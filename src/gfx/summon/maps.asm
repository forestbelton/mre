; Shared BG descriptor (CopyBgMap tilemap) frames for the Gali (scene 3) and Phenix (scene 6) summon animations, plus Phenix's metasprite defs. The scene scripts cycle these frames. NOTE: earlier mislabeled as the level-editor screen set; it is reached ONLY via scene.asm's SceneDescBank table (no editor use). See docs/screen_tilemaps.md.
; Blobs in assets/scene/<monster>/ (INCBIN); no db. Pad* = $00 padding.

SECTION "scene_maps", ROMX[$4000], BANK[$0c]

GaliMaps:
	INCBIN "assets/scene/gali/descriptors.bin"
PhenixMaps:
	INCBIN "assets/scene/phenix/descriptors.bin"
PhenixSprites:
	INCBIN "assets/scene/phenix/metasprites.bin"
