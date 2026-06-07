; Sound id $27 (SFX) -- ?
; Bank $3f, ROM $57fb-$5809. INCLUDEd by sound/bank0.asm into its $4b00 section.

; ===== sound id $27 =====
Snd_3f_57fb:
	s_chan $ff, Snd_3f_5807
	s_chan $ff, Snd_3f_5807
	s_chan $ff, Snd_3f_5807
	s_chan $ff, Snd_3f_5807
Snd_3f_5807:
	s_note_l SC_REST, 1	; rest dur=1
	s_end
