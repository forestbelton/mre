; Assets for scene 7 of the bank-$05 scene engine (src/scene.asm): the monster
; CAPTURE animation -- the golden, engraved disc stone glowing/charging, played
; when you capture a monster with a disc stone. This is the shared wSceneState=7
; scene (hardcoded, not one of the per-monster reveal scenes 0-6).
; Palette, tileset, CopyBgMap descriptor frames, and metasprite defs.
; See docs/screen_tilemaps.md.
; The tile sheet + palette are the editable source assets/scene/<name>/tiles.png
; (both banks stacked, palettes embedded); tools/pngasset.py (mode: scene) splits
; them and passes the committed descriptor/metasprite data through to build/assets/<name>/.

SECTION "scene_capture", ROMX[$4000], BANK[$0e]

CaptureTiles:
	INCBIN "assets/summon/capture/tiles_bank0.2bpp"
	INCBIN "assets/summon/capture/tiles_bank1.2bpp"
CapturePalettes:
	INCBIN "assets/summon/capture/palette.bin"
; Capture BG animation frames (CopyBgMap descriptors), drawn by the
; scene VM (SCENE_BG_DRAW) by label; maps compiled from
; assets/scene/scene7/frames.tmx (one Tiled layer pair per frame).
CaptureFrame00:
	db 2, 4
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/capture/frame00_idx.bin"
.attr:
	INCBIN "assets/summon/capture/frame00_attr.bin"
CaptureFrame01:
	db 8, 8
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/summon/capture/frame01_idx.bin"
.attr:
	INCBIN "assets/summon/capture/frame01_attr.bin"
; Capture metasprite defs (DrawMetasprite: count, {dy,dx,tile,attr});
; referenced by the scene-VM SHOW lists (SCENE_SPRITE_LIST) by label.
CaptureSprite00:
	db 16, 0, 0, $00, $00, 0, 8, $08, $00, 0, 16, $08, $20, 0, 24, $00, $20, 16, 0, $02, $00, 16, 8, $0a, $00, 16, 16, $0a, $20, 16, 24, $02, $20, 32, 0, $04, $00, 32, 8, $0c, $00, 32, 16, $0c, $20, 32, 24, $04, $20, 48, 0, $06, $00, 48, 8, $0e, $00, 48, 16, $0e, $20, 48, 24, $06, $20
CaptureSprite01:
	db 14, 0, 0, $10, $00, 0, 8, $12, $00, 0, 16, $16, $00, 0, 24, $1a, $00, 0, 32, $1e, $00, 0, 40, $22, $00, 0, 48, $26, $00, 0, 56, $2a, $00, 16, 8, $14, $00, 16, 16, $18, $00, 16, 24, $1c, $00, 16, 32, $20, $00, 16, 40, $24, $00, 16, 48, $28, $00
CaptureSprite02:
	db 26, 0, 0, $2c, $00, 0, 8, $34, $00, 0, 32, $4a, $00, 0, 40, $52, $00, 16, 0, $2e, $00, 16, 8, $36, $00, 16, 16, $3e, $00, 16, 24, $44, $00, 16, 32, $4c, $00, 16, 40, $54, $00, 32, 0, $30, $00, 32, 8, $38, $00, 32, 16, $40, $00, 32, 24, $46, $00, 32, 32, $40, $00, 32, 40, $56, $00, 48, 0, $32, $00, 48, 8, $3a, $00, 48, 16, $40, $00, 48, 24, $40, $00, 48, 32, $4e, $00, 48, 40, $58, $00, 64, 8, $3c, $00, 64, 16, $42, $00, 64, 24, $48, $00, 64, 32, $50, $00
CaptureSprite03:
	db 17, 0, 8, $5a, $00, 0, 16, $62, $00, 0, 24, $6a, $00, 0, 32, $74, $00, 16, 8, $5c, $00, 16, 16, $64, $00, 16, 24, $6c, $00, 16, 32, $76, $00, 32, 8, $5e, $00, 32, 16, $40, $00, 32, 24, $40, $00, 32, 32, $78, $00, 48, 8, $60, $00, 48, 16, $66, $00, 48, 24, $6e, $00, 64, 16, $68, $00, 64, 24, $70, $00
CaptureSprite04:
	db 10, 0, 16, $7a, $00, 0, 24, $04, $08, 16, 16, $7c, $00, 16, 24, $06, $08, 32, 16, $7e, $00, 32, 24, $08, $08, 48, 16, $00, $08, 48, 24, $0a, $08, 64, 16, $02, $08, 64, 24, $0c, $08
CaptureSprite05:
	db 6, 32, 16, $0e, $08, 32, 24, $14, $08, 48, 16, $10, $08, 48, 24, $16, $08, 64, 16, $12, $08, 64, 24, $18, $08
CaptureSprite06:
	db 4, 16, 0, $e4, $01, 16, 8, $ec, $01, 16, 16, $f4, $01, 16, 24, $fc, $01
CaptureSprite07:
	db 8, 0, 0, $e0, $01, 0, 8, $e8, $01, 0, 16, $f0, $01, 0, 24, $f8, $01, 16, 0, $e2, $01, 16, 8, $ea, $01, 16, 16, $f2, $01, 16, 24, $fa, $01
CaptureSprite08:
	db 8, 0, 0, $c4, $01, 0, 8, $cc, $01, 0, 16, $d4, $01, 0, 24, $dc, $01, 16, 0, $c6, $01, 16, 8, $ce, $01, 16, 16, $d6, $01, 16, 24, $de, $01
CaptureSprite09:
	db 8, 0, 0, $80, $01, 0, 8, $88, $01, 0, 16, $90, $01, 0, 24, $98, $01, 16, 0, $82, $01, 16, 8, $8a, $01, 16, 16, $92, $01, 16, 24, $9a, $01
CaptureSprite10:
	db 8, 0, 0, $84, $01, 0, 8, $8c, $01, 0, 16, $94, $01, 0, 24, $9c, $01, 16, 0, $86, $01, 16, 8, $8e, $01, 16, 16, $96, $01, 16, 24, $9e, $01
CaptureSprite11:
	db 4, 0, 8, $e6, $01, 0, 16, $ee, $01, 16, 8, $f6, $01, 16, 16, $fe, $01
CaptureSprite12:
	db 8, 0, 0, $bc, $21, 0, 8, $b4, $21, 0, 16, $ac, $21, 0, 24, $a4, $21, 16, 0, $be, $21, 16, 8, $b6, $21, 16, 16, $ae, $21, 16, 24, $a6, $21
CaptureSprite13:
	db 8, 0, 0, $a0, $01, 0, 8, $a8, $01, 0, 16, $b0, $01, 0, 24, $b8, $01, 16, 0, $a2, $01, 16, 8, $aa, $01, 16, 16, $b2, $01, 16, 24, $ba, $01
CaptureSprite14:
	db 8, 0, 0, $a4, $01, 0, 8, $ac, $01, 0, 16, $b4, $01, 0, 24, $bc, $01, 16, 0, $a6, $01, 16, 8, $ae, $01, 16, 16, $b6, $01, 16, 24, $be, $01
CaptureSprite15:
	db 4, 0, 8, $e6, $01, 0, 16, $ee, $01, 16, 8, $f6, $01, 16, 16, $fe, $01
CaptureSprite16:
	db 8, 0, 0, $c0, $01, 0, 8, $c8, $01, 0, 16, $d0, $01, 0, 24, $d8, $01, 16, 0, $c2, $01, 16, 8, $ca, $01, 16, 16, $d2, $01, 16, 24, $da, $01
