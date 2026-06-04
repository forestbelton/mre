#!/usr/bin/env python3
"""GBZ80 (Game Boy SM83) disassembler -- decode raw bytes into RGBASM mnemonics.

Recovered from the retired extract.py; kept as a standalone tool for the manual
cleanup workflow (turning mis-classified `db` data blobs back into code).

Usage:
    tools/disasm.py <bank> <addr> <len>      # disassemble a rom.gbc region
                                             #   e.g. tools/disasm.py 03 65a4 5
    tools/disasm.py --bytes 3e 02 e0 b8 c9   # disassemble literal hex bytes
    cat block.txt | tools/disasm.py --db     # disassemble pasted `db $..` lines

bank/addr/len and --bytes accept bare hex (no $ / 0x needed). Branch and IO
operands print as $XXXX; relabel by hand after pasting into the source.
"""
import argparse
import re
import sys
from typing import Callable


R8 = ["b", "c", "d", "e", "h", "l", "[hl]", "a"]
R16_SP = ["bc", "de", "hl", "sp"]
R16_AF = ["bc", "de", "hl", "af"]
COND = ["nz", "z", "nc", "c"]
ALU8 = ["add a,", "adc a,", "sub", "sbc a,", "and", "xor", "or", "cp"]
ROT = ["rlca", "rrca", "rla", "rra", "daa", "cpl", "scf", "ccf"]
CB_OPS = ["rlc", "rrc", "rl", "rr", "sla", "sra", "swap", "srl"]


def _signed_offset(b: int, base_after: int) -> int:
    """Resolve a signed 8-bit branch offset to an absolute 16-bit address."""
    e = b if b < 0x80 else b - 0x100
    return (base_after + e) & 0xFFFF


def _signed_byte(b: int) -> int:
    return b if b < 0x80 else b - 0x100


FmtTarget = Callable[[str, int], str]
FmtIO = Callable[[int], str]


def _default_fmt_target(kind: str, target: int) -> str:
    return f"${target:04x}"


def _default_fmt_io(io_addr: int) -> str:
    return f"${io_addr:04x}"


def decode(
    data: bytes,
    pos: int,
    addr: int,
    fmt_target: FmtTarget = _default_fmt_target,
    fmt_io: FmtIO = _default_fmt_io,
) -> tuple[str, int]:
    """Decode one GBZ80 instruction.

    Args:
        data: byte buffer.
        pos: index into `data` of the opcode.
        addr: memory address corresponding to `data[pos]` (after banking).
        fmt_target: called with `(kind, target_addr)` for every 16-bit
            operand that names a code (`'code'`) or data (`'data'`) address.
            Returns the string to substitute in the mnemonic. Defaults to
            `$XXXX` hex formatting.
        fmt_io: called with the full 16-bit address (`$ff00 + n`) for every
            8-bit LDH operand. Defaults to `$XXXX` hex formatting.

    Returns:
        (rgbasm_mnemonic, n_bytes_consumed). For truncated or invalid
        instructions, emits `db $XX` consuming one byte.
    """
    op = data[pos]
    remaining = len(data) - pos

    def imm8():
        return data[pos + 1] if remaining >= 2 else None

    def imm16():
        return (data[pos + 1] | (data[pos + 2] << 8)) if remaining >= 3 else None

    # --- Block 0: 0x00-0x3F ---------------------------------------------------
    if op < 0x40:
        y = (op >> 3) & 7
        z = op & 7
        p = y >> 1
        q = y & 1

        if z == 0:
            if y == 0:
                return ("nop", 1)
            if y == 1:
                nn = imm16()
                if nn is None: return (f"db ${op:02x}", 1)
                return (f"ld [{fmt_target('data', nn)}], sp", 3)
            if y == 2:
                # `stop` is officially `stop $00` — the opcode is `$10 $00`.
                # rgbasm assembles bare `stop` as `10 00`, so we can only emit
                # `stop` when the next byte is actually $00. Otherwise (e.g.
                # bytes treated as code that aren't) emit `db $10` so the
                # roundtrip stays byte-exact.
                if remaining >= 2 and data[pos + 1] == 0x00:
                    return ("stop", 2)
                return ("db $10", 1)
            if y == 3:
                e = imm8()
                if e is None: return (f"db ${op:02x}", 1)
                t = _signed_offset(e, addr + 2)
                return (f"jr {fmt_target('code', t)}", 2)
            # y in 4..7
            cc = COND[y - 4]
            e = imm8()
            if e is None: return (f"db ${op:02x}", 1)
            t = _signed_offset(e, addr + 2)
            return (f"jr {cc}, {fmt_target('code', t)}", 2)

        if z == 1:
            if q == 0:
                nn = imm16()
                if nn is None: return (f"db ${op:02x}", 1)
                # Resolve WRAM-range immediates (pointer loads like `ld hl, wFloorGrid`)
                # to their wram.inc symbol. fmt_target only substitutes addresses that
                # are actually defined, so undefined WRAM and all ROM/constant
                # immediates stay raw — avoids mislabeling counts/offsets, byte-exact.
                if 0xC000 <= nn < 0xE000:
                    return (f"ld {R16_SP[p]}, {fmt_target('data', nn)}", 3)
                return (f"ld {R16_SP[p]}, ${nn:04x}", 3)
            return (f"add hl, {R16_SP[p]}", 1)

        if z == 2:
            mnems_store = ("ld [bc], a", "ld [de], a", "ld [hl+], a", "ld [hl-], a")
            mnems_load = ("ld a, [bc]", "ld a, [de]", "ld a, [hl+]", "ld a, [hl-]")
            return ((mnems_store if q == 0 else mnems_load)[p], 1)

        if z == 3:
            return ((f"inc {R16_SP[p]}", 1) if q == 0 else (f"dec {R16_SP[p]}", 1))

        if z == 4:
            return (f"inc {R8[y]}", 1)
        if z == 5:
            return (f"dec {R8[y]}", 1)
        if z == 6:
            n = imm8()
            if n is None: return (f"db ${op:02x}", 1)
            return (f"ld {R8[y]}, ${n:02x}", 2)
        # z == 7
        return (ROT[y], 1)

    # --- Block 1: 0x40-0x7F — ld r, r' (0x76 is halt) ------------------------
    if op < 0x80:
        if op == 0x76:
            return ("halt", 1)
        y = (op >> 3) & 7
        z = op & 7
        return (f"ld {R8[y]}, {R8[z]}", 1)

    # --- Block 2: 0x80-0xBF — ALU A, r ----------------------------------------
    if op < 0xC0:
        y = (op >> 3) & 7
        z = op & 7
        return (f"{ALU8[y]} {R8[z]}", 1)

    # --- Block 3: 0xC0-0xFF ---------------------------------------------------
    y = (op >> 3) & 7
    z = op & 7
    p = y >> 1
    q = y & 1

    if z == 0:
        if y < 4:
            return (f"ret {COND[y]}", 1)
        if y == 4:
            n = imm8()
            if n is None: return (f"db ${op:02x}", 1)
            return (f"ldh [{fmt_io(0xFF00 + n)}], a", 2)
        if y == 5:
            n = imm8()
            if n is None: return (f"db ${op:02x}", 1)
            s = _signed_byte(n)
            return (f"add sp, {s}", 2)
        if y == 6:
            n = imm8()
            if n is None: return (f"db ${op:02x}", 1)
            return (f"ldh a, [{fmt_io(0xFF00 + n)}]", 2)
        # y == 7
        n = imm8()
        if n is None: return (f"db ${op:02x}", 1)
        s = _signed_byte(n)
        if s >= 0:
            return (f"ld hl, sp+{s}", 2)
        return (f"ld hl, sp-{-s}", 2)

    if z == 1:
        if q == 0:
            return (f"pop {R16_AF[p]}", 1)
        if p == 0: return ("ret", 1)
        if p == 1: return ("reti", 1)
        if p == 2: return ("jp hl", 1)
        return ("ld sp, hl", 1)

    if z == 2:
        if y < 4:
            nn = imm16()
            if nn is None: return (f"db ${op:02x}", 1)
            return (f"jp {COND[y]}, {fmt_target('code', nn)}", 3)
        if y == 4: return ("ldh [c], a", 1)
        if y == 5:
            nn = imm16()
            if nn is None: return (f"db ${op:02x}", 1)
            return (f"ld [{fmt_target('data', nn)}], a", 3)
        if y == 6: return ("ldh a, [c]", 1)
        # y == 7
        nn = imm16()
        if nn is None: return (f"db ${op:02x}", 1)
        return (f"ld a, [{fmt_target('data', nn)}]", 3)

    if z == 3:
        if y == 0:
            nn = imm16()
            if nn is None: return (f"db ${op:02x}", 1)
            return (f"jp {fmt_target('code', nn)}", 3)
        if y == 1:
            # CB prefix
            if remaining < 2: return (f"db ${op:02x}", 1)
            op2 = data[pos + 1]
            reg = R8[op2 & 7]
            if op2 < 0x40:
                return (f"{CB_OPS[op2 >> 3]} {reg}", 2)
            bit = (op2 >> 3) & 7
            if op2 < 0x80:
                return (f"bit {bit}, {reg}", 2)
            if op2 < 0xC0:
                return (f"res {bit}, {reg}", 2)
            return (f"set {bit}, {reg}", 2)
        if y == 6: return ("di", 1)
        if y == 7: return ("ei", 1)
        # y in {2,3,4,5}: illegal opcodes
        return (f"db ${op:02x}", 1)

    if z == 4:
        if y < 4:
            nn = imm16()
            if nn is None: return (f"db ${op:02x}", 1)
            return (f"call {COND[y]}, {fmt_target('code', nn)}", 3)
        return (f"db ${op:02x}", 1)

    if z == 5:
        if q == 0:
            return (f"push {R16_AF[p]}", 1)
        if p == 0:
            nn = imm16()
            if nn is None: return (f"db ${op:02x}", 1)
            return (f"call {fmt_target('code', nn)}", 3)
        return (f"db ${op:02x}", 1)

    if z == 6:
        n = imm8()
        if n is None: return (f"db ${op:02x}", 1)
        return (f"{ALU8[y]} ${n:02x}", 2)

    # z == 7
    return (f"rst ${y * 8:02x}", 1)


# ---------------------------------------------------------------------------
# Bank / address helpers
# ---------------------------------------------------------------------------

def flat(bank: int, addr: int) -> int:
    """bank + 16-bit address -> flat ROM offset."""
    return addr if bank == 0 else bank * 0x4000 + (addr - 0x4000)


def disassemble(data: bytes, addr: int = 0) -> list[str]:
    """Linearly decode `data`, whose first byte is at memory address `addr`."""
    out, pos, a = [], 0, addr
    while pos < len(data):
        text, length = decode(data, pos, a)
        out.append(f"\t{text}")
        pos += length
        a += length
    return out


def _hx(s: str) -> int:
    return int(s.lstrip("$").replace("0x", ""), 16)


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(
        description=__doc__.splitlines()[1],
        formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--rom", default="rom.gbc")
    ap.add_argument("--bytes", nargs="+", metavar="HEX",
                    help="disassemble these literal bytes")
    ap.add_argument("--db", action="store_true",
                    help="read `db $..` lines from stdin")
    ap.add_argument("--addr", default="0",
                    help="start address for --bytes/--db (default 0)")
    ap.add_argument("region", nargs="*", metavar="BANK ADDR LEN",
                    help="disassemble a rom.gbc region")
    args = ap.parse_args(argv)

    if args.bytes:
        data = bytes(_hx(b) for b in args.bytes)
        addr = _hx(args.addr)
    elif args.db:
        text = sys.stdin.read()
        vals = [_hx(m) for m in re.findall(r"\$[0-9a-fA-F]{1,2}", text)]
        data = bytes(vals)
        addr = _hx(args.addr)
    elif len(args.region) == 3:
        bank, addr, length = (_hx(x) for x in args.region)
        rom = open(args.rom, "rb").read()
        off = flat(bank, addr)
        data = rom[off:off + length]
    else:
        ap.error("give a BANK ADDR LEN region, --bytes, or --db")

    print("\n".join(disassemble(data, addr)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
