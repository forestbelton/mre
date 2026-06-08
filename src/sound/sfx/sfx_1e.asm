; Sound id $1e (SFX) -- ?
; Bank $3f, ROM $55fe-$562f. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $1e", ROMX

; ===== sound id $1e =====
Snd_SFX_1e:
	s_chan $00, Snd_3f_562f
	s_chan $f0, Snd_3f_560a
	s_chan $00, Snd_3f_562f
	s_chan $00, Snd_3f_562f
Snd_3f_560a:
	s_pitchenv 1
	s_deflen 2
	s_set10 0
	s_dutyenv 2
	s_oct 7	; block 6
	s_instr 0
	s_note SC_D    	; D
	s_note SC_D    	; D
	s_keyon
	s_note SC_E    	; E
	s_instr 2
	s_note SC_D    	; D
	s_keyon
	s_note SC_E    	; E
	s_oct 8	; block 7
	s_instr 0
	s_note SC_D    	; D
	s_keyon
	s_note SC_E    	; E
	s_instr 3
	s_note SC_D    	; D
	s_keyon
	s_note SC_E    	; E
	s_instr 5
	s_note SC_D    	; D
	s_keyon
	s_note SC_E    	; E
	s_end
Snd_3f_562f:
	s_end
