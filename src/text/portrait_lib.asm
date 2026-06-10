; NPC portrait display library (ROM bank $1f).
;
; Portrait palette transitions used by the NPC dialogue scripts in text/scripts/:
; ShowPortraitTransition (reveal on entering dialogue), HidePortraitWhite /
; Script_FadeOutPortrait (dismiss), all driven by RunPortraitPaletteSwap (a 32-
; frame flicker between the live palettes and a $ff/$00 fill, through the
; $c181/$c1c1 display-palette buffers). Plus ScriptWaitForBgSwap/ScriptWaitForObjSwap
; frame helpers, the tower boss-encounter dispatcher StartTowerBossEncounter
; (called from room/gameplay.asm), and the Nada final-boss portrait renderer
; (NadaPortraitInit / NadaPortraitRender).
; Carved out of analyzed.asm (byte-exact; section names unchanged). The menu
; UI for bank $1f lives separately in text/npc_menus.asm.

INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "sound_ids.inc"

SECTION "analyzed_07c000", ROMX[$4000], BANK[$1f]

Data_1f_4000:
	db $44, $18, $44, $18, $44, $18, $44, $18

; Reveal a portrait: move the just-loaded live palettes into the display buffers
; ($c181/$c1c1), blank the live palettes to white ($ff), then run the swap flicker.
; Called by the boss/NPC scripts right before entering their dialogue.
ShowPortraitTransition:
	ld hl, wBgPalettes
	ld de, $c181
	call MovePalettesFillFF
	ld hl, wObjPalettes
	ld de, $c1c1
	call MovePalettesFillFF
	ld a, $20
	ld [$c281], a
	ld [$c282], a
	ld a, $09
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	jp RunPortraitPaletteSwap
MovePalettesFillFF:
	ld c, $40
.loop:
	ld a, [hl]
	ld [de], a
	ld a, $ff
	ld [hl], a
	inc hl
	inc de
	dec c
	jr nz, .loop
	ret
HidePortraitWhite:
	ld hl, $c181
	call FillPalettesFF
	ld hl, $c1c1
	call FillPalettesFF
	ld a, $20
	ld [$c281], a
	ld [$c282], a
	ld a, $09
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	jp RunPortraitPaletteSwap
FillPalettesFF:
	ld c, $40
	ld a, $ff
.loop:
	ld [hl+], a
	dec c
	jr nz, .loop
	ret

ShowPortraitTransitionBlack:
	ld hl, wBgPalettes
	ld de, $c181
	call MovePalettesFill00
	ld hl, wObjPalettes
	ld de, $c1c1
	call MovePalettesFill00
	ld a, $20
	ld [$c281], a
	ld [$c282], a
	ld a, $09
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	jp RunPortraitPaletteSwap
MovePalettesFill00:
	ld c, $40
.loop:
	ld a, [hl]
	ld [de], a
	ld a, $00
	ld [hl], a
	inc hl
	inc de
	dec c
	jr nz, .loop
	ret

Script_FadeOutPortrait:
	ld hl, $c181
	call FillPalettes00
	ld hl, $c1c1
	call FillPalettes00
	ld a, $20
	ld [$c281], a
	ld [$c282], a
	ld a, $09
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	jp RunPortraitPaletteSwap
FillPalettes00:
	ld c, $40
	xor a
.loop:
	ld [hl+], a
	dec c
	jr nz, .loop
	ret
RunPortraitPaletteSwap:
	ld c, $20
.loop:
	push bc
	ld a, $09
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	call WaitForNextFrame
	ld a, $ff
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	call WaitForNextFrame
	pop bc
	dec c
	jr nz, .loop
	ret

ScriptWaitForBgSwap:
	ld c, $20
.loop:
	push bc
	ld a, $09
	ld [hBgPaletteDirty], a
	call WaitForNextFrame
	ld a, $ff
	ld [hBgPaletteDirty], a
	call WaitForNextFrame
	pop bc
	dec c
	jr nz, .loop
	ret

; ScriptWaitForObjSwap swaps between 32 OBJ palettes, swapping every other frame.
ScriptWaitForObjSwap:
	ld c, $20
.loop:
	push bc
	ld a, $09
	ld [hObjPaletteDirty], a
	call WaitForNextFrame
	ld a, $ff
	ld [hObjPaletteDirty], a
	call WaitForNextFrame
	pop bc
	dec c
	jr nz, .loop
	ret

; Dispatch the tower boss encounter for the current floor (1-5 ->
; Kalum/Mistral/Rafaga/Tempest/Nada): run the character's StartEncounter, silence
; the BGM, then return to the town-building flow. Called from room/gameplay.asm.
StartTowerBossEncounter:
	ld a, [wActiveFloor]
	cp $01
	jr z, .kalum
	cp $02
	jr z, .mistral
	cp $03
	jr z, .rafaga
	cp $04
	jr z, .tempest
	cp $05
	jr z, .nada
	ret

.kalum:
	FAR_CALL $1f, Kalum_StartEncounter
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	jp LeaveTownBuilding

.mistral:
	FAR_CALL $1f, Mistral_StartEncounter
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	jp LeaveTownBuilding

.rafaga:
	FAR_CALL $1f, Rafaga_StartEncounter
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	jp LeaveTownBuilding
.tempest:
	FAR_CALL $1f, Tempest_StartEncounter
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	jp LeaveTownBuilding
.nada:
	FAR_CALL $1f, Func_1f_4d8c
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	jp LeaveTownBuilding

SECTION "analyzed_07d00e", ROMX[$500e], BANK[$1f]

; Nada final-boss portrait renderer: a series of ret-terminated frame routines,
; each loading a tilemap (BankMapCopyA) + drawing a metasprite. The active frame is
; selected by the portrait engine via wRendererAddr (set by NadaPortraitInit /
; nada.asm), so the later blocks are entered by address, not fall-through.
NadaPortraitRender:
	ld hl, $723e
	ld a, $1c
	ld de, $98c9
	call BankMapCopyA
	ld hl, $729e
	ld bc, $4858
	call DrawMetasprite
	ret
	ld hl, $72c7
	ld a, $1c
	ld de, $98c9
	call BankMapCopyA
	ld hl, $7327
	ld bc, $485b
	call DrawMetasprite
	ret
	ld hl, $7348
	ld a, $1c
	ld de, $98c9
	call BankMapCopyA
	ld hl, $73a8
	ld bc, $4550
	call DrawMetasprite
	ret
	ld hl, $73d9
	ld a, $1c
	ld de, $98c9
	call BankMapCopyA
	ld hl, $7439
	ld bc, $4851
	call DrawMetasprite
	ret
	ld hl, $7462
	ld a, $1c
	ld de, $98c9
	call BankMapCopyA
	ld hl, $74c2
	ld bc, $4860
	call DrawMetasprite
	ret
	ld hl, $74d3
	ld a, $1c
	ld de, $98c9
	call BankMapCopyA
	ld hl, $7533
	ld bc, $4860
	call DrawMetasprite
	ret
	ld hl, $7544
	ld a, $1c
	ld de, $98c9
	call BankMapCopyA
	ld hl, $75a4
	ld bc, $4860
	call DrawMetasprite
	ret
NadaPortraitInit:
	ld a, $a1
	ld [wRendererAddr], a
	ld a, $50
	ld [$d61f], a
	ld a, $1f
	ld [wRendererBank], a
	ld a, $1c
	ld [wDrawBank], a
	ld hl, $76ea
	ld a, $1c
	ld de, $986c
	call BankMapCopyA
	ld hl, $76fc
	ld bc, $1360
	call DrawMetasprite
	call Func_1f_4fb2
	ld hl, $7751
	ld bc, $3020
	call DrawMetasprite
	ret

; ($20:$7000 BG/OBJ palettes carved into src/gfx/screen/town.asm as TownPalettes.)

