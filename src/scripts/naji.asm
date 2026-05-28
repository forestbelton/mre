; Naji (Tower-guard NPC) full script.
;
; Carved out of analyzed.asm via map.json; see docs/text_engine.md for
; the bytecode reference. The interpreter is at HOME $39C5; macros in
; script.inc encode each opcode.
;
; Entry points (in linear bytecode order):
;
;   $717E  NajiScript      textbox setup + state-gated jumps + IF-FIRST-TIME intro
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

SECTION "naji_06317e", ROMX[$717e], BANK[$18]

NajiScript:
    ; Dialog box at BG tilemap $9982, 16 tiles wide × 4 tiles tall.
    ; Every NPC script starts with this $01 textbox-setup opcode.
    SCRIPT_OPEN_TEXTBOX $9982, $10, $04

    ; Branch on Naji's NPC state. $D0DD progresses 0 -> 1 (after first
    ; intro) -> 2 (mid-quest "made it half-way" message available once)
    ; -> 4 (end-game). $C2D7 is a separate story flag. The fall-through
    ; is the long first-visit intro below.
    SCRIPT_IF_EQ $d0dd, $04, NajiCycler
    SCRIPT_IF_EQ $c2d7, $01, NajiCycler
    SCRIPT_IF_EQ $d0dd, $02, NajiProgress
    SCRIPT_IF_EQ $d0dd, $01, NajiCycler
    SCRIPT_RENDERER $6c27, $18
    db "Did you come to"
    SCRIPT_NEWLINE
    db "climb the tower?"
    SCRIPT_WAIT
    db "I'm Naji. The"
    SCRIPT_NEWLINE
    db "guard here. But"
    SCRIPT_WAIT
    db "I'm on vacation"
    SCRIPT_NEWLINE
    db "right now. It's"
    SCRIPT_WAIT
    db "useless to guard"
    SCRIPT_NEWLINE
    db "a place no one"
    SCRIPT_WAIT
    db "dares to come."
    SCRIPT_WAIT
    db "Village people"
    SCRIPT_NEWLINE
    db "tried to rid the"
    SCRIPT_WAIT
    db "problem, but no"
    SCRIPT_NEWLINE
    db "one has returned"
    SCRIPT_WAIT
    db "Since one can't"
    SCRIPT_NEWLINE
    db "do much, I've"
    SCRIPT_WAIT
    db "stayed behind to"
    SCRIPT_NEWLINE
    db "the brave young"
    SCRIPT_WAIT
    db "like you. But I"
    SCRIPT_NEWLINE
    db "have no strength"
    SCRIPT_WAIT
    db "left to fight"
    SCRIPT_NEWLINE
    db "Nada. You have"
    SCRIPT_WAIT
    db "wits and courage"
    SCRIPT_NEWLINE
    db "to fight Nada."
    SCRIPT_WAIT
    db "Help us? I am"
    SCRIPT_NEWLINE
    db "the best guide."
    SCRIPT_WAIT
    db "Please help!"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM $d0dd, $01
    SCRIPT_GOTO NajiMenu

NajiCycler:
    SCRIPT_CYCLE 4
    SCRIPT_JUMP_TABLE $d60d, naji_734a, naji_736d, naji_7394, naji_73bc

naji_734a:
    SCRIPT_RENDERER $6c9f, $18
    db "Oh, you're here."
    SCRIPT_NEWLINE
    db "Good luck."
    SCRIPT_WAIT
    SCRIPT_GOTO NajiMenu

naji_736d:
    SCRIPT_RENDERER $6c27, $18
    db "It's you. Good"
    SCRIPT_NEWLINE
    db "luck, my friend."
    SCRIPT_WAIT
    SCRIPT_GOTO NajiMenu

naji_7394:
    SCRIPT_RENDERER $6c9f, $18
    db "It's you. We're"
    SCRIPT_NEWLINE
    db "counting on you."
    SCRIPT_WAIT
    SCRIPT_GOTO NajiMenu

naji_73bc:
    SCRIPT_RENDERER $6c27, $18
    db "Hey. It's you!"
    SCRIPT_NEWLINE
    db "Take it easy!"
    SCRIPT_WAIT
    SCRIPT_GOTO NajiMenu

NajiProgress:
    SCRIPT_RENDERER $6c9f, $18
    db "Oh, it's you"
    SCRIPT_NEWLINE
    db "again. You made"
    SCRIPT_WAIT
    db "it half-way up."
    SCRIPT_NEWLINE
    db "I wasn't wrong"
    SCRIPT_WAIT
    db "in counting on"
    SCRIPT_NEWLINE
    db "you. Some of our"
    SCRIPT_WAIT
    db "villagers got"
    SCRIPT_NEWLINE
    db "back, but don't"
    SCRIPT_WAIT
    db "get careless."
    SCRIPT_NEWLINE
    db "It gets harder."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM $d0dd, $01
    SCRIPT_GOTO NajiMenu

NajiMenu:
    SCRIPT_RENDERER $6c27, $18
    db "What are your"
    SCRIPT_NEWLINE
    db "plans this time?"
    SCRIPT_IF_EQ $d0e2, $01, .checkAsk
    SCRIPT_IF_NEQ $cff0, $00, .renderClimb
    SCRIPT_FAR_CALL $5abc, $1f
    SCRIPT_GOTO .menuFinalize
.renderClimb:
    SCRIPT_FAR_CALL $5b42, $1f
    SCRIPT_GOTO .menuFinalize
.checkAsk:
    SCRIPT_IF_NEQ $cff0, $00, .renderLeave
    SCRIPT_FAR_CALL $5bcb, $1f
    SCRIPT_GOTO .menuFinalize
.renderLeave:
    SCRIPT_FAR_CALL $5c54, $1f
.menuFinalize:
    SCRIPT_FAR_CALL $6c1b, $18
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE $d5ff, NajiRestart, NajiClimb, NajiTowerLong, NajiAskMenu, NajiLeave

NajiRestart:
    SCRIPT_RENDERER $6c27, $18
    db "You've climbed"
    SCRIPT_NEWLINE
    db "till Level "
    SCRIPT_DECIMAL $cff2
    SCRIPT_WAIT
    db "Want to"
    SCRIPT_NEWLINE
    db "start there?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL $58d7, $1f
    SCRIPT_IF_EQ $d5fe, $01, NajiMenu
    SCRIPT_FAR_CALL $4094, $1f
    SCRIPT_FAR_CALL $6ba6, $18
    SCRIPT_END

NajiClimb:
    SCRIPT_RENDERER $6c27, $18
    db "I understand."
    SCRIPT_NEWLINE
    db "I'll open the"
    SCRIPT_WAIT
    db "door. But,"
    SCRIPT_NEWLINE
    db "are you ready?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL $58d7, $1f
    SCRIPT_IF_EQ $d5fe, $01, NajiMenu
    SCRIPT_FAR_CALL $4094, $1f
    SCRIPT_FAR_CALL $6b95, $18
    SCRIPT_END

NajiAskMenu:
    SCRIPT_RENDERER $6c27, $18
    db "What do you"
    SCRIPT_NEWLINE
    db "want to know?"
    SCRIPT_FAR_CALL $5d76, $1f
    SCRIPT_FAR_CALL $6c1b, $18
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE $d600, NajiAskTower, NajiAskItem, NajiAskStop

NajiLeave:
    SCRIPT_RENDERER $6c27, $18
    db "See you later."
    SCRIPT_WAIT
    SCRIPT_END

NajiTowerLong:
    SCRIPT_IF_EQ $d0df, $01, NajiTowerShort
    SCRIPT_RENDERER $6c27, $18
    db "10 underground"
    SCRIPT_NEWLINE
    db "levels here. The"
    SCRIPT_WAIT
    db "true legend must"
    SCRIPT_NEWLINE
    db "be hidden here."
    SCRIPT_WAIT
    db "Don't misjudge."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM $d0df, $01
    SCRIPT_FAR_CALL $4094, $1f
    SCRIPT_FAR_CALL $6bb7, $18
    SCRIPT_END

NajiTowerShort:
    SCRIPT_RENDERER $6c27, $18
    db "You again! Going"
    SCRIPT_NEWLINE
    db "to try again?"
    SCRIPT_WAIT
    db "Persistence is"
    SCRIPT_NEWLINE
    db "the shortcut to"
    SCRIPT_WAIT
    db "the legend. I'll"
    SCRIPT_NEWLINE
    db "show you the way"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL $58d7, $1f
    SCRIPT_IF_EQ $d5fe, $01, NajiMenu
    SCRIPT_FAR_CALL $4094, $1f
    SCRIPT_FAR_CALL $6bb7, $18
    SCRIPT_END

NajiAskTower:
    SCRIPT_RENDERER $6c27, $18
    db "Find the golden"
    SCRIPT_NEWLINE
    db "key in each"
    SCRIPT_WAIT
    db "room. It will"
    SCRIPT_NEWLINE
    db "open the door,"
    SCRIPT_WAIT
    db "and you can exit"
    SCRIPT_NEWLINE
    db "from that room."
    SCRIPT_WAIT
    db "Flying lights"
    SCRIPT_NEWLINE
    db "are hints of"
    SCRIPT_WAIT
    db "where the key"
    SCRIPT_NEWLINE
    db "and door hides."
    SCRIPT_WAIT
    db "Let me explain"
    SCRIPT_NEWLINE
    db "about Life."
    SCRIPT_WAIT
    db "You start with"
    SCRIPT_NEWLINE
    db "three lives."
    SCRIPT_WAIT
    db "If you lose all"
    SCRIPT_NEWLINE
    db "lives or leave"
    SCRIPT_WAIT
    db "the tower,"
    SCRIPT_NEWLINE
    db "you will lose"
    SCRIPT_WAIT
    db "all effects of"
    SCRIPT_NEWLINE
    db "items."
    SCRIPT_WAIT
    db "But don't worry."
    SCRIPT_NEWLINE
    db "You won't lose"
    SCRIPT_WAIT
    db "your Holy items."
    SCRIPT_NEWLINE
    db "That's all I"
    SCRIPT_WAIT
    db "know."
    SCRIPT_NEWLINE
    db "Good luck!"
    SCRIPT_WAIT
    SCRIPT_GOTO NajiAskMenu

NajiAskItem:
    SCRIPT_RENDERER $6c27, $18
    db "Let me explain."
    SCRIPT_NEWLINE
    db "There are over"
    SCRIPT_WAIT
    db "300 items hidden"
    SCRIPT_NEWLINE
    db "in this tower."
    SCRIPT_WAIT
    db "They're hard to"
    SCRIPT_NEWLINE
    db "find, but try"
    SCRIPT_WAIT
    db "making boxes and"
    SCRIPT_NEWLINE
    db "just break them."
    SCRIPT_WAIT
    db "The most"
    SCRIPT_NEWLINE
    db "important item"
    SCRIPT_WAIT
    db "is a saucer"
    SCRIPT_NEWLINE
    db "stone fragment."
    SCRIPT_WAIT
    db "4 fragments"
    SCRIPT_NEWLINE
    db "will make one"
    SCRIPT_WAIT
    db "saucer stone."
    SCRIPT_NEWLINE
    db "You can seal a"
    SCRIPT_WAIT
    db "good monster"
    SCRIPT_NEWLINE
    db "inside it."
    SCRIPT_WAIT
    db "I'm sorry, but"
    SCRIPT_NEWLINE
    db "this is all I"
    SCRIPT_WAIT
    db "know. The priest"
    SCRIPT_NEWLINE
    db "in the tower"
    SCRIPT_WAIT
    db "will tell you"
    SCRIPT_NEWLINE
    db "more. Bye!"
    SCRIPT_WAIT
    SCRIPT_GOTO NajiAskMenu

NajiAskStop:
    SCRIPT_GOTO NajiMenu
