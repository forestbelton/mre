; Assets for scene 7 of the bank-$05 scene engine (src/scene.asm): the monster
; CAPTURE animation -- the golden, engraved disc stone glowing/charging, played
; when you capture a monster with a disc stone. This is the shared wSceneState=7
; scene (hardcoded, not one of the per-monster reveal scenes 0-6).
; Palette, tileset, CopyBgMap descriptor frames, and metasprite defs.
; See docs/screen_tilemaps.md.
; Blobs in assets/scene/<monster>/ (INCBIN); no db. Pad* = $00 padding.

SECTION "scene_scene7", ROMX[$4000], BANK[$0e]

Scene7Tiles:
	INCBIN "assets/scene/scene7/tiles_bank0.2bpp"
	INCBIN "assets/scene/scene7/tiles_bank1.2bpp"
Scene7Palettes:
	INCBIN "assets/scene/scene7/palette.bin"
Scene7Maps:
	INCBIN "assets/scene/scene7/descriptors.bin"
Scene7Sprites:
	INCBIN "assets/scene/scene7/metasprites.bin"
