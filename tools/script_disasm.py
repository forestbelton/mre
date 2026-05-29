#!/usr/bin/env python3
"""Script disassembler for the Monster Rancher Explorer text-engine bytecode.

Given a flat ROM range, emits a hand-readable RGBASM source file using the
macros in include/script.inc. Output goes to stdout; caller redirects to
src/scripts/<name>.asm.

The tool only encodes the engine's opcode shapes (see docs/text_engine.md).
It does not understand game-specific structure: pass --label NAME=ADDR for
any address worth naming (entry point, sub-handlers, etc.).

Example:
    python3 tools/script_disasm.py --rom rom.gbc \\
        --start 0x60272 --end 0x61321 \\
        --prefix pashute --section-name pashute_060272 \\
        --label PashuteScript=0x60272 \\
        --label PashuteMenu=0x61057 \\
        --header "Pashute (monster shrine priest)" \\
        > src/scripts/pashute.asm

Bank is auto-derived from --start (start >> 14); HOME-bank addresses
(start < $4000) emit ROM0[start], otherwise ROMX[bank-addr], BANK[bank].

`$08` table sizes are inferred:
  1. exact fall-through (first entry == byte right after the table); else
  2. smallest N in [2..8] where the post-table byte parses as a plausible
     opcode.
If neither works, the $08 byte is emitted as a raw `db` and the caller
needs to hand-edit.
"""

import argparse
import sys

# Operand byte counts (NOT including the opcode itself). $08 is variable.
OP_LEN = {
    0x01: 4, 0x02: 0, 0x03: 0, 0x04: 0, 0x05: 4,
    0x06: 2, 0x07: 3,
    0x09: 3, 0x0A: 5, 0x0B: 5, 0x0C: 1, 0x0D: 0, 0x0E: 3,
    0x0F: 2, 0x10: 1, 0x11: 2,
    0xFF: 0,
}


def parse_int(s):
    s = s.strip()
    if s.startswith('$'):
        return int(s[1:], 16)
    if s.lower().startswith('0x'):
        return int(s[2:], 16)
    return int(s)


def main():
    ap = argparse.ArgumentParser(
        description="Disassemble a text-engine script range to RGBASM.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    ap.add_argument('--rom', default='rom.gbc',
                    help='ROM image (default: rom.gbc)')
    ap.add_argument('--start', required=True,
                    help='Start flat ROM offset (hex $XXXX, 0xXXXX, or decimal)')
    ap.add_argument('--end', default=None,
                    help='End flat ROM offset (exclusive); default: '
                         'auto-detect via reachability scan from --start')
    ap.add_argument('--prefix', required=True,
                    help='Auto-label prefix for unnamed targets (e.g. "pashute")')
    ap.add_argument('--section-name', required=True,
                    help='SECTION directive name (e.g. "pashute_060272")')
    ap.add_argument('--label', action='append', default=[],
                    help='Override label name: NAME=ADDR (repeatable)')
    ap.add_argument('--header', default='',
                    help='Doc comment to insert at the top (multi-line OK)')
    args = ap.parse_args()

    rom = open(args.rom, 'rb').read()
    start = parse_int(args.start)
    bank = start >> 14
    bank_base = bank * 0x4000
    # `end` is finalised after the reachability scan below, since the
    # natural script end isn't known until then. The provided --end is
    # used as a hard upper bound; if omitted, we use the bank boundary.
    provided_end = parse_int(args.end) if args.end is not None \
        else bank_base + 0x4000

    def to_bank_addr(flat):
        return (flat - bank_base) + (0x4000 if bank > 0 else 0)

    def to_flat(ba):
        if bank == 0:
            return ba
        return bank_base + (ba - 0x4000)

    label_overrides = {}
    for spec in args.label:
        if '=' not in spec:
            sys.exit(f"--label requires NAME=ADDR, got {spec!r}")
        name, addr = spec.split('=', 1)
        label_overrides[parse_int(addr)] = name

    def label_for(flat):
        if flat in label_overrides:
            return label_overrides[flat]
        return f"{args.prefix}_{to_bank_addr(flat):04x}"

    def plausible_opcode(off):
        if off >= len(rom):
            return False
        b = rom[off]
        if b == 0x00:
            return False
        if b in OP_LEN:
            return True
        if 0x20 <= b < 0x80:
            return True
        return False

    def size_table(ts):
        # Look for *any* entry whose flat address equals the table end for
        # some N — that entry is the fall-through case and tells us N.
        # (Earlier versions only checked entry 0; the menu at $0621BB in
        # the trade house puts the fall-through at index 1.)
        for n in range(1, 17):
            table_end = ts + 2 * n
            if not plausible_opcode(table_end):
                continue
            for i in range(n):
                ei = rom[ts + 2 * i] | (rom[ts + 2 * i + 1] << 8)
                if to_flat(ei) == table_end:
                    return n
        # No fall-through entry. Try N=2..8 in order, preferring N values
        # where the post-table byte is an actual control opcode — text
        # bytes are also "plausible" but happen to also be plausible just
        # inside a table whose real size is larger. Naji's Ask submenu
        # ($0635A2, N=3) is the canonical case: ROM[$0635A6] = $66 ('f',
        # text) so N=2 looks plausible too; ROM[$0635A8] = $0E (renderer),
        # which is a real opcode, so N=3 wins.
        for n in (2, 3, 4, 5, 6, 7, 8):
            te = ts + 2 * n
            if te < len(rom) and rom[te] in OP_LEN:
                return n
        for n in (2, 3, 4, 5, 6, 7, 8):
            if plausible_opcode(ts + 2 * n):
                return n
        return None

    # Reachability scan: walk from `start` following all control flow,
    # stopping at $FF/$06 (no fall-through). The max byte address we
    # consume is the natural end of the script. Bytes after it inside
    # provided_end are usually trailing Z80 helpers from $07 FAR_CALLs.
    def reachable_max_byte():
        visited = set()
        wl = [start]
        max_byte = start
        while wl:
            pc = wl.pop()
            while pc < provided_end and pc < len(rom) and pc not in visited:
                visited.add(pc)
                b = rom[pc]
                # Match the engine dispatcher's order: $FF first (terminates),
                # then text ($20+), then $08 special, then table opcodes.
                # Doing >=$20 before checking $FF would treat $FF as text and
                # walk straight past every END marker in the script.
                if b == 0xFF:
                    max_byte = max(max_byte, pc); break
                if b >= 0x20:
                    max_byte = max(max_byte, pc); pc += 1; continue
                if b == 0x08:
                    ts = pc + 3
                    n = size_table(ts)
                    if n is None:
                        max_byte = max(max_byte, pc); break
                    for i in range(n):
                        e = rom[ts + 2 * i] | (rom[ts + 2 * i + 1] << 8)
                        wl.append(to_flat(e))
                    max_byte = max(max_byte, ts + 2 * n - 1)
                    break  # unconditional dispatch
                if b not in OP_LEN:
                    break
                # OP_LEN[b] is *operand* bytes; total instruction size is 1 + operands.
                size = 1 + OP_LEN[b]
                max_byte = max(max_byte, pc + size - 1)
                if b == 0x06:
                    t = rom[pc + 1] | (rom[pc + 2] << 8)
                    wl.append(to_flat(t)); break
                if b in (0x0A, 0x0B):
                    t = rom[pc + 4] | (rom[pc + 5] << 8)
                    wl.append(to_flat(t))
                pc += size
        return max_byte

    # If the user passed --end, honour it; otherwise auto-detect via
    # reachability from --start. The auto-detect stops at the first $FF
    # reached with an empty worklist, so NPCs with multiple independently-
    # dispatched sub-scripts (e.g. Kalum's pre/win/lose bytecode trio
    # share a contiguous ROM region but have no script-level path between
    # them) need an explicit --end.
    if args.end is not None:
        end = parse_int(args.end)
    else:
        end = reachable_max_byte() + 1

    targets = {start}
    items = []
    pc = start
    text_start = None
    while pc < end:
        b = rom[pc]
        if b == 0xFF:
            if text_start is not None:
                items.append((text_start, "TEXT", rom[text_start:pc]))
                text_start = None
            items.append((pc, "END", None))
            pc += 1
        elif b >= 0x20:
            if text_start is None:
                text_start = pc
            pc += 1
        else:
            if text_start is not None:
                items.append((text_start, "TEXT", rom[text_start:pc]))
                text_start = None
            if b == 0x08:
                ts = pc + 3
                n = size_table(ts)
                if n is None:
                    items.append((pc, "RAW", b))
                    pc += 1
                    continue
                wlo = rom[pc + 1]; whi = rom[pc + 2]
                entries = []
                for i in range(n):
                    e = rom[ts + 2 * i] | (rom[ts + 2 * i + 1] << 8)
                    entries.append(e)
                    targets.add(to_flat(e))
                items.append((pc, "JT", (wlo | (whi << 8), entries)))
                pc = ts + 2 * n
            elif b == 0x01:
                pos = rom[pc + 1] | (rom[pc + 2] << 8)
                items.append((pc, "OPEN_TEXTBOX", (pos, rom[pc + 3], rom[pc + 4])))
                pc += 5
            elif b == 0x06:
                t = rom[pc + 1] | (rom[pc + 2] << 8)
                targets.add(to_flat(t))
                items.append((pc, "GOTO", t))
                pc += 3
            elif b == 0x0A:
                w = rom[pc + 1] | (rom[pc + 2] << 8); v = rom[pc + 3]
                t = rom[pc + 4] | (rom[pc + 5] << 8); targets.add(to_flat(t))
                items.append((pc, "IFEQ", (w, v, t)))
                pc += 6
            elif b == 0x0B:
                w = rom[pc + 1] | (rom[pc + 2] << 8); v = rom[pc + 3]
                t = rom[pc + 4] | (rom[pc + 5] << 8); targets.add(to_flat(t))
                items.append((pc, "IFNEQ", (w, v, t)))
                pc += 6
            elif b == 0x07:
                items.append((pc, "FARCALL",
                             (rom[pc + 1] | (rom[pc + 2] << 8), rom[pc + 3])))
                pc += 4
            elif b == 0x09:
                items.append((pc, "WRITE",
                             (rom[pc + 1] | (rom[pc + 2] << 8), rom[pc + 3])))
                pc += 4
            elif b == 0x0C:
                items.append((pc, "CYCLE", rom[pc + 1]))
                pc += 2
            elif b == 0x0E:
                items.append((pc, "RENDERER",
                             (rom[pc + 1] | (rom[pc + 2] << 8), rom[pc + 3])))
                pc += 4
            elif b == 0x0F:
                items.append((pc, "DECIMAL", rom[pc + 1] | (rom[pc + 2] << 8)))
                pc += 3
            elif b == 0x10:
                items.append((pc, "REPEAT_CHAR", rom[pc + 1]))
                pc += 2
            elif b == 0x11:
                items.append((pc, "INDEXED_STR", rom[pc + 1] | (rom[pc + 2] << 8)))
                pc += 3
            elif b == 0x04:
                items.append((pc, "WAIT", None)); pc += 1
            elif b == 0x0D:
                items.append((pc, "NL", None)); pc += 1
            elif b == 0x03:
                items.append((pc, "YN", None)); pc += 1
            elif b == 0x02:
                items.append((pc, "ANCHOR", None)); pc += 1
            else:
                items.append((pc, "RAW", b)); pc += 1
    if text_start is not None:
        items.append((text_start, "TEXT", rom[text_start:pc]))

    if args.header:
        for line in args.header.split('\n'):
            print(f"; {line}")
        print(";")
    print("; Carved out of analyzed.asm via map.json; see docs/text_engine.md")
    print("; for the bytecode reference. Initial dump produced by")
    print("; tools/script_disasm.py — hand-curate freely; the extractor's")
    print("; append-only rule on non-auto-managed files preserves your edits.")
    print()
    print('INCLUDE "script.inc"')
    print()
    if bank == 0:
        print(f'SECTION "{args.section_name}", ROM0[${start:04x}]')
    else:
        print(f'SECTION "{args.section_name}", '
              f'ROMX[${to_bank_addr(start):04x}], BANK[${bank:02x}]')
    print()

    for flat, kind, fields in items:
        if flat in targets:
            lbl = label_for(flat)
            if lbl.startswith('.'):
                print(f"{lbl}:")
            else:
                print()
                print(f"{lbl}:")
        if kind == "WAIT":
            print("    SCRIPT_WAIT")
        elif kind == "NL":
            print("    SCRIPT_NEWLINE")
        elif kind == "YN":
            print("    SCRIPT_YN_CUE")
        elif kind == "END":
            print("    SCRIPT_END")
        elif kind == "ANCHOR":
            print("    SCRIPT_ANCHOR")
        elif kind == "OPEN_TEXTBOX":
            pos, w, h = fields
            print(f"    SCRIPT_OPEN_TEXTBOX ${pos:04x}, ${w:02x}, ${h:02x}")
        elif kind == "GOTO":
            print(f"    SCRIPT_GOTO {label_for(to_flat(fields))}")
        elif kind == "IFEQ":
            w, v, t = fields
            print(f"    SCRIPT_IF_EQ ${w:04x}, ${v:02x}, {label_for(to_flat(t))}")
        elif kind == "IFNEQ":
            w, v, t = fields
            print(f"    SCRIPT_IF_NEQ ${w:04x}, ${v:02x}, {label_for(to_flat(t))}")
        elif kind == "FARCALL":
            a, bk = fields
            print(f"    SCRIPT_FAR_CALL ${a:04x}, ${bk:02x}")
        elif kind == "RENDERER":
            a, bk = fields
            print(f"    SCRIPT_RENDERER ${a:04x}, ${bk:02x}")
        elif kind == "WRITE":
            w, v = fields
            print(f"    SCRIPT_WRITE_WRAM ${w:04x}, ${v:02x}")
        elif kind == "CYCLE":
            print(f"    SCRIPT_CYCLE {fields}")
        elif kind == "DECIMAL":
            print(f"    SCRIPT_DECIMAL ${fields:04x}")
        elif kind == "REPEAT_CHAR":
            print(f"    SCRIPT_REPEAT_CHAR {fields}")
        elif kind == "INDEXED_STR":
            print(f"    SCRIPT_INDEXED_STR ${fields:04x}")
        elif kind == "JT":
            w, entries = fields
            lbls = ", ".join(label_for(to_flat(e)) for e in entries)
            print(f"    SCRIPT_JUMP_TABLE ${w:04x}, {lbls}")
        elif kind == "TEXT":
            s = fields.decode('latin-1')
            esc = s.replace('\\', '\\\\').replace('"', '\\"')
            print(f'    db "{esc}"')
        elif kind == "RAW":
            print(f"    db ${fields:02x}")


if __name__ == '__main__':
    main()
