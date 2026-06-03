; Verde (monster checkroom, ranch).
;
; Verde is one of the townspeople who returned from the tower
; (Toamuna's D0DC=3 greeting: "Verde returned. Great! Thank you").
; He introduces himself as "the owner of the checkroom" — monster
; boarding likely via the GBC link cable for trading.
;
; Two scripts in this file, dispatched independently by the engine
; depending on whether Verde is at the building:
;
;   VerdeEntry       $0614F5  D0E4 cascade; first-time intro is
;                             the long "I am Verde..." monologue
;                             referencing Naji as the referrer.
;   TradehouseEntry  $062092  D0E3 cascade; building is empty,
;                             player finds a note about the link
;                             function. The two ROM regions are
;                             ~2 KB apart but represent the same
;                             building's state.
;
; The tail of the empty-state script ($6251A onward, "What do you
; want to do?" menu) is shared infrastructure also reachable from
; the Verde-present script.
;
; See docs/text_engine.md for the bytecode reference.

INCLUDE "script.inc"

SECTION "verde_0614f5", ROMX[$54f5], BANK[$18]


VerdeEntry:
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    SCRIPT_IF_EQ .Addr=wVerdeState, .Value=$04, .Target=VerdeGreetCleared
    SCRIPT_IF_EQ .Addr=wVerdeState, .Value=$03, .Target=VerdeGreetSeen
    SCRIPT_IF_EQ .Addr=wVerdeState, .Value=$01, .Target=VerdeGreet
    SCRIPT_FAR_CALL .Addr=Verde_BuildIntroScene, .Bank=$18
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "Oh?"
    SCRIPT_NEWLINE
    db "Never seen you."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Verde_RenderPortraitSurprised, .Bank=$18
    db "What?"
    SCRIPT_NEWLINE
    db "Came to help?"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
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
    SCRIPT_RENDERER .Addr=Verde_RenderPortraitCalm, .Bank=$18
    db "I am the owner"
    SCRIPT_NEWLINE
    db "of the checkroom"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "I'm here just"
    SCRIPT_NEWLINE
    db "like the others"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Verde_RenderPortraitCalm, .Bank=$18
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
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
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
    SCRIPT_RENDERER .Addr=Verde_RenderPortraitCalm, .Bank=$18
    db "from here on."
    SCRIPT_NEWLINE
    db "But I'd be"
    SCRIPT_WAIT
    db "more trouble"
    SCRIPT_NEWLINE
    db "than help."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
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
    SCRIPT_WRITE_WRAM .Addr=$d0e1, .Value=$01
    SCRIPT_WRITE_WRAM .Addr=wRanchProgress, .Value=$03
    SCRIPT_WRITE_WRAM .Addr=wNajiState, .Value=$02
    SCRIPT_WRITE_WRAM .Addr=wPashuteState, .Value=$02
    SCRIPT_WRITE_WRAM .Addr=wVerdeState, .Value=$01
    SCRIPT_END

VerdeGreet:
    SCRIPT_FAR_CALL .Addr=Verde_BuildPortraitScene, .Bank=$18
    SCRIPT_CYCLE .Count=4
    SCRIPT_JUMP_TABLE wCycleCounter, VerdeGreetA, VerdeGreetB, VerdeGreetC, VerdeGreetD

VerdeGreetA:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "Oh, hi!"
    SCRIPT_NEWLINE
    db "How's it going?"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenu

VerdeGreetB:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "Hello!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenu

VerdeGreetC:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "Welcome!"
    SCRIPT_NEWLINE
    db "I'm glad"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenu

VerdeGreetD:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "Welcome!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenu

VerdeGreetSeen:
    SCRIPT_FAR_CALL .Addr=Verde_BuildPortraitScene, .Bank=$18
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
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
    SCRIPT_WRITE_WRAM .Addr=wVerdeState, .Value=$01
    SCRIPT_GOTO .Target=VerdeMenu

VerdeGreetCleared:
    SCRIPT_FAR_CALL .Addr=Verde_BuildPortraitScene, .Bank=$18
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
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
    SCRIPT_WRITE_WRAM .Addr=wVerdeState, .Value=$01
    SCRIPT_GOTO .Target=VerdeMenu

VerdeMenu:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "Let's see."
    SCRIPT_NEWLINE
    db "What can I"
    SCRIPT_WAIT
    db "do for you?"
    SCRIPT_FAR_CALL .Addr=Verde_ShowMainMenu, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=Verde_LoadBgMap, .Bank=$18
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE wMainMenuResult, VerdeRaise, VerdeRelease, VerdeSwitch, VerdeExplain, VerdeLeave

VerdeMenuLoop:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "Do you want"
    SCRIPT_NEWLINE
    db "something else?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL .Addr=ShowYesNoMenu, .Bank=$1f
    SCRIPT_JUMP_TABLE wYNResult, VerdeMenu, VerdeLeave

VerdeRaise:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "OK!"
    SCRIPT_NEWLINE
    db "I'll take care"
    SCRIPT_WAIT
    db "of it!"
    SCRIPT_WAIT
    SCRIPT_IF_EQ .Addr=$cfd9, .Value=$ff, .Target=VerdeRaiseFull
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "OK! It's "
    SCRIPT_INDEXED_STR .Addr=$cfd9
    db "."
    SCRIPT_NEWLINE
    db "I got it."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=$cfd9, .Value=$ff
    SCRIPT_GOTO .Target=VerdeMenuLoop

VerdeRaiseFull:
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
    SCRIPT_GOTO .Target=VerdeMenuLoop

VerdeRelease:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
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
    SCRIPT_FAR_CALL .Addr=CountCheckedInMonsters, .Bank=$18
    SCRIPT_IF_NEQ .Addr=wYNResult, .Value=$00, .Target=VerdeReleaseYes
    SCRIPT_RENDERER .Addr=Verde_RenderPortraitCalm, .Bank=$18
    db "Oh yes,"
    SCRIPT_NEWLINE
    db "I have it here."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenuLoop

VerdeReleaseYes:
    SCRIPT_IF_NEQ .Addr=wYNResult, .Value=$01, .Target=VerdeReleasePick
    db "Yes! It's "
    SCRIPT_INDEXED_STR .Addr=$cfbb
    db "."
    SCRIPT_NEWLINE
    db "I have it here."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeReleaseThis

VerdeReleasePick:
    db "Oh yes,"
    SCRIPT_NEWLINE
    db "I have it here."
    SCRIPT_WAIT
    db "So, which one"
    SCRIPT_NEWLINE
    db "are you taking?"
    SCRIPT_FAR_CALL .Addr=Verde_ShowReleaseMonsterSelect, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=Verde_LoadBgMap, .Bank=$18
    SCRIPT_ANCHOR
    SCRIPT_IF_EQ .Addr=$cfbb, .Value=$07, .Target=VerdeMenuLoop

VerdeReleaseThis:
    db "This one, right?"
    SCRIPT_NEWLINE
    db "It's healthy!"
    SCRIPT_WAIT
    db "Take good care"
    SCRIPT_NEWLINE
    db "of it, okay?"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL .Addr=Pashute_SetReplaceTargetActive, .Bank=$18
    SCRIPT_GOTO .Target=VerdeMenuLoop

VerdeSwitch:
    SCRIPT_FAR_CALL .Addr=CountCheckedInMonsters, .Bank=$18
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=VerdeSwitchDone
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
    db "OK! Switch of"
    SCRIPT_NEWLINE
    db "monsters, right?"
    SCRIPT_WAIT
    db "Okay, choose the"
    SCRIPT_NEWLINE
    db "next monster"
    SCRIPT_FAR_CALL .Addr=Verde_ShowReleaseMonsterSelect, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=Verde_LoadBgMap, .Bank=$18
    SCRIPT_ANCHOR
    SCRIPT_IF_EQ .Addr=$cfbb, .Value=$07, .Target=VerdeMenuLoop
    SCRIPT_GOTO .Target=VerdeReleaseThis

VerdeSwitchDone:
    SCRIPT_RENDERER .Addr=Verde_RenderPortraitCalm, .Bank=$18
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
    SCRIPT_GOTO .Target=VerdeMenuLoop

VerdeExplain:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
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
    SCRIPT_GOTO .Target=VerdeMenuLoop

VerdeLeave:
    SCRIPT_RENDERER .Addr=Verde_RenderPortrait, .Bank=$18
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

SECTION "verde_062092_empty", ROMX[$6092], BANK[$18]


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
