; Save-to-SRAM + the level editor (layout/room_bonus_* / room_unused_* are its room data)
; Carved out of analyzed.asm (byte-exact: section names + placement unchanged).

INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "sound_ids.inc"

SECTION "analyzed_048000", ROMX[$4000], BANK[$12]

ProcessFloorCellMarkers:
	ld e, [hl]
	ld a, $ee
	rst AddAToHL
	ld a, [hl]
	ld d, a
	cp $40
	jr nz, .notExit
	ld a, b
	ld [wSpawnCellY], a
	ld a, c
	ld [wSpawnCellX], a
	ld a, d
	ret

.notExit:
	cp $c0
	jr z, .storeMonster
	cp $80
	jr z, .storeMonster
	jr .return
.storeMonster:
	ld a, b
	ld [wExitCellY], a
	ld a, c
	ld [wExitCellX], a
.return:
	ld a, e
	cp $00
	ret nz
	ld a, d
	ret

DrawFloorPieces:
	ld bc, $0100
	ld hl, wFloorCollision
	ld a, $11
	rst AddAToHL
.next:
	xor a
	cp c
	jr z, .advance
	ld a, [wFloorWidth]
	dec a
	cp c
	jr z, .wrapRow
	jr .cell
.advance:
	inc c
	inc hl
	jr .cell
.wrapRow:
	ld c, $00
	inc b
	ld a, [wFloorRowStride]
	inc a
	rst AddAToHL
	ld a, [wFloorHeight]
	dec a
	cp b
	jr z, .done
	jr .next
.cell:
	push bc
	push hl
	ld a, [hl]
	or a
	jr nz, .skip
	ld a, $ee
	rst AddAToHL
	ld a, [hl]
	bit 7, a
	jr z, .skip
	call DrawFloorPiece
.skip:
	pop hl
	pop bc
	inc c
	inc hl
	jr .next
.done:
	ret

UploadBonusRoomTilemaps:
	call WaitForHBlank
	ld hl, Data_12_66a4
	ld de, $9820
	call CopyBgMap
	call WaitForHBlank
	ld hl, $66ca
	ld de, $983f
	call CopyBgMap
	call WaitForHBlank
	ld hl, $66f0
	ld de, $9a20
	call CopyBgMap
	ret

DrawFloorFrame:
	ld a, [wRoomType]
	cp $02
	jr nz, DrawFloorBorderTiles
	ld a, [wActiveFloor]
	cp $05
	jr nz, DrawFloorBorderTiles
	call UploadBonusRoomTilemaps
	ret

DrawFloorBorderTiles:
	xor a
	ldh [rVBK], a
	ld a, [wFloorHeight]
	dec a
	add a, a
	dec a
	ld e, a
	ld [$d0e7], a
	ld hl, $9801
.left:
	ld a, $1f
	rst AddAToHL
	ld bc, $0001
	ld d, $02
	call FillVram
	dec e
	jr z, .topInit
	ld a, $1f
	rst AddAToHL
	ld bc, $0001
	ld d, $03
	call FillVram
	dec e
	ld a, $1f
	rst AddAToHL
	ld bc, $0001
	ld d, $04
	call FillVram
	dec e
	jr z, .topInit
	ld a, $1f
	rst AddAToHL
	ld bc, $0001
	ld d, $05
	call FillVram
	dec e
	jr .left
.topInit:
	ld a, [wFloorWidth]
	dec a
	add a, a
	dec a
	ld e, a
	ld [$d0e8], a
.top:
	ld bc, $0001
	ld d, $0a
	call FillVram
	dec e
	jr z, .rightInit
	ld bc, $0001
	ld d, $0b
	call FillVram
	dec e
	ld bc, $0001
	ld d, $0c
	call FillVram
	dec e
	jr z, .rightInit
	ld bc, $0001
	ld d, $0d
	call FillVram
	dec e
	jr .top
.rightInit:
	ld a, [$d0e7]
	dec a
	ld e, a
	ld a, [wFloorWidth]
	dec a
	add a, a
	dec a
	ld hl, $9801
	rst AddAToHL
.right:
	ld a, $1f
	rst AddAToHL
	ld bc, $0001
	ld d, $02
	call FillVram
	dec e
	ld a, $1f
	rst AddAToHL
	ld bc, $0001
	ld d, $03
	call FillVram
	dec e
	jr z, .vbank1
	ld a, $1f
	rst AddAToHL
	ld bc, $0001
	ld d, $04
	call FillVram
	dec e
	ld a, $1f
	rst AddAToHL
	ld bc, $0001
	ld d, $05
	call FillVram
	dec e
	jr nz, .right
.vbank1:
	ld a, $01
	ldh [rVBK], a
	ld a, [$d0e7]
	ld e, a
	ld hl, $9801
.vb1a:
	ld a, $1f
	rst AddAToHL
	ld bc, $0001
	ld d, $02
	call FillVram
	dec e
	jr nz, .vb1a
	ld a, [$d0e8]
	ld e, a
.vb1b:
	ld bc, $0001
	ld d, $02
	call FillVram
	dec e
	jr nz, .vb1b
	ld a, [$d0e7]
	dec a
	ld e, a
	ld a, [wFloorWidth]
	dec a
	add a, a
	dec a
	ld hl, $9801
	rst AddAToHL
.vb1c:
	ld a, $1f
	rst AddAToHL
	ld bc, $0001
	ld d, $02
	call FillVram
	dec e
	jr nz, .vb1c
	ret

; Redraw the whole floor grid (used on floor load): walk every cell, run
; ProcessFloorCellMarkers to record exit/monster spawn positions, then stamp each
; piece via DrawFloorPiece. Entry $41a9; called from layout.asm (Func_00_16ad).
RedrawFloorWithSpawns:
	ld bc, $0100
	ld hl, wFloorCollision
	ld a, $11
	rst AddAToHL
.next:
	xor a
	cp c
	jr z, .advance
	ld a, [wFloorWidth]
	dec a
	cp c
	jr z, .wrapRow
	jr .cell
.advance:
	inc c
	inc hl
	jr .cell
.wrapRow:
	ld c, $00
	inc b
	ld a, [wFloorRowStride]
	inc a
	rst AddAToHL
	ld a, [wFloorHeight]
	dec a
	cp b
	jr z, .done
	jr .next
.cell:
	push bc
	push hl
	call ProcessFloorCellMarkers
	bit 7, a
	jr z, .draw
	ld a, $00
.draw:
	call DrawFloorPiece
	pop hl
	pop bc
	inc c
	inc hl
	jr .next
.done:
	ret
; The level editor's room-select screen: choose which editable room to arrange.
; OpenFloorSelectScreen draws it (bank $15) and runs the input loop, which reads
; the d-pad to move the selection in $c55d (inc / dec-with-wrap / toggle the $04
; column bit), plays cursor blips, and on A confirms while B picks option 4
; (exit). Confirming stores wActiveFloor and returns 1 (>= 4) or 0. From home.asm.
OpenFloorSelectScreen:
	FAR_CALL DrawRoomSelectScreen
	call FloorSelectInputLoop
	ret
FloorSelectInputLoop:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyPressed]
	ld b, a
	ld a, [$c55d]
	bit 4, b
	jr z, .decSel
	cp $04
	jr nc, FloorSelectInputLoop
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	inc a
	cp $03
	jr nz, .apply
	xor a                      ; wrapped past 3 -> 0
	jr .apply
.decSel:
	bit 5, b
	jr z, .toggleColA
	cp $04
	jr nc, FloorSelectInputLoop
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	dec a
	cp $80
	jr c, .apply
	ld a, $02                  ; wrapped below 0 -> 2
	jr .apply
.toggleColA:
	bit 7, b
	jr z, .toggleColB
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	xor $04
	jr .apply
.toggleColB:
	bit 6, b
	jr z, .pressA
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	xor $04
	jr .apply
.pressA:
	bit 0, b
	jr z, .pressB
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	jr .confirm
.pressB:
	ld a, [$cfbe]
	or a
	jr nz, FloorSelectInputLoop
	bit 1, b
	jp z, FloorSelectInputLoop
	push af
	ld a, SOUND_SFX_Cancel
	call PlaySound
	pop af
	ld a, $04
	jr .confirm            ; B = select option 4 (exit)
.apply:
	ld [$c55d], a
	FAR_CALL Func_15_408a
	FAR_CALL Func_15_41cf
	jp FloorSelectInputLoop
.confirm:
	cp $04
	jr c, .confirmZero
	ld [wActiveFloor], a
	ld a, $01
	ret
.confirmZero:
	ld [wActiveFloor], a
	xor a
	ret
; The editor's piece/option menu (entered after a room is chosen). The input loop
; moves a cursor over the menu (wMenuId in $c55e), and A dispatches the selected
; option, B exits: option 0 ConfirmPlayFloor, 1 ConfirmLoadFloor,
; 2 ConfirmSaveFloor, 3 ConfirmResetFloor (purposes inferred from each handler's
; wRoomType / SRAM actions). ReenterPieceSelect redraws + re-enters after a sub-
; action. Called from home.asm.
OpenPieceSelectMenu:
	xor a
	ld [wPieceCategory], a
ReenterPieceSelect:
	FAR_CALL Func_15_410f
PieceSelectInputLoop:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyPressed]
	ld b, a
	ld a, [wPieceCategory]
	call Func_00_32ae
	bit 4, b
	jr z, .toggleColAlt
	cp $04
	jr nc, PieceSelectInputLoop
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	xor $01
	jr .apply
.toggleColAlt:
	bit 5, b
	jr z, .rowInc
	cp $04
	jr nc, PieceSelectInputLoop
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	xor $01
	jr .apply
.rowInc:
	bit 7, b
	jr z, .rowDec
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	add a, $02
	cp $06
	jr c, .apply
	and $01                    ; wrapped past 5 -> low bit
	jr .apply
.rowDec:
	bit 6, b
	jr z, .pressA
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	sub $02
	cp $80
	jr c, .apply
	and $05                    ; wrapped below 0
	jr .apply
.pressA:
	bit 0, b
	jr z, .pressB
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	jr .dispatch
.pressB:
	bit 1, b
	jr z, .cancel
	push af
	ld a, SOUND_SFX_Cancel
	call PlaySound
	pop af
	ld a, $04
	jr .dispatch            ; B = dispatch option 4 (exit)
.apply:
	ld c, a
	call SwitchPieceCategory
	jp PieceSelectInputLoop
.cancel:
	call UpdateEditorTicker
	jp PieceSelectInputLoop
.dispatch:
	cp $00
	jr z, ConfirmPlayFloor
	cp $01
	jr z, ConfirmLoadFloor
	cp $02
	jr z, ConfirmSaveFloor
	cp $03
	jp z, ConfirmResetFloor
	jp ExitPieceSelect
ConfirmPlayFloor:
	call Func_00_212c
	ld a, [$c55f]
	cp $02
	jr c, .play
	jp ReenterPieceSelect            ; invalid -> back to the menu
.play:
	ld a, $05
	ld [wRoomType], a
	call LoadFloorByMode
	FAR_CALL Func_10_4041
	FAR_CALL LoadAllFloorMonsterSprites
	call InitFloorEditorState
	xor a
	ret

ConfirmLoadFloor:
	call Func_00_217d
	or a
	jp nz, ReenterPieceSelect
	FAR_CALL ResetFloorSramSlot
	jp ReenterPieceSelect
ConfirmSaveFloor:
	ld a, $04
	ld [wRoomType], a
	call LoadCurrentFloorRecordToBuffer
	call Func_00_2fa2
	jr z, .launch
	ld hl, $5230
	call ShowEditorError
	jp PieceSelectInputLoop
.launch:
	ld a, $05
	ld [wRoomType], a
	FAR_CALL SetupNewRun
	FAR_CALL EnterRoomStartScene
	FAR_CALL Func_01_439e
	call ResetScrollState
	call LoadFloorByMode
	FAR_CALL Func_10_4041
	FAR_CALL LoadAllFloorMonsterSprites
	FAR_CALL Func_15_41fe
	FAR_CALL Func_15_4134
	push af
	ld a, SOUND_BGM_Bodka
	call PlaySoundTracked
	pop af
	jp ReenterPieceSelect

ConfirmResetFloor:
	call Func_00_2223
	jp ReenterPieceSelect
ExitPieceSelect:
	ld a, $01
	ret

; Piece-category tabs (wPieceCategory 0-5): BG-attr address of each tab's
; label (highlighted via Func_00_31c4/31d5) and its bank-$17 help text
; (shown in the message line on switch).
PieceCategoryAttrDests:
	dw $98e1, $98eb, $9921, $992b, $9965, $9965
PieceCategoryHelpTexts:
	dw $47c8, $4810, $4858, $48a0, $48e8, $48e8

SwitchPieceCategory:
	ld e, c
	ld a, $01
	ldh [rVBK], a
	ld a, [wPieceCategory]
	cp $04
	jr nc, Func_12_440e
	ld b, $08
	jr Func_12_4410

Func_12_440e:
	ld b, $0a

Func_12_4410:
	add a, a
	ld hl, PieceCategoryAttrDests
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call Func_00_31c4
	ld a, e
	cp $04
	jr nc, Func_12_4424
	ld b, $08
	jr Func_12_4426
Func_12_4424:
	ld b, $0a
Func_12_4426:
	add a, a
	ld hl, PieceCategoryAttrDests
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call Func_00_31d5
	ld a, e
	ld [wPieceCategory], a
	add a, a
	ld hl, PieceCategoryHelpTexts
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call SetEditorMessage1
	ret
MovePieceSelectHighlight:
	push bc
	FAR_CALL Func_15_4147
	ld a, $01
	ldh [rVBK], a
	ld a, [$c55f]
	ld hl, $9847
	ld c, $01
	rst AddAToHL
	ld d, $f8
	call Func_00_31fa
	ld a, [$c560]
	cp $20
	jr nc, Func_12_4477
	cp $10
	jr nc, Func_12_446e
	ld hl, $9902
	ld c, $01
	jr Func_12_447e
Func_12_446e:
	sub $10
	ld hl, $9942
	ld c, $01
	jr Func_12_447e
Func_12_4477:
	and $0c
	ld hl, $9982
	ld c, $04
Func_12_447e:
	rst AddAToHL
	ld d, $06
	call Func_00_31e6
	pop bc
	ld a, b
	ld [$c560], a
	cp $20
	jr nc, Func_12_44a1
	cp $10
	jr nc, Func_12_4498
	ld hl, $9902
	ld c, $01
	jr Func_12_44a8
Func_12_4498:
	sub $10
	ld hl, $9942
	ld c, $01
	jr Func_12_44a8
Func_12_44a1:
	and $0c
	ld hl, $9982
	ld c, $04
Func_12_44a8:
	rst AddAToHL
	ld d, $f8
	call Func_00_31fa
	ret

; Top-level editor tabs (wMenuId 0-7): BG-attr address of each tab's label
; and its bank-$17 help text.
EditorTabAttrDests:
	dw $9841, $984b, $98a1, $98ab, $9901, $990b, $9965, $9965
EditorTabHelpTexts:
	dw $49c0, $4a08, $4a50, $4a98, $4ae0, $4b28, $4b70, $4b70

SwitchEditorTabWithSound:
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
SwitchEditorTab:
	ld e, b
	ld a, $01
	ldh [rVBK], a
	ld a, [wMenuId]
	cp $06
	jr nc, Func_12_44e6
	ld b, $08
	jr Func_12_44e8
Func_12_44e6:
	ld b, $0a
Func_12_44e8:
	add a, a
	ld hl, EditorTabAttrDests
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call Func_00_31c4
	ld a, e
	cp $06
	jr nc, Func_12_44fc
	ld b, $08
	jr Func_12_44fe
Func_12_44fc:
	ld b, $0a
Func_12_44fe:
	add a, a
	ld hl, EditorTabAttrDests
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call Func_00_31d5
	ld a, e
	ld [wMenuId], a
	add a, a
	ld hl, EditorTabHelpTexts
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call SetEditorMessage1
	ret
; A-press handler for the piece-placement menus (wMenuId != 3, dispatched
; from the home edit loop at $00:$1f14): place/erase/modify the piece under
; the edit cursor per the selected menu item (wMenuItemValue).
EditFloorCell:
	call FindMonsterAtCursor
	jr z, Func_12_452d

	; Code, was misfiled as data -- LIVE: a monster occupies the cursor
	; cell; placing piece $21/$22/$42 on it is refused.
	ld a, [wMenuItemValue]
	cp $21
	jr z, Func_12_4541
	cp $22
	jr z, Func_12_4541
	cp $42
	jr z, Func_12_4541

Func_12_452d:
	ld a, [wEditCursorY]
	ld b, a
	ld a, [wEditCursorX]
	ld c, a
	ld a, [wFloorPlayerY]
	cp b
	jr nz, Func_12_4548

Func_12_453b:
	ld a, [wFloorPlayerX]
	cp c
	jr nz, Func_12_4548
Func_12_4541:
	ld hl, $4ff0 ; bank-$17 text: cannot edit this cell
	call ShowEditorError
	ret

Func_12_4548:
	call ReadFloorCell
	ld a, c
	ld hl, wFloorCollision
	rst AddAToHL
	ld a, c
	ld de, wFloorGrid
	rst AddAToDE
	ldh a, [$ffac]
	bit 7, a
	jr z, Func_12_455f
	set 6, a
	ldh [$ffac], a
Func_12_455f:
	ld a, [wMenuItemValue]
	ld c, a
	bit 7, c
	jr nz, Func_12_45c3
	bit 6, c
	jp z, Func_12_4631
	ldh a, [$ffac]
	cp c
	jr nz, Func_12_4584
	xor a
	ld [de], a
	ld [hl], a
	ld [$c569], a
	push af
	ld a, SOUND_SFX_03
	call PlaySound
	pop af
	call Func_00_2ea8
	jp Func_12_4686

Func_12_4584:
	ld a, c
	cp $42
	jr nz, Func_12_4597
	ld a, [$c570]
	cp $04
	jr nz, Func_12_4597
	ld hl, $50c8
	call ShowEditorError
	ret

Func_12_4597:
	ld a, c
	ld [de], a
	ld [$c569], a
	push de
	push hl
	call Func_00_2f04
	pop hl
	pop de
	push af
	ld a, SOUND_SFX_01
	call PlaySound
	pop af
	xor a
	ld [hl], a
	ldh a, [$ffac]
	bit 7, a
	jr z, Func_12_45bd
	cp $c0
	call z, ClearCollisionCell
	call RemoveCursorCellFromList
	jp Func_12_4686

Func_12_45bd:
	call Func_00_2ea8
	jp Func_12_4686
Func_12_45c3:
	ldh a, [$ffac]
	cp $c0
	call z, ClearCollisionCell
	ldh a, [$ffac]
	cp c
	jr nz, Func_12_45e3

Data_12_45cf:
	xor a
	ld [de], a
	ldh a, [$ffab]
	ld [$c569], a
	call RemoveCursorCellFromList
	push af
	ld a, SOUND_SFX_03
	call PlaySound
	pop af
	jp Func_12_4686

Func_12_45e3:
	bit 7, a
	jr nz, Func_12_461e
	ld a, [$c56f]
	cp $0a
	jr nz, Func_12_45fa
	ld a, $01
	ld [$c585], a
	ld hl, $5110
	call ShowEditorError
	ret
Func_12_45fa:
	ld a, c
	cp $c0
	call z, Func_00_2f65
	ld a, [wMenuItemValue]
	ld [de], a
	ld [$c569], a
	push af
	ld a, SOUND_SFX_01
	call PlaySound
	pop af
	ldh a, [$ffab]
	cp $21
	jr nz, Func_12_4616
	xor a
	ld [hl], a
Func_12_4616:
	call Func_00_2e42
	call Func_00_2ea8
	jr Func_12_4686

Func_12_461e:
	ld a, c
	ld [de], a
	ld [$c569], a
	cp $c0
	call z, Func_00_2f65
	push af
	ld a, SOUND_SFX_01
	call PlaySound
	pop af
	jr Func_12_4686

Func_12_4631:
	ldh a, [$ffab]
	cp c
	jr nz, Func_12_4646

Data_12_4636:
	xor a
	ld [hl], a
	ldh a, [$ffac]
	ld [$c569], a
	push af
	ld a, SOUND_SFX_03
	call PlaySound
	pop af
	jr Func_12_4686

Func_12_4646:
	ld a, c
	ld [hl], a
	ld [$c569], a
	cp $21
	jr z, Func_12_465e
	ldh a, [$ffac]
	bit 7, a
	jr z, Func_12_467a
	push af
	ld a, SOUND_SFX_01
	call PlaySound
	pop af
	jr Func_12_4686
Func_12_465e:
	xor a
	ld [de], a
	push af
	ld a, SOUND_SFX_01
	call PlaySound
	pop af
	call Func_00_2ea8
	ldh a, [$ffac]
	bit 7, a
	jr z, Func_12_4686
	cp $c0
	call z, ClearCollisionCell
	call RemoveCursorCellFromList
	jr Func_12_4686

Func_12_467a:
	xor a
	ld [de], a
	push af
	ld a, SOUND_SFX_01
	call PlaySound
	pop af
	call Func_00_2ea8
Func_12_4686:
	ld a, [wEditCursorX]
	ld c, a
	ld a, [wEditCursorY]
	ld b, a
	ld a, [$c569]
	call Func_00_1f71
	ret

; Code, was misfiled as data. A-press handler for the monster-placement menu
; (wMenuId 3; FAR_CALLed from the home edit loop at $00:$1f1e). Menu item 0 =
; move the player spawn to the cursor; other items = place/remove that
; monster (PlaceOrRemoveMonster).
EditMonsterPlacement:
	ld a, [wMenuCursor]
	cp $00
	jr nz, PlaceOrRemoveMonster
	call FindMonsterAtCursor
	jr z, Func_12_46a8
Func_12_46a1:
	ld hl, $51a0 ; bank-$17 text: "Cannot place a ..."
	call ShowEditorError
	ret
Func_12_46a8:
	ld a, [wEditCursorY]
	ld b, a
	ld a, [wEditCursorX]
	ld c, a
	call ReadFloorCell
	cp $00
	jr nz, Func_12_46a1
	ldh a, [$ffac]
	cp $00
	jr nz, Func_12_46a1
	push af
	ld a, $01
	call PlaySound
	pop af
	ld a, [wEditCursorY]
	ld [wFloorPlayerY], a
	ld a, [wEditCursorX]
	ld [wFloorPlayerX], a
	; fall through: park the edit-cursor sprite on the new spawn

PositionEditCursorSprite:
	ld a, [wEditCursorY]
	add a, a
	add a, a
	add a, a
	add a, $10
	ld b, a
	ld a, [wEditCursorX]
	add a, a
	add a, a
	add a, a
	add a, $08
	ld c, a
	ld a, $0f
	call SetSpritePosition
	ret

; Code, was misfiled as data. Place monster #(wMenuCursor-1) at the cursor
; cell, or remove it if that same monster already sits there. Placements go
; in wFloorMonsterTable (9 slots x 5 bytes: x, y, $22, 0, monster), counted
; in wPlacedMonsterCount; the sprite is managed via PlaceMonsterSpriteAtCursor.
PlaceOrRemoveMonster:
	ld a, [wEditCursorY]
	ld b, a
	ld a, [wEditCursorX]
	ld c, a
	ld a, [wFloorPlayerY]
	cp b
	jr nz, Func_12_4703
	ld a, [wFloorPlayerX]
	cp c
	jr nz, Func_12_4703
	; cursor is on the player spawn: refuse
Func_12_46fc:
	ld hl, $5158 ; bank-$17 text: "Cannot place a ..."
	call ShowEditorError
	ret
Func_12_4703:
	ld a, [wMenuCursor]
	dec a
	ld e, a
	call ReadFloorCell
	cp $00
	jr nz, Func_12_4715
	ldh a, [$ffac]
	cp $42
	jr nz, Func_12_471c
Func_12_4715:
	ld hl, $5158 ; bank-$17 text: "Cannot place a ..."
	call ShowEditorError
	ret
Func_12_471c:
	call FindMonsterAtCursor
	jr z, Func_12_472d
	; a monster is here: same one -> remove it, different -> replace in-place
	ld a, [wFoundMonsterId]
	cp e
	jr z, Func_12_4758
	dec hl
	dec hl
	dec hl
	dec hl
	jr Func_12_477f
Func_12_472d:
	ld a, [wPlacedMonsterCount]
	cp $09
	jr nz, Func_12_473b
	ld hl, $5080 ; bank-$17 text: "Can't place any ..."
	call ShowEditorError
	ret
Func_12_473b:
	; find a free ($ff) slot in the 9-entry table
	ld hl, wFloorMonsterTable
	ld c, $00
Func_12_4740:
	ld a, [hl]
	cp $ff
	jr z, Func_12_4778
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	inc c
	ld a, $09
	cp c
	jr nz, Func_12_4740
	push af
	ld a, $02
	call PlaySound
	pop af
	ret
Func_12_4758:
	; remove: free the slot ($ff x5), hide its OAM sprite (y = $f0)
	ld a, [wPlacedMonsterCount]
	dec a
	ld [wPlacedMonsterCount], a
	ld a, $ff
	ld [hl-], a
	ld [hl-], a
	ld [hl-], a
	ld [hl-], a
	ld [hl], a
	ld d, $f0
	ld a, c
	add a, $10
	ld c, $00
	call SetOamByte
	push af
	ld a, $03
	call PlaySound
	pop af
	ret
Func_12_4778:
	ld a, [wPlacedMonsterCount]
	inc a
	ld [wPlacedMonsterCount], a
Func_12_477f:
	; write the 5-byte entry: x, y, $22, $00, monster id
	ld a, [wEditCursorX]
	ld [hl+], a
	ld a, [wEditCursorY]
	ld [hl+], a
	ld a, $22
	ld [hl+], a
	xor a
	ld [hl+], a
	ld [hl], e
	call PlaceMonsterSpriteAtCursor
	push af
	ld a, $01
	call PlaySound
	pop af
	ret

InitEditorGridBackground:
	call ClearEditorGridMap
	ld a, $00
	ld [wEditorBgBase], a
	ld a, $98
	ld [wEditorBgBase+1], a
	call DrawGridBorders
	call ClearEditCellList
	ld bc, $0100
	ld hl, wFloorCollision
	ld a, $11
	rst AddAToHL
Func_12_47b4:
	xor a
	cp c
	jr z, Func_12_47c1
	ld a, [wFloorWidth]
	dec a
	cp c
	jr z, Func_12_47c5
	jr Func_12_47d6
Func_12_47c1:
	inc c
	inc hl
	jr Func_12_47d6
Func_12_47c5:
	ld c, $00
	inc b
	ld a, [wFloorRowStride]
	inc a
	rst AddAToHL
	ld a, [wFloorHeight]
	dec a
	cp b
	jr z, Func_12_47e4
	jr Func_12_47b4
Func_12_47d6:
	push bc
	push hl
	call ClassifyFloorCell
	call Func_00_1f71
	pop hl
	pop bc
	inc c
	inc hl
	jr Func_12_47b4
Func_12_47e4:
	ret
DrawFloorPreviewMap:
	call ClearFloorPreviewArea
	ld a, [wRoomType]
	cp $02
	ret z
	cp $06
	ret z
	ld a, [wFloorWidth]
	cp $11
	jr z, Func_12_4804
	ld a, $44
	ld [wEditorBgBase], a
	ld a, $9c
	ld [wEditorBgBase+1], a
	jr Func_12_480e
Func_12_4804:
	ld a, $01
	ld [wEditorBgBase], a
	ld a, $9c
	ld [wEditorBgBase+1], a
Func_12_480e:
	call DrawGridBorders
	call ClearEditCellList
	ld bc, $0100
	ld hl, wFloorCollision
	ld a, $11
	rst AddAToHL
Func_12_481d:
	xor a
	cp c
	jr z, Func_12_482a
	ld a, [wFloorWidth]
	dec a
	cp c
	jr z, Func_12_482e
	jr Func_12_483f
Func_12_482a:
	inc c
	inc hl
	jr Func_12_483f
Func_12_482e:
	ld c, $00
	inc b
	ld a, [wFloorRowStride]
	inc a
	rst AddAToHL
	ld a, [wFloorHeight]
	dec a
	cp b
	jr z, Func_12_484d
	jr Func_12_481d
Func_12_483f:
	push bc
	push hl
	call ClassifyFloorCell
	call DrawFloorCellGlyph
	pop hl
	pop bc
	inc c
	inc hl
	jr Func_12_481d
Func_12_484d:
	ret
DrawFloorPreviewSprites:
	ld hl, $18ce
	ld bc, $0000
	call DrawMetasprite
	ld a, [wFloorWidth]
	cp $11
	jr z, Func_12_4863
	ld de, $2028
	jr Func_12_4866
Func_12_4863:
	ld de, $1010
Func_12_4866:
	ld hl, wPlayer
	xor a
	ld [$d0e7], a
	ld [$d0e8], a
Func_12_4870:
	ld a, [$d0e7]
	inc a
	ld [$d0e7], a
	cp $1c
	ret z
	ld a, [hl]
	cp $01
	jr z, Func_12_488e
	and $f0
	cp $30
	jr z, Func_12_48aa
	cp $40
	jr z, Func_12_48aa
	ld a, $2a
	rst AddAToHL
	jr Func_12_4870
Func_12_488e:
	ld a, $0c
	rst AddAToHL
	ld a, [hl+]
	srl a
	add a, e
	ld c, a
	inc hl
	ld a, [hl+]
	sub $07
	srl a
	add a, d
	ld b, a
	ld a, $00
	push hl
	call SetSpritePosition
	pop hl
	ld a, $1b
	rst AddAToHL
	jr Func_12_4870
Func_12_48aa:
	ld a, [hl]
	push af
	call ClassifyEntityType
	bit 6, a
	jr nz, Func_12_48c5
	ld a, $0c
	rst AddAToHL
	ld a, [hl+]
	srl a
	add a, e
	ld c, a
	inc hl
	ld a, [hl+]
	sub $07
	srl a
	add a, d
	ld b, a
	jr Func_12_48d3
Func_12_48c5:
	ld a, $0c
	rst AddAToHL
	ld a, [hl+]
	srl a
	add a, e
	ld c, a
	inc hl
	ld a, [hl+]
	srl a
	add a, d
	ld b, a
Func_12_48d3:
	ld a, [$d0e8]
	inc a
	ld [$d0e8], a
	push hl
	call SetSpritePosition
	pop hl
	pop af
	push hl
	push de
	sub $30
	cp $10
	jr c, Func_12_48ea

	; Code, was misfiled as data -- LIVE: entity codes $40+ fall through
	; here and shift down by 2 before the species lookup.
	sub $02

Func_12_48ea:
	ld d, a
	add a, a
	add a, $32
	ld b, a
	ld c, $00
	ld hl, wFloorMonsterSpecies
Func_12_48f4:
	ld a, [hl+]
	cp d
	jr z, Func_12_48fb
	inc c
	jr Func_12_48f4
Func_12_48fb:
	ld a, $04
	add a, c
	ld c, a
	ld a, [$d0e8]
	call SetSpriteTileAttr
	pop de
	pop hl
	ld a, $1b
	rst AddAToHL
	jp Func_12_4870
ClassifyFloorCell:
	ld e, [hl]
	ld a, $ee
	rst AddAToHL
	ld a, [hl]
	ld d, a
	cp $40
	jr nz, Func_12_4921
	ld a, b
	ld [wSpawnCellY], a
	ld a, c
	ld [wSpawnCellX], a
	ld a, d
	ret
Func_12_4921:
	bit 7, a
	jr z, Func_12_493b
	call Func_00_2e94
	ld a, d
	cp $c0
	jr z, Func_12_4933
	cp $80
	jr z, Func_12_4933
	jr Func_12_493b
Func_12_4933:
	ld a, b
	ld [wExitCellY], a
	ld a, c
	ld [wExitCellX], a
Func_12_493b:
	ld a, e
	cp $00
	ret nz
	ld a, d
	ret
DrawGridBorders:
	ld a, [wEditorBgBase]
	ld l, a
	ld a, [wEditorBgBase+1]
	ld h, a
	inc hl
	push hl
	ld a, [wFloorHeight]
	dec a
	dec a
	ld e, a
	ld [$d0e7], a
	ld b, $06
	ld d, $53
Func_12_4958:
	call WaitForHBlank
	ld a, $1f
	rst AddAToHL
	xor a
	ldh [rVBK], a
	ld [hl], d
	ld a, $01
	ldh [rVBK], a
	ld a, b
	ld [hl+], a
	dec e
	jr nz, Func_12_4958
	ld d, $54
	call WaitForHBlank
	ld a, $1f
	rst AddAToHL
	xor a
	ldh [rVBK], a
	ld [hl], d
	ld a, $01
	ldh [rVBK], a
	ld a, b
	ld [hl+], a
	ld a, [wFloorWidth]
	dec a
	dec a
	ld e, a
	ld d, $55
Func_12_4985:
	call WaitForHBlank
	xor a
	ldh [rVBK], a
	ld [hl], d
	ld a, $01
	ldh [rVBK], a
	ld a, b
	ld [hl+], a
	dec e
	jr nz, Func_12_4985
	xor a
	ldh [rVBK], a
	ld d, $52
	ld [hl], d
	ld a, $01
	ldh [rVBK], a
	ld a, b
	ld [hl+], a
	ld a, [$d0e7]
	ld e, a
	ld a, [wFloorWidth]
	dec a
	pop hl
	rst AddAToHL
	ld d, $51
Func_12_49ad:
	call WaitForHBlank
	ld a, $1f
	rst AddAToHL
	xor a
	ldh [rVBK], a
	ld [hl], d
	ld a, $01
	ldh [rVBK], a
	ld a, b
	ld [hl+], a
	dec e
	jr nz, Func_12_49ad
	ret
ClearEditorGridMap:
	xor a
	ldh [rVBK], a
	ld hl, $9800
	ld bc, $01c0
	ld d, $ff
	call FillVram
	ld a, $01
	ldh [rVBK], a
	ld hl, $9800
	ld bc, $01c0
	ld d, $0e
	call FillVram
	ret
ClearFloorPreviewArea:
	xor a
	ldh [rVBK], a
	ld c, $0d
	ld hl, $9c1f
Func_12_49e7:
	push bc
	push hl
	ld bc, $0015
	ld d, $ff
	call FillVram
	pop hl
	pop bc
	ld de, $0020
	add hl, de
	dec c
	jr nz, Func_12_49e7
	ld a, $01
	ldh [rVBK], a
	ld c, $0d
	ld hl, $9c1f
Func_12_4a03:
	push bc
	push hl
	ld bc, $0015
	ld d, $0e
	call FillVram
	pop hl
	pop bc
	ld de, $0020
	add hl, de
	dec c
	jr nz, Func_12_4a03
	ret
DrawFloorCellGlyph:
	bit 7, a
	jr z, Func_12_4a22
	bit 6, a
	jr nz, Func_12_4a27
	xor a
	jr Func_12_4a27
Func_12_4a22:
	bit 4, a
	jr z, Func_12_4a27
	xor a
Func_12_4a27:
	ld h, a
	ld de, $12fa
Func_12_4a2b:
	ld a, [de]
	cp h
	jr z, Func_12_4a38
	cp $ff
	jr z, Func_12_4a4b
	ld a, $05
	rst AddAToDE
	jr Func_12_4a2b
Func_12_4a38:
	ld a, [wEditorBgBase]
	ld l, a
	ld a, [wEditorBgBase+1]
	ld h, a
Func_12_4a40:
	ld a, $20
	rst AddAToHL
	dec b
	jr nz, Func_12_4a40
	ld a, c
	rst AddAToHL
	call SetBgMapTileAndAttr
Func_12_4a4b:
	ret

; Default room names (ASCII, drawn by DrawAsciiText). The trailing byte of
; each 7-byte name slot is a linker pad $00 (sections split around it).
RoomDefaultName1:
	db "ROOM1", 0

SECTION "analyzed_048a53", ROMX[$4a53], BANK[$12]

RoomDefaultName2:
	db "ROOM2", 0

SECTION "analyzed_048a5a", ROMX[$4a5a], BANK[$12]

RoomDefaultName3:
	db "ROOM3", 0

SECTION "analyzed_048a61", ROMX[$4a61], BANK[$12]

; Per-editor-room (0-2) parallel pointer tables. Each room's SRAM slot is
; [checksum byte][6-byte name][$245-byte floor record] at $a000/$a24f/$a49e.
RoomDefaultNamePtrs:
	dw RoomDefaultName1, RoomDefaultName2, RoomDefaultName3
FloorSramChecksumPtrs:
	dw $a000, $a24f, $a49e
FloorSramNamePtrs:
	dw $a003, $a252, $a4a1
FloorSramRecordPtrs:
	dw $a009, $a258, $a4a7

; Write the active floor's edited record (wFloorSnapshot) into its SRAM slot
; ($4a73 table) + checksum ($4a67 table), and store its height marker in
; $c7f6+floor. Called from home.asm when committing a floor edit.
SaveFloorToSram:
	call EnableSram
	ld a, [wActiveFloor]
	add a, a
	ld hl, FloorSramRecordPtrs
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, $0245
	ld de, wFloorSnapshot
	call CopyDEtoHLLong
	ld a, [wActiveFloor]
	add a, a
	ld hl, FloorSramChecksumPtrs
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, $024e
	call WriteXorChecksum
	call DisableSram
	ld a, [wActiveFloor]
	ld hl, wRoomSizeState
	rst AddAToHL
	ld a, [wFloorHeight]
	cp $0e
	jr nz, .notFullHeight
	ld [hl], $00
	ret

.notFullHeight:
	ld [hl], $01
	ret
ResetFloorSramSlot:
	call EnableSram
	ld a, [wActiveFloor]
	add a, a
	ld b, a
	ld hl, RoomDefaultNamePtrs
	rst AddAToHL
	ld a, [hl+]
	ld d, [hl]
	ld e, a
	ld a, b
	ld hl, FloorSramNamePtrs
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld c, $06
	call CopyDEtoHL
	ld d, $ff
	ld bc, $0008
	call FillRam
	ld a, [wActiveFloor]
	add a, a
	ld hl, FloorSramChecksumPtrs
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, $024e
	call WriteXorChecksum
	call DisableSram
	ld a, [wActiveFloor]
	add a, a
	ld b, a
	ld hl, RoomDefaultNamePtrs
	rst AddAToHL
	ld a, [hl+]
	ld d, [hl]
	ld e, a
	ld a, b
	ld hl, RoomNameBufPtrs
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld c, $06
	call CopyDEtoHL
	ld a, [wActiveFloor]
	ld hl, wRoomSizeState
	rst AddAToHL
	ld [hl], $02
	ret

; Restore the active floor's 6-byte room markers from the undo slot ($12db table)
; back to the live slot ($4a6d table) and rewrite its checksum -- the inverse of
; BackupFloorRoomMarkers.
RestoreFloorRoomMarkers:
	call EnableSram
	ld a, [wActiveFloor]
	add a, a
	ld b, a
	ld hl, RoomNameBufPtrs
	rst AddAToHL
	ld a, [hl+]
	ld d, [hl]
	ld e, a
	ld a, b
	ld hl, FloorSramNamePtrs
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld c, $06
	call CopyDEtoHL
	ld a, [wActiveFloor]
	add a, a
	ld hl, FloorSramChecksumPtrs
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, $024e
	call WriteXorChecksum
	call DisableSram
	ret

; Back up the active floor's 6-byte room markers from the live slot ($4a6d table)
; into the undo slot ($12db table); RestoreFloorRoomMarkers copies them back.
; Called from home.asm before applying floor edits. (Was mis-disassembled as data.)
BackupFloorRoomMarkers:
	call EnableSram
	ld a, [wActiveFloor]
	add a, a
	ld b, a
	ld hl, FloorSramNamePtrs
	rst AddAToHL
	ld a, [hl+]
	ld d, [hl]
	ld e, a
	ld a, b
	ld hl, RoomNameBufPtrs
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld c, $06
	call CopyDEtoHL
	call DisableSram
	ret

; =============================================================================
; SRAM save/load. The save record lives at SRAM $a6ed: a 3-byte "V03" signature
; followed by $0118 bytes of game state, with an XOR checksum (WriteXorChecksum write
; / VerifyXorChecksum verify). SRAM is enabled/disabled around each access by the home
; helpers EnableSram / DisableSram. Per-floor editor data uses parallel pointer
; tables ($4a61/$4a67/$4a6d/$4a73, plus the $12db undo slot).
; =============================================================================

SramSaveSignature:
	db "V03"

; Write the in-RAM game state (wSaveSignature, $0118 bytes) to SRAM with a fresh
; "V03" header + checksum. Called by the save NPCs (toamuna/bodka scripts).
SaveGameToSram:
	call EnableSram
	ld de, SramSaveSignature
	ld hl, wSaveSignature
	ld c, $03
	call CopyDEtoHL
	ld de, wSaveSignature
	ld hl, $a6ed
	ld bc, $0118
	call CopyDEtoHLLong
	ld hl, $a6ed
	ld bc, $0118
	call WriteXorChecksum
	call DisableSram
	ret
; If the SRAM save record's checksum is valid, copy it into wSaveSignature and
; return 1; otherwise return 0. Called on boot / at the ranch (toamuna, screens).
LoadGameFromSram:
	call EnableSram
	ld hl, $a6ed
	ld bc, $0118
	call VerifyXorChecksum
	jr z, .loaded
	call DisableSram          ; bad checksum: disable SRAM, return 0
	xor a
	ret
.loaded:
	ld de, $a6ed
	ld hl, wSaveSignature
	ld bc, $0118
	call CopyDEtoHLLong
	call DisableSram
	ld a, $01
	ret
; Return 1 if a valid save exists (SRAM "V03" signature matches), else 0.
HasSavedGame:
	call EnableSram
	ld de, SramSaveSignature
	ld hl, $a6ed
	ld a, [de]
	cp [hl]
	jr nz, .noSave
	inc de
	inc hl
	ld a, [de]
	cp [hl]
	jr nz, .noSave
	inc de
	inc hl
	ld a, [de]
	cp [hl]
	jr nz, .noSave
	call DisableSram
	ld a, $01
	ret
.noSave:
	call DisableSram
	xor a
	ret
; Compare the 3-byte "V03" signature against [hl] (no SRAM enable). Returns 1 on
; match, 0 otherwise. Helper used by the per-room load loop in LoadFloorEditsFromSram.
CompareSaveSignature:
	ld de, SramSaveSignature
	ld a, [de]
	cp [hl]
	jr nz, .noMatch
	inc de
	inc hl
	ld a, [de]
	cp [hl]
	jr nz, .noMatch
	inc de
	inc hl
	ld a, [de]
	cp [hl]
	jr nz, .noMatch
	ld a, $01
	ret
.noMatch:
	xor a
	ret
; If the save record is valid, load the 5-byte high score ($a6f0) into wHiScore
; and return 1, else return 0.
LoadHiScoreFromSram:
	call EnableSram
	ld hl, $a6ed
	ld bc, $0118
	call VerifyXorChecksum
	jr z, .valid
	call DisableSram          ; bad checksum: disable SRAM, return 0
	xor a
	ret
.valid:
	ld de, $a6f0
	ld hl, wHiScore
	ld c, $05
	call CopyDEtoHL
	call DisableSram
	ld a, $01
	ret
; Load all saved per-room floor edits from SRAM: for each room slot, verify its
; "V03" signature + checksum and unpack the valid ones back into the editor's
; floor tables. Called from scene.asm and link.asm.
LoadFloorEditsFromSram:
	call EnableSram
	xor a
	ld [$d0e7], a
Func_12_4c1a:
	ld a, [$d0e7]
	add a, a
	ld hl, FloorSramChecksumPtrs
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call CompareSaveSignature
	or a
	jr z, Func_12_4c3e
	ld a, [$d0e7]
	add a, a
	ld hl, FloorSramChecksumPtrs
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, $024e
	call VerifyXorChecksum
	jr z, Func_12_4c83
Func_12_4c3e:
	ld a, [$d0e7]
	add a, a
	ld hl, FloorSramChecksumPtrs
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, SramSaveSignature
	ld c, $03
	call CopyDEtoHL
	ld a, [$d0e7]
	add a, a
	ld b, a
	ld hl, RoomDefaultNamePtrs
	rst AddAToHL
	ld a, [hl+]
	ld d, [hl]
	ld e, a
	ld a, b
	ld hl, FloorSramNamePtrs
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld c, $06
	call CopyDEtoHL
	ld d, $ff
	ld bc, $0008
	call FillRam
	ld a, [$d0e7]
	add a, a
	ld hl, FloorSramChecksumPtrs
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, $024e
	call WriteXorChecksum
Func_12_4c83:
	ld a, [$d0e7]
	add a, a
	ld b, a
	ld hl, FloorSramNamePtrs
	rst AddAToHL
	ld a, [hl+]
	ld d, [hl]
	ld e, a
	ld a, b
	ld hl, RoomNameBufPtrs
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld c, $06
	call CopyDEtoHL
	ld [hl], $00
	ld a, [$d0e7]
	ld hl, wRoomSizeState
	rst AddAToHL
	ld a, $06
	rst AddAToDE
	ld a, [de]
	cp $0e
	jr nz, Func_12_4cb1

Data_12_4cad:
	db $36, $00, $18, $0a

Func_12_4cb1:
	cp $0a
	jr nz, Func_12_4cb9

Data_12_4cb5:
	db $36, $01, $18, $02

Func_12_4cb9:
	ld [hl], $02
	ld a, [$d0e7]
	inc a
	ld [$d0e7], a
	cp $03
	jp nz, Func_12_4c1a
	call DisableSram
	ret


; NB: Should probably go into src/room/room_bonus_mocchi.asm, but since this is
; larger than the unknown record tail not entirely sure what it is.
SECTION "analyzed_04a6a4", ROMX[$66a4], BANK[$12]

Data_12_66a4:
	db $10, $01, $ba, $66, $aa, $66, $55, $46, $46, $47, $55, $46, $46, $47, $55, $46
	db $46, $47, $55, $46, $46, $47, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25
	db $25, $25, $25, $25, $25, $25, $10, $01, $e0, $66, $d0, $66, $55, $46, $46, $47
	db $55, $46, $46, $47, $55, $46, $46, $47, $55, $46, $46, $47, $05, $05, $05, $05
	db $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $01, $20, $16, $67
	db $f6, $66, $55, $5d, $65, $75, $55, $5d, $65, $5d, $65, $75, $55, $5d, $75, $55
	db $5d, $65, $5d, $65, $5d, $65, $75, $55, $5d, $65, $75, $55, $5d, $65, $75, $55
	db $5d, $65, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05
	db $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05
	db $05, $05
