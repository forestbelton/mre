; Nada's recurring talking portrait (shown repeatedly through her dialogue; the
; separate $1e:$5bd9 2x2 descriptor is a mouth-animation overlay, not this image).
; Single-blob Kalum layout: 384 tiles -> VRAM bank 1 $8000 ($8800 addressing),
; arranged by the CopyBgMap descriptor below. Located via tools/find_portraits.py.
;
; Assembled from assets/nada_portrait/ by tools/gfxasset.py (Makefile, output
; under build/assets/). Grayscale source -- palettes lib-dispatched, not located.

SECTION "NadaPortraitTiles", ROMX[$4000], BANK[$1e]
NadaPortraitTiles:
	INCBIN "assets/nada_portrait/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

SECTION "NadaPortraitMapDesc", ROMX[$5880], BANK[$1e]
NadaPortraitMapDesc:
	db 11, 20                                   ; rows, cols
	dw NadaPortraitAttrMap                       ; CGB attribute map pointer
	dw NadaPortraitIndexMap                      ; tile index map pointer

SECTION "NadaPortraitIndexMap", ROMX[$5886], BANK[$1e]
NadaPortraitIndexMap:
	INCBIN "assets/nada_portrait/tilemap.bin"  ; 20x11 tile indices

SECTION "NadaPortraitAttrMap", ROMX[$5962], BANK[$1e]
NadaPortraitAttrMap:
	INCBIN "assets/nada_portrait/attrmap.bin"  ; 20x11 CGB BG attributes
