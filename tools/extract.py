#!/usr/bin/env python3
"""Extract a Game Boy ROM into RGBASM source files per a JSON map.

The map describes how the ROM should be carved up. Each entry is either a
"code" file (one .asm with one or more SECTION blocks; subsections may be
code or data) or a "data" file (one raw .bin). The header (0x100-0x14F) is
always extracted as `header.asm`. Any bytes not covered by the map become
implicit data files named `data_<offset>.bin`, split at bank boundaries.

Addresses in the map are ROM file offsets (0..ROM_SIZE), not memory
addresses; bank and memory address for SECTION directives are derived.

Usage:
    extract.py --rom rom.gbc --map map.json [--output src/]
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

HEADER_START = 0x0100
HEADER_END = 0x0150  # exclusive
BANK_SIZE = 0x4000


# ---------------------------------------------------------------------------
# GBZ80 disassembler
# ---------------------------------------------------------------------------

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


def decode(data: bytes, pos: int, addr: int) -> tuple[str, int]:
    """Decode one GBZ80 instruction.

    Args:
        data: byte buffer.
        pos: index into `data` of the opcode.
        addr: memory address corresponding to `data[pos]` (after banking).

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
                return (f"ld [${nn:04x}], sp", 3)
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
                return (f"jr ${t:04x}", 2)
            # y in 4..7
            cc = COND[y - 4]
            e = imm8()
            if e is None: return (f"db ${op:02x}", 1)
            t = _signed_offset(e, addr + 2)
            return (f"jr {cc}, ${t:04x}", 2)

        if z == 1:
            if q == 0:
                nn = imm16()
                if nn is None: return (f"db ${op:02x}", 1)
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
            return (f"ldh [${0xFF00 + n:04x}], a", 2)
        if y == 5:
            n = imm8()
            if n is None: return (f"db ${op:02x}", 1)
            s = _signed_byte(n)
            return (f"add sp, {s}", 2)
        if y == 6:
            n = imm8()
            if n is None: return (f"db ${op:02x}", 1)
            return (f"ldh a, [${0xFF00 + n:04x}]", 2)
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
            return (f"jp {COND[y]}, ${nn:04x}", 3)
        if y == 4: return ("ldh [c], a", 1)
        if y == 5:
            nn = imm16()
            if nn is None: return (f"db ${op:02x}", 1)
            return (f"ld [${nn:04x}], a", 3)
        if y == 6: return ("ldh a, [c]", 1)
        # y == 7
        nn = imm16()
        if nn is None: return (f"db ${op:02x}", 1)
        return (f"ld a, [${nn:04x}]", 3)

    if z == 3:
        if y == 0:
            nn = imm16()
            if nn is None: return (f"db ${op:02x}", 1)
            return (f"jp ${nn:04x}", 3)
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
            return (f"call {COND[y]}, ${nn:04x}", 3)
        return (f"db ${op:02x}", 1)

    if z == 5:
        if q == 0:
            return (f"push {R16_AF[p]}", 1)
        if p == 0:
            nn = imm16()
            if nn is None: return (f"db ${op:02x}", 1)
            return (f"call ${nn:04x}", 3)
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

def rom_offset_to_bank_addr(offset: int) -> tuple[int, int]:
    """Map a ROM file offset to (bank, memory_address).

    ROM0 (bank 0) lives at $0000-$3FFF. Any other bank is mapped into
    ROMX at $4000-$7FFF when banked in.
    """
    if offset < BANK_SIZE:
        return (0, offset)
    bank = offset // BANK_SIZE
    addr = (offset % BANK_SIZE) + BANK_SIZE
    return (bank, addr)


def section_directive(name: str, offset: int) -> str:
    bank, addr = rom_offset_to_bank_addr(offset)
    if bank == 0:
        return f'SECTION "{name}", ROM0[${addr:04x}]'
    return f'SECTION "{name}", ROMX[${addr:04x}], BANK[${bank:02x}]'


# ---------------------------------------------------------------------------
# Map validation
# ---------------------------------------------------------------------------

class MapError(Exception):
    pass


def _check_range(label: str, addr: int, length: int, rom_size: int) -> None:
    if not isinstance(addr, int) or not isinstance(length, int):
        raise MapError(f"{label}: addr and len must be integers")
    if length <= 0:
        raise MapError(f"{label}: len must be positive (got {length})")
    if addr < 0 or addr + length > rom_size:
        raise MapError(
            f"{label}: range ${addr:06x}+{length} extends past ROM end (${rom_size:06x})"
        )


def validate_map(spec: dict[str, Any], rom_size: int) -> list[tuple[int, int, str]]:
    """Validate the map; return sorted list of (start, end, label) intervals
    including the reserved header region."""
    if not isinstance(spec, dict) or "files" not in spec:
        raise MapError("map must be an object with a 'files' array")

    intervals: list[tuple[int, int, str]] = []
    names: set[str] = set()

    for fi, f in enumerate(spec["files"]):
        if not isinstance(f, dict):
            raise MapError(f"files[{fi}]: not an object")
        name = f.get("name")
        ftype = f.get("type")
        if not isinstance(name, str) or not name:
            raise MapError(f"files[{fi}]: missing or empty 'name'")
        if name in names:
            raise MapError(f"files[{fi}]: duplicate filename {name!r}")
        if name == "header.asm":
            raise MapError(f"files[{fi}]: 'header.asm' is reserved")
        names.add(name)

        if ftype == "code":
            secs = f.get("sections")
            if not isinstance(secs, list) or not secs:
                raise MapError(f"{name}: code files require a non-empty 'sections' list")
            for si, sec in enumerate(secs):
                stype = sec.get("type")
                if stype not in ("code", "data"):
                    raise MapError(f"{name} sections[{si}]: type must be 'code' or 'data'")
                _check_range(f"{name} sections[{si}]", sec["addr"], sec["len"], rom_size)
                intervals.append(
                    (sec["addr"], sec["addr"] + sec["len"], f"{name}[{si}]")
                )
        elif ftype == "data":
            _check_range(name, f["addr"], f["len"], rom_size)
            intervals.append((f["addr"], f["addr"] + f["len"], name))
        else:
            raise MapError(f"{name}: unknown type {ftype!r} (expected 'code' or 'data')")

    # Reserve the header.
    intervals.append((HEADER_START, HEADER_END, "header.asm"))

    intervals.sort()
    for i in range(1, len(intervals)):
        a_start, a_end, a_label = intervals[i - 1]
        b_start, b_end, b_label = intervals[i]
        if b_start < a_end:
            raise MapError(
                f"overlap between {a_label} (${a_start:06x}-${a_end - 1:06x}) "
                f"and {b_label} (${b_start:06x}-${b_end - 1:06x})"
            )

    return intervals


def find_gaps(intervals: list[tuple[int, int, str]], rom_size: int) -> list[tuple[int, int]]:
    """Compute uncovered (start, len) regions, each clipped to a single bank."""
    gaps: list[tuple[int, int]] = []
    cursor = 0
    for start, end, _ in intervals:
        if start > cursor:
            gaps.append((cursor, start - cursor))
        cursor = max(cursor, end)
    if cursor < rom_size:
        gaps.append((cursor, rom_size - cursor))

    split: list[tuple[int, int]] = []
    for start, length in gaps:
        end = start + length
        while start < end:
            bank_end = ((start // BANK_SIZE) + 1) * BANK_SIZE
            chunk_end = min(end, bank_end)
            split.append((start, chunk_end - start))
            start = chunk_end
    return split


# ---------------------------------------------------------------------------
# Emitters
# ---------------------------------------------------------------------------

GENERATED_BANNER = "; Auto-generated by tools/extract.py. Do not edit."


def _db_lines(data: bytes, indent: str = "\t") -> list[str]:
    """Format raw bytes as `db $xx, $xx, ...` lines, 16 bytes per line."""
    lines: list[str] = []
    for i in range(0, len(data), 16):
        chunk = data[i:i + 16]
        lines.append(indent + "db " + ", ".join(f"${b:02x}" for b in chunk))
    return lines


def emit_code_file(file_spec: dict[str, Any], rom: bytes, output_dir: Path) -> Path:
    name = file_spec["name"]
    stem = Path(name).stem
    sections = sorted(file_spec["sections"], key=lambda s: s["addr"])

    lines: list[str] = [GENERATED_BANNER, ""]

    for sec in sections:
        offset = sec["addr"]
        length = sec["len"]
        stype = sec["type"]
        _, mem_addr = rom_offset_to_bank_addr(offset)

        sec_name = f"{stem}_{offset:06x}"
        lines.append(section_directive(sec_name, offset))
        lines.append("")
        lines.append(f"Section_{offset:06x}:")

        chunk = rom[offset:offset + length]

        if stype == "code":
            i = 0
            while i < length:
                mnem, n = decode(chunk, i, (mem_addr + i) & 0xFFFF)
                lines.append(f"\t{mnem}")
                i += n
        else:
            lines.extend(_db_lines(chunk))
        lines.append("")

    out_path = output_dir / name
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text("\n".join(lines))
    return out_path


def emit_data_file(file_spec: dict[str, Any], rom: bytes, output_dir: Path) -> Path:
    name = file_spec["name"]
    offset = file_spec["addr"]
    length = file_spec["len"]
    out_path = output_dir / name
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_bytes(rom[offset:offset + length])
    return out_path


def emit_header(rom: bytes, output_dir: Path) -> Path:
    """Emit `header.asm` covering 0x100-0x14F, with the entry point
    disassembled and the rest laid out as labeled byte fields."""
    data = rom[HEADER_START:HEADER_END]
    lines: list[str] = [
        GENERATED_BANNER,
        "",
        'SECTION "Header", ROM0[$0100]',
        "",
        "EntryPoint:",
    ]
    # Entry point: bytes at $0100-$0103. Usually `nop; jp $0150`.
    i = 0
    while i < 4:
        mnem, n = decode(data, i, 0x0100 + i)
        # Don't overshoot the 4-byte entry-point slot.
        if i + n > 4:
            for j in range(i, 4):
                lines.append(f"\tdb ${data[j]:02x}")
            i = 4
            break
        lines.append(f"\t{mnem}")
        i += n

    def field(label: str, start: int, end: int) -> None:  # end exclusive
        lines.append("")
        lines.append(f"; {label} (${0x0100 + start:04x}-${0x0100 + end - 1:04x})")
        lines.extend(_db_lines(data[start:end]))

    field("Nintendo logo", 0x04, 0x34)
    field("Title", 0x34, 0x43)
    field("CGB flag", 0x43, 0x44)
    field("New licensee code", 0x44, 0x46)
    field("SGB flag", 0x46, 0x47)
    field("Cartridge type", 0x47, 0x48)
    field("ROM size", 0x48, 0x49)
    field("RAM size", 0x49, 0x4A)
    field("Destination code", 0x4A, 0x4B)
    field("Old licensee code", 0x4B, 0x4C)
    field("Mask ROM version", 0x4C, 0x4D)
    field("Header checksum", 0x4D, 0x4E)
    field("Global checksum", 0x4E, 0x50)
    lines.append("")

    out_path = output_dir / "header.asm"
    out_path.write_text("\n".join(lines))
    return out_path


def emit_main(
    code_asms: list[str],
    data_bins: list[tuple[str, int]],
    output_dir: Path,
) -> Path:
    """Emit `main.asm` — the single translation unit fed to rgbasm.

    INCLUDEs every code .asm and wraps every data .bin in its own SECTION
    + INCBIN at the correct bank/address. Assembling main.asm and linking
    the result produces the complete ROM.
    """
    lines: list[str] = [GENERATED_BANNER, ""]
    lines.append('INCLUDE "header.asm"')
    for asm in sorted(code_asms):
        lines.append(f'INCLUDE "{asm}"')
    lines.append("")

    for name, offset in sorted(data_bins, key=lambda x: x[1]):
        sec_name = Path(name).stem
        lines.append(section_directive(sec_name, offset))
        lines.append(f'\tINCBIN "{name}"')
        lines.append("")

    out_path = output_dir / "main.asm"
    out_path.write_text("\n".join(lines))
    return out_path


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("--rom", required=True, help="path to ROM file")
    p.add_argument("--map", dest="map_file", required=True, help="path to map JSON")
    p.add_argument("--output", default="src/", help="output directory (default: src/)")
    args = p.parse_args(argv)

    rom_path = Path(args.rom)
    map_path = Path(args.map_file)
    output_dir = Path(args.output)

    rom = rom_path.read_bytes()
    spec = json.loads(map_path.read_text())

    try:
        intervals = validate_map(spec, len(rom))
    except MapError as e:
        print(f"error: {e}", file=sys.stderr)
        return 2

    gaps = find_gaps(intervals, len(rom))

    output_dir.mkdir(parents=True, exist_ok=True)

    written: list[Path] = [emit_header(rom, output_dir)]
    code_asms: list[str] = []
    data_bins: list[tuple[str, int]] = []

    for f in spec["files"]:
        if f["type"] == "code":
            written.append(emit_code_file(f, rom, output_dir))
            code_asms.append(f["name"])
        else:
            written.append(emit_data_file(f, rom, output_dir))
            data_bins.append((f["name"], f["addr"]))

    for gap_addr, gap_len in gaps:
        gap_spec = {
            "name": f"data_{gap_addr:06x}.bin",
            "addr": gap_addr,
            "len": gap_len,
        }
        written.append(emit_data_file(gap_spec, rom, output_dir))
        data_bins.append((gap_spec["name"], gap_addr))

    written.append(emit_main(code_asms, data_bins, output_dir))

    for path in sorted(written):
        print(path)
    return 0


if __name__ == "__main__":
    sys.exit(main())
