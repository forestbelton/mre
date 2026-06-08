; Entity sprite-animation VM (bank $04).
;
; A tiny per-entity bytecode interpreter plus the animation scripts it runs.
; The entity behaviour engine drives it two ways (see src/room/engine.asm):
;   - EntityOp_Gfx ($07 a) -> EntityAnim_SetAnimation selects animation `a`: it indexes the
;     entity's animation-pointer table ([$ffcc/cd]) and loads the script pointer
;     into the VM program counter [$ffce/cf], then sets hEntityUpdate2.
;   - each frame, if hEntityUpdate2 != 0, the update path calls EntityAnim_Run,
;     which loads the PC from [$ffce] and interprets opcodes until the script
;     yields (saves PC, returns) for this frame.
;
; EntityAnim_Dispatch is the dispatch: read the opcode byte at [de], *2, index the
; 11-entry jump table at $401a, jp. EntityAnim_Yield saves the PC and returns
; (yield). Most of the bank ($43xx-$5f6a) is the animation-script DATA the PC
; walks -- ~679 little db blobs, still address-named.
;
; Relocated verbatim from analyzed.asm (fixed-address sections, addresses
; unchanged). The static-pass section split is kept as-is for now; the bytes
; between some sections are $00 pad, so the sections can't simply be merged.

SECTION "analyzed_010000", ROMX[$4000], BANK[$04]

EntityAnim_Run:
	ld hl, $ffce
	ld a, [hl+]
	ld e, a
	ld d, [hl]
EntityAnim_Dispatch:
	ld a, [de]
	add a, a
	ld c, a
	ld b, $00
	ld hl, EntityAnim_OpcodeTable
	add hl, bc
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp hl
EntityAnim_Yield:
	ld hl, $ffce
	ld a, e
	ld [hl+], a
	ld [hl], d
	ret

EntityAnim_OpcodeTable:
	db $3c, $40, $41, $40, $4e, $40, $55, $40, $62, $40, $6a, $40, $84, $40, $9f, $40
	db $ba, $40, $c3, $40, $cc, $40

SECTION "analyzed_01003a", ROMX[$403a], BANK[$04]

Data_04_403a:
	db $d8, $40

Func_04_403c:
	xor a
	ldh [hEntityUpdate2], a
	jr EntityAnim_Yield
	inc de
	ld a, [de]
	ldh [$ffb2], a
	ld c, a
	inc de
	push de
	call Func_04_419d
	pop de
	jr EntityAnim_Dispatch
	inc de
	ld a, [de]
	ldh [$ffc5], a
	inc de
	jr EntityAnim_Dispatch
	ld c, $c5
	ldh a, [c]
	or a
	jr z, Func_04_405f
	dec a
	ldh [c], a
	jr EntityAnim_Yield
Func_04_405f:
	inc de
	jr EntityAnim_Dispatch
	inc de
	ld a, [de]
	call PlaySound
	inc de
	jr EntityAnim_Dispatch
	inc de
	push de
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_04_4157
	pop de
	jr EntityAnim_Dispatch
	inc de
	push de
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_04_4191
	pop de
	jp EntityAnim_Dispatch
	inc de
	ld hl, $ffb6
	ld a, [de]
	inc de
	or a
	jr z, Func_04_40b5
	cp $01
	jr z, Func_04_40b0
	bit 7, [hl]
	jr nz, Func_04_40b5
Func_04_40b0:
	set 7, [hl]
	jp EntityAnim_Dispatch
Func_04_40b5:
	res 7, [hl]
	jp EntityAnim_Dispatch
	inc de
	ld hl, $ffb6
	set 6, [hl]
	jp EntityAnim_Dispatch
	inc de
	ld hl, $ffb6
	res 6, [hl]
	jp EntityAnim_Dispatch
	inc de
	ld hl, $4006
	push hl
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	jp hl
	inc de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld d, a
	ld e, l
	jp EntityAnim_Dispatch
EntityAnim_SetAnimation:
	ld a, b
	ldh [hEntityUpdate2], a
	ld l, a
	ld h, $00
	sla l
	rl h
	ldh a, [$ffcc]
	add a, l
	ld l, a
	ldh a, [$ffcd]
	adc a, h
	ld h, a
	ld a, [hl+]
	ldh [$ffce], a
	ld a, [hl]
	ldh [$ffcf], a
	xor a
	ldh [$ffb2], a
	ldh [$ffc5], a
	ret
Func_04_4100:
	ld a, [$cf67]
	ld l, a
	ld a, [$cf68]
	ld h, a
	ld a, $04
	rst AddAToHL
	ld a, [hl+]
	ld [$cf6b], a
	ld a, [hl]
	ld [$cf6c], a
	ret
Func_04_4114:
	ldh a, [$ffca]
	ld l, a
	ldh a, [$ffcb]
	ld h, a
	ldh a, [$ffb2]
	ld c, a
	ld b, $00
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	ldh a, [hEntityFacing]
	bit 7, a
	jr z, Func_04_4133
	inc bc
	inc bc
Func_04_4133:
	add hl, bc
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ret
Func_04_4138:
	push bc
	push hl
	ld b, $00
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	ld hl, $0006
	add hl, bc
	ldh a, [$ffca]
	ld c, a
	ldh a, [$ffcb]
	ld b, a
	add hl, bc
	ld a, [hl]
	pop hl
	pop bc
	ret
Func_04_4157:
	push bc
	call ReadFloorCell
	cp $22
	jr z, Func_04_4175
	cp $23
	jr z, Func_04_4175
	or a
	jr nz, Func_04_418f
	ldh a, [$ffac]
	bit 6, a
	jr nz, Func_04_418f
	ld a, c
	ld hl, wFloorCollision
	rst AddAToHL
	ld [hl], $22
	pop bc
	ret
Func_04_4175:
	ld b, $00
	ld hl, wFloorCollision
	add hl, bc
	ld [hl], $00
	ld hl, wFloorGrid
	add hl, bc
	pop bc
	ld a, [hl]
	bit 7, a
	jr z, Func_04_418b
	call Func_00_11dc
	ld [hl], a
Func_04_418b:
	call DrawFloorPiece
	ret

Func_04_418f:
	pop bc
	ret

Func_04_4191:
	push bc
	call Func_00_102b
	pop bc
	cp $22
	ret nz
	call DrawFloorPiece
	ret
Func_04_419d:
	ld b, $00
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	ld hl, $0004
	add hl, bc
	ldh a, [$ffca]
	ld c, a
	ldh a, [$ffcb]
	ld b, a
	add hl, bc
	push hl
	ld a, [hl]
	ld c, $d2
	call Func_04_4355
	pop hl
	inc hl
	ld a, [hl]
	ld c, $d6
	call Func_04_4355
	ret
	push de
	push hl
	ld b, $03
	ld c, $0e
	ld a, $60
	call Func_04_4247
	ld b, $03
	ld c, $0f
	ld a, $61
	call Func_04_4247
	ld b, $04
	ld c, $0f
	ld a, $62
	call Func_04_4247
	ld b, $05
	ld c, $0e
	ld a, $63
	call Func_04_4247
	ld b, $05
	ld c, $0f
	ld a, $64
	call Func_04_4247
	ld b, $06
	ld c, $0f
	ld a, $65
	call Func_04_4247
	ld b, $07
	ld c, $0f
	ld a, $66
	call Func_04_4247
	pop hl
	pop de
	ret
	push de
	push hl
	ld b, $03
	ld c, $0e
	xor a
	call Func_04_4247
	ld b, $03
	ld c, $0f
	xor a
	call Func_04_4247
	ld b, $04
	ld c, $0f
	xor a
	call Func_04_4247
	ld b, $05
	ld c, $0e
	xor a
	call Func_04_4247
	ld b, $05
	ld c, $0f
	xor a
	call Func_04_4247
	ld b, $06
	ld c, $0f
	xor a
	call Func_04_4247
	ld b, $07
	ld c, $0f
	xor a
	call Func_04_4247
	pop hl
	pop de
	ret
Func_04_4247:
	push af
	ld a, b
	swap a
	and $f0
	add a, b
	add a, c
	ld e, a
	ld d, $00
	ld hl, wFloorGrid
	add hl, de
	pop af
	ld [hl], a
	call DrawFloorPiece
	ret
EntityAnim_ResetState:
	xor a
	ld [$cc94], a
	ld c, $1c
	ld hl, $cd74
	ld de, $0008
Func_04_4268:
	ld [hl], a
	add hl, de
	dec c
	jr nz, Func_04_4268
	ld c, $1c
	ld hl, $ce54
Func_04_4272:
	ld [hl], a
	add hl, de
	dec c
	jr nz, Func_04_4272
	xor a
	ld [$cc91], a
	ld [$cc92], a
	ld [$cc93], a
	ld c, $1c
	ld hl, $c7f9
Func_04_4286:
	ld a, [hl]
	or a
	jr z, Func_04_42ab
	inc hl
	ld a, [hl-]
	or a
	jr z, Func_04_42ab
	call Func_00_11b4
	or a
	jr z, Func_04_42ab
	push hl
	ld de, $0006
	add hl, de
	ld a, [hl]
	pop hl
	bit 6, a
	jr nz, Func_04_42ab
	push bc
	push hl
	ld a, [hl]
	call Func_04_44ec
	call Func_04_42b3
	pop hl
	pop bc
Func_04_42ab:
	ld de, $002a
	add hl, de
	dec c
	jr nz, Func_04_4286
	ret
Func_04_42b3:
	ld [wBankCallTmp], a
	and $0f
	jr z, Func_04_42c6
	cp $01
	jr z, Func_04_42ce
	ld de, $ce54
	ld bc, $cc93
	jr Func_04_42d4
Func_04_42c6:
	ld de, $cc94
	ld bc, $cc91
	jr Func_04_42d4
Func_04_42ce:
	ld de, $cd74
	ld bc, $cc92
Func_04_42d4:
	ld a, [bc]
	cp $1c
	ret z
	push hl
	ld l, a
	ld h, $00
	inc a
	ld [bc], a
	sla l
	rl h
	sla l
	rl h
	sla l
	rl h
	add hl, de
	ld d, h
	ld e, l
	pop hl
	ld a, $01
	ld [de], a
	inc de
	ld a, [wBankCallTmp]
	ld [de], a
	inc de
	call Func_04_4319
	call Func_04_4114
	ld a, l
	ld [de], a
	inc de
	ld a, h
	ld [de], a
	inc de
	ldh a, [$ffb2]
	ld c, a
	call Func_04_4138
	ld [de], a
	inc de
	ldh a, [$ffd0]
	and $03
	ld [de], a
	inc de
	ldh a, [hEntityX]
	ld [de], a
	inc de
	ldh a, [hEntityY]
	ld [de], a
	ret
Func_04_4319:
	ld a, [hl+]
	ldh [hEntityState], a
	inc hl
	ld a, [hl+]
	ldh [$ffb2], a
	ld bc, $0003
	add hl, bc
	ld a, [hl+]
	ldh [hEntityFacing], a
	ld bc, $0005
	add hl, bc
	ld a, [hl+]
	ldh [hEntityX], a
	inc hl
	ld a, [hl+]
	ldh [hEntityY], a
	ld bc, $000b
	add hl, bc
	ld a, [hl+]
	ldh [$ffca], a
	ld a, [hl+]
	ldh [$ffcb], a
	ld bc, $0004
	add hl, bc
	ld a, [hl+]
	ldh [$ffd0], a
	ret
Func_04_4344:
	ld a, [$cf6b]
	ld c, $da
	call Func_04_4355
	ld a, [$cf6c]
	ld c, $de
	call Func_04_4355
	ret
Func_04_4355:
	ld l, a
	ld h, $00
	sla l
	rl h
	sla l
	rl h
	ld de, $4370
	add hl, de
	ld a, [hl+]
	ldh [c], a
	inc c
	ld a, [hl+]
	ldh [c], a
	inc c
	ld a, [hl+]
	ldh [c], a
	inc c
	ld a, [hl]
	ldh [c], a
	ret

Data_04_4370:
	db $00, $00, $00, $00, $fc, $f3, $08, $0e, $fc, $f3, $08, $0a, $fc, $f5, $08, $08

SECTION "analyzed_010388", ROMX[$4388], BANK[$04]

Data_04_4388:
	db $fc, $f9, $08, $10, $f0, $f8, $20, $10, $f9, $f9, $0e, $0e, $fa, $fa, $0c, $0c

Data_04_4398:
	db $f8, $f8, $10, $10, $f8, $00, $10, $08

Data_04_43a0:
	db $fa, $f3, $0c, $0e, $fc, $f5, $08, $08, $fa, $f9, $0c, $0e, $fc, $fa, $08, $0c
	db $fa, $f1, $0c, $10, $fd, $f2, $06, $0e, $fd, $f9, $06, $08, $fc, $fc, $08, $08
	db $fa, $fa, $0c, $0c

SECTION "analyzed_0103f0", ROMX[$43f0], BANK[$04]

Data_04_43f0:
	db $ec, $e9, $28, $18, $e8, $e9, $30, $18, $f0, $e9, $20, $18, $f0, $e9, $20, $18
	db $e8, $e1, $30, $20, $e8, $e1, $30, $20, $f4, $f9, $18, $14, $f4, $ed, $18, $14
	db $f4, $f5, $1b, $0c, $f8, $ea, $10, $2c, $f8, $ea, $10, $2c

SECTION "analyzed_010430", ROMX[$4430], BANK[$04]

Data_04_4430:
	db $fc, $fc, $08, $08, $fc, $fc, $08, $08, $fc, $fc, $08, $08

Data_04_443c:
	db $fc, $fc, $08, $08

Data_04_4440:
	db $fc, $fc, $08, $08, $fc, $fc, $08, $08, $fa, $fa, $0c, $0c, $fa, $fa, $0c, $0c
	db $fa, $fa, $0c, $0c, $f8, $f8, $10, $10

SECTION "analyzed_010470", ROMX[$4470], BANK[$04]

Data_04_4470:
	db $fc, $f4, $08, $08

Data_04_4474:
	db $fc, $f4, $08, $08

Data_04_4478:
	db $fc, $f4, $08, $08

SECTION "analyzed_01047d", ROMX[$447d], BANK[$04]

Data_04_447d:
	db $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01

SECTION "analyzed_010491", ROMX[$4491], BANK[$04]

Data_04_4491:
	db $01

SECTION "analyzed_010492", ROMX[$4492], BANK[$04]

Data_04_4492:
	db $01, $01, $01, $01, $01, $01

Data_04_4498:
	db $01, $00, $01

Data_04_449b:
	db $01, $11, $11

SECTION "analyzed_01049e", ROMX[$449e], BANK[$04]

Data_04_449e:
	db $11

SECTION "analyzed_01049f", ROMX[$449f], BANK[$04]

Data_04_449f:
	db $11, $11, $11

SECTION "analyzed_0104a2", ROMX[$44a2], BANK[$04]

Data_04_44a2:
	db $11

SECTION "analyzed_0104a3", ROMX[$44a3], BANK[$04]

Data_04_44a3:
	db $11, $01, $01, $11

SECTION "analyzed_0104a7", ROMX[$44a7], BANK[$04]

Data_04_44a7:
	db $11

SECTION "analyzed_0104a8", ROMX[$44a8], BANK[$04]

Data_04_44a8:
	db $01, $02, $02, $02, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11
	db $11, $01, $02, $01, $11, $11, $11, $11, $11, $11

SECTION "analyzed_0104cc", ROMX[$44cc], BANK[$04]

Data_04_44cc:
	db $01, $01, $01, $01, $01, $01

SECTION "analyzed_0104dc", ROMX[$44dc], BANK[$04]

Data_04_44dc:
	db $02, $02, $02, $02

SECTION "analyzed_0104ec", ROMX[$44ec], BANK[$04]

Func_04_44ec:
	push hl
	ld hl, $447c
	rst AddAToHL
	ld a, [hl]
	pop hl
	ret

Data_04_44f4:
	db $5a, $53

Data_04_44f6:
	db $5a, $53

Data_04_44f8:
	db $00, $00, $00

SECTION "analyzed_0104fc", ROMX[$44fc], BANK[$04]

Data_04_44fc:
	db $15, $53

Data_04_44fe:
	db $15, $53

Data_04_4500:
	db $00, $00, $00

SECTION "analyzed_010504", ROMX[$4504], BANK[$04]

Data_04_4504:
	db $1e, $53

Data_04_4506:
	db $1e, $53

Data_04_4508:
	db $00, $00, $00

SECTION "analyzed_01050c", ROMX[$450c], BANK[$04]

Data_04_450c:
	db $27, $53

Data_04_450e:
	db $27, $53

Data_04_4510:
	db $00, $00, $00

SECTION "analyzed_010514", ROMX[$4514], BANK[$04]

Data_04_4514:
	db $2c, $53, $2c, $53, $00, $00, $00

SECTION "analyzed_01051c", ROMX[$451c], BANK[$04]

Data_04_451c:
	db $31, $53

Data_04_451e:
	db $31, $53

Data_04_4520:
	db $00, $00, $00

SECTION "analyzed_010524", ROMX[$4524], BANK[$04]

Data_04_4524:
	db $43, $53, $3a, $53, $00, $00, $00

SECTION "analyzed_01052c", ROMX[$452c], BANK[$04]

Data_04_452c:
	db $4c, $53

Data_04_452e:
	db $4c, $53

Data_04_4530:
	db $00, $00, $00

SECTION "analyzed_010534", ROMX[$4534], BANK[$04]

Data_04_4534:
	db $51, $53

Data_04_4536:
	db $51, $53

Data_04_4538:
	db $00, $00, $00

SECTION "analyzed_01053c", ROMX[$453c], BANK[$04]

Data_04_453c:
	db $8c, $53

Data_04_453e:
	db $8c, $53

Data_04_4540:
	db $30, $30, $00

SECTION "analyzed_010544", ROMX[$4544], BANK[$04]

Data_04_4544:
	db $95, $53

Data_04_4546:
	db $95, $53

Data_04_4548:
	db $30, $30, $00

SECTION "analyzed_01054c", ROMX[$454c], BANK[$04]

Data_04_454c:
	db $9e, $53

Data_04_454e:
	db $9e, $53

Data_04_4550:
	db $30, $30, $00

SECTION "analyzed_010554", ROMX[$4554], BANK[$04]

Data_04_4554:
	db $a7, $53

Data_04_4556:
	db $a7, $53

Data_04_4558:
	db $30, $30, $00

SECTION "analyzed_01055c", ROMX[$455c], BANK[$04]

Data_04_455c:
	db $d0, $54

Data_04_455e:
	db $d0, $54

Data_04_4560:
	db $00, $00, $00

SECTION "analyzed_010564", ROMX[$4564], BANK[$04]

Data_04_4564:
	db $b9, $53

Data_04_4566:
	db $b9, $53

Data_04_4568:
	db $31, $31, $00

SECTION "analyzed_01056c", ROMX[$456c], BANK[$04]

Data_04_456c:
	db $c2, $53

Data_04_456e:
	db $c2, $53

Data_04_4570:
	db $31, $31, $00

SECTION "analyzed_010574", ROMX[$4574], BANK[$04]

Data_04_4574:
	db $cb, $53

Data_04_4576:
	db $cb, $53

Data_04_4578:
	db $31, $31, $00

SECTION "analyzed_01057c", ROMX[$457c], BANK[$04]

Data_04_457c:
	db $d4, $53

Data_04_457e:
	db $d4, $53

Data_04_4580:
	db $31, $31, $00

SECTION "analyzed_010584", ROMX[$4584], BANK[$04]

Data_04_4584:
	db $2a, $55, $96, $55, $00, $40, $03

SECTION "analyzed_01058c", ROMX[$458c], BANK[$04]

Data_04_458c:
	db $33, $55, $9f, $55, $00, $40, $03

SECTION "analyzed_010594", ROMX[$4594], BANK[$04]

Data_04_4594:
	db $2a, $55, $96, $55, $00, $00, $00

SECTION "analyzed_01059c", ROMX[$459c], BANK[$04]

Data_04_459c:
	db $33, $55, $9f, $55, $00, $00, $00

SECTION "analyzed_0105a4", ROMX[$45a4], BANK[$04]

Data_04_45a4:
	db $3c, $55, $a8, $55, $00, $00, $00

Data_04_45ab:
	db $00, $02, $56, $6e, $56, $00, $00, $03, $00, $0b, $56, $77, $56, $00, $00, $03
	db $00, $14, $56, $80, $56, $00, $00, $03, $00, $1d, $56, $89, $56, $00, $00, $03
	db $00

Data_04_45cc:
	db $02, $56, $6e, $56, $00, $00, $01

SECTION "analyzed_0105d4", ROMX[$45d4], BANK[$04]

Data_04_45d4:
	db $0b, $56, $77, $56, $00, $00, $01

SECTION "analyzed_0105dc", ROMX[$45dc], BANK[$04]

Data_04_45dc:
	db $14, $56, $80, $56, $00, $00, $01

SECTION "analyzed_0105e4", ROMX[$45e4], BANK[$04]

Data_04_45e4:
	db $02, $56, $6e, $56, $00, $32, $03

SECTION "analyzed_0105ec", ROMX[$45ec], BANK[$04]

Data_04_45ec:
	db $88, $54

Data_04_45ee:
	db $88, $54

Data_04_45f0:
	db $00, $00, $00

SECTION "analyzed_0105f4", ROMX[$45f4], BANK[$04]

Data_04_45f4:
	db $91, $54

Data_04_45f6:
	db $91, $54

Data_04_45f8:
	db $00, $00, $00

SECTION "analyzed_0105fc", ROMX[$45fc], BANK[$04]

Data_04_45fc:
	db $9a, $54

Data_04_45fe:
	db $9a, $54

Data_04_4600:
	db $00, $00, $00

SECTION "analyzed_010604", ROMX[$4604], BANK[$04]

Data_04_4604:
	db $a3, $54

Data_04_4606:
	db $a3, $54

Data_04_4608:
	db $00, $00, $00

SECTION "analyzed_01060c", ROMX[$460c], BANK[$04]

Data_04_460c:
	db $ac, $54

Data_04_460e:
	db $ac, $54

Data_04_4610:
	db $00, $00, $00

SECTION "analyzed_010614", ROMX[$4614], BANK[$04]

Data_04_4614:
	db $b5, $54

Data_04_4616:
	db $b5, $54

Data_04_4618:
	db $00, $00, $00

SECTION "analyzed_01061c", ROMX[$461c], BANK[$04]

Data_04_461c:
	db $be, $54

Data_04_461e:
	db $be, $54

Data_04_4620:
	db $00, $00, $00

SECTION "analyzed_010624", ROMX[$4624], BANK[$04]

Data_04_4624:
	db $c7, $54

Data_04_4626:
	db $c7, $54

Data_04_4628:
	db $00, $00, $00

SECTION "analyzed_01062c", ROMX[$462c], BANK[$04]

Data_04_462c:
	db $8a, $5a

Data_04_462e:
	db $8a, $5a

Data_04_4630:
	db $07, $07, $00

SECTION "analyzed_010634", ROMX[$4634], BANK[$04]

Data_04_4634:
	db $8a, $5a

Data_04_4636:
	db $8a, $5a

Data_04_4638:
	db $07, $00, $00

SECTION "analyzed_01063c", ROMX[$463c], BANK[$04]

Data_04_463c:
	db $01, $54

Data_04_463e:
	db $01, $54

Data_04_4640:
	db $30, $00, $00

SECTION "analyzed_010644", ROMX[$4644], BANK[$04]

Data_04_4644:
	db $0a, $54

Data_04_4646:
	db $0a, $54

Data_04_4648:
	db $30, $00, $00

SECTION "analyzed_01064c", ROMX[$464c], BANK[$04]

Data_04_464c:
	db $13, $54

Data_04_464e:
	db $13, $54

Data_04_4650:
	db $30, $00, $00

SECTION "analyzed_010654", ROMX[$4654], BANK[$04]

Data_04_4654:
	db $1c, $54

Data_04_4656:
	db $1c, $54

Data_04_4658:
	db $30, $00, $00

SECTION "analyzed_01065c", ROMX[$465c], BANK[$04]

Data_04_465c:
	db $25, $54

Data_04_465e:
	db $25, $54

Data_04_4660:
	db $30, $00, $00

SECTION "analyzed_010664", ROMX[$4664], BANK[$04]

Data_04_4664:
	db $2e, $54

Data_04_4666:
	db $2e, $54

Data_04_4668:
	db $30, $00, $00

SECTION "analyzed_01066c", ROMX[$466c], BANK[$04]

Data_04_466c:
	db $37, $54

Data_04_466e:
	db $37, $54

Data_04_4670:
	db $30, $00, $00

SECTION "analyzed_010674", ROMX[$4674], BANK[$04]

Data_04_4674:
	db $40, $54

Data_04_4676:
	db $40, $54

Data_04_4678:
	db $30, $00, $00

SECTION "analyzed_01067c", ROMX[$467c], BANK[$04]

Data_04_467c:
	db $49, $54

Data_04_467e:
	db $49, $54

Data_04_4680:
	db $30, $00, $00

SECTION "analyzed_010684", ROMX[$4684], BANK[$04]

Data_04_4684:
	db $52, $54

Data_04_4686:
	db $52, $54

Data_04_4688:
	db $30, $00, $00

SECTION "analyzed_01068c", ROMX[$468c], BANK[$04]

Data_04_468c:
	db $5b, $54

Data_04_468e:
	db $5b, $54

Data_04_4690:
	db $30, $00, $00

SECTION "analyzed_010694", ROMX[$4694], BANK[$04]

Data_04_4694:
	db $64, $54

Data_04_4696:
	db $64, $54

Data_04_4698:
	db $30, $00, $00

SECTION "analyzed_01069c", ROMX[$469c], BANK[$04]

Data_04_469c:
	db $6d, $54

Data_04_469e:
	db $6d, $54

Data_04_46a0:
	db $30, $00, $00

SECTION "analyzed_0106a4", ROMX[$46a4], BANK[$04]

Data_04_46a4:
	db $76, $54

Data_04_46a6:
	db $76, $54

Data_04_46a8:
	db $30, $00, $00

SECTION "analyzed_0106ac", ROMX[$46ac], BANK[$04]

Data_04_46ac:
	db $7f, $54

Data_04_46ae:
	db $7f, $54

Data_04_46b0:
	db $30, $00, $00

SECTION "analyzed_0106b4", ROMX[$46b4], BANK[$04]

Data_04_46b4:
	db $63, $53

Data_04_46b6:
	db $63, $53

Data_04_46b8:
	db $00, $00, $00

SECTION "analyzed_0106bc", ROMX[$46bc], BANK[$04]

Data_04_46bc:
	db $68, $53

Data_04_46be:
	db $68, $53

Data_04_46c0:
	db $00, $00, $00

SECTION "analyzed_0106c4", ROMX[$46c4], BANK[$04]

Data_04_46c4:
	db $71, $53

Data_04_46c6:
	db $71, $53

Data_04_46c8:
	db $00, $00, $00

SECTION "analyzed_0106cc", ROMX[$46cc], BANK[$04]

Data_04_46cc:
	db $7a, $53

Data_04_46ce:
	db $7a, $53

Data_04_46d0:
	db $00, $00, $00

SECTION "analyzed_0106d4", ROMX[$46d4], BANK[$04]

Data_04_46d4:
	db $83, $53

Data_04_46d6:
	db $83, $53

Data_04_46d8:
	db $00, $00, $00

SECTION "analyzed_0106dc", ROMX[$46dc], BANK[$04]

Data_04_46dc:
	db $2a, $55, $96, $55, $00, $42, $03

SECTION "analyzed_0106e4", ROMX[$46e4], BANK[$04]

Data_04_46e4:
	db $33, $55, $9f, $55, $00, $42, $03

Data_04_46eb:
	db $00, $3c, $55, $a8, $55, $00, $42, $03, $00

Data_04_46f4:
	db $02, $56, $6e, $56, $00, $00, $01

SECTION "analyzed_0106fc", ROMX[$46fc], BANK[$04]

Data_04_46fc:
	db $0b, $56, $77, $56, $00, $00, $01

SECTION "analyzed_010704", ROMX[$4704], BANK[$04]

Data_04_4704:
	db $14, $56, $80, $56, $00, $00, $01

Data_04_470b:
	db $00, $02, $56, $6e, $56, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00
	db $00

Data_04_471c:
	db $da, $56, $46, $57, $00, $34, $03

SECTION "analyzed_010724", ROMX[$4724], BANK[$04]

Data_04_4724:
	db $e3, $56, $4f, $57, $00, $34, $03

Data_04_472b:
	db $00, $ec, $56, $58, $57, $00, $34, $03, $00, $f5, $56, $61, $57, $00, $34, $03
	db $00

Data_04_473c:
	db $91, $5d, $91, $5d, $36, $36, $00

SECTION "analyzed_010744", ROMX[$4744], BANK[$04]

Data_04_4744:
	db $9a, $5d, $9a, $5d, $36, $36, $00

SECTION "analyzed_01074c", ROMX[$474c], BANK[$04]

Data_04_474c:
	db $a3, $5d, $a3, $5d, $36, $00, $00

SECTION "analyzed_010754", ROMX[$4754], BANK[$04]

Data_04_4754:
	db $ac, $5d, $ac, $5d, $36, $00, $00

SECTION "analyzed_01075c", ROMX[$475c], BANK[$04]

Data_04_475c:
	db $cc, $5f

Data_04_475e:
	db $cc, $5f

Data_04_4760:
	db $37, $37, $00

SECTION "analyzed_010764", ROMX[$4764], BANK[$04]

Data_04_4764:
	db $d5, $5f

Data_04_4766:
	db $d5, $5f

Data_04_4768:
	db $37, $00, $00

SECTION "analyzed_01076c", ROMX[$476c], BANK[$04]

Data_04_476c:
	db $de, $5f

Data_04_476e:
	db $de, $5f

Data_04_4770:
	db $37, $00, $00

SECTION "analyzed_010774", ROMX[$4774], BANK[$04]

Data_04_4774:
	db $9f, $5f

Data_04_4776:
	db $9f, $5f

Data_04_4778:
	db $38, $38, $00

SECTION "analyzed_01077c", ROMX[$477c], BANK[$04]

Data_04_477c:
	db $8d, $60

Data_04_477e:
	db $8d, $60

Data_04_4780:
	db $00, $00, $00

SECTION "analyzed_010784", ROMX[$4784], BANK[$04]

Data_04_4784:
	db $a8, $62

Data_04_4786:
	db $a8, $62

Data_04_4788:
	db $00, $00, $00

SECTION "analyzed_01078c", ROMX[$478c], BANK[$04]

Data_04_478c:
	db $d9, $62

Data_04_478e:
	db $d9, $62

Data_04_4790:
	db $00, $00, $00

SECTION "analyzed_010794", ROMX[$4794], BANK[$04]

Data_04_4794:
	db $0a, $63, $13, $63, $39, $39, $00

SECTION "analyzed_01079c", ROMX[$479c], BANK[$04]

Data_04_479c:
	db $1c, $63, $25, $63, $39, $39, $00

SECTION "analyzed_0107a4", ROMX[$47a4], BANK[$04]

Data_04_47a4:
	db $2e, $63, $37, $63, $39, $39, $00

SECTION "analyzed_0107bc", ROMX[$47bc], BANK[$04]

Data_04_47bc:
	db $d9, $54

Data_04_47be:
	db $d9, $54

Data_04_47c0:
	db $00, $00, $00

SECTION "analyzed_0107c4", ROMX[$47c4], BANK[$04]

Data_04_47c4:
	db $7d, $5d

Data_04_47c6:
	db $7d, $5d

Data_04_47c8:
	db $06, $06, $00

SECTION "analyzed_0107cc", ROMX[$47cc], BANK[$04]

Data_04_47cc:
	db $82, $5d

Data_04_47ce:
	db $82, $5d

Data_04_47d0:
	db $00, $00, $00

SECTION "analyzed_0107d4", ROMX[$47d4], BANK[$04]

Data_04_47d4:
	db $87, $5d

Data_04_47d6:
	db $87, $5d

Data_04_47d8:
	db $00, $00, $00

SECTION "analyzed_0107dc", ROMX[$47dc], BANK[$04]

Data_04_47dc:
	db $8c, $5d

Data_04_47de:
	db $8c, $5d

Data_04_47e0:
	db $00, $00, $00

SECTION "analyzed_0107e4", ROMX[$47e4], BANK[$04]

Data_04_47e4:
	db $a8, $5f

Data_04_47e6:
	db $a8, $5f

Data_04_47e8:
	db $00, $00, $00

SECTION "analyzed_0107ec", ROMX[$47ec], BANK[$04]

Data_04_47ec:
	db $b1, $5f

Data_04_47ee:
	db $b1, $5f

Data_04_47f0:
	db $00, $00, $00

SECTION "analyzed_0107f4", ROMX[$47f4], BANK[$04]

Data_04_47f4:
	db $ba, $5f

Data_04_47f6:
	db $ba, $5f

Data_04_47f8:
	db $00, $00, $00

SECTION "analyzed_0107fc", ROMX[$47fc], BANK[$04]

Data_04_47fc:
	db $c3, $5f

Data_04_47fe:
	db $c3, $5f

Data_04_4800:
	db $00, $00, $00

SECTION "analyzed_010804", ROMX[$4804], BANK[$04]

Data_04_4804:
	db $6a, $5a, $6a, $5a, $00, $35, $00

SECTION "analyzed_01080c", ROMX[$480c], BANK[$04]

Data_04_480c:
	db $6f, $5a, $6f, $5a, $00, $00, $00

SECTION "analyzed_010814", ROMX[$4814], BANK[$04]

Data_04_4814:
	db $78, $5a, $78, $5a, $00, $00, $00

SECTION "analyzed_01081c", ROMX[$481c], BANK[$04]

Data_04_481c:
	db $81, $5a, $81, $5a, $00, $00, $00

Data_04_4823:
	db $00, $ba, $4c

Data_04_4826:
	db $a0, $48, $a8, $48, $bc, $48, $cf, $48, $dc, $48, $e9, $48, $eb, $48, $59, $49
	db $f6, $48, $2c, $49, $61, $49, $12, $49, $33, $4b, $3d, $4b, $03, $49, $71, $49
	db $f4, $49, $f6, $49, $fe, $49, $00, $4a

Data_04_484e:
	db $08, $4a

Data_04_4850:
	db $0a, $4a

Data_04_4852:
	db $12, $4a

Data_04_4854:
	db $14, $4a, $bf, $49, $1c, $4a, $1e, $4a, $26, $4a, $28, $4a

Data_04_4860:
	db $30, $4a

Data_04_4862:
	db $32, $4a

Data_04_4864:
	db $3a, $4a

Data_04_4866:
	db $3c, $4a, $78, $4b, $80, $4b, $97, $4b

Data_04_486e:
	db $ba, $4c, $ba, $4c, $ba, $4c

Data_04_4874:
	db $d0, $4b, $ae, $4b, $b6, $4b, $be, $4b, $5d, $4b, $65, $4b, $45, $4b, $52, $4b
	db $44, $4a, $51, $4a

Data_04_4888:
	db $7a, $4a

Data_04_488a:
	db $a8, $4a, $b8, $4a, $c8, $4a

Data_04_4890:
	db $f1, $4a

Data_04_4892:
	db $f9, $4a, $70, $4b

SECTION "analyzed_010898", ROMX[$4898], BANK[$04]

Data_04_4898:
	db $19, $4b

Data_04_489a:
	db $26, $4b

Data_04_489c:
	db $01, $4b, $09, $4b, $04, $02, $01, $00, $02, $03, $03, $00, $05, $04, $01, $01
	db $01, $02, $03, $03, $01, $02, $02, $03, $03, $01, $03, $02, $03, $03, $06, $00
	db $04, $03, $05, $01, $01, $02, $03, $03, $01, $02, $02, $03, $03, $01, $00, $02
	db $03, $03, $00, $04, $04, $01, $04, $02, $03, $03, $01, $06, $02, $03, $03, $00
	db $04, $04, $01, $04, $02, $03, $03, $01, $05, $02, $03, $03, $00, $04, $04, $01
	db $07, $02, $03, $03, $01, $08, $02, $03, $03, $00, $01, $01, $02, $05, $03, $01
	db $02, $02, $05, $03, $10, $f6, $48, $04, $1b, $01, $01, $02, $05, $03, $01, $02
	db $02, $05, $03, $10, $05, $49, $01, $38, $02, $03, $03, $01, $39, $02, $03, $03
	db $01, $3a, $02, $03, $03, $01, $3b, $02, $03, $03, $01, $3c, $02, $03, $03

SECTION "analyzed_01092c", ROMX[$492c], BANK[$04]

Data_04_492c:
	db $04, $07, $01, $1f, $02, $03, $03, $01, $20, $02, $03, $03, $01, $21, $02, $03
	db $03, $01, $22, $02, $03, $03, $01, $23, $02, $03, $03, $01, $24, $02, $03, $03
	db $01, $25, $02, $03, $03, $01, $26, $02, $03, $03, $10, $f6, $48, $01, $0d, $02
	db $01, $03, $10, $59, $49, $01, $01, $02, $03, $03, $01, $02, $02, $03, $03, $01
	db $00, $02, $03, $03, $00, $04, $03, $01, $29, $02, $02, $03, $01, $2a, $02, $02
	db $03, $01, $2b, $02, $02, $03, $01, $2c, $02, $02, $03, $01, $2d, $02, $02, $03
	db $01, $2e, $02, $02, $03, $01, $2f, $02, $02, $03, $01, $30, $02, $02, $03, $01
	db $31, $02, $02, $03, $01, $32, $02, $02, $03, $01, $33, $02, $02, $03, $01, $34
	db $02, $02, $03, $01, $35, $02, $02, $03, $01, $36, $02, $02, $03, $01, $37, $02
	db $02, $03, $00, $04, $03, $01, $2e, $02, $02, $03, $01, $2f, $02, $02, $03, $01
	db $30, $02, $02, $03, $01, $31, $02, $02, $03, $01, $32, $02, $02, $03, $01, $33
	db $02, $02, $03, $01, $34, $02, $02, $03, $01, $35, $02, $02, $03, $01, $36, $02
	db $02, $03, $01, $37, $02, $02, $03, $00, $04, $0e, $01, $09, $02, $01, $03, $10
	db $f6, $49, $04, $0e, $01, $0a, $02, $01, $03, $10, $00, $4a

Data_04_4a08:
	db $04, $0e

Data_04_4a0a:
	db $01, $0b, $02, $01, $03, $10, $0a, $4a

Data_04_4a12:
	db $04, $0e

Data_04_4a14:
	db $01, $0c, $02, $01, $03, $10, $14, $4a, $04, $0e, $01, $0e, $02, $01, $03, $10
	db $1e, $4a, $04, $0e, $01, $0f, $02, $01, $03, $10, $28, $4a

Data_04_4a30:
	db $04, $0e

Data_04_4a32:
	db $01, $10, $02, $01, $03, $10, $32, $4a

Data_04_4a3a:
	db $04, $0e

Data_04_4a3c:
	db $01, $11, $02, $01, $03, $10, $3c, $4a, $01, $12, $02, $05, $03, $01, $13, $02
	db $05, $03, $10, $44, $4a, $01, $14, $02, $05, $03, $01, $15, $02, $05, $03, $01
	db $16, $02, $05, $03, $01, $15, $02, $05, $03, $01, $14, $02, $05, $03, $01, $15
	db $02, $05, $03, $01, $16, $02, $05, $03, $01, $15, $02, $05, $03

Data_04_4a79:
	db $00, $01, $17, $02, $07, $03, $01, $18, $02, $07, $03, $01, $19, $02, $07, $03
	db $01, $17, $02, $04, $03, $01, $18, $02, $04, $03, $01, $19, $02, $04, $03, $01
	db $1a, $02, $03, $03, $01, $18, $02, $03, $03, $01, $17, $02, $03, $03, $00

Data_04_4aa8:
	db $01, $1b, $02, $03, $03, $01, $1c, $02, $03, $03, $01, $1d, $02, $03, $03

SECTION "analyzed_010ab8", ROMX[$4ab8], BANK[$04]

Data_04_4ab8:
	db $01, $3d, $02, $03, $03, $01, $3e, $02, $03, $03

Data_04_4ac2:
	db $01, $3f, $02, $03, $03, $00

Data_04_4ac8:
	db $01, $40, $02, $03, $03, $01, $41, $02, $03, $03, $01, $42, $02, $03, $03, $01
	db $41, $02, $03, $03, $01, $42, $02, $03, $03, $01, $41, $02, $03, $03

Data_04_4ae6:
	db $01, $42, $02, $03, $03, $01, $40, $02, $03, $03, $00, $01, $43, $02, $02, $03
	db $10, $f1, $4a

Data_04_4af9:
	db $01, $1e, $02, $02, $03, $10, $f9, $4a, $01, $62, $02, $02, $03, $10, $01, $4b
	db $01, $63, $02, $07, $03, $01, $64, $02, $07, $03, $01, $65, $02, $07, $03

SECTION "analyzed_010b19", ROMX[$4b19], BANK[$04]

Data_04_4b19:
	db $01, $45, $02, $03, $03, $01, $46, $02, $03, $03, $10, $19, $4b

Data_04_4b26:
	db $01, $47, $02, $03, $03, $01, $48, $02, $03, $03, $10, $26, $4b

Data_04_4b33:
	db $04, $12, $01, $27, $02, $03, $03, $10, $35, $4b, $01, $28, $02, $03, $03, $10
	db $3d, $4b, $01, $49, $02, $05, $03, $01, $4a, $02, $05, $03, $10, $45, $4b, $01
	db $4b, $02, $05, $03, $01, $4c, $02, $05, $03

SECTION "analyzed_010b5d", ROMX[$4b5d], BANK[$04]

Data_04_4b5d:
	db $01, $4d, $02, $05, $03, $10, $5d, $4b, $01, $4e, $02, $05, $03, $01, $4f, $02
	db $05, $03

SECTION "analyzed_010b70", ROMX[$4b70], BANK[$04]

Data_04_4b70:
	db $01, $50, $02, $03, $03, $10, $70, $4b, $01, $5a, $02, $03, $03, $10, $78, $4b
	db $01, $5b, $02, $04, $03, $01, $5c, $02, $04, $03, $01, $5b, $02, $04, $03, $01
	db $5d, $02, $04, $03, $10, $80, $4b, $01, $5e, $02, $03, $03, $01, $5f, $02, $03
	db $03, $01, $60, $02, $03, $03, $01, $61, $02, $03, $03, $10, $97, $4b, $01, $59
	db $02, $3c, $03, $10, $ae, $4b, $01, $53, $02, $3c, $03, $10, $b6, $4b, $01, $53
	db $02, $0a, $03, $01, $52, $02, $0a, $03, $01, $51, $02, $28, $03, $10, $c8, $4b
	db $01, $54, $02, $02, $03, $01, $55, $02, $02, $03, $01, $56, $02, $02, $03, $01
	db $55, $02, $02, $03, $01, $54, $02, $02, $03

Data_04_4be9:
	db $00, $41, $51, $4a, $51

Data_04_4bee:
	db $01, $02

SECTION "analyzed_010bf2", ROMX[$4bf2], BANK[$04]

Data_04_4bf2:
	db $41, $51, $4a, $51, $01, $02, $00

SECTION "analyzed_010bfa", ROMX[$4bfa], BANK[$04]

Data_04_4bfa:
	db $53, $51, $5c, $51, $01, $03, $00

SECTION "analyzed_010c02", ROMX[$4c02], BANK[$04]

Data_04_4c02:
	db $65, $51, $6e, $51, $01, $02, $00

SECTION "analyzed_010c0a", ROMX[$4c0a], BANK[$04]

Data_04_4c0a:
	db $77, $51, $80, $51, $01, $02, $00

SECTION "analyzed_010c12", ROMX[$4c12], BANK[$04]

Data_04_4c12:
	db $89, $51, $92, $51, $01, $02, $00

SECTION "analyzed_010c1a", ROMX[$4c1a], BANK[$04]

Data_04_4c1a:
	db $9b, $51, $a4, $51, $01, $02, $00

SECTION "analyzed_010c22", ROMX[$4c22], BANK[$04]

Data_04_4c22:
	db $ad, $51, $b6, $51, $01, $03, $00

SECTION "analyzed_010c2a", ROMX[$4c2a], BANK[$04]

Data_04_4c2a:
	db $bf, $51, $c8, $51, $01, $03, $00

SECTION "analyzed_010c32", ROMX[$4c32], BANK[$04]

Data_04_4c32:
	db $d1, $51, $da, $51, $01, $02, $00

SECTION "analyzed_010c3a", ROMX[$4c3a], BANK[$04]

Data_04_4c3a:
	db $e3, $51, $ec, $51, $01, $02, $00

SECTION "analyzed_010c42", ROMX[$4c42], BANK[$04]

Data_04_4c42:
	db $f5, $51, $fe, $51, $01, $02, $00

SECTION "analyzed_010c4a", ROMX[$4c4a], BANK[$04]

Data_04_4c4a:
	db $07, $52, $10, $52, $01, $03, $00

SECTION "analyzed_010c52", ROMX[$4c52], BANK[$04]

Data_04_4c52:
	db $19, $52, $22, $52, $01, $03, $00

SECTION "analyzed_010c5a", ROMX[$4c5a], BANK[$04]

Data_04_4c5a:
	db $2b, $52, $34, $52, $01, $03, $00

SECTION "analyzed_010c62", ROMX[$4c62], BANK[$04]

Data_04_4c62:
	db $3d, $52, $46, $52, $01, $02, $00

SECTION "analyzed_010c6a", ROMX[$4c6a], BANK[$04]

Data_04_4c6a:
	db $4f, $52, $58, $52, $01, $02, $00

SECTION "analyzed_010c72", ROMX[$4c72], BANK[$04]

Data_04_4c72:
	db $61, $52, $6a, $52, $01, $03, $00

SECTION "analyzed_010c7a", ROMX[$4c7a], BANK[$04]

Data_04_4c7a:
	db $73, $52, $7c, $52, $01, $03, $00

SECTION "analyzed_010c82", ROMX[$4c82], BANK[$04]

Data_04_4c82:
	db $85, $52, $8e, $52, $01, $00, $00

SECTION "analyzed_010c8a", ROMX[$4c8a], BANK[$04]

Data_04_4c8a:
	db $97, $52, $97, $52, $01, $00, $00

SECTION "analyzed_010c92", ROMX[$4c92], BANK[$04]

Data_04_4c92:
	db $a0, $52, $a0, $52, $01, $00, $00

SECTION "analyzed_010c9a", ROMX[$4c9a], BANK[$04]

Data_04_4c9a:
	db $a9, $52, $b2, $52, $01, $00, $00

SECTION "analyzed_010ca2", ROMX[$4ca2], BANK[$04]

Data_04_4ca2:
	db $bb, $52, $c4, $52, $01, $00, $00

Data_04_4ca9:
	db $00, $cd, $52, $d6, $52, $01, $02, $00, $00, $df, $52, $e8, $52, $01, $02, $00
	db $00, $00, $ba, $4c

Data_04_4cbd:
	db $e1, $4c, $e9, $4c, $f1, $4c, $08, $4d, $1f, $4d, $2c, $4d, $39, $4d, $4b, $4d
	db $5d, $4d, $65, $4d, $6d, $4d, $75, $4d

Data_04_4cd5:
	db $ba, $4c, $ba, $4c, $ba, $4c

Data_04_4cdb:
	db $7d, $4d, $ae, $4d, $b8, $4d, $01, $01, $02, $01, $03, $10, $e1, $4c, $01, $02
	db $02, $01, $03, $10, $e9, $4c, $01, $03, $02, $03, $03, $01, $04, $02, $03, $03
	db $01, $05, $02, $03, $03, $01, $06, $02, $03, $03, $10, $f1, $4c, $01, $02, $02
	db $0a, $03, $01, $07, $02, $0a, $03, $01, $02, $02, $0a, $03, $01, $08, $02, $0a
	db $03, $10, $08, $4d, $01, $0f, $02, $07, $03, $01, $10, $02, $07, $03

Data_04_4d29:
	db $10, $e1, $4c

Data_04_4d2c:
	db $01, $11, $02, $07, $03, $01, $12, $02, $07, $03

Data_04_4d36:
	db $10, $e9, $4c

Data_04_4d39:
	db $01, $09, $02, $05, $03, $01, $0a, $02, $05, $03, $01, $0b, $02, $0a, $03, $10
	db $e1, $4c, $01, $0c, $02, $05, $03, $01, $0d, $02, $05, $03, $01, $0e, $02, $0a
	db $03, $10, $e9, $4c, $01, $07, $02, $07, $03

Data_04_4d62:
	db $10, $5d, $4d

Data_04_4d65:
	db $01, $01, $02, $01, $03, $10, $65, $4d, $01, $04, $02, $01, $03, $10, $6d, $4d
	db $01, $07, $02, $05, $03

Data_04_4d7a:
	db $10, $5d, $4d

Data_04_4d7d:
	db $04, $0c, $01, $13, $02, $06, $03, $01, $14, $02, $06, $03, $07, $02, $01, $13
	db $02, $06, $03, $07, $02, $01, $15, $02, $06, $03, $01, $16, $02, $06, $03, $01
	db $17, $02, $06, $03, $01, $16, $02, $06, $03, $01, $17, $02, $06, $03, $10, $a6
	db $4d, $04, $0c, $01, $16, $02, $01, $03, $10, $b0, $4d, $01, $16, $02, $06, $03
	db $01, $17, $02, $06, $03, $01, $16, $02, $06, $03, $01, $17, $02, $06, $03, $10
	db $c7, $4d, $f1, $52, $fa, $52, $08, $09, $00

SECTION "analyzed_010dd7", ROMX[$4dd7], BANK[$04]

Data_04_4dd7:
	db $03, $53, $0c, $53, $08, $09, $00

SECTION "analyzed_010ddf", ROMX[$4ddf], BANK[$04]

Data_04_4ddf:
	db $15, $53

Data_04_4de1:
	db $15, $53

Data_04_4de3:
	db $00, $00, $00

SECTION "analyzed_010de7", ROMX[$4de7], BANK[$04]

Data_04_4de7:
	db $1e, $53

Data_04_4de9:
	db $1e, $53

Data_04_4deb:
	db $00, $00, $00

Data_04_4dee:
	db $00, $ba, $4c

Data_04_4df1:
	db $f5, $4d, $20, $4e, $01, $02, $02, $05, $03, $01, $03, $02, $05, $03, $01, $02
	db $02, $05, $03, $01, $03, $02, $05, $03, $01, $02, $02, $05, $03, $01, $03, $02
	db $05, $03, $01, $02, $02, $05, $03, $01, $03, $02, $05, $03

Data_04_4e1d:
	db $10, $f5, $4d

Data_04_4e20:
	db $01, $00, $02, $05, $03, $01, $01, $02, $05, $03, $10, $20, $4e

Data_04_4e2d:
	db $ba, $55, $26, $56

Data_04_4e31:
	db $00, $00

SECTION "analyzed_010e35", ROMX[$4e35], BANK[$04]

Data_04_4e35:
	db $ba, $4c

Data_04_4e37:
	db $3b, $4e, $43, $4e, $01, $00, $02, $01, $03, $10, $3b, $4e, $01, $00, $02, $01
	db $03, $10, $3b, $4e

Data_04_4e4b:
	db $e2, $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_010e53", ROMX[$4e53], BANK[$04]

Data_04_4e53:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_010e5b", ROMX[$4e5b], BANK[$04]

Data_04_4e5b:
	db $f4, $54, $60, $55, $0c, $0d, $00

SECTION "analyzed_010e63", ROMX[$4e63], BANK[$04]

Data_04_4e63:
	db $fd, $54, $69, $55, $0c, $0d, $00

SECTION "analyzed_010e6b", ROMX[$4e6b], BANK[$04]

Data_04_4e6b:
	db $06, $55, $72, $55, $0c, $0d, $00

SECTION "analyzed_010e73", ROMX[$4e73], BANK[$04]

Data_04_4e73:
	db $0f, $55, $7b, $55, $0c, $00, $00

SECTION "analyzed_010e7b", ROMX[$4e7b], BANK[$04]

Data_04_4e7b:
	db $18, $55, $84, $55, $0c, $00, $00

SECTION "analyzed_010e83", ROMX[$4e83], BANK[$04]

Data_04_4e83:
	db $ba, $4c

Data_04_4e85:
	db $97, $4e

Data_04_4e87:
	db $9f, $4e

Data_04_4e89:
	db $ba, $4c

Data_04_4e8b:
	db $b1, $4e

Data_04_4e8d:
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_4e95:
	db $be, $4e

Data_04_4e97:
	db $01, $00, $02, $01, $03, $10, $97, $4e

Data_04_4e9f:
	db $01, $00, $02, $05, $03, $01, $01, $02, $05, $03, $01, $02, $02, $05, $03, $10
	db $9f, $4e, $01, $03, $02, $02, $03, $01, $04, $02, $02, $03, $10, $b1, $4e, $01
	db $05, $02, $03, $03, $01, $06, $02, $03, $03, $01, $05, $02, $03, $03, $01, $06
	db $02, $03, $03, $09, $01, $06, $02, $02, $03, $08, $02, $02, $03, $10, $d2, $4e
	db $e2, $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_010ee7", ROMX[$4ee7], BANK[$04]

Data_04_4ee7:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_010eef", ROMX[$4eef], BANK[$04]

Data_04_4eef:
	db $f4, $54, $60, $55, $0c, $0d, $00

SECTION "analyzed_010ef7", ROMX[$4ef7], BANK[$04]

Data_04_4ef7:
	db $fd, $54, $69, $55, $0c, $0d, $00

SECTION "analyzed_010eff", ROMX[$4eff], BANK[$04]

Data_04_4eff:
	db $06, $55, $72, $55, $0c, $0d, $00

SECTION "analyzed_010f07", ROMX[$4f07], BANK[$04]

Data_04_4f07:
	db $0f, $55, $7b, $55, $0c, $0d, $00

SECTION "analyzed_010f0f", ROMX[$4f0f], BANK[$04]

Data_04_4f0f:
	db $18, $55, $84, $55, $0c, $0d, $00

SECTION "analyzed_010f17", ROMX[$4f17], BANK[$04]

Data_04_4f17:
	db $21, $55, $8d, $55, $0c, $00, $00

SECTION "analyzed_010f1f", ROMX[$4f1f], BANK[$04]

Data_04_4f1f:
	db $ba, $4c, $33, $4f, $3b, $4f, $48, $4f, $5a, $4f

Data_04_4f29:
	db $67, $4f, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_4f31:
	db $74, $4f, $01, $00, $02, $01, $03, $10, $33, $4f, $01, $00, $02, $05, $03, $01
	db $01, $02, $05, $03, $10, $3b, $4f, $01, $02, $02, $1e, $03, $01, $03, $02, $05
	db $03, $01, $04, $02, $05, $03

Data_04_4f57:
	db $10, $52, $4f

Data_04_4f5a:
	db $01, $05, $02, $02, $03, $01, $06, $02, $02, $03, $10, $5a, $4f

Data_04_4f67:
	db $01, $00, $02, $03, $03, $01, $01, $02, $03, $03, $10, $67, $4f

Data_04_4f74:
	db $01, $07, $02, $04, $03, $09, $01, $07, $02, $02, $03, $08, $02, $02, $03, $10
	db $79, $4f, $e2, $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_010f8e", ROMX[$4f8e], BANK[$04]

Data_04_4f8e:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_010f96", ROMX[$4f96], BANK[$04]

Data_04_4f96:
	db $f4, $54, $60, $55, $0c, $0d, $00

SECTION "analyzed_010f9e", ROMX[$4f9e], BANK[$04]

Data_04_4f9e:
	db $fd, $54, $69, $55, $0c, $0d, $00

SECTION "analyzed_010fa6", ROMX[$4fa6], BANK[$04]

Data_04_4fa6:
	db $06, $55, $72, $55, $0c, $0d, $00

SECTION "analyzed_010fae", ROMX[$4fae], BANK[$04]

Data_04_4fae:
	db $0f, $55, $7b, $55, $0c, $0d, $00

SECTION "analyzed_010fb6", ROMX[$4fb6], BANK[$04]

Data_04_4fb6:
	db $18, $55, $84, $55, $0c, $0d, $00

SECTION "analyzed_010fbe", ROMX[$4fbe], BANK[$04]

Data_04_4fbe:
	db $21, $55, $8d, $55, $0c, $00, $00

SECTION "analyzed_010fc6", ROMX[$4fc6], BANK[$04]

Data_04_4fc6:
	db $ba, $4c, $da, $4f, $e2, $4f, $f9, $4f, $06, $50

Data_04_4fd0:
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_4fd8:
	db $13, $50, $01, $00, $02, $01, $03, $10, $da, $4f, $01, $00, $02, $03, $03, $01
	db $01, $02, $03, $03, $01, $02, $02, $03, $03, $01, $01, $02, $03, $03, $10, $e2
	db $4f, $01, $03, $02, $1e, $03, $01, $04, $02, $09, $03

Data_04_5003:
	db $10, $fe, $4f

Data_04_5006:
	db $01, $05, $02, $02, $03, $01, $06, $02, $02, $03, $10, $06, $50, $01, $07, $02
	db $04, $03, $09, $01, $07, $02, $02, $03, $08, $02, $02, $03, $10, $18, $50, $e2
	db $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_01102d", ROMX[$502d], BANK[$04]

Data_04_502d:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_011035", ROMX[$5035], BANK[$04]

Data_04_5035:
	db $f4, $54, $60, $55, $0c, $0d, $00

SECTION "analyzed_01103d", ROMX[$503d], BANK[$04]

Data_04_503d:
	db $fd, $54, $69, $55, $0c, $0d, $00

SECTION "analyzed_011045", ROMX[$5045], BANK[$04]

Data_04_5045:
	db $06, $55, $72, $55, $0c, $0d, $00

SECTION "analyzed_01104d", ROMX[$504d], BANK[$04]

Data_04_504d:
	db $0f, $55, $7b, $55, $0c, $0d, $00

SECTION "analyzed_011055", ROMX[$5055], BANK[$04]

Data_04_5055:
	db $18, $55, $84, $55, $0c, $0d, $00

SECTION "analyzed_01105d", ROMX[$505d], BANK[$04]

Data_04_505d:
	db $21, $55, $8d, $55, $0c, $00, $00

Data_04_5064:
	db $00, $ba, $4c

Data_04_5067:
	db $79, $50, $81, $50, $98, $50, $ac, $50

Data_04_506f:
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_5077:
	db $b9, $50, $01, $00, $02, $01, $03, $10, $79, $50, $01, $00, $02, $05, $03, $01
	db $01, $02, $05, $03, $01, $02, $02, $05, $03, $01, $01, $02, $05, $03, $10, $81
	db $50, $01, $03, $02, $1e, $03, $04, $0f, $01, $04, $02, $28, $03, $01, $03, $02
	db $05, $03

Data_04_50a9:
	db $10, $79, $50

Data_04_50ac:
	db $01, $05, $02, $03, $03, $01, $06, $02, $03, $03, $10, $ac, $50, $01, $07, $02
	db $04, $03, $09, $01, $07, $02, $02, $03, $08, $02, $02, $03, $10, $be, $50, $e2
	db $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_0110d3", ROMX[$50d3], BANK[$04]

Data_04_50d3:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_0110db", ROMX[$50db], BANK[$04]

Data_04_50db:
	db $f4, $54, $60, $55, $0c, $0d, $00

SECTION "analyzed_0110e3", ROMX[$50e3], BANK[$04]

Data_04_50e3:
	db $fd, $54, $69, $55, $0c, $0d, $00

SECTION "analyzed_0110eb", ROMX[$50eb], BANK[$04]

Data_04_50eb:
	db $06, $55, $72, $55, $0c, $0d, $00

SECTION "analyzed_0110f3", ROMX[$50f3], BANK[$04]

Data_04_50f3:
	db $0f, $55, $7b, $55, $0c, $0d, $00

SECTION "analyzed_0110fb", ROMX[$50fb], BANK[$04]

Data_04_50fb:
	db $18, $55, $84, $55, $0c, $00, $00

SECTION "analyzed_011103", ROMX[$5103], BANK[$04]

Data_04_5103:
	db $21, $55, $8d, $55, $0c, $00, $00

Data_04_510a:
	db $00, $ba, $4c

Data_04_510d:
	db $1f, $51, $27, $51, $34, $51, $41, $51

Data_04_5115:
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_511d:
	db $4e, $51, $01, $00, $02, $01, $03, $10, $1f, $51, $01, $00, $02, $03, $03, $01
	db $01, $02, $03, $03, $10, $27, $51, $01, $02, $02, $3c, $03, $01, $03, $02, $05
	db $03

Data_04_513e:
	db $10, $1f, $51

Data_04_5141:
	db $01, $04, $02, $02, $03, $01, $05, $02, $02, $03, $10, $41, $51, $01, $06, $02
	db $03, $03, $01, $07, $02, $03, $03, $09, $01, $07, $02, $02, $03, $08, $02, $02
	db $03, $10, $58, $51, $ba, $55, $26, $56, $0e, $0f, $00

SECTION "analyzed_01116d", ROMX[$516d], BANK[$04]

Data_04_516d:
	db $c3, $55, $2f, $56, $0e, $0f, $00

Data_04_5174:
	db $00, $cc, $55, $38, $56, $0e, $0f, $00, $00

Data_04_517d:
	db $d5, $55, $41, $56, $0e, $0f, $00

SECTION "analyzed_011185", ROMX[$5185], BANK[$04]

Data_04_5185:
	db $de, $55, $4a, $56, $0e, $0f, $00

SECTION "analyzed_01118d", ROMX[$518d], BANK[$04]

Data_04_518d:
	db $e7, $55, $53, $56, $0e, $00, $00

Data_04_5194:
	db $00, $ba, $4c

Data_04_5197:
	db $a9, $51, $b1, $51

Data_04_519b:
	db $be, $51

Data_04_519d:
	db $cb, $51

Data_04_519f:
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_51a7:
	db $d3, $51, $01, $00, $02, $01, $03, $10, $a9, $51, $01, $00, $02, $05, $03, $01
	db $01, $02, $05, $03, $10, $b1, $51

Data_04_51be:
	db $01, $01, $02, $21, $03, $01, $02, $02, $09, $03, $10, $a9, $51

Data_04_51cb:
	db $01, $03, $02, $01, $03, $10, $cb, $51, $01, $04, $02, $02, $03, $01, $05, $02
	db $02, $03, $09, $01, $05, $02, $02, $03, $08, $02, $02, $03, $10, $dd, $51, $ba
	db $55, $26, $56, $0e, $0f, $00

SECTION "analyzed_0111f2", ROMX[$51f2], BANK[$04]

Data_04_51f2:
	db $c3, $55, $2f, $56, $0e, $0f, $00

SECTION "analyzed_0111fa", ROMX[$51fa], BANK[$04]

Data_04_51fa:
	db $cc, $55, $38, $56, $0e, $0f, $00

SECTION "analyzed_011202", ROMX[$5202], BANK[$04]

Data_04_5202:
	db $d5, $55, $41, $56, $0e, $0f, $00

SECTION "analyzed_01120a", ROMX[$520a], BANK[$04]

Data_04_520a:
	db $de, $55, $4a, $56, $0e, $0f, $00

SECTION "analyzed_011212", ROMX[$5212], BANK[$04]

Data_04_5212:
	db $e7, $55, $53, $56, $0e, $0f, $00

SECTION "analyzed_01121a", ROMX[$521a], BANK[$04]

Data_04_521a:
	db $f0, $55, $5c, $56, $0e, $0f, $00

SECTION "analyzed_011222", ROMX[$5222], BANK[$04]

Data_04_5222:
	db $f9, $55, $65, $56, $0e, $00, $00

Data_04_5229:
	db $00, $ba, $4c

Data_04_522c:
	db $3e, $52, $46, $52, $5d, $52, $6a, $52

Data_04_5234:
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_523c:
	db $77, $52, $01, $00, $02, $01, $03, $10, $3e, $52, $01, $00, $02, $03, $03, $01
	db $01, $02, $03, $03, $01, $02, $02, $03, $03, $01, $01, $02, $03, $03, $10, $46
	db $52, $01, $03, $02, $03, $03, $01, $04, $02, $09, $03

Data_04_5267:
	db $10, $3e, $52

Data_04_526a:
	db $01, $05, $02, $03, $03, $01, $06, $02, $03, $03, $10, $6f, $52, $01, $07, $02
	db $04, $03, $09, $01, $07, $02, $02, $03, $08, $02, $02, $03, $10, $7c, $52, $ba
	db $55, $26, $56, $0e, $0f, $00

SECTION "analyzed_011291", ROMX[$5291], BANK[$04]

Data_04_5291:
	db $c3, $55, $2f, $56, $0e, $0f, $00

SECTION "analyzed_011299", ROMX[$5299], BANK[$04]

Data_04_5299:
	db $cc, $55, $38, $56, $0e, $0f, $00

SECTION "analyzed_0112a1", ROMX[$52a1], BANK[$04]

Data_04_52a1:
	db $d5, $55, $41, $56, $0e, $0f, $00

SECTION "analyzed_0112a9", ROMX[$52a9], BANK[$04]

Data_04_52a9:
	db $de, $55, $4a, $56, $0e, $0f, $00

SECTION "analyzed_0112b1", ROMX[$52b1], BANK[$04]

Data_04_52b1:
	db $e7, $55, $53, $56, $0e, $0f, $00

SECTION "analyzed_0112b9", ROMX[$52b9], BANK[$04]

Data_04_52b9:
	db $f0, $55, $5c, $56, $0e, $00, $00

Data_04_52c0:
	db $00, $ba, $4c

Data_04_52c3:
	db $d5, $52, $dd, $52, $ea, $52, $f7, $52, $04, $53

Data_04_52cd:
	db $ba, $4c, $ba, $4c, $ba, $4c

Data_04_52d3:
	db $11, $53, $01, $00, $02, $01, $03, $10, $d5, $52, $01, $00, $02, $03, $03, $01
	db $01, $02, $03, $03, $10, $dd, $52, $01, $01, $02, $09, $03, $01, $02, $02, $03
	db $03

Data_04_52f4:
	db $10, $ef, $52

Data_04_52f7:
	db $01, $04, $02, $02, $03, $01, $05, $02, $02, $03, $10, $f7, $52, $01, $01, $02
	db $09, $03, $01, $03, $02, $03, $03

Data_04_530e:
	db $10, $09, $53

Data_04_5311:
	db $01, $06, $02, $04, $03, $09, $01, $06, $02, $02, $03, $08, $02, $02, $03, $10
	db $16, $53, $e2, $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_01132b", ROMX[$532b], BANK[$04]

Data_04_532b:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_011333", ROMX[$5333], BANK[$04]

Data_04_5333:
	db $f4, $54, $60, $55, $0c, $0d, $00

SECTION "analyzed_01133b", ROMX[$533b], BANK[$04]

Data_04_533b:
	db $fd, $54, $69, $55, $0c, $0d, $00

SECTION "analyzed_011343", ROMX[$5343], BANK[$04]

Data_04_5343:
	db $06, $55, $72, $55, $0c, $0d, $00

SECTION "analyzed_01134b", ROMX[$534b], BANK[$04]

Data_04_534b:
	db $0f, $55, $7b, $55, $0c, $0d, $00

SECTION "analyzed_011353", ROMX[$5353], BANK[$04]

Data_04_5353:
	db $18, $55, $84, $55, $0c, $0d, $00

SECTION "analyzed_01135b", ROMX[$535b], BANK[$04]

Data_04_535b:
	db $21, $55, $8d, $55, $0c, $00, $00

SECTION "analyzed_011363", ROMX[$5363], BANK[$04]

Data_04_5363:
	db $6a, $57, $7c, $57, $0c, $0d, $00

SECTION "analyzed_01136b", ROMX[$536b], BANK[$04]

Data_04_536b:
	db $73, $57, $85, $57, $0c, $0d, $00

Data_04_5372:
	db $00, $ba, $4c

Data_04_5375:
	db $87, $53, $8f, $53, $a6, $53, $bd, $53, $d4, $53

Data_04_537f:
	db $ba, $4c, $ba, $4c, $ba, $4c

Data_04_5385:
	db $eb, $53, $01, $00, $02, $01, $03, $10, $87, $53, $01, $00, $02, $03, $03, $01
	db $01, $02, $03, $03, $01, $00, $02, $03, $03, $01, $02, $02, $03, $03, $10, $8f
	db $53, $01, $03, $02, $03, $03, $01, $04, $02, $03, $03, $01, $05, $02, $03, $03
	db $01, $06, $02, $03, $03, $10, $b5, $53, $01, $00, $02, $02, $03, $01, $01, $02
	db $02, $03, $01, $00, $02, $02, $03, $01, $02, $02, $02, $03, $10, $bd, $53, $01
	db $06, $02, $02, $03, $01, $07, $02, $02, $03, $01, $08, $02, $02, $03, $01, $09
	db $02, $02, $03, $10, $d4, $53, $01, $07, $02, $03, $03, $09, $01, $07, $02, $02
	db $03, $08, $02, $02, $03, $10, $f0, $53, $8e, $57, $8e, $57, $13, $14, $00

SECTION "analyzed_011405", ROMX[$5405], BANK[$04]

Data_04_5405:
	db $97, $57, $97, $57, $13, $14, $00

SECTION "analyzed_01140d", ROMX[$540d], BANK[$04]

Data_04_540d:
	db $a0, $57, $a0, $57, $13, $14, $00

SECTION "analyzed_011415", ROMX[$5415], BANK[$04]

Data_04_5415:
	db $a9, $57, $a9, $57, $13, $14, $00

SECTION "analyzed_01141d", ROMX[$541d], BANK[$04]

Data_04_541d:
	db $b2, $57, $b2, $57, $13, $14, $00

SECTION "analyzed_011425", ROMX[$5425], BANK[$04]

Data_04_5425:
	db $bb, $57, $bb, $57, $13, $14, $00

SECTION "analyzed_01142d", ROMX[$542d], BANK[$04]

Data_04_542d:
	db $c4, $57, $c4, $57, $13, $14, $00

SECTION "analyzed_011435", ROMX[$5435], BANK[$04]

Data_04_5435:
	db $cd, $57, $cd, $57, $13, $14, $00

Data_04_543c:
	db $00, $cd, $57, $cd, $57, $13, $14, $00, $00, $cd, $57, $cd, $57, $13, $14, $00
	db $00

Data_04_544d:
	db $d6, $57, $d6, $57, $13, $14, $00

SECTION "analyzed_011455", ROMX[$5455], BANK[$04]

Data_04_5455:
	db $df, $57, $df, $57, $13, $14, $00

SECTION "analyzed_01145d", ROMX[$545d], BANK[$04]

Data_04_545d:
	db $e8, $57, $e8, $57, $13, $14, $00

SECTION "analyzed_011465", ROMX[$5465], BANK[$04]

Data_04_5465:
	db $f1, $57, $f1, $57, $13, $14, $00

SECTION "analyzed_01146d", ROMX[$546d], BANK[$04]

Data_04_546d:
	db $fa, $57, $fa, $57, $13, $14, $00

SECTION "analyzed_011475", ROMX[$5475], BANK[$04]

Data_04_5475:
	db $03, $58, $03, $58, $13, $14, $00

SECTION "analyzed_01147d", ROMX[$547d], BANK[$04]

Data_04_547d:
	db $0c, $58, $0c, $58, $13, $14, $00

SECTION "analyzed_011485", ROMX[$5485], BANK[$04]

Data_04_5485:
	db $15, $58, $15, $58, $13, $14, $00

Data_04_548c:
	db $00, $15, $58, $15, $58, $13, $14, $00, $00, $15, $58, $15, $58, $13, $14, $00
	db $00, $ba, $4c

Data_04_549f:
	db $37, $55, $44, $55, $51, $55, $5e, $55, $6b, $55, $78, $55, $85, $55, $92, $55

SECTION "analyzed_0114bf", ROMX[$54bf], BANK[$04]

Data_04_54bf:
	db $cf, $54, $dc, $54, $e9, $54, $f6, $54, $03, $55, $10, $55, $1d, $55, $2a, $55
	db $01, $00, $02, $03, $03, $01, $01, $02, $03, $03, $10, $cf, $54, $01, $0a, $02
	db $03, $03, $01, $0b, $02, $03, $03, $10, $dc, $54, $01, $0e, $02, $03, $03, $01
	db $0f, $02, $03, $03, $10, $e9, $54, $01, $04, $02, $03, $03, $01, $05, $02, $03
	db $03, $10, $f6, $54, $01, $06, $02, $03, $03, $01, $07, $02, $03, $03, $10, $03
	db $55, $01, $0c, $02, $03, $03, $01, $0d, $02, $03, $03, $10, $10, $55, $01, $10
	db $02, $03, $03, $01, $11, $02, $03, $03, $10, $1d, $55, $01, $02, $02, $03, $03
	db $01, $03, $02, $03, $03, $10, $2a, $55, $09, $01, $00, $02, $02, $03, $08, $02
	db $02, $03, $10, $37, $55, $09, $01, $0a, $02, $02, $03, $08, $02, $02, $03, $10
	db $44, $55, $09, $01, $0e, $02, $02, $03, $08, $02, $02, $03, $10, $51, $55, $09
	db $01, $04, $02, $02, $03, $08, $02, $02, $03, $10, $5e, $55, $09, $01, $06, $02
	db $02, $03, $08, $02, $02, $03, $10, $6b, $55, $09, $01, $0c, $02, $02, $03, $08
	db $02, $02, $03, $10, $78, $55, $09, $01, $10, $02, $02, $03, $08, $02, $02, $03
	db $10, $85, $55, $09, $01, $02, $02, $03, $03, $08, $02, $02, $03, $10, $92, $55
	db $92, $56, $fe, $56, $0e, $0f, $00

SECTION "analyzed_0115a7", ROMX[$55a7], BANK[$04]

Data_04_55a7:
	db $9b, $56, $07, $57, $0e, $0f, $00

SECTION "analyzed_0115af", ROMX[$55af], BANK[$04]

Data_04_55af:
	db $a4, $56, $10, $57, $0e, $0f, $00

SECTION "analyzed_0115b7", ROMX[$55b7], BANK[$04]

Data_04_55b7:
	db $ad, $56, $19, $57, $0e, $00, $00

Data_04_55be:
	db $00, $b6, $56

Data_04_55c1:
	db $22, $57, $0e, $0f, $00

Data_04_55c6:
	db $00, $bf, $56, $2b, $57, $0e, $0f, $00, $00, $c8, $56, $34, $57, $0e, $0f, $00
	db $00, $d1, $56

Data_04_55d9:
	db $3d, $57, $0e, $00, $00

Data_04_55de:
	db $00, $ba, $4c

Data_04_55e1:
	db $f3, $55, $fb, $55, $03, $56

Data_04_55e7:
	db $10, $56, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_55ef:
	db $1d, $56, $2f, $56, $01, $00, $02, $03, $03, $10, $f3, $55, $01, $04, $02, $03
	db $03, $10, $fb, $55, $01, $01, $02, $1e, $03, $01, $02, $02, $03, $03

Data_04_560d:
	db $10, $f3, $55, $01, $05, $02, $1e, $03, $01, $06, $02, $03, $03, $10, $fb, $55

Data_04_561d:
	db $01, $03, $02, $03, $03, $09, $01, $03, $02, $02, $03, $08, $02, $02, $03, $10
	db $22, $56, $01, $07, $02, $03, $03, $09, $01, $07, $02, $02, $03, $08, $02, $02
	db $03, $10, $34, $56, $e2, $54, $4e, $55, $10, $11, $00

SECTION "analyzed_011649", ROMX[$5649], BANK[$04]

Data_04_5649:
	db $eb, $54, $57, $55, $10, $11, $00

SECTION "analyzed_011651", ROMX[$5651], BANK[$04]

Data_04_5651:
	db $f4, $54, $60, $55, $10, $12, $00

SECTION "analyzed_011659", ROMX[$5659], BANK[$04]

Data_04_5659:
	db $fd, $54, $69, $55, $10, $12, $00

SECTION "analyzed_011661", ROMX[$5661], BANK[$04]

Data_04_5661:
	db $06, $55, $72, $55, $10, $00, $00

SECTION "analyzed_011669", ROMX[$5669], BANK[$04]

Data_04_5669:
	db $0f, $55, $7b, $55, $10, $00, $00

SECTION "analyzed_011671", ROMX[$5671], BANK[$04]

Data_04_5671:
	db $18, $55, $84, $55, $10, $00, $00

Data_04_5678:
	db $00, $ba, $4c

Data_04_567b:
	db $8d, $56, $a8, $56

Data_04_567f:
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_568b:
	db $c3, $56, $01, $00, $02, $03, $03, $01, $01, $02, $03, $03, $07, $02, $01, $00
	db $02, $03, $03, $01, $01, $02, $03, $03, $07, $02, $10, $8d, $56, $01, $02, $02
	db $03, $03, $01, $03, $02, $03, $03, $07, $02, $01, $02, $02, $03, $03, $01, $03
	db $02, $03, $03, $07, $02, $10, $a8, $56, $09, $01, $04, $02, $03, $03, $01, $05
	db $02, $03, $03, $01, $06, $02, $03, $03, $09, $01, $06, $02, $02, $03, $08, $02
	db $02, $03, $10, $d3, $56, $e2, $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_0116e8", ROMX[$56e8], BANK[$04]

Data_04_56e8:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_0116f0", ROMX[$56f0], BANK[$04]

Data_04_56f0:
	db $f4, $54, $60, $55, $0c, $0d, $00

Data_04_56f7:
	db $00, $fd, $54, $69, $55, $0c, $0d, $00, $00, $06, $55, $72, $55, $0c, $0d, $00
	db $00, $0f, $55, $7b, $55, $0c, $0d, $00, $00, $18, $55, $84, $55, $0c, $0d, $00
	db $00, $21, $55, $8d, $55, $0c, $0d, $00, $00, $ba, $4c

Data_04_5722:
	db $34, $57, $3c, $57

Data_04_5726:
	db $53, $57, $60, $57, $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c, $6d, $57

Data_04_5734:
	db $01, $00, $02, $01, $03, $10, $34, $57, $01, $00, $02, $03, $03, $01, $01, $02
	db $03, $03, $01, $00, $02, $03, $03, $01, $02, $02, $03, $03, $10, $3c, $57

Data_04_5753:
	db $01, $03, $02, $1e, $03, $01, $04, $02, $05, $03, $10, $34, $57, $01, $05, $02
	db $02, $03, $01, $06, $02, $02, $03, $10, $60, $57, $01, $07, $02, $02, $03, $10
	db $6d, $57

Data_04_5775:
	db $e2, $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_01177d", ROMX[$577d], BANK[$04]

Data_04_577d:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_011785", ROMX[$5785], BANK[$04]

Data_04_5785:
	db $f4, $54, $60, $55, $0c, $0d, $00

Data_04_578c:
	db $00, $fd, $54

Data_04_578f:
	db $69, $55, $0c, $0d, $00

Data_04_5794:
	db $00, $06, $55

Data_04_5797:
	db $72, $55, $0c, $0d, $00

Data_04_579c:
	db $00, $0f, $55, $7b, $55, $0c, $0d, $00, $00, $18, $55, $84, $55, $0c, $0d, $00
	db $00, $21, $55, $8d, $55, $0c, $0d, $00, $00, $ba, $4c

Data_04_57b7:
	db $c9, $57, $d1, $57, $e8, $57, $f5, $57

Data_04_57bf:
	db $0c, $58, $ba, $4c, $ba, $4c, $ba, $4c, $1e, $58

Data_04_57c9:
	db $01, $00, $02, $01, $03, $10, $c9, $57, $01, $00, $02, $03, $03, $01, $01, $02
	db $03, $03, $01, $00, $02, $03, $03, $01, $02, $02, $03, $03, $10, $d1, $57, $01
	db $03, $02, $03, $03, $01, $04, $02, $03, $03, $10, $ed, $57, $01, $00, $02, $02
	db $03, $01, $01, $02, $02, $03, $01, $00, $02, $02, $03, $01, $02, $02, $02, $03
	db $10, $f5, $57

Data_04_580c:
	db $01, $04, $02, $02, $03, $01, $05, $02, $02, $03, $01, $06, $02, $02, $03, $10
	db $0c, $58, $01, $07, $02, $03, $03, $10, $1e, $58

Data_04_5826:
	db $e2, $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_01182e", ROMX[$582e], BANK[$04]

Data_04_582e:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_011836", ROMX[$5836], BANK[$04]

Data_04_5836:
	db $f4, $54, $60, $55, $0c, $0d, $00

SECTION "analyzed_01183e", ROMX[$583e], BANK[$04]

Data_04_583e:
	db $fd, $54, $69, $55, $0c, $0d, $00

SECTION "analyzed_011846", ROMX[$5846], BANK[$04]

Data_04_5846:
	db $06, $55, $72, $55, $0c, $0d, $00

SECTION "analyzed_01184e", ROMX[$584e], BANK[$04]

Data_04_584e:
	db $0f, $55

Data_04_5850:
	db $7b, $55

Data_04_5852:
	db $0c, $0d, $00

SECTION "analyzed_011856", ROMX[$5856], BANK[$04]

Data_04_5856:
	db $18, $55

Data_04_5858:
	db $84, $55

Data_04_585a:
	db $0c, $0d, $00

SECTION "analyzed_01185e", ROMX[$585e], BANK[$04]

Data_04_585e:
	db $21, $55

Data_04_5860:
	db $8d, $55

Data_04_5862:
	db $0c, $0d, $00

Data_04_5865:
	db $00, $ba, $4c

Data_04_5868:
	db $7a, $58, $82, $58, $99, $58, $a6, $58

Data_04_5870:
	db $b3, $58, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_5878:
	db $ca, $58, $01, $00, $02, $01, $03, $10, $7a, $58, $01, $00, $02, $03, $03, $01
	db $01, $02, $03, $03, $01, $00, $02, $03, $03, $01, $02, $02, $03, $03, $10, $82
	db $58, $01, $03, $02, $1e, $03, $01, $04, $02, $05, $03

Data_04_58a3:
	db $10, $9e, $58

Data_04_58a6:
	db $01, $05, $02, $02, $03, $01, $06, $02, $02, $03, $10, $a6, $58

Data_04_58b3:
	db $01, $00, $02, $02, $03, $01, $01, $02, $02, $03, $01, $00, $02, $02, $03, $01
	db $02, $02, $02, $03, $10, $b3, $58

Data_04_58ca:
	db $01, $07, $02, $02, $03, $10, $ca, $58, $ba, $55, $26, $56, $0e, $0f, $00

SECTION "analyzed_0118da", ROMX[$58da], BANK[$04]

Data_04_58da:
	db $c3, $55, $2f, $56, $0e, $0f, $00

Data_04_58e1:
	db $00, $cc, $55, $38, $56, $0e, $0f, $00, $00

Data_04_58ea:
	db $d5, $55, $41, $56, $0e, $0f, $00

SECTION "analyzed_0118f2", ROMX[$58f2], BANK[$04]

Data_04_58f2:
	db $de, $55, $4a, $56, $0e, $0f, $00

Data_04_58f9:
	db $00, $e7, $55, $53, $56, $0e, $0f, $00, $00, $f0, $55, $5c, $56, $0e, $0f, $00
	db $00, $f9, $55, $65, $56, $0e, $0f, $00, $00, $ba, $4c

Data_04_5914:
	db $26, $59, $2e, $59, $3b, $59

Data_04_591a:
	db $48, $59, $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c, $55, $59

Data_04_5926:
	db $01, $00, $02, $01, $03, $10, $26, $59, $01, $00, $02, $05, $03, $01, $01, $02
	db $05, $03, $10, $2e, $59, $01, $03, $02, $03, $03, $01, $04, $02, $03, $03, $10
	db $3b, $59

Data_04_5948:
	db $01, $05, $02, $02, $03, $01, $06, $02, $02, $03, $10, $48, $59, $01, $07, $02
	db $02, $03, $10, $55, $59

Data_04_595d:
	db $e2, $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_011965", ROMX[$5965], BANK[$04]

Data_04_5965:
	db $eb, $54, $57, $55, $0c, $0d, $00

Data_04_596c:
	db $00, $f4, $54, $60, $55, $0c, $0d, $00, $00, $fd, $54, $69, $55, $0c, $0d, $00
	db $00, $06, $55, $72, $55, $0c, $0d, $00, $00, $0f, $55, $7b, $55, $0c, $0d, $00
	db $00, $18, $55, $84, $55, $0c, $0d, $00, $00, $ba, $4c

Data_04_5997:
	db $a9, $59, $b1, $59

Data_04_599b:
	db $c8, $59, $df, $59, $e7, $59, $ba, $4c, $ba, $4c, $ba, $4c, $fe, $59

Data_04_59a9:
	db $01, $00, $02, $01, $03, $10, $a9, $59, $01, $00, $02, $08, $03, $01, $01, $02
	db $08, $03

Data_04_59bb:
	db $01, $00, $02, $08, $03, $01, $02, $02, $08, $03, $10, $b1, $59, $01, $00, $02
	db $03, $03, $01, $03, $02, $1b, $03, $01, $04, $02, $04, $03, $01, $02, $02, $04
	db $03, $10, $d7, $59, $01, $05, $02, $03, $03, $10, $df, $59, $01, $00, $02, $04
	db $03, $01, $01, $02, $04, $03, $01, $00, $02, $04, $03, $01, $02, $02, $04, $03
	db $10, $e7, $59, $01, $06, $02, $02, $03, $10, $fe, $59

Data_04_5a06:
	db $e2, $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_011a0e", ROMX[$5a0e], BANK[$04]

Data_04_5a0e:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_011a16", ROMX[$5a16], BANK[$04]

Data_04_5a16:
	db $f4, $54, $60, $55, $0c, $0d, $00

SECTION "analyzed_011a1e", ROMX[$5a1e], BANK[$04]

Data_04_5a1e:
	db $fd, $54, $69, $55, $0c, $0d, $00

SECTION "analyzed_011a26", ROMX[$5a26], BANK[$04]

Data_04_5a26:
	db $06, $55, $72, $55, $0c, $0d, $00

Data_04_5a2d:
	db $00, $0f, $55, $7b, $55, $0c, $0d, $00, $00, $18, $55, $84, $55, $0c, $0d, $00
	db $00, $21, $55, $8d, $55, $0c, $0d, $00, $00, $ba, $4c

Data_04_5a48:
	db $5a, $5a, $62, $5a, $74, $5a

Data_04_5a4e:
	db $86, $5a, $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c, $93, $5a

Data_04_5a5a:
	db $01, $00, $02, $01, $03, $10, $5a, $5a, $01, $00, $02, $05, $03, $01, $01, $02
	db $05, $03, $01, $02, $02, $05, $03, $10, $62, $5a, $01, $03, $02, $1e, $03, $01
	db $04, $02, $28, $03, $01, $03, $02, $05, $03

Data_04_5a83:
	db $10, $5a, $5a, $01, $05, $02, $03, $03, $01, $06, $02, $03, $03, $10, $86, $5a
	db $01, $07, $02, $03, $03, $10, $93, $5a

Data_04_5a9b:
	db $1e, $58, $1e, $58, $20, $21, $00

SECTION "analyzed_011aa3", ROMX[$5aa3], BANK[$04]

Data_04_5aa3:
	db $4f, $58, $4f, $58, $20, $21, $00

SECTION "analyzed_011aab", ROMX[$5aab], BANK[$04]

Data_04_5aab:
	db $80, $58, $13, $59, $20, $21, $00

SECTION "analyzed_011ab3", ROMX[$5ab3], BANK[$04]

Data_04_5ab3:
	db $b1, $58, $b1, $58, $20, $21, $00

SECTION "analyzed_011abb", ROMX[$5abb], BANK[$04]

Data_04_5abb:
	db $e2, $58, $e2, $58, $20, $21, $00

SECTION "analyzed_011ac3", ROMX[$5ac3], BANK[$04]

Data_04_5ac3:
	db $13, $59, $80, $58, $20, $21, $00

SECTION "analyzed_011acb", ROMX[$5acb], BANK[$04]

Data_04_5acb:
	db $44, $59, $75, $59, $20, $21, $00

SECTION "analyzed_011ad3", ROMX[$5ad3], BANK[$04]

Data_04_5ad3:
	db $a6, $59, $d7, $59, $20, $21, $00

SECTION "analyzed_011adb", ROMX[$5adb], BANK[$04]

Data_04_5adb:
	db $08, $5a, $08, $5a, $20, $00, $00

SECTION "analyzed_011ae3", ROMX[$5ae3], BANK[$04]

Data_04_5ae3:
	db $39, $5a, $39, $5a, $20, $00, $00

Data_04_5aea:
	db $00, $1e, $58, $1e, $58, $20, $00, $00, $00

Data_04_5af3:
	db $4f, $58, $4f, $58, $20, $00, $00

SECTION "analyzed_011afb", ROMX[$5afb], BANK[$04]

Data_04_5afb:
	db $80, $58, $13, $59, $20, $00, $00

SECTION "analyzed_011b03", ROMX[$5b03], BANK[$04]

Data_04_5b03:
	db $b1, $58, $b1, $58, $20, $00, $00

Data_04_5b0a:
	db $00, $e2, $58, $e2, $58, $20, $00, $00, $00, $13, $59, $80, $58, $20, $00, $00
	db $00

Data_04_5b1b:
	db $44, $59, $75, $59, $20, $00, $00

Data_04_5b22:
	db $00, $a6, $59, $d7, $59, $20, $00, $00, $00, $ba, $4c

Data_04_5b2d:
	db $3f, $5b, $47, $5b, $77, $5b, $8b, $5b

Data_04_5b35:
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_5b3d:
	db $c7, $5b, $01, $00, $02, $01, $03, $10, $3f, $5b, $01, $00, $02, $0a, $03, $01
	db $01, $02, $0a, $03, $01, $02, $02, $0a, $03, $01, $03, $02, $0a, $03, $01, $04
	db $02, $0a, $03, $01, $03, $02, $0a, $03, $01, $05, $02, $0a, $03, $01, $01, $02
	db $0a, $03, $01, $00, $02, $0a, $03

Data_04_5b74:
	db $10, $3f, $5b

Data_04_5b77:
	db $01, $01, $02, $0a, $03, $01, $06, $02, $0a, $03, $04, $1f, $01, $07, $02, $1e
	db $03

Data_04_5b88:
	db $10, $3f, $5b

Data_04_5b8b:
	db $01, $0b, $02, $07, $03, $01, $0d, $02, $07, $03, $01, $0c, $02, $07, $03, $01
	db $10, $02, $07, $03, $01, $0c, $02, $0e, $03, $01, $0b, $02, $07, $03, $01, $0d
	db $02, $07, $03, $01, $0c, $02, $07, $03, $01, $10, $02, $07, $03, $01, $0c, $02
	db $0e, $03, $04, $13, $01, $08, $02, $0a, $03, $10, $bf, $5b, $01, $09, $02, $04
	db $03, $09, $01, $09, $02, $02, $03, $08, $02, $02, $03, $10, $cc, $5b, $9b, $5a
	db $c4, $5a, $22, $23, $00

SECTION "analyzed_011be1", ROMX[$5be1], BANK[$04]

Data_04_5be1:
	db $ed, $5a, $16, $5b, $22, $23, $00

SECTION "analyzed_011be9", ROMX[$5be9], BANK[$04]

Data_04_5be9:
	db $3f, $5b, $68, $5b, $22, $23, $00

SECTION "analyzed_011bf1", ROMX[$5bf1], BANK[$04]

Data_04_5bf1:
	db $91, $5b, $ba, $5b, $22, $23, $00

Data_04_5bf8:
	db $00, $e3, $5b, $0c, $5c, $22, $23, $00, $00

Data_04_5c01:
	db $35, $5c, $5e, $5c, $22, $23, $00

SECTION "analyzed_011c09", ROMX[$5c09], BANK[$04]

Data_04_5c09:
	db $87, $5c, $b0, $5c, $22, $23, $00

SECTION "analyzed_011c11", ROMX[$5c11], BANK[$04]

Data_04_5c11:
	db $d9, $5c, $02, $5d, $22, $23, $00

Data_04_5c18:
	db $00, $2b, $5d

Data_04_5c1b:
	db $54, $5d, $22, $00, $00

Data_04_5c20:
	db $00, $ba, $4c, $35, $5c

Data_04_5c25:
	db $3d, $5c, $63, $5c, $77, $5c, $8e, $5c, $ac, $5c

Data_04_5c2f:
	db $ba, $4c, $ba, $4c

Data_04_5c33:
	db $b9, $5c

Data_04_5c35:
	db $01, $00, $02, $01, $03, $10, $35, $5c

Data_04_5c3d:
	db $01, $00, $02, $0a, $03, $01, $02, $02, $0a, $03, $01, $03, $02, $0a, $03, $01
	db $00, $02, $0a, $03, $01, $01, $02, $0a, $03, $01, $02, $02, $0a, $03, $01, $03
	db $02, $0a, $03, $10, $3d, $5c, $01, $00, $02, $0a, $03, $01, $05, $02, $0a, $03
	db $04, $19, $01, $06, $02, $01, $03, $10, $6f, $5c, $01, $03, $02, $0a, $03, $01
	db $07, $02, $0a, $03, $01, $05, $02, $0a, $03, $01, $00, $02, $0a, $03

Data_04_5c8b:
	db $10, $35, $5c

Data_04_5c8e:
	db $01, $00, $02, $0a, $03, $01, $05, $02, $0a, $03, $01, $06, $02, $0a, $03, $01
	db $03, $02, $0a, $03, $04, $19, $01, $07, $02, $01, $03, $10, $a4, $5c, $01, $05
	db $02, $0a, $03, $01, $00, $02, $0a, $03

Data_04_5cb6:
	db $10, $35, $5c

Data_04_5cb9:
	db $01, $00, $02, $0a, $03, $01, $05, $02, $0a, $03, $01, $08, $02, $0a, $03, $09
	db $01, $08, $02, $02, $03, $08, $02, $02, $03, $10, $c8, $5c, $b5, $5d, $b5, $5d
	db $24, $25, $00

SECTION "analyzed_011cdd", ROMX[$5cdd], BANK[$04]

Data_04_5cdd:
	db $e6, $5d, $e6, $5d, $24, $25, $00

SECTION "analyzed_011ce5", ROMX[$5ce5], BANK[$04]

Data_04_5ce5:
	db $17, $5e, $17, $5e, $24, $25, $00

SECTION "analyzed_011ced", ROMX[$5ced], BANK[$04]

Data_04_5ced:
	db $48, $5e, $48, $5e, $24, $25, $00

SECTION "analyzed_011cf5", ROMX[$5cf5], BANK[$04]

Data_04_5cf5:
	db $79, $5e, $79, $5e, $24, $25, $00

SECTION "analyzed_011cfd", ROMX[$5cfd], BANK[$04]

Data_04_5cfd:
	db $aa, $5e, $db, $5e, $24, $25, $00

Data_04_5d04:
	db $00, $0c, $5f

Data_04_5d07:
	db $0c, $5f, $24, $00, $00

Data_04_5d0c:
	db $00, $3d, $5f

Data_04_5d0f:
	db $3d, $5f, $24, $00, $00

Data_04_5d14:
	db $00, $6e, $5f

Data_04_5d17:
	db $6e, $5f, $24, $00, $00

Data_04_5d1c:
	db $00, $ba, $4c

Data_04_5d1f:
	db $31, $5d

Data_04_5d21:
	db $ba, $4c

Data_04_5d23:
	db $48, $5d, $61, $5d

Data_04_5d27:
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_5d2f:
	db $75, $5d, $01, $00, $02, $0a, $03, $01, $01, $02, $0a, $03, $01, $00, $02, $0a
	db $03, $01, $02, $02, $0a, $03, $10, $31, $5d, $01, $01, $02, $0a, $03, $01, $03
	db $02, $0a, $03, $01, $04, $02, $14, $03, $04, $1f, $01, $05, $02, $14, $03

Data_04_5d5e:
	db $10, $31, $5d

Data_04_5d61:
	db $01, $00, $02, $0a, $03, $01, $06, $02, $1e, $03, $04, $13, $01, $07, $02, $0a
	db $03, $10, $6d, $5d, $01, $08, $02, $04, $03, $09, $01, $08, $02, $02, $03, $08
	db $02, $02, $03, $10, $7a, $5d, $e7, $5f

Data_04_5d89:
	db $e7, $5f

Data_04_5d8b:
	db $26, $26, $00

SECTION "analyzed_011d8f", ROMX[$5d8f], BANK[$04]

Data_04_5d8f:
	db $08, $60

Data_04_5d91:
	db $08, $60

Data_04_5d93:
	db $26, $26, $00

SECTION "analyzed_011d97", ROMX[$5d97], BANK[$04]

Data_04_5d97:
	db $29, $60

Data_04_5d99:
	db $29, $60

Data_04_5d9b:
	db $27, $27, $00

SECTION "analyzed_011d9f", ROMX[$5d9f], BANK[$04]

Data_04_5d9f:
	db $4a, $60

Data_04_5da1:
	db $4a, $60

Data_04_5da3:
	db $26, $26, $00

SECTION "analyzed_011da7", ROMX[$5da7], BANK[$04]

Data_04_5da7:
	db $6b, $60

Data_04_5da9:
	db $6b, $60

Data_04_5dab:
	db $28, $28, $00

SECTION "analyzed_011daf", ROMX[$5daf], BANK[$04]

Data_04_5daf:
	db $7c, $60

Data_04_5db1:
	db $7c, $60

Data_04_5db3:
	db $28, $28, $00

SECTION "analyzed_011db7", ROMX[$5db7], BANK[$04]

Data_04_5db7:
	db $4a, $60

Data_04_5db9:
	db $4a, $60

Data_04_5dbb:
	db $26, $00, $00

SECTION "analyzed_011dbf", ROMX[$5dbf], BANK[$04]

Data_04_5dbf:
	db $6b, $60

Data_04_5dc1:
	db $6b, $60

Data_04_5dc3:
	db $28, $00, $00

Data_04_5dc6:
	db $00, $ba, $4c

Data_04_5dc9:
	db $d7, $5d, $df, $5d, $e7, $5d, $ff, $5d, $11, $5e, $18, $5e, $31, $5e, $01, $00
	db $02, $0a, $03, $10, $d7, $5d, $01, $04, $02, $0a, $03, $10, $df, $5d, $01, $06
	db $02, $04, $03, $09, $0a, $c6, $41, $01, $06, $02, $02, $03, $08, $0a, $0a, $42
	db $02, $02, $03, $10, $ec, $5d, $01, $07, $02, $04, $03, $09, $01, $07, $02, $02
	db $03, $08, $02, $02, $03, $10, $04, $5e

Data_04_5e11:
	db $08, $02, $02, $03, $10, $11, $5e

Data_04_5e18:
	db $01, $01, $02, $0a, $03, $01, $02, $02, $4e, $03, $04, $10, $01, $03, $02, $1e
	db $03, $01, $01, $02, $0a, $03

Data_04_5e2e:
	db $10, $d7, $5d

Data_04_5e31:
	db $01, $05, $02, $0a, $03, $10, $31, $5e, $8d, $60, $8d, $60, $29, $2a, $00

SECTION "analyzed_011e41", ROMX[$5e41], BANK[$04]

Data_04_5e41:
	db $be, $60, $ef, $60, $29, $2a, $00

SECTION "analyzed_011e49", ROMX[$5e49], BANK[$04]

Data_04_5e49:
	db $20, $61, $51, $61, $29, $2a, $00

SECTION "analyzed_011e51", ROMX[$5e51], BANK[$04]

Data_04_5e51:
	db $82, $61, $b3, $61, $29, $2a, $00

SECTION "analyzed_011e59", ROMX[$5e59], BANK[$04]

Data_04_5e59:
	db $e4, $61, $15, $62, $29, $2a, $00

SECTION "analyzed_011e61", ROMX[$5e61], BANK[$04]

Data_04_5e61:
	db $46, $62, $77, $62, $29, $2a, $00

SECTION "analyzed_011e69", ROMX[$5e69], BANK[$04]

Data_04_5e69:
	db $a8, $62, $a8, $62, $29, $2a, $00

SECTION "analyzed_011e71", ROMX[$5e71], BANK[$04]

Data_04_5e71:
	db $d9, $62, $d9, $62, $29, $2a, $00

SECTION "analyzed_011e79", ROMX[$5e79], BANK[$04]

Data_04_5e79:
	db $8d, $60, $8d, $60, $29, $00, $00

SECTION "analyzed_011e81", ROMX[$5e81], BANK[$04]

Data_04_5e81:
	db $d9, $62

Data_04_5e83:
	db $d9, $62

Data_04_5e85:
	db $29, $00, $00

SECTION "analyzed_011e89", ROMX[$5e89], BANK[$04]

Data_04_5e89:
	db $ba, $4c, $9f, $5e, $a8, $5e, $b5, $5e, $be, $5e, $d3, $5e, $eb, $5e, $0a, $5f
	db $13, $5f, $21, $5f, $36, $5f, $09, $01, $07, $02, $05, $03, $10, $9f, $5e, $09
	db $01, $00, $02, $02, $03, $08, $02, $02, $03, $10, $a8, $5e, $09, $01, $00, $02
	db $02, $03, $10, $b6, $5e, $09, $01, $01, $02, $0a, $03, $01, $04, $02, $14, $03
	db $04, $18, $01, $05, $02, $0a, $03, $10, $cb, $5e, $09, $01, $05, $02, $0a, $03
	db $01, $04, $02, $14, $03, $01, $01, $02, $0a, $03, $01, $00, $02, $3c, $03

Data_04_5ee8:
	db $10, $e3, $5e

Data_04_5eeb:
	db $09, $01, $01, $02, $0a, $03, $01, $02, $02, $14, $03, $04, $23, $01, $03, $02
	db $0a, $03, $01, $04, $02, $0a, $03, $01, $00, $02, $3c, $03

Data_04_5f07:
	db $10, $02, $5f

Data_04_5f0a:
	db $09, $01, $06, $02, $05, $03

Data_04_5f10:
	db $10, $9f, $5e

Data_04_5f13:
	db $09, $01, $07, $02, $05, $03, $01, $06, $02, $05, $03

Data_04_5f1e:
	db $10, $b5, $5e

Data_04_5f21:
	db $04, $22, $09, $01, $09, $02, $3c, $03, $09, $01, $09, $02, $02, $03, $08, $02
	db $02, $03, $10, $29, $5f, $04, $1a, $09, $01, $08, $02, $02, $03, $10, $39, $5f

Data_04_5f41:
	db $e2, $54, $4e, $55, $0c, $0d, $00, $00, $ba, $4c, $5d, $5f, $ba, $4c, $ba, $4c
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c, $65, $5f, $01, $00, $02, $01
	db $03, $10, $5d, $5f, $01, $00, $02, $04, $03, $09, $01, $00, $02, $02, $03, $08
	db $02, $02, $03, $10, $6a, $5f
