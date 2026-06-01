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

## Remaining unidentified item ids (4) — coordinates + static decode
Points/effect are statically decoded from the pickup tables (`Data_01_51aa` points,
`$523a` handlers) — byte-exact certain. See docs/floor_data.md.

| id | static: points · effect | where to find it (floor, row, col, state) |
|---|---|---|
| `$16` | 20,000 · points-only | in data fl 33/40/69/70 but never appears (sprite `$d6`); **not** in the `$5162` gate — separate, still-unknown suppression. Can't observe normally. |
| `$1a` | 500,000 · points-only | fl 62 (r4,c9) **visible** · fl 68 (r12,c6) visible · fl 63 (r3,c5) in-crate |
| `$1b` | 500,000 · points-only | fl 60 (r7,c8) hidden |
| `$1c` | **1,000,000** · points-only | fl 47 (r2,c8) — was phantom on that visit (`$5162`/bit-0 gate, not permanent) |

**Identified by code (no climb needed):** `$1f` = **DOLL_ALF** — its effect
`Func_01_5544` kills each monster and spawns entity `$1f` (Suzurizo, the same entity
BELL spawns) at its position. DOLL_DUCK `$1e` is the structural sibling but spawns a
different entity (`$08`). (Floor coords for `$1f`: fl 58 r7,c5.)

**`$1a`/`$1b`/`$1c` are observable, not permanently phantom.** They share the `$5162`
conditional-appearance flag (with `$07` COX_HAT, `$17` CAKE, `$19` PEACH_GOLD, `$1f`)
and are removed at floor-load only when `wC2D5` bit 0 is clear — i.e. when you
*didn't* reach the floor by the normal up-stairs path. PEACH_GOLD (same class)
appeared on fl 45, so the rest will too under the right approach. **`$16` is the only
true can't-observe id** (separate mechanism). "Hidden" (coded placement) ≠ "phantom"
(doesn't manifest); a hidden item is still obtainable.

## Known item names not yet matched to an id
From the player's in-game item list — candidates for the ids above:
- **DOLL_AYA** — effect unknown; not yet located (no remaining 0-pt DOLL id — may be
  an alias, `$1c`, or cut content).
- **PEACH_SILVER** — 500,000 points.

Static cross-check (still needs in-game confirmation for the exact name):
- **PEACH_SILVER** (500,000) ⇒ `$1a` or `$1b` (both 500,000 points-only). The other
  500k id is a second points-only "peach" not yet in the player's list.
- `$1c` (1,000,000) has **no name in the player's list yet** — a premium item.
- Matched: **PEACH_GOLD** = `$19` (500,000), confirmed in-game on fl 45 (r6,c1).
- Matched: **DOLL_ALF** = `$1f`, proven from code (spawns Suzurizo `$1f` per monster).

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
