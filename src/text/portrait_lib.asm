; NPC portrait display library (ROM bank $1f).
;
; Portrait palette-swap / fade routines (Func_1f_4008/_403a/_4062,
; Script_FadeOutPortrait) and frame-sync helpers (ScriptWaitForBgSwap/
; ScriptWaitForObjSwap) used by the NPC dialogue scripts in text/scripts/,
; plus the tower boss-encounter dispatcher (Func_1f_4109, called from
; room/gameplay.asm) and Nada final-boss portrait setup (Func_1f_500e/_50a1).
; Carved out of analyzed.asm (byte-exact; section names unchanged). The menu
; UI for bank $1f lives separately in text/npc_menus.asm.

INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "sound_ids.inc"

SECTION "analyzed_07c000", ROMX[$4000], BANK[$1f]

Data_1f_4000:
	db $44, $18, $44, $18, $44, $18, $44, $18

Func_1f_4008:
	ld hl, wBgPalettes
	ld de, $c181
	call Func_1f_402d
	ld hl, wObjPalettes
	ld de, $c1c1
	call Func_1f_402d
	ld a, $20
	ld [$c281], a
	ld [$c282], a
	ld a, $09
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	jp Func_1f_40bb
Func_1f_402d:
	ld c, $40
Func_1f_402f:
	ld a, [hl]
	ld [de], a
	ld a, $ff
	ld [hl], a
	inc hl
	inc de
	dec c
	jr nz, Func_1f_402f
	ret
Func_1f_403a:
	ld hl, $c181
	call Func_1f_4059
	ld hl, $c1c1
	call Func_1f_4059
	ld a, $20
	ld [$c281], a
	ld [$c282], a
	ld a, $09
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	jp Func_1f_40bb
Func_1f_4059:
	ld c, $40
	ld a, $ff
Func_1f_405d:
	ld [hl+], a
	dec c
	jr nz, Func_1f_405d
	ret

Func_1f_4062:
	ld hl, wBgPalettes
	ld de, $c181
	call Func_1f_4087
	ld hl, wObjPalettes
	ld de, $c1c1
	call Func_1f_4087
	ld a, $20
	ld [$c281], a
	ld [$c282], a
	ld a, $09
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	jp Func_1f_40bb
Func_1f_4087:
	ld c, $40
Func_1f_4089:
	ld a, [hl]
	ld [de], a
	ld a, $00
	ld [hl], a
	inc hl
	inc de
	dec c
	jr nz, Func_1f_4089
	ret

Script_FadeOutPortrait:
	ld hl, $c181
	call Func_1f_40b3
	ld hl, $c1c1
	call Func_1f_40b3
	ld a, $20
	ld [$c281], a
	ld [$c282], a
	ld a, $09
	ld [hBgPaletteDirty], a
	ld [hObjPaletteDirty], a
	jp Func_1f_40bb
Func_1f_40b3:
	ld c, $40
	xor a
Func_1f_40b6:
	ld [hl+], a
	dec c
	jr nz, Func_1f_40b6
	ret
Func_1f_40bb:
	ld c, $20
Func_1f_40bd:
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
	jr nz, Func_1f_40bd
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

Func_1f_4109:
	ld a, [wActiveFloor]
	cp $01
	jr z, Func_1f_4121
	cp $02
	jr z, Func_1f_4133
	cp $03
	jr z, Func_1f_4145
	cp $04
	jr z, Func_1f_4157
	cp $05
	jr z, Func_1f_4169
	ret

Func_1f_4121:
	FAR_CALL $1f, Kalum_StartEncounter
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	jp LeaveTownBuilding

Func_1f_4133:
	FAR_CALL $1f, Mistral_StartEncounter
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	jp LeaveTownBuilding

Func_1f_4145:
	FAR_CALL $1f, Rafaga_StartEncounter
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	jp LeaveTownBuilding
Func_1f_4157:
	FAR_CALL $1f, Tempest_StartEncounter
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	jp LeaveTownBuilding
Func_1f_4169:
	FAR_CALL $1f, Func_1f_4d8c
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	jp LeaveTownBuilding

SECTION "analyzed_07d00e", ROMX[$500e], BANK[$1f]

Func_1f_500e:
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
Func_1f_50a1:
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

