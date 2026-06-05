; Nada's scene graphics -- two full-screen (11x20) two-VRAM-bank CGB images.
; Both load their tile sheets to VRAM $8000 in different banks (the attr map's
; bit 3 selects the bank per cell). The two scenes share their bank-0 sheet
; (NadaIntroTilesBank0), so they are kept together here. Located via
; tools/find_portraits.py.
;
; Assembled from the editable sources under assets/portrait/nada_intro/ and
; assets/portrait/nada_scene2/ by tools/pngasset.py (Makefile, output under
; build/assets/). The 6 BG + 6 OBJ palettes (loaded by Nada_ShowScene from
; $1c:$7000/$7040) are carved into the intro scene below; the second pose reuses
; them, so its PNG is colourised but owns no palette bytes.

; --- Intro scene (shown by Func_1f_4d97 early in her script) ---------------
; Bank 0 sheet $1c:$4000, bank 1 sheet $1c:$5800.

SECTION "NadaIntroTilesBank0", ROMX[$4000], BANK[$1c]
NadaIntroTilesBank0:
	INCBIN "assets/nada_intro/tiles2.bin"   ; 384 tiles -> VRAM bank 0 $8000

SECTION "NadaIntroTiles", ROMX[$5800], BANK[$1c]
NadaIntroTiles:
	INCBIN "assets/nada_intro/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

SECTION "NadaIntroPaletteBg", ROMX[$7000], BANK[$1c]
NadaIntroPaletteBg:
	INCBIN "assets/nada_intro/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

SECTION "NadaIntroPaletteObj", ROMX[$7040], BANK[$1c]
NadaIntroPaletteObj:
	INCBIN "assets/nada_intro/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

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
