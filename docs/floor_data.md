# Tower floor data

The tower floors are **stored data, not procedurally generated**. Each floor is a
fixed-size record: a header, two cell grids (collision + visible layout built from
room-piece patterns), and object/entity arrays. This documents the format as
reverse-engineered so far. Confidence is marked: ✅ confirmed from code, 🟡 inferred.

## Lookup chain — floor number → record

`LoadFloorData` (`$00:$16EA`) resolves a floor's record:

```
idx  = GetFloorIndex()                 ; $00:$17A2 — maps the floor to a record index
bank = [FloorBankTable + idx]          ; $1567, one byte per floor
ld [$2fff], bank                       ; map that ROM bank (MBC5 low bank select)
ptr  = [FloorPtrTable + idx*2]         ; $15BF, one LE word per floor
                                        ; record lives at bank:ptr ($4000-$7FFF window)
```

✅ **`FloorBankTable` (`$1567`)** and **`FloorPtrTable` (`$15BF`)** have **88 entries** —
more than the visible floor count, i.e. the **hidden floors**. Banks run `$2D`×27,
`$2E`×27, `$2F`×17, then a `$12` cluster with `$00` gaps — the trailing `$12` block is
where **special/boss floors** live, reached differently (see GetFloorIndex).

🟡 **`GetFloorIndex` (`$17A2`)**: if `[$c2c2] != 0` it takes a separate path
(`$17BD`) — this is the **special/boss-floor** selector. Otherwise it scans the
`$1783` table by `wActiveFloor` (3-byte entries, `$FF`-terminated) and returns the
mapped record index. So the record index is **not** simply `wActiveFloor`; the exact
mapping in `$1783` is not yet fully decoded.

## Record format

Records are **fixed 581-byte slots** (verified: consecutive floors are 581 bytes
apart). `LoadFloorData` reads them sequentially from the record pointer `de`:

| Offset | Size | Destination | Meaning |
|---|---|---|---|
| 0 | 1 | `$cfbd` | 🟡 floor type/theme id (e.g. `$61`/`$62`/`$0a`) |
| 1 | 1 | `$c2ea` | 🟡 start column (spawn X) |
| 2 | 1 | `$c2eb` | 🟡 start row (spawn Y); `$FF` checked as "none" |
| 3 | 1 | `$c2e9` | 🟡 unknown param |
| 4 | 1 | `$c4cc` | 🟡 unknown param |
| 5 | 1 | `$c4cb` | 🟡 unknown param |
| 6 | 1 | `wFloorHeight` (`$c2ed`) | ✅ grid height in cells (≤14) |
| 7 | 1 | `wFloorWidth` (`$c2ec`) | ✅ grid width in cells (≤17) |
| 8 | H×W | `wFloorCollision` (`$c2ef`) | ✅ collision/attribute grid |
| 8+H×W | H×W | `wFloorGrid` (`$c3dd`) | ✅ piece-ID grid — the floor layout |
| … | 4 | `$c4cd` | 🟡 params (floor 0: `00 01 02 0e`) |
| … | 45 | `$c4d1` | 🟡 object/entity slots (5-byte entries, `$FF`=empty) |
| … | 48 | `$c4fe` | 🟡 object/entity slots (`$FF`=empty) |
| … | rest | (read by post-load) | 🟡 remaining entity data, to fill the 581-byte slot |

Both grids are stored **packed at H×W** (the WRAM grids are 17 wide; the loader uses
`wFloorRowStride = $11 - width` to skip the unused right margin). After the fixed
arrays, `LoadFloorData` calls `Func_05_49EF` (bank 5) and `Func_01_572D` (bank 1) to
finish setting up the floor (entity spawn, etc.), then restores the ROM bank.

## The piece-ID grid (`wFloorGrid`)

Each cell is a room-piece ID. The renderer (`DrawFloorPiece`, `$17DE`) looks the ID up
in **`FloorPieceDefs` (`$12FA`)** — 5-byte entries keyed by ID — and stamps a 2×2
metatile to the BG via the `{T, T+8, T+1, T+9}` expansion (`$00:$180B`). Walls are
auto-tiled from neighbours (`Func_01_5BA8`/`5BE2` choose a wall piece per the grid).

Observed cell codes:
- `$00` — floor ✅
- `$20` — wall / border ✅ (perimeter is all `$20`)
- `≥ $40` — 🟡 objects/features (stairs, items, monsters, decorations). Floor 0 has
  `$40 $c0 $d1 $c8` at specific cells; these likely cross-reference the entity arrays
  above. Exact code→object meaning is not yet decoded.

Example — floor record index 0 (`$2D:$4000`, 10×11, header `61 02 07 …`):

```
20 20 20 20 20 20 20 20 20 20 20
20 00 00 00 00 00 00 00 00 00 20
20 00 00 00 00 00 00 00 40 00 20
20 00 00 c0 00 00 00 00 00 00 20
20 00 00 d1 00 00 00 00 00 00 20
20 00 00 00 00 c8 00 00 00 00 20
20 00 00 00 00 00 00 00 00 00 20
20 00 00 00 00 00 00 00 00 00 20
20 00 00 00 00 00 00 00 00 00 20
20 20 20 20 20 20 20 20 20 20 20
```

## Open questions (for a follow-up pass)

- The `$1783` floor→record-index mapping, and the `$c2c2` special/boss path (`$17BD`).
- Header bytes 0/3/4/5 (`$cfbd`/`$c2e9`/`$c4cc`/`$c4cb`).
- The `≥$40` grid cell codes and how they bind to the entity arrays (`$c4d1`/`$c4fe`).
- Tile graphics: the floor tileset is loaded separately (see the `bg{0}` `tiledata`
  the analyzer logs); not part of this record.

## Tooling note

These addresses are named in the disassembly: `LoadFloorData`, `FloorBankTable`,
`FloorPtrTable`, `FloorPieceDefs`, `DrawFloorPiece`, `GetFloorIndex` (map.json
`labels[]`); `wFloorWidth`/`Height`/`RowStride`/`Collision`/`Grid` (wram.inc).
