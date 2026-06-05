; Naji's encounter portrait (shown during Naji's encounter); located by following the
; script's far-calls (tools/find_portraits.py). Same 20x11 single-blob layout as
; Kalum: 384 tiles -> VRAM bank 1 $8000 ($8800 signed addressing), arranged by the
; CopyBgMap descriptor below. Assembled from assets/portrait/naji/ via
; tools/pngasset.py (Makefile, output under build/assets/). The 6 BG + 6 OBJ
; palettes (loaded by Func_18_6bc8 from $1a:$72e8/$7328) are carved here from the
; PNG's colour table.

SECTION "NajiPortraitTiles", ROMX[$5ae8], BANK[$1a]
NajiPortraitTiles:
	INCBIN "assets/naji/tiles.bin"

SECTION "NajiPortraitPaletteBg", ROMX[$72e8], BANK[$1a]
NajiPortraitPaletteBg:
	INCBIN "assets/naji/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

SECTION "NajiPortraitPaletteObj", ROMX[$7328], BANK[$1a]
NajiPortraitPaletteObj:
	INCBIN "assets/naji/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

SECTION "NajiPortraitMapDesc", ROMX[$7368], BANK[$1a]
NajiPortraitMapDesc:
	db 11, 20
	dw NajiPortraitAttrMap
	dw NajiPortraitIndexMap

SECTION "NajiPortraitIndexMap", ROMX[$736e], BANK[$1a]
NajiPortraitIndexMap:
	INCBIN "assets/naji/tilemap.bin"

SECTION "NajiPortraitAttrMap", ROMX[$744a], BANK[$1a]
NajiPortraitAttrMap:
	INCBIN "assets/naji/attrmap.bin"
