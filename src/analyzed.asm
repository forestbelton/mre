; Auto-decoded ROM, banks $01+ (the bank-$00 "home" code now lives in
; home.asm; other subsystems are carved into their own files -- see
; main.asm). What remains is still-unsorted ROMX code/data, each section
; placed by its explicit ROMX[$xxxx]/BANK[$nn] address.

INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "sound_ids.inc"

SECTION "analyzed_008000", ROMX[$4000], BANK[$02]

Func_02_4000:
	xor a
	ldh [rVBK], a
	ld hl, Data_02_40b1
	ld de, $8000
	ld bc, $1000
	call VramCopy16
	ret

Func_02_4010:
	ld a, $07
	ld hl, Data_02_50e9
	call LoadBgPalette
	ld a, $00
	ld b, $08
	ld hl, $50f1
	call Func_00_0732
	ret

Func_02_4023:
	ld hl, $cc94
	ld c, $01
	call Func_02_4058
	ld a, [$c2e7]
	inc a
	ld [$c2e7], a
	and $01
	jr nz, Func_02_4047
	ld hl, $cd74
	ld c, $1c
	call Func_02_4058
	ld hl, $ce54
	ld c, $1c
	call Func_02_4058
	ret
Func_02_4047:
	ld hl, $ce54
	ld c, $1c
	call Func_02_4065
	ld hl, wMonsterMeta1Ptr
	ld c, $1c
	call Func_02_4065
	ret

Func_02_4058:
	ld a, [hl]
	or a
	call nz, Func_02_4071
	ld de, $0008
	add hl, de
	dec c
	jr nz, Func_02_4058
	ret

Func_02_4065:
	ld a, $08
	rst SubAFromHL
	ld a, [hl]
	or a
	call nz, Func_02_4071
	dec c
	jr nz, Func_02_4065
	ret

Func_02_4071:
	push hl
	push bc
	inc hl
	ld a, [hl+]
	and $f0
	jr z, Func_02_4096
	ld a, [hl+]
	ld [wSpawnPtr+1], a
	ld a, [hl+]
	ld [wSpawnPtr], a
	ld a, [hl+]
	ld d, a
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld c, a
	ld b, [hl]
	ld a, [wSpawnPtr+1]
	ld l, a
	ld a, [wSpawnPtr]
	ld h, a
	call Func_00_0c84
	pop bc
	pop hl
	ret
Func_02_4096:
	ld a, [hl+]
	ld [wSpawnPtr+1], a
	ld a, [hl+]
	ld [wSpawnPtr], a
	inc hl
	inc hl
	ld a, [hl+]
	ld c, a
	ld b, [hl]
	ld a, [wSpawnPtr+1]
	ld l, a
	ld a, [wSpawnPtr]
	ld h, a
	call Func_00_0c45
	pop bc
	pop hl
	ret

Data_02_40b1:
	INCBIN "raw_gfx/Data_02_40b1.2bpp", 0, 4096

Data_02_50b1:
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $12, $01, $63, $0c, $b5, $01, $3d, $3f
	db $12, $01, $63, $0c, $ce, $39, $5a, $6b, $12, $01, $63, $0c, $26, $12, $9f, $2f
	db $12, $01, $63, $0c, $ff, $00, $9f, $63, $12, $01, $63, $0c, $60, $7d, $9f, $63
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_02_50e9:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $00, $00, $5f, $4b, $b5, $01, $e0, $2c
	db $00, $00, $ef, $71, $00, $68, $de, $7b, $00, $00, $1b, $24, $9f, $66, $3f, $4b
	db $00, $00, $5f, $2e, $df, $0c, $de, $7b, $00, $00, $a3, $09, $59, $01, $3d, $13
	db $00, $00, $a3, $09, $59, $01, $3d, $13, $00, $00, $a3, $09, $59, $01, $3d, $13
	db $00, $00, $a3, $09, $59, $01, $3d, $13, $00, $00, $de, $7b, $ff, $7f, $ff, $7f
	db $00, $00, $df, $00, $df, $00, $df, $00, $02, $f1, $f8, $00, $00, $f1, $00, $08
	db $00, $02, $f1, $f8, $08, $20, $f1, $00, $00, $20, $02, $f1, $f8, $02, $00, $f1
	db $00, $0a, $00, $02, $f1, $f8, $0a, $20, $f1, $00, $02, $20, $02, $f1, $f8, $04
	db $00, $f1, $00, $0c, $00, $02, $f1, $f8, $0c, $20, $f1, $00, $04, $20, $02, $f1
	db $f8, $06, $00, $f1, $00, $0e, $00, $02, $f1, $f8, $0e, $20, $f1, $00, $06, $20
	db $02, $f1, $f8, $10, $00, $f1, $00, $18, $00, $02, $f1, $f8, $18, $20, $f1, $00
	db $10, $20, $02, $f1, $f8, $12, $00, $f1, $00, $1a, $00, $02, $f1, $f8, $1a, $20
	db $f1, $00, $12, $20, $02, $f1, $f8, $14, $00, $f1, $00, $1c, $00, $02, $f1, $f8
	db $1c, $20, $f1, $00, $14, $20, $02, $f1, $f8, $16, $00, $f1, $00, $1e, $00, $02
	db $f1, $f8, $1e, $20, $f1, $00, $16, $20, $02, $f1, $fa, $20, $00, $f1, $02, $28
	db $00, $02, $f1, $f6, $28, $20, $f1, $fe, $20, $20, $02, $f1, $fa, $22, $00, $f1
	db $02, $2a, $00, $02, $f1, $f6, $2a, $20, $f1, $fe, $22, $20, $02, $f1, $fa, $24
	db $00, $f1, $02, $2c, $00, $02, $f1, $f6, $2c, $20, $f1, $fe, $24, $20, $02, $f1
	db $fa, $26, $00, $f1, $02, $2e, $00, $02, $f1, $f6, $2e, $20, $f1, $fe, $26, $20
	db $02, $f1, $fa, $30, $00, $f1, $02, $38, $00, $02, $f1, $f6, $38, $20, $f1, $fe
	db $30, $20, $02, $f1, $fa, $32, $00, $f1, $02, $3a, $00, $02, $f1, $f6, $3a, $20
	db $f1, $fe, $32, $20, $02, $f1, $f8, $34, $00, $f1, $00, $3c, $00, $02, $f1, $f8
	db $3c, $20, $f1, $00, $34, $20, $02, $f1, $f8, $36, $00, $f1, $00, $3e, $00, $02
	db $f1, $f8, $3e, $20, $f1, $00, $36, $20, $02, $f1, $f8, $40, $00, $f1, $00, $48
	db $00, $02, $f1, $f8, $48, $20, $f1, $00, $40, $20, $02, $f1, $f8, $42, $00, $f1
	db $00, $4a, $00, $02, $f1, $f8, $4a, $20, $f1, $00, $42, $20, $02, $f1, $f8, $44
	db $00, $f1, $00, $4c, $00, $02, $f1, $f8, $4c, $20, $f1, $00, $44, $20, $02, $f1
	db $f8, $46, $00, $f1, $00, $4e, $00, $02, $f1, $f8, $50, $00, $f1, $00, $58, $00
	db $02, $f4, $f8, $52, $00, $f4, $00, $5a, $00, $02, $f4, $f8, $5a, $20, $f4, $00
	db $52, $20, $02, $f4, $f8, $54, $00, $f4, $00, $5c, $00, $02, $f4, $f8, $5c, $20
	db $f4, $00, $54, $20

Data_02_52cd:
	db $02, $f1, $f8, $56, $00, $f1, $00, $5e, $00, $02, $f1, $f8, $5e, $20, $f1, $00
	db $56, $20, $02, $f1, $f8, $60, $00, $f1, $00, $68, $00, $02, $f1, $f8, $68, $20
	db $f1, $00, $60, $20

Data_02_52f1:
	db $02, $f8, $f8, $c2, $02, $f8, $00, $ca, $02, $02, $f8, $f8, $ca, $22, $f8, $00
	db $c2, $22, $02, $f8, $f8, $c4, $02, $f8, $00, $cc, $02, $02, $f8, $f8, $cc, $22
	db $f8, $00, $c4, $22, $02, $f8, $f8, $80, $03, $f8, $00, $80, $23, $02, $f8, $f8
	db $82, $03, $f8, $00, $82, $63, $01, $f8, $fc, $8e, $03, $01, $f8, $fc, $84, $03
	db $02, $f8, $f8, $86, $03, $f8, $00, $86, $23, $02, $f8, $f8, $88, $23, $f8, $00
	db $8c, $23, $02, $f8, $f8, $8c, $03, $f8, $00, $88, $03, $01, $f8, $fc, $8a, $03
	db $02, $f8, $f8, $8c, $03, $f8, $00, $8c, $23, $02, $f8, $f8, $90, $03, $f8, $00
	db $90, $63, $01, $f8, $fc, $8a, $01, $02, $f8, $f8, $a4, $01, $f8, $00, $a4, $21
	db $02, $f8, $f8, $a6, $01, $f8, $00, $a6, $21, $02, $f8, $f8, $a8, $01, $f8, $00
	db $a8, $21, $02, $f8, $f8, $aa, $01, $f8, $00, $aa, $21, $02, $f8, $f8, $92, $03
	db $f8, $00, $94, $03, $02, $f8, $f8, $94, $23, $f8, $00, $92, $23, $02, $f8, $f8
	db $96, $03, $f8, $00, $98, $03, $02, $f8, $f8, $96, $43, $f8, $00, $98, $43

Data_02_53b0:
	db $02, $f8, $f8, $9a, $03, $f8, $00, $9a, $23

Data_02_53b9:
	db $02, $f8, $f8, $9c, $03, $f8, $00, $9e, $03, $02, $f8, $f8, $9e, $23, $f8, $00
	db $9c, $23, $02, $f8, $f8, $a0, $03, $f8, $00, $a2, $03, $02, $f8, $f8, $a0, $43
	db $f8, $00, $a2, $43

Data_02_53dd:
	db $02, $f8, $f8, $a8, $03, $f8, $00, $aa, $03, $02, $f8, $f8, $aa, $23, $f8, $00
	db $a8, $23, $02, $f8, $f8, $ac, $03, $f8, $00, $ae, $03, $02, $f8, $f8, $ae, $23
	db $f8, $00, $ac, $23

Data_02_5401:
	db $02, $fb, $f8, $b0, $03, $fb, $00, $b0, $63, $02, $fb, $f8, $b2, $03, $fb, $00
	db $b2, $63, $02, $fb, $f8, $b4, $03, $fb, $00, $b4, $63, $02, $fb, $f8, $b6, $03
	db $fb, $00, $b6, $63, $02, $fb, $f8, $b8, $03, $fb, $00, $b8, $63, $02, $f3, $f3
	db $b0, $03, $f3, $fb, $b0, $63, $02, $f3, $f3, $b2, $03, $f3, $fb, $b2, $63, $02
	db $f3, $f3, $b4, $03, $f3, $fb, $b4, $63, $02, $f3, $f3, $b6, $03, $f3, $fb, $b6
	db $63, $02, $f3, $f3, $b8, $03, $f3, $fb, $b8, $63, $02, $f5, $fb, $b0, $03, $f5
	db $03, $b0, $63, $02, $f5, $fb, $b2, $03, $f5, $03, $b2, $63, $02, $f5, $fb, $b4
	db $03, $f5, $03, $b4, $63, $02, $f5, $fb, $b6, $03, $f5, $03, $b6, $63, $02, $f5
	db $fb, $b8, $03, $f5, $03, $b8, $63, $02, $f8, $f8, $70, $00, $f8, $00, $78, $00
	db $02, $f8, $f8, $72, $00, $f8, $00, $7a, $00, $02, $f8, $f8, $74, $00, $f8, $00
	db $7c, $00, $02, $f8, $f8, $76, $00, $f8, $00, $7e, $00, $02, $f8, $f8, $78, $60
	db $f8, $00, $70, $60, $02, $f8, $f8, $7a, $60, $f8, $00, $72, $60, $02, $f8, $f8
	db $7c, $60, $f8, $00, $74, $60, $02, $f8, $f8, $7e, $60, $f8, $00, $76, $60, $02
	db $f8, $f8, $c0, $03, $f8, $00, $c8, $03, $02, $f8, $f8, $70, $05, $f8, $00, $78
	db $05, $02, $f1, $f8, $00, $00, $f1, $00, $08, $00, $02, $f1, $f8, $02, $00, $f1
	db $00, $0a, $00, $02, $f1, $f8, $04, $00, $f1, $00, $0c, $00, $02, $f1, $f8, $06
	db $00, $f1, $00, $0e, $00, $02, $f1, $f8, $10, $00, $f1, $00, $18, $00, $02, $f1
	db $f8, $12, $00, $f1, $00, $1a, $00, $02, $f1, $f8, $14, $00, $f1, $00, $1c, $00
	db $02, $f1, $f8, $16, $00, $f1, $00, $1e, $00, $02, $f1, $f8, $20, $00, $f1, $00
	db $28, $00, $02, $f1, $f8, $22, $00, $f1, $00, $2a, $00, $02, $f1, $f8, $24, $00
	db $f1, $00, $2c, $00

Data_02_5545:
	db $02, $f1, $f8, $26, $00, $f1, $00, $2e, $00

Data_02_554e:
	db $02, $f1, $f8, $08, $20, $f1, $00, $00, $20, $02, $f1, $f8, $0a, $20, $f1, $00
	db $02, $20, $02, $f1, $f8, $0c, $20, $f1, $00, $04, $20, $02, $f1, $f8, $0e, $20
	db $f1, $00, $06, $20, $02, $f1, $f8, $18, $20, $f1, $00, $10, $20, $02, $f1, $f8
	db $1a, $20, $f1, $00, $12, $20, $02, $f1, $f8, $1c, $20, $f1, $00, $14, $20, $02
	db $f1, $f8, $1e, $20, $f1, $00, $16, $20, $02, $f1, $f8, $28, $20, $f1, $00, $20
	db $20, $02, $f1, $f8, $2a, $20, $f1, $00, $22, $20, $02, $f1, $f8, $2c, $20, $f1
	db $00, $24, $20

Data_02_55b1:
	db $02, $f1, $f8, $2e, $20, $f1, $00, $26, $20

Data_02_55ba:
	db $02, $f8, $f8, $00, $00, $f8, $00, $08, $00, $02, $f8, $f8, $02, $00, $f8, $00
	db $0a, $00, $02, $f8, $f8, $04, $00, $f8, $00, $0c, $00, $02, $f8, $f8, $06, $00
	db $f8, $00, $0e, $00, $02, $f8, $f8, $10, $00, $f8, $00, $18, $00, $02, $f8, $f8
	db $12, $00, $f8, $00, $1a, $00, $02, $f8, $f8, $14, $00, $f8, $00, $1c, $00, $02
	db $f8, $f8, $16, $00, $f8, $00, $1e, $00, $02, $f8, $f8, $20, $00, $f8, $00, $28
	db $00, $02, $f8, $f8, $22, $00, $f8, $00, $2a, $00, $02, $f8, $f8, $24, $00, $f8
	db $00, $2c, $00

Data_02_561d:
	db $02, $f8, $f8, $26, $00, $f8, $00, $2e, $00

Data_02_5626:
	db $02, $f8, $f8, $08, $20, $f8, $00, $00, $20, $02, $f8, $f8, $0a, $20, $f8, $00
	db $02, $20, $02, $f8, $f8, $0c, $20, $f8, $00, $04, $20, $02, $f8, $f8, $0e, $20
	db $f8, $00, $06, $20, $02, $f8, $f8, $18, $20, $f8, $00, $10, $20, $02, $f8, $f8
	db $1a, $20, $f8, $00, $12, $20, $02, $f8, $f8, $1c, $20, $f8, $00, $14, $20, $02
	db $f8, $f8, $1e, $20, $f8, $00, $16, $20, $02, $f8, $f8, $28, $20, $f8, $00, $20
	db $20, $02, $f8, $f8, $2a, $20, $f8, $00, $22, $20, $02, $f8, $f8, $2c, $20, $f8
	db $00, $24, $20

Data_02_5689:
	db $02, $f8, $f8, $2e, $20, $f8, $00, $26, $20

Data_02_5692:
	db $02, $f8, $f8, $00, $00, $f8, $00, $08, $00, $02, $f8, $f8, $02, $00, $f8, $00
	db $0a, $00, $02, $f8, $f8, $04, $00, $f8, $00, $0c, $00, $02, $f8, $f8, $06, $00
	db $f8, $00, $0e, $00

Data_02_56b6:
	db $02, $f8, $f8, $10, $00, $f8, $00, $18, $00, $02, $f8, $f8, $12, $00, $f8, $00
	db $1a, $00, $02, $f8, $f8, $14, $00, $f8, $00, $1c, $00, $02, $f8, $f8, $16, $00
	db $f8, $00, $1e, $00

Data_02_56da:
	db $02, $f8, $f8, $20, $00, $f8, $00, $28, $00, $02, $f8, $f8, $22, $00, $f8, $00
	db $2a, $00

Data_02_56ec:
	db $02, $f8, $f8, $24, $00, $f8, $00, $2c, $00, $02, $f8, $f8, $26, $00, $f8, $00
	db $2e, $00

Data_02_56fe:
	db $02, $f8, $f8, $08, $20, $f8, $00, $00, $20, $02, $f8, $f8, $0a, $20, $f8, $00
	db $02, $20, $02, $f8, $f8, $0c, $20, $f8, $00, $04, $20, $02, $f8, $f8, $0e, $20
	db $f8, $00, $06, $20, $02, $f8, $f8, $10, $40, $f8, $00, $18, $40

Data_02_572b:
	db $02, $f8, $f8, $12, $40, $f8, $00, $1a, $40, $02, $f8, $f8, $14, $40, $f8, $00
	db $1c, $40

Data_02_573d:
	db $02, $f8, $f8, $16, $40, $f8, $00, $1e, $40, $02, $f8, $f8, $28, $20, $f8, $00
	db $20, $20, $02, $f8, $f8, $2a, $20, $f8, $00, $22, $20

Data_02_5758:
	db $02, $f8, $f8, $24, $40, $f8, $00, $2c, $40, $02, $f8, $f8, $26, $40, $f8, $00
	db $2e, $40

Data_02_576a:
	db $02, $f1, $f8, $1c, $60, $f1, $00, $14, $60, $02, $f1, $f8, $1e, $60, $f1, $00
	db $16, $60, $02, $f1, $f8, $14, $40, $f1, $00, $1c, $40, $02, $f1, $f8, $16, $40
	db $f1, $00, $1e, $40, $02, $f8, $f8, $00, $00, $f8, $00, $08, $00, $02, $f8, $f8
	db $02, $00, $f8, $00, $0a, $00, $02, $f8, $f8, $04, $00, $f8, $00, $0c, $00, $02
	db $f8, $f8, $06, $00, $f8, $00, $0e, $00, $02, $f8, $f8, $08, $60, $f8, $00, $00
	db $60, $02, $f8, $f8, $0a, $60, $f8, $00, $02, $60, $02, $f8, $f8, $0c, $60, $f8
	db $00, $04, $60, $02, $f8, $f8, $0e, $60, $f8, $00, $06, $60, $02, $f8, $f8, $08
	db $20, $f8, $00, $00, $20, $02, $f8, $f8, $0a, $20, $f8, $00, $02, $20, $02, $f8
	db $f8, $0c, $20, $f8, $00, $04, $20, $02, $f8, $f8, $0e, $20, $f8, $00, $06, $20
	db $02, $f8, $f8, $00, $40, $f8, $00, $08, $40, $02, $f8, $f8, $02, $40, $f8, $00
	db $0a, $40, $02, $f8, $f8, $04, $40, $f8, $00, $0c, $40, $02, $f8, $f8, $06, $40
	db $f8, $00, $0e, $40, $0c, $e9, $e8, $10, $2c, $e9, $f0, $08, $2c, $e9, $f8, $00
	db $2c, $e9, $00, $00, $0c, $e9, $08, $08, $0c, $e9, $10, $10, $0c, $f9, $e8, $12
	db $2c, $f9, $f0, $0a, $2c, $f9, $f8, $02, $2c, $f9, $00, $02, $0c, $f9, $08, $0a
	db $0c, $f9, $10, $12, $0c, $0c, $e9, $e8, $14, $2c, $e9, $f0, $0c, $2c, $e9, $f8
	db $04, $2c, $e9, $00, $04, $0c, $e9, $08, $0c, $0c, $e9, $10, $14, $0c, $f9, $e8
	db $16, $2c, $f9, $f0, $0e, $2c, $f9, $f8, $06, $2c, $f9, $00, $06, $0c, $f9, $08
	db $0e, $0c, $f9, $10, $16, $0c, $0c, $e9, $e8, $44, $2c, $e9, $f0, $3c, $2c, $e9
	db $f8, $34, $2c, $e9, $00, $18, $0c, $e9, $08, $20, $0c, $e9, $10, $28, $0c, $f9
	db $e8, $46, $2c, $f9, $f0, $3e, $2c, $f9, $f8, $36, $2c, $f9, $00, $1a, $0c, $f9
	db $08, $22, $0c, $f9, $10, $2a, $0c, $0c, $e9, $e8, $2c, $2c, $e9, $f0, $24, $2c
	db $e9, $f8, $1c, $2c, $e9, $00, $1c, $0c, $e9, $08, $24, $0c, $e9, $10, $2c, $0c
	db $f9, $e8, $2e, $2c, $f9, $f0, $26, $2c, $f9, $f8, $1e, $2c, $f9, $00, $1e, $0c
	db $f9, $08, $26, $0c, $f9, $10, $2e, $0c, $0c, $e9, $e8, $40, $2c, $e9, $f0, $38
	db $2c, $e9, $f8, $30, $2c, $e9, $00, $30, $0c, $e9, $08, $38, $0c, $e9, $10, $40
	db $0c, $f9, $e8, $42, $2c, $f9, $f0, $3a, $2c, $f9, $f8, $32, $2c, $f9, $00, $32
	db $0c, $f9, $08, $3a, $0c, $f9, $10, $42, $0c, $0c, $e9, $e8, $28, $2c, $e9, $f0
	db $20, $2c, $e9, $f8, $18, $2c, $e9, $00, $34, $0c, $e9, $08, $3c, $0c, $e9, $10
	db $44, $0c, $f9, $e8, $2a, $2c, $f9, $f0, $22, $2c, $f9, $f8, $1a, $2c, $f9, $00
	db $36, $0c, $f9, $08, $3e, $0c, $f9, $10, $46, $0c, $0c, $e9, $e8, $58, $2c, $e9
	db $f0, $50, $2c, $e9, $f8, $48, $2c, $e9, $00, $4c, $0c, $e9, $08, $54, $0c, $e9
	db $10, $5c, $0c, $f9, $e8, $5a, $2c, $f9, $f0, $52, $2c, $f9, $f8, $4a, $2c, $f9
	db $00, $4e, $0c, $f9, $08, $56, $0c, $f9, $10, $5e, $0c, $0c, $e9, $e8, $5c, $2c
	db $e9, $f0, $54, $2c, $e9, $f8, $4c, $2c, $e9, $00, $48, $0c, $e9, $08, $50, $0c
	db $e9, $10, $58, $0c, $f9, $e8, $5e, $2c, $f9, $f0, $56, $2c, $f9, $f8, $4e, $2c
	db $f9, $00, $4a, $0c, $f9, $08, $52, $0c, $f9, $10, $5a, $0c, $0c, $e9, $e8, $5c
	db $2c, $e9, $f0, $54, $2c, $e9, $f8, $4c, $2c, $e9, $00, $60, $0c, $e9, $08, $68
	db $0c, $e9, $10, $70, $0c, $f9, $e8, $5e, $2c, $f9, $f0, $56, $2c, $f9, $f8, $4e
	db $2c, $f9, $00, $62, $0c, $f9, $08, $6a, $0c, $f9, $10, $72, $0c, $0c, $e9, $e8
	db $70, $2c, $e9, $f0, $68, $2c, $e9, $f8, $60, $2c, $e9, $00, $4c, $0c, $e9, $08
	db $54, $0c, $e9, $10, $5c, $0c, $f9, $e8, $72, $2c, $f9, $f0, $6a, $2c, $f9, $f8
	db $62, $2c, $f9, $00, $4e, $0c, $f9, $08, $56, $0c, $f9, $10, $5e, $0c, $0c, $e9
	db $e8, $c8, $2c, $e9, $f0, $c0, $2c, $e9, $f8, $b8, $2c, $e9, $00, $b8, $0c, $e9
	db $08, $c0, $0c, $e9, $10, $c8, $0c, $f9, $e8, $ca, $2c, $f9, $f0, $c2, $2c, $f9
	db $f8, $ba, $2c, $f9, $00, $ba, $0c, $f9, $08, $c2, $0c, $f9, $10, $ca, $0c, $0c
	db $e9, $e8, $cc, $2c, $e9, $f0, $c4, $2c, $e9, $f8, $bc, $2c, $e9, $00, $bc, $0c
	db $e9, $08, $c4, $0c, $e9, $10, $cc, $0c, $f9, $e8, $ce, $2c, $f9, $f0, $c6, $2c
	db $f9, $f8, $be, $2c, $f9, $00, $be, $0c, $f9, $08, $c6, $0c, $f9, $10, $ce, $0c
	db $01, $f8, $fc, $78, $0c, $02, $f8, $f8, $d0, $0c, $f8, $00, $d8, $0c, $02, $f8
	db $f8, $d2, $0c, $f8, $00, $da, $0c, $02, $f8, $f8, $d4, $0c, $f8, $00, $dc, $0c
	db $04, $f8, $f0, $78, $0d, $f8, $f8, $7a, $0d, $f8, $00, $7a, $0d, $f8, $08, $7c
	db $0d, $0a, $e1, $ec, $00, $0c, $e1, $f4, $08, $0c, $e1, $fc, $10, $0c, $e1, $04
	db $18, $0c, $e1, $0c, $20, $0c, $f1, $ec, $02, $0c, $f1, $f4, $0a, $0c, $f1, $fc
	db $12, $0c, $f1, $04, $1a, $0c, $f1, $0c, $22, $0c, $0a, $e1, $ec, $20, $2c, $e1
	db $f4, $18, $2c, $e1, $fc, $10, $2c, $e1, $04, $08, $2c, $e1, $0c, $00, $2c, $f1
	db $ec, $22, $2c, $f1, $f4, $1a, $2c, $f1, $fc, $12, $2c, $f1, $04, $0a, $2c, $f1
	db $0c, $02, $2c, $0a, $e1, $ec, $04, $0c, $e1, $f4, $0c, $0c, $e1, $fc, $14, $0c
	db $e1, $04, $1c, $0c, $e1, $0c, $24, $0c, $f1, $ec, $06, $0c, $f1, $f4, $0e, $0c
	db $f1, $fc, $16, $0c, $f1, $04, $1e, $0c, $f1, $0c, $26, $0c, $0a, $e1, $ec, $24
	db $2c, $e1, $f4, $1c, $2c, $e1, $fc, $14, $2c, $e1, $04, $0c, $2c, $e1, $0c, $04
	db $2c, $f1, $ec, $26, $2c, $f1, $f4, $1e, $2c, $f1, $fc, $16, $2c, $f1, $04, $0e
	db $2c, $f1, $0c, $06, $2c, $0a, $e1, $ec, $28, $0c, $e1, $f4, $30, $0c, $e1, $fc
	db $38, $0c, $e1, $04, $40, $0c, $e1, $0c, $48, $0c, $f1, $ec, $2a, $0c, $f1, $f4
	db $32, $0c, $f1, $fc, $3a, $0c, $f1, $04, $42, $0c, $f1, $0c, $4a, $0c, $0a, $e1
	db $ec, $48, $2c, $e1, $f4, $40, $2c, $e1, $fc, $38, $2c, $e1, $04, $30, $2c, $e1
	db $0c, $28, $2c, $f1, $ec, $4a, $2c, $f1, $f4, $42, $2c, $f1, $fc, $3a, $2c, $f1
	db $04, $32, $2c, $f1, $0c, $2a, $2c, $0a, $e1, $ec, $2c, $0c, $e1, $f4, $34, $0c
	db $e1, $fc, $3c, $0c, $e1, $04, $44, $0c, $e1, $0c, $4c, $0c, $f1, $ec, $2e, $0c
	db $f1, $f4, $36, $0c, $f1, $fc, $3e, $0c, $f1, $04, $46, $0c, $f1, $0c, $4e, $0c
	db $0a, $e1, $ec, $4c, $2c, $e1, $f4, $44, $2c, $e1, $fc, $3c, $2c, $e1, $04, $34
	db $2c, $e1, $0c, $2c, $2c, $f1, $ec, $4e, $2c, $f1, $f4, $46, $2c, $f1, $fc, $3e
	db $2c, $f1, $04, $36, $2c, $f1, $0c, $2e, $2c

Data_02_5be3:
	db $0a, $e1, $ec, $50, $0c, $e1, $f4, $58, $0c, $e1, $fc, $60, $0c, $e1, $04, $68
	db $0c, $e1, $0c, $70, $0c, $f1, $ec, $52, $0c, $f1, $f4, $5a, $0c, $f1, $fc, $62
	db $0c, $f1, $04, $6a, $0c, $f1, $0c, $72, $0c, $0a, $e1, $ec, $70, $2c, $e1, $f4
	db $68, $2c, $e1, $fc, $60, $2c, $e1, $04, $58, $2c, $e1, $0c, $50, $2c, $f1, $ec
	db $72, $2c, $f1, $f4, $6a, $2c, $f1, $fc, $62, $2c, $f1, $04, $5a, $2c, $f1, $0c
	db $52, $2c

Data_02_5c35:
	db $0a, $e1, $ec, $54, $0c, $e1, $f4, $5c, $0c, $e1, $fc, $64, $0c, $e1, $04, $6c
	db $0c, $e1, $0c, $74, $0c, $f1, $ec, $56, $0c, $f1, $f4, $5e, $0c, $f1, $fc, $66
	db $0c, $f1, $04, $6e, $0c, $f1, $0c, $76, $0c, $0a, $e1, $ec, $74, $2c, $e1, $f4
	db $6c, $2c, $e1, $fc, $64, $2c, $e1, $04, $5c, $2c, $e1, $0c, $54, $2c, $f1, $ec
	db $76, $2c, $f1, $f4, $6e, $2c, $f1, $fc, $66, $2c, $f1, $04, $5e, $2c, $f1, $0c
	db $56, $2c, $0a, $e1, $ec, $b8, $0c, $e1, $f4, $c0, $0c, $e1, $fc, $c8, $0c, $e1
	db $04, $d0, $0c, $e1, $0c, $d8, $0c, $f1, $ec, $ba, $0c, $f1, $f4, $c2, $0c, $f1
	db $fc, $ca, $0c, $f1, $04, $d2, $0c, $f1, $0c, $da, $0c, $0a, $e1, $ec, $d8, $2c
	db $e1, $f4, $d0, $2c, $e1, $fc, $c8, $2c, $e1, $04, $c0, $2c, $e1, $0c, $b8, $2c
	db $f1, $ec, $da, $2c, $f1, $f4, $d2, $2c, $f1, $fc, $ca, $2c, $f1, $04, $c2, $2c
	db $f1, $0c, $ba, $2c, $0a, $e1, $ec, $bc, $0c, $e1, $f4, $c4, $0c, $e1, $fc, $cc
	db $0c, $e1, $04, $d4, $0c, $e1, $0c, $dc, $0c, $f1, $ec, $be, $0c, $f1, $f4, $c6
	db $0c, $f1, $fc, $ce, $0c, $f1, $04, $d6, $0c, $f1, $0c, $de, $0c, $0a, $e1, $ec
	db $dc, $2c, $e1, $f4, $d4, $2c, $e1, $fc, $cc, $2c, $e1, $04, $c4, $2c, $e1, $0c
	db $bc, $2c, $f1, $ec, $de, $2c, $f1, $f4, $d6, $2c, $f1, $fc, $ce, $2c, $f1, $04
	db $c6, $2c, $f1, $0c, $be, $2c

Data_02_5d2b:
	db $0a, $e1, $ec, $d0, $04, $e1, $f4, $d8, $04, $e1, $fc, $e0, $04, $e1, $04, $e8
	db $04, $e1, $0c, $f0, $04, $f1, $ec, $d2, $04, $f1, $f4, $da, $04, $f1, $fc, $e2
	db $04, $f1, $04, $ea, $04, $f1, $0c, $f2, $04

Data_02_5d54:
	db $0a, $e1, $ec, $f0, $24, $e1, $f4, $e8, $24, $e1, $fc, $e0, $24, $e1, $04, $d8
	db $24, $e1, $0c, $d0, $24, $f1, $ec, $f2, $24, $f1, $f4, $ea, $24, $f1, $fc, $e2
	db $24, $f1, $04, $da, $24, $f1, $0c, $d2, $24, $01, $f8, $fc, $78, $0e, $01, $f8
	db $fc, $7a, $0e, $01, $f8, $fc, $7c, $0e, $01, $f8, $fc, $7e, $0e, $02, $f8, $f8
	db $b8, $0d, $f8, $00, $c0, $0d, $02, $f8, $f8, $ba, $0d, $f8, $00, $c2, $0d, $02
	db $f8, $f8, $bc, $0d, $f8, $00, $c4, $0d, $02, $f8, $f8, $be, $0d, $f8, $00, $c6
	db $0d, $0c, $e1, $e8, $10, $2c, $e1, $f0, $08, $2c, $e1, $f8, $00, $2c, $e1, $00
	db $00, $0c, $e1, $08, $08, $0c, $e1, $10, $10, $0c, $f1, $e8, $12, $2c, $f1, $f0
	db $0a, $2c, $f1, $f8, $02, $2c, $f1, $00, $02, $0c, $f1, $08, $0a, $0c, $f1, $10
	db $12, $0c, $0c, $e1, $e8, $14, $2c, $e1, $f0, $0c, $2c, $e1, $f8, $04, $2c, $e1
	db $00, $04, $0c, $e1, $08, $0c, $0c, $e1, $10, $14, $0c, $f1, $e8, $16, $2c, $f1
	db $f0, $0e, $2c, $f1, $f8, $06, $2c, $f1, $00, $06, $0c, $f1, $08, $0e, $0c, $f1
	db $10, $16, $0c, $0c, $e1, $e8, $28, $2c, $e1, $f0, $20, $2c, $e1, $f8, $18, $2c
	db $e1, $00, $18, $0c, $e1, $08, $20, $0c, $e1, $10, $28, $0c, $f1, $e8, $2a, $2c
	db $f1, $f0, $22, $2c, $f1, $f8, $1a, $2c, $f1, $00, $1a, $0c, $f1, $08, $22, $0c
	db $f1, $10, $2a, $0c, $0c, $e1, $e8, $2c, $2c, $e1, $f0, $24, $2c, $e1, $f8, $1c
	db $2c, $e1, $00, $1c, $0c, $e1, $08, $24, $0c, $e1, $10, $2c, $0c, $f1, $e8, $2e
	db $2c, $f1, $f0, $26, $2c, $f1, $f8, $1e, $2c, $f1, $00, $1e, $0c, $f1, $08, $26
	db $0c, $f1, $10, $2e, $0c, $0c, $e1, $e8, $40, $2c, $e1, $f0, $38, $2c, $e1, $f8
	db $30, $2c, $e1, $00, $30, $0c, $e1, $08, $38, $0c, $e1, $10, $40, $0c, $f1, $e8
	db $42, $2c, $f1, $f0, $3a, $2c, $f1, $f8, $32, $2c, $f1, $00, $32, $0c, $f1, $08
	db $3a, $0c, $f1, $10, $42, $0c, $0c, $e1, $e8, $58, $2c, $e1, $f0, $50, $2c, $e1
	db $f8, $48, $2c, $e1, $00, $44, $2c, $e1, $08, $3c, $2c, $e1, $10, $34, $2c, $f1
	db $e8, $5a, $2c, $f1, $f0, $52, $2c, $f1, $f8, $4a, $2c, $f1, $00, $46, $2c, $f1
	db $08, $3e, $2c, $f1, $10, $36, $2c, $0c, $e1, $e8, $34, $0c, $e1, $f0, $3c, $0c
	db $e1, $f8, $44, $0c, $e1, $00, $48, $0c, $e1, $08, $50, $0c, $e1, $10, $58, $0c
	db $f1, $e8, $36, $0c, $f1, $f0, $3e, $0c, $f1, $f8, $46, $0c, $f1, $00, $4a, $0c
	db $f1, $08, $52, $0c, $f1, $10, $5a, $0c, $0c, $e1, $e8, $5c, $2c, $e1, $f0, $54
	db $2c, $e1, $f8, $4c, $2c, $e1, $00, $4c, $0c, $e1, $08, $54, $0c, $e1, $10, $5c
	db $0c, $f1, $e8, $5e, $2c, $f1, $f0, $56, $2c, $f1, $f8, $4e, $2c, $f1, $00, $4e
	db $0c, $f1, $08, $56, $0c, $f1, $10, $5e, $0c, $0c, $e1, $e8, $70, $2c, $e1, $f0
	db $68, $2c, $e1, $f8, $60, $2c, $e1, $00, $60, $0c, $e1, $08, $68, $0c, $e1, $10
	db $70, $0c, $f1, $e8, $72, $2c, $f1, $f0, $6a, $2c, $f1, $f8, $62, $2c, $f1, $00
	db $62, $0c, $f1, $08, $6a, $0c, $f1, $10, $72, $0c, $0c, $e1, $e8, $74, $2c, $e1
	db $f0, $6c, $2c, $e1, $f8, $64, $2c, $e1, $00, $64, $0c, $e1, $08, $6c, $0c, $e1
	db $10, $74, $0c, $f1, $e8, $76, $2c, $f1, $f0, $6e, $2c, $f1, $f8, $66, $2c, $f1
	db $00, $66, $0c, $f1, $08, $6e, $0c, $f1, $10, $76, $0c, $02, $f8, $f8, $60, $0d
	db $f8, $00, $68, $0d, $02, $f8, $f8, $70, $0d, $f8, $00, $78, $0d, $02, $f8, $f8
	db $72, $0d, $f8, $00, $7a, $0d, $02, $f8, $f8, $74, $0d, $f8, $00, $7c, $0d, $02
	db $f8, $f8, $76, $0d, $f8, $00, $7e, $0d, $02, $f8, $f8, $62, $0e, $f8, $00, $6a
	db $0e, $02, $f8, $f8, $64, $0e, $f8, $00, $6c, $0e, $02, $f8, $f8, $66, $0e, $f8
	db $00, $6e, $0e, $08, $f0, $f0, $00, $0c, $f0, $f8, $08, $0c, $f0, $00, $10, $0c
	db $f0, $08, $18, $0c, $00, $f0, $02, $0c, $00, $f8, $0a, $0c, $00, $00, $12, $0c
	db $00, $08, $1a, $0c, $08, $f0, $f0, $04, $0f, $f0, $f8, $0c, $0f, $f0, $00, $14
	db $0f, $f0, $08, $1c, $0f, $00, $f0, $06, $0f, $00, $f8, $0e, $0f, $00, $00, $16
	db $0f, $00, $08, $1e, $0f, $08, $e8, $f0, $20, $0f, $e8, $f8, $28, $0f, $e8, $00
	db $30, $0f, $e8, $08, $38, $0f, $f8, $f0, $22, $0f, $f8, $f8, $2a, $0f, $f8, $00
	db $32, $0f, $f8, $08, $3a, $0f, $08, $f0, $f0, $24, $0f, $f0, $f8, $2c, $0f, $f0
	db $00, $34, $0f, $f0, $08, $3c, $0f, $00, $f0, $26, $0f, $00, $f8, $2e, $0f, $00
	db $00, $36, $0f, $00, $08, $3e, $0f, $04, $f1, $f0, $40, $0c, $f1, $f8, $48, $0c
	db $f1, $00, $50, $0c, $f1, $08, $58, $0c, $04, $f0, $f0, $40, $0f, $f0, $f8, $48
	db $0f, $f0, $00, $50, $0f, $f0, $08, $58, $0f, $0c, $e8, $f0, $00, $0c, $e8, $f8
	db $08, $0c, $e8, $00, $10, $0c, $e8, $08, $18, $0c, $f8, $f0, $02, $0c, $f8, $f8
	db $0a, $0c, $f8, $00, $12, $0c, $f8, $08, $1a, $0c, $08, $f0, $04, $0c, $08, $f8
	db $0c, $0c, $08, $00, $14, $0c, $08, $08, $1c, $0c, $0c, $e8, $f0, $1e, $2c, $e8
	db $f8, $16, $2c, $e8, $00, $0e, $2c, $e8, $08, $06, $2c, $f8, $f0, $38, $2c, $f8
	db $f8, $30, $2c, $f8, $00, $28, $2c, $f8, $08, $20, $2c, $08, $f0, $3a, $2c, $08
	db $f8, $32, $2c, $08, $00, $2a, $2c, $08, $08, $22, $2c, $0c, $e8, $f0, $06, $0c
	db $e8, $f8, $0e, $0c, $e8, $00, $16, $0c, $e8, $08, $1e, $0c, $f8, $f0, $20, $0c
	db $f8, $f8, $28, $0c, $f8, $00, $30, $0c, $f8, $08, $38, $0c, $08, $f0, $22, $0c
	db $08, $f8, $2a, $0c, $08, $00, $32, $0c, $08, $08, $3a, $0c, $0c, $e8, $f0, $3c
	db $2c, $e8, $f8, $34, $2c, $e8, $00, $2c, $2c, $e8, $08, $24, $2c, $f8, $f0, $3e
	db $2c, $f8, $f8, $36, $2c, $f8, $00, $2e, $2c, $f8, $08, $26, $2c, $08, $f0, $58
	db $2c, $08, $f8, $50, $2c, $08, $00, $48, $2c, $08, $08, $40, $2c, $0c, $e8, $f0
	db $24, $0c, $e8, $f8, $2c, $0c, $e8, $00, $34, $0c, $e8, $08, $3c, $0c, $f8, $f0
	db $26, $0c, $f8, $f8, $2e, $0c, $f8, $00, $36, $0c, $f8, $08, $3e, $0c, $08, $f0
	db $40, $0c, $08, $f8, $48, $0c, $08, $00, $50, $0c, $08, $08, $58, $0c, $0c, $e8
	db $f0, $5a, $2c, $e8, $f8, $52, $2c, $e8, $00, $4a, $2c, $e8, $08, $42, $2c, $f8
	db $f0, $5c, $2c, $f8, $f8, $54, $2c, $f8, $00, $4c, $2c, $f8, $08, $44, $2c, $08
	db $f0, $5e, $2c, $08, $f8, $56, $2c, $08, $00, $4e, $2c, $08, $08, $46, $2c, $0c
	db $e8, $f0, $42, $0c, $e8, $f8, $4a, $0c, $e8, $00, $52, $0c, $e8, $08, $5a, $0c
	db $f8, $f0, $44, $0c, $f8, $f8, $4c, $0c, $f8, $00, $54, $0c, $f8, $08, $5c, $0c
	db $08, $f0, $46, $0c, $08, $f8, $4e, $0c, $08, $00, $56, $0c, $08, $08, $5e, $0c
	db $0c, $e8, $f0, $78, $2c, $e8, $f8, $70, $2c, $e8, $00, $68, $2c, $e8, $08, $60
	db $2c, $f8, $f0, $7a, $2c, $f8, $f8, $72, $2c, $f8, $00, $6a, $2c, $f8, $08, $62
	db $2c, $08, $f0, $7c, $2c, $08, $f8, $74, $2c, $08, $00, $6c, $2c, $08, $08, $64
	db $2c, $0c, $e8, $f0, $60, $0c, $e8, $f8, $68, $0c, $e8, $00, $70, $0c, $e8, $08
	db $78, $0c, $f8, $f0, $62, $0c, $f8, $f8, $6a, $0c, $f8, $00, $72, $0c, $f8, $08
	db $7a, $0c, $08, $f0, $64, $0c, $08, $f8, $6c, $0c, $08, $00, $74, $0c, $08, $08
	db $7c, $0c, $0c, $e8, $f0, $7e, $2c, $e8, $f8, $76, $2c, $e8, $00, $6e, $2c, $e8
	db $08, $66, $2c, $f8, $f0, $d0, $2c, $f8, $f8, $c8, $2c, $f8, $00, $c0, $2c, $f8
	db $08, $b8, $2c, $08, $f0, $d2, $2c, $08, $f8, $ca, $2c, $08, $00, $c2, $2c, $08
	db $08, $ba, $2c, $0c, $e8, $f0, $66, $0c, $e8, $f8, $6e, $0c, $e8, $00, $76, $0c
	db $e8, $08, $7e, $0c, $f8, $f0, $b8, $0c, $f8, $f8, $c0, $0c, $f8, $00, $c8, $0c
	db $f8, $08, $d0, $0c, $08, $f0, $ba, $0c, $08, $f8, $c2, $0c, $08, $00, $ca, $0c
	db $08, $08, $d2, $0c, $0c, $e8, $f0, $bc, $0c, $e8, $f8, $c4, $0c, $e8, $00, $cc
	db $0c, $e8, $08, $d4, $0c, $f8, $f0, $be, $0c, $f8, $f8, $c6, $0c, $f8, $00, $ce
	db $0c, $f8, $08, $d6, $0c, $08, $f0, $d8, $0c, $08, $f8, $e0, $0c, $08, $00, $e8
	db $0c, $08, $08, $f0, $0c, $0c, $e8, $f0, $da, $0c, $e8, $f8, $e2, $0c, $e8, $00
	db $ea, $0c, $e8, $08, $f2, $0c, $f8, $f0, $dc, $0c, $f8, $f8, $e4, $0c, $f8, $00
	db $ec, $0c, $f8, $08, $f4, $0c, $08, $f0, $de, $0c, $08, $f8, $e6, $0c, $08, $00
	db $ee, $0c, $08, $08, $f6, $0c, $02, $f8, $f8, $d8, $24, $f8, $00, $d0, $24, $02
	db $f8, $f8, $d0, $04, $f8, $00, $d8, $04, $02, $f8, $f8, $da, $24, $f8, $00, $d2
	db $24, $02, $f8, $f8, $d2, $04, $f8, $00, $da, $04, $02, $f8, $f8, $dc, $24, $f8
	db $00, $d4, $24, $02, $f8, $f8, $d4, $04, $f8, $00, $dc, $04

SECTION "analyzed_010000", ROMX[$4000], BANK[$04]

Func_04_4000:
	ld hl, $ffce
	ld a, [hl+]
	ld e, a
	ld d, [hl]
Func_04_4006:
	ld a, [de]
	add a, a
	ld c, a
	ld b, $00
	ld hl, $401a
	add hl, bc
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp hl
Func_04_4013:
	ld hl, $ffce
	ld a, e
	ld [hl+], a
	ld [hl], d
	ret

Data_04_401a:
	db $3c, $40, $41, $40, $4e, $40, $55, $40, $62, $40, $6a, $40, $84, $40, $9f, $40
	db $ba, $40, $c3, $40, $cc, $40

SECTION "analyzed_01003a", ROMX[$403a], BANK[$04]

Data_04_403a:
	db $d8, $40

Func_04_403c:
	xor a
	ldh [hEntityUpdate2], a
	jr Func_04_4013
	inc de
	ld a, [de]
	ldh [$ffb2], a
	ld c, a
	inc de
	push de
	call Func_04_419d
	pop de
	jr Func_04_4006
	inc de
	ld a, [de]
	ldh [$ffc5], a
	inc de
	jr Func_04_4006
	ld c, $c5
	ldh a, [c]
	or a
	jr z, Func_04_405f
	dec a
	ldh [c], a
	jr Func_04_4013
Func_04_405f:
	inc de
	jr Func_04_4006
	inc de
	ld a, [de]
	call PlaySound
	inc de
	jr Func_04_4006
	inc de
	push de
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_04_4157
	pop de
	jr Func_04_4006
	inc de
	push de
	ldh a, [hEntityX]
	add a, $08
	swap a
	and $0f
	ld c, a
	ldh a, [hEntityY]
	add a, $08
	swap a
	and $0f
	ld b, a
	call Func_04_4191
	pop de
	jp Func_04_4006
	inc de
	ld hl, $ffb6
	ld a, [de]
	inc de
	or a
	jr z, Func_04_40b5
	cp $01
	jr z, Func_04_40b0
	bit 7, [hl]
	jr nz, Func_04_40b5
Func_04_40b0:
	set 7, [hl]
	jp Func_04_4006
Func_04_40b5:
	res 7, [hl]
	jp Func_04_4006
	inc de
	ld hl, $ffb6
	set 6, [hl]
	jp Func_04_4006
	inc de
	ld hl, $ffb6
	res 6, [hl]
	jp Func_04_4006
	inc de
	ld hl, $4006
	push hl
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld h, a
	inc de
	jp hl
	inc de
	ld a, [de]
	ld l, a
	inc de
	ld a, [de]
	ld d, a
	ld e, l
	jp Func_04_4006
Func_04_40e2:
	ld a, b
	ldh [hEntityUpdate2], a
	ld l, a
	ld h, $00
	sla l
	rl h
	ldh a, [$ffcc]
	add a, l
	ld l, a
	ldh a, [$ffcd]
	adc a, h
	ld h, a
	ld a, [hl+]
	ldh [$ffce], a
	ld a, [hl]
	ldh [$ffcf], a
	xor a
	ldh [$ffb2], a
	ldh [$ffc5], a
	ret
Func_04_4100:
	ld a, [$cf67]
	ld l, a
	ld a, [$cf68]
	ld h, a
	ld a, $04
	rst AddAToHL
	ld a, [hl+]
	ld [$cf6b], a
	ld a, [hl]
	ld [$cf6c], a
	ret
Func_04_4114:
	ldh a, [$ffca]
	ld l, a
	ldh a, [$ffcb]
	ld h, a
	ldh a, [$ffb2]
	ld c, a
	ld b, $00
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	ldh a, [hEntityFacing]
	bit 7, a
	jr z, Func_04_4133
	inc bc
	inc bc
Func_04_4133:
	add hl, bc
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ret
Func_04_4138:
	push bc
	push hl
	ld b, $00
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	ld hl, $0006
	add hl, bc
	ldh a, [$ffca]
	ld c, a
	ldh a, [$ffcb]
	ld b, a
	add hl, bc
	ld a, [hl]
	pop hl
	pop bc
	ret
Func_04_4157:
	push bc
	call ReadFloorCell
	cp $22
	jr z, Func_04_4175
	cp $23
	jr z, Func_04_4175
	or a
	jr nz, Func_04_418f
	ldh a, [$ffac]
	bit 6, a
	jr nz, Func_04_418f
	ld a, c
	ld hl, wFloorCollision
	rst AddAToHL
	ld [hl], $22
	pop bc
	ret
Func_04_4175:
	ld b, $00
	ld hl, wFloorCollision
	add hl, bc
	ld [hl], $00
	ld hl, wFloorGrid
	add hl, bc
	pop bc
	ld a, [hl]
	bit 7, a
	jr z, Func_04_418b
	call Func_00_11dc
	ld [hl], a
Func_04_418b:
	call DrawFloorPiece
	ret

Func_04_418f:
	pop bc
	ret

Func_04_4191:
	push bc
	call Func_00_102b
	pop bc
	cp $22
	ret nz
	call DrawFloorPiece
	ret
Func_04_419d:
	ld b, $00
	sla c
	rl b
	sla c
	rl b
	sla c
	rl b
	ld hl, $0004
	add hl, bc
	ldh a, [$ffca]
	ld c, a
	ldh a, [$ffcb]
	ld b, a
	add hl, bc
	push hl
	ld a, [hl]
	ld c, $d2
	call Func_04_4355
	pop hl
	inc hl
	ld a, [hl]
	ld c, $d6
	call Func_04_4355
	ret
	push de
	push hl
	ld b, $03
	ld c, $0e
	ld a, $60
	call Func_04_4247
	ld b, $03
	ld c, $0f
	ld a, $61
	call Func_04_4247
	ld b, $04
	ld c, $0f
	ld a, $62
	call Func_04_4247
	ld b, $05
	ld c, $0e
	ld a, $63
	call Func_04_4247
	ld b, $05
	ld c, $0f
	ld a, $64
	call Func_04_4247
	ld b, $06
	ld c, $0f
	ld a, $65
	call Func_04_4247
	ld b, $07
	ld c, $0f
	ld a, $66
	call Func_04_4247
	pop hl
	pop de
	ret
	push de
	push hl
	ld b, $03
	ld c, $0e
	xor a
	call Func_04_4247
	ld b, $03
	ld c, $0f
	xor a
	call Func_04_4247
	ld b, $04
	ld c, $0f
	xor a
	call Func_04_4247
	ld b, $05
	ld c, $0e
	xor a
	call Func_04_4247
	ld b, $05
	ld c, $0f
	xor a
	call Func_04_4247
	ld b, $06
	ld c, $0f
	xor a
	call Func_04_4247
	ld b, $07
	ld c, $0f
	xor a
	call Func_04_4247
	pop hl
	pop de
	ret
Func_04_4247:
	push af
	ld a, b
	swap a
	and $f0
	add a, b
	add a, c
	ld e, a
	ld d, $00
	ld hl, wFloorGrid
	add hl, de
	pop af
	ld [hl], a
	call DrawFloorPiece
	ret
Func_04_425c:
	xor a
	ld [$cc94], a
	ld c, $1c
	ld hl, $cd74
	ld de, $0008
Func_04_4268:
	ld [hl], a
	add hl, de
	dec c
	jr nz, Func_04_4268
	ld c, $1c
	ld hl, $ce54
Func_04_4272:
	ld [hl], a
	add hl, de
	dec c
	jr nz, Func_04_4272
	xor a
	ld [$cc91], a
	ld [$cc92], a
	ld [$cc93], a
	ld c, $1c
	ld hl, $c7f9
Func_04_4286:
	ld a, [hl]
	or a
	jr z, Func_04_42ab
	inc hl
	ld a, [hl-]
	or a
	jr z, Func_04_42ab
	call Func_00_11b4
	or a
	jr z, Func_04_42ab
	push hl
	ld de, $0006
	add hl, de
	ld a, [hl]
	pop hl
	bit 6, a
	jr nz, Func_04_42ab
	push bc
	push hl
	ld a, [hl]
	call Func_04_44ec
	call Func_04_42b3
	pop hl
	pop bc
Func_04_42ab:
	ld de, $002a
	add hl, de
	dec c
	jr nz, Func_04_4286
	ret
Func_04_42b3:
	ld [wBankCallTmp], a
	and $0f
	jr z, Func_04_42c6
	cp $01
	jr z, Func_04_42ce
	ld de, $ce54
	ld bc, $cc93
	jr Func_04_42d4
Func_04_42c6:
	ld de, $cc94
	ld bc, $cc91
	jr Func_04_42d4
Func_04_42ce:
	ld de, $cd74
	ld bc, $cc92
Func_04_42d4:
	ld a, [bc]
	cp $1c
	ret z
	push hl
	ld l, a
	ld h, $00
	inc a
	ld [bc], a
	sla l
	rl h
	sla l
	rl h
	sla l
	rl h
	add hl, de
	ld d, h
	ld e, l
	pop hl
	ld a, $01
	ld [de], a
	inc de
	ld a, [wBankCallTmp]
	ld [de], a
	inc de
	call Func_04_4319
	call Func_04_4114
	ld a, l
	ld [de], a
	inc de
	ld a, h
	ld [de], a
	inc de
	ldh a, [$ffb2]
	ld c, a
	call Func_04_4138
	ld [de], a
	inc de
	ldh a, [$ffd0]
	and $03
	ld [de], a
	inc de
	ldh a, [hEntityX]
	ld [de], a
	inc de
	ldh a, [hEntityY]
	ld [de], a
	ret
Func_04_4319:
	ld a, [hl+]
	ldh [hEntityState], a
	inc hl
	ld a, [hl+]
	ldh [$ffb2], a
	ld bc, $0003
	add hl, bc
	ld a, [hl+]
	ldh [hEntityFacing], a
	ld bc, $0005
	add hl, bc
	ld a, [hl+]
	ldh [hEntityX], a
	inc hl
	ld a, [hl+]
	ldh [hEntityY], a
	ld bc, $000b
	add hl, bc
	ld a, [hl+]
	ldh [$ffca], a
	ld a, [hl+]
	ldh [$ffcb], a
	ld bc, $0004
	add hl, bc
	ld a, [hl+]
	ldh [$ffd0], a
	ret
Func_04_4344:
	ld a, [$cf6b]
	ld c, $da
	call Func_04_4355
	ld a, [$cf6c]
	ld c, $de
	call Func_04_4355
	ret
Func_04_4355:
	ld l, a
	ld h, $00
	sla l
	rl h
	sla l
	rl h
	ld de, $4370
	add hl, de
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
	ret

Data_04_4370:
	db $00, $00, $00, $00, $fc, $f3, $08, $0e, $fc, $f3, $08, $0a, $fc, $f5, $08, $08

SECTION "analyzed_010388", ROMX[$4388], BANK[$04]

Data_04_4388:
	db $fc, $f9, $08, $10, $f0, $f8, $20, $10, $f9, $f9, $0e, $0e, $fa, $fa, $0c, $0c

Data_04_4398:
	db $f8, $f8, $10, $10, $f8, $00, $10, $08

Data_04_43a0:
	db $fa, $f3, $0c, $0e, $fc, $f5, $08, $08, $fa, $f9, $0c, $0e, $fc, $fa, $08, $0c
	db $fa, $f1, $0c, $10, $fd, $f2, $06, $0e, $fd, $f9, $06, $08, $fc, $fc, $08, $08
	db $fa, $fa, $0c, $0c

SECTION "analyzed_0103f0", ROMX[$43f0], BANK[$04]

Data_04_43f0:
	db $ec, $e9, $28, $18, $e8, $e9, $30, $18, $f0, $e9, $20, $18, $f0, $e9, $20, $18
	db $e8, $e1, $30, $20, $e8, $e1, $30, $20, $f4, $f9, $18, $14, $f4, $ed, $18, $14
	db $f4, $f5, $1b, $0c, $f8, $ea, $10, $2c, $f8, $ea, $10, $2c

SECTION "analyzed_010430", ROMX[$4430], BANK[$04]

Data_04_4430:
	db $fc, $fc, $08, $08, $fc, $fc, $08, $08, $fc, $fc, $08, $08

Data_04_443c:
	db $fc, $fc, $08, $08

Data_04_4440:
	db $fc, $fc, $08, $08, $fc, $fc, $08, $08, $fa, $fa, $0c, $0c, $fa, $fa, $0c, $0c
	db $fa, $fa, $0c, $0c, $f8, $f8, $10, $10

SECTION "analyzed_010470", ROMX[$4470], BANK[$04]

Data_04_4470:
	db $fc, $f4, $08, $08

Data_04_4474:
	db $fc, $f4, $08, $08

Data_04_4478:
	db $fc, $f4, $08, $08

SECTION "analyzed_01047d", ROMX[$447d], BANK[$04]

Data_04_447d:
	db $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01

SECTION "analyzed_010491", ROMX[$4491], BANK[$04]

Data_04_4491:
	db $01

SECTION "analyzed_010492", ROMX[$4492], BANK[$04]

Data_04_4492:
	db $01, $01, $01, $01, $01, $01

Data_04_4498:
	db $01, $00, $01

Data_04_449b:
	db $01, $11, $11

SECTION "analyzed_01049e", ROMX[$449e], BANK[$04]

Data_04_449e:
	db $11

SECTION "analyzed_01049f", ROMX[$449f], BANK[$04]

Data_04_449f:
	db $11, $11, $11

SECTION "analyzed_0104a2", ROMX[$44a2], BANK[$04]

Data_04_44a2:
	db $11

SECTION "analyzed_0104a3", ROMX[$44a3], BANK[$04]

Data_04_44a3:
	db $11, $01, $01, $11

SECTION "analyzed_0104a7", ROMX[$44a7], BANK[$04]

Data_04_44a7:
	db $11

SECTION "analyzed_0104a8", ROMX[$44a8], BANK[$04]

Data_04_44a8:
	db $01, $02, $02, $02, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11, $11
	db $11, $01, $02, $01, $11, $11, $11, $11, $11, $11

SECTION "analyzed_0104cc", ROMX[$44cc], BANK[$04]

Data_04_44cc:
	db $01, $01, $01, $01, $01, $01

SECTION "analyzed_0104dc", ROMX[$44dc], BANK[$04]

Data_04_44dc:
	db $02, $02, $02, $02

SECTION "analyzed_0104ec", ROMX[$44ec], BANK[$04]

Func_04_44ec:
	push hl
	ld hl, $447c
	rst AddAToHL
	ld a, [hl]
	pop hl
	ret

Data_04_44f4:
	db $5a, $53

Data_04_44f6:
	db $5a, $53

Data_04_44f8:
	db $00, $00, $00

SECTION "analyzed_0104fc", ROMX[$44fc], BANK[$04]

Data_04_44fc:
	db $15, $53

Data_04_44fe:
	db $15, $53

Data_04_4500:
	db $00, $00, $00

SECTION "analyzed_010504", ROMX[$4504], BANK[$04]

Data_04_4504:
	db $1e, $53

Data_04_4506:
	db $1e, $53

Data_04_4508:
	db $00, $00, $00

SECTION "analyzed_01050c", ROMX[$450c], BANK[$04]

Data_04_450c:
	db $27, $53

Data_04_450e:
	db $27, $53

Data_04_4510:
	db $00, $00, $00

SECTION "analyzed_010514", ROMX[$4514], BANK[$04]

Data_04_4514:
	db $2c, $53, $2c, $53, $00, $00, $00

SECTION "analyzed_01051c", ROMX[$451c], BANK[$04]

Data_04_451c:
	db $31, $53

Data_04_451e:
	db $31, $53

Data_04_4520:
	db $00, $00, $00

SECTION "analyzed_010524", ROMX[$4524], BANK[$04]

Data_04_4524:
	db $43, $53, $3a, $53, $00, $00, $00

SECTION "analyzed_01052c", ROMX[$452c], BANK[$04]

Data_04_452c:
	db $4c, $53

Data_04_452e:
	db $4c, $53

Data_04_4530:
	db $00, $00, $00

SECTION "analyzed_010534", ROMX[$4534], BANK[$04]

Data_04_4534:
	db $51, $53

Data_04_4536:
	db $51, $53

Data_04_4538:
	db $00, $00, $00

SECTION "analyzed_01053c", ROMX[$453c], BANK[$04]

Data_04_453c:
	db $8c, $53

Data_04_453e:
	db $8c, $53

Data_04_4540:
	db $30, $30, $00

SECTION "analyzed_010544", ROMX[$4544], BANK[$04]

Data_04_4544:
	db $95, $53

Data_04_4546:
	db $95, $53

Data_04_4548:
	db $30, $30, $00

SECTION "analyzed_01054c", ROMX[$454c], BANK[$04]

Data_04_454c:
	db $9e, $53

Data_04_454e:
	db $9e, $53

Data_04_4550:
	db $30, $30, $00

SECTION "analyzed_010554", ROMX[$4554], BANK[$04]

Data_04_4554:
	db $a7, $53

Data_04_4556:
	db $a7, $53

Data_04_4558:
	db $30, $30, $00

SECTION "analyzed_01055c", ROMX[$455c], BANK[$04]

Data_04_455c:
	db $d0, $54

Data_04_455e:
	db $d0, $54

Data_04_4560:
	db $00, $00, $00

SECTION "analyzed_010564", ROMX[$4564], BANK[$04]

Data_04_4564:
	db $b9, $53

Data_04_4566:
	db $b9, $53

Data_04_4568:
	db $31, $31, $00

SECTION "analyzed_01056c", ROMX[$456c], BANK[$04]

Data_04_456c:
	db $c2, $53

Data_04_456e:
	db $c2, $53

Data_04_4570:
	db $31, $31, $00

SECTION "analyzed_010574", ROMX[$4574], BANK[$04]

Data_04_4574:
	db $cb, $53

Data_04_4576:
	db $cb, $53

Data_04_4578:
	db $31, $31, $00

SECTION "analyzed_01057c", ROMX[$457c], BANK[$04]

Data_04_457c:
	db $d4, $53

Data_04_457e:
	db $d4, $53

Data_04_4580:
	db $31, $31, $00

SECTION "analyzed_010584", ROMX[$4584], BANK[$04]

Data_04_4584:
	db $2a, $55, $96, $55, $00, $40, $03

SECTION "analyzed_01058c", ROMX[$458c], BANK[$04]

Data_04_458c:
	db $33, $55, $9f, $55, $00, $40, $03

SECTION "analyzed_010594", ROMX[$4594], BANK[$04]

Data_04_4594:
	db $2a, $55, $96, $55, $00, $00, $00

SECTION "analyzed_01059c", ROMX[$459c], BANK[$04]

Data_04_459c:
	db $33, $55, $9f, $55, $00, $00, $00

SECTION "analyzed_0105a4", ROMX[$45a4], BANK[$04]

Data_04_45a4:
	db $3c, $55, $a8, $55, $00, $00, $00

Data_04_45ab:
	db $00, $02, $56, $6e, $56, $00, $00, $03, $00, $0b, $56, $77, $56, $00, $00, $03
	db $00, $14, $56, $80, $56, $00, $00, $03, $00, $1d, $56, $89, $56, $00, $00, $03
	db $00

Data_04_45cc:
	db $02, $56, $6e, $56, $00, $00, $01

SECTION "analyzed_0105d4", ROMX[$45d4], BANK[$04]

Data_04_45d4:
	db $0b, $56, $77, $56, $00, $00, $01

SECTION "analyzed_0105dc", ROMX[$45dc], BANK[$04]

Data_04_45dc:
	db $14, $56, $80, $56, $00, $00, $01

SECTION "analyzed_0105e4", ROMX[$45e4], BANK[$04]

Data_04_45e4:
	db $02, $56, $6e, $56, $00, $32, $03

SECTION "analyzed_0105ec", ROMX[$45ec], BANK[$04]

Data_04_45ec:
	db $88, $54

Data_04_45ee:
	db $88, $54

Data_04_45f0:
	db $00, $00, $00

SECTION "analyzed_0105f4", ROMX[$45f4], BANK[$04]

Data_04_45f4:
	db $91, $54

Data_04_45f6:
	db $91, $54

Data_04_45f8:
	db $00, $00, $00

SECTION "analyzed_0105fc", ROMX[$45fc], BANK[$04]

Data_04_45fc:
	db $9a, $54

Data_04_45fe:
	db $9a, $54

Data_04_4600:
	db $00, $00, $00

SECTION "analyzed_010604", ROMX[$4604], BANK[$04]

Data_04_4604:
	db $a3, $54

Data_04_4606:
	db $a3, $54

Data_04_4608:
	db $00, $00, $00

SECTION "analyzed_01060c", ROMX[$460c], BANK[$04]

Data_04_460c:
	db $ac, $54

Data_04_460e:
	db $ac, $54

Data_04_4610:
	db $00, $00, $00

SECTION "analyzed_010614", ROMX[$4614], BANK[$04]

Data_04_4614:
	db $b5, $54

Data_04_4616:
	db $b5, $54

Data_04_4618:
	db $00, $00, $00

SECTION "analyzed_01061c", ROMX[$461c], BANK[$04]

Data_04_461c:
	db $be, $54

Data_04_461e:
	db $be, $54

Data_04_4620:
	db $00, $00, $00

SECTION "analyzed_010624", ROMX[$4624], BANK[$04]

Data_04_4624:
	db $c7, $54

Data_04_4626:
	db $c7, $54

Data_04_4628:
	db $00, $00, $00

SECTION "analyzed_01062c", ROMX[$462c], BANK[$04]

Data_04_462c:
	db $8a, $5a

Data_04_462e:
	db $8a, $5a

Data_04_4630:
	db $07, $07, $00

SECTION "analyzed_010634", ROMX[$4634], BANK[$04]

Data_04_4634:
	db $8a, $5a

Data_04_4636:
	db $8a, $5a

Data_04_4638:
	db $07, $00, $00

SECTION "analyzed_01063c", ROMX[$463c], BANK[$04]

Data_04_463c:
	db $01, $54

Data_04_463e:
	db $01, $54

Data_04_4640:
	db $30, $00, $00

SECTION "analyzed_010644", ROMX[$4644], BANK[$04]

Data_04_4644:
	db $0a, $54

Data_04_4646:
	db $0a, $54

Data_04_4648:
	db $30, $00, $00

SECTION "analyzed_01064c", ROMX[$464c], BANK[$04]

Data_04_464c:
	db $13, $54

Data_04_464e:
	db $13, $54

Data_04_4650:
	db $30, $00, $00

SECTION "analyzed_010654", ROMX[$4654], BANK[$04]

Data_04_4654:
	db $1c, $54

Data_04_4656:
	db $1c, $54

Data_04_4658:
	db $30, $00, $00

SECTION "analyzed_01065c", ROMX[$465c], BANK[$04]

Data_04_465c:
	db $25, $54

Data_04_465e:
	db $25, $54

Data_04_4660:
	db $30, $00, $00

SECTION "analyzed_010664", ROMX[$4664], BANK[$04]

Data_04_4664:
	db $2e, $54

Data_04_4666:
	db $2e, $54

Data_04_4668:
	db $30, $00, $00

SECTION "analyzed_01066c", ROMX[$466c], BANK[$04]

Data_04_466c:
	db $37, $54

Data_04_466e:
	db $37, $54

Data_04_4670:
	db $30, $00, $00

SECTION "analyzed_010674", ROMX[$4674], BANK[$04]

Data_04_4674:
	db $40, $54

Data_04_4676:
	db $40, $54

Data_04_4678:
	db $30, $00, $00

SECTION "analyzed_01067c", ROMX[$467c], BANK[$04]

Data_04_467c:
	db $49, $54

Data_04_467e:
	db $49, $54

Data_04_4680:
	db $30, $00, $00

SECTION "analyzed_010684", ROMX[$4684], BANK[$04]

Data_04_4684:
	db $52, $54

Data_04_4686:
	db $52, $54

Data_04_4688:
	db $30, $00, $00

SECTION "analyzed_01068c", ROMX[$468c], BANK[$04]

Data_04_468c:
	db $5b, $54

Data_04_468e:
	db $5b, $54

Data_04_4690:
	db $30, $00, $00

SECTION "analyzed_010694", ROMX[$4694], BANK[$04]

Data_04_4694:
	db $64, $54

Data_04_4696:
	db $64, $54

Data_04_4698:
	db $30, $00, $00

SECTION "analyzed_01069c", ROMX[$469c], BANK[$04]

Data_04_469c:
	db $6d, $54

Data_04_469e:
	db $6d, $54

Data_04_46a0:
	db $30, $00, $00

SECTION "analyzed_0106a4", ROMX[$46a4], BANK[$04]

Data_04_46a4:
	db $76, $54

Data_04_46a6:
	db $76, $54

Data_04_46a8:
	db $30, $00, $00

SECTION "analyzed_0106ac", ROMX[$46ac], BANK[$04]

Data_04_46ac:
	db $7f, $54

Data_04_46ae:
	db $7f, $54

Data_04_46b0:
	db $30, $00, $00

SECTION "analyzed_0106b4", ROMX[$46b4], BANK[$04]

Data_04_46b4:
	db $63, $53

Data_04_46b6:
	db $63, $53

Data_04_46b8:
	db $00, $00, $00

SECTION "analyzed_0106bc", ROMX[$46bc], BANK[$04]

Data_04_46bc:
	db $68, $53

Data_04_46be:
	db $68, $53

Data_04_46c0:
	db $00, $00, $00

SECTION "analyzed_0106c4", ROMX[$46c4], BANK[$04]

Data_04_46c4:
	db $71, $53

Data_04_46c6:
	db $71, $53

Data_04_46c8:
	db $00, $00, $00

SECTION "analyzed_0106cc", ROMX[$46cc], BANK[$04]

Data_04_46cc:
	db $7a, $53

Data_04_46ce:
	db $7a, $53

Data_04_46d0:
	db $00, $00, $00

SECTION "analyzed_0106d4", ROMX[$46d4], BANK[$04]

Data_04_46d4:
	db $83, $53

Data_04_46d6:
	db $83, $53

Data_04_46d8:
	db $00, $00, $00

SECTION "analyzed_0106dc", ROMX[$46dc], BANK[$04]

Data_04_46dc:
	db $2a, $55, $96, $55, $00, $42, $03

SECTION "analyzed_0106e4", ROMX[$46e4], BANK[$04]

Data_04_46e4:
	db $33, $55, $9f, $55, $00, $42, $03

Data_04_46eb:
	db $00, $3c, $55, $a8, $55, $00, $42, $03, $00

Data_04_46f4:
	db $02, $56, $6e, $56, $00, $00, $01

SECTION "analyzed_0106fc", ROMX[$46fc], BANK[$04]

Data_04_46fc:
	db $0b, $56, $77, $56, $00, $00, $01

SECTION "analyzed_010704", ROMX[$4704], BANK[$04]

Data_04_4704:
	db $14, $56, $80, $56, $00, $00, $01

Data_04_470b:
	db $00, $02, $56, $6e, $56, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00
	db $00

Data_04_471c:
	db $da, $56, $46, $57, $00, $34, $03

SECTION "analyzed_010724", ROMX[$4724], BANK[$04]

Data_04_4724:
	db $e3, $56, $4f, $57, $00, $34, $03

Data_04_472b:
	db $00, $ec, $56, $58, $57, $00, $34, $03, $00, $f5, $56, $61, $57, $00, $34, $03
	db $00

Data_04_473c:
	db $91, $5d, $91, $5d, $36, $36, $00

SECTION "analyzed_010744", ROMX[$4744], BANK[$04]

Data_04_4744:
	db $9a, $5d, $9a, $5d, $36, $36, $00

SECTION "analyzed_01074c", ROMX[$474c], BANK[$04]

Data_04_474c:
	db $a3, $5d, $a3, $5d, $36, $00, $00

SECTION "analyzed_010754", ROMX[$4754], BANK[$04]

Data_04_4754:
	db $ac, $5d, $ac, $5d, $36, $00, $00

SECTION "analyzed_01075c", ROMX[$475c], BANK[$04]

Data_04_475c:
	db $cc, $5f

Data_04_475e:
	db $cc, $5f

Data_04_4760:
	db $37, $37, $00

SECTION "analyzed_010764", ROMX[$4764], BANK[$04]

Data_04_4764:
	db $d5, $5f

Data_04_4766:
	db $d5, $5f

Data_04_4768:
	db $37, $00, $00

SECTION "analyzed_01076c", ROMX[$476c], BANK[$04]

Data_04_476c:
	db $de, $5f

Data_04_476e:
	db $de, $5f

Data_04_4770:
	db $37, $00, $00

SECTION "analyzed_010774", ROMX[$4774], BANK[$04]

Data_04_4774:
	db $9f, $5f

Data_04_4776:
	db $9f, $5f

Data_04_4778:
	db $38, $38, $00

SECTION "analyzed_01077c", ROMX[$477c], BANK[$04]

Data_04_477c:
	db $8d, $60

Data_04_477e:
	db $8d, $60

Data_04_4780:
	db $00, $00, $00

SECTION "analyzed_010784", ROMX[$4784], BANK[$04]

Data_04_4784:
	db $a8, $62

Data_04_4786:
	db $a8, $62

Data_04_4788:
	db $00, $00, $00

SECTION "analyzed_01078c", ROMX[$478c], BANK[$04]

Data_04_478c:
	db $d9, $62

Data_04_478e:
	db $d9, $62

Data_04_4790:
	db $00, $00, $00

SECTION "analyzed_010794", ROMX[$4794], BANK[$04]

Data_04_4794:
	db $0a, $63, $13, $63, $39, $39, $00

SECTION "analyzed_01079c", ROMX[$479c], BANK[$04]

Data_04_479c:
	db $1c, $63, $25, $63, $39, $39, $00

SECTION "analyzed_0107a4", ROMX[$47a4], BANK[$04]

Data_04_47a4:
	db $2e, $63, $37, $63, $39, $39, $00

SECTION "analyzed_0107bc", ROMX[$47bc], BANK[$04]

Data_04_47bc:
	db $d9, $54

Data_04_47be:
	db $d9, $54

Data_04_47c0:
	db $00, $00, $00

SECTION "analyzed_0107c4", ROMX[$47c4], BANK[$04]

Data_04_47c4:
	db $7d, $5d

Data_04_47c6:
	db $7d, $5d

Data_04_47c8:
	db $06, $06, $00

SECTION "analyzed_0107cc", ROMX[$47cc], BANK[$04]

Data_04_47cc:
	db $82, $5d

Data_04_47ce:
	db $82, $5d

Data_04_47d0:
	db $00, $00, $00

SECTION "analyzed_0107d4", ROMX[$47d4], BANK[$04]

Data_04_47d4:
	db $87, $5d

Data_04_47d6:
	db $87, $5d

Data_04_47d8:
	db $00, $00, $00

SECTION "analyzed_0107dc", ROMX[$47dc], BANK[$04]

Data_04_47dc:
	db $8c, $5d

Data_04_47de:
	db $8c, $5d

Data_04_47e0:
	db $00, $00, $00

SECTION "analyzed_0107e4", ROMX[$47e4], BANK[$04]

Data_04_47e4:
	db $a8, $5f

Data_04_47e6:
	db $a8, $5f

Data_04_47e8:
	db $00, $00, $00

SECTION "analyzed_0107ec", ROMX[$47ec], BANK[$04]

Data_04_47ec:
	db $b1, $5f

Data_04_47ee:
	db $b1, $5f

Data_04_47f0:
	db $00, $00, $00

SECTION "analyzed_0107f4", ROMX[$47f4], BANK[$04]

Data_04_47f4:
	db $ba, $5f

Data_04_47f6:
	db $ba, $5f

Data_04_47f8:
	db $00, $00, $00

SECTION "analyzed_0107fc", ROMX[$47fc], BANK[$04]

Data_04_47fc:
	db $c3, $5f

Data_04_47fe:
	db $c3, $5f

Data_04_4800:
	db $00, $00, $00

SECTION "analyzed_010804", ROMX[$4804], BANK[$04]

Data_04_4804:
	db $6a, $5a, $6a, $5a, $00, $35, $00

SECTION "analyzed_01080c", ROMX[$480c], BANK[$04]

Data_04_480c:
	db $6f, $5a, $6f, $5a, $00, $00, $00

SECTION "analyzed_010814", ROMX[$4814], BANK[$04]

Data_04_4814:
	db $78, $5a, $78, $5a, $00, $00, $00

SECTION "analyzed_01081c", ROMX[$481c], BANK[$04]

Data_04_481c:
	db $81, $5a, $81, $5a, $00, $00, $00

Data_04_4823:
	db $00, $ba, $4c

Data_04_4826:
	db $a0, $48, $a8, $48, $bc, $48, $cf, $48, $dc, $48, $e9, $48, $eb, $48, $59, $49
	db $f6, $48, $2c, $49, $61, $49, $12, $49, $33, $4b, $3d, $4b, $03, $49, $71, $49
	db $f4, $49, $f6, $49, $fe, $49, $00, $4a

Data_04_484e:
	db $08, $4a

Data_04_4850:
	db $0a, $4a

Data_04_4852:
	db $12, $4a

Data_04_4854:
	db $14, $4a, $bf, $49, $1c, $4a, $1e, $4a, $26, $4a, $28, $4a

Data_04_4860:
	db $30, $4a

Data_04_4862:
	db $32, $4a

Data_04_4864:
	db $3a, $4a

Data_04_4866:
	db $3c, $4a, $78, $4b, $80, $4b, $97, $4b

Data_04_486e:
	db $ba, $4c, $ba, $4c, $ba, $4c

Data_04_4874:
	db $d0, $4b, $ae, $4b, $b6, $4b, $be, $4b, $5d, $4b, $65, $4b, $45, $4b, $52, $4b
	db $44, $4a, $51, $4a

Data_04_4888:
	db $7a, $4a

Data_04_488a:
	db $a8, $4a, $b8, $4a, $c8, $4a

Data_04_4890:
	db $f1, $4a

Data_04_4892:
	db $f9, $4a, $70, $4b

SECTION "analyzed_010898", ROMX[$4898], BANK[$04]

Data_04_4898:
	db $19, $4b

Data_04_489a:
	db $26, $4b

Data_04_489c:
	db $01, $4b, $09, $4b, $04, $02, $01, $00, $02, $03, $03, $00, $05, $04, $01, $01
	db $01, $02, $03, $03, $01, $02, $02, $03, $03, $01, $03, $02, $03, $03, $06, $00
	db $04, $03, $05, $01, $01, $02, $03, $03, $01, $02, $02, $03, $03, $01, $00, $02
	db $03, $03, $00, $04, $04, $01, $04, $02, $03, $03, $01, $06, $02, $03, $03, $00
	db $04, $04, $01, $04, $02, $03, $03, $01, $05, $02, $03, $03, $00, $04, $04, $01
	db $07, $02, $03, $03, $01, $08, $02, $03, $03, $00, $01, $01, $02, $05, $03, $01
	db $02, $02, $05, $03, $10, $f6, $48, $04, $1b, $01, $01, $02, $05, $03, $01, $02
	db $02, $05, $03, $10, $05, $49, $01, $38, $02, $03, $03, $01, $39, $02, $03, $03
	db $01, $3a, $02, $03, $03, $01, $3b, $02, $03, $03, $01, $3c, $02, $03, $03

SECTION "analyzed_01092c", ROMX[$492c], BANK[$04]

Data_04_492c:
	db $04, $07, $01, $1f, $02, $03, $03, $01, $20, $02, $03, $03, $01, $21, $02, $03
	db $03, $01, $22, $02, $03, $03, $01, $23, $02, $03, $03, $01, $24, $02, $03, $03
	db $01, $25, $02, $03, $03, $01, $26, $02, $03, $03, $10, $f6, $48, $01, $0d, $02
	db $01, $03, $10, $59, $49, $01, $01, $02, $03, $03, $01, $02, $02, $03, $03, $01
	db $00, $02, $03, $03, $00, $04, $03, $01, $29, $02, $02, $03, $01, $2a, $02, $02
	db $03, $01, $2b, $02, $02, $03, $01, $2c, $02, $02, $03, $01, $2d, $02, $02, $03
	db $01, $2e, $02, $02, $03, $01, $2f, $02, $02, $03, $01, $30, $02, $02, $03, $01
	db $31, $02, $02, $03, $01, $32, $02, $02, $03, $01, $33, $02, $02, $03, $01, $34
	db $02, $02, $03, $01, $35, $02, $02, $03, $01, $36, $02, $02, $03, $01, $37, $02
	db $02, $03, $00, $04, $03, $01, $2e, $02, $02, $03, $01, $2f, $02, $02, $03, $01
	db $30, $02, $02, $03, $01, $31, $02, $02, $03, $01, $32, $02, $02, $03, $01, $33
	db $02, $02, $03, $01, $34, $02, $02, $03, $01, $35, $02, $02, $03, $01, $36, $02
	db $02, $03, $01, $37, $02, $02, $03, $00, $04, $0e, $01, $09, $02, $01, $03, $10
	db $f6, $49, $04, $0e, $01, $0a, $02, $01, $03, $10, $00, $4a

Data_04_4a08:
	db $04, $0e

Data_04_4a0a:
	db $01, $0b, $02, $01, $03, $10, $0a, $4a

Data_04_4a12:
	db $04, $0e

Data_04_4a14:
	db $01, $0c, $02, $01, $03, $10, $14, $4a, $04, $0e, $01, $0e, $02, $01, $03, $10
	db $1e, $4a, $04, $0e, $01, $0f, $02, $01, $03, $10, $28, $4a

Data_04_4a30:
	db $04, $0e

Data_04_4a32:
	db $01, $10, $02, $01, $03, $10, $32, $4a

Data_04_4a3a:
	db $04, $0e

Data_04_4a3c:
	db $01, $11, $02, $01, $03, $10, $3c, $4a, $01, $12, $02, $05, $03, $01, $13, $02
	db $05, $03, $10, $44, $4a, $01, $14, $02, $05, $03, $01, $15, $02, $05, $03, $01
	db $16, $02, $05, $03, $01, $15, $02, $05, $03, $01, $14, $02, $05, $03, $01, $15
	db $02, $05, $03, $01, $16, $02, $05, $03, $01, $15, $02, $05, $03

Data_04_4a79:
	db $00, $01, $17, $02, $07, $03, $01, $18, $02, $07, $03, $01, $19, $02, $07, $03
	db $01, $17, $02, $04, $03, $01, $18, $02, $04, $03, $01, $19, $02, $04, $03, $01
	db $1a, $02, $03, $03, $01, $18, $02, $03, $03, $01, $17, $02, $03, $03, $00

Data_04_4aa8:
	db $01, $1b, $02, $03, $03, $01, $1c, $02, $03, $03, $01, $1d, $02, $03, $03

SECTION "analyzed_010ab8", ROMX[$4ab8], BANK[$04]

Data_04_4ab8:
	db $01, $3d, $02, $03, $03, $01, $3e, $02, $03, $03

Data_04_4ac2:
	db $01, $3f, $02, $03, $03, $00

Data_04_4ac8:
	db $01, $40, $02, $03, $03, $01, $41, $02, $03, $03, $01, $42, $02, $03, $03, $01
	db $41, $02, $03, $03, $01, $42, $02, $03, $03, $01, $41, $02, $03, $03

Data_04_4ae6:
	db $01, $42, $02, $03, $03, $01, $40, $02, $03, $03, $00, $01, $43, $02, $02, $03
	db $10, $f1, $4a

Data_04_4af9:
	db $01, $1e, $02, $02, $03, $10, $f9, $4a, $01, $62, $02, $02, $03, $10, $01, $4b
	db $01, $63, $02, $07, $03, $01, $64, $02, $07, $03, $01, $65, $02, $07, $03

SECTION "analyzed_010b19", ROMX[$4b19], BANK[$04]

Data_04_4b19:
	db $01, $45, $02, $03, $03, $01, $46, $02, $03, $03, $10, $19, $4b

Data_04_4b26:
	db $01, $47, $02, $03, $03, $01, $48, $02, $03, $03, $10, $26, $4b

Data_04_4b33:
	db $04, $12, $01, $27, $02, $03, $03, $10, $35, $4b, $01, $28, $02, $03, $03, $10
	db $3d, $4b, $01, $49, $02, $05, $03, $01, $4a, $02, $05, $03, $10, $45, $4b, $01
	db $4b, $02, $05, $03, $01, $4c, $02, $05, $03

SECTION "analyzed_010b5d", ROMX[$4b5d], BANK[$04]

Data_04_4b5d:
	db $01, $4d, $02, $05, $03, $10, $5d, $4b, $01, $4e, $02, $05, $03, $01, $4f, $02
	db $05, $03

SECTION "analyzed_010b70", ROMX[$4b70], BANK[$04]

Data_04_4b70:
	db $01, $50, $02, $03, $03, $10, $70, $4b, $01, $5a, $02, $03, $03, $10, $78, $4b
	db $01, $5b, $02, $04, $03, $01, $5c, $02, $04, $03, $01, $5b, $02, $04, $03, $01
	db $5d, $02, $04, $03, $10, $80, $4b, $01, $5e, $02, $03, $03, $01, $5f, $02, $03
	db $03, $01, $60, $02, $03, $03, $01, $61, $02, $03, $03, $10, $97, $4b, $01, $59
	db $02, $3c, $03, $10, $ae, $4b, $01, $53, $02, $3c, $03, $10, $b6, $4b, $01, $53
	db $02, $0a, $03, $01, $52, $02, $0a, $03, $01, $51, $02, $28, $03, $10, $c8, $4b
	db $01, $54, $02, $02, $03, $01, $55, $02, $02, $03, $01, $56, $02, $02, $03, $01
	db $55, $02, $02, $03, $01, $54, $02, $02, $03

Data_04_4be9:
	db $00, $41, $51, $4a, $51

Data_04_4bee:
	db $01, $02

SECTION "analyzed_010bf2", ROMX[$4bf2], BANK[$04]

Data_04_4bf2:
	db $41, $51, $4a, $51, $01, $02, $00

SECTION "analyzed_010bfa", ROMX[$4bfa], BANK[$04]

Data_04_4bfa:
	db $53, $51, $5c, $51, $01, $03, $00

SECTION "analyzed_010c02", ROMX[$4c02], BANK[$04]

Data_04_4c02:
	db $65, $51, $6e, $51, $01, $02, $00

SECTION "analyzed_010c0a", ROMX[$4c0a], BANK[$04]

Data_04_4c0a:
	db $77, $51, $80, $51, $01, $02, $00

SECTION "analyzed_010c12", ROMX[$4c12], BANK[$04]

Data_04_4c12:
	db $89, $51, $92, $51, $01, $02, $00

SECTION "analyzed_010c1a", ROMX[$4c1a], BANK[$04]

Data_04_4c1a:
	db $9b, $51, $a4, $51, $01, $02, $00

SECTION "analyzed_010c22", ROMX[$4c22], BANK[$04]

Data_04_4c22:
	db $ad, $51, $b6, $51, $01, $03, $00

SECTION "analyzed_010c2a", ROMX[$4c2a], BANK[$04]

Data_04_4c2a:
	db $bf, $51, $c8, $51, $01, $03, $00

SECTION "analyzed_010c32", ROMX[$4c32], BANK[$04]

Data_04_4c32:
	db $d1, $51, $da, $51, $01, $02, $00

SECTION "analyzed_010c3a", ROMX[$4c3a], BANK[$04]

Data_04_4c3a:
	db $e3, $51, $ec, $51, $01, $02, $00

SECTION "analyzed_010c42", ROMX[$4c42], BANK[$04]

Data_04_4c42:
	db $f5, $51, $fe, $51, $01, $02, $00

SECTION "analyzed_010c4a", ROMX[$4c4a], BANK[$04]

Data_04_4c4a:
	db $07, $52, $10, $52, $01, $03, $00

SECTION "analyzed_010c52", ROMX[$4c52], BANK[$04]

Data_04_4c52:
	db $19, $52, $22, $52, $01, $03, $00

SECTION "analyzed_010c5a", ROMX[$4c5a], BANK[$04]

Data_04_4c5a:
	db $2b, $52, $34, $52, $01, $03, $00

SECTION "analyzed_010c62", ROMX[$4c62], BANK[$04]

Data_04_4c62:
	db $3d, $52, $46, $52, $01, $02, $00

SECTION "analyzed_010c6a", ROMX[$4c6a], BANK[$04]

Data_04_4c6a:
	db $4f, $52, $58, $52, $01, $02, $00

SECTION "analyzed_010c72", ROMX[$4c72], BANK[$04]

Data_04_4c72:
	db $61, $52, $6a, $52, $01, $03, $00

SECTION "analyzed_010c7a", ROMX[$4c7a], BANK[$04]

Data_04_4c7a:
	db $73, $52, $7c, $52, $01, $03, $00

SECTION "analyzed_010c82", ROMX[$4c82], BANK[$04]

Data_04_4c82:
	db $85, $52, $8e, $52, $01, $00, $00

SECTION "analyzed_010c8a", ROMX[$4c8a], BANK[$04]

Data_04_4c8a:
	db $97, $52, $97, $52, $01, $00, $00

SECTION "analyzed_010c92", ROMX[$4c92], BANK[$04]

Data_04_4c92:
	db $a0, $52, $a0, $52, $01, $00, $00

SECTION "analyzed_010c9a", ROMX[$4c9a], BANK[$04]

Data_04_4c9a:
	db $a9, $52, $b2, $52, $01, $00, $00

SECTION "analyzed_010ca2", ROMX[$4ca2], BANK[$04]

Data_04_4ca2:
	db $bb, $52, $c4, $52, $01, $00, $00

Data_04_4ca9:
	db $00, $cd, $52, $d6, $52, $01, $02, $00, $00, $df, $52, $e8, $52, $01, $02, $00
	db $00, $00, $ba, $4c

Data_04_4cbd:
	db $e1, $4c, $e9, $4c, $f1, $4c, $08, $4d, $1f, $4d, $2c, $4d, $39, $4d, $4b, $4d
	db $5d, $4d, $65, $4d, $6d, $4d, $75, $4d

Data_04_4cd5:
	db $ba, $4c, $ba, $4c, $ba, $4c

Data_04_4cdb:
	db $7d, $4d, $ae, $4d, $b8, $4d, $01, $01, $02, $01, $03, $10, $e1, $4c, $01, $02
	db $02, $01, $03, $10, $e9, $4c, $01, $03, $02, $03, $03, $01, $04, $02, $03, $03
	db $01, $05, $02, $03, $03, $01, $06, $02, $03, $03, $10, $f1, $4c, $01, $02, $02
	db $0a, $03, $01, $07, $02, $0a, $03, $01, $02, $02, $0a, $03, $01, $08, $02, $0a
	db $03, $10, $08, $4d, $01, $0f, $02, $07, $03, $01, $10, $02, $07, $03

Data_04_4d29:
	db $10, $e1, $4c

Data_04_4d2c:
	db $01, $11, $02, $07, $03, $01, $12, $02, $07, $03

Data_04_4d36:
	db $10, $e9, $4c

Data_04_4d39:
	db $01, $09, $02, $05, $03, $01, $0a, $02, $05, $03, $01, $0b, $02, $0a, $03, $10
	db $e1, $4c, $01, $0c, $02, $05, $03, $01, $0d, $02, $05, $03, $01, $0e, $02, $0a
	db $03, $10, $e9, $4c, $01, $07, $02, $07, $03

Data_04_4d62:
	db $10, $5d, $4d

Data_04_4d65:
	db $01, $01, $02, $01, $03, $10, $65, $4d, $01, $04, $02, $01, $03, $10, $6d, $4d
	db $01, $07, $02, $05, $03

Data_04_4d7a:
	db $10, $5d, $4d

Data_04_4d7d:
	db $04, $0c, $01, $13, $02, $06, $03, $01, $14, $02, $06, $03, $07, $02, $01, $13
	db $02, $06, $03, $07, $02, $01, $15, $02, $06, $03, $01, $16, $02, $06, $03, $01
	db $17, $02, $06, $03, $01, $16, $02, $06, $03, $01, $17, $02, $06, $03, $10, $a6
	db $4d, $04, $0c, $01, $16, $02, $01, $03, $10, $b0, $4d, $01, $16, $02, $06, $03
	db $01, $17, $02, $06, $03, $01, $16, $02, $06, $03, $01, $17, $02, $06, $03, $10
	db $c7, $4d, $f1, $52, $fa, $52, $08, $09, $00

SECTION "analyzed_010dd7", ROMX[$4dd7], BANK[$04]

Data_04_4dd7:
	db $03, $53, $0c, $53, $08, $09, $00

SECTION "analyzed_010ddf", ROMX[$4ddf], BANK[$04]

Data_04_4ddf:
	db $15, $53

Data_04_4de1:
	db $15, $53

Data_04_4de3:
	db $00, $00, $00

SECTION "analyzed_010de7", ROMX[$4de7], BANK[$04]

Data_04_4de7:
	db $1e, $53

Data_04_4de9:
	db $1e, $53

Data_04_4deb:
	db $00, $00, $00

Data_04_4dee:
	db $00, $ba, $4c

Data_04_4df1:
	db $f5, $4d, $20, $4e, $01, $02, $02, $05, $03, $01, $03, $02, $05, $03, $01, $02
	db $02, $05, $03, $01, $03, $02, $05, $03, $01, $02, $02, $05, $03, $01, $03, $02
	db $05, $03, $01, $02, $02, $05, $03, $01, $03, $02, $05, $03

Data_04_4e1d:
	db $10, $f5, $4d

Data_04_4e20:
	db $01, $00, $02, $05, $03, $01, $01, $02, $05, $03, $10, $20, $4e

Data_04_4e2d:
	db $ba, $55, $26, $56

Data_04_4e31:
	db $00, $00

SECTION "analyzed_010e35", ROMX[$4e35], BANK[$04]

Data_04_4e35:
	db $ba, $4c

Data_04_4e37:
	db $3b, $4e, $43, $4e, $01, $00, $02, $01, $03, $10, $3b, $4e, $01, $00, $02, $01
	db $03, $10, $3b, $4e

Data_04_4e4b:
	db $e2, $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_010e53", ROMX[$4e53], BANK[$04]

Data_04_4e53:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_010e5b", ROMX[$4e5b], BANK[$04]

Data_04_4e5b:
	db $f4, $54, $60, $55, $0c, $0d, $00

SECTION "analyzed_010e63", ROMX[$4e63], BANK[$04]

Data_04_4e63:
	db $fd, $54, $69, $55, $0c, $0d, $00

SECTION "analyzed_010e6b", ROMX[$4e6b], BANK[$04]

Data_04_4e6b:
	db $06, $55, $72, $55, $0c, $0d, $00

SECTION "analyzed_010e73", ROMX[$4e73], BANK[$04]

Data_04_4e73:
	db $0f, $55, $7b, $55, $0c, $00, $00

SECTION "analyzed_010e7b", ROMX[$4e7b], BANK[$04]

Data_04_4e7b:
	db $18, $55, $84, $55, $0c, $00, $00

SECTION "analyzed_010e83", ROMX[$4e83], BANK[$04]

Data_04_4e83:
	db $ba, $4c

Data_04_4e85:
	db $97, $4e

Data_04_4e87:
	db $9f, $4e

Data_04_4e89:
	db $ba, $4c

Data_04_4e8b:
	db $b1, $4e

Data_04_4e8d:
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_4e95:
	db $be, $4e

Data_04_4e97:
	db $01, $00, $02, $01, $03, $10, $97, $4e

Data_04_4e9f:
	db $01, $00, $02, $05, $03, $01, $01, $02, $05, $03, $01, $02, $02, $05, $03, $10
	db $9f, $4e, $01, $03, $02, $02, $03, $01, $04, $02, $02, $03, $10, $b1, $4e, $01
	db $05, $02, $03, $03, $01, $06, $02, $03, $03, $01, $05, $02, $03, $03, $01, $06
	db $02, $03, $03, $09, $01, $06, $02, $02, $03, $08, $02, $02, $03, $10, $d2, $4e
	db $e2, $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_010ee7", ROMX[$4ee7], BANK[$04]

Data_04_4ee7:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_010eef", ROMX[$4eef], BANK[$04]

Data_04_4eef:
	db $f4, $54, $60, $55, $0c, $0d, $00

SECTION "analyzed_010ef7", ROMX[$4ef7], BANK[$04]

Data_04_4ef7:
	db $fd, $54, $69, $55, $0c, $0d, $00

SECTION "analyzed_010eff", ROMX[$4eff], BANK[$04]

Data_04_4eff:
	db $06, $55, $72, $55, $0c, $0d, $00

SECTION "analyzed_010f07", ROMX[$4f07], BANK[$04]

Data_04_4f07:
	db $0f, $55, $7b, $55, $0c, $0d, $00

SECTION "analyzed_010f0f", ROMX[$4f0f], BANK[$04]

Data_04_4f0f:
	db $18, $55, $84, $55, $0c, $0d, $00

SECTION "analyzed_010f17", ROMX[$4f17], BANK[$04]

Data_04_4f17:
	db $21, $55, $8d, $55, $0c, $00, $00

SECTION "analyzed_010f1f", ROMX[$4f1f], BANK[$04]

Data_04_4f1f:
	db $ba, $4c, $33, $4f, $3b, $4f, $48, $4f, $5a, $4f

Data_04_4f29:
	db $67, $4f, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_4f31:
	db $74, $4f, $01, $00, $02, $01, $03, $10, $33, $4f, $01, $00, $02, $05, $03, $01
	db $01, $02, $05, $03, $10, $3b, $4f, $01, $02, $02, $1e, $03, $01, $03, $02, $05
	db $03, $01, $04, $02, $05, $03

Data_04_4f57:
	db $10, $52, $4f

Data_04_4f5a:
	db $01, $05, $02, $02, $03, $01, $06, $02, $02, $03, $10, $5a, $4f

Data_04_4f67:
	db $01, $00, $02, $03, $03, $01, $01, $02, $03, $03, $10, $67, $4f

Data_04_4f74:
	db $01, $07, $02, $04, $03, $09, $01, $07, $02, $02, $03, $08, $02, $02, $03, $10
	db $79, $4f, $e2, $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_010f8e", ROMX[$4f8e], BANK[$04]

Data_04_4f8e:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_010f96", ROMX[$4f96], BANK[$04]

Data_04_4f96:
	db $f4, $54, $60, $55, $0c, $0d, $00

SECTION "analyzed_010f9e", ROMX[$4f9e], BANK[$04]

Data_04_4f9e:
	db $fd, $54, $69, $55, $0c, $0d, $00

SECTION "analyzed_010fa6", ROMX[$4fa6], BANK[$04]

Data_04_4fa6:
	db $06, $55, $72, $55, $0c, $0d, $00

SECTION "analyzed_010fae", ROMX[$4fae], BANK[$04]

Data_04_4fae:
	db $0f, $55, $7b, $55, $0c, $0d, $00

SECTION "analyzed_010fb6", ROMX[$4fb6], BANK[$04]

Data_04_4fb6:
	db $18, $55, $84, $55, $0c, $0d, $00

SECTION "analyzed_010fbe", ROMX[$4fbe], BANK[$04]

Data_04_4fbe:
	db $21, $55, $8d, $55, $0c, $00, $00

SECTION "analyzed_010fc6", ROMX[$4fc6], BANK[$04]

Data_04_4fc6:
	db $ba, $4c, $da, $4f, $e2, $4f, $f9, $4f, $06, $50

Data_04_4fd0:
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_4fd8:
	db $13, $50, $01, $00, $02, $01, $03, $10, $da, $4f, $01, $00, $02, $03, $03, $01
	db $01, $02, $03, $03, $01, $02, $02, $03, $03, $01, $01, $02, $03, $03, $10, $e2
	db $4f, $01, $03, $02, $1e, $03, $01, $04, $02, $09, $03

Data_04_5003:
	db $10, $fe, $4f

Data_04_5006:
	db $01, $05, $02, $02, $03, $01, $06, $02, $02, $03, $10, $06, $50, $01, $07, $02
	db $04, $03, $09, $01, $07, $02, $02, $03, $08, $02, $02, $03, $10, $18, $50, $e2
	db $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_01102d", ROMX[$502d], BANK[$04]

Data_04_502d:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_011035", ROMX[$5035], BANK[$04]

Data_04_5035:
	db $f4, $54, $60, $55, $0c, $0d, $00

SECTION "analyzed_01103d", ROMX[$503d], BANK[$04]

Data_04_503d:
	db $fd, $54, $69, $55, $0c, $0d, $00

SECTION "analyzed_011045", ROMX[$5045], BANK[$04]

Data_04_5045:
	db $06, $55, $72, $55, $0c, $0d, $00

SECTION "analyzed_01104d", ROMX[$504d], BANK[$04]

Data_04_504d:
	db $0f, $55, $7b, $55, $0c, $0d, $00

SECTION "analyzed_011055", ROMX[$5055], BANK[$04]

Data_04_5055:
	db $18, $55, $84, $55, $0c, $0d, $00

SECTION "analyzed_01105d", ROMX[$505d], BANK[$04]

Data_04_505d:
	db $21, $55, $8d, $55, $0c, $00, $00

Data_04_5064:
	db $00, $ba, $4c

Data_04_5067:
	db $79, $50, $81, $50, $98, $50, $ac, $50

Data_04_506f:
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_5077:
	db $b9, $50, $01, $00, $02, $01, $03, $10, $79, $50, $01, $00, $02, $05, $03, $01
	db $01, $02, $05, $03, $01, $02, $02, $05, $03, $01, $01, $02, $05, $03, $10, $81
	db $50, $01, $03, $02, $1e, $03, $04, $0f, $01, $04, $02, $28, $03, $01, $03, $02
	db $05, $03

Data_04_50a9:
	db $10, $79, $50

Data_04_50ac:
	db $01, $05, $02, $03, $03, $01, $06, $02, $03, $03, $10, $ac, $50, $01, $07, $02
	db $04, $03, $09, $01, $07, $02, $02, $03, $08, $02, $02, $03, $10, $be, $50, $e2
	db $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_0110d3", ROMX[$50d3], BANK[$04]

Data_04_50d3:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_0110db", ROMX[$50db], BANK[$04]

Data_04_50db:
	db $f4, $54, $60, $55, $0c, $0d, $00

SECTION "analyzed_0110e3", ROMX[$50e3], BANK[$04]

Data_04_50e3:
	db $fd, $54, $69, $55, $0c, $0d, $00

SECTION "analyzed_0110eb", ROMX[$50eb], BANK[$04]

Data_04_50eb:
	db $06, $55, $72, $55, $0c, $0d, $00

SECTION "analyzed_0110f3", ROMX[$50f3], BANK[$04]

Data_04_50f3:
	db $0f, $55, $7b, $55, $0c, $0d, $00

SECTION "analyzed_0110fb", ROMX[$50fb], BANK[$04]

Data_04_50fb:
	db $18, $55, $84, $55, $0c, $00, $00

SECTION "analyzed_011103", ROMX[$5103], BANK[$04]

Data_04_5103:
	db $21, $55, $8d, $55, $0c, $00, $00

Data_04_510a:
	db $00, $ba, $4c

Data_04_510d:
	db $1f, $51, $27, $51, $34, $51, $41, $51

Data_04_5115:
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_511d:
	db $4e, $51, $01, $00, $02, $01, $03, $10, $1f, $51, $01, $00, $02, $03, $03, $01
	db $01, $02, $03, $03, $10, $27, $51, $01, $02, $02, $3c, $03, $01, $03, $02, $05
	db $03

Data_04_513e:
	db $10, $1f, $51

Data_04_5141:
	db $01, $04, $02, $02, $03, $01, $05, $02, $02, $03, $10, $41, $51, $01, $06, $02
	db $03, $03, $01, $07, $02, $03, $03, $09, $01, $07, $02, $02, $03, $08, $02, $02
	db $03, $10, $58, $51, $ba, $55, $26, $56, $0e, $0f, $00

SECTION "analyzed_01116d", ROMX[$516d], BANK[$04]

Data_04_516d:
	db $c3, $55, $2f, $56, $0e, $0f, $00

Data_04_5174:
	db $00, $cc, $55, $38, $56, $0e, $0f, $00, $00

Data_04_517d:
	db $d5, $55, $41, $56, $0e, $0f, $00

SECTION "analyzed_011185", ROMX[$5185], BANK[$04]

Data_04_5185:
	db $de, $55, $4a, $56, $0e, $0f, $00

SECTION "analyzed_01118d", ROMX[$518d], BANK[$04]

Data_04_518d:
	db $e7, $55, $53, $56, $0e, $00, $00

Data_04_5194:
	db $00, $ba, $4c

Data_04_5197:
	db $a9, $51, $b1, $51

Data_04_519b:
	db $be, $51

Data_04_519d:
	db $cb, $51

Data_04_519f:
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_51a7:
	db $d3, $51, $01, $00, $02, $01, $03, $10, $a9, $51, $01, $00, $02, $05, $03, $01
	db $01, $02, $05, $03, $10, $b1, $51

Data_04_51be:
	db $01, $01, $02, $21, $03, $01, $02, $02, $09, $03, $10, $a9, $51

Data_04_51cb:
	db $01, $03, $02, $01, $03, $10, $cb, $51, $01, $04, $02, $02, $03, $01, $05, $02
	db $02, $03, $09, $01, $05, $02, $02, $03, $08, $02, $02, $03, $10, $dd, $51, $ba
	db $55, $26, $56, $0e, $0f, $00

SECTION "analyzed_0111f2", ROMX[$51f2], BANK[$04]

Data_04_51f2:
	db $c3, $55, $2f, $56, $0e, $0f, $00

SECTION "analyzed_0111fa", ROMX[$51fa], BANK[$04]

Data_04_51fa:
	db $cc, $55, $38, $56, $0e, $0f, $00

SECTION "analyzed_011202", ROMX[$5202], BANK[$04]

Data_04_5202:
	db $d5, $55, $41, $56, $0e, $0f, $00

SECTION "analyzed_01120a", ROMX[$520a], BANK[$04]

Data_04_520a:
	db $de, $55, $4a, $56, $0e, $0f, $00

SECTION "analyzed_011212", ROMX[$5212], BANK[$04]

Data_04_5212:
	db $e7, $55, $53, $56, $0e, $0f, $00

SECTION "analyzed_01121a", ROMX[$521a], BANK[$04]

Data_04_521a:
	db $f0, $55, $5c, $56, $0e, $0f, $00

SECTION "analyzed_011222", ROMX[$5222], BANK[$04]

Data_04_5222:
	db $f9, $55, $65, $56, $0e, $00, $00

Data_04_5229:
	db $00, $ba, $4c

Data_04_522c:
	db $3e, $52, $46, $52, $5d, $52, $6a, $52

Data_04_5234:
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_523c:
	db $77, $52, $01, $00, $02, $01, $03, $10, $3e, $52, $01, $00, $02, $03, $03, $01
	db $01, $02, $03, $03, $01, $02, $02, $03, $03, $01, $01, $02, $03, $03, $10, $46
	db $52, $01, $03, $02, $03, $03, $01, $04, $02, $09, $03

Data_04_5267:
	db $10, $3e, $52

Data_04_526a:
	db $01, $05, $02, $03, $03, $01, $06, $02, $03, $03, $10, $6f, $52, $01, $07, $02
	db $04, $03, $09, $01, $07, $02, $02, $03, $08, $02, $02, $03, $10, $7c, $52, $ba
	db $55, $26, $56, $0e, $0f, $00

SECTION "analyzed_011291", ROMX[$5291], BANK[$04]

Data_04_5291:
	db $c3, $55, $2f, $56, $0e, $0f, $00

SECTION "analyzed_011299", ROMX[$5299], BANK[$04]

Data_04_5299:
	db $cc, $55, $38, $56, $0e, $0f, $00

SECTION "analyzed_0112a1", ROMX[$52a1], BANK[$04]

Data_04_52a1:
	db $d5, $55, $41, $56, $0e, $0f, $00

SECTION "analyzed_0112a9", ROMX[$52a9], BANK[$04]

Data_04_52a9:
	db $de, $55, $4a, $56, $0e, $0f, $00

SECTION "analyzed_0112b1", ROMX[$52b1], BANK[$04]

Data_04_52b1:
	db $e7, $55, $53, $56, $0e, $0f, $00

SECTION "analyzed_0112b9", ROMX[$52b9], BANK[$04]

Data_04_52b9:
	db $f0, $55, $5c, $56, $0e, $00, $00

Data_04_52c0:
	db $00, $ba, $4c

Data_04_52c3:
	db $d5, $52, $dd, $52, $ea, $52, $f7, $52, $04, $53

Data_04_52cd:
	db $ba, $4c, $ba, $4c, $ba, $4c

Data_04_52d3:
	db $11, $53, $01, $00, $02, $01, $03, $10, $d5, $52, $01, $00, $02, $03, $03, $01
	db $01, $02, $03, $03, $10, $dd, $52, $01, $01, $02, $09, $03, $01, $02, $02, $03
	db $03

Data_04_52f4:
	db $10, $ef, $52

Data_04_52f7:
	db $01, $04, $02, $02, $03, $01, $05, $02, $02, $03, $10, $f7, $52, $01, $01, $02
	db $09, $03, $01, $03, $02, $03, $03

Data_04_530e:
	db $10, $09, $53

Data_04_5311:
	db $01, $06, $02, $04, $03, $09, $01, $06, $02, $02, $03, $08, $02, $02, $03, $10
	db $16, $53, $e2, $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_01132b", ROMX[$532b], BANK[$04]

Data_04_532b:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_011333", ROMX[$5333], BANK[$04]

Data_04_5333:
	db $f4, $54, $60, $55, $0c, $0d, $00

SECTION "analyzed_01133b", ROMX[$533b], BANK[$04]

Data_04_533b:
	db $fd, $54, $69, $55, $0c, $0d, $00

SECTION "analyzed_011343", ROMX[$5343], BANK[$04]

Data_04_5343:
	db $06, $55, $72, $55, $0c, $0d, $00

SECTION "analyzed_01134b", ROMX[$534b], BANK[$04]

Data_04_534b:
	db $0f, $55, $7b, $55, $0c, $0d, $00

SECTION "analyzed_011353", ROMX[$5353], BANK[$04]

Data_04_5353:
	db $18, $55, $84, $55, $0c, $0d, $00

SECTION "analyzed_01135b", ROMX[$535b], BANK[$04]

Data_04_535b:
	db $21, $55, $8d, $55, $0c, $00, $00

SECTION "analyzed_011363", ROMX[$5363], BANK[$04]

Data_04_5363:
	db $6a, $57, $7c, $57, $0c, $0d, $00

SECTION "analyzed_01136b", ROMX[$536b], BANK[$04]

Data_04_536b:
	db $73, $57, $85, $57, $0c, $0d, $00

Data_04_5372:
	db $00, $ba, $4c

Data_04_5375:
	db $87, $53, $8f, $53, $a6, $53, $bd, $53, $d4, $53

Data_04_537f:
	db $ba, $4c, $ba, $4c, $ba, $4c

Data_04_5385:
	db $eb, $53, $01, $00, $02, $01, $03, $10, $87, $53, $01, $00, $02, $03, $03, $01
	db $01, $02, $03, $03, $01, $00, $02, $03, $03, $01, $02, $02, $03, $03, $10, $8f
	db $53, $01, $03, $02, $03, $03, $01, $04, $02, $03, $03, $01, $05, $02, $03, $03
	db $01, $06, $02, $03, $03, $10, $b5, $53, $01, $00, $02, $02, $03, $01, $01, $02
	db $02, $03, $01, $00, $02, $02, $03, $01, $02, $02, $02, $03, $10, $bd, $53, $01
	db $06, $02, $02, $03, $01, $07, $02, $02, $03, $01, $08, $02, $02, $03, $01, $09
	db $02, $02, $03, $10, $d4, $53, $01, $07, $02, $03, $03, $09, $01, $07, $02, $02
	db $03, $08, $02, $02, $03, $10, $f0, $53, $8e, $57, $8e, $57, $13, $14, $00

SECTION "analyzed_011405", ROMX[$5405], BANK[$04]

Data_04_5405:
	db $97, $57, $97, $57, $13, $14, $00

SECTION "analyzed_01140d", ROMX[$540d], BANK[$04]

Data_04_540d:
	db $a0, $57, $a0, $57, $13, $14, $00

SECTION "analyzed_011415", ROMX[$5415], BANK[$04]

Data_04_5415:
	db $a9, $57, $a9, $57, $13, $14, $00

SECTION "analyzed_01141d", ROMX[$541d], BANK[$04]

Data_04_541d:
	db $b2, $57, $b2, $57, $13, $14, $00

SECTION "analyzed_011425", ROMX[$5425], BANK[$04]

Data_04_5425:
	db $bb, $57, $bb, $57, $13, $14, $00

SECTION "analyzed_01142d", ROMX[$542d], BANK[$04]

Data_04_542d:
	db $c4, $57, $c4, $57, $13, $14, $00

SECTION "analyzed_011435", ROMX[$5435], BANK[$04]

Data_04_5435:
	db $cd, $57, $cd, $57, $13, $14, $00

Data_04_543c:
	db $00, $cd, $57, $cd, $57, $13, $14, $00, $00, $cd, $57, $cd, $57, $13, $14, $00
	db $00

Data_04_544d:
	db $d6, $57, $d6, $57, $13, $14, $00

SECTION "analyzed_011455", ROMX[$5455], BANK[$04]

Data_04_5455:
	db $df, $57, $df, $57, $13, $14, $00

SECTION "analyzed_01145d", ROMX[$545d], BANK[$04]

Data_04_545d:
	db $e8, $57, $e8, $57, $13, $14, $00

SECTION "analyzed_011465", ROMX[$5465], BANK[$04]

Data_04_5465:
	db $f1, $57, $f1, $57, $13, $14, $00

SECTION "analyzed_01146d", ROMX[$546d], BANK[$04]

Data_04_546d:
	db $fa, $57, $fa, $57, $13, $14, $00

SECTION "analyzed_011475", ROMX[$5475], BANK[$04]

Data_04_5475:
	db $03, $58, $03, $58, $13, $14, $00

SECTION "analyzed_01147d", ROMX[$547d], BANK[$04]

Data_04_547d:
	db $0c, $58, $0c, $58, $13, $14, $00

SECTION "analyzed_011485", ROMX[$5485], BANK[$04]

Data_04_5485:
	db $15, $58, $15, $58, $13, $14, $00

Data_04_548c:
	db $00, $15, $58, $15, $58, $13, $14, $00, $00, $15, $58, $15, $58, $13, $14, $00
	db $00, $ba, $4c

Data_04_549f:
	db $37, $55, $44, $55, $51, $55, $5e, $55, $6b, $55, $78, $55, $85, $55, $92, $55

SECTION "analyzed_0114bf", ROMX[$54bf], BANK[$04]

Data_04_54bf:
	db $cf, $54, $dc, $54, $e9, $54, $f6, $54, $03, $55, $10, $55, $1d, $55, $2a, $55
	db $01, $00, $02, $03, $03, $01, $01, $02, $03, $03, $10, $cf, $54, $01, $0a, $02
	db $03, $03, $01, $0b, $02, $03, $03, $10, $dc, $54, $01, $0e, $02, $03, $03, $01
	db $0f, $02, $03, $03, $10, $e9, $54, $01, $04, $02, $03, $03, $01, $05, $02, $03
	db $03, $10, $f6, $54, $01, $06, $02, $03, $03, $01, $07, $02, $03, $03, $10, $03
	db $55, $01, $0c, $02, $03, $03, $01, $0d, $02, $03, $03, $10, $10, $55, $01, $10
	db $02, $03, $03, $01, $11, $02, $03, $03, $10, $1d, $55, $01, $02, $02, $03, $03
	db $01, $03, $02, $03, $03, $10, $2a, $55, $09, $01, $00, $02, $02, $03, $08, $02
	db $02, $03, $10, $37, $55, $09, $01, $0a, $02, $02, $03, $08, $02, $02, $03, $10
	db $44, $55, $09, $01, $0e, $02, $02, $03, $08, $02, $02, $03, $10, $51, $55, $09
	db $01, $04, $02, $02, $03, $08, $02, $02, $03, $10, $5e, $55, $09, $01, $06, $02
	db $02, $03, $08, $02, $02, $03, $10, $6b, $55, $09, $01, $0c, $02, $02, $03, $08
	db $02, $02, $03, $10, $78, $55, $09, $01, $10, $02, $02, $03, $08, $02, $02, $03
	db $10, $85, $55, $09, $01, $02, $02, $03, $03, $08, $02, $02, $03, $10, $92, $55
	db $92, $56, $fe, $56, $0e, $0f, $00

SECTION "analyzed_0115a7", ROMX[$55a7], BANK[$04]

Data_04_55a7:
	db $9b, $56, $07, $57, $0e, $0f, $00

SECTION "analyzed_0115af", ROMX[$55af], BANK[$04]

Data_04_55af:
	db $a4, $56, $10, $57, $0e, $0f, $00

SECTION "analyzed_0115b7", ROMX[$55b7], BANK[$04]

Data_04_55b7:
	db $ad, $56, $19, $57, $0e, $00, $00

Data_04_55be:
	db $00, $b6, $56

Data_04_55c1:
	db $22, $57, $0e, $0f, $00

Data_04_55c6:
	db $00, $bf, $56, $2b, $57, $0e, $0f, $00, $00, $c8, $56, $34, $57, $0e, $0f, $00
	db $00, $d1, $56

Data_04_55d9:
	db $3d, $57, $0e, $00, $00

Data_04_55de:
	db $00, $ba, $4c

Data_04_55e1:
	db $f3, $55, $fb, $55, $03, $56

Data_04_55e7:
	db $10, $56, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_55ef:
	db $1d, $56, $2f, $56, $01, $00, $02, $03, $03, $10, $f3, $55, $01, $04, $02, $03
	db $03, $10, $fb, $55, $01, $01, $02, $1e, $03, $01, $02, $02, $03, $03

Data_04_560d:
	db $10, $f3, $55, $01, $05, $02, $1e, $03, $01, $06, $02, $03, $03, $10, $fb, $55

Data_04_561d:
	db $01, $03, $02, $03, $03, $09, $01, $03, $02, $02, $03, $08, $02, $02, $03, $10
	db $22, $56, $01, $07, $02, $03, $03, $09, $01, $07, $02, $02, $03, $08, $02, $02
	db $03, $10, $34, $56, $e2, $54, $4e, $55, $10, $11, $00

SECTION "analyzed_011649", ROMX[$5649], BANK[$04]

Data_04_5649:
	db $eb, $54, $57, $55, $10, $11, $00

SECTION "analyzed_011651", ROMX[$5651], BANK[$04]

Data_04_5651:
	db $f4, $54, $60, $55, $10, $12, $00

SECTION "analyzed_011659", ROMX[$5659], BANK[$04]

Data_04_5659:
	db $fd, $54, $69, $55, $10, $12, $00

SECTION "analyzed_011661", ROMX[$5661], BANK[$04]

Data_04_5661:
	db $06, $55, $72, $55, $10, $00, $00

SECTION "analyzed_011669", ROMX[$5669], BANK[$04]

Data_04_5669:
	db $0f, $55, $7b, $55, $10, $00, $00

SECTION "analyzed_011671", ROMX[$5671], BANK[$04]

Data_04_5671:
	db $18, $55, $84, $55, $10, $00, $00

Data_04_5678:
	db $00, $ba, $4c

Data_04_567b:
	db $8d, $56, $a8, $56

Data_04_567f:
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_568b:
	db $c3, $56, $01, $00, $02, $03, $03, $01, $01, $02, $03, $03, $07, $02, $01, $00
	db $02, $03, $03, $01, $01, $02, $03, $03, $07, $02, $10, $8d, $56, $01, $02, $02
	db $03, $03, $01, $03, $02, $03, $03, $07, $02, $01, $02, $02, $03, $03, $01, $03
	db $02, $03, $03, $07, $02, $10, $a8, $56, $09, $01, $04, $02, $03, $03, $01, $05
	db $02, $03, $03, $01, $06, $02, $03, $03, $09, $01, $06, $02, $02, $03, $08, $02
	db $02, $03, $10, $d3, $56, $e2, $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_0116e8", ROMX[$56e8], BANK[$04]

Data_04_56e8:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_0116f0", ROMX[$56f0], BANK[$04]

Data_04_56f0:
	db $f4, $54, $60, $55, $0c, $0d, $00

Data_04_56f7:
	db $00, $fd, $54, $69, $55, $0c, $0d, $00, $00, $06, $55, $72, $55, $0c, $0d, $00
	db $00, $0f, $55, $7b, $55, $0c, $0d, $00, $00, $18, $55, $84, $55, $0c, $0d, $00
	db $00, $21, $55, $8d, $55, $0c, $0d, $00, $00, $ba, $4c

Data_04_5722:
	db $34, $57, $3c, $57

Data_04_5726:
	db $53, $57, $60, $57, $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c, $6d, $57

Data_04_5734:
	db $01, $00, $02, $01, $03, $10, $34, $57, $01, $00, $02, $03, $03, $01, $01, $02
	db $03, $03, $01, $00, $02, $03, $03, $01, $02, $02, $03, $03, $10, $3c, $57

Data_04_5753:
	db $01, $03, $02, $1e, $03, $01, $04, $02, $05, $03, $10, $34, $57, $01, $05, $02
	db $02, $03, $01, $06, $02, $02, $03, $10, $60, $57, $01, $07, $02, $02, $03, $10
	db $6d, $57

Data_04_5775:
	db $e2, $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_01177d", ROMX[$577d], BANK[$04]

Data_04_577d:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_011785", ROMX[$5785], BANK[$04]

Data_04_5785:
	db $f4, $54, $60, $55, $0c, $0d, $00

Data_04_578c:
	db $00, $fd, $54

Data_04_578f:
	db $69, $55, $0c, $0d, $00

Data_04_5794:
	db $00, $06, $55

Data_04_5797:
	db $72, $55, $0c, $0d, $00

Data_04_579c:
	db $00, $0f, $55, $7b, $55, $0c, $0d, $00, $00, $18, $55, $84, $55, $0c, $0d, $00
	db $00, $21, $55, $8d, $55, $0c, $0d, $00, $00, $ba, $4c

Data_04_57b7:
	db $c9, $57, $d1, $57, $e8, $57, $f5, $57

Data_04_57bf:
	db $0c, $58, $ba, $4c, $ba, $4c, $ba, $4c, $1e, $58

Data_04_57c9:
	db $01, $00, $02, $01, $03, $10, $c9, $57, $01, $00, $02, $03, $03, $01, $01, $02
	db $03, $03, $01, $00, $02, $03, $03, $01, $02, $02, $03, $03, $10, $d1, $57, $01
	db $03, $02, $03, $03, $01, $04, $02, $03, $03, $10, $ed, $57, $01, $00, $02, $02
	db $03, $01, $01, $02, $02, $03, $01, $00, $02, $02, $03, $01, $02, $02, $02, $03
	db $10, $f5, $57

Data_04_580c:
	db $01, $04, $02, $02, $03, $01, $05, $02, $02, $03, $01, $06, $02, $02, $03, $10
	db $0c, $58, $01, $07, $02, $03, $03, $10, $1e, $58

Data_04_5826:
	db $e2, $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_01182e", ROMX[$582e], BANK[$04]

Data_04_582e:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_011836", ROMX[$5836], BANK[$04]

Data_04_5836:
	db $f4, $54, $60, $55, $0c, $0d, $00

SECTION "analyzed_01183e", ROMX[$583e], BANK[$04]

Data_04_583e:
	db $fd, $54, $69, $55, $0c, $0d, $00

SECTION "analyzed_011846", ROMX[$5846], BANK[$04]

Data_04_5846:
	db $06, $55, $72, $55, $0c, $0d, $00

SECTION "analyzed_01184e", ROMX[$584e], BANK[$04]

Data_04_584e:
	db $0f, $55

Data_04_5850:
	db $7b, $55

Data_04_5852:
	db $0c, $0d, $00

SECTION "analyzed_011856", ROMX[$5856], BANK[$04]

Data_04_5856:
	db $18, $55

Data_04_5858:
	db $84, $55

Data_04_585a:
	db $0c, $0d, $00

SECTION "analyzed_01185e", ROMX[$585e], BANK[$04]

Data_04_585e:
	db $21, $55

Data_04_5860:
	db $8d, $55

Data_04_5862:
	db $0c, $0d, $00

Data_04_5865:
	db $00, $ba, $4c

Data_04_5868:
	db $7a, $58, $82, $58, $99, $58, $a6, $58

Data_04_5870:
	db $b3, $58, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_5878:
	db $ca, $58, $01, $00, $02, $01, $03, $10, $7a, $58, $01, $00, $02, $03, $03, $01
	db $01, $02, $03, $03, $01, $00, $02, $03, $03, $01, $02, $02, $03, $03, $10, $82
	db $58, $01, $03, $02, $1e, $03, $01, $04, $02, $05, $03

Data_04_58a3:
	db $10, $9e, $58

Data_04_58a6:
	db $01, $05, $02, $02, $03, $01, $06, $02, $02, $03, $10, $a6, $58

Data_04_58b3:
	db $01, $00, $02, $02, $03, $01, $01, $02, $02, $03, $01, $00, $02, $02, $03, $01
	db $02, $02, $02, $03, $10, $b3, $58

Data_04_58ca:
	db $01, $07, $02, $02, $03, $10, $ca, $58, $ba, $55, $26, $56, $0e, $0f, $00

SECTION "analyzed_0118da", ROMX[$58da], BANK[$04]

Data_04_58da:
	db $c3, $55, $2f, $56, $0e, $0f, $00

Data_04_58e1:
	db $00, $cc, $55, $38, $56, $0e, $0f, $00, $00

Data_04_58ea:
	db $d5, $55, $41, $56, $0e, $0f, $00

SECTION "analyzed_0118f2", ROMX[$58f2], BANK[$04]

Data_04_58f2:
	db $de, $55, $4a, $56, $0e, $0f, $00

Data_04_58f9:
	db $00, $e7, $55, $53, $56, $0e, $0f, $00, $00, $f0, $55, $5c, $56, $0e, $0f, $00
	db $00, $f9, $55, $65, $56, $0e, $0f, $00, $00, $ba, $4c

Data_04_5914:
	db $26, $59, $2e, $59, $3b, $59

Data_04_591a:
	db $48, $59, $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c, $55, $59

Data_04_5926:
	db $01, $00, $02, $01, $03, $10, $26, $59, $01, $00, $02, $05, $03, $01, $01, $02
	db $05, $03, $10, $2e, $59, $01, $03, $02, $03, $03, $01, $04, $02, $03, $03, $10
	db $3b, $59

Data_04_5948:
	db $01, $05, $02, $02, $03, $01, $06, $02, $02, $03, $10, $48, $59, $01, $07, $02
	db $02, $03, $10, $55, $59

Data_04_595d:
	db $e2, $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_011965", ROMX[$5965], BANK[$04]

Data_04_5965:
	db $eb, $54, $57, $55, $0c, $0d, $00

Data_04_596c:
	db $00, $f4, $54, $60, $55, $0c, $0d, $00, $00, $fd, $54, $69, $55, $0c, $0d, $00
	db $00, $06, $55, $72, $55, $0c, $0d, $00, $00, $0f, $55, $7b, $55, $0c, $0d, $00
	db $00, $18, $55, $84, $55, $0c, $0d, $00, $00, $ba, $4c

Data_04_5997:
	db $a9, $59, $b1, $59

Data_04_599b:
	db $c8, $59, $df, $59, $e7, $59, $ba, $4c, $ba, $4c, $ba, $4c, $fe, $59

Data_04_59a9:
	db $01, $00, $02, $01, $03, $10, $a9, $59, $01, $00, $02, $08, $03, $01, $01, $02
	db $08, $03

Data_04_59bb:
	db $01, $00, $02, $08, $03, $01, $02, $02, $08, $03, $10, $b1, $59, $01, $00, $02
	db $03, $03, $01, $03, $02, $1b, $03, $01, $04, $02, $04, $03, $01, $02, $02, $04
	db $03, $10, $d7, $59, $01, $05, $02, $03, $03, $10, $df, $59, $01, $00, $02, $04
	db $03, $01, $01, $02, $04, $03, $01, $00, $02, $04, $03, $01, $02, $02, $04, $03
	db $10, $e7, $59, $01, $06, $02, $02, $03, $10, $fe, $59

Data_04_5a06:
	db $e2, $54, $4e, $55, $0c, $0d, $00

SECTION "analyzed_011a0e", ROMX[$5a0e], BANK[$04]

Data_04_5a0e:
	db $eb, $54, $57, $55, $0c, $0d, $00

SECTION "analyzed_011a16", ROMX[$5a16], BANK[$04]

Data_04_5a16:
	db $f4, $54, $60, $55, $0c, $0d, $00

SECTION "analyzed_011a1e", ROMX[$5a1e], BANK[$04]

Data_04_5a1e:
	db $fd, $54, $69, $55, $0c, $0d, $00

SECTION "analyzed_011a26", ROMX[$5a26], BANK[$04]

Data_04_5a26:
	db $06, $55, $72, $55, $0c, $0d, $00

Data_04_5a2d:
	db $00, $0f, $55, $7b, $55, $0c, $0d, $00, $00, $18, $55, $84, $55, $0c, $0d, $00
	db $00, $21, $55, $8d, $55, $0c, $0d, $00, $00, $ba, $4c

Data_04_5a48:
	db $5a, $5a, $62, $5a, $74, $5a

Data_04_5a4e:
	db $86, $5a, $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c, $93, $5a

Data_04_5a5a:
	db $01, $00, $02, $01, $03, $10, $5a, $5a, $01, $00, $02, $05, $03, $01, $01, $02
	db $05, $03, $01, $02, $02, $05, $03, $10, $62, $5a, $01, $03, $02, $1e, $03, $01
	db $04, $02, $28, $03, $01, $03, $02, $05, $03

Data_04_5a83:
	db $10, $5a, $5a, $01, $05, $02, $03, $03, $01, $06, $02, $03, $03, $10, $86, $5a
	db $01, $07, $02, $03, $03, $10, $93, $5a

Data_04_5a9b:
	db $1e, $58, $1e, $58, $20, $21, $00

SECTION "analyzed_011aa3", ROMX[$5aa3], BANK[$04]

Data_04_5aa3:
	db $4f, $58, $4f, $58, $20, $21, $00

SECTION "analyzed_011aab", ROMX[$5aab], BANK[$04]

Data_04_5aab:
	db $80, $58, $13, $59, $20, $21, $00

SECTION "analyzed_011ab3", ROMX[$5ab3], BANK[$04]

Data_04_5ab3:
	db $b1, $58, $b1, $58, $20, $21, $00

SECTION "analyzed_011abb", ROMX[$5abb], BANK[$04]

Data_04_5abb:
	db $e2, $58, $e2, $58, $20, $21, $00

SECTION "analyzed_011ac3", ROMX[$5ac3], BANK[$04]

Data_04_5ac3:
	db $13, $59, $80, $58, $20, $21, $00

SECTION "analyzed_011acb", ROMX[$5acb], BANK[$04]

Data_04_5acb:
	db $44, $59, $75, $59, $20, $21, $00

SECTION "analyzed_011ad3", ROMX[$5ad3], BANK[$04]

Data_04_5ad3:
	db $a6, $59, $d7, $59, $20, $21, $00

SECTION "analyzed_011adb", ROMX[$5adb], BANK[$04]

Data_04_5adb:
	db $08, $5a, $08, $5a, $20, $00, $00

SECTION "analyzed_011ae3", ROMX[$5ae3], BANK[$04]

Data_04_5ae3:
	db $39, $5a, $39, $5a, $20, $00, $00

Data_04_5aea:
	db $00, $1e, $58, $1e, $58, $20, $00, $00, $00

Data_04_5af3:
	db $4f, $58, $4f, $58, $20, $00, $00

SECTION "analyzed_011afb", ROMX[$5afb], BANK[$04]

Data_04_5afb:
	db $80, $58, $13, $59, $20, $00, $00

SECTION "analyzed_011b03", ROMX[$5b03], BANK[$04]

Data_04_5b03:
	db $b1, $58, $b1, $58, $20, $00, $00

Data_04_5b0a:
	db $00, $e2, $58, $e2, $58, $20, $00, $00, $00, $13, $59, $80, $58, $20, $00, $00
	db $00

Data_04_5b1b:
	db $44, $59, $75, $59, $20, $00, $00

Data_04_5b22:
	db $00, $a6, $59, $d7, $59, $20, $00, $00, $00, $ba, $4c

Data_04_5b2d:
	db $3f, $5b, $47, $5b, $77, $5b, $8b, $5b

Data_04_5b35:
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_5b3d:
	db $c7, $5b, $01, $00, $02, $01, $03, $10, $3f, $5b, $01, $00, $02, $0a, $03, $01
	db $01, $02, $0a, $03, $01, $02, $02, $0a, $03, $01, $03, $02, $0a, $03, $01, $04
	db $02, $0a, $03, $01, $03, $02, $0a, $03, $01, $05, $02, $0a, $03, $01, $01, $02
	db $0a, $03, $01, $00, $02, $0a, $03

Data_04_5b74:
	db $10, $3f, $5b

Data_04_5b77:
	db $01, $01, $02, $0a, $03, $01, $06, $02, $0a, $03, $04, $1f, $01, $07, $02, $1e
	db $03

Data_04_5b88:
	db $10, $3f, $5b

Data_04_5b8b:
	db $01, $0b, $02, $07, $03, $01, $0d, $02, $07, $03, $01, $0c, $02, $07, $03, $01
	db $10, $02, $07, $03, $01, $0c, $02, $0e, $03, $01, $0b, $02, $07, $03, $01, $0d
	db $02, $07, $03, $01, $0c, $02, $07, $03, $01, $10, $02, $07, $03, $01, $0c, $02
	db $0e, $03, $04, $13, $01, $08, $02, $0a, $03, $10, $bf, $5b, $01, $09, $02, $04
	db $03, $09, $01, $09, $02, $02, $03, $08, $02, $02, $03, $10, $cc, $5b, $9b, $5a
	db $c4, $5a, $22, $23, $00

SECTION "analyzed_011be1", ROMX[$5be1], BANK[$04]

Data_04_5be1:
	db $ed, $5a, $16, $5b, $22, $23, $00

SECTION "analyzed_011be9", ROMX[$5be9], BANK[$04]

Data_04_5be9:
	db $3f, $5b, $68, $5b, $22, $23, $00

SECTION "analyzed_011bf1", ROMX[$5bf1], BANK[$04]

Data_04_5bf1:
	db $91, $5b, $ba, $5b, $22, $23, $00

Data_04_5bf8:
	db $00, $e3, $5b, $0c, $5c, $22, $23, $00, $00

Data_04_5c01:
	db $35, $5c, $5e, $5c, $22, $23, $00

SECTION "analyzed_011c09", ROMX[$5c09], BANK[$04]

Data_04_5c09:
	db $87, $5c, $b0, $5c, $22, $23, $00

SECTION "analyzed_011c11", ROMX[$5c11], BANK[$04]

Data_04_5c11:
	db $d9, $5c, $02, $5d, $22, $23, $00

Data_04_5c18:
	db $00, $2b, $5d

Data_04_5c1b:
	db $54, $5d, $22, $00, $00

Data_04_5c20:
	db $00, $ba, $4c, $35, $5c

Data_04_5c25:
	db $3d, $5c, $63, $5c, $77, $5c, $8e, $5c, $ac, $5c

Data_04_5c2f:
	db $ba, $4c, $ba, $4c

Data_04_5c33:
	db $b9, $5c

Data_04_5c35:
	db $01, $00, $02, $01, $03, $10, $35, $5c

Data_04_5c3d:
	db $01, $00, $02, $0a, $03, $01, $02, $02, $0a, $03, $01, $03, $02, $0a, $03, $01
	db $00, $02, $0a, $03, $01, $01, $02, $0a, $03, $01, $02, $02, $0a, $03, $01, $03
	db $02, $0a, $03, $10, $3d, $5c, $01, $00, $02, $0a, $03, $01, $05, $02, $0a, $03
	db $04, $19, $01, $06, $02, $01, $03, $10, $6f, $5c, $01, $03, $02, $0a, $03, $01
	db $07, $02, $0a, $03, $01, $05, $02, $0a, $03, $01, $00, $02, $0a, $03

Data_04_5c8b:
	db $10, $35, $5c

Data_04_5c8e:
	db $01, $00, $02, $0a, $03, $01, $05, $02, $0a, $03, $01, $06, $02, $0a, $03, $01
	db $03, $02, $0a, $03, $04, $19, $01, $07, $02, $01, $03, $10, $a4, $5c, $01, $05
	db $02, $0a, $03, $01, $00, $02, $0a, $03

Data_04_5cb6:
	db $10, $35, $5c

Data_04_5cb9:
	db $01, $00, $02, $0a, $03, $01, $05, $02, $0a, $03, $01, $08, $02, $0a, $03, $09
	db $01, $08, $02, $02, $03, $08, $02, $02, $03, $10, $c8, $5c, $b5, $5d, $b5, $5d
	db $24, $25, $00

SECTION "analyzed_011cdd", ROMX[$5cdd], BANK[$04]

Data_04_5cdd:
	db $e6, $5d, $e6, $5d, $24, $25, $00

SECTION "analyzed_011ce5", ROMX[$5ce5], BANK[$04]

Data_04_5ce5:
	db $17, $5e, $17, $5e, $24, $25, $00

SECTION "analyzed_011ced", ROMX[$5ced], BANK[$04]

Data_04_5ced:
	db $48, $5e, $48, $5e, $24, $25, $00

SECTION "analyzed_011cf5", ROMX[$5cf5], BANK[$04]

Data_04_5cf5:
	db $79, $5e, $79, $5e, $24, $25, $00

SECTION "analyzed_011cfd", ROMX[$5cfd], BANK[$04]

Data_04_5cfd:
	db $aa, $5e, $db, $5e, $24, $25, $00

Data_04_5d04:
	db $00, $0c, $5f

Data_04_5d07:
	db $0c, $5f, $24, $00, $00

Data_04_5d0c:
	db $00, $3d, $5f

Data_04_5d0f:
	db $3d, $5f, $24, $00, $00

Data_04_5d14:
	db $00, $6e, $5f

Data_04_5d17:
	db $6e, $5f, $24, $00, $00

Data_04_5d1c:
	db $00, $ba, $4c

Data_04_5d1f:
	db $31, $5d

Data_04_5d21:
	db $ba, $4c

Data_04_5d23:
	db $48, $5d, $61, $5d

Data_04_5d27:
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c

Data_04_5d2f:
	db $75, $5d, $01, $00, $02, $0a, $03, $01, $01, $02, $0a, $03, $01, $00, $02, $0a
	db $03, $01, $02, $02, $0a, $03, $10, $31, $5d, $01, $01, $02, $0a, $03, $01, $03
	db $02, $0a, $03, $01, $04, $02, $14, $03, $04, $1f, $01, $05, $02, $14, $03

Data_04_5d5e:
	db $10, $31, $5d

Data_04_5d61:
	db $01, $00, $02, $0a, $03, $01, $06, $02, $1e, $03, $04, $13, $01, $07, $02, $0a
	db $03, $10, $6d, $5d, $01, $08, $02, $04, $03, $09, $01, $08, $02, $02, $03, $08
	db $02, $02, $03, $10, $7a, $5d, $e7, $5f

Data_04_5d89:
	db $e7, $5f

Data_04_5d8b:
	db $26, $26, $00

SECTION "analyzed_011d8f", ROMX[$5d8f], BANK[$04]

Data_04_5d8f:
	db $08, $60

Data_04_5d91:
	db $08, $60

Data_04_5d93:
	db $26, $26, $00

SECTION "analyzed_011d97", ROMX[$5d97], BANK[$04]

Data_04_5d97:
	db $29, $60

Data_04_5d99:
	db $29, $60

Data_04_5d9b:
	db $27, $27, $00

SECTION "analyzed_011d9f", ROMX[$5d9f], BANK[$04]

Data_04_5d9f:
	db $4a, $60

Data_04_5da1:
	db $4a, $60

Data_04_5da3:
	db $26, $26, $00

SECTION "analyzed_011da7", ROMX[$5da7], BANK[$04]

Data_04_5da7:
	db $6b, $60

Data_04_5da9:
	db $6b, $60

Data_04_5dab:
	db $28, $28, $00

SECTION "analyzed_011daf", ROMX[$5daf], BANK[$04]

Data_04_5daf:
	db $7c, $60

Data_04_5db1:
	db $7c, $60

Data_04_5db3:
	db $28, $28, $00

SECTION "analyzed_011db7", ROMX[$5db7], BANK[$04]

Data_04_5db7:
	db $4a, $60

Data_04_5db9:
	db $4a, $60

Data_04_5dbb:
	db $26, $00, $00

SECTION "analyzed_011dbf", ROMX[$5dbf], BANK[$04]

Data_04_5dbf:
	db $6b, $60

Data_04_5dc1:
	db $6b, $60

Data_04_5dc3:
	db $28, $00, $00

Data_04_5dc6:
	db $00, $ba, $4c

Data_04_5dc9:
	db $d7, $5d, $df, $5d, $e7, $5d, $ff, $5d, $11, $5e, $18, $5e, $31, $5e, $01, $00
	db $02, $0a, $03, $10, $d7, $5d, $01, $04, $02, $0a, $03, $10, $df, $5d, $01, $06
	db $02, $04, $03, $09, $0a, $c6, $41, $01, $06, $02, $02, $03, $08, $0a, $0a, $42
	db $02, $02, $03, $10, $ec, $5d, $01, $07, $02, $04, $03, $09, $01, $07, $02, $02
	db $03, $08, $02, $02, $03, $10, $04, $5e

Data_04_5e11:
	db $08, $02, $02, $03, $10, $11, $5e

Data_04_5e18:
	db $01, $01, $02, $0a, $03, $01, $02, $02, $4e, $03, $04, $10, $01, $03, $02, $1e
	db $03, $01, $01, $02, $0a, $03

Data_04_5e2e:
	db $10, $d7, $5d

Data_04_5e31:
	db $01, $05, $02, $0a, $03, $10, $31, $5e, $8d, $60, $8d, $60, $29, $2a, $00

SECTION "analyzed_011e41", ROMX[$5e41], BANK[$04]

Data_04_5e41:
	db $be, $60, $ef, $60, $29, $2a, $00

SECTION "analyzed_011e49", ROMX[$5e49], BANK[$04]

Data_04_5e49:
	db $20, $61, $51, $61, $29, $2a, $00

SECTION "analyzed_011e51", ROMX[$5e51], BANK[$04]

Data_04_5e51:
	db $82, $61, $b3, $61, $29, $2a, $00

SECTION "analyzed_011e59", ROMX[$5e59], BANK[$04]

Data_04_5e59:
	db $e4, $61, $15, $62, $29, $2a, $00

SECTION "analyzed_011e61", ROMX[$5e61], BANK[$04]

Data_04_5e61:
	db $46, $62, $77, $62, $29, $2a, $00

SECTION "analyzed_011e69", ROMX[$5e69], BANK[$04]

Data_04_5e69:
	db $a8, $62, $a8, $62, $29, $2a, $00

SECTION "analyzed_011e71", ROMX[$5e71], BANK[$04]

Data_04_5e71:
	db $d9, $62, $d9, $62, $29, $2a, $00

SECTION "analyzed_011e79", ROMX[$5e79], BANK[$04]

Data_04_5e79:
	db $8d, $60, $8d, $60, $29, $00, $00

SECTION "analyzed_011e81", ROMX[$5e81], BANK[$04]

Data_04_5e81:
	db $d9, $62

Data_04_5e83:
	db $d9, $62

Data_04_5e85:
	db $29, $00, $00

SECTION "analyzed_011e89", ROMX[$5e89], BANK[$04]

Data_04_5e89:
	db $ba, $4c, $9f, $5e, $a8, $5e, $b5, $5e, $be, $5e, $d3, $5e, $eb, $5e, $0a, $5f
	db $13, $5f, $21, $5f, $36, $5f, $09, $01, $07, $02, $05, $03, $10, $9f, $5e, $09
	db $01, $00, $02, $02, $03, $08, $02, $02, $03, $10, $a8, $5e, $09, $01, $00, $02
	db $02, $03, $10, $b6, $5e, $09, $01, $01, $02, $0a, $03, $01, $04, $02, $14, $03
	db $04, $18, $01, $05, $02, $0a, $03, $10, $cb, $5e, $09, $01, $05, $02, $0a, $03
	db $01, $04, $02, $14, $03, $01, $01, $02, $0a, $03, $01, $00, $02, $3c, $03

Data_04_5ee8:
	db $10, $e3, $5e

Data_04_5eeb:
	db $09, $01, $01, $02, $0a, $03, $01, $02, $02, $14, $03, $04, $23, $01, $03, $02
	db $0a, $03, $01, $04, $02, $0a, $03, $01, $00, $02, $3c, $03

Data_04_5f07:
	db $10, $02, $5f

Data_04_5f0a:
	db $09, $01, $06, $02, $05, $03

Data_04_5f10:
	db $10, $9f, $5e

Data_04_5f13:
	db $09, $01, $07, $02, $05, $03, $01, $06, $02, $05, $03

Data_04_5f1e:
	db $10, $b5, $5e

Data_04_5f21:
	db $04, $22, $09, $01, $09, $02, $3c, $03, $09, $01, $09, $02, $02, $03, $08, $02
	db $02, $03, $10, $29, $5f, $04, $1a, $09, $01, $08, $02, $02, $03, $10, $39, $5f

Data_04_5f41:
	db $e2, $54, $4e, $55, $0c, $0d, $00, $00, $ba, $4c, $5d, $5f, $ba, $4c, $ba, $4c
	db $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c, $ba, $4c, $65, $5f, $01, $00, $02, $01
	db $03, $10, $5d, $5f, $01, $00, $02, $04, $03, $09, $01, $00, $02, $02, $03, $08
	db $02, $02, $03, $10, $6a, $5f

SECTION "analyzed_040000", ROMX[$4000], BANK[$10]

Data_10_4000:
	db $cd, $18, $40, $cd, $3a, $40, $c9

Func_10_4007:
	xor a
	ld [rVBK], a
	ld hl, $44b7
	ld de, $9400
	ld bc, $0400
	call VramCopy16
	ret
Func_10_4018:
	xor a
	ld [rVBK], a
	ld hl, $40b7
	ld de, $9000
	ld bc, $0800
	call VramCopy16
	ld a, $01
	ld [rVBK], a
	ld hl, $48b7
	ld de, $8800
	ld bc, $0800
	call VramCopy16
	ret

Data_10_403a:
	db $21, $b7, $60, $cd, $f2, $04, $c9

Func_10_4041:
	xor a
	ld [rVBK], a
	ld hl, $50b7
	ld de, $8000
	ld bc, $0800
	call VramCopy16
	ld hl, $66f7
	ld a, $00
	ld b, $04
	call Func_00_0732
	call Func_00_0786
	ret
Func_10_405f:
	xor a
	ld [rVBK], a
	ld hl, $53b7
	ld de, $8300
	ld bc, $0500
	call VramCopy16
	ret
Func_10_4070:
	xor a
	ld [rVBK], a
	ld hl, $58b7
	ld de, $8800
	ld bc, $0800
	call VramCopy16
	ret
Func_10_4081:
	ld hl, $66f7
	ld a, $00
	ld b, $04
	call Func_00_0732
	ret

Data_10_408c:
	db $b7, $60, $37, $61, $b7, $61, $37, $62, $b7, $62, $37, $63, $b7, $63, $37, $64
	db $b7, $64, $37, $65, $b7, $65, $37, $66

Func_10_40a4:
	ld a, [$c4cb]
	add a, a
	ld hl, $408c
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, $00
	ld b, $07
	call Func_00_0716
	ret

Data_10_40b7:
	INCBIN "raw_gfx/Data_10_40b7.2bpp", 0, 4096

Data_10_50b7:
	db $00, $00, $60, $60, $78, $78, $7e, $7e, $7e, $7e, $78, $78, $60, $60, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $70, $70, $7e, $7e, $7e, $7e, $70, $70, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $7e, $7e, $7e, $7e, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $18, $18, $18, $18, $3c, $3c, $3c, $3c, $7e, $7e, $7e, $7e, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $18, $18, $18, $18, $18, $18, $3c, $3c, $3c, $3c, $3c, $3c, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $18, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $e7, $e7, $81, $81, $81, $81, $00, $00, $00, $00, $81, $81, $81, $81, $e7, $e7
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $f8, $f8, $f8, $f8, $c0, $c0, $c0, $c0, $c0, $c0, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $c0, $c0, $c0, $c0, $c0, $c0, $f8, $f8, $f8, $f8
	db $00, $00, $00, $60, $00, $78, $00, $7e, $00, $7e, $00, $78, $00, $60, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $70, $00, $7e, $00, $7e, $00, $70, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $7e, $00, $7e, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $18, $00, $18, $00, $3c, $00, $3c, $00, $7e, $00, $7e, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $18, $00, $18, $00, $18, $00, $3c, $00, $3c, $00, $3c, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $18, $00, $18, $00, $18, $00, $18, $00, $18, $00, $18, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $e7, $00, $81, $00, $81, $00, $00, $00, $00, $00, $81, $00, $81, $00, $e7
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $f8, $00, $f8, $00, $c0, $00, $c0, $00, $c0, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $c0, $00, $c0, $00, $c0, $00, $f8, $00, $f8
	db $00, $00, $60, $00, $78, $00, $7e, $00, $7e, $00, $78, $00, $60, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $70, $00, $7e, $00, $7e, $00, $70, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $7e, $00, $7e, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $18, $00, $18, $00, $3c, $00, $3c, $00, $7e, $00, $7e, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $18, $00, $18, $00, $18, $00, $3c, $00, $3c, $00, $3c, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $18, $00, $18, $00, $18, $00, $18, $00, $18, $00, $18, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $e7, $00, $81, $00, $81, $00, $00, $00, $00, $00, $81, $00, $81, $00, $e7, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $f8, $00, $f8, $00, $c0, $00, $c0, $00, $c0, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $c0, $00, $c0, $00, $c0, $00, $f8, $00, $f8, $00

Data_10_53b7:
	INCBIN "raw_gfx/Data_10_53b7.2bpp", 0, 1280

Data_10_58b7:
	db $ff, $ff, $80, $ff, $80, $ff, $8e, $f9, $9f, $f0, $9f, $f0, $8e, $f9, $83, $fe
	db $b7, $ed, $9c, $f3, $81, $ff, $83, $fe, $86, $fd, $9e, $f5, $8c, $fb, $ff, $00
	db $ff, $ff, $80, $ff, $83, $fe, $87, $fc, $87, $fc, $83, $fe, $81, $ff, $83, $fe
	db $87, $fd, $9d, $f3, $81, $ff, $83, $fe, $86, $fd, $86, $fd, $9c, $f3, $ff, $00
	db $ff, $ff, $80, $ff, $80, $ff, $bf, $ff, $bf, $e0, $bf, $e0, $80, $ff, $80, $ff
	db $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $ff, $00
	db $ff, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff
	db $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $ff, $00
	db $ff, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $e1, $9e, $b1, $6e
	db $b1, $6e, $c1, $be, $c1, $3e, $c1, $be, $71, $ce, $19, $f6, $31, $ee, $ff, $00
	db $ff, $fe, $01, $fe, $81, $7e, $c1, $3e, $c1, $3e, $81, $7e, $81, $7e, $c1, $3e
	db $e1, $5e, $b1, $6e, $b1, $6e, $c1, $be, $c1, $be, $61, $de, $e1, $9e, $ff, $00
	db $ff, $fe, $21, $fe, $31, $ee, $f9, $e6, $fd, $02, $fd, $02, $39, $e6, $31, $ee
	db $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $ff, $00
	db $ff, $fe, $01, $fe, $39, $fe, $39, $e6, $39, $e6, $39, $e6, $39, $e6, $39, $e6
	db $39, $e6, $f9, $e6, $ff, $80, $7d, $c2, $39, $e6, $11, $fe, $01, $fe, $ff, $00
	db $ff, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff
	db $84, $ff, $8c, $fb, $9f, $f3, $bf, $e0, $bf, $e0, $9c, $f3, $8c, $fb, $ff, $00
	db $ff, $ff, $80, $ff, $88, $ff, $9c, $f3, $be, $e1, $ff, $c0, $fc, $f3, $9c, $f3
	db $9c, $f3, $9c, $f3, $9c, $f3, $9c, $f3, $9c, $f3, $9c, $f3, $80, $ff, $ff, $00
	db $ff, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff
	db $80, $ff, $80, $ff, $bf, $ff, $bf, $e0, $bf, $e0, $80, $ff, $80, $ff, $ff, $00
	db $ff, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff
	db $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $ff, $00
	db $ff, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe
	db $01, $fe, $01, $fe, $fd, $fe, $fd, $02, $fd, $02, $01, $fe, $01, $fe, $ff, $00
	db $ff, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe
	db $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $ff, $00
	db $ff, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe
	db $21, $fe, $31, $ee, $f9, $e6, $fd, $02, $fd, $02, $39, $e6, $31, $ee, $ff, $00
	db $ff, $fe, $01, $fe, $11, $fe, $39, $e6, $7d, $c2, $ff, $80, $f9, $e6, $39, $e6
	db $39, $e6, $39, $e6, $39, $e6, $39, $e6, $39, $e6, $39, $e6, $01, $fe, $ff, $00
	db $ff, $ff, $84, $ff, $8c, $fb, $9f, $f3, $bf, $e0, $bf, $e0, $9c, $f3, $8c, $fb
	db $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $ff, $00
	db $ff, $ff, $80, $ff, $9c, $ff, $9c, $f3, $9c, $f3, $9c, $f3, $9c, $f3, $9c, $f3
	db $9c, $f3, $fc, $f3, $ff, $c0, $be, $e1, $9c, $f3, $88, $ff, $80, $ff, $ff, $00
	db $ff, $ff, $80, $ff, $81, $ff, $83, $fe, $87, $fc, $8f, $f8, $8f, $fe, $83, $fe
	db $83, $fe, $83, $fe, $83, $fe, $83, $fe, $83, $fe, $83, $fe, $80, $ff, $ff, $00
	db $ff, $ff, $80, $ff, $83, $ff, $83, $fe, $83, $fe, $83, $fe, $83, $fe, $83, $fe
	db $83, $fe, $8f, $fe, $8f, $f8, $87, $fc, $83, $fe, $81, $ff, $80, $ff, $ff, $00
	db $ff, $fe, $01, $fe, $01, $fe, $fd, $fe, $fd, $02, $fd, $02, $01, $fe, $01, $fe
	db $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $ff, $00
	db $ff, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe
	db $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $ff, $00
	db $ff, $fe, $01, $fe, $01, $fe, $81, $7e, $c1, $3e, $e1, $1e, $81, $7e, $81, $7e
	db $81, $7e, $81, $7e, $81, $7e, $81, $7e, $81, $7e, $81, $7e, $01, $fe, $ff, $00
	db $ff, $fe, $01, $fe, $81, $fe, $81, $7e, $81, $7e, $81, $7e, $81, $7e, $81, $7e
	db $81, $7e, $81, $7e, $e1, $1e, $c1, $3e, $81, $7e, $01, $fe, $01, $fe, $ff, $00
	db $ff, $ff, $80, $ff, $80, $ff, $80, $ff, $84, $ff, $8c, $fb, $9f, $f3, $bf, $e0
	db $bf, $e0, $9c, $f3, $8c, $fb, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $ff, $00
	db $ff, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $bf, $ff, $bf, $e0
	db $bf, $e0, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $ff, $00
	db $ff, $ff, $80, $ff, $83, $ff, $83, $fe, $83, $fe, $83, $fe, $83, $fe, $8b, $fe
	db $9b, $f6, $bf, $e6, $ff, $c0, $ff, $c0, $b8, $e7, $98, $f7, $80, $ff, $ff, $00
	db $ff, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $82, $ff
	db $86, $fd, $8f, $f9, $9f, $f0, $9f, $f0, $8e, $f9, $86, $fd, $80, $ff, $ff, $00
	db $ff, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $fd, $fe, $fd, $02
	db $fd, $02, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $ff, $00
	db $ff, $fe, $01, $fe, $01, $fe, $01, $fe, $21, $fe, $31, $ee, $f9, $e6, $fd, $02
	db $fd, $02, $39, $e6, $31, $ee, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $ff, $00
	db $ff, $fe, $01, $fe, $81, $fe, $81, $7e, $81, $7e, $81, $7e, $81, $7e, $a1, $7e
	db $b1, $6e, $f9, $66, $fd, $02, $fd, $02, $39, $e6, $31, $ee, $01, $fe, $ff, $00
	db $ff, $fe, $01, $fe, $e1, $fe, $e1, $9e, $e1, $9e, $e1, $9e, $e1, $9e, $e1, $9e
	db $e1, $9e, $e1, $9e, $e1, $1e, $e1, $1e, $01, $fe, $01, $fe, $01, $fe, $ff, $00
	db $ff, $ff, $80, $ff, $87, $ff, $87, $fc, $87, $fc, $87, $fc, $87, $fc, $87, $fc
	db $87, $fc, $87, $fc, $87, $fc, $87, $fc, $80, $ff, $80, $ff, $80, $ff, $ff, $00
	db $ff, $ff, $80, $ff, $81, $ff, $83, $fe, $8b, $fe, $8f, $fc, $8f, $f8, $8f, $f9
	db $87, $fd, $87, $fd, $8f, $fa, $8f, $fa, $87, $fd, $83, $fe, $80, $ff, $ff, $00
	db $ff, $ff, $80, $ff, $80, $ff, $8c, $ff, $9e, $f1, $bf, $e0, $bf, $e0, $bf, $e0
	db $bf, $e0, $9f, $f0, $8f, $f8, $87, $fc, $83, $fe, $81, $ff, $80, $ff, $ff, $00
	db $ff, $ff, $80, $ff, $80, $ff, $80, $ff, $83, $ff, $87, $fc, $8f, $f8, $8f, $f8
	db $8f, $f8, $87, $fc, $83, $fe, $81, $ff, $80, $ff, $80, $ff, $80, $ff, $ff, $00
	db $ff, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $41, $fe
	db $61, $de, $f1, $ce, $f9, $06, $f9, $06, $71, $ce, $61, $de, $01, $fe, $ff, $00
	db $ff, $fe, $01, $fe, $81, $7e, $81, $7e, $c1, $3e, $c1, $3e, $e1, $1e, $e1, $1e
	db $f1, $0e, $f1, $0e, $f1, $0e, $f1, $0e, $e1, $1e, $c1, $3e, $01, $fe, $ff, $00
	db $ff, $fe, $01, $fe, $01, $fe, $31, $fe, $79, $c6, $fd, $82, $fd, $02, $fd, $02
	db $fd, $02, $f9, $06, $f1, $0e, $e1, $1e, $c1, $3e, $81, $7e, $01, $fe, $ff, $00
	db $ff, $fe, $01, $fe, $01, $fe, $01, $fe, $61, $fe, $e1, $9e, $f1, $0e, $f1, $0e
	db $f1, $0e, $e1, $1e, $c1, $3e, $81, $7e, $01, $fe, $01, $fe, $01, $fe, $ff, $00
	db $ff, $ff, $e0, $ff, $d0, $ef, $b3, $ce, $87, $fc, $86, $fd, $86, $fd, $87, $fc
	db $81, $fe, $80, $ff, $80, $ff, $86, $fd, $e7, $fc, $d3, $ee, $b0, $cf, $ff, $00
	db $ff, $ff, $00, $ff, $00, $ff, $f3, $0e, $9e, $75, $00, $ff, $00, $ff, $00, $ff
	db $f0, $0f, $00, $ff, $00, $ff, $00, $ff, $98, $77, $f1, $0f, $00, $ff, $ff, $00
	db $ff, $ff, $00, $ff, $00, $ff, $ff, $08, $b6, $6d, $86, $7d, $86, $7d, $86, $7d
	db $86, $7d, $86, $7d, $86, $7d, $86, $7d, $86, $7d, $cf, $38, $00, $ff, $ff, $00
	db $ff, $ff, $00, $ff, $00, $ff, $cf, $38, $9d, $73, $b8, $67, $b0, $6f, $b0, $6f
	db $b1, $6f, $b0, $6f, $b0, $6f, $b8, $67, $9d, $73, $8f, $78, $00, $ff, $ff, $00
	db $ff, $ff, $00, $ff, $00, $ff, $f1, $0f, $3b, $e6, $1f, $f4, $06, $fd, $06, $fd
	db $f7, $0c, $3e, $e5, $1e, $f5, $1f, $f4, $3b, $e6, $f1, $0f, $00, $ff, $ff, $00
	db $ff, $ff, $00, $ff, $00, $ff, $ff, $04, $dd, $b3, $c1, $bf, $c1, $bf, $c1, $bf
	db $c1, $bf, $c1, $bf, $c1, $bf, $c1, $bf, $c1, $bf, $e3, $1e, $00, $ff, $ff, $00
	db $ff, $ff, $00, $ff, $00, $ff, $f1, $8f, $79, $c7, $79, $d7, $7d, $d3, $6f, $d9
	db $67, $dd, $67, $dd, $63, $de, $63, $de, $61, $df, $f1, $8f, $00, $ff, $ff, $00
	db $ff, $fe, $0d, $fe, $0b, $fc, $87, $78, $c1, $3e, $e1, $9e, $01, $fe, $01, $fe
	db $f1, $0e, $61, $de, $61, $de, $e1, $9e, $cd, $3e, $8b, $7c, $07, $f8, $ff, $00
	db $ff, $ff, $f8, $f8, $e7, $e0, $df, $c7, $d8, $c8, $bb, $9b, $ba, $9a, $b3, $93
	db $a4, $84, $a7, $87, $b6, $96, $b9, $99, $df, $cf, $df, $c7, $e7, $e0, $f8, $f8
	db $ff, $ff, $fe, $81, $fe, $bd, $fe, $9d, $fe, $85, $fe, $b9, $fe, $81, $80, $ff
	db $ff, $ff, $fe, $81, $fe, $ad, $fe, $a5, $fe, $b1, $fe, $a1, $fe, $81, $80, $ff
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $10, $00, $10, $00, $10, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $10, $00, $10, $00, $10, $00
	db $20, $00, $10, $00, $20, $00, $55, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $55, $00, $aa, $00, $10, $00, $20, $00, $10, $00
	db $ff, $ff, $0f, $0f, $f3, $03, $fd, $f1, $7d, $79, $7e, $7c, $c6, $c4, $be, $bc
	db $4e, $4c, $fe, $fc, $9e, $9c, $6e, $6c, $bd, $b9, $5d, $51, $f3, $03, $0f, $0f
	db $ff, $ff, $fe, $81, $fe, $b9, $fe, $91, $fe, $b5, $fe, $85, $fe, $81, $80, $ff
	db $ff, $ff, $fe, $81, $fe, $b9, $fe, $bd, $fe, $a1, $fe, $ad, $fe, $81, $80, $ff
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $10, $00, $10, $00, $10, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $10, $00, $10, $00, $10, $00
	db $00, $00, $00, $00, $00, $00, $55, $00, $aa, $00, $10, $00, $20, $00, $10, $00
	db $20, $00, $10, $00, $20, $00, $55, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $50, $00, $a2, $00, $10, $00, $a0, $00, $11, $00, $82, $00, $14, $00, $aa, $00
	db $45, $00, $00, $00, $41, $00, $82, $00, $15, $00, $28, $00, $44, $00, $2a, $00
	db $ff, $00, $00, $00, $00, $00, $00, $00, $ff, $00, $01, $00, $01, $00, $01, $00
	db $ff, $00, $00, $00, $00, $00, $00, $00, $ff, $00, $01, $00, $01, $00, $01, $00
	db $ff, $00, $01, $00, $7f, $00, $7f, $00, $ff, $00, $10, $00, $f7, $00, $f7, $00
	db $ff, $00, $01, $00, $7f, $00, $7f, $00, $ff, $00, $10, $00, $f7, $00, $f7, $00
	db $55, $00, $aa, $00, $40, $00, $80, $00, $40, $00, $80, $00, $40, $00, $80, $00
	db $40, $00, $80, $00, $40, $00, $80, $00, $40, $00, $80, $00, $55, $00, $aa, $00
	db $41, $00, $aa, $00, $40, $00, $80, $00, $40, $00, $aa, $00, $00, $00, $22, $00
	db $11, $00, $82, $00, $41, $00, $2a, $00, $41, $00, $28, $00, $11, $00, $22, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $00, $00, $00, $00, $00, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $00, $00, $00, $00, $00, $00
	db $ff, $00, $01, $00, $7f, $00, $7f, $00, $ff, $00, $10, $00, $f7, $00, $f7, $00
	db $ff, $00, $01, $00, $7f, $00, $7f, $00, $ff, $00, $10, $00, $f7, $00, $f7, $00
	db $55, $00, $aa, $00, $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00
	db $01, $00, $02, $00, $01, $00, $02, $00, $01, $00, $02, $00, $55, $00, $aa, $00
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $4a, $29, $63, $0c, $b5, $01, $3d, $3f
	db $4a, $29, $63, $0c, $ce, $39, $5a, $6b, $4a, $29, $63, $0c, $26, $12, $9f, $2f
	db $4a, $29, $63, $0c, $ff, $00, $9f, $63, $4a, $29, $63, $0c, $60, $7d, $9f, $63
	db $c4, $01, $63, $0c, $ce, $39, $5a, $6b

Data_10_60ef:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_10_6137:
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $8f, $19, $63, $0c, $b5, $01, $3d, $3f
	db $8f, $19, $63, $0c, $ce, $39, $5a, $6b, $8f, $19, $63, $0c, $26, $12, $9f, $2f
	db $8f, $19, $63, $0c, $ff, $00, $9f, $63, $8f, $19, $63, $0c, $60, $7d, $9f, $63
	db $c4, $01, $63, $0c, $ce, $39, $5a, $6b

Data_10_616f:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_10_61b7:
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $ea, $3c, $63, $0c, $b5, $01, $3d, $3f
	db $ea, $3c, $63, $0c, $ce, $39, $5a, $6b, $ea, $3c, $63, $0c, $26, $12, $9f, $2f
	db $ea, $3c, $63, $0c, $ff, $00, $9f, $63, $ea, $3c, $63, $0c, $60, $7d, $9f, $63
	db $c4, $01, $63, $0c, $ce, $39, $5a, $6b

Data_10_61ef:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_10_6237:
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $c2, $11, $63, $0c, $b5, $01, $3d, $3f
	db $c2, $11, $63, $0c, $ce, $39, $5a, $6b, $c2, $11, $63, $0c, $26, $12, $9f, $2f
	db $c2, $11, $63, $0c, $ff, $00, $9f, $63, $c2, $11, $63, $0c, $60, $7d, $9f, $63
	db $c4, $01, $63, $0c, $ce, $39, $5a, $6b

Data_10_626f:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_10_62b7:
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $0c, $01, $63, $0c, $b5, $01, $3d, $3f
	db $0c, $01, $63, $0c, $ce, $39, $5a, $6b, $0c, $01, $63, $0c, $26, $12, $9f, $2f
	db $0c, $01, $63, $0c, $ff, $00, $9f, $63, $0c, $01, $63, $0c, $60, $7d, $9f, $63
	db $c4, $01, $63, $0c, $ce, $39, $5a, $6b

Data_10_62ef:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_10_6337:
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $c4, $30, $63, $0c, $b5, $01, $3d, $3f
	db $c4, $30, $63, $0c, $ce, $39, $5a, $6b, $c4, $30, $63, $0c, $26, $12, $9f, $2f
	db $c4, $30, $63, $0c, $ff, $00, $9f, $63, $c4, $30, $63, $0c, $60, $7d, $9f, $63
	db $c4, $01, $63, $0c, $ce, $39, $5a, $6b

Data_10_636f:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_10_63b7:
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $6b, $00, $63, $0c, $b5, $01, $3d, $3f
	db $6b, $00, $63, $0c, $ce, $39, $5a, $6b, $6b, $00, $63, $0c, $26, $12, $9f, $2f
	db $6b, $00, $63, $0c, $ff, $00, $9f, $63, $6b, $00, $63, $0c, $60, $7d, $9f, $63
	db $c4, $01, $63, $0c, $ce, $39, $5a, $6b

Data_10_63ef:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_10_6437:
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $65, $08, $63, $0c, $b5, $01, $3d, $3f
	db $65, $08, $63, $0c, $ce, $39, $5a, $6b, $65, $08, $63, $0c, $26, $12, $9f, $2f
	db $65, $08, $63, $0c, $ff, $00, $9f, $63, $65, $08, $63, $0c, $60, $7d, $9f, $63
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_10_646f:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_10_64b7:
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $a0, $28, $a8, $4d, $b5, $01, $3d, $3f
	db $a0, $28, $a8, $4d, $ce, $39, $5a, $6b, $a0, $28, $a8, $4d, $26, $12, $9f, $2f
	db $a0, $28, $a8, $4d, $ff, $00, $9f, $63, $a0, $28, $a8, $4d, $60, $7d, $9f, $63
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_10_64ef:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_10_6537:
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $63, $18, $63, $0c, $b5, $01, $3d, $3f
	db $63, $18, $63, $0c, $ce, $39, $5a, $6b, $63, $18, $63, $0c, $26, $12, $9f, $2f
	db $63, $18, $63, $0c, $ff, $00, $9f, $63, $63, $18, $63, $0c, $60, $7d, $9f, $63
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_10_656f:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_10_65b7:
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $4a, $29, $63, $0c, $b5, $01, $3d, $3f
	db $4a, $29, $63, $0c, $ce, $39, $5a, $6b, $4a, $29, $63, $0c, $26, $12, $9f, $2f
	db $4a, $29, $63, $0c, $ff, $00, $9f, $63, $4a, $29, $63, $0c, $60, $7d, $9f, $63
	db $c4, $01, $63, $0c, $ce, $39, $5a, $6b

Data_10_65ef:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_10_6637:
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $00, $14, $63, $0c, $b5, $01, $3d, $3f
	db $00, $14, $63, $0c, $ce, $39, $5a, $6b, $00, $14, $63, $0c, $26, $12, $9f, $2f
	db $00, $14, $63, $0c, $56, $46, $d9, $66, $00, $14, $63, $0c, $60, $7d, $9f, $63
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_10_666f:
	db $00, $00, $9f, $22, $3d, $15, $de, $7b, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $7f, $94, $52, $4a, $29, $00, $00
	db $12, $01, $63, $0c, $b5, $01, $3d, $3f, $12, $01, $63, $0c, $ce, $39, $5a, $6b
	db $12, $01, $63, $0c, $26, $12, $9f, $2f, $12, $01, $63, $0c, $ff, $00, $9f, $63
	db $12, $01, $63, $0c, $60, $7d, $9f, $63, $c4, $01, $63, $0c, $ce, $39, $5a, $6b
	db $00, $00, $9f, $22, $3d, $15, $de, $7b

Data_10_66f7:
	db $00, $00, $5f, $4b, $b5, $01, $e0, $2c, $00, $00, $05, $7f, $1c, $54, $df, $6f
	db $00, $00, $1b, $24, $9f, $66, $3f, $4b, $00, $00, $4a, $29, $94, $52, $de, $7b

Data_10_6717:
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $0e, $14, $55, $68, $3d, $67, $e2, $e3, $ea, $eb, $e2, $e3, $ea, $eb, $e2, $e3
	db $ea, $eb, $e2, $e3, $ea, $eb, $e2, $e3, $ea, $eb, $eb, $fc, $fc, $fc, $fc, $fc
	db $d0, $d8, $d2, $da, $d4, $dc, $d6, $de, $fc, $fc, $fc, $fc, $fc, $e2, $ea, $fc
	db $fc, $fc, $fc, $fc, $d1, $d9, $d3, $db, $d5, $dd, $d7, $df, $fc, $fc, $fc, $fc
	db $fc, $e3, $e3, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $ea, $e2, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $eb, $eb, $fc, $fc, $82, $8a, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $80, $88, $fc, $e2, $ea, $fc
	db $fc, $83, $8b, $fc, $9b, $fc, $9c, $fc, $9d, $fc, $9e, $fc, $9f, $fc, $81, $89
	db $fc, $e3, $e3, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $ea, $e2, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $eb, $eb, $fc, $fc, $fc, $fc, $fc
	db $fc, $b2, $ba, $fc, $fc, $b0, $b8, $fc, $fc, $fc, $fc, $fc, $fc, $e2, $ea, $fc
	db $fc, $fc, $fc, $fc, $fc, $b3, $bb, $fc, $fc, $b1, $b9, $fc, $fc, $fc, $fc, $fc
	db $fc, $e3, $e3, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $ea, $e2, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $eb, $eb, $ea, $e3, $e2, $eb, $ea
	db $e3, $e2, $eb, $ea, $e3, $e2, $eb, $ea, $e3, $e2, $eb, $ea, $e3, $e2, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $08, $08, $08, $08, $08, $01, $01, $01, $01, $01, $01, $01, $01
	db $08, $08, $08, $08, $08, $01, $01, $08, $08, $08, $08, $08, $01, $01, $01, $01
	db $01, $01, $01, $01, $08, $08, $08, $08, $08, $01, $01, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $01, $01, $08, $08, $01, $01, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $01, $01, $08, $01, $01, $08, $08, $01, $01, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $01, $01, $08, $01, $01, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $01, $01, $08, $08, $08, $08, $08, $08, $01, $01, $08, $08, $01, $01, $08
	db $08, $08, $08, $08, $08, $01, $01, $08, $08, $08, $08, $08, $08, $01, $01, $08
	db $08, $01, $01, $08, $08, $08, $08, $08, $08, $01, $01, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $0e, $14, $8b, $6a, $73, $69, $e2, $e3, $ea, $eb
	db $e2, $e3, $ea, $eb, $e2, $e3, $ea, $eb, $e2, $e3, $ea, $eb, $e2, $e3, $ea, $eb
	db $eb, $fc, $fc, $fc, $fc, $fc, $d0, $d8, $d2, $da, $d4, $dc, $d6, $de, $fc, $fc
	db $fc, $fc, $fc, $e2, $ea, $fc, $fc, $fc, $fc, $fc, $d1, $d9, $d3, $db, $d5, $dd
	db $d7, $df, $fc, $fc, $fc, $fc, $fc, $e3, $e3, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $ea, $e2, $fc, $fc, $82
	db $8a, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $80, $88, $fc, $eb
	db $eb, $fc, $fc, $83, $8b, $fc, $9b, $fc, $9c, $fc, $9d, $fc, $9e, $fc, $9f, $fc
	db $81, $89, $fc, $e2, $ea, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $e3, $e3, $fc, $fc, $fc, $fc, $fc, $fc, $b2
	db $ba, $fc, $fc, $b0, $b8, $fc, $fc, $fc, $fc, $fc, $fc, $ea, $e2, $fc, $fc, $fc
	db $fc, $fc, $fc, $b3, $bb, $fc, $fc, $b1, $b9, $fc, $fc, $fc, $fc, $fc, $fc, $eb
	db $eb, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $e2, $ea, $fc, $fc, $c2, $ca, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $c2, $ca, $fc, $e3, $e3, $fc, $fc, $c3, $cb, $fc, $9b, $fc
	db $9c, $fc, $9d, $fc, $9e, $fc, $9f, $fc, $c3, $cb, $fc, $ea, $e2, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $eb
	db $eb, $ea, $e3, $e2, $eb, $ea, $e3, $e2, $eb, $ea, $e3, $e2, $eb, $ea, $e3, $e2
	db $eb, $ea, $e3, $e2, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $08, $08, $08, $08, $08, $01, $01
	db $01, $01, $01, $01, $01, $01, $08, $08, $08, $08, $08, $01, $01, $08, $08, $08
	db $08, $08, $01, $01, $01, $01, $01, $01, $01, $01, $08, $08, $08, $08, $08, $01
	db $01, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $01, $01, $08, $08, $01, $01, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $01, $01, $08, $01, $01, $08, $08, $01, $01, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08, $01, $01, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01
	db $01, $08, $08, $08, $08, $08, $08, $01, $01, $08, $08, $01, $01, $08, $08, $08
	db $08, $08, $08, $01, $01, $08, $08, $08, $08, $08, $08, $01, $01, $08, $08, $01
	db $01, $08, $08, $08, $08, $08, $08, $01, $01, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08, $08, $01
	db $01, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08, $01
	db $01, $08, $08, $01, $01, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $01, $01, $08, $01, $01, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $0e, $14, $c1, $6c
	db $a9, $6b, $e2, $e3, $ea, $eb, $e2, $e3, $ea, $eb, $e2, $e3, $ea, $eb, $e2, $e3
	db $ea, $eb, $e2, $e3, $ea, $eb, $eb, $fc, $fc, $fc, $fc, $fc, $d0, $d8, $d2, $da
	db $d4, $dc, $d6, $de, $fc, $fc, $fc, $fc, $fc, $e2, $ea, $fc, $fc, $fc, $fc, $fc
	db $d1, $d9, $d3, $db, $d5, $dd, $d7, $df, $fc, $fc, $fc, $fc, $fc, $e3, $e3, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $ea, $e2, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $eb, $eb, $fc, $fc, $fc, $fc, $b2, $ba, $fc, $b0, $b8
	db $fc, $a4, $ac, $fc, $a6, $ae, $fc, $fc, $fc, $e2, $ea, $fc, $fc, $fc, $fc, $b3
	db $bb, $fc, $b1, $b9, $fc, $a5, $ad, $fc, $a7, $af, $fc, $fc, $fc, $e3, $e3, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $ea, $e2, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $eb, $eb, $fc, $fc, $c2, $ca, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $c2, $ca, $fc, $e2, $ea, $fc, $fc, $c3, $cb, $fc
	db $9b, $fc, $9c, $fc, $9d, $fc, $9e, $fc, $9f, $fc, $c3, $cb, $fc, $e3, $e3, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $ea, $e2, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $eb, $eb, $ea, $e3, $e2, $eb, $ea, $e3, $e2, $eb, $ea
	db $e3, $e2, $eb, $ea, $e3, $e2, $eb, $ea, $e3, $e2, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $08
	db $08, $08, $08, $08, $01, $01, $01, $01, $01, $01, $01, $01, $08, $08, $08, $08
	db $08, $01, $01, $08, $08, $08, $08, $08, $01, $01, $01, $01, $01, $01, $01, $01
	db $08, $08, $08, $08, $08, $01, $01, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08
	db $08, $08, $08, $01, $01, $08, $01, $01, $08, $01, $01, $08, $01, $01, $08, $08
	db $08, $01, $01, $08, $08, $08, $08, $01, $01, $08, $01, $01, $08, $01, $01, $08
	db $01, $01, $08, $08, $08, $01, $01, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08
	db $08, $01, $01, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01
	db $08, $01, $01, $08, $08, $01, $01, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $01, $01, $08, $01, $01, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $0e, $14, $f7, $6e, $df, $6d, $e2, $e3, $ea, $eb, $e2, $e3, $ea, $eb
	db $e2, $e3, $ea, $eb, $e2, $e3, $ea, $eb, $e2, $e3, $ea, $eb, $eb, $fc, $fc, $fc
	db $fc, $fc, $d0, $d8, $d2, $da, $d4, $dc, $d6, $de, $fc, $fc, $fc, $fc, $fc, $e2
	db $ea, $fc, $fc, $fc, $fc, $fc, $d1, $d9, $d3, $db, $d5, $dd, $d7, $df, $fc, $fc
	db $fc, $fc, $fc, $e3, $e3, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $ea, $e2, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $eb, $eb, $fc, $fc, $82
	db $8a, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $80, $88, $fc, $e2
	db $ea, $fc, $fc, $83, $8b, $fc, $9b, $fc, $9c, $fc, $9d, $fc, $9e, $fc, $9f, $fc
	db $81, $89, $fc, $e3, $e3, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $ea, $e2, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $eb, $eb, $fc, $fc, $fc
	db $fc, $b2, $ba, $fc, $b0, $b8, $fc, $a4, $ac, $fc, $a6, $ae, $fc, $fc, $fc, $e2
	db $ea, $fc, $fc, $fc, $fc, $b3, $bb, $fc, $b1, $b9, $fc, $a5, $ad, $fc, $a7, $af
	db $fc, $fc, $fc, $e3, $e3, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $ea, $e2, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $eb, $eb, $ea, $e3, $e2
	db $eb, $ea, $e3, $e2, $eb, $ea, $e3, $e2, $eb, $ea, $e3, $e2, $eb, $ea, $e3, $e2
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $08, $08, $08, $08, $08, $01, $01, $01, $01, $01, $01
	db $01, $01, $08, $08, $08, $08, $08, $01, $01, $08, $08, $08, $08, $08, $01, $01
	db $01, $01, $01, $01, $01, $01, $08, $08, $08, $08, $08, $01, $01, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01
	db $01, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $01, $01, $08, $08, $01, $01, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $01, $01, $08, $01, $01, $08, $08, $01, $01, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08, $01, $01, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01
	db $01, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $01, $01, $08, $08, $08, $08, $01, $01, $08, $01, $01, $08, $01
	db $01, $08, $01, $01, $08, $08, $08, $01, $01, $08, $08, $08, $08, $01, $01, $08
	db $01, $01, $08, $01, $01, $08, $01, $01, $08, $08, $08, $01, $01, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01
	db $01, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $0e, $14, $2d, $71, $15, $70, $e2, $e3
	db $ea, $eb, $e2, $e3, $ea, $eb, $e2, $e3, $ea, $eb, $e2, $e3, $ea, $eb, $e2, $e3
	db $ea, $eb, $eb, $fc, $fc, $fc, $fc, $fc, $d0, $d8, $d2, $da, $d4, $dc, $d6, $de
	db $fc, $fc, $fc, $fc, $fc, $e2, $ea, $fc, $fc, $fc, $fc, $fc, $d1, $d9, $d3, $db
	db $d5, $dd, $d7, $df, $fc, $fc, $fc, $fc, $fc, $e3, $e3, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $ea, $e2, $fc
	db $fc, $82, $8a, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $80, $88
	db $fc, $eb, $eb, $fc, $fc, $83, $8b, $fc, $9b, $fc, $9c, $fc, $9d, $fc, $9e, $fc
	db $9f, $fc, $81, $89, $fc, $e2, $ea, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $e3, $e3, $fc, $fc, $fc, $fc, $84
	db $8c, $fc, $90, $98, $fc, $92, $9a, $fc, $86, $8e, $fc, $fc, $fc, $ea, $e2, $fc
	db $fc, $fc, $fc, $85, $8d, $fc, $91, $99, $fc, $93, $9b, $fc, $87, $8f, $fc, $fc
	db $fc, $eb, $eb, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $e2, $ea, $fc, $fc, $fc, $fc, $94, $9c, $fc, $a0, $a8
	db $fc, $96, $9e, $fc, $a2, $aa, $fc, $fc, $fc, $e3, $e3, $fc, $fc, $fc, $fc, $95
	db $9d, $fc, $a1, $a9, $fc, $97, $9f, $fc, $a3, $ab, $fc, $fc, $fc, $ea, $e2, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $eb, $eb, $ea, $e3, $e2, $eb, $ea, $e3, $e2, $eb, $ea, $e3, $e2, $eb, $ea
	db $e3, $e2, $eb, $ea, $e3, $e2, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $08, $08, $08, $08, $08
	db $01, $01, $01, $01, $01, $01, $01, $01, $08, $08, $08, $08, $08, $01, $01, $08
	db $08, $08, $08, $08, $01, $01, $01, $01, $01, $01, $01, $01, $08, $08, $08, $08
	db $08, $01, $01, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $01, $01, $08, $08, $01, $01, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $01, $01, $08, $01, $01, $08, $08, $01, $01, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08, $01, $01, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $01, $01, $08, $08, $08, $08, $01, $01, $08, $01, $01, $08, $01, $01, $08
	db $01, $01, $08, $08, $08, $01, $01, $08, $08, $08, $08, $01, $01, $08, $01, $01
	db $08, $01, $01, $08, $01, $01, $08, $08, $08, $01, $01, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08
	db $08, $08, $08, $01, $01, $08, $01, $01, $08, $01, $01, $08, $01, $01, $08, $08
	db $08, $01, $01, $08, $08, $08, $08, $01, $01, $08, $01, $01, $08, $01, $01, $08
	db $01, $01, $08, $08, $08, $01, $01, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $0e, $14
	db $63, $73, $4b, $72, $e2, $e3, $ea, $eb, $e2, $e3, $ea, $eb, $e2, $e3, $ea, $eb
	db $e2, $e3, $ea, $eb, $e2, $e3, $ea, $eb, $eb, $e0, $e8, $fc, $fc, $fc, $d0, $d8
	db $d2, $da, $d4, $dc, $d6, $de, $fc, $fc, $fc, $fc, $fc, $e2, $ea, $e1, $e9, $fc
	db $fc, $fc, $d1, $d9, $d3, $db, $d5, $dd, $d7, $df, $fc, $fc, $fc, $fc, $fc, $e3
	db $e3, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $ea, $e2, $fc, $fc, $c6, $ce, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $c4, $cc, $fc, $eb, $eb, $fc, $fc, $c7, $cf, $fc, $9b, $fc
	db $9c, $fc, $9d, $fc, $9e, $fc, $9f, $fc, $c5, $cd, $fc, $e2, $ea, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $e3
	db $e3, $fc, $fc, $fc, $fc, $c0, $c8, $fc, $fc, $b6, $be, $fc, $fc, $b4, $bc, $fc
	db $fc, $fc, $fc, $ea, $e2, $fc, $fc, $fc, $fc, $c1, $c9, $fc, $fc, $b7, $bf, $fc
	db $fc, $b5, $bd, $fc, $fc, $fc, $fc, $eb, $eb, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $e2, $ea, $fc, $fc, $82
	db $8a, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $80, $88, $fc, $e3
	db $e3, $fc, $fc, $83, $8b, $fc, $9b, $fc, $9c, $fc, $9d, $fc, $9e, $fc, $9f, $fc
	db $81, $89, $fc, $ea, $e2, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $eb, $eb, $ea, $e3, $e2, $eb, $ea, $e3, $e2
	db $eb, $ea, $e3, $e2, $eb, $ea, $e3, $e2, $eb, $ea, $e3, $e2, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $00, $00, $08, $08, $08, $01, $01, $01, $01, $01, $01, $01, $01, $08, $08
	db $08, $08, $08, $01, $01, $00, $00, $08, $08, $08, $01, $01, $01, $01, $01, $01
	db $01, $01, $08, $08, $08, $08, $08, $01, $01, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08, $08, $01
	db $01, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08, $01
	db $01, $08, $08, $01, $01, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $01, $01, $08, $01, $01, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $01, $01, $08, $08, $08, $08, $01, $01, $08
	db $08, $01, $01, $08, $08, $01, $01, $08, $08, $08, $08, $01, $01, $08, $08, $08
	db $08, $01, $01, $08, $08, $01, $01, $08, $08, $01, $01, $08, $08, $08, $08, $01
	db $01, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $01, $01, $08, $08, $01, $01, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $01, $01, $08, $01, $01, $08, $08, $01, $01, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08, $01, $01, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $0e, $14, $99, $75, $81, $74, $e2, $e3, $ea, $eb, $e2, $e3
	db $ea, $eb, $e2, $e3, $ea, $eb, $e2, $e3, $ea, $eb, $e2, $e3, $ea, $eb, $eb, $e0
	db $e8, $fc, $fc, $fc, $d0, $d8, $d2, $da, $d4, $dc, $d6, $de, $fc, $fc, $fc, $fc
	db $fc, $e2, $ea, $e1, $e9, $fc, $fc, $fc, $d1, $d9, $d3, $db, $d5, $dd, $d7, $df
	db $fc, $fc, $fc, $fc, $fc, $e3, $e3, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $ea, $e2, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $eb, $eb, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $e2, $ea, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $e3, $e3, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $ea, $e2, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $eb, $eb, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $e2, $ea, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $e3, $e3, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $ea, $e2, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $eb, $eb, $ea
	db $e3, $e2, $eb, $ea, $e3, $e2, $eb, $ea, $e3, $e2, $eb, $ea, $e3, $e2, $eb, $ea
	db $e3, $e2, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $00, $00, $08, $08, $08, $01, $01, $01, $01
	db $01, $01, $01, $01, $08, $08, $08, $08, $08, $01, $01, $00, $00, $08, $08, $08
	db $01, $01, $01, $01, $01, $01, $01, $01, $08, $08, $08, $08, $08, $01, $01, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $01, $01, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $01, $01, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $01, $01, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $01, $01, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $01, $01, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01

SECTION "analyzed_044000", ROMX[$4000], BANK[$11]

Func_11_4000:
	ld a, $01
	ld [wMenuCursor], a
	ld a, [$c4cd]
	ld c, a
	call LoadFloorMonsterSprite
	ld a, $02
	ld [wMenuCursor], a
	ld a, [$c4ce]
	ld c, a
	call LoadFloorMonsterSprite
	ld a, $03
	ld [wMenuCursor], a
	ld a, [$c4cf]
	ld c, a
	call LoadFloorMonsterSprite
	ld a, $04
	ld [wMenuCursor], a
	ld a, [$c4d0]
	ld c, a
	call LoadFloorMonsterSprite
	ret
Func_11_4031:
	ld c, $00
	ld hl, $c4cd
Func_11_4036:
	push hl
	push bc
	ld a, [hl]
	add a, a
	add a, a
	add a, a
	ld hl, FloorMonsterSpritePalettes
	rst AddAToHL
	ld a, c
	add a, $04
	call LoadObjPalette
	pop bc
	pop hl
	inc hl
	inc c
	ld a, $04
	cp c
	jr nz, Func_11_4036
	ret
; Upload floor-monster species C's sprite (32 tiles, 4x8 column-major from
; FloorMonsterSprites + C*$300) to VRAM bank 1 and load its OBJ palette from
; FloorMonsterSpritePalettes + C*8 into slot [wMenuCursor]+3. C is a MONSTER enum value
; (include/monster.inc). See docs/gfx_loaders.md for the rendered roster.
LoadFloorMonsterSprite:
	ld a, c
	add a, a
	push af
	add a, c
	ld hl, FloorMonsterSprites
	add a, h
	ld h, a
	ld a, [wMenuCursor]
	dec a
	add a, a
	ld de, $8000
	add a, d
	ld d, a
	ld a, $01
	ld [rVBK], a
	ld bc, $0200
	call VramCopy16
	pop af
	add a, a
	add a, a
	ld hl, FloorMonsterSpritePalettes
	rst AddAToHL
	ld a, [wMenuCursor]
	add a, $03
	call LoadObjPalette
	call Func_00_0786
	ret
Func_11_4081:
	push bc
	ld hl, $40ef
	ld c, b
	ld b, $00
	sla c
	rl b
	add hl, bc
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	pop bc
	ld b, $00
	push hl
	ld hl, $40e3
	add hl, bc
	ld a, [hl]
	ld [rVBK], a
	pop hl
	push hl
	ld hl, $40e7
	sla c
	rl b
	add hl, bc
	ld a, [hl+]
	ld d, [hl]
	ld e, a
	pop hl
	ld bc, $0300
	call VramCopy16
	ret
Func_11_40b1:
	ld de, $c4cd
	ld c, $00
Func_11_40b6:
	ld a, [de]
	cp $ff
	jr z, Func_11_40c4
	ld a, [de]
	ld b, a
	push bc
	push de
	call Func_11_40cc
	pop de
	pop bc
Func_11_40c4:
	inc de
	inc c
	ld a, c
	cp $04
	jr nz, Func_11_40b6
	ret
Func_11_40cc:
	push bc
	ld hl, $4117
	ld c, b
	ld b, $00
	sla c
	rl b
	add hl, bc
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	pop bc
	ld a, c
	add a, $04
	call LoadObjPalette
	ret

Data_11_40e3:
	db $01, $01, $01, $00, $00, $80, $00, $83, $80, $8b, $00, $8d, $5c, $41, $5c, $44
	db $5c, $47, $5c, $4a, $5c, $4d, $5c, $50, $5c, $53, $5c, $56, $5c, $59, $5c, $5c
	db $5c, $5f, $5c, $62, $5c, $65

Data_11_4109:
	db $5c, $68

Data_11_410b:
	db $5c, $6b, $5c, $6e, $5c, $71, $5c, $74, $5c, $77, $5c, $7a, $5c, $7d, $64, $7d
	db $6c, $7d, $74, $7d, $7c, $7d, $84, $7d, $8c, $7d, $94, $7d, $9c, $7d, $a4, $7d
	db $ac, $7d, $b4, $7d, $bc, $7d

Data_11_4131:
	db $c4, $7d

Data_11_4133:
	db $cc, $7d, $d4, $7d, $dc, $7d, $e4, $7d, $ec, $7d, $f4, $7d, $07, $08, $08, $0c
	db $01, $08, $88, $0e, $01, $08, $90, $0e, $21, $00, $8c, $06, $01, $58, $8c, $06
	db $41, $f0, $80, $00, $21, $f0, $98, $00, $01

; Floor-monster sprite tiles, $300 bytes (32 used) per MONSTER species, indexed by
; LoadFloorMonsterSprite. 20 species ($415c..$7d5b): Tacopi, Jell, Naga, Dino,
; Plant, Henger, Joker, Ghost, Puncho, Psylora, Ducken, FlameRed, FlameBlue,
; (#13 unused), Tiger, Mocchi, Hare, Gali, Golem, Suezo. The blob is split across
; the Data_11_* sheets below (analyzer fragmentation). See docs/gfx_loaders.md.
FloorMonsterSprites:
	INCBIN "raw_gfx/Data_11_415c.2bpp", 0, 2304

Data_11_4a5c:
	db $00, $00, $00, $00, $18, $00, $30, $08, $61, $10, $c1, $20, $c3, $20, $c6, $31
	db $64, $1b, $7d, $02, $38, $07, $18, $07, $18, $07, $31, $0e, $60, $18, $33, $0f
	db $18, $04, $30, $08, $60, $10, $40, $20, $c1, $20, $c1, $20, $c3, $30, $ce, $31
	db $c6, $39, $60, $1f, $39, $06, $0f, $00, $01, $00, $03, $00, $02, $01, $01, $00
	db $00, $00, $00, $00, $18, $00, $30, $08, $60, $10, $c1, $20, $81, $60, $82, $61
	db $8e, $71, $c0, $3f, $61, $1e, $3f, $00, $0f, $00, $1e, $00, $38, $00, $1e, $02
	db $00, $00, $1a, $01, $36, $09, $64, $13, $c4, $23, $c4, $23, $c2, $21, $c3, $20
	db $c6, $31, $cd, $32, $60, $1f, $38, $07, $18, $07, $11, $0e, $20, $18, $13, $0f
	db $00, $00, $00, $00, $60, $1c, $98, $7e, $0c, $ff, $00, $ff, $40, $be, $e0, $00
	db $60, $80, $00, $fc, $ec, $1c, $fc, $60, $fc, $40, $78, $00, $e0, $00, $7c, $04
	db $00, $00, $40, $3c, $d8, $3e, $8c, $7f, $80, $7f, $40, $be, $60, $80, $20, $c0
	db $80, $7c, $6c, $9c, $18, $e0, $80, $78, $80, $78, $00, $f0, $00, $80, $30, $f0
	db $00, $00, $00, $00, $40, $3c, $98, $7e, $8c, $7f, $40, $bf, $60, $9e, $60, $80
	db $80, $70, $40, $be, $36, $ce, $8c, $70, $e0, $1c, $40, $38, $80, $60, $4c, $3c
	db $00, $00, $00, $e0, $c0, $f0, $60, $f8, $00, $f8, $00, $f0, $e0, $00, $60, $80
	db $80, $7c, $6c, $9c, $fc, $60, $fc, $40, $fc, $00, $78, $00, $e0, $00, $7c, $04
	db $00, $00, $00, $00, $0c, $02, $10, $0c, $20, $18, $61, $10, $c3, $20, $86, $61
	db $9c, $63, $ca, $35, $71, $0e, $31, $0e, $11, $0e, $22, $1c, $40, $30, $26, $1e
	db $00, $00, $00, $00, $00, $00, $01, $00, $c3, $f0, $06, $19, $0e, $31, $18, $67
	db $00, $7f, $02, $3d, $6f, $03, $ff, $01, $9f, $00, $8f, $82, $04, $07, $00, $00
	db $00, $00, $01, $00, $03, $00, $02, $01, $06, $01, $06, $01, $07, $30, $06, $79
	db $00, $df, $10, $8f, $98, $87, $8f, $81, $01, $00, $01, $00, $01, $01, $01, $01
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, $00, $04, $03
	db $08, $07, $0d, $02, $18, $07, $30, $0f, $70, $0f, $e3, $1c, $fc, $0f, $d3, $cc
	db $00, $00, $00, $00, $00, $00, $60, $1c, $d8, $3e, $8c, $7f, $40, $bf, $60, $9e
	db $f8, $00, $78, $80, $1c, $e0, $7c, $e0, $fc, $00, $78, $00, $e0, $00, $7c, $04
	db $00, $00, $00, $00, $c0, $30, $00, $f8, $00, $d8, $00, $8c, $00, $c4, $20, $c0
	db $30, $cc, $40, $be, $8c, $7f, $ae, $5f, $a6, $5f, $00, $cf, $00, $86, $00, $00
	db $c0, $38, $80, $7c, $00, $c4, $00, $80, $00, $80, $00, $80, $00, $c0, $20, $c0
	db $38, $c4, $00, $fe, $80, $7f, $a4, $5f, $b2, $4f, $00, $cf, $00, $c6, $00, $80
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $c0, $00, $e0, $00
	db $e0, $10, $30, $00, $20, $98, $c0, $3e, $14, $ff, $c8, $3f, $54, $bf, $a0, $1e
	db $00, $00, $00, $00, $00, $00, $00, $07, $01, $1e, $0f, $73, $1f, $7f, $0f, $37
	db $07, $1b, $07, $0b, $03, $05, $01, $06, $00, $03, $00, $00, $00, $00, $00, $00
	db $00, $01, $01, $06, $03, $0d, $07, $0b, $0f, $17, $0f, $37, $1f, $6e, $3f, $fe
	db $1f, $e7, $03, $3c, $00, $0f, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $78, $60, $98, $e0, $10, $c0, $b0, $c0, $00, $80, $70
	db $f0, $c8, $f0, $fc, $f0, $e8, $e0, $90, $80, $60, $00, $80, $00, $00, $00, $00
	db $00, $e0, $c0, $38, $e0, $dc, $f8, $f6, $fc, $fa, $3c, $cf, $8e, $75, $e0, $1f
	db $e0, $d9, $f0, $6c, $38, $f6, $1c, $fa, $1c, $6a, $1c, $2a, $18, $34, $00, $78
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

Data_11_4d5c:
	INCBIN "raw_gfx/Data_11_4d5c.2bpp", 0, 3072

Data_11_595c:
	db $00, $00, $00, $00, $00, $00, $04, $00, $0c, $00, $0f, $00, $1f, $03, $1f, $04
	db $1f, $04, $1f, $07, $1f, $03, $3f, $30, $0f, $00, $0f, $00, $07, $00, $06, $06
	db $00, $00, $00, $00, $04, $00, $0c, $00, $0f, $00, $1f, $03, $1f, $04, $1f, $04
	db $1f, $07, $1f, $03, $3f, $30, $0f, $00, $0f, $00, $1f, $18, $0c, $0c, $00, $00
	db $00, $00, $00, $00, $04, $00, $0c, $00, $0f, $00, $1f, $03, $1f, $04, $1f, $04
	db $1f, $07, $1f, $03, $3f, $30, $0f, $00, $0f, $00, $07, $03, $06, $06, $00, $00
	db $00, $00, $00, $00, $00, $00, $02, $00, $07, $00, $0f, $00, $1f, $00, $1f, $01
	db $3f, $01, $3f, $01, $3f, $00, $3f, $00, $3f, $00, $1f, $00, $0e, $01, $06, $06
	db $00, $00, $00, $00, $00, $00, $40, $00, $20, $00, $e0, $00, $f0, $e0, $f0, $c0
	db $f0, $c0, $b0, $f0, $f0, $e0, $f8, $08, $e0, $10, $e0, $10, $c0, $20, $60, $60
	db $00, $00, $00, $00, $40, $00, $20, $00, $e0, $00, $f0, $e0, $f0, $c0, $f0, $c0
	db $b0, $f0, $f0, $e0, $f8, $08, $e0, $10, $e0, $10, $d8, $38, $30, $30, $00, $00
	db $00, $00, $00, $00, $40, $00, $20, $00, $e0, $00, $f0, $e0, $f0, $c0, $f0, $c0
	db $b0, $f0, $f0, $e0, $f8, $08, $e0, $10, $e0, $10, $c0, $20, $c0, $c0, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $c0, $00, $c0, $c0, $e0, $20
	db $e0, $20, $c0, $e0, $c0, $c0, $c0, $0e, $c0, $5f, $60, $bf, $00, $1f, $00, $0e
	db $00, $03, $00, $77, $07, $f8, $3c, $c3, $4c, $b3, $4f, $b0, $5f, $a0, $3f, $40
	db $1f, $20, $5f, $20, $7f, $20, $5f, $30, $2f, $10, $2f, $10, $1f, $0c, $0f, $06
	db $00, $07, $04, $6b, $0f, $f0, $3f, $c0, $5f, $a7, $5f, $a9, $5f, $a9, $3e, $6f
	db $3e, $37, $4c, $33, $4c, $33, $4c, $33, $2c, $13, $26, $19, $16, $09, $0d, $00
	db $00, $03, $00, $01, $00, $00, $33, $08, $66, $19, $4e, $31, $4c, $33, $4c, $33
	db $4c, $33, $4c, $33, $4c, $33, $4c, $33, $2c, $13, $26, $19, $16, $09, $0d, $00
	db $00, $00, $0f, $00, $30, $0f, $40, $3f, $9f, $60, $ff, $00, $60, $1f, $80, $7f
	db $00, $ff, $00, $7f, $e7, $1f, $7f, $80, $1f, $60, $00, $3f, $03, $0f, $00, $00
	db $00, $c0, $00, $ee, $e0, $1f, $5c, $a3, $22, $dd, $e2, $1d, $f2, $1d, $f4, $3a
	db $f8, $34, $fa, $16, $f8, $0e, $f8, $16, $f8, $04, $f0, $0c, $f0, $c8, $60, $f0
	db $00, $e0, $20, $d6, $f0, $0f, $fc, $03, $fa, $e5, $fa, $95, $fa, $95, $7c, $f6
	db $7c, $ec, $3a, $e6, $38, $e6, $18, $e6, $18, $e4, $30, $cc, $30, $c8, $20, $90
	db $00, $00, $00, $80, $00, $80, $00, $dc, $34, $ce, $52, $ee, $3a, $e6, $3a, $e6
	db $3a, $e6, $3a, $e6, $38, $e6, $18, $e6, $18, $e4, $30, $cc, $30, $c8, $20, $90
	db $00, $00, $f0, $00, $18, $e0, $08, $f0, $e0, $18, $f0, $00, $38, $c1, $08, $f3
	db $00, $fe, $20, $f8, $d0, $e0, $f0, $08, $c0, $38, $10, $f8, $e0, $f0, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

Data_11_5c5c:
	INCBIN "raw_gfx/Data_11_5c5c.2bpp", 0, 3072

Data_11_685c:
	db $00, $00, $00, $00, $00, $00, $7f, $7f, $92, $92, $92, $92, $92, $92, $92, $92
	db $e0, $ff, $c0, $ff, $c0, $ff, $c0, $ff, $7f, $00, $1e, $1f, $0c, $0f, $00, $03
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $fe, $fe, $49, $49, $49, $49, $49, $49, $49, $49
	db $07, $f8, $03, $fc, $03, $fc, $03, $fc, $fe, $00, $38, $c0, $70, $80, $c0

SECTION "analyzed_046b5c", ROMX[$6b5c], BANK[$11]

Data_11_6b5c:
	INCBIN "raw_gfx/Data_11_6b5c.2bpp", 0, 768

Data_11_6e5c:
	db $00, $00, $00, $00, $07, $00, $0f, $03, $0f, $06, $0f, $06, $0f, $07, $0f, $07
	db $0f, $07, $0f, $07, $0f, $0f, $1f, $1f, $1f, $1b, $0f, $03, $0f, $03, $07, $07
	db $00, $00, $07, $00, $0f, $03, $0f, $06, $0f, $06, $0f, $07, $0f, $07, $0f, $07
	db $0f, $0f, $3f, $3f, $1f, $1b, $0f, $03, $0f, $07, $0f, $0f, $1e, $1e, $0f, $0f
	db $00, $00, $07, $00, $0f, $03, $0f, $06, $0f, $06, $0f, $07, $0f, $07, $0f, $07
	db $0f, $0f, $3f, $3f, $1f, $1b, $07, $03, $03, $07, $01, $0f, $01, $1e, $00, $0e
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0f, $00, $1f, $0e
	db $3f, $1f, $3f, $1f, $3f, $1f, $3f, $1f, $1f, $0f, $0f, $07, $07, $07, $0f, $0f
	db $00, $00, $00, $00, $e0, $00, $f0, $80, $f0, $40, $f0, $70, $80, $f8, $c0, $f0
	db $e0, $e0, $f0, $f0, $f8, $f8, $f8, $f8, $f8, $f8, $e0, $f0, $80, $e0, $c0, $f8
	db $00, $00, $e0, $00, $f0, $80, $f0, $40, $f0, $70, $80, $f8, $c0, $f0, $f0, $f0
	db $f8, $f8, $f8, $f8, $f8, $f8, $f0, $f9, $e0, $ff, $00, $1e, $00, $0c, $00, $00
	db $00, $00, $e0, $00, $f0, $80, $f0, $40, $f0, $70, $80, $f8, $c0, $f0, $f0, $f0
	db $f8, $f8, $f8, $f8, $f8, $f8, $d0, $f0, $e4, $e4, $fc, $fc, $78, $78, $30, $30
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $e0, $00, $f0, $00
	db $f8, $08, $f8, $f8, $f8, $f8, $f8, $f8, $f0, $f0, $80, $e0, $00, $c0, $80, $f0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $0f, $00, $1f, $0e, $3f, $1f, $3f, $1f, $3f, $1f, $3f, $1f, $1f, $1f, $0f, $0f
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $07, $00, $0f, $0e, $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f, $0f, $0f
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $07, $07, $0f, $0f, $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f, $0f, $0f, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $0f, $00, $1f, $0e, $3f, $1f, $3f, $1f, $3f, $1d, $1f, $1e, $0f, $0d
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $e0, $00, $f0, $00, $f8, $08, $f8, $88, $fc, $fc, $fc, $fc, $fc, $fc, $f8, $f8
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $e0, $00, $f8, $08, $fc, $04, $fc, $80, $fc, $80, $fc, $80, $fc, $04, $f8, $08
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $f0, $f0, $f8, $f8, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $cc, $fc, $04, $f8, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $e0, $00, $f0, $00, $f8, $08, $f8, $88, $fc, $68, $fc, $f4, $fc, $68
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $0c, $01, $1e, $00, $3b, $41, $36, $e1, $0e, $c3, $07, $00, $03
	db $02, $1d, $05, $3f, $0b, $3d, $17, $3b, $0b, $17, $01, $07, $01, $0e, $0e, $0e
	db $00, $0c, $01, $1e, $00, $3b, $41, $36, $e1, $0e, $c3, $07, $00, $03, $01, $0e
	db $02, $1f, $05, $1e, $0b, $1d, $04, $0b, $1c, $03, $3e, $01, $3c, $00, $1e, $00
	db $00, $0c, $01, $1e, $00, $3b, $41, $36, $e1, $0e, $c3, $07, $00, $03, $01, $0e
	db $02, $1f, $05, $1e, $0b, $1d, $05, $0b, $00, $0f, $00, $3e, $00, $3c, $18, $38
	db $00, $00, $01, $18, $03, $3c, $08, $37, $52, $2d, $63, $1d, $67, $0f, $01, $07
	db $18, $07, $3e, $07, $3f, $0f, $1c, $0f, $0c, $0b, $06, $05, $0f, $00, $1f, $1c
	db $00, $00, $e0, $00, $f0, $00, $10, $c0, $00, $e0, $e0, $a0, $e0, $e0, $c0, $c0
	db $00, $dc, $50, $de, $e8, $de, $f4, $ce, $c0, $c0, $c0, $80, $e0, $00, $f0, $30
	db $e0, $00, $f0, $00, $10, $c0, $00, $e0, $e0, $a0, $e0, $e0, $c0, $dc, $10, $de
	db $a8, $fe, $f4, $8e, $fc, $38, $c0, $38, $00, $f8, $80, $70, $00, $e0, $00, $00
	db $e0, $00, $f0, $00, $10, $c0, $00, $e0, $e0, $a0, $e0, $e0, $c0, $dc, $10, $de
	db $a8, $fe, $f4, $ee, $ec, $e0, $f4, $e4, $fe, $c2, $3e, $00, $1c, $00, $18, $00
	db $00, $00, $c0, $00, $e0, $00, $20, $80, $00, $c0, $80, $40, $c0, $c0, $80, $70
	db $c0, $78, $a0, $78, $50, $b8, $30, $c0, $00, $e0, $00, $e0, $00, $c0, $00, $00
	db $00, $00, $00, $03, $00, $07, $00, $0e, $10, $0d, $38, $03, $30, $01, $00, $00
	db $01, $02, $00, $1b, $00, $1f, $00, $07, $00, $07, $00, $1f, $00, $1c, $0e, $0e
	db $00, $00, $00, $33, $00, $f7, $88, $fd, $03, $38, $03, $1c, $03, $0c, $e1, $e6
	db $c0, $e7, $80, $f3, $00, $0f, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $02, $03, $00, $38, $80, $f8, $00, $19, $00, $1b, $00, $0f, $00, $07, $00, $07
	db $e0, $e7, $c0, $e3, $80, $f1, $00, $0f, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $01, $00, $03, $01, $46, $0f, $e0, $0e, $f1, $87, $ff, $8f, $bf
	db $00, $00, $38, $00, $7c, $80, $04, $e0, $20, $d0, $2c, $d8, $f8, $f8, $30, $f0
	db $00, $ff, $e0, $0f, $68, $ef, $67, $e7, $f8, $e0, $f8, $c0, $70, $00, $3c, $0c
	db $00, $00, $00, $00, $00, $00, $1c, $00, $9c, $02, $d8, $06, $00, $c6, $00, $e6
	db $8e, $60, $9f, $60, $41, $bc, $90, $6e, $10, $ee, $1e, $6a, $3c, $3c, $00, $00
	db $00, $80, $0c, $c0, $0e, $c0, $ee, $00, $f4, $02, $e0, $16, $40, $b6, $40, $b6
	db $4e, $b0, $5f, $a0, $41, $bc, $80, $7e, $10, $ee, $0e, $7a, $3c, $3c, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $1c, $80, $3e, $c0, $aa, $50, $10, $e8, $2e, $d4, $7d, $ff, $19, $ff, $83, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

Data_11_745c:
	INCBIN "raw_gfx/Data_11_745c.2bpp", 0, 2304

; One OBJ palette (4 RGB555 colors, $08 bytes) per floor-monster species, indexed
; by LoadFloorMonsterSprite (FloorMonsterSpritePalettes + MONSTER*8).
FloorMonsterSpritePalettes:
	db $00, $24, $34, $01, $bc, $01, $df, $7b, $00, $00, $00, $49, $46, $52, $1b, $24
	db $ef, $3d, $4a, $40, $12, $6c, $9a, $76, $12, $01, $40, $01, $e0, $01, $3f, $4b
	db $00, $00, $e5, $11, $7a, $01, $5e, $17, $00, $00, $6d, $19, $3b, $3f, $7a, $01
	db $00, $00, $29, $25, $31, $46, $19, $00, $00, $00, $2c, $39, $7a, $01, $7e, $4f
	db $00, $00, $47, $1e, $dd, $09, $9f, $1f, $00, $00, $60, $2d, $46, $52, $5e, $17
	db $00, $00, $4a, $29, $5e, $17, $de, $7b, $00, $00, $a2, $69, $1e, $05, $de, $7b
	db $00, $00, $a2, $69, $1e, $05, $de, $7b

Data_11_7dc4:
	db $12, $01, $08, $21, $31, $46, $5a, $6b

Data_11_7dcc:
	db $b0, $14, $c0, $40, $4f, $5e, $de, $7b, $88, $49, $80, $01, $74, $49, $5d, $5e
	db $e0, $01, $c9, $08, $f2, $01, $7d, $5b, $c0, $6d, $4a, $29, $d9, $16, $bd, $77
	db $88, $49, $08, $21, $73, $4e, $f7, $5e, $60, $01, $8b, $10, $b9, $02, $de, $7b

SECTION "analyzed_04c398", ROMX[$4398], BANK[$13]

Data_13_4398:
	db $26

SECTION "analyzed_04c399", ROMX[$4399], BANK[$13]

Func_13_4399:
	ld a, d
	rrca
	rrca
	rrca
	rrca
	and $03
	ld hl, $4395
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

SECTION "analyzed_04c3b6", ROMX[$43b6], BANK[$13]

Data_13_43b6:
	db $1a

SECTION "analyzed_04c3b7", ROMX[$43b7], BANK[$13]

Data_13_43b7:
	db $1c, $1a, $1c

Func_13_43ba:
	ld hl, $43b6
	ld a, d
	rrca
	rrca
	rrca
	rrca
	and $03
	call Func_13_4419
	ret

Data_13_43c8:
	db $12, $14, $12, $14

Func_13_43cc:
	ld hl, $43c8
	ld a, d
	rrca
	rrca
	rrca
	rrca
	and $03
	call Func_13_4406
	ret

Data_13_43da:
	db $00, $02, $00, $04

Func_13_43de:
	ld hl, $43da
	ld a, d
	rrca
	rrca
	rrca
	rrca
	and $03
	call Func_13_4406
	ret

Data_13_43ec:
	db $06, $10, $06, $18

Func_13_43f0:
	ld hl, $43ec
	ld a, d
	rrca
	rrca
	rrca
	rrca
	and $03
	cp $03
	jr z, Func_13_4402
	call Func_13_4406
	ret
Func_13_4402:
	call Func_13_4419
	ret
Func_13_4406:
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
Func_13_4419:
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

Data_13_442c:
	db $00, $00, $94, $52, $4a, $29, $ff, $7f

Func_13_4434:
	ld hl, $442c
	ld a, $07
	ld b, $01
	call Func_00_0716
	call Func_00_0786
	ret
Func_13_4442:
	call WaitForNextFrame
	dec d
	jr nz, Func_13_4442
	ret

SECTION "analyzed_04c884", ROMX[$4884], BANK[$13]

Data_13_4884:
	db $be, $48, $3b, $49, $3b, $49, $3b, $49, $ca, $48, $3b, $49, $d3, $48, $3b, $49
	db $dd, $48, $3b, $49, $e3, $48, $3b, $49, $ed, $48, $3b, $49, $f8, $48, $3b, $49
	db $02, $49, $3b, $49, $0c, $49, $3b, $49, $15, $49, $3b, $49, $20, $49, $3b, $49
	db $2a, $49, $3b, $49, $31, $49, $3b, $49, $00, $00, $53, $54, $41, $47, $45, $20
	db $53, $54, $41, $46, $46, $00, $48, $a5, $4d, $4f, $54, $4f, $4b, $49, $00, $52
	db $a5, $53, $48, $49, $4e, $41, $44, $41, $00, $59, $a5, $41, $42, $45, $00, $59
	db $a5, $54, $41, $4b, $41, $4f, $4b, $41, $00, $4a, $a5, $59, $41, $4d, $41, $4d
	db $4f, $54, $4f, $00, $4d, $a5, $48, $41, $59, $41, $53, $48, $49, $00, $54, $a5
	db $54, $53, $55, $54, $53, $55, $49, $00, $54, $a5, $4f, $48, $4d, $4f, $52, $49
	db $00, $4d, $a5, $53, $55, $47, $41, $4e, $55, $4d, $41, $00, $4d, $a5, $4e, $41
	db $47, $41, $55, $52, $41, $00, $59, $a5, $55, $45, $44, $41, $00, $54, $a5, $49
	db $4e, $41, $4d, $4f, $54, $4f, $00, $20, $20, $20, $20, $20, $20, $20, $20, $20
	db $20, $20, $00

Func_13_4947:
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
	ld hl, $4884
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, h
	cp $00
	jr nz, Func_13_496b
	ld hl, $493b
	jr Func_13_4972
Func_13_496b:
	ld a, [$cfbc]
	inc a
	ld [$cfbc], a
Func_13_4972:
	ld de, $9800
	ld a, c
	or a
	jr z, Func_13_497f
Func_13_4979:
	ld a, $20
	rst AddAToDE
	dec c
	jr nz, Func_13_4979
Func_13_497f:
	ld a, $02
	rst AddAToDE
Func_13_4982:
	ld a, [hl+]
	ld c, a
	or a
	jr z, Func_13_499e
	ld a, e
	ld [wTextCursor], a
	ld a, d
	ld [$d617], a
	push hl
	push de
	FAR_CALL $00, PrintCharacterAtCursor
	pop de
	pop hl
	inc de
	jr Func_13_4982
Func_13_499e:
	ret
Func_13_499f:
	ldh a, [rSCY]
	inc a
	ldh [rSCY], a
	ret
Func_13_49a5:
	ld de, $9862
	ld hl, $47ff
	ret
Func_13_49ac:
	ld a, e
	ld [wTextCursor], a
	ld a, d
	ld [$d617], a
	ld a, [hl+]
	ld c, a
	cp $ff
	jr z, Func_13_4a08
	cp $0d
	jr z, Func_13_49df
	cp $04
	jr z, Func_13_49e9
	cp $40
	jr z, Func_13_49d0
	cp $de
	jr z, Func_13_49d0
	cp $df
	jr z, Func_13_49d0
	jr Func_13_49d1

SECTION "analyzed_04c9d0", ROMX[$49d0], BANK[$13]

Func_13_49d0:
	dec de

SECTION "analyzed_04c9d1", ROMX[$49d1], BANK[$13]

Func_13_49d1:
	push hl
	push de
	FAR_CALL $00, PrintCharacterAtCursor
	pop de
	inc de
	pop hl
	ret
Func_13_49df:
	ld a, $40
	rst AddAToDE
	ld a, e
	and $e0
	add a, $02
	ld e, a
	ret
Func_13_49e9:
	dec hl
	ld a, [$cfbc]
	inc a
	ld [$cfbc], a
	cp $0d
	ret nz
	push hl
	ld hl, $5e8b
	ld de, $9800
	call CopyBgMap
	ld de, $9862
	pop hl
	inc hl
	xor a
	ld [$cfbc], a
	ret
Func_13_4a08:
	dec hl
	ld a, [$cfbc]
	inc a
	ld [$cfbc], a
	cp $0d
	ret nz
	xor a
	ld [wUiState], a
	ret
Func_13_4a18:
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
	jr z, Func_13_4a30
	ld d, $ec
	jr Func_13_4a32
Func_13_4a30:
	ld d, $fc
Func_13_4a32:
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

Data_13_4a45:
	db $07, $07, $08, $0f, $10, $1f, $20, $3f, $2f, $3f, $17, $1a, $1f, $12, $0e, $09
	db $17, $1c, $2b, $3f, $7b, $4e, $7d, $4f, $38, $3f, $08, $0f, $09, $0f, $07, $07
	db $00, $00, $07, $07, $08, $0f, $10, $1f, $20, $3f, $2f, $3f, $17, $1a, $1f, $12
	db $1e, $19, $37, $2c, $3b, $2f, $1d, $1f, $08, $0f, $08, $0f, $08, $0f, $07, $07
	db $00, $00, $07, $07, $08, $0f, $10, $1f, $20, $3f, $2f, $3f, $17, $1a, $1f, $12
	db $0e, $09, $07, $04, $3b, $3f, $7d, $4f, $78, $4f, $38, $3f, $07, $07, $01, $01
	db $07, $07, $08, $0f, $18, $1f, $28, $3f, $28, $3f, $23, $3f, $10, $1f, $0f, $0f
	db $13, $1f, $28, $3f, $78, $4f, $7c, $4f, $38, $3f, $08, $0f, $09, $0f, $07, $07
	db $e0, $e0, $10, $f0, $e8, $f8, $04, $fc, $f4, $fc, $e8, $58, $f8, $48, $70, $90
	db $e8, $38, $d4, $fc, $de, $72, $be, $f2, $1c, $fc, $10, $f0, $90, $f0, $e0, $e0
	db $00, $00, $e0, $e0, $10, $f0, $e8, $f8, $04, $fc, $f4, $fc, $e8, $58, $f8, $48
	db $70, $90, $e0, $20, $dc, $fc, $be, $f2, $1e, $f2, $1c, $fc, $e0, $e0, $80, $80
	db $00, $00, $e0, $e0, $10, $f0, $e8, $f8, $04, $fc, $f4, $fc, $e8, $58, $f8, $48
	db $78, $98, $ec, $34, $dc, $f4, $b8, $f8, $10, $f0, $10, $f0, $10, $f0, $e0, $e0
	db $e0, $e0, $10, $f0, $18, $f8, $14, $fc, $14, $fc, $c4, $fc, $08, $f8, $f0, $f0
	db $c8, $f8, $14, $fc, $1e, $f2, $3e, $f2, $1c, $fc, $10, $f0, $90, $f0, $e0, $e0
	db $00, $00, $07, $07, $08, $0f, $18, $1f, $28, $3f, $28, $3f, $23, $3f, $10, $1f
	db $1f, $1f, $37, $2f, $38, $2f, $1c, $1f, $08, $0f, $08, $0f, $08, $0f, $07, $07
	db $07, $07, $08, $0f, $1c, $1f, $20, $3f, $3e, $3f, $1f, $15, $1f, $14, $07, $18
	db $1f, $10, $0f, $0f, $07, $06, $07, $06, $05, $07, $04, $07, $04, $07, $03, $03
	db $00, $00, $07, $07, $08, $0f, $1c, $1f, $20, $3f, $3e, $3f, $1f, $15, $1f, $14
	db $07, $18, $1f, $10, $0f, $0f, $07, $04, $07, $07, $08, $0f, $08, $0f, $07, $07
	db $07, $07, $0d, $0a, $19, $16, $19, $16, $18, $17, $37, $2f, $4f, $7a, $3f, $32
	db $0f, $08, $07, $07, $19, $1e, $3c, $27, $3c, $27, $1b, $1f, $04, $07, $08, $0f
	db $00, $00, $e0, $e0, $10, $f0, $18, $f8, $14, $fc, $14, $fc, $c4, $fc, $08, $f8
	db $f0, $f0, $e0, $e0, $1c, $fc, $3e, $f2, $1e, $f2, $1c, $fc, $e0, $e0, $80, $80
	db $c0, $c0, $20, $e0, $10, $f0, $38, $f8, $08, $f8, $f8, $f8, $d0, $70, $d0, $70
	db $a0, $e0, $10, $f0, $d0, $70, $f0, $70, $90, $f0, $10, $f0, $10, $f0, $e0, $e0
	db $00, $00, $c0, $c0, $20, $e0, $10, $f0, $38, $f8, $08, $f8, $f8, $f8, $d0, $70
	db $d0, $70, $a0, $e0, $90, $f0, $b0, $f0, $10, $f0, $08, $f8, $88, $f8, $70, $70
	db $e0, $e0, $30, $d0, $18, $e8, $18, $e8, $18, $e8, $ec, $f4, $f2, $5e, $fc, $4c
	db $f0, $10, $e0, $e0, $18, $f8, $bc, $64, $7c, $a4, $d8, $f8, $20, $e0, $10, $f0
	db $00, $00, $07, $07, $0d, $0a, $19, $16, $19, $16, $18, $17, $37, $2f, $4f, $7a
	db $3f, $32, $1f, $18, $37, $2f, $31, $2e, $18, $1f, $08, $0f, $0b, $0f, $19, $1f
	db $00, $00, $07, $07, $0c, $0b, $18, $17, $18, $17, $18, $17, $37, $2f, $4f, $7a
	db $3f, $32, $0f, $08, $07, $07, $19, $1e, $3e, $27, $3c, $27, $1b, $1b, $00, $00
	db $03, $03, $06, $05, $0c, $0b, $0c, $0b, $18, $17, $27, $3f, $3f, $38, $0f, $0a
	db $0f, $0a, $07, $04, $03, $03, $01, $03, $03, $02, $03, $02, $01, $03, $01, $01
	db $00, $00, $03, $03, $06, $05, $0c, $0b, $0c, $0b, $18, $17, $27, $3f, $3f, $38
	db $0f, $0a, $0f, $0a, $07, $04, $03, $03, $00, $03, $01, $03, $01, $03, $00, $01
	db $00, $00, $e0, $e0, $30, $d0, $18, $e8, $18, $e8, $18, $e8, $ec, $f4, $f2, $5e
	db $fc, $4c, $f0, $10, $e0, $e0, $18, $f8, $fc, $64, $7c, $a4, $d8, $d8, $00, $00
	db $00, $00, $e0, $e0, $b0, $50, $98, $68, $98, $68, $18, $e8, $ec, $f4, $f2, $5e
	db $fc, $4c, $f8, $18, $ec, $f4, $0c, $f4, $d8, $38, $30, $d0, $d0, $f0, $98, $f8
	db $e0, $e0, $50, $b0, $58, $a8, $4c, $b4, $4c, $b4, $0c, $f4, $e6, $fa, $fa, $1e
	db $ec, $1c, $f0, $30, $e0, $e0, $98, $f8, $dc, $74, $de, $72, $a6, $fa, $fe, $fe
	db $00, $00, $e0, $e0, $50, $b0, $58, $a8, $4c, $b4, $0c, $f4, $0c, $f4, $e6, $fa
	db $fa, $1e, $ec, $1c, $f0, $30, $e0, $e0, $cc, $fc, $fe, $3a, $f7, $39, $cf, $ff
	db $00, $00, $00, $00, $00, $00, $01, $01, $03, $03, $07, $04, $07, $04, $07, $06
	db $0b, $0d, $0f, $08, $1e, $11, $1e, $11, $3f, $20, $2f, $30, $1b, $1c, $07, $07
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $38, $38, $dc, $e4, $b6, $6a, $7e, $9a, $cb, $3d, $df, $3d
	db $ef, $3d, $ef, $dd, $eb, $1d, $ee, $12, $ec, $14, $c4, $3c, $18, $f8, $e0, $e0

SECTION "analyzed_04d247", ROMX[$5247], BANK[$13]

Data_13_5247:
	db $7f, $7f, $64, $63, $64, $63, $64, $63, $6a, $67, $60, $6f, $61, $7e, $68, $70
	db $62, $41, $49, $47, $57, $4f, $6f, $5f, $5f, $7f, $7e, $7e, $7e, $7e, $7e, $7e
	db $7e, $7e, $7f, $7f, $7e, $7f, $7f, $7f, $7f, $7f, $71, $78, $40, $40, $40, $40
	db $40, $40, $40, $40, $40, $40, $40, $40, $40, $40, $00, $00, $7f, $7f, $00, $00
	db $7f, $7f, $40, $4c, $40, $4c, $40, $4c, $44, $48, $40, $48, $40, $58, $49, $50
	db $40, $51, $40, $51, $42, $71, $50, $63, $44, $63, $60, $47, $51, $4f, $6f, $5f
	db $7f, $7f, $7f, $7f, $7f, $7f, $4f, $5f, $41, $43, $40, $41, $40, $40, $40, $40
	db $40, $40, $40, $40, $40, $40, $47, $4f, $5c, $7b, $00, $00, $7f, $7f, $00, $00
	db $ff, $ff, $0e, $ff, $70, $ff, $80, $ff, $00, $ff, $18, $e7, $23, $1f, $9f, $7f
	db $7f, $ff, $fd, $ff, $f1, $ff, $f7, $fb, $1d, $1f, $18, $0f, $1b, $0c, $1f, $08
	db $3b, $08, $73, $18, $e7, $f3, $0a, $c7, $1a, $84, $58, $80, $0a, $71, $00, $3b
	db $0b, $15, $07, $08, $03, $04, $01, $02, $00, $01, $00, $00, $ff, $ff, $00, $00
	db $ff, $ff, $00, $f0, $00, $f0, $00, $f0, $00, $f0, $00, $f0, $00, $f0, $00, $f0
	db $00, $f0, $00, $f0, $10, $e0, $00, $e0, $00, $e0, $1f, $ef, $fe, $ff, $fb, $fc
	db $fc, $f0, $a0, $70, $80, $30, $00, $c0, $0a, $8c, $c7, $80, $e7, $c7, $f0, $e0
	db $94, $d8, $1d, $9e, $7f, $7f, $9e, $8f, $ff, $8f, $00, $00, $ff, $ff, $00, $00
	db $ff, $ff, $00, $ff, $00, $ff, $00, $ff, $07, $ff, $7f, $ff, $ff, $ff, $e3, $e1
	db $9f, $9e, $2f, $2e, $2f, $2c, $1f, $01, $9f, $83, $7c, $ff, $04, $f8, $e3, $00
	db $07, $f8, $0b, $f4, $a5, $da, $8d, $06, $0f, $06, $5f, $2e, $bd, $7e, $ff, $fc
	db $fb, $fc, $f7, $f8, $8e, $71, $f9, $07, $8f, $ff, $00, $00, $ff, $ff, $00, $00
	db $ff, $ff, $01, $3e, $01, $3e, $01, $3e, $01, $3e, $00, $3f, $40, $3f, $00, $7f
	db $00, $7f, $00, $7f, $00, $7f, $40, $3f, $fe, $7f, $df, $ff, $7f, $fd, $f6, $b5
	db $1c, $1d, $41, $02, $23, $1c, $07, $00, $06, $01, $cf, $21, $9f, $c3, $3f, $07
	db $ef, $1d, $bf, $79, $ee, $e3, $3c, $cf, $f0, $ff, $00, $00, $ff, $ff, $00, $00
	db $fd, $fd, $01, $fd, $01, $fd, $7d, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $bd, $fd
	db $dd, $fd, $fd, $fd, $8d, $fd, $85, $fd, $05, $fd, $e5, $1d, $e1, $1d, $c1, $3d
	db $c1, $3d, $85, $7d, $85, $7d, $a5, $5d, $a5, $5d, $4d, $bd, $4d, $bd, $9d, $7d
	db $99, $7d, $75, $f9, $79, $f5, $e9, $f5, $d1, $ed, $01, $01, $ff, $ff, $00, $00
	db $fd, $fd, $d1, $31, $d1, $39, $c9, $39, $c9, $39, $e9, $19, $e9, $1d, $e5, $1d
	db $f1, $0d, $71, $8d, $79, $85, $7d, $81, $3d, $c1, $dd, $e1, $fd, $fd, $2d, $dd
	db $6d, $9d, $5d, $bd, $3d, $fd, $fd, $fd, $f9, $fd, $f1, $f9, $d1, $f1, $d1, $d1
	db $81, $d1, $c1, $e1, $31, $f9, $0d, $fd, $01, $fd, $01, $01, $ff, $ff, $3f, $3f
	db $40, $40, $9f, $9f, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0
	db $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $a0, $ff, $ff
	db $00, $00, $ff, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $ff, $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $ff, $24, $3c
	db $12, $1e, $09, $0f, $04, $07, $02, $03, $01, $01, $00, $00, $00, $00, $81, $ff
	db $81, $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff
	db $81, $ff, $81, $ff, $81, $ff, $81, $ff, $ff, $ff, $81, $ff, $81, $ff, $ff, $ff
	db $80, $ff, $80, $ff, $80, $ff, $ff, $ff, $80, $ff, $bf, $ff, $ae, $ea, $ae, $ea
	db $ae, $ea, $ae, $ee, $bb, $ff, $a0, $ff, $bf, $ff, $a0, $ff, $bf, $ff, $a7, $e7
	db $a7, $e7, $a7, $e7, $bd, $ff, $a0, $ff, $bf, $ff, $a0, $ff, $bf, $ff, $bb, $fa
	db $bb, $fa, $bb, $fa, $af, $ff, $a0, $ff, $bf, $ff, $80, $ff, $7f, $ff, $ff, $ff
	db $00, $ff, $00, $ff, $00, $ff, $ff, $ff, $00, $ff, $fe, $ff, $fe, $9f, $fe, $9f
	db $fe, $9f, $fe, $9f, $f2, $ff, $02, $ff, $fe, $ff, $02, $ff, $fe, $ff, $7a, $4b
	db $7a, $4b, $7a, $4b, $fe, $ff, $02, $ff, $fe, $ff, $02, $ff, $fe, $ff, $f2, $73
	db $f2, $73, $f2, $73, $de, $ff, $02, $ff, $fe, $ff, $00, $ff, $ff, $ff, $00, $ff
	db $7f, $80, $3f, $c0, $7f, $80, $00, $ff, $ff, $00, $fe, $01, $ff, $00, $00, $ff
	db $ff, $00, $ff, $00, $ff, $00, $00, $ff, $7f, $80, $7f, $80, $7f, $80, $ff, $ff
	db $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80
	db $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $80, $ff, $ff
	db $fe, $01, $ff, $00, $fe, $01, $ff, $00, $fe, $01, $ff, $00, $fe, $01, $ff, $00
	db $fe, $01, $ff, $00, $fe, $01, $ff, $00, $fe, $01, $ff, $00, $fe, $01, $ff, $ff
	db $fe, $81, $ff, $80, $fe, $81, $ff, $80, $fe, $81, $ff, $80, $fe, $81, $ff, $80
	db $fe, $81, $ff, $80, $fe, $81, $ff, $80, $fe, $81, $ff, $80, $fe, $81, $ff, $ff
	db $80, $ff, $ff, $ff, $ff, $ff, $87, $ff, $87, $ff, $87, $ff, $fc, $ff, $ff, $ff
	db $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $ff, $ff, $ff
	db $ff, $80, $ff, $80, $ff, $ff, $ff, $80, $ff, $bf, $e0, $a0, $e0, $a0, $e0, $a0
	db $e0, $a0, $e0, $a0, $ff, $bf, $ff, $80, $ff, $7f, $e0, $3f, $ff, $1f, $ff, $3f
	db $ea, $55, $d7, $68, $e8, $57, $ff, $40, $ff, $3f, $ff, $00, $ff, $00, $ff, $ff
	db $ab, $56, $f7, $0a, $2b, $d6, $ff, $02, $ff, $fc, $ff, $00, $ff, $00, $ff, $ff
	db $ff, $81, $ff, $81, $ff, $81, $ff, $ff, $ff, $81, $ff, $bd, $ff, $81, $ff, $ff
	db $ff, $81, $ff, $bd, $ff, $81, $ff, $81, $ff, $81, $ff, $81, $ff, $ff, $ff, $00
	db $c1, $c0, $39, $38, $39, $28, $29, $38, $39, $38, $01, $fe, $ff, $00, $ff, $ff
	db $00, $00, $00, $00, $03, $03, $0d, $0e, $1a, $15, $34, $2b, $60, $5f, $50, $6f
	db $60, $5f, $31, $2e, $10, $1f, $0f, $0f, $00, $00, $00, $00, $00, $00, $ff, $ff
	db $00, $00, $00, $00, $80, $80, $70, $f0, $8c, $7c, $06, $fa, $0b, $f5, $01, $ff
	db $03, $fd, $51, $af, $a7, $5f, $fe, $ff, $00, $00, $00, $00, $00, $00, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $01, $01, $03, $02, $05, $06, $0b, $0c, $1f, $18
	db $1f, $1b, $2f, $33, $7f, $40, $6a, $55, $3f, $3f, $00, $00, $00, $00, $ff, $ff
	db $38, $38, $6f, $5f, $dd, $bb, $ba, $76, $74, $ec, $a8, $58, $d0, $30, $e8, $18
	db $f8, $88, $6c, $94, $d4, $2e, $be, $7f, $f8, $fe, $00, $00, $00, $00, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff
	db $00, $ff, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $f0, $0f, $c0, $3f, $80, $7f, $80, $7f, $00, $ff, $0f, $ff, $1f, $ff
	db $1f, $ff, $1f, $ff, $1f, $ff, $1f, $ff, $1f, $ff, $1f, $ff, $1f, $ff, $ff, $00
	db $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $ff, $f0, $00
	db $ef, $00, $e1, $00, $fc, $00, $c2, $00, $ff, $00, $ff, $00, $ff, $00, $85, $00
	db $6b, $00, $6b, $00, $d7, $00, $10, $00, $ff, $00, $ff, $00, $ff, $00, $c2, $00
	db $b5, $00, $b5, $00, $6b, $00, $0b, $00, $ff, $00, $ff, $00, $ff, $00, $18, $00
	db $56, $00, $56, $00, $ad, $00, $a1, $00, $ff, $00, $ff, $00, $ff, $00, $5b, $00
	db $9b, $00, $a7, $00, $67, $00, $6f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $e2, $1d, $ee, $11, $de, $21, $df, $20, $c4, $3b, $ff, $00, $ff, $00
	db $ff, $00, $23, $dc, $eb, $14, $23, $dc, $b7, $48, $27, $d8, $ff, $00, $ff, $7f
	db $e7, $3a, $ef, $32, $ef, $32, $ef, $32, $ef, $32, $2e, $f3, $ef, $f3, $00, $00
	db $00, $00, $00, $00, $00, $01, $03, $01, $06, $01, $07, $04, $00, $04, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $18, $00, $18, $08, $19, $07, $0e, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $e0, $50, $ff, $19, $81, $8e, $01, $03, $03, $02, $02, $06
	db $04, $03, $07, $05, $0f, $06, $3a, $5e, $0c, $3a, $0c, $10, $18, $0c, $18, $10
	db $20, $10, $60, $00, $c0, $80, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $10, $70, $20, $c0, $e0, $80, $c0, $00, $80, $00, $00, $00, $00
	db $00, $81, $01, $83, $03, $06, $04, $0f, $09, $08, $01, $01, $01, $02, $02, $01
	db $02, $03, $02, $01, $01, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $20, $20, $20, $20, $40, $00, $40, $00, $00, $40, $80
	db $c0, $80, $80, $c0, $80, $80, $84, $00, $08, $84, $08, $10, $10, $18, $30, $00
	db $20, $60, $40, $e0, $80, $c0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $23, $10, $77, $11
	db $17, $1f, $19, $1f, $1b, $30, $32, $13, $32, $22, $22, $24, $24, $42, $44, $64
	db $44, $c4, $85, $4e, $87, $06, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $18, $10, $00, $20, $30, $60, $00
	db $c0, $00, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $f0, $f0
	db $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0

SECTION "analyzed_04da15", ROMX[$5a15], BANK[$13]

Data_13_5a15:
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $7f, $5f, $4b, $6f, $11, $00, $00, $7c, $67, $7b, $6f, $10, $42, $00, $00
	db $ff, $7f, $b6, $46, $32, $32, $00, $00, $7c, $63, $f4, $29, $0e, $15, $00, $00
	db $4f, $72, $7c, $63, $53, $42, $00, $00, $ac, $5e, $be, $14, $d2, $25, $00, $00
	db $ff, $7f, $5f, $4b, $80, $74, $00, $00, $ff, $7f, $94, $52, $4a, $29, $00, $00
	db $ff, $7f, $5f, $4b, $6f, $11, $00, $00, $ff, $7f, $5f, $4b, $80, $74, $00, $00
	db $ff, $7f, $ee, $2f, $26, $1a, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $7f, $94, $52, $4a, $29, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $18, $14, $ab, $5c, $cb, $5a, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $a8, $a8, $a8, $aa
	db $a8, $a8, $a8, $a8, $a8, $a8, $a8, $a8, $ac, $b0, $ac, $b0, $ff, $ff, $ff, $ff
	db $fc, $fc, $a9, $aa, $a9, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $ad, $b1, $ad, $b1
	db $ff, $ff, $ff, $ff, $fc, $fc, $fc, $ab, $fc, $fc, $b6, $b8, $be, $be, $c2, $ba
	db $ae, $b2, $ae, $b2, $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5, $b4, $b5, $b7, $b9
	db $bf, $bf, $c3, $bb, $af, $b3, $af, $b3, $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5
	db $b4, $b5, $b7, $b9, $c0, $c1, $c4, $bb, $b4, $b5, $b4, $b5, $ff, $ff, $ff, $ff
	db $b4, $b5, $b4, $b5, $b4, $b5, $bc, $bd, $bd, $bd, $bd, $bc, $b4, $b5, $b4, $b5
	db $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5
	db $b4, $b5, $b4, $b5, $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5
	db $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5
	db $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $ff, $ff, $ff, $ff
	db $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5
	db $ff, $ff, $ff, $ff, $ba, $cd, $c5, $c7, $cd, $ba, $b4, $b5, $b4, $b5, $ba, $cd
	db $c9, $cb, $cd, $ba, $ff, $ff, $ff, $ff, $bb, $fc, $c6, $c8, $fc, $bb, $b4, $b5
	db $b4, $b5, $bb, $fc, $ca, $cc, $fc, $bb, $ff, $ff, $ff, $ff, $bb, $fc, $fc, $fc
	db $fc, $bb, $b4, $b5, $b4, $b5, $bb, $fc, $fc, $fc, $fc, $bb, $ff, $ff, $ff, $ff
	db $bc, $bd, $bd, $bd, $bd, $bc, $b4, $b5, $b4, $b5, $bc, $bd, $bd, $bd, $bd, $bc
	db $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5
	db $b4, $b5, $b4, $b5, $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5
	db $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5
	db $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $ff, $ff, $ff, $ff
	db $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5
	db $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5
	db $b4, $b5, $b4, $b5, $ff, $ff, $ff, $ff, $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5
	db $b4, $b5, $b4, $b5, $b4, $b5, $b4, $b5, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $b4, $b5, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $b4, $b5, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0d, $0d, $0d, $0d, $08, $08, $08, $08
	db $0b, $0b, $0b, $0b, $2b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0d, $0d, $0d, $0d
	db $08, $08, $08, $08, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0c, $2c, $0c, $2b
	db $0d, $0d, $0d, $0d, $08, $08, $08, $08, $0a, $0a, $0a, $0a, $0a, $0a, $0b, $0b
	db $0c, $2c, $0c, $2b, $0d, $0d, $0d, $0d, $08, $08, $08, $08, $0a, $0a, $0a, $0a
	db $0a, $0a, $0b, $0b, $0c, $0c, $0c, $2b, $0a, $0a, $0a, $0a, $08, $08, $08, $08
	db $0a, $0a, $0a, $0a, $0a, $0a, $0b, $0b, $0b, $0b, $0b, $2b, $0a, $0a, $0a, $0a
	db $08, $08, $08, $08, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $08, $08, $08, $08, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $08, $08, $08, $08, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $08, $08, $08, $08
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $08, $08, $08, $08, $0b, $09, $09, $09, $09, $2b, $0a, $0a, $0a, $0a, $0b, $09
	db $09, $09, $09, $2b, $08, $08, $08, $08, $0b, $09, $09, $09, $09, $2b, $0a, $0a
	db $0a, $0a, $0b, $09, $09, $09, $09, $2b, $08, $08, $08, $08, $0b, $09, $09, $09
	db $09, $2b, $0a, $0a, $0a, $0a, $0b, $09, $09, $09, $09, $2b, $08, $08, $08, $08
	db $0b, $0b, $0b, $0b, $0b, $2b, $0a, $0a, $0a, $0a, $0b, $0b, $0b, $0b, $0b, $2b
	db $08, $08, $08, $08, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $08, $08, $08, $08, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $08, $08, $08, $08, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $08, $08, $08, $08
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $08, $08, $08, $08, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $08, $08, $08, $08, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $0a, $0a, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $0a, $0a, $08, $08, $08, $08, $08, $08
	db $08, $08, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $09, $09, $08, $08, $12, $14, $f9, $5f, $91, $5e, $ce, $ce, $ce, $ce
	db $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce
	db $d2, $d3, $d4, $d5, $d6, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd
	db $d7, $d8, $fd, $fd, $fd, $cf, $d1, $d1, $d1, $d1, $d1, $d1, $d1, $d1, $d1, $d1
	db $d1, $d1, $d1, $d1, $d1, $d1, $cf, $fd, $fd, $d0, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $d0, $fd, $fd, $d0, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $d0, $fd
	db $fd, $d0, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $d0, $fd, $fd, $d0, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $d0, $fd, $fd, $d0, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $d0, $fd, $fd, $d0, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $d0, $fd
	db $fd, $d0, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $d0, $fd, $fd, $d0, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $d0, $fd, $fd, $d0, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $d0, $fd, $fd, $d0, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $d0, $fd
	db $fd, $d0, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $d0, $fd, $fd, $d0, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $d0, $fd, $fd, $cf, $d1, $d1, $d1, $d1, $d1, $d1
	db $d1, $d1, $d1, $d1, $d1, $d1, $d1, $d1, $d1, $d1, $cf, $fd, $fd, $fd, $fd, $fd
	db $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd
	db $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce, $ce
	db $ce, $d9, $ce, $ce, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $2c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $2c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $2c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $2c, $0c
	db $0c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c
	db $4c, $4c, $6c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c
	db $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $4c, $0c, $4c, $4c, $06, $14, $df, $61
	db $67, $61, $a0, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2
	db $a2, $a2, $a2, $a2, $a2, $a0, $a1, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $a1, $a1, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $a1, $a1, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $a1, $a1, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $a1, $a0, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2
	db $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a2, $a0, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $28, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $28, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $28, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $28, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $28, $48, $48
	db $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48, $48
	db $48, $68, $04, $04, $6d, $62, $5d, $62, $80, $88, $90, $98, $81, $89, $91, $99
	db $82, $8a, $92, $9a, $83, $8b, $93, $9b, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $04, $04, $93, $62, $83, $62, $84, $8c
	db $94, $9c, $85, $8d, $95, $9d, $86, $8e, $96, $9e, $87, $8f, $97, $9f, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $04, $04
	db $b9, $62, $a9, $62, $ff, $ff, $b4, $b5, $ff, $ff, $b4, $b5, $ff, $ff, $b4, $b5
	db $ff, $ff, $ba, $cd, $0f, $0f, $0a, $0a, $0f, $0f, $0a, $0a, $0f, $0f, $0a, $0a
	db $0f, $0f, $0b, $09, $03, $06, $e1, $62, $cf, $62, $da, $dd, $e0, $e3, $e6, $e9
	db $db, $de, $e1, $e4, $e7, $ea, $dc, $df, $e2, $e5, $e8, $eb, $0f, $0f, $0f, $0f
	db $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $02, $00
	db $00, $00, $08, $00, $08, $08, $08

Data_13_62fc:
	db $02, $00, $00, $02, $08, $00, $08, $0a, $08, $02, $00, $00, $04, $08, $00, $08
	db $0c, $08

Data_13_630e:
	db $02, $00, $00, $06, $08, $00, $08, $0e, $08

Data_13_6317:
	db $02, $00, $00, $10, $08, $00, $08, $18, $08, $02, $00, $00, $18, $28, $00, $08
	db $10, $28

Data_13_6329:
	db $02, $00, $00, $12, $08, $00, $08, $1a, $08

Data_13_6332:
	db $02, $00, $00, $14, $08, $00, $08, $1c, $08, $02, $00, $00, $1a, $28, $00, $08
	db $12, $28, $02, $00, $00, $1c, $28, $00, $08, $14, $28, $02, $00, $00, $16, $09
	db $00, $08, $1e, $09, $02, $00, $00, $20, $09, $00, $08, $28, $09, $02, $00, $00
	db $22, $09, $00, $08, $2a, $09, $02, $00, $00, $24, $09, $00, $08, $2c, $09, $02
	db $00, $00, $26, $09, $00, $08, $2e, $09

Data_13_637a:
	db $02, $00, $00, $2c, $29, $00, $08, $24, $29, $02, $00, $00, $30, $0a, $00, $08
	db $38, $0a

SECTION "analyzed_050000", ROMX[$4000], BANK[$14]

Data_14_4000:
	db $02, $00, $3c, $73, $6a, $71, $26, $50, $02, $00, $ab, $15, $3e, $5e, $f5, $38
	db $02, $00, $5c, $63, $f7, $1d, $f0, $08, $02, $00, $de, $63, $9d, $1e, $50, $25
	db $02, $00, $de, $77, $55, $4a, $29, $45, $02, $00, $de, $7b, $3e, $27, $54, $19
	db $02, $00, $3f, $2f, $ba, $01, $55, $10, $4d, $3d, $3d, $3d, $3d, $3e, $3d, $a4
	db $68, $c5, $68, $f6, $68, $27, $69, $58, $69, $89, $69, $ba, $69

ShowRegeneratedMonster:
	push af
	ld a, SOUND_BGM_DiscRegen
	call PlaySoundTracked
	pop af
	call Func_00_07c5
	xor a
	ldh [rVBK], a
	ld bc, $1800
	ld hl, $436b
	ld de, $8000
	call VramCopy16
	ld a, $01
	ldh [rVBK], a
	ld bc, $0800
	ld de, $8000
	call VramCopy16
	ld hl, $63eb
	ld de, $9800
	call CopyBgMap
	ld a, $14
	ld [wDrawBank], a
	ld hl, $6853
	ld bc, $1008
	call DrawMetasprite
	ld a, [wActiveMonster]
	add a, a
	ld hl, $403f
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, $1008
	call DrawMetasprite
	call HideUnusedOamSprites
	call Func_14_42d7
	call Func_14_4319
	ld hl, $636b
	call LoadBgPalettes
	ld hl, $63ab
	call LoadObjPalettes
	ld hl, $4000
	ld a, [wActiveMonster]
	swap a
	rrca
	rst AddAToHL
	ld a, $07
	ld b, $01
	call Func_00_0732
	xor a
	ld [wUiTimer], a
Func_14_40c5:
	call WaitForNextFrame
	call WaitForNextFrame
	call WaitForNextFrame
	call WaitForNextFrame
	call WaitForNextFrame
	call WaitForNextFrame
	call WaitForNextFrame
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyPressed]
	bit 1, a
	jp nz, Func_14_417b
	ld d, $06
	ld hl, $c003
Func_14_40ec:
	ld a, [hl]
	ld c, a
	and $f8
	ld b, a
	ld a, c
	and $07
	inc a
	cp $05
	jr nz, Func_14_40fb
	ld a, $01
Func_14_40fb:
	or b
	ld [hl], a
	ld a, $04
	add a, l
	ld l, a
	dec d
	jr nz, Func_14_40ec
	ld a, [wUiTimer]
	inc a
	ld [wUiTimer], a
	cp $14
	jr nz, Func_14_40c5
	ld hl, $d0eb
	ld bc, $0008
	ld d, $ff
	call Func_00_03bc
	xor a
	ld [wUiTimer], a
Func_14_411e:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyPressed]
	bit 1, a
	jr nz, Func_14_417b
	call Func_14_41b3
	ld a, [wUiTimer]
	inc a
	ld [wUiTimer], a
	cp $8c
	jr nz, Func_14_411e
	xor a
	ld [wUiTimer], a
Func_14_413c:
	call WaitForNextFrame
	call Func_14_41b3
	call Func_14_4294
	call Func_14_42af
	ld a, [wUiTimer]
	inc a
	ld [wUiTimer], a
	cp $f0
	jr nz, Func_14_413c
	call Func_00_07a7
	ld d, $3c
Func_14_4158:
	call WaitForNextFrame
	push de
	call ReadJoypad
	pop de
	ldh a, [hJoyPressed]
	bit 1, a
	jr nz, Func_14_417b
	dec d
	jr nz, Func_14_4158
	ld hl, $63eb
	ld de, $9800
	call CopyBgMap
	call Func_14_4329
	call Func_00_0794
	call Func_14_4351
Func_14_417b:
	push af
	ld a, SOUND_BGM_Pashute
	call PlaySoundTracked
	pop af
	ret

Data_14_4183:
	db $0c, $1d, $22, $10, $27, $14, $19, $2c, $2c, $7c, $4d, $42, $65, $37, $59, $71
	db $7c, $8d, $92, $80, $97, $84, $89, $9c, $01, $11, $16, $04, $1b, $08, $0d, $20
	db $20, $31, $28, $36, $3b, $24, $2d, $40, $70, $81, $86, $7d, $8b, $78, $74, $90

Func_14_41b3:
	ld a, [wUiTimer]
	cp $8c
	jr nc, Func_14_4239
	ld c, a
	and $01
	jr nz, Func_14_4239
	ld a, c
	rrca
	ld c, a
	and $03
	ld b, a
	ld a, c
	rrca
	rrca
	and $07
	ld c, a
	ld a, b
	cp $00
	jr nz, Func_14_41de
	ld a, c
	ld hl, $419b
	rst AddAToHL
	ld d, [hl]
	ld a, c
	ld hl, $418b
	rst AddAToHL
	ld e, [hl]
	jr Func_14_420e
Func_14_41de:
	cp $01
	jr nz, Func_14_41f0
	ld a, c
	ld hl, $41a3
	rst AddAToHL
	ld d, [hl]
	ld a, c
	ld hl, $4193
	rst AddAToHL
	ld e, [hl]
	jr Func_14_420e
Func_14_41f0:
	cp $02
	jr nz, Func_14_4202
	ld a, c
	ld hl, $41ab
	rst AddAToHL
	ld d, [hl]
	ld a, c
	ld hl, $418b
	rst AddAToHL
	ld e, [hl]
	jr Func_14_420e
Func_14_4202:
	ld a, c
	ld hl, $41a3
	rst AddAToHL
	ld d, [hl]
	ld a, c
	ld hl, $4183
	rst AddAToHL
	ld e, [hl]
Func_14_420e:
	push de
	ld hl, $c080
	ld c, $00
Func_14_4214:
	ld de, $d0eb
	ld a, c
	rst AddAToDE
	ld a, [de]
	cp $10
	jr nc, Func_14_422b
	inc l
	inc l
	inc l
	inc l
	inc c
	ld a, $08
	cp c
	jr nz, Func_14_4214

Data_14_4228:
	db $d1, $18, $0e

Func_14_422b:
	ld a, $00
	ld [de], a
	pop de
	ld a, d
	ld [hl+], a
	ld a, e
	ld [hl+], a
	ld a, $5a
	ld [hl+], a
	ld a, $00
	ld [hl+], a
Func_14_4239:
	ld hl, $c080
	ld c, $00
Func_14_423e:
	ld de, $d0eb
	ld a, c
	rst AddAToDE
	ld a, [de]
	cp $10
	jr c, Func_14_4251
	ld a, $ff
	ld [de], a
	ld a, $f0
	ld [hl+], a
	inc l
	jr Func_14_428b
Func_14_4251:
	inc a
	ld b, a
	ld [de], a
	ld a, [hl+]
	ld d, a
	ld e, [hl]
	ld a, $48
	sub d
	ld d, a
	ld a, $54
	sub e
	ld e, a
	ld a, d
	add a, e
	sra a
	sra a
	sra a
	add a, [hl]
	ld [hl-], a
	ld a, d
	sub e
	sra a
	sra a
	sra a
	add a, [hl]
	ld [hl+], a
	inc l
	ld a, b
	cp $04
	jr nz, Func_14_427d
	ld [hl], $5c
	jr Func_14_428b
Func_14_427d:
	cp $08
	jr nz, Func_14_4285
	ld [hl], $5e
	jr Func_14_428b
Func_14_4285:
	cp $0c
	jr nz, Func_14_428b
	ld [hl], $60
Func_14_428b:
	inc l
	inc l
	inc c
	ld a, $08
	cp c
	jr nz, Func_14_423e
	ret
Func_14_4294:
	ld a, [wUiTimer]
	cp $64
	ret c
	and $01
	jr z, Func_14_42a3
	call Func_14_42d7
	jr Func_14_42a6
Func_14_42a3:
	call Func_14_42e7
Func_14_42a6:
	ld a, [wUiTimer]
	and $0f
	call z, Func_14_4300
	ret
Func_14_42af:
	ld a, [wUiTimer]
	ld b, a
	and $03
	ret nz
	ld a, b
	cp $78
	jr nc, Func_14_42c9
	and $04
	jr nz, Func_14_42c4
	ld hl, $66c1
	jr Func_14_42d0
Func_14_42c4:
	ld hl, $6747
	jr Func_14_42d0
Func_14_42c9:
	and $04
	jr z, Func_14_42c4
	ld hl, $67cd
Func_14_42d0:
	ld de, $9866
	call CopyBgMap
	ret
Func_14_42d7:
	ld d, $f0
	ld hl, $c018
	ld c, $0e
Func_14_42de:
	ld [hl], d
	ld a, $04
	add a, l
	ld l, a
	dec c
	jr nz, Func_14_42de
	ret
Func_14_42e7:
	ld hl, $c018
	ld c, $0e
Func_14_42ec:
	ld a, c
	cp $08
	jr c, Func_14_42f5
	ld d, $52
	jr Func_14_42f7
Func_14_42f5:
	ld d, $62
Func_14_42f7:
	ld [hl], d
	ld a, $04
	add a, l
	ld l, a
	dec c
	jr nz, Func_14_42ec
	ret
Func_14_4300:
	ld hl, $c01a
	ld c, $0e
Func_14_4305:
	ld a, [hl]
	cp $9a
	jr c, Func_14_430e
	sub $38
	jr Func_14_4310
Func_14_430e:
	add a, $1c
Func_14_4310:
	ld [hl], a
	ld a, $04
	add a, l
	ld l, a
	dec c
	jr nz, Func_14_4305
	ret
Func_14_4319:
	ld b, $f0
	ld hl, $c050
	ld c, $0c
Func_14_4320:
	ld [hl], b
	inc l
	inc l
	inc l
	inc l
	dec c
	jr nz, Func_14_4320
	ret
Func_14_4329:
	ld a, [wActiveMonster]
	ld d, a
	ld hl, $4038
	rst AddAToHL
	ld b, [hl]
	ld hl, $c050
	ld c, $0c
Func_14_4337:
	ld a, c
	cp $08
	jr z, Func_14_4344
	cp $04
	jr nz, Func_14_4348
	ld a, $00
	cp d
	ret z
Func_14_4344:
	ld a, $10
	add a, b
	ld b, a
Func_14_4348:
	ld [hl], b
	inc l
	inc l
	inc l
	inc l
	dec c
	jr nz, Func_14_4337
	ret
Func_14_4351:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [hJoyPressed]
	bit 1, a
	jr nz, Func_14_4363
	bit 0, a
	jr nz, Func_14_4363
	jr Func_14_4351
Func_14_4363:
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret

Data_14_436b:
	INCBIN "raw_gfx/Data_14_436b.2bpp", 0, 7344

Data_14_601b:
	db $80, $80, $81, $c1, $c0, $e0, $cf, $e0, $75, $73, $9a, $9a

SECTION "analyzed_05236b", ROMX[$636b], BANK[$14]

Data_14_636b:
	db $03, $1c, $cd, $2c, $94, $49, $8c, $65, $03, $1c, $cd, $2c, $94, $49, $ae, $31
	db $03, $1c, $09, $60, $0c, $40, $00, $00, $03, $1c, $e9, $34, $14, $52, $ae, $31
	db $03, $1c, $ff, $7f, $f0, $7e, $e9, $71, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $ff, $7f, $e7, $72, $a1, $54, $e0, $03, $7f, $7f, $dc, $0c, $12, $28
	db $1f, $00, $fe, $47, $6a, $1a, $40, $1d, $0f, $7c, $ff, $53, $dd, $16, $91, $21
	db $1f, $02, $7b, $7b, $4d, $6d, $00, $60, $ff, $7f, $a0, $79, $00, $6c, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $12, $14, $59, $65, $f1, $63, $58, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $58, $59, $4a, $3a, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3a, $4a, $59, $5a, $4b
	db $3b, $2b, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $2b, $3b
	db $4b, $5a, $5b, $4c, $3c, $2c, $1e, $15, $00, $00, $00, $00, $00, $00, $00, $00
	db $15, $1e, $2c, $3c, $4c, $5b, $5c, $4d, $3d, $2d, $1f, $16, $00, $00, $00, $00
	db $00, $00, $00, $00, $16, $1f, $2d, $3d, $4d, $5c, $5d, $00, $00, $2e, $20, $17
	db $00, $00, $00, $00, $00, $00, $00, $00, $17, $20, $2e, $00, $00, $5d, $5e, $4e
	db $3e, $2f, $21, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $21, $2f, $3e
	db $4e, $5e, $5f, $4f, $3f, $30, $22, $18, $00, $00, $00, $00, $00, $00, $00, $00
	db $18, $22, $30, $3f, $4f, $5f, $60, $50, $40, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $40, $50, $60, $61, $51, $41, $31, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $31, $41, $51, $61, $62, $52
	db $42, $32, $23, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $23, $32, $42
	db $52, $62, $00, $53, $43, $33, $24, $00, $b6, $f8, $fa, $fc, $fe, $7a, $7c, $7e
	db $00, $24, $33, $43, $53, $00, $00, $54, $44, $34, $25, $19, $b7, $f9, $fb, $fd
	db $ff, $7b, $7d, $7f, $19, $25, $34, $44, $54, $00, $63, $00, $45, $35, $26, $1a
	db $10, $0b, $06, $01, $01, $06, $0b, $10, $1a, $26, $35, $45, $00, $63, $64, $55
	db $46, $36, $27, $1b, $11, $0c, $07, $02, $02, $07, $0c, $11, $1b, $27, $36, $46
	db $55, $64, $65, $56, $47, $37, $28, $1c, $12, $0d, $08, $03, $03, $08, $0d, $12
	db $1c, $28, $37, $47, $56, $65, $00, $57, $48, $38, $29, $1d, $13, $0e, $09, $04
	db $04, $09, $0e, $13, $1d, $29, $38, $48, $57, $00, $00, $00, $49, $39, $2a, $00
	db $14, $0f, $0a, $05, $05, $0a, $0f, $14, $00, $2a, $39, $49, $00, $00, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20, $20, $20, $20
	db $20, $20, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20, $20, $20, $20
	db $20, $20, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20, $20, $20, $20
	db $03, $03, $03, $03, $03, $03, $03, $03, $00, $00, $00, $00, $00, $00, $20, $20
	db $20, $20, $21, $23, $03, $03, $03, $03, $03, $03, $03, $03, $03, $01, $00, $00
	db $00, $00, $20, $20, $20, $21, $21, $23, $23, $23, $23, $23, $03, $03, $03, $03
	db $03, $01, $01, $00, $00, $00, $20, $20, $20, $20, $21, $23, $23, $23, $23, $23
	db $03, $03, $03, $03, $03, $01, $00, $00, $00, $00, $20, $20, $20, $20, $20, $23
	db $23, $23, $23, $23, $03, $03, $03, $03, $03, $00, $00, $00, $00, $00, $20, $20
	db $20, $20, $20, $22, $22, $22, $22, $22, $02, $02, $02, $02, $02, $00, $00, $00
	db $00, $00, $20, $20, $20, $20, $20, $22, $22, $22, $22, $22, $02, $02, $02, $02
	db $02, $00, $00, $00, $00, $00, $08, $08, $07, $67, $c7, $66, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $66, $68, $00, $00, $00, $00, $00, $00, $67
	db $69, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $08, $08, $8d, $67
	db $4d, $67, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $6a, $6e, $72, $76, $00, $00, $00, $00, $6b, $6f, $73, $77
	db $00, $00, $00, $00, $6c, $70, $74, $78, $00, $00, $00, $00, $6d, $71, $75, $79
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $08, $08, $13, $68, $d3, $67, $b8, $c0, $c8, $d0, $d8, $e0, $e8, $f0
	db $b9, $c1, $c9, $d1, $d9, $e1, $e9, $f1, $ba, $c2, $ca, $d2, $da, $e2, $ea, $f2
	db $bb, $c3, $cb, $d3, $db, $e3, $eb, $f3, $bc, $c4, $cc, $d4, $dc, $e4, $ec, $f4
	db $bd, $c5, $cd, $d5, $dd, $e5, $ed, $f5, $be, $c6, $ce, $d6, $de, $e6, $ee, $f6
	db $bf, $c7, $cf, $d7, $df, $e7, $ef, $f7, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $14, $27, $05, $56, $23, $27, $0d, $54
	db $23, $30, $1c, $58, $22, $27, $8b, $54, $01, $27, $93, $56, $01, $30, $7c, $58
	db $04, $42, $34, $62, $05, $42, $3c, $64, $05, $42, $44, $66, $05, $42, $4c, $68
	db $05, $42, $54, $6a, $05, $42, $5c, $6c, $05, $42, $64, $6e, $05, $52, $34, $70
	db $05, $52, $3c, $72, $05, $52, $44, $74, $05, $52, $4c, $76, $05, $52, $54, $78
	db $05, $52, $5c, $7a, $05, $52, $64, $7c, $05, $08, $3d, $41, $00, $07, $3d, $49
	db $02, $07, $3d, $51, $04, $07, $3d, $59, $06, $07, $4d, $41, $08, $07, $4d, $49
	db $0a, $07, $4d, $51, $0c, $07, $4d, $59, $0e, $07, $0c, $2d, $40, $10, $07, $2d
	db $48, $12, $07, $2d, $50, $14, $07, $2d, $58, $16, $07, $3d, $40, $18, $07, $3d
	db $48, $1a, $07, $3d, $50, $1c, $07, $3d, $58, $1e, $07, $4d, $40, $20, $07, $4d
	db $48, $22, $07, $4d, $50, $24, $07, $4d, $58, $26, $07, $0c, $2d, $3f, $28, $07
	db $2d, $47, $2a, $07, $2d, $4f, $2c, $07, $2d, $57, $2e, $07, $3d, $3f, $30, $07
	db $3d, $47, $32, $07, $3d, $4f, $34, $07, $3d, $57, $36, $07, $4d, $3f, $38, $07
	db $4d, $47, $3a, $07, $4d, $4f, $3c, $07, $4d, $57, $3e, $07, $0c, $2d, $40, $40
	db $07, $2d, $48, $42, $07, $2d, $50, $44, $07, $2d, $58, $46, $07, $3d, $40, $48
	db $07, $3d, $48, $4a, $07, $3d, $50, $4c, $07, $3d, $58, $4e, $07, $4d, $40, $50
	db $07, $4d, $48, $52, $07, $4d, $50, $00, $0f, $4d, $58, $02, $0f, $0c, $2d, $41
	db $04, $0f, $2d, $49, $06, $0f, $2d, $51, $08, $0f, $2d, $59, $0a, $0f, $3d, $41
	db $0c, $0f, $3d, $49, $0e, $0f, $3d, $51, $10, $0f, $3d, $59, $12, $0f, $4d, $41
	db $14, $0f, $4d, $49, $16, $0f, $4d, $51, $18, $0f, $4d, $59, $1a, $0f, $0c, $2e
	db $3f, $1c, $0f, $2e, $47, $1e, $0f, $2e, $4f, $20, $0f, $2e, $57, $22, $0f, $3e
	db $3f, $24, $0f, $3e, $47, $26, $0f, $3e, $4f, $28, $0f, $3e, $57, $2a, $0f, $4e
	db $3f, $2c, $0f, $4e, $47, $2e, $0f, $4e, $4f, $30, $0f, $4e, $57, $32, $0f, $0c
	db $2d, $41, $34, $0f, $2d, $49, $36, $0f, $2d, $51, $38, $0f, $2d, $59, $3a, $0f
	db $3d, $41, $3c, $0f, $3d, $49, $3e, $0f, $3d, $51, $40, $0f, $3d, $59, $42, $0f
	db $4d, $41, $44, $0f, $4d, $49, $46, $0f, $4d, $51, $48, $0f, $4d, $59, $4a, $0f

SECTION "analyzed_054000", ROMX[$4000], BANK[$15]

Data_15_4000:
	db $06, $40

Data_15_4002:
	db $0a, $40

Data_15_4004:
	db $10, $40, $42, $49, $47, $00

Data_15_400a:
	db $53, $4d, $41, $4c, $4c, $00

Data_15_4010:
	db $53, $49, $5a, $45, $00

Func_15_4015:
	ld hl, $6674
	ld de, $9800
	call CopyBgMap
	ld hl, $c7e1
	ld bc, $0500
	ld a, $0e
	call Func_00_1fa4
	ld hl, $c7e8
	ld bc, $0507
	ld a, $0e
	call Func_00_1fa4
	ld hl, $c7ef
	ld bc, $050e
	ld a, $0e
	call Func_00_1fa4
	ld d, $00
Func_15_4041:
	ld a, d
	ld hl, $c7f6
	rst AddAToHL
	ld a, [hl]
	add a, a
	ld hl, $4000
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, d
	cp $00
	jr nz, Func_15_4058
	ld c, $00
	jr Func_15_4062
Func_15_4058:
	cp $01
	jr nz, Func_15_4060
	ld c, $07
	jr Func_15_4062
Func_15_4060:
	ld c, $0e
Func_15_4062:
	ld b, $07
	push de
	ld a, $0e
	call Func_00_1fa4
	pop de
	inc d
	ld a, $03
	cp d
	jr nz, Func_15_4041
	call Func_15_4185
	call Func_15_408a
	call Func_15_4241
	call Func_15_41cf
	ret

Data_15_407e:
	db $18, $46

Data_15_4080:
	db $60, $46

Data_15_4082:
	db $a8, $46, $f0, $46

Data_15_4086:
	db $38, $47, $80, $47

Func_15_408a:
	ld a, [$c55d]
	ld c, a
	cp $03
	jr nc, Func_15_40ac
	ld hl, $c7f6
	rst AddAToHL
	ld a, [hl]
	ld b, a
	add a, a
	ld hl, $407e
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	push bc
	call Func_00_33fb
	pop bc
	ld a, b
	cp $02
	call nz, Func_15_40bb
	ret
Func_15_40ac:
	ld a, [$cfbe]
	add a, a
	ld hl, $4084
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call Func_00_33fb
	ret
Func_15_40bb:
	ld a, c
	add a, a
	ld hl, $12db
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, $01
	ld [rVBK], a
	ld de, $8f60
Func_15_40cc:
	ld a, [hl+]
	cp $20
	jr nz, Func_15_40d6

Data_15_40d1:
	db $3e, $10, $f7, $18, $f6

Func_15_40d6:
	cp $21
	jr nz, Func_15_40df
	ld bc, $0a40
	jr Func_15_4101
Func_15_40df:
	cp $3f
	jr nz, Func_15_40e8
	ld bc, $0a50
	jr Func_15_4101
Func_15_40e8:
	sub $30
	ret c
	cp $0a
	jr nc, Func_15_40f3

Data_15_40ef:
	db $c6, $9a, $18, $04

Func_15_40f3:
	sub $11
	add a, $80
	swap a
	ld b, a
	and $f0
	ld c, a
	ld a, b
	and $0f
	ld b, a
Func_15_4101:
	push hl
	ld hl, $8000
	add hl, bc
	ld c, $10
	call VramCopy8
	pop hl
	jr Func_15_40cc

SECTION "analyzed_05410e", ROMX[$410e], BANK[$15]

Data_15_410e:
	db $c9

SECTION "analyzed_05410f", ROMX[$410f], BANK[$15]

Func_15_410f:
	ld hl, $6ae0
	ld de, $9800
	call CopyBgMap
	call Func_15_41b8
	call Func_15_4241
	call Func_00_0786
	call Func_15_4147
	call Func_00_0786
	ld a, [$c55e]
	ld c, a
	FAR_CALL $12, Func_12_43fe
	ret
Func_15_4134:
	ld hl, $65ce
	ld de, $99c0
	call CopyBgMap
	call Func_00_3340
	ret

Data_15_4141:
	db $b8, $73

Data_15_4143:
	db $12, $74, $6c, $74

Func_15_4147:
	ld a, [$c55d]
	add a, a
	push af
	ld hl, $4141
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $9807
	call CopyBgMap
	pop af
	ld hl, $12db
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, $0207
	ld a, $0e
	call Func_00_1fa4
	ld a, [$c55d]
	ld hl, $c7f6
	rst AddAToHL
	ld a, [hl]
	add a, a
	ld hl, $4000
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld bc, $0407
	ld a, $0e
	call Func_00_1fa4
	call Func_15_41cf
	ret
Func_15_4185:
	ld a, $15
	ld [wDrawBank], a
	ld hl, $74ee
	call DrawMetasprite
	ld hl, $74ee
	call DrawMetasprite
	ld hl, $74ee
	call DrawMetasprite
	call HideUnusedOamSprites
	ld a, $00
	ld bc, $4008
	call Func_00_20f0
	ld a, $01
	ld bc, $4040
	call Func_00_20f0
	ld a, $02
	ld bc, $4078
	call Func_00_20f0
	ret
Func_15_41b8:
	ld a, $15
	ld [wDrawBank], a
	ld hl, $74ee
	call DrawMetasprite
	call HideUnusedOamSprites
	ld a, $00
	ld bc, $2840
	call Func_00_20f0
	ret
Func_15_41cf:
	ld hl, $655e
	ld a, $02
	ld b, $04
	call Func_00_0716
	ld a, [$c55d]
	ld b, a
	cp $04
	jr nc, Func_15_41f3
	add a, $02
	swap a
	rrca
	ld hl, $74c6
	rst AddAToHL
	ld a, b
	add a, $03
	ld b, $01
	call Func_00_0716
	ret
Func_15_41f3:
	ld hl, $74ce
	ld a, $02
	ld b, $01
	call Func_00_0716
	ret
Func_15_41fe:
	call Func_00_083c
	xor a
	ld [rVBK], a
	ld bc, $1000
	ld hl, $424e
	ld de, $8800
	call VramCopy16
	ld a, $01
	ld [rVBK], a
	ld bc, $1000
	ld hl, $524e
	ld de, $8800
	call VramCopy16
	ld a, [$cfbe]
	or a
	ret z

Data_15_4227:
	db $fe, $02, $28, $05, $21, $4e, $62, $18, $03, $21, $ce, $63, $af, $ea, $4f, $ff
	db $01, $80, $01, $11, $00, $94, $cd, $94, $03, $c9

Func_15_4241:
	ld hl, $654e
	call LoadBgPalettes
	ld hl, $658e
	call LoadObjPalettes
	ret

Data_15_424e:
	db $00, $ff, $70, $fd, $00, $af, $27, $bf, $08, $f8, $13, $f0, $07, $a0, $07, $e0
	db $0f, $e0, $2f, $e0, $4f, $c0, $0f, $80, $0f, $80, $2f, $80, $3f, $80, $00, $ff
	db $00, $ff, $3f, $ff, $44, $c7, $22, $0f, $ea, $1f, $cc, $3f, $ac, $7e, $a8, $7e
	db $28, $fe, $50, $fe, $6c, $ff, $63, $f3, $ac, $60, $ce, $60, $d7, $10, $00, $ff
	db $00, $ff, $ff, $ff, $00, $c7, $00, $9f, $43, $3f, $01, $7f, $01, $ff, $01, $ff
	db $01, $ff, $01, $ff, $81, $ff, $c3, $ff, $20, $3f, $18, $1f, $07, $07, $00, $ff
	db $ff, $ff, $00, $80, $1f, $80, $3f, $80, $3f, $80, $7f, $80, $1f, $c0, $0f, $e0
	db $0f, $e0, $4f, $a0, $0f, $f0, $60, $f8, $10, $bf, $32, $bd, $00, $ff, $ff, $ff
	db $ff, $ff, $00, $00, $83, $00, $d7, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $df, $00, $0f, $80, $23, $c0, $00, $ff, $ff, $ff
	db $ff, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $00, $00, $c7, $00, $f7, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $00, $ff, $ff, $ff
	db $ff, $ff, $00, $00, $e1, $00, $f9, $00, $f7, $00, $f7, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $f8, $00, $f0, $01, $f4, $03, $00, $ff, $ff, $ff
	db $ff, $ff, $00, $01, $f8, $01, $fc, $01, $fc, $01, $fe, $01, $fc, $03, $f8, $07
	db $f2, $05, $f0, $07, $e0, $0f, $06, $1f, $0a, $fd, $4e, $bd, $00, $ff, $ff, $ff
	db $00, $ff, $ff, $ff, $00, $c7, $00, $9f, $47, $3f, $02, $7f, $02, $ff, $02, $ff
	db $02, $ff, $02, $ff, $82, $ff, $c7, $ff, $20, $3f, $18, $1f, $07, $07, $00, $ff
	db $00, $ff, $ff, $ff, $00, $c7, $00, $9f, $4f, $3f, $05, $7f, $05, $ff, $05, $ff
	db $05, $ff, $05, $ff, $85, $ff, $cf, $ff, $20, $3f, $18, $1f, $07, $07, $00, $ff
	db $00, $00, $08, $08, $6c, $44, $6c, $28, $84, $c0, $80, $c4, $e4, $dc, $38, $38
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $f0, $ff, $18, $ff, $08, $ff, $0c, $ff
	db $06, $ff, $03, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $03, $fc, $04, $f8, $0b, $f0, $06, $f1, $04, $f3, $08, $f7, $00, $ff, $08, $ff
	db $08, $ff, $08, $ff, $08, $ff, $08, $ff, $08, $ff, $08, $ff, $08, $ff, $08, $ff
	db $08, $ff, $08, $ff, $08, $ff, $08, $ff, $08, $ff, $08, $ff, $08, $ff, $08, $ff
	db $08, $ff, $08, $ff, $00, $ff, $00, $ff, $00, $ff, $08, $ff, $00, $ff, $00, $ff
	db $08, $f7, $08, $f7, $08, $f7, $08, $f7, $10, $e7, $28, $c7, $10, $0f, $e0, $1f
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $ff, $f0, $ff, $f8, $ff, $1c, $ff, $04, $ff, $04, $ff, $00, $ff, $0c, $f3
	db $08, $07, $f0, $0f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $09, $fe, $09, $fe, $09, $fe, $09, $fe, $09, $fe, $09, $fe, $09, $fe, $09, $fe
	db $09, $fe, $09, $fe, $09, $fe, $09, $fe, $09, $fe, $09, $fe, $09, $fe, $09, $fe
	db $09, $fe, $09, $fe, $01, $fe, $01, $fe, $01, $fe, $09, $fe, $01, $fe, $01, $fe
	db $09, $f6, $09, $f6, $09, $f6, $09, $f6, $11, $e6, $29, $c6, $11, $0e, $e1, $1e
	db $00, $ff, $f0, $ff, $f8, $ff, $1c, $ff, $04, $ff, $04, $ff, $00, $ff, $0c, $f3
	db $08, $07, $f0, $0f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $00, $00, $00
	db $01, $ff, $01, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $80, $ff, $80, $ff, $40, $ff, $20, $ff, $00, $ff, $20, $df
	db $20, $df, $20, $df, $20, $df, $00, $ff, $20, $ff, $00, $ff, $18, $ff, $0c, $ff
	db $06, $ff, $01, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $03, $fc, $08, $f7, $10, $ef, $11, $ef, $31, $cf, $18, $c7
	db $04, $cb, $2a, $c5, $25, $c2, $13, $e0, $18, $e0, $0c, $f0, $07, $f8, $00, $ff
	db $00, $ff, $c0, $ff, $70, $ff, $08, $ff, $00, $ff, $08, $f7, $08, $f7, $08, $f7
	db $00, $ff, $00, $ff, $80, $7f, $10, $ef, $c8, $f7, $e8, $f7, $e4, $fb, $cc, $f3
	db $1c, $e3, $a4, $53, $50, $a7, $e8, $07, $10, $0f, $60, $1f, $80, $7f, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $01, $fe
	db $07, $f8, $0c, $f3, $10, $ef, $11, $ee, $11, $ee, $11, $ee, $11, $ee, $08, $ff
	db $04, $ff, $06, $ff, $01, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $00, $ff, $00, $03, $fc, $03, $fc, $02, $fd, $02, $fd, $02, $fd, $02, $fd
	db $02, $fd, $02, $fd, $02, $fd, $04, $fb, $18, $e7, $31, $ce, $67, $98, $8c, $73
	db $38, $c7, $60, $9f, $c0, $3f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $80, $ff, $40, $ff, $30, $ff, $cc, $ff, $32, $ff, $08, $ff, $02, $fd, $0a, $f5
	db $00, $00, $ff, $00, $b8, $47, $30, $cf, $20, $df, $20, $df, $20, $df, $20, $df
	db $20, $df, $20, $df, $40, $bf, $40, $bf, $80, $7f, $80, $7f, $00, $ff, $00, $ff
	db $00, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $00, $00, $00
	db $00, $00, $4f, $47, $1f, $0f, $3d, $1e, $7c, $3d, $79, $7d, $7c, $78, $7c, $7c
	db $7d, $7e, $7b, $7f, $79, $7b, $7b, $39, $3c, $18, $1f, $0f, $4f, $47, $00, $00
	db $00, $00, $ff, $ff, $ff, $ff, $28, $18, $e9, $cb, $ff, $eb, $6b, $ff, $1f, $3f
	db $0f, $1f, $4f, $8f, $ef, $cf, $df, $cf, $1f, $1e, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $ff, $ff, $ff, $ff, $03, $03, $8b, $33, $9f, $3b, $9b, $3f, $9f, $3f
	db $9f, $3f, $9f, $3f, $9f, $3e, $9f, $3e, $1e, $0c, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $ff, $ff, $ff, $ff, $df, $ff, $cf, $df, $9f, $cf, $c7, $8f, $2f, $c7
	db $c7, $67, $67, $03, $63, $f3, $f1, $f3, $70, $e1, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $ff, $ff, $ff, $ff, $e9, $f0, $c9, $e6, $c6, $cf, $df, $8f, $9f, $8f
	db $9f, $8f, $9c, $8e, $df, $8e, $e7, $ce, $f0, $e0, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $ff, $ff, $ff, $ff, $a1, $f0, $7b, $31, $bb, $31, $bb, $f1, $fb, $f1
	db $f9, $f0, $1b, $31, $7b, $31, $7b, $31, $e0, $70, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $ff, $ff, $ff, $ff, $cf, $0f, $af, $cf, $ff, $ef, $ef, $bf, $ff, $3f
	db $7f, $3f, $7f, $bf, $bf, $ef, $ef, $cf, $0f, $0f, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $ff, $ff, $ff, $ff, $0e, $80, $dd, $8e, $df, $8f, $df, $8d, $df, $89
	db $cb, $81, $db, $8d, $dd, $8f, $df, $8e, $00, $80, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $ff, $ff, $ff, $ff, $02, $41, $45, $66, $c7, $67, $47, $e7, $c7, $e7
	db $c7, $e7, $c7, $e7, $c7, $67, $46, $67, $01, $40, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $ff, $ff, $ff, $ff, $f9, $f0, $38, $79, $18, $39, $b8, $19, $98, $19
	db $18, $99, $98, $19, $b8, $19, $78, $39, $79, $f0, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $ff, $ff, $ff, $ff, $00, $80, $98, $b3, $f9, $b3, $b9, $f3, $f9, $f3
	db $f9, $f3, $f9, $f3, $f9, $f3, $f9, $f3, $70, $e1, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $f2, $e2, $f8, $f0, $3c, $38, $be, $3c, $fe, $be, $be, $fe, $fe, $fe
	db $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fc, $fc, $f8, $f8, $f0, $f2, $e2, $00, $00
	db $00, $00, $ff, $00, $e7, $00, $e3, $00, $db, $20, $c3, $3c, $e7, $18, $ff, $00
	db $00, $00, $00, $ff, $ff, $ff, $ef, $f0, $f8, $f1, $f9, $f8, $f8, $fc, $fe, $fc
	db $fc, $fe, $ff, $fe, $ff, $fe, $ff, $fe, $fe, $fc, $ff, $ff, $00, $00, $ff, $ff
	db $ff, $00, $a7, $7f, $7b, $fc, $71, $e7, $53, $e3, $6f, $d3, $f3, $ed, $dd, $ff
	db $de, $ff, $d9, $fe, $ce, $f2, $dc, $fe, $de, $fc, $d8, $fc, $d4, $f8, $dc, $e0
	db $00, $00, $00, $ff, $ff, $ff, $6d, $9e, $8e, $8f, $c6, $87, $c6, $a3, $c0, $b3
	db $d8, $b1, $dc, $b8, $dc, $bc, $dc, $be, $2e, $9f, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $ff, $c7, $ef, $ef, $cf, $ff, $7f, $df, $9f, $7f
	db $7f, $3f, $7f, $3f, $7f, $3f, $7f, $3f, $1f, $3f, $ff, $ff, $00, $00, $ff, $ff
	db $ff, $00, $ff, $ff, $ff, $00, $7f, $de, $de, $ff, $df, $f0, $b0, $c0, $40, $80
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $bf, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f
	db $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $ef, $f0, $f9, $f1, $fb, $f1, $fb, $f1, $fb, $f1
	db $f9, $f0, $fb, $f1, $fb, $f1, $fb, $f1, $e1, $f0, $ff, $ff, $00, $00, $ff, $ff
	db $cc, $f8, $dc, $f8, $dc, $f8, $dc, $f8, $dc, $f8, $d4, $f8, $dc, $f0, $cc, $f0
	db $c4, $f0, $d4, $e0, $d4, $e0, $d4, $e0, $f4, $c0, $f4, $c0, $94, $c0, $d4, $80
	db $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $fe, $fc, $fd, $f8, $f0, $f9, $f9, $f1
	db $f9, $f1, $f1, $f9, $f8, $f9, $f9, $fc, $fd, $fe, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $ef, $1f, $bf, $cf, $ff, $ef, $ef, $bf, $ff, $3f
	db $7f, $3f, $7f, $bf, $af, $ff, $cf, $ef, $df, $0f, $ff, $ff, $00, $00, $ff, $ff
	db $ff, $00, $ff, $ff, $ff, $00, $7f, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00
	db $ff, $00, $ff, $ff, $ff, $00, $ff, $ff, $ff, $ff, $ff, $00, $00, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $5f, $bf, $4f, $e7, $f7, $e3, $e1, $f3, $f3, $f1
	db $f3, $f1, $f1, $f3, $e3, $f3, $f3, $e7, $f7, $0f, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $fc, $ff, $ff, $f9, $fb, $f9, $f9, $f8, $fc, $f8
	db $fe, $fc, $fb, $ff, $ff, $fb, $f9, $fb, $ff, $f8, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $8f, $7f, $9f, $cf, $df, $ef, $ef, $ff, $7f, $3f
	db $1f, $1f, $8f, $1f, $9f, $cf, $8f, $df, $df, $3f, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $01, $fe, $01, $fe
	db $02, $fd, $02, $fd, $02, $fd, $02, $fd, $00, $ff, $00, $ff, $02, $ff, $02, $ff
	db $02, $ff, $02, $ff, $02, $ff, $02, $ff, $03, $ff, $03, $ff, $01, $ff, $01, $ff
	db $00, $ff, $00, $ff, $03, $fc, $1f, $e0, $78, $87, $e0, $1f, $82, $7c, $05, $f8
	db $0a, $f1, $08, $f7, $18, $e7, $10, $ef, $10, $ef, $10, $ef, $10, $ef, $00, $ff
	db $10, $ff, $10, $ff, $18, $ff, $08, $ff, $0c, $ff, $04, $ff, $84, $ff, $c6, $ff
	db $c2, $ff, $63, $ff, $31, $ff, $30, $ff, $18, $ff, $0c, $ff, $06, $ff, $03, $ff
	db $00, $ff, $00, $ff, $01, $00, $fe, $01, $00, $ff, $60, $80, $ff, $00, $80, $7f
	db $00, $ff, $00, $ff, $80, $ff, $c0, $ff, $70, $ff, $38, $ff, $0e, $ff, $87, $ff
	db $c0, $ff, $70, $ff, $1c, $ff, $06, $ff, $03, $ff, $01, $ff, $00, $ff, $01, $fe
	db $0c, $f3, $f8, $07, $e0, $1f, $00, $ff, $01, $fe, $3f, $00, $fc, $03, $00, $ff
	db $c0, $ff, $60, $ff, $20, $ff, $30, $ff, $10, $ff, $00, $ff, $10, $ef, $10, $ef
	db $10, $ef, $08, $ff, $84, $ff, $e3, $ff, $70, $ff, $1c, $ff, $0e, $ff, $03, $ff
	db $01, $ff, $01, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $02, $fd, $06, $f9, $0a, $f1, $14, $e3, $08, $07, $c0, $3f, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $c0, $ff, $e0, $ff, $30, $ff, $10, $ff, $18, $ff
	db $08, $ff, $88, $ff, $88, $ff, $88, $ff, $80, $ff, $00, $ff, $08, $f7, $08, $f7
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $05, $fb, $0b, $f7, $13, $ef, $19, $e7
	db $0c, $e3, $26, $c1, $37, $c0, $39, $c0, $1c, $e0, $1f, $e0, $0f, $f0, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $80, $ff, $d0, $ef, $e8, $f7, $e8, $f7
	db $88, $f7, $38, $c7, $e0, $0f, $d0, $0f, $30, $0f, $e0, $1f, $c0, $3f, $00, $ff
	db $00, $ff, $01, $fe, $09, $f0, $06, $e1, $30, $cf, $20, $ff, $18, $ff, $07, $ff
	db $ff, $ff, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe
	db $01, $fe, $01, $fe, $01, $fe, $00, $fe, $01, $fe, $02, $fd, $02, $f9, $04, $e3
	db $58, $87, $20, $1f, $04, $f8, $0e, $f1, $08, $ff, $07, $ff, $00, $ff, $c0, $ff
	db $f8, $ff, $1c, $ff, $06, $ff, $03, $ff, $01, $ff, $00, $ff, $01, $fe, $01, $fe
	db $ff, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $ff, $ff, $10, $ef, $10, $ef, $10, $ef, $10, $ef, $10, $ef, $10, $ef, $10, $ef
	db $10, $ef, $10, $ef, $10, $ef, $10, $ef, $10, $ef, $10, $ef, $10, $cf, $00, $df
	db $20, $9f, $c0, $3f, $80, $7f, $00, $ff, $00, $ff, $00, $ff, $c0, $ff, $60, $ff
	db $10, $ff, $18, $ff, $08, $ff, $08, $ff, $00, $ff, $00, $ff, $08, $f7, $08, $f7
	db $ff, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $00, $00, $00
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $00, $00, $00
	db $88, $77, $88, $77, $88, $77, $88, $77, $88, $77, $88, $77, $ff, $00, $00, $00
	db $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f
	db $3f, $7f, $39, $79, $79, $b9, $a7, $9f, $cb, $c7, $f3, $fb, $e3, $f3, $e3, $e7
	db $eb, $c7, $cb, $8f, $cb, $8f, $cb, $8f, $cb, $8f, $cb, $8f, $cb, $8f, $cb, $8f
	db $cb, $8f, $cb, $8f, $cb, $8f, $cb, $8f, $cb, $8f, $cb, $8f, $cb, $8f, $eb, $cf
	db $eb, $e7, $e3, $f3, $f3, $fb, $cb, $c7, $a7, $9f, $79, $b9, $39, $79, $3f, $7f
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $00, $ff, $00, $00, $00, $00, $00, $00, $ff, $00, $00, $ff
	db $01, $ff, $01, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $00, $00, $00
	db $08, $ff, $88, $ff, $80, $ff, $88, $f7, $08, $f7, $88, $77, $ff, $00, $00, $00
	db $ff, $ff, $01, $fe, $01, $fe, $00, $fe, $01, $fe, $02, $fd, $02, $f9, $04, $e3
	db $ff, $ff, $10, $ef, $10, $ef, $10, $ef, $10, $ef, $10, $ef, $10, $cf, $00, $df
	db $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $ff, $00, $00, $00
	db $7f, $ff, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f
	db $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $ff, $00, $00, $00
	db $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe
	db $ff, $ff, $ff, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $ff, $ff, $ff, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $80, $ff, $c0, $ff, $60, $ff, $20, $ff, $30, $ff, $10, $ff, $10, $ff, $00, $ff
	db $20, $df, $20, $df, $30, $cf, $30, $cf, $30, $cf, $30, $cf, $30, $cf, $30, $cf
	db $30, $cf, $30, $cf, $10, $ef, $20, $ff, $30, $ff, $30, $ff, $98, $7f, $cc, $3f
	db $c6, $3f, $03, $ff, $60, $ff, $3c, $ff, $1f, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $fc, $ff, $0e, $ff, $01, $ff, $e0, $ff, $71, $fe, $11, $fe, $10, $ef
	db $18, $e7, $08, $f7, $06, $ff, $03, $ff, $80, $ff, $d0, $ef, $e8, $f7, $e8, $f7
	db $80, $ff, $60, $ff, $38, $ff, $8c, $ff, $82, $ff, $c0, $ff, $42, $fd, $02, $fd
	db $42, $bd, $61, $9f, $60, $9f, $3e, $df, $07, $ff, $01, $ff, $00, $ff, $00, $ff
	db $00, $ff, $c0, $ff, $60, $ff, $10, $ff, $10, $ff, $00, $ff, $10, $ef, $98, $67
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $f3, $ff, $f7, $ff, $28, $ff, $10, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $42, $85, $a5, $c3, $f6, $e3, $38, $e7, $1c, $f3, $0e, $f9, $00, $f9, $04, $f9
	db $f7, $f9, $02, $ff, $0e, $f3, $14, $e7, $24, $c3, $c9, $00, $98, $00, $00, $00
	db $b9, $c7, $5a, $e7, $38, $ff, $08, $ff, $0c, $ff, $04, $ff, $02, $ff, $00, $ff
	db $00, $00, $80, $03, $83, $07, $87, $07, $87, $0f, $8f, $1f, $9f, $3f, $b9, $39
	db $bf, $39, $bf, $1f, $9f, $0f, $8f, $07, $87, $07, $87, $03, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $fe, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $00, $00, $8f, $1e, $8d, $1f, $8b, $1d, $85, $19, $81, $01
	db $8d, $19, $8f, $1d, $8f, $1f, $8f, $1e, $00, $00, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $7e, $7c, $7f, $7e, $ff, $7f, $7f, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $7f, $ff, $ff, $7f, $7e, $7f, $7e, $7c, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $25, $18, $3f, $19, $07, $1b, $1b, $87, $cf, $87, $c7, $c7
	db $a7, $c3, $d1, $a3, $e3, $31, $78, $71, $68, $30, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $78, $fc, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $fe
	db $ff, $fe, $ff, $fe, $ff, $fe, $ff, $fe, $78, $fc, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $1f, $1f, $3f, $3f, $3f, $3f, $3f, $3f, $3f, $3f, $3f, $3f
	db $3f, $3f, $3f, $3f, $3f, $3f, $3f, $3f, $1f, $1f, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $00, $00, $33, $63, $f3, $63, $73, $e3, $f3, $e3, $f3, $e3
	db $f3, $e3, $f3, $e3, $f3, $e3, $f3, $e3, $e2, $c1, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $3f, $3f, $bf, $3f, $7f, $bf, $bf, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $80, $03, $83, $07, $87, $0f, $8f, $1f, $9f, $3f, $bf, $3f, $bf, $3f
	db $bf, $3f, $bf, $3f, $9f, $3f, $8f, $1f, $87, $0f, $83, $07, $00, $00, $ff, $ff
	db $00, $00, $00, $3f, $8f, $1f, $87, $0f, $83, $07, $83, $03, $83, $03, $83, $03
	db $83, $03, $83, $03, $83, $07, $87, $0f, $8f, $1f, $1f, $3f, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $e4, $fb, $ce, $dc, $9f, $de, $c6, $8f, $c1, $c3
	db $d0, $e1, $b4, $f8, $de, $bc, $fe, $9c, $c1, $81, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $d3, $e1, $f3, $e3, $f7, $e3, $f7, $e3, $f7, $e3
	db $f7, $e3, $f7, $e3, $f7, $e3, $f7, $e3, $c3, $e1, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $ef, $f0, $f9, $f1, $fb, $f1, $fb, $f1, $fb, $f1
	db $f9, $f0, $fb, $f1, $fb, $f1, $fb, $f1, $e1, $f0, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $75, $8b, $d8, $8c, $de, $8c, $dc, $8c, $ca, $81
	db $dd, $88, $dc, $8c, $dc, $8c, $dc, $8c, $0e, $81, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $e0, $80, $9a, $b1, $fb, $b1, $bb, $f1, $fb, $f1
	db $fb, $f1, $fb, $f1, $fb, $f1, $fb, $f1, $f0, $e1, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $f8, $e0, $e6, $ec, $fe, $ec, $ee, $fc, $fe, $fc
	db $fe, $fc, $fe, $fc, $fe, $fc, $fe, $fc, $fc, $f8, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $bf, $7c, $3e, $9e, $8e, $9e, $9e, $8e, $8e, $9e
	db $5e, $3e, $fe, $fe, $fe, $fe, $fe, $fe, $fe, $fc, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $bf, $c3, $e7, $c7, $ef, $47, $6f, $c7, $ef, $c7
	db $ef, $c7, $6f, $c7, $ef, $47, $6f, $c7, $81, $c6, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $7d, $3f, $fc, $3d, $f9, $bc, $bc, $f8, $f2, $fc
	db $fc, $f6, $f0, $f0, $f6, $ef, $ef, $ef, $e7, $ce, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $1e, $0f, $bf, $4f, $ff, $6f, $ef, $7f, $ff, $7f
	db $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $3e, $7f, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $df, $3f, $3f, $7f, $3f, $7f, $3f, $7f, $3f, $7f
	db $3f, $7f, $3f, $7f, $39, $7f, $39, $7b, $73, $03, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $fb, $fc, $e7, $f3, $c7, $e7, $ef, $c7, $cf, $c7
	db $cf, $c7, $cf, $c7, $ef, $87, $73, $a7, $77, $38, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $fc, $fe, $fc, $fc, $7d, $f8, $f9, $78
	db $79, $78, $79, $38, $3d, $38, $1e, $3c, $0f, $1e, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $0d, $00, $9a, $1c, $bf, $1e, $be, $1b, $bf, $13
	db $97, $03, $b7, $1b, $ba, $1f, $bc, $1e, $1d, $00, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $fb, $ff, $f9, $fb, $f3, $f9, $f8, $f1, $e5, $f8
	db $f8, $ec, $e0, $e0, $ec, $de, $de, $de, $8e, $9c, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $7f, $ff, $9c, $3e, $88, $9c, $dd, $88, $c9, $88
	db $c9, $88, $c9, $88, $dc, $88, $3e, $9c, $bf, $7e, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $6a, $9f, $f7, $63, $fb, $f3, $fb, $ff, $ff, $ff
	db $ff, $ff, $c1, $e3, $f7, $e3, $77, $e3, $1e, $07, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $ef, $f1, $f0, $f1, $f5, $f0, $f0, $f4, $f2, $f4
	db $f0, $f6, $f2, $f6, $f3, $f6, $f3, $f7, $e5, $e3, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $ef, $f0, $f8, $f1, $f9, $f8, $f8, $fc, $fe, $fc
	db $fc, $fe, $ff, $7e, $7f, $7e, $3f, $7e, $1e, $3c, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $69, $9e, $e3, $72, $f3, $fa, $fb, $fe, $ff, $fe
	db $ff, $fe, $ff, $fe, $ff, $fe, $77, $fa, $7c, $06, $ff, $ff, $00, $00, $ff, $ff
	db $ff, $ff, $e3, $e3, $c9, $c9, $9c, $9c, $9c, $9c, $80, $80, $9c, $9c, $9c, $9c
	db $ff, $ff, $81, $81, $9c, $9c, $9c, $9c, $81, $81, $9c, $9c, $9c, $9c, $81, $81
	db $ff, $ff, $e1, $e1, $cc, $cc, $9f, $9f, $9f, $9f, $9f, $9f, $cc, $cc, $e1, $e1
	db $ff, $ff, $83, $83, $99, $99, $9c, $9c, $9c, $9c, $9c, $9c, $99, $99, $83, $83
	db $ff, $ff, $80, $80, $9f, $9f, $9f, $9f, $81, $81, $9f, $9f, $9f, $9f, $80, $80
	db $ff, $ff, $80, $80, $9f, $9f, $9f, $9f, $81, $81, $9f, $9f, $9f, $9f, $9f, $9f
	db $ff, $ff, $e1, $e1, $ce, $ce, $9f, $9f, $9f, $9f, $98, $98, $cc, $cc, $e2, $e2
	db $ff, $ff, $9c, $9c, $9c, $9c, $9c, $9c, $80, $80, $9c, $9c, $9c, $9c, $9c, $9c
	db $ff, $ff, $f3, $f3, $f3, $f3, $f3, $f3, $f3, $f3, $f3, $f3, $f3, $f3, $f3, $f3
	db $ff, $ff, $c0, $c0, $f9, $f9, $f9, $f9, $f9, $f9, $b9, $b9, $b1, $b1, $c3, $c3
	db $ff, $ff, $9c, $9c, $99, $99, $93, $93, $87, $87, $83, $83, $91, $91, $98, $98
	db $ff, $ff, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c0, $c0
	db $ff, $ff, $9c, $9c, $88, $88, $80, $80, $80, $80, $94, $94, $9c, $9c, $9c, $9c
	db $ff, $ff, $9c, $9c, $8c, $8c, $84, $84, $80, $80, $90, $90, $98, $98, $9c, $9c
	db $ff, $ff, $c1, $c1, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $c1, $c1
	db $ff, $ff, $81, $81, $9c, $9c, $9c, $9c, $9c, $9c, $81, $81, $9f, $9f, $9f, $9f
	db $ff, $ff, $c1, $c1, $9c, $9c, $9c, $9c, $9c, $9c, $84, $84, $98, $98, $c1, $c1
	db $ff, $ff, $81, $81, $9c, $9c, $9c, $9c, $9c, $9c, $81, $81, $9c, $9c, $9c, $9c
	db $ff, $ff, $c1, $c1, $9c, $9c, $9f, $9f, $c1, $c1, $fc, $fc, $9c, $9c, $c1, $c1
	db $ff, $ff, $81, $81, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7
	db $ff, $ff, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $c1, $c1
	db $ff, $ff, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $c9, $c9, $e3, $e3
	db $ff, $ff, $9c, $9c, $9c, $9c, $9c, $9c, $94, $94, $80, $80, $80, $80, $c9, $c9
	db $ff, $ff, $9c, $9c, $88, $88, $c1, $c1, $e3, $e3, $c1, $c1, $88, $88, $9c, $9c
	db $ff, $ff, $9c, $9c, $9c, $9c, $9c, $9c, $c1, $c1, $e3, $e3, $e3, $e3, $e3, $e3
	db $ff, $ff, $80, $80, $f8, $f8, $f1, $f1, $e3, $e3, $c7, $c7, $8f, $8f, $80, $80
	db $ff, $ff, $c1, $c1, $9c, $9c, $98, $98, $94, $94, $8c, $8c, $9c, $9c, $c1, $c1
	db $ff, $ff, $e7, $e7, $c7, $c7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $c3, $c3
	db $ff, $ff, $c1, $c1, $9c, $9c, $9c, $9c, $f9, $f9, $e7, $e7, $cf, $cf, $80, $80
	db $ff, $ff, $c1, $c1, $9c, $9c, $9c, $9c, $f1, $f1, $9c, $9c, $9c, $9c, $c1, $c1
	db $ff, $ff, $f1, $f1, $e1, $e1, $c9, $c9, $d9, $d9, $99, $99, $80, $80, $f9, $f9
	db $ff, $ff, $80, $80, $9f, $9f, $81, $81, $fc, $fc, $fc, $fc, $9c, $9c, $c1, $c1
	db $ff, $ff, $c1, $c1, $9c, $9c, $9f, $9f, $81, $81, $9c, $9c, $9c, $9c, $c1, $c1
	db $ff, $ff, $80, $80, $9c, $9c, $9c, $9c, $f9, $f9, $f3, $f3, $e7, $e7, $e7, $e7
	db $ff, $ff, $c1, $c1, $9c, $9c, $9c, $9c, $c1, $c1, $9c, $9c, $9c, $9c, $c1, $c1
	db $ff, $ff, $c1, $c1, $9c, $9c, $9c, $9c, $c0, $c0, $fc, $fc, $9c, $9c, $c1, $c1
	db $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $ff, $ff, $e7, $e7
	db $c3, $c3, $81, $81, $99, $99, $f3, $f3, $e7, $e7, $e7, $e7, $ff, $ff, $e7, $e7
	db $ff, $ff, $ff, $ff, $ff, $ff, $c1, $c1, $ff, $ff, $c1, $c1, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $c1, $c1, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $01, $00, $9b, $1c, $bf, $1e, $be, $1b, $bf, $13
	db $97, $03, $b7, $1b, $ba, $1f, $bc, $1e, $1d, $00, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $fe, $f1, $e1, $f1, $f9, $e1, $f9, $e1, $69, $d1
	db $79, $51, $59, $31, $39, $31, $79, $31, $e0, $71, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $ff, $c7, $ef, $ef, $df, $ef, $7f, $df, $9f, $7f
	db $7f, $3f, $7f, $3f, $7f, $3f, $7f, $3f, $1f, $3f, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $f7, $18, $3b, $39, $7b, $37, $77, $2f, $6f, $0f
	db $07, $07, $47, $23, $63, $31, $78, $31, $38, $10, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $ee, $f1, $e7, $ce, $df, $8f, $0f, $9f, $9f, $1f
	db $9f, $1f, $1f, $9f, $8f, $9f, $8f, $cf, $d3, $e0, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $f9, $fe, $f3, $f7, $e7, $f7, $f1, $e3, $f0, $f0
	db $f4, $f8, $ed, $fe, $f7, $ef, $ff, $e7, $ff, $e0, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $df, $e3, $f1, $e3, $fb, $e1, $f1, $e9, $f4, $e9
	db $f0, $ec, $f4, $ec, $f6, $ec, $f6, $ee, $cb, $e6, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $f0, $f8, $fd, $f8, $fd, $f8, $fd, $f8, $fc, $f8
	db $fd, $f8, $fd, $f8, $fd, $f8, $fd, $f8, $f0, $f8, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $83, $e0, $73, $23, $f7, $23, $b7, $e3, $f7, $e3
	db $f3, $e0, $f7, $e3, $f7, $e3, $b7, $63, $43, $e0, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $3f, $ff, $bf, $3f, $ff, $bf, $bf, $ff, $7e, $ff
	db $3f, $7e, $3e, $3e, $be, $3d, $ff, $3d, $fc, $79, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $fd, $e3, $c7, $e3, $f7, $c3, $f7, $c3, $d7, $a3
	db $f7, $a3, $b7, $63, $77, $63, $f7, $63, $c0, $e3, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $df, $3f, $8f, $cf, $ef, $c7, $c7, $cf, $af, $1f
	db $df, $8f, $c7, $cf, $cf, $c7, $c7, $cf, $ef, $1f, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $0f, $1f, $bf, $1f, $be, $1f, $bf, $1e, $bc, $1f
	db $3f, $1d, $bc, $1c, $bd, $1b, $bb, $1b, $09, $13, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $bf, $ff, $9f, $bf, $3f, $9f, $8f, $1f, $5f, $8f
	db $8f, $cf, $cf, $07, $c7, $e7, $e3, $e7, $e0, $c3, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $f7, $ff, $f7, $e7, $e3, $e7, $c7, $e3, $e1, $d3
	db $bb, $d1, $f9, $81, $f9, $b8, $3c, $f8, $54, $38, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $fb, $fc, $fe, $fc, $fe, $fc, $fe, $fc, $fe, $fc
	db $fe, $fc, $fe, $fc, $fe, $fc, $fe, $fc, $f8, $fc, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $7c, $f0, $3c, $78, $7d, $38, $1d, $38, $bd, $18
	db $1c, $98, $1d, $08, $8d, $c8, $c5, $c8, $c0, $80, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $7e, $87, $cf, $8f, $c7, $cf, $ef, $c6, $c3, $e6
	db $e4, $e3, $e3, $f1, $f3, $f1, $f9, $f3, $ff, $fb, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $fc, $c3, $e3, $e7, $e2, $e7, $e1, $e6, $e1, $e4
	db $e0, $e0, $e2, $e4, $e2, $e6, $e3, $e7, $e4, $43, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $ff, $3f, $7f, $7f, $ff, $7f, $ff, $7f, $ff, $7f
	db $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $7f, $3f, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $5f, $3f, $c7, $cf, $e7, $c7, $e7, $c7, $87, $cf
	db $1f, $1f, $1f, $8f, $c7, $8f, $e6, $c7, $e4, $62, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $d7, $38, $fc, $78, $fd, $78, $7d, $f8, $fd, $f8
	db $fc, $f8, $fd, $f8, $fd, $f8, $fd, $f8, $f0, $f8, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $e7, $18, $5c, $b8, $fd, $78, $fd, $f8, $fd, $f8
	db $7c, $f8, $3d, $78, $3d, $38, $3d, $18, $90, $08, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $f9, $fe, $f9, $f3, $f3, $e7, $c3, $e7, $e7, $c7
	db $e7, $c7, $c6, $e7, $e3, $e7, $e7, $f3, $f7, $f8, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $ef, $ff, $ef, $cf, $c7, $cf, $8f, $c7, $c3, $a7
	db $77, $a3, $83, $03, $f3, $71, $79, $71, $a9, $70, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $f7, $0f, $df, $e7, $ff, $f7, $f7, $df, $ff, $9f
	db $bf, $1f, $bf, $df, $d7, $ff, $e7, $f7, $2f, $c7, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $f7, $0f, $df, $e7, $ff, $f7, $f7, $df, $ff, $9f
	db $bf, $1f, $bf, $df, $d7, $ff, $e7, $f7, $2f, $c7, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $ff, $ff, $ff, $5f, $ff, $1f, $9f, $df, $df, $df, $ff, $ff, $ff
	db $ff, $ff, $9f, $0f, $1f, $9f, $1f, $9f, $df, $3f, $ff, $ff, $00, $00, $ff, $ff
	db $00, $00, $00, $1f, $1f, $3f, $3b, $7c, $7e, $7c, $fe, $7c, $fe, $7c, $fe, $7c
	db $fe, $7c, $fe, $7c, $7e, $7c, $3e, $7c, $18, $3c, $0f, $1f, $00, $00, $ff, $ff
	db $00, $00, $00, $1f, $1f, $3f, $20, $70, $39, $71, $3b, $71, $3b, $71, $3b, $71
	db $38, $70, $3a, $71, $3b, $71, $3b, $71, $31, $60, $1f, $3f, $00, $1f, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $f9, $c7, $9d, $b9, $3f, $bd, $8d, $1f, $83, $87
	db $a1, $c3, $69, $f1, $bd, $79, $7b, $39, $83, $03, $ff, $ff, $00, $00, $ff, $ff
	db $9f, $ff, $c0, $7f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f
	db $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f
	db $00, $00, $00, $ff, $ff, $ff, $fb, $07, $6f, $73, $ff, $7b, $fb, $6f, $ff, $4f
	db $5f, $0f, $df, $6f, $eb, $7f, $f3, $7b, $17, $63, $ff, $ff, $00, $00, $ff, $ff
	db $03, $00, $00, $ff, $ff, $ff, $b4, $78, $8c, $98, $cd, $88, $cd, $88, $0d, $98
	db $3c, $38, $3d, $18, $8d, $18, $cd, $88, $c8, $c0, $ff, $ff, $00, $ff, $03, $00
	db $00, $00, $00, $ff, $ff, $ff, $ef, $1f, $8f, $8f, $c7, $8f, $ef, $87, $c3, $a6
	db $f7, $a2, $e2, $b1, $f3, $b1, $f1, $bb, $bf, $1b, $ff, $ff, $00, $00, $ff, $ff
	db $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f
	db $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $00, $80, $00
	db $00, $00, $00, $ff, $ff, $ff, $7d, $83, $cc, $8c, $de, $8c, $de, $8c, $d8, $8c
	db $c1, $81, $d1, $88, $dc, $88, $de, $8c, $0e, $86, $ff, $ff, $00, $00, $ff, $ff
	db $ff, $00, $ff, $ff, $ff, $ff, $c7, $08, $d0, $e4, $fc, $f4, $f5, $dc, $dd, $9d
	db $1d, $1d, $bd, $dd, $d5, $fd, $e5, $f5, $ec, $01, $ff, $ff, $ff, $ff, $ff, $00
	db $00, $00, $00, $ff, $ff, $ff, $f7, $8f, $1f, $8f, $9f, $0f, $9f, $0f, $9e, $8f
	db $9f, $8e, $9e, $8e, $9e, $8d, $9d, $8d, $80, $09, $ff, $ff, $00, $00, $ff, $ff
	db $00, $ff, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $7f, $ff, $7e, $7f, $7f, $7e, $7c, $ff
	db $ff, $fd, $fd, $fc, $7d, $fb, $7f, $7b, $69, $33, $ff, $ff, $00, $00, $ff, $ff
	db $ff, $00, $ff, $ff, $ff, $ff, $ef, $f3, $f7, $77, $37, $77, $17, $37, $17, $17
	db $86, $87, $87, $c6, $e5, $c6, $f6, $e5, $f9, $f4, $ff, $ff, $ff, $ff, $ff, $00
	db $00, $00, $00, $ff, $ff, $ff, $be, $ff, $9f, $bf, $3f, $9f, $8f, $1f, $5f, $8f
	db $8f, $cf, $cf, $07, $c7, $e7, $e3, $e7, $e0, $c3, $ff, $ff, $00, $00, $ff, $ff
	db $00, $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f, $00, $00, $00
	db $01, $fe, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $7f, $ff, $3f, $7f, $7f, $3f, $1f, $3f, $bf, $1f
	db $1f, $9f, $9f, $0f, $8f, $cf, $c7, $cf, $c3, $87, $ff, $ff, $00, $00, $ff, $ff
	db $ff, $00, $ff, $ff, $ff, $ff, $df, $fe, $df, $9f, $8f, $9f, $1f, $8f, $87, $4f
	db $ef, $47, $e7, $07, $e7, $e3, $f3, $e3, $53, $e0, $ff, $ff, $ff, $ff, $ff, $00
	db $00, $00, $00, $ff, $ff, $ff, $ff, $0f, $1f, $3f, $1f, $3f, $1f, $3f, $1f, $3f
	db $1f, $3f, $1f, $3f, $1f, $3e, $1c, $3e, $18, $00, $ff, $ff, $00, $00, $ff, $ff
	db $00, $ff, $fb, $fb, $f3, $f3, $e0, $e0, $c0, $c0, $ff, $ff, $ff, $00, $00, $00
	db $00, $ff, $ff, $ff, $ff, $ff, $03, $03, $03, $03, $ff, $ff, $ff, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $c9, $f7, $9d, $b9, $3f, $bd, $8d, $1f, $83, $87
	db $a1, $c3, $69, $f1, $bd, $79, $ff, $39, $ff, $03, $ff, $ff, $00, $00, $ff, $ff
	db $ff, $00, $ff, $ff, $ff, $ff, $df, $3f, $1e, $1f, $8f, $1e, $df, $0e, $87, $4d
	db $ef, $45, $c5, $63, $e7, $63, $e3, $77, $7f, $36, $ff, $ff, $ff, $ff, $ff, $00
	db $00, $00, $00, $ff, $ff, $ff, $f7, $0f, $8f, $9f, $8f, $9f, $8f, $9f, $8f, $9f
	db $8f, $9f, $8f, $9f, $8e, $9f, $8e, $9e, $9c, $00, $ff, $ff, $00, $00, $ff, $ff
	db $00, $7f, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7f, $00, $00, $00
	db $00, $7f, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7f, $00, $00, $00
	db $00, $00, $00, $ff, $ff, $ff, $ff, $c0, $e3, $e7, $e3, $e7, $e3, $e6, $e0, $e6
	db $e6, $e0, $e3, $e6, $e2, $e7, $e3, $e7, $e5, $c2, $ff, $ff, $00, $00, $ff, $ff
	db $c0, $00, $00, $ff, $ff, $ff, $ef, $10, $39, $11, $bb, $11, $bb, $11, $bb, $11
	db $b9, $10, $bb, $11, $bb, $11, $bb, $11, $00, $11, $ff, $ff, $00, $ff, $80, $00
	db $3e, $e3, $0c, $f7, $f5, $fb, $fb, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $f8, $ff, $f8, $f9, $f8, $fb, $f8, $ff, $f8, $fb, $fe, $fd, $fe, $ff, $fc
	db $00, $ff, $1c, $1c, $6c, $6c, $6c, $6c, $6c, $6c, $1c, $1c, $ff, $00, $00, $00
	db $00, $ff, $0c, $0c, $7c, $7c, $1c, $1c, $7c, $7c, $0c, $0c, $ff, $00, $00, $00
	db $00, $00, $00, $f8, $f8, $fc, $fc, $3e, $be, $3e, $ff, $be, $bf, $fe, $ff, $fe
	db $ff, $fe, $ff, $fe, $fe, $de, $dc, $9e, $38, $1c, $f0, $f8, $00, $00, $ff, $ff
	db $00, $00, $00, $f8, $f8, $fc, $ec, $1e, $bc, $ce, $fc, $ee, $ec, $be, $fc, $3e
	db $7c, $3e, $7c, $be, $ac, $fe, $cc, $ee, $5c, $8e, $f8, $fc, $00, $f8, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $fd, $ff, $f3, $f3, $81, $e3, $00, $00, $00
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $19, $19, $f9, $f9, $39, $39, $f9, $f9, $18, $18, $ff, $00, $00, $00
	db $00, $ff, $d8, $d8, $59, $59, $19, $19, $99, $99, $d8, $d8, $ff, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $01, $fe, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $fe, $3f, $3e, $ff, $00, $00, $00
	db $01, $fe, $7f, $7e, $bf, $be, $bf, $be, $bf, $be, $7f, $7e, $ff, $00, $00, $00

Data_15_624e:
	INCBIN "raw_gfx/Data_15_624e.2bpp", 0, 768

Data_15_654e:
	db $c8, $08, $6d, $1d, $32, $32, $f7, $4a, $40, $24, $e0, $40, $a0, $5d, $60, $7a
	db $c6, $0c, $84, $08, $42, $04, $00, $00, $06, $00, $08, $00, $6d, $1d, $c8, $08
	db $80, $00, $00, $01, $6d, $1d, $c8, $08, $88, $00, $10, $01, $6d, $1d, $c8, $08
	db $c8, $08, $6d, $1d, $f7, $4a, $32, $32, $f7, $4a, $32, $32, $6d, $1d, $c8, $08
	db $00, $00, $d6, $5a, $e7, $1c, $6d, $1d, $00, $00, $ad, $35, $00, $34, $a0, $01
	db $00, $00, $6b, $2d, $00, $2c, $60, $01, $00, $00, $29, $25, $00, $24, $20, $01
	db $00, $00, $e7, $1c, $00, $1c, $e0, $00, $00, $00, $a5, $14, $00, $14, $a0, $00
	db $00, $00, $63, $0c, $00, $0c, $60, $00, $00, $00, $21, $04, $00, $04, $20, $00
	db $04, $14, $24, $66, $d4, $65, $d6, $de, $ee, $ef, $ef, $ef, $ef, $ef, $ef, $ef
	db $ef, $ef, $ef, $ef, $ef, $ef, $ef, $ee, $de, $d6, $d7, $df, $28, $28, $28, $28
	db $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $df, $d7, $e6, $28
	db $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28
	db $28, $e6, $e7, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28
	db $28, $28, $28, $28, $28, $e7, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07
	db $27, $27, $27, $27, $27, $27, $27, $27, $27, $27, $07, $07, $00, $00, $00, $00
	db $00, $00, $00, $00, $20, $20, $20, $20, $20, $20, $20, $20, $27, $27, $07, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20, $20, $20, $20, $20, $20
	db $20, $27, $07, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20, $20
	db $20, $20, $20, $20, $20, $27, $0e, $14, $92, $67, $7a, $66, $a8, $a9, $ac, $af
	db $bb, $bd, $bf, $c1, $c3, $c5, $c7, $c9, $cb, $cd, $cf, $d1, $af, $ac, $a9, $a8
	db $00, $aa, $ad, $b0, $bc, $be, $c0, $c2, $c4, $c6, $c8, $ca, $cc, $ce, $d0, $d2
	db $b0, $ad, $aa, $00, $00, $ab, $ae, $00, $21, $21, $21, $21, $21, $21, $21, $21
	db $21, $21, $21, $21, $00, $ae, $ab, $00, $80, $82, $84, $84, $82, $80, $00, $80
	db $82, $92, $92, $82, $80, $00, $80, $82, $94, $94, $82, $80, $81, $83, $85, $85
	db $83, $81, $00, $81, $83, $93, $93, $83, $81, $00, $81, $83, $95, $95, $83, $81
	db $75, $75, $75, $75, $75, $75, $00, $75, $75, $75, $75, $75, $75, $00, $75, $75
	db $75, $75, $75, $75, $75, $75, $75, $75, $75, $75, $00, $75, $75, $75, $75, $75
	db $75, $00, $75, $75, $75, $75, $75, $75, $75, $75, $75, $75, $75, $75, $00, $75
	db $75, $75, $75, $75, $75, $00, $75, $75, $75, $75, $75, $75, $86, $88, $8a, $8c
	db $8e, $90, $00, $86, $88, $8a, $8c, $8e, $90, $00, $86, $88, $8a, $8c, $8e, $90
	db $87, $89, $8b, $8d, $8f, $91, $00, $87, $89, $8b, $8d, $8f, $91, $00, $87, $89
	db $8b, $8d, $8f, $91, $21, $21, $b4, $b8, $21, $ba, $21, $ba, $ba, $ba, $ba, $ba
	db $ba, $21, $ba, $21, $b8, $b4, $21, $21, $00, $b1, $b5, $b9, $00, $42, $44, $46
	db $48, $4a, $4c, $4e, $50, $52, $42, $00, $b9, $b5, $b1, $00, $00, $b2, $b6, $00
	db $00, $43, $45, $47, $49, $4b, $4d, $4f, $51, $53, $43, $00, $00, $b6, $b2, $00
	db $00, $b3, $b7, $00, $00, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $00
	db $00, $b7, $b3, $00, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $21, $21, $21, $21, $21, $01, $01, $01, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $21, $21, $21, $01, $21, $01, $01, $21
	db $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $41, $01, $21, $21, $01
	db $03, $03, $03, $23, $23, $23, $21, $04, $04, $04, $24, $24, $24, $21, $05, $05
	db $05, $25, $25, $25, $03, $03, $03, $23, $23, $23, $21, $04, $04, $04, $24, $24
	db $24, $21, $05, $05, $05, $25, $25, $25, $08, $08, $08, $08, $08, $08, $21, $08
	db $08, $08, $08, $08, $08, $21, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $21, $08, $08, $08, $08, $08, $08, $21, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $21, $08, $08, $08, $08, $08, $08, $21, $08, $08
	db $08, $08, $08, $08, $03, $03, $03, $03, $03, $03, $21, $04, $04, $04, $04, $04
	db $04, $21, $05, $05, $05, $05, $05, $05, $03, $03, $03, $03, $03, $03, $21, $04
	db $04, $04, $04, $04, $04, $21, $05, $05, $05, $05, $05, $05, $41, $41, $01, $01
	db $41, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $61, $21, $21, $61, $61
	db $21, $01, $01, $01, $21, $02, $02, $02, $02, $02, $02, $02, $02, $02, $22, $01
	db $21, $21, $21, $01, $21, $01, $01, $21, $21, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $22, $01, $01, $21, $21, $01, $21, $01, $01, $21, $21, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $21, $21, $01, $0e, $14, $c8, $69
	db $b0, $68, $32, $33, $33, $33, $3e, $33, $33, $33, $33, $32, $32, $33, $33, $33
	db $33, $33, $3f, $33, $33, $32, $00, $21, $21, $21, $21, $21, $21, $21, $21, $00
	db $00, $21, $21, $21, $21, $21, $21, $21, $21, $00, $00, $54, $58, $60, $68, $70
	db $78, $00, $54, $00, $00, $54, $5e, $66, $6e, $76, $7e, $06, $54, $00, $00, $55
	db $59, $61, $69, $71, $79, $01, $55, $00, $00, $55, $5f, $67, $6f, $77, $7f, $07
	db $55, $00, $00, $20, $20, $20, $20, $20, $20, $20, $20, $00, $00, $20, $20, $20
	db $20, $20, $20, $20, $20, $00, $00, $54, $5a, $62, $6a, $72, $7a, $02, $54, $00
	db $00, $54, $08, $10, $18, $20, $28, $30, $54, $00, $00, $55, $5b, $63, $6b, $73
	db $7b, $03, $55, $00, $00, $55, $09, $11, $19, $21, $29, $31, $55, $00, $00, $20
	db $20, $20, $20, $40, $20, $20, $20, $00, $00, $20, $20, $20, $20, $20, $20, $20
	db $20, $00, $34, $54, $5c, $64, $6c, $74, $7c, $04, $54, $00, $00, $54, $0a, $12
	db $1a, $22, $2a, $32, $54, $34, $35, $55, $5d, $65, $6d, $75, $7d, $05, $55, $00
	db $00, $55, $0b, $13, $1b, $23, $2b, $33, $55, $35, $36, $1b, $1b, $1b, $1b, $20
	db $20, $20, $20, $21, $21, $20, $20, $20, $20, $41, $1b, $1b, $1b, $36, $37, $38
	db $00, $00, $00, $42, $44, $46, $48, $4a, $4c, $4e, $50, $52, $42, $00, $00, $00
	db $38, $37, $12, $39, $3a, $00, $00, $43, $45, $47, $49, $4b, $4d, $4f, $51, $53
	db $43, $00, $00, $3a, $39, $12, $13, $15, $3b, $3c, $00, $1b, $1b, $1b, $1b, $1b
	db $1b, $1b, $1b, $1b, $1b, $00, $3c, $3b, $15, $13, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $21, $01, $21, $01, $21, $01, $21, $01, $01, $01, $21, $01, $21, $21, $01, $01
	db $21, $01, $01, $02, $02, $02, $02, $02, $02, $0a, $22, $01, $01, $02, $02, $02
	db $02, $02, $02, $0a, $22, $21, $01, $02, $02, $02, $02, $02, $02, $0a, $22, $01
	db $01, $02, $02, $02, $02, $02, $02, $0a, $22, $21, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $21, $01, $02
	db $02, $02, $02, $02, $02, $0a, $22, $01, $01, $02, $0a, $0a, $0a, $0a, $0a, $0a
	db $22, $01, $01, $02, $02, $02, $02, $02, $02, $0a, $22, $01, $01, $02, $0a, $0a
	db $0a, $0a, $0a, $0a, $22, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $21, $01, $01, $01, $01, $01, $01, $01, $21, $01, $02, $02, $02, $02, $02
	db $02, $0a, $22, $01, $01, $02, $0a, $0a, $0a, $0a, $0a, $0a, $22, $21, $01, $02
	db $02, $02, $02, $02, $02, $0a, $22, $01, $01, $02, $0a, $0a, $0a, $0a, $0a, $0a
	db $22, $21, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $21, $21, $21, $21
	db $21, $01, $01, $01, $01, $21, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $22, $01, $21, $21, $21, $21, $01, $01, $01, $01, $01, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $22, $01, $21, $21, $21, $21, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $21, $21
	db $21, $21, $0e, $14, $fe, $6b, $e6, $6a, $01, $04, $08, $0b, $0f, $00, $31, $00
	db $00, $00, $00, $00, $00, $31, $00, $0f, $0b, $08, $04, $01, $02, $05, $00, $00
	db $00, $00, $31, $00, $00, $00, $00, $00, $00, $31, $00, $00, $00, $00, $05, $02
	db $03, $06, $00, $00, $00, $00, $31, $00, $00, $00, $00, $00, $00, $31, $00, $00
	db $00, $00, $06, $03, $00, $07, $09, $00, $00, $00, $31, $00, $00, $00, $00, $00
	db $00, $31, $00, $00, $00, $09, $07, $00, $98, $00, $0a, $0c, $00, $00, $31, $00
	db $00, $00, $00, $00, $00, $31, $00, $00, $0c, $0a, $00, $98, $99, $a0, $0e, $0d
	db $10, $00, $31, $00, $00, $00, $00, $00, $00, $31, $00, $10, $0d, $0e, $a0, $99
	db $9a, $a7, $21, $2a, $2b, $21, $30, $00, $00, $00, $00, $00, $00, $30, $21, $2b
	db $2a, $21, $a7, $9a, $a2, $54, $0c, $14, $1c, $24, $2c, $34, $54, $2f, $2f, $38
	db $40, $48, $50, $58, $60, $68, $70, $a2, $a3, $55, $0d, $15, $1d, $25, $2d, $35
	db $55, $23, $23, $39, $41, $49, $51, $59, $61, $69, $71, $a3, $a4, $54, $5c, $64
	db $6c, $74, $7c, $04, $54, $23, $23, $3a, $42, $4a, $52, $5a, $62, $6a, $72, $a4
	db $a5, $55, $5d, $65, $6d, $75, $7d, $05, $55, $2e, $2e, $3b, $43, $4b, $53, $5b
	db $63, $6b, $73, $a5, $00, $00, $1b, $2c, $2d, $42, $44, $46, $48, $4a, $4c, $4e
	db $50, $52, $42, $2d, $2c, $1b, $00, $00, $12, $14, $16, $19, $1e, $43, $45, $47
	db $49, $4b, $4d, $4f, $51, $53, $43, $1e, $19, $16, $12, $14, $13, $15, $00, $1a
	db $1f, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1f, $1a, $00, $13, $15
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $21, $01, $21
	db $21, $21, $21, $21, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $21, $01, $21, $21, $21, $21, $21, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $21, $01, $21, $21, $21, $21, $21, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $21, $01, $21, $21, $21, $21, $21
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $21, $01, $21
	db $21, $21, $21, $21, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $21, $01, $21, $21, $21, $21, $21, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $21, $21, $21, $21, $21, $21, $21, $21, $21, $01, $02, $0a, $0a
	db $0a, $0a, $0a, $0a, $22, $01, $21, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $21
	db $01, $02, $0a, $0a, $0a, $0a, $0a, $0a, $22, $01, $21, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $21, $01, $02, $02, $02, $02, $02, $02, $0a, $22, $01, $21, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $21, $01, $02, $02, $02, $02, $02, $02, $0a
	db $22, $01, $21, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $21, $01, $01, $21, $01
	db $01, $02, $02, $02, $02, $02, $02, $02, $02, $02, $22, $21, $21, $01, $01, $21
	db $01, $01, $01, $01, $01, $02, $02, $02, $02, $02, $02, $02, $02, $02, $22, $21
	db $21, $21, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $21, $21, $21, $01, $01, $0e, $14, $34, $6e, $1c, $6d, $01, $04
	db $08, $0b, $0f, $00, $31, $00, $00, $00, $00, $00, $00, $31, $00, $0f, $0b, $08
	db $04, $01, $02, $05, $00, $00, $00, $00, $31, $00, $00, $00, $00, $00, $00, $31
	db $00, $00, $00, $00, $05, $02, $03, $06, $00, $00, $00, $00, $31, $00, $00, $00
	db $00, $00, $00, $31, $00, $00, $00, $00, $06, $03, $00, $07, $09, $00, $00, $00
	db $31, $00, $00, $00, $00, $00, $00, $31, $00, $00, $00, $09, $07, $00, $98, $00
	db $0a, $0c, $00, $00, $31, $00, $00, $00, $00, $00, $00, $31, $00, $00, $0c, $0a
	db $00, $98, $99, $a0, $0e, $0d, $10, $00, $31, $00, $00, $00, $00, $00, $00, $31
	db $00, $10, $0d, $0e, $a0, $99, $9a, $a1, $00, $0e, $11, $00, $31, $00, $00, $00
	db $00, $00, $00, $31, $00, $11, $0e, $00, $a1, $9a, $9b, $21, $21, $21, $22, $21
	db $21, $20, $20, $1b, $1b, $20, $20, $21, $21, $22, $21, $21, $21, $9b, $a3, $56
	db $0e, $16, $1e, $26, $2e, $36, $56, $23, $23, $56, $3c, $44, $4c, $54, $5c, $64
	db $56, $a3, $a4, $57, $0f, $17, $1f, $27, $2f, $37, $57, $23, $23, $57, $3d, $45
	db $4d, $55, $5d, $65, $57, $a4, $9e, $1b, $1b, $17, $1c, $20, $20, $20, $20, $21
	db $21, $20, $20, $20, $20, $1c, $17, $1b, $1b, $9e, $00, $00, $00, $18, $1d, $42
	db $44, $46, $48, $4a, $4c, $4e, $50, $52, $42, $1d, $18, $00, $00, $00, $12, $14
	db $16, $19, $1e, $43, $45, $47, $49, $4b, $4d, $4f, $51, $53, $43, $1e, $19, $16
	db $12, $14, $13, $15, $00, $1a, $1f, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b
	db $1b, $1f, $1a, $00, $13, $15, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $21, $21, $21, $21, $21, $21, $21, $21
	db $21, $21, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $21, $21, $21, $21
	db $21, $21, $21, $21, $21, $21, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $21, $21, $21, $21, $21, $21, $21, $21
	db $21, $21, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $21, $21, $21, $21
	db $21, $21, $21, $21, $21, $21, $01, $02, $0a, $0a, $0a, $0a, $0a, $0a, $22, $01
	db $21, $02, $0a, $0a, $0a, $0a, $0a, $0a, $22, $21, $01, $02, $0a, $0a, $0a, $0a
	db $0a, $0a, $22, $01, $21, $02, $0a, $0a, $0a, $0a, $0a, $0a, $22, $21, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $21, $21, $21, $21, $21, $21, $21, $21
	db $21, $21, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $22, $21, $21, $21, $01, $21, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $22, $21, $21, $21, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $21, $21, $21, $01, $01, $0e, $14
	db $6a, $70, $52, $6f, $01, $04, $08, $0b, $0f, $00, $31, $00, $00, $00, $00, $00
	db $00, $31, $00, $0f, $0b, $08, $04, $01, $02, $05, $00, $00, $00, $00, $31, $00
	db $00, $00, $00, $00, $00, $31, $00, $00, $00, $00, $05, $02, $03, $06, $00, $00
	db $00, $00, $31, $00, $00, $00, $00, $00, $00, $31, $00, $00, $00, $00, $06, $03
	db $00, $07, $09, $00, $00, $00, $31, $00, $00, $00, $00, $00, $00, $31, $00, $00
	db $00, $09, $07, $00, $98, $00, $0a, $0c, $00, $00, $31, $00, $00, $00, $00, $00
	db $00, $31, $00, $00, $0c, $0a, $00, $98, $99, $a0, $0e, $0d, $10, $00, $31, $00
	db $00, $00, $00, $00, $00, $31, $00, $10, $0d, $0e, $a0, $99, $9a, $a1, $00, $0e
	db $11, $00, $31, $00, $00, $00, $00, $00, $00, $31, $00, $11, $0e, $00, $a1, $9a
	db $9b, $00, $3e, $4e, $4e, $4e, $6c, $4e, $4e, $4e, $4e, $4e, $4e, $4e, $4e, $4e
	db $4e, $3e, $00, $9b, $9c, $00, $3f, $80, $81, $82, $83, $84, $85, $86, $87, $88
	db $89, $8a, $8b, $8c, $8d, $6d, $00, $9c, $9d, $00, $46, $75, $75, $75, $75, $75
	db $75, $75, $75, $75, $75, $75, $75, $75, $75, $46, $00, $9d, $9e, $00, $46, $8e
	db $8f, $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $a4, $a5, $46, $00, $9e
	db $00, $00, $47, $4f, $4f, $4f, $4f, $4f, $4f, $4f, $4f, $4f, $4f, $4f, $74, $4f
	db $4f, $47, $00, $00, $12, $14, $56, $5e, $5f, $57, $56, $5f, $5e, $57, $66, $6e
	db $76, $7e, $67, $6f, $77, $7f, $12, $14, $13, $15, $00, $1a, $1f, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $1f, $1a, $00, $13, $15, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $21, $21, $21, $21, $21, $21
	db $21, $21, $21, $21, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $21, $21
	db $21, $21, $21, $21, $21, $21, $21, $21, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $21, $21, $21, $21, $21, $21
	db $21, $21, $21, $21, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $21, $21
	db $21, $21, $21, $21, $21, $21, $21, $21, $01, $01, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $2e, $2e, $01, $21, $01, $01, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $01, $21
	db $01, $01, $0e, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $2e, $01, $21, $01, $01, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $2e, $01, $21, $01, $01, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $2e, $2e, $2e, $01, $21, $01, $01, $0e, $0e
	db $0e, $0e, $0e, $2e, $2e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $21
	db $21, $21, $01, $01, $0e, $14, $a0, $72, $88, $71, $01, $04, $08, $0b, $0f, $00
	db $31, $00, $00, $00, $00, $00, $00, $31, $00, $0f, $0b, $08, $04, $01, $02, $05
	db $00, $00, $00, $00, $31, $00, $00, $00, $00, $00, $00, $31, $00, $00, $00, $00
	db $05, $02, $03, $06, $00, $00, $00, $00, $31, $00, $00, $00, $00, $00, $00, $31
	db $00, $00, $00, $00, $06, $03, $00, $07, $09, $00, $00, $00, $31, $00, $00, $00
	db $00, $00, $00, $31, $00, $00, $00, $09, $07, $00, $98, $00, $0a, $0c, $00, $00
	db $31, $00, $00, $00, $00, $00, $00, $31, $00, $00, $0c, $0a, $00, $98, $99, $a0
	db $0e, $0d, $10, $00, $31, $00, $00, $00, $00, $00, $00, $31, $00, $10, $0d, $0e
	db $a0, $99, $9a, $a1, $00, $0e, $11, $00, $31, $00, $00, $00, $00, $00, $00, $31
	db $00, $11, $0e, $00, $a1, $9a, $9b, $21, $21, $21, $22, $21, $21, $20, $20, $1b
	db $1b, $20, $20, $21, $21, $22, $21, $21, $21, $9b, $a3, $54, $d4, $dc, $e4, $ec
	db $f4, $fc, $54, $23, $23, $54, $f8, $d8, $e0, $e8, $f0, $f8, $54, $a3, $a4, $55
	db $d5, $dd, $e5, $ed, $f5, $fd, $55, $23, $23, $55, $f9, $d9, $e1, $e9, $f1, $f9
	db $55, $a4, $9e, $1b, $1b, $17, $1c, $20, $20, $20, $20, $21, $21, $20, $20, $20
	db $20, $1c, $17, $1b, $1b, $9e, $00, $00, $00, $18, $1d, $42, $44, $46, $48, $4a
	db $4c, $4e, $50, $52, $42, $1d, $18, $00, $00, $00, $12, $14, $16, $19, $1e, $43
	db $45, $47, $49, $4b, $4d, $4f, $51, $53, $43, $1e, $19, $16, $12, $14, $13, $15
	db $00, $1a, $1f, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1b, $1f, $1a, $00
	db $13, $15, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $21, $21, $21, $21
	db $21, $21, $21, $21, $21, $21, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $21, $21, $21, $21, $21, $21, $21, $21
	db $21, $21, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $21, $21, $21, $21
	db $21, $21, $21, $21, $21, $21, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $21, $21, $21, $21, $21, $21, $21, $21
	db $21, $21, $01, $02, $02, $02, $02, $02, $02, $02, $22, $01, $21, $02, $02, $02
	db $02, $02, $02, $02, $22, $21, $01, $02, $02, $02, $02, $02, $02, $02, $22, $01
	db $21, $02, $02, $02, $02, $02, $02, $02, $22, $21, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $01, $01
	db $01, $01, $01, $02, $02, $02, $02, $02, $02, $02, $02, $02, $22, $21, $21, $21
	db $01, $21, $01, $01, $01, $01, $01, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $22, $21, $21, $21, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $21, $21, $21, $01, $01, $07, $06, $e8, $73, $be, $73
	db $80, $82, $84, $84, $82, $80, $81, $83, $85, $85, $83, $81, $78, $78, $78, $78
	db $78, $78, $78, $78, $78, $78, $78, $78, $78, $78, $78, $78, $78, $78, $86, $88
	db $8a, $8c, $8e, $90, $87, $89, $8b, $8d, $8f, $91, $03, $03, $03, $23, $23, $23
	db $03, $03, $03, $23, $23, $23, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $03, $03, $03, $03, $03, $03, $03, $03
	db $03, $03, $03, $03

Data_15_7412:
	db $07, $06, $42, $74, $18, $74, $80, $82, $92, $92, $82, $80, $81, $83, $93, $93
	db $83, $81, $78, $78, $78, $78, $78, $78, $78, $78, $78, $78, $78, $78, $78, $78
	db $78, $78, $78, $78, $86, $88, $8a, $8c, $8e, $90, $87, $89, $8b, $8d, $8f, $91
	db $04, $04, $04, $24, $24, $24, $04, $04, $04, $24, $24, $24, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $04, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $07, $06, $9c, $74, $72, $74
	db $80, $82, $94, $94, $82, $80, $81, $83, $95, $95, $83, $81, $78, $78, $78, $78
	db $78, $78, $78, $78, $78, $78, $78, $78, $78, $78, $78, $78, $78, $78, $86, $88
	db $8a, $8c, $8e, $90, $87, $89, $8b, $8d, $8f, $91, $05, $05, $05, $25, $25, $25
	db $05, $05, $05, $25, $25, $25, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $05, $05, $05, $05, $05, $05, $05, $05
	db $05, $05, $05, $05, $6d, $1d, $32, $32, $f7, $4a, $f7, $4a

Data_15_74ce:
	db $f7, $4a, $32, $32, $6d, $1d, $c8, $08, $0e, $00, $16, $00, $f7, $4a, $6d, $1d
	db $40, $01, $20, $02, $f7, $4a, $6d, $1d, $93, $01, $3e, $02, $f7, $4a, $6d, $1d
	db $01, $00, $00, $96, $00

SECTION "analyzed_058000", ROMX[$4000], BANK[$16]

Data_16_4000:
	db $7f, $40, $7f, $48, $7f, $50, $7f, $58, $7f, $60, $7f, $68, $7f, $70, $7f, $71
	db $7f, $72, $7f, $73, $7f, $74

Func_16_4016:
	ld a, $01
	ld [rVBK], a
	ld a, [$c4cc]
	ld c, a
	add a, a
	ld hl, $4000
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, c
	cp $06
	jr nc, Func_16_4036
	ld de, $9000
	ld bc, $0800
	call VramCopy16
	ret
Func_16_4036:
	ld de, $9000
	ld bc, $0020
	call VramCopy16
	ld de, $9140
	ld bc, $0020
	call VramCopy16
	ld de, $9160
	ld bc, $0020
	call VramCopy16
	ld de, $9760
	ld bc, $0020
	call VramCopy16
	ld de, $9080
	ld bc, $0020
	call VramCopy16
	ld de, $91c0
	ld bc, $0020
	call VramCopy16
	ld de, $91e0
	ld bc, $0020
	call VramCopy16
	ld de, $97e0
	ld bc, $0020
	call VramCopy16
	ret

Data_16_407f:
	INCBIN "raw_gfx/Data_16_407f.2bpp", 0, 12800

Data_16_727f:
	db $03, $03, $07, $06, $07, $05, $06, $05, $07, $06, $03, $03, $00, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $01
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $20, $c0, $90, $60, $50, $a0, $50, $a0, $90, $60, $20, $c0, $40, $80, $40, $80
	db $50, $e0, $10, $e0, $60, $80, $50, $e0, $50, $e0, $50, $e0, $10, $e0, $60, $80
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $03, $07, $06, $07, $05, $06, $05, $ff, $06, $13, $03, $10, $01, $11, $01
	db $ff, $01, $01, $01, $01, $01, $01, $01, $ff, $01, $11, $01, $11, $01, $10, $01
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $10, $00, $10, $00, $10, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $10, $00, $10, $00, $10, $00
	db $3f, $c0, $91, $60, $51, $a0, $51, $a0, $9f, $60, $30, $c0, $50, $80, $50, $80
	db $5f, $e0, $11, $e0, $61, $80, $51, $e0, $5f, $e0, $50, $e0, $10, $e0, $70, $80
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $10, $00, $10, $00, $10, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $10, $00, $10, $00, $10, $00
	db $03, $03, $07, $06, $07, $05, $06, $05, $07, $06, $03, $03, $00, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $01
	db $00, $00, $20, $3f, $22, $3f, $25, $3f, $22, $3f, $35, $3f, $12, $1f, $15, $1f
	db $1a, $1f, $09, $0f, $0c, $0f, $06, $07, $03, $03, $01, $01, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $20, $c0, $90, $60, $50, $a0, $50, $a0, $90, $60, $20, $c0, $40, $80, $40, $80
	db $50, $e0, $10, $e0, $60, $80, $50, $e0, $50, $e0, $50, $e0, $10, $e0, $60, $80
	db $00, $00, $fe, $f8, $fe, $f8, $fe, $f8, $fe, $f8, $fe, $f0, $fc, $f0, $fc, $f0
	db $fc, $f0, $7c, $e0, $b8, $e0, $58, $e0, $18, $e0, $f8, $e0, $78, $60, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

Data_16_757f:
	db $11, $08, $08, $00, $00, $08, $10, $08, $00, $f0, $10, $7c, $01, $f0, $30, $06
	db $41, $f0, $30, $06, $41, $f0, $30, $06, $41, $f0, $00, $00, $00, $f0, $00, $00
	db $00, $f0, $00, $00, $00, $f0, $00, $00, $00, $f0, $00, $00, $00, $f0, $00, $00
	db $00, $f0, $00, $00, $00, $f0, $00, $00, $00, $f0, $00, $00, $00, $f0, $88, $64
	db $00, $f0, $90, $6c, $00, $11, $28, $20, $7c, $01, $20, $2c, $06, $01, $30, $2c
	db $06, $41, $28, $28, $62, $00, $28, $30, $6a, $00, $28, $48, $62, $00, $28, $50
	db $6a, $00, $28, $68, $62, $00, $28, $70, $6a, $00, $48, $28, $62, $00, $48, $30
	db $6a, $00, $48, $48, $62, $00, $48, $50, $6a, $00, $48, $68, $62, $00, $48, $70
	db $6a, $00, $08, $88, $64, $00, $08, $90, $6c

SECTION "analyzed_05c000", ROMX[$4000], BANK[$17]

Data_17_4000:
	db $00, $03, $05, $04, $05, $ff

Data_17_4006:
	db $ff, $ff

Data_17_4008:
	db $00, $06, $0c, $01, $02, $06, $02, $ff, $00, $09, $0d, $04, $03, $ff

Data_17_4016:
	db $ff, $ff

Data_17_4018:
	db $00, $0f, $06, $03, $03, $ff

Data_17_401e:
	db $ff, $ff

Data_17_4020:
	db $00, $12, $0c, $01, $01, $06, $01, $ff, $00, $16, $0c, $04, $01, $ff

Data_17_402e:
	db $ff, $ff

Data_17_4030:
	db $00, $18, $07, $06, $03, $ff

Data_17_4036:
	db $ff, $ff

Data_17_4038:
	db $00, $1d, $08, $01, $04, $06, $04, $ff, $00, $24, $09, $04, $05, $ff

Data_17_4046:
	db $ff, $ff

Data_17_4048:
	db $00, $2b, $0a, $01, $01, $06, $01, $ff, $00, $2c, $0c, $04, $03, $09, $03, $ff
	db $00, $2f, $09, $07, $08, $ff

Data_17_405e:
	db $ff, $ff

Data_17_4060:
	db $00, $35, $0b, $01, $01, $ff

Data_17_4066:
	db $ff, $ff

Data_17_4068:
	db $00, $38, $0c, $04, $01, $ff

Data_17_406e:
	db $ff, $ff

Data_17_4070:
	db $00, $3a, $0c, $04, $03, $ff

Data_17_4076:
	db $ff, $ff

Data_17_4078:
	db $01, $0a, $0f, $01, $05, $06, $05, $ff, $06, $06, $0e, $06, $05, $ff

Data_17_4086:
	db $ff, $ff

Data_17_4088:
	db $06, $12, $0e, $01, $01, $ff

Data_17_408e:
	db $ff, $ff

Data_17_4090:
	db $06, $16, $0e, $03, $02, $ff

Data_17_4096:
	db $ff, $ff

Data_17_4098:
	db $06, $2c, $0e, $01, $01, $06, $01, $ff, $06, $38, $0e, $01, $05, $ff

Data_17_40a6:
	db $ff, $ff

Data_17_40a8:
	db $06, $3a, $0e, $04, $01, $ff

Data_17_40ae:
	db $ff, $ff

SECTION "analyzed_05c0b0", ROMX[$40b0], BANK[$17]

Data_17_40b0:
	db $ff

SECTION "analyzed_05c0b1", ROMX[$40b1], BANK[$17]

Func_17_40b1:
	ld a, [wActiveFloor]
	ld c, a
	ld a, [wRoomType]
	ld b, a
	cp $02
	jr nz, Func_17_40c3
	ld a, c
	dec a
	ld [$c55c], a
	ret
Func_17_40c3:
	ld hl, $4000
Func_17_40c6:
	ld a, [hl+]
	cp $ff
	jr z, Func_17_40dd
	cp b
	jr nz, Func_17_40d4
	ld a, [hl+]
	cp c
	jr nz, Func_17_40d5
	jr Func_17_40e3
Func_17_40d4:
	inc hl
Func_17_40d5:
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	inc hl
	jr Func_17_40c6
Func_17_40dd:
	ld a, $ff
	ld [$c55c], a
	ret
Func_17_40e3:
	ld a, [hl+]
	ld [$c55c], a
	ld a, [hl+]
Func_17_40e8:
	ld c, a
	ld a, [hl+]
	ld b, a
	push hl
	ld a, b
	swap a
	add a, b
	add a, c
	ld c, a
	ld b, $00
	ld hl, wFloorGrid
	add hl, bc
	ld d, $04
	ld e, $30
Func_17_40fc:
	xor a
	cp [hl]
	jr nz, Func_17_4101
	ld [hl], e
Func_17_4101:
	inc hl
	inc e
	cp [hl]
	jr nz, Func_17_4107
	ld [hl], e
Func_17_4107:
	inc hl
	inc e
	cp [hl]
	jr nz, Func_17_410d
	ld [hl], e
Func_17_410d:
	inc hl
	inc e
	cp [hl]
	jr nz, Func_17_4113
	ld [hl], e
Func_17_4113:
	inc hl
	inc e
	ld a, $0d
	rst AddAToHL
	dec d
	jr nz, Func_17_40fc
	pop hl
	ld a, [hl+]
	cp $ff
	jr nz, Func_17_40e8
	ret
Func_17_4122:
	ld a, [$c55c]
	cp $ff
	ret z
	cp $05
	jr c, LoadFontTiles
	FAR_CALL $38, Func_38_4000
	ret
; Upload a 64-tile font page from $17:$6118 (+ $400*[$c55c]) to VRAM $9400.
; The font sheet there is Data_17_6918 (ABC.../abc.../0-9). See docs/gfx_loaders.md.
LoadFontTiles:
	xor a
	ldh [rVBK], a
	ld bc, $0400
	ld hl, $6118
	ld a, [$c55c]
	rlca
	rlca
	add a, h
	ld h, a
	ld de, $9400
	call VramCopy16
	ret

Data_17_414c:
	db $18, $75, $20, $75, $30, $75, $38, $75, $48, $75, $58, $75, $60, $75, $68, $75
	db $70, $75, $78, $75, $80, $75, $88, $75, $90, $75, $98, $75, $a0, $75, $a8, $75

Func_17_416c:
	ld a, [$c55c]
	cp $ff
	ret z
	ld c, a
	add a, a
	ld hl, $414c
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, c
	cp $01
	jr z, Func_17_4190
	cp $03
	jr z, Func_17_4190
	cp $04
	jr z, Func_17_4190
	ld a, $06
	ld b, $01
	call Func_00_0716
	ret
Func_17_4190:
	ld a, $05
	ld b, $02
	call Func_00_0716
	ret

Data_17_4198:
	db $e3, $e3, $c9, $c9, $9c, $9c, $9c, $9c, $80, $80, $9c, $9c, $9c, $9c, $ff, $ff
	db $81, $81, $9c, $9c, $9c, $9c, $81, $81, $9c, $9c, $9c, $9c, $81, $81, $ff, $ff
	db $e1, $e1, $cc, $cc, $9f, $9f, $9f, $9f, $9f, $9f, $cc, $cc, $e1, $e1, $ff, $ff
	db $83, $83, $99, $99, $9c, $9c, $9c, $9c, $9c, $9c, $99, $99, $83, $83, $ff, $ff
	db $80, $80, $9f, $9f, $9f, $9f, $81, $81, $9f, $9f, $9f, $9f, $80, $80, $ff, $ff
	db $80, $80, $9f, $9f, $9f, $9f, $81, $81, $9f, $9f, $9f, $9f, $9f, $9f, $ff, $ff
	db $e1, $e1, $ce, $ce, $9f, $9f, $9f, $9f, $98, $98, $cc, $cc, $e2, $e2, $ff, $ff
	db $9c, $9c, $9c, $9c, $9c, $9c, $80, $80, $9c, $9c, $9c, $9c, $9c, $9c, $ff, $ff

Data_17_4218:
	db $f3, $f3, $f3, $f3, $f3, $f3, $f3, $f3, $f3, $f3, $f3, $f3, $f3, $f3, $ff, $ff

Data_17_4228:
	db $c0, $c0, $f9, $f9, $f9, $f9, $f9, $f9, $b9, $b9, $b1, $b1, $c3, $c3, $ff, $ff
	db $9c, $9c, $99, $99, $93, $93, $87, $87, $83, $83, $91, $91, $98, $98, $ff, $ff
	db $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c7, $c0, $c0, $ff, $ff
	db $9c, $9c, $88, $88, $80, $80, $80, $80, $94, $94, $9c, $9c, $9c, $9c, $ff, $ff
	db $9c, $9c, $8c, $8c, $84, $84, $80, $80, $90, $90, $98, $98, $9c, $9c, $ff, $ff
	db $c1, $c1, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $c1, $c1, $ff, $ff
	db $81, $81, $9c, $9c, $9c, $9c, $9c, $9c, $81, $81, $9f, $9f, $9f, $9f, $ff, $ff

Data_17_4298:
	db $c1, $c1, $9c, $9c, $9c, $9c, $9c, $9c, $84, $84, $98, $98, $c1, $c1, $ff, $ff

Data_17_42a8:
	db $81, $81, $9c, $9c, $9c, $9c, $9c, $9c, $81, $81, $9c, $9c, $9c, $9c, $ff, $ff
	db $c1, $c1, $9c, $9c, $9f, $9f, $c1, $c1, $fc, $fc, $9c, $9c, $c1, $c1, $ff, $ff
	db $81, $81, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $ff, $ff

Data_17_42d8:
	db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $c1, $c1, $ff, $ff
	db $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $9c, $c9, $c9, $e3, $e3, $ff, $ff

Data_17_42f8:
	db $9c, $9c, $9c, $9c, $9c, $9c, $94, $94, $80, $80, $80, $80, $c9, $c9, $ff, $ff
	db $9c, $9c, $88, $88, $c1, $c1, $e3, $e3, $c1, $c1, $88, $88, $9c, $9c, $ff, $ff
	db $9c, $9c, $9c, $9c, $9c, $9c, $c1, $c1, $e3, $e3, $e3, $e3, $e3, $e3, $ff, $ff

Data_17_4328:
	db $80, $80, $f8, $f8, $f1, $f1, $e3, $e3, $c7, $c7, $8f, $8f, $80, $80, $ff, $ff

Data_17_4338:
	db $ff, $ff, $ff, $ff, $c7, $c7, $f3, $f3, $c3, $c3, $d3, $d3, $c1, $c1, $ff, $ff
	db $cf, $cf, $cf, $cf, $c3, $c3, $c9, $c9, $c9, $c9, $c9, $c9, $c3, $c3, $ff, $ff
	db $ff, $ff, $ff, $ff, $e1, $e1, $cf, $cf, $cf, $cf, $cf, $cf, $e1, $e1, $ff, $ff
	db $f9, $f9, $f9, $f9, $e1, $e1, $c9, $c9, $c9, $c9, $c9, $c9, $e1, $e1, $ff, $ff
	db $ff, $ff, $ff, $ff, $e3, $e3, $c9, $c9, $c1, $c1, $cf, $cf, $e3, $e3, $ff, $ff
	db $f3, $f3, $e7, $e7, $c3, $c3, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $ff, $ff
	db $ff, $ff, $ff, $ff, $e0, $e0, $c9, $c9, $c9, $c9, $e1, $e1, $f9, $f9, $c3, $c3
	db $cf, $cf, $cf, $cf, $c3, $c3, $c9, $c9, $c9, $c9, $c9, $c9, $c9, $c9, $ff, $ff
	db $e7, $e7, $ff, $ff, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $ff, $ff

Data_17_43c8:
	db $f3, $f3, $ff, $ff, $f3, $f3, $f3, $f3, $f3, $f3, $f3, $f3, $c7, $c7, $ff, $ff

Data_17_43d8:
	db $cf, $cf, $cf, $cf, $c9, $c9, $c3, $c3, $c7, $c7, $c3, $c3, $c9, $c9, $ff, $ff
	db $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $ff, $ff
	db $ff, $ff, $ff, $ff, $c1, $c1, $ca, $ca, $ca, $ca, $ca, $ca, $ca, $ca, $ff, $ff
	db $ff, $ff, $ff, $ff, $c3, $c3, $c9, $c9, $c9, $c9, $c9, $c9, $c9, $c9, $ff, $ff
	db $ff, $ff, $ff, $ff, $e3, $e3, $c9, $c9, $c9, $c9, $c9, $c9, $e3, $e3, $ff, $ff
	db $ff, $ff, $ff, $ff, $c3, $c3, $c9, $c9, $c9, $c9, $c3, $c3, $cf, $cf, $cf, $cf

Data_17_4438:
	db $ff, $ff, $ff, $ff, $e1, $e1, $c9, $c9, $c9, $c9, $e1, $e1, $f9, $f9, $f9, $f9

Data_17_4448:
	db $ff, $ff, $ff, $ff, $d1, $d1, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $ff, $ff
	db $ff, $ff, $ff, $ff, $e1, $e1, $c7, $c7, $e3, $e3, $f9, $f9, $c3, $c3, $ff, $ff
	db $e7, $e7, $e7, $e7, $c1, $c1, $e7, $e7, $e7, $e7, $e7, $e7, $f1, $f1, $ff, $ff
	db $ff, $ff, $ff, $ff, $c9, $c9, $c9, $c9, $c9, $c9, $c9, $c9, $e3, $e3, $ff, $ff
	db $ff, $ff, $ff, $ff, $c9, $c9, $c9, $c9, $eb, $eb, $e3, $e3, $f7, $f7, $ff, $ff
	db $ff, $ff, $ff, $ff, $9c, $9c, $94, $94, $d5, $d5, $c1, $c1, $c9, $c9, $ff, $ff
	db $ff, $ff, $ff, $ff, $c9, $c9, $e3, $e3, $f7, $f7, $e3, $e3, $c9, $c9, $ff, $ff
	db $ff, $ff, $ff, $ff, $99, $99, $c3, $c3, $e7, $e7, $cf, $cf, $9f, $9f, $ff, $ff
	db $ff, $ff, $ff, $ff, $c1, $c1, $f9, $f9, $f3, $f3, $e7, $e7, $c1, $c1, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $cf, $cf, $cf, $cf, $ef, $ef, $df, $df
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $9f, $9f, $9f, $9f, $ff, $ff
	db $cf, $cf, $cf, $cf, $ef, $ef, $df, $df, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $fd, $fd, $fb, $fb, $f7, $f7, $ef, $ef, $df, $df, $bf, $bf, $ff, $ff
	db $ff, $ff, $c1, $c1, $9c, $9c, $98, $98, $94, $94, $8c, $8c, $9c, $9c, $c1, $c1
	db $ff, $ff, $e7, $e7, $c7, $c7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $e7, $c3, $c3
	db $ff, $ff, $c1, $c1, $9c, $9c, $9c, $9c, $f9, $f9, $e7, $e7, $cf, $cf, $80, $80

Data_17_4548:
	db $ff, $ff, $c1, $c1, $9c, $9c, $9c, $9c, $f1, $f1, $9c, $9c, $9c, $9c, $c1, $c1

Data_17_4558:
	db $ff, $ff, $f1, $f1, $e1, $e1, $c9, $c9, $d9, $d9, $99, $99, $80, $80, $f9, $f9
	db $ff, $ff, $80, $80, $9f, $9f, $81, $81, $fc, $fc, $fc, $fc, $9c, $9c, $c1, $c1

Data_17_4578:
	db $ff, $ff, $c1, $c1, $9c, $9c, $9f, $9f, $81, $81, $9c, $9c, $9c, $9c, $c1, $c1
	db $ff, $ff, $80, $80, $9c, $9c, $9c, $9c, $f9, $f9, $f3, $f3, $e7, $e7, $e7, $e7
	db $ff, $ff, $c1, $c1, $9c, $9c, $9c, $9c, $c1, $c1, $9c, $9c, $9c, $9c, $c1, $c1
	db $ff, $ff, $c1, $c1, $9c, $9c, $9c, $9c, $c0, $c0, $fc, $fc, $9c, $9c, $c1, $c1
	db $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f

Data_17_45c8:
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $c3, $c3, $81, $81, $99, $99, $f3, $f3, $e7, $e7, $e7, $e7, $ff, $ff, $e7, $e7

SECTION "analyzed_05e118", ROMX[$6118], BANK[$17]

Data_17_6118:
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $1f, $00, $18, $07, $18, $07
	db $f8, $07, $f8, $07, $80, $7f, $80, $7f, $81, $7e, $10, $00, $10, $00, $10, $00
	db $ff, $00, $ff, $00, $c0, $3f, $c0, $3f, $c0, $3f, $10, $00, $10, $00, $10, $00
	db $ff, $00, $07, $00, $06, $01, $0e, $01, $fe, $01, $fc, $03, $c0, $3f, $c0, $3f
	db $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f, $10, $00, $10, $00, $10, $00
	db $ff, $00, $1f, $00, $0c, $03, $0c, $03, $fc, $03, $18, $07, $1c, $03, $1c, $03
	db $fc, $03, $01, $00, $01, $00, $01, $00, $ff, $00, $f0, $00, $f0, $00, $f0, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $ff, $00, $c0, $3f, $c0, $3f
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $bf, $40, $00, $ff, $00, $ff
	db $00, $ff, $00, $0f, $08, $07, $04, $03, $fc, $03, $7c, $03, $71, $0e, $60, $1f
	db $e0, $1f, $e0, $1f, $00, $ff, $00, $ff, $00, $ff, $20, $1f, $61, $1e, $f0, $0f
	db $e0, $1f, $c0, $3f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $c0, $3f, $c0, $3f
	db $c0, $3f, $c0, $3f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $01, $fe, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $10, $0f, $10, $0f, $10, $0f
	db $f1, $0e, $f0, $0f, $80, $7f, $80, $7f, $80, $7f, $80, $70, $00, $f0, $00, $f0
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $fc, $03, $fb, $f8, $df, $1f
	db $37, $d7, $1d, $ed, $0b, $f7, $17, $e7, $39, $df, $df, $1f, $7f, $7c, $fc, $03
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $01, $fe, $07, $f8
	db $0f, $f3, $16, $e6, $2e, $cf, $40, $a0, $24, $dc, $1f, $ef, $0f, $f3, $07, $f8
	db $01, $fe, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $fc, $03
	db $7f, $7c, $df, $1f, $39, $df, $17, $e7, $0b, $f7, $1d, $ed, $37, $d7, $df, $1f
	db $fb, $f8, $fc, $03, $00, $ff, $00, $ff, $00, $ff, $00, $1f, $18, $07, $1f, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $7f, $80, $7f, $80, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $80, $7f, $e0, $9f
	db $70, $6f, $e8, $e7, $c8, $c7, $e8, $e7, $b0, $af, $6e, $11, $8e, $71, $0e, $f1
	db $03, $fc, $03, $fc, $03, $fc, $0f, $f1, $3b, $c3, $ef, $0f, $f7, $37, $77, $77
	db $ff, $ff, $7f, $7f, $ff, $ff, $4c, $4c, $00, $00, $f0, $f0, $fb, $fb, $ff, $ff
	db $f2, $3e, $e0, $0e, $3b, $c3, $0e, $f0, $03, $fc, $03, $fc, $03, $fc, $0e, $f1
	db $8e, $71, $6e, $11, $b0, $af, $e8, $e7, $c8, $c7, $e8, $e7, $70, $6f, $e0, $9f
	db $80, $7f, $00, $ff, $00, $ff, $00, $ff, $1f, $e0, $10, $e0, $f0, $00, $f0, $00
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $07, $f8
	db $07, $f8, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $01, $fe, $06, $f8, $0d, $f5
	db $bf, $4e, $fe, $3d, $fe, $fd, $f7, $f0, $f7, $f3, $ef, $e7, $f7, $eb, $db, $e9
	db $ff, $dd, $ff, $bd, $f6, $3c, $a3, $71, $df, $3d, $7b, $39, $3f, $1d, $5f, $6d
	db $37, $2b, $ec, $e7, $7d, $7b, $ff, $f8, $de, $fd, $e6, $25, $bf, $4e, $09, $f1
	db $06, $f8, $01, $fe, $00, $ff, $00, $ff, $00, $ff, $0f, $f0, $0f, $f0, $0f, $f0
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $e0, $1f, $1f, $00, $18, $00, $18, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $7f, $80, $00, $ff, $00, $ff
	db $00, $ff, $e0, $1f, $50, $8f, $2c, $c3, $1e, $ed, $0f, $f6, $07, $fb, $c3, $3d
	db $e1, $1e, $f8, $07, $1c, $e3, $06, $f9, $43, $bc, $c5, $38, $85, $7a, $89, $72
	db $0a, $f1, $12, $e5, $1c, $e3, $c0, $3f, $fe, $41, $d7, $92, $fe, $ba, $ef, $ad
	db $ff, $bd, $7f, $3d, $ff, $bd, $ff, $bd, $fe, $bd, $ff, $bd, $ff, $bd, $73, $b1
	db $fd, $b9, $c7, $82, $fe, $41, $c0, $3f, $1c, $e3, $12, $e5, $0a, $f1, $8d, $74
	db $85, $78, $c5, $38, $43, $bc, $0e, $f1, $38, $c7, $e1, $1e, $e7, $18, $07, $f8
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $f8, $07, $18, $07, $18, $07
	db $ff, $00, $01, $00, $c1, $00, $ff, $00, $3f, $c0, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $80, $7f, $60, $1f, $d0, $cf
	db $e8, $e7, $b8, $37, $88, $37, $70, $8f, $00, $ff, $00, $ff, $0c, $f3, $16, $e5
	db $1e, $ed, $0c, $f3, $00, $ff, $00, $ff, $18, $e7, $34, $d3, $b4, $53, $d8, $a7
	db $c0, $bf, $e0, $9f, $f0, $8f, $70, $8f, $60, $9f, $40, $38, $40, $38, $40, $38
	db $87, $78, $07, $f8, $00, $ff, $c0, $3f, $a0, $1f, $a0, $1f, $90, $4f, $50, $8f
	db $30, $cf, $18, $e7, $18, $e7, $18, $e7, $78, $87, $f0, $0f, $c0, $3f, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $f0, $00, $f0, $00, $f0
	db $ff, $00, $fe, $01, $c0, $3f, $80, $7f, $80, $7f, $00, $f0, $00, $f0, $00, $f0
	db $0f, $f0, $01, $00, $c1, $00, $c1, $00, $7f, $80, $70, $80, $00, $f0, $00, $f0
	db $0f, $f0, $01, $80, $01, $80, $01, $80, $7f, $80, $70, $80, $00, $f0, $00, $f0
	db $0f, $f0, $09, $f0, $01, $f0, $01, $e0, $1f, $e0, $10, $e0, $00, $f0, $00, $f0
	db $0f, $f0, $01, $00, $01, $00, $01, $00, $ff, $00, $10, $00, $10, $00, $10, $00
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $fc, $00, $fc, $00, $f8
	db $0f, $f0, $01, $00, $01, $00, $01, $00, $ff, $00, $f0, $00, $00, $f0, $00, $f0
	db $0f, $f0, $0f, $f0, $0f, $f0, $01, $fe, $01, $fe, $10, $00, $10, $00, $10, $00
	db $ff, $ff, $80, $ff, $bf, $ff, $a0, $ff, $a0, $ff, $bf, $e0, $82, $fc, $82, $fc
	db $82, $fc, $82, $fc, $82, $fc, $82, $fc, $83, $fd, $80, $ff, $80, $ff, $ff, $80
	db $03, $00, $07, $00, $00, $00, $01, $01, $2e, $33, $44, $3f, $61, $9e, $09, $86
	db $00, $87, $00, $83, $c0, $bf, $c0, $3f, $03, $80, $30, $87, $0d, $86, $29, $9e
	db $62, $bd, $4e, $b1, $71, $80, $40, $80, $80, $80, $84, $18, $30, $1e, $10, $3e
	db $e2, $3c, $00, $fc, $06, $f8, $01, $fe, $00, $ff, $90, $7f, $e4, $1f, $79, $07
	db $a2, $c1, $21, $c0, $42, $80, $41, $82, $04, $87, $89, $0e, $12, $1c, $64, $38
	db $08, $70, $10, $20, $00, $00, $00, $00, $03, $03, $00, $03, $01, $00, $00, $00
	db $ff, $ff, $01, $fe, $fd, $fe, $05, $fa, $05, $fa, $fd, $02, $41, $7e, $41, $7e
	db $41, $7e, $41, $7e, $41, $7e, $41, $7e, $c1, $fe, $01, $fe, $01, $fe, $ff, $00
	db $ff, $00, $fe, $00, $fd, $00, $3e, $00, $1c, $81, $9a, $00, $3c, $01, $19, $02
	db $9a, $00, $84, $00, $72, $f0, $03, $f0, $82, $00, $04, $00, $27, $0a, $29, $01
	db $2d, $00, $8b, $83, $08, $80, $2c, $00, $6c, $00, $00, $00, $63, $0c, $6f, $00
	db $00, $00, $00, $00, $05, $06, $88, $0f, $70, $9f, $20, $ff, $01, $fe, $02, $fc
	db $84, $f8, $42, $fc, $a3, $7c, $61, $3e, $10, $3f, $30, $1f, $08, $1f, $18, $0f
	db $08, $0f, $0c, $0f, $24, $0f, $2c, $07, $c4, $e7, $00, $e7, $c7, $00, $00, $ff
	db $ff, $ff, $80, $ff, $80, $ff, $83, $fc, $82, $fc, $82, $fc, $82, $fc, $82, $fc
	db $82, $fc, $82, $fc, $bf, $ff, $a0, $ff, $a0, $ff, $bf, $e0, $80, $ff, $ff, $80
	db $ff, $00, $47, $20, $03, $90, $25, $50, $19, $e4, $68, $c0, $42, $80, $88, $04
	db $b1, $00, $0b, $90, $47, $00, $0f, $00, $93, $90, $f1, $a0, $64, $fc, $e8, $f0
	db $d0, $e8, $3c, $c4, $a0, $51, $92, $93, $06, $07, $0c, $0f, $d8, $1f, $81, $3e
	db $1a, $04, $0c, $00, $04, $00, $81, $00, $5f, $80, $9f, $00, $1f, $00, $07, $08
	db $00, $00, $00, $00, $38, $18, $64, $f8, $00, $fc, $00, $fc, $18, $e0, $40, $80
	db $00, $c0, $20, $c0, $20, $c0, $00, $e0, $1d, $fe, $01, $fe, $ff, $00, $ff, $ff
	db $ff, $ff, $01, $fe, $01, $fe, $c1, $3e, $41, $7e, $41, $7e, $41, $7e, $41, $7e
	db $41, $7e, $41, $7e, $fd, $fe, $05, $fa, $05, $fa, $fd, $02, $01, $fe, $ff, $00
	db $9f, $40, $df, $40, $df, $40, $df, $40, $df, $41, $df, $41, $02, $41, $13, $ca
	db $c2, $82, $94, $82, $b6, $84, $b4, $84, $28, $84, $20, $88, $08, $80, $98, $00
	db $80, $11, $91, $00, $23, $07, $a6, $0f, $c6, $03, $61, $80, $80, $00, $00, $00
	db $00, $00, $01, $00, $04, $03, $85, $43, $c3, $01, $c0, $01, $c0, $00, $c0, $04
	db $80, $44, $c2, $04, $c2, $04, $82, $44, $82, $44, $02, $04, $02, $04, $02, $04
	db $02, $04, $02, $04, $02, $04, $02, $04, $02, $04, $02, $04, $02, $04, $ff, $ff
	db $ff, $ff, $80, $ff, $bf, $ff, $a0, $ff, $a0, $ff, $bf, $e0, $82, $fc, $82, $fc
	db $82, $fc, $82, $fc, $82, $fc, $82, $fc, $83, $fd, $80, $ff, $80, $ff, $ff, $80
	db $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80
	db $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80
	db $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80
	db $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80
	db $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80
	db $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $83, $e0
	db $ff, $ff, $01, $fe, $fd, $fe, $05, $fa, $05, $fa, $fd, $02, $41, $7e, $41, $7e
	db $41, $7e, $41, $7e, $41, $7e, $41, $7e, $c1, $fe, $01, $fe, $01, $fe, $ff, $00
	db $c0, $01, $81, $02, $03, $01, $06, $0f, $0c, $1f, $1d, $3e, $3a, $41, $70, $3c
	db $c4, $f8, $88, $f0, $b0, $c0, $40, $20, $02, $80, $87, $00, $0f, $00, $05, $02
	db $02, $01, $01, $00, $40, $00, $e0, $00, $f0, $00, $f8, $00, $3c, $80, $78, $00
	db $f0, $00, $e0, $00, $c0, $00, $01, $80, $02, $01, $05, $02, $13, $0c, $8f, $70
	db $7e, $00, $78, $00, $00, $00, $00, $00, $fc, $00, $fc, $00, $fc, $00, $fc, $00
	db $00, $c0, $c0, $00, $c1, $00, $c0, $01, $02, $01, $03, $01, $01, $00, $00, $ff
	db $ff, $ff, $80, $ff, $80, $ff, $83, $fc, $82, $fc, $82, $fc, $82, $fc, $82, $fc
	db $82, $fc, $82, $fc, $bf, $ff, $a0, $ff, $a0, $ff, $bf, $e0, $80, $ff, $ff, $80
	db $ec, $f0, $d0, $08, $80, $e0, $24, $c0, $44, $80, $84, $00, $04, $00, $3d, $00
	db $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $04, $00, $84, $00, $c4, $00
	db $e4, $00, $64, $80, $70, $80, $b1, $40, $31, $40, $31, $40, $42, $01, $32, $43
	db $b3, $42, $b0, $42, $77, $80, $62, $85, $e3, $05, $c5, $03, $9d, $06, $3e, $08
	db $28, $0a, $0c, $0a, $0a, $14, $1c, $28, $08, $28, $08, $30, $70, $20, $64, $50
	db $a4, $d0, $84, $a0, $6c, $80, $cc, $40, $4c, $40, $cc, $80, $dd, $00, $00, $ff
	db $ff, $ff, $01, $fe, $01, $fe, $c1, $3e, $41, $7e, $41, $7e, $41, $7e, $41, $7e
	db $41, $7e, $41, $7e, $fd, $fe, $05, $fa, $05, $fa, $fd, $02, $01, $fe, $ff, $00
	db $00, $60, $00, $30, $00, $18, $20, $2c, $40, $26, $60, $1b, $58, $11, $57, $11
	db $61, $31, $71, $41, $41, $51, $01, $51, $c1, $31, $b1, $21, $81, $21, $c1, $61
	db $e1, $81, $81, $a1, $01, $a1, $21, $c1, $c3, $83, $81, $83, $03, $81, $83, $03
	db $03, $83, $03, $83, $01, $83, $07, $01, $01, $05, $03, $05, $03, $03, $07, $05
	db $07, $05, $05, $03, $03, $05, $0d, $07, $0d, $0b, $0d, $0b, $03, $0d, $0d, $15
	db $09, $15, $11, $19, $31, $29, $19, $21, $31, $53, $22, $a6, $c4, $0c, $00, $f8

Data_17_6918:
	INCBIN "raw_gfx/Data_17_6918.2bpp", 0, 2048

Data_17_7118:
	db $00, $00, $00, $00, $00, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $55, $00
	db $ff, $00, $ff, $00, $ff, $00, $55, $aa, $ff, $00, $55, $aa, $ff, $00, $55, $aa
	db $aa, $55, $55, $aa, $00, $ff, $55, $aa, $00, $ff, $00, $ff, $aa, $ff, $00, $ff
	db $aa, $ff, $50, $f8, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $58, $a6, $fd, $02, $ed, $03, $ef, $00, $6f, $00, $54, $0b, $c0, $1f, $93, $0d
	db $bd, $03, $3f, $02, $3b, $06, $3b, $04, $32, $0d, $72, $09, $66, $19, $e6, $11
	db $9c, $e0, $9c, $e0, $dc, $a0, $dc, $e0, $9c, $e0, $98, $e0, $9c, $e0, $9c, $60
	db $9e, $e0, $9c, $c0, $9c, $e0, $ac, $c0, $9a, $f0, $06, $f8, $e4, $18, $3e, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $55, $00
	db $ff, $00, $ff, $00, $ff, $00, $55, $aa, $ff, $00, $55, $aa, $ff, $00, $55, $aa
	db $aa, $55, $55, $aa, $00, $ff, $55, $aa, $00, $ff, $00, $ff, $aa, $ff, $00, $ff
	db $aa, $ff, $55, $ff, $1f, $1f, $07, $07, $01, $01, $00, $00, $00, $00, $00, $00
	db $08, $08, $08, $08, $40, $88, $54, $ec, $f0, $0c, $9c, $00, $88, $80, $80, $08
	db $c8, $48, $48, $c8, $48, $88, $88, $88, $a8, $a8, $a8, $a8, $68, $a8, $c8, $48
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $aa, $55, $55, $aa, $00, $ff, $55, $aa, $00, $ff, $00, $ff, $aa, $ff, $00, $ff
	db $aa, $ff, $55, $ff, $ff, $ff, $fc, $fc, $c0, $c0, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $5c, $3f, $b9, $7e, $7c, $f0, $ae, $f0, $9c, $e0, $88, $f0, $3c, $c0, $cc, $30
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $aa, $55, $55, $aa, $00, $ff, $55, $aa, $00, $ff, $00, $ff, $aa, $ff, $00, $fe
	db $a8, $f8, $40, $e0, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $39, $18, $55, $38, $2a, $75, $ff, $61, $5f, $e1
	db $c0, $00, $80, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $ff, $36, $88, $c3, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $aa, $55, $55, $aa, $00, $ff, $55, $aa, $00, $ff, $00, $ff, $80, $c1, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $08, $08, $04, $84, $62, $16, $06, $38
	db $52, $0e, $62, $1c, $e6, $18, $cc, $30, $d1, $a6, $e3, $8f, $ef, $90, $38, $c6
	db $cf, $20, $9f, $41, $1d, $02, $1c, $03, $39, $03, $39, $03, $79, $03, $73, $00
	db $78, $83, $81, $00, $c0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $21, $18, $18, $07, $02, $00, $02, $01, $07, $00, $07, $00, $01, $00, $02, $00
	db $02, $00, $02, $00, $02, $01, $01, $00, $03, $00, $03, $00, $01, $00, $01, $00
	db $aa, $55, $55, $aa, $00, $ff, $55, $aa, $00, $ff, $00, $ff, $aa, $ff, $00, $7f
	db $2a, $3f, $05, $07, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $08, $00
	db $08, $00, $08, $08, $1c, $08, $08, $1c, $1c, $14, $80, $08, $08, $08, $08, $08
	db $88, $c8, $88, $08, $08, $88, $88, $88, $88, $08, $08, $08, $80, $08, $c8, $80
	db $48, $f7, $77, $80, $19, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $10, $e0, $fb, $00, $05, $00
	db $aa, $55, $55, $aa, $00, $ff, $55, $aa, $00, $ff, $00, $ff, $aa, $ff, $00, $ff
	db $aa, $ff, $55, $ff, $0f, $0f, $03, $03, $00, $00, $00, $00, $00, $00, $00, $00
	db $01, $00, $00, $01, $02, $01, $00, $03, $04, $03, $01, $06, $08, $06, $02, $0c
	db $05, $18, $20, $18, $08, $30, $10, $60, $a0, $40, $80, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $80, $70, $f8, $00, $f8, $06, $0e, $01, $07, $00, $83, $00, $43, $00, $21, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $7c, $3f, $c0, $06, $00
	db $aa, $55, $55, $aa, $00, $ff, $55, $aa, $00, $ff, $00, $ff, $aa, $ff, $00, $ff
	db $aa, $ff, $55, $ff, $ff, $ff, $fe, $fe, $78, $78, $00, $00, $00, $00, $00, $00
	db $bd, $c3, $1b, $c3, $7b, $83, $b2, $03, $76, $03, $e1, $06, $c1, $06, $80, $06
	db $0b, $04, $01, $0c, $15, $08, $02, $18, $08, $10, $20, $10, $10, $20, $60, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $40, $3f, $7a, $84, $b0, $00
	db $4a, $29, $00, $00, $a4, $20, $ab, $18, $63, $18, $c7, $30, $69, $41, $71, $52
	db $00, $00, $8c, $31, $94, $52, $bd, $77, $a0, $28, $a8, $4d, $90, $66, $79, $7f
	db $65, $08, $2d, $15, $57, $22, $19, $3b, $65, $08, $49, $00, $71, $00, $b6, $1d
	db $00, $14, $60, $38, $ca, $50, $c7, $65, $00, $14, $63, $20, $05, $29, $87, $49
	db $4a, $29, $00, $00, $a4, $20, $ab, $18, $4a, $29, $00, $00, $a4, $20, $ab, $18
	db $4a, $29, $00, $00, $a4, $20, $ab, $18, $4a, $29, $00, $00, $a4, $20, $ab, $18
	db $4a, $29, $00, $00, $c2, $18, $8b, $20, $4a, $29, $00, $00, $c2, $18, $8b, $20
	db $4a, $29, $00, $00, $c2, $18, $8b, $20, $4a, $29, $00, $00, $85, $10, $e2, $30
	db $4a, $29, $00, $00, $85, $10, $e2, $30, $4a, $29, $00, $00, $85, $10, $e2, $30
	db $4a, $29, $00, $00, $29, $04, $e1, $28

SECTION "analyzed_0646ca", ROMX[$46ca], BANK[$19]

Data_19_46ca:
	db $ff

SECTION "analyzed_0646cb", ROMX[$46cb], BANK[$19]

Data_19_46cb:
	INCBIN "raw_gfx/Data_19_46cb.2bpp", 0, 8192

Data_19_66cb:
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $7f, $3e, $1b, $37, $01, $4b, $00, $ff, $7f, $94, $52, $4a, $29, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $e0, $03, $94, $52, $4a, $29, $00, $00, $e0, $03, $3e, $1b, $37, $01, $4b, $00
	db $07, $14, $dd, $67, $51, $67, $70, $75, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7e
	db $7e, $7e, $7e, $7e, $7e, $7e, $7e, $7e, $75, $70, $71, $76, $97, $97, $97, $97
	db $97, $97, $97, $97, $97, $97, $97, $97, $97, $97, $97, $97, $76, $71, $72, $97
	db $97, $97, $97, $97, $97, $97, $97, $97, $97, $97, $97, $97, $97, $97, $97, $97
	db $97, $72, $73, $97, $97, $97, $97, $97, $97, $97, $97, $97, $97, $97, $97, $97
	db $97, $97, $97, $97, $97, $73, $74, $97, $97, $97, $97, $97, $97, $97, $97, $97
	db $97, $97, $97, $97, $97, $97, $97, $97, $97, $74, $79, $97, $97, $97, $97, $97
	db $97, $97, $97, $97, $97, $97, $97, $97, $97, $97, $97, $97, $97, $7c, $7a, $7f
	db $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f
	db $7f, $7d, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $06, $06, $26, $26, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $06, $06, $06, $06, $06, $06, $26, $26, $06, $06, $06, $06, $06, $06
	db $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $26, $26, $06, $06
	db $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06
	db $26, $26, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $06, $06, $26, $26, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $02, $00
	db $00, $86, $06, $00, $08, $88, $06, $02, $00, $00, $8a, $06, $00, $08, $8c, $06
	db $01, $00, $00, $82, $07, $01, $08, $00, $82, $47, $01, $00, $00, $80, $27, $01
	db $00, $00, $80, $07

Data_19_688f:
	db $02, $00, $00, $8e, $07, $00, $08, $90, $07

; ($1b:$5800 BG + $1b:$5840 OBJ palettes carved into src/gfx/portrait/pashute.asm
; as PashutePortraitPaletteBg / PashutePortraitPaletteObj.)
SECTION "analyzed_06d830", ROMX[$5830], BANK[$1b]

Data_1b_5830:
	db $ff, $7f, $3e, $1b, $37, $01, $4b, $00, $ff, $7f, $94, $52, $4a, $29, $00, $00

SECTION "analyzed_06d870", ROMX[$5870], BANK[$1b]

Data_1b_5870:
	db $e0, $03, $e0, $03, $e0, $03, $e0, $03, $00, $00, $00, $00, $00, $00, $00, $00

SECTION "analyzed_06da3e", ROMX[$5a3e], BANK[$1b]

Data_1b_5a3e:
	db $02, $04, $4c, $5a, $44, $5a, $ac, $b4, $bc, $c4, $ad, $b5, $bd, $c5, $08, $08
	db $08, $08, $08, $08, $08, $08, $0a, $00, $00, $00, $08, $00, $08, $02, $08, $00
	db $10, $04, $08, $00, $18, $06, $08, $00, $20, $08, $08, $10, $00, $0a, $08, $10
	db $08, $0c, $09, $10, $10, $0e, $09, $10, $18, $10, $09, $10, $20, $12, $08, $02
	db $04, $8b, $5a, $83, $5a, $26, $2e, $36, $3e, $27, $2f, $37, $3f, $08, $08, $08
	db $08, $08, $08, $08, $08, $0a, $00, $00, $00, $08, $00, $08, $02, $08, $00, $10
	db $04, $08, $00, $18, $06, $08, $00, $20, $08, $08, $10, $00, $0a, $08, $10, $08
	db $34, $09, $10, $10, $36, $09, $10, $18, $38, $09, $10, $20, $3a, $08, $02, $04
	db $ca, $5a, $c2, $5a, $46, $4e, $56, $5e, $47, $4f, $57, $5f, $08, $08, $08, $08
	db $08, $08, $08, $08, $0a, $00, $00, $00, $08, $00, $08, $02, $08, $00, $10, $04
	db $08, $00, $18, $06, $08, $00, $20, $08, $08, $10, $00, $0a, $08, $10, $08, $3c
	db $09, $10, $10, $3e, $09, $10, $18, $40, $09, $10, $20, $42, $08, $04, $00, $00
	db $14, $08, $00, $08, $16, $08, $10, $00, $18, $08, $10, $08, $1a, $08, $04, $00
	db $00, $1c, $08, $00, $08, $1e, $08, $10, $00, $20, $08, $10, $08, $22, $08, $08
	db $00, $00, $24, $0a, $00, $08, $26, $0a, $00, $10, $28, $0a, $00, $18, $2a, $0a
	db $10, $00, $2c, $0a, $10, $08, $2e, $0a, $10, $10, $30, $0a, $10, $18, $32, $0a
	db $03, $03, $4d, $5b, $44, $5b, $ac, $b4, $bc, $ad, $b5, $bd, $ae, $b6, $be, $08
	db $08, $08, $08, $08, $08, $0d, $08, $08, $03, $03, $65, $5b, $5c, $5b, $6b, $6e
	db $71, $6c, $6f, $72, $ae, $70, $73, $08, $08, $08, $08, $08, $08, $0d, $08, $08
	db $0a, $00, $00, $00, $08, $00, $08, $02, $08, $00, $10, $04, $08, $00, $18, $06
	db $08, $00, $20, $08, $08, $10, $00, $0a, $08, $10, $08, $44, $09, $10, $10, $46
	db $09, $10, $18, $48, $09, $10, $20, $4a, $08, $03, $03, $a6, $5b, $9d, $5b, $74
	db $77, $7a, $75, $78, $7b, $ae, $79, $7c, $08, $08, $08, $08, $08, $08, $0d, $08
	db $08, $0a, $00, $00, $00, $08, $00, $08, $02, $08, $00, $10, $04, $08, $00, $18
	db $06, $08, $00, $20, $08, $08, $10, $00, $0a, $08, $10, $08, $4c, $09, $10, $10
	db $4e, $09, $10, $18, $50, $09, $10, $20, $52, $08, $01, $00, $00, $54, $09, $44
	db $18, $df, $3a, $b0, $45, $ed, $20, $44, $18, $44, $18, $44, $18, $44, $18, $44
	db $18, $44, $18, $b0, $45, $df, $3a, $44, $18, $44, $18, $44, $18, $b0, $45, $44
	db $18, $44, $18, $b0, $45, $ed, $20, $b0, $45, $44, $18, $44, $18, $df, $3a

SECTION "analyzed_06dc1d", ROMX[$5c1d], BANK[$1b]

Data_1b_5c1d:
	db $ff, $03, $5a, $24, $aa, $28, $68, $00, $00, $7c, $7b, $6b, $7b, $3a, $68, $00
	db $1f, $7c, $7b, $6b, $f2, $51, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

SECTION "analyzed_06dc5d", ROMX[$5c5d], BANK[$1b]

Data_1b_5c5d:
	INCBIN "raw_gfx/Data_1b_5c5d.2bpp", 0, 1424

Data_1b_61ed:
	db $00, $10, $00, $78, $00, $f8, $00, $f0, $00, $c0

SECTION "analyzed_06e45d", ROMX[$645d], BANK[$1b]

Data_1b_645d:
	INCBIN "raw_gfx/Data_1b_645d.2bpp", 0, 3696

Data_1b_72cd:
	db $00, $00, $00, $00, $00, $00, $04, $04, $13, $13, $44, $44, $30, $30

SECTION "analyzed_06f45d", ROMX[$745d], BANK[$1b]

Data_1b_745d:
	db $ec, $28, $75, $3a, $7b, $0e, $b4, $01, $ec, $28, $75, $3a, $de, $63, $13, $49
	db $ec, $28, $13, $72, $7b, $0e, $b4, $01, $ec, $28, $13, $49, $7b, $0e, $b4, $01
	db $ec, $28, $13, $49, $13, $72, $b4, $01, $cb, $24, $13, $49, $13, $72, $3d, $77

SECTION "analyzed_06f49d", ROMX[$749d], BANK[$1b]

Data_1b_749d:
	db $e0, $03, $1f, $43, $fc, $21, $de, $63, $00, $7c, $1f, $43, $cc, $01, $f0, $12
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

SECTION "analyzed_06f4dd", ROMX[$74dd], BANK[$1b]

Data_1b_74dd:
	db $0b, $14, $bf, $75, $e3, $74, $80, $88, $90, $98, $a0, $a8, $b0, $b8, $c0, $c8
	db $d0, $d8, $e0, $e8, $f0, $f8, $00, $08, $10, $18, $81, $89, $91, $99, $a1, $a9
	db $b1, $b9, $c1, $c9, $d1, $d9, $e1, $e9, $f1, $f9, $01, $09, $11, $19, $82, $8a
	db $92, $9a, $a2, $aa, $b2, $ba, $c2, $ca, $d2, $da, $e2, $ea, $f2, $fa, $02, $0a
	db $12, $1a, $83, $8b, $93, $9b, $a3, $ab, $b3, $bb, $c3, $cb, $d3, $db, $e3, $eb
	db $f3, $fb, $03, $0b, $13, $1b, $84, $8c, $94, $9c, $a4, $ac, $b4, $bc, $c4, $cc
	db $d4, $dc, $e4, $ec, $f4, $fc, $04, $0c, $14, $1c, $85, $8d, $95, $9d, $a5, $ad
	db $b5, $bd, $c5, $cd, $d5, $dd, $e5, $ed, $f5, $fd, $05, $0d, $15, $1d, $86, $8e
	db $96, $9e, $a6, $ae, $b6, $be, $c6, $ce, $d6, $de, $e6, $ee, $f6, $fe, $06, $0e
	db $16, $1e, $87, $8f, $97, $9f, $a7, $af, $b7, $bf, $c7, $cf, $d7, $df, $e7, $ef
	db $f7, $ff, $07, $0f, $17, $1f, $20, $28, $30, $38, $40, $48, $50, $58, $23, $2b
	db $33, $3b, $43, $4b, $53, $5b, $26, $2e, $36, $3e, $21, $29, $31, $39, $41, $49
	db $51, $59, $24, $2c, $34, $3c, $44, $4c, $54, $5c, $27, $2f, $37, $3f, $22, $2a
	db $32, $3a, $42, $4a, $52, $5a, $25, $2d, $35, $3d, $45, $4d, $55, $5d, $46, $47
	db $4e, $4f, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0a
	db $0a, $0a, $0a, $0a, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0c, $0a, $0a, $0a, $0a, $0a, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0c, $0b, $0b, $0b, $0b, $0a, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0b, $08, $08, $08, $08, $0b
	db $0b, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $08
	db $08, $08, $08, $0b, $0b, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $08, $08, $08, $08, $0b, $0b, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $09, $09, $09, $09, $09, $09, $09, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $09, $09, $09, $09, $09, $09, $09
	db $09, $09, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $09, $09, $09
	db $09, $09, $09, $09, $09, $09, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $01, $04
	db $a5, $76, $a1, $76, $ad, $b5, $bd, $c5, $08, $08, $08, $08, $0f, $00, $00, $14
	db $09, $00, $08, $16, $09, $00, $10, $18, $09, $00, $18, $1a, $09, $00, $20, $14
	db $09, $10, $00, $1c, $09, $10, $08, $1e, $09, $10, $10, $20, $09, $10, $18, $22
	db $09, $10, $20, $24, $09, $20, $00, $26, $08, $20, $08, $28, $08, $20, $10, $2a
	db $08, $20, $18, $2c, $08, $20, $20, $2e, $09, $01, $04, $f0, $76, $ec, $76, $56
	db $57, $be, $c5, $08, $08, $08, $08, $0f, $00, $00, $14, $09, $00, $08, $16, $09
	db $00, $10, $18, $09, $00, $18, $1a, $09, $00, $20, $14, $09, $10, $00, $1c, $09
	db $10, $08, $1e, $09, $10, $10, $20, $09, $10, $18, $22, $09, $10, $20, $24, $09
	db $20, $00, $26, $08, $20, $08, $36, $08, $20, $10, $38, $08, $20, $18, $3a, $08
	db $20, $20, $2e, $09, $01, $04, $3b, $77, $37, $77, $56, $57, $be, $c5, $08, $08
	db $08, $08, $0f, $00, $00, $14, $09, $00, $08, $16, $09, $00, $10, $18, $09, $00
	db $18, $1a, $09, $00, $20, $14, $09, $10, $00, $1c, $09, $10, $08, $1e, $09, $10
	db $10, $20, $09, $10, $18, $22, $09, $10, $20, $24, $09, $20, $00, $26, $08, $20
	db $08, $3c, $08, $20, $10, $3e, $08, $20, $18, $40, $08, $20, $20, $2e, $09, $03
	db $00, $00, $30, $08, $00, $08, $32, $08, $00, $10, $34, $08, $0a, $00, $00, $00
	db $09, $00, $08, $02, $09, $00, $10, $04, $09, $00, $18, $06, $09, $00, $20, $08
	db $09, $10, $00, $0a, $09, $10, $08, $0c, $09, $10, $10, $0e, $09, $10, $18, $10
	db $09, $10, $20, $12, $09, $03, $03, $c1, $77, $b8, $77, $ad, $b5, $bd, $ae, $b6
	db $be, $af, $b7, $bf, $08, $08, $08, $08, $08, $08, $08, $08, $08, $03, $03, $d9
	db $77, $d0, $77, $ad, $b5, $bd, $ae, $b6, $be, $af, $5e, $bf, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $0f, $00, $00, $14, $09, $00, $08, $16, $09, $00, $10
	db $18, $09, $00, $18, $1a, $09, $00, $20, $14, $09, $10, $00, $1c, $09, $10, $08
	db $1e, $09, $10, $10, $20, $09, $10, $18, $22, $09, $10, $20, $24, $09, $20, $00
	db $26, $08, $20, $08, $42, $08, $20, $10, $44, $08, $20, $18, $46, $08, $20, $20
	db $2e, $09, $03, $00, $00, $48, $08, $00, $08, $4a, $08, $00, $10, $4c, $08, $03
	db $03, $3b, $78, $32, $78, $5f, $62, $65, $60, $63, $66, $61, $64, $67, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $0f, $00, $00, $14, $09, $00, $08, $16, $09
	db $00, $10, $18, $09, $00, $18, $1a, $09, $00, $20, $14, $09, $10, $00, $1c, $09
	db $10, $08, $1e, $09, $10, $10, $20, $09, $10, $18, $22, $09, $10, $20, $24, $09
	db $20, $00, $26, $08, $20, $08, $4e, $08, $20, $10, $50, $08, $20, $18, $52, $08
	db $20, $20, $2e, $09, $03, $00, $00, $54, $08, $00, $08, $56, $08, $00, $10, $58
	db $08, $44, $18, $75, $3a, $3b, $22, $2f, $31, $44, $18, $11, $4e, $de, $63, $44
	db $18, $44, $18, $44, $18, $3b, $22, $2f, $31, $44, $18, $44, $18, $3b, $22, $2f
	db $31, $44, $18, $44, $18, $44, $18, $2f, $31, $44, $18, $44, $18, $44, $18, $44
	db $18

SECTION "analyzed_06f8ce", ROMX[$78ce], BANK[$1b]

Data_1b_78ce:
	db $e0, $03, $fe, $46, $b1, $49, $de, $63, $00, $7c, $fe, $46, $69, $3d, $8c, $26

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

SECTION "analyzed_07d855", ROMX[$5855], BANK[$1f]

Func_1f_5855:
	ld a, [hJoyPressed]
	bit 4, a
	jr z, Func_1f_5868
	ld a, [hl]
	cp b
	jr z, Func_1f_5868
	inc [hl]
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
Func_1f_5868:
	ld a, [hJoyPressed]
	bit 5, a
	jr z, Func_1f_587b
	ld a, [hl]
	cp c
	jr z, Func_1f_587b
	dec [hl]
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
Func_1f_587b:
	ret
Func_1f_587c:
	ld hl, $d601
	ld a, [$d602]
	dec a
	ld b, a
	ld c, $00
	ld a, [hJoyPressed]
	bit 7, a
	jr z, Func_1f_58ae
	ld a, [hl]
	cp b
	ret z
	inc [hl]
	ld hl, $d60b
	ld a, [hl]
	cp $02
	jr z, Func_1f_58a2
	inc [hl]
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ret
Func_1f_58a2:
	ld hl, $d60c
	inc [hl]
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ret
Func_1f_58ae:
	ld a, [hJoyPressed]
	bit 6, a
	jr z, Func_1f_58d6
	ld a, [hl]
	cp c
	ret z
	dec [hl]
	ld hl, $d60b
	ld a, [hl]
	cp $00
	jr z, Func_1f_58ca
	dec [hl]
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ret
Func_1f_58ca:
	ld hl, $d60c
	dec [hl]
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
	ret
Func_1f_58d6:
	ret
ShowYesNoMenu:
	ld de, $996d
	ld bc, $0707
	call ScriptOpcode05Helper
	ld hl, $5942
	ld de, $9990
	call CopyBgMap
	xor a
	ld [wYNResult], a
Func_1f_58ed:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_590b
	call HideUnusedOamSprites
	call DrawTextWindow
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_590b:
	ld a, [hJoyPressed]
	and $c0
	jr z, Func_1f_5921
	ld hl, wYNResult
	ld a, [hl]
	inc a
	and $01
	ld [hl], a
	push af
	ld a, SOUND_SFX_Cursor
	call PlaySound
	pop af
Func_1f_5921:
	call Func_1f_592a
	call HideUnusedOamSprites
	jp Func_1f_58ed
Func_1f_592a:
	ld bc, $7478
	ld a, [wYNResult]
	sla a
	sla a
	sla a
	sla a
	add a, b
	ld b, a
	call Func_1f_65be
	ld hl, $d612
	inc [hl]
	ret

Data_1f_5942:
	db $04, $03, $54, $59, $48, $59, $97, $97, $97, $20, $9c, $aa, $97, $97, $97, $15
	db $a6, $97, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07

Toamuna_ShowMenu2:
	ld de, $98ca
	ld bc, $0904
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_596d:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5985
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5985:
	ld hl, wMainMenuResult
	ld bc, $0200
	call Func_1f_5855
	ld hl, $59cd
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98eb
	call CopyBgMap
	call Func_1f_59ae
	call HideUnusedOamSprites
	jp Func_1f_596d
Func_1f_59ae:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_59bb
	ld bc, $4858
	call Func_1f_65ec
Func_1f_59bb:
	ld a, [wMainMenuResult]
	cp $02
	jr z, Func_1f_59c8
	ld bc, $4898
	call Func_1f_65be
Func_1f_59c8:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_59cd:
	db $56, $5a, $78, $5a, $9a, $5a

Toamuna_ShowMenu1:
	ld de, $98ca
	ld bc, $0904
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_59e0:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5a08
	ld hl, $5a54
	ld a, [wMainMenuResult]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	ld [wMainMenuResult], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5a08:
	ld hl, wMainMenuResult
	ld bc, $0100
	call Func_1f_5855
	ld hl, $5a50
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98eb
	call CopyBgMap
	call Func_1f_5a31
	call HideUnusedOamSprites
	jp Func_1f_59e0
Func_1f_5a31:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_5a3e
	ld bc, $4858
	call Func_1f_65ec
Func_1f_5a3e:
	ld a, [wMainMenuResult]
	cp $01
	jr z, Func_1f_5a4b
	ld bc, $4898
	call Func_1f_65be
Func_1f_5a4b:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_5a50:
	db $56, $5a, $9a, $5a, $00, $02, $02, $07, $6a, $5a, $5c, $5a, $b8, $c0, $c8, $97
	db $97, $97, $97, $b9, $c1, $c9, $97, $97, $97, $97, $07, $07, $07, $06, $06, $06
	db $06, $06, $06, $06, $06, $06, $06, $06, $02, $07, $8c, $5a, $7e, $5a, $d0, $d8
	db $e0, $e8, $f0, $97, $97, $d1, $d9, $e1, $e9, $f1, $97, $97, $07, $07, $07, $07
	db $07, $06, $06, $06, $06, $06, $06, $06, $06, $06, $02, $07, $ae, $5a, $a0, $5a
	db $84, $8e, $97, $97, $97, $97, $97, $85, $8f, $97, $97, $97, $97, $97, $07, $07
	db $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06

Naji_ShowMenu2:
	ld de, $98cc
	ld bc, $0804
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_5ac9:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5af1
	ld hl, $5b3f
	ld a, [wMainMenuResult]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	ld [wMainMenuResult], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5af1:
	ld hl, wMainMenuResult
	ld bc, $0200
	call Func_1f_5855
	ld hl, $5b39
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ed
	call CopyBgMap
	call Func_1f_5b1a
	call HideUnusedOamSprites
	jp Func_1f_5ac9
Func_1f_5b1a:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_5b27
	ld bc, $4a68
	call Func_1f_65ec
Func_1f_5b27:
	ld a, [wMainMenuResult]
	cp $02
	jr z, Func_1f_5b34
	ld bc, $4aa0
	call Func_1f_65be
Func_1f_5b34:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_5b39:
	db $fe, $5c, $3a, $5d, $58, $5d, $01, $03, $04

Naji_ShowMenu3a:
	ld de, $98cc
	ld bc, $0804
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_5b4f:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5b77
	ld hl, $5bc7
	ld a, [wMainMenuResult]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	ld [wMainMenuResult], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5b77:
	ld hl, wMainMenuResult
	ld bc, $0300
	call Func_1f_5855
	ld hl, $5bbf
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ed
	call CopyBgMap
	call Func_1f_5ba0
	call HideUnusedOamSprites
	jp Func_1f_5b4f
Func_1f_5ba0:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_5bad
	ld bc, $4a68
	call Func_1f_65ec
Func_1f_5bad:
	ld a, [wMainMenuResult]
	cp $03
	jr z, Func_1f_5bba
	ld bc, $4aa0
	call Func_1f_65be
Func_1f_5bba:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_5bbf:
	db $e0, $5c, $fe, $5c, $3a, $5d, $58, $5d, $00, $01, $03, $04

Naji_ShowMenu3b:
	ld de, $98cc
	ld bc, $0804
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_5bd8:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5c00
	ld hl, $5c50
	ld a, [wMainMenuResult]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	ld [wMainMenuResult], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5c00:
	ld hl, wMainMenuResult
	ld bc, $0300
	call Func_1f_5855
	ld hl, $5c48
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ed
	call CopyBgMap
	call Func_1f_5c29
	call HideUnusedOamSprites
	jp Func_1f_5bd8
Func_1f_5c29:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_5c36
	ld bc, $4a68
	call Func_1f_65ec
Func_1f_5c36:
	ld a, [wMainMenuResult]
	cp $03
	jr z, Func_1f_5c43
	ld bc, $4aa0
	call Func_1f_65be
Func_1f_5c43:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_5c48:
	db $fe, $5c, $1c, $5d, $3a, $5d, $58, $5d, $01

Data_1f_5c51:
	db $02, $03, $04

Naji_ShowMenu4:
	ld de, $98cc
	ld bc, $0804
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_5c61:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5c89
	ld hl, $5cdb
	ld a, [wMainMenuResult]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	ld [wMainMenuResult], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5c89:
	ld hl, wMainMenuResult
	ld bc, $0400
	call Func_1f_5855
	ld hl, $5cd1
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ed
	call CopyBgMap
	call Func_1f_5cb2
	call HideUnusedOamSprites
	jp Func_1f_5c61
Func_1f_5cb2:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_5cbf
	ld bc, $4a68
	call Func_1f_65ec
Func_1f_5cbf:
	ld a, [wMainMenuResult]
	cp $04
	jr z, Func_1f_5ccc
	ld bc, $4aa0
	call Func_1f_65be
Func_1f_5ccc:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_5cd1:
	db $e0, $5c, $fe, $5c, $1c, $5d, $3a, $5d, $58, $5d, $00, $01, $02, $03, $04, $02
	db $06, $f2, $5c, $e6, $5c, $d8, $e0, $e8, $f0, $97, $97, $d9, $e1, $e9, $f1, $97
	db $97, $07, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06, $02, $06, $10
	db $5d, $04, $5d, $b8, $c0, $c8, $d0, $97, $97, $b9, $c1, $c9, $d1, $97, $97, $07
	db $07, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06, $02, $06, $2e, $5d, $22
	db $5d, $ea, $f2, $fa, $bc, $c4, $cc, $eb, $f3, $fb, $bd, $c5, $cd, $07, $07, $07
	db $07, $07, $07, $06, $06, $06, $06, $06, $06, $02, $06, $4c, $5d, $40, $5d, $90
	db $92, $97, $97, $97, $97, $91, $93, $97, $97, $97, $97, $07, $07, $06, $06, $06
	db $06, $06, $06, $06, $06, $06, $06, $02, $06, $6a, $5d, $5e, $5d, $f8, $ba, $c2
	db $ca, $97, $97, $f9, $bb, $c3, $cb, $97, $97, $07, $07, $07, $07, $06, $06, $06
	db $06, $06, $06, $06, $06

Naji_ShowSubMenu2:
	ld de, $98cc
	ld bc, $0804
	call ScriptOpcode05Helper
	xor a
	ld [wSubMenuCursor], a
Func_1f_5d83:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5d9b
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5d9b:
	ld hl, wSubMenuCursor
	ld bc, $0200
	call Func_1f_5855
	ld hl, $5de3
	ld a, [wSubMenuCursor]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ed
	call CopyBgMap
	call Func_1f_5dc4
	call HideUnusedOamSprites
	jp Func_1f_5d83
Func_1f_5dc4:
	ld a, [wSubMenuCursor]
	cp $00
	jr z, Func_1f_5dd1
	ld bc, $4a68
	call Func_1f_65ec
Func_1f_5dd1:
	ld a, [wSubMenuCursor]
	cp $02
	jr z, Func_1f_5dde
	ld bc, $4aa0
	call Func_1f_65be
Func_1f_5dde:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_5de3:
	db $e9, $5d, $07, $5e, $25, $5e, $02, $06, $fb, $5d, $ef, $5d, $fe, $00, $02, $04
	db $97, $97, $ff, $01, $03, $05, $97, $97, $07, $07, $07, $07, $06, $06, $06, $06
	db $06, $06, $06, $06, $02, $06, $19, $5e, $0d, $5e, $d2, $da, $e2, $97, $97, $97
	db $d3, $db, $e3, $97, $97, $97, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $02, $06, $37, $5e, $2b, $5e, $94, $b3, $b5, $97, $97, $97, $95, $b4
	db $b6, $97, $97, $97, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06, $06

Bodka_ShowMenu:
	ld de, $98cc
	ld bc, $0804
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_5e50:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5e68
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5e68:
	ld hl, wMainMenuResult
	ld bc, $0400
	call Func_1f_5855
	ld hl, $5eb0
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ed
	call CopyBgMap
	call Func_1f_5e91
	call HideUnusedOamSprites
	jp Func_1f_5e50
Func_1f_5e91:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_5e9e
	ld bc, $4868
	call Func_1f_65ec
Func_1f_5e9e:
	ld a, [wMainMenuResult]
	cp $04
	jr z, Func_1f_5eab
	ld bc, $48a0
	call Func_1f_65be
Func_1f_5eab:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_5eb0:
	db $ba, $5e, $d8, $5e, $f6, $5e, $14, $5f, $32, $5f, $02, $06, $cc, $5e, $c0, $5e
	db $d4, $dc, $e4, $ec, $97, $97, $d5, $dd, $e5, $ed, $97, $97, $07, $07, $07, $07
	db $06, $06, $06, $06, $06, $06, $06, $06, $02, $06, $ea, $5e, $de, $5e, $f4, $fc
	db $be, $c6, $97, $97, $f5, $fd, $bf, $c7, $97, $97, $07, $07, $07, $07, $06, $06
	db $06, $06, $06, $06, $06, $06, $02, $06, $08, $5f, $fc, $5e, $90, $92, $97, $97
	db $97, $97, $91, $93, $97, $97, $97, $97, $07, $07, $06, $06, $06, $06, $06, $06
	db $06, $06, $06, $06, $02, $06, $26, $5f, $1a, $5f, $ce, $d6, $de, $97, $97, $97
	db $cf, $d7, $df, $97, $97, $97, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $02, $06, $44, $5f, $38, $5f, $84, $8e, $97, $97, $97, $97, $85, $8f
	db $97, $97, $97, $97, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06

Tradehouse_ShowMenu:
	ld de, $98cc
	ld bc, $0804
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_5f5d:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5f75
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5f75:
	ld hl, wMainMenuResult
	ld bc, $0200
	call Func_1f_5855
	ld hl, $5fbd
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ed
	call CopyBgMap
	call Func_1f_5f9e
	call HideUnusedOamSprites
	jp Func_1f_5f5d
Func_1f_5f9e:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_5fab
	ld bc, $4868
	call Func_1f_65ec
Func_1f_5fab:
	ld a, [wMainMenuResult]
	cp $02
	jr z, Func_1f_5fb8
	ld bc, $48a0
	call Func_1f_65be
Func_1f_5fb8:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_5fbd:
	db $d8, $5e, $14, $5f, $32, $5f

Bodka_ShowItemsSubMenu:
	ld de, $98cc
	ld bc, $0804
	call ScriptOpcode05Helper
	xor a
	ld [wSubMenuCursor], a
Func_1f_5fd0:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_5fe8
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_5fe8:
	ld hl, wSubMenuCursor
	ld bc, $0200
	call Func_1f_5855
	ld hl, $6030
	ld a, [wSubMenuCursor]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ed
	call CopyBgMap
	call Func_1f_6011
	call HideUnusedOamSprites
	jp Func_1f_5fd0
Func_1f_6011:
	ld a, [wSubMenuCursor]
	cp $00
	jr z, Func_1f_601e
	ld bc, $4868
	call Func_1f_65ec
Func_1f_601e:
	ld a, [wSubMenuCursor]
	cp $02
	jr z, Func_1f_602b
	ld bc, $48a0
	call Func_1f_65be
Func_1f_602b:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_6030:
	db $36, $60, $54, $60, $72, $60, $02, $06, $48, $60, $3c, $60, $e6, $ee, $f6, $97
	db $97, $97, $e7, $ef, $f7, $97, $97, $97, $07, $07, $07, $06, $06, $06, $06, $06
	db $06, $06, $06, $06, $02, $06, $66, $60, $5a, $60, $ce, $d6, $de, $97, $97, $97
	db $cf, $d7, $df, $97, $97, $97, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $02, $06, $84, $60, $78, $60, $94, $b3, $b5, $97, $97, $97, $95, $b4
	db $b6, $97, $97, $97, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06, $06

Pashute_ShowMenu:
	ld de, $98cb
	ld bc, $0904
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_609d:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_60b5
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_60b5:
	ld hl, wMainMenuResult
	ld bc, $0200
	call Func_1f_5855
	ld hl, $60fd
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ec
	call CopyBgMap
	call Func_1f_60de
	call HideUnusedOamSprites
	jp Func_1f_609d
Func_1f_60de:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_60eb
	ld bc, $4860
	call Func_1f_65ec
Func_1f_60eb:
	ld a, [wMainMenuResult]
	cp $02
	jr z, Func_1f_60f8
	ld bc, $48a0
	call Func_1f_65be
Func_1f_60f8:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_60fd:
	db $03, $61, $25, $61, $47, $61, $02, $07, $17, $61, $09, $61, $c6, $ce, $d6, $97
	db $97, $97, $97, $c7, $cf, $d7, $97, $97, $97, $97, $07, $07, $07, $06, $06, $06
	db $06, $06, $06, $06, $06, $06, $06, $06, $02, $07, $39, $61, $2b, $61, $90, $92
	db $97, $97, $97, $97, $97, $91, $93, $97, $97, $97, $97, $97, $07, $07, $06, $06
	db $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $02, $07, $5b, $61, $4d, $61
	db $84, $8e, $97, $97, $97, $97, $97, $85, $8f, $97, $97, $97, $97, $97, $07, $07
	db $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06

Pashute_ShowExplainSubMenu:
	ld de, $98cb
	ld bc, $0904
	call ScriptOpcode05Helper
	xor a
	ld [wSubMenuCursor], a
Func_1f_6176:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_618e
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_618e:
	ld hl, wSubMenuCursor
	ld bc, $0200
	call Func_1f_5855
	ld hl, $61d6
	ld a, [wSubMenuCursor]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ec
	call CopyBgMap
	call Func_1f_61b7
	call HideUnusedOamSprites
	jp Func_1f_6176
Func_1f_61b7:
	ld a, [wSubMenuCursor]
	cp $00
	jr z, Func_1f_61c4
	ld bc, $4860
	call Func_1f_65ec
Func_1f_61c4:
	ld a, [wSubMenuCursor]
	cp $02
	jr z, Func_1f_61d1
	ld bc, $48a0
	call Func_1f_65be
Func_1f_61d1:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_61d6:
	db $dc, $61, $fe, $61, $20, $62, $02, $07, $f0, $61, $e2, $61, $de, $e6, $ee, $f6
	db $fe, $df, $97, $97, $97, $97, $97, $e7, $ef, $f7, $07, $07, $07, $07, $07, $07
	db $07, $06, $06, $06, $06, $06, $06, $06, $02, $07, $12, $62, $04, $62, $f8, $ba
	db $c2, $ca, $d2, $97, $97, $f9, $bb, $c3, $cb, $d3, $97, $97, $07, $07, $07, $07
	db $07, $06, $06, $06, $06, $06, $06, $06, $06, $06, $02, $07, $34, $62, $26, $62
	db $94, $b3, $b5, $97, $97, $97, $97, $95, $b4, $b6, $97, $97, $97, $97, $07, $07
	db $07, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06, $06

ShowMonsterDiscStoneSelect:
	call Func_1f_63a6
Func_1f_6245:
	ld de, $982b
	ld bc, $0909
	ld a, [$d602]
	cp $03
	jr c, Func_1f_6254
	ld a, $03
Func_1f_6254:
	sla a
	add a, $03
	ld c, a
	call ScriptOpcode05Helper
	xor a
	ld [$d601], a
	ld [$d60c], a
	ld [$d60b], a
Func_1f_6266:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_628e
	ld hl, $d603
	ld a, [$d601]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	ld [wActiveMonster], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_628e:
	call Func_1f_587c
	call Func_1f_62d8
	ld c, $68
	ld a, [$d60b]
	sla a
	sla a
	sla a
	sla a
	add a, $24
	ld b, a
	call Func_1f_65be
	call Func_1f_62b4
	call HideUnusedOamSprites
	ld hl, $d612
	inc [hl]
	jp Func_1f_6266
Func_1f_62b4:
	ld a, [$d60c]
	cp $00
	jr z, Func_1f_62c1
	ld bc, $1480
	call Func_1f_65f5
Func_1f_62c1:
	ld a, [$d602]
	sub $03
	jr nc, Func_1f_62ca
	ld a, $00
Func_1f_62ca:
	ld c, a
	ld a, [$d60c]
	cp c
	jr nc, Func_1f_62d7
	ld bc, $4b80
	call Func_1f_65fe
Func_1f_62d7:
	ret
Func_1f_62d8:
	ld hl, $d603
	ld a, [$d60c]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld de, $986d
	ld a, [$d602]
	cp $03
	jr c, Func_1f_62f0
	ld a, $03
Func_1f_62f0:
	ld c, a
Func_1f_62f1:
	push bc
	push de
	push hl
	ld a, [hl]
	ld hl, $6316
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	call CopyBgMap
	pop hl
	pop de
	pop bc
	ld a, e
	add a, $40
	ld e, a
	ld a, d
	adc a, $00
	ld d, a
	inc hl
	dec c
	jr nz, Func_1f_62f1
	ret

Data_1f_6316:
	db $26, $63, $36, $63, $46, $63, $56, $63, $66, $63, $76, $63, $86, $63, $96, $63
	db $01, $05, $31, $63, $2c, $63, $30, $38, $40, $97, $97, $07, $07, $07, $07, $07
	db $01, $05, $41, $63, $3c, $63, $3c, $44, $3d, $45, $97, $07, $07, $07, $07, $07
	db $01, $05, $51, $63, $4c, $63, $32, $3a, $42, $97, $97, $07, $07, $07, $07, $07
	db $01, $05, $61, $63, $5c, $63, $33, $3b, $43, $97, $97, $07, $07, $07, $07, $07
	db $01, $05, $71, $63, $6c, $63, $2e, $36, $3e, $46, $97, $07, $07, $07, $07, $07
	db $01, $05, $81, $63, $7c, $63, $31, $39, $41, $97, $97, $07, $07, $07, $07, $07
	db $01, $05, $91, $63, $8c, $63, $37, $3f, $47, $48, $49, $07, $07, $07, $07, $07
	db $01, $05, $a1, $63, $9c, $63, $4a, $4b, $4c, $4d, $97, $06, $06, $06, $06, $06

Func_1f_63a6:
	ld de, $d603
	ld c, $00
	ld b, $00
Func_1f_63ad:
	ld hl, wMonsterDiscStones
	ld a, l
	add a, c
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	or a
	jr z, Func_1f_63bf
	ld a, c
	ld [de], a
	inc de
	inc b
Func_1f_63bf:
	inc c
	ld a, c
	cp $07
	jr nz, Func_1f_63ad
	ld a, $07
	ld [de], a
	inc b
	ld hl, $d602
	ld [hl], b
	ret
Verde_ShowMainMenu:
	ld de, $98cb
	ld bc, $0904
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_63db:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_6403
	ld hl, $6453
	ld a, [wMainMenuResult]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	ld [wMainMenuResult], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_6403:
	ld hl, wMainMenuResult
	ld bc, $0300
	call Func_1f_5855
	ld hl, $644b
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ec
	call CopyBgMap
	call Func_1f_642c
	call HideUnusedOamSprites
	jp Func_1f_63db
Func_1f_642c:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_6439
	ld bc, $4860
	call Func_1f_65ec
Func_1f_6439:
	ld a, [wMainMenuResult]
	cp $03
	jr z, Func_1f_6446
	ld bc, $48a0
	call Func_1f_65be
Func_1f_6446:
	ld hl, $d612
	inc [hl]
	ret

Data_1f_644b:
	db $e0, $64, $02, $65, $46, $65, $68, $65, $00, $01, $03, $04

Func_1f_6457:
	ld de, $98cb
	ld bc, $0904
	call ScriptOpcode05Helper
	xor a
	ld [wMainMenuResult], a
Func_1f_6464:
	call WaitForNextFrame
	call ReadJoypad
	call DispatchTextRenderer
	ld a, [hJoyPressed]
	bit 0, a
	jr z, Func_1f_648c
	ld hl, $64dc
	ld a, [wMainMenuResult]
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	ld [wMainMenuResult], a
	push af
	ld a, SOUND_SFX_Confirm
	call PlaySound
	pop af
	ret
Func_1f_648c:
	ld hl, wMainMenuResult
	ld bc, $0300
	call Func_1f_5855
	ld hl, $64d4
	ld a, [wMainMenuResult]
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld de, $98ec
	call CopyBgMap
	call Func_1f_64b5
	call HideUnusedOamSprites
	jp Func_1f_6464
Func_1f_64b5:
	ld a, [wMainMenuResult]
	cp $00
	jr z, Func_1f_64c2
	ld bc, $4860
	call Func_1f_65ec
Func_1f_64c2:
	ld a, [wMainMenuResult]
	cp $03
	jr z, Func_1f_64cf
	ld bc, $48a0
	call Func_1f_65be
Func_1f_64cf:
	ld hl, $d612
	inc [hl]
	ret
	ldh [$ff64], a
	inc h
	ld h, l
	ld b, [hl]
	ld h, l
	ld l, b
	ld h, l
	nop
	ld [bc], a
	inc bc
	inc b

Data_1f_64e0:
	db $02, $07, $f4, $64, $e6, $64, $da, $e2, $ea, $f2, $97, $97, $97, $db, $e3, $eb
	db $f3, $97, $97, $97, $07, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $02, $07, $16, $65, $08, $65, $fa, $bc, $c4, $97, $97, $97, $97, $fb
	db $bd, $c5, $97, $97, $97, $97, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $06, $06

Data_1f_6524:
	db $02, $07, $38, $65, $2a, $65, $cc, $d4, $dc, $e4, $97, $97, $97, $cd, $d5, $dd
	db $e5, $97, $97, $97, $07, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06
	db $06, $06

Data_1f_6546:
	db $02, $07, $5a, $65, $4c, $65, $ec, $f4, $fc, $be, $97, $97, $97, $ed, $f5, $fd
	db $bf, $97, $97, $97, $07, $07, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $02, $07, $7c, $65, $6e, $65, $84, $8e, $97, $97, $97, $97, $97, $85
	db $8f, $97, $97, $97, $97, $97, $07, $07, $06, $06, $06, $06, $06, $06, $06, $06
	db $06, $06, $06, $06

Verde_ShowReleaseMonsterSelect:
	call Func_1f_6590
	jp Func_1f_6245
Func_1f_6590:
	ld de, $d603
	ld c, $00
	ld b, $00
Func_1f_6597:
	ld hl, wMonsterUses
	ld a, l
	add a, c
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl]
	or a
	jr z, Func_1f_65af
	ld a, [wDisplayMonster]
	cp c
	jr z, Func_1f_65af
	ld a, c
	ld [de], a
	inc de
	inc b
Func_1f_65af:
	inc c
	ld a, c
	cp $07
	jr nz, Func_1f_6597
	ld a, $07
	ld [de], a
	inc b
	ld hl, $d602
	ld [hl], b
	ret
Func_1f_65be:
	ld hl, $65e8
Func_1f_65c1:
	ld a, $19
	ld [wDrawBank], a
	ld a, [$d612]
	srl a
	srl a
	srl a
	cp $02
	jr c, Func_1f_65d7
	xor a
	ld [$d612], a
Func_1f_65d7:
	sla a
	add a, l
	ld l, a
	ld a, h
	adc a, $00
	ld h, a
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, l
	or h
	call nz, DrawMetasprite
	ret

Data_1f_65e8:
	db $8a, $68, $00, $00

Func_1f_65ec:
	ld hl, $65f1
	jr Func_1f_65c1

Data_1f_65f1:
	db $85, $68, $00, $00

Func_1f_65f5:
	ld hl, $65fa
	jr Func_1f_65c1

Data_1f_65fa:
	db $7b, $68, $00, $00

Func_1f_65fe:
	ld hl, $6603
	jr Func_1f_65c1

Data_1f_6603:
	db $80, $68, $00, $00

; ($20:$7000 BG/OBJ palettes carved into src/gfx/screen/town.asm as TownPalettes.)

SECTION "analyzed_083356", ROMX[$7356], BANK[$20]

Data_20_7356:
	db $10, $00, $38, $00, $00, $00, $60, $00, $20, $10, $38, $02, $00, $10, $60, $02
	db $20, $20, $38, $04, $00, $20, $60, $04, $20, $30, $38, $06, $00, $30, $60, $06
	db $20, $40, $38, $08, $00, $40, $60, $08, $20, $50, $38, $0a, $00, $50, $40, $0c
	db $00, $50, $48, $0e, $00, $50, $50, $0e, $20, $50, $58, $0c, $20, $50, $60, $0a
	db $20, $04, $06, $b5, $73, $9d, $73, $a8, $b0, $b8, $c0, $c8, $d0, $a9, $b1, $b9
	db $c1, $c9, $d1, $aa, $b2, $ba, $c2, $ca, $d2, $ab, $b3, $bb, $c3, $cb, $d3, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $04, $06, $eb, $73, $d3, $73, $ac, $b4, $bc
	db $c4, $cc, $d4, $ad, $b5, $bd, $c5, $cd, $d5, $ae, $b6, $be, $c6, $ce, $d6, $af
	db $b7, $bf, $c7, $cf, $d7, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $04, $05, $1d
	db $74, $09, $74, $84, $8c, $94, $9c, $a4, $85, $8d, $95, $9d, $a5, $86, $8e, $96
	db $9e, $a6, $87, $8f, $97, $9f, $a7, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $04, $05, $4b, $74, $37
	db $74, $80, $88, $90, $98, $a0, $81, $89, $91, $99, $a1, $82, $8a, $92, $9a, $a2
	db $83, $8b, $93, $9b, $a3, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	db $01, $01, $01, $01, $01, $01, $01, $01, $01, $08, $00, $00, $10, $02, $00, $08
	db $18, $02, $00, $10, $20, $02, $00, $18, $28, $02, $10, $00, $12, $02, $10, $08
	db $1a, $02, $10, $10, $22, $02, $10, $18, $2a, $02, $08, $00, $00, $14, $02, $00
	db $08, $1c, $02, $00, $10, $24, $02, $00, $18, $2c, $02, $10, $00, $16, $02, $10
	db $08, $1e, $02, $10, $10, $26, $02, $10, $18, $2e, $02, $08, $00, $00, $30, $02
	db $00, $08, $38, $02, $00, $10, $40, $02, $00, $18, $48, $02, $10, $00, $32, $02
	db $10, $08, $3a, $02, $10, $10, $42, $02, $10, $18, $4a, $02, $08, $00, $00, $34
	db $05, $00, $08, $3c, $05, $00, $10, $44, $05, $00, $18, $4c, $05, $10, $00, $36
	db $05, $10, $08, $3e, $05, $10, $10, $46, $05, $10, $18, $4e, $05, $08, $00, $00
	db $50, $05, $00, $08, $58, $05, $00, $10, $60, $05, $00, $18, $68, $05, $10, $00
	db $52, $05, $10, $08, $5a, $05, $10, $10, $62, $05, $10, $18, $6a, $05, $08, $00
	db $00, $54, $05, $00, $08, $5c, $05, $00, $10, $64, $05, $00, $18, $6c, $05, $10
	db $00, $56, $05, $10, $08, $5e, $05, $10, $10, $66, $05, $10, $18, $6e, $05, $08
	db $00, $00, $70, $03, $00, $08, $78, $03, $00, $10, $00, $0b, $00, $18, $08, $0b
	db $10, $00, $72, $03, $10, $08, $7a, $03, $10, $10, $02, $0b, $10, $18, $0a, $0b
	db $08, $00, $00, $74, $03, $00, $08, $7c, $03, $00, $10, $04, $0b, $00, $18, $0c
	db $0b, $10, $00, $76, $03, $10, $08, $7e, $03, $10, $10, $06, $0b, $10, $18, $0e
	db $0b, $08, $00, $00, $10, $0b, $00, $08, $18, $0b, $00, $10, $20, $0b, $00, $18
	db $28, $0b, $10, $00, $12, $0b, $10, $08, $1a, $0b, $10, $10, $22, $0b, $10, $18
	db $2a, $0b, $08, $00, $00, $14, $09, $00, $08, $1c, $09, $00, $10, $24, $09, $00
	db $18, $2c, $09, $10, $00, $16, $09, $10, $08, $1e, $09, $10, $10, $26, $09, $10
	db $18, $2e, $09, $08, $00, $00, $30, $09, $00, $08, $38, $09, $00, $10, $40, $09
	db $00, $18, $48, $09, $10, $00, $32, $09, $10, $08, $3a, $09, $10, $10, $42, $09
	db $10, $18, $4a, $09, $08, $00, $00, $34, $09, $00, $08, $3c, $09, $00, $10, $44
	db $09, $00, $18, $4c, $09, $10, $00, $36, $09, $10, $08, $3e, $09, $10, $10, $46
	db $09, $10, $18, $4e, $09, $1d, $00, $42, $08, $08, $21, $ad, $35, $1d, $00, $a5
	db $14, $8c, $31, $73, $4e, $1d, $00, $e7, $1c, $10, $42, $18, $63, $1d, $00, $4a
	db $29, $94, $52, $de, $7b, $0b, $00, $18, $e0, $0c, $00, $20, $e8, $0c, $00, $28
	db $f0, $0c, $00, $30, $f8, $0c, $08, $00, $c8, $0c, $08, $08, $d0, $0c, $08, $10
	db $d8, $0c, $10, $18, $e2, $0c, $10, $20, $ea, $0c, $10, $28, $f2, $0c, $10, $30
	db $fa, $0c, $0b, $00, $18, $68, $0c, $00, $20, $70, $0c, $00, $28, $78, $0c, $00
	db $30, $52, $0c, $08, $00, $50, $0c, $08, $08, $58, $0c, $08, $10, $60, $0c, $10
	db $18, $5a, $0c, $10, $20, $62, $0c, $10, $28, $6a, $0c, $10, $30, $72, $0c, $04
	db $08, $18, $7a, $0c, $08, $20, $54, $0c, $08, $28, $5c, $0c, $08, $30, $64, $0c
	db $0b, $00, $00, $e4, $0c, $00, $08, $ec, $0c, $00, $10, $f4, $0c, $00, $18, $fc
	db $0c, $08, $20, $ca, $0c, $08, $28, $d2, $0c, $08, $30, $da, $0c, $10, $00, $e6
	db $0c, $10, $08, $ee, $0c, $10, $10, $f6, $0c, $10, $18, $fe, $0c, $09, $00, $00
	db $74, $0c, $00, $08, $7c, $0c, $00, $10, $56, $0c, $00, $18, $5e, $0c, $08, $20
	db $d8, $04, $08, $28, $e0, $04, $10, $08, $66, $0c, $10, $10, $6e, $0c, $10, $18
	db $76, $0c, $07, $00, $00, $e8, $04, $00, $08, $f0, $04, $00, $10, $f8, $04, $00
	db $18, $80, $0c, $10, $08, $88, $0c, $10, $10, $90, $0c, $10, $18, $98, $0c, $03
	db $0e, $15, $77, $eb, $76, $f2, $ac, $b4, $21, $9c, $9a, $ab, $21, $b2, $9a, $b5
	db $9e, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21
	db $21, $9a, $ab, $9d, $21, $a7, $ac, $9a, $9d, $21, $9d, $9a, $b3, $9a, $f4, $00
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $00, $03, $0e, $6f, $77, $45, $77, $f2
	db $ac, $b4, $21, $9c, $9a, $ab, $21, $21, $21, $21, $21, $21, $21, $af, $9e, $a2
	db $9e, $ab, $9e, $af, $9a, $b3, $9e, $21, $b3, $a3, $9e, $b2, $9a, $b4, $9c, $9e
	db $af, $21, $b2, $b3, $ac, $ab, $9e, $f4, $21, $00, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $00, $08, $03, $0e, $c9, $77, $9f, $77, $f2, $ac, $b4, $21, $9c, $9a, $ab
	db $21, $21, $21, $21, $21, $21, $21, $9e, $b7, $9c, $a3, $9a, $ab, $a2, $9e, $21
	db $ac, $af, $21, $21, $21, $9c, $a3, $9e, $9c, $a6, $21, $aa, $ac, $ab, $b2, $b3
	db $9e, $af, $f4, $00, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $00, $03, $0e, $23
	db $78, $f9, $77, $f2, $ac, $b4, $21, $9c, $9a, $ab, $21, $9e, $9d, $a4, $b3, $21
	db $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $9a
	db $21, $b2, $b3, $9a, $a2, $9e, $f4, $21, $21, $21, $21, $21, $21, $00, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $00, $08, $08, $08, $08, $08, $08, $04, $14, $a3, $78, $53, $78, $15, $19, $1d
	db $1f, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $1f, $1d, $19
	db $15, $16, $1a, $1e, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21
	db $21, $21, $1e, $1a, $16, $17, $1b, $21, $21, $21, $21, $21, $21, $21, $21, $21
	db $21, $21, $21, $21, $21, $21, $21, $1b, $17, $18, $1c, $21, $21, $21, $21, $21
	db $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $21, $1c, $18, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $28, $28, $28, $28, $28, $28, $28, $28, $28
	db $28, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $28, $28, $28, $28, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $28, $28, $28, $28, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $28, $28, $28, $28, $80, $70, $97
	db $73, $03, $74, $cd, $73, $31, $74, $a1, $74, $80, $74, $a1, $74, $80, $74, $5f
	db $74, $04, $75, $e3, $74, $04, $75, $e3, $74, $c2, $74, $67, $75, $46, $75, $67
	db $75, $46, $75, $25, $75, $ca, $75, $a9, $75, $ca, $75, $a9, $75, $88, $75

Data_20_7925:
	db $ca, $75, $a9, $75, $ca, $75, $a9, $75, $88, $75

Data_20_792f:
	db $e5, $76, $3f, $77, $99, $77, $f3, $77, $4d, $78, $65, $76, $38, $76, $0b, $76
	db $0b, $76

Data_20_7941:
	db $0b, $76

Data_20_7943:
	db $c8, $76, $a3, $76, $76, $76, $76, $76

Data_20_794b:
	db $76, $76

Data_20_794d:
	db $4c, $0e, $4c, $0f, $4c, $0f, $4c, $0e, $4c, $0d, $4c, $0c, $4c, $0c, $4c, $0d
	db $28, $28, $28, $29, $28, $2a, $28, $2b, $28, $2b, $28, $2a, $28, $29, $28, $28

Func_20_796d:
	ld hl, $7939
	ld de, $794d
	call Func_20_7980
	ld hl, $7943
	ld de, $795d
	call Func_20_7980
	ret
Func_20_7980:
	ld a, [wScreenAnim2]
	add a, a
	rst AddAToHL
	rst DerefHL
	ld a, l
	cp $ff
	jr nz, Func_20_7990

Data_20_798b:
	db $7c, $fe, $ff, $28, $1c

Func_20_7990:
	ld a, [wFadeLevel]
	srl a
	srl a
	srl a
	srl a
	and $07
	add a, a
	rst AddAToDE
	ld a, [de]
	ld c, a
	inc de
	ld a, [de]
	ld b, a
	ld a, $20
	ld [wDrawBank], a
	call DrawMetasprite
	ret

; ($21:$7000 BG/OBJ palettes carved into the screen asset as RoomClearPalettes.)

SECTION "analyzed_087356", ROMX[$7356], BANK[$21]

Data_21_7356:
	db $02, $0c, $74, $73, $5c, $73, $32, $3a, $42, $4a, $52, $5a, $62, $6a, $72, $7a
	db $74, $7c, $33, $3b, $43, $4b, $53, $5b, $63, $6b, $73, $7b, $75, $7d, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $00, $00, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $00, $00, $04, $03, $9e, $73, $92, $73, $04, $0c, $14, $05
	db $0d, $15, $1c, $24, $2c, $1d, $25, $2d, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08

Data_21_73aa:
	db $8c, $73

Func_21_73ac:
	call WaitForHBlank
	ld hl, wScore
	ld de, $98cd
	ld a, [hl]
	call Func_00_3635
	ld a, [hl+]
	swap a
	call Func_00_3635
	ld a, [hl]
	call Func_00_3635
	call WaitForHBlank
	ld a, [hl+]
	swap a
	call Func_00_3635
	ld a, [hl]
	call Func_00_3635
	ld a, [hl+]
	swap a
	call Func_00_3635
	call WaitForHBlank
	ld a, [hl]
	call Func_00_3635
	ld a, [hl]
	swap a
	call Func_00_3635
	ret
Func_21_73e4:
	call WaitForHBlank
	ld hl, wFloorTimer
	ld de, $992c
	ld a, [hl]
	call Func_00_3635
	ld a, [hl+]
	swap a
	call Func_00_3635
	call WaitForHBlank
	ld a, [hl]
	call Func_00_3635
	ld a, [hl+]
	swap a
	call Func_00_3635
	ld a, [hl]
	call Func_00_3635
	ret
Func_21_7409:
	call WaitForHBlank
	ld de, $9927
	ld a, $00
	call Func_00_3635
	ret

; ($22:$7000 BG/OBJ palettes carved into the screen asset as TowerEntrancePalettes.)

SECTION "analyzed_08b356", ROMX[$7356], BANK[$22]

Data_22_7356:
	db $14, $48, $20, $34, $01, $48, $78, $38, $01, $58, $18, $30, $01, $58, $20, $36
	db $01, $58, $78, $3a, $01, $58, $80, $3c, $01, $68, $18, $32, $01, $68, $80, $3e
	db $01, $70, $00, $00, $02, $70, $08, $02, $02, $70, $90, $24, $02, $78, $98, $26
	db $02, $80, $30, $0c, $02, $80, $38, $0e, $02, $80, $40, $10, $02, $80, $48, $12
	db $02, $80, $50, $14, $02, $80, $58, $16, $02, $80, $60, $18, $02, $80, $68, $1a
	db $02, $08, $0a, $fd, $73, $ad, $73, $80, $87, $8f, $97, $9f, $9f, $97, $8f, $87
	db $80, $81, $88, $90, $98, $a0, $a0, $98, $90, $88, $81, $82, $89, $91, $99, $a1
	db $a1, $99, $91, $89, $82, $83, $8a, $92, $9a, $a1, $a1, $9a, $92, $8a, $83, $84
	db $8b, $93, $9b, $a1, $a1, $9b, $93, $8b, $84, $85, $8c, $94, $9c, $a1, $a1, $9c
	db $94, $8c, $85, $86, $8d, $95, $9d, $a1, $a1, $9d, $95, $8d, $86, $4c, $8e, $96
	db $9e, $a2, $a2, $9e, $96, $8e, $4e, $04, $04, $04, $04, $04, $24, $24, $24, $24
	db $24, $04, $04, $04, $04, $04, $24, $24, $24, $24, $24, $04, $04, $04, $04, $04
	db $24, $24, $24, $24, $24, $04, $04, $04, $04, $04, $24, $24, $24, $24, $24, $04
	db $04, $04, $04, $04, $24, $24, $24, $24, $24, $04, $04, $04, $04, $04, $24, $24
	db $24, $24, $24, $04, $04, $04, $04, $04, $24, $24, $24, $24, $24, $0b, $04, $04
	db $04, $04, $24, $24, $24, $24, $0b, $08, $0a, $a3, $74, $53, $74, $a3, $aa, $b2
	db $ba, $9f, $9f, $ba, $b2, $aa, $a3, $a4, $ab, $b3, $bb, $a1, $a1, $bb, $b3, $ab
	db $a4, $a5, $ac, $b4, $bc, $a1, $a1, $bc, $b4, $ac, $a5, $a6, $ad, $b5, $bd, $a1
	db $a1, $bd, $b5, $ad, $a6, $a7, $ae, $b6, $be, $a1, $a1, $be, $b6, $ae, $a7, $a8
	db $af, $b7, $bf, $a1, $a1, $bf, $b7, $af, $a8, $a9, $b0, $b8, $c0, $a1, $a1, $c0
	db $b8, $b0, $a9, $4c, $b1, $b9, $c1, $a2, $a2, $c1, $b9, $b1, $4e, $00, $04, $04
	db $04, $04, $24, $24, $24, $24, $20, $00, $04, $04, $04, $04, $24, $24, $24, $24
	db $20, $00, $04, $04, $04, $04, $24, $24, $24, $24, $20, $00, $04, $04, $04, $04
	db $24, $24, $24, $24, $20, $00, $04, $04, $04, $04, $24, $24, $24, $24, $20, $00
	db $04, $04, $04, $04, $24, $24, $24, $24, $20, $00, $04, $04, $04, $04, $24, $24
	db $24, $24, $20, $0b, $04, $04, $04, $04, $24, $24, $24, $24, $0b, $08, $0a, $49
	db $75, $f9, $74, $c2, $c9, $d0, $ba, $9f, $9f, $ba, $d0, $c9, $c2, $c3, $ca, $d1
	db $a1, $a1, $a1, $a1, $d1, $ca, $c3, $c4, $cb, $d2, $a1, $a1, $a1, $a1, $d2, $cb
	db $c4, $c5, $cc, $d3, $a1, $a1, $a1, $a1, $d3, $cc, $c5, $c6, $cd, $d4, $a1, $a1
	db $a1, $a1, $d4, $cd, $c6, $c7, $ce, $d5, $a1, $a1, $a1, $a1, $d5, $ce, $c7, $c8
	db $cf, $d6, $a1, $a1, $a1, $a1, $d6, $cf, $c8, $4c, $b1, $b9, $c1, $a2, $a2, $c1
	db $b9, $b1, $4d, $00, $04, $04, $24, $04, $24, $04, $24, $24, $20, $00, $04, $04
	db $04, $04, $24, $24, $24, $24, $20, $00, $04, $04, $04, $04, $24, $24, $24, $24
	db $20, $00, $04, $04, $04, $04, $24, $24, $24, $24, $20, $00, $04, $04, $04, $04
	db $24, $24, $24, $24, $20, $00, $04, $04, $04, $04, $24, $24, $24, $24, $20, $00
	db $04, $04, $04, $04, $24, $24, $24, $24, $20, $0b, $04, $04, $04, $04, $24, $24
	db $24, $24, $0b, $04, $00, $10, $28, $00, $00, $18, $2a, $00, $00, $30, $2c, $00
	db $00, $38, $2e, $00, $02, $00, $10, $40, $00, $00, $38, $40, $20, $02, $00, $10
	db $42, $00, $00, $38, $42, $20, $04, $00, $08, $44, $00, $00, $10, $46, $00, $00
	db $38, $46, $20, $00, $40, $44, $20, $a7, $73, $4d, $74, $f3, $74, $aa, $75, $b3
	db $75, $bc, $75, $99, $75

; ($23:$7000 BG/OBJ palettes carved into the screen asset as RoomStartPalettes.)

SECTION "analyzed_08f356", ROMX[$7356], BANK[$23]

Data_23_7356:
	db $08, $00, $00, $4e, $02, $00, $08, $56, $02, $00, $10, $56, $22, $00, $18, $4e
	db $22, $10, $00, $54, $02, $10, $08, $5c, $02, $10, $10, $5c, $22, $10, $18, $54
	db $22, $01, $00, $00, $4c, $01, $05, $03, $91, $73, $82, $73, $68, $6c, $6d, $68
	db $6b, $6d, $68, $6a, $6d, $68, $6a, $6d, $68, $69, $6d, $c1, $c1, $81, $c1, $c1
	db $81, $c1, $c1, $81, $c1, $c1, $81, $c1, $c1, $81, $06, $01, $ac, $73, $a6, $73
	db $68, $68, $68, $68, $68, $68, $c1, $c1, $c1, $c1, $c1, $c1, $02, $08, $c8, $73
	db $b8, $73, $6e, $76, $7e, $06, $0e, $16, $1e, $26, $2e, $36, $3e, $6e, $76, $7e
	db $6f, $77, $02, $02, $02, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0b, $0a, $4c, $74, $de, $73, $79, $79, $79, $79, $79, $79, $79, $79
	db $79, $79, $79, $72, $7a, $02, $0a, $12, $1a, $79, $79, $79, $79, $73, $7b, $03
	db $0b, $13, $1b, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79
	db $79, $79, $79, $79, $22, $2a, $79, $79, $79, $79, $79, $79, $79, $79, $23, $2b
	db $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $58, $60
	db $68, $70, $78, $79, $59, $61, $69, $71, $79, $79, $79, $79, $79, $79, $79, $79
	db $79, $79, $79, $79, $79, $3f, $77, $77, $77, $79, $79, $79, $79, $79, $79, $79
	db $79, $79, $79, $79, $79, $79, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $00, $00, $08, $08, $08, $08, $08, $08, $08, $08, $00, $00, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $0c, $04, $04, $04, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $0b, $0a, $2e, $75, $c0, $74, $79, $79, $72, $7a, $02, $0a
	db $12, $1a, $79, $79, $79, $79, $73, $7b, $03, $0b, $13, $1b, $79, $79, $79, $79
	db $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79
	db $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79
	db $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79
	db $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $58, $60, $68, $70, $78, $79
	db $59, $61, $69, $71, $79, $79, $79, $3f, $77, $77, $77, $79, $79, $79, $79, $79
	db $79, $79, $79, $79, $79, $79, $79, $79, $08, $08, $00, $00, $08, $08, $08, $08
	db $08, $08, $08, $08, $00, $00, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $0c, $04, $04, $04, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $0b, $0a, $10, $76, $a2, $75, $79, $79, $79, $79
	db $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79
	db $32, $3a, $42, $4a, $52, $5a, $62, $6a, $72, $7a, $33, $3b, $43, $4b, $53, $5b
	db $63, $6b, $73, $7b, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79
	db $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $79
	db $79, $79, $58, $60, $68, $70, $78, $79, $59, $61, $69, $71, $79, $79, $79, $79
	db $79, $79, $79, $79, $79, $79, $79, $79, $79, $2f, $77, $77, $77, $79, $79, $79
	db $79, $79, $79, $79, $79, $79, $79, $79, $79, $79, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $0c, $04, $04, $04, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $06, $00, $00, $30, $03, $00, $08, $38
	db $03, $00, $10, $40, $03, $10, $00, $32, $03, $10, $08, $3a, $03, $10, $10, $42
	db $03, $06, $00, $00, $34, $03, $00, $08, $3c, $03, $00, $10, $44, $03, $10, $00
	db $36, $03, $10, $08, $3e, $03, $10, $10, $46, $03, $06, $00, $00, $60, $03, $00
	db $08, $68, $03, $00, $10, $70, $03, $10, $00, $62, $03, $10, $08, $6a, $03, $10
	db $10, $72, $03, $06, $00, $00, $60, $03, $00, $08, $68, $03, $00, $10, $70, $03
	db $10, $00, $62, $03, $10, $08, $6a, $03, $10, $10, $72, $03, $08, $04, $08, $77
	db $e8, $76, $80, $88, $90, $98, $81, $89, $91, $99, $82, $8a, $92, $9a, $83, $8b
	db $93, $9b, $84, $8c, $94, $9c, $85, $8d, $95, $9d, $86, $8e, $96, $9e, $87, $8f
	db $97, $9f, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $08, $04, $4e, $77, $2e, $77, $a0, $a8, $b0, $b8, $a1, $a9, $b1, $b9
	db $a2, $aa, $b2, $ba, $a3, $ab, $b3, $bb, $a4, $ac, $b4, $bc, $a5, $ad, $b5, $bd
	db $a6, $ae, $b6, $be, $a7, $af, $b7, $bf, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $08, $04, $94, $77, $74, $77, $c0, $c8
	db $d0, $d8, $c1, $c9, $d1, $d9, $c2, $ca, $d2, $da, $c3, $cb, $d3, $db, $c4, $cc
	db $d4, $dc, $c5, $cd, $d5, $dd, $c6, $ce, $d6, $de, $c7, $cf, $d7, $df, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $08, $04
	db $da, $77, $ba, $77, $e0, $e8, $f0, $f8, $e1, $e9, $f1, $f9, $e2, $ea, $f2, $fa
	db $e3, $eb, $f3, $fb, $e4, $ec, $f4, $fc, $e5, $ed, $f5, $fd, $e6, $ee, $f6, $fe
	db $e7, $ef, $f7, $ff, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $08, $04, $20, $78, $00, $78, $98, $90, $88, $80, $99, $91
	db $89, $81, $9a, $92, $8a, $82, $9b, $93, $8b, $83, $9c, $94, $8c, $84, $9d, $95
	db $8d, $85, $9e, $96, $8e, $86, $9f, $97, $8f, $87, $22, $22, $22, $22, $22, $22
	db $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	db $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $08, $04, $66, $78, $46, $78
	db $b8, $b0, $a8, $a0, $b9, $b1, $a9, $a1, $ba, $b2, $aa, $a2, $bb, $b3, $ab, $a3
	db $bc, $b4, $ac, $a4, $bd, $b5, $ad, $a5, $be, $b6, $ae, $a6, $bf, $b7, $af, $a7
	db $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	db $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	db $08, $04, $ac, $78, $8c, $78, $d8, $d0, $c8, $c0, $d9, $d1, $c9, $c1, $da, $d2
	db $ca, $c2, $db, $d3, $cb, $c3, $dc, $d4, $cc, $c4, $dd, $d5, $cd, $c5, $de, $d6
	db $ce, $c6, $df, $d7, $cf, $c7, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	db $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	db $22, $22, $22, $22, $22, $22, $08, $04, $f2, $78, $d2, $78, $f8, $f0, $e8, $e0
	db $f9, $f1, $e9, $e1, $fa, $f2, $ea, $e2, $fb, $f3, $eb, $e3, $fc, $f4, $ec, $e4
	db $fd, $f5, $ed, $e5, $fe, $f6, $ee, $e6, $ff, $f7, $ef, $e7, $22, $22, $22, $22
	db $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22
	db $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $22, $08, $04, $38, $79
	db $18, $79, $98, $90, $88, $80, $99, $91, $89, $81, $69, $6d, $8a, $82, $6a, $6d
	db $8b, $83, $6a, $6d, $8c, $84, $6b, $6d, $8d, $85, $6c, $6d, $8e, $86, $6c, $6d
	db $8f, $87, $22, $22, $22, $22, $22, $22, $22, $22, $81, $81, $22, $22, $81, $81
	db $22, $22, $81, $81, $22, $22, $81, $81, $22, $22, $81, $81, $22, $22, $81, $81
	db $22, $22, $08, $04, $7e, $79, $5e, $79, $b8, $b0, $a8, $a0, $b9, $b1, $a9, $a1
	db $69, $6d, $aa, $a2, $6a, $6d, $ab, $a3, $6a, $6d, $ac, $a4, $6b, $6d, $ad, $a5
	db $6c, $6d, $ae, $a6, $6c, $6d, $af, $a7, $22, $22, $22, $22, $22, $22, $22, $22
	db $81, $81, $22, $22, $81, $81, $22, $22, $81, $81, $22, $22, $81, $81, $22, $22
	db $81, $81, $22, $22, $81, $81, $22, $22, $08, $04, $c4, $79, $a4, $79, $d8, $d0
	db $c8, $c0, $d9, $d1, $c9, $c1, $69, $6d, $ca, $c2, $6a, $6d, $cb, $c3, $6a, $6d
	db $cc, $c4, $6b, $6d, $cd, $c5, $6c, $6d, $ce, $c6, $6c, $6d, $cf, $c7, $22, $22
	db $22, $22, $22, $22, $22, $22, $81, $81, $22, $22, $81, $81, $22, $22, $81, $81
	db $22, $22, $81, $81, $22, $22, $81, $81, $22, $22, $81, $81, $22, $22, $08, $04
	db $0a, $7a, $ea, $79, $f8, $f0, $e8, $e0, $f9, $f1, $e9, $e1, $69, $6d, $ea, $e2
	db $6a, $6d, $eb, $e3, $6a, $6d, $ec, $e4, $6b, $6d, $ed, $e5, $6c, $6d, $ee, $e6
	db $6c, $6d, $ef, $e7, $22, $22, $22, $22, $22, $22, $22, $22, $81, $81, $22, $22
	db $81, $81, $22, $22, $81, $81, $22, $22, $81, $81, $22, $22, $81, $81, $22, $22
	db $81, $81, $22, $22, $02, $01, $32, $7a, $30, $7a, $4e, $4f, $0a, $0a, $02, $01
	db $3c, $7a, $3a, $7a, $44, $45, $0a, $0a, $02, $01, $46, $7a, $44, $7a, $4c, $4d
	db $0a, $0a, $02, $01, $50, $7a, $4e, $7a, $54, $55, $0a, $0a, $02, $01, $5a, $7a
	db $58, $7a, $5c, $5d, $0a, $0a, $02, $01, $64, $7a, $62, $7a, $64, $65, $0a, $0a
	db $02, $01, $6e, $7a, $6c, $7a, $6c, $6d, $0a, $0a, $02, $01, $78, $7a, $76, $7a
	db $74, $75, $0a, $0a, $02, $01, $82, $7a, $80, $7a, $7c, $7d, $0a, $0a, $02, $01
	db $8c, $7a, $8a, $7a, $46, $47, $0a, $0a, $02, $01, $96, $7a, $94, $7a, $56, $57
	db $0a, $0a, $02, $01, $a0, $7a, $9e, $7a, $66, $67, $0a, $0a, $02, $01, $aa, $7a
	db $a8, $7a, $5e, $5f, $0a, $0a, $02, $01, $b4, $7a, $b2, $7a, $38, $39, $0d, $0d
	db $02, $01, $be, $7a, $bc, $7a, $70, $71, $05, $05, $02, $01, $c8, $7a, $c6, $7a
	db $78, $79, $05, $05, $02, $01, $d2, $7a, $d0, $7a, $00, $01, $0d, $0d, $02, $01
	db $dc, $7a, $da, $7a, $08, $09, $0d, $0d, $02, $01, $e6, $7a, $e4, $7a, $10, $11
	db $0d, $0d

Data_23_7ae8:
	db $02, $01, $f0, $7a, $ee, $7a, $18, $19, $0d, $0d, $02, $01, $fa, $7a, $f8, $7a
	db $20, $21, $0d, $0d, $02, $01, $04, $7b, $02, $7b, $28, $29, $0d, $0d, $02, $01
	db $0e, $7b, $0c, $7b, $30, $31, $0d, $0d, $02, $01, $18, $7b, $16, $7b, $40, $41
	db $0d, $0d, $02, $01, $22, $7b, $20, $7b, $50, $51, $0d, $0d, $02, $01, $2c, $7b
	db $2a, $7b, $48, $49, $0d, $0d

Data_23_7b2e:
	db $02, $06, $40, $7b, $34, $7b, $79, $24, $2c, $34, $3c, $79, $79, $25, $2d, $35
	db $3d, $79, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b

Data_23_7b4c:
	db $02, $06, $5e, $7b, $52, $7b, $74, $7c, $04, $0c, $14, $1c, $75, $7d, $05, $0d
	db $15, $1d, $03, $03, $0b, $0b, $0b, $0b, $03, $03, $0b, $0b, $0b, $0b

Data_23_7b6a:
	db $e2, $76, $28, $77, $6e, $77, $b4, $77, $cc, $78, $86, $78, $40, $78, $fa, $77
	db $e4, $79, $9e, $79, $58, $79, $12, $79, $7e, $76, $97, $76, $b0, $76, $c9, $76

Data_23_7b8a:
	db $b0, $76, $97, $76, $7e, $76

Data_23_7b90:
	db $2a, $7a, $34, $7a, $3e, $7a, $48, $7a, $52, $7a, $5c, $7a, $66, $7a, $70, $7a
	db $7a, $7a, $84, $7a, $ac, $7a, $b6, $7a, $c0, $7a, $ca, $7a, $d4, $7a, $de, $7a

Data_23_7bb0:
	db $e8, $7a, $f2, $7a, $fc, $7a, $06, $7b

SECTION "analyzed_090000", ROMX[$4000], BANK[$24]

Data_24_4000:
	INCBIN "raw_gfx/Data_24_4000.2bpp", 0, 6144

Data_24_5800:
	db $00, $00, $c6, $18, $ad, $35, $94, $52, $c8, $08, $1f, $00, $32, $32, $f7, $4a
	db $c8, $08, $6d, $1d, $32, $32, $f7, $4a, $c6, $18, $ad, $35, $94, $52, $b9, $46
	db $60, $1c, $2a, $35, $14, $4e, $ff, $3a, $ad, $35, $94, $52, $b9, $46, $60, $1c
	db $00, $00, $31, $46, $00, $44, $20, $02, $00, $00, $31, $46, $00, $44, $20, $02
	db $00, $00, $5f, $4b, $6f, $11, $c0, $1c, $00, $00, $e0, $68, $1f, $00, $e0, $7e
	db $00, $00, $da, $00, $db, $01, $fd, $02, $00, $00, $00, $00, $00, $00, $c8, $08
	db $00, $00, $e7, $1c, $00, $1c, $e0, $00, $00, $00, $a5, $14, $00, $14, $a0, $00
	db $00, $00, $63, $0c, $00, $0c, $60, $00, $00, $00, $21, $04, $00, $04, $20, $00

Data_24_5880:
	db $07, $0b, $d3, $58, $86, $58, $00, $07, $0e, $15, $1c, $23, $2a, $31, $36, $3a
	db $41, $01, $08, $0f, $16, $1d, $24, $32, $32, $37, $3b, $42, $02, $09, $10, $17
	db $1e, $25, $32, $32, $37, $3c, $43, $03, $0a, $11, $18, $1f, $26, $32, $32, $37
	db $3d, $44, $04, $0b, $12, $19, $20, $27, $32, $32, $37, $3e, $45, $05, $0c, $13
	db $1a, $21, $28, $2f, $32, $38, $3f, $46, $06, $0d, $14, $1b, $22, $29, $30, $35
	db $39, $40, $47, $82, $82, $82, $82, $82, $82, $82, $82, $82, $82, $82, $82, $82
	db $82, $82, $82, $82, $82, $82, $82, $82, $82, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $03, $00, $00, $60, $03, $00, $08, $60, $03, $00, $10, $60, $03, $0a, $00, $50
	db $00, $0a, $08, $48, $00, $0a, $10, $40, $00, $0a, $18, $38, $00, $0a, $20, $30
	db $00, $0a, $28, $28, $00, $0a, $38, $10, $00, $2a, $40, $18, $00, $2a, $48, $20
	db $00, $2a, $48, $28, $02, $2a, $03, $00, $00, $f4, $01, $00, $08, $f6, $01, $00
	db $10, $f4, $21, $01, $00, $00, $fe, $01, $03, $00, $00, $f8, $01, $00, $08, $fa
	db $01, $00, $10, $fc, $01, $01, $01, $7d, $59, $7b, $59, $f2

SECTION "analyzed_09197c", ROMX[$597c], BANK[$24]

Data_24_597c:
	db $fe

SECTION "analyzed_09197d", ROMX[$597d], BANK[$24]

Data_24_597d:
	db $01

SECTION "analyzed_09197e", ROMX[$597e], BANK[$24]

Data_24_597e:
	db $08

SECTION "analyzed_09197f", ROMX[$597f], BANK[$24]

Data_24_597f:
	db $12, $09, $27, $5a, $85, $59, $32, $4f, $36, $4f, $58, $60, $68, $70, $32, $28
	db $4f, $36, $4f, $59, $61, $69, $71, $32, $29, $4f, $36, $4f, $5a, $62, $6a, $72
	db $32, $2a, $4f, $36, $4f, $5b, $63, $6b, $73, $28, $2b, $62, $6a, $72, $38, $40
	db $48, $50, $29, $2c, $63, $6b, $73, $39, $41, $49, $51, $2a, $32, $4f, $36, $4f
	db $3b, $42, $4a, $52, $2b, $32, $4f, $36, $4f, $3e, $43, $4b, $53, $2c, $32, $4f
	db $36, $4f, $3e, $46, $4e, $56, $32, $32, $4f, $36, $4f, $3f, $47, $4f, $57, $32
	db $32, $60, $68, $70, $38, $40, $48, $50, $32, $32, $61, $69, $71, $39, $41, $49
	db $51, $32, $31, $4f, $36, $4f, $3b, $42, $4a, $52, $32, $32, $4f, $36, $4f, $3c
	db $44, $4c, $54, $32, $48, $4f, $36, $4f, $3d, $45, $4d, $55, $32, $48, $4f, $36
	db $4f, $51, $54, $57, $5a, $5d, $49, $4b, $4d, $4f, $52, $55, $58, $5b, $5e, $4a
	db $4c, $4e, $50, $53, $56, $59, $5c, $5f, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a
	db $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a
	db $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $02, $02
	db $0a, $0a, $0a, $0a, $2a, $0a, $02, $02, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02
	db $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a
	db $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a
	db $0a, $2a, $0a, $02, $02, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $02, $02, $0a
	db $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a
	db $02, $0a, $0a, $0a, $0a, $2a, $02, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $02
	db $02, $0a, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $12, $09, $71, $5b, $cf, $5a
	db $32, $4f, $36, $4f, $3b, $42, $4a, $52, $32, $32, $4f, $36, $4f, $58, $60, $68
	db $70, $32, $32, $4f, $36, $4f, $59, $61, $69, $71, $32, $32, $4f, $36, $4f, $5a
	db $62, $6a, $72, $31, $32, $66, $6e, $76, $38, $40, $48, $50, $32, $2c, $67, $6f
	db $77, $39, $41, $49, $51, $32, $2d, $4f, $36, $4f, $3c, $44, $4c, $54, $32, $2e
	db $4f, $36, $4f, $3d, $45, $4d, $55, $32, $2f, $4f, $36, $4f, $3b, $42, $4a, $52
	db $32, $32, $4f, $36, $4f, $3e, $43, $4b, $53, $32, $32, $64, $6c, $74, $38, $40
	db $48, $50, $32, $32, $65, $6d, $75, $39, $41, $49, $51, $32, $32, $4f, $36, $4f
	db $58, $60, $68, $70, $32, $28, $4f, $36, $4f, $59, $61, $69, $71, $32, $29, $4f
	db $36, $4f, $5a, $62, $6a, $72, $32, $2a, $4f, $36, $4f, $5b, $63, $6b, $73, $28
	db $2b, $62, $6a, $72, $38, $40, $48, $50, $29, $2c, $63, $6b, $73, $39, $41, $49
	db $51, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a
	db $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a
	db $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $02, $02, $0a, $0a, $0a, $0a, $2a, $0a
	db $02, $02, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a
	db $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a
	db $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $02, $02
	db $0a, $0a, $0a, $0a, $2a, $0a, $02, $02, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02
	db $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a
	db $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a
	db $0a, $2a, $0a, $02, $02, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $02, $02, $0a
	db $0a, $0a, $0a, $2a, $12, $09, $bb, $5c, $19, $5c, $31, $4f, $36, $4f, $3c, $44
	db $4c, $54, $32, $32, $4f, $36, $4f, $3d, $45, $4d, $55, $31, $31, $4f, $36, $4f
	db $3b, $42, $4a, $52, $32, $33, $4f, $36, $4f, $3e, $43, $4b, $53, $32, $34, $7a
	db $02, $0a, $38, $40, $48, $50, $32, $35, $7b, $03, $0b, $39, $41, $49, $51, $31
	db $32, $4f, $36, $4f, $3c, $44, $4c, $54, $33, $32, $4f, $36, $4f, $3d, $45, $4d
	db $55, $34, $32, $4f, $36, $4f, $3b, $42, $4a, $52, $35, $32, $4f, $36, $4f, $3e
	db $43, $4b, $53, $32, $32, $78, $00, $08, $38, $40, $48, $50, $32, $32, $79, $01
	db $09, $39, $41, $49, $51, $32, $32, $4f, $36, $4f, $3b, $42, $4a, $52, $32, $32
	db $4f, $36, $4f, $58, $60, $68, $70, $32, $32, $4f, $36, $4f, $59, $61, $69, $71
	db $32, $32, $4f, $36, $4f, $5a, $62, $6a, $72, $31, $32, $66, $6e, $76, $38, $40
	db $48, $50, $32, $2c, $67, $6f, $77, $39, $41, $49, $51, $32, $0a, $02, $0a, $02
	db $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02
	db $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a
	db $0a, $02, $0a, $0a, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $0a, $0a, $0a, $0a
	db $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a
	db $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a
	db $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $0a, $0a, $0a, $0a, $0a, $2a, $0a
	db $02, $0a, $0a, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a
	db $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a
	db $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $02, $02
	db $0a, $0a, $0a, $0a, $2a, $0a, $02, $02, $02, $0a, $0a, $0a, $0a, $2a, $12, $09
	db $05, $5e, $63, $5d, $32, $4f, $36, $4f, $58, $60, $68, $70, $32, $32, $4f, $36
	db $4f, $59, $61, $69, $71, $31, $32, $4f, $36, $4f, $5a, $62, $6a, $72, $32, $28
	db $4f, $36, $4f, $5b, $63, $6b, $73, $32, $29, $7e, $06, $0e, $38, $40, $48, $50
	db $32, $2a, $7f, $07, $0f, $39, $41, $49, $51, $32, $2b, $4f, $36, $4f, $3d, $45
	db $4d, $55, $28, $2c, $4f, $36, $4f, $3b, $42, $4a, $52, $29, $32, $4f, $36, $4f
	db $3e, $46, $4e, $56, $2a, $32, $4f, $36, $4f, $3f, $47, $4f, $57, $2b, $32, $7c
	db $04, $0c, $38, $40, $48, $50, $2c, $32, $7d, $05, $0d, $39, $41, $49, $51, $32
	db $31, $4f, $36, $4f, $3c, $44, $4c, $54, $32, $32, $4f, $36, $4f, $3d, $45, $4d
	db $55, $31, $31, $4f, $36, $4f, $3b, $42, $4a, $52, $32, $33, $4f, $36, $4f, $3e
	db $43, $4b, $53, $32, $34, $7a, $02, $0a, $38, $40, $48, $50, $32, $35, $7b, $03
	db $0b, $39, $41, $49, $51, $31, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a
	db $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a
	db $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $0a, $0a, $0a
	db $0a, $0a, $2a, $0a, $02, $0a, $0a, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02
	db $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02
	db $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a
	db $0a, $02, $0a, $0a, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $0a, $0a, $0a, $0a
	db $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a
	db $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a
	db $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $0a, $0a, $0a, $0a, $0a, $2a, $0a
	db $02, $0a, $0a, $0a, $0a, $0a, $0a, $2a, $12, $09, $4f, $5f, $ad, $5e, $32, $4f
	db $36, $4f, $3d, $45, $4d, $55, $32, $32, $4f, $36, $4f, $3b, $42, $4a, $52, $32
	db $32, $4f, $36, $4f, $3d, $45, $4d, $55, $32, $32, $4f, $36, $4f, $3b, $42, $4a
	db $52, $32, $32, $12, $1a, $22, $38, $40, $48, $50, $28, $32, $13, $1b, $23, $39
	db $41, $49, $51, $29, $32, $4f, $36, $4f, $3c, $44, $4c, $52, $2a, $32, $4f, $36
	db $4f, $3d, $45, $4d, $52, $2b, $32, $4f, $36, $4f, $3e, $46, $4e, $56, $2c, $32
	db $4f, $36, $4f, $3f, $47, $4f, $57, $32, $32, $10, $18, $20, $38, $40, $48, $50
	db $32, $32, $11, $19, $21, $39, $41, $49, $51, $32, $32, $4f, $36, $4f, $58, $60
	db $68, $70, $32, $32, $4f, $36, $4f, $59, $61, $69, $71, $31, $32, $4f, $36, $4f
	db $5a, $62, $6a, $72, $32, $28, $4f, $36, $4f, $5b, $63, $6b, $73, $32, $29, $7e
	db $06, $0e, $38, $40, $48, $50, $32, $2a, $7f, $07, $0f, $39, $41, $49, $51, $32
	db $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a
	db $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a
	db $0a, $0a, $0a, $2a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $2a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a
	db $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a
	db $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $2a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02
	db $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02
	db $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a
	db $0a, $02, $0a, $0a, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $0a, $0a, $0a, $0a
	db $0a, $2a, $12, $09, $99, $60, $f7, $5f, $78, $7a, $7b, $7c, $7c, $7c, $7c, $7d
	db $7e, $79, $4f, $4f, $4f, $5d, $65, $6d, $75, $7f, $32, $4f, $4f, $4f, $5e, $66
	db $6e, $76, $32, $32, $4f, $4f, $4f, $5f, $67, $6f, $77, $32, $32, $16, $1e, $26
	db $38, $40, $48, $50, $32, $32, $17, $1f, $27, $39, $41, $49, $51, $32, $32, $4f
	db $36, $4f, $3d, $45, $4d, $55, $32, $32, $4f, $36, $4f, $3b, $42, $4a, $52, $2b
	db $32, $4f, $36, $4f, $3d, $45, $4d, $55, $2c, $32, $4f, $36, $4f, $3b, $42, $4a
	db $52, $32, $32, $14, $1c, $24, $38, $40, $48, $50, $32, $32, $15, $1d, $25, $39
	db $41, $49, $51, $32, $32, $4f, $36, $4f, $3d, $45, $4d, $55, $32, $32, $4f, $36
	db $4f, $3b, $42, $4a, $52, $32, $32, $4f, $36, $4f, $3d, $45, $4d, $55, $32, $32
	db $4f, $36, $4f, $3b, $42, $4a, $52, $32, $32, $12, $1a, $22, $38, $40, $48, $50
	db $28, $32, $13, $1b, $23, $39, $41, $49, $51, $29, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $02, $02, $02, $0a, $0a, $0a, $0a, $0a, $0a, $02, $02, $02
	db $0a, $0a, $0a, $0a, $2a, $0a, $02, $02, $02, $0a, $0a, $0a, $0a, $2a, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $2a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $2a
	db $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a
	db $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a
	db $0a, $0a, $0a, $2a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $2a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a
	db $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a
	db $2a, $0a, $02, $0a, $02, $0a, $0a, $0a, $0a, $2a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $2a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $2a, $12, $09, $e3, $61
	db $41, $61, $ac, $ae, $af, $b0, $b1, $b3, $b3, $b5, $b7, $ad, $b8, $b9, $b8, $b2
	db $b4, $b4, $b6, $ad, $ba, $80, $82, $84, $cc, $ce, $d0, $d2, $bc, $bb, $81, $83
	db $85, $cd, $cf, $d1, $d3, $bc, $bc, $ca, $cb, $ca, $d4, $d6, $d6, $d4, $bc, $bc
	db $ca, $cb, $ca, $d5, $d7, $d7, $d5, $bc, $bc, $80, $86, $88, $cc, $ce, $d0, $d2
	db $bc, $bc, $81, $87, $89, $cd, $cf, $d1, $d3, $bc, $bc, $ca, $cb, $ca, $d4, $d6
	db $d6, $d4, $bc, $bc, $ca, $cb, $ca, $d5, $d7, $d7, $d5, $bc, $bc, $80, $8a, $8c
	db $cc, $ce, $d0, $d2, $bc, $bc, $81, $8b, $8d, $cd, $cf, $d1, $d3, $bc, $bc, $ca
	db $cb, $ca, $d4, $d6, $d6, $d4, $bc, $bc, $ca, $cb, $ca, $d5, $d7, $d7, $d5, $bc
	db $bc, $80, $8e, $90, $cc, $ce, $d0, $d2, $bc, $bc, $81, $8f, $91, $cd, $cf, $d1
	db $d3, $bc, $bc, $ca, $cb, $ca, $d4, $d6, $d6, $d4, $bc, $bc, $ca, $cb, $ca, $d5
	db $d7, $d7, $d5, $bc, $02, $02, $02, $02, $02, $02, $22, $02, $02, $02, $02, $02
	db $22, $02, $02, $22, $02, $22, $02, $02, $02, $02, $02, $02, $02, $02, $22, $02
	db $02, $02, $02, $02, $02, $02, $02, $22, $02, $02, $02, $22, $02, $02, $22, $22
	db $22, $02, $42, $42, $62, $02, $02, $22, $22, $22, $02, $02, $02, $02, $02, $02
	db $02, $02, $22, $02, $02, $02, $02, $02, $02, $02, $02, $22, $02, $02, $02, $22
	db $02, $02, $22, $22, $22, $02, $42, $42, $62, $02, $02, $22, $22, $22, $02, $02
	db $02, $02, $02, $02, $02, $02, $22, $02, $02, $02, $02, $02, $02, $02, $02, $22
	db $02, $02, $02, $22, $02, $02, $22, $22, $22, $02, $42, $42, $62, $02, $02, $22
	db $22, $22, $02, $02, $02, $02, $02, $02, $02, $02, $22, $02, $02, $02, $02, $02
	db $02, $02, $02, $22, $02, $02, $02, $22, $02, $02, $22, $22, $22, $02, $42, $42
	db $62, $02, $02, $22, $22, $22, $12, $09, $2d, $63, $8b, $62, $bc, $ca, $cb, $ca
	db $d4, $d6, $d6, $d4, $bc, $bc, $ca, $cb, $ca, $d5, $d7, $d7, $d5, $bc, $bc, $80
	db $8e, $90, $cc, $ce, $d0, $d2, $bc, $bc, $81, $8f, $91, $cd, $cf, $d1, $d3, $bc
	db $bc, $ca, $cb, $ca, $d4, $d6, $d6, $d4, $bc, $bc, $ca, $cb, $ca, $d5, $d7, $d7
	db $d5, $bc, $bc, $80, $92, $94, $cc, $ce, $d0, $d2, $bc, $bc, $81, $93, $95, $cd
	db $cf, $d1, $d3, $bc, $bc, $ca, $cb, $ca, $d4, $d6, $d6, $d4, $bc, $bc, $ca, $cb
	db $ca, $d5, $d7, $d7, $d5, $bc, $bc, $80, $96, $98, $cc, $ce, $d0, $d2, $bc, $bc
	db $81, $97, $99, $cd, $cf, $d1, $d3, $bc, $bc, $ca, $cb, $ca, $d4, $d6, $d6, $d4
	db $bc, $bc, $ca, $cb, $ca, $d5, $d7, $d7, $d5, $bc, $bc, $80, $9a, $9c, $cc, $ce
	db $d0, $d2, $bc, $bc, $81, $9b, $9d, $cd, $cf, $d1, $d3, $bc, $bc, $ca, $cb, $ca
	db $d4, $d6, $d6, $d4, $bc, $bc, $ca, $cb, $ca, $d5, $d7, $d7, $d5, $bc, $02, $02
	db $02, $22, $02, $02, $22, $22, $22, $02, $42, $42, $62, $02, $02, $22, $22, $22
	db $02, $02, $02, $02, $02, $02, $02, $02, $22, $02, $02, $02, $02, $02, $02, $02
	db $02, $22, $02, $02, $02, $22, $02, $02, $22, $22, $22, $02, $42, $42, $62, $02
	db $02, $22, $22, $22, $02, $02, $02, $02, $02, $02, $02, $02, $22, $02, $02, $02
	db $02, $02, $02, $02, $02, $22, $02, $02, $02, $22, $02, $02, $22, $22, $22, $02
	db $42, $42, $62, $02, $02, $22, $22, $22, $02, $02, $02, $02, $02, $02, $02, $02
	db $22, $02, $02, $02, $02, $02, $02, $02, $02, $22, $02, $02, $02, $22, $02, $02
	db $22, $22, $22, $02, $42, $42, $62, $02, $02, $22, $22, $22, $02, $02, $02, $02
	db $02, $02, $02, $02, $22, $02, $02, $02, $02, $02, $02, $02, $02, $22, $02, $02
	db $02, $22, $02, $02, $22, $22, $22, $02, $42, $42, $62, $02, $02, $22, $22, $22
	db $12, $09, $77, $64, $d5, $63, $bc, $ca, $cb, $ca, $d4, $d6, $d6, $d4, $bc, $bc
	db $ca, $cb, $ca, $d5, $d7, $d7, $d5, $bc, $bc, $80, $9a, $9c, $cc, $ce, $d0, $d2
	db $bc, $bc, $81, $9b, $9d, $cd, $cf, $d1, $d3, $bc, $bc, $ca, $cb, $ca, $d4, $d6
	db $d6, $d4, $bc, $bc, $ca, $cb, $ca, $d5, $d7, $d7, $d5, $bc, $bc, $80, $9e, $a0
	db $cc, $ce, $d0, $d2, $bc, $bc, $81, $9f, $a1, $cd, $cf, $d1, $d3, $bc, $bc, $ca
	db $cb, $ca, $d4, $d6, $d6, $d4, $bc, $bc, $ca, $cb, $ca, $d5, $d7, $d7, $d5, $bc
	db $bc, $80, $a2, $a4, $cc, $ce, $d0, $d2, $bc, $bc, $81, $a3, $a5, $cd, $cf, $d1
	db $d3, $bc, $bc, $ca, $cb, $ca, $d4, $d6, $d6, $d4, $bc, $bc, $ca, $cb, $ca, $d5
	db $d7, $d7, $d5, $bc, $bc, $a6, $a8, $aa, $cc, $ce, $d0, $d2, $bc, $bc, $a7, $a9
	db $ab, $cd, $cf, $d1, $d3, $bc, $ad, $b8, $b9, $b8, $c1, $c3, $c5, $c7, $ad, $bd
	db $be, $bf, $c0, $c2, $c4, $c6, $c8, $c9, $02, $02, $02, $22, $02, $02, $22, $22
	db $22, $02, $42, $42, $62, $02, $02, $22, $22, $22, $02, $02, $02, $02, $02, $02
	db $02, $02, $22, $02, $02, $02, $02, $02, $02, $02, $02, $22, $02, $02, $02, $22
	db $02, $02, $22, $22, $22, $02, $42, $42, $62, $02, $02, $22, $22, $22, $02, $02
	db $02, $02, $02, $02, $02, $02, $22, $02, $02, $02, $02, $02, $02, $02, $02, $22
	db $02, $02, $02, $22, $02, $02, $22, $22, $22, $02, $42, $42, $62, $02, $02, $22
	db $22, $22, $02, $02, $02, $02, $02, $02, $02, $02, $22, $02, $02, $02, $02, $02
	db $02, $02, $02, $22, $02, $02, $02, $22, $02, $02, $22, $22, $22, $02, $42, $42
	db $62, $02, $02, $22, $22, $22, $02, $02, $02, $02, $02, $02, $02, $02, $22, $02
	db $02, $02, $02, $02, $02, $02, $02, $22, $42, $42, $42, $62, $02, $02, $02, $02
	db $62, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $00, $00, $00, $0a, $00
	db $08, $08, $0a, $02, $00, $00, $02, $0a, $00, $08, $0a, $0a, $02, $00, $00, $04
	db $0a, $00, $08, $0c, $0a, $02, $00, $00, $06, $0a, $00, $08, $0e, $0a, $02, $01
	db $45, $65, $43, $65, $ea, $eb, $02, $02, $02, $01, $4f, $65, $4d, $65, $d8, $d9
	db $02, $02, $02, $01, $59, $65, $57, $65, $da, $db, $02, $02, $02, $01, $63, $65
	db $61, $65, $dc, $dd, $02, $02, $02, $01, $6d, $65, $6b, $65, $de, $df, $02, $02
	db $02, $01, $77, $65, $75, $65, $e0, $e1, $02, $02, $02, $01, $81, $65, $7f, $65
	db $e2, $e3, $02, $02, $02, $01, $8b, $65, $89, $65, $e4, $e5, $02, $02, $02, $01
	db $95, $65, $93, $65, $e6, $e7, $02, $02, $02, $01, $9f, $65, $9d, $65, $e8, $e9
	db $02, $02, $02, $01, $a9, $65, $a7, $65, $ec, $ed, $02, $02, $02, $01, $b3, $65
	db $b1, $65, $ee, $ef, $02, $02, $02, $01, $bd, $65, $bb, $65, $f0, $f1, $02, $02
	db $7f, $59, $c9, $5a, $13, $5c, $5d, $5d, $a7, $5e, $f1, $5f, $3b, $61, $85, $62
	db $cf, $63, $19, $65, $22, $65, $2b, $65, $34, $65, $3d, $65, $47, $65, $51, $65
	db $5b, $65, $65, $65, $6f, $65, $79, $65, $83, $65, $8d, $65, $97, $65, $a1, $65
	db $ab, $65, $b5, $65, $75, $59

SECTION "analyzed_094000", ROMX[$4000], BANK[$25]

Data_25_4000:
	INCBIN "raw_gfx/Data_25_4000.2bpp", 0, 6144

Data_25_5800:
	db $04, $00, $04, $00, $06, $00, $01, $00, $00, $00, $02, $00, $11, $00, $16, $01
	db $3e, $01, $2d, $13, $67, $1b, $33, $0d, $1d, $07, $07, $03, $07, $01, $01, $00
	db $00, $00, $00, $00, $00, $00, $03, $00, $02, $00, $07, $00, $0d, $02, $04, $03
	db $1c, $03, $2d, $13, $25, $1f, $33, $0f, $14, $0b, $36, $0f, $08, $07, $01, $00
	db $00, $00, $00, $00, $01, $00, $0b, $00, $12, $00, $03, $00, $1f, $00, $16, $01
	db $3e, $03, $2f, $13, $26, $1f, $37, $0f, $1d, $07, $3f, $03, $0f, $01, $01, $00
	db $00, $00, $00, $00, $20, $00, $0e, $00, $07, $00, $0a, $05, $0c, $03, $04, $03
	db $27, $19, $27, $19, $69, $1f, $31, $0f, $05, $1f, $73, $0f, $1f, $01, $01, $00
	db $00, $00, $00, $00, $80, $00, $80, $00, $c0, $00, $c0, $00, $30, $c0, $60, $80
	db $38, $c0, $fe, $a0, $5c, $b0, $a8, $f0, $f8, $e0, $f0, $c0, $20, $c0, $c0, $00
	db $00, $00, $00, $40, $00, $00, $00, $00, $00, $00, $c0, $00, $30, $c0, $60, $80
	db $b4, $c0, $f0, $80, $f8, $80, $08, $f0, $98, $e0, $f0, $c0, $a0, $c0, $c0, $00
	db $00, $00, $c0, $00, $80, $00, $00, $00, $00, $00, $c0, $00, $30, $c0, $60, $80
	db $34, $c0, $72, $a0, $7c, $80, $08, $f0, $98, $e0, $f0, $c0, $20, $c0, $c0, $00
	db $00, $00, $40, $00, $80, $00, $a0, $00, $d0, $00, $c0, $00, $60, $80, $10, $e0
	db $b8, $c0, $86, $f8, $3c, $d0, $88, $f0, $f8, $e0, $f0, $c0, $20, $c0, $c0

SECTION "analyzed_096000", ROMX[$6000], BANK[$25]

Data_25_6000:
	db $5a, $00, $af, $00, $57, $00, $af, $00, $57, $00, $2b, $00, $17, $00, $2b, $00
	db $57, $00, $0b, $00, $57, $00, $2f, $00, $15, $00, $4b, $00, $15, $00, $0a, $00
	db $01, $00, $0a, $00, $05, $00, $02, $00, $00, $00, $01, $00, $80, $00, $01, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $f0, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ec, $00, $fe, $00, $ff, $00
	db $fe, $00, $fe, $00, $fe, $00, $7f, $00, $be, $00, $7e, $00, $04, $00, $7f, $00
	db $ff, $00, $5f, $00, $2f, $00, $03, $00, $17, $00, $09, $00, $03, $00, $00, $00
	db $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $00
	db $ff, $00, $fb, $04, $fb, $04, $fb, $04, $fb, $04, $f3, $0c, $23, $1c, $fb, $04
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $21, $1e, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $7e, $00, $d0, $00, $fb, $00
	db $fb, $00, $fb, $00, $d0, $0f, $df, $00, $c0, $00, $fb, $00, $f1, $00, $01, $00
	db $ff, $00, $3f, $00, $7f, $00, $9f, $00, $77, $00, $2f, $00, $17, $00, $b8, $00
	db $ff, $00, $ff, $00, $fe, $01, $ff, $00, $fc, $03, $f4, $0b, $e8, $17, $f0, $0f
	db $d1, $2f, $e0, $1f, $c5, $3f, $c3, $3f, $87, $7f, $0b, $ff, $87, $7f, $4f, $bf
	db $87, $7f, $cf, $3f, $87, $7f, $cb, $3f, $a7, $5f, $c7, $3f, $23, $5f, $d1, $2f
	db $e3, $1f, $d8, $27, $34, $cb, $aa, $55, $3d, $02, $fa, $05, $fe, $01, $0c, $f3
	db $9f, $60, $ff, $00, $bf, $00, $bf, $00, $bf, $00, $bf, $00, $3f, $00, $11, $0e
	db $3f, $00, $1f, $00, $2b, $00, $16, $00, $09, $00, $06, $00, $00, $00, $00, $00
	db $fa, $05, $b0, $4f, $80, $7f, $00, $ff, $02, $ff, $15, $ff, $4f, $ff, $3f, $ff
	db $7f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $7f, $ff, $5f, $ff, $bf, $ff, $57, $ff, $0a, $ff, $80, $7f, $50, $af, $b5, $4a
	db $e9, $16, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $a0, $5f
	db $fc, $00, $fe, $00, $fe, $00, $7e, $00, $56, $00, $24, $00, $48, $00, $00, $00
	db $bf, $40, $0b, $f4, $01, $fe, $00, $ff, $a0, $ff, $54, $ff, $fa, $ff, $fe, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $fe, $ff, $fd, $ff, $b4, $ff, $50, $ff, $01, $fe, $0f, $f0, $7d, $82
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $fe, $01, $fe, $01, $fd, $02, $1b, $e4
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $75, $00, $6a, $00
	db $fe, $00, $fe, $00, $7e, $80, $be, $40, $5e, $a0, $2e, $d0, $16, $e8, $0a, $f4
	db $8e, $f0, $82, $fc, $a6, $f8, $c4, $fa, $e2, $fc, $c0, $fe, $f2, $fc, $e0, $fe
	db $f2, $fc, $e0, $fe, $f2, $fc, $e0, $fe, $f6, $f8, $e2, $fc, $d6, $f8, $8e, $f0
	db $46, $f8, $1e, $e0, $2e, $d0, $5e, $a0, $fe, $00, $7c, $82, $e0, $1e, $fe, $00
	db $be, $00, $be, $00, $fe, $00, $be, $00, $be, $00, $be, $00, $1e, $00, $04, $00
	db $fe, $00, $fe, $00, $fe, $00, $fe, $00, $fc, $00, $fa, $00, $ac, $00, $50, $00
	db $00, $00, $00, $00, $0c, $00, $18, $00, $1e, $00, $1d, $00, $3f, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $06, $00, $29, $00, $56, $00, $2b, $00, $df, $00, $ff, $00
	db $fd, $02, $cf, $30, $df, $20, $df, $20, $df, $20, $fe, $01, $fd, $02, $e8, $17
	db $00, $00, $48, $00, $24, $00, $56, $00, $7e, $00, $ff, $00, $fe, $01, $fc, $03
	db $00, $ff, $ff, $00, $ff, $00, $ff, $00, $d6, $29, $a0, $5f, $00, $ff, $00, $ff
	db $6a, $00, $75, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $26, $d9, $ff, $00, $ff, $00, $5f, $a0, $aa, $55, $01, $fe, $00, $ff, $00, $ff
	db $50, $00, $ac, $00, $fa, $00, $fc, $00, $fe, $00, $ff, $00, $ff, $00, $fc, $03
	db $61, $9e, $9f, $60, $df, $20, $df, $20, $ff, $00, $bf, $40, $2f, $d0, $0b, $f4
	db $00, $00, $00, $00, $60, $00, $10, $00, $68, $00, $54, $00, $78, $00, $7c, $00
	db $90, $6c, $fe, $00, $fd, $00, $fa, $00, $fd, $00, $fa, $00, $fc, $00, $f0, $00
	db $3e, $ff, $ff, $00, $ff, $00, $ff, $00, $0b, $ff, $ff, $00, $ff, $00, $ff, $00
	db $01, $ff, $1f, $e0, $0f, $f0, $1f, $e0, $01, $ff, $01, $fe, $00, $ff, $01, $fe
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $80, $7f, $00, $ff
	db $80, $7f, $40, $bf, $a0, $5f, $40, $bf, $a0, $5f, $40, $bf, $a4, $5b, $c8, $37
	db $a2, $5d, $c0, $3f, $a4, $5b, $c8, $37, $72, $0d, $bd, $02, $5f, $00, $26, $00
	db $0c, $00, $01, $00, $03, $00, $04, $00, $10, $00, $10, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $9e, $ff, $ff, $00, $ff, $00, $ff, $00, $3f, $ff, $ff, $00, $ff, $00, $ff, $00
	db $01, $ff, $1f, $e0, $0f, $f0, $1f, $e0, $00, $ff, $01, $fe, $00, $ff, $01, $fe
	db $00, $ff, $00, $ff, $00, $ff, $04, $fb, $08, $f7, $00, $ff, $08, $f7, $10, $ef
	db $50, $af, $50, $af, $38, $c7, $28, $97, $88, $37, $40, $3f, $02, $7d, $81, $7e
	db $e1, $1e, $d4, $2b, $6a, $15, $ba, $05, $2d, $02, $0a, $01, $03, $00, $00, $00
	db $05, $00, $02, $00, $05, $00, $02, $00, $00, $00, $00, $00, $01, $00, $00, $00
	db $7e, $ff, $ff, $00, $ff, $00, $ff, $00, $0f, $ff, $ff, $00, $ff, $00, $ff, $00
	db $01, $ff, $1f, $e0, $0f, $f0, $1f, $e0, $00, $ff, $01, $fe, $00, $ff, $01, $fe
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $80, $7f, $80, $7f, $40, $bf, $a0, $5f, $54, $ab, $aa, $55
	db $d5, $2a, $ea, $15, $f4, $0b, $ea, $15, $75, $0a, $ba, $05, $7d, $02, $ba, $05
	db $7e, $ff, $ff, $00, $ff, $00, $ff, $00, $0f, $ff, $ff, $00, $ff, $00, $ff, $00
	db $00, $ff, $3f, $c0, $1f, $e0, $3f, $c0, $00, $ff, $03, $fc, $01, $fe, $03, $fc
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $48, $b7
	db $44, $bb, $80, $7f, $00, $ff, $00, $ff, $08, $f7, $40, $bf, $a0, $5f, $00, $ff
	db $fc, $ff, $ff, $00, $ff, $00, $ff, $00, $07, $ff, $ff, $00, $ff, $00, $ff, $00
	db $00, $ff, $3f, $c0, $1f, $e0, $3f, $c0, $00, $ff, $03, $fc, $01, $fe, $3f, $c0
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $78, $ff, $ff, $00, $ff, $00, $ff, $00, $0f, $ff, $ff, $00, $ff, $00, $ff, $00
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $01, $fe, $0a, $f5, $01, $fe, $02, $fd, $05, $fa, $12, $ed, $05, $fa
	db $00, $ff, $74, $80, $b8, $40, $54, $a0, $f8, $00, $e8, $00, $f4, $00, $e8, $00
	db $ff, $00, $2e, $00, $15, $00, $0a, $00, $0f, $0f, $1f, $00, $0f, $00, $1f, $00
	db $3f, $ff, $ff, $00, $ff, $00, $ff, $00, $fe, $ff, $ff, $00, $ff, $00, $ff, $00
	db $e0, $ff, $fc, $03, $f8, $07, $fc, $03, $00, $ff, $c0, $3f, $80, $7f, $c0, $3f
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $1f, $ef, $0f, $0f, $0f, $0f, $0f, $0f
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $3f, $cf, $0f, $0f, $0f, $0f, $0f, $0f
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $3f, $cf, $0f, $0f, $0f, $0f, $0f, $0f
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $3f, $cf, $0f, $0f, $0f, $0f, $0f, $0f
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $3f, $cf, $0f, $0f, $0f, $0f, $0f, $0f
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $7f, $8f, $0f, $0f, $0f, $0f, $0f, $0f

SECTION "analyzed_096801", ROMX[$6801], BANK[$25]

Data_25_6801:
	db $ff, $ff, $ff, $10, $30, $00, $10, $81, $93, $81, $93, $81, $93, $10, $10, $10
	db $30, $3e, $7f, $72, $f3, $f2, $f3, $00, $10, $00, $18, $ff, $ff, $00, $ff, $00
	db $ff, $ff, $ff, $10, $38, $00, $10, $80, $93, $81, $93, $81, $93, $11, $33, $11
	db $33, $81, $93, $81, $93, $80, $93, $00, $10, $10, $38, $ff, $ff, $00, $ff, $00
	db $ff, $ff, $ff, $10, $30, $00, $10, $81, $93, $81, $93, $81, $93, $10, $30, $10
	db $30, $8e, $9f, $82, $93, $82, $93, $00, $10, $10, $38, $ff, $ff, $00, $ff, $00
	db $ff, $ff, $ff, $10, $98, $10, $10, $10, $13, $11, $13, $11, $13, $11, $93, $11
	db $93, $11, $93, $01, $03, $00, $03, $90, $90, $90, $98, $ff, $ff, $00, $ff, $0f
	db $8f, $8f, $cf, $0f, $2f, $2f, $3f, $ef, $ff, $ef, $ff, $ef, $ff, $2f, $7f, $2f
	db $3f, $2f, $3f, $2f, $3f, $2f, $3f, $2f, $3f, $0f, $6f, $8f, $cf, $0f, $8f, $0f
	db $8f, $8f, $cf, $0f, $6f, $2f, $3f, $2f, $3f, $2f, $3f, $2f, $3f, $2f, $3f, $2f
	db $3f, $2f, $3f, $2f, $3f, $2f, $3f, $2f, $3f, $0f, $6f, $8f, $cf, $0f, $8f, $0f
	db $8f, $8f, $cf, $0f, $2f, $2f, $3f, $ef, $ff, $ef, $ff, $ef, $ff, $2f, $7f, $2f
	db $3f, $2f, $3f, $2f, $3f, $2f, $3f, $2f, $3f, $0f, $6f, $8f, $cf, $0f, $8f, $0f
	db $8f, $8f, $cf, $0f, $6f, $2f, $3f, $2f, $3f, $2f, $3f, $2f, $3f, $2f, $3f, $2f
	db $3f, $2f, $3f, $2f, $3f, $2f, $3f, $2f, $3f, $0f, $6f, $8f, $cf, $0f, $8f, $f0
	db $f1, $f1, $f3, $f3, $ff, $f7, $ff, $f6, $ff, $f6, $fe, $f6, $fe, $f4, $fe, $f4
	db $fc, $f4, $fc, $f4, $fc, $f4, $fc, $f7, $ff, $f3, $f7, $f1, $f3, $f0, $f1, $f0
	db $f1, $f1, $f3, $f0, $f4, $f4, $fc, $f4, $fc, $f4, $fc, $f4, $fc, $f4, $fc, $f4
	db $fc, $f7, $ff, $f4, $fc, $f4, $fc, $f4, $fc, $f0, $f6, $f1, $f3, $f0, $f1, $f0
	db $f1, $f1, $f3, $f0, $f4, $f4, $fc, $f4, $fc, $f4, $fc, $f4, $fc, $f4, $fc, $f4
	db $fc, $f7, $ff, $f4, $fc, $f4, $fc, $f4, $fc, $f0, $f6, $f1, $f3, $f0, $f1, $f0
	db $f1, $f1, $f3, $f0, $f6, $f4, $fc, $f4, $fc, $f4, $fc, $f4, $fc, $f4, $fc, $f4
	db $fc, $f4, $fc, $f4, $fc, $f4, $fc, $f4, $fc, $f0, $f6, $f1, $f3, $f0, $f1, $00
	db $ff, $ff, $ff, $10, $90, $10, $10, $11, $13, $11, $13, $11, $13, $10, $90, $10
	db $90, $1e, $9f, $02, $03, $02, $03, $90, $90, $90, $98, $ff, $ff, $00, $ff, $00
	db $ff, $ff, $ff, $00, $18, $00, $10, $70, $f3, $71, $f3, $71, $f3, $01, $13, $01
	db $03, $81, $c3, $81, $c3, $80, $c3, $00, $00, $00, $18, $ff, $ff, $00, $ff, $00
	db $ff, $ff, $ff, $00, $10, $00, $10, $71, $f3, $71, $f3, $71, $f3, $00, $10, $00
	db $00, $8e, $cf, $82, $c3, $82, $c3, $00, $00, $00, $18, $ff, $ff, $00, $ff, $00
	db $ff, $ff, $ff, $10, $18, $00, $00, $40, $c3, $41, $c3, $71, $f3, $01, $13, $01
	db $03, $81, $c3, $81, $c3, $80, $c3, $00, $00, $00, $18, $ff, $ff, $00, $ff, $0f
	db $8f, $8f, $cf, $0f, $2f, $2f, $3f, $ef, $ff, $ef, $ff, $ef, $ff, $2f, $7f, $2f
	db $3f, $2f, $3f, $2f, $3f, $2f, $3f, $2f, $3f, $0f, $6f, $8f, $cf, $0f, $8f, $0f
	db $8f, $8f, $cf, $0f, $6f, $2f, $3f, $2f, $3f, $2f, $3f, $2f, $3f, $2f, $3f, $2f
	db $3f, $2f, $3f, $2f, $3f, $2f, $3f, $2f, $3f, $0f, $6f, $8f, $cf, $0f, $8f, $0f
	db $8f, $8f, $cf, $0f, $2f, $2f, $3f, $ef, $ff, $ef, $ff, $ef, $ff, $2f, $7f, $2f
	db $3f, $2f, $3f, $2f, $3f, $2f, $3f, $2f, $3f, $0f, $6f, $8f, $cf, $0f, $8f, $0f
	db $8f, $8f, $cf, $0f, $6f, $2f, $3f, $2f, $3f, $2f, $3f, $2f, $3f, $2f, $3f, $2f
	db $3f, $2f, $3f, $2f, $3f, $2f, $3f, $2f, $3f, $0f, $6f, $8f, $cf, $0f, $8f, $fd
	db $f7, $fd, $f7, $fd, $f7, $fd, $f7, $7d, $f7, $7d, $f7, $fd, $77, $bd, $77, $bd
	db $77, $bd, $77, $fd, $37, $fd, $37, $dd, $37, $dd, $37, $dd, $37, $dd, $37, $dd
	db $37, $fd, $37, $fd, $37, $bd, $77, $bd, $77, $bd, $77, $bd, $77, $fd, $37, $bd
	db $77, $fd, $37, $fd, $37, $bd, $77, $bd, $77, $bd, $77, $3d, $f7, $7d, $f7, $fd
	db $f7, $fd, $f7, $fd, $f7, $fd, $f7, $7d, $f7, $7d, $f7, $fd, $77, $bd, $77, $bd
	db $77, $bd, $77, $fd, $37, $fd, $37, $dd, $37, $dd, $37, $dd, $37, $dd, $37, $dd
	db $37, $fd, $37, $fd, $37, $bd, $77, $bd, $77, $bd, $77, $bd, $77, $fd, $37, $bd
	db $77, $fd, $37, $fd, $37, $bd, $77, $bd, $77, $bd, $77, $3d, $f7, $7d, $f7, $7d
	db $f7, $7d, $f7, $7d, $f7, $7d, $f7, $7d, $f7, $fd, $f7, $fd, $f7, $fd, $f7, $f5
	db $ff, $f5, $ff, $f5, $ff, $f5, $ff, $fd, $f7, $f5, $ff, $fd, $f7, $fd, $f7, $fd
	db $f7, $fd, $f7, $fd, $f7, $fd, $f7, $fd, $f7, $fd, $f7, $fd, $f7, $fd, $f7, $7d
	db $f7, $7d, $f7, $7d, $f7, $7d, $f7, $7d, $f7, $3d, $f7, $bd, $77, $9d, $77, $dd
	db $37, $dd, $37, $dd, $37, $fd, $37, $bd, $77, $bd, $77, $bd, $77, $bd, $77, $3d
	db $f7, $7d, $f7, $7d, $f7, $7d, $f7, $fd, $f7, $fd, $f7, $fd, $f7, $fd, $f7, $ff
	db $ff, $81, $81, $81, $bd, $99, $bd, $99, $bd, $81, $bd, $81, $81, $ff, $ff, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $e9
	db $f7, $e8, $f7, $e7, $ff, $e8, $f7, $eb, $f5, $eb, $f5, $eb, $f5, $eb, $f5, $eb
	db $f5, $cb, $f5, $c3, $fd, $cb, $f5, $88, $f7, $8f, $f0, $c8, $f7, $e1, $ff, $e9
	db $f7, $e9, $f7, $c9, $f7, $89, $f7, $c9, $f7, $e9, $f7, $c9, $f7, $e9, $f7, $c9
	db $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9
	db $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9
	db $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9
	db $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9
	db $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $6f
	db $bf, $3f, $ef, $fb, $dc, $ed, $32, $7f, $e0, $57, $eb, $7b, $c5, $7d, $ce, $7f
	db $cf, $76, $cd, $7f, $e3, $7d, $e3, $2e, $f1, $5b, $fc, $6f, $bf, $6f, $bf, $ef
	db $bf, $ef, $bb, $ec, $bb, $ed, $ba, $ee, $b9, $ef, $b9, $ee, $b9, $ef, $bf, $ef
	db $bf, $eb, $bc, $ef, $bf, $ee, $bf, $ed, $be, $ee, $bd, $ea, $bd, $ef, $b8, $ef
	db $bf, $ef, $bb, $ef, $bc, $ef, $be, $ee, $b9, $ef, $bb, $ef, $bb, $ef, $b8, $ef
	db $bf, $ed, $be, $eb, $bf, $ee, $bb, $ee, $bb, $eb, $bf, $ed, $be, $ef, $bf, $ef
	db $bf, $ef, $bc, $ed, $bb, $ed, $ba, $ed, $ba, $ed, $bb, $ee, $bd, $ef, $bf, $ef
	db $bf, $ec, $bb, $ef, $b9, $ed, $ba, $ec, $bb, $ec, $bb, $ef, $b8, $ef, $bf, $f6
	db $fd, $fc, $f7, $d7, $3b, $fb, $0c, $ae, $57, $7a, $97, $f6, $fb, $fe, $33, $7e
	db $d3, $d6, $fb, $7a, $f7, $de, $27, $7c, $8f, $da, $3f, $f6, $fd, $f6, $fd, $f7
	db $fd, $77, $9d, $b7, $5d, $77, $dd, $f7, $dd, $37, $dd, $f7, $1d, $f7, $fd, $f7
	db $fd, $d7, $3d, $97, $fd, $97, $7d, $d7, $3d, $d7, $bd, $b7, $dd, $f7, $1d, $f7
	db $fd, $f7, $fd, $d7, $3d, $77, $fd, $77, $9d, $b7, $dd, $b7, $dd, $f7, $1d, $f7
	db $fd, $b7, $7d, $d7, $fd, $77, $dd, $77, $dd, $d7, $fd, $b7, $7d, $f7, $fd, $f7
	db $fd, $b7, $7d, $57, $bd, $37, $dd, $b7, $5d, $b7, $dd, $57, $bd, $f7, $fd, $f7
	db $fd, $17, $fd, $d7, $fd, $d7, $fd, $d7, $7d, $57, $bd, $f7, $1d, $f7, $fd, $97
	db $ef, $17, $ef, $e7, $ff, $17, $ef, $d7, $af, $d7, $af, $d7, $af, $d7, $af, $d7
	db $af, $d7, $af, $c7, $bf, $d7, $af, $17, $ef, $f7, $0f, $17, $ef, $87, $ff, $97
	db $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97
	db $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97
	db $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97
	db $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97
	db $ef, $97, $ef, $93, $ef, $81, $ff, $90, $ef, $83, $ff, $93, $ef, $91, $ef, $91
	db $ef, $93, $ef, $93, $ef, $93, $ef, $97, $ef, $93, $ef, $97, $ef, $97, $ef, $e9
	db $f7, $e9, $f7, $e9, $f7, $f9, $f7, $e9, $f7, $f9, $f7, $f9, $f7, $f9, $f7, $f9
	db $f7, $e9, $f7, $e9, $f7, $c9, $f7, $c9, $f7, $c9, $f7, $c9, $f7, $c9, $f7, $c9
	db $f7, $e9, $f7, $c9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $c9, $f7, $e9
	db $f7, $c9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $e9, $f7, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $fe, $ff, $fd, $ff, $fb, $fc, $f6, $ff, $f7, $fb, $ee, $fd, $ef, $fc, $f4
	db $ff, $f5, $fe, $ed, $fe, $df, $ee, $ff, $d6, $b4, $fb, $fa, $bd, $d7, $b8, $bf
	db $c0, $ee, $f1, $d9, $e7, $d7, $ee, $ef, $f0, $d9, $e6, $dd, $e2, $ef, $f0, $ef
	db $bf, $ef, $b8, $ed, $bb, $ec, $bb, $ee, $bd, $ef, $be, $ef, $bf, $ef, $bf, $ee
	db $bf, $ef, $be, $ef, $be, $ec, $bf, $ef, $bd, $ef, $bd, $ef, $b8, $ef, $bf, $ed
	db $be, $ef, $bc, $ee, $b9, $ef, $bb, $ef, $b8, $ef, $bb, $eb, $bc, $ef, $bf, $ef
	db $bd, $ee, $bd, $ed, $be, $ef, $bc, $ef, $be, $ef, $be, $eb, $bc, $ef, $bf, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $c8
	db $ff, $07, $ff, $bf, $c0, $be, $41, $7e, $89, $bb, $45, $bd, $43, $a7, $5f, $bd
	db $43, $bb, $45, $de, $29, $de, $21, $ef, $10, $f3, $0c, $3c, $f3, $9f, $7c, $7a
	db $fd, $c3, $bd, $ea, $55, $db, $e6, $fc, $03, $55, $aa, $aa, $ff, $fc, $03, $f7
	db $fd, $d7, $3d, $b7, $fd, $f7, $7d, $f7, $7d, $f7, $bd, $f7, $1d, $f7, $fd, $f7
	db $7d, $f7, $7d, $f7, $7d, $77, $bd, $77, $bd, $f7, $bd, $f7, $1d, $f7, $fd, $f7
	db $7d, $f7, $1d, $77, $dd, $f7, $dd, $f7, $1d, $f7, $dd, $d7, $3d, $f7, $fd, $f7
	db $fd, $77, $fd, $b7, $7d, $f7, $3d, $77, $fd, $77, $fd, $d7, $3d, $f7, $fd, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $13
	db $ff, $e0, $ff, $fd, $03, $7d, $82, $7e, $91, $dd, $a2, $bd, $c2, $e5, $fa, $bd
	db $c2, $dd, $a2, $7b, $94, $7b, $84, $f7, $08, $cf, $30, $3c, $cf, $f9, $3e, $5e
	db $bf, $c3, $bd, $57, $aa, $db, $67, $3f, $c0, $aa, $55, $55, $ff, $3f, $c0, $97
	db $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97
	db $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97
	db $ef, $97, $ef, $93, $ef, $97, $ef, $93, $ef, $93, $ef, $97, $ef, $93, $ef, $97
	db $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $97, $ef, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $7f, $ff, $bf, $ff, $df, $3f, $6f, $ff, $ef, $df, $77, $bf, $f7, $3f, $2f
	db $ff, $af, $7f, $b7, $7f, $fb, $77, $ff, $6b, $2d, $df, $5f, $bd, $eb, $1d, $fd
	db $03, $77, $8f, $9b, $e7, $eb, $77, $f7, $0f, $9b, $67, $bb, $47, $f7, $0f, $00
	db $00, $00, $00, $00, $01, $00, $03, $07, $0f, $0d, $2f, $2b, $7d, $7f, $7f, $fb
	db $7d, $fd, $76, $7e, $f7, $77, $ff, $f7, $ff, $f7, $ff, $f7, $ff, $ff, $ff, $00
	db $00, $40, $65, $ff, $ff, $ff, $ff, $91, $ef, $f7, $7f, $80, $7f, $df, $bf, $7f
	db $07, $0f, $ff, $ff, $ff, $ff, $ff, $8d, $f2, $ff, $ff, $00, $ff, $ff, $ff, $f1
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $f7, $08, $ff, $ff, $00, $ff, $ff, $ff, $78
	db $80, $7c, $9f, $bf, $df, $cb, $ff, $e8, $17, $fb, $fc, $17, $fe, $ff, $ff, $e0
	db $00, $a0, $40, $8c, $f0, $e2, $fc, $f1, $fe, $1c, $ff, $82, $7f, $f0, $8f, $48
	db $b7, $67, $f8, $f1, $ee, $bc, $ef, $be, $ef, $be, $ef, $bf, $ef, $af, $ff, $00
	db $00, $c6, $18, $ad, $35, $94, $52, $c8, $08, $1f, $00, $32, $32, $f7, $4a, $c8
	db $08, $6d, $1d, $32, $32, $f7, $4a, $e0, $2c, $8c, $31, $52, $4a, $39, $67, $e0
	db $2c, $42, $3d, $a5, $4d, $08, $5e, $ad, $35, $94, $52, $b9, $46, $60, $1c, $00
	db $00, $31, $46, $00, $44, $20, $02, $00, $00, $31, $46, $00, $44, $20, $02, $00
	db $00, $5f, $4b, $6f, $11, $c0, $1c, $00, $00, $e0, $68, $1f, $00, $e0, $7e, $00
	db $00, $42, $3d, $a5, $4d, $08, $5e, $00, $00, $00, $00, $00, $00, $c8, $08, $00
	db $00, $e7, $1c, $00, $1c, $e0, $00, $00, $00, $a5, $14, $00, $14, $a0, $00, $00
	db $00, $63, $0c, $00, $0c, $60, $00, $00, $00, $21, $04, $00, $04, $20, $00, $00
	db $00, $c6, $18, $ad, $35, $94, $52, $c8, $08, $1f, $00, $32, $32, $f7, $4a, $c8
	db $08, $6d, $1d, $32, $32, $f7, $4a, $c6, $18, $ad, $35, $94, $52, $b9, $46, $60
	db $1c, $2a, $35, $14, $4e, $ff, $3a, $ad, $35, $94, $52, $b9, $46, $60, $1c, $00
	db $00, $31, $46, $00, $44, $20, $02, $00, $00, $31, $46, $00, $44, $20, $02, $00
	db $00, $5f, $4b, $6f, $11, $c0, $1c, $00, $00, $e0, $68, $1f, $00, $e0, $7e, $00
	db $00, $da, $00, $db, $01, $fd, $02, $00, $00, $00, $00, $00, $00, $c8, $08, $00
	db $00, $e7, $1c, $00, $1c, $e0, $00, $00, $00, $a5, $14, $00, $14, $a0, $00, $00
	db $00, $63, $0c, $00, $0c, $60, $00, $00, $00, $21, $04, $00, $04, $20, $00, $0b
	db $0b, $7f, $71, $06, $71, $80, $8a, $94, $9d, $a6, $af, $b8, $c1, $ca, $d3, $dc
	db $81, $8b, $95, $9e, $a7, $b0, $b9, $c2, $cb, $d4, $ee, $82, $8c, $96, $9f, $a8
	db $b1, $ba, $c3, $cc, $ee, $f3, $83, $8d, $97, $a0, $a9, $b2, $bb, $8d, $ee, $fc
	db $de, $84, $8e, $98, $a1, $aa, $aa, $a1, $ee, $fd, $d6, $df, $85, $8f, $99, $da
	db $a9, $b2, $ee, $fe, $ce, $d7, $e0, $f8, $ef, $f5, $f6, $f7, $f5, $ff, $c6, $cf
	db $d8, $e1, $86, $ee, $fa, $f9, $ab, $b4, $be, $c7, $d0, $d9, $e2, $87, $f4, $ee
	db $da, $ac, $b5, $bf, $c8, $d1, $da, $e3, $88, $92, $fb, $ee, $ad, $ad, $db, $8d
	db $d2, $db, $e4, $89, $93, $9c, $f9, $ee, $b7, $d9, $c7, $d0, $d9, $e5, $0b, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $0c, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0c, $0b, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0c, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $2b
	db $0b, $0c, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0c, $0b, $0b, $0b, $0b
	db $0c, $0c, $0c, $0c, $0c, $0c, $0b, $0b, $0b, $0b, $0b, $0b, $2c, $0b, $0b, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $2c, $0b, $0b, $0b, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $0b, $2c, $0b, $2b, $2b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b
	db $2c, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $77, $72, $fe, $71, $9f, $99, $93
	db $8d, $88, $83, $80, $a6, $a5, $a6, $d1, $a0, $9a, $94, $8e, $89, $84, $81, $a6
	db $a6, $d2, $b1, $a1, $9b, $95, $8f, $8a, $85, $82, $a6, $d3, $b8, $b2, $a2, $9c
	db $96, $90, $8b, $86, $a6, $d4, $be, $b9, $b3, $a3, $9d, $97, $91, $8c, $87, $d5
	db $c3, $bf, $ba, $b4, $a4, $9e, $98, $92, $a6, $d6, $c7, $c4, $c0, $bb, $b5, $a6
	db $a6, $a6, $a6, $d7, $ca, $c8, $c5, $c1, $bc, $b6, $d0, $cf, $ce, $cd, $cc, $c9
	db $c9, $c6, $c2, $bd, $b7, $b4, $d0, $be, $d7, $a6, $a6, $a6, $a6, $a6, $a6, $a6
	db $b5, $bb, $d0, $be, $d6, $a6, $af, $ad, $ab, $a9, $a7, $b6, $bc, $c6, $d0, $be
	db $d5, $b0, $ae, $ac, $aa, $a8, $2c, $2c, $2c, $2c, $2c, $2c, $2c, $2c, $2c, $2c
	db $2d, $2c, $2c, $2c, $2c, $2c, $2c, $2c, $2c, $2c, $2d, $2b, $2c, $2c, $2c, $2c
	db $2c, $2c, $2c, $2c, $2d, $2b, $2b, $2c, $2c, $2c, $2c, $2c, $2c, $2c, $2d, $2b
	db $2b, $2b, $2c, $2c, $2c, $2c, $2c, $2c, $2d, $2b, $2b, $2b, $2b, $2c, $2c, $2c
	db $2c, $2c, $2d, $2b, $2b, $2b, $2b, $2b, $2c, $2c, $2c, $2c, $2d, $2b, $2b, $2b
	db $2b, $2b, $2b, $2b, $2b, $2b, $2b, $2b, $2b, $2b, $2b, $2b, $2b, $2b, $0b, $2b
	db $0b, $0d, $2c, $2c, $2c, $2c, $2c, $2c, $2c, $0b, $0b, $2b, $0b, $0d, $2c, $2c
	db $2c, $2c, $2c, $2c, $0b, $0b, $0b, $2b, $0b, $0d, $2c, $2c, $2c, $2c, $2c

; ($26:$7000 BG/OBJ palettes carved into the screen asset as TowerOpenPalettes.)

SECTION "analyzed_09b356", ROMX[$7356], BANK[$26]

Data_26_7356:
	db $14, $28, $20, $34, $01, $28, $78, $38, $01, $38, $18, $30, $01, $38, $20, $36
	db $01, $38, $78, $3a, $01, $38, $80, $3c, $01, $48, $18, $32, $01, $48, $80, $3e
	db $01, $58, $00, $00, $02, $58, $08, $02, $02, $58, $90, $24, $02, $58, $98, $26
	db $02, $60, $30, $0c, $02, $60, $38, $0e, $02, $60, $40, $10, $02, $60, $48, $12
	db $02, $60, $50, $14, $02, $60, $58, $16, $02, $60, $60, $18, $02, $60, $68, $1a
	db $02, $08, $0a, $fd, $73, $ad, $73, $c8, $b8, $c0, $c8, $d0, $d8, $e0, $e8, $f0
	db $f0, $c9, $b9, $c1, $c9, $d1, $d9, $e1, $e9, $f1, $f1, $ca, $ba, $c2, $ca, $d2
	db $da, $e2, $ea, $f2, $f2, $cb, $bb, $c3, $cb, $d3, $db, $e3, $eb, $f3, $f3, $cc
	db $bc, $c4, $cc, $d4, $dc, $e4, $ec, $f4, $f4, $cd, $bd, $c5, $cd, $d5, $dd, $e5
	db $ed, $f5, $f5, $ce, $be, $c6, $ce, $d6, $de, $e6, $ee, $f6, $f6, $0c, $bf, $c7
	db $cf, $d7, $df, $e7, $ef, $f7, $0d, $04, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $04, $04, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $04, $04, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $04, $04, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $04, $04
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $04, $04, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $04, $04, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $04, $0b, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0b, $08, $0a, $a3, $74, $53, $74, $88, $90, $98
	db $a0, $35, $35, $a8, $b0, $b8, $c0, $89, $91, $99, $a1, $36, $36, $a9, $b1, $b9
	db $c1, $8a, $92, $9a, $a2, $34, $34, $aa, $b2, $ba, $c2, $8b, $93, $9b, $a3, $34
	db $34, $ab, $b3, $bb, $c3, $8c, $94, $9c, $a4, $34, $34, $ac, $b4, $bc, $c4, $8d
	db $95, $9d, $a5, $34, $34, $ad, $b5, $bd, $c5, $8e, $96, $9e, $a6, $34, $34, $ae
	db $b6, $be, $c6, $0c, $97, $9f, $a7, $37, $37, $af, $b7, $bf, $0d, $04, $04, $04
	db $04, $2c, $0c, $04, $04, $04, $04, $04, $04, $04, $04, $2c, $0c, $04, $04, $04
	db $04, $04, $04, $04, $04, $0c, $0c, $04, $04, $04, $04, $04, $04, $04, $04, $0c
	db $0c, $04, $04, $04, $04, $04, $04, $04, $04, $0c, $0c, $04, $04, $04, $04, $04
	db $04, $04, $04, $0c, $0c, $04, $04, $04, $04, $04, $04, $04, $04, $0c, $0c, $04
	db $04, $04, $04, $0b, $04, $04, $04, $0c, $0c, $04, $04, $04, $0b, $08, $0a, $49
	db $75, $f9, $74, $38, $40, $48, $50, $58, $60, $68, $70, $78, $80, $39, $41, $49
	db $51, $59, $61, $69, $71, $79, $81, $3a, $42, $4a, $52, $5a, $62, $6a, $72, $7a
	db $82, $3b, $43, $4b, $53, $5b, $63, $6b, $73, $7b, $83, $3c, $44, $4c, $54, $5c
	db $64, $6c, $74, $7c, $84, $3d, $45, $4d, $55, $5d, $65, $6d, $75, $7d, $85, $3e
	db $46, $4e, $56, $5e, $66, $6e, $76, $7e, $86, $0c, $47, $4f, $57, $5f, $67, $6f
	db $77, $7f, $0d, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $04, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $04, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c
	db $04, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $04, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0c, $0c, $04, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $04, $0c
	db $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $04, $0b, $0c, $0c, $0c, $0c, $0c, $0c
	db $0c, $0c, $0b, $02, $08, $10, $44, $00, $08, $38, $44, $20, $02, $00, $18, $2c
	db $00, $00, $30, $2c, $20, $02, $00, $18, $28, $00, $00, $30, $28, $20, $05, $03
	db $c9, $75, $ba, $75, $a8, $aa, $ac, $a9, $ab, $ad, $92, $9a, $a2, $93, $9b, $a3
	db $94, $9c, $a4, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $05, $03, $ed, $75, $de, $75, $9d, $9f, $a6, $9e, $a5, $a7, $92, $9a
	db $a2, $93, $9b, $a3, $94, $9c, $a4, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $05, $03, $11, $76, $02, $76, $90, $98, $a0, $91
	db $99, $a1, $92, $9a, $a2, $93, $9b, $a3, $94, $9c, $a4, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $05, $03, $35, $76, $26, $76
	db $f8, $80, $88, $f9, $81, $89, $fa, $82, $8a, $fb, $83, $8b, $fc, $84, $8c, $05
	db $0d, $0d, $05, $0d, $0d, $05, $0d, $0d, $05, $0d, $0d, $05, $0d, $0d, $05, $03
	db $59, $76, $4a, $76, $f8, $80, $88, $fd, $85, $89, $fe, $86, $8a, $ff, $87, $8b
	db $fc, $84, $8c, $05, $0d, $0d, $05, $0d, $0d, $05, $0d, $0d, $05, $0d, $0d, $05
	db $0d, $0d, $05, $03, $7d, $76, $6e, $76, $f8, $80, $88, $8d, $95, $89, $8e, $96
	db $8a, $8f, $97, $8b, $fc, $84, $8c, $05, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $05, $0d, $0d, $a7, $73, $4d, $74, $f3, $74

Data_26_7692:
	db $a7, $73

Data_26_7694:
	db $99, $75, $a2, $75, $ab, $75, $b4, $75, $d8, $75, $fc, $75, $d8, $75, $b4, $75
	db $d8, $75, $fc, $75, $d8, $75, $20, $76, $44, $76, $68, $76, $44, $76, $20, $76
	db $44, $76, $68, $76, $44, $76

; ($28:$7000 BG/OBJ palettes carved into the screen asset as TitlePalettes.)

SECTION "analyzed_0a3356", ROMX[$7356], BANK[$28]

Data_28_7356:
	db $02, $08, $6c, $73, $5c, $73, $a8, $b0, $f8, $b8, $c0, $c8, $d0, $d8, $a9, $b1
	db $f8, $b9, $c1, $c9, $d1, $d9, $07, $07, $07, $07, $07, $07, $07, $07, $07, $07
	db $07, $07, $07, $07, $07, $07, $02, $08, $92, $73, $82, $73, $e0, $e8, $f0, $f8
	db $e2, $ea, $f2, $fa, $e1, $e9, $f1, $f9, $e3, $eb, $f3, $fb, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $09, $ba, $73
	db $a8, $73, $e4, $ec, $f4, $fc, $f8, $e6, $ee, $f6, $fe, $e5, $ed, $f5, $fd, $f9
	db $e7, $ef, $f7, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00

Data_28_73cc:
	db $03, $12, $08, $74, $d2, $73, $3a, $42, $4a, $52, $5a, $62, $6a, $72, $7a, $3d
	db $45, $4d, $55, $5d, $65, $6d, $75, $7d, $3b, $43, $4b, $53, $5b, $63, $6b, $73
	db $7b, $3e, $46, $4e, $56, $5e, $66, $6e, $76, $7e, $3c, $44, $4c, $54, $5c, $64
	db $6c, $74, $7c, $3f, $47, $4f, $57, $5f, $67, $6f, $77, $7f, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e, $0e
	db $0e, $0e

Data_28_743e:
	db $02, $00, $00, $36, $02, $00, $08, $3e, $02, $02, $00, $00, $46, $02, $00, $08
	db $4e, $02, $02, $00, $00, $56, $02, $00, $08, $5e, $02, $02, $00, $00, $66, $02
	db $00, $08, $6e, $02

Data_28_7462:
	db $06, $00, $00, $28, $00, $00, $08, $30, $00, $00, $10, $38, $00, $10, $00, $2a
	db $00, $10, $08, $32, $00, $10, $10, $3a, $00, $06, $00, $00, $40, $00, $00, $08
	db $48, $00, $00, $10, $50, $00, $10, $00, $42, $00, $10, $08, $4a, $00, $10, $10
	db $52, $00, $06, $00, $00, $58, $00, $00, $08, $60, $00, $00, $10, $68, $00, $10
	db $00, $5a, $00, $10, $08, $62, $00, $10, $10, $6a, $00, $06, $00, $00, $70, $00
	db $00, $08, $78, $00, $00, $10, $00, $08, $10, $00, $72, $00, $10, $08, $7a, $00
	db $10, $10, $02, $08

Data_28_74c6:
	db $1e, $08, $58, $08, $01, $08, $60, $10, $01, $08, $68, $18, $01, $18, $28, $82
	db $01, $18, $30, $8a, $01, $18, $38, $92, $01, $18, $40, $9a, $01, $18, $48, $a2
	db $01, $18, $50, $02, $01, $18, $58, $0a, $01, $18, $68, $1a, $01, $18, $70, $22
	db $01, $28, $28, $84, $01, $28, $30, $8c, $01, $28, $38, $94, $01, $28, $40, $9c
	db $01, $28, $48, $a4, $01, $28, $50, $04, $01, $28, $58, $0c, $01, $28, $60, $14
	db $01, $28, $68, $1c, $01, $28, $70, $24, $01, $38, $30, $8e, $01, $38, $38, $96
	db $01, $38, $40, $9e, $01, $38, $48, $a6, $01, $38, $50, $06, $01, $38, $58, $0e
	db $01, $38, $60, $16, $01, $38, $68, $1e, $01, $3e, $74, $47, $74, $50, $74, $59
	db $74

Data_28_7547:
	db $62, $74, $7b, $74, $94, $74, $ad, $74

; ($29:$7000 BG/OBJ palettes carved into the screen asset as IntroBookPalettes.)

SECTION "analyzed_0a7216", ROMX[$7216], BANK[$29]

Data_29_7216:
	db $0a, $14, $e4, $72, $1c, $72, $fc, $fc, $fc, $08, $0f, $17, $1f, $28, $31, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $02, $09, $10, $18
	db $20, $29, $32, $3b, $48, $50, $58, $60, $68, $70, $78, $70, $78, $fc, $fc, $fc
	db $03, $0a, $11, $19, $21, $2a, $33, $3c, $44, $51, $59, $61, $69, $71, $79, $70
	db $78, $fc, $fc, $fc, $04, $0b, $12, $1a, $22, $2b, $34, $3d, $45, $52, $5a, $62
	db $6a, $72, $7a, $70, $78, $fc, $fc, $00, $05, $0c, $13, $1b, $23, $2c, $35, $3e
	db $4b, $53, $5b, $63, $6b, $73, $7b, $0b, $70, $78, $fc, $01, $06, $0d, $14, $1c
	db $24, $2d, $36, $3f, $4c, $54, $5c, $64, $6c, $74, $7c, $0c, $70, $78, $fc, $fc
	db $07, $0e, $15, $1d, $25, $2e, $37, $40, $4d, $55, $5d, $65, $6d, $75, $7d, $0d
	db $70, $78, $fc, $fc, $fc, $fc, $16, $1e, $26, $2f, $38, $41, $46, $56, $5e, $66
	db $6e, $76, $7e, $0e, $06, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $27, $30, $39, $42
	db $4f, $57, $5f, $67, $6f, $77, $7f, $0f, $07, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $3a, $43, $0a, $09, $08, $05, $04, $03, $02, $01, $00, $fc, $08, $08
	db $08, $0a, $09, $09, $0a, $0a, $0a, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $0a, $09, $09, $09, $09, $09, $0a, $0a, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $08, $08, $08, $0a, $09, $09, $09, $09, $09, $09, $0a
	db $0a, $01, $01, $01, $01, $02, $02, $02, $02, $08, $08, $08, $0a, $09, $09, $09
	db $0a, $09, $09, $09, $0a, $01, $01, $01, $01, $01, $02, $02, $02, $08, $08, $0b
	db $09, $09, $09, $09, $0a, $09, $09, $09, $01, $01, $01, $01, $01, $01, $02, $22
	db $02, $02, $08, $0b, $09, $09, $09, $09, $0a, $09, $09, $09, $01, $01, $01, $01
	db $01, $01, $01, $22, $02, $02, $08, $08, $0b, $0b, $0b, $09, $0a, $09, $09, $09
	db $01, $01, $01, $01, $01, $01, $01, $22, $02, $02, $08, $08, $08, $08, $0b, $0b
	db $0b, $09, $09, $09, $0a, $01, $01, $01, $01, $01, $01, $22, $22, $08, $08, $08
	db $08, $08, $08, $08, $0b, $0b, $0b, $09, $01, $01, $01, $01, $01, $01, $01, $21
	db $22, $08, $08, $08, $08, $08, $08, $08, $08, $08, $0b, $0b, $21, $21, $21, $21
	db $21, $21, $21, $21, $23, $08

Data_29_73ac:
	db $0a, $14

Data_29_73ae:
	db $7a, $74, $b2, $73

Data_29_73b2:
	db $fc, $fc, $fc, $fc, $fc, $fc, $47, $4b, $53, $5c, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $48, $4c, $54, $5d, $48, $50
	db $58, $60, $68, $70, $78, $78, $78, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $49, $4d
	db $55, $5e, $66, $51, $59, $61, $69, $71, $79, $78, $78, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $4a, $4e, $56, $5f, $67, $52, $5a, $62, $6a, $72, $7a, $78, $78, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $4f, $57, $60, $68, $53, $5b, $63, $6b, $73
	db $7b, $0b, $78, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $50, $58, $61, $69, $54
	db $5c, $64, $6c, $74, $7c, $0c, $78, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $51
	db $59, $62, $6a, $55, $5d, $65, $6d, $75, $7d, $0d, $78, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $52, $5a, $63, $6b, $56, $5e, $66, $6e, $76, $7e, $0e, $06, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $5b, $64, $6c, $57, $5f, $67, $6f, $77
	db $7f, $0f, $07, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $65, $6d, $09
	db $08, $05, $04, $03, $02, $01, $00, $fc, $08, $08, $08, $08, $08, $08, $0a, $09
	db $09, $09, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $0a, $09, $09, $09, $02, $02, $02, $02, $02, $02, $02, $02, $02, $08
	db $08, $08, $08, $08, $08, $08, $0b, $09, $09, $09, $09, $01, $01, $01, $01, $02
	db $02, $02, $02, $08, $08, $08, $08, $08, $08, $08, $0b, $09, $09, $09, $09, $01
	db $01, $01, $01, $01, $02, $02, $02, $08, $08, $08, $08, $08, $08, $08, $08, $0b
	db $09, $09, $09, $01, $01, $01, $01, $01, $02, $22, $02, $08, $08, $08, $08, $08
	db $08, $08, $08, $0b, $09, $09, $09, $01, $01, $01, $01, $01, $01, $22, $02, $08
	db $08, $08, $08, $08, $08, $08, $08, $0b, $09, $09, $09, $01, $01, $01, $01, $01
	db $01, $22, $02, $08, $08, $08, $08, $08, $08, $08, $08, $0a, $0b, $09, $09, $01
	db $01, $01, $01, $01, $01, $22, $22, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $0b, $09, $09, $01, $01, $01, $01, $01, $01, $21, $22, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $0b, $0b, $21, $21, $21, $21, $21, $21, $21, $23, $08
	db $0a, $14

Data_29_7544:
	db $10, $76, $48, $75

Data_29_7548:
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $6f, $79, $83, $8d, $97, $a1
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $70, $7a
	db $84, $8e, $98, $a2, $78, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $6e, $71, $7b, $85, $8f, $99, $a3, $ab, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $6e, $72, $7c, $86, $90, $9a, $a4, $ac, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $6e, $73, $7d, $87, $91, $9b, $a5
	db $ad, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $6e, $74, $7e
	db $88, $92, $9c, $a6, $ae, $b3, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $6e, $75, $7f, $89, $93, $9d, $a7, $af, $b4, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $76, $80, $8a, $94, $9e, $a8, $b0, $b5, $b8, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $77, $81, $8b, $95, $9f, $a9
	db $b1, $b6, $b9, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $78, $82
	db $8c, $96, $a0, $aa, $b2, $b7, $ba, $fc, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $0b, $0b, $03, $03, $01, $02, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $0b, $0b, $03, $03, $01, $02, $02, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $0b, $0b, $0b, $03, $03, $01, $02
	db $02, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $0b, $0b, $0b
	db $03, $03, $01, $01, $02, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $0b, $0b, $0b, $03, $01, $01, $01, $02, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $0b, $0b, $0b, $01, $01, $01, $01, $01, $02, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $0b, $0b, $09, $01, $01, $01, $01
	db $01, $02, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $0b, $01
	db $01, $03, $03, $01, $01, $02, $02, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $0b, $03, $03, $03, $03, $01, $01, $01, $02, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $0b, $03, $03, $03, $03, $03, $03, $01, $01, $08
	db $0a, $14

Data_29_76da:
	db $a6, $77, $de, $76

Data_29_76de:
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $78, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $bb, $c0, $c8, $d0, $d8, $e0, $e8, $f0, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $bc, $c1, $c9, $d1, $d9, $e1, $e9, $f1, $f7, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $bd, $c2, $ca, $d2, $da, $e2, $ea
	db $f2, $f8, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $be, $c3, $cb
	db $d3, $db, $e3, $eb, $cb, $f9, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $bf, $c4, $cc, $d4, $dc, $e4, $ec, $f3, $fa, $f7, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $c5, $cd, $d5, $dd, $e5, $ed, $f4, $fb, $fe, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $c6, $ce, $d6, $de, $e6, $e6
	db $f5, $fc, $ff, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $c7, $cf
	db $d7, $df, $e7, $ef, $f6, $fd, $ee, $fc, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $02, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $03, $01, $01, $01, $01, $01, $01
	db $03, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $03, $01, $01
	db $01, $01, $01, $01, $01, $03, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $03, $01, $01, $01, $01, $01, $01, $01, $03, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $03, $01, $01, $01, $01, $01, $01, $01, $03, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $03, $01, $01, $01, $01, $01, $01
	db $01, $03, $03, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $01, $01
	db $01, $01, $01, $01, $01, $01, $03, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $01, $01, $01, $01, $01, $01, $01, $01, $03, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $03, $03, $03, $03, $03, $03, $01, $01, $03, $08

Data_29_786e:
	db $0a, $14, $3c, $79, $74, $78, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $78, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $bb, $c0, $c8, $d0, $d8, $e0, $e8, $f0, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $bc, $c1, $c9, $d1, $d9
	db $e1, $e9, $f1, $f7, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $bd
	db $c2, $ca, $d2, $da, $e2, $ea, $f2, $f8, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $be, $c3, $cb, $d3, $db, $e3, $eb, $cb, $f9, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $fc, $fc, $fc, $bf, $c4, $cc, $d4, $dc, $e4, $ec, $f3, $fa
	db $f7, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $c5, $cd, $d5, $dd
	db $e5, $ed, $f4, $fb, $fe, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $c6, $ce, $d6, $de, $e6, $e6, $f5, $fc, $ff, $fc, $fc, $fc, $fc, $fc, $fc, $fc
	db $fc, $fc, $fc, $fc, $c7, $cf, $d7, $df, $e7, $ef, $f6, $fd, $ee, $fc, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $02, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $03
	db $01, $01, $01, $01, $01, $01, $03, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $03, $01, $01, $01, $01, $01, $01, $01, $03, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $03, $01, $01, $01, $01, $01, $01, $01, $03
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $03, $01, $01, $01, $01
	db $01, $01, $01, $03, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $03
	db $01, $01, $01, $01, $01, $01, $01, $03, $03, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $01, $01, $01, $01, $01, $01, $01, $01, $03, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $01, $01, $01, $01, $01, $01, $01, $01
	db $03, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $03, $03, $03, $03
	db $03, $03, $01, $01, $03, $08

Data_29_7a04:
	db $1e, $30, $28, $00, $01, $30, $30, $08, $01, $30, $38, $10, $01, $30, $40, $18
	db $01, $30, $48, $20, $01, $30, $50, $28, $01, $30, $58, $30, $01, $30, $60, $38
	db $00, $30, $68, $40, $01, $30, $70, $48, $01, $40, $28, $02, $01, $40, $30, $0a
	db $01, $40, $38, $12, $01, $40, $40, $1a, $01, $40, $48, $22, $01, $40, $50, $2a
	db $01, $40, $58, $32, $01, $40, $60, $3a, $01, $40, $68, $42, $01, $40, $70, $4a
	db $01, $50, $28, $04, $01, $50, $30, $0c, $01, $50, $38, $14, $01, $50, $40, $1c
	db $01, $50, $48, $24, $01, $50, $50, $2c, $01, $50, $58, $34, $01, $50, $60, $3c
	db $01, $50, $68, $44, $01, $50, $70, $4c, $01, $04, $00, $00, $80, $00, $00, $08
	db $88, $00, $00, $10, $90, $00, $00, $18, $98, $00

Data_29_7a8e:
	db $03, $00, $00, $82, $00, $00, $08, $8a, $00, $00, $10, $92, $00, $02, $00, $00
	db $84, $00, $00, $08, $8c, $00

Data_29_7aa4:
	db $04, $00, $00, $a0, $00, $00, $08, $a8, $00, $00, $10, $b0, $00, $00, $18, $b8
	db $00, $03, $00, $00, $a2, $00, $00, $08, $aa, $00, $00, $10, $b2, $00, $02, $00
	db $00, $a4, $00, $00, $08, $ac, $00, $20, $20, $48, $20, $00, $20, $50, $28, $00
	db $30, $48, $22, $00, $30, $50, $2a, $00, $38, $28, $00, $01, $38, $30, $08, $01
	db $38, $38, $10, $01, $38, $40, $18, $01, $38, $58, $30, $01, $38, $60, $38, $01
	db $38, $68, $40, $01, $38, $70, $48, $01, $40, $48, $24, $00, $40, $50, $2c, $00
	db $48, $28, $02, $01, $48, $30, $0a, $01, $48, $38, $12, $01, $48, $40, $1a, $01
	db $48, $58, $32, $01, $48, $60, $3a, $01, $48, $68, $42, $01, $48, $70, $4a, $01
	db $50, $48, $26, $00, $50, $50, $2e, $00, $58, $28, $04, $01, $58, $30, $0c, $01
	db $58, $38, $14, $01, $58, $40, $1c, $01, $58, $58, $34, $01, $58, $60, $3c, $01
	db $58, $68, $44, $01, $58, $70, $4c, $01

SECTION "analyzed_0a8000", ROMX[$4000], BANK[$2a]

Data_2a_4000:
	INCBIN "raw_gfx/Data_2a_4000.2bpp", 0, 5120

Data_2a_5400:
	db $00, $00, $bd, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

Data_2a_5410:
	INCBIN "raw_gfx/Data_2a_5410.2bpp", 0, 2048

Data_2a_5c10:
	db $00, $00, $ce, $39, $d6, $5a, $ff, $7f, $00, $00, $c0, $2c, $00, $00, $d6, $5a
	db $3f, $7f, $3f, $7f, $3f, $3f, $1f, $3f, $1f, $3f, $1f, $3f, $1f, $3f, $1f, $3f
	db $3f, $1f, $2f, $1f, $17, $2f, $17, $2f, $0f, $37, $0f, $37, $0f, $17, $07, $1b
	db $03, $1f, $03, $1f, $03, $1f, $07, $1f, $17, $0f, $13, $0f, $1b, $07, $1b, $07
	db $1b, $07, $0d, $03, $0d, $03, $0d, $03, $0e, $01, $0e, $01, $0e, $01, $0c, $03
	db $0e, $01, $0f, $00, $0d, $02, $0d, $02, $0c, $03, $08, $07, $08, $07, $08, $07
	db $08, $17, $00, $1f, $02, $1d, $24, $1b, $24, $1b, $2d, $13, $6b, $17, $6b, $17
	db $76, $0f, $5d, $3f, $4e, $35, $7c, $03, $3f, $00, $1f, $00, $07, $00, $01, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $80, $7f
	db $00, $ff, $07, $f8, $1f, $ff, $7f, $ff, $ff, $ff, $eb, $f4, $bf, $ff, $7f, $f0
	db $5f, $ff, $3f, $c0, $40, $ff, $fc, $03, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ef, $f0, $ef, $f0, $e7, $f8, $e7, $f8, $e7, $f8, $e7, $f8, $e7, $f8, $e7, $f8
	db $f7, $f8, $f7, $f8, $f7, $f8, $f7, $f8, $ff, $f8, $fb, $fc, $fb, $fc, $f9, $fe
	db $f9, $fe, $f9, $fe, $f9, $fe, $fd, $fe, $fd, $fe, $fc, $ff, $fc, $ff, $fc, $ff
	db $fc, $ff, $fe, $ff, $fe, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $ff, $ff
	db $00, $ff, $01, $fe, $01, $fe, $01, $fe, $02, $fd, $02, $fd, $02, $fd, $00, $ff
	db $00, $ff, $e0, $1f, $f8, $ff, $fe, $ff, $ff, $ff, $ef, $1f, $fb, $ff, $3d, $cf
	db $e6, $ff, $fd, $03, $00, $ff, $07, $f8, $ff, $00, $ff, $00, $ff, $00, $f0, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $80, $40, $80, $40, $00, $c0, $00, $c0, $00, $c0, $00, $c0, $00, $c0, $00, $c0
	db $00, $80, $00, $80, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00
	db $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00
	db $80, $00, $00, $80, $00, $80, $01, $80, $01, $c0, $01, $c0, $01, $c0, $81, $40
	db $c1, $00, $c1, $00, $c3, $00, $c7, $00, $e7, $00, $7f, $80, $3f, $c0, $3f, $c0
	db $3e, $c0, $1c, $e0, $1c, $e0, $1c, $e0, $1c, $e0, $18, $e0, $88, $f0, $88, $f0
	db $ec, $d0, $f0, $60, $60, $a0, $20, $c0, $e0, $00, $c0, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $8f, $7f, $cf, $3f, $cf, $3f, $c7, $3f, $c7, $3f, $e7, $1f, $67, $9f, $77, $8f
	db $77, $8f, $77, $0f, $77, $0f, $77, $0f, $67, $1f, $67, $1f, $67, $1f, $67, $1f
	db $6f, $1f, $7f, $0f, $7f, $0f, $7f, $0f, $7f, $0f, $7f, $0f, $7f, $0f, $57, $2f
	db $7f, $07, $ff, $07, $ff, $07, $ff, $07, $ff, $07, $ff, $07, $ff, $07, $ff, $00
	db $ff, $00, $cf, $3f, $c7, $3f, $e7, $1f, $fb, $07, $ff, $00, $ff, $00, $fe, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $7e, $81, $02, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $fe, $01, $f0, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $f8, $fc, $f8, $fc, $f0, $f8, $f0, $f8, $f0, $f8, $f8, $f0, $f8, $f0, $e0, $f0
	db $e0, $f0, $f0, $e0, $f0, $e0, $f0, $e0, $f0, $e0, $f0, $e0, $f0, $e0, $e0, $e0
	db $e0, $e0, $e0, $e0, $e0, $c0, $e0, $c0, $e0, $c0, $e0, $c0, $e0, $80, $e0, $80
	db $e0, $a0, $e0, $a0, $f0, $b0, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $b0, $f0, $b0
	db $90, $78, $70, $f8, $e0, $f8, $e0, $f0, $80, $e0, $00, $80, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $1f, $3f, $1f, $3f, $1f, $1f, $0f, $1f, $0f, $1f, $0f, $1f, $0f, $1f, $0f, $1f
	db $1f, $0f, $17, $0f, $0f, $17, $0f, $17, $0f, $17, $07, $1f, $03, $0f, $07, $0b
	db $07, $0b, $07, $0b, $03, $0f, $0b, $07, $0b, $07, $0b, $07, $0b, $07, $09, $07
	db $09, $07, $05, $03, $05, $03, $07, $01, $07, $01, $07, $01, $01, $07, $03, $07
	db $00, $07, $00, $07, $00, $07, $00, $07, $00, $07, $01, $06, $01, $07, $03, $0d
	db $02, $0d, $02, $0d, $02, $0f, $02, $0f, $02, $0f, $05, $0f, $05, $0f, $04, $1f
	db $05, $1f, $0d, $1f, $3f, $0f, $3e, $01, $1f, $00, $0f, $00, $03, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $fe, $ff, $f3, $fc, $fd, $fe, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $03, $fc, $1f, $ef, $7f, $bf, $f0, $7f, $cf, $ff, $a0, $ff, $bf, $ff, $40, $ff
	db $7f, $ff, $c0, $ff, $ff, $ff, $0f, $f0, $e0, $ff, $9f, $e0, $f8, $ff, $1f, $e0
	db $ff, $ff, $03, $fc, $f8, $ff, $0f, $f0, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $df, $e0, $df, $e0, $ce, $f1, $ce, $f1, $ce, $f1, $ce, $f1, $ce, $f1, $ce, $f1
	db $ee, $f1, $ee, $f1, $ef, $f0, $ef, $f0, $ff, $f0, $f7, $f8, $f7, $f8, $f7, $f8
	db $f7, $f8, $f7, $f8, $f7, $f8, $f7, $f8, $77, $f8, $a7, $78, $c7, $38, $ef, $f0
	db $e7, $f8, $f3, $fc, $f1, $fe, $f9, $fe, $f8, $ff, $f8, $ff, $f8, $ff, $fd, $fe
	db $c1, $3e, $e1, $fe, $f9, $f6, $3f, $f8, $cb, $fc, $2f, $fc, $f7, $fc, $75, $8e
	db $fb, $fe, $fb, $06, $fc, $ff, $fe, $01, $3f, $c1, $ff, $01, $00, $ff, $ff, $00
	db $e0, $ff, $ff, $00, $00, $ff, $fe, $01, $ff, $00, $ff, $00, $fe, $00, $e0, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $00
	db $80, $00, $80, $00, $80, $01, $80, $01, $c0, $01, $f9, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $5f, $a0, $5e, $a0
	db $dc, $a0, $a0, $c0, $80, $40, $40, $80, $c0, $00, $80, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $8f, $7f, $8f, $7f, $8f, $7f, $cf, $3f, $cf, $3f, $cf, $3f, $cf, $3f, $8f, $7f
	db $cf, $3f, $cf, $3f, $cf, $3f, $cf, $3f, $e7, $1f, $67, $9f, $77, $8f, $77, $8f
	db $77, $0f, $77, $0f, $77, $0f, $67, $1f, $67, $1f, $67, $1f, $67, $1f, $6f, $1f
	db $7f, $0f, $7f, $0f, $7f, $0f, $7f, $0f, $7f, $4f, $7f, $0f, $57, $2f, $7f, $07
	db $78, $87, $38, $c7, $78, $87, $78, $87, $f8, $07, $7c, $83, $3e, $c1, $7e, $81
	db $f9, $3e, $df, $3f, $e7, $1f, $fb, $07, $ff, $00, $80, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $03, $fc, $7b, $87, $ff, $ff, $ff, $ff, $fe, $01, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $f8, $fc, $f8, $fc, $f8, $fc, $f8, $fc, $f8, $fc, $f8, $fc, $f8, $fc, $f8, $f8
	db $f0, $f8, $f0, $f8, $f0, $f8, $f0, $f8, $f0, $f8, $f0, $f8, $f0, $f8, $f0, $f8
	db $f0, $f8, $f8, $f8, $f0, $f0, $f0, $f0, $f0, $f0, $e0, $f0, $e0, $f0, $e0, $f0
	db $e0, $e0, $e0, $e0, $c0, $e0, $c0, $e0, $c0, $e0, $c0, $a0, $c0, $a0, $e0, $a0
	db $40, $b0, $40, $b0, $40, $b0, $80, $70, $80, $70, $80, $70, $20, $d0, $d0, $38
	db $70, $f8, $e0, $f8, $e0, $f0, $80, $c0, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $01, $00, $01, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $01, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $01, $07, $01, $07, $01, $07, $03, $07, $03, $07, $07, $07, $01, $03, $00, $03
	db $02, $01, $03, $00, $03, $00, $03, $00, $02, $01, $02, $01, $02, $01, $02, $01
	db $00, $01, $00, $01, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $01, $00, $01, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $00, $0f, $00, $1f, $c0, $3f
	db $c0, $3f, $e0, $3f, $d0, $3f, $f0, $1f, $e8, $1f, $fc, $0b, $f6, $0d, $ff, $06
	db $ff, $03, $7f, $01, $3f, $00, $07, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $1f, $0f, $1f, $0f, $1f, $0f, $17, $0f, $17, $0f, $17, $0f, $07, $0f, $0b, $07
	db $0b, $07, $09, $07, $09, $07, $09, $07, $0d, $03, $05, $03, $07, $03, $07, $03
	db $04, $03, $04, $03, $00, $07, $00, $0f, $08, $07, $09, $07, $0b, $05, $0b, $05
	db $0b, $07, $0b, $06, $07, $02, $06, $03, $07, $03, $03, $07, $03, $07, $02, $07
	db $02, $07, $02, $07, $02, $07, $03, $07, $01, $03, $01, $03, $01, $03, $01, $03
	db $01, $03, $01, $03, $01, $03, $01, $03, $00, $01, $00, $01, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $01, $00, $01, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $f7, $f8, $ef, $f0, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $0f, $f0, $1f, $ff, $7f, $ff, $e0, $ff, $bf, $ff, $70, $ff, $4b, $f4, $bf, $ff
	db $e3, $9c, $bf, $ff, $ef, $90, $bf, $ff, $00, $ff, $ff, $00, $c3, $fc, $f8, $ff
	db $8f, $f0, $ff, $ff, $64, $9f, $ff, $ff, $46, $f9, $7f, $ff, $2b, $f4, $78, $ff
	db $57, $e8, $7f, $ff, $d7, $28, $f8, $ff, $9f, $e0, $f0, $ff, $6f, $90, $18, $ff
	db $3f, $40, $5f, $20, $f0, $0f, $ff, $00, $ff, $00, $ff, $00, $7f, $00, $7f, $00
	db $3f, $00, $3f, $00, $0f, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $f3, $fc, $f7, $f8, $f7, $f8, $f3, $fc, $fb, $fc, $fb, $fc, $fb, $fc, $f9, $fe
	db $31, $fe, $91, $7e, $e9, $d6, $1d, $f6, $ec, $ff, $fc, $ff, $fe, $ff, $fe, $ff
	db $81, $7e, $e1, $9e, $fd, $f2, $37, $f8, $ef, $f8, $73, $fc, $ff, $04, $ff, $f4
	db $fd, $06, $f5, $fe, $f1, $0e, $fd, $fa, $03, $fc, $ff, $00, $ff, $00, $0f, $f0
	db $fb, $04, $ff, $fc, $ff, $04, $fd, $fe, $ff, $04, $fc, $ff, $fe, $05, $2e, $fd
	db $f8, $07, $fc, $ff, $f8, $06, $08, $fe, $f4, $0e, $08, $f4, $f0, $0c, $10, $e8
	db $ee, $10, $ef, $10, $1f, $e0, $ff, $00, $ff, $00, $ff, $00, $fc, $00, $f8, $00
	db $f0, $00, $e0, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $81, $00, $81, $00, $81, $00, $81, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00
	db $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $03, $00, $07, $00
	db $1f, $00, $ff, $00, $ff, $00, $ff, $00, $1f, $00, $0f, $00, $07, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $e3, $1f, $e3, $1f, $ff, $00, $ff, $00, $f1, $0f, $e7, $1f, $e7, $1f, $cf, $3f
	db $df, $3f, $df, $3f, $df, $3f, $df, $3f, $df, $3f, $df, $3f, $df, $3f, $df, $3f
	db $df, $3f, $df, $3f, $df, $3f, $df, $3f, $df, $3f, $df, $3f, $5f, $3f, $6f, $1f
	db $6f, $1f, $6f, $1f, $6f, $1f, $6f, $1f, $67, $1f, $67, $1f, $67, $1f, $67, $1f
	db $27, $1f, $27, $1f, $27, $1f, $27, $1f, $27, $1f, $27, $1f, $67, $5f, $ef, $df
	db $bf, $cf, $b7, $cf, $77, $8f, $f7, $0b, $fd, $03, $7d, $83, $fe, $81, $bf, $c0
	db $3f, $c0, $bf, $40, $bf, $60, $ff, $30, $fe, $1f, $ff, $0f, $ff, $03, $3f, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ec, $13, $1f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $ff, $00, $ff, $80, $7f, $c0, $3f, $7f, $80, $ff, $ff, $ff, $ff, $f8, $07
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $f8, $f0, $f8, $e0, $f8, $00, $08, $f0, $e8, $f0, $f0, $f8, $f0, $f8, $f0, $f8
	db $f0, $f8, $f0, $f8, $f0, $f8, $f0, $f8, $f0, $f8, $f0, $f8, $f0, $f8, $f0, $f8
	db $f0, $f8, $f0, $f8, $f0, $f8, $f0, $f8, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $f0
	db $f0, $e0, $f0, $e0, $f0, $e0, $e0, $f0, $e0, $f0, $e0, $f0, $f0, $e0, $f0, $e0
	db $f0, $c0, $f0, $c0, $f0, $c0, $f0, $e0, $f0, $e0, $f0, $e0, $f0, $e0, $f0, $e0
	db $f0, $e0, $f0, $f0, $f0, $f0, $f0, $f0, $f8, $f8, $f8, $f8, $f8, $f8, $f8, $f0
	db $08, $f0, $08, $f0, $10, $e8, $38, $d8, $f0, $78, $d8, $e0, $30, $c0, $00, $80
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $1f, $0f, $1f, $0f, $1f, $0f, $17, $0f, $17, $0f, $17, $0f, $07, $0f, $0f, $07
	db $0f, $07, $0f, $07, $0f, $07, $0f, $07, $0f, $03, $07, $03, $07, $03, $07, $03
	db $00, $07, $00, $07, $00, $07, $00, $07, $00, $07, $08, $07, $08, $07, $00, $0f
	db $08, $07, $09, $07, $0b, $07, $0e, $07, $05, $07, $01, $06, $07, $00, $06, $07
	db $01, $03, $00, $03, $00, $01, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $01, $00, $03, $00, $07, $00, $07, $00, $03, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $fe, $ff, $ff, $f8, $f0, $ff, $ff, $ff, $ff, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $3f, $c0
	db $ff, $7f, $ff, $ff, $80, $ff, $7f, $ff, $bf, $40, $00, $ff, $ff, $00, $1f, $e0
	db $ff, $ff, $ef, $10, $c0, $ff, $df, $20, $00, $ff, $3f, $40, $00, $1f, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $1f, $00, $7f, $00
	db $7f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $3f, $00
	db $1f, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $fb, $fc, $fb, $fc, $fb, $fc, $fa, $fc, $fa, $fc, $fa, $fc, $fa, $fc, $f8, $fe
	db $f0, $fe, $f0, $fc, $c8, $f4, $f4, $08, $14, $e8, $dc, $e0, $ec, $f0, $ec, $f0
	db $0c, $f0, $0c, $f0, $0c, $f0, $0c, $f0, $1c, $e0, $1e, $e0, $1e, $e0, $3e, $c0
	db $fe, $f0, $fe, $fc, $1e, $fe, $e6, $fe, $f2, $1e, $18, $ee, $fc, $02, $e0, $1c
	db $f0, $fc, $e8, $18, $30, $f8, $a0, $50, $00, $f0, $c0, $20, $00, $80, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $c0, $00
	db $f0, $00, $ff, $00, $ff, $00, $ff, $00, $fc, $00, $f0, $00, $c0, $00, $80, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00
	db $03, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $01, $02, $01, $07, $00
	db $1f, $00, $ff, $00, $ff, $00, $9f, $00, $1f, $00, $1f, $00, $07, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ef, $1f, $e3, $1f, $ff, $00, $ff, $00, $f1, $0f, $e7, $1f, $e7, $1f, $cf, $3f
	db $df, $3f, $df, $3f, $9f, $7f, $9f, $7f, $9f, $7f, $9f, $7f, $9f, $7f, $9f, $7f
	db $9f, $7f, $9f, $7f, $9f, $7f, $9f, $7f, $9f, $7f, $df, $3f, $df, $3f, $df, $3f
	db $df, $3f, $df, $3f, $df, $3f, $5f, $3f, $5f, $3f, $7f, $1f, $6f, $1f, $6f, $1f
	db $6f, $1f, $6f, $1f, $6f, $1f, $6f, $1f, $2f, $1f, $3f, $1f, $3f, $1f, $3f, $0f
	db $3f, $4f, $3f, $4f, $7f, $8f, $ff, $1f, $ff, $1f, $7f, $bf, $ff, $bf, $bf, $ff
	db $00, $ff, $a0, $5f, $d0, $6f, $ff, $70, $bf, $7f, $df, $3f, $e7, $1f, $3f, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ec, $13, $1f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $ff, $00, $ff, $00, $ff, $ce, $31, $ff, $ff, $ff, $ff, $ff, $ff, $fd, $fe
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $f8, $f0, $f8, $e0, $f8, $00, $08, $f0, $e8, $f0, $f0, $f8, $f0, $f8, $f0, $f8
	db $f0, $f8, $f0, $f8, $f0, $f8, $f0, $f8, $f0, $f8, $f0, $f8, $f0, $f8, $f8, $f8
	db $f8, $f8, $f8, $f8, $f8, $f8, $f8, $f8, $f8, $f8, $f8, $f8, $f0, $f8, $f0, $f8
	db $f0, $f8, $f0, $f8, $f0, $f8, $f0, $f8, $f0, $f8, $e0, $f8, $e0, $f8, $e0, $f0
	db $e0, $f0, $e0, $f0, $e0, $f0, $e0, $f0, $e0, $f0, $c0, $f0, $c0, $f0, $c0, $f0
	db $e0, $f0, $e0, $f0, $f0, $f0, $f0, $f0, $f8, $f8, $f8, $f8, $f8, $f8, $f8, $f0
	db $08, $f0, $08, $f0, $18, $f8, $38, $f8, $f8, $f8, $f8, $e0, $f0, $e0, $00, $80
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $1f, $9f, $e0, $fe, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $80, $7f, $80, $7f, $80, $7f, $c0, $3f, $40, $bf, $c0, $3f, $80, $7f, $80, $7f
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $80, $7f, $e0, $df, $70, $ef, $bc, $7b, $fe, $1f, $37, $0f, $1d, $03, $0f, $00
	db $07, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $fe, $ff, $fe, $ff, $fe, $ff, $ff, $f8, $e0, $1f, $1f, $ff, $fe, $ff, $fe, $ff
	db $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $01, $fe, $7b, $87, $ff, $ff, $ff, $ff, $79, $fe
	db $ff, $00, $fe, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $70, $80, $70, $80, $70, $80, $f0, $00, $70, $80, $70, $80, $f0, $00, $f0, $00
	db $f0, $00, $f0, $00, $f0, $00, $70, $80, $30, $c0, $30, $c0, $30, $c0, $b0, $c0
	db $b0, $c0, $b0, $c0, $a0, $c0, $a0, $c0, $a0, $c0, $a0, $c0, $e0, $80, $60, $80
	db $60, $80, $60, $80, $60, $80, $60, $80, $e0, $00, $e0, $00, $e0, $00, $f0, $00
	db $70, $80, $70, $80, $70, $80, $38, $c0, $38, $c0, $3c, $c0, $1f, $e0, $1f, $e0
	db $1f, $e0, $1f, $e0, $1f, $e0, $1f, $e0, $1f, $e0, $0f, $f0, $0f, $f0, $0f, $f0
	db $1f, $e0, $1f, $f0, $7f, $b0, $ef, $f0, $ef, $f0, $dc, $e0, $78, $80, $e0, $00
	db $c0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $07, $00, $07, $00, $07, $00, $07, $00, $06, $01, $06, $01, $07, $00, $07, $00
	db $02, $01, $02, $01, $02, $01, $02, $01, $02, $01, $02, $01, $02, $01, $03, $00
	db $01, $00, $01, $00, $00, $01, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $01, $00, $e3, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $01, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $7f, $bf, $1f, $e0, $40, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff
	db $7f, $ff, $7f, $ff, $7f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $7f, $ff, $7f, $ff
	db $7f, $ff, $7f, $ff, $7f, $ff, $3f, $ff, $3f, $ff, $9f, $7f, $9f, $7f, $9f, $7f
	db $df, $3f, $df, $3f, $df, $3f, $df, $3f, $df, $3f, $ff, $3f, $ff, $3f, $ff, $3f
	db $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $c0, $3f, $40, $bf, $40, $bf
	db $40, $bf, $60, $9f, $20, $df, $00, $ff, $80, $7f, $80, $7f, $80, $ff, $c0, $ff
	db $ff, $70, $ff, $7f, $ff, $1f, $ff, $07, $ff, $00, $ff, $00, $07, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $fe, $f6, $29, $1f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $03, $fc
	db $f3, $0f, $fe, $ff, $ff, $fc, $ff, $f8, $3f, $c0, $ff, $00, $fc, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $f0, $c0, $f0, $00, $00, $f0, $c0, $f0, $e0, $f0, $e0, $f0, $f0, $e0, $f0, $e0
	db $f0, $e0, $f0, $e0, $f0, $e0, $f0, $e0, $f0, $e0, $f0, $e0, $f0, $e0, $f0, $e0
	db $f0, $e0, $e0, $f0, $e0, $f0, $e0, $f0, $c0, $f0, $c0, $e0, $e0, $c0, $e0, $c0
	db $e0, $c0, $e0, $c0, $e0, $c0, $e0, $c0, $e0, $c0, $e0, $c0, $f8, $d8, $ff, $dc
	db $21, $de, $11, $ee, $11, $ee, $03, $fe, $03, $fe, $03, $fe, $03, $fe, $07, $fc
	db $0f, $f4, $0f, $f8, $1f, $e8, $1f, $f8, $3f, $d0, $6f, $b0, $ff, $60, $ff, $c0
	db $bc, $c0, $fc, $00, $f8, $00, $f0, $00, $e0, $00, $80, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $80, $00, $80, $00, $c0, $00, $e0, $00, $f0, $00, $f0, $00, $f8, $00, $f0, $00
	db $f0, $00, $e0, $00, $e0, $00, $c0, $00, $c0, $00, $80, $00, $80, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $ec, $00, $4f, $01, $b2, $01, $00, $00, $ec, $00, $b2, $01, $95, $3e
	db $06, $38, $48, $70, $00, $38, $50, $78, $00, $48, $48, $72, $00, $48, $50, $7a
	db $00, $58, $48, $74, $00, $58, $50, $7c, $00, $0c, $38, $40, $80, $00, $38, $48
	db $88, $00, $38, $50, $90, $00, $38, $58, $98, $00, $48, $40, $82, $00, $48, $48
	db $8a, $00, $48, $50, $92, $00, $48, $58, $9a, $00, $58, $40, $84, $00, $58, $48
	db $8c, $00, $58, $50, $94, $00, $58, $58, $9c, $00, $0c, $38, $40, $50, $00, $38
	db $48, $58, $00, $38, $50, $60, $00, $38, $58, $68, $00, $48, $40, $52, $00, $48
	db $48, $5a, $00, $48, $50, $62, $00, $48, $58, $6a, $00, $58, $40, $54, $00, $58
	db $48, $5c, $00, $58, $50, $64, $00, $58, $58, $6c, $00, $28, $28, $28, $00, $00
	db $28, $30, $08, $00, $28, $38, $10, $00, $28, $40, $18, $00, $28, $48, $20, $00
	db $28, $50, $28, $00, $28, $58, $30, $00, $28, $60, $38, $00, $28, $68, $40, $00
	db $28, $70, $48, $00, $38, $28, $02, $00, $38, $30, $0a, $00, $38, $38, $12, $00
	db $38, $40, $1a, $00, $38, $48, $22, $00, $38, $50, $2a, $00, $38, $58, $32, $00
	db $38, $60, $3a, $00, $38, $68, $42, $00, $38, $70, $4a, $00, $48, $28, $04, $00
	db $48, $30, $0c, $00, $48, $38, $14, $00, $48, $40, $1c, $00, $48, $48, $24, $00
	db $48, $50, $2c, $00, $48, $58, $34, $00, $48, $60, $3c, $00, $48, $68, $44, $00
	db $48, $70, $4c, $00, $58, $28, $06, $00, $58, $30, $0e, $00, $58, $38, $16, $00
	db $58, $40, $1e, $00, $58, $48, $26, $00, $58, $50, $2e, $00, $58, $58, $36, $00
	db $58, $60, $3e, $00, $58, $68, $46, $00, $58, $70, $4e, $00, $12, $20, $38, $00
	db $00, $20, $40, $08, $00, $20, $48, $10, $00, $20, $50, $18, $00, $20, $58, $20
	db $00, $20, $60, $28, $00, $30, $38, $02, $00, $30, $40, $0a, $00, $30, $48, $12
	db $00, $30, $50, $1a, $00, $30, $58, $22, $00, $30, $60, $2a, $00, $40, $38, $04
	db $00, $40, $40, $0c, $00, $40, $48, $14, $01, $40, $50, $1c, $01, $40, $58, $24
	db $00, $40, $60, $2c, $00, $08, $60, $30, $30, $01, $60, $38, $38, $01, $60, $40
	db $40, $01, $60, $48, $48, $01, $60, $50, $50, $01, $60, $58, $58, $01, $60, $60
	db $60, $01, $60, $68, $68, $01, $08, $60, $30, $32, $01, $60, $38, $3a, $01, $60
	db $40, $42, $01, $60, $48, $4a, $01, $60, $50, $52, $01, $60, $58, $5a, $01, $60
	db $60, $62, $01, $60, $68, $6a, $01, $08, $60, $30, $34, $01, $60, $38, $3c, $01
	db $60, $40, $44, $01, $60, $48, $4c, $01, $60, $50, $54, $01, $60, $58, $5c, $01
	db $60, $60, $64, $01, $60, $68, $6c, $01, $08, $60, $30, $36, $01, $60, $38, $3e
	db $01, $60, $40, $46, $01, $60, $48, $4e, $01, $60, $50, $56, $01, $60, $58, $5e
	db $01, $60, $60, $66, $01, $60, $68, $6e, $01, $08, $60, $30, $70, $01, $60, $38
	db $78, $01, $60, $40, $72, $01, $60, $48, $7a, $01, $60, $50, $74, $01, $60, $58
	db $7c, $01, $60, $60, $76, $01, $60, $68, $7e, $01, $1c, $20, $30, $00, $00, $20
	db $38, $08, $00, $20, $40, $10, $00, $20, $48, $18, $00, $20, $50, $20, $00, $20
	db $58, $28, $00, $20, $60, $30, $00, $30, $30, $02, $00, $30, $38, $0a, $00, $30
	db $40, $12, $00, $30, $48, $1a, $00, $30, $50, $22, $00, $30, $58, $2a, $00, $30
	db $60, $32, $00, $40, $30, $04, $01, $40, $38, $0c, $01, $40, $40, $14, $01, $40
	db $48, $1c, $01, $40, $50, $24, $01, $40, $58, $2c, $01, $40, $60, $34, $01, $50
	db $30, $06, $01, $50, $38, $0e, $01, $50, $40, $16, $01, $50, $48, $1e, $01, $50
	db $50, $26, $01, $50, $58, $2e, $01, $50, $60, $36, $01, $1c, $20, $30, $38, $00
	db $20, $38, $40, $00, $20, $40, $48, $00, $20, $48, $50, $00, $20, $50, $58, $00
	db $20, $58, $60, $00, $20, $60, $68, $00, $30, $30, $3a, $00, $30, $38, $42, $00
	db $30, $40, $4a, $00, $30, $48, $52, $00, $30, $50, $5a, $00, $30, $58, $62, $00
	db $30, $60, $6a, $00, $40, $30, $3c, $01, $40, $38, $44, $01, $40, $40, $4c, $01
	db $40, $48, $54, $01, $40, $50, $5c, $01, $40, $58, $64, $01, $40, $60, $6c, $01
	db $50, $30, $3e, $01, $50, $38, $46, $01, $50, $40, $4e, $01, $50, $48, $56, $01
	db $50, $50, $5e, $01, $50, $58, $66, $01, $50, $60, $6e, $01, $1c, $20, $30, $80
	db $00, $20, $38, $88, $00, $20, $40, $90, $00, $20, $48, $98, $00, $20, $50, $a0
	db $00, $20, $58, $a8, $00, $20, $60, $b0, $00, $30, $30, $82, $01, $30, $38, $8a
	db $01, $30, $40, $92, $01, $30, $48, $9a, $00, $30, $50, $a2, $00, $30, $58, $aa
	db $00, $30, $60, $b2, $00, $40, $30, $84, $01, $40, $38, $8c, $01, $40, $40, $94
	db $01, $40, $48, $9c, $00, $40, $50, $a4, $00, $40, $58, $ac, $00, $40, $60, $b4
	db $00, $50, $30, $86, $01, $50, $38, $8e, $01, $50, $40, $96, $01, $50, $48, $9e
	db $01, $50, $50, $a6, $01, $50, $58, $ae, $01, $50, $60, $b6, $01, $1c, $20, $30
	db $b8, $00, $20, $38, $c0, $00, $20, $40, $c8, $00, $20, $48, $d0, $00, $20, $50
	db $d8, $00, $20, $58, $e0, $00, $20, $60, $e8, $00, $30, $30, $ba, $01, $30, $38
	db $c2, $01, $30, $40, $ca, $01, $30, $48, $d2, $00, $30, $50, $da, $00, $30, $58
	db $e2, $00, $30, $60, $ea, $00, $40, $30, $bc, $01, $40, $38, $c4, $01, $40, $40
	db $cc, $01, $40, $48, $d4, $00, $40, $50, $dc, $00, $40, $58, $e4, $00, $40, $60
	db $ec, $00, $50, $30, $be, $01, $50, $38, $c6, $01, $50, $40, $ce, $01, $50, $48
	db $d6, $01, $50, $50, $de, $01, $50, $58, $e6, $01, $50, $60, $ee, $01, $1c, $20
	db $30, $30, $20, $20, $38, $28, $20, $20, $40, $20, $20, $20, $48, $18, $20, $20
	db $50, $10, $20, $20, $58, $08, $20, $20, $60, $00, $20, $30, $30, $32, $20, $30
	db $38, $2a, $20, $30, $40, $22, $20, $30, $48, $1a, $20, $30, $50, $12, $20, $30
	db $58, $0a, $20, $30, $60, $02, $20, $40, $30, $34, $21, $40, $38, $2c, $21, $40
	db $40, $24, $21, $40, $48, $1c, $21, $40, $50, $14, $21, $40, $58, $0c, $21, $40
	db $60, $04, $21, $50, $30, $36, $21, $50, $38, $2e, $21, $50, $40, $26, $21, $50
	db $48, $1e, $21, $50, $50, $16, $21, $50, $58, $0e, $21, $50, $60, $06, $21, $1c
	db $20, $30, $68, $20, $20, $38, $60, $20, $20, $40, $58, $20, $20, $48, $50, $20
	db $20, $50, $48, $20, $20, $58, $40, $20, $20, $60, $38, $20, $30, $30, $6a, $20
	db $30, $38, $62, $20, $30, $40, $5a, $20, $30, $48, $52, $20, $30, $50, $4a, $20
	db $30, $58, $42, $20, $30, $60, $3a, $20, $40, $30, $6c, $21, $40, $38, $64, $21
	db $40, $40, $5c, $21, $40, $48, $54, $21, $40, $50, $4c, $21, $40, $58, $44, $21
	db $40, $60, $3c, $21, $50, $30, $6e, $21, $50, $38, $66, $21, $50, $40, $5e, $21
	db $50, $48, $56, $21, $50, $50, $4e, $21, $50, $58, $46, $21, $50, $60, $3e, $21
	db $1c, $20, $30, $b0, $20, $20, $38, $a8, $20, $20, $40, $a0, $20, $20, $48, $98
	db $20, $20, $50, $90, $20, $20, $58, $88, $20, $20, $60, $80, $20, $30, $30, $b2
	db $20, $30, $38, $aa, $20, $30, $40, $a2, $20, $30, $48, $9a, $20, $30, $50, $92
	db $21, $30, $58, $8a, $21, $30, $60, $82, $21, $40, $30, $b4, $20, $40, $38, $ac
	db $20, $40, $40, $a4, $20, $40, $48, $9c, $20, $40, $50, $94, $21, $40, $58, $8c
	db $21, $40, $60, $84, $21, $50, $30, $b6, $21, $50, $38, $ae, $21, $50, $40, $a6
	db $21, $50, $48, $9e, $21, $50, $50, $96, $21, $50, $58, $8e, $21, $50, $60, $86
	db $21, $1c, $20, $30, $e8, $20, $20, $38, $e0, $20, $20, $40, $d8, $20, $20, $48
	db $d0, $20, $20, $50, $c8, $20, $20, $58, $c0, $20, $20, $60, $b8, $20, $30, $30
	db $ea, $20, $30, $38, $e2, $20, $30, $40, $da, $20, $30, $48, $d2, $20, $30, $50
	db $ca, $21, $30, $58, $c2, $21, $30, $60, $ba, $21, $40, $30, $ec, $20, $40, $38
	db $e4, $20, $40, $40, $dc, $20, $40, $48, $d4, $20, $40, $50, $cc, $21, $40, $58
	db $c4, $21, $40, $60, $bc, $21, $50, $30, $ee, $21, $50, $38, $e6, $21, $50, $40
	db $de, $21, $50, $48, $d6, $21, $50, $50, $ce, $21, $50, $58, $c6, $21, $50, $60
	db $be, $21, $28, $20, $28, $70, $00, $20, $30, $78, $00, $20, $38, $00, $08, $20
	db $40, $08, $08, $20, $48, $10, $08, $20, $50, $18, $08, $20, $58, $20, $08, $20
	db $60, $28, $08, $20, $68, $30, $08, $20, $70, $38, $08, $30, $28, $72, $00, $30
	db $30, $7a, $00, $30, $38, $02, $08, $30, $40, $0a, $08, $30, $48, $12, $08, $30
	db $50, $1a, $08, $30, $58, $22, $08, $30, $60, $2a, $08, $30, $68, $32, $08, $30
	db $70, $3a, $08, $40, $28, $74, $01, $40, $30, $7c, $01, $40, $38, $04, $09, $40
	db $40, $0c, $09, $40, $48, $14, $09, $40, $50, $1c, $09, $40, $58, $24, $09, $40
	db $60, $2c, $09, $40, $68, $34, $09, $40, $70, $3c, $09, $50, $28, $76, $01, $50
	db $30, $7e, $01, $50, $38, $06, $09, $50, $40, $0e, $09, $50, $48, $16, $09, $50
	db $50, $1e, $09, $50, $58, $26, $09, $50, $60, $2e, $09, $50, $68, $36, $09, $50
	db $70, $3e, $09

SECTION "analyzed_0ac000", ROMX[$4000], BANK[$2b]

Data_2b_4000:
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $01, $01, $03, $02, $07, $04, $0f, $00, $0f, $00, $07
	db $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $01, $03, $00, $03, $00, $07, $0f, $0f, $1f
	db $1f, $3e, $7d, $7e, $ef, $f0, $e7, $98, $8f, $70, $0f, $f0, $1e, $e1, $1e, $e1
	db $1c, $e3, $18, $67, $19, $06, $35, $02, $24, $03, $22, $01, $02, $01, $02, $01
	db $02, $01, $00, $01, $00, $01, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $01, $00, $00, $01, $00, $01, $01, $00, $01, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $03, $03, $0f, $0f, $1f, $1f, $3f, $3f, $1f
	db $7f, $1e, $7e, $bd, $7f, $f8, $3f, $c0, $ff, $07, $ef, $ff, $9f, $ff, $ff, $7f
	db $00, $ff, $ff, $00, $f8, $07, $f8, $07, $f0, $0f, $71, $8f, $6f, $9f, $7f, $9f
	db $5f, $bf, $ff, $1f, $ff, $0f, $0f, $f7, $73, $ff, $f9, $87, $f9, $67, $d9, $67
	db $ff, $fd, $7d, $ff, $7b, $ff, $37, $fb, $37, $fb, $0f, $f7, $0f, $ff, $07, $ff
	db $09, $f7, $07, $f8, $03, $fc, $00, $ff, $01, $ff, $83, $7c, $40, $bf, $20, $5f
	db $00, $3f, $10, $0f, $08, $07, $04, $03, $02, $01, $01, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $03, $1c, $37, $fb, $ef, $ff, $df, $ff, $bf, $ff, $ff, $7f, $7f, $f9
	db $ff, $f9, $ff, $ff, $ff, $00, $ff, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $ff, $bd, $42, $3c, $c3, $1e, $e1, $0e, $f1, $86, $f9, $f7, $f8, $fb, $fc
	db $fd, $fe, $ff, $f8, $ff, $f0, $f3, $ef, $ff, $ff, $ff, $fe, $ff, $fd, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $df, $3f, $7f, $ff, $ff, $ff, $ff, $fe, $ff, $01, $ff, $ff, $7f, $ff
	db $7f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $7f, $ff, $ff, $7f, $3f, $00
	db $1f, $00, $1f, $00, $3e, $01, $fb, $07, $af, $5f, $3f, $ff, $15, $55, $2a, $2a
	db $00, $00, $30, $fe, $f7, $ff, $f7, $ff, $f7, $ff, $f7, $ff, $f7, $ff, $f7, $ff
	db $ff, $f7, $ff, $f7, $fc, $03, $ff, $00, $ef, $fc, $ef, $ff, $df, $ff, $ff, $df
	db $2f, $df, $f8, $07, $ff, $00, $ff, $00, $6f, $90, $27, $d8, $13, $ec, $61, $fe
	db $f8, $7f, $fe, $07, $0f, $f1, $f3, $fc, $ff, $ff, $ff, $0f, $ff, $87, $7f, $87
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $fe, $ff, $fe, $fd, $fd, $fb, $ff, $f3, $fb, $e7, $f6, $8f, $e6, $19
	db $f7, $0f, $bf, $7f, $ff, $ff, $fe, $ff, $fa, $fd, $fc, $f3, $50, $45, $a0, $8a
	db $00, $00, $00, $00, $00, $c0, $c0, $f0, $f8, $fc, $fc, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $fc, $ff, $3c, $f7, $0f, $bc, $c3, $fb, $f7, $fb, $ff
	db $fc, $fb, $ff, $f9, $df, $39, $f7, $09, $fd, $03, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $7f, $80, $3f, $c0, $bf, $c0, $ff, $e0, $ff, $e0, $ef, $f0, $ff, $f0
	db $fe, $f1, $fd, $f3, $fe, $f3, $fe, $f3, $fb, $f6, $ff, $f5, $fe, $f5, $f5, $ff
	db $ff, $ff, $f7, $fc, $ff, $f4, $ef, $f6, $f7, $ee, $df, $ee, $ff, $de, $df, $be
	db $7f, $fe, $fe, $ff, $fe, $ff, $fe, $ff, $7a, $fd, $47, $ff, $3f, $ff, $ff, $ff
	db $ff, $fe, $f0, $ff, $b0, $cf, $00, $ff, $00, $ff, $00, $fa, $00, $55, $00, $aa
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $40, $c0
	db $a0, $e0, $b0, $f0, $d0, $f0, $f8, $d8, $f8, $d8, $d8, $f8, $68, $f8, $7c, $ac
	db $fc, $0c, $fc, $8c, $fc, $e4, $ee, $f6, $fe, $f6, $7d, $f3, $ff, $31, $fe, $03
	db $ff, $03, $fe, $01, $ff, $00, $ff, $00, $fe, $01, $ff, $00, $ff, $00, $7f, $80
	db $ff, $c0, $bf, $60, $ff, $a0, $ff, $e0, $7f, $e0, $7e, $e0, $7e, $c0, $fe, $c0
	db $fe, $00, $f6, $00, $f4, $00, $f4, $00, $e0, $00, $e0, $00, $60, $00, $40, $00
	db $40, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $c0, $c0, $80, $c0, $80
	db $f0, $00, $00, $f8, $00, $fc, $00, $fe, $00, $d5, $00, $aa, $00, $50, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $80, $c0
	db $40, $c0, $80, $e0, $e0, $b0, $f0, $30, $70, $b8, $38, $dc, $18, $ec, $80, $78
	db $80, $60, $80, $00, $80, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $87, $00, $92, $21, $f8, $4a, $00, $00, $ad, $35, $00, $34, $a0, $01
	db $00, $00, $00, $01, $00, $01, $00, $01, $00, $01, $00, $03, $01, $02, $01, $06
	db $02, $04, $06, $08, $0c, $11, $00, $01, $01, $02, $02, $04, $01, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $03, $07, $1f, $1f, $1f, $3f
	db $1f, $3f, $4f, $3f, $4f, $3f, $07, $af, $51, $55, $28, $2a, $15, $15, $02, $02
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $02, $01, $05, $02
	db $09, $06, $0b, $04, $17, $08, $1e, $01, $18, $07, $28, $17, $30, $0f, $30, $0f
	db $20, $1f, $20, $1f, $20, $1f, $31, $0e, $0d, $32, $07, $38, $07, $78, $07, $78
	db $07, $78, $07, $78, $07, $78, $06, $f9, $07, $f9, $07, $f9, $44, $bb, $45, $ba
	db $45, $ba, $49, $b6, $c9, $36, $cb, $34, $8b, $74, $93, $6c, $17, $68, $17, $68
	db $26, $d8, $2c, $d0, $3c, $c0, $d9, $20, $b0, $40, $c0, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $01, $00, $03, $00, $09, $86, $fe, $d9, $cd, $fe, $e7, $fe
	db $f7, $ff, $fb, $f7, $ff, $fb, $fd, $fb, $7f, $7d, $a9, $ab, $54, $55, $aa, $aa
	db $00, $00, $00, $00, $01, $0e, $10, $2f, $23, $5c, $3f, $c3, $7c, $bf, $47, $f8
	db $01, $fe, $82, $7d, $c4, $3b, $f9, $07, $73, $8f, $26, $df, $28, $df, $41, $be
	db $46, $b9, $87, $79, $9d, $63, $1f, $e3, $3a, $c7, $7a, $87, $7c, $87, $75, $8e
	db $75, $8e, $f3, $0c, $f3, $0c, $f7, $08, $77, $88, $fe, $81, $be, $c1, $fe, $c1
	db $7e, $c1, $ce, $31, $ce, $31, $ee, $11, $ee, $11, $6c, $13, $6c, $13, $ee, $11
	db $f3, $08, $e9, $00, $c1, $00, $80, $01, $00, $01, $02, $01, $02, $0d, $01, $1e
	db $06, $1f, $4f, $3f, $ff, $1f, $ec, $1f, $fb, $0c, $f7, $08, $37, $c8, $9a, $65
	db $c1, $3e, $e1, $1e, $60, $9f, $d3, $ef, $ef, $d3, $27, $58, $00, $55, $a0, $8a
	db $00, $00, $00, $00, $e0, $18, $02, $fc, $19, $e6, $be, $df, $21, $de, $fe, $01
	db $c7, $38, $38, $ff, $7d, $fe, $e7, $f8, $87, $f8, $2f, $d0, $e1, $3e, $6d, $fe
	db $f1, $fe, $e3, $fc, $c7, $f8, $9e, $e3, $3e, $c7, $7e, $8f, $fe, $1f, $de, $3f
	db $9e, $7f, $9f, $7f, $3f, $c0, $de, $3f, $3e, $c1, $7b, $8c, $fe, $17, $fe, $07
	db $7f, $87, $cf, $b7, $7f, $cf, $0f, $ff, $3f, $ff, $3f, $ff, $3f, $ff, $1f, $ff
	db $1f, $ff, $8f, $7f, $c7, $3f, $f3, $0f, $7d, $83, $1f, $e0, $07, $f8, $00, $ff
	db $40, $bf, $b7, $cf, $7b, $87, $86, $79, $61, $9e, $1c, $e7, $fe, $7f, $bf, $7f
	db $7f, $bf, $7f, $bf, $9f, $7f, $9f, $7f, $5f, $bf, $4f, $bf, $15, $45, $0a, $aa
	db $00, $00, $00, $00, $00, $00, $38, $7f, $5f, $e0, $e0, $1f, $07, $f8, $3d, $c3
	db $f7, $0f, $e5, $1e, $f3, $0f, $f7, $0f, $e5, $1e, $d7, $3f, $fb, $37, $bb, $77
	db $bc, $73, $3f, $f0, $3e, $f1, $b7, $78, $bc, $7b, $9e, $7b, $9f, $7b, $4f, $bb
	db $6f, $9b, $23, $df, $17, $ed, $8b, $75, $04, $fb, $66, $f9, $73, $fc, $ff, $fe
	db $ff, $fe, $ff, $fe, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $e7, $fb, $e7, $ff
	db $7f, $ff, $b7, $cf, $ff, $ff, $fe, $ff, $fa, $fc, $68, $f0, $e0, $00, $3c, $cc
	db $26, $de, $a3, $df, $40, $bf, $c7, $38, $8f, $70, $b7, $48, $67, $98, $1a, $fd
	db $de, $fd, $bd, $fe, $bf, $fe, $ff, $fe, $ff, $fe, $fe, $ff, $55, $55, $aa, $aa
	db $00, $00, $00, $00, $00, $00, $00, $80, $c0, $00, $20, $c0, $18, $e0, $f8, $fc
	db $1e, $fe, $cd, $03, $f3, $f8, $fa, $fc, $9e, $7f, $73, $8f, $dc, $e3, $bf, $f0
	db $bb, $dc, $51, $ee, $ac, $73, $57, $b8, $ad, $5a, $52, $ad, $32, $cd, $b9, $c6
	db $99, $e6, $d9, $e6, $8d, $f2, $fd, $02, $75, $fa, $eb, $1c, $fb, $4c, $d6, $28
	db $e6, $38, $76, $b8, $f6, $38, $3e, $f0, $fc, $f0, $fc, $f0, $fc, $f0, $e8, $f0
	db $e8, $e0, $e8, $c0, $c0, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $80, $80, $40, $c0, $c7, $3f, $c9, $37, $ce, $37, $cf, $37
	db $8f, $77, $8b, $77, $f9, $37, $f0, $3f, $c8, $37, $b1, $4e, $00, $55, $80, $2a
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $80, $80, $40, $40, $20, $20, $80, $80, $c0, $00, $c0
	db $80, $60, $c0, $20, $e0, $10, $70, $80, $b0, $40, $f8, $00, $58, $80, $08, $c0
	db $00, $e0, $20, $c0, $20, $c0, $40, $80, $40, $80, $c0, $00, $80, $00, $80, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $c0, $c0, $70, $f0, $70, $f0, $b8, $78
	db $f8, $b8, $9c, $fc, $fc, $dc, $ca, $fa, $e4, $f4, $38, $a8, $54, $44, $a0, $20
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $03, $02, $03
	db $07, $02, $01, $06, $02, $05, $03, $05, $0b, $15, $0b, $35, $0a, $35, $2a, $15
	db $2e, $11, $3e, $01, $1e, $01, $07, $00, $07, $00, $03, $00, $01, $00, $00, $00
	db $00, $00, $00, $00, $00, $01, $01, $02, $07, $08, $0f, $00, $1f, $00, $1f, $00
	db $3f, $00, $3f, $00, $2c, $43, $41, $d7, $23, $0b, $01, $55, $02, $0a, $05, $05
	db $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $07, $03, $07, $0f, $1f, $07
	db $07, $19, $33, $3c, $79, $7e, $68, $ff, $de, $ff, $be, $ff, $3e, $ff, $fc, $7f
	db $69, $fe, $d3, $fc, $96, $f9, $ad, $f3, $2b, $f7, $57, $ef, $57, $ef, $7f, $cf
	db $7f, $cf, $7f, $8f, $7f, $b3, $7b, $bd, $3d, $fe, $be, $5f, $fe, $11, $ff, $0e
	db $7b, $0c, $1f, $0e, $1e, $1f, $3d, $1f, $3f, $1d, $3b, $1c, $3f, $1b, $3b, $1f
	db $1f, $0d, $0f, $06, $0f, $01, $0f, $00, $0f, $00, $1f, $00, $23, $1c, $2f, $10
	db $1f, $20, $3f, $c0, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $01, $ff, $01
	db $ef, $11, $8f, $73, $7f, $e3, $df, $e7, $ff, $c7, $15, $45, $aa, $8a, $55, $05
	db $00, $00, $08, $07, $20, $1f, $80, $7f, $fe, $3f, $ff, $ff, $ff, $ff, $dc, $e3
	db $1e, $ff, $bf, $7f, $71, $ff, $ee, $ff, $ff, $ff, $bf, $ff, $59, $ff, $ac, $5f
	db $f6, $0f, $7b, $87, $f5, $8b, $ca, $b5, $db, $b6, $dd, $bb, $de, $bd, $df, $be
	db $ef, $df, $ef, $df, $f1, $ee, $ee, $f1, $f8, $f7, $f9, $7f, $ff, $7c, $ff, $7f
	db $ff, $7e, $ff, $ff, $ff, $ff, $ff, $fb, $ff, $fc, $ee, $f1, $f8, $07, $fe, $ff
	db $ff, $fe, $ff, $00, $ff, $ff, $ff, $ff, $fe, $3f, $ff, $00, $58, $a7, $59, $a7
	db $6b, $d7, $bb, $67, $bd, $7b, $bf, $79, $ff, $39, $fe, $3d, $df, $fc, $ff, $dc
	db $ef, $fe, $ef, $fe, $f6, $ff, $fd, $ff, $ff, $ff, $ff, $ff, $ab, $ab, $55, $55
	db $00, $00, $01, $fe, $00, $ff, $00, $ff, $10, $ef, $fe, $f9, $ff, $fe, $7f, $ff
	db $1f, $ff, $cf, $f7, $f7, $f9, $19, $fe, $86, $ff, $e1, $ff, $f4, $fb, $7a, $fd
	db $9d, $7e, $4e, $bf, $a7, $df, $d9, $e7, $6c, $f3, $d7, $38, $e9, $9e, $78, $e7
	db $9e, $79, $c9, $be, $fd, $02, $ff, $e0, $f7, $f8, $fd, $fe, $fe, $1f, $cf, $f4
	db $ff, $7f, $ff, $8f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $7f, $fe, $3f, $7e, $bf
	db $bc, $5f, $b8, $df, $81, $fe, $03, $fc, $3f, $c0, $fc, $03, $07, $ff, $ff, $ff
	db $fe, $ff, $fb, $fc, $fd, $f3, $d7, $ef, $ff, $df, $bf, $df, $7f, $bf, $ff, $3f
	db $7f, $ff, $7f, $ff, $ff, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ea, $ea, $55, $55
	db $00, $00, $00, $00, $40, $80, $00, $f0, $04, $f8, $03, $fc, $80, $7f, $c0, $bf
	db $e0, $df, $f0, $ef, $f8, $f7, $ec, $fb, $c4, $7b, $42, $bd, $a1, $de, $11, $ee
	db $88, $77, $c8, $37, $64, $9b, $b4, $cb, $5a, $e5, $0f, $f0, $cf, $30, $ff, $00
	db $7f, $80, $9f, $60, $ef, $10, $ff, $00, $fe, $01, $fc, $03, $78, $87, $98, $e7
	db $98, $67, $99, $e6, $99, $e6, $9a, $e5, $1e, $e1, $16, $e9, $3f, $c0, $3f, $c0
	db $7f, $80, $ff, $00, $f7, $08, $d9, $26, $19, $e6, $39, $c6, $b1, $ce, $61, $9e
	db $f1, $3e, $71, $fe, $e3, $fc, $e3, $fc, $e3, $fc, $e7, $f8, $eb, $f4, $f3, $ec
	db $e7, $d8, $cf, $b0, $3f, $f0, $fe, $f1, $fe, $f1, $ff, $e1, $aa, $80, $55, $01
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $c0, $00, $30, $c0
	db $08, $f0, $14, $e8, $1e, $e0, $16, $e8, $01, $fe, $08, $f7, $08, $f7, $00, $ff
	db $84, $7b, $c4, $3b, $64, $9b, $72, $8d, $32, $cd, $3b, $c4, $1f, $e0, $9e, $60
	db $9e, $60, $dc, $20, $dc, $20, $c8, $30, $c8, $30, $68, $90, $68, $90, $f0, $00
	db $c0, $20, $a0, $40, $20, $c0, $00, $c0, $40, $80, $40, $80, $40, $80, $c0, $00
	db $e0, $00, $f0, $00, $f0, $00, $f8, $00, $e8, $10, $84, $78, $c2, $3c, $f0, $0e
	db $f8, $07, $fe, $01, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $bf, $40
	db $9f, $60, $77, $f8, $79, $fe, $f8, $ff, $f0, $ff, $f0, $ff, $a0, $aa, $40, $55
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $00, $80, $40, $80
	db $20, $c0, $10, $e0, $10, $e0, $10, $e0, $20, $d0, $e0, $00, $a0, $00, $70, $00
	db $78, $00, $5c, $20, $4c, $30, $46, $38, $02, $7c, $38, $06, $02, $00, $00, $00
	db $00, $00, $00, $80, $c0, $00, $c0, $00, $f0, $00, $fc, $00, $fc, $00, $fe, $01
	db $ff, $00, $ff, $00, $fe, $01, $1c, $e3, $18, $e2, $10, $c4, $08, $a0, $10, $40
	db $00, $00, $00, $00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $07, $00, $0b, $04, $17, $08, $07, $38, $28, $d7, $d0, $af
	db $50, $af, $a0, $7f, $bb, $7c, $77, $f8, $5f, $e0, $3f, $c0, $ff, $00, $ff, $00
	db $00, $00, $00, $00, $00, $03, $00, $00, $00, $00, $03, $00, $04, $03, $0b, $07
	db $05, $0e, $0a, $1d, $0d, $33, $3b, $47, $54, $8f, $2b, $1c, $57, $38, $0f, $70
	db $9f, $61, $2f, $d1, $4f, $b1, $9e, $21, $1c, $23, $1c, $23, $1b, $20, $1b, $00
	db $13, $00, $02, $01, $01, $00, $01, $00, $00, $03, $01, $03, $03, $01, $03, $01
	db $00, $03, $01, $00, $01, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $07, $00, $3f, $00, $fe, $05, $fd, $1a, $fa, $35, $fa, $f5, $34, $eb, $14, $eb
	db $2b, $d7, $ef, $17, $ec, $17, $c7, $3f, $d7, $2f, $d7, $2f, $df, $2f, $df, $2f
	db $00, $00, $00, $00, $06, $f8, $e1, $1f, $7c, $03, $1f, $e0, $ef, $f0, $83, $fc
	db $b9, $46, $6e, $f1, $87, $f8, $03, $fc, $ff, $00, $e0, $1f, $88, $7f, $1d, $ff
	db $3f, $f0, $bf, $cf, $ff, $7f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $1f, $ff, $0f
	db $3f, $cf, $f7, $0f, $ff, $47, $3f, $e7, $f7, $ef, $ff, $cf, $ff, $cf, $ff, $df
	db $ed, $de, $ff, $c0, $ef, $f0, $f7, $78, $bf, $7f, $35, $7a, $7f, $37, $7d, $3e
	db $3e, $1f, $3f, $1f, $1f, $0f, $08, $07, $07, $00, $05, $02, $03, $07, $75, $0f
	db $ed, $1f, $fc, $1f, $b0, $7f, $e3, $1f, $fe, $ff, $7f, $ff, $0d, $ff, $c0, $ff
	db $ff, $ff, $ff, $ff, $00, $ff, $f0, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $40, $83, $a3, $cf, $46, $ff, $a9, $76, $87, $78
	db $ff, $00, $fd, $03, $f7, $0f, $eb, $1d, $e1, $1e, $1f, $e0, $c3, $fc, $e1, $fe
	db $ae, $7f, $df, $e7, $ff, $f8, $ff, $ff, $ff, $ff, $df, $e0, $7f, $80, $e1, $1e
	db $df, $20, $ff, $88, $ae, $df, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $7f, $ff, $3e, $ff, $be, $7f, $7e, $ff, $fe, $ff, $fc, $1f, $fc, $ef, $3c, $ff
	db $78, $ff, $f1, $fe, $e3, $fc, $0f, $f0, $fc, $03, $f0, $0f, $02, $fd, $06, $ff
	db $84, $ff, $8d, $fe, $99, $fe, $bb, $fc, $f2, $fd, $f9, $ff, $00, $ff, $00, $ff
	db $f0, $ff, $00, $ff, $00, $ff, $07, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $c0, $00, $f0, $f0, $08, $fc, $00, $0c, $f3
	db $b0, $7f, $5d, $fe, $a6, $df, $fb, $c7, $dc, $e3, $7e, $e1, $af, $70, $ef, $30
	db $ff, $00, $ff, $00, $fb, $04, $f3, $0c, $a3, $dc, $1d, $e2, $9f, $60, $cf, $30
	db $8e, $71, $0c, $f3, $0c, $f3, $8c, $f3, $8c, $f3, $8c, $f3, $8c, $f3, $19, $e6
	db $1b, $e4, $13, $ec, $07, $f8, $07, $f8, $03, $fc, $0a, $f4, $1a, $e4, $7a, $84
	db $fa, $05, $f1, $0e, $b1, $4e, $21, $de, $21, $de, $41, $be, $41, $be, $42, $bd
	db $81, $7e, $0d, $f2, $0b, $f5, $1b, $e5, $d7, $eb, $f7, $eb, $74, $eb, $0c, $f3
	db $2f, $d0, $2f, $d0, $2f, $d0, $ef, $d0, $df, $e0, $df, $e0, $df, $a0, $df, $a0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $80, $00, $40, $80, $80, $c0, $20, $c0, $00, $e0, $90, $60
	db $d0, $20, $e0, $10, $e0, $10, $f0, $00, $78, $80, $78, $80, $7c, $80, $f0, $00
	db $f0, $80, $60, $c0, $60, $c0, $70, $c0, $30, $c0, $70, $80, $f8, $00, $e8, $00
	db $e0, $00, $c0, $00, $c0, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $c0, $00, $b0, $40, $7c, $80, $ff, $00
	db $ff, $c0, $ff, $c0, $ff, $e0, $ff, $f0, $c3, $fc, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $c3, $3f, $ff, $0f, $ff, $07, $ff, $01, $ff, $00, $ff, $00, $ff, $00
	db $f8, $00, $ff, $00, $fd, $02, $fb, $04, $f4, $0b, $f7, $0b, $2b, $d7, $2f, $d7
	db $d7, $af, $d7, $af, $d7, $af, $b7, $4f, $bf, $47, $bb, $47, $7d, $83, $7d, $83
	db $00, $00, $00, $00, $01, $02, $0c, $13, $c0, $3f, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $7f, $00, $bf, $00, $5f, $00, $2b, $00, $55, $00, $0a, $00, $01
	db $00, $00, $00, $00, $03, $00, $0c, $03, $10, $0f, $20, $1f, $00, $7f, $00, $7f
	db $00, $ff, $00, $ff, $81, $7e, $87, $7b, $8f, $7f, $9e, $7f, $7b, $3c, $75, $3a
	db $29, $76, $57, $2c, $7f, $0c, $5a, $2d, $52, $2d, $4a, $35, $48, $37, $4f, $30
	db $2f, $10, $3f, $00, $17, $09, $17, $09, $17, $09, $0b, $05, $0b, $05, $07, $00
	db $01, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $03, $00
	db $07, $00, $7f, $02, $9f, $67, $1f, $ef, $0f, $ff, $3f, $df, $3f, $df, $3f, $df
	db $1f, $ff, $1f, $ff, $3f, $ff, $7f, $bf, $7f, $bf, $5f, $9f, $2a, $aa, $55, $15
	db $00, $1f, $81, $7e, $07, $f8, $0f, $f0, $1f, $e0, $3f, $c0, $3f, $c0, $7f, $80
	db $7f, $80, $ff, $1f, $ff, $ff, $ff, $ff, $df, $e0, $ea, $1d, $3c, $db, $75, $db
	db $f5, $db, $b5, $db, $25, $db, $a5, $5b, $d5, $2b, $55, $ab, $ff, $03, $9d, $63
	db $75, $8b, $ff, $11, $fe, $4d, $be, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $fe, $ff
	db $ff, $ff, $ff, $ff, $7f, $ff, $ff, $7c, $7f, $3f, $7f, $1f, $3f, $0f, $1b, $07
	db $19, $07, $0a, $07, $7b, $07, $db, $27, $eb, $57, $f5, $6b, $fa, $f5, $fc, $fb
	db $fd, $fa, $fd, $fa, $7e, $fd, $fe, $fd, $de, $fd, $ee, $fd, $f6, $fd, $fe, $f9
	db $fb, $fc, $fd, $fe, $fe, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $aa, $aa, $54, $55
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $fd, $fe, $ff, $ff, $ff, $ff, $3d, $c3, $c7, $f8, $f5, $fa, $f9, $ff
	db $fe, $fd, $fe, $fd, $fc, $ff, $ff, $fe, $ff, $f8, $ff, $e0, $c0, $ff, $e7, $f8
	db $fb, $f5, $f7, $fc, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $3f, $ff, $1f, $ff
	db $3f, $ff, $ff, $ff, $ff, $ff, $ff, $47, $ff, $ff, $fe, $9f, $fe, $ff, $fc, $ff
	db $f9, $fe, $67, $f8, $ff, $80, $fc, $c3, $c1, $fe, $e6, $f9, $f9, $e6, $f3, $ed
	db $f7, $eb, $f7, $eb, $67, $df, $67, $df, $e7, $5f, $e7, $1f, $de, $2f, $dc, $2b
	db $ff, $07, $ff, $1f, $bf, $7f, $bf, $7f, $bf, $7f, $bf, $7f, $aa, $2a, $15, $55
	db $00, $00, $c0, $00, $f8, $00, $fc, $00, $fe, $00, $fe, $01, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $9f, $e0, $e7, $f8, $f3, $fc, $b1, $7e, $f0, $0f, $fc, $03
	db $de, $a1, $cf, $b0, $25, $da, $55, $aa, $d2, $2d, $d2, $2d, $37, $c8, $0f, $f0
	db $8d, $72, $84, $fb, $64, $fb, $c4, $fb, $c1, $fe, $81, $fe, $86, $f8, $86, $f8
	db $8e, $f0, $0c, $f0, $1c, $e0, $18, $e0, $38, $c0, $38, $c0, $68, $90, $e8, $10
	db $c4, $38, $d4, $28, $a4, $58, $4a, $b4, $90, $6e, $79, $9e, $f9, $7e, $fc, $ff
	db $fc, $ff, $fc, $ff, $f9, $fe, $f6, $f9, $c9, $f7, $b7, $cf, $5f, $bf, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $aa, $aa, $55, $55
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $80, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00
	db $80, $00, $80, $00, $00, $80, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00
	db $80, $00, $80, $00, $80, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $e0, $00
	db $d8, $20, $c7, $38, $c0, $3f, $40, $bf, $c0, $bf, $c0, $bf, $c0, $bf, $c0, $bf
	db $c0, $bf, $c0, $bf, $80, $ff, $80, $ff, $80, $ff, $80, $d5, $00, $aa, $00, $50
	db $00, $00, $00, $00, $c0, $00, $10, $e8, $0c, $f0, $03, $fc, $03, $fc, $03, $fc
	db $03, $fc, $01, $fc, $02, $fc, $00, $f4, $02, $f8, $00, $d4, $00, $a8, $00, $50
	db $00, $00, $00, $00, $00, $01, $00, $03, $02, $01, $02, $01, $00, $07, $00, $07
	db $04, $03, $04, $03, $04, $03, $04, $03, $06, $01, $03, $00, $01, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $02, $0f, $1c, $7f, $fd, $ff
	db $b9, $bf, $5e, $5b, $2e, $2b, $57, $51, $29, $22, $07, $17, $02, $02, $01, $01
	db $00, $00, $00, $00, $00, $07, $00, $0f, $10, $0f, $20, $1f, $20, $1f, $40, $3f
	db $80, $7f, $80, $7f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $01, $fe
	db $01, $fe, $03, $fc, $07, $f8, $0e, $f1, $19, $e7, $37, $cf, $ef, $1f, $29, $1f
	db $14, $3b, $16, $09, $05, $1e, $0b, $05, $0f, $06, $04, $0f, $0f, $1f, $0f, $1f
	db $1e, $0f, $1e, $0f, $1e, $0f, $0f, $07, $0b, $07, $05, $03, $03, $05, $02, $01
	db $01, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $01, $0d, $03, $7f, $0b, $3f, $fb, $7b, $f6, $ff, $f4, $ff, $e8
	db $fe, $e1, $bd, $d3, $db, $37, $fb, $e7, $eb, $17, $fa, $fd, $aa, $aa, $55, $55
	db $00, $00, $00, $00, $00, $c0, $00, $f8, $07, $f8, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $1f, $e0, $3f, $c0, $7e, $81, $fb, $07, $ef, $1f
	db $cf, $3f, $9f, $7f, $ff, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $7f, $fe, $3a, $fd, $bd, $7e, $fe, $3f, $fe, $3f, $bf, $7f, $ff, $7f, $7f, $ff
	db $ff, $ff, $f8, $ff, $f3, $fc, $7f, $80, $bf, $ff, $ff, $ff, $ff, $ff, $d7, $e8
	db $df, $ff, $71, $ff, $70, $ff, $ff, $7f, $ff, $7f, $7f, $3f, $3f, $00, $1b, $3c
	db $7f, $9f, $bf, $df, $ef, $df, $df, $ef, $ef, $f7, $db, $37, $e5, $1b, $3a, $c5
	db $e6, $f9, $fb, $fc, $f8, $ff, $fb, $ff, $ff, $ff, $ff, $ff, $af, $00, $55, $55
	db $00, $00, $00, $00, $00, $00, $00, $00, $87, $00, $70, $8f, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $0f, $f0, $fe, $01, $ff, $00, $fd, $fe, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $00, $ff, $fb, $fc, $ff, $ff, $fe, $ff, $ee, $f3, $86, $f9
	db $88, $77, $2e, $df, $fd, $03, $79, $cf, $3a, $e7, $fe, $ff, $fe, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $3f, $ff, $9e, $7f, $ec, $df, $fc, $ef, $f4, $ff, $b4, $7f
	db $d8, $bf, $f8, $ff, $f8, $ff, $f0, $ff, $f7, $f8, $ef, $f0, $ff, $00, $fe, $01
	db $78, $87, $f7, $f8, $cf, $ff, $ff, $bf, $df, $af, $4b, $b7, $c6, $79, $c1, $7e
	db $c0, $7f, $67, $ff, $ff, $ff, $fe, $ff, $fa, $fd, $bb, $c7, $aa, $2a, $55, $55
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $60, $00, $f0, $00, $f0, $08, $f0
	db $00, $fc, $00, $fe, $c1, $3e, $01, $fe, $03, $fc, $ff, $00, $ef, $f0, $c1, $fe
	db $c0, $ff, $80, $ff, $00, $ff, $e0, $1f, $3c, $c3, $03, $ec, $1e, $ef, $0b, $f7
	db $0f, $ff, $1d, $ff, $3f, $ff, $3f, $df, $3e, $dd, $3c, $db, $1c, $eb, $0c, $f3
	db $0c, $f3, $05, $fa, $05, $fa, $0e, $f1, $04, $fb, $05, $fa, $15, $ea, $14, $ea
	db $36, $c8, $36, $c8, $34, $c8, $e4, $18, $c4, $38, $c7, $38, $8c, $73, $1c, $e7
	db $68, $9f, $70, $ff, $e0, $ff, $e1, $fe, $e3, $fd, $e7, $fb, $ef, $f7, $ff, $0f
	db $7f, $9f, $ed, $be, $ee, $b1, $ff, $1e, $de, $e1, $ef, $f3, $6a, $8a, $55, $55
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $80, $00, $80, $00, $80, $00, $80, $00, $c0, $00
	db $00, $c0, $00, $c0, $40, $80, $40, $80, $40, $80, $c0, $00, $40, $80, $c0, $80
	db $00, $c0, $c0, $80, $00, $c0, $00, $c0, $00, $c0, $40, $80, $40, $80, $40, $80
	db $c0, $00, $c0, $00, $40, $80, $00, $80, $80, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $c0, $00
	db $a0, $40, $30, $c8, $c7, $38, $00, $ff, $81, $fe, $fe, $f9, $fb, $f7, $f7, $ef
	db $ef, $df, $df, $bf, $bf, $7f, $bf, $7f, $ff, $bf, $ff, $bf, $8a, $aa, $14, $55
	db $00, $00, $00, $00, $00, $00, $c0, $00, $9e, $60, $03, $fc, $00, $ff, $f0, $ff
	db $ff, $ff, $fc, $fd, $fa, $f8, $f4, $f1, $e0, $ea, $40, $54, $a0, $a8, $50, $40
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

SECTION "analyzed_0ae010", ROMX[$6010], BANK[$2b]

Data_2b_6010:
	db $00, $00, $a2, $21, $cb, $36, $7d, $5b, $00, $00, $4d, $2d, $9b, $02, $7f, $4b
	db $00, $00, $cc, $34, $b9, $35, $bf, $4a, $00, $00, $2c, $31, $6b, $66, $57, $7f
	db $00, $00, $d0, $20, $36, $32, $7c, $57, $00, $00, $e9, $24, $d3, $59, $bc, $56
	db $39, $47, $71, $8f, $72, $8f, $e6, $1d, $c4, $3f, $c8, $3f, $88, $77, $91, $6e
	db $cd, $ff, $db, $ff, $b7, $ff, $af, $ff, $5f, $ff, $bf, $ff, $7f, $ff, $20, $ff
	db $c0, $ff, $1f, $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $00, $ff, $00, $00, $ff
	db $ff, $02, $ff, $02, $7f, $82, $fd, $02, $fd, $02, $fd, $06, $f7, $0c, $fb, $0c
	db $df, $28, $a7, $58, $77, $98, $5f, $b0, $ef, $30, $bf, $60, $5a, $e5, $f7, $c9
	db $b5, $cb, $6e, $93, $ca, $37, $dd, $27, $b9, $4e, $6b, $9e, $77, $9c, $d6, $3d
	db $ef, $39, $8c, $73, $db, $76, $bf, $e4, $b7, $ec, $7f, $c8, $66, $99, $ff, $91
	db $dd, $33, $fe, $23, $9c, $67, $74, $cf, $f8, $8f, $e8, $9f, $f1, $1f, $d1, $3f
	db $1c, $23, $5c, $23, $38, $47, $71, $8e, $71, $8e, $e2, $1d, $e6, $1b, $c6, $3b
	db $8c, $77, $99, $6f, $1a, $ef, $34, $df, $64, $bf, $60, $bf, $c1, $7e, $83, $fc
	db $87, $78, $08, $f7, $08, $f7, $10, $ef, $20, $df, $42, $bd, $84, $7b, $00, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $06, $ff
	db $00, $ff, $bf, $ff, $00, $ff, $0f, $f0, $00, $ff, $ff, $00, $ff, $00, $00, $ff
	db $fe, $11, $ff, $10, $ff, $08, $ff, $08, $ff, $08, $ff, $08, $ff, $04, $ff, $04
	db $ff, $04, $ff, $04, $ff, $02, $ff, $02, $ff, $02, $7f, $82, $ff, $e2, $f9, $f6
	db $7f, $cc, $f7, $9d, $ef, $31, $be, $63, $fc, $47, $7c, $c7, $f8, $8f, $f8, $8f
	db $f0, $1f, $d1, $3f, $e3, $3f, $c3, $7f, $47, $ff, $87, $ff, $8f, $ff, $0e, $ff
	db $e1, $1e, $c3, $3d, $c6, $3b, $86, $7b, $8c, $77, $19, $ef, $19, $ef, $33, $df
	db $67, $bf, $46, $bf, $8c, $7f, $9c, $ff, $11, $fe, $23, $fc, $47, $f8, $88, $f7
	db $80, $ff, $11, $ee, $23, $dc, $4e, $b0, $1d, $00, $01, $00, $fc, $00, $ff, $00
	db $00, $ff, $00, $ff, $f0, $ff, $ff, $ff, $ff, $ff, $0f, $ff, $92, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $e0, $ff, $00, $ff
	db $00, $ff, $ff, $ff, $00, $ff, $ff, $00, $00, $ff, $ff, $00, $ff, $00, $00, $ff
	db $35, $ff, $b1, $7f, $b1, $7f, $9a, $7f, $98, $7f, $58, $3f, $49, $3f, $4d, $3f
	db $4c, $3f, $34, $1f, $36, $1f, $16, $0f, $16, $2f, $3a, $47, $3b, $47, $7b, $87
	db $70, $8f, $f0, $0f, $e0, $1f, $e0, $1f, $c1, $3f, $83, $7d, $87, $7b, $06, $fb
	db $0c, $f7, $1c, $ef, $18, $ef, $31, $df, $62, $bf, $66, $bf, $c4, $7f, $88, $ff
	db $90, $ff, $31, $ff, $21, $ff, $43, $ff, $c3, $ff, $87, $ff, $83, $ff, $05, $ff
	db $03, $ff, $07, $f8, $82, $7f, $f9, $07, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $7f, $80, $3f, $c0, $0f, $70, $07, $f8, $03, $fc, $00, $ff, $00, $01, $ff, $00
	db $00, $ff, $00, $ff, $03, $ff, $ff, $ff, $ff, $ff, $44, $ff, $30, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $ff, $00, $ff
	db $00, $ff, $ff, $ff, $00, $ff, $ff, $00, $00, $ff, $ff, $00, $ff, $00, $00, $ff
	db $00, $00, $00, $00, $80, $80, $80, $80, $80, $80, $c0, $c0, $40, $c0, $40, $c0
	db $60, $e0, $a0, $e0, $a0, $e0, $30, $f0, $50, $f0, $58, $f8, $18, $f8, $28, $f8
	db $2c, $fc, $2c, $fc, $94, $fc, $96, $fe, $82, $fc, $1a, $fc, $11, $fe, $21, $fe
	db $41, $fe, $c3, $ff, $87, $ff, $0f, $ff, $1f, $ff, $1f, $ff, $3f, $ff, $7f, $ff
	db $ff, $ff, $ff, $df, $f3, $0f, $fb, $ff, $ff, $ff, $2f, $ff, $f8, $2f, $ff, $ff
	db $ff, $ff, $a7, $df, $7f, $87, $f1, $ff, $7f, $ff, $df, $3f, $ff, $0f, $ff, $07
	db $ff, $03, $fd, $03, $ff, $01, $ff, $01, $ff, $01, $ff, $01, $fd, $03, $fb, $07
	db $ef, $1f, $2f, $ff, $1f, $ff, $27, $ff, $0f, $ff, $63, $9f, $21, $df, $17, $ff
	db $0b, $ff, $07, $ff, $09, $ff, $02, $ff, $04, $ff, $01, $fe, $ff, $00, $00, $ff
	db $47, $bf, $80, $ff, $3f, $ff, $c1, $3f, $00, $ff, $ff, $00, $ff, $00, $00, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $40
	db $00, $c0, $20, $c0, $00, $e0, $80, $e0, $90, $e0, $a0, $f0, $c8, $f0, $c8, $f0
	db $e4, $f8, $e4, $f8, $ea, $fc, $f2, $fc, $f2, $fc, $f5, $fe, $f9, $fe, $fb, $fe
	db $fa, $ff, $fc, $ff, $fd, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $7f, $f8, $07, $2f, $c0
	db $e3, $ff, $fc, $ff, $87, $ff, $f8, $ff, $00, $ff, $ff, $00, $ff, $00, $15, $ea
	db $80, $00, $80, $00, $40, $80, $40, $80, $e0, $80, $a0, $c0, $20, $c0, $70, $c0
	db $50, $e0, $90, $e0, $a8, $f0, $a8, $f0, $dc, $f0, $d4, $f8, $d4, $f8, $ee, $f8
	db $ea, $fc, $f7, $fc, $f5, $fe, $f5, $fe, $fb, $fe, $fa, $ff, $f9, $ff, $fd, $ff
	db $fd, $ff, $fd, $ff, $fc, $ff, $fe, $ff, $ff, $ff, $fe, $ff, $7f, $ff, $8f, $7f
	db $60, $9f, $8c, $73, $73, $8c, $e6, $19, $ff, $00, $00, $00, $00, $00, $aa, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $80, $00, $c0, $00, $c0
	db $40, $80, $e0, $80, $e0, $80, $e0, $40, $70, $c0, $50, $e0, $78, $e0, $b8, $e0
	db $3c, $f0, $1c, $f0, $66, $98, $0f, $f0, $bc, $40, $01, $00, $00, $00, $ab, $00
	db $01, $00, $03, $00, $03, $00, $03, $00, $02, $01, $01, $03, $03, $03, $02, $03
	db $03, $02, $01, $02, $01, $02, $03, $00, $03, $00, $02, $01, $03, $01, $03, $01
	db $03, $01, $00, $01, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $00, $00
	db $00, $00, $00, $00, $1f, $20, $20, $20, $20, $20, $20, $20, $00, $20, $00, $20
	db $00, $10, $00, $10, $10, $10, $10, $10, $90, $10, $10, $90, $90, $10, $10, $10
	db $10, $10, $10, $10, $10, $10, $08, $10, $10, $08, $10, $08, $00, $08, $00, $08
	db $00, $08, $00, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $04, $08
	db $00, $0c, $08, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $02, $04, $04, $02, $04, $02, $02, $02, $22, $02
	db $43, $33, $a0, $40, $00, $c0, $40, $87, $8f, $00, $b7, $0f, $21, $1e, $43, $1c
	db $b8, $5f, $f5, $5b, $f8, $47, $fc, $53, $d0, $6f, $3f, $60, $4f, $30, $3c, $03
	db $00, $00, $00, $00, $80, $00, $00, $7f, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $01, $00, $06, $03, $0c, $04, $07, $0e, $1b, $09, $00, $10, $00, $10
	db $19, $10, $1f, $0f, $04, $08, $0c, $04, $07, $03, $03, $01, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $0d, $0e, $0e, $0f, $0f, $05, $04, $04, $0c, $04, $1f, $0f
	db $34, $18, $68, $30, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07
	db $e0, $f8, $00, $00, $00, $00, $00, $ff, $ff, $00, $ff, $ff, $80, $7f, $00, $ff
	db $40, $ff, $1f, $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $00, $ff, $00, $00, $ff
	db $00, $00, $00, $00, $00, $00, $00, $ff, $00, $00, $00, $00, $00, $00, $02, $01
	db $3c, $1f, $d1, $e0, $87, $33, $06, $cc, $5c, $38, $f8, $f0, $f5, $7b, $6d, $3e
	db $3c, $f0, $60, $90, $09, $10, $bf, $6f, $44, $86, $8f, $8b, $f9, $70, $1e, $0f
	db $01, $00, $00, $00, $00, $00, $0c, $78, $00, $00, $7c, $3b, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $80, $00, $f9, $ff, $44, $32, $39, $1b, $c3, $b8
	db $f8, $7f, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $37, $c8
	db $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $00, $ff, $ff, $00, $ff, $00, $ff
	db $00, $ff, $ff, $ff, $00, $ff, $00, $ff, $00, $ff, $ff, $00, $ff, $00, $00, $ff
	db $00, $00, $00, $00, $00, $00, $0b, $f4, $00, $00, $00, $00, $00, $00, $e1, $fe
	db $f0, $98, $80, $e0, $d5, $e3, $2a, $1c, $43, $20, $bc, $7f, $b2, $fc, $06, $01
	db $00, $00, $00, $00, $60, $fb, $40, $86, $02, $01, $80, $00, $34, $f8, $89, $07
	db $ff, $ff, $00, $00, $00, $00, $da, $7e, $00, $00, $f9, $fe, $00, $00, $00, $00
	db $bd, $7f, $00, $00, $00, $00, $00, $00, $1e, $ff, $b4, $0c, $28, $9c, $14, $af
	db $0b, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff
	db $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $00, $ff, $ff, $1f, $e0, $00, $ff
	db $00, $ff, $ff, $ff, $00, $ff, $7f, $80, $00, $ff, $ff, $00, $ff, $00, $00, $ff
	db $00, $00, $00, $00, $00, $00, $0f, $f0, $00, $00, $00, $00, $00, $00, $d0, $20
	db $2f, $1c, $02, $01, $a0, $c0, $00, $00, $c3, $fc, $82, $01, $00, $00, $10, $e0
	db $06, $18, $00, $00, $40, $80, $40, $30, $04, $08, $80, $00, $04, $03, $fe, $ff
	db $e8, $f0, $00, $00, $00, $00, $88, $fd, $00, $00, $bf, $a7, $00, $00, $00, $00
	db $cb, $3f, $00, $00, $00, $00, $00, $00, $1f, $ff, $82, $31, $f7, $ee, $40, $a6
	db $03, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff
	db $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $00, $ff, $ff, $ff, $00, $00, $ff
	db $00, $ff, $ff, $ff, $00, $ff, $ff, $00, $00, $ff, $ff, $00, $ff, $00, $00, $ff
	db $00, $00, $00, $00, $0c, $03, $00, $f0, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $e0, $80, $58, $20, $14, $08, $0a, $04, $87, $82, $02, $03, $03, $01
	db $01, $01, $02, $03, $03, $02, $04, $06, $0e, $0c, $34, $38, $d0, $e0, $80, $00
	db $00, $00, $00, $00, $00, $00, $18, $b9, $00, $00, $f4, $92, $00, $00, $00, $00
	db $80, $c0, $00, $00, $00, $00, $00, $00, $c3, $ff, $30, $62, $3a, $bb, $26, $0f
	db $bf, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $34, $cb
	db $60, $9c, $e4, $f8, $9c, $e2, $ec, $f2, $56, $e8, $fe, $01, $ff, $00, $00, $ff
	db $00, $ff, $ff, $ff, $00, $ff, $ff, $03, $00, $ff, $ff, $00, $ff, $00, $00, $ff
	db $f8, $00, $f8, $00, $fc, $e0, $fc, $20, $ec, $10, $fe, $10, $fe, $10, $fe, $10
	db $10, $08, $00, $08, $00, $08, $08, $04, $00, $04, $00, $04, $00, $04, $04, $02
	db $00, $02, $00, $02, $02, $01, $00, $01, $00, $01, $00, $01, $01, $00, $00, $00
	db $00, $00, $00, $00, $2c, $1c, $5c, $3c, $fc, $e8, $08, $08, $0c, $88, $5e, $3c
	db $eb, $c6, $05, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $40, $bf
	db $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $00, $ff, $ff, $ff, $00, $00, $ff
	db $fc, $03, $00, $ff, $ff, $00, $07, $f8, $ff, $00, $00, $00, $00, $00, $ff, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $80, $00, $80, $00, $c0, $00
	db $c0, $00, $c0, $00, $e0, $00, $e0, $00, $e0, $00, $f0, $00, $f0, $80, $f0, $80
	db $f8, $80, $f8, $80, $78, $c0, $f8, $40, $fc, $40, $bc, $60, $fc, $20, $fe, $20
	db $fe, $20, $de, $30, $ff, $10, $ff, $10, $ef, $18, $ff, $08, $ff, $08, $ff, $08
	db $08, $04, $80, $04, $c0, $04, $24, $02, $00, $02, $00, $02, $02, $00, $02, $81
	db $1e, $7f, $00, $00, $00, $00, $00, $ff, $ff, $00, $fe, $ff, $ff, $00, $00, $ff
	db $ff, $00, $00, $ff, $f3, $0c, $e6, $19, $ff, $00, $00, $00, $00, $00, $ff, $00
	db $c0, $00, $c0, $00, $c0, $00, $c0, $00, $e0, $00, $e0, $00, $e0, $00, $f0, $00
	db $f0, $00, $f0, $00, $f8, $00, $f8, $f0, $10, $e0, $d0, $e0, $f0, $e8, $d0, $e8
	db $00, $00, $00, $01, $00, $01, $00, $03, $00, $03, $00, $03, $00, $07, $00, $07
	db $00, $07, $00, $0f, $0c, $03, $03, $0c, $09, $06, $06, $01, $01, $00, $00, $00
	db $00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $03, $00, $03, $00, $03, $00
	db $07, $00, $07, $00, $07, $00, $0f, $00, $0f, $00, $1f, $00, $1f, $00, $1e, $01
	db $3e, $01, $3e, $01, $3c, $03, $7c, $03, $7c, $03, $78, $07, $f8, $07, $f8, $07
	db $f2, $0f, $f2, $0f, $f4, $0f, $e5, $1f, $e5, $1f, $e5, $1f, $cb, $3f, $cb, $3f
	db $c7, $3f, $80, $7f, $c0, $3f, $71, $0e, $14, $03, $81, $00, $60, $00, $18, $00
	db $19, $06, $06, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $1d, $03, $1d, $03, $3d, $03, $39, $07, $38, $07, $7a, $07, $7a, $07, $f4, $0f
	db $f4, $0f, $f5, $0f, $e9, $1f, $e9, $1f, $eb, $1f, $cb, $3f, $d3, $3f, $d7, $3f
	db $97, $7f, $a7, $7f, $a7, $7f, $af, $7f, $2f, $ff, $4f, $ff, $5f, $ff, $5f, $ff
	db $9f, $ff, $bf, $ff, $3f, $ff, $3f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $1f, $ff, $00, $ff, $18, $e7, $c3, $3c, $34, $cb, $4f, $30, $13, $0c
	db $fb, $07, $1e, $e1, $8f, $70, $67, $18, $19, $06, $06, $01, $01, $00, $00, $00
	db $3f, $ff, $3f, $ff, $7e, $ff, $7e, $ff, $7d, $fe, $7d, $fe, $ff, $fc, $ff, $fc
	db $fb, $fc, $fb, $fc, $ff, $f8, $ff, $f8, $f7, $f8, $f7, $f8, $ff, $f0, $ff, $f0
	db $ef, $f0, $f7, $f8, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $fe, $fd, $fe, $f9
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $fe, $ff, $ff, $ff, $7f, $ff, $03, $ff, $c0, $3f, $7c, $83, $07, $f8, $c1, $3e
	db $0f, $ff, $c3, $ff, $b0, $7f, $cc, $3f, $f3, $0f, $7c, $83, $9f, $60, $67, $18
	db $19, $06, $06, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $e7, $1f, $fe, $01, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $e7, $18, $f9, $06, $fe, $01, $ff, $00, $ff, $00, $fc, $00, $c0, $00, $00, $00
	db $c0, $00, $f8, $00, $7f, $80, $df, $e0, $fd, $fe, $ff, $ff, $ff, $1f, $7b, $87
	db $e3, $fc, $fc, $ff, $fe, $ff, $ff, $ff, $f7, $ff, $f1, $ff, $f7, $fe, $ff, $ff
	db $f7, $ff, $d7, $f8, $fa, $fd, $ce, $3f, $53, $af, $db, $e4, $ff, $fc, $ff, $7e
	db $e7, $1f, $3f, $c7, $ff, $fe, $ff, $ff, $ff, $ff, $1f, $ff, $c7, $3f, $f0, $0f
	db $7e, $81, $0f, $f0, $13, $ec, $cc, $33, $b3, $4c, $68, $97, $de, $21, $37, $08
	db $f2, $0f, $79, $87, $9c, $63, $61, $1e, $19, $06, $06, $01, $01, $00, $00, $00
	db $e0, $e0, $f8, $f8, $ff, $ff, $7f, $ff, $ef, $1f, $fb, $07, $ff, $00, $ff, $00
	db $3d, $c0, $7b, $80, $fa, $00, $f6, $00, $e6, $00, $6d, $00, $4d, $00, $1b, $00
	db $19, $00, $38, $00, $80, $00, $e0, $00, $ff, $00, $bf, $c0, $f7, $f8, $fd, $fe
	db $cf, $3f, $27, $df, $fe, $01, $e6, $f9, $f9, $fe, $ff, $ff, $bf, $5f, $bf, $c3
	db $e7, $f8, $fd, $fe, $7e, $8f, $f7, $8f, $c7, $f9, $7d, $fe, $ff, $3f, $57, $af
	db $fd, $e3, $ff, $fc, $fd, $3e, $cf, $3f, $9b, $e7, $ef, $f1, $f8, $ff, $fd, $fe
	db $1f, $ff, $8f, $7f, $e3, $1f, $f8, $07, $3e, $c1, $9f, $60, $67, $98, $91, $6e
	db $13, $ff, $84, $ff, $61, $ff, $98, $7f, $e6, $1f, $79, $87, $9c, $63, $67, $18
	db $19, $06, $06, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $e0, $e0, $f8, $f8, $fe, $fe, $7f, $ff, $df, $3f
	db $7f, $0f, $7b, $07, $ee, $01, $e7, $00, $c3, $3c, $f0, $0f, $d4, $03, $d7, $00
	db $df, $00, $57, $00, $2f, $00, $2f, $00, $33, $00, $81, $00, $c0, $00, $f0, $00
	db $78, $80, $de, $e0, $f7, $f8, $fb, $7c, $fe, $3f, $6f, $9f, $93, $ef, $ee, $f1
	db $7e, $f9, $ff, $7e, $cf, $3f, $fd, $c3, $fb, $f5, $fd, $7a, $fe, $1f, $0f, $f7
	db $f7, $f9, $fe, $79, $ff, $3e, $7f, $8f, $a7, $db, $f3, $fc, $fc, $3f, $fe, $0f
	db $c7, $bf, $d9, $f7, $ff, $fc, $fe, $ff, $7e, $ff, $1f, $ff, $87, $7f, $e1, $1f
	db $70, $8f, $3c, $c3, $9e, $61, $ef, $10, $d7, $28, $7d, $82, $bf, $40, $ef, $10
	db $cc, $3f, $71, $8f, $9c, $63, $67, $18, $18, $07, $06, $01, $01, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $c0, $c0
	db $f0, $f0, $f8, $f8, $fc, $fc, $7e, $fe, $df, $3f, $ef, $1f, $3f, $c7, $3f, $c3
	db $1e, $e1, $df, $20, $ff, $00, $bf, $40, $cf, $30, $f3, $0c, $fb, $04, $7f, $00
	db $7f, $00, $3f, $00, $9f, $00, $ef, $00, $ff, $00, $bf, $c0, $ff, $e0, $f7, $f8
	db $7b, $fc, $fd, $3e, $ff, $1e, $9f, $ef, $ef, $f7, $f1, $7f, $ff, $3f, $9f, $ff
	db $ff, $df, $f3, $7f, $59, $bf, $ff, $1f, $b7, $cf, $e3, $ff, $ff, $7f, $7f, $bf
	db $4f, $bf, $d7, $ef, $ff, $77, $df, $3f, $6f, $9f, $cf, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $3f, $ff, $1f, $ff, $0f, $ff, $87, $7f, $e3, $1f, $71, $8f, $b8, $47
	db $03, $ff, $01, $ff, $40, $ff, $10, $ff, $04, $ff, $21, $df, $98, $67, $66, $19
	db $13, $0c, $0c, $03, $03, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $e0, $e0, $f0, $f0
	db $f8, $f8, $78, $f8, $fc, $7e, $fe, $7f, $fc, $7f, $fe, $7f, $fc, $7f, $fe, $7f
	db $fc, $7f, $7e, $ff, $7c, $ff, $7e, $ff, $7c, $ff, $7e, $ff, $fc, $ff, $fe, $ff
	db $f8, $ff, $fc, $ff, $f8, $ff, $fc, $ff, $f8, $ff, $fc, $ff, $f8, $ff, $fc, $ff
	db $f8, $ff, $fd, $fe, $f8, $ff, $fd, $fe, $f8, $ff, $fd, $fe, $f8, $ff, $fd, $fe
	db $f8, $ff, $f1, $fe, $eb, $fc, $f1, $fe, $eb, $fc, $f1, $fe, $eb, $fc, $f1, $fe
	db $e3, $fc, $e1, $fe, $d3, $fc, $e1, $fe, $d3, $fc, $a5, $fa, $d3, $fc, $a5, $fa
	db $53, $fc, $25, $fa, $93, $7c, $c5, $3a, $db, $24, $ed, $12, $37, $c8, $83, $7c
	db $9c, $7f, $86, $7f, $41, $be, $30, $cf, $dc, $63, $36, $19, $1b, $07, $07, $00
	db $0f, $3f, $1f, $7f, $3f, $ff, $3f, $ff, $3f, $ff, $bf, $7f, $bf, $7f, $bf, $7f
	db $bf, $7f, $bf, $7f, $bf, $7f, $bf, $7f, $bf, $7f, $bf, $7f, $bf, $7f, $bf, $7f
	db $ab, $5f, $c7, $3f, $ab, $5f, $d7, $2f, $ab, $5f, $d7, $2f, $aa, $5f, $cd, $32
	db $3a, $07, $3a, $07, $3a, $07, $3a, $07, $3a, $07, $3a, $07, $3a, $07, $3a, $07
	db $3a, $07, $3a, $07, $3a, $07, $3a, $07, $3a, $07, $3a, $07, $3a, $07, $3a, $07
	db $07, $3f, $27, $1f, $37, $0f, $37, $0f, $1d, $03, $1d, $03, $0a, $05, $0e, $01
	db $0d, $02, $07, $00, $07, $00, $02, $01, $03, $00, $03, $00, $01, $00, $01, $00
	db $be, $ff, $bf, $ff, $bf, $ff, $bf, $ff, $bf, $ff, $bf, $ff, $bf, $ff, $bf, $ff
	db $bf, $ff, $bf, $ff, $bf, $ff, $bf, $ff, $bf, $ff, $bf, $ff, $bf, $ff, $bf, $ff
	db $bf, $ff, $3f, $ff, $1f, $ff, $8f, $7f, $47, $bf, $23, $df, $13, $ef, $09, $f7
	db $a0, $5f, $a4, $5b, $92, $6d, $59, $26, $4c, $33, $a4, $1b, $a6, $19, $66, $19
	db $ac, $5f, $ee, $1f, $d6, $2f, $57, $2f, $6b, $17, $2b, $17, $3b, $07, $35, $0b
	db $15, $0b, $1a, $05, $0a, $05, $0e, $01, $0d, $02, $05, $02, $06, $01, $02, $01
	db $03, $00, $03, $00, $01, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $e7, $00, $f3, $80, $f1, $c0, $d8, $e0, $ec, $f0, $f6, $f8, $db, $3c, $4f, $bc
	db $df, $ee, $d6, $ef, $eb, $f7, $ff, $f3, $ff, $f9, $cf, $f8, $f5, $ee, $eb, $f6
	db $3e, $f9, $8f, $f9, $fd, $ce, $fd, $e6, $3b, $f6, $90, $ff, $ab, $dd, $df, $ed
	db $f5, $ee, $7e, $f7, $7f, $fb, $39, $ff, $9f, $7d, $cc, $3f, $ee, $1f, $67, $9f
	db $33, $cf, $3b, $c7, $99, $67, $99, $67, $9c, $63, $4c, $b3, $6e, $91, $46, $b9
	db $66, $99, $26, $d9, $13, $ec, $13, $ec, $89, $76, $89, $76, $44, $3b, $44, $3b
	db $c4, $3b, $a4, $1b, $a2, $1d, $52, $0d, $52, $0d, $31, $0e, $29, $06, $29, $06
	db $6a, $17, $2b, $17, $35, $0b, $35, $0b, $1d, $03, $1a, $05, $0a, $05, $0d, $02
	db $0d, $02, $06, $01, $06, $01, $02, $01, $03, $00, $03, $00, $01, $00, $01, $00
	db $7c, $0c, $74, $0c, $78, $04, $fa, $06, $fe, $02, $5c, $02, $0c, $02, $0e, $00
	db $8e, $00, $8e, $00, $cf, $01, $ef, $81, $a6, $c1, $f6, $c1, $d7, $e0, $fb, $60
	db $fb, $60, $eb, $30, $7f, $b0, $f7, $b8, $bf, $d8, $bf, $48, $ab, $5c, $df, $2c
	db $b7, $ec, $7d, $86, $df, $76, $77, $9e, $d6, $af, $fb, $af, $5b, $ff, $d7, $6f
	db $8d, $77, $35, $df, $a5, $df, $db, $ef, $dd, $e7, $ef, $f7, $67, $ff, $69, $f7
	db $39, $f7, $31, $ff, $37, $fb, $11, $ff, $19, $ff, $99, $7f, $99, $7f, $8d, $7f
	db $cf, $3f, $4f, $bf, $4f, $bf, $4f, $bf, $27, $df, $27, $df, $27, $df, $17, $ef
	db $13, $ef, $93, $6f, $93, $6f, $83, $7f, $4b, $b7, $49, $b7, $49, $b7, $c9, $37
	db $a5, $5b, $a5, $5b, $65, $1b, $55, $2b, $b0, $0f, $b2, $0d, $52, $0d, $5a, $05
	db $d5, $2f, $d9, $27, $7d, $13, $2e, $19, $16, $0d, $0d, $03, $03, $00, $01, $00
	db $8f, $bf, $9f, $ff, $bf, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $bf, $ff, $bf, $ff
	db $bf, $ff, $bf, $ff, $bf, $ff, $bf, $ff, $bf, $ff, $9f, $ff, $bf, $ff, $9f, $ff
	db $bf, $ff, $9f, $ff, $bf, $ff, $9f, $ff, $bf, $ff, $9f, $ff, $bf, $ff, $9f, $ff
	db $af, $ff, $9f, $ff, $8f, $ff, $9f, $ff, $8f, $ff, $9f, $ff, $8f, $ff, $97, $ff
	db $8f, $ff, $97, $ff, $8f, $ff, $97, $ff, $cf, $bf, $97, $ff, $8f, $ff, $c7, $bf
	db $ab, $df, $c5, $bf, $a3, $df, $45, $bf, $63, $9f, $45, $bf, $62, $9f, $55, $af
	db $62, $9f, $55, $af, $62, $9f, $55, $af, $6a, $97, $51, $af, $62, $9f, $5d, $a2
	db $80, $ff, $85, $fb, $18, $e7, $0c, $f3, $3b, $c7, $6d, $9e, $e7, $f8, $e0, $1f
	db $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $01, $00, $03, $00, $03, $00, $07, $00, $07, $00, $0f, $01, $0f, $01, $1e, $01
	db $1f, $02, $1f, $02, $37, $0c, $37, $0c, $67, $19, $6f, $11, $de, $21, $dd, $22
	db $df, $22, $bf, $42, $bb, $47, $f9, $46, $fb, $44, $ff, $45, $fe, $47, $fb, $46
	db $fd, $43, $ff, $40, $ff, $40, $9f, $60, $df, $60, $df, $60, $9f, $60, $9f, $60
	db $9f, $60, $9f, $60, $9f, $60, $9f, $60, $9f, $60, $9f, $60, $9f, $60, $9f, $60
	db $bf, $40, $df, $20, $df, $21, $df, $21, $de, $21, $de, $21, $dd, $23, $df, $23
	db $de, $23, $df, $22, $db, $24, $df, $24, $df, $25, $dd, $23, $df, $23, $df, $22
	db $dd, $22, $dd, $22, $df, $24, $da, $25, $df, $29, $d5, $2a, $5e, $b1, $4a, $b5
	db $54, $ab, $f5, $0b, $e9, $17, $f7, $0f, $d7, $2f, $ee, $1f, $ae, $5f, $dc, $3f
	db $68, $9f, $e5, $1b, $98, $67, $be, $61, $5c, $33, $4f, $38, $3d, $0e, $0c, $03
	db $db, $24, $ff, $44, $ff, $48, $fe, $99, $f7, $9a, $f5, $3a, $ff, $34, $ef, $74
	db $fb, $64, $df, $68, $ef, $d8, $fe, $d9, $97, $f8, $fe, $b3, $ff, $e4, $fb, $ec
	db $ff, $9d, $ff, $93, $fe, $b7, $7e, $fb, $b5, $da, $7b, $9c, $d7, $38, $6c, $f3
	db $f8, $07, $f9, $06, $f9, $06, $fb, $04, $e7, $18, $e7, $19, $ae, $53, $de, $23
	db $dc, $27, $bd, $47, $73, $8e, $eb, $1e, $f7, $1c, $c6, $39, $ef, $39, $dc, $73
	db $9f, $f2, $bb, $e6, $3f, $c4, $73, $cc, $fe, $89, $ef, $99, $dd, $33, $fe, $23
	db $45, $22, $03, $44, $87, $48, $17, $88, $0e, $91, $0c, $13, $1c, $23, $18, $27
	db $20, $20, $30, $00, $00, $20, $38, $08, $00, $20, $40, $10, $00, $20, $48, $18
	db $00, $20, $50, $20, $00, $20, $58, $28, $00, $20, $60, $30, $00, $20, $68, $38
	db $00, $30, $30, $02, $00, $30, $38, $0a, $00, $30, $40, $12, $00, $30, $48, $1a
	db $00, $30, $50, $22, $00, $30, $58, $2a, $00, $30, $60, $32, $00, $30, $68, $3a
	db $00, $40, $30, $04, $00, $40, $38, $0c, $00, $40, $40, $14, $00, $40, $48, $1c
	db $00, $40, $50, $24, $00, $40, $58, $2c, $00, $40, $60, $34, $00, $40, $68, $3c
	db $00, $50, $30, $06, $00, $50, $38, $0e, $00, $50, $40, $16, $00, $50, $48, $1e
	db $00, $50, $50, $26, $00, $50, $58, $2e, $00, $50, $60, $36, $00, $50, $68, $3e
	db $00, $19, $20, $38, $04, $00, $20, $40, $0c, $00, $20, $48, $14, $00, $20, $50
	db $1c, $00, $20, $58, $24, $00, $20, $60, $2c, $00, $30, $38, $06, $00, $30, $40
	db $0e, $00, $30, $48, $16, $00, $30, $50, $1e, $00, $30, $58, $26, $00, $30, $60
	db $2e, $00, $40, $30, $00, $00, $40, $38, $08, $00, $40, $40, $10, $00, $40, $48
	db $18, $00, $40, $50, $20, $00, $40, $58, $28, $00, $50, $30, $02, $00, $50, $38
	db $0a, $00, $50, $40, $12, $00, $50, $48, $1a, $00, $50, $50, $22, $00, $50, $58
	db $2a, $00, $50, $60, $30, $00, $1a, $30, $18, $32, $04, $30, $20, $38, $04, $30
	db $28, $40, $04, $30, $30, $48, $04, $30, $38, $50, $04, $30, $40, $58, $04, $30
	db $48, $60, $04, $40, $18, $34, $04, $40, $20, $3a, $04, $40, $28, $42, $04, $40
	db $30, $4a, $04, $40, $38, $52, $04, $40, $40, $5a, $04, $40, $48, $62, $04, $50
	db $20, $3c, $04, $50, $28, $44, $04, $50, $30, $4c, $04, $50, $38, $54, $04, $50
	db $40, $5c, $04, $60, $18, $36, $04, $60, $20, $3e, $04, $60, $28, $46, $04, $60
	db $30, $4e, $04, $60, $38, $56, $04, $60, $40, $5e, $04, $60, $48, $64, $04, $17
	db $30, $58, $8a, $21, $30, $60, $82, $21, $30, $68, $7a, $21, $30, $70, $72, $21
	db $30, $78, $6a, $21, $40, $58, $8c, $21, $40, $60, $84, $21, $40, $68, $7c, $21
	db $40, $70, $74, $21, $40, $78, $6c, $21, $40, $80, $66, $21, $50, $58, $8e, $21
	db $50, $60, $86, $21, $50, $68, $7e, $21, $50, $70, $76, $21, $50, $78, $6e, $21
	db $60, $50, $92, $21, $60, $58, $90, $21, $60, $60, $88, $21, $60, $68, $80, $21
	db $60, $70, $78, $21, $60, $78, $70, $21, $60, $80, $68, $21, $16, $20, $18, $96
	db $02, $20, $20, $9e, $02, $20, $28, $a6, $02, $20, $30, $ae, $02, $20, $38, $b6
	db $02, $30, $18, $98, $02, $30, $20, $a0, $02, $30, $28, $a8, $02, $30, $30, $b0
	db $02, $30, $38, $b8, $02, $40, $18, $9a, $02, $40, $20, $a2, $02, $40, $28, $aa
	db $02, $40, $30, $b2, $02, $40, $38, $ba, $02, $50, $10, $94, $02, $50, $18, $9c
	db $02, $50, $20, $a4, $02, $50, $28, $ac, $02, $50, $30, $b4, $02, $50, $38, $bc
	db $02, $50, $40, $be, $02, $17, $20, $60, $c4, $03, $20, $68, $cc, $03, $20, $70
	db $d4, $03, $20, $78, $dc, $03, $20, $80, $e4, $03, $28, $58, $c0, $03, $30, $60
	db $c6, $03, $30, $68, $ce, $03, $30, $70, $d6, $03, $30, $78, $de, $03, $30, $80
	db $e6, $03, $40, $60, $c8, $03, $40, $68, $d0, $03, $40, $70, $d8, $03, $40, $78
	db $e0, $03, $40, $80, $e8, $03, $50, $58, $c2, $03, $50, $60, $ca, $03, $50, $68
	db $d2, $03, $50, $70, $da, $03, $50, $78, $e2, $03, $50, $80, $ea, $03, $50, $88
	db $ec, $03, $02, $11

Data_2b_72a4:
	db $ca, $72, $a8, $72

Data_2b_72a8:
	db $0f, $11, $b0, $03, $99, $02, $04, $b8, $c0, $c8, $d0, $d8, $e0, $e8, $f0, $f8
	db $f9, $81, $89, $0a, $99, $a1, $a9, $b1, $b9, $13, $00, $d1, $d9, $e1, $e9, $f1
	db $d9, $f1, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $02, $11

Data_2b_72ee:
	db $14, $73, $f2, $72

Data_2b_72f2:
	db $12, $13, $00, $06, $04, $c0, $0f, $b8, $0e, $06, $b8, $00, $0c, $e8, $f0, $f8
	db $f9, $00, $89, $08, $16, $a9, $12, $04, $d9, $d9, $d9, $d1, $d9, $e1, $e9, $f1
	db $d9, $f1, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $02, $11

Data_2b_7338:
	db $5e, $73, $3c, $73

Data_2b_733c:
	db $04, $03, $08, $13, $c0, $0f, $b8, $0e, $06, $b8, $00, $0c, $e8, $e8, $f0, $f8
	db $f9, $07, $89, $14, $02, $07, $08, $03, $00, $d9, $d9, $d1, $d9, $e1, $e9, $f1
	db $d9, $f1, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $02, $11

Data_2b_7382:
	db $a8, $73, $86, $73

Data_2b_7386:
	db $12, $02, $11, $08, $0f, $13, $c0, $0f, $b8, $0e, $06, $b8, $00, $0c, $f0, $f8
	db $f9, $18, $89, $07, $00, $0c, $00, $03, $00, $d9, $d9, $d1, $d9, $e1, $e9, $f1
	db $d9, $f1, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $02, $11

Data_2b_73cc:
	db $f2, $73, $d0, $73

Data_2b_73d0:
	db $12, $02, $04, $0d, $04, $c0, $0f, $b8, $0e, $06, $b8, $00, $0c, $f0, $f0, $f8
	db $f9, $0a, $89, $0d, $00, $06, $00, $08, $d9, $d9, $d9, $d1, $d9, $e1, $e9, $f1
	db $d9, $f1, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $02, $11

Data_2b_7416:
	db $3c, $74, $1a, $74

Data_2b_741a:
	db $02, $07, $00, $b8, $00, $02, $13, $04, $b8, $d9, $03, $04, $12, $08, $06, $0d
	db $f9, $0c, $89, $0a, $0e, $0c, $00, $13, $12, $14, $d1, $d9, $d9, $e1, $e9, $f1
	db $d9, $f1, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $02, $11

Data_2b_7460:
	db $86, $74, $64, $74

Data_2b_7464:
	db $12, $13, $00, $06, $04, $d1, $06, $11, $00, $0f, $07, $08, $02, $e9, $e9, $f8
	db $f9, $12, $89, $0e, $06, $00, $16, $00, $d9, $d9, $d9, $d1, $d9, $e1, $e9, $f1
	db $d9, $f1, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $02, $11

Data_2b_74aa:
	db $d0, $74, $ae, $74

Data_2b_74ae:
	db $0c, $0e, $0d, $12, $13, $04, $11, $d1, $06, $11, $00, $0f, $07, $08, $02, $f8
	db $f9, $13, $89, $07, $0e, $11, $08, $14, $02, $07, $08, $d1, $d9, $e1, $e9, $f1
	db $d9, $f1, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $02, $11

Data_2b_74f4:
	db $1a, $75, $f8, $74

Data_2b_74f8:
	db $02, $07, $00, $b8, $00, $02, $13, $04, $b8, $d9, $06, $11, $00, $0f, $07, $08
	db $02, $12, $89, $18, $0e, $12, $07, $08, $0a, $00, $16, $00, $d9, $e1, $e9, $f1
	db $d9, $f1, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $02, $11

Data_2b_753e:
	db $64, $75, $42, $75

Data_2b_7542:
	db $12, $0e, $14, $0d, $03, $d9, $03, $04, $12, $08, $06, $0d, $f9, $f9, $f9, $f9
	db $f9, $0a, $89, $13, $00, $0d, $00, $0a, $00, $d1, $d9, $d1, $d9, $e1, $e9, $f1
	db $d9, $f1, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $02, $11

Data_2b_7588:
	db $ae, $75, $8c, $75

Data_2b_758c:
	db $80, $88, $90, $98, $a0, $a8, $b0, $b8, $c0, $c8, $d1, $d1, $f9, $f9, $f9, $f9
	db $f9, $81, $89, $91, $99, $a1, $a9, $b1, $b9, $c1, $c9, $d1, $d9, $e1, $e9, $f1
	db $d9, $f1, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $04, $10

Data_2b_75d2:
	db $16, $76, $d6, $75

Data_2b_75d6:
	db $e2, $ea, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $1b, $1c, $f2, $38, $24, $20, $31, $32, $f2, $21, $24, $25, $2e, $31, $24, $f2
	db $0c, $2e, $2d, $32, $33, $24, $31, $ea, $11, $20, $2d, $22, $27, $24, $31, $1a
	db $e2, $ea, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $04, $10

Data_2b_7658:
	db $9c, $76, $5c, $76

Data_2b_765c:
	db $e2, $ea, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $08, $2d, $f2, $20, $ea, $27, $2e, $2b, $38, $f2, $2f, $2b, $20, $22, $24, $f2
	db $2e, $35, $24, $31, $ea, $0c, $33, $1a, $12, $24, $2a, $28, $33, $2e, $21, $20
	db $e2, $ea, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $04, $10

Data_2b_76de:
	db $22, $77, $e2, $76

Data_2b_76e2:
	db $e2, $ea, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $12, $33, $2e, $2e, $23, $e2, $20, $ea, $33, $20, $2b, $2b, $1d, $ea, $ea, $f2
	db $36, $27, $28, $33, $24, $e2, $33, $2e, $36, $24, $31, $1a, $e2, $e2, $e2, $e2
	db $e2, $ea, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $04, $10

Data_2b_7764:
	db $a8, $77, $68, $77

Data_2b_7768:
	db $e2, $ea, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $08, $33, $f2, $36, $20, $32, $e2, $32, $20, $28, $23, $e2, $33, $27, $20, $33
	db $e2, $e2, $e2, $e2, $e2, $e2, $e2, $e2, $e2, $e2, $e2, $e2, $e2, $e2, $e2, $e2
	db $e2, $ea, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $04, $10

Data_2b_77ea:
	db $2e, $78, $ee, $77

Data_2b_77ee:
	db $e2, $ea, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $13, $27, $24, $e2, $33, $2e, $36, $24, $31, $e2, $27, $24, $2b, $23, $e2, $20
	db $25, $20, $21, $2b, $24, $23, $e2, $2c, $2e, $2d, $32, $33, $24, $31, $1a, $e2
	db $e2, $f2, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $04, $10

Data_2b_7870:
	db $b4, $78, $74, $78

Data_2b_7874:
	db $e2, $ea, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $0c, $20, $2d, $38, $ea, $2f, $24, $2e, $2f, $2b, $24, $e2, $ea, $ea, $e2, $ea
	db $26, $20, $33, $27, $24, $31, $24, $23, $f2, $25, $2e, $31, $ea, $ea, $ea, $e2
	db $e2, $f2, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $04, $10

Data_2b_78f6:
	db $3a, $79, $fa, $78

Data_2b_78fa:
	db $e2, $ea, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $33, $27, $24, $e2, $2f, $2e, $36, $24, $31, $e2, $2e, $25, $e2, $ea, $e2, $ea
	db $33, $27, $24, $f2, $2c, $2e, $2d, $32, $33, $24, $31, $1a, $e2, $e2, $e2, $e2
	db $e2, $f2, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $04, $10

Data_2b_797c:
	db $c0, $79, $80, $79

Data_2b_7980:
	db $e2, $ea, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $00, $ea, $32, $33, $34, $23, $24, $2d, $33, $e2, $36, $24, $2d, $33, $e2, $ea
	db $33, $2e, $e2, $33, $27, $24, $e2, $33, $2e, $36, $24, $31, $e2, $e2, $e2, $e2
	db $e2, $f2, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $04, $10

Data_2b_7a02:
	db $46, $7a, $06, $7a

Data_2b_7a06:
	db $e2, $ea, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $33, $2e, $e2, $36, $31, $28, $33, $24, $f2, $27, $28, $32, $ea, $ea, $e2, $ea
	db $25, $28, $2d, $20, $2b, $e2, $2f, $20, $2f, $24, $31, $1a, $e2, $e2, $e2, $e2
	db $e2, $f2, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $04, $10

Data_2b_7a88:
	db $cc, $7a, $8c, $7a

Data_2b_7a8c:
	db $e2, $ea, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $07, $28, $32, $e2, $2d, $20, $2c, $24, $f2, $36, $20, $32, $ea, $ea, $e2, $ea
	db $02, $2e, $37, $e2, $20, $2d, $23, $ea, $27, $24, $1e, $32, $e2, $e2, $e2, $e2
	db $e2, $f2, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $04, $10

Data_2b_7b0e:
	db $52, $7b, $12, $7b

Data_2b_7b12:
	db $e2, $ea, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $25, $31, $2e, $2c, $ea, $01, $20, $33, $33, $2b, $24, $ea, $ea, $ea, $e2, $ea
	db $02, $20, $31, $23, $32, $1a, $e2, $ea, $e2, $e2, $e2, $e2, $e2, $e2, $e2, $e2
	db $e2, $f2, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $04, $10

Data_2b_7b94:
	db $d8, $7b, $98, $7b

Data_2b_7b98:
	db $e2, $ea, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $13, $27, $28, $32, $e2, $36, $20, $32, $ea, $21, $24, $25, $2e, $31, $24, $ea
	db $e2, $e2, $e2, $e2, $e2, $e2, $e2, $ea, $e2, $e2, $e2, $e2, $e2, $e2, $e2, $e2
	db $e2, $f2, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $04, $10

Data_2b_7c1a:
	db $5e, $7c, $1e, $7c

Data_2b_7c1e:
	db $e2, $ea, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $02, $2e, $37, $ea, $21, $24, $22, $20, $2c, $24, $e2, $e2, $e2, $e2, $e2, $ea
	db $20, $2d, $e2, $20, $23, $35, $24, $2d, $33, $34, $31, $24, $31, $1a, $e2, $e2
	db $e2, $f2, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $04, $10

Data_2b_7ca0:
	db $e4, $7c, $a4, $7c

Data_2b_7ca4:
	db $e2, $ea, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $13, $27, $24, $ea, $24, $37, $22, $28, $33, $28, $2d, $26, $e2, $e2, $e2, $ea
	db $29, $2e, $34, $31, $2d, $24, $38, $e2, $2c, $20, $23, $24, $ea, $ea, $e2, $e2
	db $e2, $f2, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $04, $10

Data_2b_7d26:
	db $6a, $7d, $2a, $7d

Data_2b_7d2a:
	db $e2, $ea, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $84, $8c, $94, $9c, $a4, $ac, $b4, $bc, $c4, $cc, $d4, $e2, $e2, $e2, $e2, $ea
	db $85, $8d, $95, $9d, $a5, $ad, $b5, $bd, $c5, $cd, $d5, $e2, $ea, $ea, $e2, $e2
	db $e2, $f2, $f2, $e2, $ea, $e2, $e2, $ea, $f2, $e2, $ea, $e2, $ea, $e2, $ea, $f2
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08

SECTION "analyzed_0b4145", ROMX[$4145], BANK[$2d]

Data_2d_4145:
	db $aa, $2e, $aa, $d5, $27, $55, $45, $ba, $aa, $55, $75, $aa, $ab, $aa, $aa, $55
	db $15, $55, $55, $ba, $8a, $aa, $aa, $97, $91, $0e, $a2, $5f, $e5, $05, $55, $ab
	db $22, $aa, $aa, $5d, $15, $54, $51, $ba, $aa, $d5, $54, $a9, $ba, $aa, $aa, $11
	db $57, $54, $55, $ab, $ab, $aa, $aa, $47, $45, $ac, $aa, $d5, $c6, $d7, $61, $a3
	db $ea, $af, $c0, $55, $15, $7d, $45, $8a, $72, $51, $7d, $aa, $a2, $ea, $aa, $48
	db $15, $d5, $55, $cb, $aa, $aa, $aa, $f7, $74, $ba, $aa, $d1, $55, $b5, $0d, $2a
	db $e2, $ea, $8a, $75, $45, $dd, $dd, $aa, $b8, $55, $54, $aa, $be, $aa, $aa, $47
	db $77, $55, $55, $28, $a2, $a8, $2a, $c5, $77, $23, $ba, $15, $61, $55, $55, $6a
	db $ea, $8b, $aa, $10, $55, $55, $d5, $aa, $bb, $55, $55, $a8, $eb, $aa, $ba, $55
	db $75, $54, $55, $9e, $ae, $ae, $aa, $55, $58, $ea, $aa, $d7, $45, $15, $50, $8a
	db $ab, $aa, $8a, $55, $b5, $4d, $55, $ea, $a8, $55, $55, $a2, $8a, $aa, $8a, $75
	db $d7, $55, $51, $aa, $8a, $ba, $a8, $15, $17, $a2, $aa, $55, $55, $65, $41, $aa
	db $2a, $ba, $a3, $55, $25, $55, $57, $aa, $9a, $75, $55, $aa, $af, $aa, $82, $55
	db $55, $57, $55, $ab, $aa, $ba, $2a, $54, $55, $aa, $aa, $57, $15, $55, $5d, $aa
	db $8a, $ae, $ea, $55, $55, $55, $55, $aa, $bb, $45, $55, $aa, $b2, $aa, $ea, $5a
	db $5d, $41, $55, $02, $ab, $a8, $aa, $33, $55, $ec, $ae, $40, $45, $55, $5d, $aa

SECTION "analyzed_0b45cf", ROMX[$45cf], BANK[$2d]

Data_2d_45cf:
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0b4814", ROMX[$4814], BANK[$2d]

Data_2d_4814:
	db $aa, $2e, $aa, $d5, $27, $55, $45, $ba, $aa, $57, $75, $aa, $ab, $aa, $aa, $55
	db $15, $55, $55, $fa, $8a, $aa, $aa, $97, $91, $0e, $a2, $5d, $e5, $05, $55, $ab
	db $a2, $aa, $aa, $15, $35, $54, $d1, $ba, $aa, $d5, $54, $ad, $ba, $aa, $aa, $11
	db $57, $54, $55, $ab, $ab, $aa, $aa, $4f, $45, $a8, $aa, $d5, $c6, $d7, $61, $a3
	db $ea, $af, $40, $55, $57, $7c, $45, $8a, $72, $51, $79, $aa, $a2, $aa, $aa, $4c
	db $15, $d5, $55, $9b, $aa, $aa, $aa, $f7, $74, $ba, $aa, $d1, $55, $b5, $0d, $2a
	db $e2, $ea, $8a, $75, $45, $dd, $dd, $aa, $b8, $55, $54, $aa, $be, $ba, $aa, $45
	db $77, $55, $55, $2a, $a2, $aa, $2a, $c5, $77, $23, $ba, $17, $61, $55, $55, $2a
	db $ea, $8b, $aa, $14, $55, $55, $d5, $aa, $bb, $55, $55, $a8, $ab, $aa, $ba, $55
	db $75, $54, $55, $ba, $ae, $af, $aa, $55, $d8, $aa, $aa, $d7, $4f, $15, $50, $8a
	db $ab, $aa, $8a, $55, $b5, $4d, $55, $aa, $ac, $55, $55, $a2, $8a, $aa, $8a, $75
	db $d7, $57, $51, $aa, $0a, $aa, $e8, $15, $17, $02, $aa, $55, $55, $64, $61, $a8
	db $2a, $ba, $a3, $55, $25, $55, $57, $aa, $9a, $75, $55, $aa, $ab, $aa, $82, $55
	db $55, $57, $55, $ab, $aa, $ba, $2a, $75, $55, $aa, $aa, $57, $15, $55, $5d, $aa
	db $8a, $ae, $ea, $55, $55, $55, $55, $aa, $bb, $45, $55, $8a, $b2, $aa, $ea, $5a
	db $5d, $51, $55, $02, $ab, $a8, $aa, $33, $55, $ed, $ae, $c0, $05, $55, $5d, $aa

SECTION "analyzed_0b4a59", ROMX[$4a59], BANK[$2d]

Data_2d_4a59:
	db $aa, $2e, $aa, $d5, $27, $55, $45, $ba, $aa, $57, $75, $aa, $ab, $aa, $aa, $55
	db $15, $55, $55, $fa, $8a, $aa, $aa, $97, $91, $0e, $a2, $5d, $e5, $05, $55, $ab
	db $a2, $aa, $aa, $15, $35, $54, $d1, $ba, $aa, $d5, $54, $ad, $ba, $aa, $aa, $11
	db $57, $54, $55, $ab, $ab, $aa, $aa, $4f, $45, $a8, $aa, $d5, $c6, $d7, $61, $a3
	db $ea, $af, $40, $55, $57, $7c, $45, $8a, $72, $51, $79, $aa, $a2, $aa, $aa, $4c
	db $15, $d5, $55, $9b, $aa, $aa, $aa, $f7, $74, $ba, $aa, $d1, $55, $b5, $0d, $2a
	db $e2, $ea, $8a, $75, $45, $dd, $dd, $aa, $b8, $55, $54, $aa, $be, $ba, $aa, $45
	db $77, $55, $55, $2a, $a2, $aa, $2a, $c5, $77, $23, $ba, $17, $61, $55, $55, $2a
	db $ea, $8b, $aa, $14, $55, $55, $d5, $aa, $bb, $55, $55, $a8, $ab, $aa, $ba, $55
	db $75, $54, $55, $ba, $ae, $af, $aa, $55, $d8, $aa, $aa, $d7, $4f, $15, $50, $8a
	db $ab, $aa, $8a, $55, $b5, $4d, $55, $aa, $ac, $55, $55, $a2, $8a, $aa, $8a, $75
	db $d7, $57, $51, $aa, $0a, $aa, $e8, $15, $17, $02, $aa, $55, $55, $64, $61, $a8
	db $2a, $ba, $a3, $55, $25, $55, $57, $aa, $9a, $75, $55, $aa, $ab, $aa, $82, $55
	db $55, $57, $55, $ab, $aa, $ba, $2a, $75, $55, $aa, $aa, $57, $15, $55, $5d, $aa
	db $8a, $ae, $ea, $55, $55, $55, $55, $aa, $bb, $45, $55, $8a, $b2, $aa, $ea, $5a
	db $5d, $51, $55, $02, $ab, $a8, $aa, $33, $55, $ed, $ae, $c0, $05, $55, $5d, $aa

SECTION "analyzed_0b4c9e", ROMX[$4c9e], BANK[$2d]

Data_2d_4c9e:
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0b536d", ROMX[$536d], BANK[$2d]

Data_2d_536d:
	db $00, $00, $04, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $40, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00

SECTION "analyzed_0b55b2", ROMX[$55b2], BANK[$2d]

Data_2d_55b2:
	db $aa, $2e, $aa, $d5, $27, $55, $55, $ba, $aa, $57, $75, $aa, $ab, $aa, $aa, $55
	db $15, $55, $55, $aa, $8a, $aa, $aa, $97, $91, $0e, $a2, $1f, $e5, $05, $55, $ab
	db $a2, $aa, $aa, $55, $35, $54, $d1, $ba, $aa, $d5, $74, $a9, $ba, $aa, $aa, $15
	db $57, $54, $55, $ab, $ab, $aa, $aa, $5f, $45, $ac, $aa, $d5, $c6, $d7, $61, $a3
	db $ea, $af, $40, $55, $17, $7c, $45, $8a, $72, $51, $7d, $aa, $a2, $aa, $aa, $4c
	db $15, $d5, $55, $8b, $aa, $aa, $aa, $f7, $54, $ba, $aa, $d1, $55, $b5, $0d, $2a
	db $e2, $ea, $ce, $75, $45, $dd, $dd, $aa, $b8, $55, $54, $aa, $be, $aa, $aa, $45
	db $77, $55, $55, $a8, $a2, $a8, $2a, $c5, $77, $23, $ba, $17, $61, $55, $55, $2a
	db $ea, $8b, $aa, $10, $55, $55, $55, $aa, $bb, $55, $55, $a8, $ab, $aa, $ba, $55
	db $75, $44, $55, $9e, $ae, $af, $aa, $55, $58, $aa, $aa, $d7, $47, $15, $50, $8a
	db $ab, $aa, $8a, $55, $b5, $45, $55, $ea, $ac, $55, $55, $a2, $8a, $aa, $aa, $35
	db $d7, $57, $51, $aa, $0a, $aa, $a8, $15, $57, $22, $aa, $55, $55, $65, $41, $aa
	db $2a, $ba, $a3, $75, $05, $55, $57, $aa, $98, $75, $55, $ea, $af, $aa, $82, $55
	db $55, $57, $55, $ab, $aa, $ba, $2a, $54, $55, $aa, $aa, $55, $15, $55, $5d, $aa
	db $8a, $ae, $ea, $55, $55, $55, $55, $2a, $bb, $45, $55, $aa, $a2, $aa, $ea, $5a
	db $5d, $51, $55, $02, $ab, $a8, $aa, $33, $55, $e9, $ae, $44, $45, $5d, $5d, $aa

SECTION "analyzed_0b57f7", ROMX[$57f7], BANK[$2d]

Data_2d_57f7:
	db $aa, $2e, $aa, $d5, $27, $55, $55, $ba, $aa, $57, $75, $aa, $ab, $aa, $aa, $55
	db $15, $55, $55, $aa, $8a, $aa, $aa, $97, $91, $0e, $a2, $1f, $e5, $05, $55, $ab
	db $a2, $aa, $aa, $55, $35, $54, $d1, $ba, $aa, $d5, $74, $a9, $ba, $aa, $aa, $15
	db $57, $54, $55, $ab, $ab, $aa, $aa, $5f, $45, $ac, $aa, $d5, $c6, $d7, $61, $a3
	db $ea, $af, $40, $55, $17, $7c, $45, $8a, $72, $51, $7d, $aa, $a2, $aa, $aa, $4c
	db $15, $d5, $55, $8b, $aa, $aa, $aa, $f7, $54, $ba, $aa, $d1, $55, $b5, $0d, $2a
	db $e2, $ea, $ce, $75, $45, $dd, $dd, $aa, $b8, $55, $54, $aa, $be, $aa, $aa, $45
	db $77, $55, $55, $a8, $a2, $a8, $2a, $c5, $77, $23, $ba, $17, $61, $55, $55, $2a
	db $ea, $8b, $aa, $10, $55, $55, $55, $aa, $bb, $55, $55, $a8, $ab, $aa, $ba, $55
	db $75, $44, $55, $9e, $ae, $af, $aa, $55, $58, $aa, $aa, $d7, $47, $15, $50, $8a
	db $ab, $aa, $8a, $55, $b5, $45, $55, $ea, $ac, $55, $55, $a2, $8a, $aa, $aa, $35
	db $d7, $57, $51, $aa, $0a, $aa, $a8, $15, $57, $22, $aa, $55, $55, $65, $41, $aa
	db $2a, $ba, $a3, $75, $05, $55, $57, $aa, $98, $75, $55, $ea, $af, $aa, $82, $55
	db $55, $57, $55, $ab, $aa, $ba, $2a, $54, $55, $aa, $aa, $55, $15, $55, $5d, $aa
	db $8a, $ae, $ea, $55, $55, $55, $55, $2a, $bb, $45, $55, $aa, $a2, $aa, $ea, $5a
	db $5d, $51, $55, $02, $ab, $a8, $aa, $33, $55, $e9, $ae, $44, $45, $5d, $5d, $aa

SECTION "analyzed_0b5a3c", ROMX[$5a3c], BANK[$2d]

Data_2d_5a3c:
	db $00, $01, $01, $00, $00, $00, $0e, $11, $20, $20, $20, $20, $20, $20, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20
	db $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20

SECTION "analyzed_0b5c81", ROMX[$5c81], BANK[$2d]

Data_2d_5c81:
	db $a2, $0e, $aa, $d4, $27, $15, $45, $ba, $a8, $57, $75, $aa, $ab, $aa, $aa, $55
	db $15, $55, $55, $a8, $8b, $aa, $aa, $b7, $91, $4e, $a2, $1d, $e5, $05, $55, $ab
	db $22, $ea, $aa, $9d, $05, $54, $d1, $ba, $aa, $d5, $74, $a9, $3a, $ba, $aa, $11
	db $57, $54, $55, $8a, $ab, $aa, $aa, $73, $45, $ac, $aa, $55, $c6, $d7, $61, $a3
	db $ee, $af, $40, $55, $17, $7d, $45, $8a, $72, $51, $79, $aa, $a2, $ea, $aa, $4c
	db $05, $d5, $55, $8b, $a2, $a8, $aa, $f7, $54, $ba, $aa, $d1, $15, $b5, $8d, $2a
	db $f2, $ee, $ca, $75, $45, $dd, $dd, $aa, $b8, $56, $50, $aa, $be, $ba, $aa, $45
	db $77, $95, $55, $a8, $a2, $88, $2a, $c5, $77, $2b, $ba, $17, $60, $55, $4d, $6e
	db $ea, $8b, $aa, $10, $55, $54, $d4, $aa, $b9, $51, $55, $a8, $ea, $a8, $ba, $55
	db $75, $44, $55, $9a, $ae, $bf, $aa, $55, $d8, $ea, $aa, $d7, $67, $15, $50, $9a
	db $bb, $aa, $8a, $55, $b5, $4d, $dd, $e2, $b8, $55, $55, $a2, $8a, $ab, $8a, $75
	db $d7, $57, $51, $aa, $88, $ba, $e8, $15, $17, $02, $aa, $55, $55, $74, $61, $a8
	db $2a, $ba, $a3, $75, $25, $55, $57, $aa, $9c, $75, $55, $aa, $af, $aa, $82, $55
	db $55, $57, $55, $2b, $aa, $ba, $2a, $55, $55, $aa, $aa, $17, $1d, $51, $5d, $a2
	db $8a, $af, $ea, $55, $55, $5d, $55, $28, $bb, $45, $55, $aa, $9a, $aa, $ee, $5a
	db $5d, $45, $55, $00, $ab, $a8, $aa, $31, $55, $ed, $ae, $4c, $05, $55, $5d, $aa

SECTION "analyzed_0b5ec6", ROMX[$5ec6], BANK[$2d]

Data_2d_5ec6:
	db $a2, $0e, $aa, $d4, $27, $15, $45, $ba, $a8, $57, $75, $aa, $ab, $aa, $aa, $55
	db $15, $55, $55, $a8, $8b, $aa, $aa, $b7, $91, $4e, $a2, $1d, $e5, $05, $55, $ab
	db $22, $ea, $aa, $9d, $05, $54, $d1, $ba, $aa, $d5, $74, $a9, $3a, $ba, $aa, $11
	db $57, $54, $55, $8a, $ab, $aa, $aa, $73, $45, $ac, $aa, $55, $c6, $d7, $61, $a3
	db $ee, $af, $40, $55, $17, $7d, $45, $8a, $72, $51, $79, $aa, $a2, $ea, $aa, $4c
	db $05, $d5, $55, $8b, $a2, $a8, $aa, $f7, $54, $ba, $aa, $d1, $15, $b5, $8d, $2a
	db $f2, $ee, $ca, $75, $45, $dd, $dd, $aa, $b8, $56, $50, $aa, $be, $ba, $aa, $45
	db $77, $95, $55, $a8, $a2, $88, $2a, $c5, $77, $2b, $ba, $17, $60, $55, $4d, $6e
	db $ea, $8b, $aa, $10, $55, $54, $d4, $aa, $b9, $51, $55, $a8, $ea, $a8, $ba, $55
	db $75, $44, $55, $9a, $ae, $bf, $aa, $55, $d8, $ea, $aa, $d7, $67, $15, $50, $9a
	db $bb, $aa, $8a, $55, $b5, $4d, $dd, $e2, $b8, $55, $55, $a2, $8a, $ab, $8a, $75
	db $d7, $57, $51, $aa, $88, $ba, $e8, $15, $17, $02, $aa, $55, $55, $74, $61, $a8
	db $2a, $ba, $a3, $75, $25, $55, $57, $aa, $9c, $75, $55, $aa, $af, $aa, $82, $55
	db $55, $57, $55, $2b, $aa, $ba, $2a, $55, $55, $aa, $aa, $17, $1d, $51, $5d, $a2
	db $8a, $af, $ea, $55, $55, $5d, $55, $28, $bb, $45, $55, $aa, $9a, $aa, $ee, $5a
	db $5d, $45, $55, $00, $ab, $a8, $aa, $31, $55, $ed, $ae, $4c, $05, $55, $5d, $aa

SECTION "analyzed_0b610b", ROMX[$610b], BANK[$2d]

Data_2d_610b:
	db $00, $00, $00, $00, $04, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $40, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $40, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $02, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $bf, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0b6350", ROMX[$6350], BANK[$2d]

Data_2d_6350:
	db $aa, $2e, $aa, $d5, $27, $55, $55, $ba, $aa, $57, $75, $aa, $ab, $aa, $aa, $55
	db $15, $55, $55, $aa, $8a, $aa, $aa, $97, $91, $0e, $a2, $5f, $e5, $05, $55, $ab
	db $a2, $aa, $aa, $55, $35, $54, $d1, $ba, $aa, $55, $54, $a9, $ba, $aa, $aa, $11
	db $57, $54, $55, $ab, $ab, $aa, $aa, $5d, $45, $ac, $aa, $55, $c6, $d7, $61, $a2
	db $ea, $af, $40, $55, $17, $7d, $45, $8a, $72, $51, $59, $aa, $a2, $aa, $aa, $4c
	db $15, $d5, $55, $8b, $aa, $aa, $aa, $f7, $74, $ba, $aa, $d1, $55, $b5, $0d, $2a
	db $e2, $ea, $8a, $75, $45, $dd, $dd, $aa, $b8, $55, $55, $aa, $be, $aa, $aa, $47
	db $77, $55, $55, $28, $aa, $a8, $2a, $c5, $75, $23, $ba, $17, $61, $55, $5d, $ee
	db $ea, $8b, $aa, $10, $55, $55, $d5, $aa, $bb, $51, $55, $a8, $ee, $aa, $ba, $55
	db $75, $54, $55, $ba, $ae, $af, $aa, $55, $58, $ea, $aa, $d7, $47, $15, $50, $8a
	db $ab, $aa, $8a, $55, $b5, $4d, $55, $aa, $b8, $55, $55, $a2, $8a, $aa, $8a, $75
	db $d7, $57, $51, $aa, $0a, $aa, $e8, $15, $57, $a2, $aa, $55, $55, $64, $61, $aa
	db $2a, $aa, $a3, $55, $25, $55, $57, $aa, $9a, $75, $55, $aa, $af, $aa, $82, $55
	db $55, $57, $55, $ab, $aa, $ba, $2a, $55, $55, $aa, $aa, $57, $15, $55, $5d, $aa
	db $8a, $ae, $ea, $55, $55, $55, $55, $2a, $bb, $45, $55, $aa, $a2, $aa, $ea, $5a
	db $5d, $51, $55, $02, $ab, $a8, $aa, $33, $55, $e8, $ae, $44, $45, $55, $55, $aa

SECTION "analyzed_0b6595", ROMX[$6595], BANK[$2d]

Data_2d_6595:
	db $01, $10, $02, $01, $04, $08, $00, $0c, $20, $01, $00, $00, $00, $00, $10, $12
	db $01, $10, $02, $01, $04, $08, $00, $0c, $20, $01, $00, $00, $00, $00, $10, $12
	db $01, $10, $02, $01, $04, $08, $00, $0c, $20, $01, $00, $00, $00, $00, $10, $12
	db $01, $10, $02, $01, $04, $08, $00, $0c, $20, $01, $00, $00, $00, $00, $10, $12
	db $01, $10, $02, $01, $04, $08, $00, $0c, $20, $01, $00, $00, $00, $00, $10, $12
	db $01, $10, $02, $01, $04, $08, $00, $0c, $20, $01, $00, $00, $00, $00, $10, $12
	db $01, $10, $02, $01, $04, $08, $00, $0c, $20, $01, $00, $00, $00, $00, $10, $12
	db $01, $10, $02, $01, $04, $08, $00, $0c, $20, $01, $00, $00, $00, $00, $10, $12
	db $01, $10, $02, $01, $04, $08, $00, $0c, $20, $01, $00, $00, $00, $00, $10, $12
	db $01, $10, $02, $01, $04, $08, $00, $0c, $20, $01, $00, $00, $00, $00, $10, $12
	db $01, $10, $02, $01, $04, $08, $00, $0c, $20, $01, $00, $00, $00, $00, $10, $12
	db $01, $10, $02, $01, $04, $08, $00, $0c, $20, $01, $00, $00, $00, $00, $10, $12
	db $01, $10, $02, $01, $04, $08, $00, $0c, $20, $01, $00, $00, $00, $00, $10, $12
	db $01, $10, $02, $01, $04, $08, $00, $0c, $20, $01, $00, $00, $00, $00, $10, $12
	db $01, $10, $02, $01, $04, $08, $00, $0c, $20, $01, $00, $00, $00, $00, $10, $12
	db $01, $10, $02, $01, $04, $08, $00, $0c, $20, $01, $00, $00, $00, $00, $10, $12

SECTION "analyzed_0b67da", ROMX[$67da], BANK[$2d]

Data_2d_67da:
	db $aa, $2e, $aa, $d5, $27, $55, $55, $ba, $aa, $57, $75, $aa, $ab, $aa, $aa, $55
	db $15, $55, $55, $aa, $8a, $aa, $aa, $97, $91, $0e, $a2, $5f, $e5, $05, $55, $ab
	db $a2, $aa, $aa, $55, $35, $54, $d1, $ba, $aa, $55, $54, $a9, $ba, $aa, $aa, $11
	db $57, $54, $55, $ab, $ab, $aa, $aa, $5d, $45, $ac, $aa, $55, $c6, $d7, $61, $a2
	db $ea, $af, $40, $55, $17, $7d, $45, $8a, $72, $51, $59, $aa, $a2, $aa, $aa, $4c
	db $15, $d5, $55, $8b, $aa, $aa, $aa, $f7, $74, $ba, $aa, $d1, $55, $b5, $0d, $2a
	db $e2, $ea, $8a, $75, $45, $dd, $dd, $aa, $b8, $55, $55, $aa, $be, $aa, $aa, $47
	db $77, $55, $55, $28, $aa, $a8, $2a, $c5, $75, $23, $ba, $17, $61, $55, $5d, $ee
	db $ea, $8b, $aa, $10, $55, $55, $d5, $aa, $bb, $51, $55, $a8, $ee, $aa, $ba, $55
	db $75, $54, $55, $ba, $ae, $af, $aa, $55, $58, $ea, $aa, $d7, $47, $15, $50, $8a
	db $ab, $aa, $8a, $55, $b5, $4d, $55, $aa, $b8, $55, $55, $a2, $8a, $aa, $8a, $75
	db $d7, $57, $51, $aa, $0a, $aa, $e8, $15, $57, $a2, $aa, $55, $55, $64, $61, $aa
	db $2a, $aa, $a3, $55, $25, $55, $57, $aa, $9a, $75, $55, $aa, $af, $aa, $82, $55
	db $55, $57, $55, $ab, $aa, $ba, $2a, $55, $55, $aa, $aa, $57, $15, $55, $5d, $aa
	db $8a, $ae, $ea, $55, $55, $55, $55, $2a, $bb, $45, $55, $aa, $a2, $aa, $ea, $5a
	db $5d, $51, $55, $02, $ab, $a8, $aa, $33, $55, $e8, $ae, $44, $45, $55, $55, $aa

SECTION "analyzed_0b6a1f", ROMX[$6a1f], BANK[$2d]

Data_2d_6a1f:
	db $aa, $2e, $aa, $d5, $67, $15, $45, $ba, $aa, $57, $75, $aa, $ab, $aa, $aa, $55
	db $15, $55, $55, $ba, $8a, $aa, $aa, $97, $91, $0e, $a2, $5f, $e5, $05, $55, $ab
	db $a2, $ea, $aa, $dd, $35, $54, $51, $ba, $aa, $d5, $74, $ad, $ba, $aa, $aa, $11
	db $57, $54, $d5, $ab, $ab, $aa, $aa, $6b, $45, $a8, $aa, $d5, $c6, $d7, $61, $a3
	db $ee, $af, $40, $55, $17, $7d, $45, $8a, $72, $51, $79, $aa, $a2, $ea, $aa, $4c
	db $15, $d5, $55, $9a, $a2, $aa, $aa, $f7, $74, $ba, $aa, $d1, $55, $b5, $0d, $2a
	db $e2, $6a, $8a, $75, $45, $dd, $dd, $aa, $b8, $57, $50, $aa, $be, $ba, $aa, $45
	db $77, $55, $55, $a8, $a2, $aa, $2a, $c5, $77, $23, $ba, $17, $60, $55, $55, $6e
	db $ea, $0b, $aa, $10, $55, $55, $55, $aa, $bb, $51, $55, $a8, $aa, $a8, $ba, $55
	db $75, $44, $55, $ae, $ae, $af, $aa, $55, $58, $ea, $aa, $d7, $47, $15, $50, $8a
	db $ab, $aa, $8a, $55, $b5, $4d, $5d, $e2, $ac, $55, $55, $a2, $8a, $aa, $8a, $75
	db $d7, $57, $41, $aa, $8a, $ba, $e8, $15, $57, $22, $aa, $55, $55, $64, $61, $aa
	db $2a, $ba, $a3, $75, $25, $55, $57, $aa, $d8, $75, $55, $aa, $af, $aa, $82, $55
	db $55, $57, $55, $ab, $aa, $ba, $2a, $55, $55, $aa, $aa, $17, $15, $55, $5d, $aa
	db $8a, $ae, $ea, $55, $55, $55, $55, $aa, $bb, $45, $55, $aa, $ba, $aa, $ee, $5a
	db $5d, $41, $55, $02, $ab, $a8, $aa, $73, $55, $e8, $ae, $44, $05, $55, $5d, $aa

SECTION "analyzed_0b6ea9", ROMX[$6ea9], BANK[$2d]

Data_2d_6ea9:
	db $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $c9, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $8c, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $c7, $20, $20, $00, $c2
	db $00, $00, $00, $00, $d5, $00, $c0, $00, $00, $90, $85, $42, $e0, $20, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $00
	db $01, $02, $0e, $0f, $01, $22, $00, $01, $0a, $05, $22, $00, $01, $0c, $0a, $22
	db $00, $01, $01, $09, $22, $00, $01, $06, $0c, $22, $00, $02, $ff, $ff, $ff, $01
	db $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff
	db $0e, $0c, $02, $00, $02, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0b70ee", ROMX[$70ee], BANK[$2d]

Data_2d_70ee:
	db $00, $00, $04, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $40, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00

SECTION "analyzed_0b7333", ROMX[$7333], BANK[$2d]

Data_2d_7333:
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0b7578", ROMX[$7578], BANK[$2d]

Data_2d_7578:
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0b7a02", ROMX[$7a02], BANK[$2d]

Data_2d_7a02:
	db $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $c8, $00
	db $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $d1, $00
	db $d1, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00
	db $c0, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $93, $00, $00
	db $d1, $00, $d1, $00, $00, $82, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00
	db $00, $00, $e0, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00
	db $00, $00, $00, $00, $94, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $40, $00, $20, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $07
	db $06, $02, $0e, $08, $01, $23, $03, $00, $08, $0b, $23, $02, $00, $01, $08, $23
	db $00, $01, $01, $06, $23, $00, $01, $0f, $06, $23, $01, $01, $0f, $08, $23, $01
	db $01, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff
	db $07, $02, $02, $00, $02, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $09, $02, $02, $00
	db $02, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0b7c47", ROMX[$7c47], BANK[$2d]

Data_2d_7c47:
	db $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $ce, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00
	db $00, $cd, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $c2, $00, $00, $00, $40, $00, $20, $20, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $00
	db $01, $02, $0e, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff
	db $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01
	db $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff
	db $04, $02, $01, $00, $03, $00, $ff, $ff, $ff, $ff, $ff, $ff, $02, $02, $01, $00
	db $03, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0b8145", ROMX[$4145], BANK[$2e]

Data_2e_4145:
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0b838a", ROMX[$438a], BANK[$2e]

Data_2e_438a:
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0b8a59", ROMX[$4a59], BANK[$2e]

Data_2e_4a59:
	db $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $8f, $00, $93, $00, $93
	db $00, $8f, $00, $00, $00, $00, $20, $20, $00, $00, $89, $00, $00, $00, $00, $c0
	db $00, $00, $00, $00, $00, $40, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00
	db $00, $00, $d4, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00
	db $00, $00, $00, $00, $e0, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $00
	db $01, $06, $0e, $02, $0c, $23, $00, $01, $0e, $0c, $23, $01, $01, $ff, $ff, $ff
	db $01, $ff, $0f, $05, $24, $00, $02, $0f, $07, $24, $00, $02, $ff, $ff, $ff, $01
	db $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff
	db $0d, $02, $02, $00, $04, $00, $ff, $ff, $ff, $ff, $ff, $ff, $04, $02, $02, $00
	db $04, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0b8c9e", ROMX[$4c9e], BANK[$2e]

Data_2e_4c9e:
	db $00, $00, $00, $00, $00, $20, $20, $00, $40, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $c0, $00, $d5, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $d1
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $cc, $00, $c8, $00, $cc, $00, $20, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $00
	db $01, $02, $0e, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff
	db $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01
	db $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff
	db $06, $01, $01, $02, $04, $02, $02, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0b8ee3", ROMX[$4ee3], BANK[$2e]

Data_2e_4ee3:
	db $00, $00, $04, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $40, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00

SECTION "analyzed_0b9128", ROMX[$5128], BANK[$2e]

Data_2e_5128:
	db $aa, $2e, $aa, $d5, $67, $15, $55, $ba, $aa, $57, $75, $aa, $ab, $aa, $aa, $55
	db $15, $55, $55, $a8, $8a, $aa, $aa, $97, $91, $0e, $a2, $1d, $e5, $05, $55, $ab
	db $a2, $ea, $aa, $9d, $15, $54, $51, $ba, $aa, $d5, $74, $a9, $ba, $aa, $aa, $11
	db $57, $54, $d5, $aa, $ab, $aa, $aa, $6f, $41, $ae, $aa, $55, $c6, $d7, $61, $a2
	db $ee, $af, $40, $55, $17, $7d, $55, $8a, $7a, $51, $79, $aa, $a2, $ea, $aa, $4c
	db $15, $d5, $55, $8b, $a2, $a8, $aa, $f7, $54, $ba, $aa, $d1, $55, $b5, $0d, $2a
	db $e2, $ea, $ca, $75, $45, $dd, $dd, $aa, $b8, $55, $54, $aa, $be, $ba, $aa, $47
	db $77, $55, $55, $a8, $a2, $88, $2a, $c5, $77, $23, $ba, $17, $61, $55, $55, $6a
	db $ea, $8b, $aa, $10, $55, $55, $d5, $aa, $bb, $55, $55, $a8, $aa, $aa, $ba, $55
	db $75, $54, $55, $ba, $ae, $af, $aa, $55, $58, $ea, $aa, $d7, $47, $15, $50, $8a
	db $ab, $aa, $8a, $55, $b5, $4d, $5d, $a2, $ac, $55, $55, $a2, $8a, $aa, $8a, $75
	db $d7, $55, $51, $aa, $8a, $ba, $e8, $15, $17, $2a, $aa, $55, $55, $65, $41, $aa
	db $2a, $ba, $a3, $75, $25, $55, $57, $aa, $9a, $75, $55, $aa, $ab, $aa, $82, $55
	db $55, $57, $55, $ab, $ba, $ba, $2a, $55, $55, $aa, $aa, $17, $15, $55, $5d, $aa
	db $8a, $ae, $ea, $55, $55, $55, $55, $aa, $b3, $45, $55, $aa, $aa, $aa, $ea, $52
	db $5d, $45, $55, $02, $ab, $a8, $aa, $33, $55, $ec, $ae, $40, $45, $55, $5d, $aa

SECTION "analyzed_0b936d", ROMX[$536d], BANK[$2e]

Data_2e_536d:
	db $aa, $2e, $aa, $d5, $67, $15, $55, $ba, $aa, $57, $75, $aa, $ab, $aa, $aa, $55
	db $15, $55, $55, $a8, $8a, $aa, $aa, $97, $91, $0e, $a2, $1d, $e5, $05, $55, $ab
	db $a2, $ea, $aa, $9d, $15, $54, $51, $ba, $aa, $d5, $74, $a9, $ba, $aa, $aa, $11
	db $57, $54, $d5, $aa, $ab, $aa, $aa, $6f, $41, $ae, $aa, $55, $c6, $d7, $61, $a2
	db $ee, $af, $40, $55, $17, $7d, $55, $8a, $7a, $51, $79, $aa, $a2, $ea, $aa, $4c
	db $15, $d5, $55, $8b, $a2, $a8, $aa, $f7, $54, $ba, $aa, $d1, $55, $b5, $0d, $2a
	db $e2, $ea, $ca, $75, $45, $dd, $dd, $aa, $b8, $55, $54, $aa, $be, $ba, $aa, $47
	db $77, $55, $55, $a8, $a2, $88, $2a, $c5, $77, $23, $ba, $17, $61, $55, $55, $6a
	db $ea, $8b, $aa, $10, $55, $55, $d5, $aa, $bb, $55, $55, $a8, $aa, $aa, $ba, $55
	db $75, $54, $55, $ba, $ae, $af, $aa, $55, $58, $ea, $aa, $d7, $47, $15, $50, $8a
	db $ab, $aa, $8a, $55, $b5, $4d, $5d, $a2, $ac, $55, $55, $a2, $8a, $aa, $8a, $75
	db $d7, $55, $51, $aa, $8a, $ba, $e8, $15, $17, $2a, $aa, $55, $55, $65, $41, $aa
	db $2a, $ba, $a3, $75, $25, $55, $57, $aa, $9a, $75, $55, $aa, $ab, $aa, $82, $55
	db $55, $57, $55, $ab, $ba, $ba, $2a, $55, $55, $aa, $aa, $17, $15, $55, $5d, $aa
	db $8a, $ae, $ea, $55, $55, $55, $55, $aa, $b3, $45, $55, $aa, $aa, $aa, $ea, $52
	db $5d, $45, $55, $02, $ab, $a8, $aa, $33, $55, $ec, $ae, $40, $45, $55, $5d, $aa

SECTION "analyzed_0b95b2", ROMX[$55b2], BANK[$2e]

Data_2e_55b2:
	db $00, $00, $00, $00, $04, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $40, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $bf, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0b9c81", ROMX[$5c81], BANK[$2e]

Data_2e_5c81:
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0b9ec6", ROMX[$5ec6], BANK[$2e]

Data_2e_5ec6:
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0ba350", ROMX[$6350], BANK[$2e]

Data_2e_6350:
	db $aa, $2e, $aa, $d5, $27, $55, $55, $ba, $aa, $57, $75, $aa, $ab, $aa, $aa, $55
	db $15, $55, $55, $b8, $8a, $aa, $aa, $97, $91, $0e, $a2, $5f, $e5, $05, $55, $ab
	db $a2, $aa, $aa, $5d, $15, $54, $d1, $ba, $aa, $55, $74, $a9, $ba, $aa, $aa, $11
	db $57, $54, $55, $ab, $ab, $aa, $aa, $6f, $45, $ac, $aa, $55, $c6, $d7, $61, $a3
	db $ea, $af, $40, $55, $17, $7d, $45, $8a, $72, $51, $7d, $aa, $a2, $aa, $aa, $4c
	db $05, $d5, $55, $8b, $aa, $a8, $aa, $f7, $74, $ba, $aa, $d1, $55, $b5, $0d, $2a
	db $e2, $ea, $8a, $75, $45, $dd, $dd, $aa, $f8, $55, $55, $aa, $be, $aa, $aa, $45
	db $77, $55, $55, $a8, $aa, $aa, $aa, $c5, $77, $2b, $ba, $15, $61, $55, $5d, $2e
	db $ea, $8b, $aa, $10, $55, $55, $55, $aa, $bb, $55, $55, $a8, $ea, $aa, $ba, $55
	db $75, $54, $55, $ae, $ae, $af, $aa, $55, $d8, $ea, $aa, $d7, $47, $15, $50, $8a
	db $ab, $aa, $8a, $55, $b5, $4d, $5d, $a2, $a8, $55, $55, $a2, $8a, $aa, $8a, $75
	db $d7, $55, $51, $aa, $8a, $ba, $e8, $15, $17, $22, $aa, $55, $55, $64, $41, $aa
	db $2a, $ba, $a3, $55, $25, $55, $57, $aa, $9a, $75, $55, $aa, $ab, $aa, $82, $55
	db $55, $57, $55, $ab, $aa, $ba, $2a, $54, $55, $aa, $aa, $57, $15, $55, $5d, $aa
	db $8a, $aa, $ea, $55, $55, $55, $55, $2a, $bb, $45, $55, $aa, $b2, $aa, $ea, $52
	db $5d, $41, $55, $02, $ab, $a8, $aa, $33, $55, $e0, $ae, $44, $45, $5d, $5d, $aa

SECTION "analyzed_0ba7da", ROMX[$67da], BANK[$2e]

Data_2e_67da:
	db $00, $00, $00, $00, $cf, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00
	db $00, $e0, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $d2, $00, $00, $00
	db $00, $00, $00, $dd, $00, $00, $00, $00, $00, $00, $d2, $20, $20, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $0c
	db $00, $02, $0e, $07, $09, $22, $00, $00, $09, $09, $22, $00, $00, $0d, $07, $22
	db $00, $00, $03, $07, $22, $00, $00, $08, $06, $22, $00, $00, $ff, $ff, $ff, $01
	db $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff
	db $0e, $01, $03, $01, $04, $01, $ff, $ff, $ff, $ff, $ff, $ff, $02, $01, $03, $00
	db $04, $01, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0baa1f", ROMX[$6a1f], BANK[$2e]

Data_2e_6a1f:
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0baea9", ROMX[$6ea9], BANK[$2e]

Data_2e_6ea9:
	db $00, $00, $e0, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $c1
	db $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $c6, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $c4, $00, $20, $20, $00, $00, $00, $c2, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $c2, $00, $00, $20, $20, $43, $43, $43
	db $43, $43, $00, $00, $00, $00, $00, $43, $43, $43, $43, $43, $20, $20, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $00
	db $07, $02, $0e, $08, $0c, $24, $02, $01, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff
	db $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01
	db $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff
	db $0d, $01, $01, $01, $04, $00, $02, $ff, $ff, $ff, $ff, $ff, $03, $01, $01, $00
	db $04, $02, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0bb0ee", ROMX[$70ee], BANK[$2e]

Data_2e_70ee:
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $02, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0bb333", ROMX[$7333], BANK[$2e]

Data_2e_7333:
	db $00, $00, $00, $00, $04, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0bb578", ROMX[$7578], BANK[$2e]

Data_2e_7578:
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $02, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0bb7bd", ROMX[$77bd], BANK[$2e]

Data_2e_77bd:
	db $aa, $2e, $aa, $d5, $27, $55, $55, $ba, $aa, $57, $75, $aa, $ab, $aa, $aa, $55
	db $15, $55, $55, $ba, $8a, $aa, $aa, $97, $91, $0e, $a2, $5f, $e5, $05, $55, $aa
	db $a2, $aa, $aa, $55, $15, $54, $51, $ba, $aa, $55, $54, $a9, $ba, $aa, $aa, $11
	db $57, $54, $d5, $ab, $ab, $aa, $aa, $4f, $45, $a8, $aa, $d5, $c6, $d7, $61, $a2
	db $ee, $af, $48, $55, $17, $7c, $45, $8a, $62, $51, $7d, $aa, $a2, $ea, $aa, $48
	db $15, $d5, $55, $cb, $aa, $a8, $aa, $f7, $54, $ba, $aa, $d1, $55, $b5, $0d, $2a
	db $e2, $6a, $8e, $75, $45, $dd, $9d, $aa, $b8, $55, $54, $aa, $be, $ba, $aa, $47
	db $77, $55, $55, $28, $a2, $aa, $2a, $c5, $77, $23, $ba, $17, $61, $55, $55, $6a
	db $ea, $8b, $aa, $14, $55, $55, $d4, $aa, $bb, $55, $55, $a8, $eb, $aa, $ba, $55
	db $75, $54, $55, $be, $ae, $af, $aa, $55, $58, $ea, $aa, $d7, $45, $15, $50, $8a
	db $ab, $a2, $8a, $55, $b5, $4d, $55, $aa, $a8, $55, $55, $a2, $8a, $aa, $8a, $75
	db $d7, $57, $51, $aa, $8a, $ba, $e8, $15, $17, $82, $aa, $55, $55, $65, $41, $a8
	db $2a, $aa, $a3, $55, $05, $55, $57, $aa, $9a, $75, $55, $aa, $ab, $aa, $82, $55
	db $55, $57, $55, $ab, $ba, $ba, $2a, $54, $55, $aa, $aa, $57, $15, $55, $5d, $aa
	db $8a, $ae, $ea, $55, $55, $55, $55, $2a, $bb, $45, $55, $aa, $b2, $aa, $ea, $5a
	db $5d, $41, $55, $02, $ab, $a8, $aa, $33, $55, $e9, $ae, $44, $45, $55, $5d, $aa

SECTION "analyzed_0bba02", ROMX[$7a02], BANK[$2e]

Data_2e_7a02:
	db $66, $70, $d5, $3b, $af, $dc, $55, $aa, $21, $b9, $0e, $32, $40, $1b, $d8, $76
	db $7a, $e3, $29, $d2, $60, $b8, $e9, $7c, $71, $66, $a9, $8d, $13, $c6, $30, $3e
	db $7f, $64, $53, $d1, $45, $58, $b7, $c9, $63, $a7, $a8, $4d, $14, $ac, $5c, $a5
	db $d2, $28, $c6, $d3, $6b, $36, $6d, $d7, $70, $30, $47, $ea, $85, $55, $ee, $cf
	db $ab, $37, $e9, $30, $62, $91, $bb, $67, $12, $72, $47, $24, $8f, $d7, $0a, $b2
	db $c3, $52, $12, $75, $0c, $5a, $a8, $c5, $51, $4b, $52, $54, $d6, $a8, $c9, $a3
	db $3a, $ce, $ef, $90, $9e, $1e, $28, $e1, $b1, $5f, $ee, $6b, $9f, $ec, $63, $51
	db $4e, $80, $a5, $6a, $b2, $9b, $52, $b3, $59, $2e, $7f, $fe, $b8, $cc, $8a, $d1
	db $61, $2f, $a6, $cf, $c6, $5c, $76, $42, $e3, $4e, $69, $94, $a8, $e4, $bf, $a8
	db $d2, $bb, $13, $eb, $2a, $ee, $3d, $95, $df, $65, $2b, $2c, $4e, $f6, $5d, $ed
	db $2a, $33, $2d, $ce, $53, $83, $db, $65, $37, $4f, $45, $9b, $11, $a9, $a5, $6d
	db $6f, $ab, $b1, $6d, $4b, $42, $6c, $e5, $35, $45, $a9, $e4, $28, $76, $37, $28
	db $4b, $54, $5c, $f2, $42, $a5, $56, $2a, $1f, $25, $e4, $bf, $dd, $2b, $1c, $3a
	db $c4, $58, $b4, $b6, $af, $4d, $bc, $bd, $ad, $a4, $2b, $59, $99, $a1, $2d, $e8
	db $58, $dc, $82, $6a, $32, $32, $92, $d7, $6a, $a8, $ab, $4f, $94, $c9, $2b, $63
	db $f7, $db, $eb, $cb, $98, $62, $52, $b2, $2a, $b2, $55, $ba, $47, $63, $56, $2a

SECTION "analyzed_0bbc47", ROMX[$7c47], BANK[$2e]

Data_2e_7c47:
	db $00, $00, $e0, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $c1
	db $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $c6, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $c4, $00, $20, $20, $00, $00, $00, $c2, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $c2, $00, $00, $20, $20, $43, $43, $43
	db $43, $43, $00, $00, $00, $00, $00, $43, $43, $43, $43, $43, $20, $20, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $00
	db $07, $02, $0e, $08, $0c, $24, $02, $01, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff
	db $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01
	db $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff
	db $0d, $01, $01, $01, $04, $00, $02, $ff, $ff, $ff, $ff, $ff, $03, $01, $01, $00
	db $04, $02, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0bc145", ROMX[$4145], BANK[$2f]

Data_2f_4145:
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0bc38a", ROMX[$438a], BANK[$2f]

Data_2f_438a:
	db $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $42, $00, $20, $20, $c2, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $d2, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00
	db $c5, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $cc, $20, $20, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $c0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $09
	db $01, $02, $0e, $08, $06, $24, $00, $00, $08, $08, $24, $00, $00, $08, $0a, $24
	db $00, $00, $08, $0c, $24, $00, $00, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01
	db $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff
	db $02, $02, $02, $00, $02, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $0e, $05, $02, $00
	db $02, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0bc5cf", ROMX[$45cf], BANK[$2f]

Data_2f_45cf:
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0bc814", ROMX[$4814], BANK[$2f]

Data_2f_4814:
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0bcee3", ROMX[$4ee3], BANK[$2f]

Data_2f_4ee3:
	db $00, $00, $04, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $40, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $bf, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00

SECTION "analyzed_0bd128", ROMX[$5128], BANK[$2f]

Data_2f_5128:
	db $aa, $2e, $aa, $d5, $67, $55, $45, $ba, $aa, $55, $75, $aa, $ab, $aa, $aa, $55
	db $15, $55, $55, $ba, $8a, $aa, $aa, $97, $91, $0e, $a2, $5d, $e5, $05, $55, $ab
	db $a2, $aa, $aa, $5d, $15, $54, $d1, $ba, $aa, $55, $54, $ad, $ba, $aa, $aa, $15
	db $57, $54, $55, $aa, $ab, $aa, $aa, $4d, $45, $ac, $aa, $d5, $c6, $d7, $61, $a2
	db $ea, $bf, $48, $55, $17, $7c, $45, $8a, $72, $51, $59, $aa, $a2, $ea, $aa, $4c
	db $15, $d5, $55, $ab, $aa, $aa, $aa, $f7, $54, $ba, $aa, $d1, $55, $b5, $8d, $2a
	db $e2, $6a, $8e, $75, $45, $dd, $dd, $aa, $b8, $55, $55, $aa, $bf, $ba, $aa, $45
	db $77, $55, $55, $28, $a2, $a8, $2a, $c5, $77, $23, $ba, $15, $61, $55, $55, $6e
	db $ea, $8b, $aa, $10, $55, $55, $d5, $aa, $bb, $55, $55, $a8, $aa, $aa, $ba, $55
	db $75, $54, $55, $9a, $ae, $af, $aa, $55, $58, $ea, $aa, $d7, $47, $15, $50, $82
	db $ab, $aa, $8a, $55, $b5, $6d, $5d, $a2, $a8, $55, $55, $a2, $8a, $aa, $8a, $75
	db $d7, $55, $51, $aa, $0a, $aa, $e8, $15, $55, $aa, $aa, $55, $55, $65, $41, $aa
	db $2a, $aa, $a3, $55, $25, $55, $57, $aa, $9a, $75, $55, $aa, $af, $aa, $82, $55
	db $55, $57, $55, $ab, $aa, $ba, $2a, $54, $55, $aa, $aa, $57, $15, $55, $5d, $aa
	db $8a, $ae, $ea, $55, $55, $55, $55, $aa, $bb, $45, $55, $8a, $b2, $aa, $ea, $5a
	db $5d, $41, $55, $02, $ab, $a8, $aa, $73, $55, $e8, $ae, $c4, $45, $55, $5d, $aa

SECTION "analyzed_0bd36d", ROMX[$536d], BANK[$2f]

Data_2f_536d:
	db $00, $00, $00, $00, $04, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $40, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $40, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $02, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $bf, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0bd5b2", ROMX[$55b2], BANK[$2f]

Data_2f_55b2:
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0bd7f7", ROMX[$57f7], BANK[$2f]

Data_2f_57f7:
	db $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $ce, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00
	db $00, $cd, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $c2, $00, $00, $00, $40, $00, $20, $20, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $00
	db $01, $02, $0e, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff
	db $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01
	db $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff
	db $04, $02, $01, $00, $03, $00, $ff, $ff, $ff, $ff, $ff, $ff, $02, $02, $01, $00
	db $03, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0bda3c", ROMX[$5a3c], BANK[$2f]

Data_2f_5a3c:
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0be350", ROMX[$6350], BANK[$2f]

Data_2f_6350:
	db $00, $00, $04, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $40, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $bf, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0cc000", ROMX[$4000], BANK[$33]

Data_33_4000:
	INCBIN "raw_gfx/Data_33_4000.2bpp", 0, 12288

Data_33_7000:
	db $82, $24, $d0, $39, $58, $46, $7d, $67, $82, $24, $24, $41, $65, $52, $19, $53
	db $82, $24, $31, $31, $da, $2d, $24, $31, $82, $24, $31, $31, $3d, $2e, $7f, $63
	db $82, $24, $27, $45, $cc, $35, $f6, $41, $b7, $10, $19, $26, $fc, $52, $7d, $67

Data_33_7030:
	db $e0, $03, $e0, $03, $e0, $03, $e0, $03, $e0, $03, $e0, $03, $e0, $03, $e0, $03

Data_33_7040:
	db $e0, $03, $52, $4a, $18, $57, $68, $3d, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

SECTION "analyzed_0cf080", ROMX[$7080], BANK[$33]

Data_33_7080:
	db $0b, $14, $62, $71, $86, $70, $80, $88, $90, $98, $a0, $a8, $b0, $b8, $c0, $c8
	db $d0, $d8, $e0, $e8, $f0, $f8, $00, $08, $10, $18, $81, $89, $91, $99, $a1, $a9
	db $b1, $b9, $c1, $c9, $d1, $d9, $e1, $e9, $f1, $f9, $01, $09, $11, $19, $82, $8a
	db $92, $9a, $a2, $aa, $b2, $ba, $c2, $ca, $d2, $da, $e2, $ea, $f2, $fa, $02, $0a
	db $12, $1a, $83, $8b, $93, $9b, $a3, $ab, $b3, $bb, $c3, $cb, $d3, $db, $e3, $eb
	db $f3, $fb, $03, $0b, $13, $1b, $84, $8c, $94, $9c, $a4, $ac, $b4, $bc, $c4, $cc
	db $d4, $dc, $e4, $ec, $f4, $fc, $04, $0c, $14, $1c, $85, $8d, $95, $9d, $a5, $ad
	db $b5, $bd, $c5, $cd, $d5, $dd, $e5, $ed, $f5, $fd, $05, $0d, $15, $1d, $86, $8e
	db $96, $9e, $a6, $ae, $b6, $be, $c6, $ce, $d6, $de, $e6, $ee, $f6, $fe, $06, $0e
	db $16, $1e, $87, $8f, $97, $9f, $a7, $af, $b7, $bf, $c7, $cf, $d7, $df, $e7, $ef
	db $f7, $ff, $07, $0f, $17, $1f, $20, $28, $30, $38, $40, $48, $50, $58, $23, $2b
	db $33, $3b, $43, $4b, $53, $5b, $26, $2e, $36, $3e, $21, $29, $31, $39, $41, $49
	db $51, $59, $24, $2c, $34, $3c, $44, $4c, $54, $5c, $27, $2f, $37, $3f, $22, $2a
	db $32, $3a, $42, $4a, $52, $5a, $25, $2d, $35, $3d, $45, $4d, $55, $5d, $46, $47
	db $4e, $4f, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $09, $09, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $09, $09, $0a, $0a, $0c, $0c, $0a, $0a
	db $0a, $0b, $0b, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $09, $09, $0a, $0a
	db $0c, $0c, $0a, $0a, $0a, $0b, $0b, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $09, $09, $0c, $0c, $0c, $0c, $0c, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0b, $0b, $0a, $09, $09, $0c, $0c, $0c, $0c, $0c, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $09, $09, $0c, $0c, $0c, $0c, $0c, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $09, $09, $0c, $0c
	db $0c, $0c, $0c, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $09, $09, $0c, $0c, $0c, $0c, $0c, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $09, $09, $0c, $0c, $0c, $0c, $0c, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $09, $09, $0c, $0c, $0c, $0c, $0c, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $09, $09, $0b, $14
	db $20, $73, $44, $72, $80, $88, $90, $98, $a0, $a8, $b0, $b8, $c0, $c8, $d0, $d8
	db $e0, $e8, $f0, $f8, $00, $08, $10, $18, $81, $89, $91, $99, $a1, $a9, $b1, $b9
	db $c1, $c9, $d1, $d9, $e1, $e9, $f1, $f9, $01, $09, $11, $19, $82, $8a, $92, $9a
	db $a2, $aa, $b2, $ba, $c2, $ca, $d2, $da, $e2, $ea, $f2, $fa, $02, $0a, $12, $1a
	db $83, $8b, $93, $9b, $a3, $ab, $b3, $bb, $c3, $cb, $d3, $db, $e3, $eb, $f3, $fb
	db $03, $0b, $13, $1b, $84, $8c, $94, $9c, $a4, $ac, $b4, $bc, $c4, $cc, $d4, $dc
	db $e4, $ec, $f4, $fc, $04, $0c, $14, $1c, $85, $8d, $95, $9d, $a5, $ad, $b5, $bd
	db $c5, $cd, $d5, $dd, $e5, $ed, $f5, $fd, $05, $0d, $15, $1d, $86, $8e, $96, $9e
	db $a6, $ae, $b6, $be, $c6, $ce, $d6, $de, $e6, $ee, $f6, $fe, $06, $0e, $16, $1e
	db $87, $8f, $97, $9f, $a7, $af, $b7, $bf, $c7, $cf, $d7, $df, $e7, $ef, $f7, $ff
	db $07, $0f, $17, $1f, $20, $28, $30, $38, $40, $48, $50, $58, $23, $2b, $33, $3b
	db $43, $4b, $53, $5b, $26, $2e, $36, $3e, $21, $29, $31, $39, $41, $49, $51, $59
	db $24, $2c, $34, $3c, $44, $4c, $54, $5c, $27, $2f, $37, $3f, $22, $2a, $32, $3a
	db $42, $4a, $52, $5a, $25, $2d, $35, $3d, $45, $4d, $55, $5d, $46, $47, $4e, $4f
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $09, $09, $0a, $0a, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $09, $09, $0a, $0a, $08, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $08, $08, $08, $08, $08, $08, $09, $09, $0a, $0a, $08, $0d
	db $0d, $0d, $0d, $0d, $0d, $0d, $08, $08, $08, $08, $08, $08, $08, $08, $09, $09
	db $0c, $0c, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $09, $09, $0c, $0c, $08, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d, $0d
	db $08, $08, $08, $08, $08, $08, $09, $09, $0c, $0c, $08, $0d, $0d, $0d, $0d, $0d
	db $0d, $0d, $0d, $0d, $08, $08, $08, $08, $08, $08, $09, $09, $0c, $0c, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $09, $09
	db $0c, $0c, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $09, $09, $0c, $0c, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $09, $09, $0c, $0c, $0c, $0c, $0c, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $09, $09, $02, $00, $00, $00
	db $08, $00, $08, $02, $08, $02, $00, $00, $04, $08, $00, $08, $06, $08, $02, $00
	db $00, $08, $08, $00, $08, $0a, $08, $02, $00, $00, $0c, $08, $00, $08, $0e, $08
	db $02, $00, $00, $10, $08, $00, $08, $12, $08

SECTION "analyzed_0d0000", ROMX[$4000], BANK[$34]

Data_34_4000:
	db $78, $a7, $20, $05, $21, $df, $79, $18, $03, $21, $00, $7a, $fa, $f8, $d5, $fe
	db $ff, $c8, $a7, $20, $1a, $fa, $f7, $d5, $cb, $27, $cb, $27, $c7, $2a, $ea, $f8
	db $d5, $fe, $ff, $c8, $df, $11, $c9, $98, $cd, $4e, $0b, $21, $f7, $d5, $34, $21
	db $f8, $d5, $35, $c9
Func_34_4034:
	db $fa, $c7, $d5, $fe, $20, $20, $07, $f5, $3e, $22, $cd, $85, $0a, $f1, $fa, $c7
	db $d5, $fe, $20, $d0, $fa, $c8, $d5, $3c, $fe, $0c, $38, $01, $af, $ea, $c8, $d5
	db $cb, $3f, $cb, $3f, $21, $d9, $79, $c7, $df, $3e, $34, $ea, $00, $c1, $06, $7e
	db $0e, $60, $cd, $09, $0c, $c9
Func_34_406a:
	db $cd, $d7, $0b, $af, $e0, $4f, $21, $a8, $40, $11, $00, $80, $01, $00, $18, $cd
	db $94, $03, $3e, $01, $e0, $4f, $21, $a8, $58, $11, $00, $80, $01, $00, $18, $cd
	db $94, $03, $af, $06, $08, $21, $a8, $70, $cd, $f2, $04, $af, $06, $08, $21, $e8
	db $70, $cd, $47, $05, $21, $28, $71, $11, $00, $98, $cd, $4e, $0b, $c9, $00, $00
	db $00, $00, $00, $00, $00, $00, $01, $01, $00, $00, $00, $00, $00, $00, $80, $80
	db $c0, $c0, $70, $70, $38, $38, $3e, $3e, $17, $1f, $09, $0f, $0c, $0f, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $c0, $c0, $60, $60, $70, $70
	db $38, $38, $3c, $3c, $16, $1e, $1b, $1f, $09, $0f, $cd, $cf, $f4, $f7, $02, $02
	db $02, $02, $02, $02, $07, $07, $07, $07, $07, $07, $0d, $0f, $0d, $0f, $0d, $0f
	db $09, $0f, $19, $1f, $19, $1f, $12, $1d, $32, $3d, $b6, $b9, $f6, $f9, $04, $04
	db $04, $04, $04, $04, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $0c, $18, $18, $98, $98
	db $98, $98, $98, $98, $a9, $b9, $ab, $bb, $af, $bf, $ce, $ff, $cc, $ff, $00, $00
	db $00, $00, $01, $01, $03, $03, $07, $07, $0f, $0f, $1f, $1f, $1f, $1f, $3e, $3e
	db $76, $7e, $ee, $fe, $ce, $fe, $8c, $fc, $1c, $fc, $5c, $bc, $bb, $7b, $40, $40
	db $c0, $c0, $80, $80, $80, $80, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $03, $03, $0e, $0e, $3c, $3c, $ec, $fc, $98, $f8, $06, $07
	db $03, $03, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3e, $ff
	db $1e, $ff, $87, $ff, $d9, $e7, $ce, $f1, $67, $78, $73, $7c, $3b, $3c, $19, $1e
	db $0c, $0f, $0e, $0f, $07, $07, $00, $00, $00, $00, $00, $00, $00, $00, $36, $f9
	db $96, $79, $46, $b9, $66, $99, $77, $88, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $7f, $80, $3f, $c0, $03, $00, $00, $00, $00, $00, $00, $00, $a9, $de
	db $a3, $dc, $b7, $c8, $fe, $81, $7e, $81, $7c, $83, $fc, $03, $fb, $04, $f7, $08
	db $ff, $00, $ff, $00, $fe, $01, $c0, $00, $00, $00, $00, $00, $00, $00, $bf, $7f
	db $7c, $ff, $70, $ff, $c6, $f9, $9d, $e3, $3b, $c7, $f7, $0f, $ee, $1e, $cc, $3c
	db $98, $78, $30, $f0, $60, $e0, $00, $00, $00, $00, $00, $00, $00, $00, $30, $f0
	db $30, $f0, $60, $e0, $c0, $c0, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $06, $05
	db $11, $17, $2e, $39, $6d, $13, $13, $7f, $3f, $3f, $5f, $3f, $35, $6f, $a7, $df
	db $5f, $bf, $3f, $ff, $ef, $ff, $47, $7f, $27, $1f, $2f, $3f, $0e, $0e, $60, $00
	db $60, $e0, $f0, $e0, $e8, $d4, $86, $fe, $de, $fe, $ff, $ff, $97, $ef, $26, $de
	db $6e, $9e, $9c, $fc, $fe, $fe, $fe, $fe, $fc, $fc, $f8, $f8, $60, $60, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $0e, $00, $1f, $00, $3c, $42, $0c, $70
	db $08, $14, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $10, $00
	db $f0, $00, $c8, $30, $05, $48, $06, $01, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $08, $08, $18, $18, $08, $18, $08, $18, $08, $38, $00, $30, $20, $10
	db $30, $10, $70, $10, $40, $20, $40, $a0, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $10, $10, $18, $18, $10, $18, $10, $18, $10, $1c, $00, $0c, $04, $08
	db $0c, $08, $0e, $08, $02, $04, $02, $05, $06, $05, $03, $00, $01, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $08, $00
	db $0f, $00, $13, $0c, $a0, $1c, $60, $98, $00, $c0, $80, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $70, $00, $f8, $00, $3c, $42, $30, $0e
	db $10, $28, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $30, $00, $40, $38, $03, $60, $07, $40, $07, $00, $07, $40
	db $02, $01, $02, $01, $00, $00, $00, $08, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $80, $00, $80, $40, $c0, $00
	db $c8, $c0, $80, $c0, $05, $00, $06, $01, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $08, $08, $08, $08, $08, $18, $18, $08, $30, $20, $10, $20, $20, $10
	db $20, $10, $30, $50, $10, $70, $00, $e0, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $10, $10, $10, $10, $10, $18, $18, $10, $0c, $04, $08, $04, $04, $08
	db $04, $08, $0c, $0a, $08, $0e, $00, $07, $04, $07, $03, $00, $01, $02, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $01, $00, $01, $02, $03, $00
	db $13, $03, $01, $03, $a0, $00, $60, $88, $40, $80, $80, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $0c, $00, $02, $1c, $c0, $06, $e0, $02, $e0, $00, $e0, $02
	db $40, $80, $40, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $07, $00, $0f, $00, $1f, $00, $1e, $01, $10, $0f
	db $03, $1f, $0b, $0f, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $80, $00, $08, $c0, $00, $e0
	db $e0, $00, $a0, $40, $41, $02, $02, $05, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $08, $08, $08, $08, $18, $18, $18, $08, $30, $20, $30, $20, $00, $30
	db $20, $10, $20, $50, $10, $70, $50, $b0, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $10, $10, $10, $10, $18, $18, $18, $10, $1c, $1c, $1c, $14, $0c, $04
	db $0c, $04, $00, $0e, $04, $0a, $04, $0b, $00, $07, $03, $04, $05, $06, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $01, $00, $11, $02, $01, $06
	db $17, $00, $05, $02, $80, $44, $40, $a8, $80, $40, $00, $80, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $e0, $00, $f0, $00, $f8, $00, $f8, $00, $f8, $00
	db $c8, $b0, $d0, $f0, $00, $40, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $03, $00, $0f, $00, $1f, $20, $7f, $00, $30, $cf, $00, $7f
	db $00, $3f, $06, $09, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $60, $10, $f8, $04, $ff, $00, $ff, $00, $ff, $00, $8f, $70, $06, $f9
	db $00, $ff, $00, $3f, $00, $0f, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $c0, $20, $f0, $08, $bc, $40, $0c, $f3, $00, $fc
	db $00, $f0, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, $3f, $40, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $01, $01, $00, $01, $00
	db $01, $02, $03, $00, $03, $04, $07, $08, $1f, $20, $ff, $00, $ff, $00, $00, $80
	db $80, $00, $80, $00, $80, $00, $80, $00, $80, $40, $80, $40, $c0, $00, $c0, $00
	db $c0, $20, $e0, $00, $e0, $10, $f0, $08, $fc, $02, $ff, $00, $ff, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $60, $fe, $01, $00, $03
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $00
	db $1f, $20, $07, $08, $03, $04, $03, $00, $01, $02, $01, $00, $01, $00, $00, $01
	db $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $00
	db $fc, $02, $f0, $08, $e0, $10, $e0, $00, $c0, $20, $c0, $00, $c0, $00, $80, $40
	db $80, $40, $80, $00, $80, $00, $80, $00, $80, $00, $00, $80, $00, $00, $80, $60
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $10, $08, $00, $04, $02, $03, $04, $03, $00, $03, $00, $03, $00
	db $03, $04, $04, $02, $08, $00, $00, $10, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $04, $08, $00, $10, $20, $e0, $10, $e0, $00, $e0, $00, $e0, $00
	db $e0, $10, $10, $20, $08, $00, $00, $04, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $07, $08, $01, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $80, $80, $00, $80, $00, $c0, $00, $f0, $08, $c0, $00
	db $80, $00, $80, $00, $00, $80

SECTION "analyzed_0d08a8", ROMX[$48a8], BANK[$34]

Data_34_48a8:
	INCBIN "raw_gfx/Data_34_48a8.2bpp", 0, 4096

SECTION "analyzed_0d20ca", ROMX[$60ca], BANK[$34]

Data_34_60ca:
	db $01, $01, $01, $03, $07, $03, $07, $07, $07, $0f, $0d, $1f, $1f, $1f, $1d, $3f
	db $3f, $3f, $3d, $3f, $3f, $7f, $7d, $7f, $77, $7f, $77, $ff, $69, $ff, $75, $fe
	db $fa, $ff, $f5, $ff, $fe, $ff, $f5, $ff, $fe, $ff, $f5, $ff, $ff, $ff, $7d, $ff
	db $7f, $ff, $7d, $ff, $bf, $7f, $bf, $7f, $df, $3f, $df, $3f, $ef, $1f, $ef, $1f
	db $f7, $0f, $fb, $07, $fd, $03, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $02, $01, $05, $03, $07, $0f, $0e, $1f, $1c, $3f, $7a, $7f, $f0, $ff
	db $ea, $ff, $d0, $ff, $ea, $ff, $50, $ff, $ea, $ff, $54, $ff, $ea, $ff, $55, $ff
	db $aa, $ff, $55, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff, $ea, $ff, $75, $ff
	db $af, $df, $56, $f9, $ab, $fe, $55, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $ea, $ff, $55, $ff, $fa, $ff, $55, $ff, $ff, $ff, $d5, $ff, $ff, $ff, $fd, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $7f, $ff, $df, $3f, $ef, $1f, $e7, $1f, $f3, $07
	db $f7, $03, $fb, $03, $fb, $03, $fb, $03, $f9, $03, $f9, $03, $f9, $03, $00, $00
	db $00, $00, $00, $00, $00, $00, $59, $3e, $bf, $7f, $bf, $40, $2f, $40, $13, $30
	db $9c, $78, $e7, $ff, $a0, $ff, $00, $ff, $a3, $fc, $10, $e0, $90, $e0, $07, $f8
	db $00, $ff, $00, $ff, $18, $e7, $1c, $e3, $87, $f8, $00, $ff, $80, $ff, $60, $9f
	db $9c, $e3, $55, $ff, $80, $ff, $55, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $aa, $ff, $ff, $ff, $fd, $03, $54, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $aa, $ff, $55, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff, $fe, $f1, $57, $ee
	db $ff, $ef, $df, $ef, $ff, $ef, $ff, $ef, $fe, $ef, $f6, $ef, $f6, $ff, $f7, $ff
	db $90, $7f, $f7, $0f, $f7, $88, $f8, $87, $fd, $80, $fe, $80, $ff, $80, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $a0, $c0, $74, $f8, $ef, $1f, $fe, $01
	db $61, $1f, $9b, $07, $f7, $f8, $0f, $ff, $e1, $1f, $20, $1f, $0c, $03, $00, $00
	db $83, $00, $1f, $e0, $00, $ff, $00, $ff, $00, $ff, $e0, $1f, $00, $ff, $00, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $ff, $ff, $55, $ff, $ff, $ff, $ff, $00, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $aa, $ff, $55, $ff, $ab, $ff, $55, $ff, $af, $ff, $55, $ff, $ff, $ff, $55, $ff
	db $ff, $7f, $f5, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $7f, $ff, $ff, $7f, $ff
	db $57, $7f, $2a, $7f, $15, $bf, $8a, $4f, $31, $00, $67, $00, $1f, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $40, $80, $ff, $ff
	db $ff, $ff, $ff, $ff, $bf, $7f, $7f, $80, $ff, $ff, $0f, $ff, $00, $ff, $c0, $3f
	db $f0, $0f, $ff, $00, $7f, $80, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $55, $ff
	db $00, $ff, $55, $ff, $2a, $ff, $55, $ff, $af, $ff, $55, $ff, $ff, $ff, $55, $ff
	db $ff, $ff, $57, $ff, $ff, $ff, $60, $9f, $aa, $ff, $55, $ff, $ab, $ff, $55, $ff
	db $ff, $ff, $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $55, $ff
	db $ff, $ff, $55, $ff, $ff, $ff, $d5, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $55, $ff, $aa, $ff, $c0, $3f, $ff, $00, $ff, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $40, $80
	db $d8, $e0, $ec, $f0, $d8, $e4, $ef, $1e, $fe, $ff, $ff, $ff, $7f, $ff, $07, $ff
	db $03, $ff, $85, $7f, $e0, $1f, $05, $ff, $02, $ff, $57, $ff, $0a, $ff, $57, $ff
	db $2b, $ff, $5f, $ff, $ff, $ff, $5f, $ff, $fe, $ff, $5d, $fe, $fe, $fc, $7c, $f8
	db $f0, $f8, $f0, $f8, $c0, $f0, $00, $f0, $a0, $f0, $50, $e0, $ef, $f0, $5f, $f0
	db $f7, $f8, $7f, $f8, $ff, $f8, $fb, $fc, $ff, $fc, $ff, $fc, $fd, $fe, $7e, $ff
	db $ff, $ff, $5f, $ff, $ff, $ff, $57, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $aa, $ff, $00, $ff, $ff, $00, $ff, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $c0, $80, $a0, $c0, $c0, $e0
	db $f0, $e0, $e0, $f0, $f0, $f0, $f0, $f0, $f0, $f0, $e0, $f0, $f0, $e0, $c0, $e0
	db $e0, $c0, $80, $c0, $40, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $0f, $00, $1f, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $7f, $80, $bf, $c0, $df, $e0, $ef, $f0, $ff, $f0, $ff, $f8, $fb, $fc, $ff, $fc
	db $ff, $fc, $fd, $fe, $fb, $fe, $ae, $ff, $3f, $df, $ff, $07, $ff, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $f0, $00, $fe, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $7f, $80, $9f, $80, $cf, $e0, $f3, $70, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $fc, $03, $f8, $07, $00, $3f, $00, $7f, $00, $ff, $00, $ff, $00, $ff, $48, $ff
	db $70, $ff, $f9, $ff, $fc, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00
	db $4f, $b0, $00, $f8, $00, $ff, $00, $ff, $06, $ff, $04, $ff, $0c, $ff, $03, $ff
	db $27, $ff, $df, $ff, $f9, $ff, $f0, $ff, $fb, $ff, $ff, $ff, $ff, $ff, $ff, $00
	db $e0, $00, $00, $00, $10, $fc, $3c, $ff, $2e, $ff, $0f, $ff, $3c, $ff, $1e, $ff
	db $fe, $ff, $1e, $ff, $34, $ff, $74, $ff, $fe, $ff, $fe, $ff, $ff, $ff, $ff, $00
	db $00, $00, $00, $00, $00, $00, $00, $70, $10, $f8, $18, $ff, $1c, $ff, $b8, $ff
	db $f0, $ff, $5c, $ff, $7d, $ff, $3d, $ff, $3e, $ff, $7f, $ff, $ff, $ff, $ff, $00
	db $00, $03, $00, $07, $00, $3f, $01, $7f, $01, $ff, $06, $ff, $02, $ff, $07, $ff
	db $05, $ff, $e8, $ff, $93, $ff, $35, $ff, $3b, $ff, $ff, $ff, $ff, $ff, $00, $00
	db $c0, $00, $f0, $00, $fe, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $80, $00, $e0, $00, $f8, $00, $ff, $00, $aa, $00
	db $00, $00, $aa, $00, $00, $00, $ac, $07, $03, $07, $03, $03, $01, $03, $aa, $00
	db $00, $00, $aa, $00, $00, $00, $7c, $80, $00, $ff, $ff, $ff, $ff, $ff

SECTION "analyzed_0d28a8", ROMX[$68a8], BANK[$34]

Data_34_68a8:
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $e8
	db $57, $f8, $ff, $fc, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $1f, $ef, $f8, $78, $f8, $f8, $c0, $c0, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $1f, $1f, $7f, $7f, $ff, $ff, $fe, $fe, $fc, $fc, $7c, $7c, $38, $38, $18, $18
	db $00, $00, $00, $00, $80, $80, $d8, $18, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $c1, $00, $ff, $07, $ff, $0f, $ff, $7f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $fc, $ff, $fc, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $e7, $ff, $00, $ff, $00
	db $fd, $07, $ff, $0f, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $c0, $3f, $3b, $25, $13, $1f, $7f, $7f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $fd, $fd, $fd, $fd, $1c, $1c, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $01, $01, $01, $01, $15, $00, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $ff, $7f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $3f, $f1, $e0, $ff, $f3, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $7f
	db $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $aa, $55, $c0, $ff, $8a, $95, $85, $8a, $ca, $c5, $fd, $ff, $ff, $ff
	db $87, $87, $0f, $0f, $0f, $0f, $1e, $1e, $38, $38, $00, $00, $00, $00, $18, $18
	db $3f, $3c, $f5, $e0, $ff, $80, $55, $00, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $03, $03, $aa, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $fe, $fe, $e3, $e0, $ff, $e0, $ff, $f9, $ff, $9f, $ff, $ff, $ff, $ff, $ff, $ff
	db $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $75, $ea, $f8, $f9, $f8, $f8, $c1, $c1
	db $f8, $f8, $9c, $9c, $80, $80, $00, $00, $00, $00, $00, $00, $80, $80, $c0, $c0
	db $f1, $00, $55, $00, $ff, $00, $55, $00, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $ae, $0e, $67, $67, $ff, $7f, $ff, $ff, $d0, $d0, $e0, $e0, $10, $10, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $1f, $1d
	db $3f, $00, $ff, $04, $ff, $3c, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $03, $fc, $20, $c0, $44, $80, $af, $50
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $55, $aa, $aa, $55, $55, $aa, $ff, $ff
	db $7f, $7f, $0c, $0c, $00, $00, $01, $01, $07, $00, $0f, $00, $3f, $00, $bf, $00
	db $ff, $00, $55, $00, $ff, $00, $55, $00, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $80, $80, $ff, $fd, $fe, $fe, $e2, $e0, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $9f, $ff, $ff, $fe, $e6, $c1, $c0, $81, $80
	db $fe, $00, $fc, $00, $ff, $00, $ff, $80, $ff, $e1, $ff, $f3, $ff, $ff, $ff, $ff
	db $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $80, $3f, $7c, $03, $f0, $0f, $2a, $55
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $55, $aa, $aa, $55, $71, $b2, $e7, $00
	db $f5, $ea, $0f, $00, $03, $02, $03, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $55, $00, $ff, $00, $55, $00, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $0f, $0f, $67, $00, $e1, $00, $c7, $00
	db $01, $00, $1f, $00, $3f, $00, $ff, $00, $ff, $80, $ff, $f1, $ff, $ff, $ff, $ff
	db $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $55, $aa, $aa, $55, $55, $aa, $ff, $00
	db $55, $aa, $ff, $00, $55, $aa, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $55, $00, $ff, $00, $55, $00, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $7f, $f9, $19, $f0, $00
	db $ff, $00, $ff, $00, $ff, $3c, $ff, $3f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $55, $aa, $aa, $55, $55, $aa, $ff, $00
	db $55, $aa, $ff, $00, $55, $aa, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $55, $00, $ff, $00, $55, $00, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $fe, $7f, $3c
	db $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $55, $aa, $aa, $55, $55, $aa, $ff, $00
	db $55, $aa, $ff, $00, $55, $aa, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $07, $ff, $ff, $fc, $00, $55, $00, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $fc, $00, $ff, $00, $ff, $00, $ff, $80, $be, $e3, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $55, $ff, $ff, $ff, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $55, $aa, $aa, $55, $55, $aa, $ff, $00
	db $55, $aa, $ff, $00, $55, $aa, $ff, $00, $ff, $00, $ff, $00, $ff, $18, $f7, $75
	db $ff, $ff, $ff, $ff, $78, $78, $50, $00, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $d5, $7f, $c3, $03, $ed, $03, $ff, $07, $ea, $3f, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $50, $f0, $fc, $fc, $55, $ff, $ff, $ff, $aa, $ff, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $55, $aa, $aa, $55, $55, $aa, $ff, $00
	db $55, $aa, $ff, $07, $73, $b3, $f0, $00, $ff, $00, $ff, $00, $ff, $01, $ff, $83
	db $ff, $ff, $fc, $fc, $07, $00, $55, $40, $ff, $00, $55, $00, $aa, $00, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $00, $ff, $2a, $55, $00, $1f, $2a, $15, $55, $aa, $aa, $55, $55, $aa, $ff, $03
	db $57, $af, $ff, $07, $55, $a9, $f0, $00, $f0, $f0, $e0, $e0, $fc, $fc, $ff, $ff
	db $75, $1f, $fc, $38, $57, $fc, $f0, $f0, $a7, $e0, $57, $f8, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $55, $aa, $aa, $55, $55, $aa, $ff, $00
	db $7d, $fa, $ef, $ec, $e4, $e4, $0f, $0f, $ff, $3f, $ff, $ff, $fc, $fc, $f8, $f8
	db $f8, $f8, $68, $68, $80, $00, $60, $20, $f8, $78, $55, $00, $ab, $01, $55, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $07, $ff, $bf, $7f, $7f, $ff, $f1, $71, $41, $c1, $c0, $40, $80, $80, $00, $00
	db $e0, $e0, $f0, $f0, $f8, $f8, $f0, $f0, $30, $30, $20, $20, $e3, $e3, $e3, $e3
	db $9b, $00, $ff, $00, $57, $30, $ff, $1c, $ca, $1f, $d5, $7f, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $aa, $55, $00, $ff, $aa, $55, $55, $aa, $aa, $55, $55, $aa, $ff, $00
	db $55, $aa, $ff, $00, $15, $0a, $ef, $e0, $f9, $f8, $ff, $ff, $ff, $ff, $ff, $ff
	db $3f, $3f, $3f, $3f, $3d, $3d, $38, $38, $00, $00, $00, $00, $80, $80, $45, $00
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $fd, $fd, $f0, $f0, $e0, $e0, $fc, $fc
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $c7, $00, $ff, $00, $ff, $00, $ff, $03, $ea, $3f, $55, $ff, $aa, $ff, $55, $ff
	db $00, $ff, $55, $ff, $00, $ff, $55, $ff, $00, $ff, $00, $ff, $00, $ff, $aa, $55
	db $00, $ff, $ab, $57, $07, $ff, $a0, $20, $51, $a0, $aa, $55, $55, $aa, $ff, $00
	db $55, $aa, $ff, $00, $55, $aa, $ff, $00, $ff, $1c, $f3, $f1, $f3, $f3, $87, $87
	db $ff, $ff, $ff, $ff, $ff, $ff, $7f, $7f, $7f, $7f, $01, $01, $71, $71, $53, $13
	db $aa, $00, $00, $00, $aa, $00, $00, $00, $aa, $00, $00, $00, $00, $00, $00, $00
	db $e4, $e4, $c4, $c4, $c8, $c8, $f0, $f0, $e0, $e0, $c0, $c0, $00, $00, $00, $00
	db $00, $00, $00, $00, $a0, $20, $0f, $0f, $aa

SECTION "analyzed_0d30a8", ROMX[$70a8], BANK[$34]

Data_34_70a8:
	db $77, $7f, $8d, $6e, $81, $69, $c6, $5c, $77, $7f, $8d, $6e, $81, $69, $e4, $51
	db $77, $7f, $8d, $6e, $e3, $61, $25, $41, $5c, $5f, $37, $32, $94, $52, $6b, $2d
	db $5c, $5f, $37, $32, $06, $22, $e0, $2c, $5c, $5f, $de, $7b, $94, $52, $6b, $2d
	db $5c, $5f, $94, $52, $06, $22, $00, $00, $77, $7f, $8d, $6e, $81, $69, $de, $7b
	db $8d, $6e, $ff, $7f, $8f, $7f, $00, $00, $00, $7c, $ff, $7f, $b8, $6e, $31, $5e
	db $1f, $00, $ff, $7f, $f3, $6a, $c9, $5d, $ff, $03, $7e, $67, $de, $12, $dc, $0c
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $12, $14, $96, $72, $2e, $71, $88, $90, $98, $a0, $00, $08, $10, $18, $20, $28
	db $30, $38, $07, $0f, $17, $1f, $27, $2f, $37, $3f, $89, $91, $99, $a1, $01, $09
	db $11, $19, $21, $29, $31, $39, $40, $48, $50, $58, $60, $68, $46, $4e, $8a, $92
	db $9a, $a2, $02, $0a, $12, $1a, $22, $2a, $32, $3a, $41, $49, $51, $59, $61, $69
	db $47, $4f, $8b, $93, $9b, $a3, $03, $0b, $13, $1b, $23, $2b, $33, $3b, $42, $4a
	db $52, $5a, $62, $6a, $56, $5e, $8c, $94, $9c, $a4, $04, $0c, $14, $1c, $24, $2c
	db $34, $3c, $43, $4b, $53, $5b, $63, $6b, $57, $5f, $8d, $95, $9d, $a5, $05, $0d
	db $15, $1d, $25, $2d, $35, $3d, $44, $4c, $54, $5c, $64, $6c, $66, $6e, $8e, $96
	db $9e, $a6, $06, $0e, $16, $1e, $26, $2e, $36, $3e, $45, $4d, $55, $5d, $65, $6d
	db $67, $6f, $8f, $97, $9f, $a7, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87
	db $87, $87, $87, $87, $87, $87, $a8, $b0, $b8, $c0, $87, $87, $87, $87, $87, $87
	db $48, $40, $38, $30, $30, $38, $40, $48, $87, $87, $a9, $b1, $b9, $c1, $87, $87
	db $87, $87, $87, $87, $49, $41, $39, $31, $31, $39, $41, $49, $87, $87, $aa, $b2
	db $ba, $c2, $87, $87, $87, $87, $87, $87, $4a, $42, $3a, $32, $32, $3a, $42, $4a
	db $87, $87, $ab, $b3, $bb, $c3, $d3, $d3, $d2, $d2, $d3, $87, $4b, $43, $3b, $33
	db $33, $3b, $43, $4b, $87, $d3, $ac, $b4, $bc, $c4, $c8, $d0, $d8, $e0, $e8, $e8
	db $4c, $44, $3c, $34, $34, $3c, $44, $4c, $e8, $e8, $ad, $b5, $bd, $c5, $c9, $d1
	db $d9, $e1, $e9, $e8, $4d, $45, $3d, $35, $35, $3d, $45, $4d, $e8, $e8, $ae, $b6
	db $be, $c6, $ca, $d2, $da, $e2, $ea, $e8, $4e, $46, $3e, $36, $36, $3e, $46, $4e
	db $e8, $cb, $af, $b7, $bf, $c7, $d3, $db, $e3, $eb, $f3, $fb, $ce, $d6, $de, $e6
	db $ee, $c8, $ca, $cc, $ce, $d0, $f9, $fa, $47, $4f, $d4, $dc, $e4, $ec, $f4, $fc
	db $cf, $d7, $df, $e7, $ef, $c9, $cb, $cd, $cf, $d1, $cc, $cc, $cc, $cd, $d5, $dd
	db $e5, $ed, $f5, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $fd, $85, $85
	db $85, $85, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $85, $85, $85, $85, $08, $08, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $85, $85, $85, $85, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $08, $08, $85, $85, $85, $85, $0f, $0f
	db $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $85, $85
	db $85, $85, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	db $0f, $0f, $85, $85, $85, $85, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f, $0f
	db $0f, $0f, $0f, $0f, $0f, $0f, $85, $85, $85, $85, $0f, $0f, $0f, $0f, $0f, $0f
	db $0f, $08, $08, $08, $08, $08, $08, $0f, $0f, $0f, $85, $85, $85, $85, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $85, $85
	db $85, $85, $01, $01, $01, $01, $01, $01, $22, $22, $22, $22, $02, $02, $02, $02
	db $01, $01, $85, $85, $85, $85, $01, $01, $01, $01, $01, $01, $22, $22, $22, $22
	db $02, $02, $02, $02, $01, $01, $85, $85, $85, $85, $01, $01, $01, $01, $01, $01
	db $22, $22, $22, $22, $02, $02, $02, $02, $01, $01, $85, $85, $85, $85, $09, $29
	db $29, $09, $09, $02, $22, $22, $22, $22, $02, $02, $02, $02, $02, $29, $85, $85
	db $85, $85, $01, $01, $01, $01, $01, $01, $22, $22, $22, $22, $02, $02, $02, $02
	db $01, $01, $85, $85, $85, $85, $01, $01, $01, $01, $01, $01, $22, $22, $22, $22
	db $02, $02, $02, $02, $01, $01, $85, $85, $85, $85, $01, $01, $01, $01, $01, $01
	db $22, $22, $22, $22, $02, $02, $02, $02, $01, $01, $05, $05, $05, $05, $03, $04
	db $04, $04, $04, $04, $04, $04, $04, $04, $04, $0c, $0c, $0c, $0c, $0c, $05, $05
	db $05, $05, $06, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $0c, $0c, $0c
	db $0c, $0c, $05, $05, $05, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04, $04
	db $04, $04, $04, $04, $04, $04, $09, $0a, $5e, $74, $04, $74, $86, $86, $86, $86
	db $86, $86, $86, $86, $86, $86, $87, $87, $87, $87, $87, $87, $87, $87, $87, $87
	db $87, $48, $40, $38, $30, $30, $38, $40, $48, $87, $87, $49, $41, $39, $31, $31
	db $39, $41, $49, $87, $87, $4a, $42, $3a, $32, $32, $3a, $42, $4a, $87, $87, $4b
	db $43, $3b, $33, $33, $3b, $43, $4b, $87, $e8, $4c, $44, $3c, $34, $34, $3c, $44
	db $4c, $e8, $e8, $4d, $45, $3d, $35, $35, $3d, $45, $4d, $e8, $e8, $4e, $46, $3e
	db $36, $36, $3e, $46, $4e, $e8, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $22, $22, $22, $22, $02
	db $02, $02, $02, $02, $02, $22, $22, $22, $22, $02, $02, $02, $02, $02, $02, $22
	db $22, $22, $22, $02, $02, $02, $02, $02, $02, $22, $22, $22, $22, $02, $02, $02
	db $02, $02, $02, $22, $22, $22, $22, $02, $02, $02, $02, $02, $02, $22, $22, $22
	db $22, $02, $02, $02, $02, $02, $02, $22, $22, $22, $22, $02, $02, $02, $02, $02
	db $09, $0a, $18, $75, $be, $74, $86, $86, $86, $86, $86, $86, $86, $86, $86, $86
	db $87, $6e, $87, $87, $87, $87, $87, $87, $6e, $87, $87, $6e, $66, $5e, $56, $56
	db $5e, $66, $6e, $87, $87, $68, $60, $58, $50, $50, $58, $60, $68, $87, $87, $69
	db $61, $59, $51, $51, $59, $61, $69, $87, $87, $6a, $62, $5a, $52, $52, $5a, $62
	db $6a, $87, $e8, $6b, $63, $5b, $53, $53, $5b, $63, $6b, $e8, $e8, $6c, $64, $5c
	db $54, $54, $5c, $64, $6c, $e8, $e8, $6d, $65, $5d, $55, $55, $5d, $65, $6d, $e8
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $22, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $22, $22, $22, $22, $02, $02, $02, $02, $02, $02, $22
	db $22, $22, $22, $02, $02, $02, $02, $02, $02, $22, $22, $22, $22, $02, $02, $02
	db $02, $02, $02, $22, $22, $22, $22, $02, $02, $02, $02, $02, $02, $22, $22, $22
	db $22, $02, $02, $02, $02, $02, $02, $22, $22, $22, $22, $02, $02, $02, $02, $02
	db $02, $22, $22, $22, $22, $02, $02, $02, $02, $02, $09, $0a, $d2, $75, $78, $75
	db $86, $86, $86, $86, $86, $86, $86, $86, $86, $86, $87, $87, $87, $87, $87, $87
	db $87, $87, $87, $87, $87, $6e, $87, $87, $87, $87, $87, $87, $6e, $87, $87, $6e
	db $66, $5e, $56, $56, $5e, $66, $6e, $87, $87, $6f, $67, $5f, $57, $57, $5f, $67
	db $6f, $87, $87, $7c, $74, $78, $70, $70, $78, $74, $7c, $87, $f1, $7d, $75, $79
	db $71, $71, $79, $75, $7d, $f1, $f2, $7e, $76, $7a, $72, $72, $7a, $76, $7e, $f2
	db $f8, $7f, $77, $7b, $73, $73, $7b, $77, $7f, $f8, $02, $02, $02, $02, $02, $02
	db $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $22
	db $02, $02, $02, $02, $02, $02, $02, $02, $22, $22, $22, $22, $22, $02, $02, $02
	db $02, $02, $22, $22, $22, $22, $22, $02, $02, $02, $02, $02, $22, $22, $22, $22
	db $22, $02, $02, $02, $02, $02, $22, $22, $22, $22, $22, $02, $02, $02, $02, $02
	db $22, $22, $22, $22, $22, $02, $02, $02, $02, $02, $22, $22, $22, $22, $22, $02
	db $02, $02, $02, $02, $09, $0a, $8c, $76, $32, $76, $86, $86, $86, $86, $86, $86
	db $86, $86, $86, $86, $87, $87, $10, $08, $00, $00, $08, $10, $87, $87, $87, $6e
	db $11, $09, $01, $01, $09, $11, $6e, $87, $87, $6e, $12, $0a, $02, $02, $0a, $12
	db $6e, $87, $87, $87, $13, $0b, $03, $03, $0b, $13, $87, $87, $87, $87, $14, $0c
	db $04, $04, $0c, $14, $87, $87, $e8, $e8, $15, $0d, $05, $05, $0d, $15, $e8, $e8
	db $e8, $e8, $16, $0e, $06, $06, $0e, $16, $e8, $e8, $e8, $e8, $17, $0f, $07, $07
	db $0f, $17, $e8, $e8, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
	db $22, $22, $22, $02, $02, $02, $02, $02, $02, $22, $22, $22, $22, $02, $02, $02
	db $02, $02, $22, $22, $22, $22, $22, $02, $02, $02, $02, $02, $22, $02, $22, $22
	db $22, $02, $02, $02, $02, $02, $02, $02, $22, $22, $22, $02, $02, $02, $02, $02
	db $02, $02, $22, $22, $22, $02, $02, $02, $02, $02, $02, $02, $22, $22, $22, $02
	db $02, $02, $02, $02, $02, $02, $22, $22, $22, $02, $02, $02, $02, $02, $09, $0a
	db $46, $77, $ec, $76, $86, $86, $86, $d4, $d5, $37, $3f, $86, $86, $86, $87, $6e
	db $28, $20, $18, $18, $20, $28, $6e, $87, $87, $6e, $29, $21, $19, $19, $21, $29
	db $6e, $87, $87, $87, $2a, $22, $1a, $1a, $22, $2a, $87, $87, $87, $87, $2b, $23
	db $1b, $1b, $23, $2b, $87, $87, $87, $87, $2c, $24, $1c, $1c, $24, $2c, $87, $87
	db $e8, $e8, $2d, $25, $1d, $1d, $25, $2d, $e8, $e8, $e8, $e8, $2e, $26, $1e, $1e
	db $26, $2e, $e8, $e8, $e8, $e8, $2f, $27, $1f, $1f, $27, $2f, $e8, $e8, $02, $02
	db $02, $0a, $0a, $02, $02, $02, $02, $02, $02, $22, $22, $22, $22, $02, $02, $02
	db $02, $02, $22, $22, $22, $22, $22, $02, $02, $02, $02, $02, $22, $02, $22, $22
	db $22, $02, $02, $02, $02, $02, $02, $02, $22, $22, $22, $02, $02, $02, $02, $02
	db $02, $02, $22, $22, $22, $02, $02, $02, $02, $02, $02, $02, $22, $22, $22, $02
	db $02, $02, $02, $02, $02, $02, $22, $22, $22, $02, $02, $02, $02, $02, $02, $02
	db $22, $22, $22, $02, $02, $02, $02, $02, $09, $0a, $00, $78, $a6, $77, $86, $86
	db $86, $86, $86, $86, $86, $86, $86, $86, $80, $88, $90, $98, $a0, $a8, $b0, $b8
	db $c0, $87, $81, $89, $91, $99, $a1, $a9, $b1, $b9, $c1, $87, $82, $8a, $92, $9a
	db $a2, $aa, $b2, $ba, $c2, $87, $83, $8b, $93, $9b, $a3, $ab, $b3, $bb, $c3, $87
	db $84, $8c, $94, $9c, $a4, $ac, $b4, $bc, $c4, $87, $85, $8d, $95, $9d, $a5, $ad
	db $b5, $bd, $c5, $e8, $86, $8e, $96, $9e, $a6, $ae, $b6, $be, $c6, $e8, $87, $8f
	db $97, $9f, $a7, $af, $b7, $bf, $c7, $e8, $02, $02, $02, $02, $02, $02, $02, $02
	db $02, $02, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $02, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $02, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $02
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $02, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $02, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $02, $0a, $0a
	db $0a, $0a, $0a, $0a, $0a, $0a, $0a, $02, $0a, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $0a, $02, $09, $0a, $ba, $78, $60, $78, $86, $86, $86, $86, $86, $86, $86, $86
	db $86, $86, $87, $c0, $b8, $b0, $a8, $a0, $98, $90, $88, $80, $87, $c1, $b9, $b1
	db $a9, $a1, $99, $91, $89, $81, $87, $c2, $ba, $b2, $aa, $a2, $9a, $92, $8a, $82
	db $87, $c3, $bb, $b3, $ab, $a3, $9b, $93, $8b, $83, $87, $c4, $bc, $b4, $ac, $a4
	db $9c, $94, $8c, $84, $e8, $c5, $bd, $b5, $ad, $a5, $9d, $95, $8d, $85, $e8, $c6
	db $be, $b6, $ae, $a6, $9e, $96, $8e, $86, $e8, $c7, $bf, $b7, $af, $a7, $9f, $97
	db $8f, $87, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $22, $2a, $2a, $2a
	db $2a, $2a, $2a, $2a, $2a, $2a, $22, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a
	db $22, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $22, $2a, $2a, $2a, $2a, $2a
	db $2a, $2a, $2a, $2a, $22, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $22, $2a
	db $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $22, $2a, $2a, $2a, $2a, $2a, $2a, $2a
	db $2a, $2a, $22, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $2a, $03, $00, $00, $40
	db $02, $00, $08, $42, $02, $00, $10, $44, $02, $0c, $00, $00, $00, $03, $00, $08
	db $02, $03, $00, $10, $04, $03, $00, $18, $06, $03, $00, $20, $08, $03, $00, $28
	db $0a, $03, $10, $00, $0c, $03, $10, $08, $0e, $03, $10, $10, $10, $03, $10, $18
	db $12, $03, $10, $20, $14, $03, $10, $28, $16, $03, $08, $00, $00, $46, $00, $00
	db $08, $48, $00, $00, $10, $4a, $00, $00, $18, $4c, $00, $10, $00, $4e, $00, $10
	db $08, $50, $00, $10, $10, $52, $00, $10, $18, $54, $00, $02, $00, $00, $56, $00
	db $00, $08, $58, $00, $02, $00, $00, $5a, $00, $00, $08, $5c, $00, $02, $00, $00
	db $18, $01, $00, $08, $1a, $01, $06, $00, $00, $1c, $01, $00, $08, $1e, $01, $00
	db $10, $20, $01, $00, $18, $22, $01, $00, $20, $24, $01, $00, $28, $26, $01, $06
	db $00, $00, $28, $01, $00, $08, $2a, $01, $00, $10, $2c, $01, $00, $18, $2e, $01
	db $00, $20, $30, $01, $00, $28, $32, $01, $06, $00, $00, $34, $01, $00, $08, $36
	db $01, $00, $10, $38, $01, $00, $18, $3a, $01, $00, $20, $3c, $01, $00, $28, $3e
	db $01, $8e, $79, $a7, $79, $c0, $79, $0a, $b8, $74, $00, $1e, $72, $75, $00, $02
	db $2c, $76, $00, $1e, $e6, $76, $00, $04, $2c, $76, $00, $0c, $72, $75, $00, $04
	db $b8, $74, $00, $01, $fe, $73, $00, $ff, $7c, $fe, $73, $00, $06, $2c, $76, $00
	db $06, $a0, $77, $00, $06, $2c, $76, $00, $06, $5a, $78, $00, $04, $2c, $76, $00
	db $0c, $e6, $76, $00, $04, $2c, $76, $00, $06, $72, $75, $00, $06, $2c, $76, $00
	db $01, $fe, $73, $00, $ff

; ($35:$6000 BG + $35:$6040 OBJ palettes carved into src/gfx/portrait/ferious.asm
; as FeriousPortraitPaletteBg / FeriousPortraitPaletteObj.)

SECTION "analyzed_0d623e", ROMX[$623e], BANK[$35]

Data_35_623e:
	db $08, $09, $8c, $62, $44, $62, $da, $e2, $ea, $f2, $fa, $02, $0a, $12, $80, $db
	db $e3, $eb, $f3, $fb, $03, $0b, $13, $80, $dc, $e4, $ec, $f4, $fc, $04, $0c, $14
	db $80, $dd, $e5, $ed, $f5, $fd, $05, $0d, $15, $1d, $de, $e6, $ee, $f6, $fe, $06
	db $0e, $16, $1e, $80, $e7, $ef, $f7, $ff, $07, $0f, $17, $1f, $80, $43, $4b, $53
	db $5b, $26, $2e, $36, $3e, $3c, $44, $4c, $54, $5c, $27, $2f, $37, $3f, $08, $09
	db $09, $09, $09, $09, $09, $09, $08, $08, $0a, $0a, $0a, $0a, $09, $09, $09, $08
	db $0a, $0a, $0a, $0a, $0a, $0a, $09, $09, $08, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $09, $09, $08, $0a, $0a, $0a, $0a, $0a, $0a, $09, $09, $08, $0a, $0a, $0a, $0a
	db $0a, $09, $09, $09, $08, $0a, $0a, $0b, $0b, $0b, $0d, $0d, $09, $0d, $0d, $0c
	db $0d, $0d, $0d, $0d, $0d, $0d, $04, $00, $00, $00, $0b, $00, $08, $16, $0b, $10
	db $00, $18, $0b, $10, $08, $1a, $0b, $04, $00, $00, $00, $0a, $00, $08, $26, $0a
	db $10, $00, $28, $0a, $10, $08, $2a, $0a, $0c, $00, $00, $46, $08, $00, $08, $48
	db $08, $00, $10, $4a, $08, $00, $18, $4c, $08, $10, $00, $4e, $08, $10, $08, $00
	db $09, $10, $10, $50, $09, $10, $18, $52, $09, $20, $00, $00, $08, $20, $08, $54
	db $09, $20, $10, $56, $09, $20, $18, $00, $09, $03, $00, $00, $34, $0b, $00, $08
	db $36, $0b, $00, $10, $38, $0b, $08, $09, $82, $63, $3a, $63, $da, $42, $49, $50
	db $fa, $02, $60, $67, $80, $db, $43, $4a, $51, $55, $5a, $61, $68, $80, $40, $44
	db $4b, $52, $56, $5b, $62, $69, $80, $41, $45, $4c, $53, $57, $5c, $63, $6a, $1d
	db $de, $46, $ee, $f6, $58, $5d, $64, $6b, $6e, $80, $47, $4d, $f7, $59, $5e, $65
	db $6c, $6f, $80, $48, $4e, $54, $5b, $5f, $66, $6d, $56, $3c, $44, $4f, $54, $5c
	db $27, $2f, $37, $3f, $08, $01, $01, $01, $09, $09, $01, $01, $08, $08, $02, $02
	db $02, $02, $01, $01, $01, $08, $02, $02, $02, $02, $02, $02, $01, $01, $08, $02
	db $02, $02, $02, $02, $02, $02, $01, $09, $08, $02, $0a, $0a, $02, $02, $02, $01
	db $01, $08, $02, $02, $0a, $02, $02, $02, $01, $01, $08, $02, $02, $03, $0b, $03
	db $05, $05, $09, $0d, $0d, $04, $0d, $0d, $0d, $0d, $0d, $0d, $04, $00, $00, $1c
	db $0b, $00, $08, $1e, $0b, $10, $00, $20, $0b, $10, $08, $00, $0b, $02, $00, $00
	db $2c, $0a, $10, $00, $2e, $0a, $0c, $00, $00, $58, $08, $00, $08, $5a, $08, $00
	db $10, $5c, $08, $00, $18, $5e, $08, $10, $00, $60, $08, $10, $08, $00, $09, $10
	db $10, $62, $09, $10, $18, $64, $09, $20, $00, $00, $08, $20, $08, $66, $09, $20
	db $10, $68, $09, $20, $18, $00, $09, $03, $00, $00, $3a, $0b, $00, $08, $3c, $0b
	db $00, $10, $3e, $0b, $08, $09, $70, $64, $28, $64, $da, $5f, $66, $6d, $fa, $02
	db $7d, $88, $80, $db, $60, $67, $6e, $72, $77, $7e, $89, $80, $57, $61, $68, $6f
	db $73, $78, $7f, $8a, $80, $5e, $62, $69, $70, $74, $79, $81, $91, $1d, $de, $63
	db $ee, $f6, $75, $7a, $82, $92, $9b, $80, $64, $6a, $f7, $76, $7b, $83, $99, $d0
	db $80, $65, $6b, $71, $5b, $7c, $84, $9a, $f1, $3c, $44, $6c, $54, $5c, $27, $2f
	db $37, $3f, $08, $09, $09, $09, $09, $09, $09, $09, $08, $08, $0a, $0a, $0a, $09
	db $09, $09, $09, $08, $0a, $0a, $0a, $0a, $0a, $0a, $09, $09, $08, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $09, $09, $08, $0a, $0a, $0a, $0a, $0a, $0a, $09, $09, $08
	db $0a, $0a, $0a, $0a, $0a, $09, $09, $09, $08, $0a, $0a, $0b, $0b, $0b, $0d, $0d
	db $09, $0d, $0d, $0c, $0d, $0d, $0d, $0d, $0d, $0d, $02, $00, $00, $22, $0b, $10
	db $00, $24, $0b, $02, $00, $00, $30, $0a, $10, $00, $32, $0a, $0c, $00, $00, $6a
	db $08, $00, $08, $6c, $08, $00, $10, $6e, $08, $00, $18, $70, $08, $10, $00, $72
	db $08, $10, $08, $00, $09, $10, $10, $74, $09, $10, $18, $76, $09, $20, $00, $00
	db $08, $20, $08, $78, $09, $20, $10, $7a, $09, $20, $18, $00, $09, $03, $00, $00
	db $40, $0b, $00, $08, $42, $0b, $00, $10, $44, $0b, $0a, $00, $00, $00, $08, $00
	db $08, $02, $08, $00, $10, $04, $08, $00, $18, $06, $08, $00, $20, $08, $08, $10
	db $00, $0a, $08, $10, $08, $0c, $08, $10, $10, $0e, $08, $10, $18, $10, $08, $10
	db $20, $12, $08, $01, $00, $00, $14, $0d

SECTION "analyzed_0e0000", ROMX[$4000], BANK[$38]

Func_38_4000:
	xor a
	ld [rVBK], a
	ld bc, $0400
	ld hl, $401a
	ld a, [$c55c]
	sub $05
	rlca
	rlca
	add a, h
	ld h, a
	ld de, $9400
	call VramCopy16
	ret

Data_38_401a:
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $1f, $00, $18, $07, $18, $07
	db $f8, $07, $f8, $07, $80, $7f, $80, $7f, $81, $7e, $10, $00, $10, $00, $10, $00
	db $ff, $00, $ff, $00, $c0, $3f, $c0, $3f, $c0, $3f, $10, $00, $10, $00, $10, $00
	db $ff, $00, $07, $00, $06, $01, $0e, $01, $fe, $01, $fc, $03, $c0, $3f, $c0, $3f
	db $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f, $10, $00, $10, $00, $10, $00
	db $ff, $00, $1f, $00, $0c, $03, $0c, $03, $fc, $03, $18, $07, $1c, $03, $1c, $03
	db $fc, $03, $01, $00, $01, $00, $01, $00, $ff, $00, $f0, $00, $f0, $00, $f0, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $ff, $00, $c0, $3f, $c0, $3f
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $bf, $40, $00, $ff, $00, $ff
	db $00, $ff, $00, $0f, $08, $07, $04, $03, $fd, $02, $7f, $00, $77, $08, $67, $18
	db $ed, $12, $e1, $1e, $01, $fe, $01, $fe, $01, $fe, $21, $1e, $61, $1e, $f1, $0e
	db $e1, $1e, $c1, $3e, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe
	db $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $c1, $3e, $c1, $3e
	db $c0, $3f, $c0, $3f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $80, $7f, $81, $7e, $83, $7c, $82, $7d, $12, $0d, $12, $0d, $10, $0f
	db $f0, $0f, $f0, $0f, $80, $7f, $80, $7f, $80, $7f, $80, $70, $00, $f0, $00, $f0
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $40, $bf, $80, $7f, $80, $7f, $00, $ff, $00, $ff, $00, $ff
	db $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f
	db $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f
	db $81, $7f, $83, $7d, $8f, $73, $f1, $00, $f9, $70, $fa, $f5, $dc, $d3, $d0, $cf
	db $e0, $1f, $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f
	db $c0, $3f, $c0, $3f, $e0, $1f, $10, $ef, $10, $ef, $10, $ef, $10, $ef, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $01, $fe, $07, $19, $1f, $07, $1f, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $7f, $80, $7f, $80, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $1f, $e0, $0f, $f0, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $02, $fc, $04, $fa, $0e, $f7, $07, $f7, $0f, $fd, $1f, $ed, $01, $fe, $01, $e0
	db $01, $fe, $1f, $fe, $1d, $fc, $1d, $fc, $2d, $cc, $7f, $bc, $7a, $f9, $f4, $f3
	db $f8, $f7, $f0, $ef, $e0, $9f, $80, $7f, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $01, $fe, $01, $fe, $00, $fe, $02, $fc, $02, $fc, $03, $fc, $03, $ff
	db $05, $f9, $05, $f9, $07, $fb, $07, $ff, $09, $f1, $0b, $f3, $0f, $f7, $0f, $f7
	db $0f, $ff, $1f, $ef, $1f, $ee, $2e, $cd, $ff, $20, $f0, $e0, $f0, $00, $f0, $00
	db $ff, $00, $ff, $00, $00, $ff, $04, $fb, $06, $f9, $06, $f9, $06, $f9, $07, $f8
	db $3f, $c0, $ed, $00, $ff, $00, $ff, $00, $3f, $c0, $3f, $c0, $1f, $c0, $cf, $00
	db $07, $48, $01, $44, $00, $44, $00, $c4, $80, $c7, $83, $c7, $83, $c7, $ff, $c7
	db $bf, $40, $00, $80, $00, $00, $00, $00, $00, $80, $80, $00, $80, $43, $40, $8c
	db $40, $9b, $40, $a4, $40, $98, $40, $a0, $40, $80, $40, $80, $00, $a0, $80, $30
	db $88, $00, $04, $00, $02, $00, $00, $01, $00, $00, $00, $00, $ff, $00, $f1, $ee
	db $f0, $ef, $d0, $cf, $f0, $ef, $e0, $df, $a0, $9f, $a0, $9f, $c0, $bf, $c0, $bf
	db $80, $7f, $80, $7f, $00, $ff, $00, $ff, $e3, $1c, $1f, $00, $18, $00, $18, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $7f, $80, $70, $8f, $f0, $0f
	db $f8, $07, $e0, $13, $c0, $21, $c0, $00, $80, $40, $80, $40, $00, $80, $00, $8c
	db $00, $12, $90, $01, $91, $02, $9e, $0e, $9f, $0f, $9f, $0f, $98, $07, $f8, $10
	db $f8, $07, $0f, $07, $0f, $07, $07, $07, $05, $01, $07, $fb, $03, $17, $03, $e7
	db $07, $0b, $07, $0b, $09, $07, $0a, $06, $02, $0e, $02, $0d, $07, $03, $07, $03
	db $07, $07, $06, $00, $05, $02, $06, $89, $4f, $00, $07, $12, $ff, $02, $ff, $f9
	db $fb, $f9, $ff, $7d, $5f, $9c, $3f, $de, $3f, $de, $3f, $de, $2f, $ce, $1f, $ee
	db $1c, $ed, $1c, $ef, $0e, $fd, $fe, $1f, $bd, $fc, $ff, $06, $1e, $01, $1c, $03
	db $ff, $00, $01, $00, $c1, $00, $ff, $00, $3f, $c0, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $7f, $40, $3f, $20, $1f, $20, $1f
	db $20, $1f, $20, $1f, $20, $1f, $20, $9f, $20, $9f, $20, $9f, $a0, $1f, $a0, $1f
	db $c0, $3f, $80, $7f, $80, $7f, $c0, $bf, $c0, $bf, $c0, $bf, $c0, $bf, $c0, $bf
	db $c0, $bf, $c0, $bf, $c0, $bf, $40, $3f, $40, $3f, $c0, $38, $c0, $b8, $c0, $b8
	db $c7, $b8, $47, $38, $70, $8f, $c0, $3f, $c0, $3f, $40, $bf, $20, $df, $a0, $5f
	db $80, $7f, $c0, $3f, $c0, $bf, $c0, $bf, $a0, $9f, $e0, $5f, $f0, $6f, $70, $af
	db $58, $97, $38, $d7, $28, $c7, $10, $ef, $00, $ff, $00, $f0, $00, $f0, $00, $f0
	db $ff, $00, $fe, $01, $c0, $3f, $80, $7f, $80, $7f, $00, $f0, $00, $f0, $00, $f0
	db $0f, $f0, $01, $00, $c1, $00, $c1, $00, $7f, $80, $70, $80, $00, $f0, $00, $f0
	db $0f, $f0, $01, $80, $01, $80, $01, $80, $7f, $80, $70, $80, $00, $f0, $00, $f0
	db $0f, $f0, $09, $f0, $01, $f0, $01, $e0, $1f, $e0, $10, $e0, $00, $f0, $00, $f0
	db $0f, $f0, $01, $00, $01, $00, $01, $00, $ff, $00, $10, $00, $10, $00, $10, $00
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $fc, $00, $fc, $00, $f8
	db $0f, $f0, $01, $00, $01, $00, $01, $00, $ff, $00, $f0, $00, $00, $f0, $00, $f0
	db $0f, $f0, $0f, $f0, $0f, $f0, $01, $fe, $01, $fe, $10, $00, $10, $00, $10, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $1f, $00, $18, $07, $18, $07
	db $f8, $07, $f8, $07, $80, $7f, $80, $7f, $81, $7e, $10, $00, $10, $00, $10, $00
	db $ff, $00, $ff, $00, $c0, $3f, $c0, $3f, $c0, $3f, $10, $00, $10, $00, $10, $00
	db $ff, $00, $07, $00, $06, $01, $0e, $01, $fe, $01, $fc, $03, $c0, $3f, $c0, $3f
	db $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f, $10, $00, $10, $00, $10, $00
	db $ff, $00, $1f, $00, $0c, $03, $0c, $03, $fc, $03, $18, $07, $1c, $03, $1c, $03
	db $fc, $03, $01, $00, $01, $00, $01, $00, $ff, $00, $f0, $00, $f0, $00, $f0, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $ff, $00, $c0, $3f, $c0, $3f
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $bf, $40, $00, $ff, $00, $ff
	db $00, $ff, $00, $0f, $08, $07, $04, $03, $fc, $03, $7c, $03, $70, $0f, $60, $1f
	db $e0, $1f, $e0, $1f, $00, $ff, $00, $ff, $00, $ff, $20, $1f, $60, $1f, $f0, $0f
	db $e0, $1f, $c0, $3f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $c0, $3f, $c0, $3f
	db $c0, $3f, $c0, $3f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $10, $0f, $10, $0f, $10, $0f
	db $f0, $0f, $f0, $0f, $80, $7f, $80, $7f, $80, $7f, $80, $70, $00, $f0, $00, $f0
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $03, $fc, $07, $f8, $0f, $f0, $1f, $e0
	db $3f, $c0, $3b, $c0, $78, $80, $6f, $a0, $7e, $be, $6f, $8f, $7c, $80, $77, $86
	db $7f, $87, $0f, $f7, $03, $ff, $07, $fb, $03, $fd, $00, $fe, $02, $fc, $01, $fe
	db $01, $fe, $00, $ff, $01, $fe, $01, $fe, $01, $fe, $00, $ff, $00, $ff, $01, $fe
	db $01, $fe, $02, $fc, $02, $fc, $02, $fc, $00, $fe, $04, $f8, $04, $f8, $00, $fc
	db $04, $f8, $03, $fc, $05, $f9, $07, $fb, $0d, $f5, $0f, $f7, $07, $f7, $1f, $ef
	db $1f, $ef, $1f, $ef, $1e, $ee, $1f, $ef, $07, $f6, $0f, $f6, $0d, $f4, $0e, $f5
	db $0e, $f5, $0e, $f5, $0e, $f7, $0f, $f6, $08, $f0, $07, $18, $18, $07, $1f, $00
	db $ff, $00, $ff, $00, $00, $ff, $cc, $03, $92, $01, $8f, $00, $90, $0f, $c8, $07
	db $e4, $13, $f2, $01, $e7, $00, $e3, $1c, $ff, $ff, $ff, $ff, $e3, $1c, $e7, $00
	db $e3, $18, $3f, $3f, $ff, $ff, $ff, $ff, $ff, $ff, $7f, $7f, $fe, $fe, $7e, $7f
	db $3f, $be, $f5, $04, $07, $18, $e0, $60, $0e, $0e, $80, $00, $80, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $00, $02, $00
	db $0c, $00, $ff, $00, $e6, $da, $83, $bc, $c0, $bf, $80, $ff, $c0, $bf, $80, $ff
	db $00, $ff, $80, $7f, $00, $ff, $80, $7f, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $80, $7f, $c0, $bf, $bf, $80, $b0, $20, $f0, $00, $f0, $00
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $80, $7f, $e1, $1e, $30, $cf
	db $00, $ff, $00, $ff, $f8, $07, $38, $1f, $df, $80, $ff, $ff, $ff, $00, $ff, $ce
	db $d7, $a6, $4b, $33, $87, $7b, $81, $7f, $81, $7e, $00, $ff, $80, $7f, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $80, $7f, $00, $ff, $40, $3f, $40, $3f
	db $40, $3f, $40, $3f, $a0, $1f, $a0, $1f, $80, $3f, $10, $0f, $00, $1f, $10, $0f
	db $08, $07, $f0, $0f, $e8, $e7, $f8, $f7, $f0, $77, $b0, $37, $7c, $bb, $7a, $b9
	db $7e, $bd, $5e, $9d, $3e, $dd, $3e, $dd, $1d, $ec, $1f, $ee, $0f, $f6, $0f, $f7
	db $07, $fb, $07, $fb, $03, $fd, $03, $fd, $e7, $1b, $1f, $00, $18, $00, $18, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $7f, $80, $9a, $64, $6a, $8c
	db $17, $f1, $1b, $cd, $3e, $d8, $0b, $fc, $f5, $01, $d1, $c3, $ee, $00, $3a, $d4
	db $51, $8e, $f0, $6f, $d0, $cf, $e0, $df, $60, $5f, $c0, $3f, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $80, $7f
	db $80, $7f, $80, $7f, $80, $7f, $c0, $bf, $fb, $c4, $fe, $06, $1f, $00, $18, $07
	db $ff, $00, $01, $00, $c1, $00, $ff, $00, $bf, $40, $80, $7f, $80, $7f, $80, $7f
	db $80, $7f, $80, $7f, $80, $7f, $e0, $9f, $40, $7f, $e0, $9f, $80, $7f, $80, $7f
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $f8, $00, $f8, $00, $f8
	db $07, $f8, $07, $f8, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $80, $70, $00, $f0, $00, $f0
	db $ff, $00, $fe, $01, $c0, $3f, $80, $7f, $80, $7f, $00, $f0, $00, $f0, $00, $f0
	db $0f, $f0, $01, $00, $c1, $00, $c1, $00, $7f, $80, $70, $80, $00, $f0, $00, $f0
	db $0f, $f0, $01, $80, $01, $80, $01, $80, $7f, $80, $70, $80, $00, $f0, $00, $f0
	db $0f, $f0, $09, $f0, $01, $f0, $01, $e0, $1f, $e0, $10, $e0, $00, $f0, $00, $f0
	db $0f, $f0, $01, $00, $01, $00, $01, $00, $ff, $00, $10, $00, $10, $00, $10, $00
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $fc, $00, $fc, $00, $f8
	db $0f, $f0, $01, $00, $01, $00, $01, $00, $ff, $00, $f0, $00, $00, $f0, $00, $f0
	db $0f, $f0, $0f, $f0, $0f, $f0, $01, $fe, $01, $fe, $10, $00, $10, $00, $10, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $1f, $00, $18, $07, $18, $07
	db $f8, $07, $f8, $07, $80, $7f, $80, $7f, $81, $7e, $10, $00, $10, $00, $10, $00
	db $ff, $00, $ff, $00, $c0, $3f, $c0, $3f, $c0, $3f, $10, $00, $10, $00, $10, $00
	db $ff, $00, $07, $00, $06, $01, $0e, $01, $fe, $01, $fc, $03, $c0, $3f, $c0, $3f
	db $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f, $10, $00, $10, $00, $10, $00
	db $ff, $00, $1f, $00, $0c, $03, $0c, $03, $fc, $03, $18, $07, $1c, $03, $1c, $03
	db $fc, $03, $00, $01, $01, $00, $01, $00, $ff, $00, $f0, $00, $f0, $00, $f0, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $ff, $00, $c0, $3f, $c0, $3f
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $bf, $40, $00, $ff, $00, $ff
	db $00, $ff, $00, $1f, $00, $1f, $00, $1f, $e0, $1f, $60, $1f, $60, $1f, $60, $1f
	db $e0, $1f, $e0, $1f, $00, $ff, $00, $ff, $00, $ff, $28, $17, $6e, $11, $ef, $16
	db $e7, $1b, $c3, $3d, $01, $fe, $00, $ff, $00, $ff, $00, $ff, $07, $f8, $1b, $e3
	db $e7, $07, $3f, $cc, $0e, $f1, $00, $ff, $00, $ff, $00, $ff, $c0, $3f, $c0, $3f
	db $df, $20, $cf, $37, $06, $f8, $01, $fe, $07, $f8, $0f, $f6, $0f, $f6, $1e, $ed
	db $1e, $ed, $1e, $ed, $9f, $6e, $97, $66, $8f, $77, $0f, $17, $17, $0b, $17, $0b
	db $f3, $0d, $f1, $0e, $80, $7f, $80, $7f, $80, $7f, $80, $70, $00, $f0, $00, $f0
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $0c, $f3, $0c, $f3, $12, $e1
	db $1e, $ed, $1d, $ec, $1f, $ef, $1d, $ec, $0e, $f1, $06, $fa, $0b, $f3, $f6, $06
	db $ff, $ef, $ff, $dc, $fd, $d1, $ff, $2f, $7f, $9f, $6f, $8e, $fe, $3c, $7f, $3d
	db $67, $25, $ef, $2e, $43, $83, $6f, $bf, $57, $8f, $3f, $d7, $3f, $d8, $7f, $9f
	db $1f, $0f, $eb, $e6, $ff, $f2, $f7, $08, $c5, $38, $07, $fb, $07, $fb, $05, $f9
	db $07, $fa, $05, $f8, $02, $fd, $00, $ff, $bf, $40, $dd, $9c, $ff, $ff, $f7, $f6
	db $ff, $ff, $ff, $7e, $67, $87, $1f, $e0, $00, $ff, $00, $1f, $18, $07, $1f, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $7f, $80, $7f, $80, $00, $ff, $02, $fd
	db $02, $fd, $05, $f8, $07, $fa, $06, $fa, $06, $fa, $03, $fd, $03, $fd, $02, $fc
	db $03, $fc, $9f, $62, $f6, $92, $fb, $59, $f9, $68, $ed, $a5, $fe, $d8, $ff, $ee
	db $3f, $33, $ff, $0c, $3c, $30, $ff, $fd, $ff, $0d, $7f, $76, $ff, $da, $ff, $aa
	db $ff, $da, $7f, $76, $ff, $0e, $ff, $fd, $ff, $f9, $fc, $e0, $fb, $13, $ba, $b0
	db $7f, $7a, $ff, $00, $ff, $aa, $ff, $55, $ff, $00, $6f, $0f, $ff, $87, $8f, $70
	db $07, $fb, $04, $f8, $02, $fc, $02, $fc, $01, $fe, $f1, $0e, $10, $0f, $f0, $0f
	db $40, $3f, $c0, $3f, $80, $7f, $00, $ff, $1f, $e0, $10, $e0, $f0, $00, $f0, $00
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $80, $7f, $40, $3f, $e0, $df, $e0, $df, $e0, $df
	db $e0, $1f, $fc, $a3, $bf, $2c, $3f, $1d, $df, $9b, $fb, $76, $33, $0d, $fd, $39
	db $fb, $e3, $ef, $18, $1b, $63, $ff, $df, $ff, $d8, $ff, $b7, $ff, $ad, $ff, $aa
	db $fb, $a9, $ee, $a6, $ff, $b8, $ff, $df, $f7, $c7, $fc, $e0, $fb, $f0, $f9, $d1
	db $ff, $2f, $ff, $00, $ff, $aa, $ff, $55, $ff, $00, $f1, $f0, $9f, $81, $f1, $0e
	db $60, $5f, $60, $5f, $40, $3f, $c0, $bf, $c0, $bf, $e0, $df, $a1, $1e, $42, $bc
	db $01, $fe, $00, $ff, $00, $ff, $00, $ff, $e0, $1f, $1f, $00, $18, $00, $18, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $7f, $80, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $1f, $e0
	db $6b, $88, $fc, $7b, $fc, $fb, $94, $5b, $f8, $47, $d0, $cf, $f8, $f7, $f7, $f0
	db $ff, $fb, $ff, $1d, $ff, $e5, $ff, $fa, $ff, $7c, $7f, $3c, $b7, $96, $ff, $de
	db $ff, $de, $47, $06, $ff, $7e, $ff, $fe, $fd, $f8, $fe, $f5, $fa, $09, $fa, $f9
	db $ff, $f8, $fc, $38, $df, $97, $ff, $01, $f7, $28, $d3, $cd, $e1, $de, $a0, $9f
	db $d0, $4f, $70, $8f, $10, $ef, $00, $ff, $00, $ff, $7e, $81, $dd, $1c, $fe, $fe
	db $fc, $1c, $ff, $7f, $ff, $07, $2f, $cf, $1f, $e0, $f8, $07, $18, $07, $18, $07
	db $ff, $00, $01, $00, $c1, $00, $ff, $00, $3f, $c0, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $80, $7f
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $60, $9f, $d0, $4f
	db $ec, $e3, $f0, $cf, $c0, $3f, $00, $ff, $00, $ff, $00, $ff, $f0, $0f, $fc, $f3
	db $86, $85, $04, $03, $f8, $87, $c0, $3f, $00, $ff, $00, $f8, $00, $f8, $00, $f8
	db $07, $f8, $87, $78, $c0, $bf, $e0, $df, $f0, $2f, $e0, $9f, $90, $8f, $f8, $67
	db $68, $a7, $48, $87, $48, $87, $48, $87, $58, $97, $f8, $77, $f8, $f7, $f0, $ef
	db $f0, $ef, $a0, $9f, $c0, $bf, $80, $7f, $00, $ff, $00, $f0, $00, $f0, $00, $f0
	db $ff, $00, $fe, $01, $c0, $3f, $80, $7f, $80, $7f, $00, $f0, $00, $f0, $00, $f0
	db $0f, $f0, $01, $00, $c1, $00, $c1, $00, $7f, $80, $70, $80, $00, $f0, $00, $f0
	db $0f, $f0, $01, $80, $01, $80, $01, $80, $7f, $80, $70, $80, $00, $f0, $00, $f0
	db $0f, $f0, $09, $f0, $01, $f0, $01, $e0, $1f, $e0, $10, $e0, $00, $f0, $00, $f0
	db $0f, $f0, $01, $00, $01, $00, $01, $00, $ff, $00, $10, $00, $10, $00, $10, $00
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $fc, $00, $fc, $00, $f8
	db $0f, $f0, $01, $00, $01, $00, $01, $00, $ff, $00, $f0, $00, $00, $f0, $00, $f0
	db $0f, $f0, $0f, $f0, $0f, $f0, $01, $fe, $01, $fe, $10, $00, $10, $00, $10, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $1f, $00, $18, $07, $18, $07
	db $f8, $07, $f8, $07, $80, $7f, $80, $7f, $81, $7e, $10, $00, $10, $00, $10, $00
	db $ff, $00, $ff, $00, $c0, $3f, $c0, $3f, $c0, $3f, $10, $00, $10, $00, $10, $00
	db $ff, $00, $07, $00, $06, $01, $0e, $01, $fe, $01, $fc, $03, $c0, $3f, $c0, $3f
	db $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f, $10, $00, $10, $00, $10, $00
	db $ff, $00, $1f, $00, $0c, $03, $0c, $03, $fc, $03, $18, $07, $1c, $03, $1c, $03
	db $fc, $03, $01, $00, $01, $00, $01, $00, $ff, $00, $f0, $00, $f0, $00, $f0, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $ff, $00, $c0, $3f, $c0, $3f
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $bf, $40, $00, $ff, $00, $ff
	db $00, $ff, $00, $0f, $08, $07, $04, $03, $fc, $03, $7c, $03, $70, $0f, $60, $1f
	db $e0, $1f, $e0, $1f, $00, $ff, $00, $ff, $00, $ff, $20, $1f, $60, $1f, $f0, $0f
	db $e0, $1f, $c0, $3f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $01, $fe, $00, $ff, $00, $ff, $c0, $3f, $c0, $3f
	db $c0, $3f, $cf, $30, $05, $f9, $06, $f8, $01, $fe, $00, $ff, $00, $ff, $00, $ff
	db $05, $f8, $bf, $40, $80, $7f, $80, $7f, $80, $7f, $10, $0f, $10, $0f, $10, $0f
	db $f0, $0f, $f0, $0f, $80, $7f, $80, $7f, $80, $7f, $80, $70, $00, $f0, $00, $f0
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $02, $fd, $02, $fd
	db $02, $fd, $02, $fd, $07, $f8, $07, $f8, $07, $f8, $07, $f8, $07, $f8, $03, $fc
	db $03, $fc, $0f, $f0, $fa, $00, $ff, $00, $0f, $f0, $03, $fc, $00, $ff, $00, $ff
	db $0f, $f0, $f0, $00, $ff, $ff, $f6, $f1, $f9, $06, $01, $fe, $03, $fc, $7f, $80
	db $7f, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $1f, $18, $07, $1f, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $7f, $80, $7f, $80, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $20, $df, $20, $df, $20, $df
	db $20, $df, $70, $8f, $70, $8f, $70, $8f, $70, $8f, $70, $8f, $30, $cf, $f0, $0f
	db $f0, $0f, $f8, $07, $f8, $07, $f8, $07, $fc, $03, $fc, $03, $ea, $09, $ff, $30
	db $ff, $40, $ff, $80, $bf, $40, $7f, $80, $ff, $00, $ff, $00, $fc, $03, $e0, $1f
	db $c0, $3f, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $1f, $e0, $10, $e0, $f0, $00, $f0, $00
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $38, $c7, $ff, $00, $6f, $95, $27, $da, $22, $dc, $21, $de
	db $20, $df, $20, $df, $10, $ef, $10, $ef, $10, $ef, $08, $f7, $08, $f7, $08, $f7
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $fe, $01, $00, $ff, $00, $ff
	db $15, $e0, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $e0, $1f, $1f, $00, $18, $00, $18, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $7f, $80, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $01, $fe, $01, $fe, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $e0, $9f, $d8, $47, $dc, $93, $be, $a1
	db $bf, $00, $7e, $81, $1c, $e3, $0c, $f3, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $80, $7f, $fc, $03, $ff, $00, $ff, $00, $ff, $00, $00, $ff, $07, $f8, $1f, $e0
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $f8, $07, $18, $07, $18, $07
	db $ff, $00, $01, $00, $c1, $00, $ff, $00, $bf, $40, $80, $7f, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $80, $7f, $80, $7f, $c0, $3f, $e0, $1f, $60, $9f
	db $70, $8f, $30, $cf, $30, $cf, $38, $c7, $38, $c7, $38, $c7, $1c, $e3, $1c, $e3
	db $1c, $e3, $1c, $e3, $1c, $e3, $1c, $e3, $1c, $e3, $18, $e0, $18, $e0, $18, $e0
	db $1f, $e0, $1f, $e0, $ec, $13, $f8, $07, $f8, $07, $f8, $07, $f8, $07, $f0, $0f
	db $80, $7f, $fe, $01, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $f0, $00, $f0, $00, $f0
	db $ff, $00, $fe, $01, $c0, $3f, $80, $7f, $80, $7f, $00, $f0, $00, $f0, $00, $f0
	db $0f, $f0, $01, $00, $c1, $00, $c1, $00, $7f, $80, $70, $80, $00, $f0, $00, $f0
	db $0f, $f0, $01, $80, $01, $80, $01, $80, $7f, $80, $70, $80, $00, $f0, $00, $f0
	db $0f, $f0, $09, $f0, $01, $f0, $01, $e0, $1f, $e0, $10, $e0, $00, $f0, $00, $f0
	db $0f, $f0, $01, $00, $01, $00, $01, $00, $ff, $00, $10, $00, $10, $00, $10, $00
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $fc, $00, $fc, $00, $f8
	db $0f, $f0, $01, $00, $01, $00, $01, $00, $ff, $00, $f0, $00, $00, $f0, $00, $f0
	db $0f, $f0, $0f, $f0, $0f, $f0, $01, $fe, $01, $fe, $10, $00, $10, $00, $10, $00

Data_38_501a:
	INCBIN "raw_gfx/Data_38_501a.2bpp", 0, 2048

Data_38_581a:
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $1f, $00, $18, $07, $18, $07
	db $f8, $07, $f8, $07, $80, $7f, $80, $7f, $81, $7e, $10, $00, $10, $00, $10, $00
	db $ff, $00, $ff, $00, $c0, $3f, $c0, $3f, $c0, $3f, $10, $00, $10, $00, $10, $00
	db $ff, $00, $07, $00, $06, $01, $0e, $01, $fe, $01, $fc, $03, $c0, $3f, $c0, $3f
	db $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f, $10, $00, $10, $00, $10, $00
	db $ff, $00, $1f, $00, $0c, $03, $0c, $03, $fc, $03, $18, $07, $1c, $03, $1c, $03
	db $fc, $03, $01, $00, $01, $00, $01, $00, $ff, $00, $f0, $00, $f0, $00, $f0, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $ff, $00, $c0, $3f, $c0, $3f
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $bf, $40, $00, $ff, $00, $ff
	db $00, $ff, $00, $0f, $08, $07, $04, $03, $fc, $03, $7c, $03, $70, $0f, $60, $1f
	db $e0, $1f, $e0, $1f, $00, $ff, $00, $ff, $00, $ff, $20, $1f, $60, $1f, $f0, $0f
	db $e0, $1f, $c0, $3f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $c0, $3f, $c0, $3f
	db $c0, $3f, $c0, $3f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $10, $0f, $10, $0f, $10, $0f
	db $f0, $0f, $f0, $0f, $80, $7f, $80, $7f, $80, $7f, $80, $70, $00, $f0, $00, $f0
	db $ff, $00, $ff, $00, $02, $fc, $01, $fe, $01, $fe, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $01, $fe, $03, $fc, $07, $f8, $0f, $f0
	db $1f, $e0, $3e, $c0, $38, $c1, $78, $88, $6c, $9c, $7e, $9e, $5f, $be, $7f, $87
	db $41, $a0, $40, $a1, $21, $c0, $3e, $c1, $2c, $cf, $3e, $dd, $3e, $dd, $3a, $d9
	db $5d, $9a, $7c, $bb, $79, $be, $45, $82, $4d, $82, $4c, $82, $76, $98, $ba, $7c
	db $fa, $7c, $fe, $48, $49, $86, $12, $ec, $7a, $84, $22, $dc, $21, $de, $25, $d9
	db $07, $fb, $0b, $f3, $0f, $f7, $0f, $f7, $0f, $f7, $0f, $f7, $0b, $f3, $0b, $f3
	db $0b, $f3, $07, $fb, $06, $fa, $0f, $f7, $1f, $ef, $13, $03, $1f, $00, $1f, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $7f, $00, $ff, $00, $ff, $7f, $ff, $7f
	db $7f, $bf, $7f, $bf, $5f, $90, $75, $80, $e4, $10, $e3, $10, $f0, $00, $f8, $04
	db $f8, $04, $38, $01, $3f, $00, $b9, $00, $79, $00, $3f, $06, $3d, $04, $ff, $00
	db $84, $04, $ff, $00, $00, $00, $80, $00, $80, $00, $80, $00, $00, $80, $ff, $00
	db $00, $00, $10, $10, $1b, $04, $61, $81, $02, $00, $04, $00, $01, $00, $00, $09
	db $12, $00, $64, $00, $00, $80, $08, $00, $10, $00, $60, $00, $ff, $00, $d3, $cc
	db $e1, $fe, $e2, $fc, $e3, $dd, $a3, $9d, $c3, $bd, $c1, $be, $80, $7f, $00, $ff
	db $80, $7f, $80, $7f, $80, $7f, $c0, $3f, $ff, $c0, $f0, $e0, $f0, $00, $f0, $00
	db $ff, $00, $ff, $00, $c0, $bf, $30, $cf, $78, $57, $b8, $b7, $e8, $87, $c8, $87
	db $08, $47, $48, $07, $d0, $0f, $20, $1f, $10, $0f, $68, $87, $30, $0f, $40, $3f
	db $40, $3f, $a0, $5f, $88, $17, $88, $07, $ba, $01, $de, $0d, $bd, $1c, $ff, $02
	db $61, $20, $e1, $00, $6f, $10, $6f, $1e, $9e, $6e, $97, $67, $8b, $73, $87, $7b
	db $03, $7d, $c0, $3f, $40, $3f, $40, $3f, $40, $3f, $80, $3f, $20, $1f, $20, $1f
	db $10, $2f, $10, $0f, $10, $0f, $10, $0f, $00, $1f, $08, $07, $f8, $07, $f8, $f7
	db $f8, $f7, $f8, $f7, $f8, $f7, $f8, $f7, $f8, $f7, $f4, $f3, $f4, $73, $7c, $bb
	db $5a, $99, $3e, $dd, $1f, $ec, $1e, $ee, $ff, $0f, $1f, $00, $18, $00, $18, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $7f, $80, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $01, $fe, $01, $fe, $00, $ff, $00, $ff
	db $00, $ff, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe
	db $01, $fe, $01, $fe, $01, $fe, $81, $7e, $81, $7e, $81, $fe, $a1, $9e, $f1, $ee
	db $e9, $c6, $85, $02, $4f, $80, $3f, $c6, $1f, $ed, $0b, $f3, $07, $fb, $03, $fc
	db $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe
	db $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $01, $fe, $03, $fc
	db $02, $fd, $02, $fd, $02, $fd, $e0, $1f, $f6, $e9, $ff, $06, $19, $00, $1e, $01
	db $ff, $00, $01, $00, $c1, $00, $ff, $00, $3f, $c0, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $80, $7f, $40, $bf
	db $c0, $3f, $20, $df, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $80, $7f, $80, $bf, $e0, $df, $e0, $d8, $c0, $b8, $80, $78
	db $07, $f8, $07, $f8, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $80, $7f
	db $80, $7f, $80, $7f, $80, $7f, $00, $ff, $00, $ff, $00, $f0, $00, $f0, $00, $f0
	db $ff, $00, $fe, $01, $c0, $3f, $80, $7f, $80, $7f, $00, $f0, $00, $f0, $00, $f0
	db $0f, $f0, $01, $00, $c1, $00, $c1, $00, $7f, $80, $70, $80, $00, $f0, $00, $f0
	db $0f, $f0, $01, $80, $01, $80, $01, $80, $7f, $80, $70, $80, $00, $f0, $00, $f0
	db $0f, $f0, $09, $f0, $01, $f0, $01, $e0, $1f, $e0, $10, $e0, $00, $f0, $00, $f0
	db $0f, $f0, $01, $00, $01, $00, $01, $00, $ff, $00, $10, $00, $10, $00, $10, $00
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $fc, $00, $fc, $00, $f8
	db $0f, $f0, $01, $00, $01, $00, $01, $00, $ff, $00, $f0, $00, $00, $f0, $00, $f0
	db $0f, $f0, $0f, $f0, $0f, $f0, $01, $fe, $01, $fe, $10, $00, $10, $00, $10, $00

Data_38_5c1a:
	INCBIN "raw_gfx/Data_38_5c1a.2bpp", 0, 1024

Data_38_601a:
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $1f, $00, $18, $07, $18, $07
	db $f8, $07, $f8, $07, $80, $7f, $80, $7f, $81, $7e, $10, $00, $10, $00, $10, $00
	db $ff, $00, $ff, $00, $c0, $3f, $c0, $3f, $c0, $3f, $10, $00, $10, $00, $10, $00
	db $ff, $00, $07, $00, $06, $01, $0e, $01, $fe, $01, $fc, $03, $c0, $3f, $c0, $3f
	db $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f, $10, $00, $10, $00, $10, $00
	db $ff, $00, $1f, $00, $0c, $03, $0c, $03, $fc, $03, $18, $07, $1c, $03, $1c, $03
	db $fc, $03, $01, $00, $01, $00, $01, $00, $ff, $00, $f0, $00, $f0, $00, $f0, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $ff, $00, $c0, $3f, $c0, $3f
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $bf, $40, $00, $ff, $00, $ff
	db $00, $ff, $01, $0e, $08, $07, $04, $03, $fc, $03, $7c, $03, $70, $0f, $60, $1f
	db $e0, $1f, $e0, $1f, $00, $ff, $00, $ff, $00, $ff, $20, $1f, $60, $1f, $f0, $0f
	db $e0, $1f, $c0, $3f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $c0, $3f, $c0, $3f
	db $c0, $3f, $c0, $3f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $10, $0f, $10, $0f, $10, $0f
	db $f0, $0f, $f0, $0f, $80, $7f, $80, $7f, $80, $7f, $80, $70, $00, $f0, $00, $f0
	db $ff, $00, $ff, $00, $fc, $70, $34, $e0, $3c, $c0, $45, $80, $0f, $e1, $27, $c1
	db $1d, $ec, $ec, $13, $70, $80, $0f, $f2, $01, $fe, $07, $f8, $1f, $e0, $3f, $c0
	db $7f, $80, $7f, $80, $fc, $02, $f4, $00, $ee, $0c, $ff, $3e, $de, $1e, $de, $1e
	db $ff, $01, $c3, $01, $5f, $9d, $7f, $b8, $7d, $ba, $7d, $ba, $74, $b3, $7c, $bb
	db $7c, $bb, $7d, $ba, $7d, $ba, $75, $b2, $5d, $9a, $3d, $da, $25, $c2, $25, $c2
	db $39, $c6, $7d, $ba, $5d, $9a, $7d, $ba, $3d, $d2, $19, $e6, $05, $fa, $19, $e6
	db $09, $f6, $09, $f6, $02, $fc, $03, $fd, $03, $fd, $01, $fd, $07, $fb, $07, $fb
	db $07, $fb, $05, $f9, $03, $fd, $03, $fd, $03, $fd, $03, $1d, $1b, $05, $1f, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $ff, $80, $f5, $e0, $f4, $e3
	db $e4, $d3, $df, $20, $00, $00, $fb, $04, $e3, $00, $de, $00, $e0, $20, $e0, $01
	db $f0, $02, $f7, $00, $f7, $00, $f3, $08, $e3, $00, $e3, $00, $ff, $00, $ff, $1c
	db $ff, $1c, $ef, $ef, $00, $00, $ff, $00, $00, $00, $00, $00, $80, $00, $80, $00
	db $80, $00, $c0, $00, $00, $30, $0f, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $01, $00, $02, $00, $04, $00, $18, $00, $e0, $00, $ff, $ff
	db $00, $00, $ff, $00, $f8, $f7, $e8, $e7, $f0, $ef, $f0, $ef, $e0, $df, $e0, $df
	db $e0, $df, $80, $bf, $c0, $bf, $c0, $bf, $df, $a0, $f0, $c0, $f0, $00, $f0, $00
	db $ff, $00, $ff, $00, $c0, $bf, $c0, $bf, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $10, $ef, $d0, $2f, $20, $1f, $c0, $3f, $00, $ff, $7e, $01, $76, $75, $04, $03
	db $f8, $07, $00, $ff, $e0, $1f, $a8, $07, $e4, $23, $e8, $6b, $fe, $7d, $fe, $61
	db $c2, $41, $e2, $c1, $7e, $1f, $df, $2e, $5f, $2e, $57, $27, $4f, $37, $4b, $33
	db $47, $3b, $43, $3d, $41, $3e, $c0, $3f, $20, $5f, $20, $5f, $60, $1f, $50, $0f
	db $48, $97, $88, $07, $08, $07, $08, $07, $04, $03, $04, $03, $04, $03, $fc, $fb
	db $04, $03, $fc, $03, $ba, $39, $be, $3d, $fe, $7d, $7e, $bd, $7d, $bc, $1f, $de
	db $3e, $de, $1f, $ef, $0b, $f3, $07, $fb, $e6, $1a, $1f, $00, $18, $00, $18, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $7f, $80, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $01, $fe
	db $01, $fe, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $80, $7f, $80, $7f, $c0, $bf
	db $e0, $df, $f0, $ef, $7c, $73, $c2, $15, $21, $c2, $17, $ef, $03, $fc, $02, $fc
	db $01, $fe, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $80, $7f, $80, $7f, $80, $7f, $80, $7f, $c0, $bf, $f8, $07, $18, $07, $1c, $03
	db $ff, $00, $01, $00, $c1, $00, $ff, $00, $3f, $c0, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $80, $7f, $c0, $3f, $e0, $1f, $a0, $5f, $a0, $5f, $80, $7f, $80, $7f
	db $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $40, $bf
	db $40, $bf, $40, $bf, $40, $bf, $c0, $3f, $70, $0f, $d0, $08, $f0, $68, $e0, $d8
	db $c7, $38, $47, $b8, $40, $bf, $20, $df, $20, $df, $20, $df, $20, $df, $20, $df
	db $20, $df, $20, $df, $20, $df, $20, $df, $20, $df, $20, $df, $20, $df, $10, $ef
	db $10, $ef, $10, $ef, $38, $c7, $28, $d7, $28, $d7, $00, $f0, $00, $f0, $00, $f0
	db $ff, $00, $fe, $01, $c0, $3f, $80, $7f, $80, $7f, $00, $f0, $00, $f0, $00, $f0
	db $0f, $f0, $01, $00, $c1, $00, $c1, $00, $7f, $80, $70, $80, $00, $f0, $00, $f0
	db $0f, $f0, $01, $80, $01, $80, $01, $80, $7f, $80, $70, $80, $00, $f0, $00, $f0
	db $0f, $f0, $09, $f0, $01, $f0, $01, $e0, $1f, $e0, $10, $e0, $00, $f0, $00, $f0
	db $0f, $f0, $01, $00, $01, $00, $01, $00, $ff, $00, $10, $00, $10, $00, $10, $00
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $fc, $00, $fc, $00, $f8
	db $0f, $f0, $01, $00, $01, $00, $01, $00, $ff, $00, $f0, $00, $00, $f0, $00, $f0
	db $0f, $f0, $0f, $f0, $0f, $f0, $01, $fe, $01, $fe, $10, $00, $10, $00, $10, $00

Data_38_641a:
	INCBIN "raw_gfx/Data_38_641a.2bpp", 0, 1024

Data_38_681a:
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $1f, $00, $18, $07, $18, $07
	db $f8, $07, $f8, $07, $80, $7f, $80, $7f, $81, $7e, $10, $00, $10, $00, $10, $00
	db $ff, $00, $ff, $00, $c0, $3f, $c0, $3f, $c0, $3f, $10, $00, $10, $00, $10, $00
	db $ff, $00, $07, $00, $06, $01, $0e, $01, $fe, $01, $fc, $03, $c0, $3f, $c0, $3f
	db $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f, $c0, $3f, $10, $00, $10, $00, $10, $00
	db $ff, $00, $1f, $00, $0c, $03, $0c, $03, $fc, $03, $18, $07, $1c, $03, $1c, $03
	db $fc, $03, $01, $00, $01, $00, $01, $00, $ff, $00, $f0, $00, $f0, $00, $f0, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $ff, $00, $c0, $3f, $c0, $3f
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $bf, $40, $00, $ff, $00, $ff
	db $00, $ff, $00, $0f, $08, $07, $04, $03, $fc, $03, $7c, $03, $70, $0f, $60, $1f
	db $e3, $1c, $e3, $1c, $03, $fc, $00, $ff, $00, $ff, $20, $1f, $60, $1f, $f0, $0f
	db $e0, $1f, $c0, $3f, $00, $ff, $00, $ff, $00, $ff, $01, $fe, $03, $fc, $0f, $f1
	db $3e, $c2, $7f, $80, $7e, $81, $30, $cf, $00, $ff, $00, $ff, $c0, $3f, $c0, $3f
	db $c0, $3f, $c0, $3f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $80, $7f, $80, $7f, $80, $7f, $80, $7f, $10, $0f, $10, $0f, $10, $0f
	db $f0, $0f, $f0, $0f, $80, $7f, $80, $7f, $80, $7f, $80, $70, $00, $f0, $00, $f0
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $07, $f8, $3f, $c0, $fe, $01
	db $e0, $1f, $80, $7f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $01, $fe, $07, $f8, $1f, $e0, $3d, $c0, $f3, $01, $e3, $01, $83, $01, $03, $01
	db $01, $00, $c1, $40, $f0, $00, $1e, $e0, $07, $f8, $01, $fe, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $01, $fe, $01, $fe, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $1f, $18, $07, $1f, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $7f, $80, $7f, $80, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $7f, $80, $ff, $00, $f0, $0f, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $ff, $00, $ff, $00, $ff, $7f, $ff, $ff, $ff, $ff, $ff, $fb, $ff, $f1, $ff, $f1
	db $ff, $fb, $ff, $ff, $ff, $7f, $7f, $1f, $bf, $00, $ff, $00, $e0, $1f, $70, $8f
	db $58, $a7, $4c, $b3, $e6, $19, $e3, $1c, $e1, $1e, $e0, $1f, $60, $9f, $60, $9f
	db $60, $9f, $60, $9f, $60, $9f, $60, $9f, $60, $9f, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $1f, $e0, $10, $e0, $f0, $00, $f0, $00
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $c0, $3f, $f8, $07, $fe, $01, $1f, $e0
	db $03, $fc, $01, $fe, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $f8, $07, $ff, $00, $bf, $80, $e9, $e0, $fc, $f8, $fc, $f8, $f4, $f0, $dc, $d8
	db $f8, $f0, $e8, $e0, $d0, $c0, $e0, $80, $cf, $00, $f8, $07, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $80, $7f, $40, $bf, $20, $df, $00, $ff
	db $0c, $f3, $06, $f9, $01, $fe, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $e0, $1f, $1f, $00, $18, $00, $18, $00
	db $ff, $00, $01, $00, $01, $00, $01, $00, $ff, $00, $7f, $80, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $80, $7f
	db $e0, $1f, $fe, $01, $3f, $c0, $07, $f8, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $c0, $3f, $f0, $0f, $3c, $03, $0f, $00, $01, $00, $00, $00
	db $01, $01, $03, $00, $0c, $13, $e0, $1f, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $01, $fe, $00, $ff
	db $00, $ff, $00, $ff, $c0, $3f, $38, $c7, $07, $f8, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $f8, $07, $18, $07, $18, $07
	db $ff, $00, $01, $00, $c1, $00, $ff, $00, $3f, $c0, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $fc, $03, $fc, $03, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $81, $7e, $ff, $00, $3f, $00
	db $f0, $0f, $80, $7f, $00, $ff, $00, $ff, $00, $ff, $00, $f8, $00, $f8, $00, $f8
	db $07, $f8, $07, $f8, $00, $ff, $00, $ff, $70, $8f, $88, $77, $a4, $5b, $94, $6b
	db $64, $9b, $04, $fb, $08, $f7, $30, $cf, $c0, $3f, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $f0, $00, $f0, $00, $f0
	db $ff, $00, $fe, $01, $c0, $3f, $80, $7f, $80, $7f, $00, $f0, $00, $f0, $00, $f0
	db $0f, $f0, $01, $00, $c1, $00, $c1, $00, $7f, $80, $70, $80, $00, $f0, $00, $f0
	db $0f, $f0, $01, $80, $01, $80, $01, $80, $7f, $80, $70, $80, $00, $f0, $00, $f0
	db $0f, $f0, $09, $f0, $01, $f0, $01, $e0, $1f, $e0, $10, $e0, $80, $70, $c0, $30
	db $8f, $70, $01, $00, $01, $00, $01, $00, $ff, $00, $10, $00, $10, $00, $10, $00
	db $ff, $00, $ff, $00, $00, $ff, $00, $ff, $00, $ff, $00, $fc, $00, $fc, $00, $f8
	db $0f, $f0, $01, $00, $01, $00, $01, $00, $ff, $00, $f0, $00, $00, $f0, $00, $f0
	db $0f, $f0, $0f, $f0, $0f, $f0, $01, $fe, $01, $fe, $10, $00, $10, $00, $10

SECTION "analyzed_0ec000", ROMX[$4000], BANK[$3b]

Func_3b_4000:
	xor a
	ld [rVBK], a
	ld hl, $4034
	ld de, $9000
	ld bc, $0800
	call VramCopy16
	ld a, $01
	ld [rVBK], a
	ld hl, $4834
	ld de, $8780
	ld bc, $0c00
	call VramCopy16
	ret

Data_3b_4022:
	db $3e, $01, $ea, $4f, $ff, $21, $b4, $54, $11, $00, $80, $01, $80, $02, $cd, $94
	db $03, $c9

Data_3b_4034:
	INCBIN "raw_gfx/Data_3b_4034.2bpp", 0, 5120

Data_3b_5434:
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $fc, $ff, $ff, $fc
	db $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $fc, $ff, $ff, $fc, $fc, $ff
	db $ff, $fc, $ff, $fc, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $03, $03, $07, $07, $07, $07, $0f, $0f
	db $0f, $0f, $0f, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f
	db $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f
	db $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f
	db $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f
	db $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f
	db $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f
	db $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f, $0e, $0f
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $e0, $ff, $80, $ff
	db $03, $ff, $07, $fb, $0e, $f1, $0c, $f3, $0c, $f3, $0c, $f3, $0c, $f3, $0c, $f3
	db $0c, $f3, $0c, $f3, $0c, $f3, $06, $f9, $03, $fc, $01, $fe, $00, $ff, $00, $ff
	db $00, $ff, $05, $fa, $16, $e9, $1c, $e3, $34, $cb, $14, $eb, $40, $bf, $81, $7e
	db $40, $bf, $93, $6c, $24, $db, $00, $ff, $01, $fe, $00, $ff, $01, $fe, $00, $ff
	db $13, $ec, $24, $db, $00, $ff, $01, $fe, $00, $ff, $03, $fc, $14, $eb, $24, $db
	db $04, $fb, $1e, $e1, $00, $ff, $00, $ff, $30, $cf, $09, $f6, $06, $f9, $04, $fb
	db $00, $ff, $08, $f7, $0a, $f5, $0c, $f3, $18, $e7, $28, $d7, $09, $f6, $00, $ff
	db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $00, $ff, $00, $ff
	db $ff, $ff, $ff, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $80, $7f, $c0, $3f, $60, $9f
	db $30, $cf, $18, $e7, $4c, $b3, $4c, $b3, $4c, $b3, $8c, $73, $0c, $f3, $8c, $73
	db $0c, $f3, $8c, $73, $4c, $b3, $0c, $f3, $8c, $73, $0c, $f3, $8c, $73, $0c, $f3
	db $8c, $73, $4c, $b3, $0c, $f3, $8c, $73, $0c, $f3, $0c, $f3, $8c, $73, $4c, $b3
	db $4c, $b3, $4c, $b3, $0c, $f3, $0c, $f3, $cc, $33, $0c, $f3, $0c, $f3, $0c, $f3
	db $0c, $f3, $0c, $f3, $4c, $b3, $4c, $b3, $4c, $b3, $4c, $b3, $8c, $73, $0c, $f3
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $01, $01, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03
	db $03, $03, $02, $03, $03, $03, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $d0, $ff, $a0, $ff, $c1, $fe, $a2, $fd, $45, $fa, $83, $fc
	db $45, $fa, $8b, $f4, $07, $f8, $8b, $f4, $17, $e8, $0f, $70, $17, $28, $0f, $10
	db $07, $08, $07, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00
	db $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00
	db $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00
	db $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00
	db $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03, $00, $03

SECTION "analyzed_0f0000", ROMX[$4000], BANK[$3c]

Data_3c_4000:
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $01, $00, $20, $01
	db $1e, $01, $60, $10, $80, $00, $00, $00, $00, $00, $00, $00, $0d, $00, $02, $04
	db $18, $00, $20, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $04, $00, $04, $00, $05, $02, $fc, $02
	db $81, $00, $00, $00, $21, $00, $17, $00, $0c, $10, $60, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $48, $78, $44, $64, $7c, $7c, $78, $38, $3e, $00, $0f, $00
	db $07, $07, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $20, $00, $20, $00, $00, $10, $64, $00, $82, $00, $00, $02
	db $0d, $02, $bf, $03, $63, $83, $07, $07, $03, $07, $02, $07, $00, $07, $00, $0f
	db $0c, $0f, $0c, $0f, $0c, $0f, $04, $07, $04, $07, $04, $07, $0d, $06, $0f, $00
	db $1f, $00, $10, $00, $20, $00, $60, $00, $c0, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $03, $00, $03, $07, $04, $1c, $b9, $78
	db $ff, $e0, $78, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $01, $01, $03, $03, $07, $07, $0e, $0e, $1e, $1f, $3e, $3f, $3c, $3f, $78, $7f
	db $70, $7f, $62, $60, $02, $00, $41, $00, $21, $00, $10, $01, $06, $11, $ed, $12
	db $e7, $78, $e4, $fb, $c3, $fc, $9f, $ff, $06, $ff, $04, $ff, $19, $ff, $3f, $ff
	db $3e, $fc, $7d, $f3, $74, $ec, $ef, $d7, $d7, $a7, $c3, $23, $d7, $2e, $fe, $00
	db $c0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $03, $00, $0c, $03, $30, $0c, $41, $30, $c7, $c0, $1d, $01, $60, $00, $c0, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $07, $0f, $0f, $3f, $1e, $7f, $3c, $ff, $79, $fe, $62, $fc, $c6, $f9, $88, $f7
	db $00, $ff, $01, $7f, $03, $1f, $06, $0f, $16, $07, $12, $03, $20, $03, $04, $47
	db $59, $8f, $f1, $3f, $e0, $ff, $c0, $ff, $00, $ff, $40, $ff, $02, $ff, $84, $1f
	db $0e, $1f, $d0, $d3, $c1, $c7, $c1, $87, $83, $86, $03, $0c, $85, $08, $19, $00
	db $01, $00, $03, $00, $02, $02, $06, $02, $06, $06, $1e, $0c, $38, $18, $f0, $20
	db $c0, $c0, $03, $00, $1e, $01, $e1, $7f, $ff, $1f, $ff, $ff, $7f, $7f, $4f, $7f
	db $23, $3b, $31, $39, $10, $18, $08, $0c, $04, $04, $02, $02, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $c4, $fb, $90, $e3, $27, $c0, $9c, $00, $28, $10, $41, $30, $06, $e1, $09, $e7
	db $33, $cf, $27, $df, $0f, $ff, $1f, $ff, $3e, $ff, $79, $fe, $65, $f8, $c8, $f0
	db $81, $f0, $12, $e1, $0c, $e3, $30, $cf, $22, $df, $06, $ff, $0d, $ff, $3f, $ff
	db $78, $ff, $f8, $ff, $e1, $fe, $e3, $9c, $c4, $3b, $c0, $3f, $80, $7f, $3f, $ff
	db $ff, $ff, $fc, $0f, $00, $0f, $08, $07, $00, $1f, $3e, $1f, $9f, $7f, $ff, $3f
	db $87, $7f, $40, $ff, $e0, $ff, $dc, $ff, $ef, $ff, $f3, $ff, $f9, $ff, $f8, $ff
	db $fc, $ff, $be, $ff, $8f, $ff, $43, $7b, $23, $3b, $11, $19, $0c, $0c, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $1a, $e1, $44, $83, $10, $0f, $23, $1f, $8f, $7f, $3f, $ff, $7f, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $e7, $ff, $1f, $ff, $bf, $7f, $40, $ff, $8e, $71, $c8, $07
	db $18, $07, $a7, $1f, $cf, $3f, $9f, $7f, $3f, $ff, $ff, $ff, $ff, $ff, $80, $ff
	db $0f, $f0, $60, $80, $00, $00, $80, $00, $0c, $f0, $73, $8c, $0f, $f0, $80, $ff
	db $fc, $ff, $00, $ff, $00, $ff, $00, $ff, $07, $ff, $3f, $ff, $0f, $ff, $80, $ff
	db $c0, $ff, $30, $ff, $3c, $ff, $1f, $ff, $07, $ff, $83, $ff, $e1, $ff, $f0, $ff
	db $7c, $ff, $3e, $ff, $37, $cf, $3e, $c1, $9f, $e0, $9f, $e0, $5f, $60, $47, $70
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $fc, $00, $f0, $00, $c0, $00
	db $00, $00, $0f, $00, $7f, $00, $ff, $00, $fe, $00, $fc, $00, $f0, $00, $e1, $00
	db $c7, $00, $9f, $00, $7f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $00, $ff, $00, $ff, $00, $f8, $00, $80, $00, $00, $00, $00, $00, $00, $00
	db $7c, $00, $f0, $00, $c0, $00, $80, $00, $03, $00, $1f, $00, $ff, $00, $ff, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $fe, $00, $fc, $00, $f0, $00
	db $e0, $00, $c0, $00, $80, $00, $80, $00, $80, $00, $80, $00, $c0, $00, $f0, $00
	db $f8, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $c0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $1c, $00, $f8, $00, $f8, $00, $f8, $00, $f8, $00, $f0, $00
	db $f0, $00, $f0, $00, $f0, $00, $f8, $00, $f8, $00, $f8, $00, $f0, $00, $f0, $00
	db $e0, $00, $e0, $00, $c0, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $87, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $fe, $00, $fc, $00, $f8, $00, $f1, $00, $e0, $00, $c0, $00, $c0, $00, $80, $00
	db $80, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $04, $00, $05, $00, $07, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $00, $1f, $00, $3f, $00
	db $f0, $00, $c0, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $80, $00
	db $c4, $00, $c6, $00, $e7, $00, $f3, $00, $fb, $00, $fd, $00, $ff, $00, $ff, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $84, $00, $c4, $00, $e6, $00, $f3, $00, $ff, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $88

SECTION "analyzed_0f0802", ROMX[$4802], BANK[$3c]

Data_3c_4802:
	db $01, $00, $02, $41, $86, $61, $cf, $20, $31, $ce, $ff, $cc, $ff, $00, $ff, $00
	db $df, $3c, $e9, $1e, $ff, $00, $7f, $80, $bf, $c0, $6c, $73, $27, $38, $37, $38
	db $17, $18, $1b, $1c, $0d, $0e, $05, $06, $06, $07, $02, $03, $03, $03, $03, $03
	db $01, $01, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $08, $80, $18, $80, $38, $80, $18, $e0, $f0, $e8, $f0, $08, $f0, $08
	db $f0, $08, $e8, $18, $e8, $18, $d8, $38, $38, $f8, $60, $98, $f0, $0c, $f8, $04
	db $fe, $00, $fe, $00, $ff, $00, $ff, $00, $ff, $00, $7f, $80, $7f, $80, $bf, $c0
	db $bf, $c0, $df, $e0, $ff, $e0, $ef, $f0, $7f, $70, $77, $78, $3b, $3c, $39, $3e
	db $1c, $1f, $1e, $1f, $0e, $0f, $07, $07, $07, $07, $03, $03, $03, $03, $01, $01
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $00, $01, $02, $01, $02
	db $03, $00, $03, $04, $03, $04, $07, $00, $86, $08, $84, $08, $dc, $00, $fc, $00
	db $dc, $20, $dc, $22, $fe, $01, $ff, $00, $ff, $00, $d8, $20, $d8, $20, $dc, $20
	db $dc, $20, $4f, $b0, $0f, $f0, $07, $f8, $81, $fe, $80, $ff, $c4, $ff, $c3, $ff
	db $e1, $ff, $f0, $ff, $70, $7f, $70, $7f, $20, $3f, $20, $3f, $03, $1c, $07, $38
	db $0f, $30, $0f, $30, $1f, $20, $1f, $60, $3f, $40, $3f, $40, $3f, $c0, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $40, $00, $c0, $00, $c0, $80, $40, $80, $40, $80, $40
	db $c0, $00, $c0, $00, $c0, $20, $e0, $00, $00, $20, $40, $10, $10, $00, $10, $08
	db $18, $04, $1c, $22, $3f, $c0, $fc, $00, $f0, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $80, $00, $e0, $00, $fc, $00, $ff, $00, $1f, $e0, $03, $fc
	db $c0, $ff, $ff, $ff, $7f, $ff, $1f, $ff, $01, $ff, $00, $ff, $c0, $3f, $f0, $0f
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $1f, $bf, $7f, $00, $ff
	db $71, $8e, $bf, $7f, $ff, $ff, $ff, $ff, $03, $ff, $fc, $03, $7b, $fc, $fd, $fe
	db $f3, $fc, $06, $f9, $9e, $61, $f9, $07, $e3, $1f, $0e, $ff, $fc, $ff, $00, $00
	db $01, $00, $07, $00, $ff, $00, $1f, $00, $01, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $ff, $00, $ff, $00, $ff, $00
	db $3f, $c0, $00, $ff, $ff, $ff, $ff, $ff, $fe, $ff, $00, $ff, $00, $ff, $0f, $f0
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $f8, $fe, $fe, $ff, $0c, $ff
	db $e3, $1c, $3e, $c1, $cd, $f3, $bb, $c7, $76, $8f, $ec, $1f, $99, $7e, $00, $00
	db $01, $00, $03, $00, $07, $00, $0f, $00, $18, $00, $31, $00, $70, $00, $f0, $00
	db $f0, $00, $f0, $08, $f8, $07, $ff, $00, $ff, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $07, $00, $3f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $1e, $ff, $f9, $fe, $e3, $fc, $0f, $f0, $7f, $80, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $60, $80, $00, $00
	db $00, $00, $00, $00, $00, $00, $07, $00, $1f, $00, $3f, $00, $7f, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $7f, $80, $3f, $40, $3f, $40, $3f, $40
	db $3f, $40, $7f, $80, $ff, $00, $ff, $00, $ff, $00, $3f, $00, $1f, $00, $1f, $00
	db $3f, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $1f, $e0, $3f, $c0, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $02, $1d
	db $0a, $3d, $0b, $3c, $1a, $3d, $1a, $3d, $1a, $3d, $1a, $3d, $1b, $3c, $0a, $3d
	db $0a, $3d, $0b, $3c, $09, $1e, $0d, $1e, $04, $1f, $86, $8f, $cb, $c7, $05, $03
	db $03, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $f0, $ff
	db $00, $fe, $e0, $18, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $b3, $7c
	db $72, $fc, $e4, $f8, $c0, $f8, $90, $e0, $00, $e0, $02, $c2, $03, $83, $dc, $3c
	db $30, $fe, $c0, $ff, $9e, $e1, $38, $c0, $60, $80, $c0, $00, $80, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $07, $00, $07, $00, $03
	db $00, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $01, $02, $03, $0c, $3f, $c0, $fe, $01, $b7, $cf
	db $7f, $ff, $1f, $e0, $07, $78, $00, $1f, $00, $03, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $e0, $00, $fe, $00, $ff, $00, $3f, $c0, $f7, $f8
	db $ff, $ff, $ff, $00, $ff, $00, $3f, $c0, $02, $fc, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $ff, $00, $ff, $00, $bd, $7f
	db $cf, $f0, $fc, $03, $e0, $18, $00, $c0, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $c0, $00, $e0, $00, $e0, $00
	db $00, $c0

SECTION "analyzed_0f1000", ROMX[$5000], BANK[$3c]

Data_3c_5000:
	db $87, $ff, $79, $87, $4e, $81, $01, $02, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $01, $01, $03, $03, $07, $07, $07, $07, $0f, $0f
	db $07, $0f, $07, $0f, $07, $0f, $03, $1f, $03, $1f, $00, $1f, $00, $1f, $00, $0f
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $f8, $f8, $fc, $fc, $fe, $fe, $3e, $fe, $9f, $7f, $6f, $1f, $27, $1f, $33, $0f
	db $1b, $07, $1d, $03, $0d, $03, $04, $03, $02, $01, $02, $01, $02, $01, $01, $00
	db $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $1f, $1f, $7f, $7f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $fe, $ff, $78, $ff, $00, $fe
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $c0, $c0, $e0, $e0
	db $f0, $f0, $f0, $f0, $f8, $f9, $fc, $fc, $7e, $ff, $78, $ff, $33, $fc, $36, $f9
	db $04, $fb, $60, $9f, $4c, $b3, $3c, $43, $69, $1e, $1b, $bc, $1b, $3c, $3d, $3b
	db $3f, $3b, $3f, $3f, $3f, $3f, $2b, $77, $7f, $61, $7a, $7d, $3f, $3f, $0e, $0e
	db $00, $00, $01, $00, $01, $00, $04, $04, $04, $07, $00, $00, $00, $00, $00, $00
	db $00, $00, $83, $84, $c9, $ce, $f9, $fe, $f8, $ff, $fe, $ff, $fb, $ff, $fd, $ff
	db $f9, $ff, $f9, $ff, $f0, $f9, $c6, $f6, $0f, $ef, $07, $df, $00, $1e, $00, $3c
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $00, $71
	db $10, $0c, $08, $07, $0c, $f3, $08, $f7, $00, $ff, $80, $7f, $01, $fe, $01, $fe
	db $03, $fc, $03, $fd, $37, $c9, $f7, $19, $f7, $3b, $f7, $7b, $fb, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $fe, $ff, $fe, $ff, $fe, $ff, $ff, $3f, $3f
	db $07, $07, $60, $e0, $a0, $40, $80, $80, $40, $c0, $21, $3f, $00, $00, $00, $00
	db $00, $00, $00, $00, $c0, $00, $fc, $03, $f1, $0f, $07, $ff, $1f, $ff, $bf, $ff
	db $fe, $ff, $fa, $ff, $f2, $fe, $f2, $fe, $22, $72, $20, $20, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01, $01, $01, $03, $01, $83
	db $03, $c3, $03, $67, $03, $ff, $02, $ff, $4e, $b3, $9e, $67, $3e, $cf, $fe, $0f
	db $ff, $3f, $ff, $7f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $db, $e7, $e7, $0f, $af, $67, $df, $37, $ff, $07, $ff, $07, $f8, $f8
	db $80, $80, $00, $00, $00, $00, $80, $80, $80, $80, $00, $00, $01, $01, $03, $03
	db $03, $07, $03, $0f, $11, $3f, $21, $ff, $e1, $ef, $e0, $e7, $40, $e7, $10, $f3
	db $18, $f9, $9c, $fc, $0c, $7c, $06, $3e, $00, $1f, $00, $07, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ef, $ff, $df, $e7, $dd, $e3, $9e, $e1, $b6, $c9
	db $b7, $c8, $77, $88, $6f, $90, $43, $bc, $c3, $38, $81, $78, $81, $70, $01, $f0
	db $01, $e0, $81, $e0, $c0, $e0, $e0, $e0, $e0, $e0, $e0, $e0, $f0, $f0, $f0, $f0
	db $f0, $f0, $f0, $f0, $f0, $f0, $f8, $f8, $f8, $f8, $fc, $fc, $fc, $fc, $3e, $3e
	db $07, $07, $00, $00, $00, $00, $0f, $0f, $7f, $7f, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $7f, $ff, $3f, $ff
	db $1f, $ff, $0f, $ff, $01, $7f, $00, $3f, $00, $1f, $80, $8f, $c0, $c7, $20, $23
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $f0, $f0, $f0, $f8, $b8, $fc, $98, $fc, $c0, $bc, $e0, $9e, $e0, $9e, $10, $ee
	db $00, $ff, $80, $7f, $80, $7f, $c0, $3f, $c0, $3f, $e0, $1f, $e4, $1b, $e6, $19
	db $f3, $0c, $f3, $0c, $fb, $04, $fb, $04, $7f, $00, $7f, $00, $3f, $00, $3f, $00
	db $3f, $00, $1f, $00, $1f, $00, $0b, $04, $0b, $04, $03, $0c, $03, $0c, $04, $08
	db $04, $08, $88, $90, $10, $00, $20, $00, $80, $80, $e0, $e0, $f0, $f0, $f8, $f8
	db $fc, $fc, $fc, $fc, $fe, $fe, $fe, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $df, $ff, $1f, $ff, $10, $ff, $00, $ff, $01, $ff, $07, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $03
	db $00, $07, $00, $03, $00, $01, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $c0, $31, $c0
	db $3f, $c0, $7e, $80, $7e, $80, $3a, $c1, $18, $60, $0e, $31, $07, $18, $01, $06
	db $00, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $02, $01, $08, $00, $10, $00, $20, $01, $e0, $03, $c0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $c0, $00
	db $f8, $00, $1f, $00, $1f, $00, $1f, $60, $3f, $00, $00, $c0, $ff, $00, $ff, $00
	db $7f, $80, $1f, $e0, $00, $3f, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $01, $01, $00, $01, $8c, $05, $da, $cf, $30, $ff, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $10, $00, $10, $00, $00, $00, $00, $00, $00, $00, $07, $00
	db $7f, $00, $ff, $00, $ff, $00, $7f, $00, $7f, $00, $fc, $03, $f8, $06, $f0, $0c
	db $e0, $18, $00, $f0, $00, $c0, $00, $00, $00, $10, $00, $18, $00, $08, $00, $0c
	db $00, $06, $00, $03, $00, $81, $80, $41, $e0, $00, $f8, $00, $f8, $07, $fc, $03
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $c0, $00
	db $f8, $00, $ff, $00, $f4, $0b, $c0, $30, $80, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $80, $00, $c0, $00, $e0, $00, $70, $00, $38, $00, $dc
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $80

SECTION "analyzed_0f1800", ROMX[$5800], BANK[$3c]

Data_3c_5800:
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $03, $01, $07, $01, $08, $05, $18, $0d, $31, $1e, $35, $0e
	db $68, $1f, $7d, $17, $fb, $0f, $02, $fe, $06, $7c, $04, $1c, $0c, $0c, $0c, $0c
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $01, $00, $03, $00, $06, $01, $0e, $01, $0c, $03, $1c, $03
	db $10, $00, $1c, $20, $17, $2e, $18, $27, $06, $78, $19, $7e, $1f, $7c, $1f, $7c
	db $1b, $7d, $19, $7f, $44, $3b, $68, $10, $71, $06, $68, $07, $31, $0c, $34, $08
	db $3e, $01, $1c, $00, $1d, $00, $03, $00, $0a, $01, $01, $00, $00, $00, $01, $00
	db $01, $01, $01, $01, $01, $01, $03, $01, $83, $81, $40, $c1, $a0, $60, $c0, $40
	db $80, $80, $00, $00, $00, $00, $00, $00, $01, $00, $02, $01, $02, $01, $05, $03
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $06, $01, $18, $07
	db $60, $1f, $c1, $3f, $83, $7f, $03, $ff, $07, $ff, $0f, $ff, $0f, $ff, $18, $ff
	db $81, $7e, $45, $38, $6a, $31, $25, $73, $57, $60, $58, $e7, $97, $ef, $b7, $cf
	db $37, $cf, $2b, $d7, $1d, $e3, $5c, $03, $e2, $1d, $1d, $fe, $3e, $7f, $14, $0f
	db $04, $e3, $20, $1f, $e0, $1f, $10, $ef, $08, $f7, $00, $ff, $8c, $70, $03, $00
	db $40, $81, $b1, $c0, $a0, $c0, $40, $80, $00, $80, $00, $00, $00, $00, $00, $00
	db $27, $1f, $30, $0f, $70, $00, $80, $7f, $34, $df, $7f, $de, $bd, $73, $58, $e7
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $01, $00, $02, $01, $c5, $43, $7b, $e7, $c5, $3b, $00, $ff, $1d, $fe
	db $fc, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $ff
	db $03, $00, $fe, $00, $f7, $f8, $ee, $f1, $f8, $07, $07, $ff, $ff, $ff, $ff, $ff
	db $fe, $ff, $fe, $ff, $fd, $fe, $fb, $fc, $32, $fc, $06, $f8, $0e, $f0, $04, $f8
	db $05, $f8, $08, $f1, $11, $e2, $0b, $e4, $27, $d9, $cd, $31, $a0, $41, $80, $00
	db $c0, $80, $c0, $80, $00, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $00, $ff, $1e, $00, $1c, $ef, $ed, $f7, $7b, $ee, $db, $6c, $89, $f6
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $80, $40, $40, $c0, $c0, $c0, $c0, $c0, $c6, $c4, $ce, $dc, $5c, $b8, $7c, $c0
	db $f8, $60, $a8, $71, $51, $be, $33, $dc, $af, $d8, $af, $d8, $ae, $d8, $13, $ef
	db $15, $ee, $26, $0c, $e4, $0c, $34, $cc, $34, $cc, $66, $8e, $67, $8f, $63, $9f
	db $c6, $19, $88, $10, $88, $10, $20, $10, $50, $20, $50, $28, $28, $5c, $a4, $5c
	db $5a, $86, $82, $01, $80, $00, $00, $80, $80, $80, $80, $80, $80, $80, $00, $80
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01
	db $ff, $ff, $00, $ff, $17, $00, $00, $ff, $3b, $ff, $ff, $e4, $c4, $3b, $81, $fe
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $80, $00, $80, $00, $80, $00, $00, $00, $00, $00, $00, $00, $40, $80
	db $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $c0
	db $00, $e0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $03, $07, $78, $ff
	db $03, $fc, $3c, $c3, $02, $ff, $55, $ff, $d0, $bf, $84, $78, $27, $c0, $3c, $03
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $01, $00, $01, $00, $03, $00, $07, $00, $0e, $01
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $10, $00, $30, $08, $30, $0c, $64, $1c
	db $6c, $1c, $ec, $1c, $cc, $3c, $dc, $3c, $1c, $7c, $1e, $3e, $1f, $1f, $3f, $3f
	db $7f, $7f, $ff, $ff, $ff, $ff, $ff, $ff, $fe, $fe, $fc, $fc, $fc, $fc, $f8, $f8
	db $00, $00, $08, $08, $1c, $1c, $3e, $3e, $7f, $7f, $ff, $ff, $ff, $ff, $ff, $ff
	db $c0, $c0, $c0, $c0, $80, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $01, $01, $81, $01, $83, $63, $03, $f3, $73, $83
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $18, $18
	db $1f, $1f, $3f, $3f, $3f, $3f, $7f, $7f, $7f, $7f, $ff, $ff, $fb, $fc, $df, $e0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $01, $00, $06, $01, $18, $07, $30, $09, $20, $01, $00, $03, $00, $03
	db $00, $07, $00, $06, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $03, $03, $07, $07, $03, $03, $03, $03
	db $01, $01, $00, $00, $00, $00, $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f, $7f
	db $7f, $7f, $ff, $ff, $ff, $fe, $fb, $fc, $ff, $e0, $7f, $80, $ff, $00, $fe, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $70, $0f, $80, $7f, $00, $ff, $00, $ff, $01, $ff, $01, $ff, $21, $ff, $63, $ff
	db $f3, $ff, $77, $7f, $7f, $7f, $7f, $7f, $ff, $ff, $ff, $ff, $ff, $ff, $1f, $1f
	db $1f, $1f, $3f, $3f, $7f, $7f, $ff, $ff, $ff, $ff, $ff, $ff, $7f, $7f, $3f, $3f
	db $1f, $1f, $0f, $0f, $3f, $3f, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $fe, $ff, $fe, $ff, $fd, $fe, $fb, $fc, $f7, $f8, $ef, $f0
	db $ff, $c0, $7f, $80, $fe, $01, $fc, $03, $f0, $0f, $c0, $3e, $c0, $38, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $00, $ff, $00, $ff, $00, $fe, $00, $fe, $00, $fc, $00, $f8, $00, $f0, $00
	db $ff, $00, $ff, $00, $fe, $00, $fc, $00, $f8, $00, $f0, $00, $f0, $00, $e0, $00
	db $e0, $00, $c0, $00, $c0, $00, $c0, $00, $80, $00, $80, $00, $80, $00, $80, $00
	db $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $c0, $00, $c0, $00
	db $c0, $00, $e0, $00, $e0, $00, $f0, $00, $e0, $00, $c0, $00, $c0, $00, $80, $00
	db $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $00, $ff, $00, $fc, $00, $f8, $00, $f0, $00, $e0, $00, $c0, $00, $c0, $00
	db $80, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $fe, $00, $f8, $00, $e0, $00
	db $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $00, $fe, $00, $fc, $00, $38, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $3f, $00, $3e, $00, $38, $00, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $80

SECTION "analyzed_0f2000", ROMX[$6000], BANK[$3c]

Data_3c_6000:
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $01, $01, $00, $01, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $02, $01, $02, $01, $04, $03, $04, $03
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $03, $00
	db $0f, $00, $0f, $00, $1c, $03, $18, $07, $31, $0f, $23, $1f, $03, $7f, $07, $7f
	db $03, $7f, $03, $ff, $01, $ff, $81, $7f, $c1, $3f, $c0, $3f, $e0, $1f, $78, $07
	db $3c, $03, $3c, $03, $3c, $03, $38, $07, $18, $07, $28, $07, $31, $06, $76, $00
	db $71, $00, $21, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	db $01, $00, $01, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $1b, $60, $1f, $40, $3f, $80, $7f, $01, $fe, $02, $fc, $06, $f9, $18, $e7
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $86, $78, $8f, $7e
	db $9f, $7f, $3f, $ff, $3f, $ff, $1f, $ff, $cf, $ff, $f7, $ff, $f7, $ff, $ff, $ff
	db $f5, $fe, $f6, $f8, $ec, $f0, $d8, $e0, $f8, $c0, $b0, $c0, $e2, $80, $64, $80
	db $40, $84, $48, $84, $50, $8c, $c0, $0c, $88, $04, $04, $80, $30, $00, $e4, $18
	db $cf, $3c, $df, $3f, $8f, $7f, $83, $7f, $80, $7f, $c0, $3f, $c0, $3f, $c0, $3f
	db $e0, $1f, $f0, $0f, $f8, $07, $f8, $07, $f8, $07, $3c, $03, $1c, $03, $0e, $01
	db $07, $00, $84, $03, $83, $00, $60, $00, $60, $00, $e8, $00, $f8, $00, $d8, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $00
	db $c0, $01, $f8, $c7, $ff, $e0, $fb, $c7, $fc, $c3, $f3, $8c, $f0, $8f, $e1, $9f
	db $e1, $1f, $41, $3f, $61, $1f, $bd, $0f, $1e, $3f, $15, $0f, $49, $07, $43, $01
	db $67, $01, $78, $07, $60, $1f, $61, $1f, $2c, $10, $30, $0f, $00, $1f, $20, $1f
	db $00, $0f, $05, $83, $87, $c0, $e3, $f0, $70, $f8, $30, $f8, $18, $fc, $1d, $fc
	db $1f, $fc, $1f, $fc, $3b, $fc, $3e, $f9, $34, $f9, $14, $f9, $2c, $f9, $1c, $f9
	db $3c, $f9, $1d, $f8, $9d, $7c, $fc, $00, $0c, $00, $01, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $1e, $7f
	db $3e, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $fe, $ff, $f3, $fc, $82, $fd, $fa, $fd
	db $fc, $ff, $fe, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $dc, $e7, $b3, $cf, $93, $cf
	db $c0, $80, $a1, $c0, $e1, $fe, $ff, $fe, $7e, $3f, $0d, $c6, $ea, $f1, $ff, $fc
	db $f9, $fe, $f1, $fe, $f7, $08, $fd, $00, $e0, $03, $01, $00, $3e, $1f, $ef, $1f
	db $9f, $7f, $04, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff
	db $00, $ff, $00, $ff, $00, $ff, $c0, $3f, $60, $1f, $b8, $07, $5e, $01, $0d, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $00, $c0, $10, $e0, $98, $f0, $78, $b8, $bc, $78, $7c, $fc, $fe, $fc, $f8, $fe
	db $f9, $fe, $f9, $fe, $f0, $fe, $70, $fe, $72, $fc, $31, $fe, $00, $ff, $00, $ff
	db $88, $77, $88, $77, $89, $76, $09, $f6, $1e, $e0, $1d, $e0, $32, $c0, $27, $c0
	db $4f, $86, $97, $0f, $2f, $1f, $df, $3f, $1e, $ff, $00, $ff, $70, $8f, $fc, $f3
	db $fd, $fc, $fe, $fe, $3f, $ff, $3f, $ff, $2d, $fe, $07, $f8, $01, $fe, $00, $ff
	db $00, $ff, $00, $ff, $00, $fe, $05, $f8, $0c, $f3, $18, $ef, $70, $9f, $e9, $36
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $c0, $00, $30, $c0, $38, $c0, $1e, $e0, $b9, $46, $a0, $5f, $40, $3f, $00, $7f
	db $00, $7f, $00, $7f, $00, $ff, $01, $fe, $04, $fb, $80, $77, $a0, $4f, $f0, $0f
	db $19, $e6, $8f, $f0, $c3, $fc, $86, $f8, $06, $f8, $0f, $f0, $1b, $e0, $32, $c1
	db $f4, $03, $64, $03, $04, $03, $04, $83, $c4, $03, $c4, $03, $d6, $01, $e2, $01
	db $e1, $00, $e1, $00, $60, $00, $6c, $80, $67, $80, $63, $80, $c7, $00, $87, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $00, $ff, $00, $fe, $00, $fe, $00, $fe, $00, $fe, $00, $fe, $00, $fc, $00
	db $fc, $00, $fc, $00, $fc, $00, $fc, $00, $fc, $00, $fe, $00, $fe, $00, $fe, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $00, $ff, $00, $fe, $00, $fc, $00, $f8, $00, $f8, $00, $f0, $00, $f0, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $fe, $00, $fc, $00
	db $f0, $00, $f0, $00, $e0, $00, $e0, $00, $c0, $00, $c0, $00, $80, $00, $80, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $80, $00, $80, $00, $e0, $00, $f0, $00, $f8, $00
	db $fc, $00, $fc, $00, $fe, $00, $fc, $00, $fc, $00, $fc, $00, $f4, $00, $e0, $00
	db $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $01, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $7f, $00
	db $3e, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $ff, $00, $80, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $3f, $00, $0f, $00, $07, $00, $07, $00, $03, $00, $03, $00, $01, $00, $01, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $3f, $00, $0f, $00, $07, $00, $01

SECTION "analyzed_0f28a1", ROMX[$68a1], BANK[$3c]

; Analyzer mis-split: inside the Suezo ($3c:$6800) range of the monster-portrait
; tile bank (LoadMonsterPortrait). See docs/monster_detail_screen.md.
Data_3c_68a1:
	INCBIN "raw_gfx/Data_3c_68a1.2bpp", 0, 1296

Data_3c_6db1:
	db $70, $30, $40, $30, $40, $30, $40, $20, $c0, $00, $80

SECTION "analyzed_0f3000", ROMX[$7000], BANK[$3c]

Data_3c_7000:
	db $80, $80, $80, $80, $00, $80, $00, $80, $00, $80, $c0, $40, $c0, $40, $c0, $40
	db $c0, $40, $e0, $60, $e0, $60, $a0, $60, $a0, $60, $f0, $30, $d0, $30, $f8, $18
	db $f8, $18, $e8, $18, $e8, $18, $e8, $18, $e8, $18, $c8, $38, $84, $7c, $b4, $4c
	db $fa, $06, $fa, $06, $f2, $0e, $e7, $1b, $e7, $1b, $fe, $07, $f8, $0f, $f7, $08
	db $ff, $00, $fe, $01, $fd, $03, $fe, $07, $f3, $0d, $be, $41, $bd, $42, $ff, $00
	db $ff, $00, $f3, $0c, $ef, $18, $f7, $18, $af, $70, $6c, $f3, $e9, $f7, $c6, $f9
	db $8d, $f3, $9d, $e3, $bb, $c6, $39, $c6, $73, $8c, $73, $8c, $f8, $07, $f7, $0f
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $80, $80, $40, $c0, $40, $c0
	db $60, $e0, $d0, $f0, $c8, $f8, $86, $fe, $31, $cf, $f0, $0f, $f5, $0e, $e1, $1e
	db $e8, $1f, $d8, $3f, $b0, $7f, $b3, $7c, $4f, $f0, $bf, $c0, $7f, $80, $7f, $c0
	db $fc, $83, $e2, $1f, $fd, $3e, $bb, $7c, $76, $f9, $6c, $f7, $bb, $fc, $73, $bc
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $ff, $07, $07, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $18, $1f, $6f, $70, $83, $fc, $0c, $0f, $01, $01, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $60, $e0, $0c, $fc, $c1, $3f
	db $30, $cf, $0c, $f3, $3e, $e1, $3d, $c2, $79, $86, $fb, $04, $f7, $08, $7e, $81
	db $fe, $01, $e8, $17, $e3, $1f, $e7, $1f, $ec, $1f, $c8, $3f, $db, $3c, $b7, $78
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $e7, $f8, $f8, $ff, $1f, $1f, $07, $07, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01
	db $0f, $0f, $30, $3f, $07, $f8, $9f, $60, $de, $2f, $1b, $e7, $cf, $f0, $27, $38
	db $1b, $1c, $0c, $0f, $03, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, $03, $1a, $1f, $c1, $ff
	db $00, $ff, $04, $fb, $c6, $39, $c6, $39, $a7, $58, $c7, $38, $47, $b8, $47, $b8
	db $23, $fc, $79, $f6, $2d, $fa, $e4, $3b, $fb, $24, $bf, $64, $9f, $6c, $bd, $4e
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $ff, $00, $fe, $01, $3e, $c1, $df, $e0, $f0, $ff, $3f, $3f, $0f, $0f, $03, $03
	db $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $f0, $f0
	db $c6, $fe, $01, $ff, $f0, $0f, $fc, $03, $fc, $03, $7c, $83, $f9, $07, $fe, $01
	db $fe, $01, $7f, $80, $28, $d7, $80, $ff, $7f, $7f, $1e, $1f, $0f, $0f, $05, $07
	db $05, $07, $0e, $0f, $1c, $1f, $1e, $1f, $7e, $7f, $01, $ff, $00, $ff, $43, $fc
	db $93, $ec, $9e, $e1, $cf, $f0, $4f, $f0, $6f, $f0, $6f, $f0, $b7, $78, $b7, $78
	db $d7, $38, $ef, $10, $e7, $18, $73, $8c, $3b, $c4, $cf, $30, $ed, $12, $ef, $10
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $9f, $60, $3f, $c0, $3f, $c0, $3e, $c1, $3e, $c1, $7f, $80, $7e, $81, $3f, $c0
	db $8f, $f0, $cf, $f0, $67, $78, $37, $38, $16, $19, $0b, $0c, $0b, $0c, $05, $06
	db $00, $03, $02, $03, $80, $81, $60, $e1, $31, $f1, $89, $f9, $c5, $fd, $73, $ff
	db $68, $ef, $24, $e7, $12, $f3, $3f, $ff, $3b, $ff, $01, $ff, $b0, $cf, $3e, $c1
	db $9f, $e0, $8f, $f0, $47, $f8, $83, $7c, $cc, $33, $ef, $10, $4f, $b0, $ef, $10
	db $ff, $00, $17, $e8, $47, $b8, $e7, $18, $fb, $04, $fd, $02, $fe, $01, $ef, $10
	db $f3, $0c, $f8, $07, $fc, $03, $ee, $11, $ff, $00, $f7, $08, $f3, $0c, $f3, $0e
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $bf, $40, $3f, $c0, $79, $87, $67, $9e, $0f, $f0, $3f, $c0, $ff, $00, $f8, $07
	db $f3, $0f, $e7, $18, $8f, $70, $77, $f8, $0c, $f3, $df, $33, $e7, $1c, $df, $3c
	db $b7, $4c, $f9, $06, $ff, $00, $7c, $83, $7b, $84, $65, $9a, $7b, $84, $47, $bc
	db $fb, $84, $7f, $80, $3d, $c2, $1f, $e0, $9d, $e2, $cf, $f0, $ef, $f0, $14, $fb
	db $c8, $3f, $f2, $0f, $91, $6e, $83, $7e, $29, $d6, $3e, $c1, $ff, $00, $ff, $00
	db $ff, $00, $ff, $00, $fc, $03, $7c, $83, $7c, $83, $3e, $c1, $23, $dc, $9f, $e0
	db $5e, $e3, $6f, $f3, $35, $fb, $33, $cd, $3d, $c3, $1f, $e3, $5d, $a3, $ce, $71

SECTION "analyzed_0f4000", ROMX[$4000], BANK[$3d]

Func_3d_4000:
	ld a, $01
	ld [rVBK], a
	ld a, [wActiveFloor]
	dec a
	add a, a
	ld hl, $406f
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	or h
	jr z, Func_3d_401d
	ld de, $8000
	ld bc, $0800
	call VramCopy16
Func_3d_401d:
	ld a, [wActiveFloor]
	dec a
	add a, a
	ld hl, $4079
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	or h
	jr z, Func_3d_4035
	ld de, $8b80
	ld bc, $0400
	call VramCopy16
Func_3d_4035:
	xor a
	ld [rVBK], a
	ld a, [wActiveFloor]
	dec a
	add a, a
	ld hl, $4083
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	or h
	ret z
	ld de, $8d00
	ld bc, $0300
	call VramCopy16
	ret
Func_3d_4051:
	ld a, [wActiveFloor]
	dec a
	add a, a
	ld hl, $4065
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	ld a, $04
	ld b, $04
	call Func_00_0732
	ret

Data_3d_4065:
	db $8d, $4c, $ad, $5b, $cd, $67, $ed, $6f, $0d, $7f, $8d, $40, $ad, $4c, $cd, $5b
	db $ed, $67, $0d, $70, $8d, $48, $ad, $54, $cd, $63, $00, $00, $0d, $78, $00, $00
	db $ad, $58, $00, $00, $00, $00, $0d, $7c, $00, $00, $80, $00, $40, $80, $a0, $c0
	db $d0, $e0, $58, $e0, $2c, $f0, $37, $f8, $67, $f8, $d7, $b8, $97, $f8, $ae, $f1
	db $5e, $e9, $bd, $da, $7f, $b0, $fd, $02, $7f, $80, $37, $c8, $ef, $10, $a7, $40
	db $03, $00, $02, $01, $00, $03, $01, $03, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $40, $80, $a0, $c0, $d0, $e0
	db $58, $e0, $2c, $f0, $37, $f8, $67, $f8, $d7, $b8, $97, $f8, $ae, $f1, $5e, $e9
	db $bd, $da, $7f, $b0, $fd, $02, $7f, $80, $37, $c8, $e7, $10, $a3, $40, $03, $00
	db $03, $00, $02, $01, $00, $03, $01, $03, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $0e, $00, $3c, $02, $f8, $04, $e0, $18, $e0, $10, $c0, $20, $00, $c0, $00, $80
	db $cf, $00, $fe, $01, $ff, $10, $6f, $30, $ef, $30, $ff, $20, $ef, $10, $ff, $10
	db $d6, $39, $bf, $c8, $96, $e9, $c9, $f6, $06, $19, $00, $0f, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0e, $00
	db $3c, $02, $f8, $04, $e0, $18, $e0, $10, $c0, $20, $00, $c0, $00, $80, $cf, $00
	db $fe, $01, $ff, $10, $6f, $30, $6f, $30, $ff, $20, $ef, $10, $ff, $10, $d6, $39
	db $bf, $48, $d6, $a9, $89, $f6, $c6, $d9, $00, $0f, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $80, $00, $40, $80, $70, $c0, $fc, $40, $30, $c0, $78, $c0, $f8, $80
	db $bc, $40, $d0, $20, $a0, $40, $00, $c0, $00, $80, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $80, $00, $40, $80, $70, $c0, $fc, $40, $30, $c0, $78, $c0, $f8, $80, $bc, $40
	db $d0, $20, $a0, $40, $00, $c0, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $40, $80, $a0, $c0, $d0, $e0
	db $58, $e0, $2c, $f0, $37, $f8, $67, $f8, $d7, $b8, $97, $f8, $ae, $f1, $5e, $e9
	db $bd, $da, $7f, $b0, $fd, $02, $7f, $80, $37, $c8, $e7, $10, $a7, $40, $07, $00
	db $07, $00, $05, $03, $01, $07, $03, $07, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $40, $80, $a0, $c0, $d0, $e0
	db $58, $e0, $2c, $f0, $37, $f8, $67, $f8, $d7, $b8, $97, $f8, $ae, $f1, $5e, $e9
	db $bd, $da, $7f, $b0, $fc, $02, $7f, $80, $37, $c8, $ef, $10, $af, $40, $0f, $00
	db $0f, $00, $0d, $03, $09, $07, $0b, $07, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0e, $00
	db $3c, $02, $f8, $04, $e0, $18, $e0, $10, $c0, $20, $00, $c0, $0c, $82, $fe, $01
	db $df, $20, $bb, $4c, $77, $18, $77, $18, $bb, $5c, $bb, $4c, $9b, $6c, $8d, $36
	db $8d, $36, $8d, $16, $4e, $93, $c6, $8b, $07, $01, $03, $00, $01, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0e, $00
	db $3c, $02, $f8, $04, $e0, $18, $e0, $10, $c0, $20, $00, $c0, $0f, $80, $ff, $00
	db $f9, $0e, $ff, $1c, $3f, $08, $38, $0f, $3d, $06, $1e, $27, $0e, $33, $07, $19
	db $83, $0c, $83, $0c, $01, $86, $80, $87, $00, $03, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $80, $00, $80, $80, $40, $c0, $20, $e0, $30, $f0, $10, $f0, $10
	db $f0, $10, $e0, $30, $e0, $20, $e0, $00, $c0, $00, $80, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $40
	db $c0, $00, $c0, $20, $e0, $10, $f0, $08, $f8, $0c, $f8, $0c, $fc, $06, $3c, $c6
	db $be, $c2, $de, $62, $de, $22, $fe, $02, $7c, $84, $3c, $c0, $38, $00, $30, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $40, $80, $a0, $c0
	db $d0, $e0, $58, $e0, $2c, $f0, $37, $f8, $67, $f8, $d7, $b8, $97, $f8, $ae, $f1
	db $5e, $e9, $bd, $da, $7f, $b0, $fc, $02, $7f, $80, $37, $c8, $ef, $10, $af, $40
	db $0f, $00, $0d, $03, $09, $07, $0b, $07, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $40, $80, $a0, $c0, $d0, $e0
	db $58, $e0, $2c, $f0, $37, $f8, $67, $f8, $d7, $b8, $97, $f8, $ae, $f1, $5e, $e9
	db $bd, $da, $7f, $b0, $fd, $02, $7f, $80, $37, $c8, $e7, $10, $a5, $43, $01, $07
	db $03, $07, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $0e, $00, $3c, $02, $f8, $04, $e0, $18, $e0, $10, $c0, $20, $00, $c0, $0f, $80
	db $ff, $00, $f9, $0e, $ff, $1c, $3f, $08, $38, $0f, $3d, $06, $1e, $27, $0e, $33
	db $87, $19, $83, $0c, $03, $8c, $81, $86, $00, $07, $00, $03, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0e, $00
	db $3c, $02, $f8, $04, $e0, $18, $e0, $10, $c0, $00, $00, $c0, $0c, $82, $fe, $01
	db $df, $20, $bb, $4c, $f7, $18, $f7, $18, $bb, $5c, $bb, $4c, $9b, $6c, $4d, $b6
	db $8d, $f6, $0d, $16, $0e, $13, $06, $0b, $07, $01, $03, $00, $01, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80
	db $80, $40, $c0, $00, $c0, $20, $e0, $10, $f0, $08, $f8, $0c, $f8, $0c, $fc, $06
	db $3c, $c6, $be, $c2, $de, $62, $de, $22, $fe, $02, $7c, $84, $3c, $c0, $38, $00
	db $30, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $80, $00, $80, $80, $40, $c0, $20, $e0, $30, $f0, $10, $f0, $10
	db $f0, $10, $e0, $30, $e0, $20, $e0, $00, $c0, $00, $80, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $40, $80, $a0, $c0, $d0, $e0
	db $58, $e0, $2c, $f0, $37, $f8, $67, $f8, $d7, $b8, $97, $f8, $ae, $f1, $5e, $e9
	db $bd, $da, $7f, $b0, $fd, $02, $7f, $80, $37, $c8, $e7, $10, $a2, $41, $01, $02
	db $03, $04, $07, $09, $06, $0b, $0e, $13, $0d, $16, $1f, $00, $3f, $00, $0e, $01
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $40, $80, $a0, $c0, $d0, $e0
	db $58, $e0, $2c, $f0, $37, $f8, $67, $f8, $d7, $b8, $97, $f8, $ae, $f1, $5e, $e9
	db $bd, $da, $7f, $b0, $fd, $02, $7f, $80, $37, $c8, $e7, $10, $a3, $40, $03, $00
	db $03, $00, $02, $01, $00, $03, $01, $03, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0e, $00
	db $3c, $02, $f8, $04, $e0, $18, $e0, $10, $c0, $20, $00, $c0, $00, $80, $c0, $00
	db $80, $60, $c8, $30, $ee, $17, $4d, $36, $9f, $60, $7f, $b0, $fc, $7b, $ce, $f1
	db $be, $c1, $7d, $83, $ff, $03, $fa, $06, $fa, $06, $e4, $1c, $98, $78, $60, $e0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0e, $00
	db $3c, $02, $f8, $04, $e0, $18, $e0, $10, $c0, $3c, $3c, $c2, $6c, $b3, $e7, $78
	db $fb, $3c, $7b, $1c, $3b, $4c, $19, $2e, $de, $27, $cf, $13, $c7, $08, $c0, $07
	db $e0, $00, $a0, $c0, $c0, $e0, $c0, $e0, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $80, $00, $c0, $00, $40, $c0, $c0, $c0, $40, $80
	db $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80
	db $80, $40, $c0, $40, $e0, $20, $e0, $00, $e0, $00, $e0, $00, $e0, $00, $e0, $00
	db $40, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $40, $80, $a0, $c0, $d0, $e0
	db $58, $e0, $2c, $f0, $37, $f8, $67, $f8, $d7, $b8, $97, $f8, $ae, $f1, $5e, $e9
	db $bd, $da, $7f, $b0, $fd, $02, $7f, $80, $37, $c8, $e7, $10, $a3, $40, $03, $00
	db $03, $00, $02, $01, $00, $03, $01, $03, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0e, $00
	db $3c, $02, $f8, $04, $e0, $18, $e0, $10, $c0, $20, $00, $c0, $00, $80, $80, $00
	db $80, $40, $90, $60, $de, $20, $77, $18, $ef, $31, $ef, $31, $f7, $18, $fb, $1c
	db $bd, $4e, $8f, $f2, $b7, $f8, $9b, $fc, $1f, $3f, $0f, $3f, $07, $1f, $00, $0f
	db $00, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $e0, $00, $f0, $80, $f0, $80, $fc, $00
	db $f8, $40, $70, $80, $c0, $60, $c0, $e0, $c0, $e0, $80, $c0, $80, $c0, $00, $80
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $f9, $07, $f9, $07
	db $72, $0e, $72, $0e, $72, $0e, $72, $0e, $34, $0c, $34, $0c, $34, $0c, $34, $0c
	db $10, $08, $10, $08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $80, $00, $40, $80, $a0, $c0, $d0, $e0, $58, $e0, $2c, $f0, $37, $f8
	db $67, $f8, $d7, $b8, $97, $f8, $ae, $f1, $5e, $f9, $bd, $fa, $7e, $b9, $fe, $39
	db $7f, $80, $30, $cc, $ee, $10, $be, $41, $0f, $00, $07, $00, $03, $00, $01, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $80, $00, $40, $80, $a0, $c0, $d0, $e0, $58, $e0
	db $2c, $f0, $37, $f8, $67, $f8, $d7, $b8, $97, $f8, $ae, $f1, $5e, $e1, $bd, $ea
	db $7f, $90, $fd, $2a, $7f, $80, $33, $c0, $e0, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $07, $00
	db $0f, $03, $1f, $07, $3e, $0f, $3c, $1b, $78, $37, $79, $07, $f9, $07, $e9, $17
	db $e1, $1f, $f3, $0f, $42, $bf, $44, $bf, $42, $3c, $44, $b8, $60, $80, $c0, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $c0, $e1, $07, $f7, $3f, $4f, $ff
	db $9e, $7e, $58, $3c, $00, $38, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0e, $00, $3c, $02
	db $f8, $04, $e0, $18, $e0, $10, $ce, $30, $3e, $c1, $6f, $90, $df, $60, $df, $60
	db $ef, $70, $e7, $38, $73, $9c, $bb, $4c, $1d, $26, $0f, $10, $07, $08, $03, $04
	db $01, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $c0, $80
	db $c0, $80, $c0, $c0, $60, $c0, $20, $c0, $20, $c0, $70, $80, $78, $80, $3c, $c0
	db $70, $80, $30, $c0, $60, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $80, $40, $80, $40
	db $e0, $20, $e0, $20, $e0, $20, $e0, $00, $e0, $00, $e0, $00, $e0, $00, $c0, $00
	db $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, $00, $03, $04
	db $0e, $03, $13, $1f, $11, $0e, $08, $07, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $02, $0c, $29, $36, $2f, $70, $47, $78
	db $87, $78, $99, $6e, $f8, $2f, $7f, $04, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $00, $02, $28, $20, $00, $00
	db $05, $10, $00, $00, $a8, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $60, $00, $70, $80
	db $18, $e0, $3c, $c0, $f8, $00, $ec, $10, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $70, $08, $b8, $44, $8e, $70, $1e, $e0
	db $b8, $44, $f2, $0c, $cf, $30, $fe, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $20, $00, $00, $00, $84, $20, $00, $20
	db $08, $00, $42, $00, $01, $00, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $2c, $66, $59, $5b, $5b
	db $00, $00, $8c, $31, $94, $52, $bd, $77, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $01, $00, $03, $01, $02, $01, $06, $02, $0c, $02, $0c
	db $02, $0c, $02, $04, $00, $06, $00, $02, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $03, $01, $06, $f5, $0a, $2b, $14, $1d, $20, $19, $40
	db $32, $80, $60, $00, $00, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $1e, $00, $21, $de, $40, $bf, $c0, $3f, $00, $7f, $41, $3e, $43, $3c, $47, $38
	db $6e, $10, $1c, $20, $18, $20, $00, $30, $00, $30, $10, $60, $10, $60, $00, $30
	db $00, $30, $00, $38, $0c, $1c, $1e, $1e, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $2f, $40, $f0, $0f, $e0, $1f, $00, $3f, $20, $1f, $21, $1e, $23, $1c
	db $2f, $10, $17, $08, $16, $08, $10, $0e, $18, $07, $1c, $03, $0c, $00, $0e, $00
	db $07, $00, $03, $00, $01, $00, $00, $00, $00, $00, $00, $00, $01, $01, $00, $03
	db $02, $05, $05, $0a, $05, $0a, $0a, $15, $0a, $15, $0a, $15, $0a, $15, $09, $14
	db $08, $10, $08, $00, $c3, $00, $3f, $c0, $06, $f9, $82, $7d, $83, $7c, $87, $78
	db $4f, $30, $0f, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $01, $00, $03, $01, $06, $02, $05, $02, $05, $02, $04
	db $00, $04, $80, $00, $20, $c0, $0f, $f0, $01, $fe, $81, $7e, $87, $78, $87, $78
	db $ce, $31, $0c, $03, $02, $01, $01, $00, $00, $00, $00, $c0, $00, $e0, $00, $30
	db $04, $1c, $8e, $0e, $c0, $00, $e0, $00, $00, $00, $00, $00, $00, $0f, $00, $1f
	db $01, $1f, $07, $9f, $87, $4f, $cc, $2c, $7c, $9c, $be, $5e, $9e, $7e, $18, $9f
	db $3c, $1a, $7c, $18, $e0, $1c, $b0, $4e, $18, $e7, $0c, $f1, $0c, $f0, $08, $f0
	db $98, $60, $90, $60, $30, $40, $00, $60, $00, $60, $20, $c0, $20, $c0, $00, $60
	db $00, $60, $00, $70, $18, $38, $3c, $3c, $00, $00, $00, $00, $00, $00, $10, $13
	db $00, $27, $00, $e7, $61, $97, $a1, $53, $53, $ab, $af, $57, $af, $5f, $1e, $1d
	db $0c, $3b, $0c, $73, $9e, $60, $9a, $64, $b2, $4c, $26, $d8, $34, $c8, $3c, $c0
	db $fe, $00, $3f, $c0, $03, $fc, $f1, $0e, $08, $06, $10, $0c, $20, $38, $30, $30
	db $20, $20, $00, $00, $00, $00, $00, $00, $20, $20, $40, $40, $80, $80, $00, $80
	db $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $80, $00, $80, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $08, $08, $10, $10, $20, $e0
	db $00, $e0, $40, $e0, $c0, $c0, $c0, $c0, $00, $00, $00, $00, $00, $80, $00, $80
	db $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $80, $00, $e0, $00, $f0, $00, $38, $00, $1c, $00, $0e, $00, $06, $00
	db $03, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $00
	db $41, $00, $3c, $83, $10, $8f, $03, $7c, $02, $20, $04, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $02, $01, $04, $02
	db $18, $14, $18, $18, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $20, $00, $10, $01, $08, $33, $01, $7e, $3b, $c4, $1e, $80, $18, $80, $08, $00
	db $00, $00, $00, $02, $00, $07, $00, $07, $02, $04, $46, $48, $cc, $f0, $d8, $e0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $2f, $c0, $70, $8f, $e0, $1f, $00, $3f, $40, $3f, $41, $3e, $61, $1e, $63, $1c
	db $36, $08, $6c, $10, $48, $30, $98, $60, $30, $c0, $30, $80, $60, $00, $60, $00
	db $c0, $00, $c0, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $4f, $00, $30, $cf, $e0, $1f, $00, $3f, $08, $37, $51, $2e, $53, $2c, $7f, $00
	db $3e, $00, $4c, $30, $08, $f0, $b8, $40, $18, $00, $1c, $00, $0e, $00, $06, $00
	db $06, $00, $0e, $00, $0c, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $01, $01, $02, $03, $04, $06, $09, $05, $0a, $04, $08, $00, $00, $00, $00
	db $00, $00, $f0, $00, $07, $f8, $00, $ff, $80, $7f, $80, $7f, $c0, $3f, $fc, $03
	db $0f, $00, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $01, $01, $02, $01, $02, $02, $05, $02, $05, $02, $04, $00, $04
	db $80, $00, $20, $c0, $1f, $e0, $03, $fc, $83, $7c, $81, $7e, $c0, $3f, $61, $1e
	db $1f, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00
	db $03, $02, $03, $03, $00, $00, $00, $00, $00, $00, $00, $00, $02, $02, $00, $7c
	db $78, $84, $a8, $54, $58, $a4, $ab, $57, $5f, $af, $3f, $3e, $1b, $78, $04, $73
	db $0e, $71, $c6, $38, $f0, $0c, $f0, $0c, $30, $cc, $74, $88, $fa, $04, $c0, $3e
	db $e0, $1f, $f8, $07, $39, $00, $30, $00, $30, $00, $60, $00, $60, $00, $60, $00
	db $60, $00, $60, $00, $60, $00, $30, $00, $00, $00, $04, $04, $00, $08, $00, $39
	db $30, $c9, $f0, $09, $58, $a4, $58, $a4, $af, $53, $af, $57, $0f, $0e, $0f, $1c
	db $02, $1d, $e1, $1e, $f8, $07, $8e, $71, $06, $f8, $02, $fc, $82, $7c, $e4, $18
	db $cc, $30, $c8, $30, $e0, $18, $30, $08, $10, $0c, $10, $0c, $20, $18, $c8, $30
	db $18, $e0, $18, $00, $1c, $00, $0e, $00, $00, $00, $01, $01, $02, $02, $04, $7c
	db $00, $fc, $08, $fc, $38, $f8, $78, $f8, $c0, $c0, $c0, $c0, $80, $c0, $00, $c0
	db $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $80, $00, $c0, $00, $e0, $50, $20, $20, $10, $00, $18, $00, $0c
	db $07, $01, $03, $03, $00, $00, $00, $00, $02, $02, $04, $04, $08, $f8, $00, $f8
	db $10, $f8, $70, $f0, $70, $f0, $c0, $c0, $c0, $c0, $c0, $c0, $80, $c0, $00, $c0
	db $00, $80, $00, $00, $00, $00, $00, $c0, $00, $e0, $00, $60, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $40, $00, $24, $83, $31, $8e, $13, $cc, $02, $fc, $4c, $30, $38, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $18, $06, $20, $1f, $4e, $31, $4c, $30, $9c, $60, $1c, $60
	db $34, $40, $22, $40, $20, $40, $10, $20, $00, $02, $00, $07, $01, $06, $02, $0c
	db $02, $0c, $02, $0c, $03, $07, $07, $07, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $2f, $c0, $78, $87, $b0, $0f, $20, $1f, $60, $1f, $61, $1e, $71, $0e, $3b, $04
	db $3f, $00, $67, $18, $c7, $30, $8e, $60, $4e, $30, $06, $30, $03, $18, $13, $0c
	db $04, $0c, $0e, $0e, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $80, $00, $7e, $80, $c1, $3e, $00, $7f, $10, $6f
	db $a2, $5d, $a7, $58, $ff, $00, $7c, $00, $98, $60, $10, $e0, $70, $80, $60, $00
	db $70, $00, $38, $00, $1c, $00, $9e, $80, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $01, $01, $02, $01, $02, $01, $02, $01, $02, $00, $02, $00, $00
	db $00, $00, $80, $00, $3f, $c0, $00, $ff, $80, $7f, $81, $7e, $c3, $3c, $e2, $1d
	db $9e, $01, $03, $00, $00, $00, $00, $00, $00, $00, $1c, $1b, $3f, $30, $80, $00
	db $e0, $00, $70, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $01, $00, $03, $03, $04, $05, $0a, $06, $09, $0a, $15
	db $0b, $14, $0b, $14, $0d, $12, $00, $09, $00, $00, $01, $00, $fe, $01, $3c, $c3
	db $18, $e7, $18, $e7, $38, $c7, $fc, $03, $1f, $00, $00, $00, $00, $00, $01, $00
	db $02, $01, $02, $01, $02, $01, $03, $03, $00, $00, $10, $10, $00, $21, $00, $73
	db $60, $93, $f0, $0b, $50, $a9, $5b, $a7, $57, $af, $5f, $af, $1e, $1d, $3c, $3b
	db $0d, $72, $4a, $34, $ca, $34, $e6, $18, $e6, $18, $b2, $4c, $12, $ec, $34, $c8
	db $1c, $e0, $1e, $e0, $1e, $e0, $07, $60, $03, $60, $21, $c0, $c3, $00, $1f, $00
	db $3c, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $80, $80, $00, $0f, $00, $1f, $01, $9f, $87, $5f, $87, $4f, $dc, $3c
	db $7c, $bc, $78, $ec, $f0, $cc, $30, $c8, $18, $e0, $80, $78, $e0, $1c, $70, $8c
	db $70, $88, $f0, $00, $38, $c0, $1e, $e0, $8f, $70, $47, $38, $8e, $70, $0c, $c0
	db $18, $80, $38, $80, $b8, $80, $dc, $c0, $04, $04, $08, $08, $10, $f0, $00, $f0
	db $20, $f0, $e0, $e0, $e0, $e0, $80, $80, $80, $80, $00, $80, $00, $80, $00, $80
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $80, $00, $80, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $20, $20, $40, $40, $80, $80, $00, $80, $00, $80, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $80, $ff, $bc, $ff, $a4, $fb
	db $a4, $fb, $bc, $e3, $80, $ff, $ff, $80, $4e, $70, $4e, $70, $2c, $30, $2c, $30
	db $2c, $30, $2c, $30, $08, $10, $08, $10, $ff, $ff, $00, $ff, $3c, $ff, $24, $fb
	db $24, $fb, $3c, $e3, $00, $ff, $ff, $00, $4e, $70, $4e, $70, $2c, $30, $2c, $30
	db $2c, $30, $2c, $30, $08, $10, $08, $10, $ff, $ff, $01, $fe, $3d, $fe, $25, $fa
	db $25, $fa, $3d, $e2, $01, $fe, $ff, $00, $4e, $70, $4e, $70, $2c, $30, $2c, $30
	db $2c, $30, $2c, $30, $08, $10, $08, $10, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $06, $01, $18, $07
	db $32, $0d, $47, $18, $09, $30, $12, $20, $24, $40, $00, $40, $00, $01, $00, $01
	db $00, $01, $11, $12, $33, $3c, $36, $38, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $40, $00, $24, $83, $31, $8e, $13, $cc, $02, $fc, $4c, $30, $38, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $13, $00, $0d, $72, $38, $c7, $40, $8f
	db $c0, $0f, $90, $0f, $10, $0f, $13, $0c, $0b, $04, $17, $88, $07, $f8, $2c, $d0
	db $9c, $00, $b8, $00, $70, $00, $60, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $2f, $c0, $78, $87, $b0, $0f, $20, $1f, $60, $1f, $61, $1e, $71, $0e, $3b, $04
	db $3f, $00, $67, $18, $c7, $30, $8e, $60, $4e, $30, $06, $30, $03, $18, $17, $0c
	db $0e, $0e, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $01, $01, $02, $03, $04, $02, $0d, $0f, $10, $16, $29, $10, $2f, $39, $46
	db $26, $40, $00, $00, $07, $00, $39, $06, $c0, $3f, $80, $7f, $01, $fe, $03, $fc
	db $47, $b8, $f0, $00, $c0, $00, $80, $00, $87, $06, $0f, $0c, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $01, $00, $03, $01, $06, $02, $05, $02, $05, $02, $04
	db $00, $04, $80, $00, $20, $c0, $0f, $f0, $81, $7e, $81, $7e, $c3, $3c, $c7, $38
	db $be, $01, $0f, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $00
	db $e0, $00, $70, $00, $00, $00, $00, $00, $08, $18, $00, $38, $10, $68, $78, $84
	db $fc, $02, $b4, $4a, $56, $a9, $5f, $af, $bf, $7f, $1f, $f1, $3f, $c3, $c4, $03
	db $0c, $03, $f9, $06, $fb, $04, $9f, $60, $8f, $70, $07, $f8, $0f, $f0, $07, $f8
	db $c7, $38, $07, $38, $01, $18, $00, $18, $08, $f0, $f0, $00, $07, $00, $0f, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $10, $13
	db $00, $27, $00, $e7, $61, $97, $a1, $53, $53, $ab, $af, $57, $af, $5f, $1e, $1d
	db $0c, $3b, $0c, $73, $9e, $60, $9a, $64, $b2, $4c, $26, $d8, $34, $c8, $3c, $c0
	db $7e, $80, $9f, $60, $03, $fc, $f1, $0e, $08, $06, $04, $03, $02, $01, $01, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $02, $02, $04, $7c, $00, $fc
	db $08, $fc, $38, $f8, $38, $78, $e0, $e0, $e0, $e0, $c0, $e0, $00, $e0, $00, $c0
	db $80, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $80, $00, $80, $00, $c0, $00, $e0, $00, $60, $00, $e0, $00, $c0, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $08, $08, $10, $10, $20, $e0
	db $00, $e0, $40, $e0, $c0, $c0, $c0, $c0, $00, $00, $00, $00, $00, $80, $00, $80
	db $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $80, $00, $e0, $00, $f0, $00, $38, $00, $1c, $00, $0e, $80, $46, $c0
	db $e3, $e0, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $1f, $00, $36, $09, $48, $33, $90, $63
	db $95, $62, $b5, $42, $b7, $40, $a3, $40, $c4, $13, $40, $3f, $0b, $34, $13, $60
	db $13, $60, $11, $60, $18, $38, $3c, $3c, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $f0, $00, $08, $f0, $04, $f8, $87, $78
	db $13, $ec, $38, $c7, $f8, $07, $f8, $07, $cc, $03, $87, $00, $80, $00, $00, $00
	db $80, $00, $c0, $00, $e1, $01, $f7, $03, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01
	db $01, $02, $01, $02, $01, $02, $00, $00, $00, $00, $00, $00, $0f, $00, $3f, $00
	db $ff, $00, $63, $9c, $01, $fe, $41, $be, $c1, $3e, $c3, $3c, $31, $0e, $00, $0f
	db $00, $07, $00, $07, $c1, $be, $ff, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $04, $3c, $30, $48, $50, $a9, $b0, $49
	db $50, $a9, $b7, $4f, $0f, $0f, $1e, $0f, $6c, $1f, $8c, $7f, $8c, $7c, $d8, $2c
	db $e0, $0e, $c0, $06, $c0, $03, $c0, $01, $c0, $01, $c0, $00, $e0, $01, $e0, $00
	db $f0, $00, $70, $00, $f0, $00, $e0, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $f0, $00, $f8, $40, $f8
	db $f7, $ff, $e0, $e0, $40, $40, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $80, $00, $c0, $00, $c0, $00, $80, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $91, $1c, $5f, $20, $1e, $47
	db $00, $00, $8c, $31, $94, $52, $bd, $77, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00

Data_3d_5bcd:
	INCBIN "raw_gfx/Data_3d_5bcd.2bpp", 0, 2288

Data_3d_64bd:
	db $02, $08, $00, $00, $04, $00, $00, $00, $02, $00, $00, $00, $10, $00, $20

SECTION "analyzed_0f67cf", ROMX[$67cf], BANK[$3d]

Data_3d_67cf:
	db $0c, $09, $58, $2e, $5f, $20, $00, $00, $11, $28, $16, $39, $fa, $41, $00, $00
	db $5d, $0d, $94, $52, $bd, $77, $00, $00, $00, $00, $00, $00, $00, $00

Data_3d_67ed:
	INCBIN "raw_gfx/Data_3d_67ed.2bpp", 0, 2048

Data_3d_6fed:
	db $00, $00, $49, $00, $71, $00, $b6, $1d, $00, $00, $72, $00, $df, $0c, $5f, $2e
	db $00, $00, $2d, $15, $57, $22, $19, $3b, $00, $00, $f2, $00, $9a, $01, $df, $42
	db $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $01, $00, $00, $01, $01, $01, $00, $03, $01, $02, $0d
	db $0b, $04, $06, $08, $06, $18, $04, $18, $0c, $30, $2c, $30, $4c, $70, $4c, $70
	db $44, $78, $4c, $30, $7c, $00, $3a, $00, $28, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $80, $00, $40, $80, $08, $c8, $84, $6c, $52, $2e, $6b, $15, $9f, $63
	db $eb, $15, $17, $ea, $c6, $39, $a9, $d6, $3f, $ce, $e1, $1f, $71, $8e, $9f, $00
	db $0f, $00, $0b, $05, $07, $01, $15, $12, $2e, $31, $26, $39, $27, $38, $26, $38
	db $22, $3c, $23, $3c, $23, $1c, $03, $1c, $13, $0c, $17, $08, $0f, $00, $0f, $00
	db $0f, $00, $07, $00, $03, $04, $01, $06, $01, $06, $05, $02, $05, $02, $05, $02
	db $01, $06, $0b, $04, $0f, $00, $0f, $00, $15, $0a, $0d, $12, $1d, $22, $37, $00
	db $00, $00, $00, $00, $00, $02, $02, $04, $0a, $0c, $36, $38, $6e, $70, $5b, $64
	db $72, $5d, $77, $08, $0f, $00, $06, $01, $09, $0e, $10, $1f, $11, $1e, $17, $08
	db $00, $00, $01, $00, $02, $01, $10, $13, $21, $36, $4a, $74, $d6, $a8, $f9, $c6
	db $d7, $a8, $e8, $57, $63, $9c, $95, $6b, $fc, $73, $87, $f8, $8e, $71, $f9, $00
	db $f0, $00, $d0, $a0, $e0, $80, $e0, $20, $90, $70, $c8, $78, $28, $f8, $8c, $78
	db $b4, $58, $cc, $38, $cc, $30, $fc, $00, $f8, $00, $b0, $48, $c8, $30, $48, $30
	db $68, $10, $e8, $10, $f8, $00, $d0, $28, $90, $6c, $a8, $46, $e2, $00, $80, $00
	db $80, $00, $80, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $01, $02, $07, $04, $07, $04, $0a, $0c, $17, $1b, $2c, $34, $59, $69
	db $9a, $63, $d1, $0e, $2e, $c0, $c0, $70, $c0, $78, $e0, $38, $f8, $04, $f8, $0e
	db $00, $00, $00, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $80, $00, $00, $80, $80, $80, $00, $c0, $80, $40, $b0
	db $d0, $20, $60, $10, $60, $18, $20, $18, $30, $0c, $34, $0c, $32, $0e, $32, $0e
	db $22, $1e, $32, $0c, $3e, $00, $5c, $00, $14, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $c0, $c0, $80, $c0, $d0, $20, $80, $e0, $50, $60, $a0, $c0, $40, $80
	db $80, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $01, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $01, $00, $03, $01, $06, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $03, $00, $06, $03, $06, $03
	db $03, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $1e
	db $1f, $00, $0e, $09, $07, $05, $03, $02, $07, $01, $1e, $07, $78, $3f, $c3, $7c
	db $5f, $a0, $bb, $c4, $c7, $38, $7f, $00, $01, $06, $01, $06, $03, $0c, $06, $18
	db $1e, $60, $0c, $70, $78, $80, $f0, $00, $d0, $20, $20, $40, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $02, $02, $04, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $0e, $0f, $18, $1f, $1f, $10, $1c, $07
	db $08, $07, $05, $02, $03, $00, $01, $00, $02, $03, $04, $07, $04, $07, $05, $02
	db $07, $00, $03, $02, $03, $02, $3f, $01, $ff, $3e, $80, $ff, $01, $fe, $7f, $80
	db $87, $78, $7f, $00, $1f, $00, $0f, $08, $13, $1c, $26, $38, $cc, $f0, $38, $c0
	db $da, $0c, $8e, $05, $06, $83, $c6, $03, $e5, $02, $67, $84, $e5, $06, $c9, $0e
	db $f9, $0e, $f2, $1c, $e2, $3c, $e6, $38, $fc, $10, $fc, $00, $7e, $00, $1e, $20
	db $06, $08, $06, $08, $06, $18, $0e, $10, $0e, $10, $0e, $10, $0e, $30, $1e, $20
	db $3e, $40, $1c, $60, $5c, $20, $38, $80, $d4, $00, $8c, $00, $18, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $c0, $20, $20, $c0, $c0, $00, $80, $00, $c0, $00
	db $bc, $46, $f8, $0f, $ce, $37, $a7, $78, $7e, $b0, $3a, $c4, $71, $8e, $fc, $03
	db $f3, $00, $a0, $40, $80, $c0, $c0, $00, $c0, $00, $c0, $00, $c0, $00, $80, $00
	db $c0, $00, $c0, $00, $e0, $00, $f0, $00, $fc, $00, $1e, $60, $0e, $10, $07, $08
	db $00, $00, $00, $00, $00, $80, $80, $00, $80, $00, $80, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $80, $f0, $64, $78, $12, $1c, $1b, $04, $0f, $08, $05, $06, $05, $06, $05, $06
	db $05, $06, $05, $06, $09, $c6, $09, $f6, $cd, $32, $3f, $00, $00, $00, $e0, $20
	db $f8, $10, $cc, $30, $f0, $3c, $50, $2c, $70, $6c, $18, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $1f, $20, $06, $01, $01, $06, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $04, $04, $04, $04, $13, $10, $0f, $08
	db $02, $07, $19, $1f, $04, $03, $02, $01, $03, $04, $03, $04, $03, $04, $01, $02
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $01, $00, $01, $02, $03, $04, $04, $08, $00, $00
	db $f0, $00, $a0, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $01, $00, $03, $00, $05, $00, $00, $00, $04, $04, $08, $14, $18, $6c, $70
	db $dd, $e0, $b5, $ca, $e6, $b9, $ef, $10, $1e, $01, $1b, $05, $3e, $0b, $bc, $03
	db $ff, $0c, $73, $9c, $be, $c0, $44, $f8, $f9, $00, $8f, $01, $de, $0f, $b0, $1f
	db $57, $68, $6e, $31, $31, $0e, $1f, $00, $01, $01, $03, $01, $02, $03, $05, $06
	db $1f, $18, $13, $1c, $5f, $60, $bf, $c4, $7b, $8c, $16, $18, $3e, $00, $3c, $00
	db $7c, $00, $7c, $00, $f8, $00, $70, $00, $a8, $00, $18, $00, $30, $00, $00, $00
	db $07, $08, $03, $04, $03, $04, $03, $04, $03, $04, $01, $02, $01, $02, $00, $01
	db $00, $01, $00, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $20, $00, $c0, $00, $80, $08, $50, $18, $e0, $10, $08, $20, $18, $10, $68
	db $20, $50, $d0, $00, $80, $40, $60, $80, $f0, $00, $f8, $80, $78, $80, $f8, $00
	db $bc, $40, $3e, $40, $7e, $50, $fc, $20, $fc, $40, $98, $e0, $30, $c0, $e0, $00
	db $e0, $00, $e0, $00, $38, $c0, $98, $e0, $30, $c0, $60, $80, $c0, $00, $80, $00
	db $80, $00, $80, $00, $80, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $80, $00, $c0, $00, $c0, $00, $e0, $00, $e0, $00, $f0, $00, $f0, $00
	db $f0, $00, $38, $c0, $f4, $08, $e4, $08, $68, $80, $20, $40, $30, $40, $30, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $04, $04, $04, $04, $13, $10, $0f, $08
	db $02, $07, $19, $1f, $04, $03, $02, $01, $03, $04, $03, $04, $03, $04, $01, $02
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $01, $00, $01, $02, $03, $04, $04, $08, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $02
	db $05, $06, $1b, $1c, $37, $38, $2d, $32, $39, $2e, $3b, $04, $07, $00, $03, $01
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $04, $04, $08, $14, $18, $6c, $70
	db $dd, $e0, $b5, $ca, $e6, $b9, $ef, $10, $1e, $01, $1b, $05, $3e, $0b, $bc, $03
	db $ff, $0c, $73, $9c, $be, $c0, $44, $f8, $f9, $00, $8f, $01, $de, $0f, $b0, $1f
	db $57, $68, $6e, $31, $31, $0e, $1f, $00, $01, $01, $03, $01, $02, $03, $05, $06
	db $1f, $18, $13, $1c, $5f, $60, $bf, $c4, $7b, $8c, $16, $18, $3e, $00, $3c, $00
	db $7c, $00, $7c, $00, $f8, $00, $70, $00, $a8, $00, $18, $00, $30, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $02, $03, $05, $06
	db $0b, $0d, $16, $1a, $e6, $18, $7c, $83, $a7, $58, $e2, $3d, $ff, $bb, $3f, $c0
	db $00, $00, $01, $02, $07, $04, $07, $04, $0a, $0c, $17, $1b, $2c, $34, $59, $69
	db $1a, $e3, $d1, $0e, $8e, $40, $60, $80, $f0, $00, $f8, $80, $78, $80, $f8, $00
	db $bc, $40, $3e, $40, $7e, $50, $fc, $20, $fc, $40, $98, $e0, $30, $c0, $e0, $00
	db $e0, $00, $e0, $00, $38, $c0, $98, $e0, $30, $c0, $60, $80, $c0, $00, $80, $00
	db $80, $00, $80, $00, $80, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $70, $b0, $e0, $30, $f4, $08, $a0, $38, $d4, $d8
	db $28, $30, $50, $60, $a0, $c0, $40, $80, $80, $00, $48, $b0, $e4, $d8, $e3, $1c
	db $00, $00, $c0, $c0, $80, $c0, $d0, $20, $80, $e0, $50, $60, $a0, $c0, $40, $80
	db $80, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $02, $03
	db $03, $01, $03, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $02, $09, $06, $19, $07, $18
	db $13, $1c, $09, $1e, $0d, $0e, $06, $0d, $06, $07, $01, $02, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $1c, $e0, $be, $c0, $0f, $31, $0f, $02, $7c, $0f, $f1, $7e, $87, $f8, $bf, $40
	db $76, $88, $89, $76, $fc, $07, $00, $03, $00, $01, $00, $01, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $80, $00, $40, $80, $08, $c8, $84, $6c, $52, $2e, $6b, $15
	db $9f, $63, $eb, $15, $17, $ea, $c6, $39, $a9, $d6, $bf, $4e, $71, $8f, $99, $06
	db $0f, $00, $8e, $01, $c6, $01, $cf, $08, $d7, $18, $a3, $3c, $21, $3e, $23, $3c
	db $2b, $34, $26, $38, $14, $18, $3c, $00, $1e, $00, $0e, $10, $06, $08, $02, $0c
	db $18, $0f, $0c, $07, $86, $03, $c3, $01, $c0, $00, $c0, $00, $e0, $00, $f0, $00
	db $f8, $00, $7e, $00, $8f, $10, $c7, $08, $63, $84, $73, $84, $31, $c2, $31, $c2
	db $71, $82, $19, $e2, $74, $09, $34, $49, $18, $60, $10, $20, $10, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $01, $00, $02, $01, $10, $13, $21, $36, $4a, $74, $d6, $a8
	db $f9, $c6, $d7, $a8, $e8, $57, $63, $9c, $95, $6b, $fd, $72, $8e, $f1, $99, $60
	db $f0, $00, $f1, $80, $63, $80, $e3, $20, $d3, $30, $c9, $78, $28, $f8, $88, $78
	db $b0, $58, $c8, $38, $c8, $30, $f8, $00, $70, $00, $60, $10, $50, $28, $50, $28
	db $80, $00, $40, $80, $20, $c0, $f8, $d8, $e0, $20, $50, $50, $20, $20, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $80, $00, $c0, $00, $e0, $00
	db $e0, $00, $f0, $00, $f0, $00, $f8, $00, $78, $80, $78, $80, $1c, $e0, $fa, $04
	db $72, $04, $34, $40, $10, $20, $18, $20, $18, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $40, $90, $60, $98, $e0, $18
	db $c8, $38, $90, $78, $b0, $70, $60, $b0, $60, $e0, $80, $40, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $06, $08, $06, $08, $0a, $04, $06, $08, $05, $0a, $05, $0a, $0c, $02, $06, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $40, $80, $80, $40, $20, $c0, $80, $60, $18, $68
	db $54, $2c, $22, $1e, $3b, $05, $3f, $03, $7b, $05, $ff, $5f, $c0, $3f, $e0, $1f
	db $7c, $03, $3f, $10, $0e, $01, $1c, $13, $0f, $00, $0b, $0c, $01, $1e, $11, $1e
	db $1d, $1e, $13, $0c, $1e, $00, $07, $08, $03, $04, $01, $06, $03, $04, $05, $02
	db $03, $04, $02, $05, $02, $05, $06, $01, $03, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $18, $64, $28, $44, $00, $00, $00, $00, $80, $00, $80, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $02, $01, $01, $02, $04, $03, $01, $06, $18, $16
	db $2a, $34, $44, $78, $dc, $a0, $fc, $c0, $de, $a0, $fe, $e8, $3b, $f4, $0d, $f6
	db $15, $ea, $eb, $1c, $06, $f8, $0c, $f0, $38, $c0, $f0, $00, $c0, $78, $30, $f8
	db $88, $78, $c8, $30, $78, $00, $70, $00, $f0, $00, $a0, $50, $30, $c8, $50, $88
	db $80, $00, $80, $00, $80, $00, $80, $00, $80, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $80, $00, $80, $00, $80, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $01, $03, $01, $03
	db $01, $07, $00, $07, $00, $04, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $01, $00, $02, $00, $06, $00, $07, $03, $0f, $03, $0f, $07, $0f, $07, $1f
	db $07, $1f, $0f, $1f, $0b, $1f, $0a, $3f, $02, $3f, $00, $3f, $00, $2d, $00, $29
	db $00, $00, $00, $00, $00, $02, $00, $02, $00, $06, $02, $07, $03, $0f, $07, $0f
	db $03, $0f, $02, $0f, $00, $0b, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $20, $40, $c0, $80, $d0
	db $c0, $e0, $00, $c0, $00, $80, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $20, $00, $48, $00, $d8, $80, $f0, $a0, $f0, $a0, $f0, $e0, $f0, $c0, $e0
	db $c0, $e0, $80, $e0, $80, $c0, $00, $c0, $00, $80, $00, $80, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $80, $00, $20, $40, $c0, $80, $d0
	db $c0, $e0, $80, $c0

SECTION "analyzed_0f7f0f", ROMX[$7f0f], BANK[$3d]

Data_3d_7f0f:
	db $e6, $2c, $cb, $51, $53, $62, $00, $00, $5a, $6b, $ce, $39, $63, $0c, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
