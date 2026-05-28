; Macros for the Monster Rancher Explorer text-engine bytecode.
; See docs/text_engine.md for the full opcode reference. Each macro
; expands to the exact bytes the dispatcher at HOME:$39C5 will read.

    IF !DEF(SCRIPT_INC)
DEF SCRIPT_INC EQU 1

; --- Single-byte opcodes ---

MACRO script_anchor
    db $02      ; reset render anchor (used before script_jump_table)
ENDM

MACRO script_yn_cue
    db $03      ; cue placed before every Y/N menu setup
ENDM

MACRO script_wait
    db $04      ; wait for A — end of message
ENDM

MACRO script_newline
    db $0D      ; in-message newline
ENDM

MACRO script_end
    db $FF      ; end of script — dispatcher returns
ENDM

; --- Multi-byte opcodes ---

; script_goto <target> : same-bank jump (3 bytes — $06 lo hi)
MACRO script_goto
    db $06
    dw \1
ENDM

; script_far_call <addr>, <bank> : far Z80 call (4 bytes — $07 lo hi bank)
MACRO script_far_call
    db $07
    dw \1
    db \2
ENDM

; script_jump_table <wram_addr>, <t1>, <t2>, ... : dispatcher (3 + 2N bytes)
; Reads byte at [wram_addr], multiplies by 2, indexes the inline table.
MACRO script_jump_table
    db $08
    dw \1
    SHIFT
    REPT _NARG
        dw \1
        SHIFT
    ENDR
ENDM

; script_write_wram <wram_addr>, <value> : write val to [addr] (4 bytes — $09 lo hi val)
MACRO script_write_wram
    db $09
    dw \1
    db \2
ENDM

; script_if_eq <wram_addr>, <value>, <target> : GOTO target if [addr]==val (6 bytes)
MACRO script_if_eq
    db $0A
    dw \1
    db \2
    dw \3
ENDM

; script_if_neq <wram_addr>, <value>, <target> : GOTO target if [addr]!=val (6 bytes)
MACRO script_if_neq
    db $0B
    dw \1
    db \2
    dw \3
ENDM

; script_cycle <count> : advance [$D60D] mod count (2 bytes — $0C N)
MACRO script_cycle
    db $0C, \1
ENDM

; script_renderer <addr>, <bank> : set text-renderer to {bank,addr}, stored
; at $D61E/$D61F/$D620. Following text bytes use this renderer. (4 bytes)
MACRO script_renderer
    db $0E
    dw \1
    db \2
ENDM

; script_decimal <wram_addr> : print [addr] as a 1- or 2-digit decimal (3 bytes — $0F lo hi)
MACRO script_decimal
    db $0F
    dw \1
ENDM

; script_repeat_char <count> : print the next text-char N times (2 bytes — $10 N)
MACRO script_repeat_char
    db $10, \1
ENDM

; script_indexed_str <wram_addr> : print indexed string via table at $3B75 (3 bytes — $11 lo hi)
MACRO script_indexed_str
    db $11
    dw \1
ENDM

    ENDC ; SCRIPT_INC
