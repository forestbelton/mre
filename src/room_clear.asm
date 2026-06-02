; The room-clear results screen (18x20 full-screen background): an ornate frame
; reading "STAGE CLEAR!" with SCORE and TIME labels, shown after completing a
; tower room. Drawn by Func_30_503b (bank $30), reached via the ROM0 $34xx-$35xx
; screen-transition handlers. The score/time values are overlaid at runtime.
;
; Two-VRAM-bank CGB image, same layout as nada_intro: $21:$4000 -> VRAM bank 0
; $8000 and $21:$5800 -> VRAM bank 1 $8000 (384 tiles each, $8800 addressing);
; the attr map's bit 3 selects the tile bank per cell. Descriptor at $21:$7080
; -> $9800. Grayscale source (palettes lib-dispatched, not yet located); tiles +
; tilemap round-trip byte-exact. See tools/gfxasset.py.

SECTION "RoomClearTilesBank0", ROMX[$4000], BANK[$21]
RoomClearTilesBank0:
	INCBIN "assets/room_clear/tiles2.bin"   ; 384 tiles -> VRAM bank 0 $8000

SECTION "RoomClearTiles", ROMX[$5800], BANK[$21]
RoomClearTiles:
	INCBIN "assets/room_clear/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

SECTION "RoomClearMapDesc", ROMX[$7080], BANK[$21]
RoomClearMapDesc:
	db 18, 20                                 ; rows, cols
	dw RoomClearAttrMap                        ; CGB attribute map pointer
	dw RoomClearIndexMap                       ; tile index map pointer

SECTION "RoomClearIndexMap", ROMX[$7086], BANK[$21]
RoomClearIndexMap:
	INCBIN "assets/room_clear/tilemap.bin"  ; 20x18 tile indices

SECTION "RoomClearAttrMap", ROMX[$71ee], BANK[$21]
RoomClearAttrMap:
	INCBIN "assets/room_clear/attrmap.bin"  ; 20x18 CGB BG attributes (bit 3 = VRAM bank)
