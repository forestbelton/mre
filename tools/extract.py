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
import re
import sys
from pathlib import Path
from typing import Any, Callable

HEADER_START = 0x0100
HEADER_END = 0x0150  # exclusive
BANK_SIZE = 0x4000
DEFAULT_INCLUDE_DIR = "include"
HARDWARE_INC = "hardware.inc"

# Section types accepted in `sections[]`. Each maps to one of the two
# coverage flavors the rest of the pipeline cares about:
#   - "code"  : treat as disassembled instructions; labels at instruction
#               boundaries only.
#   - "data"  : treat as a span of bytes; labels at any byte position.
# `ascii` and `asciz` are emitted as RGBASM string literals but are
# coverage-equivalent to `data` (any byte is a valid label position).
SECTION_TYPES = {"code", "data", "ascii", "asciz", "padding"}
DATA_LIKE_TYPES = {"data", "ascii", "asciz"}


def section_coverage_kind(stype: str) -> str:
    """Map a section's semantic type to its coverage kind ("code" / "data")."""
    return "code" if stype == "code" else "data"


# Files the extractor always owns and always regenerates. Every other
# code file in map.json is treated as user-editable after first emission:
# extract.py won't overwrite it on subsequent runs.
AUTO_MANAGED_FILES = {"header.asm", "main.asm", "analyzed.asm"}


# ---------------------------------------------------------------------------
# hardware.inc parsing
# ---------------------------------------------------------------------------

_EQU_RE = re.compile(
    r"^\s*def\s+(\w+)\s+equ\s+(.+?)\s*(?:;.*)?$",
    re.IGNORECASE,
)


def parse_hw_symbols(path: Path) -> dict[int, str]:
    """Parse a hardware.inc-style file. Return {addr: canonical_name} for
    addresses inside the I/O + HRAM range (0xFF00-0xFFFF).

    Handles two forms of definition:
        def rLCDC   equ $FF40           ; direct hex literal
        def rNR52   equ rAUDENA         ; alias of another symbol

    Aliases are resolved transitively; the *first* name that maps to a
    given address wins (hardware.inc lists canonical names before aliases).
    """
    if not path.exists():
        return {}
    direct: dict[str, int] = {}    # name -> address
    alias: dict[str, str] = {}     # name -> referenced name
    for line in path.read_text().splitlines():
        m = _EQU_RE.match(line)
        if not m:
            continue
        name, value = m.group(1), m.group(2).strip()
        if value.startswith("$"):
            try:
                direct[name] = int(value[1:], 16)
            except ValueError:
                pass
        elif value.isidentifier():
            alias[name] = value

    # Resolve aliases to their ultimate direct address.
    for name, ref in alias.items():
        if name in direct:
            continue
        seen: set[str] = set()
        cur = ref
        while cur in alias and cur not in seen:
            seen.add(cur)
            cur = alias[cur]
        if cur in direct:
            direct[name] = direct[cur]

    addr_to_name: dict[int, str] = {}
    for name, addr in direct.items():
        if 0xFF00 <= addr <= 0xFFFF and addr not in addr_to_name:
            addr_to_name[addr] = name
    return addr_to_name


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


def resolve_target_to_flat(source_bank: int, target_addr: int) -> int | None:
    """Map a 16-bit code/data target into a flat ROM offset.

    For $0000-$3FFF the bank is always 0. For $4000-$7FFF we assume the
    currently-loaded bank is `source_bank` — the same bank as the code
    that issued the reference. This is a heuristic; cross-bank dispatch
    through a fixed-bank trampoline isn't recognized.

    The exception is bank 0 calling into $4000-$7FFF: bank 0 has no
    high-bank area of its own, so this is unambiguously a call into
    *some other* bank that was switched in. We can't tell which from
    the instruction alone, so we leave it unresolved (hex literal).
    """
    if target_addr < 0x4000:
        return target_addr
    if target_addr < 0x8000:
        if source_bank == 0:
            return None
        return source_bank * BANK_SIZE + (target_addr - BANK_SIZE)
    return None


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


_LABEL_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


def _validate_label(value: Any, where: str, seen: dict[str, str]) -> str | None:
    """Validate an optional `label` field. Returns the label (a string)
    if present and well-formed, or None if missing. Raises MapError on
    bad input or a duplicate. `seen` maps label -> where it was defined,
    for nice duplicate-detection messages."""
    if value is None:
        return None
    if not isinstance(value, str) or not value:
        raise MapError(f"{where}: 'label' must be a non-empty string")
    if not _LABEL_RE.match(value):
        raise MapError(
            f"{where}: 'label' {value!r} must match {_LABEL_RE.pattern} "
            "(RGBASM identifier)"
        )
    if value in seen:
        raise MapError(
            f"{where}: duplicate label {value!r}, already defined at {seen[value]}"
        )
    seen[value] = where
    return value


ANALYZED_FILE_NAME = "analyzed.asm"


def validate_padding_sections(spec: dict[str, Any], rom: bytes) -> None:
    """Verify every padding section in the spec is backed by all-$00 bytes.

    Padding sections don't emit any RGBASM directives — they exist purely
    to claim the address range so the extractor's coverage stats know it
    isn't an "uncovered" gap. The bytes get filled by rgblink's `-p 0`
    pass since there's no SECTION declared for that range and a real
    section sits at a higher address (extending the ROM size). If any of
    those bytes were non-zero, dropping the section directive would
    silently corrupt the build, so we check up-front.
    """
    for f in spec.get("files", []):
        if not isinstance(f, dict) or f.get("type") != "code":
            continue
        for s in f.get("sections", []) or []:
            if not isinstance(s, dict) or s.get("type") != "padding":
                continue
            start = int(s["addr"])
            length = int(s["len"])
            end = start + length
            if end > len(rom):
                raise MapError(
                    f"{f.get('name')!r} padding section at ${start:06x}: "
                    f"extends past ROM end (${len(rom):06x})"
                )
            for i in range(start, end):
                if rom[i] != 0:
                    raise MapError(
                        f"{f.get('name')!r} padding section at ${start:06x}: "
                        f"byte ${i:06x} is ${rom[i]:02x}, not $00"
                    )


def reconcile_analyzed_sections(spec: dict[str, Any]) -> None:
    """In-memory split of analyzed.asm sections around user-curated ranges.

    The analyzer is the only thing that ever rewrites analyzed.asm's section
    list, so when the user adds a new file entry to map.json the analyzed
    sections still cover the bytes the new entry now claims. Rather than
    making the user re-run the analyzer just to trim, we trim here.

    For every section in analyzed.asm: if any user-curated interval (any
    file entry except analyzed.asm itself) overlaps it, replace that one
    section with the gap pieces before and after the overlap. Sections
    fully covered by user intervals disappear. The mutation is in-memory
    only; the on-disk map.json keeps its old section list until the
    analyzer next snapshots.

    Idempotent: re-running on an already-reconciled spec is a no-op.
    """
    user_intervals: list[tuple[int, int]] = []
    for f in spec.get("files", []):
        if not isinstance(f, dict):
            continue
        if f.get("name") == ANALYZED_FILE_NAME:
            continue
        ftype = f.get("type")
        if ftype == "code":
            for s in f.get("sections", []) or []:
                if isinstance(s, dict) and "addr" in s and "len" in s:
                    user_intervals.append((int(s["addr"]), int(s["addr"]) + int(s["len"])))
        elif ftype == "data":
            if "addr" in f and "len" in f:
                user_intervals.append((int(f["addr"]), int(f["addr"]) + int(f["len"])))
    if not user_intervals:
        return
    user_intervals.sort()

    analyzed = next(
        (f for f in spec.get("files", []) if isinstance(f, dict) and f.get("name") == ANALYZED_FILE_NAME),
        None,
    )
    if analyzed is None:
        return
    secs = analyzed.get("sections")
    if not isinstance(secs, list):
        return

    new_secs: list[dict[str, Any]] = []
    for sec in secs:
        if not isinstance(sec, dict) or "addr" not in sec or "len" not in sec:
            new_secs.append(sec)
            continue
        s_start = int(sec["addr"])
        s_end = s_start + int(sec["len"])
        # Collect overlaps with this section.
        overlaps = [
            (us, ue) for us, ue in user_intervals
            if us < s_end and ue > s_start
        ]
        if not overlaps:
            new_secs.append(sec)
            continue
        # Walk the section, emitting gap pieces between overlaps.
        cursor = s_start
        for us, ue in overlaps:
            if cursor < us:
                piece = dict(sec)
                piece["addr"] = cursor
                piece["len"] = us - cursor
                new_secs.append(piece)
            cursor = max(cursor, ue)
        if cursor < s_end:
            piece = dict(sec)
            piece["addr"] = cursor
            piece["len"] = s_end - cursor
            new_secs.append(piece)
    analyzed["sections"] = new_secs


def validate_map(spec: dict[str, Any], rom_size: int) -> list[tuple[int, int, str]]:
    """Validate the map; return sorted list of (start, end, label) intervals
    including the reserved header region."""
    if not isinstance(spec, dict) or "files" not in spec:
        raise MapError("map must be an object with a 'files' array")

    intervals: list[tuple[int, int, str]] = []
    names: set[str] = set()
    labels_seen: dict[str, str] = {}

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
                if stype not in SECTION_TYPES:
                    raise MapError(
                        f"{name} sections[{si}]: type must be one of "
                        f"{sorted(SECTION_TYPES)} (got {stype!r})"
                    )
                _check_range(f"{name} sections[{si}]", sec["addr"], sec["len"], rom_size)
                _validate_label(sec.get("label"), f"{name} sections[{si}]", labels_seen)
                intervals.append(
                    (sec["addr"], sec["addr"] + sec["len"], f"{name}[{si}]")
                )
        elif ftype == "data":
            _check_range(name, f["addr"], f["len"], rom_size)
            _validate_label(f.get("label"), name, labels_seen)
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


# Coverage-stats categories. Order matters for the print summary, and the
# fill priority below (later wins) is what assigns each ROM byte to exactly
# one category when more than one claim overlaps.
_COV_CATEGORIES = [
    ("user_code",     "user-curated code"),
    ("user_data",     "user-curated data"),
    ("user_ascii",    "user-curated ascii"),
    ("user_asciz",    "user-curated asciz"),
    ("user_padding",  "user-curated padding"),
    ("analyzed_code", "analyzer code"),
    ("analyzed_data", "analyzer data"),
    ("conflict",      "conflict bytes"),
    ("header",        "cartridge header"),
    ("uncovered",     "uncovered (gap-fill .bin)"),
]


def compute_coverage(spec: dict[str, Any], rom_size: int) -> dict[str, int]:
    """Return a {category_key: byte_count} dict summarising the map.

    Every ROM byte is assigned to exactly one category. The priority order
    (later wins, so user-curated entries take precedence over the analyzer's
    view, and the header always wins) is:
      analyzer (code, data) <- conflicts <- user-curated <- header
    """
    keys = [k for k, _ in _COV_CATEGORIES]
    cat_id = {k: i for i, k in enumerate(keys)}
    marks = bytearray(rom_size)  # default 0 == uncovered (last category)
    # Use a 0-byte default that does NOT map to one of the real category ids,
    # then re-label it as 'uncovered' at the end. Simpler: pick an "unmarked"
    # sentinel and translate it.
    UNMARKED = 0xFF
    for i in range(rom_size):
        marks[i] = UNMARKED

    def fill(start: int, length: int, kind: str) -> None:
        cid = cat_id[kind]
        end = min(start + length, rom_size)
        for i in range(max(start, 0), end):
            marks[i] = cid

    # Lowest priority first.
    for f in spec.get("files", []):
        if not isinstance(f, dict):
            continue
        if f.get("name") == ANALYZED_FILE_NAME and f.get("type") == "code":
            for s in f.get("sections", []) or []:
                t = s.get("type")
                if t == "code":
                    fill(s["addr"], s["len"], "analyzed_code")
                elif t == "data":
                    fill(s["addr"], s["len"], "analyzed_data")

    # Conflicts overlay any analyzed range.
    for c in spec.get("conflicts", []) or []:
        if isinstance(c, dict) and "addr" in c and "len" in c:
            fill(c["addr"], c["len"], "conflict")

    # User-curated entries beat analyzer/conflict.
    for f in spec.get("files", []):
        if not isinstance(f, dict):
            continue
        if f.get("name") == ANALYZED_FILE_NAME:
            continue
        ftype = f.get("type")
        if ftype == "code":
            for s in f.get("sections", []) or []:
                t = s.get("type")
                if t == "code":
                    fill(s["addr"], s["len"], "user_code")
                elif t == "data":
                    fill(s["addr"], s["len"], "user_data")
                elif t == "ascii":
                    fill(s["addr"], s["len"], "user_ascii")
                elif t == "asciz":
                    fill(s["addr"], s["len"], "user_asciz")
                elif t == "padding":
                    fill(s["addr"], s["len"], "user_padding")
        elif ftype == "data":
            fill(f["addr"], f["len"], "user_data")

    # Header always wins.
    fill(HEADER_START, HEADER_END - HEADER_START, "header")

    counts: dict[str, int] = {k: 0 for k in keys}
    for b in marks:
        if b == UNMARKED:
            counts["uncovered"] += 1
        else:
            counts[keys[b]] += 1
    return counts


def print_coverage_stats(counts: dict[str, int], rom_size: int, *, stream=sys.stderr) -> None:
    """Print a one-block coverage summary."""
    print("", file=stream)
    print(f"  coverage of {rom_size} ROM bytes:", file=stream)
    for key, label in _COV_CATEGORIES:
        n = counts.get(key, 0)
        if n == 0 and key != "uncovered":
            continue
        pct = 100.0 * n / rom_size if rom_size else 0.0
        print(f"    {label:<28}  {n:>8}  {pct:5.1f}%", file=stream)
    covered = rom_size - counts.get("uncovered", 0)
    cov_pct = 100.0 * covered / rom_size if rom_size else 0.0
    print(f"    {'covered total':<28}  {covered:>8}  {cov_pct:5.1f}%", file=stream)


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
# Reference discovery + label assignment
# ---------------------------------------------------------------------------

import bisect


def build_section_index(
    spec: dict[str, Any],
) -> list[tuple[int, int, str, str]]:
    """Sorted list of (start, end_exclusive, kind, owner) intervals.

    `kind` is "code", "data", or "header" (the section's own type).
    `owner` is:
      - "code-file"  — a subsection inside a code .asm; inline `db` for
                       data subsections, so any byte can take a label.
      - "data-file"  — a top-level .bin; only the section *start* is a
                       valid label position (the body is INCBIN'd).
      - "header"     — the cartridge header; off-limits.
    """
    out: list[tuple[int, int, str, str]] = []
    for f in spec.get("files", []):
        if f.get("type") == "code":
            for s in f.get("sections", []):
                kind = section_coverage_kind(s["type"])
                # ascii/asciz spans render as one RGBASM string literal,
                # so we can't slot a label in mid-span — same constraint
                # as an INCBIN'd top-level data file. Mark the owner
                # accordingly so build_labels only accepts a label at
                # the section's start.
                owner = ("string-section"
                         if s["type"] in ("ascii", "asciz")
                         else "code-file")
                out.append((s["addr"], s["addr"] + s["len"], kind, owner))
        elif f.get("type") == "data":
            out.append((f["addr"], f["addr"] + f["len"], "data", "data-file"))
    out.append((HEADER_START, HEADER_END, "header", "header"))
    out.sort()
    return out


def section_at(
    index: list[tuple[int, int, str, str]], flat: int,
) -> tuple[int, int, str, str] | None:
    """Return the section containing `flat`, or None."""
    starts = [s[0] for s in index]
    i = bisect.bisect_right(starts, flat) - 1
    if i < 0:
        return None
    s = index[i]
    return s if s[0] <= flat < s[1] else None


def compute_insn_boundaries(rom: bytes, spec: dict[str, Any]) -> set[int]:
    """For each code subsection, find every byte that starts an instruction
    when the section is disassembled linearly. Labels are only emitted at
    these positions in code sections — putting one mid-instruction would
    refuse to assemble."""
    boundaries: set[int] = set()
    for f in spec.get("files", []):
        if f.get("type") != "code":
            continue
        for s in f.get("sections", []):
            if s.get("type") != "code":
                continue
            offset = s["addr"]
            length = s["len"]
            chunk = rom[offset:offset + length]
            _, mem_start = rom_offset_to_bank_addr(offset)
            i = 0
            while i < length:
                boundaries.add(offset + i)
                _, n = decode(chunk, i, (mem_start + i) & 0xFFFF)
                i += n
    return boundaries


def collect_refs(rom: bytes, spec: dict[str, Any]) -> list[tuple[str, int, int]]:
    """Pass 1. Returns a list of (kind, source_bank, target_addr) tuples,
    where `kind` is "code" or "data" and target_addr is the raw 16-bit
    operand from the instruction."""
    refs: list[tuple[str, int, int]] = []
    for f in spec.get("files", []):
        if f.get("type") != "code":
            continue
        for s in f.get("sections", []):
            if s.get("type") != "code":
                continue
            offset = s["addr"]
            length = s["len"]
            chunk = rom[offset:offset + length]
            sec_bank, mem_start = rom_offset_to_bank_addr(offset)

            def record_target(kind: str, target: int, _bank: int = sec_bank) -> str:
                refs.append((kind, _bank, target))
                return f"${target:04x}"

            def record_io(io_addr: int) -> str:
                return f"${io_addr:04x}"

            i = 0
            while i < length:
                pc = (mem_start + i) & 0xFFFF
                _, n = decode(chunk, i, pc, record_target, record_io)
                i += n
    return refs


def build_labels(
    refs: list[tuple[str, int, int]],
    sec_index: list[tuple[int, int, str]],
    insn_boundaries: set[int],
    spec: dict[str, Any],
) -> dict[int, str]:
    """Pass 2. Build {flat_offset: label_name}.

    A reference target gets a label only when it resolves to a position
    inside a section we own AND the position is a valid emission point
    (instruction boundary in a code section, any byte in a data section).
    All explicit subsection starts also get a label so they're navigable
    even when nothing references them.
    """
    labels: dict[int, str] = {}

    def assign(flat: int, kind: str, override: str | None = None) -> None:
        if flat in labels:
            return
        if override:
            labels[flat] = override
            return
        bank, mem_addr = rom_offset_to_bank_addr(flat)
        prefix = "Func" if kind == "code" else "Data"
        labels[flat] = f"{prefix}_{bank:02x}_{mem_addr:04x}"

    # Section starts always labeled. A user-provided "label" field on a
    # section (or top-level data file) overrides the auto-generated name.
    for f in spec.get("files", []):
        if f.get("type") == "code":
            for s in f.get("sections", []):
                assign(s["addr"], section_coverage_kind(s["type"]), s.get("label"))
        elif f.get("type") == "data":
            assign(f["addr"], "data", f.get("label"))

    # Referenced positions, validated against the section index. A label
    # is only "definable" where the emitter actually walks byte-by-byte —
    # instruction boundaries in code subsections, anywhere in inline-`db`
    # data subsections, and only the very first byte of an INCBIN'd .bin.
    for kind, src_bank, target in refs:
        flat = resolve_target_to_flat(src_bank, target)
        if flat is None:
            continue
        sec = section_at(sec_index, flat)
        if sec is None:
            continue
        sec_start, _sec_end, sec_kind, owner = sec
        if owner == "header":
            continue
        if owner in ("data-file", "string-section"):
            if flat != sec_start:
                continue
        elif owner == "code-file":
            if sec_kind == "code" and flat not in insn_boundaries:
                continue
            # data subsection inside a code file: any byte is fine
        assign(flat, kind)

    return labels


def make_resolver(
    hw_symbols: dict[int, str],
    labels: dict[int, str],
    sec_bank: int,
) -> tuple[FmtTarget, FmtIO]:
    """Build (fmt_target, fmt_io) closures bound to a section's bank
    context so address resolution sees the right ROMX bank for $4000+."""
    def fmt_target(kind: str, target: int) -> str:
        flat = resolve_target_to_flat(sec_bank, target)
        if flat is not None and flat in labels:
            return labels[flat]
        if 0xFF00 <= target <= 0xFFFF and target in hw_symbols:
            return hw_symbols[target]
        return f"${target:04x}"

    def fmt_io(io_addr: int) -> str:
        return hw_symbols.get(io_addr, f"${io_addr:04x}")

    return fmt_target, fmt_io


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


def _format_ascii_db(data: bytes, indent: str = "\t",
                    trailing_terminator: bool = False) -> list[str]:
    """Render `data` as RGBASM `db` lines using string literals where
    possible. Printable bytes ($20-$7E) collapse into "..." segments;
    `"` and `\\` get backslash-escaped; non-printable bytes break out
    as numeric `$xx` between string segments.

    If `trailing_terminator` is set, the last byte of `data` must be
    `$00` and is rendered as `, 0` after the string (used for asciz).
    """
    if trailing_terminator:
        if not data or data[-1] != 0:
            raise ValueError(
                "asciz section: last byte must be $00 "
                f"(got ${data[-1]:02x})" if data else "asciz section is empty"
            )
        body = data[:-1]
    else:
        body = data

    parts: list[str] = []
    cur = ""
    for b in body:
        if 0x20 <= b <= 0x7E:
            ch = chr(b)
            if ch in ('"', '\\'):
                ch = "\\" + ch
            cur += ch
        else:
            if cur:
                parts.append(f'"{cur}"')
                cur = ""
            parts.append(f"${b:02x}")
    if cur:
        parts.append(f'"{cur}"')
    if trailing_terminator:
        parts.append("0")
    if not parts:
        return []
    return [indent + "db " + ", ".join(parts)]


# Parses a SECTION directive into its declared address. Two forms:
#   SECTION "name", ROM0[$XXXX]
#   SECTION "name", ROMX[$YYYY], BANK[$ZZ]
# The name (group 1) is ignored — section identity is the address, not
# whatever string the user picked for the directive. Whitespace inside
# the directive is permissive.
_SECTION_DIRECTIVE_RE = re.compile(
    r'^\s*SECTION\s+"[^"]+"\s*,\s*'
    r'(?:ROM0\[\s*\$([0-9a-fA-F]+)\s*\]'
    r'|ROMX\[\s*\$([0-9a-fA-F]+)\s*\]\s*,\s*BANK\[\s*\$([0-9a-fA-F]+)\s*\])',
    re.MULTILINE,
)


def _existing_section_extents(path: Path) -> list[tuple[int, int]]:
    """Parse SECTION directives in an existing .asm file and return their
    implicit coverage: a sorted list of (flat_start, flat_end) ranges
    where `flat_end` is the next SECTION's start in the same file or
    the bank boundary, whichever comes first.

    Section IDENTITY is the address. Names, labels, and inline content
    are deliberately ignored — the user can rename, merge, or split
    directives without confusing the extractor.
    """
    if not path.exists():
        return []
    starts: list[int] = []
    for m in _SECTION_DIRECTIVE_RE.finditer(path.read_text()):
        if m.group(1) is not None:  # ROM0
            flat = int(m.group(1), 16)
        else:  # ROMX, BANK
            addr = int(m.group(2), 16)
            bank = int(m.group(3), 16)
            flat = bank * BANK_SIZE + (addr - BANK_SIZE)
        starts.append(flat)
    starts.sort()
    # Compute extent: each section extends to the next section's start
    # or the bank boundary, whichever comes first. rgbasm SECTIONs can't
    # straddle banks anyway.
    extents: list[tuple[int, int]] = []
    for i, s in enumerate(starts):
        bank_end = ((s // BANK_SIZE) + 1) * BANK_SIZE
        nxt = starts[i + 1] if i + 1 < len(starts) else bank_end
        extents.append((s, min(nxt, bank_end)))
    return extents


def _range_covered(extents: list[tuple[int, int]], addr: int, length: int) -> bool:
    """True iff [addr, addr+length) lies entirely inside some extent."""
    end = addr + length
    for s, e in extents:
        if s <= addr and end <= e:
            return True
    return False


def _build_section_lines(
    sec: dict[str, Any],
    sec_name: str,
    file_name: str,
    rom: bytes,
    labels: dict[int, str],
    hw_symbols: dict[int, str],
) -> list[str]:
    """Render one section in a code file. Returns the list of lines
    (including the SECTION directive at the top)."""
    offset = sec["addr"]
    length = sec["len"]
    stype = sec["type"]
    sec_bank, mem_addr = rom_offset_to_bank_addr(offset)

    lines: list[str] = [section_directive(sec_name, offset), ""]
    chunk = rom[offset:offset + length]
    fmt_target, fmt_io = make_resolver(hw_symbols, labels, sec_bank)

    if stype == "code":
        i = 0
        while i < length:
            flat = offset + i
            if flat in labels:
                lines.append(f"{labels[flat]}:")
            pc = (mem_addr + i) & 0xFFFF
            mnem, n = decode(chunk, i, pc, fmt_target, fmt_io)
            lines.append(f"\t{mnem}")
            i += n
    elif stype in ("ascii", "asciz"):
        # Render the whole span as one RGBASM string literal (with break-
        # outs for non-printable bytes). Mid-section labels aren't
        # supported — see build_labels' "string-section" handling.
        if offset in labels:
            lines.append(f"{labels[offset]}:")
        try:
            lines.extend(_format_ascii_db(
                chunk, indent="\t",
                trailing_terminator=(stype == "asciz"),
            ))
        except ValueError as e:
            raise MapError(f"{file_name} section at ${offset:06x}: {e}") from None
    else:
        # Data subsection: emit `db` lines, breaking at any label position
        # so addresses referenced from elsewhere can resolve.
        i = 0
        while i < length:
            flat = offset + i
            if flat in labels:
                lines.append(f"{labels[flat]}:")
            end = min(i + 16, length)
            for j in range(i + 1, end):
                if (offset + j) in labels:
                    end = j
                    break
            lines.append("\tdb " + ", ".join(f"${b:02x}" for b in chunk[i:end]))
            i = end
    return lines


def emit_code_file(
    file_spec: dict[str, Any],
    rom: bytes,
    output_dir: Path,
    labels: dict[int, str],
    hw_symbols: dict[int, str],
) -> Path:
    """Emit (or update) a code file.

    Auto-managed files (header.asm, main.asm, analyzed.asm) always
    full-regen — user hand-edits to those are NOT preserved.

    Every other code file is append-only: if it already exists, scan for
    SECTION "..." directives already present in the file and skip those.
    Append any sections from map.json that aren't there yet at the end.
    This lets the user edit the file freely (whitespace, macros, RAM
    decls, custom labels) and still pull new sections into it on later
    extracts. To force one section to refresh, delete that SECTION block
    from the file; to force a full refresh, delete the whole file.
    """
    name = file_spec["name"]
    stem = Path(name).stem
    # Padding sections claim a range for coverage purposes but emit
    # nothing — rgblink's -p 0 fills the bytes since they're not assigned
    # to any SECTION. Skip them here so an entry like
    #   { "type": "padding", "addr": ..., "len": ... }
    # contributes zero output but still keeps the range out of find_gaps.
    sections = sorted(
        (s for s in file_spec["sections"] if s.get("type") != "padding"),
        key=lambda s: s["addr"],
    )
    out_path = output_dir / name
    out_path.parent.mkdir(parents=True, exist_ok=True)

    is_auto = name in AUTO_MANAGED_FILES
    extents = [] if is_auto else _existing_section_extents(out_path)

    if extents and not is_auto:
        # Append-only update keyed on address coverage. For each map.json
        # section, if its [addr, addr+len) lies inside any existing
        # SECTION's implicit extent (the user may have one big SECTION
        # claiming the whole range, or several small ones — both work),
        # leave it alone. Otherwise append.
        new_blocks: list[str] = []
        appended: list[str] = []
        for sec in sections:
            if _range_covered(extents, sec["addr"], sec["len"]):
                continue
            sec_name = f"{stem}_{sec['addr']:06x}"
            block = "\n".join(_build_section_lines(
                sec, sec_name, name, rom, labels, hw_symbols))
            new_blocks.append(block)
            appended.append(sec_name)
        if new_blocks:
            text = out_path.read_text()
            if not text.endswith("\n"):
                text += "\n"
            out_path.write_text(text + "\n" + "\n\n".join(new_blocks) + "\n")
            print(f"  {name}: appended {len(appended)} section(s): "
                  f"{', '.join(appended)}", file=sys.stderr)
        else:
            print(f"  {name}: up to date ({len(extents)} SECTION directive(s) in file "
                  f"cover all {len(sections)} map.json section(s))",
                  file=sys.stderr)
        return out_path

    # Fresh emit — either an auto-managed file or first-time generation.
    all_lines: list[str] = [GENERATED_BANNER, ""]
    for sec in sections:
        sec_name = f"{stem}_{sec['addr']:06x}"
        all_lines.extend(_build_section_lines(
            sec, sec_name, name, rom, labels, hw_symbols))
        all_lines.append("")
    out_path.write_text("\n".join(all_lines))
    return out_path


def emit_data_file(file_spec: dict[str, Any], rom: bytes, output_dir: Path) -> Path:
    name = file_spec["name"]
    offset = file_spec["addr"]
    length = file_spec["len"]
    out_path = output_dir / name
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_bytes(rom[offset:offset + length])
    return out_path


def emit_header(
    rom: bytes,
    output_dir: Path,
    labels: dict[int, str],
    hw_symbols: dict[int, str],
) -> Path:
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
    fmt_target, fmt_io = make_resolver(hw_symbols, labels, 0)
    # Entry point: bytes at $0100-$0103. Usually `nop; jp $0150`.
    i = 0
    while i < 4:
        mnem, n = decode(data, i, 0x0100 + i, fmt_target, fmt_io)
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
    labels: dict[int, str],
    output_dir: Path,
) -> Path:
    """Emit `main.asm` — the single translation unit fed to rgbasm.

    Pulls in `hardware.inc` so generated code can reference `rLCDC` etc.,
    INCLUDEs every code .asm, then wraps every data .bin in its own
    SECTION + INCBIN at the correct bank/address (with a label so the
    section's start address resolves symbolically from elsewhere).
    """
    lines: list[str] = [GENERATED_BANNER, ""]
    lines.append('INCLUDE "hardware.inc"')
    # WRAM variable declarations — included here so labels resolve in
    # every other file. Optional: if include/wram.inc isn't present
    # the build will fail loudly, but that's the same behaviour as
    # hardware.inc.
    lines.append('INCLUDE "wram.inc"')
    lines.append("")
    lines.append('INCLUDE "header.asm"')
    for asm in sorted(code_asms):
        lines.append(f'INCLUDE "{asm}"')
    lines.append("")

    for name, offset in sorted(data_bins, key=lambda x: x[1]):
        sec_name = Path(name).stem
        lines.append(section_directive(sec_name, offset))
        if offset in labels:
            lines.append(f"{labels[offset]}:")
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
    p.add_argument(
        "--include-dir",
        default=DEFAULT_INCLUDE_DIR,
        help=f"path to assembly includes (default: {DEFAULT_INCLUDE_DIR})",
    )
    args = p.parse_args(argv)

    rom_path = Path(args.rom)
    map_path = Path(args.map_file)
    output_dir = Path(args.output)

    rom = rom_path.read_bytes()
    spec = json.loads(map_path.read_text())

    reconcile_analyzed_sections(spec)

    try:
        intervals = validate_map(spec, len(rom))
        validate_padding_sections(spec, rom)
    except MapError as e:
        print(f"error: {e}", file=sys.stderr)
        return 2

    gaps = find_gaps(intervals, len(rom))

    # Fold gap regions into the spec as implicit data files so they get
    # labels assigned during the discovery pass. The on-disk emission is
    # still controlled separately below.
    gap_files: list[dict[str, Any]] = []
    for gap_addr, gap_len in gaps:
        gap_files.append({
            "type": "data",
            "name": f"data_{gap_addr:06x}.bin",
            "addr": gap_addr,
            "len": gap_len,
        })
    label_spec = {"files": list(spec.get("files", [])) + gap_files}

    hw_symbols = parse_hw_symbols(Path(args.include_dir) / HARDWARE_INC)
    refs = collect_refs(rom, label_spec)
    insn_boundaries = compute_insn_boundaries(rom, label_spec)
    sec_index = build_section_index(label_spec)
    labels = build_labels(refs, sec_index, insn_boundaries, label_spec)

    output_dir.mkdir(parents=True, exist_ok=True)

    written: list[Path] = [emit_header(rom, output_dir, labels, hw_symbols)]
    code_asms: list[str] = []
    data_bins: list[tuple[str, int]] = []

    for f in spec["files"]:
        if f["type"] == "code":
            written.append(emit_code_file(f, rom, output_dir, labels, hw_symbols))
            code_asms.append(f["name"])
        else:
            written.append(emit_data_file(f, rom, output_dir))
            data_bins.append((f["name"], f["addr"]))

    for gf in gap_files:
        written.append(emit_data_file(gf, rom, output_dir))
        data_bins.append((gf["name"], gf["addr"]))

    written.append(emit_main(code_asms, data_bins, labels, output_dir))

    for path in sorted(written):
        print(path)

    print_coverage_stats(compute_coverage(spec, len(rom)), len(rom))
    return 0


if __name__ == "__main__":
    sys.exit(main())
