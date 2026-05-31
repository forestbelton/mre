# Tower floor data

The tower floors are **stored data, not procedurally generated**. Each floor is a
fixed 581-byte record: a header, two cell grids (collision + visual/piece layout),
and entity arrays. Confidence is marked ✅ confirmed / 🟡 inferred.

## Lookup chain — floor number → record

The floor index is computed by **`Func_00_16c1`** (called from the dungeon setup
`Func_01_439e`) and depends on the screen **mode** in `$c2c1`:

```
d = wActiveFloor - 1                  ; wActiveFloor ($C2C0) = floor number, 1-based
mode = [$c2c1]
  mode == 0 :  index = d              ; ✅ normal tower floors  (records 0..~70)
  mode == 2 :  index = $46 + d        ; 🟡 a higher block
  mode == 5 :  -> LoadFloorData / GetFloorIndex  ; special/boss floors (see below)
```

Then (`Func_00_16ed`):

```
bank = [FloorBankTable + index]       ; $1567, one byte per floor
ld [$2fff], bank                      ; map that ROM bank
ptr  = [FloorPtrTable + index*2]      ; $15BF, one LE word per floor
                                       ; record at bank:ptr ($4000-$7FFF window)
```

✅ **`FloorBankTable` (`$1567`)** / **`FloorPtrTable` (`$15BF`)** have 88 entries:
records 0–~70 in banks `$2D`/`$2E`/`$2F` (normal floors), and a `$12`-bank tail
(records ~76–87) for the **special/boss floors**.

**Special floors** (mode 5): `GetFloorIndex` (`$17A2`) scans the 6-entry exception
table **`$1783`** — floors **6, 18, 22, 44, 56, 58** remap to records **82–87**
(bank `$12`); anything else defaults to record 82. (`$c2c2 != 0` also routes here.)

So **floor 1 → record 0**, **floor 2 → record 1**, normal floors are
`record = floor − 1`, and the named special floors take the `$1783` path. Verified
against a live `--watch-write` of `$C2C0`/`$C2C1`/`$C2C2`: floor 1 reads
`$C2C0=1, $C2C1=0` → index 0.

## Record format (581-byte slot)

`LoadFloorData`/`Func_00_16ed` parses the record sequentially:

| Offset | Size | Field | Meaning |
|---|---|---|---|
| 0 | 1 | type | 🟡 floor type/theme (`$61` for floor 1) |
| 1 | 1 | spawnX | ✅ player start column |
| 2 | 1 | spawnY | ✅ player start row |
| 3–5 | 3 | params | 🟡 unknown (floor 1: `00 00 01`) |
| 6 | 1 | height | ✅ grid height (≤14) |
| 7 | 1 | width | ✅ grid width (≤17) |
| 8 | H×W | **collision grid** → `wFloorCollision` (`$C2EF`) | room geometry |
| 8+H×W | H×W | **piece grid** → `wFloorGrid` (`$C3DD`) | visual + object markers |
| … | 4 | arr1 → `$C4CD` | 🟡 entity/spawn params |
| … | 45 | arr2 → `$C4D1` | 🟡 entity/monster slots (5-byte-ish entries, `$FF`=empty) |
| … | 48 | arr3 → `$C4FE` | 🟡 more entity slots |

The grids are stored packed at H×W; the WRAM grids are 17 wide, so the loader uses
`wFloorRowStride = $11 − width` to skip the margin. After the arrays, bank-5/bank-1
post-load routines (`Func_05_49EF`, `Func_01_572D`) finish entity setup.

### Collision grid cells
`$20` = outer border · `$21` = wall · `$00` = walkable floor · `$22` = object cell.

### Piece grid cells
`$00` = floor. `≥$40` = an object, classified by `DrawFloorPiece` (`$17DE`) on the
bits: bit 7 → item, bit 6 → exit. Known codes:

| code | object |
|---|---|
| `$40` | EXIT (stairs) |
| `$c0` | KEY |
| `$c8` | BOMB_SMALL |
| `$d1` | COIN_GRAY |

Lower piece IDs index `FloorPieceDefs` (`$12FA`, 5-byte entries) and stamp a 2×2
metatile `{T, T+8, T+1, T+9}` to the BG (`$00:$180B`); walls auto-tile from
neighbours (`Func_01_5BA8`/`5BE2`).

## Worked example — Floor 1 (record 0, `$2D:$4000`, 10×11)

Header: `type=$61  spawn=(col 2,row 7)  10×11`.

```
collision (20 border, 21 wall, 00 walkable, 22 object):
  20 20 20 20 20 20 20 20 20 20 20
  20 21 21 21 21 21 21 21 21 21 20
  20 21 00 00 00 00 00 00 00 21 20
  20 21 00 00 00 00 00 00 21 21 20
  20 21 00 22 00 00 00 22 21 21 20
  20 21 00 00 00 00 22 21 21 21 20
  20 21 00 00 00 22 21 21 21 21 20
  20 21 00 00 21 21 21 21 21 21 20
  20 21 21 21 21 21 21 21 21 21 20
  20 20 20 20 20 20 20 20 20 20 20

objects (from the piece grid):
  col 8,row 2 = $40 EXIT
  col 3,row 3 = $c0 KEY
  col 3,row 4 = $d1 COIN_GRAY
  col 5,row 5 = $c8 BOMB_SMALL
```

The collision grid's diagonal wall mass is the same room geometry as a live VRAM
capture of B1 (orientation differs by scroll). `arr2`'s one live entry
`06 04 22 00 01` (rest `$FF`) is the monster/entity data — see open questions.

## Open questions

- The `arr1`/`arr2`/`arr3` entity format (monster types/positions). `arr2` looks
  like fixed-capacity slots, `$FF`-empty.
- Header params at offsets 3–5; the full object-code table beyond the four above.
- Mode-1 path in `Func_00_16c1`; the post-load routines `Func_05_49EF`/`Func_01_572D`.

## Named in the disassembly

map.json `labels[]`: `FloorBankTable`, `FloorPtrTable`, `FloorPieceDefs`,
`LoadFloorData`, `DrawFloorPiece`, `GetFloorIndex`. wram.inc: `wActiveFloor`,
`wFloorWidth`/`Height`/`RowStride`/`Collision`/`Grid`.
