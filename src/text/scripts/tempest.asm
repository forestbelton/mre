; Tempest (tower NPC, fourth of Nada's henchmen).
;
; Identifies himself in his first message ("I, Tempest, must fight
; now. Dragon, help me again..."). Fourth tower battle in the chain
; (Kalum -> Mistral -> Rafaga -> Tempest), monster: Dragon.
;
; Same three-end shape as the other tower NPCs.
;
; Carved out of analyzed.asm via map.json; see docs/text_engine.md
; for the bytecode reference. Initial dump produced by
; tools/script_disasm.py — hand-curate freely; the extractor's
; append-only rule on non-auto-managed files preserves your edits.

INCLUDE "hardware.inc"

INCLUDE "text.inc"
INCLUDE "sound/id.inc"

SECTION "Tempest script", ROMX


TempestScript:
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$01, .Target=.TempestVictory
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$02, .Target=.TempestDefeat
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    db "You've defeated\r"
    db "them and you"
    SCRIPT_WAIT
    db "still rebel\r"
    db "against Nada."
    SCRIPT_WAIT
    db "I, Tempest,\r"
    db "must fight now."
    SCRIPT_WAIT
    db "Dragon,\r"
    db "help me again."
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL Tempest_ShowMonsterPortrait
    SCRIPT_FAR_CALL Tempest_ShowMonsterPortrait2
    SCRIPT_REPEAT_CHAR .Count=30
    SCRIPT_ANCHOR
    db "Young one."
    SCRIPT_WAIT
    db "Don't be easy on\r"
    db "me because"
    SCRIPT_WAIT
    db "I'm old.\r"
    db "Let's fight."
    SCRIPT_WAIT
    SCRIPT_END
.TempestVictory:
    db "You are strong,\r"
    db "A good fight."
    SCRIPT_WAIT
    db "It feels good\r"
    db "to be defeated."
    SCRIPT_WAIT
    db "Time for Dragon\r"
    db "and me to retire"
    SCRIPT_WAIT
    db "Hm. All right.\r"
    db "Go, young one."
    SCRIPT_WAIT
    db "Nada is stronger\r"
    db "than me."
    SCRIPT_WAIT
    db "Good luck."
    SCRIPT_WAIT
    SCRIPT_END
.TempestDefeat:
    db "Hmm."
    SCRIPT_WAIT
    db "Guess this is it"
    SCRIPT_WAIT
    db "Come back again."
    SCRIPT_WAIT
    db "Acquire the\r"
    db "strength I will"
    SCRIPT_WAIT
    db "acknowledge.\r"
    db "It'll be fun."
    SCRIPT_WAIT
    db "My Dragon and I\r"
    db "will wait here."
    SCRIPT_WAIT
    SCRIPT_END

SECTION "analyzed_07ca74", ROMX[$4a74], BANK[$1f]

Tempest_StartEncounter:
	call LoadWhitePalettes
	call HideAllSprites
	call LoadTextUi
	ld a, $01
	ld [rVBK], a
	ld a, $1e
	ld hl, $5be7
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld hl, $7467
	ld a, $1e
	ld de, $9800
	call BankMapCopyA
	call Tempest_AnimateMonsterPortrait
	call HideUnusedOamSprites
	ld a, $1e
	ld hl, $73e7
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, $1e
	ld hl, $7427
	ld de, wObjPalettes
	ld bc, $0030
	call BankCopy
	call LoadPortraitBackdropBg
	call LoadPortraitBackdropObj
	push af
	ld a, SOUND_BGM_RivalEncounter
	call PlaySoundTracked
	pop af
	call ShowPortraitTransition
	ld hl, TempestScript
	jp ScriptDispatcherEnterAfterCall
Tempest_ShowMonsterPortrait:
	call Tempest_LoadMonsterTiles
	call LoadPortraitBackdropObj
	jp ScriptWaitForBgSwap
Tempest_ShowMonsterPortrait2:
	call Tempest_LoadMonsterTiles
	jp ScriptWaitForObjSwap
Tempest_LoadMonsterTiles:
	ld a, $1e
	ld hl, $73e7
	ld de, $c181
	ld bc, $0030
	call BankCopy
	ld de, $c131
	ld hl, $c1b1
	ld c, $10
	call CopyDEtoHL
	ld a, $1e
	ld hl, $7427
	ld de, $c1c1
	ld bc, $0030
	call BankCopy
	ld de, $c171
	ld hl, $c1f1
	ld c, $10
	call CopyDEtoHL
	ret
Tempest_AnimateMonsterPortrait:
	ld a, $15
	ld [wRendererAddr], a
	ld a, $4b
	ld [$d61f], a
	ld a, $1f
	ld [wRendererBank], a
	ld a, $1e
	ld [wDrawBank], a
	ld hl, Tempest_hat
	ld bc, $2060
	call DrawMetasprite
	ld hl, Tempest_shoulder
	ld bc, $5052
	call DrawMetasprite
	ld hl, Tempest_dragon_eye
	ld bc, $183b
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
	ld hl, Tempest_eyes_frame0
	ld a, $1e
	ld de, $98ad
	call BankMapCopyA
	ld hl, Tempest_blink_frame0
	ld bc, $3560
	call DrawMetasprite
	ret
.frame1:
	ld hl, Tempest_eyes_frame1
	ld a, $1e
	ld de, $98ad
	call BankMapCopyA
	ld hl, Tempest_blink_frame1
	ld bc, $3560
	call DrawMetasprite
	ret
