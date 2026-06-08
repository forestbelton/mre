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
	call Func_00_083c
	ldh a, [$ffa8]
	ld [$cf6d], a
	ldh a, [$ffa9]
	ld [$cf6e], a
	ld a, $10
	ldh [$ffa8], a
	ld a, $08
	ldh [$ffa9], a
	call Func_00_0bdd
	ld hl, $9800
	ld bc, $0400
	call Func_00_1002
	ld hl, $9c00
	ld bc, $0400
	call Func_00_1002
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
	call Func_00_09b1
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
	call Func_00_09d5
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
	call Func_00_083c
	call Func_00_16ad
	FAR_CALL $12, Func_12_402c
	FAR_CALL $01, Func_01_75ad
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
	ldh [$ffa8], a
	ld a, [$cf6e]
	ldh [$ffa9], a
	call Func_05_48fc
	call Func_00_0786
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
	call Func_00_108f
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
	call Func_00_10b5
	ret

; --- Per-scene tables, indexed by wSceneState (the dispatch). Set up by
; SceneSetupTracks (script roots), SceneLoadTiles (BG tiles), SceneLoadPalettes (palettes). ---
ScenePaletteSrc:     ; $45da: BG+OBJ palette block ptr (SceneLoadPalettes -> LoadBgPalettes/LoadObjPalettes)
	dw TigerPalettes, MocchiPalettes, HarePalettes, GaliPalettes
	dw GolemPalettes, SuezoPalettes, PhenixPalettes, Scene7Palettes
SceneBgTilesetSrc:      ; $45ea: BG tile source -> VRAM $8000; SceneLoadTiles/Func_00_108f loads $1800 to bank0 then the next $1800 to bank1
	dw TigerTiles, MocchiTiles, HareTiles, GaliTiles
	dw GolemTiles, SuezoTiles, PhenixTiles, Scene7Tiles
SceneBgTilesetBank:     ; $45fa: bank for the BG tile load
	db $08, $09, $07, $0b, $06, $0a, $0d, $0e
ScenePaletteBank:    ; $4602: bank of the palette block (also the metasprite-tile bank, Func_05_43db)
	db $08, $09, $07, $0b, $06, $0a, $0d, $0e
SceneDescBank:       ; $460a: per-scene bank the CopyBgMap descriptor is read from (SceneDrawBgMap -> b -> Func_00_10dc)
	db $05, $09, $07, $0c, $06, $0a, $0c, $0e
SceneDrawBank:          ; $4612: per-scene metasprite bank -> wDrawBank (Func_05_44b4)
	db $08, $09, $07, $0b, $06, $0a, $0c, $0e
SceneBgScriptTable:     ; $461a: VM1 (BG track) script roots, by wSceneState
	dw Scene0_VM1, Scene1_VM1, Scene2_VM1, Scene3_VM1
	dw Scene4_VM1, Scene5_VM1, Scene6_VM1, Scene7_VM1
SceneSprScriptTable:    ; $462a: VM2 (sprite track) script roots
	dw Scene0_VM2, Scene1_VM2, Scene2_VM2, Scene3_VM2
	dw Scene4_VM2, Scene5_VM2, Scene6_VM2, Scene7_VM2

Func_05_463a:
	FAR_CALL $00, Func_00_39ad
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
	FAR_CALL $12, Func_12_4c13
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
Func_05_4785:
	ld a, $01
	call Func_05_47d4
	ld a, $01
	ld [$c2ab], a
	ld a, $00
	ld [wRoomType], a
	ld a, $01
	ld [wActiveFloor], a
	call Func_00_1219
	ret
Func_05_479d:
	xor a
	call Func_05_47d4
	xor a
	ld [$c2ab], a
	ld a, [$cff1]
	ld [wRoomType], a
	ld a, [wCFF0]
	ld [wActiveFloor], a
	ret
Func_05_47b2:
	xor a
	call Func_05_47d4
	ld a, $01
	ld [$c2ab], a
	ld a, $01
	ld [wRoomType], a
	ld a, $01
	ld [wActiveFloor], a
	ret
Func_05_47c6:
	ld a, $01
	call Func_05_47d4
	ld a, $01
	ld [$c2ab], a
	call Func_00_1219
	ret
Func_05_47d4:
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
	FAR_CALL $12, Func_12_4bb3
	ld [wScreenPhase], a
	or a
	jr z, Func_05_4865
	FAR_CALL $12, Func_12_4bef
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
	FAR_CALL $10, Func_10_4018
	FAR_CALL $02, Func_02_4000
	FAR_CALL $16, Func_16_4016
	FAR_CALL $17, SpecialScene_LoadGraphics
	call Func_05_48c9
	ret
Func_05_48c9:
	ld a, [wRoomType]
	cp $02
	jr nz, Func_05_48d9
	FAR_CALL $3d, Func_3d_4000
	ret
Func_05_48d9:
	call Func_05_48dd
	ret
Func_05_48dd:
	ld de, $c4cd
	ld c, $00
Func_05_48e2:
	ld a, [de]
	cp $ff
	jr z, Func_05_48f4
	ld b, a
	push bc
	push de
	FAR_CALL $11, Func_11_4081
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
	FAR_CALL $02, Func_02_4010
	call Func_05_4918
	FAR_CALL $10, Func_10_40a4
	FAR_CALL $17, SpecialScene_LoadTilemap
	ret
Func_05_4918:
	ld a, [wRoomType]
	cp $02
	jr nz, Func_05_4928
	FAR_CALL $3d, Func_3d_4051
	ret
Func_05_4928:
	FAR_CALL $11, Func_11_40b1
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
	SCENE_BG_DRAW   $03, $0060, $59b2
	SCENE_BG_DRAW   $03, $0060, $5b98
	SCENE_BG_DRAW   $03, $0060, $5d7e
	SCENE_BG_DRAW   $03, $0060, $5f64
	SCENE_BG_DRAW   $04, $0060, $614a
	SCENE_BG_DRAW   $0a, $0060, $6330
	SCENE_BG_DRAW   $08, $0060, $6516
	SCENE_BG_DRAW   $05, $0060, $66fc
	SCENE_BG_DRAW   $05, $0060, $68e2
	SCENE_BG_DRAW   $05, $0060, $6ac8
	SCENE_BG_DRAW   $05, $0060, $66fc
	SCENE_BG_DRAW   $05, $0060, $68e2
	SCENE_BG_DRAW   $05, $0060, $6ac8
	SCENE_BG_DRAW   $05, $0060, $66fc
	SCENE_BG_DRAW   $05, $0060, $68e2
	SCENE_BG_DRAW   $05, $0060, $6ac8
	SCENE_BG_DRAW   $05, $0060, $66fc
	SCENE_BG_DRAW   $05, $0060, $68e2
	SCENE_BG_DRAW   $05, $0060, $6ac8
	SCENE_BG_DRAW   $05, $0060, $66fc
	SCENE_BG_DRAW   $05, $0060, $68e2
	SCENE_BG_DRAW   $05, $0060, $6ac8
	SCENE_BG_DRAW   $05, $0060, $66fc
	SCENE_BG_DRAW   $05, $0060, $68e2
	SCENE_BG_DRAW   $05, $0060, $6ac8
	SCENE_BG_DRAW   $05, $0060, $66fc
	SCENE_BG_DRAW   $05, $0060, $68e2
	SCENE_BG_DRAW   $05, $0060, $6ac8
	SCENE_BG_DRAW   $05, $0060, $66fc
	SCENE_BG_DRAW   $05, $0060, $68e2
	SCENE_BG_DRAW   $05, $0060, $6ac8
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
	SCENE_SPRITE_LIST TigerSprites, $0049, $0000
	SCENE_SPRITE_LIST TigerSprites, $00cb, $007e
	SCENE_SPRITE_LIST TigerSprites, $0155, $0100
	SCENE_SPRITE_LIST TigerSprites, $01d7, $018a
	SCENE_SPRITE_LIST TigerSprites, $0259, $020c
	SCENE_SPRITE_LIST TigerSprites, $02d3, $0286
Scene1_VM1:
	SCENE_BG_DRAW   $68, $0060, $0000
	SCENE_BG_SOUND  $17
	SCENE_BG_DRAW   $01, $0060, MocchiMaps
	SCENE_BG_DRAW   $07, $0060, MocchiMaps
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
	SCENE_SPRITE_LIST MocchiSprites, $0031, $0000
	SCENE_SPRITE_LIST MocchiSprites, $006b, $004a
	SCENE_SPRITE_LIST MocchiSprites, $00b9, $0084
	SCENE_SPRITE_LIST MocchiSprites, $0113, $00d2
	SCENE_SPRITE_LIST MocchiSprites, $0175, $012c
	SCENE_SPRITE_LIST MocchiSprites, $01e7, $019a
Scene2_VM1:
	SCENE_BG_DRAW   $01, $0060, HareMaps
	SCENE_BG_DRAW   $ff, $0060, HareMaps

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
	SCENE_SPRITE_LIST HareSprites, $0029, $0000
	SCENE_SPRITE_LIST HareSprites, $0036
	SCENE_SPRITE_LIST HareSprites, $006b
	SCENE_SPRITE_LIST HareSprites, $00b0
	SCENE_SPRITE_LIST HareSprites, $015e, $00fd
	SCENE_SPRITE_LIST HareSprites, $017b

; --- Scene 4 (wSceneState==4): BG track, root from $05:$461A[4] ($4622) ---
Scene4_VM1:
	SCENE_BG_DRAW   $30, $0060, $0000
	SCENE_BG_WOBBLE_ON
	SCENE_BG_DRAW   $0c, $0060, GolemMaps
	SCENE_BG_DRAW   $18, $0060, GolemMaps + $01e6
	SCENE_BG_DRAW   $0c, $0060, GolemMaps + $03cc
	SCENE_BG_DRAW   $20, $0060, GolemMaps + $05b2
	SCENE_BG_DRAW   $20, $0060, GolemMaps + $0798
	SCENE_BG_DRAW   $18, $0060, GolemMaps + $097e
	SCENE_BG_DRAW   $40, $0060, GolemMaps + $0b64
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
	SCENE_SPRITE_LIST GolemSprites, $0000
	SCENE_SPRITE_LIST GolemSprites, $0081
	SCENE_SPRITE_LIST GolemSprites, $010a
Scene5_VM1:
	SCENE_BG_DRAW   $72, $0060, $0000
	SCENE_BG_SOUND  $01
	SCENE_BG_DRAW   $08, $00ca, SuezoMaps
	SCENE_BG_DRAW   $06, $00ca, SuezoMaps + $0036
	SCENE_BG_DRAW   $06, $00ca, SuezoMaps + $006c
	SCENE_BG_DRAW   $06, $00ca, SuezoMaps + $00a2
	SCENE_BG_DRAW   $08, $00ca, SuezoMaps + $00d8
	SCENE_BG_DRAW   $04, $00ca, SuezoMaps + $010e
	SCENE_BG_DRAW   $04, $00ca, SuezoMaps + $0144
	SCENE_BG_SOUND  $01
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $06, $0085, SuezoMaps + $017a
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $06, $0085, SuezoMaps + $01e4
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $06, $0085, SuezoMaps + $024e
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $06, $0085, SuezoMaps + $02b8
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $04, $0085, SuezoMaps + $0322
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $04, $0085, SuezoMaps + $038c
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $10, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $00, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $04, $0061, SuezoMaps + $0544
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $00, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $00, $0061, SuezoMaps + $058a
	SCENE_BG_DRAW   $04, $0161, SuezoMaps + $0460
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $00, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $00, $0061, SuezoMaps + $05d0
	SCENE_BG_DRAW   $04, $0161, SuezoMaps + $0486
	SCENE_BG_SOUND  $02
	SCENE_BG_ROW    $00, $4080, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $00, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $00, $0061, SuezoMaps + $0616
	SCENE_BG_DRAW   $04, $0161, SuezoMaps + $04ac
	SCENE_BG_ROW    $00, $4088, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $00, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $00, $0061, SuezoMaps + $065c
	SCENE_BG_DRAW   $04, $0161, SuezoMaps + $04ac
	SCENE_BG_ROW    $00, $4080, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $00, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $00, $0061, SuezoMaps + $06a2
	SCENE_BG_DRAW   $04, $0161, SuezoMaps + $04d2
	SCENE_BG_ROW    $00, $4088, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $00, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $00, $0061, SuezoMaps + $06e8
	SCENE_BG_DRAW   $04, $0161, SuezoMaps + $04d2
	SCENE_BG_SOUND  $02
	SCENE_BG_ROW    $00, $4080, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $00, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $00, $0061, SuezoMaps + $0616
	SCENE_BG_DRAW   $04, $0161, SuezoMaps + $04f8
	SCENE_BG_ROW    $00, $4088, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $00, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $00, $0061, SuezoMaps + $065c
	SCENE_BG_DRAW   $04, $0161, SuezoMaps + $04ac
	SCENE_BG_ROW    $00, $4080, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $00, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $00, $0061, SuezoMaps + $06a2
	SCENE_BG_DRAW   $04, $0161, SuezoMaps + $04d2
	SCENE_BG_ROW    $00, $4088, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $00, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $00, $0061, SuezoMaps + $06e8
	SCENE_BG_DRAW   $04, $0161, SuezoMaps + $04d2
	SCENE_BG_SOUND  $02
	SCENE_BG_ROW    $00, $4080, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $00, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $00, $0061, SuezoMaps + $0616
	SCENE_BG_DRAW   $04, $0161, SuezoMaps + $04ac
	SCENE_BG_ROW    $00, $4088, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $00, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $00, $0061, SuezoMaps + $065c
	SCENE_BG_DRAW   $04, $0161, SuezoMaps + $04ac
	SCENE_BG_ROW    $00, $4080, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $00, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $00, $0061, SuezoMaps + $06a2
	SCENE_BG_DRAW   $04, $0161, SuezoMaps + $04d2
	SCENE_BG_ROW    $00, $4088, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $00, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $00, $0061, SuezoMaps + $06e8
	SCENE_BG_DRAW   $04, $0161, SuezoMaps + $04d2
	SCENE_BG_SOUND  $02
	SCENE_BG_ROW    $00, $4080, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $00, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $00, $0061, SuezoMaps + $0616
	SCENE_BG_DRAW   $04, $0161, SuezoMaps + $04f8
	SCENE_BG_ROW    $00, $4088, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $00, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $00, $0061, SuezoMaps + $065c
	SCENE_BG_DRAW   $04, $0161, SuezoMaps + $04ac
	SCENE_BG_ROW    $00, $4080, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $00, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $00, $0061, SuezoMaps + $06a2
	SCENE_BG_DRAW   $04, $0161, SuezoMaps + $04d2
	SCENE_BG_ROW    $00, $4088, $01, $01
	SCENE_BG_DRAW   $00, $00ca, SuezoMaps + $0144
	SCENE_BG_DRAW   $00, $0085, SuezoMaps + $03f6
	SCENE_BG_DRAW   $00, $0061, SuezoMaps + $06e8
	SCENE_BG_DRAW   $04, $0161, SuezoMaps + $04d2
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
	SCENE_SPRITE_LIST SuezoSprites, $0051, $0000
	SCENE_SPRITE_LIST SuezoSprites, $00c3, $0072
	SCENE_SPRITE_LIST SuezoSprites, $0135, $00e4
	SCENE_SPRITE_LIST SuezoSprites, $0156
	SCENE_SPRITE_LIST SuezoSprites, $01f8, $01a7
	SCENE_SPRITE_LIST SuezoSprites, $026a, $0219
	SCENE_SPRITE_LIST SuezoSprites, $02dc, $028b
Scene3_VM1:
	SCENE_BG_DRAW   $72, $0060, $0000
	SCENE_BG_DRAW   $06, $0060, $0000
	SCENE_BG_DRAW   $06, $0065, GaliMaps
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
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $00f6
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $03fc
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $0702
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $0a08
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $0d0e
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $1014
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $131a
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $1620
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $1926
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $1c2c
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $1f32
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $2238
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $00f6
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $03fc
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $0702
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $0a08
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $0d0e
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $1014
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $131a
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $1620
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $1926
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $1c2c
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $1f32
	SCENE_BG_DRAW   $05, $0060, GaliMaps + $2238
	SCENE_BG_SCROLL $fd
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $00f6
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $03fc
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $0702
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $0a08
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $0d0e
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $1014
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $131a
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $1620
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $1926
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $1c2c
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $1f32
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $2238
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $00f6
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $03fc
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $0702
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $0a08
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $0d0e
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $1014
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $131a
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $1620
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $1926
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $1c2c
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $1f32
	SCENE_BG_DRAW   $06, $0060, GaliMaps + $2238
	SCENE_BG_SCROLL $fe
	SCENE_BG_DRAW   $07, $0060, GaliMaps + $00f6
	SCENE_BG_DRAW   $07, $0060, GaliMaps + $03fc
	SCENE_BG_DRAW   $07, $0060, GaliMaps + $0702
	SCENE_BG_DRAW   $07, $0060, GaliMaps + $0a08
	SCENE_BG_DRAW   $07, $0060, GaliMaps + $0d0e
	SCENE_BG_DRAW   $07, $0060, GaliMaps + $1014
	SCENE_BG_DRAW   $07, $0060, GaliMaps + $131a
	SCENE_BG_DRAW   $07, $0060, GaliMaps + $1620
	SCENE_BG_DRAW   $07, $0060, GaliMaps + $1926
	SCENE_BG_DRAW   $07, $0060, GaliMaps + $1c2c
	SCENE_BG_DRAW   $07, $0060, GaliMaps + $1f32
	SCENE_BG_DRAW   $07, $0060, GaliMaps + $2238
	SCENE_BG_SCROLL $ff
	SCENE_BG_DRAW   $08, $0060, GaliMaps + $00f6
	SCENE_BG_DRAW   $08, $0060, GaliMaps + $03fc
	SCENE_BG_DRAW   $08, $0060, GaliMaps + $0702
	SCENE_BG_DRAW   $08, $0060, GaliMaps + $0a08
	SCENE_BG_DRAW   $08, $0060, GaliMaps + $0d0e
	SCENE_BG_DRAW   $08, $0060, GaliMaps + $1014
	SCENE_BG_DRAW   $08, $0060, GaliMaps + $131a
	SCENE_BG_DRAW   $08, $0060, GaliMaps + $1620
	SCENE_BG_DRAW   $08, $0060, GaliMaps + $1926
	SCENE_BG_DRAW   $08, $0060, GaliMaps + $1c2c
	SCENE_BG_DRAW   $08, $0060, GaliMaps + $1f32
	SCENE_BG_SCROLL $00
	SCENE_BG_SOUND  $00
	SCENE_BG_DRAW   $30, $0060, GaliMaps + $2238
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
	SCENE_SPRITE_LIST GaliSprites, $004d, $0000
	SCENE_SPRITE_LIST GaliSprites, $00c3, $006e
	SCENE_SPRITE_LIST GaliSprites, $0135, $00e4
	SCENE_SPRITE_LIST GaliSprites, $019f, $0156
	SCENE_SPRITE_LIST GaliSprites, $020d, $01b8
	SCENE_SPRITE_LIST GaliSprites, $027f, $0226
	SCENE_SPRITE_LIST GaliSprites, $02f1, $0298
Scene6_VM1:
	SCENE_BG_DRAW   $5a, $0060, $0000
	SCENE_BG_DRAW   $04, $0060, PhenixMaps + $0f30
	SCENE_BG_DRAW   $04, $0060, PhenixMaps + $1116
	SCENE_BG_DRAW   $48, $0060, PhenixMaps
	SCENE_BG_DRAW   $04, $0060, PhenixMaps + $01e6
	SCENE_BG_DRAW   $04, $0060, PhenixMaps + $03cc
	SCENE_BG_SOUND  $13
	SCENE_BG_DRAW   $04, $0060, PhenixMaps + $05b2
	SCENE_BG_DRAW   $06, $0060, PhenixMaps + $0798
	SCENE_BG_DRAW   $06, $0060, PhenixMaps + $097e
	SCENE_BG_DRAW   $38, $0060, PhenixMaps + $0b64
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
	SCENE_SPRITE_LIST PhenixSprites, $0000
	SCENE_SPRITE_LIST PhenixSprites, $0009
	SCENE_SPRITE_LIST PhenixSprites, $001a
	SCENE_SPRITE_LIST PhenixSprites, $0033
	SCENE_SPRITE_LIST PhenixSprites, $006c
	SCENE_SPRITE_LIST PhenixSprites, $00ad
	SCENE_SPRITE_LIST PhenixSprites, $00f6
	SCENE_SPRITE_LIST PhenixSprites, $0117
	SCENE_SPRITE_LIST PhenixSprites, $0148
	SCENE_SPRITE_LIST PhenixSprites, $0199
	SCENE_SPRITE_LIST PhenixSprites, $01ea
	SCENE_SPRITE_LIST PhenixSprites, $023b
	SCENE_SPRITE_LIST PhenixSprites, $02dc
	SCENE_SPRITE_LIST PhenixSprites, $037d
Scene7_VM1:
	SCENE_BG_DRAW   $02, $0188, Scene7Maps
	SCENE_BG_DRAW   $1e, $0188, Scene7Maps
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
	SCENE_BG_DRAW   $04, $00a6, Scene7Maps + $0016
	SCENE_BG_DRAW   $04, $00a6, Scene7Maps + $0016
	SCENE_BG_ROW    $08, $70b0, $02, $01
	SCENE_BG_ROW    $08, $70b8, $02, $01
	SCENE_BG_ROW    $08, $70c0, $02, $01
	SCENE_BG_ROW    $08, $70c8, $02, $01
	SCENE_BG_SOUND  $0d
	SCENE_BG_ROW    $48, $7080, $02, $01
	SCENE_BG_END
Scene7_VM2:
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
	SCENE_SPRITE_LIST Scene7Sprites, $0041
	SCENE_SPRITE_LIST Scene7Sprites, $007a
	SCENE_SPRITE_LIST Scene7Sprites, $00e3
	SCENE_SPRITE_LIST Scene7Sprites, $0128
	SCENE_SPRITE_LIST Scene7Sprites, $0151
	SCENE_SPRITE_LIST Scene7Sprites, $016a
	SCENE_SPRITE_LIST Scene7Sprites, $017b
	SCENE_SPRITE_LIST Scene7Sprites, $019c
	SCENE_SPRITE_LIST Scene7Sprites, $01bd
	SCENE_SPRITE_LIST Scene7Sprites, $01de
	SCENE_SPRITE_LIST Scene7Sprites, $01ff
	SCENE_SPRITE_LIST Scene7Sprites, $0210
	SCENE_SPRITE_LIST Scene7Sprites, $0231
	SCENE_SPRITE_LIST Scene7Sprites, $0252
	SCENE_SPRITE_LIST Scene7Sprites, $0273
	SCENE_SPRITE_LIST Scene7Sprites, $0284
	db $0c, $14

Data_05_59b4:
	db $a8, $5a, $b8, $59

Data_05_59b8:
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ac, $b4, $bc, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $bd, $b5, $ad, $ad, $b5, $bd, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $bc, $b4, $ac, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $01, $01, $01, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $61, $61, $61, $01, $01, $01, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $61, $61, $61, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $0c, $14

Data_05_5b9a:
	db $8e, $5c, $9e, $5b

Data_05_5b9e:
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $86, $8e, $96, $9e, $a6, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $a7, $9f, $97, $8f, $87, $87, $8f, $97, $9f, $a7, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $a6, $9e, $96, $8e, $86, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $01, $01, $01, $01, $01, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $61, $61, $61, $61, $61, $01, $01, $01, $01, $01, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $61, $61, $61, $61, $61, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $0c, $14

Data_05_5d80:
	db $74, $5e, $84, $5d

Data_05_5d84:
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $84, $8c, $94, $9c, $a4, $ac, $b4, $bc, $ff, $ff, $ff, $ff
	db $bd, $b5, $ad, $a5, $9d, $95, $8d, $85, $ff, $8d, $95, $9d, $a5, $ad, $b5, $bd
	db $ff, $ff, $ff, $ff, $bc, $b4, $ac, $a4, $9c, $94, $8c, $84, $85, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $01, $01, $01, $01, $01, $01, $01, $01, $09, $09, $09, $09
	db $61, $61, $61, $61, $61, $61, $61, $61, $49, $01, $01, $01, $01, $01, $01, $01
	db $09, $09, $09, $09, $61, $61, $61, $61, $61, $61, $61, $61, $41, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $0c, $14

Data_05_5f66:
	db $5a, $60, $6a, $5f

Data_05_5f6a:
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $6b, $6f, $73, $76, $72, $6e, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $80, $88, $90, $98, $a0, $a8, $b0, $6c, $70, $74, $75, $71
	db $6d, $b1, $a9, $a1, $99, $91, $89, $81, $81, $89, $91, $99, $a1, $a9, $b1, $6d
	db $71, $75, $74, $70, $6c, $b0, $a8, $a0, $98, $90, $88, $80, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $6e, $72, $76, $73, $6f, $6b, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $69, $69, $69, $09, $09, $09
	db $09, $09, $09, $09, $01, $01, $01, $01, $01, $01, $01, $09, $09, $09, $69, $69
	db $69, $61, $61, $61, $61, $61, $61, $61, $01, $01, $01, $01, $01, $01, $01, $09
	db $09, $09, $69, $69, $69, $61, $61, $61, $61, $61, $61, $61, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $69, $69, $69, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $0c, $14

Data_05_614c:
	db $40, $62, $50, $61

Data_05_6150:
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $be, $c4, $ca, $cf, $c9, $c3, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $ae, $bf, $c5, $cb, $ce, $c8, $c2, $b7, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $a6, $9e, $96, $8e, $86, $af, $c0, $c6, $cc, $cd, $c7
	db $c1, $b6, $86, $8e, $96, $9e, $a6, $fc, $fc, $a7, $9f, $97, $8f, $87, $b6, $c1
	db $c7, $cd, $cc, $c6, $c0, $af, $87, $8f, $97, $9f, $a7, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $b7, $c2, $c8, $ce, $cb, $c5, $bf, $ae, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $c3, $c9, $cf, $ca, $c4, $be, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $01, $01, $01, $61, $61, $61, $68, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $01, $01, $01, $01, $61, $61, $61, $61, $08, $08
	db $08, $08, $08, $08, $08, $21, $21, $21, $21, $21, $01, $01, $01, $01, $61, $61
	db $61, $61, $01, $01, $01, $01, $01, $08, $08, $21, $21, $21, $21, $21, $01, $01
	db $01, $01, $61, $61, $61, $61, $01, $01, $01, $01, $01, $08, $08, $08, $08, $08
	db $08, $08, $01, $01, $01, $01, $61, $61, $61, $61, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $01, $01, $01, $61, $61, $61, $68, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $0c, $14

Data_05_6332:
	db $26, $64, $36, $63

Data_05_6336:
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $d0, $d8, $e0
	db $e8, $f0, $f7, $ef, $e7, $df, $d7, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $d1, $d9, $e1, $e9, $f1, $f6, $ee, $e6, $de, $d6, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $d2, $da, $e2, $ea, $f2, $f5, $ed, $e5, $dd, $d5, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $bc, $b4, $d3, $db, $e3, $eb, $f3, $f4, $ec
	db $e4, $dc, $d4, $b5, $bd, $fc, $fc, $fc, $fc, $fc, $fc, $bd, $b5, $d4, $dc, $e4
	db $ec, $f4, $f3, $eb, $e3, $db, $d3, $b4, $bc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $d5, $dd, $e5, $ed, $f5, $f2, $ea, $e2, $da, $d2, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $d6, $de, $e6, $ee, $f6, $f1, $e9, $e1, $d9, $d1, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $d7, $df, $e7, $ef, $f7, $f0, $e8
	db $e0, $d8, $d0, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $01
	db $01, $01, $61, $61, $61, $61, $61, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $01, $01, $01, $01, $01, $61, $61, $61, $61, $61, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $01, $01, $01, $01, $01, $61, $61, $61, $61, $61, $08
	db $08, $08, $08, $08, $08, $08, $08, $21, $21, $01, $01, $01, $01, $01, $61, $61
	db $61, $61, $61, $41, $41, $08, $08, $08, $08, $08, $08, $21, $21, $01, $01, $01
	db $01, $01, $61, $61, $61, $61, $61, $41, $41, $08, $08, $08, $08, $08, $08, $08
	db $08, $01, $01, $01, $01, $01, $61, $61, $61, $61, $61, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $01, $01, $01, $01, $01, $61, $61, $61, $61, $61, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $01, $01, $01, $61, $61
	db $61, $61, $61, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $0c, $14

Data_05_6518:
	db $0c, $66, $1c, $65

Data_05_651c:
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $c3, $c9, $cf, $ca, $c4, $be, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $b7, $c2, $c8, $ce, $cb, $c5, $bf, $ae, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $a6, $fc, $fc, $fc, $a6, $b6, $c1, $c7, $cd, $cc, $c6
	db $c0, $af, $a7, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $a7, $af, $c0
	db $c6, $cc, $cd, $c7, $c1, $b6, $a6, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $ae, $bf, $c5, $cb, $ce, $c8, $c2, $b7, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $be, $c4, $ca, $cf, $c9, $c3, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $48, $41, $41, $41, $21, $21, $21, $28, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $41, $41, $41, $41, $21, $21, $21, $21, $08, $08
	db $08, $08, $08, $08, $08, $21, $08, $08, $08, $21, $41, $41, $41, $41, $21, $21
	db $21, $21, $41, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $21, $41, $41
	db $41, $41, $21, $21, $21, $21, $41, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $41, $41, $41, $41, $21, $21, $21, $21, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $48, $41, $41, $41, $21, $21, $21, $28, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $0c, $14

Data_05_66fe:
	db $f2, $67, $02, $67

Data_05_6702:
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $00, $08, $12, $1a, $24, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $31, $2b, $23, $19, $11, $01, $09, $13, $1b, $25, $32, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $40, $39, $30, $2a, $22, $18, $10, $02, $0a, $14, $1c
	db $26, $33, $3a, $fc, $46, $4c, $51, $4b, $45, $3f, $38, $2f, $29, $21, $0f, $07
	db $03, $0b, $15, $1d, $27, $34, $3b, $41, $47, $4d, $50, $4a, $44, $3e, $37, $2e
	db $28, $20, $0e, $06, $04, $0c, $16, $1e, $2c, $35, $3c, $42, $48, $4e, $4f, $49
	db $43, $3d, $36, $2d, $1f, $17, $0d, $05, $05, $0d, $17, $1f, $2d, $36, $3d, $43
	db $49, $4f, $4e, $48, $42, $3c, $35, $2c, $1e, $16, $0c, $04, $06, $0e, $20, $28
	db $2e, $37, $3e, $44, $4a, $50, $4d, $47, $41, $3b, $34, $27, $1d, $15, $0b, $03
	db $07, $0f, $21, $29, $2f, $38, $3f, $45, $4b, $51, $4c, $46, $fc, $3a, $33, $26
	db $1c, $14, $0a, $02, $10, $18, $22, $2a, $30, $39, $40, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $32, $25, $1b, $13, $09, $01, $11, $19, $23, $2b, $31, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $24, $1a, $12, $08, $00, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $01, $01, $01, $01, $01, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $61, $61, $61, $61, $61, $01, $01, $01, $01, $01, $01, $08, $08
	db $08, $08, $08, $08, $08, $61, $61, $61, $61, $61, $61, $61, $01, $01, $01, $01
	db $01, $01, $01, $08, $01, $01, $61, $61, $61, $61, $61, $61, $61, $61, $61, $61
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $61, $61, $61, $61, $61, $61
	db $61, $61, $61, $61, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $61, $61
	db $61, $61, $61, $61, $61, $61, $61, $61, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $61, $61, $61, $61, $61, $61, $61, $61, $61, $61, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $61, $61, $61, $61, $61, $61, $61, $61, $61, $61
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $61, $61, $08, $61, $61, $61
	db $61, $61, $61, $61, $01, $01, $01, $01, $01, $01, $01, $08, $08, $08, $08, $08
	db $08, $08, $61, $61, $61, $61, $61, $61, $01, $01, $01, $01, $01, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $61, $61, $61, $61, $61, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $0c, $14

Data_05_68e4:
	db $d8, $69, $e8, $68

Data_05_68e8:
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $52, $5c, $65, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $5b, $53, $5d, $66, $6e, $76, $7e, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $05, $7d, $75, $6d, $64, $5a, $54, $5e, $67, $6f
	db $77, $7f, $06, $0c, $12, $18, $1d, $17, $11, $0b, $04, $7c, $74, $6c, $63, $59
	db $55, $5f, $68, $70, $78, $00, $07, $0d, $13, $19, $1c, $16, $10, $0a, $03, $7b
	db $73, $6b, $62, $58, $56, $60, $69, $71, $79, $01, $08, $0e, $14, $1a, $1b, $15
	db $0f, $09, $02, $7a, $72, $6a, $61, $57, $57, $61, $6a, $72, $7a, $02, $09, $0f
	db $15, $1b, $1a, $14, $0e, $08, $01, $79, $71, $69, $60, $56, $58, $62, $6b, $73
	db $7b, $03, $0a, $10, $16, $1c, $19, $13, $0d, $07, $00, $78, $70, $68, $5f, $55
	db $59, $63, $6c, $74, $7c, $04, $0b, $11, $17, $1d, $18, $12, $0c, $06, $7f, $77
	db $6f, $67, $5e, $54, $5a, $64, $6d, $75, $7d, $05, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $7e, $76, $6e, $66, $5d, $53, $5b, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $65, $5c, $52, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $01, $01, $01, $09, $09, $09, $09, $09, $09, $09, $69, $69
	db $69, $69, $69, $69, $69, $69, $69, $61, $01, $01, $01, $01, $01, $01, $09, $09
	db $09, $09, $69, $69, $69, $69, $69, $61, $61, $61, $61, $61, $01, $01, $01, $01
	db $01, $01, $09, $09, $09, $09, $69, $69, $69, $69, $69, $61, $61, $61, $61, $61
	db $01, $01, $01, $01, $01, $09, $09, $09, $09, $09, $69, $69, $69, $69, $69, $61
	db $61, $61, $61, $61, $01, $01, $01, $01, $01, $09, $09, $09, $09, $09, $69, $69
	db $69, $69, $69, $61, $61, $61, $61, $61, $01, $01, $01, $01, $01, $09, $09, $09
	db $09, $09, $69, $69, $69, $69, $69, $61, $61, $61, $61, $61, $01, $01, $01, $01
	db $01, $09, $09, $09, $09, $09, $69, $69, $69, $69, $69, $61, $61, $61, $61, $61
	db $01, $01, $01, $01, $01, $09, $09, $09, $09, $09, $69, $69, $69, $69, $61, $61
	db $61, $61, $61, $61, $01, $01, $01, $01, $01, $09, $09, $09, $09, $09, $69, $69
	db $69, $69, $61, $61, $61, $61, $61, $61, $01, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $69, $69, $69, $69, $69, $69, $69, $61, $61, $61, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $0c, $14

Data_05_6aca:
	db $be, $6b, $ce, $6a

Data_05_6ace:
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $1e, $27, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $42, $39, $30, $ff, $1f, $28, $31, $3a, $ff, $4a, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $58, $51, $49, $41, $38, $2f, $26, $20, $29, $32, $3b
	db $43, $4b, $52, $59, $5f, $65, $6a, $64, $5e, $57, $50, $48, $40, $37, $2e, $25
	db $21, $2a, $33, $3c, $44, $4c, $53, $5a, $60, $66, $69, $63, $5d, $56, $4f, $47
	db $3f, $36, $2d, $24, $22, $2b, $34, $3d, $45, $4d, $54, $5b, $61, $67, $68, $62
	db $5c, $55, $4e, $46, $3e, $35, $2c, $23, $23, $2c, $35, $3e, $46, $4e, $55, $5c
	db $62, $68, $67, $61, $5b, $54, $4d, $45, $3d, $34, $2b, $22, $24, $2d, $36, $3f
	db $47, $4f, $56, $5d, $63, $69, $66, $60, $5a, $53, $4c, $44, $3c, $33, $2a, $21
	db $25, $2e, $37, $40, $48, $50, $57, $5e, $64, $6a, $65, $5f, $59, $52, $4b, $43
	db $3b, $32, $29, $20, $26, $2f, $38, $41, $49, $51, $58, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $4a, $ff, $3a, $31, $28, $1f, $ff, $30, $39, $42, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $27, $1e, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $69, $69
	db $69, $69, $69, $69, $69, $69, $69, $69, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $69, $69, $69, $69, $69, $69, $69, $69, $69, $69, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $69, $69, $69, $69, $69, $69, $69, $69, $69, $69
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $69, $69, $69, $69, $69, $69
	db $69, $69, $69, $69, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $69, $69
	db $69, $69, $69, $69, $69, $69, $69, $69, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $69, $69, $69, $69, $69, $69, $69, $69, $69, $69, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $69, $69, $69, $69, $69, $69, $69, $69, $69, $69
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $69, $69, $69, $69, $69, $69
	db $69, $69, $69, $69, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $69, $69
	db $69, $69, $69, $69, $69, $69, $69, $69, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $69, $69, $69, $69, $69, $69, $69, $69, $69, $69, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
