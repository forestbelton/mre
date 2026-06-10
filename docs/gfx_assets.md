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
- `portrait --png <sheet.png> --tiles1 N --tiles0 M --palettes-bg 6 --palettes-obj 6
  --out-dir D` → `tiles.bin` (the `--tiles1` bank-1 tiles), `tiles2.bin` (the
  `--tiles0` bank-0 tiles, when set), `palette_bg.bin` / `palette_obj.bin` (the
  `--palettes-bg/-obj` palettes, split off the PNG table), plus the committed
  `tilemap.bin`/`attrmap.bin` passed through. The character-portrait sheet holds
  the bank-1 tiles first, then any bank-0 tiles; the 6 BG + 6 OBJ palettes lead
  the PNG table and each tile shows in its colour (`tile value = pixel % 4`).
- `decode --tiles --tilemap --palette(.pal) --cols --rows --out p.png` →
  composite PNG (bootstraps the source from existing component bins).

Every graphics asset is PNG-driven through this one tool (the old multi-file
`assets/<name>/asset.json` + `tools/gfxasset.py` flow has been removed).

## Layout: `assets/` mirrors `src/gfx/`

The asset tree is laid out to parallel the asm tree, so `assets/screen/town/`
sits next to `src/gfx/screen/town.asm`:

```
assets/logo/logo.png              src/gfx/logo.asm
assets/intro/intro.png            src/gfx/intro.asm
assets/screen/<name>/<name>.png   src/gfx/screen/<name>.asm   (town, tower,
                                    tower_open, room_start, room_done, title)
assets/portrait/<name>/<name>.png src/gfx/portrait/<name>.asm (kalum, …; nada.asm
                                    drives nada_intro/ + nada_scene2/)
```

Each leaf dir holds the editable `<name>.png` plus the committed `tilemap.bin` /
`attrmap.bin` (the arrangement). The build writes ROM components to
`build/assets/<name>/`, which the asm `INCBIN`s.

## Descriptor: `assets/assets.yaml` + `tools/buildassets.py`

One YAML lists every asset; `tools/buildassets.py` (the single entry point the
Makefile calls) runs `pngasset.py` per entry. **Adding an asset is a YAML edit,
not a Makefile change.** The output dir is derived from the PNG's parent dir name
(`assets/screen/town/town.png` → `build/assets/town`), which the asm `INCBIN`s.

```yaml
logo:
  mode: composite          # one self-contained image; tool derives tiles + tilemap
  png: logo/logo.png
  sheet_rows: 8
  pad_before: [0, 4096]    # blank-tile VRAM block before the sheet
town:
  mode: screen             # two-bank colour screen; one combined tile-sheet PNG
  png: screen/town/town.png
```

`mode: composite` opts: `sheet_rows`, `pad_before [byte, n]`, `colors`.
`mode: screen` opts: `tiles` (per bank, default 384).
`mode: portrait` opts: `tiles1` (bank 1, default 384), `tiles0` (bank 0, default 0
= single-bank). All 18 assets now live in this file — the logo (composite), the 7
two-bank colour screens, and the 10 portraits.

## Migrated: the town screen (sheet mode — two-bank + colour exemplar)

`src/gfx/screen/town.asm` was the first bank-`$30` screen taken off the
auto-generated inline-`db` extract dump onto pngasset. Editable source is **one
image** — `assets/screen/town/town.png` (both banks stacked, all 16 palettes
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

## Migrated: the portraits (portrait mode)

The 10 character portraits followed onto `mode: portrait`. Each is one colour
tile-sheet PNG — `assets/portrait/<name>/<name>.png`, bank-1 tiles first then any bank-0
tiles, with the 6 BG + 6 OBJ palettes embedded — plus the committed
`tilemap.bin`/`attrmap.bin`. Single-bank portraits (kalum, toamuna, rafaga,
tempest, naji, pashute, bodka, nada_scene2) emit only `tiles.bin`; the two-bank
ones (ferious `tiles0: 128`, nada_intro `tiles0: 384`) also emit `tiles2.bin`.

**Colour (`palettes_bg: 6`, `palettes_obj: 6`):** each portrait's draw routine
copies 6 BG + 6 OBJ palettes (`$30` each) from ROM *adjacent to its tile sheet*
into `wBgPalettes`/`wObjPalettes` (e.g. Kalum_StartEncounter reads `$1d:$5800`/
`$5840`) — they were never lib-dispatched, just unlabelled data. They are carved
out of `analyzed.asm` into each portrait asset (`<Name>PortraitPaletteBg` /
`PaletteObj` → palette_bg.bin / palette_obj.bin), so the portraits carry real
colour. nada_scene2 reuses nada_intro's `$1c:$7000` palette, so it is colourised
for editing but owns no palette bytes. See docs/palettes.md for the located map.

**Derived maps (pashute):** rather than commit pashute's opaque `tilemap.bin`/
`attrmap.bin`, the BG layer is committed as a *rendered reference image*
(`reference.png`) and the build re-derives both maps from it byte-exact
(`--reference --rows --cols --bank`). The tilemap is positional (column-major
within bands, `$8800`-signed) and inferred from the unambiguous cells; the attrmap
palette is recovered per cell and spread by 8-neighbour consensus. See
`derive_portrait_maps` in tools/pngasset.py.

**Layered overlay region (pashute):** the data immediately after pashute's attrmap
(`$5a3e-$5bdc`) is the portrait's animation overlay — eyes blink frames plus
shoulders/collar and sad/shocked faces — a run of two block kinds: BG **patch**
descriptors (`CopyBgMap` sub-tilemaps, `BankMapCopyA` → `$9885`) and OBJ
**metasprite** lists (`DrawMetasprite`). Rather than a `db` blob, this is committed
as *layered source*: one PNG per block under `assets/portrait/pashute/sprites/` plus
`sprites.yaml` (ordered blocks, roles, and metasprite placement origin). The build
regenerates the whole region byte-exact (`--sprites`; patch tile indices follow the
same column-major model, OBJ tiles matched 8×16 under the consensus palette). Block
roles were traced from the bank-`$18` render functions (Pashute_RenderPortrait*).
The trailing 64 bytes (`$5bdd-$5c1c`, intro-scene data) remain a `db`. This is the
template for migrating the other portraits' overlay regions — **pashute, kalum, naji,
toamuna done; see [portrait_overlays.md](portrait_overlays.md)** for the full
procedure, the structural heuristics, and how to edit pngasset/buildassets.

## Migrated: the TECMO logo (composite mode)

`assets/logo/logo.png` (160×144 indexed) is the only committed source; the build
regenerates tiles/palette/tilemap/attrmap. The byte-exact tile-ordering heuristic:
blank tile = all-color-0; find the bounding box of non-blank cells; build the
sheet **column-major** over the bbox, padding each column to `--sheet-rows` tiles
with blanks; tile index = `content_col*sheet_rows + content_row` (no dedup);
tilemap is positional (background → the first blank tile); `--pad-before` prepends
the `$1000` blank-tile VRAM block. This works because **every logo tile is visible
in the composite**.

## Asset survey (18 captured assets)

A one-time survey of the 18 captured assets, measuring dimensions, addressing,
tile-bank layout, attribute-map usage, palette, and how many sheet tiles are
unreferenced.

| Family | Count | Members | Shared shape |
|---|---|---|---|
| Composite | 1 | logo | `direct`, 1 palette, 128 tiles, attr **all-zero**, 1 bank |
| Single-bank portraits | 7 | kalum, toamuna, rafaga, tempest, naji, pashute, bodka | 11×20, `8800`, 384 tiles, attr = per-cell pal 0-5 + bank3=1 |
| Two-bank portraits | 3 | ferious, nada_intro, nada_scene2 | 11×20, `8800`, 384 + 2nd sheet, attr bit3 selects bank |
| Two-bank screens | 7 | town, tower_entrance, room_start, room_clear, tower_entrance_open, title_screen, intro_book | 18×20 (intro 10×20), `8800`, 384+384, attr bit3 bank-select, some xflip |

### What's common

**17 of 18 share one archetype:** `8800` addressing, 384-tile sheet(s), a real
attribute map, and **non-blank "invisible" tiles the tilemap never references**
(mouth-animation/overlay frames drawn by other descriptors). (At survey time their
palettes were thought "not located" → recorded as grayscale; they have since all
been located and carved, so every asset now carries colour.) Only the logo is the
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
