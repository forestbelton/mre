; Sound id $33 (BGM) -- Verde
; Bank $3e, ROM $5a30-$5cb5. INCLUDEd by sound/bank1.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "BGM - $33", ROMX

; ===== sound id $33 =====
Snd_3e_5a30:
	s_chan $f0, Snd_3e_5a3c
	s_chan $f0, Snd_3e_5acb
	s_chan $f0, Snd_3e_5bb0
	s_chan $f0, Snd_3e_5c58
Snd_3e_5a3c:
	s_pitchenv 0
	s_instr 1
	s_set10 0
Snd_3e_5a42:
	s_dutyenv 5
	s_call Snd_3e_5a79
	s_call Snd_3e_5a89
	s_call Snd_3e_5a79
	s_call Snd_3e_5a93
	s_call Snd_3e_5a79
	s_call Snd_3e_5a89
	s_call Snd_3e_5aa9
	s_call Snd_3e_5abc
	s_dutyenv 4
	s_call Snd_3e_5a79
	s_call Snd_3e_5a89
	s_call Snd_3e_5a79
	s_call Snd_3e_5a93
	s_call Snd_3e_5a79
	s_call Snd_3e_5a89
	s_call Snd_3e_5aa9
	s_call Snd_3e_5abc
	s_goto Snd_3e_5a42
Snd_3e_5a79:
	s_deflen 8
	s_oct 4	; block 3
	s_instr 1
	s_note_l SC_G, 16	; G dur=16
	s_note SC_A    	; A
	s_note_l SC_REST, 16	; rest dur=16
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_keyon
	s_note_l SC_C, 48	; C dur=48
	s_ret
Snd_3e_5a89:
	s_note_l SC_REST, 24	; rest dur=24
	s_note_l SC_DS, 24	; D# dur=24
	s_note_l SC_D, 16	; D dur=16
	s_note SC_D    	; D
	s_note_l SC_REST, 24	; rest dur=24
	s_ret
Snd_3e_5a93:
	s_note_l SC_REST, 16	; rest dur=16
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_oct 5	; block 4
	s_note_l SC_F, 16	; F dur=16
	s_note SC_DS   	; D#
	s_note_l SC_E, 16	; E dur=16
	s_note SC_E    	; E
	s_keyon
	s_instr 3
	s_note SC_E    	; E
	s_instr 4
	s_note SC_E    	; E
	s_instr 5
	s_note SC_E    	; E
	s_ret
Snd_3e_5aa9:
	s_note_l SC_C, 16	; C dur=16
	s_note SC_REST 	; rest
	s_note_l SC_C, 16	; C dur=16
	s_instr 3
	s_note SC_C    	; C
	s_instr 1
	s_note_l SC_C, 16	; C dur=16
	s_oct 4	; block 3
	s_note SC_AS   	; A#
	s_note_l SC_B, 16	; B dur=16
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_ret
Snd_3e_5abc:
	s_note_l SC_REST, 16	; rest dur=16
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_oct 4	; block 3
	s_note_l SC_A, 16	; A dur=16
	s_note SC_B    	; B
	s_note_l SC_B, 16	; B dur=16
	s_note SC_A    	; A
	s_note_l SC_G, 16	; G dur=16
	s_note SC_B    	; B
	s_ret
Snd_3e_5acb:
	s_pitchenv 1
	s_set10 0
Snd_3e_5acf:
	s_dutyenv 2
	s_call Snd_3e_5b06
	s_call Snd_3e_5b18
	s_call Snd_3e_5b06
	s_call Snd_3e_5b25
	s_call Snd_3e_5b06
	s_call Snd_3e_5b18
	s_call Snd_3e_5b32
	s_call Snd_3e_5b43
	s_dutyenv 2
	s_call Snd_3e_5b50
	s_call Snd_3e_5b5d
	s_call Snd_3e_5b6b
	s_call Snd_3e_5b75
	s_call Snd_3e_5b50
	s_call Snd_3e_5b86
	s_call Snd_3e_5b95
	s_call Snd_3e_5ba2
	s_goto Snd_3e_5acf
Snd_3e_5b06:
	s_deflen 8
	s_oct 4	; block 3
	s_instr 2
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_FS   	; F#
	s_note SC_G    	; G
	s_note SC_FS   	; F#
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_FS   	; F#
	s_note SC_G    	; G
	s_note SC_FS   	; F#
	s_note SC_F    	; F
	s_ret
Snd_3e_5b18:
	s_note SC_A    	; A
	s_note SC_GS   	; G#
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_note SC_AS   	; A#
	s_note SC_A    	; A
	s_note_l SC_G, 16	; G dur=16
	s_note SC_F    	; F
	s_ret
Snd_3e_5b25:
	s_note SC_A    	; A
	s_note SC_GS   	; G#
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_G    	; G
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_note SC_A    	; A
	s_note SC_AS   	; A#
	s_note_l SC_B, 16	; B dur=16
	s_note SC_G    	; G
	s_ret
Snd_3e_5b32:
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_note SC_DS   	; D#
	s_note_l SC_E, 16	; E dur=16
	s_instr 4
	s_note SC_E    	; E
	s_instr 2
	s_note_l SC_E, 16	; E dur=16
	s_note SC_F    	; F
	s_note_l SC_FS, 16	; F# dur=16
	s_note SC_G    	; G
	s_ret
Snd_3e_5b43:
	s_note_l SC_REST, 16	; rest dur=16
	s_oct 4	; block 3
	s_note SC_E    	; E
	s_note_l SC_C, 16	; C dur=16
	s_note_l SC_D, 24	; D dur=24
	s_note SC_E    	; E
	s_note_l SC_D, 16	; D dur=16
	s_note SC_F    	; F
	s_ret
Snd_3e_5b50:
	s_deflen 8
	s_oct 3	; block 2
	s_instr 0
	s_note_l SC_E, 48	; E dur=48
	s_note_l SC_G, 32	; G dur=32
	s_keyon
	s_note SC_G    	; G
	s_note SC_C    	; C
	s_ret
Snd_3e_5b5d:
	s_keyon
	s_note_l SC_C, 24	; C dur=24
	s_oct 4	; block 3
	s_note_l SC_C, 24	; C dur=24
	s_oct 3	; block 2
	s_note_l SC_B, 16	; B dur=16
	s_note SC_G    	; G
	s_note_l SC_A, 16	; A dur=16
	s_note SC_G    	; G
	s_ret
Snd_3e_5b6b:
	s_note_l SC_E, 16	; E dur=16
	s_note SC_G    	; G
	s_keyon
	s_note_l SC_G, 48	; G dur=48
	s_keyon
	s_note_l SC_G, 24	; G dur=24
	s_ret
Snd_3e_5b75:
	s_oct 3	; block 2
	s_instr 3
	s_note_l SC_G, 32	; G dur=32
	s_instr 5
	s_note_l SC_G, 24	; G dur=24
	s_note SC_REST 	; rest
	s_instr 0
	s_note SC_G    	; G
	s_note_l SC_FS, 16	; F# dur=16
	s_note SC_F    	; F
	s_ret
Snd_3e_5b86:
	s_keyon
	s_note_l SC_C, 24	; C dur=24
	s_oct 4	; block 3
	s_note_l SC_C, 24	; C dur=24
	s_oct 3	; block 2
	s_note_l SC_REST, 16	; rest dur=16
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note_l SC_C, 16	; C dur=16
	s_note SC_D    	; D
	s_ret
Snd_3e_5b95:
	s_note_l SC_E, 16	; E dur=16
	s_note SC_REST 	; rest
	s_note_l SC_E, 16	; E dur=16
	s_note SC_C    	; C
	s_note_l SC_E, 16	; E dur=16
	s_note SC_F    	; F
	s_note_l SC_FS, 16	; F# dur=16
	s_note SC_G    	; G
	s_ret
Snd_3e_5ba2:
	s_oct 3	; block 2
	s_note_l SC_REST, 16	; rest dur=16
	s_note SC_G    	; G
	s_note_l SC_A, 16	; A dur=16
	s_note_l SC_G, 16	; G dur=16
	s_note SC_REST 	; rest
	s_note SC_G    	; G
	s_note_l SC_FS, 16	; F# dur=16
	s_note SC_F    	; F
	s_ret
Snd_3e_5bb0:
	s_pitchenv 0
	s_set10 0
Snd_3e_5bb4:
	s_call Snd_3e_5bcf
	s_call Snd_3e_5bf1
	s_call Snd_3e_5bcf
	s_call Snd_3e_5bf1
	s_call Snd_3e_5bcf
	s_call Snd_3e_5bf1
	s_call Snd_3e_5c2b
	s_call Snd_3e_5c42
	s_goto Snd_3e_5bb4
Snd_3e_5bcf:
	s_wave 2
	s_deflen 8
	s_oct 3	; block 2
	s_instr 20
	s_note_l SC_C, 16	; C dur=16
	s_instr 19
	s_note SC_C    	; C
	s_instr 20
	s_note_l SC_C, 16	; C dur=16
	s_instr 19
	s_note SC_C    	; C
	s_instr 20
	s_note_l SC_E, 16	; E dur=16
	s_instr 19
	s_note SC_E    	; E
	s_instr 20
	s_note_l SC_E, 16	; E dur=16
	s_instr 19
	s_note SC_E    	; E
	s_ret
Snd_3e_5bf1:
	s_instr 20
	s_note_l SC_F, 16	; F dur=16
	s_instr 19
	s_note SC_F    	; F
	s_instr 20
	s_note_l SC_F, 16	; F dur=16
	s_instr 19
	s_note SC_F    	; F
	s_instr 20
	s_note_l SC_G, 16	; G dur=16
	s_instr 19
	s_note SC_G    	; G
	s_instr 20
	s_note_l SC_G, 16	; G dur=16
	s_instr 19
	s_note SC_G    	; G
	s_ret
Snd_3e_5c0e:	; unused/dead pattern
	s_instr 20
	s_note_l SC_D, 16	; D dur=16
	s_instr 19
	s_note SC_D    	; D
	s_instr 20
	s_note_l SC_D, 16	; D dur=16
	s_instr 19
	s_note SC_D    	; D
	s_instr 20
	s_note_l SC_G, 16	; G dur=16
	s_instr 19
	s_note SC_G    	; G
	s_instr 20
	s_note_l SC_G, 16	; G dur=16
	s_instr 19
	s_note SC_G    	; G
	s_ret
Snd_3e_5c2b:
	s_instr 20
	s_note_l SC_C, 16	; C dur=16
	s_instr 19
	s_note SC_C    	; C
	s_instr 20
	s_note_l SC_C, 16	; C dur=16
	s_instr 19
	s_note SC_C    	; C
	s_instr 20
	s_note_l SC_C, 16	; C dur=16
	s_note SC_G    	; G
	s_note_l SC_FS, 16	; F# dur=16
	s_note SC_F    	; F
	s_ret
Snd_3e_5c42:
	s_note_l SC_REST, 16	; rest dur=16
	s_instr 20
	s_note SC_G    	; G
	s_note_l SC_FS, 16	; F# dur=16
	s_note SC_G    	; G
	s_keyon
	s_note_l SC_G, 16	; G dur=16
	s_instr 19
	s_note SC_G    	; G
	s_instr 20
	s_note_l SC_G, 16	; G dur=16
	s_instr 19
	s_note SC_G    	; G
	s_ret
Snd_3e_5c58:
	s_pitchenv 0
	s_oct 1	; block 0
	s_set10 0
Snd_3e_5c5d:
	s_call Snd_3e_5c78
	s_call Snd_3e_5c78
	s_call Snd_3e_5c78
	s_call Snd_3e_5c78
	s_call Snd_3e_5c78
	s_call Snd_3e_5c78
	s_call Snd_3e_5c8d
	s_call Snd_3e_5ca5
	s_goto Snd_3e_5c5d
Snd_3e_5c78:
	s_deflen 24
	s_instr 12
	s_note SC_C    	; C
	s_instr 10
	s_note_l SC_F, 16	; F dur=16
	s_note_l SC_C, 8	; C dur=8
	s_instr 12
	s_note SC_C    	; C
	s_instr 10
	s_note_l SC_F, 16	; F dur=16
	s_note_l SC_C, 8	; C dur=8
	s_ret
Snd_3e_5c8d:
	s_deflen 8
	s_instr 10
	s_note_l SC_F, 16	; F dur=16
	s_note SC_C    	; C
	s_instr 12
	s_note_l SC_C, 24	; C dur=24
	s_instr 10
	s_note_l SC_F, 16	; F dur=16
	s_instr 12
	s_note_l SC_C, 24	; C dur=24
	s_instr 13
	s_note_l SC_C, 24	; C dur=24
	s_ret
Snd_3e_5ca5:
	s_instr 10
	s_note SC_C    	; C
	s_instr 11
	s_note_l SC_D, 16	; D dur=16
	s_note_l SC_D, 16	; D dur=16
	s_note SC_D    	; D
	s_note SC_D    	; D
	s_note SC_D    	; D
	s_instr 12
	s_note SC_D    	; D
	s_note SC_D    	; D
	s_ret
