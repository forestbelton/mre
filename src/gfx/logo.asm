; TECMO logo graphics data -- the image shown on the first boot screen.
; The renderer that draws and fades it lives in src/logo.asm (DrawTecmoLogo).
;
; Assembled from the editable source under assets/tecmo_logo/ by
; tools/gfxasset.py (run in the Makefile, output under build/assets/). The
; components are pinned to their original bank-$27 offsets so the build stays
; byte-exact, but the map descriptor references the two maps by *label* (dw) --
; so this region would relocate cleanly if the offsets were ever dropped
; (see docs/philosophy.md).

SECTION "TECMO logo graphics", ROMX

TecmoLogoTiles:
	INCBIN "raw_gfx/IntroBlankTiles.2bpp", 0, 4096
	INCBIN "assets/tecmo_logo/tiles.bin"       ; 128 tiles; land at VRAM $9000 ($8800 mode)

TecmoLogoPalette:
	INCBIN "assets/tecmo_logo/palette.bin"     ; 1 BG palette: white / gray / gray / red

TecmoLogoMapDesc:
	db 18, 20                                   ; rows, cols
	dw TecmoLogoAttrMap                          ; CGB attribute map pointer
	dw TecmoLogoIndexMap                         ; tile index map pointer

TecmoLogoIndexMap:
	INCBIN "assets/tecmo_logo/tilemap.bin"     ; 20x18 tile indices

TecmoLogoAttrMap:
	INCBIN "assets/tecmo_logo/attrmap.bin"     ; 20x18 CGB BG attributes

Data_27_5ade:
	INCBIN "raw_gfx/Data_27_5ade.2bpp", 0, 5408

Data_27_6ffe:
	db $00, $00
