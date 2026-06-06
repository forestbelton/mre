; Toamuna's portrait (ranch save NPC, mother of Naji). Shown by her "what do you
; want to do?" menu; located by following her script's far-calls
; (tools/find_portraits.py). Same descriptor layout as Kalum's portrait: the 384
; tiles are copied to VRAM bank 1 $8000 ($8800 signed addressing) and arranged by
; the CopyBgMap descriptor below over the top 20x11 cells.
;
; Assembled from the editable source under assets/portrait/toamuna/ by
; tools/pngasset.py (run in the Makefile, output under build/assets/). The
; descriptor references the two maps by *label* (dw), so the region is internally
; relocatable. The 6 BG + 6 OBJ palettes (loaded by Toamuna_CheckSaveExists from
; $1a:$5800/$5840) are carved here from the PNG's colour table.

SECTION "ToamunaPortraitTiles", ROMX[$4000], BANK[$1a]
ToamunaPortraitTiles:
	INCBIN "assets/toamuna/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

ToamunaPortraitPaletteBg:
	INCBIN "assets/toamuna/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

SECTION "ToamunaPortraitPaletteObj", ROMX[$5840], BANK[$1a]
ToamunaPortraitPaletteObj:
	INCBIN "assets/toamuna/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

SECTION "ToamunaPortraitMapDesc", ROMX[$5880], BANK[$1a]
ToamunaPortraitMapDesc:
	db 11, 20                                      ; rows, cols
	dw ToamunaPortraitAttrMap                       ; CGB attribute map pointer
	dw ToamunaPortraitIndexMap                      ; tile index map pointer

ToamunaPortraitIndexMap:
	INCBIN "assets/toamuna/tilemap.bin"  ; 20x11 tile indices

ToamunaPortraitAttrMap:
	INCBIN "assets/toamuna/attrmap.bin"  ; 20x11 CGB BG attributes
