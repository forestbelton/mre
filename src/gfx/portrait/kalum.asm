; Kalum's encounter portrait (tower NPC). Drawn by Kalum_StartEncounter
; ($1f:$417b): the tiles are copied to VRAM bank 1 $8000 ($8800 signed tile
; addressing) and arranged by the CopyBgMap descriptor below over the top
; 20x11 cells; see docs/text_engine.md.
;
; Assembled from the editable source under assets/kalum_portrait/ by
; tools/gfxasset.py (run in the Makefile, output under build/assets/). The
; descriptor references the two maps by *label* (dw), so the region is
; internally relocatable (docs/philosophy.md). The 6 BG palettes are
; lib-dispatched and not yet located, so the source is grayscale — only the
; tile pixels + tilemap round-trip here.

SECTION "KalumPortraitTiles", ROMX[$4000], BANK[$1d]
KalumPortraitTiles:
	INCBIN "assets/kalum_portrait/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

SECTION "KalumPortraitMapDesc", ROMX[$5880], BANK[$1d]
KalumPortraitMapDesc:
	db 11, 20                                    ; rows, cols
	dw KalumPortraitAttrMap                       ; CGB attribute map pointer
	dw KalumPortraitIndexMap                      ; tile index map pointer

SECTION "KalumPortraitIndexMap", ROMX[$5886], BANK[$1d]
KalumPortraitIndexMap:
	INCBIN "assets/kalum_portrait/tilemap.bin"  ; 20x11 tile indices

SECTION "KalumPortraitAttrMap", ROMX[$5962], BANK[$1d]
KalumPortraitAttrMap:
	INCBIN "assets/kalum_portrait/attrmap.bin"  ; 20x11 CGB BG attributes
