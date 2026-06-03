#!/usr/bin/env python3
"""Disassemble bank $03's per-entity script bytecode.

Bank $03 (src/room.asm, the tower in-room action engine) runs each entity as a
tiny bytecode "script" interpreted by RunEntityScript ($4042): it reads a 1-byte
opcode at the script PC (the `de` register), dispatches through EntityOpcodeTable
($4098, 41 entries -- ~35 used, the rest null), and each handler advances `de`
past its operands before fetching the next opcode. Scripts live in $71d5-$7d25
plus one isolated script at $7092 (see SCRIPT_RUNS).

This tool reconstructs the scripts by walking from every entry point
(`ld de, $7xxx` immediates in the behaviour selectors, plus every branch target)
and following control flow. Because the bytecode is a clean instruction stream,
the decoded instructions tile the region exactly -- that perfect tiling
(no gaps, no overlaps, no out-of-region control flow) is the round-trip proof
that the opcode spec below is correct.

The opcode spec was derived by reading every handler in src/room.asm
($40ea-$42ed); see docs/entity_scripts.md for the per-opcode semantics.

Usage:
    python3 tools/entity_script_disasm.py            # self-check (round-trip)
    python3 tools/entity_script_disasm.py --list     # full disassembly listing
"""
import argparse
import json
import re
import sys
from pathlib import Path

# The scripts occupy two runs: the main blob plus a 28-byte script at $7092 that
# only MonsterSpawnScriptTable reaches (surrounded by velocity tables, so it is
# walked explicitly rather than gap-filled).
SCRIPT_RUNS = ((0x7092, 0x70ae), (0x71d5, 0x7d25))
SCRIPT_LO, SCRIPT_HI = 0x7092, 0x7d25     # overall bank-$03-local bounds
# MonsterSpawnScriptTable (Data_01_79c4): entity type -> initial script.
SPAWN_TABLE = (0x7264, 0x727d, 0x7287, 0x7291, 0x74f1, 0x756c, 0x7615, 0x76a8,
               0x7713, 0x7777, 0x77b7, 0x77f7, 0x785c, 0x78d7, 0x797f, 0x79df,
               0x7a1f, 0x72b4, 0x71d5, 0x7092, 0x7a59, 0x7ac5, 0x7b48, 0x7bd6,
               0x7c21, 0x7caf)

# opcode -> (mnemonic, total_length, kind, target_operand_offset)
#   kind: cont  = linear, advance by length
#         term  = stop (despawn / kill script)
#         jmp   = unconditional branch, de := 16-bit target operand
#         br    = conditional branch: fall through AND follow 16-bit target
#         callc = operand is a native bank-$03 code address (entity calls asm)
#         dref  = operand is a data-table address (read, not followed)
SPEC = {
    0x00: ("ent_despawn",       1, "term",  None),  # state=0, yield (slot freed)
    0x01: ("ent_set_type",      2, "cont",  None),  # $ffb3 = type id
    0x02: ("ent_vel_x_zero",    1, "cont",  None),  # X velocity = 0
    0x03: ("ent_set_vel_x",     3, "cont",  None),  # X velocity = imm16
    0x04: ("ent_vel_x_indexed", 3, "dref",  1),     # X velocity = table[$ffd1&7]
    0x05: ("ent_set_xflip",     2, "cont",  None),  # $ffb6 bit7 (left/right facing)
    0x06: ("ent_set_facing",    2, "cont",  None),  # $ffb6 low bits (4-dir)
    0x07: ("ent_gfx",           2, "cont",  None),  # select sprite/anim (bank $04)
    0x08: ("ent_set_timer",     2, "cont",  None),  # $ffc6 = imm8
    0x09: ("ent_timer_tick",    1, "cont",  None),  # dec $ffc6, yield if running
    0x0a: ("ent_loop_timer",    3, "br",    1),     # dec $ffc6; if !=0 jump (yield)
    0x0b: ("ent_wait_timer",    1, "cont",  None),  # block until $ffc6 == 0
    0x0c: ("ent_yield",         1, "cont",  None),  # sleep one frame
    0x0d: ("ent_spawn_rel",     4, "cont",  None),  # spawn (xoff, yoff, type)
    0x0e: ("ent_set_flag2",     2, "cont",  None),  # $ffb6 bit2
    0x0f: ("ent_begin_action",  1, "cont",  None),  # $ffb4 bit7, $ffc7=$14
    0x10: ("ent_update_action", 1, "cont",  None),  # call UpdateActionTimer
    0x16: ("ent_call",          3, "callc", 1),     # call native asm, then resume
    0x17: ("ent_call_bank0",    4, "cont",  None),  # call bank-$00 $1150 (b, imm16)
    0x18: ("ent_load_b8",       3, "dref",  1),     # $ffb8 = [imm16]
    0x19: ("ent_and_b8",        2, "cont",  None),  # $ffb8 &= imm8 (set flags)
    0x1a: ("ent_test_b8",       2, "cont",  None),  # flags = $ffb8 & imm8
    0x1b: ("ent_cmp_b8",        2, "cont",  None),  # flags = cmp($ffb8, imm8)
    0x1c: ("ent_set_vel_y",     3, "cont",  None),  # $ffc1/$ffc2 = imm16
    0x1d: ("ent_wait_counter",  1, "cont",  None),  # block until $ffc1/$ffc2 == 0
    0x20: ("ent_jump",          3, "jmp",   1),     # de := imm16
    0x21: ("ent_jr_busy",       3, "br",    1),     # if $ffb7 bit0 (action busy)
    0x22: ("ent_jr_free",       3, "br",    1),     # if !$ffb7 bit0
    0x23: ("ent_jr_hit",        3, "br",    1),     # if $ffb7 bit1 (collision)
    0x24: ("ent_jr_nohit",      3, "br",    1),     # if !$ffb7 bit1
    0x25: ("ent_jr_timer0",     3, "br",    1),     # if $ffc6 == 0
    0x26: ("ent_jr_timer_nz",   3, "br",    1),     # if $ffc6 != 0
    0x27: ("ent_jr_b8_eq",      4, "br",    2),     # if $ffb8 == imm8 (probe result)
    0x28: ("ent_jr_b8_ne",      4, "br",    2),     # if $ffb8 != imm8
}


def load_rom(path="rom.gbc"):
    return Path(path).read_bytes()


def flat(ba):
    """bank-$03-local address ($4000-$7fff) -> flat ROM offset."""
    return 0xc000 + (ba - 0x4000)


def collect_entry_points(room_asm="src/room.asm", map_json="map.json"):
    """Script entry seeds. Before the macro-carve the selectors hold
    `ld de, $7xxx` immediates; after it they hold `ld de, <Label>` and the
    script-entry labels live in map.json. Union both so the tool works in
    either state; the fixpoint fills any script reached only via a table."""
    eps = set()
    txt = Path(room_asm).read_text()
    eps |= {int(m.group(1), 16)
            for m in re.finditer(r'ld de, \$([0-9a-f]{4})', txt)
            if int(m.group(1), 16) >= 0x7000}
    try:
        spec = json.loads(Path(map_json).read_text())
        for lab in spec.get("labels", []):
            a = lab["addr"]
            a = int(a, 16) if isinstance(a, str) else a
            ba = a - 0x8000          # flat ROM offset -> bank-$03 local
            if SCRIPT_LO <= ba < SCRIPT_HI:
                eps.add(ba)
    except (OSError, ValueError, KeyError):
        pass
    eps |= {v for v in SPAWN_TABLE if SCRIPT_LO <= v < SCRIPT_HI}
    return eps


def _walk(rom, roots):
    rd = lambda ba: rom[flat(ba)]
    rd16 = lambda ba: rom[flat(ba)] | (rom[flat(ba) + 1] << 8)
    insns, targets, code_refs, data_refs, errors = {}, set(roots), set(), set(), []
    work, seen = list(roots), set()
    while work:
        a = work.pop()
        while a not in seen:
            if not (0x7000 <= a < 0x8000):
                errors.append(f"PC left script region at ${a:04x}")
                break
            op = rd(a)
            if op not in SPEC:
                errors.append(f"unknown opcode ${op:02x} at ${a:04x}")
                break
            mnem, length, kind, toff = SPEC[op]
            insns[a] = (op, length, mnem, kind, toff)
            seen.add(a)
            if kind in ("br", "jmp"):
                tgt = rd16(a + toff)
                targets.add(tgt)
                if tgt not in seen:
                    work.append(tgt)
            elif kind == "callc":
                code_refs.add(rd16(a + toff))
            elif kind == "dref":
                data_refs.add(rd16(a + toff))
            if kind in ("term", "jmp"):
                break
            a += length
    return insns, targets, code_refs, data_refs, errors


def disassemble(rom, room_asm="src/room.asm"):
    """Walk the scripts. The main run ($71d5+) is gap-filled (promote each
    gap-start that is a valid opcode and not a known data-table address, until
    stable) since it is pure bytecode; the isolated low script (< $71d5) is
    walked plainly because it is surrounded by velocity tables."""
    rd = lambda ba: rom[flat(ba)]
    roots = collect_entry_points(room_asm)
    main_roots = {r for r in roots if r >= 0x71d5}
    low_roots = {r for r in roots if r < 0x71d5}
    while True:
        insns, targets, code_refs, data_refs, errors = _walk(rom, main_roots)
        if errors:
            return insns, targets, code_refs, data_refs, errors
        addrs = sorted(insns)
        lo, hi = addrs[0], addrs[-1] + insns[addrs[-1]][1]
        covered = {a + i for a in addrs for i in range(insns[a][1])}
        new = set()
        prev = None
        for x in range(lo, hi):
            if x in covered:
                prev = None
                continue
            if prev is None and rd(x) in SPEC and x not in data_refs:
                new.add(x)
            prev = x
        new -= main_roots
        if not new:
            break
        main_roots |= new
    # merge the isolated low script(s)
    li, lt, lc, ld_, le = _walk(rom, low_roots)
    insns.update(li)
    return (insns, targets | lt, code_refs | lc, data_refs | ld_, errors + le)


def self_check(rom, room_asm="src/room.asm"):
    insns, targets, code_refs, data_refs, errors = disassemble(rom, room_asm)
    if errors:
        print("DECODE ERRORS:")
        for e in errors[:50]:
            print("  ", e)
        return 1
    covered = {a + i for a in insns for i in range(insns[a][1])}
    expected = {x for lo, hi in SCRIPT_RUNS for x in range(lo, hi)}
    total = sum(insns[a][1] for a in insns)
    overlaps = total - len(covered)
    drefs_in = [x for x in data_refs if x in expected]
    ok = (overlaps == 0 and covered == expected and not drefs_in)
    print(f"scripts: {len(insns)} instructions, {len(targets)} labels")
    print(f"runs:    {', '.join(f'${lo:04x}-${hi:04x}' for lo, hi in SCRIPT_RUNS)} "
          f"({len(expected)} bytes), overlaps={overlaps}, "
          f"missing={len(expected - covered)}, extra={len(covered - expected)}")
    print(f"refs:    {len(code_refs)} native calls, {len(data_refs)} data tables "
          f"({len(drefs_in)} inside region)")
    print("ROUND-TRIP:", "OK -- bytecode tiles both runs exactly" if ok else "FAIL")
    return 0 if ok else 1


def render(rom, room_asm="src/room.asm"):
    rd = lambda ba: rom[flat(ba)]
    rd16 = lambda ba: rom[flat(ba)] | (rom[flat(ba) + 1] << 8)
    insns, targets, code_refs, data_refs, errors = disassemble(rom, room_asm)
    if errors:
        return self_check(rom, room_asm)
    labels = {a: f"Script_{a:04x}" for a in sorted(targets)}
    out = []
    for a in sorted(insns):
        op, length, mnem, kind, toff = insns[a]
        if a in labels:
            out.append(f"\n{labels[a]}:")
        if kind in ("br", "jmp"):
            tgt = rd16(a + toff)
            tlabel = labels.get(tgt, f"${tgt:04x}")
            arg = (f"${rd(a + 1):02x}, {tlabel}" if op in (0x27, 0x28) else tlabel)
        elif kind == "callc":
            arg = f"Func_03_{rd16(a + toff):04x}"
        elif kind == "dref":
            arg = f"${rd16(a + toff):04x}"
        elif length == 3 and op in (0x03, 0x1c):
            arg = f"${rd(a + 2):02x}{rd(a + 1):02x}"
        else:
            arg = ", ".join(f"${rd(a + i):02x}" for i in range(1, length))
        raw = " ".join(f"{rd(a + i):02x}" for i in range(length))
        out.append(f"  {a:04x}: {raw:<12}  {mnem} {arg}".rstrip())
    print("\n".join(out))
    return 0


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--rom", default="rom.gbc")
    ap.add_argument("--room", default="src/room.asm")
    ap.add_argument("--list", action="store_true", help="print full disassembly")
    args = ap.parse_args(argv)
    rom = load_rom(args.rom)
    if args.list:
        return render(rom, args.room)
    return self_check(rom, args.room)


if __name__ == "__main__":
    sys.exit(main())
