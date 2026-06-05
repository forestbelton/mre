; tower entrance (door closed) -- drawn by DrawTowerEntranceScreen (bank $30). Generated from the single editable image
; assets/tower_entrance/tower_entrance.png by tools/pngasset.py (screen mode, via assets.yaml): both
; VRAM banks stacked + the 16 CGB palettes embedded. The map descriptor references
; the maps by label (dw). See docs/gfx_assets.md.

SECTION "TowerEntranceTiles bank0", ROMX[$4000], BANK[$22]
TowerEntranceTilesBank0:
	INCBIN "assets/tower_entrance/tiles_bank0.bin"   ; 384 tiles -> VRAM bank 0 $8000

SECTION "TowerEntranceTiles bank1", ROMX[$5800], BANK[$22]
TowerEntranceTilesBank1:
	INCBIN "assets/tower_entrance/tiles_bank1.bin"   ; 384 tiles -> VRAM bank 1 $8000

SECTION "TowerEntrancePalettes", ROMX[$7000], BANK[$22]
TowerEntrancePalettes:
	INCBIN "assets/tower_entrance/palette.bin"       ; 8 BG + 8 OBJ palettes (RGB555 LE)

SECTION "TowerEntranceDescriptor", ROMX[$7080], BANK[$22]
TowerEntranceMapDesc:
	db 18, 20
	dw TowerEntranceAttrMap
	dw TowerEntranceIdxMap

SECTION "TowerEntranceIdxMap", ROMX[$7086], BANK[$22]
TowerEntranceIdxMap:
	INCBIN "assets/tower_entrance/tilemap.bin"

SECTION "TowerEntranceAttrMap", ROMX[$71ee], BANK[$22]
TowerEntranceAttrMap:
	INCBIN "assets/tower_entrance/attrmap.bin"
