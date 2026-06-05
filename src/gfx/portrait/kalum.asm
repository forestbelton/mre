; Kalum's encounter portrait (tower NPC). Drawn by Kalum_StartEncounter
; ($1f:$417b): the tiles are copied to VRAM bank 1 $8000 ($8800 signed tile
; addressing) and arranged by the CopyBgMap descriptor below over the top
; 20x11 cells; see docs/text_engine.md.
;
; Assembled from the editable source under assets/portrait/kalum/ by
; tools/pngasset.py (`portrait` mode, run in the Makefile, output under
; build/assets/). The descriptor references the two maps by *label* (dw), so the
; region is internally relocatable (docs/philosophy.md). The 6 BG + 6 OBJ palettes
; (loaded by Kalum_StartEncounter from $1d:$5800/$5840) are carved here from the
; PNG's colour table, so the portrait carries its real colour.

SECTION "Kalum graphics", ROMX

KalumPortraitTiles:
	INCBIN "assets/kalum/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

KalumPortraitPaletteBg:
	INCBIN "assets/kalum/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

DS $10, 0

KalumPortraitPaletteObj:
	INCBIN "assets/kalum/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

DS $10, 0

KalumPortraitMapDesc:
	db 11, 20                                    ; rows, cols
	dw KalumPortraitAttrMap                       ; CGB attribute map pointer
	dw KalumPortraitIndexMap                      ; tile index map pointer

KalumPortraitIndexMap:
	INCBIN "assets/kalum/tilemap.bin"  ; 20x11 tile indices

KalumPortraitAttrMap:
	INCBIN "assets/kalum/attrmap.bin"  ; 20x11 CGB BG attributes

Data_1d_5a3e:
	db $02, $03, $4a, $5a, $44, $5a, $ec, $f4, $fc, $ed, $f5, $fd, $0b, $0b, $0b, $0a
	db $0a, $0a, $0c, $00, $00, $04, $08, $00, $08, $06, $08, $00, $10, $08, $08, $00
	db $18, $0a, $08, $10, $00, $0c, $08, $10, $08, $0e, $08, $10, $10, $10, $08, $10
	db $18, $12, $08, $20, $00, $14, $08, $20, $08, $16, $08, $20, $10, $18, $08, $20
	db $18, $1a, $08, $02, $03, $8d, $5a, $87, $5a, $56, $5e, $60, $57, $5f, $61, $0b
	db $0b, $0b, $0b, $0b, $0b, $0c, $00, $00, $04, $08, $00, $08, $06, $08, $00, $10
	db $08, $08, $00, $18, $0a, $08, $10, $00, $0c, $08, $10, $08, $20, $08, $10, $10
	db $22, $08, $10, $18, $24, $08, $20, $00, $14, $08, $20, $08, $16, $08, $20, $10
	db $18, $08, $20, $18, $1a, $08, $02, $03, $d0, $5a, $ca, $5a, $62, $64, $66, $63
	db $65, $67, $0b, $0b, $0b, $0b, $0b, $0b, $0c, $00, $00, $04, $08, $00, $08, $06
	db $08, $00, $10, $08, $08, $00, $18, $0a, $08, $10, $00, $0c, $08, $10, $08, $26
	db $08, $10, $10, $28, $08, $10, $18, $2a, $08, $20, $00, $14, $08, $20, $08, $16
	db $08, $20, $10, $18, $08, $20, $18, $1a, $08, $02, $00, $00, $1c, $08, $00, $08
	db $1e, $08, $02, $00, $00, $00, $0d, $00, $08, $02, $0d
