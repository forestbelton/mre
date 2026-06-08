; Sound id $02 (SFX) -- ?
; Bank $3f, ROM $4d39-$4d5e. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $02", ROMX

; ===== sound id $02 =====
Snd_SFX_02:
	s_chan $00, Snd_3f_4d5e
	s_chan $f0, Snd_3f_4d45
	s_chan $00, Snd_3f_4d5e
	s_chan $00, Snd_3f_4d5e
Snd_3f_4d45:
	s_pitchenv 0
	s_set10 0
	s_dutyenv 2
	s_pitchenv 0
	s_instr 0
	s_oct 6	; block 5
	s_note_l SC_C, 2	; C dur=2
	s_deflen 1
	s_oct 7	; block 6
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_note SC_C    	; C
	s_note SC_G    	; G
	s_end
Snd_3f_4d5e:
	s_end
