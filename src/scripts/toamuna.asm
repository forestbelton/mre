; Toamuna (ranch guardian, mother of Naji) full script.
;
; Carved out of analyzed.asm via map.json; see docs/text_engine.md for
; the bytecode reference. Entry points (linear bytecode order):
;
;   $40DD  ToamunaScript       textbox setup + state cascade (on D0DC)
;   $4381  ToamunaCycler       cyclic round-robin of 4 default greetings
;   $4408  ToamunaPashute      'Pashute is back. Thanks a lot.' branch
;   $4432  ToamunaVerde        'Verde returned. Great! Thank you' branch
;   $445E  ToamunaAllBack      'Everyone's back...' branch (everyone returned)
;   $44A7  ToamunaMenu         'What do you want to do?' + 3-way dispatch
;   $44D7  ToamunaPostAction   'Need to do something else?' Y/N loop
;   $450F  ToamunaSign         Sign branch (save flow)
;   $45E3  ToamunaConfirm      Confirm branch (load flow)
;   $46B4  ToamunaExit         Exit branch ('Be careful.')

INCLUDE "script.inc"

SECTION "toamuna_0640dd", ROMX[$40dd], BANK[$19]


ToamunaScript:
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    SCRIPT_IF_EQ .Addr=wRanchProgress, .Value=$04, .Target=ToamunaAllBack
    SCRIPT_IF_EQ .Addr=wRanchProgress, .Value=$03, .Target=ToamunaVerde
    SCRIPT_IF_EQ .Addr=wRanchProgress, .Value=$02, .Target=ToamunaPashute
    SCRIPT_IF_EQ .Addr=wRanchProgress, .Value=$01, .Target=ToamunaCycler
    SCRIPT_RENDERER .Addr=Toamuna_RenderPortrait, .Bank=$19
    db "I haven't had a"
    SCRIPT_NEWLINE
    db "guest in so long."
    SCRIPT_WAIT
    db "The guard house"
    SCRIPT_NEWLINE
    db "has been ours."
    SCRIPT_WAIT
    db "I am Toamuna,"
    SCRIPT_NEWLINE
    db "the guardian."
    SCRIPT_WAIT
    db "Did you come to"
    SCRIPT_NEWLINE
    db "climb the tower?"
    SCRIPT_WAIT
    db "Well, this tower"
    SCRIPT_NEWLINE
    db "is famous."
    SCRIPT_WAIT
    db "Until recently,"
    SCRIPT_NEWLINE
    db "it was busy here"
    SCRIPT_WAIT
    db "Adventurers like"
    SCRIPT_NEWLINE
    db "you came from"
    SCRIPT_WAIT
    db "around the world"
    SCRIPT_NEWLINE
    db "seeking a legend"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Toamuna_RenderPortraitAlt, .Bank=$19
    db "A few years ago,"
    SCRIPT_WAIT
    db "a priest named"
    SCRIPT_NEWLINE
    db "Nada came here,"
    SCRIPT_WAIT
    db "and this tower"
    SCRIPT_NEWLINE
    db "became full of"
    SCRIPT_WAIT
    db "Baddies. So no"
    SCRIPT_NEWLINE
    db "one visits now."
    SCRIPT_WAIT
    db "People from the"
    SCRIPT_NEWLINE
    db "town went in to"
    SCRIPT_WAIT
    db "protect it, but"
    SCRIPT_NEWLINE
    db "never came out."
    SCRIPT_WAIT
    db "You don't seem"
    SCRIPT_NEWLINE
    db "strong, but"
    SCRIPT_WAIT
    db "if you still"
    SCRIPT_NEWLINE
    db "want to go,"
    SCRIPT_WAIT
    db "You feel free"
    SCRIPT_NEWLINE
    db "to do so."
    SCRIPT_WAIT
    db "Please help us!"
    SCRIPT_WAIT
    db "Sorry. No use"
    SCRIPT_NEWLINE
    db "being depressed."
    SCRIPT_WAIT
    db "If you go to the"
    SCRIPT_NEWLINE
    db "tower entrance,"
    SCRIPT_WAIT
    db "my son Naji will"
    SCRIPT_NEWLINE
    db "be there."
    SCRIPT_WAIT
    db "He should"
    SCRIPT_NEWLINE
    db "help you out."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wRanchProgress, .Value=$01
    SCRIPT_GOTO .Target=ToamunaMenu

ToamunaCycler:
    SCRIPT_CYCLE .Count=4
    SCRIPT_JUMP_TABLE wCycleCounter, .cycle0, .cycle1, .cycle2, .cycle3
.cycle0:
    SCRIPT_RENDERER .Addr=Toamuna_RenderPortrait, .Bank=$19
    db "Welcome, stay as"
    SCRIPT_NEWLINE
    db "long as you like"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=ToamunaMenu
.cycle1:
    SCRIPT_RENDERER .Addr=Toamuna_RenderPortrait, .Bank=$19
    db "Welcome."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=ToamunaMenu
.cycle2:
    SCRIPT_RENDERER .Addr=Toamuna_RenderPortrait, .Bank=$19
    db "Welcome back."
    SCRIPT_NEWLINE
    db "Go and rest."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=ToamunaMenu
.cycle3:
    SCRIPT_RENDERER .Addr=Toamuna_RenderPortrait, .Bank=$19
    db "Welcome back."
    SCRIPT_NEWLINE
    db "Long day?"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=ToamunaMenu

ToamunaPashute:
    SCRIPT_RENDERER .Addr=Toamuna_RenderPortrait, .Bank=$19
    db "Pashute is back."
    SCRIPT_NEWLINE
    db "Thanks a lot."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wRanchProgress, .Value=$01
    SCRIPT_GOTO .Target=ToamunaMenu

ToamunaVerde:
    SCRIPT_RENDERER .Addr=Toamuna_RenderPortrait, .Bank=$19
    db "Verde returned."
    SCRIPT_NEWLINE
    db "Great! Thank you"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wRanchProgress, .Value=$01
    SCRIPT_GOTO .Target=ToamunaMenu

ToamunaAllBack:
    SCRIPT_RENDERER .Addr=Toamuna_RenderPortrait, .Bank=$19
    db "Everyone's back,"
    SCRIPT_NEWLINE
    db "thanks to you."
    SCRIPT_WAIT
    db "I'm so happy,"
    SCRIPT_NEWLINE
    db "I'm speechless."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wRanchProgress, .Value=$01
    SCRIPT_GOTO .Target=ToamunaMenu

ToamunaMenu:
    SCRIPT_RENDERER .Addr=Toamuna_RenderPortrait, .Bank=$19
    db "What do you"
    SCRIPT_NEWLINE
    db "want to do?"
    SCRIPT_FAR_CALL .Addr=Toamuna_CheckSaveExists, .Bank=$19
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=.afterPrompt
    SCRIPT_FAR_CALL .Addr=Toamuna_ShowMenu1, .Bank=$1f
    SCRIPT_GOTO .Target=ToamunaPostAction
.afterPrompt:
    SCRIPT_FAR_CALL .Addr=Toamuna_ShowMenu2, .Bank=$1f

ToamunaPostAction:
    SCRIPT_FAR_CALL .Addr=Toamuna_LoadPortraitTilemap, .Bank=$19
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE wMainMenuResult, ToamunaSign, ToamunaConfirm, ToamunaExit
ToamunaPostActionBody:
    SCRIPT_RENDERER .Addr=Toamuna_RenderPortrait, .Bank=$19
    db "Need to do"
    SCRIPT_NEWLINE
    db "something else?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL .Addr=ShowYesNoMenu, .Bank=$1f
    SCRIPT_JUMP_TABLE wYNResult, ToamunaMenu, ToamunaExit

ToamunaSign:
    SCRIPT_RENDERER .Addr=Toamuna_RenderPortrait, .Bank=$19
    db "Want to sign the"
    SCRIPT_NEWLINE
    db "guest book?"
    SCRIPT_WAIT
    db "... ... ... ..."
    SCRIPT_NEWLINE
    db "Okay. It's ready"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=Toamuna_CheckSaveExists, .Bank=$19
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=.signSavePrompt
    db "Current data"
    SCRIPT_NEWLINE
    db "will be saved."
    SCRIPT_YN_CUE
    SCRIPT_GOTO .Target=.signReplaceFlow
.signSavePrompt:
    db "Replace previous"
    SCRIPT_NEWLINE
    db "saved data?"
    SCRIPT_YN_CUE
.signReplaceFlow:
    SCRIPT_FAR_CALL .Addr=ShowYesNoMenu, .Bank=$1f
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=ToamunaMenu
    db "Do not remove"
    SCRIPT_NEWLINE
    db "Game Pak."
    SCRIPT_REPEAT_CHAR .Count=120
    SCRIPT_ANCHOR
    SCRIPT_FAR_CALL .Addr=Toamuna_SaveGame, .Bank=$19
    db "Finished signing"
    SCRIPT_NEWLINE
    db "the guest book!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=ToamunaPostActionBody

ToamunaConfirm:
    SCRIPT_RENDERER .Addr=Toamuna_RenderPortrait, .Bank=$19
    db "Want to check"
    SCRIPT_NEWLINE
    db "the guest book?"
    SCRIPT_WAIT
    db "... ... ... ..."
    SCRIPT_NEWLINE
    db "Okay. It's ready"
    SCRIPT_WAIT
    db "Previous data"
    SCRIPT_NEWLINE
    db "will be loaded."
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL .Addr=ShowYesNoMenu, .Bank=$1f
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=ToamunaMenu
    db "Do not remove"
    SCRIPT_NEWLINE
    db "Game Pak."
    SCRIPT_REPEAT_CHAR .Count=120
    SCRIPT_ANCHOR
    SCRIPT_FAR_CALL .Addr=Toamuna_LoadGame, .Bank=$19
    SCRIPT_IF_NEQ .Addr=wYNResult, .Value=$01, .Target=.confirmDoneFlow
    db "Done checking"
    SCRIPT_NEWLINE
    db "the guest book!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=ToamunaPostActionBody
.confirmDoneFlow:
    db "Did not accept?"
    SCRIPT_NEWLINE
    db "Try it again!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=ToamunaPostActionBody

ToamunaExit:
    SCRIPT_RENDERER .Addr=Toamuna_RenderPortrait, .Bank=$19
    db "Okay."
    SCRIPT_NEWLINE
    db "Be careful."
    SCRIPT_WAIT
