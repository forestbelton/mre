; Naji (the Tower-guard NPC). See docs/text_engine.md for the bytecode
; reference. Each region is carved out of analyzed.asm via map.json and
; rewritten here using the macros from include/script.inc.

INCLUDE "script.inc"

SECTION "naji_063966", ROMX[$7966], BANK[$18]

; Ask submenu, "Stop" branch — bare GOTO back to the main "What are
; your plans this time?" prompt at $7483 (= step 14 in the pseudocode).
; This is the smallest possible script and was the empirical evidence
; that $06 is a GOTO opcode.
NajiAskStop:
    db_goto $7483
