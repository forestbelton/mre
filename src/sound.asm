; =============================================================================
; Sound engine
; =============================================================================
; Monster Rancher Explorer's audio system: a small command-driven driver plus
; the song/SFX data it interprets. Carved verbatim from analyzed.asm (byte-exact);
; classification and labelling are refined in place. See docs/sound_engine.md.
;
; Layout of this file:
;   * HOME API ($0a30-$0b4d)  -- the public entry points the rest of the game
;     calls (PlaySound / PlaySoundTracked / ResetSoundEngine / UpdateSoundEngine)
;     and the SoundCommandTable that maps a sound id -> (driver bank, local idx).
;   * Shared driver           -- sound_driver.asm ($4000-$4aff) INCLUDEd once per
;     bank; the code is byte-identical in $3e and $3f.
;   * Bank $3e song/SFX data  -- $4b00+, for sound ids $2f-$3a.
;   * Bank $3f song/SFX data  -- $4b00+, for sound ids $00-$2e (primary).
;
; The HOME API looks a command id up in SoundCommandTable, banks in the owning
; driver bank ($3e or $3f), and calls a fixed trampoline at the bank base ($4000).
; Each driver bank resolves the id to a command pointer (Sound_ResolveCmdPtr, via
; the $4b00 table) and drives the APU through channel state in $de80+.


; ----- HOME: public sound API -------------------------------------------------
SECTION "analyzed_000a30", ROM0[$0a30]

ResetSoundEngine:
	ld a, [$7fff]
	push af
	ld a, $3f
	ld [$2fff], a
	call Func_3f_4000
	pop af
	ld [$2fff], a
	xor a
	ld [wCurrentSound], a
	ret

UpdateSoundEngine:
	ld a, [$7fff]
	push af
	ld a, $3f
	ld [$2fff], a
	call Func_3f_4003
	pop af
	ld [$2fff], a
	ret

PlaySoundIfChanged:
	push hl
	ld hl, wCurrentSound
	cp [hl]
	jr z, .done
	ld [hl], a
	call PlaySoundTracked
.done:
	pop hl
	ret

PlaySoundTracked:
	ld [wCurrentSound], a
	push bc
	push de
	push hl
	ld c, a
	ld b, $00
	ld a, [$7fff]
	push af
	ld hl, $0ad8
	add hl, bc
	add hl, bc
	ld a, [hl+]
	ld [$2fff], a
	ld a, [hl]
	call $4006
	pop af
	ld [$2fff], a
	pop hl
	pop de
	pop bc
	ret

PlaySound:
	push bc
	push de
	push hl
	ld c, a
	ld b, $00
	ld a, [$7fff]
	push af
	ld hl, $0ad8
	add hl, bc
	add hl, bc
	ld a, [hl+]
	ld [$2fff], a
	ld a, [hl]
	call $4009
	pop af
	ld [$2fff], a
	pop hl
	pop de
	pop bc
	ret

; Two more public entry points, both banking into $3f. Neither is reached by any
; currently-disassembled caller, but they are the natural fade/mute API.

; SetSoundFade -- hand (B, C, A) to the driver's fade block ($ded3/$ded4/$ded5).
; $3f's per-frame Func_3f_4070 ramps rAUDVOL by $11 toward $77 using that block
; ($ded3 = direction: 1 = fade in, else fade out). Calls $3f:$400c -> $46de.
SetSoundFade:
	push af
	push bc
	push de
	push hl
	ld a, [$7fff]
	push af
	ld a, $3f
	ld [$2fff], a
	call $400c
	pop af
	ld [$2fff], a
	pop hl
	pop de
	pop bc
	pop af
	ret

; SetSoundMute -- A != 0 saves rAUDTERM and zeroes rAUDTERM/rAUDVOL (silence);
; A == 0 restores them. Calls $3f:$400f -> $46e7.
SetSoundMute:
	push af
	push bc
	push de
	push hl
	ld b, a
	ld a, [$7fff]
	push af
	ld a, $3f
	ld [$2fff], a
	ld a, b
	call $400f
	pop af
	ld [$2fff], a
	pop hl
	pop de
	pop bc
	pop af
	ret

; \1 Bank
; \2 Local command index
MACRO SOUND_COMMAND
	db \1, \2
ENDM

; Sound id (the A passed to PlaySound/PlaySoundTracked) -> (driver bank, that
; bank's local command index). 2 bytes/entry. ids $00-$2e are in bank $3f
; (index == id); ids $2f-$3a are in bank $3e (index == id-$2f). 59 ids total.
;
; By role (from the call sites; see docs/sound_engine.md for the per-id table):
;   ids $00-$27 = SFX  (started via PlaySound, transient path; $00 = silence/stop)
;   ids $28-$3a = BGM  (started via PlaySoundTracked; $28 = main/title theme)
SoundCommandTable:
	; ids $00-$2e -> bank $3f, index = id
	FOR I, $2f
		SOUND_COMMAND $3f, I
	ENDR
	; ids $2f-$3a -> bank $3e, index = id-$2f
	FOR I, $2f, $3b
		SOUND_COMMAND $3e, (I - $2f)
	ENDR

; ----- Shared driver ($4000-$4aff), instantiated into both banks --------------
; sound_driver.asm is byte-identical in $3e and $3f; include it once per bank
; with SB/SBU set to the bank suffix. See sound_driver.asm for the details.
def SB equs "3f"
INCLUDE "sound_driver.asm"
redef SB equs "3e"
INCLUDE "sound_driver.asm"

; Song/SFX bytecode macros (used by the generated data files below).
INCLUDE "snd_song.inc"

; ----- Bank $3e: song/SFX data ($4b00+) for sound ids $2f-$3a -----------------
; Readable, byte-exact macro source: per-bank pointer table + one file per song
; under src/sound/{sfx,bgm}/. (Dis)assembled by tools/songdisasm.py.
INCLUDE "sound/bank_3e.asm"

; ----- Bank $3f: song/SFX data ($4b00+) for sound ids $00-$2e (primary) -------
INCLUDE "sound/bank_3f.asm"
