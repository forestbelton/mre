#!/usr/bin/env python3
"""Carve sections out of src/analyzed.asm into another file (byte-exact).

    tools/carvebank.py --bank 0f --out src/monster_detail.asm --desc "..."
    tools/carvebank.py --sections analyzed_07c416 --out src/scripts/mistral.asm --append

Select sections either by --bank (all sections of that ROMX bank, which are one
contiguous block) or by --sections (a comma-separated list of section names).
The chosen sections are removed from analyzed.asm and written to --out (created
with a header, or appended with --append). An `INCLUDE "<out>"` is added to
src/main.asm after analyzed.asm unless that file is already included.

Section names and addresses are unchanged and everything stays one compilation
unit, so cross-bank label refs still resolve. Run `make verify` afterwards.
"""
import re, sys, argparse

ANALYZED = 'src/analyzed.asm'
MAIN = 'src/main.asm'
SECRE = re.compile(r'^SECTION "([^"]+)"(?:.*BANK\[\$([0-9a-f]+)\])?')


def sections(lines):
    """Yield (start, end, name, bank) for every SECTION block."""
    spans = []
    for i, ln in enumerate(lines):
        m = SECRE.match(ln)
        if m:
            spans.append([i, None, m.group(1), int(m.group(2), 16) if m.group(2) else 0])
    for k, s in enumerate(spans):
        s[1] = spans[k + 1][0] if k + 1 < len(spans) else len(lines)
    return spans


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument('--bank')
    ap.add_argument('--sections')
    ap.add_argument('--out', required=True)
    ap.add_argument('--desc', default='')
    ap.add_argument('--append', action='store_true')
    ap.add_argument('--at-top', action='store_true',
                    help='with --append, insert after the target file header (before its '
                         'first SECTION) instead of at EOF -- e.g. NPC scene functions '
                         'placed above their script, matching text/scripts/nada.asm')
    args = ap.parse_args()

    lines = open(ANALYZED).readlines()
    spans = sections(lines)

    if args.bank is not None:
        bank = int(args.bank.lstrip('$'), 16)
        pick = [s for s in spans if s[3] == bank]
    elif args.sections:
        want = set(args.sections.split(','))
        pick = [s for s in spans if s[2] in want]
        missing = want - {s[2] for s in pick}
        if missing:
            print(f"sections not found: {sorted(missing)}"); return 1
    else:
        print("give --bank or --sections"); return 2
    if not pick:
        print("nothing selected"); return 1

    # collect carved text (in file order) and the set of removed line indices
    remove = set()
    block = []
    for s in sorted(pick, key=lambda s: s[0]):
        block += lines[s[0]:s[1]]
        remove.update(range(s[0], s[1]))
    block = ''.join(block).rstrip('\n') + '\n'

    import os
    if args.append and os.path.exists(args.out):
        if args.at_top:
            tgt = open(args.out).read().split('\n')
            i = 0  # skip the leading comment/blank header block
            while i < len(tgt) and (tgt[i].strip() == '' or tgt[i].lstrip().startswith(';')):
                i += 1
            tgt[i:i] = block.rstrip('\n').split('\n') + ['']
            open(args.out, 'w').write('\n'.join(tgt))
        else:
            with open(args.out, 'a') as f:
                f.write('\n' + block)
    else:
        hdr = f"; {args.desc}\n; Carved out of analyzed.asm (byte-exact: section names + placement unchanged).\n\n" if args.desc \
              else "; Carved out of analyzed.asm (byte-exact).\n\n"
        open(args.out, 'w').write(hdr + block)

    open(ANALYZED, 'w').write(''.join(l for i, l in enumerate(lines) if i not in remove))

    # In the multi-object build every src/**.asm is compiled on its own (no central
    # INCLUDE list); main.asm is gone, so there is nothing to register here.
    inc = args.out[len('src/'):] if args.out.startswith('src/') else args.out
    if os.path.exists(MAIN):
        mlines = open(MAIN).readlines()
        if not any(f'INCLUDE "{inc}"' in l for l in mlines):
            for i, ln in enumerate(mlines):
                if ln.strip() == 'INCLUDE "analyzed.asm"':
                    mlines.insert(i + 1, f'INCLUDE "{inc}"\n'); break
            open(MAIN, 'w').write(''.join(mlines))
            added = f'; INCLUDE "{inc}" added'
        else:
            added = '; already included'
    else:
        added = '; multi-object build: auto-compiled, no INCLUDE needed'

    print(f"carved {len(pick)} section(s), {len(remove)} lines -> {args.out} {added}")
    return 0


if __name__ == '__main__':
    sys.exit(main())
