# Entity script bytecode (bank `$03`)

Every tower entity — the player avatar, each monster, projectiles and FX — is
driven by a tiny **bytecode script** interpreted by the bank-`$03` engine (see
[`room_engine.md`](room_engine.md) for the engine and entity record). This
document specifies the script VM and its instruction set.

The scripts themselves occupy **`$71eb`–`$7d25`** (2874 bytes, ~1387
instructions across ~326 reachable labels) in bank `$03`.

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
**tile the `$71eb`–`$7d25` region exactly** — no gaps, no overlaps, and no
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

## Not yet done

The scripts are understood and disassembled but still stored as raw `db` bytes
in `src/room.asm`. The next step is to re-carve the region with assembler macros
(one per opcode) so each script reads — and edits — as the listing above while
assembling back to identical bytes, and to name each script by the entity/state
it implements (resolved through the selector that loads it).
