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
| `Data_11_415c` | ? | `Func_11_4050` | `$8000` | bank-11 tiles (sparse) | low |
| `Data_0e_4000` | ~64 | `Func_15_4147` | — | bank-$0e copy (len `$407`, non-tile-aligned) | low |

`$8000`/`$9000` are tile data (BG or sprite — the OAM/attr distinction is
separate); a 384-tile (`$1800`) load to `$8000` is the standard full-screen sheet
(usually paired with a sibling `$5800` sheet + a `$7080`-style CopyBgMap
descriptor, like the screens in docs/gfx_assets.md). `$8800`/`$8300` partial loads
are fonts/overlays patched into an existing layout.

## Pointer-table / lib-dispatched sheets (no direct address load)

These have no `ld hl, $addr` site — they're fetched through pointer tables / the
CopyBgMap "screen library" dispatch (see the screen-libraries notes), so they're
genuinely data arranged at runtime: `Data_0f_63ce`, `Data_0f_684e`,
`Data_11_4d5c`, `Data_11_5c5c`, `Data_11_6b5c`, `Data_11_745c`, `Data_15_624e`,
`Data_16_407f` (800 tiles — a very large sheet), `Data_17_6918`, `Data_1b_645d`,
`Data_27_5ade`, `Data_32_5613`, `Data_32_5dd3` (both bank $32 → likely more
monster-detail tiles), `Data_34_48a8`, `Data_38_501a/5c1a/641a`, `Data_3c_68a1`
(bank $3c, the monster-portrait tile bank), `Data_3d_5bcd`, `Data_3d_67ed`.

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

## TODO

- Trace the lib-dispatched sheets through their pointer tables.
- Pull Verde's portrait out as an asset; fix the blink-overlay placement.
- `Data_19_46cb` is the NPC script engine's tile set (border/font/A-button/special
  text); tie it to docs/text_engine.md. `Data_10_53b7` and `Data_2a_4000` are
  other text fonts — first text graphics located, candidates for "font" assets.
