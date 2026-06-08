; Sound id $24 (SFX) -- ?
; Bank $3f, ROM $5724-$575f. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $24", ROMX

; ===== sound id $24 =====
Snd_SFX_24:
	s_chan $00, Snd_3f_575f
	s_chan $f0, Snd_3f_5730
	s_chan $00, Snd_3f_575f
	s_chan $f0, Snd_3f_574d
Snd_3f_5730:
	s_pitchenv 0
	s_deflen 1
	s_set10 0
	s_dutyenv 2
	s_oct 2	; block 1
	s_instr 0
	s_note SC_C    	; C
	s_note SC_B    	; B
	s_note SC_G    	; G
	s_note SC_REST 	; rest
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_note SC_REST 	; rest
	s_deflen 2
	s_instr 3
	s_note SC_F    	; F
	s_note SC_G    	; G
	s_instr 5
	s_note SC_F    	; F
	s_note SC_G    	; G
	s_end
Snd_3f_574d:
	s_pitchenv 0
	s_oct 1	; block 0
	s_deflen 1
	s_instr 10
	s_note SC_F    	; F
	s_note SC_REST 	; rest
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_deflen 2
	s_instr 13
	s_note SC_D    	; D
	s_note SC_D    	; D
	s_end
Snd_3f_575f:
	s_end
