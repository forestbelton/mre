; TECMO logo graphics data -- the image shown on the first boot screen.
; The renderer that draws and fades it lives in src/logo.asm (DrawTecmoLogo).
;
; Generated from the single source image assets/logo/logo.png by tools/pngasset.py
; (run in the Makefile, output under build/assets/logo/). The PNG is the only
; committed source; tiles, palette, tilemap and attribute map are all
; reconstructed from it byte-exact -- including the $1000 blank-tile block before
; the sheet (pngasset --pad-before). The map descriptor references the two maps by
; *label* (dw), so this region would relocate cleanly if the offsets were ever
; dropped (see docs/philosophy.md).

SECTION "TECMO logo graphics", ROMX

TecmoLogoTiles:
	INCBIN "assets/logo/tiles.bin"             ; $1000 blank + 128 logo tiles -> VRAM $8000 ($8800 mode)
TecmoLogoTilesEnd:

TecmoLogoPalette:
	INCBIN "assets/logo/palette.bin"           ; 1 BG palette: white / gray / gray / red

TecmoLogoMapDesc:
	db 18, 20                                   ; rows, cols
	dw TecmoLogoAttrMap                          ; CGB attribute map pointer
	dw TecmoLogoIndexMap                         ; tile index map pointer

TecmoLogoIndexMap:
	INCBIN "assets/logo/tilemap.bin"           ; 20x18 tile indices

TecmoLogoAttrMap:
	INCBIN "assets/logo/attrmap.bin"           ; 20x18 CGB BG attributes

Data_27_5ade:
	INCBIN "gfx/raw/Data_27_5ade.2bpp", 0, 5408
