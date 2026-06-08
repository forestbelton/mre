; Sound id $37 (BGM) -- title
; Bank $3e, ROM $646a-$664c. INCLUDEd by sound/bank1.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "BGM - $37", ROMX

; ===== sound id $37 =====
Snd_3e_646a:
	s_chan $f0, Snd_3e_6476
	s_chan $f0, Snd_3e_6559
	s_chan $f0, Snd_3e_65d2
	s_chan $f0, Snd_3e_660e
Snd_3e_6476:
	s_pitchenv 0
	s_instr 1
	s_deflen 18
	s_oct 4	; block 3
	s_set10 0
	s_dutyenv 3
Snd_3e_6481:
	s_call Snd_3e_649c
	s_call Snd_3e_64b8
	s_call Snd_3e_64cd
	s_call Snd_3e_64e2
	s_call Snd_3e_64f9
	s_call Snd_3e_651c
	s_call Snd_3e_6531
	s_call Snd_3e_6546
	s_goto Snd_3e_6481
Snd_3e_649c:
	s_oct 5	; block 4
	s_deflen 18
	s_instr 2
	s_note SC_E    	; E
	s_instr 3
	s_note SC_E    	; E
	s_instr 4
	s_note SC_E    	; E
	s_instr 5
	s_note SC_E    	; E
	s_instr 2
	s_note SC_F    	; F
	s_instr 3
	s_note SC_F    	; F
	s_instr 4
	s_note SC_F    	; F
	s_instr 5
	s_note SC_F    	; F
	s_ret
Snd_3e_64b8:
	s_instr 2
	s_note SC_G    	; G
	s_instr 3
	s_note SC_G    	; G
	s_instr 4
	s_note SC_G    	; G
	s_instr 5
	s_note SC_G    	; G
	s_instr 2
	s_note SC_B    	; B
	s_oct 6	; block 5
	s_note SC_C    	; C
	s_oct 5	; block 4
	s_note SC_G    	; G
	s_note SC_F    	; F
	s_ret
Snd_3e_64cd:
	s_instr 2
	s_note SC_G    	; G
	s_instr 4
	s_note SC_G    	; G
	s_instr 5
	s_note SC_G    	; G
	s_instr 2
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_G    	; G
	s_instr 4
	s_note SC_G    	; G
	s_instr 2
	s_note SC_F    	; F
	s_ret
Snd_3e_64e2:
	s_instr 2
	s_note SC_E    	; E
	s_instr 3
	s_note SC_E    	; E
	s_instr 4
	s_note SC_E    	; E
	s_instr 5
	s_note SC_E    	; E
	s_note SC_REST 	; rest
	s_instr 2
	s_note SC_C    	; C
	s_instr 4
	s_note SC_C    	; C
	s_instr 2
	s_note SC_D    	; D
	s_ret
Snd_3e_64f9:
	s_instr 2
	s_note SC_G    	; G
	s_instr 3
	s_note SC_G    	; G
	s_instr 4
	s_note SC_G    	; G
	s_instr 5
	s_note SC_G    	; G
	s_oct 6	; block 5
	s_instr 2
	s_note SC_C    	; C
	s_instr 4
	s_note SC_C    	; C
	s_instr 5
	s_note SC_C    	; C
	s_deflen 6
	s_instr 2
	s_oct 5	; block 4
	s_note SC_B    	; B
	s_keyon
	s_oct 6	; block 5
	s_note SC_C    	; C
	s_keyon
	s_oct 5	; block 4
	s_note SC_B    	; B
	s_ret
Snd_3e_651c:
	s_deflen 18
	s_instr 2
	s_note SC_G    	; G
	s_instr 3
	s_note SC_G    	; G
	s_instr 4
	s_note SC_G    	; G
	s_instr 5
	s_note SC_G    	; G
	s_instr 2
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_ret
Snd_3e_6531:
	s_instr 2
	s_note SC_G    	; G
	s_instr 4
	s_note SC_G    	; G
	s_instr 5
	s_note SC_G    	; G
	s_instr 2
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_G    	; G
	s_instr 4
	s_note SC_G    	; G
	s_instr 2
	s_note SC_F    	; F
	s_ret
Snd_3e_6546:
	s_instr 2
	s_note SC_E    	; E
	s_instr 3
	s_note SC_E    	; E
	s_instr 4
	s_note SC_E    	; E
	s_instr 5
	s_note SC_E    	; E
	s_instr 2
	s_note SC_REST 	; rest
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_note SC_C    	; C
	s_ret
Snd_3e_6559:
	s_pitchenv 0
	s_instr 3
	s_set10 0
	s_dutyenv 5
Snd_3e_6561:
	s_call Snd_3e_657c
	s_call Snd_3e_6599
	s_call Snd_3e_657c
	s_call Snd_3e_65ac
	s_call Snd_3e_657c
	s_call Snd_3e_6599
	s_call Snd_3e_657c
	s_call Snd_3e_65ac
	s_goto Snd_3e_6561
Snd_3e_657c:
	s_oct 5	; block 4
	s_deflen 18
	s_instr 1
	s_note SC_C    	; C
	s_instr 2
	s_note SC_C    	; C
	s_instr 3
	s_note SC_C    	; C
	s_instr 4
	s_note SC_C    	; C
	s_oct 4	; block 3
	s_instr 1
	s_note SC_A    	; A
	s_instr 2
	s_note SC_A    	; A
	s_instr 3
	s_note SC_A    	; A
	s_instr 4
	s_note SC_A    	; A
	s_ret
Snd_3e_6599:
	s_instr 1
	s_note SC_B    	; B
	s_instr 2
	s_note SC_B    	; B
	s_instr 3
	s_note SC_B    	; B
	s_instr 4
	s_note SC_B    	; B
	s_note SC_REST 	; rest
	s_instr 1
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_ret
Snd_3e_65ac:
	s_instr 1
	s_note SC_B    	; B
	s_instr 2
	s_note SC_B    	; B
	s_instr 3
	s_note SC_B    	; B
	s_instr 4
	s_note SC_B    	; B
	s_instr 1
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_ret
Snd_3e_65bf:	; unused/dead pattern
	s_instr 1
	s_note SC_B    	; B
	s_instr 2
	s_note SC_B    	; B
	s_instr 3
	s_note SC_B    	; B
	s_instr 4
	s_note SC_B    	; B
	s_note SC_REST 	; rest
	s_instr 1
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_ret
Snd_3e_65d2:
	s_pitchenv 0
	s_set10 0
Snd_3e_65d6:
	s_call Snd_3e_65e5
	s_call Snd_3e_65e5
	s_call Snd_3e_65e5
	s_call Snd_3e_65e5
	s_goto Snd_3e_65d6
Snd_3e_65e5:
	s_wave 2
	s_deflen 18
	s_oct 3	; block 2
	s_instr 20
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_instr 19
	s_note SC_G    	; G
	s_instr 20
	s_note SC_G    	; G
	s_note SC_D    	; D
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_ret
Snd_3e_65fb:	; unused/dead pattern
	s_oct 2	; block 1
	s_instr 20
	s_note SC_G    	; G
	s_oct 3	; block 2
	s_note SC_D    	; D
	s_note SC_G    	; G
	s_oct 4	; block 3
	s_note SC_D    	; D
	s_instr 19
	s_note SC_D    	; D
	s_instr 20
	s_note SC_D    	; D
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_ret
Snd_3e_660e:
	s_pitchenv 0
	s_deflen 9
	s_oct 1	; block 0
	s_set10 0
Snd_3e_6615:
	s_call Snd_3e_6624
	s_call Snd_3e_6624
	s_call Snd_3e_6624
	s_call Snd_3e_6638
	s_goto Snd_3e_6615
Snd_3e_6624:
	s_deflen 36
	s_instr 10
	s_note SC_F    	; F
	s_instr 12
	s_note SC_D    	; D
	s_instr 10
	s_note SC_F    	; F
	s_instr 12
	s_note_l SC_D, 18	; D dur=18
	s_instr 10
	s_note_l SC_F, 18	; F dur=18
	s_ret
Snd_3e_6638:
	s_instr 10
	s_note SC_F    	; F
	s_instr 12
	s_note SC_D    	; D
	s_instr 10
	s_note SC_F    	; F
	s_instr 12
	s_note_l SC_D, 18	; D dur=18
	s_deflen 6
	s_instr 12
	s_note SC_D    	; D
	s_note SC_D    	; D
	s_note SC_D    	; D
	s_ret
