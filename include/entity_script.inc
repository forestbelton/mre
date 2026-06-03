; Entity-script VM opcodes (bank $03). One macro per opcode; each assembles to
; the exact bytecode the interpreter (RunEntityScript, $4042) consumes. See
; docs/entity_scripts.md for semantics and tools/entity_script_disasm.py.
;
; Operand conventions:
;   \1.. = immediate bytes / 16-bit values (little-endian via dw)
;   branch macros take a script label; ent_call/ent_*_indexed take a raw $addr
;   into bank-$03 code/data space.

IF !DEF(ENTITY_SCRIPT_INC)
DEF ENTITY_SCRIPT_INC EQU 1

MACRO ent_despawn       ; $00  free the slot (terminator)
    db $00
ENDM
MACRO ent_set_type      ; $01 t
    db $01, \1
ENDM
MACRO ent_vel_x_zero    ; $02
    db $02
ENDM
MACRO ent_set_vel_x     ; $03 v16 (signed X velocity)
    db $03
    dw \1
ENDM
MACRO ent_vel_x_indexed ; $04 tbl  (X velocity = tbl[$ffd1&7])
    db $04
    dw \1
ENDM
MACRO ent_set_xflip     ; $05 a    ($ffb6 bit7, left/right facing)
    db $05, \1
ENDM
MACRO ent_set_facing    ; $06 a    ($ffb6 low bits, 4-dir)
    db $06, \1
ENDM
MACRO ent_gfx           ; $07 a    (select sprite/animation)
    db $07, \1
ENDM
MACRO ent_set_timer     ; $08 n    ($ffc6)
    db $08, \1
ENDM
MACRO ent_timer_tick    ; $09
    db $09
ENDM
MACRO ent_loop_timer    ; $0a L    (dec $ffc6; if !=0 jump L, yielding)
    db $0a
    dw \1
ENDM
MACRO ent_wait_timer    ; $0b      (block until $ffc6 == 0)
    db $0b
ENDM
MACRO ent_yield         ; $0c      (sleep one frame)
    db $0c
ENDM
MACRO ent_spawn_rel     ; $0d xo, yo, t
    db $0d, \1, \2, \3
ENDM
MACRO ent_set_flag2     ; $0e a    ($ffb6 bit2)
    db $0e, \1
ENDM
MACRO ent_begin_action  ; $0f      ($ffb4 bit7, $ffc7=$14)
    db $0f
ENDM
MACRO ent_update_action ; $10
    db $10
ENDM
MACRO ent_call          ; $16 addr (call native bank-$03 asm, then resume)
    db $16
    dw \1
ENDM
MACRO ent_call_bank0    ; $17 b, w16  (call bank-$00 $1150)
    db $17, \1
    dw \2
ENDM
MACRO ent_load_b8       ; $18 addr ($ffb8 = [addr])
    db $18
    dw \1
ENDM
MACRO ent_and_b8        ; $19 m
    db $19, \1
ENDM
MACRO ent_test_b8       ; $1a m
    db $1a, \1
ENDM
MACRO ent_cmp_b8        ; $1b v
    db $1b, \1
ENDM
MACRO ent_set_vel_y     ; $1c v16  ($ffc1/$ffc2)
    db $1c
    dw \1
ENDM
MACRO ent_wait_counter  ; $1d      (block until $ffc1/$ffc2 == 0)
    db $1d
ENDM
MACRO ent_jump          ; $20 L
    db $20
    dw \1
ENDM
MACRO ent_jr_busy       ; $21 L    (if $ffb7 bit0)
    db $21
    dw \1
ENDM
MACRO ent_jr_free       ; $22 L    (if !$ffb7 bit0)
    db $22
    dw \1
ENDM
MACRO ent_jr_hit        ; $23 L    (if $ffb7 bit1)
    db $23
    dw \1
ENDM
MACRO ent_jr_nohit      ; $24 L    (if !$ffb7 bit1)
    db $24
    dw \1
ENDM
MACRO ent_jr_timer0     ; $25 L    (if $ffc6 == 0)
    db $25
    dw \1
ENDM
MACRO ent_jr_timer_nz   ; $26 L    (if $ffc6 != 0)
    db $26
    dw \1
ENDM
MACRO ent_jr_b8_eq      ; $27 v, L (if $ffb8 == v)
    db $27, \1
    dw \2
ENDM
MACRO ent_jr_b8_ne      ; $28 v, L (if $ffb8 != v)
    db $28, \1
    dw \2
ENDM

ENDC
