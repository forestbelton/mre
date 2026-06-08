; Rafaga (tower NPC, third encounter).
;
; Introduces himself as "Nada's servant" and acknowledges the
; player's prior victories ("You beat Kalum and Mistral. I must ask
; you to leave."). Same tower-battle shape as Kalum and Mistral —
; three SCRIPT_END branches for pre-battle / post-win / post-lose.
;
; Carved out of analyzed.asm via map.json; see docs/text_engine.md
; for the bytecode reference. Initial dump produced by
; tools/script_disasm.py — hand-curate freely; the extractor's
; append-only rule on non-auto-managed files preserves your edits.

INCLUDE "hardware.inc"

INCLUDE "text.inc"

SECTION "Rafaga script", ROMX


RafagaScript:
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$01, .Target=.RafagaVictory
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$02, .Target=.RafagaDefeat
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    db "Hello. You're"
    SCRIPT_NEWLINE
    db "finally here."
    SCRIPT_WAIT
    db "I am Rafaga."
    SCRIPT_NEWLINE
    db "Nada's servant."
    SCRIPT_WAIT
    db "I'm surprised"
    SCRIPT_NEWLINE
    db "you made it here"
    SCRIPT_WAIT
    db "You beat Kalum"
    SCRIPT_NEWLINE
    db "and Mistral."
    SCRIPT_WAIT
    db "I must ask you"
    SCRIPT_NEWLINE
    db "to leave here or"
    SCRIPT_WAIT
    db "Nada will be"
    SCRIPT_NEWLINE
    db "mad at me."
    SCRIPT_WAIT
    db "So I'm going to"
    SCRIPT_NEWLINE
    db "be serious now."
    SCRIPT_WAIT
    db "Wake up Punisher"
    SCRIPT_NEWLINE
    db "Time to fight."
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL .Addr=Rafaga_ShowMonsterPortrait, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=Rafaga_ShowMonsterPortrait2, .Bank=$1f
    SCRIPT_REPEAT_CHAR .Count=90
    SCRIPT_END
.RafagaVictory:
    db "This is bad."
    SCRIPT_NEWLINE
    db "I've lost, too."
    SCRIPT_WAIT
    db "Frankly,"
    SCRIPT_NEWLINE
    db "I am shocked."
    SCRIPT_WAIT
    db "Punisher, Nada"
    SCRIPT_NEWLINE
    db "had given to me."
    SCRIPT_WAIT
    db "I must report it"
    SCRIPT_NEWLINE
    db "Nada will be mad"
    SCRIPT_WAIT
    db "You will regret"
    SCRIPT_NEWLINE
    db "this defeat."
    SCRIPT_WAIT
    SCRIPT_END
.RafagaDefeat:
    db "Whew."
    SCRIPT_NEWLINE
    db "I guess"
    SCRIPT_WAIT
    db "Nada won't"
    SCRIPT_NEWLINE
    db "be mad at me."
    SCRIPT_WAIT
    db "Let this be a"
    SCRIPT_NEWLINE
    db "lesson to you."
    SCRIPT_WAIT
    db "Don't think of"
    SCRIPT_NEWLINE
    db "any thing stupid"
    SCRIPT_WAIT
    db "Now, please."
    SCRIPT_NEWLINE
    db "Quietly leave."
    SCRIPT_WAIT
    SCRIPT_END

SECTION "analyzed_07c749", ROMX[$4749], BANK[$1f]

Rafaga_StartEncounter:
	call Func_00_0822
	call HideAllSprites
	call Func_00_3971
	ld a, $01
	ld [rVBK], a
	ld a, $1d
	ld hl, $5b19
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld hl, $7399
	ld a, $1d
	ld de, $9800
	call BankMapCopyA
	call Rafaga_AnimateMonsterPortrait
	call HideUnusedOamSprites
	ld a, $1d
	ld hl, $7319
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, $1d
	ld hl, $7359
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
	ld hl, $4857
	jp ScriptDispatcherEnterAfterCall
Rafaga_ShowMonsterPortrait:
	call Rafaga_LoadMonsterTiles
	call Func_1f_41e6
	jp ScriptWaitForBgSwap
Rafaga_ShowMonsterPortrait2:
	call Rafaga_LoadMonsterTiles
	jp ScriptWaitForObjSwap
Rafaga_LoadMonsterTiles:
	ld a, $1d
	ld hl, $7319
	ld de, $c181
	ld bc, $0030
	call BankCopy
	ld de, $c131
	ld hl, $c1b1
	ld c, $10
	call CopyDEtoHL
	ld a, $1d
	ld hl, $7359
	ld de, $c1c1
	ld bc, $0030
	call BankCopy
	ld de, $c171
	ld hl, $c1f1
	ld c, $10
	call CopyDEtoHL
	ret
Rafaga_AnimateMonsterPortrait:
	ld a, $ea
	ld [wRendererAddr], a
	ld a, $47
	ld [$d61f], a
	ld a, $1f
	ld [wRendererBank], a
	ld a, $1d
	ld [wDrawBank], a
	ld hl, $75c5
	ld bc, $4848
	call DrawMetasprite
	ld hl, $75de
	ld bc, $5872
	call DrawMetasprite
	ld hl, $75e7
	ld bc, $1933
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
	ld hl, $7557
	ld a, $1d
	ld de, $98ad
	call BankMapCopyA
	ld hl, $7565
	ld bc, $3860
	call DrawMetasprite
	ret
.frame1:
	ld hl, $758e
	ld a, $1d
	ld de, $98ad
	call BankMapCopyA
	ld hl, $759c
	ld bc, $3860
	call DrawMetasprite
	ret
