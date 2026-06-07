; Sound song/SFX bytecode macros (driver banks $3f/$3e, region $4b00-$7fff).
; One macro per opcode; each assembles to the exact bytes the channel-stream
; interpreter (Func_3f_414a) consumes. See docs/sound_engine.md for semantics
; and tools/songdisasm.py for the (dis)assembler. Mirrors include/entity_script.inc.
;
; A song is: a $4b00 pointer table (s_songptr) -> 12-byte descriptors (4x s_chan)
; -> per-channel op-streams (notes + commands) -> the pattern subroutines they
; s_call. All pointers are offsets/relatives the macros compute from labels, so
; the source has no hard ROM offsets in the operands.

IF !DEF(SOUND_INC)
DEF SOUND_INC EQU 1

DEF SOUND_BANK_0 EQU $3f    ; primary: sound ids $00-$2e (SFX + BGM $28-$2e)
DEF SOUND_BANK_1 EQU $3e    ; secondary: BGM ids $2f-$3a
DEF SND_BASE EQU $4b00      ; table/descriptor offsets are relative to here

; --- note columns (note & $0f -> semitone); $07/$0f are rests. Cols 10/14 are
;     enharmonic duplicates of F/C, kept distinct so the encoding round-trips. ---
DEF SC_C    EQU $00
DEF SC_D    EQU $01
DEF SC_E    EQU $02
DEF SC_F    EQU $03
DEF SC_G    EQU $04
DEF SC_A    EQU $05
DEF SC_B    EQU $06
DEF SC_REST EQU $07
DEF SC_CS   EQU $08
DEF SC_DS   EQU $09
DEF SC_ES   EQU $0a         ; E# (= F)
DEF SC_FS   EQU $0b
DEF SC_GS   EQU $0c
DEF SC_AS   EQU $0d
DEF SC_BS   EQU $0e         ; B# (= C, next octave)
DEF SC_REST2 EQU $0f

; ---- notes (bit7=0). byte = (pan<<5) | (len_flag<<4) | col. pan 3 = center. ----
MACRO s_note            ; \1 col            ; pan=3, default length
    db $60 | (\1)
ENDM
MACRO s_note_l          ; \1 col, \2 frames ; pan=3, explicit length
    db $70 | (\1), \2
ENDM
MACRO s_note_p          ; \1 pan, \2 col    ; explicit pan, default length
    db ((\1) << 5) | (\2)
ENDM
MACRO s_note_pl         ; \1 pan, \2 col, \3 frames ; explicit pan + length
    db ((\1) << 5) | $10 | (\2), \3
ENDM

; ---- commands (bit7 set) ----
MACRO s_oct             ; \1 nibble (1-8); selects freq-table row (block = n-1)
    db $90 | (\1)
ENDM
MACRO s_wave    ; \1 idx  ; $ea load CH3 waveform $4760[idx]
    db $ea, \1
ENDM
MACRO s_loopback         ; $eb  dec loop counter; jump to loop point if nonzero
    db $eb
ENDM
MACRO s_setloop ; \1 cnt  ; $ec set loop count, loop point = here
    db $ec, \1
ENDM
MACRO s_dutyenv ; \1 idx  ; $ed load duty/length envelope $4754[idx]
    db $ed, \1
ENDM
MACRO s_sweep   ; \1 n    ; $ee set CH1 sweep (NR10)
    db $ee, \1
ENDM
MACRO s_set10   ; \1 n    ; $ef set voice +$10
    db $ef, \1
ENDM
MACRO s_nop              ; $f0 marker / skip
    db $f0
ENDM
MACRO s_rawcmd  ; \1 op   ; $f1-$f7 reserved opcodes (only in unused data)
    db \1
ENDM
MACRO s_ret              ; $f8 return to saved pointer
    db $f8
ENDM
MACRO s_call    ; \1 label ; $f9 call (target = opcode_addr + rel16)
    db $f9
    dw \1 - @ + 1
ENDM
MACRO s_goto    ; \1 label ; $fa goto (target = opcode_addr + rel16)
    db $fa
    dw \1 - @ + 1
ENDM
MACRO s_pitchenv ; \1 idx ; $fb load pitch envelope $474c[idx]
    db $fb, \1
ENDM
MACRO s_instr   ; \1 idx  ; $fc set instrument / volume envelope $4708[idx]
    db $fc, \1
ENDM
MACRO s_deflen  ; \1 n    ; $fd default note length (frames) for length-less notes
    db $fd, \1
ENDM
MACRO s_keyon            ; $fe key-on flag
    db $fe
ENDM
MACRO s_end              ; $ff end of channel stream
    db $ff
ENDM

; ---- structure ----
MACRO s_chan    ; \1 priority, \2 stream-label ; one descriptor channel record
    db \1
    dw \2 - SND_BASE
ENDM

MACRO SOUND_TABLE
	DEF _count = 0
ENDM

MACRO SOUND
    dw \1 - SND_BASE
	DEF _count += 1
ENDM

MACRO END_SOUND_TABLE
	ASSERT _count <= $100
	REPT $100 - _count
        SOUND Snd_3e_4d00
	ENDR
	PURGE _count
ENDM

ENDC
