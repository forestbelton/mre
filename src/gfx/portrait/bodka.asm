; Bodka's portrait (the older man in Nada's dialogue; shown recurringly as he and
; Nada talk -- the separate $1e:$5bd9 2x2 descriptor is a mouth-animation overlay,
; not this image). Single-blob Kalum layout: 384 tiles -> VRAM bank 1 $8000 ($8800
; addressing), arranged by the CopyBgMap descriptor below. Located via
; tools/find_portraits.py.
;
; Assembled from assets/portrait/bodka/ by tools/pngasset.py (Makefile, output
; under build/assets/). The 6 BG + 6 OBJ palettes (loaded by Bodka_BuildStudioScene
; from $1e:$5800/$5840) are carved here from the PNG's colour table.
INCLUDE "util.inc"

SECTION "Bodka graphics", ROMX

ASSET BodkaPortraitTiles, "assets/bodka/tiles.bin" ; 384 tiles -> VRAM bank 1 $8000

BodkaPortraitPaletteBg:
	INCBIN "assets/bodka/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

DS $10

BodkaPortraitPaletteObj:
	INCBIN "assets/bodka/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

DS $10

BodkaPortraitMapDesc:
	db 11, 20                                    ; rows, cols
	dw BodkaPortraitAttrMap                       ; CGB attribute map pointer
	dw BodkaPortraitIndexMap                      ; tile index map pointer

BodkaPortraitIndexMap:
	INCBIN "assets/bodka/tilemap.bin"  ; 20x11 tile indices

BodkaPortraitAttrMap:
	INCBIN "assets/bodka/attrmap.bin"  ; 20x11 CGB BG attributes

Data_1e_5a3e:
	; Overlay region ($5a3e-$5b59): 3-frame talking-eye animation
	; (eyes_frame0/face_frame0 .. frame2) drawn over VRAM $98a6, the 16-sprite chest,
	; and a smile expression (eyes_smile/face_smile) -- the layered PNG source in
	; assets/portrait/bodka/sprites/ (see docs/portrait_overlays.md). eyes_frame2 is a
	; near-blank patch whose BG palette is image-irreducible (pinned via sprites.yaml).
	INCBIN "assets/bodka/sprites.bin"

	; $5b59: studio-scene BG palettes (6 x RGB555 LE), loaded by Bodka_BuildStudioScene.
	db $44, $18, $69, $20, $d6, $1d, $ed, $2c, $44, $18, $69, $20, $14, $3a, $ed, $2c
	db $44, $18, $69, $20, $5a, $6b, $ed, $2c, $44, $18, $44, $18, $44, $18, $44, $18
	db $44, $18, $44, $18, $44, $18, $44, $18, $44, $18, $44, $18, $44, $18, $44, $18

Data_1e_5b89:
	db $e0, $03, $e0, $03, $e0, $03, $e0, $03, $e0, $03, $e0, $03, $e0, $03, $e0, $03

Data_1e_5b99:
	db $e0, $03, $df, $3a, $6d, $45, $e5, $34, $00, $7c, $73, $52, $6d, $45, $e5, $34
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

Data_1e_5bd9:
	db $02, $02, $e3, $5b, $df, $5b, $68, $70, $69, $71, $0b, $08, $08, $08
