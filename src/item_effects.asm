; Item pickup effect handlers (bank $01, $5282-$54cf). Dispatched indirectly
; from ItemEffectHandlers (item_data.asm) by CollectItem (jp hl). Shared shape:
; call Func_01_54d0 (consume + prep), play pickup SFX ($05 via CallLibFunc), then
; the item-specific effect. Shared helpers ($54d0+) stay in analyzed.asm; the two
; never-collected handlers ($1c, RED_DISC_STONE) are disassembled from ROM gaps.

SECTION "item_effects", ROMX[$5282], BANK[$01]


ItemEffect_ScoreOnly:  ; generic: just the ItemPoints score (gems, coins, medals, peaches)
	call Func_01_54d0
	push af
	ld a, $05
	call CallLibFunc
	pop af
	ret

ItemEffect_DiscPiece:  ; DISC_STONE_PIECE: +1 piece ($cfd7, cap 4); at 4 -> assemble a stone ($cfd8)
	call Func_01_54d0
	push af
	ld a, $05
	call CallLibFunc
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
	call CallLibFunc
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
	call CallLibFunc
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
	call CallLibFunc
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
	call CallLibFunc
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
	call CallLibFunc
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
	call CallLibFunc
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
	call CallLibFunc
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
	call CallLibFunc
	pop af
	call Func_01_55a6
	ret

ItemEffect_Item1c:  ; $1c: score-only; never placed (stripped by the gate)
	call Func_01_54d0
	push af
	ld a, $05
	call CallLibFunc
	pop af
	ret

ItemEffect_AlfDoll:  ; ALF_DOLL: transform all monsters into Suzurins ($5544)
	call Func_01_54d0
	push af
	ld a, $05
	call CallLibFunc
	pop af
	call $5544
	ret

ItemEffect_HalfTororon:  ; HALF_TORORON: time x2 ($c2d4=2, Func_01_5611)
	call Func_01_54d0
	push af
	ld a, $05
	call CallLibFunc
	pop af
	ld a, $02
	ld [$c2d4], a
	call Func_01_5611
	ret

ItemEffect_FullTororon:  ; FULL_TORORON: time x5 ($c2d4=5, Func_01_562b)
	call Func_01_54d0
	push af
	ld a, $05
	call CallLibFunc
	pop af
	ld a, $05
	ld [$c2d4], a
	call Func_01_562b
	ret

ItemEffect_OrangeHourglass:  ; ORANGE_HOURGLASS: set floor timer to 50s ($c2d1-$c2d3)
	call Func_01_54d0
	push af
	ld a, $05
	call CallLibFunc
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
	call CallLibFunc
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
	call CallLibFunc
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
	call CallLibFunc
	pop af
	call Func_01_47a9
	ret

ItemEffect_BattleCard:  ; BATTLE_CARD: set battle flag ($c2e8=1; $cff3=1 unless mode 5)
	call Func_01_54d0
	push af
	ld a, $05
	call CallLibFunc
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
	call CallLibFunc
	pop af
	ld hl, $c2d5
	set 3, [hl]
	ret

ItemEffect_Item21:  ; $21: collect 4 ($cf7e) -> $cf40=1 + Func_01_5854; never placed
	call Func_01_54d0
	push af
	ld a, $05
	call CallLibFunc
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
	call CallLibFunc
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
	call CallLibFuncSaveId
	pop af
	call Func_01_54d0
	push af
	ld a, $05
	call CallLibFunc
	pop af
	ld bc, $0006
	ld hl, $cfda
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
