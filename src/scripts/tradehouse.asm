; Trade House (link-cable shop) — initial empty state.
; 
; Entry $0614F5 (separate script) is the same building when the
; shopkeeper is present; this script handles the case where the
; building is empty and the player finds a note explaining the link
; function. D0E3 gates the long intro vs the short repeat-visit text.
; 
; The tail region from $6251A onward is the shared "What do you
; want to do?" menu sub-script, which the sibling NPC at $0614F5
; also reaches via GOTO. Bundled here so the labels live in one
; place; cross-file references from the other script resolve at
; link time.
;
; Carved out of analyzed.asm via map.json; see docs/text_engine.md
; for the bytecode reference. Initial dump produced by
; tools/script_disasm.py — hand-curate freely; the extractor's
; append-only rule on non-auto-managed files preserves your edits.

INCLUDE "script.inc"

SECTION "tradehouse_062092", ROMX[$6092], BANK[$18]


TradeHouseEntry:
    SCRIPT_OPEN_TEXTBOX $9982, $10, $04
    SCRIPT_IF_EQ $d0e3, $01, tradehouse_60f9
    SCRIPT_FAR_CALL $5f6e, $18
    db "Nobody seems"
    SCRIPT_NEWLINE
    db "to be here."
    SCRIPT_WAIT
    db "Oh!"
    SCRIPT_NEWLINE
    db "There's a note!"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL $5fcb, $18
    db "Link function"
    SCRIPT_NEWLINE
    db "seems usable."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM $d0e3, $01
    SCRIPT_FAR_CALL $5f71, $18
    SCRIPT_GOTO tradehouse_60fd

tradehouse_60f9:
    SCRIPT_FAR_CALL $5f6e, $18

tradehouse_60fd:
    db "What would you"
    SCRIPT_NEWLINE
    db "like to play?"
    SCRIPT_FAR_CALL $5f50, $1f
    SCRIPT_FAR_CALL $5fbf, $18
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE $d5ff, tradehouse_612b, tradehouse_6190, tradehouse_646b

tradehouse_612b:
    db "OK. Let's enter"
    SCRIPT_NEWLINE
    db "the room, then."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL $18f7, $00
    SCRIPT_FAR_CALL $5f6e, $18
    SCRIPT_IF_EQ $c2c0, $04, tradehouse_616d
    SCRIPT_IF_EQ $c2c0, $05, tradehouse_616d
    SCRIPT_IF_EQ $c2c0, $06, tradehouse_616d
    SCRIPT_FAR_CALL $195e, $00
    SCRIPT_FAR_CALL $5f6e, $18

tradehouse_616d:
    db "Done. OK, let's"
    SCRIPT_NEWLINE
    db "leave the room."
    SCRIPT_WAIT
    SCRIPT_GOTO tradehouse_60fd

tradehouse_6190:
    db "Okay. Let me try"
    SCRIPT_NEWLINE
    db "the exchange."
    SCRIPT_YN_CUE
    SCRIPT_WRITE_WRAM $d5c2, $00
    SCRIPT_FAR_CALL $4040, $31
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE $d5c2, tradehouse_624e, tradehouse_61c3, tradehouse_6203, tradehouse_6238

tradehouse_61c3:
    db "Your friend does"
    SCRIPT_NEWLINE
    db "not seem ready."
    SCRIPT_WAIT
    db "Try when you're"
    SCRIPT_NEWLINE
    db "both ready."
    SCRIPT_WAIT
    SCRIPT_GOTO tradehouse_60fd

tradehouse_6203:
    db "You don't seem"
    SCRIPT_NEWLINE
    db "ready yet."
    SCRIPT_WAIT
    db "Connect the"
    SCRIPT_NEWLINE
    db "Link Cable!"
    SCRIPT_WAIT
    SCRIPT_GOTO tradehouse_60fd

tradehouse_6238:
    db "Process"
    SCRIPT_NEWLINE
    db "cancelled."
    SCRIPT_WAIT
    SCRIPT_GOTO tradehouse_60fd

tradehouse_624e:
    db "But before that,"
    SCRIPT_NEWLINE
    db "current status"
    SCRIPT_WAIT
    db "must be saved."
    SCRIPT_NEWLINE
    db "Okay?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL $58d7, $1f
    SCRIPT_IF_EQ $d5fe, $00, tradehouse_62b3
    db "Hmmm..."
    SCRIPT_WAIT
    db "Let's not do it"
    SCRIPT_NEWLINE
    db "this time."
    SCRIPT_WAIT
    SCRIPT_GOTO tradehouse_60fd

tradehouse_62b3:
    db "Now saving."
    SCRIPT_NEWLINE
    db "Leave Game Pak."
    SCRIPT_WAIT
    SCRIPT_REPEAT_CHAR 120
    SCRIPT_ANCHOR
    SCRIPT_FAR_CALL $4b67, $12
    db "We're ready! Now"
    SCRIPT_NEWLINE
    db "start exchange!"
    SCRIPT_WAIT
    db "Okay, then..."
    SCRIPT_WAIT
    db "Let's choose a"
    SCRIPT_NEWLINE
    db "room to exchange"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM $cfbe, $02
    SCRIPT_FAR_CALL $1937, $00
    SCRIPT_FAR_CALL $5dec, $18
    SCRIPT_FAR_CALL $5f6e, $18
    db "Next, choose a"
    SCRIPT_NEWLINE
    db "room to receive."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM $cfbe, $01
    SCRIPT_FAR_CALL $1937, $00
    SCRIPT_FAR_CALL $5df3, $18
    SCRIPT_FAR_CALL $5f6e, $18
    db "You're both OK?"
    SCRIPT_NEWLINE
    db "Let's start!"
    SCRIPT_WAIT
    db "Leave Link Cable"
    SCRIPT_NEWLINE
    db "and Game Pak."
    SCRIPT_WAIT
    db "Your friend is"
    SCRIPT_NEWLINE
    db "getting ready."
    SCRIPT_WAIT
    db "Let's wait for"
    SCRIPT_NEWLINE
    db "a little while."
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL $44c9, $31
    SCRIPT_FAR_CALL $5f6e, $18
    SCRIPT_FAR_CALL $5de3, $18
    SCRIPT_JUMP_TABLE $d5c2, tradehouse_63f5, tradehouse_6424, tradehouse_6455, tradehouse_6455

tradehouse_63f5:
    db "Yes!"
    SCRIPT_NEWLINE
    db "We did it!"
    SCRIPT_WAIT
    db "The exchange was"
    SCRIPT_NEWLINE
    db "a success!"
    SCRIPT_WAIT
    SCRIPT_GOTO tradehouse_60fd

tradehouse_6424:
    db "Uh-oh. Something"
    SCRIPT_NEWLINE
    db "went wrong."
    SCRIPT_WAIT
    db "Let's try again."
    SCRIPT_WAIT
    SCRIPT_GOTO tradehouse_60fd

tradehouse_6455:
    db "Process"
    SCRIPT_NEWLINE
    db "cancelled."
    SCRIPT_WAIT
    SCRIPT_GOTO tradehouse_60fd

tradehouse_646b:
    db "I should stop"
    SCRIPT_NEWLINE
    db "for now."
    SCRIPT_WAIT
    SCRIPT_END
    SCRIPT_OPEN_TEXTBOX $9982, $10, $04
    SCRIPT_FAR_CALL $5e03, $18
    SCRIPT_CYCLE 4
    SCRIPT_JUMP_TABLE $d60d, tradehouse_6499, tradehouse_64b5, tradehouse_64d7, tradehouse_64fd

tradehouse_6499:
    SCRIPT_RENDERER $5f3c, $18
    db "Hey!"
    SCRIPT_NEWLINE
    db "How's it going?"
    SCRIPT_WAIT
    SCRIPT_GOTO SharedMenuPrompt

tradehouse_64b5:
    SCRIPT_RENDERER $5f3c, $18
    db "Hey! Howdy?"
    SCRIPT_NEWLINE
    db "Have some fun!"
    SCRIPT_WAIT
    SCRIPT_GOTO SharedMenuPrompt

tradehouse_64d7:
    SCRIPT_RENDERER $5f3c, $18
    db "Oh! You again!"
    SCRIPT_NEWLINE
    db "Take your time!"
    SCRIPT_WAIT
    SCRIPT_GOTO SharedMenuPrompt

tradehouse_64fd:
    SCRIPT_RENDERER $5f3c, $18
    db "Wow!"
    SCRIPT_NEWLINE
    db "Doing your best?"
    SCRIPT_WAIT
    SCRIPT_GOTO SharedMenuPrompt

SharedMenuPrompt:
    SCRIPT_RENDERER $5f3c, $18
    db "What do you"
    SCRIPT_NEWLINE
    db "want to do?"
    SCRIPT_FAR_CALL $5e43, $1f
    SCRIPT_FAR_CALL $5ebc, $18
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE $d5ff, tradehouse_654b, tradehouse_659a, tradehouse_6614, tradehouse_6641, tradehouse_69ab

tradehouse_654b:
    SCRIPT_RENDERER $5f3c, $18
    db "Leave it to me!"
    SCRIPT_NEWLINE
    db "I got it ready."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL $1982, $00
    SCRIPT_FAR_CALL $5e03, $18
    SCRIPT_RENDERER $5f3c, $18
    db "Oh, you're done?"
    SCRIPT_NEWLINE
    db "Great job!"
    SCRIPT_WAIT
    SCRIPT_GOTO SharedMenuPrompt

tradehouse_659a:
    SCRIPT_RENDERER $5f3c, $18
    db "Want to try a"
    SCRIPT_NEWLINE
    db "room. Good luck!"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL $18f7, $00
    SCRIPT_FAR_CALL $5e03, $18
    SCRIPT_IF_EQ $c2c0, $04, tradehouse_65fd
    SCRIPT_IF_EQ $c2c0, $05, tradehouse_65fd
    SCRIPT_IF_EQ $c2c0, $06, tradehouse_65fd
    SCRIPT_RENDERER $5f3c, $18
    db "Okay! Now enter"
    SCRIPT_NEWLINE
    db "the room!"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL $195e, $00
    SCRIPT_FAR_CALL $5e03, $18

tradehouse_65fd:
    SCRIPT_RENDERER $5f3c, $18
    db "Not today, huh?"
    SCRIPT_WAIT
    SCRIPT_GOTO SharedMenuPrompt

tradehouse_6614:
    SCRIPT_RENDERER $5f3c, $18
    db "Now,"
    SCRIPT_NEWLINE
    db "let me explain."
    SCRIPT_FAR_CALL $5fc3, $1f
    SCRIPT_FAR_CALL $5ebc, $18
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE $d600, tradehouse_69c9, tradehouse_6a9b
    db "bk"
    SCRIPT_GOTO SharedMenuPrompt

tradehouse_6641:
    SCRIPT_RENDERER $5f3c, $18
    db "Well then,"
    SCRIPT_NEWLINE
    db "let's exchange!"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL $4040, $31
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE $d5c2, tradehouse_66f9, tradehouse_6670, tradehouse_66a6, tradehouse_66df

tradehouse_6670:
    SCRIPT_RENDERER $5ec8, $18
    db "Opponent not"
    SCRIPT_NEWLINE
    db "ready yet."
    SCRIPT_WAIT
    db "Call again"
    SCRIPT_NEWLINE
    db "when ready."
    SCRIPT_WAIT
    SCRIPT_GOTO SharedMenuPrompt

tradehouse_66a6:
    SCRIPT_RENDERER $5ec8, $18
    db "You don't look"
    SCRIPT_NEWLINE
    db "ready yet."
    SCRIPT_WAIT
    db "Connect the"
    SCRIPT_NEWLINE
    db "Link Cable."
    SCRIPT_WAIT
    SCRIPT_GOTO SharedMenuPrompt

tradehouse_66df:
    SCRIPT_RENDERER $5ec8, $18
    db "Process"
    SCRIPT_NEWLINE
    db "cancelled."
    SCRIPT_WAIT
    SCRIPT_GOTO SharedMenuPrompt

tradehouse_66f9:
    SCRIPT_RENDERER $5ec8, $18
    db "First, I'll save"
    SCRIPT_NEWLINE
    db "current status."
    SCRIPT_WAIT
    db "Okay?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL $58d7, $1f
    SCRIPT_IF_EQ $d5fe, $00, tradehouse_676b
    SCRIPT_RENDERER $5ec8, $18
    db "I see. How"
    SCRIPT_NEWLINE
    db "disappointing."
    SCRIPT_WAIT
    db "Tell me again,"
    SCRIPT_NEWLINE
    db "if you like."
    SCRIPT_WAIT
    SCRIPT_GOTO SharedMenuPrompt

tradehouse_676b:
    SCRIPT_RENDERER $5f3c, $18
    db "Okay. Looks like"
    SCRIPT_NEWLINE
    db "you're ready."
    SCRIPT_WAIT
    db "Well."
    SCRIPT_NEWLINE
    db "Wait a second."
    SCRIPT_WAIT
    SCRIPT_RENDERER $5ec8, $18
    db "I'm saving now."
    SCRIPT_NEWLINE
    db "Leave Game Pak."
    SCRIPT_REPEAT_CHAR 120
    SCRIPT_ANCHOR
    SCRIPT_FAR_CALL $4b67, $12
    SCRIPT_RENDERER $5f3c, $18
    db "Sorry you waited"
    SCRIPT_NEWLINE
    db "Let's exchange."
    SCRIPT_WAIT
    SCRIPT_RENDERER $5ec8, $18
    db "Okay, now choose"
    SCRIPT_WAIT
    db "the room you"
    SCRIPT_NEWLINE
    db "want to exchange"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM $cfbe, $02
    SCRIPT_FAR_CALL $1937, $00
    SCRIPT_FAR_CALL $5dec, $18
    SCRIPT_FAR_CALL $5e03, $18
    SCRIPT_RENDERER $5f3c, $18
    db "Now, choose a"
    SCRIPT_NEWLINE
    db "room to receive."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM $cfbe, $01
    SCRIPT_FAR_CALL $1937, $00
    SCRIPT_FAR_CALL $5df3, $18
    SCRIPT_FAR_CALL $5e03, $18
    SCRIPT_RENDERER $5f3c, $18
    db "Are you both OK?"
    SCRIPT_NEWLINE
    db "Let's get going."
    SCRIPT_WAIT
    SCRIPT_RENDERER $5ec8, $18
    db "Leave Link Cable"
    SCRIPT_NEWLINE
    db "and Game Pak."
    SCRIPT_WAIT
    db "Your friend is"
    SCRIPT_NEWLINE
    db "getting ready."
    SCRIPT_WAIT
    db "Please wait"
    SCRIPT_NEWLINE
    db "a second."
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL $44c9, $31
    SCRIPT_FAR_CALL $5e03, $18
    SCRIPT_FAR_CALL $5de3, $18
    SCRIPT_JUMP_TABLE $d5c2, tradehouse_68fc, tradehouse_6958, tradehouse_6991, tradehouse_6991

tradehouse_68fc:
    SCRIPT_RENDERER $5f3c, $18
    db "Whoa! Looks like"
    SCRIPT_NEWLINE
    db "it was a success"
    SCRIPT_WAIT
    SCRIPT_RENDERER $5f3c, $18
    db "Exchange done."
    SCRIPT_WAIT
    db "Call if you need"
    SCRIPT_NEWLINE
    db "anything else."
    SCRIPT_WAIT
    SCRIPT_GOTO SharedMenuPrompt

tradehouse_6958:
    SCRIPT_RENDERER $5ec8, $18
    db "Hmmm. Looks"
    SCRIPT_NEWLINE
    db "like we failed."
    SCRIPT_WAIT
    db "Can you try"
    SCRIPT_NEWLINE
    db "it again?"
    SCRIPT_WAIT
    SCRIPT_GOTO SharedMenuPrompt

tradehouse_6991:
    SCRIPT_RENDERER $5ec8, $18
    db "Process"
    SCRIPT_NEWLINE
    db "cancelled."
    SCRIPT_WAIT
    SCRIPT_GOTO SharedMenuPrompt

tradehouse_69ab:
    SCRIPT_RENDERER $5f3c, $18
    db "Okay! Please"
    SCRIPT_NEWLINE
    db "come again!"
    SCRIPT_WAIT
    SCRIPT_END

tradehouse_69c9:
    SCRIPT_RENDERER $5ec8, $18
    db "You can make 3"
    SCRIPT_NEWLINE
    db "rooms. Choose a"
    SCRIPT_WAIT
    db "large or small"
    SCRIPT_NEWLINE
    db "sized room."
    SCRIPT_WAIT
    db "Place monsters"
    SCRIPT_NEWLINE
    db "and items where"
    SCRIPT_WAIT
    db "you wish. Don't"
    SCRIPT_NEWLINE
    db "forget the door"
    SCRIPT_WAIT
    db "and key. You can"
    SCRIPT_NEWLINE
    db "place 3 types"
    SCRIPT_WAIT
    db "and up to 9"
    SCRIPT_NEWLINE
    db "monsters in all."
    SCRIPT_WAIT
    db "That's all."
    SCRIPT_NEWLINE
    db "Have fun!"
    SCRIPT_WAIT
    SCRIPT_GOTO tradehouse_6614

tradehouse_6a9b:
    SCRIPT_RENDERER $5ec8, $18
    db "Link Exchange,"
    SCRIPT_NEWLINE
    db "right?"
    SCRIPT_WAIT
    SCRIPT_RENDERER $5f3c, $18
    db "This lets you"
    SCRIPT_NEWLINE
    db "exchange"
    SCRIPT_WAIT
    db "rooms created"
    SCRIPT_NEWLINE
    db "with your pals."
    SCRIPT_WAIT
    db "A cool feature"
    SCRIPT_NEWLINE
    db "only found here."
    SCRIPT_WAIT
    db "Create fun or"
    SCRIPT_NEWLINE
    db "difficult rooms"
    SCRIPT_WAIT
    db "and attack them"
    SCRIPT_NEWLINE
    db "with your pals!"
    SCRIPT_WAIT
    db "That's fun."
    SCRIPT_WAIT
    db "Enjoy!"
    SCRIPT_WAIT
    SCRIPT_GOTO tradehouse_6614
