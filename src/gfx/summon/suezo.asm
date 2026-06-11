; Suezo summon-animation assets (src/scene.asm, scene 5). Palette + tileset + CopyBgMap descriptor frames; see docs/screen_tilemaps.md.
; The tile sheet + palette are the editable source assets/scene/<name>/tiles.png
; (both banks stacked, palettes embedded); tools/pngasset.py (mode: scene) splits
; them and passes the committed descriptor/metasprite data through to build/assets/<name>/.

SECTION "Suezo summon", ROMX

SuezoPalettes:
	INCBIN "assets/suezo/palette.bin"
SuezoTiles:
	INCBIN "assets/suezo/tiles_bank0.2bpp"
	INCBIN "assets/suezo/tiles_bank1.2bpp"
SuezoSprites:
	INCBIN "assets/suezo/metasprites.bin"
SuezoMaps:
	INCBIN "assets/suezo/descriptors.bin"
