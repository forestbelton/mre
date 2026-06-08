; Sound id $03 (SFX) -- ?
; Bank $3f, ROM $4d5f-$4d78. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $03", ROMX

; ===== sound id $03 =====
Snd_3f_4d5f:
	s_chan $00, Snd_3f_4d78
	s_chan $00, Snd_3f_4d78
	s_chan $00, Snd_3f_4d78
	s_chan $f0, Snd_3f_4d6b
Snd_3f_4d6b:
	s_pitchenv 0
	s_oct 1	; block 0
	s_instr 13
	s_note SC_D    	; D
	s_note_l SC_F, 1	; F dur=1
	s_instr 11
	s_note_l SC_D, 8	; D dur=8
	s_end
Snd_3f_4d78:
	s_end
