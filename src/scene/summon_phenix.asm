; Phenix summon-animation assets (src/scene.asm scene 6): palette + tileset. Phenix's descriptors and metasprite defs are in the shared bank $0c. See docs/screen_tilemaps.md.
; Blobs in assets/scene/<monster>/ (INCBIN); no db. Pad* = $00 padding.

SECTION "scene_phenix", ROMX[$4000], BANK[$0d]

PhenixPalettes:
	INCBIN "assets/scene/phenix/palette.bin"
PhenixTiles:
	INCBIN "assets/scene/phenix/tiles_bank0.2bpp"
	INCBIN "assets/scene/phenix/tiles_bank1.2bpp"
