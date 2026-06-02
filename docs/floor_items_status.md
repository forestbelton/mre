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

## All placed item ids now identified

The last three unknowns were resolved by collecting them in a ROM hack (force the
floor-58 placements visible + NOP the hide/removal passes — see git history) and
reading the encyclopedia:

| id | name | pts | notes |
|---|---|---|---|
| `$16` | **WALKING_COIN** *(tentative)* | 20,000 | a gold coin with legs; in data fl 33/40/69/70 |
| `$1b` | **HARE_ICON** | 500,000 | fl 60 (r7,c8) |
| `$1c` | **AYA_DOLL** | 1,000,000 | fl 47 (r2,c8); the player-list "DOLL_AYA" |
| `$1f` | **ALF_DOLL** | — | fl 58 (r7,c5); kills all monsters, spawns Suzurin |
| `$1a` | PEACH_SILVER | 500,000 | fl 62/B2 (r4,c9, visible) |
| `$19` | GOLD_PEACH | 500,000 | fl 45; also fl 70/B10 (r8,c5) |

> Floor numbering: tower floors 61–70 are displayed as **basement B1–B10** in-game
> (so fl 62 = B2). Records are still `record = floor − 1`.

### Why $16/$1c/$1f are never collectible in normal play (mechanism resolved)
Pickup (`RemoveOpenItemAtCell`) only takes **open** (bit-6) items, and these are
forced **hidden** at every floor-load by bank-$05 grid passes run from
`FloorPostLoadCleanup`:
- `Func_05_49c8` re-hides `$16` (**unconditional** — this is the once-"unknown"
  separate suppressor).
- `Func_05_496b` re-hides `$1c`/`$1f` when `$c2e8==0`.
- the `$5162` gate (`RemoveConditionalItemsPass`) also strips `$1c`/`$1f`/peaches/
  etc. unless `wC2D5` bit 0 is set (normal up-stairs path).
- `Func_05_499d` *removes* `$1b` HARE_ICON unless `$c2aa!=0`.

### Encyclopedia ("items seen") mapping
`wItemsSeen` ($CFF4, 4 bytes) is set on pickup by `TrackItemCollection`: for base
id K, descriptor `d = Data_01_5186[K]` (`$ff` = not tracked), and the flag is bit
`d&7` of byte `d>>4`. Items still unseen in the current save: **`$18` BATTLE_CARD**
(fl 31, r4c2) and **`$1b` HARE_ICON** (fl 60).

## Special ids ($21/$22) — confirmed via a floor-59 ROM hack
Both were placed visible on fl 59 and picked up; both are safe (real handlers).
- `$21` (sprite `$e1`, **bomb icon**): a special-stage **collect-4 token**, *not* a
  real bomb (pickup adds no bombs — confirmed in-game). Placed 4× in the corners of
  the no-monster special floors **75/76** (shared record `$12:$574d`), 0 pts, no
  encyclopedia entry. `ItemEffect_Item21` (`$01:$5462`) increments `$cf7e`; only the
  4th pickup sets `$cf40=1` and calls `Func_01_5854(c=4)` (GOLD_KEY's exit/unlock) —
  i.e. collect all four to open the way.
- `$22` (sprite `$e2`, **silver-key icon**): a silver-key **stage-advance token**,
  never placed in normal play. `ItemEffect_Item22` (`$01:$5485` — a real bank-$01
  handler, *not* the bank-$04 junk I first misread) runs the silver-key unlock
  (`Func_01_47a9`) then sets `$c2d6=1`, which the main loop (`Func_01_45ad`) reads as
  "stage complete" → cleanup + `$c2a7=$13`. So pickup **instantly ends/advances the
  stage**; tied to basement-room (mode `$c2c1==2`) descent. No encyclopedia entry.
- `DOLL_AYA` in the player list = `$1c` AYA_DOLL (was thought possibly an alias).

## Open threads / next steps
- **All placed ids identified, `enum ITEM` exists — DONE.** Names live in
  `include/room.inc`; `$1a`/`$19`/`$1b`/`$1c`/`$1f` confirmed in-game (the last
  three via the ROM hack). Only `$16` = WALKING_COIN is a **tentative** name (a
  gold coin with legs; no authoritative name in the editor legend) — rename if a
  real one surfaces.
- **Encyclopedia completion:** still unseen are `$18` BATTLE_CARD (fl 31, r4c2)
  and `$1b` HARE_ICON (fl 60, r7c8) — both normal floors, collectible on a fresh
  visit.
- **`$21` effect** (`$01:$5462`, the special-floor 75/76 item) is undecoded.
- **Spawner params** `p0/p1/p2` (rate/count) are undecoded — see `Func_01_4219`.
  Spawner species = `arr1[byte5]`, `$ff` = inert.
- Floor 41 (2,2) crate is unbreakable-by-jump due to geometry, not data (noted in
  floor_data.md); no action needed.
