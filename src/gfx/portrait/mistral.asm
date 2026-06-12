; Mistral's encounter portrait (shown during her dialogue; she's the girl in the red
; hood, with her summoned monster Ferious -- "Ferious! Come!" -- drawn as the
; silhouette behind her). A two-VRAM-bank CGB portrait: the loader (Mistral_StartEncounter)
; copies these 384 tiles to VRAM bank 1 $8000 and the 128 bank-0 tiles to VRAM bank 0
; $9000; the attr map's bit 3 selects the tile bank per cell. Located by following
; Mistral's script far-calls (tools/find_portraits.py).
;
; Assembled from the editable source under assets/portrait/mistral/ by
; tools/pngasset.py (Makefile, output under build/assets/). The 6 BG + 6 OBJ
; palettes (loaded by Mistral_StartEncounter from $35:$6000/$6040) are carved here
; from the PNG's colour table.

SECTION "Mistral graphics", ROMX

MistralPortraitTilesBank0:
	INCBIN "assets/mistral/tiles2.bin"   ; 128 tiles -> VRAM bank 0 $9000

MistralPortraitTiles:
	INCBIN "assets/mistral/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

MistralPortraitPaletteBg:
	INCBIN "assets/mistral/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

Data_35_6030:
	DB $ff, $7f, $3e, $1b, $37, $01, $4b, $00
	DB $ff, $7f, $94, $52, $4a, $29, $00, $00

MistralPortraitPaletteObj:
	INCBIN "assets/mistral/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

Data_35_6070:
	DB $ff, $7f, $94, $52, $4a, $29, $00, $00
	DB $ff, $7f, $3e, $1b, $37, $01, $4b, $00

MistralPortraitMapDesc:
	db 11, 20                                      ; rows, cols
	dw MistralPortraitAttrMap                       ; CGB attribute map pointer
	dw MistralPortraitIndexMap                      ; tile index map pointer

MistralPortraitIndexMap:
	INCBIN "assets/mistral/tilemap.bin"  ; 20x11 tile indices

MistralPortraitAttrMap:
	INCBIN "assets/mistral/attrmap.bin"  ; 20x11 CGB BG attributes (bit 3 = VRAM bank)

SECTION "analyzed_0d623e", ROMX[$623e], BANK[$35]

	; Overlay region ($623e-$6536): Mistral's animated portrait -- a 3-frame body/face
	; animation (body_frame0/mistral_face0/hat0/left_tassels0/right_tassels0 .. frame2)
	; over VRAM $984b, plus her collar and the ferious_eye glow on the background monster
	; silhouette (Ferious himself is BG tilemap, not overlay). frame1's body patch mixes
	; tile banks. Layered PNG source in assets/portrait/mistral/sprites/
	; (see docs/portrait_overlays.md).
	INCLUDE "assets/mistral/sprites.asm"
