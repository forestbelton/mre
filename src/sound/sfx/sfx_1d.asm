; Sound id $1d (SFX) -- ?
; Bank $3f, ROM $55ef-$55fd. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $1d", ROMX

; ===== sound id $1d =====
Snd_3f_55ef:
	s_chan $ff, Snd_3f_55fb
	s_chan $ff, Snd_3f_55fb
	s_chan $ff, Snd_3f_55fb
	s_chan $ff, Snd_3f_55fb
Snd_3f_55fb:
	s_note_l SC_REST, 1	; rest dur=1
	s_end
