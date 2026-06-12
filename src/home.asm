; ROM bank $00 -- the "home" bank, fixed at $0000-$3fff and always mapped
; alongside the active ROMX bank. Carved out of analyzed.asm. Holds the
; reset/init path, the RST helper vectors, the interrupt handlers, and the
; shared library routines the rest of the game far-calls into. Sections are
; placed by their explicit ROM0[$xxxx] addresses.

INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "scene.inc"
INCLUDE "sound_ids.inc"

SECTION "RST_00", ROM0[$00]

; AddAToHL adds A to HL.
AddAToHL:
	add a, l
	ld l, a
	ret nc
	inc h
	ret

SECTION "RST_08", ROM0[$08]

; SubAFromHL subtracts A from HL.
SubAFromHL:
	cpl
	inc a
	add a, l
	ld l, a
	ret c
	dec h
	ret

SECTION "RST_18", ROM0[$18]

; DerefHL dereferences the little-endian word at HL and store it in HL.
DerefHL:
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ret

SECTION "RST_20", ROM0[$20]

; CheckCGB tests wIsCgb: returns NZ (Z clear) on a Game Boy Color, Z set
; otherwise -- wIsCgb is 1 on CGB, so `and a` leaves a non-zero result there.
; (Callers branch `jr nz` for the CGB path, `jr z` for the DMG path.)
CheckCgb:
	ld a, [wIsCgb]
	and a
	ret

SECTION "RST_30", ROM0[$30]

; AddAToDE adds A to DE.
AddAToDE:
	add a, e
	ld e, a
	ret nc
	inc d
	ret

SECTION "RST_40", ROM0[$40]
	jp $c28d

SECTION "RST_48", ROM0[$48]
	jp $c290

SECTION "RST_50", ROM0[$50]
	jp $c293

SECTION "RST_58", ROM0[$58]
	jp $c296

SECTION "RST_60", ROM0[$60]
	jp $c299

SECTION "Header", ROM0[$0100]
	nop
	jp GameInit

	DS $150 - @, 0

GameInit:
	ld [wConsoleType], a
InitGameSystems:
	di
	ld sp, $de00
	call SetIsCgb
	xor a
	ld [$c285], a
	call InitOamCopy
	call InitInterruptVectors
	call ResetSoundEngine
	call HideAllSprites
	ld a, $c7
	ldh [rLCDC], a
	ei
	push af
	ld a, SOUND_SFX_Silence
	call PlaySound
	pop af
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	ld c, $0a
.wait:
	push bc
	call WaitForNextFrame
	pop bc
	dec c
	jr nz, .wait
	call Func_00_35c8
.update:
	call InitAndRunGameLoop
	jr .update

InitInterruptVectors:
	xor a
	ldh [rIF], a
	ldh [rIE], a
	ld de, $c28d
	ld c, $05
Func_00_0199:
	ld b, $03
	ld hl, $01c6
Func_00_019e:
	ld a, [hl+]
	ld [de], a
	inc de
	dec b
	jr nz, Func_00_019e
	dec c
	jr nz, Func_00_0199
	ld a, [wIsCgb]
	cp $01
	jr z, Func_00_01b3
	ld hl, $02a4
	jr Func_00_01b6
Func_00_01b3:
	ld hl, $02b9
Func_00_01b6:
	ld a, l
	ld [$c28e], a
	ld a, h
	ld [$c28f], a
	xor a
	ldh [rIF], a
	ld a, $03
	ldh [rIE], a
	ret

Func_00_01c6:
	jp Func_00_01c9
Func_00_01c9:
	reti

; InitOamCopy copies the OAM DMA routine into HRAM.
InitOamCopy:
	ld c, LOW(hOamCopy)
	ld b, $0a
	ld hl, OamCopy
.loop:
	ld a, [hl+]
	ldh [c], a
	inc c
	dec b
	jr nz, .loop
	ret

; OamCopy performs a DMA copy from $c000-$c09f into OAM.
OamCopy:
	ld a, $c0
	ldh [rDMA], a
	ld a, $40
	dec a
	jr nz, $01de
	ret

SetIsCgb:
	ld a, [wConsoleType]
	cp $11
	jr z, .cgb
	xor a
	ld [wIsCgb], a
	ret
.cgb:
	ld a, $01
	ld [wIsCgb], a
	call SetDoubleSpeed
	jp InitPaletteState

CheckSoftReset:
	ldh a, [hJoyHeld]
	cp $0f
	ret nz
	call LoadWhitePalettes
	call WaitForNextFrame
	call InitInterruptVectors
	call ResetSoundEngine
	call HideAllSprites
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	call WaitForNextFrame
	di
	xor a
	ldh [rSCY], a
	ldh [rSCX], a
	ld d, $00
	ld hl, $9000
	ld bc, $0010
	call FillVram
	rst CheckCgb
	jr z, .dmg
	ld a, $01
	ldh [rVBK], a
	ld hl, TILEMAP0
	ld bc, $0240
	call FillVram
	ld a, $00
	ldh [rVBK], a
.dmg:
	ld hl, TILEMAP0
	ld bc, $0240
	call FillVram
	ld a, $81
	ldh [rLCDC], a
	ld sp, $de00
	ld a, [wConsoleType]
	jp InitGameSystems

ReadJoypad:
	ld c, $00
	ldh a, [hJoyHeld]
	ld d, a
	ld a, $20
	ldh [c], a
	ldh a, [c]
	ldh a, [c]
	cpl
	and $0f
	swap a
	ld b, a
	ld a, $10
	ldh [c], a
	ldh a, [c]
	ldh a, [c]
	ldh a, [c]
	ldh a, [c]
	ldh a, [c]
	ldh a, [c]
	cpl
	and $0f
	or b
	ld b, a
	ld a, d
	xor b
	and b
	ldh [hJoyPressed], a
	ld a, b
	ldh [hJoyHeld], a
	ld a, $30
	ldh [c], a
	ld hl, hJoyRepeatTimer
	ldh a, [hJoyPressed]
	and a
	jr nz, Func_00_029b
	ldh a, [hJoyHeld]
	and a
	jr z, Func_00_0294
	dec [hl]
	jr nz, Func_00_0294
	ldh [hJoyRepeat], a
	ld a, $05
	ld [hl], a
	call CheckSoftReset
	ret
Func_00_0294:
	xor a
	ldh [hJoyRepeat], a
	call CheckSoftReset
	ret
Func_00_029b:
	ldh [hJoyRepeat], a
	ld a, $1e
	ld [hl], a
	call CheckSoftReset
	ret

VBlankHandlerDmg:
	push af
	push bc
	push de
	push hl
	call $ff80
	ld a, $01
	ld [$c286], a
	ei
	call UpdateSoundEngine
	pop hl
	pop de
	pop bc
	pop af
	ret

VBlankHandlerCgb:
	push af
	push bc
	push de
	push hl
	call FlushDirtyPalettes
	call $ff80
	ld a, $01
	ld [$c286], a
	ei
	call UpdateSoundEngine
	pop hl
	pop de
	pop bc
	pop af
	ret

WaitForHBlank:
	ldh a, [rLCDC]
	rla
	ret nc                ; LCD off -> VRAM is always accessible
.enterMode3:
	ldh a, [rSTAT]
	and $03
	cp $03
	jr nz, .enterMode3    ; spin until mode 3 (pixel transfer) begins
.leaveMode3:
	ldh a, [rSTAT]
	and $03
	cp $03
	jr z, .leaveMode3     ; then spin until it ends -- now at the start of HBlank
	ret

WaitForNextFrame:
	ld a, [$c287]
	inc a
	ld [$c287], a
	ldh a, [rIE]
	rra
	ret nc
	rst CheckCgb
	jr z, HaltOnly
	call Func_00_0643
	call Func_00_0666
	jr HaltOnly
HaltOnly:
	halt
	nop
HaltIfC286Set:
	ld a, [$c286]
	and a
	jr z, HaltOnly
	xor a
	ld [$c286], a
	rst CheckCgb
	ret nz
	; NB: Not sure why ret immediately follows ret nz here.
	ret

CopyDEtoHL:
	ld a, [de]
	ld [hl+], a
	inc de
	dec c
	jr nz, CopyDEtoHL
	ret

CopyDEtoHLLong:
	ld a, [de]
	ld [hl+], a
	inc de
	dec bc
	ld a, b
	or c
	jr nz, CopyDEtoHLLong
	ret

Data_00_031b:
	db $e7, $20, $76, $79, $a1, $28, $06, $cd, $2f, $03, $78, $a0, $c8, $cd, $2f, $03
	db $05, $20, $fa, $c9, $cd, $d1, $02, $2a, $12, $13, $0d, $c8, $2a, $12, $13, $0d
	db $c8, $2a, $12, $13, $0d, $c8, $2a, $12, $13, $0d, $c8, $18, $e7

; VramCopy8 -- copy C bytes from HL to DE without corrupting the display,
; choosing a strategy by hardware (rst CheckCgb). DE is typically VRAM/OAM, which
; the CPU may only touch while the PPU is blanked. C is the byte count, with C = 0
; meaning 256 (VramCopy16 leans on this to move whole 256-byte pages). HL/DE are
; left just past the copied range, C = 0. This is the per-segment worker behind
; VramCopy16 / BankVramCopy.
;
;   CGB (.loop):     di, sync to the PPU via WaitForHBlank (returns instantly when
;     the LCD is off), then blast a batch of up to 7 bytes, re-enabling interrupts
;     briefly between batches -- double-speed CGB has the cycles to move several
;     bytes per blanking window.
;   DMG (.slowCopy): di, then one byte at a time -- poll rSTAT until the PPU is
;     blanked (bit 1 clear = mode 0/1), write the byte, then re-check rSTAT: if the
;     window closed around the write, retry the same byte (HL/DE/C not advanced);
;     only commit (ei, inc hl, inc de, dec c) once the write is confirmed safe.
;
; in:  hl = source, de = destination, c = byte count (0 means 256)
; out: hl, de advanced past the range; c = 0
VramCopy8:
	rst CheckCgb
	jr nz, .gbcCopy
.dmgCopy:
	di
.waitVram:
	ldh a, [rSTAT]
	bit 1, a
	jr nz, .waitVram
	ld a, [hl]
	ld [de], a
	ldh a, [rSTAT]
	bit 1, a
	jr nz, .waitVram
	ei
	inc hl
	inc de
	dec c
	jr nz, .dmgCopy
	ret
.gbcCopy:
	di
	call WaitForHBlank
REPT 7
	ld a, [hl+]
	ld [de], a
	inc de
	dec c
	jr z, .done
ENDR
	ei
	jr .gbcCopy
.done:
	ei
	ret

; VramCopy16 performs a VRAM-safe copy with 16-bit length.
;
; hl    Source address
; de	Target address
; bc    Number of bytes to copy
VramCopy16:
	ld a, c
	and c
	jr z, .copy2
	call VramCopy8
	ld a, b
	and b
	ret z
.copy2:
	call VramCopy8
	dec b
	jr nz, .copy2
	ret

; FillVram performs a VRAM-safe fill with a given byte.
;
; hl	Target address
; bc	Number of bytes
; d		Byte to fill
FillVram:
	call WaitForHBlank
	REPT 2
		ld a, d
		ld [hl+], a
		dec bc
		ld a, b
		or c
		ret z
	ENDR
	ld a, d
	ld [hl+], a
	dec bc
	ld a, b
	or c
	jr nz, FillVram
	ret

; FillRam performs a fill with a given byte.
;
; hl	Target address
; bc	Number of bytes
; d		Byte to fill
FillRam:
	ld a, d
	ld [hl+], a
	dec bc
	ld a, b
	or c
	jr nz, FillRam
	ret

GetRandomByte:
	push bc
	push de
	push hl
	ld a, [$c288]
	ld c, a
	ld de, $006b
	ld hl, $0000
	ld a, $0f
Func_00_03d3:
	sla e
	rl d
	jr nc, Func_00_03da
	add hl, bc
Func_00_03da:
	add hl, hl
	dec a
	jr nz, Func_00_03d3
	bit 7, d
	jr z, Func_00_03e3
	add hl, bc
Func_00_03e3:
	ldh a, [rDIV]
	ld de, $0403
	add hl, de
	add a, l
	ld [$c288], a
	ld hl, $c287
	add a, [hl]
	pop hl
	pop de
	pop bc
	ret
	ld c, b
	ld b, $00
	add hl, bc
	add hl, bc
	add hl, bc
	ld a, [hl+]
	ld b, a
	rst DerefHL
	ret
	reti

DisableLcdStatInterrupt:
	di
	ldh a, [rIE]
	res 1, a
	ldh [rIE], a
	ld a, $ff
	ld [$c291], a
	ld a, $03
	ld [$c292], a
	ei
	ret
SetLcdStatInterrupt:
	ld c, a
	di
	ldh a, [rIE]
	set 1, a
	ldh [rIE], a
	ldh a, [rSTAT]
	set 6, a
	ldh [rSTAT], a
	ld a, c
	ldh [rLYC], a
	ld a, l
	ld [$c291], a
	ld a, h
	ld [$c292], a
	ei
	ret
CallBankedHL:
	ld d, a
	ld a, [CUR_BANK_TAG]
	push af
	ld a, d
	ld [$2fff], a
	ld de, $043c
	push de
	jp hl
	ld [wBankCallTmp], a
	pop af
	ld [$2fff], a
	ld a, [wBankCallTmp]
	ret

Data_00_0447:
	db $f5, $7a, $ea, $9f, $c2, $7b, $ea, $a0, $c2, $f1, $57, $fa, $ff, $7f, $f5, $7a
	db $ea, $ff, $2f, $11, $3c, $04, $d5, $fa, $9f, $c2, $57, $fa, $a0, $c2, $5f, $e9

Func_00_0467:
	push af
	ld a, d
	ld [wSpawnY], a
	ld a, e
	ld [wSpawnX], a
	pop af
	ld d, a
	ld a, [CUR_BANK_TAG]
	push af
	ld a, d
	ld [$2fff], a
	ld de, $043c
	push de
	push hl
	ld a, [wBankCallTmp]
	push af
	ld a, [wSpawnY]
	ld d, a
	ld a, [wSpawnX]
	ld e, a
	ld a, [wSpawnPtr]
	ld h, a
	ld a, [wSpawnPtr+1]
	ld l, a
	pop af
	ret

Func_00_0495:
	ld [wBankCallTmp], a
	ld a, h
	ld [wSpawnPtr], a
	ld a, l
	ld [wSpawnPtr+1], a
	ld a, [CUR_BANK_TAG]
	push af
	ld a, [wBankCallTmp]
	ld [$2fff], a
	ld hl, $04b7
	push hl
	ld a, [wSpawnPtr]
	ld h, a
	ld a, [wSpawnPtr+1]
	ld l, a
	jp hl
	pop af
	ld [$2fff], a
	ret

Func_00_04bc:
	call WaitForNextFrame
	ld a, $e7
	ldh [rLCDC], a
	ret
Func_00_04c4:
	call WaitForNextFrame
	ld a, $c7
	ldh [rLCDC], a
	ret
InitPaletteState:
	xor a
	ld [$c282], a
	ld [$c281], a
	dec a
	ldh [hBgPaletteDirty], a
	ldh [hObjPaletteDirty], a
	ret
ArePalettesClean:
	ldh a, [hBgPaletteDirty]
	cp $ff
	ret nz
	ldh a, [hObjPaletteDirty]
	cp $ff
	ret
; --- CGB palette subsystem (see docs/palettes.md) ----------------------------
; Palettes are staged in WRAM shadow buffers (wBgPalettes / wObjPalettes) and
; flushed to the hardware palette registers in VBlank. The Load* routines copy
; RGB555 data from [HL] into the buffer and mark it dirty; FlushDirtyPalettes
; (called each VBlank) streams any dirty buffer out via rBGPD/rOBPD.

; VBlank: flush whichever palette buffers are dirty (state != $ff).
FlushDirtyPalettes:
	ldh a, [hBgPaletteDirty]
	cp $ff
	call nz, FlushBgPalettes
	ldh a, [hObjPaletteDirty]
	cp $ff
	jp nz, FlushObjPalettes
	ret
; LoadBgPalettes: copy all 8 BG palettes ($40 bytes) from [HL] -> wBgPalettes.
LoadBgPalettes:
	rst CheckCgb
	ret z
	di
	ld d, h
	ld e, l
	ld hl, wBgPalettes
	ld c, $40
	call CopyDEtoHL
	ld a, $08
	ldh [hBgPaletteDirty], a
	ei
	ret
; FlushBgPalettes: stream wBgPalettes -> rBGPD (8 palettes); clear dirty unless $09.
FlushBgPalettes:
	ld hl, wBgPalettes
	ld de, $ff69
	ld c, $08
	ld a, $80
	ldh [rBGPI], a
.loop:
	ld a, [hl+]
	ld [de], a
	ld a, [hl+]
	ld [de], a
	ld a, [hl+]
	ld [de], a
	ld a, [hl+]
	ld [de], a
	ld a, [hl+]
	ld [de], a
	ld a, [hl+]
	ld [de], a
	ld a, [hl+]
	ld [de], a
	ld a, [hl+]
	ld [de], a
	dec c
	jr nz, .loop
	ldh a, [hBgPaletteDirty]
	cp $09
	ret z
	ld a, $ff
	ldh [hBgPaletteDirty], a
	ret
; LoadBgPalette: copy one BG palette ($08 bytes) from [HL] -> wBgPalettes + A*8.
LoadBgPalette:
	ld c, a
	rst CheckCgb
	ret z
	ld d, h
	ld e, l
	ld a, c
	di
	ld hl, wBgPalettes
	add a, a
	add a, a
	add a, a
	rst AddAToHL
	ld c, $08
	call CopyDEtoHL
	ld a, $08
	ldh [hBgPaletteDirty], a
	ei
	ret
; LoadObjPalettes: copy all 8 OBJ palettes ($40 bytes) from [HL] -> wObjPalettes.
LoadObjPalettes:
	rst CheckCgb
	ret z
	di
	ld d, h
	ld e, l
	ld hl, wObjPalettes
	ld c, $40
	call CopyDEtoHL
	ld a, $08
	ldh [hObjPaletteDirty], a
	ei
	ret
; FlushObjPalettes: stream wObjPalettes -> rOBPD (8 palettes); clear dirty unless $09.
FlushObjPalettes:
	ld hl, wObjPalettes
	ld de, $ff6b
	ld c, $08
	ld a, $80
	ldh [rOBPI], a
.loop:
	ld a, [hl+]
	ld [de], a
	ld a, [hl+]
	ld [de], a
	ld a, [hl+]
	ld [de], a
	ld a, [hl+]
	ld [de], a
	ld a, [hl+]
	ld [de], a
	ld a, [hl+]
	ld [de], a
	ld a, [hl+]
	ld [de], a
	ld a, [hl+]
	ld [de], a
	dec c
	jr nz, .loop
	ldh a, [hObjPaletteDirty]
	cp $09
	ret z
	ld a, $ff
	ldh [hObjPaletteDirty], a
	ret
; LoadObjPalette: copy one OBJ palette ($08 bytes) from [HL] -> wObjPalettes + A*8.
LoadObjPalette:
	ld b, a
	rst CheckCgb
	ret z
	ld a, b
	di
	push af
	ld d, h
	ld e, l
	add a, a
	add a, a
	add a, a
	ld hl, wObjPalettes
	rst AddAToHL
	ld c, $08
	call CopyDEtoHL
	pop af
	ldh [hObjPaletteDirty], a
	ei
	ret

Data_00_059c:
	db $fe, $02, $28, $0a, $fe, $04, $28, $06, $fe, $08, $28, $02, $3e, $01, $e0, $a6
	db $18, $06

Func_00_05ae:
	rst CheckCgb
	ret z
	ld a, $01
	ldh [$ffa6], a
	di
	ld d, h
	ld e, l
	ld hl, $c181
	ld c, $40
	call CopyDEtoHL
	ld a, $20
	ld [$c281], a
	ld a, $09
	ldh [hBgPaletteDirty], a
	ei
	ret
Func_00_05ca:
	rst CheckCgb
	ret z
	ld a, $01
	ldh [$ffa6], a
	ld d, h
	ld e, l
	ld hl, $c181
	ld c, $08
Func_00_05d7:
	ld b, $08
	call WaitForHBlank
Func_00_05dc:
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, Func_00_05dc
	dec c
	jr nz, Func_00_05d7
	ld a, $20
	ld [$c281], a
	ld a, $09
	ldh [hBgPaletteDirty], a
	ret

Func_00_05ef:
	cp $02
	jr z, Func_00_05fd
	cp $04
	jr z, Func_00_05fd
	cp $08
	jr z, Func_00_05fd
	ld a, $01
Func_00_05fd:
	ldh [$ffa6], a
	jp Func_00_0608

Func_00_0602:
	rst CheckCgb
	ret z
	ld a, $01
	ldh [$ffa6], a
Func_00_0608:
	di
	ld d, h
	ld e, l
	ld hl, $c1c1
	ld c, $40
	call CopyDEtoHL
	ld a, $20
	ld [$c282], a
	ld a, $09
	ldh [hObjPaletteDirty], a
	ei
	ret
Func_00_061e:
	rst CheckCgb
	ret z
	ld a, $01
	ldh [$ffa6], a
	ld d, h
	ld e, l
	ld hl, $c1c1
	ld c, $08
Func_00_062b:
	ld b, $08
	call WaitForHBlank
Func_00_0630:
	ld a, [de]
	ld [hl+], a
	inc de
	dec b
	jr nz, Func_00_0630
	dec c
	jr nz, Func_00_062b
	ld a, $20
	ld [$c282], a
	ld a, $09
	ldh [hObjPaletteDirty], a
	ret
Func_00_0643:
	ldh a, [hBgPaletteDirty]
	cp $09
	ret nz
	ldh a, [$ffa6]
Func_00_064a:
	push af
	ld hl, $c281
	dec [hl]
	pop af
	dec a
	jr nz, Func_00_064a
	ld a, [hl]
	and a
	jr z, Func_00_0661
	ld c, $20
	ld hl, $c181
	ld de, wBgPalettes
	jr Func_00_0689
Func_00_0661:
	ld a, $ff
	ldh [hBgPaletteDirty], a
	ret
Func_00_0666:
	ldh a, [hObjPaletteDirty]
	cp $09
	ret nz
	ldh a, [$ffa6]
Func_00_066d:
	push af
	ld hl, $c282
	dec [hl]
	pop af
	dec a
	jr nz, Func_00_066d
	ld a, [hl]
	and a
	jr z, Func_00_0684
	ld c, $20
	ld hl, $c1c1
	ld de, wObjPalettes
	jr Func_00_0689
Func_00_0684:
	ld a, $ff
	ldh [hObjPaletteDirty], a
	ret
Func_00_0689:
	push bc
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld b, a
	push hl
	ld a, [de]
	inc de
	ld l, a
	ld a, [de]
	dec de
	ld h, a
	push de
	call Func_00_06a6
	pop de
	ld a, l
	ld [de], a
	inc de
	ld a, h
	ld [de], a
	inc de
	pop hl
	pop bc
	dec c
	jr nz, Func_00_0689
	ret
Func_00_06a6:
	ld a, l
	and $1f
	ldh [$ffa3], a
	ld a, l
	and $e0
	ld l, a
	ld a, h
	and $03
	or l
	rlca
	rlca
	rlca
	ldh [$ffa4], a
	ld a, h
	and $7c
	rrca
	rrca
	ldh [$ffa5], a
	ldh a, [$ffa6]
Func_00_06c1:
	push af
	push bc
	ld hl, $ffa3
	ld a, c
	and $1f
	cp [hl]
	jr z, Func_00_06d2
	jr c, Func_00_06d1
	inc [hl]
	jr Func_00_06d2
Func_00_06d1:
	dec [hl]
Func_00_06d2:
	inc hl
	ld a, c
	and $e0
	ld c, a
	ld a, b
	and $03
	or c
	rlca
	rlca
	rlca
	cp [hl]
	jr z, Func_00_06e7
	jr c, Func_00_06e6
	inc [hl]
	jr Func_00_06e7
Func_00_06e6:
	dec [hl]
Func_00_06e7:
	inc hl
	ld a, b
	and $7c
	rrca
	rrca
	cp [hl]
	jr z, Func_00_06f6
	jr c, Func_00_06f5
	inc [hl]
	jr Func_00_06f6
Func_00_06f5:
	dec [hl]
Func_00_06f6:
	pop bc
	pop af
	dec a
	jp nz, Func_00_06c1
	ld hl, $ffa3
	ld a, [hl+]
	ld d, a
	ld a, [hl+]
	rrca
	rrca
	rrca
	ld e, a
	ld a, [hl]
	rlca
	rlca
	ld h, a
	ld l, d
	ld a, e
	and $e0
	or l
	ld l, a
	ld a, e
	and $03
	or h
	ld h, a
	ret
LoadBgPalettesToSlot:
	ld c, a
	rst CheckCgb
	ret z
	ld d, h
	ld e, l
	ld a, c
	di
	ld hl, wBgPalettes
	add a, a
	add a, a
	add a, a
	rst AddAToHL
	ld a, b
	add a, a
	add a, a
	add a, a
	ld c, a
	call CopyDEtoHL
	ld a, $08
	ldh [hBgPaletteDirty], a
	ei
	ret
LoadObjPalettesToSlot:
	ld c, a
	rst CheckCgb
	ret z
	ld d, h
	ld e, l
	ld a, c
	di
	ld hl, wObjPalettes
	add a, a
	add a, a
	add a, a
	rst AddAToHL
	ld a, b
	add a, a
	add a, a
	add a, a
	ld c, a
	call CopyDEtoHL
	ld a, $08
	ldh [hObjPaletteDirty], a
	ei
	ret

Data_00_074e:
	db $47, $e7, $c8, $e5, $d1, $f3, $21, $81, $c1, $78, $87, $87, $87, $4f, $cd, $0b
	db $03, $3e, $20, $ea, $81, $c2, $3e, $09, $e0, $a1, $fb, $c9, $47, $e7, $c8, $e5
	db $d1
Func_00_076f:
	di
	ld hl, $c1c1
	ld a, b
	add a, a
	add a, a
	add a, a
	ld c, a
	call CopyDEtoHL
	ld a, $20
	ld [$c282], a
	ld a, $09
	ldh [hObjPaletteDirty], a
	ei
	ret

WaitForPaletteFadeCgb:
	rst CheckCgb
	ret z
WaitForPaletteFade:
	call WaitForNextFrame
	call ArePalettesClean
	jr nz, WaitForPaletteFade
	call WaitForNextFrame
	ret
; Fade the screen back in: ramp the hardware palettes from their current
; (usually all-white) state to the saved palettes at $c201/$c241. CGB only.
FadeInPalettes:
	rst CheckCgb
	ret z
	call WaitForPaletteFadeCgb
	ld hl, $c201
	call Func_00_05ae
	ld hl, $c241
	call Func_00_0602
	jr WaitForPaletteFadeCgb
; Fade the screen out to white: save the current palettes to $c201 (so
; FadeInPalettes can restore them), then ramp everything to $0857 (all $7fff).
FadePalettesToWhite:
	rst CheckCgb
	ret z
	ld de, wBgPalettes
	ld hl, $c201
	ld c, $80
	call CopyDEtoHL
	call WaitForPaletteFadeCgb
	ld hl, $0857
	call Func_00_05ae
	ld hl, $0857
	call Func_00_0602
	jr WaitForPaletteFadeCgb
; Fade the screen out to black: save the current palettes to $c201, then ramp
; everything to $0897 (all $0000).
FadePalettesToBlack:
	rst CheckCgb
	ret z
	ld de, wBgPalettes
	ld hl, $c201
	ld c, $80
	call CopyDEtoHL
	call WaitForPaletteFadeCgb
	ld hl, $0897
	call Func_00_05ae
	ld hl, $0897
	call Func_00_0602
	jp WaitForPaletteFadeCgb
Func_00_07e4:
	rst CheckCgb
	ret z
	ld de, wBgPalettes
	ld hl, $c201
	ld c, $80
	call CopyDEtoHL
	call WaitForPaletteFadeCgb
	ld hl, $0857
	call Func_00_05ca
	ld hl, $0857
	call Func_00_061e
	jp WaitForPaletteFadeCgb

Func_00_0803:
	rst CheckCgb
	ret z
	ld de, wBgPalettes
	ld hl, $c201
	ld c, $80
	call CopyDEtoHL
	call WaitForPaletteFadeCgb
	ld hl, $0897
	call Func_00_05ca
	ld hl, $0897
	call Func_00_061e
	jp WaitForPaletteFadeCgb

; Blank the display to white. On CGB, loads the all-white palette at $0857
; (4x $7fff) into every BG and OBJ palette slot; on DMG, zeroes rBGP/rOBP0/rOBP1
; (all-white). Used at the start of a screen/portrait transition so the screen is
; blank while the new content loads, before it is faded in (ShowPortraitTransition).
LoadWhitePalettes:
	rst CheckCgb
	jr z, Func_00_0834
	ld hl, $0857
	call LoadBgPalettes
	ld hl, $0857
	call LoadObjPalettes
	jp WaitForPaletteFadeCgb

Func_00_0834:
	xor a
	ldh [rOBP0], a
	ldh [rOBP1], a
	ldh [rBGP], a
	ret

; Blank the display to black instantly (no ramp): loads the all-black palette
; at $0897 into every BG/OBJ slot; on DMG, $ff to the palette registers. The
; counterpart of LoadWhitePalettes.
BlackoutPalettes:
	rst CheckCgb
	jr z, Func_00_084e
	ld hl, $0897
	call LoadBgPalettes
	ld hl, $0897
	call LoadObjPalettes
	jp WaitForPaletteFadeCgb

Func_00_084e:
	ld a, $ff
	ldh [rOBP0], a
	ldh [rOBP1], a
	ldh [rBGP], a
	ret

Data_00_0857:
	db $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f
	db $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f
	db $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f
	db $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

Func_00_08d7:
	ld hl, $08dc
	jr Func_00_08e9
	db $e4
	sub b
	ld b, b
	nop
	ld hl, $08e5
	jr Func_00_08e9
	nop
	ld b, b
	sub b
	db $e4
Func_00_08e9:
	push hl
	and $07
	ld hl, $0913
	rst AddAToHL
	ld d, [hl]
	pop hl
	ld b, $00
	ld c, $04
Func_00_08f6:
	push bc
	push de
	push hl
	ld a, b
	rst AddAToHL
	ld a, [hl]
	ldh [rBGP], a
	ldh [rOBP0], a
	ldh [rOBP1], a
	ld a, d
Func_00_0903:
	push af
	call WaitForNextFrame
	pop af
	dec a
	jr nz, Func_00_0903
	pop hl
	pop de
	pop bc
	inc b
	dec c
	jr nz, Func_00_08f6
	ret
	ld bc, $0408
	ld [$0802], sp
	ld [$ea08], sp
	sbc a, h
	jp nz, $ea79
	sbc a, [hl]
	jp nz, $fffa
	ld a, a
	push af
	ld a, [$c29e]
	ld [$2fff], a
	ld d, h
	ld e, l
	call WaitForHBlank
	ld a, [wBankCallTmp]
	add a, a
	add a, a
	add a, a
	ld hl, wBgPalettes
	rst AddAToHL
	ld c, $08
	call CopyDEtoHL
	ld a, [wBankCallTmp]
	ldh [hBgPaletteDirty], a
	pop af
	ld [$2fff], a
	ret

LoadObjPaletteBlockBanked:
	ld [wBankCallTmp], a
	ld a, c
	ld [$c29e], a
	ld a, [CUR_BANK_TAG]
	push af
	ld a, [$c29e]
	ld [$2fff], a
	ld d, h
	ld e, l
	call WaitForHBlank
	ld a, [wBankCallTmp]
	add a, a
	add a, a
	add a, a
	ld hl, wObjPalettes
	rst AddAToHL
	ld c, $08
	call CopyDEtoHL
	ld a, [wBankCallTmp]
	ldh [hObjPaletteDirty], a
	pop af
	ld [$2fff], a
	ret

Func_00_0979:
	ld [wBankCallTmp], a
	ld a, c
	ld [$c29e], a
	ld a, [CUR_BANK_TAG]
	push af
	ld a, [$c29e]
	ld [$2fff], a
	ld a, [wBankCallTmp]
	call LoadBgPalette
	pop af
	ld [$2fff], a
	ret
	ld [wBankCallTmp], a
	ld a, c
	ld [$c29e], a
	ld a, [CUR_BANK_TAG]
	push af
	ld a, [$c29e]
	ld [$2fff], a
	ld a, [wBankCallTmp]
	call LoadObjPalette
	pop af
	ld [$2fff], a
	ret

LoadBgPalettesToSlotBanked:
	ld [wBankCallTmp], a
	ld a, b
	ld [$c29d], a
	ld a, c
	ld [$c29e], a
	ld a, [CUR_BANK_TAG]
	push af
	ld a, [$c29e]
	ld [$2fff], a
	ld a, [$c29d]
	ld b, a
	ld a, [wBankCallTmp]
	call LoadBgPalettesToSlot
	pop af
	ld [$2fff], a
	ret
LoadObjPalettesToSlotBanked:
	ld [wBankCallTmp], a
	ld a, b
	ld [$c29d], a
	ld a, c
	ld [$c29e], a
	ld a, [CUR_BANK_TAG]
	push af
	ld a, [$c29e]
	ld [$2fff], a
	ld a, [$c29d]
	ld b, a
	ld a, [wBankCallTmp]
	call LoadObjPalettesToSlot
	pop af
	ld [$2fff], a
	ret
EnableSram:
	ld a, $0a
	ld [Data_00_1fff], a
	ret
DisableSram:
	xor a
	ld [Data_00_1fff], a
	ret
SetDoubleSpeed:
	rst CheckCgb
	ret z
	ld hl, $ff4d
	bit 7, [hl]
	ret nz
	set 0, [hl]
	xor a
	ldh [rIF], a
	ldh [rIE], a
	ld a, $30
	ldh [rJOYP], a
	stop
	ret

Data_00_0a1a:
	rst CheckCgb
	ret z
	ld hl, $ff4d
	bit 7, [hl]
	ret z
	set 0, [hl]
	xor a
	ldh [rIF], a
	ldh [rIE], a
	ld a, $30
	ldh [rJOYP], a
	stop
	ret

SECTION "analyzed_000b4e", ROM0[$0b4e]

CopyBgMap:
	ld a, [hl+]
	ld b, a
	ld a, [hl+]
	ld c, a
	rst CheckCgb
	jr z, Func_00_0b65
	push hl
	push de
	push bc
	ld a, $01
	ldh [rVBK], a
	call Func_00_0b67
	xor a
	ldh [rVBK], a
	pop bc
	pop de
	pop hl
Func_00_0b65:
	inc hl
	inc hl
Func_00_0b67:
	rst DerefHL
Func_00_0b68:
	push bc
	ld b, $00
	push de
	call VramCopy16
	pop de
	ld a, $20
	rst AddAToDE
	pop bc
	dec b
	jr nz, Func_00_0b68
	ret

Func_00_0b78:
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
	ld d, $08
	call FillVram
	ret
	xor a
	ldh [rVBK], a
	ld hl, $9c00
	ld bc, $0400
	ld d, $fc
	call FillVram
	ld a, $01
	ldh [rVBK], a
	ld hl, $9c00
	ld bc, $0400
	ld d, $08
	call FillVram
	ret
Func_00_0bb4:
	push hl
	push de
	push bc
	ld b, $00
	call VramCopy16
	pop bc
	pop de
	pop hl
	ld a, $20
	rst AddAToHL
	ld a, $20
	rst AddAToDE
	dec b
	jr nz, Func_00_0bb4
	ret

Func_00_0bc9:
	ld hl, hSpriteOriginY
	ld a, b
	ld [hl+], a
	ld [hl], c
	ret

Data_00_0bd0:
	ld hl, hSpriteOriginY
	ld a, [hl+]
	ld c, [hl]
	ld b, a
	ret

HideAllSprites:
	ld bc, $0000
	call Func_00_0bc9
Func_00_0bdd:
	ld c, $28
	ld hl, $fe00
	call WaitForHBlank
	xor a
Func_00_0be6:
	ld [hl+], a
	inc hl
	inc hl
	inc hl
	dec c
	jr nz, Func_00_0be6
	ld a, $00
	ldh [hOamCursor], a
HideUnusedOamSprites:
	ldh a, [hOamCursor]
	cp $a0
	jr nc, Func_00_0c04
	ld l, a
	ld h, $c0
Func_00_0bfa:
	xor a
	ld [hl+], a
	inc hl
	inc hl
	inc hl
	ld a, l
	cp $a0
	jr c, Func_00_0bfa
Func_00_0c04:
	ld a, $00
	ldh [hOamCursor], a
	ret

; Stamp a metasprite (a hardware-OBJ group) into the OAM shadow buffer at $c000,
; appending after whatever is already there (HideAllSprites resets the cursor;
; HideUnusedOamSprites clears the tail). The list is a 1-byte count followed by that many
; 4-byte {Yoff, Xoff, tile, attr} records -- see docs/metasprites.md.
;   hl = pointer to the metasprite list, in bank `wDrawBank` (paged in via $2fff,
;        restored on return); hl is left just past the list.
;   b  = base Y position \  the anchor the per-record offsets are added to
;   c  = base X position /
; Each record writes one OAM entry:
;     Y    = Yoff + b + hSpriteOriginY   (all 8-bit, wrapping)
;     X    = Xoff + c + hSpriteOriginX   (hSpriteOriginY/X is a global {Y,X} bias)
;     tile = tile, attr = attr           (copied as-is)
; hOamCursor (low byte of the next free $c0xx slot) advances 4 per record, so successive
; calls stack OBJs into the same frame.
DrawMetasprite:
	ld a, [CUR_BANK_TAG]
	push af
	ld a, [wDrawBank]
	ld [$2fff], a
	ld a, c
	ldh [hMetaspriteBaseX], a
	ld d, $c0
	ldh a, [hOamCursor]
	ld e, a
	ld a, [hl+]
	and a
	jr z, Func_00_0c40
	ld c, a
Func_00_0c20:
	push bc
	ld a, [hl+]
	add a, b
	ld b, a
	ldh a, [hSpriteOriginY]
	add a, b
	ld [de], a
	inc e
	ldh a, [hMetaspriteBaseX]
	add a, [hl]
	ld b, a
	ldh a, [hSpriteOriginX]
	add a, b
	ld [de], a
	inc hl
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	pop bc
	dec c
	jr nz, Func_00_0c20
	ld a, e
	ldh [hOamCursor], a
Func_00_0c40:
	pop af
	ld [$2fff], a
	ret
Func_00_0c45:
	ld a, c
	ldh [hMetaspriteBaseX], a
	ld d, $c0
	ldh a, [hOamCursor]
	ld e, a
	ld a, [hl+]
	and a
	ret z
	ld c, a
Func_00_0c51:
	push bc
	ld a, [hl+]
	add a, b
	ld b, a
	ldh a, [hSpriteOriginY]
	add a, b
	ld [de], a
	inc e
	ldh a, [hMetaspriteBaseX]
	add a, [hl]
	ld b, a
	ldh a, [hSpriteOriginX]
	add a, b
	ld [de], a
	inc hl
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	ld a, [hl+]
	ld [de], a
	inc e
	pop bc
	dec c
	jr nz, Func_00_0c51
	ld a, e
	ldh [hOamCursor], a
	ret

Data_00_0c72:
	ld a, [BANK_TAG_01]
	push af
	ld a, [wDrawBank]
	ld [$2fff], a
	call Func_00_0c84
	pop af
	ld [$2fff], a
	ret

Func_00_0c84:
	ld a, c
	ldh [hMetaspriteBaseX], a
	push hl
	ld hl, $0ce4
	ld a, e
	rst AddAToHL
	ld a, [hl]
	pop hl
	ldh [$ff9f], a
	ld a, d
	or a
	jr nz, Func_00_0ca0
	push hl
	ld hl, $0ce8
	ld d, $00
	add hl, de
	ld a, [hl]
	pop hl
	jr Func_00_0cae
Func_00_0ca0:
	ldh [$ff9d], a
	push hl
	ld hl, $0cec
	ld d, $00
	add hl, de
	ld d, [hl]
	pop hl
	ldh a, [$ff9d]
	or d
Func_00_0cae:
	ldh [$ff9d], a
	ld d, $c0
	ldh a, [hOamCursor]
	ld e, a
	ld a, [hl+]
	and a
	ret z
	ld c, a
Func_00_0cb9:
	push bc
	ld a, [hl+]
	add a, b
	ld b, a
	ldh a, [hSpriteOriginY]
	add a, b
	ld [de], a
	inc e
	ldh a, [hMetaspriteBaseX]
	add a, [hl]
	ld b, a
	ldh a, [hSpriteOriginX]
	add a, b
	ld [de], a
	inc hl
	inc e
	ldh a, [$ff9f]
	ld c, a
	ld a, [hl+]
	add a, c
	ld [de], a
	inc e
	ldh a, [$ff9d]
	ld c, a
	ld a, [hl+]
	and $f0
	or c
	ld [de], a
	inc e
	pop bc
	dec c
	jr nz, Func_00_0cb9
	ld a, e
	ldh [hOamCursor], a
	ret

Data_00_0ce4:
	db $00, $30, $b8, $d0, $0c, $0d, $0e, $07, $08, $08, $08, $00

Func_00_0cf0:
	xor a
	ldh [rOBP0], a
	ldh [rOBP1], a
	ldh [rBGP], a
	ret
	ld a, $e4
	ldh [rOBP0], a
	ldh [rOBP1], a
	ldh [rBGP], a
	ret
	jr $0d66
	db $10
	ld b, d
	ld [$0021], sp
	nop
	jr Func_00_0d6e
	db $10
	ld b, d
	ld [$0021], sp
	nop
	jr Func_00_0d76
	db $10
	ld b, d
	ld [$0021], sp
	nop
	jr Func_00_0d7e
	db $10
	ld b, d
	ld [$0021], sp
	nop
	jr $0d86
	db $10
	ld b, d
	ld [$0021], sp
	nop
	jr $0d8e
	db $10
	ld b, d
	ld [$0021], sp
	nop
	jr $0d96
	db $10
	ld b, d
	ld [$0021], sp
	nop
	jr $0d9e
	db $10
	ld b, d
	ld [$0021], sp
	nop

Func_00_0d41:
	ld a, $01
	ld [$c2ac], a
	ld [$c2ad], a
	call Func_00_0d4d
	ret
Func_00_0d4d:
	push af
	push bc
	push hl
	ld a, [$c2ac]
	cp $02
	jr z, Func_00_0d7f
	cp $03
	jr z, Func_00_0da3
	ld a, [$c289]
	ldh [rSCY], a
	ld a, [$c28a]
	ldh [rSCX], a
	ld a, $07
	ldh [rWX], a
	ld hl, $ff40
	res 1, [hl]
Func_00_0d6e:
	ld hl, $0dc6
	ld a, $08
	call SetLcdStatInterrupt
Func_00_0d76:
	ld a, $01
	ld [$c2ad], a
	pop hl
	pop bc
	pop af
Func_00_0d7e:
	ret
Func_00_0d7f:
	ld a, [$c289]
	ldh [rSCY], a
	ld a, [$c28a]
	ldh [rSCX], a
	ld a, $07
	ldh [rWX], a
	ld hl, $ff40
	res 1, [hl]
	ld hl, $0ddd
	ld a, $08
	call SetLcdStatInterrupt
	ld a, $02
	ld [$c2ad], a
	pop hl
	pop bc
	pop af
	ret
Func_00_0da3:
	ld a, [$c289]
	ldh [rSCY], a
	ld a, [$c28a]
	ldh [rSCX], a
	ld a, $07
	ldh [rWX], a
	ld hl, $ff40
	set 1, [hl]
	ld hl, $0d4d
	xor a
	call SetLcdStatInterrupt
	ld a, $03
	ld [$c2ad], a
	pop hl
	pop bc
	pop af
	ret
	push af
	push bc
	push hl
	ld a, $a7
	ldh [rWX], a
	ld hl, $ff40
	set 1, [hl]
	ld hl, $0d4d
	xor a
	call SetLcdStatInterrupt
	pop hl
	pop bc
	pop af
	ret
	push af
	push bc
	push hl
	ld a, $a7
	ldh [rWX], a
	ld hl, $ff40
	set 1, [hl]
	ld hl, $0df5
	ld a, $30
	call SetLcdStatInterrupt
	pop hl
	pop bc
	pop af
	ret
	push af
	push bc
	push hl
	ld a, $07
	ldh [rWX], a
	ld hl, $ff40
	res 1, [hl]
	ld hl, $0e0d
	ld a, $68
	call SetLcdStatInterrupt
	pop hl
	pop bc
	pop af
	ret
	push af
	push bc
	push hl
	ld a, $a7
	ldh [rWX], a
	ld hl, $ff40
	set 1, [hl]
	ld hl, $0d4d
	xor a
	call SetLcdStatInterrupt
	pop hl
	pop bc
	pop af
	ret
Func_00_0e24:
	ld hl, $ffff
	res 1, [hl]
	ld hl, $ff40
	set 1, [hl]
	ret
Func_00_0e2f:
	call Func_00_0e33
	ret
Func_00_0e33:
	push af
	push bc
	push hl
	ld a, $a7
	ldh [rWX], a
	ld c, $42
	ld a, [$cf3f]
	or a
	jr nz, Func_00_0e48
	ldh a, [c]
	and $7f
	ldh [c], a
	jr Func_00_0e4e
Func_00_0e48:
	ldh a, [c]
	and $7f
	or $80
	ldh [c], a
Func_00_0e4e:
	ld hl, $ff40
	set 1, [hl]
	ld hl, $0e5f
	ld a, $77
	call SetLcdStatInterrupt
	pop hl
	pop bc
	pop af
	ret
	push af
	push bc
	push hl
	ld a, $07
	ldh [rWX], a
	ld hl, $ff40
	res 1, [hl]
	ld hl, $0e33
	ld a, $17
	call SetLcdStatInterrupt
	pop hl
	pop bc
	pop af
	ret
Func_00_0e77:
	call Func_00_0e7b
	ret
Func_00_0e7b:
	push af
	push bc
	push hl
	ld a, $a7
	ldh [rWX], a
	ld c, $42
	ld a, [$cf3f]
	or a
	jr nz, Func_00_0e90
	ldh a, [c]
	and $7f
	ldh [c], a
	jr Func_00_0e96
Func_00_0e90:
	ldh a, [c]
	and $7f
	or $80
	ldh [c], a
Func_00_0e96:
	ld a, [$cf5b]
	ldh [rSCX], a
	ld hl, $ff40
	set 1, [hl]
	ld hl, $0eac
	ld a, $2f
	call SetLcdStatInterrupt
	pop hl
	pop bc
	pop af
	ret
	push af
	push bc
	push hl
	ld a, [$cf5c]
	ldh [rSCX], a
	ld hl, $ff40
	set 1, [hl]
	ld hl, $0ec5
	ld a, $3f
	call SetLcdStatInterrupt
	pop hl
	pop bc
	pop af
	ret
	push af
	push bc
	push hl
	ld a, [$cf5d]
	ldh [rSCX], a
	ld hl, $ff40
	set 1, [hl]
	ld hl, $0ede
	ld a, $47
	call SetLcdStatInterrupt
	pop hl
	pop bc
	pop af
	ret
	push af
	push bc
	push hl
	ld a, [$cf5e]
	ldh [rSCX], a
	ld hl, $ff40
	set 1, [hl]
	ld hl, $0ef7
	ld a, $4f
	call SetLcdStatInterrupt
	pop hl
	pop bc
	pop af
	ret
	push af
	push bc
	push hl
	ld a, [$cf5f]
	ldh [rSCX], a
	ld hl, $ff40
	set 1, [hl]
	ld hl, $0f10
	ld a, $5f
	call SetLcdStatInterrupt
	pop hl
	pop bc
	pop af
	ret
	push af
	push bc
	push hl
	ld a, [$cf60]
	ldh [rSCX], a
	ld hl, $ff40
	set 1, [hl]
	ld hl, $0f29
	ld a, $77
	call SetLcdStatInterrupt
	pop hl
	pop bc
	pop af
	ret
	push af
	push bc
	push hl
	ld a, $07
	ldh [rWX], a
	ld hl, $ff40
	res 1, [hl]
	ld hl, $0e7b
	ld a, $17
	call SetLcdStatInterrupt
	pop hl
	pop bc
	pop af
	ret
; The game's top-level loop: dispatch wGameScene through GameSceneTable
; (farptr per scene), forever. Each handler runs one blocking screen/script
; flow and sets the next wGameScene before returning here.
InitAndRunGameLoop:
	xor a
	ld [wGameScene], a
	ld [$c2a8], a
	ld a, SCENE_LOGO
	ld [wGameScene], a
	call ResetScrollState
	FAR_CALL Func_05_463a
RunGameScene:
	ld hl, GameSceneLoopBack
	push hl
	ld a, [wGameScene]
	ld l, a
	add a, a
	add a, l
	ld hl, GameSceneTable
	rst AddAToHL
	ld a, [hl+]
	ld [$2fff], a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp hl
GameSceneLoopBack:
	jr RunGameScene
	ret

; One farptr per SCENE_* value (scene.inc); zero rows are the unused ids.
GameSceneTable:
	farptr IntroScene_LoadTitle          ; 0 TITLE
	farptr IntroScene_TecmoLogo          ; 1 LOGO
	farptr IntroScene_Cutscene           ; 2 INTRO
	db $00, $00, $00                     ; 3 (unused)
	farptr EnterTownScene                ; 4 TOWN
	farptr Naji_StartTownScript          ; 5 NAJI (the tower spot)
	farptr Bodka_StartDialogue           ; 6 BODKA
	farptr Pashute_StartTownScript       ; 7 PASHUTE
	farptr Toamuna_StartScript           ; 8 TOAMUNA
	farptr Verde_StartDialogue           ; 9 VERDE
	db $00, $00, $00                     ; 10 (unused)
	db $00, $00, $00                     ; 11 (unused)
	db $00, $00, $00                     ; 12 (unused)
	db $00, $00, $00                     ; 13 (unused)
	db $00, $00, $00                     ; 14 (unused)
	db $00, $00, $00                     ; 15 (unused)
	farptr EnterNextRoomScene            ; 16 NEXT_ROOM
	farptr EnterRoomStartScene           ; 17 ROOM_START
	farptr Func_01_439e                  ; 18 ROOM (gameplay proper, bank $01)
	farptr EnterRoomClearScene           ; 19 ROOM_CLEAR
	farptr EnterTowerScene               ; 20 TOWER

TestAabbOverlap:
	push bc
	ldh a, [hHitbox2X]
	ld c, a
	ldh a, [hHitbox1X]
	sub c
	jr c, Func_00_0fce
	ld c, a
	ldh a, [hHitbox2W]
	ld b, a
	ld a, c
	sub b
	jr nc, Func_00_0fc7
	cpl
	inc a
	ldh [hOverlapX], a
	jr Func_00_0fda
Func_00_0fc7:
	pop bc
	xor a
	ldh [hOverlapX], a
	ldh [hOverlapY], a
	ret
Func_00_0fce:
	cpl
	inc a
	ld c, a
	ldh a, [hHitbox1W]
	ld b, a
	ld a, c
	sub b
	jr nc, Func_00_0fc7
	ldh [hOverlapX], a
Func_00_0fda:
	ldh a, [hHitbox2Y]
	ld c, a
	ldh a, [hHitbox1Y]
	sub c
	jr c, Func_00_0ff2
	ld c, a
	ldh a, [hHitbox2H]
	ld b, a
	ld a, c
	sub b
	jr nc, Func_00_0fc7
	cpl
	inc a
	ldh [hOverlapY], a
	pop bc
	ld a, $01
	ret
Func_00_0ff2:
	cpl
	inc a
	ld c, a
	ldh a, [hHitbox1H]
	ld b, a
	ld a, c
	sub b
	jr nc, Func_00_0fc7
	ldh [hOverlapY], a
	pop bc
	ld a, $01
	ret
ClearBgMapAndAttrs:
	xor a
	ldh [rVBK], a
Data_00_1005:
	push bc
	push hl
	ld d, $fc
	call FillVram
	pop hl
	pop bc
	ld a, $01
	ldh [rVBK], a
	ld d, $08
	call FillVram
	xor a
	ldh [rVBK], a
	ret
GetCollisionCell:
	ld a, b
	swap a
Data_00_101e:
	and $f0
	add a, b
	add a, c
	ld c, a
	ld b, $00
	ld hl, wFloorCollision
	add hl, bc
	ld a, [hl]
	ret
GetCollisionCellSaveHL:
	push hl
	ld a, b
	swap a
	and $f0
	add a, b
	add a, c
	ld c, a
	ld b, $00
	ld hl, wFloorCollision
	add hl, bc
	ld a, [hl]
	pop hl
Data_00_103c:
	ret
GetFloorGridCell:
	push hl
	ld a, b
	swap a
	and $f0
	add a, b
	add a, c
	ld c, a
	ld b, $00
	ld hl, wFloorGrid
	add hl, bc
	ld a, [hl]
	pop hl
	ret
Func_00_104f:
	push hl
	ld a, $22
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ldh [c], a
	inc c
	ld a, [hl+]
	ldh [c], a
	inc c
	ld a, [hl+]
	ldh [c], a
	inc c
	ld a, [hl]
	ldh [c], a
	pop hl
	push hl
	ld bc, $000c
	add hl, bc
	ld a, [hl+]
	ld c, a
	inc hl
	ld b, [hl]
	pop hl
	ret
Func_00_106f:
	push hl
	ld a, $26
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ldh [c], a
	inc c
	ld a, [hl+]
	ldh [c], a
	inc c
	ld a, [hl+]
	ldh [c], a
	inc c
	ld a, [hl]
	ldh [c], a
	pop hl
	push hl
	ld bc, $000c
	add hl, bc
	ld a, [hl+]
	ld c, a
	inc hl
	ld b, [hl]
	pop hl
	ret
CopyTilesToBothVramBanks:
	ld [wBankCallTmp], a
	ld a, [CUR_BANK_TAG]
	push af
	ld a, [wBankCallTmp]
	ld [$2fff], a
	xor a
	ldh [rVBK], a
	push bc
	push de
	push hl
	call VramCopy16
	pop hl
	pop de
	pop bc
	ld a, $01
	ldh [rVBK], a
	add hl, bc
	call VramCopy16
	pop af
	ld [$2fff], a
	ret
LoadBgAndObjPalettesBanked:
	ld [wBankCallTmp], a
	ld a, [CUR_BANK_TAG]
	push af
	ld a, [wBankCallTmp]
	ld [$2fff], a
	xor a
	ldh [rVBK], a
	call WaitForHBlank
	push hl
	call LoadBgPalettes
	pop hl
	call WaitForHBlank
	ld de, $0040
	add hl, de
	call LoadObjPalettes
	pop af
	ld [$2fff], a
	ret
; CopyBgMap variant for descriptors whose maps follow the 6-byte header
; inline: hl = descriptor in bank b ([rows][cols][attr ptr][idx ptr], both
; pointers == hl+6), de = destination override. Copies the idx map to VRAM
; bank 0 then the attr map to bank 1, HBlank-safe.
BankMapCopyInline:
	ld a, [CUR_BANK_TAG]
	push af
	ld a, b
	ld [$2fff], a
	ld a, [hl+]
	ld b, a
	ld a, [hl+]
	ld c, a
	inc hl
	inc hl
	inc hl
	inc hl
	xor a
	ldh [rVBK], a
	push bc
Data_00_10f0:
	push de
Func_00_10f1:
	push bc
	push de
Func_00_10f3:
	call WaitForHBlank
	ld a, [hl+]
	ld [de], a
	inc de
	dec c
	jr z, Func_00_110e
	ld a, [hl+]
	ld [de], a
	inc de
	dec c
	jr z, Func_00_110e
	ld a, [hl+]
	ld [de], a
	inc de
	dec c
	jr z, Func_00_110e
	ld a, [hl+]
	ld [de], a
	inc de
	dec c
	jr nz, Func_00_10f3
Func_00_110e:
	pop de
	pop bc
	ld a, e
	add a, $20
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	dec b
	jr nz, Func_00_10f1
	pop de
	pop bc
	ld a, $01
	ldh [rVBK], a
Func_00_1121:
	push bc
	push de
Func_00_1123:
	call WaitForHBlank
	ld a, [hl+]
	ld [de], a
	inc de
	dec c
	jr z, Func_00_113e
	ld a, [hl+]
	ld [de], a
	inc de
	dec c
	jr z, Func_00_113e
	ld a, [hl+]
	ld [de], a
	inc de
	dec c
	jr z, Func_00_113e
	ld a, [hl+]
	ld [de], a
	inc de
	dec c
	jr nz, Func_00_1123
Func_00_113e:
	pop de
	pop bc
	ld a, e
	add a, $20
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	dec b
	jr nz, Func_00_1121
	pop af
	ld [$2fff], a
	ret
Func_00_1150:
	push de
	ld a, [CUR_BANK_TAG]
	push af
	ld a, b
	ld [$2fff], a
	ld de, $115e
	push de
	jp hl
	pop af
	ld [$2fff], a
	pop de
	ret

; Set story/progress flag #A (bit A&7 of wStoryFlags[A>>3]). These flags live
; in the battery-saved block; e.g. flags $0c/$0d gate the town growth stages.
SetStoryFlag:
	push bc
	push hl
	push af
	and $07
	ld hl, BitMaskTable
	rst AddAToHL
	ld b, [hl]
	pop af
	sra a
	sra a
	sra a
	ld hl, wStoryFlags
	rst AddAToHL
	ld a, [hl]
	or b
	ld [hl], a
	pop hl
	pop bc
	ret

; Clear story flag #A.
ClearStoryFlag:
	push bc
	push hl
	push af
	and $07
	ld hl, InvBitMaskTable
	rst AddAToHL
	ld b, [hl]
	pop af
	sra a
	sra a
	sra a
	ld hl, wStoryFlags
	rst AddAToHL
	ld a, [hl]
	and b
	ld [hl], a
	pop hl
	pop bc
	ret

; Test story flag #A: returns NZ (the isolated bit) if set.
TestStoryFlag:
	push bc
	push hl
	push af
	and $07
	ld hl, BitMaskTable
	rst AddAToHL
	ld b, [hl]
	pop af
	sra a
	sra a
	sra a
	ld hl, wStoryFlags
	rst AddAToHL
	ld a, [hl]
	and b
	pop hl
	pop bc
	ret
Func_00_11b4:
	ld a, [hl]
	or a
	jr z, Func_00_11d7
	cp $01
	jr z, Func_00_11ca
	and $f0
	cp $50
	jr nz, Func_00_11d9
	ld a, [$c2e3]
	or a
	jr z, Func_00_11d9
	jr Func_00_11d3
Func_00_11ca:
	ld a, [$c2df]
	or a
	jr z, Func_00_11d9
	ld a, [$c2e0]
Func_00_11d3:
	and $02
	jr z, Func_00_11d9
Func_00_11d7:
	xor a
	ret
Func_00_11d9:
	ld a, $01
	ret
Func_00_11dc:
	set 6, a
	cp $dc
	jr z, Func_00_11f6
	cp $df
	jr z, Func_00_11f6
	cp $d6
	ret nz
	ld [wBankCallTmp], a
	ld a, [$c2ab]
	or a
	jr z, Func_00_1203

Data_00_11f2:
	ld a, [wBankCallTmp]
	ret

Func_00_11f6:
	ld [wBankCallTmp], a
	ld a, [wHasBattleCard]
	or a
	jr z, Func_00_1203

Data_00_11ff:
	ld a, [wBankCallTmp]
	ret

Func_00_1203:
	ld a, [wBankCallTmp]
	res 6, a
	ret

BitMaskTable:
	db $01, $02, $04, $08, $10, $20, $40, $80

InvBitMaskTable:
	db $fe, $fd, $fb, $f7, $ef, $df, $bf, $7f

InitProgressFlags:
	xor a
	set 0, a
	ld [wProgressFlags], a
	ret

Data_00_1220:
	db $00, $00, $40, $40, $40, $40, $40, $40, $40, $00, $60, $60, $40, $40, $60, $60
	db $40, $40, $40, $40, $40

SECTION "analyzed_001235", ROM0[$1235]

Data_00_1235:
	db $40

SECTION "analyzed_001236", ROM0[$1236]

Data_00_1236:
	db $40, $40, $40, $40, $40, $40

Data_00_123c:
	db $40, $00

Data_00_123e:
	db $08, $4b, $89, $89

SECTION "analyzed_001242", ROM0[$1242]

Data_00_1242:
	db $c8

SECTION "analyzed_001243", ROM0[$1243]

Data_00_1243:
	db $c8, $89, $c8

SECTION "analyzed_001246", ROM0[$1246]

Data_00_1246:
	db $d1

SECTION "analyzed_001247", ROM0[$1247]

Data_00_1247:
	db $d1, $51, $51, $d1

SECTION "analyzed_00124b", ROM0[$124b]

Data_00_124b:
	db $d1

SECTION "analyzed_00124c", ROM0[$124c]

Data_00_124c:
	db $51, $51, $51, $51, $8f, $8f, $8f, $8f, $8f, $cf, $cf, $cf, $8f, $cf, $cf, $87
	db $87, $41, $60, $60, $8b, $8b, $8b, $cb, $8b, $8b

SECTION "analyzed_001270", ROM0[$1270]

Data_00_1270:
	db $01, $01, $01, $03, $03, $41

SECTION "analyzed_001280", ROM0[$1280]

Data_00_1280:
	db $01, $01, $42, $40

SECTION "analyzed_001290", ROM0[$1290]

ClassifyEntityType:
	push hl
	ld hl, $1220
	rst AddAToHL
	ld a, [hl]
	pop hl
	ret
LoadCurrentFloorRecordToBuffer:
	ld a, [wActiveFloor]
	ld d, a
	ld a, [wRoomType]
	cp $04
	jr nz, Func_00_12a8
	ld a, $4e
	add a, d
	jr LoadFloorRecordToBuffer
Func_00_12a8:
	ld a, $4c
	add a, d
; LoadFloorRecordToBuffer (a = record index): map the record's bank
; (FloorBankTable) + pointer (FloorPtrTable) and copy the WHOLE 581-byte record
; -- the 325-byte front AND the 256-byte trailer -- into wFloorSnapshot for the
; in-room level editor / preview. This is the only code that reads the trailer
; (gameplay's ParseFloorRecord stops after the front). See docs/floor_data.md.
LoadFloorRecordToBuffer:
	ld d, a
	ld hl, $1567
	rst AddAToHL
	ld a, [CUR_BANK_TAG]
	push af
	ld a, [hl]
	ld [$2fff], a
	ld a, d
	add a, a
	ld hl, $15bf
	rst AddAToHL
	ld a, [hl+]
	ld d, [hl]
	ld e, a
	call EnableSram
	ld bc, $0245
	ld hl, wFloorSnapshot
	call CopyDEtoHLLong
	call DisableSram
	pop af
	ld [$2fff], a
	ld a, [$c55d]
	ld [wActiveFloor], a
	ret

Data_00_12db:
	db $e1, $c7, $e8, $c7, $ef, $c7

VerifyXorChecksum:
	ld d, $00
Func_00_12e3:
	ld a, [hl+]
	xor d
	ld d, a
	dec bc
	ld a, b
	or c
	jr nz, Func_00_12e3
	ld a, [hl]
	cp d
	ret
WriteXorChecksum:
	ld d, $00
Func_00_12f0:
	ld a, [hl+]
	xor d
	ld d, a
	dec bc
	ld a, b
	or c
	jr nz, Func_00_12f0
	ld [hl], d
	ret

FloorPieceDefs:
	db $00, $76, $0b, $7d, $0b, $21, $00, $02, $50, $02, $22, $06, $01, $56, $01, $23
	db $10, $01

Data_00_130c:
	db $56, $01

Data_00_130e:
	db $40, $20, $01, $58, $01, $41, $24, $01, $58, $01, $42, $64, $09, $59, $01, $43
	db $66, $09, $5a, $01, $c0, $00, $09, $5b, $01, $c1, $00, $0a

Data_00_132a:
	db $5b, $02

Data_00_132c:
	db $c2, $02, $09, $5c, $01, $c3, $04, $0b, $5d, $03, $c4, $06, $0b, $5e, $03, $c5
	db $10, $09

Data_00_133e:
	db $5f, $01

Data_00_1340:
	db $c6, $10, $0d

Data_00_1343:
	db $5f, $05

Data_00_1345:
	db $c7, $12, $09, $60, $01, $c8, $14, $09, $61, $01, $c9, $16, $09

Data_00_1352:
	db $62, $01

Data_00_1354:
	db $ca, $20, $0c

Data_00_1357:
	db $63, $04

Data_00_1359:
	db $cb, $22, $09

Data_00_135c:
	db $64, $01

Data_00_135e:
	db $cc, $24, $0d, $65, $05, $cd, $24, $0c, $65, $04, $ce, $26, $0d, $66, $05, $cf
	db $26, $0c, $66, $04, $d0, $30, $0a, $67, $02, $d1, $32, $0a, $68, $02, $d2, $34
	db $0a, $69, $02, $d3, $32, $09, $68, $01, $d4, $34, $09, $69, $01, $d5, $36, $0a
	db $6a, $02, $d6, $40, $09, $6b, $01, $d7, $42, $0c, $6c, $04, $d8, $44, $0d

Data_00_139d:
	db $6d, $05

Data_00_139f:
	db $d9, $46, $09, $6e, $01, $da, $46, $0a, $6e, $02, $db, $50, $09

Data_00_13ac:
	db $6f, $01

Data_00_13ae:
	db $dc, $52, $0c, $70, $04, $dd, $54, $0c, $71, $04, $de, $56, $09, $72, $01, $df
	db $60, $0d, $73, $05, $e0, $62, $0a, $74, $02, $e1, $14, $0c

Data_00_13ca:
	db $74, $02

Data_00_13cc:
	db $e2, $00, $0a

Data_00_13cf:
	db $5b, $02

Data_00_13d1:
	db $e3, $70, $0c, $59, $04, $10, $40, $05

SECTION "analyzed_0013db", ROM0[$13db]

Data_00_13db:
	db $11, $50, $05

SECTION "analyzed_0013e0", ROM0[$13e0]

Data_00_13e0:
	db $12, $60, $05

SECTION "analyzed_0013e5", ROM0[$13e5]

Data_00_13e5:
	db $13, $70, $05

SECTION "analyzed_0013ea", ROM0[$13ea]

Data_00_13ea:
	db $14, $42, $05

SECTION "analyzed_0013ef", ROM0[$13ef]

Data_00_13ef:
	db $15, $52, $05

SECTION "analyzed_0013f4", ROM0[$13f4]

Data_00_13f4:
	db $16, $62, $05

SECTION "analyzed_0013f9", ROM0[$13f9]

Data_00_13f9:
	db $17, $72, $05

SECTION "analyzed_0013fe", ROM0[$13fe]

Data_00_13fe:
	db $18, $44, $05

SECTION "analyzed_001403", ROM0[$1403]

Data_00_1403:
	db $19, $54, $05

SECTION "analyzed_001408", ROM0[$1408]

Data_00_1408:
	db $1a, $64, $05

SECTION "analyzed_00140d", ROM0[$140d]

Data_00_140d:
	db $1b, $74, $05

SECTION "analyzed_001412", ROM0[$1412]

Data_00_1412:
	db $1c, $46, $05

SECTION "analyzed_001417", ROM0[$1417]

Data_00_1417:
	db $1d, $56, $05

SECTION "analyzed_00141c", ROM0[$141c]

Data_00_141c:
	db $1e, $66, $05

SECTION "analyzed_001421", ROM0[$1421]

Data_00_1421:
	db $1f, $76, $05

SECTION "analyzed_001426", ROM0[$1426]

Data_00_1426:
	db $30, $40, $06

SECTION "analyzed_00142b", ROM0[$142b]

Data_00_142b:
	db $31, $50, $06

SECTION "analyzed_001430", ROM0[$1430]

Data_00_1430:
	db $32, $60, $06

SECTION "analyzed_001435", ROM0[$1435]

Data_00_1435:
	db $33, $70, $06

SECTION "analyzed_00143a", ROM0[$143a]

Data_00_143a:
	db $34, $42, $06

SECTION "analyzed_00143f", ROM0[$143f]

Data_00_143f:
	db $35, $52, $06

SECTION "analyzed_001444", ROM0[$1444]

Data_00_1444:
	db $36, $62, $06

SECTION "analyzed_001449", ROM0[$1449]

Data_00_1449:
	db $37, $72, $06

SECTION "analyzed_00144e", ROM0[$144e]

Data_00_144e:
	db $38, $44, $06

SECTION "analyzed_001453", ROM0[$1453]

Data_00_1453:
	db $39, $54, $06

SECTION "analyzed_001458", ROM0[$1458]

Data_00_1458:
	db $3a, $64, $06

SECTION "analyzed_00145d", ROM0[$145d]

Data_00_145d:
	db $3b, $74, $06

SECTION "analyzed_001462", ROM0[$1462]

Data_00_1462:
	db $3c, $46, $06

SECTION "analyzed_001467", ROM0[$1467]

Data_00_1467:
	db $3d, $56, $06

SECTION "analyzed_00146c", ROM0[$146c]

Data_00_146c:
	db $3e, $66, $06

SECTION "analyzed_001471", ROM0[$1471]

Data_00_1471:
	db $3f, $76, $06

SECTION "analyzed_001476", ROM0[$1476]

Data_00_1476:
	db $50

SECTION "analyzed_001477", ROM0[$1477]

Data_00_1477:
	db $40, $05, $00, $00

SECTION "analyzed_00147b", ROM0[$147b]

Data_00_147b:
	db $51

SECTION "analyzed_00147c", ROM0[$147c]

Func_00_147c:
	ld d, b
	dec b
	nop
	nop

SECTION "analyzed_001480", ROM0[$1480]

Data_00_1480:
	db $52

SECTION "analyzed_001481", ROM0[$1481]

Data_00_1481:
	db $60, $05, $00, $00

SECTION "analyzed_001485", ROM0[$1485]

Data_00_1485:
	db $53

SECTION "analyzed_001486", ROM0[$1486]

Data_00_1486:
	db $70, $05, $00, $00

SECTION "analyzed_00148a", ROM0[$148a]

Data_00_148a:
	db $54

SECTION "analyzed_00148b", ROM0[$148b]

Data_00_148b:
	db $42, $05, $00, $00

SECTION "analyzed_00148f", ROM0[$148f]

Data_00_148f:
	db $55

SECTION "analyzed_001490", ROM0[$1490]

Data_00_1490:
	db $52, $05, $00, $00

SECTION "analyzed_001494", ROM0[$1494]

Data_00_1494:
	db $56

SECTION "analyzed_001495", ROM0[$1495]

Data_00_1495:
	db $62, $05, $00, $00

SECTION "analyzed_001499", ROM0[$1499]

Data_00_1499:
	db $57

SECTION "analyzed_00149a", ROM0[$149a]

Data_00_149a:
	db $72, $05, $00, $00

Data_00_149e:
	db $58, $44, $05

SECTION "analyzed_0014a3", ROM0[$14a3]

Data_00_14a3:
	db $59, $54, $05

SECTION "analyzed_0014a8", ROM0[$14a8]

Data_00_14a8:
	db $5a, $64, $05

SECTION "analyzed_0014ad", ROM0[$14ad]

Data_00_14ad:
	db $5b, $74, $05

SECTION "analyzed_0014b2", ROM0[$14b2]

Data_00_14b2:
	db $5c

SECTION "analyzed_0014b3", ROM0[$14b3]

Data_00_14b3:
	db $46, $05, $00, $00

SECTION "analyzed_0014b7", ROM0[$14b7]

Data_00_14b7:
	db $5d

SECTION "analyzed_0014b8", ROM0[$14b8]

Func_00_14b8:
	ld d, [hl]
	dec b
	nop
	nop

SECTION "analyzed_0014bc", ROM0[$14bc]

Data_00_14bc:
	db $5e

SECTION "analyzed_0014bd", ROM0[$14bd]

Data_00_14bd:
	db $66, $05, $00, $00

SECTION "analyzed_0014c1", ROM0[$14c1]

Data_00_14c1:
	db $5f

SECTION "analyzed_0014c2", ROM0[$14c2]

Data_00_14c2:
	db $76, $05, $00, $00

Data_00_14c6:
	db $60, $40, $06

SECTION "analyzed_0014cb", ROM0[$14cb]

Data_00_14cb:
	db $61, $50, $06

SECTION "analyzed_0014d0", ROM0[$14d0]

Data_00_14d0:
	db $62, $60, $06

SECTION "analyzed_0014d5", ROM0[$14d5]

Data_00_14d5:
	db $63, $70, $06

SECTION "analyzed_0014da", ROM0[$14da]

Data_00_14da:
	db $64, $42, $06

SECTION "analyzed_0014df", ROM0[$14df]

Data_00_14df:
	db $65, $52, $06

SECTION "analyzed_0014e4", ROM0[$14e4]

Data_00_14e4:
	db $66, $62, $06

SECTION "analyzed_0014e9", ROM0[$14e9]

Data_00_14e9:
	db $67

SECTION "analyzed_0014ea", ROM0[$14ea]

Data_00_14ea:
	db $72, $06, $00, $00

SECTION "analyzed_0014ee", ROM0[$14ee]

Data_00_14ee:
	db $68

SECTION "analyzed_0014ef", ROM0[$14ef]

Data_00_14ef:
	db $44, $06, $00, $00

SECTION "analyzed_0014f3", ROM0[$14f3]

Data_00_14f3:
	db $69

SECTION "analyzed_0014f4", ROM0[$14f4]

Data_00_14f4:
	db $54, $06, $00, $00

Data_00_14f8:
	db $6a, $64, $06

SECTION "analyzed_0014fd", ROM0[$14fd]

Data_00_14fd:
	db $6b, $74, $06

SECTION "analyzed_001502", ROM0[$1502]

Data_00_1502:
	db $6c

SECTION "analyzed_001503", ROM0[$1503]

Data_00_1503:
	db $46, $06, $00, $00

SECTION "analyzed_001507", ROM0[$1507]

Data_00_1507:
	db $6d

SECTION "analyzed_001508", ROM0[$1508]

Data_00_1508:
	db $56, $06, $00, $00

SECTION "analyzed_00150c", ROM0[$150c]

Data_00_150c:
	db $6e

SECTION "analyzed_00150d", ROM0[$150d]

Data_00_150d:
	db $66, $06, $00, $00

SECTION "analyzed_001511", ROM0[$1511]

Data_00_1511:
	db $6f

SECTION "analyzed_001512", ROM0[$1512]

Data_00_1512:
	db $76, $06, $00, $00

Data_00_1516:
	db $44, $22, $01

Data_00_1519:
	db $58, $01

Data_00_151b:
	db $48, $26, $01

SECTION "analyzed_001520", ROM0[$1520]

Data_00_1520:
	db $49, $30, $01

SECTION "analyzed_001525", ROM0[$1525]

Data_00_1525:
	db $4a, $32, $01

SECTION "analyzed_00152a", ROM0[$152a]

Data_00_152a:
	db $4b, $34, $01

SECTION "analyzed_00152f", ROM0[$152f]

Data_00_152f:
	db $b0, $e4, $03

SECTION "analyzed_001534", ROM0[$1534]

Data_00_1534:
	db $b1, $e6, $03

SECTION "analyzed_001539", ROM0[$1539]

Data_00_1539:
	db $b2, $f0, $03

SECTION "analyzed_00153e", ROM0[$153e]

Data_00_153e:
	db $b3, $f2, $03

SECTION "analyzed_001543", ROM0[$1543]

Data_00_1543:
	db $b4, $f4, $03

SECTION "analyzed_001548", ROM0[$1548]

Data_00_1548:
	db $b5, $f6, $03

SECTION "analyzed_00154d", ROM0[$154d]

Data_00_154d:
	db $ba

SECTION "analyzed_00154e", ROM0[$154e]

Data_00_154e:
	db $a4, $01, $00, $00

SECTION "analyzed_001552", ROM0[$1552]

Data_00_1552:
	db $bb

SECTION "analyzed_001553", ROM0[$1553]

Data_00_1553:
	db $a6, $01, $00, $00

SECTION "analyzed_001557", ROM0[$1557]

Data_00_1557:
	db $fc

SECTION "analyzed_001558", ROM0[$1558]

Data_00_1558:
	db $42, $01, $ff, $ff

Data_00_155c:
	db $fd, $36, $01

Data_00_155f:
	db $ff, $ff, $fe, $40, $01, $ff, $ff, $ff

FloorBankTable:
	db $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d
	db $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2d, $2e, $2e, $2e, $2e, $2e
	db $2e, $2e, $2e, $2e, $2e, $2e, $2e, $2e, $2e, $2e, $2e, $2e, $2e, $2e, $2e, $2e
	db $2e, $2e, $2e, $2e, $2e, $2e, $2f, $2f, $2f, $2f, $2f, $2f, $2f, $2f, $2f, $2f
	db $2f, $2f, $2f, $2f, $2f, $2f, $12, $12, $12, $12, $12

SECTION "analyzed_0015b2", ROM0[$15b2]

Data_00_15b2:
	db $12

SECTION "analyzed_0015b3", ROM0[$15b3]

Data_00_15b3:
	db $12

SECTION "analyzed_0015b4", ROM0[$15b4]

Data_00_15b4:
	db $12

SECTION "analyzed_0015b5", ROM0[$15b5]

Data_00_15b5:
	db $00, $00, $00, $00, $12, $12, $12, $12, $12, $12
FloorPtrTable:
	db $00, $40, $45, $42, $8a, $44, $cf, $46, $14, $49, $59, $4b, $9e, $4d, $e3, $4f
	db $28, $52, $6d, $54, $b2, $56, $f7, $58, $3c, $5b, $81, $5d, $c6, $5f, $0b, $62
	db $50, $64, $95, $66, $da, $68, $1f, $6b, $64, $6d, $a9, $6f, $ee, $71, $33, $74
	db $78, $76, $bd, $78, $02, $7b, $00, $40, $45, $42, $8a, $44, $cf, $46, $14, $49
	db $59, $4b, $9e, $4d, $e3
Data_00_1604:
	db $4f, $28, $52
Data_00_1607:
	db $6d, $54, $b2
Data_00_160a:
	db $56, $f7
Data_00_160c:
	db $58, $3c
Data_00_160e:
	db $5b, $81, $5d, $c6, $5f, $0b, $62, $50, $64, $95, $66, $da, $68, $1f, $6b, $64
	db $6d, $a9, $6f, $ee, $71, $33, $74, $78, $76, $bd, $78, $02, $7b, $00, $40, $45
	db $42, $8a, $44, $cf, $46, $14, $49, $59, $4b, $9e, $4d, $e3, $4f, $28, $52, $6d
	db $54, $b2, $56, $f7, $58, $3c, $5b, $81, $5d, $c6, $5f, $0b, $62, $55, $50, $26
	db $52, $df, $53, $94, $55, $4d, $57

Data_00_1655:
	db $4d, $57

Data_00_1657:
	db $10, $4e

Data_00_1659:
	db $cb, $4c

Data_00_165b:
	db $09, $a0, $58, $a2, $a7, $a4, $86, $c5, $06, $59, $4b, $5b, $90, $5d, $d5, $5f
	db $1a, $62, $5f, $64

SECTION "analyzed_001873", ROM0[$1873]

Data_00_1873:
	db $07, $05, $19, $04, $7f, $18, $87, $18, $8d, $18, $a7, $18, $b0, $b1, $b2, $b3
	db $b4, $b5, $fd, $ff, $40, $42, $43, $21, $22, $ff, $c0, $c2, $c3, $c4, $c5, $c6
	db $c7, $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf, $d0, $d1, $d2, $d3, $d4, $d5, $d7
	db $d9, $da, $de, $ff

Data_00_18a7:
	db $00, $61, $62, $63, $ff

Data_00_18ac:
	db $08, $18, $90, $76, $00, $18, $98, $7e, $00, $30, $90, $00, $0c, $30, $98, $08
	db $0c, $48, $90, $20, $0d, $48, $98, $28, $0d, $60, $90, $40, $0e, $60, $98, $48
	db $0e

SECTION "analyzed_0018cd", ROM0[$18cd]

Data_00_18cd:
	db $ff

SECTION "analyzed_0018ce", ROM0[$18ce]

Data_00_18ce:
	db $0a, $f0, $00, $30, $00, $f0, $00, $32, $00, $f0, $00, $32, $00, $f0, $00, $32
	db $00, $f0, $00, $32, $00, $f0, $00, $32, $00, $f0, $00, $32, $00, $f0, $00, $32
	db $00, $f0, $00, $32, $00, $f0, $00, $32, $00

OpenRoomSelectMenu:
	ld a, $00
	ld [$c55d], a
	ld a, $00
	ld [$cfbe], a
	FAR_CALL Func_15_41fe
	FAR_CALL Func_15_4134
	FAR_CALL Func_15_4015
Func_00_1919:
	FAR_CALL FloorSelectInputLoop
	or a
	ret nz
	ld a, $04
	ld [wRoomType], a
	call LoadCurrentFloorRecordToBuffer
	call Func_00_2fa2
	ret z
	ld hl, $5230
	call Func_00_3450
	jr Func_00_1919

SetupExchangeRoomSelect:
	ld a, $00
	ld [$c55d], a
	FAR_CALL Func_15_41fe
	FAR_CALL Func_15_4134
	FAR_CALL Func_15_4015
	FAR_CALL FloorSelectInputLoop
	or a
	ret
EnterSelectedRoom:
	ld a, $05
	ld [wRoomType], a
	call LoadFloorByMode
	FAR_CALL SetupNewRun
	FAR_CALL EnterRoomStartScene
	FAR_CALL Func_01_439e
	call ResetScrollState
	ret

OpenRoomArrangeMenu:
	push af
	ld a, SOUND_BGM_Bodka
	call PlaySoundTracked
	pop af
	ld a, $00
	ld [$c55d], a
	ld a, $00
	ld [$cfbe], a
	FAR_CALL Func_15_41fe
	FAR_CALL Func_15_4134
Func_00_19a3:
	FAR_CALL OpenFloorSelectScreen
	or a
	jp nz, Func_00_1a66
Func_00_19af:
	FAR_CALL OpenPieceSelectMenu
	or a
	jr nz, Func_00_19a3
Func_00_19ba:
	call OpenEditorActionMenu
	ld a, [wMenuId]
	cp $00
	jr z, Func_00_19d6
	cp $01
	jr z, Func_00_19ee
	cp $02
	jr z, Func_00_19ee
	cp $03
	jr z, Func_00_1a06
	cp $04
	jr z, Func_00_1a1e
	jr Func_00_19af
Func_00_19d6:
	call Func_00_320e
	call Func_00_1b87
	FAR_CALL Func_15_41fe
	FAR_CALL Func_15_4134
	jr Func_00_19ba
Func_00_19ee:
	call Func_00_320e
	call Func_00_1b29
	FAR_CALL Func_15_41fe
	FAR_CALL Func_15_4134
	jr Func_00_19ba
Func_00_1a06:
	call Func_00_320e
	call Func_00_1b58
	FAR_CALL Func_15_41fe
	FAR_CALL Func_15_4134
	jr Func_00_19ba
Func_00_1a1e:
	FAR_CALL SetupNewRun
	FAR_CALL EnterRoomStartScene
	FAR_CALL Func_01_439e
	call ResetScrollState
	call LoadFloorByMode
	FAR_CALL Func_10_4041
	FAR_CALL LoadAllFloorMonsterSprites
	FAR_CALL Func_15_41fe
	FAR_CALL Func_15_4134
	push af
	ld a, SOUND_BGM_Bodka
	call PlaySoundTracked
	pop af
	jp Func_00_19ba
Func_00_1a66:
	ld a, SCENE_TOWN
	ld [wGameScene], a
	ret
Func_00_1a6c:
	FAR_CALL Func_12_4798
	ld a, [wMenuId]
	ld hl, $1873
	rst AddAToHL
	ld a, [hl]
	ld [wMenuItemCount], a
	ld a, [wMenuId]
	add a, a
	ld hl, $1877
	rst AddAToHL
	ld a, [hl+]
	ld [wMenuItemPtr], a
	ld a, [hl+]
	ld [wMenuItemPtr + 1], a
	ldh a, [rLCDC]
	or $02
	ldh [rLCDC], a
	ld a, $11
	ld [wDrawBank], a
	ld hl, $413f
	ld bc, $1008
	call DrawMetasprite
	ld hl, $18ac
	ld bc, $0000
	call DrawMetasprite
	ld hl, $18ce
	ld bc, $0000
	call DrawMetasprite
	call HideUnusedOamSprites
	call SetEditCursorSprite
	call Func_00_206a
	ld a, [wMenuId]
	cp $03
	jr z, Func_00_1acd
	call Func_00_3268
	call Func_00_205b
	jr Func_00_1ada
Func_00_1acd:
	call Func_00_2020
	ld a, [wMenuCursor]
	cp $00
	jr z, Func_00_1ada
	call Func_00_2081
Func_00_1ada:
	ld a, [wEditCursorY]
	ld b, a
	ld a, [wEditCursorX]
	ld c, a
	push bc
	ld a, [$c2eb]
	ld [wEditCursorY], a
	ld a, [$c2ea]
	ld [wEditCursorX], a
	FAR_CALL Func_12_46d0
	ld hl, wFloorMonsterTable
	ld c, $00
Func_00_1afc:
	ld a, [hl+]
	cp $ff
	jr z, Func_00_1b15
Data_00_1b01:
	ld [wEditCursorX], a
	ld a, [hl+]
	ld [wEditCursorY], a
	ld a, [hl+]
	ld a, [hl+]
	ld a, [hl+]
	ld e, a
	push bc
	push hl
	call Data_00_2094
	pop hl
	pop bc
	jr Func_00_1b19
Func_00_1b15:
	inc hl
	inc hl
	inc hl
	inc hl
Func_00_1b19:
	inc c
	ld a, $09
	cp c
	jr nz, Func_00_1afc
	pop bc
	ld a, b
	ld [wEditCursorY], a
	ld a, c
	ld [wEditCursorX], a
	ret
Func_00_1b29:
	ld a, $01
	ld [wUiState], a
Func_00_1b2e:
	call WaitForNextFrame
	call ReadJoypad
	ld a, [wUiState]
	cp $01
	jr nz, Func_00_1b40
	call MoveMenuListCursor
	jr Func_00_1b43
Func_00_1b40:
	call MoveFloorEditCursor
Func_00_1b43:
	call Func_00_3460
	call Func_00_2dbc
	ld a, [wUiTimer]
	inc a
	ld [wUiTimer], a
	ld a, [wUiState]
	cp $00
	jr nz, Func_00_1b2e
	ret
Func_00_1b58:
	ld a, $01
	ld [wUiState], a
Func_00_1b5d:
	call WaitForNextFrame
	call ReadJoypad
	ld a, [wUiState]
	cp $01
	jr nz, Func_00_1b6f
	call HandleFloorMonsterEdit
	jr Func_00_1b72

Func_00_1b6f:
	call MoveFloorEditCursor

Func_00_1b72:
	call Func_00_3460
	call Func_00_2dbc
	ld a, [wUiTimer]
	inc a
	ld [wUiTimer], a
	ld a, [wUiState]
	cp $00
	jr nz, Func_00_1b5d
	ret
Func_00_1b87:
	ld a, $01
	ld [wUiState], a
	call WaitForNextFrame
	call ReadJoypad
	call MoveMenuListCursor
	ld a, [wUiState]
	cp $02
	jr nz, Func_00_1bc7
	ld a, [wMenuItemValue]
	cp $fd
	jr nz, Func_00_1bb9
	ld a, [wFloorPalette]
	inc a
	cp $07
	jr nz, Func_00_1bac
	xor a
Func_00_1bac:
	ld [wFloorPalette], a
	FAR_CALL LoadFloorBgPalette
	jr Func_00_1bc7
Func_00_1bb9:
	ld a, [wMenuCursor]
	ld [wFloorTileset], a
	FAR_CALL LoadTileset
Func_00_1bc7:
	call Func_00_2dbc
	ld a, [wUiTimer]
	inc a
	ld [wUiTimer], a
	ld a, [wUiState]
	cp $00
	jr nz, Func_00_1b87
	ret

Data_00_1bd9:
	db $06, $08, $0a, $08, $00, $02, $04, $02

Func_00_1be1:
	ld a, h
	ld a, d
	ld a, b
	ld a, d

MoveMenuListCursor:
	ldh a, [hJoyRepeat]
	ld b, a
	ld a, [wMenuItemCount]
	ld c, a
	bit 7, b
	jr z, Func_00_1c20
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ld a, [wMenuCursor]
	inc a
	cp c
	jr nz, Func_00_1c00
	ld a, $00
Func_00_1c00:
	ld [wMenuCursor], a
	ld a, c
	cp $05
	jr nc, Func_00_1c10

Data_00_1c08:
	ld a, [wMenuCursor]
	ld [wMenuCursorRow], a
	jr Func_00_1c1b	; WARN: jr target $1c1b outside decoded range $1c08-$1c0f — wrong --addr? (jr needs the real base address)

Func_00_1c10:
	ld a, [wMenuCursorRow]
	cp $03
	jr z, Func_00_1c1b
	inc a
	ld [wMenuCursorRow], a
Func_00_1c1b:
	call Func_00_3089
	jr Func_00_1c7e
Func_00_1c20:
	bit 6, b
	jr z, Func_00_1c57
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ld a, [wMenuCursor]
	dec a
	cp $80
	jr c, Func_00_1c37
	ld a, [wMenuItemCount]
	dec a
Func_00_1c37:
	ld [wMenuCursor], a
	ld a, c
	cp $05
	jr nc, Func_00_1c47

Data_00_1c3f:
	ld a, [wMenuCursor]
	ld [wMenuCursorRow], a
	jr Func_00_1c52	; WARN: jr target $1c52 outside decoded range $1c3f-$1c46 — wrong --addr? (jr needs the real base address)

Func_00_1c47:
	ld a, [wMenuCursorRow]
	cp $00
	jr z, Func_00_1c52
	dec a
	ld [wMenuCursorRow], a
Func_00_1c52:
	call Func_00_3089
	jr Func_00_1c7e
Func_00_1c57:
	bit 0, b
	jr z, Func_00_1c6c
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ld a, $02
	ld [wUiState], a
	call Func_00_30cf
	jr Func_00_1c7e
Func_00_1c6c:
	ldh a, [hJoyPressed]
	bit 1, a
	jr z, Func_00_1c7e
	push af
	ld a, SOUND_SFX_Cancel
	call PlaySound
	pop af
	ld a, $00
	ld [wUiState], a
Func_00_1c7e:
	call Func_00_3268
	ld a, [wUiTimer]
	rrca
	rrca
	and $03
	ld hl, $1bd9
	rst AddAToHL
	ld d, [hl]
	ld a, $03
	ld c, $02
	call SetOamByte
	ld a, $04
	call SetOamByte
	call Func_00_206a
	ret
HandleFloorMonsterEdit:
	ldh a, [hJoyRepeat]
	ld b, a
	ld a, [wMenuItemCount]
	ld c, a
	bit 7, b
	jr z, Func_00_1cdc
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ld a, [wMenuCursor]
	inc a
	cp c
	jr nz, Func_00_1cb8
	ld a, $00
Func_00_1cb8:
	ld [wMenuCursor], a
	ld a, c
	cp $05
	jr nc, Func_00_1cc8
	ld a, [wMenuCursor]
	ld [wMenuCursorRow], a
	jr Func_00_1cd3

Func_00_1cc8:
	ld a, [wMenuCursorRow]
	cp $03
	jr z, Func_00_1cd3
	inc a
	ld [wMenuCursorRow], a

Func_00_1cd3:
	call NormalizeMonsterTableFlags
	call Func_00_30b3
	jp Func_00_1de5
Func_00_1cdc:
	bit 6, b
	jr z, Func_00_1d17
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ld a, [wMenuCursor]
	dec a
	cp $80
	jr c, Func_00_1cf3
	ld a, [wMenuItemCount]
	dec a
Func_00_1cf3:
	ld [wMenuCursor], a
	ld a, c
	cp $05
	jr nc, Func_00_1d03
	ld a, [wMenuCursor]
	ld [wMenuCursorRow], a
	jr Func_00_1d0e

Func_00_1d03:
	ld a, [wMenuCursorRow]
	cp $00
	jr z, Func_00_1d0e
	dec a
	ld [wMenuCursorRow], a

Func_00_1d0e:
	call NormalizeMonsterTableFlags
	call Func_00_30b3
	jp Func_00_1de5
Func_00_1d17:
	bit 5, b
	jr z, Func_00_1d69
	ld a, [wMenuCursor]
	dec a
	cp $80
	jr nc, Func_00_1d69
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	cp $03
	jr nz, Func_00_1d40

Data_00_1d2e:
	ld hl, wFloorMonsterSpecies
	rst AddAToHL
	ld a, [hl]
	dec a
	cp $0d
	jr nz, $1d3a
	ld a, $13
	ld [hl], a
	ld [wMenuItemValue], a
	jr $1d57	; WARN: jr target $1d57 outside decoded range $1d2e-$1d3f — wrong --addr? (jr needs the real base address)

Func_00_1d40:
	ld hl, wFloorMonsterSpecies
	rst AddAToHL
	call Func_00_1e34
	jp z, Func_00_1de5
Func_00_1d4a:
	ld a, [hl]
	dec a
	cp $80
	jr c, Func_00_1d52

Data_00_1d50:
	ld a, $0c

Func_00_1d52:
	call Func_00_1e58
	jr z, Func_00_1d4a
	ld c, a
	FAR_CALL LoadFloorMonsterSprite
	call Func_00_1ff4
	call Func_00_30b3
	jp Func_00_1de5
Func_00_1d69:
	bit 4, b
	jr z, Func_00_1db8
	ld a, [wMenuCursor]
	dec a
	cp $80
	jr nc, Func_00_1db8
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	cp $03
	jr nz, Func_00_1d92

Data_00_1d80:
	ld hl, wFloorMonsterSpecies
	rst AddAToHL
	ld a, [hl]
	inc a
	cp $14
	jr nz, $1d8c
	ld a, $0e
	ld [hl], a
	ld [wMenuItemValue], a
	jr $1da7	; WARN: jr target $1da7 outside decoded range $1d80-$1d91 — wrong --addr? (jr needs the real base address)

Func_00_1d92:
	ld hl, wFloorMonsterSpecies
	rst AddAToHL
	call Func_00_1e34
	jr z, Func_00_1de5
Func_00_1d9b:
	ld a, [hl]
	inc a
	cp $0d
	jr nz, Func_00_1da2
	xor a
Func_00_1da2:
	call Func_00_1e58
	jr z, Func_00_1d9b
	ld c, a
	FAR_CALL LoadFloorMonsterSprite
	call Func_00_1ff4
	call Func_00_30b3
	jr Func_00_1de5
Func_00_1db8:
	bit 0, b
	jr z, Func_00_1dd0

Data_00_1dbc:
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ld a, $02
	ld [wUiState], a
	call NormalizeMonsterTableFlags
	call Func_00_30cf
	jr Func_00_1de5	; WARN: jr target $1de5 outside decoded range $1dbc-$1dcf — wrong --addr? (jr needs the real base address)

Func_00_1dd0:
	ldh a, [hJoyPressed]
	bit 1, a
	jr z, Func_00_1de5
	push af
	ld a, SOUND_SFX_Cancel
	call PlaySound
	pop af
	ld a, $00
	ld [wUiState], a
	call NormalizeMonsterTableFlags
Func_00_1de5:
	call Func_00_2020
	ld a, [wUiTimer]
	rrca
	rrca
	and $03
	ld [$d0e7], a
	ld hl, $1bd9
	rst AddAToHL
	ld d, [hl]
	ld a, $03
	ld c, $02
	call SetOamByte
	ld a, $04
	call SetOamByte
	call Func_00_206a
	ld a, [wMenuCursor]
	cp $00
	jr nz, Func_00_1e1c
	ld d, $00
	ld a, $05
	ld c, $00
	call SetOamByte
	ld a, $06
	call SetOamByte
	ret
Func_00_1e1c:
	ld a, [$d0e7]
	ld hl, $1bdd
	rst AddAToHL
	ld d, [hl]
	ld a, $05
	ld c, $02
	call SetOamByte
	ld a, $06
	call SetOamByte
	call Func_00_2081
	ret
Func_00_1e34:
	push hl
	ld d, [hl]
	ld c, $04
	ld hl, wFloorSpawnerTable
Func_00_1e3b:
	ld a, $05
	rst AddAToHL
	ld e, $06
Func_00_1e40:
	ld a, [hl+]
	cp d
	jr z, Func_00_1e4f
	dec e
	jr nz, Func_00_1e40
	inc hl
	dec c
	jr nz, Func_00_1e3b
	or $01
	pop hl
	ret

Func_00_1e4f:
	ld hl, $51e8
	call Func_00_3450
	xor a
	pop hl
	ret

Func_00_1e58:
	ld [hl], a
	ld [wMenuItemValue], a
	ld a, [wFloorMonsterSpecies]
	ld d, a
	ld a, [wFloorMonsterSpecies+1]
	cp d
	ret z
	ld a, [wFloorMonsterSpecies+2]
	cp d
	ret z
	ld d, a
	ld a, [wFloorMonsterSpecies+1]
	cp d
	ret z
	ld a, [hl]
	ret
MoveFloorEditCursor:
	ldh a, [hJoyRepeat]
	ld b, a
	ld a, [wFloorHeight]
	dec a
	ld c, a
	bit 7, b
	jr z, Func_00_1e93
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ld a, [wEditCursorY]
	inc a
	cp c
	jr nz, Func_00_1e8e

Data_00_1e8c:
	ld a, $01

Func_00_1e8e:
	ld [wEditCursorY], a
	jr Func_00_1eff
Func_00_1e93:
	bit 6, b
	jr z, Func_00_1eb0
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ld a, [wEditCursorY]
	dec a
	cp $00
	jr nz, Func_00_1eab

Data_00_1ea6:
	ld a, [wFloorHeight]
	sub $02

Func_00_1eab:
	ld [wEditCursorY], a
	jr Func_00_1eff
Func_00_1eb0:
	bit 5, b
	jr z, Func_00_1ecd
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ld a, [wEditCursorX]
	dec a
	cp $00
	jr nz, Func_00_1ec8

Data_00_1ec3:
	ld a, [wFloorWidth]
	sub $02

Func_00_1ec8:
	ld [wEditCursorX], a
	jr Func_00_1eff
Func_00_1ecd:
	ld a, [wFloorWidth]
	dec a
	ld c, a
	bit 4, b
	jr z, Func_00_1eeb
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ld a, [wEditCursorX]
	inc a
	cp c
	jr nz, Func_00_1ee6

Data_00_1ee4:
	ld a, $01

Func_00_1ee6:
	ld [wEditCursorX], a
	jr Func_00_1eff
Func_00_1eeb:
	bit 1, b
	jr z, Func_00_1f07
	push af
	ld a, SOUND_SFX_Cancel
	call PlaySound
	pop af
	ld a, $01
	ld [wUiState], a
	call Func_00_3089
	ret
Func_00_1eff:
	ldh a, [hJoyHeld]
	bit 0, a
	jr z, Func_00_1f2b

Data_00_1f05:
	jr $1f0d	; WARN: jr target $1f0d outside decoded range $1f05-$1f06 — wrong --addr? (jr needs the real base address)

Func_00_1f07:
	ldh a, [hJoyPressed]
	bit 0, a
	jr z, Func_00_1f2b
	ld a, [wMenuId]
	cp $03
	jr z, Func_00_1f1e
	FAR_CALL Func_12_4519
	jr Func_00_1f34

Func_00_1f1e:
	FAR_CALL Data_12_4695
	call NormalizeMonsterTableFlags
	jr Func_00_1f34

Func_00_1f2b:
	ldh a, [hJoyPressed]
	bit 2, a
	jr z, Func_00_1f34

Data_00_1f31:
	call Func_00_2446

Func_00_1f34:
	call SetEditCursorSprite
	ld a, [wUiTimer]
	and $04
	jr nz, Func_00_1f47
	ld d, $00
	ld a, $00
	ld c, $00
	call SetOamByte
Func_00_1f47:
	ret
Func_00_1f48:
	ld h, a
	ld de, $12fa
	cp $00
	jr nz, Func_00_1f55

Data_00_1f50:
	ld a, [wFloorTileset]
	inc a
	ld h, a

Func_00_1f55:
	ld a, [de]
	cp h
	jr z, Func_00_1f62
	cp $ff
	jr z, Func_00_1f70
	ld a, $05
	rst AddAToDE
	jr Func_00_1f55
Func_00_1f62:
	ld hl, $9800
Func_00_1f65:
	ld a, $20
	rst AddAToHL
	dec b
	jr nz, Func_00_1f65
	ld a, c
	rst AddAToHL
	call StampFloorMetatile
Func_00_1f70:
	ret
Func_00_1f71:
	ld h, a
	ld de, $12fa
Func_00_1f75:
	ld a, [de]
	cp h
	jr z, Func_00_1f82
	cp $ff
	jr z, Func_00_1f90
	ld a, $05
	rst AddAToDE
	jr Func_00_1f75
Func_00_1f82:
	ld hl, $9800
Func_00_1f85:
	ld a, $20
	rst AddAToHL
	dec b
	jr nz, Func_00_1f85
	ld a, c
	rst AddAToHL
	call SetBgMapTileAndAttr
Func_00_1f90:
	ret
SetBgMapTileAndAttr:
	xor a
	ldh [rVBK], a
	inc de
	inc de
	inc de
	call WaitForHBlank
	ld a, [de]
	ld [hl], a
	ld a, $01
	ldh [rVBK], a
	inc de
	ld a, [de]
	ld [hl], a
	ret
Func_00_1fa4:
	push af
	ld de, $9800
	ld a, b
	or a
	jr z, Func_00_1fb2
Func_00_1fac:
	ld a, $20
	rst AddAToDE
	dec b
	jr nz, Func_00_1fac
Func_00_1fb2:
	ld a, c
	rst AddAToDE
	pop bc
Func_00_1fb5:
	ld a, [hl+]
	cp $20
	jr z, Func_00_1fe8
	cp $21
	jr nz, Func_00_1fc2
	ld a, $a4
	jr Func_00_1fd9
Func_00_1fc2:
	cp $3f
	jr nz, Func_00_1fca
	ld a, $a5
	jr Func_00_1fd9
Func_00_1fca:
	sub $30
	ret c
	cp $0a
	jr nc, Func_00_1fd5
	add a, $9a
	jr Func_00_1fd9
Func_00_1fd5:
	sub $11
	add a, $80
Func_00_1fd9:
	ld c, a
	call WaitForHBlank
	xor a
	ldh [rVBK], a
	ld a, c
	ld [de], a
	ld a, $01
	ldh [rVBK], a
	ld a, b
	ld [de], a
Func_00_1fe8:
	inc de
	jr Func_00_1fb5

Data_00_1feb:
	ld hl, $c000
	add a, a
	add a, a
	add a, c
	rst AddAToHL
	ld a, [hl]
	ret

Func_00_1ff4:
	ld a, [wMenuCursor]
	dec a
	ld b, a
	ld hl, wFloorMonsterTable
	ld c, $00
Func_00_1ffe:
	inc hl
Data_00_1fff:
	inc hl
Data_00_2000:
	inc hl
	inc hl
	ld a, [hl+]
	cp b
	jr nz, Func_00_2019

Data_00_2006:
	push hl
	push bc
	ld a, [wMenuItemValue]
	add a, a
	add a, $32
	ld d, a
	ld a, c
	add a, $10
	ld c, $02
	call SetOamByte
	pop bc
	pop hl

Func_00_2019:
	inc c
	ld a, $09
	cp c
	jr nz, Func_00_1ffe
	ret
Func_00_2020:
	ld de, $c01c
	ld hl, $18ad
	ld a, [wMenuCursorRow]
	ld c, a
	ld a, [wMenuCursor]
	sub c
	jr nc, Func_00_2035

Data_00_2030:
	ld c, a
	ld a, [wMenuItemCount]
	add a, c

Func_00_2035:
	add a, a
	add a, a
	add a, a
	rst AddAToHL
	ld c, $04
Func_00_203b:
	ld a, [hl]
	cp $ff
	jr nz, Func_00_2043

Data_00_2040:
	ld hl, $18ad

Func_00_2043:
	inc hl
	inc hl
	inc de
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	inc hl
	inc hl
	inc de
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	ld a, [hl+]
	ld [de], a
	inc de
	dec c
	jr nz, Func_00_203b
	ret
Func_00_205b:
	ld a, $f0
	ld c, $08
	ld hl, $c01c
Func_00_2062:
	ld [hl+], a
	inc hl
	inc hl
	inc hl
	dec c
	jr nz, Func_00_2062
	ret
Func_00_206a:
	ld a, [wMenuCursorRow]
	ld b, a
	ld c, $18
	call Multiply8
	add a, $18
	ld b, a
	ld [$d0e8], a
	ld c, $90
Func_00_207b:
	ld a, $01
	call SetSpritePairPosition
	ret
Func_00_2081:
	ld a, [$d0e8]
	add a, $04
	ld d, a
	ld a, $05
	ld c, $00
	call SetOamByte
	ld a, $06
	call SetOamByte
	ret

Data_00_2094:
	ld a, c
	add a, $10
	ld b, a
	ld a, $04
	add a, e
	ld d, a
	ld a, b
	ld c, $03
	call SetOamByte
	ld a, e
	ld hl, wFloorMonsterSpecies
	rst AddAToHL
	ld a, [hl]
	add a, a
	add a, $32
	ld d, a
	ld a, b
	ld c, $02
	call SetOamByte
	ld a, [wEditCursorY]
	add a, a
	add a, a
	add a, a
	add a, $10
	ld d, a
	ld a, b
	ld c, $00
	call SetOamByte
	ld a, [wEditCursorX]
	add a, a
	add a, a
	add a, a
	add a, $08
	ld d, a
	ld a, b
	ld c, $01
	call SetOamByte
	ret

SetOamByte:
	ld hl, $c000
	add a, a
	add a, a
	add a, c
	rst AddAToHL
	ld [hl], d
	ret
SetEditCursorSprite:
	ld hl, $c000
	ld a, [wEditCursorY]
	add a, a
	add a, a
	add a, a
	add a, $10
	ld [hl+], a
	ld a, [wEditCursorX]
	add a, a
	add a, a
	add a, a
	add a, $08
	ld [hl], a
	ret
SetSpritePosition:
	ld hl, $c000
	add a, a
	add a, a
	rst AddAToHL
	ld a, b
	ld [hl+], a
	ld [hl], c
	ret
SetSpritePairPosition:
	ld hl, $c000
	add a, a
	add a, a
	rst AddAToHL
	ld a, b
	ld [hl+], a
	ld a, c
	ld [hl+], a
	inc hl
	inc hl
	ld a, b
	ld [hl+], a
	ld a, c
	add a, $08
	ld [hl+], a
	ret
SetSpriteTileAttr:
	ld hl, $c002
	add a, a
	add a, a
	rst AddAToHL
	ld a, b
	ld [hl+], a
	ld [hl], c
	ret
SetSpritePairTileAttr:
	ld hl, $c000
	add a, a
	add a, a
	add a, $02
	rst AddAToHL
	ld a, b
	ld [hl+], a
	ld a, c
	ld [hl+], a
	inc hl
	inc hl
	ld a, b
	add a, $08
	ld [hl+], a
	ld a, c
	ld [hl+], a
	ret
Func_00_212c:
	ld a, $04
	ld [wRoomType], a
	call LoadCurrentFloorRecordToBuffer
	ld a, [wFloorSnapshot]
	cp $ff
	jr z, Func_00_2140

Data_00_213b:
	xor a
	ld [$c55f], a
	ret

Func_00_2140:
	ld a, [CUR_BANK_TAG]
	push af
	ld a, $15
	ld [$2fff], a
	ld hl, $6d16
	ld de, $9800
	call CopyBgMap
	pop af
	ld [$2fff], a
	FAR_CALL Func_15_4147
	ld hl, $4978
	call Func_00_33fb
	xor a
	ld [$c55f], a
	call Func_00_3049
	call Func_00_21a5
	cp $02
	ret nc
	ld [wActiveFloor], a
	ld a, $03
	ld [wRoomType], a
	call LoadCurrentFloorRecordToBuffer
	ret
Func_00_217d:
	xor a
	ld [$c55f], a
	ld a, [CUR_BANK_TAG]
	push af
	ld a, $15
	ld [$2fff], a
	ld hl, $7182
	ld de, $9800
	call CopyBgMap
	pop af
	ld [$2fff], a
	FAR_CALL Func_15_4147
	ld a, [$c55f]
	call Func_00_3049
Func_00_21a5:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyPressed]
	ld b, a
	ld a, [$c55f]
	bit 4, b
	jr z, Func_00_21c4
	cp $02
	jr nc, Func_00_21a5
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	xor $01
	jr Func_00_221e
Func_00_21c4:
	bit 5, b
	jr z, Func_00_21d7
	cp $02
	jr nc, Func_00_21a5
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	xor $01
	jr Func_00_221e
Func_00_21d7:
	bit 7, b
	jr z, Func_00_21ec

Data_00_21db:
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	add a, $02
	cp $04
	jr c, Func_00_221e	; WARN: jr target $221e outside decoded range $21db-$21eb — wrong --addr? (jr needs the real base address)
	and $01
	jr Func_00_221e	; WARN: jr target $221e outside decoded range $21db-$21eb — wrong --addr? (jr needs the real base address)

Func_00_21ec:
	bit 6, b
	jr z, Func_00_2201

Data_00_21f0:
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	sub $02
	cp $80
	jr c, Func_00_221e	; WARN: jr target $221e outside decoded range $21f0-$2200 — wrong --addr? (jr needs the real base address)
	and $03
	jr Func_00_221e	; WARN: jr target $221e outside decoded range $21f0-$2200 — wrong --addr? (jr needs the real base address)

Func_00_2201:
	bit 0, b
	jr z, Func_00_220d
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_00_220d:
	bit 1, b
	jr z, Func_00_21a5
	push af
	ld a, SOUND_SFX_Cancel
	call PlaySound
	pop af
	ld a, $02
	ld [$c55f], a
	ret

Func_00_221e:
	call Func_00_3049
	jr Func_00_21a5
Func_00_2223:
	xor a
	ld [$c55f], a
	ld a, [CUR_BANK_TAG]
	push af
	ld a, $15
	ld [$2fff], a
	ld hl, $6f4c
	ld de, $9800
	call CopyBgMap
	pop af
	ld [$2fff], a
	FAR_CALL Func_15_4147
	ld a, $01
	ld [$c560], a
	ld b, a
	FAR_CALL Func_12_4441
Func_00_2253:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyRepeat]
	ld b, a
	ld a, [$c560]
	bit 4, b
	jr z, Func_00_228f
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	cp $20
	jr nc, Func_00_227f
	inc a
	cp $0f
	jr nz, Func_00_2275
	ld a, $01
Func_00_2275:
	cp $1f
	jp nz, Func_00_2319
	ld a, $11
	jp Func_00_2319
Func_00_227f:
	add a, $04
	cp $2f
	jr nz, Func_00_2287
	ld a, $2e
Func_00_2287:
	jp c, Func_00_2319
	ld a, $21
	jp Func_00_2319
Func_00_228f:
	bit 5, b
	jr z, Func_00_22bb
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	cp $20
	jr nc, Func_00_22ad
	dec a
	cp $00
	jr nz, $22a5
	ld a, $0e
	cp $10
	jr nz, Func_00_2319
	ld a, $1e
	jr Func_00_2319
Func_00_22ad:
	sub $04
	cp $20
	jr nz, Func_00_22b5
	ld a, $21
Func_00_22b5:
	jr nc, Func_00_2319
	ld a, $2e
	jr Func_00_2319
Func_00_22bb:
	bit 7, b
	jr z, Func_00_22d0
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	add a, $10
	cp $30
	jr c, Func_00_2319
Func_00_22cc:
	and $0f
	jr Func_00_2319
Func_00_22d0:
	bit 6, b
	jr z, Func_00_22e5
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	sub $10
	cp $80
	jr c, Func_00_2319
	add a, $30
	jr Func_00_2319
Func_00_22e5:
	bit 0, b
	jp z, Func_00_22f7
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	call Func_00_313d
	ret z
	jr Func_00_2319
Func_00_22f7:
	bit 1, b
	jp z, Func_00_2253
Func_00_22fc:
	push af
	ld a, SOUND_SFX_Cancel
	call PlaySound
	pop af
	ld b, a
	ld a, [$c55f]
	or a
	jr nz, Func_00_2313
	FAR_CALL BackupFloorRoomMarkers
	ret
Func_00_2313:
	dec a
	ld [$c55f], a
	jr Func_00_231a
Func_00_2319:
	ld b, a
Func_00_231a:
	FAR_CALL Func_12_4441
	jp Func_00_2253
OpenEditorActionMenu:
	xor a
	ld [wMenuCursor], a
	ld [wMenuCursorRow], a
	call Func_00_0bdd
	ld a, $15
	ld [$2fff], a
	ld hl, $68aa
	ld de, $9800
	call CopyBgMap
	ld a, [wMenuId]
	ld b, a
	FAR_CALL Func_12_44d6
	FAR_CALL Func_15_4241
Func_00_2351:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyPressed]
	ld b, a
	ld a, [wMenuId]
	bit 4, b
	jr z, Func_00_2369
	cp $06
	jr nc, Func_00_2351
	xor $01
	jr Func_00_23b5
Func_00_2369:
	bit 5, b
	jr z, Func_00_2375
	cp $06
	jr nc, Func_00_2351
	xor $01
	jr Func_00_23b5
Func_00_2375:
	bit 7, b
	jr z, Func_00_2383
	add a, $02
	cp $08
	jr c, Func_00_2381

Data_00_237f:
	and $01

Func_00_2381:
	jr Func_00_23b5
Func_00_2383:
	bit 6, b
	jr z, Func_00_2391
	sub $02
	cp $80
	jr c, Func_00_238f

Data_00_238d:
	and $07

Func_00_238f:
	jr Func_00_23b5
Func_00_2391:
	bit 0, b
	jr z, Func_00_23a2
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	call DispatchEditorMenuAction
	ret nz
	jr Func_00_23be
Func_00_23a2:
	bit 1, b
	jr z, Func_00_23be

Data_00_23a6:
	ld a, $06
	push af
	ld a, SOUND_SFX_Cancel
	call PlaySound
	pop af
	call DispatchEditorMenuAction
	ret nz
	jr Func_00_23be	; WARN: jr target $23be outside decoded range $23a6-$23b4 — wrong --addr? (jr needs the real base address)

Func_00_23b5:
	ld b, a
	FAR_CALL Func_12_44cf
Func_00_23be:
	call Func_00_3460
	jr Func_00_2351
DispatchEditorMenuAction:
	ld [wMenuId], a
	cp $04
	jr z, Func_00_23d8
	cp $05
	jr z, Func_00_23e8
	cp $06
	jr z, Func_00_2420
	cp $07
	jr z, Func_00_2420
	jr Func_00_2443
Func_00_23d8:
	call PackFloorSnapshot
	call Func_00_2fa2
	jr z, Func_00_2443
	ld hl, $5230
	call Func_00_3450
	xor a
	ret
Func_00_23e8:
	FAR_CALL Func_15_41b8
	call Func_00_217d
	or a
	jr nz, Func_00_2401
	call PackFloorSnapshot
	FAR_CALL SaveFloorToSram
Func_00_2401:
	call Func_00_0bdd
	ld a, $15
	ld [$2fff], a
	ld hl, $68aa
	ld de, $9800
	call CopyBgMap
	ld a, [wMenuId]
	ld b, a
	FAR_CALL Func_12_44d6
	xor a
	ret
Func_00_2420:
	ld hl, $4bb8
	call Func_00_33fb
	FAR_CALL Func_15_41b8
	call Func_00_217d
	cp $02
	jr nc, Func_00_2401
	or a
	jr nz, Func_00_2443
	call PackFloorSnapshot
	FAR_CALL SaveFloorToSram
Func_00_2443:
	or $01
	ret

Func_00_2446:
	ld a, [wMenuId]
	cp $03
	jr z, Func_00_2455
	call ToggleFloorCellFlag
	ret nz
	call $24a2
	ret
Func_00_2455:
	call $24a2
	ret nz
	call ToggleFloorCellFlag
	ret
ToggleFloorCellFlag:
	ld a, [wEditCursorY]
	ld b, a
	ld a, [wEditCursorX]
	ld c, a
	call ReadFloorCell
	ld hl, wFloorGrid
	ld a, c
	rst AddAToHL
	ld a, [wEditCursorY]
	ld b, a
	ld a, [wEditCursorX]
	ld c, a
	ldh a, [$ffac]
	bit 7, a
	ret z
	push af
	ld a, SOUND_SFX_01
	call PlaySound
	pop af
	bit 6, a
	jr nz, $248e
	set 6, a
	ld [hl], a
	call Func_00_1f71
	or $01
	ret
	res 6, a
	ld [hl], a
	or $01
	ret

SECTION "analyzed_002494", ROM0[$2494]

Data_00_2494:
	db $00

SECTION "analyzed_002495", ROM0[$2495]

Data_00_2495:
	db $00, $00, $00, $02, $00, $00, $01, $00, $05, $03, $ff, $ff, $04, $af, $ea, $66
	db $c5, $fa, $65, $c5, $47, $fa, $64, $c5, $4f, $cd, $3d, $10, $fe, $42, $20, $0d
	db $cd, $35, $25, $fe, $00, $c8, $3e, $06, $ea, $d2, $c7, $18, $18, $cd, $88, $2d
	db $c8, $7e, $fe, $03, $c8, $21, $cd, $c4, $c7, $7e, $21, $94, $24, $c7, $7e, $ea
	db $d2, $c7, $fe, $ff, $c8, $f5, $3e, $01, $cd, $85, $0a, $f1, $fe, $00, $20, $05
	db $cd, $e5, $25, $18, $32, $fe, $01, $20, $05, $cd, $26, $26, $18, $29, $fe, $02
	db $20, $05, $cd, $79, $26, $18, $20, $fe, $03, $20, $05, $cd, $d0, $26, $18, $17
	db $fe, $04, $20, $05, $cd, $15, $27, $18, $0e, $fe, $05, $20, $05, $cd, $58, $27
	db $18, $05, $cd, $a5, $27, $18, $08, $cd, $54, $2c, $3e, $01, $ea, $e9, $d0, $cd
	db $c0, $28, $3e, $02, $ea, $e9, $d0, $cd, $6c, $1a, $cd, $cf, $30, $f6, $01, $c9
	db $21, $cd, $c4, $2a, $fe, $03, $38, $12, $2a, $fe, $03, $38, $0d, $2a, $fe, $03
	db $38, $08, $21, $38, $50, $cd, $50, $34, $af, $c9, $21, $fe, $c4, $fa, $64, $c5
	db $57, $fa, $65, $c5, $47, $0e, $00, $2a, $ba, $20, $39, $2a, $b8, $20, $36, $16
	db $00, $2a, $ea, $cf, $c7, $2a, $ea, $ce, $c7, $2a, $ea, $cd, $c7, $2a, $fe, $ff
	db $28, $03, $14, $18, $f8, $7a, $fe, $00, $20, $0f, $fa, $6e, $c5, $fe, $09, $20
	db $08, $21, $80, $50, $cd, $50, $34, $af, $c9, $7a, $ea, $cb, $c7, $79, $ea, $cc
	db $c7, $3e, $01, $c9, $23, $3e, $0a, $c7, $0c, $3e, $04, $b9, $20, $b9, $c9

NormalizeMonsterTableFlags:
	ld c, $09
	ld hl, wFloorMonsterTable
Func_00_25a9:
	inc hl
	inc hl
	inc hl
	push hl
	inc hl
	ld a, [hl]
	ld hl, wFloorMonsterSpecies
	rst AddAToHL
	ld a, [hl]
	ld hl, $2494
	rst AddAToHL
	ld a, [hl]
	pop hl
	cp $01
	jr z, Func_00_25d0
	cp $03
	jr z, Func_00_25d6
	cp $04
	jr z, Func_00_25d6
	cp $05
	jr z, Func_00_25dc
	ld a, [hl]
	and $01
	ld [hl+], a
	jr Func_00_25e0

Func_00_25d0:
	ld a, [hl]
	or $02
	ld [hl+], a
	jr Func_00_25e0
Func_00_25d6:
	ld a, [hl]
	and $03
	ld [hl+], a
	jr Func_00_25e0
Func_00_25dc:
	ld a, [hl]
	and $07
	ld [hl+], a

Func_00_25e0:
	inc hl
	dec c
	jr nz, Func_00_25a9
	ret

Func_00_25e5:
	ld a, $02
	ld [wMenuItemCount], a
	ld a, $10
	ld [$2fff], a
	ld hl, $6737
	ld de, $9800
	call CopyBgMap
	call Func_00_3121
	call Func_00_289d
	ld b, $30
	ld a, [$c7cd]
	and $0f
	ld [$c7d3], a
	swap a
	add a, $38
	ld c, a
	ld a, $03
	call SetSpritePosition
	ld b, $48
	ld a, [$c7ce]
	ld [$c7d4], a
	swap a
	add a, a
	add a, $44
	ld c, a
	ld a, $04
	call SetSpritePosition
	ret
	ld a, $02
	ld [wMenuItemCount], a
	ld a, $10
	ld [$2fff], a
	ld hl, $6737
	ld de, $9800
	call CopyBgMap
	call Func_00_3121
	ld bc, $0907
	ld a, $ba
	call Func_00_1f48
	ld bc, $090b
	ld a, $bb
	call Func_00_1f48
	call Func_00_289d
	ld b, $30
	ld a, [$c7cd]
	and $0f
	ld [$c7d3], a
	swap a
	add a, $38
	ld c, a
	ld a, $03
	call SetSpritePosition
	ld b, $48
	ld a, [$c7ce]
	sub $02
	ld [$c7d4], a
	swap a
	add a, a
	add a, $44
	ld c, a
	ld a, $04
	call SetSpritePosition
	ret
	ld a, $03
	ld [wMenuItemCount], a
	ld a, $10
	ld [$2fff], a
	ld hl, $696d
	ld de, $9800
	call CopyBgMap
	call Func_00_3121
	call Func_00_289d
	ld b, $28
	ld a, [$c7cd]
	and $0f
	ld [$c7d3], a
	swap a
	add a, $38
	ld c, a
	ld a, $03
	call SetSpritePosition
	ld b, $38
	ld a, [$c7ce]
	ld [$c7d4], a
	swap a
	add a, a
	add a, $44
	ld c, a
	ld a, $04
	call SetSpritePosition
	ld b, $58
	ld a, [$c7cd]
	and $f0
	swap a
	ld [$c7d5], a
	swap a
	add a, $38
	ld c, a
	ld a, $05
	call SetSpritePosition
	ret
	ld a, $02
	ld [wMenuItemCount], a
	ld a, $10
	ld [$2fff], a
	ld hl, $6ba3
	ld de, $9800
	call CopyBgMap
	call Func_00_3121
	call Func_00_289d
	ld b, $28
	ld a, [$c7ce]
	ld [$c7d3], a
	swap a
	ld c, a
	rrca
	add a, c
	add a, $34
	ld c, a
	ld a, $03
	call SetSpritePosition
	ld b, $50
	ld a, [$c7cd]
	and $f0
	swap a
	ld [$c7d4], a
	swap a
	add a, $38
	ld c, a
	ld a, $04
	call SetSpritePosition
	ret
	ld a, $02
	ld [wMenuItemCount], a
	ld a, $10
	ld [$2fff], a
	ld hl, $6dd9
	ld de, $9800
	call CopyBgMap
	call Func_00_3121
	call Func_00_289d
	ld b, $30
	ld a, [$c7cd]
	and $0f
	ld [$c7d3], a
	swap a
	add a, $38
	ld c, a
	ld a, $03
	call SetSpritePosition
	ld b, $48
	ld a, [$c7ce]
	ld [$c7d4], a
	swap a
	ld c, a
	rrca
	add a, c
	add a, $34
	ld c, a
	ld a, $04
	call SetSpritePosition
	ret
	ld a, $02
	ld [wMenuItemCount], a
	ld a, $10
	ld [$2fff], a
	ld hl, $700f
	ld de, $9800
	call CopyBgMap
	call Func_00_3121
	call Func_00_289d
	ld b, $28
	ld a, [$c7cd]
	and $0f
	ld [$c7d3], a
	swap a
	add a, $38
	ld c, a
	ld a, $03
	call SetSpritePosition
	ld a, [$c7ce]
	ld [$c7d4], a
	bit 2, a
	jr nz, Func_00_2793
	ld b, $38
	jr Func_00_2795
Func_00_2793:
	ld b, $50
Func_00_2795:
	and $03
	swap a
	ld c, a
	rrca
	add a, c
	add a, $34
	ld c, a
	ld a, $04
	call SetSpritePosition
	ret
Func_00_27a5:
	ld a, $02
	ld [wUiState], a
	ld a, $10
	ld [$2fff], a
	ld hl, $747b
	ld de, $9800
	call CopyBgMap
	ld a, $16
	ld [wDrawBank], a
	ld hl, $75c4
	ld bc, $1008
	call DrawMetasprite
	call HideUnusedOamSprites
	ld hl, $4fa8
	call Func_00_33fb
	ld a, [$c56e]
	ld e, a
	ld a, $09
	sub e
	ld e, a
	ld a, [$c7cb]
	add a, e
	cp $06
	jr c, Func_00_27e1
	ld a, $06
Func_00_27e1:
	ld [$c7d1], a
	ld e, a
	ld d, $00
	ld hl, wFloorSpawnerTable
	ld a, [$c7cc]
	add a, a
	add a, a
	ld c, a
	add a, a
	add a, c
	add a, $05
	rst AddAToHL
	ld a, [hl]
	ld [wGridCol], a
Func_00_27f9:
	ld a, [hl+]
	call DrawMonsterIconSprite
	inc d
	dec e
	jr nz, Func_00_27f9
	ld a, [$c7cb]
	inc a
	cp $07
	jr c, Func_00_280b
	ld a, $06
Func_00_280b:
	ld [wMenuItemCount], a
	xor a
	ld [wGridRow], a
	ld a, [wGridCol]
	cp $ff
	jr nz, Func_00_281b
	ld a, $03
Func_00_281b:
	ld [wGridCol], a
	ret
Func_00_281f:
	ld a, $03
	ld [wMenuItemCount], a
	ld a, $10
	ld [$2fff], a
	ld hl, $7245
	ld de, $9800
	call CopyBgMap
	call Func_00_3121
	call Func_00_289d
	ld bc, $f0f0
	ld a, $00
	call SetSpritePairPosition
	ld bc, $1890
	ld a, $0f
	call SetSpritePairPosition
	ld b, $28
	ld a, [$c7cf]
	ld [$c7d3], a
	swap a
	add a, $38
	ld c, a
	ld a, $03
	call SetSpritePosition
	ld b, $38
	ld a, [$c7ce]
	ld [$c7d4], a
	swap a
	add a, a
	add a, $34
	ld c, a
	ld a, $04
	call SetSpritePosition
	ld b, $58
	ld a, [$c7cd]
	ld [$c7d5], a
	swap a
	add a, $38
	ld c, a
	ld a, $05
	call SetSpritePosition
	ret
DrawMonsterIconSprite:
	cp $ff
	jr z, Func_00_288f
	ld c, a
	add a, a
	swap a
	ld b, a
	ld a, $0c
	add a, c
	ld c, a
	jr Func_00_2893
Func_00_288f:
	ld b, $60
	ld c, $00
Func_00_2893:
	ld a, d
	add a, a
	add a, $03
	push hl
	call SetSpritePairTileAttr
	pop hl
	ret
Func_00_289d:
	ld a, $16
	ld [wDrawBank], a
	ld hl, TilesetMetasprite
	ld bc, $1008
	call DrawMetasprite
	call HideUnusedOamSprites
	ld a, [$c7cb]
	add a, a
	swap a
	ld b, a
	ld a, [$c7cb]
	add a, $0c
	ld c, a
	xor a
	call SetSpritePairTileAttr
	ret
Func_00_28c0:
	call WaitForNextFrame
	call ReadJoypad
	ld a, [wUiState]
	cp $01
	jr nz, Func_00_28d2
	call Func_00_28fb
	jr Func_00_28d5
Func_00_28d2:
	call Func_00_2a05
Func_00_28d5:
	ld a, [wUiTimer]
	inc a
	ld [wUiTimer], a
	and $08
	rrca
	rrca
	ld b, a
	ld a, [$c7d2]
	cp $06
	jr nz, Func_00_28f3
	ld a, $64
	add a, b
	ld b, a
	ld c, $00
	ld a, $0f
	call SetSpritePairTileAttr
Func_00_28f3:
	ld a, [wUiState]
	cp $00
	jr nz, Func_00_28c0
	ret
Func_00_28fb:
	ldh a, [hJoyRepeat]
	ld b, a
	bit 7, b
	jr z, Func_00_2922
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ld a, [wMenuItemCount]
	ld c, a
	ld a, [wGridRow]
	inc a
	cp c
	jr nz, Func_00_2916
	ld a, $00
Func_00_2916:
	ld [wGridRow], a
	call SetGridColumnsForRow
	call Func_00_3121
	jp Func_00_29d7
Func_00_2922:
	bit 6, b
	jr z, Func_00_2945
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ld a, [wGridRow]
	dec a
	cp $80
	jr c, Func_00_2939
	ld a, [wMenuItemCount]
	dec a
Func_00_2939:
	ld [wGridRow], a
	call SetGridColumnsForRow
	call Func_00_3121
	jp Func_00_29d7
Func_00_2945:
	bit 4, b
	jr z, Func_00_296d
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ld a, [wGridColCount]
	ld c, a
	ld a, [wGridCol]
	inc a
	cp c
	jr nz, Func_00_295d
	ld a, $00
Func_00_295d:
	ld [wGridCol], a
	ld hl, $c7d3
	ld a, [wGridRow]
	rst AddAToHL
	ld a, [wGridCol]
	ld [hl], a
	jr Func_00_29d7
Func_00_296d:
	bit 5, b
	jr z, Func_00_2994
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ld a, [wGridCol]
	dec a
	cp $80
	jr c, Func_00_2984
	ld a, [wGridColCount]
	dec a
Func_00_2984:
	ld [wGridCol], a
	ld hl, $c7d3
	ld a, [wGridRow]
	rst AddAToHL
	ld a, [wGridCol]
	ld [hl], a
	jr Func_00_29d7
Func_00_2994:
	bit 0, b
	jr z, Func_00_29c1
	ld a, [$c7d2]
	cp $06
	jr nz, Func_00_29c1
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ld a, [$c7d3]
	ld [$c7cf], a
	ld a, [$c7d4]
	ld [$c7ce], a
	ld a, [$c7d5]
	ld [$c7cd], a
	call Func_00_27a5
	ld a, $02
	ld [wUiState], a
	ret
Func_00_29c1:
	ldh a, [hJoyPressed]
	bit 1, a
	jr nz, Func_00_29cb
	bit 2, a
	jr z, Func_00_29d7
Func_00_29cb:
	push af
	ld a, SOUND_SFX_Cancel
	call PlaySound
	pop af
	ld a, $00
	ld [wUiState], a
Func_00_29d7:
	ld a, [wUiTimer]
	rrca
	rrca
	and $03
	push af
	ld hl, $1be1
	rst AddAToHL
	ld d, [hl]
	ld a, $02
	ld c, $02
	call SetOamByte
	call Func_00_2bf1
	pop af
	ld hl, $1bd9
	rst AddAToHL
	ld d, [hl]
	ld a, [wGridRow]
	add a, $03
	ld c, $02
	call SetOamByte
	call Func_00_2cf9
	call Func_00_2c85
	ret
Func_00_2a05:
	ldh a, [hJoyRepeat]
	ld b, a
	bit 7, b
	jr z, Func_00_2a25
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
Func_00_2a13:
	ld a, [wGridCol]
	inc a
	cp $04
	jr nz, Func_00_2a1d
	ld a, $00
Func_00_2a1d:
	call CheckGridCellSelectable
	jr nz, Func_00_2a13
	jp Func_00_2ab6
Func_00_2a25:
	bit 6, b
	jr z, Func_00_2a41
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
Func_00_2a30:
	ld a, [wGridCol]
	dec a
	cp $80
	jr c, Func_00_2a3a
	ld a, $03
Func_00_2a3a:
	call CheckGridCellSelectable
	jr nz, Func_00_2a30
	jr Func_00_2ab6
Func_00_2a41:
	bit 4, b
	jr z, Func_00_2a60
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ld a, [wMenuItemCount]
	ld c, a
	ld a, [wGridRow]
	inc a
	cp c
	jr nz, Func_00_2a58
	xor a
Func_00_2a58:
	ld [wGridRow], a
	call LoadSpawnerColumnForRow
	jr Func_00_2ab6
Func_00_2a60:
	bit 5, b
	jr z, Func_00_2a7f
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ld a, [wGridRow]
	dec a
	cp $80
	jr c, Func_00_2a77
	ld a, [wMenuItemCount]
	dec a
Func_00_2a77:
	ld [wGridRow], a
	call LoadSpawnerColumnForRow
	jr Func_00_2ab6
Func_00_2a7f:
	bit 0, b
	jr z, Func_00_2a9d
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	xor a
	ld [wGridRow], a
	call Func_00_281f
	call SetGridColumnsForRow
	ld a, $01
	ld [wUiState], a
	call Func_00_2bb8
	ret
Func_00_2a9d:
	ldh a, [hJoyPressed]
	bit 1, a
	jr nz, Func_00_2aa7
	bit 2, a
	jr z, Func_00_2ab6
Func_00_2aa7:
	push af
	ld a, SOUND_SFX_Cancel
	call PlaySound
	pop af
	ld a, $00
	ld [wUiState], a
	call Func_00_2bb8
Func_00_2ab6:
	ld a, [wUiTimer]
	rrca
	rrca
	and $03
	push af
	ld hl, $1be1
	rst AddAToHL
	ld d, [hl]
	ld a, $00
	ld c, $02
	call SetOamByte
	pop af
	ld hl, $1bd9
	rst AddAToHL
	ld d, [hl]
	ld a, $01
	ld c, $02
	call SetOamByte
	ld a, $02
	call SetOamByte
	call Func_00_2b1b
	ld a, [wGridRow]
	ld d, a
	ld a, [wGridCol]
	cp $03
	jr nz, Func_00_2aec
	ld a, $ff
Func_00_2aec:
	call DrawMonsterIconSprite
	call StoreSpawnerColumnForRow
	call CountSpawnerEntries
	ret
CheckGridCellSelectable:
	ld [wGridCol], a
	cp $03
	jr nz, Func_00_2b0d
	ld a, [wGridRow]
	inc a
	cp $06
	jr c, Func_00_2b07
	ld a, $06
Func_00_2b07:
	ld c, a
	ld a, [$c7cb]
	cp c
	ret
Func_00_2b0d:
	ld hl, wFloorMonsterSpecies
	rst AddAToHL
	ld a, [hl]
	cp $03
	jr nc, Func_00_2b18
	xor a
	ret
Func_00_2b18:
	or $01
	ret
Func_00_2b1b:
	ld a, [wGridRow]
	ld e, a
	sub $03
	jr nc, Func_00_2b27
	ld b, $38
	jr Func_00_2b2a
Func_00_2b27:
	ld b, $58
	ld e, a
Func_00_2b2a:
	ld a, e
	swap a
	rlca
	add a, $28
	ld c, a
	ld a, $00
	call SetSpritePosition
	ld a, b
	sub $08
	ld b, a
	ld a, c
	add a, $0c
	ld c, a
	ld a, $01
	call SetSpritePosition
	ld a, b
	add a, $10
	ld b, a
	ld a, $02
	call SetSpritePosition
	ret
LoadSpawnerColumnForRow:
	ld hl, wFloorSpawnerTable
	ld a, [$c7cc]
	add a, a
	add a, a
	ld c, a
	add a, a
	add a, c
	add a, $05
	ld c, a
	ld a, [wGridRow]
	add a, c
	rst AddAToHL
	ld a, [hl]
	cp $ff
	jr nz, Func_00_2b67
	ld a, $03
Func_00_2b67:
	ld [wGridCol], a
	ret
StoreSpawnerColumnForRow:
	ld hl, wFloorSpawnerTable
	ld a, [$c7cc]
	add a, a
	add a, a
	ld c, a
	add a, a
	add a, c
	add a, $05
	ld c, a
	ld a, [wGridRow]
	add a, c
	rst AddAToHL
	ld a, [wGridCol]
	cp $03
	jr nz, Func_00_2b87
	ld a, $ff
Func_00_2b87:
	ld [hl], a
	ret
CountSpawnerEntries:
	ld hl, wFloorSpawnerTable
	ld a, [$c7cc]
	add a, a
	add a, a
	ld c, a
	add a, a
	add a, c
	add a, $05
	rst AddAToHL
	ld d, $00
Func_00_2b99:
	ld a, [hl+]
	cp $ff
	jr z, Func_00_2ba1
	inc d
	jr Func_00_2b99
Func_00_2ba1:
	ld a, [$c7d1]
	ld c, a
	ld a, d
	ld [$c7cb], a
	inc a
	cp $07
	jr c, Func_00_2bb0
	ld a, $06
Func_00_2bb0:
	cp c
	jr c, Func_00_2bb4
	ld a, c
Func_00_2bb4:
	ld [wMenuItemCount], a
	ret
Func_00_2bb8:
	ld d, $00
	ld c, $09
	ld hl, wFloorMonsterTable
Func_00_2bbf:
	ld a, [hl]
	cp $ff
	jr z, Func_00_2bc5
	inc d
Func_00_2bc5:
	ld a, $05
	rst AddAToHL
	dec c
	jr nz, Func_00_2bbf
	ld c, $04
	ld hl, wFloorSpawnerTable
Func_00_2bd0:
	ld a, [hl+]
	cp $ff
	jr z, Func_00_2be6
	ld a, $04
	rst AddAToHL
	ld e, $06
Func_00_2bda:
	ld a, [hl+]
	cp $ff
	jr z, Func_00_2be0
	inc d
Func_00_2be0:
	dec e
	jr nz, Func_00_2bda
	inc hl
	jr Func_00_2be9
Func_00_2be6:
	ld a, $0b
	rst AddAToHL
Func_00_2be9:
	dec c
	jr nz, Func_00_2bd0
	ld a, d
	ld [$c56e], a
	ret
Func_00_2bf1:
	ld c, $00
	ld a, [$c7d2]
	cp $02
	jr z, Func_00_2c11
	cp $05
	jr z, Func_00_2c2c
	cp $06
	jr z, Func_00_2c11
	ld a, [wGridRow]
	swap a
	add a, a
	add a, $38
	ld d, a
	ld a, $02
	call SetOamByte
	ret
Func_00_2c11:
	ld a, [wGridRow]
	cp $00
	jr nz, Func_00_2c1c
	ld d, $30
	jr Func_00_2c26
Func_00_2c1c:
	cp $01
	jr nz, Func_00_2c24
	ld d, $48
	jr Func_00_2c26
Func_00_2c24:
	ld d, $60
Func_00_2c26:
	ld a, $02
	call SetOamByte
	ret
Func_00_2c2c:
	ld a, [wGridRow]
	cp $00
	jr nz, Func_00_2c37
	ld d, $30
	jr Func_00_2c39
Func_00_2c37:
	ld d, $54
Func_00_2c39:
	ld a, $02
	call SetOamByte
	ret
	dec b
	ld [bc], a
	nop
	dec b
	ld [bc], a
	nop
	dec b
	ld [bc], a
	dec b
	inc b
	dec b
	nop
	dec b
	inc b
	nop
	dec b
	ld [$0500], sp
	inc bc
	dec b
SetGridColumnsForRow:
	ld hl, $2c3f
	ld a, [$c7d2]
	ld c, a
	add a, a
	add a, c
	ld c, a
	ld a, [wGridRow]
	add a, c
	rst AddAToHL
	ld a, [hl]
	ld [wGridColCount], a
	ld hl, $c7d3
	ld a, [wGridRow]
	rst AddAToHL
	ld a, [hl]
	ld [wGridCol], a
	ret
	nop
	ld bc, $00ff
	ld [bc], a
	rst $38
	nop
	ld bc, $0103
	inc bc
	rst $38
	nop
	inc b
	rst $38
	nop
	dec b
	rst $38
Func_00_2c85:
	ld a, [$c7d2]
	cp $06
	jr z, Func_00_2ce1
	ld hl, wFloorMonsterTable
	ld a, [$c7cc]
	ld c, a
	add a, a
	add a, a
	add a, c
	add a, $02
	rst AddAToHL
	ld de, $2c73
	ld a, [$c7d2]
	ld c, a
	add a, a
	add a, c
	ld c, a
	ld a, [wGridRow]
	add a, c
	rst AddAToDE
	ld a, [de]
	cp $01
	jr z, Func_00_2cc7
	cp $02
	jr z, Func_00_2ccd
	cp $03
	jr z, Func_00_2cd5
	cp $04
	jr z, Func_00_2cc7
	cp $05
	jr z, Func_00_2cc7
	ld a, [wGridCol]
	ld c, a
	ld a, [hl]
	and $f0
	or c
	ld [hl], a
	ret
Func_00_2cc7:
	inc hl
	ld a, [wGridCol]
	ld [hl], a
	ret
Func_00_2ccd:
	inc hl
	ld a, [wGridCol]
	add a, $02
	ld [hl], a
	ret
Func_00_2cd5:
	ld a, [wGridCol]
	swap a
	ld c, a
	ld a, [hl]
	and $0f
	or c
	ld [hl], a
	ret
Func_00_2ce1:
	ld hl, wFloorSpawnerTable
	ld a, [$c7cc]
	add a, a
	add a, a
	ld c, a
	add a, a
	add a, c
	add a, $02
	ld c, a
	ld a, [wGridRow]
	add a, c
	rst AddAToHL
	ld a, [wGridCol]
	ld [hl], a
	ret
Func_00_2cf9:
	ld hl, $2c3f
	ld a, [$c7d2]
	ld c, a
	add a, a
	add a, c
	ld c, a
	ld a, [wGridRow]
	add a, c
	rst AddAToHL
	ld a, [hl]
	cp $05
	jr z, Func_00_2d1d
	cp $02
	jr z, Func_00_2d30
	cp $04
	jr z, Func_00_2d44
	cp $08
	jr z, Func_00_2d5a
	cp $03
	jr z, Func_00_2d77
Func_00_2d1d:
	ld a, [wGridCol]
	swap a
	add a, $38
	ld d, a
	ld c, $01
	ld a, [wGridRow]
	add a, $03
	call SetOamByte
	ret
Func_00_2d30:
	ld a, [wGridCol]
	swap a
	add a, a
	add a, $44
	ld d, a
	ld c, $01
	ld a, [wGridRow]
	add a, $03
	call SetOamByte
	ret
Func_00_2d44:
	ld a, [wGridCol]
	swap a
	ld d, a
	rrca
	add a, d
	add a, $34
	ld d, a
	ld c, $01
	ld a, [wGridRow]
	add a, $03
	call SetOamByte
	ret
Func_00_2d5a:
	ld a, [wGridCol]
	bit 2, a
	jr nz, Func_00_2d65
	ld b, $38
	jr Func_00_2d67
Func_00_2d65:
	ld b, $50
Func_00_2d67:
	and $03
	swap a
	ld c, a
	rrca
	add a, c
	add a, $34
	ld c, a
	ld a, $04
	call SetSpritePosition
	ret
Func_00_2d77:
	ld a, [wGridCol]
	swap a
	add a, a
	add a, $34
	ld d, a
	ld c, $01
	ld a, $04
	call SetOamByte
	ret

FindMonsterAtCursor:
	ld hl, wFloorMonsterTable
	ld a, [wEditCursorX]
	ld d, a
	ld a, [wEditCursorY]
	ld b, a
	ld c, $00
Func_00_2d95:
	ld a, [hl+]
	cp d
	jr nz, Func_00_2db0
	ld a, [hl+]
	cp b
	jr nz, Func_00_2db1
	ld a, [hl+]
	ld [$c7cd], a
	ld a, [hl+]
	ld [$c7ce], a
	ld a, [hl]
	ld [$c7cb], a
	ld a, c
	ld [$c7cc], a
	or $01
	ret

Func_00_2db0:
	inc hl
Func_00_2db1:
	inc hl
	inc hl
	inc hl
	inc c
	ld a, $09
	cp c
	jr nz, Func_00_2d95
	xor a
	ret
Func_00_2dbc:
	ld hl, $c571
	ld d, $0a
Func_00_2dc1:
	push de
	ld a, [hl+]
	push hl
	cp $ff
	jr z, Func_00_2def
	ld c, a
	ld a, [hl]
	ld b, a
	push bc
	call ReadFloorCell
	pop bc
	cp $00
	jr nz, Func_00_2dda
	ldh a, [$ffac]
	bit 6, a
	jr nz, Func_00_2def

Func_00_2dda:
	ld a, [wUiTimer]
	and $10
	jr nz, Func_00_2de8
	ldh a, [$ffab]
	call Func_00_1f71
	jr Func_00_2def
Func_00_2de8:
	ldh a, [$ffac]
	set 6, a
	call Func_00_1f71

Func_00_2def:
	pop hl
	inc hl
	pop de
	dec d
	jr nz, Func_00_2dc1
	ret
InitFloorEditorState:
	xor a
	ld [wMenuId], a
	ld [$c585], a
	ld a, $01
	ld [wEditCursorX], a
	ld [wEditCursorY], a
	ld a, $ff
	ld [wSpawnCellX], a
	ld [wSpawnCellY], a
	ld [$c530], a
	ld [$c531], a
	ld b, $00
	ld c, $09
	ld hl, wFloorMonsterTable
Func_00_2e1a:
	ld a, [hl+]
	cp $ff
	jr z, Func_00_2e20
	inc b
Func_00_2e20:
	ld a, $04
	rst AddAToHL
	dec c
	jr nz, Func_00_2e1a
	ld a, b
	ld [$c56e], a
	ld b, $00
	ld c, $04
	ld hl, wFloorSpawnerTable
Func_00_2e31:
	ld a, [hl+]
	cp $ff
	jr z, Func_00_2e37
	inc b
Func_00_2e37:
	ld a, $0b
	rst AddAToHL
	dec c
	jr nz, Func_00_2e31
	ld a, b
	ld [$c570], a
	ret
Func_00_2e42:
	ld hl, $c571
	ld a, [wEditCursorY]
	ld b, a
	ld a, [wEditCursorX]
	ld c, a
Func_00_2e4d:
	ld a, [hl]
	cp $ff
	jr z, Func_00_2e56
	inc hl
	inc hl
	jr Func_00_2e4d
Func_00_2e56:
	ld a, c
	ld [hl+], a
	ld a, b
	ld [hl], a
	ld a, [$c56f]
	inc a
	ld [$c56f], a
	ret

RemoveCursorCellFromList:
	ld a, [wEditCursorY]
	ld b, a
	ld a, [wEditCursorX]
	ld c, a

Func_00_2e6a:
	ld hl, $c571
Func_00_2e6d:
	ld a, [hl+]
	cp c
	jr nz, Func_00_2e75
	ld a, [hl]
	cp b
	jr z, Func_00_2e78

Func_00_2e75:
	inc hl
	jr Func_00_2e6d

Func_00_2e78:
	ld a, $ff
	ld [hl-], a
	ld [hl], a
	ld a, [$c56f]
	dec a
	ld [$c56f], a
	ret
ClearEditCellList:
	ld hl, $c571
	ld b, $14
Func_00_2e89:
	ld a, $ff
	ld [hl+], a
	dec b
	jr nz, Func_00_2e89
	xor a
	ld [$c56f], a
	ret

Func_00_2e94:
	ld hl, $c571
	ld a, [$c56f]
	add a, a
	rst AddAToHL
	ld a, c
	ld [hl+], a
	ld a, b
	ld [hl], a
	ld a, [$c56f]
	inc a
	ld [$c56f], a
	ret

Func_00_2ea8:
	ldh a, [$ffac]
	cp $40
	jr nz, Func_00_2eb7

ClearSpawnCell:
	ld a, $ff
	ld [wSpawnCellX], a
	ld [wSpawnCellY], a
	ret

Func_00_2eb7:
	cp $42
	jr nz, Func_00_2efa

Func_00_2ebb:
	ld hl, wFloorSpawnerTable
	ld d, $04
	ld a, [wEditCursorY]
	ld b, a
	ld a, [wEditCursorX]
	ld c, a
	ld a, [hl+]
	cp c
	jr nz, $2ef3
	ld a, [hl]
	cp b
	jr nz, $2ef3
	ld d, $00
	ld a, $ff
	ld c, a
	dec hl
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld a, [hl]
	cp c
	jr z, $2ee4
	ld a, c
	ld [hl+], a
	inc d
	jr $2edb
	ld a, [$c570]
	dec a
	ld [$c570], a
	ld a, [$c56e]
	sub d
	ld [$c56e], a
	ret
	ld a, $0b
	rst AddAToHL
	dec d
	jr nz, $2ec8
	ret
Func_00_2efa:
	ret

ClearCollisionCell:
	ld a, $ff
	ld [$c530], a
	ld [$c531], a
	ret

Func_00_2f04:
	cp $40
	jr nz, Func_00_2f38
	ld a, [wSpawnCellX]
	cp $ff
	jr z, Func_00_2f2b

Data_00_2f0f:
	ld a, [wSpawnCellY]
	ld b, a
	ld h, a
	ld a, [wSpawnCellX]
	ld l, a
	ld a, $11
	ld c, a
	call Multiply8
	add a, l
	ld de, wFloorGrid
	rst AddAToDE
	ld c, l
	ld b, h
	ld a, $00
	ld [de], a
	call Func_00_1f71

Func_00_2f2b:
	ld a, [wEditCursorX]
	ld [wSpawnCellX], a
	ld a, [wEditCursorY]
	ld [wSpawnCellY], a
	ret

Func_00_2f38:
	cp $42
	jr nz, Func_00_2f64
	ld hl, wFloorSpawnerTable
	ld d, $04
Func_00_2f41:
	ld a, [hl]
	cp $ff
	jr z, Func_00_2f4b
	ld a, $0c
	rst AddAToHL
	jr Func_00_2f41
Func_00_2f4b:
	ld a, [wEditCursorX]
	ld [hl+], a
	ld a, [wEditCursorY]
	ld [hl+], a
	ld a, $02
	ld [hl+], a
	ld a, $00
	ld [hl+], a
	ld a, $02
	ld [hl+], a
	ld a, [$c570]
	inc a
	ld [$c570], a
	ret
Func_00_2f64:
	ret

Func_00_2f65:
	ld a, [$c530]
	cp $ff
	jr z, Func_00_2f95
	push de
	push hl
	ld a, [$c531]
	ld b, a
	ld h, a
	ld a, [$c530]
	ld l, a
	ld a, $11
	ld c, a
	call Multiply8
	add a, l
	ld de, wFloorCollision
	rst AddAToDE
	ld c, l
	ld b, h
	call Func_00_2e6a
	ld a, [de]
	ld l, a
	ld a, $ee
	rst AddAToDE
	ld a, $00
	ld [de], a
	ld a, l
	call Func_00_1f71
	pop hl
	pop de
Func_00_2f95:
	ld a, [wEditCursorX]
	ld [$c530], a
	ld a, [wEditCursorY]
	ld [$c531], a
	ret
Func_00_2fa2:
	ld hl, $c58c
	ld a, [hl+]
	cp $ff
	jr nz, Func_00_2fad
	or $01
	ret
Func_00_2fad:
	ld b, a
	ld c, [hl]
	call Multiply8
	ld c, a
	ld hl, $c58e
	rst AddAToHL
	ld d, $00
Func_00_2fb9:
	ld a, [hl+]
	cp $40
	jr nz, Func_00_2fc1
	inc d
	jr Func_00_2fcd
Func_00_2fc1:
	cp $c0
	jr nz, Func_00_2fc8
	inc d
	jr Func_00_2fcd
Func_00_2fc8:
	cp $80
	jr nz, Func_00_2fcd
	inc d
Func_00_2fcd:
	dec c
	jr nz, Func_00_2fb9
	ld a, $02
	cp d
	ret

; PackFloorSnapshot: the inverse of ParseFloorRecord -- re-pack the *live* WRAM
; floor (header fields + the collision/piece grids + arr1/2/3, with the 17-wide
; row stride removed) into the front of wFloorSnapshot, so the editor/preview
; captures the current floor state (player + revealed items). Leaves the buffer's
; trailer bytes untouched (they come from the last LoadFloorRecordToBuffer).
PackFloorSnapshot:
	ld hl, wFloorSnapshot
	ld a, [wFloorId]
	ld [hl+], a
	ld a, [$c2ea]
	ld [hl+], a
	ld a, [$c2eb]
	ld [hl+], a
	ld a, [$c2e9]
	ld [hl+], a
	ld a, [wFloorTileset]
	ld [hl+], a
	ld a, [wFloorPalette]
	ld [hl+], a
	ld a, [wFloorHeight]
	ld [hl+], a
	ld a, [wFloorWidth]
	ld [hl+], a
	ld c, a
	ld a, $11
	sub c
	ld [wFloorRowStride], a
	ld de, wFloorCollision
	ld a, [wFloorHeight]
	ld b, a
.copyCollision:
	ld a, [wFloorWidth]
	ld c, a
	call CopyDEtoHL
	ld a, [wFloorRowStride]
	rst AddAToDE
	dec b
	jr nz, .copyCollision
	ld de, wFloorGrid
	ld a, [wFloorHeight]
	ld b, a
.copyPieces:
	ld a, [wFloorWidth]
	ld c, a
	call CopyDEtoHL
	ld a, [wFloorRowStride]
	rst AddAToDE
	dec b
	jr nz, .copyPieces
	ld c, $04
	ld de, wFloorMonsterSpecies
	call CopyDEtoHL
	ld c, $2d
	ld de, wFloorMonsterTable
	call CopyDEtoHL
	ld c, $30
	ld de, wFloorSpawnerTable
	call CopyDEtoHL
	ret

Data_00_3041:
	db $01, $99, $0b, $99

Func_00_3045:
	ld h, l
	sbc a, c
	ld h, l
	sbc a, c

Func_00_3049:
	ld e, a
	ld a, $01
	ldh [rVBK], a
	ld a, [$c55f]
	cp $02
	jr nc, Func_00_3059
	ld b, $08
	jr Func_00_305b

Func_00_3059:
	ld b, $0a

Func_00_305b:
	add a, a
	ld hl, $3041
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call Func_00_31c4
	ld a, e
	cp $02
	jr nc, Func_00_306f
	ld b, $08
	jr Func_00_3071

Func_00_306f:
	ld b, $0a

Func_00_3071:
	add a, a
	ld hl, $3041
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call Func_00_31d5
	ld a, e
	ld [$c55f], a
	ret

Data_00_3081:
	db $78, $52, $c0, $52, $28, $54, $30, $5b

Func_00_3089:
	ld a, [wMenuId]
	ld b, a
	add a, a
	ld hl, $3081
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, b
	cp $00
	jr z, Func_00_30ab
	cp $03
	jr z, Func_00_30af
	ld a, [wMenuCursor]
	ld c, a
	or a
	jr z, Func_00_30ab
Func_00_30a5:
	ld a, $48
	rst AddAToHL
	dec c
	jr nz, Func_00_30a5
Func_00_30ab:
	call Func_00_33fb
	ret
Func_00_30af:
	call Func_00_30b3
	ret
Func_00_30b3:
	ld hl, $5b30
	ld a, [wMenuCursor]
	cp $00
	jr z, Func_00_30cb
	dec a
	ld de, wFloorMonsterSpecies
	rst AddAToDE
	ld a, [de]
	inc a
	ld c, a
Func_00_30c5:
	ld a, $48
	rst AddAToHL
	dec c
	jr nz, Func_00_30c5
Func_00_30cb:
	call Func_00_33fb
	ret
Func_00_30cf:
	ld a, [wMenuId]
	cp $00
	ret z
	cp $01
	jr nz, Func_00_30e3
	ld hl, $4c00
	ld de, $4d20
	call Func_00_340c
	ret
Func_00_30e3:
	cp $02
	jr nz, Func_00_30f1
	ld hl, $4d68
	ld de, $4cd8
	call Func_00_340c
	ret

Func_00_30f1:
	ld hl, $4c00
	ld de, $4c48
	ld bc, $4c90
	call Func_00_342a
	ret
	nop
	ld bc, $0000
	ld bc, $0000
	ld bc, $0102
	ld [bc], a
	nop
	ld bc, $0002
	nop
	inc bc
	nop
	inc b
	dec b
	ld b, $b0
	ld c, l
	ld hl, sp+77
	ld b, b
	ld c, [hl]
	adc a, b
	ld c, [hl]
	ret nc
	ld c, [hl]
	jr Func_00_316e
	ld h, b
	ld c, a
Func_00_3121:
	ld hl, $30fe
	ld a, [$c7d2]
	ld c, a
	add a, a
	add a, c
	ld c, a
	ld a, [wGridRow]
	add a, c
	rst AddAToHL
	ld a, [hl]
	add a, a
	ld hl, $3113
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call Func_00_33fb
	ret

Func_00_313d:
	ld d, a
	cp $20
	jr nc, Func_00_317d
	cp $10
	jr nc, Func_00_314b
	add a, $40
	ld c, a
	jr Func_00_315e
Func_00_314b:
	cp $1d
	jr nz, Func_00_3153
	ld c, $21
	jr Func_00_315e
Func_00_3153:
	cp $1e
	jr nz, Func_00_315b
	ld c, $3f
	jr Func_00_315e
Func_00_315b:
	add a, $3e
	ld c, a
Func_00_315e:
	ld a, [$c55d]
	add a, a
	ld hl, $12db
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, [$c55f]
	ld e, a
	rst AddAToHL
Func_00_316e:
	ld [hl], c
	ld a, e
	inc a
	cp $06
	jr nz, Func_00_3177
	ld a, $05
Func_00_3177:
	ld [$c55f], a
	ld a, d
	or a
	ret
Func_00_317d:
	and $0c
	jr nz, Func_00_318c
Func_00_3181:
	ld a, [$c55f]
	dec a
	cp $80
	jr c, Func_00_3177
	xor a
	jr Func_00_3177
Func_00_318c:
	cp $04
	jr nz, Func_00_319c
Func_00_3190:
	ld a, [$c55f]
	inc a
	cp $06
	jr nz, Func_00_3177
	ld a, $05
	jr Func_00_3177
Func_00_319c:
	cp $08
	jr nz, Func_00_31a4
Func_00_31a0:
	ld c, $20
	jr Func_00_315e
Func_00_31a4:
	ld hl, $4930
	call Func_00_33fb
	call Func_00_217d
	or a
	jr nz, Func_00_31ba
	FAR_CALL RestoreFloorRoomMarkers
	jr Func_00_31c2
Func_00_31ba:
	FAR_CALL BackupFloorRoomMarkers
Func_00_31c2:
	xor a
	ret

Func_00_31c4:
	ld c, b
	ld d, $fa
	call Func_00_31fa
	ld a, $20
	sub b
	rst AddAToHL
	ld c, b
	ld d, $fa
	call Func_00_31fa
	ret

Func_00_31d5:
	ld c, b
	ld d, $07
	call Func_00_31e6
	ld a, $20
	sub b
	rst AddAToHL
	ld c, b
	ld d, $07
	call Func_00_31e6
	ret

Func_00_31e6:
	call WaitForHBlank
	ld a, [hl]
	or d
	ld [hl+], a
	dec c
	ret z
	ld a, [hl]
	or d
	ld [hl+], a
	dec c
	ret z
	ld a, [hl]
	or d
	ld [hl+], a
	dec c
	jr nz, Func_00_31e6
	ret

Func_00_31fa:
	call WaitForHBlank
	ld a, [hl]
	and d
	ld [hl+], a
	dec c
	ret z
	ld a, [hl]
	and d
	ld [hl+], a
	dec c
	ret z
	ld a, [hl]
	and d
	ld [hl+], a
	dec c
	jr nz, Func_00_31fa
	ret

Func_00_320e:
	call BlackoutPalettes
	FAR_CALL LoadTileset
	FAR_CALL Func_10_4018
	FAR_CALL Func_10_4070
	xor a
	ldh [rVBK], a
	ld hl, $99c0
	ld bc, $0080
	ld d, $fc
	call FillVram
	ld a, $01
	ldh [rVBK], a
	ld hl, $99c0
	ld bc, $0080
	ld d, $08
	call FillVram
	call Func_00_3340
	call Func_00_1a6c
	call Func_00_3089
	FAR_CALL LoadFloorBgPalette
	FAR_CALL Func_10_4081
	FAR_CALL LoadAllFloorMonsterPalettes
	ret
Func_00_3268:
	ld a, [wMenuItemPtr]
	ld l, a
	ld a, [wMenuItemPtr + 1]
	ld h, a
	push hl
	ld a, [wMenuCursor]
	rst AddAToHL
	ld a, [hl]
	ld [wMenuItemValue], a
	pop hl
	ld a, [wMenuCursorRow]
	ld c, a
	ld a, [wMenuCursor]
	sub c
	jr nc, Func_00_3289
	ld c, a
	ld a, [wMenuItemCount]
	add a, c
Func_00_3289:
	rst AddAToHL
	ld d, $04
	ld b, $01
Func_00_328e:
	ld c, $11
	ld a, [hl+]
	push de
	push bc
	push hl
	call Func_00_1f48
	pop hl
	pop bc
	pop de
	inc b
	inc b
	inc b
	ld a, [hl]
	cp $ff
	jr nz, Func_00_32aa
	ld a, [wMenuItemPtr]
	ld l, a
	ld a, [wMenuItemPtr + 1]
	ld h, a
Func_00_32aa:
	dec d
	jr nz, Func_00_328e
	ret
Func_00_32ae:
	push af
	push bc
	ldh a, [hJoyPressed]
	bit 3, b
	jr z, Func_00_3305
Func_00_32b6:
	ld a, [$c55d]
	cp $03
	jr nc, Func_00_3305
	add a, a
	ld hl, $12db
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, [hl+]
	cp $21
	jr nz, Func_00_3305
	ld a, [hl+]
	sub $41
	swap a
	ld c, a
	ld a, [hl+]
	sub $41
	add a, c
	ld c, a
	ld d, $00
	ld a, d
	ld hl, $1567
	rst AddAToHL
	ld a, [BANK_TAG_01]
	push af
	ld a, [hl]
	ld [$2fff], a
	ld a, d
	add a, a
	ld hl, $15bf
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld b, [hl]
	pop af
	ld [$2fff], a
	ld a, b
	cp c
	jr z, Func_00_3308
	inc d
	ld a, $46
	cp d
	jr nz, Func_00_3300
	ld a, $0c
	add a, d
	ld d, a
Func_00_3300:
	ld a, $58
	cp d
	jr nz, $32d7
Func_00_3305:
	pop bc
	pop af
	ret
Func_00_3308:
	inc d
	ld a, d
	cp $3d
	jr nc, Func_00_3318
	ld [$c2c0], a
	ld a, $00
	ld [$c2c1], a
	jr $3322
Func_00_3318:
	sub $3c
	ld [$c2c0], a
	ld a, $01
	ld [$c2c1], a
	call LoadFloorByMode
	call PackFloorSnapshot
	ld a, [$c55d]
	ld [$c2c0], a
	FAR_CALL SaveFloorToSram
	FAR_CALL Func_15_4147
	jr Func_00_3305

Func_00_3340:
	ld a, $ff
	ld [$c7de], a
	xor a
	ld [$c7dc], a
	xor a
	ldh [rVBK], a
	ld d, $b4
	ld hl, $99c1
	ld e, $04
Func_00_3353:
	ld c, $12
Func_00_3355:
	push bc
	ld bc, $0001
	call FillVram
	inc d
	pop bc
	dec c
	jr nz, Func_00_3355
	ld a, $0e
	rst AddAToHL
	dec e
	jr nz, Func_00_3353
	ld a, $01
	ldh [rVBK], a
	ld d, $08
	ld hl, $99c1
	ld e, $04
Func_00_3372:
	ld c, $12
Func_00_3374:
	push bc
	ld bc, $0001
	call FillVram
	pop bc
	dec c
	jr nz, Func_00_3374
	ld a, $0e
	rst AddAToHL
	dec e
	jr nz, Func_00_3372
	ret
RenderTextToVram:
	ld a, [CUR_BANK_TAG]
	push af
	ld a, $17
	ld [$2fff], a
	ld a, $01
	ldh [rVBK], a
	ld c, $48
	ld de, $8b40
Func_00_3398:
	ld a, [hl]
	push bc
	push hl
	cp $20
	jr nz, Func_00_33a3
	ld a, $43
	jr Func_00_33dd
Func_00_33a3:
	cp $3f
	jr nz, Func_00_33ab
	ld a, $44
	jr Func_00_33dd
Func_00_33ab:
	cp $2c
	jr nz, Func_00_33b3
	ld a, $34
	jr Func_00_33dd
Func_00_33b3:
	cp $2e
	jr nz, Func_00_33bb
	ld a, $35
	jr Func_00_33dd
Func_00_33bb:
	cp $27
	jr nz, Func_00_33c3
	ld a, $36
	jr Func_00_33dd
Func_00_33c3:
	cp $2f
	jr nz, Func_00_33cb
	ld a, $37
	jr Func_00_33dd
Func_00_33cb:
	cp $61
	jr c, Func_00_33d3
	sub $47
	jr Func_00_33dd
Func_00_33d3:
	cp $41
	jr c, Func_00_33db
	sub $41
	jr Func_00_33dd
Func_00_33db:
	add a, $08
Func_00_33dd:
	swap a
	ld c, a
	and $0f
	ld b, a
	ld a, c
	and $f0
	ld c, a
	ld hl, $4198
	add hl, bc
	ld c, $10
	call VramCopy8
	pop hl
	pop bc
	inc hl
	dec c
	jr nz, Func_00_3398
	pop af
	ld [$2fff], a
	ret
Func_00_33fb:
	ld a, l
	ld [$c7d6], a
	ld a, h
	ld [$c7d7], a
	ld a, $01
	ld [$c7dd], a
	call RenderTextToVram
	ret
Func_00_340c:
	ld a, $78
	ld [$c7de], a
	ld a, l
	ld [$c7d6], a
	ld a, h
	ld [$c7d7], a
	ld a, e
	ld [$c7d8], a
	ld a, d
	ld [$c7d9], a
	ld a, $02
	ld [$c7dd], a
	call RenderTextToVram
	ret

Func_00_342a:
	ld a, $78
	ld [$c7de], a
	ld a, l
	ld [$c7d6], a
	ld a, h
	ld [$c7d7], a
	ld a, e
	ld [$c7d8], a
	ld a, d
	ld [$c7d9], a
	ld a, c
	ld [$c7da], a
	ld a, b
	ld [$c7db], a
	ld a, $03
	ld [$c7dd], a
	call RenderTextToVram
	ret

Func_00_3450:
	ld a, $78
	ld [$c7de], a
	push af
	ld a, SOUND_SFX_02
	call PlaySound
	pop af
	call RenderTextToVram
	ret
Func_00_3460:
	ld a, [$c7de]
	or a
	jr z, Func_00_346e
	cp $ff
	ret z
	dec a
	ld [$c7de], a
	ret
Func_00_346e:
	ld a, [$c7dd]
	cp $01
	jr z, Func_00_3492
	ld c, a
	ld a, [$c7dc]
	inc a
	cp c
	jr nz, Func_00_347e
	xor a
Func_00_347e:
	ld [$c7dc], a
	add a, a
	ld hl, $c7d6
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, $78
	ld [$c7de], a
	call RenderTextToVram
	ret

Func_00_3492:
	ld a, $ff
	ld [$c7de], a
	ld a, [$c7d6]
	ld l, a
	ld a, [$c7d7]
	ld h, a
	call RenderTextToVram
	ret

; Scene 4 (TOWN): town stage = 2/1/0 by story flags $0d/$0c, cursor seeded
; from wGameSceneArg, then the bank-$30 town screen (which sets the next
; scene from the chosen location).
EnterTownScene:
	ld a, $0d
	call TestStoryFlag
	and a
	jr z, Func_00_34af
	ld a, $02
	jr Func_00_34bc
Func_00_34af:
	ld a, $0c
	call TestStoryFlag
	and a
	jr z, Func_00_34bb
	ld a, $01
	jr Func_00_34bc
Func_00_34bb:
	xor a
Func_00_34bc:
	ld [wTownStage], a
	ld a, [wGameSceneArg]
	ld [wScreenInput], a
	ld [wScreenPhase], a
	FAR_CALL InitProgressFlags
	call ResetScrollState
	push af
	ld a, SOUND_BGM_Town
	call PlaySoundTracked
	pop af
	ld a, $30
	ld [$2fff], a
	call DrawTownScreen
	ret

EnterTowerEntrance:
	call ResetScrollState
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	ld a, $30
	ld [$2fff], a
	call DrawTowerEntranceScreen
	ld a, [wRoomType]
	cp $02
	jr z, Func_00_3502
	ld a, SCENE_ROOM_START
	ld [wGameScene], a
	ret

Func_00_3502:
	ld a, SCENE_ROOM
	ld [wGameScene], a
	ret

; Scene 17 (ROOM_START); falls through to SCENE_ROOM unless a user room.
EnterRoomStartScene:
	call ResetScrollState
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	ld a, $30
	ld [$2fff], a
	call DrawRoomStartScreen
	ld a, [wRoomType]
	cp $05
	ret z
	ld a, SCENE_ROOM
	ld [wGameScene], a
	ret
; Scene 16 (NEXT_ROOM): the between-floors flight screen.
EnterNextRoomScene:
	call ResetScrollState
	push af
	ld a, SOUND_BGM_RoomTransition
	call PlaySoundTracked
	pop af
	ld a, $30
	ld [$2fff], a
	call DrawNextRoomScreen
	ld a, SCENE_ROOM_START
	ld [wGameScene], a
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	ret
; Scene 19 (ROOM_CLEAR): the results/tally screen.
EnterRoomClearScene:
	call ResetScrollState
	ld a, $30
	ld [$2fff], a
	call DrawRoomClearScreen
	FAR_CALL Func_05_46ba
	ret
; Scene 20 (TOWER): tower-open cutscene (first time only, per wC2D7), then
; Naji's between-floors encounter and back to town.
EnterTowerScene:
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	call ResetScrollState
	ld a, [wC2D7]
	cp $00
	jr nz, Func_00_3572
	ld a, $30
	ld [$2fff], a
	call DrawTowerOpenScreen
Func_00_3572:
	FAR_CALL Naji_RunEncounter
	ld a, SCENE_TOWN
	ld [wGameScene], a
	ret

IntroScene_TecmoLogo:
	call ResetScrollState
	ld a, $30
	ld [$2fff], a
	call DrawTecmoLogo
	ld a, SCENE_INTRO
	ld [wGameScene], a
	ret

IntroScene_Cutscene:
	call ResetScrollState
	ld a, $30
	ld [$2fff], a
	call DrawIntroBookScreen
	ld a, SCENE_TITLE
	ld [wGameScene], a
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	ret

IntroScene_LoadTitle:
	call ResetScrollState
	push af
	ld a, SOUND_BGM_Title
	call PlaySoundTracked
	pop af
	ld a, BANK(LoadTitleScreen)
	ld [$2fff], a
	call LoadTitleScreen
	push af
	ld a, SOUND_BGM_Silence
	call PlaySoundTracked
	pop af
	ld a, $03
	ld [wGameSceneArg], a
	ret

Func_00_35c8:
	call ResetScrollState
	ld a, $30
	ld [$2fff], a
	call DmgOnlyScreen
	ret

; Draw BG-map patch #A: hl = dw descriptor table in bank b, de = BG dest;
; dereferences entry A and CopyBgMap's it.
BankMapCopyIndexed:
	ld c, a
	ld a, [CUR_BANK_TAG]
	push af
	ld a, b
	ld [$2fff], a
	ld a, c
	add a, a
	rst AddAToHL
	rst DerefHL
	call CopyBgMap
	pop af
	ld [$2fff], a
	ret

BankMapCopyB:
	ld a, [CUR_BANK_TAG]
	push af
	ld a, b
	ld [$2fff], a
	call CopyBgMap
	pop af
	ld [$2fff], a
	ret

; Draw metasprite #A: hl = dw metasprite table in bank b, (d,e) = (y,x).
DrawMetaspriteIndexed:
	ld c, a
	ld a, [CUR_BANK_TAG]
	push af
	ld a, b
	ld [$2fff], a
	ld a, c
	add a, a
	rst AddAToHL
	rst DerefHL
	ld a, b
	ld [wDrawBank], a
	ld b, d
	ld c, e
	call DrawMetasprite
	pop af
	ld [$2fff], a
	ret
LoadPalettesBanked:
	ld a, [CUR_BANK_TAG]
	push af
	ld a, b
	ld [$2fff], a
	push de
	ld hl, $c201
	ld c, $40
	call CopyDEtoHL
	pop de
	ld a, $40
	rst AddAToDE
	ld hl, $c241
	ld c, $40
	call CopyDEtoHL
	pop af
	ld [$2fff], a
; Write one BCD digit as a BG cell at de (tile $9a+digit, attr $08) and step
; de backwards -- callers emit multi-digit numbers low digit first.
WriteBcdDigitTile:
	and $0f
	add a, $9a
	ld [de], a
	ld a, $01
	ldh [rVBK], a
	ld a, $08
	ld [de], a
	xor a
	ldh [rVBK], a
	dec de
	ret

HBlankCopy:
	rst CheckCgb
	jr nz, .gbc
.dmg:
	di
.loop:
	ldh a, [rSTAT]
	bit 1, a
	jr nz, .loop
	ld a, [hl]
	ld [de], a
	ldh a, [rSTAT]
	bit 1, a
	jr nz, .loop
	ei
	inc hl
	inc de
	dec c
	jr nz, .dmg
	ret
.gbc:
	call WaitForHBlank
	REPT 4
		ld a, [hl+]
		ld [de], a
		inc de
		dec c
		jr z, .done
	ENDR
	call WaitForHBlank
	REPT 3
		ld a, [hl+]
		ld [de], a
		inc de
		dec c
		jr z, .done
	ENDR
	jr .gbc
.done:
	ret

HBlankCopyPaged:
	ld a, c
	and c
	jr z, Func_00_369c
	call HBlankCopy
	ld a, b
	and b
	ret z
Func_00_369c:
	call HBlankCopy
	dec b
	jr nz, Func_00_369c
	ret

BankHBlankCopy:
	ld [wBankCallTmp], a
	ld a, [CUR_BANK_TAG]
	push af
	ld a, [wBankCallTmp]
	ld [$2fff], a
	call HBlankCopyPaged
	pop af
	ld [$2fff], a
	ret

Func_00_36b8:
	call Func_00_36bc
	ret

Func_00_36bc:
	push af
	push bc
	push hl
	ld a, $a7
	ldh [rWX], a
	ld c, $42
	ld a, [$cf3f]
	or a
	jr nz, Func_00_36d1
	ldh a, [c]
	and $7f
	ldh [c], a
	jr Func_00_36d7
Func_00_36d1:
	ldh a, [c]
	and $7f
	or $80
	ldh [c], a
Func_00_36d7:
	ld hl, $ff40
	set 1, [hl]
	ld hl, $36e8
	ld a, $6f
	call SetLcdStatInterrupt
	pop hl
	pop bc
	pop af
	ret
	push af
	push bc
	push hl
	ld a, $00
	ldh [rWX], a
	ld hl, $ff40
	res 1, [hl]
	ld hl, $36bc
	ld a, $1f
	call SetLcdStatInterrupt
	pop hl
	pop bc
	pop af
	ret
Multiply8:
	push de
	ld d, $00
Func_00_3703:
	srl c
	jr nc, Func_00_370a
	ld a, b
	add a, d
	ld d, a
Func_00_370a:
	ld a, c
	and a
	jr z, Func_00_3712
	sla b
	jr Func_00_3703
Func_00_3712:
	ld a, d
	pop de
	ret

Multiply16:
	ld hl, $0000
Func_00_3718:
	srl d
	rr e
	jr nc, Func_00_371f
	add hl, bc
Func_00_371f:
	ld a, d
	or e
	ret z
	sla c
	rl b
	jr Func_00_3718
	ld a, b
	xor d
	rla
	push af
	bit 7, b
	jr z, Func_00_3737
	ld a, c
	cpl
	ld c, a
	ld a, b
	cpl
	ld b, a
	inc bc
Func_00_3737:
	bit 7, d
	jr z, Func_00_3742
	ld a, e
	cpl
	ld e, a
	ld a, d
	cpl
	ld d, a
	inc de
Func_00_3742:
	call Func_00_374f
	pop af
	ret nc
	ld a, l
	cpl
	ld l, a
	ld a, h
	cpl
	ld h, a
	inc hl
	ret

Func_00_374f:
	xor a
	ld h, a
	ld l, a
Func_00_3752:
	bit 7, d
	jr nz, Func_00_375d
	sla e
	rl d
	inc a
	jr Func_00_3752
Func_00_375d:
	push af
	ld a, c
	sub e
	ld a, b
	sbc a, d
	jr c, Func_00_3769
	ld b, a
	ld a, c
	sub e
	ld c, a
	inc hl
Func_00_3769:
	pop af
	and a
	ret z
	dec a
	srl d
	rr e
	add hl, hl
	jr Func_00_375d
Divide8:
	push bc
	ld b, $08
	ld l, d
	ld h, $00
Func_00_377a:
	add hl, hl
	ld a, h
	cp e
	jr c, Func_00_3783
	sub e
	ld h, a
	set 0, l
Func_00_3783:
	dec b
	jr nz, Func_00_377a
	pop bc
	ret

Divide16:
	push hl
	xor a
	ld [$c2a3], a
	ld [$c2a4], a
	rl c
	rl b
	ld a, $10
Func_00_3796:
	ld [$c2a5], a
	ld hl, $c2a4
	rl [hl]
	dec hl
	rl [hl]
	ld a, [$c2a4]
	sub e
	ld a, [$c2a3]
	sbc a, d
	jp nc, Func_00_37b0
	ccf
	jp Func_00_37bf
Func_00_37b0:
	ld a, [$c2a4]
	sbc a, e
	ld [$c2a4], a
	ld a, [$c2a3]
	sbc a, d
	ld [$c2a3], a
	scf
Func_00_37bf:
	rl c
	rl b
	ld a, [$c2a5]
	dec a
	jp nz, Func_00_3796
	pop hl
	ret

Func_00_37cc:
	ld d, $00
	ld e, b
	sla b
	jr nc, Func_00_37d4
	dec d
Func_00_37d4:
	call Func_00_37e8
	jp Multiply16
	ld d, $00
	ld e, b
	sla b
	jr nc, Func_00_37e2
	dec d
Func_00_37e2:
	call Func_00_380f
	jp Multiply16
Func_00_37e8:
	cp $40
	jr z, Func_00_3805
	cp $c0
	jr z, Func_00_380a
	cp $81
	jr nc, Func_00_37f8
	ld b, $00
	jr Func_00_37fa
Func_00_37f8:
	ld b, $ff
Func_00_37fa:
	ld hl, $3813
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld c, [hl]
	ret
Func_00_3805:
	ld b, $01
	ld c, $00
	ret
Func_00_380a:
	ld b, $ff
	ld c, $00
	ret
Func_00_380f:
	add a, $40
	jr Func_00_37e8
	nop
	ld b, $0c
	ld [de], a
	add hl, de
	rra
	dec h
	dec hl
	ld sp, $3e38
	ld b, h
	ld c, d
	ld d, b
	ld d, [hl]
	ld e, h
	ld h, c
	ld h, a
	ld l, l
	ld [hl], e
	ld a, b
	ld a, [hl]
	add a, e
	adc a, b
	adc a, [hl]
	sub e
	sbc a, b
	sbc a, l
	and d
	and a
	xor e
	or b
	or l
	cp c
	cp l
	pop bc
	push bc
	ret
	call $d4d1
	ret c
	db $db
	sbc a, $e1
	db $e4
	rst CheckCgb
	ld [$eeec], a
	pop af
	di
	db $f4
	or $f8
	ld sp, hl
	ei
	db $fc
	db $fd
	cp $fe
	rst $38
	rst $38
	rst $38
	nop
	rst $38
	rst $38
	rst $38
	cp $fe
	db $fd
	db $fc
	ei
	ld sp, hl
	ld hl, sp-10
	db $f4
	di
	pop af
	xor $ec
	ld [$e4e7], a
	pop hl
	sbc a, $db
	ret c
	call nc, $cdd1
	ret
	push bc
	pop bc
	cp l
	cp c
	or l
	or b
	xor e
	and a
	and d
	sbc a, l
	sbc a, b
	sub e
	adc a, [hl]
	adc a, b
	add a, e
	ld a, [hl]
	ld a, b
	ld [hl], e
	ld l, l
	ld h, a
	ld h, c
	ld e, h
	ld d, [hl]
	ld d, b
	ld c, d
	ld b, h
	ld a, $38
	ld sp, $252b
	rra
	add hl, de
	ld [de], a
	inc c
	ld b, $00
	ld a, [$eef4]
	rst CheckCgb
	pop hl
	db $db
	push de
	rst SubAFromHL
	ret z
	jp nz, $b6bc
	or b
	xor d
	and h
	sbc a, a
	sbc a, c
	sub e
	adc a, l
	adc a, b
	add a, d
	ld a, l
	ld a, b
	ld [hl], d
	ld l, l
	ld l, b
	ld h, e
	ld e, [hl]
	ld e, c
	ld d, l
	ld d, b
	ld c, e
	ld b, a
	ld b, e
	ccf
	dec sp
	scf
	inc sp
	cpl
	inc l
	jr z, Func_00_38e3
	ld [hl+], a
	rra
	inc e
	add hl, de
	ld d, $14
	ld [de], a
	rrca
	dec c
	inc c
	ld a, [bc]
	ld [$0507], sp
	inc b
	inc bc
	ld [bc], a
	ld [bc], a
	ld bc, $0101
	nop
	ld bc, $0101
	ld [bc], a
	ld [bc], a
	inc bc
	inc b
	dec b
	rlca
	ld [$0c0a], sp
	dec c
	rrca
	ld [de], a
Func_00_38e3:
	inc d
	ld d, $19
	inc e
	rra
	ld [hl+], a
	dec h
	jr z, $3918
	cpl
	inc sp
	scf
	dec sp
	ccf
	ld b, e
	ld b, a
	ld c, e
	ld d, b
	ld d, l
	ld e, c
	ld e, [hl]
	ld h, e
	ld l, b
	ld l, l
	ld [hl], d
	ld a, b
	ld a, l
	add a, d
	adc a, b
	adc a, l
	sub e
	sbc a, c
	sbc a, a
	and h
	xor d
	or b
	or [hl]
	cp h
	jp nz, $cfc8
	push de
	db $db
	pop hl
	rst CheckCgb
	xor $f4
	db $fa

; BankCopy switches to a new ROM bank and performs a copy.
; a		Bank to switch to
; hl	Source address
; de	Target address
; bc	Number of bytes to copy
BankCopy:
	; Save current bank in wBankCallTmp and switch to target bank
	ld [wBankCallTmp], a
	ld a, [CUR_BANK_TAG]
	push af
	ld a, [wBankCallTmp]
	ld [$2fff], a
.loop:
	ld a, [hl+]
	ld [de], a
	inc de
	dec bc
	ld a, c
	or b
	jr nz, .loop
	; Switch back to original bank
	pop af
	ld [$2fff], a
	ret

; BankCopy switches to a new ROM bank and performs a VRAM-safe copy.
; a		Bank to switch to
; hl	Source address
; de	Target address
; bc	Number of bytes to copy
BankVramCopy:
	ld [wBankCallTmp], a
	ld a, [CUR_BANK_TAG]
	push af
	ld a, [wBankCallTmp]
	ld [$2fff], a
	call VramCopy16
	pop af
	ld [$2fff], a
	ret

BankMapCopyA:
	ld [wBankCallTmp], a
	ld a, [CUR_BANK_TAG]
	push af
	ld a, [wBankCallTmp]
	ld [$2fff], a
	call CopyBgMap
	pop af
	ld [$2fff], a
	ret

LeaveTownBuilding:
	FAR_CALL Script_FadeOutPortrait
	ld a, SCENE_TOWN
	ld [wGameScene], a
	ret

; Load the text-window UI that sits under a portrait/dialogue scene. The portrait
; occupies the top 11 rows; this fills the bottom rows (tilemap -> $9960) with the
; box-frame layout and loads the shared font/box tile set + 16 BG palettes, then
; resets the renderer state. Tiles/tilemap/palettes live in bank $19 (see
; src/gfx/screen/screen_19.asm). LoadTextUiAlt is the same but uses the alt tile
; set at $56cb (used by bodka/naji); both fall through to LoadTextUiTiles, which
; takes the tile source in a:hl.
LoadTextUiAlt:
	ld a, $00
	ldh [rVBK], a
	ld a, BANK(TextUiTilesAlt)
	ld hl, TextUiTilesAlt
	jp LoadTextUiTiles
LoadTextUi:
	ld a, $00
	ldh [rVBK], a
	ld a, BANK(TextUiTiles)
	ld hl, TextUiTiles
LoadTextUiTiles:
	ld de, $8800
	ld bc, $1000
	call BankVramCopy
	ld hl, TextUiBoxMap
	ld a, BANK(TextUiBoxMap)
	ld de, $9960
	call BankMapCopyA
	ld a, BANK(TextUiPalettes)
	ld hl, TextUiPalettes
	ld de, wBgPalettes
	ld bc, $0080
	call BankCopy
	xor a
	ld [$d61b], a
	ld [wRendererAddr], a
	ld [wRendererAddr+1], a
	ld [wRendererBank], a
	ld [$d61a], a
	ret

ClearBossState:
	ld a, $00
	ld [$d60e], a
	ld [wBossState], a
	ld hl, wToamunaState
	ld c, $0b
	xor a
.loop:
	ld [hl+], a
	dec c
	jr nz, .loop
	ret

SECTION "analyzed_003d30", ROM0[$3d30]

Data_00_3d30:
	db $97, $07

SECTION "analyzed_003d37", ROM0[$3d37]

Data_00_3d37:
	db $b2

SECTION "analyzed_003d38", ROM0[$3d38]

Func_00_3d38:
	nop
	nop
	inc l
	nop

Data_00_3d3c:
	db $2c, $2f, $06

SECTION "analyzed_003d40", ROM0[$3d40]

Data_00_3d40:
	db $22, $23, $24, $25, $26, $27, $28, $29, $2a, $2b

Data_00_3d4a:
	db $00, $00, $00, $2e, $00

SECTION "analyzed_003d4f", ROM0[$3d4f]

Data_00_3d4f:
	db $2d

SECTION "analyzed_003d51", ROM0[$3d51]

Data_00_3d51:
	db $08, $09, $0a, $0b, $0c, $0d, $0e, $0f, $10, $11, $12, $13, $14, $15, $16, $17

SECTION "analyzed_003d61", ROM0[$3d61]

Data_00_3d61:
	db $18

SECTION "analyzed_003d62", ROM0[$3d62]

Data_00_3d62:
	db $19, $1a, $1b, $1c, $1d, $1e

SECTION "analyzed_003d68", ROM0[$3d68]

Data_00_3d68:
	db $1f

SECTION "analyzed_003d69", ROM0[$3d69]

Data_00_3d69:
	db $20

SECTION "analyzed_003d6a", ROM0[$3d6a]

Data_00_3d6a:
	db $21, $00, $00, $00, $00, $00, $00

Data_00_3d71:
	db $98, $99, $9a, $9b, $9c, $9d, $9e, $9f, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $a7
	db $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af, $b0, $b1

Data_00_3d8b:
	db $00, $00, $00, $35, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $97, $00, $00, $00, $95

SECTION "analyzed_003db5", ROM0[$3db5]

Data_00_3db5:
	db $34

SECTION "analyzed_003db6", ROM0[$3db6]

Data_00_3db6:
	db $c4, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd, $ce, $92, $98, $99, $9a, $9b, $9c
	db $9d, $9e, $9f, $a0, $a1, $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $aa, $ab, $ac
	db $ad, $ae, $af, $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7, $b8, $b9, $ba, $bb, $bc
	db $bd, $be, $bf, $c0, $c1, $c2, $c3, $c5, $93, $94, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $2c, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

DrawBlinkCursor:
	ld a, [wDrawBank]
	push af
	ld a, $19
	ld [wDrawBank], a
	ld a, [$d612]
	srl a
	srl a
	srl a
	and $01
	ld hl, $3e3e
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call DrawMetasprite
	ld hl, $d612
	inc [hl]
	pop af
	ld [wDrawBank], a
	ret

Data_00_3e3e:
	db $69, $68, $72, $68

NumberToDecimal3:
	ld hl, $3e68
	call DivBySubtraction
	ld [$d5fd], a
	ld hl, $3e69
	call DivBySubtraction
	ld [wBcdHigh], a
	ld a, c
	ld [wBcdLow], a
	ret

DivBySubtraction:
	ld e, $00
Func_00_3e5b:
	ld a, c
	sub [hl]
	ld c, a
	jr c, Func_00_3e63
	inc e
	jr Func_00_3e5b
Func_00_3e63:
	ld a, c
	add a, [hl]
	ld c, a
	ld a, e
	ret

Data_00_3e68:
	db $64, $0a

DelayShort:
	push af
	ld a, $ff
Func_00_3e6d:
	nop
	dec a
	or a
	jr nz, Func_00_3e6d
	pop af
	ret
DelayLong:
	call DelayShort
	call DelayShort
	call DelayShort
	ret

Func_00_3e7e:
	push af
	ld a, $ff
	ld [wSerialRecvFlag], a
	ldh a, [rSB]
	ld [wSerialRecv], a
	cp $f0
	jr z, Func_00_3ea1
	cp $f1
	jr z, Func_00_3e93
	pop af
	reti

Func_00_3e93:
	ld a, [wSerialSend]
	ldh [rSB], a
	call DelayLong
	ld a, $80
	ldh [rSC], a
	pop af
	reti
Func_00_3ea1:
	pop af
	reti
	push af
	ld a, $ff
	ld [wSerialRecvFlag], a
	ldh a, [rSB]
	ld [wSerialRecv], a
	cp $f2
	jr z, Func_00_3ea1
	cp $f3
	jr z, Func_00_3e93
	pop af
	reti
	push af
	ld a, $ff
	ld [wSerialRecvFlag], a
	ldh a, [rSB]
	ld [wSerialRecv], a
	cp $f4
	jr z, Func_00_3ea1
	cp $f5
	jr z, Func_00_3e93
	pop af
	reti
	push af
	ldh a, [rSB]
	ld [wSerialRecv], a
	ld a, [wSerialSend]
	ldh [rSB], a
	ld a, $80
	ldh [rSC], a
	ld a, $ff
	ld [wSerialRecvFlag], a
	pop af
	reti
	push af
	ldh a, [rSB]
	ld [wSerialRecv], a
	ld a, [wSerialSend]
	ldh [rSB], a
	ld a, $ff
	ld [wSerialRecvFlag], a
	pop af
	reti
