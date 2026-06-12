; Full-screen draw routines: Town/Title/Intro/Tower screens (gfx/screen/* holds their data)
; Carved out of analyzed.asm (byte-exact: section names + placement unchanged).

INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "scene.inc"
INCLUDE "sound_ids.inc"

SECTION "analyzed_0c0000", ROMX[$4000], BANK[$30]

Func_30_4000:
	ld d, b
	ld c, h
	ld b, c
	ld e, c
	nop
	ld b, l
	ld b, h
	ld c, c
	ld d, h
	nop

Data_30_400a:
	db $d9, $41, $dd, $41, $06, $42, $2f, $42, $54, $42, $00, $98, $42, $99, $ac, $98
	db $4c, $99, $a3, $98

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
	ld a, [$d0fb]
	ld b, $02
	add a, b
	ld b, a
Func_30_405a:
	ld a, b
	cp c
	jp c, Func_30_4077
	push bc
	ld hl, $4014
	ld a, c
	add a, a
	rst AddAToHL
	rst DerefHL
	ld d, h
	ld e, l
	ld hl, $78f3
	ld b, $20
	ld a, c
	call Func_00_35d4
	pop bc
	inc c
	jp Func_30_405a
Func_30_4077:
	ld a, BANK(Data_20_7356)
	ld [wDrawBank], a
	ld hl, Data_20_7356
	ld b, $10
	ld c, $08
	call DrawMetasprite
	call Func_30_42d5
	call HideUnusedOamSprites
	ldh a, [rLCDC]
	set 1, a
	ldh [rLCDC], a
	xor a
	ld b, $08
	ld c, $20
	ld hl, $7000
	call Func_00_09b1
	xor a
	ld b, $08
	ld c, $20
	ld hl, $7040
	call Func_00_09d5
	call Func_30_436c
Func_30_40ab:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyRepeat]
	ld b, a
	bit 7, b
	jr z, Func_30_40c0
	ld a, $03
	call Func_30_41a9
	jp Func_30_4104
Func_30_40c0:
	bit 6, b
	jr z, Func_30_40cc
	ld a, $02
	call Func_30_41a9
	jp Func_30_4104
Func_30_40cc:
	bit 5, b
	jr z, Func_30_40d8
	ld a, $01
	call Func_30_41a9
	jp Func_30_4104
Func_30_40d8:
	bit 4, b
	jr z, Func_30_40e4
	ld a, $00
	call Func_30_41a9
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
	call Func_30_42c2
	jp Func_30_4152
Func_30_4104:
	ld a, [wScreenInput]
	cp $00
	jp z, Func_30_411b
	ld a, [wFadeLevel]
	cp $10
	jr nc, Func_30_411b
	ld a, [$c287]
	and $01
	jp nz, Func_30_4129
Func_30_411b:
	ld hl, $4129
	push hl
	ld a, [wScreenInput]
	add a, a
	ld hl, $400a
	rst AddAToHL
	rst DerefHL
	jp hl
Func_30_4129:
	call Func_30_42ef
	call Func_30_4336
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
	jp Func_30_40ab
Func_30_4152:
	call Func_00_0400
	call Func_00_0786
	call Func_00_07a7
	ld a, [wScreenInput]
	ld [wGameSceneArg], a
	add a, $05
	ld [wGameScene], a
	ret

Data_30_4167:
	db $01, $03

Data_30_4169:
	db $01, $03

Data_30_416b:
	db $ff, $00

Data_30_416d:
	db $ff, $00, $ff, $ff, $ff, $ff

Data_30_4173:
	db $00, $ff

Data_30_4175:
	db $00, $ff, $ff, $ff, $ff, $ff

Data_30_417b:
	db $01, $03

Data_30_417d:
	db $01, $03

Data_30_417f:
	db $ff, $00

SECTION "analyzed_0c0181", ROMX[$4181], BANK[$30]

Data_30_4181:
	db $ff

SECTION "analyzed_0c0182", ROMX[$4182], BANK[$30]

Data_30_4182:
	db $02

SECTION "analyzed_0c0183", ROMX[$4183], BANK[$30]

Data_30_4183:
	db $ff

SECTION "analyzed_0c0184", ROMX[$4184], BANK[$30]

Data_30_4184:
	db $00

SECTION "analyzed_0c0185", ROMX[$4185], BANK[$30]

Data_30_4185:
	db $ff, $ff

SECTION "analyzed_0c0187", ROMX[$4187], BANK[$30]

Data_30_4187:
	db $00

SECTION "analyzed_0c0188", ROMX[$4188], BANK[$30]

Data_30_4188:
	db $ff, $00, $ff, $ff, $ff, $ff, $ff

Data_30_418f:
	db $01, $03, $01, $03, $ff, $00

SECTION "analyzed_0c0195", ROMX[$4195], BANK[$30]

Data_30_4195:
	db $ff

SECTION "analyzed_0c0196", ROMX[$4196], BANK[$30]

Data_30_4196:
	db $02, $ff, $00, $01, $ff, $00, $ff, $04

SECTION "analyzed_0c019e", ROMX[$419e], BANK[$30]

Data_30_419e:
	db $ff

SECTION "analyzed_0c019f", ROMX[$419f], BANK[$30]

Data_30_419f:
	db $00

SECTION "analyzed_0c01a0", ROMX[$41a0], BANK[$30]

Data_30_41a0:
	db $ff

SECTION "analyzed_0c01a1", ROMX[$41a1], BANK[$30]

Data_30_41a1:
	db $ff, $03, $67, $41, $7b, $41, $8f, $41

Func_30_41a9:
	ld d, a
	ld hl, $41a3
	ld a, [$d0fb]
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
	call Func_30_42c2
	ret
	ld a, [wFadeLevel]
	cp $10
	jr c, Func_30_41ef
	ld a, $11
	ld [wFadeLevel], a
	ld a, $04
	add a, $0f
	jr Func_30_41fe
Func_30_41ef:
	call Func_30_42a6
	ld a, $03
	call Func_30_42c9
	ld b, $02
	call Func_30_427d
	add a, $0f
Func_30_41fe:
	ld e, $6e
	ld d, $2c
	call Func_30_428f
	ret
	ld a, [wFadeLevel]
	cp $10
	jr c, Func_30_4218
	ld a, $11
	ld [wFadeLevel], a
	ld a, $04
	add a, $05
	jr Func_30_4227
Func_30_4218:
	call Func_30_42a6
	ld a, $01
	call Func_30_42c9
	ld b, $02
	call Func_30_427d
	add a, $05
Func_30_4227:
	ld e, $72
	ld d, $60
	call Func_30_428f
	ret
	ld a, [wFadeLevel]
	cp $10
	jr c, Func_30_423f
	ld a, $11
	ld [wFadeLevel], a
	ld a, $04
	jr Func_30_424c
Func_30_423f:
	call Func_30_42a6
	ld a, $00
	call Func_30_42c9
	ld b, $02
	call Func_30_427d
Func_30_424c:
	ld e, $1c
	ld d, $60
	call Func_30_428f
	ret
	ld a, [wFadeLevel]
	cp $10
	jr c, Func_30_4266
	ld a, $11
	ld [wFadeLevel], a
	ld a, $04
	add a, $0a
	jr Func_30_4275
Func_30_4266:
	call Func_30_42a6
	ld a, $02
	call Func_30_42c9
	ld b, $02
	call Func_30_427d
	add a, $0a
Func_30_4275:
	ld e, $22
	ld d, $2c
	call Func_30_428f
	ret
Func_30_427d:
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
Func_30_428f:
	ld hl, $78fd
	ld b, $20
	call Func_00_35f9
	ret

Data_30_4298:
	db $f5, $78, $ea, $00, $c1, $f1, $c7, $df, $43, $4a, $cd, $09, $0c, $c9

Func_30_42a6:
	ld hl, Data_20_792f
	ld de, TILEMAP1
	ld b, BANK(Data_20_792f)
	ld a, $04
	call Func_00_35d4
	ldh a, [rLCDC]
	set 5, a
	ldh [rLCDC], a
	ld a, $07
	ldh [rWX], a
	ld a, $70
	ldh [rWY], a
	ret

Func_30_42c2:
	ldh a, [rLCDC]
	and $df
	ldh [rLCDC], a
	ret

Func_30_42c9:
	ld hl, Data_20_792f
	ld de, $9c23
	ld b, BANK(Data_20_792f)
	call Func_00_35d4
	ret

Func_30_42d5:
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

Func_30_42ef:
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

Data_30_4315:
	db $fa, $f6, $d0, $e6, $03, $20, $09, $fa, $f8, $d0, $3d, $ea, $f8, $d0, $18, $00

Func_30_4325:
	FAR_CALL Func_20_796d
	ret

Data_30_432e:
	db $eb, $75, $f3, $75, $fb, $75, $03, $76

Func_30_4336:
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
	call Func_30_4387
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
	call Func_30_4387
Func_30_436b:
	ret

Func_30_436c:
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
	call Func_30_4387
	ret

Func_30_4387:
	ld a, [wScreenAnim]
	add a, a
	ld hl, $432e
	rst AddAToHL
	rst DerefHL
	push hl
	ld a, $02
	ld b, $01
	ld c, $20
	call Func_00_09b1
	pop hl
	xor a
	ld b, $01
	ld c, $20
	call Func_00_09d5
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
	call Func_30_4487
	call Func_30_4494
	call HideUnusedOamSprites
	ldh a, [rLCDC]
	set 1, a
	ldh [rLCDC], a
	xor a
	ld b, $08
	ld c, $22
	ld hl, $7000
	call Func_00_09b1
	xor a
	ld b, $08
	ld c, $22
	ld hl, $7040
	call Func_00_09d5
Func_30_4403:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyRepeat]
	ld b, a
	ld a, [$c55d]
	bit 0, b
	jr z, Func_30_442e
	ld a, [wScreenInput]
	cp $01
	jp z, Func_30_4403
	push af
	ld a, SOUND_SFX_11
	call PlaySound
	pop af
	call Func_30_42c2
	xor a
	ld [wFadeLevel], a
	ld a, $01
	ld [wScreenInput], a
Func_30_442e:
	ld a, [wScreenInput]
	cp $00
	jr nz, Func_30_443d
	ld a, $03
	call Func_30_4487
	jp Func_30_444a
Func_30_443d:
	ld a, [wFadeLevel]
	cp $48
	jr nc, Func_30_445a
	call Func_30_4461
	call Func_30_4484
Func_30_444a:
	call Func_30_4494
	call HideUnusedOamSprites
	ld a, [wFadeLevel]
	inc a
	ld [wFadeLevel], a
	jp Func_30_4403
Func_30_445a:
	call Func_00_0786
	call Func_00_07c5
	ret
Func_30_4461:
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
	call Func_00_35d4
	ret
Func_30_4484:
	ld a, [wScreenPhase]
Func_30_4487:
	ld b, $22
	ld hl, $75d3
	ld d, $69
	ld e, $30
	call Func_00_35f9
	ret
Func_30_4494:
	ld a, $22
	ld [wDrawBank], a
	ld hl, $7356
	ld b, $10
	ld c, $08
	call DrawMetasprite
	ret

Data_30_44a4:
	db $e6, $45, $2d, $46, $8d, $46

DrawRoomStartScreen:
	call Func_00_083c
	xor a
	ld [wFadeLevel], a
	xor a
	ld [wScreenInput], a
	ld [wScreenPhase], a
	ld [wScreenTimer], a
	ld a, [$c55d]
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
	ld b, $23
	ld hl, $73b2
	ld de, $9886
	call BankMapCopyB
	jr Func_30_4524
Func_30_4506:
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
	ld [$d100], a
	call Func_30_476c
Func_30_4524:
	xor a
	ld b, $08
	ld c, $23
	ld hl, $7000
	call Func_00_09b1
	xor a
	ld b, $08
	ld c, $23
	ld hl, $7040
	call Func_00_09d5
	ldh a, [rLCDC]
	set 1, a
	ldh [rLCDC], a
Func_30_4540:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyRepeat]
	ld b, a
	ld a, [$c55d]
	bit 0, b
	jr nz, Func_30_4554
	bit 1, b
	jr z, Func_30_456a
Func_30_4554:
	ld a, [wScreenInput]
	cp $01
	jp z, Func_30_456a
	ld a, $01
	ld [wScreenInput], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	jr Func_30_456a
Func_30_456a:
	ld hl, $4578
	push hl
	ld a, [wScreenPhase]
	add a, a
	ld hl, $44a4
	rst AddAToHL
	rst DerefHL
	jp hl
	ld a, [wScreenPhase]
	cp $03
	jr nc, Func_30_45e2
	ld a, [wFadeLevel]
	srl a
	srl a
	srl a
	and $03
	push af
	ld hl, $7b6a
	ld de, $9800
	ld b, $23
	call Func_00_35d4
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
	call Func_00_35d4
	ld a, [wFadeLevel]
	srl a
	srl a
	push af
	and $03
	ld b, $23
	ld hl, $7b82
	ld d, $20
	ld e, $10
	call Func_00_35f9
	pop af
	add a, $03
	and $03
	ld b, $23
	ld hl, $7b82
	ld d, $20
	ld e, $89
	call Func_00_35f9
	call HideUnusedOamSprites
	ld a, [wFadeLevel]
	inc a
	ld [wFadeLevel], a
	jp Func_30_4540
Func_30_45e2:
	call Func_00_0786
	ret
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
	call Func_30_46f1
	jr Func_30_4672
Func_30_4666:
	cp $05
	jr nz, Func_30_466f
	call Func_30_4712
	jr Func_30_4672
Func_30_466f:
	call Func_30_46a4
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
	call Func_00_07c5
Func_30_468c:
	ret
	ld a, [wFadeLevel]
	cp $48
	jr nc, Func_30_469d
	ld b, $50
	ld c, $48
	call Func_30_4855
	jr Func_30_46a3
Func_30_469d:
	ld a, $03
	ld [wScreenPhase], a
	xor a
Func_30_46a3:
	ret
Func_30_46a4:
	ld a, [wScreenTimer]
	cp $00
	jr nz, Func_30_46db
	ld hl, $73d8
	ld de, $9845
	ld b, $23
	call BankMapCopyB
	call Func_30_47d0
	ld a, [wLives]
	and $0f
	ld hl, $7ba4
	ld de, $98cc
	ld b, $23
	call Func_00_35d4
	ld a, [wLives]
	swap a
	and $0f
	ld hl, $7ba4
	ld de, $98cb
	ld b, $23
	call Func_00_35d4
Func_30_46db:
	ld b, $50
	ld c, $48
	call Func_30_4855
	jr Func_30_46f0

Data_30_46e4:
	db $3e, $02, $ea, $f4, $d0, $af, $ea, $f5, $d0, $cd, $c5, $07

Func_30_46f0:
	ret
Func_30_46f1:
	ld a, [wScreenTimer]
	cp $00
	jr nz, Func_30_4703
	ld hl, $759c
	ld de, $9845
	ld b, $23
	call BankMapCopyB
Func_30_4703:
	jr Func_30_4711

Data_30_4705:
	db $3e, $02, $ea, $f4, $d0, $af, $ea, $f5, $d0, $cd, $c5, $07

Func_30_4711:
	ret
Func_30_4712:
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

Data_30_4742:
	db $fe, $01, $28, $07, $fa, $ec, $c2, $fe, $11, $28, $05, $21, $4c, $7b, $18, $03

Func_30_4752:
	ld hl, $7b2e
	ld de, $98e7
	ld b, $23
	call BankMapCopyB
Func_30_475d:
	jr Func_30_476b

Data_30_475f:
	db $3e, $02, $ea, $f4, $d0, $af, $ea, $f5, $d0, $cd, $c5, $07

Func_30_476b:
	ret
Func_30_476c:
	ld a, [wRoomType]
	cp $01
	jr z, Func_30_4796
	ld a, [$d100]
	swap a
	and $0f
	ld hl, $7b90
	ld de, $9889
	ld b, $23
	call Func_00_35d4
	ld a, [$d100]
	and $0f
	ld hl, $7b90
	ld de, $988a
	ld b, $23
	call Func_00_35d4
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
	call Func_00_35d4
	ld hl, $7a8e
	ld de, $9889
	ld b, $23
	call BankMapCopyB
Func_30_47cb:
	ret

Data_30_47cc:
	db $08, $08, $08, $08

Func_30_47d0:
	ld a, [wRoomType]
	cp $01
	jr z, Func_30_4800
	ld c, $02
	ld a, [$d100]
	swap a
	and $0f
	ld hl, $7b90
	ld de, $986c
	ld b, $23
	call Func_00_35d4
	ld c, $02
	push bc
	ld a, [$d100]
	and $0f
	ld hl, $7b90
	ld de, $986d
	ld b, $23
	call Func_00_35d4
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
	call Func_00_35d4
	ld hl, $7a8e
	ld de, $986c
	ld b, $23
	call BankMapCopyB
Func_30_4838:
	pop bc
	ld de, $986c
	call Func_30_4840
	ret
Func_30_4840:
	ld a, $01
	ldh [rVBK], a
	ld hl, $47cc
	ld b, $02
	call Func_30_486d
	ret

Data_30_484d:
	db $6e, $51, $80, $51, $92, $51, $a4, $51

Func_30_4855:
	ld a, [wFadeLevel]
	and $0f
	srl a
	srl a
	add a, a
	ld hl, $484d
	rst AddAToHL
	rst DerefHL
	ld a, $02
	ld [wDrawBank], a
	call DrawMetasprite
	ret
Func_30_486d:
	push bc
	ld b, $00
	push de
	call VramCopy16
	pop de
	ld a, $20
	rst AddAToDE
	pop bc
	dec b
	jr nz, Func_30_486d
	ret
DrawNextRoomScreen:
	xor a
	ld [wFadeLevel], a
	ld [$d0ff], a
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
	ld [$d100], a
	call Func_30_49fd
	call Func_30_4a3f
	call Func_30_4f10
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
	call Func_30_5023
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
	call Func_00_09b1
	pop hl
	ld a, $40
	rst AddAToHL
	xor a
	ld b, $08
	ld c, $25
	call Func_00_09d5
Func_30_4946:
	call WaitForNextFrame
	ld a, [wFadeLevel]
	cp $2c
	jr nz, Func_30_4957
	ld a, [$d0ff]
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
	ld [$d0ff], a
	ld a, $01
	ld [wScreenInput], a
	call Func_00_07c5
Func_30_4982:
	ld a, [wScreenInput]
	cp $01
	jp nz, Func_30_4997
	ld a, [wFadeLevel]
	cp $48
	jr nc, Func_30_4994
	jp Func_30_4997
Func_30_4994:
	jp Func_30_49e5
Func_30_4997:
	call Func_30_4e9e
	call Func_30_4de3
	call Func_30_4f88
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
	call Func_00_35f9
Func_30_49bc:
	ld a, [wRoomType]
	cp $01
	jr z, Func_30_49c6
	call Func_30_5023
Func_30_49c6:
	call HideUnusedOamSprites
	ld a, [wScreenAnim2]
	cp $c3
	jr c, Func_30_49d1
	add a, a
Func_30_49d1:
	ld a, [wFadeLevel]
	ld c, a
	ld a, [$d0ff]
	ld b, a
	inc bc
	ld a, b
	ld [$d0ff], a
	ld a, c
	ld [wFadeLevel], a
	jp Func_30_4946
Func_30_49e5:
	ldh a, [rLCDC]
	res 5, a
	ldh [rLCDC], a
	call Func_00_0786
	ld a, [wScreenInput]
	ret

SECTION "analyzed_0c09f4", ROMX[$49f4], BANK[$30]

Data_30_49f4:
	db $00, $00, $00, $01, $01, $01, $02, $02, $02

Func_30_49fd:
	ld a, [wRoomType]
	cp $01
	jr z, Func_30_4a2b
	ld a, [$d100]
	swap a
	and $0f
	ld b, a
	cp $00
	jr z, Func_30_4a1a
	ld a, [$d100]
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
	call Func_00_35d4
	jr Func_30_4a3e
Func_30_4a2b:
	ld a, [wActiveFloor]
	ld hl, $49f2
	rst AddAToHL
	ld a, [hl]
	ld b, $24
	ld hl, $65cb
	ld de, $9900
	call Func_00_35d4
Func_30_4a3e:
	ret
Func_30_4a3f:
	ld a, [wRoomType]
	cp $01
	jr z, Func_30_4a59
	ld a, [$d100]
	swap a
	and $0f
	call Func_30_4a75
	ld a, [$d100]
	and $0f
	call Func_30_4a81
	ret
Func_30_4a59:
	ld a, [wActiveFloor]
	cp $0a
	jr nz, Func_30_4a6c
	ld a, $0b
	call Func_30_4a75
	ld a, $0c
	call Func_30_4a81
	jr Func_30_4a74
Func_30_4a6c:
	call Func_30_4a81
	ld a, $0a
	call Func_30_4a75
Func_30_4a74:
	ret

Func_30_4a75:
	ld b, $24
	ld hl, $65d9
	ld de, $9c67
	call Func_00_35d4
	ret

Func_30_4a81:
	ld b, $24
	ld hl, $65d9
	ld de, $9c68
	call Func_00_35d4
	ret

Data_30_4a8d:
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
	db $a8, $10, $a8, $10, $a8, $10, $a7, $11, $a7, $11, $a6, $12, $a6, $12, $a5, $13
	db $a5, $13, $a4, $14, $a4, $14, $a3, $15, $a3, $15, $a2, $16, $a1, $17, $a1, $17
	db $a0, $18, $a0, $18, $9f, $19, $9f, $19, $9e, $1a, $9e, $1a, $9d, $1b, $9d, $1b
	db $9c, $1c, $9b, $1d, $9b, $1d, $9a, $1e, $9a, $1e, $99, $1f, $99, $1f, $98, $20
	db $98, $20, $97, $21, $97, $21, $96, $22, $95, $23, $95, $23, $94, $24, $94, $24
	db $93, $25, $93, $25, $92, $26, $92, $26, $91, $27, $91, $27, $90, $28, $8f, $29
	db $8f, $29, $8e, $2a, $8e, $2a, $8d, $2b, $8d, $2b, $8c, $2c, $8c, $2c, $8b, $2d
	db $8b, $2d, $8a, $2e, $8a, $2e, $89, $2f, $88, $30, $88, $30, $87, $31, $87, $31
	db $86, $32, $86, $32, $85, $33, $85, $33, $84, $34, $84, $34, $83, $35, $82, $36
	db $82, $36, $81, $37, $81, $37, $80, $38, $80, $38, $7f, $39, $7f, $39, $7e, $3a
	db $7e, $3a, $7d, $3b, $7c, $3c, $7c, $3c, $7b, $3d, $7b, $3d, $7a, $3e, $7a, $3e
	db $79, $3f, $79, $3f, $78, $40, $78, $40, $77, $41, $76, $42, $76, $42, $75, $43
	db $75, $43, $74, $44, $74, $44, $73, $45, $73, $45, $72, $46, $72, $46, $71, $47
	db $70, $48, $70, $48, $6f, $48, $6e, $48, $6d, $48, $6c, $48, $6b, $48, $6a, $48
	db $68, $48, $67, $48, $66, $48, $65, $48, $64, $48, $63, $48, $62, $48, $60, $48
	db $5f, $48, $5e, $48, $5d, $48, $5c, $48, $5b, $48, $5a, $48, $58, $48, $58, $48
	db $58, $48, $59, $49, $59, $49, $5a, $4a, $5a, $4a, $5b, $4b, $5c, $4b, $5c, $4c
	db $5d, $4c, $5d, $4d, $5e, $4e, $5f, $4e, $5f, $4f, $60, $4f, $60, $50, $61, $50
	db $62, $51, $62, $51, $63, $52, $63, $53, $64, $53, $64, $54, $65, $54, $66, $55
	db $66, $55, $67, $56, $67, $56, $68, $57, $69, $58, $69, $58, $6a, $59, $6a, $59
	db $6b, $5a, $6c, $5a, $6c, $5b, $6d, $5b, $6d, $5c, $6e, $5d, $6f, $5d, $6f, $5e
	db $70, $5e, $70, $5f, $71, $5f, $71, $60, $72, $60, $73, $61, $73, $62, $74, $62
	db $74, $63, $75, $63, $76, $64, $76, $64, $77, $65, $77, $65, $78, $66, $79, $67
	db $79, $67, $7a, $68, $7a, $68, $7b, $69, $7c, $69, $7c, $6a, $7d, $6a, $7d, $6b
	db $7e, $6c, $7e, $6c, $7f, $6d, $80, $6d, $80, $6e, $81, $6e, $81, $6f, $82, $6f
	db $83, $70, $83, $71, $84, $71, $84, $72, $85, $72, $86, $73, $86, $73, $87, $74
	db $87, $74, $88, $75, $89, $76, $65, $51, $77, $51, $89, $51, $9b, $51, $6e, $51
	db $80, $51, $92, $51, $a4, $51

Func_30_4de3:
	ld a, [$d0ff]
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
	ld hl, $5920
	ld b, $68
	ld c, $78
	call DrawMetasprite
	ld a, [wFadeLevel]
	and $0f
	srl a
	srl a
	add a, a
	ld hl, $4dd3
	rst AddAToHL
	ld a, [wRoomType]
	cp $01
	jr z, Func_30_4e2e
	ld a, [wScreenAnim2]
	cp $5a
	jr nc, Func_30_4e29
	ld a, $08
	rst AddAToHL
Func_30_4e29:
	ld de, $4a8d
	jr Func_30_4e3b
Func_30_4e2e:
	ld a, [wScreenAnim2]
	cp $7e
	jr nc, Func_30_4e38
	ld a, $08
	rst AddAToHL
Func_30_4e38:
	ld de, $4c2f
Func_30_4e3b:
	rst DerefHL
	call Func_30_4e47
	ld a, [wScreenAnim2]
	inc a
	ld [wScreenAnim2], a
Func_30_4e46:
	ret
Func_30_4e47:
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

Func_30_4e66:
	db $01
	sbc a, e

Data_30_4e68:
	db $e2, $9a, $c2, $9a, $a2, $9a, $82, $9a

Data_30_4e70:
	db $41, $9a

Data_30_4e72:
	db $22, $9a, $02, $9a, $e2, $99, $c2, $99

Data_30_4e7a:
	db $82, $99

Data_30_4e7c:
	db $62, $99, $42, $99, $22, $99, $02, $99

Func_30_4e84:
	db $10
	sub b

Data_30_4e86:
	db $18, $88, $18, $80, $18, $78, $18, $70, $10, $60, $18, $58, $18, $50, $18, $48
	db $18, $40, $10, $30, $20, $40, $60, $80

Func_30_4e9e:
	ld a, [wFadeLevel]
	bit 4, a
	jp z, Func_30_4f0f
	ld a, [wRoomType]
	cp $01
	jr z, Func_30_4ee5
	ld a, [$d100]
	and $0f
	ld c, a
	cp $05
	jr z, Func_30_4ec6
	cp $00
	jr nz, Func_30_4ecb
	ld a, [$d100]
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
	ld hl, $4e84
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
	ld hl, $4e9a
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
Func_30_4f10:
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
	ld hl, $4e66
	rst AddAToHL
	rst DerefHL
	ld a, l
	ld e, a
	ld a, h
	ld d, a
	ld b, $24
	ld hl, $65f3
	ld a, $00
	call Func_00_35d4
Func_30_4f82:
	pop bc
	inc c
	jp Func_30_4f38
Func_30_4f87:
	ret
Func_30_4f88:
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
	ld hl, $4e9a
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
Func_30_5023:
	ld a, $24
	ld [wDrawBank], a
	ld hl, $592d
	ld b, $10
	ld c, $50
	call DrawMetasprite
	ret

Data_30_5033:
	db $5e, $51, $7c, $51, $43, $52, $b1, $52

DrawRoomClearScreen:
	xor a
	ld [wFadeLevel], a
	ld [wScreenInput], a
	ld [wScreenPhase], a
	ld [wScreenTimer], a
	ld a, [wFloorTimer]
	ld [$d101], a
	ld a, [wFloorTimer+1]
	ld [$d102], a
	ld a, [wFloorTimer+2]
	ld [$d103], a
	ld a, [wScore]
	ld [$d104], a
	ld a, [$c2c7]
	ld [$d105], a
	ld a, [$c2c8]
	ld [$d106], a
	ld a, [$c2c9]
	ld [$d107], a
	ld a, [$c2ca]
	ld [$d108], a
	ld a, $48
	ld [$d0f9], a
	ld a, $88
	ld [$d0fa], a
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
	FAR_CALL Func_21_7409
	xor a
	ld b, $08
	ld c, $21
	ld hl, $7000
	call Func_00_09b1
	xor a
	ld b, $08
	ld c, $21
	ld hl, $7040
	call Func_00_09d5
	ldh a, [rLCDC]
	set 1, a
	ldh [rLCDC], a
Func_30_50d7:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyRepeat]
	ld b, a
	ld a, [$c55d]
	ld hl, $50f1
	push hl
	ld a, [wScreenPhase]
	add a, a
	ld hl, $5033
	rst AddAToHL
	rst DerefHL
	jp hl
	ld a, [wScreenPhase]
	cp $04
	jr nc, Func_30_512e
	FAR_CALL Func_21_73e4
	FAR_CALL Func_21_73ac
	ld a, [wScreenFrame]
	cp $00
	jr nz, Func_30_5121
	ld a, [wScreenPhase]
	cp $02
	jr c, Func_30_5121
	ld a, [$d0fa]
	ld b, a
	ld a, [$d0f9]
	ld c, a
	call Func_30_4855
Func_30_5121:
	call HideUnusedOamSprites
	ld a, [wFadeLevel]
	inc a
	ld [wFadeLevel], a
	jp Func_30_50d7
Func_30_512e:
	call Func_00_07c5
	call Func_00_0786
	ld a, [wScreenFrame]
	cp $00
	jr nz, Func_30_5142
	ld a, [wScreenInput]
	cp $00
	jr nz, Func_30_514b
Func_30_5142:
	FAR_CALL Func_01_4654
	ret
Func_30_514b:
	ld a, $04
	ld [wC2D7], a
	FAR_CALL Func_18_6b71
	ld a, SCENE_TOWN
	ld [wGameScene], a
	ret
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

Data_30_51a0:
	db $21, $c6, $c2, $3e, $99, $22, $22, $22, $22, $af, $77

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
Func_30_51c2:
	ld hl, wFloorTimer
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
	ld hl, $d104
	ld de, $d101
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
	ld a, [$d104]
	ld [wScore], a
	ld a, [$d105]
	ld [$c2c7], a
	ld a, [$d106]
	ld [$c2c8], a
	ld a, [$d107]
	ld [$c2c9], a
	ld a, [$d108]
	ld [$c2ca], a
	or a
	jr z, Func_30_5219

Data_30_520e:
	db $21, $c6, $c2, $3e, $99, $22, $22, $22, $22, $af, $77

Func_30_5219:
	ld a, [wScreenFrame]
	cp $00
	jr nz, Func_30_5236
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
	ld [$d0fa], a
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
	ld [$d0fa], a
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
	call Func_30_5408
	call HideUnusedOamSprites
	xor a
	ld b, $08
	ld c, $26
	ld hl, $7000
	call Func_00_09b1
	xor a
	ld b, $08
	ld c, $26
	ld hl, $7040
	call Func_00_09d5
	ldh a, [rLCDC]
	set 1, a
	ldh [rLCDC], a
Func_30_5324:
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
	jr nc, Func_30_53b7
	ld a, [wScreenPhase]
	cp $02
	jr c, Func_30_5368
	ld a, [wScreenInput]
	cp $00
	jr nz, Func_30_53b7
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
	call Func_30_53be
	call Func_30_53cd
	ld a, [wScreenTimer]
	inc a
	ld [wScreenTimer], a
Func_30_53a0:
	call Func_30_53dd
	call Func_30_5408
	call HideUnusedOamSprites
	ld a, [wFadeLevel]
	ld b, a
	and $80
	inc b
	or b
	ld [wFadeLevel], a
	jp Func_30_5324
Func_30_53b7:
	call Func_00_0786
	call Func_00_07c5
	ret
Func_30_53be:
	ld a, [wScreenPhase]
	ld b, $26
	ld hl, $768c
	ld de, $98c5
	call Func_00_35d4
	ret
Func_30_53cd:
	ld a, [wScreenPhase]
	ld b, $26
	ld hl, $7694
	ld d, $48
	ld e, $30
	call Func_00_35f9
	ret
Func_30_53dd:
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
	call Func_00_35d4
	pop af
	ld b, $26
	ld hl, $76aa
	ld de, $98e0
	call Func_00_35d4
	ret
Func_30_5408:
	ld a, $26
	ld [wDrawBank], a
	ld hl, $7356
	ld b, $10
	ld c, $08
	call DrawMetasprite
	ret

SECTION "analyzed_0c147f", ROMX[$547f], BANK[$30]

Func_30_547f:
	rst CheckCgb
	ret nz
	call $02e6
	ld a, $80
	ldh [$ff40], a
	xor a
	ldh [$ff4f], a
	ld a, $27
	ld hl, $5ade
	ld de, $8800
	ld bc, $1000
	call $392d
	ld b, $27
	ld hl, $6ade
	ld de, $9800
	call $35e9
	call $02d1
	ld a, $1b
	ldh [$ff47], a
	call $02e6
	ld a, $81
	ldh [$ff40], a
	call $02e6
	jp $54b2

LoadTitleScreen:
	xor a
	ld [wFadeLevel], a
	ld [$d0ff], a
	ld [wScreenInput], a
	ld [wScreenTimer], a
	ld [wScreenFrame], a
	ld [wScreenAnim], a
	FAR_CALL Func_05_4843
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
	call Func_30_5698
	call Func_30_565c
	call LoadWhitePalettes
	ld b, BANK(TitlePalettes)
	ld de, TitlePalettes
	call LoadPalettesBanked
	call Func_00_0794
Func_30_552f:
	call WaitForNextFrame
	call ReadJoypad
	ld a, [wScreenInput]
	cp $00
	jr z, Func_30_5571
	cp $01
	jr z, Func_30_559d
	cp $02
	jr z, Func_30_55a6
	jp $55ca
Func_30_5547:
	call Func_30_565c
	ld a, [wFadeLevel]
	add a, $01
	ld [wFadeLevel], a
	ld a, [$d0ff]
	adc a, $00
	ld [$d0ff], a
	jp Func_30_552f
Func_30_555d:
	ld a, SCENE_TOWN
	ld [wGameScene], a
	ld c, $5a
Func_30_5564:
	call WaitForNextFrame
	dec c
	jr nz, Func_30_5564
	call Func_00_07a7
	call Func_00_0786
	ret
Func_30_5571:
	ldh a, [hJoyRepeat]
	cp $00
	jr z, Func_30_5547
	ld b, BANK(Data_28_737c)
	ld hl, Data_28_737c
	ld de, $9966
	call BankMapCopyB
	call Func_30_56d3
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
	jr Func_30_5547
Func_30_559d:
	call Func_30_55fa
	call Func_30_566c
	jp Func_30_5547
Func_30_55a6:
	ld a, [wScreenTimer]
	and a
	jr z, Func_30_555d
	FAR_CALL LoadGameFromSram
	and a
	jr nz, Func_30_555d

Data_30_55b7:
	db $06, $28, $21, $cc, $73, $11, $a1, $99, $cd, $e9, $35, $3e, $03, $ea, $f3, $d0
	db $c3, $47, $55, $f0, $8d, $fe, $00, $ca, $47, $55, $cd, $f8, $56, $06, $28, $21
	db $7c, $73, $11, $66, $99, $cd, $e9, $35, $3e, $01, $ea, $f3, $d0, $af, $ea, $fe
	db $d0, $ea, $ff, $d0, $ea, $f4, $d0, $ea, $f5, $d0, $ea, $f6, $d0, $ea, $f7, $d0
	db $ca, $47, $55

Func_30_55fa:
	ldh a, [hJoyRepeat]
	ld b, a
	ld a, [wScreenPhase]
	cp $00
	jr z, Func_30_5636
	bit 7, b
	jr z, Func_30_561d
	ld a, [wScreenTimer]
	cp $01
	jr z, Func_30_5646
	ld a, $01
	ld [wScreenTimer], a
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	jr Func_30_5646
Func_30_561d:
	bit 6, b
	jr z, Func_30_5636
	ld a, [wScreenTimer]
	cp $00
	jr z, Func_30_5646
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ld a, $00
	ld [wScreenTimer], a
	jr Func_30_5646
Func_30_5636:
	bit 0, b
	jr z, Func_30_5646
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ld a, $02
	ld [wScreenInput], a
Func_30_5646:
	ld a, $28
	ld [$d0f9], a
	ld a, [wScreenTimer]
	cp $00
	jr nz, Func_30_5656
	ld a, $68
	jr Func_30_5658
Func_30_5656:
	ld a, $78
Func_30_5658:
	ld [$d0fa], a
	ret
Func_30_565c:
	ld a, $28
	ld [wDrawBank], a
	ld b, $10
	ld c, $08
	ld hl, $74c6
	call DrawMetasprite
	ret
Func_30_566c:
	ld b, $28
	ld hl, $753f
	ld a, [$d0fa]
	ld d, a
	ld a, [$d0f9]
	ld e, a
	ld a, [wScreenAnim]
	call Func_00_35f9
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
Func_30_5698:
	call WaitForHBlank
	ld hl, wHiScore
	ld de, $99ad
	ld a, [hl]
	call Func_00_3635
	ld a, [hl+]
	swap a
	call Func_00_3635
	call WaitForHBlank
	ld a, [hl]
	call Func_00_3635
	ld a, [hl+]
	swap a
	call Func_00_3635
	call WaitForHBlank
	ld a, [hl]
	call Func_00_3635
	ld a, [hl+]
	swap a
	call Func_00_3635
	call WaitForHBlank
	ld a, [hl]
	call Func_00_3635
	ld a, [hl]
	swap a
	call Func_00_3635
	ret
Func_30_56d3:
	call WaitForHBlank
	ld de, $99ad
	call Func_30_5751
	call Func_30_5751
	call Func_30_5751
	call WaitForHBlank
	call Func_30_5751
	call Func_30_5751
	call Func_30_5751
	call WaitForHBlank
	call Func_30_5751
	call Func_30_5751
	ret

Data_30_56f8:
	db $11, $b2, $99, $0e, $03, $c5, $cd, $d1, $02, $cd, $51, $57, $cd, $51, $57, $cd
	db $51, $57, $cd, $d1, $02, $cd, $51, $57, $cd, $51, $57, $cd, $51, $57, $cd, $d1
	db $02, $cd, $51, $57, $cd, $51, $57, $cd, $51, $57, $cd, $d1, $02, $cd, $51, $57
	db $cd, $51, $57, $cd, $51, $57, $cd, $d1, $02, $cd, $51, $57, $cd, $51, $57, $cd
	db $51, $57, $cd, $d1, $02, $cd, $51, $57, $cd, $51, $57, $cd, $51, $57, $c1, $21
	db $32, $00, $19, $54, $5d, $0d, $20, $ad, $c9

Func_30_5751:
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

Data_30_5760:
	db $ed, $58, $54, $59, $c4, $59, $58, $5a, $b0, $5a, $05, $5b, $66, $5b, $ca, $5b
	db $6b, $5c, $c8, $5c, $24, $5d, $5e, $5d, $cf, $5d, $54, $5e, $d9, $5e

DrawIntroBookScreen:
	xor a
	ld [wFadeLevel], a
	ld [wScreenInput], a
	ld [wScreenPhase], a
	ld [wScreenTimer], a
	ld [wScreenFrame], a
	call Func_30_5816
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
	call Func_00_0794
	push af
	ld a, SOUND_BGM_Intro
	call PlaySoundTracked
	pop af
Func_30_57d4:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyRepeat]
	and a
	jr nz, Func_30_5809
	ld a, [wScreenInput]
	cp $0f
	jr nc, Func_30_5809
	ld a, [wScreenPhase]
	and a
	jr nz, Func_30_57ef
	call Func_30_6007
Func_30_57ef:
	ld a, [wScreenInput]
	ld hl, $57fd
	push hl
	add a, a
	ld hl, $5760
	rst AddAToHL
	rst DerefHL
	jp hl
	call HideUnusedOamSprites
	ld a, [wFadeLevel]
	inc a
	ld [wFadeLevel], a
	jr Func_30_57d4
Func_30_5809:
	call Func_00_07a7
	call Func_00_0786
	call Func_00_04c4
	call Func_00_0e24
	ret
Func_30_5816:
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
	call Func_00_1002
	ld hl, $9c00
	ld bc, $0400
	call Func_00_1002
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

Data_30_5868:
	db $29, $29

Data_30_586a:
	db $29, $29

Data_30_586c:
	db $29, $29, $29, $29, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a
	db $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2b, $2b, $2b, $2b, $2b, $2b

SECTION "analyzed_0c1889", ROMX[$5889], BANK[$30]

Data_30_5889:
	db $29

SECTION "analyzed_0c188a", ROMX[$588a], BANK[$30]

Data_30_588a:
	db $29, $29, $29, $04, $7a, $7d, $7a

Data_30_5891:
	db $8e, $7a, $9b, $7a

Data_30_5895:
	db $a4, $7a, $b5, $7a, $c2, $7a, $cb, $7a, $30, $74, $49, $74, $7a, $74, $ab, $74
	db $4c, $75, $95, $75, $b6, $75, $d7, $75, $f8, $75, $19, $76, $3a, $76, $ab, $76
	db $1c, $77, $8d, $77, $fe, $77, $6f, $78, $e0, $78, $51, $79, $c2, $79, $40, $70
	db $c1, $70, $26, $71, $8f, $71, $ec, $71, $45, $72

Data_30_58cf:
	db $16, $72

Data_30_58d1:
	db $ac, $73, $42, $75, $d8, $76

Func_30_58d7:
	push af
	ld hl, $5868
	rst AddAToHL
	ld a, [hl]
	ld [wDrawBank], a
	pop af
	ld hl, $588d
	add a, a
	rst AddAToHL
	rst DerefHL
	ld b, d
	ld c, e
	call DrawMetasprite
	ret
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
Func_30_590c:
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
	call Func_30_58d7
	ret

Data_30_5934:
	db $68, $01, $20, $02, $20, $03, $28, $04, $20, $04, $18, $04, $18, $05, $18, $06
	db $68, $04, $60, $04, $58, $04, $50, $04, $48, $04, $40, $04, $38, $04, $30, $04

Func_30_5954:
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
	call Func_30_5f78
	jr Func_30_599d
Func_30_598d:
	cp $e6
	jr nz, Func_30_5998
	ld a, $09
	ld [wScreenTimer], a
	jr Func_30_599d
Func_30_5998:
	jr c, Func_30_599d
	call Func_30_5fa2
Func_30_599d:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_59bc
	ld d, $00
	ld e, $00
	ld a, $00
	call Func_30_58d7
	ld hl, $d0f7
	ld b, $01
	call Func_30_590c
	ld hl, $d0f8
	ld b, $04
	call Func_30_590c
Func_30_59bc:
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	ret
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
	call Func_00_36a3
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
	call Func_30_5f78
	jr Func_30_5a20
Func_30_5a10:
	cp $e6
	jr nz, Func_30_5a1b
	ld a, $09
	ld [wScreenTimer], a
	jr Func_30_5a20
Func_30_5a1b:
	jr c, Func_30_5a20
	call Func_30_5fa2
Func_30_5a20:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5a3f
	ld hl, $d0f7
	ld b, $01
	call Func_30_590c
	ld d, $00
	ld e, $00
	ld a, $07
	call Func_30_58d7
	ld hl, $d0f8
	ld b, $04
	call Func_30_590c
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
	call Func_30_58d7
Func_30_5a57:
	ret
	ld a, [wScreenPhase]
	cp $00
	jr nz, Func_30_5a8a
	xor a
	ldh [rVBK], a
	ld a, $2a
	ld hl, $4600
	ld de, $8000
	ld bc, $0e00
	call Func_00_36a3
	ld a, $00
	ld b, $02
	ld c, $2a
	ld hl, $5400
	call Func_00_09d5
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
	call Func_30_5f78
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
	call Func_30_5fa2
Func_30_5afa:
	call Func_30_5a47
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	ret
	ld a, [wScreenPhase]
	cp $00
	jr nz, Func_30_5b32
	xor a
	ldh [rVBK], a
	ld a, $2a
	ld hl, $5410
	ld de, $8000
	ld bc, $0800
	call Func_00_36a3
	ld a, $00
	ld b, $02
	ld c, $2a
	ld hl, $5c10
	call Func_00_09d5
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
	call Func_30_5f78
	jr Func_30_5b41
Func_30_5b41:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5b50
	ld d, $00
	ld e, $00
	ld a, $0c
	call Func_30_58d7
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
	call Func_30_5fa2
Func_30_5ba9:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5bc2
	ld d, $00
	ld e, $00
	ld a, $0c
	call Func_30_58d7
	ld d, $00
	ld e, $00
	ld a, [wScreenAnim]
	call Func_30_58d7
Func_30_5bc2:
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	ret
	ld a, [wScreenPhase]
	cp $00
	jr nz, Func_30_5c14
	xor a
	ldh [rVBK], a
	ld a, $2a
	ld hl, $5c20
	ld de, $8000
	ld bc, $1000
	call Func_00_36a3
	ld a, $01
	ldh [rVBK], a
	ld a, $2a
	ld hl, $6c20
	ld de, $8000
	ld bc, $0800
	call Func_00_36a3
	ld a, $00
	ld b, $02
	ld c, $2a
	ld hl, $7420
	call Func_00_09d5
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
	call Func_30_5f78
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
	call Func_30_58d7
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
	call Func_30_5fa2
Func_30_5ca9:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5cb9
	ld d, $00
	ld e, $00
	ld a, [wScreenAnim]
	call Func_30_58d7
Func_30_5cb9:
	ld a, [wScreenAnim2]
	inc a
	ld [wScreenAnim2], a
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	ret
	ld a, [wScreenPhase]
	cp $00
	jr nz, Func_30_5cf1
	xor a
	ldh [rVBK], a
	ld a, $2b
	ld hl, $4000
	ld de, $8000
	ld bc, $0800
	call Func_00_36a3
	ld a, $00
	ld b, $02
	ld c, $2b
	ld hl, $4800
	call Func_00_09d5
	ld a, $09
	ld [wScreenTimer], a
Func_30_5cf1:
	cp $0a
	jr nc, Func_30_5cf7
	jr Func_30_5cfe
Func_30_5cf7:
	cp $14
	jr nc, Func_30_5cfe
	call Func_30_5f78
Func_30_5cfe:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5d0d
	ld d, $00
	ld e, $00
	ld a, $1b
	call Func_30_58d7
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

Data_30_5d23:
	db $c9

SECTION "analyzed_0c1d24", ROMX[$5d24], BANK[$30]

Func_30_5d24:
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
	call Func_30_5fa2
Func_30_5d47:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5d56
	ld d, $00
	ld e, $00
	ld a, $1b
	call Func_30_58d7
Func_30_5d56:
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	ret
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
	call Func_00_36a3
	ld a, $00
	ld b, $06
	ld c, $2b
	ld hl, $6010
	call Func_00_09d5
	ld a, $09
	ld [wScreenTimer], a
	xor a
	ld [wScreenFrame], a
Func_30_5d9b:
	cp $3c
	jr c, Func_30_5db8
	cp $46
	jr nc, Func_30_5da8
	call Func_30_5f78
	jr Func_30_5db8
Func_30_5da8:
	cp $aa
	jr nz, Func_30_5db3
	ld a, $09
	ld [wScreenTimer], a
	jr Func_30_5db8
Func_30_5db3:
	jr c, Func_30_5db8
	call Func_30_5fa2
Func_30_5db8:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5dc7
	ld d, $00
	ld e, $00
	ld a, $1c
	call Func_30_58d7
Func_30_5dc7:
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	ret
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
	call Func_30_5f78
	jr Func_30_5e0c
Func_30_5dfc:
	cp $50
	jr nz, Func_30_5e07
	ld a, $09
	ld [wScreenTimer], a
	jr Func_30_5e0c
Func_30_5e07:
	jr c, Func_30_5e0c
	call Func_30_5fa2
Func_30_5e0c:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5e1b
	ld d, $00
	ld e, $00
	ld a, $1d
	call Func_30_58d7
Func_30_5e1b:
	jr Func_30_5e4c
Func_30_5e1d:
	jr nz, Func_30_5e24
	ld a, $09
	ld [wScreenTimer], a
Func_30_5e24:
	cp $64
	jr nc, Func_30_5e2d
	call Func_30_5f78
	jr Func_30_5e3d
Func_30_5e2d:
	cp $aa
	jr nz, Func_30_5e38
	ld a, $09
	ld [wScreenTimer], a
	jr Func_30_5e3d
Func_30_5e38:
	jr c, Func_30_5e3d
	call Func_30_5fa2
Func_30_5e3d:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5e4c
	ld d, $00
	ld e, $00
	ld a, $1e
	call Func_30_58d7
Func_30_5e4c:
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	ret
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
	call Func_30_5f78
	jr Func_30_5e91
Func_30_5e81:
	cp $50
	jr nz, Func_30_5e8c
	ld a, $09
	ld [wScreenTimer], a
	jr Func_30_5e91
Func_30_5e8c:
	jr c, Func_30_5e91
	call Func_30_5fa2
Func_30_5e91:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5ea0
	ld d, $00
	ld e, $00
	ld a, $1f
	call Func_30_58d7
Func_30_5ea0:
	jr Func_30_5ed1
Func_30_5ea2:
	jr nz, Func_30_5ea9
	ld a, $09
	ld [wScreenTimer], a
Func_30_5ea9:
	cp $64
	jr nc, Func_30_5eb2
	call Func_30_5f78
	jr Func_30_5ec2
Func_30_5eb2:
	cp $aa
	jr nz, Func_30_5ebd
	ld a, $09
	ld [wScreenTimer], a
	jr Func_30_5ec2
Func_30_5ebd:
	jr c, Func_30_5ec2
	call Func_30_5fa2
Func_30_5ec2:
	ld a, [wScreenFrame]
	and a
	jr z, Func_30_5ed1
	ld d, $00
	ld e, $00
	ld a, $20
	call Func_30_58d7
Func_30_5ed1:
	ld a, [wScreenPhase]
	inc a
	ld [wScreenPhase], a
	ret
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
	call Func_00_36a3
	ld a, $01
	ldh [rVBK], a
	ld a, $2b
	ld hl, $6840
	ld de, $9000
	ld bc, $0800
	call Func_00_36a3
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
	call Func_30_5f4b
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
Func_30_5f4b:
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
	call Func_00_10dc
	call Func_30_5f6e
	ret
Func_30_5f6e:
	ld a, [$cf3f]
	cpl
	and $01
	ld [$cf3f], a
	ret
Func_30_5f78:
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
Func_30_5fa2:
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

Data_30_5fcb:
	db $a2, $72, $d0, $75, $ff, $ff, $56, $76, $ec, $72, $dc, $76, $36, $73, $62, $77
	db $80, $73, $e8, $77, $ca, $73, $6e, $78, $ff, $ff, $f4, $78, $14, $74, $7a, $79
	db $5e, $74, $00, $7a, $a8, $74, $86, $7a, $f2, $74, $0c, $7b, $ff, $ff, $92, $7b
	db $3c, $75, $18, $7c, $ff, $ff, $9e, $7c, $86, $75, $24, $7d

Func_30_6007:
	ld a, [wScreenInput]
	add a, a
	add a, a
	ld hl, $5fcb
	rst AddAToHL
	push hl
	rst DerefHL
	ld a, h
	cp $ff
	jr nz, Func_30_6022
	ld hl, $9c20
	ld bc, $0040
	call Func_00_1002
	jr Func_30_602a
Func_30_6022:
	ld de, $9c22
	ld b, $2b
	call Func_00_10dc
Func_30_602a:
	pop hl
	ld a, $02
	rst AddAToHL
	rst DerefHL
	ld de, $9c83
	ld b, $2b
	call Func_00_10dc
	ret
