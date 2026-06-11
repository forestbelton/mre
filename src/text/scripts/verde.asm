; Verde - monster checkroom.
;
; Verde is one of the townspeople who returned from the tower
; (Toamuna's D0DC=3 greeting: "Verde returned. Great! Thank you").
; She introduces herself as "the owner of the checkroom" — monster
; boarding for inactiv
;
;   VerdeEntry       $0614F5  D0E4 cascade; first-time intro is
;                             the long "I am Verde..." monologue
;                             referencing Naji as the referrer.
;
; The tail of the empty-state script ($6251A onward, "What do you
; want to do?" menu) is shared infrastructure also reachable from
; the Verde-present script.
;
; See docs/text_engine.md for the bytecode reference.

INCLUDE "game.inc"
INCLUDE "hardware.inc"
INCLUDE "text.inc"
INCLUDE "sound_ids.inc"

SECTION "Verde script functions", ROMX

CountCheckedInMonsters:
	ld hl, wMonsterUses
	ld c, $00
	ld b, $00
.loop:
	ld a, [hl+]
	or a
	jr z, .next
	ld a, c
	ld [wActiveMonster], a
	inc b
.next:
	inc c
	ld a, c
	cp $07
	jr nz, .loop
	ld a, b
	ld [wYNResult], a
	ret
Func_18_533c:
	ld hl, VerdeEntry
	call ScriptDispatcherEnterAfterCall
	jp LeaveTownBuilding
Verde_BuildPortraitScene:
	call Func_00_0822
	call HideAllSprites
	call Func_00_3971
	ld a, $01
	ld [rVBK], a
	ld a, $1b
	ld hl, $5c5d
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	call Verde_LoadBgMap
	call Verde_RenderPortrait
	call HideUnusedOamSprites
	ld a, $1b
	ld hl, $745d
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, $1b
	ld hl, $749d
	ld de, wObjPalettes
	ld bc, $0030
	call BankCopy
	xor a
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	call WaitForNextFrame
	push af
	ld a, SOUND_BGM_Verde
	call PlaySoundTracked
	pop af
	ret
Verde_BuildIntroScene:
	call Func_00_0822
	call HideAllSprites
	call Func_00_3971
	ld a, $01
	ld [rVBK], a
	ld a, $1b
	ld hl, $5c5d
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	call Verde_LoadBgMap
	call Verde_RenderPortrait
	call HideUnusedOamSprites
	ld a, $1b
	ld hl, $788e
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, $1b
	ld hl, $78ce
	ld de, wObjPalettes
	ld bc, $0030
	call BankCopy
	xor a
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	call WaitForNextFrame
	push af
	ld a, SOUND_BGM_Verde
	call PlaySoundTracked
	pop af
	ret
Verde_LoadBgMap:
	ld hl, $74dd
	ld a, $1b
	ld de, $9800
	call BankMapCopyA
	ret
Verde_RenderPortrait:
	ld a, $f7
	ld [wRendererAddr], a
	ld a, $53
	ld [$d61f], a
	ld a, $18
	ld [wRendererBank], a
	ld a, $1b
	ld [wDrawBank], a
	ld hl, Verde_face
	ld bc, $4435
	call DrawMetasprite
	ld hl, Verde_overalls
	ld bc, $502c
	call DrawMetasprite
	ld hl, Verde_base_patch
	ld a, $1b
	ld de, $98a5
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
	ld hl, Verde_eyes_frame0
	ld a, $1b
	ld de, $98a5
	call BankMapCopyA
	ld hl, Verde_head_frame0
	ld bc, $142d
	call DrawMetasprite
	ret
.frame1:
	ld hl, Verde_eyes_frame1
	ld a, $1b
	ld de, $98a5
	call BankMapCopyA
	ld hl, Verde_head_frame1
	ld bc, $142d
	call DrawMetasprite
	ret
.frame2:
	ld hl, Verde_eyes_frame2
	ld a, $1b
	ld de, $98a5
	call BankMapCopyA
	ld hl, Verde_head_frame2
	ld bc, $142d
	call DrawMetasprite
	ret
Verde_RenderPortraitSurprised:
	ld a, $7f
	ld [wRendererAddr], a
	ld a, $54
	ld [$d61f], a
	ld a, $18
	ld [wRendererBank], a
	ld a, $1b
	ld [wDrawBank], a
	ld hl, Verde_overalls
	ld bc, $502c
	call DrawMetasprite
	ld hl, Verde_eyes_surprised
	ld a, $1b
	ld de, $98a5
	call BankMapCopyA
	ld hl, Verde_face_surprised
	ld bc, $4435
	call DrawMetasprite
	ld hl, Verde_head_surprised
	ld bc, $142d
	call DrawMetasprite
	ret
Verde_RenderPortraitCalm:
	ld a, $ba
	ld [wRendererAddr], a
	ld a, $54
	ld [$d61f], a
	ld a, $18
	ld [wRendererBank], a
	ld a, $1b
	ld [wDrawBank], a
	ld hl, Verde_overalls
	ld bc, $502c
	call DrawMetasprite
	ld hl, Verde_eyes_sad
	ld a, $1b
	ld de, $98a5
	call BankMapCopyA
	ld hl, Verde_face_sad
	ld bc, $4435
	call DrawMetasprite
	ld hl, Verde_head_sad
	ld bc, $142d
	call DrawMetasprite
	ret

SECTION "Verde script", ROMX

VerdeEntry:
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    SCRIPT_IF_EQ .Addr=wVerdeState, .Value=$04, .Target=VerdeGreetCleared
    SCRIPT_IF_EQ .Addr=wVerdeState, .Value=$03, .Target=VerdeGreetSeen
    SCRIPT_IF_EQ .Addr=wVerdeState, .Value=$01, .Target=VerdeGreet
    SCRIPT_FAR_CALL Verde_BuildIntroScene
    SCRIPT_RENDERER Verde_RenderPortrait
    db "Oh?\r"
    db "Never seen you."
    SCRIPT_WAIT
    SCRIPT_RENDERER Verde_RenderPortraitSurprised
    db "What?\r"
    db "Came to help?"
    SCRIPT_WAIT
    SCRIPT_RENDERER Verde_RenderPortrait
    db "Hmm... I see.\r"
    db "Naji did, huh?"
    SCRIPT_WAIT
    db "Now, I get it.\r"
    db "You surprised me"
    SCRIPT_WAIT
    db "I am Verde, a\r"
    db "monster breeder"
    SCRIPT_WAIT
    SCRIPT_RENDERER Verde_RenderPortraitCalm
    db "I am the owner\r"
    db "of the checkroom"
    SCRIPT_WAIT
    SCRIPT_RENDERER Verde_RenderPortrait
    db "I'm here just\r"
    db "like the others"
    SCRIPT_WAIT
    SCRIPT_RENDERER Verde_RenderPortraitCalm
    db "Made it up here\r"
    db "with my energy"
    SCRIPT_WAIT
    db "it gets harder\r"
    db "as I climb up."
    SCRIPT_WAIT
    db "If this goes on\r"
    db "to the top,"
    SCRIPT_WAIT
    db "I'd be too tired\r"
    db "for anything."
    SCRIPT_WAIT
    db "So I thought\r"
    db "of what to do."
    SCRIPT_WAIT
    SCRIPT_RENDERER Verde_RenderPortrait
    db "You're amazing,\r"
    db "here in a flash."
    SCRIPT_WAIT
    db "No wonder Naji\r"
    db "trusts you."
    SCRIPT_WAIT
    db "So, I say, let's\r"
    db "help each other"
    SCRIPT_WAIT
    SCRIPT_RENDERER Verde_RenderPortraitCalm
    db "from here on.\r"
    db "But I'd be"
    SCRIPT_WAIT
    db "more trouble\r"
    db "than help."
    SCRIPT_WAIT
    SCRIPT_RENDERER Verde_RenderPortrait
    db "Instead, I'll be\r"
    db "a supporter."
    SCRIPT_WAIT
    db "I'll be cheering\r"
    db "you on!"
    SCRIPT_WAIT
    db "When you decide\r"
    db "to come down,"
    SCRIPT_WAIT
    db "come to the\r"
    db "checkroom."
    SCRIPT_WAIT
    db "I'm sure I can\r"
    db "help you then."
    SCRIPT_WAIT
    db "Well then,\r"
    db "Good luck!"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=$d0e1, .Value=$01
    SCRIPT_WRITE_WRAM .Addr=wToamunaState, .Value=TOAMUNA_STATE_VERDE
    SCRIPT_WRITE_WRAM .Addr=wNajiState, .Value=$02
    SCRIPT_WRITE_WRAM .Addr=wPashuteState, .Value=$02
    SCRIPT_WRITE_WRAM .Addr=wVerdeState, .Value=$01
    SCRIPT_END

VerdeGreet:
    SCRIPT_FAR_CALL Verde_BuildPortraitScene
    SCRIPT_CYCLE .Count=4
    SCRIPT_JUMP_TABLE wCycleCounter, VerdeGreetA, VerdeGreetB, VerdeGreetC, VerdeGreetD

VerdeGreetA:
    SCRIPT_RENDERER Verde_RenderPortrait
    db "Oh, hi!\r"
    db "How's it going?"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenu

VerdeGreetB:
    SCRIPT_RENDERER Verde_RenderPortrait
    db "Hello!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenu

VerdeGreetC:
    SCRIPT_RENDERER Verde_RenderPortrait
    db "Welcome!\r"
    db "I'm glad"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenu

VerdeGreetD:
    SCRIPT_RENDERER Verde_RenderPortrait
    db "Welcome!"
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenu

VerdeGreetSeen:
    SCRIPT_FAR_CALL Verde_BuildPortraitScene
    SCRIPT_RENDERER Verde_RenderPortrait
    db "You're here.\r"
    db "I thank you."
    SCRIPT_WAIT
    db "Thanks for\r"
    db "helping us!"
    SCRIPT_WAIT
    db "This place is\r"
    db "getting busy!"
    SCRIPT_WAIT
    db "Oh, by the way,\r"
    db "I hear that, the"
    SCRIPT_WAIT
    db "Stage Studio\r"
    db "behind the tower"
    SCRIPT_WAIT
    db "is open again."
    SCRIPT_WAIT
    db "You can link or\r"
    db "exchange with"
    SCRIPT_WAIT
    db "your pals there."
    SCRIPT_WAIT
    db "It'll be fun.\r"
    db "Go try it out!"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wVerdeState, .Value=$01
    SCRIPT_GOTO .Target=VerdeMenu

VerdeGreetCleared:
    SCRIPT_FAR_CALL Verde_BuildPortraitScene
    SCRIPT_RENDERER Verde_RenderPortrait
    db "Oh!\r"
    db "You're here!"
    SCRIPT_WAIT
    db "Naji told me\r"
    db "everything."
    SCRIPT_WAIT
    db "I'm excited\r"
    db "to take care of"
    SCRIPT_WAIT
    db "Phenix!"
    SCRIPT_WAIT
    db "I'm excited\r"
    db "as a breeder."
    SCRIPT_WAIT
    db "I'll take good\r"
    db "care of them,"
    SCRIPT_WAIT
    db "so bring\r"
    db "more of them."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wVerdeState, .Value=$01
    SCRIPT_GOTO .Target=VerdeMenu

VerdeMenu:
    SCRIPT_RENDERER Verde_RenderPortrait
    db "Let's see.\r"
    db "What can I"
    SCRIPT_WAIT
    db "do for you?"
    SCRIPT_FAR_CALL Verde_ShowMainMenu
    SCRIPT_FAR_CALL Verde_LoadBgMap
    SCRIPT_ANCHOR
    SCRIPT_JUMP_TABLE wMainMenuResult, VerdeRaise, VerdeRelease, VerdeSwitch, VerdeExplain, VerdeLeave

VerdeMenuLoop:
    SCRIPT_RENDERER Verde_RenderPortrait
    db "Do you want\r"
    db "something else?"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL ShowYesNoMenu
    SCRIPT_JUMP_TABLE wYNResult, VerdeMenu, VerdeLeave

VerdeRaise:
    SCRIPT_RENDERER Verde_RenderPortrait
    db "OK!\r"
    db "I'll take care"
    SCRIPT_WAIT
    db "of it!"
    SCRIPT_WAIT
    SCRIPT_IF_EQ .Addr=wDisplayMonster, .Value=$ff, .Target=VerdeRaiseFull
    SCRIPT_RENDERER Verde_RenderPortrait
    db "OK! It's "
    SCRIPT_INDEXED_STR .Addr=wDisplayMonster
    db ".\r"
    db "I got it."
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wDisplayMonster, .Value=$ff
    SCRIPT_GOTO .Target=VerdeMenuLoop

VerdeRaiseFull:
    db "Hm? Looks like\r"
    db "no monsters here"
    SCRIPT_WAIT
    db "You have to\r"
    db "have a monster,"
    SCRIPT_WAIT
    db "to leave at\r"
    db "the checkroom."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenuLoop

VerdeRelease:
    SCRIPT_RENDERER Verde_RenderPortrait
    db "OK!\r"
    db "You'll take"
    SCRIPT_WAIT
    db "a monster!"
    SCRIPT_WAIT
    db "Wait a minute.\r"
    db "Your monster is?"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL CountCheckedInMonsters
    SCRIPT_IF_NEQ .Addr=wYNResult, .Value=$00, .Target=VerdeReleaseYes
    SCRIPT_RENDERER Verde_RenderPortraitCalm
    db "Oh yes,\r"
    db "I have it here."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenuLoop

VerdeReleaseYes:
    SCRIPT_IF_NEQ .Addr=wYNResult, .Value=$01, .Target=VerdeReleasePick
    db "Yes! It's "
    SCRIPT_INDEXED_STR .Addr=$cfbb
    db ".\r"
    db "I have it here."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeReleaseThis

VerdeReleasePick:
    db "Oh yes,\r"
    db "I have it here."
    SCRIPT_WAIT
    db "So, which one\r"
    db "are you taking?"
    SCRIPT_FAR_CALL Verde_ShowReleaseMonsterSelect
    SCRIPT_FAR_CALL Verde_LoadBgMap
    SCRIPT_ANCHOR
    SCRIPT_IF_EQ .Addr=$cfbb, .Value=$07, .Target=VerdeMenuLoop

VerdeReleaseThis:
    db "This one, right?\r"
    db "It's healthy!"
    SCRIPT_WAIT
    db "Take good care\r"
    db "of it, okay?"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL Pashute_SetReplaceTargetActive
    SCRIPT_GOTO .Target=VerdeMenuLoop

VerdeSwitch:
    SCRIPT_FAR_CALL CountCheckedInMonsters
    SCRIPT_IF_EQ .Addr=wYNResult, .Value=$01, .Target=VerdeSwitchDone
    SCRIPT_RENDERER Verde_RenderPortrait
    db "OK! Switch of\r"
    db "monsters, right?"
    SCRIPT_WAIT
    db "Okay, choose the\r"
    db "next monster"
    SCRIPT_FAR_CALL Verde_ShowReleaseMonsterSelect
    SCRIPT_FAR_CALL Verde_LoadBgMap
    SCRIPT_ANCHOR
    SCRIPT_IF_EQ .Addr=$cfbb, .Value=$07, .Target=VerdeMenuLoop
    SCRIPT_GOTO .Target=VerdeReleaseThis

VerdeSwitchDone:
    SCRIPT_RENDERER Verde_RenderPortraitCalm
    db "Well.\r"
    db "What?"
    SCRIPT_WAIT
    db "I can't exchange\r"
    db "monsters if you"
    SCRIPT_WAIT
    db "don't have one\r"
    db "checked in."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenuLoop

VerdeExplain:
    SCRIPT_RENDERER Verde_RenderPortrait
    db "Let me explain."
    SCRIPT_WAIT
    db "This checkroom\r"
    db "is a great place"
    SCRIPT_WAIT
    db "to hold monsters\r"
    db "regenerated from"
    SCRIPT_WAIT
    db "a saucer stone!"
    SCRIPT_WAIT
    db "If you want to\r"
    db "carry more than"
    SCRIPT_WAIT
    db "one monster,\r"
    db "this will help"
    SCRIPT_WAIT
    db "you a lot!"
    SCRIPT_WAIT
    db "I'll keep\r"
    db "the monsters"
    SCRIPT_WAIT
    db "in good shape\r"
    db "because I'm a"
    SCRIPT_WAIT
    db "top breeder!"
    SCRIPT_WAIT
    db "That's all.\r"
    db "It's simple."
    SCRIPT_WAIT
    SCRIPT_GOTO .Target=VerdeMenuLoop

VerdeLeave:
    SCRIPT_RENDERER Verde_RenderPortrait
    db "OK!\r"
    db "That's it."
    SCRIPT_WAIT
    db "I'll take care\r"
    db "of the monsters."
    SCRIPT_WAIT
    db "Good luck!"
    SCRIPT_WAIT
    SCRIPT_END
