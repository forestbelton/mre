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


def tmx_to_maps(tmx_path, tiles_per_bank=384, banks=2, base_tile=0):
    """Compile a Tiled .tmx into (tilemap, attrmap) bytes — the hand-authored
    (family-A) map source, see docs/asset_source_model.md.

    Tilesets (by tilecount): the sheet (banks*tiles_per_bank tiles; VRAM banks
    stacked when banks=2, or alternate sets — a map may only reference the
    first when banks=1), the 8-swatch palette tileset, and optionally a
    384-tile "vram1" placeholder for cells whose bank-1 tiles are loaded by
    another subsystem (not in this sheet).
    Layers: "map" (arrangement; Tiled flip flags = attr bits 5/6), "palette"
    (per-cell CGB palette), optional "priority" (any swatch = attr bit 7).
    base_tile = the VRAM tile number of sheet index 0 (0 for $8000-loaded
    sheets, 128 for $8800); map bytes are $8800-signed."""
    import xml.etree.ElementTree as ET

    HFLIP, VFLIP, GIDMASK = 0x80000000, 0x40000000, 0x0FFFFFFF
    root = ET.parse(tmx_path).getroot()
    sheet_first = pal_first = vram1_first = None
    nsheet = banks * tiles_per_bank
    for ts in root.findall("tileset"):
        n = int(ts.get("tilecount", 0))
        first = int(ts.get("firstgid"))
        if n == nsheet and sheet_first is None:
            sheet_first = first
        elif n == 8:
            pal_first = first
        elif ts.get("name") == "vram1":
            vram1_first = first
    if sheet_first is None or pal_first is None:
        raise SystemExit(f"{tmx_path}: need a {nsheet}-tile sheet tileset "
                         "and an 8-swatch palette tileset")
    layers = {}
    for ly in root.findall("layer"):
        data = ly.find("data")
        if data.get("encoding") != "csv":
            raise SystemExit(f"{tmx_path}: layer {ly.get('name')!r} must be CSV-encoded")
        layers[ly.get("name")] = [int(t) for t in data.text.replace("\n", ",").split(",")
                                  if t.strip()]
    if "map" not in layers or "palette" not in layers:
        raise SystemExit(f"{tmx_path}: need layers 'map' and 'palette'")
    gids, pals = layers["map"], layers["palette"]
    prio = layers.get("priority", [0] * len(gids))
    if not (len(gids) == len(pals) == len(prio)):
        raise SystemExit(f"{tmx_path}: layer size mismatch")
    tmap, amap = bytearray(), bytearray()
    for cell, (g, pg, pr) in enumerate(zip(gids, pals, prio)):
        xf, yf = bool(g & HFLIP), bool(g & VFLIP)
        idx = (g & GIDMASK) - sheet_first
        if vram1_first is not None and (g & GIDMASK) >= vram1_first:
            bank, vt = 1, (g & GIDMASK) - vram1_first   # tile loaded elsewhere
        elif 0 <= idx < nsheet:
            bank, sidx = divmod(idx, tiles_per_bank)
            vt = base_tile + sidx
        else:
            raise SystemExit(f"{tmx_path}: cell {cell} is empty/not a sheet tile")
        if not 128 <= vt < 384:
            raise SystemExit(f"{tmx_path}: cell {cell} -> VRAM tile {vt} "
                             "(not addressable in $8800 BG mode)")
        tmap.append(vt & 0xFF)
        pal = pg - pal_first
        if not 0 <= pal <= 7:
            raise SystemExit(f"{tmx_path}: cell {cell} palette layer isn't a swatch")
        amap.append(pal | (bank << 3) | (xf << 5) | (yf << 6) | ((pr != 0) << 7))
    return bytes(tmap), bytes(amap)


def tmx_frames_to_maps(tmx_path):
    """Compile a scene's frames.tmx -- one Tiled layer pair (frameNN +
    frameNN_pal) per CopyBgMap animation frame -- into an ordered list of
    (name, rows, cols, idx_bytes, attr_bytes). Each frame occupies the
    top-left rows x cols rectangle of its layer (the rest empty); the sheet
    tileset GIDs encode bank*384 + VRAM tile number (128-383, $8800-signed)."""
    import xml.etree.ElementTree as ET

    HFLIP, VFLIP, GIDMASK = 0x80000000, 0x40000000, 0x0FFFFFFF
    root = ET.parse(tmx_path).getroot()
    sheet_first = pal_first = None
    for ts in root.findall("tileset"):
        n = int(ts.get("tilecount", 0))
        if n == 8:
            pal_first = int(ts.get("firstgid"))
        elif sheet_first is None:
            sheet_first = int(ts.get("firstgid"))
    layers = {}
    order = []
    for ly in root.findall("layer"):
        data = ly.find("data")
        vals = [int(t) for t in data.text.replace("\n", ",").split(",") if t.strip()]
        layers[ly.get("name")] = (int(ly.get("width")), vals)
        if not ly.get("name").endswith("_pal"):
            order.append(ly.get("name"))
    out = []
    for name in order:
        W, gids = layers[name]
        _, pals = layers[name + "_pal"]
        filled = [i for i, g in enumerate(gids) if g]
        rows = max(i // W for i in filled) + 1
        cols = max(i % W for i in filled) + 1
        idx, attr = bytearray(), bytearray()
        for r in range(rows):
            for c in range(cols):
                g, pg = gids[r * W + c], pals[r * W + c]
                if not g:
                    raise SystemExit(f"{tmx_path}:{name}: hole at ({r},{c}) -- "
                                     "frames must fill their top-left rectangle")
                xf, yf = bool(g & HFLIP), bool(g & VFLIP)
                i = (g & GIDMASK) - sheet_first
                bank, vt = divmod(i, 384)
                if not 128 <= vt < 384:
                    raise SystemExit(f"{tmx_path}:{name}: cell ({r},{c}) -> VRAM "
                                     f"tile {vt} (not addressable in $8800 mode)")
                idx.append(vt & 0xFF)
                attr.append((pg - pal_first) | (bank << 3) | (xf << 5) | (yf << 6))
        out.append((name, rows, cols, bytes(idx), bytes(attr)))
    return out


def tmx_layer_to_map(tmx_path, layer_name, base_tile=128):
    """Compile ONE named layer (+ its <layer>_pal twin) of a Tiled map into
    (tilemap, attrmap) bytes. The map may hold several sheet tilesets (e.g. one
    per monster, each layer drawn over its own); a gid resolves against
    whichever tileset's range contains it, and the tile byte is the
    $8800-signed VRAM tile number base_tile + (gid - firstgid). The 8-swatch
    "palettes" tileset carries the per-cell CGB palette; Tiled flip flags map
    to attr bits 5/6. (Used by the monster portraits --
    assets/monster_portrait/monster_portraits.tmx.)"""
    import xml.etree.ElementTree as ET

    HFLIP, VFLIP, GIDMASK = 0x80000000, 0x40000000, 0x0FFFFFFF
    root = ET.parse(tmx_path).getroot()
    sheets = []                       # (firstgid, tilecount)
    pal_first = None
    for ts in root.findall("tileset"):
        n = int(ts.get("tilecount", 0))
        first = int(ts.get("firstgid"))
        if n == 8:
            pal_first = first
        else:
            sheets.append((first, n))
    layers = {}
    for ly in root.findall("layer"):
        data = ly.find("data")
        layers[ly.get("name")] = [int(t) for t in
                                  data.text.replace("\n", ",").split(",") if t.strip()]
    if layer_name not in layers or f"{layer_name}_pal" not in layers:
        raise SystemExit(f"{tmx_path}: need layers {layer_name!r} + '{layer_name}_pal'")
    gids, pals = layers[layer_name], layers[f"{layer_name}_pal"]
    tmap, amap = bytearray(), bytearray()
    for cell, (g, pg) in enumerate(zip(gids, pals)):
        xf, yf = bool(g & HFLIP), bool(g & VFLIP)
        raw = g & GIDMASK
        for first, n in sheets:
            if first <= raw < first + n:
                vt = base_tile + (raw - first)
                break
        else:
            raise SystemExit(f"{tmx_path}:{layer_name}: cell {cell} is empty/"
                             "not a sheet tile")
        if not 128 <= vt < 384:
            raise SystemExit(f"{tmx_path}:{layer_name}: cell {cell} -> VRAM tile "
                             f"{vt} (not addressable in $8800 BG mode)")
        tmap.append(vt & 0xFF)
        amap.append((pg - pal_first) | (xf << 5) | (yf << 6))
    return bytes(tmap), bytes(amap)


def cmd_maplib(args: argparse.Namespace) -> int:
    """A screen-library bank: one indexed sheet PNG (--tiles total, --banks 1 for
    alternate sets / 2 for stacked VRAM banks, --base = VRAM tile number of sheet
    index 0), --palettes CGB palettes in its table, and any number of Tiled .tmx
    maps -> tiles.bin, palette.bin, <stem>_idx.bin/<stem>_attr.bin per map."""
    png = Path(args.png)
    d = png.parent
    tiles = sheet_png_to_tiles(png, args.tiles)
    out = Path(args.out_dir)
    out.mkdir(parents=True, exist_ok=True)
    comps = [("tiles", b"".join(tiles))]
    if args.palettes:
        _w, _h, _px, colors = read_indexed_png(png)
        pal = bytearray()
        for i in range(args.palettes * 4):
            word = rgb888_to_555(*colors[i])
            pal += bytes((word & 0xFF, (word >> 8) & 0xFF))
        comps.append(("palette", bytes(pal)))
    for tmx in (args.maps or "").split(","):
        tmx = tmx.strip()
        if not tmx:
            continue
        tmap, amap = tmx_to_maps(d / tmx, args.tiles // args.banks, args.banks,
                                 args.base)
        stem = Path(tmx).stem
        comps += [(f"{stem}_idx", tmap), (f"{stem}_attr", amap)]
    for name, data in comps:
        (out / f"{name}.bin").write_bytes(data)
        print(f"  {name}.bin: {len(data)} bytes")
    return 0


def cmd_screen(args: argparse.Namespace) -> int:
    """Two-VRAM-bank colour screen from ONE indexed tile-sheet PNG. The sheet holds
    both banks stacked (top `--tiles` tiles -> VRAM bank 0, bottom -> bank 1) and the
    16 CGB palettes (8 BG + 8 OBJ) in its PNG palette table; each tile is shown in
    its real palette (pixel = palette*4 + 2bpp value). Splits it into
    tiles_bank0/1.bin + palette.bin; the arrangement comes from the Tiled .tmx
    (--map, the hand-authored source — open it in Tiled with the sheet as tileset).
    The screens' full tile data can't come from a screenshot -- 402 of town's 768
    tiles are off-screen animation/scroll frames -- so the editable source is this
    sheet plus the map. See docs/gfx_assets.md, docs/asset_source_model.md."""
    png = Path(args.png)
    d = png.parent
    tiles = sheet_png_to_tiles(png, args.tiles * 2)            # both banks, stacked
    _w, _h, _px, colors = read_indexed_png(png)
    pal = bytearray()
    for i in range(args.palettes * 4):                        # 16 palettes * 4 colors
        word = rgb888_to_555(*colors[i])
        pal += bytes((word & 0xFF, (word >> 8) & 0xFF))
    if getattr(args, "map", None):
        tmap, amap = tmx_to_maps(d / args.map, args.tiles, 2, 0)
    else:
        tmap = (d / "tilemap.bin").read_bytes()               # legacy committed maps
        amap = (d / "attrmap.bin").read_bytes()
    out = Path(args.out_dir)
    out.mkdir(parents=True, exist_ok=True)
    comps = [
        ("tiles_bank0", b"".join(tiles[: args.tiles])),
        ("tiles_bank1", b"".join(tiles[args.tiles:])),
        ("palette", bytes(pal)),
        ("tilemap", tmap),
        ("attrmap", amap),
    ]
    for name, data in comps:
        (out / f"{name}.bin").write_bytes(data)
        print(f"  {name}.bin: {len(data)} bytes")
    return 0


def cmd_scene(args: argparse.Namespace) -> int:
    """Summon-animation scene tiles from ONE indexed tile-sheet PNG -- the same stacked
    two-bank sheet as `screen` (top `--tiles` -> VRAM bank 0, bottom -> bank 1; the PNG
    palette table holds the scene's `--palettes` CGB palettes; pixel = palette*4 + 2bpp
    value). Splits into tiles_bank0/1.2bpp + palette.bin and passes the committed
    descriptors.bin / metasprites.bin (next to the PNG; the BG-frame tilemaps + OBJ lists,
    which the bank-$05 scene VM drives) through to build/. Only the tile art + palette are
    editable here; the frame layout stays as data. See docs/screen_tilemaps.md."""
    png = Path(args.png)
    d = png.parent
    tiles = sheet_png_to_tiles(png, args.tiles * 2)            # both banks, stacked
    _w, _h, _px, colors = read_indexed_png(png)
    pal = bytearray()
    for i in range(args.palettes * 4):                        # N palettes * 4 colors
        word = rgb888_to_555(*colors[i])
        pal += bytes((word & 0xFF, (word >> 8) & 0xFF))
    out = Path(args.out_dir)
    out.mkdir(parents=True, exist_ok=True)
    comps = [
        ("tiles_bank0.2bpp", b"".join(tiles[: args.tiles])),
        ("tiles_bank1.2bpp", b"".join(tiles[args.tiles:])),
        ("palette.bin", bytes(pal)),
    ]
    if getattr(args, "frames", None):
        for name, rows, cols, idx, attr in tmx_frames_to_maps(d / args.frames):
            comps += [(f"{name}_idx.bin", idx), (f"{name}_attr.bin", attr)]
    for name, data in comps:
        (out / name).write_bytes(data)
        print(f"  {name}: {len(data)} bytes")
    return 0


# --- portrait BG maps: reconstructed allocator output ------------------------
# The portrait converter allocated the 11x20 base picture positionally, with NO
# dedup: top band (rows 0-7) column-major 8-deep from $80 (byte = $80+8*col+row,
# wrapping into $00-$1f for cols 16-19), bottom band (rows 8-10) packed into the
# leftover 8-byte groups from $20. Two packings exist (most portraits vs
# pashute); both are content-independent constants, byte-identical across every
# portrait that uses them. See docs/asset_source_model.md (family G).
def _portrait_layout(bottom):
    top = [(0x80 + 8 * c + r) & 0xFF for r in range(8) for c in range(20)]
    return {"rows": 11, "cols": 20, "attr_or": 0x08,
            "map": bytes(top) + bytes(bottom)}


PORTRAIT_LAYOUTS = {
    "standard": _portrait_layout([
        0x20, 0x28, 0x30, 0x38, 0x40, 0x48, 0x50, 0x58, 0x23, 0x2b, 0x33, 0x3b, 0x43, 0x4b, 0x53, 0x5b, 0x26, 0x2e, 0x36, 0x3e,
        0x21, 0x29, 0x31, 0x39, 0x41, 0x49, 0x51, 0x59, 0x24, 0x2c, 0x34, 0x3c, 0x44, 0x4c, 0x54, 0x5c, 0x27, 0x2f, 0x37, 0x3f,
        0x22, 0x2a, 0x32, 0x3a, 0x42, 0x4a, 0x52, 0x5a, 0x25, 0x2d, 0x35, 0x3d, 0x45, 0x4d, 0x55, 0x5d, 0x46, 0x47, 0x4e, 0x4f,
    ]),
    "pashute": _portrait_layout([
        0x20, 0x28, 0x30, 0x38, 0x40, 0x48, 0x50, 0x58, 0x60, 0x63, 0x66, 0x69, 0x23, 0x2b, 0x33, 0x3b, 0x43, 0x4b, 0x53, 0x5b,
        0x21, 0x29, 0x31, 0x39, 0x41, 0x49, 0x51, 0x59, 0x61, 0x64, 0x67, 0x6a, 0x24, 0x2c, 0x34, 0x3c, 0x44, 0x4c, 0x54, 0x5c,
        0x22, 0x2a, 0x32, 0x3a, 0x42, 0x4a, 0x52, 0x5a, 0x62, 0x65, 0x68, 0x6b, 0x25, 0x2d, 0x35, 0x3d, 0x45, 0x4d, 0x55, 0x5d,
    ]),
}


def derive_portrait_maps(sheet_png, layout, blank_byte=None, ref_png=None,
                         map_overrides=None):
    """Derive (tilemap, attrmap) for a positional (family-G) portrait/screen.

    tilemap = the named layout constant (PORTRAIT_LAYOUTS). attrmap = attr_or |
    palette, where each cell's palette is the display palette of its slot's
    tile in the INDEXED sheet PNG (positional allocation is bijective).

    blank_byte: some portraits (mistral -> $80) don't keep every cell's tile at
    its positional slot -- blank cells were collapsed to the shared blank tile
    and their slots reused for other art. The rule that reproduces the ROM:
    a cell keeps its positional byte iff the sheet still holds the cell's exact
    pixels at that slot; otherwise it gets `blank_byte`. The cell's pixels (and
    palette) come from `ref_png`, the composed reference (indexed, pixel =
    palette*4 + value). map_overrides pins blank-cell/blank-slot ties."""
    w, h, px, _ = read_indexed_png(Path(sheet_png))
    L = PORTRAIT_LAYOUTS[layout]
    rows, cols, attr_or, layout_bytes = L["rows"], L["cols"], L["attr_or"], L["map"]
    ncell = rows * cols
    nt = (w // 8) * (h // 8)

    def slot(byte):
        t = byte if byte >= 128 else byte + 256       # $8800-signed VRAM tile no.
        if nt <= 256:                                  # small sheet loaded at $8800
            t -= 128
        return t

    def slot_vals(byte):
        t = slot(byte)
        bx, by = (t % 16) * 8, (t // 16) * 8
        return [px[(by + y) * w + bx + x] % 4 for y in range(8) for x in range(8)]

    def slot_pal(byte):
        t = slot(byte)
        return px[(t // 16) * 8 * w + (t % 16) * 8] // 4   # tiles are palette-uniform

    if blank_byte is None:
        amap = bytes(attr_or | slot_pal(layout_bytes[cell]) for cell in range(ncell))
        return layout_bytes, amap

    rw, rh, rpx, _ = read_indexed_png(Path(ref_png))
    assert (rw, rh) == (cols * 8, rows * 8), "reference dims must match the layout"
    tmap = bytearray()
    amap = bytearray()
    for cell in range(ncell):
        r, c = cell // cols, cell % cols
        block = [rpx[(r * 8 + y) * rw + c * 8 + x] for y in range(8) for x in range(8)]
        vals = [q % 4 for q in block]
        keep = slot_vals(layout_bytes[cell]) == vals
        tmap.append(layout_bytes[cell] if keep else blank_byte)
        amap.append(attr_or | (block[0] // 4))
    for cell, byte in (map_overrides or {}).items():
        tmap[int(cell)] = byte
    return bytes(tmap), bytes(amap)


def gen_sprite_region(manifest_path, tiles, tiles2=None):
    """Regenerate a portrait's metasprite/patch data region byte-exact from its
    layered source: a manifest (ordered blocks + roles) plus one INDEXED PNG per
    block (pixel = display_palette*4 + 2bpp value, so each cell/record's palette
    is explicit in the image -- nothing is inferred from colours).

    Two block kinds, the two halves of a portrait's animation overlay:
      * patch -- a CopyBgMap sub-tilemap (BG layer): [rows][cols][attr_ptr][idx_ptr]
        + idx map + attr map. The idx is positional (column-major, byte = base+8*col
        +row, $8800-signed); duplicate-tile ambiguity is resolved by that model.
        Pointers are absolute, computed from the block's laid-out address
        (idx_ptr = addr+6, attr_ptr = addr+6+rows*cols), so `base` in the manifest
        must match the asm SECTION address.
      * meta  -- a DrawMetasprite OAM list (OBJ layer): [count] + [Yoff,Xoff,tile,
        attr]*count, 8x16. The PNG carries the bitmap; its placement origin (oy,ox,
        possibly negative) is manifest metadata. Tile picked with the +2 even-tile
        run model.
    See docs/gfx_assets.md, docs/asset_source_model.md and portrait_overlays.md."""
    from collections import Counter

    import yaml
    from PIL import Image

    NT = len(tiles) // 16
    TPX = [tile_to_indices(tiles[i * 16:i * 16 + 16]) for i in range(NT)]
    # BG: signed tilemap-byte lookup (b -> tiles[b] for b>=128 else tiles[b+256])
    bgidx: dict = {}
    for ti in range(128, NT):
        bgidx.setdefault(tuple(TPX[ti]), []).append(ti & 0xFF)
    # two-bank portraits: a patch cell with attr bit 3 = 0 reads the bank-0 sheet
    # (tiles2, loaded at VRAM $9000), addressed byte b (<128) -> tiles2[b].
    NT2 = len(tiles2) // 16 if tiles2 else 0
    TPX2 = [tile_to_indices(tiles2[i * 16:i * 16 + 16]) for i in range(NT2)]
    bgidx0: dict = {}
    for ti in range(NT2):
        bgidx0.setdefault(tuple(TPX2[ti]), []).append(ti)
    # OBJ: 8x16 (top tile T even + T+1) -> list of even tile T
    objidx: dict = {}
    for T in range(0, NT, 2):
        objidx.setdefault(tuple(TPX[T & 0xFE] + TPX[(T & 0xFE) + 1]), []).append(T)
    # two-bank portraits also draw OBJ records from the bank-0 sheet (tiles2): a
    # metasprite record with attr bit 3 = 0 reads tiles2 -- same per-record `bank0` map
    # as patches. Build the bank-0 OBJ lookup / blank set in parallel.
    objidx2: dict = {}
    for T in range(0, NT2, 2):
        objidx2.setdefault(tuple(TPX2[T & 0xFE] + TPX2[(T & 0xFE) + 1]), []).append(T)
    # blank (all-colour-0) OBJ tiles, byte-indexable -- a transparent grid cell must
    # use one of these, and the tool reuses the lowest when padding the grid.
    blank_obj = sorted(T for T in range(0, min(256, NT - 1), 2)
                       if not any(TPX[T]) and not any(TPX[T + 1]))
    blank_obj2 = sorted(T for T in range(0, min(256, NT2 - 1), 2)
                        if not any(TPX2[T]) and not any(TPX2[T + 1]))

    def cell_pal(blk, what):
        ps = {q // 4 for q in blk}
        if len(ps) != 1:
            raise SystemExit(f"{what}: cell mixes display palettes {sorted(ps)} "
                             "(indexed cel pixels must be palette*4 + value)")
        return ps.pop()

    def gen_patch(img, addr, bank, idx_over=None, bank0=None):
        px = img.load()
        cols, rows = img.size[0] // 8, img.size[1] // 8
        grid = [(r, c) for r in range(rows) for c in range(cols)]
        blks = [[px[c * 8 + x, r * 8 + y] for y in range(8) for x in range(8)] for (r, c) in grid]
        vals = [tuple(q % 4 for q in blk) for blk in blks]
        # PALETTE is explicit in the indexed source (pixel // 4), per cell.
        P = [cell_pal(blk, "patch") for blk in blks]
        # two-bank patches: a per-cell bank (attr bit 3). bank0 (committed metadata, the
        # monster-body region) reads tiles2; the rest read the bank-1 sheet. Single-bank
        # patches leave bank0 empty -> every cell uses `bank` (the block default).
        bset = set(bank0 or [])
        cbank = [0 if i in bset else bank for i in range(len(grid))]
        # TILE (positional): a cell's byte candidates are the sheet bytes (in its bank)
        # whose tile VALUES equal the cell's -- exact, no palette dimension; the byte is
        # then fixed positionally -- bank-1 cells by column-major (byte = base + 8*col
        # + row), bank-0 cells by their contiguous column-major allocation in tiles2
        # (byte = base0 + rank, rank = the cell's index among bank-0 cells, column-major).
        def cand(i):
            tbl = bgidx if cbank[i] else bgidx0
            return sorted(tbl.get(vals[i], ()))

        bcand = [cand(i) for i in range(len(grid))]
        pin = [bs[0] if len(bs) == 1 else None for bs in bcand]
        bcnt = Counter((pin[i] - 8 * c - r) % 256
                       for i, (r, c) in enumerate(grid) if pin[i] is not None and cbank[i])
        base = bcnt.most_common(1)[0][0] if bcnt else None
        order0 = [r * cols + c for c in range(cols) for r in range(rows) if r * cols + c in bset]
        rank0 = {cell: k for k, cell in enumerate(order0)}
        b0cnt = Counter((pin[i] - rank0[i]) % 256 for i in bset if pin[i] is not None)
        base0 = b0cnt.most_common(1)[0][0] if b0cnt else None
        idx = []
        for i, (bs, (r, c)) in enumerate(zip(bcand, grid)):
            if pin[i] is not None:
                idx.append(pin[i])
                continue
            if cbank[i] == 0:
                want = (base0 + rank0[i]) % 256 if base0 is not None else None
            else:
                want = (base + 8 * c + r) % 256 if base is not None else None
            if want in bs:
                idx.append(want)
                continue
            # the positional model doesn't reach this duplicate cell -- it belongs to a
            # freshly-allocated band; prefer a candidate within the byte range its row's
            # same-bank pinned cells span (that band) over the lowest sheet byte.
            rb = [pin[r * cols + cc] for cc in range(cols)
                  if pin[r * cols + cc] is not None and cbank[r * cols + cc] == cbank[i]]
            inrange = [b for b in bs if rb and min(rb) <= b <= max(rb)]
            idx.append(inrange[0] if inrange else (bs[0] if bs else 0))
        # image-irreducible tile: a cell whose pixels match several sheet tiles where the
        # tool reused a non-local duplicate the column-major model can't predict (e.g.
        # Verde's blinking-eye frames) is pinned per-cell via the manifest `idx` map.
        for cell, b in (idx_over or {}).items():
            idx[int(cell)] = b
        attr = bytes((cbank[cell] << 3) | P[cell] for cell in range(rows * cols))
        ip = (addr + 6) & 0xFFFF
        ap = (addr + 6 + rows * cols) & 0xFFFF
        return bytes([rows, cols, ap & 0xFF, ap >> 8, ip & 0xFF, ip >> 8]) + bytes(idx) + attr

    def gen_meta(img, oy, ox, bank, idx_over=None, bank0=None):
        px = img.load()
        W, H = img.size
        cols = W // 8
        # two-bank portraits: per-record bank (attr bit 3). bank0 (committed metadata)
        # records read tiles2 / objidx2; the rest read the bank-1 sheet. Single-bank
        # metasprites leave bank0 empty -> every record uses `bank` (the block default).
        b0set = set(bank0 or [])
        OBJI = lambda i: objidx2 if i in b0set else objidx
        BLNK = lambda i: blank_obj2 if i in b0set else blank_obj
        # the metasprite is a complete row-major grid of 8x16 cells; EVERY cell is a
        # record, including ones drawn with a blank (all-transparent) tile -- the
        # original tool padded the grid rather than pruning blank cells.
        cells = []                                              # (cr, cc, vals, opaque)
        tcand: list = []         # candidate even tiles per cell: exact VALUE match
        P: list = []             # record palette, explicit in the indexed source
        for cr in range(0, H, 16):
            for cc in range(0, W, 8):
                ci = len(cells)
                blk = [px[cc + c, cr + r] for r in range(16) for c in range(8)]
                v = tuple(q % 4 for q in blk)
                opaque = any(v)
                P.append(cell_pal(blk, "meta"))
                cells.append((cr, cc, v, opaque))
                ts = set(OBJI(ci).get(v, ())) if opaque else set()
                tcand.append(sorted(t for t in ts if t < 256))  # OBJ tile index is a byte
        # TILE: pin the unique-candidate cells. Tiles run +2 in record order along a
        # "base diagonal" (byte = base0 + 2*i, base0 = the common (tile-2*i)); animated
        # frames allocate a fresh CONTIGUOUS run for the changed cells, which can pixel-
        # duplicate a base tile (image-irreducible). Resolve an ambiguous cell by an
        # adjacent OFF-diagonal pinned neighbour (it belongs to that override run),
        # else the base diagonal. Blank cells carry no pixels: tile = (next opaque) - 2.
        pinned = [c[3] and len(tc) == 1 for c, tc in zip(cells, tcand)]
        tile: list = [tcand[i][0] if pinned[i] else None for i in range(len(cells))]
        bcnt = Counter((tile[i] - 2 * i) % 256 for i in range(len(cells)) if pinned[i])
        base0 = bcnt.most_common(1)[0][0] if bcnt else 0
        # Override-run rectangles: an animation frame reallocates a contiguous rectangle
        # of changed cells as one fresh +2 run, row-major over the rectangle. Because the
        # rectangle spans multiple grid rows, its lower rows are NOT record-adjacent to a
        # pinned off-diagonal cell, so the per-cell anchoring below can't reach them (it
        # would pick the pixel-twin base-diagonal tile). Seed each run from its pinned
        # off-diagonal cells (the top row), then fill the rectangle's still-ambiguous
        # cells by row-major rank.
        grows = H // 16
        offdiag = sorted((i for i in range(len(cells))
                          if pinned[i] and tile[i] != (base0 + 2 * i) % 256),
                         key=lambda i: tile[i])
        groups: list = []                                       # consecutive +2 tile runs
        for i in offdiag:
            if groups and tile[i] == (tile[groups[-1][-1]] + 2) % 256:
                groups[-1].append(i)
            else:
                groups.append([i])
        for grp in groups:
            start = min(grp, key=lambda g: tile[g])          # lowest tile = rectangle top-left
            rtop, c0, run_base = start // cols, start % cols, tile[start]
            width = 1                                         # extend right while the next cell
            while c0 + width < cols:                          # admits the next +2 run tile (the
                i = rtop * cols + (c0 + width)                # top-row cells may be ambiguous, so
                val = (run_base + 2 * width) % 256            # use candidates, not pinned status)
                if val in tcand[i] and tile[i] in (None, val):
                    width += 1
                else:
                    break
            for rr in range(rtop, grows):                     # fill the rectangle row-major +2
                progressed = False
                for k in range(width):
                    i = rr * cols + (c0 + k)
                    val = (run_base + 2 * ((rr - rtop) * width + k)) % 256
                    if tile[i] is None and val in tcand[i]:
                        tile[i] = val
                        progressed = True
                    elif tile[i] == val:
                        progressed = True
                if not progressed:
                    break
        for i, (c, ts) in enumerate(zip(cells, tcand)):
            if tile[i] is not None or not c[3]:
                continue
            anchored = [(tile[j] + (2 if j < i else -2)) % 256
                        for j in (i - 1, i + 1)
                        if 0 <= j < len(cells) and pinned[j] and tile[j] != (base0 + 2 * j) % 256]
            be = (base0 + 2 * i) % 256
            want = [a for a in anchored if a in ts] + ([be] if be in ts else []) + ts
            tile[i] = want[0] if want else None   # no sheet tile carries these values
            # (a hand-edited cel); left for the `idx` closure pin.
        for i in range(len(cells) - 1, -1, -1):                 # blank cells: next opaque - 2
            if tile[i] is None and i + 1 < len(cells) and tile[i + 1] is not None:
                tile[i] = (tile[i + 1] - 2) & 0xFF
        for i in range(len(cells)):                             # trailing blanks: prev + 2
            if tile[i] is None:
                tile[i] = (tile[i - 1] + 2) & 0xFF if i else 0
        # a transparent cell's tile must itself be blank; where the run lands on an
        # OPAQUE tile the tool instead reused a shared blank tile (the lowest one it had
        # allocated, else the lowest in the sheet).
        used = [tile[i] for i, c in enumerate(cells)
                if not c[3] and tile[i] is not None and tile[i] in BLNK(i)]
        for i, c in enumerate(cells):
            if not c[3] and (tile[i] is None or tile[i] not in BLNK(i)):
                bl = BLNK(i)
                same = [t for t in used if t in bl]
                tile[i] = (Counter(same).most_common(1)[0][0] if same
                           else (bl[0] if bl else 0))
        # image-irreducible metasprite tile (a fresh run the +2/override model mispredicts,
        # e.g. Mistral's wing run): pinned per-record via the manifest `idx` map.
        for rec, tval in (idx_over or {}).items():
            tile[int(rec)] = tval
        out = bytearray([len(cells)])
        for i, ((cr, cc, v, opaque), t, p) in enumerate(zip(cells, tile, P)):
            b = 0 if i in b0set else bank
            out += bytes(((oy + cr) & 0xFF, (ox + cc) & 0xFF, t, (b << 3) | p))
        return bytes(out)

    man = yaml.safe_load(Path(manifest_path).read_text())
    base = man["base"] if isinstance(man["base"], int) else int(str(man["base"]), 0)
    d = Path(manifest_path).parent
    out = bytearray()
    addr = base
    for blk in man["blocks"]:
        bank = blk.get("bank", 1)
        img = Image.open(d / blk["png"])
        if img.mode != "P":
            raise SystemExit(f"{blk['png']}: cel PNGs must be indexed "
                             "(pixel = display_palette*4 + 2bpp value)")
        if blk["kind"] == "patch":
            data = gen_patch(img, addr, bank, blk.get("idx"), blk.get("bank0"))
        else:
            data = gen_meta(img, blk.get("oy", 0), blk.get("ox", 0), bank,
                            blk.get("idx"), blk.get("bank0"))
        out += data
        addr += len(data)
    return bytes(out)


def gen_sprite_region_asm(manifest_path, tiles, tiles2=None):
    """The same region as gen_sprite_region, emitted as structured .asm: one label per
    block (`<prefix>_<role>`), `metasprite`/`obj` for OBJ lists and a CopyBgMap descriptor
    struct for patches, so code can reference the blocks by label instead of raw address.
    The manifest must carry a `prefix:`. Byte-identical to the .bin once the host SECTION
    is at the manifest's `base` (patch pointers become `dw`-relative -> relocatable).
    Returns asm text; the host file INCLUDEs it inside the overlay's SECTION."""
    import yaml
    man = yaml.safe_load(Path(manifest_path).read_text())
    prefix = man["prefix"]
    data = gen_sprite_region(manifest_path, tiles, tiles2)
    out = ["; Generated by tools/pngasset.py from the layered PNG source -- do not edit.",
           '; (INCLUDEd into the overlay SECTION; see docs/metasprites.md / portrait_overlays.md.)',
           'INCLUDE "metasprite.inc"', ""]

    def dbs(bs):
        return [f"\tdb " + ", ".join(f"${x:02x}" for x in bs[k:k+16]) for k in range(0, len(bs), 16)]

    p = 0
    for blk in man["blocks"]:
        lab = f"{prefix}_{blk['role']}"
        if blk["kind"] == "meta":
            count = data[p]
            out.append(f"\tmetasprite {lab}")
            for i in range(count):
                r = data[p+1+4*i:p+5+4*i]
                out.append(f"\t\tobj ${r[0]:02x}, ${r[1]:02x}, ${r[2]:02x}, ${r[3]:02x}")
            out.append(f"\tend_metasprite {lab}")
            p += 1 + 4 * count
        else:                                                    # patch (CopyBgMap descriptor)
            rows, cols = data[p], data[p+1]
            nn = rows * cols
            out += [f"{lab}:", f"\tdb {rows}, {cols}", "\tdw .attr", "\tdw .idx", ".idx:"]
            out += dbs(data[p+6:p+6+nn])
            out.append(".attr:")
            out += dbs(data[p+6+nn:p+6+2*nn])
            p += 6 + 2 * nn
        out.append("")
    return "\n".join(out) + "\n"


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
    if getattr(args, "map", None):
        # the arrangement is a Tiled source file (one layer pair per screen,
        # possibly one tileset per sheet) -- see docs/asset_source_model.md.
        tmap, amap = tmx_layer_to_map(d / args.map, args.map_layer)
        comps += [("tilemap", tmap), ("attrmap", amap)]
    elif getattr(args, "layout", None):
        # derive the maps from the layout constant + the indexed sheet (and the
        # composed reference for blank-collapse layouts) instead of committing
        # tilemap.bin/attrmap.bin. See docs/asset_source_model.md (family G).
        bb = int(args.blank_byte, 0) if getattr(args, "blank_byte", None) else None
        mo = {int(k, 0): int(v, 0)
              for k, v in (tok.split(":") for tok in
                           (getattr(args, "map_overrides", "") or "").split(";") if tok)}
        tmap, amap = derive_portrait_maps(
            png, args.layout, bb,
            d / args.reference if getattr(args, "reference", None) else None, mo)
        comps += [("tilemap", tmap), ("attrmap", amap)]
    else:
        comps += [
            ("tilemap", (d / "tilemap.bin").read_bytes()),
            ("attrmap", (d / "attrmap.bin").read_bytes()),
        ]
    sprites_asm = None
    if getattr(args, "sprites", None):
        # regenerate the metasprite/patch data region from the layered source manifest.
        # With a `prefix:` in the manifest, emit structured sprites.asm (labelled blocks)
        # instead of sprites.bin so code can reference the blocks by label.
        tiles2 = next((data for name, data in comps if name == "tiles2"), None)
        import yaml
        man = yaml.safe_load((d / args.sprites).read_text())
        if man.get("prefix"):
            sprites_asm = gen_sprite_region_asm(d / args.sprites, comps[0][1], tiles2)
        else:
            comps.append(("sprites", gen_sprite_region(d / args.sprites, comps[0][1],
                                                        tiles2)))
    if getattr(args, "palettes2_png", None):
        # a second palette set (e.g. an alternate scene) carried by its own indexed PNG:
        # BG palettes lead its colour table, OBJ palettes follow (same as the sheet).
        _w2, _h2, _px2, colors2 = read_indexed_png(d / args.palettes2_png)

        def pack2(first: int, n: int) -> bytes:
            out = bytearray()
            for i in range(first, first + n * 4):
                word = rgb888_to_555(*colors2[i])
                out += bytes((word & 0xFF, (word >> 8) & 0xFF))
            return bytes(out)

        comps.append(("palette_bg2", pack2(0, args.palettes_bg)))
        comps.append(("palette_obj2", pack2(args.palettes_bg * 4, args.palettes_obj)))
    out = Path(args.out_dir)
    out.mkdir(parents=True, exist_ok=True)
    for name, data in comps:
        (out / f"{name}.bin").write_bytes(data)
        print(f"  {name}.bin: {len(data)} bytes")
    if sprites_asm is not None:
        (out / "sprites.asm").write_text(sprites_asm)
        print(f"  sprites.asm: {sprites_asm.count(chr(10))} lines")
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
    sc.add_argument("--map", default=None,
                    help="Tiled .tmx (next to --png) carrying the arrangement; "
                         "compiled to tilemap/attrmap instead of reading the bins")
    sc.set_defaults(fn=cmd_screen)

    ml = sub.add_parser(
        "maplib", help="screen-library bank: sheet PNG + palettes + N Tiled maps"
    )
    ml.add_argument("--png", required=True, help="indexed sheet (16 tiles/row)")
    ml.add_argument("--out-dir", required=True)
    ml.add_argument("--tiles", type=int, required=True, help="total sheet tiles")
    ml.add_argument("--banks", type=int, default=1,
                    help="2 = stacked VRAM banks; 1 = single bank / alternate sets")
    ml.add_argument("--base", type=int, default=0,
                    help="VRAM tile number of sheet index 0 (0=$8000, 128=$8800)")
    ml.add_argument("--palettes", type=int, default=0, help="CGB palettes in the PNG table")
    ml.add_argument("--maps", default="", help="comma-separated .tmx files next to --png")
    ml.set_defaults(fn=cmd_maplib)

    scn = sub.add_parser(
        "scene", help="summon-animation tiles: one tile-sheet PNG -> tiles/palette .bin "
                      "(+ descriptors/metasprites passthrough)"
    )
    scn.add_argument("--png", required=True,
                     help="combined indexed sheet (both banks stacked, palettes embedded); "
                          "descriptors.bin/metasprites.bin live next to it")
    scn.add_argument("--out-dir", required=True)
    scn.add_argument("--tiles", type=int, default=384, help="tiles per bank")
    scn.add_argument("--palettes", type=int, default=16, help="palettes in the PNG table")
    scn.add_argument("--frames", default=None,
                    help="Tiled .tmx (next to --png) of CopyBgMap animation frames, "
                         "one layer pair per frame -> frameNN_idx/attr.bin")
    scn.set_defaults(fn=cmd_scene)

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
    pt.add_argument("--layout", default=None, choices=sorted(PORTRAIT_LAYOUTS),
                    help="derive tilemap/attrmap from this allocator layout + the "
                         "indexed sheet, instead of committing the map bins")
    pt.add_argument("--blank-byte", default=None,
                    help="layouts that collapse blank cells to a shared blank tile "
                         "(e.g. 0x80); needs --reference for which cells are blank")
    pt.add_argument("--reference", default=None,
                    help="composed 11x20 indexed reference PNG (next to --png), "
                         "for --blank-byte layouts")
    pt.add_argument("--map", default=None,
                    help="Tiled .tmx (relative to --png) carrying the arrangement; "
                         "compiled with --map-layer instead of a layout/bins")
    pt.add_argument("--map-layer", default=None,
                    help="layer name in --map (its _pal twin carries palettes)")
    pt.add_argument("--map-overrides", default="",
                    help="'cell:byte;cell:byte' tilemap pins for blank-cell/"
                         "blank-slot ties the rule can't decide")
    pt.add_argument("--sprites", default=None,
                    help="metasprite/patch manifest (next to --png); regenerates the "
                         "OBJ/BG overlay data region into sprites.bin")
    pt.add_argument("--palettes2-png", default=None,
                    help="second indexed PNG (next to --png) whose colour table holds a "
                         "second BG+OBJ palette set (e.g. an alternate scene); split into "
                         "palette_bg2.bin / palette_obj2.bin")
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
