; Nada's scene graphics -- two full-screen (11x20) two-VRAM-bank CGB images.
; Both load their tile sheets to VRAM $8000 in different banks (the attr map's
; bit 3 selects the bank per cell). The two scenes share their bank-0 sheet
; (NadaIntroTilesBank0), so they are kept together here. Located via
; tools/find_portraits.py.
;
; Assembled from the editable sources under assets/nada_intro/ and
; assets/nada_scene2/ by tools/gfxasset.py (Makefile, output under
; build/assets/). Grayscale sources -- palettes are lib-dispatched and not yet
; located; tiles + tilemap round-trip here.

; --- Intro scene (shown by Func_1f_4d97 early in her script) ---------------
; Bank 0 sheet $1c:$4000, bank 1 sheet $1c:$5800.

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

; --- Second pose (shown by Func_1f_4e65 -- Nada with a summoned monster) -----
; Shares the bank-0 sheet above (NadaIntroTilesBank0); owns only the bank-1
; sheet $1f:$6607 plus its descriptor/maps. Editable bank-0 tiles live in
; assets/nada_intro/.

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
