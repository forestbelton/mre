; Rafaga's encounter portrait (shown during Rafaga's encounter ("Time to fight.")); located by following the
; script's far-calls (tools/find_portraits.py). Same 20x11 single-blob layout as
; Kalum: 384 tiles -> VRAM bank 1 $8000 ($8800 signed addressing), arranged by the
; CopyBgMap descriptor below. Assembled from assets/portrait/rafaga/ via
; tools/pngasset.py (Makefile, output under build/assets/). The 6 BG + 6 OBJ
; palettes (loaded by Rafaga_StartEncounter from $1d:$7319/$7359) are carved here
; from the PNG's colour table.

SECTION "RafagaPortraitTiles", ROMX[$5b19], BANK[$1d]
RafagaPortraitTiles:
	INCBIN "assets/rafaga/tiles.bin"

SECTION "RafagaPortraitPaletteBg", ROMX[$7319], BANK[$1d]
RafagaPortraitPaletteBg:
	INCBIN "assets/rafaga/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

SECTION "RafagaPortraitPaletteObj", ROMX[$7359], BANK[$1d]
RafagaPortraitPaletteObj:
	INCBIN "assets/rafaga/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

SECTION "RafagaPortraitMapDesc", ROMX[$7399], BANK[$1d]
RafagaPortraitMapDesc:
	db 11, 20
	dw RafagaPortraitAttrMap
	dw RafagaPortraitIndexMap

SECTION "RafagaPortraitIndexMap", ROMX[$739f], BANK[$1d]
RafagaPortraitIndexMap:
	INCBIN "assets/rafaga/tilemap.bin"

SECTION "RafagaPortraitAttrMap", ROMX[$747b], BANK[$1d]
RafagaPortraitAttrMap:
	INCBIN "assets/rafaga/attrmap.bin"
