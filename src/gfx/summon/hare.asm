; Hare summon-animation assets (src/scene.asm, scene 2). Palette + tileset + CopyBgMap descriptor frames; see docs/screen_tilemaps.md and the scene.asm per-scene tables.
; Blobs in assets/scene/<monster>/ (INCBIN); no db. Pad* = $00 padding.

SECTION "Hare summon", ROMX

HarePalettes:
	INCBIN "assets/scene/hare/palette.bin"
HareTiles:
	INCBIN "assets/scene/hare/tiles_bank0.2bpp"
	INCBIN "assets/scene/hare/tiles_bank1.2bpp"
HareSprites:
	INCBIN "assets/scene/hare/metasprites.bin"
HareMaps:
	INCBIN "assets/scene/hare/descriptors.bin"
