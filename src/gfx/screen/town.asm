; Town screen -- the overworld town (fountain + totem), drawn by DrawTownScreen
; ($30:$401e). Generated from the editable sources in assets/town_screen/ by
; tools/pngasset.py (`screen` mode, run in the Makefile, output under
; build/assets/town_screen/): two tile sheets -> VRAM banks 0/1, the 16 CGB
; palettes ($7000), and the tilemap/attrmap. The map descriptor references the two
; maps by *label* (dw), so the region could relocate cleanly (see docs/philosophy.md).
; This is the first bank-$30 screen migrated off the inline-`db` extract dump onto
; the PNG-driven pipeline -- the two-bank + colour exemplar. See docs/gfx_assets.md.

SECTION "TownScreen tiles bank0", ROMX[$4000], BANK[$20]
TownTilesBank0:
	INCBIN "assets/town_screen/tiles_bank0.bin"   ; 384 tiles -> VRAM bank 0 $8000

SECTION "TownScreen tiles bank1", ROMX[$5800], BANK[$20]
TownTilesBank1:
	INCBIN "assets/town_screen/tiles_bank1.bin"   ; 384 tiles -> VRAM bank 1 $8000

SECTION "TownScreen palettes", ROMX[$7000], BANK[$20]
TownPalettes:
	INCBIN "assets/town_screen/palette.bin"       ; 8 BG + 8 OBJ palettes (RGB555 LE)

SECTION "TownScreen descriptor", ROMX[$7080], BANK[$20]
TownMapDesc:
	db 18, 20                                      ; rows, cols
	dw TownAttrMap                                 ; CGB attribute-map pointer
	dw TownIdxMap                                  ; tile-index-map pointer

SECTION "TownScreen idxmap", ROMX[$7086], BANK[$20]
TownIdxMap:
	INCBIN "assets/town_screen/tilemap.bin"        ; 20x18 tile indices

SECTION "TownScreen attrmap", ROMX[$71ee], BANK[$20]
TownAttrMap:
	INCBIN "assets/town_screen/attrmap.bin"        ; 20x18 CGB BG attributes
