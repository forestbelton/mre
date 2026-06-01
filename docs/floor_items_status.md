# Floor item/monster mapping — status & how to continue

Companion to `docs/floor_data.md` (the format reference). This tracks the
*in-progress* work of naming every tower item and monster. As of 2026-05-31.

## Workflow (how this is being done)

1. `python3 tools/floor.py <N>` decodes normal floor N (record N-1): items (with
   visible/in-crate/hidden state), monsters, spawners. Names come live from
   `include/items.inc`. `--grids` also prints the collision + piece grids.
   `tools/floor.py <rec+1>` reaches a specific record (e.g. floor 85 → bonus
   record 84).
2. The player climbs the tower and reports each item/monster's identity; confirmed
   names are added to `include/items.inc` — items as `DEF IID_<NAME> EQU $xx`
   (base id = low 6 bits), monsters in the `enum MONSTER` block (enum.inc).
3. After each addition: `make verify` (must stay sha256 `8f66b59…`) then commit.
   items.inc isn't assembled into the ROM, so changes are byte-exact by definition;
   `make verify` just confirms nothing else broke.
4. To find which floors still have unknowns, scan records 0-70 (+82-87 bonus) for
   piece-grid item bases / `arr1` species not yet in items.inc.

## Done
- **Floor record format, lookup, encoding, spawners**: fully documented in
  `docs/floor_data.md`. Named in the disasm: `LoadFloorByMode`, `FloorBankTable`,
  `FloorPtrTable`, `FloorPieceDefs`, `DrawFloorPiece`, `GetFloorIndex`,
  `SpawnFloorMonsters`, `ProcessFloorSpawners`, and the `wFloor*` WRAM grids.
- **All 19 monster species named** ($00-$13, incl. the 6 bonus-stage recruits).
- **Most items named** — see items.inc.

## Remaining unidentified item ids (3) — coordinates + static decode
Points/effect are statically decoded from the pickup tables (`Data_01_51aa` points,
`$523a` handlers) — byte-exact certain. See docs/floor_data.md.

| id | static: points · effect | where to find it (floor, row, col, state) |
|---|---|---|
| `$16` | 20,000 · points-only | in data fl 33/40/69/70 but never appears (sprite `$d6`); **not** in the `$5162` gate — separate, still-unknown suppression. Can't observe normally. |
| `$1b` | 500,000 · points-only | fl 60 (r7,c8) hidden — a second "peach" (not in editor legend), still unnamed |
| `$1c` | **1,000,000** · points-only | fl 47 (r2,c8) — was phantom on that visit (`$5162`/bit-0 gate, not permanent) |

**Identified:** `$1a` = **PEACH_SILVER** (confirmed in-game on **fl 62 / basement B2**,
r4,c9 visible). `$1f` = **DOLL_ALF** (proven from code: effect `Func_01_5544` kills
each monster and spawns entity `$1f` = Suzurin, the entity BELL spawns; DOLL_DUCK
`$1e` is the sibling but spawns a different entity `$08`). Coords for `$1f`: fl 58 r7,c5.

> Floor numbering: tower floors 61–70 are displayed as **basement B1–B10** in-game
> (so fl 62 = B2). Records are still `record = floor − 1`.

**`$1b`/`$1c` are observable, not permanently phantom.** They share the `$5162`
conditional-appearance flag (with `$07` COX_HAT, `$17` CAKE, `$19` PEACH_GOLD, `$1a`
PEACH_SILVER, `$1f`) and are removed at floor-load only when `wC2D5` bit 0 is clear —
i.e. when you *didn't* reach the floor by the normal up-stairs path. PEACH_GOLD/SILVER
(same class) appeared, so the rest will too under the right approach. **`$16` is the
only true can't-observe id** (separate mechanism). "Hidden" (coded placement) ≠
"phantom" (doesn't manifest); a hidden item is still obtainable.

## Known item names not yet matched to an id
The level editor's legend (`src/data/data_05d278.bin`) is the authoritative name
list. Cross-referenced against it:
- `$1b` (500,000) is a **second peach** — same points/handler as `$19` PEACH_GOLD /
  `$1a` PEACH_SILVER, but **absent from the editor legend** (not editor-placeable),
  so it has no authoritative name. Still unnamed.
- `$16` and `$1c` (1,000,000) are **absent from the editor legend** — no
  authoritative name from that source; still unknown.
- **DOLL_AYA** — in the player's in-game list but not in the editor legend, and no
  remaining 0-pt DOLL id; may be an alias/cut content.
- Matched: **PEACH_GOLD** = `$19` (500,000), confirmed in-game on fl 45 (r6,c1).
- Matched: **PEACH_SILVER** = `$1a` (500,000), confirmed in-game on fl 62 / B2 (r4,c9).
- Matched: **DOLL_ALF** = `$1f`, proven from code (spawns Suzurin `$1f` per monster).

(`$21`/`$22` are defined-but-unplaced — cut/reserved.)

## Open threads / next steps
- **Static decode — DONE:** the item-pickup/points-effect tables (`Data_01_51aa`
  points, `$523a` handlers) are decoded; points + effect kind for every id are in
  the table above and in docs/floor_data.md. Remaining work is only matching the
  player's *names* to ids (`$1a`/`$1b`/`$1c`/`$1f`) — confirm in-game when reachable.
- **`$16` only true unknown:** in data but never appears, and (unlike `$1c`) not in
  the `$5162` gate. Needs its separate suppression mechanism traced, or sprite
  rendered, to name.
- **Spawner params** `p0/p1/p2` (rate/count) are undecoded — see `Func_01_4219`.
  Spawner species = `arr1[byte5]`, `$ff` = inert.
- **Convert `IID_*` defs to an `enum ITEM`** (like the monsters) once all item ids
  are identified — the player requested this for the final form.
- Floor 41 (2,2) crate is unbreakable-by-jump due to geometry, not data (noted in
  floor_data.md); no action needed.
