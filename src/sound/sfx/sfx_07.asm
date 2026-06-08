; Sound id $07 (SFX) -- ?
; Bank $3f, ROM $4e15-$4e51. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $07", ROMX

; ===== sound id $07 =====
Snd_3f_4e15:
	s_chan $f0, Snd_3f_4e21
	s_chan $f0, Snd_3f_4e39
	s_chan $00, Snd_3f_4e51
	s_chan $00, Snd_3f_4e51
Snd_3f_4e21:
	s_pitchenv 0
	s_set10 0
	s_dutyenv 1
	s_instr 1
	s_deflen 6
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_oct 4	; block 3
	s_note SC_B    	; B
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_note SC_DS   	; D#
	s_deflen 12
	s_note SC_GS   	; G#
	s_note SC_F    	; F
	s_note SC_GS   	; G#
	s_note SC_F    	; F
	s_end
Snd_3f_4e39:
	s_pitchenv 0
	s_set10 0
	s_dutyenv 1
	s_instr 1
	s_deflen 6
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_DS   	; D#
	s_deflen 12
	s_note SC_GS   	; G#
	s_note SC_F    	; F
	s_note SC_GS   	; G#
	s_note SC_F    	; F
	s_end
Snd_3f_4e51:
	s_end
