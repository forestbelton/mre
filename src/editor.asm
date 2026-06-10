; Save-to-SRAM + the level editor (layout/room_bonus_* / room_unused_* are its room data)
; Carved out of analyzed.asm (byte-exact: section names + placement unchanged).

INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "sound_ids.inc"

SECTION "analyzed_048000", ROMX[$4000], BANK[$12]

Func_12_4000:
	ld e, [hl]
	ld a, $ee
	rst AddAToHL
	ld a, [hl]
	ld d, a
	cp $40
	jr nz, Func_12_4014
	ld a, b
	ld [wSpawnCellY], a
	ld a, c
	ld [wSpawnCellX], a
	ld a, d
	ret

Func_12_4014:
	cp $c0
	jr z, Func_12_401e
	cp $80
	jr z, Func_12_401e
	jr Func_12_4026
Func_12_401e:
	ld a, b
	ld [$c531], a
	ld a, c
	ld [$c530], a
Func_12_4026:
	ld a, e
	cp $00
	ret nz
	ld a, d
	ret

Func_12_402c:
	ld bc, $0100
	ld hl, wFloorCollision
	ld a, $11
	rst AddAToHL
Func_12_4035:
	xor a
	cp c
	jr z, Func_12_4042
	ld a, [wFloorWidth]
	dec a
	cp c
	jr z, Func_12_4046
	jr Func_12_4057
Func_12_4042:
	inc c
	inc hl
	jr Func_12_4057
Func_12_4046:
	ld c, $00
	inc b
	ld a, [wFloorRowStride]
	inc a
	rst AddAToHL
	ld a, [wFloorHeight]
	dec a
	cp b
	jr z, Func_12_406e
	jr Func_12_4035
Func_12_4057:
	push bc
	push hl
	ld a, [hl]
	or a
	jr nz, Func_12_4068
	ld a, $ee
	rst AddAToHL
	ld a, [hl]
	bit 7, a
	jr z, Func_12_4068
	call DrawFloorPiece
Func_12_4068:
	pop hl
	pop bc
	inc c
	inc hl
	jr Func_12_4035
Func_12_406e:
	ret

Func_12_406f:
	call WaitForHBlank
	ld hl, $66a4
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

Func_12_4094:
	ld a, [wRoomType]
	cp $02
	jr nz, Func_12_40a6
	ld a, [wActiveFloor]
	cp $05
	jr nz, Func_12_40a6
	call Func_12_406f
	ret

Func_12_40a6:
	xor a
	ldh [rVBK], a
	ld a, [wFloorHeight]
	dec a
	add a, a
	dec a
	ld e, a
	ld [$d0e7], a
	ld hl, $9801
Func_12_40b6:
	ld a, $1f
	rst AddAToHL
	ld bc, $0001
	ld d, $02
	call FillVram
	dec e
	jr z, Func_12_40ec
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
	jr z, Func_12_40ec
	ld a, $1f
	rst AddAToHL
	ld bc, $0001
	ld d, $05
	call FillVram
	dec e
	jr Func_12_40b6
Func_12_40ec:
	ld a, [wFloorWidth]
	dec a
	add a, a
	dec a
	ld e, a
	ld [$d0e8], a
Func_12_40f6:
	ld bc, $0001
	ld d, $0a
	call FillVram
	dec e
	jr z, Func_12_4120
	ld bc, $0001
	ld d, $0b
	call FillVram
	dec e
	ld bc, $0001
	ld d, $0c
	call FillVram
	dec e
	jr z, Func_12_4120
	ld bc, $0001
	ld d, $0d
	call FillVram
	dec e
	jr Func_12_40f6
Func_12_4120:
	ld a, [$d0e7]
	dec a
	ld e, a
	ld a, [wFloorWidth]
	dec a
	add a, a
	dec a
	ld hl, $9801
	rst AddAToHL
Func_12_412f:
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
	jr z, Func_12_4163
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
	jr nz, Func_12_412f
Func_12_4163:
	ld a, $01
	ldh [rVBK], a
	ld a, [$d0e7]
	ld e, a
	ld hl, $9801
Func_12_416e:
	ld a, $1f
	rst AddAToHL
	ld bc, $0001
	ld d, $02
	call FillVram
	dec e
	jr nz, Func_12_416e
	ld a, [$d0e8]
	ld e, a
Func_12_4180:
	ld bc, $0001
	ld d, $02
	call FillVram
	dec e
	jr nz, Func_12_4180
	ld a, [$d0e7]
	dec a
	ld e, a
	ld a, [wFloorWidth]
	dec a
	add a, a
	dec a
	ld hl, $9801
	rst AddAToHL
Func_12_419a:
	ld a, $1f
	rst AddAToHL
	ld bc, $0001
	ld d, $02
	call FillVram
	dec e
	jr nz, Func_12_419a
	ret
	ld bc, $0100
	ld hl, wFloorCollision
	ld a, $11
	rst AddAToHL
Func_12_41b2:
	xor a
	cp c
	jr z, Func_12_41bf
	ld a, [wFloorWidth]
	dec a
	cp c
	jr z, Func_12_41c3
	jr Func_12_41d4
Func_12_41bf:
	inc c
	inc hl
	jr Func_12_41d4
Func_12_41c3:
	ld c, $00
	inc b
	ld a, [wFloorRowStride]
	inc a
	rst AddAToHL
	ld a, [wFloorHeight]
	dec a
	cp b
	jr z, Func_12_41e8
	jr Func_12_41b2
Func_12_41d4:
	push bc
	push hl
	call Func_12_4000
	bit 7, a
	jr z, Func_12_41df
	ld a, $00
Func_12_41df:
	call DrawFloorPiece
	pop hl
	pop bc
	inc c
	inc hl
	jr Func_12_41b2
Func_12_41e8:
	ret
Func_12_41e9:
	FAR_CALL $15, Func_15_4015
	call Func_12_41f5
	ret
Func_12_41f5:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyPressed]
	ld b, a
	ld a, [$c55d]
	bit 4, b
	jr z, Func_12_4218
	cp $04
	jr nc, Func_12_41f5
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	inc a
	cp $03
	jr nz, Func_12_4271

Data_12_4215:
	db $af, $18, $59

Func_12_4218:
	bit 5, b
	jr z, Func_12_4230
	cp $04
	jr nc, Func_12_41f5
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	dec a
	cp $80
	jr c, Func_12_4271

Data_12_422c:
	db $3e, $02, $18, $41

Func_12_4230:
	bit 7, b
	jr z, Func_12_423f
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	xor $04
	jr Func_12_4271
Func_12_423f:
	bit 6, b
	jr z, Func_12_424e

Data_12_4243:
	db $f5, $3e, $04, $cd, $85, $0a, $f1, $ee, $04, $18, $23

Func_12_424e:
	bit 0, b
	jr z, Func_12_425b
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	jr Func_12_4287
Func_12_425b:
	ld a, [$cfbe]
	or a
	jr nz, Func_12_41f5
	bit 1, b
	jp z, Func_12_41f5

Data_12_4266:
	db $f5, $3e, $0e, $cd, $85, $0a, $f1, $3e, $04, $18, $16

Func_12_4271:
	ld [$c55d], a
	FAR_CALL $15, Func_15_408a
	FAR_CALL $15, Func_15_41cf
	jp Func_12_41f5
Func_12_4287:
	cp $04
	jr c, Func_12_4291
	ld [wActiveFloor], a
	ld a, $01
	ret
Func_12_4291:
	ld [wActiveFloor], a
	xor a
	ret
Func_12_4296:
	xor a
	ld [$c55e], a
Func_12_429a:
	FAR_CALL $15, Func_15_410f
Func_12_42a2:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyPressed]
	ld b, a
	ld a, [$c55e]
	call Func_00_32ae
	bit 4, b
	jr z, Func_12_42c4
	cp $04
	jr nc, Func_12_42a2
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	xor $01
	jr Func_12_431d
Func_12_42c4:
	bit 5, b
	jr z, Func_12_42d7
	cp $04
	jr nc, Func_12_42a2
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	xor $01
	jr Func_12_431d
Func_12_42d7:
	bit 7, b
	jr z, Func_12_42ec
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	add a, $02
	cp $06
	jr c, Func_12_431d

Data_12_42e8:
	db $e6, $01, $18, $31

Func_12_42ec:
	bit 6, b
	jr z, Func_12_4301
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	sub $02
	cp $80
	jr c, Func_12_431d

Data_12_42fd:
	db $e6, $05, $18, $1c

Func_12_4301:
	bit 0, b
	jr z, Func_12_430e
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	jr Func_12_432a
Func_12_430e:
	bit 1, b
	jr z, Func_12_4324

Data_12_4312:
	db $f5, $3e, $0e, $cd, $85, $0a, $f1, $3e, $04, $18, $0d

Func_12_431d:
	ld c, a
	call Func_12_43fe
	jp Func_12_42a2
Func_12_4324:
	call Func_00_3460
	jp Func_12_42a2
Func_12_432a:
	cp $00
	jr z, Func_12_433e
	cp $01
	jr z, Func_12_4368
	cp $02
	jr z, Func_12_437a
	cp $03
	jp z, Func_12_43dd
	jp Func_12_43e3
Func_12_433e:
	call Func_00_212c
	ld a, [$c55f]
	cp $02
	jr c, Func_12_434b

Data_12_4348:
	db $c3, $9a, $42

Func_12_434b:
	ld a, $05
	ld [wRoomType], a
	call LoadFloorByMode
	FAR_CALL $10, Func_10_4041
	FAR_CALL $11, LoadAllFloorMonsterSprites
	call Func_00_2df6
	xor a
	ret

Func_12_4368:
	call Func_00_217d
	or a
	jp nz, Func_12_429a
	FAR_CALL $12, Func_12_4ab8
	jp Func_12_429a
Func_12_437a:
	ld a, $04
	ld [wRoomType], a
	call Func_00_1298
	call Func_00_2fa2
	jr z, Func_12_4390
	ld hl, $5230
	call Func_00_3450
	jp Func_12_42a2
Func_12_4390:
	ld a, $05
	ld [wRoomType], a
	FAR_CALL $05, Func_05_47c6
	FAR_CALL $00, Func_00_3508
	FAR_CALL $01, Func_01_439e
	call ResetScrollState
	call LoadFloorByMode
	FAR_CALL $10, Func_10_4041
	FAR_CALL $11, LoadAllFloorMonsterSprites
	FAR_CALL $15, Func_15_41fe
	FAR_CALL $15, Func_15_4134
	push af
	ld a, SOUND_BGM_Bodka
	call PlaySoundTracked
	pop af
	jp Func_12_429a

Func_12_43dd:
	call Func_00_2223
	jp Func_12_429a
Func_12_43e3:
	ld a, $01
	ret

Data_12_43e6:
	db $e1, $98

Data_12_43e8:
	db $eb, $98

Data_12_43ea:
	db $21, $99, $2b, $99

Data_12_43ee:
	db $65, $99

Data_12_43f0:
	db $65, $99, $c8, $47

Data_12_43f4:
	db $10, $48

Data_12_43f6:
	db $58, $48, $a0, $48

Data_12_43fa:
	db $e8, $48

Data_12_43fc:
	db $e8, $48

Func_12_43fe:
	ld e, c
	ld a, $01
	ldh [rVBK], a
	ld a, [$c55e]
	cp $04
	jr nc, Func_12_440e
	ld b, $08
	jr Func_12_4410

Func_12_440e:
	ld b, $0a

Func_12_4410:
	add a, a
	ld hl, $43e6
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
	ld hl, $43e6
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call Func_00_31d5
	ld a, e
	ld [$c55e], a
	add a, a
	ld hl, $43f2
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call Func_00_33fb
	ret
Func_12_4441:
	push bc
	FAR_CALL $15, Func_15_4147
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

Data_12_44af:
	db $41, $98, $4b, $98, $a1, $98, $ab, $98, $01, $99, $0b, $99, $65, $99, $65, $99
	db $c0, $49, $08, $4a, $50, $4a, $98, $4a, $e0, $4a, $28, $4b, $70, $4b, $70, $4b

Func_12_44cf:
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
Func_12_44d6:
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
	ld hl, $44af
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
	ld hl, $44af
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call Func_00_31d5
	ld a, e
	ld [wMenuId], a
	add a, a
	ld hl, $44bf
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call Func_00_33fb
	ret
Func_12_4519:
	call Func_00_2d88
	jr z, Func_12_452d

Data_12_451e:
	db $fa, $68, $c5, $fe, $21, $28, $1c, $fe, $22, $28, $18, $fe, $42, $28, $14

Func_12_452d:
	ld a, [wEditCursorY]
	ld b, a
	ld a, [wEditCursorX]
	ld c, a
	ld a, [$c2eb]
	cp b
	jr nz, Func_12_4548

Func_12_453b:
	ld a, [$c2ea]
	cp c
	jr nz, Func_12_4548
	ld hl, $4ff0
	call $3450
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
	call $2ea8
	jp $4686

Func_12_4584:
	ld a, c
	cp $42
	jr nz, Func_12_4597
	ld a, [$c570]
	cp $04
	jr nz, Func_12_4597
	ld hl, $50c8
	call Func_00_3450
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
	call z, Func_00_2efb
	call Func_00_2e62
	jp Func_12_4686

Func_12_45bd:
	call Func_00_2ea8
	jp Func_12_4686
Func_12_45c3:
	ldh a, [$ffac]
	cp $c0
	call z, Func_00_2efb
	ldh a, [$ffac]
	cp c
	jr nz, Func_12_45e3

Data_12_45cf:
	xor a
	ld [de], a
	ldh a, [$ffab]
	ld [$c569], a
	call Func_00_2e62
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
	call Func_00_3450
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
	call z, Func_00_2efb
	call Func_00_2e62
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

Data_12_4695:
	db $fa, $62, $c5, $fe, $00, $20, $4c, $cd, $88, $2d, $28, $07, $21, $a0, $51, $cd
	db $50, $34, $c9, $fa, $65, $c5, $47, $fa, $64, $c5, $4f, $cd, $48, $18, $fe, $00
	db $20, $ea, $f0, $ac, $fe, $00, $20, $e4, $f5, $3e, $01, $cd, $85, $0a, $f1, $fa
	db $65, $c5, $ea, $eb, $c2, $fa, $64, $c5, $ea, $ea, $c2

Func_12_46d0:
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
	call Func_00_20f0
	ret

Data_12_46e8:
	db $fa, $65, $c5, $47, $fa, $64, $c5, $4f, $fa, $eb, $c2, $b8, $20, $0d, $fa, $ea
	db $c2, $b9, $20, $07, $21, $58, $51, $cd, $50, $34, $c9, $fa, $62, $c5, $3d, $5f
	db $cd, $48, $18, $fe, $00, $20, $06, $f0, $ac, $fe, $42, $20, $07, $21, $58, $51
	db $cd, $50, $34, $c9, $cd, $88, $2d, $28, $0c, $fa, $cb, $c7, $bb, $28, $31, $2b
	db $2b, $2b, $2b, $18, $52, $fa, $6e, $c5, $fe, $09, $20, $07, $21, $80, $50, $cd
	db $50, $34, $c9, $21, $d1, $c4, $0e, $00, $7e, $fe, $ff, $28, $33, $23, $23, $23
	db $23, $23, $0c, $3e, $09, $b9, $20, $f0, $f5, $3e, $02, $cd, $85, $0a, $f1, $c9
	db $fa, $6e, $c5, $3d, $ea, $6e, $c5, $3e, $ff, $32, $32, $32, $32, $77, $16, $f0
	db $79, $c6, $10, $0e, $00, $cd, $d1, $20, $f5, $3e, $03, $cd, $85, $0a, $f1, $c9
	db $fa, $6e, $c5, $3c, $ea, $6e, $c5, $fa, $64, $c5, $22, $fa, $65, $c5, $22, $3e
	db $22, $22, $af, $22, $73, $cd, $94, $20, $f5, $3e, $01, $cd, $85, $0a, $f1, $c9

Func_12_4798:
	call Func_12_49c1
	ld a, $00
	ld [$c7df], a
	ld a, $98
	ld [$c7e0], a
	call Func_12_4941
	call Func_00_2e84
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
	call Func_12_490d
	call Func_00_1f71
	pop hl
	pop bc
	inc c
	inc hl
	jr Func_12_47b4
Func_12_47e4:
	ret
Func_12_47e5:
	call Func_12_49df
	ld a, [wRoomType]
	cp $02
	ret z
	cp $06
	ret z
	ld a, [wFloorWidth]
	cp $11
	jr z, Func_12_4804
	ld a, $44
	ld [$c7df], a
	ld a, $9c
	ld [$c7e0], a
	jr Func_12_480e
Func_12_4804:
	ld a, $01
	ld [$c7df], a
	ld a, $9c
	ld [$c7e0], a
Func_12_480e:
	call Func_12_4941
	call Func_00_2e84
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
	call Func_12_490d
	call Func_12_4a17
	pop hl
	pop bc
	inc c
	inc hl
	jr Func_12_481d
Func_12_484d:
	ret
Func_12_484e:
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
	ld hl, $c7f9
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
	call Func_00_20f0
	pop hl
	ld a, $1b
	rst AddAToHL
	jr Func_12_4870
Func_12_48aa:
	ld a, [hl]
	push af
	call Func_00_1290
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
	call Func_00_20f0
	pop hl
	pop af
	push hl
	push de
	sub $30
	cp $10
	jr c, Func_12_48ea

Data_12_48e8:
	db $d6, $02

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
	call Func_00_210d
	pop de
	pop hl
	ld a, $1b
	rst AddAToHL
	jp Func_12_4870
Func_12_490d:
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
	ld [$c531], a
	ld a, c
	ld [$c530], a
Func_12_493b:
	ld a, e
	cp $00
	ret nz
	ld a, d
	ret
Func_12_4941:
	ld a, [$c7df]
	ld l, a
	ld a, [$c7e0]
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
Func_12_49c1:
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
Func_12_49df:
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
Func_12_4a17:
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
	ld a, [$c7df]
	ld l, a
	ld a, [$c7e0]
	ld h, a
Func_12_4a40:
	ld a, $20
	rst AddAToHL
	dec b
	jr nz, Func_12_4a40
	ld a, c
	rst AddAToHL
	call Func_00_1f91
Func_12_4a4b:
	ret

Data_12_4a4c:
	db $52, $4f, $4f, $4d, $31, $00

SECTION "analyzed_048a53", ROMX[$4a53], BANK[$12]

Data_12_4a53:
	db $52, $4f, $4f, $4d, $32, $00

SECTION "analyzed_048a5a", ROMX[$4a5a], BANK[$12]

Data_12_4a5a:
	db $52, $4f, $4f, $4d, $33, $00

SECTION "analyzed_048a61", ROMX[$4a61], BANK[$12]

Data_12_4a61:
	db $4c, $4a, $53, $4a, $5a, $4a, $00, $a0, $4f, $a2, $9e, $a4, $03, $a0, $52, $a2
	db $a1, $a4, $09, $a0

Data_12_4a75:
	db $58, $a2, $a7, $a4

Func_12_4a79:
	call Func_00_09f9
	ld a, [wActiveFloor]
	add a, a
	ld hl, $4a73
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, $0245
	ld de, wFloorSnapshot
	call CopyDEtoHLLong
	ld a, [wActiveFloor]
	add a, a
	ld hl, $4a67
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, $024e
	call Func_00_12ee
	call Func_00_09ff
	ld a, [wActiveFloor]
	ld hl, $c7f6
	rst AddAToHL
	ld a, [wFloorHeight]
	cp $0e
	jr nz, Func_12_4ab5
	ld [hl], $00
	ret

Func_12_4ab5:
	ld [hl], $01
	ret
Func_12_4ab8:
	call Func_00_09f9
	ld a, [wActiveFloor]
	add a, a
	ld b, a
	ld hl, $4a61
	rst AddAToHL
	ld a, [hl+]
	ld d, [hl]
	ld e, a
	ld a, b
	ld hl, $4a6d
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
	ld hl, $4a67
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, $024e
	call Func_00_12ee
	call Func_00_09ff
	ld a, [wActiveFloor]
	add a, a
	ld b, a
	ld hl, $4a61
	rst AddAToHL
	ld a, [hl+]
	ld d, [hl]
	ld e, a
	ld a, b
	ld hl, $12db
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld c, $06
	call CopyDEtoHL
	ld a, [wActiveFloor]
	ld hl, $c7f6
	rst AddAToHL
	ld [hl], $02
	ret

Func_12_4b13:
	call Func_00_09f9
	ld a, [wActiveFloor]
	add a, a
	ld b, a
	ld hl, $12db
	rst AddAToHL
	ld a, [hl+]
	ld d, [hl]
	ld e, a
	ld a, b
	ld hl, $4a6d
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld c, $06
	call CopyDEtoHL
	ld a, [wActiveFloor]
	add a, a
	ld hl, $4a67
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, $024e
	call Func_00_12ee
	call Func_00_09ff
	ret

Data_12_4b44:
	db $cd, $f9, $09, $fa, $c0, $c2, $87, $47, $21, $6d, $4a, $c7, $2a, $56, $5f, $78
	db $21, $db, $12, $c7, $2a, $66, $6f, $0e, $06, $cd, $0b, $03, $cd, $ff, $09, $c9

Data_12_4b64:
	db $56, $30, $33

SaveGameToSram:
	call Func_00_09f9
	ld de, $4b64
	ld hl, wSaveSignature
	ld c, $03
	call CopyDEtoHL
	ld de, wSaveSignature
	ld hl, $a6ed
	ld bc, $0118
	call CopyDEtoHLLong
	ld hl, $a6ed
	ld bc, $0118
	call Func_00_12ee
	call Func_00_09ff
	ret
Func_12_4b8e:
	call Func_00_09f9
	ld hl, $a6ed
	ld bc, $0118
	call Func_00_12e1
	jr z, Func_12_4ba1

Data_12_4b9c:
	db $cd, $ff, $09, $af, $c9

Func_12_4ba1:
	ld de, $a6ed
	ld hl, wSaveSignature
	ld bc, $0118
	call CopyDEtoHLLong
	call Func_00_09ff
	ld a, $01
	ret
Func_12_4bb3:
	call Func_00_09f9
	ld de, $4b64
	ld hl, $a6ed
	ld a, [de]
	cp [hl]
	jr nz, Func_12_4bd2
	inc de
	inc hl
	ld a, [de]
	cp [hl]
	jr nz, Func_12_4bd2
	inc de
	inc hl
	ld a, [de]
	cp [hl]
	jr nz, Func_12_4bd2
	call Func_00_09ff
	ld a, $01
	ret
Func_12_4bd2:
	call Func_00_09ff
	xor a
	ret
Func_12_4bd7:
	ld de, $4b64
	ld a, [de]
	cp [hl]
	jr nz, Func_12_4bed
	inc de
	inc hl
	ld a, [de]
	cp [hl]
	jr nz, Func_12_4bed
	inc de
	inc hl
	ld a, [de]
	cp [hl]
	jr nz, Func_12_4bed
	ld a, $01
	ret
Func_12_4bed:
	xor a
	ret
Func_12_4bef:
	call Func_00_09f9
	ld hl, $a6ed
	ld bc, $0118
	call Func_00_12e1
	jr z, Func_12_4c02

Data_12_4bfd:
	db $cd, $ff, $09, $af, $c9

Func_12_4c02:
	ld de, $a6f0
	ld hl, wHiScore
	ld c, $05
	call CopyDEtoHL
	call Func_00_09ff
	ld a, $01
	ret
Func_12_4c13:
	call Func_00_09f9
	xor a
	ld [$d0e7], a
Func_12_4c1a:
	ld a, [$d0e7]
	add a, a
	ld hl, $4a67
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call Func_12_4bd7
	or a
	jr z, Func_12_4c3e
	ld a, [$d0e7]
	add a, a
	ld hl, $4a67
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, $024e
	call Func_00_12e1
	jr z, Func_12_4c83
Func_12_4c3e:
	ld a, [$d0e7]
	add a, a
	ld hl, $4a67
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $4b64
	ld c, $03
	call CopyDEtoHL
	ld a, [$d0e7]
	add a, a
	ld b, a
	ld hl, $4a61
	rst AddAToHL
	ld a, [hl+]
	ld d, [hl]
	ld e, a
	ld a, b
	ld hl, $4a6d
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
	ld hl, $4a67
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, $024e
	call Func_00_12ee
Func_12_4c83:
	ld a, [$d0e7]
	add a, a
	ld b, a
	ld hl, $4a6d
	rst AddAToHL
	ld a, [hl+]
	ld d, [hl]
	ld e, a
	ld a, b
	ld hl, $12db
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld c, $06
	call CopyDEtoHL
	ld [hl], $00
	ld a, [$d0e7]
	ld hl, $c7f6
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
	call Func_00_09ff
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
