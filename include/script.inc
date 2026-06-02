; Macros for the Monster Rancher Explorer text-engine bytecode.
; See docs/text_engine.md for the full opcode reference. Each macro
; expands to the exact bytes the dispatcher at HOME:$39C5 will read.
;
; The operand-carrying opcodes accept EITHER positional args or `.Name=value`
; designated initializers (in any order), e.g. both of these are equivalent:
;     SCRIPT_IF_EQ $d60f, $01, .KalumVictory
;     SCRIPT_IF_EQ .Target=.KalumVictory, .Addr=$d60f, .Value=$01
; This is just rgbds-structs' `dstruct` named-init: each macro emits its fixed
; opcode byte, then lays out the operands from a per-opcode struct (below).

    IF !DEF(SCRIPT_INC)
DEF SCRIPT_INC EQU 1

INCLUDE "wram.inc"
; rgbds-structs powers the named-operand support. room.inc usually pulls it in
; first; guard so a standalone script assembly still gets it (and we never
; double-include the unguarded library).
    IF !DEF(STRUCTS_VERSION)
INCLUDE "structs.inc"
    ENDC

; --- Operand layouts (use `words` for 2-byte operands, `bytes` for 1-byte) ---
struct ScriptBox        ; OPEN_TEXTBOX
    words 1, Pos
    bytes 1, Width
    bytes 1, Height
end_struct
struct ScriptCond       ; IF_EQ / IF_NEQ
    words 1, Addr
    bytes 1, Value
    words 1, Target
end_struct
struct ScriptWrite      ; WRITE_WRAM
    words 1, Addr
    bytes 1, Value
end_struct
struct ScriptCall       ; FAR_CALL / RENDERER  ({addr, bank})
    words 1, Addr
    bytes 1, Bank
end_struct
struct ScriptTarget     ; GOTO
    words 1, Target
end_struct
struct ScriptAddr       ; DECIMAL / INDEXED_STR
    words 1, Addr
end_struct
struct ScriptCount      ; CYCLE / REPEAT_CHAR
    bytes 1, Count
end_struct

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

; --- Multi-byte opcodes (positional or .Name=value) ---

; SCRIPT_OPEN_TEXTBOX .Pos, .Width, .Height : set up the dialog box position and
; extents. Stored at $D614/$D615 (anchor, also duplicated into the cursor at
; $D616/$D617), $D618, and $D619. NPCs invoke this once at script entry.
; (5 bytes — $01 lo hi w h)
MACRO SCRIPT_OPEN_TEXTBOX
    db $01
    dstruct ScriptBox, , \#
ENDM

; SCRIPT_GOTO .Target : same-bank jump (3 bytes — $06 lo hi)
MACRO SCRIPT_GOTO
    db $06
    dstruct ScriptTarget, , \#
ENDM

; SCRIPT_FAR_CALL .Addr, .Bank : far Z80 call (4 bytes — $07 lo hi bank)
MACRO SCRIPT_FAR_CALL
    db $07
    dstruct ScriptCall, , \#
ENDM

; SCRIPT_JUMP_TABLE <wram_addr>, <t1>, <t2>, ... : dispatcher (3 + 2N bytes)
; Reads byte at [wram_addr], multiplies by 2, indexes the inline table.
; (variadic — positional only)
MACRO SCRIPT_JUMP_TABLE
    db $08
    dw \1
    SHIFT
    REPT _NARG
        dw \1
        SHIFT
    ENDR
ENDM

; SCRIPT_WRITE_WRAM .Addr, .Value : write val to [addr] (4 bytes — $09 lo hi val)
MACRO SCRIPT_WRITE_WRAM
    db $09
    dstruct ScriptWrite, , \#
ENDM

; SCRIPT_IF_EQ .Addr, .Value, .Target : GOTO target if [addr]==val (6 bytes)
MACRO SCRIPT_IF_EQ
    db $0A
    dstruct ScriptCond, , \#
ENDM

; SCRIPT_IF_NEQ .Addr, .Value, .Target : GOTO target if [addr]!=val (6 bytes)
MACRO SCRIPT_IF_NEQ
    db $0B
    dstruct ScriptCond, , \#
ENDM

; SCRIPT_CYCLE .Count : advance [$D60D] mod count (2 bytes — $0C N)
MACRO SCRIPT_CYCLE
    db $0C
    dstruct ScriptCount, , \#
ENDM

; SCRIPT_RENDERER .Addr, .Bank : set text-renderer to {bank,addr}, stored at
; $D61E/$D61F/$D620. Following text bytes use this renderer. (4 bytes)
MACRO SCRIPT_RENDERER
    db $0E
    dstruct ScriptCall, , \#
ENDM

; SCRIPT_DECIMAL .Addr : print [addr] as a 1- or 2-digit decimal (3 bytes — $0F lo hi)
MACRO SCRIPT_DECIMAL
    db $0F
    dstruct ScriptAddr, , \#
ENDM

; SCRIPT_REPEAT_CHAR .Count : print the next text-char N times (2 bytes — $10 N)
MACRO SCRIPT_REPEAT_CHAR
    db $10
    dstruct ScriptCount, , \#
ENDM

; SCRIPT_INDEXED_STR .Addr : print indexed string via table at $3B75 (3 bytes — $11 lo hi)
MACRO SCRIPT_INDEXED_STR
    db $11
    dstruct ScriptAddr, , \#
ENDM

    ENDC ; SCRIPT_INC
