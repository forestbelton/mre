#!/usr/bin/env python3
"""Decode and print a tower floor's stored record — items, monsters, spawners.

A normal tower floor N (screen mode $c2c1 == 0) loads record N-1 via
FloorBankTable ($1567) + FloorPtrTable ($15bf); see docs/floor_data.md. (Special
floors use other modes / the $1783 remap and aren't handled here.) Item and
monster names are parsed from include/room.inc so they stay in sync.

Record layout (581 bytes): 8-byte header [type][spawnX][spawnY][?][?][?][H][W],
then an H*W collision grid, an H*W piece grid, then arr1 (4B species table),
arr2 (9 monster slots x 5B), arr3 (8 spawner slots x 6B).

Usage:
    tools/floor.py <floor> [--rom rom.gbc] [--inc include/room.inc] [--grids]
"""

import argparse
import re
from pathlib import Path
from typing import Literal, TypedDict

FLOOR_BANK_TABLE = 0x1567  # $00:$1567, one bank byte per floor
FLOOR_PTR_TABLE = 0x15BF  # $00:$15bf, one LE pointer per floor
COLL_CRATE = 0x22  # collision value for a breakable crate

Names = dict[int, str]


def parse_enum(text: str, name: str) -> Names:
    """Parse an `enum <name> / case X / skip / end_enum` block (enum.inc) into
    {discriminant: case_name}, starting at 0 and incrementing per case/skip."""
    out: dict[int, str] = {}
    in_enum = False
    disc = 0
    for line in text.splitlines():
        s = line.strip()
        if not in_enum:
            m = re.match(r"enum\s+(\w+)", s)
            if m and m.group(1) == name:
                in_enum, disc = True, 0
            continue
        if s.startswith("end_enum"):
            break
        m = re.match(r"case\s+(\w+)", s)
        if m:
            out[disc] = m.group(1)
            disc += 1
        elif re.match(r"skip\b", s):
            disc += 1
    return out


def parse_legend(inc_path: str) -> tuple[Names, Names]:
    """Return ({base_id: item_name}, {species_id: monster_name}) from room.inc.
    Items are an `enum ITEM` block; monsters are an `enum MONSTER` block."""
    text = Path(inc_path).read_text()
    items = parse_enum(text, "ITEM")
    mons = parse_enum(text, "MONSTER")
    return items, mons


class FloorRecord(TypedDict):
    d: int
    bank: int
    ptr: int
    flat: int
    hdr: bytes
    h: int
    w: int
    coll: bytes
    pieces: bytes
    arr1: bytes
    arr2: bytes
    arr3: bytes


def read_record(rom: bytes, floor: int) -> FloorRecord:
    d = floor - 1
    bank = rom[FLOOR_BANK_TABLE + d]
    if not (0 < bank < len(rom) // 0x4000):
        raise SystemExit(
            f"floor {floor}: record {d} has bank ${bank:02x} "
            f"(not a normal mode-0 floor?)"
        )
    ptr = rom[FLOOR_PTR_TABLE + d * 2] | (rom[FLOOR_PTR_TABLE + d * 2 + 1] << 8)
    flat = bank * 0x4000 + (ptr - 0x4000)
    hdr = rom[flat : flat + 8]
    h, w = hdr[6], hdr[7]
    body = flat + 8
    coll = rom[body : body + h * w]
    pieces = rom[body + h * w : body + 2 * h * w]
    t = body + 2 * h * w
    return FloorRecord(
        d=d,
        bank=bank,
        ptr=ptr,
        flat=flat,
        hdr=hdr,
        h=h,
        w=w,
        coll=coll,
        pieces=pieces,
        arr1=rom[t : t + 4],
        arr2=rom[t + 4 : t + 49],
        arr3=rom[t + 49 : t + 97],
    )


def item_state(byte: int, collision: int) -> Literal["visible", "hidden", "in-crate"]:
    # A crate ($22 collision) hides the item regardless of bit 6; otherwise bit 6
    # picks visible (set) vs hidden/phantom (clear).
    if collision == COLL_CRATE:
        return "in-crate"
    return "visible" if (byte & 0x40) else "hidden"


def main() -> None:
    ap = argparse.ArgumentParser(
        description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter
    )
    ap.add_argument("floor", type=int)
    ap.add_argument("--rom", default="rom.gbc")
    ap.add_argument("--inc", default="include/room.inc")
    ap.add_argument("--grids", action="store_true", help="also print the two grids")
    args = ap.parse_args()

    rom = Path(args.rom).read_bytes()
    items, mons = parse_legend(args.inc)
    r = read_record(rom, args.floor)
    h, w, coll, pieces, a1 = r["h"], r["w"], r["coll"], r["pieces"], r["arr1"]

    print(
        f"FLOOR {args.floor} = record {r['d']}  bank ${r['bank']:02x}:${r['ptr']:04x}"
        f"  {h}x{w} (interior {w-2}x{h-2})  type=${r['hdr'][0]:02x}"
        f"  spawn=(col {r['hdr'][1]},row {r['hdr'][2]})"
        f"  arr1={' '.join(f'{b:02x}' for b in a1)}"
    )

    if args.grids:
        for name, g in (("collision", coll), ("piece", pieces)):
            print(f"\n{name} grid:")
            for rr in range(h):
                print("  " + " ".join(f"{b:02x}" for b in g[rr * w : (rr + 1) * w]))

    print("\nitems (row, col, code, name, state):")
    found = False
    for rr in range(h):
        for c in range(w):
            v = pieces[rr * w + c]
            if v & 0x80:
                found = True
                base = v & 0x3F
                name = items.get(base, f"?? base ${base:02x}")
                print(
                    f"  row {rr:2d}, col {c:2d}  ${v:02x}  {name:18s} {item_state(v, coll[rr*w+c])}"
                )
    if not found:
        print("  (none)")

    print("\nmonsters (arr2):")
    found = False
    for s in range(9):
        e = r["arr2"][s * 5 : s * 5 + 5]
        if e[4] != 0xFF and e[4] < len(a1):
            found = True
            sp = a1[e[4]]
            print(
                f"  row {e[1]:2d}, col {e[0]:2d}  species=${sp:02x} {mons.get(sp, '?? NEW ??')}"
            )
    if not found:
        print("  (none)")

    # arr3 spawner entries are 6 bytes [col][row][p0][p1][p2][gfxIndex]. The species
    # is arr1[gfxIndex] (same as arr2); gfxIndex $ff = inert (spawns nothing).
    # p0/p1/p2 are spawn rate/count (packed for Func_01_4219) -- not decoded yet.
    print("\nspawners (arr3):")
    found = False
    for s in range(8):
        e = r["arr3"][s * 6 : s * 6 + 6]
        if e[0] != 0xFF and e[1] != 0xFF:  # both $ff col & row = dead slot
            found = True
            gi = e[5]
            if gi < len(a1):
                sp = a1[gi]
                who = mons.get(sp, "?? NEW ??")
                print(
                    f"  col {e[0]:2d}, row {e[1]:2d}  spawns ${sp:02x} {who}"
                    f"  rate={e[2]:02x} {e[3]:02x} {e[4]:02x}"
                )
            else:
                print(f"  col {e[0]:2d}, row {e[1]:2d}  inert (gfxIndex=${gi:02x})")
    if not found:
        print("  (none)")


if __name__ == "__main__":
    main()
