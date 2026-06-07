; Shared sound driver ($4000-$4aff): byte-identical in banks $3e and $3f.
; INCLUDEd once per bank from sound.asm with SB set to the bank suffix (3f/3e)
; and SBI to the bank index (0/1), so each instantiation gets its own
; bank-suffixed labels (Func_3f_*/Func_3e_* ...) and a distinct floating section
; ("Sound driver {SBI}") placed by layout.link. Data references ($442e freq
; table, $454b command jump table, $4708 instrument table, $4b00 song table) are
; raw bank-agnostic 16-bit addresses, so the emitted bytes are identical in both.
;
; See docs/sound_engine.md for the architecture and the command/bytecode tables.

SECTION "Sound driver {SBI}", ROMX

Func_{SB}_4000:
	jp Sound_Reset_{SB}
Func_{SB}_4003:
	jp Sound_Update_{SB}
	jp Sound_StartTracked_{SB}
	jp Sound_Start_{SB}

Func_{SB}_400c:
	jp Sound_SetFadeBlock_{SB}
	jp Sound_SetMute_{SB}
Sound_Reset_{SB}:
	ld hl, $de80
	ld de, $0180
Func_{SB}_4018:
	xor a
	ld [hl+], a
	dec de
	ld a, d
	or e
	jr nz, Func_{SB}_4018
	xor a
	ld hl, $ff10
	ld b, $15
Func_{SB}_4025:
	ld [hl+], a
	dec b
	jr nz, Func_{SB}_4025
	ld a, $77
	ldh [rAUDVOL], a
	xor a
	ldh [rAUDTERM], a
	ld a, $8f
	ldh [rAUDENA], a
	xor a
	call Sound_StartTracked_{SB}
	xor a
	call Sound_Start_{SB}
	call Sound_Update_{SB}
	xor a
	ld [$dee0], a
	ld [$dee4], a
	ld [$dee8], a
	ld [$deec], a
	ld [$def0], a
	ld [$def4], a
	ld [$def8], a
	ld [$defc], a
	ret
Sound_Update_{SB}:
	ld hl, $de92
	ld a, [hl+]
	or [hl]
	ret nz
	ld a, [$de80]
	or a
	ret nz
	ld a, [$ded0]
	or a
	ret nz
	call Func_{SB}_4113
	call Func_{SB}_4070
	ret
Func_{SB}_4070:
	ld hl, $ded3
	ld a, [hl+]
	or a
	ret z

Func_{SB}_4076:
	cp $01
	jr z, $408c
	ld a, [hl]
	or a
	jr nz, $4089
	ldh a, [rAUDVOL]
	cp $77
	ret z
	add a, $11
	ldh [rAUDVOL], a
	inc hl
	ld a, [hl-]
	dec a
	ld [hl], a
	ret
	ld a, [hl]
	or a
	jr nz, $4089
	ldh a, [rAUDVOL]
	or a
	ret z
	sub $11
	ldh [rAUDVOL], a
	inc hl
	ld a, [hl-]
	jr $4089
Sound_StartTracked_{SB}:
	ld [$dec0], a
	call Sound_ResolveCmdPtr_{SB}
	ld de, $dee0
	ld bc, $df00
	call Func_{SB}_40d2
	xor a
	ld [$ded3], a
	ld a, $77
	ldh [rAUDVOL], a
	ret
Sound_Start_{SB}:
	ld [$dec1], a
	call Sound_ResolveCmdPtr_{SB}
	ld de, $def0
	ld bc, $df80
	call Func_{SB}_40d2
	ret
Sound_ResolveCmdPtr_{SB}:
	sla a
	ld l, a
	ld h, $00
	ld de, $4b00
	add hl, de
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	add hl, de
	ret
Func_{SB}_40d2:
	ld a, $01
	ld [$de80], a
	ld a, $04
Func_{SB}_40d9:
	push af
	push bc
	ld a, [de]
	ld b, a
	ld a, [hl]
	cp b
	pop bc
	jr c, Func_{SB}_40fe
	push de
	push hl
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [CUR_BANK_TAG]
	ld [de], a
	inc de
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	push de
	ld de, $4b00
	add hl, de
	pop de
	ld a, l
	ld [de], a
	inc de
	ld a, h
	ld [de], a
	pop hl
	pop de
	xor a
	ld [bc], a
Func_{SB}_40fe:
	inc hl
	inc hl
	inc hl
	inc de
	inc de
	inc de
	inc de
	ld a, c
	add a, $20
	ld c, a
	pop af
	dec a
	jr nz, Func_{SB}_40d9
	ld a, $00
	ld [$de80], a
	ret
Func_{SB}_4113:
	xor a
	ld [$dec3], a
	ld hl, $df00
	ld a, h
	ld [$dec6], a
	ld a, l
	ld [$dec7], a
	ld hl, $dee2
	ld a, h
	ld [$dec4], a
	ld a, l
	ld [$dec5], a
Func_{SB}_412d:
	dec hl
	dec hl
	ld a, [hl]
	inc hl
	inc hl
	or a
	jr z, Func_{SB}_4158
	dec hl
	ld a, [hl]
	ld [Data_00_2000], a
	inc hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, [$dec6]
	ld d, a
	ld a, [$dec7]
	ld e, a
	ld a, [de]
	or a
	jr nz, Func_{SB}_41ac
Func_{SB}_414a:
	ld a, [hl]
	cp $ff
	jp z, Func_{SB}_418c
	bit 7, a
	jp z, Func_{SB}_432c
	jp nz, Func_{SB}_452e
Func_{SB}_4158:
	ld a, [$dec6]
	ld h, a
	ld a, [$dec7]
	ld l, a
	ld de, $0020
	add hl, de
	ld a, h
	ld [$dec6], a
	ld a, l
	ld [$dec7], a
	ld a, [$dec4]
	ld h, a
	ld a, [$dec5]
	ld l, a
	inc hl
	inc hl
	inc hl
	inc hl
	ld a, h
	ld [$dec4], a
	ld a, l
	ld [$dec5], a
	ld a, [$dec3]
	inc a
	ld [$dec3], a
	cp $08
	jr nz, Func_{SB}_412d
	ret
Func_{SB}_418c:
	ld a, [$dec4]
	ld b, a
	ld a, [$dec5]
	ld c, a
	dec bc
	dec bc
	xor a
	ld [bc], a
	ld b, $01
	jr Func_{SB}_41d5
Func_{SB}_419c:
	ld a, [$dec4]
	ld h, a
	ld a, [$dec5]
	ld l, a
	dec hl
	dec hl
	ld a, [hl]
	or a
	jr z, Func_{SB}_41e5
	jr Func_{SB}_41c3
Func_{SB}_41ac:
	ld a, [$dec3]
	cp $04
	jr nc, Func_{SB}_419c
	ld a, [$dec4]
	ld h, a
	ld a, [$dec5]
	ld l, a
	ld a, $0e
	add a, l
	ld l, a
	ld a, [hl]
	or a
	jr nz, Func_{SB}_41d8
Func_{SB}_41c3:
	ld a, [$dec3]
	and $03
	cp $03
	jr z, Func_{SB}_41d2
	call Func_{SB}_41e8
	call Func_{SB}_422e
Func_{SB}_41d2:
	call Func_{SB}_4257
Func_{SB}_41d5:
	call Func_{SB}_42c5
Func_{SB}_41d8:
	ld a, [$dec6]
	ld h, a
	ld a, [$dec7]
	ld l, a
	ld a, [hl]
	or a
	jr z, Func_{SB}_41e5
	dec [hl]
Func_{SB}_41e5:
	jp Func_{SB}_4158
; Duty/length envelope stepper (cmd $ed, $4754 family). Reads [value,frames]
; pairs via the +$0c/d pointer; value -> rAUD1LEN/rAUD2LEN. Skips CH3 (no LEN).
Func_{SB}_41e8:
	ld a, [$dec3]
	and $03
	cp $02
	ret z
	ld d, $df
	ld a, [$dec7]
	ld e, a
	ld a, $0f
	add a, e
	ld e, a
	ld a, [de]
	or a
	jr nz, Func_{SB}_4218
	dec de
	dec de
	ld a, [de]
	ld l, a
	dec de
	ld a, [de]
	ld h, a
	inc hl
	inc hl
	ld a, [hl+]
	inc de
	inc de
	ld [de], a
	ld a, [hl+]
	inc de
	ld [de], a
	dec de
	dec de
	ld l, a
	ld [de], a
	dec de
	ld h, a
	ld [de], a
	inc de
	inc de
	inc de
Func_{SB}_4218:
	dec a
	ld [de], a
	dec de
	ld a, [de]
	ld b, a
	ld a, [$dec3]
	and $03
	cp $00
	jr z, Func_{SB}_422a
	ld a, b
	ldh [rAUD2LEN], a
	ret
Func_{SB}_422a:
	ld a, b
	ldh [rAUD1LEN], a
	ret
; Pitch envelope stepper (cmd $fb, $474c family). Reads [value,frames] pairs via
; the +$1c/d pointer; value is a signed offset added to the note freq (vibrato).
Func_{SB}_422e:
	ld d, $df
	ld a, [$dec7]
	ld e, a
	ld hl, $001f
	add hl, de
	ld a, [hl]
	or a
	jr nz, Func_{SB}_4254
	push hl
	ld d, h
	ld e, l
	dec de
	dec hl
	dec hl
	ld a, [hl-]
	ld h, [hl]
	ld l, a
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	ld b, a
	dec de
	dec de
	ld a, l
	ld [de], a
	dec de
	ld a, h
	ld [de], a
	pop hl
	ld a, b
Func_{SB}_4254:
	dec a
	ld [hl], a
	ret
Func_{SB}_4257:
	ld d, $df
	ld a, [$dec7]
	ld e, a
	inc de
	inc de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	or l
	jr z, Func_{SB}_42be
	push hl
	ld hl, $000d
	add hl, de
	ld a, [hl]
	ld c, a
	ld de, $000e
	add hl, de
	ld a, [hl]
	ld e, a
	ld d, $00
	bit 7, a
	jr z, Func_{SB}_427c

Func_{SB}_427a:
	ld d, $ff
Func_{SB}_427c:
	pop hl
	add hl, de
	ld e, c
	ld d, $00
	bit 7, c
	jr z, Func_{SB}_4287

Func_{SB}_4285:
	ld d, $ff
Func_{SB}_4287:
	add hl, de
	ld b, $00
Func_{SB}_428a:
	ld a, [$dec3]
	and $03
	cp $00
	jr z, Func_{SB}_429f
	cp $01
	jr z, Func_{SB}_42a9
	cp $02
	jr z, Func_{SB}_42b3
	ld a, l
	ldh [rAUD4POLY], a
	ret
Func_{SB}_429f:
	ld a, l
	ldh [rAUD1LOW], a
	ld a, h
	ldh [rAUD1HIGH], a
	ld [$ded2], a
	ret
Func_{SB}_42a9:
	ld a, l
	ldh [rAUD2LOW], a
	ld a, h
	ldh [rAUD2HIGH], a
	ld [$ded2], a
	ret
Func_{SB}_42b3:
	ld a, l
	ldh [rAUD3LOW], a
	ld a, h
	ldh [rAUD3HIGH], a
	ld a, $00
	ldh [rAUD3LEN], a
	ret
Func_{SB}_42be:
	ld b, $01
	ld [$ded2], a
	jr Func_{SB}_428a
; Volume envelope stepper (cmd $fc, $4708 family). Reads [value,frames] pairs via
; the +$16/17 pointer; value -> rAUD1/2/4ENV (retriggering) or rAUD3LEVEL, routed
; by voice & 3 in Func_{SB}_42ea. +$18 is the frame countdown.
Func_{SB}_42c5:
	ld d, $df
	ld a, [$dec7]
	ld e, a
	ld hl, $0018
	add hl, de
	ld a, b
	cp $01
	jr z, Func_{SB}_4326
	ld a, [hl]
	or a
	jr nz, Func_{SB}_4323
	dec hl
	ld a, [hl-]
	ld e, a
	ld a, [hl+]
	inc hl
	ld d, a
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	inc de
	ld [hl-], a
	ld b, a
	ld a, e
	ld [hl-], a
	ld a, d
	ld [hl+], a
	inc hl
Func_{SB}_42ea:
	ld a, [$dec3]
	and $03
	cp $00
	jr z, Func_{SB}_4318
	cp $01
	jr z, Func_{SB}_430b
	cp $02
	jr z, Func_{SB}_4305
	ld a, c
	ldh [rAUD4ENV], a
	ld a, $80
	ldh [rAUD4GO], a
	ld a, b
	jr Func_{SB}_4323
Func_{SB}_4305:
	ld a, c
	ldh [rAUD3LEVEL], a
	ld a, b
	jr Func_{SB}_4323
Func_{SB}_430b:
	ld a, c
	ldh [rAUD2ENV], a
	ld a, [$ded2]
	or $80
	ldh [rAUD2HIGH], a
	ld a, b
	jr Func_{SB}_4323
Func_{SB}_4318:
	ld a, c
	ldh [rAUD1ENV], a
	ld a, [$ded2]
	or $80
	ldh [rAUD1HIGH], a
	ld a, b
Func_{SB}_4323:
	dec a
	ld [hl], a
	ret
Func_{SB}_4326:
	ld b, $ff
	ld c, $08
	jr Func_{SB}_42ea
Func_{SB}_432c:
	ld b, a
	and $70
	bit 4, a
	jr z, Func_{SB}_4347
	ld a, [$dec6]
	ld d, a
	ld a, [$dec7]
	ld e, a
	inc hl
	ld a, [hl]
	ld [de], a
	inc de
	inc de
	inc de
	inc de
	inc de
	inc de
	ld a, $01
	ld [de], a
Func_{SB}_4347:
	ld a, [$dec3]
	cp $04
	jr nc, Func_{SB}_435e
	ld a, [$dec4]
	ld d, a
	ld a, [$dec5]
	ld e, a
	ld a, $0e
	add a, e
	ld e, a
	ld a, [de]
	or a
	jr nz, Func_{SB}_4382
Func_{SB}_435e:
	ldh a, [rAUDVOL]
	or a
	jr nz, Func_{SB}_4365

Func_{SB}_4363:
	ld b, $07
Func_{SB}_4365:
	ld a, b
	and $0f
	cp $07
	jr z, Func_{SB}_4382
	cp $0f
	jr z, Func_{SB}_4382
	ld a, b
	and $60
	cp $60
	jp z, Func_{SB}_43ff

Func_{SB}_4378:
	cp $40
	ld a, $00
	jp z, $4401
	jp $4403
Func_{SB}_4382:
	inc hl
	ld a, [$dec4]
	ld d, a
	ld a, [$dec5]
	ld e, a
	ld a, l
	ld [de], a
	inc de
	ld a, h
	ld [de], a
	ld a, b
	and $0f
	sla a
	ld l, a
	ld h, $00
	ld de, $442e
	add hl, de
	ld d, $df
	ld a, [$dec7]
	ld e, a
	inc de
	ld a, [de]
	sla a
	sla a
	sla a
	sla a
	sla a
	ld c, a
	ld b, $00
	add hl, bc
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	inc de
	ld a, [de]
	or a
	jr nz, Func_{SB}_43e8
	ld hl, $0006
	add hl, de
	ld a, [hl+]
	inc hl
	ld [hl-], a
	ld b, a
	ld a, [hl+]
	inc hl
	ld [hl+], a
	ld c, a
	ld a, [bc]
	ld [hl+], a
	inc bc
	ld a, [bc]
	ld [hl+], a
	ld bc, $0004
	add hl, bc
	ld a, [hl+]
	inc hl
	ld [hl-], a
	ld a, [hl+]
	inc hl
	ld [hl+], a
	xor a
	ld [hl+], a
	inc hl
	ld a, [hl+]
	inc hl
	ld [hl-], a
	ld b, a
	ld a, [hl+]
	inc hl
	ld [hl+], a
	ld c, a
	ld a, [bc]
	ld [hl+], a
	inc bc
	ld a, [bc]
	ld [hl], a
Func_{SB}_43e8:
	xor a
	ld [de], a
	inc de
	inc de
	ld a, [de]
	or a
	jr nz, Func_{SB}_43fb
	dec de
	ld a, [de]
	dec de
	dec de
	dec de
	dec de
	dec de
	ld [de], a
Func_{SB}_43f8:
	jp Func_{SB}_41ac
Func_{SB}_43fb:
	xor a
	ld [de], a
	jr Func_{SB}_43f8
Func_{SB}_43ff:
	ld a, $01
	add a, $0f
	add a, $01
	ld e, $ee
	ld c, a
	ld a, [$dec3]
	and $03
	cp $00
	jr z, Func_{SB}_4425
	cp $01
	jr z, Func_{SB}_4421
	cp $02
	jr z, Func_{SB}_441d
	sla c
	rlc e
Func_{SB}_441d:
	sla c
	rlc e
Func_{SB}_4421:
	sla c
	rlc e
Func_{SB}_4425:
	ldh a, [rAUDTERM]
	and e
	or c
	ldh [rAUDTERM], a
	jp Func_{SB}_4382

Data_{SB}_442e:
	db $00, $01, $20, $01, $40, $01, $60, $01, $80, $01, $a0, $01

Data_{SB}_443a:
	db $c0, $01

Data_{SB}_443c:
	db $00, $00, $10, $01, $30, $01

Data_{SB}_4442:
	db $50, $01

Data_{SB}_4444:
	db $70, $01, $90, $01

Data_{SB}_4448:
	db $b0, $01, $d0, $01, $00, $00

Data_{SB}_444e:
	db $2c, $00, $07, $01, $c9, $01, $23, $02, $c7, $02, $58, $03, $da, $03, $00, $00
	db $9d, $00

Data_{SB}_4460:
	db $6b, $01, $23, $02, $77, $02

Data_{SB}_4466:
	db $12, $03

Data_{SB}_4468:
	db $9b, $03, $16, $04, $00, $00

Data_{SB}_446e:
	db $16, $04, $83, $04, $e5, $04, $11, $05, $63, $05, $ac, $05, $ed, $05, $00, $00
	db $4e, $04, $b5, $04

Data_{SB}_4482:
	db $11, $05

Data_{SB}_4484:
	db $3b, $05, $89, $05, $ce, $05

Data_{SB}_448a:
	db $0b, $06, $00, $00

Data_{SB}_448e:
	db $0b, $06, $42, $06, $72, $06, $89, $06, $b2, $06, $d6, $06, $f7, $06, $00, $00
	db $27, $06, $5b, $06

Data_{SB}_44a2:
	db $89, $06

Data_{SB}_44a4:
	db $9e, $06, $c4, $06, $e7, $06

Data_{SB}_44aa:
	db $06, $07, $00, $00

Data_{SB}_44ae:
	db $06, $07, $21, $07, $39, $07, $44, $07, $59, $07, $6b, $07, $7b, $07, $00, $00
	db $14, $07, $2d, $07

Data_{SB}_44c2:
	db $44, $07

Data_{SB}_44c4:
	db $4f, $07, $62, $07, $73, $07

Data_{SB}_44ca:
	db $83, $07, $00, $00

Data_{SB}_44ce:
	db $83, $07, $90, $07, $9d, $07, $a2, $07, $ac, $07, $b6, $07, $be, $07, $00, $00

Data_{SB}_44de:
	db $8a, $07

Data_{SB}_44e0:
	db $97, $07

Data_{SB}_44e2:
	db $a2, $07

Data_{SB}_44e4:
	db $a7, $07, $b1, $07, $ba, $07

Data_{SB}_44ea:
	db $c1, $07, $00, $00

Data_{SB}_44ee:
	db $c1, $07, $c8, $07, $ce, $07, $d1, $07, $d6, $07, $db, $07, $df, $07, $00, $00
	db $c5, $07, $cb, $07

Data_{SB}_4502:
	db $d1, $07

Data_{SB}_4504:
	db $d4, $07, $d9, $07, $dd, $07

Data_{SB}_450a:
	db $e1, $07, $00, $00

Data_{SB}_450e:
	db $e1, $07, $e4, $07, $e7, $07, $e9, $07, $eb, $07, $ed, $07, $ef, $07, $00, $00
	db $e2, $07, $e6, $07

Data_{SB}_4522:
	db $e9, $07

Data_{SB}_4524:
	db $ea, $07

Data_{SB}_4526:
	db $ec, $07, $ee, $07, $00, $00, $00, $00

; Channel-stream command dispatch (byte with bit 7 set). $9x -> Func_{SB}_46cc
; (set octave register [+1]=nibble-1, the freq-table row); otherwise (cmd-$ea)
; indexes the jump table at
; $454b. Command set (see docs/sound_engine.md):
;   $ea n  load CH3 waveform $4760[n]      $f0    skip byte (marker)
;   $eb    loop back if [+7]-- nonzero     $f1-$f7 reserved (jp self)
;   $ec n  set loop count/point            $f8    return ([+$12])
;   $ed n  load effect table $4754[n]      $f9 .. call (save [+$12])
;   $ee n  set CH1 sweep (NR10)            $fa .. goto (rel16)
;   $ef n  set [+$10]                      $fb n  load table $474c[n]
;                                          $fc n  set instrument $4708[n]
;                                          $fd n  set [+5]
;                                          $fe    key-on flag [+4]=1
Func_{SB}_452e:
	ld b, a
	and $f0
	cp $90
	jp z, Func_{SB}_46cc
	ld d, h
	ld e, l
	ld a, b
	sub $ea
	sla a
	ld hl, $454b
	ld b, $00
	ld c, a
	add hl, bc
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	push hl
	ld h, d
	ld l, e
	ret

Data_{SB}_454b:
	db $a1, $46

Data_{SB}_454d:
	db $87, $46, $71, $46

Data_{SB}_4551:
	db $43, $46

Data_{SB}_4553:
	db $3c, $46

Data_{SB}_4555:
	db $2a, $46

Data_{SB}_4557:
	db $26, $46, $db, $46, $db, $46, $db, $46, $db, $46, $db, $46, $db, $46, $db, $46

Data_{SB}_4567:
	db $14, $46, $f9, $45, $ef, $45, $c1, $45, $96, $45, $86, $45, $75, $45

Func_{SB}_4575:
	ld d, $df
	ld a, [$dec7]
	ld e, a
	inc de
	inc de
	inc de
	inc de
	ld a, $01
	ld [de], a
	inc hl
	jp Func_{SB}_414a
	ld d, $df
	ld a, [$dec7]
	ld e, a
	ld a, $05
	add a, e
	ld e, a
	inc hl
	ld a, [hl+]
	ld [de], a
	jp Func_{SB}_414a
	inc hl
	ld a, [hl+]
	sla a
	push hl
	ld hl, $4708
	ld b, $00
	ld c, a
	add hl, bc
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld d, $df
	ld a, [$dec7]
	ld e, a
	ld a, $14
	add a, e
	ld e, a
	ld a, h
	ld [de], a
	inc de
	inc de
	ld [de], a
	dec de
	ld a, l
	ld [de], a
	inc de
	inc de
	ld [de], a
	inc de
	xor a
	ld [de], a
	pop hl
	jp Func_{SB}_414a
	inc hl
	ld a, [hl+]
	sla a
	push hl
	ld hl, $474c
	ld b, $00
	ld c, a
	add hl, bc
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld d, $df
	ld a, [$dec7]
	ld e, a
	ld a, $1a
	add a, e
	ld e, a
	ld a, h
	ld [de], a
	inc de
	inc de
	ld [de], a
	dec de
	ld a, l
	ld [de], a
	inc de
	inc de
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	pop hl
	jp Func_{SB}_414a
	inc hl
	ld e, [hl]
	inc hl
	ld d, [hl]
	add hl, de
	dec hl
	dec hl
	jp Func_{SB}_414a
	inc hl
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	ld d, $df
	ld a, [$dec7]
	ld e, a
	ld a, $12
	add a, e
	ld e, a
	ld a, h
	ld [de], a
	inc de
	ld a, l
	ld [de], a
	add hl, bc
	dec hl
	dec hl
	dec hl
	jp Func_{SB}_414a
	ld d, $df
	ld a, [$dec7]
	ld e, a
	ld a, $12
	add a, e
	ld e, a
	ld a, [de]
	ld h, a
	inc de
	ld a, [de]
	ld l, a
	jp Func_{SB}_414a

Func_{SB}_4626:
	inc hl
	jp Func_{SB}_414a
Func_{SB}_462a:
	inc hl
	ld a, [hl+]
	ld b, a
	ld d, $df
	ld a, [$dec7]
	ld e, a
	ld a, $10
	add a, e
	ld e, a
	ld a, b
	ld [de], a
	jp Func_{SB}_414a

Func_{SB}_463c:
	inc hl
	ld a, [hl+]
	ldh [rAUD1SWEEP], a
	jp Func_{SB}_414a
Func_{SB}_4643:
	inc hl
	ld a, [hl+]
	push hl
	ld hl, $4754
	sla a
	ld b, $00
	ld c, a
	add hl, bc
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld d, $df
	ld a, [$dec7]
	ld e, a
	ld a, $0a
	add a, e
	ld e, a
	ld a, h
	ld [de], a
	inc de
	inc de
	ld [de], a
	dec de
	ld a, l
	ld [de], a
	inc de
	inc de
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	pop hl
	jp Func_{SB}_414a

Func_{SB}_4671:
	ld d, $df
	ld a, [$dec7]
	ld e, a
	ld a, $07
	add a, e
	ld e, a
	inc hl
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, h
	ld [de], a
	inc de
	ld a, l
	ld [de], a
	jp Func_{SB}_414a
	inc hl
	ld d, $df
	ld a, [$dec7]
	ld e, a
	ld a, $07
	add a, e
	ld e, a
	ld a, [de]
	or a
	jr z, $469e
	dec a
	ld [de], a
	inc de
	ld a, [de]
	ld h, a
	inc de
	ld a, [de]
	ld l, a
	jp Func_{SB}_414a
Func_{SB}_46a1:
	inc hl
	ld a, [hl+]
	push hl
	ld hl, $4760
	sla a
	ld b, $00
	ld c, a
	add hl, bc
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	xor a
	ldh [rAUD3ENA], a
	ld de, $ff30
	ld b, $10
Func_{SB}_46b8:
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, Func_{SB}_46b8
	ld a, $80
	ldh [rAUD3ENA], a
	ldh [rAUD3HIGH], a
	ld a, $00
	ldh [rAUD3LEN], a
	pop hl
	jp Func_{SB}_414a
Func_{SB}_46cc:
	ld d, $df
	ld a, [$dec7]
	ld e, a
	inc de
	ld a, [hl+]
	and $0f
	dec a
	ld [de], a
	jp Func_{SB}_414a

Func_{SB}_46db:
	jp Func_{SB}_46db
Sound_SetFadeBlock_{SB}:
	ld hl, $ded3
	ld a, b
	ld [hl+], a
	ld a, c
	ld [hl+], a
	ld [hl], a
	ret
Sound_SetMute_{SB}:
	ld [$ded0], a
	or a
	jr nz, $46fd
	ld a, [$ded1]
	ldh [rAUDTERM], a
	ld a, [$ded3]
	cp $01
	ret z
	ld a, $77
	ldh [rAUDVOL], a
	ret
	ldh a, [rAUDTERM]
	ld [$ded1], a
	xor a
	ldh [rAUDVOL], a
	ldh [rAUDTERM], a
	ret
Data_{SB}_4708:
	db $76, $47, $78, $47, $7c, $47, $80, $47, $84, $47, $86, $47

Data_{SB}_4714:
	db $88, $47, $8a, $47, $8c, $47, $8e, $47

Data_{SB}_471c:
	db $90, $47, $94, $47, $98, $47, $9a, $47, $9c, $47

Data_{SB}_4726:
	db $a0, $47, $a2, $47, $a4, $47, $aa, $47

Data_{SB}_472e:
	db $ae, $47, $b0, $47

Data_{SB}_4732:
	db $b4, $47, $b8, $47, $ba, $47, $be, $47, $c2, $47, $c6, $47, $ca, $47, $ce, $47
	db $d2, $47, $d6, $47, $da, $47, $de, $47, $e4, $47

Data_{SB}_474c:
	db $e6, $47, $e8, $47, $3c, $49

Data_{SB}_4752:
	db $4c, $49

Data_{SB}_4754:
	db $5e, $49, $60, $49, $62, $49, $64, $49, $66, $49, $70, $49

Func_{SB}_4760:
	ld [hl], h
	ld c, c
	add a, h
	ld c, c

Data_{SB}_4764:
	db $94, $49

Data_{SB}_4766:
	db $a4, $49, $b4, $49, $c4, $49, $d4, $49, $e4, $49

Data_{SB}_4770:
	db $f4, $49

Data_{SB}_4772:
	db $04, $4a

Data_{SB}_4774:
	db $14, $4a, $f0, $ff, $c1, $03, $90, $ff, $a1, $03, $70, $ff, $81, $03, $50, $ff
	db $40, $ff, $20, $ff

Data_{SB}_4788:
	db $19, $0c, $e4, $03, $d1, $0c, $53, $ff

Data_{SB}_4790:
	db $f1, $01, $00, $ff, $f1, $01, $b1, $ff, $73, $ff, $f2, $ff, $f1, $01, $91, $ff

Data_{SB}_47a0:
	db $81, $ff, $51, $ff, $79, $04, $b1, $07, $40, $ff, $1a, $10, $f5, $ff

Data_{SB}_47ae:
	db $40, $ff, $20, $ff

Data_{SB}_47b2:
	db $28, $ff, $20, $01, $80, $ff, $86, $ff, $20, $03, $80, $ff, $20, $04, $80, $ff
	db $20, $05, $80, $ff, $20, $06, $80, $ff, $20, $07, $80, $ff, $20, $08, $80, $ff
	db $20, $09, $80, $ff, $f0, $10, $f5, $ff, $e1, $01, $d0, $ff, $1c, $80, $f0, $80
	db $f6, $ff, $00, $00

Data_{SB}_47e6:
	db $00, $ff, $00, $10, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01, $fe, $01
	db $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01, $fe, $01
	db $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01

Data_{SB}_4814:
	db $fe, $01, $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01
	db $fe, $01, $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01
	db $fe, $01, $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01
	db $fe, $01, $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01
	db $fe, $01, $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01
	db $fe, $01, $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01
	db $fe, $01, $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01
	db $fe, $01, $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01
	db $fe, $01, $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01
	db $fe, $01, $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01
	db $fe, $01, $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01
	db $fe, $01, $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01
	db $fe, $01, $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01
	db $fe, $01, $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01
	db $fe, $01, $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01
	db $fe, $01, $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01
	db $fe, $01, $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01
	db $fe, $01, $fd, $01, $ff, $01, $01, $01, $02, $01, $03, $02, $02, $01, $ff, $01
	db $fe, $01, $fd, $01, $ff, $01, $00, $ff

Data_{SB}_493c:
	db $00, $01

Data_{SB}_493e:
	db $e0, $01, $d0, $01, $c0, $01, $b0, $01, $a0, $02, $90, $02, $80, $ff, $00, $01
	db $f0, $01, $e0, $01, $d0, $02, $c0, $02, $b0, $02, $a0, $02, $90, $02, $80, $ff

Data_{SB}_495e:
	db $00, $ff, $40, $ff, $80, $ff, $c0, $ff, $80, $01, $40, $01

Data_{SB}_496a:
	db $00, $02, $40, $03, $80, $ff

Data_{SB}_4970:
	db $c0, $02, $80, $ff

Data_{SB}_4974:
	db $00, $11, $23, $46, $9b, $cd, $ee, $ff, $ff, $ee, $dc, $b9, $64, $32, $11, $00
	db $01, $23, $45, $67, $89, $ab, $cd, $ef, $ed, $cb, $a9, $87, $65, $43, $21, $00

Data_{SB}_4994:
	db $00, $00, $00, $00, $00, $00, $00, $0f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f0

Data_{SB}_49a4:
	db $0f, $fe, $ed, $dc, $cb, $ba, $a9, $98, $87, $76, $65, $54, $43, $32, $21, $10
	db $01, $12, $23, $34, $45, $56, $67, $78, $89, $9a, $ab, $bc, $cd, $de, $ef, $f0
	db $01, $34, $68, $9a, $ce, $ff, $ec, $a9, $89, $ac, $ef, $ec, $a9, $86, $43, $10
	db $01, $46, $54, $8d, $f9, $51, $27, $be, $db, $db, $75, $32, $05, $67, $53, $20
	db $03, $69, $8c, $be, $fc, $bb, $ed, $ef, $db, $ac, $ba, $99, $78, $85, $64, $32

Data_{SB}_49f4:
	db $00, $11, $12, $46, $9b, $be, $ee, $ff, $ff, $ee, $ed, $d9, $64, $21, $11, $00

Data_{SB}_4a04:
	db $02, $46, $89, $ab, $cd, $ef, $ed, $cb, $a9, $87, $65, $45, $65, $43, $20, $00

Data_{SB}_4a14:
	db $01, $70, $13, $57, $9b, $df, $fb, $73, $03, $7b, $fd, $89, $75, $31, $00, $00

Data_{SB}_4a24:
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
