; Sound id $2b (BGM) -- bonus stage (tentative)
; Bank $3f, ROM $60bf-$660c. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "BGM - $2b", ROMX

; ===== sound id $2b =====
Snd_3f_60bf:
	s_chan $f0, Snd_3f_60cb
	s_chan $f0, Snd_3f_6307
	s_chan $f0, Snd_3f_63d6
	s_chan $f0, Snd_3f_656d
Snd_3f_60cb:
	s_pitchenv 0
	s_set10 0
Snd_3f_60cf:
	s_dutyenv 2
	s_call Snd_3f_6100
	s_call Snd_3f_6124
	s_call Snd_3f_6146
	s_call Snd_3f_6170
	s_call Snd_3f_6195
	s_call Snd_3f_61c3
	s_dutyenv 3
	s_call Snd_3f_61dc
	s_call Snd_3f_6204
	s_call Snd_3f_622d
	s_call Snd_3f_6255
	s_call Snd_3f_6279
	s_call Snd_3f_629e
	s_call Snd_3f_62c1
	s_call Snd_3f_62f3
	s_goto Snd_3f_60cf
Snd_3f_6100:
	s_instr 0
	s_oct 4	; block 3
	s_note_l SC_REST, 14	; rest dur=14
	s_oct 3	; block 2
	s_note_l SC_G, 6	; G dur=6
	s_note_l SC_A, 14	; A dur=14
	s_oct 4	; block 3
	s_note_l SC_C, 6	; C dur=6
	s_note_l SC_DS, 14	; D# dur=14
	s_note_l SC_E, 6	; E dur=6
	s_note_l SC_REST, 14	; rest dur=14
	s_oct 3	; block 2
	s_note_l SC_G, 6	; G dur=6
	s_oct 4	; block 3
	s_note_l SC_C, 14	; C dur=14
	s_oct 3	; block 2
	s_note_l SC_G, 6	; G dur=6
	s_oct 4	; block 3
	s_note_l SC_DS, 14	; D# dur=14
	s_note_l SC_E, 6	; E dur=6
	s_note_l SC_REST, 40	; rest dur=40
	s_ret
Snd_3f_6124:
	s_note_l SC_REST, 14	; rest dur=14
	s_oct 3	; block 2
	s_note_l SC_G, 6	; G dur=6
	s_note_l SC_A, 14	; A dur=14
	s_oct 4	; block 3
	s_note_l SC_C, 6	; C dur=6
	s_note_l SC_DS, 14	; D# dur=14
	s_note_l SC_E, 6	; E dur=6
	s_note_l SC_REST, 14	; rest dur=14
	s_note_l SC_C, 6	; C dur=6
	s_note_l SC_REST, 14	; rest dur=14
	s_note_l SC_G, 6	; G dur=6
	s_note_l SC_FS, 14	; F# dur=14
	s_note_l SC_G, 6	; G dur=6
	s_note_l SC_DS, 14	; D# dur=14
	s_note_l SC_C, 20	; C dur=20
	s_oct 3	; block 2
	s_note_l SC_A, 6	; A dur=6
	s_ret
Snd_3f_6146:
	s_note_l SC_REST, 14	; rest dur=14
	s_instr 0
	s_note_l SC_G, 6	; G dur=6
	s_note_l SC_A, 14	; A dur=14
	s_oct 4	; block 3
	s_note_l SC_C, 6	; C dur=6
	s_note_l SC_DS, 14	; D# dur=14
	s_note_l SC_E, 6	; E dur=6
	s_note_l SC_REST, 14	; rest dur=14
	s_oct 3	; block 2
	s_note_l SC_A, 6	; A dur=6
	s_oct 4	; block 3
	s_note_l SC_A, 14	; A dur=14
	s_instr 5
	s_note_l SC_A, 6	; A dur=6
	s_instr 0
	s_note_l SC_GS, 14	; G# dur=14
	s_note_l SC_G, 13	; G dur=13
	s_note_l SC_REST, 7	; rest dur=7
	s_note_l SC_G, 13	; G dur=13
	s_note_l SC_F, 7	; F dur=7
	s_note_l SC_DS, 6	; D# dur=6
	s_ret
Snd_3f_6170:
	s_note_l SC_E, 30	; E dur=30
	s_note_l SC_REST, 4	; rest dur=4
	s_note_l SC_E, 6	; E dur=6
	s_note_l SC_REST, 14	; rest dur=14
	s_instr 0
	s_note_l SC_C, 6	; C dur=6
	s_instr 4
	s_note_l SC_C, 6	; C dur=6
	s_note_l SC_REST, 14	; rest dur=14
	s_instr 0
	s_note_l SC_C, 20	; C dur=20
	s_instr 4
	s_note_l SC_C, 14	; C dur=14
	s_instr 0
	s_note_l SC_C, 6	; C dur=6
	s_instr 4
	s_note_l SC_C, 6	; C dur=6
	s_note_l SC_REST, 34	; rest dur=34
	s_ret
Snd_3f_6195:
	s_instr 0
	s_note_l SC_D, 14	; D dur=14
	s_note_l SC_F, 6	; F dur=6
	s_note_l SC_REST, 14	; rest dur=14
	s_note_l SC_D, 6	; D dur=6
	s_oct 3	; block 2
	s_note_l SC_G, 14	; G dur=14
	s_instr 5
	s_note_l SC_G, 6	; G dur=6
	s_oct 4	; block 3
	s_instr 0
	s_note_l SC_D, 14	; D dur=14
	s_note_l SC_DS, 6	; D# dur=6
	s_note_l SC_REST, 14	; rest dur=14
	s_note_l SC_DS, 6	; D# dur=6
	s_note_l SC_D, 14	; D dur=14
	s_note_l SC_REST, 6	; rest dur=6
	s_note_l SC_C, 13	; C dur=13
	s_note_l SC_REST, 1	; rest dur=1
	s_note_l SC_C, 6	; C dur=6
	s_oct 3	; block 2
	s_note_l SC_AS, 14	; A# dur=14
	s_oct 4	; block 3
	s_note_l SC_C, 6	; C dur=6
	s_keyon
	s_ret
Snd_3f_61c3:
	s_oct 4	; block 3
	s_note_l SC_C, 13	; C dur=13
	s_note_l SC_C, 7	; C dur=7
	s_keyon
	s_deflen 40
	s_note_l SC_C, 20	; C dur=20
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_note_l SC_REST, 13	; rest dur=13
	s_note_l SC_B, 7	; B dur=7
	s_keyon
	s_deflen 10
	s_note SC_B    	; B
	s_instr 4
	s_note SC_B    	; B
	s_ret
Snd_3f_61dc:
	s_oct 4	; block 3
	s_deflen 10
	s_note SC_REST 	; rest
	s_note SC_REST 	; rest
	s_instr 1
	s_note SC_G    	; G
	s_instr 5
	s_note SC_G    	; G
	s_instr 1
	s_note SC_G    	; G
	s_instr 5
	s_note SC_G    	; G
	s_instr 1
	s_note SC_G    	; G
	s_instr 5
	s_note SC_G    	; G
	s_instr 1
	s_note_l SC_G, 14	; G dur=14
	s_note_l SC_C, 6	; C dur=6
	s_note_l SC_REST, 14	; rest dur=14
	s_note_l SC_C, 6	; C dur=6
	s_instr 5
	s_note_l SC_C, 6	; C dur=6
	s_note_l SC_REST, 34	; rest dur=34
	s_ret
Snd_3f_6204:
	s_deflen 10
	s_note SC_REST 	; rest
	s_note SC_REST 	; rest
	s_instr 1
	s_note SC_G    	; G
	s_instr 5
	s_note SC_G    	; G
	s_instr 1
	s_note SC_G    	; G
	s_instr 5
	s_note SC_G    	; G
	s_instr 1
	s_note SC_G    	; G
	s_instr 5
	s_note SC_G    	; G
	s_instr 1
	s_note_l SC_AS, 14	; A# dur=14
	s_note_l SC_B, 6	; B dur=6
	s_note_l SC_C, 13	; C dur=13
	s_note_l SC_REST, 1	; rest dur=1
	s_note_l SC_C, 6	; C dur=6
	s_instr 5
	s_note_l SC_C, 6	; C dur=6
	s_note_l SC_REST, 34	; rest dur=34
	s_ret
Snd_3f_622d:
	s_deflen 10
	s_note SC_REST 	; rest
	s_note SC_REST 	; rest
	s_instr 1
	s_note SC_G    	; G
	s_instr 5
	s_note SC_G    	; G
	s_instr 1
	s_note_l SC_G, 13	; G dur=13
	s_note_l SC_REST, 1	; rest dur=1
	s_note_l SC_G, 20	; G dur=20
	s_instr 5
	s_note_l SC_G, 6	; G dur=6
	s_instr 1
	s_note_l SC_G, 14	; G dur=14
	s_note_l SC_GS, 6	; G# dur=6
	s_note_l SC_A, 14	; A dur=14
	s_note_l SC_DS, 20	; D# dur=20
	s_note_l SC_D, 6	; D dur=6
	s_note_l SC_C, 14	; C dur=14
	s_oct 3	; block 2
	s_note_l SC_A, 6	; A dur=6
	s_ret
Snd_3f_6255:
	s_oct 4	; block 3
	s_note_l SC_E, 30	; E dur=30
	s_instr 5
	s_note_l SC_E, 4	; E dur=4
	s_instr 1
	s_note_l SC_G, 40	; G dur=40
	s_instr 3
	s_note_l SC_G, 6	; G dur=6
	s_instr 1
	s_note_l SC_C, 20	; C dur=20
	s_instr 4
	s_note_l SC_C, 14	; C dur=14
	s_instr 1
	s_note_l SC_C, 6	; C dur=6
	s_instr 4
	s_note_l SC_C, 6	; C dur=6
	s_note_l SC_REST, 14	; rest dur=14
	s_note_l SC_REST, 20	; rest dur=20
	s_ret
Snd_3f_6279:
	s_note_l SC_REST, 14	; rest dur=14
	s_instr 1
	s_note_l SC_D, 6	; D dur=6
	s_keyon
	s_note_l SC_D, 14	; D dur=14
	s_note_l SC_D, 6	; D dur=6
	s_instr 1
	s_note_l SC_D, 14	; D dur=14
	s_note_l SC_E, 6	; E dur=6
	s_note_l SC_REST, 14	; rest dur=14
	s_note_l SC_F, 6	; F dur=6
	s_keyon
	s_note_l SC_F, 14	; F dur=14
	s_note_l SC_E, 6	; E dur=6
	s_note_l SC_G, 14	; G dur=14
	s_note_l SC_A, 6	; A dur=6
	s_note_l SC_DS, 14	; D# dur=14
	s_note_l SC_D, 6	; D dur=6
	s_note_l SC_C, 20	; C dur=20
	s_ret
Snd_3f_629e:
	s_note_l SC_REST, 20	; rest dur=20
	s_note_l SC_C, 14	; C dur=14
	s_note_l SC_C, 6	; C dur=6
	s_instr 1
	s_note_l SC_C, 14	; C dur=14
	s_note_l SC_D, 6	; D dur=6
	s_note_l SC_REST, 14	; rest dur=14
	s_note_l SC_DS, 6	; D# dur=6
	s_keyon
	s_note_l SC_DS, 14	; D# dur=14
	s_note_l SC_F, 6	; F dur=6
	s_note_l SC_FS, 14	; F# dur=14
	s_note_l SC_F, 6	; F dur=6
	s_note_l SC_F, 14	; F dur=14
	s_note_l SC_DS, 6	; D# dur=6
	s_note_l SC_G, 14	; G dur=14
	s_oct 3	; block 2
	s_note_l SC_AS, 6	; A# dur=6
	s_ret
Snd_3f_62c1:
	s_oct 4	; block 3
	s_deflen 10
	s_instr 1
	s_note SC_C    	; C
	s_instr 5
	s_note SC_C    	; C
	s_instr 1
	s_note SC_C    	; C
	s_instr 5
	s_note SC_C    	; C
	s_instr 1
	s_note_l SC_C, 14	; C dur=14
	s_instr 1
	s_note_l SC_C, 6	; C dur=6
	s_instr 4
	s_note_l SC_C, 6	; C dur=6
	s_note_l SC_REST, 14	; rest dur=14
	s_instr 1
	s_note_l SC_C, 20	; C dur=20
	s_instr 4
	s_note_l SC_C, 14	; C dur=14
	s_instr 1
	s_note_l SC_C, 6	; C dur=6
	s_instr 4
	s_note_l SC_C, 6	; C dur=6
	s_note_l SC_REST, 14	; rest dur=14
	s_note_l SC_REST, 20	; rest dur=20
	s_ret
Snd_3f_62f3:
	s_oct 4	; block 3
	s_note_l SC_REST, 13	; rest dur=13
	s_instr 1
	s_note_l SC_C, 7	; C dur=7
	s_keyon
	s_deflen 20
	s_note SC_C    	; C
	s_note_l SC_C, 40	; C dur=40
	s_oct 3	; block 2
	s_note_l SC_B, 60	; B dur=60
	s_instr 4
	s_note SC_B    	; B
	s_ret
Snd_3f_6307:
	s_pitchenv 0
	s_set10 0
	s_dutyenv 2
Snd_3f_630d:
	s_call Snd_3f_633a
	s_call Snd_3f_633a
	s_call Snd_3f_6356
	s_call Snd_3f_633a
	s_call Snd_3f_638d
	s_call Snd_3f_63bc
	s_call Snd_3f_633a
	s_call Snd_3f_633a
	s_call Snd_3f_6356
	s_call Snd_3f_633a
	s_call Snd_3f_6371
	s_call Snd_3f_6356
	s_call Snd_3f_633a
	s_call Snd_3f_63a9
	s_goto Snd_3f_630d
Snd_3f_633a:
	s_oct 3	; block 2
	s_deflen 10
	s_note SC_REST 	; rest
	s_note SC_REST 	; rest
	s_instr 0
	s_note SC_AS   	; A#
	s_note SC_REST 	; rest
	s_note_l SC_REST, 14	; rest dur=14
	s_note_l SC_AS, 6	; A# dur=6
	s_note_l SC_REST, 20	; rest dur=20
	s_note_l SC_AS, 20	; A# dur=20
	s_instr 4
	s_note_l SC_AS, 14	; A# dur=14
	s_instr 0
	s_note_l SC_AS, 6	; A# dur=6
	s_note_l SC_REST, 40	; rest dur=40
	s_ret
Snd_3f_6356:
	s_deflen 10
	s_note SC_REST 	; rest
	s_note SC_REST 	; rest
	s_instr 0
	s_note SC_A    	; A
	s_note SC_REST 	; rest
	s_note_l SC_REST, 14	; rest dur=14
	s_note_l SC_A, 6	; A dur=6
	s_note_l SC_REST, 20	; rest dur=20
	s_note_l SC_A, 20	; A dur=20
	s_instr 4
	s_note_l SC_A, 14	; A dur=14
	s_instr 0
	s_note_l SC_A, 6	; A dur=6
	s_note_l SC_REST, 40	; rest dur=40
	s_ret
Snd_3f_6371:
	s_oct 3	; block 2
	s_deflen 10
	s_note SC_REST 	; rest
	s_note SC_REST 	; rest
	s_instr 0
	s_note SC_B    	; B
	s_note SC_REST 	; rest
	s_note_l SC_REST, 14	; rest dur=14
	s_note_l SC_B, 6	; B dur=6
	s_note_l SC_REST, 20	; rest dur=20
	s_note_l SC_B, 20	; B dur=20
	s_instr 4
	s_note_l SC_B, 14	; B dur=14
	s_instr 0
	s_note_l SC_B, 6	; B dur=6
	s_note_l SC_REST, 40	; rest dur=40
	s_ret
Snd_3f_638d:
	s_oct 3	; block 2
	s_deflen 10
	s_note SC_REST 	; rest
	s_note SC_REST 	; rest
	s_instr 0
	s_note SC_B    	; B
	s_note SC_REST 	; rest
	s_note_l SC_REST, 14	; rest dur=14
	s_note_l SC_B, 6	; B dur=6
	s_note_l SC_REST, 20	; rest dur=20
	s_note_l SC_A, 20	; A dur=20
	s_instr 4
	s_note_l SC_A, 14	; A dur=14
	s_instr 0
	s_note_l SC_A, 6	; A dur=6
	s_note_l SC_REST, 40	; rest dur=40
	s_ret
Snd_3f_63a9:
	s_oct 3	; block 2
	s_note_l SC_REST, 13	; rest dur=13
	s_instr 0
	s_note_l SC_AS, 7	; A# dur=7
	s_keyon
	s_deflen 20
	s_note SC_AS   	; A#
	s_note_l SC_A, 40	; A dur=40
	s_note_l SC_G, 60	; G dur=60
	s_instr 4
	s_note SC_G    	; G
	s_ret
Snd_3f_63bc:
	s_oct 3	; block 2
	s_note_l SC_REST, 13	; rest dur=13
	s_instr 0
	s_note_l SC_AS, 7	; A# dur=7
	s_keyon
	s_deflen 40
	s_note_l SC_AS, 20	; A# dur=20
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_note_l SC_REST, 13	; rest dur=13
	s_note_l SC_G, 7	; G dur=7
	s_keyon
	s_deflen 10
	s_note SC_G    	; G
	s_instr 4
	s_note SC_G    	; G
	s_ret
Snd_3f_63d6:
	s_pitchenv 0
	s_set10 0
Snd_3f_63da:
	s_call Snd_3f_6407
	s_call Snd_3f_6407
	s_call Snd_3f_643d
	s_call Snd_3f_6407
	s_call Snd_3f_64d7
	s_call Snd_3f_653c
	s_call Snd_3f_6407
	s_call Snd_3f_6407
	s_call Snd_3f_643d
	s_call Snd_3f_6407
	s_call Snd_3f_6470
	s_call Snd_3f_64a4
	s_call Snd_3f_6407
	s_call Snd_3f_650c
	s_goto Snd_3f_63da
Snd_3f_6407:
	s_wave 2
	s_deflen 10
	s_oct 3	; block 2
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_instr 20
	s_note SC_E    	; E
	s_instr 19
	s_note SC_E    	; E
	s_instr 20
	s_note SC_G    	; G
	s_instr 19
	s_note SC_G    	; G
	s_instr 20
	s_note SC_A    	; A
	s_instr 19
	s_note SC_A    	; A
	s_instr 20
	s_note SC_AS   	; A#
	s_instr 19
	s_note SC_AS   	; A#
	s_instr 20
	s_note SC_A    	; A
	s_instr 19
	s_note SC_A    	; A
	s_instr 20
	s_note SC_G    	; G
	s_instr 19
	s_note SC_G    	; G
	s_instr 20
	s_note SC_E    	; E
	s_instr 19
	s_note SC_E    	; E
	s_ret
Snd_3f_643d:
	s_instr 20
	s_note SC_F    	; F
	s_instr 19
	s_note SC_F    	; F
	s_instr 20
	s_note SC_A    	; A
	s_instr 19
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_instr 20
	s_note SC_D    	; D
	s_instr 19
	s_note SC_D    	; D
	s_instr 20
	s_note SC_DS   	; D#
	s_instr 19
	s_note SC_DS   	; D#
	s_instr 20
	s_note SC_D    	; D
	s_instr 19
	s_note SC_D    	; D
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_instr 20
	s_note SC_A    	; A
	s_instr 19
	s_note SC_A    	; A
	s_ret
Snd_3f_6470:
	s_oct 3	; block 2
	s_instr 20
	s_note SC_G    	; G
	s_instr 19
	s_note SC_G    	; G
	s_instr 20
	s_note SC_B    	; B
	s_instr 19
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_instr 20
	s_note SC_D    	; D
	s_instr 19
	s_note SC_D    	; D
	s_instr 20
	s_note SC_E    	; E
	s_instr 19
	s_note SC_E    	; E
	s_instr 20
	s_note SC_F    	; F
	s_instr 19
	s_note SC_F    	; F
	s_instr 20
	s_note SC_E    	; E
	s_instr 19
	s_note SC_E    	; E
	s_instr 20
	s_note SC_D    	; D
	s_instr 19
	s_note SC_D    	; D
	s_oct 3	; block 2
	s_instr 20
	s_note SC_G    	; G
	s_instr 19
	s_note SC_G    	; G
	s_ret
Snd_3f_64a4:
	s_instr 20
	s_note SC_F    	; F
	s_instr 19
	s_note SC_F    	; F
	s_instr 20
	s_note SC_A    	; A
	s_instr 19
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_instr 20
	s_note SC_D    	; D
	s_instr 19
	s_note SC_D    	; D
	s_instr 20
	s_note SC_DS   	; D#
	s_instr 19
	s_note SC_DS   	; D#
	s_instr 20
	s_note SC_D    	; D
	s_instr 19
	s_note SC_D    	; D
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_instr 20
	s_note SC_A    	; A
	s_instr 19
	s_note SC_A    	; A
	s_ret
Snd_3f_64d7:
	s_oct 3	; block 2
	s_instr 20
	s_note SC_G    	; G
	s_instr 19
	s_note SC_G    	; G
	s_instr 20
	s_note SC_B    	; B
	s_instr 19
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_instr 20
	s_note SC_D    	; D
	s_instr 19
	s_note SC_D    	; D
	s_instr 20
	s_note SC_CS   	; C#
	s_instr 19
	s_note SC_CS   	; C#
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_instr 20
	s_note SC_F    	; F
	s_instr 19
	s_note SC_F    	; F
	s_oct 4	; block 3
	s_instr 20
	s_note SC_F    	; F
	s_instr 19
	s_note SC_F    	; F
	s_instr 20
	s_note SC_DS   	; D#
	s_instr 19
	s_note SC_DS   	; D#
	s_ret
Snd_3f_650c:
	s_instr 20
	s_note_l SC_C, 13	; C dur=13
	s_note_l SC_E, 7	; E dur=7
	s_keyon
	s_deflen 10
	s_note SC_E    	; E
	s_instr 19
	s_note SC_E    	; E
	s_instr 20
	s_note SC_F    	; F
	s_instr 19
	s_note SC_F    	; F
	s_instr 20
	s_note SC_FS   	; F#
	s_instr 19
	s_note SC_FS   	; F#
	s_instr 20
	s_note_l SC_G, 20	; G dur=20
	s_instr 20
	s_note SC_A    	; A
	s_instr 19
	s_note SC_A    	; A
	s_instr 20
	s_note SC_AS   	; A#
	s_instr 19
	s_note SC_AS   	; A#
	s_instr 20
	s_note SC_B    	; B
	s_instr 19
	s_note SC_B    	; B
	s_ret
Snd_3f_653c:
	s_instr 20
	s_note_l SC_C, 13	; C dur=13
	s_oct 3	; block 2
	s_note_l SC_C, 7	; C dur=7
	s_keyon
	s_deflen 10
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_instr 20
	s_note SC_E    	; E
	s_instr 19
	s_note SC_E    	; E
	s_instr 20
	s_note SC_F    	; F
	s_instr 19
	s_note SC_F    	; F
	s_instr 20
	s_note_l SC_G, 20	; G dur=20
	s_instr 20
	s_note SC_A    	; A
	s_instr 19
	s_note SC_A    	; A
	s_instr 20
	s_note SC_AS   	; A#
	s_instr 19
	s_note SC_AS   	; A#
	s_instr 20
	s_note SC_B    	; B
	s_instr 19
	s_note SC_B    	; B
	s_ret
Snd_3f_656d:
	s_pitchenv 0
	s_deflen 20
	s_oct 1	; block 0
	s_set10 0
Snd_3f_6574:
	s_call Snd_3f_65a1
	s_call Snd_3f_65a1
	s_call Snd_3f_65a1
	s_call Snd_3f_65a1
	s_call Snd_3f_65a1
	s_call Snd_3f_65ef
	s_call Snd_3f_65a1
	s_call Snd_3f_65a1
	s_call Snd_3f_65a1
	s_call Snd_3f_65a1
	s_call Snd_3f_65a1
	s_call Snd_3f_65a1
	s_call Snd_3f_65a1
	s_call Snd_3f_65d3
	s_goto Snd_3f_6574
Snd_3f_65a1:
	s_instr 13
	s_note_l SC_C, 20	; C dur=20
	s_deflen 7
	s_instr 14
	s_note SC_D    	; D
	s_note SC_REST 	; rest
	s_note_l SC_D, 6	; D dur=6
	s_instr 13
	s_note_l SC_C, 20	; C dur=20
	s_deflen 7
	s_instr 14
	s_note SC_D    	; D
	s_note SC_REST 	; rest
	s_note_l SC_D, 6	; D dur=6
	s_instr 13
	s_note_l SC_C, 20	; C dur=20
	s_deflen 7
	s_instr 14
	s_note SC_D    	; D
	s_note SC_REST 	; rest
	s_note_l SC_D, 6	; D dur=6
	s_deflen 14
	s_instr 13
	s_note SC_C    	; C
	s_instr 14
	s_note_l SC_D, 20	; D dur=20
	s_instr 14
	s_note_l SC_D, 6	; D dur=6
	s_ret
Snd_3f_65d3:
	s_instr 14
	s_note_l SC_C, 13	; C dur=13
	s_instr 11
	s_note_l SC_D, 27	; D dur=27
	s_deflen 20
	s_note SC_D    	; D
	s_note SC_REST 	; rest
	s_note SC_D    	; D
	s_note_l SC_REST, 14	; rest dur=14
	s_instr 13
	s_note_l SC_C, 14	; C dur=14
	s_note_l SC_C, 13	; C dur=13
	s_instr 11
	s_note_l SC_D, 13	; D dur=13
	s_note_l SC_D, 6	; D dur=6
	s_ret
Snd_3f_65ef:
	s_instr 14
	s_note_l SC_D, 13	; D dur=13
	s_instr 11
	s_note_l SC_D, 27	; D dur=27
	s_deflen 20
	s_note SC_D    	; D
	s_note SC_REST 	; rest
	s_note SC_D    	; D
	s_note_l SC_REST, 14	; rest dur=14
	s_instr 14
	s_note_l SC_D, 14	; D dur=14
	s_note_l SC_D, 13	; D dur=13
	s_note_l SC_REST, 7	; rest dur=7
	s_instr 11
	s_note_l SC_D, 6	; D dur=6
	s_note_l SC_D, 6	; D dur=6
	s_ret
