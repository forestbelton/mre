; Sound id $00 (SFX) -- silence / stop
; Bank $3f, ROM $4d00-$4d0e. INCLUDEd by sound/bank0.asm into its $4b00 section.

; ===== sound id $00 =====
Snd_3f_4d00:
	s_chan $ff, Snd_3f_4d0c
	s_chan $ff, Snd_3f_4d0c
	s_chan $ff, Snd_3f_4d0c
	s_chan $ff, Snd_3f_4d0c
Snd_3f_4d0c:
	s_note_l SC_REST, 1	; rest dur=1
	s_end
