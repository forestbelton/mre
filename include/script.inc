; Macros for the Monster Rancher Explorer text-engine bytecode.
; See docs/text_engine.md for the full opcode reference. Each macro
; expands to the exact bytes the dispatcher at HOME:$39C5 will read.
;
; Macros are added on demand — only opcodes currently used by an
; extracted script need a macro here. Anything not yet covered can
; still be emitted as raw `db` until it's worth wrapping.

    IF !DEF(SCRIPT_INC)
DEF SCRIPT_INC EQU 1

; --- Single-byte opcodes (used inline as `db DB_WAIT` etc.) ---
DEF DB_WAIT    EQU $04     ; wait for A — end of message
DEF DB_NEWLINE EQU $0D     ; in-message newline
DEF DB_END     EQU $FF     ; end of script

; --- Multi-byte opcodes (macros to keep argument syntax clean) ---

; db_goto <target> : same-bank jump (3 bytes)
MACRO db_goto
    db $06
    dw \1
ENDM

    ENDC ; SCRIPT_INC
