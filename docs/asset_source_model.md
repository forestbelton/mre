# Asset source model — unifying the graphics pipeline (PROPOSAL)

Status: **proposal, 2026-06-11** — not yet implemented. This is the design for
bringing every graphics asset under one umbrella, replacing the committed
`tilemap.bin`/`attrmap.bin` pairs and the per-portrait `sprites.yaml` pin
special-cases with source forms that are (a) derivable by algorithm wherever the
bytes actually were machine-generated, and (b) honestly *editable source* where
they were hand-authored. Evidence below; decisions pending at the end.

## The problem (why pngasset isn't the end state)

`tools/pngasset.py` round-trips byte-exact, but:

1. **Maps are committed, not derived** — 17 `tilemap.bin`+`attrmap.bin` pairs
   (11 portraits, intro, 6 screens) and 15 scene `descriptors.bin`/
   `metasprites.bin` are opaque binaries pretending to be source.
2. **Pinned special cases** — 46 override entries across the portrait
   `sprites.yaml` manifests (18 `idx`, 15 `pal`, 13 `pal_cells`) plus 13
   `bank0` maps, plus one-off mechanisms (`reference.png` for pashute only,
   `palettes2`, `intro_pals.png`).
3. **It doesn't resemble the original dev tree** — no developer authored a
   `tilemap.bin`; they drew pictures and placed tiles in a map editor.

## The key finding: there were TWO original toolchains

Measured on the committed assets (`scratch/packer_probe.py`,
`scratch/map_derive_test.py`, `scratch/invisible_bits.py`, 2026-06-11):

### Family G — machine-generated from composed art

| evidence (portraits, logo) | value |
|---|---|
| tilemap across 5 single-bank portraits | **byte-identical** (positional constant, column-major bands, no dedup) |
| flip bits in 7 portrait attrmaps | **0** of 1540 cells |
| attrmap content | per-cell palette only (+ constant bank bit) |
| logo | bbox column-major, positional, every tile visible |

The maps are a **pure function of the composed picture** (given the allocation
profile). The original tool was a converter: picture in, tiles+map+attrs out.
`derive_portrait_maps` (pashute) already re-derives one byte-exact.

### Family A — hand-authored tilemaps

| evidence (the 6 two-bank screens) | value |
|---|---|
| flip bits set on flip-symmetric tiles (invisible in ANY rendered image) | 2–29 cells per screen (e.g. town alternates xflip on pixel-identical wall tiles — an artist's texture pattern) |
| cells whose rendered pixels are reachable via >1 sheet tile | 51–241 per screen (the ROM picks non-lowest, non-local duplicates) |
| naive derive-from-picture (unique + lowest-index rule) | only ~67% of cells; **provably cannot reach 100%** (the flip bits above carry no pixel evidence) |
| sheet allocation order vs map scan order | non-monotonic (sheet accretes from multiple sources; 2/3 of tiles are off-screen animation/UI frames) |
| flip-aware dedup | real: every flipped cell reuses an unflipped tile |

The map contains **information that is not in the picture**. These tilemaps
were placed by hand (a GBMB-style map editor) against a separately-drawn tile
sheet. Deriving them from a composed PNG is impossible, full stop — and forcing
it would be *less* like the original tree, not more. The scene-frame
descriptors (the golem derisk's "~72% irreducible cells") sit in this family
too.

**Consequence:** one source form for everything is the wrong goal. The umbrella
is one *model* with two map provenances:

## The model

Every graphics asset = **palettes + tile art + placements**, built by one
compiler from one manifest schema. Three component kinds:

### 1. `art` — indexed PNGs (the universal pixel convention)
Every committed image uses the convention the sheet PNGs already use:
**pixel = display_palette × 4 + 2bpp value**, real colours in the PNG palette
table. This makes per-cell/per-sprite palette **explicit instead of inferred**
— which is where most pins came from (an RGBA sprite whose colours exist in
several palettes is ambiguous; an indexed one never is). Applies to: tile
sheets (already done), composed pictures, overlay cel PNGs (currently RGB/RGBA
— migrating them kills all 28 `pal`/`pal_cells` pins mechanically).

### 2. maps — derived (family G) or authored (family A)
- **G: composed picture is source; maps are generated.** The compiler
  implements the reconstructed allocation profiles as *forward* algorithms:
  `positional-bands` (portraits: column-major within bands, no dedup, the two
  known packing layouts as a parameter), `composite-bbox` (logo), `cel-runs`
  (overlay blocks: fresh contiguous runs per block, the portrait_overlays.md §4
  rules run forwards). Portrait `tilemap.bin`/`attrmap.bin` (22 files) die; the
  pashute `reference.png` flow stops being a special case and becomes the
  family default. Endgame (separately derisked): generate the *sheet* too,
  making the pictures the only committed pixels, exactly like the logo.
- **A: the map IS source — commit it in an editable form, not `.bin`.**
  Sheet PNG (art) + a human-editable map file the compiler turns into
  descriptor bytes (`rows, cols + idx + attr`). Format decision below. The 12
  screen map bins and the structured-asm screens (editor, bank-$2b, cox,
  room_screen) converge on the same form; scene `descriptors.bin` (7 files)
  follows once the format exists.

### 3. `records` — structural data stays asm
Metasprite lists, scene-VM scripts, pointer tables: labelled asm with macros
(the cox/scene.asm style). The 8 scene `metasprites.bin` migrate to named
records like cox's. Not images; never were.

### Overrides: one uniform escape hatch, measured
Where the original tool made a genuinely arbitrary choice our algorithm can't
predict (a cel cell reusing a non-local pixel-twin tile — verde needed 4), the
manifest takes a uniform `overrides:` block, auto-emitted by the existing
closure pass and **counted in CI** (a build line: "N overrides"). Target after
migration: G-family ≈ a handful project-wide (today: 46 + 13 `bank0`). The
`bank0` maps should fall to the forward allocator (mistral's bank-0 cells are a
contiguous column-major run — algorithmic, not arbitrary).

### One manifest, one tool
`assets.yaml` absorbs the per-portrait `sprites.yaml` content: an asset entry
declares its palettes, art, picture(s)/map(s), cels (ordered blocks with
roles), records location, profile names, overrides. `pngasset.py` evolves into
(or is superseded by) `tools/gfxc.py` — same helpers, the modes re-expressed as
the component kinds above. `buildassets.py` stays the single build entry.

## What dies

| today | count | replaced by |
|---|---|---|
| portrait/intro `tilemap.bin`+`attrmap.bin` | 24 files | derived from composed picture (G) |
| screen `tilemap.bin`+`attrmap.bin` | 12 files | editable map source (A) |
| scene `descriptors.bin` | 7 files | editable map source (A) |
| scene `metasprites.bin` | 8 files | asm records (R) |
| `pal`/`pal_cells` pins | 28 | indexed cel PNGs (explicit palette) |
| `idx` pins | 18 | forward allocation + small override residue |
| `bank0` maps | 13 | two-bank forward allocation |
| `reference.png` special case | 1 | the G-family norm |
| `mode:` zoo (composite/screen/portrait/scene) | 4 modes | component kinds + named profiles |

## Migration plan (each step byte-exact, independently committable)

1. **Indexed cels** — recolour the overlay cel PNGs RGB(A)→indexed (mechanical,
   scripted); teach `gen_patch`/`gen_meta` to read palette from the index.
   Kills the 28 palette pins. No format/schema change yet.
   **DONE 2026-06-12** (`scratch/reindex_cels.py` + the pngasset rewrite): all
   10 portraits byte-exact with the palette-inference code deleted; pins now
   18 `idx` + 13 `bank0` in 3 manifests (8 of 10 are pin-free). A removability
   sweep (`scratch/sweep_pins.py`) confirmed every surviving `idx` pin is a
   genuine pixel-twin, not an inference artifact.
2. **Portrait maps derived** — generalize `derive_portrait_maps` to the indexed
   reference (no inference left: palette explicit, tilemap positional);
   per-portrait composed `portrait.png` replaces `tilemap.bin`/`attrmap.bin`.
   Covers the two-bank ones (mistral/nada) with the bank-region model.
   **DONE 2026-06-12, better than planned**: the maps derive from the layout
   constant + the indexed SHEET alone — no composed reference needed at all
   for 8 of 9 (positional allocation is bijective, so the sheet's per-tile
   palette IS the attrmap; the tilemap is the `standard`/`pashute` constant in
   `PORTRAIT_LAYOUTS`). Mistral additionally collapses blank cells to `$80`
   where their slots were reused, so it carries a composed `reference.png` +
   2 `map_overrides` pins (blank-cell/blank-slot ties that render identically
   either way). 17 files deleted (8×2 bins + pashute's RGB reference); the
   old RGB-inference `derive_portrait_maps` is gone. Residue: the nada pair
   keeps its bins — its maps use a different allocator (bbox-positional with
   blank-collapse, authored against the intro sheet across two banks); model
   it later or accept the bins.
3. **Map source format for family A** — pick the format (decision below),
   write the compiler + a decode bootstrap, convert the 6 screens + intro(?);
   re-express the already-structured asm screens (editor/$2b/cox/room_screen)
   in it only if it pays.
   **DONE 2026-06-12** for the screen family: each screen's arrangement is a
   Tiled `.tmx` next to its sheet PNG (layer "map" over the sheet tileset with
   Tiled flip flags; layer "palette" over the shared 8-swatch
   `assets/screen/palettes.png`). `tmx_to_maps` in pngasset compiles it
   (`map:` key in assets.yaml); all 7 (6 screens + intro_book) round-trip
   byte-exact and their 14 map bins are deleted. intro_book classified into
   family A by inspection (xflips present → authored).
4. **New carves land in the new model** — screen_2a, screen_2b, screen_19,
   tradehouse, next_room, the $0c editor library: sheet PNG + authored maps,
   no new bins. (screen_25 = room_screen is already half-migrated.)
   **PARTIAL 2026-06-12:**
   - **tradehouse DONE** — family G! Both 11x20 maps are the standard
     portrait layout; two derived portrait-style screens
     (assets/screen/tradehouse_{studio,note}), raw 2bpp deleted, bodka.asm
     refs labelled.
   - **screen_19 → textui DONE** — it's the shared dialogue-box UI. New
     `mode: maplib` (generalized `tmx_to_maps`: tiles-per-bank/banks/base
     params, `vram1` placeholder tileset + `priority` layer support) for
     library banks; 512-tile alternate-set sheet + textui.tmx; raw 2bpp
     deleted; home/engine/cox refs labelled.
   - **next_room (bank $24) scoped, not migrated**: tiles $4000 (384 →
     VRAM bank 0), palettes $5800, window panel desc $5880 (7x11 → $9c00,
     uses **priority bits**), then NINE 18x9 floor-group strips chained
     $597f..$6519 (step $14a; their bank-1 cells reference tiles loaded by
     another subsystem → needs the `vram1` placeholder tileset, already
     implemented), metasprite lists, and small digit/label tables
     $65bf-$65f3 consumed by screens.asm via Func_00_35d4/35f9. The strip
     consumers are reached through further indirection (Func_30_4f10 →
     Func_30_58d7?) — trace before restructuring. ~10 TMX maps once done.
   - **screen_2b deferred**: descriptors structured (Screen2b_00-25) but
     the BG tile source is unidentified (the $30:$5cb9 flow loads only
     $0800 of OBJ tiles); trace the BG tileset before a maplib conversion.
   - **screen_2a deferred**: multi-tileset grab-bag + in-room sprites; no
     descriptors of its own found yet — needs inventory first.
5. **Scene frames + metasprites** — descriptors → map source; metasprites →
   asm records.
6. **Endgame derisk (optional)** — generate portrait sheets from
   picture+cels (drop the sheet PNGs for family G); revisit
   `scratch/canon_bottom.py`'s bottom-band findings.

## Decisions

1. **The authored-map source format: Tiled (TMX/CSV)** — decided 2026-06-11.
   Edit maps in Tiled against the sheet PNG as tileset; the build needs only a
   small TMX→bytes compiler (no Tiled dependency at build time). Mapping:
   - **tile + flips**: Tiled stores flips in the GID high bits
     (H=`0x8000_0000` → attr bit 5, V=`0x4000_0000` → attr bit 6).
   - **bank** (attr bit 3): implicit from the GID — the tileset image is the
     stacked two-bank sheet, so GIDs ≥ 384 are bank 1.
   - **palette** (attr bits 0-2): a second tile layer ("palette") over a tiny
     8-swatch tileset; **priority** (bit 7) a third sparse layer if/where used.
   - Layer encoding = CSV inside the TMX for diffability.
   - Bootstrap tool decodes ROM descriptor → `.tmx`; compiler goes the other
     way; both round-trip-tested per screen before the bin is deleted.

## Open decisions

1. **Tool shape**: evolve `pngasset.py` in place vs. a fresh `gfxc.py` that
   imports its helpers (the modes are load-bearing for 28 assets; in-place
   evolution keeps every step verifiable).
2. **intro/intro_book family membership** — classify by the same probes before
   migrating (it has a map bin pair; one quick experiment).

## Guardrails (unchanged)

Byte-exact always (`make verify`); never bulk-emit opaque blobs; overrides are
a measured residue, not a convenience; renders are for human eyeballing, with
sign-off before role names are committed.
