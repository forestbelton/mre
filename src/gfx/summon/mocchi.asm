; Mocchi summon-animation assets (src/scene.asm, scene 1). Palette + tileset + CopyBgMap descriptor frames; see docs/screen_tilemaps.md.
; Blobs in assets/scene/<monster>/ (INCBIN); no db. Pad* = $00 padding.

SECTION "Mocchi summon", ROMX

MocchiPalettes:
	INCBIN "assets/scene/mocchi/palette.bin"
MocchiTiles:
	INCBIN "assets/scene/mocchi/tiles_bank0.2bpp"
	INCBIN "assets/scene/mocchi/tiles_bank1.2bpp"
MocchiSprites:
	INCBIN "assets/scene/mocchi/metasprites.bin"
MocchiMaps:
	INCBIN "assets/scene/mocchi/descriptors.bin"
