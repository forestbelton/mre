; Sound id $19 (SFX) -- ?
; Bank $3f, ROM $547a-$54b6. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $19", ROMX

; ===== sound id $19 =====
Snd_SFX_19:
	s_chan $00, Snd_3f_54b6
	s_chan $00, Snd_3f_54b6
	s_chan $00, Snd_3f_54b6
	s_chan $f0, Snd_3f_5486
Snd_3f_5486:
	s_deflen 1
	s_pitchenv 0
	s_oct 1	; block 0
	s_instr 5
	s_note SC_C    	; C
	s_note SC_REST 	; rest
	s_deflen 3
	s_instr 1
	s_note SC_D    	; D
	s_instr 0
	s_note SC_E    	; E
	s_instr 1
	s_note SC_E    	; E
	s_keyon
	s_note SC_F    	; F
	s_keyon
	s_deflen 3
	s_pitchenv 0
	s_instr 0
	s_note SC_E    	; E
	s_keyon
	s_note SC_F    	; F
	s_keyon
	s_note SC_G    	; G
	s_keyon
	s_keyon
	s_instr 3
	s_note SC_G    	; G
	s_keyon
	s_instr 4
	s_note SC_F    	; F
	s_keyon
	s_instr 5
	s_note SC_E    	; E
	s_end
Snd_3f_54b6:
	s_end
