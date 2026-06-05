; Bodka's portrait (the older man in Nada's dialogue; shown recurringly as he and
; Nada talk -- the separate $1e:$5bd9 2x2 descriptor is a mouth-animation overlay,
; not this image). Single-blob Kalum layout: 384 tiles -> VRAM bank 1 $8000 ($8800
; addressing), arranged by the CopyBgMap descriptor below. Located via
; tools/find_portraits.py.
;
; Assembled from assets/bodka/ by tools/gfxasset.py (Makefile, output
; under build/assets/). Grayscale source -- palettes lib-dispatched, not located.

SECTION "BodkaPortraitTiles", ROMX[$4000], BANK[$1e]
BodkaPortraitTiles:
	INCBIN "assets/bodka/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

SECTION "BodkaPortraitMapDesc", ROMX[$5880], BANK[$1e]
BodkaPortraitMapDesc:
	db 11, 20                                    ; rows, cols
	dw BodkaPortraitAttrMap                       ; CGB attribute map pointer
	dw BodkaPortraitIndexMap                      ; tile index map pointer

SECTION "BodkaPortraitIndexMap", ROMX[$5886], BANK[$1e]
BodkaPortraitIndexMap:
	INCBIN "assets/bodka/tilemap.bin"  ; 20x11 tile indices

SECTION "BodkaPortraitAttrMap", ROMX[$5962], BANK[$1e]
BodkaPortraitAttrMap:
	INCBIN "assets/bodka/attrmap.bin"  ; 20x11 CGB BG attributes
