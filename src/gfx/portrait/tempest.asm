; Tempest's encounter portrait (shown during Tempest's encounter ("help me again.")); located by following the
; script's far-calls (tools/find_portraits.py). Same 20x11 single-blob layout as
; Kalum: 384 tiles -> VRAM bank 1 $8000 ($8800 signed addressing), arranged by the
; CopyBgMap descriptor below. Assembled from assets/portrait/tempest/ via
; tools/pngasset.py (Makefile, output under build/assets/). The 6 BG + 6 OBJ
; palettes (loaded by Tempest_StartEncounter from $1e:$73e7/$7427) are carved here
; from the PNG's colour table.

SECTION "TempestPortraitTiles", ROMX[$5be7], BANK[$1e]
TempestPortraitTiles:
	INCBIN "assets/tempest/tiles.bin"

SECTION "TempestPortraitPaletteBg", ROMX[$73e7], BANK[$1e]
TempestPortraitPaletteBg:
	INCBIN "assets/tempest/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

SECTION "TempestPortraitPaletteObj", ROMX[$7427], BANK[$1e]
TempestPortraitPaletteObj:
	INCBIN "assets/tempest/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

SECTION "TempestPortraitMapDesc", ROMX[$7467], BANK[$1e]
TempestPortraitMapDesc:
	db 11, 20
	dw TempestPortraitAttrMap
	dw TempestPortraitIndexMap

SECTION "TempestPortraitIndexMap", ROMX[$746d], BANK[$1e]
TempestPortraitIndexMap:
	INCBIN "assets/tempest/tilemap.bin"

SECTION "TempestPortraitAttrMap", ROMX[$7549], BANK[$1e]
TempestPortraitAttrMap:
	INCBIN "assets/tempest/attrmap.bin"
