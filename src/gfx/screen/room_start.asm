; room start (the vault door) -- drawn by DrawRoomStartScreen (bank $30). Generated from the single editable image
; assets/room_start/room_start.png by tools/pngasset.py (screen mode, via assets.yaml): both
; VRAM banks stacked + the 16 CGB palettes embedded. The map descriptor references
; the maps by label (dw). See docs/gfx_assets.md.

SECTION "RoomStartTiles bank0", ROMX[$4000], BANK[$23]
RoomStartTilesBank0:
	INCBIN "assets/room_start/tiles_bank0.bin"   ; 384 tiles -> VRAM bank 0 $8000

RoomStartTilesBank1:
	INCBIN "assets/room_start/tiles_bank1.bin"   ; 384 tiles -> VRAM bank 1 $8000

RoomStartPalettes:
	INCBIN "assets/room_start/palette.bin"       ; 8 BG + 8 OBJ palettes (RGB555 LE)

RoomStartMapDesc:
	db 18, 20
	dw RoomStartAttrMap
	dw RoomStartIdxMap

RoomStartIdxMap:
	INCBIN "assets/room_start/tilemap.bin"

RoomStartAttrMap:
	INCBIN "assets/room_start/attrmap.bin"
