; Sound id $0f (SFX) -- ?
; Bank $3f, ROM $5085-$5097. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $0f", ROMX

; ===== sound id $0f =====
Snd_SFX_0f:
	s_chan $00, Snd_3f_5097
	s_chan $00, Snd_3f_5097
	s_chan $00, Snd_3f_5097
	s_chan $f0, Snd_3f_5091
Snd_3f_5091:
	s_oct 1	; block 0
	s_instr 0
	s_note_l SC_F, 24	; F dur=24
	s_end
Snd_3f_5097:
	s_end
