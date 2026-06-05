; intro-cutscene open book (top 10 rows) -- drawn by DrawIntroBookScreen (bank $30). Generated from the single editable image
; assets/intro_book/intro_book.png by tools/pngasset.py (screen mode, via assets.yaml): both
; VRAM banks stacked + the 16 CGB palettes embedded. The map descriptor references
; the maps by label (dw). See docs/gfx_assets.md.

SECTION "IntroBookTiles bank0", ROMX[$4000], BANK[$29]
IntroBookTilesBank0:
	INCBIN "assets/intro_book/tiles_bank0.bin"   ; 384 tiles -> VRAM bank 0 $8000

SECTION "IntroBookTiles bank1", ROMX[$5800], BANK[$29]
IntroBookTilesBank1:
	INCBIN "assets/intro_book/tiles_bank1.bin"   ; 384 tiles -> VRAM bank 1 $8000

SECTION "IntroBookPalettes", ROMX[$7000], BANK[$29]
IntroBookPalettes:
	INCBIN "assets/intro_book/palette.bin"       ; 8 BG + 8 OBJ palettes (RGB555 LE)

SECTION "IntroBookDescriptor", ROMX[$7080], BANK[$29]
IntroBookMapDesc:
	db 10, 20
	dw IntroBookAttrMap
	dw IntroBookIdxMap

SECTION "IntroBookIdxMap", ROMX[$7086], BANK[$29]
IntroBookIdxMap:
	INCBIN "assets/intro_book/tilemap.bin"

SECTION "IntroBookAttrMap", ROMX[$714e], BANK[$29]
IntroBookAttrMap:
	INCBIN "assets/intro_book/attrmap.bin"
