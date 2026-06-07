; Sound id $21 (SFX) -- ?
; Bank $3f, ROM $5689-$56bc. INCLUDEd by sound/bank0.asm into its $4b00 section.

; ===== sound id $21 =====
Snd_3f_5689:
	s_chan $00, Snd_3f_56bc
	s_chan $f0, Snd_3f_5695
	s_chan $00, Snd_3f_56bc
	s_chan $00, Snd_3f_56bc
Snd_3f_5695:
	s_pitchenv 0
	s_set10 0
	s_dutyenv 4
	s_deflen 1
	s_oct 4	; block 3
	s_instr 0
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_REST 	; rest
	s_oct 5	; block 4
	s_note SC_G    	; G
	s_note SC_D    	; D
	s_note SC_E    	; E
	s_oct 4	; block 3
	s_instr 3
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_REST 	; rest
	s_oct 5	; block 4
	s_note SC_G    	; G
	s_note SC_D    	; D
	s_note SC_E    	; E
	s_oct 4	; block 3
	s_instr 5
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_REST 	; rest
	s_oct 5	; block 4
	s_note SC_G    	; G
	s_note SC_D    	; D
	s_note SC_E    	; E
	s_end
Snd_3f_56bc:
	s_end
