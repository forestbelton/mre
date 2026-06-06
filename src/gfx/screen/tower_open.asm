; tower entrance (door open) -- drawn by DrawTowerOpenScreen (bank $30). Generated from the single editable image
; assets/tower_open/tower_entrance_open.png by tools/pngasset.py (screen mode, via assets.yaml): both
; VRAM banks stacked + the 16 CGB palettes embedded. The map descriptor references
; the maps by label (dw). See docs/gfx_assets.md.

SECTION "TowerOpenTiles bank0", ROMX[$4000], BANK[$26]
TowerOpenTilesBank0:
	INCBIN "assets/tower_open/tiles_bank0.bin"   ; 384 tiles -> VRAM bank 0 $8000

TowerOpenTilesBank1:
	INCBIN "assets/tower_open/tiles_bank1.bin"   ; 384 tiles -> VRAM bank 1 $8000

TowerOpenPalettes:
	INCBIN "assets/tower_open/palette.bin"       ; 8 BG + 8 OBJ palettes (RGB555 LE)

TowerOpenMapDesc:
	db 18, 20
	dw TowerOpenAttrMap
	dw TowerOpenIdxMap

TowerOpenIdxMap:
	INCBIN "assets/tower_open/tilemap.bin"

TowerOpenAttrMap:
	INCBIN "assets/tower_open/attrmap.bin"
