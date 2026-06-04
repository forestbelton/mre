; The intro-cutscene book scene (10x20, top half of the screen): an open book,
; shown as one scene of the opening cutscene. Drawn by Func_30_577e (bank $30),
; reached via the ROM0 $34xx-$35xx screen-transition handlers.
;
; Two-VRAM-bank CGB image, same layout as nada_intro: $29:$4000 -> VRAM bank 0
; $8000 and $29:$5800 -> VRAM bank 1 $8000 (384 tiles each, $8800 addressing);
; the attr map's bit 3 selects the tile bank per cell. Descriptor at $29:$7080
; -> $9800 (10 rows x 20 cols). Grayscale source (palettes lib-dispatched, not
; yet located); tiles + tilemap round-trip byte-exact. See tools/gfxasset.py.

SECTION "IntroBookTilesBank0", ROMX[$4000], BANK[$29]
IntroBookTilesBank0:
	INCBIN "assets/intro_book/tiles2.bin"   ; 384 tiles -> VRAM bank 0 $8000

SECTION "IntroBookTiles", ROMX[$5800], BANK[$29]
IntroBookTiles:
	INCBIN "assets/intro_book/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

SECTION "IntroBookMapDesc", ROMX[$7080], BANK[$29]
IntroBookMapDesc:
	db 10, 20                                 ; rows, cols
	dw IntroBookAttrMap                        ; CGB attribute map pointer
	dw IntroBookIndexMap                       ; tile index map pointer

SECTION "IntroBookIndexMap", ROMX[$7086], BANK[$29]
IntroBookIndexMap:
	INCBIN "assets/intro_book/tilemap.bin"  ; 20x10 tile indices

SECTION "IntroBookAttrMap", ROMX[$714e], BANK[$29]
IntroBookAttrMap:
	INCBIN "assets/intro_book/attrmap.bin"  ; 20x10 CGB BG attributes (bit 3 = VRAM bank)
