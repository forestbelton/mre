; Tradehouse / Bodka note screen (ROM bank $33).
;
; Two portrait-converter screens (family G, docs/asset_source_model.md): the
; studio/trade view and the note scene, each a 384-tile set -> VRAM bank 1
; $8000 with an 11x20 standard-layout map (derived from the sheet by the
; build; assets/screen/tradehouse_*/). Shared 6 BG + 6 OBJ palettes. Loaded by
; text/scripts/bodka.asm (Tradehouse_BuildScene / Tradehouse_BuildNoteScene).

SECTION "analyzed_0cc000", ROMX[$4000], BANK[$33]

TradehouseStudioTiles:           ; studio set -> VRAM bank 1 $8000
	INCBIN "assets/screen/tradehouse_studio/tiles.bin"
TradehouseNoteTiles:             ; note-scene set -> VRAM bank 1 $8000
	INCBIN "assets/screen/tradehouse_note/tiles.bin"

TradehousePalettesBg:            ; $7000: 6 BG palettes -> wBgPalettes
	INCBIN "assets/screen/tradehouse_studio/palette_bg.bin"
	db $e0, $03, $e0, $03, $e0, $03, $e0, $03, $e0, $03, $e0, $03, $e0, $03, $e0, $03   ; $7030: filler palette slots (never copied)
TradehousePalettesObj:           ; $7040: 6 OBJ palettes -> wObjPalettes
	INCBIN "assets/screen/tradehouse_studio/palette_obj.bin"

SECTION "analyzed_0cf080", ROMX[$7080], BANK[$33]

TradehouseStudioMap:             ; CopyBgMap 11x20 -> $9800 (the studio screen)
	db 11, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/screen/tradehouse_studio/tilemap.bin"
.attr:
	INCBIN "assets/screen/tradehouse_studio/attrmap.bin"

TradehouseNoteMap:               ; CopyBgMap 11x20 -> $9800 (the note scene)
	db 11, 20
	dw .attr
	dw .idx
.idx:
	INCBIN "assets/screen/tradehouse_note/tilemap.bin"
.attr:
	INCBIN "assets/screen/tradehouse_note/attrmap.bin"

; Note-scene animation frames (DrawMetasprite: count, {dy,dx,tile,attr};
; 8x16 OBJs from the note tile set, referenced by the bank-$18 renderer).
TradehouseNoteSprite0:
	db 2, 0, 0, $00, $08, 0, 8, $02, $08
TradehouseNoteSprite1:
	db 2, 0, 0, $04, $08, 0, 8, $06, $08
TradehouseNoteSprite2:
	db 2, 0, 0, $08, $08, 0, 8, $0a, $08
TradehouseNoteSprite3:
	db 2, 0, 0, $0c, $08, 0, 8, $0e, $08
TradehouseNoteSprite4:
	db 2, 0, 0, $10, $08, 0, 8, $12, $08
TradehouseNoteSprite5:
	db 0, 
TradehouseNoteSprite6:
	db 0, 
TradehouseNoteSprite7:
	db 0, 
TradehouseNoteSprite8:
	db 0, 
TradehouseNoteSprite9:
	db 0, 
TradehouseNoteSprite10:
	db 0, 
TradehouseNoteSprite11:
	db 0, 
TradehouseNoteSprite12:
	db 0, 
TradehouseNoteSprite13:
	db 0, 
TradehouseNoteSprite14:
	db 0, 
TradehouseNoteSprite15:
	db 0, 
TradehouseNoteSprite16:
	db 0, 
