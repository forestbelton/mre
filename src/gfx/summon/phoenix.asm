; Phenix summon-animation assets (src/scene.asm scene 6): palette + tileset. Phenix's descriptors and metasprite defs are in the shared bank $0c. See docs/screen_tilemaps.md.
; The tile sheet + palette are the editable source assets/scene/<name>/tiles.png
; (both banks stacked, palettes embedded); tools/pngasset.py (mode: scene) splits
; them and passes the committed descriptor/metasprite data through to build/assets/<name>/.

SECTION "scene_phenix", ROMX[$4000], BANK[$0d]

PhenixPalettes:
	INCBIN "assets/phenix/palette.bin"
PhenixTiles:
	INCBIN "assets/phenix/tiles_bank0.2bpp"
	INCBIN "assets/phenix/tiles_bank1.2bpp"
