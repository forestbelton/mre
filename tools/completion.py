#!/usr/bin/env python3
"""Rough "how far along is the disassembly" metrics.

Reports four proxy dimensions of turning the ROM into a real source project
(see docs/philosophy.md), with the underlying counts so the numbers can be
judged, not just trusted:

  1. Semantic labeling   -- named labels vs the analyzer's auto Func_/Data_ names
  2. Symbolic references -- named RAM/IO/labels vs raw $hhhh address literals
  3. Graphics pipeline   -- tile bytes migrated to PNG assets vs raw .2bpp blobs
  4. Section offsets      -- ROM sections placed by layout.link vs pinned [$addr]
                            (the litmus test: a floated section could relocate)

All are coarse proxies (by count / byte, not by effort). Run `make completion`
(builds assets first so dimension 3 has data) or `python3 tools/completion.py`.
"""

from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "src"


def _asms() -> list[Path]:
    return sorted(SRC.rglob("*.asm"))


def labels() -> tuple[int, int, int]:
    """(semantic, auto, inline_auto_refs)."""
    auto_def = re.compile(r"^(Func|Data|jr_|Jump|Call)_[0-9a-fA-F]{2}_[0-9a-fA-F]{4}\b")
    glob_def = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*::?")
    auto_ref = re.compile(r"\b(Func|Data)_[0-9a-fA-F]{2}_[0-9a-fA-F]{4}\b")
    sem = auto = refs = 0
    for f in _asms():
        for line in f.read_text().splitlines():
            if glob_def.match(line):
                if auto_def.match(line):
                    auto += 1
                else:
                    sem += 1
            refs += len(auto_ref.findall(line))
    return sem, auto, refs


def references() -> tuple[int, int, int, int]:
    """(sym_mem, raw_mem, sym_addr_loads, raw_addr_loads).

    Memory accesses: [wX]/[hX]/[rX]/[sX] vs [$hhhh]. Register address loads:
    `ld hl/de/bc, Label` vs `ld hl/de/bc, $hhhh` where the immediate is in an
    address range ($4000+); small immediates are lengths/counts, not addresses.
    """
    raw_mem = re.compile(r"\[\$[0-9a-fA-F]{2,4}\]")
    sym_mem = re.compile(r"\[[whrs][A-Z][A-Za-z0-9_]*\]")
    ld_imm = re.compile(r"\bld (?:hl|de|bc), \$([0-9a-fA-F]{4})\b")
    ld_lbl = re.compile(r"\bld (?:hl|de|bc), [A-Za-z_][A-Za-z0-9_]*\b")
    sm = rm = sa = ra = 0
    for f in _asms():
        txt = f.read_text()
        sm += len(sym_mem.findall(txt))
        rm += len(raw_mem.findall(txt))
        sa += len(ld_lbl.findall(txt))
        ra += sum(1 for v in ld_imm.findall(txt) if int(v, 16) >= 0x4000)
    return sm, rm, sa, ra


def graphics() -> tuple[int, int, int]:
    """(raw_sheet_count, raw_bytes, migrated_bytes). migrated_bytes is 0 when
    build/assets is absent (run a build first)."""
    raw = list((SRC / "gfx" / "raw").glob("*.2bpp"))
    raw_bytes = sum(p.stat().st_size for p in raw)
    migrated = 0
    ba = ROOT / "build" / "assets"
    if ba.exists():
        migrated = sum(
            p.stat().st_size
            for p in ba.rglob("*")
            if p.is_file() and p.suffix in (".bin", ".2bpp")
        )
    return len(raw), raw_bytes, migrated


def sections() -> tuple[int, int, int]:
    """(rom_floating, rom_pinned, ram_sections). ROM sections placed by
    layout.link (no [$addr]) vs pinned to a source offset."""
    sec = re.compile(
        r'^\s*SECTION\s+"[^"]+",\s*(ROM0|ROMX|WRAM0|WRAMX|HRAM|VRAM|SRAM)(\[)?'
    )
    floating = pinned = ram = 0
    for f in _asms():
        for line in f.read_text().splitlines():
            m = sec.match(line)
            if not m:
                continue
            typ, offset = m.group(1), m.group(2)
            if typ in ("ROM0", "ROMX"):
                pinned += 1 if offset else 0
                floating += 0 if offset else 1
            else:
                ram += 1
    return floating, pinned, ram


def pct(part: int, whole: int) -> float:
    return 100 * part / whole if whole else 0.0


def main() -> int:
    sem, auto, refs = labels()
    sm, rm, sa, ra = references()
    nraw, rawb, migb = graphics()
    sfloat, spin, sram = sections()

    label_pct = pct(sem, sem + auto)
    mem_pct = pct(sm, sm + rm)
    addr_pct = pct(sa, sa + ra)
    ref_pct = pct(sm + sa, sm + sa + rm + ra)
    gfx_pct = pct(migb, migb + rawb) if migb else float("nan")
    sec_pct = pct(sfloat, sfloat + spin)

    print("== 1. Semantic labeling ==")
    print(f"   semantic {sem} / {sem + auto} labels  ->  {label_pct:.1f}%")
    print(f"   (auto Func_/Data_ labels: {auto}; inline refs to them: {refs})")
    print("== 2. Symbolic references ==")
    print(f"   memory [sym] {sm} / {sm + rm}  ->  {mem_pct:.1f}%")
    print(f"   address loads (label) {sa} / {sa + ra}  ->  {addr_pct:.1f}%")
    print(f"   combined  ->  {ref_pct:.1f}%")
    print("== 3. Graphics pipeline ==")
    if migb:
        print(f"   migrated {migb} B / {migb + rawb} B tile bytes  ->  {gfx_pct:.1f}%")
    else:
        print("   migrated bytes unknown (build/assets absent -- run `make` first)")
    print(f"   raw .2bpp sheets remaining: {nraw} ({rawb} B)")
    print("== 4. Section offsets (litmus: could we drop the offset?) ==")
    print(f"   floating (layout.link) {sfloat} / {sfloat + spin} ROM sections"
          f"  ->  {sec_pct:.1f}%")
    print(f"   (still pinned [$addr]: {spin}; RAM/HRAM/VRAM sections: {sram})")

    dims = [label_pct, ref_pct, sec_pct] + ([gfx_pct] if migb else [])
    print("\n== blended (equal weight, coarse) ==")
    print(f"   {sum(dims) / len(dims):.0f}%  across "
          f"{len(dims)} dimensions{' (graphics excluded: no build)' if not migb else ''}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
