; The Cox flashback (bank $13): dialogue scripts, cutscene driver, and the
; scene's graphics -- a self-contained story sequence set in Cox's house.
;
; The player watches a series of flashback / memory scenes featuring
; Cox and his childhood friend Alf. CoxScript holds four SCRIPT_END
; sub-scripts back to back; each runs independently, dispatched by the
; engine (re-entered at the address after the preceding SCRIPT_END)
; when the corresponding story trigger fires:
;
;   $4C449  Cox/Alf flashback ("Wow, you were cool back then... It's
;           a promise between men!"). Two-speaker scene alternating
;           the Cox_RenderPortrait_AlfSpeaking / _CoxSpeaking renderers
;           for the left vs right bubble positions.
;   $46D5   Cox reminiscing solo ("Whew! I forgot just how much fun it
;           was...") — Cox_RenderPortrait_Reminiscing.
;   $473D   Cox "I'll go see old friends" — Cox_RenderPortrait_GoSeeFriends.
;   $47C3   Cox "Wait, I forgot" (short) — Cox_RenderPortrait_Note.
;
; Cox_PlayFlashback plays the four scripts with walking cutscenes between
; them, then types LetterFromCox onto the SOLOMON computer monitor and rolls
; the STAGE STAFF credits over the scrolling house scene, ending on "Fin".
;
; The flashbacks use textbox tilemap position $9C22 (vs the standard
; $9982 used by overworld NPCs), placing the dialog in a different
; on-screen region appropriate for a flashback/memory view.
;
; Graphics: the 256-tile sheet (OBJ character frames + the scene's BG-bank-1
; tiles) and its palettes are the PNG asset assets/cox/tiles.png; the CopyBgMap
; tilemaps and DrawMetasprite frames are structured at the end of this file.
; BG cells with attr bit 3 clear use the shared bank-$19 tileset (TextUiTiles).
;
; See docs/text_engine.md for the bytecode reference.

INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "text.inc"
INCLUDE "sound_ids.inc"

; The Cox flashback driver and its scene helpers. Cox_PlayFlashback
; (FAR_CALLed from gameplay.asm) plays the four flashback sub-scripts
; (CoxScript / CoxReminisceScript / CoxGoSeeFriendsScript / CoxNoteScript)
; in sequence, with walking cutscenes between each, then the letter + credits.
SECTION "Cox script functions", ROMX

DEF WINDOW_ON EQU LCDC_ON | LCDC_WIN_9C00 | LCDC_WIN_ON | LCDC_BG_9800 | LCDC_OBJ_16 | LCDC_OBJ_ON | LCDC_PRIO_ON
DEF WINDOW_OFF EQU LCDC_ON | LCDC_WIN_9C00 | LCDC_BG_9800 | LCDC_OBJ_16 | LCDC_OBJ_ON | LCDC_PRIO_ON

Cox_PlayFlashback:
	push af
	ld a, SOUND_BGM_39
	call PlaySoundTracked
	pop af
	call Cox_LoadFlashbackScene
	ld a, $01
	ld [$d61a], a
	ld a, WINDOW_ON
	ldh [rLCDC], a
	ld hl, CoxScript
	call ScriptDispatcherEnterAfterCall
	ld a, WINDOW_OFF
	ldh [rLCDC], a
	call Cox_CutsceneAlfWalksOff
	ld a, WINDOW_ON
	ldh [rLCDC], a
	ld hl, CoxReminisceScript
	call ScriptDispatcherEnterAfterCall
	ld a, WINDOW_OFF
	ldh [rLCDC], a
	call Cox_CutsceneCoxWalksToCenter
	ld a, WINDOW_ON
	ldh [rLCDC], a
	ld hl, CoxGoSeeFriendsScript
	call ScriptDispatcherEnterAfterCall
	ld a, WINDOW_OFF
	ldh [rLCDC], a
	call Cox_CutsceneLeaveAndReturn
	ld a, WINDOW_ON
	ldh [rLCDC], a
	ld hl, CoxNoteScript
	call ScriptDispatcherEnterAfterCall
	call Cox_LoadMonitorTextPalette
	push af
	ld a, SOUND_BGM_3a
	call PlaySoundTracked
	pop af
	ld a, $c7
	ldh [rLCDC], a
	call Cox_ShowLetterOnMonitor
	call Cox_PlayStaffRoll
	ret

Cox_LoadFlashbackScene:
	call FadePalettesToWhite
	ld a, $01
	ldh [rVBK], a
	ld hl, CoxFlashbackTiles
	ld de, $8000
	ld bc, $1000
	call VramCopy16
	xor a
	ld [$d61b], a
	ld [wRendererAddr], a
	ld [$d61f], a
	ld a, $00
	ldh [rVBK], a
	ld a, BANK(TextUiTiles)
	ld hl, TextUiTiles
	ld de, $8800
	ld bc, $1000
	call BankVramCopy
	ld hl, CoxHouseMap
	ld de, $9800
	call CopyBgMap
	ld hl, CoxTextWindowMap
	ld de, $9c00
	call CopyBgMap
	ld a, $07
	ldh [rWX], a
	ld a, $60
	ldh [rWY], a
	ld hl, CoxFlashbackBgPals
	call LoadBgPalettes
	ld hl, CoxFlashbackObjPals
	call LoadObjPalettes
	ret

Cox_CutsceneAlfWalksOff:
	ld hl, CoxFaceClearMap
	ld de, $9900
	call CopyBgMap
	call Cox_DrawCoxStandLeft
	call Cox_DrawAlf
	call Cox_DrawMonster
	call HideUnusedOamSprites
	ld bc, $3078
	ld d, $20
.down:
	call WaitForNextFrame
	ld a, $02
	inc b
	call SetSpritePairPosition
	call Cox_AnimAlfWalkDown
	dec d
	jr nz, .down
	ld d, $28
.left:
	call WaitForNextFrame
	ld a, $02
	dec c
	call SetSpritePairPosition
	call Cox_AnimAlfWalkLeft
	dec d
	jr nz, .left
	ld d, $70
.down2:
	call WaitForNextFrame
	ld a, $02
	inc b
	call SetSpritePairPosition
	call Cox_AnimAlfWalkDown
	dec d
	jr nz, .down2
	ld d, $5a
	call Cox_WaitDFrames
	ret

Cox_CutsceneCoxWalksToCenter:
	ld hl, CoxFaceClearMap
	ld de, $9900
	call CopyBgMap
	call Cox_DrawCoxStand
	call Cox_DrawAlfOffscreen
	call Cox_DrawMonster
	call HideUnusedOamSprites
	ld bc, $3088
	ld d, $20
.down:
	call WaitForNextFrame
	ld a, $00
	inc b
	call SetSpritePairPosition
	call Cox_AnimCoxWalkDown
	dec d
	jr nz, .down
	ld d, $38
.left:
	call WaitForNextFrame
	ld a, $00
	dec c
	call SetSpritePairPosition
	call Cox_AnimCoxWalkLeft
	dec d
	jr nz, .left
	ret

Cox_CutsceneLeaveAndReturn:
	ld hl, CoxFaceClearMap
	ld de, $9900
	call CopyBgMap
	call Cox_DrawCoxCenter
	call Cox_DrawAlfOffscreen
	call Cox_DrawMonster
	call HideUnusedOamSprites
	ld bc, $5050
	ld d, $10
.up:
	call WaitForNextFrame
	ld a, $00
	dec b
	call SetSpritePairPosition
	call Cox_AnimCoxWalkUp
	dec d
	jr nz, .up
	ld d, $08
.left:
	call WaitForNextFrame
	ld a, $00
	dec c
	call SetSpritePairPosition
	call Cox_AnimCoxWalkLeft
	dec d
	jr nz, .left
	push bc
	ld a, $00
	ld bc, $0608
	call SetSpritePairTileAttr
	ld d, $1e
	call Cox_WaitDFrames
	ld a, $04
	ld bc, $f0f0
	call SetSpritePairPosition
	pop bc
	ld d, $08
.right:
	call WaitForNextFrame
	ld a, $00
	inc c
	call SetSpritePairPosition
	call Cox_AnimCoxWalkRight
	dec d
	jr nz, .right
	ld d, $60
.down:
	call WaitForNextFrame
	ld a, $00
	inc b
	call SetSpritePairPosition
	call Cox_AnimCoxWalkDown
	dec d
	jr nz, .down
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	ld d, $b4
	call Cox_WaitDFrames
	ld d, $60
.up2:
	call WaitForNextFrame
	ld a, $00
	dec b
	call SetSpritePairPosition
	call Cox_AnimCoxWalkUp
	dec d
	jr nz, .up2
	ld d, $08
.right2:
	call WaitForNextFrame
	ld a, $00
	inc c
	call SetSpritePairPosition
	call Cox_AnimCoxWalkRight
	dec d
	jr nz, .right2
	ret
Cox_ShowLetterOnMonitor:
	ld a, $00
	ld bc, $f0f0
	call SetSpritePairPosition
	ld hl, CoxMonitorMap
	ld de, $9800
	call CopyBgMap
	call Cox_InitLetterCursor
	xor a
	ld [wUiTimer], a
	ld [$cfbc], a
	inc a
	ld [wUiState], a
.typeLoop:
	ld b, d
	ld d, $08
	call Cox_WaitDFrames
	ld d, b
	call Cox_TypeLetterChar
	call Cox_BlinkLetterCursor
	ld a, [wUiTimer]
	inc a
	ld [wUiTimer], a
	ld a, [wUiState]
	or a
	jr nz, .typeLoop
	call FadePalettesToBlack
	ret
Cox_PlayStaffRoll:
	call Cox_ClearBgTilemap
	call ResetScrollState
	xor a
	ld [$cfbc], a
	call FadeInPalettes
	ld de, $0258
.scrollLoop:
	call WaitForNextFrame
	call WaitForNextFrame
	push de
	call Cox_PrintStaffRollLine
	call Cox_ScrollStaffRoll
	pop de
	dec de
	ld a, e
	or d
	jr nz, .scrollLoop
	call ResetScrollState
	ld hl, CoxFinMap
	ld de, $9907
	call CopyBgMap
	ld d, $b4
	call Cox_WaitDFrames
	ld d, $78
	call Cox_WaitDFrames
	call FadePalettesToBlack
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	ret
Cox_ClearBgTilemap:
	xor a
	ldh [rVBK], a
	ld hl, $9800
	ld bc, $0400
	ld d, $fc
	call FillVram
	ld a, $01
	ldh [rVBK], a
	ld hl, $9800
	ld bc, $0400
	ld d, $0f
	call FillVram
	ret

Cox_RenderPortrait_AlfSpeaking:
	ld hl, AlfFaceMap
	ld de, $9900
	call CopyBgMap
	ld a, BANK(CoxSpriteStand)
	ld [wDrawBank], a
	call Cox_DrawCoxStandLeft
	call Cox_DrawAlf
	call Cox_DrawMonster
	ret

Cox_RenderPortrait_CoxSpeaking:
	ld hl, CoxFaceMap
	ld de, TILEMAP0_X0_Y8
	call CopyBgMap
	ld a, BANK(CoxSpriteStand)
	ld [wDrawBank], a
	call Cox_DrawCoxStandLeft
	call Cox_DrawAlf
	call Cox_DrawMonster
	ret

Cox_RenderPortrait_Reminiscing:
	ld hl, CoxFaceMap
	ld de, TILEMAP0_X0_Y8
	call CopyBgMap
	ld a, BANK(CoxSpriteStand)
	ld [wDrawBank], a
	call Cox_DrawCoxStand
	call Cox_DrawAlfOffscreen
	call Cox_DrawMonster
	ret

Cox_RenderPortrait_GoSeeFriends:
	ld hl, CoxFaceMap
	ld de, TILEMAP0_X0_Y8
	call CopyBgMap
	ld a, BANK(CoxSpriteStand)
	ld [wDrawBank], a
	call Cox_DrawCoxCenter
	call Cox_DrawAlfOffscreen
	call Cox_DrawMonster
	ret

Cox_RenderPortrait_Note:
	ld hl, CoxFaceMap
	ld de, TILEMAP0_X0_Y8
	call CopyBgMap
	ld a, BANK(CoxSpriteStand)
	ld [wDrawBank], a
	call Cox_DrawCoxAtDesk
	ret

Cox_DrawCoxStandLeft:
	ld hl, CoxSpriteStandLeft
	ld bc, $1008
	call DrawMetasprite
	ld a, $00
	ld bc, $3088
	call SetSpritePairPosition
	ret

Cox_DrawCoxStand:
	ld hl, CoxSpriteStand
	ld bc, $1008
	call DrawMetasprite
	ld a, $00
	ld bc, $3088
	call SetSpritePairPosition
	ret

Cox_DrawCoxCenter:
	ld hl, CoxSpriteStand
	ld bc, $1008
	call DrawMetasprite
	ld a, $00
	ld bc, $5050
	call SetSpritePairPosition
	ret

Cox_DrawCoxAtDesk:
	ld hl, CoxSpriteBack
	ld bc, $1008
	call DrawMetasprite
	ld a, $00
	ld bc, $4058
	call SetSpritePairPosition
	ret

Cox_DrawAlf:
	ld hl, AlfSpriteStandRight
	ld bc, $1008
	call DrawMetasprite
	ld a, $02
	ld bc, $3078
	call SetSpritePairPosition
	ret

Cox_DrawAlfOffscreen:
	ld hl, AlfSpriteStandRight
	ld bc, $1008
	call DrawMetasprite
	ld a, $02
	ld bc, $f0f0
	call SetSpritePairPosition
	ret

Cox_DrawMonster:
	ld hl, CoxMonsterSprite
	ld bc, $1008
	call DrawMetasprite
	ld a, $04
	ld bc, $3048
	call SetSpritePairPosition
	ret

AlfWalkDownTiles:
	db $16, $20, $16, $22

Cox_AnimAlfWalkDown:
	ld a, d
	rrca
	rrca
	rrca
	rrca
	and $03
	ld hl, AlfWalkDownTiles
	rst AddAToHL
	ld e, [hl]
	ld hl, $c00a
	ld a, e
	ld [hl+], a
	ld [hl], $09
	ld a, $03
	rst AddAToHL
	ld a, e
	add a, $08
	ld [hl+], a
	ld [hl], $09
	ret

AlfWalkLeftTiles:
	db $24, $26, $24, $26

Cox_AnimAlfWalkLeft:
	ld a, d
	rrca
	rrca
	rrca
	rrca
	and $03
	ld hl, AlfWalkLeftTiles
	rst AddAToHL
	ld e, [hl]
	ld hl, $c00a
	ld a, e
	ld [hl+], a
	ld [hl], $09
	ld a, $03
	rst AddAToHL
	ld a, e
	add a, $08
	ld [hl+], a
	ld [hl], $09
	ret

CoxWalkRightTiles:
	db $1a, $1c, $1a, $1c

Cox_AnimCoxWalkRight:
	ld hl, CoxWalkRightTiles
	ld a, d
	rrca
	rrca
	rrca
	rrca
	and $03
	call Cox_SetCoxSpriteTilesFlipped
	ret

CoxWalkLeftTiles:
	db $12, $14, $12, $14

Cox_AnimCoxWalkLeft:
	ld hl, CoxWalkLeftTiles
	ld a, d
	rrca
	rrca
	rrca
	rrca
	and $03
	call Cox_SetCoxSpriteTiles
	ret

CoxWalkDownTiles:
	db $00, $02, $00, $04

Cox_AnimCoxWalkDown:
	ld hl, CoxWalkDownTiles
	ld a, d
	rrca
	rrca
	rrca
	rrca
	and $03
	call Cox_SetCoxSpriteTiles
	ret

CoxWalkUpTiles:
	db $06, $10, $06, $18

Cox_AnimCoxWalkUp:
	ld hl, CoxWalkUpTiles
	ld a, d
	rrca
	rrca
	rrca
	rrca
	and $03
	cp $03
	jr z, .flipped
	call Cox_SetCoxSpriteTiles
	ret
.flipped:
	call Cox_SetCoxSpriteTilesFlipped
	ret
Cox_SetCoxSpriteTiles:
	rst AddAToHL
	ld e, [hl]
	ld hl, $c002
	ld a, e
	ld [hl+], a
	ld [hl], $08
	ld a, $03
	rst AddAToHL
	ld a, e
	add a, $08
	ld [hl+], a
	ld [hl], $08
	ret
Cox_SetCoxSpriteTilesFlipped:
	rst AddAToHL
	ld e, [hl]
	ld hl, $c002
	ld a, e
	ld [hl+], a
	ld [hl], $28
	ld a, $03
	rst AddAToHL
	ld a, e
	sub $08
	ld [hl+], a
	ld [hl], $28
	ret

CoxMonitorTextPalette:
	db $00, $00, $94, $52, $4a, $29, $ff, $7f

Cox_LoadMonitorTextPalette:
	ld hl, CoxMonitorTextPalette
	ld a, $07
	ld b, $01
	call LoadBgPalettesToSlot
	call WaitForPaletteFadeCgb
	ret
Cox_WaitDFrames:
	call WaitForNextFrame
	dec d
	jr nz, Cox_WaitDFrames
	ret

SECTION "Cox script", ROMX

CoxScript:
    SCRIPT_OPEN_TEXTBOX .Pos=TILEMAP1_X2_Y1, .Width=$10, .Height=$04
    SCRIPT_RENDERER Cox_RenderPortrait_AlfSpeaking
    db "Wow, you were\r"
    db "cool back then."
    SCRIPT_WAIT
    db "You don't look\r"
    db "so cool now."
    SCRIPT_WAIT
    SCRIPT_RENDERER Cox_RenderPortrait_CoxSpeaking
    db "Ugh...\r"
    db "That's harsh."
    SCRIPT_WAIT
    SCRIPT_RENDERER Cox_RenderPortrait_AlfSpeaking
    db "Cool! I want\r"
    db "adventure like"
    SCRIPT_WAIT
    db "that! Is that\r"
    db "tower there now?"
    SCRIPT_WAIT
    SCRIPT_RENDERER Cox_RenderPortrait_CoxSpeaking
    db "Of course, Alf."
    SCRIPT_WAIT
    db "You should go\r"
    db "there someday."
    SCRIPT_WAIT
    db "You'd have\r"
    db "a great time."
    SCRIPT_WAIT
    SCRIPT_RENDERER Cox_RenderPortrait_AlfSpeaking
    db "Hmmm...\r"
    db "After I grow up?"
    SCRIPT_WAIT
    db "Oh no! I want\r"
    db "to go there now!"
    SCRIPT_WAIT
    SCRIPT_RENDERER Cox_RenderPortrait_CoxSpeaking
    db "Whoa whoa whoa!\r"
    db "It's dangerous."
    SCRIPT_WAIT
    db "What happens if\r"
    db "you get lost?"
    SCRIPT_WAIT
    SCRIPT_RENDERER Cox_RenderPortrait_AlfSpeaking
    db "Gimme a break!"
    SCRIPT_WAIT
    db "You're the\r"
    db "one who's lost!"
    SCRIPT_WAIT
    SCRIPT_RENDERER Cox_RenderPortrait_CoxSpeaking
    db "Ugh...\r"
    db "Alf..."
    SCRIPT_WAIT
    db "You're harsh..."
    SCRIPT_WAIT
    SCRIPT_RENDERER Cox_RenderPortrait_AlfSpeaking
    db "Will you take me\r"
    db "when I'm grown?"
    SCRIPT_WAIT
    db "A promise 'tween"
    SCRIPT_WAIT
    db "men, okay? I'll\r"
    db "wait till then!"
    SCRIPT_WAIT
    SCRIPT_RENDERER Cox_RenderPortrait_CoxSpeaking
    db "Okay.\r"
    db "I promise."
    SCRIPT_WAIT
    db "It's a promise\r"
    db "between men!"
    SCRIPT_WAIT
    SCRIPT_RENDERER Cox_RenderPortrait_AlfSpeaking
    db "Okay! Now I'll\r"
    db "practice and"
    SCRIPT_WAIT
    db "become a\r"
    db "Battle Card"
    SCRIPT_WAIT
    db "Master! I'll\r"
    db "see you later!"
    SCRIPT_WAIT
    SCRIPT_END

; $46d5 — Cox reminiscing solo after the flashback ("Whew! I forgot...").
CoxReminisceScript:
    SCRIPT_RENDERER Cox_RenderPortrait_Reminiscing
    db "Whew! I forgot\r"
    db "just how much"
    SCRIPT_WAIT
    db "fun it was then.\r"
    db "Ah, memories!"
    SCRIPT_WAIT
    db "Thanks, Alf."
    SCRIPT_WAIT
    db "I wonder how\r"
    db "everyone is."
    SCRIPT_WAIT
    SCRIPT_END

; $473d — Cox decides to go see old friends.
CoxGoSeeFriendsScript:
    SCRIPT_RENDERER Cox_RenderPortrait_GoSeeFriends
    db "I know!"
    SCRIPT_WAIT
    db "I'll go see\r"
    db "old friends!"
    SCRIPT_WAIT
    db "I have to\r"
    db "refresh myself"
    SCRIPT_WAIT
    db "for Alf, anyway."
    SCRIPT_WAIT
    db "He'll get\r"
    db "mad if I don't"
    SCRIPT_WAIT
    db "know my way.\r"
    db "Okay, off I go!"
    SCRIPT_WAIT
    SCRIPT_END

; $47c3 — Cox remembers to leave a note ("Wait, I forgot").
CoxNoteScript:
    SCRIPT_RENDERER Cox_RenderPortrait_Note
    db "Wait, I forgot.\r"
    db "Withouta note,"
    SCRIPT_WAIT
    db "Nox will get\r"
    db "mad again."
    SCRIPT_WAIT
    SCRIPT_END

; The note Cox leaves for Nox. Not dispatched through the script engine:
; Cox_ShowLetterOnMonitor types it character-by-character onto the SOLOMON
; monitor screen (CoxMonitorMap) with a blinking cursor. \r = newline,
; SCRIPT_WAIT ($04) pauses then clears the page, SCRIPT_END ($ff) finishes.
LetterFromCox:
    db "Hello. I'm off \r"
    db "to the ruins.\r"
    db "I'm going to \r"
    db "Mt. Sekitoba.\r"
    db "If I'm not back\r"
    db "in 2 weeks, "
    SCRIPT_WAIT
    db "come and look \r"
    db "for me,okay? \r"
    db " \r"
    db " \r"
    db "         Cox"
    SCRIPT_END

; Staff-roll lines, one dw per 8-pixel scroll step (read by Cox_PrintStaffRollLine
; while the house scene scrolls); dw $0000 ends the list (blank lines from then on).
; $a5 prints as the katakana middle dot in the staff-roll font.
CoxStaffRollLines:
	dw .stageStaff, CoxStaffBlankLine, CoxStaffBlankLine, CoxStaffBlankLine
	dw .hMotoki, CoxStaffBlankLine
	dw .rShinada, CoxStaffBlankLine
	dw .yAbe, CoxStaffBlankLine
	dw .yTakaoka, CoxStaffBlankLine
	dw .jYamamoto, CoxStaffBlankLine
	dw .mHayashi, CoxStaffBlankLine
	dw .tTsutsui, CoxStaffBlankLine
	dw .tOhmori, CoxStaffBlankLine
	dw .mSuganuma, CoxStaffBlankLine
	dw .mNagaura, CoxStaffBlankLine
	dw .yUeda, CoxStaffBlankLine
	dw .tInamoto, CoxStaffBlankLine
	dw $0000
.stageStaff: db "STAGE STAFF", 0
.hMotoki:    db "H", $a5, "MOTOKI", 0
.rShinada:   db "R", $a5, "SHINADA", 0
.yAbe:       db "Y", $a5, "ABE", 0
.yTakaoka:   db "Y", $a5, "TAKAOKA", 0
.jYamamoto:  db "J", $a5, "YAMAMOTO", 0
.mHayashi:   db "M", $a5, "HAYASHI", 0
.tTsutsui:   db "T", $a5, "TSUTSUI", 0
.tOhmori:    db "T", $a5, "OHMORI", 0
.mSuganuma:  db "M", $a5, "SUGANUMA", 0
.mNagaura:   db "M", $a5, "NAGAURA", 0
.yUeda:      db "Y", $a5, "UEDA", 0
.tInamoto:   db "T", $a5, "INAMOTO", 0
CoxStaffBlankLine:
	db "           ", 0

Cox_PrintStaffRollLine:
	ldh a, [rSCY]
	ld b, a
	and $07
	ret nz
	ld a, b
	rrca
	rrca
	rrca
	add a, $12
	and $1f
	ld c, a
	ld a, [$cfbc]
	add a, a
	ld hl, CoxStaffRollLines
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, h
	cp $00
	jr nz, .advance
	ld hl, CoxStaffBlankLine
	jr .calcDest
.advance:
	ld a, [$cfbc]
	inc a
	ld [$cfbc], a
.calcDest:
	ld de, $9800
	ld a, c
	or a
	jr z, .indent
.rowLoop:
	ld a, $20
	rst AddAToDE
	dec c
	jr nz, .rowLoop
.indent:
	ld a, $02
	rst AddAToDE
.printLoop:
	ld a, [hl+]
	ld c, a
	or a
	jr z, .done
	ld a, e
	ld [wTextCursor], a
	ld a, d
	ld [$d617], a
	push hl
	push de
	FAR_CALL PrintCharacterAtCursor
	pop de
	pop hl
	inc de
	jr .printLoop
.done:
	ret
Cox_ScrollStaffRoll:
	ldh a, [rSCY]
	inc a
	ldh [rSCY], a
	ret
Cox_InitLetterCursor:
	ld de, $9862
	ld hl, LetterFromCox
	ret
Cox_TypeLetterChar:
	ld a, e
	ld [wTextCursor], a
	ld a, d
	ld [$d617], a
	ld a, [hl+]
	ld c, a
	cp $ff
	jr z, .end
	cp $0d
	jr z, .newline
	cp $04
	jr z, .pageBreak
	cp $40
	jr z, .noAdvance
	cp $de
	jr z, .noAdvance
	cp $df
	jr z, .noAdvance
	jr .print
.noAdvance:
	dec de
.print:
	push hl
	push de
	FAR_CALL PrintCharacterAtCursor
	pop de
	inc de
	pop hl
	ret

.newline:
	ld a, $40
	rst AddAToDE
	ld a, e
	and $e0
	add a, $02
	ld e, a
	ret
.pageBreak:
	dec hl
	ld a, [$cfbc]
	inc a
	ld [$cfbc], a
	cp $0d
	ret nz
	push hl
	ld hl, CoxMonitorMap
	ld de, $9800
	call CopyBgMap
	ld de, $9862
	pop hl
	inc hl
	xor a
	ld [$cfbc], a
	ret
.end:
	dec hl
	ld a, [$cfbc]
	inc a
	ld [$cfbc], a
	cp $0d
	ret nz
	xor a
	ld [wUiState], a
	ret
Cox_BlinkLetterCursor:
	push hl
	push de
	ld h, d
	ld l, e
	ld a, $20
	rst AddAToHL
	xor a
	ldh [rVBK], a
	ld bc, $0001
	ld a, [wUiTimer]
	and $01
	jr z, .off
	ld d, $ec
	jr .draw
.off:
	ld d, $fc
.draw:
	call FillVram
	dec hl
	ld a, $01
	ldh [rVBK], a
	ld bc, $0001
	ld d, $0f
	call FillVram
	pop de
	pop hl
	ret

; The flashback tile sheet: 256 tiles ($1000 bytes) -> VRAM bank 1 $8000
; (Cox_LoadFlashbackScene/VramCopy16). First half: the 16x16 OBJ frames listed
; below ($8000-$87ff). Second half: BG tiles -- the SOLOMON monitor, room props
; and the staff-roll/Fin lettering -- addressed as $8800-mode bank-1 cells (attr
; bit 3) by the maps below. Editable source: assets/cox/tiles.png (palettes
; embedded); the blank runs between the art are real ROM zeros, kept in the sheet.
CoxFlashbackTiles:
	INCBIN "assets/cox/tiles_bank0.2bpp"
	INCBIN "assets/cox/tiles_bank1.2bpp"

; 8 BG + 8 OBJ palettes -> wBgPalettes/wObjPalettes (split off the same
; assets/cox/tiles.png palette table; BG slot 7 is later replaced by
; CoxMonitorTextPalette for the letter scene).
CoxFlashbackBgPals:
	INCBIN "assets/cox/palette.bin", 0, 64
CoxFlashbackObjPals:
	INCBIN "assets/cox/palette.bin", 64, 64

; CopyBgMap 24 rows x 20 cols -> $9800: Cox's house interior (desk with the
; computer, bookshelves, two beds). 24 rows -- six below the visible screen --
; because the staff roll wrap-scrolls SCY over it. Cells with attr bit 3 clear
; take their tiles from the shared bank-$19 tileset (TextUiTiles).
CoxHouseMap:
	db 24, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/cox/house_idx.bin"
.attr:
	INCBIN "assets/cox/house_attr.bin"

; CopyBgMap 18x20 -> $9800: the "SOLOMON C59" computer monitor; LetterFromCox
; is typed onto its black screen by Cox_ShowLetterOnMonitor.
CoxMonitorMap:
	db 18, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/cox/monitor_idx.bin"
.attr:
	INCBIN "assets/cox/monitor_attr.bin"

; CopyBgMap 6x20 -> $9c00: the flashback textbox window frame (also drawn by
; DrawTextWindow in text/engine.asm when the alt-window flag [$d61a] is set).
CoxTextWindowMap:
	db 6, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/cox/window_idx.bin"
.attr:
	INCBIN "assets/cox/window_attr.bin"

; CopyBgMap 4x4 -> $9900: speaker face bubble, Cox (explorer hat).
CoxFaceMap:
	db 4, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/cox/face_cox_idx.bin"
.attr:
	INCBIN "assets/cox/face_cox_attr.bin"

; CopyBgMap 4x4 -> $9900: speaker face bubble, Alf (blue hood).
AlfFaceMap:
	db 4, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/cox/face_alf_idx.bin"
.attr:
	INCBIN "assets/cox/face_alf_attr.bin"

; CopyBgMap 4x4 -> $9900: erases the face bubble (restores the wall/floor cells).
CoxFaceClearMap:
	db 4, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/cox/face_clear_idx.bin"
.attr:
	INCBIN "assets/cox/face_clear_attr.bin"

; CopyBgMap 3x6 -> $9907: the closing "Fin" card.
CoxFinMap:
	db 3, 6
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/cox/fin_idx.bin"
.attr:
	INCBIN "assets/cox/fin_attr.bin"

; 16x16 character frames for DrawMetasprite: db count, then {Yoff, Xoff, tile,
; attr} per 8x16 OBJ. OBJ palette (attr low bits) 0 = Cox, 1 = Alf, 2 = the
; monster; attr bit 5 = X-flip, bit 3 = VRAM bank 1 (this sheet). The walk
; animations cycle the same frame pairs by poking OAM tile ids directly
; (Cox_SetCoxSpriteTiles / the *WalkTiles tables).
CoxSpriteStand:   ; standing, facing the player
	db 2, 0, 0, $00, $08, 0, 8, $08, $08
CoxSpriteWalkDown1:   ; walking down
	db 2, 0, 0, $02, $08, 0, 8, $0a, $08
CoxSpriteWalkDown2:
	db 2, 0, 0, $04, $08, 0, 8, $0c, $08
CoxSpriteBack:   ; from behind (at the desk)
	db 2, 0, 0, $06, $08, 0, 8, $0e, $08
CoxSpriteWalkUp1:   ; side-step frames of the walking-away cycle
	db 2, 0, 0, $10, $08, 0, 8, $18, $08
CoxSpriteWalkUp2:
	db 2, 0, 0, $18, $28, 0, 8, $10, $28
CoxSpriteStandLeft:   ; standing, facing left (toward Alf in the flashback)
	db 2, 0, 0, $12, $08, 0, 8, $1a, $08
CoxSpriteWalkLeft:   ; walking left
	db 2, 0, 0, $14, $08, 0, 8, $1c, $08
CoxSpriteStandRight:   ; X-flip of StandLeft
	db 2, 0, 0, $1a, $28, 0, 8, $12, $28
CoxSpriteWalkRight:   ; X-flip of WalkLeft
	db 2, 0, 0, $1c, $28, 0, 8, $14, $28
AlfSpriteStand:   ; standing, facing the player
	db 2, 0, 0, $16, $09, 0, 8, $1e, $09
AlfSpriteWalkDown1:   ; walking down
	db 2, 0, 0, $20, $09, 0, 8, $28, $09
AlfSpriteWalkDown2:
	db 2, 0, 0, $22, $09, 0, 8, $2a, $09
AlfSpriteWalkLeft1:   ; walking left
	db 2, 0, 0, $24, $09, 0, 8, $2c, $09
AlfSpriteWalkLeft2:
	db 2, 0, 0, $26, $09, 0, 8, $2e, $09
AlfSpriteStandRight:   ; standing, facing right (toward Cox in the flashback)
	db 2, 0, 0, $2c, $29, 0, 8, $24, $29
CoxMonsterSprite:   ; Cox's green monster
	db 2, 0, 0, $30, $0a, 0, 8, $38, $0a
