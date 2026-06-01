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

## Remaining unidentified item ids (5) — coordinates
| id | where to find it (floor, row, col, state) |
|---|---|
| `$16` | **phantom**: in data on fl 33/40/69/70 but NEVER appears in play (has a real sprite `$d6`). Can't observe normally. |
| `$1a` | fl 62 (r4,c9) **visible** · fl 68 (r12,c6) visible · fl 63 (r3,c5) in-crate |
| `$1b` | fl 60 (r7,c8) hidden |
| `$1c` | **phantom**: fl 47 (r2,c8) coded hidden, but nothing appears at the cell in play (confirmed in-game). Only location — can't observe normally, like `$16`. |
| `$1f` | fl 58 (r7,c5) hidden |

**"Hidden" (coded placement) ≠ "phantom" (doesn't appear in play at all).** A hidden
item is still obtainable (PEACH_GOLD `$19` on fl 45 was). Phantom is runtime
non-manifestation — nothing at the cell — and currently affects `$16` and `$1c`.
See docs/floor_data.md.

## Known item names not yet matched to an id
From the player's in-game item list — candidates for the ids above:
- **DOLL_ALF** — turns all floor monsters into Suzurizos (the entity a BELL `$02`
  pickup spawns; collecting 10 Suzurizos = 1-up)
- **DOLL_AYA** — effect unknown
- **PEACH_SILVER** — 500,000 points

(Matched: **PEACH_GOLD** = `$19`, confirmed in-game on floor 45 (r6,c1, hidden).)

(`$16` may be one of these or cut. `$21`/`$22` are defined-but-unplaced — cut/reserved.)

## Open threads / next steps
- **Faster matching (offered, not started):** decode the item-pickup/points-effect
  table (effects are keyed by item id) to match the remaining ids ↔ names
  statically — e.g. the id that awards 500,000 pts is a PEACH, ×2-time is
  TORORON_HALF — instead of reaching each floor.
- **Spawner params** `p0/p1/p2` (rate/count) are undecoded — see `Func_01_4219`.
  Spawner species = `arr1[byte5]`, `$ff` = inert.
- **Convert `IID_*` defs to an `enum ITEM`** (like the monsters) once all item ids
  are identified — the player requested this for the final form.
- Floor 41 (2,2) crate is unbreakable-by-jump due to geometry, not data (noted in
  floor_data.md); no action needed.
