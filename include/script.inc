; Macros for the Monster Rancher Explorer text-engine bytecode.
; See docs/text_engine.md for the full opcode reference. Each macro
; expands to the exact bytes the dispatcher at HOME:$39C5 will read.

    IF !DEF(SCRIPT_INC)
DEF SCRIPT_INC EQU 1

; --- Single-byte opcodes ---

MACRO SCRIPT_ANCHOR
    db $02      ; reset render anchor (used before SCRIPT_JUMP_TABLE)
ENDM

MACRO SCRIPT_YN_CUE
    db $03      ; cue placed before every Y/N menu setup
ENDM

MACRO SCRIPT_WAIT
    db $04      ; wait for A — end of message
ENDM

MACRO SCRIPT_NEWLINE
    db $0D      ; in-message newline
ENDM

MACRO SCRIPT_END
    db $FF      ; end of script — dispatcher returns
ENDM

; --- Multi-byte opcodes ---

; SCRIPT_GOTO <target> : same-bank jump (3 bytes — $06 lo hi)
MACRO SCRIPT_GOTO
    db $06
    dw \1
ENDM

; SCRIPT_FAR_CALL <addr>, <bank> : far Z80 call (4 bytes — $07 lo hi bank)
MACRO SCRIPT_FAR_CALL
    db $07
    dw \1
    db \2
ENDM

; SCRIPT_JUMP_TABLE <wram_addr>, <t1>, <t2>, ... : dispatcher (3 + 2N bytes)
; Reads byte at [wram_addr], multiplies by 2, indexes the inline table.
MACRO SCRIPT_JUMP_TABLE
    db $08
    dw \1
    SHIFT
    REPT _NARG
        dw \1
        SHIFT
    ENDR
ENDM

; SCRIPT_WRITE_WRAM <wram_addr>, <value> : write val to [addr] (4 bytes — $09 lo hi val)
MACRO SCRIPT_WRITE_WRAM
    db $09
    dw \1
    db \2
ENDM

; SCRIPT_IF_EQ <wram_addr>, <value>, <target> : GOTO target if [addr]==val (6 bytes)
MACRO SCRIPT_IF_EQ
    db $0A
    dw \1
    db \2
    dw \3
ENDM

; SCRIPT_IF_NEQ <wram_addr>, <value>, <target> : GOTO target if [addr]!=val (6 bytes)
MACRO SCRIPT_IF_NEQ
    db $0B
    dw \1
    db \2
    dw \3
ENDM

; SCRIPT_CYCLE <count> : advance [$D60D] mod count (2 bytes — $0C N)
MACRO SCRIPT_CYCLE
    db $0C, \1
ENDM

; SCRIPT_RENDERER <addr>, <bank> : set text-renderer to {bank,addr}, stored
; at $D61E/$D61F/$D620. Following text bytes use this renderer. (4 bytes)
MACRO SCRIPT_RENDERER
    db $0E
    dw \1
    db \2
ENDM

; SCRIPT_DECIMAL <wram_addr> : print [addr] as a 1- or 2-digit decimal (3 bytes — $0F lo hi)
MACRO SCRIPT_DECIMAL
    db $0F
    dw \1
ENDM

; SCRIPT_REPEAT_CHAR <count> : print the next text-char N times (2 bytes — $10 N)
MACRO SCRIPT_REPEAT_CHAR
    db $10, \1
ENDM

; SCRIPT_INDEXED_STR <wram_addr> : print indexed string via table at $3B75 (3 bytes — $11 lo hi)
MACRO SCRIPT_INDEXED_STR
    db $11
    dw \1
ENDM

    ENDC ; SCRIPT_INC
