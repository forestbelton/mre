; Sound id $11 (SFX) -- ?
; Bank $3f, ROM $50b1-$5197. INCLUDEd by sound/bank0.asm into its $4b00 section.

; ===== sound id $11 =====
Snd_3f_50b1:
	s_chan $f0, Snd_3f_50bd
	s_chan $f0, Snd_3f_5104
	s_chan $00, Snd_3f_5197
	s_chan $f0, Snd_3f_514f
Snd_3f_50bd:
	s_pitchenv 0
	s_oct 1	; block 0
	s_deflen 1
	s_set10 0
	s_dutyenv 3
	s_instr 0
	s_note SC_DS   	; D#
	s_keyon
	s_note SC_D    	; D
	s_keyon
	s_note SC_D    	; D
	s_keyon
	s_note SC_CS   	; C#
	s_keyon
	s_deflen 5
	s_note SC_D    	; D
	s_keyon
	s_note SC_D    	; D
	s_keyon
	s_note SC_DS   	; D#
	s_keyon
	s_note SC_DS   	; D#
	s_keyon
	s_note SC_E    	; E
	s_keyon
	s_note SC_E    	; E
	s_deflen 4
	s_keyon
	s_note SC_F    	; F
	s_keyon
	s_note SC_F    	; F
	s_keyon
	s_note SC_F    	; F
	s_keyon
	s_note SC_G    	; G
	s_keyon
	s_note SC_G    	; G
	s_keyon
	s_note SC_G    	; G
	s_deflen 2
	s_keyon
	s_note SC_GS   	; G#
	s_keyon
	s_note SC_GS   	; G#
	s_keyon
	s_note SC_GS   	; G#
	s_keyon
	s_note SC_G    	; G
	s_deflen 3
	s_instr 3
	s_keyon
	s_note SC_GS   	; G#
	s_keyon
	s_note SC_G    	; G
	s_instr 5
	s_keyon
	s_note SC_GS   	; G#
	s_keyon
	s_note SC_G    	; G
	s_end
Snd_3f_5104:
	s_pitchenv 0
	s_oct 1	; block 0
	s_deflen 1
	s_set10 0
	s_dutyenv 4
	s_instr 0
	s_note SC_DS   	; D#
	s_keyon
	s_note SC_D    	; D
	s_keyon
	s_note SC_D    	; D
	s_keyon
	s_note SC_CS   	; C#
	s_keyon
	s_deflen 5
	s_note SC_D    	; D
	s_keyon
	s_note SC_D    	; D
	s_keyon
	s_note SC_DS   	; D#
	s_keyon
	s_note SC_DS   	; D#
	s_keyon
	s_note SC_E    	; E
	s_keyon
	s_note SC_E    	; E
	s_deflen 3
	s_keyon
	s_note SC_F    	; F
	s_keyon
	s_note SC_F    	; F
	s_keyon
	s_note SC_F    	; F
	s_keyon
	s_note SC_G    	; G
	s_keyon
	s_note SC_G    	; G
	s_keyon
	s_note SC_G    	; G
	s_deflen 2
	s_keyon
	s_note SC_GS   	; G#
	s_keyon
	s_note SC_GS   	; G#
	s_keyon
	s_note SC_GS   	; G#
	s_keyon
	s_note SC_G    	; G
	s_instr 1
	s_keyon
	s_note SC_GS   	; G#
	s_keyon
	s_note SC_G    	; G
	s_instr 3
	s_keyon
	s_note SC_GS   	; G#
	s_keyon
	s_note SC_G    	; G
	s_instr 5
	s_keyon
	s_note SC_GS   	; G#
	s_keyon
	s_note SC_G    	; G
	s_end
Snd_3f_514f:
	s_pitchenv 0
	s_oct 1	; block 0
	s_instr 12
	s_instr 10
	s_deflen 2
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_keyon
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note_l SC_REST, 1	; rest dur=1
	s_deflen 2
	s_note SC_F    	; F
	s_keyon
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_keyon
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_keyon
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_keyon
	s_note SC_F    	; F
	s_note_l SC_REST, 1	; rest dur=1
	s_deflen 2
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_keyon
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_keyon
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note_l SC_REST, 1	; rest dur=1
	s_deflen 2
	s_note SC_F    	; F
	s_keyon
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note_l SC_REST, 1	; rest dur=1
	s_deflen 2
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_keyon
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_keyon
	s_note SC_F    	; F
	s_end
Snd_3f_5197:
	s_end
