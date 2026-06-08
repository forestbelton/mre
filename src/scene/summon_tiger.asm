; Tiger summon-animation assets (src/scene.asm scene 0): palette, tileset, and metasprite defs (SceneDrawBank[0]). Tiger's CopyBgMap descriptor frames live in bank $05 (scene.asm itself). See docs/screen_tilemaps.md.
; Blobs in assets/scene/<monster>/ (INCBIN); no db. Pad* = $00 padding.

SECTION "Tiger summon", ROMX

TigerPalettes:
	INCBIN "assets/scene/tiger/palette.bin"
TigerTiles:
	INCBIN "assets/scene/tiger/tiles_bank0.2bpp"
	INCBIN "assets/scene/tiger/tiles_bank1.2bpp"
TigerSprites:
	INCBIN "assets/scene/tiger/metasprites.bin"
