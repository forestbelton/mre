; title screen -- drawn by DrawTitleScreen (bank $30). Generated from the single editable image
; assets/title/title_screen.png by tools/pngasset.py (screen mode, via assets.yaml): both
; VRAM banks stacked + the 16 CGB palettes embedded. The map descriptor references
; the maps by label (dw). See docs/gfx_assets.md.

SECTION "TitleTiles bank0", ROMX[$4000], BANK[$28]
TitleTilesBank0:
	INCBIN "assets/title/tiles_bank0.bin"   ; 384 tiles -> VRAM bank 0 $8000

TitleTilesBank1:
	INCBIN "assets/title/tiles_bank1.bin"   ; 384 tiles -> VRAM bank 1 $8000

TitlePalettes:
	INCBIN "assets/title/palette.bin"       ; 8 BG + 8 OBJ palettes (RGB555 LE)

TitleMapDesc:
	db 18, 20
	dw TitleAttrMap
	dw TitleIdxMap

TitleIdxMap:
	INCBIN "assets/title/tilemap.bin"

TitleAttrMap:
	INCBIN "assets/title/attrmap.bin"
