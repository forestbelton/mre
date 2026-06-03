; TECMO logo renderer -- the "draw the TECMO logo and fade it" routine, the
; first screen drawn at boot (fades in, holds ~3s, fades out). Lifted out of
; bank $30 in analyzed.asm so the logo's code lives with its data
; (src/gfx/logo.asm). It is pure rendering: no state-machine logic. The intro
; dispatcher reaches it via the bank-0 handler IntroScene_TecmoLogo ($3580),
; which banks in $30, `call`s here, and advances the intro state -- see
; RunIntroScene / IntroSceneTable. It calls shared engine routines
; (CopyBytesBanked, etc.) defined in analyzed.asm, and references the logo's
; tile/palette/map data (TecmoLogo*) carved into src/gfx/logo.asm.

; NB: Can't use TECMO_LOGO_GFX_BANK when declaring the data sections in
; gfx/logo.asm because it doesn't play nicely with the extractor. Can either
; fix the extractor or wait until the extractor is simplified out after ROM
; mapping.
DEF TECMO_LOGO_GFX_BANK EQU $27

SECTION "DrawTecmoLogo", ROMX[$5418], BANK[$30]
DrawTecmoLogo:
	xor a
	ld [wFadeLevel], a          ; fade level := 0
	call HideAllSprites         ; clear OAM / pre-screen init
	xor a
	ldh [rVBK], a               ; VRAM bank 0
	ld a, TECMO_LOGO_GFX_BANK
	ld hl, $4000                ; bank $27 $4000 -> VRAM $8000 (tiles, incl logo @ $9000)
	ld de, $8000
	ld bc, $1800
	call CopyBytesBanked
	ld a, $01
	ldh [rVBK], a               ; VRAM bank 1
	ld a, TECMO_LOGO_GFX_BANK
	ld hl, $5800                ; bank-1 plane (palette/maps/tail ride along, unused as tiles)
	ld de, $8000
	ld bc, $1800
	call CopyBytesBanked
	ld b, TECMO_LOGO_GFX_BANK
	ld hl, TecmoLogoMapDesc     ; TecmoLogoMapDesc -> BG tilemap + CGB attrs
	ld de, $9800
	call CopyBgMapBanked
	call Func_00_0822
	ld b, TECMO_LOGO_GFX_BANK
	ld de, TecmoLogoPalette     ; TecmoLogoPalette -> BG/OBJ palette buffers
	call LoadPalettesBanked
	call Func_00_0794           ; show screen + apply palettes
.fadeLoop:
	call WaitForNextFrame
	call ReadJoypad
	ldh a, [$ff8d]              ; held buttons
	cp $00
	jr nz, .done                ; any press skips the fade
	ld a, [wFadeLevel]
	cp $b4                      ; held ~180 frames (~3 s)
	jr nc, .done
	ld a, [wFadeLevel]
	inc a
	ld [wFadeLevel], a          ; advance fade level (per-frame palette dim)
	jp .fadeLoop
.done:
	call Func_00_07a7           ; fade out
	call Func_00_0786
	ret
