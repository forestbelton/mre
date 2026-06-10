; Floor-monster sprite loader (ROM bank $11).
;
; Renders the four monsters visible on a dungeon floor. Their MONSTER species ids
; live in the 4-byte array at $c4cd-$c4d0 ($c4cc holds the tileset id; see
; tileset_loader.asm). Two code paths draw the same roster:
;   - home/editor menu path: LoadAllFloorMonsterSprites (tiles+palettes) and
;     LoadAllFloorMonsterPalettes (palettes only), placing each slot via
;     wMenuCursor; the per-monster worker is LoadFloorMonsterSprite.
;   - dungeon-scene path (scene.asm): LoadFloorMonsterSpriteToSlot /
;     LoadFloorMonsterSlotPalettes, using the SlotVramBank/SlotDest/
;     SpeciesSrcPtrs/SpeciesPalettePtrs index tables below.
; Sprite tiles + palettes are the assets in the second half of the bank.
; Carved out of analyzed.asm (byte-exact; section names unchanged).

INCLUDE "hardware.inc"
INCLUDE "util.inc"
INCLUDE "sound_ids.inc"

SECTION "analyzed_044000", ROMX[$4000], BANK[$11]

; Load all four floor monsters (tiles + OBJ palette) for the menu/editor view,
; reading each slot's species id from $c4cd-$c4d0. wMenuCursor is reused as the
; 1-based slot index that LoadFloorMonsterSprite renders into.
LoadAllFloorMonsterSprites:
	ld a, $01
	ld [wMenuCursor], a
	ld a, [wFloorMonsterSpecies]              ; slot 1 species
	ld c, a
	call LoadFloorMonsterSprite
	ld a, $02
	ld [wMenuCursor], a
	ld a, [wFloorMonsterSpecies+1]              ; slot 2 species
	ld c, a
	call LoadFloorMonsterSprite
	ld a, $03
	ld [wMenuCursor], a
	ld a, [wFloorMonsterSpecies+2]              ; slot 3 species
	ld c, a
	call LoadFloorMonsterSprite
	ld a, $04
	ld [wMenuCursor], a
	ld a, [wFloorMonsterSpecies+3]              ; slot 4 species
	ld c, a
	call LoadFloorMonsterSprite
	ret

; Reload only the four floor-monster OBJ palettes (no tiles) into OBJ slots 4-7,
; e.g. after another screen clobbered them. C = OBJ slot offset (0-3); hl walks
; the species array $c4cd-$c4d0.
LoadAllFloorMonsterPalettes:
	ld c, $00
	ld hl, wFloorMonsterSpecies
.loop:
	push hl
	push bc
	ld a, [hl]
	add a, a
	add a, a
	add a, a
	ld hl, FloorMonsterSpritePalettes
	rst AddAToHL
	ld a, c
	add a, $04
	call LoadObjPalette
	pop bc
	pop hl
	inc hl
	inc c
	ld a, $04
	cp c
	jr nz, .loop
	ret
; Upload floor-monster species C's sprite (32 tiles, 4x8 column-major from
; FloorMonsterSprites + C*$300) to VRAM bank 1 and load its OBJ palette from
; FloorMonsterSpritePalettes + C*8 into slot [wMenuCursor]+3. C is a MONSTER enum value
; (include/monster.inc). See docs/gfx_loaders.md for the rendered roster.
LoadFloorMonsterSprite:
	ld a, c
	add a, a
	push af
	add a, c
	ld hl, FloorMonsterSprites
	add a, h
	ld h, a
	ld a, [wMenuCursor]
	dec a
	add a, a
	ld de, $8000
	add a, d
	ld d, a
	ld a, $01
	ld [rVBK], a
	ld bc, $0200
	call VramCopy16
	pop af
	add a, a
	add a, a
	ld hl, FloorMonsterSpritePalettes
	rst AddAToHL
	ld a, [wMenuCursor]
	add a, $03
	call LoadObjPalette
	call Func_00_0786
	ret

; Dungeon-scene path: upload one monster's sprite tiles. B = MONSTER species
; (source = SpeciesSrcPtrs[B], $300 bytes), C = on-screen slot 0-3 (target VRAM
; bank = SlotVramBank[C], destination = SlotDest[C]). Called per non-empty slot
; from scene.asm while composing the floor view.
LoadFloorMonsterSpriteToSlot:
	push bc
	ld hl, SpeciesSrcPtrs
	ld c, b
	ld b, $00
	sla c
	rl b
	add hl, bc
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	pop bc
	ld b, $00
	push hl
	ld hl, SlotVramBank
	add hl, bc
	ld a, [hl]
	ld [rVBK], a
	pop hl
	push hl
	ld hl, SlotDest
	sla c
	rl b
	add hl, bc
	ld a, [hl+]
	ld d, [hl]
	ld e, a
	pop hl
	ld bc, $0300
	call VramCopy16
	ret

; Dungeon-scene path: load the floor-monster OBJ palettes into slots 4-7, skipping
; empty ($ff) entries in $c4cd-$c4d0. Per-slot palette is fetched through
; SpeciesPalettePtrs (.loadOne). Called from scene.asm.
LoadFloorMonsterSlotPalettes:
	ld de, wFloorMonsterSpecies
	ld c, $00
.loop:
	ld a, [de]
	cp $ff
	jr z, .next
	ld a, [de]
	ld b, a
	push bc
	push de
	call .loadOne
	pop de
	pop bc
.next:
	inc de
	inc c
	ld a, c
	cp $04
	jr nz, .loop
	ret
.loadOne:
	push bc
	ld hl, SpeciesPalettePtrs
	ld c, b
	ld b, $00
	sla c
	rl b
	add hl, bc
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	pop bc
	ld a, c
	add a, $04
	call LoadObjPalette
	ret

; --- Floor-monster sprite/palette index tables ($40e3-$415b) ---
; Parallel tables read by the loaders above. There are four on-screen "slots"
; (0-3) and 20 MONSTER species. Each slot has a fixed VRAM bank + destination;
; each species has a source-tile pointer and an OBJ-palette pointer.
SlotVramBank:                              ; [slot] -> VRAM bank (0/1)
	db $01, $01, $01, $00
SlotDest:                                  ; [slot] -> VRAM destination address
	dw $8000, $8300, $8b80, $8d00
SpeciesSrcPtrs:                            ; [species] -> FloorMonsterSprites + species*$300
	dw $415c, $445c, $475c, $4a5c, $4d5c, $505c, $535c, $565c
	dw $595c, $5c5c, $5f5c, $625c, $655c, $685c, $6b5c, $6e5c
	dw $715c, $745c, $775c, $7a5c
SpeciesPalettePtrs:                        ; [species] -> FloorMonsterSpritePalettes + species*8
	dw $7d5c, $7d64, $7d6c, $7d74, $7d7c, $7d84, $7d8c, $7d94
	dw $7d9c, $7da4, $7dac, $7db4, $7dbc, $7dc4, $7dcc, $7dd4
	dw $7ddc, $7de4, $7dec, $7df4
; Count-prefixed OAM record list (1 count byte + 7x[Yoff,Xoff,tile,attr]) -- the
; on-screen layout of a floor monster's sprite. Consumer not yet pinned.
FloorMonsterMetasprite:
	db $07
	db $08, $08, $0c, $01, $08, $88, $0e, $01, $08, $90, $0e, $21, $00, $8c, $06, $01
	db $58, $8c, $06, $41, $f0, $80, $00, $21, $f0, $98, $00, $01

; Floor-monster sprite tiles, $300 bytes (32 used) per MONSTER species, indexed by
; LoadFloorMonsterSprite. 20 species ($415c..$7d5b): Tacopi, Jell, Naga, Dino,
; Plant, Henger, Joker, Ghost, Puncho, Psylora, Ducken, FlameRed, FlameBlue,
; (#13 unused), Tiger, Mocchi, Hare, Gali, Golem, Suezo. The blob is split across
; the Data_11_* sheets below (analyzer fragmentation). See docs/gfx_loaders.md.
FloorMonsterSprites:
	INCBIN "gfx/raw/Data_11_415c.2bpp", 0, 2304

Data_11_4a5c:
	db $00, $00, $00, $00, $18, $00, $30, $08, $61, $10, $c1, $20, $c3, $20, $c6, $31
	db $64, $1b, $7d, $02, $38, $07, $18, $07, $18, $07, $31, $0e, $60, $18, $33, $0f
	db $18, $04, $30, $08, $60, $10, $40, $20, $c1, $20, $c1, $20, $c3, $30, $ce, $31
	db $c6, $39, $60, $1f, $39, $06, $0f, $00, $01, $00, $03, $00, $02, $01, $01, $00
	db $00, $00, $00, $00, $18, $00, $30, $08, $60, $10, $c1, $20, $81, $60, $82, $61
	db $8e, $71, $c0, $3f, $61, $1e, $3f, $00, $0f, $00, $1e, $00, $38, $00, $1e, $02
	db $00, $00, $1a, $01, $36, $09, $64, $13, $c4, $23, $c4, $23, $c2, $21, $c3, $20
	db $c6, $31, $cd, $32, $60, $1f, $38, $07, $18, $07, $11, $0e, $20, $18, $13, $0f
	db $00, $00, $00, $00, $60, $1c, $98, $7e, $0c, $ff, $00, $ff, $40, $be, $e0, $00
	db $60, $80, $00, $fc, $ec, $1c, $fc, $60, $fc, $40, $78, $00, $e0, $00, $7c, $04
	db $00, $00, $40, $3c, $d8, $3e, $8c, $7f, $80, $7f, $40, $be, $60, $80, $20, $c0
	db $80, $7c, $6c, $9c, $18, $e0, $80, $78, $80, $78, $00, $f0, $00, $80, $30, $f0
	db $00, $00, $00, $00, $40, $3c, $98, $7e, $8c, $7f, $40, $bf, $60, $9e, $60, $80
	db $80, $70, $40, $be, $36, $ce, $8c, $70, $e0, $1c, $40, $38, $80, $60, $4c, $3c
	db $00, $00, $00, $e0, $c0, $f0, $60, $f8, $00, $f8, $00, $f0, $e0, $00, $60, $80
	db $80, $7c, $6c, $9c, $fc, $60, $fc, $40, $fc, $00, $78, $00, $e0, $00, $7c, $04
	db $00, $00, $00, $00, $0c, $02, $10, $0c, $20, $18, $61, $10, $c3, $20, $86, $61
	db $9c, $63, $ca, $35, $71, $0e, $31, $0e, $11, $0e, $22, $1c, $40, $30, $26, $1e
	db $00, $00, $00, $00, $00, $00, $01, $00, $c3, $f0, $06, $19, $0e, $31, $18, $67
	db $00, $7f, $02, $3d, $6f, $03, $ff, $01, $9f, $00, $8f, $82, $04, $07, $00, $00
	db $00, $00, $01, $00, $03, $00, $02, $01, $06, $01, $06, $01, $07, $30, $06, $79
	db $00, $df, $10, $8f, $98, $87, $8f, $81, $01, $00, $01, $00, $01, $01, $01, $01
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $03, $00, $04, $03
	db $08, $07, $0d, $02, $18, $07, $30, $0f, $70, $0f, $e3, $1c, $fc, $0f, $d3, $cc
	db $00, $00, $00, $00, $00, $00, $60, $1c, $d8, $3e, $8c, $7f, $40, $bf, $60, $9e
	db $f8, $00, $78, $80, $1c, $e0, $7c, $e0, $fc, $00, $78, $00, $e0, $00, $7c, $04
	db $00, $00, $00, $00, $c0, $30, $00, $f8, $00, $d8, $00, $8c, $00, $c4, $20, $c0
	db $30, $cc, $40, $be, $8c, $7f, $ae, $5f, $a6, $5f, $00, $cf, $00, $86, $00, $00
	db $c0, $38, $80, $7c, $00, $c4, $00, $80, $00, $80, $00, $80, $00, $c0, $20, $c0
	db $38, $c4, $00, $fe, $80, $7f, $a4, $5f, $b2, $4f, $00, $cf, $00, $c6, $00, $80
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $c0, $00, $e0, $00
	db $e0, $10, $30, $00, $20, $98, $c0, $3e, $14, $ff, $c8, $3f, $54, $bf, $a0, $1e
	db $00, $00, $00, $00, $00, $00, $00, $07, $01, $1e, $0f, $73, $1f, $7f, $0f, $37
	db $07, $1b, $07, $0b, $03, $05, $01, $06, $00, $03, $00, $00, $00, $00, $00, $00
	db $00, $01, $01, $06, $03, $0d, $07, $0b, $0f, $17, $0f, $37, $1f, $6e, $3f, $fe
	db $1f, $e7, $03, $3c, $00, $0f, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $78, $60, $98, $e0, $10, $c0, $b0, $c0, $00, $80, $70
	db $f0, $c8, $f0, $fc, $f0, $e8, $e0, $90, $80, $60, $00, $80, $00, $00, $00, $00
	db $00, $e0, $c0, $38, $e0, $dc, $f8, $f6, $fc, $fa, $3c, $cf, $8e, $75, $e0, $1f
	db $e0, $d9, $f0, $6c, $38, $f6, $1c, $fa, $1c, $6a, $1c, $2a, $18, $34, $00, $78
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

Data_11_4d5c:
	INCBIN "gfx/raw/Data_11_4d5c.2bpp", 0, 3072

Data_11_595c:
	db $00, $00, $00, $00, $00, $00, $04, $00, $0c, $00, $0f, $00, $1f, $03, $1f, $04
	db $1f, $04, $1f, $07, $1f, $03, $3f, $30, $0f, $00, $0f, $00, $07, $00, $06, $06
	db $00, $00, $00, $00, $04, $00, $0c, $00, $0f, $00, $1f, $03, $1f, $04, $1f, $04
	db $1f, $07, $1f, $03, $3f, $30, $0f, $00, $0f, $00, $1f, $18, $0c, $0c, $00, $00
	db $00, $00, $00, $00, $04, $00, $0c, $00, $0f, $00, $1f, $03, $1f, $04, $1f, $04
	db $1f, $07, $1f, $03, $3f, $30, $0f, $00, $0f, $00, $07, $03, $06, $06, $00, $00
	db $00, $00, $00, $00, $00, $00, $02, $00, $07, $00, $0f, $00, $1f, $00, $1f, $01
	db $3f, $01, $3f, $01, $3f, $00, $3f, $00, $3f, $00, $1f, $00, $0e, $01, $06, $06
	db $00, $00, $00, $00, $00, $00, $40, $00, $20, $00, $e0, $00, $f0, $e0, $f0, $c0
	db $f0, $c0, $b0, $f0, $f0, $e0, $f8, $08, $e0, $10, $e0, $10, $c0, $20, $60, $60
	db $00, $00, $00, $00, $40, $00, $20, $00, $e0, $00, $f0, $e0, $f0, $c0, $f0, $c0
	db $b0, $f0, $f0, $e0, $f8, $08, $e0, $10, $e0, $10, $d8, $38, $30, $30, $00, $00
	db $00, $00, $00, $00, $40, $00, $20, $00, $e0, $00, $f0, $e0, $f0, $c0, $f0, $c0
	db $b0, $f0, $f0, $e0, $f8, $08, $e0, $10, $e0, $10, $c0, $20, $c0, $c0, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $c0, $00, $c0, $c0, $e0, $20
	db $e0, $20, $c0, $e0, $c0, $c0, $c0, $0e, $c0, $5f, $60, $bf, $00, $1f, $00, $0e
	db $00, $03, $00, $77, $07, $f8, $3c, $c3, $4c, $b3, $4f, $b0, $5f, $a0, $3f, $40
	db $1f, $20, $5f, $20, $7f, $20, $5f, $30, $2f, $10, $2f, $10, $1f, $0c, $0f, $06
	db $00, $07, $04, $6b, $0f, $f0, $3f, $c0, $5f, $a7, $5f, $a9, $5f, $a9, $3e, $6f
	db $3e, $37, $4c, $33, $4c, $33, $4c, $33, $2c, $13, $26, $19, $16, $09, $0d, $00
	db $00, $03, $00, $01, $00, $00, $33, $08, $66, $19, $4e, $31, $4c, $33, $4c, $33
	db $4c, $33, $4c, $33, $4c, $33, $4c, $33, $2c, $13, $26, $19, $16, $09, $0d, $00
	db $00, $00, $0f, $00, $30, $0f, $40, $3f, $9f, $60, $ff, $00, $60, $1f, $80, $7f
	db $00, $ff, $00, $7f, $e7, $1f, $7f, $80, $1f, $60, $00, $3f, $03, $0f, $00, $00
	db $00, $c0, $00, $ee, $e0, $1f, $5c, $a3, $22, $dd, $e2, $1d, $f2, $1d, $f4, $3a
	db $f8, $34, $fa, $16, $f8, $0e, $f8, $16, $f8, $04, $f0, $0c, $f0, $c8, $60, $f0
	db $00, $e0, $20, $d6, $f0, $0f, $fc, $03, $fa, $e5, $fa, $95, $fa, $95, $7c, $f6
	db $7c, $ec, $3a, $e6, $38, $e6, $18, $e6, $18, $e4, $30, $cc, $30, $c8, $20, $90
	db $00, $00, $00, $80, $00, $80, $00, $dc, $34, $ce, $52, $ee, $3a, $e6, $3a, $e6
	db $3a, $e6, $3a, $e6, $38, $e6, $18, $e6, $18, $e4, $30, $cc, $30, $c8, $20, $90
	db $00, $00, $f0, $00, $18, $e0, $08, $f0, $e0, $18, $f0, $00, $38, $c1, $08, $f3
	db $00, $fe, $20, $f8, $d0, $e0, $f0, $08, $c0, $38, $10, $f8, $e0, $f0, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

Data_11_5c5c:
	INCBIN "gfx/raw/Data_11_5c5c.2bpp", 0, 3072

Data_11_685c:
	db $00, $00, $00, $00, $00, $00, $7f, $7f, $92, $92, $92, $92, $92, $92, $92, $92
	db $e0, $ff, $c0, $ff, $c0, $ff, $c0, $ff, $7f, $00, $1e, $1f, $0c, $0f, $00, $03
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $fe, $fe, $49, $49, $49, $49, $49, $49, $49, $49
	db $07, $f8, $03, $fc, $03, $fc, $03, $fc, $fe, $00, $38, $c0, $70, $80, $c0

SECTION "analyzed_046b5c", ROMX[$6b5c], BANK[$11]

Data_11_6b5c:
	INCBIN "gfx/raw/Data_11_6b5c.2bpp", 0, 768

Data_11_6e5c:
	db $00, $00, $00, $00, $07, $00, $0f, $03, $0f, $06, $0f, $06, $0f, $07, $0f, $07
	db $0f, $07, $0f, $07, $0f, $0f, $1f, $1f, $1f, $1b, $0f, $03, $0f, $03, $07, $07
	db $00, $00, $07, $00, $0f, $03, $0f, $06, $0f, $06, $0f, $07, $0f, $07, $0f, $07
	db $0f, $0f, $3f, $3f, $1f, $1b, $0f, $03, $0f, $07, $0f, $0f, $1e, $1e, $0f, $0f
	db $00, $00, $07, $00, $0f, $03, $0f, $06, $0f, $06, $0f, $07, $0f, $07, $0f, $07
	db $0f, $0f, $3f, $3f, $1f, $1b, $07, $03, $03, $07, $01, $0f, $01, $1e, $00, $0e
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0f, $00, $1f, $0e
	db $3f, $1f, $3f, $1f, $3f, $1f, $3f, $1f, $1f, $0f, $0f, $07, $07, $07, $0f, $0f
	db $00, $00, $00, $00, $e0, $00, $f0, $80, $f0, $40, $f0, $70, $80, $f8, $c0, $f0
	db $e0, $e0, $f0, $f0, $f8, $f8, $f8, $f8, $f8, $f8, $e0, $f0, $80, $e0, $c0, $f8
	db $00, $00, $e0, $00, $f0, $80, $f0, $40, $f0, $70, $80, $f8, $c0, $f0, $f0, $f0
	db $f8, $f8, $f8, $f8, $f8, $f8, $f0, $f9, $e0, $ff, $00, $1e, $00, $0c, $00, $00
	db $00, $00, $e0, $00, $f0, $80, $f0, $40, $f0, $70, $80, $f8, $c0, $f0, $f0, $f0
	db $f8, $f8, $f8, $f8, $f8, $f8, $d0, $f0, $e4, $e4, $fc, $fc, $78, $78, $30, $30
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $e0, $00, $f0, $00
	db $f8, $08, $f8, $f8, $f8, $f8, $f8, $f8, $f0, $f0, $80, $e0, $00, $c0, $80, $f0
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $0f, $00, $1f, $0e, $3f, $1f, $3f, $1f, $3f, $1f, $3f, $1f, $1f, $1f, $0f, $0f
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $07, $00, $0f, $0e, $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f, $0f, $0f
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $07, $07, $0f, $0f, $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f, $1f, $0f, $0f, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $0f, $00, $1f, $0e, $3f, $1f, $3f, $1f, $3f, $1d, $1f, $1e, $0f, $0d
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $e0, $00, $f0, $00, $f8, $08, $f8, $88, $fc, $fc, $fc, $fc, $fc, $fc, $f8, $f8
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $e0, $00, $f8, $08, $fc, $04, $fc, $80, $fc, $80, $fc, $80, $fc, $04, $f8, $08
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $f0, $f0, $f8, $f8, $fc, $fc, $fc, $fc, $fc, $fc, $fc, $cc, $fc, $04, $f8, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $e0, $00, $f0, $00, $f8, $08, $f8, $88, $fc, $68, $fc, $f4, $fc, $68
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $0c, $01, $1e, $00, $3b, $41, $36, $e1, $0e, $c3, $07, $00, $03
	db $02, $1d, $05, $3f, $0b, $3d, $17, $3b, $0b, $17, $01, $07, $01, $0e, $0e, $0e
	db $00, $0c, $01, $1e, $00, $3b, $41, $36, $e1, $0e, $c3, $07, $00, $03, $01, $0e
	db $02, $1f, $05, $1e, $0b, $1d, $04, $0b, $1c, $03, $3e, $01, $3c, $00, $1e, $00
	db $00, $0c, $01, $1e, $00, $3b, $41, $36, $e1, $0e, $c3, $07, $00, $03, $01, $0e
	db $02, $1f, $05, $1e, $0b, $1d, $05, $0b, $00, $0f, $00, $3e, $00, $3c, $18, $38
	db $00, $00, $01, $18, $03, $3c, $08, $37, $52, $2d, $63, $1d, $67, $0f, $01, $07
	db $18, $07, $3e, $07, $3f, $0f, $1c, $0f, $0c, $0b, $06, $05, $0f, $00, $1f, $1c
	db $00, $00, $e0, $00, $f0, $00, $10, $c0, $00, $e0, $e0, $a0, $e0, $e0, $c0, $c0
	db $00, $dc, $50, $de, $e8, $de, $f4, $ce, $c0, $c0, $c0, $80, $e0, $00, $f0, $30
	db $e0, $00, $f0, $00, $10, $c0, $00, $e0, $e0, $a0, $e0, $e0, $c0, $dc, $10, $de
	db $a8, $fe, $f4, $8e, $fc, $38, $c0, $38, $00, $f8, $80, $70, $00, $e0, $00, $00
	db $e0, $00, $f0, $00, $10, $c0, $00, $e0, $e0, $a0, $e0, $e0, $c0, $dc, $10, $de
	db $a8, $fe, $f4, $ee, $ec, $e0, $f4, $e4, $fe, $c2, $3e, $00, $1c, $00, $18, $00
	db $00, $00, $c0, $00, $e0, $00, $20, $80, $00, $c0, $80, $40, $c0, $c0, $80, $70
	db $c0, $78, $a0, $78, $50, $b8, $30, $c0, $00, $e0, $00, $e0, $00, $c0, $00, $00
	db $00, $00, $00, $03, $00, $07, $00, $0e, $10, $0d, $38, $03, $30, $01, $00, $00
	db $01, $02, $00, $1b, $00, $1f, $00, $07, $00, $07, $00, $1f, $00, $1c, $0e, $0e
	db $00, $00, $00, $33, $00, $f7, $88, $fd, $03, $38, $03, $1c, $03, $0c, $e1, $e6
	db $c0, $e7, $80, $f3, $00, $0f, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $02, $03, $00, $38, $80, $f8, $00, $19, $00, $1b, $00, $0f, $00, $07, $00, $07
	db $e0, $e7, $c0, $e3, $80, $f1, $00, $0f, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $01, $00, $03, $01, $46, $0f, $e0, $0e, $f1, $87, $ff, $8f, $bf
	db $00, $00, $38, $00, $7c, $80, $04, $e0, $20, $d0, $2c, $d8, $f8, $f8, $30, $f0
	db $00, $ff, $e0, $0f, $68, $ef, $67, $e7, $f8, $e0, $f8, $c0, $70, $00, $3c, $0c
	db $00, $00, $00, $00, $00, $00, $1c, $00, $9c, $02, $d8, $06, $00, $c6, $00, $e6
	db $8e, $60, $9f, $60, $41, $bc, $90, $6e, $10, $ee, $1e, $6a, $3c, $3c, $00, $00
	db $00, $80, $0c, $c0, $0e, $c0, $ee, $00, $f4, $02, $e0, $16, $40, $b6, $40, $b6
	db $4e, $b0, $5f, $a0, $41, $bc, $80, $7e, $10, $ee, $0e, $7a, $3c, $3c, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $1c, $80, $3e, $c0, $aa, $50, $10, $e8, $2e, $d4, $7d, $ff, $19, $ff, $83, $ff
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00

Data_11_745c:
	INCBIN "gfx/raw/Data_11_745c.2bpp", 0, 2304

; One OBJ palette (4 RGB555 colours, 8 bytes) per floor-monster species (20),
; indexed by LoadFloorMonsterSprite / SpeciesPalettePtrs (base + MONSTER*8).
FloorMonsterSpritePalettes:
	db $00, $24, $34, $01, $bc, $01, $df, $7b   ;  0 Tacopi
	db $00, $00, $00, $49, $46, $52, $1b, $24   ;  1 Jell
	db $ef, $3d, $4a, $40, $12, $6c, $9a, $76   ;  2 Naga
	db $12, $01, $40, $01, $e0, $01, $3f, $4b   ;  3 Dino
	db $00, $00, $e5, $11, $7a, $01, $5e, $17   ;  4 Plant
	db $00, $00, $6d, $19, $3b, $3f, $7a, $01   ;  5 Henger
	db $00, $00, $29, $25, $31, $46, $19, $00   ;  6 Joker
	db $00, $00, $2c, $39, $7a, $01, $7e, $4f   ;  7 Ghost
	db $00, $00, $47, $1e, $dd, $09, $9f, $1f   ;  8 Puncho
	db $00, $00, $60, $2d, $46, $52, $5e, $17   ;  9 Psylora
	db $00, $00, $4a, $29, $5e, $17, $de, $7b   ; 10 Ducken
	db $00, $00, $a2, $69, $1e, $05, $de, $7b   ; 11 FlameRed
	db $00, $00, $a2, $69, $1e, $05, $de, $7b   ; 12 FlameBlue
	db $12, $01, $08, $21, $31, $46, $5a, $6b   ; 13 (#13 unused)
	db $b0, $14, $c0, $40, $4f, $5e, $de, $7b   ; 14 Tiger
	db $88, $49, $80, $01, $74, $49, $5d, $5e   ; 15 Mocchi
	db $e0, $01, $c9, $08, $f2, $01, $7d, $5b   ; 16 Hare
	db $c0, $6d, $4a, $29, $d9, $16, $bd, $77   ; 17 Gali
	db $88, $49, $08, $21, $73, $4e, $f7, $5e   ; 18 Golem
	db $60, $01, $8b, $10, $b9, $02, $de, $7b   ; 19 Suezo

