; Nada (final tower boss).
;
; References her henchmen — "I heard about you from Rafaga" — and
; expects the player to have defeated them. She's the tower's
; antagonist, the priest who corrupted it (per Toamuna's intro
; text: "a priest named Nada came here, and this tower became
; full of Baddies").
;
; Note: the literal string "Zan" (her monster per game lore) does
; not appear in the ROM as ASCII — likely encoded as an indexed
; glyph via the $11 INDEXED_STR opcode the engine uses for monster
; names elsewhere.
;
; Carved out of analyzed.asm via map.json; see docs/text_engine.md
; for the bytecode reference. Initial dump produced by
; tools/script_disasm.py — hand-curate freely; the extractor's
; append-only rule on non-auto-managed files preserves your edits.

INCLUDE "script.inc"

SECTION "nada_07d0d6", ROMX[$50d6], BANK[$1f]


NadaScript:
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$01, .Target=.NadaVictory
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$02, .Target=.NadaDefeat
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    SCRIPT_FAR_CALL .Addr=Nada_ShowScene, .Bank=$1f
    SCRIPT_RENDERER .Addr=Nada_RenderPortrait, .Bank=$1f
    db "Wow. It took you"
    SCRIPT_NEWLINE
    db "a while. I heard"
    SCRIPT_WAIT
    db "about you from"
    SCRIPT_NEWLINE
    db "Rafaga. He never"
    SCRIPT_WAIT
    db "thought you'd"
    SCRIPT_NEWLINE
    db "make it up here."
    SCRIPT_WAIT
    db "Those kids are"
    SCRIPT_NEWLINE
    db "useless. One"
    SCRIPT_WAIT
    db "adventurer"
    SCRIPT_NEWLINE
    db "makes no"
    SCRIPT_WAIT
    db "difference. I'll"
    SCRIPT_NEWLINE
    db "ask this old man"
    SCRIPT_WAIT
    db "where the mythic"
    SCRIPT_NEWLINE
    db "monster is."
    SCRIPT_WAIT
    db "I'll take care"
    SCRIPT_NEWLINE
    db "of you later."
    SCRIPT_WAIT
    db "Can you hush and"
    SCRIPT_NEWLINE
    db "wait a sec?"
    SCRIPT_WAIT
    db "... ... ... ..."
    SCRIPT_NEWLINE
    db "Now, old man."
    SCRIPT_WAIT
    db "Where is the"
    SCRIPT_NEWLINE
    db "mythic monster?"
    SCRIPT_WAIT
    db "You built this,"
    SCRIPT_NEWLINE
    db "you should know."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=Studio_BuildHostSceneWithTiles, .Bank=$18
    SCRIPT_RENDERER .Addr=Studio_RenderPortrait, .Bank=$18
    db "Hm, I don't know"
    SCRIPT_WAIT
    db "Ask the tower."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=Nada_ShowSnapReaction, .Bank=$1f
    SCRIPT_RENDERER .Addr=Nada_RenderPortraitAngry, .Bank=$1f
    db "!!"
    SCRIPT_NEWLINE
    db "SNAP!"
    SCRIPT_WRITE_WRAM .Addr=$d611, .Value=$01
    SCRIPT_WAIT
    db "You hear that?!"
    SCRIPT_NEWLINE
    db "I just snapped!"
    SCRIPT_WAIT
    db "Tell me and I'll"
    SCRIPT_NEWLINE
    db "spare your life!"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=Studio_BuildHostSceneWithTiles, .Bank=$18
    SCRIPT_RENDERER .Addr=Studio_RenderPortrait, .Bank=$18
    db "Heh! I don't"
    SCRIPT_NEWLINE
    db "think so."
    SCRIPT_WAIT
    db "I'm dead whether"
    SCRIPT_NEWLINE
    db "or not I tell."
    SCRIPT_WAIT
    db "Your lies don't"
    SCRIPT_NEWLINE
    db "fool me."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=Nada_ShowSnapReaction, .Bank=$1f
    SCRIPT_RENDERER .Addr=Nada_RenderPortraitAngry, .Bank=$1f
    db "!!"
    SCRIPT_NEWLINE
    db "SNAP, SNAP!"
    SCRIPT_WAIT
    db "Can't you hear"
    SCRIPT_NEWLINE
    db "me snapping?"
    SCRIPT_WAIT
    db "Don't make me"
    SCRIPT_NEWLINE
    db "any angrier!"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=Studio_BuildHostSceneWithTiles, .Bank=$18
    SCRIPT_RENDERER .Addr=Studio_RenderPortraitAlt, .Bank=$18
    db "Sorry, but this"
    SCRIPT_NEWLINE
    db "is how it goes."
    SCRIPT_WAIT
    db "Better get out!"
    SCRIPT_NEWLINE
    db "The place will"
    SCRIPT_WAIT
    db "be gone soon."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=Nada_ShowRageScene, .Bank=$1f
    db "!!!"
    SCRIPT_NEWLINE
    db "SNAAAAAAAP!"
    SCRIPT_WAIT
    db "Fine!"
    SCRIPT_NEWLINE
    db "Be that way!"
    SCRIPT_WAIT
    db "I'll let you"
    SCRIPT_NEWLINE
    db "keep the legend."
    SCRIPT_WAIT
    db "I'll destroy"
    SCRIPT_NEWLINE
    db "the legend!"
    SCRIPT_WAIT
    db "Everything will"
    SCRIPT_NEWLINE
    db "be gone!"
    SCRIPT_WAIT
    db "You first! Let's"
    SCRIPT_NEWLINE
    db "see what you got"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL .Addr=Nada_ShowMonsterPortrait, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=Nada_ShowMonsterPortrait2, .Bank=$1f
    SCRIPT_REPEAT_CHAR .Count=90
    SCRIPT_END
.NadaVictory:
    SCRIPT_FAR_CALL .Addr=Nada_ShowScene, .Bank=$1f
    SCRIPT_RENDERER .Addr=Nada_RenderPortraitAngry, .Bank=$1f
    db "Unbelievable."
    SCRIPT_WAIT
    db "If I only had"
    SCRIPT_NEWLINE
    db "the great power."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=Studio_BuildHostSceneWithTiles, .Bank=$18
    SCRIPT_RENDERER .Addr=Studio_RenderPortraitAlt, .Bank=$18
    db "I didn't think"
    SCRIPT_NEWLINE
    db "that this day"
    SCRIPT_WAIT
    db "would ever come."
    SCRIPT_WAIT
    db "I had given up"
    SCRIPT_NEWLINE
    db "a long time ago."
    SCRIPT_WAIT
    db "Thank you! Thank"
    SCRIPT_NEWLINE
    db "you very much!"
    SCRIPT_WAIT
    db "This room is the"
    SCRIPT_NEWLINE
    db "highest in the"
    SCRIPT_WAIT
    db "tower. Many"
    SCRIPT_NEWLINE
    db "people came here"
    SCRIPT_WAIT
    db "to get the"
    SCRIPT_NEWLINE
    db "legendary power."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Studio_RenderPortrait, .Bank=$18
    db "But just because"
    SCRIPT_NEWLINE
    db "you got here"
    SCRIPT_WAIT
    db "doesn't mean"
    SCRIPT_NEWLINE
    db "that you'll get"
    SCRIPT_WAIT
    db "the power. There"
    SCRIPT_NEWLINE
    db "is a secret that"
    SCRIPT_WAIT
    db "Nada couldn't"
    SCRIPT_NEWLINE
    db "even solve. The"
    SCRIPT_WAIT
    db "only hint I can"
    SCRIPT_NEWLINE
    db "give is that"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Studio_RenderPortraitAlt, .Bank=$18
    db "silver key you"
    SCRIPT_NEWLINE
    db "picked up. That"
    SCRIPT_WAIT
    db "key is my token"
    SCRIPT_NEWLINE
    db "of thanks."
    SCRIPT_WAIT
    db "You can get to"
    SCRIPT_NEWLINE
    db "the basement"
    SCRIPT_WAIT
    db "using this key."
    SCRIPT_NEWLINE
    db "There is more"
    SCRIPT_WAIT
    db "than one"
    SCRIPT_NEWLINE
    db "basement room."
    SCRIPT_WAIT
    db "But more than"
    SCRIPT_NEWLINE
    db "one key too."
    SCRIPT_WAIT
    db "Search the tower"
    SCRIPT_NEWLINE
    db "to find more."
    SCRIPT_WAIT
    db "I can't tell"
    SCRIPT_NEWLINE
    db "you any more."
    SCRIPT_WAIT
    db "But it'll be fun"
    SCRIPT_NEWLINE
    db "to see how far"
    SCRIPT_WAIT
    db "you can go. Now,"
    SCRIPT_NEWLINE
    db "I'm going back"
    SCRIPT_WAIT
    db "to join everyone"
    SCRIPT_NEWLINE
    db "else. This is a"
    SCRIPT_WAIT
    db "happy day. We're"
    SCRIPT_NEWLINE
    db "going to"
    SCRIPT_WAIT
    db "celebrate! By"
    SCRIPT_NEWLINE
    db "the way, I'm"
    SCRIPT_WAIT
    db "Bodka. I operate"
    SCRIPT_NEWLINE
    db "the studio"
    SCRIPT_WAIT
    db "downstairs. Come"
    SCRIPT_NEWLINE
    db "if you have the"
    SCRIPT_WAIT
    db "time. See ya!"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wNajiMenuShown, .Value=$01
    SCRIPT_WRITE_WRAM .Addr=wRanchProgress, .Value=$04
    SCRIPT_WRITE_WRAM .Addr=wPashuteState, .Value=$03
    SCRIPT_WRITE_WRAM .Addr=wVerdeState, .Value=$03
    SCRIPT_END
.NadaDefeat:
    SCRIPT_FAR_CALL .Addr=Nada_ShowScene, .Bank=$1f
    SCRIPT_RENDERER .Addr=Nada_RenderPortraitAngry, .Bank=$1f
    db "No one beats me"
    SCRIPT_NEWLINE
    db "when I'm serious"
    SCRIPT_WAIT
    db "You'll regret"
    SCRIPT_NEWLINE
    db "fighting me!"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Nada_RenderPortrait, .Bank=$1f
    db "After this, I'll"
    SCRIPT_NEWLINE
    db "destroy the land"
    SCRIPT_WAIT
    SCRIPT_END
