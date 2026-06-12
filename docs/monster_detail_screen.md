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
list. (The palettes were later located: the per-monster `$80`-byte block at
`$0f:$7191 + $80*id` fills BG palettes 4-6 and OBJ palettes 1-2 —
see docs/palettes.md.)

**Asset form (2026-06-12, docs/asset_source_model.md):** each tile set is the
colorized indexed sheet `assets/monster_portrait/monster_<name>/` (BG cells in
their attr palettes, OBJ tiles in OBJ pal 1-2). The 7×7 `bgmap` arrangements
are `assets/monster_portrait/monster_portraits.tmx` — one Tiled layer pair per
monster over its own tileset (open it in Tiled and toggle layers to see each
assembled portrait BG); the maps in src/monster_detail.asm compile from it.
(They happen to be the portrait converter's positional constant — family-G
provenance — but the arrangement is committed as a viewable source file rather
than a constant in tool code.) The `meta1`/`meta2` lists are labelled
`MonsterPortraitMeta_*` records and `MonsterPortraitMetaRecords` is fully
symbolic.

## Name + ability-text regions (BG, bank `$32`)

On the detail screen two more per-monster regions overlay the base tilemap
(`$32:$6313` → `$9800`), both `db rows,cols / dw attr / dw idx` descriptors:

- **Name** — table `$32:$4000[monster]` (7 × 2-byte ptr) → a 6×2 region at `$9827`.
- **Ability blurb** — table `$32:$400e[monster]` → an 18×4 region at `$99a1`.

The 7 monsters (ids 0..6), identified by compositing the BG + sprite layers
(scratch/render_composite.py) — they are exactly the six bonus-room monsters plus
Phoenix:

| # | tiles @ `$3c` | monster | ability blurb |
|---|---|---|---|
| 0 | `$4000` | Tiger | "Enemies vanish!" |
| 1 | `$4800` | Mocchi | "to be invincible!" |
| 2 | `$5000` | Hare | "to double speed!" |
| 3 | `$5800` | Gali | "Stops stage time!" |
| 4 | `$6000` | Golem | "to break blocks!" |
| 5 | `$6800` | Suezo | "See hidden items!" |
| 6 | `$7000` | Phoenix | "Take it along to save your life!" (BG-only, no metasprite) |

(Confirmed in color — scratch/render_color.py. Grayscale had Tiger/Hare swapped:
Tiger is the blue two-horned wolf, Hare the brown big-eared one.)

## Why the portrait is split across BG + sprites

Not animation — the metasprites are static single-frame lists. It's a CGB
**color-depth** technique: each 8×8 tile (BG or OBJ) can only use one 4-color
palette, but BG and OBJ are *independent* palette banks. The body is drawn on BG
using **BG palettes 4–6** and the overlaid detail on sprites using **OBJ palettes
1–2**, so the portrait shows ~16–20 colors at once instead of 4, while keeping the
bulk on BG to stay under the 10-sprites-per-scanline OBJ limit.

## Rendering the full portrait

The complete image is the **`bgmap` BG layer + the `meta1`/`meta2` sprite layers**,
all reading the per-monster `$3c` tiles (uploaded to VRAM `$8800`, so both BG
`$8800` addressing and OBJ tile $80+ index the same tiles). On the detail screen
the `bgmap` is drawn to `$98a3` (`Func_32_4184`) and the sprites at OAM base
`(32, 56)` (`Func_32_4197`/`DrawMetasprite`); BG origin and sprite origin coincide
at screen pixel `(24, 40)`, so the layers align cell-for-pixel.

## Palettes (located)

Per-monster palette data lives in **bank `$0f`**, a `$80`-byte block per monster
at `$7191 + $80*m` (pointer table at `$32:$41f7`). `Func_32_41c1` copies
`block+$20` → BG palettes **4–6** (`$c121`) and `block+$48` → OBJ palettes **1–2**
(`$c149`). The portrait sprites use OBJ palette 1 (attr `$01`); the BG body uses
BG palettes 4–6 per the `bgmap` attr bits. See docs/palettes.md for the general
CGB palette mechanism this revealed (`$c101`/`$c141` WRAM shadow buffers).

## TODO

- **Done — `$3c` tile sets carved, then lifted to the asset model:** the seven
  sheets are colorized indexed PNGs (`assets/monster_portrait/monster_<name>/`),
  the 7×7 `bgmap` arrangements are `monster_portraits.tmx`, and the metasprite
  lists are labelled records — see "Asset form" above. The bank-`$0f` palette
  blocks (`$7191+$80·id`) are still raw data in monster_detail.asm; carving
  them per-asset (like the NPC-portrait palettes) is the remaining piece.
- The id↔name mapping above is from color visual ID; cross-checking
  `wMonsterDiscStones` (Phoenix is index 6, `wMonsterDiscStones+6`) confirms the
  count and Phoenix.
