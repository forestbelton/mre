; Sound id $0e (SFX) -- ?
; Bank $3f, ROM $505b-$5084. INCLUDEd by sound/bank0.asm into its $4b00 section.

; ===== sound id $0e =====
Snd_3f_505b:
	s_chan $00, Snd_3f_5084
	s_chan $f0, Snd_3f_5067
	s_chan $00, Snd_3f_5084
	s_chan $00, Snd_3f_5084
Snd_3f_5067:
	s_set10 0
	s_dutyenv 2
	s_pitchenv 0
	s_instr 0
	s_deflen 1
	s_oct 8	; block 7
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_oct 6	; block 5
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_end
Snd_3f_5084:
	s_end
