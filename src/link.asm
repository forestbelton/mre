; ROM bank $31 -- Game Link cable exchange protocol (LinkExchange*). Carved out of analyzed.asm; section
; names and placement are unchanged (byte-exact). 1 sections.

INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "sound_ids.inc"

SECTION "analyzed_0c4000", ROMX[$4000], BANK[$31]

Func_31_4000:
	nop
	and b
	ld c, a
	and d
	sbc a, [hl]
	and h

Func_31_4006:
	xor a
	ldh [rIF], a
	ldh a, [rIE]
	or $08
	ldh [rIE], a
	ret
Func_31_4010:
	xor a
	ldh [rIF], a
	ldh a, [rIE]
	and $f7
	ldh [rIE], a
	ldh a, [rSC]
	res 7, a
	res 0, a
	ldh [rSC], a
	ret
Func_31_4022:
	ld hl, $c297
	ld a, $7e
	ld [hl+], a
	ld a, $3e
	ld [hl], a
	ret

Func_31_402c:
	ld hl, $c297
	ld a, $a3
	ld [hl+], a
	ld a, $3e
	ld [hl], a
	ret
Func_31_4036:
	ld hl, $c297
	ld a, $b8
	ld [hl+], a
	ld a, $3e
	ld [hl], a
	ret

LinkExchangeConnect:
	call Func_31_4022
	call Func_31_4006
	xor a
	ld [$d5c3], a
Func_31_404a:
	call ReadJoypad
	ld a, $f0
	ldh [rSB], a
	xor a
	ld [wSerialRecv], a
	ld a, $80
	ldh [rSC], a
	ldh a, [hJoyPressed]
	bit 1, a
	jr nz, Func_31_4094
	ld a, [$d5c3]
	cp $04
	jr c, Func_31_4069
	call Func_31_4289
Func_31_4069:
	call WaitForNextFrame
	ld a, [wSerialRecv]
	cp $f1
	jp z, Func_31_40a1
	cp $f0
	jp z, Func_31_40c4
	ld a, [$d5c3]
	inc a
	and a
	jr z, Func_31_4085
	ld [$d5c3], a
	jr Func_31_404a
Func_31_4085:
	ld a, [wSerialRecv]
	cp $00
	jr nz, Func_31_4090

Data_31_408c:
	db $3e, $01, $18, $0a

Func_31_4090:
	ld a, $02
	jr Func_31_409a

Func_31_4094:
	ld a, $03
	jr Func_31_409a
Func_31_4098:
	ld a, $00

Func_31_409a:
	ld [$d5c2], a
	call Func_31_4010
	ret

Func_31_40a1:
	ld hl, $c297
	ld a, $a3
	ld [hl+], a
	ld a, $3e
	ld [hl], a
	ld a, $f2
	ldh [rSB], a
	xor a
	ld [wSerialRecv], a
	ld a, $80
	ldh [rSC], a
	call Func_31_43db
	ld a, [wSerialRecv]
	cp $f3
	jp z, Func_31_4098
	jp LinkExchangeConnect
Func_31_40c4:
	ld hl, $c297
	ld a, $a3
	ld [hl+], a
	ld a, $3e
	ld [hl], a
	call Func_00_3e74
	ld a, $f3
	ldh [rSB], a
	ld a, $81
	ldh [rSC], a
	call WaitForNextFrame
	ld a, [wSerialRecv]
	cp $f2
	jp z, Func_31_4098
	jp LinkExchangeConnect
Func_31_40e6:
	call Func_31_402c
	call Func_31_4006
	xor a
	ld [$d5c3], a
Func_31_40f0:
	call ReadJoypad
	ld a, $f2
	ldh [rSB], a
	xor a
	ld [wSerialRecv], a
	ld a, $80
	ldh [rSC], a
	ldh a, [hJoyPressed]
	bit 1, a
	jr nz, Func_31_4137
	ld a, [$d5c3]
	cp $04
	jr c, Func_31_410f
	call Func_31_4292
Func_31_410f:
	call WaitForNextFrame
	ld a, [wSerialRecv]
	cp $f3
	jp z, Func_31_4144
	cp $f2
	jp z, Func_31_4167
	ld a, [$d5c3]
	inc a
	ld [$d5c3], a
	jr Func_31_40f0
	ld a, [wSerialRecv]
	cp $00
	jr nz, Func_31_4133
	ld a, $01
	jr Func_31_413d
Func_31_4133:
	ld a, $02
	jr Func_31_413d
Func_31_4137:
	ld a, $03
	jr Func_31_413d
	ld a, $00
Func_31_413d:
	ld [$d5c2], a
	call Func_31_4010
	ret
Func_31_4144:
	ld hl, $c297
	ld a, $7e
	ld [hl+], a
	ld a, $3e
	ld [hl], a
	ld a, $f0
	ldh [rSB], a
	xor a
	ld [wSerialRecv], a
	ld a, $80
	ldh [rSC], a
	call Func_31_43db
	ld a, [wSerialRecv]
	cp $f1
	jp z, Func_31_41bb
	jp Func_31_40e6
Func_31_4167:
	ld hl, $c297
	ld a, $7e
	ld [hl+], a
	ld a, $3e
	ld [hl], a
	call Func_00_3e74
	ld a, $f1
	ldh [rSB], a
	ld a, $81
	ldh [rSC], a
	call WaitForNextFrame
	ld a, [wSerialRecv]
	cp $f0
	jp z, Func_31_4189
	jp Func_31_40e6
Func_31_4189:
	call Func_00_3e74
	ld hl, $c297
	ld a, $e3
	ld [hl+], a
	ld a, $3e
	ld [hl], a
	ld a, [$d5f9]
	ldh [rSB], a
	call Func_31_4434
	call Func_00_3e74
	ld a, [wSerialRecv]
	ld [$d5c5], a
	ld a, [$d5fa]
	ldh [rSB], a
	call Func_31_4434
	call Func_00_3e74
	ld a, [wSerialRecv]
	ld [$d5c6], a
	call Func_31_4010
	ret
Func_31_41bb:
	ld hl, $c297
	ld a, $cd
	ld [hl+], a
	ld a, $3e
	ld [hl], a
	ld a, [$d5f9]
	ldh [rSB], a
	call Func_31_4423
	ld a, [wSerialRecv]
	ld [$d5c5], a
	ld a, [$d5fa]
	ldh [rSB], a
	call Func_31_4423
	ld a, [wSerialRecv]
	ld [$d5c6], a
	call Func_31_4010
	ret
Func_31_41e4:
	call Func_31_4036
	call Func_31_4006
	xor a
	ld [$d5c3], a
Func_31_41ee:
	call ReadJoypad
	ld a, $f4
	ldh [rSB], a
	xor a
	ld [wSerialRecv], a
	ld a, $80
	ldh [rSC], a
	ldh a, [hJoyPressed]
	bit 1, a
	jr nz, Func_31_4237
	ld a, [$d5c3]
	cp $04
	jr c, Func_31_420d
	call Func_31_429b
Func_31_420d:
	push bc
	call WaitForNextFrame
	pop bc
	ld a, [wSerialRecv]
	cp $f5
	jp z, Func_31_4244
	cp $f4
	jp z, Func_31_4267
	ld a, [$d5c3]
	inc a
	ld [$d5c3], a
	jr Func_31_41ee
	ld a, [wSerialRecv]
	cp $00
	jr nz, Func_31_4233
	ld a, $01
	jr Func_31_423d
Func_31_4233:
	ld a, $02
	jr Func_31_423d
Func_31_4237:
	ld a, $03
	jr Func_31_423d
	ld a, $00
Func_31_423d:
	ld [$d5c2], a
	call Func_31_4010
	ret
Func_31_4244:
	ld hl, $c297
	ld a, $7e
	ld [hl+], a
	ld a, $3e
	ld [hl], a
	ld a, $f0
	ldh [rSB], a
	xor a
	ld [wSerialRecv], a
	ld a, $80
	ldh [rSC], a
	call Func_31_43db
	ld a, [wSerialRecv]
	cp $f1
	jp z, Func_31_434a
	jp LinkExchangeConnect
Func_31_4267:
	ld hl, $c297
	ld a, $7e
	ld [hl+], a
	ld a, $3e
	ld [hl], a
	call Func_00_3e74
	ld a, $f1
	ldh [rSB], a
	ld a, $81
	ldh [rSC], a
	call WaitForNextFrame
	ld a, [wSerialRecv]
	cp $f0
	jp z, Func_31_42a4
	jp LinkExchangeConnect

Func_31_4289:
	ld a, $f1
	ldh [rSB], a
	ld a, $81
	ldh [rSC], a
	ret

Func_31_4292:
	ld a, $f3
	ldh [rSB], a
	ld a, $81
	ldh [rSC], a
	ret
Func_31_429b:
	ld a, $f5
	ldh [rSB], a
	ld a, $81
	ldh [rSC], a
	ret
Func_31_42a4:
	call Func_00_3e74
	call Func_00_3e74
	call Func_00_3e74
	ld hl, $c297
	ld a, $e3
	ld [hl+], a
	ld a, $3e
	ld [hl], a
	ld bc, $0255
	ld bc, $0258
	ld de, $d112
	ld hl, $d36a
	dec de
Func_31_42c3:
	push bc
	push de
	push hl
	call ReadJoypad
	pop hl
	pop de
	pop bc
	ldh a, [hJoyPressed]
	bit 1, a
	jr nz, Func_31_4341
	call Func_31_443c
	dec bc
	ld a, b
	or c
	jr nz, Func_31_42c3
	ld hl, $d363
	ld a, [hl+]
	ld b, a
	ld a, [hl]
	cpl
	cp b
	jr z, Func_31_42e9
	call Func_31_44b0
	jr Func_31_42f8
Func_31_42e9:
	call Func_31_44b0
	and a
	jr nz, Func_31_42f8
	ld a, $f8
	ldh [rSB], a
	ld [$d10d], a
	jr Func_31_42ff
Func_31_42f8:
	ld a, $f9
	ldh [rSB], a
	ld [$d10d], a
Func_31_42ff:
	call Func_31_4434
	ld a, [wSerialRecv]
	ld b, a
	ld a, [$d10d]
	cp $f8
	jr nz, Func_31_433e
	xor b
	and a
	jr nz, Func_31_433e
	ld a, [$d112]
	cp $0a
	jr nz, Func_31_431f
	ld a, [$d362]
	cp $0b
	jr z, Func_31_4325
Func_31_431f:
	ld a, $fb
	ldh [rSB], a
	jr Func_31_4329
Func_31_4325:
	ld a, $fa
	ldh [rSB], a
Func_31_4329:
	call Func_00_3e74
	call Func_31_4434
	ld a, [wSerialRecv]
	cp $fa
	jr nz, Func_31_433e
	xor a
	ld [$d5c2], a
	call Func_31_4010
	ret
Func_31_433e:
	jp Func_31_41e4
Func_31_4341:
	ld a, $03
	ld [$d5c2], a
	call Func_31_4010
	ret
Func_31_434a:
	ld hl, $c297
	ld a, $cd
	ld [hl+], a
	ld a, $3e
	ld [hl], a
	ld bc, $0255
	ld bc, $0258
	ld de, $d112
	ld hl, $d36a
	dec de
Func_31_4360:
	call Func_31_4427
	ld a, [$d109]
	and a
	jr nz, Func_31_43d2
	dec bc
	ld a, b
	or c
	jr nz, Func_31_4360
	ld hl, $d363
	ld a, [hl+]
	ld b, a
	ld a, [hl]
	cpl
	cp b
	jr z, Func_31_437d
	call Func_31_44b0
	jr Func_31_438c
Func_31_437d:
	call Func_31_44b0
	and a
	jr nz, Func_31_438c
	ld a, $f8
	ldh [rSB], a
	ld [$d10d], a
	jr Func_31_4393
Func_31_438c:
	ld a, $f9
	ldh [rSB], a
	ld [$d10d], a
Func_31_4393:
	call Func_31_4423
	ld a, [wSerialRecv]
	ld b, a
	ld a, [$d10d]
	cp $f8
	jr nz, Func_31_43cf
	xor b
	and a
	jr nz, Func_31_43cf
	ld a, [$d112]
	cp $0a
	jr nz, Func_31_43b3
	ld a, [$d362]
	cp $0b
	jr z, Func_31_43b9
Func_31_43b3:
	ld a, $fb
	ldh [rSB], a
	jr Func_31_43bd
Func_31_43b9:
	ld a, $fa
	ldh [rSB], a
Func_31_43bd:
	call Func_31_4423
	ld a, [wSerialRecv]
	cp $fa
	jr nz, Func_31_43cf
	xor a
	ld [$d5c2], a
	call Func_31_4010
	ret
Func_31_43cf:
	jp Func_31_41e4
Func_31_43d2:
	ld a, $03
	ld [$d5c2], a
	call Func_31_4010
	ret
Func_31_43db:
	xor a
	ld [$d109], a
	ld [wSerialRecvFlag], a
	ld a, $80
	ldh [rSC], a
Func_31_43e6:
	push bc
	push de
	push hl
	call ReadJoypad
	pop hl
	pop de
	pop bc
	ldh a, [hJoyPressed]
	bit 1, a
	jr nz, Func_31_43fc
	ld a, [wSerialRecvFlag]
	and a
	jr z, Func_31_43e6
	ret
Func_31_43fc:
	ld a, $aa
	ld [$d109], a
	ld a, [wSerialRecvFlag]
	and a
	ret
	xor a
	ld [wSerialRecvFlag], a
	ld a, $80
	ldh [rSC], a
	ld b, $00
	ld c, $00
Func_31_4412:
	ld a, c
	add a, $01
	ld c, a
	ld a, b
	adc a, $00
	ld b, a
	and c
	ret z
	ld a, [wSerialRecvFlag]
	and a
	jr z, Func_31_4412
	ret
Func_31_4423:
	call Func_31_43db
	ret
Func_31_4427:
	ld a, [hl+]
	ld [wSerialSend], a
	call Func_31_4423
	ld a, [wSerialRecv]
	ld [de], a
	inc de
	ret
Func_31_4434:
	ld a, $81
	ldh [rSC], a
	call Func_00_3e74
	ret
Func_31_443c:
	ld a, [hl+]
	ld [wSerialSend], a
	call Func_31_4434
	ld a, [wSerialRecv]
	ld [de], a
	inc de
	ret
Func_31_4449:
	ld a, $0a
	ld [Data_00_1fff], a
	ld a, [$d5f9]
	res 2, a
	add a, a
	ld hl, $4000
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld d, h
	ld e, l
	ld bc, $024f
	ld hl, $d36b
	call CopyDEtoHLLong
	xor a
	ld [Data_00_1fff], a
	call Func_31_4496
	ret
Func_31_446e:
	ld hl, $d113
	ld bc, $024e
	call Func_00_12e1
	ret nz
	ld a, $0a
	ld [Data_00_1fff], a
	ld a, [$d5fa]
	add a, a
	ld hl, $4000
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, $024f
	ld de, $d113
	call CopyDEtoHLLong
	xor a
	ld [Data_00_1fff], a
	ret
Func_31_4496:
	ld a, $0a
	ld [$d36a], a
	ld a, $0b
	ld [$d5ba], a
	ld bc, $024f
	ld hl, $d36a
	ld bc, $0251
	call Func_31_44bd
	ld [hl+], a
	cpl
	ld [hl], a
	ret
Func_31_44b0:
	ld hl, $d112
	ld bc, $0251
	call Func_31_44bd
	ld b, a
	ld a, [hl]
	xor b
	ret
Func_31_44bd:
	ld d, $00
Func_31_44bf:
	ld a, [hl+]
	add a, d
	ld d, a
	dec bc
	ld a, b
	or c
	jr nz, Func_31_44bf
	ld a, d
	ret
LinkExchangeTransfer:
	call Func_31_40e6
	ld a, [$d5c2]
	cp $03
	ret z
	ld a, [$d5f9]
	bit 2, a
	jr z, Func_31_44e1
	ld a, [$d5fa]
	bit 2, a
	jr z, Func_31_44e1
	ret
Func_31_44e1:
	ld a, [$d5f9]
	bit 2, a
	jr z, Func_31_44f0
	ld a, [$d5c5]
	bit 2, a
	jr z, Func_31_44f0
	ret
Func_31_44f0:
	call Func_31_47aa
	ld a, [$d5f9]
	bit 2, a
	jr nz, Func_31_44fd
	call Func_31_452e
Func_31_44fd:
	call Func_31_4449
	call Func_31_41e4
	ld a, [$d5c2]
	cp $03
	jr z, Func_31_452a
	ld a, [$d5c5]
	bit 2, a
	jr nz, Func_31_4526
	ld a, [$d5fa]
	bit 2, a
	jr nz, Func_31_4526
	call Func_31_446e
	FAR_CALL $12, LoadFloorEditsFromSram
	call Func_31_456f
Func_31_4526:
	xor a
	ld [$d5c2], a
Func_31_452a:
	call HideAllSprites
	ret
Func_31_452e:
	xor a
	ld [$d5c7], a
	ld [$d5f8], a
	ld [$d5f7], a
	ld a, $a0
	ld [$d5f5], a
	ld a, $28
	ld [$d5f6], a
Func_31_4542:
	call Func_31_4644
	call Func_31_4697
	FAR_CALL $34, Func_34_4034
	call Func_31_462b
	call HideUnusedOamSprites
	ld b, $00
	FAR_CALL $34, Data_34_4000
	call WaitForNextFrame
	ld a, [$d5c7]
	inc a
	ld [$d5c7], a
	cp $64
	jr nz, Func_31_4542
	ret
Func_31_456f:
	xor a
	ld [$d5c7], a
	ld [$d5f8], a
	ld [$d5f7], a
	ld a, $f0
	ld [$d5f6], a
Func_31_457e:
	call Func_31_46e0
	call HideUnusedOamSprites
	ld b, $01
	FAR_CALL $34, Data_34_4000
	call WaitForNextFrame
	ld a, [$d5c7]
	inc a
	ld [$d5c7], a
	cp $ff
	jr nz, Func_31_457e
	ret
	ld c, $03
	ld b, $10
	ld hl, $d5eb
Func_31_45a4:
	ld a, [hl+]
	ld d, a
	ld a, [hl-]
	ld e, a
	ld a, d
	ld [hl+], a
	ld a, e
	ld [hl+], a
	push bc
	push hl
	ld a, $34
	ld [wDrawBank], a
	ld hl, $7914
	ld c, d
	call DrawMetasprite
	pop hl
	pop bc
	ld a, b
	add a, $0c
	ld b, a
	dec c
	ld a, c
	and a
	jr nz, Func_31_45a4
	ret
	ld a, [$d5c7]
	cp $2c
	ret c
	ld c, $08
Func_31_45ce:
	ld hl, $d5c9
	ld a, c
	dec a
	sla a
	sla a
	rst AddAToHL
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [hl+]
	add a, e
	ld e, a
	ld a, [hl]
	sub $01
	ld [hl], a
	ld b, a
	ld a, d
	sub b
	ld d, a
	ld a, d
	srl a
	ld b, a
	ld a, $50
	sub b
	cp $70
	jr c, Func_31_45fe
	ld a, [hl]
	ld b, a
	xor a
	sub b
	ld a, b
	srl a
	srl a
	srl a
	ld [hl], a
Func_31_45fe:
	ld hl, $d5c9
	ld a, c
	dec a
	sla a
	sla a
	rst AddAToHL
	ld a, e
	ld [hl+], a
	ld a, d
	ld [hl], a
	push bc
	ld a, d
	add a, $50
	ld b, a
	ld a, e
	sra a
	ld c, a
	add a, $68
	sub c
	ld c, a
	ld a, $34
	ld [wDrawBank], a
	ld hl, $7973
	call DrawMetasprite
	pop bc
	dec c
	ld a, c
	and a
	jr nz, Func_31_45ce
	ret
Func_31_462b:
	ld a, [$d5c7]
	cp $2c
	ret c
	cp $40
	ret nc
	ld a, $34
	ld [wDrawBank], a
	ld hl, $7921
	ld b, $28
	ld c, $60
	call DrawMetasprite
	ret
Func_31_4644:
	ld a, [$d5c7]
	ld c, a
	cp $2c
	ret c
	cp $3b
	ret nc
	ld a, [$d5e9]
	dec a
	ld [$d5e9], a
	ld b, a
	ld a, [$d5ea]
	add a, b
	ld [$d5ea], a
	bit 0, c
	ret z
	ld a, $34
	ld [wDrawBank], a
	ld hl, $7985
	ld a, [$d5ea]
	swap a
	and $0f
	ld c, a
	ld a, $38
	sub c
	ld b, a
	ld a, $60
	sub c
	ld c, a
	call DrawMetasprite
	ld a, $34
	ld [wDrawBank], a
	ld hl, $7985
	ld a, [$d5ea]
	swap a
	and $0f
	ld c, a
	ld a, $38
	sub c
	ld b, a
	ld a, $80
	add a, c
	ld c, a
	call DrawMetasprite
	ret
Func_31_4697:
	ld a, [$d5c7]
	cp $20
	jr nz, Func_31_46a5
	push af
	ld a, SOUND_SFX_22
	call PlaySound
	pop af
Func_31_46a5:
	ld a, [$d5c7]
	cp $2c
	ret c
	ld a, [$d5f6]
	cp $f0
	jr nc, Func_31_46b5
	cp $b0
	ret nc
Func_31_46b5:
	ld b, a
	ld c, $68
	ld a, $34
	ld [wDrawBank], a
	ld a, [$d5c7]
	bit 2, a
	jr nz, Func_31_46c9
	ld hl, $7952
	jr Func_31_46d4
Func_31_46c9:
	ld hl, $7973
	ld a, b
	add a, $08
	ld b, a
	ld a, c
	add a, $08
	ld c, a
Func_31_46d4:
	call DrawMetasprite
	ld a, [$d5f6]
	sub $04
	ld [$d5f6], a
	ret
Func_31_46e0:
	ld a, [$d5c7]
	cp $7c
	jr nz, Func_31_46ee
	push af
	ld a, SOUND_SFX_26
	call PlaySound
	pop af
Func_31_46ee:
	ld a, [$d5c7]
	cp $28
	jr c, Func_31_46fe
	cp $6e
	jr c, Func_31_4718
	cp $86
	jr c, Func_31_4749
	ret
Func_31_46fe:
	ld b, $08
	ld a, [$d5c7]
	add a, b
	ld b, a
	ld a, [$d5f5]
	sub $04
	sub $02
	ld [$d5f5], a
	ld c, a
	ld a, $01
	ld [$d5f6], a
	jp Func_31_4782
Func_31_4718:
	ld a, [$d5c7]
	cp $44
	jr c, Func_31_4725
	ld a, $f0
	ld [$d5f6], a
	ret
Func_31_4725:
	ld a, [$d5f5]
	add a, $04
	add a, $04
	ld [$d5f5], a
	ld c, a
	ld a, [$d5c7]
	ld b, $28
	sub b
	srl a
	srl a
	ld b, a
	ld a, [$d5f6]
	add a, b
	ld [$d5f6], a
	ld b, a
	ld a, $80
	sub b
	ld b, a
	jr Func_31_4762
Func_31_4749:
	ld a, [$d5f6]
	cp $40
	jr c, Func_31_4755
	cp $a0
	jr nc, Func_31_4755
	ret
Func_31_4755:
	ld a, [$d5f6]
	add a, $04
	add a, $02
	ld [$d5f6], a
	ld b, a
	ld c, $68
Func_31_4762:
	ld a, $34
	ld [wDrawBank], a
	ld a, [$d5c7]
	bit 2, a
	jr nz, Func_31_4773
	ld hl, $7952
	jr Func_31_477e
Func_31_4773:
	ld hl, $7973
	ld a, b
	add a, $08
	ld b, a
	ld a, c
	add a, $08
	ld c, a
Func_31_477e:
	call DrawMetasprite
	ret
Func_31_4782:
	ld a, $34
	ld [wDrawBank], a
	ld a, [$d5c7]
	bit 2, a
	jr nz, Func_31_479b
	ld hl, $797c
	ld a, b
	add a, $08
	ld b, a
	ld a, c
	add a, $08
	ld c, a
	jr Func_31_47a6
Func_31_479b:
	ld hl, $7973
	ld a, b
	add a, $08
	ld b, a
	ld a, c
	add a, $08
	ld c, a
Func_31_47a6:
	call DrawMetasprite
	ret
Func_31_47aa:
	ldh a, [rLCDC]
	res 7, a
	res 5, a
	ldh [rLCDC], a
	FAR_CALL $34, Func_34_406a
	ld c, $03
	ld hl, $d5eb
Func_31_47bf:
	call Func_00_03c4
	ld [hl+], a
	ld [hl+], a
	dec c
	ld a, c
	and a
	jr nz, Func_31_47bf
	ld c, $08
	ld hl, $d5c9
Func_31_47ce:
	call Func_00_03c4
	and $1f
	sub $0f
	ld [hl+], a
	ld b, a
	xor a
	ld [hl+], a
	ld a, b
	ld [hl+], a
	call Func_00_03c4
	and $03
	add a, $04
	ld [hl+], a
	dec c
	ld a, c
	and a
	jr nz, Func_31_47ce
	xor a
	ld [$d5f8], a
	ld [$d5f7], a
	ld [$d5ea], a
	ld a, $0f
	ld [$d5e9], a
	ldh a, [rLCDC]
	set 7, a
	ldh [rLCDC], a
	ret

SECTION "analyzed_0d0000", ROMX[$4000], BANK[$34]

Data_34_4000:
	db $78, $a7, $20, $05, $21, $df, $79, $18, $03, $21, $00, $7a, $fa, $f8, $d5, $fe
	db $ff, $c8, $a7, $20, $1a, $fa, $f7, $d5, $cb, $27, $cb, $27, $c7, $2a, $ea, $f8
	db $d5, $fe, $ff, $c8, $df, $11, $c9, $98, $cd, $4e, $0b, $21, $f7, $d5, $34, $21
	db $f8, $d5, $35, $c9
Func_34_4034:
	db $fa, $c7, $d5, $fe, $20, $20, $07, $f5, $3e, $22, $cd, $85, $0a, $f1, $fa, $c7
	db $d5, $fe, $20, $d0, $fa, $c8, $d5, $3c, $fe, $0c, $38, $01, $af, $ea, $c8, $d5
	db $cb, $3f, $cb, $3f, $21, $d9, $79, $c7, $df, $3e, $34, $ea, $00, $c1, $06, $7e
	db $0e, $60, $cd, $09, $0c, $c9
Func_34_406a:
	db $cd, $d7, $0b, $af, $e0, $4f, $21, $a8, $40, $11, $00, $80, $01, $00, $18, $cd
	db $94, $03, $3e, $01, $e0, $4f, $21, $a8, $58, $11, $00, $80, $01, $00, $18, $cd
	db $94, $03, $af, $06, $08, $21, $a8, $70, $cd, $f2, $04, $af, $06, $08, $21, $e8
	db $70, $cd, $47, $05, $21, $28, $71, $11, $00, $98, $cd, $4e, $0b, $c9, $00, $00
	db $00, $00, $00, $00, $00, $00, $01, $01, $00, $00, $00, $00, $00, $00, $80, $80
	db $c0, $c0, $70, $70, $38, $38, $3e, $3e, $17, $1f, $09, $0f, $0c, $0f, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $c0, $c0, $60, $60, $70, $70
	db $38, $38, $3c, $3c, $16, $1e, $1b, $1f, $09, $0f, $cd, $cf, $f4, $f7, $02, $02
	db $02, $02, $02, $02, $07, $07, $07, $07, $07, $07, $0d, $0f, $0d, $0f, $0d, $0f
	db $09, $0f, $19, $1f, $19, $1f, $12, $1d, $32, $3d, $b6, $b9, $f6, $f9, $04, $04
	db $04, $04, $04, $04, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $18, $18, $98, $98
	db $98, $98, $98, $98, $a9, $b9, $ab, $bb, $af, $bf, $ce, $ff, $cc, $ff, $00, $00
	db $00, $00, $01, $01, $03, $03, $07, $07, $0f, $0f, $1f, $1f, $1f, $1f, $3e, $3e
	db $76, $7e, $ee, $fe, $ce, $fe, $8c, $fc, $1c, $fc, $5c, $bc, $bb, $7b, $40, $40
	db $c0, $c0, $80, $80, $80, $80, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $03, $03, $0e, $0e, $3c, $3c, $ec, $fc, $98, $f8, $06, $07
	db $03, $03, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3e, $ff
	db $1e, $ff, $87, $ff, $d9, $e7, $ce, $f1, $67, $78, $73, $7c, $3b, $3c, $19, $1e
	db $0c, $0f, $0e, $0f, $07, $07, $00, $00, $00, $00, $00, $00, $00, $00, $36, $f9
	db $96, $79, $46, $b9, $66, $99, $77, $88, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $7f, $80, $3f, $c0, $03, $00, $00, $00, $00, $00, $00, $00, $a9, $de
	db $a3, $dc, $b7, $c8, $fe, $81, $7e, $81, $7c, $83, $fc, $03, $fb, $04, $f7, $08
	db $ff, $00, $ff, $00, $fe, $01, $c0, $00, $00, $00, $00, $00, $00, $00, $bf, $7f
	db $7c, $ff, $70, $ff, $c6, $f9, $9d, $e3, $3b, $c7, $f7, $0f, $ee, $1e, $cc, $3c
	db $98, $78, $30, $f0, $60, $e0, $00, $00, $00, $00, $00, $00, $00, $00, $30, $f0
	db $30, $f0, $60, $e0, $c0, $c0, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $06, $05
	db $11, $17, $2e, $39, $6d, $13, $13, $7f, $3f, $3f, $5f, $3f, $35, $6f, $a7, $df
	db $5f, $bf, $3f, $ff, $ef, $ff, $47, $7f, $27, $1f, $2f, $3f, $0e, $0e, $60, $00
	db $60, $e0, $f0, $e0, $e8, $d4, $86, $fe, $de, $fe, $ff, $ff, $97, $ef, $26, $de
	db $6e, $9e, $9c, $fc, $fe, $fe, $fe, $fe, $fc, $fc, $f8, $f8, $60, $60, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $0e, $00, $1f, $00, $3c, $42, $0c, $70
	db $08, $14, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $10, $00
	db $f0, $00, $c8, $30, $05, $48, $06, $01, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $08, $08, $18, $18, $08, $18, $08, $18, $08, $38, $00, $30, $20, $10
	db $30, $10, $70, $10, $40, $20, $40, $a0, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $10, $10, $18, $18, $10, $18, $10, $18, $10, $1c, $00, $0c, $04, $08
	db $0c, $08, $0e, $08, $02, $04, $02, $05, $06, $05, $03, $00, $01, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $08, $00
	db $0f, $00, $13, $0c, $a0, $1c, $60, $98, $00, $c0, $80, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $70, $00, $f8, $00, $3c, $42, $30, $0e
	db $10, $28, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $30, $00, $40, $38, $03, $60, $07, $40, $07, $00, $07, $40
	db $02, $01, $02, $01, $00, $00, $00, $08, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $80, $00, $80, $40, $c0, $00
	db $c8, $c0, $80, $c0, $05, $00, $06, $01, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $08, $08, $08, $08, $08, $18, $18, $08, $30, $20, $10, $20, $20, $10
	db $20, $10, $30, $50, $10, $70, $00, $e0, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $10, $10, $10, $10, $10, $18, $18, $10, $0c, $04, $08, $04, $04, $08
	db $04, $08, $0c, $0a, $08, $0e, $00, $07, $04, $07, $03, $00, $01, $02, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $01, $00, $01, $02, $03, $00
	db $13, $03, $01, $03, $a0, $00, $60, $88, $40, $80, $80, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $0c, $00, $02, $1c, $c0, $06, $e0, $02, $e0, $00, $e0, $02
	db $40, $80, $40, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $07, $00, $0f, $00, $1f, $00, $1e, $01, $10, $0f
	db $03, $1f, $0b, $0f, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $80, $00, $08, $c0, $00, $e0
	db $e0, $00, $a0, $40, $41, $02, $02, $05, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $08, $08, $08, $08, $18, $18, $18, $08, $30, $20, $30, $20, $00, $30
	db $20, $10, $20, $50, $10, $70, $50, $b0, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $10, $10, $10, $10, $18, $18, $18, $10, $1c, $1c, $1c, $14, $0c, $04
	db $0c, $04, $00, $0e, $04, $0a, $04, $0b, $00, $07, $03, $04, $05, $06, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $01, $00, $11, $02, $01, $06
	db $17, $00, $05, $02, $80, $44, $40, $a8, $80, $40, $00, $80, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $e0, $00, $f0, $00, $f8, $00, $f8, $00, $f8, $00
	db $c8, $b0, $d0, $f0, $00, $40, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $03, $00, $0f, $00, $1f, $20, $7f, $00, $30, $cf, $00, $7f
	db $00, $3f, $06, $09, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $60, $10, $f8, $04, $ff, $00, $ff, $00, $ff, $00, $8f, $70, $06, $f9
	db $00, $ff, $00, $3f, $00, $0f, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $c0, $20, $f0, $08, $bc, $40, $0c, $f3, $00, $fc
	db $00, $f0, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, $3f, $40, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $01, $01, $00, $01, $00
	db $01, $02, $03, $00, $03, $04, $07, $08, $1f, $20, $ff, $00, $ff, $00, $00, $80
	db $80, $00, $80, $00, $80, $00, $80, $00, $80, $40, $80, $40, $c0, $00, $c0, $00
	db $c0, $20, $e0, $00, $e0, $10, $f0, $08, $fc, $02, $ff, $00, $ff, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $60, $fe, $01, $00, $03
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $00
	db $1f, $20, $07, $08, $03, $04, $03, $00, $01, $02, $01, $00, $01, $00, $00, $01
	db $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $00
	db $fc, $02, $f0, $08, $e0, $10, $e0, $00, $c0, $20, $c0, $00, $c0, $00, $80, $40
	db $80, $40, $80, $00, $80, $00, $80, $00, $80, $00, $00, $80, $00, $00, $80, $60
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $10, $08, $00, $04, $02, $03, $04, $03, $00, $03, $00, $03, $00
	db $03, $04, $04, $02, $08, $00, $00, $10, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $04, $08, $00, $10, $20, $e0, $10, $e0, $00, $e0, $00, $e0, $00
	db $e0, $10, $10, $20, $08, $00, $00, $04, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $07, $08, $01, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $80, $80, $00, $80, $00, $c0, $00, $f0, $08, $c0, $00
	db $80, $00, $80, $00, $00, $80

SECTION "analyzed_0d08a8", ROMX[$48a8], BANK[$34]

Data_34_48a8:
	INCBIN "gfx/raw/Data_34_48a8.2bpp", 0, 4096

SECTION "analyzed_0d20ca", ROMX[$60ca], BANK[$34]

Data_34_60ca:
	db $01, $01, $01, $03, $07, $03, $07, $07, $07, $0f, $0d, $1f, $1f, $1f, $1d, $3f
	db $3f, $3f, $3d, $3f, $3f, $7f, $7d, $7f, $77, $7f, $77, $ff, $69, $ff, $75, $fe
	db $fa, $ff, $f5, $ff, $fe, $ff, $f5, $ff, $fe, $ff, $f5, $ff, $ff, $ff, $7d, $ff
	db $7f, $ff, $7d, $ff, $bf, $7f, $bf, $7f, $df, $3f, $df, $3f, $ef, $1f, $ef, $1f
	db $f7, $0f, $fb, $07, $fd, $03, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $02, $01, $05, $03, $07, $0f, $0e, $1f, $1c, $3f, $7a, $7f, $f0, $ff
	db $ea, $ff, $d0, $ff, $ea, $ff, $50, $ff, $ea, $ff, $54, $ff, $ea, $ff, $55, $ff
	db $aa, $ff, $55, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff, $ea, $ff, $75, $ff
	db $af, $df, $56, $f9, $ab, $fe, $55, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $ea, $ff, $55, $ff, $fa, $ff, $55, $ff, $ff, $ff, $d5, $ff, $ff, $ff, $fd, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $7f, $ff, $df, $3f, $ef, $1f, $e7, $1f, $f3, $07
	db $f7, $03, $fb, $03, $fb, $03, $fb, $03, $f9, $03, $f9, $03, $f9, $03, $00, $00
	db $00, $00, $00, $00, $00, $00, $59, $3e, $bf, $7f, $bf, $40, $2f, $40, $13, $30
	db $9c, $78, $e7, $ff, $a0, $ff, $00, $ff, $a3, $fc, $10, $e0, $90, $e0, $07, $f8
	db $00, $ff, $00, $ff, $18, $e7, $1c, $e3, $87, $f8, $00, $ff, $80, $ff, $60, $9f
	db $9c, $e3, $55, $ff, $80, $ff, $55, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $aa, $ff, $ff, $ff, $fd, $03, $54, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $aa, $ff, $55, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff, $fe, $f1, $57, $ee
	db $ff, $ef, $df, $ef, $ff, $ef, $ff, $ef, $fe, $ef, $f6, $ef, $f6, $ff, $f7, $ff
	db $90, $7f, $f7, $0f, $f7, $88, $f8, $87, $fd, $80, $fe, $80, $ff, $80, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $a0, $c0, $74, $f8, $ef, $1f, $fe, $01
	db $61, $1f, $9b, $07, $f7, $f8, $0f, $ff, $e1, $1f, $20, $1f, $0c, $03, $00, $00
	db $83, $00, $1f, $e0, $00, $ff, $00, $ff, $00, $ff, $e0, $1f, $00, $ff, $00, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $ff, $ff, $55, $ff, $ff, $ff, $ff, $00, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $aa, $ff, $55, $ff, $ab, $ff, $55, $ff, $af, $ff, $55, $ff, $ff, $ff, $55, $ff
	db $ff, $7f, $f5, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $ff, $7f, $ff
	db $57, $7f, $2a, $7f, $15, $bf, $8a, $4f, $31, $00, $67, $00, $1f, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $40, $80, $ff, $ff
	db $ff, $ff, $ff, $ff, $bf, $7f, $7f, $80, $ff, $ff, $0f, $ff, $00, $ff, $c0, $3f
	db $f0, $0f, $ff, $00, $7f, $80, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $55, $ff
	db $00, $ff, $55, $ff, $2a, $ff, $55, $ff, $af, $ff, $55, $ff, $ff, $ff, $55, $ff
	db $ff, $ff, $57, $ff, $ff, $ff, $60, $9f, $aa, $ff, $55, $ff, $ab, $ff, $55, $ff
	db $ff, $ff, $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $55, $ff
	db $ff, $ff, $55, $ff, $ff, $ff, $d5, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $55, $ff, $aa, $ff, $c0, $3f, $ff, $00, $ff, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $40, $80
	db $d8, $e0, $ec, $f0, $d8, $e4, $ef, $1e, $fe, $ff, $ff, $ff, $7f, $ff, $07, $ff
	db $03, $ff, $85, $7f, $e0, $1f, $05, $ff, $02, $ff, $57, $ff, $0a, $ff, $57, $ff
	db $2b, $ff, $5f, $ff, $ff, $ff, $5f, $ff, $fe, $ff, $5d, $fe, $fe, $fc, $7c, $f8
	db $f0, $f8, $f0, $f8, $c0, $f0, $00, $f0, $a0, $f0, $50, $e0, $ef, $f0, $5f, $f0
	db $f7, $f8, $7f, $f8, $ff, $f8, $fb, $fc, $ff, $fc, $ff, $fc, $fd, $fe, $7e, $ff
	db $ff, $ff, $5f, $ff, $ff, $ff, $57, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $aa, $ff, $00, $ff, $ff, $00, $ff, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $c0, $80, $a0, $c0, $c0, $e0
	db $f0, $e0, $e0, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $e0, $f0, $f0, $e0, $c0, $e0
	db $e0, $c0, $80, $c0, $40, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $0f, $00, $1f, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $7f, $80, $bf, $c0, $df, $e0, $ef, $f0, $ff, $f0, $ff, $f8, $fb, $fc, $ff, $fc
	db $ff, $fc, $fd, $fe, $fb, $fe, $ae, $ff, $3f, $df, $ff, $07, $ff, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $f0, $00, $fe, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $7f, $80, $9f, $80, $cf, $e0, $f3, $70, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $fc, $03, $f8, $07, $00, $3f, $00, $7f, $00, $ff, $00, $ff, $00, $ff, $48, $ff
	db $70, $ff, $f9, $ff, $fc, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00
	db $4f, $b0, $00, $f8, $00, $ff, $00, $ff, $06, $ff, $04, $ff, $0c, $ff, $03, $ff
	db $27, $ff, $df, $ff, $f9, $ff, $f0, $ff, $fb, $ff, $ff, $ff, $ff, $ff, $ff, $00
	db $e0, $00, $00, $00, $10, $fc, $3c, $ff, $2e, $ff, $0f, $ff, $3c, $ff, $1e, $ff
	db $fe, $ff, $1e, $ff, $34, $ff, $74, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $00
	db $00, $00, $00, $00, $00, $00, $00, $70, $10, $f8, $18, $ff, $1c, $ff, $b8, $ff
	db $f0, $ff, $5c, $ff, $7d, $ff, $3d, $ff, $3e, $ff, $7f, $ff, $ff, $ff, $ff, $00
	db $00, $03, $00, $07, $00, $3f, $01, $7f, $01, $ff, $06, $ff, $02, $ff, $07, $ff
	db $05, $ff, $e8, $ff, $93, $ff, $35, $ff, $3b, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $c0, $00, $f0, $00, $fe, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $80, $00, $e0, $00, $f8, $00, $ff, $00, $aa, $00
	db $00, $00, $aa, $00, $00, $00, $ac, $07, $03, $07, $03, $03, $01, $03, $aa, $00
	db $00, $00, $aa, $00, $00, $00, $7c, $80, $00, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0d28a8", ROMX[$68a8], BANK[$34]

Data_34_68a8:
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $e8
	db $57, $f8, $ff, $fc, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $1f, $ef, $f8, $78, $f8, $f8, $c0, $c0, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $1f, $1f, $7f, $7f, $ff, $ff, $fe, $fe, $fc, $fc, $7c, $7c, $38, $38, $18, $18
	db $00, $00, $00, $00, $80, $80, $d8, $18, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $c1, $00, $ff, $07, $ff, $0f, $ff, $7f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $fc, $ff, $fc, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $e7, $ff, $00, $ff, $00
	db $fd, $07, $ff, $0f, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $c0, $3f, $3b, $25, $13, $1f, $7f, $7f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $fd, $fd, $fd, $fd, $1c, $1c, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $01, $01, $01, $01, $15, $00, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $ff, $7f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $3f, $f1, $e0, $ff, $f3, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $7f
	db $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $aa, $55, $c0, $ff, $8a, $95, $85, $8a, $ca, $c5, $fd, $ff, $ff, $ff
	db $87, $87, $0f, $0f, $0f, $0f, $1e, $1e, $38, $38, $00, $00, $00, $00, $18, $18
	db $3f, $3c, $f5, $e0, $ff, $80, $55, $00, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $03, $03, $aa, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $fe, $fe, $e3, $e0, $ff, $e0, $ff, $f9, $ff, $9f, $ff, $ff, $ff, $ff, $ff, $ff
	db $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $75, $ea, $f8, $f9, $f8, $f8, $c1, $c1
	db $f8, $f8, $9c, $9c, $80, $80, $00, $00, $00, $00, $00, $00, $80, $80, $c0, $c0
	db $f1, $00, $55, $00, $ff, $00, $55, $00, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $ae, $0e, $67, $67, $ff, $7f, $ff, $ff, $d0, $d0, $e0, $e0, $10, $10, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $1f, $1d
	db $3f, $00, $ff, $04, $ff, $3c, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $03, $fc, $20, $c0, $44, $80, $af, $50
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $55, $aa, $aa, $55, $55, $aa, $ff, $ff
	db $7f, $7f, $0c, $0c, $00, $00, $01, $01, $07, $00, $0f, $00, $3f, $00, $bf, $00
	db $ff, $00, $55, $00, $ff, $00, $55, $00, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $80, $80, $ff, $fd, $fe, $fe, $e2, $e0, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $9f, $ff, $ff, $fe, $e6, $c1, $c0, $81, $80
	db $fe, $00, $fc, $00, $ff, $00, $ff, $80, $ff, $e1, $ff, $f3, $ff, $ff, $ff, $ff
	db $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $80, $3f, $7c, $03, $f0, $0f, $2a, $55
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $55, $aa, $aa, $55, $71, $b2, $e7, $00
	db $f5, $ea, $0f, $00, $03, $02, $03, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $55, $00, $ff, $00, $55, $00, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $0f, $0f, $67, $00, $e1, $00, $c7, $00
	db $01, $00, $1f, $00, $3f, $00, $ff, $00, $ff, $80, $ff, $f1, $ff, $ff, $ff, $ff
	db $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $55, $aa, $aa, $55, $55, $aa, $ff, $00
	db $55, $aa, $ff, $00, $55, $aa, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $55, $00, $ff, $00, $55, $00, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $7f, $f9, $19, $f0, $00
	db $ff, $00, $ff, $00, $ff, $3c, $ff, $3f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $55, $aa, $aa, $55, $55, $aa, $ff, $00
	db $55, $aa, $ff, $00, $55, $aa, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $55, $00, $ff, $00, $55, $00, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $fe, $7f, $3c
	db $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $55, $aa, $aa, $55, $55, $aa, $ff, $00
	db $55, $aa, $ff, $00, $55, $aa, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $07, $ff, $ff, $fc, $00, $55, $00, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $fc, $00, $ff, $00, $ff, $00, $ff, $80, $be, $e3, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $55, $aa, $aa, $55, $55, $aa, $ff, $00
	db $55, $aa, $ff, $00, $55, $aa, $ff, $00, $ff, $00, $ff, $00, $ff, $18, $f7, $75
	db $ff, $ff, $ff, $ff, $78, $78, $50, $00, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $d5, $7f, $c3, $03, $ed, $03, $ff, $07, $ea, $3f, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $50, $f0, $fc, $fc, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $55, $aa, $aa, $55, $55, $aa, $ff, $00
	db $55, $aa, $ff, $07, $73, $b3, $f0, $00, $ff, $00, $ff, $00, $ff, $01, $ff, $83
	db $ff, $ff, $fc, $fc, $07, $00, $55, $40, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $00, $ff, $2a, $55, $00, $1f, $2a, $15, $55, $aa, $aa, $55, $55, $aa, $ff, $03
	db $57, $af, $ff, $07, $55, $a9, $f0, $00, $f0, $f0, $e0, $e0, $fc, $fc, $ff, $ff
	db $75, $1f, $fc, $38, $57, $fc, $f0, $f0, $a7, $e0, $57, $f8, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $55, $aa, $aa, $55, $55, $aa, $ff, $00
	db $7d, $fa, $ef, $ec, $e4, $e4, $0f, $0f, $ff, $3f, $ff, $ff, $fc, $fc, $f8, $f8
	db $f8, $f8, $68, $68, $80, $00, $60, $20, $f8, $78, $55, $00, $ab, $01, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $07, $ff, $bf, $7f, $7f, $ff, $f1, $71, $41, $c1, $c0, $40, $80, $80, $00, $00
	db $e0, $e0, $f0, $f0, $f8, $f8, $f0, $f0, $30, $30, $20, $20, $e3, $e3, $e3, $e3
	db $9b, $00, $ff, $00, $57, $30, $ff, $1c, $ca, $1f, $d5, $7f, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $55, $aa, $aa, $55, $55, $aa, $ff, $00
	db $55, $aa, $ff, $00, $15, $0a, $ef, $e0, $f9, $f8, $ff, $ff, $ff, $ff, $ff, $ff
	db $3f, $3f, $3f, $3f, $3d, $3d, $38, $38, $00, $00, $00, $00, $80, $80, $45, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $fd, $fd, $f0, $f0, $e0, $e0, $fc, $fc
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $c7, $00, $ff, $00, $ff, $00, $ff, $03, $ea, $3f, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $ab, $57, $07, $ff, $a0, $20, $51, $a0, $aa, $55, $55, $aa, $ff, $00
	db $55, $aa, $ff, $00, $55, $aa, $ff, $00, $ff, $1c, $f3, $f1, $f3, $f3, $87, $87
	db $ff, $ff, $ff, $ff, $ff, $ff, $7f, $7f, $7f, $7f, $01, $01, $71, $71, $53, $13
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $e4, $e4, $c4, $c4, $c8, $c8, $f0, $f0, $e0, $e0, $c0, $c0, $00, $00, $00, $00
	db $00, $00, $00, $00, $a0, $20, $0f, $0f, $aa

SECTION "analyzed_0d30a8", ROMX[$70a8], BANK[$34]

Data_34_70a8:
	db $77, $7f, $8d, $6e, $81, $69, $c6, $5c, $77, $7f, $8d, $6e, $81, $69, $e4, $51
	db $77, $7f, $8d, $6e, $e3, $61, $25, $41, $5c, $5f, $37, $32, $94, $52, $6b, $2d
	db $5c, $5f, $37, $32, $06, $22, $e0, $2c, $5c, $5f, $de, $7b, $94, $52, $6b, $2d
	db $5c, $5f, $94, $52, $06, $22, $00, $00, $77, $7f, $8d, $6e, $81, $69, $de, $7b
	db $8d, $6e, $ff, $7f, $8f, $7f, $00, $00, $00, $7c, $ff, $7f, $b8, $6e, $31, $5e
	db $1f, $00, $ff, $7f, $f3, $6a, $c9, $5d, $ff, $03, $7e, $67, $de, $12, $dc, $0c
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $12, $14, $96, $72, $2e, $71, $88, $90, $98, $a0, $00, $08, $10, $18, $20, $28
	db $30, $38, $07, $0f, $17, $1f, $27, $2f, $37, $3f, $89, $91, $99, $a1, $01, $09
	db $11, $19, $21, $29, $31, $39, $40, $48, $50, $58, $60, $68, $46, $4e, $8a, $92
	db $9a, $a2, $02, $0a, $12, $1a, $22, $2a, $32, $3a, $41, $49, $51, $59, $61, $69
	db $47, $4f, $8b, $93, $9b, $a3, $03, $0b, $13, $1b, $23, $2b, $33, $3b, $42, $4a
	db $52, $5a, $62, $6a, $56, $5e, $8c, $94, $9c, $a4, $04, $0c, $14, $1c, $24, $2c
	db $34, $3c, $43, $4b, $53, $5b, $63, $6b, $57, $5f, $8d, $95, $9d, $a5, $05, $0d
	db $15, $1d, $25, $2d, $35, $3d, $44, $4c, $54, $5c, $64, $6c, $66, $6e, $8e, $96
	db $9e, $a6, $06, $0e, $16, $1e, $26, $2e, $36, $3e, $45, $4d, $55, $5d, $65, $6d
	db $67, $6f, $8f, $97, $9f, $a7, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87
	db $87, $87, $87, $87, $87, $87, $a8, $b0, $b8, $c0, $87, $87, $87, $87, $87, $87
	db $48, $40, $38, $30, $30, $38, $40, $48, $87, $87, $a9, $b1, $b9, $c1, $87, $87
	db $87, $87, $87, $87, $49, $41, $39, $31, $31, $39, $41, $49, $87, $87, $aa, $b2
	db $ba, $c2, $87, $87, $87, $87, $87, $87, $4a, $42, $3a, $32, $32, $3a, $42, $4a
	db $87, $87, $ab, $b3, $bb, $c3, $d3, $d3, $d2, $d2, $d3, $87, $4b, $43, $3b, $33
	db $33, $3b, $43, $4b, $87, $d3, $ac, $b4, $bc, $c4, $c8, $d0, $d8, $e0, $e8, $e8
	db $4c, $44, $3c, $34, $34, $3c, $44, $4c, $e8, $e8, $ad, $b5, $bd, $c5, $c9, $d1
	db $d9, $e1, $e9, $e8, $4d, $45, $3d, $35, $35, $3d, $45, $4d, $e8, $e8, $ae, $b6
	db $be, $c6, $ca, $d2, $da, $e2, $ea, $e8, $4e, $46, $3e, $36, $36, $3e, $46, $4e
	db $e8, $cb, $af, $b7, $bf, $c7, $d3, $db, $e3, $eb, $f3, $fb, $ce, $d6, $de, $e6
	db $ee, $c8, $ca, $cc, $ce, $d0, $f9, $fa, $47, $4f, $d4, $dc, $e4, $ec, $f4, $fc
	db $cf, $d7, $df, $e7, $ef, $c9, $cb, $cd, $cf, $d1, $cc, $cc, $cc, $cd, $d5, $dd
	db $e5, $ed, $f5, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $85, $85
	db $85, $85, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $85, $85, $85, $85, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $85, $85, $85, $85, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $85, $85, $85, $85, $0f, $0f
	db $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $85, $85
	db $85, $85, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	db $0f, $0f, $85, $85, $85, $85, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	db $0f, $0f, $0f, $0f, $0f, $0f, $85, $85, $85, $85, $0f, $0f, $0f, $0f, $0f, $0f
	db $0f, $08, $08, $08, $08, $08, $08, $0f, $0f, $0f, $85, $85, $85, $85, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $85, $85
	db $85, $85, $01, $01, $01, $01, $01, $01, $22, $22, $22, $22, $02, $02, $02, $02
	db $01, $01, $85, $85, $85, $85, $01, $01, $01, $01, $01, $01, $22, $22, $22, $22
	db $02, $02, $02, $02, $01, $01, $85, $85, $85, $85, $01, $01, $01, $01, $01, $01
	db $22, $22, $22, $22, $02, $02, $02, $02, $01, $01, $85, $85, $85, $85, $09, $29
	db $29, $09, $09, $02, $22, $22, $22, $22, $02, $02, $02, $02, $02, $29, $85, $85
	db $85, $85, $01, $01, $01, $01, $01, $01, $22, $22, $22, $22, $02, $02, $02, $02
	db $01, $01, $85, $85, $85, $85, $01, $01, $01, $01, $01, $01, $22, $22, $22, $22
	db $02, $02, $02, $02, $01, $01, $85, $85, $85, $85, $01, $01, $01, $01, $01, $01
	db $22, $22, $22, $22, $02, $02, $02, $02, $01, $01, $05, $05, $05, $05, $03, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $0c, $0c, $0c, $0c, $0c, $05, $05
	db $05, $05, $06, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $0c, $0c, $0c
	db $0c, $0c, $05, $05, $05, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $09, $0a, $5e, $74, $04, $74, $86, $86, $86, $86
	db $86, $86, $86, $86, $86, $86, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87
	db $87, $48, $40, $38, $30, $30, $38, $40, $48, $87, $87, $49, $41, $39, $31, $31
	db $39, $41, $49, $87, $87, $4a, $42, $3a, $32, $32, $3a, $42, $4a, $87, $87, $4b
	db $43, $3b, $33, $33, $3b, $43, $4b, $87, $e8, $4c, $44, $3c, $34, $34, $3c, $44
	db $4c, $e8, $e8, $4d, $45, $3d, $35, $35, $3d, $45, $4d, $e8, $e8, $4e, $46, $3e
	db $36, $36, $3e, $46, $4e, $e8, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $22, $22, $22, $22, $02
	db $02, $02, $02, $02, $02, $22, $22, $22, $22, $02, $02, $02, $02, $02, $02, $22
	db $22, $22, $22, $02, $02, $02, $02, $02, $02, $22, $22, $22, $22, $02, $02, $02
	db $02, $02, $02, $22, $22, $22, $22, $02, $02, $02, $02, $02, $02, $22, $22, $22
	db $22, $02, $02, $02, $02, $02, $02, $22, $22, $22, $22, $02, $02, $02, $02, $02
	db $09, $0a, $18, $75, $be, $74, $86, $86, $86, $86, $86, $86, $86, $86, $86, $86
	db $87, $6e, $87, $87, $87, $87, $87, $87, $6e, $87, $87, $6e, $66, $5e, $56, $56
	db $5e, $66, $6e, $87, $87, $68, $60, $58, $50, $50, $58, $60, $68, $87, $87, $69
	db $61, $59, $51, $51, $59, $61, $69, $87, $87, $6a, $62, $5a, $52, $52, $5a, $62
	db $6a, $87, $e8, $6b, $63, $5b, $53, $53, $5b, $63, $6b, $e8, $e8, $6c, $64, $5c
	db $54, $54, $5c, $64, $6c, $e8, $e8, $6d, $65, $5d, $55, $55, $5d, $65, $6d, $e8
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $22, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $22, $22, $22, $22, $02, $02, $02, $02, $02, $02, $22
	db $22, $22, $22, $02, $02, $02, $02, $02, $02, $22, $22, $22, $22, $02, $02, $02
	db $02, $02, $02, $22, $22, $22, $22, $02, $02, $02, $02, $02, $02, $22, $22, $22
	db $22, $02, $02, $02, $02, $02, $02, $22, $22, $22, $22, $02, $02, $02, $02, $02
	db $02, $22, $22, $22, $22, $02, $02, $02, $02, $02, $09, $0a, $d2, $75, $78, $75
	db $86, $86, $86, $86, $86, $86, $86, $86, $86, $86, $87, $87, $87, $87, $87, $87
	db $87, $87, $87, $87, $87, $6e, $87, $87, $87, $87, $87, $87, $6e, $87, $87, $6e
	db $66, $5e, $56, $56, $5e, $66, $6e, $87, $87, $6f, $67, $5f, $57, $57, $5f, $67
	db $6f, $87, $87, $7c, $74, $78, $70, $70, $78, $74, $7c, $87, $f1, $7d, $75, $79
	db $71, $71, $79, $75, $7d, $f1, $f2, $7e, $76, $7a, $72, $72, $7a, $76, $7e, $f2
	db $f8, $7f, $77, $7b, $73, $73, $7b, $77, $7f, $f8, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $22
	db $02, $02, $02, $02, $02, $02, $02, $02, $22, $22, $22, $22, $22, $02, $02, $02
	db $02, $02, $22, $22, $22, $22, $22, $02, $02, $02, $02, $02, $22, $22, $22, $22
	db $22, $02, $02, $02, $02, $02, $22, $22, $22, $22, $22, $02, $02, $02, $02, $02
	db $22, $22, $22, $22, $22, $02, $02, $02, $02, $02, $22, $22, $22, $22, $22, $02
	db $02, $02, $02, $02, $09, $0a, $8c, $76, $32, $76, $86, $86, $86, $86, $86, $86
	db $86, $86, $86, $86, $87, $87, $10, $08, $00, $00, $08, $10, $87, $87, $87, $6e
	db $11, $09, $01, $01, $09, $11, $6e, $87, $87, $6e, $12, $0a, $02, $02, $0a, $12
	db $6e, $87, $87, $87, $13, $0b, $03, $03, $0b, $13, $87, $87, $87, $87, $14, $0c
	db $04, $04, $0c, $14, $87, $87, $e8, $e8, $15, $0d, $05, $05, $0d, $15, $e8, $e8
	db $e8, $e8, $16, $0e, $06, $06, $0e, $16, $e8, $e8, $e8, $e8, $17, $0f, $07, $07
	db $0f, $17, $e8, $e8, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $22, $22, $22, $02, $02, $02, $02, $02, $02, $22, $22, $22, $22, $02, $02, $02
	db $02, $02, $22, $22, $22, $22, $22, $02, $02, $02, $02, $02, $22, $02, $22, $22
	db $22, $02, $02, $02, $02, $02, $02, $02, $22, $22, $22, $02, $02, $02, $02, $02
	db $02, $02, $22, $22, $22, $02, $02, $02, $02, $02, $02, $02, $22, $22, $22, $02
	db $02, $02, $02, $02, $02, $02, $22, $22, $22, $02, $02, $02, $02, $02, $09, $0a
	db $46, $77, $ec, $76, $86, $86, $86, $d4, $d5, $37, $3f, $86, $86, $86, $87, $6e
	db $28, $20, $18, $18, $20, $28, $6e, $87, $87, $6e, $29, $21, $19, $19, $21, $29
	db $6e, $87, $87, $87, $2a, $22, $1a, $1a, $22, $2a, $87, $87, $87, $87, $2b, $23
	db $1b, $1b, $23, $2b, $87, $87, $87, $87, $2c, $24, $1c, $1c, $24, $2c, $87, $87
	db $e8, $e8, $2d, $25, $1d, $1d, $25, $2d, $e8, $e8, $e8, $e8, $2e, $26, $1e, $1e
	db $26, $2e, $e8, $e8, $e8, $e8, $2f, $27, $1f, $1f, $27, $2f, $e8, $e8, $02, $02
	db $02, $0a, $0a, $02, $02, $02, $02, $02, $02, $22, $22, $22, $22, $02, $02, $02
	db $02, $02, $22, $22, $22, $22, $22, $02, $02, $02, $02, $02, $22, $02, $22, $22
	db $22, $02, $02, $02, $02, $02, $02, $02, $22, $22, $22, $02, $02, $02, $02, $02
	db $02, $02, $22, $22, $22, $02, $02, $02, $02, $02, $02, $02, $22, $22, $22, $02
	db $02, $02, $02, $02, $02, $02, $22, $22, $22, $02, $02, $02, $02, $02, $02, $02
	db $22, $22, $22, $02, $02, $02, $02, $02, $09, $0a, $00, $78, $a6, $77, $86, $86
	db $86, $86, $86, $86, $86, $86, $86, $86, $80, $88, $90, $98, $a0, $a8, $b0, $b8
	db $c0, $87, $81, $89, $91, $99, $a1, $a9, $b1, $b9, $c1, $87, $82, $8a, $92, $9a
	db $a2, $aa, $b2, $ba, $c2, $87, $83, $8b, $93, $9b, $a3, $ab, $b3, $bb, $c3, $87
	db $84, $8c, $94, $9c, $a4, $ac, $b4, $bc, $c4, $87, $85, $8d, $95, $9d, $a5, $ad
	db $b5, $bd, $c5, $e8, $86, $8e, $96, $9e, $a6, $ae, $b6, $be, $c6, $e8, $87, $8f
	db $97, $9f, $a7, $af, $b7, $bf, $c7, $e8, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $02, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $02, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $02
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $02, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $02, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $02, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $02, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $02, $09, $0a, $ba, $78, $60, $78, $86, $86, $86, $86, $86, $86, $86, $86
	db $86, $86, $87, $c0, $b8, $b0, $a8, $a0, $98, $90, $88, $80, $87, $c1, $b9, $b1
	db $a9, $a1, $99, $91, $89, $81, $87, $c2, $ba, $b2, $aa, $a2, $9a, $92, $8a, $82
	db $87, $c3, $bb, $b3, $ab, $a3, $9b, $93, $8b, $83, $87, $c4, $bc, $b4, $ac, $a4
	db $9c, $94, $8c, $84, $e8, $c5, $bd, $b5, $ad, $a5, $9d, $95, $8d, $85, $e8, $c6
	db $be, $b6, $ae, $a6, $9e, $96, $8e, $86, $e8, $c7, $bf, $b7, $af, $a7, $9f, $97
	db $8f, $87, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $22, $2a, $2a, $2a
	db $2a, $2a, $2a, $2a, $2a, $2a, $22, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a
	db $22, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $22, $2a, $2a, $2a, $2a, $2a
	db $2a, $2a, $2a, $2a, $22, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $22, $2a
	db $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $22, $2a, $2a, $2a, $2a, $2a, $2a, $2a
	db $2a, $2a, $22, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $03, $00, $00, $40
	db $02, $00, $08, $42, $02, $00, $10, $44, $02, $0c, $00, $00, $00, $03, $00, $08
	db $02, $03, $00, $10, $04, $03, $00, $18, $06, $03, $00, $20, $08, $03, $00, $28
	db $0a, $03, $10, $00, $0c, $03, $10, $08, $0e, $03, $10, $10, $10, $03, $10, $18
	db $12, $03, $10, $20, $14, $03, $10, $28, $16, $03, $08, $00, $00, $46, $00, $00
	db $08, $48, $00, $00, $10, $4a, $00, $00, $18, $4c, $00, $10, $00, $4e, $00, $10
	db $08, $50, $00, $10, $10, $52, $00, $10, $18, $54, $00, $02, $00, $00, $56, $00
	db $00, $08, $58, $00, $02, $00, $00, $5a, $00, $00, $08, $5c, $00, $02, $00, $00
	db $18, $01, $00, $08, $1a, $01, $06, $00, $00, $1c, $01, $00, $08, $1e, $01, $00
	db $10, $20, $01, $00, $18, $22, $01, $00, $20, $24, $01, $00, $28, $26, $01, $06
	db $00, $00, $28, $01, $00, $08, $2a, $01, $00, $10, $2c, $01, $00, $18, $2e, $01
	db $00, $20, $30, $01, $00, $28, $32, $01, $06, $00, $00, $34, $01, $00, $08, $36
	db $01, $00, $10, $38, $01, $00, $18, $3a, $01, $00, $20, $3c, $01, $00, $28, $3e
	db $01, $8e, $79, $a7, $79, $c0, $79, $0a, $b8, $74, $00, $1e, $72, $75, $00, $02
	db $2c, $76, $00, $1e, $e6, $76, $00, $04, $2c, $76, $00, $0c, $72, $75, $00, $04
	db $b8, $74, $00, $01, $fe, $73, $00, $ff, $7c, $fe, $73, $00, $06, $2c, $76, $00
	db $06, $a0, $77, $00, $06, $2c, $76, $00, $06, $5a, $78, $00, $04, $2c, $76, $00
	db $0c, $e6, $76, $00, $04, $2c, $76, $00, $06, $72, $75, $00, $06, $2c, $76, $00
	db $01, $fe, $73, $00, $ff

; ($35:$6000 BG + $35:$6040 OBJ palettes carved into src/gfx/portrait/ferious.asm
; as MistralPortraitPaletteBg / MistralPortraitPaletteObj.)

