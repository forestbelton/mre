; Nada's scene graphics -- two full-screen (11x20) two-VRAM-bank CGB images.
; Both load their tile sheets to VRAM $8000 in different banks (the attr map's
; bit 3 selects the bank per cell). The two scenes share their bank-0 sheet
; (NadaIntroTilesBank0), so they are kept together here. Located via
; tools/find_portraits.py.
;
; Assembled from the editable sources under assets/portrait/nada_intro/ and
; assets/portrait/nada_scene2/ by tools/pngasset.py (Makefile, output under
; build/assets/). The 6 BG + 6 OBJ palettes (loaded by Nada_ShowScene from
; $1c:$7000/$7040) are carved into the intro scene below; the second pose reuses
; them, so its PNG is colourised but owns no palette bytes.

; --- Intro scene (shown by Func_1f_4d97 early in her script) ---------------
; Bank 0 sheet $1c:$4000, bank 1 sheet $1c:$5800.

SECTION "Nada graphics", ROMX

NadaIntroTilesBank0:
	INCBIN "assets/nada_intro/tiles2.bin"   ; 384 tiles -> VRAM bank 0 $8000

NadaIntroTiles:
	INCBIN "assets/nada_intro/tiles.bin"    ; 384 tiles -> VRAM bank 1 $8000

NadaIntroPaletteBg:
	INCBIN "assets/nada_intro/palette_bg.bin"   ; 6 BG palettes (RGB555 LE)

Data_1c_7030:
	db $ff, $7f, $3e, $1b, $37, $01, $4b, $00, $ff, $7f, $94, $52, $4a, $29, $00, $00

NadaIntroPaletteObj:
	INCBIN "assets/nada_intro/palette_obj.bin"  ; 6 OBJ palettes (RGB555 LE)

Data_1c_7070:
	db $e0, $03, $94, $52, $4a, $29, $00, $00, $00, $7c, $3e, $1b, $37, $01, $4b, $00

NadaIntroMapDesc:
	db 11, 20                                ; rows, cols
	dw NadaIntroAttrMap                       ; CGB attribute map pointer
	dw NadaIntroIndexMap                      ; tile index map pointer

NadaIntroIndexMap:
	INCBIN "assets/nada_intro/tilemap.bin"  ; 20x11 tile indices

NadaIntroAttrMap:
	INCBIN "assets/nada_intro/attrmap.bin"  ; 20x11 CGB BG attributes (bit 3 = VRAM bank)

; Overlay region ($723e-$7755), shared by both scenes: Nada's 7-frame snap animation
; (snap_body0..6 two-bank 5x9 patch + snap_hand0..6 metasprite each, intro-only -- the
; body patch is authored against the intro sheet; the bank-$1f Func_1f_4fb2 ping-pong
; dispatch drives it), her talking mouth/face (mouth_frame0..2 + face_frame0..2), and the
; angry/rage expression (mouth_angry/face_angry + the monster_eye red glow NadaPortraitInit
; draws). Layered PNG source in assets/portrait/nada_intro/sprites/ (docs/portrait_overlays.md).
	INCLUDE "assets/nada_intro/sprites.asm"   ; Nada_<role> blocks

; --- Second pose (shown by Func_1f_4e65 -- Nada with a summoned monster) -----
; Shares the bank-0 sheet above (NadaIntroTilesBank0); owns only the bank-1
; sheet $1f:$6607 plus its descriptor/maps. Editable bank-0 tiles live in
; assets/nada_intro/.

SECTION "Nada graphics 2", ROMX

NadaScene2Tiles:
	INCBIN "assets/nada_scene2/tiles.bin"     ; 384 tiles -> VRAM bank 1 $8000

NadaScene2MapDesc:
	db 11, 20                                  ; rows, cols
	dw NadaScene2AttrMap                        ; CGB attribute map pointer
	dw NadaScene2IndexMap                       ; tile index map pointer

NadaScene2IndexMap:
	INCBIN "assets/nada_scene2/tilemap.bin"   ; 20x11 tile indices

NadaScene2AttrMap:
	INCBIN "assets/nada_scene2/attrmap.bin"   ; 20x11 CGB BG attributes (bit 3 = VRAM bank)
