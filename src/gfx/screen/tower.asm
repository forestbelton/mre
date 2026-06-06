; tower entrance (door closed) -- drawn by DrawTowerEntranceScreen (bank $30). Generated from the single editable image
; assets/tower/tower_entrance.png by tools/pngasset.py (screen mode, via assets.yaml): both
; VRAM banks stacked + the 16 CGB palettes embedded. The map descriptor references
; the maps by label (dw). See docs/gfx_assets.md.

SECTION "TowerEntranceTiles bank0", ROMX[$4000], BANK[$22]
TowerEntranceTilesBank0:
	INCBIN "assets/tower/tiles_bank0.bin"   ; 384 tiles -> VRAM bank 0 $8000

TowerEntranceTilesBank1:
	INCBIN "assets/tower/tiles_bank1.bin"   ; 384 tiles -> VRAM bank 1 $8000

TowerEntrancePalettes:
	INCBIN "assets/tower/palette.bin"       ; 8 BG + 8 OBJ palettes (RGB555 LE)

TowerEntranceMapDesc:
	db 18, 20
	dw TowerEntranceAttrMap
	dw TowerEntranceIdxMap

TowerEntranceIdxMap:
	INCBIN "assets/tower/tilemap.bin"

TowerEntranceAttrMap:
	INCBIN "assets/tower/attrmap.bin"
