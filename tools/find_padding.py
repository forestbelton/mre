#!/usr/bin/env python3
"""Find contiguous $00 padding runs in the ROM and add them to map.json.

Scans the ROM for runs of $00 bytes that aren't already claimed by any
file entry in map.json. Anything at or above --min-length is reported;
with --apply, the runs are added as `padding` sections under a single
file entry (default name `padding.asm`) so the coverage stats can show
them as covered instead of "uncovered".

Padding sections emit no RGBASM directives — rgblink's `-p 0` fills the
unassigned bytes during the link. extract.py's validate_padding_sections
double-checks the underlying bytes are all $00 before each build.

Usage:
    python3 tools/find_padding.py --rom rom.gbc --map map.json
    python3 tools/find_padding.py --rom rom.gbc --map map.json --apply
"""
import argparse
import json
import sys
from pathlib import Path


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--rom", default="rom.gbc")
    ap.add_argument("--map", dest="map_file", default="map.json")
    ap.add_argument("--min-length", type=int, default=256,
                    help="minimum run length to report (default 256)")
    ap.add_argument("--file-name", default="padding.asm",
                    help="map.json file name to add padding sections under")
    ap.add_argument("--apply", action="store_true",
                    help="patch map.json in place (default: print only)")
    args = ap.parse_args(argv)

    rom = Path(args.rom).read_bytes()
    spec = json.loads(Path(args.map_file).read_text())

    # Build a "covered" bitmap from existing map.json entries (any type).
    covered = bytearray(len(rom))
    def claim(start, length):
        end = min(start + length, len(rom))
        for i in range(max(start, 0), end):
            covered[i] = 1

    for f in spec.get("files", []):
        if not isinstance(f, dict): continue
        if f.get("type") == "code":
            for s in f.get("sections", []) or []:
                if isinstance(s, dict) and "addr" in s and "len" in s:
                    claim(int(s["addr"]), int(s["len"]))
        elif f.get("type") == "data":
            if "addr" in f and "len" in f:
                claim(int(f["addr"]), int(f["len"]))
    # Reserve the cartridge header so we don't try to "pad" through it.
    claim(0x100, 0x150 - 0x100)

    # Find runs of $00 bytes that are uncovered. Split at bank boundaries
    # so each padding section sits in exactly one rgbasm SECTION-eligible
    # bank.
    BANK = 0x4000
    runs = []
    i = 0
    while i < len(rom):
        if not covered[i] and rom[i] == 0:
            start = i
            bank_end = ((i // BANK) + 1) * BANK
            while i < len(rom) and not covered[i] and rom[i] == 0 and i < bank_end:
                i += 1
            length = i - start
            if length >= args.min_length:
                runs.append((start, length))
        else:
            i += 1

    if not runs:
        print("no padding runs found above threshold", file=sys.stderr)
        return 0

    total = sum(l for _, l in runs)
    print(f"found {len(runs)} padding runs totalling {total} bytes "
          f"({100*total/len(rom):.1f}% of ROM)", file=sys.stderr)
    for start, length in runs:
        bank = start // BANK
        print(f"  ${start:06x}-${start+length-1:06x}  "
              f"({length:>6} bytes, bank {bank})", file=sys.stderr)

    if not args.apply:
        print("\n(re-run with --apply to patch map.json)", file=sys.stderr)
        return 0

    # Locate or create the padding file entry.
    target = next(
        (f for f in spec.get("files", []) if isinstance(f, dict) and f.get("name") == args.file_name),
        None,
    )
    new_sections = [
        {"type": "padding",
         "addr": s,
         "len": l,
         "label": f"Padding_{s:06x}"}
        for s, l in runs
    ]
    if target is None:
        target = {"type": "code", "name": args.file_name, "sections": new_sections}
        # Insert before analyzed.asm so the order is stable.
        files = spec.setdefault("files", [])
        idx = next(
            (i for i, f in enumerate(files) if isinstance(f, dict) and f.get("name") == "analyzed.asm"),
            len(files),
        )
        files.insert(idx, target)
    else:
        # Merge: only add sections that aren't already present at the same addr.
        existing_addrs = {int(s["addr"]) for s in target.get("sections", []) if isinstance(s, dict)}
        target.setdefault("sections", []).extend(
            s for s in new_sections if s["addr"] not in existing_addrs
        )

    Path(args.map_file).write_text(json.dumps(spec, indent="\t") + "\n")
    print(f"wrote {args.map_file}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
