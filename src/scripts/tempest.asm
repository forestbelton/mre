; Tempest (tower NPC, fourth of Nada's henchmen).
;
; Identifies himself in his first message ("I, Tempest, must fight
; now. Dragon, help me again..."). Fourth tower battle in the chain
; (Kalum -> Mistral -> Rafaga -> Tempest), monster: Dragon.
;
; Same three-end shape as the other tower NPCs.
;
; Carved out of analyzed.asm via map.json; see docs/text_engine.md
; for the bytecode reference. Initial dump produced by
; tools/script_disasm.py — hand-curate freely; the extractor's
; append-only rule on non-auto-managed files preserves your edits.

INCLUDE "script.inc"

SECTION "tempest_07cb82", ROMX[$4b82], BANK[$1f]


TempestScript:
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$01, .Target=.TempestVictory
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$02, .Target=.TempestDefeat
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    db "You've defeated"
    SCRIPT_NEWLINE
    db "them and you"
    SCRIPT_WAIT
    db "still rebel"
    SCRIPT_NEWLINE
    db "against Nada."
    SCRIPT_WAIT
    db "I, Tempest,"
    SCRIPT_NEWLINE
    db "must fight now."
    SCRIPT_WAIT
    db "Dragon,"
    SCRIPT_NEWLINE
    db "help me again."
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL .Addr=$4ad3, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=$4adc, .Bank=$1f
    SCRIPT_REPEAT_CHAR .Count=30
    SCRIPT_ANCHOR
    db "Young one."
    SCRIPT_WAIT
    db "Don't be easy on"
    SCRIPT_NEWLINE
    db "me because"
    SCRIPT_WAIT
    db "I'm old."
    SCRIPT_NEWLINE
    db "Let's fight."
    SCRIPT_WAIT
    SCRIPT_END
.TempestVictory:
    db "You are strong,"
    SCRIPT_NEWLINE
    db "A good fight."
    SCRIPT_WAIT
    db "It feels good"
    SCRIPT_NEWLINE
    db "to be defeated."
    SCRIPT_WAIT
    db "Time for Dragon"
    SCRIPT_NEWLINE
    db "and me to retire"
    SCRIPT_WAIT
    db "Hm. All right."
    SCRIPT_NEWLINE
    db "Go, young one."
    SCRIPT_WAIT
    db "Nada is stronger"
    SCRIPT_NEWLINE
    db "than me."
    SCRIPT_WAIT
    db "Good luck."
    SCRIPT_WAIT
    SCRIPT_END
.TempestDefeat:
    db "Hmm."
    SCRIPT_WAIT
    db "Guess this is it"
    SCRIPT_WAIT
    db "Come back again."
    SCRIPT_WAIT
    db "Acquire the"
    SCRIPT_NEWLINE
    db "strength I will"
    SCRIPT_WAIT
    db "acknowledge."
    SCRIPT_NEWLINE
    db "It'll be fun."
    SCRIPT_WAIT
    db "My Dragon and I"
    SCRIPT_NEWLINE
    db "will wait here."
    SCRIPT_WAIT
    SCRIPT_END
