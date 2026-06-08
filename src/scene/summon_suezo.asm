; Suezo summon-animation assets (src/scene.asm, scene 5). Palette + tileset + CopyBgMap descriptor frames; see docs/screen_tilemaps.md.
; Blobs in assets/scene/<monster>/ (INCBIN); no db. Pad* = $00 padding.

SECTION "scene_suezo", ROMX[$4000], BANK[$0a]

SuezoPalettes:
	INCBIN "assets/scene/suezo/palette.bin"
SuezoTiles:
	INCBIN "assets/scene/suezo/tiles_bank0.2bpp"
	INCBIN "assets/scene/suezo/tiles_bank1.2bpp"
SuezoSprites:
	INCBIN "assets/scene/suezo/metasprites.bin"
SuezoMaps:
	INCBIN "assets/scene/suezo/descriptors.bin"
