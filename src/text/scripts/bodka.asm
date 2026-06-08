INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "text.inc"

SECTION "analyzed_061de3", ROMX[$5de3], BANK[$18]

LinkClampResultCode:
	ld a, [$d5c2]
	cp $04
	ret c
	ld a, $03
	ret
LinkStoreSendRoom:
	ld a, [wActiveFloor]
	ld [$d5f9], a
	ret
LinkStoreRecvRoom:
	ld a, [wActiveFloor]
	ld [$d5fa], a
	ret

Func_18_5dfa:
	ld hl, $608c
	call ScriptDispatcherEnterAfterCall
	jp LeaveTownBuilding
Bodka_BuildStudioScene:
	call Func_00_0822
	ld a, $c7
	ld [rLCDC], a
	call HideAllSprites
	call Func_00_3965
	ld a, $01
	ld [rVBK], a
	ld a, $1e
	ld hl, $4000
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	call Bodka_LoadStudioBgMap
	call Bodka_RenderPortrait
	call HideUnusedOamSprites
	ld a, $1e
	ld hl, $5800
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, $1e
	ld hl, $5840
	ld de, wObjPalettes
	ld bc, $0030
	call BankCopy
	xor a
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	call WaitForNextFrame
	push af
	ld a, $30
	call PlaySoundTracked
	pop af
	ret
Bodka_BuildTowerScene:
	FAR_CALL $1f, Func_1f_4d66
	ld a, $c7
	ld [rLCDC], a
	call HideAllSprites
	call Func_00_3965
	ld a, $01
	ld [rVBK], a
	ld a, $1e
	ld hl, $4000
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	call Bodka_LoadStudioBgMap
	ld hl, $5bd9
	ld a, $1e
	ld de, $9845
	call BankMapCopyA
	call Bodka_RenderPortrait
	call HideUnusedOamSprites
	ld a, $1e
	ld hl, $5b59
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, $1e
	ld hl, $5b99
	ld de, wObjPalettes
	ld bc, $0030
	call BankCopy
	xor a
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	call WaitForNextFrame
	ret
Bodka_LoadStudioBgMap:
	ld hl, $5880
	ld a, $1e
	ld de, $9800
	call BankMapCopyA
	ret
Bodka_RenderPortrait:
	ld a, $c8
	ld [wRendererAddr], a
	ld a, $5e
	ld [$d61f], a
	ld a, $18
	ld [wRendererBank], a
	ld a, $1e
	ld [wDrawBank], a
	ld hl, $5add
	ld bc, $482b
	call DrawMetasprite
	ld hl, $d610
	ld a, [hl]
	inc a
	and $ff
	ld [hl], a
	srl a
	srl a
	cp $01
	jr z, .frame1
	cp $02
	jr z, .frame2
	cp $03
	jr z, .frame1
	ld hl, $5a3e
	ld a, $1e
	ld de, $98a6
	call BankMapCopyA
	ld hl, $5a4a
	ld bc, $2833
	call DrawMetasprite
	ret
.frame1:
	ld hl, $5a73
	ld a, $1e
	ld de, $98a6
	call BankMapCopyA
	ld hl, $5a7f
	ld bc, $2833
	call DrawMetasprite
	ret
.frame2:
	ld hl, $5aa8
	ld a, $1e
	ld de, $98a6
	call BankMapCopyA
	ld hl, $5ab4
	ld bc, $2833
	call DrawMetasprite
	ret
Bodka_RenderPortraitAlt:
	ld a, $3c
	ld [wRendererAddr], a
	ld a, $5f
	ld [$d61f], a
	ld a, $18
	ld [wRendererBank], a
	ld a, $1e
	ld [wDrawBank], a
	ld hl, $5add
	ld bc, $482b
	call DrawMetasprite
	ld hl, $5b1e
	ld a, $1e
	ld de, $98a6
	call BankMapCopyA
	ld hl, $5b30
	ld bc, $2833
	call DrawMetasprite
	ret
Tradehouse_BuildScene:
	call Func_00_0822
Tradehouse_BuildSceneNoInit:
	ld a, $c7
	ld [rLCDC], a
	call HideAllSprites
	call Func_00_3965
	ld a, $01
	ld [rVBK], a
	ld a, $33
	ld hl, $4000
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	call Tradehouse_LoadBgMap
	call Tradehouse_AnimateNoteScene
	call HideUnusedOamSprites
	ld a, $33
	ld hl, $7000
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, $33
	ld hl, $7040
	ld de, wObjPalettes
	ld bc, $0030
	call BankCopy
	xor a
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	call WaitForNextFrame
	ret
Tradehouse_LoadBgMap:
	ld hl, $7080
	ld a, $33
	ld de, $9800
	call BankMapCopyA
	ret
Tradehouse_BuildNoteScene:
	ld a, $c7
	ld [rLCDC], a
	call HideAllSprites
	call Func_00_3965
	ld a, $01
	ld [rVBK], a
	ld a, $33
	ld hl, $5800
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	call Tradehouse_LoadNoteBgMap
	ld a, $33
	ld hl, $7000
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, $33
	ld hl, $7040
	ld de, wObjPalettes
	ld bc, $0030
	call BankCopy
	xor a
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	call WaitForNextFrame
	ret
Tradehouse_LoadNoteBgMap:
	ld hl, $723e
	ld a, $33
	ld de, $9800
	call BankMapCopyA
	ret
Tradehouse_AnimateNoteScene:
	ld a, $1f
	ld [wRendererAddr], a
	ld a, $60
	ld [$d61f], a
	ld a, $18
	ld [wRendererBank], a
	ld a, $33
	ld [wDrawBank], a
	ld hl, $d610
	ld a, [hl]
	inc a
	cp $1c
	jr c, .selectFrame
	xor a
.selectFrame:
	ld [hl], a
	srl a
	srl a
	cp $01
	jr z, .frame1
	cp $02
	jr z, .frame2
	cp $03
	jr z, .frame3
	cp $04
	jr z, .frame4
	cp $05
	jr z, .frame2
	cp $06
	jr z, .frame1
	ld hl, $73fc
	ld bc, $1e98
	call DrawMetasprite
	ret
.frame1:
	ld hl, $7405
	ld bc, $1e98
	call DrawMetasprite
	ret
.frame2:
	ld hl, $740e
	ld bc, $1e98
	call DrawMetasprite
	ret
.frame3:
	ld hl, $7417
	ld bc, $1e98
	call DrawMetasprite
	ret
.frame4:
	ld hl, $7420
	ld bc, $1e98
	call DrawMetasprite
	ret

Data_18_608c:
	db $0a, $e2, $d0, $01, $83, $64

SECTION "Bodka script", ROMX

TradehouseEntry:
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    SCRIPT_IF_EQ .Addr=wTradehouseState, .Value=$01, .Target=TradehouseReady
    SCRIPT_FAR_CALL .Addr=Tradehouse_BuildScene, .Bank=$18
    db "Nobody seems"
    SCRIPT_NEWLINE
    db "to be here."
    SCRIPT_WAIT
    db "Oh!"
    SCRIPT_NEWLINE
    db "There's a note!"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=Tradehouse_BuildNoteScene, .Bank=$18
    db "Link function"
    SCRIPT_NEWLINE
    db "seems usable."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wTradehouseState, .Value=$01
    SCRIPT_FAR_CALL .Addr=Tradehouse_BuildSceneNoInit, .Bank=$18
    SCRIPT_GOTO .Target=TradehouseMenu

TradehouseReady:
    SCRIPT_FAR_CALL .Addr=Tradehouse_BuildScene, .Bank=$18

TradehouseMenu:
    db "What would you"
    SCRIPT_NEWLINE
    db "like to play?"
    SCRIPT_FAR_CALL .Addr=Tradehouse_ShowMenu, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=Tradehouse_LoadBgMap, .Bank=$18
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE wMainMenuResult, TradehouseEnter, TradehouseSave, BodkaGreet

TradehouseEnter:
    db "OK. Let's enter"
    SCRIPT_NEWLINE
    db "the room, then."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=OpenRoomSelectMenu, .Bank=$00
    SCRIPT_FAR_CALL .Addr=Tradehouse_BuildScene, .Bank=$18
    SCRIPT_IF_EQ .Addr=wActiveFloor, .Value=$04, .Target=TradehouseEnterDone
    SCRIPT_IF_EQ .Addr=wActiveFloor, .Value=$05, .Target=TradehouseEnterDone
    SCRIPT_IF_EQ .Addr=wActiveFloor, .Value=$06, .Target=TradehouseEnterDone
    SCRIPT_FAR_CALL .Addr=EnterSelectedRoom, .Bank=$00
    SCRIPT_FAR_CALL .Addr=Tradehouse_BuildScene, .Bank=$18

TradehouseEnterDone:
    db "Done. OK, let's"
    SCRIPT_NEWLINE
    db "leave the room."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=TradehouseMenu

TradehouseSave:
    db "Okay. Let me try"
    SCRIPT_NEWLINE
    db "the exchange."
    SCRIPT_YN_CUE
    SCRIPT_WRITE_WRAM .Addr=$d5c2, .Value=$00
    SCRIPT_FAR_CALL .Addr=LinkExchangeConnect, .Bank=$31
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE $d5c2, TradehouseSaveConfirm, TradehouseSaveNoFriend, TradehouseSaveNotReady, TradehouseSaveProcess

TradehouseSaveNoFriend:
    db "Your friend does"
    SCRIPT_NEWLINE
    db "not seem ready."
    SCRIPT_WAIT
    db "Try when you're"
    SCRIPT_NEWLINE
    db "both ready."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=TradehouseMenu

TradehouseSaveNotReady:
    db "You don't seem"
    SCRIPT_NEWLINE
    db "ready yet."
    SCRIPT_WAIT
    db "Connect the"
    SCRIPT_NEWLINE
    db "Link Cable!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=TradehouseMenu

TradehouseSaveProcess:
    db "Process"
    SCRIPT_NEWLINE
    db "cancelled."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=TradehouseMenu

TradehouseSaveConfirm:
    db "But before that,"
    SCRIPT_NEWLINE
    db "current status"
    SCRIPT_WAIT
    db "must be saved."
    SCRIPT_NEWLINE
    db "Okay?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL .Addr=ShowYesNoMenu, .Bank=$1f
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$00, .Target=TradehouseSaving
    db "Hmmm..."
    SCRIPT_WAIT
    db "Let's not do it"
    SCRIPT_NEWLINE
    db "this time."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=TradehouseMenu

TradehouseSaving:
    db "Now saving."
    SCRIPT_NEWLINE
    db "Leave Game Pak."
    SCRIPT_WAIT
    SCRIPT_REPEAT_CHAR .Count=120
    SCRIPT_ANCHOR
    SCRIPT_FAR_CALL .Addr=SaveGameToSram, .Bank=$12
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
    SCRIPT_WRITE_WRAM .Addr=$cfbe, .Value=$02
    SCRIPT_FAR_CALL .Addr=SetupExchangeRoomSelect, .Bank=$00
    SCRIPT_FAR_CALL .Addr=LinkStoreSendRoom, .Bank=$18
    SCRIPT_FAR_CALL .Addr=Tradehouse_BuildScene, .Bank=$18
    db "Next, choose a"
    SCRIPT_NEWLINE
    db "room to receive."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=$cfbe, .Value=$01
    SCRIPT_FAR_CALL .Addr=SetupExchangeRoomSelect, .Bank=$00
    SCRIPT_FAR_CALL .Addr=LinkStoreRecvRoom, .Bank=$18
    SCRIPT_FAR_CALL .Addr=Tradehouse_BuildScene, .Bank=$18
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
    SCRIPT_FAR_CALL .Addr=LinkExchangeTransfer, .Bank=$31
    SCRIPT_FAR_CALL .Addr=Tradehouse_BuildScene, .Bank=$18
    SCRIPT_FAR_CALL .Addr=LinkClampResultCode, .Bank=$18
    SCRIPT_JUMP_TABLE $d5c2, TradehouseSaveOk, TradehouseSaveErr, TradehouseSaveProcess2, TradehouseSaveProcess2

TradehouseSaveOk:
    db "Yes!"
    SCRIPT_NEWLINE
    db "We did it!"
    SCRIPT_WAIT
    db "The exchange was"
    SCRIPT_NEWLINE
    db "a success!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=TradehouseMenu

TradehouseSaveErr:
    db "Uh-oh. Something"
    SCRIPT_NEWLINE
    db "went wrong."
    SCRIPT_WAIT
    db "Let's try again."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=TradehouseMenu

TradehouseSaveProcess2:
    db "Process"
    SCRIPT_NEWLINE
    db "cancelled."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=TradehouseMenu

BodkaGreet:
    db "I should stop"
    SCRIPT_NEWLINE
    db "for now."
    SCRIPT_WAIT
    SCRIPT_END
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    SCRIPT_FAR_CALL .Addr=Bodka_BuildStudioScene, .Bank=$18
    SCRIPT_CYCLE .Count=4
    SCRIPT_JUMP_TABLE wCycleCounter, BodkaGreetA, BodkaGreetB, BodkaGreetC, BodkaGreetD

BodkaGreetA:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
    db "Hey!"
    SCRIPT_NEWLINE
    db "How's it going?"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaGreetB:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
    db "Hey! Howdy?"
    SCRIPT_NEWLINE
    db "Have some fun!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaGreetC:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
    db "Oh! You again!"
    SCRIPT_NEWLINE
    db "Take your time!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaGreetD:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
    db "Wow!"
    SCRIPT_NEWLINE
    db "Doing your best?"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaMenu:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
    db "What do you"
    SCRIPT_NEWLINE
    db "want to do?"
    SCRIPT_FAR_CALL .Addr=Bodka_ShowMenu, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=Bodka_LoadStudioBgMap, .Bank=$18
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE wMainMenuResult, BodkaLeave, BodkaEnter, BodkaItems, BodkaSave, BodkaExit

BodkaLeave:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
    db "Leave it to me!"
    SCRIPT_NEWLINE
    db "I got it ready."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=OpenRoomArrangeMenu, .Bank=$00
    SCRIPT_FAR_CALL .Addr=Bodka_BuildStudioScene, .Bank=$18
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
    db "Oh, you're done?"
    SCRIPT_NEWLINE
    db "Great job!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaEnter:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
    db "Want to try a"
    SCRIPT_NEWLINE
    db "room. Good luck!"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=OpenRoomSelectMenu, .Bank=$00
    SCRIPT_FAR_CALL .Addr=Bodka_BuildStudioScene, .Bank=$18
    SCRIPT_IF_EQ .Addr=wActiveFloor, .Value=$04, .Target=BodkaEnterNo
    SCRIPT_IF_EQ .Addr=wActiveFloor, .Value=$05, .Target=BodkaEnterNo
    SCRIPT_IF_EQ .Addr=wActiveFloor, .Value=$06, .Target=BodkaEnterNo
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
    db "Okay! Now enter"
    SCRIPT_NEWLINE
    db "the room!"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=EnterSelectedRoom, .Bank=$00
    SCRIPT_FAR_CALL .Addr=Bodka_BuildStudioScene, .Bank=$18

BodkaEnterNo:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
    db "Not today, huh?"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaItems:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
    db "Now,"
    SCRIPT_NEWLINE
    db "let me explain."
    SCRIPT_FAR_CALL .Addr=Bodka_ShowItemsSubMenu, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=Bodka_LoadStudioBgMap, .Bank=$18
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE wSubMenuCursor, BodkaItemDisc, BodkaItemLink, BodkaItemStop
    SCRIPT_GOTO .Target=BodkaMenu

BodkaSave:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
    db "Well then,"
    SCRIPT_NEWLINE
    db "let's exchange!"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL .Addr=LinkExchangeConnect, .Bank=$31
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE $d5c2, BodkaSaveConfirm, BodkaSaveNoOpp, BodkaSaveNotReady, BodkaSaveProcess

BodkaSaveNoOpp:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortrait, .Bank=$18
    db "Opponent not"
    SCRIPT_NEWLINE
    db "ready yet."
    SCRIPT_WAIT
    db "Call again"
    SCRIPT_NEWLINE
    db "when ready."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaSaveNotReady:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortrait, .Bank=$18
    db "You don't look"
    SCRIPT_NEWLINE
    db "ready yet."
    SCRIPT_WAIT
    db "Connect the"
    SCRIPT_NEWLINE
    db "Link Cable."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaSaveProcess:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortrait, .Bank=$18
    db "Process"
    SCRIPT_NEWLINE
    db "cancelled."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaSaveConfirm:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortrait, .Bank=$18
    db "First, I'll save"
    SCRIPT_NEWLINE
    db "current status."
    SCRIPT_WAIT
    db "Okay?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL .Addr=ShowYesNoMenu, .Bank=$1f
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$00, .Target=BodkaSaving
    SCRIPT_RENDERER .Addr=Bodka_RenderPortrait, .Bank=$18
    db "I see. How"
    SCRIPT_NEWLINE
    db "disappointing."
    SCRIPT_WAIT
    db "Tell me again,"
    SCRIPT_NEWLINE
    db "if you like."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaSaving:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
    db "Okay. Looks like"
    SCRIPT_NEWLINE
    db "you're ready."
    SCRIPT_WAIT
    db "Well."
    SCRIPT_NEWLINE
    db "Wait a second."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Bodka_RenderPortrait, .Bank=$18
    db "I'm saving now."
    SCRIPT_NEWLINE
    db "Leave Game Pak."
    SCRIPT_REPEAT_CHAR .Count=120
    SCRIPT_ANCHOR
    SCRIPT_FAR_CALL .Addr=SaveGameToSram, .Bank=$12
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
    db "Sorry you waited"
    SCRIPT_NEWLINE
    db "Let's exchange."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Bodka_RenderPortrait, .Bank=$18
    db "Okay, now choose"
    SCRIPT_WAIT
    db "the room you"
    SCRIPT_NEWLINE
    db "want to exchange"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=$cfbe, .Value=$02
    SCRIPT_FAR_CALL .Addr=SetupExchangeRoomSelect, .Bank=$00
    SCRIPT_FAR_CALL .Addr=LinkStoreSendRoom, .Bank=$18
    SCRIPT_FAR_CALL .Addr=Bodka_BuildStudioScene, .Bank=$18
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
    db "Now, choose a"
    SCRIPT_NEWLINE
    db "room to receive."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=$cfbe, .Value=$01
    SCRIPT_FAR_CALL .Addr=SetupExchangeRoomSelect, .Bank=$00
    SCRIPT_FAR_CALL .Addr=LinkStoreRecvRoom, .Bank=$18
    SCRIPT_FAR_CALL .Addr=Bodka_BuildStudioScene, .Bank=$18
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
    db "Are you both OK?"
    SCRIPT_NEWLINE
    db "Let's get going."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Bodka_RenderPortrait, .Bank=$18
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
    SCRIPT_FAR_CALL .Addr=LinkExchangeTransfer, .Bank=$31
    SCRIPT_FAR_CALL .Addr=Bodka_BuildStudioScene, .Bank=$18
    SCRIPT_FAR_CALL .Addr=LinkClampResultCode, .Bank=$18
    SCRIPT_JUMP_TABLE $d5c2, BodkaSaveOk, BodkaSaveErr, BodkaSaveProcess2, BodkaSaveProcess2

BodkaSaveOk:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
    db "Whoa! Looks like"
    SCRIPT_NEWLINE
    db "it was a success"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
    db "Exchange done."
    SCRIPT_WAIT
    db "Call if you need"
    SCRIPT_NEWLINE
    db "anything else."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaSaveErr:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortrait, .Bank=$18
    db "Hmmm. Looks"
    SCRIPT_NEWLINE
    db "like we failed."
    SCRIPT_WAIT
    db "Can you try"
    SCRIPT_NEWLINE
    db "it again?"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaSaveProcess2:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortrait, .Bank=$18
    db "Process"
    SCRIPT_NEWLINE
    db "cancelled."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaExit:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
    db "Okay! Please"
    SCRIPT_NEWLINE
    db "come again!"
    SCRIPT_WAIT
    SCRIPT_END

BodkaItemDisc:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortrait, .Bank=$18
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
    SCRIPT_GOTO .Target=BodkaItems

BodkaItemLink:
    SCRIPT_RENDERER .Addr=Bodka_RenderPortrait, .Bank=$18
    db "Link Exchange,"
    SCRIPT_NEWLINE
    db "right?"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Bodka_RenderPortraitAlt, .Bank=$18
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
    SCRIPT_GOTO .Target=BodkaItems

BodkaItemStop:
    SCRIPT_GOTO .Target=BodkaMenu
