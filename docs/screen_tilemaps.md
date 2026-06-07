# Screen tilemap libraries — plan (PINNED)

Status: **deferred / not started.** This captures everything needed to turn the
ROM's BG-tilemap "screen libraries" into editable, comprehensible assets, so the
work can be resumed without re-deriving it. The screens are already mapped as
plain `data` (no coverage gap); this is *phase-2 comprehension* work, optional
and per-screen — see `memory` (project_screen_libraries) and
docs/philosophy.md. **Comprehensibility over coverage; never bulk-emit opaque
`db` walls.**

## What these are

A large slice of `data`-typed ROM is **`CopyBgMap` screen descriptors** — BG
tilemaps (tile indices + CGB attributes), *not* tile pixels (those are VRAM tile
data, loaded separately). Each screen:

```
descriptor (6 bytes):  [rows] [cols] [attr_ptr:LE16] [idx_ptr:LE16]
idx  map: rows*cols bytes  (tile indices)   -- at idx_ptr  == descriptor + 6
attr map: rows*cols bytes  (CGB attributes) -- at attr_ptr == idx_ptr + rows*cols
```

Descriptors sit **back-to-back** (one screen's attr map ends where the next
descriptor begins). CGB attribute byte = palette(0-2) | vrambank(3) | xflip(5) |
yflip(6) | priority(7). Confirmed by decoding bank `$0c` (a 12×10 then a run of
12×32 screens; `scratch/screen_probe.py` decodes descriptors).

### Loaders (confirmed)
- `CopyBgMap` (HOME): `ld a,[hl+]→rows; ld a,[hl+]→cols`; on CGB derefs the
  `attr_ptr` into VRAM bank 1, then derefs `idx_ptr` into VRAM bank 0; copies
  `cols` per row, `de += $20` between rows. hl must already point at a
  descriptor in the *currently mapped* bank.
- Banked path `CopyBgMapBankedA` (`$3942`, per memory): `ld a,<bank>;
  ld [$c29c],a; ld hl,<descriptor>; call $3942`.
- The level editor (bank `$12`) draws some screens from its **own** bank — e.g.
  `Func_12_406f`: `hl=$66a4→$9820`, `$66ca→$983f`, `$66f0→$9a20` via `CopyBgMap`.

### Where they live
~54 libraries / ~65 KB / ~400 screens across banks **`$0c`** (the editor's set,
~23), `$05`, `$15`, `$0a`, `$2b`, plus `$0f`/`$23`. Currently raw `data` in
`src/analyzed.asm`.

## What's already done
The **full-screen `$X:$7080` family + NPC portraits** are editable PNGs:
- `assets/screen/{town,tower,tower_open,room_start,room_done,title}/*.png`,
  `assets/intro/intro.png`, `assets/portrait/*`.
- Pipeline: `assets/assets.yaml` lists each; `tools/buildassets.py` runs
  `tools/pngasset.py` per entry → `build/assets/<name>/` (INCBIN'd by `src/gfx/`).
- A `mode: screen` asset = **one PNG** (tile data + palette *derived* from it) +
  committed **`tilemap.bin`** and **`attrmap.bin`** (the non-derivable maps).
  See docs/gfx_assets.md, docs/philosophy.md.

## The gating dependency (the actual work)
A tilemap is only indices+attributes; to render a **picture** you also need the
screen's **tileset** (2bpp tile pixels in VRAM) and **palettes** (8 BG palettes
of 4 colours). These are set up by the *code that draws the screen*, per context
— so "which tiles + which palette feed screen N" is a **per-screen / per-group
trace** of the VRAM tile load + palette load around each draw site. The old
VRAM-provenance tooling for this was removed and must be re-derived. This trace,
not the tilemap decode, is the real cost — hence **prove one render before
scaling.**

Useful leads: docs/palettes.md (CGB palette system, WRAM shadows `$c101`/`$c141`),
docs/gfx_loaders.md / gfx_catalog.md (identifying raw_gfx sheets),
project_vram_provenance / project_cgb_palettes / project_gfx_loaders in memory.

## Plan (phased)

0. **Inventory** — promote `scratch/screen_probe.py` to a tool that walks each
   bank, decodes every descriptor (addr, rows×cols, idx/attr offsets, size),
   and lists all screens. Cheap; no tileset needed. Gives the full screen map.
1. **Prove one render** (read-only, no source change) — pick one group (the
   editor `$0c` set is the best first target: many partial screens likely
   sharing one tileset+palette). Trace that group's tileset + BG palettes. Build
   a renderer `(descriptor + tileset + palette) → PNG` and validate one screen
   looks correct. *This is the milestone that de-risks everything.*
2. **One group → editable assets** — extend `pngasset.py` with a "screen-lib"
   mode (shared tileset, partial/non-full-screen tilemaps; commit
   `tilemap.bin`/`attrmap.bin` per screen, derive/ share the tileset+palette);
   render the whole group to PNGs; add to `assets.yaml`; carve that bank's
   library out of `analyzed.asm` → INCBIN. Confirm `make verify` byte-exact.
3. **Scale** — repeat per group/bank, sharing tilesets where groups share them.

## Open decisions (revisit when resumed)
- **Editable pictures vs comprehensible-as-data.** Full PNG round-trip (phase
  1-3) is the north-star, but a cheaper interim is a *structured* carve (per
  screen: a label + `rows,cols` + idx/attr as 2-D `db` grids) — comprehensible &
  editable as tilemap data, byte-exact, *no tileset trace needed*. Not opaque
  `db`, but not a picture. Decide per appetite; default is the PNG route.
- How widely tilesets are shared within/across banks (determines grouping).
- Start target: editor `$0c` set (assumed shared tileset) vs another group.

## Guardrails
- Byte-exact always (`make verify`); never bulk-emit opaque `db`.
- Tooling via `tools/`; run from `scratch/*.py`. Surgical asm edits via
  `tools/asmrepl.py`.
