; Kalum's encounter portrait (tower NPC). Drawn by Kalum_StartEncounter
; ($1f:$417b): the tiles are copied to VRAM bank 1 $8000 ($8800 signed tile
; addressing) and arranged by the CopyBgMap descriptor below over the top
; 20x11 cells; see docs/text_engine.md.
;
; Assembled from the editable source under assets/portrait/kalum/ by
; tools/pngasset.py (`portrait` mode, run in the Makefile, output under
; build/assets/). The descriptor references the two maps by *label* (dw), so the
; region is internally relocatable (docs/philosophy.md). The 6 BG + 6 OBJ palettes
; (loaded by Kalum_StartEncounter from $1d:$5800/$5840) are carved here from the
; PNG's colour table, so the portrait carries its real colour.

SECTION "KalumPortraitTiles", ROMX[$4000], BANK[$1d]
KalumPortraitTiles:
	INCBIN "assets/kalum/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

SECTION "KalumPortraitPaletteBg", ROMX[$5800], BANK[$1d]
KalumPortraitPaletteBg:
	INCBIN "assets/kalum/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

SECTION "KalumPortraitPaletteObj", ROMX[$5840], BANK[$1d]
KalumPortraitPaletteObj:
	INCBIN "assets/kalum/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

SECTION "KalumPortraitMapDesc", ROMX[$5880], BANK[$1d]
KalumPortraitMapDesc:
	db 11, 20                                    ; rows, cols
	dw KalumPortraitAttrMap                       ; CGB attribute map pointer
	dw KalumPortraitIndexMap                      ; tile index map pointer

SECTION "KalumPortraitIndexMap", ROMX[$5886], BANK[$1d]
KalumPortraitIndexMap:
	INCBIN "assets/kalum/tilemap.bin"  ; 20x11 tile indices

SECTION "KalumPortraitAttrMap", ROMX[$5962], BANK[$1d]
KalumPortraitAttrMap:
	INCBIN "assets/kalum/attrmap.bin"  ; 20x11 CGB BG attributes
