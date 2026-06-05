; Bodka's portrait (the older man in Nada's dialogue; shown recurringly as he and
; Nada talk -- the separate $1e:$5bd9 2x2 descriptor is a mouth-animation overlay,
; not this image). Single-blob Kalum layout: 384 tiles -> VRAM bank 1 $8000 ($8800
; addressing), arranged by the CopyBgMap descriptor below. Located via
; tools/find_portraits.py.
;
; Assembled from assets/portrait/bodka/ by tools/pngasset.py (Makefile, output
; under build/assets/). The 6 BG + 6 OBJ palettes (loaded by Bodka_BuildStudioScene
; from $1e:$5800/$5840) are carved here from the PNG's colour table.

SECTION "Bodka graphics", ROMX

BodkaPortraitTiles:
	INCBIN "assets/bodka/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

BodkaPortraitPaletteBg:
	INCBIN "assets/bodka/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

DS $10

BodkaPortraitPaletteObj:
	INCBIN "assets/bodka/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

DS $10

BodkaPortraitMapDesc:
	db 11, 20                                    ; rows, cols
	dw BodkaPortraitAttrMap                       ; CGB attribute map pointer
	dw BodkaPortraitIndexMap                      ; tile index map pointer

BodkaPortraitIndexMap:
	INCBIN "assets/bodka/tilemap.bin"  ; 20x11 tile indices

BodkaPortraitAttrMap:
	INCBIN "assets/bodka/attrmap.bin"  ; 20x11 CGB BG attributes

Data_1e_5a3e:
	db $01, $03, $47, $5a, $44, $5a, $b5, $bd, $c5, $0a, $0a, $0a, $0a, $00, $00, $00
	db $08, $00, $08, $02, $08, $00, $10, $04, $08, $00, $18, $06, $08, $00, $20, $08
	db $09, $10, $00, $0a, $08, $10, $08, $0c, $08, $10, $10, $0e, $08, $10, $18, $10
	db $08, $10, $20, $12, $09, $01, $03, $7c, $5a, $79, $5a, $56, $57, $5e, $0a, $0a
	db $0a, $0a, $00, $00, $00, $08, $00, $08, $02, $08, $00, $10, $04, $08, $00, $18
	db $06, $08, $00, $20, $08, $09, $10, $00, $0a, $08, $10, $08, $14, $08, $10, $10
	db $16, $08, $10, $18, $18, $08, $10, $20, $12, $09, $01, $03, $b1, $5a, $ae, $5a
	db $5f, $60, $61, $0a, $0a, $0a, $0a, $00, $00, $00, $08, $00, $08, $02, $08, $00
	db $10, $04, $08, $00, $18, $06, $08, $00, $20, $08, $09, $10, $00, $0a, $08, $10
	db $08, $1a, $08, $10, $10, $1c, $08, $10, $18, $1e, $08, $10, $20, $12, $09, $10
	db $00, $00, $20, $08, $00, $08, $22, $08, $00, $10, $24, $08, $00, $18, $26, $08
	db $00, $20, $28, $08, $00, $28, $2a, $08, $00, $30, $2c, $08, $00, $38, $2e, $08
	db $10, $00, $30, $08, $10, $08, $32, $08, $10, $10, $34, $08, $10, $18, $36, $08
	db $10, $20, $38, $08, $10, $28, $3a, $08, $10, $30, $3c, $08, $10, $38, $3e, $08
	db $02, $03, $2a, $5b, $24, $5b, $62, $64, $66, $63, $65, $67, $0a, $0a, $0a, $0a
	db $0a, $0a, $0a, $00, $00, $40, $08, $00, $08, $42, $08, $00, $10, $44, $08, $00
	db $18, $46, $08, $00, $20, $08, $09, $10, $00, $48, $08, $10, $08, $4a, $08, $10
	db $10, $4c, $08, $10, $18, $4e, $08, $10, $20, $12, $09, $44, $18, $69, $20, $d6
	db $1d, $ed, $2c, $44, $18, $69, $20, $14, $3a, $ed, $2c, $44, $18, $69, $20, $5a
	db $6b, $ed, $2c, $44, $18, $44, $18, $44, $18, $44, $18, $44, $18, $44, $18, $44
	db $18, $44, $18, $44, $18, $44, $18, $44, $18, $44, $18

Data_1e_5b89:
	db $e0, $03, $e0, $03, $e0, $03, $e0, $03, $e0, $03, $e0, $03, $e0, $03, $e0, $03

Data_1e_5b99:
	db $e0, $03, $df, $3a, $6d, $45, $e5, $34, $00, $7c, $73, $52, $6d, $45, $e5, $34
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

Data_1e_5bd9:
	db $02, $02, $e3, $5b, $df, $5b, $68, $70, $69, $71, $0b, $08, $08, $08
