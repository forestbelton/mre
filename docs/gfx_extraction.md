# Graphics extraction — plan & handoff

Status as of 2026-05-30. Goal #2 work: turn mapped "data" regions that are
actually graphics into real source (PNGs round-tripped through `rgbgfx`),
driven by runtime VRAM-write provenance rather than visual guessing.

**Stages 1–3 are complete and byte-exact** (analyzer marks gfx → extract emits
PNG + INCBIN → build rebuilds the exact ROM). What remains is purely *coverage*:
capture wider play sessions so more of the ~328 KB of data gets traced and
reclassified data → gfx (see "How to capture a real session" below).

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

## How to capture a real session (the remaining coverage work)

Runtime coverage only marks graphics actually drawn on screen. A boot trace
touches ~31 KB of ~328 KB of data (the title logo, font, and intro sprites). A
full play session is needed to reach the rest:

```
make analyzer
tools/analyzer/analyzer --rom rom.gbc --map map.json --watch-vram /tmp/vram.log
```

Play widely: battles, menus, ranch, every dungeon floor, monster encyclopedia,
shops, cutscenes — anything that draws new art. Double-tap ESC to quit. The
report appends to `/tmp/vram.log`.

NOTE: the analyzer **merges** code/data coverage into `--map` every 10s (it
never deletes). For a real session that accumulates coverage. For a smoke test
the trace's coverage is almost always already a subset of the committed map, so
pointing `--map map.json` straight at the real file is effectively a no-op — no
need to copy it to `/tmp` first. Likewise `--no-save` is unnecessary for these
traces: `rom.gbc.sav` is only written on an actual in-game save (`GB_save_battery`),
which a boot/smoke trace never reaches. Reserve `--no-save` for sessions where
you actually save in-game and don't want to overwrite the user's `.sav`.

## Next steps (Stage 2 + 3)

**Stage 2 — fold the runs into map.json as `gfx` sections. DONE.**
- The analyzer auto-promotes contiguous **verbatim tiledata** runs (whole
  16-byte tiles, >= `GFX_MIN_BYTES` = 0x40) to `type:"gfx"` sections in the
  `analyzed.asm` entry on every map.json save. Tilemaps/other stay `data`
  (report-only), per the agreed confidence split.
- Persistence: a `gfx` byte is tracked in `is_gfx[]`, set both from the live
  trace and when **loading** existing `gfx` sections from map.json, so the
  classification survives later `analyze` runs that don't use `--watch-vram`.
- `extract.py` accepts `gfx` (coverage = data) and currently emits it as `db`
  bytes, so `make verify` stays byte-exact. Verified end-to-end: trace →
  gfx sections in map → extract → assemble → identical sha256.
- A `gfx` section may later gain an optional `width` (tiles/row, default 16)
  for the PNG arrangement; len is already a multiple of 16.
- **No `palette` field is needed** (verified). 2bpp tile data IS pixel indices
  (0-3); color is applied at runtime by the tilemap/OAM attribute. So the
  build renders every gfx region to a PNG with ONE fixed distinct sentinel
  palette and `rgbgfx -c "#ffffff,#aaaaaa,#555555,#000000"` recovers the exact
  bytes — region colors are irrelevant to the round-trip (one Makefile rule
  fits all). A `palette` field would also be ambiguous: the same tiles are
  drawn with multiple palettes (font region = bg{0,1,2,3}). Real colors are
  only wanted for a *colored preview*; that's optional, many-to-one sidecar
  metadata sourced from the --watch-vram report, never needed by the asm.
- Coalescing note: adjacent runs separated by tiny gaps may be one image split
  by partial draws; merging heuristics may help. Runs are bank-local already.

**Stage 3 — extractor + build (round-trip byte-exact). DONE.**
- `tools/extract.py`: `gfx` is in SECTION_TYPES / DATA_LIKE_TYPES (coverage
  kind = data). `_build_section_lines` decodes a gfx section → **indexed** PNG
  (`gfx_to_indexed_png`, sentinel grays, palette index == 2bpp value) into
  `src/gfx/<label>.png` and emits `INCBIN "gfx/<label>.2bpp", 0, <len>`. The
  filename/label is the section's start label. gfx is INCBIN-like for label
  assignment (owner `gfx-section`): only the section start can carry a label,
  same as a `.bin`/string span — interior refs fall back to raw hex.
  An optional per-section `width` (tiles/row, default 16) sets the PNG layout.
- `Makefile`: the ROM target builds every `src/gfx/*.png` → `.2bpp` with
  `rgbgfx -c embedded` before assembling. `src/gfx/` is gitignored (generated
  from ROM by extract, like the `.bin` gap files).
- **Verified end-to-end:** a boot trace folded 4 real gfx sections (logo
  `0x9c000`, font `0xa4000` = `bg{0,1,2,3}`, sprites `0xa8000`/`0xa9410`) into
  map.json; `make verify` rebuilds the exact sha256
  (8f66b5972bf76ed15985815ccdecc459fab9e84221454139b05d1d6654b69e7a) and the
  font PNG renders as the legible Latin+kana glyph sheet. Unit test
  `TestGfxSections` covers the rgbgfx round-trip + INCBIN emission.

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
The asm INCBINs only the 2bpp bytes; palette never enters the assembly.

**Duplicate-color palettes (decision):** rgbgfx can't encode these at all
(color→index is lossy), and we will NOT distort colors to work around it.
- **For now:** the extractor/build must **error** if a gfx region's palette has
  duplicate colors, naming the region — don't silently mis-encode.
- **Later:** write our own tiny PNG→2bpp encoder for these regions (trivial:
  read an indexed PNG, emit 2 bitplane bytes per row straight from the pixel
  indices — no color matching, so duplicates are a non-issue). The 2bpp format
  is 16 bytes/tile, row = lo-plane byte then hi-plane byte, bit7 = leftmost
  pixel. Once that exists, route duplicate-palette regions through it instead
  of rgbgfx and drop the error.

## Worked example: the TECMO logo (first thing drawn at boot)

The intro sequence is TECMO logo (fade in/out) → opening cutscene → title
screen. The TECMO logo is a CGB full-screen image and the first concrete use of
the gfx pipeline on a real asset.

- **Graphic:** `TecmoLogoGfx` at file offset **`0x9C000`** = ROM bank `$27`
  (`0x27·0x4000`), uploaded through the CPU's ROMX window at `$4000`. NB: the
  `9C000` is a *file offset*, unrelated to the VRAM `$9C00` window-tilemap
  address — different address space. `0x3000` bytes = two `$1800` tile planes
  (this image needs >384 tiles, so it spans both CGB VRAM banks). Extracts to
  `src/gfx/TecmoLogoGfx.png`.
- **Renderer:** `DrawTecmoLogo` (bank `$30`, `$5418` = `0xC1418`):
  - `CopyBytesBanked` ×2 — tile plane 0 → VRAM bank 0 `$8000`, plane 1 → VRAM
    bank 1 `$8000` (`ld hl,$4000`/`$5800`, both bank `$27`).
  - `CopyBgMapBanked` — BG tilemap + CGB attribute map from `$5808` (bank `$27`)
    → `$9800` (a 2-byte dimension header precedes the data).
  - `LoadPalettesBanked` — BG (`$c201`) and OBJ (`$c241`) palette buffers from
    bank `$27` (palettes reach hardware from these WRAM buffers, which is why
    `--watch-vram` couldn't trace palette writes back to ROM — see above).
  - **Fade loop** (`TecmoLogo_FadeLoop`): each frame `ReadJoypad`, then bump the
    fade level `$d0fe` until `$b4` (~180 frames ≈ 3 s); a button press (`$ff8d`)
    skips to `TecmoLogo_Done`. The per-frame palette update dims by `$d0fe`.
- **Dispatch:** `RunIntroScene` (`$0f58`) indexes `IntroSceneTable` (`$0f71`,
  3 bytes/entry `{bank,lo,hi}`) by the intro state `$c2a7`; the TECMO entry →
  `IntroScene_TecmoLogo` (`$3580`) which banks in `$30` and calls `DrawTecmoLogo`.
- The tile blob is kept whole (one `gfx` section) because that's exactly what
  the two-plane upload copies and it round-trips byte-exact; the tilemap/palette
  live packed inside the same bank and are *not* split out as separate sections
  (a label can't sit mid-INCBIN). Confirmed first-drawn empirically: a ~30 s
  boot `--watch-vram` trace marked bank `$27` (this logo) but never reached the
  bank `$28` cutscene/title art.

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
