; Ferious, the monster Mistral summons ("Ferious! Come!"). A two-VRAM-bank CGB
; portrait: the loader (Func_1f_4416) copies these 384 tiles to VRAM bank 1 $8000
; and the 128 bank-0 tiles to VRAM bank 0 $9000; the attr map's bit 3 selects the
; tile bank per cell. Located by following Mistral's script far-calls
; (tools/find_portraits.py).
;
; Assembled from the editable source under assets/portrait/ferious/ by
; tools/pngasset.py (Makefile, output under build/assets/). The 6 BG + 6 OBJ
; palettes (loaded by Mistral_StartEncounter from $35:$6000/$6040) are carved here
; from the PNG's colour table.

SECTION "Mistral graphics", ROMX

FeriousPortraitTilesBank0:
	INCBIN "assets/ferious/tiles2.bin"   ; 128 tiles -> VRAM bank 0 $9000

FeriousPortraitTiles:
	INCBIN "assets/ferious/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

FeriousPortraitPaletteBg:
	INCBIN "assets/ferious/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

Data_35_6030:
	DB $ff, $7f, $3e, $1b, $37, $01, $4b, $00
	DB $ff, $7f, $94, $52, $4a, $29, $00, $00

FeriousPortraitPaletteObj:
	INCBIN "assets/ferious/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

Data_35_6070:
	DB $ff, $7f, $94, $52, $4a, $29, $00, $00
	DB $ff, $7f, $3e, $1b, $37, $01, $4b, $00

FeriousPortraitMapDesc:
	db 11, 20                                      ; rows, cols
	dw FeriousPortraitAttrMap                       ; CGB attribute map pointer
	dw FeriousPortraitIndexMap                      ; tile index map pointer

FeriousPortraitIndexMap:
	INCBIN "assets/ferious/tilemap.bin"  ; 20x11 tile indices

FeriousPortraitAttrMap:
	INCBIN "assets/ferious/attrmap.bin"  ; 20x11 CGB BG attributes (bit 3 = VRAM bank)
