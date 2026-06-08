; Bonus stage: Suezo -- record 85, reached from floor 44. See docs/special_floor_records.md.

INCLUDE "room.inc"

SECTION "Suezo room", ROMX

RoomBonusSuezo:
    dstruct Header, , .Id=$69, .SpawnX=5, .SpawnY=4, .Pad=$00, .Tileset=$00, .Palette=$00, .Height=10, .Width=11
    assert @ - RoomBonusSuezo == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_C, COLL_C, COLL_F, COLL_C, COLL_C, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_C, COLL_F, COLL_C, COLL_F, COLL_C, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_F, COLL_C, COLL_F, COLL_C, COLL_F, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_C, COLL_F, COLL_C, COLL_C, COLL_F, COLL_C, COLL_C, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_NUGGET, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, TILE_EXIT, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_COX_HAT, COLL_B
    db COLL_B, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_DISC_STONE_PIECE, ITEM_FLAG | ITEM_OPEN | ITEM_RED_DIAMOND, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_DISC_STONE_PIECE, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_DISC_STONE_PIECE, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BLUE_DIAMOND, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_NUGGET, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BELL, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table
    db MONSTER_NAGA, MONSTER_FLAME_BLUE, MONSTER_JELL, MONSTER_SUEZO

    ; arr2: 9 monster slots
.monsters
    dstruct Monster, , .X=2, .Y=3, .Type=$22, .Facing=$00, .Index=1
    dstruct Monster, , .X=8, .Y=3, .Type=$22, .Facing=$00, .Index=1
    dstruct Monster, , .X=5, .Y=8, .Type=$22, .Facing=$00, .Index=3
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

Data_12_611a:
	db $00, $43, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $43, $00, $d6, $00
	db $d6, $00, $43, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $43, $00, $00
	db $00, $40, $00, $43, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $43, $00
	db $00, $00, $00, $00, $43, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $43
	db $43, $43, $43, $43, $43, $43, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00
	db $00, $00, $00, $00, $00, $43, $00, $00, $00, $00, $20, $20, $00, $00, $00, $c0
	db $00, $c7, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00
	db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20
	db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $0c
	db $09, $01, $0e, $09, $06, $24, $00, $01, $09, $04, $24, $04, $01, $06, $08, $22
	db $00, $00, $0f, $0c, $22, $00, $02, $04, $08, $22, $00, $00, $ff, $ff, $ff, $01
	db $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
	db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
