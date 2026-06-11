# CGB palettes — how the game loads colors

Discovered while colorizing the monster portraits (docs/monster_detail_screen.md),
but this is the game-wide palette mechanism. It was the key to giving the
grayscale-extracted assets (portraits, screens — see docs/gfx_assets.md) their
real colors; all of them now carry colour.

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

### 6-of-8: why `$30` is loaded from a `$40` region

The CGB has **8 BG + 8 OBJ** hardware palette slots = `$40` bytes per set, and the ROM
lays each set out on a `$40` boundary (BG at `base`, OBJ at `base+$40`). But most
screens/portraits only define **6** palettes, so the upload copies only **`$30`** (6
palettes) into the WRAM shadow — leaving a `$10` gap (the 2 unused slots) between the
loaded BG palettes and the next set. So a "palette" that looks `$40` on disk but loads
`$30` is normal: it's 6 used + 2 spare slots.

That trailing `$10` is **not always zero** — don't blindly drop it. Surveyed across the
portraits + scene palette sets:
- 7 sets (toamuna, kalum, naji, rafaga, tempest, bodka, verde ×2) have the 2 spare slots
  as `$00` → carved as **`DS $10`** (the `.bin` holds only the 6 real palettes).
- 4 sets (pashute, mistral, nada, the bank-`$33` tradehouse scene) have **real non-zero
  palette data** in those slots → kept as a `db` blob (`Data_<bank>_<addr>`), never
  loaded but byte-real.

So when carving a palette region, copy the loaded `$30` into the `.bin` and check the
trailing `$10` in the ROM: `DS $10` if zero, an explicit `db` blob if not.

## Why this helps the whole project

All of the editable graphics assets now carry real colour; nothing is left
grayscale-for-lack-of-a-palette. The recipe to locate any asset's palette:

1. Find the screen/portrait's setup routine (the one that uploads its tiles/tilemap).
2. Look for the `Func_00_04f2` / `Func_00_0547` (or the banked-copy
   `Func_00_3913` into `wBgPalettes` / `wObjPalettes`) calls near it and note the
   ROM pointer in `HL` (and bank) before each.
3. Read the bytes there = the BG (or OBJ) palettes; map cells/sprites to a palette
   via their attribute byte's low 3 bits.

Worked examples:
- Monster portraits: per-monster `$80`-byte block in bank `$0f` at `$7191 + $80*m`;
  `block+$20` → BG palettes 4–6, `block+$48` → OBJ palettes 1–2.
- Bank-`$30` full screens (town, tower, title, …): each data bank has a fixed
  layout — `$X:$7000` = 8 BG palettes, `$X:$7040` = 8 OBJ, `$X:$7080` = the
  CopyBgMap descriptor. The screen assets embed these in their PNGs.
- Character portraits (kalum, toamuna, …): each draw routine copies 6 BG + 6 OBJ
  palettes (`$30` each) from ROM **adjacent to the tile sheet** into
  `wBgPalettes`/`wObjPalettes` via `Func_00_3913` — e.g. Kalum_StartEncounter
  reads `$1d:$5800`/`$5840`. These were NOT lib-dispatched; they are carved into
  each portrait asset (palette_bg.bin / palette_obj.bin). See docs/gfx_assets.md.
