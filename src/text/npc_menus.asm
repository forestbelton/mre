; NPC dialogue menus (bank $1f).
;
; The script-driven choice / shop menus that the NPC scripts invoke via
; SCRIPT_FAR_CALL ..., .Bank=$1f. Each Show*Menu routine draws a small BG/text
; window (CopyBgMap + DispatchTextRenderer), runs a menu loop (WaitForNextFrame +
; ReadJoypad + cursor navigation via MoveMenuCursor), and returns the chosen
; option in a result var (e.g. wMainMenuResult / wYNResult). Entry points are
; named per NPC -- Toamuna / Naji / Bodka / Pashute / Verde / Tradehouse -- plus
; the shared ShowYesNoMenu and ShowMonsterDiscStoneSelect.

INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "sound_ids.inc"

SECTION "NPC dialogue menus", ROMX[$5855], BANK[$1f]

MoveMenuCursor:
	ld a, [hJoyPressed]
	bit 4, a
	jr z, Func_1f_5868
	ld a, [hl]
	cp b
	jr z, Func_1f_5868
	inc [hl]
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
Func_1f_5868:
	ld a, [hJoyPressed]
	bit 5, a
	jr z, Func_1f_587b
	ld a, [hl]
	cp c
	jr z, Func_1f_587b
	dec [hl]
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
Func_1f_587b:
	ret
Func_1f_587c:
	ld hl, $d601
	ld a, [$d602]
	dec a
	ld b, a
	ld c, $00
	ld a, [hJoyPressed]
	bit 7, a
	jr z, Func_1f_58ae
	ld a, [hl]
	cp b
	ret z
	inc [hl]
	ld hl, $d60b
	ld a, [hl]
	cp $02
	jr z, Func_1f_58a2
	inc [hl]
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ret
Func_1f_58a2:
	ld hl, $d60c
	inc [hl]
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ret
Func_1f_58ae:
	ld a, [hJoyPressed]
	bit 6, a
	jr z, Func_1f_58d6
	ld a, [hl]
	cp c
	ret z
	dec [hl]
	ld hl, $d60b
	ld a, [hl]
	cp $00
	jr z, Func_1f_58ca
	dec [hl]
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ret
Func_1f_58ca:
	ld hl, $d60c
	dec [hl]
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ret
Func_1f_58d6:
	ret
ShowYesNoMenu:
	ld de, $996d
	ld bc, $0707
	call ScriptOpcode05Helper
	ld hl, $5942
	ld de, $9990
	call CopyBgMap
	xor a
	ld [wYNResult], a
Func_1f_58ed:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_590b
	call HideUnusedOamSprites
	call DrawTextWindow
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_590b:
	ld a, [hJoyPressed]
	and $c0
	jr z, Func_1f_5921
	ld hl, wYNResult
	ld a, [hl]
	inc a
	and $01
	ld [hl], a
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
Func_1f_5921:
	call Func_1f_592a
	call HideUnusedOamSprites
	jp Func_1f_58ed
Func_1f_592a:
	ld bc, $7478
	ld a, [wYNResult]
	sla a
	sla a
	sla a
	sla a
	add a, b
	ld b, a
	call Func_1f_65be
	ld hl, $d612
	inc [hl]
	ret

Data_1f_5942:
	db $04, $03, $54, $59, $48, $59, $97, $97, $97, $20, $9c, $aa, $97, $97, $97, $15
	db $a6, $97, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07

Toamuna_ShowMenu2:
	ld de, $98ca
	ld bc, $0904
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_596d:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5985
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5985:
	ld hl, wMainMenuResult
	ld bc, $0200
	call MoveMenuCursor
	ld hl, $59cd
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98eb
	call CopyBgMap
	call Func_1f_59ae
	call HideUnusedOamSprites
	jp Func_1f_596d
Func_1f_59ae:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_59bb
	ld bc, $4858
	call Func_1f_65ec
Func_1f_59bb:
	ld a, [wMainMenuResult]
	cp $02
	jr z, Func_1f_59c8
	ld bc, $4898
	call Func_1f_65be
Func_1f_59c8:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_59cd:
	db $56, $5a, $78, $5a, $9a, $5a

Toamuna_ShowMenu1:
	ld de, $98ca
	ld bc, $0904
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_59e0:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5a08
	ld hl, $5a54
	ld a, [wMainMenuResult]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	ld [wMainMenuResult], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5a08:
	ld hl, wMainMenuResult
	ld bc, $0100
	call MoveMenuCursor
	ld hl, $5a50
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98eb
	call CopyBgMap
	call Func_1f_5a31
	call HideUnusedOamSprites
	jp Func_1f_59e0
Func_1f_5a31:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_5a3e
	ld bc, $4858
	call Func_1f_65ec
Func_1f_5a3e:
	ld a, [wMainMenuResult]
	cp $01
	jr z, Func_1f_5a4b
	ld bc, $4898
	call Func_1f_65be
Func_1f_5a4b:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_5a50:
	db $56, $5a, $9a, $5a, $00, $02, $02, $07, $6a, $5a, $5c, $5a, $b8, $c0, $c8, $97
	db $97, $97, $97, $b9, $c1, $c9, $97, $97, $97, $97, $07, $07, $07, $06, $06, $06
	db $06, $06, $06, $06, $06, $06, $06, $06, $02, $07, $8c, $5a, $7e, $5a, $d0, $d8
	db $e0, $e8, $f0, $97, $97, $d1, $d9, $e1, $e9, $f1, $97, $97, $07, $07, $07, $07
	db $07, $06, $06, $06, $06, $06, $06, $06, $06, $06, $02, $07, $ae, $5a, $a0, $5a
	db $84, $8e, $97, $97, $97, $97, $97, $85, $8f, $97, $97, $97, $97, $97, $07, $07
	db $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06

Naji_ShowMenu2:
	ld de, $98cc
	ld bc, $0804
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_5ac9:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5af1
	ld hl, $5b3f
	ld a, [wMainMenuResult]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	ld [wMainMenuResult], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5af1:
	ld hl, wMainMenuResult
	ld bc, $0200
	call MoveMenuCursor
	ld hl, $5b39
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ed
	call CopyBgMap
	call Func_1f_5b1a
	call HideUnusedOamSprites
	jp Func_1f_5ac9
Func_1f_5b1a:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_5b27
	ld bc, $4a68
	call Func_1f_65ec
Func_1f_5b27:
	ld a, [wMainMenuResult]
	cp $02
	jr z, Func_1f_5b34
	ld bc, $4aa0
	call Func_1f_65be
Func_1f_5b34:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_5b39:
	db $fe, $5c, $3a, $5d, $58, $5d, $01, $03, $04

Naji_ShowMenu3a:
	ld de, $98cc
	ld bc, $0804
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_5b4f:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5b77
	ld hl, $5bc7
	ld a, [wMainMenuResult]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	ld [wMainMenuResult], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5b77:
	ld hl, wMainMenuResult
	ld bc, $0300
	call MoveMenuCursor
	ld hl, $5bbf
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ed
	call CopyBgMap
	call Func_1f_5ba0
	call HideUnusedOamSprites
	jp Func_1f_5b4f
Func_1f_5ba0:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_5bad
	ld bc, $4a68
	call Func_1f_65ec
Func_1f_5bad:
	ld a, [wMainMenuResult]
	cp $03
	jr z, Func_1f_5bba
	ld bc, $4aa0
	call Func_1f_65be
Func_1f_5bba:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_5bbf:
	db $e0, $5c, $fe, $5c, $3a, $5d, $58, $5d, $00, $01, $03, $04

Naji_ShowMenu3b:
	ld de, $98cc
	ld bc, $0804
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_5bd8:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5c00
	ld hl, $5c50
	ld a, [wMainMenuResult]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	ld [wMainMenuResult], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5c00:
	ld hl, wMainMenuResult
	ld bc, $0300
	call MoveMenuCursor
	ld hl, $5c48
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ed
	call CopyBgMap
	call Func_1f_5c29
	call HideUnusedOamSprites
	jp Func_1f_5bd8
Func_1f_5c29:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_5c36
	ld bc, $4a68
	call Func_1f_65ec
Func_1f_5c36:
	ld a, [wMainMenuResult]
	cp $03
	jr z, Func_1f_5c43
	ld bc, $4aa0
	call Func_1f_65be
Func_1f_5c43:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_5c48:
	db $fe, $5c, $1c, $5d, $3a, $5d, $58, $5d, $01

Data_1f_5c51:
	db $02, $03, $04

Naji_ShowMenu4:
	ld de, $98cc
	ld bc, $0804
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_5c61:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5c89
	ld hl, $5cdb
	ld a, [wMainMenuResult]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	ld [wMainMenuResult], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5c89:
	ld hl, wMainMenuResult
	ld bc, $0400
	call MoveMenuCursor
	ld hl, $5cd1
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ed
	call CopyBgMap
	call Func_1f_5cb2
	call HideUnusedOamSprites
	jp Func_1f_5c61
Func_1f_5cb2:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_5cbf
	ld bc, $4a68
	call Func_1f_65ec
Func_1f_5cbf:
	ld a, [wMainMenuResult]
	cp $04
	jr z, Func_1f_5ccc
	ld bc, $4aa0
	call Func_1f_65be
Func_1f_5ccc:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_5cd1:
	db $e0, $5c, $fe, $5c, $1c, $5d, $3a, $5d, $58, $5d, $00, $01, $02, $03, $04, $02
	db $06, $f2, $5c, $e6, $5c, $d8, $e0, $e8, $f0, $97, $97, $d9, $e1, $e9, $f1, $97
	db $97, $07, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06, $02, $06, $10
	db $5d, $04, $5d, $b8, $c0, $c8, $d0, $97, $97, $b9, $c1, $c9, $d1, $97, $97, $07
	db $07, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06, $02, $06, $2e, $5d, $22
	db $5d, $ea, $f2, $fa, $bc, $c4, $cc, $eb, $f3, $fb, $bd, $c5, $cd, $07, $07, $07
	db $07, $07, $07, $06, $06, $06, $06, $06, $06, $02, $06, $4c, $5d, $40, $5d, $90
	db $92, $97, $97, $97, $97, $91, $93, $97, $97, $97, $97, $07, $07, $06, $06, $06
	db $06, $06, $06, $06, $06, $06, $06, $02, $06, $6a, $5d, $5e, $5d, $f8, $ba, $c2
	db $ca, $97, $97, $f9, $bb, $c3, $cb, $97, $97, $07, $07, $07, $07, $06, $06, $06
	db $06, $06, $06, $06, $06

Naji_ShowSubMenu2:
	ld de, $98cc
	ld bc, $0804
	call ScriptOpcode05Helper
	xor a
	ld [wSubMenuCursor], a
Func_1f_5d83:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5d9b
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5d9b:
	ld hl, wSubMenuCursor
	ld bc, $0200
	call MoveMenuCursor
	ld hl, $5de3
	ld a, [wSubMenuCursor]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ed
	call CopyBgMap
	call Func_1f_5dc4
	call HideUnusedOamSprites
	jp Func_1f_5d83
Func_1f_5dc4:
	ld a, [wSubMenuCursor]
	cp $00
	jr z, Func_1f_5dd1
	ld bc, $4a68
	call Func_1f_65ec
Func_1f_5dd1:
	ld a, [wSubMenuCursor]
	cp $02
	jr z, Func_1f_5dde
	ld bc, $4aa0
	call Func_1f_65be
Func_1f_5dde:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_5de3:
	db $e9, $5d, $07, $5e, $25, $5e, $02, $06, $fb, $5d, $ef, $5d, $fe, $00, $02, $04
	db $97, $97, $ff, $01, $03, $05, $97, $97, $07, $07, $07, $07, $06, $06, $06, $06
	db $06, $06, $06, $06, $02, $06, $19, $5e, $0d, $5e, $d2, $da, $e2, $97, $97, $97
	db $d3, $db, $e3, $97, $97, $97, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $02, $06, $37, $5e, $2b, $5e, $94, $b3, $b5, $97, $97, $97, $95, $b4
	db $b6, $97, $97, $97, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06, $06

Bodka_ShowMenu:
	ld de, $98cc
	ld bc, $0804
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_5e50:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5e68
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5e68:
	ld hl, wMainMenuResult
	ld bc, $0400
	call MoveMenuCursor
	ld hl, $5eb0
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ed
	call CopyBgMap
	call Func_1f_5e91
	call HideUnusedOamSprites
	jp Func_1f_5e50
Func_1f_5e91:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_5e9e
	ld bc, $4868
	call Func_1f_65ec
Func_1f_5e9e:
	ld a, [wMainMenuResult]
	cp $04
	jr z, Func_1f_5eab
	ld bc, $48a0
	call Func_1f_65be
Func_1f_5eab:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_5eb0:
	db $ba, $5e, $d8, $5e, $f6, $5e, $14, $5f, $32, $5f, $02, $06, $cc, $5e, $c0, $5e
	db $d4, $dc, $e4, $ec, $97, $97, $d5, $dd, $e5, $ed, $97, $97, $07, $07, $07, $07
	db $06, $06, $06, $06, $06, $06, $06, $06, $02, $06, $ea, $5e, $de, $5e, $f4, $fc
	db $be, $c6, $97, $97, $f5, $fd, $bf, $c7, $97, $97, $07, $07, $07, $07, $06, $06
	db $06, $06, $06, $06, $06, $06, $02, $06, $08, $5f, $fc, $5e, $90, $92, $97, $97
	db $97, $97, $91, $93, $97, $97, $97, $97, $07, $07, $06, $06, $06, $06, $06, $06
	db $06, $06, $06, $06, $02, $06, $26, $5f, $1a, $5f, $ce, $d6, $de, $97, $97, $97
	db $cf, $d7, $df, $97, $97, $97, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $02, $06, $44, $5f, $38, $5f, $84, $8e, $97, $97, $97, $97, $85, $8f
	db $97, $97, $97, $97, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06

Tradehouse_ShowMenu:
	ld de, $98cc
	ld bc, $0804
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_5f5d:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5f75
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5f75:
	ld hl, wMainMenuResult
	ld bc, $0200
	call MoveMenuCursor
	ld hl, $5fbd
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ed
	call CopyBgMap
	call Func_1f_5f9e
	call HideUnusedOamSprites
	jp Func_1f_5f5d
Func_1f_5f9e:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_5fab
	ld bc, $4868
	call Func_1f_65ec
Func_1f_5fab:
	ld a, [wMainMenuResult]
	cp $02
	jr z, Func_1f_5fb8
	ld bc, $48a0
	call Func_1f_65be
Func_1f_5fb8:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_5fbd:
	db $d8, $5e, $14, $5f, $32, $5f

Bodka_ShowItemsSubMenu:
	ld de, $98cc
	ld bc, $0804
	call ScriptOpcode05Helper
	xor a
	ld [wSubMenuCursor], a
Func_1f_5fd0:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5fe8
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5fe8:
	ld hl, wSubMenuCursor
	ld bc, $0200
	call MoveMenuCursor
	ld hl, $6030
	ld a, [wSubMenuCursor]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ed
	call CopyBgMap
	call Func_1f_6011
	call HideUnusedOamSprites
	jp Func_1f_5fd0
Func_1f_6011:
	ld a, [wSubMenuCursor]
	cp $00
	jr z, Func_1f_601e
	ld bc, $4868
	call Func_1f_65ec
Func_1f_601e:
	ld a, [wSubMenuCursor]
	cp $02
	jr z, Func_1f_602b
	ld bc, $48a0
	call Func_1f_65be
Func_1f_602b:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_6030:
	db $36, $60, $54, $60, $72, $60, $02, $06, $48, $60, $3c, $60, $e6, $ee, $f6, $97
	db $97, $97, $e7, $ef, $f7, $97, $97, $97, $07, $07, $07, $06, $06, $06, $06, $06
	db $06, $06, $06, $06, $02, $06, $66, $60, $5a, $60, $ce, $d6, $de, $97, $97, $97
	db $cf, $d7, $df, $97, $97, $97, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $02, $06, $84, $60, $78, $60, $94, $b3, $b5, $97, $97, $97, $95, $b4
	db $b6, $97, $97, $97, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06, $06

Pashute_ShowMenu:
	ld de, $98cb
	ld bc, $0904
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_609d:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_60b5
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_60b5:
	ld hl, wMainMenuResult
	ld bc, $0200
	call MoveMenuCursor
	ld hl, $60fd
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ec
	call CopyBgMap
	call Func_1f_60de
	call HideUnusedOamSprites
	jp Func_1f_609d
Func_1f_60de:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_60eb
	ld bc, $4860
	call Func_1f_65ec
Func_1f_60eb:
	ld a, [wMainMenuResult]
	cp $02
	jr z, Func_1f_60f8
	ld bc, $48a0
	call Func_1f_65be
Func_1f_60f8:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_60fd:
	db $03, $61, $25, $61, $47, $61, $02, $07, $17, $61, $09, $61, $c6, $ce, $d6, $97
	db $97, $97, $97, $c7, $cf, $d7, $97, $97, $97, $97, $07, $07, $07, $06, $06, $06
	db $06, $06, $06, $06, $06, $06, $06, $06, $02, $07, $39, $61, $2b, $61, $90, $92
	db $97, $97, $97, $97, $97, $91, $93, $97, $97, $97, $97, $97, $07, $07, $06, $06
	db $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $02, $07, $5b, $61, $4d, $61
	db $84, $8e, $97, $97, $97, $97, $97, $85, $8f, $97, $97, $97, $97, $97, $07, $07
	db $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06

Pashute_ShowExplainSubMenu:
	ld de, $98cb
	ld bc, $0904
	call ScriptOpcode05Helper
	xor a
	ld [wSubMenuCursor], a
Func_1f_6176:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_618e
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_618e:
	ld hl, wSubMenuCursor
	ld bc, $0200
	call MoveMenuCursor
	ld hl, $61d6
	ld a, [wSubMenuCursor]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ec
	call CopyBgMap
	call Func_1f_61b7
	call HideUnusedOamSprites
	jp Func_1f_6176
Func_1f_61b7:
	ld a, [wSubMenuCursor]
	cp $00
	jr z, Func_1f_61c4
	ld bc, $4860
	call Func_1f_65ec
Func_1f_61c4:
	ld a, [wSubMenuCursor]
	cp $02
	jr z, Func_1f_61d1
	ld bc, $48a0
	call Func_1f_65be
Func_1f_61d1:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_61d6:
	db $dc, $61, $fe, $61, $20, $62, $02, $07, $f0, $61, $e2, $61, $de, $e6, $ee, $f6
	db $fe, $df, $97, $97, $97, $97, $97, $e7, $ef, $f7, $07, $07, $07, $07, $07, $07
	db $07, $06, $06, $06, $06, $06, $06, $06, $02, $07, $12, $62, $04, $62, $f8, $ba
	db $c2, $ca, $d2, $97, $97, $f9, $bb, $c3, $cb, $d3, $97, $97, $07, $07, $07, $07
	db $07, $06, $06, $06, $06, $06, $06, $06, $06, $06, $02, $07, $34, $62, $26, $62
	db $94, $b3, $b5, $97, $97, $97, $97, $95, $b4, $b6, $97, $97, $97, $97, $07, $07
	db $07, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06

ShowMonsterDiscStoneSelect:
	call Func_1f_63a6
Func_1f_6245:
	ld de, $982b
	ld bc, $0909
	ld a, [$d602]
	cp $03
	jr c, Func_1f_6254
	ld a, $03
Func_1f_6254:
	sla a
	add a, $03
	ld c, a
	call ScriptOpcode05Helper
	xor a
	ld [$d601], a
	ld [$d60c], a
	ld [$d60b], a
Func_1f_6266:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_628e
	ld hl, $d603
	ld a, [$d601]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	ld [wActiveMonster], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_628e:
	call Func_1f_587c
	call Func_1f_62d8
	ld c, $68
	ld a, [$d60b]
	sla a
	sla a
	sla a
	sla a
	add a, $24
	ld b, a
	call Func_1f_65be
	call Func_1f_62b4
	call HideUnusedOamSprites
	ld hl, $d612
	inc [hl]
	jp Func_1f_6266
Func_1f_62b4:
	ld a, [$d60c]
	cp $00
	jr z, Func_1f_62c1
	ld bc, $1480
	call Func_1f_65f5
Func_1f_62c1:
	ld a, [$d602]
	sub $03
	jr nc, Func_1f_62ca
	ld a, $00
Func_1f_62ca:
	ld c, a
	ld a, [$d60c]
	cp c
	jr nc, Func_1f_62d7
	ld bc, $4b80
	call Func_1f_65fe
Func_1f_62d7:
	ret
Func_1f_62d8:
	ld hl, $d603
	ld a, [$d60c]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld de, $986d
	ld a, [$d602]
	cp $03
	jr c, Func_1f_62f0
	ld a, $03
Func_1f_62f0:
	ld c, a
Func_1f_62f1:
	push bc
	push de
	push hl
	ld a, [hl]
	ld hl, $6316
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call CopyBgMap
	pop hl
	pop de
	pop bc
	ld a, e
	add a, $40
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	inc hl
	dec c
	jr nz, Func_1f_62f1
	ret

Data_1f_6316:
	db $26, $63, $36, $63, $46, $63, $56, $63, $66, $63, $76, $63, $86, $63, $96, $63
	db $01, $05, $31, $63, $2c, $63, $30, $38, $40, $97, $97, $07, $07, $07, $07, $07
	db $01, $05, $41, $63, $3c, $63, $3c, $44, $3d, $45, $97, $07, $07, $07, $07, $07
	db $01, $05, $51, $63, $4c, $63, $32, $3a, $42, $97, $97, $07, $07, $07, $07, $07
	db $01, $05, $61, $63, $5c, $63, $33, $3b, $43, $97, $97, $07, $07, $07, $07, $07
	db $01, $05, $71, $63, $6c, $63, $2e, $36, $3e, $46, $97, $07, $07, $07, $07, $07
	db $01, $05, $81, $63, $7c, $63, $31, $39, $41, $97, $97, $07, $07, $07, $07, $07
	db $01, $05, $91, $63, $8c, $63, $37, $3f, $47, $48, $49, $07, $07, $07, $07, $07
	db $01, $05, $a1, $63, $9c, $63, $4a, $4b, $4c, $4d, $97, $06, $06, $06, $06, $06

Func_1f_63a6:
	ld de, $d603
	ld c, $00
	ld b, $00
Func_1f_63ad:
	ld hl, wMonsterDiscStones
	ld a, l
	add a, c
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	or a
	jr z, Func_1f_63bf
	ld a, c
	ld [de], a
	inc de
	inc b
Func_1f_63bf:
	inc c
	ld a, c
	cp $07
	jr nz, Func_1f_63ad
	ld a, $07
	ld [de], a
	inc b
	ld hl, $d602
	ld [hl], b
	ret
Verde_ShowMainMenu:
	ld de, $98cb
	ld bc, $0904
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_63db:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_6403
	ld hl, $6453
	ld a, [wMainMenuResult]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	ld [wMainMenuResult], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_6403:
	ld hl, wMainMenuResult
	ld bc, $0300
	call MoveMenuCursor
	ld hl, $644b
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ec
	call CopyBgMap
	call Func_1f_642c
	call HideUnusedOamSprites
	jp Func_1f_63db
Func_1f_642c:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_6439
	ld bc, $4860
	call Func_1f_65ec
Func_1f_6439:
	ld a, [wMainMenuResult]
	cp $03
	jr z, Func_1f_6446
	ld bc, $48a0
	call Func_1f_65be
Func_1f_6446:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_644b:
	db $e0, $64, $02, $65, $46, $65, $68, $65, $00, $01, $03, $04

Func_1f_6457:
	ld de, $98cb
	ld bc, $0904
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_6464:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_648c
	ld hl, $64dc
	ld a, [wMainMenuResult]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	ld [wMainMenuResult], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_648c:
	ld hl, wMainMenuResult
	ld bc, $0300
	call MoveMenuCursor
	ld hl, $64d4
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ec
	call CopyBgMap
	call Func_1f_64b5
	call HideUnusedOamSprites
	jp Func_1f_6464
Func_1f_64b5:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_64c2
	ld bc, $4860
	call Func_1f_65ec
Func_1f_64c2:
	ld a, [wMainMenuResult]
	cp $03
	jr z, Func_1f_64cf
	ld bc, $48a0
	call Func_1f_65be
Func_1f_64cf:
	ld hl, $d612
	inc [hl]
	ret
	ldh [$ff64], a
	inc h
	ld h, l
	ld b, [hl]
	ld h, l
	ld l, b
	ld h, l
	nop
	ld [bc], a
	inc bc
	inc b

Data_1f_64e0:
	db $02, $07, $f4, $64, $e6, $64, $da, $e2, $ea, $f2, $97, $97, $97, $db, $e3, $eb
	db $f3, $97, $97, $97, $07, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $02, $07, $16, $65, $08, $65, $fa, $bc, $c4, $97, $97, $97, $97, $fb
	db $bd, $c5, $97, $97, $97, $97, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $06, $06

Data_1f_6524:
	db $02, $07, $38, $65, $2a, $65, $cc, $d4, $dc, $e4, $97, $97, $97, $cd, $d5, $dd
	db $e5, $97, $97, $97, $07, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06
	db $06, $06

Data_1f_6546:
	db $02, $07, $5a, $65, $4c, $65, $ec, $f4, $fc, $be, $97, $97, $97, $ed, $f5, $fd
	db $bf, $97, $97, $97, $07, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $02, $07, $7c, $65, $6e, $65, $84, $8e, $97, $97, $97, $97, $97, $85
	db $8f, $97, $97, $97, $97, $97, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $06, $06

Verde_ShowReleaseMonsterSelect:
	call Func_1f_6590
	jp Func_1f_6245
Func_1f_6590:
	ld de, $d603
	ld c, $00
	ld b, $00
Func_1f_6597:
	ld hl, wMonsterUses
	ld a, l
	add a, c
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	or a
	jr z, Func_1f_65af
	ld a, [wDisplayMonster]
	cp c
	jr z, Func_1f_65af
	ld a, c
	ld [de], a
	inc de
	inc b
Func_1f_65af:
	inc c
	ld a, c
	cp $07
	jr nz, Func_1f_6597
	ld a, $07
	ld [de], a
	inc b
	ld hl, $d602
	ld [hl], b
	ret
Func_1f_65be:
	ld hl, $65e8
Func_1f_65c1:
	ld a, $19
	ld [wDrawBank], a
	ld a, [$d612]
	srl a
	srl a
	srl a
	cp $02
	jr c, Func_1f_65d7
	xor a
	ld [$d612], a
Func_1f_65d7:
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	or h
	call nz, DrawMetasprite
	ret

Data_1f_65e8:
	db $8a, $68, $00, $00

Func_1f_65ec:
	ld hl, $65f1
	jr Func_1f_65c1

Data_1f_65f1:
	db $85, $68, $00, $00

Func_1f_65f5:
	ld hl, $65fa
	jr Func_1f_65c1

Data_1f_65fa:
	db $7b, $68, $00, $00

Func_1f_65fe:
	ld hl, $6603
	jr Func_1f_65c1

Data_1f_6603:
	db $80, $68, $00, $00
