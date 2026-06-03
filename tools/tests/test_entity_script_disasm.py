"""Unit test for tools/entity_script_disasm.py.

The single most important invariant: the entity-script VM opcode spec must
decode the bytecode in $71eb-$7d25 into instructions that tile the region
*exactly* -- no gaps, no overlaps, no control flow leaving the region. That
perfect tiling is the round-trip proof the spec is correct; if any opcode length
is wrong the tiling breaks. Run with `make test`.
"""
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(ROOT / "tools"))
import entity_script_disasm as esd  # noqa: E402


class TestEntityScriptDisasm(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.rom = esd.load_rom(str(ROOT / "rom.gbc"))
        cls.room = str(ROOT / "src" / "room.asm")
        (cls.insns, cls.targets, cls.code_refs,
         cls.data_refs, cls.errors) = esd.disassemble(cls.rom, cls.room)

    def test_no_decode_errors(self):
        self.assertEqual(self.errors, [])

    def test_tiles_runs_exactly(self):
        covered = {a + i for a in self.insns for i in range(self.insns[a][1])}
        expected = {x for lo, hi in esd.SCRIPT_RUNS for x in range(lo, hi)}
        total = sum(self.insns[a][1] for a in self.insns)
        # decoded bytes exactly cover the script runs, no overlaps
        self.assertEqual(covered, expected)
        self.assertEqual(total, len(covered))

    def test_data_refs_outside_runs(self):
        expected = {x for lo, hi in esd.SCRIPT_RUNS for x in range(lo, hi)}
        inside = [x for x in self.data_refs if x in expected]
        self.assertEqual(inside, [])


if __name__ == "__main__":
    unittest.main()
