; Kalum (tower NPC).
;
; References "climb up here" — Kalum is a tower-level NPC the player
; encounters during their ascent.
;
; Carved out of analyzed.asm via map.json; see docs/text_engine.md
; for the bytecode reference. Initial dump produced by
; tools/script_disasm.py — hand-curate freely; the extractor's
; append-only rule on non-auto-managed files preserves your edits.

INCLUDE "hardware.inc"
INCLUDE "sound/id.inc"
INCLUDE "text.inc"
INCLUDE "util.inc"

SECTION "analyzed_07c17b", ROMX[$417b], BANK[$1f]

Kalum_StartEncounter:
	call LoadWhitePalettes
	call HideAllSprites
	call LoadTextUi
	ld a, $01
	ld [rVBK], a
	ld a, BANK(KalumPortraitTiles)
	ld hl, KalumPortraitTiles
	ld de, TILEDATA0
	ld bc, KalumPortraitTilesEnd - KalumPortraitTiles
	call BankVramCopy
	ld hl, KalumPortraitMapDesc
	ld a, BANK(KalumPortraitMapDesc)
	ld de, TILEMAP0
	call BankMapCopyA
	call Kalum_AnimateMonsterPortrait
	call HideUnusedOamSprites
	ld a, BANK(KalumPortraitPaletteBg)
	ld hl, KalumPortraitPaletteBg
	ld de, wBgPalettes
	ld bc, KalumPortraitPaletteBgEnd - KalumPortraitPaletteBg
	call BankCopy
	ld a, BANK(KalumPortraitPaletteObj)
	ld hl, KalumPortraitPaletteObj
	ld de, wObjPalettes
	ld bc, KalumPortraitPaletteObjEnd - KalumPortraitPaletteObj
	call BankCopy
	call LoadPortraitBackdropBg
	call LoadPortraitBackdropObj
	push af
	ld a, SOUND_BGM_RivalEncounter
	call PlaySoundTracked
	pop af
	call ShowPortraitTransition
	ld hl, KalumScript
	jp ScriptDispatcherEnterAfterCall

; Load the fixed dark palette at the base of this bank ($1f:$4000 = $1844 x4)
; into BG palette 0 -- whose color 0 is the screen backdrop -- giving the
; encounter portrait its dim backdrop. (Bank $1f is mapped at every call site.)
LoadPortraitBackdropBg:
	ld de, $4000
	ld hl, wBgPalettes
	ld c, $08
	call CopyDEtoHL
	ret

; Same fixed dark palette into OBJ palette 5 (wObjPalettes + 5*8). Re-applied by
; the *ShowMonsterPortrait routines after the monster's own tiles are loaded.
LoadPortraitBackdropObj:
	ld de, $4000
	ld hl, wObjPalettes + $28
	ld c, $08
	call CopyDEtoHL
	ret

Kalum_ShowMonsterPortrait:
	call Kalum_LoadMonsterTiles
	call LoadPortraitBackdropObj
	jp ScriptWaitForBgSwap

Kalum_ShowMonsterPortrait2:
	call Kalum_LoadMonsterTiles
	jp ScriptWaitForObjSwap

Kalum_LoadMonsterTiles:
	ld a, BANK(KalumPortraitPaletteBg)
	ld hl, KalumPortraitPaletteBg
	ld de, $c181
	ld bc, KalumPortraitPaletteBgEnd - KalumPortraitPaletteBg
	call BankCopy
	ld de, $c131
	ld hl, $c1b1
	ld c, $10
	call CopyDEtoHL
	ld a, BANK(KalumPortraitPaletteObj)
	ld hl, KalumPortraitPaletteObj
	ld de, $c1c1
	ld bc, KalumPortraitPaletteObjEnd - KalumPortraitPaletteObj
	call BankCopy
	ld de, $c171
	ld hl, $c1f1
	ld c, $10
	call CopyDEtoHL
	ret

Kalum_AnimateMonsterPortrait:
	ld a, LOW(Kalum_AnimateMonsterPortrait)
	ld [wRendererAddr], a
	ld a, HIGH(Kalum_AnimateMonsterPortrait)
	ld [$d61f], a
	ld a, BANK(Kalum_AnimateMonsterPortrait)
	ld [wRendererBank], a
	ld a, BANK(Kalum_shoulder_collar)
	ld [wDrawBank], a
	ld hl, Kalum_shoulder_collar
	ld bc, $5070
	call DrawMetasprite
	ld hl, Kalum_selketo_eye
	ld bc, $2058
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
	ld hl, Kalum_eyes_frame0
	ld a, BANK(Kalum_eyes_frame0)
	ld de, TILEMAP0_X13_Y4
	call BankMapCopyA
	ld hl, Kalum_blink_frame0
	ld bc, $2068
	call DrawMetasprite
	ret
.frame1:
	ld hl, Kalum_eyes_frame1
	ld a, BANK(Kalum_eyes_frame1)
	ld de, TILEMAP0_X13_Y4
	call BankMapCopyA
	ld hl, Kalum_blink_frame1
	ld bc, $2068
	call DrawMetasprite
	ret
.frame2:
	ld hl, Kalum_eyes_frame2
	ld a, BANK(Kalum_eyes_frame2)
	ld de, TILEMAP0_X13_Y4
	call BankMapCopyA
	ld hl, Kalum_blink_frame2
	ld bc, $2068
	call DrawMetasprite
	ret

SECTION "Kalum script", ROMX

KalumScript:
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$01, .Target=.KalumVictory
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$02, .Target=.KalumDefeat
    ; Default greeting (first visit) — was the mislabeled start at $42bd:
    SCRIPT_OPEN_TEXTBOX .Pos=TILEMAP0_X2_Y12, .Width=$10, .Height=$04
    db "Wow! I can't\r"
    db "believe people"
    SCRIPT_WAIT
    db "still climb up\r"
    db "here."
    SCRIPT_WAIT
    db "I've been bored\r"
    db "lately."
    SCRIPT_WAIT
    db "It's time to\r"
    db "have some fun!"
    SCRIPT_WAIT
    db "Let's go,\r"
    db "Selketo!"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL Kalum_ShowMonsterPortrait
    SCRIPT_FAR_CALL Kalum_ShowMonsterPortrait2
    SCRIPT_REPEAT_CHAR .Count=90
    SCRIPT_END
.KalumVictory:
    db "Unbelievable..."
    SCRIPT_WAIT
    db "My Selketo\r"
    db "lost..."
    SCRIPT_WAIT
    db "Heh! Even if you\r"
    db "beat me..."
    SCRIPT_WAIT
    db "Stronger guys\r"
    db "are up here!"
    SCRIPT_WAIT
    SCRIPT_END
.KalumDefeat:
    db "Hm. Im sorry\r"
    db "to say, but..."
    SCRIPT_WAIT
    db "At your level,\r"
    db "it's the same"
    SCRIPT_WAIT
    db "regardless of\r"
    db "your attempts."
    SCRIPT_WAIT
    db "Don't like it\r"
    db "Practice harder!"
    SCRIPT_WAIT
    SCRIPT_END
