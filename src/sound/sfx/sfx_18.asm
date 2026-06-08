; Sound id $18 (SFX) -- ?
; Bank $3f, ROM $5433-$5479. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $18", ROMX

; ===== sound id $18 =====
Snd_3f_5433:
	s_chan $00, Snd_3f_5479
	s_chan $00, Snd_3f_5479
	s_chan $00, Snd_3f_5479
	s_chan $f0, Snd_3f_543f
Snd_3f_543f:
	s_deflen 1
	s_pitchenv 0
	s_oct 1	; block 0
	s_instr 0
	s_note SC_CS   	; C#
	s_keyon
	s_deflen 3
	s_pitchenv 0
	s_instr 0
	s_note SC_D    	; D
	s_keyon
	s_note SC_DS   	; D#
	s_keyon
	s_deflen 5
	s_pitchenv 0
	s_note SC_E    	; E
	s_keyon
	s_note SC_E    	; E
	s_keyon
	s_deflen 2
	s_pitchenv 0
	s_instr 2
	s_note SC_DS   	; D#
	s_note SC_DS   	; D#
	s_keyon
	s_deflen 1
	s_pitchenv 0
	s_note SC_C    	; C
	s_keyon
	s_instr 2
	s_note SC_C    	; C
	s_keyon
	s_instr 3
	s_note SC_C    	; C
	s_keyon
	s_instr 4
	s_note SC_C    	; C
	s_keyon
	s_instr 5
	s_note SC_C    	; C
	s_end
Snd_3f_5479:
	s_end
