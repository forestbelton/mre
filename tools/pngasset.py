#!/usr/bin/env python3
"""pngasset — generate a screen's ROM components from a single source PNG.

The goal (see docs/philosophy.md): an image's editable source is *one PNG*, and
the build regenerates the ROM bytes (tile data, palette, tilemap, attribute map)
from it. Nothing else is committed.

The committed source is the PNG plus (for screens/portraits) the non-derivable
`tilemap.bin` / `attrmap.bin`; everything else (tile data, palette) is rebuilt.
Assets live under `assets/` in a tree mirroring `src/gfx/` (logo/, intro/,
screen/<name>/, portrait/<name>/).

Reproducing the *exact* original tileset order + tilemap from a flat image needs
a layout heuristic (the game didn't dedupe in a canonical way). The heuristic
here, which reproduces the TECMO logo byte-exact:

  * The "blank" tile is the all-color-0 tile. Find the bounding box of the cells
    that aren't blank -- that's the image content.
  * Build the tile sheet COLUMN-MAJOR over that bbox: for each content column,
    emit its tiles top-to-bottom, then pad the column to `--sheet-rows` tiles with
    blank tiles. (TECMO: a 16-wide content block padded to 8 rows -> 128 tiles.)
    Tile index = content_col*sheet_rows + content_row. No deduplication: every
    content cell keeps its own index, matching the ROM.
  * The tilemap is positional: a content cell -> its column-major sheet index;
    every background cell -> the first blank tile (index = bbox height).
  * `--pad-before BYTE N` prepends N bytes (e.g. a $1000 block of blank VRAM
    tiles that sits before the real sheet).

As more screens come under this tool the heuristic will need options (row-major
order, multiple palettes, real attribute maps, 8800 vs direct addressing, two
VRAM banks). For now it does exactly what the logo needs; `verify` proves the
round-trip is byte-exact.

Commands:
    pngasset.py encode --png assets/logo/logo.png --sheet-rows 8 \
        --pad-before 0x00 4096 --out-dir build/assets/logo
    pngasset.py decode --tiles t.bin --tilemap m.bin --palette p.pal \
        --cols 20 --rows 18 --out assets/logo/logo.png      # bootstrap the PNG
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

TILE_BYTES = 0x10


# --- 2bpp tile codec -------------------------------------------------------
def tile_to_indices(tile: bytes) -> list[int]:
    """16-byte 2bpp tile -> 64 pixel indices (row-major), values 0..3."""
    px: list[int] = []
    for r in range(8):
        lo, hi = tile[r * 2], tile[r * 2 + 1]
        for c in range(8):
            px.append(((lo >> (7 - c)) & 1) | (((hi >> (7 - c)) & 1) << 1))
    return px


def indices_to_tile(px: list[int]) -> bytes:
    """64 pixel indices (row-major) -> 16-byte 2bpp tile."""
    out = bytearray()
    for r in range(8):
        lo = hi = 0
        for c in range(8):
            v = px[r * 8 + c] & 3
            lo |= (v & 1) << (7 - c)
            hi |= ((v >> 1) & 1) << (7 - c)
        out += bytes((lo, hi))
    return bytes(out)


# --- RGB555 <-> RGB888 -----------------------------------------------------
def rgb555_to_888(word: int) -> tuple[int, int, int]:
    r, g, b = word & 31, (word >> 5) & 31, (word >> 10) & 31

    def e(v: int) -> int:
        return (v << 3) | (v >> 2)

    return e(r), e(g), e(b)


def rgb888_to_555(r: int, g: int, b: int) -> int:
    return (r >> 3) | ((g >> 3) << 5) | ((b >> 3) << 10)


# --- PNG (indexed 'P' mode) ------------------------------------------------
def read_indexed_png(path: Path):
    from PIL import Image

    img = Image.open(path)
    if img.mode != "P":
        img = img.convert("P")
    w, h = img.size
    pal = img.getpalette() or []
    colors = [(pal[i], pal[i + 1], pal[i + 2]) for i in range(0, len(pal), 3)]
    return w, h, img.tobytes(), colors


def write_indexed_png(
    path: Path, w: int, h: int, pixels: bytes, colors: list[tuple[int, int, int]]
) -> None:
    from PIL import Image

    img = Image.frombytes("P", (w, h), bytes(pixels))
    flat: list[int] = []
    for c in colors:
        flat += list(c)
    flat += [0, 0, 0] * (256 - len(colors))
    img.putpalette(flat)
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path)


def read_pal_file(path: Path) -> list[int]:
    words: list[int] = []
    for line in path.read_text().splitlines():
        line = line.split(";", 1)[0].strip()
        if not line:
            continue
        words += [int(t, 16) for t in line.split()]
    return words


# --- the image model -------------------------------------------------------
def cells_from_png(png: Path):
    """Read an indexed PNG into (cols, rows, list-of-2bpp-cell-tiles, colors)."""
    w, h, px, colors = read_indexed_png(png)
    if w % 8 or h % 8:
        raise SystemExit(f"{png}: {w}x{h} not a multiple of 8")
    cols, rows = w // 8, h // 8
    cells: list[bytes] = []
    for ty in range(rows):
        for tx in range(cols):
            ind = [
                px[(ty * 8 + r) * w + (tx * 8 + c)] for r in range(8) for c in range(8)
            ]
            cells.append(indices_to_tile(ind))
    return cols, rows, cells, colors


def build_sheet_and_map(
    cols: int, rows: int, cells: list[bytes], sheet_rows: int | None
):
    """Column-major sheet over the non-blank bbox (padded to sheet_rows), plus a
    positional tilemap (background -> the first blank tile). Returns (tiles_bytes,
    tilemap_bytes)."""
    blank = bytes(TILE_BYTES)
    nb = [(i // cols, i % cols) for i, t in enumerate(cells) if t != blank]
    if not nb:
        raise SystemExit("image is entirely blank")
    r0 = min(r for r, _ in nb)
    r1 = max(r for r, _ in nb)
    c0 = min(c for _, c in nb)
    c1 = max(c for _, c in nb)
    bh = r1 - r0 + 1
    if sheet_rows is None:
        sheet_rows = bh
    if sheet_rows < bh:
        raise SystemExit(f"--sheet-rows {sheet_rows} < content height {bh}")
    sheet: list[bytes] = []
    for c in range(c0, c1 + 1):
        for r in range(r0, r1 + 1):
            sheet.append(cells[r * cols + c])
        sheet += [blank] * (sheet_rows - bh)
    bg_index = bh  # col 0's first pad tile is the first blank in the sheet
    if sheet_rows == bh and any(
        cells[r * cols + c] == blank
        for r in range(r0, r1 + 1)
        for c in range(c0, c1 + 1)
    ):
        raise SystemExit(
            "background cells exist but no blank sheet tile (raise --sheet-rows)"
        )
    tmap = bytearray(rows * cols)
    for r in range(rows):
        for c in range(cols):
            if r0 <= r <= r1 and c0 <= c <= c1:
                tmap[r * cols + c] = (c - c0) * sheet_rows + (r - r0)
            else:
                tmap[r * cols + c] = bg_index
    return b"".join(sheet), bytes(tmap)


# --- commands --------------------------------------------------------------
def cmd_encode(args: argparse.Namespace) -> int:
    cols, rows, cells, colors = cells_from_png(Path(args.png))
    tiles, tmap = build_sheet_and_map(cols, rows, cells, args.sheet_rows)
    if args.pad_before:
        byte, n = args.pad_before
        tiles = bytes([byte]) * n + tiles
    pal = bytearray()
    for word in (rgb888_to_555(*colors[i]) for i in range(args.colors)):
        pal += bytes((word & 0xFF, (word >> 8) & 0xFF))
    attr = bytes(rows * cols)
    out = Path(args.out_dir)
    out.mkdir(parents=True, exist_ok=True)
    for name, data in (
        ("tiles", tiles),
        ("palette", pal),
        ("tilemap", tmap),
        ("attrmap", attr),
    ):
        (out / f"{name}.bin").write_bytes(data)
        print(f"  {name}.bin: {len(data)} bytes")
    return 0


def cmd_decode(args: argparse.Namespace) -> int:
    tiles = Path(args.tiles).read_bytes()
    tmap = Path(args.tilemap).read_bytes()
    words = read_pal_file(Path(args.palette))
    colors = [rgb555_to_888(w) for w in words]
    cols, rows = args.cols, args.rows
    tl = [tiles[i : i + TILE_BYTES] for i in range(0, len(tiles), TILE_BYTES)]
    w, h = cols * 8, rows * 8
    px = bytearray(w * h)
    for cell in range(rows * cols):
        ty, tx = divmod(cell, cols)
        ind = tile_to_indices(tl[tmap[cell]])
        for r in range(8):
            for c in range(8):
                px[(ty * 8 + r) * w + (tx * 8 + c)] = ind[r * 8 + c]
    write_indexed_png(Path(args.out), w, h, bytes(px), colors)
    print(f"wrote {args.out}  ({w}x{h}, {len(colors)} colors)")
    return 0


def sheet_png_to_tiles(path: Path, count: int, sheet_w: int = 16) -> list[bytes]:
    """Read a tile-sheet PNG (tiles laid out `sheet_w` per row) into `count`
    2bpp tiles. Pixel values are `display_palette*4 + 2bpp_value`, so the tile's
    pixel value is `pixel % 4` (the display palette is only for viewing)."""
    w, _h, px, _ = read_indexed_png(path)
    tiles: list[bytes] = []
    for t in range(count):
        bx, by = (t % sheet_w) * 8, (t // sheet_w) * 8
        grid = [px[(by + r) * w + (bx + c)] % 4 for r in range(8) for c in range(8)]
        tiles.append(indices_to_tile(grid))
    return tiles


def cmd_screen(args: argparse.Namespace) -> int:
    """Two-VRAM-bank colour screen from ONE indexed tile-sheet PNG. The sheet holds
    both banks stacked (top `--tiles` tiles -> VRAM bank 0, bottom -> bank 1) and the
    16 CGB palettes (8 BG + 8 OBJ) in its PNG palette table; each tile is shown in
    its real palette (pixel = palette*4 + 2bpp value). Splits it into
    tiles_bank0/1.bin + palette.bin and passes the committed tilemap/attrmap (next to
    the PNG) through. The screens' full tile data can't come from a screenshot -- 402
    of town's 768 tiles are off-screen animation/scroll frames -- so the editable
    source is this sheet plus the committed maps (the arrangement). See docs/gfx_assets.md."""
    png = Path(args.png)
    d = png.parent
    tiles = sheet_png_to_tiles(png, args.tiles * 2)            # both banks, stacked
    _w, _h, _px, colors = read_indexed_png(png)
    pal = bytearray()
    for i in range(args.palettes * 4):                        # 16 palettes * 4 colors
        word = rgb888_to_555(*colors[i])
        pal += bytes((word & 0xFF, (word >> 8) & 0xFF))
    out = Path(args.out_dir)
    out.mkdir(parents=True, exist_ok=True)
    comps = [
        ("tiles_bank0", b"".join(tiles[: args.tiles])),
        ("tiles_bank1", b"".join(tiles[args.tiles:])),
        ("palette", bytes(pal)),
        ("tilemap", (d / "tilemap.bin").read_bytes()),        # committed maps,
        ("attrmap", (d / "attrmap.bin").read_bytes()),        # passed through to build/
    ]
    for name, data in comps:
        (out / f"{name}.bin").write_bytes(data)
        print(f"  {name}.bin: {len(data)} bytes")
    return 0


def parse_overrides(s: str):
    """'r,c,p;r,c,p' -> [(row,col,palette), ...] (image-irreducible palette ties)."""
    out = []
    for tok in (s or "").split(";"):
        tok = tok.strip()
        if tok:
            r, c, p = tok.split(",")
            out.append((int(r), int(c), int(p)))
    return out


def derive_portrait_maps(ref_path, tiles, palbg, rows, cols, bank, pal_overrides):
    """Re-derive (tilemap, attrmap) for a single-VRAM-bank, no-flip portrait from
    its rendered reference PNG + the tile sheet + BG palettes -- byte-exact, so the
    opaque tilemap.bin/attrmap.bin no longer need to be committed.

    tilemap: the original tool linearised the cells into the sheet column-major
    within horizontal bands, addressed $8800-signed (tilemap byte b -> tiles[b] for
    b>=128, tiles[b+256] otherwise). So the tilemap is positional; we infer the
    layout model from the unambiguous cells -- band split (where contiguity breaks),
    a learned top-band linear base(c)=(A+B*c)%256, and bottom-band column runs pinned
    by the bijection (each sheet tile used once) + the +8 column stride.
    attrmap: bank bit | per-cell BG palette. The palette is region-based, recovered
    by matching the now-known exact tile's colours and spreading by neighbour
    consensus; the few image-irreducible ties come from pal_overrides."""
    from PIL import Image
    from collections import Counter

    NT, NPAL = len(tiles) // 16, len(palbg) // 8
    rpx = Image.open(ref_path).convert("RGB").load()

    def palcol(p):
        cs = []
        for ci in range(4):
            o = p * 8 + ci * 2
            w = palbg[o] | (palbg[o + 1] << 8)
            cs.append(rgb555_to_888(w))
        return cs

    PAL = [palcol(p) for p in range(NPAL)]
    TILEPAT = [tile_to_indices(tiles[i * 16:i * 16 + 16]) for i in range(NT)]

    def block(cell):
        r0, c0 = (cell // cols) * 8, (cell % cols) * 8
        return [rpx[c0 + x, r0 + y] for y in range(8) for x in range(8)]

    BLOCK = [block(i) for i in range(rows * cols)]

    # --- tilemap: candidate sheet-bytes per cell (signed addressing) ---
    rgbidx: dict = {}
    for ti in range(128, NT):
        b = ti & 0xFF
        for p in range(NPAL):
            rgbidx.setdefault(tuple(PAL[p][v] for v in TILEPAT[ti]), set()).add(b)
    CAND = [rgbidx.get(tuple(BLOCK[i]), set()) for i in range(rows * cols)]

    def band_base(c, lo, hi):
        sets = [{(v - (r - lo)) % 256 for v in CAND[r * cols + c]} for r in range(lo, hi)]
        return set.intersection(*sets) if all(sets) else set()

    breaks: Counter = Counter()
    for c in range(cols):
        for r in range(1, rows):
            a, b = CAND[(r - 1) * cols + c], CAND[r * cols + c]
            if len(a) == 1 and len(b) == 1 and next(iter(b)) != (next(iter(a)) + 1) % 256:
                breaks[r] += 1
    K = breaks.most_common(1)[0][0] if breaks else rows
    known = {c: next(iter(band_base(c, 0, K))) for c in range(cols) if len(band_base(c, 0, K)) == 1}
    csk = sorted(known)
    B = ((known[csk[1]] - known[csk[0]]) * pow(csk[1] - csk[0], -1, 256)) % 256
    A = (known[csk[0]] - B * csk[0]) % 256
    topbase = [(A + B * c) % 256 for c in range(cols)]
    used = {(topbase[c] + r) % 256 for c in range(cols) for r in range(K)}
    botbase: dict = {c: None for c in range(cols)}

    def fits(c, base):
        return all((base + (r - K)) % 256 not in used for r in range(K, rows))

    def claim(c, base):
        botbase[c] = base
        used.update((base + (r - K)) % 256 for r in range(K, rows))

    for _ in range(cols):                                   # pass 1: unique runs
        prog = False
        for c in sorted((c for c in range(cols) if botbase[c] is None),
                        key=lambda c: len([b for b in band_base(c, K, rows) if fits(c, b)])):
            opts = [b for b in band_base(c, K, rows) if fits(c, b)]
            if len(opts) == 1:
                claim(c, opts[0]); prog = True
        if not prog:
            break
    for _ in range(cols):                                   # pass 2: +8 column stride
        prog = False
        for c in range(cols):
            if botbase[c] is not None:
                continue
            opts = [b for b in band_base(c, K, rows) if fits(c, b)]
            pref = None
            if c > 0 and botbase[c - 1] is not None and (botbase[c - 1] + 8) % 256 in opts:
                pref = (botbase[c - 1] + 8) % 256
            elif c < cols - 1 and botbase[c + 1] is not None and (botbase[c + 1] - 8) % 256 in opts:
                pref = (botbase[c + 1] - 8) % 256
            elif len(opts) == 1:
                pref = opts[0]
            if pref is not None:
                claim(c, pref); prog = True
        if not prog:
            break
    tmap = bytearray(rows * cols)
    for c in range(cols):
        for r in range(rows):
            tmap[r * cols + c] = (topbase[c] + r) % 256 if r < K else (botbase[c] + (r - K)) % 256

    # --- attrmap: bank bit | per-cell BG palette ---
    P: list = [None] * (rows * cols)
    pcand: list = [None] * (rows * cols)
    for cell in range(rows * cols):
        b = tmap[cell]
        pat = TILEPAT[b if b >= 128 else b + 256]
        pcand[cell] = [p for p in range(NPAL) if all(PAL[p][pat[i]] == BLOCK[cell][i] for i in range(64))]
        if len(pcand[cell]) == 1:
            P[cell] = pcand[cell][0]
    for _ in range(rows + cols):                            # spread by 8-neighbour consensus
        for cell in range(rows * cols):
            if P[cell] is not None:
                continue
            r0, c0 = cell // cols, cell % cols
            nb = [P[(r0+dr)*cols + (c0+dc)]
                  for dr in (-1, 0, 1) for dc in (-1, 0, 1)
                  if (dr or dc) and 0 <= r0+dr < rows and 0 <= c0+dc < cols
                  and P[(r0+dr)*cols + (c0+dc)] in pcand[cell]]
            if nb:
                P[cell] = Counter(nb).most_common(1)[0][0]
    for cell in range(rows * cols):
        if P[cell] is None:
            P[cell] = pcand[cell][0] if pcand[cell] else 0
    for (r, c, p) in pal_overrides:
        P[r * cols + c] = p
    amap = bytes((bank << 3) | P[cell] for cell in range(rows * cols))
    return bytes(tmap), amap


def cmd_portrait(args: argparse.Namespace) -> int:
    """Single- or two-VRAM-bank portrait from one tile-sheet PNG. The PNG holds the
    bank-1 (main) tiles, optionally followed by the bank-0 tiles; splits into
    tiles.bin (bank 1) + tiles2.bin (bank 0, when --tiles0 > 0) and passes the
    committed tilemap/attrmap (next to the PNG) through. When --palettes-bg/-obj are
    set, the PNG's table holds the real CGB palettes (BG palettes first, then OBJ)
    and each tile is shown in its colour (pixel = palette*4 + 2bpp value); they are
    split off into palette_bg.bin / palette_obj.bin. See docs/gfx_assets.md."""
    png = Path(args.png)
    d = png.parent
    tiles = sheet_png_to_tiles(png, args.tiles1 + args.tiles0)
    comps = [("tiles", b"".join(tiles[: args.tiles1]))]            # bank 1 (main)
    if args.tiles0:
        comps.append(("tiles2", b"".join(tiles[args.tiles1:])))   # bank 0
    if args.palettes_bg or args.palettes_obj:
        _w, _h, _px, colors = read_indexed_png(png)

        def pack(first: int, n: int) -> bytes:
            out = bytearray()
            for i in range(first, first + n * 4):                 # n palettes * 4 colors
                word = rgb888_to_555(*colors[i])
                out += bytes((word & 0xFF, (word >> 8) & 0xFF))
            return bytes(out)

        if args.palettes_bg:                                      # BG palettes lead the table
            comps.append(("palette_bg", pack(0, args.palettes_bg)))
        if args.palettes_obj:                                     # OBJ palettes follow them
            comps.append(("palette_obj", pack(args.palettes_bg * 4, args.palettes_obj)))
    if getattr(args, "reference", None):
        # derive the maps from the rendered reference image (BG layer) instead of
        # committing tilemap.bin/attrmap.bin. Needs the bank-1 tiles + BG palettes.
        palbg = next(data for name, data in comps if name == "palette_bg")
        tmap, amap = derive_portrait_maps(
            d / args.reference, comps[0][1], palbg, args.rows, args.cols,
            args.bank, parse_overrides(args.pal_overrides))
        comps += [("tilemap", tmap), ("attrmap", amap)]
    else:
        comps += [
            ("tilemap", (d / "tilemap.bin").read_bytes()),
            ("attrmap", (d / "attrmap.bin").read_bytes()),
        ]
    out = Path(args.out_dir)
    out.mkdir(parents=True, exist_ok=True)
    for name, data in comps:
        (out / f"{name}.bin").write_bytes(data)
        print(f"  {name}.bin: {len(data)} bytes")
    return 0


def main() -> int:
    doc = __doc__
    assert doc is not None

    p = argparse.ArgumentParser(description=doc.splitlines()[0])
    sub = p.add_subparsers(dest="cmd", required=True)

    sc = sub.add_parser(
        "screen", help="two-bank colour screen: one tile-sheet PNG -> tiles/palette .bin"
    )
    sc.add_argument(
        "--png", required=True,
        help="combined indexed sheet (both banks stacked, 16 palettes embedded); "
             "tilemap.bin/attrmap.bin live next to it",
    )
    sc.add_argument("--out-dir", required=True)
    sc.add_argument("--tiles", type=int, default=384, help="tiles per bank")
    sc.add_argument("--palettes", type=int, default=16, help="palettes in the PNG table")
    sc.set_defaults(fn=cmd_screen)

    pt = sub.add_parser(
        "portrait", help="grayscale portrait: one tile-sheet PNG -> tiles(.bin)(+tiles2.bin)"
    )
    pt.add_argument("--png", required=True,
                    help="grayscale sheet: bank-1 tiles then (optional) bank-0 tiles; "
                         "tilemap.bin/attrmap.bin live next to it")
    pt.add_argument("--out-dir", required=True)
    pt.add_argument("--tiles1", type=int, default=384, help="bank-1 (main) tile count")
    pt.add_argument("--tiles0", type=int, default=0, help="bank-0 tile count (0 = single bank)")
    pt.add_argument("--palettes-bg", type=int, default=0,
                    help="BG palettes in the PNG table (0 = grayscale, no palette.bin)")
    pt.add_argument("--palettes-obj", type=int, default=0, help="OBJ palettes, after the BG ones")
    pt.add_argument("--reference", default=None,
                    help="rendered reference PNG (next to --png); derive the maps from it "
                         "instead of committing tilemap.bin/attrmap.bin")
    pt.add_argument("--rows", type=int, default=0, help="map rows (with --reference)")
    pt.add_argument("--cols", type=int, default=0, help="map cols (with --reference)")
    pt.add_argument("--bank", type=int, default=1, help="VRAM bank for attr bit 3 (single-bank)")
    pt.add_argument("--pal-overrides", default="",
                    help="image-irreducible palette ties: 'r,c,p;r,c,p'")
    pt.set_defaults(fn=cmd_portrait)

    e = sub.add_parser("encode", help="PNG -> tiles/palette/tilemap/attrmap .bin")
    e.add_argument("--png", required=True)
    e.add_argument("--out-dir", required=True)
    e.add_argument(
        "--sheet-rows",
        type=int,
        default=None,
        help="pad each content column to this many tiles (default: content height)",
    )
    e.add_argument("--colors", type=int, default=4, help="palette entries to emit")
    e.add_argument(
        "--pad-before",
        nargs=2,
        metavar=("BYTE", "N"),
        default=None,
        help="prepend N bytes of BYTE to tiles.bin (e.g. 0x00 4096)",
    )
    e.set_defaults(fn=cmd_encode)

    d = sub.add_parser(
        "decode", help="component .bin/.pal -> composite PNG (bootstrap)"
    )
    d.add_argument("--tiles", required=True)
    d.add_argument("--tilemap", required=True)
    d.add_argument("--palette", required=True, help=".pal text file")
    d.add_argument("--cols", type=int, required=True)
    d.add_argument("--rows", type=int, required=True)
    d.add_argument("--out", required=True)
    d.set_defaults(fn=cmd_decode)

    args = p.parse_args()
    if getattr(args, "pad_before", None):
        args.pad_before = (int(args.pad_before[0], 0), int(args.pad_before[1], 0))
    return args.fn(args)


if __name__ == "__main__":
    sys.exit(main())
