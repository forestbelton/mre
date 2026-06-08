; Bonus stage: Golem -- record 84, reached from floor 22. See docs/special_floor_records.md.

INCLUDE "room.inc"

SECTION "Golem room", ROMX

RoomBonusGolem:
    dstruct Header, , .Id=$68, .SpawnX=5, .SpawnY=1, .Pad=$00, .Tileset=$00, .Palette=$00, .Height=10, .Width=11
    assert @ - RoomBonusGolem == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_C, COLL_C, COLL_F, COLL_C, COLL_C, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, ITEM_FLAG | ITEM_OPEN | ITEM_RED_DIAMOND, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, TILE_EXIT, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_COX_HAT, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_DISC_STONE_PIECE, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BELL, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_DISC_STONE_PIECE, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BLUE_DIAMOND, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_MEDAL, COLL_F, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_BELL, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_DISC_STONE_PIECE, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table
    db MONSTER_TACOPI, MONSTER_JELL, MONSTER_NAGA, MONSTER_GOLEM

    ; arr2: 9 monster slots
.monsters
    dstruct Monster, , .X=5, .Y=5, .Type=$22, .Param=$00, .Index=3
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    assert @ - .monsters == sizeof_Monster * 9

    ; arr3: 4 spawner slots
.spawners
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    assert @ - .spawners == sizeof_Spawner * 4

Data_12_5ed5:
	db $00, $00, $e0, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $c1
	db $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $c6, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $c4, $00, $20, $20, $00, $00, $00, $c2, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $c2, $00, $00, $20, $20, $43, $43, $43
	db $43, $43, $00, $00, $00, $00, $00, $43, $43, $43, $43, $43, $20, $20, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $00
	db $07, $02, $0e, $08, $0c, $24, $02, $01, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff
	db $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01
	db $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff
	db $0d, $01, $01, $01, $04, $00, $02, $ff, $ff, $ff, $ff, $ff, $03, $01, $01, $00
	db $04, $02, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
