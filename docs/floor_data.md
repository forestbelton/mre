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

Internal floors **61–70 are displayed in-game as basement B1–B10** (so internal
floor 62 = "B2"); the `record = floor − 1` mapping is unchanged — only the on-screen
label differs.

## Record format (581-byte slot)

`LoadFloorData`/`Func_00_16ed` parses the record sequentially:

| Offset | Size | Field | Meaning |
|---|---|---|---|
| 0 | 1 | id | ✅ per-floor unique id (all 70 distinct) → `wFloorId` (`$CFBD`). **Inert** — never read by gameplay/render; only the editor snapshots it. *Not* the theme. |
| 1 | 1 | spawnX | ✅ player start column |
| 2 | 1 | spawnY | ✅ player start row |
| 3 | 1 | pad | always `$00` |
| 4 | 1 | tileset | ✅ tile-graphics set, 0–5 → `$C4CC`. `Func_16_4016` copies set *N* (bank `$16`) to VRAM `$9000`; also keys `FloorPieceDefs`. |
| 5 | 1 | palette | ✅ BG colour set, 0–6 → `$C4CB`. `Func_10_40a4` loads palette block *N* (bank `$10` `$408c`) into `wBgPalettes` via `Func_00_0716`. |
| 6 | 1 | height | ✅ grid height (≤14) |
| 7 | 1 | width | ✅ grid width (≤17) |

So a floor's **look = `tileset` (which tile graphics) + `palette` (which colours)**; both are
editor-selectable (the floor-edit menu `Func_00_1b87` sets `tileset` from the cursor and cycles
`palette` 0–6). The `id` byte despite its old "type" name has no effect — it's a per-floor tag.
| 8 | H×W | **collision grid** → `wFloorCollision` (`$C2EF`) | room geometry |
| 8+H×W | H×W | **piece grid** → `wFloorGrid` (`$C3DD`) | visual + object markers |
| … | 4 | arr1 → `$C4CD` | ✅ per-floor sprite-gfx lookup (indexed by a monster's gfxIndex) |
| … | 45 | arr2 → `$C4D1` | ✅ **monster table** — 9 slots × 5 bytes (see below) |
| … | 48 | arr3 → `$C4FE` | ✅ **monster spawner table** — 4 slots × 12 bytes (see below) |

The grids are stored packed at H×W; the WRAM grids are 17 wide, so the loader uses
`wFloorRowStride = $11 − width` to skip the margin. After the arrays, bank-5/bank-1
post-load routines (`Func_05_49EF`, `Func_01_572D`) finish entity setup.

### Record trailer (the 10×11 floors' 256-byte slot slack)

Every record occupies a fixed **581-byte slot** (the `$245` `FloorPtrTable`
stride). 581 is exactly the size of a maximal **14×17** floor:
`8 + 2·238 + 4 + 45 + 48 = 581`. A floor's data fills `8 + 2·H·W + 97` bytes; the
rest of the slot is unused slack. Floors come in **several sizes** (the editor
offers small / medium / large):

| size | H×W | cells | front | **slack** | where |
|---|---|---|---|---|---|
| small  | 10×11 | 110 | 325 | **256** | normal tower (53) + some bonus |
| medium | 10×17 / 14×12 / 14×13 | 168–182 | 441–469 | **112–140** | bonus/boss (bank `$12`) |
| large  | 14×17 | 238 | 581 | **0** | normal tower (17) + some bonus |

(The normal tower floors in banks `$2d/$2e/$2f` are only small or large; the
medium sizes appear on the bonus/boss records in bank `$12`.) A large floor fills
the slot exactly — no trailer; every smaller floor leaves a slack tail.

The **256-byte tail of the 10×11 floors** (what's folded into the small
`roomNN.asm` files) is **never read by anything** — `ParseFloorRecord` stops after
`arr3`, and no other code computes `record+$145` or interprets the tail. Its
content is
just leftover/default bytes, which is why it's structured-but-meaningless and
shared across unrelated floors (analysis in `scratch/trailer_analysis.py`):

- **14 floors** carry the same trivial `ff 00×8 ff×7` fill (entropy 1.0, 2 byte
  values) — a default pattern;
- **8 floors** carry a verbatim copy of some 14×17 floor's tail (`[325:581]`) — a
  buffer-reuse remnant;
- the rest hold other leftover patterns. None of it correlates with `type`, the
  grids, or the layout.

So the "trailer" is **padding, not a field**: the record format is fixed-size for
the biggest floor, and small floors leave the tail uninitialized. (The in-room
level editor copies the whole 581-byte slot — `LoadFloorRecordToBuffer` →
`wFloorSnapshot` → SRAM with an XOR checksum — so the slack rides along, but it
edits only the front and never touches the tail.) It's colocated raw (a `.trailer`
`db` block) in each `src/layout/roomNN.asm` only to keep the build byte-exact.

### Collision grid cells
`$20` = outer border · `$21` = wall · `$00` = walkable floor · `$22` = **crate**
(breakable; an open item on a `$22` cell is "in a crate"). There is no separate
"hard crate" code — whether a crate can be *fully* broken is runtime physics, not
data: a crate boxed in by walls with another crate stacked directly on top only
half-breaks when jumped into from below (e.g. floor 41 (2,2)), though a monster
from an adjacent spawner can break the stacked one. The half-broken state lives in
WRAM, not the record.

### Piece grid cells
`$00` = floor. `≥$40` = an object, classified by `DrawFloorPiece` (`$17DE`) on the
bits: bit 7 → item, bit 6 → exit. Known codes:

| code | object | | code | object |
|---|---|---|---|---|
| `$40` | EXIT (stairs) | | `$c2` | BELL |
| `$43` | Devil's Seal (obstruction) | | `$c8` | BOMB_SMALL |
| `$8f` | DIAMOND_RED | | `$ce` | DIAMOND_BLUE |
| `$93` | MEDAL_GOLD (hidden) | | `$d1` | MEDAL_SILVER |
| `$c0` | KEY | | `$d2` | NUGGET_SILVER |
| `$c1` | KEY_SILVER | | `$d3` | MEDAL_GOLD |
| `$cc` | CRYSTAL_BLUE | | | |

For items (bit 7 set), the low 6 bits are the base id and **bit 6 = placement**:
set (`$cx-$fx`) = placed in the open, clear (`$8x-$bx`) = crate-hidden (revealed by
destroying a crate). E.g. MEDAL_GOLD is `$d3` open / `$93` hidden — confirmed in-game
(`$8e` = hidden DIAMOND_BLUE = `$ce` with bit 6 clear).

An item has **three placement states**, decided by the cell's **collision** value
(and only then bit 6): collision `$22` (crate) ⇒ *in-crate* for either bit 6;
collision `$00` with bit 6 set ⇒ *visible*; collision `$00` with bit 6 clear ⇒
*hidden*. So a crate hides any item — bit 6 only matters off a crate.
(`$ce` DIAMOND_BLUE is visible on floor 5, in a crate on floor 3; `$90`
RING_PLATINUM and `$85` HOURGLASS, both bit-6-clear, are in crates on floor 20.) KEY_SILVER (`$c1`)
is open-coded but gated by progression (the first silver key must be taken at the
tower top), not by the hidden bit.

**"Hidden" ≠ "phantom".** *Hidden* is just this coded placement state and a hidden
item is still obtainable in play (floor 45's PEACH_GOLD `$19`, coded hidden, was
picked up). *Phantom* is the separate, empirical case where an item is in the floor
*definition data* but **nothing appears at its cell at all** in play — not even a
hidden pickup (floor 47 (r2,c8) `$1c`). Phantom is runtime non-manifestation,
orthogonal to the coded visible/hidden/in-crate state, and (for `$1c`) has a known
cause — the conditional-appearance gate below. `$4x` = structural (`$40` EXIT,
`$43` obstruction). Named codes live in `include/items.inc`; many remain unidentified.

#### Conditional-appearance gate (why some items are phantom)
At floor load, `Func_00_166f` runs three grid-cleanup passes (bank `$01`):
- `Func_01_569b` — removes KEY (`$00`) when `wC2D5` (`$c2d5`) bit 1 is set.
- `Func_01_56d5` — removes KEY_SILVER (`$01`) until a progress flag (`Func_00_119a $09`).
- `Func_01_56fb` — the **conditional-item** pass: for each item cell it indexes a
  per-base-id flag table **`Data_01_5162`** (`$5162`); if the flag is nonzero it
  **zeroes the cell** (item gone) — but the whole pass is skipped when `wC2D5` bit 0
  is *set* (`ret nz`). Flagged ids: `$07` COX_HAT, `$17` CAKE, `$19` PEACH_GOLD,
  `$1a`, `$1b`, `$1c`, `$1f`. So these seven appear **only while bit 0 is set**.

`wC2D5` bit 0 is set by `Func_00_1219` (`= $01`) on the normal stair-advance/new-run
setup (`Func_05_4785` at floor 1; `Func_01_4748/4759/476d`) and cleared by
`Func_01_459a` (via the stair-transition `Func_01_447f`, triggered by bit 7) and on
the `$c2d6 ∈ {0,2}` advance branch (`Func_01_4782`, which skips the re-set). Net:
the flagged items show when you reach a floor by the normal up-stairs path and are
suppressed otherwise — which is why PEACH_GOLD appeared on fl 45 but `$1c` did not
on fl 47. (`$16` is **not** in `$5162`; its non-appearance is a separate, still-
unidentified mechanism.)

#### Item points + effect tables
The pickup dispatch `CollectItem` (bank `$01`, in `src/layout.asm`) resolves a
collected item by base id through four parallel per-id tables, now carved as a
readable database in **`src/item_data.asm`** ($00-$23, 36 entries each):
- **`ItemGateFlags`** (`$5162`) — 1 byte/id; the conditional-appearance gate above.
- **`ItemCollectibleDesc`** (`$5186`) — 1 byte/id; `TrackItemCollection`'s "collect
  a set" descriptor (`$ff` = untracked).
- **`ItemPoints`** (`$51aa`) — 4 bytes/id, **big-endian BCD** score (`AddItemScore`).
  E.g. PLATINUM_RING = 50,000; CAKE = 100,000; GOLD_PEACH/SILVER_PEACH/HARE_ICON =
  500,000; `$1c` = 1,000,000.
- **`ItemEffectHandlers`** (`$523a`) — 2 bytes/id, LE pointer to the bank-`$01`
  effect handler. `$5282` is the generic points-only handler (gems/coins/peaches);
  special items (keys, bombs, tororon/hourglass time, dolls, disc stones) each have
  their own handler at `$5282`+ (still in `analyzed.asm`).

Lower piece IDs index `FloorPieceDefs` (`$12FA`, 5-byte entries) and stamp a 2×2
metatile `{T, T+8, T+1, T+9}` to the BG (`$00:$180B`); walls auto-tile from
neighbours (`Func_01_5BA8`/`5BE2`).

### Monster table (arr2)
`Func_01_4064` spawns monsters from `arr2` — **9 slots × 5 bytes**:

| +0 | +1 | +2 | +3 | +4 |
|---|---|---|---|---|
| col | row | **Type** (`$cf81`) | **Facing** (`$cf82`) | gfxIndex (`$cf80`); `$FF` = empty slot |

Sprite pixel position is `col*16 − 8`, `row*16 − 8`. The displayed **species** is
selected by **`arr1[gfxIndex]`** (the per-floor sprite/species table) — observed
`$00` = Tacopi (Octopee), `$01` = Jell, `$03` = Dino, `$05` = Henger, `$06` = Joker,
`$07` = Ghost, `$08` = Puncho, `$0a` = Dakkung (full list in `include/items.inc`).

The `+2`/`+3` bytes are **per-instance behaviour**, not the species, distributed
into the spawned entity (`SpawnFloorMonsters`):

- **Type** (`$cf81`) — two packed 3-bit params (bits 3 & 7 unused; each 0–4 in the
  shipped floors). Low 3 bits (`& $07`) → `entity+$21` (`$ffd1`) = the
  **movement/speed selector** (entity scripts read X-velocity as `tbl[$ffd1 & 7]`
  via `ent_vel_x_indexed`). High 3 bits (`& $70`) → `entity+$20` (`$ffd0`) bits 4–6
  = a **second AI param** the entity update reads. (So floor 1's Jell `$22` = both
  fields = 2; floor 2's Jell `$21` = speed 1.)
- **Facing** (`$cf82`) — the monster's **initial facing** → `entity+$06` (`$ffb6`):
  `Facing & 3` = the 4-direction (dir 1 also sets the xflip bit), `Facing ≥ 4` sets
  an extra flag (bit 2). Mostly `0`.

Items, by contrast, are baked into the piece grid, so a floor's dynamic content is
piece-grid items + `arr2` monsters + `arr3` spawners.

### Monster spawners (arr3)
`Func_01_41aa` (`ProcessFloorSpawners`) reads `arr3` as **4 slots × 12 bytes**
(4×12 = 48 — *not* the 8×6 the room data files originally modelled; byte-identical
only because empty slots are all `$FF`). Per slot:

| Offset | Field | Meaning |
|---|---|---|
| +0 | col | spawn cell column |
| +1 | row | spawn cell row |
| +2..+4 | p0/p1/p2 | spawn timing, packed into one rate value (`p0&7`,`p1&3`,`p2&7`) — undecoded detail |
| +5..+10 | **schedule** | six steps; each `& 3` indexes `arr1`, value `3` (or `$FF`) = no spawn |
| +11 | — | unused trailing byte |

The six schedule bytes (`ReadSpawnerParams` → `$cf84..$cf89`, packed into the
entity's `+$20`/`+$21` by `Func_01_426d`) are a **spawn list**: each step spawns
`arr1[value]`, and a `$FF`/`3` step spawns nothing. A slot whose six steps are all
`3` is empty (`SpawnerSlotActive` returns 0). This exactly reproduces play:

- **Floor 23** — both spawners carry `{2,2,2,-,-,-}` → 3× `arr1[2]` = **3 Naga** each.
- **Floor 47** — one spawner `{0,2,-,-,-,-}` (Tacopi→Naga), the other `{2,0,-,-,-,-}`
  (Naga→Tacopi).

Validated across all 70 floors: every non-empty 12-byte slot has a valid cell, a
schedule of `{0..3,$FF}` values, and `$FF` in `[+11]`. The `Spawner` struct in
`include/room.inc` and every `layout/roomNN.asm` now model this 12-byte layout.

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
  col 3,row 4 = $d1 MEDAL_SILVER
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
