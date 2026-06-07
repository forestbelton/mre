; Sound id $15 (SFX) -- ?
; Bank $3f, ROM $52ce-$534a. INCLUDEd by sound/bank0.asm into its $4b00 section.

; ===== sound id $15 =====
Snd_3f_52ce:
	s_chan $00, Snd_3f_534a
	s_chan $f0, Snd_3f_52da
	s_chan $00, Snd_3f_534a
	s_chan $f0, Snd_3f_5313
Snd_3f_52da:
	s_set10 0
	s_dutyenv 3
	s_note_l SC_REST, 10	; rest dur=10
	s_pitchenv 0
	s_deflen 1
	s_instr 0
	s_call Snd_3f_5305
	s_call Snd_3f_5305
	s_call Snd_3f_5305
	s_call Snd_3f_5305
	s_call Snd_3f_5305
	s_instr 1
	s_call Snd_3f_5305
	s_instr 2
	s_call Snd_3f_5305
	s_instr 3
	s_call Snd_3f_5305
	s_end
Snd_3f_5305:
	s_oct 2	; block 1
	s_note SC_B    	; B
	s_note SC_REST 	; rest
	s_note SC_GS   	; G#
	s_note SC_A    	; A
	s_note SC_CS   	; C#
	s_note SC_REST 	; rest
	s_note SC_C    	; C
	s_note SC_D    	; D
	s_note SC_REST 	; rest
	s_oct 2	; block 1
	s_note SC_B    	; B
	s_note SC_A    	; A
	s_ret
Snd_3f_5313:
	s_note_l SC_REST, 15	; rest dur=15
	s_pitchenv 0
	s_oct 1	; block 0
	s_deflen 1
	s_instr 10
	s_call Snd_3f_5343
	s_call Snd_3f_5343
	s_call Snd_3f_5343
	s_call Snd_3f_5343
	s_call Snd_3f_5343
	s_call Snd_3f_5343
	s_call Snd_3f_5343
	s_call Snd_3f_5343
	s_call Snd_3f_5343
	s_call Snd_3f_5343
	s_instr 0
	s_call Snd_3f_5343
	s_call Snd_3f_5343
	s_end
Snd_3f_5343:
	s_note SC_F    	; F
	s_note SC_REST 	; rest
	s_note SC_REST 	; rest
	s_note SC_F    	; F
	s_note SC_REST 	; rest
	s_note SC_F    	; F
	s_ret
Snd_3f_534a:
	s_end
