; Sound id $17 (SFX) -- ?
; Bank $3f, ROM $539e-$5432. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $17", ROMX

; ===== sound id $17 =====
Snd_SFX_17:
	s_chan $00, Snd_3f_5432
	s_chan $f0, Snd_3f_53aa
	s_chan $00, Snd_3f_5432
	s_chan $f0, Snd_3f_53f7
Snd_3f_53aa:
	s_set10 0
	s_dutyenv 1
	s_deflen 2
	s_pitchenv 0
	s_instr 5
	s_oct 3	; block 2
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_G    	; G
	s_instr 3
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_instr 2
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_instr 1
	s_note SC_B    	; B
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_instr 0
	s_note SC_D    	; D
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_oct 6	; block 5
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_G    	; G
	s_instr 1
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_instr 2
	s_oct 7	; block 6
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_instr 3
	s_note SC_B    	; B
	s_oct 8	; block 7
	s_note SC_C    	; C
	s_instr 4
	s_note SC_D    	; D
	s_note SC_E    	; E
	s_instr 5
	s_note SC_F    	; F
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_end
Snd_3f_53f7:
	s_deflen 2
	s_pitchenv 0
	s_oct 1	; block 0
	s_instr 0
	s_note SC_C    	; C
	s_note SC_C    	; C
	s_keyon
	s_instr 4
	s_note SC_F    	; F
	s_keyon
	s_note SC_F    	; F
	s_deflen 4
	s_instr 4
	s_note SC_E    	; E
	s_keyon
	s_note SC_F    	; F
	s_instr 3
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_keyon
	s_note SC_F    	; F
	s_instr 2
	s_note SC_F    	; F
	s_instr 1
	s_note SC_E    	; E
	s_keyon
	s_note SC_F    	; F
	s_instr 0
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_keyon
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_instr 2
	s_note SC_F    	; F
	s_keyon
	s_note SC_F    	; F
	s_instr 4
	s_note SC_F    	; F
	s_keyon
	s_instr 5
	s_note SC_C    	; C
	s_note SC_C    	; C
	s_end
Snd_3f_5432:
	s_end
