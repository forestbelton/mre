; Pashute's encounter portrait (shown during Pashute's encounter); located by following the
; script's far-calls (tools/find_portraits.py). Same 20x11 single-blob layout as
; Kalum: 384 tiles -> VRAM bank 1 $8000 ($8800 signed addressing), arranged by the
; CopyBgMap descriptor below. Assembled from assets/pashute_portrait/ via
; tools/gfxasset.py (Makefile, output under build/assets/). Grayscale source --
; palettes are lib-dispatched and not yet located; tiles + tilemap round-trip here.

SECTION "PashutePortraitTiles", ROMX[$4000], BANK[$1b]
PashutePortraitTiles:
	INCBIN "assets/pashute_portrait/tiles.bin"

SECTION "PashutePortraitMapDesc", ROMX[$5880], BANK[$1b]
PashutePortraitMapDesc:
	db 11, 20
	dw PashutePortraitAttrMap
	dw PashutePortraitIndexMap

SECTION "PashutePortraitIndexMap", ROMX[$5886], BANK[$1b]
PashutePortraitIndexMap:
	INCBIN "assets/pashute_portrait/tilemap.bin"

SECTION "PashutePortraitAttrMap", ROMX[$5962], BANK[$1b]
PashutePortraitAttrMap:
	INCBIN "assets/pashute_portrait/attrmap.bin"
