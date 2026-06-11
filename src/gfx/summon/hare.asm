; Hare summon-animation assets (src/scene.asm, scene 2). Palette + tileset + CopyBgMap descriptor frames; see docs/screen_tilemaps.md and the scene.asm per-scene tables.
; The tile sheet + palette are the editable source assets/scene/<name>/tiles.png
; (both banks stacked, palettes embedded); tools/pngasset.py (mode: scene) splits
; them and passes the committed descriptor/metasprite data through to build/assets/<name>/.

SECTION "Hare summon", ROMX

HarePalettes:
	INCBIN "assets/hare/palette.bin"
HareTiles:
	INCBIN "assets/hare/tiles_bank0.2bpp"
	INCBIN "assets/hare/tiles_bank1.2bpp"
HareSprites:
	INCBIN "assets/hare/metasprites.bin"
HareMaps:
	INCBIN "assets/hare/descriptors.bin"
