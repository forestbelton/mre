; Verde (monster breeder at the ranch).
; 
; Verde is one of the townspeople who went to the tower and returned
; (Toamuna's D0DC=3 greeting: "Verde returned. Great! Thank you").
; He introduces himself as "a monster breeder", which fits — like
; Pashute (priest, monster regeneration), he runs a ranch-side service.
; 
; D0E4 gates the state cascade: ==1/3/4 jump to alternate welcomes,
; fall-through is the first-encounter intro.
; 
; The 286-byte Z80 helper region at $061F6E onward (after this script)
; holds routines $07 FAR_CALLed from within the script; we don't
; include those bytes here.
;
; Carved out of analyzed.asm via map.json; see docs/text_engine.md
; for the bytecode reference. Initial dump produced by
; tools/script_disasm.py — hand-curate freely; the extractor's
; append-only rule on non-auto-managed files preserves your edits.

INCLUDE "script.inc"

SECTION "verde_0614f5", ROMX[$54f5], BANK[$18]


VerdeScript:
    SCRIPT_OPEN_TEXTBOX $9982, $10, $04
    SCRIPT_IF_EQ $d0e4, $04, verde_5929
    SCRIPT_IF_EQ $d0e4, $03, verde_5833
    SCRIPT_IF_EQ $d0e4, $01, verde_57cc
    SCRIPT_FAR_CALL $5398, $18
    SCRIPT_RENDERER $53f7, $18
    db "Oh?"
    SCRIPT_NEWLINE
    db "Never seen you."
    SCRIPT_WAIT
    SCRIPT_RENDERER $547f, $18
    db "What?"
    SCRIPT_NEWLINE
    db "Came to help?"
    SCRIPT_WAIT
    SCRIPT_RENDERER $53f7, $18
    db "Hmm... I see."
    SCRIPT_NEWLINE
    db "Naji did, huh?"
    SCRIPT_WAIT
    db "Now, I get it."
    SCRIPT_NEWLINE
    db "You surprised me"
    SCRIPT_WAIT
    db "I am Verde, a"
    SCRIPT_NEWLINE
    db "monster breeder"
    SCRIPT_WAIT
    SCRIPT_RENDERER $54ba, $18
    db "I am the owner"
    SCRIPT_NEWLINE
    db "of the checkroom"
    SCRIPT_WAIT
    SCRIPT_RENDERER $53f7, $18
    db "I'm here just"
    SCRIPT_NEWLINE
    db "like the others"
    SCRIPT_WAIT
    SCRIPT_RENDERER $54ba, $18
    db "Made it up here"
    SCRIPT_NEWLINE
    db "with my energy"
    SCRIPT_WAIT
    db "it gets harder"
    SCRIPT_NEWLINE
    db "as I climb up."
    SCRIPT_WAIT
    db "If this goes on"
    SCRIPT_NEWLINE
    db "to the top,"
    SCRIPT_WAIT
    db "I'd be too tired"
    SCRIPT_NEWLINE
    db "for anything."
    SCRIPT_WAIT
    db "So I thought"
    SCRIPT_NEWLINE
    db "of what to do."
    SCRIPT_WAIT
    SCRIPT_RENDERER $53f7, $18
    db "You're amazing,"
    SCRIPT_NEWLINE
    db "here in a flash."
    SCRIPT_WAIT
    db "No wonder Naji"
    SCRIPT_NEWLINE
    db "trusts you."
    SCRIPT_WAIT
    db "So, I say, let's"
    SCRIPT_NEWLINE
    db "help each other"
    SCRIPT_WAIT
    SCRIPT_RENDERER $54ba, $18
    db "from here on."
    SCRIPT_NEWLINE
    db "But I'd be"
    SCRIPT_WAIT
    db "more trouble"
    SCRIPT_NEWLINE
    db "than help."
    SCRIPT_WAIT
    SCRIPT_RENDERER $53f7, $18
    db "Instead, I'll be"
    SCRIPT_NEWLINE
    db "a supporter."
    SCRIPT_WAIT
    db "I'll be cheering"
    SCRIPT_NEWLINE
    db "you on!"
    SCRIPT_WAIT
    db "When you decide"
    SCRIPT_NEWLINE
    db "to come down,"
    SCRIPT_WAIT
    db "come to the"
    SCRIPT_NEWLINE
    db "checkroom."
    SCRIPT_WAIT
    db "I'm sure I can"
    SCRIPT_NEWLINE
    db "help you then."
    SCRIPT_WAIT
    db "Well then,"
    SCRIPT_NEWLINE
    db "Good luck!"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM $d0e1, $01
    SCRIPT_WRITE_WRAM $d0dc, $03
    SCRIPT_WRITE_WRAM $d0dd, $02
    SCRIPT_WRITE_WRAM $d0de, $02
    SCRIPT_WRITE_WRAM $d0e4, $01
    SCRIPT_END

verde_57cc:
    SCRIPT_FAR_CALL $5345, $18
    SCRIPT_CYCLE 4
    SCRIPT_JUMP_TABLE $d60d, verde_57dd, verde_57fc, verde_580a, verde_5823

verde_57dd:
    SCRIPT_RENDERER $53f7, $18
    db "Oh, hi!"
    SCRIPT_NEWLINE
    db "How's it going?"
    SCRIPT_WAIT
    SCRIPT_GOTO verde_59d4

verde_57fc:
    SCRIPT_RENDERER $53f7, $18
    db "Hello!"
    SCRIPT_WAIT
    SCRIPT_GOTO verde_59d4

verde_580a:
    SCRIPT_RENDERER $53f7, $18
    db "Welcome!"
    SCRIPT_NEWLINE
    db "I'm glad"
    SCRIPT_WAIT
    SCRIPT_GOTO verde_59d4

verde_5823:
    SCRIPT_RENDERER $53f7, $18
    db "Welcome!"
    SCRIPT_WAIT
    SCRIPT_GOTO verde_59d4

verde_5833:
    SCRIPT_FAR_CALL $5345, $18
    SCRIPT_RENDERER $53f7, $18
    db "You're here."
    SCRIPT_NEWLINE
    db "I thank you."
    SCRIPT_WAIT
    db "Thanks for"
    SCRIPT_NEWLINE
    db "helping us!"
    SCRIPT_WAIT
    db "This place is"
    SCRIPT_NEWLINE
    db "getting busy!"
    SCRIPT_WAIT
    db "Oh, by the way,"
    SCRIPT_NEWLINE
    db "I hear that, the"
    SCRIPT_WAIT
    db "Stage Studio"
    SCRIPT_NEWLINE
    db "behind the tower"
    SCRIPT_WAIT
    db "is open again."
    SCRIPT_WAIT
    db "You can link or"
    SCRIPT_NEWLINE
    db "exchange with"
    SCRIPT_WAIT
    db "your pals there."
    SCRIPT_WAIT
    db "It'll be fun."
    SCRIPT_NEWLINE
    db "Go try it out!"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM $d0e4, $01
    SCRIPT_GOTO verde_59d4

verde_5929:
    SCRIPT_FAR_CALL $5345, $18
    SCRIPT_RENDERER $53f7, $18
    db "Oh!"
    SCRIPT_NEWLINE
    db "You're here!"
    SCRIPT_WAIT
    db "Naji told me"
    SCRIPT_NEWLINE
    db "everything."
    SCRIPT_WAIT
    db "I'm excited"
    SCRIPT_NEWLINE
    db "to take care of"
    SCRIPT_WAIT
    db "Phenix!"
    SCRIPT_WAIT
    db "I'm excited"
    SCRIPT_NEWLINE
    db "as a breeder."
    SCRIPT_WAIT
    db "I'll take good"
    SCRIPT_NEWLINE
    db "care of them,"
    SCRIPT_WAIT
    db "so bring"
    SCRIPT_NEWLINE
    db "more of them."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM $d0e4, $01
    SCRIPT_GOTO verde_59d4

verde_59d4:
    SCRIPT_RENDERER $53f7, $18
    db "Let's see."
    SCRIPT_NEWLINE
    db "What can I"
    SCRIPT_WAIT
    db "do for you?"
    SCRIPT_FAR_CALL $63ce, $1f
    SCRIPT_FAR_CALL $53eb, $18
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE $d5ff, verde_5a3a, verde_5adb, verde_5bf1, verde_5c9c, verde_5da4

verde_5a0f:
    SCRIPT_RENDERER $53f7, $18
    db "Do you want"
    SCRIPT_NEWLINE
    db "something else?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL $58d7, $1f
    SCRIPT_JUMP_TABLE $d5fe, verde_59d4, verde_5da4

verde_5a3a:
    SCRIPT_RENDERER $53f7, $18
    db "OK!"
    SCRIPT_NEWLINE
    db "I'll take care"
    SCRIPT_WAIT
    db "of it!"
    SCRIPT_WAIT
    SCRIPT_IF_EQ $cfd9, $ff, verde_5a81
    SCRIPT_RENDERER $53f7, $18
    db "OK! It's "
    SCRIPT_INDEXED_STR $cfd9
    db "."
    SCRIPT_NEWLINE
    db "I got it."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM $cfd9, $ff
    SCRIPT_GOTO verde_5a0f

verde_5a81:
    db "Hm? Looks like"
    SCRIPT_NEWLINE
    db "no monsters here"
    SCRIPT_WAIT
    db "You have to"
    SCRIPT_NEWLINE
    db "have a monster,"
    SCRIPT_WAIT
    db "to leave at"
    SCRIPT_NEWLINE
    db "the checkroom."
    SCRIPT_WAIT
    SCRIPT_GOTO verde_5a0f

verde_5adb:
    SCRIPT_RENDERER $53f7, $18
    db "OK!"
    SCRIPT_NEWLINE
    db "You'll take"
    SCRIPT_WAIT
    db "a monster!"
    SCRIPT_WAIT
    db "Wait a minute."
    SCRIPT_NEWLINE
    db "Your monster is?"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL $5321, $18
    SCRIPT_IF_NEQ $d5fe, $00, verde_5b43
    SCRIPT_RENDERER $54ba, $18
    db "Oh yes,"
    SCRIPT_NEWLINE
    db "I have it here."
    SCRIPT_WAIT
    SCRIPT_GOTO verde_5a0f

verde_5b43:
    SCRIPT_IF_NEQ $d5fe, $01, verde_5b6b
    db "Yes! It's "
    SCRIPT_INDEXED_STR $cfbb
    db "."
    SCRIPT_NEWLINE
    db "I have it here."
    SCRIPT_WAIT
    SCRIPT_GOTO verde_5baf

verde_5b6b:
    db "Oh yes,"
    SCRIPT_NEWLINE
    db "I have it here."
    SCRIPT_WAIT
    db "So, which one"
    SCRIPT_NEWLINE
    db "are you taking?"
    SCRIPT_FAR_CALL $658a, $1f
    SCRIPT_FAR_CALL $53eb, $18
    SCRIPT_ANCHOR
    SCRIPT_IF_EQ $cfbb, $07, verde_5a0f

verde_5baf:
    db "This one, right?"
    SCRIPT_NEWLINE
    db "It's healthy!"
    SCRIPT_WAIT
    db "Take good care"
    SCRIPT_NEWLINE
    db "of it, okay?"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL $404d, $18
    SCRIPT_GOTO verde_5a0f

verde_5bf1:
    SCRIPT_FAR_CALL $5321, $18
    SCRIPT_IF_EQ $d5fe, $01, verde_5c4d
    SCRIPT_RENDERER $53f7, $18
    db "OK! Switch of"
    SCRIPT_NEWLINE
    db "monsters, right?"
    SCRIPT_WAIT
    db "Okay, choose the"
    SCRIPT_NEWLINE
    db "next monster"
    SCRIPT_FAR_CALL $658a, $1f
    SCRIPT_FAR_CALL $53eb, $18
    SCRIPT_ANCHOR
    SCRIPT_IF_EQ $cfbb, $07, verde_5a0f
    SCRIPT_GOTO verde_5baf

verde_5c4d:
    SCRIPT_RENDERER $54ba, $18
    db "Well."
    SCRIPT_NEWLINE
    db "What?"
    SCRIPT_WAIT
    db "I can't exchange"
    SCRIPT_NEWLINE
    db "monsters if you"
    SCRIPT_WAIT
    db "don't have one"
    SCRIPT_NEWLINE
    db "checked in."
    SCRIPT_WAIT
    SCRIPT_GOTO verde_5a0f

verde_5c9c:
    SCRIPT_RENDERER $53f7, $18
    db "Let me explain."
    SCRIPT_WAIT
    db "This checkroom"
    SCRIPT_NEWLINE
    db "is a great place"
    SCRIPT_WAIT
    db "to hold monsters"
    SCRIPT_NEWLINE
    db "regenerated from"
    SCRIPT_WAIT
    db "a saucer stone!"
    SCRIPT_WAIT
    db "If you want to"
    SCRIPT_NEWLINE
    db "carry more than"
    SCRIPT_WAIT
    db "one monster,"
    SCRIPT_NEWLINE
    db "this will help"
    SCRIPT_WAIT
    db "you a lot!"
    SCRIPT_WAIT
    db "I'll keep"
    SCRIPT_NEWLINE
    db "the monsters"
    SCRIPT_WAIT
    db "in good shape"
    SCRIPT_NEWLINE
    db "because I'm a"
    SCRIPT_WAIT
    db "top breeder!"
    SCRIPT_WAIT
    db "That's all."
    SCRIPT_NEWLINE
    db "It's simple."
    SCRIPT_WAIT
    SCRIPT_GOTO verde_5a0f

verde_5da4:
    SCRIPT_RENDERER $53f7, $18
    db "OK!"
    SCRIPT_NEWLINE
    db "That's it."
    SCRIPT_WAIT
    db "I'll take care"
    SCRIPT_NEWLINE
    db "of the monsters."
    SCRIPT_WAIT
    db "Good luck!"
    SCRIPT_WAIT
    SCRIPT_END
