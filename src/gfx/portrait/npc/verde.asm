; Verde's portrait (shown throughout Verde's dialogue and the intro scene). Single-blob
; Kalum layout: 384 tiles -> VRAM bank 1 $8000 ($8800 addressing), arranged by the
; CopyBgMap descriptor below. Located by tracing Verde's script (Verde_BuildPortraitScene
; / Verde_BuildIntroScene far-call $1b:$5c5d -> VRAM, palettes from $745d/$749d, maps
; from $74dd; the overlay render funcs Verde_RenderPortrait/*Surprised/*Calm).
;
; Assembled from assets/portrait/verde/ by tools/pngasset.py (Makefile, output under
; build/assets/). Two palette sets: the portrait scene ($745d/$749d, carved from the
; sheet PNG) and the intro scene ($788e/$78ce, carried by intro_pals.png). Previously
; lived raw (gfx/raw INCBINs + db) inside pashute.asm.

SECTION "Verde graphics", ROMX[$5c5d], BANK[$1b]

VerdePortraitTiles:                              ; $5c5d, 384 tiles -> VRAM bank 1 $8000
	INCBIN "assets/portrait/npc/verde/tiles.bin"

VerdePortraitPaletteBg:                          ; $745d
	INCBIN "assets/portrait/npc/verde/palette_bg.bin"     ; 6 BG palettes (RGB555 LE)

	DS $10

VerdePortraitPaletteObj:                         ; $749d
	INCBIN "assets/portrait/npc/verde/palette_obj.bin"    ; 6 OBJ palettes (RGB555 LE)

	DS $10

VerdePortraitMapDesc:                            ; $74dd
	db 11, 20
	dw VerdePortraitAttrMap
	dw VerdePortraitIndexMap

VerdePortraitIndexMap:                           ; $74e3
	INCBIN "assets/portrait/npc/verde/tilemap.bin"

VerdePortraitAttrMap:                            ; $75bf
	INCBIN "assets/portrait/npc/verde/attrmap.bin"

VerdePortraitOverlay:                            ; $769b
	; Overlay region ($769b-$788e): 3-frame talking animation (eyes_frame0/head_frame0
	; .. frame2) drawn over VRAM $98a5, the face + overalls metasprites, a base patch,
	; and sad/surprised expressions (eyes/head/face each) -- the layered PNG source in
	; assets/portrait/verde/sprites/ (see docs/portrait_overlays.md).
	INCLUDE "assets/portrait/npc/verde/sprites.asm"

VerdeIntroPaletteBg:                             ; $788e, intro-scene BG palettes
	INCBIN "assets/portrait/npc/verde/palette_bg2.bin"

	DS $10

SECTION "Verde intro obj palettes", ROMX[$78ce], BANK[$1b]

VerdeIntroPaletteObj:                            ; $78ce, intro-scene OBJ palettes
	INCBIN "assets/portrait/npc/verde/palette_obj2.bin"
