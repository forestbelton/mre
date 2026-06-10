; Dungeon tileset loader (ROM bank $16).
;
; LoadTileset swaps a floor's tile graphics into VRAM, chosen by the tileset id
; in $c4cc (the floor record's [4] field; see layout.asm/ParseFloorRecord).
; The TilesetSrcPtrs table maps id -> source tiles: ids 0-5 are full tilesets,
; ids 6-10 are partial tile-chunk updates. Called from home/scene/monster_detail.
; Carved out of analyzed.asm (byte-exact; section names unchanged).

INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "sound_ids.inc"

SECTION "analyzed_058000", ROMX[$4000], BANK[$16]

; Source-tile pointer per tileset id (the floor record's [4] field, in $c4cc).
; ids 0-5 -> full tilesets in TilesetTiles; ids 6-10 -> partial-update chunks.
TilesetSrcPtrs:
	dw $407f, $487f, $507f, $587f, $607f, $687f   ; 0-5 full tilesets ($800 each)
	dw $707f, $717f, $727f, $737f, $747f          ; 6-10 partial-update sets

; Load the tileset selected by [$c4cc] into VRAM bank 1. ids 0-5 copy a full
; $800-byte (64-tile) tileset to $9000; ids >= 6 take the .scatter path that
; pokes eight 32-byte tile chunks into fixed VRAM slots (animated/UI tiles).
LoadTileset:
	ld a, $01
	ld [rVBK], a
	ld a, [$c4cc]              ; tileset id (floor record [4])
	ld c, a
	add a, a
	ld hl, TilesetSrcPtrs
	rst AddAToHL
	ld a, [hl+]
	ld h, [hl]
	ld l, a                    ; hl = TilesetSrcPtrs[id]
	ld a, c
	cp $06
	jr nc, .scatter
	ld de, $9000
	ld bc, $0800
	call VramCopy16
	ret
.scatter:
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

; Full tileset graphics: ids 0-5 are 6 complete $800-byte (64-tile) tilesets,
; ids 6-10 continue into TilesetTilesPartial as small partial-update tile chunks.
TilesetTiles:
	INCBIN "gfx/raw/Data_16_407f.2bpp", 0, 12800

; Partial-update tile chunks for tileset ids 8-10 (TilesetSrcPtrs[8..10] point
; here); the .scatter path pokes 32-byte pieces of these into fixed VRAM slots.
TilesetTilesPartial:
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

; Count-prefixed metasprite ($11 = 17 OAM records) drawn from this bank's tiles
; by home Func_00_289d (sets wDrawBank=$16, DrawMetasprite at $1008). Depiction
; not yet pinned in-game.
TilesetMetasprite:
	db $11, $08, $08, $00, $00, $08, $10, $08, $00, $f0, $10, $7c, $01, $f0, $30, $06
	db $41, $f0, $30, $06, $41, $f0, $30, $06, $41, $f0, $00, $00, $00, $f0, $00, $00
	db $00, $f0, $00, $00, $00, $f0, $00, $00, $00, $f0, $00, $00, $00, $f0, $00, $00
	db $00, $f0, $00, $00, $00, $f0, $00, $00, $00, $f0, $00, $00, $00, $f0, $88, $64
	db $00, $f0, $90, $6c, $00, $11, $28, $20, $7c, $01, $20, $2c, $06, $01, $30, $2c
	db $06, $41, $28, $28, $62, $00, $28, $30, $6a, $00, $28, $48, $62, $00, $28, $50
	db $6a, $00, $28, $68, $62, $00, $28, $70, $6a, $00, $48, $28, $62, $00, $48, $30
	db $6a, $00, $48, $48, $62, $00, $48, $50, $6a, $00, $48, $68, $62, $00, $48, $70
	db $6a, $00, $08, $88, $64, $00, $08, $90, $6c

