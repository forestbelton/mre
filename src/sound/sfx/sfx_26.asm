; Sound id $26 (SFX) -- ?
; Bank $3f, ROM $579c-$57fa. INCLUDEd by sound/bank0.asm into its $4b00 section.

; ===== sound id $26 =====
Snd_3f_579c:
	s_chan $00, Snd_3f_57fa
	s_chan $f0, Snd_3f_57a8
	s_chan $00, Snd_3f_57fa
	s_chan $00, Snd_3f_57fa
Snd_3f_57a8:
	s_set10 0
	s_dutyenv 4
	s_deflen 1
	s_pitchenv 0
	s_oct 4	; block 3
	s_instr 0
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_note SC_F    	; F
	s_oct 2	; block 1
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_call Snd_3f_57db
	s_instr 2
	s_call Snd_3f_57db
	s_instr 4
	s_call Snd_3f_57db
	s_instr 0
	s_call Snd_3f_57ed
	s_instr 2
	s_call Snd_3f_57ed
	s_instr 4
	s_call Snd_3f_57ed
	s_end
Snd_3f_57db:
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_B    	; B
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_oct 5	; block 4
	s_note SC_F    	; F
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_note SC_D    	; D
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_ret
Snd_3f_57ed:
	s_oct 2	; block 1
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_note SC_A    	; A
	s_note SC_REST 	; rest
	s_note SC_G    	; G
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_ret
Snd_3f_57fa:
	s_end
