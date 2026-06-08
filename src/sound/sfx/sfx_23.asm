; Sound id $23 (SFX) -- ?
; Bank $3f, ROM $56ee-$5723. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $23", ROMX

; ===== sound id $23 =====
Snd_SFX_23:
	s_chan $00, Snd_3f_5723
	s_chan $00, Snd_3f_5723
	s_chan $f0, Snd_3f_56fa
	s_chan $f0, Snd_3f_5712
Snd_3f_56fa:
	s_pitchenv 0
	s_set10 0
	s_wave 2
	s_instr 20
	s_deflen 1
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_note SC_GS   	; G#
	s_note SC_REST 	; rest
	s_note SC_E    	; E
	s_note SC_CS   	; C#
	s_instr 19
	s_note SC_B    	; B
	s_note SC_GS   	; G#
	s_note SC_REST 	; rest
	s_note SC_E    	; E
	s_note SC_CS   	; C#
	s_end
Snd_3f_5712:
	s_deflen 1
	s_pitchenv 0
	s_oct 1	; block 0
	s_instr 10
	s_note SC_F    	; F
	s_note SC_REST 	; rest
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_instr 13
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_note SC_D    	; D
	s_end
Snd_3f_5723:
	s_end
