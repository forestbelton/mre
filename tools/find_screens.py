#!/usr/bin/env python3
"""Statically locate CopyBgMap screen libraries in the ROM.

A "screen" is a BG-tilemap descriptor in the engine's CopyBgMap format:

    [rows][cols][attr_ptr:LE16][idx_ptr:LE16]   (6-byte descriptor)
    idx map  : rows*cols bytes of tile indices   (immediately after descriptor)
    attr map : rows*cols bytes of CGB attributes  (immediately after idx map)

so idx_ptr == descriptor_addr + 6 and attr_ptr == idx_ptr + rows*cols. The
descriptor + both maps describe the *layout* of a screen; the tile *pixels*
they index live elsewhere (VRAM-loaded, tagged separately by the analyzer).

Descriptors are stored back-to-back in "libraries" (the attr map of one screen
ends exactly where the next descriptor begins). A run of >=2 chained descriptors
is too arithmetically constrained to occur by chance; singletons are reported
separately as lower-confidence candidates.

Cross-validates against the known Kalum portrait at bank $1d:$5880.

Usage:
    tools/find_screens.py [--rom rom.gbc] [--min-run 2] [--json out.json]
    tools/find_screens.py --gap-dir src/data   # also report gap intersection
"""
import argparse, glob, json, os, re, sys
from collections import Counter

BANK_SIZE = 0x4000


def le16(rom, o):
    return rom[o] | (rom[o + 1] << 8)


def describe(rom, p):
    """Return (rows, cols, attr_ptr, idx_ptr, cells) if p is a valid descriptor, else None."""
    if p < BANK_SIZE or p + 6 > len(rom):
        return None  # bank0 has no $4000-window descriptors
    bank = p // BANK_SIZE
    desc_addr = 0x4000 + (p - bank * BANK_SIZE)
    rows, cols = rom[p], rom[p + 1]
    attr, idx = le16(rom, p + 2), le16(rom, p + 4)
    cells = rows * cols
    if not (1 <= rows <= 32 and 1 <= cols <= 32):
        return None
    if idx != desc_addr + 6 or attr != idx + cells:
        return None
    if attr + cells > 0x8000:  # maps must fit in the bank's $4000-$7fff window
        return None
    return rows, cols, attr, idx, cells


def find_runs(rom):
    """Yield maximal chains of consecutive descriptors as dicts."""
    runs = []
    p = BANK_SIZE
    n = len(rom)
    while p < n - 6:
        d = describe(rom, p)
        if d is None:
            p += 1
            continue
        start = p
        screens = []
        while True:
            d = describe(rom, p)
            if d is None:
                break
            rows, cols, attr, idx, cells = d
            bank = p // BANK_SIZE
            screens.append({
                "desc": 0x4000 + (p - bank * BANK_SIZE),
                "rows": rows, "cols": cols,
            })
            p = bank * BANK_SIZE + (attr - 0x4000) + cells  # next descriptor
        end = p
        bank = start // BANK_SIZE
        runs.append({
            "offset": start,
            "bank": bank,
            "addr": 0x4000 + (start - bank * BANK_SIZE),
            "count": len(screens),
            "bytes": end - start,
            "screens": screens,
        })
    return runs


def load_gap_set(rom_len, gap_dir):
    """Build the uncovered-byte set from extract.py's gap-fill blobs (data_<hex>.bin)."""
    uncov = bytearray(rom_len)
    total = 0
    for f in glob.glob(os.path.join(gap_dir, "data_*.bin")):
        m = re.search(r"data_([0-9a-fA-F]+)\.bin$", f)
        if not m:
            continue
        off = int(m.group(1), 16)
        sz = os.path.getsize(f)
        total += sz
        for i in range(off, min(off + sz, rom_len)):
            uncov[i] = 1
    return uncov, total


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--rom", default="rom.gbc")
    ap.add_argument("--min-run", type=int, default=2,
                    help="minimum chained screens to report as confident (default 2)")
    ap.add_argument("--gap-dir", default="src/data",
                    help="dir of extract.py gap blobs, for gap intersection")
    ap.add_argument("--json", help="write the full inventory here")
    args = ap.parse_args()

    rom = open(args.rom, "rb").read()
    runs = find_runs(rom)
    confident = [r for r in runs if r["count"] >= args.min_run]
    singletons = [r for r in runs if r["count"] < args.min_run]

    uncov = total_gap = None
    if args.gap_dir and os.path.isdir(args.gap_dir):
        uncov, total_gap = load_gap_set(len(rom), args.gap_dir)
        for r in runs:
            r["gap_bytes"] = sum(uncov[r["offset"]:r["offset"] + r["bytes"]])

    tot = sum(r["bytes"] for r in confident)
    print(f"{len(confident)} screen libraries (>= {args.min_run} chained), "
          f"{tot} bytes, {sum(r['count'] for r in confident)} screens")
    if uncov is not None:
        ingap = sum(r["gap_bytes"] for r in confident)
        print(f"  {ingap} bytes ({100 * ingap // max(1, total_gap)}% of {total_gap} "
              f"uncovered) land in unmapped gaps")
    print(f"  dim histogram: "
          f"{dict(Counter((s['rows'], s['cols']) for r in confident for s in r['screens']).most_common(8))}")
    print()
    for r in sorted(confident, key=lambda r: r["offset"]):
        gap = f"  gap={r['gap_bytes']:5d}" if uncov is not None else ""
        print(f"  0x{r['offset']:06x}  bank ${r['bank']:02x} ${r['addr']:04x}: "
              f"{r['count']:3d} screens, {r['bytes']:5d}B{gap}")
    if singletons:
        print(f"\n{len(singletons)} singleton candidates (verify before trusting):")
        for r in sorted(singletons, key=lambda r: r["offset"]):
            s = r["screens"][0]
            print(f"  0x{r['offset']:06x}  bank ${r['bank']:02x} ${r['addr']:04x}: "
                  f"1 screen {s['rows']}x{s['cols']}, {r['bytes']}B")

    if args.json:
        with open(args.json, "w") as fh:
            json.dump({"confident": confident, "singletons": singletons}, fh, indent=2)
        print(f"\nwrote {args.json}")


if __name__ == "__main__":
    main()
