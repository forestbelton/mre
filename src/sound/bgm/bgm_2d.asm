; Sound id $2d (BGM) -- ?
; Bank $3f, ROM $6a2f-$6eb5. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "BGM - $2d", ROMX

; ===== sound id $2d =====
Snd_BGM_2d:
	s_chan $f0, Snd_3f_6a3b
	s_chan $f0, Snd_3f_6ba3
	s_chan $f0, Snd_3f_6c88
	s_chan $f0, Snd_3f_6df8
Snd_3f_6a3b:
	s_pitchenv 0
	s_deflen 7
	s_set10 0
	s_dutyenv 5
Snd_3f_6a43:
	s_call Snd_3f_6a7e
	s_call Snd_3f_6a7e
	s_call Snd_3f_6a9c
	s_call Snd_3f_6a9c
	s_call Snd_3f_6a7e
	s_call Snd_3f_6a7e
	s_call Snd_3f_6a9c
	s_call Snd_3f_6a9c
	s_call Snd_3f_6ab9
	s_call Snd_3f_6adb
	s_call Snd_3f_6afb
	s_call Snd_3f_6b1b
	s_call Snd_3f_6b39
	s_call Snd_3f_6b39
	s_call Snd_3f_6b55
	s_call Snd_3f_6b74
	s_instr 1
	s_call Snd_3f_6b74
	s_call Snd_3f_6b86
	s_goto Snd_3f_6a43
Snd_3f_6a7e:
	s_deflen 7
	s_instr 2
	s_oct 4	; block 3
	s_note SC_GS   	; G#
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_GS   	; G#
	s_oct 3	; block 2
	s_note SC_GS   	; G#
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_note SC_AS   	; A#
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_GS   	; G#
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_note SC_AS   	; A#
	s_oct 4	; block 3
	s_note SC_GS   	; G#
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_note SC_AS   	; A#
	s_note SC_A    	; A
	s_ret
Snd_3f_6a9c:
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_note SC_AS   	; A#
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_note SC_AS   	; A#
	s_ret
Snd_3f_6ab9:
	s_deflen 7
	s_instr 1
	s_note_l SC_GS, 14	; G# dur=14
	s_instr 2
	s_note_l SC_GS, 14	; G# dur=14
	s_instr 2
	s_oct 4	; block 3
	s_note SC_AS   	; A#
	s_note SC_GS   	; G#
	s_note SC_DS   	; D#
	s_note_l SC_F, 14	; F dur=14
	s_instr 3
	s_note SC_F    	; F
	s_instr 4
	s_note SC_F    	; F
	s_instr 5
	s_note SC_F    	; F
	s_instr 1
	s_note SC_DS   	; D#
	s_note SC_F    	; F
	s_note_l SC_GS, 14	; G# dur=14
	s_ret
Snd_3f_6adb:
	s_deflen 7
	s_note_l SC_A, 14	; A dur=14
	s_instr 2
	s_note_l SC_A, 14	; A dur=14
	s_instr 2
	s_oct 4	; block 3
	s_note SC_B    	; B
	s_note SC_A    	; A
	s_note SC_E    	; E
	s_note_l SC_FS, 14	; F# dur=14
	s_instr 3
	s_note SC_FS   	; F#
	s_instr 4
	s_note SC_FS   	; F#
	s_instr 5
	s_note SC_FS   	; F#
	s_instr 1
	s_note SC_E    	; E
	s_note SC_FS   	; F#
	s_note_l SC_A, 14	; A dur=14
	s_ret
Snd_3f_6afb:
	s_deflen 7
	s_note_l SC_GS, 14	; G# dur=14
	s_instr 2
	s_note_l SC_GS, 14	; G# dur=14
	s_instr 2
	s_oct 4	; block 3
	s_note SC_AS   	; A#
	s_note SC_B    	; B
	s_note SC_AS   	; A#
	s_note_l SC_F, 14	; F dur=14
	s_instr 3
	s_note SC_F    	; F
	s_instr 4
	s_note SC_F    	; F
	s_instr 5
	s_note SC_F    	; F
	s_instr 1
	s_note SC_DS   	; D#
	s_note SC_F    	; F
	s_note_l SC_GS, 14	; G# dur=14
	s_ret
Snd_3f_6b1b:
	s_deflen 7
	s_note_l SC_A, 14	; A dur=14
	s_instr 2
	s_note_l SC_A, 14	; A dur=14
	s_instr 2
	s_oct 4	; block 3
	s_note SC_B    	; B
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_note_l SC_FS, 14	; F# dur=14
	s_instr 3
	s_note SC_FS   	; F#
	s_instr 4
	s_note SC_FS   	; F#
	s_instr 5
	s_note SC_FS   	; F#
	s_instr 1
	s_note_l SC_A, 28	; A dur=28
	s_ret
Snd_3f_6b39:
	s_oct 4	; block 3
	s_note SC_GS   	; G#
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_GS   	; G#
	s_oct 3	; block 2
	s_note SC_GS   	; G#
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_note SC_AS   	; A#
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_note SC_AS   	; A#
	s_ret
Snd_3f_6b55:
	s_oct 4	; block 3
	s_instr 0
	s_note SC_GS   	; G#
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_note SC_AS   	; A#
	s_note SC_GS   	; G#
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_note SC_B    	; B
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_AS   	; A#
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_oct 4	; block 3
	s_note SC_B    	; B
	s_note SC_C    	; C
	s_note SC_CS   	; C#
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_instr 3
	s_ret
Snd_3f_6b74:
	s_oct 4	; block 3
	s_note SC_B    	; B
	s_note SC_C    	; C
	s_note SC_B    	; B
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_note SC_CS   	; C#
	s_note SC_C    	; C
	s_note SC_B    	; B
	s_note SC_C    	; C
	s_note SC_CS   	; C#
	s_note SC_B    	; B
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_note SC_CS   	; C#
	s_note SC_C    	; C
	s_ret
Snd_3f_6b86:
	s_deflen 7
	s_instr 0
	s_oct 5	; block 4
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 5	; block 4
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_note SC_CS   	; C#
	s_note SC_C    	; C
	s_oct 5	; block 4
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_CS   	; C#
	s_oct 5	; block 4
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_note SC_CS   	; C#
	s_note SC_C    	; C
	s_ret
Snd_3f_6ba3:
	s_pitchenv 0
	s_deflen 7
	s_set10 0
	s_dutyenv 3
Snd_3f_6bab:
	s_call Snd_3f_6be4
	s_call Snd_3f_6be4
	s_call Snd_3f_6c01
	s_call Snd_3f_6c01
	s_call Snd_3f_6be4
	s_call Snd_3f_6be4
	s_call Snd_3f_6c01
	s_call Snd_3f_6c01
	s_call Snd_3f_6a7e
	s_call Snd_3f_6a9c
	s_call Snd_3f_6a7e
	s_call Snd_3f_6a9c
	s_call Snd_3f_6c19
	s_call Snd_3f_6c19
	s_call Snd_3f_6c37
	s_call Snd_3f_6b74
	s_call Snd_3f_6c55
	s_call Snd_3f_6c68
	s_goto Snd_3f_6bab
Snd_3f_6be4:
	s_deflen 7
	s_instr 1
	s_oct 4	; block 3
	s_note SC_CS   	; C#
	s_note SC_D    	; D
	s_note SC_DS   	; D#
	s_note SC_C    	; C
	s_oct 4	; block 3
	s_note SC_CS   	; C#
	s_note SC_DS   	; D#
	s_note SC_D    	; D
	s_note SC_CS   	; C#
	s_oct 4	; block 3
	s_note SC_CS   	; C#
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_note SC_CS   	; C#
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_CS   	; C#
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_ret
Snd_3f_6c01:
	s_deflen 7
	s_instr 1
	s_oct 4	; block 3
	s_note SC_E    	; E
	s_note SC_CS   	; C#
	s_note SC_D    	; D
	s_note SC_DS   	; D#
	s_note SC_D    	; D
	s_note SC_E    	; E
	s_note SC_DS   	; D#
	s_note SC_D    	; D
	s_oct 4	; block 3
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_oct 4	; block 3
	s_note SC_CS   	; C#
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_note SC_CS   	; C#
	s_note SC_C    	; C
	s_ret
Snd_3f_6c19:
	s_instr 2
	s_note SC_REST 	; rest
	s_oct 4	; block 3
	s_note SC_GS   	; G#
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_GS   	; G#
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_note SC_B    	; B
	s_note SC_AS   	; A#
	s_note SC_A    	; A
	s_note SC_REST 	; rest
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_note SC_B    	; B
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_note SC_AS   	; A#
	s_instr 1
	s_ret
Snd_3f_6c37:
	s_note SC_REST 	; rest
	s_oct 4	; block 3
	s_note SC_GS   	; G#
	s_oct 3	; block 2
	s_note SC_A    	; A
	s_note SC_AS   	; A#
	s_note SC_GS   	; G#
	s_oct 4	; block 3
	s_note SC_A    	; A
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_note SC_B    	; B
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_AS   	; A#
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_oct 4	; block 3
	s_note SC_B    	; B
	s_note SC_C    	; C
	s_note SC_CS   	; C#
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_instr 5
	s_ret
Snd_3f_6c55:
	s_instr 1
	s_oct 4	; block 3
	s_note SC_B    	; B
	s_note SC_C    	; C
	s_note SC_B    	; B
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_note SC_CS   	; C#
	s_note SC_C    	; C
	s_note SC_B    	; B
	s_note SC_C    	; C
	s_note SC_CS   	; C#
	s_note SC_B    	; B
	s_note SC_D    	; D
	s_note SC_C    	; C
	s_note SC_CS   	; C#
	s_ret
Snd_3f_6c68:
	s_deflen 7
	s_oct 5	; block 4
	s_instr 0
	s_note SC_A    	; A
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_oct 5	; block 4
	s_note SC_A    	; A
	s_oct 3	; block 2
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_note SC_B    	; B
	s_note SC_AS   	; A#
	s_oct 5	; block 4
	s_note SC_A    	; A
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_note SC_B    	; B
	s_oct 5	; block 4
	s_note SC_A    	; A
	s_oct 4	; block 3
	s_note SC_C    	; C
	s_oct 3	; block 2
	s_note SC_AS   	; A#
	s_note SC_B    	; B
	s_note SC_AS   	; A#
	s_ret
Snd_3f_6c88:
	s_deflen 7
	s_pitchenv 0
	s_set10 0
Snd_3f_6c8e:
	s_call Snd_3f_6cc7
	s_call Snd_3f_6cc7
	s_call Snd_3f_6cf6
	s_call Snd_3f_6cf6
	s_call Snd_3f_6cc7
	s_call Snd_3f_6cc7
	s_call Snd_3f_6cf6
	s_call Snd_3f_6cf6
	s_call Snd_3f_6cc7
	s_call Snd_3f_6cf6
	s_call Snd_3f_6cc7
	s_call Snd_3f_6cf6
	s_call Snd_3f_6d1f
	s_call Snd_3f_6d1f
	s_call Snd_3f_6d48
	s_call Snd_3f_6da2
	s_call Snd_3f_6da2
	s_call Snd_3f_6dcc
	s_goto Snd_3f_6c8e
Snd_3f_6cc7:
	s_deflen 7
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
	s_oct 3	; block 2
	s_instr 20
	s_note_l SC_AS, 14	; A# dur=14
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
	s_ret
Snd_3f_6cf6:
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
Snd_3f_6d1f:
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
Snd_3f_6d48:
	s_instr 20
	s_note SC_AS   	; A#
	s_instr 19
	s_note SC_AS   	; A#
	s_instr 20
	s_note SC_AS   	; A#
	s_instr 19
	s_note SC_AS   	; A#
	s_instr 20
	s_note SC_B    	; B
	s_instr 19
	s_note SC_B    	; B
	s_instr 20
	s_note SC_B    	; B
	s_instr 19
	s_note SC_B    	; B
	s_oct 4	; block 3
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_instr 20
	s_note SC_CS   	; C#
	s_instr 19
	s_note SC_CS   	; C#
	s_instr 20
	s_note_l SC_CS, 14	; C# dur=14
	s_ret
Snd_3f_6d78:	; unused/dead pattern
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
	s_instr 20
	s_note_l SC_C, 14	; C dur=14
	s_instr 19
	s_note SC_C    	; C
	s_instr 20
	s_note SC_C    	; C
	s_instr 19
	s_note SC_C    	; C
	s_ret
Snd_3f_6da2:
	s_oct 4	; block 3
	s_instr 20
	s_note SC_CS   	; C#
	s_instr 19
	s_note SC_CS   	; C#
	s_instr 20
	s_note SC_CS   	; C#
	s_instr 19
	s_note SC_CS   	; C#
	s_note SC_REST 	; rest
	s_instr 20
	s_note_l SC_CS, 14	; C# dur=14
	s_instr 19
	s_note SC_CS   	; C#
	s_instr 20
	s_note_l SC_CS, 14	; C# dur=14
	s_instr 19
	s_note SC_CS   	; C#
	s_instr 20
	s_note_l SC_CS, 14	; C# dur=14
	s_instr 19
	s_note SC_CS   	; C#
	s_instr 20
	s_note SC_CS   	; C#
	s_instr 19
	s_note SC_CS   	; C#
	s_ret
Snd_3f_6dcc:
	s_deflen 7
	s_oct 4	; block 3
	s_instr 20
	s_note SC_CS   	; C#
	s_instr 19
	s_note SC_CS   	; C#
	s_instr 20
	s_note SC_CS   	; C#
	s_instr 19
	s_note SC_CS   	; C#
	s_note SC_REST 	; rest
	s_instr 20
	s_note_l SC_CS, 14	; C# dur=14
	s_instr 19
	s_note SC_CS   	; C#
	s_instr 20
	s_note_l SC_CS, 14	; C# dur=14
	s_instr 19
	s_note SC_CS   	; C#
	s_instr 20
	s_note_l SC_CS, 14	; C# dur=14
	s_instr 19
	s_note SC_CS   	; C#
	s_instr 20
	s_note SC_CS   	; C#
	s_instr 19
	s_note SC_CS   	; C#
	s_ret
Snd_3f_6df8:
	s_pitchenv 0
	s_oct 1	; block 0
	s_deflen 7
	s_set10 0
Snd_3f_6dff:
	s_call Snd_3f_6e3a
	s_call Snd_3f_6e59
	s_call Snd_3f_6e3a
	s_call Snd_3f_6e78
	s_call Snd_3f_6e3a
	s_call Snd_3f_6e59
	s_call Snd_3f_6e3a
	s_call Snd_3f_6e78
	s_call Snd_3f_6e3a
	s_call Snd_3f_6e59
	s_call Snd_3f_6e3a
	s_call Snd_3f_6e78
	s_call Snd_3f_6e3a
	s_call Snd_3f_6e3a
	s_call Snd_3f_6e59
	s_call Snd_3f_6e3a
	s_call Snd_3f_6e3a
	s_deflen 7
	s_call Snd_3f_6e97
	s_goto Snd_3f_6dff
Snd_3f_6e3a:
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
	s_instr 13
	s_note_l SC_C, 14	; C dur=14
	s_ret
Snd_3f_6e59:
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
Snd_3f_6e78:
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
	s_instr 14
	s_note SC_F    	; F
	s_note SC_F    	; F
	s_ret
Snd_3f_6e97:
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
