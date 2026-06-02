; Pashute (monster shrine priest, regeneration NPC) full script.
;
; Pashute is one of the townspeople who went into the tower and
; returned (Toamuna's D0DC=2 greeting). He runs the monster shrine —
; the script offers regeneration of monsters (names rendered via the
; engine's $11 indexed-string opcode reading the table at HOME $3B75).
;
; Carved out of analyzed.asm via map.json; see docs/text_engine.md.

INCLUDE "script.inc"

SECTION "pashute_060272", ROMX[$4272], BANK[$18]


PashuteScript:
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    SCRIPT_IF_EQ .Addr=wPashuteState, .Value=$04, .Target=PashuteGameDone
    SCRIPT_IF_EQ .Addr=wPashuteState, .Value=$03, .Target=PashuteGreetProgress
    SCRIPT_IF_EQ .Addr=wPashuteState, .Value=$02, .Target=PashuteGreetReturning
    SCRIPT_IF_EQ .Addr=wPashuteState, .Value=$01, .Target=PashuteGreetingCycle
    SCRIPT_FAR_CALL .Addr=$40f3, .Bank=$18
    SCRIPT_RENDERER .Addr=$41e1, .Bank=$18
    db "Waaaaaaaa!"
    SCRIPT_NEWLINE
    db "They found me!"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "But it doesn't"
    SCRIPT_NEWLINE
    db "scare me!"
    SCRIPT_WAIT
    db "I'm Pashute, a"
    SCRIPT_NEWLINE
    db "priest here!"
    SCRIPT_WAIT
    db "I will not run,"
    SCRIPT_NEWLINE
    db "or hide!"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=$4225, .Bank=$18
    db "... ... ... ..."
    SCRIPT_NEWLINE
    db "Huh? ... ... ..."
    SCRIPT_WAIT
    db "Aren't you going"
    SCRIPT_NEWLINE
    db "to attack me?"
    SCRIPT_WAIT
    db "Like BOOM! or"
    SCRIPT_NEWLINE
    db "Aaaargh! or huh?"
    SCRIPT_WAIT
    db "... ... What?"
    SCRIPT_NEWLINE
    db "Came to help?"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "I see. I guess"
    SCRIPT_NEWLINE
    db "I took it wrong."
    SCRIPT_WAIT
    db "You don't look"
    SCRIPT_NEWLINE
    db "bad, anyway."
    SCRIPT_WAIT
    db "Going to ask me"
    SCRIPT_NEWLINE
    db "to support?"
    SCRIPT_WAIT
    db "Woo hooo!"
    SCRIPT_NEWLINE
    db "I mean. AHEM!"
    SCRIPT_WAIT
    db "I don't like to"
    SCRIPT_NEWLINE
    db "fight bat..."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=$41e1, .Bank=$18
    db "I'm not a weak"
    SCRIPT_NEWLINE
    db "baby or anything"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "....AHEM!"
    SCRIPT_NEWLINE
    db "Anyways."
    SCRIPT_WAIT
    db "I'll go"
    SCRIPT_NEWLINE
    db "down now"
    SCRIPT_WAIT
    db "to revive"
    SCRIPT_NEWLINE
    db "the shrine."
    SCRIPT_WAIT
    db "When you collect"
    SCRIPT_NEWLINE
    db "enough saucer"
    SCRIPT_WAIT
    db "stone fragments"
    SCRIPT_NEWLINE
    db "to make a saucer"
    SCRIPT_WAIT
    db "stone, you can"
    SCRIPT_NEWLINE
    db "seal certain"
    SCRIPT_WAIT
    db "monsters. After,"
    SCRIPT_NEWLINE
    db "you seal them,"
    SCRIPT_WAIT
    db "bring one saucer"
    SCRIPT_NEWLINE
    db "stone to the"
    SCRIPT_WAIT
    db "shrine and I'll"
    SCRIPT_NEWLINE
    db "regenerate them."
    SCRIPT_WAIT
    db "Then they will"
    SCRIPT_NEWLINE
    db "undoubtedly"
    SCRIPT_WAIT
    db "help you."
    SCRIPT_NEWLINE
    db "Easy to seal"
    SCRIPT_WAIT
    db "monsters! Just"
    SCRIPT_NEWLINE
    db "touch an"
    SCRIPT_WAIT
    db "unconscious one"
    SCRIPT_NEWLINE
    db "after completing"
    SCRIPT_WAIT
    db "a saucer stone."
    SCRIPT_NEWLINE
    db "I don't know"
    SCRIPT_WAIT
    db "which monster"
    SCRIPT_NEWLINE
    db "you can seal, or"
    SCRIPT_WAIT
    db "where they are."
    SCRIPT_NEWLINE
    db "Observe the"
    SCRIPT_WAIT
    db "monster well,"
    SCRIPT_NEWLINE
    db "then challenge"
    SCRIPT_WAIT
    db "them. They are"
    SCRIPT_NEWLINE
    db "knocked out when"
    SCRIPT_WAIT
    db "defeated."
    SCRIPT_NEWLINE
    db "That's the key."
    SCRIPT_WAIT
    db "I will go back."
    SCRIPT_NEWLINE
    db "I await the day"
    SCRIPT_WAIT
    db "we meet again!"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=$d0e0, .Value=$01
    SCRIPT_WRITE_WRAM .Addr=wRanchProgress, .Value=$02
    SCRIPT_WRITE_WRAM .Addr=wPashuteState, .Value=$01
    SCRIPT_END

PashuteGreetingCycle:
    SCRIPT_FAR_CALL .Addr=$40a0, .Bank=$18
    SCRIPT_CYCLE .Count=4
    SCRIPT_JUMP_TABLE wCycleCounter, PashuteGreeting1, PashuteGreeting2, PashuteGreeting3, PashuteGreeting4

PashuteGreeting1:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Welcome to the"
    SCRIPT_NEWLINE
    db "Monster Shrine."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteMenu

PashuteGreeting2:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Hello!"
    SCRIPT_NEWLINE
    db "Welcome!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteMenu

PashuteGreeting3:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Welcome to the"
    SCRIPT_NEWLINE
    db "Monster Shrine."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteMenu

PashuteGreeting4:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Well, well"
    SCRIPT_NEWLINE
    db "Good to see you."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteMenu

PashuteGreetReturning:
    SCRIPT_FAR_CALL .Addr=$40a0, .Bank=$18
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Oh, yes. I heard"
    SCRIPT_NEWLINE
    db "that there's a"
    SCRIPT_WAIT
    db "new building"
    SCRIPT_NEWLINE
    db "near here. That"
    SCRIPT_WAIT
    db "is the Monster"
    SCRIPT_NEWLINE
    db "Checkroom. Have"
    SCRIPT_WAIT
    db "you been there?"
    SCRIPT_NEWLINE
    db "They check your"
    SCRIPT_WAIT
    db "monsters for you"
    SCRIPT_NEWLINE
    db "Monster"
    SCRIPT_WAIT
    db "handling should"
    SCRIPT_NEWLINE
    db "be a lot easier"
    SCRIPT_WAIT
    db "now. You should"
    SCRIPT_NEWLINE
    db "go sometime!"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wPashuteState, .Value=$01
    SCRIPT_GOTO .Target=PashuteMenu

PashuteGreetProgress:
    SCRIPT_FAR_CALL .Addr=$40a0, .Bank=$18
    SCRIPT_RENDERER .Addr=$4225, .Bank=$18
    db "Oh! Well,"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Thank you"
    SCRIPT_NEWLINE
    db "for helping us."
    SCRIPT_WAIT
    db "We were lucky"
    SCRIPT_NEWLINE
    db "you were around."
    SCRIPT_WAIT
    db "I'm happy. I"
    SCRIPT_NEWLINE
    db "can help you out"
    SCRIPT_WAIT
    db "Oh, I heard"
    SCRIPT_NEWLINE
    db "they've built"
    SCRIPT_WAIT
    db "another building"
    SCRIPT_NEWLINE
    db "near here. That"
    SCRIPT_WAIT
    db "is the Stage"
    SCRIPT_NEWLINE
    db "Studio. You been"
    SCRIPT_WAIT
    db "there? You can"
    SCRIPT_NEWLINE
    db "make your own"
    SCRIPT_WAIT
    db "stages, then"
    SCRIPT_NEWLINE
    db "share them with"
    SCRIPT_WAIT
    db "your pals using"
    SCRIPT_NEWLINE
    db "Link Cables."
    SCRIPT_WAIT
    db "Visit there."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wPashuteState, .Value=$01
    SCRIPT_GOTO .Target=PashuteMenu

PashuteGameDone:
    SCRIPT_FAR_CALL .Addr=$40a0, .Bank=$18
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Hello! How are"
    SCRIPT_NEWLINE
    db "doing? I heard"
    SCRIPT_WAIT
    db "that you cleared"
    SCRIPT_NEWLINE
    db "all the stages."
    SCRIPT_WAIT
    db "Your abilities"
    SCRIPT_NEWLINE
    db "never cease to"
    SCRIPT_WAIT
    db "amaze me, but"
    SCRIPT_NEWLINE
    db "there are many"
    SCRIPT_WAIT
    db "other ways to"
    SCRIPT_NEWLINE
    db "enjoy this tower"
    SCRIPT_WAIT
    db "Play, play,"
    SCRIPT_NEWLINE
    db "and play more!"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wPashuteState, .Value=$01
    SCRIPT_GOTO .Target=PashuteMenu

PashuteMenu:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Well, then."
    SCRIPT_WAIT
    db "How can I"
    SCRIPT_NEWLINE
    db "help you?"
    SCRIPT_FAR_CALL .Addr=$6090, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=$4144, .Bank=$18
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE wMainMenuResult, PashuteStone, PashuteAsk, PashuteLeave

PashuteContinue:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Anything"
    SCRIPT_NEWLINE
    db "else you need?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL .Addr=$58d7, .Bank=$1f
    SCRIPT_JUMP_TABLE wYNResult, PashuteMenu, PashuteNoContinue

PashuteNoContinue:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "I see."
    SCRIPT_WAIT
    db "Well, I await"
    SCRIPT_NEWLINE
    db "your return."
    SCRIPT_WAIT
    SCRIPT_END

PashuteStone:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Regenerating a"
    SCRIPT_NEWLINE
    db "saucer stone?"
    SCRIPT_WAIT
    SCRIPT_IF_EQ .Addr=$d0e1, .Value=$01, .Target=PashuteStoneCheck
    SCRIPT_IF_EQ .Addr=$cfd9, .Value=$ff, .Target=PashuteStoneCheck
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "If the new"
    SCRIPT_NEWLINE
    db "monster differs"
    SCRIPT_WAIT
    db "from the current"
    SCRIPT_NEWLINE
    db "one, the loaded"
    SCRIPT_WAIT
    db "one will be"
    SCRIPT_NEWLINE
    db "replaced, okay?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL .Addr=$58d7, .Bank=$1f
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$00, .Target=PashuteStoneCheck
    SCRIPT_RENDERER .Addr=$41e1, .Bank=$18
    db "Until recently,"
    SCRIPT_WAIT
    db "there was a"
    SCRIPT_NEWLINE
    db "place to check"
    SCRIPT_WAIT
    db "your monster."
    SCRIPT_NEWLINE
    db "Too bad it's"
    SCRIPT_WAIT
    db "gone. Please"
    SCRIPT_NEWLINE
    db "come again."
    SCRIPT_WAIT
    SCRIPT_END

PashuteStoneCheck:
    SCRIPT_IF_NEQ .Addr=$cfda, .Value=$00, .Target=PashuteStoneReady
    SCRIPT_IF_NEQ .Addr=$cfdb, .Value=$00, .Target=PashuteStoneReady
    SCRIPT_IF_NEQ .Addr=$cfdc, .Value=$00, .Target=PashuteStoneReady
    SCRIPT_IF_NEQ .Addr=$cfdd, .Value=$00, .Target=PashuteStoneReady
    SCRIPT_IF_NEQ .Addr=$cfde, .Value=$00, .Target=PashuteStoneReady
    SCRIPT_IF_NEQ .Addr=$cfdf, .Value=$00, .Target=PashuteStoneReady
    SCRIPT_IF_NEQ .Addr=$cfe0, .Value=$00, .Target=PashuteStoneReady
    SCRIPT_RENDERER .Addr=$41e1, .Bank=$18
    db "But you"
    SCRIPT_WAIT
    db "don't have any"
    SCRIPT_NEWLINE
    db "saucer stones to"
    SCRIPT_WAIT
    db "regenerate. Come"
    SCRIPT_NEWLINE
    db "after you seal"
    SCRIPT_WAIT
    db "a monster in a"
    SCRIPT_NEWLINE
    db "saucer stone."
    SCRIPT_WAIT
    SCRIPT_END

PashuteStoneReady:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Then..."
    SCRIPT_NEWLINE
    db "please choose"
    SCRIPT_WAIT
    db "saucer stone"
    SCRIPT_NEWLINE
    db "to regenerate."
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL .Addr=$6242, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=$4144, .Bank=$18
    SCRIPT_ANCHOR
    SCRIPT_IF_EQ .Addr=$cfbb, .Value=$07, .Target=PashuteContinue
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Starting the"
    SCRIPT_NEWLINE
    db "process."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=$4094, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=$404d, .Bank=$14
    SCRIPT_FAR_CALL .Addr=$40a0, .Bank=$18
    SCRIPT_IF_EQ .Addr=$d0e1, .Value=$01, .Target=PashuteRegenSetup
    SCRIPT_FAR_CALL .Addr=$4054, .Bank=$18
    SCRIPT_GOTO .Target=PashuteRegenPick

PashuteRegenSetup:
    SCRIPT_FAR_CALL .Addr=$4074, .Bank=$18

PashuteRegenPick:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Regeneration"
    SCRIPT_NEWLINE
    db "is complete."
    SCRIPT_WAIT
    db "Let's look at"
    SCRIPT_NEWLINE
    db "the new monster."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=$4094, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=$40a5, .Bank=$32
    SCRIPT_FAR_CALL .Addr=$40a0, .Bank=$18
    SCRIPT_JUMP_TABLE $cfbb, \
        PashuteTiger, \
        PashuteMocchi, \
        PashuteHare, \
        PashuteGali, \
        PashuteGolem, \
        PashuteSuezo, \
        PashutePhenix

PashuteTiger:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "This is Tiger,"
    SCRIPT_NEWLINE
    db "a cool monster."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteRegenConfirm

PashuteMocchi:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "This is Mocchi,"
    SCRIPT_NEWLINE
    db "a cute monster."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteRegenConfirm

PashuteHare:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "This is Hare,"
    SCRIPT_NEWLINE
    db "a fast monster."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteRegenConfirm

PashuteGali:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "It's Gali, a"
    SCRIPT_NEWLINE
    db "mystery monster."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteRegenConfirm

PashuteGolem:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "It's Golem, a"
    SCRIPT_NEWLINE
    db "powerful monster"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteRegenConfirm

PashuteSuezo:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "This is Suezo,"
    SCRIPT_NEWLINE
    db "a funny monster"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteRegenConfirm

PashutePhenix:
    SCRIPT_RENDERER .Addr=$4225, .Bank=$18
    db "Whoa! Th...this!"
    SCRIPT_NEWLINE
    db "No way!...Dang!"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db " . . Ahem . . ."
    SCRIPT_NEWLINE
    db "Sorry about that"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=$4225, .Bank=$18
    db "This is Phenix!"
    SCRIPT_NEWLINE
    db "A wonder monster"
    SCRIPT_WAIT

PashuteRegenConfirm:
    SCRIPT_IF_EQ .Addr=$d0e1, .Value=$01, .Target=PashuteRegenTake
    SCRIPT_FAR_CALL .Addr=$4027, .Bank=$18
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$00, .Target=PashuteRegenDoNow
    SCRIPT_IF_EQ .Addr=$cfd9, .Value=$ff, .Target=PashuteRegenDoNow
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Then I will"
    SCRIPT_NEWLINE
    db "replace "
    SCRIPT_INDEXED_STR .Addr=$cfd9
    db "."
    SCRIPT_WAIT
    db "You now have"
    SCRIPT_WAIT
    db "the newborn"
    SCRIPT_NEWLINE
    SCRIPT_INDEXED_STR .Addr=$cfbb
    db "."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=$404d, .Bank=$18
    SCRIPT_GOTO .Target=PashuteRegenDone

PashuteRegenDoNow:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Now I will"
    SCRIPT_NEWLINE
    db "give you"
    SCRIPT_WAIT
    db "the newborn"
    SCRIPT_NEWLINE
    db "monster."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=$404d, .Bank=$18
    SCRIPT_GOTO .Target=PashuteRegenDone

PashuteRegenTake:
    SCRIPT_FAR_CALL .Addr=$403c, .Bank=$18
    SCRIPT_IF_NEQ .Addr=wYNResult, .Value=$05, .Target=PashuteRegenNow
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Will you take"
    SCRIPT_NEWLINE
    db "the newborn now?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL .Addr=$58d7, .Bank=$1f
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=PashuteRegenPlace
    SCRIPT_IF_EQ .Addr=$cfd9, .Value=$ff, .Target=PashuteRegenDoNow2
    db "Then let's put"
    SCRIPT_NEWLINE
    db "this "
    SCRIPT_INDEXED_STR .Addr=$cfd9
    SCRIPT_WAIT
    db "in the Monster"
    SCRIPT_NEWLINE
    db "Checkroom."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=$404d, .Bank=$18
    SCRIPT_GOTO .Target=PashuteRegenDone

PashuteRegenDoNow2:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Now I will"
    SCRIPT_NEWLINE
    db "give you"
    SCRIPT_WAIT
    db "the newborn"
    SCRIPT_NEWLINE
    db "monster."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=$404d, .Bank=$18
    SCRIPT_GOTO .Target=PashuteRegenDone

PashuteRegenPlace:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Then let's put"
    SCRIPT_NEWLINE
    db "this "
    SCRIPT_INDEXED_STR .Addr=$cfbb
    SCRIPT_WAIT
    db "in the Monster"
    SCRIPT_NEWLINE
    db "Checkroom."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteRegenDone

PashuteRegenNow:
    SCRIPT_FAR_CALL .Addr=$4027, .Bank=$18
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$00, .Target=PashuteRegenNow2
    db "Now "
    SCRIPT_INDEXED_STR .Addr=$cfbb
    db " in the"
    SCRIPT_NEWLINE
    db "Checkroom has"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=$4000, .Bank=$18
    SCRIPT_DECIMAL .Addr=wYNResult
    db " times of"
    SCRIPT_NEWLINE
    db "usable moves."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteRegenDone

PashuteRegenNow2:
    db "Now "
    SCRIPT_INDEXED_STR .Addr=$cfbb
    SCRIPT_NEWLINE
    db "you carry"
    SCRIPT_WAIT
    db "has "
    SCRIPT_FAR_CALL .Addr=$4000, .Bank=$18
    SCRIPT_DECIMAL .Addr=wYNResult
    db " times of"
    SCRIPT_NEWLINE
    db "usable moves."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteRegenDone

PashuteRegenDone:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "We are all done."
    SCRIPT_NEWLINE
    db "Please take"
    SCRIPT_WAIT
    db "good care of"
    SCRIPT_NEWLINE
    db "the monsters."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteContinue

PashuteAsk:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "What shall"
    SCRIPT_NEWLINE
    db "I explain?"
    SCRIPT_FAR_CALL .Addr=$6169, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=$4144, .Bank=$18
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE wSubMenuCursor, PashuteAskShrineStone, PashuteAskMonster
    db "'J"

PashuteLeave:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Come back again."
    SCRIPT_NEWLINE
    db "I'll be waiting."
    SCRIPT_WAIT
    SCRIPT_END

PashuteAskShrineStone:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Hello."
    SCRIPT_NEWLINE
    db "This Shrine"
    SCRIPT_WAIT
    db "regenerates"
    SCRIPT_NEWLINE
    db "monsters from"
    SCRIPT_WAIT
    db "saucer stones."
    SCRIPT_NEWLINE
    db "Find the hidden"
    SCRIPT_WAIT
    db "fragments in the"
    SCRIPT_NEWLINE
    db "tower and when"
    SCRIPT_WAIT
    db "you collect 4,"
    SCRIPT_NEWLINE
    db "bring them here."
    SCRIPT_WAIT
    db "A saucer stone"
    SCRIPT_NEWLINE
    db "will be made."
    SCRIPT_WAIT
    db "Seal monsters in"
    SCRIPT_NEWLINE
    db "the stone to"
    SCRIPT_WAIT
    db "regenerate them."
    SCRIPT_NEWLINE
    db "Okay?"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteAsk

PashuteAskMonster:
    SCRIPT_RENDERER .Addr=$4150, .Bank=$18
    db "Let me explain"
    SCRIPT_NEWLINE
    db "about monsters."
    SCRIPT_WAIT
    db "Good monsters"
    SCRIPT_NEWLINE
    db "lived as"
    SCRIPT_WAIT
    db "guardians of"
    SCRIPT_NEWLINE
    db "the legendary"
    SCRIPT_WAIT
    db "power before"
    SCRIPT_NEWLINE
    db "Nada's invasion."
    SCRIPT_WAIT
    db "Now there are"
    SCRIPT_NEWLINE
    db "Bad monsters"
    SCRIPT_WAIT
    db "living in the"
    SCRIPT_NEWLINE
    db "tower. They have"
    SCRIPT_WAIT
    db "been regenerated"
    SCRIPT_NEWLINE
    db "by Nada. Some of"
    SCRIPT_WAIT
    db "them can be good"
    SCRIPT_NEWLINE
    db "again by sealing"
    SCRIPT_WAIT
    db "them in the"
    SCRIPT_NEWLINE
    db "saucer stones."
    SCRIPT_WAIT
    db "Knock them out"
    SCRIPT_NEWLINE
    db "and seal them"
    SCRIPT_WAIT
    db "when they are"
    SCRIPT_NEWLINE
    db "unconscious."
    SCRIPT_WAIT
    db "Think right."
    SCRIPT_NEWLINE
    db "Take your chance"
    SCRIPT_WAIT
    db "with care, and"
    SCRIPT_NEWLINE
    db "you will gain"
    SCRIPT_WAIT
    db "reliable allies!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteAsk
