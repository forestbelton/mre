INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "text.inc"
INCLUDE "sound_ids.inc"

SECTION "Bodka script functions", ROMX

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
	ld hl, BodkaScript
	call ScriptDispatcherEnterAfterCall
	jp LeaveTownBuilding

Bodka_BuildStudioScene:
	call Func_00_0822
	ld a, LCDC_ON | LCDC_WIN_9C00 | LCDC_OBJ_16 | LCDC_OBJ_ON | LCDC_PRIO_ON
	ld [rLCDC], a
	call HideAllSprites
	call Func_00_3965
	ld a, $01
	ld [rVBK], a
	ld a, BANK(BodkaPortraitTiles)
	ld hl, BodkaPortraitTiles
	ld de, $8000
	ld bc, BodkaPortraitTilesEnd - BodkaPortraitTiles
	call BankVramCopy
	call Bodka_LoadStudioBgMap
	call Bodka_RenderPortrait
	call HideUnusedOamSprites
	ld a, BANK(BodkaPortraitPaletteBg)
	ld hl, BodkaPortraitPaletteBg
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, BANK(BodkaPortraitPaletteObj)
	ld hl, BodkaPortraitPaletteObj
	ld de, wObjPalettes
	ld bc, $0030
	call BankCopy
	xor a
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	call WaitForNextFrame
	push af
	ld a, SOUND_BGM_Bodka
	call PlaySoundTracked
	pop af
	ret

Bodka_BuildTowerScene:
	FAR_CALL Func_1f_4d66
	ld a, $c7
	ld [rLCDC], a
	call HideAllSprites
	call Func_00_3965
	ld a, $01
	ld [rVBK], a
	ld a, BANK(BodkaPortraitTiles)
	ld hl, BodkaPortraitTiles
	ld de, $8000
	ld bc, BodkaPortraitTilesEnd - BodkaPortraitTiles
	call BankVramCopy
	call Bodka_LoadStudioBgMap
	ld hl, Data_1e_5bd9
	ld a, BANK(Data_1e_5bd9)
	ld de, $9845
	call BankMapCopyA
	call Bodka_RenderPortrait
	call HideUnusedOamSprites
	ld a, $1e
	ld hl, $5b59
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, BANK(Data_1e_5b99)
	ld hl, Data_1e_5b99
	ld de, wObjPalettes
	ld bc, $0030
	call BankCopy
	xor a
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	call WaitForNextFrame
	ret

Bodka_LoadStudioBgMap:
	ld hl, BodkaPortraitMapDesc
	ld a, BANK(BodkaPortraitMapDesc)
	ld de, TILEMAP0
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
	ld hl, Data_1e_5a3e
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
	ld a, BANK(Data_33_4000)
	ld hl, Data_33_4000
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	call Tradehouse_LoadBgMap
	call Tradehouse_AnimateNoteScene
	call HideUnusedOamSprites
	ld a, BANK(Data_33_7000)
	ld hl, Data_33_7000
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, BANK(Data_33_7040)
	ld hl, Data_33_7040
	ld de, wObjPalettes
	ld bc, $0030
	call BankCopy
	xor a
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	call WaitForNextFrame
	ret

Tradehouse_LoadBgMap:
	ld hl, Data_33_7080
	ld a, BANK(Data_33_7080)
	ld de, TILEMAP0
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
	ld a, BANK(Data_33_7000)
	ld hl, Data_33_7000
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, BANK(Data_33_7040)
	ld hl, Data_33_7040
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

SECTION "Bodka script", ROMX

; Top-level Bodka script entry ($608c), reached from Func_18_5dfa. Dispatch on
; the studio-mode flag: when [$d0e2]==1 Bodka is the post-game studio host
; (BodkaStudioGreet); otherwise fall through to the tradehouse scene. The
; leading IF_EQ was previously misfiled as Data_18_608c at the tail of the
; portrait-code section, so the script appeared to start at TradehouseEntry.
BodkaScript:
    SCRIPT_IF_EQ .Addr=$d0e2, .Value=$01, .Target=BodkaStudioGreet
TradehouseEntry:
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    SCRIPT_IF_EQ .Addr=wTradehouseState, .Value=$01, .Target=TradehouseReady
    SCRIPT_FAR_CALL Tradehouse_BuildScene
    db "Nobody seems\r"
    db "to be here."
    SCRIPT_WAIT
    db "Oh!\r"
    db "There's a note!"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL Tradehouse_BuildNoteScene
    db "Link function\r"
    db "seems usable."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wTradehouseState, .Value=$01
    SCRIPT_FAR_CALL Tradehouse_BuildSceneNoInit
    SCRIPT_GOTO .Target=TradehouseMenu

TradehouseReady:
    SCRIPT_FAR_CALL Tradehouse_BuildScene

TradehouseMenu:
    db "What would you\r"
    db "like to play?"
    SCRIPT_FAR_CALL Tradehouse_ShowMenu
    SCRIPT_FAR_CALL Tradehouse_LoadBgMap
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE wMainMenuResult, \
        TradehouseEnter, \
        TradehouseSave, \
        BodkaGreet

TradehouseEnter:
    db "OK. Let's enter\r"
    db "the room, then."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL OpenRoomSelectMenu
    SCRIPT_FAR_CALL Tradehouse_BuildScene
    SCRIPT_IF_EQ .Addr=wActiveFloor, .Value=$04, .Target=TradehouseEnterDone
    SCRIPT_IF_EQ .Addr=wActiveFloor, .Value=$05, .Target=TradehouseEnterDone
    SCRIPT_IF_EQ .Addr=wActiveFloor, .Value=$06, .Target=TradehouseEnterDone
    SCRIPT_FAR_CALL EnterSelectedRoom
    SCRIPT_FAR_CALL Tradehouse_BuildScene

TradehouseEnterDone:
    db "Done. OK, let's\r"
    db "leave the room."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=TradehouseMenu

TradehouseSave:
    db "Okay. Let me try\r"
    db "the exchange."
    SCRIPT_YN_CUE
    SCRIPT_WRITE_WRAM .Addr=$d5c2, .Value=$00
    SCRIPT_FAR_CALL LinkExchangeConnect
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE $d5c2, \
        TradehouseSaveConfirm, \
        TradehouseSaveNoFriend, \
        TradehouseSaveNotReady, \
        TradehouseSaveProcess

TradehouseSaveNoFriend:
    db "Your friend does\r"
    db "not seem ready."
    SCRIPT_WAIT
    db "Try when you're\r"
    db "both ready."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=TradehouseMenu

TradehouseSaveNotReady:
    db "You don't seem\r"
    db "ready yet."
    SCRIPT_WAIT
    db "Connect the\r"
    db "Link Cable!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=TradehouseMenu

TradehouseSaveProcess:
    db "Process\r"
    db "cancelled."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=TradehouseMenu

TradehouseSaveConfirm:
    db "But before that,\r"
    db "current status"
    SCRIPT_WAIT
    db "must be saved.\r"
    db "Okay?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL ShowYesNoMenu
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$00, .Target=TradehouseSaving
    db "Hmmm..."
    SCRIPT_WAIT
    db "Let's not do it\r"
    db "this time."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=TradehouseMenu

TradehouseSaving:
    db "Now saving.\r"
    db "Leave Game Pak."
    SCRIPT_WAIT
    SCRIPT_REPEAT_CHAR .Count=120
    SCRIPT_ANCHOR
    SCRIPT_FAR_CALL SaveGameToSram
    db "We're ready! Now\r"
    db "start exchange!"
    SCRIPT_WAIT
    db "Okay, then..."
    SCRIPT_WAIT
    db "Let's choose a\r"
    db "room to exchange"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=$cfbe, .Value=$02
    SCRIPT_FAR_CALL SetupExchangeRoomSelect
    SCRIPT_FAR_CALL LinkStoreSendRoom
    SCRIPT_FAR_CALL Tradehouse_BuildScene
    db "Next, choose a\r"
    db "room to receive."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=$cfbe, .Value=$01
    SCRIPT_FAR_CALL SetupExchangeRoomSelect
    SCRIPT_FAR_CALL LinkStoreRecvRoom
    SCRIPT_FAR_CALL Tradehouse_BuildScene
    db "You're both OK?\r"
    db "Let's start!"
    SCRIPT_WAIT
    db "Leave Link Cable\r"
    db "and Game Pak."
    SCRIPT_WAIT
    db "Your friend is\r"
    db "getting ready."
    SCRIPT_WAIT
    db "Let's wait for\r"
    db "a little while."
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL LinkExchangeTransfer
    SCRIPT_FAR_CALL Tradehouse_BuildScene
    SCRIPT_FAR_CALL LinkClampResultCode
    SCRIPT_JUMP_TABLE $d5c2, \
        TradehouseSaveOk, \
        TradehouseSaveErr, \
        TradehouseSaveProcess2, \
        TradehouseSaveProcess2

TradehouseSaveOk:
    db "Yes!\r"
    db "We did it!"
    SCRIPT_WAIT
    db "The exchange was\r"
    db "a success!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=TradehouseMenu

TradehouseSaveErr:
    db "Uh-oh. Something\r"
    db "went wrong."
    SCRIPT_WAIT
    db "Let's try again."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=TradehouseMenu

TradehouseSaveProcess2:
    db "Process\r"
    db "cancelled."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=TradehouseMenu

BodkaGreet:
    db "I should stop\r"
    db "for now."
    SCRIPT_WAIT
    SCRIPT_END

; Studio-host greeting ($6483) — target of the BodkaScript studio-flag branch.
BodkaStudioGreet:
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    SCRIPT_FAR_CALL Bodka_BuildStudioScene
    SCRIPT_CYCLE .Count=4
    SCRIPT_JUMP_TABLE wCycleCounter, \
        BodkaGreetA, \
        BodkaGreetB, \
        BodkaGreetC, \
        BodkaGreetD,

BodkaGreetA:
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "Hey!\r"
    db "How's it going?"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaGreetB:
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "Hey! Howdy?\r"
    db "Have some fun!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaGreetC:
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "Oh! You again!\r"
    db "Take your time!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaGreetD:
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "Wow!\r"
    db "Doing your best?"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaMenu:
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "What do you\r"
    db "want to do?"
    SCRIPT_FAR_CALL Bodka_ShowMenu
    SCRIPT_FAR_CALL Bodka_LoadStudioBgMap
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE wMainMenuResult, \
        BodkaLeave, \
        BodkaEnter, \
        BodkaItems, \
        BodkaSave, \
        BodkaExit,

BodkaLeave:
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "Leave it to me!\r"
    db "I got it ready."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL OpenRoomArrangeMenu
    SCRIPT_FAR_CALL Bodka_BuildStudioScene
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "Oh, you're done?\r"
    db "Great job!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaEnter:
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "Want to try a\r"
    db "room. Good luck!"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL OpenRoomSelectMenu
    SCRIPT_FAR_CALL Bodka_BuildStudioScene
    SCRIPT_IF_EQ .Addr=wActiveFloor, .Value=$04, .Target=BodkaEnterNo
    SCRIPT_IF_EQ .Addr=wActiveFloor, .Value=$05, .Target=BodkaEnterNo
    SCRIPT_IF_EQ .Addr=wActiveFloor, .Value=$06, .Target=BodkaEnterNo
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "Okay! Now enter\r"
    db "the room!"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL EnterSelectedRoom
    SCRIPT_FAR_CALL Bodka_BuildStudioScene

BodkaEnterNo:
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "Not today, huh?"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaItems:
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "Now,\r"
    db "let me explain."
    SCRIPT_FAR_CALL Bodka_ShowItemsSubMenu
    SCRIPT_FAR_CALL Bodka_LoadStudioBgMap
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE wSubMenuCursor, \
        BodkaItemDisc, \
        BodkaItemLink, \
        BodkaItemStop,
    SCRIPT_GOTO .Target=BodkaMenu

BodkaSave:
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "Well then,\r"
    db "let's exchange!"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL LinkExchangeConnect
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE $d5c2, \
        BodkaSaveConfirm, \
        BodkaSaveNoOpp, \
        BodkaSaveNotReady, \
        BodkaSaveProcess,

BodkaSaveNoOpp:
    SCRIPT_RENDERER Bodka_RenderPortrait
    db "Opponent not\r"
    db "ready yet."
    SCRIPT_WAIT
    db "Call again\r"
    db "when ready."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaSaveNotReady:
    SCRIPT_RENDERER Bodka_RenderPortrait
    db "You don't look\r"
    db "ready yet."
    SCRIPT_WAIT
    db "Connect the\r"
    db "Link Cable."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaSaveProcess:
    SCRIPT_RENDERER Bodka_RenderPortrait
    db "Process\r"
    db "cancelled."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaSaveConfirm:
    SCRIPT_RENDERER Bodka_RenderPortrait
    db "First, I'll save\r"
    db "current status."
    SCRIPT_WAIT
    db "Okay?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL ShowYesNoMenu
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$00, .Target=BodkaSaving
    SCRIPT_RENDERER Bodka_RenderPortrait
    db "I see. How\r"
    db "disappointing."
    SCRIPT_WAIT
    db "Tell me again,\r"
    db "if you like."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaSaving:
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "Okay. Looks like\r"
    db "you're ready."
    SCRIPT_WAIT
    db "Well.\r"
    db "Wait a second."
    SCRIPT_WAIT
    SCRIPT_RENDERER Bodka_RenderPortrait
    db "I'm saving now.\r"
    db "Leave Game Pak."
    SCRIPT_REPEAT_CHAR .Count=120
    SCRIPT_ANCHOR
    SCRIPT_FAR_CALL SaveGameToSram
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "Sorry you waited\r"
    db "Let's exchange."
    SCRIPT_WAIT
    SCRIPT_RENDERER Bodka_RenderPortrait
    db "Okay, now choose"
    SCRIPT_WAIT
    db "the room you\r"
    db "want to exchange"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=$cfbe, .Value=$02
    SCRIPT_FAR_CALL SetupExchangeRoomSelect
    SCRIPT_FAR_CALL LinkStoreSendRoom
    SCRIPT_FAR_CALL Bodka_BuildStudioScene
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "Now, choose a\r"
    db "room to receive."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=$cfbe, .Value=$01
    SCRIPT_FAR_CALL SetupExchangeRoomSelect
    SCRIPT_FAR_CALL LinkStoreRecvRoom
    SCRIPT_FAR_CALL Bodka_BuildStudioScene
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "Are you both OK?\r"
    db "Let's get going."
    SCRIPT_WAIT
    SCRIPT_RENDERER Bodka_RenderPortrait
    db "Leave Link Cable\r"
    db "and Game Pak."
    SCRIPT_WAIT
    db "Your friend is\r"
    db "getting ready."
    SCRIPT_WAIT
    db "Please wait\r"
    db "a second."
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL LinkExchangeTransfer
    SCRIPT_FAR_CALL Bodka_BuildStudioScene
    SCRIPT_FAR_CALL LinkClampResultCode
    SCRIPT_JUMP_TABLE $d5c2, \
        BodkaSaveOk, \
        BodkaSaveErr, \
        BodkaSaveProcess2, \
        BodkaSaveProcess2 \

BodkaSaveOk:
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "Whoa! Looks like\r"
    db "it was a success"
    SCRIPT_WAIT
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "Exchange done."
    SCRIPT_WAIT
    db "Call if you need\r"
    db "anything else."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaSaveErr:
    SCRIPT_RENDERER Bodka_RenderPortrait
    db "Hmmm. Looks\r"
    db "like we failed."
    SCRIPT_WAIT
    db "Can you try\r"
    db "it again?"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaSaveProcess2:
    SCRIPT_RENDERER Bodka_RenderPortrait
    db "Process\r"
    db "cancelled."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaMenu

BodkaExit:
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "Okay! Please\r"
    db "come again!"
    SCRIPT_WAIT
    SCRIPT_END

BodkaItemDisc:
    SCRIPT_RENDERER Bodka_RenderPortrait
    db "You can make 3\r"
    db "rooms. Choose a"
    SCRIPT_WAIT
    db "large or small\r"
    db "sized room."
    SCRIPT_WAIT
    db "Place monsters\r"
    db "and items where"
    SCRIPT_WAIT
    db "you wish. Don't\r"
    db "forget the door"
    SCRIPT_WAIT
    db "and key. You can\r"
    db "place 3 types"
    SCRIPT_WAIT
    db "and up to 9\r"
    db "monsters in all."
    SCRIPT_WAIT
    db "That's all.\r"
    db "Have fun!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaItems

BodkaItemLink:
    SCRIPT_RENDERER Bodka_RenderPortrait
    db "Link Exchange,\r"
    db "right?"
    SCRIPT_WAIT
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "This lets you\r"
    db "exchange"
    SCRIPT_WAIT
    db "rooms created\r"
    db "with your pals."
    SCRIPT_WAIT
    db "A cool feature\r"
    db "only found here."
    SCRIPT_WAIT
    db "Create fun or\r"
    db "difficult rooms"
    SCRIPT_WAIT
    db "and attack them\r"
    db "with your pals!"
    SCRIPT_WAIT
    db "That's fun."
    SCRIPT_WAIT
    db "Enjoy!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=BodkaItems

BodkaItemStop:
    SCRIPT_GOTO .Target=BodkaMenu
