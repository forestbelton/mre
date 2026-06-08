; Sound id $1a (SFX) -- ?
; Bank $3f, ROM $54b7-$5513. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $1a", ROMX

; ===== sound id $1a =====
Snd_SFX_1a:
	s_chan $00, Snd_3f_5513
	s_chan $f0, Snd_3f_54c3
	s_chan $00, Snd_3f_5513
	s_chan $00, Snd_3f_5513
Snd_3f_54c3:
	s_pitchenv 1
	s_oct 4	; block 3
	s_set10 0
	s_dutyenv 3
	s_deflen 3
	s_call Snd_3f_54d3
	s_call Snd_3f_54f4
	s_end
Snd_3f_54d3:
	s_instr 2
	s_note SC_D    	; D
	s_keyon
	s_instr 1
	s_note SC_D    	; D
	s_keyon
	s_instr 0
	s_note SC_DS   	; D#
	s_keyon
	s_note SC_E    	; E
	s_instr 1
	s_note SC_DS   	; D#
	s_keyon
	s_instr 2
	s_note SC_E    	; E
	s_instr 1
	s_note SC_F    	; F
	s_keyon
	s_note SC_DS   	; D#
	s_note SC_DS   	; D#
	s_instr 2
	s_note SC_E    	; E
	s_instr 3
	s_note SC_DS   	; D#
	s_ret
Snd_3f_54f4:
	s_instr 3
	s_note SC_D    	; D
	s_keyon
	s_instr 2
	s_note SC_D    	; D
	s_keyon
	s_note SC_DS   	; D#
	s_keyon
	s_note SC_E    	; E
	s_instr 3
	s_note SC_DS   	; D#
	s_keyon
	s_instr 4
	s_note SC_E    	; E
	s_instr 2
	s_note SC_F    	; F
	s_keyon
	s_note SC_DS   	; D#
	s_note SC_DS   	; D#
	s_instr 3
	s_note SC_E    	; E
	s_instr 4
	s_note SC_DS   	; D#
	s_ret
Snd_3f_5513:
	s_end
