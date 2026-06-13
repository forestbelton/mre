; Room-background mural tiles (ROM bank $38).
;
; LoadRoomMural pages a 1KB mural-tile page into VRAM $9400 -- the decoration
; tiles that show behind floor walls. The page is RoomMuralTiles + (wSpecialScene
; - 5) * $400. Loaded by room/special_scene.asm per scene.
; Carved out of analyzed.asm (byte-exact; section names unchanged).

INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "sound/id.inc"

SECTION "analyzed_0e0000", ROMX[$4000], BANK[$38]

; Copy the wSpecialScene-th 1KB mural tile page (pages start at index 5) into
; VRAM bank 0 $9400.
LoadRoomMural:
	xor a
	ld [rVBK], a
	ld bc, $0400
	ld hl, RoomMuralTiles
	ld a, [wSpecialScene]
	sub $05
	rlca
	rlca
	add a, h
	ld h, a
	ld de, $9400
	call VramCopy16
	ret

; The mural tiles are one editable grayscale sheet, assets/room/mural.png (the
; murals are recoloured per-floor from FloorBgPalettePtrs, so there is no single
; palette). tools/pngasset.py (mode: sprite, asset `mural`) compiles it to tiles.bin.
; The mural data proper is 11263 bytes ($401a..$6c18), one byte short of its 704th
; tile, so the sheet rounds up to 704 tiles ($2c00 = 11264 bytes) with a $00 pad
; byte. INCBINing the whole thing just claims the one trailing byte of bank padding
; (also $00) that already followed this section -- the ROM is byte-identical. That
; final $00 is live: LoadRoomMural copies it as the last byte of the last mural page
; ($681a, special scene $0f). See docs/gfx_loaders.md. (Was the analyzer-fragmented
; Data_38_* db/INCBIN blob.)
RoomMuralTiles:
	INCBIN "assets/room/mural/tiles.bin"
