; Sound id $09 (SFX) -- ?
; Bank $3f, ROM $4eaa-$4f04. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $09", ROMX

; ===== sound id $09 =====
Snd_3f_4eaa:
	s_chan $f0, Snd_3f_4eb6
	s_chan $f0, Snd_3f_4ed0
	s_chan $f0, Snd_3f_4eea
	s_chan $00, Snd_3f_4f04
Snd_3f_4eb6:
	s_pitchenv 0
	s_set10 0
	s_dutyenv 1
	s_instr 1
	s_oct 5	; block 4
	s_note_l SC_E, 15	; E dur=15
	s_note_l SC_F, 5	; F dur=5
	s_deflen 10
	s_note SC_G    	; G
	s_note SC_E    	; E
	s_deflen 5
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_G    	; G
	s_note_l SC_F, 20	; F dur=20
	s_end
Snd_3f_4ed0:
	s_pitchenv 0
	s_set10 0
	s_dutyenv 1
	s_instr 1
	s_oct 5	; block 4
	s_note_l SC_E, 15	; E dur=15
	s_note_l SC_F, 5	; F dur=5
	s_deflen 10
	s_note SC_G    	; G
	s_note SC_E    	; E
	s_deflen 5
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_G    	; G
	s_note_l SC_F, 20	; F dur=20
	s_end
Snd_3f_4eea:
	s_pitchenv 0
	s_set10 0
	s_wave 10
	s_instr 20
	s_oct 4	; block 3
	s_note_l SC_E, 15	; E dur=15
	s_note_l SC_F, 5	; F dur=5
	s_deflen 10
	s_note SC_G    	; G
	s_note SC_E    	; E
	s_deflen 5
	s_note SC_F    	; F
	s_note SC_E    	; E
	s_note SC_F    	; F
	s_note SC_G    	; G
	s_note_l SC_F, 20	; F dur=20
	s_end
Snd_3f_4f04:
	s_end
