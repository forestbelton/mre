#!/usr/bin/env python3
"""Carve one ROM bank's contiguous section run out of src/analyzed.asm.

    tools/carvebank.py <bank-hex> <out-path> ["one-line description"]

analyzed.asm holds the banks in ascending order, each as one contiguous block
(verify with scratch/bank_profile.py). This moves a bank's block verbatim into a
new file, drops it from analyzed.asm, and adds an INCLUDE to src/main.asm right
after analyzed.asm. Section names are unchanged and everything stays one
compilation unit, so cross-bank label refs still resolve -- byte-exact. Run
`make verify` afterwards to confirm.
"""
import re, sys

ANALYZED = 'src/analyzed.asm'
MAIN = 'src/main.asm'


def main() -> int:
    if len(sys.argv) < 3:
        print(__doc__); return 2
    bank = int(sys.argv[1].lstrip('$'), 16)
    out = sys.argv[2]
    desc = sys.argv[3] if len(sys.argv) > 3 else f"bank ${bank:02x}"

    lines = open(ANALYZED).readlines()
    secre = re.compile(r'^SECTION .*BANK\[\$([0-9a-f]+)\]')

    # find the contiguous [start, end) line span whose sections are this bank
    start = end = None
    for i, ln in enumerate(lines):
        m = secre.match(ln)
        if m and int(m.group(1), 16) == bank:
            if start is None:
                start = i
            end = i  # last seen section header for this bank
    if start is None:
        print(f"no sections for bank ${bank:02x}"); return 1
    # extend end to just before the next bank's section (or EOF)
    j = end + 1
    while j < len(lines) and not secre.match(lines[j]):
        j += 1
    end = j
    # sanity: no other bank appears inside [start, end)
    for k in range(start, end):
        m = secre.match(lines[k])
        if m and int(m.group(1), 16) != bank:
            print(f"bank ${bank:02x} is not contiguous (found ${int(m.group(1),16):02x} at line {k+1})")
            return 1

    block = lines[start:end]
    while block and block[-1].strip() == '':
        block.pop()
    nsec = sum(1 for l in block if l.startswith('SECTION'))

    header = (f"; ROM bank ${bank:02x} -- {desc}. Carved out of analyzed.asm; section\n"
              f"; names and placement are unchanged (byte-exact). {nsec} sections.\n\n")
    open(out, 'w').write(header + ''.join(block))

    rest = lines[:start] + lines[end:]
    open(ANALYZED, 'w').write(''.join(rest))

    # add the include after analyzed.asm in main.asm
    inc = out[len('src/'):] if out.startswith('src/') else out
    mlines = open(MAIN).readlines()
    for i, ln in enumerate(mlines):
        if ln.strip() == 'INCLUDE "analyzed.asm"':
            mlines.insert(i + 1, f'INCLUDE "{inc}"\n')
            break
    open(MAIN, 'w').write(''.join(mlines))

    print(f"carved bank ${bank:02x}: {len(block)} lines, {nsec} sections -> {out}")
    print(f"  INCLUDE \"{inc}\" added to {MAIN}; run `make verify`")
    return 0


if __name__ == '__main__':
    sys.exit(main())
