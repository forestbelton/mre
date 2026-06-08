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
	FAR_CALL $12, Func_12_4c13
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
