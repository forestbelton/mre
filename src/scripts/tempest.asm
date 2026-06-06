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

INCLUDE "script.inc"

SECTION "tempest_07cb82", ROMX[$4b82], BANK[$1f]


TempestScript:
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$01, .Target=.TempestVictory
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$02, .Target=.TempestDefeat
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    db "You've defeated"
    SCRIPT_NEWLINE
    db "them and you"
    SCRIPT_WAIT
    db "still rebel"
    SCRIPT_NEWLINE
    db "against Nada."
    SCRIPT_WAIT
    db "I, Tempest,"
    SCRIPT_NEWLINE
    db "must fight now."
    SCRIPT_WAIT
    db "Dragon,"
    SCRIPT_NEWLINE
    db "help me again."
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL .Addr=Tempest_ShowMonsterPortrait, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=Tempest_ShowMonsterPortrait2, .Bank=$1f
    SCRIPT_REPEAT_CHAR .Count=30
    SCRIPT_ANCHOR
    db "Young one."
    SCRIPT_WAIT
    db "Don't be easy on"
    SCRIPT_NEWLINE
    db "me because"
    SCRIPT_WAIT
    db "I'm old."
    SCRIPT_NEWLINE
    db "Let's fight."
    SCRIPT_WAIT
    SCRIPT_END
.TempestVictory:
    db "You are strong,"
    SCRIPT_NEWLINE
    db "A good fight."
    SCRIPT_WAIT
    db "It feels good"
    SCRIPT_NEWLINE
    db "to be defeated."
    SCRIPT_WAIT
    db "Time for Dragon"
    SCRIPT_NEWLINE
    db "and me to retire"
    SCRIPT_WAIT
    db "Hm. All right."
    SCRIPT_NEWLINE
    db "Go, young one."
    SCRIPT_WAIT
    db "Nada is stronger"
    SCRIPT_NEWLINE
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
    db "Acquire the"
    SCRIPT_NEWLINE
    db "strength I will"
    SCRIPT_WAIT
    db "acknowledge."
    SCRIPT_NEWLINE
    db "It'll be fun."
    SCRIPT_WAIT
    db "My Dragon and I"
    SCRIPT_NEWLINE
    db "will wait here."
    SCRIPT_WAIT
    SCRIPT_END

SECTION "analyzed_07ca74", ROMX[$4a74], BANK[$1f]

Tempest_StartEncounter:
	call Func_00_0822
	call HideAllSprites
	call Func_00_3971
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
	call Func_1f_4b15
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
	call Func_1f_41da
	call Func_1f_41e6
	push af
	ld a, $36
	call PlaySoundTracked
	pop af
	call Func_1f_4008
	ld hl, $4b82
	jp ScriptDispatcherEnterAfterCall
Tempest_ShowMonsterPortrait:
	call Tempest_LoadMonsterTiles
	call Func_1f_41e6
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
Func_1f_4b15:
	ld a, $15
	ld [wRendererAddr], a
	ld a, $4b
	ld [$d61f], a
	ld a, $1f
	ld [wRendererBank], a
	ld a, $1e
	ld [wDrawBank], a
	ld hl, $76bb
	ld bc, $2060
	call DrawMetasprite
	ld hl, $76cc
	ld bc, $5052
	call DrawMetasprite
	ld hl, $76d5
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
	jr z, Func_1f_4b6d
	cp $02
	jr z, Func_1f_4b6d
	ld hl, $7625
	ld a, $1e
	ld de, $98ad
	call BankMapCopyA
	ld hl, $7633
	ld bc, $3560
	call DrawMetasprite
	ret
Func_1f_4b6d:
	ld hl, $7670
	ld a, $1e
	ld de, $98ad
	call BankMapCopyA
	ld hl, $767e
	ld bc, $3560
	call DrawMetasprite
	ret
