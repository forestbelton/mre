; Hare summon-animation assets (src/scene.asm, scene 2). Palette + tileset + CopyBgMap descriptor frames; see docs/screen_tilemaps.md and the scene.asm per-scene tables.
; The tile sheet + palette are the editable source assets/scene/<name>/tiles.png
; (both banks stacked, palettes embedded); tools/pngasset.py (mode: scene) splits
; them and passes the committed descriptor/metasprite data through to build/assets/<name>/.

SECTION "Hare summon", ROMX

HarePalettes:
	INCBIN "assets/summon/hare/palette.bin"
HareTiles:
	INCBIN "assets/summon/hare/tiles_bank0.2bpp"
	INCBIN "assets/summon/hare/tiles_bank1.2bpp"
; Hare metasprite defs (DrawMetasprite: count, {dy,dx,tile,attr});
; referenced by the scene-VM SHOW lists (SCENE_SPRITE_LIST) by label.
HareSprite00:
	db 10, 0, 8, $60, $01, 0, 16, $62, $01, 0, 24, $64, $01, 0, 32, $66, $01, 16, 0, $68, $03, 16, 8, $6a, $00, 16, 16, $6c, $00, 16, 24, $6e, $00, 32, 24, $70, $03, 32, 32, $72, $03
HareSprite01:
	db 3, 16, 8, $74, $03, 16, 16, $76, $03, 16, 24, $78, $03
HareSprite02:
	db 13, 0, 0, $7a, $01, 0, 8, $7e, $01, 0, 16, $04, $09, 0, 24, $0a, $09, 0, 32, $10, $09, 16, 0, $7c, $01, 16, 8, $00, $09, 16, 16, $06, $09, 16, 24, $0c, $09, 24, 32, $12, $09, 32, 8, $02, $09, 32, 16, $08, $09, 32, 24, $0e, $09
HareSprite03:
	db 17, 0, 0, $3e, $00, 0, 8, $42, $01, 0, 16, $48, $01, 0, 24, $50, $00, 0, 32, $52, $00, 0, 40, $54, $00, 16, 8, $44, $02, 16, 16, $4a, $01, 16, 24, $56, $01, 16, 32, $5a, $00, 32, 0, $40, $03, 32, 8, $46, $02, 32, 16, $4c, $02, 32, 24, $58, $02, 32, 32, $5c, $03, 48, 16, $4e, $00, 48, 24, $5e, $03
HareSprite04:
	db 19, 0, 0, $14, $09, 0, 8, $1a, $09, 0, 16, $22, $09, 0, 24, $2a, $09, 0, 32, $32, $09, 0, 40, $38, $09, 16, 0, $16, $09, 16, 8, $1c, $09, 16, 16, $24, $09, 16, 24, $2c, $09, 16, 32, $34, $09, 32, 0, $18, $09, 32, 8, $1e, $09, 32, 16, $26, $09, 32, 24, $2e, $09, 32, 32, $36, $09, 48, 8, $20, $09, 48, 16, $28, $09, 48, 24, $30, $09
HareSprite05:
	db 24, 0, 0, $00, $00, 0, 8, $02, $00, 0, 16, $04, $00, 0, 24, $0e, $00, 0, 32, $12, $00, 0, 40, $16, $00, 0, 48, $1a, $00, 16, 16, $06, $00, 16, 24, $10, $00, 16, 32, $14, $00, 16, 40, $18, $01, 24, 48, $1c, $00, 32, 16, $08, $00, 32, 24, $1e, $01, 32, 32, $20, $01, 32, 40, $2a, $00, 40, 48, $2e, $02, 48, 16, $0a, $00, 48, 24, $26, $02, 48, 32, $28, $02, 48, 40, $2c, $02, 56, 0, $22, $02, 56, 8, $24, $02, 64, 16, $0c, $00
HareSprite06:
	db 7, 24, 24, $34, $02, 24, 32, $36, $02, 32, 16, $30, $02, 32, 40, $38, $02, 40, 48, $3c, $00, 48, 16, $32, $02, 48, 40, $3a, $00
HareSprite07:
	db 25, 0, 0, $3a, $09, 0, 8, $3e, $09, 0, 16, $44, $09, 0, 24, $4e, $09, 0, 32, $56, $09, 0, 40, $5e, $09, 0, 48, $66, $09, 16, 16, $46, $09, 16, 24, $50, $09, 16, 32, $58, $09, 16, 40, $60, $09, 16, 48, $68, $09, 32, 16, $48, $09, 32, 24, $52, $09, 32, 32, $5a, $09, 32, 40, $62, $09, 32, 48, $6a, $09, 48, 16, $4a, $09, 48, 24, $54, $09, 48, 32, $5c, $09, 48, 40, $64, $09, 48, 48, $6c, $09, 56, 0, $3c, $09, 56, 8, $42, $09, 64, 16, $4c, $09
; Hare BG animation frames (CopyBgMap descriptors), drawn by the
; scene VM (SCENE_BG_DRAW) by label; maps compiled from
; assets/scene/hare/frames.tmx (one Tiled layer pair per frame).
HareFrame00:
	db 12, 32
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/hare/frame00_idx.bin"
.attr:
	INCBIN "assets/summon/hare/frame00_attr.bin"
