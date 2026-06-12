# editor.asm (bank $12) labeling — remaining clusters

Status (2026-06-12): all six clusters from the original list are resolved —
the editor banks are labeled end to end (`make verify` byte-exact throughout).

Done this pass (on top of the earlier SRAM/floor-render/floor-select/
piece-select work):

- **VRAM setup / grid background**: `InitEditorGridBackground`,
  `DrawFloorPreviewMap` (the window minimap, not just borders),
  `PositionEditCursorSprite`, `DrawGridBorders`, `ClearEditorGridMap`,
  `ClearFloorPreviewArea`, `ClassifyFloorCell` (returns the cell's
  collision/piece code; records the spawn cell + `wExitCellX/Y`),
  `DrawFloorCellGlyph`, `DrawFloorPreviewSprites`.
- **Monster placement** (was two misfiled `db` blocks, FAR_CALLed from home
  as `Data_12_4695`): `EditMonsterPlacement` (menu item 0 moves the player
  spawn) + `PlaceOrRemoveMonster` (9-slot `wFloorMonsterTable`, count in
  `wPlacedMonsterCount`, OAM via `PlaceMonsterSpriteAtCursor`).
- **Grid editing**: `EditFloorCell` (A-press dispatch; its misfiled
  monster-collision guard re-disassembled). Interior branch targets stay
  `Func_12_*` per project convention.
- **Menu cursor/tabs**: `SwitchEditorTab(WithSound)`, `SwitchPieceCategory`,
  `MovePieceSelectHighlight`; tables `EditorTabAttrDests/HelpTexts`,
  `PieceCategoryAttrDests/HelpTexts` (help texts are bank-$17 strings).
- **Snapshot/undo**: `ResetFloorSramSlot` (writes the default "ROOMn" name,
  invalidates the record, re-checksums, marks `wRoomSizeState` = 2).
- **Tables**: `RoomDefaultName1-3` ("ROOM1/2/3"), `RoomDefaultNamePtrs`,
  `FloorSramChecksumPtrs/NamePtrs/RecordPtrs` ($a000/$a24f/$a49e slots),
  home `RoomNameBufPtrs` ($12db -> wRoomName1-3).
- **Editor message line** (home): `SetEditorMessage1/2/3`, `ShowEditorError`,
  `Update/AdvanceEditorTicker`, `ShowEditorMessageSticky`; WRAM
  `wEditorMsgPtrs/Index/Count/Timer`. Plus `DrawAsciiText` ($1fa4) and the
  editor WRAM block `wEditorBgBase`, `wRoomName1-3`, `wRoomSizeState`,
  `wFoundMonsterId/Slot`, `wPieceCategory`, `wPlacedMonsterCount`.

## Still raw (low priority)

- `$c55d` (room-select slot/result), `$c55f`/`$c560` (piece-select highlight
  positions), `$c569` (last-placed cell value), `$c570`, `$c7cd-$c7d5`
  (monster property-dialog scratch) — usage known mechanically, semantic
  names deferred until the property dialogs are read.
- The bank-$17 help/error strings are still raw addresses with the string
  quoted in a comment; labeling editor_descriptions.asm would let them link.
