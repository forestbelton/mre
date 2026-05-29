"""Unit tests for tools/extract.py.

Run with `make test` or `python3 -m unittest discover tools/tests`.

Test surface focuses on the bug classes we've actually hit:
  - decode() edge cases (STOP, illegal ops, CB-prefix, signed JR)
  - decode()'s fmt_target / fmt_io callbacks getting invoked at the
    right places with the right (kind, target) values
  - parse_hw_symbols() including alias resolution
  - resolve_target_to_flat() including the bank-0 → $4000 case that
    silently produced wrong labels until we returned None for it
  - validate_map() error paths, especially around the new "label" field
  - build_labels() honoring custom labels and the section-start vs
    referenced-position distinction
"""

import sys
import tempfile
import unittest
from pathlib import Path

# Import extract.py from the parent directory.
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import extract  # noqa: E402


# ----------------------------------------------------------------------
# decode(): opcode -> mnemonic + length
# ----------------------------------------------------------------------

class TestDecodeOpcodes(unittest.TestCase):
    def assertDecodes(self, raw: bytes, addr: int,
                      mnemonic: str, length: int) -> None:
        mnem, n = extract.decode(raw, 0, addr)
        self.assertEqual(mnem, mnemonic, f"mnemonic for {raw.hex()}")
        self.assertEqual(n, length, f"length for {raw.hex()}")

    # Block 0 ---------------------------------------------------------

    def test_nop(self):
        self.assertDecodes(b"\x00", 0, "nop", 1)

    def test_ld_bc_imm16(self):
        self.assertDecodes(b"\x01\x34\x12", 0, "ld bc, $1234", 3)

    def test_ld_mem_sp(self):
        self.assertDecodes(b"\x08\x00\xc0", 0, "ld [$c000], sp", 3)

    def test_stop_with_zero_padding(self):
        # `stop $00` — opcode 10 + padding byte 00 — assembles back as 10 00.
        self.assertDecodes(b"\x10\x00", 0, "stop", 2)

    def test_stop_with_nonzero_falls_back_to_db(self):
        # Critical: rgbasm always assembles bare `stop` as 10 00, so a
        # 10 XX where XX != 00 must NOT be emitted as `stop` or the
        # roundtrip breaks. We caught this on the first ROM extract.
        self.assertDecodes(b"\x10\x3f", 0, "db $10", 1)

    def test_jr_positive(self):
        # JR +4 at $0150 → target = $0150 + 2 + 4 = $0156
        self.assertDecodes(b"\x18\x04", 0x0150, "jr $0156", 2)

    def test_jr_negative(self):
        # JR -3 at $0150 → target = $0150 + 2 - 3 = $014f
        self.assertDecodes(b"\x18\xfd", 0x0150, "jr $014f", 2)

    def test_jr_conditional(self):
        self.assertDecodes(b"\x20\x04", 0x0150, "jr nz, $0156", 2)
        self.assertDecodes(b"\x28\x04", 0x0150, "jr z, $0156", 2)
        self.assertDecodes(b"\x30\x04", 0x0150, "jr nc, $0156", 2)
        self.assertDecodes(b"\x38\x04", 0x0150, "jr c, $0156", 2)

    def test_inc_dec_reg(self):
        self.assertDecodes(b"\x04", 0, "inc b", 1)
        self.assertDecodes(b"\x05", 0, "dec b", 1)
        self.assertDecodes(b"\x34", 0, "inc [hl]", 1)
        self.assertDecodes(b"\x3c", 0, "inc a", 1)

    def test_ld_reg_imm8(self):
        self.assertDecodes(b"\x3e\x42", 0, "ld a, $42", 2)
        self.assertDecodes(b"\x06\xff", 0, "ld b, $ff", 2)

    # Block 1: ld r, r' (0x76 is HALT)
    def test_ld_reg_reg(self):
        self.assertDecodes(b"\x40", 0, "ld b, b", 1)
        self.assertDecodes(b"\x47", 0, "ld b, a", 1)
        self.assertDecodes(b"\x7e", 0, "ld a, [hl]", 1)

    def test_halt(self):
        self.assertDecodes(b"\x76", 0, "halt", 1)

    # Block 2: ALU A, r
    def test_alu_reg(self):
        self.assertDecodes(b"\x80", 0, "add a, b", 1)
        self.assertDecodes(b"\xaf", 0, "xor a", 1)
        self.assertDecodes(b"\xbe", 0, "cp [hl]", 1)

    # Block 3 ---------------------------------------------------------

    def test_call_imm16(self):
        self.assertDecodes(b"\xcd\x50\x01", 0, "call $0150", 3)

    def test_call_conditional(self):
        self.assertDecodes(b"\xc4\x00\x40", 0, "call nz, $4000", 3)

    def test_jp_imm16(self):
        self.assertDecodes(b"\xc3\x50\x01", 0, "jp $0150", 3)

    def test_jp_conditional(self):
        self.assertDecodes(b"\xc2\x50\x01", 0, "jp nz, $0150", 3)

    def test_jp_hl(self):
        self.assertDecodes(b"\xe9", 0, "jp hl", 1)

    def test_ret_and_friends(self):
        self.assertDecodes(b"\xc9", 0, "ret", 1)
        self.assertDecodes(b"\xd9", 0, "reti", 1)
        self.assertDecodes(b"\xc0", 0, "ret nz", 1)

    def test_rst(self):
        self.assertDecodes(b"\xc7", 0, "rst $00", 1)
        self.assertDecodes(b"\xff", 0, "rst $38", 1)

    def test_ldh_n_a(self):
        # Default fmt_io expands the 8-bit operand to the full $ffNN.
        self.assertDecodes(b"\xe0\x40", 0, "ldh [$ff40], a", 2)

    def test_ldh_a_n(self):
        self.assertDecodes(b"\xf0\x44", 0, "ldh a, [$ff44]", 2)

    def test_ld_mem_a(self):
        self.assertDecodes(b"\xea\x34\x12", 0, "ld [$1234], a", 3)

    def test_ld_a_mem(self):
        self.assertDecodes(b"\xfa\x34\x12", 0, "ld a, [$1234]", 3)

    def test_add_sp_signed(self):
        self.assertDecodes(b"\xe8\x05", 0, "add sp, 5", 2)
        self.assertDecodes(b"\xe8\xfb", 0, "add sp, -5", 2)

    def test_ld_hl_sp_signed(self):
        self.assertDecodes(b"\xf8\x05", 0, "ld hl, sp+5", 2)
        self.assertDecodes(b"\xf8\xfb", 0, "ld hl, sp-5", 2)

    def test_illegal_opcodes_become_db(self):
        # $D3 $DB $DD $E3 $E4 $EB $EC $ED $F4 $FC $FD are all illegal.
        for op in (0xd3, 0xdb, 0xdd, 0xe3, 0xe4, 0xeb, 0xec, 0xed, 0xf4, 0xfc, 0xfd):
            self.assertDecodes(bytes([op]), 0, f"db ${op:02x}", 1)

    def test_truncated_multibyte_falls_back(self):
        # `jp $nnnn` wants 3 bytes; one byte alone must degrade.
        self.assertDecodes(b"\xc3", 0, "db $c3", 1)

    # CB prefix -------------------------------------------------------

    def test_cb_rotate_shift(self):
        self.assertDecodes(b"\xcb\x07", 0, "rlc a", 2)
        self.assertDecodes(b"\xcb\x10", 0, "rl b", 2)
        self.assertDecodes(b"\xcb\x36", 0, "swap [hl]", 2)

    def test_cb_bit_res_set(self):
        self.assertDecodes(b"\xcb\x40", 0, "bit 0, b", 2)
        self.assertDecodes(b"\xcb\x80", 0, "res 0, b", 2)
        self.assertDecodes(b"\xcb\xc0", 0, "set 0, b", 2)
        self.assertDecodes(b"\xcb\x7e", 0, "bit 7, [hl]", 2)


# ----------------------------------------------------------------------
# decode() callback wiring
# ----------------------------------------------------------------------

class TestDecodeCallbacks(unittest.TestCase):
    def test_fmt_target_for_jp(self):
        seen = []
        def fmt(kind, t): seen.append((kind, t)); return f"Sym_{t:04x}"
        mnem, _ = extract.decode(b"\xc3\x34\x12", 0, 0, fmt_target=fmt)
        self.assertEqual(mnem, "jp Sym_1234")
        self.assertEqual(seen, [("code", 0x1234)])

    def test_fmt_target_for_conditional_call(self):
        seen = []
        def fmt(kind, t): seen.append((kind, t)); return f"X_{t:04x}"
        mnem, _ = extract.decode(b"\xc4\x00\x40", 0, 0, fmt_target=fmt)
        self.assertEqual(mnem, "call nz, X_4000")
        self.assertEqual(seen, [("code", 0x4000)])

    def test_fmt_target_for_jr(self):
        seen = []
        def fmt(kind, t): seen.append((kind, t)); return "L"
        mnem, _ = extract.decode(b"\x18\x04", 0, 0x0150, fmt_target=fmt)
        self.assertEqual(mnem, "jr L")
        # JR target is the resolved 16-bit address, not the raw signed byte.
        self.assertEqual(seen, [("code", 0x0156)])

    def test_fmt_target_for_ld_mem(self):
        seen = []
        def fmt(kind, t): seen.append((kind, t)); return f"D_{t:04x}"
        mnem, _ = extract.decode(b"\xfa\x00\xc0", 0, 0, fmt_target=fmt)
        self.assertEqual(mnem, "ld a, [D_c000]")
        self.assertEqual(seen, [("data", 0xc000)])

    def test_fmt_target_for_ld_mem_sp(self):
        seen = []
        def fmt(kind, t): seen.append((kind, t)); return f"D_{t:04x}"
        mnem, _ = extract.decode(b"\x08\x00\xc0", 0, 0, fmt_target=fmt)
        self.assertEqual(mnem, "ld [D_c000], sp")
        self.assertEqual(seen, [("data", 0xc000)])

    def test_fmt_io_for_ldh(self):
        seen = []
        def fmt(addr): seen.append(addr); return "rLCDC"
        mnem, _ = extract.decode(b"\xe0\x40", 0, 0, fmt_io=fmt)
        self.assertEqual(mnem, "ldh [rLCDC], a")
        self.assertEqual(seen, [0xff40])

    def test_ldh_c_does_not_invoke_callback(self):
        # `ldh [c], a` has no address operand — fmt_io shouldn't fire.
        seen = []
        def fmt(addr): seen.append(addr); return "X"
        mnem, _ = extract.decode(b"\xe2", 0, 0, fmt_io=fmt)
        self.assertEqual(mnem, "ldh [c], a")
        self.assertEqual(seen, [])

    def test_immediate_loads_do_not_invoke_callback(self):
        # `ld bc, $1234` is a 16-bit immediate, not a memory operand —
        # we intentionally don't treat it as a reference.
        seen = []
        def fmt(kind, t): seen.append((kind, t)); return "X"
        extract.decode(b"\x01\x34\x12", 0, 0, fmt_target=fmt)
        self.assertEqual(seen, [])


# ----------------------------------------------------------------------
# parse_hw_symbols()
# ----------------------------------------------------------------------

class TestParseHwSymbols(unittest.TestCase):
    def _write(self, td: str, content: str) -> Path:
        p = Path(td) / "hardware.inc"
        p.write_text(content)
        return p

    def test_direct_definitions(self):
        with tempfile.TemporaryDirectory() as td:
            p = self._write(td,
                "def rJOYP equ $FF00\n"
                "def rLCDC equ $FF40\n"
                "def rIE equ $FFFF\n")
            syms = extract.parse_hw_symbols(p)
            self.assertEqual(syms[0xff00], "rJOYP")
            self.assertEqual(syms[0xff40], "rLCDC")
            self.assertEqual(syms[0xffff], "rIE")

    def test_alias_resolves_to_target_address(self):
        with tempfile.TemporaryDirectory() as td:
            p = self._write(td,
                "def rAUDENA equ $FF26\n"
                "def rNR52 equ rAUDENA\n")
            syms = extract.parse_hw_symbols(p)
            # First name wins (canonical names precede aliases).
            self.assertEqual(syms[0xff26], "rAUDENA")

    def test_first_name_wins(self):
        with tempfile.TemporaryDirectory() as td:
            p = self._write(td,
                "def rFIRST equ $FF40\n"
                "def rSECOND equ $FF40\n")
            self.assertEqual(extract.parse_hw_symbols(p)[0xff40], "rFIRST")

    def test_excludes_below_ff00(self):
        with tempfile.TemporaryDirectory() as td:
            p = self._write(td,
                "def WRAM equ $C000\n"
                "def rIO equ $FF40\n")
            syms = extract.parse_hw_symbols(p)
            self.assertNotIn(0xc000, syms)
            self.assertIn(0xff40, syms)

    def test_missing_file_is_empty(self):
        self.assertEqual(extract.parse_hw_symbols(Path("/nope/not/here.inc")), {})

    def test_ignores_comments_and_whitespace(self):
        with tempfile.TemporaryDirectory() as td:
            p = self._write(td,
                "; a comment line\n"
                "\n"
                "    def rLCDC equ $FF40    ; inline comment\n"
                "DEF rSTAT EQU $FF41\n"  # case-insensitive
                )
            syms = extract.parse_hw_symbols(p)
            self.assertEqual(syms[0xff40], "rLCDC")
            self.assertEqual(syms[0xff41], "rSTAT")


# ----------------------------------------------------------------------
# Bank / address helpers
# ----------------------------------------------------------------------

class TestBankAddr(unittest.TestCase):
    def test_offset_to_bank_addr_bank0(self):
        self.assertEqual(extract.rom_offset_to_bank_addr(0x0000), (0, 0x0000))
        self.assertEqual(extract.rom_offset_to_bank_addr(0x3fff), (0, 0x3fff))

    def test_offset_to_bank_addr_bank1(self):
        self.assertEqual(extract.rom_offset_to_bank_addr(0x4000), (1, 0x4000))
        self.assertEqual(extract.rom_offset_to_bank_addr(0x7fff), (1, 0x7fff))

    def test_offset_to_bank_addr_higher_bank(self):
        # Flat 0x8000 = start of bank 2 → memory $4000
        self.assertEqual(extract.rom_offset_to_bank_addr(0x8000), (2, 0x4000))
        # Flat 0xab1234 → bank 0x2ac (offset // 0x4000),
        # low 14 bits 0x1234 → memory 0x5234.
        self.assertEqual(extract.rom_offset_to_bank_addr(0xab1234), (0x2ac, 0x5234))

    def test_resolve_target_in_bank0(self):
        self.assertEqual(extract.resolve_target_to_flat(0, 0x0150), 0x0150)
        self.assertEqual(extract.resolve_target_to_flat(5, 0x0150), 0x0150)
        self.assertEqual(extract.resolve_target_to_flat(0, 0x3fff), 0x3fff)

    def test_resolve_target_in_high_bank_assumes_source_bank(self):
        self.assertEqual(extract.resolve_target_to_flat(1, 0x4000), 0x4000)
        self.assertEqual(extract.resolve_target_to_flat(2, 0x5234), 0x9234)

    def test_resolve_bank0_into_high_returns_none(self):
        # The bug we caught: bank 0 calling $4000 doesn't tell us which
        # bank is loaded, so we must NOT pick "bank 0 + ($4000 - $4000)
        # = flat 0" — that re-targets to the start of bank 0.
        self.assertIsNone(extract.resolve_target_to_flat(0, 0x4000))
        self.assertIsNone(extract.resolve_target_to_flat(0, 0x7fff))

    def test_resolve_target_outside_rom_returns_none(self):
        self.assertIsNone(extract.resolve_target_to_flat(1, 0xc000))
        self.assertIsNone(extract.resolve_target_to_flat(0, 0xff00))


# ----------------------------------------------------------------------
# validate_map() — error paths
# ----------------------------------------------------------------------

class TestValidateMap(unittest.TestCase):
    ROM_SIZE = 0x10000

    def _v(self, spec):
        return extract.validate_map(spec, self.ROM_SIZE)

    def test_empty_files_ok(self):
        # Only the header reservation appears.
        intervals = self._v({"files": []})
        self.assertEqual(len(intervals), 1)

    def test_missing_files_key_rejected(self):
        with self.assertRaises(extract.MapError):
            self._v({})

    def test_header_name_reserved(self):
        with self.assertRaises(extract.MapError):
            self._v({"files": [{"type": "code", "name": "header.asm",
                                "sections": [{"type": "code", "addr": 0x200, "len": 4}]}]})

    def test_duplicate_filename(self):
        with self.assertRaises(extract.MapError):
            self._v({"files": [
                {"type": "code", "name": "x.asm",
                 "sections": [{"type": "code", "addr": 0x200, "len": 4}]},
                {"type": "data", "name": "x.asm", "addr": 0x300, "len": 4},
            ]})

    def test_overlapping_sections_rejected(self):
        with self.assertRaises(extract.MapError):
            self._v({"files": [
                {"type": "code", "name": "a.asm",
                 "sections": [{"type": "code", "addr": 0x200, "len": 10}]},
                {"type": "code", "name": "b.asm",
                 "sections": [{"type": "code", "addr": 0x205, "len": 10}]},
            ]})

    def test_section_overlapping_header(self):
        with self.assertRaises(extract.MapError):
            self._v({"files": [{"type": "code", "name": "x.asm", "sections": [
                {"type": "code", "addr": 0x0140, "len": 0x20}  # spans into 0x14F
            ]}]})

    def test_out_of_bounds(self):
        with self.assertRaises(extract.MapError):
            self._v({"files": [{"type": "code", "name": "x.asm", "sections": [
                {"type": "code", "addr": 0x200, "len": self.ROM_SIZE}
            ]}]})

    def test_unknown_file_type(self):
        with self.assertRaises(extract.MapError):
            self._v({"files": [{"type": "rom", "name": "x.asm"}]})

    def test_label_valid(self):
        self._v({"files": [{"type": "code", "name": "x.asm", "sections": [
            {"type": "code", "addr": 0x200, "len": 4, "label": "MyFunc"}
        ]}]})  # should not raise

    def test_label_must_be_identifier(self):
        for bad in ("123start", "with-dash", "with.dot", "with space", ""):
            with self.subTest(label=bad):
                with self.assertRaises(extract.MapError):
                    self._v({"files": [{"type": "code", "name": "x.asm", "sections": [
                        {"type": "code", "addr": 0x200, "len": 4, "label": bad}
                    ]}]})

    def test_duplicate_label(self):
        with self.assertRaises(extract.MapError):
            self._v({"files": [{"type": "code", "name": "x.asm", "sections": [
                {"type": "code", "addr": 0x200, "len": 4, "label": "Foo"},
                {"type": "code", "addr": 0x300, "len": 4, "label": "Foo"},
            ]}]})

    def test_label_on_data_file_ok(self):
        self._v({"files": [
            {"type": "data", "name": "tbl.bin", "addr": 0x1000, "len": 4,
             "label": "MyTable"}
        ]})


# ----------------------------------------------------------------------
# Section index + label building
# ----------------------------------------------------------------------

class TestSectionIndex(unittest.TestCase):
    def test_owner_assignment(self):
        spec = {"files": [
            {"type": "code", "name": "x.asm", "sections": [
                {"type": "code", "addr": 0x200, "len": 4},
                {"type": "data", "addr": 0x210, "len": 4},
            ]},
            {"type": "data", "name": "y.bin", "addr": 0x300, "len": 10},
        ]}
        index = extract.build_section_index(spec)
        by_start = {s[0]: s for s in index}
        # (start, end, kind, owner)
        self.assertEqual(by_start[0x200][3], "code-file")
        self.assertEqual(by_start[0x210][3], "code-file")
        self.assertEqual(by_start[0x300][3], "data-file")
        self.assertEqual(by_start[extract.HEADER_START][3], "header")

    def test_section_at_lookup(self):
        spec = {"files": [{"type": "code", "name": "x.asm", "sections": [
            {"type": "code", "addr": 0x200, "len": 4}
        ]}]}
        index = extract.build_section_index(spec)
        # Start, interior, just-past-end.
        self.assertEqual(extract.section_at(index, 0x200)[0], 0x200)
        self.assertEqual(extract.section_at(index, 0x203)[0], 0x200)
        self.assertIsNone(extract.section_at(index, 0x204))  # one past end
        self.assertIsNone(extract.section_at(index, 0x500))


class TestBuildLabels(unittest.TestCase):
    def _empty_rom(self) -> bytes:
        return bytes(0x10000)

    def _build(self, spec, rom=None):
        rom = rom or self._empty_rom()
        sec_index = extract.build_section_index(spec)
        boundaries = extract.compute_insn_boundaries(rom, spec)
        refs = extract.collect_refs(rom, spec)
        return extract.build_labels(refs, sec_index, boundaries, spec)

    def test_section_start_gets_auto_label(self):
        spec = {"files": [{"type": "code", "name": "x.asm", "sections": [
            {"type": "code", "addr": 0x200, "len": 4}
        ]}]}
        labels = self._build(spec)
        self.assertEqual(labels[0x200], "Func_00_0200")

    def test_data_section_start_gets_data_prefix(self):
        spec = {"files": [{"type": "code", "name": "x.asm", "sections": [
            {"type": "data", "addr": 0x200, "len": 4}
        ]}]}
        labels = self._build(spec)
        self.assertEqual(labels[0x200], "Data_00_0200")

    def test_custom_label_overrides_auto(self):
        spec = {"files": [{"type": "code", "name": "x.asm", "sections": [
            {"type": "code", "addr": 0x200, "len": 4, "label": "MyEntry"}
        ]}]}
        labels = self._build(spec)
        self.assertEqual(labels[0x200], "MyEntry")

    def test_top_level_data_label_override(self):
        spec = {"files": [
            {"type": "data", "name": "tbl.bin", "addr": 0x1000, "len": 10,
             "label": "PointerTable"}
        ]}
        labels = self._build(spec)
        self.assertEqual(labels[0x1000], "PointerTable")

    def test_referenced_address_inside_section_gets_label(self):
        # A small program at $0200 that JPs to $0210. $0210 must also
        # be a valid emission point (start of an instruction there).
        rom = bytearray(0x10000)
        rom[0x200:0x203] = bytes.fromhex("c31002")  # jp $0210
        rom[0x210:0x211] = bytes.fromhex("c9")      # ret
        spec = {"files": [{"type": "code", "name": "x.asm", "sections": [
            {"type": "code", "addr": 0x200, "len": 3},
            {"type": "code", "addr": 0x210, "len": 1},
        ]}]}
        labels = self._build(spec, bytes(rom))
        # Section starts always labeled.
        self.assertEqual(labels[0x200], "Func_00_0200")
        self.assertEqual(labels[0x210], "Func_00_0210")

    def test_label_not_assigned_mid_instruction(self):
        # JP $0201 — target falls in the middle of the 3-byte JP at
        # $0200. build_labels must NOT define a label there.
        rom = bytearray(0x10000)
        rom[0x200:0x203] = bytes.fromhex("c30102")  # jp $0201 (mid-self)
        spec = {"files": [{"type": "code", "name": "x.asm", "sections": [
            {"type": "code", "addr": 0x200, "len": 3},
        ]}]}
        labels = self._build(spec, bytes(rom))
        self.assertIn(0x200, labels)         # section start
        self.assertNotIn(0x201, labels)      # mid-instruction


# ----------------------------------------------------------------------
# ascii / asciz section types
# ----------------------------------------------------------------------

class TestAsciiFormat(unittest.TestCase):
    def test_printable_collapse_to_string(self):
        self.assertEqual(extract._format_ascii_db(b"Hello"), ['\tdb "Hello"'])

    def test_escape_quote_and_backslash(self):
        # "Say \"hi\\\""  →  "Say \"hi\\\""  → bytes: Say "hi\""
        raw = b'Say "hi\\"'
        # Rendered with backslash-escapes inside the literal.
        # Each `"` becomes `\"`, each `\` becomes `\\`.
        # raw = S a y  " h i \ "
        # escaped = S a y \" h i \\ \"
        self.assertEqual(extract._format_ascii_db(raw),
                         ['\tdb "Say \\"hi\\\\\\""'])

    def test_non_printable_break_out(self):
        # "He" + $00 + "lo"
        self.assertEqual(extract._format_ascii_db(b"He\x00lo"),
                         ['\tdb "He", $00, "lo"'])

    def test_empty_data(self):
        self.assertEqual(extract._format_ascii_db(b""), [])

    def test_all_non_printable(self):
        self.assertEqual(extract._format_ascii_db(b"\x01\x02\x03"),
                         ['\tdb $01, $02, $03'])


class TestAscizFormat(unittest.TestCase):
    def test_simple(self):
        self.assertEqual(extract._format_ascii_db(b"Hi\x00", trailing_terminator=True),
                         ['\tdb "Hi", 0'])

    def test_with_break_out(self):
        self.assertEqual(extract._format_ascii_db(b"H\x07i\x00", trailing_terminator=True),
                         ['\tdb "H", $07, "i", 0'])

    def test_only_null(self):
        # Just the terminator: no string body before the trailing 0.
        self.assertEqual(extract._format_ascii_db(b"\x00", trailing_terminator=True),
                         ['\tdb 0'])

    def test_missing_terminator_raises(self):
        with self.assertRaises(ValueError):
            extract._format_ascii_db(b"Hi", trailing_terminator=True)

    def test_empty_raises(self):
        with self.assertRaises(ValueError):
            extract._format_ascii_db(b"", trailing_terminator=True)


class TestParseWramSymbols(unittest.TestCase):
    def _write(self, body, tmpdir):
        path = Path(tmpdir) / "wram.inc"
        path.write_text(body)
        return path

    def test_basic_section_and_labels(self):
        with tempfile.TemporaryDirectory() as td:
            path = self._write("""\
SECTION "wram_npc_state", WRAMX[$D0DC], BANK[1]

wRanchProgress::    ds 1
wNajiState::        ds 1
                    ds 1
wTowerExplained::   ds 1
""", td)
            sym = extract.parse_wram_symbols(path)
            self.assertEqual(sym[0xD0DC], "wRanchProgress")
            self.assertEqual(sym[0xD0DD], "wNajiState")
            self.assertNotIn(0xD0DE, sym)        # anonymous ds advances cursor
            self.assertEqual(sym[0xD0DF], "wTowerExplained")

    def test_wram0_section(self):
        with tempfile.TemporaryDirectory() as td:
            path = self._write("""\
SECTION "wram_floor_state", WRAM0[$CFF0]
wCFF0::             ds 1
                    ds 1
wCurrentFloor::     ds 1
""", td)
            sym = extract.parse_wram_symbols(path)
            self.assertEqual(sym[0xCFF0], "wCFF0")
            self.assertEqual(sym[0xCFF2], "wCurrentFloor")

    def test_multibyte_ds_advances_cursor(self):
        with tempfile.TemporaryDirectory() as td:
            path = self._write("""\
SECTION "wram_text", WRAMX[$D614], BANK[1]
wTextAnchor::       ds 2
wTextCursor::       ds 2
wTextWidth::        ds 1
""", td)
            sym = extract.parse_wram_symbols(path)
            self.assertEqual(sym[0xD614], "wTextAnchor")
            self.assertEqual(sym[0xD616], "wTextCursor")
            self.assertEqual(sym[0xD618], "wTextWidth")

    def test_comments_dont_confuse_parser(self):
        with tempfile.TemporaryDirectory() as td:
            path = self._write("""\
; this is a comment about ds 99 and label::
SECTION "wram_x", WRAMX[$D000], BANK[1]
wX::                ds 1    ; another comment mentioning ds 5
""", td)
            sym = extract.parse_wram_symbols(path)
            self.assertEqual(sym, {0xD000: "wX"})

    def test_addresses_outside_wram_dropped(self):
        # Sanity: an SRAM-style address would be ignored even if someone
        # accidentally declared one with WRAM0/WRAMX syntax.
        with tempfile.TemporaryDirectory() as td:
            path = self._write("""\
SECTION "x", WRAMX[$E000], BANK[1]
shouldBeDropped::   ds 1
""", td)
            sym = extract.parse_wram_symbols(path)
            self.assertEqual(sym, {})

    def test_missing_file_is_empty(self):
        with tempfile.TemporaryDirectory() as td:
            sym = extract.parse_wram_symbols(Path(td) / "absent.inc")
            self.assertEqual(sym, {})


class TestResolverWithWramSymbols(unittest.TestCase):
    def test_wram_target_resolves_to_symbol(self):
        fmt_target, _ = extract.make_resolver(
            hw_symbols={}, labels={}, sec_bank=0,
            wram_symbols={0xD617: "wTextCursorHi"},
        )
        self.assertEqual(fmt_target("data", 0xD617), "wTextCursorHi")

    def test_wram_miss_falls_back_to_hex(self):
        fmt_target, _ = extract.make_resolver(
            hw_symbols={}, labels={}, sec_bank=0,
            wram_symbols={0xD617: "wTextCursorHi"},
        )
        # Address inside WRAM range but no symbol registered for it.
        self.assertEqual(fmt_target("data", 0xD618), "$d618")

    def test_hw_symbols_still_take_priority_in_ff_range(self):
        # The $FF00+ branch comes before the WRAM branch in make_resolver,
        # so an IO register name resolves even if a junk WRAM entry exists.
        fmt_target, _ = extract.make_resolver(
            hw_symbols={0xFF40: "rLCDC"}, labels={}, sec_bank=0,
            wram_symbols={},
        )
        self.assertEqual(fmt_target("data", 0xFF40), "rLCDC")

    def test_resolver_works_without_wram_symbols_argument(self):
        # Backwards-compat: omit the new wram_symbols arg entirely.
        fmt_target, _ = extract.make_resolver(
            hw_symbols={}, labels={}, sec_bank=0,
        )
        self.assertEqual(fmt_target("data", 0xD617), "$d617")


class TestUserLabels(unittest.TestCase):
    """Top-level `labels` array in map.json overrides auto-generated names."""

    def _build(self, user_labels, sections):
        return {
            "files": [{"type": "code", "name": "x.asm", "sections": sections}],
            "labels": user_labels,
        }

    def test_user_label_replaces_func_default(self):
        spec = self._build(
            user_labels=[{"addr": 0x3a14, "name": "ScriptOpcode01_InitTextState"}],
            sections=[{"type": "code", "addr": 0x3a14, "len": 0x10}],
        )
        labels = extract.build_labels([], [], set(), spec)
        self.assertEqual(labels[0x3a14], "ScriptOpcode01_InitTextState")

    def test_user_label_wins_over_section_label_field(self):
        spec = self._build(
            user_labels=[{"addr": 0x3a14, "name": "UserWins"}],
            sections=[{"type": "code", "addr": 0x3a14, "len": 0x10, "label": "SectionWins"}],
        )
        labels = extract.build_labels([], [], set(), spec)
        self.assertEqual(labels[0x3a14], "UserWins")

    def test_user_label_at_unknown_addr_still_recorded(self):
        # An override at an address that isn't a section start is fine —
        # the label only emits if something references that byte, but the
        # mapping is still in the dict for downstream lookups.
        spec = self._build(
            user_labels=[{"addr": 0x4000, "name": "RandomLabel"}],
            sections=[{"type": "code", "addr": 0x3a14, "len": 0x10}],
        )
        labels = extract.build_labels([], [], set(), spec)
        self.assertEqual(labels[0x4000], "RandomLabel")

    def test_missing_labels_field_is_noop(self):
        labels = extract.build_labels([], [], set(), {"files": []})
        self.assertEqual(labels, {})

    def test_malformed_entries_silently_skipped(self):
        # Non-dict entries, missing addr/name — all just dropped, no crash.
        spec = {
            "files": [],
            "labels": [
                "not a dict",
                {"addr": 0x100},                       # missing name
                {"name": "OnlyName"},                  # missing addr
                {"addr": "not-int", "name": "X"},      # bad type
                {"addr": 0x200, "name": "GoodOne"},    # this one should land
            ],
        }
        labels = extract.build_labels([], [], set(), spec)
        self.assertEqual(labels, {0x200: "GoodOne"})


class TestPaddingSections(unittest.TestCase):
    def test_padding_type_accepted_by_validate_map(self):
        # Just a structural check — validate_map shouldn't reject padding.
        extract.validate_map({"files": [
            {"type": "code", "name": "p.asm", "sections": [
                {"type": "padding", "addr": 0x4000, "len": 0x100, "label": "P"}
            ]}
        ]}, rom_size=0x8000)

    def test_validate_padding_accepts_zero_bytes(self):
        rom = bytes(0x1000)
        extract.validate_padding_sections({"files": [
            {"type": "code", "name": "p.asm", "sections": [
                {"type": "padding", "addr": 0x200, "len": 0x100, "label": "P"}
            ]}
        ]}, rom)

    def test_validate_padding_rejects_nonzero(self):
        rom = bytearray(0x1000)
        rom[0x250] = 0x42  # poisoned byte inside the claimed padding range
        with self.assertRaises(extract.MapError) as ctx:
            extract.validate_padding_sections({"files": [
                {"type": "code", "name": "p.asm", "sections": [
                    {"type": "padding", "addr": 0x200, "len": 0x100, "label": "P"}
                ]}
            ]}, bytes(rom))
        # Caller should see the address of the offending byte.
        self.assertIn("$000250", str(ctx.exception))
        self.assertIn("$42", str(ctx.exception))

    def test_validate_padding_ignores_non_padding(self):
        # A code or data section with non-zero bytes is fine; only padding
        # sections trigger the zero-check.
        rom = bytes([0x42] * 0x1000)
        extract.validate_padding_sections({"files": [
            {"type": "code", "name": "p.asm", "sections": [
                {"type": "data", "addr": 0x200, "len": 0x100, "label": "D"}
            ]}
        ]}, rom)

    def test_padding_counted_as_user_padding(self):
        spec = {"files": [{"type": "code", "name": "p.asm", "sections": [
            {"type": "padding", "addr": 0x200, "len": 0x100, "label": "P"}
        ]}]}
        c = extract.compute_coverage(spec, 0x10000)
        self.assertEqual(c["user_padding"], 0x100)
        # And not double-counted as uncovered.
        self.assertEqual(c["uncovered"], 0x10000 - 0x100 - (extract.HEADER_END - extract.HEADER_START))


class TestComputeCoverage(unittest.TestCase):
    ROM = 0x10000

    def test_uncovered_when_empty(self):
        c = extract.compute_coverage({"files": []}, self.ROM)
        # Header is always fenced off.
        self.assertEqual(c["header"], extract.HEADER_END - extract.HEADER_START)
        self.assertEqual(c["uncovered"], self.ROM - c["header"])
        self.assertEqual(c["user_code"], 0)
        self.assertEqual(c["analyzed_code"], 0)

    def test_user_curated_wins_over_analyzer(self):
        # Same byte range claimed by both; user wins.
        spec = {"files": [
            {"type": "code", "name": "x.asm", "sections": [
                {"type": "code", "addr": 0x500, "len": 0x100}
            ]},
            {"type": "code", "name": "analyzed.asm", "sections": [
                {"type": "data", "addr": 0x500, "len": 0x100}
            ]},
        ]}
        c = extract.compute_coverage(spec, self.ROM)
        self.assertEqual(c["user_code"], 0x100)
        self.assertEqual(c["analyzed_data"], 0)

    def test_conflict_overlays_analyzed(self):
        spec = {
            "files": [{"type": "code", "name": "analyzed.asm", "sections": [
                {"type": "data", "addr": 0x500, "len": 0x100}
            ]}],
            "conflicts": [{"addr": 0x540, "len": 0x10}],
        }
        c = extract.compute_coverage(spec, self.ROM)
        # 0x540..0x54F (16 bytes) become conflict; the rest of $500..$5FF stays
        # tagged as analyzer data.
        self.assertEqual(c["conflict"], 0x10)
        self.assertEqual(c["analyzed_data"], 0x100 - 0x10)

    def test_all_section_types_counted(self):
        spec = {"files": [{"type": "code", "name": "x.asm", "sections": [
            {"type": "code",  "addr": 0x200, "len": 4},
            {"type": "data",  "addr": 0x300, "len": 8},
            {"type": "ascii", "addr": 0x400, "len": 5},
            {"type": "asciz", "addr": 0x500, "len": 6},
        ]}]}
        c = extract.compute_coverage(spec, self.ROM)
        self.assertEqual(c["user_code"], 4)
        self.assertEqual(c["user_data"], 8)
        self.assertEqual(c["user_ascii"], 5)
        self.assertEqual(c["user_asciz"], 6)

    def test_counts_sum_to_rom_size(self):
        spec = {
            "files": [
                {"type": "code", "name": "x.asm", "sections": [
                    {"type": "code", "addr": 0x200, "len": 0x100, "label": "X"}
                ]},
                {"type": "code", "name": "analyzed.asm", "sections": [
                    {"type": "data", "addr": 0x1000, "len": 0x200},
                    {"type": "code", "addr": 0x2000, "len": 0x100},
                ]},
            ],
            "conflicts": [{"addr": 0x1100, "len": 0x40}],
        }
        c = extract.compute_coverage(spec, self.ROM)
        self.assertEqual(sum(c.values()), self.ROM)


class TestReconcileAnalyzedSections(unittest.TestCase):
    """Auto-split of analyzed.asm sections around user-curated entries."""

    @staticmethod
    def _build(user_intervals, analyzed_sections):
        files = []
        for i, (a, l) in enumerate(user_intervals):
            files.append({
                "type": "code",
                "name": f"user_{i}.asm",
                "sections": [{"type": "data", "addr": a, "len": l, "label": f"L{i}"}],
            })
        files.append({
            "type": "code",
            "name": "analyzed.asm",
            "sections": [{"type": s[0], "addr": s[1], "len": s[2]} for s in analyzed_sections],
        })
        return {"files": files}

    def _analyzed(self, spec):
        a = next(f for f in spec["files"] if f["name"] == "analyzed.asm")
        return [(s["type"], s["addr"], s["len"]) for s in a["sections"]]

    def test_no_overlap_unchanged(self):
        spec = self._build([(0x500, 0x100)], [("data", 0x100, 0x200), ("code", 0x800, 0x100)])
        extract.reconcile_analyzed_sections(spec)
        self.assertEqual(self._analyzed(spec),
                         [("data", 0x100, 0x200), ("code", 0x800, 0x100)])

    def test_full_containment_removes_section(self):
        spec = self._build([(0x200, 0x400)], [("data", 0x300, 0x100)])
        extract.reconcile_analyzed_sections(spec)
        self.assertEqual(self._analyzed(spec), [])

    def test_left_overlap_shrinks_right(self):
        spec = self._build([(0x200, 0x100)], [("data", 0x280, 0x200)])
        extract.reconcile_analyzed_sections(spec)
        self.assertEqual(self._analyzed(spec), [("data", 0x300, 0x180)])

    def test_right_overlap_shrinks_left(self):
        spec = self._build([(0x400, 0x100)], [("data", 0x300, 0x200)])
        extract.reconcile_analyzed_sections(spec)
        self.assertEqual(self._analyzed(spec), [("data", 0x300, 0x100)])

    def test_middle_overlap_splits_into_two(self):
        spec = self._build([(0x300, 0x100)], [("data", 0x200, 0x400)])
        extract.reconcile_analyzed_sections(spec)
        self.assertEqual(self._analyzed(spec),
                         [("data", 0x200, 0x100), ("data", 0x400, 0x200)])

    def test_multiple_overlaps_in_one_section(self):
        spec = self._build([(0x300, 0x100), (0x500, 0x100)],
                           [("data", 0x200, 0x500)])
        extract.reconcile_analyzed_sections(spec)
        self.assertEqual(self._analyzed(spec),
                         [("data", 0x200, 0x100),
                          ("data", 0x400, 0x100),
                          ("data", 0x600, 0x100)])

    def test_preserves_extra_fields(self):
        # Sections carry through `type` and any other keys when split.
        spec = self._build([(0x300, 0x100)], [("code", 0x200, 0x400)])
        extract.reconcile_analyzed_sections(spec)
        # 'code' type preserved on both pieces.
        types = [s[0] for s in self._analyzed(spec)]
        self.assertEqual(types, ["code", "code"])

    def test_idempotent(self):
        spec = self._build([(0x300, 0x100)], [("data", 0x200, 0x400)])
        extract.reconcile_analyzed_sections(spec)
        first = self._analyzed(spec)
        extract.reconcile_analyzed_sections(spec)
        self.assertEqual(self._analyzed(spec), first)

    def test_no_user_intervals_unchanged(self):
        spec = self._build([], [("data", 0x100, 0x200)])
        extract.reconcile_analyzed_sections(spec)
        self.assertEqual(self._analyzed(spec), [("data", 0x100, 0x200)])

    def test_no_analyzed_asm_is_noop(self):
        # If there's no analyzed.asm entry at all, nothing to do.
        spec = {"files": [
            {"type": "code", "name": "u.asm",
             "sections": [{"type": "data", "addr": 0x200, "len": 0x100, "label": "U"}]},
        ]}
        extract.reconcile_analyzed_sections(spec)
        self.assertEqual(spec["files"][0]["sections"][0]["addr"], 0x200)


class TestAsciiAscizValidation(unittest.TestCase):
    ROM_SIZE = 0x10000

    def test_ascii_section_accepted(self):
        extract.validate_map({"files": [
            {"type": "code", "name": "x.asm", "sections": [
                {"type": "ascii", "addr": 0x200, "len": 5}
            ]}
        ]}, self.ROM_SIZE)

    def test_asciz_section_accepted(self):
        extract.validate_map({"files": [
            {"type": "code", "name": "x.asm", "sections": [
                {"type": "asciz", "addr": 0x200, "len": 6}
            ]}
        ]}, self.ROM_SIZE)

    def test_unknown_section_type(self):
        with self.assertRaises(extract.MapError):
            extract.validate_map({"files": [
                {"type": "code", "name": "x.asm", "sections": [
                    {"type": "utf8", "addr": 0x200, "len": 4}
                ]}
            ]}, self.ROM_SIZE)


class TestAsciiSectionIndex(unittest.TestCase):
    def test_ascii_is_string_section_owner(self):
        spec = {"files": [{"type": "code", "name": "x.asm", "sections": [
            {"type": "ascii", "addr": 0x200, "len": 4}
        ]}]}
        index = extract.build_section_index(spec)
        by_start = {s[0]: s for s in index}
        # (start, end, kind, owner) — kind collapses to "data", owner is "string-section"
        self.assertEqual(by_start[0x200][2], "data")
        self.assertEqual(by_start[0x200][3], "string-section")

    def test_label_not_assigned_mid_string(self):
        # A string at $0200 len 5. A reference to $0202 (mid-string)
        # must NOT define a label there — the emitter renders the
        # whole span as one db "..." literal.
        rom = bytearray(0x10000)
        rom[0x200:0x205] = b"Hello"
        rom[0x300:0x303] = bytes.fromhex("c30202")  # jp $0202
        spec = {"files": [{"type": "code", "name": "x.asm", "sections": [
            {"type": "ascii", "addr": 0x200, "len": 5},
            {"type": "code",  "addr": 0x300, "len": 3},
        ]}]}
        sec_index = extract.build_section_index(spec)
        boundaries = extract.compute_insn_boundaries(bytes(rom), spec)
        refs = extract.collect_refs(bytes(rom), spec)
        labels = extract.build_labels(refs, sec_index, boundaries, spec)
        self.assertIn(0x200, labels)
        self.assertNotIn(0x202, labels)

    def test_custom_label_at_string_start(self):
        spec = {"files": [{"type": "code", "name": "x.asm", "sections": [
            {"type": "asciz", "addr": 0x200, "len": 6, "label": "Greeting"}
        ]}]}
        sec_index = extract.build_section_index(spec)
        boundaries = extract.compute_insn_boundaries(bytes(0x10000), spec)
        labels = extract.build_labels([], sec_index, boundaries, spec)
        self.assertEqual(labels[0x200], "Greeting")


# ----------------------------------------------------------------------
# Append-only emission for user-edited files
# ----------------------------------------------------------------------

class TestAppendOnlyEmission(unittest.TestCase):
    """Verify emit_code_file's behavior on already-existing files:
      - User hand-edits to the file survive re-extract.
      - Existing SECTION blocks are NOT re-emitted (user owns them).
      - New sections from map.json get appended at the end.
      - Auto-managed files (header.asm, main.asm, analyzed.asm) always
        full-regen.
    """

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.dir = Path(self.tmp.name)
        self.rom = bytes(0x10000)
        # Put something at $0200 so SECTION emission is deterministic.
        rom = bytearray(self.rom)
        rom[0x0200:0x0203] = bytes.fromhex("c9c9c9")  # 3 x ret
        rom[0x0300:0x0303] = bytes.fromhex("c9c9c9")
        self.rom = bytes(rom)

    def tearDown(self):
        self.tmp.cleanup()

    def _spec_with_sections(self, *addrs_and_lens):
        sections = [{"type": "code", "addr": a, "len": l} for a, l in addrs_and_lens]
        return {
            "files": [{"type": "code", "name": "engine.asm", "sections": sections}]
        }

    def _emit(self, spec):
        sec_index = extract.build_section_index(spec)
        boundaries = extract.compute_insn_boundaries(self.rom, spec)
        refs = extract.collect_refs(self.rom, spec)
        labels = extract.build_labels(refs, sec_index, boundaries, spec)
        f = spec["files"][0]
        return extract.emit_code_file(f, self.rom, self.dir, labels, {})

    def test_first_extract_emits_fresh(self):
        spec = self._spec_with_sections((0x0200, 3))
        out = self._emit(spec)
        text = out.read_text()
        self.assertIn('SECTION "engine_000200"', text)
        self.assertIn("Auto-generated", text)  # banner present

    def test_existing_file_user_edits_survive(self):
        spec = self._spec_with_sections((0x0200, 3))
        out = self._emit(spec)
        # Simulate the user adding a comment after the SECTION block.
        user_text = out.read_text() + "\n; --- user comment ---\nMyMacro: MACRO\n\tnop\nENDM\n"
        out.write_text(user_text)
        # Re-extract with the same map.json — file already has engine_000200.
        self._emit(spec)
        # User comment survives; we don't re-emit the existing section.
        final = out.read_text()
        self.assertIn("--- user comment ---", final)
        self.assertIn("MyMacro: MACRO", final)
        # Only one banner (no duplicate emission).
        self.assertEqual(final.count("Auto-generated by tools/extract.py"), 1)
        # Only one SECTION directive for $0200.
        self.assertEqual(final.count('SECTION "engine_000200"'), 1)

    def test_new_section_in_different_bank_gets_appended(self):
        # Cross-bank new section: bank-0 SECTION at $0200's extent caps
        # at the bank boundary ($4000), so a new map.json section at
        # $4000+ (bank 1) is not covered and gets appended.
        spec1 = self._spec_with_sections((0x0200, 3))
        out = self._emit(spec1)
        out.write_text(out.read_text() + "\n; user content\n")
        spec2 = {"files": [{"type": "code", "name": "engine.asm", "sections": [
            {"type": "code", "addr": 0x0200, "len": 3},
            {"type": "code", "addr": 0x4000, "len": 3},  # bank 1
        ]}]}
        self._emit(spec2)
        final = out.read_text()
        self.assertIn('SECTION "engine_000200"', final)
        self.assertIn('SECTION "engine_004000"', final)
        # User content survives.
        self.assertIn("; user content", final)
        # Bank-1 section was appended after user content (which sat at
        # the end of the previous file).
        self.assertLess(final.index("; user content"),
                        final.index('SECTION "engine_004000"'))

    def test_no_sections_in_file_treated_as_uncovered(self):
        # User wipes all SECTION directives from the file (e.g. preparing
        # to start over). On re-extract, the map.json sections come back.
        spec = self._spec_with_sections((0x0200, 3))
        out = self._emit(spec)
        out.write_text("; user blanked the file but kept it on disk\n")
        self._emit(spec)
        text = out.read_text()
        self.assertIn('SECTION "engine_000200"', text)

    def test_merged_section_no_duplicates(self):
        # The user merges two map.json sections under ONE big SECTION
        # directive (deleted the second directive, kept the bytes inside
        # the first). Re-extract must NOT re-append the "missing" one —
        # the address range is already covered.
        spec = self._spec_with_sections((0x0200, 3), (0x0204, 3))
        out = self._emit(spec)
        # Hand-craft a merged version: one SECTION covering both ranges.
        out.write_text(
            'SECTION "MyMerged", ROM0[$0200]\n'
            'MyLabel_0200:\n\tret\n\tret\n\tret\n'
            '\tret\n\tret\n\tret\n'
        )
        self._emit(spec)
        text = out.read_text()
        # Only the user's "MyMerged" SECTION; nothing appended.
        self.assertEqual(text.count("SECTION "), 1)
        self.assertNotIn('SECTION "engine_000200"', text)
        self.assertNotIn('SECTION "engine_000204"', text)

    def test_rename_section_directive_no_duplicate(self):
        # User renames `engine_000200` to something semantic. The address
        # ($0200) is still claimed by a SECTION in the file, so re-extract
        # leaves it alone.
        spec = self._spec_with_sections((0x0200, 3))
        out = self._emit(spec)
        renamed = out.read_text().replace(
            'SECTION "engine_000200"', 'SECTION "InitVector"')
        out.write_text(renamed)
        self._emit(spec)
        text = out.read_text()
        self.assertIn('SECTION "InitVector"', text)
        self.assertNotIn('SECTION "engine_000200"', text)

    def test_new_section_in_bank_appended_when_partial_coverage(self):
        # File has a SECTION at $0200 covering 3 bytes. map.json says
        # $0200 and also $3000 (uncovered). $3000 falls inside the
        # remaining-bank-0 extent of the SECTION ($0200..$4000), so the
        # heuristic says "already covered" — which is the known
        # misconfig case. Document the behavior with a test so we notice
        # if it changes.
        spec = self._spec_with_sections((0x0200, 3), (0x3000, 3))
        out = self._emit(spec)
        # Wipe to leave just one SECTION at $0200.
        out.write_text('SECTION "OnlyOne", ROM0[$0200]\n\tret\n')
        self._emit(spec)
        text = out.read_text()
        # Heuristic says $3000 is "covered" by [OnlyOne, bank_end). No
        # append. (The linker would catch this misconfig at build time.)
        self.assertEqual(text.count("SECTION "), 1)

    def test_auto_managed_full_regen(self):
        # analyzed.asm always full-regens regardless of existing content.
        spec = {
            "files": [{"type": "code", "name": "analyzed.asm", "sections": [
                {"type": "code", "addr": 0x0200, "len": 3}
            ]}]
        }
        out = self._emit(spec)
        # Simulate stale user content in analyzed.asm.
        out.write_text("STALE_CONTENT_SHOULD_BE_OVERWRITTEN\n")
        self._emit(spec)
        final = out.read_text()
        self.assertNotIn("STALE_CONTENT", final)
        self.assertIn('SECTION "analyzed_000200"', final)


if __name__ == "__main__":
    unittest.main()
