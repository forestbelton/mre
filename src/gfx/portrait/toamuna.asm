; Toamuna's portrait (ranch save NPC, mother of Naji). Shown by her "what do you
; want to do?" menu; located by following her script's far-calls
; (tools/find_portraits.py). Same descriptor layout as Kalum's portrait: the 384
; tiles are copied to VRAM bank 1 $8000 ($8800 signed addressing) and arranged by
; the CopyBgMap descriptor below over the top 20x11 cells.
;
; Assembled from the editable source under assets/toamuna/ by
; tools/gfxasset.py (run in the Makefile, output under build/assets/). The
; descriptor references the two maps by *label* (dw), so the region is internally
; relocatable. The BG palettes are lib-dispatched and not yet located, so the
; source is grayscale — only the tile pixels + tilemap round-trip here.

SECTION "ToamunaPortraitTiles", ROMX[$4000], BANK[$1a]
ToamunaPortraitTiles:
	INCBIN "assets/toamuna/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

SECTION "ToamunaPortraitMapDesc", ROMX[$5880], BANK[$1a]
ToamunaPortraitMapDesc:
	db 11, 20                                      ; rows, cols
	dw ToamunaPortraitAttrMap                       ; CGB attribute map pointer
	dw ToamunaPortraitIndexMap                      ; tile index map pointer

SECTION "ToamunaPortraitIndexMap", ROMX[$5886], BANK[$1a]
ToamunaPortraitIndexMap:
	INCBIN "assets/toamuna/tilemap.bin"  ; 20x11 tile indices

SECTION "ToamunaPortraitAttrMap", ROMX[$5962], BANK[$1a]
ToamunaPortraitAttrMap:
	INCBIN "assets/toamuna/attrmap.bin"  ; 20x11 CGB BG attributes
