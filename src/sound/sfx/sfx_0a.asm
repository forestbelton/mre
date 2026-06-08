; Sound id $0a (SFX) -- ?
; Bank $3f, ROM $4f05-$4f8f. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $0a", ROMX

; ===== sound id $0a =====
Snd_3f_4f05:
	s_chan $f0, Snd_3f_4f11
	s_chan $f0, Snd_3f_4f42
	s_chan $f0, Snd_3f_4f68
	s_chan $00, Snd_3f_4f8f
Snd_3f_4f11:
	s_pitchenv 0
	s_set10 0
	s_dutyenv 1
	s_instr 1
	s_deflen 2
	s_oct 8	; block 7
	s_note SC_G    	; G
	s_note SC_FS   	; F#
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_note SC_DS   	; D#
	s_note SC_D    	; D
	s_note SC_CS   	; C#
	s_note SC_C    	; C
	s_oct 7	; block 6
	s_note SC_B    	; B
	s_note SC_AS   	; A#
	s_note SC_A    	; A
	s_note SC_GS   	; G#
	s_note SC_G    	; G
	s_note SC_FS   	; F#
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_note SC_DS   	; D#
	s_note SC_D    	; D
	s_note SC_CS   	; C#
	s_note SC_C    	; C
	s_oct 6	; block 5
	s_note SC_B    	; B
	s_note SC_AS   	; A#
	s_note SC_A    	; A
	s_note SC_GS   	; G#
	s_instr 4
	s_deflen 15
	s_oct 6	; block 5
	s_note SC_G    	; G
	s_note SC_E    	; E
	s_note SC_C    	; C
	s_oct 5	; block 4
	s_note_l SC_A, 40	; A dur=40
	s_end
Snd_3f_4f42:
	s_pitchenv 0
	s_set10 0
	s_dutyenv 2
	s_instr 3
	s_deflen 6
	s_oct 8	; block 7
	s_note SC_G    	; G
	s_note SC_E    	; E
	s_note SC_C    	; C
	s_oct 7	; block 6
	s_note SC_A    	; A
	s_instr 3
	s_deflen 6
	s_oct 7	; block 6
	s_note SC_G    	; G
	s_note SC_E    	; E
	s_note SC_C    	; C
	s_oct 6	; block 5
	s_note SC_A    	; A
	s_deflen 15
	s_instr 2
	s_oct 7	; block 6
	s_note SC_G    	; G
	s_note SC_E    	; E
	s_note SC_C    	; C
	s_oct 6	; block 5
	s_note_l SC_A, 40	; A dur=40
	s_end
Snd_3f_4f68:
	s_pitchenv 0
	s_set10 0
	s_wave 8
	s_instr 20
	s_note_l SC_REST, 48	; rest dur=48
	s_deflen 2
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_B    	; B
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
Snd_3f_4f8f:
	s_end
