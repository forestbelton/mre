; Sound id $30 (BGM) -- Bodka
; Bank $3e, ROM $516f-$559c. INCLUDEd by sound/bank1.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "BGM - $30", ROMX

; ===== sound id $30 =====
Snd_3e_516f:
	s_chan $f0, Snd_3e_517b
	s_chan $f0, Snd_3e_5282
	s_chan $f0, Snd_3e_53a3
	s_chan $f0, Snd_3e_5477
Snd_3e_517b:
	s_pitchenv 0
	s_instr 1
	s_deflen 8
	s_oct 3	; block 2
	s_set10 0
Snd_3e_5184:
	s_dutyenv 4
	s_call Snd_3e_51bb
	s_call Snd_3e_51d0
	s_call Snd_3e_51e1
	s_call Snd_3e_51f5
	s_call Snd_3e_51bb
	s_call Snd_3e_520a
	s_call Snd_3e_521a
	s_call Snd_3e_522a
	s_dutyenv 5
	s_call Snd_3e_5238
	s_call Snd_3e_524e
	s_call Snd_3e_5258
	s_call Snd_3e_5266
	s_call Snd_3e_5238
	s_call Snd_3e_524e
	s_call Snd_3e_5274
	s_call Snd_3e_527d
	s_goto Snd_3e_5184
Snd_3e_51bb:
	s_instr 1
	s_oct 4	; block 3
	s_note_l SC_REST, 16	; rest dur=16
	s_note_l SC_FS, 16	; F# dur=16
	s_deflen 8
	s_note SC_G    	; G
	s_note SC_REST 	; rest
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_deflen 16
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_note SC_D    	; D
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_ret
Snd_3e_51d0:
	s_oct 4	; block 3
	s_note_l SC_FS, 16	; F# dur=16
	s_deflen 8
	s_note SC_G    	; G
	s_note SC_REST 	; rest
	s_note SC_G    	; G
	s_note SC_REST 	; rest
	s_deflen 16
	s_note SC_C    	; C
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_note SC_D    	; D
	s_note SC_G    	; G
	s_ret
Snd_3e_51e1:
	s_instr 3
	s_note SC_G    	; G
	s_instr 1
	s_oct 4	; block 3
	s_note SC_FS   	; F#
	s_deflen 8
	s_note SC_G    	; G
	s_note SC_REST 	; rest
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_deflen 16
	s_note SC_GS   	; G#
	s_note SC_G    	; G
	s_note SC_F    	; F
	s_note SC_GS   	; G#
	s_ret
Snd_3e_51f5:
	s_note SC_G    	; G
	s_note_l SC_FS, 8	; F# dur=8
	s_note_l SC_F, 8	; F dur=8
	s_note SC_E    	; E
	s_dutyenv 5
	s_instr 2
	s_note_l SC_C, 32	; C dur=32
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_note SC_A    	; A
	s_note SC_AS   	; A#
	s_instr 1
	s_dutyenv 4
	s_ret
Snd_3e_520a:
	s_oct 4	; block 3
	s_note SC_FS   	; F#
	s_deflen 8
	s_note SC_G    	; G
	s_note SC_REST 	; rest
	s_note SC_G    	; G
	s_note SC_REST 	; rest
	s_deflen 16
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note_l SC_GS, 32	; G# dur=32
	s_note SC_F    	; F
	s_ret
Snd_3e_521a:
	s_instr 3
	s_note SC_F    	; F
	s_instr 1
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_AS   	; A#
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_oct 4	; block 3
	s_note SC_G    	; G
	s_note SC_AS   	; A#
	s_oct 5	; block 4
	s_note SC_F    	; F
	s_ret
Snd_3e_522a:
	s_oct 5	; block 4
	s_deflen 32
	s_note SC_E    	; E
	s_instr 2
	s_note SC_E    	; E
	s_instr 3
	s_note SC_E    	; E
	s_instr 5
	s_note SC_E    	; E
	s_ret
Snd_3e_5238:
	s_instr 1
	s_oct 4	; block 3
	s_deflen 16
	s_note_l SC_A, 8	; A dur=8
	s_note_l SC_REST, 8	; rest dur=8
	s_note_l SC_A, 32	; A dur=32
	s_oct 5	; block 4
	s_note_l SC_C, 8	; C dur=8
	s_note_l SC_D, 8	; D dur=8
	s_note SC_DS   	; D#
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_oct 4	; block 3
	s_note SC_AS   	; A#
	s_ret
Snd_3e_524e:
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_oct 4	; block 3
	s_note_l SC_A, 32	; A dur=32
	s_note SC_F    	; F
	s_note_l SC_DS, 48	; D# dur=48
	s_note SC_REST 	; rest
	s_ret
Snd_3e_5258:
	s_note SC_GS   	; G#
	s_note_l SC_A, 32	; A dur=32
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_note SC_DS   	; D#
	s_instr 2
	s_note SC_DS   	; D#
	s_instr 1
	s_note_l SC_D, 32	; D dur=32
	s_ret
Snd_3e_5266:
	s_oct 5	; block 4
	s_note_l SC_D, 64	; D dur=64
	s_note_l SC_C, 64	; C dur=64
	s_ret
Snd_3e_526c:	; unused/dead pattern
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note SC_C    	; C
	s_note_l SC_DS, 64	; D# dur=64
	s_ret
Snd_3e_5274:
	s_note_l SC_A, 32	; A dur=32
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_F    	; F
	s_note_l SC_A, 32	; A dur=32
	s_note SC_AS   	; A#
	s_ret
Snd_3e_527d:
	s_note_l SC_B, 64	; B dur=64
	s_note_l SC_G, 64	; G dur=64
	s_ret
Snd_3e_5282:
	s_pitchenv 0
	s_set10 0
Snd_3e_5286:
	s_dutyenv 5
	s_call Snd_3e_52bb
	s_call Snd_3e_52ca
	s_call Snd_3e_52bb
	s_call Snd_3e_52dd
	s_call Snd_3e_52f1
	s_call Snd_3e_52fd
	s_call Snd_3e_5311
	s_call Snd_3e_531d
	s_call Snd_3e_532f
	s_call Snd_3e_5340
	s_call Snd_3e_534c
	s_call Snd_3e_5358
	s_call Snd_3e_5367
	s_call Snd_3e_5378
	s_call Snd_3e_5389
	s_call Snd_3e_5399
	s_goto Snd_3e_5286
Snd_3e_52bb:
	s_instr 1
	s_oct 3	; block 2
	s_deflen 16
	s_note SC_G    	; G
	s_note SC_C    	; C
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_note SC_F    	; F
	s_note SC_REST 	; rest
	s_note SC_F    	; F
	s_oct 4	; block 3
	s_note SC_D    	; D
	s_ret
Snd_3e_52ca:
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_deflen 8
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_note SC_E    	; E
	s_note SC_REST 	; rest
	s_deflen 16
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_oct 4	; block 3
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_note SC_D    	; D
	s_ret
Snd_3e_52dd:
	s_note SC_E    	; E
	s_deflen 8
	s_note SC_DS   	; D#
	s_note SC_D    	; D
	s_deflen 16
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_oct 4	; block 3
	s_instr 2
	s_note_l SC_G, 32	; G dur=32
	s_note SC_D    	; D
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_instr 1
	s_ret
Snd_3e_52f1:
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_note SC_FS   	; F#
	s_note SC_AS   	; A#
	s_note SC_A    	; A
	s_note SC_AS   	; A#
	s_note SC_B    	; B
	s_ret
Snd_3e_52fd:
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_deflen 8
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_note SC_REST 	; rest
	s_deflen 16
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_note_l SC_F, 32	; F dur=32
	s_note SC_GS   	; G#
	s_ret
Snd_3e_5311:
	s_note SC_G    	; G
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_G    	; G
	s_oct 4	; block 3
	s_note SC_G    	; G
	s_note SC_D    	; D
	s_note SC_DS   	; D#
	s_note_l SC_D, 32	; D dur=32
	s_ret
Snd_3e_531d:
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note_l SC_B, 8	; B dur=8
	s_note_l SC_REST, 8	; rest dur=8
	s_note SC_AS   	; A#
	s_note SC_B    	; B
	s_note SC_G    	; G
	s_oct 4	; block 3
	s_note SC_G    	; G
	s_instr 2
	s_note SC_G    	; G
	s_instr 1
	s_note SC_D    	; D
	s_ret
Snd_3e_532f:
	s_oct 3	; block 2
	s_instr 1
	s_deflen 16
	s_note SC_F    	; F
	s_note_l SC_C, 8	; C dur=8
	s_note_l SC_C, 8	; C dur=8
	s_note SC_F    	; F
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_note SC_DS   	; D#
	s_note SC_D    	; D
	s_note SC_DS   	; D#
	s_ret
Snd_3e_5340:
	s_note SC_F    	; F
	s_note_l SC_C, 8	; C dur=8
	s_note_l SC_D, 8	; D dur=8
	s_note SC_DS   	; D#
	s_note SC_AS   	; A#
	s_note_l SC_A, 32	; A dur=32
	s_note_l SC_G, 32	; G dur=32
	s_ret
Snd_3e_534c:
	s_note SC_F    	; F
	s_note_l SC_C, 8	; C dur=8
	s_note_l SC_C, 8	; C dur=8
	s_note SC_A    	; A
	s_note SC_F    	; F
	s_note_l SC_AS, 32	; A# dur=32
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_ret
Snd_3e_5358:
	s_note_l SC_A, 32	; A dur=32
	s_instr 1
	s_oct 4	; block 3
	s_note_l SC_F, 32	; F dur=32
	s_note SC_G    	; G
	s_note_l SC_F, 8	; F dur=8
	s_note_l SC_E, 8	; E dur=8
	s_note_l SC_DS, 32	; D# dur=32
	s_ret
Snd_3e_5367:
	s_oct 4	; block 3
	s_instr 1
	s_deflen 16
	s_note_l SC_C, 32	; C dur=32
	s_oct 3	; block 2
	s_note SC_F    	; F
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note_l SC_AS, 32	; A# dur=32
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_ret
Snd_3e_5378:
	s_note_l SC_A, 32	; A dur=32
	s_note_l SC_F, 32	; F dur=32
	s_oct 3	; block 2
	s_deflen 8
	s_note SC_AS   	; A#
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note_l SC_G, 16	; G dur=16
	s_note_l SC_F, 16	; F dur=16
	s_note_l SC_DS, 16	; D# dur=16
	s_ret
Snd_3e_5389:
	s_note_l SC_F, 16	; F dur=16
	s_note_l SC_DS, 16	; D# dur=16
	s_note SC_E    	; E
	s_note SC_D    	; D
	s_note_l SC_C, 16	; C dur=16
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note_l SC_B, 32	; B dur=32
	s_note SC_F    	; F
	s_note SC_FS   	; F#
	s_ret
Snd_3e_5399:
	s_oct 4	; block 3
	s_note_l SC_D, 32	; D dur=32
	s_note_l SC_C, 32	; C dur=32
	s_note_l SC_CS, 32	; C# dur=32
	s_note_l SC_D, 32	; D dur=32
	s_ret
Snd_3e_53a3:
	s_pitchenv 0
	s_set10 0
Snd_3e_53a7:
	s_call Snd_3e_53da
	s_call Snd_3e_53da
	s_call Snd_3e_53da
	s_call Snd_3e_53da
	s_call Snd_3e_53da
	s_call Snd_3e_53da
	s_call Snd_3e_53da
	s_call Snd_3e_53f9
	s_call Snd_3e_5412
	s_call Snd_3e_5412
	s_call Snd_3e_5412
	s_call Snd_3e_542e
	s_call Snd_3e_5412
	s_call Snd_3e_5412
	s_call Snd_3e_5445
	s_call Snd_3e_545e
	s_goto Snd_3e_53a7
Snd_3e_53da:
	s_wave 2
	s_deflen 16
	s_oct 3	; block 2
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_oct 4	; block 3
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_instr 20
	s_note SC_AS   	; A#
	s_instr 19
	s_note SC_AS   	; A#
	s_instr 20
	s_note SC_A    	; A
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_ret
Snd_3e_53f9:
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_oct 4	; block 3
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_instr 20
	s_note SC_AS   	; A#
	s_instr 19
	s_note SC_AS   	; A#
	s_instr 20
	s_note SC_G    	; G
	s_note SC_FS   	; F#
	s_ret
Snd_3e_5412:
	s_wave 2
	s_deflen 16
	s_oct 3	; block 2
	s_instr 20
	s_note SC_F    	; F
	s_instr 19
	s_note SC_F    	; F
	s_instr 20
	s_note SC_F    	; F
	s_instr 19
	s_note SC_F    	; F
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_instr 20
	s_note SC_C    	; C
	s_note SC_FS   	; F#
	s_ret
Snd_3e_542e:
	s_instr 20
	s_note SC_F    	; F
	s_instr 19
	s_note SC_F    	; F
	s_instr 20
	s_note SC_A    	; A
	s_instr 19
	s_note SC_A    	; A
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_instr 20
	s_note SC_G    	; G
	s_note SC_FS   	; F#
	s_ret
Snd_3e_5445:
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
	s_instr 20
	s_note SC_CS   	; C#
	s_instr 19
	s_note SC_CS   	; C#
	s_ret
Snd_3e_545e:
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
	s_note SC_B    	; B
	s_instr 19
	s_note SC_B    	; B
	s_ret
Snd_3e_5477:
	s_pitchenv 0
	s_deflen 16
	s_oct 1	; block 0
	s_set10 0
Snd_3e_547e:
	s_call Snd_3e_54b1
	s_call Snd_3e_54b1
	s_call Snd_3e_54b1
	s_call Snd_3e_54c9
	s_call Snd_3e_54b1
	s_call Snd_3e_54b1
	s_call Snd_3e_54b1
	s_call Snd_3e_54e4
	s_call Snd_3e_54fc
	s_call Snd_3e_5519
	s_call Snd_3e_54fc
	s_call Snd_3e_5538
	s_call Snd_3e_54fc
	s_call Snd_3e_5519
	s_call Snd_3e_5557
	s_call Snd_3e_557a
	s_goto Snd_3e_547e
Snd_3e_54b1:
	s_deflen 16
	s_instr 10
	s_note SC_F    	; F
	s_instr 12
	s_note SC_C    	; C
	s_instr 14
	s_note SC_F    	; F
	s_instr 10
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note SC_C    	; C
	s_instr 14
	s_note SC_F    	; F
	s_note_l SC_F, 8	; F dur=8
	s_note_l SC_F, 8	; F dur=8
	s_ret
Snd_3e_54c9:
	s_instr 10
	s_note SC_F    	; F
	s_instr 12
	s_note SC_C    	; C
	s_instr 14
	s_note SC_F    	; F
	s_instr 10
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_note SC_C    	; C
	s_deflen 8
	s_instr 14
	s_note SC_F    	; F
	s_instr 12
	s_note SC_C    	; C
	s_instr 14
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_ret
Snd_3e_54e4:
	s_instr 10
	s_note SC_F    	; F
	s_instr 12
	s_note SC_C    	; C
	s_instr 14
	s_note SC_F    	; F
	s_instr 10
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_instr 14
	s_note SC_F    	; F
	s_instr 14
	s_note SC_F    	; F
	s_deflen 8
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_ret
Snd_3e_54fc:
	s_instr 10
	s_note SC_F    	; F
	s_note SC_C    	; C
	s_instr 12
	s_note_l SC_D, 16	; D dur=16
	s_instr 14
	s_note_l SC_D, 16	; D dur=16
	s_note_l SC_D, 16	; D dur=16
	s_instr 10
	s_note_l SC_F, 16	; F dur=16
	s_instr 12
	s_note SC_D    	; D
	s_note SC_D    	; D
	s_instr 14
	s_note_l SC_D, 16	; D dur=16
	s_note_l SC_D, 16	; D dur=16
	s_ret
Snd_3e_5519:
	s_instr 10
	s_note SC_F    	; F
	s_note SC_C    	; C
	s_instr 12
	s_note_l SC_D, 16	; D dur=16
	s_instr 14
	s_note_l SC_D, 16	; D dur=16
	s_note_l SC_D, 16	; D dur=16
	s_instr 10
	s_note_l SC_F, 16	; F dur=16
	s_instr 12
	s_note_l SC_D, 16	; D dur=16
	s_instr 14
	s_note SC_D    	; D
	s_instr 12
	s_note SC_D    	; D
	s_note SC_D    	; D
	s_note SC_D    	; D
	s_ret
Snd_3e_5538:
	s_instr 10
	s_note_l SC_F, 16	; F dur=16
	s_instr 12
	s_note_l SC_D, 16	; D dur=16
	s_instr 10
	s_note_l SC_F, 16	; F dur=16
	s_instr 14
	s_note_l SC_D, 16	; D dur=16
	s_instr 10
	s_note_l SC_F, 16	; F dur=16
	s_instr 12
	s_note_l SC_D, 16	; D dur=16
	s_instr 14
	s_note_l SC_D, 16	; D dur=16
	s_note SC_D    	; D
	s_note SC_D    	; D
	s_ret
Snd_3e_5557:
	s_instr 14
	s_note_l SC_D, 16	; D dur=16
	s_instr 10
	s_note_l SC_F, 16	; F dur=16
	s_instr 14
	s_note_l SC_D, 16	; D dur=16
	s_instr 10
	s_note_l SC_F, 16	; F dur=16
	s_instr 14
	s_note SC_D    	; D
	s_note SC_D    	; D
	s_instr 10
	s_note_l SC_F, 16	; F dur=16
	s_instr 14
	s_note_l SC_D, 16	; D dur=16
	s_instr 10
	s_note SC_F    	; F
	s_instr 14
	s_note SC_D    	; D
	s_ret
Snd_3e_557a:
	s_instr 14
	s_note_l SC_D, 16	; D dur=16
	s_instr 10
	s_note SC_F    	; F
	s_note SC_C    	; C
	s_instr 14
	s_note_l SC_D, 16	; D dur=16
	s_instr 10
	s_note SC_F    	; F
	s_note SC_C    	; C
	s_instr 14
	s_note SC_D    	; D
	s_instr 12
	s_note SC_C    	; C
	s_instr 14
	s_note SC_D    	; D
	s_note SC_D    	; D
	s_instr 14
	s_note SC_D    	; D
	s_instr 12
	s_note SC_D    	; D
	s_note SC_D    	; D
	s_note SC_D    	; D
	s_ret
