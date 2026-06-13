; Pashute (monster shrine priest, regeneration NPC) full script.
;
; Pashute is one of the townspeople who went into the tower and
; returned (Toamuna's D0DC=2 greeting). He runs the monster shrine —
; the script offers regeneration of monsters (names rendered via the
; engine's $11 indexed-string opcode reading the table at HOME $3B75).
;
; Carved out of analyzed.asm via map.json; see docs/text_engine.md.

INCLUDE "game.inc"
INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "text.inc"
INCLUDE "sound/id.inc"

SECTION "Pashute script functions", ROMX

Pashute_GetMonsterUsesDecimal:
	ld hl, wMonsterUses
	ld a, [wActiveMonster]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld c, $00
	ld a, [hl]
	swap a
	and $0f
	ld b, a
.loop:
	ld a, b
	or a
	jr z, .done
	ld a, c
	add a, $0a
	ld c, a
	dec b
	jr .loop
.done:
	ld a, [hl]
	and $0f
	add a, c
	ld [wYNResult], a
	ret

Pashute_IsReplacingActiveMonster:
	ld hl, wActiveMonster
	ld a, [wDisplayMonster]
	cp [hl]
	jr z, .yes
	ld a, $01
	ld [wYNResult], a
	ret
.yes:
	ld a, $00
	ld [wYNResult], a
	ret

Pashute_GetActiveMonsterUses:
	ld hl, wMonsterUses
	ld a, [wActiveMonster]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	ld [wYNResult], a
	ret

Pashute_SetReplaceTargetActive:
	ld a, [wActiveMonster]
	ld [wDisplayMonster], a
	ret

Pashute_ResetRosterKeepNew:
	ld hl, wMonsterUses
	ld a, [wActiveMonster]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	push af
	push hl
	ld hl, wMonsterUses
	xor a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	pop hl
	pop af
	ld [hl], a
	jp Pashute_AddFiveMonsterUses

Pashute_AddFiveMonsterUses:
	ld hl, wMonsterUses
	ld a, [wActiveMonster]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	add a, $05
	daa
	jr nc, .update
	ld a, $99
.update:
	ld [hl], a
	ld hl, wMonsterDiscStones
	ld a, [wActiveMonster]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	dec [hl]
	ret

Pashute_StartTownScript:
	ld hl, PashuteScript
	call ScriptDispatcherEnterAfterCall
	jp LeaveTownBuilding

Pashute_LoadShrineScene:
	call LoadWhitePalettes
	call HideAllSprites
	call LoadTextUi
	ld a, $01
	ld [rVBK], a
	ld a, $1b
	ld hl, $4000
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	call Pashute_LoadShrineTilemap
	call Pashute_RenderPortraitNeutral
	call HideUnusedOamSprites
	ld a, $1b
	ld hl, $5800
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, $1b
	ld hl, $5840
	ld de, wObjPalettes
	ld bc, $0030
	call BankCopy
	xor a
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	call WaitForNextFrame
	push af
	ld a, SOUND_BGM_Pashute
	call PlaySoundTracked
	pop af
	ret
Pashute_LoadIntroScene:
	call LoadWhitePalettes
	call HideAllSprites
	call LoadTextUi
	ld a, $01
	ld [rVBK], a
	ld a, $1b
	ld hl, $4000
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	call Pashute_LoadShrineTilemap
	call Pashute_RenderPortraitNeutral
	call HideUnusedOamSprites
	ld a, $1b
	ld hl, $5bdd
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, $1b
	ld hl, $5c1d
	ld de, wObjPalettes
	ld bc, $0030
	call BankCopy
	push af
	ld a, SOUND_BGM_Pashute
	call PlaySoundTracked
	pop af
	FAR_CALL ShowPortraitTransition
	ret
Pashute_LoadShrineTilemap:
	ld hl, $5880
	ld a, $1b
	ld de, $9800
	call BankMapCopyA
	ret
Pashute_RenderPortraitNeutral:
	ld a, $50
	ld [wRendererAddr], a
	ld a, $41
	ld [$d61f], a
	ld a, $18
	ld [wRendererBank], a
	ld a, $1b
	ld [wDrawBank], a
	ld hl, Pashute_shoulder_left
	ld bc, $5018
	call DrawMetasprite
	ld hl, Pashute_shoulder_right
	ld bc, $5058
	call DrawMetasprite
	ld hl, Pashute_collar
	ld bc, $482f
	call DrawMetasprite
	ld hl, Pashute_neutral_face
	ld a, $1b
	ld de, $9885
	call BankMapCopyA
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
	ld hl, Pashute_eyes_frame0
	ld a, $1b
	ld de, $9885
	call BankMapCopyA
	ld hl, Pashute_blink_frame0
	ld bc, $1d28
	call DrawMetasprite
	ret
.frame1:
	ld hl, Pashute_eyes_frame1
	ld a, $1b
	ld de, $9885
	call BankMapCopyA
	ld hl, Pashute_blink_frame1
	ld bc, $1d28
	call DrawMetasprite
	ret
.frame2:
	ld hl, Pashute_eyes_frame2
	ld a, $1b
	ld de, $9885
	call BankMapCopyA
	ld hl, Pashute_blink_frame2
	ld bc, $1d28
	call DrawMetasprite
	ret
Pashute_RenderPortraitPanic:
	ld a, $e1
	ld [wRendererAddr], a
	ld a, $41
	ld [$d61f], a
	ld a, $18
	ld [wRendererBank], a
	ld a, $1b
	ld [wDrawBank], a
	ld hl, Pashute_shoulder_left
	ld bc, $5018
	call DrawMetasprite
	ld hl, Pashute_shoulder_right
	ld bc, $5058
	call DrawMetasprite
	ld hl, Pashute_collar
	ld bc, $482f
	call DrawMetasprite
	ld hl, Pashute_sad_face
	ld a, $1b
	ld de, $9885
	call BankMapCopyA
	ld hl, Pashute_sad_overlay
	ld bc, $1d28
	call DrawMetasprite
	ret
Pashute_RenderPortraitShocked:
	ld a, $25
	ld [wRendererAddr], a
	ld a, $42
	ld [$d61f], a
	ld a, $18
	ld [wRendererBank], a
	ld a, $1b
	ld [wDrawBank], a
	ld hl, Pashute_shoulder_left
	ld bc, $5018
	call DrawMetasprite
	ld hl, Pashute_shoulder_right
	ld bc, $5058
	call DrawMetasprite
	ld hl, Pashute_collar
	ld bc, $482f
	call DrawMetasprite
	ld hl, Pashute_shocked_face
	ld a, $1b
	ld de, $9885
	call BankMapCopyA
	ld hl, Pashute_shocked_overlay
	ld bc, $1d28
	call DrawMetasprite
	ld hl, Pashute_shocked_overlay2
	ld bc, $3d3a
	call DrawMetasprite
	ret

SECTION "Pashute script", ROMX


PashuteScript:
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    SCRIPT_IF_EQ .Addr=wPashuteState, .Value=$04, .Target=PashuteGameDone
    SCRIPT_IF_EQ .Addr=wPashuteState, .Value=$03, .Target=PashuteGreetProgress
    SCRIPT_IF_EQ .Addr=wPashuteState, .Value=$02, .Target=PashuteGreetReturning
    SCRIPT_IF_EQ .Addr=wPashuteState, .Value=$01, .Target=PashuteGreetingCycle
    SCRIPT_FAR_CALL Pashute_LoadIntroScene
    SCRIPT_RENDERER Pashute_RenderPortraitPanic
    db "Waaaaaaaa!\r"
    db "They found me!"
    SCRIPT_WAIT
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "But it doesn't\r"
    db "scare me!"
    SCRIPT_WAIT
    db "I'm Pashute, a\r"
    db "priest here!"
    SCRIPT_WAIT
    db "I will not run,\r"
    db "or hide!"
    SCRIPT_WAIT
    SCRIPT_RENDERER Pashute_RenderPortraitShocked
    db "... ... ... ...\r"
    db "Huh? ... ... ..."
    SCRIPT_WAIT
    db "Aren't you going\r"
    db "to attack me?"
    SCRIPT_WAIT
    db "Like BOOM! or\r"
    db "Aaaargh! or huh?"
    SCRIPT_WAIT
    db "... ... What?\r"
    db "Came to help?"
    SCRIPT_WAIT
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "I see. I guess\r"
    db "I took it wrong."
    SCRIPT_WAIT
    db "You don't look\r"
    db "bad, anyway."
    SCRIPT_WAIT
    db "Going to ask me\r"
    db "to support?"
    SCRIPT_WAIT
    db "Woo hooo!\r"
    db "I mean. AHEM!"
    SCRIPT_WAIT
    db "I don't like to\r"
    db "fight bat..."
    SCRIPT_WAIT
    SCRIPT_RENDERER Pashute_RenderPortraitPanic
    db "I'm not a weak\r"
    db "baby or anything"
    SCRIPT_WAIT
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "....AHEM!\r"
    db "Anyways."
    SCRIPT_WAIT
    db "I'll go\r"
    db "down now"
    SCRIPT_WAIT
    db "to revive\r"
    db "the shrine."
    SCRIPT_WAIT
    db "When you collect\r"
    db "enough saucer"
    SCRIPT_WAIT
    db "stone fragments\r"
    db "to make a saucer"
    SCRIPT_WAIT
    db "stone, you can\r"
    db "seal certain"
    SCRIPT_WAIT
    db "monsters. After,\r"
    db "you seal them,"
    SCRIPT_WAIT
    db "bring one saucer\r"
    db "stone to the"
    SCRIPT_WAIT
    db "shrine and I'll\r"
    db "regenerate them."
    SCRIPT_WAIT
    db "Then they will\r"
    db "undoubtedly"
    SCRIPT_WAIT
    db "help you.\r"
    db "Easy to seal"
    SCRIPT_WAIT
    db "monsters! Just\r"
    db "touch an"
    SCRIPT_WAIT
    db "unconscious one\r"
    db "after completing"
    SCRIPT_WAIT
    db "a saucer stone.\r"
    db "I don't know"
    SCRIPT_WAIT
    db "which monster\r"
    db "you can seal, or"
    SCRIPT_WAIT
    db "where they are.\r"
    db "Observe the"
    SCRIPT_WAIT
    db "monster well,\r"
    db "then challenge"
    SCRIPT_WAIT
    db "them. They are\r"
    db "knocked out when"
    SCRIPT_WAIT
    db "defeated.\r"
    db "That's the key."
    SCRIPT_WAIT
    db "I will go back.\r"
    db "I await the day"
    SCRIPT_WAIT
    db "we meet again!"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=$d0e0, .Value=$01
    SCRIPT_WRITE_WRAM .Addr=wToamunaState, .Value=TOAMUNA_STATE_PASHUTE
    SCRIPT_WRITE_WRAM .Addr=wPashuteState, .Value=$01
    SCRIPT_END

PashuteGreetingCycle:
    SCRIPT_FAR_CALL Pashute_LoadShrineScene
    SCRIPT_CYCLE .Count=4
    SCRIPT_JUMP_TABLE wCycleCounter, PashuteGreeting1, PashuteGreeting2, PashuteGreeting3, PashuteGreeting4

PashuteGreeting1:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Welcome to the\r"
    db "Monster Shrine."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteMenu

PashuteGreeting2:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Hello!\r"
    db "Welcome!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteMenu

PashuteGreeting3:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Welcome to the\r"
    db "Monster Shrine."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteMenu

PashuteGreeting4:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Well, well\r"
    db "Good to see you."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteMenu

PashuteGreetReturning:
    SCRIPT_FAR_CALL Pashute_LoadShrineScene
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Oh, yes. I heard\r"
    db "that there's a"
    SCRIPT_WAIT
    db "new building\r"
    db "near here. That"
    SCRIPT_WAIT
    db "is the Monster\r"
    db "Checkroom. Have"
    SCRIPT_WAIT
    db "you been there?\r"
    db "They check your"
    SCRIPT_WAIT
    db "monsters for you\r"
    db "Monster"
    SCRIPT_WAIT
    db "handling should\r"
    db "be a lot easier"
    SCRIPT_WAIT
    db "now. You should\r"
    db "go sometime!"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wPashuteState, .Value=$01
    SCRIPT_GOTO .Target=PashuteMenu

PashuteGreetProgress:
    SCRIPT_FAR_CALL Pashute_LoadShrineScene
    SCRIPT_RENDERER Pashute_RenderPortraitShocked
    db "Oh! Well,"
    SCRIPT_WAIT
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Thank you\r"
    db "for helping us."
    SCRIPT_WAIT
    db "We were lucky\r"
    db "you were around."
    SCRIPT_WAIT
    db "I'm happy. I\r"
    db "can help you out"
    SCRIPT_WAIT
    db "Oh, I heard\r"
    db "they've built"
    SCRIPT_WAIT
    db "another building\r"
    db "near here. That"
    SCRIPT_WAIT
    db "is the Stage\r"
    db "Studio. You been"
    SCRIPT_WAIT
    db "there? You can\r"
    db "make your own"
    SCRIPT_WAIT
    db "stages, then\r"
    db "share them with"
    SCRIPT_WAIT
    db "your pals using\r"
    db "Link Cables."
    SCRIPT_WAIT
    db "Visit there."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wPashuteState, .Value=$01
    SCRIPT_GOTO .Target=PashuteMenu

PashuteGameDone:
    SCRIPT_FAR_CALL Pashute_LoadShrineScene
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Hello! How are\r"
    db "doing? I heard"
    SCRIPT_WAIT
    db "that you cleared\r"
    db "all the stages."
    SCRIPT_WAIT
    db "Your abilities\r"
    db "never cease to"
    SCRIPT_WAIT
    db "amaze me, but\r"
    db "there are many"
    SCRIPT_WAIT
    db "other ways to\r"
    db "enjoy this tower"
    SCRIPT_WAIT
    db "Play, play,\r"
    db "and play more!"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wPashuteState, .Value=$01
    SCRIPT_GOTO .Target=PashuteMenu

PashuteMenu:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Well, then."
    SCRIPT_WAIT
    db "How can I\r"
    db "help you?"
    SCRIPT_FAR_CALL Pashute_ShowMenu
    SCRIPT_FAR_CALL Pashute_LoadShrineTilemap
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE wMainMenuResult, PashuteStone, PashuteAsk, PashuteLeave

PashuteContinue:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Anything\r"
    db "else you need?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL ShowYesNoMenu
    SCRIPT_JUMP_TABLE wYNResult, PashuteMenu, PashuteNoContinue

PashuteNoContinue:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "I see."
    SCRIPT_WAIT
    db "Well, I await\r"
    db "your return."
    SCRIPT_WAIT
    SCRIPT_END

PashuteStone:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Regenerating a\r"
    db "saucer stone?"
    SCRIPT_WAIT
    SCRIPT_IF_EQ .Addr=$d0e1, .Value=$01, .Target=PashuteStoneCheck
    SCRIPT_IF_EQ .Addr=wDisplayMonster, .Value=$ff, .Target=PashuteStoneCheck
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "If the new\r"
    db "monster differs"
    SCRIPT_WAIT
    db "from the current\r"
    db "one, the loaded"
    SCRIPT_WAIT
    db "one will be\r"
    db "replaced, okay?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL ShowYesNoMenu
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$00, .Target=PashuteStoneCheck
    SCRIPT_RENDERER Pashute_RenderPortraitPanic
    db "Until recently,"
    SCRIPT_WAIT
    db "there was a\r"
    db "place to check"
    SCRIPT_WAIT
    db "your monster.\r"
    db "Too bad it's"
    SCRIPT_WAIT
    db "gone. Please\r"
    db "come again."
    SCRIPT_WAIT
    SCRIPT_END

PashuteStoneCheck:
    SCRIPT_IF_NEQ .Addr=$cfda, .Value=$00, .Target=PashuteStoneReady
    SCRIPT_IF_NEQ .Addr=$cfdb, .Value=$00, .Target=PashuteStoneReady
    SCRIPT_IF_NEQ .Addr=$cfdc, .Value=$00, .Target=PashuteStoneReady
    SCRIPT_IF_NEQ .Addr=$cfdd, .Value=$00, .Target=PashuteStoneReady
    SCRIPT_IF_NEQ .Addr=$cfde, .Value=$00, .Target=PashuteStoneReady
    SCRIPT_IF_NEQ .Addr=$cfdf, .Value=$00, .Target=PashuteStoneReady
    SCRIPT_IF_NEQ .Addr=$cfe0, .Value=$00, .Target=PashuteStoneReady
    SCRIPT_RENDERER Pashute_RenderPortraitPanic
    db "But you"
    SCRIPT_WAIT
    db "don't have any\r"
    db "saucer stones to"
    SCRIPT_WAIT
    db "regenerate. Come\r"
    db "after you seal"
    SCRIPT_WAIT
    db "a monster in a\r"
    db "saucer stone."
    SCRIPT_WAIT
    SCRIPT_END

PashuteStoneReady:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Then...\r"
    db "please choose"
    SCRIPT_WAIT
    db "saucer stone\r"
    db "to regenerate."
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL ShowMonsterDiscStoneSelect
    SCRIPT_FAR_CALL Pashute_LoadShrineTilemap
    SCRIPT_ANCHOR
    SCRIPT_IF_EQ .Addr=$cfbb, .Value=$07, .Target=PashuteContinue
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Starting the\r"
    db "process."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL Script_FadeOutPortrait
    SCRIPT_FAR_CALL ShowRegeneratedMonster
    SCRIPT_FAR_CALL Pashute_LoadShrineScene
    SCRIPT_IF_EQ .Addr=$d0e1, .Value=$01, .Target=PashuteRegenSetup
    SCRIPT_FAR_CALL Pashute_ResetRosterKeepNew
    SCRIPT_GOTO .Target=PashuteRegenPick

PashuteRegenSetup:
    SCRIPT_FAR_CALL Pashute_AddFiveMonsterUses

PashuteRegenPick:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Regeneration\r"
    db "is complete."
    SCRIPT_WAIT
    db "Let's look at\r"
    db "the new monster."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL Script_FadeOutPortrait
    SCRIPT_FAR_CALL ShowMonsterDetailScreen
    SCRIPT_FAR_CALL Pashute_LoadShrineScene
    SCRIPT_JUMP_TABLE $cfbb, \
        PashuteTiger, \
        PashuteMocchi, \
        PashuteHare, \
        PashuteGali, \
        PashuteGolem, \
        PashuteSuezo, \
        PashutePhenix

PashuteTiger:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "This is Tiger,\r"
    db "a cool monster."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteRegenConfirm

PashuteMocchi:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "This is Mocchi,\r"
    db "a cute monster."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteRegenConfirm

PashuteHare:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "This is Hare,\r"
    db "a fast monster."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteRegenConfirm

PashuteGali:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "It's Gali, a\r"
    db "mystery monster."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteRegenConfirm

PashuteGolem:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "It's Golem, a\r"
    db "powerful monster"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteRegenConfirm

PashuteSuezo:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "This is Suezo,\r"
    db "a funny monster"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteRegenConfirm

PashutePhenix:
    SCRIPT_RENDERER Pashute_RenderPortraitShocked
    db "Whoa! Th...this!\r"
    db "No way!...Dang!"
    SCRIPT_WAIT
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db " . . Ahem . . .\r"
    db "Sorry about that"
    SCRIPT_WAIT
    SCRIPT_RENDERER Pashute_RenderPortraitShocked
    db "This is Phenix!\r"
    db "A wonder monster"
    SCRIPT_WAIT

PashuteRegenConfirm:
    SCRIPT_IF_EQ .Addr=$d0e1, .Value=$01, .Target=PashuteRegenTake
    SCRIPT_FAR_CALL Pashute_IsReplacingActiveMonster
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$00, .Target=PashuteRegenDoNow
    SCRIPT_IF_EQ .Addr=wDisplayMonster, .Value=$ff, .Target=PashuteRegenDoNow
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Then I will\r"
    db "replace "
    SCRIPT_INDEXED_STR .Addr=wDisplayMonster
    db "."
    SCRIPT_WAIT
    db "You now have"
    SCRIPT_WAIT
    db "the newborn\r"
    SCRIPT_INDEXED_STR .Addr=$cfbb
    db "."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL Pashute_SetReplaceTargetActive
    SCRIPT_GOTO .Target=PashuteRegenDone

PashuteRegenDoNow:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Now I will\r"
    db "give you"
    SCRIPT_WAIT
    db "the newborn\r"
    db "monster."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL Pashute_SetReplaceTargetActive
    SCRIPT_GOTO .Target=PashuteRegenDone

PashuteRegenTake:
    SCRIPT_FAR_CALL Pashute_GetActiveMonsterUses
    SCRIPT_IF_NEQ .Addr=wYNResult, .Value=$05, .Target=PashuteRegenNow
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Will you take\r"
    db "the newborn now?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL ShowYesNoMenu
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=PashuteRegenPlace
    SCRIPT_IF_EQ .Addr=wDisplayMonster, .Value=$ff, .Target=PashuteRegenDoNow2
    db "Then let's put\r"
    db "this "
    SCRIPT_INDEXED_STR .Addr=wDisplayMonster
    SCRIPT_WAIT
    db "in the Monster\r"
    db "Checkroom."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL Pashute_SetReplaceTargetActive
    SCRIPT_GOTO .Target=PashuteRegenDone

PashuteRegenDoNow2:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Now I will\r"
    db "give you"
    SCRIPT_WAIT
    db "the newborn\r"
    db "monster."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL Pashute_SetReplaceTargetActive
    SCRIPT_GOTO .Target=PashuteRegenDone

PashuteRegenPlace:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Then let's put\r"
    db "this "
    SCRIPT_INDEXED_STR .Addr=$cfbb
    SCRIPT_WAIT
    db "in the Monster\r"
    db "Checkroom."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteRegenDone

PashuteRegenNow:
    SCRIPT_FAR_CALL Pashute_IsReplacingActiveMonster
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$00, .Target=PashuteRegenNow2
    db "Now "
    SCRIPT_INDEXED_STR .Addr=$cfbb
    db " in the\r"
    db "Checkroom has"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL Pashute_GetMonsterUsesDecimal
    SCRIPT_DECIMAL .Addr=wYNResult
    db " times of\r"
    db "usable moves."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteRegenDone

PashuteRegenNow2:
    db "Now "
    SCRIPT_INDEXED_STR .Addr=$cfbb
    db "\r"
    db "you carry"
    SCRIPT_WAIT
    db "has "
    SCRIPT_FAR_CALL Pashute_GetMonsterUsesDecimal
    SCRIPT_DECIMAL .Addr=wYNResult
    db " times of\r"
    db "usable moves."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteRegenDone

PashuteRegenDone:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "We are all done.\r"
    db "Please take"
    SCRIPT_WAIT
    db "good care of\r"
    db "the monsters."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteContinue

PashuteAsk:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "What shall\r"
    db "I explain?"
    SCRIPT_FAR_CALL Pashute_ShowExplainSubMenu
    SCRIPT_FAR_CALL Pashute_LoadShrineTilemap
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE wSubMenuCursor, PashuteAskShrineStone, PashuteAskMonster
    db "'J"

PashuteLeave:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Come back again.\r"
    db "I'll be waiting."
    SCRIPT_WAIT
    SCRIPT_END

PashuteAskShrineStone:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Hello.\r"
    db "This Shrine"
    SCRIPT_WAIT
    db "regenerates\r"
    db "monsters from"
    SCRIPT_WAIT
    db "saucer stones.\r"
    db "Find the hidden"
    SCRIPT_WAIT
    db "fragments in the\r"
    db "tower and when"
    SCRIPT_WAIT
    db "you collect 4,\r"
    db "bring them here."
    SCRIPT_WAIT
    db "A saucer stone\r"
    db "will be made."
    SCRIPT_WAIT
    db "Seal monsters in\r"
    db "the stone to"
    SCRIPT_WAIT
    db "regenerate them.\r"
    db "Okay?"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteAsk

PashuteAskMonster:
    SCRIPT_RENDERER Pashute_RenderPortraitNeutral
    db "Let me explain\r"
    db "about monsters."
    SCRIPT_WAIT
    db "Good monsters\r"
    db "lived as"
    SCRIPT_WAIT
    db "guardians of\r"
    db "the legendary"
    SCRIPT_WAIT
    db "power before\r"
    db "Nada's invasion."
    SCRIPT_WAIT
    db "Now there are\r"
    db "Bad monsters"
    SCRIPT_WAIT
    db "living in the\r"
    db "tower. They have"
    SCRIPT_WAIT
    db "been regenerated\r"
    db "by Nada. Some of"
    SCRIPT_WAIT
    db "them can be good\r"
    db "again by sealing"
    SCRIPT_WAIT
    db "them in the\r"
    db "saucer stones."
    SCRIPT_WAIT
    db "Knock them out\r"
    db "and seal them"
    SCRIPT_WAIT
    db "when they are\r"
    db "unconscious."
    SCRIPT_WAIT
    db "Think right.\r"
    db "Take your chance"
    SCRIPT_WAIT
    db "with care, and\r"
    db "you will gain"
    SCRIPT_WAIT
    db "reliable allies!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=PashuteAsk
