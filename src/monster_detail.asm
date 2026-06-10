; Monster detail / portrait display screen (banks $0f + $32). See docs/monster_detail_screen.md
; Carved out of analyzed.asm (byte-exact: section names + placement unchanged).

INCLUDE "monster.inc"
INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "sound_ids.inc"

SECTION "analyzed_03c000", ROMX[$4000], BANK[$0f]

Func_0f_4000:
	ld a, [wProgressFlags]
	bit 5, a
	jr nz, Func_0f_403b
	ld a, [$c2db]
	or a
	ret nz
	ldh a, [hJoyPressed]
	bit 3, a
	ret z
	ld a, [wPlayerStatus]
	bit 0, a
	ret nz
	FAR_CALL $01, Func_01_4c4d
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ld hl, wProgressFlags
	set 5, [hl]
	ld a, $10
	ld [$c2d8], a
	call Func_0f_43bb
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	ret
Func_0f_403b:
	ld a, [$c2d8]
	and $f0
	cp $10
	jr z, Func_0f_4050
	cp $20
	jr z, Func_0f_404c
	call Func_0f_4aac
	ret
Func_0f_404c:
	call Func_0f_42bb
	ret
Func_0f_4050:
	call Func_0f_4054
	ret
Func_0f_4054:
	ld a, [$c2d8]
	and $0f
	cp $01
	jp z, Func_0f_416c
	cp $02
	jp z, Func_0f_40f9
	cp $03
	jr z, Func_0f_4086
	FAR_CALL $01, Func_01_4e09
	ld a, $11
	ld [$c2d8], a
	xor a
	ld [$c2d9], a
	FAR_CALL $01, Func_01_4eb8
	ld a, $02
	ld [$c2ac], a
	ret
Func_0f_4086:
	ldh a, [hJoyPressed]
	bit 1, a
	jr nz, Func_0f_40cb
	bit 0, a
	jr nz, Func_0f_40e8
	bit 5, a
	jr nz, Func_0f_40b2
	bit 4, a
	ret z

Func_0f_4097:
	ld a, [$c2da]
	cp $01
	ret z
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ld a, $01
	ld [$c2da], a
	FAR_CALL $01, Func_01_4e8c
	ret

Func_0f_40b2:
	ld a, [$c2da]
	or a
	ret z
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	xor a
	ld [$c2da], a
	FAR_CALL $01, Func_01_4e8c
	ret
Func_0f_40cb:
	FAR_CALL $01, Func_01_4e09
	FAR_CALL $01, Func_01_4eb8
	push af
	ld a, SOUND_SFX_Cancel
	call PlaySound
	pop af
	ld a, $11
	ld [$c2d8], a
	ret
Func_0f_40e8:
	ld a, [$c2da]
	or a
	jr nz, Func_0f_40cb
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	call Func_0f_427b
	ret
Func_0f_40f9:
	ldh a, [hJoyPressed]
	bit 1, a
	jr nz, Func_0f_413e
	bit 0, a
	jr nz, Func_0f_415b
	bit 5, a
	jr nz, Func_0f_4125
	bit 4, a
	ret z

Data_0f_410a:
	db $fa, $da, $c2, $fe, $01, $c8, $f5, $3e, $04, $cd, $85, $0a, $f1, $3e, $01, $ea
	db $da, $c2, $3e, $01, $21, $8c, $4e, $cd, $2e, $04, $c9

Func_0f_4125:
	ld a, [$c2da]
	or a
	ret z
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	xor a
	ld [$c2da], a
	FAR_CALL $01, Func_01_4e8c
	ret
Func_0f_413e:
	FAR_CALL $01, Func_01_4e09
	FAR_CALL $01, Func_01_4eb8
	push af
	ld a, SOUND_SFX_Cancel
	call PlaySound
	pop af
	ld a, $11
	ld [$c2d8], a
	ret
Func_0f_415b:
	ld a, [$c2da]
	or a
	jr nz, Func_0f_413e
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	call Func_0f_4265
	ret
Func_0f_416c:
	ldh a, [hJoyPressed]
	bit 1, a
	jp nz, Func_0f_4206
	bit 0, a
	jr nz, Func_0f_41d6
	bit 6, a
	jr nz, Func_0f_41bd
	bit 7, a
	ret z
	ld a, [wRoomType]
	cp $05
	jr z, Func_0f_41a3
	cp $06
	jr z, Func_0f_41a3
	ld a, [$c2d9]
	cp $03
	ret z
	inc a
	ld [$c2d9], a
	FAR_CALL $01, Func_01_4eb8
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ret
Func_0f_41a3:
	ld a, [$c2d9]
	cp $02
	ret z
	inc a
	ld [$c2d9], a
	FAR_CALL $01, Func_01_4eb8
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ret
Func_0f_41bd:
	ld a, [$c2d9]
	or a
	ret z
	dec a
	ld [$c2d9], a
	FAR_CALL $01, Func_01_4eb8
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ret
Func_0f_41d6:
	ld a, [$c2d9]
	or a
	jr z, Func_0f_420f
	cp $01
	jr z, Func_0f_4229
	cp $02
	jr z, Func_0f_4243
	ld a, $13
	ld [$c2d8], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	FAR_CALL $01, Func_01_4e55
	ld a, $01
	ld [$c2da], a
	FAR_CALL $01, Func_01_4e8c
	ret
Func_0f_4206:
	call Func_0f_42a2
	ld a, $01
	ld [$c2ac], a
	ret
Func_0f_420f:
	ld a, $20
	ld [$c2d8], a
	call Func_00_04bc
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ldh a, [$ffa8]
	ld [$cf6d], a
	ldh a, [$ffa9]
	ld [$cf6e], a
	ret
Func_0f_4229:
	ld a, $30
	ld [$c2d8], a
	call Func_00_04bc
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ldh a, [$ffa8]
	ld [$cf6d], a
	ldh a, [$ffa9]
	ld [$cf6e], a
	ret
Func_0f_4243:
	ld a, $12
	ld [$c2d8], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	FAR_CALL $01, Func_01_4e55
	ld a, $01
	ld [$c2da], a
	FAR_CALL $01, Func_01_4e8c
	ret
Func_0f_4265:
	call Func_0f_42a2
	FAR_CALL $01, Func_01_4b0e
	ld a, $02
	ld [wTransitionState], a
	ld a, $01
	ld [$c2ac], a
	ret
Func_0f_427b:
	call Func_0f_42a2
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	FAR_CALL $03, RequestFloorExit
	ld a, $01
	ld [wLives], a
	ld a, $02
	ld [wTransitionState], a
	ld a, $04
	ld [wC2D7], a
	ld a, $01
	ld [$c2ac], a
	ret
Func_0f_42a2:
	ld hl, wProgressFlags
	res 5, [hl]
	xor a
	ld [$c2d8], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	FAR_CALL $01, Func_01_449d
	ret
Func_0f_42bb:
	ld a, [$c2d8]
	and $0f
	jr z, Func_0f_42cf
	cp $01
	jr z, Func_0f_42dd
	cp $02
	jr z, Func_0f_42f9
	cp $03
	jr z, Func_0f_4307

SECTION "analyzed_03c2ce", ROMX[$42ce], BANK[$0f]

Data_0f_42ce:
	db $c9

SECTION "analyzed_03c2cf", ROMX[$42cf], BANK[$0f]

Func_0f_42cf:
	ld a, $21
	ld [$c2d8], a
	ld a, $03
	ld [$c2ac], a
	call Func_0f_433a
	ret
Func_0f_42dd:
	call Func_0f_436e
	call Func_0f_49c9
	ldh a, [hJoyPressed]
	bit 1, a
	jr nz, Func_0f_4329
	and $30
	ret z
	ld a, $22
	ld [$c2d8], a
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ret
Func_0f_42f9:
	ld a, $23
	ld [$c2d8], a
	ld a, $03
	ld [$c2ac], a
	call Func_0f_435b
	ret
Func_0f_4307:
	call Func_0f_436e
	call Func_0f_48f1
	call Func_0f_466c
	call DrawMonsterPortraitSprites
	ldh a, [hJoyPressed]
	bit 1, a
	jr nz, Func_0f_4329
	and $30
	ret z
	ld a, $20
	ld [$c2d8], a
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ret
Func_0f_4329:
	call Func_0f_4543
	call Func_0f_42a2
	ld a, [$cf6d]
	ldh [$ffa8], a
	ld a, [$cf6e]
	ldh [$ffa9], a
	ret
Func_0f_433a:
	call Func_0f_44d5
	call Func_00_0bdd
	call Func_0f_450d
	FAR_CALL $3b, Func_3b_4000
	call LoadDiscStoneDisplay
	call LoadMonsterPortrait
	call Func_0f_4565
	call Func_0f_4518
	call Func_0f_43c3
	ret
Func_0f_435b:
	call Func_0f_44d5
	call Func_00_0bdd
	call Func_0f_450d
	call Func_0f_4588
	call DrawMonsterPortraitBgMap
	call Func_0f_452d
	ret
Func_0f_436e:
	ld a, $0f
	ld [wDrawBank], a
	ld a, [$c287]
	and $0c
	srl a
	ld hl, $43b3
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ldh a, [rSCY]
	add a, $40
	ld b, a
	ldh a, [rSCX]
	ld c, a
	call DrawMetasprite
	ld a, [$c287]
	and $0c
	srl a
	ld hl, $43ab
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ldh a, [rSCY]
	add a, $40
	ld b, a
	ldh a, [rSCX]
	add a, $98
	ld c, a
	call DrawMetasprite
	call Func_0f_43c3
	ret

Data_0f_43ab:
	db $16, $71, $1b, $71, $20, $71, $1b, $71, $25, $71, $2a, $71, $20, $71, $2a, $71

Func_0f_43bb:
	xor a
	ld [$cfb2], a
	ld [$cfb1], a
	ret
Func_0f_43c3:
	xor a
	ld [$cfb3], a
	ld [$cfb4], a
	ld a, [$cfb2]
	ld c, a
	ld b, $00
	sla c
	rl b
	ld hl, $4419
	add hl, bc
	ld a, [hl+]
	ld [$cfb5], a
	ld [$cfb7], a
	ld [$cfb9], a
	ld a, [hl]
	ld [$cfb6], a
	ld [$cfb8], a
	ld [$cfba], a
	ld hl, $cfb3
	ld a, $06
	call LoadObjPalette
	ld a, [$cfb1]
	inc a
	ld [$cfb1], a
	and $03
	ret nz
	ld a, [$cfb2]
	inc a
	ld [$cfb2], a
	ld c, a
	ld b, $00
	sla c
	rl b
	ld hl, $4419
	add hl, bc
	ld a, [hl+]
	ld b, [hl]
	or b
	ret nz
	xor a
	ld [$cfb2], a
	ret

Data_0f_4419:
	db $3f, $04, $5e, $04, $7d, $04, $9c, $04, $bb, $04, $da, $04, $f9, $04, $18, $05
	db $37, $05, $56, $05, $75, $05, $94, $05, $b3, $05, $d2, $05, $f1, $05, $10, $06
	db $31, $06, $4e, $06, $6d, $06, $8c, $06, $ab, $06, $ca, $06, $e9, $06, $08, $07
	db $27, $07, $46, $07, $65, $07, $84, $07, $a3, $07, $c2, $07, $e1, $07, $e1, $07
	db $c1, $0b, $a1, $0f, $81, $13, $61, $17, $41, $1b, $21, $1f, $01, $23, $e1, $26
	db $c1, $2a, $a1, $2e, $81, $32, $61, $36, $41, $3a, $21, $3e, $01, $42, $21, $46
	db $c1, $49, $a1, $4d, $81, $51, $61, $55, $41, $59, $21, $5d, $01, $61, $e1, $64
	db $c1, $68, $a1, $6c, $81, $70, $61, $74, $41, $78, $21, $7c, $21, $7c, $22, $78
	db $23, $74, $24, $70, $25, $6c, $26, $68, $27, $64, $28, $60, $29, $5c, $2a, $58
	db $2b, $54, $2c, $50, $2d, $4c, $2e, $48, $2f, $44, $30, $40, $31, $44, $32, $38
	db $33, $34, $34, $30, $35, $2c, $36, $28, $37, $24, $38, $20, $39, $1c, $3a, $18
	db $3b, $14, $3c, $10, $3d, $0c, $3e, $08, $3f, $04, $00, $00

Func_0f_44d5:
	xor a
	ldh [rVBK], a
	ld c, $11
	ld hl, $9c1f
Func_0f_44dd:
	push bc
	push hl
	ld bc, $0015
	ld d, $fc
	call FillVram
	pop hl
	pop bc
	ld de, $0020
	add hl, de
	dec c
	jr nz, Func_0f_44dd
	ld a, $01
	ldh [rVBK], a
	ld c, $11
	ld hl, $9c1f
Func_0f_44f9:
	push bc
	push hl
	ld bc, $0015
	ld d, $08
	call FillVram
	pop hl
	pop bc
	ld de, $0020
	add hl, de
	dec c
	jr nz, Func_0f_44f9
	ret
Func_0f_450d:
	ld hl, $0897
	ld a, $01
	ld b, $06
	call Func_00_0716
	ret
Func_0f_4518:
	ld hl, $51cc
	ld a, $01
	ld b, $06
	call Func_00_0716
	ld hl, $5224
	ld a, $04
	ld b, $03
	call Func_00_0732
	ret
Func_0f_452d:
	ld hl, $524c
	ld a, $01
	ld b, $03
	call Func_00_0716
	call Func_0f_4bb7
	ld hl, $52b4
	ld a, $06
	call LoadObjPalette
	ret
Func_0f_4543:
	call Func_0f_44d5
	call Func_00_0bdd
	call Func_0f_450d
	FAR_CALL $05, Func_05_48a5
	FAR_CALL $05, Func_05_48fc
	call Func_00_0786
	ld a, $01
	ld [$c2ac], a
	ret
Func_0f_4565:
	xor a
	ld [$cf65], a
	ld [$cf66], a
	ld [$cf67], a
	ld hl, MonsterDetailBg0
	ld de, $9c20
	call CopyBgMap
	call Func_0f_46d6
	call Func_0f_4722
	call Func_0f_476e
	call Func_0f_494b
	call Func_0f_49d9
	ret
Func_0f_4588:
	xor a
	ld [$cf65], a
	ld [$cf66], a
	ld [$cf67], a
	call Func_0f_45ab
	call Func_0f_48f1
	call Func_0f_45c7
	call Func_0f_4604
	call Func_0f_466c
	call Func_0f_480c
	call Func_0f_4832
	call Func_0f_489f
	ret
Func_0f_45ab:
	ld a, $09
	call Func_00_119a
	or a
	jr nz, Func_0f_45bd
	ld hl, MonsterDetailBg2
	ld de, $9c20
	call CopyBgMap
	ret
Func_0f_45bd:
	ld hl, MonsterDetailBg1
	ld de, $9c20
	call CopyBgMap
	ret
Func_0f_45c7:
	xor a
	ldh [rVBK], a
	ld a, $09
	call Func_00_119a
	or a
	jr nz, Func_0f_45eb
	call WaitForHBlank
	ld a, [wLives]
	swap a
	and $0f
	add a, $9a
	ld hl, $9cc4
	ld [hl+], a
	ld a, [wLives]
	and $0f
	add a, $9a
	ld [hl+], a
	ret
Func_0f_45eb:
	call WaitForHBlank
	ld a, [wLives]
	swap a
	and $0f
	add a, $9a
	ld hl, $9c66
	ld [hl+], a
	ld a, [wLives]
	and $0f
	add a, $9a
	ld [hl+], a
	ret
Func_0f_4604:
	ld a, $09
	call Func_00_119a
	or a
	ret z
	xor a
	ldh [rVBK], a
	ld a, [wSilverKeys]
	ld d, a
	ld e, $0a
	call Func_00_3774
	ld b, h
	call WaitForHBlank
	ld a, l
	and $0f
	add a, $9a
	ld hl, $9ce4
	ld [hl+], a
	ld a, b
	and $0f
	add a, $9a
	ld [hl+], a
	ret
; Disc-stone progress display (Pashute's shrine): for wDiscStoneFragments (1-4),
; upload that fragment count's 72-tile graphic from DiscStoneDisplayTable[frags-1]
; to VRAM $9380 and point the renderer at DiscStoneDisplayMeta ($cf3a/$cf3b).
LoadDiscStoneDisplay:
	xor a
	ld [$cf3c], a
	ld [$cf3d], a
	ld [$cf3e], a
	ld a, [wDiscStoneFragments]
	or a
	jr z, Func_0f_465c
	dec a
	add a, a
	ld hl, DiscStoneDisplayTable
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, $01
	ldh [rVBK], a
	ld de, $9380
	ld bc, $0480
	call VramCopy16
	ld a, $bb
	ld [$cf3a], a
	ld a, $46
	ld [$cf3b], a
	ret
Func_0f_465c:
	xor a
	ld [$cf3a], a
	ld [$cf3b], a
	ret

DiscStoneDisplayTable:
	db $ce, $5a, $4e, $5f, $ce, $63

Data_0f_466a:
	db $4e, $68

Func_0f_466c:
	xor a
	ldh [rVBK], a
	ld a, [$cf3a]
	ld l, a
	ld a, [$cf3b]
	ld h, a
	or l
	ret z
	ld a, [$cf3e]
	or a
	jr z, Func_0f_4684
	dec a
	ld [$cf3e], a
	ret
Func_0f_4684:
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [hl+]
	or a
	jr nz, Func_0f_4690
	ld h, d
	ld l, e
	jr Func_0f_4684
Func_0f_4690:
	ld [$cf3e], a
	ld a, e
	ld [$cf3c], a
	ld a, d
	ld [$cf3d], a
	ld a, l
	ld [$cf3a], a
	ld a, h
	ld [$cf3b], a
	ld h, d
	ld l, e
	ld a, $09
	call Func_00_119a
	or a
	jr nz, Func_0f_46b4
	ld de, $9c87
	call CopyBgMap
	ret
Func_0f_46b4:
	ld de, $9ca7
	call CopyBgMap
	ret

DiscStoneDisplayMeta:
	db $ce, $6c, $07, $e6, $6c, $07, $fe, $6c, $07, $16, $6d, $07, $2e, $6d, $07, $46
	db $6d, $07, $fe, $6c, $07, $5e, $6d, $07, $bb, $46, $00

Func_0f_46d6:
	xor a
	ldh [rVBK], a
	call WaitForHBlank
	ld hl, wScore
	ld de, $9c92
	ld a, [hl]
	and $0f
	add a, $9a
	ld [de], a
	dec de
	ld a, [hl+]
	swap a
	and $0f
	add a, $9a
	ld [de], a
	dec de
	ld a, [hl]
	and $0f
	add a, $9a
	ld [de], a
	dec de
	ld a, [hl+]
	swap a
	and $0f
	add a, $9a
	ld [de], a
	dec de
	ld a, [hl]
	and $0f
	add a, $9a
	ld [de], a
	dec de
	ld a, [hl+]
	swap a
	and $0f
	add a, $9a
	ld [de], a
	dec de
	ld a, [hl]
	and $0f
	add a, $9a
	ld [de], a
	dec de
	ld a, [hl]
	swap a
	and $0f
	add a, $9a
	ld [de], a
	ret
Func_0f_4722:
	xor a
	ldh [rVBK], a
	call WaitForHBlank
	ld hl, wHiScore
	ld de, $9cd2
	ld a, [hl]
	and $0f
	add a, $9a
	ld [de], a
	dec de
	ld a, [hl+]
	swap a
	and $0f
	add a, $9a
	ld [de], a
	dec de
	ld a, [hl]
	and $0f
	add a, $9a
	ld [de], a
	dec de
	ld a, [hl+]
	swap a
	and $0f
	add a, $9a
	ld [de], a
	dec de
	ld a, [hl]
	and $0f
	add a, $9a
	ld [de], a
	dec de
	ld a, [hl+]
	swap a
	and $0f
	add a, $9a
	ld [de], a
	dec de
	ld a, [hl]
	and $0f
	add a, $9a
	ld [de], a
	dec de
	ld a, [hl]
	swap a
	and $0f
	add a, $9a
	ld [de], a
	ret
Func_0f_476e:
	xor a
	ldh [rVBK], a
	ld a, [wRoomType]
	cp $02
	jr z, Func_0f_478e
	cp $06
	jr z, Func_0f_4798
	cp $00
	jr z, Func_0f_47a2
	cp $01
	jr z, Func_0f_47cc

Data_0f_4784:
	db $21, $82, $6e, $11, $25, $9c, $cd, $4e, $0b, $c9

Func_0f_478e:
	ld hl, $6e26
	ld de, $9c25
	call CopyBgMap
	ret
Func_0f_4798:
	ld hl, $6e54
	ld de, $9c25
	call CopyBgMap
	ret
Func_0f_47a2:
	ld a, [wActiveFloor]
	ld d, a
	ld e, $0a
	call Func_00_3774
	push hl
	ld a, l
	add a, a
	ld hl, $47f8
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $9c2c
	call CopyBgMap
	pop hl
	ld a, h
	add a, a
	ld hl, $47f8
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $9c2d
	call CopyBgMap
	ret
Func_0f_47cc:
	ld a, [wActiveFloor]
	cp $0a
	jr z, Func_0f_47ee
	ld hl, $6f14
	ld de, $9c2c
	call CopyBgMap
	ld a, [wActiveFloor]
	add a, a
	ld hl, $47f8
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $9c2d
	call CopyBgMap
	ret
Func_0f_47ee:
	ld hl, $6f1e
	ld de, $9c2c
	call CopyBgMap
	ret

Data_0f_47f8:
	db $b0, $6e, $ba, $6e, $c4, $6e, $ce, $6e, $d8, $6e, $e2, $6e, $ec, $6e, $f6, $6e
	db $00, $6f, $0a, $6f

Func_0f_480c:
	ld a, [wDisplayMonster]
	cp $ff
	ret z
	xor a
	ldh [rVBK], a
	call WaitForHBlank
	ld a, [wDisplayMonster]
	ld hl, wMonsterUses
	rst AddAToHL
	ld a, [hl]
	ld b, a
	swap a
	and $0f
	add a, $9a
	ld hl, $9e09
	ld [hl+], a
	ld a, b
	and $0f
	add a, $9a
	ld [hl+], a
	ret
Func_0f_4832:
	ld hl, $6d8c
	ld de, $9c6d
	ld b, $01
	call Func_0f_4880
	ld hl, $6da2
	ld de, $9cad
	ld b, $02
	call Func_0f_4880
	ld hl, $6db8
	ld de, $9ced
	ld b, $04
	call Func_0f_4880
	ld hl, $6dce
	ld de, $9d2d
	ld b, $08
	call Func_0f_4880
	ld hl, $6de4
	ld de, $9d6d
	ld b, $10
	call Func_0f_4880
	ld hl, $6dfa
	ld de, $9dad
	ld b, $20
	call Func_0f_4880
	ld hl, $6e10
	ld de, $9ded
	ld b, $40
	call Func_0f_4880
	ret
Func_0f_4880:
	ld a, [$cfe8]
	and b
	jr nz, Func_0f_4889
	ld hl, $6d76
Func_0f_4889:
	call CopyBgMap
	ret
Func_0f_488d:
	inc c
	ld b, $01
Func_0f_4890:
	dec c
	jr z, Func_0f_4897
	sla b
	jr Func_0f_4890
Func_0f_4897:
	ld a, [$cfe8]
	or b
	ld [$cfe8], a
	ret
Func_0f_489f:
	xor a
	ldh [rVBK], a
	call WaitForHBlank
	ld a, [wFreeDiscStones]
	add a, $9a
	ld hl, $9c52
	ld [hl], a
	ld a, [wMonsterDiscStones]
	add a, $9a
	ld hl, $9c92
	ld [hl], a
	ld a, [$cfdb]
	add a, $9a
	ld hl, $9cd2
	ld [hl], a
	ld a, [$cfdc]
	add a, $9a
	ld hl, $9d12
	ld [hl], a
	call WaitForHBlank
	ld a, [$cfdd]
	add a, $9a
	ld hl, $9d52
	ld [hl], a
	ld a, [$cfde]
	add a, $9a
	ld hl, $9d92
	ld [hl], a
	ld a, [$cfdf]
	add a, $9a
	ld hl, $9dd2
	ld [hl], a
	ld a, [$cfe0]
	add a, $9a
	ld hl, $9e12
	ld [hl], a
	ret
Func_0f_48f1:
	ld a, $02
	ld [wDrawBank], a
	ld a, [$cf66]
	add a, a
	ld hl, $493f
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, $09
	call Func_00_119a
	or a
	jr nz, Func_0f_4915
	ldh a, [rSCY]
	add a, $38
	ld b, a
	ldh a, [rSCX]
	add a, $10
	ld c, a
	jr Func_0f_491f
Func_0f_4915:
	ldh a, [rSCY]
	add a, $20
	ld b, a
	ldh a, [rSCX]
	add a, $20
	ld c, a
Func_0f_491f:
	call DrawMetasprite
	ld a, [$cf67]
	inc a
	ld [$cf67], a
	cp $03
	ret nz
	xor a
	ld [$cf67], a
	ld a, [$cf66]
	inc a
	ld [$cf66], a
	cp $06
	ret nz
	xor a
	ld [$cf66], a
	ret

Data_0f_493f:
	db $65, $51, $77, $51, $89, $51, $9b, $51, $89, $51, $77, $51

Func_0f_494b:
	call Func_0f_49ca
	ld b, h
	ld c, l
	ld de, $0064
	call Func_00_3715
	ld b, h
	ld c, l
	ld de, $018b
	call Func_00_3788
	call Func_0f_49b3
	or a
	ret nz
	ld d, c
	ld e, $64
	call Func_00_3774
	xor a
	ldh [rVBK], a
	ld de, $9d0c
	call WaitForHBlank
	ld a, l
	ld [de], a
	inc de
	push de
	ld d, h
	ld e, $0a
	call Func_00_3774
	pop de
	call WaitForHBlank
	ld a, l
	ld [de], a
	inc de
	call WaitForHBlank
	ld a, h
	ld [de], a
	ld a, [$c2a3]
	ld b, a
	ld a, [$c2a4]
	ld c, a
	ld de, $0064
	call Func_00_3715
	ld b, h
	ld c, l
	ld de, $018b
	call Func_00_3788
	ld d, c
	ld e, $0a
	call Func_00_3774
	ld de, $9d10
	call WaitForHBlank
	ld a, l
	ld [de], a
	inc de
	call WaitForHBlank
	ld a, h
	ld [de], a
	ret
Func_0f_49b3:
	push bc
	ld a, c
	cp $64
	jr nz, Func_0f_49c6

Data_0f_49b9:
	db $21, $ec, $70, $11, $01, $9d, $cd, $4e, $0b, $c1, $3e, $01, $c9

Func_0f_49c6:
	pop bc
	xor a
	ret
Func_0f_49c9:
	ret
Func_0f_49ca:
	ld c, $4c
	ld de, $cff8
	ld hl, $0000
Func_0f_49d2:
	ld a, [de]
	rst AddAToHL
	inc de
	dec c
	jr nz, Func_0f_49d2
	ret
Func_0f_49d9:
	ld hl, $4a0b
Func_0f_49dc:
	ld a, [hl]
	cp $ff
	ret z
	ld b, a
	push hl
	push hl
	swap a
	and $0f
	ld hl, wItemsSeen
	rst AddAToHL
	ld d, [hl]
	ld a, b
	and $07
	ld hl, $1209
	rst AddAToHL
	ld a, [hl]
	pop hl
	and d
	jr z, Func_0f_4a05
	push hl
	inc hl
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call CopyBgMap
	pop hl
Func_0f_4a05:
	pop hl
	ld a, $05
	rst AddAToHL
	jr Func_0f_49dc

Data_0f_4a0b:
	db $00, $42, $9d, $2c, $6f, $01, $44, $9d, $3a, $6f, $02, $46, $9d, $48, $6f, $03
	db $48, $9d, $56, $6f, $04, $4a, $9d, $64, $6f, $05, $4c, $9d, $72, $6f, $06, $4e
	db $9d, $80, $6f, $07, $50, $9d, $8e, $6f, $10, $82, $9d, $9c, $6f, $11, $84, $9d
	db $aa, $6f, $12, $86, $9d, $b8, $6f, $13, $88, $9d, $c6, $6f, $14, $8a, $9d, $d4
	db $6f, $15, $8c, $9d, $e2, $6f, $16, $8e, $9d, $f0, $6f, $17, $90, $9d, $fe, $6f
	db $20, $c2, $9d, $0c, $70, $21, $c4, $9d, $1a, $70, $22, $c6, $9d, $28, $70, $23
	db $c8, $9d, $36, $70, $24, $ca, $9d, $44, $70, $25, $cc, $9d, $52, $70, $26, $ce
	db $9d, $60, $70, $27, $d0, $9d, $6e, $70, $30, $02, $9e, $7c, $70, $31, $04, $9e
	db $8a, $70, $32, $06, $9e, $98, $70, $33, $08, $9e, $a6, $70, $34, $0a, $9e, $b4
	db $70, $35, $0c, $9e, $c2, $70, $36, $0e, $9e, $d0, $70, $37, $10, $9e, $de, $70
	db $ff

Func_0f_4aac:
	ld a, [$c2d8]
	and $0f
	jr z, Func_0f_4ab8
	cp $01
	jr z, Func_0f_4ac6

SECTION "analyzed_03cab7", ROMX[$4ab7], BANK[$0f]

Data_0f_4ab7:
	db $c9

SECTION "analyzed_03cab8", ROMX[$4ab8], BANK[$0f]

Func_0f_4ab8:
	ld a, $31
	ld [$c2d8], a
	ld a, $03
	ld [$c2ac], a
	call Func_0f_4aef
	ret
Func_0f_4ac6:
	ld a, [wRoomType]
	cp $06
	jr z, Func_0f_4ad9
	cp $02
	jr z, Func_0f_4ad9
	FAR_CALL $12, Func_12_484e
Func_0f_4ad9:
	ldh a, [hJoyPressed]
	bit 1, a
	ret z
	call Func_0f_4543
	call Func_0f_42a2
	ld a, [$cf6d]
	ldh [$ffa8], a
	ld a, [$cf6e]
	ldh [$ffa9], a
	ret
Func_0f_4aef:
	call Func_0f_44d5
	call Func_00_0bdd
	call Func_0f_450d
	call Func_0f_4b27
	call Func_0f_4b02
	call Func_0f_4b4f
	ret
Func_0f_4b02:
	FAR_CALL $12, Func_12_47e5
	ld hl, $5138
	ld de, $9de3
	call CopyBgMap
	ld a, [wRoomType]
	cp $02
	jr z, Func_0f_4b1d
	cp $06
	ret nz
Func_0f_4b1d:
	ld hl, $5176
	ld de, $9cc4
	call CopyBgMap
	ret
Func_0f_4b27:
	FAR_CALL $10, Func_10_405f
	FAR_CALL $16, LoadTileset
	FAR_CALL $10, Func_10_4007
	xor a
	ldh [rVBK], a
	ld hl, $4d38
	ld de, $8800
	ld bc, $0800
	call VramCopy16
	ret
Func_0f_4b4f:
	FAR_CALL $10, Func_10_40a4
	ld hl, $4ce8
	ld a, $06
	ld b, $01
	call Func_00_0716
	ret
; LoadMonsterPortrait: for wDisplayMonster, set the wMonster*Ptr pointers from the
; $0f:$4C4B record and upload its 128 portrait tiles ($3c table $0f:$4C3D) to VRAM
; $8800. See docs/monster_detail_screen.md.
LoadMonsterPortrait:
	ld a, [wDisplayMonster]
	cp $ff
	jr z, Func_0f_4ba3
	add a, a
	ld hl, MonsterPortraitMetaTable
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, [hl+]
	ld [wMonsterMeta1Ptr], a
	ld a, [hl+]
	ld [wMonsterMeta1Ptr + 1], a
	ld a, [hl+]
	ld [wMonsterMeta2Ptr], a
	ld a, [hl+]
	ld [wMonsterMeta2Ptr + 1], a
	ld a, [hl+]
	ld [wMonsterBgMapPtr], a
	ld a, [hl]
	ld [wMonsterBgMapPtr + 1], a
	xor a
	ldh [rVBK], a
	ld a, [wDisplayMonster]
	add a, a
	ld hl, MonsterPortraitTileTable
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, $3c
	ld de, $8800
	ld bc, $0800
	call BankVramCopy
	ret
Func_0f_4ba3:
	xor a
	ld [wMonsterMeta1Ptr], a
	ld [wMonsterMeta1Ptr + 1], a
	ld [wMonsterMeta2Ptr], a
	ld [wMonsterMeta2Ptr + 1], a
	ld [wMonsterBgMapPtr], a
	ld [wMonsterBgMapPtr + 1], a
	ret
Func_0f_4bb7:
	ld a, [wDisplayMonster]
	cp $ff
	ret z
	add a, a
	ld hl, $4bde
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	push hl
	ld bc, $0020
	add hl, bc
	ld a, $04
	ld b, $03
	call Func_00_0716
	pop hl
	ld bc, $0048
	add hl, bc
	ld a, $01
	ld b, $07
	call Func_00_0732
	ret

Data_0f_4bde:
	db $91, $71, $11, $72, $91, $72, $11, $73, $91, $73, $11, $74, $91, $74

DrawMonsterPortraitBgMap:
	ld a, [wDisplayMonster]
	cp $ff
	ret z
	ld a, [wMonsterBgMapPtr]
	ld l, a
	ld a, [wMonsterBgMapPtr + 1]
	ld h, a
	or l
	ret z
	ld de, $9d41
	call CopyBgMap
	ret
DrawMonsterPortraitSprites:
	ld a, [wMonsterMeta1Ptr]
	ld l, a
	ld a, [wMonsterMeta1Ptr + 1]
	ld h, a
	or l
	jr z, Func_0f_4c20
	ld a, $0f
	ld [wDrawBank], a
	ldh a, [rSCY]
	add a, $50
	ld b, a
	ldh a, [rSCX]
	add a, $08
	ld c, a
	call DrawMetasprite
Func_0f_4c20:
	ld a, [wMonsterMeta2Ptr]
	ld l, a
	ld a, [wMonsterMeta2Ptr + 1]
	ld h, a
	or l
	ret z
	ld a, $0f
	ld [wDrawBank], a
	ldh a, [rSCY]
	add a, $50
	ld b, a
	ldh a, [rSCX]
	add a, $08
	ld c, a
	call DrawMetasprite
	ret

; Indexed by wDisplayMonster (0-6). See docs/monster_detail_screen.md.
MonsterPortraitTileTable:
	enum_table SUMMON, dw, \
		.TIGER = MonsterPortraitTiles_Tiger, \
		.MOCCHI = MonsterPortraitTiles_Mocchi, \
		.HARE = MonsterPortraitTiles_Hare, \
		.GALI = MonsterPortraitTiles_Gali, \
		.GOLEM = MonsterPortraitTiles_Golem, \
		.SUEZO = MonsterPortraitTiles_Suezo, \
		.PHOENIX = MonsterPortraitTiles_Phoenix

MonsterPortraitMetaTable:
	; -> a MonsterPortraitMetaRecords entry below
	db $59, $4c, $5f, $4c, $65, $4c, $6b, $4c, $71, $4c, $77, $4c, $7d, $4c

MonsterPortraitMetaRecords:
	; [meta1, meta2, bgmap] little-endian bank-$0f pointers (0 = none)
	dw $77e9, $0000, MonsterPortraitBg_Tiger ; 0 Tiger
	dw $783b, $7826, MonsterPortraitBg_Mocchi ; 1 Mocchi
	dw $7850, $0000, MonsterPortraitBg_Hare ; 2 Hare
	dw $78b2, $7881, MonsterPortraitBg_Gali ; 3 Gali
	dw $78d7, $0000, MonsterPortraitBg_Golem ; 4 Golem
	dw $7900, $0000, MonsterPortraitBg_Suezo ; 5 Suezo
	dw $0000, $0000, MonsterPortraitBg_Phoenix ; 6 Phoenix

Data_0f_4c83:
	db $f0, $8c, $cb, $67, $20, $14, $cb, $6f, $20, $01, $c9, $21, $d9, $cf, $7e, $fe
	db $ff, $28, $1a, $fe, $00, $28, $1a, $3d, $77, $c9, $21, $d9, $cf, $7e, $fe, $ff
	db $28, $07, $fe, $06, $28, $0b, $3c, $77, $c9, $3e, $00, $77, $c9, $3e, $06, $77
	db $c9, $3e, $ff, $77, $c9, $ff, $7f, $94, $52, $4a, $29, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00

Data_0f_4ce8:
	db $df, $03, $94, $02, $4a, $01, $00, $00

SECTION "analyzed_03cd38", ROMX[$4d38], BANK[$0f]

Data_0f_4d38:
	INCBIN "gfx/raw/Data_0f_4d38.2bpp", 0, 1420


MonsterDetailBg0:  ; 17x20 detail-screen background, drawn to $9c20 by Func_0f_4565
	db 17, 20
	dw MonsterDetailBg0_Attr
	dw MonsterDetailBg0_Idx
MonsterDetailBg0_Idx:
	db $dc, $dc, $dc, $dc, $dc, $fc, $d0, $d2, $d4, $d6, $d8, $da, $fc, $fc, $fc, $dc
	db $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $fc, $d1, $d3, $d5, $d7, $d9, $db
	db $fc, $fc, $fc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc
	db $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $92, $82, $8e
	db $91, $84, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $dc
	db $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc
	db $dc, $dc, $dc, $dc, $dc, $87, $88, $a7, $92, $82, $8e, $91, $84, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc
	db $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $88, $93, $84
	db $8c, $fc, $86, $84, $93, $0b, $fc, $fc, $00, $00, $00, $76, $00, $00, $0a, $dc
	db $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc
	db $dc, $dc, $dc, $dc, $fc, $0c, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc
	db $dc, $dc, $dc, $dc, $dc, $dc, $0e, $fc, $fc, $0d, $dc, $dc, $dc, $dc, $dc, $dc
	db $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $0f, $fc, $fc, $0c, $dc, $dc
	db $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $0e, $fc
	db $fc, $0d, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc
	db $dc, $dc, $0f, $fc, $fc, $0c, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc
	db $dc, $dc, $dc, $dc, $dc, $dc, $0e, $fc, $fc, $0d, $dc, $dc, $dc, $dc, $dc, $dc
	db $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $0f, $fc, $fc, $0c, $dc, $dc
	db $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $0e, $fc
	db $fc, $0d, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc
	db $dc, $dc, $0f, $fc
MonsterDetailBg0_Attr:
	db $0b, $0b, $0b, $0b, $0b, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $0b, $0b, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $08, $08, $08
	db $08, $08, $08, $08, $08, $00, $08, $08, $00, $00, $00, $00, $00, $00, $00, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $0b, $08, $01, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $06, $08, $08, $01, $0b, $0b, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $06, $08, $08, $01, $0b, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $06, $08
	db $08, $01, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b
	db $0b, $0b, $06, $08, $08, $01, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $06, $08, $08, $01, $0b, $0b, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $06, $08, $08, $01, $0b, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $06, $08
	db $08, $01, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b
	db $0b, $0b, $06, $08
MonsterDetailBg1:  ; 17x20 detail-screen background, drawn to $9c20 by Func_0f_45bd
	db 17, 20
	dw MonsterDetailBg1_Attr
	dw MonsterDetailBg1_Idx
MonsterDetailBg1_Idx:
	db $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $c8, $c9, $c9, $c9, $c9
	db $c9, $c9, $c9, $ca, $dc, $dc, $dc, $fc, $fc, $dc, $dc, $dc, $dc, $dc, $dc, $cb
	db $c7, $85, $91, $84, $84, $a4, $fc, $cc, $dc, $dc, $dc, $fc, $fc, $a4, $fc, $fc
	db $dc, $dc, $dc, $cb, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $cc, $dc, $dc, $dc, $dc
	db $dc, $dc, $dc, $dc, $dc, $dc, $dc, $cb, $c7, $fc, $fc, $fc, $fc, $a4, $fc, $cc
	db $dc, $dc, $dc, $dc, $dc, $dc, $dc, $fc, $fc, $fc, $dc, $cb, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $cc, $dc, $74, $7c, $dc, $dc, $dc, $dc, $fc, $fc, $fc, $dc, $cb
	db $c7, $fc, $fc, $fc, $fc, $a4, $fc, $cc, $dc, $75, $7d, $a4, $fc, $fc, $dc, $fc
	db $fc, $fc, $dc, $cb, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $cc, $dc, $dc, $dc, $dc
	db $dc, $dc, $dc, $dc, $dc, $dc, $dc, $cb, $c7, $fc, $fc, $fc, $fc, $a4, $fc, $cc
	db $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $cb, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $cc, $dc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $dc, $dc, $dc, $cb
	db $c7, $fc, $fc, $fc, $fc, $a4, $fc, $cc, $dc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $dc, $dc, $dc, $cb, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $cc, $dc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $dc, $dc, $dc, $cb, $c7, $fc, $fc, $fc, $fc, $a4, $fc, $cc
	db $dc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $dc, $dc, $dc, $cb, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $cc, $dc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $dc, $dc, $dc, $cb
	db $c7, $fc, $fc, $fc, $fc, $a4, $fc, $cc, $dc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $dc, $dc, $dc, $cb, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $cc, $dc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $a4, $fc, $fc, $cb, $c7, $fc, $fc, $fc, $fc, $a4, $fc, $cc
	db $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $cd, $ce, $ce, $ce, $ce
	db $ce, $ce, $ce, $cf
MonsterDetailBg1_Attr:
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $09, $09, $09, $09
	db $09, $09, $09, $09, $0b, $0b, $0b, $08, $08, $0b, $0b, $0b, $0b, $0b, $0b, $0b
	db $0a, $09, $09, $09, $09, $09, $09, $09, $0b, $0b, $0b, $08, $08, $08, $08, $08
	db $0b, $0b, $0b, $0b, $09, $09, $09, $09, $09, $09, $09, $09, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0a, $09, $09, $09, $09, $09, $09, $09
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $08, $08, $08, $0b, $0b, $09, $09, $09, $09
	db $09, $09, $09, $09, $0b, $00, $00, $0b, $0b, $0b, $0b, $08, $08, $08, $0b, $0b
	db $0a, $09, $09, $09, $09, $09, $09, $09, $0b, $00, $00, $08, $08, $08, $0b, $08
	db $08, $08, $0b, $0b, $09, $09, $09, $09, $09, $09, $09, $09, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0a, $09, $09, $09, $09, $09, $09, $09
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $09, $09, $09, $09
	db $09, $09, $09, $09, $0b, $08, $08, $08, $08, $08, $08, $08, $0b, $0b, $0b, $0b
	db $0a, $09, $09, $09, $09, $09, $09, $09, $0b, $08, $08, $08, $08, $08, $08, $08
	db $0b, $0b, $0b, $0b, $09, $09, $09, $09, $09, $09, $09, $09, $0b, $08, $08, $08
	db $08, $08, $08, $08, $0b, $0b, $0b, $0b, $0a, $09, $09, $09, $09, $09, $09, $09
	db $0b, $08, $08, $08, $08, $08, $08, $08, $0b, $0b, $0b, $0b, $09, $09, $09, $09
	db $09, $09, $09, $09, $0b, $08, $08, $08, $08, $08, $08, $08, $0b, $0b, $0b, $0b
	db $0a, $09, $09, $09, $09, $09, $09, $09, $0b, $08, $08, $08, $08, $08, $08, $08
	db $0b, $0b, $0b, $0b, $09, $09, $09, $09, $09, $09, $09, $09, $0b, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $0b, $0a, $09, $09, $09, $09, $09, $09, $09
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $09, $09, $09, $09
	db $09, $09, $09, $09
MonsterDetailBg2:  ; 17x20 detail-screen background, drawn to $9c20 by Func_0f_45ab
	db 17, 20
	dw MonsterDetailBg2_Attr
	dw MonsterDetailBg2_Idx
MonsterDetailBg2_Idx:
	db $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $c8, $c9, $c9, $c9, $c9
	db $c9, $c9, $c9, $ca, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $cb
	db $c7, $85, $91, $84, $84, $a4, $fc, $cc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc
	db $dc, $dc, $dc, $cb, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $cc, $dc, $dc, $dc, $dc
	db $dc, $dc, $dc, $fc, $fc, $fc, $dc, $cb, $c7, $fc, $fc, $fc, $fc, $a4, $fc, $cc
	db $dc, $fc, $fc, $dc, $dc, $dc, $dc, $fc, $fc, $fc, $dc, $cb, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $cc, $dc, $fc, $fc, $a4, $fc, $fc, $dc, $fc, $fc, $fc, $dc, $cb
	db $c7, $fc, $fc, $fc, $fc, $a4, $fc, $cc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc
	db $dc, $dc, $dc, $cb, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $cc, $dc, $dc, $dc, $dc
	db $dc, $dc, $dc, $dc, $dc, $dc, $dc, $cb, $c7, $fc, $fc, $fc, $fc, $a4, $fc, $cc
	db $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $cb, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $cc, $dc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $dc, $dc, $dc, $cb
	db $c7, $fc, $fc, $fc, $fc, $a4, $fc, $cc, $dc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $dc, $dc, $dc, $cb, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $cc, $dc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $dc, $dc, $dc, $cb, $c7, $fc, $fc, $fc, $fc, $a4, $fc, $cc
	db $dc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $dc, $dc, $dc, $cb, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $cc, $dc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $dc, $dc, $dc, $cb
	db $c7, $fc, $fc, $fc, $fc, $a4, $fc, $cc, $dc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $dc, $dc, $dc, $cb, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $cc, $dc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $a4, $fc, $fc, $cb, $c7, $fc, $fc, $fc, $fc, $a4, $fc, $cc
	db $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $dc, $cd, $ce, $ce, $ce, $ce
	db $ce, $ce, $ce, $cf
MonsterDetailBg2_Attr:
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $09, $09, $09, $09
	db $09, $09, $09, $09, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b
	db $0a, $09, $09, $09, $09, $09, $09, $09, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $0b, $09, $09, $09, $09, $09, $09, $09, $09, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $08, $08, $08, $0b, $0b, $0a, $09, $09, $09, $09, $09, $09, $09
	db $0b, $08, $08, $0b, $0b, $0b, $0b, $08, $08, $08, $0b, $0b, $09, $09, $09, $09
	db $09, $09, $09, $09, $0b, $08, $08, $08, $08, $08, $0b, $08, $08, $08, $0b, $0b
	db $0a, $09, $09, $09, $09, $09, $09, $09, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $0b, $09, $09, $09, $09, $09, $09, $09, $09, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0a, $09, $09, $09, $09, $09, $09, $09
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $09, $09, $09, $09
	db $09, $09, $09, $09, $0b, $08, $08, $08, $08, $08, $08, $08, $0b, $0b, $0b, $0b
	db $0a, $09, $09, $09, $09, $09, $09, $09, $0b, $08, $08, $08, $08, $08, $08, $08
	db $0b, $0b, $0b, $0b, $09, $09, $09, $09, $09, $09, $09, $09, $0b, $08, $08, $08
	db $08, $08, $08, $08, $0b, $0b, $0b, $0b, $0a, $09, $09, $09, $09, $09, $09, $09
	db $0b, $08, $08, $08, $08, $08, $08, $08, $0b, $0b, $0b, $0b, $09, $09, $09, $09
	db $09, $09, $09, $09, $0b, $08, $08, $08, $08, $08, $08, $08, $0b, $0b, $0b, $0b
	db $0a, $09, $09, $09, $09, $09, $09, $09, $0b, $08, $08, $08, $08, $08, $08, $08
	db $0b, $0b, $0b, $0b, $09, $09, $09, $09, $09, $09, $09, $09, $0b, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $0b, $0a, $09, $09, $09, $09, $09, $09, $09
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $09, $09, $09, $09
	db $09, $09, $09, $09
Data_0f_5ace:
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $fc, $ff, $ff, $fc, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff
	db $fc, $ff, $ff, $fc, $fc, $ff, $ff, $fc, $ff, $fc, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $3f, $ff, $cf, $3f, $37, $cf, $0b, $f7, $05, $fb, $02, $fd, $01, $fe
	db $f9, $06, $00, $ff, $f8, $07, $04, $fb, $f2, $0d, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $1f, $ff, $07, $ff, $83, $7f, $41, $bf, $21, $df, $10, $ef, $10, $ef
	db $88, $77, $08, $f7, $88, $77, $48, $b7, $28, $d7, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $c3, $ff, $c3, $ff, $c3, $ff, $c3, $ff, $c3, $ff, $c3, $ff, $c3, $ff
	db $c3, $ff, $c3, $ff, $c3, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $7f, $ff
	db $7f, $ff, $bf, $7f, $bf, $7f, $bf, $7f, $bf, $7f, $ff, $ff, $ff, $ff, $ff, $ff
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
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $fe, $ff
	db $fe, $ff, $fd, $fe, $fd, $fe, $fd, $fe, $fd, $fe, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $c3, $ff, $c3, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $f8, $ff, $e0, $ff, $c1, $fe, $82, $fd, $84, $fb, $08, $f7, $08, $f7
	db $10, $ef, $10, $ef, $10, $ef, $10, $ef, $10, $ef, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $fc, $ff, $f3, $fc, $ec, $f3, $d0, $ef, $a0, $df, $40, $bf, $80, $7f
	db $80, $7f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $f8, $ff, $e0, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $3f, $ff, $ff, $3f, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff
	db $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $d0, $ef, $a0, $df, $a0, $df, $40, $bf, $40, $bf
	db $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $1f, $ff, $07, $ff, $0b, $f7, $05, $fb, $05, $fb, $02, $fd, $02, $fd
	db $05, $fa, $09, $f6, $0d, $f2, $0b, $f4, $0d, $f2, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $fc, $ff, $ff, $fc, $fc, $ff, $fc, $ff, $fc, $ff
	db $fc, $ff, $fc, $ff, $fc, $ff, $ff, $fc, $fc, $ff, $ff, $fc, $ff, $fc, $fc, $ff
	db $fc, $ff, $fc, $ff, $ff, $fc, $fc, $ff, $ff, $fc, $fe, $fd, $fd, $fe, $fe, $fd
	db $fd, $fe, $ff, $fc, $fc, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $3f, $ff, $cf, $3f, $37, $cf, $0b, $f7, $05, $fb
	db $02, $fd, $01, $fe, $f9, $06, $00, $ff, $f8, $07, $04, $fb, $f2, $0d, $08, $f7
	db $04, $fb, $00, $ff, $f0, $0f, $01, $fe, $e1, $1e, $12, $ed, $c5, $3b, $2b, $d7
	db $37, $cf, $cf, $3f, $3f, $ff, $1f, $ff, $07, $ff, $83, $7f, $41, $bf, $21, $df
	db $10, $ef, $10, $ef, $88, $77, $08, $f7, $88, $77, $48, $b7, $28, $d7, $08, $f7
	db $08, $f7, $08, $f7, $c8, $37, $28, $d7, $90, $6f, $50, $af, $a1, $5f, $41, $bf
	db $83, $7f, $07, $ff, $1f, $ff, $c3, $ff, $c3, $ff, $c3, $ff, $c3, $ff, $c3, $ff
	db $c3, $ff, $c3, $ff, $c3, $ff, $c3, $ff, $c3, $ff, $c3, $ff, $c3, $ff, $c3, $ff
	db $c3, $ff, $c3, $ff, $c3, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $7f, $ff, $7f, $ff, $bf, $7f, $bf, $7f, $bf, $7f, $bf, $7f, $bf, $7f
	db $bf, $7f, $bf, $7f, $bf, $7f, $7f, $ff, $7f, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
	db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $fe, $ff
	db $fe, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $fe, $ff, $fe, $ff, $fd, $fe, $fd, $fe, $fd, $fe, $fd, $fe, $fd, $fe
	db $fd, $fe, $fd, $fe, $fd, $fe, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $fe, $ff, $c3, $ff, $c3, $ff, $c3, $ff, $c3, $ff, $c3, $ff
	db $c3, $ff, $c3, $ff, $c3, $ff, $f8, $ff, $e0, $ff, $c1, $fe, $82, $fd, $84, $fb
	db $08, $f7, $08, $f7, $10, $ef, $10, $ef, $10, $ef, $10, $ef, $10, $ef, $10, $ef
	db $10, $ef, $10, $ef, $10, $ef, $10, $ef, $08, $f7, $08, $f7, $84, $fb, $82, $fd
	db $c1, $fe, $e0, $ff, $f8, $ff, $fc, $ff, $f3, $fc, $ec, $f3, $d0, $ef, $a0, $df
	db $40, $bf, $80, $7f, $80, $7f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $80, $7f, $80, $7f, $40, $bf, $a0, $df, $d0, $ef
	db $ec, $f3, $f3, $fc, $fc, $ff, $f8, $ff, $e0, $ff, $c0, $ff, $90, $ef, $20, $df
	db $40, $bf, $40, $bf, $80, $7f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $3f, $ff, $ff, $3f, $3f, $ff, $3f, $ff, $3f, $ff
	db $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff
	db $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff
	db $3f, $ff, $ff, $3f, $3f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $fe, $ff
	db $fe, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f
	db $80, $7f, $80, $7f, $80, $7f, $80, $7f, $40, $bf, $40, $bf, $a0, $df, $90, $ef
	db $c0, $ff, $e0, $ff, $f8, $ff, $1f, $ff, $07, $ff, $03, $ff, $09, $f7, $04, $fb
	db $02, $fd, $02, $fd, $01, $fe, $09, $f6, $01, $fe, $09, $f6, $05, $fa, $01, $fe
	db $01, $fe, $01, $fe, $09, $f6, $05, $fa, $02, $fd, $0a, $f5, $05, $fb, $09, $f7
	db $03, $ff, $07, $ff, $1f, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
	db $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00

Data_0f_63ce:
	INCBIN "gfx/raw/Data_0f_63ce.2bpp", 0, 1152

Data_0f_684e:
	INCBIN "gfx/raw/Data_0f_684e.2bpp", 0, 1152

Data_0f_6cce:
	db $03, $03, $dd, $6c, $d4, $6c, $38, $40, $48, $39, $41, $49, $3a, $42, $4a, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $03, $03, $f5, $6c, $ec, $6c, $3b, $43
	db $4b, $3c, $44, $4c, $3d, $45, $4d, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $03, $03, $0d, $6d, $04, $6d, $3e, $46, $4e, $3f, $47, $4f, $50, $58, $60, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $03, $03, $25, $6d, $1c, $6d, $51, $59
	db $61, $52, $5a, $62, $53, $5b, $63, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $03, $03, $3d, $6d, $34, $6d, $54, $5c, $64, $55, $5d, $65, $56, $5e, $66, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $03, $03, $55, $6d, $4c, $6d, $57, $5f
	db $67, $68, $70, $78, $69, $71, $79, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $03, $03, $6d, $6d, $64, $6d, $6a, $72, $7a, $6b, $73, $7b, $6c, $74, $7c, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $02, $04, $84, $6d, $7c, $6d, $fc, $fc
	db $fc, $fc, $a5, $a5, $a5, $a5, $09, $09, $09, $09, $09, $09, $09, $09, $02, $04
	db $9a, $6d, $92, $6d, $fc, $fc, $fc, $fc, $93, $88, $86, $b3, $09, $09, $09, $09
	db $09, $09, $09, $09, $02, $04, $b0, $6d, $a8, $6d, $fc, $fc, $fc, $fc, $8c, $8e
	db $82, $b3, $09, $09, $09, $09, $09, $09, $09, $09, $02, $04, $c6, $6d, $be, $6d
	db $fc, $fc, $fc, $fc, $87, $80, $91, $b3, $09, $09, $09, $09, $09, $09, $09, $09
	db $02, $04, $dc, $6d, $d4, $6d, $fc, $fc, $fc, $fc, $86, $80, $8b, $b3, $09, $09
	db $09, $09, $09, $09, $09, $09, $02, $04, $f2, $6d, $ea, $6d, $fc, $fc, $fc, $fc
	db $86, $8e, $8b, $b3, $09, $09, $09, $09, $09, $09, $09, $09, $02, $04, $08, $6e
	db $00, $6e, $fc, $fc, $fc, $fc, $92, $94, $84, $b3, $09, $09, $09, $09, $09, $09
	db $09, $09, $02, $04, $1e, $6e, $16, $6e, $fc, $fc, $fc, $fc, $8f, $87, $8e, $b3
	db $09, $09, $09, $09, $09, $09, $09, $09, $02, $0a, $40, $6e, $2c, $6e, $00, $02
	db $04, $06, $08, $0a, $0c, $0e, $10, $12, $01, $03, $05, $07, $09, $0b, $0d, $0f
	db $11, $13, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $02, $0a, $6e, $6e, $5a, $6e, $14, $16, $18, $1a
	db $1c, $1e, $20, $22, $24, $26, $15, $17, $19, $1b, $1d, $1f, $21, $23, $25, $27
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08

Data_0f_6e82:
	db $02, $0a, $9c, $6e, $88, $6e, $28, $2a, $2c, $2e, $30, $32, $34, $36, $dd, $fa
	db $29, $2b, $2d, $2f, $31, $33, $35, $37, $de, $fb, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08

Data_0f_6eb0:
	db $02, $01, $b8, $6e, $b6, $6e, $f2, $f3, $08, $08, $02, $01, $c2, $6e, $c0, $6e
	db $e0, $e1, $08, $08, $02, $01, $cc, $6e, $ca, $6e, $e2, $e3, $08, $08, $02, $01
	db $d6, $6e, $d4, $6e, $e4, $e5, $08, $08, $02, $01, $e0, $6e, $de, $6e, $e6, $e7
	db $08, $08, $02, $01, $ea, $6e, $e8, $6e, $e8, $e9, $08, $08, $02, $01, $f4, $6e
	db $f2, $6e, $ea, $eb, $08, $08, $02, $01, $fe, $6e, $fc, $6e, $ec, $ed, $08, $08
	db $02, $01, $08, $6f, $06, $6f, $ee, $ef, $08, $08, $02, $01, $12, $6f, $10, $6f
	db $f0, $f1, $08, $08, $02, $01, $1c, $6f, $1a, $6f, $f4, $f5, $08, $08, $02, $02
	db $28, $6f, $24, $6f, $f6, $f8, $f7, $f9, $08, $08, $08, $08, $02, $02, $36, $6f
	db $32, $6f, $10, $18, $11, $19, $01, $01, $01, $01, $02, $02, $44, $6f, $40, $6f
	db $12, $1a, $13, $1b, $03, $03, $03, $03, $02, $02, $52, $6f, $4e, $6f, $14, $1c
	db $15, $1d, $03, $03, $03, $03, $02, $02, $60, $6f, $5c, $6f, $16, $1e, $17, $1f
	db $01, $01, $01, $01, $02, $02, $6e, $6f, $6a, $6f, $16, $1e, $17, $1f, $05, $05
	db $05, $05, $02, $02, $7c, $6f, $78, $6f, $20, $28, $21, $29, $01, $01, $01, $01
	db $02, $02, $8a, $6f, $86, $6f, $22, $2a, $23, $2b, $02, $02, $02, $02, $02, $02
	db $98, $6f, $94, $6f, $24, $2c, $25, $2d, $04, $04, $04, $04, $02, $02, $a6, $6f
	db $a2, $6f, $26, $2e, $27, $2f, $01, $01, $01, $01, $02, $02, $b4, $6f, $b0, $6f
	db $30, $38, $31, $39, $01, $01, $01, $01, $02, $02, $c2, $6f, $be, $6f, $32, $3a
	db $33, $3b, $04, $04, $04, $04, $02, $02, $d0, $6f, $cc, $6f, $34, $3c, $35, $3d
	db $01, $01, $01, $01, $02, $02, $de, $6f, $da, $6f, $36, $3e, $37, $3f, $04, $04
	db $04, $04, $02, $02, $ec, $6f, $e8, $6f, $36, $3e, $37, $3f, $05, $05, $05, $05
	db $02, $02, $fa, $6f, $f6, $6f, $40, $48, $41, $49, $04, $04, $04, $04, $02, $02
	db $08, $70, $04, $70, $40, $48, $41, $49, $05, $05, $05, $05, $02, $02, $16, $70
	db $12, $70, $42, $4a, $43, $4b, $04, $04, $04, $04, $02, $02, $24, $70, $20, $70
	db $44, $4c, $45, $4d, $02, $02, $02, $02, $02, $02, $32, $70, $2e, $70, $46, $4e
	db $47, $4f, $02, $02, $02, $02, $02, $02, $40, $70, $3c, $70, $46, $4e, $47, $4f
	db $01, $01, $01, $01, $02, $02, $4e, $70, $4a, $70, $50, $58, $51, $59, $02, $02
	db $02, $02, $02, $02, $5c, $70, $58, $70, $50, $58, $51, $59, $01, $01, $01, $01
	db $02, $02, $6a, $70, $66, $70, $52, $5a, $53, $5b, $01, $01, $01, $01, $02, $02
	db $78, $70, $74, $70, $54, $5c, $55, $5d, $02, $02, $02, $02, $02, $02, $86, $70
	db $82, $70, $56, $5e, $57, $5f, $05, $05, $05, $05, $02, $02, $94, $70, $90, $70
	db $60, $68, $61, $69, $05, $05, $05, $05, $02, $02, $a2, $70, $9e, $70, $62, $6a
	db $63, $6b, $04, $04, $04, $04, $02, $02, $b0, $70, $ac, $70, $64, $6c, $65, $6d
	db $04, $04, $04, $04, $02, $02, $be, $70, $ba, $70, $66, $6e, $67, $6f, $02, $02
	db $02, $02, $02, $02, $cc, $70, $c8, $70, $66, $6e, $67, $6f, $01, $01, $01, $01
	db $02, $02, $da, $70, $d6, $70, $70, $78, $71, $79, $01, $01, $01, $01, $02, $02
	db $e8, $70, $e4, $70, $72, $7a, $73, $7b, $01, $01, $01, $01

Data_0f_70ec:
	db $01, $12, $04, $71, $f2, $70, $fc, $fc, $88, $93, $84, $8c, $fc, $82, $8e, $8c
	db $8f, $8b, $84, $93, $84, $0b, $fc, $fc, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $00, $08, $08

Data_0f_7116:
	db $01, $00, $00, $7e, $0e, $01, $00, $00, $7c, $0e, $01, $00, $00, $7a, $0e, $01
	db $00, $00, $7e, $2e, $01, $00, $00, $7c, $2e

Data_0f_712f:
	db $0c, $00, $00, $00, $0d, $00, $08, $08, $0d, $00, $10, $10, $0d, $10, $00, $02
	db $0d, $10, $08, $0a, $0d, $10, $10, $12, $0d, $20, $00, $04, $0d, $20, $08, $0c
	db $0d, $20, $10, $14, $0d, $30, $00, $06, $0d, $30, $08, $0e, $0d, $30, $10, $16
	db $0d, $0c, $00, $00, $1e, $0c, $00, $08, $18, $0c, $00, $10, $20, $0c, $10, $00
	db $1e, $0c, $10, $08, $1a, $0c, $10, $10, $22, $0c, $20, $00, $1e, $0c, $20, $08
	db $1c, $0c, $20, $10, $24, $0c, $30, $00, $1e, $0c, $30, $08, $1e, $0c, $30, $10
	db $26, $0c, $ff, $7f, $94, $52, $4a, $29, $00, $00, $0d, $09, $00, $00, $14, $22
	db $da, $32, $da, $32, $4a, $29, $52, $4a, $5a, $6b, $12, $01, $63, $0c, $14, $22
	db $da, $32

Data_0f_71b1:
	db $38, $77, $30, $5a, $20, $55, $a0, $34, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_0f_71c9:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $6b, $2d, $5f, $4b, $b5, $01, $63, $0c

Data_0f_71d9:
	db $00, $00, $00, $00, $1d, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_0f_7211:
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $0d, $09, $00, $00, $14, $22, $da, $32
	db $da, $32, $4a, $29, $52, $4a, $5a, $6b, $12, $01, $63, $0c, $14, $22, $da, $32

Data_0f_7231:
	db $00, $00, $bf, $6a, $f7, $55, $50, $41, $00, $00, $c0, $00, $a0, $09, $80, $16
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_0f_7249:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $6b, $2d, $5f, $4b, $b5, $01, $63, $0c

Data_0f_7259:
	db $00, $00, $c0, $00, $a0, $09, $80, $16, $00, $00, $5c, $03, $53, $02, $6c, $01
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_0f_7291:
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $0d, $09, $00, $00, $14, $22, $da, $32
	db $da, $32, $4a, $29, $52, $4a, $5a, $6b, $12, $01, $63, $0c, $14, $22, $da, $32

Data_0f_72b1:
	db $00, $00, $c8, $00, $4d, $09, $f3, $11, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_0f_72c9:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $6b, $2d, $5f, $4b, $b5, $01, $63, $0c

Data_0f_72d9:
	db $00, $00, $3b, $53, $75, $3e, $d0, $29, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_0f_7311:
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $0d, $09, $00, $00, $14, $22, $da, $32
	db $da, $32, $4a, $29, $52, $4a, $5a, $6b, $12, $01, $63, $0c, $14, $22, $da, $32

Data_0f_7331:
	db $a7, $00, $6d, $11, $34, $22, $1b, $33, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_0f_7349:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $6b, $2d, $5f, $4b, $b5, $01, $63, $0c

Data_0f_7359:
	db $00, $00, $de, $7b, $32, $46, $4a, $29, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_0f_7391:
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $0d, $09, $00, $00, $14, $22, $da, $32
	db $da, $32, $4a, $29, $52, $4a, $5a, $6b, $12, $01, $63, $0c, $14, $22, $da, $32

Data_0f_73b1:
	db $08, $1d, $ad, $31, $52, $4a, $18, $63, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_0f_73c9:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $6b, $2d, $5f, $4b, $b5, $01, $63, $0c

Data_0f_73d9:
	db $00, $00, $00, $00, $1d, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_0f_7411:
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $0d, $09, $00, $00, $14, $22, $da, $32
	db $da, $32, $4a, $29, $52, $4a, $5a, $6b, $12, $01, $63, $0c, $14, $22, $da, $32

Data_0f_7431:
	db $00, $00, $ae, $01, $76, $02, $5f, $03, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_0f_7449:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $6b, $2d, $5f, $4b, $b5, $01, $63, $0c

Data_0f_7459:
	db $00, $00, $de, $7b, $32, $46, $80, $4d, $00, $00, $1b, $01, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_0f_7491:
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $0d, $09, $00, $00, $14, $22, $da, $32
	db $da, $32, $4a, $29, $52, $4a, $5a, $6b, $12, $01, $63, $0c, $14, $22, $da, $32

Data_0f_74b1:
	db $00, $00, $7d, $57, $1a, $02, $0f, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_0f_74c9:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $6b, $2d, $5f, $4b, $b5, $01, $63, $0c

Data_0f_74d9:
	db $00, $00, $00, $00, $1d, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00
MonsterPortraitBg_Tiger:  ; 7x7 BG behind the Tiger portrait
	db 7, 7
	dw MonsterPortraitBg_Tiger_Attr
	dw MonsterPortraitBg_Tiger_Idx
MonsterPortraitBg_Tiger_Idx:
	db $80, $88, $90, $98, $a0, $a8, $b0, $81, $89, $91, $99, $a1, $a9, $b1, $82, $8a
	db $92, $9a, $a2, $aa, $b2, $83, $8b, $93, $9b, $a3, $ab, $b3, $84, $8c, $94, $9c
	db $a4, $ac, $b4, $85, $8d, $95, $9d, $a5, $ad, $b5, $86, $8e, $96, $9e, $a6, $ae
	db $b6
MonsterPortraitBg_Tiger_Attr:
	db $00, $00, $00, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $00, $04, $04, $04, $04, $04, $00, $04, $04, $04
	db $04, $04, $04, $00, $04, $04, $04, $04, $04, $04, $00, $04, $04, $00, $04, $04
	db $04
MonsterPortraitBg_Mocchi:  ; 7x7 BG behind the Mocchi portrait
	db 7, 7
	dw MonsterPortraitBg_Mocchi_Attr
	dw MonsterPortraitBg_Mocchi_Idx
MonsterPortraitBg_Mocchi_Idx:
	db $80, $88, $90, $98, $a0, $a8, $b0, $81, $89, $91, $99, $a1, $a9, $b1, $82, $8a
	db $92, $9a, $a2, $aa, $b2, $83, $8b, $93, $9b, $a3, $ab, $b3, $84, $8c, $94, $9c
	db $a4, $ac, $b4, $85, $8d, $95, $9d, $a5, $ad, $b5, $86, $8e, $96, $9e, $a6, $ae
	db $b6
MonsterPortraitBg_Mocchi_Attr:
	db $04, $04, $04, $04, $05, $05, $05, $04, $04, $04, $04, $05, $05, $04, $04, $04
	db $04, $04, $05, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04
MonsterPortraitBg_Hare:  ; 7x7 BG behind the Hare portrait
	db 7, 7
	dw MonsterPortraitBg_Hare_Attr
	dw MonsterPortraitBg_Hare_Idx
MonsterPortraitBg_Hare_Idx:
	db $80, $88, $90, $98, $a0, $a8, $b0, $81, $89, $91, $99, $a1, $a9, $b1, $82, $8a
	db $92, $9a, $a2, $aa, $b2, $83, $8b, $93, $9b, $a3, $ab, $b3, $84, $8c, $94, $9c
	db $a4, $ac, $b4, $85, $8d, $95, $9d, $a5, $ad, $b5, $86, $8e, $96, $9e, $a6, $ae
	db $b6
MonsterPortraitBg_Hare_Attr:
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04
MonsterPortraitBg_Gali:  ; 7x7 BG behind the Gali portrait
	db 7, 7
	dw MonsterPortraitBg_Gali_Attr
	dw MonsterPortraitBg_Gali_Idx
MonsterPortraitBg_Gali_Idx:
	db $80, $88, $90, $98, $a0, $a8, $b0, $81, $89, $91, $99, $a1, $a9, $b1, $82, $8a
	db $92, $9a, $a2, $aa, $b2, $83, $8b, $93, $9b, $a3, $ab, $b3, $84, $8c, $94, $9c
	db $a4, $ac, $b4, $85, $8d, $95, $9d, $a5, $ad, $b5, $86, $8e, $96, $9e, $a6, $ae
	db $b6
MonsterPortraitBg_Gali_Attr:
	db $00, $00, $00, $04, $04, $04, $00, $00, $00, $04, $04, $04, $04, $04, $00, $00
	db $04, $04, $04, $04, $04, $00, $00, $04, $04, $04, $04, $04, $00, $00, $04, $04
	db $04, $04, $04, $00, $04, $04, $04, $04, $04, $04, $00, $04, $04, $04, $04, $04
	db $04
MonsterPortraitBg_Golem:  ; 7x7 BG behind the Golem portrait
	db 7, 7
	dw MonsterPortraitBg_Golem_Attr
	dw MonsterPortraitBg_Golem_Idx
MonsterPortraitBg_Golem_Idx:
	db $80, $88, $90, $98, $a0, $a8, $b0, $81, $89, $91, $99, $a1, $a9, $b1, $82, $8a
	db $92, $9a, $a2, $aa, $b2, $83, $8b, $93, $9b, $a3, $ab, $b3, $84, $8c, $94, $9c
	db $a4, $ac, $b4, $85, $8d, $95, $9d, $a5, $ad, $b5, $86, $8e, $96, $9e, $a6, $ae
	db $b6
MonsterPortraitBg_Golem_Attr:
	db $00, $04, $04, $04, $04, $00, $00, $00, $04, $04, $04, $04, $04, $00, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $00, $04, $04, $04
	db $04, $04, $04, $00, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04
MonsterPortraitBg_Suezo:  ; 7x7 BG behind the Suezo portrait
	db 7, 7
	dw MonsterPortraitBg_Suezo_Attr
	dw MonsterPortraitBg_Suezo_Idx
MonsterPortraitBg_Suezo_Idx:
	db $80, $88, $90, $98, $a0, $a8, $b0, $81, $89, $91, $99, $a1, $a9, $b1, $82, $8a
	db $92, $9a, $a2, $aa, $b2, $83, $8b, $93, $9b, $a3, $ab, $b3, $84, $8c, $94, $9c
	db $a4, $ac, $b4, $85, $8d, $95, $9d, $a5, $ad, $b5, $86, $8e, $96, $9e, $a6, $ae
	db $b6
MonsterPortraitBg_Suezo_Attr:
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04
MonsterPortraitBg_Phoenix:  ; 7x7 BG behind the Phoenix portrait
	db 7, 7
	dw MonsterPortraitBg_Phoenix_Attr
	dw MonsterPortraitBg_Phoenix_Idx
MonsterPortraitBg_Phoenix_Idx:
	db $80, $88, $90, $98, $a0, $a8, $b0, $81, $89, $91, $99, $a1, $a9, $b1, $82, $8a
	db $92, $9a, $a2, $aa, $b2, $83, $8b, $93, $9b, $a3, $ab, $b3, $84, $8c, $94, $9c
	db $a4, $ac, $b4, $85, $8d, $95, $9d, $a5, $ad, $b5, $86, $8e, $96, $9e, $a6, $ae
	db $b6
MonsterPortraitBg_Phoenix_Attr:
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04
	db $0f, $00, $18, $c8, $01, $00, $20, $ce, $01, $08, $00, $b8, $01, $08, $08, $bc
	db $01, $08, $10, $c2, $01, $10, $18, $ca, $01, $18, $00, $ba, $01, $18, $08, $be
	db $01, $18, $10, $c4, $01, $20, $18, $cc, $01, $28, $08, $c0, $01, $28, $10, $c6
	db $01, $28, $20, $d0, $01, $28, $28, $d2, $01, $28, $30, $d4, $01, $05, $00, $18
	db $b8, $01, $08, $28, $be, $01, $08, $30, $c0, $01, $10, $18, $ba, $01, $10, $20
	db $bc, $01, $05, $18, $10, $c2, $02, $18, $18, $c4, $02, $18, $20, $c6, $02, $18
	db $28, $c8, $02, $18, $30, $ca, $02, $0c, $18, $08, $b8, $01, $18, $10, $c0, $01
	db $18, $18, $c8, $01, $18, $20, $d0, $01, $18, $28, $d8, $01, $18, $30, $e0, $01
	db $28, $08, $ba, $01, $28, $10, $c2, $01, $28, $18, $ca, $01, $28, $20, $d2, $01
	db $28, $28, $da, $01, $28, $30, $e2, $01, $0c, $00, $28, $c8, $01, $00, $30, $d0
	db $01, $10, $28, $ca, $01, $10, $30, $d2, $01, $18, $10, $ba, $01, $20, $20, $c2
	db $01, $20, $28, $cc, $01, $20, $30, $d4, $01, $28, $00, $b8, $01, $28, $08, $c0
	db $01, $28, $10, $bc, $01, $28, $18, $be, $01, $09, $00, $18, $e2, $02, $00, $20
	db $e4, $02, $00, $28, $e6, $02, $00, $30, $e8, $02, $08, $10, $da, $02, $18, $10
	db $dc, $02, $28, $00, $d8, $02, $28, $08, $e0, $02, $28, $10, $de, $02, $0a, $00
	db $08, $bc, $01, $00, $10, $c2, $01, $00, $18, $c4, $01, $00, $20, $c6, $01, $08
	db $28, $c8, $01, $10, $00, $b8, $01, $10, $30, $ca, $01, $18, $08, $be, $01, $28
	db $00, $ba, $01, $28, $08, $c0, $01, $0a, $10, $10, $b8, $01, $10, $18, $c0, $01
	db $10, $20, $c8, $01, $10, $28, $d0, $01, $10, $30, $d8, $01, $20, $10, $ba, $01
	db $20, $18, $c2, $01, $20, $20, $ca, $01, $20, $28, $d2, $01, $20, $30, $da, $01

SECTION "analyzed_0c8000", ROMX[$4000], BANK[$32]

; Indexed by wActiveMonster (0-6). BankMapCopyA descriptors (db rows,cols /
; dw attr / dw idx). See docs/monster_detail_screen.md.
MonsterNameMapTable:
	; -> name-plate descriptor, drawn to $9827
	db $03, $6a, $21, $6a, $3f, $6a, $5d, $6a, $7b, $6a, $99, $6a, $b7, $6a
MonsterAbilityMapTable:
	; -> ability-blurb descriptor (18x4), drawn to $99a1
	db $e9, $65, $7f, $66, $15, $67, $ab, $67, $41, $68, $d7, $68, $6d, $69
Data_32_401c:
	db $00, $00, $ff, $7f, $ff, $7f, $ff, $7f, $00, $00, $1f, $00, $1f, $00, $1f, $00
	db $00, $00, $5f, $4b, $b5, $01, $e0, $2c

Func_32_4034:
	ld a, [wDisplayMonster]
	ld hl, wMonsterUses
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, $05
	srl a
	srl a
	srl a
	srl a
	and $0f
	ld [wBcdHigh], a
	ld a, $05
	and $0f
	ld [wBcdLow], a
	call WaitForHBlank
	ld hl, $996a
	ld a, $01
	ld [rVBK], a
	ld [hl], $08
	ld a, $00
	ld [rVBK], a
	ld [hl], $a4
	ld a, [wBcdHigh]
	add a, $9a
	ld c, a
	call WaitForHBlank
	ld hl, $996b
	ld a, $01
	ld [rVBK], a
	ld [hl], $08
	ld a, $00
	ld [rVBK], a
	ld [hl], c
	ld a, [wBcdLow]
	add a, $9a
	ld c, a
	call WaitForHBlank
	ld hl, $996c
	ld a, $01
	ld [rVBK], a
	ld [hl], $08
	ld a, $00
	ld [rVBK], a
	ld [hl], c
	ret

Data_32_409d:
	db $01, $01, $a4, $40, $a3, $40, $a4, $08

ShowMonsterDetailScreen:
	ld a, [wDisplayMonster]
	push af
	ld a, [wActiveMonster]
	ld [wDisplayMonster], a
	call Func_00_083c
	call HideAllSprites
	ld a, $00
	ld [rVBK], a
	ld a, $32
	ld hl, $4613
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld a, $01
	ld [rVBK], a
	ld a, $32
	ld hl, $5e13
	ld de, $9000
	ld bc, $0800
	call BankVramCopy
	ld a, $3b
	ld hl, $48b4
	ld de, $8800
	ld bc, $0800
	call BankVramCopy
	ld hl, $6313
	ld a, $32
	ld de, $9800
	call BankMapCopyA
	ld hl, MonsterNameMapTable
	ld a, [wActiveMonster]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, $32
	ld de, $9827
	call BankMapCopyA
	ld hl, MonsterAbilityMapTable
	ld a, [wActiveMonster]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, $32
	ld de, $99a1
	call BankMapCopyA
	call Func_32_4034
	FAR_CALL $0f, LoadMonsterPortrait
	call DrawMonsterDetailBgMap
	call DrawMonsterDetailSprites
	call Func_32_4205
	ld a, $32
	ld hl, $6293
	ld de, wBgPalettes
	ld bc, $0080
	call BankCopy
	call LoadMonsterPalettes
	xor a
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	call WaitForNextFrame
Func_32_4155:
	call WaitForNextFrame
	call ReadJoypad
	ld c, $00
	call Func_32_431a
	ld c, $01
	call Func_32_431a
	ld c, $02
	call Func_32_431a
	call DrawMonsterDetailSprites
	call HideUnusedOamSprites
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_32_4155
	FAR_CALL $1f, Func_1f_403a
	pop af
	ld [wDisplayMonster], a
	ret
DrawMonsterDetailBgMap:
	ld a, [wMonsterBgMapPtr]
	ld l, a
	ld a, [wMonsterBgMapPtr + 1]
	ld h, a
	or l
	ret z
	ld a, $0f
	ld de, $98a3
	call BankMapCopyA
	ret
DrawMonsterDetailSprites:
	ld a, $0f
	ld [wDrawBank], a
	ld a, [wMonsterMeta1Ptr]
	ld l, a
	ld a, [wMonsterMeta1Ptr + 1]
	ld h, a
	or l
	jr z, Func_32_41ae
	ld c, $20
	ld b, $38
	call DrawMetasprite
Func_32_41ae:
	ld a, [wMonsterMeta2Ptr]
	ld l, a
	ld a, [wMonsterMeta2Ptr + 1]
	ld h, a
	or l
	jr z, Func_32_41c0
	ld c, $20
	ld b, $38
	call DrawMetasprite
Func_32_41c0:
	ret
; LoadMonsterPalettes: for wDisplayMonster, copy its palette block (bank $0f,
; $7191 + $80*id) into wBgPalettes 4-6 and wObjPalettes 1-2. See docs/palettes.md.
LoadMonsterPalettes:
	ld a, [wDisplayMonster]
	cp $ff
	ret z
	add a, a
	ld hl, MonsterPaletteTable
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	push hl
	ld bc, $0020
	add hl, bc
	ld de, wBgPalettes + $20
	ld bc, $0018
	ld a, $0f
	call BankCopy
	pop hl
	push hl
	ld bc, $0048
	add hl, bc
	ld de, wObjPalettes + $8
	ld bc, $0010
	ld a, $0f
	call BankCopy
	pop hl
	ret

MonsterPaletteTable:
	; per-monster -> $80-byte palette block, bank $0f $7191+$80*id
	db $91, $71, $11, $72, $91, $72, $11, $73, $91, $73, $11, $74, $91, $74

Func_32_4205:
	ld hl, MonsterDetailSetupTable
	ld a, [wActiveMonster]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp hl

MonsterDetailSetupTable:
	; per-monster -> a per-monster setup routine (jp hl)
	db $25, $42, $3e, $42, $57, $42, $70, $42, $89, $42, $a2, $42, $bb, $42

Func_32_4225:
	ld c, $00
	ld hl, $43bb
	call Func_32_430a
	ld c, $01
	ld hl, $43cb
	call Func_32_430a
	ld c, $02
	ld hl, $43e3
	call Func_32_430a
	ret
	ld c, $00
	ld hl, $43fb
	call Func_32_430a
	ld c, $01
	ld hl, $0000
	call Func_32_430a
	ld c, $02
	ld hl, $0000
	call Func_32_430a
	ret
	ld c, $00
	ld hl, $4483
	call Func_32_430a
	ld c, $01
	ld hl, $0000
	call Func_32_430a
	ld c, $02
	ld hl, $0000
	call Func_32_430a
	ret
	ld c, $00
	ld hl, $44cb
	call Func_32_430a
	ld c, $01
	ld hl, $456b
	call Func_32_430a
	ld c, $02
	ld hl, $0000
	call Func_32_430a
	ret
	ld c, $00
	ld hl, $457b
	call Func_32_430a
	ld c, $01
	ld hl, $458b
	call Func_32_430a
	ld c, $02
	ld hl, $45a3
	call Func_32_430a
	ret
	ld c, $00
	ld hl, $45bb
	call Func_32_430a
	ld c, $01
	ld hl, $45cb
	call Func_32_430a
	ld c, $02
	ld hl, $45e3
	call Func_32_430a
	ret
	ld c, $00
	ld hl, $45fb
	call Func_32_430a
	ld c, $01
	ld hl, $0000
	call Func_32_430a
	ld c, $02
	ld hl, $0000
	call Func_32_430a
	ret
Func_32_42d4:
	push bc
	sla c
	sla c
	sla c
	ld b, $00
	ld hl, $d6d2
	add hl, bc
	ld a, [hl+]
	ld [$d6cf], a
	ld a, [hl+]
	ld [$d6d0], a
	ld a, [hl+]
	ld [$d6d1], a
	pop bc
	ret
Func_32_42ef:
	push bc
	sla c
	sla c
	sla c
	ld b, $00
	ld hl, $d6d2
	add hl, bc
	ld a, [$d6cf]
	ld [hl+], a
	ld a, [$d6d0]
	ld [hl+], a
	ld a, [$d6d1]
	ld [hl+], a
	pop bc
	ret
Func_32_430a:
	ld a, l
	ld [$d6d0], a
	ld a, h
	ld [$d6d1], a
	inc hl
	ld a, [hl]
	ld [$d6cf], a
	jp Func_32_42ef
Func_32_431a:
	ld a, $32
	ld [wDrawBank], a
	call Func_32_42d4
	push bc
	call Func_32_432a
	pop bc
	jp Func_32_42ef
Func_32_432a:
	ld hl, $d6d0
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	or h
	ret z
	ld a, [$d6cf]
	or a
	jr nz, Func_32_4350
Func_32_4339:
	ld hl, $d6d0
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, $0008
	add hl, bc
	ld a, l
	ld [$d6d0], a
	ld a, h
	ld [$d6d1], a
Func_32_434b:
	inc hl
	ld a, [hl]
	ld [$d6cf], a
Func_32_4350:
	ld hl, $d6d0
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, [hl]
	cp $01
	jp z, Func_32_4370
	cp $02
	jp z, Func_32_4381
	cp $03
	jp z, Func_32_4394
	cp $04
	jp z, Func_32_43a4
Func_32_436b:
	ld hl, $d6cf
	dec [hl]
	ret
Func_32_4370:
	inc hl
	inc hl
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	or h
	call nz, DrawMetasprite
	jp Func_32_436b
Func_32_4381:
	inc hl
	inc hl
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	or h
	ld a, $32
	call nz, BankMapCopyA
	jp Func_32_436b
Func_32_4394:
	inc hl
	inc hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	ld [$d6d0], a
	ld a, h
	ld [$d6d1], a
	jp Func_32_434b
Func_32_43a4:
	inc hl
	inc hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, wObjPalettes
	ld c, $08
Func_32_43ae:
	ld a, [hl+]
	ld [de], a
	inc de
	dec c
	jr nz, Func_32_43ae
	xor a
	ld [hObjPaletteDirty], a
	jp Func_32_4339

Data_32_43bb:
	db $01, $3c, $70, $48, $d5, $6a

SECTION "analyzed_0c83c3", ROMX[$43c3], BANK[$32]

Data_32_43c3:
	db $03, $01, $bb, $43

SECTION "analyzed_0c83cb", ROMX[$43cb], BANK[$32]

Data_32_43cb:
	db $01, $1e, $80, $48, $14, $6b

SECTION "analyzed_0c83d3", ROMX[$43d3], BANK[$32]

Data_32_43d3:
	db $01, $1e, $80, $48, $1d, $6b

SECTION "analyzed_0c83db", ROMX[$43db], BANK[$32]

Data_32_43db:
	db $03, $01, $cb, $43

SECTION "analyzed_0c83e3", ROMX[$43e3], BANK[$32]

Data_32_43e3:
	db $01, $1e, $60, $48, $26, $6b

SECTION "analyzed_0c83eb", ROMX[$43eb], BANK[$32]

Data_32_43eb:
	db $01, $1e, $60, $48, $2f, $6b

SECTION "analyzed_0c83f3", ROMX[$43f3], BANK[$32]

Data_32_43f3:
	db $03, $01, $e3, $43

SECTION "analyzed_0c83fb", ROMX[$43fb], BANK[$32]

Data_32_43fb:
	db $04, $01, $2c, $40

SECTION "analyzed_0c8403", ROMX[$4403], BANK[$32]

Data_32_4403:
	db $01, $03, $70, $48, $e7, $6a

SECTION "analyzed_0c840b", ROMX[$440b], BANK[$32]

Data_32_440b:
	db $04, $01, $1c, $40

SECTION "analyzed_0c8413", ROMX[$4413], BANK[$32]

Data_32_4413:
	db $01, $03, $70, $48, $e7, $6a

SECTION "analyzed_0c841b", ROMX[$441b], BANK[$32]

Data_32_441b:
	db $04, $01, $2c, $40

SECTION "analyzed_0c8423", ROMX[$4423], BANK[$32]

Data_32_4423:
	db $01, $03, $70, $48, $f0, $6a

SECTION "analyzed_0c842b", ROMX[$442b], BANK[$32]

Data_32_442b:
	db $04, $01, $1c, $40

SECTION "analyzed_0c8433", ROMX[$4433], BANK[$32]

Data_32_4433:
	db $01, $03, $70, $48, $f0, $6a

SECTION "analyzed_0c843b", ROMX[$443b], BANK[$32]

Data_32_443b:
	db $04, $01, $2c, $40

SECTION "analyzed_0c8443", ROMX[$4443], BANK[$32]

Data_32_4443:
	db $01, $03, $70, $48, $f9, $6a

SECTION "analyzed_0c844b", ROMX[$444b], BANK[$32]

Data_32_444b:
	db $04, $01, $1c, $40

SECTION "analyzed_0c8453", ROMX[$4453], BANK[$32]

Data_32_4453:
	db $01, $03, $70, $48, $f9, $6a

SECTION "analyzed_0c845b", ROMX[$445b], BANK[$32]

Data_32_445b:
	db $04, $01, $2c, $40

SECTION "analyzed_0c8463", ROMX[$4463], BANK[$32]

Data_32_4463:
	db $01, $03, $70, $48, $02, $6b

SECTION "analyzed_0c846b", ROMX[$446b], BANK[$32]

Data_32_446b:
	db $04, $01, $1c, $40

SECTION "analyzed_0c8473", ROMX[$4473], BANK[$32]

Data_32_4473:
	db $01, $03, $70, $48, $02, $6b

SECTION "analyzed_0c847b", ROMX[$447b], BANK[$32]

Data_32_447b:
	db $03, $01, $fb, $43

SECTION "analyzed_0c8483", ROMX[$4483], BANK[$32]

Data_32_4483:
	db $04, $01, $2c, $40

SECTION "analyzed_0c848b", ROMX[$448b], BANK[$32]

Data_32_448b:
	db $01, $03, $70, $48, $e7, $6a

SECTION "analyzed_0c8493", ROMX[$4493], BANK[$32]

Data_32_4493:
	db $04, $01, $24, $40

SECTION "analyzed_0c849b", ROMX[$449b], BANK[$32]

Data_32_449b:
	db $01, $03, $70, $48, $f0, $6a

SECTION "analyzed_0c84a3", ROMX[$44a3], BANK[$32]

Data_32_44a3:
	db $04, $01, $2c, $40

SECTION "analyzed_0c84ab", ROMX[$44ab], BANK[$32]

Data_32_44ab:
	db $01, $03, $70, $48, $f9, $6a

SECTION "analyzed_0c84b3", ROMX[$44b3], BANK[$32]

Data_32_44b3:
	db $04, $01, $24, $40

SECTION "analyzed_0c84bb", ROMX[$44bb], BANK[$32]

Data_32_44bb:
	db $01, $03, $70, $48, $02, $6b

SECTION "analyzed_0c84c3", ROMX[$44c3], BANK[$32]

Data_32_44c3:
	db $03, $01, $83, $44

SECTION "analyzed_0c84cb", ROMX[$44cb], BANK[$32]

Data_32_44cb:
	db $01, $2d, $70, $48, $d5, $6a

SECTION "analyzed_0c84d3", ROMX[$44d3], BANK[$32]

Data_32_44d3:
	db $01, $04, $70, $48, $de, $6a

SECTION "analyzed_0c84db", ROMX[$44db], BANK[$32]

Data_32_44db:
	db $01, $02, $70, $46, $d5, $6a

SECTION "analyzed_0c84e3", ROMX[$44e3], BANK[$32]

Data_32_44e3:
	db $01, $02, $70, $44, $d5, $6a

SECTION "analyzed_0c84eb", ROMX[$44eb], BANK[$32]

Data_32_44eb:
	db $01, $02, $70, $42, $d5, $6a

SECTION "analyzed_0c84f3", ROMX[$44f3], BANK[$32]

Data_32_44f3:
	db $01, $02, $70, $40, $d5, $6a

SECTION "analyzed_0c84fb", ROMX[$44fb], BANK[$32]

Data_32_44fb:
	db $01, $02, $70, $3e, $d5, $6a

SECTION "analyzed_0c8503", ROMX[$4503], BANK[$32]

Data_32_4503:
	db $01, $02, $70, $3c, $d5, $6a

SECTION "analyzed_0c850b", ROMX[$450b], BANK[$32]

Data_32_450b:
	db $01, $02, $70, $3a, $d5, $6a

SECTION "analyzed_0c8513", ROMX[$4513], BANK[$32]

Data_32_4513:
	db $01, $02, $70, $38, $d5, $6a

SECTION "analyzed_0c851b", ROMX[$451b], BANK[$32]

Data_32_451b:
	db $01, $02, $70, $38, $d5, $6a

SECTION "analyzed_0c8523", ROMX[$4523], BANK[$32]

Data_32_4523:
	db $01, $02, $70, $3a, $d5, $6a

SECTION "analyzed_0c852b", ROMX[$452b], BANK[$32]

Data_32_452b:
	db $01, $02, $70, $3c, $d5, $6a

SECTION "analyzed_0c8533", ROMX[$4533], BANK[$32]

Data_32_4533:
	db $01, $02, $70, $3e, $d5, $6a

SECTION "analyzed_0c853b", ROMX[$453b], BANK[$32]

Data_32_453b:
	db $01, $02, $70, $40, $d5, $6a

SECTION "analyzed_0c8543", ROMX[$4543], BANK[$32]

Data_32_4543:
	db $01, $02, $70, $42, $d5, $6a

SECTION "analyzed_0c854b", ROMX[$454b], BANK[$32]

Data_32_454b:
	db $01, $02, $70, $44, $d5, $6a

SECTION "analyzed_0c8553", ROMX[$4553], BANK[$32]

Data_32_4553:
	db $01, $02, $70, $46, $d5, $6a

SECTION "analyzed_0c855b", ROMX[$455b], BANK[$32]

Data_32_455b:
	db $01, $04, $70, $48, $de, $6a

SECTION "analyzed_0c8563", ROMX[$4563], BANK[$32]

Data_32_4563:
	db $03, $01, $cb, $44

SECTION "analyzed_0c856b", ROMX[$456b], BANK[$32]

Data_32_456b:
	db $01, $1e, $60, $48, $26, $6b

SECTION "analyzed_0c8573", ROMX[$4573], BANK[$32]

Data_32_4573:
	db $03, $01, $6b, $45

SECTION "analyzed_0c857b", ROMX[$457b], BANK[$32]

Data_32_457b:
	db $01, $3c, $78, $48, $d5, $6a

SECTION "analyzed_0c8583", ROMX[$4583], BANK[$32]

Data_32_4583:
	db $03, $01, $7b, $45

SECTION "analyzed_0c858b", ROMX[$458b], BANK[$32]

Data_32_458b:
	db $02, $1e, $ad, $98, $46, $6b

SECTION "analyzed_0c8593", ROMX[$4593], BANK[$32]

Data_32_4593:
	db $02, $1e, $ad, $98, $38, $6b

SECTION "analyzed_0c859b", ROMX[$459b], BANK[$32]

Data_32_459b:
	db $03, $01, $8b, $45

SECTION "analyzed_0c85a3", ROMX[$45a3], BANK[$32]

Data_32_45a3:
	db $02, $1e, $eb, $98, $54, $6b

SECTION "analyzed_0c85ab", ROMX[$45ab], BANK[$32]

Data_32_45ab:
	db $02, $1e, $eb, $98, $38, $6b

SECTION "analyzed_0c85b3", ROMX[$45b3], BANK[$32]

Data_32_45b3:
	db $03, $01, $a3, $45

SECTION "analyzed_0c85bb", ROMX[$45bb], BANK[$32]

Data_32_45bb:
	db $01, $3c, $78, $48, $d5, $6a

SECTION "analyzed_0c85c3", ROMX[$45c3], BANK[$32]

Data_32_45c3:
	db $03, $01, $bb, $45

SECTION "analyzed_0c85cb", ROMX[$45cb], BANK[$32]

Data_32_45cb:
	db $02, $1e, $ad, $98, $62, $6b

SECTION "analyzed_0c85d3", ROMX[$45d3], BANK[$32]

Data_32_45d3:
	db $02, $1e, $ad, $98, $38, $6b

SECTION "analyzed_0c85db", ROMX[$45db], BANK[$32]

Data_32_45db:
	db $03, $01, $cb, $45

SECTION "analyzed_0c85e3", ROMX[$45e3], BANK[$32]

Data_32_45e3:
	db $02, $1e, $eb, $98, $70, $6b

SECTION "analyzed_0c85eb", ROMX[$45eb], BANK[$32]

Data_32_45eb:
	db $02, $1e, $eb, $98, $38, $6b

SECTION "analyzed_0c85f3", ROMX[$45f3], BANK[$32]

Data_32_45f3:
	db $03, $01, $e3, $45

SECTION "analyzed_0c85fb", ROMX[$45fb], BANK[$32]

Data_32_45fb:
	db $01, $3c, $70, $48, $d5, $6a

SECTION "analyzed_0c8603", ROMX[$4603], BANK[$32]

Data_32_4603:
	db $01, $2d, $70, $48, $0b, $6b

SECTION "analyzed_0c860b", ROMX[$460b], BANK[$32]

Data_32_460b:
	db $03, $01, $fb, $45

SECTION "analyzed_0c8613", ROMX[$4613], BANK[$32]

Data_32_4613:
	INCBIN "gfx/raw/Data_32_4613.2bpp", 0, 736

SECTION "analyzed_0c9613", ROMX[$5613], BANK[$32]

; Analyzer mis-split: this and Data_32_5dd3 are inside the single $32:$4613 ($1800)
; monster-detail tile blob that ShowMonsterDetailScreen uploads. See docs/gfx_loaders.md.
Data_32_5613:
	INCBIN "gfx/raw/Data_32_5613.2bpp", 0, 1392

Data_32_5b83:
	db $c8, $f0, $0c, $f0, $82, $fc, $c1, $fe, $01, $fe, $7f, $80, $40, $80, $c0

SECTION "analyzed_0c9dd3", ROMX[$5dd3], BANK[$32]

Data_32_5dd3:
	INCBIN "gfx/raw/Data_32_5dd3.2bpp", 0, 2112

Data_32_6613:
	db $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c
	db $7c, $7c, $04, $27, $1e, $26, $22, $1e, $2c, $7c, $2f, $1a, $27, $22, $2c, $21
	db $34, $7c, $7c, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $12, $cd, $66
	db $85, $66, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c
	db $7c, $7c, $7c, $7c, $0f, $2b, $1e, $2c, $2c, $7c, $12, $1e, $25, $1e, $1c, $2d
	db $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c
	db $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $2d, $28, $7c, $1b, $1e, $7c, $22, $27
	db $2f, $22, $27, $1c, $22, $1b, $25, $1e, $34, $7c, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $04, $12, $63, $67, $1b, $67, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c
	db $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $0f, $2b, $1e, $2c, $2c, $7c
	db $12, $1e, $25, $1e, $1c, $2d, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c
	db $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $2d, $28
	db $7c, $1d, $28, $2e, $1b, $25, $1e, $7c, $2c, $29, $1e, $1e, $1d, $34, $7c, $7c
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $04, $12, $f9, $67, $b1, $67, $7c, $7c
	db $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c
	db $0f, $2b, $1e, $2c, $2c, $7c, $12, $1e, $25, $1e, $1c, $2d, $7c, $7c, $7c, $7c
	db $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c
	db $7c, $7c, $7c, $7c, $12, $2d, $28, $29, $2c, $7c, $2c, $2d, $1a, $20, $1e, $7c
	db $2d, $22, $26, $1e, $34, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $12
	db $8f, $68, $47, $68, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c
	db $7c, $7c, $7c, $7c, $7c, $7c, $0f, $2b, $1e, $2c, $2c, $7c, $12, $1e, $25, $1e
	db $1c, $2d, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c
	db $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $2d, $28, $7c, $1b, $2b, $1e
	db $1a, $24, $7c, $1b, $25, $28, $1c, $24, $2c, $34, $7c, $7c, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $04, $12, $25, $69, $dd, $68, $7c, $7c, $7c, $7c, $7c, $7c
	db $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $0f, $2b, $1e, $2c
	db $2c, $7c, $12, $1e, $25, $1e, $1c, $2d, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c
	db $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c
	db $12, $1e, $1e, $7c, $21, $22, $1d, $1d, $1e, $27, $7c, $22, $2d, $1e, $26, $2c
	db $34, $7c, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $12, $bb, $69, $73, $69
	db $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c
	db $7c, $7c, $13, $1a, $24, $1e, $7c, $22, $2d, $7c, $1a, $25, $28, $27, $20, $7c
	db $2d, $28, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c, $7c
	db $7c, $7c, $7c, $7c, $7c, $7c, $2c, $1a, $2f, $1e, $7c, $32, $28, $2e, $2b, $7c
	db $25, $22, $1f, $1e, $34, $7c, $7c, $7c, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $02, $06, $15, $6a, $09, $6a, $00, $02, $04, $06, $08, $0a, $01, $03, $05, $07
	db $09, $0b, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $02, $06
	db $33, $6a, $27, $6a, $0c, $0e, $10, $12, $14, $16, $0d, $0f, $11, $13, $15, $17
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $02, $06, $51, $6a
	db $45, $6a, $00, $18, $1a, $1c, $1e, $0a, $01, $19, $1b, $1d, $1f, $0b, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $02, $06, $6f, $6a, $63, $6a
	db $00, $20, $22, $24, $26, $0a, $01, $21, $23, $25, $27, $0b, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $09, $09, $02, $06, $8d, $6a, $81, $6a, $28, $2a
	db $2c, $2e, $30, $32, $29, $2b, $2d, $2f, $31, $33, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $02, $06, $ab, $6a, $9f, $6a, $00, $34, $36, $38
	db $3a, $0a, $01, $35, $37, $39, $3b, $0b, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $02, $06, $c9, $6a, $bd, $6a, $3c, $3e, $40, $42, $44, $46
	db $3d, $3f, $41, $43, $45, $47, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $02, $00, $00, $00, $00, $00, $08, $08, $00, $02, $00, $00, $02, $00
	db $00, $08, $0a, $00, $02, $00, $00, $04, $00, $00, $08, $0c, $00, $02, $00, $00
	db $06, $00, $00, $08, $0e, $00, $02, $00, $00, $10, $00, $00, $08, $18, $00, $02
	db $00, $00, $12, $00, $00, $08, $1a, $00, $02, $00, $00, $14, $00, $00, $08, $1c
	db $00, $02, $00, $00, $16, $03, $00, $08, $1e, $03, $02, $00, $00, $20, $03, $00
	db $08, $28, $03, $02, $00, $00, $22, $04, $00, $08, $2a, $04, $02, $00, $00, $24
	db $04, $00, $08, $2c, $04, $02, $02, $42, $6b, $3e, $6b, $7c, $7c, $7c, $7c, $00
	db $00, $00, $00, $02, $02, $50, $6b, $4c, $6b, $4a, $52, $4b, $53, $01, $01, $01
	db $01, $02, $02, $5e, $6b, $5a, $6b, $48, $50, $49, $51, $02, $02, $02, $02, $02
	db $02, $6c, $6b, $68, $6b, $4c, $54, $4d, $55, $03, $03, $03, $03, $02, $02, $7a
	db $6b, $76, $6b, $4e, $56, $4f, $57, $03, $03, $03, $03

SECTION "analyzed_0ec000", ROMX[$4000], BANK[$3b]

Func_3b_4000:
	xor a
	ld [rVBK], a
	ld hl, $4034
	ld de, $9000
	ld bc, $0800
	call VramCopy16
	ld a, $01
	ld [rVBK], a
	ld hl, $4834
	ld de, $8780
	ld bc, $0c00
	call VramCopy16
	ret

Data_3b_4022:
	db $3e, $01, $ea, $4f, $ff, $21, $b4, $54, $11, $00, $80, $01, $80, $02, $cd, $94
	db $03, $c9

Data_3b_4034:
	INCBIN "gfx/raw/Data_3b_4034.2bpp", 0, 5120

Data_3b_5434:
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $fc, $ff, $ff, $fc
	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $ff, $fc, $fc, $ff
	db $ff, $fc, $ff, $fc, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $03, $03, $07, $07, $07, $07, $0f, $0f
	db $0f, $0f, $0f, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f
	db $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f
	db $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f
	db $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f
	db $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f
	db $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f
	db $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $e0, $ff, $80, $ff
	db $03, $ff, $07, $fb, $0e, $f1, $0c, $f3, $0c, $f3, $0c, $f3, $0c, $f3, $0c, $f3
	db $0c, $f3, $0c, $f3, $0c, $f3, $06, $f9, $03, $fc, $01, $fe, $00, $ff, $00, $ff
	db $00, $ff, $05, $fa, $16, $e9, $1c, $e3, $34, $cb, $14, $eb, $40, $bf, $81, $7e
	db $40, $bf, $93, $6c, $24, $db, $00, $ff, $01, $fe, $00, $ff, $01, $fe, $00, $ff
	db $13, $ec, $24, $db, $00, $ff, $01, $fe, $00, $ff, $03, $fc, $14, $eb, $24, $db
	db $04, $fb, $1e, $e1, $00, $ff, $00, $ff, $30, $cf, $09, $f6, $06, $f9, $04, $fb
	db $00, $ff, $08, $f7, $0a, $f5, $0c, $f3, $18, $e7, $28, $d7, $09, $f6, $00, $ff
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $00, $ff, $00, $ff
	db $ff, $ff, $ff, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $80, $7f, $c0, $3f, $60, $9f
	db $30, $cf, $18, $e7, $4c, $b3, $4c, $b3, $4c, $b3, $8c, $73, $0c, $f3, $8c, $73
	db $0c, $f3, $8c, $73, $4c, $b3, $0c, $f3, $8c, $73, $0c, $f3, $8c, $73, $0c, $f3
	db $8c, $73, $4c, $b3, $0c, $f3, $8c, $73, $0c, $f3, $0c, $f3, $8c, $73, $4c, $b3
	db $4c, $b3, $4c, $b3, $0c, $f3, $0c, $f3, $cc, $33, $0c, $f3, $0c, $f3, $0c, $f3
	db $0c, $f3, $0c, $f3, $4c, $b3, $4c, $b3, $4c, $b3, $4c, $b3, $8c, $73, $0c, $f3
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $01, $01, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03
	db $03, $03, $02, $03, $03, $03, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $d0, $ff, $a0, $ff, $c1, $fe, $a2, $fd, $45, $fa, $83, $fc
	db $45, $fa, $8b, $f4, $07, $f8, $8b, $f4, $17, $e8, $0f, $70, $17, $28, $0f, $10
	db $07, $08, $07, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00
	db $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00
	db $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00
	db $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00
	db $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03

