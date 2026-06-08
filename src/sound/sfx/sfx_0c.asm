; Sound id $0c (SFX) -- ?
; Bank $3f, ROM $4faf-$5030. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $0c", ROMX

; ===== sound id $0c =====
Snd_3f_4faf:
	s_chan $f0, Snd_3f_4fbb
	s_chan $f0, Snd_3f_4fe2
	s_chan $f0, Snd_3f_5009
	s_chan $00, Snd_3f_5030
Snd_3f_4fbb:
	s_pitchenv 1
	s_set10 0
	s_dutyenv 3
	s_deflen 3
	s_instr 1
	s_oct 5	; block 4
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_oct 6	; block 5
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_note_l SC_DS, 12	; D# dur=12
	s_note_l SC_C, 6	; C dur=6
	s_oct 5	; block 4
	s_deflen 12
	s_note SC_B    	; B
	s_oct 6	; block 5
	s_note SC_C    	; C
	s_deflen 3
	s_oct 5	; block 4
	s_note SC_G    	; G
	s_note SC_B    	; B
	s_oct 6	; block 5
	s_note SC_D    	; D
	s_note SC_F    	; F
	s_deflen 12
	s_note SC_GS   	; G#
	s_note SC_G    	; G
	s_end
Snd_3f_4fe2:
	s_pitchenv 0
	s_set10 0
	s_dutyenv 3
	s_deflen 3
	s_instr 1
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_note_l SC_DS, 12	; D# dur=12
	s_note_l SC_C, 6	; C dur=6
	s_oct 4	; block 3
	s_deflen 12
	s_note SC_B    	; B
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_deflen 3
	s_oct 4	; block 3
	s_note SC_G    	; G
	s_note SC_B    	; B
	s_oct 5	; block 4
	s_note SC_D    	; D
	s_note SC_F    	; F
	s_deflen 12
	s_note SC_GS   	; G#
	s_note SC_G    	; G
	s_end
Snd_3f_5009:
	s_pitchenv 0
	s_set10 0
	s_wave 10
	s_instr 20
	s_deflen 3
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_note_l SC_DS, 12	; D# dur=12
	s_note_l SC_C, 6	; C dur=6
	s_oct 3	; block 2
	s_deflen 12
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_deflen 3
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_D    	; D
	s_note SC_F    	; F
	s_deflen 12
	s_note SC_GS   	; G#
	s_note SC_G    	; G
	s_end
Snd_3f_5030:
	s_end
