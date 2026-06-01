#!/usr/bin/env python3
"""Decode and print a tower floor's stored record — items, monsters, spawners.

A normal tower floor N (screen mode $c2c1 == 0) loads record N-1 via
FloorBankTable ($1567) + FloorPtrTable ($15bf); see docs/floor_data.md. (Special
floors use other modes / the $1783 remap and aren't handled here.) Item and
monster names are parsed from include/items.inc so they stay in sync.

Record layout (581 bytes): 8-byte header [type][spawnX][spawnY][?][?][?][H][W],
then an H*W collision grid, an H*W piece grid, then arr1 (4B species table),
arr2 (9 monster slots x 5B), arr3 (4 spawner slots x 6B).

Usage:
    tools/floor.py <floor> [--rom rom.gbc] [--inc include/items.inc] [--grids]
"""
import argparse
import re
from pathlib import Path

FLOOR_BANK_TABLE = 0x1567   # $00:$1567, one bank byte per floor
FLOOR_PTR_TABLE  = 0x15bf   # $00:$15bf, one LE pointer per floor
COLL_CRATE = 0x22           # collision value for a breakable crate


def parse_legend(inc_path):
    """Return ({base_id: item_name}, {species_id: monster_name}) from items.inc."""
    text = Path(inc_path).read_text()
    items, mons = {}, {}
    for m in re.finditer(r'DEF\s+IID_(\w+)\s+EQU\s+\$([0-9A-Fa-f]+)', text):
        items[int(m.group(2), 16)] = m.group(1)
    for m in re.finditer(r'DEF\s+MON_(\w+)\s+EQU\s+\$([0-9A-Fa-f]+)', text):
        mons[int(m.group(2), 16)] = m.group(1)
    return items, mons


def read_record(rom, floor):
    d = floor - 1
    bank = rom[FLOOR_BANK_TABLE + d]
    if not (0 < bank < len(rom) // 0x4000):
        raise SystemExit(f"floor {floor}: record {d} has bank ${bank:02x} "
                         f"(not a normal mode-0 floor?)")
    ptr = rom[FLOOR_PTR_TABLE + d * 2] | (rom[FLOOR_PTR_TABLE + d * 2 + 1] << 8)
    flat = bank * 0x4000 + (ptr - 0x4000)
    hdr = rom[flat:flat + 8]
    h, w = hdr[6], hdr[7]
    body = flat + 8
    coll = rom[body:body + h * w]
    pieces = rom[body + h * w:body + 2 * h * w]
    t = body + 2 * h * w
    return dict(d=d, bank=bank, ptr=ptr, flat=flat, hdr=hdr, h=h, w=w,
                coll=coll, pieces=pieces,
                arr1=rom[t:t + 4], arr2=rom[t + 4:t + 49], arr3=rom[t + 49:t + 97])


def item_state(byte, collision):
    if not (byte & 0x40):
        return "hidden"
    return "in-crate" if collision == COLL_CRATE else "visible"


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("floor", type=int)
    ap.add_argument("--rom", default="rom.gbc")
    ap.add_argument("--inc", default="include/items.inc")
    ap.add_argument("--grids", action="store_true", help="also print the two grids")
    args = ap.parse_args()

    rom = Path(args.rom).read_bytes()
    items, mons = parse_legend(args.inc)
    r = read_record(rom, args.floor)
    h, w, coll, pieces, a1 = r["h"], r["w"], r["coll"], r["pieces"], r["arr1"]

    print(f"FLOOR {args.floor} = record {r['d']}  bank ${r['bank']:02x}:${r['ptr']:04x}"
          f"  {h}x{w} (interior {w-2}x{h-2})  type=${r['hdr'][0]:02x}"
          f"  spawn=(col {r['hdr'][1]},row {r['hdr'][2]})"
          f"  arr1={' '.join(f'{b:02x}' for b in a1)}")

    if args.grids:
        for name, g in (("collision", coll), ("piece", pieces)):
            print(f"\n{name} grid:")
            for rr in range(h):
                print("  " + " ".join(f"{b:02x}" for b in g[rr*w:(rr+1)*w]))

    print("\nitems (row, col, code, name, state):")
    found = False
    for rr in range(h):
        for c in range(w):
            v = pieces[rr*w + c]
            if v & 0x80:
                found = True
                base = v & 0x3f
                name = items.get(base, f"?? base ${base:02x}")
                print(f"  row {rr:2d}, col {c:2d}  ${v:02x}  {name:18s} {item_state(v, coll[rr*w+c])}")
    if not found:
        print("  (none)")

    print("\nmonsters (arr2):")
    found = False
    for s in range(9):
        e = r["arr2"][s*5:s*5+5]
        if e[4] != 0xff and e[4] < len(a1):
            found = True
            sp = a1[e[4]]
            print(f"  row {e[1]:2d}, col {e[0]:2d}  species=${sp:02x} {mons.get(sp, '?? NEW ??')}")
    if not found:
        print("  (none)")

    print("\nspawners (arr3):")
    found = False
    for s in range(4):
        e = r["arr3"][s*6:s*6+6]
        if e[0] != 0xff:
            found = True
            sp = a1[e[5]] if e[5] < len(a1) else None
            spn = mons.get(sp, "?? NEW ??") if sp is not None else "?"
            print(f"  col {e[0]:2d}, row {e[1]:2d}  species=${(sp if sp is not None else 0):02x} {spn}"
                  f"  params={e[2]:02x} {e[3]:02x} {e[4]:02x}")
    if not found:
        print("  (none)")


if __name__ == "__main__":
    main()
