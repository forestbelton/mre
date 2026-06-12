; Tempest's encounter portrait (shown during Tempest's encounter ("help me again.")); located by following the
; script's far-calls (tools/find_portraits.py). Same 20x11 single-blob layout as
; Kalum: 384 tiles -> VRAM bank 1 $8000 ($8800 signed addressing), arranged by the
; CopyBgMap descriptor below. Assembled from assets/portrait/tempest/ via
; tools/pngasset.py (Makefile, output under build/assets/). The 6 BG + 6 OBJ
; palettes (loaded by Tempest_StartEncounter from $1e:$73e7/$7427) are carved here
; from the PNG's colour table.

SECTION "Tempest graphics", ROMX

TempestPortraitTiles:
	INCBIN "assets/portrait/npc/tempest/tiles.bin"

TempestPortraitPaletteBg:
	INCBIN "assets/portrait/npc/tempest/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

DS $10

TempestPortraitPaletteObj:
	INCBIN "assets/portrait/npc/tempest/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

DS $10

TempestPortraitMapDesc:
	db 11, 20
	dw TempestPortraitAttrMap
	dw TempestPortraitIndexMap

TempestPortraitIndexMap:
	INCBIN "assets/portrait/npc/tempest/tilemap.bin"

TempestPortraitAttrMap:
	INCBIN "assets/portrait/npc/tempest/attrmap.bin"

	; Overlay region: two-frame eyes/blink animation (eyes_frame0/blink_frame0 ->
	; eyes_frame1/blink_frame1) drawn over VRAM $98ad, plus three static overlay
	; metasprites (hat, shoulder, dragon_eye). Layered PNG source in
	; assets/portrait/tempest/sprites/ (see docs/portrait_overlays.md).
	INCLUDE "assets/portrait/npc/tempest/sprites.asm"
