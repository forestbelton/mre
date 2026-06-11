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

INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "text.inc"
INCLUDE "sound_ids.inc"

SECTION "Toamuna script functions", ROMX

Toamuna_LoadGame:
	FAR_CALL LoadGameFromSram
	ld [wYNResult], a
	ret
Toamuna_SaveGame:
	FAR_CALL SaveGameToSram
	ld [wYNResult], a
	ret
Toamuna_CheckSaveExists:
	FAR_CALL HasSavedGame
	ld [wYNResult], a
	ret
	call Func_00_0822
	call HideAllSprites
	call Func_00_3971
	ld a, $01
	ld [rVBK], a
	ld a, $1a
	ld hl, $4000
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	call Toamuna_LoadPortraitTilemap
	call Toamuna_RenderPortrait
	call HideUnusedOamSprites
	ld a, $1a
	ld hl, $5800
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, $1a
	ld hl, $5840
	ld de, wObjPalettes
	ld bc, $0030
	call BankCopy
	xor a
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	call WaitForNextFrame
	push af
	ld a, SOUND_BGM_Toamuna
	call PlaySoundTracked
	pop af
	ld hl, ToamunaScript
	call ScriptDispatcherEnterAfterCall
	jp LeaveTownBuilding
Toamuna_LoadPortraitTilemap:
	ld hl, $5880
	ld a, $1a
	ld de, $9800
	call BankMapCopyA
	ret
Toamuna_RenderPortrait:
	ld a, $8b
	ld [wRendererAddr], a
	ld a, $40
	ld [$d61f], a
	ld a, $19
	ld [wRendererBank], a
	ld a, $1a
	ld [wDrawBank], a
	ld hl, $5a56
	ld bc, $2828
	call DrawMetasprite
	ld hl, $5a3e
	ld a, $1a
	ld de, $98c4
	call BankMapCopyA
	ret
Toamuna_RenderPortraitAlt:
	ld a, $b4
	ld [wRendererAddr], a
	ld a, $40
	ld [$d61f], a
	ld a, $19
	ld [wRendererBank], a
	ld a, $1a
	ld [wDrawBank], a
	ld hl, $5aab
	ld bc, $2828
	call DrawMetasprite
	ld hl, $5a93
	ld a, $1a
	ld de, $98c4
	call BankMapCopyA
	ret

SECTION "Toamuna script", ROMX


ToamunaScript:
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    SCRIPT_IF_EQ .Addr=wRanchProgress, .Value=$04, .Target=ToamunaAllBack
    SCRIPT_IF_EQ .Addr=wRanchProgress, .Value=$03, .Target=ToamunaVerde
    SCRIPT_IF_EQ .Addr=wRanchProgress, .Value=$02, .Target=ToamunaPashute
    SCRIPT_IF_EQ .Addr=wRanchProgress, .Value=$01, .Target=ToamunaCycler
    SCRIPT_RENDERER Toamuna_RenderPortrait
    db "I haven't had a\r"
    db "guest in so long."
    SCRIPT_WAIT
    db "The guard house\r"
    db "has been ours."
    SCRIPT_WAIT
    db "I am Toamuna,\r"
    db "the guardian."
    SCRIPT_WAIT
    db "Did you come to\r"
    db "climb the tower?"
    SCRIPT_WAIT
    db "Well, this tower\r"
    db "is famous."
    SCRIPT_WAIT
    db "Until recently,\r"
    db "it was busy here"
    SCRIPT_WAIT
    db "Adventurers like\r"
    db "you came from"
    SCRIPT_WAIT
    db "around the world\r"
    db "seeking a legend"
    SCRIPT_WAIT
    SCRIPT_RENDERER Toamuna_RenderPortraitAlt
    db "A few years ago,"
    SCRIPT_WAIT
    db "a priest named\r"
    db "Nada came here,"
    SCRIPT_WAIT
    db "and this tower\r"
    db "became full of"
    SCRIPT_WAIT
    db "Baddies. So no\r"
    db "one visits now."
    SCRIPT_WAIT
    db "People from the\r"
    db "town went in to"
    SCRIPT_WAIT
    db "protect it, but\r"
    db "never came out."
    SCRIPT_WAIT
    db "You don't seem\r"
    db "strong, but"
    SCRIPT_WAIT
    db "if you still\r"
    db "want to go,"
    SCRIPT_WAIT
    db "You feel free\r"
    db "to do so."
    SCRIPT_WAIT
    db "Please help us!"
    SCRIPT_WAIT
    db "Sorry. No use\r"
    db "being depressed."
    SCRIPT_WAIT
    db "If you go to the\r"
    db "tower entrance,"
    SCRIPT_WAIT
    db "my son Naji will\r"
    db "be there."
    SCRIPT_WAIT
    db "He should\r"
    db "help you out."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wRanchProgress, .Value=$01
    SCRIPT_GOTO .Target=ToamunaMenu

ToamunaCycler:
    SCRIPT_CYCLE .Count=4
    SCRIPT_JUMP_TABLE wCycleCounter, .cycle0, .cycle1, .cycle2, .cycle3
.cycle0:
    SCRIPT_RENDERER Toamuna_RenderPortrait
    db "Welcome, stay as\r"
    db "long as you like"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=ToamunaMenu
.cycle1:
    SCRIPT_RENDERER Toamuna_RenderPortrait
    db "Welcome."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=ToamunaMenu
.cycle2:
    SCRIPT_RENDERER Toamuna_RenderPortrait
    db "Welcome back.\r"
    db "Go and rest."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=ToamunaMenu
.cycle3:
    SCRIPT_RENDERER Toamuna_RenderPortrait
    db "Welcome back.\r"
    db "Long day?"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=ToamunaMenu

ToamunaPashute:
    SCRIPT_RENDERER Toamuna_RenderPortrait
    db "Pashute is back.\r"
    db "Thanks a lot."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wRanchProgress, .Value=$01
    SCRIPT_GOTO .Target=ToamunaMenu

ToamunaVerde:
    SCRIPT_RENDERER Toamuna_RenderPortrait
    db "Verde returned.\r"
    db "Great! Thank you"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wRanchProgress, .Value=$01
    SCRIPT_GOTO .Target=ToamunaMenu

ToamunaAllBack:
    SCRIPT_RENDERER Toamuna_RenderPortrait
    db "Everyone's back,\r"
    db "thanks to you."
    SCRIPT_WAIT
    db "I'm so happy,\r"
    db "I'm speechless."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wRanchProgress, .Value=$01
    SCRIPT_GOTO .Target=ToamunaMenu

ToamunaMenu:
    SCRIPT_RENDERER Toamuna_RenderPortrait
    db "What do you\r"
    db "want to do?"
    SCRIPT_FAR_CALL Toamuna_CheckSaveExists
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=.afterPrompt
    SCRIPT_FAR_CALL Toamuna_ShowMenu1
    SCRIPT_GOTO .Target=ToamunaPostAction
.afterPrompt:
    SCRIPT_FAR_CALL Toamuna_ShowMenu2

ToamunaPostAction:
    SCRIPT_FAR_CALL Toamuna_LoadPortraitTilemap
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE wMainMenuResult, ToamunaSign, ToamunaConfirm, ToamunaExit
ToamunaPostActionBody:
    SCRIPT_RENDERER Toamuna_RenderPortrait
    db "Need to do\r"
    db "something else?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL ShowYesNoMenu
    SCRIPT_JUMP_TABLE wYNResult, ToamunaMenu, ToamunaExit

ToamunaSign:
    SCRIPT_RENDERER Toamuna_RenderPortrait
    db "Want to sign the\r"
    db "guest book?"
    SCRIPT_WAIT
    db "... ... ... ...\r"
    db "Okay. It's ready"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL Toamuna_CheckSaveExists
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=.signSavePrompt
    db "Current data\r"
    db "will be saved."
    SCRIPT_YN_CUE
    SCRIPT_GOTO .Target=.signReplaceFlow
.signSavePrompt:
    db "Replace previous\r"
    db "saved data?"
    SCRIPT_YN_CUE
.signReplaceFlow:
    SCRIPT_FAR_CALL ShowYesNoMenu
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=ToamunaMenu
    db "Do not remove\r"
    db "Game Pak."
    SCRIPT_REPEAT_CHAR .Count=120
    SCRIPT_ANCHOR
    SCRIPT_FAR_CALL Toamuna_SaveGame
    db "Finished signing\r"
    db "the guest book!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=ToamunaPostActionBody

ToamunaConfirm:
    SCRIPT_RENDERER Toamuna_RenderPortrait
    db "Want to check\r"
    db "the guest book?"
    SCRIPT_WAIT
    db "... ... ... ...\r"
    db "Okay. It's ready"
    SCRIPT_WAIT
    db "Previous data\r"
    db "will be loaded."
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL ShowYesNoMenu
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=ToamunaMenu
    db "Do not remove\r"
    db "Game Pak."
    SCRIPT_REPEAT_CHAR .Count=120
    SCRIPT_ANCHOR
    SCRIPT_FAR_CALL Toamuna_LoadGame
    SCRIPT_IF_NEQ .Addr=wYNResult, .Value=$01, .Target=.confirmDoneFlow
    db "Done checking\r"
    db "the guest book!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=ToamunaPostActionBody
.confirmDoneFlow:
    db "Did not accept?\r"
    db "Try it again!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=ToamunaPostActionBody

ToamunaExit:
    SCRIPT_RENDERER Toamuna_RenderPortrait
    db "Okay.\r"
    db "Be careful."
    SCRIPT_WAIT
