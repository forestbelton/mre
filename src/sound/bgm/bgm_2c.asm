; Sound id $2c (BGM) -- ?
; Bank $3f, ROM $660d-$6a2e. INCLUDEd by sound/bank0.asm into its $4b00 section.

; ===== sound id $2c =====
Snd_3f_660d:
	s_chan $f0, Snd_3f_6619
	s_chan $f0, Snd_3f_6775
	s_chan $f0, Snd_3f_6815
	s_chan $f0, Snd_3f_698a
Snd_3f_6619:
	s_pitchenv 0
	s_set10 0
Snd_3f_661d:
	s_dutyenv 5
	s_call Snd_3f_6665
	s_call Snd_3f_6684
	s_call Snd_3f_6665
	s_call Snd_3f_66a2
	s_call Snd_3f_6665
	s_call Snd_3f_6684
	s_call Snd_3f_6665
	s_call Snd_3f_66a2
	s_dutyenv 2
	s_call Snd_3f_66c0
	s_call Snd_3f_66d2
	s_call Snd_3f_6662
	s_call Snd_3f_66df
	s_call Snd_3f_66f7
	s_call Snd_3f_6706
	s_call Snd_3f_6662
	s_call Snd_3f_6711
	s_dutyenv 0
	s_call Snd_3f_6722
	s_call Snd_3f_6743
	s_call Snd_3f_6722
	s_call Snd_3f_675c
	s_goto Snd_3f_661d
Snd_3f_6662:
	s_note_l SC_REST, 112	; rest dur=112
	s_ret
Snd_3f_6665:
	s_instr 1
	s_deflen 7
	s_oct 4	; block 3
	s_note_l SC_C, 14	; C dur=14
	s_note_l SC_G, 14	; G dur=14
	s_instr 2
	s_note SC_G    	; G
	s_instr 1
	s_note_l SC_FS, 14	; F# dur=14
	s_instr 2
	s_note SC_FS   	; F#
	s_instr 1
	s_note_l SC_F, 21	; F dur=21
	s_note_l SC_DS, 21	; D# dur=21
	s_oct 3	; block 2
	s_instr 3
	s_note_l SC_AS, 14	; A# dur=14
	s_ret
Snd_3f_6684:
	s_instr 1
	s_deflen 7
	s_oct 4	; block 3
	s_note_l SC_C, 14	; C dur=14
	s_note_l SC_G, 14	; G dur=14
	s_instr 2
	s_note SC_G    	; G
	s_instr 1
	s_note_l SC_FS, 14	; F# dur=14
	s_instr 2
	s_note SC_FS   	; F#
	s_instr 1
	s_note_l SC_F, 21	; F dur=21
	s_note_l SC_DS, 21	; D# dur=21
	s_instr 3
	s_note_l SC_F, 14	; F dur=14
	s_ret
Snd_3f_66a2:
	s_instr 1
	s_deflen 7
	s_oct 4	; block 3
	s_instr 1
	s_note SC_C    	; C
	s_note SC_FS   	; F#
	s_note SC_G    	; G
	s_note SC_AS   	; A#
	s_instr 2
	s_note SC_AS   	; A#
	s_instr 1
	s_note_l SC_AS, 14	; A# dur=14
	s_instr 2
	s_note SC_AS   	; A#
	s_instr 1
	s_note_l SC_AS, 21	; A# dur=21
	s_note_l SC_GS, 21	; G# dur=21
	s_note_l SC_A, 14	; A dur=14
	s_ret
Snd_3f_66c0:
	s_instr 1
	s_deflen 21
	s_oct 4	; block 3
	s_note SC_GS   	; G#
	s_note SC_A    	; A
	s_deflen 7
	s_note_l SC_GS, 28	; G# dur=28
	s_note_l SC_REST, 14	; rest dur=14
	s_note SC_DS   	; D#
	s_note_l SC_E, 14	; E dur=14
	s_note SC_F    	; F
	s_ret
Snd_3f_66d2:
	s_note SC_REST 	; rest
	s_note SC_GS   	; G#
	s_note SC_DS   	; D#
	s_note_l SC_A, 21	; A dur=21
	s_note_l SC_GS, 28	; G# dur=28
	s_deflen 14
	s_note SC_FS   	; F#
	s_note_l SC_GS, 28	; G# dur=28
	s_ret
Snd_3f_66df:
	s_oct 4	; block 3
	s_note SC_REST 	; rest
	s_instr 1
	s_note SC_AS   	; A#
	s_deflen 7
	s_note SC_REST 	; rest
	s_instr 1
	s_note SC_A    	; A
	s_instr 2
	s_note SC_A    	; A
	s_instr 1
	s_note SC_A    	; A
	s_deflen 14
	s_note SC_GS   	; G#
	s_note SC_FS   	; F#
	s_note SC_CS   	; C#
	s_note SC_DS   	; D#
	s_ret
Snd_3f_66f7:
	s_instr 1
	s_deflen 14
	s_oct 4	; block 3
	s_note_l SC_D, 21	; D dur=21
	s_note_l SC_DS, 21	; D# dur=21
	s_note_l SC_F, 28	; F dur=28
	s_note SC_FS   	; F#
	s_note SC_F    	; F
	s_note SC_DS   	; D#
	s_ret
Snd_3f_6706:
	s_note SC_A    	; A
	s_note_l SC_DS, 7	; D# dur=7
	s_note_l SC_GS, 21	; G# dur=21
	s_note_l SC_FS, 28	; F# dur=28
	s_note SC_GS   	; G#
	s_note SC_A    	; A
	s_note SC_FS   	; F#
	s_ret
Snd_3f_6711:
	s_oct 4	; block 3
	s_deflen 14
	s_note SC_REST 	; rest
	s_instr 1
	s_note SC_AS   	; A#
	s_note_l SC_REST, 7	; rest dur=7
	s_note_l SC_A, 21	; A dur=21
	s_note_l SC_GS, 21	; G# dur=21
	s_note_l SC_FS, 21	; F# dur=21
	s_note SC_A    	; A
	s_ret
Snd_3f_6722:
	s_instr 2
	s_deflen 7
	s_oct 4	; block 3
	s_note SC_GS   	; G#
	s_oct 5	; block 4
	s_note SC_GS   	; G#
	s_oct 4	; block 3
	s_note SC_GS   	; G#
	s_note SC_GS   	; G#
	s_oct 5	; block 4
	s_note SC_GS   	; G#
	s_oct 4	; block 3
	s_note SC_GS   	; G#
	s_note SC_GS   	; G#
	s_oct 5	; block 4
	s_note SC_GS   	; G#
	s_oct 4	; block 3
	s_note SC_GS   	; G#
	s_note SC_GS   	; G#
	s_oct 5	; block 4
	s_note SC_GS   	; G#
	s_oct 4	; block 3
	s_note SC_GS   	; G#
	s_oct 4	; block 3
	s_note SC_GS   	; G#
	s_oct 5	; block 4
	s_note SC_GS   	; G#
	s_oct 4	; block 3
	s_note SC_GS   	; G#
	s_note SC_GS   	; G#
	s_ret
Snd_3f_6743:
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_oct 5	; block 4
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_note SC_AS   	; A#
	s_note SC_A    	; A
	s_oct 5	; block 4
	s_note SC_A    	; A
	s_note SC_DS   	; D#
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_note SC_FS   	; F#
	s_oct 5	; block 4
	s_note SC_A    	; A
	s_oct 5	; block 4
	s_note SC_A    	; A
	s_note SC_AS   	; A#
	s_oct 5	; block 4
	s_note SC_A    	; A
	s_note SC_DS   	; D#
	s_note SC_A    	; A
	s_note SC_AS   	; A#
	s_ret
Snd_3f_675c:
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_oct 5	; block 4
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_note SC_AS   	; A#
	s_note SC_A    	; A
	s_oct 5	; block 4
	s_note SC_A    	; A
	s_note SC_DS   	; D#
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_note SC_FS   	; F#
	s_oct 5	; block 4
	s_note SC_A    	; A
	s_oct 5	; block 4
	s_note SC_A    	; A
	s_note SC_AS   	; A#
	s_oct 5	; block 4
	s_note SC_A    	; A
	s_note SC_DS   	; D#
	s_note SC_D    	; D
	s_note SC_CS   	; C#
	s_ret
Snd_3f_6775:
	s_pitchenv 1
	s_deflen 7
	s_set10 0
	s_dutyenv 5
Snd_3f_677d:
	s_call Snd_3f_67bc
	s_call Snd_3f_67bc
	s_call Snd_3f_67bc
	s_call Snd_3f_67d0
	s_call Snd_3f_67bc
	s_call Snd_3f_67bc
	s_call Snd_3f_67bc
	s_call Snd_3f_67d0
	s_call Snd_3f_67e1
	s_call Snd_3f_67e1
	s_call Snd_3f_67fc
	s_call Snd_3f_67fc
	s_call Snd_3f_67e1
	s_call Snd_3f_67e1
	s_call Snd_3f_67fc
	s_call Snd_3f_67fc
	s_call Snd_3f_67e1
	s_call Snd_3f_67fc
	s_call Snd_3f_67e1
	s_call Snd_3f_67fc
	s_goto Snd_3f_677d
Snd_3f_67bc:
	s_instr 1
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_note SC_F    	; F
	s_note SC_FS   	; F#
	s_note SC_G    	; G
	s_note SC_D    	; D
	s_note SC_F    	; F
	s_note SC_FS   	; F#
	s_note SC_G    	; G
	s_note SC_G    	; G
	s_note SC_F    	; F
	s_note SC_FS   	; F#
	s_note SC_G    	; G
	s_note SC_D    	; D
	s_note SC_F    	; F
	s_note SC_FS   	; F#
	s_note SC_G    	; G
	s_ret
Snd_3f_67d0:
	s_instr 1
	s_note SC_G    	; G
	s_note SC_CS   	; C#
	s_note SC_D    	; D
	s_note SC_DS   	; D#
	s_note SC_GS   	; G#
	s_note SC_A    	; A
	s_note SC_FS   	; F#
	s_note SC_G    	; G
	s_note_l SC_F, 21	; F dur=21
	s_note_l SC_DS, 21	; D# dur=21
	s_note_l SC_E, 14	; E dur=14
	s_ret
Snd_3f_67e1:
	s_oct 4	; block 3
	s_instr 2
	s_note_l SC_F, 14	; F dur=14
	s_oct 3	; block 2
	s_note SC_GS   	; G#
	s_note SC_AS   	; A#
	s_oct 4	; block 3
	s_note SC_F    	; F
	s_oct 3	; block 2
	s_note SC_GS   	; G#
	s_note SC_AS   	; A#
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note_l SC_GS, 14	; G# dur=14
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_note SC_AS   	; A#
	s_note SC_GS   	; G#
	s_oct 4	; block 3
	s_note SC_F    	; F
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_note SC_A    	; A
	s_ret
Snd_3f_67fc:
	s_oct 4	; block 3
	s_note_l SC_FS, 14	; F# dur=14
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_FS   	; F#
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_note SC_AS   	; A#
	s_oct 4	; block 3
	s_note_l SC_A, 14	; A dur=14
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_FS   	; F#
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_note SC_AS   	; A#
	s_ret
Snd_3f_6815:
	s_pitchenv 0
	s_deflen 7
	s_set10 0
Snd_3f_681b:
	s_call Snd_3f_685a
	s_call Snd_3f_685a
	s_call Snd_3f_685a
	s_call Snd_3f_6885
	s_call Snd_3f_685a
	s_call Snd_3f_685a
	s_call Snd_3f_685a
	s_call Snd_3f_6885
	s_call Snd_3f_68b1
	s_call Snd_3f_68b1
	s_call Snd_3f_68df
	s_call Snd_3f_68df
	s_call Snd_3f_68b1
	s_call Snd_3f_68b1
	s_call Snd_3f_68df
	s_call Snd_3f_690d
	s_call Snd_3f_6937
	s_call Snd_3f_6961
	s_call Snd_3f_6937
	s_call Snd_3f_6961
	s_goto Snd_3f_681b
Snd_3f_685a:
	s_wave 2
	s_oct 4	; block 3
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_instr 20
	s_note_l SC_C, 14	; C dur=14
	s_instr 19
	s_note SC_C    	; C
	s_instr 20
	s_note_l SC_C, 14	; C dur=14
	s_instr 19
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_instr 20
	s_note_l SC_F, 14	; F dur=14
	s_instr 19
	s_note SC_F    	; F
	s_instr 20
	s_note_l SC_G, 14	; G dur=14
	s_ret
Snd_3f_6885:
	s_wave 2
	s_oct 3	; block 2
	s_instr 20
	s_note SC_G    	; G
	s_instr 19
	s_note SC_G    	; G
	s_instr 20
	s_note SC_G    	; G
	s_instr 19
	s_note SC_G    	; G
	s_note SC_REST 	; rest
	s_instr 20
	s_note_l SC_G, 14	; G dur=14
	s_instr 19
	s_note SC_G    	; G
	s_instr 20
	s_note_l SC_G, 14	; G dur=14
	s_instr 19
	s_note SC_G    	; G
	s_instr 20
	s_note_l SC_G, 14	; G dur=14
	s_instr 19
	s_note SC_G    	; G
	s_instr 20
	s_note SC_G    	; G
	s_instr 19
	s_note SC_G    	; G
	s_ret
Snd_3f_68b1:
	s_wave 2
	s_oct 3	; block 2
	s_instr 20
	s_note_l SC_AS, 14	; A# dur=14
	s_instr 19
	s_note SC_AS   	; A#
	s_instr 20
	s_note SC_AS   	; A#
	s_instr 19
	s_note SC_AS   	; A#
	s_instr 20
	s_note_l SC_AS, 14	; A# dur=14
	s_instr 19
	s_note SC_AS   	; A#
	s_instr 20
	s_note SC_AS   	; A#
	s_instr 19
	s_note SC_AS   	; A#
	s_instr 20
	s_note SC_AS   	; A#
	s_instr 19
	s_note SC_AS   	; A#
	s_instr 20
	s_note SC_AS   	; A#
	s_note SC_AS   	; A#
	s_instr 19
	s_note SC_AS   	; A#
	s_instr 20
	s_note SC_AS   	; A#
	s_ret
Snd_3f_68df:
	s_wave 2
	s_oct 3	; block 2
	s_instr 20
	s_note_l SC_B, 14	; B dur=14
	s_instr 19
	s_note SC_B    	; B
	s_instr 20
	s_note SC_B    	; B
	s_instr 19
	s_note SC_B    	; B
	s_instr 20
	s_note_l SC_B, 14	; B dur=14
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
	s_note SC_B    	; B
	s_instr 19
	s_note SC_B    	; B
	s_instr 20
	s_note SC_B    	; B
	s_ret
Snd_3f_690d:
	s_wave 2
	s_oct 3	; block 2
	s_instr 20
	s_note_l SC_B, 14	; B dur=14
	s_instr 19
	s_note SC_B    	; B
	s_instr 20
	s_note SC_B    	; B
	s_instr 19
	s_note SC_B    	; B
	s_instr 20
	s_note_l SC_B, 14	; B dur=14
	s_instr 19
	s_note SC_B    	; B
	s_instr 20
	s_note_l SC_B, 14	; B dur=14
	s_instr 19
	s_note SC_B    	; B
	s_instr 20
	s_note_l SC_B, 14	; B dur=14
	s_instr 19
	s_note SC_B    	; B
	s_instr 20
	s_note SC_B    	; B
	s_note SC_B    	; B
	s_ret
Snd_3f_6937:
	s_wave 2
	s_oct 3	; block 2
	s_instr 20
	s_note SC_AS   	; A#
	s_instr 19
	s_note SC_AS   	; A#
	s_instr 20
	s_note SC_AS   	; A#
	s_instr 19
	s_note SC_AS   	; A#
	s_note SC_REST 	; rest
	s_instr 20
	s_note_l SC_AS, 14	; A# dur=14
	s_instr 19
	s_note SC_AS   	; A#
	s_instr 20
	s_note_l SC_AS, 14	; A# dur=14
	s_instr 19
	s_note SC_AS   	; A#
	s_instr 20
	s_note_l SC_AS, 14	; A# dur=14
	s_instr 19
	s_note SC_AS   	; A#
	s_instr 20
	s_note_l SC_AS, 14	; A# dur=14
	s_ret
Snd_3f_6961:
	s_instr 20
	s_note SC_B    	; B
	s_instr 19
	s_note SC_B    	; B
	s_instr 20
	s_note SC_B    	; B
	s_instr 19
	s_note SC_B    	; B
	s_note SC_REST 	; rest
	s_instr 20
	s_note_l SC_B, 14	; B dur=14
	s_instr 19
	s_note SC_B    	; B
	s_instr 20
	s_note_l SC_B, 14	; B dur=14
	s_instr 19
	s_note SC_B    	; B
	s_instr 20
	s_note_l SC_B, 14	; B dur=14
	s_instr 19
	s_note SC_B    	; B
	s_instr 20
	s_note SC_B    	; B
	s_instr 19
	s_note SC_B    	; B
	s_ret
Snd_3f_698a:
	s_pitchenv 0
	s_oct 1	; block 0
	s_deflen 7
	s_set10 0
Snd_3f_6991:
	s_call Snd_3f_69d0
	s_call Snd_3f_69d0
	s_call Snd_3f_69d0
	s_call Snd_3f_69d0
	s_call Snd_3f_69d0
	s_call Snd_3f_69d0
	s_call Snd_3f_69d0
	s_call Snd_3f_69d0
	s_call Snd_3f_69ef
	s_call Snd_3f_69ef
	s_call Snd_3f_69ef
	s_call Snd_3f_69ef
	s_call Snd_3f_69ef
	s_call Snd_3f_69ef
	s_call Snd_3f_69ef
	s_call Snd_3f_6a10
	s_call Snd_3f_69d0
	s_call Snd_3f_69d0
	s_call Snd_3f_69d0
	s_call Snd_3f_6a10
	s_goto Snd_3f_6991
Snd_3f_69d0:
	s_instr 10
	s_note SC_F    	; F
	s_note SC_C    	; C
	s_note SC_F    	; F
	s_note SC_C    	; C
	s_instr 14
	s_note SC_F    	; F
	s_instr 10
	s_note SC_F    	; F
	s_note SC_C    	; C
	s_note SC_F    	; F
	s_instr 10
	s_note SC_C    	; C
	s_note SC_C    	; C
	s_note SC_F    	; F
	s_note SC_C    	; C
	s_instr 14
	s_note SC_F    	; F
	s_instr 10
	s_note SC_C    	; C
	s_note SC_F    	; F
	s_instr 14
	s_note SC_F    	; F
	s_ret
Snd_3f_69ef:
	s_instr 10
	s_note_l SC_F, 14	; F dur=14
	s_note SC_C    	; C
	s_instr 14
	s_note_l SC_F, 14	; F dur=14
	s_instr 14
	s_note_l SC_F, 14	; F dur=14
	s_instr 10
	s_note SC_F    	; F
	s_instr 10
	s_note_l SC_F, 14	; F dur=14
	s_instr 14
	s_note_l SC_F, 14	; F dur=14
	s_instr 14
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_instr 10
	s_note_l SC_F, 14	; F dur=14
	s_ret
Snd_3f_6a10:
	s_instr 10
	s_note SC_F    	; F
	s_note SC_C    	; C
	s_note SC_F    	; F
	s_note SC_C    	; C
	s_instr 14
	s_note SC_F    	; F
	s_instr 10
	s_note SC_F    	; F
	s_note SC_C    	; C
	s_note SC_F    	; F
	s_instr 10
	s_note SC_F    	; F
	s_instr 14
	s_note SC_F    	; F
	s_instr 10
	s_note SC_C    	; C
	s_instr 14
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_ret
