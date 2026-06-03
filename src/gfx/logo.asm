; TECMO logo graphics data -- the image shown on the first boot screen.
; The renderer that draws and fades it lives in src/logo.asm (DrawTecmoLogo).
;
; Assembled from the editable source under assets/tecmo_logo/ by
; tools/gfxasset.py (run in the Makefile, output under build/assets/). The
; components are pinned to their original bank-$27 offsets so the build stays
; byte-exact, but the map descriptor references the two maps by *label* (dw) --
; so this region would relocate cleanly if the offsets were ever dropped
; (see docs/philosophy.md).

SECTION "TecmoLogoTiles", ROMX[$5000], BANK[$27]
TecmoLogoTiles:
	INCBIN "assets/tecmo_logo/tiles.bin"       ; 128 tiles; land at VRAM $9000 ($8800 mode)

SECTION "TecmoLogoPalette", ROMX[$5800], BANK[$27]
TecmoLogoPalette:
	INCBIN "assets/tecmo_logo/palette.bin"     ; 1 BG palette: white / gray / gray / red

SECTION "TecmoLogoMapDesc", ROMX[$5808], BANK[$27]
TecmoLogoMapDesc:
	db 18, 20                                   ; rows, cols
	dw TecmoLogoAttrMap                          ; CGB attribute map pointer
	dw TecmoLogoIndexMap                         ; tile index map pointer

SECTION "TecmoLogoIndexMap", ROMX[$580e], BANK[$27]
TecmoLogoIndexMap:
	INCBIN "assets/tecmo_logo/tilemap.bin"     ; 20x18 tile indices

SECTION "TecmoLogoAttrMap", ROMX[$5976], BANK[$27]
TecmoLogoAttrMap:
	INCBIN "assets/tecmo_logo/attrmap.bin"     ; 20x18 CGB BG attributes
