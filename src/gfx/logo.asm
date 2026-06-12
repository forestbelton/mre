; TECMO logo graphics data -- the image shown on the first boot screen.
; The renderer that draws and fades it lives in src/logo.asm (DrawTecmoLogo).
;
; Editable source: assets/logo.png (the 128-tile sheet) + assets/logo.tmx (the
; 20x18 arrangement, mode: maplib -- open it in Tiled to see the logo). The map
; descriptor references the maps by *label* (dw), so this region would relocate
; cleanly if the offsets were ever dropped (see docs/philosophy.md).

SECTION "TECMO logo graphics", ROMX

TecmoLogoTiles:
	ds $1000                                   ; blank lead-in tiles (cleared VRAM block)
	INCBIN "assets/logo/tiles.bin"             ; 128 logo tiles -> VRAM $9000 ($8800 mode)
TecmoLogoTilesEnd:

TecmoLogoPalette:
	INCBIN "assets/logo/palette.bin"           ; 1 BG palette: white / gray / gray / red

TecmoLogoMapDesc:
	db 18, 20                                   ; rows, cols
	dw TecmoLogoAttrMap                          ; CGB attribute map pointer
	dw TecmoLogoIndexMap                         ; tile index map pointer

TecmoLogoIndexMap:
	INCBIN "assets/logo/logo_idx.bin"           ; 20x18 tile indices

TecmoLogoAttrMap:
	INCBIN "assets/logo/logo_attr.bin"           ; 20x18 CGB BG attributes

Data_27_5ade:
	INCBIN "gfx/raw/Data_27_5ade.2bpp", 0, 5408
