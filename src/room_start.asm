; The room-start screen (18x20 full-screen background): a framed door shown when
; a new tower room begins. Drawn by Func_30_44aa (bank $30), reached via the
; ROM0 $34xx-$35xx screen-transition handlers. At runtime the game animates the
; central door opening and overlays the current room number, the room timer, and
; the player's remaining lives on top of this static background.
;
; Two-VRAM-bank CGB image, same layout as nada_intro: $23:$4000 -> VRAM bank 0
; $8000 and $23:$5800 -> VRAM bank 1 $8000 (384 tiles each, $8800 addressing);
; the attr map's bit 3 selects the tile bank per cell. Descriptor at $23:$7080
; -> $9800. Grayscale source (palettes lib-dispatched, not yet located); tiles +
; tilemap round-trip byte-exact. See tools/gfxasset.py.

SECTION "RoomStartTilesBank0", ROMX[$4000], BANK[$23]
RoomStartTilesBank0:
	INCBIN "assets/room_start/tiles2.bin"   ; 384 tiles -> VRAM bank 0 $8000

SECTION "RoomStartTiles", ROMX[$5800], BANK[$23]
RoomStartTiles:
	INCBIN "assets/room_start/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

SECTION "RoomStartMapDesc", ROMX[$7080], BANK[$23]
RoomStartMapDesc:
	db 18, 20                                 ; rows, cols
	dw RoomStartAttrMap                        ; CGB attribute map pointer
	dw RoomStartIndexMap                       ; tile index map pointer

SECTION "RoomStartIndexMap", ROMX[$7086], BANK[$23]
RoomStartIndexMap:
	INCBIN "assets/room_start/tilemap.bin"  ; 20x18 tile indices

SECTION "RoomStartAttrMap", ROMX[$71ee], BANK[$23]
RoomStartAttrMap:
	INCBIN "assets/room_start/attrmap.bin"  ; 20x18 CGB BG attributes (bit 3 = VRAM bank)
