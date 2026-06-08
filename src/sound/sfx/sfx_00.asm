; Sound id $00 (SFX) -- silence / stop
; Bank $3f, ROM $4d00-$4d0e. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $00", ROMX

; ===== sound id $00 =====
Snd_SFX_Silence:
	s_chan $ff, Snd_3f_4d0c
	s_chan $ff, Snd_3f_4d0c
	s_chan $ff, Snd_3f_4d0c
	s_chan $ff, Snd_3f_4d0c
Snd_3f_4d0c:
	s_note_l SC_REST, 1	; rest dur=1
	s_end
