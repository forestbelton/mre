; The town screen (18x20 full-screen background). Drawn by Func_30_401e (bank
; $30), reached via the ROM0 $34xx-$35xx screen-transition handlers. The game
; overlays sprites on this static background at runtime.
;
; Two-VRAM-bank CGB image, same layout as nada_intro: $20:$4000 -> VRAM bank 0
; $8000 and $20:$5800 -> VRAM bank 1 $8000 (384 tiles each, $8800 addressing);
; the attr map's bit 3 selects the tile bank per cell. Descriptor at $20:$7080
; -> $9800.
;
; Assembled from the editable source under assets/town_screen/ by
; tools/gfxasset.py (Makefile, output under build/assets/). Grayscale source --
; palettes are lib-dispatched and not yet located; tiles + tilemap round-trip
; byte-exact (verified by `gfxasset.py verify`).

SECTION "TownScreenTilesBank0", ROMX[$4000], BANK[$20]
TownScreenTilesBank0:
	INCBIN "assets/town_screen/tiles2.bin"   ; 384 tiles -> VRAM bank 0 $8000

SECTION "TownScreenTiles", ROMX[$5800], BANK[$20]
TownScreenTiles:
	INCBIN "assets/town_screen/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

SECTION "TownScreenMapDesc", ROMX[$7080], BANK[$20]
TownScreenMapDesc:
	db 18, 20                                 ; rows, cols
	dw TownScreenAttrMap                       ; CGB attribute map pointer
	dw TownScreenIndexMap                      ; tile index map pointer

SECTION "TownScreenIndexMap", ROMX[$7086], BANK[$20]
TownScreenIndexMap:
	INCBIN "assets/town_screen/tilemap.bin"  ; 20x18 tile indices

SECTION "TownScreenAttrMap", ROMX[$71ee], BANK[$20]
TownScreenAttrMap:
	INCBIN "assets/town_screen/attrmap.bin"  ; 20x18 CGB BG attributes (bit 3 = VRAM bank)
