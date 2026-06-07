; Toamuna's portrait (ranch save NPC, mother of Naji). Shown by her "what do you
; want to do?" menu; located by following her script's far-calls
; (tools/find_portraits.py). Same descriptor layout as Kalum's portrait: the 384
; tiles are copied to VRAM bank 1 $8000 ($8800 signed addressing) and arranged by
; the CopyBgMap descriptor below over the top 20x11 cells.
;
; Assembled from the editable source under assets/portrait/toamuna/ by
; tools/pngasset.py (run in the Makefile, output under build/assets/). The
; descriptor references the two maps by *label* (dw), so the region is internally
; relocatable. The 6 BG + 6 OBJ palettes (loaded by Toamuna_CheckSaveExists from
; $1a:$5800/$5840) are carved here from the PNG's colour table.

SECTION "Toamuna graphics", ROMX

ToamunaPortraitTiles:
	INCBIN "assets/toamuna/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

ToamunaPortraitPaletteBg:
	INCBIN "assets/toamuna/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

DS $10

ToamunaPortraitPaletteObj:
	INCBIN "assets/toamuna/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

DS $10

ToamunaPortraitMapDesc:
	db 11, 20                                      ; rows, cols
	dw ToamunaPortraitAttrMap                       ; CGB attribute map pointer
	dw ToamunaPortraitIndexMap                      ; tile index map pointer

ToamunaPortraitIndexMap:
	INCBIN "assets/toamuna/tilemap.bin"  ; 20x11 tile indices

ToamunaPortraitAttrMap:
	INCBIN "assets/toamuna/attrmap.bin"  ; 20x11 CGB BG attributes

Data_1a_5a3e:
	db $03, $03, $4d, $5a, $44, $5a, $a6, $ae, $b6, $a7, $af, $b7, $40, $48, $50, $08
	db $08, $08, $08, $08, $08, $08, $08, $08, $0f, $00, $00, $00, $08, $00, $08, $02
	db $08, $00, $10, $04, $08, $00, $18, $06, $08, $00, $20, $08, $08, $10, $00, $0a
	db $08, $10, $08, $0c, $08, $10, $10, $0e, $08, $10, $18, $10, $08, $10, $20, $12
	db $08, $20, $00, $14, $08, $20, $08, $16, $08, $20, $10, $08, $08, $20, $18, $08
	db $08, $20, $20, $18, $08, $03, $03, $a2, $5a, $99, $5a, $56, $5e, $60, $57, $5f
	db $61, $63, $64, $62, $08, $08, $08, $08, $08, $08, $08, $08, $08, $0f, $00, $00
	db $00, $08, $00, $08, $02, $08, $00, $10, $04, $08, $00, $18, $06, $08, $00, $20
	db $08, $08, $10, $00, $1a, $08, $10, $08, $1c, $08, $10, $10, $1e, $08, $10, $18
	db $10, $08, $10, $20, $12, $08, $20, $00, $14, $08, $20, $08, $16, $08, $20, $10
	db $08, $08, $20, $18, $08, $08, $20, $20, $18, $08
