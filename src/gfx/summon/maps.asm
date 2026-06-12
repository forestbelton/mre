; Shared BG descriptor (CopyBgMap tilemap) frames for the Gali (scene 3) and Phenix (scene 6) summon animations, plus Phenix's metasprite defs. The scene scripts cycle these frames. NOTE: earlier mislabeled as the level-editor screen set; it is reached ONLY via scene.asm's SceneDescBank table (no editor use). See docs/screen_tilemaps.md.
; Blobs in assets/scene/<monster>/ (INCBIN); no db. Pad* = $00 padding.

SECTION "scene_maps", ROMX[$4000], BANK[$0c]

; Gali BG animation frames (CopyBgMap descriptors), drawn by the
; scene VM (SCENE_BG_DRAW) by label; maps compiled from
; assets/scene/gali/frames.tmx (one Tiled layer pair per frame).
GaliFrame00:
	db 12, 10
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/gali/frame00_idx.bin"
.attr:
	INCBIN "assets/gali/frame00_attr.bin"
GaliFrame01:
	db 12, 32
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/gali/frame01_idx.bin"
.attr:
	INCBIN "assets/gali/frame01_attr.bin"
GaliFrame02:
	db 12, 32
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/gali/frame02_idx.bin"
.attr:
	INCBIN "assets/gali/frame02_attr.bin"
GaliFrame03:
	db 12, 32
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/gali/frame03_idx.bin"
.attr:
	INCBIN "assets/gali/frame03_attr.bin"
GaliFrame04:
	db 12, 32
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/gali/frame04_idx.bin"
.attr:
	INCBIN "assets/gali/frame04_attr.bin"
GaliFrame05:
	db 12, 32
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/gali/frame05_idx.bin"
.attr:
	INCBIN "assets/gali/frame05_attr.bin"
GaliFrame06:
	db 12, 32
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/gali/frame06_idx.bin"
.attr:
	INCBIN "assets/gali/frame06_attr.bin"
GaliFrame07:
	db 12, 32
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/gali/frame07_idx.bin"
.attr:
	INCBIN "assets/gali/frame07_attr.bin"
GaliFrame08:
	db 12, 32
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/gali/frame08_idx.bin"
.attr:
	INCBIN "assets/gali/frame08_attr.bin"
GaliFrame09:
	db 12, 32
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/gali/frame09_idx.bin"
.attr:
	INCBIN "assets/gali/frame09_attr.bin"
GaliFrame10:
	db 12, 32
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/gali/frame10_idx.bin"
.attr:
	INCBIN "assets/gali/frame10_attr.bin"
GaliFrame11:
	db 12, 32
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/gali/frame11_idx.bin"
.attr:
	INCBIN "assets/gali/frame11_attr.bin"
GaliFrame12:
	db 12, 32
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/gali/frame12_idx.bin"
.attr:
	INCBIN "assets/gali/frame12_attr.bin"
; Phenix BG animation frames (CopyBgMap descriptors), drawn by the
; scene VM (SCENE_BG_DRAW) by label; maps compiled from
; assets/scene/phenix/frames.tmx (one Tiled layer pair per frame).
PhenixFrame00:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/phenix/frame00_idx.bin"
.attr:
	INCBIN "assets/phenix/frame00_attr.bin"
PhenixFrame01:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/phenix/frame01_idx.bin"
.attr:
	INCBIN "assets/phenix/frame01_attr.bin"
PhenixFrame02:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/phenix/frame02_idx.bin"
.attr:
	INCBIN "assets/phenix/frame02_attr.bin"
PhenixFrame03:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/phenix/frame03_idx.bin"
.attr:
	INCBIN "assets/phenix/frame03_attr.bin"
PhenixFrame04:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/phenix/frame04_idx.bin"
.attr:
	INCBIN "assets/phenix/frame04_attr.bin"
PhenixFrame05:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/phenix/frame05_idx.bin"
.attr:
	INCBIN "assets/phenix/frame05_attr.bin"
PhenixFrame06:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/phenix/frame06_idx.bin"
.attr:
	INCBIN "assets/phenix/frame06_attr.bin"
PhenixFrame07:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/phenix/frame07_idx.bin"
.attr:
	INCBIN "assets/phenix/frame07_attr.bin"
PhenixFrame08:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/phenix/frame08_idx.bin"
.attr:
	INCBIN "assets/phenix/frame08_attr.bin"
PhenixFrame09:
	db 12, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/phenix/frame09_idx.bin"
.attr:
	INCBIN "assets/phenix/frame09_attr.bin"
; Phenix metasprite defs (DrawMetasprite: count, {dy,dx,tile,attr});
; referenced by the scene-VM SHOW lists (SCENE_SPRITE_LIST) by label.
PhenixSprite00:
	db 2, 0, 0, $80, $00, 0, 8, $80, $20
PhenixSprite01:
	db 4, 0, 0, $82, $00, 0, 8, $84, $00, 0, 16, $84, $20, 0, 24, $82, $20
PhenixSprite02:
	db 6, 0, 0, $86, $00, 0, 8, $88, $00, 0, 16, $8a, $00, 0, 24, $8a, $20, 0, 32, $88, $20, 0, 40, $86, $20
PhenixSprite03:
	db 14, 0, 24, $92, $00, 0, 32, $96, $00, 0, 40, $96, $20, 0, 48, $92, $20, 8, 0, $8c, $00, 8, 8, $8e, $00, 8, 16, $90, $00, 8, 56, $90, $20, 8, 64, $8e, $20, 8, 72, $8c, $20, 16, 24, $94, $00, 16, 32, $98, $00, 16, 40, $98, $20, 16, 48, $94, $20
PhenixSprite04:
	db 16, 0, 16, $9e, $00, 0, 24, $a2, $00, 0, 32, $a6, $00, 0, 40, $a6, $20, 0, 48, $a2, $20, 0, 56, $9e, $20, 8, 0, $9a, $00, 8, 8, $9c, $00, 8, 64, $9c, $20, 8, 72, $9a, $20, 16, 16, $a0, $00, 16, 24, $a4, $00, 16, 32, $a8, $00, 16, 40, $a8, $20, 16, 48, $a4, $20, 16, 56, $a0, $20
PhenixSprite05:
	db 18, 0, 8, $ac, $00, 0, 16, $b0, $00, 0, 24, $b4, $00, 0, 32, $b8, $00, 0, 40, $b8, $20, 0, 48, $b4, $20, 0, 56, $b0, $20, 0, 64, $ac, $20, 8, 0, $aa, $00, 8, 72, $aa, $20, 16, 8, $ae, $00, 16, 16, $b2, $00, 16, 24, $b6, $00, 16, 32, $ba, $00, 16, 40, $ba, $20, 16, 48, $b6, $20, 16, 56, $b2, $20, 16, 64, $ae, $20
PhenixSprite06:
	db 8, 48, 0, $0c, $01, 48, 8, $14, $01, 48, 16, $1c, $01, 48, 24, $24, $01, 64, 0, $00, $01, 64, 8, $02, $01, 64, 16, $02, $21, 64, 24, $00, $21
PhenixSprite07:
	db 12, 32, 0, $08, $01, 32, 8, $10, $01, 32, 16, $18, $01, 32, 24, $20, $01, 48, 0, $0a, $01, 48, 8, $12, $01, 48, 16, $1a, $01, 48, 24, $22, $01, 64, 0, $00, $01, 64, 8, $02, $01, 64, 16, $02, $21, 64, 24, $00, $21
PhenixSprite08:
	db 20, 0, 0, $28, $01, 0, 8, $30, $01, 0, 16, $38, $01, 0, 24, $40, $01, 16, 0, $2a, $01, 16, 8, $32, $01, 16, 16, $3a, $01, 16, 24, $42, $01, 32, 0, $06, $01, 32, 8, $04, $01, 32, 16, $04, $21, 32, 24, $06, $21, 48, 0, $06, $01, 48, 8, $04, $01, 48, 16, $04, $21, 48, 24, $06, $21, 64, 0, $00, $01, 64, 8, $02, $01, 64, 16, $02, $21, 64, 24, $00, $21
PhenixSprite09:
	db 20, 0, 0, $0c, $01, 0, 8, $14, $01, 0, 16, $1c, $01, 0, 24, $24, $01, 16, 0, $0e, $01, 16, 8, $16, $01, 16, 16, $1e, $01, 16, 24, $26, $01, 32, 0, $06, $01, 32, 8, $04, $01, 32, 16, $04, $21, 32, 24, $06, $21, 48, 0, $06, $01, 48, 8, $04, $01, 48, 16, $04, $21, 48, 24, $06, $21, 64, 0, $00, $01, 64, 8, $02, $01, 64, 16, $02, $21, 64, 24, $00, $21
PhenixSprite10:
	db 20, 0, 0, $08, $01, 0, 8, $10, $01, 0, 16, $18, $01, 0, 24, $20, $01, 16, 0, $0a, $01, 16, 8, $12, $01, 16, 16, $1a, $01, 16, 24, $22, $01, 32, 0, $06, $01, 32, 8, $04, $01, 32, 16, $04, $21, 32, 24, $06, $21, 48, 0, $06, $01, 48, 8, $04, $01, 48, 16, $04, $21, 48, 24, $06, $21, 64, 0, $00, $01, 64, 8, $02, $01, 64, 16, $02, $21, 64, 24, $00, $21
PhenixSprite11:
	db 40, 40, 40, $2c, $01, 40, 48, $34, $01, 40, 56, $3c, $01, 40, 64, $44, $01, 40, 72, $48, $01, 40, 80, $50, $01, 40, 88, $58, $01, 40, 96, $60, $01, 40, 104, $68, $01, 56, 40, $2e, $01, 56, 48, $36, $01, 56, 56, $3e, $01, 56, 64, $46, $01, 56, 72, $4a, $01, 56, 80, $52, $01, 56, 88, $5a, $01, 56, 96, $62, $01, 56, 104, $6a, $01, 72, 40, $70, $01, 72, 48, $78, $01, 72, 56, $00, $09, 72, 64, $08, $09, 72, 72, $4c, $01, 72, 80, $54, $01, 72, 88, $5c, $01, 72, 96, $64, $01, 72, 104, $6c, $01, 88, 40, $72, $01, 88, 48, $7a, $01, 88, 56, $02, $09, 88, 64, $0a, $09, 88, 72, $4e, $01, 88, 80, $56, $01, 88, 88, $5e, $01, 88, 96, $66, $01, 88, 104, $6e, $01, 104, 40, $74, $01, 104, 48, $7c, $01, 104, 56, $04, $09, 104, 64, $0c, $09
PhenixSprite12:
	db 40, 32, 32, $2c, $01, 32, 40, $34, $01, 32, 48, $3c, $01, 32, 56, $44, $01, 32, 88, $48, $01, 32, 96, $50, $01, 32, 104, $58, $01, 32, 112, $60, $01, 32, 120, $68, $01, 48, 32, $2e, $01, 48, 40, $36, $01, 48, 48, $3e, $01, 48, 56, $46, $01, 48, 88, $4a, $01, 48, 96, $52, $01, 48, 104, $5a, $01, 48, 112, $62, $01, 48, 120, $6a, $01, 80, 32, $70, $01, 80, 40, $78, $01, 80, 48, $00, $09, 80, 56, $08, $09, 80, 88, $4c, $01, 80, 96, $54, $01, 80, 104, $5c, $01, 80, 112, $64, $01, 80, 120, $6c, $01, 96, 32, $72, $01, 96, 40, $7a, $01, 96, 48, $02, $09, 96, 56, $0a, $09, 96, 88, $4e, $01, 96, 96, $56, $01, 96, 104, $5e, $01, 96, 112, $66, $01, 96, 120, $6e, $01, 112, 32, $74, $01, 112, 40, $7c, $01, 112, 48, $04, $09, 112, 56, $0c, $09
PhenixSprite13:
	db 26, 16, 8, $10, $09, 16, 16, $18, $09, 16, 24, $20, $09, 16, 112, $76, $01, 16, 120, $7e, $01, 16, 128, $06, $09, 16, 136, $0e, $09, 32, 8, $12, $09, 32, 16, $1a, $09, 32, 24, $22, $09, 104, 8, $14, $09, 104, 16, $1c, $09, 104, 24, $24, $09, 104, 32, $2c, $09, 104, 120, $30, $09, 104, 128, $38, $09, 104, 136, $40, $09, 104, 144, $48, $09, 120, 8, $16, $09, 120, 16, $1e, $09, 120, 24, $26, $09, 120, 32, $2e, $09, 120, 120, $32, $09, 120, 128, $3a, $09, 120, 136, $42, $09, 120, 144, $4a, $09
