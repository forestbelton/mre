; Sound id $12 (SFX) -- ?
; Bank $3f, ROM $5198-$524b. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $12", ROMX

; ===== sound id $12 =====
Snd_3f_5198:
	s_chan $00, Snd_3f_524b
	s_chan $f0, Snd_3f_51a4
	s_chan $00, Snd_3f_524b
	s_chan $f0, Snd_3f_5210
Snd_3f_51a4:
	s_set10 0
	s_dutyenv 3
	s_deflen 3
	s_pitchenv 0
	s_oct 1	; block 0
	s_instr 0
	s_note SC_G    	; G
	s_oct 2	; block 1
	s_note SC_G    	; G
	s_oct 1	; block 0
	s_note SC_A    	; A
	s_oct 2	; block 1
	s_note SC_C    	; C
	s_deflen 2
	s_note SC_G    	; G
	s_note SC_G    	; G
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_oct 2	; block 1
	s_note SC_A    	; A
	s_note SC_A    	; A
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_oct 2	; block 1
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_oct 1	; block 0
	s_note SC_G    	; G
	s_oct 2	; block 1
	s_note SC_G    	; G
	s_oct 1	; block 0
	s_note SC_A    	; A
	s_oct 2	; block 1
	s_note SC_C    	; C
	s_oct 2	; block 1
	s_note SC_G    	; G
	s_note SC_G    	; G
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_oct 2	; block 1
	s_note SC_A    	; A
	s_note SC_A    	; A
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_oct 2	; block 1
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_instr 0
	s_note SC_G    	; G
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_oct 2	; block 1
	s_note SC_A    	; A
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_instr 3
	s_oct 2	; block 1
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_instr 0
	s_note SC_F    	; F
	s_oct 3	; block 2
	s_note SC_F    	; F
	s_oct 2	; block 1
	s_note SC_G    	; G
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_instr 4
	s_oct 2	; block 1
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_oct 3	; block 2
	s_instr 3
	s_note SC_F    	; F
	s_oct 2	; block 1
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_F    	; F
	s_oct 3	; block 2
	s_instr 4
	s_note SC_F    	; F
	s_oct 2	; block 1
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_G    	; G
	s_note SC_E    	; E
	s_instr 5
	s_note SC_D    	; D
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_D    	; D
	s_end
Snd_3f_5210:
	s_deflen 2
	s_pitchenv 0
	s_oct 1	; block 0
	s_instr 3
	s_note SC_G    	; G
	s_note SC_G    	; G
	s_note SC_G    	; G
	s_note SC_GS   	; G#
	s_note SC_GS   	; G#
	s_deflen 6
	s_instr 0
	s_note SC_GS   	; G#
	s_note SC_GS   	; G#
	s_note SC_G    	; G
	s_deflen 1
	s_instr 3
	s_note SC_G    	; G
	s_note SC_G    	; G
	s_note SC_GS   	; G#
	s_note SC_GS   	; G#
	s_deflen 4
	s_instr 0
	s_note SC_GS   	; G#
	s_note SC_GS   	; G#
	s_note SC_G    	; G
	s_deflen 20
	s_note SC_G    	; G
	s_note SC_G    	; G
	s_deflen 2
	s_instr 2
	s_note SC_G    	; G
	s_note SC_G    	; G
	s_note SC_G    	; G
	s_note SC_G    	; G
	s_instr 3
	s_note SC_G    	; G
	s_note SC_G    	; G
	s_note SC_GS   	; G#
	s_note SC_GS   	; G#
	s_instr 5
	s_note SC_GS   	; G#
	s_note SC_GS   	; G#
	s_note SC_A    	; A
	s_note SC_A    	; A
	s_end
Snd_3f_524b:
	s_end
