; "STAGE CLEAR!" results -- drawn by DrawRoomClearScreen (bank $30). Generated from the single editable image
; assets/room_clear/room_clear.png by tools/pngasset.py (screen mode, via assets.yaml): both
; VRAM banks stacked + the 16 CGB palettes embedded. The map descriptor references
; the maps by label (dw). See docs/gfx_assets.md.

SECTION "RoomClearTiles bank0", ROMX[$4000], BANK[$21]
RoomClearTilesBank0:
	INCBIN "assets/room_clear/tiles_bank0.bin"   ; 384 tiles -> VRAM bank 0 $8000

SECTION "RoomClearTiles bank1", ROMX[$5800], BANK[$21]
RoomClearTilesBank1:
	INCBIN "assets/room_clear/tiles_bank1.bin"   ; 384 tiles -> VRAM bank 1 $8000

SECTION "RoomClearPalettes", ROMX[$7000], BANK[$21]
RoomClearPalettes:
	INCBIN "assets/room_clear/palette.bin"       ; 8 BG + 8 OBJ palettes (RGB555 LE)

SECTION "RoomClearDescriptor", ROMX[$7080], BANK[$21]
RoomClearMapDesc:
	db 18, 20
	dw RoomClearAttrMap
	dw RoomClearIdxMap

SECTION "RoomClearIdxMap", ROMX[$7086], BANK[$21]
RoomClearIdxMap:
	INCBIN "assets/room_clear/tilemap.bin"

SECTION "RoomClearAttrMap", ROMX[$71ee], BANK[$21]
RoomClearAttrMap:
	INCBIN "assets/room_clear/attrmap.bin"
