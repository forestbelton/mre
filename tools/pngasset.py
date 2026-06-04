#!/usr/bin/env python3
"""pngasset — generate a screen's ROM components from a single source PNG.

The goal (see docs/philosophy.md): an image's editable source is *one PNG*, and
the build regenerates the ROM bytes (tile data, palette, tilemap, attribute map)
from it. Nothing else is committed.

This is the successor to gfxasset.py's multi-file `assets/<name>/` layout: instead
of committing tiles.png + palette.pal + tilemap.bin + attrmap.bin + asset.json, we
commit just `assets/<name>.png` and reconstruct everything.

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
    pngasset.py encode --png assets/logo.png --sheet-rows 8 \
        --pad-before 0x00 4096 --out-dir build/assets/logo
    pngasset.py decode --tiles t.bin --tilemap m.bin --palette p.pal \
        --cols 20 --rows 18 --out assets/logo.png      # bootstrap the PNG
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

TILE_BYTES = 0x10


# --- 2bpp tile codec -------------------------------------------------------
def tile_to_indices(tile: bytes) -> list[int]:
    """16-byte 2bpp tile -> 64 pixel indices (row-major), values 0..3."""
    px = []
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
    e = lambda v: (v << 3) | (v >> 2)
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


def write_indexed_png(path: Path, w: int, h: int, pixels: bytes,
                      colors: list[tuple[int, int, int]]) -> None:
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
    cells = []
    for ty in range(rows):
        for tx in range(cols):
            ind = [px[(ty * 8 + r) * w + (tx * 8 + c)]
                   for r in range(8) for c in range(8)]
            cells.append(indices_to_tile(ind))
    return cols, rows, cells, colors


def build_sheet_and_map(cols: int, rows: int, cells: list[bytes], sheet_rows: int):
    """Column-major sheet over the non-blank bbox (padded to sheet_rows), plus a
    positional tilemap (background -> the first blank tile). Returns (tiles_bytes,
    tilemap_bytes)."""
    blank = bytes(TILE_BYTES)
    nb = [(i // cols, i % cols) for i, t in enumerate(cells) if t != blank]
    if not nb:
        raise SystemExit("image is entirely blank")
    r0 = min(r for r, _ in nb); r1 = max(r for r, _ in nb)
    c0 = min(c for _, c in nb); c1 = max(c for _, c in nb)
    bh = r1 - r0 + 1
    if sheet_rows is None:
        sheet_rows = bh
    if sheet_rows < bh:
        raise SystemExit(f"--sheet-rows {sheet_rows} < content height {bh}")
    sheet = []
    for c in range(c0, c1 + 1):
        for r in range(r0, r1 + 1):
            sheet.append(cells[r * cols + c])
        sheet += [blank] * (sheet_rows - bh)
    bg_index = bh   # col 0's first pad tile is the first blank in the sheet
    if sheet_rows == bh and any(cells[r * cols + c] == blank
                                for r in range(r0, r1 + 1) for c in range(c0, c1 + 1)):
        raise SystemExit("background cells exist but no blank sheet tile (raise --sheet-rows)")
    tmap = bytearray(rows * cols)
    for r in range(rows):
        for c in range(cols):
            if r0 <= r <= r1 and c0 <= c <= c1:
                tmap[r * cols + c] = (c - c0) * sheet_rows + (r - r0)
            else:
                tmap[r * cols + c] = bg_index
    return b"".join(sheet), bytes(tmap)


# --- commands --------------------------------------------------------------
def cmd_encode(args) -> int:
    cols, rows, cells, colors = cells_from_png(Path(args.png))
    tiles, tmap = build_sheet_and_map(cols, rows, cells, args.sheet_rows)
    if args.pad_before:
        byte, n = args.pad_before
        tiles = bytes([byte]) * n + tiles
    pal = bytearray()
    for word in (rgb888_to_555(*colors[i]) for i in range(args.colors)):
        pal += bytes((word & 0xFF, (word >> 8) & 0xFF))
    attr = bytes(rows * cols)
    out = Path(args.out_dir); out.mkdir(parents=True, exist_ok=True)
    for name, data in (("tiles", tiles), ("palette", pal),
                       ("tilemap", tmap), ("attrmap", attr)):
        (out / f"{name}.bin").write_bytes(data)
        print(f"  {name}.bin: {len(data)} bytes")
    return 0


def cmd_decode(args) -> int:
    tiles = Path(args.tiles).read_bytes()
    tmap = Path(args.tilemap).read_bytes()
    words = read_pal_file(Path(args.palette))
    colors = [rgb555_to_888(w) for w in words]
    cols, rows = args.cols, args.rows
    tl = [tiles[i:i + TILE_BYTES] for i in range(0, len(tiles), TILE_BYTES)]
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


def main(argv=None) -> int:
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    sub = p.add_subparsers(dest="cmd", required=True)

    e = sub.add_parser("encode", help="PNG -> tiles/palette/tilemap/attrmap .bin")
    e.add_argument("--png", required=True)
    e.add_argument("--out-dir", required=True)
    e.add_argument("--sheet-rows", type=int, default=None,
                   help="pad each content column to this many tiles (default: content height)")
    e.add_argument("--colors", type=int, default=4, help="palette entries to emit")
    e.add_argument("--pad-before", nargs=2, metavar=("BYTE", "N"), default=None,
                   help="prepend N bytes of BYTE to tiles.bin (e.g. 0x00 4096)")
    e.set_defaults(fn=cmd_encode)

    d = sub.add_parser("decode", help="component .bin/.pal -> composite PNG (bootstrap)")
    d.add_argument("--tiles", required=True)
    d.add_argument("--tilemap", required=True)
    d.add_argument("--palette", required=True, help=".pal text file")
    d.add_argument("--cols", type=int, required=True)
    d.add_argument("--rows", type=int, required=True)
    d.add_argument("--out", required=True)
    d.set_defaults(fn=cmd_decode)

    args = p.parse_args(argv)
    if getattr(args, "pad_before", None):
        args.pad_before = (int(args.pad_before[0], 0), int(args.pad_before[1], 0))
    return args.fn(args)


if __name__ == "__main__":
    sys.exit(main())
