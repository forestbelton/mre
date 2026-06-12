; Suezo summon-animation assets (src/scene.asm, scene 5). Palette + tileset + CopyBgMap descriptor frames; see docs/screen_tilemaps.md.
; The tile sheet + palette are the editable source assets/scene/<name>/tiles.png
; (both banks stacked, palettes embedded); tools/pngasset.py (mode: scene) splits
; them and passes the committed descriptor/metasprite data through to build/assets/<name>/.

SECTION "Suezo summon", ROMX

SuezoPalettes:
	INCBIN "assets/summon/suezo/palette.bin"
SuezoTiles:
	INCBIN "assets/summon/suezo/tiles_bank0.2bpp"
	INCBIN "assets/summon/suezo/tiles_bank1.2bpp"
; Suezo metasprite defs (DrawMetasprite: count, {dy,dx,tile,attr});
; referenced by the scene-VM SHOW lists (SCENE_SPRITE_LIST) by label.
SuezoSprite00:
	db 20, 0, 0, $60, $08, 0, 8, $64, $08, 0, 16, $68, $08, 0, 24, $6c, $08, 0, 32, $7e, $00, 8, 40, $24, $00, 16, 0, $62, $08, 16, 8, $66, $08, 16, 16, $6a, $08, 16, 24, $6e, $08, 16, 32, $3c, $08, 24, 40, $26, $00, 32, 0, $6a, $00, 32, 8, $32, $08, 32, 16, $36, $08, 32, 24, $3a, $08, 32, 32, $3e, $08, 48, 16, $12, $00, 48, 24, $1a, $00, 48, 32, $22, $00
SuezoSprite01:
	db 8, 8, 0, $70, $09, 8, 8, $74, $09, 8, 16, $78, $09, 8, 24, $7c, $09, 24, 0, $72, $09, 24, 8, $76, $09, 24, 16, $7a, $09, 24, 24, $5e, $09
SuezoSprite02:
	db 20, 0, 0, $40, $08, 0, 8, $44, $08, 0, 16, $48, $08, 0, 24, $4c, $08, 0, 32, $7e, $00, 8, 40, $24, $00, 16, 0, $42, $08, 16, 8, $46, $08, 16, 16, $4a, $08, 16, 24, $4e, $08, 16, 32, $3c, $08, 24, 40, $26, $00, 32, 0, $6a, $00, 32, 8, $32, $08, 32, 16, $36, $08, 32, 24, $3a, $08, 32, 32, $3e, $08, 48, 16, $12, $00, 48, 24, $1a, $00, 48, 32, $22, $00
SuezoSprite03:
	db 8, 8, 0, $50, $09, 8, 8, $54, $09, 8, 16, $58, $09, 8, 24, $5c, $09, 24, 0, $52, $09, 24, 8, $56, $09, 24, 16, $5a, $09, 24, 24, $5e, $09
SuezoSprite04:
	db 20, 0, 0, $66, $00, 0, 8, $6c, $00, 0, 16, $72, $00, 0, 24, $78, $00, 0, 32, $7e, $00, 8, 40, $24, $00, 16, 0, $68, $00, 16, 8, $6e, $00, 16, 16, $34, $08, 16, 24, $38, $08, 16, 32, $3c, $08, 24, 40, $26, $00, 32, 0, $6a, $00, 32, 8, $32, $08, 32, 16, $36, $08, 32, 24, $3a, $08, 32, 32, $3e, $08, 48, 16, $12, $00, 48, 24, $1a, $00, 48, 32, $22, $00
SuezoSprite05:
	db 8, 8, 0, $04, $09, 8, 8, $08, $09, 8, 16, $0c, $09, 8, 24, $10, $09, 24, 0, $06, $09, 24, 8, $0a, $09, 24, 16, $0e, $09, 24, 24, $12, $09
SuezoSprite06:
	db 20, 0, 0, $14, $08, 0, 8, $1a, $08, 0, 16, $20, $08, 0, 24, $26, $08, 0, 32, $2c, $08, 8, 40, $24, $00, 16, 0, $16, $08, 16, 8, $1c, $08, 16, 16, $22, $08, 16, 24, $28, $08, 16, 32, $2e, $08, 24, 40, $26, $00, 32, 0, $18, $08, 32, 8, $1e, $08, 32, 16, $24, $08, 32, 24, $2a, $08, 32, 32, $30, $08, 48, 16, $12, $00, 48, 24, $1a, $00, 48, 32, $22, $00
SuezoSprite07:
	db 20, 0, 0, $66, $00, 0, 8, $6c, $00, 0, 16, $72, $00, 0, 24, $78, $00, 0, 32, $7e, $00, 8, 40, $24, $00, 16, 0, $68, $00, 16, 8, $6e, $00, 16, 16, $74, $00, 16, 24, $7a, $00, 16, 32, $00, $08, 24, 40, $26, $00, 32, 0, $6a, $00, 32, 8, $70, $00, 32, 16, $76, $00, 32, 24, $7c, $00, 32, 32, $02, $08, 48, 16, $12, $00, 48, 24, $1a, $00, 48, 32, $22, $00
SuezoSprite08:
	db 8, 8, 0, $04, $09, 8, 8, $08, $09, 8, 16, $0c, $09, 8, 24, $10, $09, 24, 0, $06, $09, 24, 8, $0a, $09, 24, 16, $0e, $09, 24, 24, $12, $09
SuezoSprite09:
	db 20, 0, 0, $38, $00, 0, 8, $3e, $00, 0, 16, $44, $00, 0, 24, $4a, $00, 0, 32, $50, $00, 8, 40, $24, $00, 16, 0, $3a, $00, 16, 8, $40, $00, 16, 16, $46, $00, 16, 24, $4c, $00, 16, 32, $52, $00, 24, 40, $26, $00, 32, 0, $3c, $00, 32, 8, $42, $00, 32, 16, $48, $00, 32, 24, $4e, $00, 32, 32, $54, $00, 48, 16, $12, $00, 48, 24, $1a, $00, 48, 32, $22, $00
SuezoSprite10:
	db 8, 8, 0, $56, $01, 8, 8, $5a, $01, 8, 16, $5e, $01, 8, 24, $62, $01, 24, 0, $58, $01, 24, 8, $5c, $01, 24, 16, $60, $01, 24, 24, $64, $01
SuezoSprite11:
	db 20, 0, 0, $00, $00, 0, 8, $06, $00, 0, 16, $0c, $00, 0, 24, $14, $00, 0, 32, $1c, $00, 8, 40, $24, $00, 16, 0, $02, $00, 16, 8, $08, $00, 16, 16, $0e, $00, 16, 24, $16, $00, 16, 32, $1e, $00, 24, 40, $26, $00, 32, 0, $04, $00, 32, 8, $0a, $00, 32, 16, $10, $00, 32, 24, $18, $00, 32, 32, $20, $00, 48, 16, $12, $00, 48, 24, $1a, $00, 48, 32, $22, $00
SuezoSprite12:
	db 8, 8, 0, $28, $01, 8, 8, $2c, $01, 8, 16, $30, $01, 8, 24, $34, $01, 24, 0, $2a, $01, 24, 8, $2e, $01, 24, 16, $32, $01, 24, 24, $36, $01
; Suezo BG animation frames (CopyBgMap descriptors), drawn by the
; scene VM (SCENE_BG_DRAW) by label; maps compiled from
; assets/scene/suezo/frames.tmx (one Tiled layer pair per frame).
SuezoFrame00:
	db 6, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame00_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame00_attr.bin"
SuezoFrame01:
	db 6, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame01_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame01_attr.bin"
SuezoFrame02:
	db 6, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame02_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame02_attr.bin"
SuezoFrame03:
	db 6, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame03_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame03_attr.bin"
SuezoFrame04:
	db 6, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame04_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame04_attr.bin"
SuezoFrame05:
	db 6, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame05_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame05_attr.bin"
SuezoFrame06:
	db 6, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame06_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame06_attr.bin"
SuezoFrame07:
	db 10, 5
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame07_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame07_attr.bin"
SuezoFrame08:
	db 10, 5
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame08_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame08_attr.bin"
SuezoFrame09:
	db 10, 5
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame09_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame09_attr.bin"
SuezoFrame10:
	db 10, 5
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame10_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame10_attr.bin"
SuezoFrame11:
	db 10, 5
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame11_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame11_attr.bin"
SuezoFrame12:
	db 10, 5
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame12_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame12_attr.bin"
SuezoFrame13:
	db 10, 5
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame13_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame13_attr.bin"
SuezoFrame14:
	db 4, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame14_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame14_attr.bin"
SuezoFrame15:
	db 4, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame15_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame15_attr.bin"
SuezoFrame16:
	db 4, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame16_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame16_attr.bin"
SuezoFrame17:
	db 4, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame17_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame17_attr.bin"
SuezoFrame18:
	db 4, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame18_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame18_attr.bin"
SuezoFrame19:
	db 4, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame19_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame19_attr.bin"
SuezoFrame20:
	db 8, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame20_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame20_attr.bin"
SuezoFrame21:
	db 8, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame21_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame21_attr.bin"
SuezoFrame22:
	db 8, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame22_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame22_attr.bin"
SuezoFrame23:
	db 8, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame23_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame23_attr.bin"
SuezoFrame24:
	db 8, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame24_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame24_attr.bin"
SuezoFrame25:
	db 8, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame25_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame25_attr.bin"
SuezoFrame26:
	db 8, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/suezo/frame26_idx.bin"
.attr:
	INCBIN "assets/summon/suezo/frame26_attr.bin"
