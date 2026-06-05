# Graphics loaders — what each raw_gfx sheet is & how it's stitched

Maps the `src/raw_gfx/Data_XX_YYYY` tile sheets to the code that uploads them,
the same way docs/monster_detail_screen.md did for the portraits. Found by
searching `analyzed.asm` for each sheet's raw `ld hl, $YYYY` load correlated with
its bank (scratch/find_loaders3.py) and reading the tile sheets
(scratch/montage_gfx.py). "How it's stitched" = which routine copies it, to which
VRAM address, and (where known) the descriptor/palette that arranges it.

## Sheets with a traced loader

| sheet | tiles | loader | VRAM | what it is | conf |
|---|---|---|---|---|---|
| `Data_10_53b7` | 80 | `Func_10_405f` | `$8300` | **text font** — full upper/lower/digits + words ("TECMO", "QUIT", staff text); a credits/staff screen | high |
| `Data_19_46cb` | 256 | `Func_00_3971` + `Func_13_4061` | `$8800` | **NPC script/dialogue assets**: textbox border, font, the "A" button (for `SCRIPT_WAIT`), and special text tiles (monster names / menu options). The text engine's tile set (docs/text_engine.md) | high |
| `Data_2a_4000` | 96 | `Func_30_59d7` | `$8000` | **font** — uppercase + digits, a results/score screen | high |
| `Data_1b_5c5d` | 384 | `Verde_BuildPortraitScene` / `_BuildIntroScene` | `$8000` | **Verde's portrait** — confirmed in color (girl, orange ponytail, green vest, in a purple shrine hall). BG body via `$1b:$74dd` + face metasprites (`$777c`/`$7789`); BG pals `$1b:$745d`, OBJ pals `$1b:$749d` | high |
| `Data_14_436b` | 128 | `ShowRegeneratedMonster` | `$8000` | regenerated-monster display gfx (Pashute shrine) | high |
| `Data_33_4000` | 384 | `Tradehouse_BuildSceneNoInit` | `$8000` | trade-house scene background | high |
| `Data_0e_5800` | 384 | `Tradehouse_BuildNoteScene` | `$8000` | trade-house "note" scene background | high |
| `Data_32_4613` | 384 | `ShowMonsterDetailScreen` | `$8000` | monster-detail shared UI tiles (docs/monster_detail_screen.md) | high |
| `Data_2a_5410` | 128 | `Func_30_5afa` | `$8000` | logo/emblem tiles (a ® mark is visible) | med |
| `Data_10_40b7` | 128 | `Func_10_4018` | `$9000` | a large illustration / cutscene art | med |
| `Data_24_4000` | 384 | `DrawNextRoomScreen` (`Func_30_487d`) | `$8000` | the **"NEXT ROOM"** inter-floor transition (renders "NEXT ROOM" from the `$24:$5880` window descriptor; shows the floor number from `wActiveFloor`) | high |
| `Data_25_4000` | 384 | `Func_30_48c9` | `$8000` | the in-game **room background** loaded after "NEXT ROOM" (varies by `wRoomType`; `Func_30_4911` is the room-type-1 variant) | high |
| `Data_02_40b1` | 256 | `Func_02_4000` | `$8000` | sprite/object tiles (bank 2) | med |
| `Data_0f_4d38` | 128 | `Func_0f_4b27` | `$8800` | sprite/character tiles | med |
| `Data_3b_4034` | 128 | `Func_3b_4000` | `$9000` | sprite/character tiles | med |
| `Data_11_415c`+ | 20×32 | `LoadFloorMonsterSprite` (`$11:4050`) | bank 1 | **floor-monster sprites** — see the roster below | high |
| `Data_0e_4000` | ~64 | `Func_15_4147` | — | bank-$0e copy (len `$407`, non-tile-aligned) | low |

`$8000`/`$9000` are tile data (BG or sprite — the OAM/attr distinction is
separate); a 384-tile (`$1800`) load to `$8000` is the standard full-screen sheet
(usually paired with a sibling `$5800` sheet + a `$7080`-style CopyBgMap
descriptor, like the screens in docs/gfx_assets.md). `$8800`/`$8300` partial loads
are fonts/overlays patched into an existing layout.

## Pointer-table / paged sheets (no direct address load)

These load via a per-bank function that computes the address from an index/table
(scratch/find_bank_loaders.py), so there's no literal `ld hl, $addr`. Identified
by the loader + the sheet pixels (scratch/montage_unmapped.py):

| sheet | bank / loader | what it is | conf |
|---|---|---|---|
| `Data_16_407f` (800t) | `$16` `Func_16_4016` (table `$16:$4000`, page = `[$c4cc]`) | **paged intro/notice text+gfx**: the GBC-only notice ("…ゲームボーイカラー専用"), ©TECMO, and English credit text | high |
| `Data_17_6918` | `$17` `Func_17_4135` (page = `[$c55c]`) | a **text font page** (clean `ABC…abc…0-9` alphabet) | high |
| `Data_15_624e` | `$15` `Func_15_41fe` → `$8800` (256t) | a full illustration / cutscene image | med |
| `Data_0f_63ce`, `Data_0f_684e` | `$0f` `LoadDiscStoneDisplay` → `$9380` | **disc-stone progress display** (Pashute's shrine; indexed by `wDiscStoneFragments`, drawn via `DiscStoneDisplayMeta`) | high |
| `Data_11_4d5c/5c5c/6b5c/745c` | `$11` | continuation of `FloorMonsterSprites` (see roster) | high |
| `Data_38_501a/5c1a/641a` | `$38` `Func_38_4000` → `$9400` (page `[$c55c]-5`) | room-background **mural/decoration** tiles (poke out behind floor walls); paged alongside the font | med |
| `Data_3d_5bcd`, `Data_3d_67ed` | `$3d` `Func_3d_4000` (3 tables `$406f`/`$4079`/`$4083` indexed by `wActiveFloor`) | **per-floor decoration tiles** — each tower floor's custom graphics (loader left unnamed) | med |
| `Data_1b_645d` | `$1b` | portrait-related (Verde/Pashute bank) | low |
| `Data_27_5ade` | `$27` (in `src/gfx/logo.asm`) | graphics right after the TECMO logo (intro) | med |
| `Data_34_48a8` | `$34` | tiles — loader not yet located | low |
| `Data_32_5613`, `Data_32_5dd3` | `$32` | **analyzer mis-split** — both fall inside the single `$32:$4613` (`$1800`) monster-detail tile load (`ShowMonsterDetailScreen`) | high |
| `Data_3c_68a1` | `$3c` | **analyzer mis-split** — inside the Suezo (`$6800`) range of the monster-portrait tile bank | high |

## Bank-$30 screen loaders (rendered & named)

Each draws a full screen from one contiguous per-bank layout: tiles `$X:$4000`→VRAM
bank 0 `$8000` + `$X:$5800`→bank 1, **palettes `$X:$7000` (8 BG) / `$X:$7040` (8
OBJ)**, then a `$X:$7080` CopyBgMap descriptor → `$9800`. scratch/render_screens.py
renders them **in color** (reading the `$7000` palettes, per docs/palettes.md) with
the palette swatches folded in. All confirmed visually and renamed in source:

| loader | bank | screen |
|---|---|---|
| `DrawTitleScreen` (`$54df`) | `$28` | title — "Monster Rancher EXPLORER ©TECMO LTD 2000" |
| `DrawTownScreen` (`$401e`) | `$20` | the town (fountain + totem) |
| `DrawTowerEntranceScreen` (`$43a4`) | `$22` | tower entrance (door closed) |
| `DrawTowerOpenScreen` (`$52c4`) | `$26` | tower entrance (door open) |
| `DrawRoomStartScreen` (`$44aa`) | `$23` | room start (the vault door) |
| `DrawRoomClearScreen` (`$503b`) | `$21` | "STAGE CLEAR! / SCORE / TIME" results |
| `DrawNextRoomScreen` (`$487d`) | `$24` | "NEXT ROOM" inter-floor transition |
| `DrawIntroBookScreen` (`$577e`) | `$29` | the intro-cutscene open book |

The descriptor-only `Func_30_*` routines (`$463d`, `$46a4`, `$46f1`, `$4712`,
`$4752`, `$4796`, `$47b5`, `$4800`, `$4822`, `$5219`, `$5571`) redraw a sub-region
tilemap over already-loaded tiles (animation/variant states), not new sheets.

## Floor-monster sprites (bank `$11`)

`FloorMonsterSprites` (`$11:$415c`..`$7d5b`) holds the 20 floor-monster species'
sprites — `$300` bytes (32 tiles used, **4×8 column-major**) per species, indexed
by `LoadFloorMonsterSprite` with a `MONSTER` enum value; each has one OBJ palette
in `FloorMonsterSpritePalettes` (`$11:$7d5c`). Rendered roster (scratch/roster11.py),
which matches `include/monster.inc` exactly, **#13 = the enum's `skip` (unused)**:

| # | species | # | species | # | species | # | species |
|---|---|---|---|---|---|---|---|
| 0 | Tacopi | 5 | Henger | 10 | Ducken | 15 | Mocchi |
| 1 | Jell | 6 | Joker | 11 | FlameRed | 16 | Hare |
| 2 | Naga | 7 | Ghost | 12 | FlameBlue | 17 | Gali |
| 3 | Dino | 8 | Puncho | 13 | *(unused)* | 18 | Golem |
| 4 | Plant | 9 | Psylora | 14 | Tiger | 19 | Suezo |

(The blob is fragmented across the `Data_11_*` sheets by the analyzer.)

## TODO

- The bank `$3d`/`$0f` sprite sets: identify which characters/effects they are.
- Confirm bank `$38` is the floor murals (its tilemap arrangement wasn't recovered).
- `Data_34_48a8`: locate its loader. `Data_16_407f`: name `Func_16_4016` once its
  exact role (intro story vs notice vs credits) is pinned down.
- Merge the analyzer mis-splits (`Data_32_5613/5dd3` into `Data_32_4613`,
  `Data_3c_68a1` into the Suezo tile blob) so each gfx is one INCBIN.
- Pull Verde's portrait out as an asset; fix the blink-overlay placement.
- `Data_19_46cb` is the NPC script engine's tile set (border/font/A-button/special
  text); tie it to docs/text_engine.md. `Data_10_53b7` and `Data_2a_4000` are
  other text fonts — first text graphics located, candidates for "font" assets.
