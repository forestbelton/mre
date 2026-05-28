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
    script_if_eq $d0dd, $04, NajiCycler
    script_if_eq $c2d7, $01, NajiCycler
    script_if_eq $d0dd, $02, NajiProgress
    script_if_eq $d0dd, $01, NajiCycler
    script_renderer $6c27, $18
    db "Did you come to"
    script_newline
    db "climb the tower?"
    script_wait
    db "I'm Naji. The"
    script_newline
    db "guard here. But"
    script_wait
    db "I'm on vacation"
    script_newline
    db "right now. It's"
    script_wait
    db "useless to guard"
    script_newline
    db "a place no one"
    script_wait
    db "dares to come."
    script_wait
    db "Village people"
    script_newline
    db "tried to rid the"
    script_wait
    db "problem, but no"
    script_newline
    db "one has returned"
    script_wait
    db "Since one can't"
    script_newline
    db "do much, I've"
    script_wait
    db "stayed behind to"
    script_newline
    db "the brave young"
    script_wait
    db "like you. But I"
    script_newline
    db "have no strength"
    script_wait
    db "left to fight"
    script_newline
    db "Nada. You have"
    script_wait
    db "wits and courage"
    script_newline
    db "to fight Nada."
    script_wait
    db "Help us? I am"
    script_newline
    db "the best guide."
    script_wait
    db "Please help!"
    script_wait
    script_write_wram $d0dd, $01
    script_goto NajiMenu

NajiCycler:
    script_cycle 4
    script_jump_table $d60d, naji_734a, naji_736d, naji_7394, naji_73bc

naji_734a:
    script_renderer $6c9f, $18
    db "Oh, you're here."
    script_newline
    db "Good luck."
    script_wait
    script_goto NajiMenu

naji_736d:
    script_renderer $6c27, $18
    db "It's you. Good"
    script_newline
    db "luck, my friend."
    script_wait
    script_goto NajiMenu

naji_7394:
    script_renderer $6c9f, $18
    db "It's you. We're"
    script_newline
    db "counting on you."
    script_wait
    script_goto NajiMenu

naji_73bc:
    script_renderer $6c27, $18
    db "Hey. It's you!"
    script_newline
    db "Take it easy!"
    script_wait
    script_goto NajiMenu

NajiProgress:
    script_renderer $6c9f, $18
    db "Oh, it's you"
    script_newline
    db "again. You made"
    script_wait
    db "it half-way up."
    script_newline
    db "I wasn't wrong"
    script_wait
    db "in counting on"
    script_newline
    db "you. Some of our"
    script_wait
    db "villagers got"
    script_newline
    db "back, but don't"
    script_wait
    db "get careless."
    script_newline
    db "It gets harder."
    script_wait
    script_write_wram $d0dd, $01
    script_goto NajiMenu

NajiMenu:
    script_renderer $6c27, $18
    db "What are your"
    script_newline
    db "plans this time?"
    script_if_eq $d0e2, $01, .checkAsk
    script_if_neq $cff0, $00, .renderClimb
    script_far_call $5abc, $1f
    script_goto .menuFinalize
.renderClimb:
    script_far_call $5b42, $1f
    script_goto .menuFinalize
.checkAsk:
    script_if_neq $cff0, $00, .renderLeave
    script_far_call $5bcb, $1f
    script_goto .menuFinalize
.renderLeave:
    script_far_call $5c54, $1f
.menuFinalize:
    script_far_call $6c1b, $18
    script_anchor
    script_jump_table $d5ff, NajiRestart, NajiClimb, NajiTowerLong, NajiAskMenu, NajiLeave

NajiRestart:
    script_renderer $6c27, $18
    db "You've climbed"
    script_newline
    db "till Level "
    script_decimal $cff2
    script_wait
    db "Want to"
    script_newline
    db "start there?"
    script_yn_cue
    script_far_call $58d7, $1f
    script_if_eq $d5fe, $01, NajiMenu
    script_far_call $4094, $1f
    script_far_call $6ba6, $18
    script_end

NajiClimb:
    script_renderer $6c27, $18
    db "I understand."
    script_newline
    db "I'll open the"
    script_wait
    db "door. But,"
    script_newline
    db "are you ready?"
    script_yn_cue
    script_far_call $58d7, $1f
    script_if_eq $d5fe, $01, NajiMenu
    script_far_call $4094, $1f
    script_far_call $6b95, $18
    script_end

NajiAskMenu:
    script_renderer $6c27, $18
    db "What do you"
    script_newline
    db "want to know?"
    script_far_call $5d76, $1f
    script_far_call $6c1b, $18
    script_anchor
    script_jump_table $d600, NajiAskTower, NajiAskItem, NajiAskStop

NajiLeave:
    script_renderer $6c27, $18
    db "See you later."
    script_wait
    script_end

NajiTowerLong:
    script_if_eq $d0df, $01, NajiTowerShort
    script_renderer $6c27, $18
    db "10 underground"
    script_newline
    db "levels here. The"
    script_wait
    db "true legend must"
    script_newline
    db "be hidden here."
    script_wait
    db "Don't misjudge."
    script_wait
    script_write_wram $d0df, $01
    script_far_call $4094, $1f
    script_far_call $6bb7, $18
    script_end

NajiTowerShort:
    script_renderer $6c27, $18
    db "You again! Going"
    script_newline
    db "to try again?"
    script_wait
    db "Persistence is"
    script_newline
    db "the shortcut to"
    script_wait
    db "the legend. I'll"
    script_newline
    db "show you the way"
    script_yn_cue
    script_far_call $58d7, $1f
    script_if_eq $d5fe, $01, NajiMenu
    script_far_call $4094, $1f
    script_far_call $6bb7, $18
    script_end

NajiAskTower:
    script_renderer $6c27, $18
    db "Find the golden"
    script_newline
    db "key in each"
    script_wait
    db "room. It will"
    script_newline
    db "open the door,"
    script_wait
    db "and you can exit"
    script_newline
    db "from that room."
    script_wait
    db "Flying lights"
    script_newline
    db "are hints of"
    script_wait
    db "where the key"
    script_newline
    db "and door hides."
    script_wait
    db "Let me explain"
    script_newline
    db "about Life."
    script_wait
    db "You start with"
    script_newline
    db "three lives."
    script_wait
    db "If you lose all"
    script_newline
    db "lives or leave"
    script_wait
    db "the tower,"
    script_newline
    db "you will lose"
    script_wait
    db "all effects of"
    script_newline
    db "items."
    script_wait
    db "But don't worry."
    script_newline
    db "You won't lose"
    script_wait
    db "your Holy items."
    script_newline
    db "That's all I"
    script_wait
    db "know."
    script_newline
    db "Good luck!"
    script_wait
    script_goto NajiAskMenu

NajiAskItem:
    script_renderer $6c27, $18
    db "Let me explain."
    script_newline
    db "There are over"
    script_wait
    db "300 items hidden"
    script_newline
    db "in this tower."
    script_wait
    db "They're hard to"
    script_newline
    db "find, but try"
    script_wait
    db "making boxes and"
    script_newline
    db "just break them."
    script_wait
    db "The most"
    script_newline
    db "important item"
    script_wait
    db "is a saucer"
    script_newline
    db "stone fragment."
    script_wait
    db "4 fragments"
    script_newline
    db "will make one"
    script_wait
    db "saucer stone."
    script_newline
    db "You can seal a"
    script_wait
    db "good monster"
    script_newline
    db "inside it."
    script_wait
    db "I'm sorry, but"
    script_newline
    db "this is all I"
    script_wait
    db "know. The priest"
    script_newline
    db "in the tower"
    script_wait
    db "will tell you"
    script_newline
    db "more. Bye!"
    script_wait
    script_goto NajiAskMenu

NajiAskStop:
    script_goto NajiMenu
