; Item attribute database -- four parallel tables, one entry per item base id
; ($00-$23), consumed by the pickup path in room/engine.asm (CollectItem/AddItemScore/
; TrackItemCollection) and the bank-1 cleanup pass. Item names come from the ITEM
; enum in room.inc; see docs/floor_data.md. Carved from analyzed.asm; the per-item
; effect handlers ($5282+) are referenced by address (still in analyzed.asm).
INCLUDE "bcd.inc"
INCLUDE "enum.inc"
INCLUDE "room.inc"

SECTION "items", ROMX

; RemoveConditionalItemsPass strips an item cell when its flag here is nonzero,
; unless wC2D5 bit 0 is set -- the "only on the normal stair path" items.
ItemGateFlags: enum_table ITEM, byte, * = $00, \
    .GOLD_KEY = $00, \
    .SILVER_KEY = $00, \
    .BELL = $00, \
    .HALF_TORORON = $00, \
    .FULL_TORORON = $00, \
    .ORANGE_HOURGLASS = $00, \
    .BLUE_HOURGLASS = $00, \
    .COX_HAT = $01, \
    .BOMB_SMALL = $00, \
    .BOMB_LARGE = $00, \
    .FIREPLACE = $00, \
    .GUNPOWDER = $00, \
    .BLUE_CRYSTAL = $00, \
    .RED_CRYSTAL = $00, \
    .BLUE_DIAMOND = $00, \
    .RED_DIAMOND = $00, \
    .PLATINUM_RING = $00, \
    .SILVER_MEDAL = $00, \
    .SILVER_NUGGET = $00, \
    .GOLD_MEDAL = $00, \
    .GOLD_NUGGET = $00, \
    .HEAL_BADGE = $00, \
    .WALKING_COIN = $00, \
    .CAKE = $01, \
    .BATTLE_CARD = $00, \
    .GOLD_PEACH = $01, \
    .SILVER_PEACH = $01, \
    .HARE_ICON = $01, \
    .AYA_DOLL = $01, \
    .MONSTER_FLAME = $00, \
    .DUCK_DOLL = $00, \
    .ALF_DOLL = $01, \
    .DISC_STONE_PIECE = $00, \
    .RED_DISC_STONE = $00,

; TrackItemCollection's per-id descriptor ($ff = not a tracked "collect a set" item).
ItemCollectibleDesc: enum_table ITEM, byte, * = $ff, \
    .GOLD_KEY = $ff, \
    .SILVER_KEY = $ff, \
    .BELL = $00, \
    .HALF_TORORON = $01, \
    .FULL_TORORON = $02, \
    .ORANGE_HOURGLASS = $03, \
    .BLUE_HOURGLASS = $04, \
    .COX_HAT = $05, \
    .BOMB_SMALL = $10, \
    .BOMB_LARGE = $11, \
    .FIREPLACE = $12, \
    .GUNPOWDER = $13, \
    .BLUE_CRYSTAL = $15, \
    .RED_CRYSTAL = $14, \
    .BLUE_DIAMOND = $17, \
    .RED_DIAMOND = $16, \
    .PLATINUM_RING = $21, \
    .SILVER_MEDAL = $24, \
    .SILVER_NUGGET = $22, \
    .GOLD_MEDAL = $25, \
    .GOLD_NUGGET = $23, \
    .HEAL_BADGE = $27, \
    .WALKING_COIN = $26, \
    .CAKE = $33, \
    .BATTLE_CARD = $30, \
    .GOLD_PEACH = $35, \
    .SILVER_PEACH = $34, \
    .HARE_ICON = $37, \
    .AYA_DOLL = $32, \
    .MONSTER_FLAME = $20, \
    .DUCK_DOLL = $36, \
    .ALF_DOLL = $31, \
    .DISC_STONE_PIECE = $06, \
    .RED_DISC_STONE = $07,

; 4 bytes/id, big-endian BCD score added by AddItemScore.
ItemPoints:
	BCD4 0       ; GOLD_KEY
	BCD4 0       ; SILVER_KEY
	BCD4 0       ; BELL
	BCD4 0       ; HALF_TORORON
	BCD4 0       ; FULL_TORORON
	BCD4 0       ; ORANGE_HOURGLASS
	BCD4 0       ; BLUE_HOURGLASS
	BCD4 0       ; COX_HAT
	BCD4 0       ; BOMB_SMALL
	BCD4 0       ; BOMB_LARGE
	BCD4 0       ; FIREPLACE
	BCD4 0       ; GUNPOWDER
	BCD4 200     ; BLUE_CRYSTAL
	BCD4 0       ; RED_CRYSTAL
	BCD4 500     ; BLUE_DIAMOND
	BCD4 5000    ; RED_DIAMOND
	BCD4 50000   ; PLATINUM_RING
	BCD4 100     ; SILVER_MEDAL
	BCD4 200     ; SILVER_NUGGET
	BCD4 1000    ; GOLD_MEDAL
	BCD4 2000    ; GOLD_NUGGET
	BCD4 10000   ; HEAL_BADGE
	BCD4 20000   ; WALKING_COIN
	BCD4 100000  ; CAKE
	BCD4 200000  ; BATTLE_CARD
	BCD4 500000  ; GOLD_PEACH
	BCD4 500000  ; SILVER_PEACH
	BCD4 500000  ; HARE_ICON
	BCD4 1000000 ; AYA_DOLL
	BCD4 0       ; MONSTER_FLAME
	BCD4 0       ; DUCK_DOLL
	BCD4 0       ; ALF_DOLL
	BCD4 0       ; DISC_STONE_PIECE
	BCD4 0       ; $21 (unused)
	BCD4 0       ; $22 (unused)
	BCD4 0       ; RED_DISC_STONE

; 2 bytes/id, LE pointer to the bank-1 effect handler ($5282 = generic score-only).
ItemEffectHandlers:
    dw ItemEffect_GoldKey  ; $00 GOLD_KEY
    dw ItemEffect_SilverKey  ; $01 SILVER_KEY
    dw ItemEffect_Bell  ; $02 BELL
    dw ItemEffect_HalfTororon  ; $03 HALF_TORORON
    dw ItemEffect_FullTororon  ; $04 FULL_TORORON
    dw ItemEffect_OrangeHourglass  ; $05 ORANGE_HOURGLASS
    dw ItemEffect_BlueHourglass  ; $06 BLUE_HOURGLASS
    dw ItemEffect_CoxHat  ; $07 COX_HAT
    dw ItemEffect_BombSmall  ; $08 BOMB_SMALL
    dw ItemEffect_BombLarge  ; $09 BOMB_LARGE
    dw ItemEffect_Fireplace  ; $0a FIREPLACE
    dw ItemEffect_Gunpowder  ; $0b GUNPOWDER
    dw ItemEffect_BlueCrystal  ; $0c BLUE_CRYSTAL
    dw ItemEffect_RedCrystal  ; $0d RED_CRYSTAL
    dw ItemEffect_ScoreOnly  ; $0e BLUE_DIAMOND     (score only)
    dw ItemEffect_ScoreOnly  ; $0f RED_DIAMOND      (score only)
    dw ItemEffect_ScoreOnly  ; $10 PLATINUM_RING    (score only)
    dw ItemEffect_ScoreOnly  ; $11 SILVER_MEDAL     (score only)
    dw ItemEffect_ScoreOnly  ; $12 SILVER_NUGGET    (score only)
    dw ItemEffect_ScoreOnly  ; $13 GOLD_MEDAL       (score only)
    dw ItemEffect_ScoreOnly  ; $14 GOLD_NUGGET      (score only)
    dw ItemEffect_ScoreOnly  ; $15 HEAL_BADGE       (score only)
    dw ItemEffect_ScoreOnly  ; $16 (unused)         (score only)
    dw ItemEffect_ScoreOnly  ; $17 CAKE             (score only)
    dw ItemEffect_BattleCard  ; $18 BATTLE_CARD
    dw ItemEffect_ScoreOnly  ; $19 GOLD_PEACH       (score only)
    dw ItemEffect_ScoreOnly  ; $1a SILVER_PEACH     (score only)
    dw ItemEffect_ScoreOnly  ; $1b HARE_ICON        (score only)
    dw ItemEffect_Item1c  ; $1c (unused)
    dw ItemEffect_MonsterFlame  ; $1d MONSTER_FLAME
    dw ItemEffect_DuckDoll  ; $1e DUCK_DOLL
    dw ItemEffect_AlfDoll  ; $1f ALF_DOLL
    dw ItemEffect_DiscPiece  ; $20 DISC_STONE_PIECE
    dw ItemEffect_Item21  ; $21 (unused)
    dw ItemEffect_Item22  ; $22 (unused)
    dw ItemEffect_RedDiscStone  ; $23 RED_DISC_STONE

; Item pickup effect handlers (bank $01, $5282-$54cf). Dispatched indirectly
; from ItemEffectHandlers (item_data.asm) by CollectItem (jp hl). Shared shape:
; call SpawnPickupEffect (the sparkle/popup at the item's cell -- the item itself
; was already cleared from the grid by RemoveOpenItemAtCell), play pickup SFX ($05
; via PlaySound), then the item-specific effect. Shared helpers ($54d0+) stay in
; analyzed.asm; the two
; never-collected handlers ($1c, RED_DISC_STONE) are disassembled from ROM gaps.
ItemEffect_ScoreOnly:  ; generic: just the ItemPoints score (gems, coins, medals, peaches)
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	ret

ItemEffect_DiscPiece:  ; DISC_STONE_PIECE: +1 piece ($cfd7, cap 4); at 4 -> assemble a stone ($cfd8)
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	ld hl, $cfd7
	ld a, [hl]
	inc a
	ld [hl], a
	cp $04
	ret c
	ld a, $04
	ld [hl], a
	ld hl, $cfd8
	ld a, [hl]
	cp $09
	ret z
	inc a
	ld [hl], a
	ld hl, $cfd7
	ld a, [hl]
	sub $04
	ld [hl], a
	ret

ItemEffect_Fireplace:  ; FIREPLACE: +1 bomb slot ($c2cb, max 8)
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	ld hl, $c2cb
	ld a, [hl]
	cp $08
	ret z
	inc [hl]
	ret

ItemEffect_Gunpowder:  ; GUNPOWDER: if a bomb is held, flag bomb 0 large ($c2cd bit 0)
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	ld a, [$c2cc]
	or a
	ret z
	ld hl, $c2cd
	set 0, [hl]
	ret

ItemEffect_BombSmall:  ; BOMB_SMALL: +1 held bomb ($c2cc), small type
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	ld a, [$c2cb]
	ld b, a
	ld a, [$c2cc]
	cp b
	ret z
	inc a
	ld [$c2cc], a
	ld c, a
	ld b, $01
.L52f6:
	dec c
	jr z, .L52fd
	sla b
	jr .L52f6
.L52fd:
	ld a, b
	xor $ff
	ld b, a
	ld hl, $c2cd
	ld a, [hl]
	and b
	ld [hl], a
	ret

ItemEffect_BombLarge:  ; BOMB_LARGE: +1 held bomb, large/piercing type
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	ld a, [$c2cb]
	ld b, a
	ld a, [$c2cc]
	cp b
	ret z
	inc a
	ld [$c2cc], a
	ld c, a
	ld b, $01
.L5322:
	dec c
	jr z, .L5329
	sla b
	jr .L5322
.L5329:
	ld hl, $c2cd
	ld a, [hl]
	or b
	ld [hl], a
	ret

ItemEffect_BlueCrystal:  ; BLUE_CRYSTAL: add to the crystal score counter ($c2ce)
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	ld hl, $c2ce
	ld a, [hl]
	add a, $04
	ld [hl+], a
	ld a, [hl]
	adc a, $00
	ld [hl], a
	ret

ItemEffect_RedCrystal:  ; RED_CRYSTAL: add (more) to the crystal score counter ($c2ce)
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	ld hl, $c2ce
	ld a, [hl]
	add a, $10
	ld [hl+], a
	ld a, [hl]
	adc a, $00
	ld [hl], a
	ret

ItemEffect_Bell:  ; BELL: spawn a Suzurin pickup at the $c52e/$c52f slot (gfx $1f)
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	ld a, [$c52f]
	cp $ff
	ret z
	swap a
	and $f0
	ld d, a
	ld a, [$c52e]
	swap a
	and $f0
	ld e, a
	ld bc, $0000
	ld a, $1f
	ld [$c29c], a
	ld a, h
	ld [$c2a1], a
	ld a, l
	ld [$c2a2], a
	ld a, $03
	ld hl, $4593
	call Func_00_0467
	ret

ItemEffect_DuckDoll:  ; DUCK_DOLL: transform all monsters (Func_01_55a6)
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	call Func_01_55a6
	ret

ItemEffect_Item1c:  ; $1c: score-only; never placed (stripped by the gate)
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	ret

ItemEffect_AlfDoll:  ; ALF_DOLL: transform all monsters into Suzurins ($5544)
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	call Func_01_5544
	ret

ItemEffect_HalfTororon:  ; HALF_TORORON: time x2 ($c2d4=2, Func_01_5611)
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	ld a, $02
	ld [$c2d4], a
	call Func_01_5611
	ret

ItemEffect_FullTororon:  ; FULL_TORORON: time x5 ($c2d4=5, Func_01_562b)
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	ld a, $05
	ld [$c2d4], a
	call Func_01_562b
	ret

ItemEffect_OrangeHourglass:  ; ORANGE_HOURGLASS: set floor timer to 50s ($c2d1-$c2d3)
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	ld hl, $c2d3
	xor a
	ld [hl-], a
	ld a, $50
	ld [hl-], a
	xor a
	ld [hl], a
	ret

ItemEffect_BlueHourglass:  ; BLUE_HOURGLASS: set floor timer to 100s
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	ld hl, $c2d3
	ld a, $01
	ld [hl-], a
	xor a
	ld [hl-], a
	ld [hl], a
	ret

ItemEffect_CoxHat:  ; COX_HAT: +1 life ($c2c3 BCD, cap 99); 1-up SFX $08
	call Func_01_5504
	push af
	ld a, $08
	call PlaySound
	pop af
	ld hl, $c2c3
	ld a, [hl]
	cp $99
	ret z
	add a, $01
	daa
	ld [hl], a
	ret

ItemEffect_GoldKey:  ; GOLD_KEY: unlock the exit ($c2d5 bit 1; Func_01_5854)
	ld hl, $c2d5
	set 1, [hl]
	ld c, $01
	call Func_01_5854
	ret

ItemEffect_SilverKey:  ; SILVER_KEY: unlock a basement room (Func_01_47a9)
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	call Func_01_47a9
	ret

ItemEffect_BattleCard:  ; BATTLE_CARD: set battle flag ($c2e8=1; $cff3=1 unless mode 5)
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	ld a, $01
	ld [$c2e8], a
	ld a, [$c2c1]
	cp $05
	ret z
	ld a, $01
	ld [$cff3], a
	ret

ItemEffect_MonsterFlame:  ; MONSTER_FLAME: flag the bonus-stage warp ($c2d5 bit 3)
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	ld hl, $c2d5
	set 3, [hl]
	ret

ItemEffect_Item21:  ; $21: collect 4 ($cf7e) -> $cf40=1 + Func_01_5854; never placed
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	ld a, [$cf7e]
	inc a
	ld [$cf7e], a
	cp $04
	ret nz
	xor a
	ld [$cf7e], a
	ld a, $01
	ld [$cf40], a
	ld c, $04
	call Func_01_5854
	ret

ItemEffect_Item22:  ; $22: key-like ($c2d5 bit 7 + Func_01_47a9); never placed
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	ld hl, $c2d5
	set 7, [hl]
	call Func_01_47a9
	ld a, $01
	ld [$c2d6], a
	ret

ItemEffect_RedDiscStone:  ; RED_DISC_STONE: completed disc stone -> Phoenix; SFX $28, bumps $cfda+6
	push af
	ld a, $28
	call PlaySoundTracked
	pop af
	call SpawnPickupEffect
	push af
	ld a, $05
	call PlaySound
	pop af
	ld bc, SUMMON_PHOENIX
	ld hl, wMonsterDiscStones
	add hl, bc
	ld a, [hl]
	cp $09
	jr z, .L54bb
	inc [hl]
.L54bb:
	ld hl, $c2d5
	set 7, [hl]
	ld c, $06
	ld a, $0f
	ld hl, $488d
	call CallBankedHL
	ld a, $01
	ld [$c2d6], a
	ret
