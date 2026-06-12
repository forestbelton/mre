; Bank $30 -- the full-screen presentation flows, one blocking draw+input loop
; per screen, entered from the wGameScene dispatcher in home.asm:
;
;   DrawTownScreen          town map; d-pad picks a location (tower/Bodka/
;                           Pashute/Toamuna/Verde), confirm -> scene 5+N
;   DrawTowerEntranceScreen tower door opens, player enters
;   DrawRoomStartScreen     vault door + "FLOOR N" plaque (variants for
;                           basement, wRoomType-6 and user/editor rooms)
;   DrawNextRoomScreen      between-floors flight along a (y,x) path, with
;                           the 10-floor progress ladder
;   DrawRoomClearScreen     results: time-bonus tally into wScore (BCD),
;                           NEXT/TOWN menu
;   DrawTowerOpenScreen     tower-opening cutscene
;   LoadTitleScreen         title: hi-score, START/CONTINUE menu, SRAM load
;   DrawIntroBookScreen     15-page intro storybook (art from banks $29-$2b,
;                           captions = the bank-$2b Screen2b_* descriptors)
;   DmgOnlyScreen           "for Game Boy Color" notice on non-CGB hardware
;
; Each loop drives the shared wScreen* scratchpad (wram.asm $D0F3) and ends by
; setting wGameScene. Screen art lives in the per-screen banks (gfx/screen/*).
; Carved out of analyzed.asm (byte-exact: section names + placement unchanged).

INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "scene.inc"
INCLUDE "sound_ids.inc"

SECTION "analyzed_0c0000", ROMX[$4000], BANK[$30]

; "PLAY"/"EDIT" ASCII -- was misdisassembled as code. Unreferenced (no pointer
; to $30:$4000 anywhere in the ROM); leftover draft of the title menu, which
; instead draws pre-rendered tile patches (Data_28_737c).
UnusedPlayEditText:
	db "PLAY", 0, "EDIT", 0

; Town location-select, indexed by wScreenInput (0-4). Confirming location N
; starts scene SCENE_TOWN+1+N (see TownConfirmSelection + the scene farptr
; table at $00:$0f7d): 0 = the tower (Naji's gate encounter), 1 = Bodka,
; 2 = Pashute, 3 = Toamuna, 4 = Verde.
; Per-location cursor handlers, dispatched via `jp hl` each frame.
TownLocCursorHandlers:
	dw TownCursorTower
	dw TownCursorBodka
	dw TownCursorPashute
	dw TownCursorToamuna
	dw TownCursorVerde
; BG dest each location's name plate is drawn to (descriptors from the bank-$20
; table at $20:$78f3, drawn by the TownDrawLocationNames loop).
TownLocNameDests:
	dw $9800, $9942, $98ac, $994c, $98a3

DrawTownScreen:
	xor a
	ld [wFadeLevel], a
	ld [wScreenFrame], a
	ld [wScreenAnim], a
	ld [wScreenAnim2], a
	call HideAllSprites
	xor a
	ldh [rVBK], a
	ld a, BANK(TownTilesBank0)
	ld hl, TownTilesBank0
	ld de, $8000
	ld bc, TownTilesBank0End - TownTilesBank0
	call BankVramCopy
	ld a, $01
	ldh [rVBK], a
	ld a, BANK(TownTilesBank1)
	ld hl, TownTilesBank1
	ld de, $8000
	ld bc, TownTilesBank1End - TownTilesBank1
	call BankVramCopy
	ld c, $00
	ld a, [wTownStage]
	ld b, $02
	add a, b
	ld b, a
; draw the name plate of every unlocked location (count = wTownStage + 3)
TownDrawLocationNames:
	ld a, b
	cp c
	jp c, TownFinishSetup
	push bc
	ld hl, TownLocNameDests
	ld a, c
	add a, a
	rst AddAToHL
	rst DerefHL
	ld d, h
	ld e, l
	ld hl, $78f3
	ld b, $20
	ld a, c
	call BankMapCopyIndexed
	pop bc
	inc c
	jp TownDrawLocationNames
TownFinishSetup:
	ld a, BANK(Data_20_7356)
	ld [wDrawBank], a
	ld hl, Data_20_7356
	ld b, $10
	ld c, $08
	call DrawMetasprite
	call TownGlowOverlayInit
	call HideUnusedOamSprites
	ldh a, [rLCDC]
	set 1, a
	ldh [rLCDC], a
	xor a
	ld b, $08
	ld c, $20
	ld hl, $7000
	call LoadBgPalettesToSlotBanked
	xor a
	ld b, $08
	ld c, $20
	ld hl, $7040
	call LoadObjPalettesToSlotBanked
	call TownGlowInit
; d-pad moves the cursor between locations (direction code 0-3 -> nav map);
; A confirms (location 0 immediately, others once the cursor has settled).
TownInputLoop:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyRepeat]
	ld b, a
	bit 7, b
	jr z, Func_30_40c0
	ld a, $03
	call TownMoveCursor
	jp Func_30_4104
Func_30_40c0:
	bit 6, b
	jr z, Func_30_40cc
	ld a, $02
	call TownMoveCursor
	jp Func_30_4104
Func_30_40cc:
	bit 5, b
	jr z, Func_30_40d8
	ld a, $01
	call TownMoveCursor
	jp Func_30_4104
Func_30_40d8:
	bit 4, b
	jr z, Func_30_40e4
	ld a, $00
	call TownMoveCursor
	jp Func_30_4104
Func_30_40e4:
	bit 0, b
	jr z, Func_30_4104
	ld a, [wScreenInput]
	cp $00
	jp z, Func_30_40f7
	ld a, [wFadeLevel]
	cp $10
	jr c, Func_30_4104
Func_30_40f7:
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	call HideWindowLayer
	jp TownConfirmSelection
Func_30_4104:
	ld a, [wScreenInput]
	cp $00
	jp z, Func_30_411b
	ld a, [wFadeLevel]
	cp $10
	jr nc, Func_30_411b
	ld a, [$c287]
	and $01
	jp nz, TownDrawFrame
Func_30_411b:
	ld hl, TownDrawFrame
	push hl
	ld a, [wScreenInput]
	add a, a
	ld hl, TownLocCursorHandlers
	rst AddAToHL
	rst DerefHL
	jp hl
TownDrawFrame:
	call TownGlowOverlayStep
	call TownGlowPaletteStep
	ld a, [wScreenFrame]
	inc a
	ld [wScreenFrame], a
	ld a, BANK(Data_20_7356)
	ld [wDrawBank], a
	ld hl, Data_20_7356
	ld b, $10
	ld c, $08
	call DrawMetasprite
	call HideUnusedOamSprites
	ld a, [wFadeLevel]
	inc a
	ld [wFadeLevel], a
	jp TownInputLoop
; fade out and hand the selection to the scene dispatcher: scene =
; SCENE_TOWN+1+location (5-9 = Naji/Bodka/Pashute/Toamuna/Verde scripts),
; wGameSceneArg = location (restored as the cursor position on return).
TownConfirmSelection:
	call DisableLcdStatInterrupt
	call WaitForPaletteFadeCgb
	call FadePalettesToWhite
	ld a, [wScreenInput]
	ld [wGameSceneArg], a
	add a, SCENE_NAJI
	ld [wGameScene], a
	ret

; Town cursor-movement maps, one per growth stage (wTownStage 0-2): 5 rows
; (current location) x 4 columns (d-pad direction 0=Right 1=Left 2=Up 3=Down,
; see TownInputLoop) = the location the cursor moves to, $ff = no move.
; Locked locations' rows are all $ff in the earlier stages.
TownNavStage0:
	db $01, $03, $01, $03 ; 0 tower
	db $ff, $00, $ff, $00 ; 1 Bodka
	db $ff, $ff, $ff, $ff ; 2 Pashute (locked)
	db $00, $ff, $00, $ff ; 3 Toamuna
	db $ff, $ff, $ff, $ff ; 4 Verde (locked)
TownNavStage1:
	db $01, $03, $01, $03 ; 0 tower
	db $ff, $00, $ff, $02 ; 1 Bodka
	db $ff, $00, $ff, $ff ; 2 Pashute
	db $00, $ff, $00, $ff ; 3 Toamuna
	db $ff, $ff, $ff, $ff ; 4 Verde (locked)
TownNavStage2:
	db $01, $03, $01, $03 ; 0 tower
	db $ff, $00, $ff, $02 ; 1 Bodka
	db $ff, $00, $01, $ff ; 2 Pashute
	db $00, $ff, $04, $ff ; 3 Toamuna
	db $00, $ff, $ff, $03 ; 4 Verde
TownNavTables:
	dw TownNavStage0
	dw TownNavStage1
	dw TownNavStage2

; A = d-pad direction (0-3); move the town cursor per the stage's nav map,
; or play the "blocked" buzz if the map says $ff.
TownMoveCursor:
	ld d, a
	ld hl, TownNavTables
	ld a, [wTownStage]
	add a, a
	rst AddAToHL
	rst DerefHL
	ld a, [wScreenInput]
	add a, a
	add a, a
	add a, d
	rst AddAToHL
	ld a, [hl]
	ld c, a
	cp $ff
	jr nz, Func_30_41c9
	push af
	ld a, SOUND_SFX_02
	call PlaySound
	pop af
	jr Func_30_41d8
Func_30_41c9:
	ld a, c
	ld [wScreenInput], a
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	xor a
	ld [wFadeLevel], a
Func_30_41d8:
	ret

; Location 0 (the tower): no name window, no cursor sprite -- the tower
; highlight pulse (TownGlow*) marks the selection instead.
TownCursorTower:
	call HideWindowLayer
	ret

; Locations 1-4: settle-in for $10 frames (wFadeLevel), then hold. Cursor
; metasprite = bank-$20 table $78fd, frame = per-location base + blink phase
; (settled frame = base + 4); name plate into the window while settling.
TownCursorBodka:
	ld a, [wFadeLevel]
	cp $10
	jr c, Func_30_41ef
	ld a, $11
	ld [wFadeLevel], a
	ld a, $04
	add a, $0f
	jr Func_30_41fe
Func_30_41ef:
	call TownShowNameWindow
	ld a, $03
	call TownDrawNamePlate
	ld b, $02
	call TownCursorBlinkFrame
	add a, $0f
Func_30_41fe:
	ld e, $6e
	ld d, $2c
	call TownDrawCursorSprite
	ret

TownCursorPashute:
	ld a, [wFadeLevel]
	cp $10
	jr c, Func_30_4218
	ld a, $11
	ld [wFadeLevel], a
	ld a, $04
	add a, $05
	jr Func_30_4227
Func_30_4218:
	call TownShowNameWindow
	ld a, $01
	call TownDrawNamePlate
	ld b, $02
	call TownCursorBlinkFrame
	add a, $05
Func_30_4227:
	ld e, $72
	ld d, $60
	call TownDrawCursorSprite
	ret

TownCursorToamuna:
	ld a, [wFadeLevel]
	cp $10
	jr c, Func_30_423f
	ld a, $11
	ld [wFadeLevel], a
	ld a, $04
	jr Func_30_424c
Func_30_423f:
	call TownShowNameWindow
	ld a, $00
	call TownDrawNamePlate
	ld b, $02
	call TownCursorBlinkFrame
Func_30_424c:
	ld e, $1c
	ld d, $60
	call TownDrawCursorSprite
	ret

TownCursorVerde:
	ld a, [wFadeLevel]
	cp $10
	jr c, Func_30_4266
	ld a, $11
	ld [wFadeLevel], a
	ld a, $04
	add a, $0a
	jr Func_30_4275
Func_30_4266:
	call TownShowNameWindow
	ld a, $02
	call TownDrawNamePlate
	ld b, $02
	call TownCursorBlinkFrame
	add a, $0a
Func_30_4275:
	ld e, $22
	ld d, $2c
	call TownDrawCursorSprite
	ret
TownCursorBlinkFrame:
	ld a, [wFadeLevel]
	ld d, a
	ld c, $00
Func_30_4283:
	srl d
	inc c
	ld a, c
	cp b
	jp nz, Func_30_4283
	ld a, d
	and $07
	ret
TownDrawCursorSprite:
	ld hl, $78fd
	ld b, $20
	call DrawMetaspriteIndexed
	ret

; Code, was misfiled as data. Unreferenced (no pointer to $30:$4298 in the
; ROM): a draw-indexed-metasprite helper like DrawMetaspriteIndexed but without the
; bank switch and with swapped coord registers. Dead.
UnusedDrawMetaspriteIndexed:
	push af
	ld a, b
	ld [wDrawBank], a
	pop af
	rst AddAToHL
	rst DerefHL
	ld b, e
	ld c, d
	call DrawMetasprite
	ret

TownShowNameWindow:
	ld hl, Data_20_792f
	ld de, TILEMAP1
	ld b, BANK(Data_20_792f)
	ld a, $04
	call BankMapCopyIndexed
	ldh a, [rLCDC]
	set 5, a
	ldh [rLCDC], a
	ld a, $07
	ldh [rWX], a
	ld a, $70
	ldh [rWY], a
	ret

HideWindowLayer:
	ldh a, [rLCDC]
	and $df
	ldh [rLCDC], a
	ret

TownDrawNamePlate:
	ld hl, Data_20_792f
	ld de, $9c23
	ld b, BANK(Data_20_792f)
	call BankMapCopyIndexed
	ret

; Tower-selected highlight, secondary layer (a bank-$20 overlay drawn by
; Func_20_796d, frame = wScreenAnim2): snap fully on/off at screen setup.
TownGlowOverlayInit:
	ld a, [wScreenInput]
	and a
	jr nz, Func_30_42e9
	ld a, $03
	ld [wScreenAnim2], a
	FAR_CALL Func_20_796d
	ret

Func_30_42e9:
	ld a, $00
	ld [wScreenAnim2], a
	ret

; Per-frame: ramp wScreenAnim2 up to 3 while the cursor is on the tower
; (every 4th frame), snap to 0 otherwise, then redraw the overlay.
TownGlowOverlayStep:
	ld a, [wScreenInput]
	and a
	jr nz, Func_30_430c
	ld a, [wScreenAnim2]
	cp $03
	jr nc, Func_30_4325
	ld a, [wScreenFrame]
	and $03
	jr nz, Func_30_4325
	ld a, [wScreenAnim2]
	inc a
	ld [wScreenAnim2], a
	jr Func_30_4325
Func_30_430c:
	xor a
	ld [wScreenAnim2], a
	ld a, [wScreenAnim2]
	and a
	ret z

; Code, was misfiled as data. Dead: the `ret z` above always takes (it tests
; the zero just stored). Would have stepped wScreenAnim2 back down one notch
; every 4th frame instead of snapping it to 0.
UnusedTownGlowRampDown:
	ld a, [wScreenFrame]
	and $03
	jr nz, Func_30_4325
	ld a, [wScreenAnim2]
	dec a
	ld [wScreenAnim2], a
	jr Func_30_4325

Func_30_4325:
	FAR_CALL Func_20_796d
	ret

; Tower-glow palette ramp: 4 palette blocks in bank $20 (off -> full glow),
; indexed by wScreenAnim. Loaded into BG slot 2 + OBJ slot 0.
TownGlowPalettes:
	dw $75eb, $75f3, $75fb, $7603

; Per-frame: ramp wScreenAnim toward 3 while the cursor is on the tower (every
; 2nd frame), back toward 0 otherwise, reloading the glow palette each step.
TownGlowPaletteStep:
	ld a, [wScreenInput]
	and a
	jr nz, Func_30_4355
	ld a, [wScreenAnim]
	cp $03
	ret nc
	ld a, [wScreenFrame]
	and $01
	jr nz, Func_30_436b
	ld a, [wScreenAnim]
	inc a
	ld [wScreenAnim], a
	call TownGlowLoadPalette
	jr Func_30_436b
Func_30_4355:
	ld a, [wScreenAnim]
	and a
	ret z
	ld a, [wScreenFrame]
	and $01
	jr nz, Func_30_436b
	ld a, [wScreenAnim]
	dec a
	ld [wScreenAnim], a
	call TownGlowLoadPalette
Func_30_436b:
	ret

TownGlowInit:
	ld a, [wScreenInput]
	and a
	jr nz, Func_30_437c
	ld a, $03
	ld [wScreenAnim], a
	ld [wScreenAnim2], a
	jr Func_30_4383
Func_30_437c:
	xor a
	ld [wScreenAnim], a
	ld [wScreenAnim2], a
Func_30_4383:
	call TownGlowLoadPalette
	ret

TownGlowLoadPalette:
	ld a, [wScreenAnim]
	add a, a
	ld hl, TownGlowPalettes
	rst AddAToHL
	rst DerefHL
	push hl
	ld a, $02
	ld b, $01
	ld c, $20
	call LoadBgPalettesToSlotBanked
	pop hl
	xor a
	ld b, $01
	ld c, $20
	call LoadObjPalettesToSlotBanked
	ret
DrawTowerEntranceScreen:
	xor a
	ld [wFadeLevel], a
	ld [wScreenPhase], a
	call HideAllSprites
	xor a
	ldh [rVBK], a
	ld a, $22
	ld hl, $4000
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld a, $01
	ldh [rVBK], a
	ld a, $22
	ld hl, $5800
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld b, $22
	ld hl, $7080
	ld de, $9800
	call BankMapCopyB
	ld a, $03
	call TowerDoorDrawSprite
	call TowerEntranceDrawStatic
	call HideUnusedOamSprites
	ldh a, [rLCDC]
	set 1, a
	ldh [rLCDC], a
	xor a
	ld b, $08
	ld c, $22
	ld hl, $7000
	call LoadBgPalettesToSlotBanked
	xor a
	ld b, $08
	ld c, $22
	ld hl, $7040
	call LoadObjPalettesToSlotBanked
; A starts the door-opening sequence (wScreenInput 0 -> 1); the door then
; animates open over wFadeLevel frames and the screen fades out at $48.
TowerEntranceLoop:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyRepeat]
	ld b, a
	ld a, [$c55d] ; dead read (leftover; immediately overwritten)
	bit 0, b
	jr z, Func_30_442e
	ld a, [wScreenInput]
	cp $01
	jp z, TowerEntranceLoop
	push af
	ld a, SOUND_SFX_11
	call PlaySound
	pop af
	call HideWindowLayer
	xor a
	ld [wFadeLevel], a
	ld a, $01
	ld [wScreenInput], a
Func_30_442e:
	ld a, [wScreenInput]
	cp $00
	jr nz, Func_30_443d
	ld a, $03
	call TowerDoorDrawSprite
	jp Func_30_444a
Func_30_443d:
	ld a, [wFadeLevel]
	cp $48
	jr nc, TowerEntranceExit
	call TowerDoorStep
	call TowerDoorDrawSpriteByPhase
Func_30_444a:
	call TowerEntranceDrawStatic
	call HideUnusedOamSprites
	ld a, [wFadeLevel]
	inc a
	ld [wFadeLevel], a
	jp TowerEntranceLoop
TowerEntranceExit:
	call WaitForPaletteFadeCgb
	call FadePalettesToBlack
	ret
; advance the door-opening phase (0-2) every $20 frames and redraw the door
; BG patch (descriptor #phase from the bank-$22 table at $22:$75cd -> $9945)
TowerDoorStep:
	ld a, [wFadeLevel]
	and $1f
	cp $1f
	jr nz, Func_30_4475
	ld a, [wScreenPhase]
	cp $02
	jr nc, Func_30_4475
	inc a
	ld [wScreenPhase], a
Func_30_4475:
	ld a, [wScreenPhase]
	ld hl, $75cd
	ld b, $22
	ld de, $9945
	call BankMapCopyIndexed
	ret
; door overlay metasprite #A (table $22:$75d3), frame 3 = closed
TowerDoorDrawSpriteByPhase:
	ld a, [wScreenPhase]
TowerDoorDrawSprite:
	ld b, $22
	ld hl, $75d3
	ld d, $69
	ld e, $30
	call DrawMetaspriteIndexed
	ret
TowerEntranceDrawStatic:
	ld a, $22
	ld [wDrawBank], a
	ld hl, $7356
	ld b, $10
	ld c, $08
	call DrawMetasprite
	ret

; room-start screen state machine, indexed by wScreenPhase
RoomStartPhaseHandlers:
	dw RoomStartPhaseWait
	dw RoomStartPhaseFloorInfo
	dw RoomStartPhaseFadeOut

DrawRoomStartScreen:
	call BlackoutPalettes
	xor a
	ld [wFadeLevel], a
	xor a
	ld [wScreenInput], a
	ld [wScreenPhase], a
	ld [wScreenTimer], a
	ld a, [$c55d] ; editor room slot (0-2); only used by the wRoomType-5 path
	ld [wScreenAnim], a
	call HideAllSprites
	xor a
	ldh [rVBK], a
	ld a, $23
	ld hl, $4000
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld a, $01
	ldh [rVBK], a
	ld a, $23
	ld hl, $5800
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld b, $23
	ld hl, $7080
	ld de, $9800
	call BankMapCopyB
	ld a, [wRoomType]
	cp $05
	jr nz, Func_30_4506
	; wRoomType 5 (user/editor room): alternate plaque instead of a floor number
	ld b, $23
	ld hl, $73b2
	ld de, $9886
	call BankMapCopyB
	jr Func_30_4524
Func_30_4506:
	; wActiveFloor -> packed BCD (tens<<4 | ones) for the digit draws
	ld a, [wActiveFloor]
	ld b, a
	ld c, $00
Func_30_450c:
	sub $0a
	jr c, Func_30_4514
	ld b, a
	inc c
	jr Func_30_450c
Func_30_4514:
	ld a, b
	and $0f
	ld b, a
	ld a, c
	swap a
	and $f0
	or b
	ld [wFloorBcd], a
	call RoomStartDrawFloorNumber
Func_30_4524:
	xor a
	ld b, $08
	ld c, $23
	ld hl, $7000
	call LoadBgPalettesToSlotBanked
	xor a
	ld b, $08
	ld c, $23
	ld hl, $7040
	call LoadObjPalettesToSlotBanked
	ldh a, [rLCDC]
	set 1, a
	ldh [rLCDC], a
RoomStartLoop:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyRepeat]
	ld b, a
	ld a, [$c55d] ; dead read (leftover; immediately overwritten)
	bit 0, b
	jr nz, Func_30_4554
	bit 1, b
	jr z, RoomStartRunPhase
Func_30_4554:
	; A/B skips ahead (latch wScreenInput = 1)
	ld a, [wScreenInput]
	cp $01
	jp z, RoomStartRunPhase
	ld a, $01
	ld [wScreenInput], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	jr RoomStartRunPhase
RoomStartRunPhase:
	ld hl, RoomStartDrawFrame
	push hl
	ld a, [wScreenPhase]
	add a, a
	ld hl, RoomStartPhaseHandlers
	rst AddAToHL
	rst DerefHL
	jp hl
; common per-frame tail: torch flames (BG patch cycle + two mirrored flame
; metasprites), until phase 3 ends the screen
RoomStartDrawFrame:
	ld a, [wScreenPhase]
	cp $03
	jr nc, RoomStartExit
	ld a, [wFadeLevel]
	srl a
	srl a
	srl a
	and $03
	push af
	ld hl, $7b6a
	ld de, $9800
	ld b, $23
	call BankMapCopyIndexed
	ld b, $04
	ld a, [wScreenPhase]
	cp $00
	jr z, Func_30_45a1
	ld b, $08
Func_30_45a1:
	pop af
	add a, b
	ld hl, $7b6a
	ld de, $9810
	ld b, $23
	call BankMapCopyIndexed
	ld a, [wFadeLevel]
	srl a
	srl a
	push af
	and $03
	ld b, $23
	ld hl, $7b82
	ld d, $20
	ld e, $10
	call DrawMetaspriteIndexed
	pop af
	add a, $03
	and $03
	ld b, $23
	ld hl, $7b82
	ld d, $20
	ld e, $89
	call DrawMetaspriteIndexed
	call HideUnusedOamSprites
	ld a, [wFadeLevel]
	inc a
	ld [wFadeLevel], a
	jp RoomStartLoop
RoomStartExit:
	call WaitForPaletteFadeCgb
	ret
; phase 0: characters stand at the vault door for $78 frames (or until A/B)
RoomStartPhaseWait:
	ld a, [wScreenTimer]
	cp $78
	jr nc, Func_30_461f
	ld a, [wRoomType]
	cp $05
	jr z, Func_30_4603
	ld hl, $7356
	ld a, $23
	ld [wDrawBank], a
	ld b, $28
	ld c, $48
	call DrawMetasprite
Func_30_4603:
	ld hl, $7377
	ld a, $23
	ld [wDrawBank], a
	ld b, $48
	ld c, $38
	call DrawMetasprite
	ld a, [wScreenInput]
	cp $00
	jr nz, Func_30_461f
	ld a, [wScreenTimer]
	inc a
	jr Func_30_4629
Func_30_461f:
	xor a
	ld [wScreenInput], a
	ld a, $01
	ld [wScreenPhase], a
	xor a
Func_30_4629:
	ld [wScreenTimer], a
	ret
; phase 1: floor-info plaque ("FLOOR N" / room name / lives), $f0 frames
RoomStartPhaseFloorInfo:
	ld a, [wScreenTimer]
	cp $f0
	jr c, Func_30_463d
	xor a
	ld [wFadeLevel], a
	ld a, $01
	ld [wScreenInput], a
Func_30_463d:
	ld a, [wScreenTimer]
	cp $00
	jr nz, Func_30_465a
	ld hl, $73a0
	ld de, $984f
	ld b, $23
	call BankMapCopyB
	ld hl, $737c
	ld de, $990f
	ld b, $23
	call BankMapCopyB
Func_30_465a:
	ld a, [wRoomType]
	cp $06
	jr nz, Func_30_4666
	call RoomStartPlaqueType6
	jr Func_30_4672
Func_30_4666:
	cp $05
	jr nz, Func_30_466f
	call RoomStartPlaqueUserRoom
	jr Func_30_4672
Func_30_466f:
	call RoomStartPlaqueFloor
Func_30_4672:
	ld a, [wScreenTimer]
	inc a
	ld [wScreenTimer], a
	ld a, [wScreenInput]
	cp $00
	jr z, Func_30_468c
	ld a, $02
	ld [wScreenPhase], a
	xor a
	ld [wScreenTimer], a
	call FadePalettesToBlack
Func_30_468c:
	ret
; phase 2: player walk cycle while the palettes fade out; phase 3 at $48
RoomStartPhaseFadeOut:
	ld a, [wFadeLevel]
	cp $48
	jr nc, Func_30_469d
	ld b, $50
	ld c, $48
	call DrawWalkCycleSprite
	jr Func_30_46a3
Func_30_469d:
	ld a, $03
	ld [wScreenPhase], a
	xor a
Func_30_46a3:
	ret
; normal rooms: "FLOOR N" plaque + floor digits + lives count (BCD)
RoomStartPlaqueFloor:
	ld a, [wScreenTimer]
	cp $00
	jr nz, Func_30_46db
	ld hl, $73d8
	ld de, $9845
	ld b, $23
	call BankMapCopyB
	call RoomStartDrawPlaqueDigits
	ld a, [wLives]
	and $0f
	ld hl, $7ba4
	ld de, $98cc
	ld b, $23
	call BankMapCopyIndexed
	ld a, [wLives]
	swap a
	and $0f
	ld hl, $7ba4
	ld de, $98cb
	ld b, $23
	call BankMapCopyIndexed
Func_30_46db:
	ld b, $50
	ld c, $48
	call DrawWalkCycleSprite
	jr Func_30_46f0

; Code, was misfiled as data. Dead (the `jr` above always skips it): would
; have jumped straight to phase 2 + fade-out. The same orphaned 12 bytes
; follow each of the three plaque variants.
UnusedRoomStartSkipToFadeOutA:
	ld a, $02
	ld [wScreenPhase], a
	xor a
	ld [wScreenTimer], a
	call FadePalettesToBlack

Func_30_46f0:
	ret
; wRoomType 6: alternate plaque (no floor number)
RoomStartPlaqueType6:
	ld a, [wScreenTimer]
	cp $00
	jr nz, Func_30_4703
	ld hl, $759c
	ld de, $9845
	ld b, $23
	call BankMapCopyB
Func_30_4703:
	jr Func_30_4711

; dead, see UnusedRoomStartSkipToFadeOutA
UnusedRoomStartSkipToFadeOutB:
	ld a, $02
	ld [wScreenPhase], a
	xor a
	ld [wScreenTimer], a
	call FadePalettesToBlack

Func_30_4711:
	ret
; wRoomType 5 (user/editor room): plaque + the room's name (text buffer
; $c7e1/$c7e8/$c7ef picked by slot $c55d, table $00:$12db) + status patch
RoomStartPlaqueUserRoom:
	ld a, [wScreenTimer]
	cp $00
	jr nz, Func_30_475d
	ld hl, $74ba
	ld de, $9845
	ld b, $23
	call BankMapCopyB
	ld a, [wScreenAnim]
	add a, a
	ld hl, $12db
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, $0507
	ld a, $08
	call Func_00_1fa4
	ld a, [wScreenAnim]
	ld hl, $c7f6
	rst AddAToHL
	ld a, [hl]
	or a
	jr z, Func_30_4752

	; Code, was misfiled as data -- LIVE: falls through from the `jr z`
	; above when the slot's status flag ($c7f6+slot) is nonzero. Flag 1 ->
	; alternate status patch ($23:$7b4c); other values -> alternate unless
	; the user floor is full-width (wFloorWidth == 17).
	cp $01
	jr z, Func_30_474d
	ld a, [wFloorWidth]
	cp $11
	jr z, Func_30_4752
Func_30_474d:
	ld hl, $7b4c
	jr Func_30_4755

Func_30_4752:
	ld hl, $7b2e
Func_30_4755:
	ld de, $98e7
	ld b, $23
	call BankMapCopyB
Func_30_475d:
	jr Func_30_476b

; dead, see UnusedRoomStartSkipToFadeOutA
UnusedRoomStartSkipToFadeOutC:
	ld a, $02
	ld [wScreenPhase], a
	xor a
	ld [wScreenTimer], a
	call FadePalettesToBlack

Func_30_476b:
	ret
; Floor number on the vault door ($9889/$988a): two digits from the bank-$23
; digit-descriptor table at $23:$7b90, or "B"+digit ($23:$7a8e) on basement
; floors (wRoomType 1; floor 10 uses dedicated patches).
RoomStartDrawFloorNumber:
	ld a, [wRoomType]
	cp $01
	jr z, Func_30_4796
	ld a, [wFloorBcd]
	swap a
	and $0f
	ld hl, $7b90
	ld de, $9889
	ld b, $23
	call BankMapCopyIndexed
	ld a, [wFloorBcd]
	and $0f
	ld hl, $7b90
	ld de, $988a
	ld b, $23
	call BankMapCopyIndexed
	ret
Func_30_4796:
	ld a, [wActiveFloor]
	cp $0a
	jr nz, Func_30_47b5
	ld hl, $7aa2
	ld de, $9889
	ld b, $23
	call BankMapCopyB
	ld hl, $7a98
	ld de, $988a
	ld b, $23
	call BankMapCopyB
	jr Func_30_47cb
Func_30_47b5:
	ld hl, $7b90
	ld de, $988a
	ld b, $23
	call BankMapCopyIndexed
	ld hl, $7a8e
	ld de, $9889
	ld b, $23
	call BankMapCopyB
Func_30_47cb:
	ret

; CGB attributes (palette 0, VRAM bank 1) for the plaque digit cells
RoomStartDigitAttrs:
	db $08, $08, $08, $08

; same two digits / "B"+digit again, on the floor-info plaque ($986c/$986d),
; plus their CGB attributes
RoomStartDrawPlaqueDigits:
	ld a, [wRoomType]
	cp $01
	jr z, Func_30_4800
	ld c, $02
	ld a, [wFloorBcd]
	swap a
	and $0f
	ld hl, $7b90
	ld de, $986c
	ld b, $23
	call BankMapCopyIndexed
	ld c, $02
	push bc
	ld a, [wFloorBcd]
	and $0f
	ld hl, $7b90
	ld de, $986d
	ld b, $23
	call BankMapCopyIndexed
	jr Func_30_4838
Func_30_4800:
	ld c, $02
	push bc
	ld a, [wActiveFloor]
	cp $0a
	jr nz, Func_30_4822
	ld hl, $7aa2
	ld de, $986c
	ld b, $23
	call BankMapCopyB
	ld hl, $7a98
	ld de, $986d
	ld b, $23
	call BankMapCopyB
	jr Func_30_4838
Func_30_4822:
	ld hl, $7b90
	ld de, $986d
	ld b, $23
	call BankMapCopyIndexed
	ld hl, $7a8e
	ld de, $986c
	ld b, $23
	call BankMapCopyB
Func_30_4838:
	pop bc
	ld de, $986c
	call RoomStartSetDigitAttrs
	ret
RoomStartSetDigitAttrs:
	ld a, $01
	ldh [rVBK], a
	ld hl, RoomStartDigitAttrs
	ld b, $02
	call CopyAttrRows
	ret

; Player walk-cycle metasprite frames (bank $02 entity sprites); stepped by
; DrawWalkCycleSprite from wFadeLevel.
WalkCycleSpriteFrames:
	dw $516e, $5180, $5192, $51a4

; 4-frame player walk cycle at (b,c) -- used as the room-start/room-clear
; "walking in" sprite and as the room-clear menu cursor.
DrawWalkCycleSprite:
	ld a, [wFadeLevel]
	and $0f
	srl a
	srl a
	add a, a
	ld hl, WalkCycleSpriteFrames
	rst AddAToHL
	rst DerefHL
	ld a, $02
	ld [wDrawBank], a
	call DrawMetasprite
	ret
; copy b rows of 2 attr/tile bytes from hl to the BG map at de (next row each
; iteration); used with rVBK already set
CopyAttrRows:
	push bc
	ld b, $00
	push de
	call VramCopy16
	pop de
	ld a, $20
	rst AddAToDE
	pop bc
	dec b
	jr nz, CopyAttrRows
	ret
DrawNextRoomScreen:
	xor a
	ld [wFadeLevel], a
	ld [wFadeLevelHi], a
	ld [wScreenInput], a
	ld [wScreenAnim2], a
	ld a, $40
	ldh [rSCY], a
	ldh a, [rLCDC]
	set 5, a
	ldh [rLCDC], a
	ld a, $4f
	ldh [rWX], a
	ld a, $58
	ldh [rWY], a
	call HideAllSprites
	xor a
	ldh [rVBK], a
	ld a, $24
	ld hl, $4000
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld b, $24
	ld hl, $5880
	ld de, $9c00
	call BankMapCopyB
	ld a, [wActiveFloor]
	ld b, a
	ld c, $00
Func_30_48c1:
	sub $0a
	jr c, Func_30_48c9
	ld b, a
	inc c
	jr Func_30_48c1
Func_30_48c9:
	ld a, b
	and $0f
	ld b, a
	ld a, c
	swap a
	and $f0
	or b
	ld [wFloorBcd], a
	call NextRoomDrawHeaderLabel
	call NextRoomDrawWindowFloor
	call NextRoomComputeStopFlags
	ldh a, [rLCDC]
	set 1, a
	ldh [rLCDC], a
	ld a, [wRoomType]
	cp $01
	jr z, Func_30_4911
	ld a, $01
	ldh [rVBK], a
	ld a, BANK(Data_25_4000)
	ld hl, Data_25_4000
	ld de, $8000
	ld bc, Data_25_4000End - Data_25_4000
	call BankVramCopy
	ld b, $25
	ld hl, $7100
	ld de, $9909
	call BankMapCopyB
	call NextRoomDrawStatic
	ld hl, $7000
	jr Func_30_4931
Func_30_4911:
	ld a, $01
	ldh [rVBK], a
	ld a, BANK(Data_25_5800)
	ld hl, Data_25_5800
	ld de, $8000
	ld bc, Data_25_5800End - Data_25_5800
	call BankVramCopy
	ld b, $25
	ld hl, $71f8
	ld de, $9909
	call BankMapCopyB
	ld hl, $7080
Func_30_4931:
	push hl
	xor a
	ld b, $08
	ld c, $25
	call LoadBgPalettesToSlotBanked
	pop hl
	ld a, $40
	rst AddAToHL
	xor a
	ld b, $08
	ld c, $25
	call LoadObjPalettesToSlotBanked
NextRoomLoop:
	call WaitForNextFrame
	ld a, [wFadeLevel]
	cp $2c
	jr nz, Func_30_4957
	ld a, [wFadeLevelHi]
	cp $01
	jr z, Func_30_4973
Func_30_4957:
	call ReadJoypad
	ldh a, [hJoyRepeat]
	ld b, a
	ld a, [$c55d]
	bit 0, b
	jr z, Func_30_4982
	ld a, [wScreenInput]
	cp $01
	jp z, Func_30_4982
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
Func_30_4973:
	xor a
	ld [wFadeLevel], a
	ld [wFadeLevelHi], a
	ld a, $01
	ld [wScreenInput], a
	call FadePalettesToBlack
Func_30_4982:
	ld a, [wScreenInput]
	cp $01
	jp nz, Func_30_4997
	ld a, [wFadeLevel]
	cp $48
	jr nc, Func_30_4994
	jp Func_30_4997
Func_30_4994:
	jp NextRoomExit
Func_30_4997:
	call NextRoomDrawProgressMarker
	call NextRoomDrawPlayer
	call NextRoomDrawStopIcons
	ld a, [wRoomType]
	cp $00
	jr z, Func_30_49bc
	ld a, [wFadeLevel]
	and $0f
	srl a
	srl a
	ld b, $24
	ld hl, $65d1
	ld d, $18
	ld e, $58
	call DrawMetaspriteIndexed
Func_30_49bc:
	ld a, [wRoomType]
	cp $01
	jr z, Func_30_49c6
	call NextRoomDrawStatic
Func_30_49c6:
	call HideUnusedOamSprites
	ld a, [wScreenAnim2]
	cp $c3
	jr c, Func_30_49d1
	add a, a
Func_30_49d1:
	ld a, [wFadeLevel]
	ld c, a
	ld a, [wFadeLevelHi]
	ld b, a
	inc bc
	ld a, b
	ld [wFadeLevelHi], a
	ld a, c
	ld [wFadeLevel], a
	jp NextRoomLoop
NextRoomExit:
	ldh a, [rLCDC]
	res 5, a
	ldh [rLCDC], a
	call WaitForPaletteFadeCgb
	ld a, [wScreenInput]
	ret

SECTION "analyzed_0c09f4", ROMX[$49f4], BANK[$30]

; Basement floors -> header-label index (0-2). Indexed by wActiveFloor from
; label-2 ($49f2): the first two entries land on linker pad bytes in the
; section gap before this one (floor 0 doesn't occur; floor 1 reads pad $00).
NextRoomBasementLabelIdx:
	db $00, $00, $00, $01, $01, $01, $02, $02, $02

; Header banner at $9900: descriptor #(tens digit, adjusted) from the bank-$24
; table at $24:$65bf, or the basement banner set at $24:$65cb.
NextRoomDrawHeaderLabel:
	ld a, [wRoomType]
	cp $01
	jr z, Func_30_4a2b
	ld a, [wFloorBcd]
	swap a
	and $0f
	ld b, a
	cp $00
	jr z, Func_30_4a1a
	ld a, [wFloorBcd]
	and $0f
	cp $01
	jr nc, Func_30_4a1a
	dec b
Func_30_4a1a:
	ld a, b
	ld [wScreenFrame], a
	ld b, $24
	ld hl, $65bf
	ld de, $9900
	call BankMapCopyIndexed
	jr Func_30_4a3e
Func_30_4a2b:
	ld a, [wActiveFloor]
	ld hl, NextRoomBasementLabelIdx - 2
	rst AddAToHL
	ld a, [hl]
	ld b, $24
	ld hl, $65cb
	ld de, $9900
	call BankMapCopyIndexed
Func_30_4a3e:
	ret
NextRoomDrawWindowFloor:
	ld a, [wRoomType]
	cp $01
	jr z, Func_30_4a59
	ld a, [wFloorBcd]
	swap a
	and $0f
	call NextRoomDrawWindowDigitHi
	ld a, [wFloorBcd]
	and $0f
	call NextRoomDrawWindowDigitLo
	ret
Func_30_4a59:
	ld a, [wActiveFloor]
	cp $0a
	jr nz, Func_30_4a6c
	ld a, $0b
	call NextRoomDrawWindowDigitHi
	ld a, $0c
	call NextRoomDrawWindowDigitLo
	jr Func_30_4a74
Func_30_4a6c:
	call NextRoomDrawWindowDigitLo
	ld a, $0a
	call NextRoomDrawWindowDigitHi
Func_30_4a74:
	ret

NextRoomDrawWindowDigitHi:
	ld b, $24
	ld hl, $65d9
	ld de, $9c67
	call BankMapCopyIndexed
	ret

NextRoomDrawWindowDigitLo:
	ld b, $24
	ld hl, $65d9
	ld de, $9c68
	call BankMapCopyIndexed
	ret

; Per-frame (y,x) flight path of the player sprite across the next-room
; screen, indexed by wScreenAnim2*2 (NextRoomDrawPlayerAtPathPos).
NextRoomPathMain: ; 209 pairs (normal floors)
	db $88, $70, $88, $70, $87, $6f, $87, $6f, $86, $6e, $86, $6e, $85, $6d, $85, $6d
	db $84, $6c, $84, $6c, $83, $6b, $83, $6b, $82, $6a, $81, $69, $81, $69, $80, $68
	db $80, $68, $7f, $67, $7f, $67, $7e, $66, $7e, $66, $7d, $65, $7d, $65, $7c, $64
	db $7c, $64, $7b, $63, $7a, $62, $7a, $62, $79, $61, $79, $61, $78, $60, $78, $60
	db $77, $5f, $77, $5f, $76, $5e, $76, $5e, $75, $5d, $75, $5d, $74, $5c, $73, $5b
	db $73, $5b, $72, $5a, $72, $5a, $71, $59, $71, $59, $70, $58, $70, $58, $6f, $57
	db $6f, $57, $6e, $56, $6e, $56, $6d, $55, $6c, $54, $6c, $54, $6b, $53, $6b, $53
	db $6a, $52, $6a, $52, $69, $51, $69, $51, $68, $50, $68, $50, $67, $4f, $67, $4f
	db $66, $4e, $65, $4d, $65, $4d, $64, $4c, $64, $4c, $63, $4b, $63, $4b, $62, $4a
	db $62, $4a, $61, $49, $61, $49, $60, $48, $60, $48, $5f, $47, $5e, $46, $5e, $46
	db $5d, $45, $5d, $45, $5c, $44, $5c, $44, $5b, $43, $5b, $43, $5a, $42, $5a, $42
	db $59, $41, $58, $40, $59, $40, $5a, $40, $5b, $40, $5c, $40, $5d, $40, $5e, $40
	db $60, $40, $61, $40, $62, $40, $63, $40, $64, $40, $65, $40, $66, $40, $68, $40
	db $69, $40, $6a, $40, $6b, $40, $6c, $40, $6d, $40, $6e, $40, $70, $40, $71, $40
	db $72, $40, $73, $40, $74, $40, $75, $40, $76, $40, $78, $40, $79, $40, $7a, $40
	db $7b, $40, $7c, $40, $7d, $40, $7e, $40, $80, $40, $80, $40, $80, $40, $80, $3f
	db $81, $3f, $81, $3e, $82, $3e, $82, $3d, $83, $3c, $83, $3c, $84, $3b, $84, $3b
	db $85, $3a, $85, $3a, $86, $39, $86, $38, $87, $38, $87, $37, $88, $37, $88, $36
	db $89, $36, $89, $35, $8a, $34, $8a, $34, $8b, $33, $8b, $33, $8c, $32, $8c, $31
	db $8d, $31, $8d, $30, $8d, $30, $8e, $2f, $8e, $2f, $8f, $2e, $8f, $2d, $90, $2d
	db $90, $2c, $91, $2c, $91, $2b, $92, $2b, $92, $2a, $93, $29, $93, $29, $94, $28
	db $94, $28, $95, $27, $95, $26, $96, $26, $96, $25, $97, $25, $97, $24, $98, $24
	db $98, $23, $99, $22, $99, $22, $9a, $21, $9a, $21, $9a, $20, $9b, $20, $9b, $1f
	db $9c, $1e, $9c, $1e, $9d, $1d, $9d, $1d, $9e, $1c, $9e, $1b, $9f, $1b, $9f, $1a
	db $a0, $1a, $a0, $19, $a1, $19, $a1, $18, $a2, $17, $a2, $17, $a3, $16, $a3, $16
	db $a4, $15, $a4, $15, $a5, $14, $a5, $13, $a6, $13, $a6, $12, $a7, $12, $a7, $11
	db $a8, $10
NextRoomPathBasement: ; 210 pairs (basement floors, wRoomType 1)
	db $a8, $10, $a8, $10, $a7, $11, $a7, $11, $a6, $12, $a6, $12, $a5, $13, $a5, $13
	db $a4, $14, $a4, $14, $a3, $15, $a3, $15, $a2, $16, $a1, $17, $a1, $17, $a0, $18
	db $a0, $18, $9f, $19, $9f, $19, $9e, $1a, $9e, $1a, $9d, $1b, $9d, $1b, $9c, $1c
	db $9b, $1d, $9b, $1d, $9a, $1e, $9a, $1e, $99, $1f, $99, $1f, $98, $20, $98, $20
	db $97, $21, $97, $21, $96, $22, $95, $23, $95, $23, $94, $24, $94, $24, $93, $25
	db $93, $25, $92, $26, $92, $26, $91, $27, $91, $27, $90, $28, $8f, $29, $8f, $29
	db $8e, $2a, $8e, $2a, $8d, $2b, $8d, $2b, $8c, $2c, $8c, $2c, $8b, $2d, $8b, $2d
	db $8a, $2e, $8a, $2e, $89, $2f, $88, $30, $88, $30, $87, $31, $87, $31, $86, $32
	db $86, $32, $85, $33, $85, $33, $84, $34, $84, $34, $83, $35, $82, $36, $82, $36
	db $81, $37, $81, $37, $80, $38, $80, $38, $7f, $39, $7f, $39, $7e, $3a, $7e, $3a
	db $7d, $3b, $7c, $3c, $7c, $3c, $7b, $3d, $7b, $3d, $7a, $3e, $7a, $3e, $79, $3f
	db $79, $3f, $78, $40, $78, $40, $77, $41, $76, $42, $76, $42, $75, $43, $75, $43
	db $74, $44, $74, $44, $73, $45, $73, $45, $72, $46, $72, $46, $71, $47, $70, $48
	db $70, $48, $6f, $48, $6e, $48, $6d, $48, $6c, $48, $6b, $48, $6a, $48, $68, $48
	db $67, $48, $66, $48, $65, $48, $64, $48, $63, $48, $62, $48, $60, $48, $5f, $48
	db $5e, $48, $5d, $48, $5c, $48, $5b, $48, $5a, $48, $58, $48, $58, $48, $58, $48
	db $59, $49, $59, $49, $5a, $4a, $5a, $4a, $5b, $4b, $5c, $4b, $5c, $4c, $5d, $4c
	db $5d, $4d, $5e, $4e, $5f, $4e, $5f, $4f, $60, $4f, $60, $50, $61, $50, $62, $51
	db $62, $51, $63, $52, $63, $53, $64, $53, $64, $54, $65, $54, $66, $55, $66, $55
	db $67, $56, $67, $56, $68, $57, $69, $58, $69, $58, $6a, $59, $6a, $59, $6b, $5a
	db $6c, $5a, $6c, $5b, $6d, $5b, $6d, $5c, $6e, $5d, $6f, $5d, $6f, $5e, $70, $5e
	db $70, $5f, $71, $5f, $71, $60, $72, $60, $73, $61, $73, $62, $74, $62, $74, $63
	db $75, $63, $76, $64, $76, $64, $77, $65, $77, $65, $78, $66, $79, $67, $79, $67
	db $7a, $68, $7a, $68, $7b, $69, $7c, $69, $7c, $6a, $7d, $6a, $7d, $6b, $7e, $6c
	db $7e, $6c, $7f, $6d, $80, $6d, $80, $6e, $81, $6e, $81, $6f, $82, $6f, $83, $70
	db $83, $71, $84, $71, $84, $72, $85, $72, $86, $73, $86, $73, $87, $74, $87, $74
	db $88, $75, $89, $76
; Player metasprite frames (bank $02): 4 late-phase frames, then the
; 4-frame walk cycle (same pointers as WalkCycleSpriteFrames) used while
; wScreenAnim2 is below the threshold (+8 byte offset in the draw code).
NextRoomPlayerFrames:
	dw $5165, $5177, $5189, $519b
	dw $516e, $5180, $5192, $51a4

NextRoomDrawPlayer:
	ld a, [wFadeLevelHi]
	cp $00
	jp nz, Func_30_4df3
	ld a, [wFadeLevel]
	cp $3c
	jp c, Func_30_4e46
Func_30_4df3:
	ld a, [wScreenAnim2]
	cp $d2
	jp nc, Func_30_4e46
	ld a, $24
	ld [wDrawBank], a
	ld hl, $5920 ; static companion sprite ($24)
	ld b, $68
	ld c, $78
	call DrawMetasprite
	ld a, [wFadeLevel]
	and $0f
	srl a
	srl a
	add a, a
	ld hl, NextRoomPlayerFrames
	rst AddAToHL
	ld a, [wRoomType]
	cp $01
	jr z, Func_30_4e2e
	ld a, [wScreenAnim2]
	cp $5a
	jr nc, Func_30_4e29
	ld a, $08 ; early in the path: walk-cycle frame set
	rst AddAToHL
Func_30_4e29:
	ld de, NextRoomPathMain
	jr Func_30_4e3b
Func_30_4e2e:
	ld a, [wScreenAnim2]
	cp $7e
	jr nc, Func_30_4e38
	ld a, $08 ; early in the path: walk-cycle frame set
	rst AddAToHL
Func_30_4e38:
	ld de, NextRoomPathBasement
Func_30_4e3b:
	rst DerefHL
	call NextRoomDrawPlayerAtPathPos
	ld a, [wScreenAnim2]
	inc a
	ld [wScreenAnim2], a
Func_30_4e46:
	ret
NextRoomDrawPlayerAtPathPos:
	push hl
	ld a, [wScreenAnim2]
	ld b, $00
	sla a
	rl b
	ld c, a
	ld a, e
	add a, c
	ld l, a
	ld a, d
	adc a, b
	ld h, a
	ld a, [hl+]
	ld c, a
	ld a, [hl]
	ld b, a
	pop hl
	ld a, $02
	ld [wDrawBank], a
	call DrawMetasprite
	ret

; Data, was chopped up / partly mislabeled as code. BG dests for the floor
; numbers up the progress ladder (15 rungs, bottom to top; drawn by the
; NextRoomComputeStopFlags else-branch from the digit table at $24:$65f3).
NextRoomLadderDigitDests:
	dw $9b01, $9ae2, $9ac2, $9aa2, $9a82
	dw $9a41, $9a22, $9a02, $99e2, $99c2
	dw $9982, $9962, $9942, $9922, $9902

; (x,y) sprite positions of the progress marker per ones-digit 0-10 (10 =
; "x0" top rung); was mislabeled as code.
NextRoomMarkerPos:
	db $10, $90
	db $18, $88
	db $18, $80
	db $18, $78
	db $18, $70
	db $10, $60
	db $18, $58
	db $18, $50
	db $18, $48
	db $18, $40
	db $10, $30
; Y positions of the basement stop icons (one per prize tier)
NextRoomBasementIconYs:
	db $20, $40, $60, $80

NextRoomDrawProgressMarker:
	ld a, [wFadeLevel]
	bit 4, a
	jp z, Func_30_4f0f
	ld a, [wRoomType]
	cp $01
	jr z, Func_30_4ee5
	ld a, [wFloorBcd]
	and $0f
	ld c, a
	cp $05
	jr z, Func_30_4ec6
	cp $00
	jr nz, Func_30_4ecb
	ld a, [wFloorBcd]
	swap a
	and $0f
	jr z, Func_30_4ecb
	ld c, $0a
Func_30_4ec6:
	ld hl, $5956
	jr Func_30_4ece
Func_30_4ecb:
	ld hl, $5963
Func_30_4ece:
	push hl
	ld a, $24
	ld [wDrawBank], a
	ld a, c
	add a, a
	ld hl, NextRoomMarkerPos
	rst AddAToHL
	ld a, [hl+]
	ld c, a
	ld a, [hl]
	ld b, a
	pop hl
	call DrawMetasprite
	jp Func_30_4f0f
Func_30_4ee5:
	ld a, [wActiveFloor]
	ld c, $01
	cp $08
	jr c, Func_30_4ef2
	ld c, $07
	jr Func_30_4ef8
Func_30_4ef2:
	cp $05
	jr c, Func_30_4ef8
	ld c, $04
Func_30_4ef8:
	sub c
	jp c, Func_30_4f0f
	ld hl, NextRoomBasementIconYs
	rst AddAToHL
	ld a, [hl]
	ld b, a
	ld a, $24
	ld [wDrawBank], a
	ld hl, $5956
	ld c, $10
	call DrawMetasprite
Func_30_4f0f:
	ret
NextRoomComputeStopFlags:
	ld a, [wRoomType]
	cp $01
	jr z, Func_30_4f87
	xor a
	ld [wScreenAnim], a
	ld a, [$cfed]
	ld b, a
	ld a, [wScreenFrame]
	ld c, a
Func_30_4f23:
	ld a, c
	cp $00
	jr z, Func_30_4f2f
	ld a, b
	sub $0a
	ld b, a
	dec c
	jr Func_30_4f23
Func_30_4f2f:
	ld a, b
	cp $0e
	jr c, Func_30_4f36
	ld b, $0e
Func_30_4f36:
	ld c, $00
Func_30_4f38:
	ld a, b
	cp c
	jp c, Func_30_4f87
	push bc
	ld a, c
	cp $00
	jr nz, Func_30_4f4e
	ld a, [wScreenAnim]
	set 0, a
	ld [wScreenAnim], a
	jp Func_30_4f82
Func_30_4f4e:
	ld a, c
	cp $05
	jr nz, Func_30_4f5e
	ld a, [wScreenAnim]
	set 1, a
	ld [wScreenAnim], a
	jp Func_30_4f82
Func_30_4f5e:
	ld a, c
	cp $0a
	jr nz, Func_30_4f6e
	ld a, [wScreenAnim]
	set 2, a
	ld [wScreenAnim], a
	jp Func_30_4f82
Func_30_4f6e:
	add a, a
	ld hl, NextRoomLadderDigitDests
	rst AddAToHL
	rst DerefHL
	ld a, l
	ld e, a
	ld a, h
	ld d, a
	ld b, $24
	ld hl, $65f3
	ld a, $00
	call BankMapCopyIndexed
Func_30_4f82:
	pop bc
	inc c
	jp Func_30_4f38
Func_30_4f87:
	ret
NextRoomDrawStopIcons:
	ld a, [wRoomType]
	cp $01
	jr z, Func_30_4fe3
	ld a, [wScreenAnim]
	cp $00
	jp z, Func_30_5022
	ld a, [wActiveFloor]
	cp $0b
	jr c, Func_30_4fb4
	ld a, [wScreenAnim]
	bit 0, a
	jr z, Func_30_4fb4
	ld a, $24
	ld [wDrawBank], a
	ld hl, $5968
	ld b, $90
	ld c, $10
	call DrawMetasprite
Func_30_4fb4:
	ld a, [wScreenAnim]
	bit 1, a
	jr z, Func_30_4fca
	ld a, $24
	ld [wDrawBank], a
	ld hl, $5968
	ld b, $60
	ld c, $10
	call DrawMetasprite
Func_30_4fca:
	ld a, [wScreenAnim]
	bit 2, a
	jr z, Func_30_5022
	ld a, $24
	ld [wDrawBank], a
	ld hl, $5968
	ld b, $30
	ld c, $10
	call DrawMetasprite
	jp Func_30_5022
Func_30_4fe3:
	ld a, [wActiveFloor]
	ld c, $01
	cp $08
	jr c, Func_30_4ff0
	ld c, $07
	jr Func_30_4ff6
Func_30_4ff0:
	cp $05
	jr c, Func_30_4ff6
	ld c, $04
Func_30_4ff6:
	ld a, [$cfee]
	sub c
	jp c, Func_30_5022
	ld c, a
	ld b, $00
Func_30_5000:
	ld a, b
	cp $04
	jr nc, Func_30_5022
	ld a, c
	cp b
	jr c, Func_30_5022
	push bc
	ld hl, NextRoomBasementIconYs
	ld a, b
	rst AddAToHL
	ld a, [hl]
	ld b, a
	ld a, $24
	ld [wDrawBank], a
	ld hl, $5968
	ld c, $10
	call DrawMetasprite
	pop bc
	inc b
	jr Func_30_5000
Func_30_5022:
	ret
NextRoomDrawStatic:
	ld a, $24
	ld [wDrawBank], a
	ld hl, $592d
	ld b, $10
	ld c, $50
	call DrawMetasprite
	ret

; room-clear screen state machine, indexed by wScreenPhase
RoomClearPhaseHandlers:
	dw RoomClearPhaseDelay
	dw RoomClearPhaseTally
	dw RoomClearPhaseMenu
	dw RoomClearPhaseDone

DrawRoomClearScreen:
	xor a
	ld [wFadeLevel], a
	ld [wScreenInput], a
	ld [wScreenPhase], a
	ld [wScreenTimer], a
	ld a, [wFloorTimer]
	ld [wTallyTimer], a
	ld a, [wFloorTimer+1]
	ld [wTallyTimer+1], a
	ld a, [wFloorTimer+2]
	ld [wTallyTimer+2], a
	ld a, [wScore]
	ld [wTallyScore], a
	ld a, [wScore+1]
	ld [wTallyScore+1], a
	ld a, [wScore+2]
	ld [wTallyScore+2], a
	ld a, [wScore+3]
	ld [wTallyScore+3], a
	ld a, [wScore+4]
	ld [wTallyScore+4], a
	ld a, $48
	ld [wScreenCursorX], a
	ld a, $88
	ld [wScreenCursorY], a
	call HideAllSprites
	xor a
	ldh [rVBK], a
	ld a, $21
	ld hl, $4000
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld a, $01
	ldh [rVBK], a
	ld a, $21
	ld hl, $5800
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld b, $21
	ld hl, $7080
	ld de, $9800
	call BankMapCopyB
	FAR_CALL RoomClearDrawZeroDigit
	xor a
	ld b, $08
	ld c, $21
	ld hl, $7000
	call LoadBgPalettesToSlotBanked
	xor a
	ld b, $08
	ld c, $21
	ld hl, $7040
	call LoadObjPalettesToSlotBanked
	ldh a, [rLCDC]
	set 1, a
	ldh [rLCDC], a
RoomClearLoop:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyRepeat]
	ld b, a
	ld a, [$c55d] ; dead read (leftover; immediately overwritten)
	ld hl, RoomClearDrawFrame
	push hl
	ld a, [wScreenPhase]
	add a, a
	ld hl, RoomClearPhaseHandlers
	rst AddAToHL
	rst DerefHL
	jp hl
; common per-frame tail: bank-$21 screen animation + the walk-cycle sprite as
; the NEXT/TOWN menu cursor (from phase 2, unless wScreenFrame is preset
; nonzero = no menu)
RoomClearDrawFrame:
	ld a, [wScreenPhase]
	cp $04
	jr nc, RoomClearExit
	FAR_CALL RoomClearDrawTimer
	FAR_CALL RoomClearDrawScore
	ld a, [wScreenFrame]
	cp $00
	jr nz, Func_30_5121
	ld a, [wScreenPhase]
	cp $02
	jr c, Func_30_5121
	ld a, [wScreenCursorY]
	ld b, a
	ld a, [wScreenCursorX]
	ld c, a
	call DrawWalkCycleSprite
Func_30_5121:
	call HideUnusedOamSprites
	ld a, [wFadeLevel]
	inc a
	ld [wFadeLevel], a
	jp RoomClearLoop
RoomClearExit:
	call FadePalettesToBlack
	call WaitForPaletteFadeCgb
	ld a, [wScreenFrame]
	cp $00
	jr nz, Func_30_5142
	ld a, [wScreenInput]
	cp $00
	jr nz, RoomClearGoToTown
Func_30_5142:
	FAR_CALL Func_01_4654
	ret
RoomClearGoToTown:
	ld a, $04
	ld [wC2D7], a
	FAR_CALL Naji_RunEncounter
	ld a, SCENE_TOWN
	ld [wGameScene], a
	ret
; phase 0: $3c-frame pause, then the tally jingle
RoomClearPhaseDelay:
	ld a, [wScreenTimer]
	cp $3c
	jr nc, Func_30_516b
	ld a, [wScreenTimer]
	inc a
	jr Func_30_5178
Func_30_516b:
	push af
	ld a, SOUND_SFX_0b
	call PlaySound
	pop af
	ld a, $01
	ld [wScreenPhase], a
	xor a
Func_30_5178:
	ld [wScreenTimer], a
	ret
; phase 1: time bonus -- live wScore counts up by 11 BCD per frame while
; wFloorTimer counts down by 11; A/B (b & 3) skips to the final values
; (computed into the wTally* copies), which are then committed
RoomClearPhaseTally:
	ld a, b
	and $03
	jr nz, Func_30_51c2
	ld hl, wScore
	ld a, [hl]
	add a, $11
	daa
	ld [hl+], a
	ld a, [hl]
	adc a, $00
	daa
	ld [hl+], a
	ld a, [hl]
	adc a, $00
	daa
	ld [hl+], a
	ld a, [hl]
	adc a, $00
	daa
	ld [hl+], a
	ld a, [hl]
	adc a, $00
	daa
	ld [hl], a
	or a
	jr z, Func_30_51ab

	; Code, was misfiled as data -- LIVE: falls through when the 5th score
	; byte went nonzero; clamps wScore to its 8-digit max 99999999.
	ld hl, wScore
	ld a, $99
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	xor a
	ld [hl], a

Func_30_51ab:
	ld hl, wFloorTimer
	ld a, [hl]
	sub $11
	daa
	ld [hl+], a
	ld a, [hl]
	sbc a, $00
	daa
	ld [hl+], a
	ld a, [hl]
	sbc a, $00
	daa
	ld [hl], a
	and $f0
	jp z, Func_30_5242
; instant finish: zero the timer, add the whole remaining wTallyTimer into
; wTallyScore (BCD) and commit it as wScore
Func_30_51c2:
	ld hl, wFloorTimer
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
	ld hl, wTallyScore
	ld de, wTallyTimer
	ld a, [de]
	ld b, a
	ld a, [hl]
	add a, b
	daa
	ld [hl+], a
	inc de
	ld a, [de]
	ld b, a
	ld a, [hl]
	adc a, b
	daa
	ld [hl+], a
	inc de
	ld a, [de]
	ld b, a
	ld a, [hl]
	adc a, b
	daa
	ld [hl+], a
	ld a, [hl]
	adc a, $00
	daa
	ld [hl+], a
	ld a, [hl]
	adc a, $00
	daa
	ld [hl], a
	ld a, [wTallyScore]
	ld [wScore], a
	ld a, [wTallyScore+1]
	ld [wScore+1], a
	ld a, [wTallyScore+2]
	ld [wScore+2], a
	ld a, [wTallyScore+3]
	ld [wScore+3], a
	ld a, [wTallyScore+4]
	ld [wScore+4], a
	or a
	jr z, Func_30_5219

	; Code, was misfiled as data -- LIVE: same 99999999 clamp as above, for
	; the instant-finish path.
	ld hl, wScore
	ld a, $99
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	xor a
	ld [hl], a

Func_30_5219:
	ld a, [wScreenFrame]
	cp $00
	jr nz, Func_30_5236
	; show the NEXT/TOWN menu patches ($21:$7356 -> $9964, $738c -> $99a9)
	ld b, $21
	ld hl, $7356
	ld de, $9964
	call BankMapCopyB
	ld b, $21
	ld hl, $738c
	ld de, $99a9
	call BankMapCopyB
Func_30_5236:
	push af
	ld a, SOUND_SFX_Silence
	call PlaySound
	pop af
	ld a, $02
	ld [wScreenPhase], a
Func_30_5242:
	ret
; phase 2: NEXT/TOWN menu -- up/down moves the walk-sprite cursor between
; rows $88/$98, A confirms (wScreenInput = 0 next floor / 1 town)
RoomClearPhaseMenu:
	ld a, [wScreenTimer]
	cp $01
	jr nz, Func_30_5251
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
Func_30_5251:
	cp $02
	jr nc, Func_30_5259
	inc a
	ld [wScreenTimer], a
Func_30_5259:
	ld a, [wScreenFrame]
	cp $00
	jr nz, Func_30_529c
	bit 7, b
	jr z, Func_30_527e
	ld a, [wScreenInput]
	cp $01
	jr z, Func_30_52b0
	ld a, $01
	ld [wScreenInput], a
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ld a, $98
	ld [wScreenCursorY], a
	jr Func_30_52b0
Func_30_527e:
	bit 6, b
	jr z, Func_30_529c
	ld a, [wScreenInput]
	cp $00
	jr z, Func_30_52b0
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ld a, $88
	ld [wScreenCursorY], a
	ld a, $00
	ld [wScreenInput], a
	jr Func_30_52b0
Func_30_529c:
	bit 0, b
	jr z, Func_30_52b0
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	xor a
	ld [wScreenTimer], a
	ld a, $03
	ld [wScreenPhase], a
Func_30_52b0:
	ret
; phase 3: $1e-frame grace, then phase 4 ends the screen
RoomClearPhaseDone:
	ld a, [wScreenTimer]
	cp $1e
	jp c, Func_30_52bf
	ld a, $04
	ld [wScreenPhase], a
	ret
Func_30_52bf:
	inc a
	ld [wScreenTimer], a
	ret
DrawTowerOpenScreen:
	xor a
	ld [wFadeLevel], a
	ld [wScreenInput], a
	ld [wScreenPhase], a
	ld [wScreenTimer], a
	call HideAllSprites
	xor a
	ldh [rVBK], a
	ld a, $26
	ld hl, $4000
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld a, $01
	ldh [rVBK], a
	ld a, $26
	ld hl, $5800
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld b, $26
	ld hl, $7080
	ld de, $9800
	call BankMapCopyB
	call TowerOpenDrawStatic
	call HideUnusedOamSprites
	xor a
	ld b, $08
	ld c, $26
	ld hl, $7000
	call LoadBgPalettesToSlotBanked
	xor a
	ld b, $08
	ld c, $26
	ld hl, $7040
	call LoadObjPalettesToSlotBanked
	ldh a, [rLCDC]
	set 1, a
	ldh [rLCDC], a
TowerOpenLoop:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyRepeat]
	ld b, a
	ld a, [$c55d]
	bit 0, b
	jr z, Func_30_5341
	ld a, [wScreenInput]
	cp $01
	jp z, Func_30_5341
	ld a, $01
	ld [wScreenInput], a
Func_30_5341:
	ld a, [wFadeLevel]
	cp $14
	jr c, Func_30_53a0
	jr nz, Func_30_5351
	push af
	ld a, SOUND_SFX_11
	call PlaySound
	pop af
Func_30_5351:
	ld a, [wFadeLevel]
	cp $ff
	jr nc, TowerOpenExit
	ld a, [wScreenPhase]
	cp $02
	jr c, Func_30_5368
	ld a, [wScreenInput]
	cp $00
	jr nz, TowerOpenExit
	jr Func_30_5393
Func_30_5368:
	ld a, [wScreenInput]
	cp $00
	jr z, Func_30_537e
	push af
	ld a, SOUND_SFX_Silence
	call PlaySound
	pop af
	xor a
	ld [wScreenInput], a
	ld a, $02
	jr Func_30_5390
Func_30_537e:
	ld a, [wScreenTimer]
	ld b, a
	ld c, $00
Func_30_5384:
	srl b
	inc c
	ld a, c
	cp $05
	jp nz, Func_30_5384
	ld a, b
	and $03
Func_30_5390:
	ld [wScreenPhase], a
Func_30_5393:
	call TowerOpenDrawDoorPatch
	call TowerOpenDrawDoorSprite
	ld a, [wScreenTimer]
	inc a
	ld [wScreenTimer], a
Func_30_53a0:
	call TowerOpenDrawRays
	call TowerOpenDrawStatic
	call HideUnusedOamSprites
	ld a, [wFadeLevel]
	ld b, a
	and $80
	inc b
	or b
	ld [wFadeLevel], a
	jp TowerOpenLoop
TowerOpenExit:
	call WaitForPaletteFadeCgb
	call FadePalettesToBlack
	ret
TowerOpenDrawDoorPatch:
	ld a, [wScreenPhase]
	ld b, $26
	ld hl, $768c
	ld de, $98c5
	call BankMapCopyIndexed
	ret
TowerOpenDrawDoorSprite:
	ld a, [wScreenPhase]
	ld b, $26
	ld hl, $7694
	ld d, $48
	ld e, $30
	call DrawMetaspriteIndexed
	ret
TowerOpenDrawRays:
	ld a, [wFadeLevel]
	ld b, a
	ld c, $00
Func_30_53e3:
	srl b
	inc c
	ld a, c
	cp $03
	jp nz, Func_30_53e3
	ld a, b
	and $07
	push af
	ld b, $26
	ld hl, $769a
	ld de, $98f1
	call BankMapCopyIndexed
	pop af
	ld b, $26
	ld hl, $76aa
	ld de, $98e0
	call BankMapCopyIndexed
	ret
TowerOpenDrawStatic:
	ld a, $26
	ld [wDrawBank], a
	ld hl, $7356
	ld b, $10
	ld c, $08
	call DrawMetasprite
	ret

SECTION "analyzed_0c147f", ROMX[$547f], BANK[$30]

; On a non-color Game Boy: draw the bank-$27 "this game is for Game Boy Color"
; notice and hang forever. CheckCgb returns NZ on CGB, so the `ret nz` skips
; the screen on color hardware. Called from the boot path ($00:$35c8).
DmgOnlyScreen:
	rst CheckCgb
	ret nz
	call WaitForNextFrame
	ld a, $80
	ldh [rLCDC], a
	xor a
	ldh [rVBK], a
	ld a, $27
	ld hl, $5ade
	ld de, $8800
	ld bc, $1000
	call BankVramCopy
	ld b, $27
	ld hl, $6ade
	ld de, $9800
	call BankMapCopyB
	call WaitForHBlank
	ld a, $1b
	ldh [rBGP], a
	call WaitForNextFrame
	ld a, $81
	ldh [rLCDC], a
.hang:
	call WaitForNextFrame
	jp .hang

LoadTitleScreen:
	xor a
	ld [wFadeLevel], a
	ld [wFadeLevelHi], a
	ld [wScreenInput], a
	ld [wScreenTimer], a
	ld [wScreenFrame], a
	ld [wScreenAnim], a
	FAR_CALL Func_05_4843 ; save-presence check; 1 = SRAM save exists
	ld [wScreenPhase], a
	cp $01
	jr nz, DrawTitleScreen
	ld a, $01
	ld [wScreenTimer], a
DrawTitleScreen:
	call HideAllSprites
	xor a
	ldh [rVBK], a
	ld a, BANK(TitleTilesBank0)
	ld hl, TitleTilesBank0
	ld de, $8000
	ld bc, TitleTilesBank0End - TitleTilesBank0
	call BankVramCopy
	ld a, $01
	ldh [rVBK], a
	ld a, BANK(TitleTilesBank1)
	ld hl, TitleTilesBank1
	ld de, $8000
	ld bc, TitleTilesBank1End - TitleTilesBank1
	call BankVramCopy
	ld b, BANK(TitleMapDesc)
	ld hl, TitleMapDesc
	ld de, TILEMAP0
	call BankMapCopyB
	ld b, BANK(Data_28_7356)
	ld hl, Data_28_7356
	ld de, $9986
	call BankMapCopyB
	call TitleDrawHiScore
	call TitleDrawStatic
	call LoadWhitePalettes
	ld b, BANK(TitlePalettes)
	ld de, TitlePalettes
	call LoadPalettesBanked
	call FadeInPalettes
; title state machine, on wScreenInput: 0 = waiting for a button, 1 = menu,
; 2 = confirmed, 3 = "no save data" notice
TitleLoop:
	call WaitForNextFrame
	call ReadJoypad
	ld a, [wScreenInput]
	cp $00
	jr z, TitleStateWaitStart
	cp $01
	jr z, TitleStateMenu
	cp $02
	jr z, TitleStateConfirm
	jp TitleStateNoData
TitleNextFrame:
	call TitleDrawStatic
	ld a, [wFadeLevel]
	add a, $01
	ld [wFadeLevel], a
	ld a, [wFadeLevelHi]
	adc a, $00
	ld [wFadeLevelHi], a
	jp TitleLoop
TitleStartGame:
	ld a, SCENE_TOWN
	ld [wGameScene], a
	ld c, $5a
Func_30_5564:
	call WaitForNextFrame
	dec c
	jr nz, Func_30_5564
	call FadePalettesToWhite
	call WaitForPaletteFadeCgb
	ret
; any button: replace the hi-score row with the menu (START patch, plus the
; CONTINUE patch when a save exists / wScreenPhase != 0)
TitleStateWaitStart:
	ldh a, [hJoyRepeat]
	cp $00
	jr z, TitleNextFrame
	ld b, BANK(Data_28_737c)
	ld hl, Data_28_737c
	ld de, $9966
	call BankMapCopyB
	call TitleClearHiScoreRow
	ld a, [wScreenPhase]
	and a
	jr z, Func_30_5596
	ld b, BANK(Data_28_73a2)
	ld hl, Data_28_73a2
	ld de, $99a6
	call BankMapCopyB
Func_30_5596:
	ld a, $01
	ld [wScreenInput], a
	jr TitleNextFrame
TitleStateMenu:
	call TitleMenuInput
	call TitleDrawCursor
	jp TitleNextFrame
; cursor row 0 (START) -> new game; row 1 -> load the save, falling through
; to the "no data" notice if the load fails
TitleStateConfirm:
	ld a, [wScreenTimer]
	and a
	jr z, TitleStartGame
	FAR_CALL LoadGameFromSram
	and a
	jr nz, TitleStartGame

	; Code, was misfiled as data -- LIVE: SRAM load failed; draw the
	; "no data" patch ($28:$73cc) over the menu and enter state 3.
	ld b, $28
	ld hl, $73cc
	ld de, $99a1
	call BankMapCopyB
	ld a, $03
	ld [wScreenInput], a
	jp TitleNextFrame

	; Code, was misfiled as data -- LIVE (state 3, reached via the
	; TitleLoop dispatch): wait for any button, then erase the notice,
	; redraw the menu, and reset to state 1.
TitleStateNoData:
	ldh a, [hJoyRepeat]
	cp $00
	jp z, TitleNextFrame
	call TitleClearMenuArea
	ld b, $28
	ld hl, Data_28_737c
	ld de, $9966
	call BankMapCopyB
	ld a, $01
	ld [wScreenInput], a
	xor a
	ld [wFadeLevel], a
	ld [wFadeLevelHi], a
	ld [wScreenPhase], a
	ld [wScreenTimer], a
	ld [wScreenFrame], a
	ld [wScreenAnim], a
	jp z, TitleNextFrame

; menu input: up/down moves the cursor (wScreenTimer 0 = START / 1 =
; CONTINUE), A confirms -> state 2; recomputes the cursor sprite position
TitleMenuInput:
	ldh a, [hJoyRepeat]
	ld b, a
	ld a, [wScreenPhase]
	cp $00
	jr z, Func_30_5636
	bit 7, b
	jr z, Func_30_561d
	ld a, [wScreenTimer]
	cp $01
	jr z, TitleSetCursorPos
	ld a, $01
	ld [wScreenTimer], a
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	jr TitleSetCursorPos
Func_30_561d:
	bit 6, b
	jr z, Func_30_5636
	ld a, [wScreenTimer]
	cp $00
	jr z, TitleSetCursorPos
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ld a, $00
	ld [wScreenTimer], a
	jr TitleSetCursorPos
Func_30_5636:
	bit 0, b
	jr z, TitleSetCursorPos
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ld a, $02
	ld [wScreenInput], a
TitleSetCursorPos:
	ld a, $28
	ld [wScreenCursorX], a
	ld a, [wScreenTimer]
	cp $00
	jr nz, Func_30_5656
	ld a, $68
	jr Func_30_5658
Func_30_5656:
	ld a, $78
Func_30_5658:
	ld [wScreenCursorY], a
	ret
TitleDrawStatic:
	ld a, $28
	ld [wDrawBank], a
	ld b, $10
	ld c, $08
	ld hl, $74c6
	call DrawMetasprite
	ret
TitleDrawCursor:
	ld b, $28
	ld hl, $753f
	ld a, [wScreenCursorY]
	ld d, a
	ld a, [wScreenCursorX]
	ld e, a
	ld a, [wScreenAnim]
	call DrawMetaspriteIndexed
	ld a, [wFadeLevel]
	and $07
	cp $04
	jr nz, Func_30_5697
	ld a, [wScreenAnim]
	cp $03
	jr c, Func_30_5693
	ld a, $00
	jr Func_30_5694
Func_30_5693:
	inc a
Func_30_5694:
	ld [wScreenAnim], a
Func_30_5697:
	ret
TitleDrawHiScore:
	call WaitForHBlank
	ld hl, wHiScore
	ld de, $99ad
	ld a, [hl]
	call WriteBcdDigitTile
	ld a, [hl+]
	swap a
	call WriteBcdDigitTile
	call WaitForHBlank
	ld a, [hl]
	call WriteBcdDigitTile
	ld a, [hl+]
	swap a
	call WriteBcdDigitTile
	call WaitForHBlank
	ld a, [hl]
	call WriteBcdDigitTile
	ld a, [hl+]
	swap a
	call WriteBcdDigitTile
	call WaitForHBlank
	ld a, [hl]
	call WriteBcdDigitTile
	ld a, [hl]
	swap a
	call WriteBcdDigitTile
	ret
; blank the 8 hi-score digit cells (backwards from $99ad)
TitleClearHiScoreRow:
	call WaitForHBlank
	ld de, $99ad
	call TitleClearCell
	call TitleClearCell
	call TitleClearCell
	call WaitForHBlank
	call TitleClearCell
	call TitleClearCell
	call TitleClearCell
	call WaitForHBlank
	call TitleClearCell
	call TitleClearCell
	ret

; Code, was misfiled as data. Erase the 3-row menu/notice area: 18 cells per
; row backwards from $99b2, stepping de to the next row's end. Called by the
; "no data" notice handler (TitleStateNoData).
TitleClearMenuArea:
	ld de, $99b2
	ld c, $03
.row:
	push bc
	call WaitForHBlank
	call TitleClearCell
	call TitleClearCell
	call TitleClearCell
	call WaitForHBlank
	call TitleClearCell
	call TitleClearCell
	call TitleClearCell
	call WaitForHBlank
	call TitleClearCell
	call TitleClearCell
	call TitleClearCell
	call WaitForHBlank
	call TitleClearCell
	call TitleClearCell
	call TitleClearCell
	call WaitForHBlank
	call TitleClearCell
	call TitleClearCell
	call TitleClearCell
	call WaitForHBlank
	call TitleClearCell
	call TitleClearCell
	call TitleClearCell
	pop bc
	ld hl, $0032
	add hl, de
	ld d, h
	ld e, l
	dec c
	jr nz, .row
	ret

; blank one BG cell at de (tile $f8, attr 0) and step backwards
TitleClearCell:
	ld a, $f8
	ld [de], a
	ld a, $01
	ldh [rVBK], a
	ld a, $00
	ld [de], a
	xor a
	ldh [rVBK], a
	dec de
	ret

; Intro storybook page handlers, indexed by wScreenInput (advances 0-14;
; $0f or any button ends the cutscene).
IntroPageHandlers:
	dw IntroPage00, IntroPage01, IntroPage02, IntroPage03, IntroPage04
	dw IntroPage05, IntroPage06, IntroPage07, IntroPage08, IntroPage09
	dw IntroPage10, IntroPage11, IntroPage12, IntroPage13, IntroPage14

DrawIntroBookScreen:
	xor a
	ld [wFadeLevel], a
	ld [wScreenInput], a
	ld [wScreenPhase], a
	ld [wScreenTimer], a
	ld [wScreenFrame], a
	call IntroResetState
	xor a
	ldh [rVBK], a
	ld a, $29
	ld hl, $4000
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld a, $01
	ldh [rVBK], a
	ld a, $29
	ld hl, $5800
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld b, $29
	ld hl, $7080
	ld de, $9880
	call BankMapCopyB
	call LoadWhitePalettes
	ld b, $29
	ld de, $7000
	call LoadPalettesBanked
	call FadeInPalettes
	push af
	ld a, SOUND_BGM_Intro
	call PlaySoundTracked
	pop af
IntroLoop:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyRepeat]
	and a
	jr nz, IntroExit
	ld a, [wScreenInput]
	cp $0f
	jr nc, IntroExit
	ld a, [wScreenPhase]
	and a
	jr nz, Func_30_57ef
	call IntroDrawCaption
Func_30_57ef:
	ld a, [wScreenInput]
	ld hl, IntroDrawTail
	push hl
	add a, a
	ld hl, IntroPageHandlers
	rst AddAToHL
	rst DerefHL
	jp hl
IntroDrawTail:
	call HideUnusedOamSprites
	ld a, [wFadeLevel]
	inc a
	ld [wFadeLevel], a
	jr IntroLoop
IntroExit:
	call FadePalettesToWhite
	call WaitForPaletteFadeCgb
	call Func_00_04c4
	call Func_00_0e24
	ret
IntroResetState:
	xor a
	ld [$cf3f], a
	ld [$cf5b], a
	ld [$cf5c], a
	ld [$cf5d], a
	ld [$cf5e], a
	ld [$cf5f], a
	ld [$cf60], a
	ld [$cf61], a
	ld [$cf52], a
	ld [$cf64], a
	call LoadWhitePalettes
	ld a, $10
	ldh [hSpriteOriginY], a
	ld a, $08
	ldh [hSpriteOriginX], a
	call Func_00_0bdd
	ld hl, $9800
	ld bc, $0400
	call ClearBgMapAndAttrs
	ld hl, $9c00
	ld bc, $0400
	call ClearBgMapAndAttrs
	ld a, $07
	ldh [rWX], a
	xor a
	ldh [rWY], a
	call Func_00_04bc
	xor a
	ldh [rSCX], a
	ldh [rSCY], a
	call Func_00_36b8
	ret

; Intro-cutscene art tables, indexed by sprite id 0-$24 (was chopped into
; arbitrary Data_30_* pieces): source bank per entry, then the pointer. Ids
; 0-$20 are metasprites (IntroDrawSprite); $21-$24 are BG-map descriptors for
; the final pages (IntroDrawBgFrame via BankMapCopyInline).
IntroSpriteBanks:
	db $29, $29, $29, $29, $29, $29, $29, $29
	db $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a
	db $2a, $2a, $2a
	db $2b, $2b, $2b, $2b, $2b, $2b
	db $29, $29, $29, $29
IntroSpritePtrs:
	dw $7a04, $7a7d, $7a8e, $7a9b, $7aa4, $7ab5, $7ac2, $7acb
	dw $7430, $7449, $747a, $74ab, $754c, $7595, $75b6, $75d7
	dw $75f8, $7619, $763a, $76ab, $771c, $778d, $77fe, $786f
	dw $78e0, $7951, $79c2
	dw $7040, $70c1, $7126, $718f, $71ec, $7245
	dw $7216, $73ac, $7542, $76d8

; draw intro art #A at (d,e) -- bank/pointer from the tables above
IntroDrawSprite:
	push af
	ld hl, IntroSpriteBanks
	rst AddAToHL
	ld a, [hl]
	ld [wDrawBank], a
	pop af
	ld hl, IntroSpritePtrs
	add a, a
	rst AddAToHL
	rst DerefHL
	ld b, d
	ld c, e
	call DrawMetasprite
	ret

IntroPage00:
	ld a, [wScreenPhase]
	cp $f0
	jr c, Func_30_5900
	ld a, [wScreenInput]
	inc a
	ld [wScreenInput], a
	xor a
	ld [wScreenPhase], a
	ret
Func_30_5900:
	cp $00
	jr nz, Func_30_5904
Func_30_5904:
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	ret
IntroFlyingSpriteStep:
	ld a, [wFadeLevel]
	and $03
	cp $03
	jr nz, Func_30_5921
	ld a, [hl]
	cp $18
	jr c, Func_30_591e
	dec a
	ld [hl], a
	jr Func_30_5921
Func_30_591e:
	ld a, $68
	ld [hl], a
Func_30_5921:
	ld a, [hl]
	ld e, a
	ld d, $20
	cp $1d
	jr nc, Func_30_592f
	inc b
	cp $1a
	jr nc, Func_30_592f
	inc b
Func_30_592f:
	ld a, b
	call IntroDrawSprite
	ret

; Unreferenced (no pointer to $5934 in the bank): looks like leftover
; (x, sprite-id) keyframe pairs for an intro animation that ended up
; hard-coded in the page handlers instead.
UnusedIntroKeyframes:
	db $68, $01, $20, $02, $20, $03, $28, $04, $20, $04, $18, $04, $18, $05, $18, $06
	db $68, $04, $60, $04, $58, $04, $50, $04, $48, $04, $40, $04, $38, $04, $30, $04

IntroPage01:
	ld a, [wScreenPhase]
	cp $f0
	jr c, Func_30_5967
	ld a, [wScreenInput]
	inc a
	ld [wScreenInput], a
	xor a
	ld [wScreenPhase], a
	ret
Func_30_5967:
	cp $00
	jr nz, Func_30_597e
	ld a, $09
	ld [wScreenTimer], a
	xor a
	ld [wScreenFrame], a
	ld a, $68
	ld [wScreenAnim], a
	ld a, $40
	ld [wScreenAnim2], a
Func_30_597e:
	cp $1e
	jr nc, Func_30_5984
	jr Func_30_599d
Func_30_5984:
	cp $28
	jr nc, Func_30_598d
	call IntroSpriteFlickerIn
	jr Func_30_599d
Func_30_598d:
	cp $e6
	jr nz, Func_30_5998
	ld a, $09
	ld [wScreenTimer], a
	jr Func_30_599d
Func_30_5998:
	jr c, Func_30_599d
	call IntroSpriteFlickerOut
Func_30_599d:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_59bc
	ld d, $00
	ld e, $00
	ld a, $00
	call IntroDrawSprite
	ld hl, wScreenAnim ; reused as a sprite X coord here
	ld b, $01
	call IntroFlyingSpriteStep
	ld hl, wScreenAnim2 ; reused as a sprite X coord here
	ld b, $04
	call IntroFlyingSpriteStep
Func_30_59bc:
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	ret
IntroPage02:
	ld a, [wScreenPhase]
	cp $f0
	jr c, Func_30_59d7
	ld a, [wScreenInput]
	inc a
	ld [wScreenInput], a
	xor a
	ld [wScreenPhase], a
	ret
Func_30_59d7:
	cp $00
	jr nz, Func_30_5a01
	xor a
	ldh [rVBK], a
	ld a, $2a
	ld hl, $4000
	ld de, $8000
	ld bc, $0600
	call BankHBlankCopy
	ld a, $09
	ld [wScreenTimer], a
	xor a
	ld [wScreenFrame], a
	ld a, $68
	ld [wScreenAnim], a
	ld a, $40
	ld [wScreenAnim2], a
	jr Func_30_5a20
Func_30_5a01:
	cp $1e
	jr nc, Func_30_5a07
	jr Func_30_5a20
Func_30_5a07:
	cp $28
	jr nc, Func_30_5a10
	call IntroSpriteFlickerIn
	jr Func_30_5a20
Func_30_5a10:
	cp $e6
	jr nz, Func_30_5a1b
	ld a, $09
	ld [wScreenTimer], a
	jr Func_30_5a20
Func_30_5a1b:
	jr c, Func_30_5a20
	call IntroSpriteFlickerOut
Func_30_5a20:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5a3f
	ld hl, wScreenAnim ; reused as a sprite X coord here
	ld b, $01
	call IntroFlyingSpriteStep
	ld d, $00
	ld e, $00
	ld a, $07
	call IntroDrawSprite
	ld hl, wScreenAnim2 ; reused as a sprite X coord here
	ld b, $04
	call IntroFlyingSpriteStep
Func_30_5a3f:
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	ret
Func_30_5a47:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5a57
	ld d, $00
	ld e, $00
	ld a, [wScreenAnim]
	call IntroDrawSprite
Func_30_5a57:
	ret
IntroPage03:
	ld a, [wScreenPhase]
	cp $00
	jr nz, Func_30_5a8a
	xor a
	ldh [rVBK], a
	ld a, $2a
	ld hl, $4600
	ld de, $8000
	ld bc, $0e00
	call BankHBlankCopy
	ld a, $00
	ld b, $02
	ld c, $2a
	ld hl, $5400
	call LoadObjPalettesToSlotBanked
	ld a, $09
	ld [wScreenTimer], a
	xor a
	ld [wScreenFrame], a
	ld a, $08
	ld [wScreenAnim], a
Func_30_5a8a:
	cp $5a
	jr nc, Func_30_5a90
	jr Func_30_5a97
Func_30_5a90:
	cp $64
	jr nc, Func_30_5a97
	call IntroSpriteFlickerIn
Func_30_5a97:
	call Func_30_5a47
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	cp $b4
	ret c
	ld a, [wScreenInput]
	inc a
	ld [wScreenInput], a
	xor a
	ld [wScreenPhase], a
	ret
IntroPage04:
	ld a, [wScreenPhase]
	cp $b4
	jr c, Func_30_5ac3
	ld a, [wScreenInput]
	inc a
	ld [wScreenInput], a
	xor a
	ld [wScreenPhase], a
	ret
Func_30_5ac3:
	cp $00
	jr nz, Func_30_5ad6
	ld a, $09
	ld [wScreenTimer], a
	ld a, $01
	ld [wScreenFrame], a
	ld a, $08
	ld [wScreenAnim], a
Func_30_5ad6:
	cp $aa
	jr nc, Func_30_5af0
	ld a, [wScreenPhase]
	and $07
	cp $07
	jr nz, Func_30_5afa
	ld a, [wScreenAnim]
	cp $0b
	jr nc, Func_30_5afa
	inc a
	ld [wScreenAnim], a
	jr Func_30_5afa
Func_30_5af0:
	jr nz, Func_30_5af7
	ld a, $09
	ld [wScreenTimer], a
Func_30_5af7:
	call IntroSpriteFlickerOut
Func_30_5afa:
	call Func_30_5a47
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	ret
IntroPage05:
	ld a, [wScreenPhase]
	cp $00
	jr nz, Func_30_5b32
	xor a
	ldh [rVBK], a
	ld a, $2a
	ld hl, $5410
	ld de, $8000
	ld bc, $0800
	call BankHBlankCopy
	ld a, $00
	ld b, $02
	ld c, $2a
	ld hl, $5c10
	call LoadObjPalettesToSlotBanked
	ld a, $09
	ld [wScreenTimer], a
	xor a
	ld [wScreenFrame], a
Func_30_5b32:
	cp $1e
	jr nc, Func_30_5b38
	jr Func_30_5b41
Func_30_5b38:
	cp $28
	jr nc, Func_30_5b41
	call IntroSpriteFlickerIn
	jr Func_30_5b41
Func_30_5b41:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5b50
	ld d, $00
	ld e, $00
	ld a, $0c
	call IntroDrawSprite
Func_30_5b50:
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	cp $b4
	ret c
	ld a, [wScreenInput]
	inc a
	ld [wScreenInput], a
	xor a
	ld [wScreenPhase], a
	ret
IntroPage06:
	ld a, [wScreenPhase]
	cp $f0
	jr c, Func_30_5b79
	ld a, [wScreenInput]
	inc a
	ld [wScreenInput], a
	xor a
	ld [wScreenPhase], a
	ret
Func_30_5b79:
	cp $00
	jr nz, Func_30_5b8c
	ld a, $09
	ld [wScreenTimer], a
	ld a, $01
	ld [wScreenFrame], a
	ld a, $0d
	ld [wScreenAnim], a
Func_30_5b8c:
	cp $e6
	jr nc, Func_30_5ba6
	ld a, [wScreenPhase]
	and $1f
	cp $1f
	jr nz, Func_30_5ba9
	ld a, [wScreenAnim]
	cp $11
	jr nc, Func_30_5ba9
	inc a
	ld [wScreenAnim], a
	jr Func_30_5ba9
Func_30_5ba6:
	call IntroSpriteFlickerOut
Func_30_5ba9:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5bc2
	ld d, $00
	ld e, $00
	ld a, $0c
	call IntroDrawSprite
	ld d, $00
	ld e, $00
	ld a, [wScreenAnim]
	call IntroDrawSprite
Func_30_5bc2:
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	ret
IntroPage07:
	ld a, [wScreenPhase]
	cp $00
	jr nz, Func_30_5c14
	xor a
	ldh [rVBK], a
	ld a, $2a
	ld hl, $5c20
	ld de, $8000
	ld bc, $1000
	call BankHBlankCopy
	ld a, $01
	ldh [rVBK], a
	ld a, $2a
	ld hl, $6c20
	ld de, $8000
	ld bc, $0800
	call BankHBlankCopy
	ld a, $00
	ld b, $02
	ld c, $2a
	ld hl, $7420
	call LoadObjPalettesToSlotBanked
	ld a, $09
	ld [wScreenTimer], a
	xor a
	ld [wScreenFrame], a
	ld a, $12
	ld [wScreenAnim], a
	xor a
	ld [wScreenAnim2], a
	jr Func_30_5c3e
Func_30_5c14:
	cp $1e
	jr nc, Func_30_5c1a
	jr Func_30_5c3e
Func_30_5c1a:
	cp $28
	jr nc, Func_30_5c23
	call IntroSpriteFlickerIn
	jr Func_30_5c3e
Func_30_5c23:
	ld a, [wScreenAnim2]
	and $07
	cp $07
	jr nz, Func_30_5c3e
	ld a, [wScreenAnim]
	cp $19
	jr c, Func_30_5c3a
	ld a, $12
	ld [wScreenAnim], a
	jr Func_30_5c3e
Func_30_5c3a:
	inc a
	ld [wScreenAnim], a
Func_30_5c3e:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5c4e
	ld d, $00
	ld e, $00
	ld a, [wScreenAnim]
	call IntroDrawSprite
Func_30_5c4e:
	ld a, [wScreenAnim2]
	inc a
	ld [wScreenAnim2], a
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	cp $b4
	ret c
	ld a, [wScreenInput]
	inc a
	ld [wScreenInput], a
	xor a
	ld [wScreenPhase], a
	ret
IntroPage08:
	ld a, [wScreenPhase]
	cp $b4
	jr c, Func_30_5c7e
	ld a, [wScreenInput]
	inc a
	ld [wScreenInput], a
	xor a
	ld [wScreenPhase], a
	ret
Func_30_5c7e:
	cp $00
	jr nz, Func_30_5c8c
	ld a, $09
	ld [wScreenTimer], a
	ld a, $01
	ld [wScreenFrame], a
Func_30_5c8c:
	cp $aa
	jr nc, Func_30_5ca6
	ld a, [wScreenAnim2]
	and $07
	cp $07
	jr nz, Func_30_5ca9
	ld a, [wScreenAnim]
	cp $1a
	jr nc, Func_30_5ca9
	inc a
	ld [wScreenAnim], a
	jr Func_30_5ca9
Func_30_5ca6:
	call IntroSpriteFlickerOut
Func_30_5ca9:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5cb9
	ld d, $00
	ld e, $00
	ld a, [wScreenAnim]
	call IntroDrawSprite
Func_30_5cb9:
	ld a, [wScreenAnim2]
	inc a
	ld [wScreenAnim2], a
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	ret
IntroPage09:
	ld a, [wScreenPhase]
	cp $00
	jr nz, Func_30_5cf1
	xor a
	ldh [rVBK], a
	ld a, $2b
	ld hl, $4000
	ld de, $8000
	ld bc, $0800
	call BankHBlankCopy
	ld a, $00
	ld b, $02
	ld c, $2b
	ld hl, $4800
	call LoadObjPalettesToSlotBanked
	ld a, $09
	ld [wScreenTimer], a
Func_30_5cf1:
	cp $0a
	jr nc, Func_30_5cf7
	jr Func_30_5cfe
Func_30_5cf7:
	cp $14
	jr nc, Func_30_5cfe
	call IntroSpriteFlickerIn
Func_30_5cfe:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5d0d
	ld d, $00
	ld e, $00
	ld a, $1b
	call IntroDrawSprite
Func_30_5d0d:
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	cp $b4
	ret c
	ld a, [wScreenInput]
	inc a
	ld [wScreenInput], a
	xor a
	ld [wScreenPhase], a
	ret

SECTION "analyzed_0c1d23", ROMX[$5d23], BANK[$30]

; Code, was misfiled as data: an orphaned `ret` between page handlers --
; nothing jumps to it (IntroPage09 returns just before it).
UnusedIntroRet:
	ret

SECTION "analyzed_0c1d24", ROMX[$5d24], BANK[$30]

IntroPage10:
	ld a, [wScreenPhase]
	cp $b4
	jr c, Func_30_5d37
	ld a, [wScreenInput]
	inc a
	ld [wScreenInput], a
	xor a
	ld [wScreenPhase], a
	ret
Func_30_5d37:
	cp $00
	jr nz, Func_30_5d40
	ld a, $09
	ld [wScreenTimer], a
Func_30_5d40:
	cp $aa
	jr c, Func_30_5d47
	call IntroSpriteFlickerOut
Func_30_5d47:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5d56
	ld d, $00
	ld e, $00
	ld a, $1b
	call IntroDrawSprite
Func_30_5d56:
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	ret
IntroPage11:
	ld a, [wScreenPhase]
	cp $b4
	jr c, Func_30_5d71
	ld a, [wScreenInput]
	inc a
	ld [wScreenInput], a
	xor a
	ld [wScreenPhase], a
	ret
Func_30_5d71:
	cp $00
	jr nz, Func_30_5d9b
	xor a
	ldh [rVBK], a
	ld a, $2b
	ld hl, $4810
	ld de, $8000
	ld bc, $1000
	call BankHBlankCopy
	ld a, $00
	ld b, $06
	ld c, $2b
	ld hl, $6010
	call LoadObjPalettesToSlotBanked
	ld a, $09
	ld [wScreenTimer], a
	xor a
	ld [wScreenFrame], a
Func_30_5d9b:
	cp $3c
	jr c, Func_30_5db8
	cp $46
	jr nc, Func_30_5da8
	call IntroSpriteFlickerIn
	jr Func_30_5db8
Func_30_5da8:
	cp $aa
	jr nz, Func_30_5db3
	ld a, $09
	ld [wScreenTimer], a
	jr Func_30_5db8
Func_30_5db3:
	jr c, Func_30_5db8
	call IntroSpriteFlickerOut
Func_30_5db8:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5dc7
	ld d, $00
	ld e, $00
	ld a, $1c
	call IntroDrawSprite
Func_30_5dc7:
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	ret
IntroPage12:
	ld a, [wScreenPhase]
	cp $b4
	jr c, Func_30_5de2
	ld a, [wScreenInput]
	inc a
	ld [wScreenInput], a
	xor a
	ld [wScreenPhase], a
	ret
Func_30_5de2:
	cp $5a
	jr nc, Func_30_5e1d
	cp $00
	jr nz, Func_30_5df3
	ld a, $09
	ld [wScreenTimer], a
	xor a
	ld [wScreenFrame], a
Func_30_5df3:
	cp $0a
	jr nc, Func_30_5dfc
	call IntroSpriteFlickerIn
	jr Func_30_5e0c
Func_30_5dfc:
	cp $50
	jr nz, Func_30_5e07
	ld a, $09
	ld [wScreenTimer], a
	jr Func_30_5e0c
Func_30_5e07:
	jr c, Func_30_5e0c
	call IntroSpriteFlickerOut
Func_30_5e0c:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5e1b
	ld d, $00
	ld e, $00
	ld a, $1d
	call IntroDrawSprite
Func_30_5e1b:
	jr Func_30_5e4c
Func_30_5e1d:
	jr nz, Func_30_5e24
	ld a, $09
	ld [wScreenTimer], a
Func_30_5e24:
	cp $64
	jr nc, Func_30_5e2d
	call IntroSpriteFlickerIn
	jr Func_30_5e3d
Func_30_5e2d:
	cp $aa
	jr nz, Func_30_5e38
	ld a, $09
	ld [wScreenTimer], a
	jr Func_30_5e3d
Func_30_5e38:
	jr c, Func_30_5e3d
	call IntroSpriteFlickerOut
Func_30_5e3d:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5e4c
	ld d, $00
	ld e, $00
	ld a, $1e
	call IntroDrawSprite
Func_30_5e4c:
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	ret
IntroPage13:
	ld a, [wScreenPhase]
	cp $b4
	jr c, Func_30_5e67
	ld a, [wScreenInput]
	inc a
	ld [wScreenInput], a
	xor a
	ld [wScreenPhase], a
	ret
Func_30_5e67:
	cp $5a
	jr nc, Func_30_5ea2
	cp $00
	jr nz, Func_30_5e78
	ld a, $09
	ld [wScreenTimer], a
	xor a
	ld [wScreenFrame], a
Func_30_5e78:
	cp $0a
	jr nc, Func_30_5e81
	call IntroSpriteFlickerIn
	jr Func_30_5e91
Func_30_5e81:
	cp $50
	jr nz, Func_30_5e8c
	ld a, $09
	ld [wScreenTimer], a
	jr Func_30_5e91
Func_30_5e8c:
	jr c, Func_30_5e91
	call IntroSpriteFlickerOut
Func_30_5e91:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5ea0
	ld d, $00
	ld e, $00
	ld a, $1f
	call IntroDrawSprite
Func_30_5ea0:
	jr Func_30_5ed1
Func_30_5ea2:
	jr nz, Func_30_5ea9
	ld a, $09
	ld [wScreenTimer], a
Func_30_5ea9:
	cp $64
	jr nc, Func_30_5eb2
	call IntroSpriteFlickerIn
	jr Func_30_5ec2
Func_30_5eb2:
	cp $aa
	jr nz, Func_30_5ebd
	ld a, $09
	ld [wScreenTimer], a
	jr Func_30_5ec2
Func_30_5ebd:
	jr c, Func_30_5ec2
	call IntroSpriteFlickerOut
Func_30_5ec2:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5ed1
	ld d, $00
	ld e, $00
	ld a, $20
	call IntroDrawSprite
Func_30_5ed1:
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	ret
IntroPage14:
	ld a, [wScreenPhase]
	cp $b4
	jr c, Func_30_5eec
	ld a, [wScreenInput]
	inc a
	ld [wScreenInput], a
	xor a
	ld [wScreenPhase], a
	ret
Func_30_5eec:
	cp $00
	jr nz, Func_30_5f1c
	xor a
	ldh [rVBK], a
	ld a, $2b
	ld hl, $6040
	ld de, $8800
	ld bc, $0800
	call BankHBlankCopy
	ld a, $01
	ldh [rVBK], a
	ld a, $2b
	ld hl, $6840
	ld de, $9000
	ld bc, $0800
	call BankHBlankCopy
	ld a, $21
	ld [wScreenAnim], a
	xor a
	ld [wScreenAnim2], a
Func_30_5f1c:
	ld a, [wScreenAnim2]
	cp $10
	jr c, Func_30_5f35
	xor a
	ld [wScreenAnim2], a
	ld a, [wScreenAnim]
	cp $24
	jr nc, Func_30_5f35
	inc a
	ld [wScreenAnim], a
	call IntroDrawBgFrame
Func_30_5f35:
	ld a, [wScreenPhase]
	cp $1e
	jr c, Func_30_5f43
	ld a, [wScreenAnim2]
	inc a
	ld [wScreenAnim2], a
Func_30_5f43:
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	ret
IntroDrawBgFrame:
	push af
	ld hl, $5868
	rst AddAToHL
	ld a, [hl]
	ld b, a
	pop af
	ld hl, $588d
	add a, a
	rst AddAToHL
	rst DerefHL
	ld a, [$cf3f]
	or a
	jr z, Func_30_5f64
	ld de, $9880
	jr Func_30_5f67
Func_30_5f64:
	ld de, $9a80
Func_30_5f67:
	call BankMapCopyInline
	call IntroFlipBgBuffer
	ret
IntroFlipBgBuffer:
	ld a, [$cf3f]
	cpl
	and $01
	ld [$cf3f], a
	ret
IntroSpriteFlickerIn:
	ld a, [wScreenTimer]
	and a
	jr nz, Func_30_5f84
	ld a, $01
	ld [wScreenFrame], a
	ret z
Func_30_5f84:
	cp $0a
	jr nc, Func_30_5f92
	ld a, [wFadeLevel]
	and $01
	ld [wScreenFrame], a
	jr Func_30_5f9a

Func_30_5f92:
	ld a, [wFadeLevel]
	and $01
	ld [wScreenFrame], a

Func_30_5f9a:
	ld a, [wScreenTimer]
	dec a
	ld [wScreenTimer], a
	ret
IntroSpriteFlickerOut:
	ld a, [wScreenTimer]
	and a
	jr nz, Func_30_5fad
	xor a
	ld [wScreenFrame], a
	ret z
Func_30_5fad:
	cp $0a
	jr nc, Func_30_5fbb
	ld a, [wFadeLevel]
	and $01
	ld [wScreenFrame], a
	jr Func_30_5fc3

Func_30_5fbb:
	ld a, [wFadeLevel]
	and $01
	ld [wScreenFrame], a

Func_30_5fc3:
	ld a, [wScreenTimer]
	dec a
	ld [wScreenTimer], a
	ret

; Per-page caption text: two bank-$2b screen descriptors (top 2x17 line ->
; window $9c22, bottom 4x16 block -> $9c83); $ffff = blank the top line.
; This is what the Screen2b_* "structural only" screens are: the intro text.
IntroCaptionPtrs:
	dw Screen2b_00, Screen2b_11
	dw $ffff,       Screen2b_12
	dw Screen2b_01, Screen2b_13
	dw Screen2b_02, Screen2b_14
	dw Screen2b_03, Screen2b_15
	dw Screen2b_04, Screen2b_16
	dw $ffff,       Screen2b_17
	dw Screen2b_05, Screen2b_18
	dw Screen2b_06, Screen2b_19
	dw Screen2b_07, Screen2b_20
	dw Screen2b_08, Screen2b_21
	dw $ffff,       Screen2b_22
	dw Screen2b_09, Screen2b_23
	dw $ffff,       Screen2b_24
	dw Screen2b_10, Screen2b_25

IntroDrawCaption:
	ld a, [wScreenInput]
	add a, a
	add a, a
	ld hl, IntroCaptionPtrs
	rst AddAToHL
	push hl
	rst DerefHL
	ld a, h
	cp $ff
	jr nz, Func_30_6022
	ld hl, $9c20
	ld bc, $0040
	call ClearBgMapAndAttrs
	jr Func_30_602a
Func_30_6022:
	ld de, $9c22
	ld b, $2b
	call BankMapCopyInline
Func_30_602a:
	pop hl
	ld a, $02
	rst AddAToHL
	rst DerefHL
	ld de, $9c83
	ld b, $2b
	call BankMapCopyInline
	ret
