; Town screen -- the overworld town (fountain + totem), drawn by DrawTownScreen
; ($30:$401e). Generated from the editable sources in assets/town/ by
; tools/pngasset.py (`screen` mode, run in the Makefile, output under
; build/assets/town/): two tile sheets -> VRAM banks 0/1, the 16 CGB
; palettes ($7000), and the tilemap/attrmap. The map descriptor references the two
; maps by *label* (dw), so the region could relocate cleanly (see docs/philosophy.md).
; This is the first bank-$30 screen migrated off the inline-`db` extract dump onto
; the PNG-driven pipeline -- the two-bank + colour exemplar. See docs/gfx_assets.md.

SECTION "Town screen graphics", ROMX

TownTilesBank0:
	INCBIN "assets/town/tiles_bank0.bin"   ; 384 tiles -> VRAM bank 0 $8000

TownTilesBank1:
	INCBIN "assets/town/tiles_bank1.bin"   ; 384 tiles -> VRAM bank 1 $8000

TownPalettes:
	INCBIN "assets/town/palette.bin"       ; 8 BG + 8 OBJ palettes (RGB555 LE)

TownMapDesc:
	db 18, 20                                      ; rows, cols
	dw TownAttrMap                                 ; CGB attribute-map pointer
	dw TownIdxMap                                  ; tile-index-map pointer

TownIdxMap:
	INCBIN "assets/town/tilemap.bin"        ; 20x18 tile indices

TownAttrMap:
	INCBIN "assets/town/attrmap.bin"        ; 20x18 CGB BG attributes
