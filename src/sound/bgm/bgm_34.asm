; Sound id $34 (BGM) -- Toamuna
; Bank $3e, ROM $5cb6-$5ef8. INCLUDEd by sound/bank1.asm into its $4b00 section.

; ===== sound id $34 =====
Snd_3e_5cb6:
	s_chan $f0, Snd_3e_5cc2
	s_chan $f0, Snd_3e_5d97
	s_chan $f0, Snd_3e_5e54
	s_chan $f0, Snd_3e_5eed
Snd_3e_5cc2:
	s_pitchenv 0
	s_deflen 20
	s_set10 0
	s_dutyenv 5
Snd_3e_5cca:
	s_dutyenv 1
	s_call Snd_3e_5cf5
	s_call Snd_3e_5d08
	s_call Snd_3e_5cf5
	s_call Snd_3e_5d19
	s_dutyenv 5
	s_call Snd_3e_5d28
	s_call Snd_3e_5d39
	s_call Snd_3e_5d4b
	s_call Snd_3e_5d5e
	s_call Snd_3e_5d28
	s_call Snd_3e_5d6e
	s_call Snd_3e_5d7d
	s_call Snd_3e_5d88
	s_goto Snd_3e_5cca
Snd_3e_5cf5:
	s_oct 4	; block 3
	s_instr 2
	s_note SC_B    	; B
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_note SC_E    	; E
	s_instr 4
	s_note SC_E    	; E
	s_instr 2
	s_note SC_C    	; C
	s_oct 4	; block 3
	s_note SC_B    	; B
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_ret
Snd_3e_5d08:
	s_oct 4	; block 3
	s_note SC_G    	; G
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_note SC_F    	; F
	s_instr 4
	s_note SC_F    	; F
	s_instr 2
	s_note SC_E    	; E
	s_oct 4	; block 3
	s_note SC_G    	; G
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_ret
Snd_3e_5d19:
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_note SC_F    	; F
	s_instr 4
	s_note SC_F    	; F
	s_instr 2
	s_note SC_E    	; E
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_ret
Snd_3e_5d28:
	s_oct 5	; block 4
	s_instr 2
	s_note_l SC_G, 60	; G dur=60
	s_note SC_E    	; E
	s_instr 4
	s_note SC_E    	; E
	s_instr 3
	s_note SC_C    	; C
	s_oct 4	; block 3
	s_note SC_B    	; B
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_ret
Snd_3e_5d39:
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_instr 2
	s_oct 5	; block 4
	s_note SC_G    	; G
	s_note SC_F    	; F
	s_instr 4
	s_note SC_F    	; F
	s_instr 2
	s_note SC_E    	; E
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_ret
Snd_3e_5d4b:
	s_note_l SC_E, 60	; E dur=60
	s_instr 3
	s_note SC_E    	; E
	s_instr 4
	s_note SC_E    	; E
	s_instr 3
	s_oct 4	; block 3
	s_instr 2
	s_note SC_G    	; G
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_oct 4	; block 3
	s_note SC_B    	; B
	s_ret
Snd_3e_5d5e:
	s_note_l SC_G, 60	; G dur=60
	s_instr 3
	s_oct 5	; block 4
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_note SC_G    	; G
	s_instr 4
	s_note SC_G    	; G
	s_oct 4	; block 3
	s_instr 3
	s_note SC_G    	; G
	s_ret
Snd_3e_5d6e:
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_instr 3
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_instr 2
	s_note SC_A    	; A
	s_note_l SC_G, 40	; G dur=40
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_note SC_D    	; D
	s_ret
Snd_3e_5d7d:
	s_note_l SC_E, 80	; E dur=80
	s_instr 3
	s_note SC_E    	; E
	s_oct 4	; block 3
	s_note SC_G    	; G
	s_note SC_B    	; B
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_ret
Snd_3e_5d88:
	s_instr 2
	s_note_l SC_E, 80	; E dur=80
	s_instr 3
	s_note SC_D    	; D
	s_instr 4
	s_note SC_D    	; D
	s_instr 3
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_ret
Snd_3e_5d97:
	s_pitchenv 1
	s_deflen 20
	s_oct 4	; block 3
	s_set10 0
	s_dutyenv 4
Snd_3e_5da0:
	s_call Snd_3e_5dc7
	s_call Snd_3e_5de0
	s_call Snd_3e_5dc7
	s_call Snd_3e_5de0
	s_call Snd_3e_5e12
	s_call Snd_3e_5e25
	s_call Snd_3e_5e12
	s_call Snd_3e_5e25
	s_call Snd_3e_5e12
	s_call Snd_3e_5e25
	s_call Snd_3e_5e12
	s_call Snd_3e_5e25
	s_goto Snd_3e_5da0
Snd_3e_5dc7:
	s_instr 1
	s_note SC_E    	; E
	s_instr 4
	s_note SC_E    	; E
	s_instr 1
	s_note SC_E    	; E
	s_instr 4
	s_note SC_E    	; E
	s_instr 1
	s_note SC_E    	; E
	s_instr 4
	s_note SC_E    	; E
	s_instr 1
	s_note SC_E    	; E
	s_instr 4
	s_note SC_E    	; E
	s_ret
Snd_3e_5de0:
	s_instr 1
	s_note SC_F    	; F
	s_instr 4
	s_note SC_F    	; F
	s_instr 1
	s_note SC_F    	; F
	s_instr 4
	s_note SC_F    	; F
	s_instr 1
	s_note SC_F    	; F
	s_instr 4
	s_note SC_F    	; F
	s_instr 1
	s_note SC_F    	; F
	s_instr 4
	s_note SC_F    	; F
	s_ret
Snd_3e_5df9:	; unused/dead pattern
	s_instr 1
	s_note SC_D    	; D
	s_instr 4
	s_note SC_D    	; D
	s_instr 1
	s_note SC_D    	; D
	s_instr 4
	s_note SC_D    	; D
	s_instr 1
	s_note SC_D    	; D
	s_instr 4
	s_note SC_D    	; D
	s_instr 1
	s_note SC_D    	; D
	s_instr 4
	s_note SC_D    	; D
	s_ret
Snd_3e_5e12:
	s_instr 1
	s_oct 4	; block 3
	s_note SC_E    	; E
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_oct 4	; block 3
	s_note SC_E    	; E
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_oct 4	; block 3
	s_note SC_E    	; E
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_oct 4	; block 3
	s_note SC_E    	; E
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_ret
Snd_3e_5e25:
	s_oct 4	; block 3
	s_note SC_F    	; F
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_F    	; F
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_F    	; F
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_F    	; F
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_ret
Snd_3e_5e36:	; unused/dead pattern
	s_oct 4	; block 3
	s_note SC_D    	; D
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_D    	; D
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_D    	; D
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_D    	; D
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_ret
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_oct 4	; block 3
	s_note SC_D    	; D
	s_note SC_G    	; G
	s_note SC_D    	; D
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_note SC_G    	; G
	s_oct 4	; block 3
	s_note SC_G    	; G
	s_note SC_F    	; F
	s_ret
Snd_3e_5e54:
	s_pitchenv 0
	s_oct 3	; block 2
	s_wave 2
	s_set10 0
Snd_3e_5e5b:
	s_call Snd_3e_5e82
	s_call Snd_3e_5e82
	s_call Snd_3e_5e82
	s_call Snd_3e_5e82
	s_call Snd_3e_5e82
	s_call Snd_3e_5e82
	s_call Snd_3e_5e82
	s_call Snd_3e_5e82
	s_call Snd_3e_5e82
	s_call Snd_3e_5e82
	s_call Snd_3e_5e82
	s_call Snd_3e_5eb4
	s_goto Snd_3e_5e5b
Snd_3e_5e82:
	s_instr 20
	s_oct 4	; block 3
	s_note_l SC_C, 60	; C dur=60
	s_instr 19
	s_note_l SC_C, 20	; C dur=20
	s_instr 20
	s_note_l SC_C, 60	; C dur=60
	s_instr 19
	s_note_l SC_C, 20	; C dur=20
	s_ret
Snd_3e_5e94:	; unused/dead pattern
	s_deflen 10
	s_instr 20
	s_oct 4	; block 3
	s_note_l SC_C, 40	; C dur=40
	s_instr 19
	s_note_l SC_C, 20	; C dur=20
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_instr 20
	s_note_l SC_C, 40	; C dur=40
	s_instr 19
	s_note_l SC_C, 20	; C dur=20
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_ret
Snd_3e_5eb4:
	s_deflen 10
	s_instr 20
	s_note_l SC_C, 40	; C dur=40
	s_instr 19
	s_note_l SC_C, 20	; C dur=20
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_deflen 20
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_instr 20
	s_note_l SC_G, 40	; G dur=40
	s_ret
Snd_3e_5ed2:	; unused/dead pattern
	s_deflen 20
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_ret
Snd_3e_5eed:
	s_pitchenv 0
	s_deflen 10
	s_oct 1	; block 0
	s_set10 0
Snd_3e_5ef4:
	s_note_l SC_REST, 40	; rest dur=40
	s_goto Snd_3e_5ef4
