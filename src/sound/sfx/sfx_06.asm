; Sound id $06 (SFX) -- ?
; Bank $3f, ROM $4dd0-$4e14. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $06", ROMX

; ===== sound id $06 =====
Snd_SFX_06:
	s_chan $f0, Snd_3f_4ddc
	s_chan $f0, Snd_3f_4df8
	s_chan $00, Snd_3f_4e14
	s_chan $00, Snd_3f_4e14
Snd_3f_4ddc:
	s_pitchenv 0
	s_set10 0
	s_dutyenv 4
	s_deflen 7
	s_oct 6	; block 5
	s_instr 1
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_instr 3
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_instr 5
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_end
Snd_3f_4df8:
	s_pitchenv 0
	s_set10 0
	s_dutyenv 5
	s_deflen 7
	s_oct 6	; block 5
	s_instr 1
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_instr 3
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_instr 5
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_end
Snd_3f_4e14:
	s_end
