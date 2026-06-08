; Sound id $0d (SFX) -- UI confirm
; Bank $3f, ROM $5031-$505a. INCLUDEd by sound/bank0.asm into its $4b00 section.

INCLUDE "sound.inc"

SECTION "SFX - $0d", ROMX

; ===== sound id $0d =====
Snd_3f_5031:
	s_chan $00, Snd_3f_505a
	s_chan $f0, Snd_3f_503d
	s_chan $00, Snd_3f_505a
	s_chan $00, Snd_3f_505a
Snd_3f_503d:
	s_pitchenv 0
	s_set10 0
	s_dutyenv 2
	s_instr 0
	s_oct 5	; block 4
	s_note_l SC_C, 1	; C dur=1
	s_oct 7	; block 6
	s_note_l SC_C, 12	; C dur=12
	s_deflen 5
	s_instr 1
	s_note SC_C    	; C
	s_instr 2
	s_note SC_C    	; C
	s_instr 3
	s_note SC_C    	; C
	s_instr 4
	s_note SC_C    	; C
	s_end
Snd_3f_505a:
	s_end
