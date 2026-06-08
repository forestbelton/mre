; Sound id $0b (SFX) -- ?
; Bank $3f, ROM $4f90-$4fae. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $0b", ROMX

; ===== sound id $0b =====
Snd_3f_4f90:
	s_chan $00, Snd_3f_4fae
	s_chan $f0, Snd_3f_4f9c
	s_chan $00, Snd_3f_4fae
	s_chan $00, Snd_3f_4fae
Snd_3f_4f9c:
	s_pitchenv 0
	s_set10 0
	s_dutyenv 5
	s_deflen 2
	s_oct 7	; block 6
	s_instr 3
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_REST 	; rest
	s_goto Snd_3f_4f9c
Snd_3f_4fad:
	ds 1, $ff
Snd_3f_4fae:
	s_end
