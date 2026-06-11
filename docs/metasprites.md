# Metasprite format (`DrawMetasprite`)

A **metasprite** is a small, position-independent group of hardware OBJ sprites stored as
a compact list and stamped into the OAM shadow buffer by `DrawMetasprite`
(`src/home.asm`). Portraits, summon scenes, and various screens use it for every animated
OBJ overlay (faces, hands, glows, …). This is the authoritative format reference; the
asset side (turning these lists into editable PNGs) is in
[portrait_overlays.md](portrait_overlays.md), and the regenerator is `gen_meta` in
`tools/pngasset.py`.

## List format

A metasprite list is a 1-byte count followed by that many 4-byte records:

```
list:
    db   N                 ; record count (N = 0 -> draw nothing, returns immediately)
    ; N records, 4 bytes each:
    db   Yoff, Xoff, tile, attr
    ...
```

Each record becomes one hardware OBJ (one OAM entry):

| byte | field  | meaning |
|------|--------|---------|
| 0    | `Yoff` | Y offset from the base position (added, 8-bit wrap) |
| 1    | `Xoff` | X offset from the base position (added, 8-bit wrap) |
| 2    | `tile` | OAM tile index |
| 3    | `attr` | OAM attribute byte |

`attr` is a standard CGB OAM attribute byte:

| bit | meaning |
|-----|---------|
| 0–2 | CGB OBJ palette (`OBP0`–`OBP7` shadow) |
| 3   | tile VRAM bank (0/1) |
| 4   | DMG palette (unused on CGB) |
| 5   | X flip |
| 6   | Y flip |
| 7   | BG/OBJ priority |

**8×16 OBJ mode.** The game runs OBJs in 8×16 mode (`LCDC` bit 2 = 1), so each record is
a vertical 8×16 pair: the hardware draws `tile & $FE` on top and `tile | $01` below.
`tile` is therefore effectively even, and tile allocations step by 2. (`gen_meta` and the
extractor rely on this — see [portrait_overlays.md §4](portrait_overlays.md).)

## `DrawMetasprite` contract

Inputs:

| reg / RAM | meaning |
|-----------|---------|
| `hl`      | pointer to the metasprite list (in bank `wDrawBank`) |
| `b`       | base Y position |
| `c`       | base X position |
| `wDrawBank` | ROM bank holding the list — paged into `$4000–$7fff` via `$2fff` for the copy, restored on return (`Func_00_0c45` is the same code without the bank save/switch, for lists already in the mapped bank) |
| `[$ffa7]` | OAM cursor: low byte of the next free slot in the `$c000` OAM shadow |
| `[$ffa8]` | global Y bias added to every record |
| `[$ffa9]` | global X bias added to every record |

For each record the final OAM entry is:

```
OAM.Y    = Yoff + b   + [$ffa8]      ; all 8-bit, wrapping
OAM.X    = Xoff + c   + [$ffa9]
OAM.tile = tile
OAM.attr = attr
```

Records are **appended** to the OAM shadow at `$c000 + [$ffa7]`, and `[$ffa7]` is advanced
by 4 per record, so successive `DrawMetasprite` calls stack sprites into the same frame.
`hl` is left just past the list.

## Frame lifecycle

The OAM shadow lives at `$c000–$c09f` (40 entries × 4 bytes) and is DMA'd to `$fe00`
every VBlank by the routine `InitOamCopy` installs in HRAM (`hOamCopy`). A frame builds
its sprites like:

1. **`HideAllSprites`** — clears OAM and resets the cursor `[$ffa7]` to `0`.
2. **`DrawMetasprite` × N** — each appends its records, advancing the cursor.
3. **`HideUnusedOamSprites`** — zeroes the shadow from the current cursor to `$a0`
   (clearing last frame's leftovers) and resets `[$ffa7]` to `0` for next frame.
4. OAM DMA copies `$c000` → `$fe00`.

## Worked example

From a Nada portrait frame (`src/text/scripts/nada.asm`):

```asm
ld hl, $762e          ; metasprite list (face_frame1), in bank wDrawBank
ld bc, $1360          ; base Y = $13, base X = $60
call DrawMetasprite
```

`$762e` starts with the record count, then `count` × `[Yoff, Xoff, tile, attr]`. Each
record lands at `($13 + Yoff + [$ffa8], $60 + Xoff + [$ffa9])`.

## Structured source (`include/metasprite.inc`)

Many metasprite lists are still raw `db` blobs, often several packed back-to-back so code
reaches the later ones with raw addresses (`ld hl, $7397`) that can't be made into labels
without splitting the blob. `include/metasprite.inc` turns a list into structured,
labelled source:

```asm
INCLUDE "metasprite.inc"

metasprite CursorSprite        ; CursorSprite: = the count byte; CursorSprite.objs: = first record
    obj  $00, $38, $00, $00
    obj  $00, $60, $00, $20    ; X-flipped (attr bit 5)
.row1:                         ; an ordinary local label -> CursorSprite.row1, a mid-list target
    obj  $10, $38, $02, $00
    obj  $10, $60, $02, $20
end_metasprite CursorSprite    ; CursorSprite.end:
```

- The **count byte is auto-derived** from the record block (`(.end - .objs) / sizeof_MetaspriteObj`),
  so it can never disagree with the records.
- `obj Yoff, Xoff, Tile, Attr` is one record; `struct MetaspriteObj` gives the field
  names / `sizeof`.
- Because the data is now in code, **a raw `ld hl, $xxxx` into the middle of a packed blob
  becomes a label** — split the blob at the boundary and add a `metasprite Name` (or a
  `.local` label) there, then symbolise the reference. This is the main payoff: the
  hidden references between code and sprite data become visible.

## See also
- [portrait_overlays.md](portrait_overlays.md) — the editable-PNG asset model for these
  lists (the `meta` block kind) and the `gen_meta` heuristics. (Asset-managed overlays
  stay as `INCBIN`; the macros are for the raw-`db` lists embedded in code.)
- `tools/pngasset.py` `gen_meta` / `scratch/extract_sprites.py` — regenerate / carve.
