; Sound id $36 (BGM) -- rival encounter
; Bank $3e, ROM $62fa-$6469. INCLUDEd by sound/bank1.asm into its $4b00 section.

; ===== sound id $36 =====
Snd_3e_62fa:
	s_chan $f0, Snd_3e_6306
	s_chan $f0, Snd_3e_6394
	s_chan $f0, Snd_3e_63d9
	s_chan $f0, Snd_3e_6411
Snd_3e_6306:
	s_pitchenv 0
	s_instr 1
	s_set10 0
	s_dutyenv 5
Snd_3e_630e:
	s_call Snd_3e_6329
	s_call Snd_3e_6356
	s_call Snd_3e_6329
	s_call Snd_3e_636a
	s_call Snd_3e_6329
	s_call Snd_3e_6356
	s_call Snd_3e_6329
	s_call Snd_3e_637f
	s_goto Snd_3e_630e
Snd_3e_6329:
	s_deflen 8
	s_oct 4	; block 3
	s_instr 1
	s_note_l SC_FS, 4	; F# dur=4
	s_keyon
	s_note_l SC_G, 12	; G dur=12
	s_oct 3	; block 2
	s_instr 1
	s_note SC_G    	; G
	s_instr 4
	s_note SC_G    	; G
	s_oct 3	; block 2
	s_instr 1
	s_note SC_G    	; G
	s_instr 4
	s_note SC_G    	; G
	s_instr 1
	s_note_l SC_G, 24	; G dur=24
	s_instr 4
	s_note SC_G    	; G
	s_instr 1
	s_note SC_G    	; G
	s_instr 4
	s_note SC_G    	; G
	s_oct 4	; block 3
	s_instr 1
	s_note_l SC_D, 16	; D dur=16
	s_note_l SC_G, 16	; G dur=16
	s_ret
Snd_3e_6356:
	s_deflen 16
	s_instr 2
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_note SC_DS   	; D#
	s_instr 3
	s_note SC_DS   	; D#
	s_instr 5
	s_note SC_DS   	; D#
	s_instr 1
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note_l SC_F, 32	; F dur=32
	s_ret
Snd_3e_636a:
	s_deflen 16
	s_instr 2
	s_note SC_F    	; F
	s_oct 5	; block 4
	s_note SC_CS   	; C#
	s_note SC_C    	; C
	s_instr 3
	s_note SC_C    	; C
	s_instr 5
	s_note SC_C    	; C
	s_instr 1
	s_oct 4	; block 3
	s_note SC_AS   	; A#
	s_note SC_A    	; A
	s_note SC_GS   	; G#
	s_ret
Snd_3e_637f:
	s_deflen 16
	s_instr 2
	s_note SC_F    	; F
	s_note SC_C    	; C
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_instr 3
	s_note SC_C    	; C
	s_instr 5
	s_note SC_C    	; C
	s_oct 4	; block 3
	s_instr 1
	s_note SC_F    	; F
	s_note SC_GS   	; G#
	s_note SC_F    	; F
	s_ret
Snd_3e_6394:
	s_deflen 16
	s_pitchenv 1
	s_set10 0
	s_dutyenv 2
Snd_3e_639c:
	s_call Snd_3e_63b7
	s_call Snd_3e_63c2
	s_call Snd_3e_63b7
	s_call Snd_3e_63c2
	s_call Snd_3e_63b7
	s_call Snd_3e_63c2
	s_call Snd_3e_63b7
	s_call Snd_3e_63c8
	s_goto Snd_3e_639c
Snd_3e_63b7:
	s_oct 3	; block 2
	s_deflen 16
	s_instr 1
	s_note_l SC_AS, 96	; A# dur=96
	s_keyon
	s_note SC_AS   	; A#
	s_note SC_A    	; A
	s_ret
Snd_3e_63c2:
	s_note_l SC_GS, 96	; G# dur=96
	s_keyon
	s_note SC_GS   	; G#
	s_note SC_A    	; A
	s_ret
Snd_3e_63c8:
	s_deflen 16
	s_note SC_GS   	; G#
	s_note SC_F    	; F
	s_note SC_GS   	; G#
	s_instr 3
	s_note SC_GS   	; G#
	s_instr 5
	s_note SC_GS   	; G#
	s_instr 1
	s_note_l SC_F, 32	; F dur=32
	s_note SC_A    	; A
	s_ret
Snd_3e_63d9:
	s_deflen 16
	s_pitchenv 0
	s_set10 0
Snd_3e_63df:
	s_call Snd_3e_63ee
	s_call Snd_3e_6402
	s_call Snd_3e_63ee
	s_call Snd_3e_6402
	s_goto Snd_3e_63df
Snd_3e_63ee:
	s_wave 2
	s_deflen 16
	s_oct 3	; block 2
	s_instr 20
	s_note SC_G    	; G
	s_note SC_D    	; D
	s_note_l SC_G, 32	; G dur=32
	s_instr 19
	s_note SC_G    	; G
	s_instr 20
	s_note SC_D    	; D
	s_note SC_G    	; G
	s_note SC_FS   	; F#
	s_ret
Snd_3e_6402:
	s_instr 20
	s_note SC_F    	; F
	s_note SC_C    	; C
	s_note_l SC_F, 32	; F dur=32
	s_instr 19
	s_note SC_F    	; F
	s_instr 20
	s_note SC_D    	; D
	s_note SC_F    	; F
	s_note SC_FS   	; F#
	s_ret
Snd_3e_6411:
	s_deflen 8
	s_oct 1	; block 0
	s_pitchenv 0
	s_set10 0
Snd_3e_6418:
	s_call Snd_3e_6433
	s_call Snd_3e_6433
	s_call Snd_3e_6433
	s_call Snd_3e_6433
	s_call Snd_3e_6433
	s_call Snd_3e_6433
	s_call Snd_3e_6433
	s_call Snd_3e_6450
	s_goto Snd_3e_6418
Snd_3e_6433:
	s_deflen 8
	s_instr 10
	s_note_l SC_F, 16	; F dur=16
	s_instr 12
	s_note SC_C    	; C
	s_note SC_C    	; C
	s_instr 11
	s_note_l SC_F, 32	; F dur=32
	s_instr 10
	s_note_l SC_C, 16	; C dur=16
	s_note_l SC_F, 16	; F dur=16
	s_instr 12
	s_note SC_C    	; C
	s_note SC_C    	; C
	s_instr 10
	s_note SC_F    	; F
	s_note SC_C    	; C
	s_ret
Snd_3e_6450:
	s_deflen 16
	s_instr 10
	s_note SC_F    	; F
	s_instr 12
	s_note SC_C    	; C
	s_instr 11
	s_note_l SC_F, 32	; F dur=32
	s_instr 10
	s_note SC_C    	; C
	s_note SC_F    	; F
	s_instr 14
	s_note_l SC_F, 8	; F dur=8
	s_note_l SC_F, 8	; F dur=8
	s_instr 10
	s_note SC_F    	; F
	s_ret
