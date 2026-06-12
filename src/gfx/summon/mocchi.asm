; Mocchi summon-animation assets (src/scene.asm, scene 1). Palette + tileset + CopyBgMap descriptor frames; see docs/screen_tilemaps.md.
; The tile sheet + palette are the editable source assets/scene/<name>/tiles.png
; (both banks stacked, palettes embedded); tools/pngasset.py (mode: scene) splits
; them and passes the committed descriptor/metasprite data through to build/assets/<name>/.

SECTION "Mocchi summon", ROMX

MocchiPalettes:
	INCBIN "assets/summon/mocchi/palette.bin"
MocchiTiles:
	INCBIN "assets/summon/mocchi/tiles_bank0.2bpp"
	INCBIN "assets/summon/mocchi/tiles_bank1.2bpp"
; Mocchi metasprite defs (DrawMetasprite: count, {dy,dx,tile,attr});
; referenced by the scene-VM SHOW lists (SCENE_SPRITE_LIST) by label.
MocchiSprite00:
	db 12, 32, 0, $56, $08, 32, 8, $5a, $08, 32, 16, $5e, $09, 32, 24, $62, $08, 32, 32, $66, $08, 32, 40, $6a, $08, 48, 0, $58, $08, 48, 8, $5c, $08, 48, 16, $60, $08, 48, 24, $64, $08, 48, 32, $68, $08, 48, 40, $6c, $08
MocchiSprite01:
	db 6, 32, 8, $6e, $09, 32, 16, $70, $09, 32, 24, $74, $09, 32, 32, $78, $09, 48, 16, $72, $09, 48, 24, $76, $09
MocchiSprite02:
	db 8, 32, 16, $42, $09, 32, 24, $46, $09, 48, 0, $3e, $08, 48, 8, $40, $08, 48, 16, $44, $08, 48, 24, $48, $08, 48, 32, $4a, $08, 48, 40, $4c, $08
MocchiSprite03:
	db 6, 32, 16, $42, $09, 32, 24, $46, $09, 48, 8, $4e, $09, 48, 16, $50, $09, 48, 24, $52, $09, 48, 32, $54, $09
MocchiSprite04:
	db 13, 0, 8, $18, $09, 0, 16, $1e, $09, 0, 32, $2c, $08, 8, 24, $26, $08, 16, 8, $1a, $09, 16, 16, $20, $08, 16, 32, $2e, $08, 24, 24, $28, $08, 32, 8, $1c, $08, 32, 16, $22, $08, 32, 32, $30, $08, 40, 24, $2a, $08, 48, 16, $24, $08
MocchiSprite05:
	db 6, 0, 24, $38, $09, 0, 32, $3c, $09, 16, 16, $34, $09, 16, 24, $3a, $09, 32, 8, $32, $09, 32, 16, $36, $09
MocchiSprite06:
	db 16, 0, 8, $6e, $00, 0, 16, $76, $01, 0, 24, $7e, $01, 0, 32, $06, $09, 16, 8, $70, $00, 16, 16, $78, $00, 16, 24, $00, $09, 16, 32, $08, $08, 24, 0, $6c, $00, 32, 8, $72, $00, 32, 16, $7a, $00, 32, 24, $02, $08, 32, 32, $0a, $08, 48, 8, $74, $00, 48, 16, $7c, $00, 48, 24, $04, $08
MocchiSprite07:
	db 6, 16, 16, $0e, $09, 16, 32, $14, $09, 32, 8, $0c, $09, 32, 16, $10, $09, 32, 24, $12, $09, 32, 32, $16, $09
MocchiSprite08:
	db 18, 0, 0, $36, $01, 0, 8, $3e, $00, 0, 16, $46, $00, 0, 24, $4e, $00, 16, 0, $38, $00, 16, 8, $40, $00, 16, 16, $48, $00, 16, 24, $50, $00, 16, 32, $56, $01, 32, 0, $3a, $00, 32, 8, $42, $00, 32, 16, $4a, $00, 32, 24, $52, $00, 32, 32, $58, $01, 48, 0, $3c, $00, 48, 8, $44, $00, 48, 16, $4c, $00, 48, 24, $54, $00
MocchiSprite09:
	db 9, 0, 8, $5c, $01, 0, 16, $60, $01, 0, 24, $64, $01, 16, 0, $5a, $02, 16, 8, $5e, $02, 16, 24, $66, $01, 32, 24, $68, $01, 48, 16, $62, $01, 48, 24, $6a, $01
MocchiSprite10:
	db 19, 0, 0, $00, $00, 0, 8, $22, $01, 0, 16, $0c, $00, 0, 24, $14, $00, 0, 32, $1c, $00, 16, 0, $02, $00, 16, 8, $26, $03, 16, 16, $0e, $00, 16, 24, $16, $00, 16, 32, $1e, $00, 32, 0, $04, $00, 32, 8, $08, $00, 32, 16, $10, $00, 32, 24, $18, $00, 32, 32, $20, $00, 48, 8, $0a, $00, 48, 16, $12, $00, 48, 24, $1a, $00, 48, 32, $24, $01
MocchiSprite11:
	db 7, 0, 0, $2a, $01, 0, 16, $2e, $01, 16, 0, $2c, $01, 16, 8, $28, $02, 16, 16, $30, $02, 32, 32, $34, $01, 48, 24, $32, $01
; Mocchi BG animation frames (CopyBgMap descriptors), drawn by the
; scene VM (SCENE_BG_DRAW) by label; maps compiled from
; assets/scene/mocchi/frames.tmx (one Tiled layer pair per frame).
MocchiFrame00:
	db 12, 32
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/mocchi/frame00_idx.bin"
.attr:
	INCBIN "assets/summon/mocchi/frame00_attr.bin"
