; The Letter from Cox (bank 19).
;
; A static written note the player reads. Unlike spoken dialog,
; this script has only $0D line-breaks and a single $FF terminator
; with no $04 waits — it renders as a scrollable letter / box of
; text rather than message-by-message NPC speech.
;
; "Cox" is mentioned in the doc; he might be a character or the
; letter's author. Worth checking against the in-game context.

INCLUDE "text.inc"

SECTION "letter_from_cox", ROMX[$47ff], BANK[$13]


LetterFromCox:
    db "Hello. I'm off "
    SCRIPT_NEWLINE
    db "to the ruins."
    SCRIPT_NEWLINE
    db "I'm going to "
    SCRIPT_NEWLINE
    db "Mt. Sekitoba."
    SCRIPT_NEWLINE
    db "If I'm not back"
    SCRIPT_NEWLINE
    db "in 2 weeks, "
    SCRIPT_WAIT
    db "come and look "
    SCRIPT_NEWLINE
    db "for me,okay? "
    SCRIPT_NEWLINE
    db " "
    SCRIPT_NEWLINE
    db " "
    SCRIPT_NEWLINE
    db "         Cox"
    SCRIPT_END
