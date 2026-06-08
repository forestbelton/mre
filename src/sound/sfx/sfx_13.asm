; Sound id $13 (SFX) -- ?
; Bank $3f, ROM $524c-$5282. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $13", ROMX

; ===== sound id $13 =====
Snd_SFX_13:
	s_chan $00, Snd_3f_5282
	s_chan $00, Snd_3f_5282
	s_chan $00, Snd_3f_5282
	s_chan $f0, Snd_3f_5258
Snd_3f_5258:
	s_deflen 4
	s_pitchenv 0
	s_oct 1	; block 0
	s_instr 0
	s_note SC_C    	; C
	s_note SC_CS   	; C#
	s_note SC_D    	; D
	s_note SC_CS   	; C#
	s_note SC_F    	; F
	s_note SC_FS   	; F#
	s_note SC_G    	; G
	s_note SC_GS   	; G#
	s_deflen 12
	s_pitchenv 0
	s_instr 0
	s_note SC_G    	; G
	s_deflen 9
	s_pitchenv 0
	s_instr 0
	s_note SC_G    	; G
	s_instr 1
	s_note SC_G    	; G
	s_instr 2
	s_note SC_G    	; G
	s_instr 3
	s_note SC_G    	; G
	s_instr 4
	s_note SC_G    	; G
	s_end
Snd_3f_5282:
	s_end
