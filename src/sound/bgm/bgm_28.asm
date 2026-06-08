; Sound id $28 (BGM) -- BGM silence / stop
; Bank $3f, ROM $580a-$581a. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "BGM - $28", ROMX

; ===== sound id $28 =====
Snd_3f_580a:
	s_chan $f0, Snd_3f_5816
	s_chan $f0, Snd_3f_5816
	s_chan $f0, Snd_3f_5816
	s_chan $f0, Snd_3f_5816
Snd_3f_5816:
	s_note_l SC_REST, 1	; rest dur=1
	s_goto Snd_3f_5816
