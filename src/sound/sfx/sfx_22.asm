; Sound id $22 (SFX) -- ?
; Bank $3f, ROM $56bd-$56ed. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $22", ROMX

; ===== sound id $22 =====
Snd_SFX_22:
	s_chan $00, Snd_3f_56ed
	s_chan $00, Snd_3f_56ed
	s_chan $00, Snd_3f_56ed
	s_chan $f0, Snd_3f_56c9
Snd_3f_56c9:
	s_deflen 4
	s_pitchenv 0
	s_oct 1	; block 0
	s_instr 0
	s_note SC_C    	; C
	s_note SC_CS   	; C#
	s_note SC_D    	; D
	s_note SC_CS   	; C#
	s_note SC_F    	; F
	s_note SC_FS   	; F#
	s_note SC_G    	; G
	s_note SC_GS   	; G#
	s_deflen 6
	s_pitchenv 0
	s_instr 0
	s_note SC_G    	; G
	s_deflen 9
	s_pitchenv 0
	s_instr 0
	s_note SC_G    	; G
	s_instr 3
	s_note SC_G    	; G
	s_instr 4
	s_note SC_G    	; G
	s_end
Snd_3f_56ed:
	s_end
