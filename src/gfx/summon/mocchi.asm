; Mocchi summon-animation assets (src/scene.asm, scene 1). Palette + tileset + CopyBgMap descriptor frames; see docs/screen_tilemaps.md.
; The tile sheet + palette are the editable source assets/scene/<name>/tiles.png
; (both banks stacked, palettes embedded); tools/pngasset.py (mode: scene) splits
; them and passes the committed descriptor/metasprite data through to build/assets/<name>/.

SECTION "Mocchi summon", ROMX

MocchiPalettes:
	INCBIN "assets/mocchi/palette.bin"
MocchiTiles:
	INCBIN "assets/mocchi/tiles_bank0.2bpp"
	INCBIN "assets/mocchi/tiles_bank1.2bpp"
MocchiSprites:
	INCBIN "assets/mocchi/metasprites.bin"
MocchiMaps:
	INCBIN "assets/mocchi/descriptors.bin"
