#!/usr/bin/env python3
"""gfxasset — a small "rgbgfx for this game".

Monster Rancher Explorer draws full-screen images (the TECMO logo, the title
screen, cutscene frames) from a handful of separate ROM components that share a
common shape:

  * tile data    — 2bpp tiles ($10 bytes each), uploaded to VRAM tile data.
  * palette      — CGB palettes, 4 RGB555 colors each ($08 bytes/palette).
  * map descriptor — `db rows, cols / dw attrPtr / dw idxPtr`: the dimensions
                     and the bank-local addresses of the two maps below.
  * tile index map — rows*cols bytes, one tile number per BG cell.
  * attribute map  — rows*cols CGB BG attributes (palette / VRAM bank / flips).

Off-the-shelf rgbgfx doesn't speak this layout (the descriptor, our palette
packing, the $8800 index addressing), so this is our own codec. It round-trips
each component byte-for-byte and also bakes a *composite* PNG — the assembled,
full-color image — for viewing.

The components are the editable source of truth; `preview.png` is a generated
preview (gitignored, not source). See docs/philosophy.md.

Commands:
    gfxasset.py decode --rom rom.gbc --asset tecmo_logo --out src/gfx/tecmo_logo/
    gfxasset.py verify --rom rom.gbc --in  src/gfx/tecmo_logo/
    gfxasset.py encode --in src/gfx/tecmo_logo/ --out-dir <dir>   # write component bytes

Decode writes (into --out): tiles.png, palette.pal, tilemap.bin, attrmap.bin,
asset.json (layout metadata), and preview.png (the composite). encode/verify
reproduce the exact component bytes from those source files.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

BANK_SIZE = 0x4000
TILE_BYTES = 0x10        # 2bpp: 16 bytes per 8x8 tile
PAL_BYTES = 0x08         # one CGB palette: 4 colors * RGB555 (2 bytes)

# Built-in asset specs. addr fields are flat ROM file offsets; `bank` is the
# ROMX bank the descriptor's pointers are relative to. Everything else (the two
# map addresses, rows, cols) is read from the descriptor at decode time.
ASSETS = {
    # First thing drawn at boot: the red-on-white TECMO logo (fades in/out).
    # Rendered by DrawTecmoLogo (bank $30 $5418). Tiles land at VRAM $9000
    # ($8800 index addressing), one BG palette, VRAM bank 0. See
    # docs/gfx_extraction.md.
    "tecmo_logo": {
        "bank": 0x27,
        "tiles_addr": 0x9D000,
        "tiles_count": 128,
        "palette_addr": 0x9D800,
        "palette_count": 1,
        "desc_addr": 0x9D808,
        # tiles_addr already points at the VRAM $9000 tiles, and all indices are
        # < $80, so the tile number is the index directly.
        "index_base": 0,
        "addressing": "direct",
    },
    # Kalum's encounter portrait (tower NPC). Drawn by Kalum_StartEncounter
    # ($1f:$417b): tiles loaded $1d:$4000 +0x1800 to VRAM bank 1 $8000 ($8000
    # index addressing), arranged by the CopyBgMap descriptor at $1d:$5880 over
    # the top 20x11 cells. Uses 6 BG palettes whose ROM source is lib-dispatched
    # (not yet located) — so palette_count 0 = grayscale composite for now;
    # tiles/tilemap still round-trip byte-exact.
    "kalum_portrait": {
        "bank": 0x1d,
        "tiles_addr": 0x74000,
        "tiles_count": 384,
        "palette_addr": None,
        "palette_count": 0,
        "desc_addr": 0x75880,
        "index_base": 0,
        # $8800 signed addressing with the sheet based at VRAM $8000 (tiles_addr):
        # index >=$80 -> tile=index; index <$80 -> tile=index+$100 (the $9000 set).
        "addressing": "8800",
    },
    # Toamuna's portrait (ranch save NPC; shown by her "what do you want to do?"
    # menu). Same descriptor layout as Kalum (20x11, tiles at $1a:$4000 -> VRAM
    # bank 1 $8000, $8800 addressing), one bank further along at $1a. Found by
    # following her script's far-calls (tools/find_portraits.py).
    "toamuna_portrait": {
        "bank": 0x1a,
        "tiles_addr": 0x68000,    # $1a:$4000
        "tiles_count": 384,
        "palette_addr": None,
        "palette_count": 0,
        "desc_addr": 0x69880,     # $1a:$5880
        "index_base": 0,
        "addressing": "8800",
    },
    # More tower-NPC encounter portraits, all the same 20x11 single-blob Kalum
    # layout, located via tools/find_portraits.py from each NPC's script far-calls.
    "rafaga_portrait": {
        "bank": 0x1d, "tiles_addr": 0x75b19, "tiles_count": 384,
        "palette_addr": None, "palette_count": 0,
        "desc_addr": 0x77399, "index_base": 0, "addressing": "8800",
    },
    "tempest_portrait": {
        "bank": 0x1e, "tiles_addr": 0x79be7, "tiles_count": 384,
        "palette_addr": None, "palette_count": 0,
        "desc_addr": 0x7b467, "index_base": 0, "addressing": "8800",
    },
    "naji_portrait": {
        "bank": 0x1a, "tiles_addr": 0x69ae8, "tiles_count": 384,
        "palette_addr": None, "palette_count": 0,
        "desc_addr": 0x6b368, "index_base": 0, "addressing": "8800",
    },
    "pashute_portrait": {
        "bank": 0x1b, "tiles_addr": 0x6c000, "tiles_count": 384,
        "palette_addr": None, "palette_count": 0,
        "desc_addr": 0x6d880, "index_base": 0, "addressing": "8800",
    },
    # Ferious, the monster Mistral summons ("Ferious! Come!"). A two-VRAM-bank
    # CGB portrait: the loader (Func_1f_4416) copies $35:$4800 (384t) to VRAM
    # bank 1 $8000 and $35:$4000 (128t) to VRAM bank 0 $9000; the attr map's bit 3
    # selects the bank per cell. Found via tools/find_portraits.py.
    "ferious_portrait": {
        "bank": 0x35,
        "tiles_addr": 0xd4800, "tiles_count": 384,    # $35:$4800 -> VRAM bank 1 $8000
        "tiles2_addr": 0xd4000, "tiles2_count": 128,  # $35:$4000 -> VRAM bank 0 $9000
        "palette_addr": None, "palette_count": 0,
        "desc_addr": 0xd6080, "index_base": 0, "addressing": "8800",
    },
    # Nada's intro scene (shown by Func_1f_4d97). Two-bank, but unlike Ferious
    # both sheets load to VRAM $8000 (different VBK): $1c:$4000 (bank 0) and
    # $1c:$5800 (bank 1); attr bit 3 picks per cell. Located via find_portraits.
    "nada_intro": {
        "bank": 0x1c,
        "tiles_addr": 0x71800, "tiles_count": 384,    # $1c:$5800 -> VRAM bank 1 $8000
        "tiles2_addr": 0x70000, "tiles2_count": 384,  # $1c:$4000 -> VRAM bank 0 $8000
        "tiles2_vram": 0x8000,
        "palette_addr": None, "palette_count": 0,
        "desc_addr": 0x73080, "index_base": 0, "addressing": "8800",
    },
    # Bodka's portrait (the older man in Nada's dialogue; the $1e:$5bd9 2x2
    # descriptor elsewhere is a mouth-animation overlay). Single-blob Kalum layout,
    # tiles $1e:$4000, descriptor $1e:$5880.
    "bodka_portrait": {
        "bank": 0x1e,
        "tiles_addr": 0x78000, "tiles_count": 384,   # $1e:$4000
        "palette_addr": None, "palette_count": 0,
        "desc_addr": 0x79880, "index_base": 0, "addressing": "8800",
    },
    # Nada's second pose (shown by Func_1f_4e65). Two-bank like the intro and
    # *reuses the intro's $1c:$4000 sheet* as its bank-0 half (tiles2_ref), so this
    # asset owns only the bank-1 sheet $1f:$6607 + descriptor/maps at $1f:$7e07.
    "nada_scene2": {
        "bank": 0x1f,
        "tiles_addr": 0x7e607, "tiles_count": 384,    # $1f:$6607 -> VRAM bank 1 $8000
        "tiles2_addr": 0x70000, "tiles2_count": 384,  # $1c:$4000 -> VRAM bank 0 $8000 (shared)
        "tiles2_vram": 0x8000, "tiles2_ref": "nada_intro",
        "palette_addr": None, "palette_count": 0,
        "desc_addr": 0x7fe07, "index_base": 0, "addressing": "8800",
    },
}

# Grayscale ramp for palette-less assets (composite + tile sheet).
GRAY = [(0xFF, 0xFF, 0xFF), (0xAA, 0xAA, 0xAA), (0x55, 0x55, 0x55), (0x00, 0x00, 0x00)]


# ---------------------------------------------------------------------------
# 2bpp tile codec (our own — reads/writes pixel *indices*, so it is immune to
# the duplicate-color limitation that bites rgbgfx).
# ---------------------------------------------------------------------------

def tile_to_indices(tile: bytes) -> list[list[int]]:
    """16-byte 2bpp tile -> 8x8 of pixel indices 0..3. Row = lo-plane byte then
    hi-plane byte; bit 7 is the leftmost pixel; value = lo | (hi << 1)."""
    rows = []
    for r in range(8):
        lo, hi = tile[r * 2], tile[r * 2 + 1]
        rows.append([((lo >> (7 - c)) & 1) | (((hi >> (7 - c)) & 1) << 1)
                     for c in range(8)])
    return rows


def indices_to_tile(px: list[list[int]]) -> bytes:
    """Inverse of tile_to_indices: 8x8 indices -> 16-byte 2bpp tile."""
    out = bytearray()
    for r in range(8):
        lo = hi = 0
        for c in range(8):
            v = px[r][c] & 3
            lo |= (v & 1) << (7 - c)
            hi |= ((v >> 1) & 1) << (7 - c)
        out += bytes((lo, hi))
    return bytes(out)


# ---------------------------------------------------------------------------
# RGB555 <-> 8-bit (lossless for the stored 5-bit value)
# ---------------------------------------------------------------------------

def rgb555_to_rgb888(word: int) -> tuple[int, int, int]:
    r, g, b = word & 31, (word >> 5) & 31, (word >> 10) & 31
    expand = lambda v: (v << 3) | (v >> 2)
    return expand(r), expand(g), expand(b)


def rgb888_to_rgb555(rgb: tuple[int, int, int]) -> int:
    r, g, b = (c >> 3 for c in rgb)
    return (r & 31) | ((g & 31) << 5) | ((b & 31) << 10)


# ---------------------------------------------------------------------------
# Palette file (.pal): one CGB palette per line, 4 space-separated RGB555 hex
# words, with a trailing comment showing the colors. Human-editable.
# ---------------------------------------------------------------------------

def read_palettes(rom: bytes, addr: int, count: int) -> list[list[int]]:
    pals = []
    for p in range(count):
        base = addr + p * PAL_BYTES
        pals.append([rom[base + 2 * k] | (rom[base + 2 * k + 1] << 8)
                     for k in range(4)])
    return pals


def palettes_to_bytes(pals: list[list[int]]) -> bytes:
    out = bytearray()
    for pal in pals:
        for word in pal:
            out += bytes((word & 0xFF, (word >> 8) & 0xFF))
    return bytes(out)


def write_pal_file(path: Path, pals: list[list[int]]) -> None:
    lines = ["; CGB palettes — 4 RGB555 words each (little-endian in ROM).",
             "; Edit the hex words; the trailing comment is just the RGB.", ""]
    for i, pal in enumerate(pals):
        words = " ".join(f"{w:04x}" for w in pal)
        rgb = " ".join("(%2d,%2d,%2d)" % rgb555_to_rgb888(w) for w in pal)
        lines.append(f"{words}   ; pal {i}: {rgb}")
    path.write_text("\n".join(lines) + "\n")


def read_pal_file(path: Path) -> list[list[int]]:
    pals = []
    for line in path.read_text().splitlines():
        line = line.split(";", 1)[0].strip()
        if not line:
            continue
        words = [int(tok, 16) for tok in line.split()]
        if len(words) != 4:
            raise ValueError(f"{path}: each palette line needs 4 words, got {len(words)}")
        pals.append(words)
    return pals


# ---------------------------------------------------------------------------
# Descriptor: db rows, cols / dw attrPtr / dw idxPtr  (bank-local pointers)
# ---------------------------------------------------------------------------

def read_descriptor(rom: bytes, desc_addr: int, bank: int) -> dict:
    rows = rom[desc_addr]
    cols = rom[desc_addr + 1]
    attr_ptr = rom[desc_addr + 2] | (rom[desc_addr + 3] << 8)
    idx_ptr = rom[desc_addr + 4] | (rom[desc_addr + 5] << 8)
    to_file = lambda p: bank * BANK_SIZE + (p - BANK_SIZE)
    return {
        "rows": rows, "cols": cols,
        "attr_ptr": attr_ptr, "idx_ptr": idx_ptr,
        "attr_addr": to_file(attr_ptr), "idx_addr": to_file(idx_ptr),
    }


def descriptor_to_bytes(rows: int, cols: int, attr_ptr: int, idx_ptr: int) -> bytes:
    return bytes((rows, cols,
                  attr_ptr & 0xFF, (attr_ptr >> 8) & 0xFF,
                  idx_ptr & 0xFF, (idx_ptr >> 8) & 0xFF))


# ---------------------------------------------------------------------------
# Indexed PNG read/write (mode 'P'); we read pixel indices directly so colors
# are irrelevant to the round-trip.
# ---------------------------------------------------------------------------

def write_indexed_png(path: Path, width: int, height: int,
                      pixels: bytes, palette_rgb: list[tuple[int, int, int]]) -> None:
    from PIL import Image
    img = Image.frombytes("P", (width, height), bytes(pixels))
    flat: list[int] = []
    for rgb in palette_rgb:
        flat += list(rgb)
    flat += [0, 0, 0] * (256 - len(palette_rgb))
    img.putpalette(flat)
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path)


def read_indexed_png(path: Path) -> tuple[int, int, bytes]:
    from PIL import Image
    img = Image.open(path)
    if img.mode != "P":
        img = img.convert("P")
    w, h = img.size
    return w, h, img.tobytes()


# ---------------------------------------------------------------------------
# Tile sheet PNG (all tiles laid out `sheet_w` tiles per row)
# ---------------------------------------------------------------------------

SHEET_W = 16  # tiles per row in the editable tile sheet


def tiles_to_sheet_png(path: Path, tiles: list[bytes], pal_rgb: list[tuple[int, int, int]]) -> None:
    n = len(tiles)
    rows_t = (n + SHEET_W - 1) // SHEET_W
    W, H = SHEET_W * 8, rows_t * 8
    px = bytearray(W * H)
    for t, tile in enumerate(tiles):
        bx, by = (t % SHEET_W) * 8, (t // SHEET_W) * 8
        ind = tile_to_indices(tile)
        for r in range(8):
            for c in range(8):
                px[(by + r) * W + (bx + c)] = ind[r][c]
    write_indexed_png(path, W, H, bytes(px), pal_rgb)


def sheet_png_to_tiles(path: Path, count: int) -> list[bytes]:
    W, H, px = read_indexed_png(path)
    tiles = []
    for t in range(count):
        bx, by = (t % SHEET_W) * 8, (t // SHEET_W) * 8
        grid = [[px[(by + r) * W + (bx + c)] for c in range(8)] for r in range(8)]
        tiles.append(indices_to_tile(grid))
    return tiles


# ---------------------------------------------------------------------------
# Composite render: tiles + index map + attr map + palettes -> full-color PNG
# ---------------------------------------------------------------------------

def map_index_to_tile(v: int, index_base: int, addressing: str) -> int:
    """Map a BG tilemap index to a tile number in the sheet, per the LCDC
    tile-data addressing mode. "8800" is signed addressing with the sheet
    based at VRAM $8000 (index >=$80 -> index; <$80 -> index+$100, the $9000
    half); "direct" is index - index_base."""
    if addressing == "8800":
        return v if v >= 0x80 else v + 0x100
    return (v - index_base) & 0xFF


def render_composite(path: Path, rows: int, cols: int, idx: bytes, attr: bytes,
                     tiles: list[bytes], pals: list[list[int]], index_base: int,
                     addressing: str = "direct", tiles2: list[bytes] | None = None,
                     tiles2_vram: int = 0x9000) -> None:
    W, H = cols * 8, rows * 8
    grayscale = not pals
    # Build a 256-color RGB palette from the CGB palettes (palette p, color k
    # -> PNG index p*4 + k). Cells reference it via their attr palette bits.
    # With no palettes (source not yet located), fall back to a gray ramp and
    # ignore the per-cell palette selector.
    pal_rgb: list[tuple[int, int, int]] = list(GRAY) if grayscale else []
    for pal in pals:
        pal_rgb += [rgb555_to_rgb888(w) for w in pal]
    px = bytearray(W * H)
    for cell in range(rows * cols):
        ty, tx = divmod(cell, cols)
        v = idx[cell]
        a = attr[cell]
        pal_no = 0 if grayscale else (a & 0x07)
        xflip, yflip = (a >> 5) & 1, (a >> 6) & 1
        # CGB BG attribute bit 3 selects the VRAM tile bank. With a second sheet
        # (bank 0) present, bit-3-clear cells read from it; a sheet based at VRAM
        # `base` maps an $8800 index to tile (0x9000-base)//16 + signed(index)
        # (so base $9000 -> signed(index), base $8000 -> same as the primary).
        if tiles2 is not None and not (a >> 3) & 1:
            tile_no = (0x9000 - tiles2_vram) // 0x10 + (v if v < 0x80 else v - 0x100)
            sheet = tiles2
        else:
            tile_no = map_index_to_tile(v, index_base, addressing)
            sheet = tiles
        ind = tile_to_indices(sheet[tile_no]) if 0 <= tile_no < len(sheet) else [[0] * 8] * 8
        for r in range(8):
            sr = 7 - r if yflip else r
            for c in range(8):
                sc = 7 - c if xflip else c
                px[(ty * 8 + r) * W + (tx * 8 + c)] = pal_no * 4 + ind[sr][sc]
    write_indexed_png(path, W, H, bytes(px), pal_rgb)


# ---------------------------------------------------------------------------
# decode / encode / verify
# ---------------------------------------------------------------------------

def resolve_spec(args) -> dict:
    if args.asset:
        if args.asset not in ASSETS:
            raise SystemExit(f"unknown asset {args.asset!r}; known: {sorted(ASSETS)}")
        return dict(ASSETS[args.asset])
    raise SystemExit("specify --asset")


def cmd_decode(args) -> int:
    rom = Path(args.rom).read_bytes()
    spec = resolve_spec(args)
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)

    desc = read_descriptor(rom, spec["desc_addr"], spec["bank"])
    rows, cols = desc["rows"], desc["cols"]
    n_cells = rows * cols

    def read_tiles(addr, count):
        return [rom[addr + t * TILE_BYTES: addr + (t + 1) * TILE_BYTES] for t in range(count)]
    tiles = read_tiles(spec["tiles_addr"], spec["tiles_count"])
    # Optional second tile blob: a CGB portrait that also loads VRAM bank 0
    # ($9000) tiles, selected per-cell by attr bit 3 (e.g. Mistral's Ferious).
    tiles2 = read_tiles(spec["tiles2_addr"], spec["tiles2_count"]) if spec.get("tiles2_addr") else None
    pals = (read_palettes(rom, spec["palette_addr"], spec["palette_count"])
            if spec["palette_count"] else [])
    idx = rom[desc["idx_addr"]: desc["idx_addr"] + n_cells]
    attr = rom[desc["attr_addr"]: desc["attr_addr"] + n_cells]

    pal_rgb = [rgb555_to_rgb888(w) for w in pals[0]] if pals else list(GRAY)
    tiles_to_sheet_png(out / "tiles.png", tiles, pal_rgb)
    # When the bank-0 sheet is shared with another asset (tiles2_ref), we read it
    # from the ROM only to render this composite -- it isn't owned/carved/emitted
    # here (the other asset's section already provides those ROM bytes).
    if tiles2 is not None and not spec.get("tiles2_ref"):
        tiles_to_sheet_png(out / "tiles_bank0.png", tiles2, pal_rgb)
    if pals:
        write_pal_file(out / "palette.pal", pals)
    (out / "tilemap.bin").write_bytes(idx)
    (out / "attrmap.bin").write_bytes(attr)

    name = args.asset
    # preview.png is a *generated* composite (not source) — gitignored.
    render_composite(out / "preview.png", rows, cols, idx, attr, tiles, pals,
                     spec["index_base"], spec.get("addressing", "direct"), tiles2,
                     spec.get("tiles2_vram", 0x9000))

    meta = {
        "asset": name,
        "bank": spec["bank"],
        "rows": rows, "cols": cols,
        "tiles_count": spec["tiles_count"],
        "palette_count": spec["palette_count"],
        "index_base": spec["index_base"],
        "addressing": spec.get("addressing", "direct"),
        # ROM offsets + the descriptor's bank-local pointers (kept so encode can
        # reproduce the descriptor's dw bytes exactly).
        "tiles_addr": spec["tiles_addr"],
        "palette_addr": spec["palette_addr"],
        "desc_addr": spec["desc_addr"],
        "attr_ptr": desc["attr_ptr"], "idx_ptr": desc["idx_ptr"],
        "attr_addr": desc["attr_addr"], "idx_addr": desc["idx_addr"],
    }
    if tiles2 is not None:
        meta["tiles2_addr"] = spec["tiles2_addr"]
        meta["tiles2_count"] = spec["tiles2_count"]
        meta["tiles2_vram"] = spec.get("tiles2_vram", 0x9000)
        if spec.get("tiles2_ref"):
            meta["tiles2_ref"] = spec["tiles2_ref"]  # owning asset of the shared sheet
    (out / "asset.json").write_text(json.dumps(meta, indent=2) + "\n")

    print(f"decoded {name}: {cols}x{rows} cells, {spec['tiles_count']} tiles, "
          f"{spec['palette_count']} palette(s)" + (" [grayscale]" if not pals else ""))
    comp = "tiles.png, tilemap.bin, attrmap.bin" + (", palette.pal" if pals else "")
    print(f"  components -> {out}/  ({comp})")
    print(f"  composite  -> {out / 'preview.png'}  (generated preview)")
    return 0


def encode_components(src: Path) -> dict[str, bytes]:
    """Reproduce each ROM component's bytes from the source files. Returns a
    dict component -> bytes, plus the asset.json metadata under key '_meta'."""
    meta = json.loads((src / "asset.json").read_text())
    tiles = sheet_png_to_tiles(src / "tiles.png", meta["tiles_count"])
    pals = read_pal_file(src / "palette.pal") if (src / "palette.pal").exists() else []
    idx = (src / "tilemap.bin").read_bytes()
    attr = (src / "attrmap.bin").read_bytes()
    comps = {
        "_meta": meta,
        "tiles": b"".join(tiles),
        "palette": palettes_to_bytes(pals),
        "descriptor": descriptor_to_bytes(meta["rows"], meta["cols"],
                                           meta["attr_ptr"], meta["idx_ptr"]),
        "tilemap": idx,
        "attrmap": attr,
    }
    # A shared (tiles2_ref) bank-0 sheet isn't owned here, so it's not a component
    # this asset reproduces/verifies; it's pulled from the owning asset for preview.
    if meta.get("tiles2_count") and not meta.get("tiles2_ref"):
        comps["tiles2"] = b"".join(sheet_png_to_tiles(src / "tiles_bank0.png", meta["tiles2_count"]))
    return comps


def cmd_encode(args) -> int:
    comps = encode_components(Path(args.input))
    out = Path(args.out_dir)
    out.mkdir(parents=True, exist_ok=True)
    keys = ["tiles", "palette", "descriptor", "tilemap", "attrmap"]
    if "tiles2" in comps:
        keys.append("tiles2")
    for key in keys:
        (out / f"{key}.bin").write_bytes(comps[key])
        print(f"  {key}.bin: {len(comps[key])} bytes")
    return 0


def cmd_preview(args) -> int:
    """Render the composite PNG from the *source* files (no ROM needed) — for
    refreshing the preview after editing the components."""
    src = Path(args.input)
    comps = encode_components(src)
    meta = comps["_meta"]
    tiles_blob = comps["tiles"]
    tiles = [tiles_blob[i:i + TILE_BYTES] for i in range(0, len(tiles_blob), TILE_BYTES)]
    pals = read_pal_file(src / "palette.pal") if (src / "palette.pal").exists() else []
    out = Path(args.out)
    tiles2 = None
    if meta.get("tiles2_count"):
        if meta.get("tiles2_ref"):
            # shared bank-0 sheet: read it from the owning sibling asset
            tiles2 = sheet_png_to_tiles(src.parent / meta["tiles2_ref"] / "tiles_bank0.png",
                                        meta["tiles2_count"])
        else:
            t2 = comps["tiles2"]
            tiles2 = [t2[i:i + TILE_BYTES] for i in range(0, len(t2), TILE_BYTES)]
    render_composite(out, meta["rows"], meta["cols"], comps["tilemap"],
                     comps["attrmap"], tiles, pals, meta["index_base"],
                     meta.get("addressing", "direct"), tiles2,
                     meta.get("tiles2_vram", 0x9000))
    print(f"preview -> {out}")
    return 0


def cmd_verify(args) -> int:
    rom = Path(args.rom).read_bytes()
    comps = encode_components(Path(args.input))
    meta = comps["_meta"]
    # (component, ROM file offset)
    regions = [
        ("tiles", meta["tiles_addr"]),
        ("descriptor", meta["desc_addr"]),
        ("tilemap", meta["idx_addr"]),
        ("attrmap", meta["attr_addr"]),
    ]
    if meta.get("tiles2_count") and not meta.get("tiles2_ref"):
        regions.append(("tiles2", meta["tiles2_addr"]))
    if meta.get("palette_count") and meta.get("palette_addr") is not None:
        regions.insert(1, ("palette", meta["palette_addr"]))
    ok = True
    for name, addr in regions:
        data = comps[name]
        rom_slice = rom[addr: addr + len(data)]
        match = data == rom_slice
        ok = ok and match
        status = "OK " if match else "MISMATCH"
        print(f"  [{status}] {name:10s} @ 0x{addr:06x} +{len(data):4d}")
        if not match:
            for i in range(len(data)):
                if data[i] != rom_slice[i]:
                    print(f"      first diff at +{i}: src {data[i]:#04x} != rom {rom_slice[i]:#04x}")
                    break
    print("verify: OK — all components byte-exact" if ok else "verify: FAIL")
    return 0 if ok else 1


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    sub = p.add_subparsers(dest="cmd", required=True)

    d = sub.add_parser("decode", help="ROM -> editable source components + composite PNG")
    d.add_argument("--rom", required=True)
    d.add_argument("--asset", required=True, help=f"one of: {sorted(ASSETS)}")
    d.add_argument("--out", required=True, help="output dir for the source files")
    d.set_defaults(fn=cmd_decode)

    e = sub.add_parser("encode", help="source components -> raw component .bin files")
    e.add_argument("--in", dest="input", required=True)
    e.add_argument("--out-dir", required=True)
    e.set_defaults(fn=cmd_encode)

    v = sub.add_parser("verify", help="encode source and compare to ROM (byte-exact check)")
    v.add_argument("--rom", required=True)
    v.add_argument("--in", dest="input", required=True)
    v.set_defaults(fn=cmd_verify)

    pv = sub.add_parser("preview", help="render the composite PNG from source files (no ROM)")
    pv.add_argument("--in", dest="input", required=True)
    pv.add_argument("--out", required=True, help="output PNG path")
    pv.set_defaults(fn=cmd_preview)

    args = p.parse_args(argv)
    return args.fn(args)


if __name__ == "__main__":
    sys.exit(main())
