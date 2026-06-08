; Sound id $29 (BGM) -- room
; Bank $3f, ROM $581b-$5ca2. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "BGM - $29", ROMX

; ===== sound id $29 =====
Snd_BGM_Room:
	s_chan $f0, Snd_3f_5827
	s_chan $f0, Snd_3f_5957
	s_chan $f0, Snd_3f_5a9b
	s_chan $f0, Snd_3f_5b9c
Snd_3f_5827:
	s_pitchenv 0
	s_instr 1
	s_note_l SC_REST, 14	; rest dur=14
	s_set10 0
Snd_3f_582f:
	s_dutyenv 2
	s_call Snd_3f_58a1
	s_call Snd_3f_58b1
	s_call Snd_3f_58b8
	s_call Snd_3f_58bc
	s_call Snd_3f_58a1
	s_call Snd_3f_58b1
	s_call Snd_3f_58b8
	s_call Snd_3f_58c5
	s_call Snd_3f_58ce
	s_call Snd_3f_58e6
	s_call Snd_3f_58fa
	s_call Snd_3f_58ff
	s_call Snd_3f_590a
	s_call Snd_3f_5924
	s_call Snd_3f_590a
	s_call Snd_3f_593b
	s_goto Snd_3f_582f
Snd_3f_5864:	; unused/dead pattern
	s_deflen 7
	s_oct 3	; block 2
	s_note_l SC_REST, 14	; rest dur=14
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_REST 	; rest
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_note SC_REST 	; rest
	s_note SC_A    	; A
	s_note SC_REST 	; rest
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_DS   	; D#
	s_note SC_REST 	; rest
	s_note_l SC_DS, 14	; D# dur=14
	s_ret
	s_oct 3	; block 2
	s_note_l SC_REST, 14	; rest dur=14
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_REST 	; rest
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_note SC_REST 	; rest
	s_note SC_A    	; A
	s_note SC_REST 	; rest
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_note SC_GS   	; G#
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_ret
	s_note_l SC_G, 14	; G dur=14
	s_note_l SC_REST, 14	; rest dur=14
	s_note SC_G    	; G
	s_note_l SC_A, 21	; A dur=21
	s_note SC_DS   	; D#
	s_note SC_D    	; D
	s_note SC_REST 	; rest
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_ret
Snd_3f_58a1:
	s_deflen 14
	s_oct 4	; block 3
	s_instr 1
	s_note SC_DS   	; D#
	s_note SC_REST 	; rest
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_note SC_A    	; A
	s_note SC_REST 	; rest
	s_note SC_G    	; G
	s_keyon
	s_ret
Snd_3f_58b1:
	s_note_l SC_G, 56	; G dur=56
	s_note SC_REST 	; rest
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_ret
Snd_3f_58b8:
	s_note_l SC_G, 112	; G dur=112
	s_keyon
	s_ret
Snd_3f_58bc:
	s_note_l SC_G, 84	; G dur=84
	s_instr 3
	s_note SC_G    	; G
	s_instr 5
	s_note SC_G    	; G
	s_ret
Snd_3f_58c5:
	s_note_l SC_G, 84	; G dur=84
	s_instr 3
	s_note SC_G    	; G
	s_instr 5
	s_note SC_G    	; G
	s_ret
Snd_3f_58ce:
	s_instr 1
	s_deflen 7
	s_oct 4	; block 3
	s_note_l SC_D, 21	; D dur=21
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_CS   	; C#
	s_note SC_D    	; D
	s_note SC_REST 	; rest
	s_note_l SC_D, 14	; D dur=14
	s_note SC_C    	; C
	s_deflen 14
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_note SC_G    	; G
	s_ret
Snd_3f_58e6:
	s_note_l SC_F, 28	; F dur=28
	s_deflen 7
	s_note SC_REST 	; rest
	s_oct 3	; block 2
	s_note_l SC_AS, 14	; A# dur=14
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note_l SC_G, 21	; G dur=21
	s_note_l SC_AS, 14	; A# dur=14
	s_note_l SC_B, 14	; B dur=14
	s_ret
Snd_3f_58fa:
	s_oct 4	; block 3
	s_note_l SC_C, 112	; C dur=112
	s_keyon
	s_ret
Snd_3f_58ff:
	s_note_l SC_C, 84	; C dur=84
	s_deflen 14
	s_instr 3
	s_note SC_C    	; C
	s_instr 5
	s_note SC_C    	; C
	s_ret
Snd_3f_590a:
	s_instr 2
	s_deflen 7
	s_oct 3	; block 2
	s_note SC_REST 	; rest
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_note SC_REST 	; rest
	s_note SC_A    	; A
	s_note SC_REST 	; rest
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_DS   	; D#
	s_note SC_REST 	; rest
	s_note_l SC_DS, 14	; D# dur=14
	s_ret
Snd_3f_5924:
	s_oct 3	; block 2
	s_note SC_REST 	; rest
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_note SC_REST 	; rest
	s_note SC_A    	; A
	s_note SC_REST 	; rest
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_note SC_GS   	; G#
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_ret
Snd_3f_593b:
	s_oct 3	; block 2
	s_note SC_REST 	; rest
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_instr 4
	s_note SC_G    	; G
	s_instr 2
	s_note SC_G    	; G
	s_note SC_REST 	; rest
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_ret
Snd_3f_5957:
	s_pitchenv 1
	s_note_l SC_REST, 14	; rest dur=14
	s_set10 0
	s_dutyenv 2
Snd_3f_595f:
	s_dutyenv 5
	s_call Snd_3f_59a8
	s_call Snd_3f_59a8
	s_call Snd_3f_59b9
	s_call Snd_3f_59d6
	s_call Snd_3f_59f5
	s_call Snd_3f_59f5
	s_call Snd_3f_5a03
	s_call Snd_3f_5a14
	s_call Snd_3f_5a2b
	s_call Snd_3f_5a3b
	s_call Snd_3f_5a46
	s_call Snd_3f_5a51
	s_dutyenv 4
	s_call Snd_3f_5a60
	s_call Snd_3f_5a75
	s_call Snd_3f_5a60
	s_call Snd_3f_5a87
	s_goto Snd_3f_595f
Snd_3f_5996:	; unused/dead pattern
	s_note_l SC_REST, 112	; rest dur=112
	s_ret
	s_note_l SC_G, 14	; G dur=14
	s_note_l SC_REST, 14	; rest dur=14
	s_note SC_G    	; G
	s_note_l SC_A, 21	; A dur=21
	s_note SC_DS   	; D#
	s_note SC_D    	; D
	s_note SC_REST 	; rest
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_ret
Snd_3f_59a8:
	s_deflen 14
	s_oct 3	; block 2
	s_instr 2
	s_note SC_AS   	; A#
	s_instr 4
	s_note SC_AS   	; A#
	s_note SC_REST 	; rest
	s_note_l SC_REST, 56	; rest dur=56
	s_instr 2
	s_note SC_G    	; G
	s_keyon
	s_ret
Snd_3f_59b9:
	s_oct 3	; block 2
	s_note_l SC_AS, 14	; A# dur=14
	s_deflen 7
	s_oct 4	; block 3
	s_note_l SC_G, 14	; G dur=14
	s_note SC_FS   	; F#
	s_note SC_F    	; F
	s_instr 3
	s_note SC_F    	; F
	s_instr 2
	s_note_l SC_DS, 14	; D# dur=14
	s_instr 3
	s_note SC_DS   	; D#
	s_instr 2
	s_note_l SC_C, 14	; C dur=14
	s_note_l SC_F, 14	; F dur=14
	s_note_l SC_FS, 14	; F# dur=14
	s_ret
Snd_3f_59d6:
	s_oct 3	; block 2
	s_note_l SC_AS, 14	; A# dur=14
	s_deflen 7
	s_oct 4	; block 3
	s_instr 2
	s_note_l SC_G, 14	; G dur=14
	s_note SC_G    	; G
	s_note SC_DS   	; D#
	s_instr 3
	s_note SC_DS   	; D#
	s_instr 2
	s_note_l SC_F, 14	; F dur=14
	s_note SC_F    	; F
	s_note_l SC_DS, 14	; D# dur=14
	s_note SC_F    	; F
	s_instr 4
	s_note SC_F    	; F
	s_instr 2
	s_note_l SC_G, 14	; G dur=14
	s_ret
Snd_3f_59f5:
	s_deflen 14
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_instr 4
	s_note SC_A    	; A
	s_note_l SC_REST, 56	; rest dur=56
	s_note SC_REST 	; rest
	s_instr 2
	s_note SC_G    	; G
	s_ret
Snd_3f_5a03:
	s_deflen 14
	s_note SC_AS   	; A#
	s_oct 4	; block 3
	s_note SC_DS   	; D#
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_deflen 7
	s_note SC_F    	; F
	s_note SC_FS   	; F#
	s_note SC_REST 	; rest
	s_note_l SC_F, 21	; F dur=21
	s_note_l SC_DS, 14	; D# dur=14
	s_ret
Snd_3f_5a14:
	s_deflen 14
	s_oct 3	; block 2
	s_note_l SC_AS, 21	; A# dur=21
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note_l SC_REST, 7	; rest dur=7
	s_note_l SC_DS, 28	; D# dur=28
	s_note SC_C    	; C
	s_deflen 7
	s_note SC_FS   	; F#
	s_instr 4
	s_note SC_FS   	; F#
	s_instr 2
	s_note_l SC_G, 14	; G dur=14
	s_ret
Snd_3f_5a2b:
	s_deflen 14
	s_oct 3	; block 2
	s_instr 2
	s_note SC_B    	; B
	s_instr 4
	s_note SC_B    	; B
	s_note SC_REST 	; rest
	s_note_l SC_REST, 56	; rest dur=56
	s_instr 2
	s_note SC_G    	; G
	s_ret
Snd_3f_5a3b:
	s_note SC_A    	; A
	s_instr 4
	s_note SC_A    	; A
	s_note_l SC_REST, 56	; rest dur=56
	s_note SC_REST 	; rest
	s_instr 2
	s_note SC_A    	; A
	s_ret
Snd_3f_5a46:
	s_note SC_G    	; G
	s_instr 4
	s_note SC_G    	; G
	s_note_l SC_REST, 56	; rest dur=56
	s_note SC_REST 	; rest
	s_instr 2
	s_note SC_AS   	; A#
	s_ret
Snd_3f_5a51:
	s_note SC_G    	; G
	s_instr 4
	s_note SC_G    	; G
	s_instr 2
	s_note_l SC_G, 21	; G dur=21
	s_note_l SC_AS, 21	; A# dur=21
	s_note SC_G    	; G
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_note SC_B    	; B
	s_ret
Snd_3f_5a60:
	s_deflen 7
	s_oct 5	; block 4
	s_instr 2
	s_note SC_C    	; C
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_oct 4	; block 3
	s_note SC_AS   	; A#
	s_note SC_AS   	; A#
	s_note SC_REST 	; rest
	s_note SC_AS   	; A#
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_instr 4
	s_note SC_C    	; C
	s_note_l SC_REST, 49	; rest dur=49
	s_ret
Snd_3f_5a75:
	s_instr 2
	s_note SC_C    	; C
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_oct 4	; block 3
	s_note SC_AS   	; A#
	s_note SC_AS   	; A#
	s_note SC_REST 	; rest
	s_note SC_G    	; G
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_instr 4
	s_note SC_C    	; C
	s_note_l SC_REST, 49	; rest dur=49
	s_ret
Snd_3f_5a87:
	s_instr 2
	s_note SC_C    	; C
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_oct 4	; block 3
	s_note SC_AS   	; A#
	s_note SC_AS   	; A#
	s_note SC_REST 	; rest
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_instr 4
	s_note SC_G    	; G
	s_note SC_REST 	; rest
	s_note_l SC_REST, 28	; rest dur=28
	s_note_l SC_REST, 14	; rest dur=14
	s_ret
Snd_3f_5a9b:
	s_pitchenv 0
	s_note_l SC_REST, 14	; rest dur=14
	s_set10 0
Snd_3f_5aa1:
	s_call Snd_3f_5b06
	s_call Snd_3f_5b06
	s_call Snd_3f_5b06
	s_call Snd_3f_5b06
	s_call Snd_3f_5b23
	s_call Snd_3f_5b3f
	s_call Snd_3f_5b06
	s_call Snd_3f_5b55
	s_call Snd_3f_5b6e
	s_call Snd_3f_5b86
	s_call Snd_3f_5b06
	s_call Snd_3f_5ad4
	s_call Snd_3f_5ad4
	s_call Snd_3f_5ad4
	s_call Snd_3f_5ad4
	s_call Snd_3f_5ad4
	s_goto Snd_3f_5aa1
Snd_3f_5ad4:
	s_wave 10
	s_deflen 7
	s_oct 3	; block 2
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_deflen 14
	s_instr 20
	s_note SC_C    	; C
	s_note_l SC_E, 21	; E dur=21
	s_note_l SC_F, 21	; F dur=21
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_G    	; G
	s_ret
Snd_3f_5aec:	; unused/dead pattern
	s_deflen 7
	s_oct 3	; block 2
	s_instr 20
	s_note_l SC_C, 14	; C dur=14
	s_instr 19
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_instr 20
	s_note SC_REST 	; rest
	s_note SC_C    	; C
	s_note SC_E    	; E
	s_note SC_C    	; C
	s_note SC_F    	; F
	s_note_l SC_E, 14	; E dur=14
	s_note_l SC_F, 14	; F dur=14
	s_note SC_E    	; E
	s_note_l SC_G, 14	; G dur=14
	s_ret
Snd_3f_5b06:
	s_wave 2
	s_deflen 14
	s_oct 3	; block 2
	s_instr 20
	s_note SC_C    	; C
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_E    	; E
	s_instr 19
	s_note_l SC_E, 7	; E dur=7
	s_instr 20
	s_note_l SC_F, 21	; F dur=21
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_keyon
	s_deflen 7
	s_note SC_FS   	; F#
	s_keyon
	s_note SC_G    	; G
	s_ret
Snd_3f_5b23:
	s_deflen 14
	s_oct 3	; block 2
	s_instr 20
	s_note SC_F    	; F
	s_oct 4	; block 3
	s_note SC_F    	; F
	s_note SC_DS   	; D#
	s_instr 19
	s_note_l SC_DS, 7	; D# dur=7
	s_instr 20
	s_note_l SC_C, 21	; C dur=21
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_deflen 7
	s_note SC_DS   	; D#
	s_keyon
	s_note SC_E    	; E
	s_ret
Snd_3f_5b3f:
	s_deflen 14
	s_oct 3	; block 2
	s_instr 20
	s_note SC_F    	; F
	s_oct 4	; block 3
	s_note SC_F    	; F
	s_note SC_DS   	; D#
	s_instr 19
	s_note_l SC_DS, 7	; D# dur=7
	s_instr 20
	s_note_l SC_C, 21	; C dur=21
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_note SC_AS   	; A#
	s_note SC_B    	; B
	s_ret
Snd_3f_5b55:
	s_deflen 14
	s_oct 3	; block 2
	s_instr 20
	s_note SC_C    	; C
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_E    	; E
	s_instr 19
	s_note_l SC_E, 7	; E dur=7
	s_instr 20
	s_note_l SC_F, 21	; F dur=21
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_deflen 7
	s_note SC_F    	; F
	s_note SC_FS   	; F#
	s_ret
Snd_3f_5b6e:
	s_oct 3	; block 2
	s_instr 20
	s_note_l SC_G, 28	; G dur=28
	s_deflen 14
	s_oct 4	; block 3
	s_instr 20
	s_note SC_F    	; F
	s_instr 19
	s_note_l SC_F, 7	; F dur=7
	s_instr 20
	s_note_l SC_D, 21	; D dur=21
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_oct 3	; block 2
	s_note SC_DS   	; D#
	s_ret
Snd_3f_5b86:
	s_oct 3	; block 2
	s_instr 20
	s_note_l SC_F, 28	; F dur=28
	s_oct 4	; block 3
	s_instr 20
	s_note SC_DS   	; D#
	s_instr 19
	s_note_l SC_DS, 7	; D# dur=7
	s_instr 20
	s_note_l SC_C, 21	; C dur=21
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_note SC_AS   	; A#
	s_note SC_A    	; A
	s_ret
Snd_3f_5b9c:
	s_pitchenv 0
	s_deflen 7
	s_oct 1	; block 0
	s_instr 10
	s_note SC_F    	; F
	s_instr 12
	s_note SC_C    	; C
	s_set10 0
Snd_3f_5ba9:
	s_call Snd_3f_5c60
	s_call Snd_3f_5c60
	s_call Snd_3f_5c60
	s_call Snd_3f_5c60
	s_call Snd_3f_5c60
	s_call Snd_3f_5c60
	s_call Snd_3f_5c60
	s_call Snd_3f_5c60
	s_call Snd_3f_5c60
	s_call Snd_3f_5c60
	s_call Snd_3f_5c60
	s_call Snd_3f_5c40
	s_call Snd_3f_5be7
	s_call Snd_3f_5be7
	s_call Snd_3f_5be7
	s_call Snd_3f_5c40
	s_goto Snd_3f_5ba9
Snd_3f_5bdc:	; unused/dead pattern
	s_deflen 14
	s_instr 10
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note_l SC_REST, 56	; rest dur=56
	s_note SC_REST 	; rest
	s_note SC_F    	; F
	s_ret
Snd_3f_5be7:
	s_deflen 7
	s_instr 10
	s_note_l SC_F, 14	; F dur=14
	s_instr 12
	s_note_l SC_C, 14	; C dur=14
	s_instr 10
	s_note SC_C    	; C
	s_note SC_C    	; C
	s_instr 12
	s_note_l SC_C, 14	; C dur=14
	s_instr 10
	s_note SC_C    	; C
	s_note SC_C    	; C
	s_instr 12
	s_note SC_C    	; C
	s_note SC_C    	; C
	s_instr 10
	s_note SC_C    	; C
	s_note SC_C    	; C
	s_instr 12
	s_note_l SC_C, 14	; C dur=14
	s_ret
Snd_3f_5c0a:	; unused/dead pattern
	s_deflen 14
	s_instr 10
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_instr 14
	s_note SC_F    	; F
	s_instr 10
	s_note_l SC_F, 21	; F dur=21
	s_note_l SC_F, 14	; F dur=14
	s_note_l SC_F, 7	; F dur=7
	s_instr 14
	s_note SC_F    	; F
	s_instr 10
	s_note SC_F    	; F
	s_ret
	s_deflen 14
	s_instr 14
	s_note SC_F    	; F
	s_note SC_REST 	; rest
	s_deflen 7
	s_instr 14
	s_note SC_F    	; F
	s_instr 10
	s_note_l SC_F, 21	; F dur=21
	s_instr 14
	s_note SC_F    	; F
	s_instr 10
	s_note_l SC_F, 14	; F dur=14
	s_note_l SC_F, 14	; F dur=14
	s_instr 14
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_ret
Snd_3f_5c40:
	s_deflen 14
	s_instr 14
	s_note_l SC_F, 28	; F dur=28
	s_note SC_F    	; F
	s_deflen 7
	s_instr 10
	s_note SC_C    	; C
	s_instr 14
	s_note_l SC_F, 14	; F dur=14
	s_instr 10
	s_note SC_F    	; F
	s_instr 14
	s_note SC_F    	; F
	s_instr 10
	s_note SC_C    	; C
	s_instr 14
	s_note_l SC_F, 14	; F dur=14
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_ret
Snd_3f_5c60:
	s_deflen 14
	s_instr 10
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_instr 14
	s_note SC_F    	; F
	s_instr 10
	s_note_l SC_C, 7	; C dur=7
	s_instr 10
	s_note SC_F    	; F
	s_deflen 7
	s_note SC_C    	; C
	s_note SC_F    	; F
	s_note SC_C    	; C
	s_instr 14
	s_note_l SC_F, 14	; F dur=14
	s_instr 10
	s_note SC_F    	; F
	s_note SC_C    	; C
	s_ret
Snd_3f_5c7e:	; unused/dead pattern
	s_deflen 7
	s_instr 10
	s_note_l SC_F, 14	; F dur=14
	s_instr 12
	s_note_l SC_C, 14	; C dur=14
	s_instr 10
	s_note SC_C    	; C
	s_note SC_C    	; C
	s_instr 12
	s_note_l SC_C, 14	; C dur=14
	s_instr 10
	s_note SC_C    	; C
	s_instr 12
	s_note_l SC_C, 14	; C dur=14
	s_instr 10
	s_note SC_C    	; C
	s_note SC_C    	; C
	s_instr 12
	s_note SC_C    	; C
	s_instr 10
	s_note_l SC_F, 14	; F dur=14
	s_ret
