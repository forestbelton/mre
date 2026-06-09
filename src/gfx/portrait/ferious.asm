; Ferious, the monster Mistral summons ("Ferious! Come!"). A two-VRAM-bank CGB
; portrait: the loader (Func_1f_4416) copies these 384 tiles to VRAM bank 1 $8000
; and the 128 bank-0 tiles to VRAM bank 0 $9000; the attr map's bit 3 selects the
; tile bank per cell. Located by following Mistral's script far-calls
; (tools/find_portraits.py).
;
; Assembled from the editable source under assets/portrait/ferious/ by
; tools/pngasset.py (Makefile, output under build/assets/). The 6 BG + 6 OBJ
; palettes (loaded by Mistral_StartEncounter from $35:$6000/$6040) are carved here
; from the PNG's colour table.

SECTION "Mistral graphics", ROMX

FeriousPortraitTilesBank0:
	INCBIN "assets/ferious/tiles2.bin"   ; 128 tiles -> VRAM bank 0 $9000

FeriousPortraitTiles:
	INCBIN "assets/ferious/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

FeriousPortraitPaletteBg:
	INCBIN "assets/ferious/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

Data_35_6030:
	DB $ff, $7f, $3e, $1b, $37, $01, $4b, $00
	DB $ff, $7f, $94, $52, $4a, $29, $00, $00

FeriousPortraitPaletteObj:
	INCBIN "assets/ferious/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

Data_35_6070:
	DB $ff, $7f, $94, $52, $4a, $29, $00, $00
	DB $ff, $7f, $3e, $1b, $37, $01, $4b, $00

FeriousPortraitMapDesc:
	db 11, 20                                      ; rows, cols
	dw FeriousPortraitAttrMap                       ; CGB attribute map pointer
	dw FeriousPortraitIndexMap                      ; tile index map pointer

FeriousPortraitIndexMap:
	INCBIN "assets/ferious/tilemap.bin"  ; 20x11 tile indices

FeriousPortraitAttrMap:
	INCBIN "assets/ferious/attrmap.bin"  ; 20x11 CGB BG attributes (bit 3 = VRAM bank)

SECTION "analyzed_0d623e", ROMX[$623e], BANK[$35]

Data_35_623e:
	db $08, $09, $8c, $62, $44, $62, $da, $e2, $ea, $f2, $fa, $02, $0a, $12, $80, $db
	db $e3, $eb, $f3, $fb, $03, $0b, $13, $80, $dc, $e4, $ec, $f4, $fc, $04, $0c, $14
	db $80, $dd, $e5, $ed, $f5, $fd, $05, $0d, $15, $1d, $de, $e6, $ee, $f6, $fe, $06
	db $0e, $16, $1e, $80, $e7, $ef, $f7, $ff, $07, $0f, $17, $1f, $80, $43, $4b, $53
	db $5b, $26, $2e, $36, $3e, $3c, $44, $4c, $54, $5c, $27, $2f, $37, $3f, $08, $09
	db $09, $09, $09, $09, $09, $09, $08, $08, $0a, $0a, $0a, $0a, $09, $09, $09, $08
	db $0a, $0a, $0a, $0a, $0a, $0a, $09, $09, $08, $0a, $0a, $0a, $0a, $0a, $0a, $0a
	db $09, $09, $08, $0a, $0a, $0a, $0a, $0a, $0a, $09, $09, $08, $0a, $0a, $0a, $0a
	db $0a, $09, $09, $09, $08, $0a, $0a, $0b, $0b, $0b, $0d, $0d, $09, $0d, $0d, $0c
	db $0d, $0d, $0d, $0d, $0d, $0d, $04, $00, $00, $00, $0b, $00, $08, $16, $0b, $10
	db $00, $18, $0b, $10, $08, $1a, $0b, $04, $00, $00, $00, $0a, $00, $08, $26, $0a
	db $10, $00, $28, $0a, $10, $08, $2a, $0a, $0c, $00, $00, $46, $08, $00, $08, $48
	db $08, $00, $10, $4a, $08, $00, $18, $4c, $08, $10, $00, $4e, $08, $10, $08, $00
	db $09, $10, $10, $50, $09, $10, $18, $52, $09, $20, $00, $00, $08, $20, $08, $54
	db $09, $20, $10, $56, $09, $20, $18, $00, $09, $03, $00, $00, $34, $0b, $00, $08
	db $36, $0b, $00, $10, $38, $0b, $08, $09, $82, $63, $3a, $63, $da, $42, $49, $50
	db $fa, $02, $60, $67, $80, $db, $43, $4a, $51, $55, $5a, $61, $68, $80, $40, $44
	db $4b, $52, $56, $5b, $62, $69, $80, $41, $45, $4c, $53, $57, $5c, $63, $6a, $1d
	db $de, $46, $ee, $f6, $58, $5d, $64, $6b, $6e, $80, $47, $4d, $f7, $59, $5e, $65
	db $6c, $6f, $80, $48, $4e, $54, $5b, $5f, $66, $6d, $56, $3c, $44, $4f, $54, $5c
	db $27, $2f, $37, $3f, $08, $01, $01, $01, $09, $09, $01, $01, $08, $08, $02, $02
	db $02, $02, $01, $01, $01, $08, $02, $02, $02, $02, $02, $02, $01, $01, $08, $02
	db $02, $02, $02, $02, $02, $02, $01, $09, $08, $02, $0a, $0a, $02, $02, $02, $01
	db $01, $08, $02, $02, $0a, $02, $02, $02, $01, $01, $08, $02, $02, $03, $0b, $03
	db $05, $05, $09, $0d, $0d, $04, $0d, $0d, $0d, $0d, $0d, $0d, $04, $00, $00, $1c
	db $0b, $00, $08, $1e, $0b, $10, $00, $20, $0b, $10, $08, $00, $0b, $02, $00, $00
	db $2c, $0a, $10, $00, $2e, $0a, $0c, $00, $00, $58, $08, $00, $08, $5a, $08, $00
	db $10, $5c, $08, $00, $18, $5e, $08, $10, $00, $60, $08, $10, $08, $00, $09, $10
	db $10, $62, $09, $10, $18, $64, $09, $20, $00, $00, $08, $20, $08, $66, $09, $20
	db $10, $68, $09, $20, $18, $00, $09, $03, $00, $00, $3a, $0b, $00, $08, $3c, $0b
	db $00, $10, $3e, $0b, $08, $09, $70, $64, $28, $64, $da, $5f, $66, $6d, $fa, $02
	db $7d, $88, $80, $db, $60, $67, $6e, $72, $77, $7e, $89, $80, $57, $61, $68, $6f
	db $73, $78, $7f, $8a, $80, $5e, $62, $69, $70, $74, $79, $81, $91, $1d, $de, $63
	db $ee, $f6, $75, $7a, $82, $92, $9b, $80, $64, $6a, $f7, $76, $7b, $83, $99, $d0
	db $80, $65, $6b, $71, $5b, $7c, $84, $9a, $f1, $3c, $44, $6c, $54, $5c, $27, $2f
	db $37, $3f, $08, $09, $09, $09, $09, $09, $09, $09, $08, $08, $0a, $0a, $0a, $09
	db $09, $09, $09, $08, $0a, $0a, $0a, $0a, $0a, $0a, $09, $09, $08, $0a, $0a, $0a
	db $0a, $0a, $0a, $0a, $09, $09, $08, $0a, $0a, $0a, $0a, $0a, $0a, $09, $09, $08
	db $0a, $0a, $0a, $0a, $0a, $09, $09, $09, $08, $0a, $0a, $0b, $0b, $0b, $0d, $0d
	db $09, $0d, $0d, $0c, $0d, $0d, $0d, $0d, $0d, $0d, $02, $00, $00, $22, $0b, $10
	db $00, $24, $0b, $02, $00, $00, $30, $0a, $10, $00, $32, $0a, $0c, $00, $00, $6a
	db $08, $00, $08, $6c, $08, $00, $10, $6e, $08, $00, $18, $70, $08, $10, $00, $72
	db $08, $10, $08, $00, $09, $10, $10, $74, $09, $10, $18, $76, $09, $20, $00, $00
	db $08, $20, $08, $78, $09, $20, $10, $7a, $09, $20, $18, $00, $09, $03, $00, $00
	db $40, $0b, $00, $08, $42, $0b, $00, $10, $44, $0b, $0a, $00, $00, $00, $08, $00
	db $08, $02, $08, $00, $10, $04, $08, $00, $18, $06, $08, $00, $20, $08, $08, $10
	db $00, $0a, $08, $10, $08, $0c, $08, $10, $10, $0e, $08, $10, $18, $10, $08, $10
	db $20, $12, $08, $01, $00, $00, $14, $0d

