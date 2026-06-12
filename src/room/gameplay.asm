; Tower in-room gameplay: stairs, pickups/item effects, floor timers, monster transforms, key unlock, summon (drives the bank-$03 entity engine)
; Carved out of analyzed.asm (byte-exact: section names + placement unchanged).

INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "scene.inc"
INCLUDE "sound_ids.inc"

SECTION "analyzed_0042c9", ROMX[$42c9], BANK[$01]

Data_01_42c9:
	db $40, $00, $80, $00, $c0, $00, $00, $01

Data_01_42d1:
	db $40, $01, $80, $01, $c0, $01, $00, $02

Func_01_42d9:
	call Func_01_42b3
	push hl
	ld de, $0011
	add hl, de
	ld a, c
	ld [hl+], a
	ld [hl], b
	pop hl
	ret
Func_01_42e6:
	ld a, [wActiveFloor]
	dec a
	add a, a
	ld hl, $4335
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
Func_01_42f2:
	ld a, [hl]
	or a
	ret z
	push hl
	inc hl
	push af
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a
	ld a, [hl+]
	ld [$cf81], a
	ld a, [hl+]
	ld [$cf82], a
	ld a, [hl]
	ld [$cf83], a
	pop af
	ld bc, $0000
	ld [wBankCallTmp], a
	ld a, h
	ld [wSpawnPtr], a
	ld a, l
	ld [wSpawnPtr+1], a
	ld a, $03
	ld hl, $4593
	call Func_00_0467
	xor a
	ld [$cf80], a
	call Func_01_40c6
	call Func_01_40da
	call Func_01_40e7
	call Func_01_4124
	pop hl
	ld a, $06
	rst AddAToHL
	jr Func_01_42f2

Data_01_4335:
	db $3f, $43, $46, $43, $59, $43, $7e, $43, $97, $43, $50, $60, $37, $22, $01, $01
	db $00, $51, $a4, $47, $22, $01, $05, $60, $20, $10, $22, $03, $00, $61, $e0, $10
	db $22, $03, $00, $00, $52, $58, $37, $22, $00, $01, $62, $10, $40, $22, $00, $00
	db $62, $a0, $40, $22, $00, $00, $62, $10, $70, $22, $00, $00, $62, $a0, $70, $22
	db $00, $00, $62, $80, $a0, $22, $00, $00, $00, $53, $d0, $2f, $22, $00, $05, $54
	db $e8, $87, $22, $02, $00, $63, $38, $18, $22, $02, $00, $63, $88, $18, $22, $02
	db $00, $00, $55, $80, $47, $22, $00, $05, $00

Func_01_439e:
	FAR_CALL Func_05_46f0
	call Func_01_5cbe
	call Func_01_49cb
	call Func_00_083c
	FAR_CALL Func_05_4884
	call LoadFloorByMode
	FAR_CALL SpecialScene_SelectIndex
	call FloorPostLoadCleanup
	FAR_CALL Func_05_4931
	xor a
	call Func_01_5bd8
	call Func_01_75ad
	call SpawnFloorEntities
	call Func_01_4a71
	FAR_CALL Func_05_48a5
	FAR_CALL UpdateEntities
	call Func_01_4c57
	ld a, [$c289]
	ldh [rSCY], a
	ld a, [$c28a]
	ldh [rSCX], a
	FAR_CALL Func_05_48fc
	call Func_00_0786
	xor a
	ldh [hJoyHeld], a
	ldh [hJoyPressed], a
	ld c, $03
	call StartRoomAnimation
	call Func_00_0d41
	call Func_00_04bc
Func_01_4412:
	call WaitForNextFrame
	call ReadJoypad
	ld a, [wProgressFlags]
	bit 7, a
	jr nz, Func_01_447f
	bit 5, a
	jr nz, Func_01_444a
	call Func_01_5866
	call Func_01_4bae
	FAR_CALL UpdateEntities
	ld a, [$c2db]
	cp $04
	jr z, Func_01_446b
	or a
	jr nz, Func_01_444a
	call Func_01_5e8b
	call Func_01_675c
	call Func_01_6b6e
	call Func_01_68ca
	call Func_01_6a3e
Func_01_444a:
	call Func_01_4c57
	ld a, [$c2d8]
	and $f0
	jr z, Func_01_4458
	cp $10
	jr nz, Func_01_446b
Func_01_4458:
	call Func_01_4dd9
	FAR_CALL EntityAnim_ResetState
	FAR_CALL RefreshEntitySprites
Func_01_446b:
	FAR_CALL Func_0f_4000
	call Func_01_75f6
	call Func_01_775b
	call HideUnusedOamSprites
	jp Func_01_4412
Func_01_447f:
	call Func_00_07e4
	call Func_00_0e24
	call Func_00_04c4
	call HideAllSprites
	call WaitForNextFrame
	call ResetScrollState
	call Func_01_459a
	FAR_CALL Func_05_473d
	ret
Func_01_449d:
	ld a, [$c2e6]
	cp $02
	ret z
	or a
	jr z, Func_01_44bd
	ld a, [wRoomType]
	cp $02
	jr z, Func_01_44b5
	push af
	ld a, SOUND_BGM_2a
	call PlaySoundTracked
	pop af
	ret
Func_01_44b5:
	push af
	ld a, SOUND_BGM_2d
	call PlaySoundTracked
	pop af
	ret
Func_01_44bd:
	ld a, [wRoomType]
	cp $02
	jr z, Func_01_44d0
	cp $06
	jr z, Func_01_44e7
	push af
	ld a, SOUND_BGM_Room
	call PlaySoundTracked
	pop af
	ret
Func_01_44d0:
	ld a, [wActiveFloor]
	cp $05
	jr z, Func_01_44df
	push af
	ld a, SOUND_BGM_2c
	call PlaySoundTracked
	pop af
	ret
Func_01_44df:
	push af
	ld a, SOUND_BGM_2e
	call PlaySoundTracked
	pop af
	ret
Func_01_44e7:
	push af
	ld a, SOUND_BGM_2b
	call PlaySoundTracked
	pop af
	ret
Func_01_44ef:
	ld a, [$c2e6]
	cp $02
	ret z
	ld a, [$c2e6]
	or a
	jr z, Func_01_4515
	ld a, [wRoomType]
	cp $02
	ret z
	ld a, [wFloorTimer+2]
	or a
	jr nz, Func_01_450d
	ld a, [wFloorTimer+1]
	cp $20
	ret c
Func_01_450d:
	call Func_01_4543
	xor a
	ld [$c2e6], a
	ret
Func_01_4515:
	ld a, [wRoomType]
	cp $02
	jr z, Func_01_4530
	ld a, [wFloorTimer+2]
	or a
	ret nz
	ld a, [wFloorTimer+1]
	cp $20
	ret nc
	call Func_01_455a
	ld a, $01
	ld [$c2e6], a
	ret
Func_01_4530:
	ld a, [$c2c5]
	cp $01
	ret nz
	push af
	ld a, SOUND_BGM_2d
	call PlaySoundTracked
	pop af
	ld a, $01
	ld [$c2e6], a
	ret
Func_01_4543:
	ld a, [wRoomType]
	cp $06
	jr z, Func_01_4552
	push af
	ld a, SOUND_BGM_Room
	call PlaySoundTracked
	pop af
	ret

Func_01_4552:
	push af
	ld a, SOUND_BGM_2b
	call PlaySoundTracked
	pop af
	ret

Func_01_455a:
	push af
	ld a, SOUND_BGM_2a
	call PlaySoundTracked
	pop af
	ret
Func_01_4562:
	ld a, [wPlayerStatus]
	bit 0, a
	ret nz
	ld a, [wRoomType]
	cp $02
	jr z, Func_01_4596
	ld a, [$c2e2]
	cp $03
	ret z
	ld a, [wTimeMultiplier]
	ld c, a
	ld hl, wFloorTimer
	ld a, [hl]
	sub c
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
	jr z, Func_01_4596

Func_01_458e:
	xor a
	ld [hl-], a
	ld [hl-], a
	ld [hl], a
	call Func_01_4b0e
	ret

Func_01_4596:
	call Func_01_44ef
	ret
Func_01_459a:
	ld a, [wProgressFlags]
	res 0, a
	ld [wProgressFlags], a
	ld a, [wRoomType]
	cp $05
	jr nz, Func_01_45ad
	call Func_00_1219
	ret
Func_01_45ad:
	ld a, [wRoomType]
	cp $02
	jr z, Func_01_45cf
	ld a, [wTransitionState]
	cp $01
	jr nz, Func_01_45d2
	FAR_CALL Func_05_481d
	call Func_01_4b7c
	call Func_01_45d6
	ld a, SCENE_ROOM_CLEAR
	ld [wGameScene], a
	ret
Func_01_45cf:
	call Func_01_5c28
Func_01_45d2:
	call Func_01_4654
	ret
Func_01_45d6:
	ld a, [wRoomType]
	cp $00
	ret nz
	call Func_01_5c7c
	cp $01
	jr z, Func_01_45f6
	ld a, [wActiveFloor]
	cp $3c
	ret z
	inc a
	ld [wCFF0], a
	ld a, $00
	ld [$cff1], a
	call Func_01_4987
	ret
Func_01_45f6:
	ld a, [wActiveFloor]
	cp $0a
	jr z, Func_01_460e
	cp $14
	jr z, Func_01_461c
	cp $28
	jr z, Func_01_462a
	cp $32
	jr z, Func_01_4638
	cp $3c
	jr z, Func_01_4646

SECTION "analyzed_00460d", ROMX[$460d], BANK[$01]

Data_01_460d:
	db $c9

SECTION "analyzed_00460e", ROMX[$460e], BANK[$01]

Func_01_460e:
	ld a, $01
	ld [wCFF0], a
	ld a, $02
	ld [$cff1], a
	call Func_01_4987
	ret
Func_01_461c:
	ld a, $02
	ld [wCFF0], a
	ld a, $02
	ld [$cff1], a
	call Func_01_4987
	ret
Func_01_462a:
	ld a, $03
	ld [wCFF0], a
	ld a, $02
	ld [$cff1], a
	call Func_01_4987
	ret
Func_01_4638:
	ld a, $04
	ld [wCFF0], a
	ld a, $02
	ld [$cff1], a
	call Func_01_4987
	ret
Func_01_4646:
	ld a, $05
	ld [wCFF0], a
	ld a, $02
	ld [$cff1], a
	call Func_01_4987
	ret
Func_01_4654:
	ld a, [wRoomType]
	cp $06
	jr z, Func_01_4698
	cp $02
	jr nz, Func_01_46a0
	ld a, [wTransitionState]
	cp $02
	jp z, Func_01_478d
	cp $00
	jp z, Func_01_478d
	call Func_01_48e9
	call Func_01_4937
	ld a, [wActiveFloor]
	cp $3c
	jr nz, Func_01_46d5
Func_01_4679:
	xor a
	ld [wCFF0], a
	ld a, $00
	ld [$cff1], a
	call Func_01_4987
	ld a, $01
	ld [wC2D7], a
	FAR_CALL Naji_RunEncounter
	ld a, SCENE_TOWN
	ld [wGameScene], a
	ret
Func_01_4698:
	ld a, [$c2c2]
	ld [wRoomType], a
	jr Func_01_46c8
Func_01_46a0:
	ld a, [wTransitionState]
	cp $02
	jp z, Func_01_4782
	cp $00
	jp z, Func_01_4782
	ld a, [wProgressFlags]
	bit 3, a
	jr z, Func_01_46c8
	ld a, [wRoomType]
	ld [$c2c2], a
	ld a, $06
	ld [wRoomType], a
	call Func_00_1219
	ld a, SCENE_ROOM_START
	ld [wGameScene], a
	ret
Func_01_46c8:
	call Func_01_5c7c
	cp $01
	jp z, Func_01_476d
	cp $02
	jp z, Func_01_4759
Func_01_46d5:
	ld a, [wRoomType]
	cp $00
	jr z, Func_01_46e6
	cp $01
	jr z, Func_01_46f8

Data_01_46e0:
	db $fe, $06, $28, $02, $18, $62

Func_01_46e6:
	ld a, $09
	call Func_00_119a
	or a
	jr z, Func_01_4748
	ld a, [wActiveFloor]
	cp $3c
	jp z, Func_01_4679
	jr Func_01_4748
Func_01_46f8:
	ld a, [wActiveFloor]
	cp $0a
	jr z, Func_01_470d
	ld c, a
	ld a, [wSilverKeys]
	cp c
	jr nz, Func_01_4748

Data_01_4706:
	db $3e, $02, $ea, $d7, $c2, $18, $2d

Func_01_470d:
	ld a, $03
	ld [wC2D7], a
	ld a, $0e
	call Func_00_119a
	or a
	jr nz, Func_01_473a
	FAR_CALL Func_13_4000
	FAR_CALL SetTrioNpcState
	ld a, $0e
	call Func_00_1164
	ld a, $03
	ld [wGameSceneArg], a
	ld a, SCENE_TOWN
	ld [wGameScene], a
	ret

Func_01_473a:
	FAR_CALL Naji_RunEncounter
	ld a, SCENE_TOWN
	ld [wGameScene], a
	ret

Func_01_4748:
	FAR_CALL Func_05_4800
	call Func_00_1219
	ld a, SCENE_NEXT_ROOM
	ld [wGameScene], a
	ret
Func_01_4759:
	call Func_01_5d77
	FAR_CALL Func_05_4800
	call Func_00_1219
	ld a, SCENE_NEXT_ROOM
	ld [wGameScene], a
	ret
Func_01_476d:
	ld a, $09
	call Func_00_119a
	or a
	jp nz, Func_01_46d5
	call Func_01_48af
	call Func_00_1219
	ld a, SCENE_ROOM
	ld [wGameScene], a
	ret
Func_01_4782:
	call Func_01_479e
	jr z, Func_01_4798
	ld a, SCENE_ROOM_START
	ld [wGameScene], a
	ret
Func_01_478d:
	call Func_01_479e
	jr z, Func_01_4798
	ld a, SCENE_ROOM
	ld [wGameScene], a
	ret
Func_01_4798:
	ld a, SCENE_TOWER
	ld [wGameScene], a
	ret
Func_01_479e:
	ld a, [wLives]
	sub $01
	daa
	ld [wLives], a
	or a
	ret
GrantSilverKey:
	call Func_01_47bc
	cp $ff
	ret z
	or a
	ret nz
	ld a, [wSilverKeys]
	inc a
	ld [wSilverKeys], a
	call Func_01_4833
	ret
Func_01_47bc:
	ld a, [wRoomType]
	cp $02
	jr z, Func_01_47f0
	cp $00
	ret nz
	ld a, [wActiveFloor]
	cp $03
	jr z, Func_01_47fd
	cp $09
	jr z, Func_01_4803
	cp $0f
	jr z, Func_01_4809
	cp $18
	jr z, Func_01_480f
	cp $1d
	jr z, Func_01_4815
	cp $24
	jr z, Func_01_481b
	cp $2b
	jr z, Func_01_4821
	cp $2f
	jr z, Func_01_4827
	cp $35
	jr z, Func_01_482d
Func_01_47ed:
	ld a, $ff
	ret
Func_01_47f0:
	ld a, [wActiveFloor]
	cp $05
	jr nz, Func_01_47ed
	ld a, $10
	call Func_00_119a
	ret
Func_01_47fd:
	ld a, $11
	call Func_00_119a
	ret
Func_01_4803:
	ld a, $12
	call Func_00_119a
	ret
Func_01_4809:
	ld a, $13
	call Func_00_119a
	ret
Func_01_480f:
	ld a, $14
	call Func_00_119a
	ret
Func_01_4815:
	ld a, $15
	call Func_00_119a
	ret

Func_01_481b:
	ld a, $16
	call Func_00_119a
	ret
Func_01_4821:
	ld a, $17
	call Func_00_119a
	ret
Func_01_4827:
	ld a, $18
	call Func_00_119a
	ret

Func_01_482d:
	ld a, $19
	call Func_00_119a
	ret
Func_01_4833:
	ld a, [wRoomType]
	cp $02
	jr z, Func_01_486d
	cp $00
	jr z, Func_01_4849

Data_01_483e:
	db $fe, $01, $c0, $fa, $c0, $c2, $fe, $35, $28, $61, $c9

Func_01_4849:
	ld a, [wActiveFloor]
	cp $03
	jr z, Func_01_4879
	cp $09
	jr z, Func_01_487f
	cp $0f
	jr z, Func_01_4885
	cp $18
	jr z, Func_01_488b
	cp $1d
	jr z, Func_01_4891
	cp $24
	jr z, Func_01_4897
	cp $2b
	jr z, Func_01_489d
	cp $2f
	jr z, Func_01_48a3
	ret
Func_01_486d:
	ld a, [wActiveFloor]
	cp $05
	ret nz
	ld a, $10
	call Func_00_1164
	ret
Func_01_4879:
	ld a, $11
	call Func_00_1164
	ret
Func_01_487f:
	ld a, $12
	call Func_00_1164
	ret
Func_01_4885:
	ld a, $13
	call Func_00_1164
	ret
Func_01_488b:
	ld a, $14
	call Func_00_1164
	ret
Func_01_4891:
	ld a, $15
	call Func_00_1164
	ret

Func_01_4897:
	ld a, $16
	call Func_00_1164
	ret
Func_01_489d:
	ld a, $17
	call Func_00_1164
	ret
Func_01_48a3:
	ld a, $18
	call Func_00_1164
	ret
	ld a, $19
	call Func_00_1164
	ret

Func_01_48af:
	ld a, $02
	ld [wRoomType], a
	ld a, [wActiveFloor]
	cp $0a
	jr z, Func_01_48cb
	cp $14
	jr z, Func_01_48d1
	cp $28
	jr z, Func_01_48d7
	cp $32
	jr z, Func_01_48dd
	cp $3c
	jr z, Func_01_48e3
Func_01_48cb:
	ld a, $01
	ld [wActiveFloor], a
	ret
Func_01_48d1:
	ld a, $02
	ld [wActiveFloor], a
	ret
Func_01_48d7:
	ld a, $03
	ld [wActiveFloor], a
	ret
Func_01_48dd:
	ld a, $04
	ld [wActiveFloor], a
	ret
Func_01_48e3:
	ld a, $05
	ld [wActiveFloor], a
	ret
Func_01_48e9:
	ld a, [wActiveFloor]
	cp $01
	jr z, Func_01_4900
	cp $02
	jr z, Func_01_490b
	cp $03
	jr z, Func_01_4916
	cp $04
	jr z, Func_01_4921
	cp $05
	jr z, Func_01_492c
Func_01_4900:
	ld a, $0a
	ld [wActiveFloor], a
	ld a, $00
	ld [wRoomType], a
	ret
Func_01_490b:
	ld a, $14
	ld [wActiveFloor], a
	ld a, $00
	ld [wRoomType], a
	ret
Func_01_4916:
	ld a, $28
	ld [wActiveFloor], a
	ld a, $00
	ld [wRoomType], a
	ret
Func_01_4921:
	ld a, $32
	ld [wActiveFloor], a
	ld a, $00
	ld [wRoomType], a
	ret
Func_01_492c:
	ld a, $3c
	ld [wActiveFloor], a
	ld a, $00
	ld [wRoomType], a
	ret
Func_01_4937:
	ld hl, $cfe9
	ld a, [wActiveFloor]
	cp $0a
	jr z, Func_01_4952
	cp $14
	jr z, Func_01_4958
	cp $28
	jr z, Func_01_495e
	cp $32
	jr z, Func_01_4964
	cp $3c
	jr z, Func_01_496a

SECTION "analyzed_004951", ROMX[$4951], BANK[$01]

Data_01_4951:
	db $c9

SECTION "analyzed_004952", ROMX[$4952], BANK[$01]

Func_01_4952:
	ld a, $01
	call Func_00_1164
	ret
Func_01_4958:
	ld a, $03
	call Func_00_1164
	ret
Func_01_495e:
	ld a, $05
	call Func_00_1164
	ret
Func_01_4964:
	ld a, $07
	call Func_00_1164
	ret
Func_01_496a:
	ld a, $09
	call Func_00_1164
	ret
Func_01_4970:
	ld a, [wRoomType]
	cp $00
	jr z, Func_01_497a
	cp $02
	ret nz
Func_01_497a:
	ld [$cff1], a
	ld a, [wActiveFloor]
	ld [wCFF0], a
	call Func_01_4987
	ret
Func_01_4987:
	ld a, [$cff1]
	cp $02
	jr z, Func_01_4995
	ld a, [wCFF0]
	ld [wCurrentFloor], a
	ret
Func_01_4995:
	ld a, [wCFF0]
	cp $01
	jr z, Func_01_49ad
	cp $02
	jr z, Func_01_49b3
	cp $03
	jr z, Func_01_49b9
	cp $04
	jr z, Func_01_49bf
	cp $05
	jr z, Func_01_49c5

SECTION "analyzed_0049ac", ROMX[$49ac], BANK[$01]

Data_01_49ac:
	db $c9

SECTION "analyzed_0049ad", ROMX[$49ad], BANK[$01]

Func_01_49ad:
	ld a, $0a
	ld [wCurrentFloor], a
	ret
Func_01_49b3:
	ld a, $14
	ld [wCurrentFloor], a
	ret
Func_01_49b9:
	ld a, $28
	ld [wCurrentFloor], a
	ret
Func_01_49bf:
	ld a, $32
	ld [wCurrentFloor], a
	ret
Func_01_49c5:
	ld a, $3c
	ld [wCurrentFloor], a
	ret
Func_01_49cb:
	call HideAllSprites
	ld a, [wProgressFlags]
	bit 0, a
	jr nz, Func_01_49e0
	res 3, a
	res 4, a
	res 5, a
	res 7, a
	ld [wProgressFlags], a
Func_01_49e0:
	call Func_01_4970
	xor a
	ld [$c2e6], a
	ld [wTransitionState], a
	ld [$c2d8], a
	ld [$c2d0], a
	ld [$c2e2], a
	ld [$c2e3], a
	ld [$c2df], a
	ld [$c2e0], a
	ld [$c2e1], a
	ld [$c2e5], a
	ld [$cf7f], a
	ld a, $00
	ld [wC2D7], a
	ld hl, $cf77
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
	call Func_01_4a3b
	call Func_01_4a4e
	ld c, $00
	call StartRoomAnimation
	xor a
	ldh [rSCX], a
	ldh [rSCY], a
	ld [$c289], a
	ld [$c28a], a
	ld a, $08
	ldh [hSpriteOriginX], a
	ld a, $10
	ldh [hSpriteOriginY], a
	ld a, $07
	ldh [rWX], a
	xor a
	ldh [rWY], a
	ret
Func_01_4a3b:
	ld a, [wRoomType]
	cp $02
	jr z, Func_01_4a48
	ld a, $01
	ld [$c2c5], a
	ret
Func_01_4a48:
	ld a, $03
	ld [$c2c5], a
	ret
Func_01_4a4e:
	ld a, $01
	ld [wTimeMultiplier], a
	ld hl, wFloorTimer
	ld a, [wRoomType]
	cp $06
	jr z, Func_01_4a67
	ld a, $00
	ld [hl+], a
	ld a, $90
	ld [hl+], a
	ld a, $00
	ld [hl], a
	ret
Func_01_4a67:
	ld a, $00
	ld [hl+], a
	ld a, $70
	ld [hl+], a
	ld a, $00
	ld [hl], a
	ret
Func_01_4a71:
	ld hl, $c7f9
	ld c, $1c
Func_01_4a76:
	ld a, [hl]
	cp $60
	jr z, Func_01_4a91
	cp $61
	jr z, Func_01_4a91
	cp $62
	jr z, Func_01_4a91
	cp $63
	jr z, Func_01_4a91
	push hl
	ld de, $0006
	add hl, de
	set 6, [hl]
	pop hl
	jr Func_01_4a99
Func_01_4a91:
	push hl
	ld de, $0006
	add hl, de
	res 6, [hl]
	pop hl
Func_01_4a99:
	ld de, $002a
	add hl, de
	dec c
	jr nz, Func_01_4a76
	ret
Func_01_4aa1:
	ld hl, $c7f9
	ld c, $1c
Func_01_4aa6:
	push hl
	ld de, $0006
	add hl, de
	res 6, [hl]
	pop hl
	ld de, $002a
	add hl, de
	dec c
	jr nz, Func_01_4aa6
	ret
Func_01_4ab6:
	ld a, [$c2df]
	or a
	ret nz
	ld a, [$c2c5]
	or a
	ret z
	dec a
	ld [$c2c5], a
	jr nz, Func_01_4af4
	ld a, [wDisplayMonster]
	cp $06
	jr nz, Func_01_4b07
	ld hl, wMonsterUses
	rst AddAToHL
	ld a, [hl]
	or a
	jr z, Func_01_4b07
	sub $01
	daa
	ld [hl], a
	or a
	jr nz, Func_01_4ae1
	ld a, $ff
	ld [wDisplayMonster], a
Func_01_4ae1:
	ld a, $06
	ld [wSceneState], a
	ld c, $04
	call StartRoomAnimation
	ld a, $01
	ld [$c2c5], a
	xor a
	ld [$c2ab], a
Func_01_4af4:
	ld a, $01
	ld [$c2df], a
	ld a, $2c
	ld [$c2e0], a
	ld a, $01
	ld [$c2e1], a
	call Func_01_77d2
	ret
Func_01_4b07:
	call Func_01_4b0e
	call Func_01_77d2
	ret
Func_01_4b0e:
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	xor a
	ld [$c80f], a
	ld [wPlayerVelXLo], a
	ld [wPlayerVelXHi], a
	ld a, [wPlayerStatus]
	set 0, a
	ld [wPlayerStatus], a
	bit 7, a
	jr nz, Func_01_4b3b
	ld a, $14
	ld [wPlayerType], a
	ld a, $82
	ld [$c811], a
	ld a, $74
	ld [$c812], a
	ret
Func_01_4b3b:
	ld a, $15
	ld [wPlayerType], a
	ld a, $96
	ld [$c811], a
	ld a, $74
	ld [$c812], a
	ld a, [wPlayerX]
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, [wPlayerY]
	ld b, a
	ld a, [$c81c]
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_102b
	pop bc
	or a
	ret z

Data_01_4b6a:
	db $78, $3c, $cb, $37, $e6, $f0, $d6, $08, $c6, $0d, $ea, $07, $c8, $af, $ea, $06
	db $c8, $c9

Func_01_4b7c:
	ld a, [wProgressFlags]
	bit 3, a
	jr nz, Func_01_4ba8
	ld a, [wRoomType]
	cp $01
	jr nz, Func_01_4b96
	ld a, [wActiveFloor]
	ld c, a
	ld a, [wSilverKeys]
	cp c
	jr z, Func_01_4ba8
	jr Func_01_4ba3
Func_01_4b96:
	call Func_01_5c7c
	or a
	jr nz, Func_01_4ba8
	ld a, [wActiveFloor]
	cp $3c
	jr z, Func_01_4ba8
Func_01_4ba3:
	xor a
	ld [wScreenFrame], a
	ret
Func_01_4ba8:
	ld a, $01
	ld [wScreenFrame], a
	ret
Func_01_4bae:
	ld a, [$c2db]
	or a
	ret nz
	call Func_01_4bdc
	call Func_01_4bbd
	call Func_01_4bfb
	ret
Func_01_4bbd:
	ld a, [$c2df]
	or a
	ret z
	ld a, [$c2e0]
	ld e, a
	ld a, [$c2e1]
	ld d, a
	or e
	ret z
	dec de
	ld a, e
	ld [$c2e0], a
	ld a, d
	ld [$c2e1], a
	or e
	ret nz
	xor a
	ld [$c2df], a
	ret
Func_01_4bdc:
	ld a, [wRoomType]
	cp $02
	ret nz
	ld a, [$c2e3]
	or a
	ret z
	dec a
	ld [$c2e3], a
	ret
Func_01_4bec:
	ld a, [$c2e2]
	cp $02
	ret nz
	ld hl, $c80a
	ld a, $0a
	ld [hl+], a
	xor a
	ld [hl], a
	ret
Func_01_4bfb:
	ld hl, $c80a
	ld a, [hl+]
	ld e, a
	ld a, [hl-]
	ld d, a
	or e
	ret z
	dec de
	ld a, e
	ld [hl+], a
	ld a, d
	ld [hl], a
	or e
	jr nz, Func_01_4c1d
	call Func_01_4c4d
	xor a
	ld [$c2e2], a
	ld hl, $c81a
	ld a, [hl]
	and $f8
	or $02
	ld [hl], a
	ret
Func_01_4c1d:
	ld a, [$c2e2]
	cp $01
	jr z, Func_01_4c29
	cp $02
	jr z, Func_01_4c3b
	ret
Func_01_4c29:
	ld a, e
	and $03
	jr z, Func_01_4c4d
	cp $02
	ret nz
	ld c, $02
	ld hl, $5139
	xor a
	call Func_00_094a
	ret
Func_01_4c3b:
	ld a, e
	and $03
	jr z, Func_01_4c4d
	cp $02
	ret nz
	ld c, $02
	ld hl, $5131
	xor a
	call Func_00_094a
	ret
Func_01_4c4d:
	ld c, $02
	ld hl, $50f1
	xor a
	call Func_00_094a
	ret
Func_01_4c57:
	ld a, [$c55b]
	ld d, a
	ld a, [$c289]
	ld e, a
	ld a, [wPlayerY]
	sub e
	ld c, a
	sub $40
	jr nc, Func_01_4c70
	add a, e
	cp $80
	jr c, Func_01_4c7a
	xor a
	jr Func_01_4c7a
Func_01_4c70:
	ld a, c
	sub $60
	jr c, Func_01_4c82
	add a, e
	cp d
	jr c, Func_01_4c7a
	ld a, d
Func_01_4c7a:
	ld [$c289], a
	cpl
	add a, $11
	ldh [hSpriteOriginY], a
Func_01_4c82:
	ld a, [$c55a]
	ld d, a
	ld a, [$c28a]
	ld e, a
	ld a, [wPlayerX]
	sub e
	ld c, a
	sub $38
	jr nc, Func_01_4c9b
	add a, e
	cp $80
	jr c, Func_01_4ca5
	xor a
	jr Func_01_4ca5
Func_01_4c9b:
	ld a, c
	sub $68
	jr c, Func_01_4cad
	add a, e
	cp d
	jr c, Func_01_4ca5
	ld a, d
Func_01_4ca5:
	ld [$c28a], a
	cpl
	add a, $09
	ldh [hSpriteOriginX], a
Func_01_4cad:
	ret
Func_01_4cae:
	ld a, $e1
	ld b, $01
	ld c, $01
	call Func_01_4d95
	ld a, $e1
	ld b, $08
	ld c, $01
	call Func_01_4d95
	ld a, $e1
	ld b, $01
	ld c, $0f
	call Func_01_4d95
	ld a, $e1
	ld b, $08
	ld c, $0f
	call Func_01_4d95
	ret
DrawStairTileClosedL:
	ld a, $30
	ld b, $05
	ld c, $01
	call Func_01_4d95
	xor a
	ld [$cf77], a
	ret
Func_01_4ce1:
	ld a, $31
	ld b, $05
	ld c, $01
	call Func_01_4d95
	ld a, $01
	ld [$cf77], a
	ret
DrawStairTileOpenR:
	ld a, $32
	ld b, $05
	ld c, $0f
	call Func_01_4d95
	xor a
	ld [$cf78], a
	ret
Func_01_4cfe:
	ld a, $33
	ld b, $05
	ld c, $0f
	call Func_01_4d95
	ld a, $01
	ld [$cf78], a
	ret
Func_01_4d0d:
	ld a, [$c530]
	ld c, a
	ld a, [$c531]
	ld b, a
	ld a, $c0
	call Func_01_4d95
	ret
DrawTileAtSpawnCoord:
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
	ld a, $e2
	call Func_01_4d95
	ret
ReadTileAtEntityCell:
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
	ld a, $c8
	call Func_01_4dbe
	ret
AnimSparkleRing:
	ld a, [$cf77]
	inc a
	ld [$cf77], a
	ld a, [$cf77]
	add a, a
	ld hl, $4d89
	add a, l
	jr nc, Func_01_4d5d

SECTION "analyzed_004d5c", ROMX[$4d5c], BANK[$01]

Data_01_4d5c:
	db $24

SECTION "analyzed_004d5d", ROMX[$4d5d], BANK[$01]

Func_01_4d5d:
	ld l, a
	ld a, [hl+]
	push hl
	ld b, $04
	ld c, $05
	ld d, $09
Func_01_4d66:
	push af
	push de
	push bc
	call Func_01_4d95
	pop bc
	pop de
	pop af
	inc b
	dec d
	jr nz, Func_01_4d66
	pop hl
	ld a, [hl]
	ld b, $04
	ld c, $06
	ld d, $09
Func_01_4d7b:
	push af
	push bc
	push de
	call Func_01_4d95
	pop de
	pop bc
	pop af
	inc b
	dec d
	jr nz, Func_01_4d7b
	ret

Func_01_4d89:
	jr nc, Func_01_4dbc

Data_01_4d8b:
	db $32, $33, $34, $35, $36, $37, $38, $39, $00, $00

Func_01_4d95:
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
	push af
	push hl
	ld hl, wFloorCollision
	add hl, de
	ld a, [hl]
	pop hl
	or a
	jr nz, Func_01_4db6
	pop af
	call DrawFloorPiece
	ret
Func_01_4db6:
	pop af
	bit 7, a
	ret z

Func_01_4dba:
	set 6, a
Func_01_4dbc:
	ld [hl], a
	ret

Func_01_4dbe:
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
	ld a, [hl]
	or a
	jr nz, Func_01_4dd7
	pop af
	ld [hl], a
	call DrawFloorPiece
	ret
Func_01_4dd7:
	pop af
	ret
Func_01_4dd9:
	ld a, [wRoomType]
	cp $02
	ret nz
	ld a, [wActiveFloor]
	cp $04
	ret nz
	ld a, [$c2e5]
	or a
	ret z
	dec a
	ld [$c2e5], a
	and $07
	ld hl, $4e01
	rst AddAToHL
	ld a, [$c289]
	add a, [hl]
	ld [$c289], a
	cpl
	add a, $11
	ldh [hSpriteOriginY], a
	ret

Data_01_4e01:
	db $00, $01, $00, $02, $00, $fe, $00, $ff

Func_01_4e09:
	ld hl, $4f5b
	ld de, $9c20
	call Func_01_76dd
	ld hl, $4f70
	ld de, $9c40
	call Func_01_76dd
	ld hl, $4f85
	ld de, $9c60
	call Func_01_76dd
	ld hl, $4f9a
	ld de, $9c80
	call Func_01_76dd
	ld hl, $4faf
	ld de, $9ca0
	call Func_01_76dd
	ld a, [wRoomType]
	cp $05
	jr z, Func_01_4e4b
	cp $06
	jr z, Func_01_4e4b
	ld hl, $4fc4
	ld de, $9cc0
	call Func_01_76dd
	ret
Func_01_4e4b:
	ld hl, $4f70
	ld de, $9cc0
	call Func_01_76dd
	ret
Func_01_4e55:
	ld hl, $4f70
	ld de, $9c20
	call Func_01_76dd
	ld hl, $4f70
	ld de, $9c40
	call Func_01_76dd
	ld hl, $4fdd
	ld de, $9c60
	call Func_01_76dd
	ld hl, $4f70
	ld de, $9c80
	call Func_01_76dd
	ld hl, $4ff2
	ld de, $9ca0
	call Func_01_76dd
	ld hl, $4f70
	ld de, $9cc0
	call Func_01_76dd
	ret
Func_01_4e8c:
	ld a, [$c2da]
	or a
	jr z, Func_01_4ea5
	ld hl, $4fdb
	ld de, $9ca4
	call Func_01_76dd
	ld hl, $4fd9
	ld de, $9cab
	call Func_01_76dd
	ret
Func_01_4ea5:
	ld hl, $4fd9
	ld de, $9ca4
	call Func_01_76dd
	ld hl, $4fdb
	ld de, $9cab
	call Func_01_76dd
	ret
Func_01_4eb8:
	ld a, [$c2d9]
	cp $01
	jr z, Func_01_4eec
	cp $02
	jr z, Func_01_4f11
	cp $03
	jr z, Func_01_4f36
	ld hl, $4fd9
	ld de, $9c65
	call Func_01_76dd
	ld hl, $4fdb
	ld de, $9c85
	call Func_01_76dd
	ld hl, $4fdb
	ld de, $9ca5
	call Func_01_76dd
	ld hl, $4fdb
	ld de, $9cc5
	call Func_01_76dd
	ret
Func_01_4eec:
	ld hl, $4fdb
	ld de, $9c65
	call Func_01_76dd
	ld hl, $4fd9
	ld de, $9c85
	call Func_01_76dd
	ld hl, $4fdb
	ld de, $9ca5
	call Func_01_76dd
	ld hl, $4fdb
	ld de, $9cc5
	call Func_01_76dd
	ret
Func_01_4f11:
	ld hl, $4fdb
	ld de, $9c65
	call Func_01_76dd
	ld hl, $4fdb
	ld de, $9c85
	call Func_01_76dd
	ld hl, $4fd9
	ld de, $9ca5
	call Func_01_76dd
	ld hl, $4fdb
	ld de, $9cc5
	call Func_01_76dd
	ret
Func_01_4f36:
	ld hl, $4fdb
	ld de, $9c65
	call Func_01_76dd
	ld hl, $4fdb
	ld de, $9c85
	call Func_01_76dd
	ld hl, $4fdb
	ld de, $9ca5
	call Func_01_76dd
	ld hl, $4fd9
	ld de, $9cc5
	call Func_01_76dd
	ret

Data_01_4f5b:
	db $20, $20, $20, $20, $20, $20, $20, $50, $41, $55, $53, $45, $20, $20, $20, $20
	db $20, $20, $20, $20, $00, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $20, $00, $20, $20, $20, $20, $20, $20
	db $53, $54, $41, $54, $55, $53, $20, $20, $20, $20, $20, $20, $20, $20, $00, $20
	db $20, $20, $20, $20, $20, $53, $54, $41, $47, $45, $2d, $4d, $41, $50, $20, $20
	db $20, $20, $20, $00, $20, $20, $20, $20, $20, $20, $47, $49, $56, $45, $2d, $55
	db $50, $20, $20, $20, $20, $20, $20, $20, $00, $20, $20, $20, $20, $20, $20, $54
	db $4f, $57, $4e, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $00, $6c, $00
	db $20, $00, $20, $20, $20, $20, $20, $20, $20, $20, $4f, $4b, $3f, $20, $20, $20
	db $20, $20, $20, $20, $20, $20, $00, $20, $20, $20, $20, $20, $59, $45, $53, $20
	db $20, $20, $20, $4e, $4f, $20, $20, $20, $20, $20, $20, $00

SECTION "analyzed_0054d0", ROMX[$54d0], BANK[$01]

; SpawnPickupEffect ($54d0) -- spawn the item-pickup feedback entity (spawn param
; $08) at the cell of the just-collected item: rounds b/c (item pixel pos) to a
; cell, takes the effect script from $ffe5/$ffe6, and calls the bank-$03 spawn
; primitive ($4593). Does NOT remove the item -- RemoveOpenItemAtCell already did
; that. SpawnPickupEffectAlt below is the same routine with spawn param $0c.
SpawnPickupEffect:
	ld a, c
	add a, $08
	swap a
	and $0f
	swap a
	and $f0
	ld e, a
	ld a, b
	add a, $08
	swap a
	and $0f
	swap a
	and $f0
	ld d, a
	ld hl, $ffe5
	ld a, [hl+]
	ld c, a
	ld b, [hl]
	ld a, $08
	ld [wBankCallTmp], a
	ld a, h
	ld [wSpawnPtr], a
	ld a, l
	ld [wSpawnPtr+1], a
	ld a, $03
	ld hl, $4593
	call Func_00_0467
	ret

SpawnPickupEffectAlt:
	ld a, c
	add a, $08
	swap a
	and $0f
	swap a
	and $f0
	ld e, a
	ld a, b
	add a, $08
	swap a
	and $0f
	swap a
	and $f0
	ld d, a
	ld hl, $ffe5
	ld a, [hl+]
	ld c, a
	ld b, [hl]
	ld a, $0c
	ld [wBankCallTmp], a
	ld a, h
	ld [wSpawnPtr], a
	ld a, l
	ld [wSpawnPtr+1], a
	ld a, $03
	ld hl, $4593
	call Func_00_0467
	ret
Func_01_5538:
	ld a, [$c2db]
	cp $02
	ret z
	ld c, $02
	call StartRoomAnimation
	ret
TransformMonstersToSuzurin:
	ld hl, $c823
	ld c, $1b
Func_01_5549:
	push bc
	push hl
	ld a, [hl]
	call Func_00_1290
	bit 2, a
	jr z, Func_01_559c

Data_01_5553:
	db $cb, $77, $20, $1d, $e5, $01, $0d, $00, $09, $2a, $66, $6f, $11, $00, $08, $7d
	db $93, $6f, $7c, $9a, $67, $54, $5d, $e1, $e5, $01, $0d, $00, $09, $7b, $22, $72
	db $e1, $af, $77, $e5, $01, $0c, $00, $09, $5e, $e1, $e5, $01, $0e, $00, $09, $56
	db $e1, $01, $00, $00, $3e, $1f, $ea, $9c, $c2, $7c, $ea, $a1, $c2, $7d, $ea, $a2
	db $c2, $3e, $03, $21, $93, $45, $cd, $67, $04

Func_01_559c:
	pop hl
	ld de, $002a
	add hl, de
	pop bc
	dec c
	jr nz, Func_01_5549
	ret
TransformMonstersToDuck:
	ld hl, $c823
	ld c, $1b
Func_01_55ab:
	push bc
	push hl
	ld a, [hl]
	cp $30
	jr z, Func_01_55bc
	cp $31
	jr z, Func_01_55bc
	cp $32
	jr z, Func_01_55bc
	jr Func_01_5607
Func_01_55bc:
	call Func_00_1290
	bit 6, a
	jr nz, Func_01_55d1
	push hl
	ld bc, $000e
	add hl, bc
	ld a, [hl]
	sub $08
	ld [$cf76], a
	pop hl
	jr Func_01_55db

Func_01_55d1:
	push hl
	ld bc, $000e
	add hl, bc
	ld a, [hl]
	ld [$cf76], a
	pop hl

Func_01_55db:
	push hl
	ld bc, $000c
	add hl, bc
	ld a, [hl]
	ld [$cf75], a
	pop hl
	xor a
	ld [hl], a
	ld a, [$cf75]
	ld e, a
	ld a, [$cf76]
	ld d, a
	ld bc, $0000
	ld a, $08
	ld [wBankCallTmp], a
	ld a, h
	ld [wSpawnPtr], a
	ld a, l
	ld [wSpawnPtr+1], a
	ld a, $03
	ld hl, $4593
	call Func_00_0467
Func_01_5607:
	pop hl
	ld de, $002a
	add hl, de
	pop bc
	dec c
	jr nz, Func_01_55ab
	ret
DoubleFloorTimer:
	ld hl, wFloorTimer
	ld a, [hl]
	add a, a
	daa
	ld [hl+], a
	ld a, [hl]
	adc a, a
	daa
	ld [hl+], a
	ld a, [hl]
	adc a, a
	daa
	ld [hl], a
	and $f0
	ret z

Data_01_5623:
	db $3e, $09, $32, $3e, $99, $32, $77, $c9

QuintupleFloorTimer:
	ld hl, wFloorTimer
	ld a, [hl+]
	ld [$cf65], a
	ld a, [hl+]
	ld [$cf66], a
	ld a, [hl-]
	ld [$cf67], a
	dec hl
	ld a, [hl]
	add a, a
	daa
	ld [hl+], a
	ld a, [hl]
	adc a, a
	daa
	ld [hl+], a
	ld a, [hl]
	ld b, a
	adc a, b
	daa
	ld [hl-], a
	dec hl
	ld a, [hl]
	add a, a
	daa
	ld [hl+], a
	ld a, [hl]
	adc a, a
	daa
	ld [hl+], a
	ld a, [hl]
	adc a, a
	daa
	ld [hl-], a
	dec hl
	ld b, [hl]
	ld a, [$cf65]
	add a, b
	daa
	ld [hl+], a
	ld b, [hl]
	ld a, [$cf66]
	adc a, b
	daa
	ld [hl+], a
	ld b, [hl]
	ld a, [$cf67]
	adc a, b
	daa
	ld [hl], a
	and $f0
	ret z

Data_01_566e:
	db $3e, $09, $32, $3e, $99, $32, $77, $c9

SECTION "analyzed_00572d", ROMX[$572d], BANK[$01]

Func_01_572d:
	call Func_01_573d
	ld a, [wRoomType]
	cp $05
	ret z
	cp $02
	ret z
	call Func_01_5749
	ret
Func_01_573d:
	ld hl, $cf91
	ld c, $10
	xor a
Func_01_5743:
	ld [hl+], a
	ld [hl+], a
	dec c
	jr nz, Func_01_5743
	ret
Func_01_5749:
	xor a
	ld [$cf8e], a
	ld de, $cf91
	ld hl, wFloorGrid
	xor a
	ld [$cf90], a
	ld a, [wFloorHeight]
	ld b, a
Func_01_575b:
	xor a
	ld [$cf8f], a
	ld a, [wFloorWidth]
	ld c, a
	push hl
Func_01_5764:
	ld a, [hl]
	call Func_01_5817
	or a
	jr z, Func_01_5788
	call Func_01_57d0
	push af
	ld a, [$cf8e]
	inc a
	ld [$cf8e], a
	pop af
	or a
	jr nz, Func_01_5786
	ld a, [$cf8f]
	ld [de], a
	inc de
	ld a, [$cf90]
	ld [de], a
	inc de
	jr Func_01_5788
Func_01_5786:
	inc de
	inc de
Func_01_5788:
	inc hl
	ld a, [$cf8f]
	inc a
	ld [$cf8f], a
	dec c
	jr nz, Func_01_5764
	pop hl
	push de
	ld de, $0011
	add hl, de
	pop de
	ld a, [$cf90]
	inc a
	ld [$cf90], a
	dec b
	jr nz, Func_01_575b
	ret
Func_01_57a5:
	ld a, [wRoomType]
	cp $00
	jr z, Func_01_57b7
	cp $01
	jr z, Func_01_57bd
	call Func_00_17c0
	or a
	ret z
	jr Func_01_57c2
Func_01_57b7:
	ld a, [wActiveFloor]
	dec a
	jr Func_01_57c2
Func_01_57bd:
	ld a, [wActiveFloor]
	add a, $3b
Func_01_57c2:
	push de
	ld d, $00
	ld e, a
	sla e
	rl d
	ld hl, $d044
	add hl, de
	pop de
	ret
Func_01_57d0:
	push bc
	push de
	push hl
	ld a, [$cf8e]
	and $07
	ld hl, $1209
	rst AddAToHL
	ld b, [hl]
	ld a, [$cf8e]
	sra a
	sra a
	sra a
	ld e, a
	ld d, $00
	call Func_01_57a5
	add hl, de
	ld a, [hl]
	and b
	pop hl
	pop de
	pop bc
	ret
Func_01_57f3:
	push bc
	push de
	push hl
	ld a, [$cf8e]
	and $07
	ld hl, $1209
	rst AddAToHL
	ld b, [hl]
	ld a, [$cf8e]
	sra a
	sra a
	sra a
	ld e, a
	ld d, $00
	call Func_01_57a5
	add hl, de
	ld a, [hl]
	or b
	ld [hl], a
	pop hl
	pop de
	pop bc
	ret
Func_01_5817:
	push bc
	push hl
	bit 7, a
	jr z, Func_01_582f
	set 6, a
	ld c, a
	ld hl, $5833
Func_01_5823:
	ld a, [hl+]
	or a
	jr z, Func_01_582f
	cp c
	jr nz, Func_01_5823
	pop hl
	pop bc
	ld a, $01
	ret
Func_01_582f:
	pop hl
	pop bc
	xor a
	ret

Data_01_5833:
	db $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf, $d0, $d1
	db $d2, $d3, $d4, $d5, $d6, $d7, $d8, $d9, $da, $db, $dc, $dd, $de, $df, $e0, $e3
	db $00

StartRoomAnimation:
	ld a, c
	ld [$c2db], a
	xor a
	ld [$c2dd], a
	ld [$c2de], a
	ld a, c
	or a
	ret z
	call Func_01_4c4d
	ret
Func_01_5866:
	ld a, [$c2db]
	add a, a
	ld e, a
	ld d, $00
	ld hl, $5875
	add hl, de
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp hl

Data_01_5875:
	db $7f, $58, $80, $58, $ee, $58, $49, $59, $5f, $5a

Func_01_587f:
	ret
	ld a, [$c2dd]
	cp $01
	jr z, Func_01_58c0
	cp $02
	jr z, Func_01_58c1
	ld hl, $c530
	ld a, [hl+]
	swap a
	and $f0
	sub $08
	add a, $08
	ld e, a
	ld a, [hl]
	swap a
	and $f0
	sub $08
	add a, $08
	ld d, a
	ld bc, $0000
	ld a, $0a
	ld [wBankCallTmp], a
	ld a, h
	ld [wSpawnPtr], a
	ld a, l
	ld [wSpawnPtr+1], a
	ld a, $03
	ld hl, $4593
	call Func_00_0467
	ld a, $01
	ld [$c2dd], a
	ret
Func_01_58c0:
	ret
Func_01_58c1:
	ld a, [$c2de]
	ld e, a
	and $0f
	jr nz, Func_01_58d9
	ld a, e
	swap a
	and $0f
	ld e, a
	ld d, $00
	ld hl, $58ec
	add hl, de
	ld a, [hl]
	call Func_01_5b9e
Func_01_58d9:
	ld hl, $c2de
	inc [hl]
	ld a, [hl]
	cp $20
	ret nz
	xor a
	ld [$c2de], a
	ld [$c2dd], a
	ld [$c2db], a
	ret

Data_01_58ec:
	db $01, $02

Func_01_58ee:
	ld a, [$c2de]
	ld e, a
	and $0f
	jr nz, Func_01_5908
	ld a, e
	swap a
	and $0f
	ld e, a
	ld d, $00
	ld hl, $5944
	add hl, de
	ld a, [hl]
	cp $ff
	call nz, Func_01_5b9e
Func_01_5908:
	ld hl, $c2de
	inc [hl]
	ld a, [hl]
	cp $01
	jr z, Func_01_5934
	cp $02
	jr z, Func_01_593c
	cp $50
	jr z, Func_01_5922
	cp $10
	ret nz
	ld hl, wPlayerFacing
	set 6, [hl]
	ret
Func_01_5922:
	xor a
	ld [$c2dd], a
	ld [$c2de], a
	ld hl, wProgressFlags
	set 7, [hl]
	ld a, $01
	ld [wTransitionState], a
	ret
Func_01_5934:
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	ret
Func_01_593c:
	push af
	ld a, SOUND_SFX_09
	call PlaySound
	pop af
	ret

Data_01_5944:
	db $ff, $ff, $01, $00, $ff

Func_01_5949:
	ld a, [$c2dd]
	cp $05
	jr z, Func_01_599b
	cp $04
	jr z, Func_01_597b
	cp $03
	jr z, Func_01_596b
	cp $01
	jr z, Func_01_59b4
	or a
	ret nz
	push af
	ld a, SOUND_SFX_0a
	call PlaySound
	pop af
	ld a, $01
	ld [$c2dd], a
	ret
Func_01_596b:
	ld a, [wProgressFlags]
	bit 1, a
	jr z, Func_01_599b
	xor a
	ld [$c2de], a
	ld a, $04
	ld [$c2dd], a
Func_01_597b:
	ld a, [$c2de]
	ld e, a
	and $0f
	jr nz, Func_01_5993
	ld a, e
	swap a
	and $0f
	ld e, a
	ld d, $00
	ld hl, $58ec
	add hl, de
	ld a, [hl]
	call Func_01_5b9e
Func_01_5993:
	ld hl, $c2de
	inc [hl]
	ld a, [hl]
	cp $20
	ret nz
Func_01_599b:
	FAR_CALL DrawFloorPieces
	call Func_01_449d
	call Func_01_4aa1
	xor a
	ld [$c2db], a
	ld [$c2dd], a
	ld [$c2de], a
	ret
Func_01_59b4:
	ld a, [$c2de]
	ld e, a
	and $0f
	jr nz, Func_01_59ce
	ld a, e
	swap a
	and $0f
	ld e, a
	ld d, $00
	ld hl, $5a58
	add hl, de
	ld a, [hl]
	cp $ff
	call nz, Func_01_5bd8
Func_01_59ce:
	ld hl, $c2de
	inc [hl]
	ld a, [hl]
	cp $30
	jr z, Func_01_5a52
	cp $60
	ret nz
	ld a, [wRoomType]
	cp $02
	jr nz, Func_01_5a06
	ld a, [wActiveFloor]
	cp $05
	jr nz, Func_01_599b
	ld bc, $0000
	ld a, $3f
	ld [wBankCallTmp], a
	ld a, h
	ld [wSpawnPtr], a
	ld a, l
	ld [wSpawnPtr+1], a
	ld a, $03
	ld hl, $4593
	call Func_00_0467
	ld a, $06
	ld [$c2dd], a
	ret
Func_01_5a06:
	ld a, [$c530]
	cp $ff
	jr nz, Func_01_5a16
	ld a, [wSpawnCellX]
	cp $ff
	jr nz, Func_01_5a16
	jr Func_01_5a4c
Func_01_5a16:
	ld a, [$c2ea]
	swap a
	and $f0
	sub $08
	add a, $08
	ld e, a
	ld a, [$c2eb]
	swap a
	and $f0
	sub $08
	add a, $08
	ld d, a
	ld bc, $0000
	ld a, $0b
	ld [wBankCallTmp], a
	ld a, h
	ld [wSpawnPtr], a
	ld a, l
	ld [wSpawnPtr+1], a
	ld a, $03
	ld hl, $4593
	call Func_00_0467
	ld a, $02
	ld [$c2dd], a
	ret
Func_01_5a4c:
	ld a, $03
	ld [$c2dd], a
	ret
Func_01_5a52:
	ld hl, wPlayerFacing
	res 6, [hl]
	ret

Data_01_5a58:
	db $ff, $01, $02, $03, $ff, $04

SECTION "analyzed_005a5e", ROMX[$5a5e], BANK[$01]

Data_01_5a5e:
	db $ff

SECTION "analyzed_005a5f", ROMX[$5a5f], BANK[$01]

Func_01_5a5f:
	ld a, [$c2dd]
	or a
	jr nz, Func_01_5a7a
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	FAR_CALL SceneInit
	ld a, $01
	ld [$c2dd], a
	ret
Func_01_5a7a:
	FAR_CALL SceneRunFrame
	bit 7, a
	ret z
	call Func_01_5a90
	call Func_01_449d
	xor a
	ld [$c2db], a
	ret
Func_01_5a90:
	ld a, [wSceneState]
	and $7f
	cp $07
	ret nc
	add a, a
	ld hl, $5aa1
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp hl

Data_01_5aa1:
	db $b9, $5a, $d5, $5a, $ed, $5a, $05, $5b, $1d, $5b, $35, $5b, $4d, $5b

Data_01_5aaf:
	db $b1, $5a, $f5, $3e, $06, $cd, $85, $0a, $f1, $c9

Func_01_5ab9:
	ld hl, $c823
	ld c, $1b
Func_01_5abe:
	ld a, [hl]
	or a
	jr z, Func_01_5acd
	cp $1f
	jr z, Func_01_5acd
	push bc
	push hl
	call Func_01_6592
	pop hl
	pop bc
Func_01_5acd:
	ld de, $002a
	add hl, de
	dec c
	jr nz, Func_01_5abe
	ret
	ld hl, $c80a
	ld a, $b0
	ld [hl+], a
	ld a, $04
	ld [hl], a
	ld a, $02
	ld [$c2e2], a
	ld hl, $c81a
	ld a, [hl]
	and $f8
	or $02
	ld [hl], a
	ret
	ld hl, $c80a
	ld a, $b0
	ld [hl+], a
	ld a, $04
	ld [hl], a
	ld a, $01
	ld [$c2e2], a
	ld hl, $c81a
	ld a, [hl]
	and $f8
	or $04
	ld [hl], a
	ret
	ld hl, $c80a
	ld a, $b0
	ld [hl+], a
	ld a, $04
	ld [hl], a
	ld a, $03
	ld [$c2e2], a
	ld hl, $c81a
	ld a, [hl]
	and $f8
	or $02
	ld [hl], a
	ret
	ld b, $00
Func_01_5b1f:
	ld c, $00
	push bc
Func_01_5b22:
	call Func_01_5b4e
	inc c
	ld a, [wFloorWidth]
	cp c
	jr nz, Func_01_5b22
	pop bc
	inc b
	ld a, [wFloorHeight]
	cp b
	jr nz, Func_01_5b1f
	ret
	ld b, $00
Func_01_5b37:
	ld c, $00
	push bc
Func_01_5b3a:
	call Func_01_5b7b
	inc c
	ld a, [wFloorWidth]
	cp c
	jr nz, Func_01_5b3a
	pop bc
	inc b
	ld a, [wFloorHeight]
	cp b
	jr nz, Func_01_5b37
	ret
	ret
Func_01_5b4e:
	push bc
	push bc
	call ReadFloorCell
	or a
	jr z, Func_01_5b77
	cp $20
	jr z, Func_01_5b77
	ld b, $00
	ld hl, wFloorCollision
	add hl, bc
	ld [hl], $00
	ld hl, wFloorGrid
	add hl, bc
	pop bc
	ld a, [hl]
	bit 7, a
	jr z, Func_01_5b70
	call Func_00_11dc
	ld [hl], a
Func_01_5b70:
	call DrawFloorPiece
	pop bc
	ld a, $01
	ret
Func_01_5b77:
	pop bc
	pop bc
	xor a
	ret
Func_01_5b7b:
	push bc
	push bc
	call ReadFloorCell
	or a
	jr nz, Func_01_5b9a
	ld b, $00
	ld hl, wFloorGrid
	add hl, bc
	pop bc
	ld a, [hl]
	bit 7, a
	jr z, Func_01_5b93
	call Func_00_11dc
	ld [hl], a
Func_01_5b93:
	call DrawFloorPiece
	pop bc
	ld a, $01
	ret
Func_01_5b9a:
	pop bc
	pop bc
	xor a
	ret
Func_01_5b9e:
	push af
	ld a, [wSpawnCellY]
	cp $ff
	jr nz, Func_01_5ba8

Data_01_5ba6:
	db $f1, $c9

Func_01_5ba8:
	ld b, a
	ld a, [wSpawnCellX]
	ld c, a
	push bc
	ld a, b
	swap a
	and $f0
	add a, b
	add a, c
	ld hl, wFloorGrid
	rst AddAToHL
	pop bc
	pop af
	cp $00
	jr nz, Func_01_5bc6
	ld a, $40
	ld [hl], a
	call DrawFloorPiece
	ret
Func_01_5bc6:
	cp $01
	jr nz, Func_01_5bd1
	ld a, $44
	ld [hl], a
	call DrawFloorPiece
	ret
Func_01_5bd1:
	ld a, $41
	ld [hl], a
	call DrawFloorPiece
	ret
Func_01_5bd8:
	push af
	ld a, [$c2eb]
	cp $ff
	jr nz, Func_01_5be2

Data_01_5be0:
	db $f1, $c9

Func_01_5be2:
	ld b, a
	ld a, [$c2ea]
	ld c, a
	push bc
	ld a, b
	swap a
	and $f0
	add a, b
	add a, c
	ld hl, wFloorGrid
	rst AddAToHL
	pop bc
	pop af
	cp $01
	jr z, Func_01_5c0c
	cp $02
	jr z, Func_01_5c13
	cp $03
	jr z, Func_01_5c1a
	cp $04
	jr z, Func_01_5c21
	ld a, $48
	ld [hl], a
	call DrawFloorPiece
	ret
Func_01_5c0c:
	ld a, $49
	ld [hl], a
	call DrawFloorPiece
	ret
Func_01_5c13:
	ld a, $4a
	ld [hl], a
	call DrawFloorPiece
	ret
Func_01_5c1a:
	ld a, $4b
	ld [hl], a
	call DrawFloorPiece
	ret
Func_01_5c21:
	ld a, $00
	ld [hl], a
	call DrawFloorPiece
	ret
Func_01_5c28:
	ld a, [wRoomType]
	cp $02
	ret nz
	ld a, [wTransitionState]
	cp $01
	jr z, Func_01_5c42
	ld a, [wLives]
	cp $01
	ret nz

Data_01_5c3b:
	db $3e, $02, $ea, $0f, $d6, $18, $05

Func_01_5c42:
	ld a, $01
	ld [wBossState], a
	ld a, [wActiveFloor]
	cp $01
	jr z, Func_01_5c5f
	cp $02
	jr z, Func_01_5c62
	cp $03
	jr z, Func_01_5c66
	cp $04
	jr z, Func_01_5c6a
	cp $05
	jr z, Func_01_5c6e

SECTION "analyzed_005c5e", ROMX[$5c5e], BANK[$01]

Data_01_5c5e:
	db $c9

SECTION "analyzed_005c5f", ROMX[$5c5f], BANK[$01]

Func_01_5c5f:
	xor a
	jr Func_01_5c70
Func_01_5c62:
	ld a, $01
	jr Func_01_5c70
Func_01_5c66:
	ld a, $02
	jr Func_01_5c70
Func_01_5c6a:
	ld a, $03
	jr Func_01_5c70
Func_01_5c6e:
	ld a, $04
Func_01_5c70:
	ld [$d60e], a
	FAR_CALL StartTowerBossEncounter
	ret
Func_01_5c7c:
	ld a, [wActiveFloor]
	cp $0a
	jr z, Func_01_5c9d
	cp $0f
	jr z, Func_01_5ca8
	cp $14
	jr z, Func_01_5c9d
	cp $1e
	jr z, Func_01_5cb3
	cp $28
	jr z, Func_01_5c9d
	cp $32
	jr z, Func_01_5c9d
	cp $3c
	jr z, Func_01_5c9d
Func_01_5c9b:
	xor a
	ret
Func_01_5c9d:
	ld a, $09
	call Func_00_119a
	or a
	jr nz, Func_01_5c9b
	ld a, $01
	ret
Func_01_5ca8:
	ld a, $0c
	call Func_00_119a
	or a
	jr nz, Func_01_5c9b
	ld a, $02
	ret
Func_01_5cb3:
	ld a, $0d
	call Func_00_119a
	or a
	jr nz, Func_01_5c9b
	ld a, $02
	ret
Func_01_5cbe:
	ld a, [wRoomType]
	cp $02
	ret nz
	ld a, [wProgressFlags]
	bit 0, a
	ret z
	ld a, [wActiveFloor]
	cp $01
	jr z, Func_01_5ce2
	cp $02
	jr z, Func_01_5cff
	cp $03
	jr z, Func_01_5d1d
	cp $04
	jr z, Func_01_5d3b
	cp $05
	jr z, Func_01_5d59
	ret

Func_01_5ce2:
	ld a, $00
	call Func_00_119a
	or a
	ret nz
	xor a
	ld [$d60e], a
	xor a
	ld [wBossState], a
	FAR_CALL StartTowerBossEncounter
	ld a, $00
	call Func_00_1164
	ret

Func_01_5cff:
	ld a, $02
	call Func_00_119a
	or a
	ret nz
	ld a, $01
	ld [$d60e], a
	xor a
	ld [wBossState], a
	FAR_CALL StartTowerBossEncounter
	ld a, $02
	call Func_00_1164
	ret

Func_01_5d1d:
	ld a, $04
	call Func_00_119a
	or a
	ret nz
	ld a, $02
	ld [$d60e], a
	xor a
	ld [wBossState], a
	FAR_CALL StartTowerBossEncounter
	ld a, $04
	call Func_00_1164
	ret

Func_01_5d3b:
	ld a, $06
	call Func_00_119a
	or a
	ret nz
	ld a, $03
	ld [$d60e], a
	xor a
	ld [wBossState], a
	FAR_CALL StartTowerBossEncounter
	ld a, $06
	call Func_00_1164
	ret

Func_01_5d59:
	ld a, $08
	call Func_00_119a
	or a
	ret nz
	ld a, $04
	ld [$d60e], a
	xor a
	ld [wBossState], a
	FAR_CALL StartTowerBossEncounter
	ld a, $08
	call Func_00_1164
	ret

Func_01_5d77:
	ld a, [wActiveFloor]
	cp $0f
	jr z, Func_01_5d84
	cp $1e
	jr z, Func_01_5d99
	xor a
	ret

Func_01_5d84:
	ld a, $0c
	call Func_00_119a
	or a
	ret nz
	FAR_CALL Pashute_StartTownScript
	ld a, $0c
	call Func_00_1164
	ret

Func_01_5d99:
	ld a, $0d
	call Func_00_119a
	or a
	ret nz
	FAR_CALL Verde_StartDialogue
	ld a, $0d
	call Func_00_1164
	ret

Player_SummonMonster:
	ld a, [wRoomType]
	cp $02
	ret z
	cp $06
	ret z
	ld a, [wDisplayMonster]
	cp $ff
	ret z
	cp $06
	ret z
	ld c, a
	ld b, $00
	ld hl, wMonsterUses
	add hl, bc
	ld a, [hl]
	or a
	ret z
	sub $01
	daa
	ld [hl], a
	push de
	ld a, [wDisplayMonster]
	ld [wSceneState], a
	ld c, $04
	FAR_CALL StartRoomAnimation
	pop de
	xor a
	ld [$c2ab], a
	ld a, [wDisplayMonster]
	ld c, a
	ld b, $00
	ld hl, wMonsterUses
	add hl, bc
	ld a, [hl]
	or a
	ret nz
	ld a, $ff
	ld [wDisplayMonster], a
	ret
Func_01_5df7:
	ld a, l
	ldh [hEntityPtrLo], a
	ld a, h
	ldh [hEntityPtrHi], a
	ld a, [hl+]
	ldh [hEntityState], a
	ld bc, $0003
	add hl, bc
	ld a, [hl+]
	ldh [hEntityStatus], a
	ld a, [hl+]
	ldh [hEntityAnimState], a
	ld a, [hl+]
	ldh [hEntityFacing], a
	ld bc, $0004
	add hl, bc
	ld a, [hl+]
	ldh [hEntityXSub], a
	ld a, [hl+]
	ldh [hEntityX], a
	ld a, [hl+]
	ldh [hEntityYSub], a
	ld a, [hl+]
	ldh [hEntityY], a
	inc hl
	inc hl
	ld a, [hl+]
	ldh [hEntityVelYLo], a
	ld a, [hl+]
	ldh [hEntityVelYHi], a
	ld bc, $0003
	add hl, bc
	ld a, [hl+]
	ldh [hEntityTimer], a
	inc hl
	ld a, [hl+]
	ldh [hEntityScriptPtrLo], a
	ld a, [hl+]
	ldh [hEntityScriptPtrHi], a
	ld bc, $000c
	add hl, bc
	ld a, [hl+]
	ldh [$ffd6], a
	ld a, [hl+]
	ldh [$ffd7], a
	ld a, [hl+]
	ldh [$ffd8], a
	ld a, [hl+]
	ldh [$ffd9], a
	ret
Func_01_5e44:
	ldh a, [hEntityState]
	ld [hl+], a
	ld bc, $0003
	add hl, bc
	ldh a, [hEntityStatus]
	ld [hl+], a
	ldh a, [hEntityAnimState]
	ld [hl+], a
	ldh a, [hEntityFacing]
	ld [hl+], a
	ld bc, $0004
	add hl, bc
	ldh a, [hEntityXSub]
	ld [hl+], a
	ldh a, [hEntityX]
	ld [hl+], a
	ldh a, [hEntityYSub]
	ld [hl+], a
	ldh a, [hEntityY]
	ld [hl+], a
	inc hl
	inc hl
	ldh a, [hEntityVelYLo]
	ld [hl+], a
	ldh a, [hEntityVelYHi]
	ld [hl+], a
	ld bc, $0003
	add hl, bc
	ldh a, [hEntityTimer]
	ld [hl+], a
	inc hl
	ldh a, [hEntityScriptPtrLo]
	ld [hl+], a
	ldh a, [hEntityScriptPtrHi]
	ld [hl+], a
	ld bc, $000c
	add hl, bc
	ldh a, [$ffd6]
	ld [hl+], a
	ldh a, [$ffd7]
	ld [hl+], a
	ldh a, [$ffd8]
	ld [hl+], a
	ldh a, [$ffd9]
	ld [hl+], a
	ret
Func_01_5e8b:
	ld a, [wPlayerStatus]
	bit 2, a
	ret z
	ldh a, [$ffe7]
	ld l, a
	ldh a, [$ffe8]
	ld h, a
	ld a, [hl]
	cp $10
	ret c
	cp $1c
	ret nc
	call Func_01_5df7
	ldh a, [hEntityFacing]
	bit 3, a
	jr z, Func_01_5eac
	call Func_01_5ec1
	jr Func_01_5eaf
Func_01_5eac:
	call Func_01_62c5
Func_01_5eaf:
	ldh a, [$ffd8]
	or a
	jr z, Func_01_5eb7
	call Func_01_650d
Func_01_5eb7:
	ldh a, [hEntityPtrLo]
	ld l, a
	ldh a, [hEntityPtrHi]
	ld h, a
	call Func_01_5e44
	ret
Func_01_5ec1:
	bit 2, a
	jr nz, Func_01_5ed9
	and $03
	cp $01
	jp z, Func_01_5fe3
	cp $02
	jp z, Func_01_60d9
	cp $03
	jp z, Func_01_61cf
	jp Func_01_5eed
Func_01_5ed9:
	and $03
	cp $01
	jp z, Func_01_605e
	cp $02
	jp z, Func_01_6154
	cp $03
	jp z, Func_01_624a
	jp Func_01_5f68
Func_01_5eed:
	ldh a, [hEntityX]
	add a, $03
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $03
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jp nz, Func_01_5f58
	ldh a, [hEntityY]
	sub $04
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	ret nz
	ldh a, [hEntityX]
	sub $04
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_01_5f52
	inc c
	inc c
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	or a
	ret nz
	call Func_01_64d7
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $02
	ld [hl], a
	call Func_01_6449
	ret

Func_01_5f52:
	ld hl, $ffb6
	res 3, [hl]
	ret

Func_01_5f58:
	call Func_01_64f2
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $03
	ld [hl], a
	call Func_01_645f
	ret
Func_01_5f68:
	ldh a, [hEntityX]
	add a, $03
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	sub $04
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jp nz, Func_01_5fd3
	ldh a, [hEntityY]
	add a, $03
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	ret nz
	ldh a, [hEntityX]
	sub $04
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_01_5fcd
	inc c
	inc c
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	or a
	ret nz
	call Func_01_64f2
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $03
	ld [hl], a
	call Func_01_6449
	ret

Func_01_5fcd:
	ld hl, $ffb6
	res 3, [hl]
	ret

Func_01_5fd3:
	call Func_01_64d7
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $02
	ld [hl], a
	call Func_01_645f
	ret
Func_01_5fe3:
	ldh a, [hEntityX]
	sub $04
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	sub $04
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jp nz, Func_01_604e
	ldh a, [hEntityY]
	add a, $03
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	ret nz
	ldh a, [hEntityX]
	add a, $03
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_01_6048
	dec c
	dec c
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	or a
	ret nz
	call Func_01_64f2
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $03
	ld [hl], a
	call Func_01_645f
	ret

Func_01_6048:
	ld hl, $ffb6
	res 3, [hl]
	ret

Func_01_604e:
	call Func_01_64d7
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $02
	ld [hl], a
	call Func_01_6449
	ret
Func_01_605e:
	ldh a, [hEntityX]
	sub $04
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $03
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jp nz, Func_01_60c9
	ldh a, [hEntityY]
	sub $04
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	ret nz
	ldh a, [hEntityX]
	add a, $03
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_01_60c3
	dec c
	dec c
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	or a
	ret nz
	call Func_01_64d7
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $02
	ld [hl], a
	call Func_01_645f
	ret

Func_01_60c3:
	ld hl, $ffb6
	res 3, [hl]
	ret

Func_01_60c9:
	call Func_01_64f2
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $03
	ld [hl], a
	call Func_01_6449
	ret
Func_01_60d9:
	ldh a, [hEntityX]
	add a, $03
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	sub $04
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jp nz, Func_01_6144
	ldh a, [hEntityX]
	sub $04
	add a, $08
	swap a
	and $0f
	ld c, a
	push bc
	call Func_00_101b
	pop bc
	or a
	ret nz
	ldh a, [hEntityY]
	add a, $03
	ld b, a
	push bc
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_01_613e
	dec b
	dec b
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret nz
	call Func_01_64bc
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $01
	ld [hl], a
	call Func_01_648b
	ret

Func_01_613e:
	ld hl, $ffb6
	res 3, [hl]
	ret

Func_01_6144:
	call Func_01_64a1
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $00
	ld [hl], a
	call Func_01_6475
	ret
Func_01_6154:
	ldh a, [hEntityX]
	sub $04
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	sub $04
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jp nz, Func_01_61bf
	ldh a, [hEntityX]
	add a, $03
	add a, $08
	swap a
	and $0f
	ld c, a
	push bc
	call Func_00_101b
	pop bc
	or a
	ret nz
	ldh a, [hEntityY]
	add a, $03
	ld b, a
	push bc
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_01_61b9
	dec b
	dec b
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret nz
	call Func_01_64a1
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $00
	ld [hl], a
	call Func_01_648b
	ret

Func_01_61b9:
	ld hl, $ffb6
	res 3, [hl]
	ret

Func_01_61bf:
	call Func_01_64bc
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $01
	ld [hl], a
	call Func_01_6475
	ret
Func_01_61cf:
	ldh a, [hEntityX]
	sub $04
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $03
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jp nz, Func_01_623a
	ldh a, [hEntityX]
	add a, $03
	add a, $08
	swap a
	and $0f
	ld c, a
	push bc
	call Func_00_101b
	pop bc
	or a
	ret nz
	ldh a, [hEntityY]
	sub $04
	ld b, a
	push bc
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_01_6234
	inc b
	inc b
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret nz
	call Func_01_64a1
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $00
	ld [hl], a
	call Func_01_6475
	ret

Func_01_6234:
	ld hl, $ffb6
	res 3, [hl]
	ret

Func_01_623a:
	call Func_01_64bc
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $01
	ld [hl], a
	call Func_01_648b
	ret
Func_01_624a:
	ldh a, [hEntityX]
	add a, $03
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $03
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	jp nz, Func_01_62b5
	ldh a, [hEntityX]
	sub $04
	add a, $08
	swap a
	and $0f
	ld c, a
	push bc
	call Func_00_101b
	pop bc
	or a
	ret nz
	ldh a, [hEntityY]
	sub $04
	ld b, a
	push bc
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_01_62af
	inc b
	inc b
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret nz
	call Func_01_64bc
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $01
	ld [hl], a
	call Func_01_6475
	ret

Func_01_62af:
	ld hl, $ffb6
	res 3, [hl]
	ret

Func_01_62b5:
	call Func_01_64a1
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $00
	ld [hl], a
	call Func_01_648b
	ret
Func_01_62c5:
	bit 2, a
	jr nz, Func_01_62dd
	and $03
	cp $01
	jp z, Func_01_6347
	cp $02
	jp z, Func_01_639d
	cp $03
	jp z, Func_01_63f3
	jp Func_01_62f1
Func_01_62dd:
	and $03
	cp $01
	jp z, Func_01_6372
	cp $02
	jp z, Func_01_63c8
	cp $03
	jp z, Func_01_641e
	jp Func_01_631c
Func_01_62f1:
	ldh a, [hEntityX]
	add a, $03
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret z
	call Func_01_64f2
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $03
	set 3, a
	ld [hl], a
	call Func_01_645f
	ret
Func_01_631c:
	ldh a, [hEntityX]
	add a, $03
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret z
	call Func_01_64d7
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $02
	set 3, a
	ld [hl], a
	call Func_01_645f
	ret
Func_01_6347:
	ldh a, [hEntityX]
	sub $04
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret z
	call Func_01_64d7
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $02
	set 3, a
	ld [hl], a
	call Func_01_6449
	ret
Func_01_6372:
	ldh a, [hEntityX]
	sub $04
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret z
	call Func_01_64f2
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $03
	set 3, a
	ld [hl], a
	call Func_01_6449
	ret

Func_01_639d:
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	sub $04
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret z
	call Func_01_64a1
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $00
	set 3, a
	ld [hl], a
	call Func_01_6475
	ret
Func_01_63c8:
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	sub $04
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret z
	call Func_01_64bc
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $01
	set 3, a
	ld [hl], a
	call Func_01_6475
	ret
Func_01_63f3:
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $03
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret z
	call Func_01_64bc
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $01
	set 3, a
	ld [hl], a
	call Func_01_648b
	ret
Func_01_641e:
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $03
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	or a
	ret z
	call Func_01_64a1
	ld hl, $ffb6
	ld a, [hl]
	and $fc
	or $00
	set 3, a
	ld [hl], a
	call Func_01_648b
	ret

Func_01_6449:
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	swap a
	and $f0
	sub $08
	add a, $03
	ldh [hEntityX], a
	xor a
	ldh [hEntityXSub], a
	ret
Func_01_645f:
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	swap a
	and $f0
	sub $08
	add a, $0d
	ldh [hEntityX], a
	xor a
	ldh [hEntityXSub], a
	ret
Func_01_6475:
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	swap a
	and $f0
	sub $08
	add a, $03
	ldh [hEntityY], a
	xor a
	ldh [hEntityYSub], a
	ret
Func_01_648b:
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	swap a
	and $f0
	sub $08
	add a, $0d
	ldh [hEntityY], a
	xor a
	ldh [hEntityYSub], a
	ret
Func_01_64a1:
	xor a
	ldh [hEntityTimer], a
	ldh a, [hEntityStatus]
	bit 3, a
	jr nz, Func_01_64b3
	ld a, $11
	ldh [hEntityScriptPtrLo], a
	ld a, $71
	ldh [hEntityScriptPtrHi], a
	ret
Func_01_64b3:
	ld a, $d1
	ldh [hEntityScriptPtrLo], a
	ld a, $70
	ldh [hEntityScriptPtrHi], a
	ret
Func_01_64bc:
	xor a
	ldh [hEntityTimer], a
	ldh a, [hEntityStatus]
	bit 3, a
	jr nz, Func_01_64ce
	ld a, $21
	ldh [hEntityScriptPtrLo], a
	ld a, $71
	ldh [hEntityScriptPtrHi], a
	ret
Func_01_64ce:
	ld a, $e1
	ldh [hEntityScriptPtrLo], a
	ld a, $70
	ldh [hEntityScriptPtrHi], a
	ret
Func_01_64d7:
	xor a
	ldh [hEntityTimer], a
	ldh a, [hEntityStatus]
	bit 3, a
	jr nz, Func_01_64e9
	ld a, $31
	ldh [hEntityScriptPtrLo], a
	ld a, $71
	ldh [hEntityScriptPtrHi], a
	ret
Func_01_64e9:
	ld a, $f1
	ldh [hEntityScriptPtrLo], a
	ld a, $70
	ldh [hEntityScriptPtrHi], a
	ret
Func_01_64f2:
	xor a
	ldh [hEntityTimer], a
	ldh a, [hEntityStatus]
	bit 3, a
	jr nz, Func_01_6504
	ld a, $41
	ldh [hEntityScriptPtrLo], a
	ld a, $71
	ldh [hEntityScriptPtrHi], a
	ret
Func_01_6504:
	ld a, $01
	ldh [hEntityScriptPtrLo], a
	ld a, $71
	ldh [hEntityScriptPtrHi], a
	ret
Func_01_650d:
	ld hl, hHitbox1X
	ldh a, [hEntityX]
	ld c, a
	ldh a, [$ffd6]
	add a, c
	ld [hl+], a
	ldh a, [hEntityY]
	ld b, a
	ldh a, [$ffd7]
	add a, b
	ld [hl+], a
	ldh a, [$ffd8]
	ld [hl+], a
	ldh a, [$ffd9]
	ld [hl], a
	ld hl, $c823
	ld c, $1b
Func_01_6529:
	push bc
	ld a, [hl]
	call Func_00_1290
	bit 1, a
	jr z, Func_01_6567
	ld a, b
	and $f0
	cp $40
	jr nz, Func_01_6544
	push hl
	ld bc, $0003
	add hl, bc
	ld a, [hl]
	pop hl
	cp $ff
	jr z, Func_01_6567
Func_01_6544:
	ld c, $de
	call Func_00_106f
	ldh a, [hHitbox2W]
	or a
	jr z, Func_01_6567
	ldh a, [hHitbox2X]
	add a, c
	ldh [hHitbox2X], a
	ldh a, [hHitbox2Y]
	add a, b
	ldh [hHitbox2Y], a
	call Func_00_0fb0
	or a
	jr z, Func_01_6567
	call Func_01_6570
	or a
	call nz, Func_01_6582
	pop bc
	ret
Func_01_6567:
	pop bc
	ld de, $002a
	add hl, de
	dec c
	jr nz, Func_01_6529
	ret
Func_01_6570:
	call Func_01_6592
	call Func_01_6577
	ret
Func_01_6577:
	ldh a, [hEntityStatus]
	bit 3, a
	jr z, Func_01_657f
	xor a
	ret
Func_01_657f:
	ld a, $01
	ret
Func_01_6582:
	xor a
	ldh [hEntityVelYLo], a
	ldh [hEntityVelYHi], a
	ldh [hEntityTimer], a
	ld a, $b5
	ldh [hEntityScriptPtrLo], a
	ld a, $70
	ldh [hEntityScriptPtrHi], a
	ret
Func_01_6592:
	ld a, [hl]
	cp $39
	jr z, Func_01_6613
	cp $55
	jr z, Func_01_65a6
	cp $54
	jr z, Func_01_65cb
	cp $53
	jr z, Func_01_65e8
	jp Func_01_6634
Func_01_65a6:
	push hl
	ld bc, $0001
	add hl, bc
	ld a, [hl]
	pop hl
	cp $01
	jp nz, Func_01_666a
	ld a, $01
	ld [$cf79], a
	call Func_01_4bec
	ld a, [$c2e4]
	dec a
	ld [$c2e4], a
	jr z, Func_01_660c
	ld a, $b4
	ld [$c2e3], a
	jp Func_01_6666
Func_01_65cb:
	ld a, [$c2e3]
	or a
	jp nz, Func_01_666a
	push hl
	ld bc, $0003
	add hl, bc
	ld b, [hl]
	pop hl
	ld a, b
	and $0f
	cp $02
	jp nz, Func_01_666a
	ld a, $01
	ld [$cf77], a
	jr Func_01_6666
Func_01_65e8:
	ld a, [$c2e3]
	or a
	jr nz, Func_01_666a
	push hl
	ld bc, $0003
	add hl, bc
	ld b, [hl]
	pop hl
	ld a, b
	and $0f
	cp $02
	jr nz, Func_01_666a
	ld a, [$c2e4]
	dec a
	ld [$c2e4], a
	jr z, Func_01_660c
	ld a, $b4
	ld [$c2e3], a
	jr Func_01_6666
Func_01_660c:
	ld a, $01
	ld [$cf78], a
	jr Func_01_6666
Func_01_6613:
	push hl
	ld bc, $0003
	add hl, bc
	ld a, [hl]
	pop hl
	bit 7, a
	jr nz, Func_01_666a
	push hl
	ld bc, $0001
	add hl, bc
	ld a, [hl]
	and $0f
	dec a
	add a, a
	pop hl
	push hl
	ld hl, $666c
	rst AddAToHL
	ld a, [hl+]
	ld b, [hl]
	ld c, a
	pop hl
	jr Func_01_6647
Func_01_6634:
	ld c, [hl]
	ld b, $00
	sla c
	rl b
	push hl
	ld hl, $667c
	add hl, bc
	ld a, [hl+]
	ld b, [hl]
	ld c, a
	pop hl
	or b
	jr z, Func_01_666a
Func_01_6647:
	push de
	push hl
	ld de, $0003
	add hl, de
	ld a, [hl]
	pop hl
	bit 7, a
	jr nz, Func_01_6669
	push hl
	ld de, $0018
	add hl, de
	ld a, c
	ld [hl+], a
	ld a, b
	ld [hl], a
	pop hl
	push hl
	ld de, $0016
	add hl, de
	xor a
	ld [hl], a
	pop hl
	pop de
Func_01_6666:
	ld a, $01
	ret
Func_01_6669:
	pop de
Func_01_666a:
	xor a
	ret

Data_01_666c:
	db $37, $79, $40, $79, $49, $79, $52, $79, $5b, $79, $64, $79, $6d, $79, $76, $79

SECTION "analyzed_0066b8", ROMX[$66b8], BANK[$01]

Data_01_66b8:
	db $00, $00

Data_01_66ba:
	db $e5, $74, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00

Data_01_66dc:
	db $63, $75, $0c, $76, $9f, $76, $0a, $77, $6e, $77, $a5, $77, $e5, $77, $4a, $78
	db $ce, $78

SECTION "analyzed_0066f0", ROMX[$66f0], BANK[$01]

Data_01_66f0:
	db $ca, $79

SECTION "analyzed_0066f4", ROMX[$66f4], BANK[$01]

Data_01_66f4:
	db $00, $00, $00, $00

Data_01_66f8:
	db $00, $00, $00, $00, $b4, $7a, $37, $7b, $c5, $7b, $08, $7c, $9e, $7c, $25, $7d
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $73, $7e, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_01_6740:
	db $a2, $72

SECTION "analyzed_00675c", ROMX[$675c], BANK[$01]

Func_01_675c:
	ld hl, $c81f
	ld a, [wPlayerX]
	ld b, a
	ld a, [hl+]
	add a, b
	ldh [hHitbox1X], a
	ld a, [wPlayerY]
	ld b, a
	ld a, [hl+]
	add a, b
	ldh [hHitbox1Y], a
	ld a, [hl+]
	ldh [hHitbox1W], a
	ld a, [hl]
	ldh [hHitbox1H], a
	call Func_01_6adb
	ld hl, $c823
	ld c, $1b
Func_01_677d:
	push bc
	ld a, [hl]
	or a
	jr z, Func_01_67b5
	and $f0
	cp $50
	jr nz, Func_01_678e
	ld a, [$c2e3]
	or a
	jr nz, Func_01_67b5
Func_01_678e:
	ld a, [hl]
	call Func_00_1290
	bit 0, a
	jr z, Func_01_67b5
	ld c, $de
	call Func_00_106f
	ldh a, [hHitbox2W]
	or a
	jr z, Func_01_67b5
	ldh a, [hHitbox2X]
	add a, c
	ldh [hHitbox2X], a
	ldh a, [hHitbox2Y]
	add a, b
	ldh [hHitbox2Y], a
	call Func_00_0fb0
	or a
	jr z, Func_01_67b5
	push hl
	call Func_01_67be
	pop hl
Func_01_67b5:
	pop bc
	ld de, $002a
	add hl, de
	dec c
	jr nz, Func_01_677d
	ret
Func_01_67be:
	ld a, [hl]
	cp $1f
	jr z, Func_01_67ee
	ld a, [wPlayerStatus]
	bit 0, a
	ret nz
	ld a, [$c2e2]
	cp $02
	jp z, Func_01_6862
	ld a, [hl]
	call Func_00_1290
	bit 4, a
	jr nz, Func_01_67e8
	ld a, [hl]
	and $f0
	cp $40
	jr nz, Func_01_67e4
	call Func_01_686f
	ret
Func_01_67e4:
	call Func_01_4ab6
	ret
Func_01_67e8:
	xor a
	ld [hl], a
	call Func_01_4ab6
	ret
Func_01_67ee:
	ld a, [wPlayerStatus]
	bit 0, a
	ret nz
	xor a
	ld [hl], a
	ld a, [$c2c4]
	inc a
	cp $0a
	jr z, Func_01_6829
	ld [$c2c4], a
	ld de, $000c
	add hl, de
	ld a, [hl+]
	ld e, a
	inc hl
	ld d, [hl]
	ld bc, $0000
	ld a, $08
	ld [wBankCallTmp], a
	ld a, h
	ld [wSpawnPtr], a
	ld a, l
	ld [wSpawnPtr+1], a
	ld a, $03
	ld hl, $4593
	call Func_00_0467
	push af
	ld a, SOUND_SFX_06
	call PlaySound
	pop af
	ret
Func_01_6829:
	ld de, $000c
	add hl, de
	ld a, [hl+]
	ld e, a
	inc hl
	ld d, [hl]
	ld bc, $0000
	ld a, $0c
	ld [wBankCallTmp], a
	ld a, h
	ld [wSpawnPtr], a
	ld a, l
	ld [wSpawnPtr+1], a
	ld a, $03
	ld hl, $4593
	call Func_00_0467
	ld a, [wLives]
	cp $99
	jr z, Func_01_6856
	add a, $01
	daa
	ld [wLives], a
Func_01_6856:
	xor a
	ld [$c2c4], a
	push af
	ld a, SOUND_SFX_08
	call PlaySound
	pop af
	ret
Func_01_6862:
	call Func_01_6592
	or a
	ret z
	push af
	ld a, SOUND_SFX_24
	call PlaySound
	pop af
	ret
Func_01_686f:
	ld a, [wFreeDiscStones]
	or a
	ret z
	ld a, [hl]
	sub $40
	push hl
	ld hl, wMonsterDiscStones
	rst AddAToHL
	ld a, [hl]
	cp $09
	jr z, Func_01_68c8
	inc a
	ld [hl], a
	ld hl, wFreeDiscStones
	dec [hl]
	pop hl
	push hl
	ld a, [hl]
	sub $40
	ld c, a
	FAR_CALL Func_0f_488d
	pop hl
	push hl
	ld de, $000c
	add hl, de
	ld a, [hl+]
	ld e, a
	inc hl
	ld a, [hl]
	sub $08
	ld d, a
	ld bc, $0000
	ld a, $08
	ld [wBankCallTmp], a
	ld a, h
	ld [wSpawnPtr], a
	ld a, l
	ld [wSpawnPtr+1], a
	ld a, $03
	ld hl, $4593
	call Func_00_0467
	pop hl
	xor a
	ld [hl], a
	ld a, $07
	ld [wSceneState], a
	ld c, $04
	call StartRoomAnimation
	ret

Func_01_68c8:
	pop hl
	ret

Func_01_68ca:
	ld hl, $c823
	ld c, $1b
Func_01_68cf:
	push bc
	ld a, [hl]
	call Func_00_1290
	bit 4, a
	jr z, Func_01_68ec
	push hl
	ld de, $0004
	add hl, de
	ld a, [hl]
	pop hl
	bit 0, a
	jr nz, Func_01_68ec
	call Func_01_68f5
	or a
	jr z, Func_01_68ec
	call Func_01_69f5
Func_01_68ec:
	pop bc
	ld de, $002a
	add hl, de
	dec c
	jr nz, Func_01_68cf
	ret
Func_01_68f5:
	push hl
	xor a
	ld [$cf65], a
	push hl
	ld de, $000c
	add hl, de
	ld a, [hl+]
	ld c, a
	inc hl
	ld b, [hl]
	pop hl
	push hl
	ld de, $0026
	add hl, de
	ld a, [hl+]
	add a, c
	ldh [hHitbox1X], a
	ld a, [hl+]
	add a, b
	ldh [hHitbox1Y], a
	ld a, [hl+]
	ldh [hHitbox1W], a
	ld a, [hl]
	ldh [hHitbox1H], a
	pop hl
	ldh a, [hHitbox1X]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hHitbox1Y]
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_102b
	pop bc
	or a
	jr z, Func_01_6949
	cp $22
	jr z, Func_01_693a
	cp $23
	jr nz, Func_01_6944
Func_01_693a:
	push hl
	FAR_CALL BreakTileAtCell
	pop hl
Func_01_6944:
	ld a, $01
	ld [$cf65], a
Func_01_6949:
	ldh a, [hHitbox1X]
	ld c, a
	ldh a, [hHitbox1W]
	add a, c
	dec a
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hHitbox1Y]
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_102b
	pop bc
	or a
	jr z, Func_01_697f
	cp $22
	jr z, Func_01_6970
	cp $23
	jr nz, Func_01_697a
Func_01_6970:
	push hl
	FAR_CALL BreakTileAtCell
	pop hl
Func_01_697a:
	ld a, $01
	ld [$cf65], a
Func_01_697f:
	ldh a, [hHitbox1X]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hHitbox1Y]
	ld b, a
	ldh a, [hHitbox1H]
	add a, b
	dec a
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_102b
	pop bc
	or a
	jr z, Func_01_69b5
	cp $22
	jr z, Func_01_69a6
	cp $23
	jr nz, Func_01_69b0
Func_01_69a6:
	push hl
	FAR_CALL BreakTileAtCell
	pop hl
Func_01_69b0:
	ld a, $01
	ld [$cf65], a
Func_01_69b5:
	ldh a, [hHitbox1X]
	ld c, a
	ldh a, [hHitbox1W]
	add a, c
	dec a
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hHitbox1Y]
	ld b, a
	ldh a, [hHitbox1H]
	add a, b
	dec a
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_102b
	pop bc
	or a
	jr z, Func_01_69f0
	cp $22
	jr z, Func_01_69e1
	cp $23
	jr nz, Func_01_69eb
Func_01_69e1:
	push hl
	FAR_CALL BreakTileAtCell
	pop hl
Func_01_69eb:
	ld a, $01
	ld [$cf65], a
Func_01_69f0:
	pop hl
	ld a, [$cf65]
	ret
Func_01_69f5:
	ld a, [hl]
	cp $2c
	jr z, Func_01_6a05
	cp $28
	jr z, Func_01_6a13
	cp $29
	jr z, Func_01_6a21
	xor a
	ld [hl], a
	ret
Func_01_6a05:
	push hl
	ld bc, $0018
	add hl, bc
	ld a, $6f
	ld [hl+], a
	ld a, $72
	ld [hl], a
	pop hl
	jr Func_01_6a2d
Func_01_6a13:
	push hl
	ld bc, $0018
	add hl, bc
	ld a, $56
	ld [hl+], a
	ld a, $72
	ld [hl], a
	pop hl
	jr Func_01_6a2d
Func_01_6a21:
	push hl
	ld bc, $0018
	add hl, bc
	ld a, $a6
	ld [hl+], a
	ld a, $71
	ld [hl], a
	pop hl
Func_01_6a2d:
	push hl
	ld bc, $0004
	add hl, bc
	set 0, [hl]
	pop hl
	push hl
	ld bc, $0016
	add hl, bc
	xor a
	ld [hl], a
	pop hl
	ret
Func_01_6a3e:
	ld a, [wRoomType]
	cp $02
	ret nz
	ld a, [wActiveFloor]
	cp $02
	ret nz
	ld a, [$c2e4]
	or a
	ret z
	ld a, [$c2e3]
	or a
	ret nz
	ld hl, $c823
	ld c, $1b
Func_01_6a59:
	ld a, [hl]
	cp $60
	jr z, Func_01_6a6a
	cp $61
	jr z, Func_01_6a6a
Func_01_6a62:
	ld de, $002a
	add hl, de
	dec c
	jr nz, Func_01_6a59
	ret
Func_01_6a6a:
	push bc
	push hl
	ld c, $da
	call Func_00_106f
	ldh a, [hHitbox1X]
	add a, c
	ldh [hHitbox1X], a
	ldh a, [hHitbox1Y]
	add a, b
	ldh [hHitbox1Y], a
	ldh a, [hHitbox1W]
	or a
	jr z, Func_01_6aaa
	ld hl, $c823
	ld c, $1b
Func_01_6a85:
	ld a, [hl]
	cp $51
	jr nz, Func_01_6aa3
	push bc
	push hl
	ld c, $de
	call Func_00_106f
	ldh a, [hHitbox2X]
	add a, c
	ldh [hHitbox2X], a
	ldh a, [hHitbox2Y]
	add a, b
	ldh [hHitbox2Y], a
	call Func_00_0fb0
	pop hl
	pop bc
	or a
	jr nz, Func_01_6aae
Func_01_6aa3:
	ld de, $002a
	add hl, de
	dec c
	jr nz, Func_01_6a85
Func_01_6aaa:
	pop hl
	pop bc
	jr Func_01_6a62
Func_01_6aae:
	ld a, [$c2e4]
	dec a
	ld [$c2e4], a
	jr z, Func_01_6ac4
	ld a, $b4
	ld [$c2e3], a
	ld a, $01
	ld [$cf79], a
	pop hl
	pop bc
	ret
Func_01_6ac4:
	push hl
	ld de, $0018
	add hl, de
	ld a, $17
	ld [hl+], a
	ld a, $7e
	ld [hl], a
	pop hl
	push hl
	ld de, $0016
	add hl, de
	xor a
	ld [hl], a
	pop hl
	pop hl
	pop bc
	ret
Func_01_6adb:
	ld a, [wRoomType]
	cp $02
	ret nz
	ld a, [wActiveFloor]
	cp $04
	ret nz
	ldh a, [hHitbox1X]
	ld c, a
	ldh a, [hHitbox1Y]
	ld b, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_103d
	pop bc
	and $f0
	cp $60
	jr z, Func_01_6b6a
	ldh a, [hHitbox1W]
	add a, c
	dec a
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_103d
	pop bc
	and $f0
	cp $60
	jr z, Func_01_6b6a
	ldh a, [hHitbox1X]
	ld c, a
	ldh a, [hHitbox1H]
	add a, b
	dec a
	ld b, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_103d
	pop bc
	and $f0
	cp $60
	jr z, Func_01_6b6a
	ldh a, [hHitbox1W]
	add a, c
	dec a
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_103d
	pop bc
	and $f0
	cp $60
	ret nz

Func_01_6b6a:
	call Func_01_4ab6
	ret

Func_01_6b6e:
	ld hl, $c823
	ld c, $1b
Func_01_6b73:
	ld a, [hl]
	cp $41
	jr z, Func_01_6b7c
	cp $38
	jr nz, Func_01_6baa
Func_01_6b7c:
	push hl
	ld de, $0003
	add hl, de
	ld a, [hl]
	pop hl
	cp $05
	jr z, Func_01_6b8d
	cp $06
	jr z, Func_01_6b8d
	jr Func_01_6baa
Func_01_6b8d:
	call Func_01_6bdc
	call Func_01_6c2a
	or a
	jr nz, Func_01_6ba1
	call Func_01_6c03
	ld d, h
	ld e, l
	call Func_01_6c8c
	or a
	jr z, Func_01_6baa
Func_01_6ba1:
	ld a, [hl]
	cp $38
	jr z, Func_01_6bb2

Data_01_6ba6:
	db $fe, $41, $28, $1d

Func_01_6baa:
	ld de, $002a
	add hl, de
	dec c
	jr nz, Func_01_6b73
	ret
Func_01_6bb2:
	push hl
	ld de, $0018
	add hl, de
	ld a, $ce
	ld [hl+], a
	ld a, $78
	ld [hl], a
	pop hl
	push hl
	ld de, $0016
	add hl, de
	xor a
	ld [hl], a
	pop hl
	ret

Data_01_6bc7:
	db $e5, $11, $18, $00, $19, $3e, $37, $22, $3e, $7b, $77, $e1, $e5, $11, $16, $00
	db $19, $af, $77, $e1, $c9

Func_01_6bdc:
	push hl
	ld de, $0022
	add hl, de
	ld a, [hl+]
	ldh [hHitbox1X], a
	ld a, [hl+]
	ldh [hHitbox1Y], a
	ld a, [hl+]
	ldh [hHitbox1W], a
	ld a, [hl]
	ldh [hHitbox1H], a
	pop hl
	push hl
	ld de, $000c
	add hl, de
	ld a, [hl+]
	ld d, a
	ldh a, [hHitbox1X]
	add a, d
	ldh [hHitbox1X], a
	inc hl
	ld d, [hl]
	ldh a, [hHitbox1Y]
	add a, d
	ldh [hHitbox1Y], a
	pop hl
	ret
Func_01_6c03:
	push hl
	ld de, $0026
	add hl, de
	ld a, [hl+]
	ldh [hHitbox1X], a
	ld a, [hl+]
	ldh [hHitbox1Y], a
	ld a, [hl+]
	ldh [hHitbox1W], a
	ld a, [hl]
	ldh [hHitbox1H], a
	pop hl
	push hl
	ld de, $000c
	add hl, de
	ld a, [hl+]
	ld d, a
	ldh a, [hHitbox1X]
	add a, d
	ldh [hHitbox1X], a
	inc hl
	ld d, [hl]
	ldh a, [hHitbox1Y]
	add a, d
	ldh [hHitbox1Y], a
	pop hl
	ret
Func_01_6c2a:
	push bc
	push hl
	push hl
	ld de, $0006
	add hl, de
	ld a, [hl]
	pop hl
	and $03
	cp $00
	jr z, Func_01_6c41
	cp $01
	jr z, Func_01_6c68

Data_01_6c3d:
	db $e1, $c1, $af, $c9

Func_01_6c41:
	ldh a, [hHitbox1W]
	ld c, a
	ldh a, [hHitbox1X]
	add a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hHitbox1H]
	sra a
	ld b, a
	ldh a, [hHitbox1Y]
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	FAR_CALL BreakTileAtCell
	pop hl
	pop bc
	ret
Func_01_6c68:
	ldh a, [hHitbox1X]
	dec a
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hHitbox1H]
	sra a
	ld b, a
	ldh a, [hHitbox1Y]
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	FAR_CALL BreakTileAtCell
	pop hl
	pop bc
	ret
Func_01_6c8c:
	push bc
	push hl
	ld hl, $c823
	ld c, $1b
Func_01_6c93:
	push bc
	push hl
	ld a, d
	cp h
	jr nz, Func_01_6c9d
	ld a, e
	cp l
	jr z, Func_01_6cd3
Func_01_6c9d:
	ld a, [hl]
	cp $41
	jr z, Func_01_6ca6
	cp $38
	jr nz, Func_01_6cb9
Func_01_6ca6:
	push hl
	ld bc, $0003
	add hl, bc
	ld a, [hl]
	pop hl
	cp $03
	jr z, Func_01_6cb9
	ld a, [hl]
	call Func_00_1290
	bit 0, a
	jr z, Func_01_6cd3
Func_01_6cb9:
	ld c, $de
	call Func_00_106f
	ldh a, [hHitbox2W]
	or a
	jr z, Func_01_6cd3
	ldh a, [hHitbox2X]
	add a, c
	ldh [hHitbox2X], a
	ldh a, [hHitbox2Y]
	add a, b
	ldh [hHitbox2Y], a
	call Func_00_0fb0
	or a
	jr nz, Func_01_6ce0
Func_01_6cd3:
	pop hl
	ld bc, $002a
	add hl, bc
	pop bc
	dec c
	jr nz, Func_01_6c93
	pop hl
	pop bc
	xor a
	ret
Func_01_6ce0:
	pop hl
	push hl
	ld bc, $0003
	add hl, bc
	ld a, [hl]
	pop hl
	cp $03
	jr nz, Func_01_6cf5
	ld a, [hl]
	cp $38
	jr z, Func_01_6cfe

Data_01_6cf1:
	db $fe, $41, $28, $1e

Func_01_6cf5:
	call Func_01_6592
	pop bc
	pop hl
	pop bc
	ld a, $01
	ret
Func_01_6cfe:
	push hl
	ld bc, $0018
	add hl, bc
	ld a, $a5
	ld [hl+], a
	ld a, $78
	ld [hl], a
	pop hl
	call Func_01_6d28
	pop bc
	pop hl
	pop bc
	ld a, $01
	ret

Data_01_6d13:
	db $e5, $01, $18, $00, $09, $3e, $0e, $22, $3e, $7b, $77, $e1, $cd, $28, $6d, $c1
	db $e1, $c1, $3e, $01, $c9

Func_01_6d28:
	push hl
	ld bc, $0016
	add hl, bc
	xor a
	ld [hl], a
	pop hl
	push hl
	ld hl, $0006
	add hl, de
	ld d, [hl]
	pop hl
	push hl
	ld bc, $0006
	add hl, bc
	bit 7, d
	jr z, Func_01_6d44

Data_01_6d40:
	db $cb, $fe, $18, $02

Func_01_6d44:
	res 7, [hl]
	pop hl
	ret
Func_01_6d48:
	ldh a, [hEntityState]
	add a, a
	ld c, a
	ld b, $00
	ld hl, $6d56
	add hl, bc
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp hl

Func_01_6d56:
	ld [hl], $6e

Data_01_6d58:
	db $af, $6e, $36, $6e, $36, $6e, $36, $6e, $36, $6e, $36, $6e, $36, $6e, $36, $6e
	db $36, $6e, $37, $6e, $37, $6e, $37, $6e, $36, $6e, $37, $6e, $37, $6e, $37, $6e
	db $37, $6e, $37, $6e, $37, $6e, $37, $6e

Data_01_6d80:
	db $37, $6e

Data_01_6d82:
	db $37, $6e, $37, $6e, $37, $6e, $37, $6e, $37, $6e, $37, $6e

Data_01_6d8e:
	db $36, $6e, $36, $6e

Data_01_6d92:
	db $36, $6e, $d0, $6e, $36, $6e, $36, $6e

Data_01_6d9a:
	db $36, $6e

Data_01_6d9c:
	db $36, $6e, $36, $6e, $36, $6e

Data_01_6da2:
	db $37, $6e

Data_01_6da4:
	db $37, $6e, $37, $6e, $37, $6e, $37, $6e

Data_01_6dac:
	db $37, $6e

Data_01_6dae:
	db $37, $6e, $37, $6e, $37, $6e, $37, $6e, $48, $6e, $48, $6e, $48, $6e, $48, $6e
	db $48, $6e, $48, $6e, $48, $6e, $48, $6e, $48, $6e, $37, $6e, $48, $6e, $48, $6e
	db $48, $6e, $37, $6e, $37, $6e, $37, $6e, $48, $6e, $48, $6e, $48, $6e, $48, $6e
	db $48, $6e, $48, $6e

Data_01_6de2:
	db "6n6n6n6n6n6n6n6n6n6n"

Data_01_6df6:
	db $55, $6e, $95, $6e, $65, $6e, $75, $6e, $85, $6e, $a5, $6e

Data_01_6e02:
	db "6n6n6n6n6n6n6n6n6n6n"

Data_01_6e16:
	db $3e, $6e, $3e, $6e, $36, $6e, $36, $6e

Data_01_6e1e:
	db "6n6n6n6n6n6n6n6n6n6n6n6n"

Func_01_6e36:
	ret
	call Func_01_6f07
	call Func_01_6f3a
	ret
	call Func_01_6f07
	call Func_01_6f3a
	call Func_01_755b
	ret
	call Func_01_6f07
	call Func_01_70e3
	call Func_01_6f3a
	call Func_01_6fff
	ret
	call Func_01_6f07
	call Func_01_740b
	call Func_01_716f
	call Func_01_6f3a
	call Func_01_704b
	ret
	call Func_01_6f07
	call Func_01_740b
	call Func_01_716f
	call Func_01_6f3a
	call Func_01_704b
	ret
	call Func_01_6f07
	call Func_01_740b
	call Func_01_716f
	call Func_01_6f3a
	call Func_01_704b
	ret
	call Func_01_6f07
	call Func_01_7435
	call Func_01_716f
	call Func_01_6f3a
	call Func_01_704b
	ret
	call Func_01_6f07
	call Func_01_740b
	call Func_01_716f
	call Func_01_6f3a
	call Func_01_7097
	ret
	call Func_01_6f07
	call Func_01_7499
	call Func_01_6f3a
	ret
	ldh a, [hEntityStatus]
	bit 1, a
	jr z, Func_01_6ebd
	ldh a, [hEntityFacing]
	and $03
	call Func_01_716f
	ret
Func_01_6ebd:
	call Func_01_6f07
	call Func_01_716f
	call Func_01_6f3a
	call Func_01_6fff
	call Func_01_6eda
	call CheckItemPickup
	ret
	call Func_01_6f07
	call Func_01_716f
	call Func_01_6fc4
	ret
Func_01_6eda:
	ldh a, [hEntityStatus]
	bit 7, a
	ret z
	ld a, [$cf7f]
	bit 0, a
	ret nz
	bit 7, a
	jr z, Func_01_6ef9
	ldh a, [hJoyPressed]
	bit 6, a
	ret z
	ld a, [$cf7f]
	res 7, a
	set 0, a
	ld [$cf7f], a
	ret
Func_01_6ef9:
	ldh a, [hJoyHeld]
	bit 6, a
	ret nz
	ld a, [$cf7f]
	set 7, a
	ld [$cf7f], a
	ret
Func_01_6f07:
	ldh a, [hEntityFacing]
	and $03
	cp $01
	jr z, Func_01_6f16
	cp $00
	jr z, Func_01_6f28
	ld a, $ff
	ret
Func_01_6f16:
	ldh a, [hEntityVelXLo]
	ld e, a
	ldh a, [hEntityVelXHi]
	ld d, a
	ld c, $bb
	ldh a, [c]
	sub e
	ldh [c], a
	inc c
	ldh a, [c]
	sbc a, d
	ldh [c], a
	ld a, $01
	ret
Func_01_6f28:
	ldh a, [hEntityVelXLo]
	ld e, a
	ldh a, [hEntityVelXHi]
	ld d, a
	ld c, $bb
	ldh a, [c]
	add a, e
	ldh [c], a
	inc c
	ldh a, [c]
	adc a, d
	ldh [c], a
	ld a, $00
	ret
Func_01_6f3a:
	ldh a, [hEntityStatus]
	bit 7, a
	jr nz, Func_01_6f6b
	ldh a, [hEntityFacing]
	and $03
	cp $02
	jr z, Func_01_6f5b
	cp $03
	ret nz
	ldh a, [hEntityVelXLo]
	ld e, a
	ldh a, [hEntityVelXHi]
	ld d, a
	ld c, $bd
	ldh a, [c]
	add a, e
	ldh [c], a
	inc c
	ldh a, [c]
	adc a, d
	ldh [c], a
	ret
Func_01_6f5b:
	ldh a, [hEntityVelXLo]
	ld e, a
	ldh a, [hEntityVelXHi]
	ld d, a
	ld c, $bd
	ldh a, [c]
	sub e
	ldh [c], a
	inc c
	ldh a, [c]
	sbc a, d
	ldh [c], a
	ret
Func_01_6f6b:
	ldh a, [hEntityState]
	cp $51
	jr z, Func_01_6f75
	call Func_01_6f7c
	ret
Func_01_6f75:
	call Func_01_6f8e
	call Func_01_7512
	ret
Func_01_6f7c:
	ldh a, [hEntityActionTimer]
	cp $28
	jr z, Func_01_6f85
	inc a
	ldh [hEntityActionTimer], a
Func_01_6f85:
	push hl
	ld hl, $7b6b
	call Func_01_6fb2
	pop hl
	ret
Func_01_6f8e:
	ldh a, [hEntityActionTimer]
	cp $3d
	jr z, Func_01_6f97
	inc a
	ldh [hEntityActionTimer], a
Func_01_6f97:
	ldh a, [hEntityVelYLo]
	or a
	jr z, Func_01_6fa7
	push hl
	ld hl, $7c39
	ldh a, [hEntityActionTimer]
	call Func_01_6fb2
	pop hl
	ret
Func_01_6fa7:
	push hl
	ld hl, $7bbd
	ldh a, [hEntityActionTimer]
	call Func_01_6fb2
	pop hl
	ret
Func_01_6fb2:
	add a, a
	ld c, a
	ld b, $00
	add hl, bc
	ld a, [hl+]
	ld e, a
	ld d, [hl]
	ld c, $bd
	ldh a, [c]
	add a, e
	ldh [c], a
	inc c
	ldh a, [c]
	adc a, d
	ldh [c], a
	ret
Func_01_6fc4:
	ldh a, [hEntityType]
	cp $01
	ret nz
	push de
	ldh a, [hEntityY]
	ld h, a
	ld a, [wPlayerY]
	sub $08
	cp h
	jr nc, Func_01_6fe9
	sub h
	ld d, $00
	ld e, a
	srl e
	ldh a, [hEntityYSub]
	sub e
	ldh [hEntityYSub], a
	ld a, h
	sbc a, d
	ldh [hEntityY], a
	pop de
	call Func_01_7265
	ret
Func_01_6fe9:
	ld d, a
	ld a, h
	sub d
	ld d, $00
	ld e, a
	srl e
	ldh a, [hEntityYSub]
	add a, e
	ldh [hEntityYSub], a
	ld a, h
	adc a, d
	ldh [hEntityY], a
	pop de
	call Func_01_7210
	ret
Func_01_6fff:
	ldh a, [hEntityStatus]
	bit 1, a
	ret nz
	bit 7, a
	jr nz, Func_01_701a
	call Func_01_72b5
	or a
	jr z, Func_01_7014
Func_01_700e:
	ld hl, $ffb6
	set 3, [hl]
	ret
Func_01_7014:
	ld hl, $ffb6
	res 3, [hl]
	ret
Func_01_701a:
	ldh a, [hEntityActionTimer]
	cp $15
	ret c
	call Func_01_72b5
	or a
	jr z, Func_01_7014
	ldh a, [hEntityProbeY]
	ld b, a
	ldh a, [hEntityProbeH]
	ld c, a
	ldh a, [hEntityY]
	add a, b
	add a, c
	add a, $08
	swap a
	and $0f
	swap a
	and $f0
	sub $08
	sub c
	sub b
	ldh [hEntityY], a
	xor a
	ldh [hEntityYSub], a
	ldh [hEntityActionTimer], a
	ld hl, $ffb4
	res 7, [hl]
	jr Func_01_700e
Func_01_704b:
	ldh a, [hEntityStatus]
	bit 1, a
	ret nz
	bit 7, a
	jr nz, Func_01_7066
	call Func_01_72f3
	or a
	jr z, Func_01_7060
Func_01_705a:
	ld hl, $ffb6
	set 3, [hl]
	ret
Func_01_7060:
	ld hl, $ffb6
	res 3, [hl]
	ret
Func_01_7066:
	ldh a, [hEntityActionTimer]
	cp $15
	ret c
	call Func_01_72f3
	or a
	jr z, Func_01_7060
	ldh a, [hEntityProbeY]
	ld b, a
	ldh a, [hEntityProbeH]
	ld c, a
	ldh a, [hEntityY]
	add a, b
	add a, c
	add a, $08
	swap a
	and $0f
	swap a
	and $f0
	sub $08
	sub c
	sub b
	ldh [hEntityY], a
	xor a
	ldh [hEntityYSub], a
	ldh [hEntityActionTimer], a
	ld hl, $ffb4
	res 7, [hl]
	jr Func_01_705a
Func_01_7097:
	ldh a, [hEntityStatus]
	bit 1, a
	ret nz
	bit 7, a
	jr nz, Func_01_70b2
	call Func_01_7373
	or a
	jr z, Func_01_70ac
Func_01_70a6:
	ld hl, $ffb6
	set 3, [hl]
	ret
Func_01_70ac:
	ld hl, $ffb6
	res 3, [hl]
	ret
Func_01_70b2:
	ldh a, [hEntityActionTimer]
	cp $1f
	ret c
	call Func_01_7373
	or a
	jr z, Func_01_70ac
	ldh a, [hEntityProbeY]
	ld b, a
	ldh a, [hEntityProbeH]
	ld c, a
	ldh a, [hEntityY]
	add a, b
	add a, c
	add a, $08
	swap a
	and $0f
	swap a
	and $f0
	sub $08
	sub c
	sub b
	ldh [hEntityY], a
	xor a
	ldh [hEntityYSub], a
	ldh [hEntityActionTimer], a
	ld hl, $ffb4
	res 7, [hl]
	jr Func_01_70a6
Func_01_70e3:
	cp $00
	jr z, Func_01_7129
	cp $01
	ret nz
	ldh a, [hEntityProbeW]
	or a
	ret z
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeY]
	add a, b
	ld b, a
	ldh a, [hEntityProbeH]
	dec a
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	ret z
	ld a, c
	swap a
	and $f0
	sub $08
	add a, $10
	ld c, a
	ldh a, [hEntityProbeX]
	ld b, a
	ld a, c
	sub b
	ldh [hEntityX], a
	xor a
	ldh [hEntityXSub], a
	ret
Func_01_7129:
	ldh a, [hEntityProbeW]
	or a
	ret z
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityProbeW]
	add a, c
	dec a
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeY]
	add a, b
	ld b, a
	ldh a, [hEntityProbeH]
	dec a
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	call Func_00_101b
	pop bc
	or a
	ret z
	ldh a, [hEntityProbeW]
	ld b, a
	ld a, c
	swap a
	and $f0
	sub $08
	sub b
	ld c, a
	ldh a, [hEntityProbeX]
	ld b, a
	ld a, c
	sub b
	ldh [hEntityX], a
	xor a
	ldh [hEntityXSub], a
	ret
Func_01_716f:
	ldh a, [hEntityProbeH]
	or a
	ret z
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeY]
	add a, b
	ld b, a
	push bc
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	jr nz, Func_01_71ac
	ldh a, [hEntityProbeH]
	dec a
	add a, b
	ld b, a
	push bc
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_01_71c1
Func_01_71ac:
	ld a, c
	swap a
	and $f0
	sub $08
	add a, $10
	ld c, a
	ldh a, [hEntityProbeX]
	ld b, a
	ld a, c
	sub b
	ldh [hEntityX], a
	xor a
	ldh [hEntityXSub], a
	ret
Func_01_71c1:
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityProbeW]
	dec a
	add a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	push bc
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	jr nz, Func_01_71f9
	ldh a, [hEntityProbeH]
	dec a
	ld l, a
	ld a, b
	sub l
	ld b, a
	push bc
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	ret z
Func_01_71f9:
	ldh a, [hEntityProbeW]
	ld b, a
	ld a, c
	swap a
	and $f0
	sub $08
	sub b
	ld c, a
	ldh a, [hEntityProbeX]
	ld b, a
	ld a, c
	sub b
	ldh [hEntityX], a
	xor a
	ldh [hEntityXSub], a
	ret
Func_01_7210:
	ldh a, [hEntityProbeH]
	or a
	ret z
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeY]
	add a, b
	ld b, a
	ldh a, [hEntityProbeH]
	dec a
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	pop bc
	or a
	jr nz, Func_01_7251
	ldh a, [hEntityProbeW]
	dec a
	add a, c
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	pop bc
	or a
	ret z
Func_01_7251:
	ldh a, [hEntityProbeH]
	sra a
	ld b, a
	ldh a, [hEntityY]
	sub $08
	and $f0
	add a, $08
	add a, b
	ldh [hEntityY], a
	xor a
	ldh [hEntityYSub], a
	ret
Func_01_7265:
	ldh a, [hEntityProbeH]
	or a
	ret z
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeY]
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	pop bc
	or a
	jr nz, Func_01_72a1
	ldh a, [hEntityProbeW]
	dec a
	add a, c
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	pop bc
	or a
	ret z
Func_01_72a1:
	ldh a, [hEntityProbeH]
	sra a
	ld b, a
	ldh a, [hEntityY]
	sub $08
	and $f0
	add a, $18
	sub b
	ldh [hEntityY], a
	xor a
	ldh [hEntityYSub], a
	ret
Func_01_72b5:
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeY]
	add a, b
	ld b, a
	ldh a, [hEntityProbeH]
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	pop bc
	or a
	jr nz, Func_01_72ee
	ldh a, [hEntityProbeW]
	dec a
	add a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	call Func_00_101b
	or a
	jr z, Func_01_72f1
Func_01_72ee:
	ld a, $01
	ret
Func_01_72f1:
	xor a
	ret
Func_01_72f3:
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeY]
	add a, b
	ld b, a
	ldh a, [hEntityProbeH]
	add a, b
	ld b, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	jr nz, Func_01_736e
	dec c
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	jr nz, Func_01_736e
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	jr nz, Func_01_736e
	ldh a, [hEntityProbeW]
	dec a
	add a, c
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	jr z, Func_01_7371
Func_01_736e:
	ld a, $01
	ret
Func_01_7371:
	xor a
	ret
Func_01_7373:
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeY]
	add a, b
	ld b, a
	ldh a, [hEntityProbeH]
	add a, b
	ld b, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	cp $20
	jr z, Func_01_7408
	cp $21
	jr z, Func_01_7408
	dec c
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	cp $20
	jr z, Func_01_7408
	cp $21
	jr z, Func_01_7408
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	cp $20
	jr z, Func_01_7408
	cp $21
	jr z, Func_01_7408
	ldh a, [hEntityProbeW]
	dec a
	add a, c
	ld c, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_00_101b
	pop bc
	or a
	cp $20
	jr z, Func_01_7408
	cp $21
	jr z, Func_01_7408
	xor a
	ret
Func_01_7408:
	ld a, $01
	ret
Func_01_740b:
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeY]
	add a, b
	ld b, a
	ldh a, [hEntityFacing]
	and $03
	cp $01
	jr z, Func_01_742a
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityProbeW]
	add a, c
	dec a
	ld c, a
	call Func_01_74c4
	ret
Func_01_742a:
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	call Func_01_74c4
	ret
Func_01_7435:
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeY]
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	FAR_CALL BreakTileAtCell
	pop bc
	inc c
	push bc
	FAR_CALL BreakTileAtCell
	pop bc
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeY]
	add a, b
	ld b, a
	ldh a, [hEntityProbeH]
	dec a
	add a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	push bc
	FAR_CALL BreakTileAtCell
	pop bc
	inc c
	push bc
	FAR_CALL BreakTileAtCell
	pop bc
	ret
Func_01_7499:
	ldh a, [hEntityY]
	ld b, a
	ldh a, [$ffd7]
	add a, b
	ld b, a
	ldh a, [hEntityX]
	ld c, a
	push bc
	call Func_01_74dd
	pop bc
	ldh a, [hEntityX]
	ld c, a
	ldh a, [$ffd6]
	add a, c
	ld c, a
	ldh a, [$ffd8]
	add a, c
	dec a
	ld c, a
	push bc
	call Func_01_74dd
	pop bc
	ldh a, [hEntityX]
	ld c, a
	ldh a, [$ffd6]
	add a, c
	ld c, a
	call Func_01_74dd
	ret
Func_01_74c4:
	push de
	push bc
	FAR_CALL BreakTileAtPixel
	pop bc
	ld a, $10
	add a, b
	ld b, a
	FAR_CALL BreakTileAtPixel
	pop de
	ret
Func_01_74dd:
	push de
	push bc
	FAR_CALL BreakTileAtPixel
	pop bc
	ld a, $10
	add a, b
	ld b, a
	push bc
	FAR_CALL BreakTileAtPixel
	pop bc
	ld a, $10
	add a, b
	ld b, a
	push bc
	FAR_CALL BreakTileAtPixel
	pop bc
	ld a, $0f
	add a, b
	ld b, a
	FAR_CALL BreakTileAtPixel
	pop de
	ret
Func_01_7512:
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityActionTimer]
	cp $1f
	jr c, Func_01_752d
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeY]
	add a, b
	ld b, a
	ldh a, [hEntityProbeH]
	add a, b
	dec a
	ld b, a
	jr Func_01_7534
Func_01_752d:
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeY]
	add a, b
	ld b, a
Func_01_7534:
	push de
	push bc
	FAR_CALL BreakTileAtPixel
	pop bc
	ld a, $10
	add a, c
	ld c, a
	push bc
	FAR_CALL BreakTileAtPixel
	pop bc
	ld a, $10
	add a, c
	ld c, a
	FAR_CALL BreakTileAtPixel
	pop de
	ret
Func_01_755b:
	ldh a, [hEntityFacing]
	and $03
	cp $02
	jr z, Func_01_7571
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeY]
	add a, b
	ld b, a
	ldh a, [hEntityProbeH]
	add a, b
	dec a
	ld b, a
	jr Func_01_7578
Func_01_7571:
	ldh a, [hEntityY]
	ld b, a
	ldh a, [hEntityProbeY]
	add a, b
	ld b, a
Func_01_7578:
	push de
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	push bc
	FAR_CALL BreakTileAtPixel
	pop bc
	ldh a, [hEntityX]
	ld c, a
	push bc
	FAR_CALL BreakTileAtPixel
	pop bc
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityProbeX]
	add a, c
	ld c, a
	ldh a, [hEntityProbeW]
	add a, c
	dec a
	ld c, a
	FAR_CALL BreakTileAtPixel
	pop de
	ret
Func_01_75ad:
	ld a, [wRoomType]
	cp $02
	jr z, Func_01_75b9
	ld hl, $75cc
	jr Func_01_75bc
Func_01_75b9:
	ld hl, $75e1
Func_01_75bc:
	ld de, $9c00
	call Func_01_76dd
	call Func_01_7608
	call Func_01_775b
	call Func_01_77d2
	ret

Data_01_75cc:
	db $64, $2d, $30, $30, $30, $30, $30, $20, $65, $2a, $30, $20, $20, $20, $20, $20
	db $20, $20, $20, $20, $00, $4c, $49, $46, $45, $6a, $6a, $6a, $20, $65, $2a, $30
	db $20, $20, $20, $20, $20, $20, $20, $20, $20, $00

Func_01_75f6:
	ld a, [wProgressFlags]
	bit 5, a
	ret nz
	ld a, [$c2db]
	or a
	ret nz
	call Func_01_4562
	call Func_01_7608
	ret
Func_01_7608:
	ld hl, $c532
	ld bc, wFloorTimer+2
	ld a, [bc]
	and $0f
	add a, $9a
	ld [hl+], a
	dec bc
	ld a, [bc]
	swap a
	and $0f
	add a, $9a
	ld [hl+], a
	ld a, [bc]
	and $0f
	add a, $9a
	ld [hl+], a
	dec bc
	ld a, [bc]
	swap a
	and $0f
	add a, $9a
	ld [hl+], a
	ld a, [bc]
	and $0f
	add a, $9a
	ld [hl+], a
	ld a, [$c2c4]
	add a, $9a
	ld [hl+], a
	call Func_01_763c
	ret
Func_01_763c:
	ld hl, $c2d0
	ld a, [$c2e2]
	cp $03
	jr z, Func_01_764d
	ld a, [hl]
	inc a
	and $1f
	ld [hl], a
	jr Func_01_764e
Func_01_764d:
	ld a, [hl]
Func_01_764e:
	srl a
	srl a
	srl a
	ld [$cf65], a
	ld a, [wBombLargeFlags]
	ld b, a
	ld c, $00
	ld a, [wBombCount]
	ld d, a
	ld a, [wBombCapacity]
	ld e, a
	ld hl, $c538
Func_01_7668:
	xor a
	or e
	jr z, Func_01_769b
	xor a
	or d
	jr z, Func_01_7696
	bit 0, b
	jr z, Func_01_7685
	push hl
	ld a, [$cf65]
	add a, $d9
	ld l, a
	ld a, $76
	adc a, $00
	ld h, a
	ld a, [hl]
	pop hl
	ld [hl+], a
	jr Func_01_769e
Func_01_7685:
	push hl
	ld a, [$cf65]
	add a, $d5
	ld l, a
	ld a, $76
	adc a, $00
	ld h, a
	ld a, [hl]
	pop hl
	ld [hl+], a
	jr Func_01_769e
Func_01_7696:
	ld a, $ad
	ld [hl+], a
	jr Func_01_769e
Func_01_769b:
	ld a, $fc
	ld [hl+], a
Func_01_769e:
	srl b
	call Func_01_76cb
	call Func_01_76d0
	inc c
	ld a, c
	cp $08
	jr nz, Func_01_7668
	ld c, $00
	ld a, [wBombCapacity]
	ld e, a
	ld hl, $c540
Func_01_76b5:
	xor a
	or e
	jr z, Func_01_76be
	ld a, $0f
	ld [hl+], a
	jr Func_01_76c1
Func_01_76be:
	ld a, $08
	ld [hl+], a
Func_01_76c1:
	call Func_01_76cb
	inc c
	ld a, c
	cp $08
	jr nz, Func_01_76b5
	ret
Func_01_76cb:
	ld a, e
	or a
	ret z
	dec e
	ret
Func_01_76d0:
	ld a, d
	or a
	ret z
	dec d
	ret

Data_01_76d5:
	db $ae, $af, $b0, $af, $a8, $a9, $aa, $a9

Func_01_76dd:
	xor a
	ldh [rVBK], a
	push hl
	push de
Func_01_76e2:
	ld a, [hl+]
	or a
	jr z, Func_01_76f2
	call Func_01_7715
	push af
	call WaitForHBlank
	pop af
	ld [de], a
	inc de
	jr Func_01_76e2
Func_01_76f2:
	pop de
	pop hl
	ld a, $01
	ldh [rVBK], a
Func_01_76f8:
	ld a, [hl+]
	or a
	ret z
	call Func_01_7715
	cp $a8
	jr c, Func_01_7706
	cp $b8
	jr c, Func_01_770a
Func_01_7706:
	ld a, $08
	jr Func_01_770c
Func_01_770a:
	ld a, $0f
Func_01_770c:
	push af
	call WaitForHBlank
	pop af
	ld [de], a
	inc de
	jr Func_01_76f8
Func_01_7715:
	cp $2a
	jr z, Func_01_7740
	cp $3f
	jr z, Func_01_7743
	cp $3d
	jr z, Func_01_7746
	cp $2d
	jr z, Func_01_7749
	cp $30
	jr c, Func_01_773d
	cp $3a
	jr c, Func_01_774c
	cp $41
	jr c, Func_01_773d
	cp $5b
	jr c, Func_01_7751
	cp $61
	jr c, Func_01_773d
	cp $7b
	jr c, Func_01_7756
Func_01_773d:
	ld a, $fc
	ret
Func_01_7740:
	ld a, $a4
	ret
Func_01_7743:
	ld a, $a5
	ret

Func_01_7746:
	ld a, $a6
	ret

Func_01_7749:
	ld a, $a7
	ret
Func_01_774c:
	sub $30
	add a, $9a
	ret
Func_01_7751:
	sub $41
	add a, $80
	ret
Func_01_7756:
	sub $61
	add a, $a8
	ret
Func_01_775b:
	ld a, [$c2db]
	cp $04
	ret z
	xor a
	ldh [rVBK], a
	ld a, [wRoomType]
	cp $02
	jr z, Func_01_7782
	ld hl, $c532
	ld de, $9c02
	call WaitForHBlank
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
Func_01_7782:
	ld hl, $c537
	ld de, $9c0a
	call WaitForHBlank
	ld a, [hl+]
	ld [de], a
	ld de, $9c0c
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
	call WaitForHBlank
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
	ld a, $01
	ldh [rVBK], a
	ld de, $9c0c
	call WaitForHBlank
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
	call WaitForHBlank
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	xor a
	ldh [rVBK], a
	ret
Func_01_77d2:
	ld a, [wRoomType]
	cp $02
	ret nz
	xor a
	ldh [rVBK], a
	ld a, [$c2c5]
	cp $01
	jr z, Func_01_77f6
	cp $02
	jr z, Func_01_7803
	cp $03
	jr z, Func_01_7810
	ld hl, $9c04
	call WaitForHBlank
	ld a, $b2
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
	ret
Func_01_77f6:
	ld hl, $9c04
	call WaitForHBlank
	ld a, $b1
	ld [hl+], a
	inc a
	ld [hl+], a
	ld [hl], a
	ret
Func_01_7803:
	ld hl, $9c04
	call WaitForHBlank
	ld a, $b1
	ld [hl+], a
	ld [hl+], a
	inc a
	ld [hl], a
	ret
Func_01_7810:
	ld hl, $9c04
	call WaitForHBlank
	ld a, $b1
	ld [hl+], a
	ld [hl+], a
	ld [hl], a
	ret

SECTION "analyzed_00781f", ROMX[$781f], BANK[$01]

Data_01_781f:
	db $01, $01, $01, $02, $00, $00, $03, $00, $00, $04, $00, $00, $05, $00, $00, $06
	db $00, $00, $07, $00, $00, $08, $00, $00, $09, $00, $00, $0a, $00, $00, $0b, $00
	db $00, $0c, $00, $00, $0d, $00, $00, $0e, $00, $00, $0f, $00, $00, $10, $00, $00
	db $11, $00, $00, $12, $00, $00, $13, $00, $00, $14, $00, $00

Data_01_785b:
	db $15, $00, $00

Data_01_785e:
	db $16, $00, $00, $17, $00, $00, $18, $00, $00, $19, $00, $00, $1a, $00, $00, $1b
	db $00, $00

Data_01_7870:
	db $1c, $00, $00, $00, $00, $00

Data_01_7876:
	db $1e, $03, $03, $1f, $02, $02, $20, $00, $00, $21, $00, $00

Data_01_7882:
	db $22, $00, $00

Data_01_7885:
	db $23, $00, $00, $24, $00, $00, $25, $00, $00

Data_01_788e:
	db $26, $00, $00

Data_01_7891:
	db $27, $00, $00, $28, $00, $00, $29, $00, $00, $2a, $00, $00

Data_01_789d:
	db $2b, $00, $00

Data_01_78a0:
	db $2c, $00, $00, $2d, $00, $00, $2e, $00, $00, $2f, $00, $00, $30, $10, $10, $31
	db $11, $11, $32, $12, $12, $33, $13, $13, $34, $14, $14, $35, $15, $15, $36, $16
	db $16, $37, $17, $17, $38, $18, $18, $39, $19, $19, $3a, $1a, $1a, $3b, $1b, $1b
	db $3c, $1c, $1c, $3d, $00, $00, $3e, $00, $00, $3f, $00, $00, $40, $20, $20, $41
	db $21, $21, $42, $22, $22, $43, $23, $23, $44, $24, $24, $45, $25, $25

SECTION "analyzed_00790c", ROMX[$790c], BANK[$01]

Data_01_790c:
	db $50, $30, $30, $51, $31, $31, $52, $32, $32, $53, $33, $33, $54, $34, $34, $55
	db $35, $35

Data_01_791e:
	db $50, $30, $30, $50, $30, $30, $50, $30, $30, $50, $30, $30, $50, $30, $30, $50
	db $30, $30, $50, $30, $30, $50, $30, $30, $50, $30, $30, $50, $30, $30

Data_01_793c:
	db $60, $00, $00, $61, $00, $00, $62, $00, $00, $63, $00, $00

Func_01_7948:
	ld h, b
	nop
	nop
	ld h, b
	nop
	nop
	ld h, b
	nop
	nop
	ld h, b
	nop
	nop
	ld h, b
	nop
	nop
	ld h, b
	nop
	nop
	ld h, b
	nop
	nop
	ld h, b
	nop
	nop
	ld h, b
	nop
	nop
	ld h, b
	nop
	nop
	ld h, b
	nop
	nop
	ld h, b
	nop
	nop
	nop
	nop

Data_01_796e:
	db $d6, $72, $46, $70, $4d, $70, $54, $70, $5b, $70, $62, $70, $69, $70, $70, $70
	db $ae, $70, $77, $70, $86, $70, $ad, $71, $b8, $71, $bf, $71, $c9, $71, $09, $71
	db $c9, $70, $09, $71, $c9, $70, $09, $71

Data_01_7996:
	db $c9, $70

Data_01_7998:
	db $19, $71, $d9, $70, $19, $71, $d9, $70, $19, $71, $d9, $70

Data_01_79a4:
	db $b5, $70, $bf, $70

Data_01_79a8:
	db $e6, $74, $b5, $74, $49, $71, $50, $71

Data_01_79b0:
	db $57, $71

Data_01_79b2:
	db $5e, $71, $65, $71, $6c, $71

Data_01_79b8:
	db $73, $71

Data_01_79ba:
	db $7e, $71, $4b, $72, $9b, $71, $89, $71

Data_01_79c2:
	db $92, $71

MonsterSpawnScriptTable:
	db $64, $72, $7d, $72, $87, $72, $91, $72, $f1, $74, $6c, $75, $15, $76, $a8, $76
	db $13, $77, $77, $77, $b7, $77, $f7, $77, $5c, $78, $d7, $78, $7f, $79, $df, $79
	db $1f, $7a, $b4, $72, $d5, $71, $92, $70, $59, $7a, $c5, $7a, $48, $7b, $d6, $7b
	db $21, $7c, $af, $7c

SECTION "analyzed_007a0c", ROMX[$7a0c], BANK[$01]

Data_01_7a0c:
	db $36, $7d, $b3, $7d, $28, $7e, $73, $7e, $9e, $7e, $0f, $7f

SECTION "analyzed_007a2c", ROMX[$7a2c], BANK[$01]

Data_01_7a2c:
	db $eb, $71, $1b, $72, $9b, $72, $ad, $72

SECTION "analyzed_007a4c", ROMX[$7a4c], BANK[$01]

Data_01_7a4c:
	db $f4, $44, $ea, $4b, $cf, $4d, $2d, $4e

Data_01_7a54:
	db $f4, $44, $f4, $44, $f4, $44, $f4, $44, $f4, $44, $f4, $44, $f4, $44, $f4, $44
	db $f4, $44, $f4, $44, $f4, $44, $f4, $44

Data_01_7a6c:
	db $4b, $4e, $df, $4e, $86, $4f, $25, $50, $cb, $50, $65, $51, $ea, $51, $89, $52
	db $23, $53, $fd, $53, $9f, $55, $41, $56, $41, $56

SECTION "analyzed_007a8c", ROMX[$7a8c], BANK[$01]

Data_01_7a8c:
	db $e0, $56, $75, $57, $26, $58, $d2, $58, $5d, $59, $06, $5a

SECTION "analyzed_007aac", ROMX[$7aac], BANK[$01]

Data_01_7aac:
	db $9b, $5a, $d9, $5b, $d5, $5c, $87, $5d, $87, $5d, $39, $5e, $24, $48, $bb, $4c
	db $ef, $4d, $35, $4e

Data_01_7ac0:
	db "$H$H$H$H$H$H$H$H$H$H$H$H"

Data_01_7ad8:
	db $83, $4e, $1f, $4f, $c6, $4f, $65, $50, $0b, $51, $95, $51, $2a, $52, $c1, $52
	db $73, $53, $9d, $54, $df, $55, $79, $56, $79, $56

SECTION "analyzed_007af8", ROMX[$7af8], BANK[$01]

Data_01_7af8:
	db $20, $57, $b5, $57, $66, $58, $12, $59, $95, $59, $46, $5a

SECTION "analyzed_007b18", ROMX[$7b18], BANK[$01]

Data_01_7b18:
	db $2b, $5b, $21, $5c, $1d, $5d, $c7, $5d, $c7, $5d, $89, $5e

Func_01_7b24:
	push hl
	ld h, b
	ld l, c
	add hl, bc
	add hl, bc
	ld de, $781c
	add hl, de
	ld d, h
	ld e, l
	ld a, [de]
	inc de
	add a, a
	ld c, a
	ld b, $00
	ld hl, $796c
	add hl, bc
	ld a, [hl+]
	ld [$cf65], a
	ld a, [hl]
	ld [$cf66], a
	ld a, [de]
	inc de
	add a, a
	ld c, a
	ld hl, $7a4c
	add hl, bc
	ld a, [hl+]
	ld [$cf67], a
	ld a, [hl]
	ld [$cf68], a
	ld a, [de]
	inc de
	add a, a
	ld c, a
	ld hl, $7ab8
	add hl, bc
	ld a, [hl+]
	ld [$cf69], a
	ld a, [hl]
	ld [$cf6a], a
	FAR_CALL Func_04_4100
	pop hl
	ret

SECTION "analyzed_007b6d", ROMX[$7b6d], BANK[$01]

Data_01_7b6d:
	db $a1, $fe, $a3, $fe, $a7, $fe, $ad, $fe, $b6, $fe, $c1, $fe, $cd, $fe, $dc, $fe
	db $ec, $fe, $fe, $fe, $11, $ff, $26, $ff, $3d, $ff, $54, $ff, $6d, $ff, $86, $ff
	db $a1, $ff, $bb, $ff, $d7, $ff, $f2, $ff, $0e, $00, $29, $00, $45, $00, $5f, $00
	db $7a, $00, $93, $00, $ac, $00, $c3, $00, $da, $00, $ef, $00, $02, $01, $14, $01
	db $24, $01, $33, $01, $3f, $01, $4a, $01, $53, $01, $59, $01, $5d, $01, $5f, $01

SECTION "analyzed_007bbf", ROMX[$7bbf], BANK[$01]

Data_01_7bbf:
	db $2a, $ff, $2a, $ff, $2b, $ff, $2d, $ff, $2f, $ff, $32, $ff, $36, $ff, $3a, $ff
	db $3e, $ff, $44, $ff, $49, $ff, $4f, $ff, $56, $ff, $5d, $ff, $64, $ff, $6c, $ff
	db $75, $ff, $7d, $ff, $87, $ff, $90, $ff, $9a, $ff, $a4, $ff, $ae, $ff, $b8, $ff
	db $c3, $ff, $ce, $ff, $d9, $ff, $e4, $ff, $ef, $ff, $fa, $ff, $06, $00, $11, $00
	db $1c, $00, $27, $00, $32, $00, $3d, $00, $48, $00, $52, $00, $5c, $00, $66, $00
	db $70, $00, $79, $00, $83, $00, $8b, $00, $94, $00, $9c, $00, $a3, $00, $aa, $00
	db $b1, $00, $b7, $00, $bc, $00, $c2, $00, $c6, $00, $ca, $00, $ce, $00, $d1, $00
	db $d3, $00, $d5, $00, $d6, $00, $d6, $00, $ac, $01

SECTION "analyzed_007c3b", ROMX[$7c3b], BANK[$01]

Data_01_7c3b:
	db $d2, $fb, $d2, $fb, $d7, $fb, $e1, $fb, $eb, $fb, $fa, $fb, $0e, $fc, $22, $fc
	db $36, $fc, $54, $fc, $6d, $fc, $8b, $fc, $ae, $fc, $d1, $fc, $f4, $fc, $1c, $fd
	db $49, $fd, $71, $fd, $a3, $fd, $d0, $fd, $02, $fe, $34, $fe, $66, $fe, $98, $fe
	db $cf, $fe, $06, $ff, $3d, $ff, $74, $ff, $ab, $ff, $e2, $ff, $1e, $00, $55, $00
	db $8c, $00, $c3, $00, $fa, $00, $31, $01, $68, $01, $9a, $01, $cc, $01, $fe, $01
	db $30, $02, $5d, $02, $8f, $02, $b7, $02, $e4, $02, $0c, $03, $2f, $03, $52, $03
	db $75, $03, $93, $03, $ac, $03, $ca, $03, $de, $03, $f2, $03, $06, $04, $15, $04
	db $1f, $04, $29, $04, $2e, $04, $2e, $04

Data_01_7cb3:
	db $2e, $04
