; Monster-regeneration display sequence (ROM bank $14).
;
; ShowRegeneratedMonster: the scripted animation that reveals a monster
; regenerated from a disc at Pashute's shrine (plays BGM, loads tiles/tilemap/
; palettes, draws the monster metasprite, runs a sparkle/glitch reveal FX, waits
; for input). Triggered from text/scripts/pashute.asm; keyed by wActiveMonster
; (7 friendly monsters) via the MonsterRegen* tables below.
; Carved out of analyzed.asm (byte-exact; section names unchanged).
; NOTE: the per-frame FX state machine's internal branch/loop targets are still
; raw Func_14_* labels -- a dedicated pass could localize them.

INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "sound_ids.inc"

SECTION "analyzed_050000", ROMX[$4000], BANK[$14]

; Per-monster regen tables, indexed by wActiveMonster (7 friendly monsters).
MonsterRegenBgPalettes:                     ; one 8-byte BG palette per monster (-> slot 7)
	db $02, $00, $3c, $73, $6a, $71, $26, $50   ; 0
	db $02, $00, $ab, $15, $3e, $5e, $f5, $38   ; 1
	db $02, $00, $5c, $63, $f7, $1d, $f0, $08   ; 2
	db $02, $00, $de, $63, $9d, $1e, $50, $25   ; 3
	db $02, $00, $de, $77, $55, $4a, $29, $45   ; 4
	db $02, $00, $de, $7b, $3e, $27, $54, $19   ; 5
	db $02, $00, $3f, $2f, $ba, $01, $55, $10   ; 6
MonsterRegenBaseTile:                       ; base OAM tile per monster (read by SetMonsterOamTiles)
	db $4d, $3d, $3d, $3d, $3d, $3e, $3d
MonsterRegenSpritePtrs:                     ; metasprite pointer per monster (-> $68xx data)
	dw $68a4, $68c5, $68f6, $6927, $6958, $6989, $69ba

ShowRegeneratedMonster:
	push af
	ld a, SOUND_BGM_DiscRegen
	call PlaySoundTracked
	pop af
	call Func_00_07c5
	xor a
	ldh [rVBK], a
	ld bc, $1800
	ld hl, Data_14_436b
	ld de, $8000
	call VramCopy16
	ld a, $01
	ldh [rVBK], a
	ld bc, $0800
	ld de, $8000
	call VramCopy16
	ld hl, $63eb
	ld de, $9800
	call CopyBgMap
	ld a, $14
	ld [wDrawBank], a
	ld hl, $6853
	ld bc, $1008
	call DrawMetasprite
	ld a, [wActiveMonster]
	add a, a
	ld hl, MonsterRegenSpritePtrs
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, $1008
	call DrawMetasprite
	call HideUnusedOamSprites
	call Func_14_42d7
	call Func_14_4319
	ld hl, Data_14_636b
	call LoadBgPalettes
	ld hl, $63ab
	call LoadObjPalettes
	ld hl, MonsterRegenBgPalettes
	ld a, [wActiveMonster]
	swap a
	rrca
	rst AddAToHL
	ld a, $07
	ld b, $01
	call Func_00_0732
	xor a
	ld [wUiTimer], a
Func_14_40c5:
	call WaitForNextFrame
	call WaitForNextFrame
	call WaitForNextFrame
	call WaitForNextFrame
	call WaitForNextFrame
	call WaitForNextFrame
	call WaitForNextFrame
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyPressed]
	bit 1, a
	jp nz, PlayPashuteBgm
	ld d, $06
	ld hl, $c003
Func_14_40ec:
	ld a, [hl]
	ld c, a
	and $f8
	ld b, a
	ld a, c
	and $07
	inc a
	cp $05
	jr nz, Func_14_40fb
	ld a, $01
Func_14_40fb:
	or b
	ld [hl], a
	ld a, $04
	add a, l
	ld l, a
	dec d
	jr nz, Func_14_40ec
	ld a, [wUiTimer]
	inc a
	ld [wUiTimer], a
	cp $14
	jr nz, Func_14_40c5
	ld hl, $d0eb
	ld bc, $0008
	ld d, $ff
	call FillRam
	xor a
	ld [wUiTimer], a
Func_14_411e:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyPressed]
	bit 1, a
	jr nz, PlayPashuteBgm
	call Func_14_41b3
	ld a, [wUiTimer]
	inc a
	ld [wUiTimer], a
	cp $8c
	jr nz, Func_14_411e
	xor a
	ld [wUiTimer], a
Func_14_413c:
	call WaitForNextFrame
	call Func_14_41b3
	call Func_14_4294
	call Func_14_42af
	ld a, [wUiTimer]
	inc a
	ld [wUiTimer], a
	cp $f0
	jr nz, Func_14_413c
	call Func_00_07a7
	ld d, $3c
Func_14_4158:
	call WaitForNextFrame
	push de
	call ReadJoypad
	pop de
	ldh a, [hJoyPressed]
	bit 1, a
	jr nz, PlayPashuteBgm
	dec d
	jr nz, Func_14_4158
	ld hl, $63eb
	ld de, $9800
	call CopyBgMap
	call SetMonsterOamTiles
	call Func_00_0794
	call WaitForRegenConfirm
PlayPashuteBgm:
	push af
	ld a, SOUND_BGM_Pashute
	call PlaySoundTracked
	pop af
	ret

Data_14_4183:
	db $0c, $1d, $22, $10, $27, $14, $19, $2c, $2c, $7c, $4d, $42, $65, $37, $59, $71
	db $7c, $8d, $92, $80, $97, $84, $89, $9c, $01, $11, $16, $04, $1b, $08, $0d, $20
	db $20, $31, $28, $36, $3b, $24, $2d, $40, $70, $81, $86, $7d, $8b, $78, $74, $90

Func_14_41b3:
	ld a, [wUiTimer]
	cp $8c
	jr nc, Func_14_4239
	ld c, a
	and $01
	jr nz, Func_14_4239
	ld a, c
	rrca
	ld c, a
	and $03
	ld b, a
	ld a, c
	rrca
	rrca
	and $07
	ld c, a
	ld a, b
	cp $00
	jr nz, Func_14_41de
	ld a, c
	ld hl, $419b
	rst AddAToHL
	ld d, [hl]
	ld a, c
	ld hl, $418b
	rst AddAToHL
	ld e, [hl]
	jr Func_14_420e
Func_14_41de:
	cp $01
	jr nz, Func_14_41f0
	ld a, c
	ld hl, $41a3
	rst AddAToHL
	ld d, [hl]
	ld a, c
	ld hl, $4193
	rst AddAToHL
	ld e, [hl]
	jr Func_14_420e
Func_14_41f0:
	cp $02
	jr nz, Func_14_4202
	ld a, c
	ld hl, $41ab
	rst AddAToHL
	ld d, [hl]
	ld a, c
	ld hl, $418b
	rst AddAToHL
	ld e, [hl]
	jr Func_14_420e
Func_14_4202:
	ld a, c
	ld hl, $41a3
	rst AddAToHL
	ld d, [hl]
	ld a, c
	ld hl, $4183
	rst AddAToHL
	ld e, [hl]
Func_14_420e:
	push de
	ld hl, $c080
	ld c, $00
Func_14_4214:
	ld de, $d0eb
	ld a, c
	rst AddAToDE
	ld a, [de]
	cp $10
	jr nc, Func_14_422b
	inc l
	inc l
	inc l
	inc l
	inc c
	ld a, $08
	cp c
	jr nz, Func_14_4214

Data_14_4228:
	db $d1, $18, $0e

Func_14_422b:
	ld a, $00
	ld [de], a
	pop de
	ld a, d
	ld [hl+], a
	ld a, e
	ld [hl+], a
	ld a, $5a
	ld [hl+], a
	ld a, $00
	ld [hl+], a
Func_14_4239:
	ld hl, $c080
	ld c, $00
Func_14_423e:
	ld de, $d0eb
	ld a, c
	rst AddAToDE
	ld a, [de]
	cp $10
	jr c, Func_14_4251
	ld a, $ff
	ld [de], a
	ld a, $f0
	ld [hl+], a
	inc l
	jr Func_14_428b
Func_14_4251:
	inc a
	ld b, a
	ld [de], a
	ld a, [hl+]
	ld d, a
	ld e, [hl]
	ld a, $48
	sub d
	ld d, a
	ld a, $54
	sub e
	ld e, a
	ld a, d
	add a, e
	sra a
	sra a
	sra a
	add a, [hl]
	ld [hl-], a
	ld a, d
	sub e
	sra a
	sra a
	sra a
	add a, [hl]
	ld [hl+], a
	inc l
	ld a, b
	cp $04
	jr nz, Func_14_427d
	ld [hl], $5c
	jr Func_14_428b
Func_14_427d:
	cp $08
	jr nz, Func_14_4285
	ld [hl], $5e
	jr Func_14_428b
Func_14_4285:
	cp $0c
	jr nz, Func_14_428b
	ld [hl], $60
Func_14_428b:
	inc l
	inc l
	inc c
	ld a, $08
	cp c
	jr nz, Func_14_423e
	ret
Func_14_4294:
	ld a, [wUiTimer]
	cp $64
	ret c
	and $01
	jr z, Func_14_42a3
	call Func_14_42d7
	jr Func_14_42a6
Func_14_42a3:
	call Func_14_42e7
Func_14_42a6:
	ld a, [wUiTimer]
	and $0f
	call z, Func_14_4300
	ret
Func_14_42af:
	ld a, [wUiTimer]
	ld b, a
	and $03
	ret nz
	ld a, b
	cp $78
	jr nc, Func_14_42c9
	and $04
	jr nz, Func_14_42c4
	ld hl, $66c1
	jr Func_14_42d0
Func_14_42c4:
	ld hl, $6747
	jr Func_14_42d0
Func_14_42c9:
	and $04
	jr z, Func_14_42c4
	ld hl, $67cd
Func_14_42d0:
	ld de, $9866
	call CopyBgMap
	ret
Func_14_42d7:
	ld d, $f0
	ld hl, $c018
	ld c, $0e
Func_14_42de:
	ld [hl], d
	ld a, $04
	add a, l
	ld l, a
	dec c
	jr nz, Func_14_42de
	ret
Func_14_42e7:
	ld hl, $c018
	ld c, $0e
Func_14_42ec:
	ld a, c
	cp $08
	jr c, Func_14_42f5
	ld d, $52
	jr Func_14_42f7
Func_14_42f5:
	ld d, $62
Func_14_42f7:
	ld [hl], d
	ld a, $04
	add a, l
	ld l, a
	dec c
	jr nz, Func_14_42ec
	ret
Func_14_4300:
	ld hl, $c01a
	ld c, $0e
Func_14_4305:
	ld a, [hl]
	cp $9a
	jr c, Func_14_430e
	sub $38
	jr Func_14_4310
Func_14_430e:
	add a, $1c
Func_14_4310:
	ld [hl], a
	ld a, $04
	add a, l
	ld l, a
	dec c
	jr nz, Func_14_4305
	ret
Func_14_4319:
	ld b, $f0
	ld hl, $c050
	ld c, $0c
Func_14_4320:
	ld [hl], b
	inc l
	inc l
	inc l
	inc l
	dec c
	jr nz, Func_14_4320
	ret
SetMonsterOamTiles:
	ld a, [wActiveMonster]
	ld d, a
	ld hl, MonsterRegenBaseTile
	rst AddAToHL
	ld b, [hl]
	ld hl, $c050
	ld c, $0c
Func_14_4337:
	ld a, c
	cp $08
	jr z, Func_14_4344
	cp $04
	jr nz, Func_14_4348
	ld a, $00
	cp d
	ret z
Func_14_4344:
	ld a, $10
	add a, b
	ld b, a
Func_14_4348:
	ld [hl], b
	inc l
	inc l
	inc l
	inc l
	dec c
	jr nz, Func_14_4337
	ret
WaitForRegenConfirm:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyPressed]
	bit 1, a
	jr nz, Func_14_4363
	bit 0, a
	jr nz, Func_14_4363
	jr WaitForRegenConfirm
Func_14_4363:
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret

Data_14_436b:
	INCBIN "gfx/raw/Data_14_436b.2bpp", 0, 7344

Data_14_601b:
	db $80, $80, $81, $c1, $c0, $e0, $cf, $e0, $75, $73, $9a, $9a

SECTION "analyzed_05236b", ROMX[$636b], BANK[$14]

Data_14_636b:
	db $03, $1c, $cd, $2c, $94, $49, $8c, $65, $03, $1c, $cd, $2c, $94, $49, $ae, $31
	db $03, $1c, $09, $60, $0c, $40, $00, $00, $03, $1c, $e9, $34, $14, $52, $ae, $31
	db $03, $1c, $ff, $7f, $f0, $7e, $e9, $71, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $ff, $7f, $e7, $72, $a1, $54, $e0, $03, $7f, $7f, $dc, $0c, $12, $28
	db $1f, $00, $fe, $47, $6a, $1a, $40, $1d, $0f, $7c, $ff, $53, $dd, $16, $91, $21
	db $1f, $02, $7b, $7b, $4d, $6d, $00, $60, $ff, $7f, $a0, $79, $00, $6c, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $12, $14, $59, $65, $f1, $63, $58, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $58, $59, $4a, $3a, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3a, $4a, $59, $5a, $4b
	db $3b, $2b, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $2b, $3b
	db $4b, $5a, $5b, $4c, $3c, $2c, $1e, $15, $00, $00, $00, $00, $00, $00, $00, $00
	db $15, $1e, $2c, $3c, $4c, $5b, $5c, $4d, $3d, $2d, $1f, $16, $00, $00, $00, $00
	db $00, $00, $00, $00, $16, $1f, $2d, $3d, $4d, $5c, $5d, $00, $00, $2e, $20, $17
	db $00, $00, $00, $00, $00, $00, $00, $00, $17, $20, $2e, $00, $00, $5d, $5e, $4e
	db $3e, $2f, $21, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $21, $2f, $3e
	db $4e, $5e, $5f, $4f, $3f, $30, $22, $18, $00, $00, $00, $00, $00, $00, $00, $00
	db $18, $22, $30, $3f, $4f, $5f, $60, $50, $40, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $40, $50, $60, $61, $51, $41, $31, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $31, $41, $51, $61, $62, $52
	db $42, $32, $23, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $23, $32, $42
	db $52, $62, $00, $53, $43, $33, $24, $00, $b6, $f8, $fa, $fc, $fe, $7a, $7c, $7e
	db $00, $24, $33, $43, $53, $00, $00, $54, $44, $34, $25, $19, $b7, $f9, $fb, $fd
	db $ff, $7b, $7d, $7f, $19, $25, $34, $44, $54, $00, $63, $00, $45, $35, $26, $1a
	db $10, $0b, $06, $01, $01, $06, $0b, $10, $1a, $26, $35, $45, $00, $63, $64, $55
	db $46, $36, $27, $1b, $11, $0c, $07, $02, $02, $07, $0c, $11, $1b, $27, $36, $46
	db $55, $64, $65, $56, $47, $37, $28, $1c, $12, $0d, $08, $03, $03, $08, $0d, $12
	db $1c, $28, $37, $47, $56, $65, $00, $57, $48, $38, $29, $1d, $13, $0e, $09, $04
	db $04, $09, $0e, $13, $1d, $29, $38, $48, $57, $00, $00, $00, $49, $39, $2a, $00
	db $14, $0f, $0a, $05, $05, $0a, $0f, $14, $00, $2a, $39, $49, $00, $00, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20, $20, $20, $20
	db $20, $20, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20, $20, $20, $20
	db $20, $20, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20, $20, $20, $20
	db $03, $03, $03, $03, $03, $03, $03, $03, $00, $00, $00, $00, $00, $00, $20, $20
	db $20, $20, $21, $23, $03, $03, $03, $03, $03, $03, $03, $03, $03, $01, $00, $00
	db $00, $00, $20, $20, $20, $21, $21, $23, $23, $23, $23, $23, $03, $03, $03, $03
	db $03, $01, $01, $00, $00, $00, $20, $20, $20, $20, $21, $23, $23, $23, $23, $23
	db $03, $03, $03, $03, $03, $01, $00, $00, $00, $00, $20, $20, $20, $20, $20, $23
	db $23, $23, $23, $23, $03, $03, $03, $03, $03, $00, $00, $00, $00, $00, $20, $20
	db $20, $20, $20, $22, $22, $22, $22, $22, $02, $02, $02, $02, $02, $00, $00, $00
	db $00, $00, $20, $20, $20, $20, $20, $22, $22, $22, $22, $22, $02, $02, $02, $02
	db $02, $00, $00, $00, $00, $00, $08, $08, $07, $67, $c7, $66, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $66, $68, $00, $00, $00, $00, $00, $00, $67
	db $69, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $08, $08, $8d, $67
	db $4d, $67, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $6a, $6e, $72, $76, $00, $00, $00, $00, $6b, $6f, $73, $77
	db $00, $00, $00, $00, $6c, $70, $74, $78, $00, $00, $00, $00, $6d, $71, $75, $79
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $08, $08, $13, $68, $d3, $67, $b8, $c0, $c8, $d0, $d8, $e0, $e8, $f0
	db $b9, $c1, $c9, $d1, $d9, $e1, $e9, $f1, $ba, $c2, $ca, $d2, $da, $e2, $ea, $f2
	db $bb, $c3, $cb, $d3, $db, $e3, $eb, $f3, $bc, $c4, $cc, $d4, $dc, $e4, $ec, $f4
	db $bd, $c5, $cd, $d5, $dd, $e5, $ed, $f5, $be, $c6, $ce, $d6, $de, $e6, $ee, $f6
	db $bf, $c7, $cf, $d7, $df, $e7, $ef, $f7, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $14, $27, $05, $56, $23, $27, $0d, $54
	db $23, $30, $1c, $58, $22, $27, $8b, $54, $01, $27, $93, $56, $01, $30, $7c, $58
	db $04, $42, $34, $62, $05, $42, $3c, $64, $05, $42, $44, $66, $05, $42, $4c, $68
	db $05, $42, $54, $6a, $05, $42, $5c, $6c, $05, $42, $64, $6e, $05, $52, $34, $70
	db $05, $52, $3c, $72, $05, $52, $44, $74, $05, $52, $4c, $76, $05, $52, $54, $78
	db $05, $52, $5c, $7a, $05, $52, $64, $7c, $05, $08, $3d, $41, $00, $07, $3d, $49
	db $02, $07, $3d, $51, $04, $07, $3d, $59, $06, $07, $4d, $41, $08, $07, $4d, $49
	db $0a, $07, $4d, $51, $0c, $07, $4d, $59, $0e, $07, $0c, $2d, $40, $10, $07, $2d
	db $48, $12, $07, $2d, $50, $14, $07, $2d, $58, $16, $07, $3d, $40, $18, $07, $3d
	db $48, $1a, $07, $3d, $50, $1c, $07, $3d, $58, $1e, $07, $4d, $40, $20, $07, $4d
	db $48, $22, $07, $4d, $50, $24, $07, $4d, $58, $26, $07, $0c, $2d, $3f, $28, $07
	db $2d, $47, $2a, $07, $2d, $4f, $2c, $07, $2d, $57, $2e, $07, $3d, $3f, $30, $07
	db $3d, $47, $32, $07, $3d, $4f, $34, $07, $3d, $57, $36, $07, $4d, $3f, $38, $07
	db $4d, $47, $3a, $07, $4d, $4f, $3c, $07, $4d, $57, $3e, $07, $0c, $2d, $40, $40
	db $07, $2d, $48, $42, $07, $2d, $50, $44, $07, $2d, $58, $46, $07, $3d, $40, $48
	db $07, $3d, $48, $4a, $07, $3d, $50, $4c, $07, $3d, $58, $4e, $07, $4d, $40, $50
	db $07, $4d, $48, $52, $07, $4d, $50, $00, $0f, $4d, $58, $02, $0f, $0c, $2d, $41
	db $04, $0f, $2d, $49, $06, $0f, $2d, $51, $08, $0f, $2d, $59, $0a, $0f, $3d, $41
	db $0c, $0f, $3d, $49, $0e, $0f, $3d, $51, $10, $0f, $3d, $59, $12, $0f, $4d, $41
	db $14, $0f, $4d, $49, $16, $0f, $4d, $51, $18, $0f, $4d, $59, $1a, $0f, $0c, $2e
	db $3f, $1c, $0f, $2e, $47, $1e, $0f, $2e, $4f, $20, $0f, $2e, $57, $22, $0f, $3e
	db $3f, $24, $0f, $3e, $47, $26, $0f, $3e, $4f, $28, $0f, $3e, $57, $2a, $0f, $4e
	db $3f, $2c, $0f, $4e, $47, $2e, $0f, $4e, $4f, $30, $0f, $4e, $57, $32, $0f, $0c
	db $2d, $41, $34, $0f, $2d, $49, $36, $0f, $2d, $51, $38, $0f, $2d, $59, $3a, $0f
	db $3d, $41, $3c, $0f, $3d, $49, $3e, $0f, $3d, $51, $40, $0f, $3d, $59, $42, $0f
	db $4d, $41, $44, $0f, $4d, $49, $46, $0f, $4d, $51, $48, $0f, $4d, $59, $4a, $0f

