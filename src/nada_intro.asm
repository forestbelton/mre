; Nada's intro scene (shown by Func_1f_4d97 early in her script). A two-VRAM-bank
; CGB image where -- unlike Ferious -- both tile sheets load to VRAM $8000 in
; different banks: $1c:$4000 (bank 0) and $1c:$5800 (bank 1); the attr map's bit 3
; selects the bank per cell. Located via tools/find_portraits.py.
;
; Assembled from the editable source under assets/nada_intro/ by tools/gfxasset.py
; (Makefile, output under build/assets/). Grayscale source -- palettes are
; lib-dispatched and not yet located; tiles + tilemap round-trip here.

SECTION "NadaIntroTilesBank0", ROMX[$4000], BANK[$1c]
NadaIntroTilesBank0:
	INCBIN "assets/nada_intro/tiles2.bin"   ; 384 tiles -> VRAM bank 0 $8000

SECTION "NadaIntroTiles", ROMX[$5800], BANK[$1c]
NadaIntroTiles:
	INCBIN "assets/nada_intro/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

SECTION "NadaIntroMapDesc", ROMX[$7080], BANK[$1c]
NadaIntroMapDesc:
	db 11, 20                                ; rows, cols
	dw NadaIntroAttrMap                       ; CGB attribute map pointer
	dw NadaIntroIndexMap                      ; tile index map pointer

SECTION "NadaIntroIndexMap", ROMX[$7086], BANK[$1c]
NadaIntroIndexMap:
	INCBIN "assets/nada_intro/tilemap.bin"  ; 20x11 tile indices

SECTION "NadaIntroAttrMap", ROMX[$7162], BANK[$1c]
NadaIntroAttrMap:
	INCBIN "assets/nada_intro/attrmap.bin"  ; 20x11 CGB BG attributes (bit 3 = VRAM bank)
