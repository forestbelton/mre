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
