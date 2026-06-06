; "STAGE CLEAR!" results -- drawn by DrawRoomClearScreen (bank $30). Generated from the single editable image
; assets/room_done/room_clear.png by tools/pngasset.py (screen mode, via assets.yaml): both
; VRAM banks stacked + the 16 CGB palettes embedded. The map descriptor references
; the maps by label (dw). See docs/gfx_assets.md.

SECTION "RoomClearTiles bank0", ROMX[$4000], BANK[$21]
RoomClearTilesBank0:
	INCBIN "assets/room_done/tiles_bank0.bin"   ; 384 tiles -> VRAM bank 0 $8000

RoomClearTilesBank1:
	INCBIN "assets/room_done/tiles_bank1.bin"   ; 384 tiles -> VRAM bank 1 $8000

RoomClearPalettes:
	INCBIN "assets/room_done/palette.bin"       ; 8 BG + 8 OBJ palettes (RGB555 LE)

RoomClearMapDesc:
	db 18, 20
	dw RoomClearAttrMap
	dw RoomClearIdxMap

RoomClearIdxMap:
	INCBIN "assets/room_done/tilemap.bin"

RoomClearAttrMap:
	INCBIN "assets/room_done/attrmap.bin"
