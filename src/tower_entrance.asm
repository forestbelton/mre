; The tower-entrance screen (18x20 full-screen background): a large door flanked
; by statues. Drawn by Func_30_43a4 (bank $30), reached via the ROM0 $34xx-$35xx
; screen-transition handlers. The door and statues are animated at runtime
; (different animation for entering the tower vs. game over) by sprites/tile
; updates layered over this static background.
;
; Two-VRAM-bank CGB image, same layout as nada_intro: $22:$4000 -> VRAM bank 0
; $8000 and $22:$5800 -> VRAM bank 1 $8000 (384 tiles each, $8800 addressing);
; the attr map's bit 3 selects the tile bank per cell. Descriptor at $22:$7080
; -> $9800. Grayscale source (palettes lib-dispatched, not yet located); tiles +
; tilemap round-trip byte-exact. See tools/gfxasset.py.

SECTION "TowerEntranceTilesBank0", ROMX[$4000], BANK[$22]
TowerEntranceTilesBank0:
	INCBIN "assets/tower_entrance/tiles2.bin"   ; 384 tiles -> VRAM bank 0 $8000

SECTION "TowerEntranceTiles", ROMX[$5800], BANK[$22]
TowerEntranceTiles:
	INCBIN "assets/tower_entrance/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

SECTION "TowerEntranceMapDesc", ROMX[$7080], BANK[$22]
TowerEntranceMapDesc:
	db 18, 20                                   ; rows, cols
	dw TowerEntranceAttrMap                      ; CGB attribute map pointer
	dw TowerEntranceIndexMap                     ; tile index map pointer

SECTION "TowerEntranceIndexMap", ROMX[$7086], BANK[$22]
TowerEntranceIndexMap:
	INCBIN "assets/tower_entrance/tilemap.bin"  ; 20x18 tile indices

SECTION "TowerEntranceAttrMap", ROMX[$71ee], BANK[$22]
TowerEntranceAttrMap:
	INCBIN "assets/tower_entrance/attrmap.bin"  ; 20x18 CGB BG attributes (bit 3 = VRAM bank)
