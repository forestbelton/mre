; Tempest's encounter portrait (shown during Tempest's encounter ("help me again.")); located by following the
; script's far-calls (tools/find_portraits.py). Same 20x11 single-blob layout as
; Kalum: 384 tiles -> VRAM bank 1 $8000 ($8800 signed addressing), arranged by the
; CopyBgMap descriptor below. Assembled from assets/portrait/tempest/ via
; tools/pngasset.py (Makefile, output under build/assets/). The 6 BG + 6 OBJ
; palettes (loaded by Tempest_StartEncounter from $1e:$73e7/$7427) are carved here
; from the PNG's colour table.

SECTION "Tempest graphics", ROMX

TempestPortraitTiles:
	INCBIN "assets/tempest/tiles.bin"

TempestPortraitPaletteBg:
	INCBIN "assets/tempest/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

DS $10

TempestPortraitPaletteObj:
	INCBIN "assets/tempest/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

DS $10

TempestPortraitMapDesc:
	db 11, 20
	dw TempestPortraitAttrMap
	dw TempestPortraitIndexMap

TempestPortraitIndexMap:
	INCBIN "assets/tempest/tilemap.bin"

TempestPortraitAttrMap:
	INCBIN "assets/tempest/attrmap.bin"

Data_1e_7625:
	db $02, $02, $2f, $76, $2b, $76, $ed, $f5, $ee, $f6, $0c, $0c, $0a, $0c, $0f, $00
	db $00, $00, $08, $00, $08, $02, $08, $00, $10, $04, $08, $00, $18, $06, $08, $00
	db $20, $08, $08, $10, $00, $0a, $08, $10, $08, $0c, $08, $10, $10, $0e, $08, $10
	db $18, $10, $08, $10, $20, $12, $08, $20, $00, $14, $08, $20, $08, $16, $08, $20
	db $10, $18, $08, $20, $18, $18, $08, $20, $20, $18, $08, $02, $02, $7a, $76, $76
	db $76, $56, $5e, $57, $5f, $0a, $0a, $0a, $0a, $0f, $00, $00, $00, $08, $00, $08
	db $02, $08, $00, $10, $26, $08, $00, $18, $28, $08, $00, $20, $08, $08, $10, $00
	db $0a, $08, $10, $08, $0c, $08, $10, $10, $2a, $08, $10, $18, $2c, $08, $10, $20
	db $12, $08, $20, $00, $14, $08, $20, $08, $16, $08, $20, $10, $18, $08, $20, $18
	db $18, $08, $20, $20, $18, $08, $04, $00, $00, $1a, $09, $00, $08, $1c, $09, $10
	db $00, $1e, $09, $10, $08, $18, $09, $02, $00, $00, $20, $09, $00, $08, $22, $09
	db $01, $00, $00, $24, $0d
