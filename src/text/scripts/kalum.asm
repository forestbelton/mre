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
INCLUDE "text.inc"

SECTION "analyzed_07c17b", ROMX[$417b], BANK[$1f]

Kalum_StartEncounter:
	call Func_00_0822
	call HideAllSprites
	call Func_00_3971
	ld a, $01
	ld [rVBK], a
	ld a, $1d
	ld hl, KalumPortraitTiles
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld hl, KalumPortraitMapDesc
	ld a, $1d
	ld de, TILEMAP0
	call BankMapCopyA
	call Kalum_AnimateMonsterPortrait
	call HideUnusedOamSprites
	ld a, $1d
	ld hl, KalumPortraitPaletteBg
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, $1d
	ld hl, KalumPortraitPaletteObj
	ld de, wObjPalettes
	ld bc, $0030
	call BankCopy
	call Func_1f_41da
	call Func_1f_41e6
	push af
	ld a, $36
	call PlaySoundTracked
	pop af
	call Func_1f_4008
	ld hl, KalumScript
	jp ScriptDispatcherEnterAfterCall

Func_1f_41da:
	ld de, $4000
	ld hl, wBgPalettes
	ld c, $08
	call CopyDEtoHL
	ret

Func_1f_41e6:
	ld de, $4000
	ld hl, $c169
	ld c, $08
	call CopyDEtoHL
	ret

Kalum_ShowMonsterPortrait:
	call Kalum_LoadMonsterTiles
	call Func_1f_41e6
	jp ScriptWaitForBgSwap

Kalum_ShowMonsterPortrait2:
	call Kalum_LoadMonsterTiles
	jp ScriptWaitForObjSwap

Kalum_LoadMonsterTiles:
	ld a, $1d
	ld hl, KalumPortraitPaletteBg
	ld de, $c181
	ld bc, $0030
	call BankCopy
	ld de, $c131
	ld hl, $c1b1
	ld c, $10
	call CopyDEtoHL
	ld a, $1d
	ld hl, KalumPortraitPaletteObj
	ld de, $c1c1
	ld bc, $0030
	call BankCopy
	ld de, $c171
	ld hl, $c1f1
	ld c, $10
	call CopyDEtoHL
	ret

Kalum_AnimateMonsterPortrait:
	ld a, $34
	ld [wRendererAddr], a
	ld a, $42
	ld [$d61f], a
	ld a, $1f
	ld [wRendererBank], a
	ld a, $1d
	ld [wDrawBank], a
	ld hl, $5b07
	ld bc, $5070
	call DrawMetasprite
	ld hl, $5b10
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
	ld hl, $5a3e
	ld a, $1d
	ld de, $988d
	call BankMapCopyA
	ld hl, $5a50
	ld bc, $2068
	call DrawMetasprite
	ret
.frame1:
	ld hl, $5a81
	ld a, $1d
	ld de, $988d
	call BankMapCopyA
	ld hl, $5a93
	ld bc, $2068
	call DrawMetasprite
	ret
.frame2:
	ld hl, $5ac4
	ld a, $1d
	ld de, $988d
	call BankMapCopyA
	ld hl, $5ad6
	ld bc, $2068
	call DrawMetasprite
	ret

SECTION "Kalum script", ROMX

KalumScript:
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$01, .Target=.KalumVictory
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$02, .Target=.KalumDefeat
    ; Default greeting (first visit) — was the mislabeled start at $42bd:
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    db "Wow! I can't"
    SCRIPT_NEWLINE
    db "believe people"
    SCRIPT_WAIT
    db "still climb up"
    SCRIPT_NEWLINE
    db "here."
    SCRIPT_WAIT
    db "I've been bored"
    SCRIPT_NEWLINE
    db "lately."
    SCRIPT_WAIT
    db "It's time to"
    SCRIPT_NEWLINE
    db "have some fun!"
    SCRIPT_WAIT
    db "Let's go,"
    SCRIPT_NEWLINE
    db "Selketo!"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL .Addr=Kalum_ShowMonsterPortrait, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=Kalum_ShowMonsterPortrait2, .Bank=$1f
    SCRIPT_REPEAT_CHAR .Count=90
    SCRIPT_END
.KalumVictory:
    db "Unbelievable..."
    SCRIPT_WAIT
    db "My Selketo"
    SCRIPT_NEWLINE
    db "lost..."
    SCRIPT_WAIT
    db "Heh! Even if you"
    SCRIPT_NEWLINE
    db "beat me..."
    SCRIPT_WAIT
    db "Stronger guys"
    SCRIPT_NEWLINE
    db "are up here!"
    SCRIPT_WAIT
    SCRIPT_END
.KalumDefeat:
    db "Hm. Im sorry"
    SCRIPT_NEWLINE
    db "to say, but..."
    SCRIPT_WAIT
    db "At your level,"
    SCRIPT_NEWLINE
    db "it's the same"
    SCRIPT_WAIT
    db "regardless of"
    SCRIPT_NEWLINE
    db "your attempts."
    SCRIPT_WAIT
    db "Don't like it"
    SCRIPT_NEWLINE
    db "Practice harder!"
    SCRIPT_WAIT
    SCRIPT_END
