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
    SCRIPT_RENDERER Naji_RenderPortraitTalking
    db "Did you come to\r"
    db "climb the tower?"
    SCRIPT_WAIT
    db "I'm Naji. The\r"
    db "guard here. But"
    SCRIPT_WAIT
    db "I'm on vacation\r"
    db "right now. It's"
    SCRIPT_WAIT
    db "useless to guard\r"
    db "a place no one"
    SCRIPT_WAIT
    db "dares to come."
    SCRIPT_WAIT
    db "Village people\r"
    db "tried to rid the"
    SCRIPT_WAIT
    db "problem, but no\r"
    db "one has returned"
    SCRIPT_WAIT
    db "Since one can't\r"
    db "do much, I've"
    SCRIPT_WAIT
    db "stayed behind to\r"
    db "the brave young"
    SCRIPT_WAIT
    db "like you. But I\r"
    db "have no strength"
    SCRIPT_WAIT
    db "left to fight\r"
    db "Nada. You have"
    SCRIPT_WAIT
    db "wits and courage\r"
    db "to fight Nada."
    SCRIPT_WAIT
    db "Help us? I am\r"
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
    SCRIPT_RENDERER Naji_RenderPortraitAlt
    db "Oh, you're here.\r"
    db "Good luck."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=NajiMenu

.greet1:
    SCRIPT_RENDERER Naji_RenderPortraitTalking
    db "It's you. Good\r"
    db "luck, my friend."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=NajiMenu

.greet2:
    SCRIPT_RENDERER Naji_RenderPortraitAlt
    db "It's you. We're\r"
    db "counting on you."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=NajiMenu

.greet3:
    SCRIPT_RENDERER Naji_RenderPortraitTalking
    db "Hey. It's you!\r"
    db "Take it easy!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=NajiMenu

NajiProgress:
    SCRIPT_RENDERER Naji_RenderPortraitAlt
    db "Oh, it's you\r"
    db "again. You made"
    SCRIPT_WAIT
    db "it half-way up.\r"
    db "I wasn't wrong"
    SCRIPT_WAIT
    db "in counting on\r"
    db "you. Some of our"
    SCRIPT_WAIT
    db "villagers got\r"
    db "back, but don't"
    SCRIPT_WAIT
    db "get careless.\r"
    db "It gets harder."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wNajiState, .Value=$01
    SCRIPT_GOTO .Target=NajiMenu

NajiMenu:
    SCRIPT_RENDERER Naji_RenderPortraitTalking
    db "What are your\r"
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
    SCRIPT_RENDERER Naji_RenderPortraitTalking
    db "You've climbed\r"
    db "till Level "
    SCRIPT_DECIMAL .Addr=wCurrentFloor
    SCRIPT_WAIT
    db "Want to\r"
    db "start there?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL ShowYesNoMenu
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=NajiMenu
    SCRIPT_FAR_CALL Script_FadeOutPortrait
    SCRIPT_FAR_CALL Naji_ResumeTowerClimb
    SCRIPT_END

NajiClimb:
    SCRIPT_RENDERER Naji_RenderPortraitTalking
    db "I understand.\r"
    db "I'll open the"
    SCRIPT_WAIT
    db "door. But,\r"
    db "are you ready?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL ShowYesNoMenu
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=NajiMenu
    SCRIPT_FAR_CALL Script_FadeOutPortrait
    SCRIPT_FAR_CALL Naji_StartTowerClimb
    SCRIPT_END

NajiAskMenu:
    SCRIPT_RENDERER Naji_RenderPortraitTalking
    db "What do you\r"
    db "want to know?"
    SCRIPT_FAR_CALL Naji_ShowSubMenu2
    SCRIPT_FAR_CALL Naji_LoadPortraitTilemap
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE wSubMenuCursor, NajiAskTower, NajiAskItem, NajiAskStop

NajiLeave:
    SCRIPT_RENDERER Naji_RenderPortraitTalking
    db "See you later."
    SCRIPT_WAIT
    SCRIPT_END

NajiTowerLong:
    SCRIPT_IF_EQ .Addr=wTowerExplained, .Value=$01, .Target=NajiTowerShort
    SCRIPT_RENDERER Naji_RenderPortraitTalking
    db "10 underground\r"
    db "levels here. The"
    SCRIPT_WAIT
    db "true legend must\r"
    db "be hidden here."
    SCRIPT_WAIT
    db "Don't misjudge."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wTowerExplained, .Value=$01
    SCRIPT_FAR_CALL Script_FadeOutPortrait
    SCRIPT_FAR_CALL Naji_StartTowerFromBottom
    SCRIPT_END

NajiTowerShort:
    SCRIPT_RENDERER Naji_RenderPortraitTalking
    db "You again! Going\r"
    db "to try again?"
    SCRIPT_WAIT
    db "Persistence is\r"
    db "the shortcut to"
    SCRIPT_WAIT
    db "the legend. I'll\r"
    db "show you the way"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL ShowYesNoMenu
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=NajiMenu
    SCRIPT_FAR_CALL Script_FadeOutPortrait
    SCRIPT_FAR_CALL Naji_StartTowerFromBottom
    SCRIPT_END

NajiAskTower:
    SCRIPT_RENDERER Naji_RenderPortraitTalking
    db "Find the golden\r"
    db "key in each"
    SCRIPT_WAIT
    db "room. It will\r"
    db "open the door,"
    SCRIPT_WAIT
    db "and you can exit\r"
    db "from that room."
    SCRIPT_WAIT
    db "Flying lights\r"
    db "are hints of"
    SCRIPT_WAIT
    db "where the key\r"
    db "and door hides."
    SCRIPT_WAIT
    db "Let me explain\r"
    db "about Life."
    SCRIPT_WAIT
    db "You start with\r"
    db "three lives."
    SCRIPT_WAIT
    db "If you lose all\r"
    db "lives or leave"
    SCRIPT_WAIT
    db "the tower,\r"
    db "you will lose"
    SCRIPT_WAIT
    db "all effects of\r"
    db "items."
    SCRIPT_WAIT
    db "But don't worry.\r"
    db "You won't lose"
    SCRIPT_WAIT
    db "your Holy items.\r"
    db "That's all I"
    SCRIPT_WAIT
    db "know.\r"
    db "Good luck!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=NajiAskMenu

NajiAskItem:
    SCRIPT_RENDERER Naji_RenderPortraitTalking
    db "Let me explain.\r"
    db "There are over"
    SCRIPT_WAIT
    db "300 items hidden\r"
    db "in this tower."
    SCRIPT_WAIT
    db "They're hard to\r"
    db "find, but try"
    SCRIPT_WAIT
    db "making boxes and\r"
    db "just break them."
    SCRIPT_WAIT
    db "The most\r"
    db "important item"
    SCRIPT_WAIT
    db "is a saucer\r"
    db "stone fragment."
    SCRIPT_WAIT
    db "4 fragments\r"
    db "will make one"
    SCRIPT_WAIT
    db "saucer stone.\r"
    db "You can seal a"
    SCRIPT_WAIT
    db "good monster\r"
    db "inside it."
    SCRIPT_WAIT
    db "I'm sorry, but\r"
    db "this is all I"
    SCRIPT_WAIT
    db "know. The priest\r"
    db "in the tower"
    SCRIPT_WAIT
    db "will tell you\r"
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
	FAR_CALL Script_FadeOutPortrait
	ret

	call Naji_BuildPortraitScene
	ld hl, NajiScript
	call ScriptDispatcherEnterAfterCall
	ld a, [wMainMenuResult]
	cp $04
	jp z, LeaveTownBuilding
	ret

Naji_StartTowerClimb:
	FAR_CALL Func_05_4785
	FAR_CALL Func_00_34e3
	ret
Naji_ResumeTowerClimb:
	FAR_CALL Func_05_479d
	FAR_CALL Func_00_34e3
	ret
Naji_StartTowerFromBottom:
	FAR_CALL Func_05_47b2
	FAR_CALL Func_00_34e3
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
	ld hl, Naji_talk_face
	ld a, $1a
	ld de, $9886
	call BankMapCopyA
	ld hl, Naji_collar
	ld bc, $3e3c
	call DrawMetasprite
	ld hl, Naji_vest_left
	ld bc, $4828
	call DrawMetasprite
	ld hl, Naji_vest_right
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
	ld hl, Naji_eyes_frame0
	ld a, $1a
	ld de, $9886
	call BankMapCopyA
	ld hl, Naji_face_shadow0
	ld bc, $1e34
	call DrawMetasprite
	ret
.frame1:
	ld hl, Naji_eyes_frame1
	ld a, $1a
	ld de, $9886
	call BankMapCopyA
	ld hl, Naji_face_shadow1
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
	ld hl, Naji_smile_face
	ld a, $1a
	ld de, $9886
	call BankMapCopyA
	ld hl, Naji_smile_shadow
	ld bc, $1e34
	call DrawMetasprite
	ld hl, Naji_collar
	ld bc, $3e3c
	call DrawMetasprite
	ld hl, Naji_vest_left
	ld bc, $4828
	call DrawMetasprite
	ld hl, Naji_vest_right
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
    SCRIPT_RENDERER Naji_RenderPortraitAlt
    db "You got out safe.\r"
    db "Good to see you."
    SCRIPT_WAIT
    SCRIPT_RENDERER Naji_RenderPortraitTalking
    db "I'll make sure\r"
    db "you will start"
    SCRIPT_WAIT
    db "Level "
    SCRIPT_DECIMAL .Addr=$cff2
    db "\r"
    db "next time."
    SCRIPT_WAIT
    db "Get some rest."
    SCRIPT_WAIT
    SCRIPT_END
.firstClearThanks:
    SCRIPT_IF_NEQ .Addr=$d0e5, .Value=$00, .Target=.climbedAgain
    SCRIPT_RENDERER Naji_RenderPortraitAlt
    db "Good to see you.\r"
    db "You finally did"
    SCRIPT_WAIT
    db "it. Thanks! All\r"
    db "that's left is"
    SCRIPT_WAIT
    db "the complete\r"
    db "conquer of this"
    SCRIPT_WAIT
    db "tower. There are\r"
    db "more things"
    SCRIPT_WAIT
    db "hiding in this\r"
    db "tower. Be"
    SCRIPT_WAIT
    db "careful. I'll\r"
    db "help you out."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=$d0e5, .Value=$01
    SCRIPT_END
.climbedAgain:
    SCRIPT_RENDERER Naji_RenderPortraitAlt
    db "You climbed to\r"
    db "the top again."
    SCRIPT_WAIT
    SCRIPT_RENDERER Naji_RenderPortraitTalking
    db "If you feel you\r"
    db "haven't finished"
    SCRIPT_WAIT
    db "rest at the\r"
    db "cabin and return"
    SCRIPT_WAIT
    SCRIPT_RENDERER Naji_RenderPortraitAlt
    db "I'll be waiting."
    SCRIPT_WAIT
    SCRIPT_END
.thrownOutTried:
    SCRIPT_RENDERER Naji_RenderPortraitTalking
    db "Looks like you\r"
    db "were thrown out."
    SCRIPT_WAIT
    db "It's okay since\r"
    db "you tried!"
    SCRIPT_WAIT
    db "Don't be hard\r"
    db "on yourself."
    SCRIPT_WAIT
    SCRIPT_RENDERER Naji_RenderPortraitAlt
    db "I'll make sure\r"
    db "you will get"
    SCRIPT_WAIT
    db "Level "
    SCRIPT_DECIMAL .Addr=$cff2
    db "\r"
    db "next time."
    SCRIPT_WAIT
    SCRIPT_END
.clearedRun:
    SCRIPT_IF_EQ .Addr=$c2d7, .Value=$00, .Target=.thrownOutHard
    SCRIPT_IF_EQ .Addr=$c2d7, .Value=$03, .Target=.basementOpened
    SCRIPT_IF_EQ .Addr=$c2d7, .Value=$02, .Target=.needSilverKey
    SCRIPT_RENDERER Naji_RenderPortraitAlt
    db "You made it out!\r"
    db "Glad you're safe"
    SCRIPT_WAIT
    SCRIPT_RENDERER Naji_RenderPortraitTalking
    db "To move forward\r"
    db "and gain success"
    SCRIPT_WAIT
    db "plan a strategy.\r"
    db "Good luck."
    SCRIPT_WAIT
    SCRIPT_END
.basementOpened:
    SCRIPT_IF_NEQ .Addr=$d0e6, .Value=$00, .Target=.backSafely
    SCRIPT_RENDERER Naji_RenderPortraitAlt
    db "Oh, you're here.\r"
    db "I didn't think"
    SCRIPT_WAIT
    db "you'd open all\r"
    db "the basement"
    SCRIPT_WAIT
    db "rooms. Great!\r"
    db "Go ahead and"
    SCRIPT_WAIT
    db "explore as you\r"
    db "please."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=$d0e6, .Value=$01
    SCRIPT_END
.backSafely:
    SCRIPT_RENDERER Naji_RenderPortraitAlt
    db "Good. You made\r"
    db "it back safely."
    SCRIPT_WAIT
    db "You're getting\r"
    db "used to it here."
    SCRIPT_WAIT
    db "Rest first and\r"
    db "come back."
    SCRIPT_WAIT
    SCRIPT_END
.thrownOutHard:
    SCRIPT_RENDERER Naji_RenderPortraitTalking
    db "Looks like you\r"
    db "were thrown out."
    SCRIPT_WAIT
    db "Bad happens when\r"
    db "you try too hard"
    SCRIPT_WAIT
    SCRIPT_RENDERER Naji_RenderPortraitAlt
    db "Be careful, and\r"
    db "good luck."
    SCRIPT_WAIT
    SCRIPT_END
.needSilverKey:
    SCRIPT_RENDERER Naji_RenderPortraitTalking
    db "Good work, but\r"
    db "you can't go any"
    SCRIPT_WAIT
    db "further. To\r"
    db "move on, you"
    SCRIPT_WAIT
    db "need another\r"
    db "silver key. One"
    SCRIPT_WAIT
    db "still exists\r"
    db "in the tower."
    SCRIPT_WAIT
    SCRIPT_RENDERER Naji_RenderPortraitAlt
    db "You can do it!\r"
    db "Don't give up!"
    SCRIPT_WAIT
    SCRIPT_END

