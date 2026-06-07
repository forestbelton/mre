; Mistral (tower NPC).
;
; References Kalum in her first message ("That means Kalum lost"),
; placing her as a tower NPC the player encounters after defeating
; Kalum. Sics her monster Ferious on the player; three SCRIPT_END
; branches handle pre-battle, post-win, and post-lose like Kalum.
;
; Carved out of analyzed.asm via map.json; see docs/text_engine.md
; for the bytecode reference. Initial dump produced by
; tools/script_disasm.py — hand-curate freely; the extractor's
; append-only rule on non-auto-managed files preserves your edits.

INCLUDE "text.inc"

SECTION "mistral_07c5a5", ROMX[$45a5], BANK[$1f]


MistralScript:
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$01, .Target=.MistralVictory
    SCRIPT_IF_EQ .Addr=wBossState, .Value=$02, .Target=.MistralDefeat
    SCRIPT_OPEN_TEXTBOX .Pos=$9982, .Width=$10, .Height=$04
    db "Oh?"
    SCRIPT_NEWLINE
    db "I haven't had a"
    SCRIPT_WAIT
    db "guest in a while"
    SCRIPT_WAIT
    db "That means"
    SCRIPT_NEWLINE
    db "Kalum lost."
    SCRIPT_WAIT
    db "I guess you're"
    SCRIPT_NEWLINE
    db "pretty good."
    SCRIPT_WAIT
    db "Ferious isn't"
    SCRIPT_NEWLINE
    db "easy to defeat!"
    SCRIPT_WAIT
    db "Ferious! Come!"
    SCRIPT_YN_CUE
    SCRIPT_FAR_CALL .Addr=Mistral_ShowMonsterPortrait, .Bank=$1f
    SCRIPT_FAR_CALL .Addr=Mistral_ShowMonsterPortrait2, .Bank=$1f
    SCRIPT_REPEAT_CHAR .Count=90
    SCRIPT_END
.MistralVictory:
    db "I... lost?"
    SCRIPT_WAIT
    db "Don't boast"
    SCRIPT_NEWLINE
    db "so soon!"
    SCRIPT_WAIT
    db "You didn't beat"
    SCRIPT_NEWLINE
    db "anybody else yet"
    SCRIPT_WAIT
    db "Now,"
    SCRIPT_NEWLINE
    db "you can go!"
    SCRIPT_WAIT
    db "I'll let you"
    SCRIPT_NEWLINE
    db "pass this time."
    SCRIPT_WAIT
    SCRIPT_END
.MistralDefeat:
    db "Hmph!"
    SCRIPT_WAIT
    db "After all,"
    SCRIPT_NEWLINE
    db "I'm stronger."
    SCRIPT_WAIT
    db "Well, later on"
    SCRIPT_NEWLINE
    db "I have to give"
    SCRIPT_WAIT
    db "Kalum a tip"
    SCRIPT_NEWLINE
    db "on fighting."
    SCRIPT_WAIT
    db "I'll fight you"
    SCRIPT_NEWLINE
    db "again any time"
    SCRIPT_WAIT
    db "if you could"
    SCRIPT_NEWLINE
    db "come here again."
    SCRIPT_WAIT
    SCRIPT_END

SECTION "analyzed_07c416", ROMX[$4416], BANK[$1f]

Mistral_StartEncounter:
	call Func_00_0822
	call HideAllSprites
	call Func_00_3971
	ld a, $00
	ld [rVBK], a
	ld a, $35
	ld hl, $4000
	ld de, $9000
	ld bc, $0800
	call BankVramCopy
	ld a, $01
	ld [rVBK], a
	ld a, $35
	ld hl, $4800
	ld de, $8000
	ld bc, $1800
	call BankVramCopy
	ld hl, $6080
	ld a, $35
	ld de, $9800
	call BankMapCopyA
	call Func_1f_44ca
	call HideUnusedOamSprites
	ld a, $35
	ld hl, $6000
	ld de, wBgPalettes
	ld bc, $0030
	call BankCopy
	ld a, $35
	ld hl, $6040
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
	ld hl, $45a5
	jp ScriptDispatcherEnterAfterCall
Mistral_ShowMonsterPortrait:
	call Mistral_LoadMonsterTiles
	call Func_1f_41e6
	jp ScriptWaitForBgSwap
Mistral_ShowMonsterPortrait2:
	call Mistral_LoadMonsterTiles
	jp ScriptWaitForObjSwap
Mistral_LoadMonsterTiles:
	ld a, $35
	ld hl, $6000
	ld de, $c181
	ld bc, $0030
	call BankCopy
	ld de, $c131
	ld hl, $c1b1
	ld c, $10
	call CopyDEtoHL
	ld a, $35
	ld hl, $6040
	ld de, $c1c1
	ld bc, $0030
	call BankCopy
	ld de, $c171
	ld hl, $c1f1
	ld c, $10
	call CopyDEtoHL
	ret
Func_1f_44ca:
	ld a, $ca
	ld [wRendererAddr], a
	ld a, $44
	ld [$d61f], a
	ld a, $1f
	ld [wRendererBank], a
	ld a, $35
	ld [wDrawBank], a
	ld hl, $6508
	ld bc, $5068
	call DrawMetasprite
	ld hl, $6531
	ld bc, $1039
	call DrawMetasprite
Func_1f_44f0:
	ld a, [rLY]
	cp $50
	jr nz, Func_1f_44f0
	ld hl, $d610
	ld a, [hl]
	inc a
	and $1f
	ld [hl], a
	srl a
	srl a
	srl a
	cp $00
	jr z, Func_1f_4515
	cp $01
	jr z, Func_1f_4545
	cp $02
	jr z, Func_1f_4575
	cp $03
	jr z, Func_1f_4545
Func_1f_4515:
	ld hl, $623e
	ld a, $35
	ld de, $984b
	call BankMapCopyA
	ld hl, $62d4
	ld bc, $405a
	call DrawMetasprite
	ld hl, $62e5
	ld bc, $3890
	call DrawMetasprite
	ld hl, $62f6
	ld bc, $2068
	call DrawMetasprite
	ld hl, $6327
	ld bc, $2088
	call DrawMetasprite
	ret
Func_1f_4545:
	ld hl, $6334
	ld a, $35
	ld de, $984b
	call BankMapCopyA
	ld hl, $63ca
	ld bc, $4060
	call DrawMetasprite
	ld hl, $63db
	ld bc, $3898
	call DrawMetasprite
	ld hl, $63e4
	ld bc, $2068
	call DrawMetasprite
	ld hl, $6415
	ld bc, $2088
	call DrawMetasprite
	ret
Func_1f_4575:
	ld hl, $6422
	ld a, $35
	ld de, $984b
	call BankMapCopyA
	ld hl, $64b8
	ld bc, $4063
	call DrawMetasprite
	ld hl, $64c1
	ld bc, $409a
	call DrawMetasprite
	ld hl, $64ca
	ld bc, $2068
	call DrawMetasprite
	ld hl, $64fb
	ld bc, $2088
	call DrawMetasprite
	ret
