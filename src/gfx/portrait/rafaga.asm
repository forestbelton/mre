; Rafaga's encounter portrait (shown during Rafaga's encounter ("Time to fight.")); located by following the
; script's far-calls (tools/find_portraits.py). Same 20x11 single-blob layout as
; Kalum: 384 tiles -> VRAM bank 1 $8000 ($8800 signed addressing), arranged by the
; CopyBgMap descriptor below. Assembled from assets/rafaga_portrait/ via
; tools/gfxasset.py (Makefile, output under build/assets/). Grayscale source --
; palettes are lib-dispatched and not yet located; tiles + tilemap round-trip here.

SECTION "RafagaPortraitTiles", ROMX[$5b19], BANK[$1d]
RafagaPortraitTiles:
	INCBIN "assets/rafaga_portrait/tiles.bin"

SECTION "RafagaPortraitMapDesc", ROMX[$7399], BANK[$1d]
RafagaPortraitMapDesc:
	db 11, 20
	dw RafagaPortraitAttrMap
	dw RafagaPortraitIndexMap

SECTION "RafagaPortraitIndexMap", ROMX[$739f], BANK[$1d]
RafagaPortraitIndexMap:
	INCBIN "assets/rafaga_portrait/tilemap.bin"

SECTION "RafagaPortraitAttrMap", ROMX[$747b], BANK[$1d]
RafagaPortraitAttrMap:
	INCBIN "assets/rafaga_portrait/attrmap.bin"
