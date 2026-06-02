; Naji's encounter portrait (shown during Naji's encounter); located by following the
; script's far-calls (tools/find_portraits.py). Same 20x11 single-blob layout as
; Kalum: 384 tiles -> VRAM bank 1 $8000 ($8800 signed addressing), arranged by the
; CopyBgMap descriptor below. Assembled from assets/naji_portrait/ via
; tools/gfxasset.py (Makefile, output under build/assets/). Grayscale source --
; palettes are lib-dispatched and not yet located; tiles + tilemap round-trip here.

SECTION "NajiPortraitTiles", ROMX[$5ae8], BANK[$1a]
NajiPortraitTiles:
	INCBIN "assets/naji_portrait/tiles.bin"

SECTION "NajiPortraitMapDesc", ROMX[$7368], BANK[$1a]
NajiPortraitMapDesc:
	db 11, 20
	dw NajiPortraitAttrMap
	dw NajiPortraitIndexMap

SECTION "NajiPortraitIndexMap", ROMX[$736e], BANK[$1a]
NajiPortraitIndexMap:
	INCBIN "assets/naji_portrait/tilemap.bin"

SECTION "NajiPortraitAttrMap", ROMX[$744a], BANK[$1a]
NajiPortraitAttrMap:
	INCBIN "assets/naji_portrait/attrmap.bin"
