; Rafaga's encounter portrait (shown during Rafaga's encounter ("Time to fight.")); located by following the
; script's far-calls (tools/find_portraits.py). Same 20x11 single-blob layout as
; Kalum: 384 tiles -> VRAM bank 1 $8000 ($8800 signed addressing), arranged by the
; CopyBgMap descriptor below. Assembled from assets/portrait/rafaga/ via
; tools/pngasset.py (Makefile, output under build/assets/). The 6 BG + 6 OBJ
; palettes (loaded by Rafaga_StartEncounter from $1d:$7319/$7359) are carved here
; from the PNG's colour table.

SECTION "Rafaga graphics", ROMX

RafagaPortraitTiles:
	INCBIN "assets/rafaga/tiles.bin"

RafagaPortraitPaletteBg:
	INCBIN "assets/rafaga/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

DS $10

RafagaPortraitPaletteObj:
	INCBIN "assets/rafaga/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

DS $10

RafagaPortraitMapDesc:
	db 11, 20
	dw RafagaPortraitAttrMap
	dw RafagaPortraitIndexMap

RafagaPortraitIndexMap:
	INCBIN "assets/rafaga/tilemap.bin"

RafagaPortraitAttrMap:
	INCBIN "assets/rafaga/attrmap.bin"

Data_1d_7557:
	db $02, $02, $61, $75, $5d, $75, $ed, $f5, $ee, $f6, $0d, $0d, $0d, $0d, $0a, $00
	db $00, $00, $08, $00, $08, $02, $08, $00, $10, $04, $08, $00, $18, $06, $08, $00
	db $20, $08, $08, $10, $00, $0a, $08, $10, $08, $0c, $08, $10, $10, $0e, $08, $10
	db $18, $10, $08, $10, $20, $12, $08, $02, $02, $98, $75, $94, $75, $56, $5e, $57
	db $5f, $0d, $0d, $0d, $0d, $0a, $00, $00, $00, $08, $00, $08, $02, $08, $00, $10
	db $26, $08, $00, $18, $28, $08, $00, $20, $08, $08, $10, $00, $0a, $08, $10, $08
	db $0c, $08, $10, $10, $0e, $08, $10, $18, $10, $08, $10, $20, $12, $08, $06, $00
	db $00, $14, $09, $00, $08, $16, $09, $00, $10, $18, $09, $10, $00, $1a, $09, $10
	db $08, $1c, $09, $10, $10, $1e, $09, $02, $00, $00, $20, $09, $00, $08, $22, $09
	db $01, $00, $00, $24, $0d
