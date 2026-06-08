; Sound id $01 (SFX) -- ?
; Bank $3f, ROM $4d0f-$4d38. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $01", ROMX

; ===== sound id $01 =====
Snd_SFX_01:
	s_chan $00, Snd_3f_4d38
	s_chan $f0, Snd_3f_4d1b
	s_chan $00, Snd_3f_4d38
	s_chan $00, Snd_3f_4d38
Snd_3f_4d1b:
	s_set10 0
	s_dutyenv 2
	s_pitchenv 0
	s_deflen 1
	s_instr 2
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
	s_note SC_D    	; D
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_oct 8	; block 7
	s_note SC_C    	; C
	s_end
Snd_3f_4d38:
	s_end
