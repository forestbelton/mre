; Ferious, the monster Mistral summons ("Ferious! Come!"). A two-VRAM-bank CGB
; portrait: the loader (Func_1f_4416) copies these 384 tiles to VRAM bank 1 $8000
; and the 128 bank-0 tiles to VRAM bank 0 $9000; the attr map's bit 3 selects the
; tile bank per cell. Located by following Mistral's script far-calls
; (tools/find_portraits.py).
;
; Assembled from the editable source under assets/ferious_portrait/ by
; tools/gfxasset.py (Makefile, output under build/assets/). Grayscale source --
; palettes are lib-dispatched and not yet located; tiles + tilemap round-trip here.

SECTION "FeriousPortraitTilesBank0", ROMX[$4000], BANK[$35]
FeriousPortraitTilesBank0:
	INCBIN "assets/ferious_portrait/tiles2.bin"   ; 128 tiles -> VRAM bank 0 $9000

SECTION "FeriousPortraitTiles", ROMX[$4800], BANK[$35]
FeriousPortraitTiles:
	INCBIN "assets/ferious_portrait/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

SECTION "FeriousPortraitMapDesc", ROMX[$6080], BANK[$35]
FeriousPortraitMapDesc:
	db 11, 20                                      ; rows, cols
	dw FeriousPortraitAttrMap                       ; CGB attribute map pointer
	dw FeriousPortraitIndexMap                      ; tile index map pointer

SECTION "FeriousPortraitIndexMap", ROMX[$6086], BANK[$35]
FeriousPortraitIndexMap:
	INCBIN "assets/ferious_portrait/tilemap.bin"  ; 20x11 tile indices

SECTION "FeriousPortraitAttrMap", ROMX[$6162], BANK[$35]
FeriousPortraitAttrMap:
	INCBIN "assets/ferious_portrait/attrmap.bin"  ; 20x11 CGB BG attributes (bit 3 = VRAM bank)
