; Golem summon-animation assets (drawn by src/scene.asm, scene 4 / wDisplayMonster=4). Palette block ($4000), BG+OBJ tileset ($4080, $3000 B loaded across VRAM banks 0+1 by SceneLoadTiles), and the CopyBgMap descriptor frames. Indexed via the scene.asm tables (SceneBgTilesetBank/ScenePaletteBank/SceneDescBank). See docs/screen_tilemaps.md.
; The tile sheet + palette are the editable source assets/scene/golem/tiles.png (both
; banks stacked, the 16 palettes embedded); tools/pngasset.py (mode: scene) splits them and
; passes the committed descriptor/metasprite data through, so the asm INCBINs build/assets/golem/.

SECTION "Golem summon", ROMX

GolemPalettes:
	INCBIN "assets/golem/palette.bin"
GolemTiles:
	INCBIN "assets/golem/tiles_bank0.2bpp"
	INCBIN "assets/golem/tiles_bank1.2bpp"
GolemSprites:
	INCBIN "assets/golem/metasprites.bin"
GolemMaps:
	INCBIN "assets/golem/descriptors.bin"
