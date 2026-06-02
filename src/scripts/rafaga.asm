; Rafaga (tower NPC, third encounter).
;
; Introduces himself as "Nada's servant" and acknowledges the
; player's prior victories ("You beat Kalum and Mistral. I must ask
; you to leave."). Same tower-battle shape as Kalum and Mistral —
; three SCRIPT_END branches for pre-battle / post-win / post-lose.
;
; Carved out of analyzed.asm via map.json; see docs/text_engine.md
; for the bytecode reference. Initial dump produced by
; tools/script_disasm.py — hand-curate freely; the extractor's
; append-only rule on non-auto-managed files preserves your edits.

INCLUDE "script.inc"

SECTION "rafaga_07c857", ROMX[$4857], BANK[$1f]


RafagaScript:
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$01, .Target=.RafagaVictory
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$02, .Target=.RafagaDefeat
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    db "Hello. You're"
    SCRIPT_NEWLINE
    db "finally here."
    SCRIPT_WAIT
    db "I am Rafaga."
    SCRIPT_NEWLINE
    db "Nada's servant."
    SCRIPT_WAIT
    db "I'm surprised"
    SCRIPT_NEWLINE
    db "you made it here"
    SCRIPT_WAIT
    db "You beat Kalum"
    SCRIPT_NEWLINE
    db "and Mistral."
    SCRIPT_WAIT
    db "I must ask you"
    SCRIPT_NEWLINE
    db "to leave here or"
    SCRIPT_WAIT
    db "Nada will be"
    SCRIPT_NEWLINE
    db "mad at me."
    SCRIPT_WAIT
    db "So I'm going to"
    SCRIPT_NEWLINE
    db "be serious now."
    SCRIPT_WAIT
    db "Wake up Punisher"
    SCRIPT_NEWLINE
    db "Time to fight."
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL .Addr=$47a8, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=$47b1, .Bank=$1f
    SCRIPT_REPEAT_CHAR .Count=90
    SCRIPT_END
.RafagaVictory:
    db "This is bad."
    SCRIPT_NEWLINE
    db "I've lost, too."
    SCRIPT_WAIT
    db "Frankly,"
    SCRIPT_NEWLINE
    db "I am shocked."
    SCRIPT_WAIT
    db "Punisher, Nada"
    SCRIPT_NEWLINE
    db "had given to me."
    SCRIPT_WAIT
    db "I must report it"
    SCRIPT_NEWLINE
    db "Nada will be mad"
    SCRIPT_WAIT
    db "You will regret"
    SCRIPT_NEWLINE
    db "this defeat."
    SCRIPT_WAIT
    SCRIPT_END
.RafagaDefeat:
    db "Whew."
    SCRIPT_NEWLINE
    db "I guess"
    SCRIPT_WAIT
    db "Nada won't"
    SCRIPT_NEWLINE
    db "be mad at me."
    SCRIPT_WAIT
    db "Let this be a"
    SCRIPT_NEWLINE
    db "lesson to you."
    SCRIPT_WAIT
    db "Don't think of"
    SCRIPT_NEWLINE
    db "any thing stupid"
    SCRIPT_WAIT
    db "Now, please."
    SCRIPT_NEWLINE
    db "Quietly leave."
    SCRIPT_WAIT
    SCRIPT_END
