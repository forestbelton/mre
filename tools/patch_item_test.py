#!/usr/bin/env python3
"""Experiment: place an item id, *visible*, on floor 1 so it can be observed in an
emulator. Writes a PATCHED COPY of the ROM (never modifies the input rom.gbc), so it
is safe to run while the analyzer is using rom.gbc.

Why floor 1: the game-start init (Func_05_4785) sets wC2D5 bit 0, and the
conditional-appearance removal pass (Func_01_56fb / Data_01_5162) is skipped while
bit 0 is set. So for ids gated only by that table ($1b, $1c, ...) just placing the
item is enough. As a belt-and-suspenders we also zero the item's $5162 flag.

NOTE: $16 has a *separate*, still-unidentified suppressor (it is not in $5162), so
this patch alone may not surface it.

Usage:
    tools/patch_item_test.py <id-hex> [--rom rom.gbc] [--out build/rom_item_<id>.gbc]
                             [--cell ROW,COL] [--no-flag-patch]
"""
import argparse
import importlib.util
from pathlib import Path

COND_FLAG_TABLE = 0x5162  # Data_01_5162: bank $01, flat offset == addr


def load_floor_mod():
    spec = importlib.util.spec_from_file_location(
        "floor", Path(__file__).with_name("floor.py")
    )
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def pick_cell(rec, want=None):
    """Choose a walkable ($00 collision) + empty ($00 piece) cell, defaulting to the
    one nearest the player's spawn (but not the spawn tile itself)."""
    h, w, coll, pieces = rec["h"], rec["w"], rec["coll"], rec["pieces"]
    spawn_c, spawn_r = rec["hdr"][1], rec["hdr"][2]
    if want is not None:
        r, c = want
        return r, c
    best = None
    for r in range(h):
        for c in range(w):
            if coll[r * w + c] == 0x00 and pieces[r * w + c] == 0x00:
                if (r, c) == (spawn_r, spawn_c):
                    continue
                d = abs(r - spawn_r) + abs(c - spawn_c)
                if best is None or d < best[0]:
                    best = (d, r, c)
    if best is None:
        raise SystemExit("no empty walkable cell found on floor 1")
    return best[1], best[2]


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("id", help="item base id in hex, e.g. 1c")
    ap.add_argument("--rom", default="rom.gbc")
    ap.add_argument("--out", default=None)
    ap.add_argument("--cell", default=None, help="ROW,COL (1-based grid incl. border)")
    ap.add_argument("--no-flag-patch", action="store_true",
                    help="don't zero the $5162 conditional flag for this id")
    args = ap.parse_args()

    iid = int(args.id, 16)
    if not (0 <= iid <= 0x3F):
        raise SystemExit("id must be 0x00-0x3f")
    out = args.out or f"build/rom_item_{iid:02x}.gbc"

    floor = load_floor_mod()
    rom = bytearray(Path(args.rom).read_bytes())
    rec = floor.read_record(bytes(rom), 1)
    h, w = rec["h"], rec["w"]
    pieces_off = rec["flat"] + 8 + h * w

    want = None
    if args.cell:
        rr, cc = (int(x) for x in args.cell.split(","))
        want = (rr, cc)
    r, c = pick_cell(rec, want)

    code = 0xC0 | iid  # bit7 item + bit6 visible
    cell_off = pieces_off + r * w + c
    prev = rom[cell_off]
    rom[cell_off] = code

    patched = [f"piece cell (row {r}, col {c}) @ ROM ${cell_off:05x}: "
               f"${prev:02x} -> ${code:02x}"]
    if not args.no_flag_patch:
        foff = COND_FLAG_TABLE + iid
        pflag = rom[foff]
        rom[foff] = 0x00
        patched.append(f"$5162[${iid:02x}] @ ROM ${foff:05x}: ${pflag:02x} -> $00")

    Path(out).parent.mkdir(parents=True, exist_ok=True)
    Path(out).write_bytes(rom)

    print(f"item ${iid:02x}: placed VISIBLE on floor 1, code ${code:02x}")
    for p in patched:
        print("  patch:", p)
    print(f"wrote {out}  (spawn is row {rec['hdr'][2]}, col {rec['hdr'][1]})")


if __name__ == "__main__":
    main()
