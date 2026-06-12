; tower entrance (door open) -- drawn by DrawTowerOpenScreen (bank $30). Generated from the single editable image
; assets/tower_open/tower_entrance_open.png by tools/pngasset.py (screen mode, via assets.yaml): both
; VRAM banks stacked + the 16 CGB palettes embedded. The map descriptor references
; the maps by label (dw). See docs/gfx_assets.md.

SECTION "TowerOpenTiles bank0", ROMX[$4000], BANK[$26]
TowerOpenTilesBank0:
	INCBIN "assets/screen/tower_open/tiles_bank0.bin"   ; 384 tiles -> VRAM bank 0 $8000

TowerOpenTilesBank1:
	INCBIN "assets/screen/tower_open/tiles_bank1.bin"   ; 384 tiles -> VRAM bank 1 $8000

TowerOpenPalettes:
	INCBIN "assets/screen/tower_open/palette.bin"       ; 8 BG + 8 OBJ palettes (RGB555 LE)

TowerOpenMapDesc:
	db 18, 20
	dw TowerOpenAttrMap
	dw TowerOpenIdxMap

TowerOpenIdxMap:
	INCBIN "assets/screen/tower_open/tilemap.bin"

TowerOpenAttrMap:
	INCBIN "assets/screen/tower_open/attrmap.bin"

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

