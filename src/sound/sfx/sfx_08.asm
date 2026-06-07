; Sound id $08 (SFX) -- ?
; Bank $3f, ROM $4e52-$4ea9. INCLUDEd by sound/bank0.asm into its $4b00 section.

; ===== sound id $08 =====
Snd_3f_4e52:
	s_chan $f0, Snd_3f_4e5e
	s_chan $f0, Snd_3f_4e77
	s_chan $f0, Snd_3f_4e90
	s_chan $00, Snd_3f_4ea9
Snd_3f_4e5e:
	s_pitchenv 0
	s_set10 0
	s_dutyenv 1
	s_instr 1
	s_oct 4	; block 3
	s_note_l SC_C, 3	; C dur=3
	s_note_l SC_CS, 6	; C# dur=6
	s_note_l SC_F, 3	; F dur=3
	s_deflen 6
	s_note SC_FS   	; F#
	s_note SC_AS   	; A#
	s_deflen 3
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_note SC_CS   	; C#
	s_end
Snd_3f_4e77:
	s_pitchenv 0
	s_set10 0
	s_dutyenv 1
	s_instr 1
	s_oct 4	; block 3
	s_note_l SC_C, 3	; C dur=3
	s_note_l SC_CS, 6	; C# dur=6
	s_note_l SC_F, 3	; F dur=3
	s_deflen 6
	s_note SC_FS   	; F#
	s_note SC_AS   	; A#
	s_deflen 3
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_note SC_CS   	; C#
	s_end
Snd_3f_4e90:
	s_pitchenv 0
	s_set10 0
	s_instr 20
	s_wave 10
	s_oct 4	; block 3
	s_note_l SC_C, 3	; C dur=3
	s_note_l SC_CS, 6	; C# dur=6
	s_note_l SC_F, 3	; F dur=3
	s_deflen 6
	s_note SC_FS   	; F#
	s_note SC_AS   	; A#
	s_deflen 3
	s_oct 5	; block 4
	s_note SC_C    	; C
	s_note SC_CS   	; C#
	s_end
Snd_3f_4ea9:
	s_end
