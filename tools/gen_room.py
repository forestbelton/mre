#!/usr/bin/env python3
"""Generate a readable src/room/roomNN.asm for one tower floor record (or all).

Emits the floor record -- header, collision/piece grids, sprite/monster/spawner
tables -- using the structs and named constants in include/room.inc, byte-exact
against the ROM. Floors 1-60 -> room{NN}.asm; basement floors 61-70 ->
roomB{NN}.asm (B1-B10). Records 70+ (bonus stages) aren't handled.

extract.py is append-only for existing code files, so a generated room survives
later `make extract` runs (and hand-edits to it are preserved too).

Usage:
    tools/gen_room.py <floor>        # one floor (1-70)
    tools/gen_room.py --all          # floors 1-70
"""

import argparse
import importlib.util
from pathlib import Path

FLOOR_BANK_TABLE = 0x1567
FLOOR_PTR_TABLE = 0x15BF

COLL = {0x00: "COLL_F", 0x20: "COLL_B", 0x21: "COLL_W", 0x22: "COLL_C"}
TILE = {0x40: "TILE_EXIT", 0x43: "TILE_OBSTACLE_BAT"}


def load_floor_mod():
    spec = importlib.util.spec_from_file_location(
        "floor", Path(__file__).with_name("floor.py"))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def room_name(floor: int) -> tuple[str, str]:
    """(file stem, asm label) for a floor: 1-60 -> roomNN, 61-70 -> roomBNN."""
    if floor <= 60:
        return f"room{floor:02d}", f"Room{floor:02d}"
    b = floor - 60
    return f"roomB{b:02d}", f"RoomB{b:02d}"


def gen(rom: bytes, floor: int, items, mons) -> tuple[str, str]:
    d = floor - 1
    bank = rom[FLOOR_BANK_TABLE + d]
    ptr = rom[FLOOR_PTR_TABLE + d * 2] | (rom[FLOOR_PTR_TABLE + d * 2 + 1] << 8)
    flat = bank * 0x4000 + (ptr - 0x4000)
    h, w = rom[flat + 6], rom[flat + 7]
    rec = rom[flat:flat + 105 + 2 * h * w]
    name, label = room_name(floor)

    def coll_tok(v):
        return COLL.get(v, f"${v:02x}")

    def piece_tok(v):
        if v & 0x80:
            base = v & 0x3F
            nm = items.get(base)
            parts = ["ITEM_FLAG"] + (["ITEM_OPEN"] if v & 0x40 else [])
            parts.append(f"ITEM_{nm}" if nm else f"${base:02x}")
            return " | ".join(parts)
        return COLL.get(v) or TILE.get(v) or f"${v:02x}"

    def grid(data, tok):
        return ["    db " + ", ".join(tok(data[r * w + c]) for c in range(w))
                for r in range(h)]

    hd = rec[:8]
    L = [
        f"; Floor {floor} (record {d}) -- {w} wide x {h} tall. Tower floor data; "
        "see docs/floor_data.md.", "",
        'INCLUDE "room.inc"', "",
        f'SECTION "{name}", ROMX[${ptr:04x}], BANK[${bank:02x}]', f"{label}:",
        f"    dstruct Header, , .Type=${hd[0]:02x}, .SpawnX={hd[1]}, .SpawnY={hd[2]}, "
        f".Pad=${hd[3]:02x}, .Param0=${hd[4]:02x}, .Param1=${hd[5]:02x}, "
        f".Height={hd[6]}, .Width={hd[7]}",
        f"    assert @ - {label} == sizeof_Header", "",
        f"    ; collision grid ({h} rows x {w})",
    ]
    L += grid(rec[8:8 + h * w], coll_tok)
    L += ["", f"    ; piece/object grid ({h} rows x {w})"]
    L += grid(rec[8 + h * w:8 + 2 * h * w], piece_tok)

    t = 8 + 2 * h * w
    arr1 = rec[t:t + 4]
    L += [
        "", "    ; arr1: per-floor sprite/species table (indexed by a monster's Index)",
        "    db " + ", ".join(f"MONSTER_{mons.get(b, f'${b:02x}')}" for b in arr1),
        "", "    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)", ".monsters",
    ]
    arr2 = rec[t + 4:t + 49]
    for s in range(9):
        e = arr2[s * 5:s * 5 + 5]
        if e[4] != 0xFF and e[4] < len(arr1):
            sp = mons.get(arr1[e[4]], "?")
            L.append(f"    dstruct Monster, , .X={e[0]}, .Y={e[1]}, .Type=${e[2]:02x}, "
                     f".Param=${e[3]:02x}, .Index={e[4]}   ; {sp}")
        else:
            L.append("    EMPTY_MONSTER_SLOT")
    L += ["    assert @ - .monsters == sizeof_Monster * 9", "",
          "    ; arr3: 8 spawner slots (Spawner: X,Y,P0,P1,P2,Index)", ".spawners"]
    arr3 = rec[t + 49:t + 97]
    for s in range(8):
        e = arr3[s * 6:s * 6 + 6]
        if e[0] != 0xFF:
            L.append(f"    dstruct Spawner, , .X={e[0]}, .Y={e[1]}, .P0=${e[2]:02x}, "
                     f".P1=${e[3]:02x}, .P2=${e[4]:02x}, .Index={e[5]}")
        else:
            L.append("    EMPTY_SPAWNER_SLOT")
    L.append("    assert @ - .spawners == sizeof_Spawner * 8")
    return name, "\n".join(L) + "\n"


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("floor", nargs="?", type=int)
    ap.add_argument("--all", action="store_true", help="generate floors 1-70")
    ap.add_argument("--rom", default="rom.gbc")
    ap.add_argument("--inc", default="include/room.inc")
    args = ap.parse_args()

    rom = Path(args.rom).read_bytes()
    floor_mod = load_floor_mod()
    items, mons = floor_mod.parse_legend(args.inc)

    if args.all:
        floors = range(1, 71)
    elif args.floor:
        floors = [args.floor]
    else:
        ap.error("give a floor number or --all")

    outdir = Path("src/room")
    outdir.mkdir(parents=True, exist_ok=True)
    for f in floors:
        name, text = gen(rom, f, items, mons)
        (outdir / f"{name}.asm").write_text(text)
    print(f"wrote {len(list(floors))} room file(s)")


if __name__ == "__main__":
    main()
