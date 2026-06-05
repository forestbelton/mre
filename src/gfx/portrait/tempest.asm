; Tempest's encounter portrait (shown during Tempest's encounter ("help me again.")); located by following the
; script's far-calls (tools/find_portraits.py). Same 20x11 single-blob layout as
; Kalum: 384 tiles -> VRAM bank 1 $8000 ($8800 signed addressing), arranged by the
; CopyBgMap descriptor below. Assembled from assets/tempest/ via
; tools/gfxasset.py (Makefile, output under build/assets/). Grayscale source --
; palettes are lib-dispatched and not yet located; tiles + tilemap round-trip here.

SECTION "TempestPortraitTiles", ROMX[$5be7], BANK[$1e]
TempestPortraitTiles:
	INCBIN "assets/tempest/tiles.bin"

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
