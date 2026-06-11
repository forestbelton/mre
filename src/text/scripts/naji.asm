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

INCLUDE "hardware.inc"
INCLUDE "util.inc"

INCLUDE "text.inc"
INCLUDE "sound_ids.inc"

SECTION "Naji script", ROMX

NajiScript:
    ; Dialog box at BG tilemap $9982, 16 tiles wide × 4 tiles tall.
    ; Every NPC script starts with this $01 textbox-setup opcode.
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04

    ; Branch on Naji's NPC state. $D0DD progresses 0 -> 1 (after first
    ; intro) -> 2 (mid-quest "made it half-way" message available once)
    ; -> 4 (end-game). $C2D7 is a separate story flag. The fall-through
    ; is the long first-visit intro below.
    SCRIPT_IF_EQ .Addr=wNajiState, .Value=$04, .Target=NajiCycler
    SCRIPT_IF_EQ .Addr=wC2D7, .Value=$01, .Target=NajiCycler
    SCRIPT_IF_EQ .Addr=wNajiState, .Value=$02, .Target=NajiProgress
    SCRIPT_IF_EQ .Addr=wNajiState, .Value=$01, .Target=NajiCycler
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitTalking, .Bank=$18
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
    SCRIPT_WRITE_WRAM .Addr=wNajiState, .Value=$01
    SCRIPT_GOTO .Target=NajiMenu

NajiCycler:
    SCRIPT_CYCLE .Count=4
    SCRIPT_JUMP_TABLE wCycleCounter, .greet0, .greet1, .greet2, .greet3

.greet0:
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitAlt, .Bank=$18
    db "Oh, you're here."
    SCRIPT_NEWLINE
    db "Good luck."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=NajiMenu

.greet1:
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitTalking, .Bank=$18
    db "It's you. Good"
    SCRIPT_NEWLINE
    db "luck, my friend."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=NajiMenu

.greet2:
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitAlt, .Bank=$18
    db "It's you. We're"
    SCRIPT_NEWLINE
    db "counting on you."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=NajiMenu

.greet3:
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitTalking, .Bank=$18
    db "Hey. It's you!"
    SCRIPT_NEWLINE
    db "Take it easy!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=NajiMenu

NajiProgress:
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitAlt, .Bank=$18
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
    SCRIPT_WRITE_WRAM .Addr=wNajiState, .Value=$01
    SCRIPT_GOTO .Target=NajiMenu

NajiMenu:
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitTalking, .Bank=$18
    db "What are your"
    SCRIPT_NEWLINE
    db "plans this time?"
    SCRIPT_IF_EQ .Addr=wNajiMenuShown, .Value=$01, .Target=.checkAsk
    SCRIPT_IF_NEQ .Addr=wCFF0, .Value=$00, .Target=.renderClimb
    SCRIPT_FAR_CALL Naji_ShowMenu2
    SCRIPT_GOTO .Target=.menuFinalize
.renderClimb:
    SCRIPT_FAR_CALL Naji_ShowMenu3a
    SCRIPT_GOTO .Target=.menuFinalize
.checkAsk:
    SCRIPT_IF_NEQ .Addr=wCFF0, .Value=$00, .Target=.renderLeave
    SCRIPT_FAR_CALL Naji_ShowMenu3b
    SCRIPT_GOTO .Target=.menuFinalize
.renderLeave:
    SCRIPT_FAR_CALL Naji_ShowMenu4
.menuFinalize:
    SCRIPT_FAR_CALL Naji_LoadPortraitTilemap
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE wMainMenuResult, NajiRestart, NajiClimb, NajiTowerLong, NajiAskMenu, NajiLeave

NajiRestart:
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitTalking, .Bank=$18
    db "You've climbed"
    SCRIPT_NEWLINE
    db "till Level "
    SCRIPT_DECIMAL .Addr=wCurrentFloor
    SCRIPT_WAIT
    db "Want to"
    SCRIPT_NEWLINE
    db "start there?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL ShowYesNoMenu
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=NajiMenu
    SCRIPT_FAR_CALL Script_FadeOutPortrait
    SCRIPT_FAR_CALL Naji_ResumeTowerClimb
    SCRIPT_END

NajiClimb:
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitTalking, .Bank=$18
    db "I understand."
    SCRIPT_NEWLINE
    db "I'll open the"
    SCRIPT_WAIT
    db "door. But,"
    SCRIPT_NEWLINE
    db "are you ready?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL ShowYesNoMenu
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=NajiMenu
    SCRIPT_FAR_CALL Script_FadeOutPortrait
    SCRIPT_FAR_CALL Naji_StartTowerClimb
    SCRIPT_END

NajiAskMenu:
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitTalking, .Bank=$18
    db "What do you"
    SCRIPT_NEWLINE
    db "want to know?"
    SCRIPT_FAR_CALL Naji_ShowSubMenu2
    SCRIPT_FAR_CALL Naji_LoadPortraitTilemap
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE wSubMenuCursor, NajiAskTower, NajiAskItem, NajiAskStop

NajiLeave:
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitTalking, .Bank=$18
    db "See you later."
    SCRIPT_WAIT
    SCRIPT_END

NajiTowerLong:
    SCRIPT_IF_EQ .Addr=wTowerExplained, .Value=$01, .Target=NajiTowerShort
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitTalking, .Bank=$18
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
    SCRIPT_WRITE_WRAM .Addr=wTowerExplained, .Value=$01
    SCRIPT_FAR_CALL Script_FadeOutPortrait
    SCRIPT_FAR_CALL Naji_StartTowerFromBottom
    SCRIPT_END

NajiTowerShort:
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitTalking, .Bank=$18
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
    SCRIPT_FAR_CALL ShowYesNoMenu
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=NajiMenu
    SCRIPT_FAR_CALL Script_FadeOutPortrait
    SCRIPT_FAR_CALL Naji_StartTowerFromBottom
    SCRIPT_END

NajiAskTower:
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitTalking, .Bank=$18
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
    SCRIPT_GOTO .Target=NajiAskMenu

NajiAskItem:
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitTalking, .Bank=$18
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
    SCRIPT_GOTO .Target=NajiAskMenu

NajiAskStop:
    SCRIPT_GOTO .Target=NajiMenu

SECTION "Naji script functions", ROMX

Func_18_6b65:
	ld a, $04
	ld [wNajiState], a
	ld [wPashuteState], a
	ld [wVerdeState], a
	ret

Func_18_6b71:
	call Naji_BuildPortraitScene
	ld hl, NajiEncounterScript
	call ScriptDispatcherEnterAfterCall
	FAR_CALL $1f, Script_FadeOutPortrait
	ret

	call Naji_BuildPortraitScene
	ld hl, NajiScript
	call ScriptDispatcherEnterAfterCall
	ld a, [wMainMenuResult]
	cp $04
	jp z, LeaveTownBuilding
	ret

Naji_StartTowerClimb:
	FAR_CALL $05, Func_05_4785
	FAR_CALL $00, Func_00_34e3
	ret
Naji_ResumeTowerClimb:
	FAR_CALL $05, Func_05_479d
	FAR_CALL $00, Func_00_34e3
	ret
Naji_StartTowerFromBottom:
	FAR_CALL $05, Func_05_47b2
	FAR_CALL $00, Func_00_34e3
	ret

Naji_BuildPortraitScene:
	call Func_00_0822
	call HideAllSprites
	call Func_00_3965
	ld a, $01
	ld [rVBK], a
	ld a, $1a
	ld hl, $5ae8
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	call Naji_LoadPortraitTilemap
	call Naji_RenderPortraitTalking
	call HideUnusedOamSprites
	ld a, $1a
	ld hl, $72e8
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, $1a
	ld hl, $7328
	ld de, wObjPalettes
	ld bc, $0030
	call BankCopy
	xor a
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	call WaitForNextFrame
	push af
	ld a, SOUND_BGM_Town
	call PlaySoundIfChanged
	pop af
	ret
Naji_LoadPortraitTilemap:
	ld hl, $7368
	ld a, $1a
	ld de, $9800
	call BankMapCopyA
	ret
Naji_RenderPortraitTalking:
	ld a, $27
	ld [wRendererAddr], a
	ld a, $6c
	ld [$d61f], a
	ld a, $18
	ld [wRendererBank], a
	ld a, $1a
	ld [wDrawBank], a
	ld hl, $75d3
	ld a, $1a
	ld de, $9886
	call BankMapCopyA
	ld hl, $7590
	ld bc, $3e3c
	call DrawMetasprite
	ld hl, $75a1
	ld bc, $4828
	call DrawMetasprite
	ld hl, $75ba
	ld bc, $484c
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
	jr z, .frame1
	ld hl, $7526
	ld a, $1a
	ld de, $9886
	call BankMapCopyA
	ld hl, $7532
	ld bc, $1e34
	call DrawMetasprite
	ret
.frame1:
	ld hl, $755b
	ld a, $1a
	ld de, $9886
	call BankMapCopyA
	ld hl, $7567
	ld bc, $1e34
	call DrawMetasprite
	ret
Naji_RenderPortraitAlt:
	ld a, $9f
	ld [wRendererAddr], a
	ld a, $6c
	ld [$d61f], a
	ld a, $18
	ld [wRendererBank], a
	ld a, $1a
	ld [wDrawBank], a
	ld hl, $75eb
	ld a, $1a
	ld de, $9886
	call BankMapCopyA
	ld hl, $7603
	ld bc, $1e34
	call DrawMetasprite
	ld hl, $7590
	ld bc, $3e3c
	call DrawMetasprite
	ld hl, $75a1
	ld bc, $4828
	call DrawMetasprite
	ld hl, $75ba
	ld bc, $484c
	call DrawMetasprite
	ret

; --- Naji's encounter dialogue (entered at $6ce3 via Func_18_6b71) ---
; State-dependent greeting tree, dispatched on the tower-run flags $c2c1 /
; $c2d7 and the one-time-message flags $d0e5 / $d0e6 (set with WRITE_WRAM
; after first showing); $cff2 holds the level number printed by SCRIPT_DECIMAL.
; Previously misfiled as raw-hex Data_18_* blocks (and the $6fa5/$7080 stretch
; was further misdisassembled as code); decoded here to SCRIPT_* macros.
NajiEncounterScript:
    SCRIPT_IF_EQ .Addr=$c2c1, .Value=$01, .Target=.clearedRun
    SCRIPT_IF_EQ .Addr=$c2d7, .Value=$00, .Target=.thrownOutTried
    SCRIPT_IF_EQ .Addr=$c2d7, .Value=$01, .Target=.firstClearThanks
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitAlt, .Bank=$18
    db "You got out safe."
    SCRIPT_NEWLINE
    db "Good to see you."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitTalking, .Bank=$18
    db "I'll make sure"
    SCRIPT_NEWLINE
    db "you will start"
    SCRIPT_WAIT
    db "Level "
    SCRIPT_DECIMAL .Addr=$cff2
    SCRIPT_NEWLINE
    db "next time."
    SCRIPT_WAIT
    db "Get some rest."
    SCRIPT_WAIT
    SCRIPT_END
.firstClearThanks:
    SCRIPT_IF_NEQ .Addr=$d0e5, .Value=$00, .Target=.climbedAgain
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitAlt, .Bank=$18
    db "Good to see you."
    SCRIPT_NEWLINE
    db "You finally did"
    SCRIPT_WAIT
    db "it. Thanks! All"
    SCRIPT_NEWLINE
    db "that's left is"
    SCRIPT_WAIT
    db "the complete"
    SCRIPT_NEWLINE
    db "conquer of this"
    SCRIPT_WAIT
    db "tower. There are"
    SCRIPT_NEWLINE
    db "more things"
    SCRIPT_WAIT
    db "hiding in this"
    SCRIPT_NEWLINE
    db "tower. Be"
    SCRIPT_WAIT
    db "careful. I'll"
    SCRIPT_NEWLINE
    db "help you out."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=$d0e5, .Value=$01
    SCRIPT_END
.climbedAgain:
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitAlt, .Bank=$18
    db "You climbed to"
    SCRIPT_NEWLINE
    db "the top again."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitTalking, .Bank=$18
    db "If you feel you"
    SCRIPT_NEWLINE
    db "haven't finished"
    SCRIPT_WAIT
    db "rest at the"
    SCRIPT_NEWLINE
    db "cabin and return"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitAlt, .Bank=$18
    db "I'll be waiting."
    SCRIPT_WAIT
    SCRIPT_END
.thrownOutTried:
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitTalking, .Bank=$18
    db "Looks like you"
    SCRIPT_NEWLINE
    db "were thrown out."
    SCRIPT_WAIT
    db "It's okay since"
    SCRIPT_NEWLINE
    db "you tried!"
    SCRIPT_WAIT
    db "Don't be hard"
    SCRIPT_NEWLINE
    db "on yourself."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitAlt, .Bank=$18
    db "I'll make sure"
    SCRIPT_NEWLINE
    db "you will get"
    SCRIPT_WAIT
    db "Level "
    SCRIPT_DECIMAL .Addr=$cff2
    SCRIPT_NEWLINE
    db "next time."
    SCRIPT_WAIT
    SCRIPT_END
.clearedRun:
    SCRIPT_IF_EQ .Addr=$c2d7, .Value=$00, .Target=.thrownOutHard
    SCRIPT_IF_EQ .Addr=$c2d7, .Value=$03, .Target=.basementOpened
    SCRIPT_IF_EQ .Addr=$c2d7, .Value=$02, .Target=.needSilverKey
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitAlt, .Bank=$18
    db "You made it out!"
    SCRIPT_NEWLINE
    db "Glad you're safe"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitTalking, .Bank=$18
    db "To move forward"
    SCRIPT_NEWLINE
    db "and gain success"
    SCRIPT_WAIT
    db "plan a strategy."
    SCRIPT_NEWLINE
    db "Good luck."
    SCRIPT_WAIT
    SCRIPT_END
.basementOpened:
    SCRIPT_IF_NEQ .Addr=$d0e6, .Value=$00, .Target=.backSafely
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitAlt, .Bank=$18
    db "Oh, you're here."
    SCRIPT_NEWLINE
    db "I didn't think"
    SCRIPT_WAIT
    db "you'd open all"
    SCRIPT_NEWLINE
    db "the basement"
    SCRIPT_WAIT
    db "rooms. Great!"
    SCRIPT_NEWLINE
    db "Go ahead and"
    SCRIPT_WAIT
    db "explore as you"
    SCRIPT_NEWLINE
    db "please."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=$d0e6, .Value=$01
    SCRIPT_END
.backSafely:
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitAlt, .Bank=$18
    db "Good. You made"
    SCRIPT_NEWLINE
    db "it back safely."
    SCRIPT_WAIT
    db "You're getting"
    SCRIPT_NEWLINE
    db "used to it here."
    SCRIPT_WAIT
    db "Rest first and"
    SCRIPT_NEWLINE
    db "come back."
    SCRIPT_WAIT
    SCRIPT_END
.thrownOutHard:
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitTalking, .Bank=$18
    db "Looks like you"
    SCRIPT_NEWLINE
    db "were thrown out."
    SCRIPT_WAIT
    db "Bad happens when"
    SCRIPT_NEWLINE
    db "you try too hard"
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitAlt, .Bank=$18
    db "Be careful, and"
    SCRIPT_NEWLINE
    db "good luck."
    SCRIPT_WAIT
    SCRIPT_END
.needSilverKey:
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitTalking, .Bank=$18
    db "Good work, but"
    SCRIPT_NEWLINE
    db "you can't go any"
    SCRIPT_WAIT
    db "further. To"
    SCRIPT_NEWLINE
    db "move on, you"
    SCRIPT_WAIT
    db "need another"
    SCRIPT_NEWLINE
    db "silver key. One"
    SCRIPT_WAIT
    db "still exists"
    SCRIPT_NEWLINE
    db "in the tower."
    SCRIPT_WAIT
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitAlt, .Bank=$18
    db "You can do it!"
    SCRIPT_NEWLINE
    db "Don't give up!"
    SCRIPT_WAIT
    SCRIPT_END

