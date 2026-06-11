; Gali summon-animation assets (src/scene.asm scene 3): palette, tileset, metasprite defs. Gali's descriptor frames are in the shared bank $0c (see summon_maps). See docs/screen_tilemaps.md.
; The tile sheet + palette are the editable source assets/scene/<name>/tiles.png
; (both banks stacked, palettes embedded); tools/pngasset.py (mode: scene) splits
; them and passes the committed descriptor/metasprite data through to build/assets/<name>/.

SECTION "Gali summon", ROMX

GaliPalettes:
	INCBIN "assets/gali/palette.bin"
GaliTiles:
	INCBIN "assets/gali/tiles_bank0.2bpp"
	INCBIN "assets/gali/tiles_bank1.2bpp"
GaliSprites:
	INCBIN "assets/gali/metasprites.bin"
