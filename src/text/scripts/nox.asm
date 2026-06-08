; Nox flashback dialogues (bank 19).
;
; The player watches a series of flashback / memory scenes featuring
; Nox and his childhood friend Alf. NoxScript holds four SCRIPT_END
; sub-scripts back to back; each runs independently, dispatched by the
; engine (re-entered at the address after the preceding SCRIPT_END)
; when the corresponding story trigger fires:
;
;   $4C449  Nox/Alf flashback ("Wow, you were cool back then... It's
;           a promise between men!"). Two-speaker scene alternating
;           the Nox_RenderPortrait_AlfSpeaking / _NoxSpeaking renderers
;           for the left vs right bubble positions.
;   $46D5   Nox reminiscing solo ("Whew! I forgot just how much fun it
;           was...") — Nox_RenderPortrait_Reminiscing.
;   $473D   Nox "I'll go see old friends" — Nox_RenderPortrait_GoSeeFriends.
;   $47C3   Nox "Wait, I forgot" (short) — Nox_RenderPortrait_Note.
;
; The flashbacks use textbox tilemap position $9C22 (vs the standard
; $9982 used by overworld NPCs), placing the dialog in a different
; on-screen region appropriate for a flashback/memory view.
;
; See docs/text_engine.md for the bytecode reference.

INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "text.inc"
INCLUDE "sound_ids.inc"

; The Nox flashback driver and its scene-setup helpers ($4000-$4283),
; relocated here from analyzed.asm to sit with the renderers and scripts they
; drive. Func_13_4000 (FAR_CALLed from gameplay.asm) plays the four flashback
; sub-scripts (NoxScript / NoxReminisceScript / NoxGoSeeFriendsScript /
; NoxNoteScript) in sequence, with portrait/scene setup between each.
SECTION "analyzed_04c000", ROMX[$4000], BANK[$13]

Func_13_4000:
	push af
	ld a, SOUND_BGM_39
	call PlaySoundTracked
	pop af
	call Func_13_4061
	ld a, $01
	ld [$d61a], a
	ld a, $e7
	ldh [rLCDC], a
	ld hl, NoxScript
	call ScriptDispatcherEnterAfterCall
	ld a, $c7
	ldh [rLCDC], a
	call Func_13_40b7
	ld a, $e7
	ldh [rLCDC], a
	ld hl, NoxReminisceScript
	call ScriptDispatcherEnterAfterCall
	ld a, $c7
	ldh [rLCDC], a
	call Func_13_4108
	ld a, $e7
	ldh [rLCDC], a
	ld hl, NoxGoSeeFriendsScript
	call ScriptDispatcherEnterAfterCall
	ld a, $c7
	ldh [rLCDC], a
	call Func_13_4143
	ld a, $e7
	ldh [rLCDC], a
	ld hl, NoxNoteScript
	call ScriptDispatcherEnterAfterCall
	call Func_13_4434
	push af
	ld a, SOUND_BGM_3a
	call PlaySoundTracked
	pop af
	ld a, $c7
	ldh [rLCDC], a
	call Func_13_41e5
	call Func_13_4222
	ret
Func_13_4061:
	call Func_00_07a7
	ld a, $01
	ldh [rVBK], a
	ld hl, $4a45
	ld de, $8000
	ld bc, $1000
	call VramCopy16
	xor a
	ld [$d61b], a
	ld [wRendererAddr], a
	ld [$d61f], a
	ld a, $00
	ldh [rVBK], a
	ld a, $19
	ld hl, $46cb
	ld de, $8800
	ld bc, $1000
	call BankVramCopy
	ld hl, $5ac5
	ld de, $9800
	call CopyBgMap
	ld hl, $6161
	ld de, $9c00
	call CopyBgMap
	ld a, $07
	ldh [rWX], a
	ld a, $60
	ldh [rWY], a
	ld hl, $5a45
	call LoadBgPalettes
	ld hl, $5a85
	call LoadObjPalettes
	ret
Func_13_40b7:
	ld hl, $62a3
	ld de, $9900
	call CopyBgMap
	call Func_13_42f6
	call Func_13_433e
	call Func_13_4362
	call HideUnusedOamSprites
	ld bc, $3078
	ld d, $20
Func_13_40d1:
	call WaitForNextFrame
	ld a, $02
	inc b
	call Func_00_20fa
	call Func_13_4378
	dec d
	jr nz, Func_13_40d1
	ld d, $28
Func_13_40e2:
	call WaitForNextFrame
	ld a, $02
	dec c
	call Func_00_20fa
	call Func_13_4399
	dec d
	jr nz, Func_13_40e2
	ld d, $70
Func_13_40f3:
	call WaitForNextFrame
	ld a, $02
	inc b
	call Func_00_20fa
	call Func_13_4378
	dec d
	jr nz, Func_13_40f3
	ld d, $5a
	call Func_13_4442
	ret
Func_13_4108:
	ld hl, $62a3
	ld de, $9900
	call CopyBgMap
	call Func_13_4308
	call Func_13_4350
	call Func_13_4362
	call HideUnusedOamSprites
	ld bc, $3088
	ld d, $20
Func_13_4122:
	call WaitForNextFrame
	ld a, $00
	inc b
	call Func_00_20fa
	call Func_13_43de
	dec d
	jr nz, Func_13_4122
	ld d, $38
Func_13_4133:
	call WaitForNextFrame
	ld a, $00
	dec c
	call Func_00_20fa
	call Func_13_43cc
	dec d
	jr nz, Func_13_4133
	ret
Func_13_4143:
	ld hl, $62a3
	ld de, $9900
	call CopyBgMap
	call Func_13_431a
	call Func_13_4350
	call Func_13_4362
	call HideUnusedOamSprites
	ld bc, $5050
	ld d, $10
Func_13_415d:
	call WaitForNextFrame
	ld a, $00
	dec b
	call Func_00_20fa
	call Func_13_43f0
	dec d
	jr nz, Func_13_415d
	ld d, $08
Func_13_416e:
	call WaitForNextFrame
	ld a, $00
	dec c
	call Func_00_20fa
	call Func_13_43cc
	dec d
	jr nz, Func_13_416e
	push bc
	ld a, $00
	ld bc, $0608
	call Func_00_2117
	ld d, $1e
	call Func_13_4442
	ld a, $04
	ld bc, $f0f0
	call Func_00_20fa
	pop bc
	ld d, $08
Func_13_4196:
	call WaitForNextFrame
	ld a, $00
	inc c
	call Func_00_20fa
	call Func_13_43ba
	dec d
	jr nz, Func_13_4196
	ld d, $60
Func_13_41a7:
	call WaitForNextFrame
	ld a, $00
	inc b
	call Func_00_20fa
	call Func_13_43de
	dec d
	jr nz, Func_13_41a7
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	ld d, $b4
	call Func_13_4442
	ld d, $60
Func_13_41c4:
	call WaitForNextFrame
	ld a, $00
	dec b
	call Func_00_20fa
	call Func_13_43f0
	dec d
	jr nz, Func_13_41c4
	ld d, $08
Func_13_41d5:
	call WaitForNextFrame
	ld a, $00
	inc c
	call Func_00_20fa
	call Func_13_43ba
	dec d
	jr nz, Func_13_41d5
	ret
Func_13_41e5:
	ld a, $00
	ld bc, $f0f0
	call Func_00_20fa
	ld hl, $5e8b
	ld de, $9800
	call CopyBgMap
	call Func_13_49a5
	xor a
	ld [wUiTimer], a
	ld [$cfbc], a
	inc a
	ld [wUiState], a
Func_13_4204:
	ld b, d
	ld d, $08
	call Func_13_4442
	ld d, b
	call Func_13_49ac
	call Func_13_4a18
	ld a, [wUiTimer]
	inc a
	ld [wUiTimer], a
	ld a, [wUiState]
	or a
	jr nz, Func_13_4204
	call Func_00_07c5
	ret
Func_13_4222:
	call Func_13_4266
	call ResetScrollState
	xor a
	ld [$cfbc], a
	call Func_00_0794
	ld de, $0258
Func_13_4232:
	call WaitForNextFrame
	call WaitForNextFrame
	push de
	call Func_13_4947
	call Func_13_499f
	pop de
	dec de
	ld a, e
	or d
	jr nz, Func_13_4232
	call ResetScrollState
	ld hl, $62c9
	ld de, $9907
	call CopyBgMap
	ld d, $b4
	call Func_13_4442
	ld d, $78
	call Func_13_4442
	call Func_00_07c5
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	ret
Func_13_4266:
	xor a
	ldh [rVBK], a
	ld hl, $9800
	ld bc, $0400
	ld d, $fc
	call FillVram
	ld a, $01
	ldh [rVBK], a
	ld hl, $9800
	ld bc, $0400
	ld d, $0f
	call FillVram
	ret

SECTION "analyzed_04c284", ROMX[$4284], BANK[$13]

Nox_RenderPortrait_AlfSpeaking:
	ld hl, $627d
	ld de, $9900
	call CopyBgMap
	ld a, $13
	ld [wDrawBank], a
	call Func_13_42f6
	call Func_13_433e
	call Func_13_4362
	ret
Nox_RenderPortrait_NoxSpeaking:
	ld hl, $6257
	ld de, $9900
	call CopyBgMap
	ld a, $13
	ld [wDrawBank], a
	call Func_13_42f6
	call Func_13_433e
	call Func_13_4362
	ret
Nox_RenderPortrait_Reminiscing:
	ld hl, $6257
	ld de, $9900
	call CopyBgMap
	ld a, $13
	ld [wDrawBank], a
	call Func_13_4308
	call Func_13_4350
	call Func_13_4362
	ret
Nox_RenderPortrait_GoSeeFriends:
	ld hl, $6257
	ld de, $9900
	call CopyBgMap
	ld a, $13
	ld [wDrawBank], a
	call Func_13_431a
	call Func_13_4350
	call Func_13_4362
	ret
Nox_RenderPortrait_Note:
	ld hl, $6257
	ld de, $9900
	call CopyBgMap
	ld a, $13
	ld [wDrawBank], a
	call Func_13_432c
	ret
Func_13_42f6:
	ld hl, $6329
	ld bc, $1008
	call DrawMetasprite
	ld a, $00
	ld bc, $3088
	call Func_00_20fa
	ret
Func_13_4308:
	ld hl, $62f3
	ld bc, $1008
	call DrawMetasprite
	ld a, $00
	ld bc, $3088
	call Func_00_20fa
	ret
Func_13_431a:
	ld hl, $62f3
	ld bc, $1008
	call DrawMetasprite
	ld a, $00
	ld bc, $5050
	call Func_00_20fa
	ret
Func_13_432c:
	ld hl, $630e
	ld bc, $1008
	call DrawMetasprite
	ld a, $00
	ld bc, $4058
	call Func_00_20fa
	ret
Func_13_433e:
	ld hl, $637a
	ld bc, $1008
	call DrawMetasprite
	ld a, $02
	ld bc, $3078
	call Func_00_20fa
	ret
Func_13_4350:
	ld hl, $637a
	ld bc, $1008
	call DrawMetasprite
	ld a, $02
	ld bc, $f0f0
	call Func_00_20fa
	ret
Func_13_4362:
	ld hl, $6383
	ld bc, $1008
	call DrawMetasprite
	ld a, $04
	ld bc, $3048
	call Func_00_20fa
	ret

Data_13_4374:
	db $16, $20, $16, $22

Func_13_4378:
	ld a, d
	rrca
	rrca
	rrca
	rrca
	and $03
	ld hl, $4374
	rst AddAToHL
	ld e, [hl]
	ld hl, $c00a
	ld a, e
	ld [hl+], a
	ld [hl], $09
	ld a, $03
	rst AddAToHL
	ld a, e
	add a, $08
	ld [hl+], a
	ld [hl], $09
	ret

Data_13_4395:
	db $24, $26, $24

SECTION "Alf/Nox script", ROMX

NoxScript:
    SCRIPT_OPEN_TEXTBOX .Pos=$9c22, .Width=$10, .Height=$04
    SCRIPT_RENDERER .Addr=Nox_RenderPortrait_AlfSpeaking, .Bank=$13
    db "Wow, you were"
    SCRIPT_NEWLINE
    db "cool back then."
    SCRIPT_WAIT
    db "You don't look"
    SCRIPT_NEWLINE
    db "so cool now."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Nox_RenderPortrait_NoxSpeaking, .Bank=$13
    db "Ugh..."
    SCRIPT_NEWLINE
    db "That's harsh."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Nox_RenderPortrait_AlfSpeaking, .Bank=$13
    db "Cool! I want"
    SCRIPT_NEWLINE
    db "adventure like"
    SCRIPT_WAIT
    db "that! Is that"
    SCRIPT_NEWLINE
    db "tower there now?"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Nox_RenderPortrait_NoxSpeaking, .Bank=$13
    db "Of course, Alf."
    SCRIPT_WAIT
    db "You should go"
    SCRIPT_NEWLINE
    db "there someday."
    SCRIPT_WAIT
    db "You'd have"
    SCRIPT_NEWLINE
    db "a great time."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Nox_RenderPortrait_AlfSpeaking, .Bank=$13
    db "Hmmm..."
    SCRIPT_NEWLINE
    db "After I grow up?"
    SCRIPT_WAIT
    db "Oh no! I want"
    SCRIPT_NEWLINE
    db "to go there now!"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Nox_RenderPortrait_NoxSpeaking, .Bank=$13
    db "Whoa whoa whoa!"
    SCRIPT_NEWLINE
    db "It's dangerous."
    SCRIPT_WAIT
    db "What happens if"
    SCRIPT_NEWLINE
    db "you get lost?"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Nox_RenderPortrait_AlfSpeaking, .Bank=$13
    db "Gimme a break!"
    SCRIPT_WAIT
    db "You're the"
    SCRIPT_NEWLINE
    db "one who's lost!"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Nox_RenderPortrait_NoxSpeaking, .Bank=$13
    db "Ugh..."
    SCRIPT_NEWLINE
    db "Alf..."
    SCRIPT_WAIT
    db "You're harsh..."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Nox_RenderPortrait_AlfSpeaking, .Bank=$13
    db "Will you take me"
    SCRIPT_NEWLINE
    db "when I'm grown?"
    SCRIPT_WAIT
    db "A promise 'tween"
    SCRIPT_WAIT
    db "men, okay? I'll"
    SCRIPT_NEWLINE
    db "wait till then!"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Nox_RenderPortrait_NoxSpeaking, .Bank=$13
    db "Okay."
    SCRIPT_NEWLINE
    db "I promise."
    SCRIPT_WAIT
    db "It's a promise"
    SCRIPT_NEWLINE
    db "between men!"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Nox_RenderPortrait_AlfSpeaking, .Bank=$13
    db "Okay! Now I'll"
    SCRIPT_NEWLINE
    db "practice and"
    SCRIPT_WAIT
    db "become a"
    SCRIPT_NEWLINE
    db "Battle Card"
    SCRIPT_WAIT
    db "Master! I'll"
    SCRIPT_NEWLINE
    db "see you later!"
    SCRIPT_WAIT
    SCRIPT_END

; $46d5 — Nox reminiscing solo after the flashback ("Whew! I forgot...").
NoxReminisceScript:
    SCRIPT_RENDERER .Addr=Nox_RenderPortrait_Reminiscing, .Bank=$13
    db "Whew! I forgot"
    SCRIPT_NEWLINE
    db "just how much"
    SCRIPT_WAIT
    db "fun it was then."
    SCRIPT_NEWLINE
    db "Ah, memories!"
    SCRIPT_WAIT
    db "Thanks, Alf."
    SCRIPT_WAIT
    db "I wonder how"
    SCRIPT_NEWLINE
    db "everyone is."
    SCRIPT_WAIT
    SCRIPT_END

; $473d — Nox decides to go see old friends.
NoxGoSeeFriendsScript:
    SCRIPT_RENDERER .Addr=Nox_RenderPortrait_GoSeeFriends, .Bank=$13
    db "I know!"
    SCRIPT_WAIT
    db "I'll go see"
    SCRIPT_NEWLINE
    db "old friends!"
    SCRIPT_WAIT
    db "I have to"
    SCRIPT_NEWLINE
    db "refresh myself"
    SCRIPT_WAIT
    db "for Alf, anyway."
    SCRIPT_WAIT
    db "He'll get"
    SCRIPT_NEWLINE
    db "mad if I don't"
    SCRIPT_WAIT
    db "know my way."
    SCRIPT_NEWLINE
    db "Okay, off I go!"
    SCRIPT_WAIT
    SCRIPT_END

; $47c3 — Nox remembers to leave a note ("Wait, I forgot").
NoxNoteScript:
    SCRIPT_RENDERER .Addr=Nox_RenderPortrait_Note, .Bank=$13
    db "Wait, I forgot."
    SCRIPT_NEWLINE
    db "Withouta note,"
    SCRIPT_WAIT
    db "Nox will get"
    SCRIPT_NEWLINE
    db "mad again."
    SCRIPT_WAIT
    SCRIPT_END

; --- Nox flashback: animation helpers + graphics/metasprite data ($4398-$637a) ---
; The rest of bank $13, relocated from analyzed.asm to join the driver,
; renderers and scripts above -- the whole flashback subsystem now lives here.
; These fixed-address sections hold the per-frame animation routines the driver
; calls (Func_13_4399/43ba/43cc/43de/43f0/4434/4442/49a5/4a18/...) and the
; flashback's data (Data_13_4a45 = the CH-tile source Func_13_4061 uploads;
; the $62xx-$637a blocks are DrawMetasprite lists used by the renderers).
; Addresses are unchanged; kept as separate sections (the original split has
; $00-pad gaps, so they can't simply be merged).
SECTION "analyzed_04c398", ROMX[$4398], BANK[$13]

Data_13_4398:
	db $26

SECTION "analyzed_04c399", ROMX[$4399], BANK[$13]

Func_13_4399:
	ld a, d
	rrca
	rrca
	rrca
	rrca
	and $03
	ld hl, $4395
	rst AddAToHL
	ld e, [hl]
	ld hl, $c00a
	ld a, e
	ld [hl+], a
	ld [hl], $09
	ld a, $03
	rst AddAToHL
	ld a, e
	add a, $08
	ld [hl+], a
	ld [hl], $09
	ret

SECTION "analyzed_04c3b6", ROMX[$43b6], BANK[$13]

Data_13_43b6:
	db $1a

SECTION "analyzed_04c3b7", ROMX[$43b7], BANK[$13]

Data_13_43b7:
	db $1c, $1a, $1c

Func_13_43ba:
	ld hl, $43b6
	ld a, d
	rrca
	rrca
	rrca
	rrca
	and $03
	call Func_13_4419
	ret

Data_13_43c8:
	db $12, $14, $12, $14

Func_13_43cc:
	ld hl, $43c8
	ld a, d
	rrca
	rrca
	rrca
	rrca
	and $03
	call Func_13_4406
	ret

Data_13_43da:
	db $00, $02, $00, $04

Func_13_43de:
	ld hl, $43da
	ld a, d
	rrca
	rrca
	rrca
	rrca
	and $03
	call Func_13_4406
	ret

Data_13_43ec:
	db $06, $10, $06, $18

Func_13_43f0:
	ld hl, $43ec
	ld a, d
	rrca
	rrca
	rrca
	rrca
	and $03
	cp $03
	jr z, Func_13_4402
	call Func_13_4406
	ret
Func_13_4402:
	call Func_13_4419
	ret
Func_13_4406:
	rst AddAToHL
	ld e, [hl]
	ld hl, $c002
	ld a, e
	ld [hl+], a
	ld [hl], $08
	ld a, $03
	rst AddAToHL
	ld a, e
	add a, $08
	ld [hl+], a
	ld [hl], $08
	ret
Func_13_4419:
	rst AddAToHL
	ld e, [hl]
	ld hl, $c002
	ld a, e
	ld [hl+], a
	ld [hl], $28
	ld a, $03
	rst AddAToHL
	ld a, e
	sub $08
	ld [hl+], a
	ld [hl], $28
	ret

Data_13_442c:
	db $00, $00, $94, $52, $4a, $29, $ff, $7f

Func_13_4434:
	ld hl, $442c
	ld a, $07
	ld b, $01
	call Func_00_0716
	call Func_00_0786
	ret
Func_13_4442:
	call WaitForNextFrame
	dec d
	jr nz, Func_13_4442
	ret

SECTION "analyzed_04c884", ROMX[$4884], BANK[$13]

Data_13_4884:
	db $be, $48, $3b, $49, $3b, $49, $3b, $49, $ca, $48, $3b, $49, $d3, $48, $3b, $49
	db $dd, $48, $3b, $49, $e3, $48, $3b, $49, $ed, $48, $3b, $49, $f8, $48, $3b, $49
	db $02, $49, $3b, $49, $0c, $49, $3b, $49, $15, $49, $3b, $49, $20, $49, $3b, $49
	db $2a, $49, $3b, $49, $31, $49, $3b, $49, $00, $00, $53, $54, $41, $47, $45, $20
	db $53, $54, $41, $46, $46, $00, $48, $a5, $4d, $4f, $54, $4f, $4b, $49, $00, $52
	db $a5, $53, $48, $49, $4e, $41, $44, $41, $00, $59, $a5, $41, $42, $45, $00, $59
	db $a5, $54, $41, $4b, $41, $4f, $4b, $41, $00, $4a, $a5, $59, $41, $4d, $41, $4d
	db $4f, $54, $4f, $00, $4d, $a5, $48, $41, $59, $41, $53, $48, $49, $00, $54, $a5
	db $54, $53, $55, $54, $53, $55, $49, $00, $54, $a5, $4f, $48, $4d, $4f, $52, $49
	db $00, $4d, $a5, $53, $55, $47, $41, $4e, $55, $4d, $41, $00, $4d, $a5, $4e, $41
	db $47, $41, $55, $52, $41, $00, $59, $a5, $55, $45, $44, $41, $00, $54, $a5, $49
	db $4e, $41, $4d, $4f, $54, $4f, $00, $20, $20, $20, $20, $20, $20, $20, $20, $20
	db $20, $20, $00

Func_13_4947:
	ldh a, [rSCY]
	ld b, a
	and $07
	ret nz
	ld a, b
	rrca
	rrca
	rrca
	add a, $12
	and $1f
	ld c, a
	ld a, [$cfbc]
	add a, a
	ld hl, $4884
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, h
	cp $00
	jr nz, Func_13_496b
	ld hl, $493b
	jr Func_13_4972
Func_13_496b:
	ld a, [$cfbc]
	inc a
	ld [$cfbc], a
Func_13_4972:
	ld de, $9800
	ld a, c
	or a
	jr z, Func_13_497f
Func_13_4979:
	ld a, $20
	rst AddAToDE
	dec c
	jr nz, Func_13_4979
Func_13_497f:
	ld a, $02
	rst AddAToDE
Func_13_4982:
	ld a, [hl+]
	ld c, a
	or a
	jr z, Func_13_499e
	ld a, e
	ld [wTextCursor], a
	ld a, d
	ld [$d617], a
	push hl
	push de
	FAR_CALL $00, PrintCharacterAtCursor
	pop de
	pop hl
	inc de
	jr Func_13_4982
Func_13_499e:
	ret
Func_13_499f:
	ldh a, [rSCY]
	inc a
	ldh [rSCY], a
	ret
Func_13_49a5:
	ld de, $9862
	ld hl, $47ff
	ret
Func_13_49ac:
	ld a, e
	ld [wTextCursor], a
	ld a, d
	ld [$d617], a
	ld a, [hl+]
	ld c, a
	cp $ff
	jr z, Func_13_4a08
	cp $0d
	jr z, Func_13_49df
	cp $04
	jr z, Func_13_49e9
	cp $40
	jr z, Func_13_49d0
	cp $de
	jr z, Func_13_49d0
	cp $df
	jr z, Func_13_49d0
	jr Func_13_49d1

SECTION "analyzed_04c9d0", ROMX[$49d0], BANK[$13]

Func_13_49d0:
	dec de

SECTION "analyzed_04c9d1", ROMX[$49d1], BANK[$13]

Func_13_49d1:
	push hl
	push de
	FAR_CALL $00, PrintCharacterAtCursor
	pop de
	inc de
	pop hl
	ret
Func_13_49df:
	ld a, $40
	rst AddAToDE
	ld a, e
	and $e0
	add a, $02
	ld e, a
	ret
Func_13_49e9:
	dec hl
	ld a, [$cfbc]
	inc a
	ld [$cfbc], a
	cp $0d
	ret nz
	push hl
	ld hl, $5e8b
	ld de, $9800
	call CopyBgMap
	ld de, $9862
	pop hl
	inc hl
	xor a
	ld [$cfbc], a
	ret
Func_13_4a08:
	dec hl
	ld a, [$cfbc]
	inc a
	ld [$cfbc], a
	cp $0d
	ret nz
	xor a
	ld [wUiState], a
	ret
Func_13_4a18:
	push hl
	push de
	ld h, d
	ld l, e
	ld a, $20
	rst AddAToHL
	xor a
	ldh [rVBK], a
	ld bc, $0001
	ld a, [wUiTimer]
	and $01
	jr z, Func_13_4a30
	ld d, $ec
	jr Func_13_4a32
Func_13_4a30:
	ld d, $fc
Func_13_4a32:
	call FillVram
	dec hl
	ld a, $01
	ldh [rVBK], a
	ld bc, $0001
	ld d, $0f
	call FillVram
	pop de
	pop hl
	ret

Data_13_4a45:
	db $07, $07, $08, $0f, $10, $1f, $20, $3f, $2f, $3f, $17, $1a, $1f, $12, $0e, $09
	db $17, $1c, $2b, $3f, $7b, $4e, $7d, $4f, $38, $3f, $08, $0f, $09, $0f, $07, $07
	db $00, $00, $07, $07, $08, $0f, $10, $1f, $20, $3f, $2f, $3f, $17, $1a, $1f, $12
	db $1e, $19, $37, $2c, $3b, $2f, $1d, $1f, $08, $0f, $08, $0f, $08, $0f, $07, $07
	db $00, $00, $07, $07, $08, $0f, $10, $1f, $20, $3f, $2f, $3f, $17, $1a, $1f, $12
	db $0e, $09, $07, $04, $3b, $3f, $7d, $4f, $78, $4f, $38, $3f, $07, $07, $01, $01
	db $07, $07, $08, $0f, $18, $1f, $28, $3f, $28, $3f, $23, $3f, $10, $1f, $0f, $0f
	db $13, $1f, $28, $3f, $78, $4f, $7c, $4f, $38, $3f, $08, $0f, $09, $0f, $07, $07
	db $e0, $e0, $10, $f0, $e8, $f8, $04, $fc, $f4, $fc, $e8, $58, $f8, $48, $70, $90
	db $e8, $38, $d4, $fc, $de, $72, $be, $f2, $1c, $fc, $10, $f0, $90, $f0, $e0, $e0
	db $00, $00, $e0, $e0, $10, $f0, $e8, $f8, $04, $fc, $f4, $fc, $e8, $58, $f8, $48
	db $70, $90, $e0, $20, $dc, $fc, $be, $f2, $1e, $f2, $1c, $fc, $e0, $e0, $80, $80
	db $00, $00, $e0, $e0, $10, $f0, $e8, $f8, $04, $fc, $f4, $fc, $e8, $58, $f8, $48
	db $78, $98, $ec, $34, $dc, $f4, $b8, $f8, $10, $f0, $10, $f0, $10, $f0, $e0, $e0
	db $e0, $e0, $10, $f0, $18, $f8, $14, $fc, $14, $fc, $c4, $fc, $08, $f8, $f0, $f0
	db $c8, $f8, $14, $fc, $1e, $f2, $3e, $f2, $1c, $fc, $10, $f0, $90, $f0, $e0, $e0
	db $00, $00, $07, $07, $08, $0f, $18, $1f, $28, $3f, $28, $3f, $23, $3f, $10, $1f
	db $1f, $1f, $37, $2f, $38, $2f, $1c, $1f, $08, $0f, $08, $0f, $08, $0f, $07, $07
	db $07, $07, $08, $0f, $1c, $1f, $20, $3f, $3e, $3f, $1f, $15, $1f, $14, $07, $18
	db $1f, $10, $0f, $0f, $07, $06, $07, $06, $05, $07, $04, $07, $04, $07, $03, $03
	db $00, $00, $07, $07, $08, $0f, $1c, $1f, $20, $3f, $3e, $3f, $1f, $15, $1f, $14
	db $07, $18, $1f, $10, $0f, $0f, $07, $04, $07, $07, $08, $0f, $08, $0f, $07, $07
	db $07, $07, $0d, $0a, $19, $16, $19, $16, $18, $17, $37, $2f, $4f, $7a, $3f, $32
	db $0f, $08, $07, $07, $19, $1e, $3c, $27, $3c, $27, $1b, $1f, $04, $07, $08, $0f
	db $00, $00, $e0, $e0, $10, $f0, $18, $f8, $14, $fc, $14, $fc, $c4, $fc, $08, $f8
	db $f0, $f0, $e0, $e0, $1c, $fc, $3e, $f2, $1e, $f2, $1c, $fc, $e0, $e0, $80, $80
	db $c0, $c0, $20, $e0, $10, $f0, $38, $f8, $08, $f8, $f8, $f8, $d0, $70, $d0, $70
	db $a0, $e0, $10, $f0, $d0, $70, $f0, $70, $90, $f0, $10, $f0, $10, $f0, $e0, $e0
	db $00, $00, $c0, $c0, $20, $e0, $10, $f0, $38, $f8, $08, $f8, $f8, $f8, $d0, $70
	db $d0, $70, $a0, $e0, $90, $f0, $b0, $f0, $10, $f0, $08, $f8, $88, $f8, $70, $70
	db $e0, $e0, $30, $d0, $18, $e8, $18, $e8, $18, $e8, $ec, $f4, $f2, $5e, $fc, $4c
	db $f0, $10, $e0, $e0, $18, $f8, $bc, $64, $7c, $a4, $d8, $f8, $20, $e0, $10, $f0
	db $00, $00, $07, $07, $0d, $0a, $19, $16, $19, $16, $18, $17, $37, $2f, $4f, $7a
	db $3f, $32, $1f, $18, $37, $2f, $31, $2e, $18, $1f, $08, $0f, $0b, $0f, $19, $1f
	db $00, $00, $07, $07, $0c, $0b, $18, $17, $18, $17, $18, $17, $37, $2f, $4f, $7a
	db $3f, $32, $0f, $08, $07, $07, $19, $1e, $3e, $27, $3c, $27, $1b, $1b, $00, $00
	db $03, $03, $06, $05, $0c, $0b, $0c, $0b, $18, $17, $27, $3f, $3f, $38, $0f, $0a
	db $0f, $0a, $07, $04, $03, $03, $01, $03, $03, $02, $03, $02, $01, $03, $01, $01
	db $00, $00, $03, $03, $06, $05, $0c, $0b, $0c, $0b, $18, $17, $27, $3f, $3f, $38
	db $0f, $0a, $0f, $0a, $07, $04, $03, $03, $00, $03, $01, $03, $01, $03, $00, $01
	db $00, $00, $e0, $e0, $30, $d0, $18, $e8, $18, $e8, $18, $e8, $ec, $f4, $f2, $5e
	db $fc, $4c, $f0, $10, $e0, $e0, $18, $f8, $fc, $64, $7c, $a4, $d8, $d8, $00, $00
	db $00, $00, $e0, $e0, $b0, $50, $98, $68, $98, $68, $18, $e8, $ec, $f4, $f2, $5e
	db $fc, $4c, $f8, $18, $ec, $f4, $0c, $f4, $d8, $38, $30, $d0, $d0, $f0, $98, $f8
	db $e0, $e0, $50, $b0, $58, $a8, $4c, $b4, $4c, $b4, $0c, $f4, $e6, $fa, $fa, $1e
	db $ec, $1c, $f0, $30, $e0, $e0, $98, $f8, $dc, $74, $de, $72, $a6, $fa, $fe, $fe
	db $00, $00, $e0, $e0, $50, $b0, $58, $a8, $4c, $b4, $0c, $f4, $0c, $f4, $e6, $fa
	db $fa, $1e, $ec, $1c, $f0, $30, $e0, $e0, $cc, $fc, $fe, $3a, $f7, $39, $cf, $ff
	db $00, $00, $00, $00, $00, $00, $01, $01, $03, $03, $07, $04, $07, $04, $07, $06
	db $0b, $0d, $0f, $08, $1e, $11, $1e, $11, $3f, $20, $2f, $30, $1b, $1c, $07, $07
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $38, $38, $dc, $e4, $b6, $6a, $7e, $9a, $cb, $3d, $df, $3d
	db $ef, $3d, $ef, $dd, $eb, $1d, $ee, $12, $ec, $14, $c4, $3c, $18, $f8, $e0, $e0

SECTION "analyzed_04d247", ROMX[$5247], BANK[$13]

Data_13_5247:
	db $7f, $7f, $64, $63, $64, $63, $64, $63, $6a, $67, $60, $6f, $61, $7e, $68, $70
	db $62, $41, $49, $47, $57, $4f, $6f, $5f, $5f, $7f, $7e, $7e, $7e, $7e, $7e, $7e
	db $7e, $7e, $7f, $7f, $7e, $7f, $7f, $7f, $7f, $7f, $71, $78, $40, $40, $40, $40
	db $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $00, $00, $7f, $7f, $00, $00
	db $7f, $7f, $40, $4c, $40, $4c, $40, $4c, $44, $48, $40, $48, $40, $58, $49, $50
	db $40, $51, $40, $51, $42, $71, $50, $63, $44, $63, $60, $47, $51, $4f, $6f, $5f
	db $7f, $7f, $7f, $7f, $7f, $7f, $4f, $5f, $41, $43, $40, $41, $40, $40, $40, $40
	db $40, $40, $40, $40, $40, $40, $47, $4f, $5c, $7b, $00, $00, $7f, $7f, $00, $00
	db $ff, $ff, $0e, $ff, $70, $ff, $80, $ff, $00, $ff, $18, $e7, $23, $1f, $9f, $7f
	db $7f, $ff, $fd, $ff, $f1, $ff, $f7, $fb, $1d, $1f, $18, $0f, $1b, $0c, $1f, $08
	db $3b, $08, $73, $18, $e7, $f3, $0a, $c7, $1a, $84, $58, $80, $0a, $71, $00, $3b
	db $0b, $15, $07, $08, $03, $04, $01, $02, $00, $01, $00, $00, $ff, $ff, $00, $00
	db $ff, $ff, $00, $f0, $00, $f0, $00, $f0, $00, $f0, $00, $f0, $00, $f0, $00, $f0
	db $00, $f0, $00, $f0, $10, $e0, $00, $e0, $00, $e0, $1f, $ef, $fe, $ff, $fb, $fc
	db $fc, $f0, $a0, $70, $80, $30, $00, $c0, $0a, $8c, $c7, $80, $e7, $c7, $f0, $e0
	db $94, $d8, $1d, $9e, $7f, $7f, $9e, $8f, $ff, $8f, $00, $00, $ff, $ff, $00, $00
	db $ff, $ff, $00, $ff, $00, $ff, $00, $ff, $07, $ff, $7f, $ff, $ff, $ff, $e3, $e1
	db $9f, $9e, $2f, $2e, $2f, $2c, $1f, $01, $9f, $83, $7c, $ff, $04, $f8, $e3, $00
	db $07, $f8, $0b, $f4, $a5, $da, $8d, $06, $0f, $06, $5f, $2e, $bd, $7e, $ff, $fc
	db $fb, $fc, $f7, $f8, $8e, $71, $f9, $07, $8f, $ff, $00, $00, $ff, $ff, $00, $00
	db $ff, $ff, $01, $3e, $01, $3e, $01, $3e, $01, $3e, $00, $3f, $40, $3f, $00, $7f
	db $00, $7f, $00, $7f, $00, $7f, $40, $3f, $fe, $7f, $df, $ff, $7f, $fd, $f6, $b5
	db $1c, $1d, $41, $02, $23, $1c, $07, $00, $06, $01, $cf, $21, $9f, $c3, $3f, $07
	db $ef, $1d, $bf, $79, $ee, $e3, $3c, $cf, $f0, $ff, $00, $00, $ff, $ff, $00, $00
	db $fd, $fd, $01, $fd, $01, $fd, $7d, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $bd, $fd
	db $dd, $fd, $fd, $fd, $8d, $fd, $85, $fd, $05, $fd, $e5, $1d, $e1, $1d, $c1, $3d
	db $c1, $3d, $85, $7d, $85, $7d, $a5, $5d, $a5, $5d, $4d, $bd, $4d, $bd, $9d, $7d
	db $99, $7d, $75, $f9, $79, $f5, $e9, $f5, $d1, $ed, $01, $01, $ff, $ff, $00, $00
	db $fd, $fd, $d1, $31, $d1, $39, $c9, $39, $c9, $39, $e9, $19, $e9, $1d, $e5, $1d
	db $f1, $0d, $71, $8d, $79, $85, $7d, $81, $3d, $c1, $dd, $e1, $fd, $fd, $2d, $dd
	db $6d, $9d, $5d, $bd, $3d, $fd, $fd, $fd, $f9, $fd, $f1, $f9, $d1, $f1, $d1, $d1
	db $81, $d1, $c1, $e1, $31, $f9, $0d, $fd, $01, $fd, $01, $01, $ff, $ff, $3f, $3f
	db $40, $40, $9f, $9f, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0
	db $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $ff, $ff
	db $00, $00, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $ff, $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $ff, $24, $3c
	db $12, $1e, $09, $0f, $04, $07, $02, $03, $01, $01, $00, $00, $00, $00, $81, $ff
	db $81, $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff
	db $81, $ff, $81, $ff, $81, $ff, $81, $ff, $ff, $ff, $81, $ff, $81, $ff, $ff, $ff
	db $80, $ff, $80, $ff, $80, $ff, $ff, $ff, $80, $ff, $bf, $ff, $ae, $ea, $ae, $ea
	db $ae, $ea, $ae, $ee, $bb, $ff, $a0, $ff, $bf, $ff, $a0, $ff, $bf, $ff, $a7, $e7
	db $a7, $e7, $a7, $e7, $bd, $ff, $a0, $ff, $bf, $ff, $a0, $ff, $bf, $ff, $bb, $fa
	db $bb, $fa, $bb, $fa, $af, $ff, $a0, $ff, $bf, $ff, $80, $ff, $7f, $ff, $ff, $ff
	db $00, $ff, $00, $ff, $00, $ff, $ff, $ff, $00, $ff, $fe, $ff, $fe, $9f, $fe, $9f
	db $fe, $9f, $fe, $9f, $f2, $ff, $02, $ff, $fe, $ff, $02, $ff, $fe, $ff, $7a, $4b
	db $7a, $4b, $7a, $4b, $fe, $ff, $02, $ff, $fe, $ff, $02, $ff, $fe, $ff, $f2, $73
	db $f2, $73, $f2, $73, $de, $ff, $02, $ff, $fe, $ff, $00, $ff, $ff, $ff, $00, $ff
	db $7f, $80, $3f, $c0, $7f, $80, $00, $ff, $ff, $00, $fe, $01, $ff, $00, $00, $ff
	db $ff, $00, $ff, $00, $ff, $00, $00, $ff, $7f, $80, $7f, $80, $7f, $80, $ff, $ff
	db $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80
	db $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $ff
	db $fe, $01, $ff, $00, $fe, $01, $ff, $00, $fe, $01, $ff, $00, $fe, $01, $ff, $00
	db $fe, $01, $ff, $00, $fe, $01, $ff, $00, $fe, $01, $ff, $00, $fe, $01, $ff, $ff
	db $fe, $81, $ff, $80, $fe, $81, $ff, $80, $fe, $81, $ff, $80, $fe, $81, $ff, $80
	db $fe, $81, $ff, $80, $fe, $81, $ff, $80, $fe, $81, $ff, $80, $fe, $81, $ff, $ff
	db $80, $ff, $ff, $ff, $ff, $ff, $87, $ff, $87, $ff, $87, $ff, $fc, $ff, $ff, $ff
	db $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $ff, $ff, $ff
	db $ff, $80, $ff, $80, $ff, $ff, $ff, $80, $ff, $bf, $e0, $a0, $e0, $a0, $e0, $a0
	db $e0, $a0, $e0, $a0, $ff, $bf, $ff, $80, $ff, $7f, $e0, $3f, $ff, $1f, $ff, $3f
	db $ea, $55, $d7, $68, $e8, $57, $ff, $40, $ff, $3f, $ff, $00, $ff, $00, $ff, $ff
	db $ab, $56, $f7, $0a, $2b, $d6, $ff, $02, $ff, $fc, $ff, $00, $ff, $00, $ff, $ff
	db $ff, $81, $ff, $81, $ff, $81, $ff, $ff, $ff, $81, $ff, $bd, $ff, $81, $ff, $ff
	db $ff, $81, $ff, $bd, $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff, $ff, $ff, $00
	db $c1, $c0, $39, $38, $39, $28, $29, $38, $39, $38, $01, $fe, $ff, $00, $ff, $ff
	db $00, $00, $00, $00, $03, $03, $0d, $0e, $1a, $15, $34, $2b, $60, $5f, $50, $6f
	db $60, $5f, $31, $2e, $10, $1f, $0f, $0f, $00, $00, $00, $00, $00, $00, $ff, $ff
	db $00, $00, $00, $00, $80, $80, $70, $f0, $8c, $7c, $06, $fa, $0b, $f5, $01, $ff
	db $03, $fd, $51, $af, $a7, $5f, $fe, $ff, $00, $00, $00, $00, $00, $00, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $01, $01, $03, $02, $05, $06, $0b, $0c, $1f, $18
	db $1f, $1b, $2f, $33, $7f, $40, $6a, $55, $3f, $3f, $00, $00, $00, $00, $ff, $ff
	db $38, $38, $6f, $5f, $dd, $bb, $ba, $76, $74, $ec, $a8, $58, $d0, $30, $e8, $18
	db $f8, $88, $6c, $94, $d4, $2e, $be, $7f, $f8, $fe, $00, $00, $00, $00, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff
	db $00, $ff, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $f0, $0f, $c0, $3f, $80, $7f, $80, $7f, $00, $ff, $0f, $ff, $1f, $ff
	db $1f, $ff, $1f, $ff, $1f, $ff, $1f, $ff, $1f, $ff, $1f, $ff, $1f, $ff, $ff, $00
	db $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $ff, $f0, $00
	db $ef, $00, $e1, $00, $fc, $00, $c2, $00, $ff, $00, $ff, $00, $ff, $00, $85, $00
	db $6b, $00, $6b, $00, $d7, $00, $10, $00, $ff, $00, $ff, $00, $ff, $00, $c2, $00
	db $b5, $00, $b5, $00, $6b, $00, $0b, $00, $ff, $00, $ff, $00, $ff, $00, $18, $00
	db $56, $00, $56, $00, $ad, $00, $a1, $00, $ff, $00, $ff, $00, $ff, $00, $5b, $00
	db $9b, $00, $a7, $00, $67, $00, $6f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $e2, $1d, $ee, $11, $de, $21, $df, $20, $c4, $3b, $ff, $00, $ff, $00
	db $ff, $00, $23, $dc, $eb, $14, $23, $dc, $b7, $48, $27, $d8, $ff, $00, $ff, $7f
	db $e7, $3a, $ef, $32, $ef, $32, $ef, $32, $ef, $32, $2e, $f3, $ef, $f3, $00, $00
	db $00, $00, $00, $00, $00, $01, $03, $01, $06, $01, $07, $04, $00, $04, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $18, $00, $18, $08, $19, $07, $0e, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $e0, $50, $ff, $19, $81, $8e, $01, $03, $03, $02, $02, $06
	db $04, $03, $07, $05, $0f, $06, $3a, $5e, $0c, $3a, $0c, $10, $18, $0c, $18, $10
	db $20, $10, $60, $00, $c0, $80, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $10, $70, $20, $c0, $e0, $80, $c0, $00, $80, $00, $00, $00, $00
	db $00, $81, $01, $83, $03, $06, $04, $0f, $09, $08, $01, $01, $01, $02, $02, $01
	db $02, $03, $02, $01, $01, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $20, $20, $20, $20, $40, $00, $40, $00, $00, $40, $80
	db $c0, $80, $80, $c0, $80, $80, $84, $00, $08, $84, $08, $10, $10, $18, $30, $00
	db $20, $60, $40, $e0, $80, $c0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $23, $10, $77, $11
	db $17, $1f, $19, $1f, $1b, $30, $32, $13, $32, $22, $22, $24, $24, $42, $44, $64
	db $44, $c4, $85, $4e, $87, $06, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $18, $10, $00, $20, $30, $60, $00
	db $c0, $00, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $f0, $f0
	db $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0

SECTION "analyzed_04da15", ROMX[$5a15], BANK[$13]

Data_13_5a15:
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $7f, $5f, $4b, $6f, $11, $00, $00, $7c, $67, $7b, $6f, $10, $42, $00, $00
	db $ff, $7f, $b6, $46, $32, $32, $00, $00, $7c, $63, $f4, $29, $0e, $15, $00, $00
	db $4f, $72, $7c, $63, $53, $42, $00, $00, $ac, $5e, $be, $14, $d2, $25, $00, $00
	db $ff, $7f, $5f, $4b, $80, $74, $00, $00, $ff, $7f, $94, $52, $4a, $29, $00, $00
	db $ff, $7f, $5f, $4b, $6f, $11, $00, $00, $ff, $7f, $5f, $4b, $80, $74, $00, $00
	db $ff, $7f, $ee, $2f, $26, $1a, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $18, $14, $ab, $5c, $cb, $5a, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $a8, $a8, $a8, $aa
	db $a8, $a8, $a8, $a8, $a8, $a8, $a8, $a8, $ac, $b0, $ac, $b0, $ff, $ff, $ff, $ff
	db $fc, $fc, $a9, $aa, $a9, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $ad, $b1, $ad, $b1
	db $ff, $ff, $ff, $ff, $fc, $fc, $fc, $ab, $fc, $fc, $b6, $b8, $be, $be, $c2, $ba
	db $ae, $b2, $ae, $b2, $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5, $b4, $b5, $b7, $b9
	db $bf, $bf, $c3, $bb, $af, $b3, $af, $b3, $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5
	db $b4, $b5, $b7, $b9, $c0, $c1, $c4, $bb, $b4, $b5, $b4, $b5, $ff, $ff, $ff, $ff
	db $b4, $b5, $b4, $b5, $b4, $b5, $bc, $bd, $bd, $bd, $bd, $bc, $b4, $b5, $b4, $b5
	db $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5
	db $b4, $b5, $b4, $b5, $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5
	db $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5
	db $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $ff, $ff, $ff, $ff
	db $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5
	db $ff, $ff, $ff, $ff, $ba, $cd, $c5, $c7, $cd, $ba, $b4, $b5, $b4, $b5, $ba, $cd
	db $c9, $cb, $cd, $ba, $ff, $ff, $ff, $ff, $bb, $fc, $c6, $c8, $fc, $bb, $b4, $b5
	db $b4, $b5, $bb, $fc, $ca, $cc, $fc, $bb, $ff, $ff, $ff, $ff, $bb, $fc, $fc, $fc
	db $fc, $bb, $b4, $b5, $b4, $b5, $bb, $fc, $fc, $fc, $fc, $bb, $ff, $ff, $ff, $ff
	db $bc, $bd, $bd, $bd, $bd, $bc, $b4, $b5, $b4, $b5, $bc, $bd, $bd, $bd, $bd, $bc
	db $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5
	db $b4, $b5, $b4, $b5, $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5
	db $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5
	db $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $ff, $ff, $ff, $ff
	db $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5
	db $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5
	db $b4, $b5, $b4, $b5, $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5
	db $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $b4, $b5, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $b4, $b5, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0d, $0d, $0d, $0d, $08, $08, $08, $08
	db $0b, $0b, $0b, $0b, $2b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0d, $0d, $0d, $0d
	db $08, $08, $08, $08, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0c, $2c, $0c, $2b
	db $0d, $0d, $0d, $0d, $08, $08, $08, $08, $0a, $0a, $0a, $0a, $0a, $0a, $0b, $0b
	db $0c, $2c, $0c, $2b, $0d, $0d, $0d, $0d, $08, $08, $08, $08, $0a, $0a, $0a, $0a
	db $0a, $0a, $0b, $0b, $0c, $0c, $0c, $2b, $0a, $0a, $0a, $0a, $08, $08, $08, $08
	db $0a, $0a, $0a, $0a, $0a, $0a, $0b, $0b, $0b, $0b, $0b, $2b, $0a, $0a, $0a, $0a
	db $08, $08, $08, $08, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $08, $08, $08, $08, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $08, $08, $08, $08, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $08, $08, $08, $08
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $08, $08, $08, $08, $0b, $09, $09, $09, $09, $2b, $0a, $0a, $0a, $0a, $0b, $09
	db $09, $09, $09, $2b, $08, $08, $08, $08, $0b, $09, $09, $09, $09, $2b, $0a, $0a
	db $0a, $0a, $0b, $09, $09, $09, $09, $2b, $08, $08, $08, $08, $0b, $09, $09, $09
	db $09, $2b, $0a, $0a, $0a, $0a, $0b, $09, $09, $09, $09, $2b, $08, $08, $08, $08
	db $0b, $0b, $0b, $0b, $0b, $2b, $0a, $0a, $0a, $0a, $0b, $0b, $0b, $0b, $0b, $2b
	db $08, $08, $08, $08, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $08, $08, $08, $08, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $08, $08, $08, $08, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $08, $08, $08, $08
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $08, $08, $08, $08, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $08, $08, $08, $08, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $0a, $0a, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $0a, $0a, $08, $08, $08, $08, $08, $08
	db $08, $08, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $08, $08, $12, $14, $f9, $5f, $91, $5e, $ce, $ce, $ce, $ce
	db $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce
	db $d2, $d3, $d4, $d5, $d6, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd
	db $d7, $d8, $fd, $fd, $fd, $cf, $d1, $d1, $d1, $d1, $d1, $d1, $d1, $d1, $d1, $d1
	db $d1, $d1, $d1, $d1, $d1, $d1, $cf, $fd, $fd, $d0, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $d0, $fd, $fd, $d0, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $d0, $fd
	db $fd, $d0, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $d0, $fd, $fd, $d0, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $d0, $fd, $fd, $d0, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $d0, $fd, $fd, $d0, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $d0, $fd
	db $fd, $d0, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $d0, $fd, $fd, $d0, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $d0, $fd, $fd, $d0, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $d0, $fd, $fd, $d0, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $d0, $fd
	db $fd, $d0, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $d0, $fd, $fd, $d0, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $d0, $fd, $fd, $cf, $d1, $d1, $d1, $d1, $d1, $d1
	db $d1, $d1, $d1, $d1, $d1, $d1, $d1, $d1, $d1, $d1, $cf, $fd, $fd, $fd, $fd, $fd
	db $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd
	db $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce
	db $ce, $d9, $ce, $ce, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $2c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $2c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $2c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c
	db $0c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c
	db $4c, $4c, $6c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c
	db $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $0c, $4c, $4c, $06, $14, $df, $61
	db $67, $61, $a0, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2
	db $a2, $a2, $a2, $a2, $a2, $a0, $a1, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $a1, $a1, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $a1, $a1, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $a1, $a1, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $a1, $a0, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2
	db $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a0, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $28, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $28, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $28, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $28, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $28, $48, $48
	db $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48
	db $48, $68, $04, $04, $6d, $62, $5d, $62, $80, $88, $90, $98, $81, $89, $91, $99
	db $82, $8a, $92, $9a, $83, $8b, $93, $9b, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $04, $04, $93, $62, $83, $62, $84, $8c
	db $94, $9c, $85, $8d, $95, $9d, $86, $8e, $96, $9e, $87, $8f, $97, $9f, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $04, $04
	db $b9, $62, $a9, $62, $ff, $ff, $b4, $b5, $ff, $ff, $b4, $b5, $ff, $ff, $b4, $b5
	db $ff, $ff, $ba, $cd, $0f, $0f, $0a, $0a, $0f, $0f, $0a, $0a, $0f, $0f, $0a, $0a
	db $0f, $0f, $0b, $09, $03, $06, $e1, $62, $cf, $62, $da, $dd, $e0, $e3, $e6, $e9
	db $db, $de, $e1, $e4, $e7, $ea, $dc, $df, $e2, $e5, $e8, $eb, $0f, $0f, $0f, $0f
	db $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $02, $00
	db $00, $00, $08, $00, $08, $08, $08

Data_13_62fc:
	db $02, $00, $00, $02, $08, $00, $08, $0a, $08, $02, $00, $00, $04, $08, $00, $08
	db $0c, $08

Data_13_630e:
	db $02, $00, $00, $06, $08, $00, $08, $0e, $08

Data_13_6317:
	db $02, $00, $00, $10, $08, $00, $08, $18, $08, $02, $00, $00, $18, $28, $00, $08
	db $10, $28

Data_13_6329:
	db $02, $00, $00, $12, $08, $00, $08, $1a, $08

Data_13_6332:
	db $02, $00, $00, $14, $08, $00, $08, $1c, $08, $02, $00, $00, $1a, $28, $00, $08
	db $12, $28, $02, $00, $00, $1c, $28, $00, $08, $14, $28, $02, $00, $00, $16, $09
	db $00, $08, $1e, $09, $02, $00, $00, $20, $09, $00, $08, $28, $09, $02, $00, $00
	db $22, $09, $00, $08, $2a, $09, $02, $00, $00, $24, $09, $00, $08, $2c, $09, $02
	db $00, $00, $26, $09, $00, $08, $2e, $09

Data_13_637a:
	db $02, $00, $00, $2c, $29, $00, $08, $24, $29, $02, $00, $00, $30, $0a, $00, $08
	db $38, $0a
