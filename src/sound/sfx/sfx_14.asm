; Sound id $14 (SFX) -- ?
; Bank $3f, ROM $5283-$52cd. INCLUDEd by sound/bank0.asm into its $4b00 section.

; ===== sound id $14 =====
Snd_3f_5283:
	s_chan $00, Snd_3f_52cd
	s_chan $f0, Snd_3f_528f
	s_chan $00, Snd_3f_52cd
	s_chan $f0, Snd_3f_52b5
Snd_3f_528f:
	s_set10 0
	s_dutyenv 5
	s_pitchenv 0
	s_deflen 1
	s_instr 0
	s_call Snd_3f_52a7
	s_instr 2
	s_call Snd_3f_52a7
	s_instr 4
	s_call Snd_3f_52a7
	s_end
Snd_3f_52a7:
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_note SC_REST 	; rest
	s_note SC_GS   	; G#
	s_note SC_A    	; A
	s_note SC_CS   	; C#
	s_note SC_REST 	; rest
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_note SC_REST 	; rest
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_note SC_A    	; A
	s_ret
Snd_3f_52b5:
	s_deflen 1
	s_pitchenv 0
	s_oct 1	; block 0
	s_instr 10
	s_note SC_F    	; F
	s_note SC_D    	; D
	s_note SC_D    	; D
	s_note SC_F    	; F
	s_instr 13
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_instr 10
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_end
Snd_3f_52cd:
	s_end
