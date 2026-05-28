; Naji (Tower-guard NPC) full script.
;
; Carved out of analyzed.asm via map.json; see docs/text_engine.md for
; the bytecode reference. The interpreter is at HOME $39C5; macros in
; script.inc encode each opcode.
;
; Entry points (in linear bytecode order):
;
;   $7183  NajiScript      4 state-gated jumps + IF-FIRST-TIME intro
;   $733D  NajiCycler      cyclic round-robin of 4 greetings
;   $73E0  NajiProgress    'you made it half-way' message
;   $7483  NajiMenu        'What are your plans?' prompt + render + dispatch
;   $74E2  NajiRestart     restart-at-saved-level Y/N + ENTER_DUNGEON_AT
;   $752C  NajiClimb       start-from-level-1 Y/N + ENTER_DUNGEON
;   $7579  NajiAskMenu     Ask submenu + 3-way dispatch
;   $75A8  NajiLeave       'See you later.'
;   $75BC  NajiTowerLong   tower long content (unreachable from main cursor)
;   $7624  NajiTowerShort  'You again! Going to try again?' (when D0DF==1)
;   $769B  NajiAskTower    Ask -> Tower
;   $7809  NajiAskItem     Ask -> Item
;   $7966  NajiAskStop     Ask -> Stop (bare GOTO back to NajiMenu)

INCLUDE "script.inc"

SECTION "naji_063183", ROMX[$7183], BANK[$18]


NajiScript:
    db_if_eq $d0dd, $04, NajiCycler
    db_if_eq $c2d7, $01, NajiCycler
    db_if_eq $d0dd, $02, NajiProgress
    db_if_eq $d0dd, $01, NajiCycler
    db_renderer $6c27, $18
    db "Did you come to"
    db DB_NEWLINE
    db "climb the tower?"
    db DB_WAIT
    db "I'm Naji. The"
    db DB_NEWLINE
    db "guard here. But"
    db DB_WAIT
    db "I'm on vacation"
    db DB_NEWLINE
    db "right now. It's"
    db DB_WAIT
    db "useless to guard"
    db DB_NEWLINE
    db "a place no one"
    db DB_WAIT
    db "dares to come."
    db DB_WAIT
    db "Village people"
    db DB_NEWLINE
    db "tried to rid the"
    db DB_WAIT
    db "problem, but no"
    db DB_NEWLINE
    db "one has returned"
    db DB_WAIT
    db "Since one can't"
    db DB_NEWLINE
    db "do much, I've"
    db DB_WAIT
    db "stayed behind to"
    db DB_NEWLINE
    db "the brave young"
    db DB_WAIT
    db "like you. But I"
    db DB_NEWLINE
    db "have no strength"
    db DB_WAIT
    db "left to fight"
    db DB_NEWLINE
    db "Nada. You have"
    db DB_WAIT
    db "wits and courage"
    db DB_NEWLINE
    db "to fight Nada."
    db DB_WAIT
    db "Help us? I am"
    db DB_NEWLINE
    db "the best guide."
    db DB_WAIT
    db "Please help!"
    db DB_WAIT
    db_write_wram $d0dd, $01
    db_goto NajiMenu

NajiCycler:
    db_cycle 4
    db_jump_table $d60d, naji_734a, naji_736d, naji_7394, naji_73bc

naji_734a:
    db_renderer $6c9f, $18
    db "Oh, you're here."
    db DB_NEWLINE
    db "Good luck."
    db DB_WAIT
    db_goto NajiMenu

naji_736d:
    db_renderer $6c27, $18
    db "It's you. Good"
    db DB_NEWLINE
    db "luck, my friend."
    db DB_WAIT
    db_goto NajiMenu

naji_7394:
    db_renderer $6c9f, $18
    db "It's you. We're"
    db DB_NEWLINE
    db "counting on you."
    db DB_WAIT
    db_goto NajiMenu

naji_73bc:
    db_renderer $6c27, $18
    db "Hey. It's you!"
    db DB_NEWLINE
    db "Take it easy!"
    db DB_WAIT
    db_goto NajiMenu

NajiProgress:
    db_renderer $6c9f, $18
    db "Oh, it's you"
    db DB_NEWLINE
    db "again. You made"
    db DB_WAIT
    db "it half-way up."
    db DB_NEWLINE
    db "I wasn't wrong"
    db DB_WAIT
    db "in counting on"
    db DB_NEWLINE
    db "you. Some of our"
    db DB_WAIT
    db "villagers got"
    db DB_NEWLINE
    db "back, but don't"
    db DB_WAIT
    db "get careless."
    db DB_NEWLINE
    db "It gets harder."
    db DB_WAIT
    db_write_wram $d0dd, $01
    db_goto NajiMenu

NajiMenu:
    db_renderer $6c27, $18
    db "What are your"
    db DB_NEWLINE
    db "plans this time?"
    db_if_eq $d0e2, $01, .checkAsk
    db_if_neq $cff0, $00, .renderClimb
    db_far_call $5abc, $1f
    db_goto .menuFinalize
.renderClimb:
    db_far_call $5b42, $1f
    db_goto .menuFinalize
.checkAsk:
    db_if_neq $cff0, $00, .renderLeave
    db_far_call $5bcb, $1f
    db_goto .menuFinalize
.renderLeave:
    db_far_call $5c54, $1f
.menuFinalize:
    db_far_call $6c1b, $18
    db DB_ANCHOR
    db_jump_table $d5ff, NajiRestart, NajiClimb, NajiTowerLong, NajiAskMenu, NajiLeave

NajiRestart:
    db_renderer $6c27, $18
    db "You've climbed"
    db DB_NEWLINE
    db "till Level "
    db_decimal $cff2
    db DB_WAIT
    db "Want to"
    db DB_NEWLINE
    db "start there?"
    db DB_YN_CUE
    db_far_call $58d7, $1f
    db_if_eq $d5fe, $01, NajiMenu
    db_far_call $4094, $1f
    db_far_call $6ba6, $18
    db DB_END

NajiClimb:
    db_renderer $6c27, $18
    db "I understand."
    db DB_NEWLINE
    db "I'll open the"
    db DB_WAIT
    db "door. But,"
    db DB_NEWLINE
    db "are you ready?"
    db DB_YN_CUE
    db_far_call $58d7, $1f
    db_if_eq $d5fe, $01, NajiMenu
    db_far_call $4094, $1f
    db_far_call $6b95, $18
    db DB_END

NajiAskMenu:
    db_renderer $6c27, $18
    db "What do you"
    db DB_NEWLINE
    db "want to know?"
    db_far_call $5d76, $1f
    db_far_call $6c1b, $18
    db DB_ANCHOR
    db_jump_table $d600, NajiAskTower, NajiAskItem, NajiAskStop

NajiLeave:
    db_renderer $6c27, $18
    db "See you later."
    db DB_WAIT
    db DB_END

NajiTowerLong:
    db_if_eq $d0df, $01, NajiTowerShort
    db_renderer $6c27, $18
    db "10 underground"
    db DB_NEWLINE
    db "levels here. The"
    db DB_WAIT
    db "true legend must"
    db DB_NEWLINE
    db "be hidden here."
    db DB_WAIT
    db "Don't misjudge."
    db DB_WAIT
    db_write_wram $d0df, $01
    db_far_call $4094, $1f
    db_far_call $6bb7, $18
    db DB_END

NajiTowerShort:
    db_renderer $6c27, $18
    db "You again! Going"
    db DB_NEWLINE
    db "to try again?"
    db DB_WAIT
    db "Persistence is"
    db DB_NEWLINE
    db "the shortcut to"
    db DB_WAIT
    db "the legend. I'll"
    db DB_NEWLINE
    db "show you the way"
    db DB_YN_CUE
    db_far_call $58d7, $1f
    db_if_eq $d5fe, $01, NajiMenu
    db_far_call $4094, $1f
    db_far_call $6bb7, $18
    db DB_END

NajiAskTower:
    db_renderer $6c27, $18
    db "Find the golden"
    db DB_NEWLINE
    db "key in each"
    db DB_WAIT
    db "room. It will"
    db DB_NEWLINE
    db "open the door,"
    db DB_WAIT
    db "and you can exit"
    db DB_NEWLINE
    db "from that room."
    db DB_WAIT
    db "Flying lights"
    db DB_NEWLINE
    db "are hints of"
    db DB_WAIT
    db "where the key"
    db DB_NEWLINE
    db "and door hides."
    db DB_WAIT
    db "Let me explain"
    db DB_NEWLINE
    db "about Life."
    db DB_WAIT
    db "You start with"
    db DB_NEWLINE
    db "three lives."
    db DB_WAIT
    db "If you lose all"
    db DB_NEWLINE
    db "lives or leave"
    db DB_WAIT
    db "the tower,"
    db DB_NEWLINE
    db "you will lose"
    db DB_WAIT
    db "all effects of"
    db DB_NEWLINE
    db "items."
    db DB_WAIT
    db "But don't worry."
    db DB_NEWLINE
    db "You won't lose"
    db DB_WAIT
    db "your Holy items."
    db DB_NEWLINE
    db "That's all I"
    db DB_WAIT
    db "know."
    db DB_NEWLINE
    db "Good luck!"
    db DB_WAIT
    db_goto NajiAskMenu

NajiAskItem:
    db_renderer $6c27, $18
    db "Let me explain."
    db DB_NEWLINE
    db "There are over"
    db DB_WAIT
    db "300 items hidden"
    db DB_NEWLINE
    db "in this tower."
    db DB_WAIT
    db "They're hard to"
    db DB_NEWLINE
    db "find, but try"
    db DB_WAIT
    db "making boxes and"
    db DB_NEWLINE
    db "just break them."
    db DB_WAIT
    db "The most"
    db DB_NEWLINE
    db "important item"
    db DB_WAIT
    db "is a saucer"
    db DB_NEWLINE
    db "stone fragment."
    db DB_WAIT
    db "4 fragments"
    db DB_NEWLINE
    db "will make one"
    db DB_WAIT
    db "saucer stone."
    db DB_NEWLINE
    db "You can seal a"
    db DB_WAIT
    db "good monster"
    db DB_NEWLINE
    db "inside it."
    db DB_WAIT
    db "I'm sorry, but"
    db DB_NEWLINE
    db "this is all I"
    db DB_WAIT
    db "know. The priest"
    db DB_NEWLINE
    db "in the tower"
    db DB_WAIT
    db "will tell you"
    db DB_NEWLINE
    db "more. Bye!"
    db DB_WAIT
    db_goto NajiAskMenu

NajiAskStop:
    db_goto NajiMenu
