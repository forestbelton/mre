; Item attribute database -- four parallel tables, one entry per item base id
; ($00-$23), consumed by the pickup path in room/engine.asm (CollectItem/AddItemScore/
; TrackItemCollection) and the bank-1 cleanup pass. Item names come from the ITEM
; enum in room.inc; see docs/floor_data.md. Carved from analyzed.asm; the per-item
; effect handlers ($5282+) are referenced by address (still in analyzed.asm).

SECTION "item_gate_flags", ROMX[$5162], BANK[$01]
; RemoveConditionalItemsPass strips an item cell when its flag here is nonzero,
; unless wC2D5 bit 0 is set -- the "only on the normal stair path" items.
ItemGateFlags:
    db $00    ; $00 GOLD_KEY
    db $00    ; $01 SILVER_KEY
    db $00    ; $02 BELL
    db $00    ; $03 HALF_TORORON
    db $00    ; $04 FULL_TORORON
    db $00    ; $05 ORANGE_HOURGLASS
    db $00    ; $06 BLUE_HOURGLASS
    db $01    ; $07 COX_HAT
    db $00    ; $08 BOMB_SMALL
    db $00    ; $09 BOMB_LARGE
    db $00    ; $0a FIREPLACE
    db $00    ; $0b GUNPOWDER
    db $00    ; $0c BLUE_CRYSTAL
    db $00    ; $0d RED_CRYSTAL
    db $00    ; $0e BLUE_DIAMOND
    db $00    ; $0f RED_DIAMOND
    db $00    ; $10 PLATINUM_RING
    db $00    ; $11 SILVER_MEDAL
    db $00    ; $12 SILVER_NUGGET
    db $00    ; $13 GOLD_MEDAL
    db $00    ; $14 GOLD_NUGGET
    db $00    ; $15 HEAL_BADGE
    db $00    ; $16 (unused)
    db $01    ; $17 CAKE
    db $00    ; $18 BATTLE_CARD
    db $01    ; $19 GOLD_PEACH
    db $01    ; $1a SILVER_PEACH
    db $01    ; $1b HARE_ICON
    db $01    ; $1c (unused)
    db $00    ; $1d MONSTER_FLAME
    db $00    ; $1e DUCK_DOLL
    db $01    ; $1f ALF_DOLL
    db $00    ; $20 DISC_STONE_PIECE
    db $00    ; $21 (unused)
    db $00    ; $22 (unused)
    db $00    ; $23 RED_DISC_STONE

SECTION "item_collectible_desc", ROMX[$5186], BANK[$01]
; TrackItemCollection's per-id descriptor ($ff = not a tracked "collect a set" item).
ItemCollectibleDesc:
    db $ff    ; $00 GOLD_KEY
    db $ff    ; $01 SILVER_KEY
    db $00    ; $02 BELL
    db $01    ; $03 HALF_TORORON
    db $02    ; $04 FULL_TORORON
    db $03    ; $05 ORANGE_HOURGLASS
    db $04    ; $06 BLUE_HOURGLASS
    db $05    ; $07 COX_HAT
    db $10    ; $08 BOMB_SMALL
    db $11    ; $09 BOMB_LARGE
    db $12    ; $0a FIREPLACE
    db $13    ; $0b GUNPOWDER
    db $15    ; $0c BLUE_CRYSTAL
    db $14    ; $0d RED_CRYSTAL
    db $17    ; $0e BLUE_DIAMOND
    db $16    ; $0f RED_DIAMOND
    db $21    ; $10 PLATINUM_RING
    db $24    ; $11 SILVER_MEDAL
    db $22    ; $12 SILVER_NUGGET
    db $25    ; $13 GOLD_MEDAL
    db $23    ; $14 GOLD_NUGGET
    db $27    ; $15 HEAL_BADGE
    db $26    ; $16 (unused)
    db $33    ; $17 CAKE
    db $30    ; $18 BATTLE_CARD
    db $35    ; $19 GOLD_PEACH
    db $34    ; $1a SILVER_PEACH
    db $37    ; $1b HARE_ICON
    db $32    ; $1c (unused)
    db $20    ; $1d MONSTER_FLAME
    db $36    ; $1e DUCK_DOLL
    db $31    ; $1f ALF_DOLL
    db $06    ; $20 DISC_STONE_PIECE
    db $ff    ; $21 (unused)
    db $ff    ; $22 (unused)
    db $07    ; $23 RED_DISC_STONE

SECTION "item_points", ROMX[$51aa], BANK[$01]
; 4 bytes/id, big-endian BCD score added by AddItemScore.
ItemPoints:
    db $00,$00,$00,$00  ; $00 GOLD_KEY         = 0
    db $00,$00,$00,$00  ; $01 SILVER_KEY       = 0
    db $00,$00,$00,$00  ; $02 BELL             = 0
    db $00,$00,$00,$00  ; $03 HALF_TORORON     = 0
    db $00,$00,$00,$00  ; $04 FULL_TORORON     = 0
    db $00,$00,$00,$00  ; $05 ORANGE_HOURGLASS = 0
    db $00,$00,$00,$00  ; $06 BLUE_HOURGLASS   = 0
    db $00,$00,$00,$00  ; $07 COX_HAT          = 0
    db $00,$00,$00,$00  ; $08 BOMB_SMALL       = 0
    db $00,$00,$00,$00  ; $09 BOMB_LARGE       = 0
    db $00,$00,$00,$00  ; $0a FIREPLACE        = 0
    db $00,$00,$00,$00  ; $0b GUNPOWDER        = 0
    db $00,$00,$02,$00  ; $0c BLUE_CRYSTAL     = 200
    db $00,$00,$00,$00  ; $0d RED_CRYSTAL      = 0
    db $00,$00,$05,$00  ; $0e BLUE_DIAMOND     = 500
    db $00,$00,$50,$00  ; $0f RED_DIAMOND      = 5000
    db $00,$05,$00,$00  ; $10 PLATINUM_RING    = 50000
    db $00,$00,$01,$00  ; $11 SILVER_MEDAL     = 100
    db $00,$00,$02,$00  ; $12 SILVER_NUGGET    = 200
    db $00,$00,$10,$00  ; $13 GOLD_MEDAL       = 1000
    db $00,$00,$20,$00  ; $14 GOLD_NUGGET      = 2000
    db $00,$01,$00,$00  ; $15 HEAL_BADGE       = 10000
    db $00,$02,$00,$00  ; $16 (unused)         = 20000
    db $00,$10,$00,$00  ; $17 CAKE             = 100000
    db $00,$20,$00,$00  ; $18 BATTLE_CARD      = 200000
    db $00,$50,$00,$00  ; $19 GOLD_PEACH       = 500000
    db $00,$50,$00,$00  ; $1a SILVER_PEACH     = 500000
    db $00,$50,$00,$00  ; $1b HARE_ICON        = 500000
    db $01,$00,$00,$00  ; $1c (unused)         = 1000000
    db $00,$00,$00,$00  ; $1d MONSTER_FLAME    = 0
    db $00,$00,$00,$00  ; $1e DUCK_DOLL        = 0
    db $00,$00,$00,$00  ; $1f ALF_DOLL         = 0
    db $00,$00,$00,$00  ; $20 DISC_STONE_PIECE = 0
    db $00,$00,$00,$00  ; $21 (unused)         = 0
    db $00,$00,$00,$00  ; $22 (unused)         = 0
    db $00,$00,$00,$00  ; $23 RED_DISC_STONE   = 0

SECTION "item_effect_table", ROMX[$523a], BANK[$01]
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
; call Func_01_54d0 (consume + prep), play pickup SFX ($05 via PlaySound), then
; the item-specific effect. Shared helpers ($54d0+) stay in analyzed.asm; the two
; never-collected handlers ($1c, RED_DISC_STONE) are disassembled from ROM gaps.

SECTION "item_effects", ROMX[$5282], BANK[$01]


ItemEffect_ScoreOnly:  ; generic: just the ItemPoints score (gems, coins, medals, peaches)
	call Func_01_54d0
	push af
	ld a, $05
	call PlaySound
	pop af
	ret

ItemEffect_DiscPiece:  ; DISC_STONE_PIECE: +1 piece ($cfd7, cap 4); at 4 -> assemble a stone ($cfd8)
	call Func_01_54d0
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
	call Func_01_54d0
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
	call Func_01_54d0
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
	call Func_01_54d0
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
	call Func_01_54d0
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
	call Func_01_54d0
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
	call Func_01_54d0
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
	call Func_01_54d0
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
	call Func_01_54d0
	push af
	ld a, $05
	call PlaySound
	pop af
	call Func_01_55a6
	ret

ItemEffect_Item1c:  ; $1c: score-only; never placed (stripped by the gate)
	call Func_01_54d0
	push af
	ld a, $05
	call PlaySound
	pop af
	ret

ItemEffect_AlfDoll:  ; ALF_DOLL: transform all monsters into Suzurins ($5544)
	call Func_01_54d0
	push af
	ld a, $05
	call PlaySound
	pop af
	call $5544
	ret

ItemEffect_HalfTororon:  ; HALF_TORORON: time x2 ($c2d4=2, Func_01_5611)
	call Func_01_54d0
	push af
	ld a, $05
	call PlaySound
	pop af
	ld a, $02
	ld [$c2d4], a
	call Func_01_5611
	ret

ItemEffect_FullTororon:  ; FULL_TORORON: time x5 ($c2d4=5, Func_01_562b)
	call Func_01_54d0
	push af
	ld a, $05
	call PlaySound
	pop af
	ld a, $05
	ld [$c2d4], a
	call Func_01_562b
	ret

ItemEffect_OrangeHourglass:  ; ORANGE_HOURGLASS: set floor timer to 50s ($c2d1-$c2d3)
	call Func_01_54d0
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
	call Func_01_54d0
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
	call Func_01_54d0
	push af
	ld a, $05
	call PlaySound
	pop af
	call Func_01_47a9
	ret

ItemEffect_BattleCard:  ; BATTLE_CARD: set battle flag ($c2e8=1; $cff3=1 unless mode 5)
	call Func_01_54d0
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
	call Func_01_54d0
	push af
	ld a, $05
	call PlaySound
	pop af
	ld hl, $c2d5
	set 3, [hl]
	ret

ItemEffect_Item21:  ; $21: collect 4 ($cf7e) -> $cf40=1 + Func_01_5854; never placed
	call Func_01_54d0
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
	call Func_01_54d0
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
	call Func_01_54d0
	push af
	ld a, $05
	call PlaySound
	pop af
	ld bc, $0006
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
