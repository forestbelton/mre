; Mistral (tower NPC).
;
; References Kalum in her first message ("That means Kalum lost"),
; placing her as a tower NPC the player encounters after defeating
; Kalum. Sics her monster Ferious on the player; three SCRIPT_END
; branches handle pre-battle, post-win, and post-lose like Kalum.
;
; Carved out of analyzed.asm via map.json; see docs/text_engine.md
; for the bytecode reference. Initial dump produced by
; tools/script_disasm.py — hand-curate freely; the extractor's
; append-only rule on non-auto-managed files preserves your edits.

INCLUDE "script.inc"

SECTION "mistral_07c5a5", ROMX[$45a5], BANK[$1f]


MistralScript:
    ; Greeting selector on $d60f (encounter state); launcher enters here at $45a5.
    SCRIPT_IF_EQ .Addr=$d60f, .Value=$01, .Target=.MistralVictory
    SCRIPT_IF_EQ .Addr=$d60f, .Value=$02, .Target=.MistralDefeat
    ; Default greeting — was the mislabeled start at $45b1:
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    db "Oh?"
    SCRIPT_NEWLINE
    db "I haven't had a"
    SCRIPT_WAIT
    db "guest in a while"
    SCRIPT_WAIT
    db "That means"
    SCRIPT_NEWLINE
    db "Kalum lost."
    SCRIPT_WAIT
    db "I guess you're"
    SCRIPT_NEWLINE
    db "pretty good."
    SCRIPT_WAIT
    db "Ferious isn't"
    SCRIPT_NEWLINE
    db "easy to defeat!"
    SCRIPT_WAIT
    db "Ferious! Come!"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL .Addr=$4488, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=$4491, .Bank=$1f
    SCRIPT_REPEAT_CHAR .Count=90
    SCRIPT_END
.MistralVictory:
    db "I... lost?"
    SCRIPT_WAIT
    db "Don't boast"
    SCRIPT_NEWLINE
    db "so soon!"
    SCRIPT_WAIT
    db "You didn't beat"
    SCRIPT_NEWLINE
    db "anybody else yet"
    SCRIPT_WAIT
    db "Now,"
    SCRIPT_NEWLINE
    db "you can go!"
    SCRIPT_WAIT
    db "I'll let you"
    SCRIPT_NEWLINE
    db "pass this time."
    SCRIPT_WAIT
    SCRIPT_END
.MistralDefeat:
    db "Hmph!"
    SCRIPT_WAIT
    db "After all,"
    SCRIPT_NEWLINE
    db "I'm stronger."
    SCRIPT_WAIT
    db "Well, later on"
    SCRIPT_NEWLINE
    db "I have to give"
    SCRIPT_WAIT
    db "Kalum a tip"
    SCRIPT_NEWLINE
    db "on fighting."
    SCRIPT_WAIT
    db "I'll fight you"
    SCRIPT_NEWLINE
    db "again any time"
    SCRIPT_WAIT
    db "if you could"
    SCRIPT_NEWLINE
    db "come here again."
    SCRIPT_WAIT
    SCRIPT_END
