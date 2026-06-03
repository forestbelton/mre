# Tower in-room action engine (bank `$03`, `src/room.asm`)

Bank `$03` is the engine that runs **while the player is inside a tower room**:
the player avatar, monster AI, projectiles / FX sprites, and breakable-crate
handling. It is distinct from the floor *layout* code:

| concern | file | bank |
|---|---|---|
| per-floor layout **data** (collision + piece grids, spawner table) | `src/layout/roomNN.asm` | `$2d`/`$2e` |
| turn a floor number into a built, rendered room (parse record, draw pieces, spawn initial entities) | `src/layout.asm` | `$00`/`$01`/`$05` |
| **animate the room each frame** (this document) | `src/room.asm` | `$03` |

See [`floor_data.md`](floor_data.md) for the record/grid formats the layout code
consumes.

## Entry points (the only labels called from outside bank `$03`)

| addr | name | callers | role |
|---|---|---|---|
| `$4000` | `UpdateEntities` | bank `$01` tower loop (`Func_01_4412`), once at floor setup + once per frame | per-frame pass over all 28 entity slots |
| `$44bb` | `BreakTileAtPixel` | bank `$01`, ~12 sites | `b`=pixel Y, `c`=pixel X → cell, then `BreakTileAtCell` |
| `$44cb` | `BreakTileAtCell` | bank `$01`, ~10 sites | break a breakable cell at row `b`, col `c`; on success spawn a shard entity (type `$0d`) at the cell centre, return `a=1` |
| `$4a58` | `RequestFloorExit` | bank `$0f` bonus-stage exit | `set 7, [$c2d5]` — the floor-exit / stair-transition flag the main loop polls (`bit 7,[$c2d5] → Func_01_447f`) |

All four are reached through the project's `CallBankedHL` trampoline
(`ld a,$03 / ld hl,<entry> / call CallBankedHL`). Everything else in the bank is
bank-internal.

## The per-entity script VM

Each entity is a **`$2a`-byte (42) record**. Up to **28** of them live in
`wEntities` — the alloc/scan base is `$c7f9`, and `UpdateEntities` walks the same
array starting from `$cc67`. Record byte **+0** is the occupied/state flag
(`0` = empty slot).

`UpdateEntities` (`$4000`) walks the 28 slots (`ld c,$1c`, stride `$2a` via
`rst $08`). For each occupied slot it calls `RunEntity` (`$4037`), which:

1. `LoadEntityRegs` (`$4308`) copies the 42-byte record into the **HRAM shadow**
   `$ffb0..$ffd9`, and stashes the record's WRAM pointer in `$ffe5/$ffe6`.
2. Enters `RunEntityScript` (`$4042`) — a **threaded bytecode interpreter**:

   ```
   RunEntityScript:        ; de = script PC (entity field +$18)
       ld a, [de]          ; fetch opcode
       <hl = EntityOpcodeTable + a*2>
       jp hl               ; dispatch
   ```

   Each opcode handler reads its operands with `inc de; ld a,[de]`, does its work,
   and tail-jumps back to `RunEntityScript` to fetch the next opcode.
   `EndEntityFrame` (`$404f`) is the per-frame **yield**: it stores `de` back to
   field +$18, runs the cross-bank per-frame sprite/anim update (`Func_01_6d48`
   in bank `$01`, `Func_04_4000` in bank `$04`), then `SaveEntityRegs` (`$438d`)
   writes the shadow back to WRAM.

`EntityOpcodeTable` (`$4098`) is the 9-entry primary opcode jump table (opcodes
`$00`–`$08`): set/clear velocity, set type, indexed velocity, set facing, call a
gfx routine, set a timer, etc. A secondary block of handlers (`$41ac`–`$42ed`,
interleaved with small dispatch tables at `$40aa`–`$40d8`) implements the
extended opcodes — waits, countdown-and-branch, AND-tests, relative spawns,
input/value conditional branches. *(The extended set's mechanism is uniform and
clear; individual opcode numbers are not all enumerated yet.)*

### Entity record / HRAM-shadow layout

Reconstructed from `LoadEntityRegs`/`SaveEntityRegs` and field usage. Offsets are
the record offset; the live copy sits at `$ffb0 + offset`.

| off | HRAM | meaning |
|---|---|---|
| +0 | `$ffb0` | occupied / state-id flag (`0` = empty) |
| +1 | `$ffb1` | secondary-update enable (nonzero → call `Func_04_4000`) |
| +3 | `$ffb3` | entity **type** id (set by opcode `$01`) |
| +4 | `$ffb4` | status bits (bit7 = acting/cooldown gate) |
| +5 | `$ffb5` | animation sub-state (`&3` selects facing variant) |
| +6 | `$ffb6` | **facing/flags** (bit7 = X facing, bits0-1 = 4-dir, bit3 = active) |
| +7 | `$ffb7` | move/collision result bits |
| +8 | `$ffb8` | behaviour-selector result code (`$ff`/0..4) |
| +$0b/+$0c | `$ffbb/$ffbc` | **X position** (subpixel / pixel) |
| +$0d/+$0e | `$ffbd/$ffbe` | **Y position** (subpixel / pixel) |
| +$0f/+$10 | `$ffbf/$ffc0` | **X velocity** (signed 16-bit) |
| +$11/+$12 | `$ffc1/$ffc2` | Y velocity / counter |
| +$13/+$14 | `$ffc3/$ffc4` | 16-bit timer |
| +$16 | `$ffc6` | per-entity timer (opcode `$08`) |
| +$17 | `$ffc7` | action/attack cooldown timer |
| +$18/+$19 | `$ffc8/$ffc9` | **script program counter** (`de` in `RunEntityScript`) |
| +$20/+$21 | `$ffd0/$ffd1` | OAM attribute / species-anim selector |
| +$22..+$25 | `$ffd2..$ffd5` | hitbox-probe offsets (ahead-X, up-Y, width, height) |

Other HRAM used by the engine: `$ffe4` = current-entity classification byte,
`$ffe5/$ffe6` = current-entity WRAM pointer, `$ffda..$ffe1` = scratch hitbox rect
built for entity-vs-entity overlap tests.

## Spawning

* `FindFreeEntitySlot` (`$4575`) scans the 28 records (`$c7f9`, stride `$2a`) for
  the first with `[+0]==0`; returns `a=1`, `hl`=slot, or `a=0` if full.
* `SpawnEntity` (`$4593`): **`A`=type id, `D`=Y pixel, `E`=X pixel, `BC`=param**.
  Allocates a slot, zeroes flags/velocity, stamps type+position, then calls
  bank-`$01` `Func_01_7b24` and bank-`$04` `Func_04_4344` to fill the gfx/script
  template from a per-type table. Returns `a=1`,`hl`=slot on success, `a=0` if no
  free slot.
* `SpawnEntityRelative` (`$440c`) adds the current entity's position to `(c,b)`
  before calling `SpawnEntity` (used by the relative-spawn opcode).

Type ids seen passed to `SpawnEntity` include `$0d` (crate shard), the
`$10`–`$1b` range (player-attack sprites), and various FX ids.

## Breakable-crate / floor-cell helpers

| addr | name | behaviour |
|---|---|---|
| `$44f1` | `TryBreakCrateCell` | `ReadFloorCell`; if tile `$22`/`$23` (crate) → clear `wFloorCollision[cell]`, un-hide any concealed item in `wFloorGrid` (bit7), `DrawFloorPiece`, return 1; else 0 |
| `$451c` | `BreakOrChainCrateCell` | `$22` → half-break to `$23` + redraw (ret 1); `$23` → full clear + reveal gated on a neighbour check (ret 0); else ret 2 |
| `$46dc` | `OrderPair` | returns `b`=max(`a`,`b`), `c`=min(`a`,`b`) (distance helper) |

`ReadFloorCell` / `DrawFloorPiece` are the bank-`$00` floor-grid routines
documented in `floor_data.md`.

## Behaviour selectors (the bulk of `$5938`–`$6e00`)

From roughly `$5938` on, the bank is a long sequence of near-identical
**per-type / per-state behaviour selectors**. Each one calls a probe sub
(`UpdateActionTimer` at `$441f` plus a world/player test) that writes a small
result code into `$ffb8`, then `cp`-chains on that code and returns `de` = the
address of the next **script** to run. The scripts themselves are bytecode in the
`$71eb`–`$7d25` region, consumed by `RunEntityScript` — fully specified in
[`entity_scripts.md`](entity_scripts.md).

* Selectors that read the joypad (`$ff8b`/`$ff8c`, via `$46ed`/`$48cb`) drive the
  **player avatar**.
* Selectors that read floor tiles + player position (`$c805` X / `$c807` Y /
  `$c7ff` facing) drive **monster AI**; the `$5de3`–`$6355` block is the
  8-direction "move, else turn" locomotion core.

## Curated vs. undecoded

The labels above (and a handful of helpers) are in `map.json` `labels[]` and
carry curated names. The full VM dispatcher is now decoded: `EntityOpcodeTable`
plus all 34 `EntityOp_*` handlers, and the entire script bytecode
([`entity_scripts.md`](entity_scripts.md)). The remainder of the bank keeps
auto-generated `Func_03_xxxx` / `Data_03_xxxx` names — deliberately, rather than
inventing speculative ones. The script bytecode is fully carved and the monster
**species** are resolved (`MonsterSpawnScriptTable` → `room.inc` `enum MONSTER` →
the editor legend), and the ~110 native routines/tables the scripts `ent_call`
(per-species `<Species>_Think` selectors, projectile spawners, player handlers,
shared helpers, velocity tables) are named too; see
[`entity_scripts.md`](entity_scripts.md). Good next targets: the shared internal
probes (`$59aa`, `$663c`, …) and the 8-direction locomotion cores
(`$5de3`–`$62e8`) those selectors call, and identifying the non-editor entity
types (`Mob12`–`Mob17`, spawn types 14/15 — likely bonus-stage monsters).
