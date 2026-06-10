# editor.asm (bank $12) labeling — remaining clusters

Status as of this session: **81 of 192 raw `Func_12_*`/`Data_12_*` labels resolved**
(111 remain, ~24 of them `Data_12_*`). Four clusters done and committed, each
byte-exact (`make verify` unchanged):

- SRAM save/load (`SaveGameToSram`, `LoadGameFromSram`, `HasSavedGame`,
  `LoadHiScoreFromSram`, `LoadFloorEditsFromSram`, `SaveFloorToSram`,
  `Backup`/`RestoreFloorRoomMarkers`, `CompareSaveSignature`, `SramSaveSignature`).
- Floor rendering (`DrawFloorPieces`, `RedrawFloorWithSpawns` — named the
  previously-unlabeled `$41a9` —, `ProcessFloorCellMarkers`, `DrawFloorFrame`,
  `DrawFloorBorderTiles`, `UploadBonusRoomTilemaps`).
- Floor-select input loop (`OpenFloorSelectScreen`, `FloorSelectInputLoop`).
- Piece-select menu (`OpenPieceSelectMenu`, `ReenterPieceSelect`,
  `PieceSelectInputLoop`, `Confirm{Play,Load,Save,Reset}Floor`, `ExitPieceSelect`).

Method that worked: verify the Explore structural map against the real code (it
mislabeled several), name functions from external callers, localize jr/jp branch
targets, convert mis-disassembled `Data_12_*` fallthrough code back to
instructions (re-derive jr offsets from the ROM — `make verify` catches errors).

## Remaining clusters (rough priority order)

1. **Editor VRAM setup / grid background** — externally called, self-contained:
   - `Func_12_4798` (home) — InitEditorGridBackground: clears VRAM map, draws all
     cells, calls the spawn detector per cell.
   - `Func_12_47e5` (monster_detail) — DrawPlayerAreaBorders (bonus-stage preview).
   - `Func_12_46d0` (home) — DrawEditCursorOverlay: flashing cursor sprite at
     (wEditCursorX, wEditCursorY).
   - helpers: `Func_12_4941` (DrawGridBorders), `Func_12_49c1` (ClearScreenBanks),
     `Func_12_49df` (ClearStatusAreaBanks), `Func_12_490d` (DetectSpawnPointInCell).

2. **Grid editing state machine** (biggest) — `Func_12_4519` (home, EditFloorCell):
   reads the cursor cell and dispatches on the selected piece/item to place/delete/
   modify pieces. Many internal branch targets ($452d-$4686) to localize; several
   `Data_12_*` in this range are inline code.

3. **Menu-cursor helpers** — `Func_12_43fe` (editor_screens; UpdateMenuCursor),
   `Func_12_44cf` (home; PlayCursorSoundAndHighlight), `Func_12_44d6` (home;
   HighlightMenuEntry). Plus the VRAM-address lookup tables `Data_12_43e6`…`Data_12_44af`.

4. **Bonus-monster display** — `Func_12_484e` (monster_detail; DrawBonusMonsterSprites)
   + `Func_12_4a17` (RenderMonsterGlyph). Iterates an entity array, draws sprites.

5. **Snapshot/undo helper** — `Func_12_4ab8` (left raw deliberately; pairs with the
   `$4a6d`/`$12db` room-marker buffers — copies `$4a61` into both then sets
   `$c7f6+floor=$02`; exact role unconfirmed). Verify before naming.

6. **Loose ends** — `Func_12_4441` (home-called, unidentified); the `Data_12_*`
   string/lookup tables (`Data_12_4a4c` = "ROOM1/2/3" strings, `Data_12_66a4` =
   bonus-room tilemap, already relinked from `UploadBonusRoomTilemaps`).

Re-run the structural map with the Explore agent if needed, but always verify
against code before renaming.
