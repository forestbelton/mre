# Special floor records (boss / bonus / editor) and the boss-record overlap

The floor-record system (`docs/floor_data.md`) is driven by two parallel tables
in bank `$00`: `FloorBankTable` (`$1567`, 1 byte/record) and `FloorPtrTable`
(`$15bf`, 1 LE word/record), indexed by a record number that `LoadFloorByMode`
derives from `wActiveFloor` + the screen mode (`wRoomType`). `ParseFloorRecord`
(`$16ed`) expands every record the same way: 8-byte header, then packed `H×W`
collision grid, packed `H×W` piece grid, then `arr1` (4) / `arr2` (45) / `arr3`
(48) — total `105 + 2·H·W` bytes.

**Records 0–69 are carved** into `src/layout/room01.asm`–`room60.asm` (mode-0
floors 1–60) and `roomB01.asm`–`roomB10.asm` (records 60–69, the mode-1 floors).
**Records 70–87 are not yet carved** — they're still raw `Data_12_*` (and a few
non-ROM pointers) in `analyzed.asm`. They use the *same* format; the only reason
the boss block isn't carved is the overlap quirk below.

## Record map (70–87)

| Rec | bank:addr | dims | what | reached by |
|---|---|---|---|---|
| 70 | `$12:$5055` | 14×13 | **Boss: Selketo** | mode 2, idx 1 (after fl 10) |
| 71 | `$12:$5226` | 10×17 | **Boss: Ferious** | mode 2, idx 2 (after fl 20) |
| 72 | `$12:$53df` | 14×12 | **Boss: Punisher** | mode 2, idx 3 (after fl 40) |
| 73 | `$12:$5594` | 10×17 | **Boss: Dragon** | mode 2, idx 4 (after fl 50) |
| 74 | `$12:$574d` | 10×17 | **Boss: Zan** | mode 2, idx 5 (after fl 60) |
| 75 | `$12:$574d` | — | duplicate pointer to 74 (Zan); no data of its own |
| 76 | `$12:$4e10` | 14×17 | unused floor record (spawn 1,1) | no mode reaches it |
| 77 | `$12:$4ccb` | 10×11 | unused floor record (spawn 1,1) | no mode reaches it |
| 78 | `$00:$a009` | — | **SRAM** editor room 1 (`V03ROOM1`) | level editor |
| 79 | `$00:$a258` | — | **SRAM** editor room 2 (`V03ROOM2`) | level editor |
| 80 | `$00:$a4a7` | — | **SRAM** editor room 3 (`V03ROOM3`) | level editor |
| 81 | `$00:$c586` | — | **WRAM** record, built dynamically | mode 5 (link-cable "send a room" staging) |
| 82 | `$12:$5906` | 10×11 | **Bonus: Hare** (type `$66`) | from fl 6 via `BonusFloorRemap` |
| 83 | `$12:$5b4b` | 10×11 | **Bonus: Gali** (`$67`) | from fl 18 |
| 84 | `$12:$5d90` | 10×11 | **Bonus: Golem** (`$68`) | from fl 22 |
| 85 | `$12:$5fd5` | 10×11 | **Bonus: Suezo** (`$69`) | from fl 44 |
| 86 | `$12:$621a` | 10×11 | **Bonus: Tiger** (`$64`) | from fl 56 |
| 87 | `$12:$645f` | 10×11 | **Bonus: Mocchi** (`$65`) | from fl 58 |

Boss floors carry an empty `arr2` (the boss itself is spawned separately, from
`Data_01_4335` — see `docs/entity_scripts.md` "Tower bosses"). Zan's floor (74)
also holds the four `$21` "collect-4" corner tokens (`include/room.inc`).

Records 78–81 are **not ROM data**: 78–80 point into SRAM at the three
`V03ROOM1/2/3` editor-room save blocks (`include/wram.inc`), and 81 points into
WRAM (`$c586`) — mode 5 builds its record there at runtime (the editor's "send a
room" / link-cable path). Nothing to carve for those.

## The boss-record overlap (and how 70–74 are carved)

The boss records are **packed so that each record's runtime read overruns the
next record's header by 4 bytes.** A record's *read* size is `105 + 2·H·W`, but
consecutive boss records sit only `read_size − 4` apart:

```
rec 70 $5055  read 469 B -> ends $522a, but rec 71 starts $5226  (overlap 4)
rec 71 $5226  read 445 B -> ends $53eb, but rec 72 starts $53df  (overlap 4)
rec 72 $53df  read 441 B -> ends $5560, but rec 73 starts $5594  ... etc.
rec 73 $5594  read 445 B -> overlaps rec 74
rec 74 $574d  read 445 B -> overlaps rec 82 (Hare) by 4
```

The shared 4 bytes are the record's `arr3` tail **and** the next record's header
head at the same time (the last spawner slot's `Spawn3..End` == the next
record's `Type/SpawnX/SpawnY/Pad`). It works at load time because each record is
parsed independently; it's a deliberate space-saving trick.

The five boss records can't be five *overlapping* fixed-address `SECTION`s, but
the overlap is only the shared 4 bytes — so each record is carved emitting just
its **`front − 4`** unique bytes (header + grids + the 93-byte `$ff` tail), with
the trailing `arr3` slot dropped. That makes them **abut** instead of overlap,
and the next record's `Header` supplies the shared 4 (the last boss, `74`/Zan,
borrows them from `82`/Hare). Decisively: every boss record's `arr1`/`arr2`/`arr3`
is all `$ff` (the boss is spawned separately from `Data_01_4335`; mode 2 never
processes the floor's tables), so a boss record is purely **header + grids**.

## How they're carved

- `src/layout/boss/{selketo,ferious,punisher,dragon,zan}.json` — one JSON each,
  `"boss": true`, header + grids only (`tools/build_room.py` boss mode emits
  `ds 93, INERT` for the unused tail and no trailer; `tools/dump_room.py
  decode_boss_room` is the inverse).
- `layout.link` places them as floating sections, contiguous from `ORG $5055`;
  the five stride-sized records pack to exactly `$5906` (Hare's start).

The records before the chain (`77`→`76`→`70`) abut exactly, and the bonus records
83–87 are gapped (581-byte stride, 325-byte data) and fully independent. The
**bonus (82–87)** and **unused (76/77)** records carve as ordinary rooms
(`bonus/<breed>.json`, `unused/room_unused01/02.asm`).
