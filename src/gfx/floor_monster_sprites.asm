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

INCLUDE "monster.inc"
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
	call WaitForPaletteFadeCgb
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

; Floor-monster sprite tiles: a flat 48-tile ($300-byte) OBJ sprite set per MONSTER
; species (include/monster.inc), uploaded straight to OBJ VRAM by the loaders above
; (LoadFloorMonsterSprite / SpeciesSrcPtrs: base + species*$300). 20 species span
; $415c..$7d5b; species 13 is unused. Each set plus its 4-colour OBJ palette (table
; below) is the editable indexed PNG assets/room/monster/<name>.png -- pngasset.py
; (mode: sprite) splits each into tiles.bin + palette.bin. See docs/gfx_loaders.md.
FloorMonsterSprites:
	enum_table MONSTER, INCBIN, \
		.TACOPI = "assets/room/monster/tacopi/tiles.bin", \
        .JELL = "assets/room/monster/jell/tiles.bin", \
        .NAGA = "assets/room/monster/naga/tiles.bin", \
        .DINO = "assets/room/monster/dino/tiles.bin", \
        .PLANT = "assets/room/monster/plant/tiles.bin", \
        .HENGER = "assets/room/monster/henger/tiles.bin", \
        .JOKER = "assets/room/monster/joker/tiles.bin", \
        .GHOST = "assets/room/monster/ghost/tiles.bin", \
        .PUNCHO = "assets/room/monster/puncho/tiles.bin", \
        .PSYLORA = "assets/room/monster/psylora/tiles.bin", \
        .DUCKEN = "assets/room/monster/ducken/tiles.bin", \
        .FLAME_RED = "assets/room/monster/flame_red/tiles.bin", \
        .FLAME_BLUE = "assets/room/monster/flame_blue/tiles.bin", \
		.UNUSED = "assets/room/monster/unused/tiles.bin", \
        .TIGER = "assets/room/monster/tiger/tiles.bin", \
        .MOCCHI = "assets/room/monster/mocchi/tiles.bin", \
        .HARE = "assets/room/monster/hare/tiles.bin", \
        .GALI = "assets/room/monster/gali/tiles.bin", \
        .GOLEM = "assets/room/monster/golem/tiles.bin", \
        .SUEZO = "assets/room/monster/suezo/tiles.bin"

; One OBJ palette (4 RGB555 colours, 8 bytes) per floor-monster species (20),
; indexed by LoadFloorMonsterSprite / SpeciesPalettePtrs (base + MONSTER*8). These
; are the colours baked into each species' PNG above (split out to palette.bin).
FloorMonsterSpritePalettes:
	enum_table MONSTER, INCBIN, \
	    .TACOPI = "assets/room/monster/tacopi/palette.bin", \
        .JELL = "assets/room/monster/jell/palette.bin", \
        .NAGA = "assets/room/monster/naga/palette.bin", \
        .DINO = "assets/room/monster/dino/palette.bin", \
        .PLANT = "assets/room/monster/plant/palette.bin", \
        .HENGER = "assets/room/monster/henger/palette.bin", \
        .JOKER = "assets/room/monster/joker/palette.bin", \
        .GHOST = "assets/room/monster/ghost/palette.bin", \
        .PUNCHO = "assets/room/monster/puncho/palette.bin", \
        .PSYLORA = "assets/room/monster/psylora/palette.bin", \
        .DUCKEN = "assets/room/monster/ducken/palette.bin", \
        .FLAME_RED = "assets/room/monster/flame_red/palette.bin", \
        .FLAME_BLUE = "assets/room/monster/flame_blue/palette.bin", \
		.UNUSED = "assets/room/monster/unused/palette.bin", \
        .TIGER = "assets/room/monster/tiger/palette.bin", \
        .MOCCHI = "assets/room/monster/mocchi/palette.bin", \
        .HARE = "assets/room/monster/hare/palette.bin", \
        .GALI = "assets/room/monster/gali/palette.bin", \
        .GOLEM = "assets/room/monster/golem/palette.bin", \
        .SUEZO = "assets/room/monster/suezo/palette.bin"
