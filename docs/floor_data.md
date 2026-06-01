# Tower floor data

The tower floors are **stored data, not procedurally generated**. Each floor is a
fixed 581-byte record: a header, two cell grids (collision + visual/piece layout),
and entity arrays. Confidence is marked ✅ confirmed / 🟡 inferred.

## Lookup chain — floor number → record

The floor index is computed by **`Func_00_16c1`** (called from the dungeon setup
`Func_01_439e`) and depends on the screen **mode** in `$c2c1`:

```
d = wActiveFloor - 1                  ; wActiveFloor ($C2C0) = floor number, 1-based
mode = [$c2c1]
  mode == 0 :  index = d              ; ✅ normal tower floors  (records 0..~70)
  mode == 2 :  index = $46 + d        ; 🟡 a higher block
  mode == 5 :  -> LoadFloorData / GetFloorIndex  ; bonus stages (see below)
```

Then (`Func_00_16ed`):

```
bank = [FloorBankTable + index]       ; $1567, one byte per floor
ld [$2fff], bank                      ; map that ROM bank
ptr  = [FloorPtrTable + index*2]      ; $15BF, one LE word per floor
                                       ; record at bank:ptr ($4000-$7FFF window)
```

✅ **`FloorBankTable` (`$1567`)** / **`FloorPtrTable` (`$15BF`)** have 88 entries:
records 0–~70 in banks `$2D`/`$2E`/`$2F` (normal floors), and a `$12`-bank tail
(records ~76–87) for the **bonus stages** (reached via MONSTER_FLAME).

**Bonus stages** (mode 5): six floors — **6, 18, 22, 44, 56, 58** — contain a
`MONSTER_FLAME` item (`$1d`) that warps to a bonus stage with a friendly monster.
The bonus-stage layout is its own record: `GetFloorIndex` (`$17A2`) scans the
6-entry table **`$1783`** to remap those floors to records **82–87** (bank `$12`).
The normal floor and its bonus stage are different records (floor 18 = record 17;
its bonus stage = record 83, where the friendly monster is GALI `$11`).

So **floor 1 → record 0**, **floor 2 → record 1**, and *every* normal floor is
`record = floor − 1`. Verified against a live `--watch-write` of
`$C2C0`/`$C2C1`/`$C2C2` (floor 1 = `$C2C0=1, $C2C1=0` → index 0).

## Record format (581-byte slot)

`LoadFloorData`/`Func_00_16ed` parses the record sequentially:

| Offset | Size | Field | Meaning |
|---|---|---|---|
| 0 | 1 | type | 🟡 floor type/theme (`$61` for floor 1) |
| 1 | 1 | spawnX | ✅ player start column |
| 2 | 1 | spawnY | ✅ player start row |
| 3–5 | 3 | params | 🟡 unknown (floor 1: `00 00 01`) |
| 6 | 1 | height | ✅ grid height (≤14) |
| 7 | 1 | width | ✅ grid width (≤17) |
| 8 | H×W | **collision grid** → `wFloorCollision` (`$C2EF`) | room geometry |
| 8+H×W | H×W | **piece grid** → `wFloorGrid` (`$C3DD`) | visual + object markers |
| … | 4 | arr1 → `$C4CD` | ✅ per-floor sprite-gfx lookup (indexed by a monster's gfxIndex) |
| … | 45 | arr2 → `$C4D1` | ✅ **monster table** — 9 slots × 5 bytes (see below) |
| … | 48 | arr3 → `$C4FE` | ✅ **monster spawner table** — 4 slots × 6 bytes (see below) |

The grids are stored packed at H×W; the WRAM grids are 17 wide, so the loader uses
`wFloorRowStride = $11 − width` to skip the margin. After the arrays, bank-5/bank-1
post-load routines (`Func_05_49EF`, `Func_01_572D`) finish entity setup.

### Collision grid cells
`$20` = outer border · `$21` = wall · `$00` = walkable floor · `$22` = **crate**
(breakable; an open item on a `$22` cell is "in a crate").

### Piece grid cells
`$00` = floor. `≥$40` = an object, classified by `DrawFloorPiece` (`$17DE`) on the
bits: bit 7 → item, bit 6 → exit. Known codes:

| code | object | | code | object |
|---|---|---|---|---|
| `$40` | EXIT (stairs) | | `$c2` | BELL |
| `$43` | bat obstruction | | `$c8` | BOMB_SMALL |
| `$8f` | DIAMOND_RED | | `$ce` | DIAMOND_BLUE |
| `$93` | COIN_GOLD (hidden) | | `$d1` | COIN_GRAY |
| `$c0` | KEY | | `$d2` | NUGGET_GRAY |
| `$c1` | KEY_SILVER | | `$d3` | COIN_GOLD |
| `$cc` | CRYSTAL_BLUE | | | |

For items (bit 7 set), the low 6 bits are the base id and **bit 6 = placement**:
set (`$cx-$fx`) = placed in the open, clear (`$8x-$bx`) = crate-hidden (revealed by
destroying a crate). E.g. COIN_GOLD is `$d3` open / `$93` hidden — confirmed in-game
(`$8e` = hidden DIAMOND_BLUE = `$ce` with bit 6 clear).

An item has **three placement states**, decided by the cell's **collision** value
(and only then bit 6): collision `$22` (crate) ⇒ *in-crate* for either bit 6;
collision `$00` with bit 6 set ⇒ *visible*; collision `$00` with bit 6 clear ⇒
*hidden* (phantom). So a crate hides any item — bit 6 only matters off a crate.
(`$ce` DIAMOND_BLUE is visible on floor 5, in a crate on floor 3; `$90`
RING_PLATINUM and `$85` HOURGLASS, both bit-6-clear, are in crates on floor 20.) KEY_SILVER (`$c1`)
is open-coded but gated by progression (the first silver key must be taken at the
tower top), not by the hidden bit. `$4x` = structural (`$40` EXIT, `$43` obstruction).
Named codes live in `include/items.inc`; many remain unidentified.

Lower piece IDs index `FloorPieceDefs` (`$12FA`, 5-byte entries) and stamp a 2×2
metatile `{T, T+8, T+1, T+9}` to the BG (`$00:$180B`); walls auto-tile from
neighbours (`Func_01_5BA8`/`5BE2`).

### Monster table (arr2)
`Func_01_4064` spawns monsters from `arr2` — **9 slots × 5 bytes**:

| +0 | +1 | +2 | +3 | +4 |
|---|---|---|---|---|
| col | row | type (`$cf81`) | param (`$cf82`) | gfxIndex (`$cf80`); `$FF` = empty slot |

Sprite pixel position is `col*16 − 8`, `row*16 − 8`. The displayed **species** is
selected by **`arr1[gfxIndex]`** (the per-floor sprite/species table) — observed
`$00` = Tacopi (Octopee), `$01` = Jell, `$03` = Dino, `$05` = Henger, `$06` = Joker,
`$07` = Ghost, `$08` = Puncho, `$0a` = Dakkung (full list in `include/items.inc`). The `+2` "type" byte is *not* the species
(a per-instance attribute: floor 1's Jell is `$22`, floor 2's Jell is `$21`).
Items, by contrast, are baked into the piece grid, so a floor's dynamic content is
piece-grid items + `arr2` monsters + `arr3` spawners.

### Monster spawners (arr3)
`Func_01_41aa` (`ProcessFloorSpawners`) reads `arr3` as **4 slots × 6 bytes**:
`[col][row][p0][p1][p2][p3]`. `col=$ff` = empty slot. The reader packs `p0&7`,
`p1&3`, `p2&7` into a value and passes it to `Func_01_4219` — the spawned species
and rate/cap live in those params (not a clean `arr1` index), and aren't decoded
yet. Floor 8's two spawners (`04 02 01 00 03 00`, `02 02 01 00 03 00`) produce
Tacopi. The reader `jr z`-skips when `Func_01_4219` returns 0, so a slot can be
**inert** — present but spawning nothing, acting like an obstruction (e.g. floor
15's `… 02 00 02 …`). Active/species/rate decode is TBD.

## Worked example — Floor 1 (record 0, `$2D:$4000`, 10×11)

Header: `type=$61  spawn=(col 2,row 7)  10×11`.

```
collision (20 border, 21 wall, 00 walkable, 22 object):
  20 20 20 20 20 20 20 20 20 20 20
  20 21 21 21 21 21 21 21 21 21 20
  20 21 00 00 00 00 00 00 00 21 20
  20 21 00 00 00 00 00 00 21 21 20
  20 21 00 22 00 00 00 22 21 21 20
  20 21 00 00 00 00 22 21 21 21 20
  20 21 00 00 00 22 21 21 21 21 20
  20 21 00 00 21 21 21 21 21 21 20
  20 21 21 21 21 21 21 21 21 21 20
  20 20 20 20 20 20 20 20 20 20 20

objects (from the piece grid):
  col 8,row 2 = $40 EXIT
  col 3,row 3 = $c0 KEY
  col 3,row 4 = $d1 COIN_GRAY
  col 5,row 5 = $c8 BOMB_SMALL
```

The collision grid's diagonal wall mass is the same room geometry as a live VRAM
capture of B1 (orientation differs by scroll). **One monster** (`arr2` entry 0
`06 04 22 00 01`): col 6, row 4, type `$22`, gfxIndex 1 — confirmed against the
live game. `arr1 = 00 01 02 0e`. The remaining `arr2`/`arr3` slots are `$FF`.

## Open questions

- Spawner param bytes (`p0/p1/p2`) — spawn rate/cap/etc. (`Func_01_4219`).
- The `arr2` `+2` "type" byte (per-instance attribute, not species); header
  params at offsets 3–5; remaining unnamed item codes / species (see items.inc).
- Mode-1 path in `Func_00_16c1`; the post-load routines `Func_05_49EF`/`Func_01_572D`.

## Named in the disassembly

map.json `labels[]`: `FloorBankTable`, `FloorPtrTable`, `FloorPieceDefs`,
`LoadFloorData`, `DrawFloorPiece`, `GetFloorIndex`. wram.inc: `wActiveFloor`,
`wFloorWidth`/`Height`/`RowStride`/`Collision`/`Grid`.
