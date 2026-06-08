; Golem summon-animation assets (drawn by src/scene.asm, scene 4 / wDisplayMonster=4). Palette block ($4000), BG+OBJ tileset ($4080, $3000 B loaded across VRAM banks 0+1 by SceneLoadTiles), and the CopyBgMap descriptor frames. Indexed via the scene.asm tables (SceneBgTilesetBank/ScenePaletteBank/SceneDescBank). See docs/screen_tilemaps.md.
; Blobs in assets/scene/<monster>/ (INCBIN); no db. Pad* = $00 padding.

SECTION "Golem summon", ROMX

GolemPalettes:
	INCBIN "assets/scene/golem/palette.bin"
GolemTiles:
	INCBIN "assets/scene/golem/tiles_bank0.2bpp"
	INCBIN "assets/scene/golem/tiles_bank1.2bpp"
GolemSprites:
	INCBIN "assets/scene/golem/metasprites.bin"
GolemMaps:
	INCBIN "assets/scene/golem/descriptors.bin"
