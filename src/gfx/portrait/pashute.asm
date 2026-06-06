; Pashute's encounter portrait (shown during Pashute's encounter); located by following the
; script's far-calls (tools/find_portraits.py). Same 20x11 single-blob layout as
; Kalum: 384 tiles -> VRAM bank 1 $8000 ($8800 signed addressing), arranged by the
; CopyBgMap descriptor below. Assembled from assets/portrait/pashute/ via
; tools/pngasset.py (Makefile, output under build/assets/). The 6 BG + 6 OBJ
; palettes (loaded by Pashute_LoadShrineScene from $1b:$5800/$5840) are carved here
; from the PNG's colour table.

SECTION "PashutePortraitTiles", ROMX[$4000], BANK[$1b]
PashutePortraitTiles:
	INCBIN "assets/pashute/tiles.bin"

PashutePortraitPaletteBg:
	INCBIN "assets/pashute/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

SECTION "PashutePortraitPaletteObj", ROMX[$5840], BANK[$1b]
PashutePortraitPaletteObj:
	INCBIN "assets/pashute/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

SECTION "PashutePortraitMapDesc", ROMX[$5880], BANK[$1b]
PashutePortraitMapDesc:
	db 11, 20
	dw PashutePortraitAttrMap
	dw PashutePortraitIndexMap

PashutePortraitIndexMap:
	INCBIN "assets/pashute/tilemap.bin"

PashutePortraitAttrMap:
	INCBIN "assets/pashute/attrmap.bin"
