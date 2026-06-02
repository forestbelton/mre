; Nada's second pose (shown by Func_1f_4e65 -- Nada with a summoned monster). A
; two-VRAM-bank CGB image that shares its bank-0 sheet with nada_intro: bank 0 is
; nada_intro's $1c:$4000 (NadaIntroTilesBank0), and this asset owns only the bank-1
; sheet $1f:$6607 plus the descriptor/maps. attr bit 3 picks the bank per cell.
; Located via tools/find_portraits.py.
;
; Assembled from assets/nada_scene2/ by tools/gfxasset.py (Makefile, output under
; build/assets/); the editable bank-0 tiles live in assets/nada_intro/. Grayscale
; source -- palettes lib-dispatched, not located.

SECTION "NadaScene2Tiles", ROMX[$6607], BANK[$1f]
NadaScene2Tiles:
	INCBIN "assets/nada_scene2/tiles.bin"     ; 384 tiles -> VRAM bank 1 $8000

SECTION "NadaScene2MapDesc", ROMX[$7e07], BANK[$1f]
NadaScene2MapDesc:
	db 11, 20                                  ; rows, cols
	dw NadaScene2AttrMap                        ; CGB attribute map pointer
	dw NadaScene2IndexMap                       ; tile index map pointer

SECTION "NadaScene2IndexMap", ROMX[$7e0d], BANK[$1f]
NadaScene2IndexMap:
	INCBIN "assets/nada_scene2/tilemap.bin"   ; 20x11 tile indices

SECTION "NadaScene2AttrMap", ROMX[$7ee9], BANK[$1f]
NadaScene2AttrMap:
	INCBIN "assets/nada_scene2/attrmap.bin"   ; 20x11 CGB BG attributes (bit 3 = VRAM bank)
