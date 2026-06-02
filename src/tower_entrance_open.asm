; The tower-entrance screen with the door open (18x20 full-screen background): a
; door-open variant of tower_entrance (bank $22), flanked by statues. Drawn by
; Func_30_52c4 (bank $30), reached via the ROM0 $34xx-$35xx screen-transition
; handlers. Used for the open-door state of the entrance animation.
;
; Two-VRAM-bank CGB image, same layout as nada_intro: $26:$4000 -> VRAM bank 0
; $8000 and $26:$5800 -> VRAM bank 1 $8000 (384 tiles each, $8800 addressing);
; the attr map's bit 3 selects the tile bank per cell. Descriptor at $26:$7080
; -> $9800. Grayscale source (palettes lib-dispatched, not yet located); tiles +
; tilemap round-trip byte-exact. See tools/gfxasset.py.

SECTION "TowerEntranceOpenTilesBank0", ROMX[$4000], BANK[$26]
TowerEntranceOpenTilesBank0:
	INCBIN "assets/tower_entrance_open/tiles2.bin"   ; 384 tiles -> VRAM bank 0 $8000

SECTION "TowerEntranceOpenTiles", ROMX[$5800], BANK[$26]
TowerEntranceOpenTiles:
	INCBIN "assets/tower_entrance_open/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

SECTION "TowerEntranceOpenMapDesc", ROMX[$7080], BANK[$26]
TowerEntranceOpenMapDesc:
	db 18, 20                                        ; rows, cols
	dw TowerEntranceOpenAttrMap                       ; CGB attribute map pointer
	dw TowerEntranceOpenIndexMap                      ; tile index map pointer

SECTION "TowerEntranceOpenIndexMap", ROMX[$7086], BANK[$26]
TowerEntranceOpenIndexMap:
	INCBIN "assets/tower_entrance_open/tilemap.bin"  ; 20x18 tile indices

SECTION "TowerEntranceOpenAttrMap", ROMX[$71ee], BANK[$26]
TowerEntranceOpenAttrMap:
	INCBIN "assets/tower_entrance_open/attrmap.bin"  ; 20x18 CGB BG attributes (bit 3 = VRAM bank)
