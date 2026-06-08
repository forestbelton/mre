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

INCLUDE "text.inc"

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
