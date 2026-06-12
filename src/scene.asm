; Bank $05 — the intro/cutscene SCENE engine and its assets. A two-level scene-scripting VM (SceneBgVm_Dispatch BG track + SceneSprVm_Enter sprite track, driven per-frame by SceneRunFrame, set up by SceneInit/44d8) plays the eight scenes selected by wSceneState. Scene bytecode is carved into SCENE_BG_*/SCENE_SPR_* macros (see include/scene_script.inc, docs/screen_tilemaps.md): Scene{0-7}_VM1/_VM2. Per-scene dispatch/param tables live around $461a; the rest is CopyBgMap tilemap descriptors + metasprite lists. (Also hosts a small floor-fill helper at FloorFillTiles that merely abuts the scripts.)
; Carved out of analyzed.asm (byte-exact: section names + placement unchanged).

INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "scene_script.inc"
INCLUDE "sound_ids.inc"

SECTION "analyzed_014000", ROMX[$4000], BANK[$05]

SceneInit:
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
	call BlackoutPalettes
	ldh a, [hSpriteOriginY]
	ld [$cf6d], a
	ldh a, [hSpriteOriginX]
	ld [$cf6e], a
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
	call SceneSetupTracks
	call SceneLoadTiles
	call SceneLoadPalettes
	ld a, $07
	ldh [rWX], a
	xor a
	ldh [rWY], a
	call Func_00_04bc
	ld a, [wSceneState]
	cp $02
	jr z, Func_05_4074
	cp $01
	jr z, Func_05_4074
	cp $03
	jr z, Func_05_4074
	call Func_00_0e2f
	xor a
	ldh [rSCX], a
	ldh [rSCY], a
	ret
Func_05_4074:
	call Func_00_0e77
	xor a
	ldh [rSCX], a
	ldh [rSCY], a
	ret

SceneRunFrame:
	ld a, [wSceneState]
	bit 7, a
	ret nz
	call SceneBgVm_Enter
	call SceneSprVm_Step
	call SceneScrollWobble
	call SceneDrawMetasprites
	call Func_05_409c
	ld a, [wSceneState]
	bit 7, a
	ret z
	call SceneFinish
	ret

Func_05_409c:
	ld a, [wSceneState]
	cp $02
	jr z, Func_05_40b2
	cp $01
	jr z, Func_05_40ae
	cp $03
	ret nz
	call Func_05_447f
	ret
Func_05_40ae:
	call Func_05_445a
	ret
Func_05_40b2:
	call Func_05_443d
	ret

SceneScrollWobble:
	ld a, [$cf62]
	or a
	ret z
	ld a, [$cf63]
	inc a
	ld [$cf63], a
	and $07
	ld hl, $40d7
	rst AddAToHL
	ld c, [hl]
	ldh a, [rSCY]
	add a, c
	ldh [rSCY], a
	ret

Data_05_40cf:
	db $00, $01, $00, $ff, $00, $01, $00, $ff

Data_05_40d7:
	db $00, $01, $00, $02, $00, $fe, $00, $ff

Data_05_40df:
	db $00, $02, $00, $03, $00, $fd, $00, $fe

SceneBgVm_Enter:
	ldh a, [hJoyPressed]
	bit 1, a
	jr nz, SceneBgVm_End
	ld a, [$cf41]
	ld l, a
	ld a, [$cf42]
	ld h, a
SceneBgVm_Step:
	ld a, [$cf45]
	cp $ff
	ret z
	or a
	jr z, SceneBgVm_Dispatch
	dec a
	ld [$cf45], a
	ret
SceneBgVm_Dispatch:
	ld a, [hl]
	cp $00
	jr z, SceneBgOp_Draw
	cp $02
	jr z, SceneBgOp_Flip
	cp $03
	jr z, SceneBgOp_Row
	cp $01
	jr z, SceneBgOp_Sound
	cp $fb
	jp z, SceneBgOp_Scroll
	cp $fd
	jp z, SceneBgOp_WobbleOn
	cp $fc
	jp z, SceneBgOp_WobbleOff
	cp $fa
	jp z, SceneBgOp_FarCall
SceneBgVm_End:
	push af
	ld a, SOUND_SFX_Silence
	call PlaySound
	pop af
	ld a, [wSceneState]
	set 7, a
	ld [wSceneState], a
	ret
SceneBgOp_Sound:
	inc hl
	ld a, [hl+]
	call PlaySound
	ld a, l
	ld [$cf41], a
	ld a, h
	ld [$cf42], a
	jr SceneBgVm_Step
SceneBgOp_Flip:
	inc hl
	ld a, l
	ld [$cf41], a
	ld a, h
	ld [$cf42], a
	push hl
	call Func_05_43b1
	pop hl
	call SceneFlipDrawBuffer
	jr SceneBgVm_Step
SceneBgOp_Draw:
	inc hl
	ld a, [hl+]
	ld [$cf45], a
	ld a, [hl+]
	ld [$cf49], a
	ld a, [hl+]
	ld [$cf4a], a
	ld a, [hl+]
	ld [$cf43], a
	ld a, [hl+]
	ld [$cf44], a
	ld a, l
	ld [$cf41], a
	ld a, h
	ld [$cf42], a
	push hl
	call SceneDrawBgMap
	pop hl
	ld a, [$cf45]
	or a
	jp z, SceneBgVm_Step
	call SceneFlipDrawBuffer
	ret
SceneBgOp_Row:
	inc hl
	ld a, [hl+]
	ld [$cf45], a
	ld a, [hl+]
	ld [$cf57], a
	ld a, [hl+]
	ld [$cf58], a
	ld a, [hl+]
	ld [$cf59], a
	ld a, [hl+]
	ld [$cf5a], a
	ld a, l
	ld [$cf41], a
	ld a, h
	ld [$cf42], a
	push hl
	call Func_05_43db
	pop hl
	ld a, [$cf45]
	or a
	jp z, SceneBgVm_Step
	ret
SceneBgOp_WobbleOn:
	ld a, $01
	ld [$cf62], a
	xor a
	ld [$cf63], a
	inc hl
	ld a, l
	ld [$cf41], a
	ld a, h
	ld [$cf42], a
	jp SceneBgVm_Step

SceneBgOp_WobbleOff:
	xor a
	ld [$cf62], a
	ld [$cf63], a
	inc hl
	ld a, l
	ld [$cf41], a
	ld a, h
	ld [$cf42], a
	jp SceneBgVm_Step

SceneBgOp_Scroll:
	inc hl
	ld a, [hl+]
	ld [$cf61], a
	ld a, l
	ld [$cf41], a
	ld a, h
	ld [$cf42], a
	jp SceneBgVm_Step

SceneBgOp_FarCall:
	inc hl
	ld a, [hl+]
	push hl
	push af
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	pop af
	call Func_00_0495
	pop hl
	inc hl
	inc hl
	jp SceneBgVm_Step

SceneSprVm_Step:
	ld a, [$cf4b]
	ld l, a
	ld a, [$cf4c]
	ld h, a
SceneSprVm_Enter:
	ld a, [$cf4f]
	cp $ff
	ret z
	or a
	jr z, SceneSprVm_Dispatch
	dec a
	ld [$cf4f], a
	ret
SceneSprVm_Dispatch:
	ld a, [hl]
	cp $00
	jp z, SceneSprOp_Show
	cp $07
	jp z, SceneSprOp_Move
	cp $08
	jp z, SceneSprOp_Step
	cp $03
	jr z, SceneSprOp_Anim
	cp $01
	jr z, SceneSprOp_Sound
	cp $04
	jr z, SceneSprOp_Jump
	cp $05
	jr z, SceneSprOp_LoopOn
	cp $06
	jr z, SceneSprOp_LoopOff
	cp $fa
	jp z, SceneSprOp_FarCall
	ld a, [wSceneState]
	set 7, a
	ld [wSceneState], a
	ret
SceneSprOp_LoopOn:
	inc hl
	ld a, $01
	ld [$cf52], a
	ld a, l
	ld [$cf4b], a
	ld a, h
	ld [$cf4c], a
	jr SceneSprVm_Enter
SceneSprOp_LoopOff:
	inc hl
	xor a
	ld [$cf52], a
	ld a, l
	ld [$cf4b], a
	ld a, h
	ld [$cf4c], a
	jr SceneSprVm_Enter
SceneSprOp_Sound:
	inc hl
	ld a, [hl+]
	call PlaySound
	ld a, l
	ld [$cf4b], a
	ld a, h
	ld [$cf4c], a
	jr SceneSprVm_Enter
SceneSprOp_Jump:
	inc hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	ld [$cf4b], a
	ld a, h
	ld [$cf4c], a
	jr SceneSprVm_Enter
SceneSprOp_Anim:
	inc hl
	ld a, [hl+]
	ld [$cf4f], a
	ld a, [hl+]
	ld [$cf57], a
	ld a, [hl+]
	ld [$cf58], a
	ld a, [hl+]
	ld [$cf59], a
	ld a, [hl+]
	ld [$cf5a], a
	ld a, l
	ld [$cf4b], a
	ld a, h
	ld [$cf4c], a
	push hl
	call Func_05_440c
	pop hl
	ld a, [$cf4f]
	or a
	jp z, SceneSprVm_Enter

SECTION "analyzed_0142a7", ROMX[$42a7], BANK[$05]

Data_05_42a7:
	db $c9

SECTION "analyzed_0142a8", ROMX[$42a8], BANK[$05]

SceneSprOp_Show:
	inc hl
	ld a, [hl+]
	ld [$cf4f], a
	ld a, [hl+]
	ld [$cf50], a
	ld a, [hl+]
	ld [$cf51], a
	ld a, [hl+]
	ld [$cf4d], a
	ld a, [hl+]
	ld [$cf4e], a
	ld a, l
	ld [$cf4b], a
	ld a, h
	ld [$cf4c], a
	ld a, [$cf4f]
	or a
	jp z, SceneSprVm_Enter
	ret
SceneSprOp_Move:
	inc hl
	xor a
	ld [$cf4f], a
	ld a, [hl+]
	ld [$cf50], a
	ld a, [hl+]
	ld [$cf51], a
	ld a, [hl+]
	ld [$cf53], a
	ld a, [hl+]
	ld [$cf54], a
	ld a, [hl+]
	ld [$cf55], a
	ld a, [hl+]
	ld [$cf56], a
	ld a, [hl+]
	ld [$cf4d], a
	ld a, [hl+]
	ld [$cf4e], a
	ld a, l
	ld [$cf4b], a
	ld a, h
	ld [$cf4c], a
	ret
SceneSprOp_Step:
	ld a, [$cf50]
	ld c, a
	ld a, [$cf55]
	add a, c
	ld [$cf50], a
	ld c, a
	ld a, [$cf51]
	ld b, a
	ld a, [$cf56]
	add a, b
	ld [$cf51], a
	ld b, a
	ld a, [$cf53]
	cp c
	ret nz
	ld a, [$cf54]
	cp b
	ret nz
	inc hl
	ld a, l
	ld [$cf4b], a
	ld a, h
	ld [$cf4c], a
	ret

SceneSprOp_FarCall:
	inc hl
	ld a, [hl+]
	push hl
	push af
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	pop af
	call Func_00_0495
	pop hl
	inc hl
	inc hl
	jp SceneSprVm_Enter

SceneFlipDrawBuffer:
	ld a, [$cf3f]
	or a
	jr z, Func_05_4343
	xor a
	ld [$cf3f], a
	ret
Func_05_4343:
	ld a, $01
	ld [$cf3f], a
	ret
SceneDrawBgMap:
	ld a, [$cf43]
	ld l, a
	ld a, [$cf44]
	ld h, a
	or l
	ret z
	ld a, [$cf3f]
	or a
	jr z, Func_05_4385
	push hl
	ld a, [wSceneState]
	ld hl, SceneDescBank
	rst AddAToHL
	ld b, [hl]
	ld de, $9800
	ld a, [$cf49]
	ld l, a
	ld a, [$cf4a]
	ld h, a
	add hl, de
	ld d, h
	ld e, l
	pop hl
	ld [wBankCallTmp], a
	ld a, h
	ld [wSpawnPtr], a
	ld a, l
	ld [wSpawnPtr+1], a
	ld a, $00
	ld hl, $10dc
	call Func_00_0467
	ret
Func_05_4385:
	push hl
	ld a, [wSceneState]
	ld hl, SceneDescBank
	rst AddAToHL
	ld b, [hl]
	ld de, $9a00
	ld a, [$cf49]
	ld l, a
	ld a, [$cf4a]
	ld h, a
	add hl, de
	ld d, h
	ld e, l
	pop hl
	ld [wBankCallTmp], a
	ld a, h
	ld [wSpawnPtr], a
	ld a, l
	ld [wSpawnPtr+1], a
	ld a, $00
	ld hl, $10dc
	call Func_00_0467
	ret
Func_05_43b1:
	ld a, [$cf3f]
	or a
	jr z, Func_05_43c9
	ld de, $9800
	ld c, $20
	ld b, $10
	ld a, $fc
	call SceneVramFillBank0
	ld a, $08
	call SceneVramFillBank1
	ret
Func_05_43c9:
	ld de, $9a00
	ld c, $20
	ld b, $10
	ld a, $fc
	call SceneVramFillBank0
	ld a, $08
	call SceneVramFillBank1
	ret
Func_05_43db:
	ld a, [$cf57]
	ld l, a
	ld a, [$cf58]
	ld h, a
	or l
	ret z
	push hl
	ld a, [wSceneState]
	ld hl, ScenePaletteBank
	rst AddAToHL
	ld c, [hl]
	pop hl
	ld a, [$cf5a]
	ld b, a
	ld a, [$cf59]
	ld d, a
Func_05_43f7:
	push bc
	push de
	push hl
	ld b, $00
	ld a, d
	call LoadBgPalettesToSlotBanked
	pop hl
	ld de, $0008
	add hl, de
	pop de
	inc d
	pop bc
	dec b
	jr nz, Func_05_43f7
	ret
Func_05_440c:
	ld a, [$cf57]
	ld l, a
	ld a, [$cf58]
	ld h, a
	or l
	ret z
	push hl
	ld a, [wSceneState]
	ld hl, ScenePaletteBank
	rst AddAToHL
	ld c, [hl]
	pop hl
	ld a, [$cf5a]
	ld b, a
	ld a, [$cf59]
	ld d, a
Func_05_4428:
	push bc
	push de
	push hl
	ld b, $00
	ld a, d
	call LoadObjPalettesToSlotBanked
	pop hl
	ld de, $0008
	add hl, de
	pop de
	inc d
	pop bc
	dec b
	jr nz, Func_05_4428
	ret
Func_05_443d:
	ld a, [$cf5b]
	add a, $04
	ld [$cf5b], a
	ld [$cf60], a
	ld a, [$cf5c]
	sub $04
	ld [$cf5c], a
	ld [$cf5d], a
	ld [$cf5e], a
	ld [$cf5f], a
	ret
Func_05_445a:
	ld a, [$cf5b]
	sub $04
	ld [$cf5b], a
	cpl
	ld [$cf60], a
	ld a, [$cf5c]
	add a, $03
	ld [$cf5c], a
	cpl
	ld [$cf5f], a
	ld a, [$cf5d]
	sub $02
	ld [$cf5d], a
	cpl
	ld [$cf5e], a
	ret
Func_05_447f:
	ld a, [$cf61]
	ld b, a
	ld a, [$cf5b]
	add a, b
	ld [$cf5b], a
	ld [$cf5c], a
	ld [$cf5d], a
	ld [$cf5e], a
	ld [$cf5f], a
	ld [$cf60], a
	ret
SceneDrawMetasprites:
	ld a, [$cf4d]
	ld e, a
	ld a, [$cf4e]
	ld d, a
	or e
	ret z
	ld a, [$cf52]
	or a
	jr z, Func_05_44b4
	ld a, [$cf64]
	inc a
	ld [$cf64], a
	and $01
	ret nz
Func_05_44b4:
	ld a, [wSceneState]
	ld hl, SceneDrawBank
	rst AddAToHL
	ld a, [hl]
	ld [wDrawBank], a
	ld a, [$cf50]
	ld c, a
	ld a, [$cf51]
	ld b, a
Func_05_44c7:
	ld a, [de]
	inc de
	ld l, a
	ld a, [de]
	inc de
	ld h, a
	or l
	ret z
	push bc
	push de
	call DrawMetasprite
	pop de
	pop bc
	jr Func_05_44c7
SceneSetupTracks:
	ld a, [wSceneState]
	add a, a
	push af
	ld hl, SceneBgScriptTable
	rst AddAToHL
	ld a, [hl+]
	ld [$cf41], a
	ld a, [hl]
	ld [$cf42], a
	pop af
	ld hl, SceneSprScriptTable
	rst AddAToHL
	ld a, [hl+]
	ld [$cf4b], a
	ld a, [hl]
	ld [$cf4c], a
	xor a
	ld [$cf43], a
	ld [$cf44], a
	ld [$cf45], a
	ld [$cf4d], a
	ld [$cf4e], a
	ld [$cf4f], a
	ld [$cf50], a
	ld [$cf51], a
	ld [$cf62], a
	ld [$cf63], a
	ret
SceneFinish:
	call Func_00_0bdd
	call BlackoutPalettes
	call Func_00_16ad
	FAR_CALL DrawFloorPieces
	FAR_CALL Func_01_75ad
	call Func_05_48a5
	ld a, $07
	ldh [rWX], a
	xor a
	ldh [rWY], a
	call Func_00_0d41
	ld a, [$c289]
	ldh [rSCY], a
	ld a, [$c28a]
	ldh [rSCX], a
	ld a, [$cf6d]
	ldh [hSpriteOriginY], a
	ld a, [$cf6e]
	ldh [hSpriteOriginX], a
	call Func_05_48fc
	call WaitForPaletteFadeCgb
	ret
SceneVramFillBank0:
	ld l, a
	xor a
	ldh [rVBK], a
	push bc
	push de
	call WaitForHBlank
Func_05_4560:
	push bc
	push de
Func_05_4562:
	ld a, e
	and $03
	call z, WaitForHBlank
	ld a, l
	ld [de], a
	inc de
	dec c
	jr nz, Func_05_4562
	pop de
	pop bc
	ld a, e
	add a, $20
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	dec b
	jr nz, Func_05_4560
	pop de
	pop bc
	ret
SceneVramFillBank1:
	ld l, a
	ld a, $01
	ldh [rVBK], a
	call WaitForHBlank
Func_05_4586:
	push bc
	push de
Func_05_4588:
	ld a, e
	and $03
	call z, WaitForHBlank
	ld a, l
	ld [de], a
	inc de
	dec c
	jr nz, Func_05_4588
	pop de
	pop bc
	ld a, e
	add a, $20
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	dec b
	jr nz, Func_05_4586
	ret
SceneLoadTiles:
	ld a, [wSceneState]
	ld hl, SceneBgTilesetBank
	rst AddAToHL
	ld a, [hl]
	push af
	ld a, [wSceneState]
	add a, a
	ld hl, SceneBgTilesetSrc
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $8000
	ld bc, $1800
	pop af
	call CopyTilesToBothVramBanks
	ret
SceneLoadPalettes:
	ld a, [wSceneState]
	ld hl, ScenePaletteBank
	rst AddAToHL
	ld a, [hl]
	push af
	ld a, [wSceneState]
	add a, a
	ld hl, ScenePaletteSrc
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	pop af
	call LoadBgAndObjPalettesBanked
	ret

; --- Per-scene tables, indexed by wSceneState (the dispatch). Set up by
; SceneSetupTracks (script roots), SceneLoadTiles (BG tiles), SceneLoadPalettes (palettes). ---
ScenePaletteSrc:     ; $45da: BG+OBJ palette block ptr (SceneLoadPalettes -> LoadBgPalettes/LoadObjPalettes)
	dw TigerPalettes, MocchiPalettes, HarePalettes, GaliPalettes
	dw GolemPalettes, SuezoPalettes, PhenixPalettes, CapturePalettes
SceneBgTilesetSrc:      ; $45ea: BG tile source -> VRAM $8000; SceneLoadTiles/CopyTilesToBothVramBanks loads $1800 to bank0 then the next $1800 to bank1
	dw TigerTiles, MocchiTiles, HareTiles, GaliTiles
	dw GolemTiles, SuezoTiles, PhenixTiles, CaptureTiles
SceneBgTilesetBank:     ; $45fa: bank for the BG tile load
	db $08, $09, $07, $0b, $06, $0a, $0d, $0e
ScenePaletteBank:    ; $4602: bank of the palette block (also the metasprite-tile bank, Func_05_43db)
	db $08, $09, $07, $0b, $06, $0a, $0d, $0e
SceneDescBank:       ; $460a: per-scene bank the CopyBgMap descriptor is read from (SceneDrawBgMap -> b -> BankMapCopyInline)
	db $05, $09, $07, $0c, $06, $0a, $0c, $0e
SceneDrawBank:          ; $4612: per-scene metasprite bank -> wDrawBank (Func_05_44b4)
	db $08, $09, $07, $0b, $06, $0a, $0c, $0e
SceneBgScriptTable:     ; $461a: VM1 (BG track) script roots, by wSceneState
	dw Scene0_VM1, Scene1_VM1, Scene2_VM1, Scene3_VM1
	dw Scene4_VM1, Scene5_VM1, Scene6_VM1, Capture_VM1
SceneSprScriptTable:    ; $462a: VM2 (sprite track) script roots
	dw Scene0_VM2, Scene1_VM2, Scene2_VM2, Scene3_VM2
	dw Scene4_VM2, Scene5_VM2, Scene6_VM2, Capture_VM2

Func_05_463a:
	FAR_CALL ClearBossState
	call Func_05_4690
	call Func_05_4699
	ld a, $01
	ld [wActiveFloor], a
	ld a, $03
	ld [wGameSceneArg], a
	xor a
	ld [wCFF0], a
	ld [wCurrentFloor], a
	ld [wSilverKeys], a
	ld [wBattleCardPending], a
	ld [$cfed], a
	ld [$cfee], a
	ld [wDiscStoneFragments], a
	ld [wFreeDiscStones], a
	ld [$cfe8], a
	ld hl, wMonsterDiscStones
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
	ld hl, wMonsterUses
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
	ld a, $ff
	ld [wDisplayMonster], a
	FAR_CALL LoadFloorEditsFromSram
	ret
Func_05_4690:
	xor a
	ld hl, $cfe9
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
	ret
Func_05_4699:
	xor a
	ld [wItemsSeen], a
	ld [$cff5], a
	ld [$cff6], a
	ld [$cff7], a
	ld c, $4c
	ld hl, $d044
Func_05_46ab:
	ld [hl+], a
	ld [hl+], a
	dec c
	jr nz, Func_05_46ab
	ld c, $4c
	ld hl, $cff8
Func_05_46b5:
	ld [hl+], a
	dec c
	jr nz, Func_05_46b5
	ret
Func_05_46ba:
	ld hl, $c2ca
	ld de, $cfd6
	ld c, $05
Func_05_46c2:
	ld a, [de]
	swap a
	and $0f
	ld b, a
	ld a, [hl]
	swap a
	and $0f
	cp b
	ret c
	jr nz, Func_05_46e1
	ld a, [de]
	dec de
	and $0f
	ld b, a
	ld a, [hl-]
	and $0f
	cp b
	ret c
	jr nz, Func_05_46e1
	dec c
	jr nz, Func_05_46c2
	ret
Func_05_46e1:
	ld hl, wScore
	ld de, wHiScore
	ld c, $05
Func_05_46e9:
	ld a, [hl+]
	ld [de], a
	inc de
	dec c
	jr nz, Func_05_46e9
	ret
Func_05_46f0:
	ld a, [wRoomType]
	cp $05
	ret nz
	ld hl, $c2ae
	ld a, [wDiscStoneFragments]
	ld [hl+], a
	ld a, [wFreeDiscStones]
	ld [hl+], a
	ld a, [wDisplayMonster]
	ld [hl+], a
	ld de, wMonsterDiscStones
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	ld [hl+], a
	ld de, wMonsterUses
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	inc de
	ld [hl+], a
	ld a, [de]
	ld [hl+], a
	ld a, [$cfe8]
	ld [hl+], a
	ld a, $ff
	ld [wDisplayMonster], a
	ret
Func_05_473d:
	ld a, [wRoomType]
	cp $05
	ret nz
	ld hl, $c2ae
	ld a, [hl+]
	ld [wDiscStoneFragments], a
	ld a, [hl+]
	ld [wFreeDiscStones], a
	ld a, [hl+]
	ld [wDisplayMonster], a
	ld de, wMonsterDiscStones
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	ld de, wMonsterUses
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	ld a, [hl+]
	ld [$cfe8], a
	ret
; Tower-climb entry setups. Each resets the action-game run state (ResetRunState)
; with A -> $c2aa, then configures the starting room/floor:
;   SetupTowerClimb            new climb: floor 1, room type 0, mark progress flag
;   SetupTowerClimbResume      restore room type/floor from the saved slot ($cff1/wCFF0)
;   SetupTowerClimbFromBottom  floor 1, room type 1
; (all three are entered via Naji's tower-entrance handlers.)
SetupTowerClimb:
	ld a, $01
	call ResetRunState
	ld a, $01
	ld [$c2ab], a
	ld a, $00
	ld [wRoomType], a
	ld a, $01
	ld [wActiveFloor], a
	call InitProgressFlags
	ret
SetupTowerClimbResume:
	xor a
	call ResetRunState
	xor a
	ld [$c2ab], a
	ld a, [$cff1]
	ld [wRoomType], a
	ld a, [wCFF0]
	ld [wActiveFloor], a
	ret
SetupTowerClimbFromBottom:
	xor a
	call ResetRunState
	ld a, $01
	ld [$c2ab], a
	ld a, $01
	ld [wRoomType], a
	ld a, $01
	ld [wActiveFloor], a
	ret
; Generic fresh-run setup (no floor preset; caller sets it). Used by the level
; editor's test-play and the new-game paths in the home bank.
SetupNewRun:
	ld a, $01
	call ResetRunState
	ld a, $01
	ld [$c2ab], a
	call InitProgressFlags
	ret
; Reset the action-game run state: A -> $c2aa, then 3 lives, bomb capacity 3,
; $50 crystals, and clear score/bomb/battle-card state.
ResetRunState:
	ld [$c2aa], a
	ld a, $03
	ld [wLives], a
	ld a, $03
	ld [wBombCapacity], a
	ld a, $50
	ld [wCrystalCount], a
	xor a
	ld [$c2cf], a
	xor a
	ld [$c2c4], a
	ld [wBombLargeFlags], a
	ld [wBombCount], a
	ld [wHasBattleCard], a
	ld hl, wScore
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
	ret
Func_05_4800:
	ld a, [wRoomType]
	cp $01
	jr z, Func_05_4812
	ld a, [wActiveFloor]
	cp $3c
	ret z
	inc a
	ld [wActiveFloor], a
	ret
Func_05_4812:
	ld a, [wActiveFloor]
	cp $0a
	ret z
	inc a
	ld [wActiveFloor], a
	ret
Func_05_481d:
	ld a, [wRoomType]
	cp $01
	jr z, Func_05_4835
	cp $00
	ret nz
	ld a, [wActiveFloor]
	ld b, a
	ld a, [$cfed]
	cp b
	ret nc
	ld a, b
	ld [$cfed], a
	ret
Func_05_4835:
	ld a, [wActiveFloor]
	ld b, a
	ld a, [$cfee]
	cp b
	ret nc
	ld a, b
	ld [$cfee], a
	ret
Func_05_4843:
	FAR_CALL HasSavedGame
	ld [wScreenPhase], a
	or a
	jr z, Func_05_4865
	FAR_CALL LoadHiScoreFromSram
	or a
	jr z, Func_05_485f
	ld a, $01
	ret

Func_05_485f:
	call Func_05_486a
	ld a, $01
	ret

Func_05_4865:
	call Func_05_486a
	xor a
	ret
Func_05_486a:
	ld hl, wHiScore
	ld de, $487f
	ld a, [de]
	ld [hl+], a
	inc de
	ld a, [de]
	ld [hl+], a
	inc de
	ld a, [de]
	ld [hl+], a
	inc de
	ld a, [de]
	ld [hl+], a
	inc de
	ld a, [de]
	ld [hl], a
	ret

Data_05_487f:
	db $00, $00, $10, $00, $00

Func_05_4884:
	xor a
	ldh [rVBK], a
	ld hl, $9800
	ld bc, $0800
	ld d, $fc
	call FillVram
	ld a, $01
	ldh [rVBK], a
	ld hl, $9800
	ld bc, $0800
	ld d, $08
	call FillVram
	xor a
	ldh [rVBK], a
	ret
Func_05_48a5:
	FAR_CALL Func_10_4018
	FAR_CALL LoadEntityTiles
	FAR_CALL LoadTileset
	FAR_CALL SpecialScene_LoadGraphics
	call Func_05_48c9
	ret
Func_05_48c9:
	ld a, [wRoomType]
	cp $02
	jr nz, Func_05_48d9
	FAR_CALL LoadDungeonFloorTiles
	ret
Func_05_48d9:
	call Func_05_48dd
	ret
Func_05_48dd:
	ld de, wFloorMonsterSpecies
	ld c, $00
Func_05_48e2:
	ld a, [de]
	cp $ff
	jr z, Func_05_48f4
	ld b, a
	push bc
	push de
	FAR_CALL LoadFloorMonsterSpriteToSlot
	pop de
	pop bc
Func_05_48f4:
	inc de
	inc c
	ld a, c
	cp $04
	jr nz, Func_05_48e2
	ret
Func_05_48fc:
	FAR_CALL LoadEntityPalettes
	call Func_05_4918
	FAR_CALL LoadFloorBgPalette
	FAR_CALL SpecialScene_LoadTilemap
	ret
Func_05_4918:
	ld a, [wRoomType]
	cp $02
	jr nz, Func_05_4928
	FAR_CALL LoadDungeonFloorPalette
	ret
Func_05_4928:
	FAR_CALL LoadFloorMonsterSlotPalettes
	ret
Func_05_4931:
	ld a, [wRoomType]
	cp $02
	jr nz, Func_05_4956
	ld a, [wActiveFloor]
	cp $04
	jr nz, Func_05_4956
	ld a, [wFloorHeight]
	sub $0a
	swap a
	ld [$c55b], a
	ld a, [wFloorWidth]
	sub $0b
	swap a
	sub $08
	ld [$c55a], a
	ret
Func_05_4956:
	ld a, [wFloorHeight]
	sub $0a
	swap a
	ld [$c55b], a
	ld a, [wFloorWidth]
	sub $0b
	swap a
	ld [$c55a], a
	ret
Func_05_496b:
	ld a, [wHasBattleCard]
	or a
	ret nz
	ld hl, wFloorGrid
	ld a, [wFloorHeight]
	ld b, a
Func_05_4977:
	ld a, [wFloorWidth]
	ld c, a
	push hl
Func_05_497c:
	ld a, [hl]
	bit 7, a
	jr z, Func_05_4990
	set 6, a
	cp $dc
	jr z, Func_05_498d
	cp $df
	jr z, Func_05_498d
	jr Func_05_4990
Func_05_498d:
	res 6, a
	ld [hl], a
Func_05_4990:
	inc hl
	dec c
	jr nz, Func_05_497c
	pop hl
	ld de, $0011
	add hl, de
	dec b
	jr nz, Func_05_4977
	ret
Func_05_499d:
	ld a, [$c2aa]
	or a
	ret nz
	ld hl, wFloorGrid
	ld a, [wFloorHeight]
	ld b, a
Func_05_49a9:
	ld a, [wFloorWidth]
	ld c, a
	push hl
Func_05_49ae:
	ld a, [hl]
	bit 7, a
	jr z, Func_05_49bb
	set 6, a
	cp $db
	jr nz, Func_05_49bb
	xor a
	ld [hl], a
Func_05_49bb:
	inc hl
	dec c
	jr nz, Func_05_49ae
	pop hl
	ld de, $0011
	add hl, de
	dec b
	jr nz, Func_05_49a9
	ret
Func_05_49c8:
	ld hl, wFloorGrid
	ld a, [wFloorHeight]
	ld b, a
Func_05_49cf:
	ld a, [wFloorWidth]
	ld c, a
	push hl
Func_05_49d4:
	ld a, [hl]
	bit 7, a
	jr z, Func_05_49e2
	set 6, a
	cp $d6
	jr nz, Func_05_49e2
	res 6, a
	ld [hl], a
Func_05_49e2:
	inc hl
	dec c
	jr nz, Func_05_49d4
	pop hl
	ld de, $0011
	add hl, de
	dec b
	jr nz, Func_05_49cf
	ret
Func_05_49ef:
	ld a, [wRoomType]
	cp $01
	ret nz
	ld a, [wActiveFloor]
	cp $0a
	ret nz
	ld hl, wFloorGrid
	ld a, [wFloorHeight]
	ld b, a
FloorFillTiles:
	ld a, [wFloorWidth]
	ld c, a
	push hl
Func_05_4a07:
	ld a, [hl]
	cp $c0
	jr nz, Func_05_4a0f

FloorFillTiles_StampE3:           ; alt entry: stamp tile $e3, then fall into the fill loop
	ld a, $e3
	ld [hl], a

Func_05_4a0f:
	inc hl
	dec c
	jr nz, Func_05_4a07
	pop hl
	ld de, $0011
	add hl, de
	dec b
	jr nz, FloorFillTiles
	ret

; Floor/room-type setup stubs, dispatched via the bank-$04 jump table at $04:$4858
; ($4a1c $4a1e $4a26 $4a28 ...). Each writes wActiveFloor and/or wRoomType; the table
; also targets the store+ret tails mid-stub (e.g. $4a1e) to share code.
FloorRoomSetters:
	ld a, $0f
	ld [wActiveFloor], a
	ret
	ld a, $1e
	ld [wActiveFloor], a
	ret
	ld a, $02
	ld [wRoomType], a
	ld a, $01
	ld [wActiveFloor], a
	ret
	ld a, $02
	ld [wRoomType], a
	ld a, $02
	ld [wActiveFloor], a
	ret
	ld a, $02
	ld [wRoomType], a
	ld a, $03
	ld [wActiveFloor], a
	ret
	ld a, $02
	ld [wRoomType], a
	ld a, $04
	ld [wActiveFloor], a
	ret
	ld a, $02
	ld [wRoomType], a
	ld a, $05
	ld [wActiveFloor], a
	ret

Data_05_4a5f:
Scene0_VM1:
	SCENE_BG_DRAW   $70, $0060, $0000
	SCENE_BG_DRAW   $03, $0060, TigerFrame00
	SCENE_BG_DRAW   $03, $0060, TigerFrame01
	SCENE_BG_DRAW   $03, $0060, TigerFrame02
	SCENE_BG_DRAW   $03, $0060, TigerFrame03
	SCENE_BG_DRAW   $04, $0060, TigerFrame04
	SCENE_BG_DRAW   $0a, $0060, TigerFrame05
	SCENE_BG_DRAW   $08, $0060, TigerFrame06
	SCENE_BG_DRAW   $05, $0060, TigerFrame07
	SCENE_BG_DRAW   $05, $0060, TigerFrame08
	SCENE_BG_DRAW   $05, $0060, TigerFrame09
	SCENE_BG_DRAW   $05, $0060, TigerFrame07
	SCENE_BG_DRAW   $05, $0060, TigerFrame08
	SCENE_BG_DRAW   $05, $0060, TigerFrame09
	SCENE_BG_DRAW   $05, $0060, TigerFrame07
	SCENE_BG_DRAW   $05, $0060, TigerFrame08
	SCENE_BG_DRAW   $05, $0060, TigerFrame09
	SCENE_BG_DRAW   $05, $0060, TigerFrame07
	SCENE_BG_DRAW   $05, $0060, TigerFrame08
	SCENE_BG_DRAW   $05, $0060, TigerFrame09
	SCENE_BG_DRAW   $05, $0060, TigerFrame07
	SCENE_BG_DRAW   $05, $0060, TigerFrame08
	SCENE_BG_DRAW   $05, $0060, TigerFrame09
	SCENE_BG_DRAW   $05, $0060, TigerFrame07
	SCENE_BG_DRAW   $05, $0060, TigerFrame08
	SCENE_BG_DRAW   $05, $0060, TigerFrame09
	SCENE_BG_DRAW   $05, $0060, TigerFrame07
	SCENE_BG_DRAW   $05, $0060, TigerFrame08
	SCENE_BG_DRAW   $05, $0060, TigerFrame09
	SCENE_BG_DRAW   $05, $0060, TigerFrame07
	SCENE_BG_DRAW   $05, $0060, TigerFrame08
	SCENE_BG_DRAW   $05, $0060, TigerFrame09
	SCENE_BG_END
Scene0_VM2:
	SCENE_SPR_SHOW  $18, $30, $28, $4b47
	SCENE_SPR_SHOW  $06, $30, $28, $4b4d
	SCENE_SPR_SHOW  $48, $30, $28, $4b53
	SCENE_SPR_SOUND $12
	SCENE_SPR_SHOW  $06, $30, $28, $4b59
	SCENE_SPR_SHOW  $04, $30, $28, $4b5f
	SCENE_SPR_SHOW  $ff, $30, $28, $4b65

SECTION "analyzed_014b46", ROMX[$4b46], BANK[$05]

Data_05_4b46:
	SCENE_SPR_END

SECTION "analyzed_014b47", ROMX[$4b47], BANK[$05]

Data_05_4b47:
	SCENE_SPRITE_LIST TigerSprite01, TigerSprite00
	SCENE_SPRITE_LIST TigerSprite03, TigerSprite02
	SCENE_SPRITE_LIST TigerSprite05, TigerSprite04
	SCENE_SPRITE_LIST TigerSprite07, TigerSprite06
	SCENE_SPRITE_LIST TigerSprite09, TigerSprite08
	SCENE_SPRITE_LIST TigerSprite11, TigerSprite10
Scene1_VM1:
	SCENE_BG_DRAW   $68, $0060, $0000
	SCENE_BG_SOUND  $17
	SCENE_BG_DRAW   $01, $0060, MocchiFrame00
	SCENE_BG_DRAW   $07, $0060, MocchiFrame00
	SCENE_BG_ROW    $08, $4080, $01, $03
	SCENE_BG_ROW    $08, $4098, $01, $03
	SCENE_BG_ROW    $08, $40b0, $01, $03
	SCENE_BG_ROW    $08, $40c8, $01, $03
	SCENE_BG_ROW    $08, $40e0, $01, $03
	SCENE_BG_ROW    $08, $40f8, $01, $03
	SCENE_BG_ROW    $08, $4110, $01, $03
	SCENE_BG_ROW    $08, $4128, $01, $03
	SCENE_BG_ROW    $30, $4140, $01, $03
	SCENE_BG_END
Scene1_VM2:
	SCENE_SPR_SHOW  $38, $38, $28, $4be3
	SCENE_SPR_SOUND $16
	SCENE_SPR_SHOW  $10, $38, $28, $4be9
	SCENE_SPR_SHOW  $06, $38, $28, $4bef
	SCENE_SPR_SHOW  $06, $38, $20, $4bef
	SCENE_SPR_SHOW  $06, $38, $20, $4bf5
	SCENE_SPR_SHOW  $06, $38, $20, $4bfb
	SCENE_SPR_SHOW  $ff, $38, $20, $4c01

SECTION "analyzed_014be2", ROMX[$4be2], BANK[$05]

Data_05_4be2:
	SCENE_SPR_END

SECTION "analyzed_014be3", ROMX[$4be3], BANK[$05]

Data_05_4be3:
	SCENE_SPRITE_LIST MocchiSprite01, MocchiSprite00
	SCENE_SPRITE_LIST MocchiSprite03, MocchiSprite02
	SCENE_SPRITE_LIST MocchiSprite05, MocchiSprite04
	SCENE_SPRITE_LIST MocchiSprite07, MocchiSprite06
	SCENE_SPRITE_LIST MocchiSprite09, MocchiSprite08
	SCENE_SPRITE_LIST MocchiSprite11, MocchiSprite10
Scene2_VM1:
	SCENE_BG_DRAW   $01, $0060, HareFrame00
	SCENE_BG_DRAW   $ff, $0060, HareFrame00

SECTION "analyzed_014c13", ROMX[$4c13], BANK[$05]

Func_05_4c13:
	SCENE_BG_END

SECTION "analyzed_014c14", ROMX[$4c14], BANK[$05]

Data_05_4c14:
Scene2_VM2:
	SCENE_SPR_SOUND $18
	SCENE_SPR_SHOW  $40, $00, $00, $0000
	SCENE_SPR_SOUND $19
	SCENE_SPR_SHOW  $02, $08, $30, $4cf7
	SCENE_SPR_SHOW  $02, $00, $28, $4cf7
	SCENE_SPR_SHOW  $02, $08, $30, $4cf7
	SCENE_SPR_SHOW  $02, $10, $38, $4cf7
	SCENE_SPR_SHOW  $20, $08, $30, $4cf1
	SCENE_SPR_SHOW  $01, $08, $30, $4cf7
	SCENE_SPR_SHOW  $01, $00, $28, $4cf7
	SCENE_SPR_SHOW  $01, $08, $30, $4cf7
	SCENE_SPR_SHOW  $01, $10, $38, $4cf7
	SCENE_SPR_SHOW  $38, $00, $00, $0000
	SCENE_SPR_SOUND $18
	SCENE_SPR_SHOW  $01, $70, $38, $4cff
	SCENE_SPR_SHOW  $01, $70, $30, $4cff
	SCENE_SPR_SHOW  $01, $70, $38, $4cff
	SCENE_SPR_SHOW  $01, $70, $40, $4cff
	SCENE_SPR_SHOW  $01, $70, $38, $4cff
	SCENE_SPR_SHOW  $18, $70, $38, $4cfb
	SCENE_SPR_SOUND $19
	SCENE_SPR_SHOW  $01, $70, $38, $4cff
	SCENE_SPR_SHOW  $01, $70, $30, $4cff
	SCENE_SPR_SHOW  $01, $70, $38, $4cff
	SCENE_SPR_SHOW  $01, $70, $40, $4cff
	SCENE_SPR_SHOW  $01, $70, $38, $4cff
	SCENE_SPR_SHOW  $38, $00, $00, $0000
	SCENE_SPR_SHOW  $01, $38, $18, $4d09
	SCENE_SPR_SHOW  $01, $30, $20, $4d09
	SCENE_SPR_SHOW  $01, $28, $28, $4d09
	SCENE_SPR_SHOW  $01, $30, $20, $4d09
	SCENE_SPR_SHOW  $28, $30, $20, $4d03
	SCENE_SPR_SOUND $19
	SCENE_SPR_SHOW  $01, $38, $18, $4d09
	SCENE_SPR_SHOW  $01, $30, $20, $4d09
	SCENE_SPR_SHOW  $01, $28, $28, $4d09
	SCENE_SPR_SHOW  $01, $30, $20, $4d09
	SCENE_SPR_SHOW  $01, $38, $18, $4d09
	SCENE_SPR_SHOW  $01, $30, $20, $4d09
	SCENE_SPR_SHOW  $38, $00, $00, $0000
	SCENE_SPR_END
	SCENE_SPRITE_LIST HareSprite01, HareSprite00
	SCENE_SPRITE_LIST HareSprite02
	SCENE_SPRITE_LIST HareSprite03
	SCENE_SPRITE_LIST HareSprite04
	SCENE_SPRITE_LIST HareSprite06, HareSprite05
	SCENE_SPRITE_LIST HareSprite07

; --- Scene 4 (wSceneState==4): BG track, root from $05:$461A[4] ($4622) ---
Scene4_VM1:
	SCENE_BG_DRAW   $30, $0060, $0000
	SCENE_BG_WOBBLE_ON
	SCENE_BG_DRAW   $0c, $0060, GolemFrame00
	SCENE_BG_DRAW   $18, $0060, GolemFrame01
	SCENE_BG_DRAW   $0c, $0060, GolemFrame02
	SCENE_BG_DRAW   $20, $0060, GolemFrame03
	SCENE_BG_DRAW   $20, $0060, GolemFrame04
	SCENE_BG_DRAW   $18, $0060, GolemFrame05
	SCENE_BG_DRAW   $40, $0060, GolemFrame06
	SCENE_BG_END

; --- Scene 4: sprite track, root from $05:$462A[4] ($4632) ---
Scene4_VM2:
	SCENE_SPR_SHOW  $28, $30, $20, $4d54
	SCENE_SPR_SHOW  $04, $30, $20, $4d58
	SCENE_SPR_SOUND $15
	SCENE_SPR_SHOW  $ff, $30, $20, $4d5c
	SCENE_SPR_END

SECTION "analyzed_014d54", ROMX[$4d54], BANK[$05]

Data_05_4d54:
	SCENE_SPRITE_LIST GolemSprite00
	SCENE_SPRITE_LIST GolemSprite01
	SCENE_SPRITE_LIST GolemSprite02
Scene5_VM1:
	SCENE_BG_DRAW   $72, $0060, $0000
	SCENE_BG_SOUND  $01
	SCENE_BG_DRAW   $08, $00ca, SuezoFrame00
	SCENE_BG_DRAW   $06, $00ca, SuezoFrame01
	SCENE_BG_DRAW   $06, $00ca, SuezoFrame02
	SCENE_BG_DRAW   $06, $00ca, SuezoFrame03
	SCENE_BG_DRAW   $08, $00ca, SuezoFrame04
	SCENE_BG_DRAW   $04, $00ca, SuezoFrame05
	SCENE_BG_DRAW   $04, $00ca, SuezoFrame06
	SCENE_BG_SOUND  $01
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $06, $0085, SuezoFrame07
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $06, $0085, SuezoFrame08
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $06, $0085, SuezoFrame09
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $06, $0085, SuezoFrame10
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $04, $0085, SuezoFrame11
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $04, $0085, SuezoFrame12
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $10, $0085, SuezoFrame13
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $00, $0085, SuezoFrame13
	SCENE_BG_DRAW   $04, $0061, SuezoFrame20
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $00, $0085, SuezoFrame13
	SCENE_BG_DRAW   $00, $0061, SuezoFrame21
	SCENE_BG_DRAW   $04, $0161, SuezoFrame14
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $00, $0085, SuezoFrame13
	SCENE_BG_DRAW   $00, $0061, SuezoFrame22
	SCENE_BG_DRAW   $04, $0161, SuezoFrame15
	SCENE_BG_SOUND  $02
	SCENE_BG_ROW    $00, $4080, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $00, $0085, SuezoFrame13
	SCENE_BG_DRAW   $00, $0061, SuezoFrame23
	SCENE_BG_DRAW   $04, $0161, SuezoFrame16
	SCENE_BG_ROW    $00, $4088, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $00, $0085, SuezoFrame13
	SCENE_BG_DRAW   $00, $0061, SuezoFrame24
	SCENE_BG_DRAW   $04, $0161, SuezoFrame16
	SCENE_BG_ROW    $00, $4080, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $00, $0085, SuezoFrame13
	SCENE_BG_DRAW   $00, $0061, SuezoFrame25
	SCENE_BG_DRAW   $04, $0161, SuezoFrame17
	SCENE_BG_ROW    $00, $4088, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $00, $0085, SuezoFrame13
	SCENE_BG_DRAW   $00, $0061, SuezoFrame26
	SCENE_BG_DRAW   $04, $0161, SuezoFrame17
	SCENE_BG_SOUND  $02
	SCENE_BG_ROW    $00, $4080, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $00, $0085, SuezoFrame13
	SCENE_BG_DRAW   $00, $0061, SuezoFrame23
	SCENE_BG_DRAW   $04, $0161, SuezoFrame18
	SCENE_BG_ROW    $00, $4088, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $00, $0085, SuezoFrame13
	SCENE_BG_DRAW   $00, $0061, SuezoFrame24
	SCENE_BG_DRAW   $04, $0161, SuezoFrame16
	SCENE_BG_ROW    $00, $4080, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $00, $0085, SuezoFrame13
	SCENE_BG_DRAW   $00, $0061, SuezoFrame25
	SCENE_BG_DRAW   $04, $0161, SuezoFrame17
	SCENE_BG_ROW    $00, $4088, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $00, $0085, SuezoFrame13
	SCENE_BG_DRAW   $00, $0061, SuezoFrame26
	SCENE_BG_DRAW   $04, $0161, SuezoFrame17
	SCENE_BG_SOUND  $02
	SCENE_BG_ROW    $00, $4080, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $00, $0085, SuezoFrame13
	SCENE_BG_DRAW   $00, $0061, SuezoFrame23
	SCENE_BG_DRAW   $04, $0161, SuezoFrame16
	SCENE_BG_ROW    $00, $4088, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $00, $0085, SuezoFrame13
	SCENE_BG_DRAW   $00, $0061, SuezoFrame24
	SCENE_BG_DRAW   $04, $0161, SuezoFrame16
	SCENE_BG_ROW    $00, $4080, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $00, $0085, SuezoFrame13
	SCENE_BG_DRAW   $00, $0061, SuezoFrame25
	SCENE_BG_DRAW   $04, $0161, SuezoFrame17
	SCENE_BG_ROW    $00, $4088, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $00, $0085, SuezoFrame13
	SCENE_BG_DRAW   $00, $0061, SuezoFrame26
	SCENE_BG_DRAW   $04, $0161, SuezoFrame17
	SCENE_BG_SOUND  $02
	SCENE_BG_ROW    $00, $4080, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $00, $0085, SuezoFrame13
	SCENE_BG_DRAW   $00, $0061, SuezoFrame23
	SCENE_BG_DRAW   $04, $0161, SuezoFrame18
	SCENE_BG_ROW    $00, $4088, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $00, $0085, SuezoFrame13
	SCENE_BG_DRAW   $00, $0061, SuezoFrame24
	SCENE_BG_DRAW   $04, $0161, SuezoFrame16
	SCENE_BG_ROW    $00, $4080, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $00, $0085, SuezoFrame13
	SCENE_BG_DRAW   $00, $0061, SuezoFrame25
	SCENE_BG_DRAW   $04, $0161, SuezoFrame17
	SCENE_BG_ROW    $00, $4088, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoFrame06
	SCENE_BG_DRAW   $00, $0085, SuezoFrame13
	SCENE_BG_DRAW   $00, $0061, SuezoFrame26
	SCENE_BG_DRAW   $04, $0161, SuezoFrame17
	SCENE_BG_END
Scene5_VM2:
	SCENE_SPR_SHOW  $08, $70, $30, $5058
	SCENE_SPR_SOUND $1a
	SCENE_SPR_SHOW  $06, $70, $30, $5064
	SCENE_SPR_SHOW  $08, $70, $30, $505e
	SCENE_SPR_SHOW  $06, $70, $30, $5064
	SCENE_SPR_SHOW  $08, $70, $30, $5058
	SCENE_SPR_SHOW  $06, $70, $30, $5064
	SCENE_SPR_SHOW  $08, $70, $30, $506a
	SCENE_SPR_SHOW  $20, $70, $30, $5064
	SCENE_SPR_SHOW  $08, $70, $30, $506e
	SCENE_SPR_SHOW  $08, $70, $30, $5074
	SCENE_SPR_SHOW  $ff, $70, $30, $507a

SECTION "analyzed_015057", ROMX[$5057], BANK[$05]

Data_05_5057:
	SCENE_SPR_END

SECTION "analyzed_015058", ROMX[$5058], BANK[$05]

Data_05_5058:
	SCENE_SPRITE_LIST SuezoSprite01, SuezoSprite00
	SCENE_SPRITE_LIST SuezoSprite03, SuezoSprite02
	SCENE_SPRITE_LIST SuezoSprite05, SuezoSprite04
	SCENE_SPRITE_LIST SuezoSprite06
	SCENE_SPRITE_LIST SuezoSprite08, SuezoSprite07
	SCENE_SPRITE_LIST SuezoSprite10, SuezoSprite09
	SCENE_SPRITE_LIST SuezoSprite12, SuezoSprite11
Scene3_VM1:
	SCENE_BG_DRAW   $72, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0065, GaliFrame00
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $03, $0060, $0000
	SCENE_BG_SOUND  $1c
	SCENE_BG_SCROLL $fc
	SCENE_BG_DRAW   $05, $0060, GaliFrame01
	SCENE_BG_DRAW   $05, $0060, GaliFrame02
	SCENE_BG_DRAW   $05, $0060, GaliFrame03
	SCENE_BG_DRAW   $05, $0060, GaliFrame04
	SCENE_BG_DRAW   $05, $0060, GaliFrame05
	SCENE_BG_DRAW   $05, $0060, GaliFrame06
	SCENE_BG_DRAW   $05, $0060, GaliFrame07
	SCENE_BG_DRAW   $05, $0060, GaliFrame08
	SCENE_BG_DRAW   $05, $0060, GaliFrame09
	SCENE_BG_DRAW   $05, $0060, GaliFrame10
	SCENE_BG_DRAW   $05, $0060, GaliFrame11
	SCENE_BG_DRAW   $05, $0060, GaliFrame12
	SCENE_BG_DRAW   $05, $0060, GaliFrame01
	SCENE_BG_DRAW   $05, $0060, GaliFrame02
	SCENE_BG_DRAW   $05, $0060, GaliFrame03
	SCENE_BG_DRAW   $05, $0060, GaliFrame04
	SCENE_BG_DRAW   $05, $0060, GaliFrame05
	SCENE_BG_DRAW   $05, $0060, GaliFrame06
	SCENE_BG_DRAW   $05, $0060, GaliFrame07
	SCENE_BG_DRAW   $05, $0060, GaliFrame08
	SCENE_BG_DRAW   $05, $0060, GaliFrame09
	SCENE_BG_DRAW   $05, $0060, GaliFrame10
	SCENE_BG_DRAW   $05, $0060, GaliFrame11
	SCENE_BG_DRAW   $05, $0060, GaliFrame12
	SCENE_BG_SCROLL $fd
	SCENE_BG_DRAW   $06, $0060, GaliFrame01
	SCENE_BG_DRAW   $06, $0060, GaliFrame02
	SCENE_BG_DRAW   $06, $0060, GaliFrame03
	SCENE_BG_DRAW   $06, $0060, GaliFrame04
	SCENE_BG_DRAW   $06, $0060, GaliFrame05
	SCENE_BG_DRAW   $06, $0060, GaliFrame06
	SCENE_BG_DRAW   $06, $0060, GaliFrame07
	SCENE_BG_DRAW   $06, $0060, GaliFrame08
	SCENE_BG_DRAW   $06, $0060, GaliFrame09
	SCENE_BG_DRAW   $06, $0060, GaliFrame10
	SCENE_BG_DRAW   $06, $0060, GaliFrame11
	SCENE_BG_DRAW   $06, $0060, GaliFrame12
	SCENE_BG_DRAW   $06, $0060, GaliFrame01
	SCENE_BG_DRAW   $06, $0060, GaliFrame02
	SCENE_BG_DRAW   $06, $0060, GaliFrame03
	SCENE_BG_DRAW   $06, $0060, GaliFrame04
	SCENE_BG_DRAW   $06, $0060, GaliFrame05
	SCENE_BG_DRAW   $06, $0060, GaliFrame06
	SCENE_BG_DRAW   $06, $0060, GaliFrame07
	SCENE_BG_DRAW   $06, $0060, GaliFrame08
	SCENE_BG_DRAW   $06, $0060, GaliFrame09
	SCENE_BG_DRAW   $06, $0060, GaliFrame10
	SCENE_BG_DRAW   $06, $0060, GaliFrame11
	SCENE_BG_DRAW   $06, $0060, GaliFrame12
	SCENE_BG_SCROLL $fe
	SCENE_BG_DRAW   $07, $0060, GaliFrame01
	SCENE_BG_DRAW   $07, $0060, GaliFrame02
	SCENE_BG_DRAW   $07, $0060, GaliFrame03
	SCENE_BG_DRAW   $07, $0060, GaliFrame04
	SCENE_BG_DRAW   $07, $0060, GaliFrame05
	SCENE_BG_DRAW   $07, $0060, GaliFrame06
	SCENE_BG_DRAW   $07, $0060, GaliFrame07
	SCENE_BG_DRAW   $07, $0060, GaliFrame08
	SCENE_BG_DRAW   $07, $0060, GaliFrame09
	SCENE_BG_DRAW   $07, $0060, GaliFrame10
	SCENE_BG_DRAW   $07, $0060, GaliFrame11
	SCENE_BG_DRAW   $07, $0060, GaliFrame12
	SCENE_BG_SCROLL $ff
	SCENE_BG_DRAW   $08, $0060, GaliFrame01
	SCENE_BG_DRAW   $08, $0060, GaliFrame02
	SCENE_BG_DRAW   $08, $0060, GaliFrame03
	SCENE_BG_DRAW   $08, $0060, GaliFrame04
	SCENE_BG_DRAW   $08, $0060, GaliFrame05
	SCENE_BG_DRAW   $08, $0060, GaliFrame06
	SCENE_BG_DRAW   $08, $0060, GaliFrame07
	SCENE_BG_DRAW   $08, $0060, GaliFrame08
	SCENE_BG_DRAW   $08, $0060, GaliFrame09
	SCENE_BG_DRAW   $08, $0060, GaliFrame10
	SCENE_BG_DRAW   $08, $0060, GaliFrame11
	SCENE_BG_SCROLL $00
	SCENE_BG_SOUND  $00
	SCENE_BG_DRAW   $30, $0060, GaliFrame12
	SCENE_BG_END
Scene3_VM2:
	SCENE_SPR_SOUND $18
	SCENE_SPR_SHOW  $08, $30, $28, $5402
	SCENE_SPR_SHOW  $08, $30, $28, $5408
	SCENE_SPR_SHOW  $08, $30, $28, $540e
	SCENE_SPR_SHOW  $08, $30, $28, $5402
	SCENE_SPR_SHOW  $08, $30, $28, $5408
	SCENE_SPR_SHOW  $08, $30, $28, $540e
	SCENE_SPR_SHOW  $08, $30, $28, $5402
	SCENE_SPR_SHOW  $08, $30, $28, $5408
	SCENE_SPR_SHOW  $08, $30, $28, $540e
	SCENE_SPR_SHOW  $20, $30, $28, $5414
	SCENE_SPR_SHOW  $04, $30, $28, $5402
	SCENE_SPR_SHOW  $06, $30, $28, $541a
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $541a
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $0000
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $541a
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $0000
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $541a
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $0000
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $541a
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $0000
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $541a
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $0000
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $541a
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $0000
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $541a
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $0000
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $541a
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $0000
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $541a
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $0000
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $541a
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $0000
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $541a
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $0000
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $541a
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $06, $30, $28, $0000
	SCENE_SPR_SOUND $03
	SCENE_SPR_SHOW  $03, $30, $28, $541a
	SCENE_SPR_SHOW  $06, $30, $28, $5420
	SCENE_SPR_SHOW  $06, $30, $28, $5426
	SCENE_SPR_SHOW  $06, $30, $28, $541a
	SCENE_SPR_JUMP  $53ed
	SCENE_SPRITE_LIST GaliSprite01, GaliSprite00
	SCENE_SPRITE_LIST GaliSprite03, GaliSprite02
	SCENE_SPRITE_LIST GaliSprite05, GaliSprite04
	SCENE_SPRITE_LIST GaliSprite07, GaliSprite06
	SCENE_SPRITE_LIST GaliSprite09, GaliSprite08
	SCENE_SPRITE_LIST GaliSprite11, GaliSprite10
	SCENE_SPRITE_LIST GaliSprite13, GaliSprite12
Scene6_VM1:
	SCENE_BG_DRAW   $5a, $0060, $0000
	SCENE_BG_DRAW   $04, $0060, PhenixFrame08
	SCENE_BG_DRAW   $04, $0060, PhenixFrame09
	SCENE_BG_DRAW   $48, $0060, PhenixFrame00
	SCENE_BG_DRAW   $04, $0060, PhenixFrame01
	SCENE_BG_DRAW   $04, $0060, PhenixFrame02
	SCENE_BG_SOUND  $13
	SCENE_BG_DRAW   $04, $0060, PhenixFrame03
	SCENE_BG_DRAW   $06, $0060, PhenixFrame04
	SCENE_BG_DRAW   $06, $0060, PhenixFrame05
	SCENE_BG_DRAW   $38, $0060, PhenixFrame06
	SCENE_BG_SOUND  $12
	SCENE_BG_ROW    $04, $4080, $01, $01
	SCENE_BG_ROW    $04, $4088, $01, $01
	SCENE_BG_ROW    $04, $4080, $01, $01
	SCENE_BG_ROW    $04, $4088, $01, $01
	SCENE_BG_ROW    $04, $4080, $01, $01
	SCENE_BG_ROW    $04, $4088, $01, $01
	SCENE_BG_ROW    $04, $4080, $01, $01
	SCENE_BG_ROW    $04, $4088, $01, $01
	SCENE_BG_ROW    $04, $4080, $01, $01
	SCENE_BG_ROW    $04, $4088, $01, $01
	SCENE_BG_ROW    $04, $4080, $01, $01
	SCENE_BG_ROW    $04, $4088, $01, $01
	SCENE_BG_ROW    $04, $4080, $01, $01
	SCENE_BG_ROW    $04, $4088, $01, $01
	SCENE_BG_ROW    $04, $4080, $01, $01
	SCENE_BG_ROW    $04, $4088, $01, $01
	SCENE_BG_END
Scene6_VM2:
	SCENE_SPR_SOUND $1e
	SCENE_SPR_SHOW  $04, $48, $20, $5588
	SCENE_SPR_SHOW  $04, $48, $38, $5588
	SCENE_SPR_SHOW  $06, $48, $48, $5588
	SCENE_SPR_SHOW  $06, $40, $60, $558c
	SCENE_SPR_SHOW  $06, $38, $60, $5590
	SCENE_SPR_SHOW  $06, $28, $58, $5594
	SCENE_SPR_SHOW  $06, $28, $58, $5598
	SCENE_SPR_SHOW  $06, $28, $58, $559c
	SCENE_SPR_SHOW  $18, $00, $00, $0000
	SCENE_SPR_SOUND $17
	SCENE_SPR_LOOP_ON
	SCENE_SPR_SHOW  $04, $40, $20, $55a0
	SCENE_SPR_SHOW  $06, $40, $20, $55a4
	SCENE_SPR_SHOW  $06, $40, $20, $55a8
	SCENE_SPR_SHOW  $06, $40, $20, $55ac
	SCENE_SPR_SHOW  $06, $40, $20, $55b0
	SCENE_SPR_SHOW  $06, $40, $20, $55a8
	SCENE_SPR_SHOW  $06, $40, $20, $55ac
	SCENE_SPR_SHOW  $06, $40, $20, $55b0
	SCENE_SPR_SHOW  $06, $40, $20, $55a8
	SCENE_SPR_SHOW  $06, $40, $20, $55ac
	SCENE_SPR_SHOW  $06, $40, $20, $55b0
	SCENE_SPR_SHOW  $06, $40, $20, $55a8
	SCENE_SPR_SHOW  $06, $40, $20, $55ac
	SCENE_SPR_SHOW  $06, $40, $20, $55b0
	SCENE_SPR_SHOW  $06, $40, $20, $55a8
	SCENE_SPR_SHOW  $06, $40, $20, $55ac
	SCENE_SPR_SHOW  $06, $40, $20, $55b0
	SCENE_SPR_LOOP_OFF
	SCENE_SPR_SHOW  $04, $00, $00, $55b4
	SCENE_SPR_SHOW  $04, $00, $00, $55b8
	SCENE_SPR_SHOW  $04, $00, $00, $55bc
	SCENE_SPR_SHOW  $ff, $00, $00, $0000

SECTION "analyzed_015587", ROMX[$5587], BANK[$05]

Data_05_5587:
	SCENE_SPR_END

SECTION "analyzed_015588", ROMX[$5588], BANK[$05]

Data_05_5588:
	SCENE_SPRITE_LIST PhenixSprite00
	SCENE_SPRITE_LIST PhenixSprite01
	SCENE_SPRITE_LIST PhenixSprite02
	SCENE_SPRITE_LIST PhenixSprite03
	SCENE_SPRITE_LIST PhenixSprite04
	SCENE_SPRITE_LIST PhenixSprite05
	SCENE_SPRITE_LIST PhenixSprite06
	SCENE_SPRITE_LIST PhenixSprite07
	SCENE_SPRITE_LIST PhenixSprite08
	SCENE_SPRITE_LIST PhenixSprite09
	SCENE_SPRITE_LIST PhenixSprite10
	SCENE_SPRITE_LIST PhenixSprite11
	SCENE_SPRITE_LIST PhenixSprite12
	SCENE_SPRITE_LIST PhenixSprite13
Capture_VM1:
	SCENE_BG_DRAW   $02, $0188, CaptureFrame00
	SCENE_BG_DRAW   $1e, $0188, CaptureFrame00
	SCENE_BG_DRAW   $38, $0000, $0000
	SCENE_BG_DRAW   $08, $0000, $0000
	SCENE_BG_DRAW   $06, $0000, $0000
	SCENE_BG_DRAW   $04, $0000, $0000
	SCENE_BG_DRAW   $04, $0000, $0000
	SCENE_BG_DRAW   $04, $0000, $0000
	SCENE_BG_DRAW   $48, $0000, $0000
	SCENE_BG_FLIP
	SCENE_BG_FLIP
	SCENE_BG_DRAW   $04, $0000, $0000
	SCENE_BG_DRAW   $08, $0000, $0000
	SCENE_BG_DRAW   $08, $0000, $0000
	SCENE_BG_DRAW   $30, $0000, $0000
	SCENE_BG_DRAW   $0c, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $07, $0000, $0000
	SCENE_BG_DRAW   $01, $0000, $0000
	SCENE_BG_DRAW   $04, $00a6, CaptureFrame01
	SCENE_BG_DRAW   $04, $00a6, CaptureFrame01
	SCENE_BG_ROW    $08, $70b0, $02, $01
	SCENE_BG_ROW    $08, $70b8, $02, $01
	SCENE_BG_ROW    $08, $70c0, $02, $01
	SCENE_BG_ROW    $08, $70c8, $02, $01
	SCENE_BG_SOUND  $0d
	SCENE_BG_ROW    $48, $7080, $02, $01
	SCENE_BG_END
Capture_VM2:
	SCENE_SPR_SOUND $06
	SCENE_SPR_SHOW  $20, $00, $00, $0000
	SCENE_SPR_SOUND $0f
	SCENE_SPR_MOVE  $40, $e0, $40, $18, $00, $01, $6e, $59
	SCENE_SPR_STEP
	SCENE_SPR_SOUND $10
	SCENE_SPR_SHOW  $08, $30, $50, $5972
	SCENE_SPR_SHOW  $06, $38, $20, $5976
	SCENE_SPR_SHOW  $04, $38, $20, $597a
	SCENE_SPR_SHOW  $04, $38, $20, $597e
	SCENE_SPR_SHOW  $04, $38, $20, $5982
	SCENE_SPR_SHOW  $48, $00, $00, $0000
	SCENE_SPR_SHOW  $04, $40, $50, $5986
	SCENE_SPR_SHOW  $08, $40, $50, $598a
	SCENE_SPR_SHOW  $08, $40, $50, $598e
	SCENE_SPR_SHOW  $30, $40, $50, $5992
	SCENE_SPR_MOVE  $40, $50, $40, $38, $00, $fe, $92, $59
	SCENE_SPR_STEP
	SCENE_SPR_SOUND $20
	SCENE_SPR_SHOW  $07, $40, $38, $5992
	SCENE_SPR_SHOW  $07, $40, $38, $5996
	SCENE_SPR_SHOW  $07, $40, $38, $599a
	SCENE_SPR_SHOW  $07, $40, $38, $599e
	SCENE_SPR_SHOW  $07, $40, $38, $59a2
	SCENE_SPR_SHOW  $07, $40, $38, $59a6
	SCENE_SPR_SHOW  $07, $40, $38, $59aa
	SCENE_SPR_SHOW  $07, $40, $38, $59ae
	SCENE_SPR_SHOW  $07, $40, $38, $5992
	SCENE_SPR_SHOW  $07, $40, $38, $5996
	SCENE_SPR_SHOW  $07, $40, $38, $599a
	SCENE_SPR_SHOW  $07, $40, $38, $599e
	SCENE_SPR_SHOW  $07, $40, $38, $59a2
	SCENE_SPR_SHOW  $07, $40, $38, $59a6
	SCENE_SPR_SHOW  $07, $40, $38, $59aa
	SCENE_SPR_SHOW  $07, $40, $38, $59ae
	SCENE_SPR_ANIM  $00, $7088, $01, $01
	SCENE_SPR_SHOW  $07, $40, $38, $5992
	SCENE_SPR_SHOW  $07, $40, $38, $5996
	SCENE_SPR_SHOW  $07, $40, $38, $599a
	SCENE_SPR_SHOW  $07, $40, $38, $599e
	SCENE_SPR_SHOW  $07, $40, $38, $59a2
	SCENE_SPR_SHOW  $07, $40, $38, $59a6
	SCENE_SPR_SHOW  $07, $40, $38, $59aa
	SCENE_SPR_SHOW  $07, $40, $38, $59ae
	SCENE_SPR_ANIM  $00, $7090, $01, $01
	SCENE_SPR_SHOW  $07, $40, $38, $5992
	SCENE_SPR_SHOW  $07, $40, $38, $5996
	SCENE_SPR_SHOW  $07, $40, $38, $599a
	SCENE_SPR_SHOW  $07, $40, $38, $599e
	SCENE_SPR_SHOW  $07, $40, $38, $59a2
	SCENE_SPR_SHOW  $07, $40, $38, $59a6
	SCENE_SPR_SHOW  $07, $40, $38, $59aa
	SCENE_SPR_SHOW  $07, $40, $38, $59ae
	SCENE_SPR_ANIM  $00, $7098, $01, $01
	SCENE_SPR_SHOW  $07, $40, $38, $5992
	SCENE_SPR_SHOW  $07, $40, $38, $5996
	SCENE_SPR_SHOW  $07, $40, $38, $599a
	SCENE_SPR_SHOW  $07, $40, $38, $599e
	SCENE_SPR_SHOW  $07, $40, $38, $59a2
	SCENE_SPR_SHOW  $07, $40, $38, $59a6
	SCENE_SPR_SHOW  $07, $40, $38, $59aa
	SCENE_SPR_SHOW  $07, $40, $38, $59ae
	SCENE_SPR_ANIM  $00, $70a0, $01, $01
	SCENE_SPR_SHOW  $07, $40, $38, $5992
	SCENE_SPR_SHOW  $07, $40, $38, $5996
	SCENE_SPR_SHOW  $07, $40, $38, $599a
	SCENE_SPR_SHOW  $07, $40, $38, $599e
	SCENE_SPR_SHOW  $07, $40, $38, $59a2
	SCENE_SPR_SHOW  $07, $40, $38, $59a6
	SCENE_SPR_SHOW  $07, $40, $38, $59aa
	SCENE_SPR_SHOW  $07, $40, $38, $59ae
	SCENE_SPR_ANIM  $00, $70a8, $01, $01
	SCENE_SPR_SHOW  $07, $40, $38, $5992
	SCENE_SPR_SHOW  $07, $40, $38, $5996
	SCENE_SPR_SHOW  $07, $40, $38, $599a
	SCENE_SPR_SHOW  $07, $40, $38, $599e
	SCENE_SPR_SHOW  $07, $40, $38, $59a2
	SCENE_SPR_SHOW  $07, $40, $38, $59a6
	SCENE_SPR_SHOW  $07, $40, $38, $59aa
	SCENE_SPR_SHOW  $07, $40, $38, $59ae
	SCENE_SPR_SOUND $00
	SCENE_SPR_SHOW  $ff, $40, $38, $5992

SECTION "analyzed_01596d", ROMX[$596d], BANK[$05]

Data_05_596d:
	SCENE_SPR_END

SECTION "analyzed_01596e", ROMX[$596e], BANK[$05]

Data_05_596e:
	db $6c, $71, $00, $00
	SCENE_SPRITE_LIST CaptureSprite01
	SCENE_SPRITE_LIST CaptureSprite02
	SCENE_SPRITE_LIST CaptureSprite03
	SCENE_SPRITE_LIST CaptureSprite04
	SCENE_SPRITE_LIST CaptureSprite05
	SCENE_SPRITE_LIST CaptureSprite06
	SCENE_SPRITE_LIST CaptureSprite07
	SCENE_SPRITE_LIST CaptureSprite08
	SCENE_SPRITE_LIST CaptureSprite09
	SCENE_SPRITE_LIST CaptureSprite10
	SCENE_SPRITE_LIST CaptureSprite11
	SCENE_SPRITE_LIST CaptureSprite12
	SCENE_SPRITE_LIST CaptureSprite13
	SCENE_SPRITE_LIST CaptureSprite14
	SCENE_SPRITE_LIST CaptureSprite15
	SCENE_SPRITE_LIST CaptureSprite16
; Tiger summon-animation BG frames (CopyBgMap descriptors; scene 0 draws
; them by label) -- maps compiled from assets/summon/tiger.tmx, one Tiled
; layer pair per frame, like the other scenes.
TigerFrame00:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/tiger/frame00_idx.bin"
.attr:
	INCBIN "assets/summon/tiger/frame00_attr.bin"
TigerFrame01:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/tiger/frame01_idx.bin"
.attr:
	INCBIN "assets/summon/tiger/frame01_attr.bin"
TigerFrame02:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/tiger/frame02_idx.bin"
.attr:
	INCBIN "assets/summon/tiger/frame02_attr.bin"
TigerFrame03:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/tiger/frame03_idx.bin"
.attr:
	INCBIN "assets/summon/tiger/frame03_attr.bin"
TigerFrame04:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/tiger/frame04_idx.bin"
.attr:
	INCBIN "assets/summon/tiger/frame04_attr.bin"
TigerFrame05:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/tiger/frame05_idx.bin"
.attr:
	INCBIN "assets/summon/tiger/frame05_attr.bin"
TigerFrame06:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/tiger/frame06_idx.bin"
.attr:
	INCBIN "assets/summon/tiger/frame06_attr.bin"
TigerFrame07:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/tiger/frame07_idx.bin"
.attr:
	INCBIN "assets/summon/tiger/frame07_attr.bin"
TigerFrame08:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/tiger/frame08_idx.bin"
.attr:
	INCBIN "assets/summon/tiger/frame08_attr.bin"
TigerFrame09:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/tiger/frame09_idx.bin"
.attr:
	INCBIN "assets/summon/tiger/frame09_attr.bin"
