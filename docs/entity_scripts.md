# Entity script bytecode (bank `$03`)

Every tower entity — the player avatar, each monster, projectiles and FX — is
driven by a tiny **bytecode script** interpreted by the bank-`$03` engine (see
[`room_engine.md`](room_engine.md) for the engine and entity record). This
document specifies the script VM and its instruction set.

The scripts occupy **`$7046`–`$7fec`** in bank `$03` (with the velocity tables
they read at `$6fc4`–`$7046` just above), split by entity class across
`src/room/scripts/{fx,environment,player,monster,boss}.asm`.
Roughly by address: the **FX/animation library** (`$7046`–`$71c9`: `Popup_*`,
`Glide_*`, `Burst*`, `Vanish_*`, `Fly_*`, `Shatter_*`, dispatched by id from
bank-1 pointer tables at `$79a8..`), then the **non-editor spawns** (`ZanExitFlame_*`,
`Spawn3F_*`), the **player + editor monsters** (`$723a` on), and the
**five tower bosses** (`$7d36`–`$7fec`, engine types `$50`–`$55`).

`$71d5` and `$7092` are `MonsterSpawnScriptTable` slots 18/19 ($ffb0 `$3e`/`$3f`)
— outside the floor monster-array path (see "Resolving monster species"). `$71d5`
(type `$3e`) is **Zan's exit flame** (`ZanExitFlame_Drop`): `SpawnFloorFlameOrFX`
spawns it when `wActiveFloor == $05`, which on a boss floor is the boss index 5
(Zan, after floor 60) — *not* floor 5; the boss-floor remap `Func_01_48af` sets
`wActiveFloor` to the boss index 1–5. It drops to the boss kill cell and stamps
the exit tile (the other four bosses just get stairs).
`$7092` (type `$3f`) has no found spawn site and stays structural as
`Spawn3F_Sweep`.

## The VM

`RunEntityScript` (`$4042`) is a threaded interpreter. The entity's **script
program counter** is register `de` (saved in record field +$18 / HRAM
`$ffc8`-`$ffc9` between frames):

```
RunEntityScript:
    ld a, [de]              ; fetch 1-byte opcode at the PC
    add a, a               ; *2
    ld hl, EntityOpcodeTable
    add hl, <a>
    ld a, [hl+] / ld h,[hl] / ld l,a
    jp hl                  ; jump to the handler
```

`EntityOpcodeTable` (`$4098`) is **41 little-endian handler pointers** (opcodes
`$00`–`$28`; entries `$11`–`$15`, `$1e`, `$1f` are null and unused). Each handler
reads its operands with `inc de` / `ld a,[de]`, does its work, and tail-jumps
back to `RunEntityScript` to fetch the next opcode — or to `EndEntityFrame`
(`$404f`), the per-frame **yield** that saves `de` and returns control to the
main loop until next frame.

Because the bytecode is a clean instruction stream, the decoded instructions
**tile both script runs exactly** — no gaps, no overlaps, and no
control flow leaving the region. That perfect tiling is the round-trip proof
that the instruction lengths below are correct (`tools/entity_script_disasm.py`
checks it).

## Instruction set

Operands are little-endian. "len" is the total instruction length in bytes.
`imm16` targets shown as a label are script addresses; `→asm` operands are
native bank-`$03` code addresses; `→data` operands point at parameter tables in
code space (outside the script region).

| op | len | mnemonic | effect |
|----|-----|----------|--------|
| `$00` | 1 | `ent_despawn` | set state byte = 0 (free the slot) and yield — **terminator** |
| `$01` | 2 | `ent_set_type t` | entity type id `$ffb3 = t` |
| `$02` | 1 | `ent_vel_x_zero` | X velocity = 0 |
| `$03` | 3 | `ent_set_vel_x v16` | X velocity = signed `v16` |
| `$04` | 3 | `ent_vel_x_indexed →data` | X velocity = `table[$ffd1 & 7]` |
| `$05` | 2 | `ent_set_xflip a` | set/clear `$ffb6` bit7 (left/right facing) |
| `$06` | 2 | `ent_set_facing a` | set `$ffb6` low bits (4-direction) |
| `$07` | 2 | `ent_gfx a` | select sprite/animation `a` (via bank `$04`) |
| `$08` | 2 | `ent_set_timer n` | `$ffc6 = n` |
| `$09` | 1 | `ent_timer_tick` | decrement `$ffc6`; yield this frame if still running |
| `$0a` | 3 | `ent_loop_timer L` | decrement `$ffc6`; if non-zero jump to `L` (yields) — **branch** |
| `$0b` | 1 | `ent_wait_timer` | block until `$ffc6` reaches 0 (re-runs each frame) |
| `$0c` | 1 | `ent_yield` | sleep exactly one frame |
| `$0d` | 4 | `ent_spawn_rel xo, yo, t` | spawn entity type `t` at offset `(xo,yo)` |
| `$0e` | 2 | `ent_set_flag2 a` | set/clear `$ffb6` bit2 |
| `$0f` | 1 | `ent_begin_action` | `$ffb4` bit7 = 1, action timer `$ffc7 = $14` |
| `$10` | 1 | `ent_update_action` | call `UpdateActionTimer` |
| `$16` | 3 | `ent_call →asm` | call a native bank-`$03` routine, then resume the script |
| `$17` | 4 | `ent_call_bank0 b, w16` | call bank-`$00` `$1150` with `b`, `w16` |
| `$18` | 3 | `ent_load_b8 →data` | `$ffb8 = [w16]` (load a probe/result byte) |
| `$19` | 2 | `ent_and_b8 m` | `$ffb8 &= m` (and set flags) |
| `$1a` | 2 | `ent_test_b8 m` | flags = `$ffb8 & m` |
| `$1b` | 2 | `ent_cmp_b8 v` | flags = `cmp($ffb8, v)` |
| `$1c` | 3 | `ent_set_vel_y v16` | Y velocity / counter `$ffc1/$ffc2 = v16` |
| `$1d` | 1 | `ent_wait_counter` | block until `$ffc1/$ffc2` reaches 0 |
| `$20` | 3 | `ent_jump L` | `de := L` — **unconditional branch** |
| `$21` | 3 | `ent_jr_busy L` | branch if `$ffb7` bit0 (action busy) |
| `$22` | 3 | `ent_jr_free L` | branch if not `$ffb7` bit0 |
| `$23` | 3 | `ent_jr_hit L` | branch if `$ffb7` bit1 (collision) |
| `$24` | 3 | `ent_jr_nohit L` | branch if not `$ffb7` bit1 |
| `$25` | 3 | `ent_jr_timer0 L` | branch if `$ffc6 == 0` |
| `$26` | 3 | `ent_jr_timer_nz L` | branch if `$ffc6 != 0` |
| `$27` | 4 | `ent_jr_b8_eq v, L` | branch if `$ffb8 == v` (probe result match) |
| `$28` | 4 | `ent_jr_b8_ne v, L` | branch if `$ffb8 != v` |

The conditional branches `$21`–`$28` test the move/collision result bits
(`$ffb7`, set by the locomotion primitives) or the **behaviour-selector result**
`$ffb8` — the AI/probe code that the selectors load with `ent_load_b8` or that
the native locomotion routines leave behind. This is how a script reacts to the
world: *"if the probe says state 1, go run that script."*

## How a script is shaped

Scripts are small state machines. The recurring idiom is **set up appearance and
motion, then loop a per-frame `ent_call` + `ent_yield`**, branching out when a
condition fires:

```
Script_72df:                 ; player avatar, type 0 (idle)
    ent_set_type   $00
    ent_vel_x_zero
    ent_gfx        $01
Script_72e4:
    ent_call       Func_03_470a   ; native per-frame logic (read input, move)
    ent_yield
    ent_jump       Script_72e4    ; loop forever (native code switches scripts)

Script_722f:                 ; a monster decision loop
    ent_call       Func_03_6f43   ; probe -> result in $ffb8
    ent_jr_b8_eq   $01, Script_723a   ; result 1 -> attack script
    ent_yield
    ent_jump       Script_722f
```

The `ent_set_type $00/$01/$02/$03 …` values at script heads are the entity's
**state enum**; `ent_vel_x_indexed`/`ent_call` operands point at the per-type
parameter tables and native helpers in `$5xxx`–`$6xxx`.

## Tooling

`tools/entity_script_disasm.py` reconstructs and verifies the scripts:

```
python3 tools/entity_script_disasm.py          # round-trip self-check
python3 tools/entity_script_disasm.py --list    # full annotated disassembly
```

It walks from every entry point (`ld de, $7xxx` in the selectors) plus every
branch target, then fixpoint-fills any script reached only from a pointer table,
and asserts the decode tiles `$71eb`–`$7d25` exactly.

## Source form

The scripts are carved into **`src/room/scripts/`** (one file per entity class:
`fx`, `environment`, `player`, `monster`, `boss`) as readable, editable
source: one assembler macro per opcode (defined in `include/entity_script.inc`),
labels per script, and `.l`-local labels for intra-script branches. The
`ent_call` / `ent_vel_x_indexed` / `ent_call_bank0` operands resolve to the named
native routines and data tables in `room.asm` (see below). It assembles back to
the exact ROM bytes (`make verify`). Example:

```
Tacopi_Windup:
    ent_set_type    $03
    ent_vel_x_zero
    ent_gfx         $02
    ent_call        MonsterBreakTileInFront
    ent_set_timer   $1e
.l752c:
    ent_update_action
    ent_jr_busy     Tacopi_Hurt
    ent_loop_timer  .l752c
    ent_set_xflip   $ff
    ent_jump        Tacopi_Chase
```

### Native helpers

The ~110 bank-`$03` routines / data tables the scripts reach are named in
`map.json` and defined in `room.asm`: per-species AI selectors
(`<Species>_Think`, `Psylora_MoveDir*`), projectile spawners (`Ducken_FireMissileA`,
`Plant_FireMissile`, ...), player input/action handlers (`Player_WalkThinkRight`,
`Player_SpawnAttackFront`, ...), shared engine helpers (`MonsterBreakTileInFront`,
`FacePlayerX`, `MonsterBreakTileUnder`), the velocity tables (`MonsterWalkVel`,
`PlayerWalkVelR`, ...), and the bank-`$01` tile-draw routines reached by
`ent_call_bank0` (`DrawStairTileClosedL`, ...).

The selectors in `room.asm` still load a script by raw address (`ld de, $7xxx`);
the matching label is under `src/room/scripts/`.

### Resolving monster species

A freshly-spawned entity's initial script is looked up by type in
`MonsterSpawnScriptTable` (`Data_01_79c4`, bank `$01`): a 26-entry table of
script pointers. The first 4 slots are warp/door FX; from slot 4 the entries are
the editor-placeable monsters, in `room.inc`'s `enum MONSTER` order — i.e.
**table index = species id + 4**. `SpawnFloorMonsters` (`layout.asm`) reads the
floor's `arr1[gfxIndex]` species id and spawns through it.

The species→group mapping is confirmed by two unambiguous behaviour matches from
the level-editor legend (`data_05d278.bin`): **Ducken** ("sticks to wall, fires
missiles") is the stationary turret group, and **Psylora** ("moves along wall")
is the 8-direction walker — both land exactly where index = id + 4 predicts,
with the flyers (Henger/Joker/Ghost) and shooters (Plant/Dino) corroborating.

| id | species | entry | | id | species | entry |
|----|---------|-------|-|----|---------|-------|
| 0 | Tacopi | `$74f1` | | 10 | Ducken | `$797f` |
| 1 | Jell | `$756c` | | 11 | FlameRed | `$79df` |
| 2 | Naga | `$7615` | | 12 | FlameBlue | `$7a1f` |
| 3 | Dino | `$76a8` | | 14 | **Tiger** | `$7a59` |
| 4 | Plant | `$7713` | | 15 | **Mocchi** | `$7ac5` |
| 5 | Henger | `$7777` | | 16 | **Hare** | `$7b48` |
| 6 | Joker | `$77b7` | | 17 | **Gali** | `$7bd6` |
| 7 | Ghost | `$77f7` | | 18 | **Golem** | `$7c21` |
| 8 | Puncho | `$785c` | | 19 | **Suezo** | `$7caf` |
| 9 | Psylora | `$78d7` | | | | |

Species **14–19 are the friendly Monster Rancher breeds** (Tiger, Mocchi, Hare,
Gali, Golem, Suezo) that appear on the bonus stages — named in `room.inc`'s
`enum MONSTER` and confirmed by the floor scan (special floors 83–88). The index
relation is `table_slot = $ffb0 - $2c`, and `SpawnFloorMonsters` gives a monster
`$ffb0 = species + $30`, **plus 2 if species ≥ 14** (`cp $3e; jr c; add $02`).
That `+2` skips `$ffb0 = $3e/$3f`, so the friendly breeds land in slots 20–25
(not 18/19). Slots 18/19 (`$71d5`, `$7092`) therefore hold no *floor* monster;
`$71d5` is instead Zan's exit flame (type `$3e`, `ZanExitFlame_Drop`, spawned on
the Zan boss floor) and `$7092` (type `$3f`, `Spawn3F_Sweep`) has no found spawn
site.

So each monster's scripts are named `<Species>_<Role>` (e.g. `Ducken_FireR`,
`Suezo_Chase`). The player avatar is fully resolved (walk/push/pull/grab/carry/
throw/kick).

### FX / animation library (`$7046`–`$71c9`)

Self-contained visual-effect scripts owned by no entity; dispatched by id from
the bank-1 pointer tables at `$79a8..$79c2`. Names encode content, not a verified
semantic (the gfx ids index an unmapped sprite table), so confidence is medium:

- **`Popup_FrameNN`** — stop, show one gfx frame `NN`, wait, despawn.
- **`Glide_ToTargetX/Y`** — init + per-frame easing mover (`$4faa`+`$5059` /
  `$4f20`+`$5013`) that interpolates the sprite along a curve to a stored target.
- **`Burst10_*` / `Burst19_*`** — two 8-direction fans (gfx `$11`–`$18` → finisher
  gfx `$10`; gfx `$1a`–`$21` → gfx `$19`); the finisher calls `$4c5f`, which
  scatters child sprites in the facing direction.
- **`Vanish_FrameNN`** — sequential one-shot vanish frames (gfx `$30`–`$35`).
- **`Fly_FrameNN`** — horizontal drift sprites (`set_vel_x`, then loop).
- **`Shatter_Spawn8` / `Shatter_DriveFragments`** — `$55a1` spawns 8 fragment
  sprites + a capstone; `$55e7` animates them per frame.

### Tower bosses (`$7d36`–`$7fec`, engine types `$50`–`$55`)

The five tower bosses, fought on the **unnumbered boss floors** entered after
exiting floors 10/20/40/50/60:

| Type | Boss | After floor | Notes |
|---|---|---|---|
| `$50` | **Selketo** | 10 | digs/breaks terrain tiles |
| `$51` | **Ferious** | 20 | seeks a target tile |
| `$52` | **Punisher** | 40 | digs + fires projectiles |
| `$53` | **Dragon** (head) | 50 | fires projectiles; its death gates the exit |
| `$54` | **DragonBody** | 50 | 2nd part of the Dragon; wide beam/attached-sprite sweep |
| `$55` | **Zan** | 60 | final boss; charges the player, spawns a child |

They have their own sprite/init group `$30`–`$35` (parallel to the friendly
breeds at `$40`–`$45`) and are **not** placed by the normal `arr2` floor spawner.
The boss-floor remap `Func_01_48af` maps `wActiveFloor` 10/20/40/50/60 → boss
index 1–5; in that mode `Func_01_42e6` reads the boss spawn-list table
`Data_01_4335` (bank `$01`) by `(index-1)` and spawns each listed type via
`SpawnEntity` — the only place types `$50`–`$55` reach `SpawnEntity` (data-driven,
so there is no `ld a,$5x` in code). Each boss's death routine writes its kill cell
to `$c530`/`$c531`; `SpawnFloorFlameOrFX` reads that to drop the floor exit (plain
stairs for bosses 1–4, the animated `ZanExitFlame_Drop` for Zan). The Dragon is
the only two-part boss (`$53` head gates the exit, `$54` body does not).
