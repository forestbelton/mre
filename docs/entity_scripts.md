# Entity script bytecode (bank `$03`)

Every tower entity — the player avatar, each monster, projectiles and FX — is
driven by a tiny **bytecode script** interpreted by the bank-`$03` engine (see
[`room_engine.md`](room_engine.md) for the engine and entity record). This
document specifies the script VM and its instruction set.

The scripts occupy **`$71d5`–`$7d25`** plus one isolated 28-byte script at
**`$7092`** (~1410 instructions across ~332 labels) in bank `$03`. The `$7092`
script and the `$71d5` one are spawn types 15 and 14 — non-editor entities
reached only through `MonsterSpawnScriptTable`, hidden among the velocity tables
below the selector-reachable region.

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

The scripts are carved into **`src/entity_scripts.asm`** as readable, editable
source: one assembler macro per opcode (defined in `include/entity_script.inc`),
labels per script, and `.l`-local labels for intra-script branches. It assembles
back to the exact ROM bytes (`make verify`). Example:

```
Mob1_Windup:
    ent_set_type    $03
    ent_vel_x_zero
    ent_gfx         $02
    ent_call        $4461        ; native attack wind-up
    ent_set_timer   $1e
.l752c:
    ent_update_action
    ent_jr_busy     Mob1_Hurt
    ent_loop_timer  .l752c
    ent_set_xflip   $ff
    ent_jump        Mob1_Chase
```

The selectors in `room.asm` still load a script by raw address (`ld de, $7xxx`);
the matching label is in `entity_scripts.asm`.

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

| id | species | group entry | | id | species | group entry |
|----|---------|-------------|-|----|---------|-------------|
| 0 | Tacopi | `$74f1` | | 7 | Ghost | `$77f7` |
| 1 | Jell | `$756c` | | 8 | Puncho | `$785c` |
| 2 | Naga | `$7615` | | 9 | Psylora | `$78d7` |
| 3 | Dino | `$76a8` | | 10 | Ducken | `$797f` |
| 4 | Plant | `$7713` | | 11 | FlameRed | `$79df` |
| 5 | Henger | `$7777` | | 12 | FlameBlue | `$7a1f` |
| 6 | Joker | `$77b7` | | | | |

So each monster's scripts are named `<Species>_<Role>` (e.g. `Ducken_FireR`,
`Naga_Windup`). Table slots 16–21 (`Mob12`–`Mob17`) are non-editor entity types
(bonus-stage / internal) with no legend names, so they keep numbered prefixes.
The player avatar is fully resolved (walk/push/pull/grab/carry/throw/kick).
