; Gali summon-animation assets (src/scene.asm scene 3): palette, tileset, metasprite defs. Gali's descriptor frames are in the shared bank $0c (see summon_maps). See docs/screen_tilemaps.md.
; Blobs in assets/scene/<monster>/ (INCBIN); no db. Pad* = $00 padding.

SECTION "Gali summon", ROMX

GaliPalettes:
	INCBIN "assets/scene/gali/palette.bin"
GaliTiles:
	INCBIN "assets/scene/gali/tiles_bank0.2bpp"
	INCBIN "assets/scene/gali/tiles_bank1.2bpp"
GaliSprites:
	INCBIN "assets/scene/gali/metasprites.bin"
