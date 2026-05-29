; Kalum (tower NPC).
; 
; References "climb up here" — Kalum is a tower-level NPC the player
; encounters during their ascent.
;
; Carved out of analyzed.asm via map.json; see docs/text_engine.md
; for the bytecode reference. Initial dump produced by
; tools/script_disasm.py — hand-curate freely; the extractor's
; append-only rule on non-auto-managed files preserves your edits.

INCLUDE "script.inc"

SECTION "kalum_07c2bd", ROMX[$42bd], BANK[$1f]


KalumScript:
    SCRIPT_OPEN_TEXTBOX $9982, $10, $04
    db "Wow! I can't"
    SCRIPT_NEWLINE
    db "believe people"
    SCRIPT_WAIT
    db "still climb up"
    SCRIPT_NEWLINE
    db "here."
    SCRIPT_WAIT
    db "I've been bored"
    SCRIPT_NEWLINE
    db "lately."
    SCRIPT_WAIT
    db "It's time to"
    SCRIPT_NEWLINE
    db "have some fun!"
    SCRIPT_WAIT
    db "Let's go,"
    SCRIPT_NEWLINE
    db "Selketo!"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL $41f2, $1f
    SCRIPT_FAR_CALL $41fb, $1f
    SCRIPT_REPEAT_CHAR 90
    SCRIPT_END
    db "Unbelievable..."
    SCRIPT_WAIT
    db "My Selketo"
    SCRIPT_NEWLINE
    db "lost..."
    SCRIPT_WAIT
    db "Heh! Even if you"
    SCRIPT_NEWLINE
    db "beat me..."
    SCRIPT_WAIT
    db "Stronger guys"
    SCRIPT_NEWLINE
    db "are up here!"
    SCRIPT_WAIT
    SCRIPT_END
    db "Hm. Im sorry"
    SCRIPT_NEWLINE
    db "to say, but..."
    SCRIPT_WAIT
    db "At your level,"
    SCRIPT_NEWLINE
    db "it's the same"
    SCRIPT_WAIT
    db "regardless of"
    SCRIPT_NEWLINE
    db "your attempts."
    SCRIPT_WAIT
    db "Don't like it"
    SCRIPT_NEWLINE
    db "Practice harder!"
    SCRIPT_WAIT
    SCRIPT_END
