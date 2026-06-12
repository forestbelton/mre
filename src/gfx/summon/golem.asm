; Golem summon-animation assets (drawn by src/scene.asm, scene 4 / wDisplayMonster=4). Palette block ($4000), BG+OBJ tileset ($4080, $3000 B loaded across VRAM banks 0+1 by SceneLoadTiles), and the CopyBgMap descriptor frames. Indexed via the scene.asm tables (SceneBgTilesetBank/ScenePaletteBank/SceneDescBank). See docs/screen_tilemaps.md.
; The tile sheet + palette are the editable source assets/scene/golem/tiles.png (both
; banks stacked, the 16 palettes embedded); tools/pngasset.py (mode: scene) splits them and
; passes the committed descriptor/metasprite data through, so the asm INCBINs build/assets/golem/.

SECTION "Golem summon", ROMX

GolemPalettes:
	INCBIN "assets/summon/golem/palette.bin"
GolemTiles:
	INCBIN "assets/summon/golem/tiles_bank0.2bpp"
	INCBIN "assets/summon/golem/tiles_bank1.2bpp"
; Golem metasprite defs (DrawMetasprite: count, {dy,dx,tile,attr});
; referenced by the scene-VM SHOW lists (SCENE_SPRITE_LIST) by label.
GolemSprite00:
	db 32, 0, 8, $08, $08, 0, 16, $0e, $08, 8, 0, $06, $08, 8, 24, $18, $08, 8, 32, $20, $08, 8, 40, $28, $08, 8, 48, $30, $08, 16, 8, $0a, $08, 16, 16, $10, $08, 16, 56, $38, $08, 24, 24, $1a, $08, 24, 32, $22, $08, 24, 40, $2a, $08, 24, 48, $32, $08, 32, 16, $12, $08, 32, 56, $3a, $08, 40, 8, $0c, $08, 40, 24, $1c, $08, 40, 32, $24, $08, 40, 40, $2c, $08, 40, 48, $34, $08, 48, 16, $14, $08, 48, 56, $3c, $08, 56, 0, $48, $00, 56, 8, $50, $00, 56, 16, $58, $00, 56, 24, $1e, $08, 56, 32, $26, $08, 56, 40, $2e, $08, 56, 48, $36, $08, 64, 16, $16, $08, 64, 56, $3e, $08
GolemSprite01:
	db 34, 0, 0, $42, $00, 0, 40, $6a, $00, 0, 48, $74, $00, 0, 56, $7e, $00, 8, 8, $4a, $00, 8, 16, $52, $00, 8, 24, $5a, $00, 8, 32, $62, $00, 16, 0, $44, $00, 16, 40, $6c, $00, 16, 48, $76, $00, 16, 56, $00, $08, 24, 8, $4c, $00, 24, 16, $54, $00, 24, 24, $5c, $00, 24, 32, $64, $00, 32, 0, $46, $00, 32, 40, $6e, $00, 32, 48, $78, $00, 40, 8, $4e, $00, 40, 16, $56, $00, 40, 24, $5e, $00, 40, 32, $66, $00, 40, 56, $02, $08, 48, 40, $70, $00, 48, 48, $7a, $00, 56, 0, $48, $00, 56, 8, $50, $00, 56, 16, $58, $00, 56, 24, $60, $00, 56, 32, $68, $00, 56, 56, $04, $08, 64, 40, $72, $00, 64, 48, $7c, $00
GolemSprite02:
	db 33, 0, 24, $16, $00, 0, 32, $20, $00, 0, 40, $2a, $00, 0, 48, $34, $00, 16, 8, $06, $00, 16, 16, $0e, $00, 16, 24, $18, $00, 16, 32, $22, $00, 16, 40, $2c, $00, 16, 48, $36, $00, 24, 0, $00, $00, 32, 8, $08, $00, 32, 16, $10, $00, 32, 24, $1a, $00, 32, 32, $24, $00, 32, 40, $2e, $00, 32, 48, $38, $00, 40, 0, $02, $00, 40, 56, $3e, $00, 48, 8, $0a, $00, 48, 16, $12, $00, 48, 24, $1c, $00, 48, 32, $26, $00, 48, 40, $30, $00, 48, 48, $3a, $00, 56, 0, $04, $00, 56, 56, $40, $00, 64, 8, $0c, $00, 64, 16, $14, $00, 64, 24, $1e, $00, 64, 32, $28, $00, 64, 40, $32, $00, 64, 48, $3c, $00
; Golem BG animation frames (CopyBgMap descriptors), drawn by the
; scene VM (SCENE_BG_DRAW) by label; maps compiled from
; assets/scene/golem/frames.tmx (one Tiled layer pair per frame).
GolemFrame00:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/golem/frame00_idx.bin"
.attr:
	INCBIN "assets/summon/golem/frame00_attr.bin"
GolemFrame01:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/golem/frame01_idx.bin"
.attr:
	INCBIN "assets/summon/golem/frame01_attr.bin"
GolemFrame02:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/golem/frame02_idx.bin"
.attr:
	INCBIN "assets/summon/golem/frame02_attr.bin"
GolemFrame03:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/golem/frame03_idx.bin"
.attr:
	INCBIN "assets/summon/golem/frame03_attr.bin"
GolemFrame04:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/golem/frame04_idx.bin"
.attr:
	INCBIN "assets/summon/golem/frame04_attr.bin"
GolemFrame05:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/golem/frame05_idx.bin"
.attr:
	INCBIN "assets/summon/golem/frame05_attr.bin"
GolemFrame06:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/golem/frame06_idx.bin"
.attr:
	INCBIN "assets/summon/golem/frame06_attr.bin"
