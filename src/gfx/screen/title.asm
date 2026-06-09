; title screen -- drawn by DrawTitleScreen (bank $30). Generated from the single editable image
; assets/title/title_screen.png by tools/pngasset.py (screen mode, via assets.yaml): both
; VRAM banks stacked + the 16 CGB palettes embedded. The map descriptor references
; the maps by label (dw). See docs/gfx_assets.md.

SECTION "TitleTiles bank0", ROMX[$4000], BANK[$28]
TitleTilesBank0:
	INCBIN "assets/title/tiles_bank0.bin"   ; 384 tiles -> VRAM bank 0 $8000

TitleTilesBank1:
	INCBIN "assets/title/tiles_bank1.bin"   ; 384 tiles -> VRAM bank 1 $8000

TitlePalettes:
	INCBIN "assets/title/palette.bin"       ; 8 BG + 8 OBJ palettes (RGB555 LE)

TitleMapDesc:
	db 18, 20
	dw TitleAttrMap
	dw TitleIdxMap

TitleIdxMap:
	INCBIN "assets/title/tilemap.bin"

TitleAttrMap:
	INCBIN "assets/title/attrmap.bin"

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

