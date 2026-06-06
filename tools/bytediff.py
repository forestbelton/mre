#!/usr/bin/env python3
"""Find the first byte where the built ROM diverges from the reference ROM.

    tools/bytediff.py [built] [reference]

Defaults: built=build/rom.gbc, reference=rom.gbc. Reports the flat offset, the
bank:addr it maps to, both byte values, and (from build/rom.gbc.map, if present)
the nearest preceding label in that bank -- so a mismatch points straight at the
routine/table that drifted. Exit status is 1 when the ROMs differ.

The rgbfix-computed header checksums ($014D header, $014E-$014F global) change
whenever *any* byte changes, so they only echo a real mismatch elsewhere. They're
ignored during the scan and only reported if the rest of the ROM matches (which
would mean the checksum itself is wrong -- e.g. a bad rgbfix invocation).
"""
import sys, re

# rgbfix-managed checksum bytes: header checksum + 16-bit global checksum.
HEADER_CKSUM = {0x014D, 0x014E, 0x014F}


def bank_addr(off: int) -> tuple[int, int]:
    """Flat ROM offset -> (bank, 16-bit address)."""
    bank = off // 0x4000
    return (0, off) if bank == 0 else (bank, 0x4000 + (off % 0x4000))


def load_symbols(mapfile: str) -> dict[int, list[tuple[int, str]]]:
    """bank -> sorted [(addr, label)], parsed from an rgblink map."""
    syms: dict[int, list] = {}
    bank = None
    try:
        lines = open(mapfile)
    except OSError:
        return syms
    for ln in lines:
        m = re.match(r'^(ROM0|ROMX) bank #([0-9a-fA-F]+):', ln)
        if m:
            bank = int(m.group(2), 16); continue
        s = re.match(r'\s*\$([0-9a-f]+) = (\S+)', ln)
        if s and bank is not None:
            syms.setdefault(bank, []).append((int(s.group(1), 16), s.group(2)))
    for b in syms:
        syms[b].sort()
    return syms


def nearest_label(syms, bank, addr):
    cands = syms.get(bank, [])
    best = None
    for a, lab in cands:
        if a <= addr:
            best = (a, lab)
        else:
            break
    return best


def main() -> int:
    built = sys.argv[1] if len(sys.argv) > 1 else 'build/rom.gbc'
    ref = sys.argv[2] if len(sys.argv) > 2 else 'rom.gbc'
    a, b = open(built, 'rb').read(), open(ref, 'rb').read()
    syms = load_symbols('build/rom.gbc.map')

    if a == b:
        print(f"identical ({len(a)} bytes)")
        return 0
    if len(a) != len(b):
        print(f"size differs: built {len(a)} vs reference {len(b)} bytes")

    all_diffs = [i for i in range(min(len(a), len(b))) if a[i] != b[i]]
    mismatches = [i for i in all_diffs if i not in HEADER_CKSUM]
    if not mismatches:
        # Only the header checksums differ -- the rest of the ROM matches.
        for i in sorted(set(all_diffs) & HEADER_CKSUM):
            kind = 'header checksum' if i == 0x014D else 'global checksum'
            print(f"only the {kind} differs at ${i:04x}: built=${a[i]:02x} ref=${b[i]:02x}")
        print("(re-run rgbfix; the ROM body is byte-identical)")
        return 1
    first = mismatches[0]
    bank, addr = bank_addr(first)
    near = nearest_label(syms, bank, addr)
    loc = ''
    if near:
        loc = f"  near {near[1]}+${addr - near[0]:x} (${near[0]:04x})"
    print(f"{len(mismatches)} mismatched bytes; first at offset ${first:06x}")
    print(f"  -> bank ${bank:02x} : ${addr:04x}   built=${a[first]:02x} ref=${b[first]:02x}{loc}")
    # a little context: the next couple of distinct mismatch regions
    shown = 0
    prev = first
    for i in mismatches[1:]:
        if i > prev + 1 and shown < 4:
            bk, ad = bank_addr(i)
            nb = nearest_label(syms, bk, ad)
            extra = f"  near {nb[1]}+${ad - nb[0]:x}" if nb else ''
            print(f"     +next region: bank ${bk:02x} : ${ad:04x}   built=${a[i]:02x} ref=${b[i]:02x}{extra}")
            shown += 1
        prev = i
    return 1


if __name__ == '__main__':
    sys.exit(main())
