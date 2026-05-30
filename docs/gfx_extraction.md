# Graphics extraction — plan & handoff

Status as of 2026-05-29. Goal #2 work: turn mapped "data" regions that are
actually graphics into real source (PNGs round-tripped through `rgbgfx`),
driven by runtime VRAM-write provenance rather than visual guessing.

## The approach (decided)

Work **backwards from VRAM writes**: the analyzer watches what the game copies
into VRAM and records the ROM source. This gives runtime ground truth for:

- **tiledata** ($8000–$97FF) = pixel data. Covers BOTH sprite tiles and
  background tiles (sprites vs BG is an OAM/attribute distinction, not a
  tiledata/tilemap one — sprite *pixels* are tiledata too).
- **tilemap** ($9800–$9FFF) = background layout (tile indices; on CGB, bank 1
  holds per-cell attributes in the same address range).
- **uncompressed** (source in ROM) vs **decompressed** (source in WRAM ⇒ the
  ROM blob is compressed; leave as data for now).

Only **verbatim** copies (`rom[src] == value_written`) are marked, so map.json
will only ever receive *definite* ROM sources. Transformed copies (e.g. tilemap
tile-indices written with a base offset) and computed/RAM writes are counted in
the report but NOT marked — they need human review / a later offset-aware pass.

## What's built (committed: 82b70a4)

`tools/analyzer/analyzer.c` → **`--watch-vram [PATH]`**:
- HDMA path: hooks `$FF55`, reads src/dest/len from HDMA1–4 registers.
- CPU path: `last_data_read` tracks the most-recent non-fetch ROM data read;
  each VRAM write is credited to it iff verbatim, then the source is consumed.
- On exit: coalesces marked bytes into contiguous runs, prints a report
  (tiledata/tilemap/mixed, run >= 16 bytes), plus summary counters. Reports
  to stderr or the PATH arg. **Does not modify map.json.**
- SIGINT/SIGTERM → graceful shutdown (so `timeout --signal=INT` works headless).

### Finding: this game uses CPU copy loops, not HDMA
HDMA byte counts are 0 in traces. The CPU read-provenance + verbatim gate does
the work and is precise: an 18s boot trace gave 27 KB of runs, **0 noise, 0
verbatim rejections**. Identified tiledata runs render as clean graphics — the
in-game font + sprites at `0x0A4000`, a logo at `0x09C000`, sprite sheet at
`0x0A8000`. These line up exactly with the big "data" blocks in map.json.

## How to capture a real session (THIS is the blocker)

Runtime coverage only marks graphics actually drawn on screen. Boot touched
27 KB of ~328 KB of data. A full play session is needed:

```
make analyzer
tools/analyzer/analyzer --rom rom.gbc --map map.json --watch-vram /tmp/vram.log
```

Play widely: battles, menus, ranch, every dungeon floor, monster encyclopedia,
shops, cutscenes — anything that draws new art. Double-tap ESC to quit. The
report appends to `/tmp/vram.log`.

NOTE: the analyzer also merges code/data coverage into `--map` every 10s. That's
desirable for a real session (accumulates coverage). For throwaway smoke tests
use a copy: `cp map.json /tmp/m.json` and `--map /tmp/m.json --no-save`. Always
`--no-save` in tests so rom.gbc.sav isn't clobbered (see memory feedback note).

## Next steps (Stage 2 + 3)

**Stage 2 — fold the runs into map.json as `gfx` sections.**
- Decision pending (ask user): have the analyzer write `gfx` regions directly,
  or keep `--watch-vram` report-only and add a separate tool that ingests the
  report after review. Leaning report-only for tilemaps (lower confidence),
  auto for large verbatim tiledata runs.
- A `gfx` section needs: `type:"gfx"`, `addr`, `len` (multiple of 16), `label`,
  and a `width` (tiles/row, default 16). len should be width*16*rows; if not, we
  pad the PNG and slice on INCBIN (below).
- Coalescing note: adjacent runs separated by tiny gaps may be one image split
  by partial draws; merging heuristics may help. Runs are bank-local already.

**Stage 3 — extractor + build (round-trip PROVEN byte-exact).**
- `tools/extract.py`: add `gfx` to SECTION_TYPES / DATA_LIKE_TYPES (coverage
  kind = data). For a gfx section, decode bytes → **indexed** PNG into
  `src/gfx/<label>.png`; emit `INCBIN "gfx/<label>.2bpp", 0, <len>` in the asm.
- `Makefile`: add a rule to build `%.2bpp` from `%.png` via rgbgfx, and make the
  ROM target depend on the generated `.2bpp` files. Gitignore `*.2bpp`.
- `make verify` must still produce the exact sha256
  (8f66b5972bf76ed15985815ccdecc459fab9e84221454139b05d1d6654b69e7a).

### Proven encode recipe (byte-exact, verified)
2bpp = 16 bytes/tile, 8x8, row = 2 bytes (lo plane, hi plane), bit7 = leftmost
pixel, value = lo_bit | (hi_bit << 1). Encode to an **indexed** PNG whose
palette index == the 2bpp value (4 grays, any colors as long as index order is
0,1,2,3), then:

```
rgbgfx -c embedded -o out.2bpp in.png      # -c embedded uses the PNG palette order as-is
```

rgbgfx pads the final partial tile-row, so its output can be longer than the
ROM region. Handle by slicing in the asm: `INCBIN "gfx/x.2bpp", 0, <len>`
(rgbasm supports the start,len form). The first `len` bytes are byte-identical
to the ROM. A 16-wide PNG is fine and human-viewable regardless of the real
in-game tile width (linear tile order is width-independent when fully packed).

Tooling present: `rgbgfx v1.0.1`, PIL, ImageMagick. Reference decoder used for
the scratch validation is straightforward (see git history / regenerate).

## Palettes (added — captured in the same trace)

The analyzer also captures palette info, since color is part of "the right
image" even though it never enters the assembly.

- **Palette data writes** to the CGB ports ($FF69 BGPD / $FF6B OBPD) are hooked
  with the same verbatim-from-ROM provenance (VSRC_PALETTE bit).
- **Finding:** in this game palettes are written from a **WRAM buffer**, not
  straight from ROM (palette `marked: 0`; the bytes show up in "not from ROM").
  So the palette *ROM table* needs a second-order trace (ROM→WRAM→port).
  **Decision (user): defer locating palette ROM addresses.** We color tiles
  from the live palette registers instead, and drop palette from the asm.
- **Tile↔palette cross-reference** (the link only exists at *draw* time):
  - `vram_byte_src[0x4000]` remembers which ROM offset loaded each VRAM byte.
  - Each frame, `scan_tile_palette_associations()` walks the BG/window tilemaps
    (attribute byte bits 0-2 = BG palette) and OAM (attr bits 0-2 = OBJ palette),
    follows each on-screen tile slot back to its ROM source, and ORs the palette
    bit into `rom_bg_pal[]` / `rom_obj_pal[]`.
  - The report shows per region e.g. `bg{0,1,2,3}` (the font region) or `bg{0}`.
  - Palette colors are snapshotted (first-use) into `bg_pal_colors`/`obj_pal_colors`
    and printed as RGB555. **Caveat:** "first-use" can catch a palette before its
    real colors are loaded (saw white pals at boot). TODO: snapshot at draw-time
    keyed per region, or last-use, for accurate region colors.

### CRITICAL round-trip rule: force the palette with `-c`, colors must be DISTINCT
rgbgfx ALWAYS maps input pixels by **color**, never by stored PNG index (man:
`-c embedded` errors "if colors other than these 4 are used"; `dmg` "same gray
shade cannot go in two color indexes"). So the round-trip is byte-exact iff the
4 colors are distinct — verified:

| PNG colors fed to rgbgfx | round-trip |
|---|---|
| real palette, 4 distinct | exact |
| real palette w/ duplicates (e.g. all-white) | FAILS (indices collapse) |
| 4 distinct sentinel grays | exact |

**Use the inline `-c` form to force the palette explicitly** (deterministic,
doesn't depend on PNG PLTE order) — verified byte-exact with real colors:

```
rgbgfx -c "#5abdc5,#83a400,#393939,#0883ac" -o x.2bpp x.png   # colors = 2bpp values 0..3
```

So we CAN keep real colors (render the PNG in the captured palette, pass those
same colors to `-c`) and still rebuild exactly — as long as the 4 are distinct.
When a real palette has duplicate colors: nudge a dup by 1 LSB (imperceptible,
restores distinctness) or fall back to sentinel grays. Either way the asm
INCBINs only the 2bpp bytes; palette never enters the assembly.

## Caveats / open questions
- Tilemaps written with a tile-index base offset are NOT verbatim → currently
  unmarked. A later pass could detect a constant offset (value - rom[src]) and
  mark + record the offset.
- CGB attribute maps (VRAM bank 1, $9800–$9FFF) are lumped under "tilemap" by
  dest address; fine for provenance, but the eventual source form differs.
- Sprite metasprite assembly (which tiles form one creature, OAM layout) is RAM
  state, not in scope for ROM gfx extraction — we only extract the tile pixels.
- ~32% of the ROM is padding and ~31% is still uncovered (goal #1); the gfx work
  also incidentally improves map quality by reclassifying data → gfx.
