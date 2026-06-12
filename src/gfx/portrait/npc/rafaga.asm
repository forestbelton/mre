; Rafaga's encounter portrait (shown during Rafaga's encounter ("Time to fight.")); located by following the
; script's far-calls (tools/find_portraits.py). Same 20x11 single-blob layout as
; Kalum: 384 tiles -> VRAM bank 1 $8000 ($8800 signed addressing), arranged by the
; CopyBgMap descriptor below. Assembled from assets/portrait/rafaga/ via
; tools/pngasset.py (Makefile, output under build/assets/). The 6 BG + 6 OBJ
; palettes (loaded by Rafaga_StartEncounter from $1d:$7319/$7359) are carved here
; from the PNG's colour table.

SECTION "Rafaga graphics", ROMX

RafagaPortraitTiles:
	INCBIN "assets/portrait/npc/rafaga/tiles.bin"

RafagaPortraitPaletteBg:
	INCBIN "assets/portrait/npc/rafaga/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

DS $10

RafagaPortraitPaletteObj:
	INCBIN "assets/portrait/npc/rafaga/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

DS $10

RafagaPortraitMapDesc:
	db 11, 20
	dw RafagaPortraitAttrMap
	dw RafagaPortraitIndexMap

RafagaPortraitIndexMap:
	INCBIN "assets/portrait/npc/rafaga/tilemap.bin"

RafagaPortraitAttrMap:
	INCBIN "assets/portrait/npc/rafaga/attrmap.bin"

	; Overlay region: two-frame eyes/blink animation (eyes_frame0/blink_frame0 ->
	; eyes_frame1/blink_frame1) drawn over VRAM $98ad, plus three static overlay
	; metasprites (collar, shoulder, punisher_eyes). Layered PNG source in
	; assets/portrait/rafaga/sprites/ (see docs/portrait_overlays.md).
	INCLUDE "assets/portrait/npc/rafaga/sprites.asm"
