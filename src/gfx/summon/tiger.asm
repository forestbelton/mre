; Tiger summon-animation assets (src/scene.asm scene 0): palette, tileset, and metasprite defs (SceneDrawBank[0]). Tiger's CopyBgMap descriptor frames live in bank $05 (scene.asm itself). See docs/screen_tilemaps.md.
; The tile sheet + palette are the editable source assets/scene/<name>/tiles.png
; (both banks stacked, palettes embedded); tools/pngasset.py (mode: scene) splits
; them and passes the committed descriptor/metasprite data through to build/assets/<name>/.

SECTION "Tiger summon", ROMX

TigerPalettes:
	INCBIN "assets/tiger/palette.bin"
TigerTiles:
	INCBIN "assets/tiger/tiles_bank0.2bpp"
	INCBIN "assets/tiger/tiles_bank1.2bpp"
TigerSprites:
	INCBIN "assets/tiger/metasprites.bin"
