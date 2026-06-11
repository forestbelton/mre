#!/usr/bin/env python3
"""Scan the ROM for pointer tables still living as raw `db` data, so they can be
rewritten symbolically (farptr / dw Label) and the hidden call graph surfaces -- the
Func_18_5dfa case generalized.

Heuristic: slide over each section's bytes looking for RUNS of consecutive pointer
records whose targets land in valid ROM address ranges. Three record shapes:
  far  {bank, lo, hi}   -> farptr   (3 bytes, bank first; the IntroSceneTable shape)
  far  {lo, hi, bank}   -> farptr   (3 bytes, bank last)
  near {lo, hi}         -> dw Label (2 bytes, target in the table's own bank)
A run is scored by length and by how many targets resolve onto a known label (from the
.sym) within the same routine. Each run is mapped to its source section/file and
classified raw-`db` (actionable) vs already-symbolic (skip). Writes a ranked worklist to
docs/pointer_tables_todo.md.

Run manually: `python3 tools/find_pointer_tables.py`  (reads build/rom.gbc{,.map,.sym}).
It's a heuristic triage list, not ground truth -- eyeball before converting.
"""
from __future__ import annotations

import bisect
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ROM = ROOT / "build" / "rom.gbc"
MAP = ROOT / "build" / "rom.gbc.map"
SYM = ROOT / "build" / "rom.gbc.sym"
SRC = ROOT / "src"
OUT = ROOT / "docs" / "pointer_tables_todo.md"

FAR_MIN = 3      # min records for a far-pointer run
NEAR_MIN = 8     # min records for a near-pointer (dw) run
OFF_CAP = 0x600  # target counts as "resolved" if within this many bytes of a label

BANK_RE = re.compile(r"^(ROM0|ROMX) bank #(\d+):")
SEC_RE = re.compile(r"^\tSECTION: \$([0-9A-Fa-f]+)-\$([0-9A-Fa-f]+) \(\$[0-9A-Fa-f]+ bytes\) \[\"(.*)\"\]")
SRC_SEC_RE = re.compile(r'^\s*SECTION\s+"([^"]+)"')
SYM_RE = re.compile(r"^([0-9A-Fa-f]{2,3}):([0-9A-Fa-f]{4})\s+(\S+)")


def file_off(bank: int, addr: int) -> int:
    return addr if bank == 0 else bank * 0x4000 + (addr - 0x4000)


def addr_ok(bank: int, addr: int) -> bool:
    return (0 <= addr < 0x4000) if bank == 0 else (0x4000 <= addr < 0x8000)


def load_syms():
    by_bank: dict[int, list] = {}
    for ln in SYM.read_text().splitlines():
        m = SYM_RE.match(ln.strip())
        if m:
            by_bank.setdefault(int(m.group(1), 16), []).append((int(m.group(2), 16), m.group(3)))
    for b in by_bank:
        by_bank[b].sort()
    return by_bank


def section_to_file():
    out = {}
    for f in sorted(SRC.rglob("*.asm")):
        rel = str(f.relative_to(ROOT))
        for ln in f.read_text(errors="replace").splitlines():
            m = SRC_SEC_RE.match(ln)
            if m:
                out.setdefault(m.group(1), rel)
    return out


def parse_sections():
    secs = []
    region = bank = None
    for ln in MAP.read_text().splitlines():
        mb = BANK_RE.match(ln)
        if mb:
            region, bank = mb.group(1), int(mb.group(2))
            continue
        ms = SEC_RE.match(ln)
        if ms and bank is not None:
            secs.append((bank, int(ms.group(1), 16), int(ms.group(2), 16), ms.group(3)))
    return secs


def main() -> int:
    for p in (ROM, MAP, SYM):
        if not p.exists():
            sys.exit(f"missing {p} -- build the ROM first")
    rom = ROM.read_bytes()
    syms = load_syms()
    s2f = section_to_file()
    sections = parse_sections()
    nbanks = max(b for b, *_ in sections) + 1

    addr_index = {b: [a for a, _ in arr] for b, arr in syms.items()}
    exact_set = {(b, a) for b, arr in syms.items() for a, _ in arr}

    def resolve(bank, addr):
        """-> (label[, '+N']) string if addr sits at/just-after a label in `bank`."""
        arr = syms.get(bank, [])
        i = bisect.bisect_right(addr_index.get(bank, []), addr) - 1
        if i < 0:
            return None
        a, name = arr[i]
        off = addr - a
        if off == 0:
            return name
        return f"{name}+{off}" if off <= OFF_CAP else None

    def is_exact(bank, addr):
        return (bank, addr) in exact_set

    def section_symbolic(secname):
        f = s2f.get(secname)
        if not f:
            return False
        txt = (ROOT / f).read_text(errors="replace")
        # crude: does the section's source use farptr / dw <label> already?
        m = re.search(r'^\s*SECTION\s+"' + re.escape(secname) + r'"', txt, re.M)
        if not m:
            return False
        rest = txt[m.start():]
        nxt = re.search(r'\n\s*SECTION\s+"', rest[1:])
        body = rest[: nxt.start()] if nxt else rest
        return bool(re.search(r'\bfarptr\b|\bdw\s+[A-Za-z_]', body))

    runs = []   # (score, bank, start_addr, fmt, n, targets, secname, file, actionable)

    def record_run(bank, start_addr, fmt, recs, secname):
        n = len(recs)
        anchored = sum(1 for b, a in recs if is_exact(b, a))
        targets = [(f"${b:02x}:${a:04x}", resolve(b, a)) for b, a in recs]
        sym = section_symbolic(secname)
        score = anchored * 3 + n + (0 if sym else 5)
        runs.append({
            "bank": bank, "addr": start_addr, "fmt": fmt, "n": n,
            "targets": targets, "sec": secname, "file": s2f.get(secname, "?"),
            "anchored": anchored, "actionable": not sym, "score": score,
        })

    covered = set()   # (bank, byte_offset_in_section) consumed by a far run

    for bank, S, E, name in sections:
        base = file_off(bank, S)
        buf = rom[base: base + (E - S + 1)]

        # --- far runs: both byte orders, stride 3. Extend while range-valid; keep only
        # runs whose targets are MOSTLY exact labels (routine entries) -- a dispatch
        # table points at entry points, random data does not. ---
        for order in ("bank_first", "bank_last"):
            i = 0
            while i + 3 <= len(buf):
                recs = []
                j = i
                while j + 3 <= len(buf):
                    if order == "bank_first":
                        b, lo, hi = buf[j], buf[j + 1], buf[j + 2]
                    else:
                        lo, hi, b = buf[j], buf[j + 1], buf[j + 2]
                    addr = lo | (hi << 8)
                    if not (0 < b < nbanks and addr_ok(b, addr)):  # b>0: skip all-zero noise
                        break
                    recs.append((b, addr))
                    j += 3
                anchored = sum(1 for b, a in recs if is_exact(b, a))
                distinct = len(set(recs))
                # a real table has DISTINCT entries; uniform/zero padding resolves to one
                # low label repeated (e.g. $0000 -> AddAToHL) -- reject it.
                if (len(recs) >= FAR_MIN and anchored >= 3 and anchored >= 0.66 * len(recs)
                        and distinct >= 3 and distinct >= 0.5 * len(recs)):
                    record_run(bank, S + i, f"far/{order}", recs, name)
                    covered.update((bank, k) for k in range(i, j))
                    i = j
                else:
                    i += 1

        # --- near runs: stride 2, target in this section's bank, EXACT labels only
        # (break on the first non-entry) -- strictest, since the bank is implicit. ---
        i = 0
        while i + 2 <= len(buf):
            if (bank, i) in covered:
                i += 1
                continue
            recs = []
            j = i
            while j + 2 <= len(buf) and (bank, j) not in covered:
                addr = buf[j] | (buf[j + 1] << 8)
                if not (addr_ok(bank, addr) and is_exact(bank, addr)):
                    break
                recs.append((bank, addr))
                j += 2
            if len(recs) >= NEAR_MIN and len(set(recs)) >= max(4, 0.5 * len(recs)):
                record_run(bank, S + i, "near/dw", recs, name)
                i = j
            else:
                i += 1

    runs.sort(key=lambda r: (r["actionable"], r["score"]), reverse=True)
    actionable = [r for r in runs if r["actionable"]]

    out = ["# Pointer-table worklist\n",
           "_Auto-generated by `tools/find_pointer_tables.py` (heuristic; eyeball before "
           "converting). Run it again to refresh after symbolizing tables._\n",
           f"Found **{len(runs)}** candidate pointer-table runs "
           f"(**{len(actionable)}** still raw `db`, actionable). Far runs -> `farptr`; "
           "near `dw` runs -> `dw Label`. Targets shown as `bank:addr` -> resolved "
           "`label[+offset]` (blank = no nearby label).\n",
           "## Actionable (raw `db`)\n"]
    for r in actionable:
        out.append(f"### ${r['bank']:02x}:${r['addr']:04x} — {r['n']}x {r['fmt']} "
                   f"({r['anchored']}/{r['n']} entries) — `{r['sec']}` ({Path(r['file']).name})")
        for loc, lab in r["targets"]:
            out.append(f"- {loc}  {('-> ' + lab) if lab else ''}")
        out.append("")
    skipped = [r for r in runs if not r["actionable"]]
    out.append(f"## Already symbolic ({len(skipped)}) — section uses farptr/dw\n")
    for r in skipped:
        out.append(f"- ${r['bank']:02x}:${r['addr']:04x} {r['n']}x {r['fmt']} "
                   f"`{r['sec']}` ({Path(r['file']).name})")

    OUT.write_text("\n".join(out) + "\n")
    print(f"pointer-tables: {len(runs)} runs ({len(actionable)} actionable) -> "
          f"{OUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
