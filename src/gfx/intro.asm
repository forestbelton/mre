; intro-cutscene open book (top 10 rows) -- drawn by DrawIntroBookScreen (bank $30). Generated from the single editable image
; assets/intro/intro_book.png by tools/pngasset.py (screen mode, via assets.yaml): both
; VRAM banks stacked + the 16 CGB palettes embedded. The map descriptor references
; the maps by label (dw). See docs/gfx_assets.md.

SECTION "IntroBookTiles bank0", ROMX[$4000], BANK[$29]
IntroBookTilesBank0:
	INCBIN "assets/intro/tiles_bank0.bin"   ; 384 tiles -> VRAM bank 0 $8000

IntroBookTilesBank1:
	INCBIN "assets/intro/tiles_bank1.bin"   ; 384 tiles -> VRAM bank 1 $8000

IntroBookPalettes:
	INCBIN "assets/intro/palette.bin"       ; 8 BG + 8 OBJ palettes (RGB555 LE)

IntroBookMapDesc:
	db 10, 20
	dw IntroBookAttrMap
	dw IntroBookIdxMap

IntroBookIdxMap:
	INCBIN "assets/intro/tilemap.bin"

IntroBookAttrMap:
	INCBIN "assets/intro/attrmap.bin"
