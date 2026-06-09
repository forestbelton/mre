"""Disassemble a floor record (581-byte slot) into the build_room.py JSON form.

Inverse of tools/build_room.py: reads a record's bytes from the built ROM (by
label, via the .sym map) and emits a Room JSON object that build_room.py turns
back into the identical record.
"""
import argparse
import json
import re

RECORD_SIZE = 581
COLL = {0x00: "F", 0x20: "B", 0x21: "W", 0x22: "C"}  # collision byte -> letter
EMPTY_MONSTER = bytes([0xFF, 0xFF, 0xFF, 0x01, 0xFF])
EMPTY_SPAWNER = bytes([0xFF] * 12)
SPAWN_NONE = 0xFF


def parse_enum(path: str, name: str) -> dict[int, str]:
    """Parse an enum.inc `enum <name> ... end_enum` block into {value: case}."""
    text = open(path).read()
    m = re.search(rf"^enum {name}\b(.*?)^end_enum", text, re.S | re.M)
    if not m:
        raise ValueError(f"enum {name} not found in {path}")
    values: dict[int, str] = {}
    val = 0
    for line in m.group(1).splitlines():
        line = line.split(";")[0].strip()
        if line.startswith("case "):
            values[val] = line.split()[1]
            val += 1
        elif line == "skip":
            val += 1
    return values


ITEMS = parse_enum("include/room.inc", "ITEM")
MONSTERS = parse_enum("include/monster.inc", "MONSTER")


def decode_room(rec: bytes, name: str) -> dict:
    assert len(rec) == RECORD_SIZE, f"{name}: record is {len(rec)} bytes, expected {RECORD_SIZE}"
    rid, sx, sy, _pad, tileset, palette, height, width = rec[:8]
    off = 8
    coll = rec[off : off + height * width]
    off += height * width
    piece = rec[off : off + height * width]
    off += height * width
    species_raw = rec[off : off + 4]
    off += 4
    arr2 = rec[off : off + 45]
    off += 45
    arr3 = rec[off : off + 48]
    off += 48
    trailer = rec[off:]

    collision = [
        "".join(COLL[coll[y * width + x]] for x in range(width)) for y in range(height)
    ]
    objects = decode_pieces(piece, width, height)
    species = [MONSTERS[b].removeprefix("") for b in species_raw]  # enum case names
    monsters = decode_monsters(arr2)
    spawners = decode_spawners(arr3)

    return {
        "id": rid,
        "name": name,
        "spawn": {"x": sx, "y": sy},
        "tileset": tileset,
        "palette": palette,
        "height": height,
        "width": width,
        "collision": collision,
        "objects": objects,
        "species": species,
        "monsters": monsters,
        "spawners": spawners,
        "trailer": list(trailer),
    }


def decode_pieces(piece: bytes, width: int, height: int) -> list[dict]:
    objects: list[dict] = []
    for y in range(height):
        for x in range(width):
            b = piece[y * width + x]
            border = x in (0, width - 1) or y in (0, height - 1)
            if border or b == 0x00:
                continue  # border / floor
            cell = {"x": x + 1, "y": y + 1}  # objects are 1-based
            if b == 0x40:
                objects.append({**cell, "type": "exit"})
            elif b & 0x80:
                obj = {**cell, "type": "item", "item": ITEMS[b & 0x3F]}
                if not (b & 0x40):
                    obj["hidden"] = True
                objects.append(obj)
            else:
                objects.append({**cell, "type": "tile", "value": b})
    return objects


def decode_monsters(arr2: bytes) -> list[dict]:
    out = []
    for i in range(9):
        slot = arr2[i * 5 : i * 5 + 5]
        if slot == EMPTY_MONSTER:
            continue
        x, y, mtype, facing, index = slot
        entry = {"slot": i, "x": x, "y": y, "type": mtype, "facing": facing, "index": index}
        if i == len(out):  # contiguous from the front -> slot is redundant
            del entry["slot"]
        out.append(entry)
    return out


def decode_spawners(arr3: bytes) -> list[dict]:
    out = []
    for i in range(4):
        slot = arr3[i * 12 : i * 12 + 12]
        if slot == EMPTY_SPAWNER:
            continue
        x, y, p0, p1, p2 = slot[:5]
        steps = list(slot[5:11])
        while steps and steps[-1] == SPAWN_NONE:
            steps.pop()
        entry = {"slot": i, "x": x, "y": y, "p0": p0, "p1": p1, "p2": p2, "schedule": steps}
        if i == len(out):
            del entry["slot"]
        out.append(entry)
    return out


def load_sym(path: str) -> dict[str, int]:
    sym = {}
    for line in open(path):
        m = re.match(r"([0-9a-f]{2}):([0-9a-f]{4}) (\w+)$", line.strip())
        if m:
            bank, addr = int(m.group(1), 16), int(m.group(2), 16)
            sym[m.group(3)] = bank * 0x4000 + (addr - 0x4000)
    return sym


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--rom", default="build/rom.gbc")
    ap.add_argument("--sym", default="build/rom.gbc.sym")
    ap.add_argument("--label", required=True, help="record label in the .sym map")
    ap.add_argument("--name", required=True, help="JSON room name (section/label)")
    ap.add_argument("--output", "-o")
    args = ap.parse_args()
    rom = open(args.rom, "rb").read()
    base = load_sym(args.sym)[args.label]
    room = decode_room(rom[base : base + RECORD_SIZE], args.name)
    out = json.dumps(room, indent=4)
    if args.output:
        open(args.output, "w").write(out + "\n")
    else:
        print(out)


if __name__ == "__main__":
    main()
