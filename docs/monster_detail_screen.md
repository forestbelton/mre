# Monster detail / summon screen & the friendly-monster portraits

Where the 7 friendly (summonable, disc-stone) monsters' portraits, names and
ability blurbs live. Two screens use the same data: the disc-stone conversion
preview at Pashute (`ShowMonsterDetailScreen`, bank `$32`, far-called from
`scripts/pashute.asm`) and the pause-menu summon screen (via `Func_0f_4c03`).
The active monster is `[$cfd9]` (loaded from `wActiveMonster`; `$ff` = none).

## The portrait is a metasprite, not a BG tile sheet

`ShowMonsterDetailScreen` uploads **shared** UI/text tiles and a fixed base
tilemap, then `Func_0f_4b62` (bank `$0f`) loads the **per-monster** pieces keyed
by `[$cfd9]`:

- **Portrait tiles** — table `$0f:$4c3d[monster]` → a pointer into **bank `$3c`**;
  128 tiles (`$0800` bytes) copied to VRAM `$8800` (OBJ tile $80+). The 7 sets are
  contiguous: `$3c:$4000, $4800, $5000, $5800, $6000, $6800, $7000`.
- **Metasprite record** — table `$0f:$4c4b[monster]` → a 6-byte record copied to
  `$cf34..$cf39`: `meta1` (`$cf34/35`), `meta2` (`$cf36/37`), `bgmap` (`$cf38/39`).
  - `meta1` is the portrait metasprite (in bank `$0f`, `$77xx`). Format =
    `db count`, then `count`×`[dy, dx, tile, attr]`, drawn by `DrawMetasprite`
    (`$0700` area). **8×16 OBJ** (tile = `tn & $FE` top / `+1` bottom), all
    `attr = $01` (CGB **palette 1**, VRAM bank 0).
  - `meta2` is a second sprite layer present for some monsters (1, 3).
  - `bgmap` is a small `CopyBgMap` region drawn to `$9d41` (`Func_0f_4bec`).

So a portrait = 128 bank-`$3c` tiles arranged by its `meta1` (+`meta2`) sprite
list. Rendering them grayscale (scratch/monster_meta.py) shows recognizable
shapes (monster 5 = Suezo's eye); true colors need the CGB palette (palette 1,
lib-dispatched, not yet located).

## Name + ability-text regions (BG, bank `$32`)

On the detail screen two more per-monster regions overlay the base tilemap
(`$32:$6313` → `$9800`), both `db rows,cols / dw attr / dw idx` descriptors:

- **Name** — table `$32:$4000[monster]` (7 × 2-byte ptr) → a 6×2 region at `$9827`.
- **Ability blurb** — table `$32:$400e[monster]` → an 18×4 region at `$99a1`.

The 7 ability blurbs (rendered, in monster order 0..6):

| # | tiles @ `$3c` | ability blurb |
|---|---|---|
| 0 | `$4000` | "Enemies vanish!" |
| 1 | `$4800` | "to be invincible!" |
| 2 | `$5000` | "to double speed!" |
| 3 | `$5800` | "Stops stage time!" |
| 4 | `$6000` | "to break blocks!" |
| 5 | `$6800` | "See hidden items!" (Suezo) |
| 6 | `$7000` | "Take it along to save your life!" (Phoenix — no metasprite) |

Likely identities (bonus-room monsters Hare/Gali/Golem/Suezo/Tiger/Mocchi +
Phoenix) to be confirmed once the palette is located.

## TODO

- Locate the CGB palette for these (attr palette 1) to render/extract in color.
- Confirm each monster id ↔ name (cross-ref `wMonsterDiscStones` / the summon
  code; Phoenix is index 6, `wMonsterDiscStones+6`).
- Decide an editable representation (metasprite + `$3c` tile set per monster) when
  the sprite/metasprite system is brought under the asset pipeline.
