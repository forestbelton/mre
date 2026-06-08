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
    SCRIPT_FAR_CALL .Addr=Naji_ShowMenu2, .Bank=$1f
    SCRIPT_GOTO .Target=.menuFinalize
.renderClimb:
    SCRIPT_FAR_CALL .Addr=Naji_ShowMenu3a, .Bank=$1f
    SCRIPT_GOTO .Target=.menuFinalize
.checkAsk:
    SCRIPT_IF_NEQ .Addr=wCFF0, .Value=$00, .Target=.renderLeave
    SCRIPT_FAR_CALL .Addr=Naji_ShowMenu3b, .Bank=$1f
    SCRIPT_GOTO .Target=.menuFinalize
.renderLeave:
    SCRIPT_FAR_CALL .Addr=Naji_ShowMenu4, .Bank=$1f
.menuFinalize:
    SCRIPT_FAR_CALL .Addr=Naji_LoadPortraitTilemap, .Bank=$18
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
    SCRIPT_FAR_CALL .Addr=ShowYesNoMenu, .Bank=$1f
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=NajiMenu
    SCRIPT_FAR_CALL .Addr=Script_FadeOutPortrait, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=Naji_ResumeTowerClimb, .Bank=$18
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
    SCRIPT_FAR_CALL .Addr=ShowYesNoMenu, .Bank=$1f
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=NajiMenu
    SCRIPT_FAR_CALL .Addr=Script_FadeOutPortrait, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=Naji_StartTowerClimb, .Bank=$18
    SCRIPT_END

NajiAskMenu:
    SCRIPT_RENDERER .Addr=Naji_RenderPortraitTalking, .Bank=$18
    db "What do you"
    SCRIPT_NEWLINE
    db "want to know?"
    SCRIPT_FAR_CALL .Addr=Naji_ShowSubMenu2, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=Naji_LoadPortraitTilemap, .Bank=$18
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
    SCRIPT_FAR_CALL .Addr=Script_FadeOutPortrait, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=Naji_StartTowerFromBottom, .Bank=$18
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
    SCRIPT_FAR_CALL .Addr=ShowYesNoMenu, .Bank=$1f
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=NajiMenu
    SCRIPT_FAR_CALL .Addr=Script_FadeOutPortrait, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=Naji_StartTowerFromBottom, .Bank=$18
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

SECTION "analyzed_062b65", ROMX[$6b65], BANK[$18]

Func_18_6b65:
	ld a, $04
	ld [wNajiState], a
	ld [wPashuteState], a
	ld [wVerdeState], a
	ret

Func_18_6b71:
	call Naji_BuildPortraitScene
	ld hl, $6ce3
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
	ld a, $2f
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

; --- Naji dialogue table ---
; Raw text-script bytecode (see include/text.inc / docs/text_engine.md), the
; same opcodes the carved scripts express via SCRIPT_* macros:
;   $0E lo hi bank  set renderer ($6c27=Naji_RenderPortraitTalking,
;                                 $6c9f=Naji_RenderPortraitAlt)
;   $0D newline   $04 wait-for-A / end message   $FF end of script
;   $0A/$0B addr val tgt  IF_EQ/IF_NEQ branch     $09 addr val  write WRAM
; Each block is entered via a pointer embedded in the scene scripts or an
; earlier block. Data_18_6fa5 and Data_18_7080 were previously
; misdisassembled as code (the $18 script byte aliases the Z80 `jr` opcode,
; which spawned bogus jr labels into the strings); re-carved here as data.
; Still raw hex like the rest of the table — decoding to SCRIPT_* + db "text"
; is future work.
Data_18_6ce3:
	db $0a, $c1, $c2, $01, $2b, $6f, $0a, $d7, $c2, $00, $9b, $6e, $0a, $d7, $c2, $01
	db $63, $6d, $0e, $9f, $6c, $18, $59, $6f, $75, $20, $67, $6f, $74, $20, $6f, $75
	db $74, $20, $73, $61, $66, $65, $2e, $0d, $47, $6f, $6f, $64, $20, $74, $6f, $20
	db $73, $65, $65, $20, $79, $6f, $75, $2e, $04, $0e, $27, $6c, $18, $49, $27, $6c
	db $6c, $20, $6d, $61, $6b, $65, $20, $73, $75, $72, $65, $0d, $79, $6f, $75, $20
	db $77, $69, $6c, $6c, $20, $73, $74, $61, $72, $74, $04, $4c, $65, $76, $65, $6c
	db $20, $0f, $f2, $cf, $0d, $6e, $65, $78, $74, $20, $74, $69, $6d, $65, $2e, $04
	db $47, $65, $74, $20, $73, $6f, $6d, $65, $20, $72, $65, $73, $74, $2e, $04, $ff
	db $0b, $e5, $d0, $00, $21, $6e, $0e, $9f, $6c, $18, $47, $6f, $6f, $64, $20, $74
	db $6f, $20, $73, $65, $65, $20, $79, $6f, $75, $2e, $0d, $59, $6f, $75, $20, $66
	db $69, $6e, $61, $6c, $6c, $79, $20, $64, $69, $64, $04, $69, $74, $2e, $20, $54
	db $68, $61, $6e, $6b, $73, $21, $20, $41, $6c, $6c, $0d, $74, $68, $61, $74, $27
	db $73, $20, $6c, $65, $66, $74, $20, $69, $73, $04, $74, $68, $65, $20, $63, $6f
	db $6d, $70, $6c, $65, $74, $65, $0d, $63, $6f, $6e, $71, $75, $65, $72, $20, $6f
	db $66, $20, $74, $68, $69, $73, $04, $74, $6f, $77, $65, $72, $2e, $20, $54, $68
	db $65, $72, $65, $20, $61, $72, $65, $0d, $6d, $6f, $72, $65, $20, $74, $68, $69
	db $6e, $67, $73, $04, $68, $69, $64, $69, $6e, $67, $20, $69, $6e, $20, $74, $68
	db $69, $73, $0d, $74, $6f, $77, $65, $72, $2e, $20, $42, $65, $04, $63, $61, $72
	db $65, $66, $75, $6c, $2e, $20, $49, $27, $6c, $6c, $0d, $68, $65, $6c, $70, $20
	db $79, $6f, $75, $20, $6f, $75, $74, $2e, $04, $09, $e5, $d0, $01, $ff

Data_18_6e21:
	db $0e, $9f, $6c, $18, $59, $6f, $75, $20, $63, $6c, $69, $6d, $62, $65, $64, $20
	db $74, $6f, $0d, $74, $68, $65, $20, $74, $6f, $70, $20, $61, $67, $61, $69, $6e
	db $2e, $04, $0e, $27, $6c, $18, $49, $66, $20, $79, $6f, $75, $20, $66, $65, $65
	db $6c, $20, $79, $6f, $75, $0d, $68, $61, $76, $65, $6e, $27, $74, $20, $66, $69
	db $6e, $69, $73, $68, $65, $64, $04, $72, $65, $73, $74, $20, $61, $74, $20, $74
	db $68, $65, $0d, $63, $61, $62, $69, $6e, $20, $61, $6e, $64, $20, $72, $65, $74
	db $75, $72, $6e, $04, $0e, $9f, $6c, $18, $49, $27, $6c, $6c, $20, $62, $65, $20
	db $77, $61, $69, $74, $69, $6e, $67, $2e, $04, $ff

Data_18_6e9b:
	db $0e, $27, $6c, $18, $4c, $6f, $6f, $6b, $73, $20, $6c, $69, $6b, $65, $20, $79
	db $6f, $75, $0d, $77, $65, $72, $65, $20, $74, $68, $72, $6f, $77, $6e, $20, $6f
	db $75, $74, $2e, $04, $49, $74, $27, $73, $20, $6f, $6b, $61, $79, $20, $73, $69
	db $6e, $63, $65, $0d, $79, $6f, $75, $20, $74, $72, $69, $65, $64, $21, $04, $44
	db $6f, $6e, $27, $74, $20, $62, $65, $20, $68, $61, $72, $64, $0d, $6f, $6e, $20
	db $79, $6f, $75, $72, $73, $65, $6c, $66, $2e, $04, $0e, $9f, $6c, $18, $49, $27
	db $6c, $6c, $20, $6d, $61, $6b, $65, $20, $73, $75, $72, $65, $0d, $79, $6f, $75
	db $20, $77, $69, $6c, $6c, $20, $67, $65, $74, $04, $4c, $65, $76, $65, $6c, $20
	db $0f, $f2, $cf, $0d, $6e, $65, $78, $74, $20, $74, $69, $6d, $65, $2e, $04, $ff
	db $0a, $d7, $c2, $00, $80, $70, $0a, $d7, $c2, $03, $a5, $6f, $0a, $d7, $c2, $02
	db $e6, $70, $0e, $9f, $6c, $18, $59, $6f, $75, $20, $6d, $61, $64, $65, $20, $69
	db $74, $20, $6f, $75, $74, $21, $0d, $47, $6c, $61, $64, $20, $79, $6f, $75, $27
	db $72, $65, $20, $73, $61, $66, $65, $04, $0e, $27, $6c, $18, $54, $6f, $20, $6d
	db $6f, $76, $65, $20, $66, $6f, $72, $77, $61, $72, $64, $0d, $61, $6e, $64, $20
	db $67, $61, $69, $6e, $20, $73, $75, $63, $63, $65, $73, $73, $04, $70, $6c, $61
	db $6e, $20, $61, $20, $73, $74, $72, $61, $74, $65, $67, $79, $2e, $0d, $47, $6f
	db $6f, $64, $20, $6c, $75, $63, $6b, $2e, $04, $ff

Data_18_6fa5:
	db $0b, $e6, $d0, $00, $22, $70, $0e, $9f, $6c, $18, $4f, $68, $2c, $20, $79, $6f
	db $75, $27, $72, $65, $20, $68, $65, $72, $65, $2e, $0d, $49, $20, $64, $69, $64
	db $6e, $27, $74, $20, $74, $68, $69, $6e, $6b, $04, $79, $6f, $75, $27, $64, $20
	db $6f, $70, $65, $6e, $20, $61, $6c, $6c, $0d, $74, $68, $65, $20, $62, $61, $73
	db $65, $6d, $65, $6e, $74, $04, $72, $6f, $6f, $6d, $73, $2e, $20, $47, $72, $65
	db $61, $74, $21, $0d, $47, $6f, $20, $61, $68, $65, $61, $64, $20, $61, $6e, $64
	db $04, $65, $78, $70, $6c, $6f, $72, $65, $20, $61, $73, $20, $79, $6f, $75, $0d
	db $70, $6c, $65, $61, $73, $65, $2e, $04, $09, $e6, $d0, $01, $ff, $0e, $9f, $6c
	db $18, $47, $6f, $6f, $64, $2e, $20, $59, $6f, $75, $20, $6d, $61, $64, $65, $0d
	db $69, $74, $20, $62, $61, $63, $6b, $20, $73, $61, $66, $65, $6c, $79, $2e, $04
	db $59, $6f, $75, $27, $72, $65, $20, $67, $65, $74, $74, $69, $6e, $67, $0d, $75
	db $73, $65, $64, $20, $74, $6f, $20, $69, $74, $20, $68, $65, $72, $65, $2e, $04
	db $52, $65, $73, $74, $20, $66, $69, $72, $73, $74, $20, $61, $6e, $64, $0d, $63
	db $6f, $6d, $65, $20, $62, $61, $63, $6b, $2e, $04, $ff

Data_18_7080:
	db $0e, $27, $6c, $18, $4c, $6f, $6f, $6b, $73, $20, $6c, $69, $6b, $65, $20, $79
	db $6f, $75, $0d, $77, $65, $72, $65, $20, $74, $68, $72, $6f, $77, $6e, $20, $6f
	db $75, $74, $2e, $04, $42, $61, $64, $20, $68, $61, $70, $70, $65, $6e, $73, $20
	db $77, $68, $65, $6e, $0d, $79, $6f, $75, $20, $74, $72, $79, $20, $74, $6f, $6f
	db $20, $68, $61, $72, $64, $04, $0e, $9f, $6c, $18, $42, $65, $20, $63, $61, $72
	db $65, $66, $75, $6c, $2c, $20, $61, $6e, $64, $0d, $67, $6f, $6f, $64, $20, $6c
	db $75, $63, $6b, $2e, $04, $ff

Data_18_70e6:
	db $0e, $27, $6c, $18, $47, $6f, $6f, $64, $20, $77, $6f, $72, $6b, $2c, $20, $62
	db $75, $74, $0d, $79, $6f, $75, $20, $63, $61, $6e, $27, $74, $20, $67, $6f, $20
	db $61, $6e, $79, $04, $66, $75, $72, $74, $68, $65, $72, $2e, $20, $54, $6f, $0d
	db $6d, $6f, $76, $65, $20, $6f, $6e, $2c, $20, $79, $6f, $75, $04, $6e, $65, $65
	db $64, $20, $61, $6e, $6f, $74, $68, $65, $72, $0d, $73, $69, $6c, $76, $65, $72
	db $20, $6b, $65, $79, $2e, $20, $4f, $6e, $65, $04, $73, $74, $69, $6c, $6c, $20
	db $65, $78, $69, $73, $74, $73, $0d, $69, $6e, $20, $74, $68, $65, $20, $74, $6f
	db $77, $65, $72, $2e, $04, $0e, $9f, $6c, $18, $59, $6f, $75, $20, $63, $61, $6e
	db $20, $64, $6f, $20, $69, $74, $21, $0d, $44, $6f, $6e, $27, $74, $20, $67, $69
	db $76, $65, $20, $75, $70, $21, $04, $ff
