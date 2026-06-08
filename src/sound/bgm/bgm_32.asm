; Sound id $32 (BGM) -- Pashute
; Bank $3e, ROM $570a-$5a2f. INCLUDEd by sound/bank1.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "BGM - $32", ROMX

; ===== sound id $32 =====
Snd_BGM_Pashute:
	s_chan $f0, Snd_3e_5716
	s_chan $f0, Snd_3e_5913
	s_chan $f0, Snd_3e_5988
	s_chan $f0, Snd_3e_5a1d
Snd_3e_5716:
	s_pitchenv 0
	s_instr 2
	s_deflen 9
	s_set10 0
	s_dutyenv 4
Snd_3e_5720:
	s_dutyenv 4
	s_call Snd_3e_574b
	s_call Snd_3e_5781
	s_call Snd_3e_57aa
	s_call Snd_3e_57e1
	s_dutyenv 3
	s_call Snd_3e_580b
	s_call Snd_3e_5857
	s_call Snd_3e_588a
	s_call Snd_3e_58be
	s_call Snd_3e_5831
	s_call Snd_3e_5857
	s_call Snd_3e_588a
	s_call Snd_3e_58e9
	s_goto Snd_3e_5720
Snd_3e_574b:
	s_oct 5	; block 4
	s_instr 2
	s_note SC_G    	; G
	s_instr 3
	s_note SC_G    	; G
	s_oct 6	; block 5
	s_instr 2
	s_note SC_C    	; C
	s_instr 3
	s_note SC_C    	; C
	s_oct 5	; block 4
	s_instr 2
	s_note SC_B    	; B
	s_instr 3
	s_note SC_B    	; B
	s_oct 6	; block 5
	s_instr 2
	s_note SC_D    	; D
	s_instr 3
	s_note SC_D    	; D
	s_instr 4
	s_note SC_D    	; D
	s_instr 5
	s_note SC_D    	; D
	s_instr 2
	s_note SC_C    	; C
	s_instr 3
	s_note SC_C    	; C
	s_oct 5	; block 4
	s_instr 2
	s_note SC_B    	; B
	s_instr 3
	s_note SC_B    	; B
	s_instr 2
	s_note SC_G    	; G
	s_instr 3
	s_note SC_G    	; G
	s_ret
Snd_3e_5781:
	s_instr 2
	s_note_l SC_A, 36	; A dur=36
	s_instr 3
	s_note SC_A    	; A
	s_instr 4
	s_note SC_A    	; A
	s_instr 2
	s_note SC_F    	; F
	s_instr 3
	s_note SC_F    	; F
	s_instr 3
	s_note SC_F    	; F
	s_instr 4
	s_note SC_F    	; F
	s_instr 2
	s_note SC_E    	; E
	s_instr 3
	s_note SC_E    	; E
	s_instr 2
	s_note SC_D    	; D
	s_instr 3
	s_note SC_D    	; D
	s_instr 2
	s_note SC_F    	; F
	s_instr 3
	s_note SC_F    	; F
	s_ret
Snd_3e_57aa:
	s_oct 5	; block 4
	s_instr 2
	s_note SC_G    	; G
	s_instr 3
	s_note SC_G    	; G
	s_oct 6	; block 5
	s_instr 2
	s_note SC_C    	; C
	s_instr 3
	s_note SC_C    	; C
	s_oct 5	; block 4
	s_instr 2
	s_note SC_B    	; B
	s_instr 3
	s_note SC_B    	; B
	s_oct 6	; block 5
	s_instr 2
	s_note SC_D    	; D
	s_instr 3
	s_note SC_D    	; D
	s_instr 4
	s_note SC_D    	; D
	s_instr 5
	s_note SC_D    	; D
	s_instr 2
	s_note SC_C    	; C
	s_instr 3
	s_note SC_C    	; C
	s_oct 5	; block 4
	s_instr 2
	s_note SC_G    	; G
	s_instr 3
	s_note SC_G    	; G
	s_oct 6	; block 5
	s_instr 2
	s_note SC_E    	; E
	s_instr 3
	s_note SC_E    	; E
	s_ret
Snd_3e_57e1:
	s_instr 2
	s_note_l SC_D, 36	; D dur=36
	s_instr 3
	s_note SC_D    	; D
	s_instr 4
	s_note SC_D    	; D
	s_instr 2
	s_note SC_F    	; F
	s_instr 3
	s_note SC_F    	; F
	s_instr 4
	s_note SC_F    	; F
	s_instr 5
	s_note SC_F    	; F
	s_instr 2
	s_note SC_E    	; E
	s_instr 3
	s_note SC_E    	; E
	s_instr 2
	s_note SC_D    	; D
	s_instr 3
	s_note SC_D    	; D
	s_oct 5	; block 4
	s_instr 2
	s_note SC_AS   	; A#
	s_instr 3
	s_note SC_AS   	; A#
	s_ret
Snd_3e_580b:
	s_instr 3
	s_note SC_E    	; E
	s_note SC_G    	; G
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_note SC_G    	; G
	s_note SC_E    	; E
	s_note SC_E    	; E
	s_note SC_G    	; G
	s_instr 2
	s_note SC_G    	; G
	s_instr 3
	s_note SC_G    	; G
	s_oct 6	; block 5
	s_instr 2
	s_note SC_C    	; C
	s_instr 3
	s_note SC_C    	; C
	s_oct 5	; block 4
	s_instr 2
	s_note SC_B    	; B
	s_instr 3
	s_note SC_B    	; B
	s_oct 6	; block 5
	s_instr 2
	s_note SC_D    	; D
	s_instr 3
	s_note SC_D    	; D
	s_ret
Snd_3e_5831:
	s_instr 3
	s_note SC_G    	; G
	s_note SC_G    	; G
	s_note SC_E    	; E
	s_note SC_G    	; G
	s_note SC_G    	; G
	s_note SC_C    	; C
	s_note SC_E    	; E
	s_note SC_G    	; G
	s_instr 2
	s_note SC_G    	; G
	s_instr 3
	s_note SC_G    	; G
	s_oct 6	; block 5
	s_instr 2
	s_note SC_C    	; C
	s_instr 3
	s_note SC_C    	; C
	s_oct 5	; block 4
	s_instr 2
	s_note SC_B    	; B
	s_instr 3
	s_note SC_B    	; B
	s_oct 6	; block 5
	s_instr 2
	s_note SC_D    	; D
	s_instr 3
	s_note SC_D    	; D
	s_ret
Snd_3e_5857:
	s_instr 4
	s_note SC_D    	; D
	s_instr 5
	s_note SC_D    	; D
	s_instr 2
	s_note SC_C    	; C
	s_instr 3
	s_note SC_C    	; C
	s_oct 5	; block 4
	s_instr 2
	s_note SC_AS   	; A#
	s_instr 3
	s_note SC_AS   	; A#
	s_instr 2
	s_note SC_F    	; F
	s_instr 3
	s_note SC_F    	; F
	s_instr 2
	s_note SC_D    	; D
	s_instr 3
	s_note SC_D    	; D
	s_instr 2
	s_note SC_F    	; F
	s_instr 3
	s_note SC_F    	; F
	s_instr 2
	s_note SC_AS   	; A#
	s_instr 3
	s_note SC_AS   	; A#
	s_oct 6	; block 5
	s_instr 2
	s_note SC_F    	; F
	s_instr 3
	s_note SC_F    	; F
	s_ret
Snd_3e_588a:
	s_instr 4
	s_note SC_F    	; F
	s_instr 5
	s_note SC_F    	; F
	s_instr 2
	s_note SC_E    	; E
	s_instr 3
	s_note SC_E    	; E
	s_oct 6	; block 5
	s_instr 2
	s_note SC_C    	; C
	s_instr 3
	s_note SC_C    	; C
	s_oct 5	; block 4
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
	s_instr 3
	s_note SC_B    	; B
	s_oct 6	; block 5
	s_instr 2
	s_note SC_C    	; C
	s_instr 3
	s_note SC_C    	; C
	s_instr 2
	s_note SC_E    	; E
	s_instr 3
	s_note SC_E    	; E
	s_ret
Snd_3e_58be:
	s_instr 2
	s_note SC_F    	; F
	s_instr 3
	s_note SC_F    	; F
	s_instr 2
	s_note SC_E    	; E
	s_instr 3
	s_note SC_E    	; E
	s_instr 2
	s_note SC_G    	; G
	s_instr 3
	s_note SC_G    	; G
	s_instr 2
	s_note SC_C    	; C
	s_instr 3
	s_note SC_C    	; C
	s_instr 4
	s_note SC_C    	; C
	s_instr 5
	s_note SC_C    	; C
	s_instr 2
	s_note SC_D    	; D
	s_instr 3
	s_note SC_D    	; D
	s_oct 5	; block 4
	s_note_l SC_A, 18	; A dur=18
	s_note_l SC_G, 18	; G dur=18
	s_keyon
	s_ret
Snd_3e_58e9:
	s_instr 2
	s_note SC_F    	; F
	s_instr 3
	s_note SC_F    	; F
	s_instr 2
	s_note SC_E    	; E
	s_instr 3
	s_note SC_E    	; E
	s_instr 2
	s_note SC_G    	; G
	s_instr 3
	s_note SC_G    	; G
	s_instr 2
	s_note SC_F    	; F
	s_instr 3
	s_note SC_F    	; F
	s_instr 4
	s_note SC_F    	; F
	s_instr 5
	s_note SC_F    	; F
	s_instr 2
	s_note SC_E    	; E
	s_instr 3
	s_note SC_E    	; E
	s_note_l SC_D, 18	; D dur=18
	s_note_l SC_C, 18	; C dur=18
	s_keyon
	s_ret
Snd_3e_5913:
	s_pitchenv 1
	s_instr 1
	s_deflen 18
	s_set10 0
	s_dutyenv 5
Snd_3e_591d:
	s_call Snd_3e_592c
	s_call Snd_3e_593e
	s_call Snd_3e_5957
	s_call Snd_3e_5970
	s_goto Snd_3e_591d
Snd_3e_592c:
	s_oct 4	; block 3
	s_instr 1
	s_note SC_C    	; C
	s_instr 3
	s_note SC_C    	; C
	s_instr 1
	s_note_l SC_G, 72	; G dur=72
	s_instr 2
	s_note SC_G    	; G
	s_instr 3
	s_note SC_G    	; G
	s_ret
Snd_3e_593e:
	s_oct 3	; block 2
	s_instr 1
	s_note SC_AS   	; A#
	s_instr 3
	s_note SC_AS   	; A#
	s_oct 4	; block 3
	s_instr 1
	s_note_l SC_F, 36	; F dur=36
	s_instr 2
	s_note SC_F    	; F
	s_instr 3
	s_note SC_F    	; F
	s_instr 4
	s_note SC_F    	; F
	s_instr 5
	s_note SC_F    	; F
	s_ret
Snd_3e_5957:
	s_oct 3	; block 2
	s_instr 1
	s_note SC_G    	; G
	s_instr 3
	s_note SC_G    	; G
	s_oct 4	; block 3
	s_instr 1
	s_note_l SC_E, 36	; E dur=36
	s_instr 2
	s_note SC_E    	; E
	s_instr 3
	s_note SC_E    	; E
	s_instr 4
	s_note SC_E    	; E
	s_instr 5
	s_note SC_E    	; E
	s_ret
Snd_3e_5970:
	s_oct 3	; block 2
	s_instr 1
	s_note SC_AS   	; A#
	s_instr 3
	s_note SC_AS   	; A#
	s_oct 4	; block 3
	s_instr 1
	s_note_l SC_F, 36	; F dur=36
	s_instr 2
	s_note SC_F    	; F
	s_instr 3
	s_note SC_F    	; F
	s_instr 2
	s_note SC_E    	; E
	s_note SC_D    	; D
	s_oct 5	; block 4
	s_ret
Snd_3e_5988:
	s_pitchenv 0
	s_wave 2
	s_deflen 18
	s_set10 0
Snd_3e_5990:
	s_call Snd_3e_599f
	s_call Snd_3e_59ac
	s_call Snd_3e_599f
	s_call Snd_3e_59ac
	s_goto Snd_3e_5990
Snd_3e_599f:
	s_oct 3	; block 2
	s_instr 20
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_oct 4	; block 3
	s_note_l SC_C, 72	; C dur=72
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_ret
Snd_3e_59ac:
	s_oct 2	; block 1
	s_instr 20
	s_note SC_AS   	; A#
	s_note SC_F    	; F
	s_oct 3	; block 2
	s_note_l SC_AS, 72	; A# dur=72
	s_oct 3	; block 2
	s_note SC_F    	; F
	s_note SC_AS   	; A#
	s_ret
Snd_3e_59b8:	; unused/dead pattern
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
	s_oct 2	; block 1
	s_instr 20
	s_note SC_B    	; B
	s_instr 19
	s_note SC_B    	; B
	s_instr 20
	s_note SC_B    	; B
	s_instr 19
	s_note SC_B    	; B
	s_instr 20
	s_note SC_B    	; B
	s_instr 19
	s_note SC_B    	; B
	s_instr 20
	s_note SC_B    	; B
	s_instr 19
	s_note SC_B    	; B
	s_ret
	s_instr 20
	s_note SC_A    	; A
	s_instr 19
	s_note SC_A    	; A
	s_instr 20
	s_note SC_A    	; A
	s_instr 19
	s_note SC_A    	; A
	s_instr 20
	s_note SC_A    	; A
	s_instr 19
	s_note SC_A    	; A
	s_instr 20
	s_note SC_A    	; A
	s_instr 19
	s_note SC_A    	; A
	s_ret
	s_instr 20
	s_note SC_G    	; G
	s_instr 19
	s_note SC_G    	; G
	s_instr 20
	s_note SC_G    	; G
	s_instr 19
	s_note SC_G    	; G
	s_instr 20
	s_note SC_G    	; G
	s_instr 19
	s_note SC_G    	; G
	s_instr 20
	s_note SC_G    	; G
	s_instr 19
	s_note SC_G    	; G
	s_ret
Snd_3e_5a1d:
	s_pitchenv 0
	s_deflen 9
	s_oct 1	; block 0
	s_set10 0
Snd_3e_5a24:
	s_note_l SC_REST, 36	; rest dur=36
	s_goto Snd_3e_5a24
Snd_3e_5a29:	; unused/dead pattern
	s_deflen 18
	s_instr 10
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_ret
