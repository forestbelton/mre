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
    SCRIPT_OPEN_TEXTBOX $9982, $10, $04
    SCRIPT_IF_EQ $d0de, $04, pashute_492f
    SCRIPT_IF_EQ $d0de, $03, pashute_47fe
    SCRIPT_IF_EQ $d0de, $02, pashute_471d
    SCRIPT_IF_EQ $d0de, $01, pashute_4686
    SCRIPT_FAR_CALL $40f3, $18
    SCRIPT_RENDERER $41e1, $18
    db "Waaaaaaaa!"
    SCRIPT_NEWLINE
    db "They found me!"
    SCRIPT_WAIT
    SCRIPT_RENDERER $4150, $18
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
    SCRIPT_RENDERER $4225, $18
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
    SCRIPT_RENDERER $4150, $18
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
    SCRIPT_RENDERER $41e1, $18
    db "I'm not a weak"
    SCRIPT_NEWLINE
    db "baby or anything"
    SCRIPT_WAIT
    SCRIPT_RENDERER $4150, $18
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
    SCRIPT_WRITE_WRAM $d0e0, $01
    SCRIPT_WRITE_WRAM $d0dc, $02
    SCRIPT_WRITE_WRAM $d0de, $01
    SCRIPT_END

pashute_4686:
    SCRIPT_FAR_CALL $40a0, $18
    SCRIPT_CYCLE 4
    SCRIPT_JUMP_TABLE $d60d, pashute_4697, pashute_46bd, pashute_46d4, pashute_46fa

pashute_4697:
    SCRIPT_RENDERER $4150, $18
    db "Welcome to the"
    SCRIPT_NEWLINE
    db "Monster Shrine."
    SCRIPT_WAIT
    SCRIPT_GOTO pashute_49f2

pashute_46bd:
    SCRIPT_RENDERER $4150, $18
    db "Hello!"
    SCRIPT_NEWLINE
    db "Welcome!"
    SCRIPT_WAIT
    SCRIPT_GOTO pashute_49f2

pashute_46d4:
    SCRIPT_RENDERER $4150, $18
    db "Welcome to the"
    SCRIPT_NEWLINE
    db "Monster Shrine."
    SCRIPT_WAIT
    SCRIPT_GOTO pashute_49f2

pashute_46fa:
    SCRIPT_RENDERER $4150, $18
    db "Well, well"
    SCRIPT_NEWLINE
    db "Good to see you."
    SCRIPT_WAIT
    SCRIPT_GOTO pashute_49f2

pashute_471d:
    SCRIPT_FAR_CALL $40a0, $18
    SCRIPT_RENDERER $4150, $18
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
    SCRIPT_WRITE_WRAM $d0de, $01
    SCRIPT_GOTO pashute_49f2

pashute_47fe:
    SCRIPT_FAR_CALL $40a0, $18
    SCRIPT_RENDERER $4225, $18
    db "Oh! Well,"
    SCRIPT_WAIT
    SCRIPT_RENDERER $4150, $18
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
    SCRIPT_WRITE_WRAM $d0de, $01
    SCRIPT_GOTO pashute_49f2

pashute_492f:
    SCRIPT_FAR_CALL $40a0, $18
    SCRIPT_RENDERER $4150, $18
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
    SCRIPT_WRITE_WRAM $d0de, $01
    SCRIPT_GOTO pashute_49f2

pashute_49f2:
    SCRIPT_RENDERER $4150, $18
    db "Well, then."
    SCRIPT_WAIT
    db "How can I"
    SCRIPT_NEWLINE
    db "help you?"
    SCRIPT_FAR_CALL $6090, $1f
    SCRIPT_FAR_CALL $4144, $18
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE $d5ff, pashute_4a75, PashuteMenu, PashuteLeave

pashute_4a27:
    SCRIPT_RENDERER $4150, $18
    db "Anything"
    SCRIPT_NEWLINE
    db "else you need?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL $58d7, $1f
    SCRIPT_JUMP_TABLE $d5fe, pashute_49f2, pashute_4a4e

pashute_4a4e:
    SCRIPT_RENDERER $4150, $18
    db "I see."
    SCRIPT_WAIT
    db "Well, I await"
    SCRIPT_NEWLINE
    db "your return."
    SCRIPT_WAIT
    SCRIPT_END

pashute_4a75:
    SCRIPT_RENDERER $4150, $18
    db "Regenerating a"
    SCRIPT_NEWLINE
    db "saucer stone?"
    SCRIPT_WAIT
    SCRIPT_IF_EQ $d0e1, $01, pashute_4b6c
    SCRIPT_IF_EQ $cfd9, $ff, pashute_4b6c
    SCRIPT_RENDERER $4150, $18
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
    SCRIPT_FAR_CALL $58d7, $1f
    SCRIPT_IF_EQ $d5fe, $00, pashute_4b6c
    SCRIPT_RENDERER $41e1, $18
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

pashute_4b6c:
    SCRIPT_IF_NEQ $cfda, $00, pashute_4c00
    SCRIPT_IF_NEQ $cfdb, $00, pashute_4c00
    SCRIPT_IF_NEQ $cfdc, $00, pashute_4c00
    SCRIPT_IF_NEQ $cfdd, $00, pashute_4c00
    SCRIPT_IF_NEQ $cfde, $00, pashute_4c00
    SCRIPT_IF_NEQ $cfdf, $00, pashute_4c00
    SCRIPT_IF_NEQ $cfe0, $00, pashute_4c00
    SCRIPT_RENDERER $41e1, $18
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

pashute_4c00:
    SCRIPT_RENDERER $4150, $18
    db "Then..."
    SCRIPT_NEWLINE
    db "please choose"
    SCRIPT_WAIT
    db "saucer stone"
    SCRIPT_NEWLINE
    db "to regenerate."
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL $6242, $1f
    SCRIPT_FAR_CALL $4144, $18
    SCRIPT_ANCHOR
    SCRIPT_IF_EQ $cfbb, $07, pashute_4a27
    SCRIPT_RENDERER $4150, $18
    db "Starting the"
    SCRIPT_NEWLINE
    db "process."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL $4094, $1f
    SCRIPT_FAR_CALL $404d, $14
    SCRIPT_FAR_CALL $40a0, $18
    SCRIPT_IF_EQ $d0e1, $01, pashute_4c78
    SCRIPT_FAR_CALL $4054, $18
    SCRIPT_GOTO pashute_4c7c

pashute_4c78:
    SCRIPT_FAR_CALL $4074, $18

pashute_4c7c:
    SCRIPT_RENDERER $4150, $18
    db "Regeneration"
    SCRIPT_NEWLINE
    db "is complete."
    SCRIPT_WAIT
    db "Let's look at"
    SCRIPT_NEWLINE
    db "the new monster."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL $4094, $1f
    SCRIPT_FAR_CALL $40a5, $32
    SCRIPT_FAR_CALL $40a0, $18
    SCRIPT_JUMP_TABLE $cfbb, pashute_4cd6, pashute_4cfc, pashute_4d23, pashute_4d48, pashute_4d6d, pashute_4d93, pashute_4db9

pashute_4cd6:
    SCRIPT_RENDERER $4150, $18
    db "This is Tiger,"
    SCRIPT_NEWLINE
    db "a cool monster."
    SCRIPT_WAIT
    SCRIPT_GOTO pashute_4e28

pashute_4cfc:
    SCRIPT_RENDERER $4150, $18
    db "This is Mocchi,"
    SCRIPT_NEWLINE
    db "a cute monster."
    SCRIPT_WAIT
    SCRIPT_GOTO pashute_4e28

pashute_4d23:
    SCRIPT_RENDERER $4150, $18
    db "This is Hare,"
    SCRIPT_NEWLINE
    db "a fast monster."
    SCRIPT_WAIT
    SCRIPT_GOTO pashute_4e28

pashute_4d48:
    SCRIPT_RENDERER $4150, $18
    db "It's Gali, a"
    SCRIPT_NEWLINE
    db "mystery monster."
    SCRIPT_WAIT
    SCRIPT_GOTO pashute_4e28

pashute_4d6d:
    SCRIPT_RENDERER $4150, $18
    db "It's Golem, a"
    SCRIPT_NEWLINE
    db "powerful monster"
    SCRIPT_WAIT
    SCRIPT_GOTO pashute_4e28

pashute_4d93:
    SCRIPT_RENDERER $4150, $18
    db "This is Suezo,"
    SCRIPT_NEWLINE
    db "a funny monster"
    SCRIPT_WAIT
    SCRIPT_GOTO pashute_4e28

pashute_4db9:
    SCRIPT_RENDERER $4225, $18
    db "Whoa! Th...this!"
    SCRIPT_NEWLINE
    db "No way!...Dang!"
    SCRIPT_WAIT
    SCRIPT_RENDERER $4150, $18
    db " . . Ahem . . ."
    SCRIPT_NEWLINE
    db "Sorry about that"
    SCRIPT_WAIT
    SCRIPT_RENDERER $4225, $18
    db "This is Phenix!"
    SCRIPT_NEWLINE
    db "A wonder monster"
    SCRIPT_WAIT

pashute_4e28:
    SCRIPT_IF_EQ $d0e1, $01, pashute_4eb4
    SCRIPT_FAR_CALL $4027, $18
    SCRIPT_IF_EQ $d5fe, $00, pashute_4e80
    SCRIPT_IF_EQ $cfd9, $ff, pashute_4e80
    SCRIPT_RENDERER $4150, $18
    db "Then I will"
    SCRIPT_NEWLINE
    db "replace "
    SCRIPT_INDEXED_STR $cfd9
    db "."
    SCRIPT_WAIT
    db "You now have"
    SCRIPT_WAIT
    db "the newborn"
    SCRIPT_NEWLINE
    SCRIPT_INDEXED_STR $cfbb
    db "."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL $404d, $18
    SCRIPT_GOTO pashute_5018

pashute_4e80:
    SCRIPT_RENDERER $4150, $18
    db "Now I will"
    SCRIPT_NEWLINE
    db "give you"
    SCRIPT_WAIT
    db "the newborn"
    SCRIPT_NEWLINE
    db "monster."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL $404d, $18
    SCRIPT_GOTO pashute_5018

pashute_4eb4:
    SCRIPT_FAR_CALL $403c, $18
    SCRIPT_IF_NEQ $d5fe, $05, pashute_4f97
    SCRIPT_RENDERER $4150, $18
    db "Will you take"
    SCRIPT_NEWLINE
    db "the newborn now?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL $58d7, $1f
    SCRIPT_IF_EQ $d5fe, $01, pashute_4f5e
    SCRIPT_IF_EQ $cfd9, $ff, pashute_4f2a
    db "Then let's put"
    SCRIPT_NEWLINE
    db "this "
    SCRIPT_INDEXED_STR $cfd9
    SCRIPT_WAIT
    db "in the Monster"
    SCRIPT_NEWLINE
    db "Checkroom."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL $404d, $18
    SCRIPT_GOTO pashute_5018

pashute_4f2a:
    SCRIPT_RENDERER $4150, $18
    db "Now I will"
    SCRIPT_NEWLINE
    db "give you"
    SCRIPT_WAIT
    db "the newborn"
    SCRIPT_NEWLINE
    db "monster."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL $404d, $18
    SCRIPT_GOTO pashute_5018

pashute_4f5e:
    SCRIPT_RENDERER $4150, $18
    db "Then let's put"
    SCRIPT_NEWLINE
    db "this "
    SCRIPT_INDEXED_STR $cfbb
    SCRIPT_WAIT
    db "in the Monster"
    SCRIPT_NEWLINE
    db "Checkroom."
    SCRIPT_WAIT
    SCRIPT_GOTO pashute_5018

pashute_4f97:
    SCRIPT_FAR_CALL $4027, $18
    SCRIPT_IF_EQ $d5fe, $00, pashute_4fe0
    db "Now "
    SCRIPT_INDEXED_STR $cfbb
    db " in the"
    SCRIPT_NEWLINE
    db "Checkroom has"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL $4000, $18
    SCRIPT_DECIMAL $d5fe
    db " times of"
    SCRIPT_NEWLINE
    db "usable moves."
    SCRIPT_WAIT
    SCRIPT_GOTO pashute_5018

pashute_4fe0:
    db "Now "
    SCRIPT_INDEXED_STR $cfbb
    SCRIPT_NEWLINE
    db "you carry"
    SCRIPT_WAIT
    db "has "
    SCRIPT_FAR_CALL $4000, $18
    SCRIPT_DECIMAL $d5fe
    db " times of"
    SCRIPT_NEWLINE
    db "usable moves."
    SCRIPT_WAIT
    SCRIPT_GOTO pashute_5018

pashute_5018:
    SCRIPT_RENDERER $4150, $18
    db "We are all done."
    SCRIPT_NEWLINE
    db "Please take"
    SCRIPT_WAIT
    db "good care of"
    SCRIPT_NEWLINE
    db "the monsters."
    SCRIPT_WAIT
    SCRIPT_GOTO pashute_4a27

PashuteMenu:
    SCRIPT_RENDERER $4150, $18
    db "What shall"
    SCRIPT_NEWLINE
    db "I explain?"
    SCRIPT_FAR_CALL $6169, $1f
    SCRIPT_FAR_CALL $4144, $18
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE $d600, pashute_50a9, pashute_518e
    db "'J"

PashuteLeave:
    SCRIPT_RENDERER $4150, $18
    db "Come back again."
    SCRIPT_NEWLINE
    db "I'll be waiting."
    SCRIPT_WAIT
    SCRIPT_END

pashute_50a9:
    SCRIPT_RENDERER $4150, $18
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
    SCRIPT_GOTO PashuteMenu

pashute_518e:
    SCRIPT_RENDERER $4150, $18
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
    SCRIPT_GOTO PashuteMenu
