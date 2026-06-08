; Sound id $05 (SFX) -- item use
; Bank $3f, ROM $4d95-$4dcf. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $05", ROMX

; ===== sound id $05 =====
Snd_SFX_ItemUse:
	s_chan $00, Snd_3f_4dcf
	s_chan $f0, Snd_3f_4da1
	s_chan $00, Snd_3f_4dcf
	s_chan $00, Snd_3f_4dcf
Snd_3f_4da1:
	s_set10 0
	s_dutyenv 2
	s_pitchenv 0
	s_instr 1
	s_deflen 1
	s_oct 7	; block 6
	s_note SC_C    	; C
	s_oct 6	; block 5
	s_note SC_B    	; B
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_oct 5	; block 4
	s_note SC_B    	; B
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_note SC_D    	; D
	s_oct 5	; block 4
	s_note SC_C    	; C
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
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_oct 7	; block 6
	s_note SC_C    	; C
	s_end
Snd_3f_4dcf:
	s_end
