; Sound id $1c (SFX) -- ?
; Bank $3f, ROM $55a3-$55ee. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $1c", ROMX

; ===== sound id $1c =====
Snd_SFX_1c:
	s_chan $00, Snd_3f_55ee
	s_chan $f0, Snd_3f_55af
	s_chan $f0, Snd_3f_55d0
	s_chan $00, Snd_3f_55ee
Snd_3f_55af:
	s_pitchenv 0
	s_set10 0
	s_dutyenv 4
	s_deflen 4
	s_oct 7	; block 6
	s_instr 2
	s_note SC_G    	; G
	s_note SC_REST 	; rest
	s_note SC_GS   	; G#
	s_note SC_REST 	; rest
	s_note SC_A    	; A
	s_note SC_REST 	; rest
	s_deflen 4
	s_oct 6	; block 5
	s_instr 4
	s_note SC_G    	; G
	s_note SC_REST 	; rest
	s_note SC_GS   	; G#
	s_note SC_REST 	; rest
	s_note SC_A    	; A
	s_note SC_REST 	; rest
	s_goto Snd_3f_55af
Snd_3f_55ce:
	ds 2, $ff
Snd_3f_55d0:
	s_pitchenv 0
	s_set10 0
	s_wave 8
	s_instr 19
	s_deflen 4
	s_oct 6	; block 5
	s_note SC_E    	; E
	s_note SC_REST 	; rest
	s_note SC_F    	; F
	s_note SC_REST 	; rest
	s_note SC_FS   	; F#
	s_note SC_REST 	; rest
	s_deflen 4
	s_oct 5	; block 4
	s_note SC_E    	; E
	s_note SC_REST 	; rest
	s_note SC_F    	; F
	s_note SC_REST 	; rest
	s_note SC_FS   	; F#
	s_note SC_REST 	; rest
	s_goto Snd_3f_55d0
Snd_3f_55ed:
	ds 1, $ff
Snd_3f_55ee:
	s_end
