; Macros for the Monster Rancher Explorer text-engine bytecode.
; See docs/text_engine.md for the full opcode reference. Each macro
; expands to the exact bytes the dispatcher at HOME:$39C5 will read.

    IF !DEF(SCRIPT_INC)
DEF SCRIPT_INC EQU 1

; --- Single-byte opcodes (use inline as `db DB_WAIT` etc.) ---
DEF DB_WAIT    EQU $04    ; wait for A — end of message
DEF DB_YN_CUE  EQU $03    ; cue placed before every Y/N menu setup
DEF DB_NEWLINE EQU $0D    ; in-message newline
DEF DB_ANCHOR  EQU $02    ; reset render anchor (used before a jump_table)
DEF DB_END     EQU $FF    ; end of script — dispatcher returns

; --- Multi-byte opcodes (macros to keep argument syntax clean) ---

; db_goto <target> : same-bank jump (3 bytes — $06 lo hi)
MACRO db_goto
    db $06
    dw \1
ENDM

; db_far_call <addr>, <bank> : far Z80 call (4 bytes — $07 lo hi bank)
MACRO db_far_call
    db $07
    dw \1
    db \2
ENDM

; db_jump_table <wram_addr>, <t1>, <t2>, ... : dispatcher (3 + 2N bytes)
; Reads byte at [wram_addr], multiplies by 2, indexes the inline table.
MACRO db_jump_table
    db $08
    dw \1
    SHIFT
    REPT _NARG
        dw \1
        SHIFT
    ENDR
ENDM

; db_write_wram <wram_addr>, <value> : write val to [addr] (4 bytes — $09 lo hi val)
MACRO db_write_wram
    db $09
    dw \1
    db \2
ENDM

; db_if_eq <wram_addr>, <value>, <target> : GOTO target if [addr]==val (6 bytes)
MACRO db_if_eq
    db $0A
    dw \1
    db \2
    dw \3
ENDM

; db_if_neq <wram_addr>, <value>, <target> : GOTO target if [addr]!=val (6 bytes)
MACRO db_if_neq
    db $0B
    dw \1
    db \2
    dw \3
ENDM

; db_cycle <count> : advance [$D60D] mod count (2 bytes — $0C N)
MACRO db_cycle
    db $0C, \1
ENDM

; db_renderer <addr>, <bank> : set text-renderer to {bank,addr}, stored
; at $D61E/$D61F/$D620. Following text bytes use this renderer. (4 bytes)
MACRO db_renderer
    db $0E
    dw \1
    db \2
ENDM

; db_decimal <wram_addr> : print [addr] as a 1- or 2-digit decimal (3 bytes — $0F lo hi)
MACRO db_decimal
    db $0F
    dw \1
ENDM

; db_repeat_char <count> : print the next text-char N times (2 bytes — $10 N)
MACRO db_repeat_char
    db $10, \1
ENDM

; db_indexed_str <wram_addr> : print indexed string via table at $3B75 (3 bytes — $11 lo hi)
MACRO db_indexed_str
    db $11
    dw \1
ENDM

    ENDC ; SCRIPT_INC
