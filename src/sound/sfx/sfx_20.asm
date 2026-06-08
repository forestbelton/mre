; Sound id $20 (SFX) -- ?
; Bank $3f, ROM $5652-$5688. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $20", ROMX

; ===== sound id $20 =====
Snd_SFX_20:
	s_chan $00, Snd_3f_5688
	s_chan $f0, Snd_3f_565e
	s_chan $f0, Snd_3f_5673
	s_chan $00, Snd_3f_5688
Snd_3f_565e:
	s_pitchenv 0
	s_set10 0
	s_dutyenv 2
	s_deflen 10
	s_oct 5	; block 4
	s_instr 4
	s_note SC_G    	; G
	s_keyon
	s_note SC_GS   	; G#
	s_keyon
	s_note SC_A    	; A
	s_keyon
	s_goto Snd_3f_565e
Snd_3f_5672:
	ds 1, $ff
Snd_3f_5673:
	s_pitchenv 0
	s_set10 0
	s_wave 8
	s_instr 20
	s_deflen 10
	s_oct 5	; block 4
	s_note SC_E    	; E
	s_keyon
	s_note SC_F    	; F
	s_keyon
	s_note SC_FS   	; F#
	s_keyon
	s_goto Snd_3f_5673
Snd_3f_5687:
	ds 1, $ff
Snd_3f_5688:
	s_end
