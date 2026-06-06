; Tower floor (room) generation/loading code -- bank $00 cluster ($166f-$1872).
;
; This is the core that turns a floor NUMBER into a live, rendered room:
;   LoadFloorByMode -> (GetFloorIndex) -> ParseFloorRecord expands the packed
;   per-floor record (header + collision grid + piece grid + entity tables) into
;   WRAM, then DrawFloorPiece stamps each piece's metatile to the BG map. The
;   per-floor record DATA lives in src/room/roomNN.asm; this file is the engine
;   that consumes it. See docs/floor_data.md for the record format and the
;   FloorBankTable/FloorPtrTable lookup chain.
;
; Two RST vectors are used heavily as 16-bit add helpers:
;   rst AddAToHL  ->  hl += a       ($0000: add a,l / ld l,a / ret nc / inc h / ret)
;   rst AddAToDE  ->  de += a       ($0030: add a,e / ld e,a / ret nc / inc d / ret)
;
; Labels referenced from analyzed.asm keep their curated names (added to
; map.json labels[]); two whose behaviour is clear but whose purpose isn't
; (Func_00_16ad, Func_00_17c0) keep their auto-generated names with a note.

SECTION "layout_code", ROM0[$166f]

; -----------------------------------------------------------------------------
; FloorPostLoadCleanup ($166f) -- run after a floor record is parsed.
; Runs the three bank-$01 grid-cleanup passes (which strip conditionally-absent
; items from the piece grid), three bank-$05 setup routines, clears four entity
; slots, then falls through into the bank-$12 refresh below.
; See docs/floor_data.md "Conditional-appearance gate".
; -----------------------------------------------------------------------------
FloorPostLoadCleanup:
	ld a, $01
	ld hl, RemoveKeyPass           ; pass 1: strip gold KEY when wProgressFlags bit 1 set
	call CallBankedHL
	ld a, $01
	ld hl, RemoveSilverKeyGate     ; pass 2: strip SILVER_KEY unless progress allows
	call CallBankedHL
	ld a, $01
	ld hl, RemoveConditionalItemsPass  ; pass 3: conditional-item gate (Data_01_5162)
	call CallBankedHL
	FAR_CALL $05, Func_05_496b
	FAR_CALL $05, Func_05_49c8
	FAR_CALL $05, Func_05_499d
	ld a, $ff              ; clear a pair of entity slots ($FF = empty)
	ld [$c530], a
	ld [$c531], a
	ld [wSpawnCellX], a
	ld [wSpawnCellY], a
	; falls through

; Func_00_16ad -- map ROM bank $12 and run two of its routines, restoring the
; previously-mapped bank afterwards. Also called standalone from elsewhere.
; (Behaviour is clear; the bank-$12 routines aren't decoded, so the name is kept.)
Func_00_16ad:
	ld a, [$7fff]          ; save current bank ($7fff mirrors the bank register)
	push af
	ld a, $12
	ld [$2fff], a          ; map bank $12 into $4000-$7fff
	call Func_12_4094
	call $41a9             ; Func_12_41a9 (no curated label)
	pop af
	ld [$2fff], a          ; restore previous bank
	ret

; -----------------------------------------------------------------------------
; LoadFloorByMode ($16c1) -- pick the record index for the active floor from the
; screen "mode" in wRoomType, then tail into ParseFloorRecord. d = wActiveFloor - 1.
;   mode 0 : index = floor-1               (normal tower floors)
;   mode 1 : index = $3c + (floor-1)
;   mode 2 : index = $46 + (floor-1)
;   mode 5 : index = $51                   (fixed)
;   else   : GetFloorIndex (bonus-stage remap)
; See docs/floor_data.md "Lookup chain".
; -----------------------------------------------------------------------------
LoadFloorByMode:
	ld a, [wActiveFloor]
	dec a
	ld d, a                ; d = floor - 1
	ld a, [wRoomType]          ; screen mode
	cp $00
	jr nz, .notMode0
	ld a, d
	jr ParseFloorRecord
.notMode0:
	cp $01
	jr nz, .notMode1
	ld a, $3c
	add a, d
	jr ParseFloorRecord
.notMode1:
	cp $02
	jr nz, .notMode2
	ld a, $46
	add a, d
	jr ParseFloorRecord
.notMode2:
	cp $05
	jr nz, LoadFloorData
	ld a, $51
	jr ParseFloorRecord

; LoadFloorData ($16ea) -- entry that resolves the record index via the
; bonus-stage remap table first (used by the dungeon-setup path).
LoadFloorData:
	call GetFloorIndex

; -----------------------------------------------------------------------------
; ParseFloorRecord ($16ed) -- a = record index. Look up the record's bank+ptr,
; map the bank, then expand the record into WRAM:
;   8-byte header -> scattered WRAM fields
;   height x width collision grid -> wFloorCollision (17-wide, margin skipped)
;   height x width piece grid      -> wFloorGrid
;   4-byte sprite/species table (arr1) -> $c4cd
;   45-byte monster table (arr2; 9 x 5)  -> $c4d1
;   48-byte spawner table (arr3; 4 x 12) -> $c4fe
; then runs bank-$05/$01 post-load entity setup. See docs/floor_data.md.
; -----------------------------------------------------------------------------
ParseFloorRecord:
	ld d, a                ; d = record index
	ld hl, FloorBankTable
	rst AddAToHL                ; hl = FloorBankTable + index
	ld a, [$7fff]          ; save current bank
	push af
	ld a, [hl]
	ld [$2fff], a          ; map the record's ROM bank
	ld a, d
	add a, a               ; index * 2 (FloorPtrTable is words)
	ld hl, FloorPtrTable
	rst AddAToHL                ; hl = FloorPtrTable + index*2
	ld a, [hl+]
	ld h, [hl]
	ld l, a                ; hl = record pointer (bank-mapped $4000-$7fff)

	; -- 8-byte header --
	ld a, [hl+]
	ld [$cfbd], a          ; [0] type/theme
	ld a, [hl+]
	ld [$c2ea], a          ; [1] spawn column
	ld a, [hl+]
	ld [$c2eb], a          ; [2] spawn row
	ld a, [hl+]
	ld [$c2e9], a          ; [3] pad (always $00)
	ld a, [hl+]
	ld [$c4cc], a          ; [4] param0 (undecoded)
	ld a, [hl+]
	ld [$c4cb], a          ; [5] param1 (undecoded)
	ld a, [hl+]
	ld [wFloorHeight], a    ; [6] height
	ld a, [hl+]
	ld [wFloorWidth], a     ; [7] width
	ld c, a
	ld a, $11
	sub c
	ld [wFloorRowStride], a ; $11 - width: per-row skip into the 17-wide WRAM grid

	ld d, h
	ld e, l                 ; de = source cursor (packed grid data)
	ld hl, wFloorCollision
	ld a, [wFloorHeight]
	ld b, a
.copyCollision:
	ld a, [wFloorWidth]
	ld c, a
	call CopyDEtoHL         ; copy one packed row (width bytes) de -> hl
	ld a, [wFloorRowStride]
	rst AddAToHL                 ; advance hl over the WRAM row margin
	dec b
	jr nz, .copyCollision

	ld hl, wFloorGrid
	ld a, [wFloorHeight]
	ld b, a
.copyPieces:
	ld a, [wFloorWidth]
	ld c, a
	call CopyDEtoHL
	ld a, [wFloorRowStride]
	rst AddAToHL
	dec b
	jr nz, .copyPieces

	ld c, $04              ; arr1: 4-byte sprite/species table
	ld hl, $c4cd
	call CopyDEtoHL
	ld c, $2d              ; arr2: 45-byte monster table (9 x 5)
	ld hl, $c4d1
	call CopyDEtoHL
	ld c, $30             ; arr3: 48-byte spawner table (4 x 12; see ProcessFloorSpawners)
	ld hl, $c4fe
	call CopyDEtoHL

	ld a, $05
	ld hl, Func_05_49ef    ; bank-$05 post-load entity setup
	call CallBankedHL
	ld a, $01
	ld hl, Func_01_572d    ; bank-$01 post-load entity setup
	call CallBankedHL
	pop af
	ld [$2fff], a          ; restore previous bank
	ret

; -----------------------------------------------------------------------------
; BonusFloorRemap ($1783) -- the six tower floors that hold a MONSTER_FLAME warp
; to a bonus stage with a friendly monster. GetFloorIndex / Func_00_17c0 scan
; this for wActiveFloor. 6 entries x 3 bytes {floor, bonusRecord, field3},
; $FF-terminated. bonusRecord $52-$57 = records 82-87 (bank $12). See
; docs/floor_data.md "Bonus stages".
; -----------------------------------------------------------------------------
BonusFloorRemap:
	;   floor          record  field3
	db  6, $52, $46    ; floor  6 -> record 82 (HARE)
	db 18, $53, $47    ; floor 18 -> record 83 (GALI)
	db 22, $54, $48    ; floor 22 -> record 84 (GOLEM)
	db 44, $55, $49    ; floor 44 -> record 85 (SUEZO)
	db 56, $56, $4a    ; floor 56 -> record 86 (TIGER)
	db 58, $57, $4b    ; floor 58 -> record 87 (MOCCHI)
	db $ff             ; terminator

; GetBonusFloorByRecord ($1796) -- inverse of the table above: given a
; bonus-record offset in c, return BonusFloorRemap[c*3] (the floor number).
GetBonusFloorByRecord:
	ld b, $00
	ld h, b
	ld l, c
	add hl, bc            ; hl = c*2
	add hl, bc            ; hl = c*3
	ld bc, BonusFloorRemap
	add hl, bc
	ld a, [hl]
	ret

; -----------------------------------------------------------------------------
; GetFloorIndex ($17a2) -- map wActiveFloor to its bonus-stage record index by
; scanning BonusFloorRemap. Returns the entry's bonusRecord (2nd field); if the
; bonus context flag $c2c2 is set, or the floor isn't a bonus floor, returns the
; default record $52.
; -----------------------------------------------------------------------------
GetFloorIndex:
	ld a, [$c2c2]
	or a
	jr nz, .default
	ld a, [wActiveFloor]
	ld c, a
	ld hl, BonusFloorRemap
.scan:
	ld a, [hl+]            ; floor field
	cp $ff
	jr z, .default        ; hit terminator -> not a bonus floor
	cp c
	jr z, .found
	inc hl                ; skip bonusRecord + field3 to next entry
	inc hl
	jr .scan
.found:
	ld a, [hl]            ; bonusRecord (2nd field)
	ret
.default:
	ld a, $52
	ret

; Func_00_17c0 -- identical scan to GetFloorIndex but returns the entry's 3rd
; field (field3, $46-$4b; purpose undecoded), defaulting to 0. Name kept since
; the field's meaning is unknown.
Func_00_17c0:
	ld a, [$c2c2]
	or a
	jr nz, .default
	ld a, [wActiveFloor]
	ld c, a
	ld hl, BonusFloorRemap
.scan:
	ld a, [hl+]
	cp $ff
	jr z, .default
	cp c
	jr z, .found
	inc hl
	inc hl
	jr .scan
.found:
	inc hl                ; advance to the 3rd field
	ld a, [hl]
	ret
.default:
	xor a
	ret

; -----------------------------------------------------------------------------
; DrawFloorPiece ($17de) -- a = piece byte, (b,c) = cell. Resolve the piece to a
; FloorPieceDefs entry, position into the BG tilemap from the cell, and stamp the
; 2x2 metatile. Hidden items (bit 7 set, bit 6 clear) render as the floor tile
; (key 0); everything else keys on the full byte. FloorPieceDefs entries are 5
; bytes; the id byte is matched against `h`. See docs/floor_data.md "Piece grid".
; -----------------------------------------------------------------------------
DrawFloorPiece:
	ld h, a                ; h = lookup key (the piece byte)
	ld de, FloorPieceDefs
	bit 7, a               ; item?
	jr z, .lookup          ; non-item piece -> key on the full byte
	bit 6, a               ; open item?
	jr nz, .lookup
	ld h, $00              ; hidden item -> key 0 (draw the floor tile)
.lookup:
	ld a, $05
	ld l, a                ; l = entry stride (5)
.search:
	ld a, [de]             ; entry's id byte
	cp h
	jr z, .found
	ld a, l
	rst AddAToDE                ; de += 5 -> next entry
	jr .search
.found:
	sla b                  ; cell row -> BG tile row (x2, minus 1)
	dec b
	ld hl, $9800           ; BG map base
.downRows:
	ld a, $20
	rst AddAToHL                ; hl += $20 -> down one tile row
	dec b
	jr nz, .downRows
	ld a, c                ; cell col -> BG tile col (x2, minus 1)
	rlca
	dec a
	rst AddAToHL
	call StampFloorMetatile
	ret

; StampFloorMetatile ($180b) -- write the matched FloorPieceDefs entry's 2x2
; metatile to the BG map at hl. de points just past the id byte. Tile indices go
; to VRAM bank 0 as {T, T+8 | T+1, T+9}; the attribute byte to VRAM bank 1.
StampFloorMetatile:
	xor a
	ldh [rVBK], a          ; VRAM bank 0 (tile indices)
	inc de                 ; de -> tile base T
	push hl
	call WaitForHBlank
	ld a, [de]
	ld [hl+], a            ; top-left  = T
	add a, $08
	ld c, a
	ld [hl+], a            ; top-right = T+8
	ld a, $1e
	rst AddAToHL                ; hl += $1e -> next tile row of the 2x2
	ld a, c
	sub $07
	ld [hl+], a            ; bottom-left  = T+1
	add a, $08
	ld [hl], a             ; bottom-right = T+9
	pop hl
	ld a, $01
	ldh [rVBK], a          ; VRAM bank 1 (attributes)
	inc de                 ; de -> attribute byte
	call WaitForHBlank
	ld a, [de]
	ld c, a
	ld [hl+], a
	ld [hl+], a
	ld a, $1e
	rst AddAToHL
	ld a, c
	ld [hl+], a
	ld [hl], a
	ret

; Func_00_1837 -- convert pixel coordinates in b,c to cell coordinates:
; cell = (pixel + 8) >> 4  (cells are 16px; the +8 rounds to nearest). Not reached
; by any resolved reference; kept as code for clarity. Name retained pending use.
Func_00_1837:
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ret

; -----------------------------------------------------------------------------
; ReadFloorCell ($1848) -- b = row, c = col. Read that cell's piece byte into
; $ffac and its collision byte into $ffab. Grid index = row*17 + col.
; -----------------------------------------------------------------------------
ReadFloorCell:
	push hl
	ld a, b
	swap a
	and $f0
	add a, b               ; b*17 (b*16 + b)
	add a, c               ; + col
	ld c, a
	ld b, $00
	ld hl, wFloorGrid
	add hl, bc
	ld a, [hl]
	ldh [$ffac], a         ; cell's piece byte
	ld hl, wFloorCollision
	add hl, bc
	ld a, [hl]
	ldh [$ffab], a         ; cell's collision byte
	pop hl
	ret

; ResetFloorScroll ($1863) -- zero the camera shadow vars and BG scroll registers.
ResetFloorScroll:
	xor a
	ld [$c289], a
	ld [$c28a], a
	ldh [$ffa8], a
	ldh [$ffa9], a
	ldh [rSCX], a
	ldh [rSCY], a
	ret


; =============================================================================
; Tower floor entity generation -- bank $01 cluster ($4000-$42c8).
;
; After ParseFloorRecord copies a floor's arr2 (monsters) and arr3 (spawners)
; tables into WRAM, this populates the live entity list from them:
;   SpawnFloorEntities -> clear sprite RAM, spawn the player, spawn arr2
;   monsters, then process arr3 spawners. Each monster/spawner slot is turned
;   into an allocated sprite entity (Func_00_0467) whose fields are filled by the
;   per-attribute helpers below. See docs/floor_data.md "Monster table"/"spawners".
;
; NOTE: arr3 spawner slots are 12 bytes each (4 slots = 48), not the 8x6 the
; room data files currently model -- byte-identical only because empty slots are
; all $FF. See ProcessFloorSpawners.
;
; The sprite-attribute setters (Func_01_40c6/40da/40e7/4124) are also reused by
; the mode-2 bonus path (Func_01_42e6) outside this range, so they keep their
; auto-generated names; their exact sprite-struct field meanings aren't decoded.
; =============================================================================

SECTION "layout_entities", ROMX[$4000], BANK[$01]

; SpawnFloorEntities ($4000) -- build the live entity list for the loaded floor.
SpawnFloorEntities:
	call ClearFloorSpriteRam
	call SpawnPlayerEntity
	call SpawnFloorMonstersOrBonus
	call ProcessFloorSpawners
	ret

; ClearFloorSpriteRam ($400d) -- zero the $498-byte sprite/entity RAM block.
ClearFloorSpriteRam:
	ld hl, $c7f9
	ld bc, $0498
	ld d, $00
	call Func_00_03bc
	ret

; SpawnPlayerEntity ($4019) -- allocate the player sprite at the floor's spawn
; cell ($c2ea col / $c2eb row, from the record header) and set its initial state.
SpawnPlayerEntity:
	ld a, [$c2eb]          ; spawn row -> pixel y (row*16 + 7)
	swap a
	and $f0
	add a, $07
	ld d, a
	ld a, [$c2ea]          ; spawn col -> pixel x
	swap a
	and $f0
	ld e, a
	ld a, $01
	ld bc, $0000
	ld [wBankCallTmp], a          ; sprite-alloc params for Func_00_0467
	ld a, h
	ld [wSpawnPtr], a
	ld a, l
	ld [wSpawnPtr+1], a
	ld a, $03
	ld hl, $4593
	call Func_00_0467      ; allocate entity -> hl = entity struct
	push hl
	ld de, $0021
	add hl, de
	ld a, $02
	ld [hl], a             ; entity+$21 = $02
	pop hl
	push hl
	ld de, $0006
	add hl, de
	set 3, [hl]            ; entity+$06 bit 3
	pop hl
	ret

; SpawnFloorMonstersOrBonus ($4055) -- mode 2 uses a scripted bonus list, else
; the floor's arr2 table.
SpawnFloorMonstersOrBonus:
	ld a, [wRoomType]          ; screen mode
	cp $02
	jr nz, .normal
	call Func_01_42e6      ; mode 2: scripted bonus-stage monsters
	ret
.normal:
	call SpawnFloorMonsters
	ret

; -----------------------------------------------------------------------------
; SpawnFloorMonsters ($4064) -- spawn the floor's arr2 monsters: 9 slots x 5
; bytes {col, row, type, param, gfxIndex}. gfxIndex $FF = empty slot. The
; displayed species is arr1[gfxIndex] (the per-floor sprite table at $c4cd).
; See docs/floor_data.md "Monster table".
; -----------------------------------------------------------------------------
SpawnFloorMonsters:
	ld hl, $c4d1           ; arr2 monster table
	ld c, $09              ; 9 slots
.slotLoop:
	push bc
	ld a, [hl+]            ; [+0] col -> pixel x (col*16 - 8)
	swap a
	and $f0
	sub $08
	ld e, a
	ld a, [hl+]            ; [+1] row -> pixel y
	swap a
	and $f0
	sub $08
	ld d, a
	ld a, [hl+]            ; [+2] type   -> cf81
	ld [$cf81], a
	ld a, [hl+]            ; [+3] param  -> cf82
	ld [$cf82], a
	ld a, [hl+]            ; [+4] gfxIndex -> cf80 ($FF = empty)
	ld [$cf80], a
	cp $ff
	jr z, .nextSlot
	push hl
	ld c, a
	ld b, $00
	ld hl, $c4cd           ; arr1 sprite/species table
	add hl, bc
	ld a, [hl]             ; species id = arr1[gfxIndex]
	add a, $30
	cp $3e
	jr c, .gfxResolved
	add a, $02
.gfxResolved:
	ld bc, $0000
	ld [wBankCallTmp], a
	ld a, h
	ld [wSpawnPtr], a
	ld a, l
	ld [wSpawnPtr+1], a
	ld a, $03
	ld hl, $4593
	call Func_00_0467      ; allocate the monster entity
	call Func_01_40c6      ; entity+$20 <- (cf80 & 3) | (cf81 & $70)
	call Func_01_40da      ; entity+$21 <- cf81 & 7
	call Func_01_40e7      ; entity+$06 facing/flags from cf82
	call AdjustEntitySpawnPos   ; nudge spawn position
	call InitEntityHeading      ; type-$39 heading init
	pop hl
.nextSlot:
	pop bc
	dec c
	jr nz, .slotLoop
	ret

; Func_01_40c6 -- entity+$20 <- (cf80 & 3) | (cf81 & $70). (Field meaning undecoded.)
Func_01_40c6:
	ld a, [$cf80]
	and $03
	ld e, a
	ld a, [$cf81]
	and $70
	or e
	push hl
	ld de, $0020
	add hl, de
	ld [hl], a
	pop hl
	ret

; Func_01_40da -- entity+$21 <- cf81 & 7.
Func_01_40da:
	ld a, [$cf81]
	and $07
	push hl
	ld de, $0021
	add hl, de
	ld [hl], a
	pop hl
	ret

; Func_01_40e7 -- set entity+$06 facing/flag bits from the param byte (cf82):
; bit 3 always set; bit 2 from cf82>=4; low 2 bits select a direction case.
Func_01_40e7:
	push hl
	ld de, $0006
	add hl, de
	ld b, [hl]
	set 3, b
	ld a, [$cf82]
	cp $04
	jr c, .clearBit2
	set 2, b
	jr .dispatch
.clearBit2:
	res 2, b
.dispatch:
	ld a, [$cf82]
	and $03
	cp $01
	jr z, .dir1
	cp $02
	jr z, .dir2
	cp $03
	jr z, .dir3
	ld [hl], b
	pop hl
	ret
.dir1:
	ld a, b
	set 7, a
	or $01
	ld [hl], a
	pop hl
	ret
.dir2:
	ld a, b
	or $02
	ld [hl], a
	pop hl
	ret
.dir3:
	ld a, b
	or $03
	ld [hl], a
	pop hl
	ret

; Func_01_4124 -- if cf83 is nonzero, store it to $c2e4. (Used by the bonus path.)
Func_01_4124:
	ld a, [$cf83]
	or a
	ret z
	ld [$c2e4], a
	ret

; AdjustEntitySpawnPos ($412d) -- offset the entity's position fields (+$0c/+$0d)
; by a fixed amount; items (Func_00_1290 bit 6 set) use a different Y nudge.
AdjustEntitySpawnPos:
	push hl
	ld a, [hl]
	call Func_00_1290      ; classify the entity type -> a
	bit 6, a
	jr nz, .openItem
	ld de, $000c
	add hl, de
	ld a, [hl]
	add a, $08
	ld [hl+], a
	inc hl
	ld a, [hl]
	add a, $0f
	ld [hl], a
	pop hl
	ret
.openItem:
	ld de, $000c
	add hl, de
	ld a, [hl]
	add a, $08
	ld [hl+], a
	inc hl
	ld a, [hl]
	add a, $08
	ld [hl], a
	pop hl
	ret

; InitEntityHeading ($4154) -- only for entity type $39: pick which position
; delta field (+$0c or +$0e) to inc/dec from the facing bits at entity+$06.
InitEntityHeading:
	ld a, [hl]
	cp $39
	ret nz
	push bc
	push de
	push hl
	ld de, $0006
	add hl, de
	ld b, [hl]
	pop hl
	bit 2, b
	jr nz, .inverted
	ld a, b
	and $03
	cp $01
	jr z, .incE
	cp $03
	jr z, .incD
	cp $02
	jr z, .decD
	jr .decE
.inverted:
	ld a, b
	and $03
	cp $00
	jr z, .incE
	cp $03
	jr z, .decD
	cp $02
	jr z, .incD
.decE:
	push hl
	ld de, $000e
	add hl, de
	dec [hl]
	pop hl
	jr .done
.incE:
	push hl
	ld de, $000e
	add hl, de
	inc [hl]
	pop hl
	jr .done
.incD:
	push hl
	ld de, $000c
	add hl, de
	inc [hl]
	pop hl
	jr .done
.decD:
	push hl
	ld de, $000c
	add hl, de
	dec [hl]
	pop hl
.done:
	pop de
	pop bc
	ret

; -----------------------------------------------------------------------------
; ProcessFloorSpawners ($41aa) -- process the floor's arr3 spawner table: 4 slots
; x 12 bytes. Per slot: [+0]col [+1]row [+2..+4] rate params (packed into c),
; [+5..+10] six 2-bit params (-> cf84..cf89). A slot whose six params are all $03
; is empty. See docs/floor_data.md "Monster spawners".
; -----------------------------------------------------------------------------
ProcessFloorSpawners:
	ld a, [wRoomType]
	cp $02
	ret z                  ; mode 2 has no arr3 spawners
	ld hl, $c4fe           ; arr3 spawner table
	ld c, $04              ; 4 slots
.slotLoop:
	push bc
	push hl
	ld a, [hl+]            ; [+0] col -> pixel x
	swap a
	and $f0
	sub $08
	ld e, a
	ld a, [hl+]            ; [+1] row -> pixel y
	swap a
	and $f0
	sub $08
	ld d, a
	ld a, [hl+]            ; [+2] p0 -> rate bits
	and $07
	sla a
	sla a
	ld c, a
	ld a, [hl+]            ; [+3] p1
	and $03
	or c
	ld c, a
	ld a, [hl+]            ; [+4] p2
	and $07
	swap a
	sla a
	or c
	ld c, a               ; c = packed spawn-rate value
	call ReadSpawnerParams ; [+5..+10] -> cf84..cf89
	call SpawnerSlotActive
	or a
	jr z, .nextSlot       ; all params $03 -> empty, skip
	push bc
	ld a, $1e
	ld bc, $0000
	ld [wBankCallTmp], a
	ld a, h
	ld [wSpawnPtr], a
	ld a, l
	ld [wSpawnPtr+1], a
	ld a, $03
	ld hl, $4593
	call Func_00_0467      ; allocate the spawner entity
	pop bc
	call Func_01_426d      ; pack cf84..cf89 into entity+$20/+$21
	call Func_01_42a2      ; entity+$06 <- packed rate c
	call Func_01_42aa      ; entity+$05 <- 0 (spawn timer)
	call Func_01_42d9      ; entity+$11 <- velocity vector (Func_01_42b3)
	call AdjustEntitySpawnPos
.nextSlot:
	pop hl
	ld bc, $000c           ; advance 12 bytes to the next slot
	add hl, bc
	pop bc
	dec c
	jr nz, .slotLoop
	ret

; ReadSpawnerParams ($4219) -- read six consecutive 2-bit params into cf84..cf89.
ReadSpawnerParams:
	ld a, [hl+]
	and $03
	ld [$cf84], a
	ld a, [hl+]
	and $03
	ld [$cf85], a
	ld a, [hl+]
	and $03
	ld [$cf86], a
	ld a, [hl+]
	and $03
	ld [$cf87], a
	ld a, [hl+]
	and $03
	ld [$cf88], a
	ld a, [hl+]
	and $03
	ld [$cf89], a
	ret

; SpawnerSlotActive ($423e) -- a = 0 if all six params (cf84..cf89) are $03
; (empty slot), else a = 1.
SpawnerSlotActive:
	ld a, [$cf84]
	cp $03
	jr nz, .active
	ld a, [$cf85]
	cp $03
	jr nz, .active
	ld a, [$cf86]
	cp $03
	jr nz, .active
	ld a, [$cf87]
	cp $03
	jr nz, .active
	ld a, [$cf88]
	cp $03
	jr nz, .active
	ld a, [$cf89]
	cp $03
	jr nz, .active
	xor a
	ret
.active:
	ld a, $01
	ret

; Func_01_426d -- pack cf84..cf86 into entity+$20 and cf87..cf89 into entity+$21.
Func_01_426d:
	ld a, [$cf84]
	ld e, a
	ld a, [$cf85]
	sla a
	sla a
	or e
	ld e, a
	ld a, [$cf86]
	swap a
	or e
	push hl
	ld de, $0020
	add hl, de
	ld [hl], a
	pop hl
	ld a, [$cf87]
	ld e, a
	ld a, [$cf88]
	sla a
	sla a
	or e
	ld e, a
	ld a, [$cf89]
	swap a
	or e
	push hl
	ld de, $0021
	add hl, de
	ld [hl], a
	pop hl
	ret

; Func_01_42a2 -- entity+$06 <- c (the packed spawn-rate value).
Func_01_42a2:
	push hl
	ld de, $0006
	add hl, de
	ld [hl], c
	pop hl
	ret

; Func_01_42aa -- entity+$05 <- 0 (reset spawn timer).
Func_01_42aa:
	push hl
	ld de, $0005
	add hl, de
	xor a
	ld [hl], a
	pop hl
	ret

; Func_01_42b3 -- look up a 16-bit velocity vector in Data_01_42c9 from bits 2-4
; of c, returning it in bc.
Func_01_42b3:
	push hl
	ld a, c
	and $1c
	sra a
	sra a
	sla a
	ld c, a
	ld b, $00
	ld hl, $42c9
	add hl, bc
	ld a, [hl+]
	ld c, a
	ld b, [hl]
	pop hl
	ret


; =============================================================================
; Tower floor grid cleanup passes -- bank $01 cluster ($5676-$572c).
;
; RemoveOpenItemAtCell consumes a single open item (used by the pickup path).
; The three grid-scan passes run from FloorPostLoadCleanup right after a floor
; loads, stripping items from the piece grid that shouldn't appear given current
; progress/run state. Each walks the H x W grid (17-wide WRAM, $0011 row stride).
; See docs/floor_data.md "Conditional-appearance gate".
; =============================================================================

SECTION "layout_cleanup", ROMX[$5676], BANK[$01]

; RemoveOpenItemAtCell ($5676) -- b = row, c = col. If the cell holds an open item
; (collision 0, piece bit7+bit6 set), clear it from the grid, redraw the cell as
; floor, and return the removed piece byte in $ffaa ($ff = nothing taken).
RemoveOpenItemAtCell:
	ld a, $ff
	ldh [$ffaa], a
	push bc
	call ReadFloorCell     ; -> $ffac piece, $ffab collision; c = cell index
	or a                   ; collision != 0 (wall/border/crate)?
	jr nz, .none
	ldh a, [$ffac]
	bit 7, a               ; item?
	jr z, .none
	bit 6, a               ; open?
	jr z, .none
	ldh [$ffaa], a         ; return the taken item
	ld a, c
	ld hl, wFloorGrid
	rst AddAToHL                ; hl = wFloorGrid + cell index
	xor a
	ld [hl], a             ; clear the piece cell
	pop bc
	call DrawFloorPiece    ; redraw as floor (a = 0)
	ret
.none:
	pop bc
	ret

; RemoveKeyPass ($569b) -- when wProgressFlags (wProgressFlags) bit 1 is set, strip the gold KEY
; (open $c0 / hidden $80) from every cell.
RemoveKeyPass:
	ld a, [wProgressFlags]
	bit 1, a
	ret z
	ld hl, wFloorGrid
	ld a, [wFloorHeight]
	ld b, a
.row:
	ld a, [wFloorWidth]
	ld c, a
	push hl
.cell:
	ld a, [hl]
	cp $c0                 ; KEY (open)
	jr z, .clear
	cp $80                 ; KEY (hidden)
	jr nz, .next
.clear:
	xor a
	ld [hl], a
.next:
	inc hl
	dec c
	jr nz, .cell
	pop hl
	ld de, $0011
	add hl, de
	dec b
	jr nz, .row
	ret

; RemoveSilverKeyGate ($56c5) -- gate the silver-key strip on progress flag $09
; (Func_00_119a) and Func_01_47bc; falls through to RemoveSilverKeyPass to strip.
RemoveSilverKeyGate:
	ld a, $09
	call Func_00_119a
	or a
	jr z, RemoveSilverKeyPass
	call Func_01_47bc
	or a
	ret z
	cp $ff
	ret z
	; falls through

; RemoveSilverKeyPass ($56d5) -- strip SILVER_KEY (open $c1 / hidden $81) from
; every cell. (set 6 normalizes the hidden form to the open code before compare.)
RemoveSilverKeyPass:
	ld hl, wFloorGrid
	ld a, [wFloorHeight]
	ld b, a
.row:
	ld a, [wFloorWidth]
	ld c, a
	push hl
.cell:
	ld a, [hl]
	bit 7, a
	jr z, .next
	set 6, a
	cp $c1                 ; SILVER_KEY
	jr nz, .next
	xor a
	ld [hl], a
.next:
	inc hl
	dec c
	jr nz, .cell
	pop hl
	ld de, $0011
	add hl, de
	dec b
	jr nz, .row
	ret

; RemoveConditionalItemsPass ($56fb) -- unless wProgressFlags bit 0 is set, strip every
; item cell whose base id (low 6 bits) has a nonzero flag in Data_01_5162 ($5162).
; This is why $07/$17/$19/$1a/$1b/$1c/$1f appear only via the normal stair path.
RemoveConditionalItemsPass:
	ld a, [wProgressFlags]
	bit 0, a
	ret nz
	ld hl, wFloorGrid
	ld a, [wFloorHeight]
	ld b, a
.row:
	ld a, [wFloorWidth]
	ld c, a
	push hl
.cell:
	ld a, [hl]
	bit 7, a               ; item?
	jr z, .next
	and $3f                ; base id
	push hl
	ld hl, $5162           ; Data_01_5162 per-id flag table
	rst AddAToHL
	ld a, [hl]
	pop hl
	or a
	jr z, .next
	xor a
	ld [hl], a             ; flagged -> remove
.next:
	inc hl
	dec c
	jr nz, .cell
	pop hl
	ld de, $0011
	add hl, de
	dec b
	jr nz, .row
	ret


; =============================================================================
; Item pickup + scoring -- bank $01 cluster ($5007-$5161).
;
; CheckItemPickup tests the player's occupied cells each frame; on a collectible
; it falls into CollectItem, which adds the item's score (AddItemScore, from the
; BCD table Data_01_51aa at $51aa), runs collection tracking (for the "collect N
; for a bonus" items), then tail-calls the item's effect handler via the pointer
; table Data_01_523a ($523a). Those data tables + the effect handlers ($5282+)
; are not carved here yet -- they stay in analyzed.asm, referenced by address.
; See docs/floor_data.md "Item points + effect tables".
; =============================================================================

SECTION "layout_pickup", ROMX[$5007], BANK[$01]

; CheckItemPickup ($5007) -- check the two grid cells the player overlaps for an
; open item; on the first hit, dispatch CollectItem. $ffbc/$ffbe = player x/y,
; $ffd7/$ffd9 reach the second cell. Piece $41 triggers Func_01_5538 (special).
CheckItemPickup:
	ldh a, [hEntityStatus]
	bit 0, a
	ret nz
	ldh a, [hEntityX]
	ld c, a
	ldh a, [hEntityY]
	ld b, a
	ldh a, [$ffd7]
	add a, b
	inc a
	ld b, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a                ; c = column (pixel -> cell)
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a                ; b = row
	call RemoveOpenItemAtCell
	pop bc
	ldh a, [$ffac]
	cp $41
	call z, Func_01_5538
	ldh a, [$ffaa]
	cp $ff
	jr nz, CollectItem     ; an item was taken -> collect it
	ldh a, [$ffd9]
	dec a
	add a, b
	dec a
	ld b, a
	push bc
	ld a, c
	add a, $08
	swap a
	and $0f
	ld c, a
	ld a, b
	add a, $08
	swap a
	and $0f
	ld b, a
	call RemoveOpenItemAtCell
	pop bc
	ldh a, [$ffac]
	cp $41
	call z, Func_01_5538
	ldh a, [$ffaa]
	cp $ff
	ret z
	; falls through into CollectItem

; CollectItem ($5060) -- a = the taken piece byte. Add its score, run collection
; tracking, then jump to its effect handler from Data_01_523a (2-byte LE pointers).
CollectItem:
	sub $c0                ; open item byte -> base id
	call AddItemScore
	call TrackItemCollection
	add a, a               ; base id * 2 (pointer table stride)
	ld e, a
	ld d, $00
	ld hl, $523a           ; Data_01_523a effect-handler pointers
	add hl, de
	ld a, [hl+]
	ld h, [hl]
	ld l, a
	jp hl                  ; tail-call the per-item effect handler

; AddItemScore ($5074) -- a = base id. Add the item's 4-byte big-endian BCD point
; value (Data_01_51aa, 4 bytes/id) to the 5-byte LE-BCD score at wScore.
AddItemScore:
	push af
	push bc
	ld e, a
	ld d, $00
	sla e
	rl d
	sla e
	rl d                   ; de = id * 4
	ld hl, $51aa           ; Data_01_51aa point values
	add hl, de
	ld a, [hl+]
	ld b, a                ; b = MSB
	ld a, [hl+]
	ld c, a
	ld a, [hl+]
	ld d, a
	ld e, [hl]             ; bcde = point value (big-endian BCD)
	ld hl, wScore           ; score, 5 bytes, least-significant first
	ld a, [hl]
	add a, e
	daa
	ld [hl+], a
	ld a, [hl]
	adc a, d
	daa
	ld [hl+], a
	ld a, [hl]
	adc a, c
	daa
	ld [hl+], a
	ld a, [hl]
	adc a, b
	daa
	ld [hl+], a
	ld a, [hl]
	adc a, $00
	daa
	ld [hl], a
	or a
	jr z, RefreshScoreDisplay   ; no carry past the 5th BCD byte -> done
	; score overflowed past 8 digits -> cap it, then fall through

; CapScoreOverflow ($50a7) -- clamp the score to 99999900 (reached only by
; fall-through from AddItemScore when the add carried past the 5-byte field).
CapScoreOverflow:
	ld a, $99
	ld hl, wScore
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	ld [hl+], a
	xor a
	ld [hl], a
	; falls through

; RefreshScoreDisplay ($50b2) -- push the new score to the bank-5 HUD (skipped in
; mode 5), then unwind AddItemScore's saved af/bc.
RefreshScoreDisplay:
	ld a, [wRoomType]
	cp $05
	jr z, .done
	FAR_CALL $05, Func_05_46ba
.done:
	pop bc
	pop af
	ret

; TrackItemCollection ($50c4) -- for "collect a set" items (those with an entry in
; the $5186 table), set the item's collected-bit in $cff4 and drop its cell from
; the collected-position list. Skipped in modes 5 and 2.
TrackItemCollection:
	push af
	push bc
	ld e, a
	ld a, [wRoomType]
	cp $05
	jr z, .done
	cp $02
	jr z, .done
	ld a, c
	add a, $08
	swap a
	and $0f
	ld [$cf8f], a          ; picked cell column
	ld a, b
	add a, $08
	swap a
	and $0f
	ld [$cf90], a          ; picked cell row
	ld d, $00
	ld hl, $5186           ; per-id collectible descriptor ($ff = not tracked)
	add hl, de
	ld a, [hl]
	cp $ff
	jr z, .done
	ld d, a
	ld a, d
	and $07
	ld hl, $1209           ; bit-mask table
	rst AddAToHL
	ld b, [hl]
	ld a, d
	swap a
	and $0f
	ld hl, $cff4           ; collected-flags bitfield
	rst AddAToHL
	ld a, [hl]
	or b
	ld [hl], a
	call RemoveCollectedCell
.done:
	pop bc
	pop af
	ret

; RemoveCollectedCell ($510c) -- find the picked cell (cf8f,cf90) in the 16-entry
; collected-position list at $cf91 and clear it; on a match, run Func_01_57f3 and
; bump the per-floor collection counter.
RemoveCollectedCell:
	xor a
	ld [$cf8e], a
	ld a, [$cf8f]
	ld e, a
	ld a, [$cf90]
	ld d, a
	ld hl, $cf91           ; 16 x {col,row}
	ld c, $10
.scan:
	push hl
	ld a, [hl+]
	cp e
	jr nz, .next
	ld a, [hl]
	cp d
	jr nz, .next
	pop hl
	xor a
	ld [hl+], a
	ld [hl], a
	call Func_01_57f3
	call IncFloorCollectCounter
	ret
.next:
	pop hl
	inc hl
	inc hl
	ld a, [$cf8e]
	inc a
	ld [$cf8e], a
	dec c
	jr nz, .scan
	ret

; IncFloorCollectCounter ($513f) -- increment the collected-count for the active
; floor in the $cff8 table (the index mirrors the LoadFloorByMode mode mapping;
; mode 2 uses Func_00_17c0, returning 0 to skip).
IncFloorCollectCounter:
	ld a, [wRoomType]
	cp $00
	jr z, .mode0
	cp $01
	jr z, .mode1
	call Func_00_17c0
	or a
	ret z
	jr .store
.mode0:
	ld a, [wActiveFloor]
	dec a
	jr .store
.mode1:
	ld a, [wActiveFloor]
	add a, $3b
.store:
	ld hl, $cff8
	rst AddAToHL
	inc [hl]
	ret
