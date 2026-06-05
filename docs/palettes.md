# CGB palettes — how the game loads colors

Discovered while colorizing the monster portraits (docs/monster_detail_screen.md),
but this is the game-wide palette mechanism. It's the key to giving the many
grayscale-extracted assets (portraits, screens — see docs/gfx_assets.md) their
real colors.

## WRAM shadow buffers + VBlank flush

The CGB palette registers (`rBGPI/rBGPD` = `$ff68/69`, `rOBPI/rOBPD` = `$ff6a/6b`)
are not written directly by gameplay code. Instead the game keeps two **WRAM
shadow buffers** and flushes them during VBlank:

- **`$c101`** — 8 BG palettes × 8 bytes = `$40` bytes (4 RGB555 colors each).
- **`$c141`** — 8 OBJ palettes × 8 bytes = `$40` bytes.

`Func_00_0505` streams `$c101` → `rBGPD` (auto-increment from index `$80`); the
twin `Func_00_055a` streams `$c141` → `rOBPD`. They run when the dirty flags
`[$ffa1]` (BG) / `[$ffa2]` (OBJ) are set, then clear them.

## Loaders (set a palette, request a flush)

Each copies palette bytes from a ROM pointer in `HL` into the shadow buffer and
sets the dirty flag. `A` selects the slot where noted:

| routine | copies | into | meaning |
|---|---|---|---|
| `Func_00_04f2` | `$40` (all 8) | `$c101` | replace all BG palettes |
| `Func_00_052e` | `$08` (one) | `$c101 + A*8` | set BG palette `A` |
| `Func_00_0547` | `$40` (all 8) | `$c141` | replace all OBJ palettes |
| (OBJ single)   | `$08` | `$c141 + A*8` | set OBJ palette `A` |

A screen's init typically calls `Func_00_04f2` then `Func_00_0547` with two ROM
pointers (grep finds the pairs: e.g. lines ~1411, ~2580, ~34952, ~36074, ~36983).
Partial updates use the single-palette loaders, and arbitrary `memcpy`s into
`$c101`/`$c141` + setting `[$ffa1]`/`[$ffa2]` also work (e.g. the per-monster
portrait palettes — `Func_32_41c1` copies straight into `$c121`/`$c149`).

## Palette data format

`$08` bytes per palette = 4 colors, each a little-endian **RGB555** word
(`r | g<<5 | b<<10`, 5 bits/channel). Same packing as `tools/pngasset.py`
already reads for the logo.

## Why this helps the whole project

Most extracted assets are grayscale because their palette source was "not yet
located" (docs/gfx_assets.md). The recipe to colorize any of them:

1. Find the screen's setup routine (the one that uploads its tiles/tilemap).
2. Look for the `Func_00_04f2` / `Func_00_0547` (or single-palette) calls near it
   and note the ROM pointer in `HL` (and bank) before each call.
3. Read `$40` bytes there = the 8 BG (or OBJ) palettes; map cells/sprites to a
   palette via their attribute byte's low 3 bits.

Worked examples:
- Monster portraits: per-monster `$80`-byte block in bank `$0f` at `$7191 + $80*m`;
  `block+$20` → BG palettes 4–6, `block+$48` → OBJ palettes 1–2.
- Bank-`$30` full screens (town, tower, title, …): each data bank has a fixed
  layout — `$X:$7000` = 8 BG palettes, `$X:$7040` = 8 OBJ, `$X:$7080` = the
  CopyBgMap descriptor. scratch/render_screens.py reads `$7000` to render them in
  color; see docs/gfx_loaders.md.
