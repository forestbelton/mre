; Text-window UI graphics (ROM bank $19).
;
; The shared dialogue/text-box UI drawn under portrait scenes: 512 tiles -- the
; main set (TextUiTiles, loaded by home LoadTextUi) and the alt set
; (TextUiTilesAlt, LoadTextUiAlt; used by bodka/naji) -- both -> VRAM bank 0
; $8800. TextUiBoxMap (7x20 -> $9960) is the box-frame layout filling the rows
; under the 11-row portrait; TextUiPalettes = 8 BG + 8 OBJ -> wBgPalettes.
; The main set doubles as the BG tileset of Cox's house in the Cox flashback
; (CoxHouseMap in src/text/scripts/cox.asm). Editable source:
; assets/screen/textui/ -- the sheet PNG (both sets stacked, palettes embedded)
; + textui.tmx (the box-frame arrangement, mode: maplib).

SECTION "analyzed_0646ca", ROMX[$46ca], BANK[$19]

Data_19_46ca:
	db $ff

SECTION "analyzed_0646cb", ROMX[$46cb], BANK[$19]

TextUiTiles:                     ; main set -> VRAM bank 0 $8800 (LoadTextUi)
	INCBIN "assets/textui/tiles.bin", 0, 4096
TextUiTilesAlt:                  ; alt set (LoadTextUiAlt; bodka/naji scenes)
	INCBIN "assets/textui/tiles.bin", 4096, 4096

TextUiPalettes:                  ; $66cb: 8 BG + 8 OBJ -> wBgPalettes/wObjPalettes
	INCBIN "assets/textui/palette.bin"

TextUiBoxMap:                    ; CopyBgMap 7x20 -> $9960: the text-box frame
	db 7, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/textui/textui_idx.bin"
.attr:
	INCBIN "assets/textui/textui_attr.bin"

; Text-box OBJ overlays (DrawMetasprite: count, {dy,dx,tile,attr}; 8x16 OBJs
; from the loaded UI set -- continue-arrow / cursor pieces).
TextUiSprite0:
	db 2, 0, 0, $86, $06, 0, 8, $88, $06
TextUiSprite1:
	db 2, 0, 0, $8a, $06, 0, 8, $8c, $06
TextUiSprite2:
	db 1, 0, 0, $82, $07
TextUiSprite3:
	db 1, 8, 0, $82, $47
TextUiSprite4:
	db 1, 0, 0, $80, $27
TextUiSprite5:
	db 1, 0, 0, $80, $07
TextUiSprite6:
	db 2, 0, 0, $8e, $07, 0, 8, $90, $07
