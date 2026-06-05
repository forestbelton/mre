# Graphics assets — PNG-driven pipeline & asset survey

Goal (see docs/philosophy.md): a screen's editable source should be an image, and
the build regenerates the ROM bytes from it byte-exact. This doc covers the tool,
the first migration (the TECMO logo), and a survey of every currently-captured
asset so we know what to abstract over. **Not yet decided / deferred:** a unified
YAML-driven generator (one metadata file + one script) — more assets still need
to be located before committing to a schema.

## Tool: `tools/pngasset.py`

Regenerates a screen's components from a source PNG.

- `encode --png … --sheet-rows N --pad-before BYTE N --out-dir D` → `tiles.bin`,
  `palette.bin`, `tilemap.bin`, `attrmap.bin` (composite mode; the logo).
- `screen --png <sheet.png> --out-dir D` → `tiles_bank0.bin`, `tiles_bank1.bin`,
  `palette.bin`, and passes `tilemap.bin`/`attrmap.bin` (next to the PNG) through.
  **Sheet mode** for the two-VRAM-bank colour screens: ONE indexed PNG holds both
  banks stacked (top half → VRAM bank 0, bottom → bank 1) and all 16 CGB palettes
  (8 BG + 8 OBJ) in its palette table; each tile is shown in its real palette
  (`pixel = palette*4 + 2bpp value`, so the tile value is `pixel % 4`). No packer —
  the tile order lives in the committed tilemap.
- `decode --tiles --tilemap --palette(.pal) --cols --rows --out p.png` →
  composite PNG (bootstraps the source from existing component bins).

The legacy multi-file flow (`assets/<name>/asset.json` + `tools/gfxasset.py`) is
still used by everything except the logo and the town screen.

## Migrated: the town screen (sheet mode — two-bank + colour exemplar)

`src/gfx/screen/town.asm` was the first bank-`$30` screen taken off the
auto-generated inline-`db` extract dump onto pngasset. Editable source is **one
image** — `assets/town_screen/town.png` (both banks stacked, all 16 palettes
embedded, each tile in its real colour) — plus the committed `tilemap.bin` /
`attrmap.bin` (the arrangement). The build splits the PNG into the two banks +
palette, the asm `INCBIN`s the bins, and the map descriptor references the maps by
label (`dw`). The CGB palettes (`$20:$7000`, 8 BG + 8 OBJ) were carved out of
`analyzed.asm` into the asset, so the screen now carries real colour. Byte-exact.

**Why not a single screenshot?** A screen's full tile data can't come from a
composite: 402 of town's 768 tiles are off-screen (animation/scroll/sprite frames
the game draws at runtime), so they appear in no screenshot — but byte-exact needs
them. Hence the source is a tile *sheet* (which holds every tile), not a rendered
screen, and the arbitrary tile order/arrangement stays in the committed maps. This
is the exemplar for the remaining six screens (and the eventual YAML schema):
`mode: sheet`, one combined PNG (two banks + 16 palettes), maps committed.

## Migrated: the TECMO logo (composite mode)

`assets/logo.png` (160×144 indexed) is the only committed source; the build
regenerates tiles/palette/tilemap/attrmap. The byte-exact tile-ordering heuristic:
blank tile = all-color-0; find the bounding box of non-blank cells; build the
sheet **column-major** over the bbox, padding each column to `--sheet-rows` tiles
with blanks; tile index = `content_col*sheet_rows + content_row` (no dedup);
tilemap is positional (background → the first blank tile); `--pad-before` prepends
the `$1000` blank-tile VRAM block. This works because **every logo tile is visible
in the composite**.

## Asset survey (18 captured assets)

From `scratch/asset_survey.py` over `gfxasset.ASSETS`, measuring dimensions,
addressing, tile-bank layout, attribute-map usage, palette, and how many sheet
tiles are unreferenced.

| Family | Count | Members | Shared shape |
|---|---|---|---|
| Composite | 1 | tecmo_logo | `direct`, 1 palette, 128 tiles, attr **all-zero**, 1 bank |
| Single-bank portraits | 7 | kalum, toamuna, rafaga, tempest, naji, pashute, bodka | 11×20, `8800`, 384 tiles, attr = per-cell pal 0-5 + bank3=1 |
| Two-bank portraits | 3 | ferious, nada_intro, nada_scene2 | 11×20, `8800`, 384 + 2nd sheet, attr bit3 selects bank |
| Two-bank screens | 7 | town, tower_entrance, room_start, room_clear, tower_entrance_open, title_screen, intro_book | 18×20 (intro 10×20), `8800`, 384+384, attr bit3 bank-select, some xflip |

### What's common

**17 of 18 share one archetype:** `8800` addressing, 384-tile sheet(s), grayscale
(real palettes are lib-dispatched and not yet located → `palette_count 0`), a real
attribute map, and **non-blank "invisible" tiles the tilemap never references**
(mouth-animation/overlay frames drawn by other descriptors). Only the logo is the
composite outlier (every tile visible, attr all-zero, has a palette).

### Key insight — two modes; packing is a non-problem

- A composite PNG only works when every tile is visible — i.e. **the logo alone**.
  The other 17 need the source PNG to be the **tile sheet itself** (it holds the
  invisible tiles too).
- For sheet-mode the tile data is a plain contiguous blob, so **PNG-grid → tiles.bin
  is a trivial 2bpp dump** and the (arbitrary) tile packing simply stays in the
  committed tilemap — there is no packer to reverse-engineer. (kalum's bottom-3-rows
  packing into leftover slots looked hard only under the composite assumption.)
- So the real abstraction is **`mode: sheet` (the common case) vs `mode: composite`
  (logo)**. The only sheet-mode structural variable is **1 vs 2 tile banks**
  (`tiles2`, selected per cell by attr bit 3). Flips (xflip on 6 screens) and
  per-cell palettes are already just bytes in the committed attrmap — they ride
  along, nothing to abstract.

### Suggested order (when we act)

1. Add a `sheet` mode to `pngasset` (PNG grid → `tiles.bin`, optional `tiles2`) —
   unlocks 17/18 at once.
2. Convert the **two-bank screen family (7)** first (most uniform; exercises dual
   sheets + bank-select attr), then the single-bank portraits (7), then the rest.
3. A YAML schema falls out: defaults = the 17-asset norm (`mode: sheet`,
   `addressing: 8800`, `palettes: 0`, committed `tilemap`/`attrmap`); the logo
   overrides with `mode: composite`, `direct`, `palettes: 1`, `pad_before`.

Open question (non-blocking): whether `tilemap`/`attrmap` stay committed binaries
or move to a more editable text form. They're small and not derivable, so
committing them is fine to start.

**Caveat:** many graphics regions are still *not* captured under `assets/` (see
docs/gfx_catalog.md). Gather more before locking the YAML schema.
