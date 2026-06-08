; Sound id $1f (SFX) -- ?
; Bank $3f, ROM $5630-$5651. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $1f", ROMX

; ===== sound id $1f =====
Snd_3f_5630:
	s_chan $00, Snd_3f_5651
	s_chan $00, Snd_3f_5651
	s_chan $00, Snd_3f_5651
	s_chan $f0, Snd_3f_563c
Snd_3f_563c:
	s_pitchenv 0
	s_oct 1	; block 0
	s_deflen 1
	s_instr 10
	s_note SC_G    	; G
	s_note SC_DS   	; D#
	s_note SC_G    	; G
	s_note SC_DS   	; D#
	s_note SC_G    	; G
	s_note SC_DS   	; D#
	s_note SC_G    	; G
	s_note SC_DS   	; D#
	s_deflen 15
	s_instr 13
	s_note SC_DS   	; D#
	s_end
Snd_3f_5651:
	s_end
