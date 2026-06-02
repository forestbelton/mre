; The title screen (18x20 full-screen background): the "Monster Rancher EXPLORER"
; logo with the (C)TECMO,LTD.2000 / LICENSED BY NINTENDO notices. Drawn by
; Func_30_54df (bank $30), reached via the ROM0 $34xx-$35xx screen-transition
; handlers. (The same routine also blits a $7356 sub-descriptor overlay -- the
; press-start / menu prompt -- which stays in analyzed.asm for now.)
;
; Two-VRAM-bank CGB image, same layout as nada_intro: $28:$4000 -> VRAM bank 0
; $8000 and $28:$5800 -> VRAM bank 1 $8000 (384 tiles each, $8800 addressing);
; the attr map's bit 3 selects the tile bank per cell. Descriptor at $28:$7080
; -> $9800. Grayscale source (palettes lib-dispatched, not yet located); tiles +
; tilemap round-trip byte-exact. See tools/gfxasset.py.

SECTION "TitleScreenTilesBank0", ROMX[$4000], BANK[$28]
TitleScreenTilesBank0:
	INCBIN "assets/title_screen/tiles2.bin"   ; 384 tiles -> VRAM bank 0 $8000

SECTION "TitleScreenTiles", ROMX[$5800], BANK[$28]
TitleScreenTiles:
	INCBIN "assets/title_screen/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

SECTION "TitleScreenMapDesc", ROMX[$7080], BANK[$28]
TitleScreenMapDesc:
	db 18, 20                                  ; rows, cols
	dw TitleScreenAttrMap                       ; CGB attribute map pointer
	dw TitleScreenIndexMap                      ; tile index map pointer

SECTION "TitleScreenIndexMap", ROMX[$7086], BANK[$28]
TitleScreenIndexMap:
	INCBIN "assets/title_screen/tilemap.bin"  ; 20x18 tile indices

SECTION "TitleScreenAttrMap", ROMX[$71ee], BANK[$28]
TitleScreenAttrMap:
	INCBIN "assets/title_screen/attrmap.bin"  ; 20x18 CGB BG attributes (bit 3 = VRAM bank)
