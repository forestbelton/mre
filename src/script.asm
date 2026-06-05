INCLUDE "enum.inc"
INCLUDE "monster.inc"

SECTION "ScriptEngine", ROM0[$39c0]

ScriptDispatcherEnterAfterCall:
	push hl
	call WaitForNextFrame
	pop hl
ScriptDispatcherNext:
	ld c, [hl]
	inc hl
	ld a, c
	cp $ff
	ret z
	cp $20
	jr nc, ScriptTextOutputPath
	sla a
	ld de, SCRIPT_OPCODE_TABLE
	add a, e
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	ld a, [de]
	inc de
	ld c, a
	ld a, [de]
	inc de
	ld b, a
	push bc
	ret

ScriptTextOutputPath:
	call PrintCharacterAtCursor
	push hl
	call DispatchTextRenderer
	call HideUnusedOamSprites
	pop hl
	jp ScriptDispatcherEnterAfterCall

; Per-opcode handler table, indexed by ScriptDispatcherNext as $39f0 + 2*opcode.
SCRIPT_OPCODE_TABLE:
	dw $0000                                     ; $00  (unused)
	dw ScriptInitText       					 ; $01
	dw ScriptOpcode02Handler_RenderAnchor        ; $02
	dw ScriptOpcode03Handler_WaitAndRenderPrep   ; $03
	dw ScriptWaitForInput                        ; $04
	dw ScriptOpcode05Handler_InitTextStateV2     ; $05
	dw ScriptGoto                				 ; $06
	dw ScriptFarCall             				 ; $07
	dw ScriptJumpTable           			     ; $08
	dw ScriptWriteWRAM           				 ; $09
	dw ScriptJumpIfEqual         				 ; $0a
	dw ScriptJumpIfNotEqual                      ; $0b
	dw ScriptIncrementCycle                      ; $0c
	dw ScriptNewline                             ; $0d
	dw ScriptSetRenderer                         ; $0e
	dw ScriptPrintDecimal                        ; $0f
	dw ScriptRepeatChar          				 ; $10
	dw ScriptPrintMonsterName                    ; $11

ScriptInitText:
	ld a, [hl+]
	ld [wTextAnchor], a
	ld [wTextCursor], a
	ld a, [hl+]
	ld [wTextAnchor+1], a
	ld [wTextCursor+1], a
	ld a, [hl+]
	ld [wTextWidth], a
	ld a, [hl+]
	ld [wTextHeight], a
	jp ScriptDispatcherNext

ScriptWaitForInput:
	call ScriptWaitInputCore
	jp ScriptOpcode02Handler_RenderAnchor

ScriptOpcode03Handler_WaitAndRenderPrep:
	call ScriptWaitInputCore
	jp ScriptDispatcherNext

ScriptWaitInputCore:
	push hl
Func_00_3a3a:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [$d61a]
	or a
	jr nz, Data_00_3a4e
	ld bc, $8c92
	jr Func_00_3a51

Data_00_3a4e:
	ld bc, $8c9a

Func_00_3a51:
	call Func_00_3e10
	call HideUnusedOamSprites
	ldh a, [hJoyPressed]
	bit 0, a
	jr z, Func_00_3a3a
	push af
	ld a, $0d
	call PlaySound
	pop af
	ld hl, wTextAnchor
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	ld [wTextCursor], a
	ld a, h
	ld [$d617], a
	call WaitForNextFrame
	call DispatchTextRenderer
	call HideUnusedOamSprites
	pop hl
	ret

ScriptOpcode02Handler_RenderAnchor:
	push hl
	ld hl, wTextAnchor
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	ld [wTextCursor], a
	ld a, h
	ld [wTextCursor+1], a
	call DrawTextWindow
	pop hl
	jp ScriptDispatcherNext

ScriptOpcode05Handler_InitTextStateV2:
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld b, [hl]
	inc hl
	ld c, [hl]
	inc hl
	call ScriptOpcode05Helper
	jp ScriptDispatcherNext

ScriptGoto:
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp ScriptDispatcherNext

ScriptJumpTable:
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld a, [de]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp ScriptDispatcherNext

ScriptFarCall:
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	ld a, [hl+]
	push hl
	push bc
	pop hl
	call CallBankedHL
	pop hl
	jp ScriptDispatcherNext

ScriptWriteWRAM:
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld a, [hl+]
	ld [de], a
	jp ScriptDispatcherNext

ScriptJumpIfEqual:
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld a, [de]
	ld e, a
	ld d, [hl]
	inc hl
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	ld a, d
	cp e
	jr nz, .done
	push bc
	pop hl
.done:
	jp ScriptDispatcherNext

ScriptJumpIfNotEqual:
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	ld a, [de]
	ld e, a
	ld d, [hl]
	inc hl
	ld c, [hl]
	inc hl
	ld b, [hl]
	inc hl
	ld a, d
	cp e
	jr z, .done
	push bc
	pop hl
.done:
	jp ScriptDispatcherNext

ScriptIncrementCycle:
	ld c, [hl]
	inc hl
	ld a, [wCycleCounter]
	inc a
	cp c
	jr c, .done
	xor a
.done:
	ld [wCycleCounter], a
	jp ScriptDispatcherNext

ScriptSetRenderer:
	ld a, [hl+]
	ld [wRendererAddr], a
	ld a, [hl+]
	ld [wRendererAddr+1], a
	ld a, [hl+]
	ld [wRendererBank], a
	jp ScriptDispatcherNext

ScriptPrintDecimal:
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	push hl
	ld a, [de]
	ld c, a
	call NumberToDecimal3
	ld a, [wBcdHigh]
	or a
	jr z, Func_00_3b31
	add a, $30
	ld c, a
	call PrintCharacterAtCursor
Func_00_3b31:
	ld a, [wBcdLow]
	add a, $30
	ld c, a
	call PrintCharacterAtCursor
	pop hl
	jp ScriptDispatcherNext

ScriptRepeatChar:
	ld c, [hl]
	inc hl
	push hl
Func_00_3b41:
	push bc
	call WaitForNextFrame
	call DispatchTextRenderer
	call HideUnusedOamSprites
	pop bc
	dec c
	jr nz, Func_00_3b41
	pop hl
	jp ScriptDispatcherNext

ScriptPrintMonsterName:
	ld e, [hl]
	inc hl
	ld d, [hl]
	inc hl
	push hl
	ld a, [de]
	ld hl, MONSTER_NAME_POINTERS
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
.PutChar:
	ld a, [hl+]
	or a
	jr z, .PutCharDone
	ld c, a
	call PrintCharacterAtCursor
	jr .PutChar
.PutCharDone:
	pop hl
	jp ScriptDispatcherNext

MONSTER_NAME_POINTERS: enum_table SUMMON, word, \
	.TIGER=MONSTER_NAME_TIGER, \
	.MOCCHI=MONSTER_NAME_MOCCHI, \
	.HARE=MONSTER_NAME_HARE, \
	.GALI=MONSTER_NAME_GALI, \
	.GOLEM=MONSTER_NAME_GOLEM, \
	.SUEZO=MONSTER_NAME_SUEZO, \
	.PHOENIX=MONSTER_NAME_PHOENIX,

MONSTER_NAME_TIGER:   db "Tiger", 0
MONSTER_NAME_MOCCHI:  db "Mocchi", 0
MONSTER_NAME_HARE:    db "Hare", 0
MONSTER_NAME_GALI:    db "Gali", 0
MONSTER_NAME_GOLEM:   db "Golem", 0
MONSTER_NAME_SUEZO:   db "Suezo", 0
MONSTER_NAME_PHOENIX: db "Phenix", 0

ScriptNewline:
	ld a, [wTextCursor+1]
	ld d, a
	ld a, [wTextCursor]
	ld e, a
	ld a, e
	and $e0
	ld e, a
	ld a, [wTextAnchor]
	and $1f
	add a, e
	ld e, a
	ld a, e
	add a, $40
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	ld a, e
	ld [wTextCursor], a
	ld a, d
	ld [wTextCursor+1], a
	jp ScriptDispatcherNext

ScriptOpcode05Helper:
	push hl
	ld a, b
	ld [wTextStateV2+1], a
	ld a, c
	ld [wTextStateV2], a
	ld hl, $d627
	ld a, l
	ld [$d623], a
	ld a, h
	ld [$d624], a
	ld hl, $d67b
	ld a, l
	ld [$d625], a
	ld a, h
	ld [$d626], a
	push de
	ld hl, $d627
	ld c, $86
	ld de, $0686
	call WriteWindowRow
	ld a, [wTextStateV2]
	sub $02
Func_00_3c03:
	push af
	ld c, $06
	ld de, $0606
	call WriteWindowRow
	pop af
	dec a
	jr nz, Func_00_3c03
	ld c, $86
	ld de, $0686
	call WriteWindowRow
	ld hl, $d67b
	ld c, $78
	ld de, $7e7b
	call WriteWindowRow
	ld a, [wTextStateV2]
	sub $02
Func_00_3c28:
	push af
	ld c, $79
	ld de, $977c
	call WriteWindowRow
	pop af
	dec a
	jr nz, Func_00_3c28
	ld c, $7a
	ld de, $7f7d
	call WriteWindowRow
	pop de
	ld hl, wTextStateV2
	call CopyBgMap
	pop hl
	ret

WriteWindowRow:
	ld [hl], c
	inc hl
	ld a, [wTextStateV2+1]
	sub $02
Func_00_3c4d:
	ld [hl], d
	inc hl
	dec a
	jr nz, Func_00_3c4d
	ld [hl], e
	inc hl
	ret

DrawTextWindow:
	ld a, [$d61a]
	or a
	jr nz, Data_00_3c69
	push hl
	ld hl, $674b
	ld a, $19
	ld de, $9960
	call CopyBgMapBankedA
	pop hl
	ret

Data_00_3c69:
	push hl
	ld hl, $6161
	ld a, $13
	ld de, $9c00
	call CopyBgMapBankedA
	pop hl
	ret

PrintCharacterAtCursor:
	push bc
	push de
	push hl
	ld a, c
	cp $40
	jr z, Data_00_3c98
	ld a, [$d617]
	ld d, a
	ld a, [wTextCursor]
	ld e, a
	call PrintCharacterAtCursor_Helper1
	ld a, c
	call PrintCharacterAtCursor_Helper2
	jr c, Func_00_3c94
	ld hl, wTextCursor
	inc [hl]
Func_00_3c94:
	pop hl
	pop de
	pop bc
	ret

Data_00_3c98:
	ld a, [$d61b]
	inc a
	and $01
	ld [$d61b], a
	jr Func_00_3c94

PrintCharacterAtCursor_Helper1:
	push bc
	ld a, c
	call PrintCharacterAtCursor_Helper2
	jr nc, Func_00_3cad

Func_00_3caa:
	db $1b, $18, $08   ; dec de / jr $3cb5 (unreached stray)

Func_00_3cad:
	ld a, e
	add a, $20
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	ld b, $00
	ld hl, $3d10
	add hl, bc
	ld b, [hl]
	ld a, c
	cp $de
	jr z, Func_00_3cd3
	cp $df
	jr z, Func_00_3cd3
	cp $b0
	jr z, Func_00_3cd3
	ld a, [$d61b]
	or a
	jr z, Func_00_3cd3

Func_00_3ccf:
	ld a, $38
	add a, b
	ld b, a

Func_00_3cd3:
	ld a, $01
	ldh [rVBK], a
	di
	call WaitForHBlank
	ld a, $07
	ld [de], a
	ld a, $00
	ldh [rVBK], a
	ld a, b
	ld [de], a
	ei
	pop bc
	ret
PrintCharacterAtCursor_Helper2:
	cp $de
	jr z, Data_00_3cf1
	cp $df
	jr z, Data_00_3cf1
	xor a
	ret

Data_00_3cf1:
	scf
	ret

DispatchTextRenderer:
	ld a, [$7fff]
	push af
	ld a, [wRendererBank]
	ld [$2fff], a
	ld hl, $3d0b
	push hl
	ld hl, wRendererAddr
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	or h
	ret z
	jp hl
DispatchTextRenderer_Return:
	pop af
	ld [$2fff], a
	ret
