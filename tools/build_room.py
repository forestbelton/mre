import argparse
import json
import re
from typing import Literal, NotRequired, TypedDict

# Every floor record occupies a fixed 581-byte slot (the FloorPtrTable stride),
# sized for the largest 14x17 floor. Smaller floors leave the tail as unused
# "trailer" slack. See docs/floor_data.md.
RECORD_SIZE = 581


class RoomSpawn(TypedDict):
    x: int
    y: int


class AbstractRoomObject(TypedDict):
    x: int
    y: int


class RoomExit(AbstractRoomObject):
    type: Literal["exit"]


class RoomItem(AbstractRoomObject):
    type: Literal["item"]
    item: str | int  # enum case name, or a raw id for unnamed (`skip`) item ids
    hidden: NotRequired[bool]


class RoomTile(AbstractRoomObject):
    # A non-item room-piece tile (piece-grid byte with bit 7 clear), e.g. the
    # $43 Devil's Seal obstacle. `value` is the raw piece byte.
    type: Literal["tile"]
    value: int


RoomObject = RoomItem | RoomExit | RoomTile

# Named non-item piece-grid tiles (bit 7 clear); others are emitted as raw hex.
TILE_NAMES = {0x43: "TILE_OBSTACLE_BAT"}


class RoomMonster(TypedDict):
    slot: NotRequired[int]  # arr2 slot 0-8 (defaults to list order); preserves the
    # exact byte layout when empties are interspersed
    x: int
    y: int
    type: int  # packed behaviour: low 3 bits = speed, hi 3 bits (&$70) = AI param
    facing: int  # initial facing (0-3 direction, +4 sets a flag)
    index: int  # index into the room's species table (0-3)


class RoomSpawner(TypedDict):
    slot: NotRequired[int]  # arr3 slot 0-3 (defaults to list order)
    x: int
    y: int
    p0: int  # spawn-timing params (packed, undecoded)
    p1: int
    p2: int
    schedule: list[int]  # up to 6 steps; each a species-table index (0-3). Short
    # lists are padded with SPAWN_NONE.


class Room(TypedDict):
    id: int
    name: str
    spawn: RoomSpawn
    tileset: int
    palette: int
    height: int
    width: int
    collision: list[str]
    objects: list[RoomObject]
    species: list[str]
    monsters: list[RoomMonster]
    spawners: list[RoomSpawner]
    trailer: list[int]
    # Boss floors (records 70-74). The boss is spawned separately, so the floor's
    # species/monster/spawner tables are all unused ($ff); a boss record carves to
    # header + grids + a 93-byte $ff tail, with no trailer. The records are packed
    # front-to-front (placed contiguously by layout.link), each abutting the next
    # -- a record's arr3 tail (its final 4 bytes) doubles as the next record's
    # header, so it's omitted here and supplied by the abutting record.
    boss: NotRequired[bool]


# A boss record's tail: arr1(4) + arr2(45) + arr3 head(44), all $ff. arr3's last
# 4 bytes are the next record's header and are intentionally omitted.
BOSS_TAIL = 93


class RoomValidationError(Exception):
    pass


def check_slots(entries: list, count: int, kind: str) -> None:
    if len(entries) > count:
        raise RoomValidationError(f"at most {count} {kind}s per room")
    used = [e.get("slot", k) for k, e in enumerate(entries)]
    for s in used:
        if not 0 <= s < count:
            raise RoomValidationError(f"{kind} slot {s} out of range 0-{count - 1}")
    if len(set(used)) != len(used):
        raise RoomValidationError(f"duplicate {kind} slot")


def build_room(room: Room) -> str:
    if room.get("boss"):
        return build_boss_room(room)
    validate_room(room)
    label = re.sub(r"[^A-Za-z0-9_]", "", room["name"])
    collision_grid = build_collision_grid(room["collision"])
    object_grid = build_object_grid(room["width"], room["height"], room["objects"])
    species = ", ".join(f"MONSTER_{s}" for s in room["species"])
    monster_table = build_monster_table(room["monsters"], room["species"])
    spawner_table = build_spawner_table(room["spawners"])
    should_pad = room.get("pad", True)
    size = trailer_size(room) if should_pad else len(room["trailer"])
    trailer = build_trailer(room["trailer"], size)
    return f"""
INCLUDE "room.inc"

SECTION "{room['name']}", ROMX

{label}:
    dstruct Header, , \\
        .Id={to_hex(room['id'])}, \\
        .SpawnX={room['spawn']['x']}, \\
        .SpawnY={room['spawn']['y']}, \\
        .Pad=$00, \\
        .Tileset={room['tileset']}, \\
        .Palette={room['palette']}, \\
        .Height={room['height']}, \\
        .Width={room['width']}
    assert @ - {label} == sizeof_Header

    ; Collision grid ({room['height']} rows x {room['width']} columns)
.collision:
{collision_grid}
    assert @ - .collision == {room['height']} * {room['width']}

    ; Object grid ({room['height']} rows x {room['width']} columns)
.objects:
{object_grid}
    assert @ - .objects == {room['height']} * {room['width']}

    ; Species table (indexed by a monster's Index field)
    db {species}

    ; Monster table (9 slots)
.monsters:
{monster_table}
    assert @ - .monsters == sizeof_Monster * 9

    ; Spawner table (4 slots)
.spawners:
{spawner_table}
    assert @ - .spawners == sizeof_Spawner * 4

    ; Trailer ({trailer_size(room)} bytes of unused slot slack)
{trailer}
    {f"assert @ - {label} == {RECORD_SIZE}" if should_pad else ""}
""".strip() + "\n"


def build_boss_room(room: Room) -> str:
    validate_geometry(room)
    label = re.sub(r"[^A-Za-z0-9_]", "", room["name"])
    collision_grid = build_collision_grid(room["collision"])
    object_grid = build_object_grid(room["width"], room["height"], room["objects"])
    return f"""
INCLUDE "room.inc"

SECTION "{room['name']}", ROMX

; Boss floor record: the boss is spawned separately (Data_01_4335), so the
; floor's species/monster/spawner tables are all unused ($ff). The records are
; packed front-to-front (placed contiguously by layout.link), each abutting the
; next -- a record's arr3 tail (its final 4 bytes) doubles as the next record's
; header, so those 4 bytes are omitted here and supplied by the abutting record.
; See docs/special_floor_records.md.
{label}:
    dstruct Header, , \\
        .Id={to_hex(room['id'])}, \\
        .SpawnX={room['spawn']['x']}, \\
        .SpawnY={room['spawn']['y']}, \\
        .Pad=$00, \\
        .Tileset={room['tileset']}, \\
        .Palette={room['palette']}, \\
        .Height={room['height']}, \\
        .Width={room['width']}
    assert @ - {label} == sizeof_Header

    ; Collision grid ({room['height']} rows x {room['width']} columns)
.collision:
{collision_grid}
    assert @ - .collision == {room['height']} * {room['width']}

    ; Object grid ({room['height']} rows x {room['width']} columns)
.objects:
{object_grid}
    assert @ - .objects == {room['height']} * {room['width']}

    ; Unused tables (arr1/arr2/arr3, all $ff); arr3's final 4 bytes are the next
    ; record's header, provided by the abutting record.
    ds {BOSS_TAIL}, INERT
    assert @ - {label} == 8 + 2 * {room['height']} * {room['width']} + {BOSS_TAIL}
""".strip() + "\n"


def build_collision_grid(coll: list[str]) -> str:
    def build_row(row: str) -> str:
        return ", ".join(f"COLL_{cell}" for cell in row)

    return "\n".join(f"    db {build_row(row)}" for row in coll)


def build_object_grid(width: int, height: int, objects: list[RoomObject]) -> str:
    # Object coordinates are 1-based (col/row 1 is the border); the grid is
    # 0-based, so an object at (x, y) lands in grid cell (x-1, y-1).
    by_cell = {(o["x"] - 1, o["y"] - 1): o for o in objects}

    def build_cell(x: int, y: int) -> str:
        if x == 0 or x == width - 1 or y == 0 or y == height - 1:
            return "COLL_B"
        found = by_cell.get((x, y))
        if found is None:
            return "COLL_F"
        match found["type"]:
            case "item":
                entry = "ITEM_FLAG"
                if not found.get("hidden", False):
                    entry += " | ITEM_OPEN"
                # `item` is an enum case name, or a raw id for the unnamed (`skip`)
                # ids like the $21/$22 special-stage tokens.
                item = found["item"]
                base = f"ITEM_{item}" if isinstance(item, str) else to_hex(item)
                return entry + f" | {base}"
            case "exit":
                return "TILE_EXIT"
            case "tile":
                return TILE_NAMES.get(found["value"], to_hex(found["value"]))
        raise RoomValidationError(f"unknown object type: {found['type']}")

    def build_row(y: int) -> str:
        return ", ".join(build_cell(x, y) for x in range(width))

    return "\n".join(f"    db {build_row(y)}" for y in range(height))


def place_by_slot(entries: list, count: int) -> list:
    # Map entries into `count` fixed slots. An entry's slot is its "slot" field,
    # or its list position when none is given (compact, for hand-written rooms).
    slots: list = [None] * count
    for k, e in enumerate(entries):
        slots[e.get("slot", k)] = e
    return slots


def build_monster_table(monsters: list[RoomMonster], species: list[str]) -> str:
    lines: list[str] = []
    for m in place_by_slot(monsters, 9):
        if m is None:
            lines.append("    EMPTY_MONSTER_SLOT")
            continue
        name = "UNUSED"
        if m["index"] in species:
            name = species[m["index"]]
        lines.append(
            f"    dstruct Monster, , .X={m['x']}, .Y={m['y']}, "
            f".Type={to_hex(m['type'])}, .Facing={m['facing']}, .Index={m['index']}"
            f"   ; {name}"
        )
    return "\n".join(lines)


def build_spawner_table(spawners: list[RoomSpawner]) -> str:
    lines: list[str] = []
    for s in place_by_slot(spawners, 4):
        if s is None:
            lines.append("    EMPTY_SPAWNER_SLOT")
            continue
        steps = [
            str(s["schedule"][i]) if i < len(s["schedule"]) else "SPAWN_NONE"
            for i in range(6)
        ]
        spawn_fields = ", ".join(f".Spawn{i}={steps[i]}" for i in range(6))
        lines.append(
            f"    dstruct Spawner, , .X={s['x']}, .Y={s['y']}, "
            f".P0={to_hex(s['p0'])}, .P1={to_hex(s['p1'])}, .P2={to_hex(s['p2'])}, "
            f"{spawn_fields}, .End=INERT"
        )
    return "\n".join(lines)


def build_trailer(trailer: list[int], size: int) -> str:
    # Emit the supplied slack bytes, $00-padded up to the slot's trailer size.
    # (The trailer is never read; bytes only matter for byte-exact reproduction.)
    padded = list(trailer) + [0] * (size - len(trailer))
    if not padded:
        return ""
    rows = [padded[i : i + 16] for i in range(0, len(padded), 16)]
    return "\n".join("    db " + ", ".join(to_hex(b) for b in row) for row in rows)


def trailer_size(room: Room) -> int:
    front = 8 + 2 * room["height"] * room["width"] + 4 + 9 * 5 + 4 * 12
    return RECORD_SIZE - front


def to_hex(x: int) -> str:
    return f"${x:02x}"


def validate_geometry(room: Room):
    if room["height"] <= 0 or room["height"] >= 15:
        raise RoomValidationError("room height must be between 1 and 14")
    if room["width"] <= 0 or room["width"] >= 18:
        raise RoomValidationError("room width must be between 1 and 17")
    if room["height"] != len(room["collision"]):
        raise RoomValidationError(
            f"height mismatch in collision map: expected={room['height']}, actual={len(room['collision'])}"
        )
    for y, row in enumerate(room["collision"]):
        if room["width"] != len(row):
            raise RoomValidationError(
                f"width mismatch in collision row {y}: expected={room['width']}, actual={len(row)}"
            )
    for i, obj in enumerate(room["objects"]):
        if (
            obj["x"] <= 1
            or obj["x"] > room["width"] - 1
            or obj["y"] <= 1
            or obj["y"] > room["height"] - 1
        ):
            raise RoomValidationError(
                f"object {i} outside of room bounds: {obj['x']}, {obj['y']}"
            )


def validate_room(room: Room):
    validate_geometry(room)
    if len(room["species"]) != 4:
        raise RoomValidationError("must have exactly 4 species")
    check_slots(room["monsters"], 9, "monster")
    for i, m in enumerate(room["monsters"]):
        if m["index"] == 0xFF:
            continue
        if not 0 <= m["index"] < 4:
            raise RoomValidationError(f"monster {i} index must be 0-3")
        if m["type"] & 0x88:
            raise RoomValidationError(f"monster {i} type uses reserved bits 3/7")
    check_slots(room["spawners"], 4, "spawner")
    for i, s in enumerate(room["spawners"]):
        if len(s["schedule"]) > 6:
            raise RoomValidationError(f"spawner {i} schedule has at most 6 steps")
    size = trailer_size(room)
    if size < 0:
        raise RoomValidationError("room is larger than the 581-byte slot")
    if len(room["trailer"]) > size:
        raise RoomValidationError(
            f"trailer too long: {len(room['trailer'])} bytes, slot holds {size}"
        )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", "-o")
    parser.add_argument("input")
    args = parser.parse_args()
    with open(args.input, "r") as f:
        room: Room = json.load(f)
    source = build_room(room)
    if args.output is None:
        print(source)
    else:
        with open(args.output, "w") as f:
            f.write(source)


if __name__ == "__main__":
    main()
