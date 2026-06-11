; Room screen graphics (room-type variant) (ROM bank $25).
;
; Two 384-tile sets selected by wRoomType, both copied to VRAM $8000 by the loader
; (Func_30_48c9 in screens.asm): tileset A ($4000, room types != 1) with tilemap
; RoomScreenTilemap ($7100) + palette set A ($7000); tileset B ($5800, room type 1)
; with RoomScreenTilemapAlt ($71f8) + palette set B ($7080). Both tilemaps are 11x11
; CopyBgMap descriptors copied to $9909.
;
; Editable source: assets/screen/room_screen/tiles.png stacks both tilesets (768 tiles)
; with all 32 palettes embedded; tools/pngasset.py (mode: scene) splits it into
; tiles_bank0/1.2bpp + palette.bin. The two tilemap descriptors stay structured here.
;
; NOTE: Pashute's shocked-portrait renderer (Pashute_RenderPortraitShocked) reads
; metasprite/patch data from raw addresses $25:$5afb..$5bd8 -- i.e. bytes inside
; tileset B's region are reused as OBJ data in that other screen. Those raw refs stay
; byte-exact; editing tileset B's pixels there would also change that overlay.

SECTION "Room screen graphics", ROMX[$4000], BANK[$25]

Data_25_4000:
	INCBIN "assets/room_screen/tiles_bank0.2bpp"   ; tileset A (room types != 1)
Data_25_4000End:

Data_25_5800:
	INCBIN "assets/room_screen/tiles_bank1.2bpp"   ; tileset B (room type 1)
Data_25_5800End:                                    ; = $7000

RoomScreenPalettes:                                 ; $7000: set A (8 BG + 8 OBJ),
	INCBIN "assets/room_screen/palette.bin"         ; then set B at $7080 (256 bytes)

RoomScreenTilemap:                              ; CopyBgMap 11x11 -> $9909 (room types != 1)
	db 11, 11
	dw .attr
	dw .idx
.idx:
	db $80, $8a, $94, $9d, $a6, $af, $b8, $c1, $ca, $d3, $dc, $81, $8b, $95, $9e, $a7
	db $b0, $b9, $c2, $cb, $d4, $ee, $82, $8c, $96, $9f, $a8, $b1, $ba, $c3, $cc, $ee
	db $f3, $83, $8d, $97, $a0, $a9, $b2, $bb, $8d, $ee, $fc, $de, $84, $8e, $98, $a1
	db $aa, $aa, $a1, $ee, $fd, $d6, $df, $85, $8f, $99, $da, $a9, $b2, $ee, $fe, $ce
	db $d7, $e0, $f8, $ef, $f5, $f6, $f7, $f5, $ff, $c6, $cf, $d8, $e1, $86, $ee, $fa
	db $f9, $ab, $b4, $be, $c7, $d0, $d9, $e2, $87, $f4, $ee, $da, $ac, $b5, $bf, $c8
	db $d1, $da, $e3, $88, $92, $fb, $ee, $ad, $ad, $db, $8d, $d2, $db, $e4, $89, $93
	db $9c, $f9, $ee, $b7, $d9, $c7, $d0, $d9, $e5
.attr:
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $0b, $0b, $0c, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0c
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0c, $0b, $0b, $0b, $0b, $0b, $0b
	db $0b, $2b, $0b, $0c, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0c, $0b, $0b
	db $0b, $0b, $0c, $0c, $0c, $0c, $0c, $0c, $0b, $0b, $0b, $0b, $0b, $0b, $2c, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $0b, $2c, $0b, $0b, $0b, $0b, $0b
	db $0b, $0b, $0b, $0b, $0b, $0b, $2c, $0b, $2b, $2b, $0b, $0b, $0b, $0b, $0b, $0b
	db $0b, $0b, $2c, $0b, $0b, $0b, $0b, $0b, $0b

RoomScreenTilemapAlt:                           ; CopyBgMap 11x11 -> $9909 (room type 1)
	db 11, 11
	dw .attr
	dw .idx
.idx:
	db $9f, $99, $93, $8d, $88, $83, $80, $a6, $a5, $a6, $d1, $a0, $9a, $94, $8e, $89
	db $84, $81, $a6, $a6, $d2, $b1, $a1, $9b, $95, $8f, $8a, $85, $82, $a6, $d3, $b8
	db $b2, $a2, $9c, $96, $90, $8b, $86, $a6, $d4, $be, $b9, $b3, $a3, $9d, $97, $91
	db $8c, $87, $d5, $c3, $bf, $ba, $b4, $a4, $9e, $98, $92, $a6, $d6, $c7, $c4, $c0
	db $bb, $b5, $a6, $a6, $a6, $a6, $d7, $ca, $c8, $c5, $c1, $bc, $b6, $d0, $cf, $ce
	db $cd, $cc, $c9, $c9, $c6, $c2, $bd, $b7, $b4, $d0, $be, $d7, $a6, $a6, $a6, $a6
	db $a6, $a6, $a6, $b5, $bb, $d0, $be, $d6, $a6, $af, $ad, $ab, $a9, $a7, $b6, $bc
	db $c6, $d0, $be, $d5, $b0, $ae, $ac, $aa, $a8
.attr:
	db $2c, $2c, $2c, $2c, $2c, $2c, $2c, $2c, $2c, $2c, $2d, $2c, $2c, $2c, $2c, $2c
	db $2c, $2c, $2c, $2c, $2d, $2b, $2c, $2c, $2c, $2c, $2c, $2c, $2c, $2c, $2d, $2b
	db $2b, $2c, $2c, $2c, $2c, $2c, $2c, $2c, $2d, $2b, $2b, $2b, $2c, $2c, $2c, $2c
	db $2c, $2c, $2d, $2b, $2b, $2b, $2b, $2c, $2c, $2c, $2c, $2c, $2d, $2b, $2b, $2b
	db $2b, $2b, $2c, $2c, $2c, $2c, $2d, $2b, $2b, $2b, $2b, $2b, $2b, $2b, $2b, $2b
	db $2b, $2b, $2b, $2b, $2b, $2b, $2b, $2b, $0b, $2b, $0b, $0d, $2c, $2c, $2c, $2c
	db $2c, $2c, $2c, $0b, $0b, $2b, $0b, $0d, $2c, $2c, $2c, $2c, $2c, $2c, $0b, $0b
	db $0b, $2b, $0b, $0d, $2c, $2c, $2c, $2c, $2c

	ds $7fff - @, $00                               ; $72f0-$7ffe padding ($7fff = bank tag)
