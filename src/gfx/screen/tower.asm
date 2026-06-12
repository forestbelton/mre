; tower entrance (door closed) -- drawn by DrawTowerEntranceScreen (bank $30). Generated from the single editable image
; assets/tower/tower_entrance.png by tools/pngasset.py (screen mode, via assets.yaml): both
; VRAM banks stacked + the 16 CGB palettes embedded. The map descriptor references
; the maps by label (dw). See docs/gfx_assets.md.

SECTION "TowerEntranceTiles bank0", ROMX[$4000], BANK[$22]
TowerEntranceTilesBank0:
	INCBIN "assets/screen/tower/tiles_bank0.bin"   ; 384 tiles -> VRAM bank 0 $8000

TowerEntranceTilesBank1:
	INCBIN "assets/screen/tower/tiles_bank1.bin"   ; 384 tiles -> VRAM bank 1 $8000

TowerEntrancePalettes:
	INCBIN "assets/screen/tower/palette.bin"       ; 8 BG + 8 OBJ palettes (RGB555 LE)

TowerEntranceMapDesc:
	db 18, 20
	dw TowerEntranceAttrMap
	dw TowerEntranceIdxMap

TowerEntranceIdxMap:
	INCBIN "assets/screen/tower/tilemap.bin"

TowerEntranceAttrMap:
	INCBIN "assets/screen/tower/attrmap.bin"

SECTION "analyzed_08b356", ROMX[$7356], BANK[$22]

Data_22_7356:
	db $14, $48, $20, $34, $01, $48, $78, $38, $01, $58, $18, $30, $01, $58, $20, $36
	db $01, $58, $78, $3a, $01, $58, $80, $3c, $01, $68, $18, $32, $01, $68, $80, $3e
	db $01, $70, $00, $00, $02, $70, $08, $02, $02, $70, $90, $24, $02, $78, $98, $26
	db $02, $80, $30, $0c, $02, $80, $38, $0e, $02, $80, $40, $10, $02, $80, $48, $12
	db $02, $80, $50, $14, $02, $80, $58, $16, $02, $80, $60, $18, $02, $80, $68, $1a
	db $02, $08, $0a, $fd, $73, $ad, $73, $80, $87, $8f, $97, $9f, $9f, $97, $8f, $87
	db $80, $81, $88, $90, $98, $a0, $a0, $98, $90, $88, $81, $82, $89, $91, $99, $a1
	db $a1, $99, $91, $89, $82, $83, $8a, $92, $9a, $a1, $a1, $9a, $92, $8a, $83, $84
	db $8b, $93, $9b, $a1, $a1, $9b, $93, $8b, $84, $85, $8c, $94, $9c, $a1, $a1, $9c
	db $94, $8c, $85, $86, $8d, $95, $9d, $a1, $a1, $9d, $95, $8d, $86, $4c, $8e, $96
	db $9e, $a2, $a2, $9e, $96, $8e, $4e, $04, $04, $04, $04, $04, $24, $24, $24, $24
	db $24, $04, $04, $04, $04, $04, $24, $24, $24, $24, $24, $04, $04, $04, $04, $04
	db $24, $24, $24, $24, $24, $04, $04, $04, $04, $04, $24, $24, $24, $24, $24, $04
	db $04, $04, $04, $04, $24, $24, $24, $24, $24, $04, $04, $04, $04, $04, $24, $24
	db $24, $24, $24, $04, $04, $04, $04, $04, $24, $24, $24, $24, $24, $0b, $04, $04
	db $04, $04, $24, $24, $24, $24, $0b, $08, $0a, $a3, $74, $53, $74, $a3, $aa, $b2
	db $ba, $9f, $9f, $ba, $b2, $aa, $a3, $a4, $ab, $b3, $bb, $a1, $a1, $bb, $b3, $ab
	db $a4, $a5, $ac, $b4, $bc, $a1, $a1, $bc, $b4, $ac, $a5, $a6, $ad, $b5, $bd, $a1
	db $a1, $bd, $b5, $ad, $a6, $a7, $ae, $b6, $be, $a1, $a1, $be, $b6, $ae, $a7, $a8
	db $af, $b7, $bf, $a1, $a1, $bf, $b7, $af, $a8, $a9, $b0, $b8, $c0, $a1, $a1, $c0
	db $b8, $b0, $a9, $4c, $b1, $b9, $c1, $a2, $a2, $c1, $b9, $b1, $4e, $00, $04, $04
	db $04, $04, $24, $24, $24, $24, $20, $00, $04, $04, $04, $04, $24, $24, $24, $24
	db $20, $00, $04, $04, $04, $04, $24, $24, $24, $24, $20, $00, $04, $04, $04, $04
	db $24, $24, $24, $24, $20, $00, $04, $04, $04, $04, $24, $24, $24, $24, $20, $00
	db $04, $04, $04, $04, $24, $24, $24, $24, $20, $00, $04, $04, $04, $04, $24, $24
	db $24, $24, $20, $0b, $04, $04, $04, $04, $24, $24, $24, $24, $0b, $08, $0a, $49
	db $75, $f9, $74, $c2, $c9, $d0, $ba, $9f, $9f, $ba, $d0, $c9, $c2, $c3, $ca, $d1
	db $a1, $a1, $a1, $a1, $d1, $ca, $c3, $c4, $cb, $d2, $a1, $a1, $a1, $a1, $d2, $cb
	db $c4, $c5, $cc, $d3, $a1, $a1, $a1, $a1, $d3, $cc, $c5, $c6, $cd, $d4, $a1, $a1
	db $a1, $a1, $d4, $cd, $c6, $c7, $ce, $d5, $a1, $a1, $a1, $a1, $d5, $ce, $c7, $c8
	db $cf, $d6, $a1, $a1, $a1, $a1, $d6, $cf, $c8, $4c, $b1, $b9, $c1, $a2, $a2, $c1
	db $b9, $b1, $4d, $00, $04, $04, $24, $04, $24, $04, $24, $24, $20, $00, $04, $04
	db $04, $04, $24, $24, $24, $24, $20, $00, $04, $04, $04, $04, $24, $24, $24, $24
	db $20, $00, $04, $04, $04, $04, $24, $24, $24, $24, $20, $00, $04, $04, $04, $04
	db $24, $24, $24, $24, $20, $00, $04, $04, $04, $04, $24, $24, $24, $24, $20, $00
	db $04, $04, $04, $04, $24, $24, $24, $24, $20, $0b, $04, $04, $04, $04, $24, $24
	db $24, $24, $0b, $04, $00, $10, $28, $00, $00, $18, $2a, $00, $00, $30, $2c, $00
	db $00, $38, $2e, $00, $02, $00, $10, $40, $00, $00, $38, $40, $20, $02, $00, $10
	db $42, $00, $00, $38, $42, $20, $04, $00, $08, $44, $00, $00, $10, $46, $00, $00
	db $38, $46, $20, $00, $40, $44, $20, $a7, $73, $4d, $74, $f3, $74, $aa, $75, $b3
	db $75, $bc, $75, $99, $75

; ($23:$7000 BG/OBJ palettes carved into the screen asset as RoomStartPalettes.)

