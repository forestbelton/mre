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

SECTION "analyzed_087356", ROMX[$7356], BANK[$21]

Data_21_7356:
	db $02, $0c, $74, $73, $5c, $73, $32, $3a, $42, $4a, $52, $5a, $62, $6a, $72, $7a
	db $74, $7c, $33, $3b, $43, $4b, $53, $5b, $63, $6b, $73, $7b, $75, $7d, $08, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $00, $00, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08, $00, $00, $04, $03, $9e, $73, $92, $73, $04, $0c, $14, $05
	db $0d, $15, $1c, $24, $2c, $1d, $25, $2d, $08, $08, $08, $08, $08, $08, $08, $08
	db $08, $08, $08, $08

Data_21_73aa:
	db $8c, $73

Func_21_73ac:
	call WaitForHBlank
	ld hl, wScore
	ld de, $98cd
	ld a, [hl]
	call Func_00_3635
	ld a, [hl+]
	swap a
	call Func_00_3635
	ld a, [hl]
	call Func_00_3635
	call WaitForHBlank
	ld a, [hl+]
	swap a
	call Func_00_3635
	ld a, [hl]
	call Func_00_3635
	ld a, [hl+]
	swap a
	call Func_00_3635
	call WaitForHBlank
	ld a, [hl]
	call Func_00_3635
	ld a, [hl]
	swap a
	call Func_00_3635
	ret
Func_21_73e4:
	call WaitForHBlank
	ld hl, wFloorTimer
	ld de, $992c
	ld a, [hl]
	call Func_00_3635
	ld a, [hl+]
	swap a
	call Func_00_3635
	call WaitForHBlank
	ld a, [hl]
	call Func_00_3635
	ld a, [hl+]
	swap a
	call Func_00_3635
	ld a, [hl]
	call Func_00_3635
	ret
Func_21_7409:
	call WaitForHBlank
	ld de, $9927
	ld a, $00
	call Func_00_3635
	ret

; ($22:$7000 BG/OBJ palettes carved into the screen asset as TowerEntrancePalettes.)

