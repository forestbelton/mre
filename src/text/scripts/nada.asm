; Nada (final tower boss).
;
; References her henchmen — "I heard about you from Rafaga" — and
; expects the player to have defeated them. She's the tower's
; antagonist, the priest who corrupted it (per Toamuna's intro
; text: "a priest named Nada came here, and this tower became
; full of Baddies").
;
; Note: the literal string "Zan" (her monster per game lore) does
; not appear in the ROM as ASCII — likely encoded as an indexed
; glyph via the $11 INDEXED_STR opcode the engine uses for monster
; names elsewhere.
;
; Carved out of analyzed.asm via map.json; see docs/text_engine.md
; for the bytecode reference. Initial dump produced by
; tools/script_disasm.py — hand-curate freely; the extractor's
; append-only rule on non-auto-managed files preserves your edits.

INCLUDE "hardware.inc"

INCLUDE "text.inc"
INCLUDE "sound_ids.inc"


SECTION "analyzed_07cd66", ROMX[$4d66], BANK[$1f]

Func_1f_4d66:
	ld hl, wBgPalettes
	ld de, $0000
	call Func_1f_4d82
	ld hl, wObjPalettes
	ld de, $0000
	call Func_1f_4d82
	xor a
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	jp WaitForNextFrame
Func_1f_4d82:
	ld c, $18
.loop:
	ld [hl], e
	inc hl
	ld [hl], d
	inc hl
	dec c
	jr nz, .loop
	ret
Func_1f_4d8c:
	ld a, $00
	ld [$d611], a
	ld hl, NadaScript
	jp ScriptDispatcherEnterAfterCall
Nada_ShowScene:
	call Func_00_0822
	call HideAllSprites
	call Func_00_3971
	ld a, $00
	ld [rVBK], a
	ld a, $1c
	ld hl, $4000
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld a, $01
	ld [rVBK], a
	ld a, $1c
	ld hl, $5800
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld hl, $7080
	ld a, $1c
	ld de, $9800
	call BankMapCopyA
	call Nada_RenderPortrait
	call HideUnusedOamSprites
	ld a, $1c
	ld hl, $7000
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, $1c
	ld hl, $7040
	ld de, wObjPalettes
	ld bc, $0030
	call BankCopy
	push af
	ld a, SOUND_BGM_RivalEncounter
	call PlaySoundTracked
	pop af
	call ShowPortraitTransition
	ret
Nada_ShowSnapReaction:
	call Func_1f_4d66
	call HideAllSprites
	call Func_00_3971
	ld a, $00
	ld [rVBK], a
	ld a, $1c
	ld hl, $4000
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld a, $01
	ld [rVBK], a
	ld a, $1c
	ld hl, $5800
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld hl, $7080
	ld a, $1c
	ld de, $9800
	call BankMapCopyA
	call Nada_RenderPortrait
	call HideUnusedOamSprites
	ld a, $1c
	ld hl, $7000
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, $1c
	ld hl, $7040
	ld de, wObjPalettes
	ld bc, $0030
	call BankCopy
	xor a
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	call WaitForNextFrame
	ret
Nada_ShowRageScene:
	call Func_1f_4d66
	call HideAllSprites
	call Func_00_3971
	ld a, $00
	ld [rVBK], a
	ld a, $1c
	ld hl, $4000
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld a, $01
	ld [rVBK], a
	ld a, $1f
	ld hl, $6607
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld hl, $7e07
	ld a, $1f
	ld de, $9800
	call BankMapCopyA
	call NadaPortraitInit
	call HideUnusedOamSprites
	ld a, $1c
	ld hl, $7000
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, $1c
	ld hl, $7040
	ld de, wObjPalettes
	ld bc, $0030
	call BankCopy
	call Func_1f_41da
	call Func_1f_41e6
	xor a
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	call WaitForNextFrame
	ret
Nada_ShowMonsterPortrait:
	call Nada_LoadMonsterTiles
	call Func_1f_41e6
	jp ScriptWaitForBgSwap

Nada_ShowMonsterPortrait2:
	call Nada_LoadMonsterTiles
	jp ScriptWaitForObjSwap

Nada_LoadMonsterTiles:
	ld a, $1c
	ld hl, $7000
	ld de, $c181
	ld bc, $0030
	call BankCopy
	ld de, $c131
	ld hl, $c1b1
	ld c, $10
	call CopyDEtoHL
	ld a, $1c
	ld hl, $7040
	ld de, $c1c1
	ld bc, $0030
	call BankCopy
	ld de, $c171
	ld hl, $c1f1
	ld c, $10
	call CopyDEtoHL
	ret
Nada_RenderPortrait:
	ld a, $14
	ld [wRendererAddr], a
	ld a, $4f
	ld [$d61f], a
	ld a, $1f
	ld [wRendererBank], a
	ld a, $1c
	ld [wDrawBank], a
	call Nada_AnimatePortrait
	call Func_1f_4fb2
	ret
Nada_RenderPortraitAngry:
	ld a, $2f
	ld [wRendererAddr], a
	ld a, $4f
	ld [$d61f], a
	ld a, $1f
	ld [wRendererBank], a
	ld a, $1c
	ld [wDrawBank], a
	ld hl, Nada_mouth_angry
	ld a, $1c
	ld de, $986c
	call BankMapCopyA
	ld hl, Nada_face_angry
	ld bc, $1360
	call DrawMetasprite
	call Func_1f_4fb2
	ret
Nada_AnimatePortrait:
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
	ld hl, Nada_mouth_frame0
	ld a, $1c
	ld de, $986c
	call BankMapCopyA
	ld hl, Nada_face_frame0
	ld bc, $1360
	call DrawMetasprite
	ret
.frame1:
	ld hl, Nada_mouth_frame1
	ld a, $1c
	ld de, $986c
	call BankMapCopyA
	ld hl, Nada_face_frame1
	ld bc, $1360
	call DrawMetasprite
	ret
.frame2:
	ld hl, Nada_mouth_frame2
	ld a, $1c
	ld de, $986c
	call BankMapCopyA
	ld hl, Nada_face_frame2
	ld bc, $1360
	call DrawMetasprite
	ret
Func_1f_4fb2:
	ld hl, $d611
	ld a, [hl]
	or a
	jr z, .clamp
	cp $ff
	jr z, .clamp
	inc a
	ld [hl], a
.clamp:
	srl a
	cp $1b
	jr c, .dispatch
	ld a, $1a
.dispatch:
	ld hl, $4fd6
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp hl

Data_1f_4fd6:
	db $0e, $50, $0e, $50, $0e, $50, $23, $50, $23, $50, $23, $50, $38, $50, $38, $50
	db $38, $50, $4d, $50, $4d, $50, $4d, $50, $62, $50, $62, $50, $62, $50, $77, $50
	db $77, $50, $77, $50, $8c, $50, $8c, $50, $8c, $50, $77, $50, $77, $50, $77, $50
	db $62, $50, $62, $50, $62, $50

SECTION "Nada script", ROMX

NadaScript:
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$01, .Target=.NadaVictory
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$02, .Target=.NadaDefeat
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    SCRIPT_FAR_CALL Nada_ShowScene
    SCRIPT_RENDERER Nada_RenderPortrait
    db "Wow. It took you\r"
    db "a while. I heard"
    SCRIPT_WAIT
    db "about you from\r"
    db "Rafaga. He never"
    SCRIPT_WAIT
    db "thought you'd\r"
    db "make it up here."
    SCRIPT_WAIT
    db "Those kids are\r"
    db "useless. One"
    SCRIPT_WAIT
    db "adventurer\r"
    db "makes no"
    SCRIPT_WAIT
    db "difference. I'll\r"
    db "ask this old man"
    SCRIPT_WAIT
    db "where the mythic\r"
    db "monster is."
    SCRIPT_WAIT
    db "I'll take care\r"
    db "of you later."
    SCRIPT_WAIT
    db "Can you hush and\r"
    db "wait a sec?"
    SCRIPT_WAIT
    db "... ... ... ...\r"
    db "Now, old man."
    SCRIPT_WAIT
    db "Where is the\r"
    db "mythic monster?"
    SCRIPT_WAIT
    db "You built this,\r"
    db "you should know."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL Bodka_BuildTowerScene
    SCRIPT_RENDERER Bodka_RenderPortrait
    db "Hm, I don't know"
    SCRIPT_WAIT
    db "Ask the tower."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL Nada_ShowSnapReaction
    SCRIPT_RENDERER Nada_RenderPortraitAngry
    db "!!\r"
    db "SNAP!"
    SCRIPT_WRITE_WRAM .Addr=$d611, .Value=$01
    SCRIPT_WAIT
    db "You hear that?!\r"
    db "I just snapped!"
    SCRIPT_WAIT
    db "Tell me and I'll\r"
    db "spare your life!"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL Bodka_BuildTowerScene
    SCRIPT_RENDERER Bodka_RenderPortrait
    db "Heh! I don't\r"
    db "think so."
    SCRIPT_WAIT
    db "I'm dead whether\r"
    db "or not I tell."
    SCRIPT_WAIT
    db "Your lies don't\r"
    db "fool me."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL Nada_ShowSnapReaction
    SCRIPT_RENDERER Nada_RenderPortraitAngry
    db "!!\r"
    db "SNAP, SNAP!"
    SCRIPT_WAIT
    db "Can't you hear\r"
    db "me snapping?"
    SCRIPT_WAIT
    db "Don't make me\r"
    db "any angrier!"
    SCRIPT_WAIT
    SCRIPT_FAR_CALL Bodka_BuildTowerScene
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "Sorry, but this\r"
    db "is how it goes."
    SCRIPT_WAIT
    db "Better get out!\r"
    db "The place will"
    SCRIPT_WAIT
    db "be gone soon."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL Nada_ShowRageScene
    db "!!!\r"
    db "SNAAAAAAAP!"
    SCRIPT_WAIT
    db "Fine!\r"
    db "Be that way!"
    SCRIPT_WAIT
    db "I'll let you\r"
    db "keep the legend."
    SCRIPT_WAIT
    db "I'll destroy\r"
    db "the legend!"
    SCRIPT_WAIT
    db "Everything will\r"
    db "be gone!"
    SCRIPT_WAIT
    db "You first! Let's\r"
    db "see what you got"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL Nada_ShowMonsterPortrait
    SCRIPT_FAR_CALL Nada_ShowMonsterPortrait2
    SCRIPT_REPEAT_CHAR .Count=90
    SCRIPT_END
.NadaVictory:
    SCRIPT_FAR_CALL Nada_ShowScene
    SCRIPT_RENDERER Nada_RenderPortraitAngry
    db "Unbelievable."
    SCRIPT_WAIT
    db "If I only had\r"
    db "the great power."
    SCRIPT_WAIT
    SCRIPT_FAR_CALL Bodka_BuildTowerScene
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "I didn't think\r"
    db "that this day"
    SCRIPT_WAIT
    db "would ever come."
    SCRIPT_WAIT
    db "I had given up\r"
    db "a long time ago."
    SCRIPT_WAIT
    db "Thank you! Thank\r"
    db "you very much!"
    SCRIPT_WAIT
    db "This room is the\r"
    db "highest in the"
    SCRIPT_WAIT
    db "tower. Many\r"
    db "people came here"
    SCRIPT_WAIT
    db "to get the\r"
    db "legendary power."
    SCRIPT_WAIT
    SCRIPT_RENDERER Bodka_RenderPortrait
    db "But just because\r"
    db "you got here"
    SCRIPT_WAIT
    db "doesn't mean\r"
    db "that you'll get"
    SCRIPT_WAIT
    db "the power. There\r"
    db "is a secret that"
    SCRIPT_WAIT
    db "Nada couldn't\r"
    db "even solve. The"
    SCRIPT_WAIT
    db "only hint I can\r"
    db "give is that"
    SCRIPT_WAIT
    SCRIPT_RENDERER Bodka_RenderPortraitAlt
    db "silver key you\r"
    db "picked up. That"
    SCRIPT_WAIT
    db "key is my token\r"
    db "of thanks."
    SCRIPT_WAIT
    db "You can get to\r"
    db "the basement"
    SCRIPT_WAIT
    db "using this key.\r"
    db "There is more"
    SCRIPT_WAIT
    db "than one\r"
    db "basement room."
    SCRIPT_WAIT
    db "But more than\r"
    db "one key too."
    SCRIPT_WAIT
    db "Search the tower\r"
    db "to find more."
    SCRIPT_WAIT
    db "I can't tell\r"
    db "you any more."
    SCRIPT_WAIT
    db "But it'll be fun\r"
    db "to see how far"
    SCRIPT_WAIT
    db "you can go. Now,\r"
    db "I'm going back"
    SCRIPT_WAIT
    db "to join everyone\r"
    db "else. This is a"
    SCRIPT_WAIT
    db "happy day. We're\r"
    db "going to"
    SCRIPT_WAIT
    db "celebrate! By\r"
    db "the way, I'm"
    SCRIPT_WAIT
    db "Bodka. I operate\r"
    db "the studio"
    SCRIPT_WAIT
    db "downstairs. Come\r"
    db "if you have the"
    SCRIPT_WAIT
    db "time. See ya!"
    SCRIPT_WAIT
    SCRIPT_WRITE_WRAM .Addr=wNajiMenuShown, .Value=$01
    SCRIPT_WRITE_WRAM .Addr=wRanchProgress, .Value=$04
    SCRIPT_WRITE_WRAM .Addr=wPashuteState, .Value=$03
    SCRIPT_WRITE_WRAM .Addr=wVerdeState, .Value=$03
    SCRIPT_END
.NadaDefeat:
    SCRIPT_FAR_CALL Nada_ShowScene
    SCRIPT_RENDERER Nada_RenderPortraitAngry
    db "No one beats me\r"
    db "when I'm serious"
    SCRIPT_WAIT
    db "You'll regret\r"
    db "fighting me!"
    SCRIPT_WAIT
    SCRIPT_RENDERER Nada_RenderPortrait
    db "After this, I'll\r"
    db "destroy the land"
    SCRIPT_WAIT
    SCRIPT_END
