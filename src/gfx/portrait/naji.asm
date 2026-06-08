; Naji's encounter portrait (shown during Naji's encounter); located by following the
; script's far-calls (tools/find_portraits.py). Same 20x11 single-blob layout as
; Kalum: 384 tiles -> VRAM bank 1 $8000 ($8800 signed addressing), arranged by the
; CopyBgMap descriptor below. Assembled from assets/portrait/naji/ via
; tools/pngasset.py (Makefile, output under build/assets/). The 6 BG + 6 OBJ
; palettes (loaded by Naji_BuildPortraitScene from $1a:$72e8/$7328) are carved here from the
; PNG's colour table.

SECTION "Naji graphics", ROMX

NajiPortraitTiles:
	INCBIN "assets/naji/tiles.bin"

NajiPortraitPaletteBg:
	INCBIN "assets/naji/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

DS $10

NajiPortraitPaletteObj:
	INCBIN "assets/naji/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

DS $10

NajiPortraitMapDesc:
	db 11, 20
	dw NajiPortraitAttrMap
	dw NajiPortraitIndexMap

NajiPortraitIndexMap:
	INCBIN "assets/naji/tilemap.bin"

NajiPortraitAttrMap:
	INCBIN "assets/naji/attrmap.bin"

Data_1a_7526:
	db $01, $03, $2f, $75, $2c, $75, $b4, $bc, $c4, $09, $09, $09, $0a, $00, $00, $00
	db $08, $00, $08, $02, $08, $00, $10, $04, $08, $00, $18, $06, $08, $00, $20, $08
	db $08, $10, $00, $0a, $09, $10, $08, $0c, $09, $10, $10, $0e, $09, $10, $18, $10
	db $09, $10, $20, $12, $09, $01, $03, $64, $75, $61, $75, $56, $57, $5e, $09, $09
	db $09, $0a, $00, $00, $00, $08, $00, $08, $02, $08, $00, $10, $04, $08, $00, $18
	db $06, $08, $00, $20, $08, $08, $10, $00, $0a, $09, $10, $08, $34, $09, $10, $10
	db $36, $09, $10, $18, $38, $09, $10, $20, $12, $09, $04, $00, $00, $14, $09, $00
	db $08, $16, $09, $00, $10, $18, $09, $00, $18, $1a, $09, $06, $00, $00, $1c, $0a
	db $00, $08, $1e, $0a, $00, $10, $20, $0a, $10, $00, $22, $0a, $10, $08, $24, $0a
	db $10, $10, $26, $0a, $06, $00, $00, $28, $0a, $00, $08, $2a, $0a, $00, $10, $2c
	db $0a, $10, $00, $2e, $0a, $10, $08, $30, $0a, $10, $10, $32, $0a, $03, $03, $e2
	db $75, $d9, $75, $b4, $bc, $c4, $b5, $bd, $c5, $b6, $be, $c6, $09, $09, $09, $09
	db $09, $09, $09, $09, $09, $03, $03, $fa, $75, $f1, $75, $5f, $62, $65, $60, $63
	db $66, $61, $64, $67, $09, $09, $09, $09, $09, $09, $09, $09, $09, $0a, $00, $00
	db $00, $08, $00, $08, $02, $08, $00, $10, $04, $08, $00, $18, $06, $08, $00, $20
	db $08, $08, $10, $00, $0a, $09, $10, $08, $3a, $09, $10, $10, $3c, $09, $10, $18
	db $3e, $09, $10, $20, $12, $09
