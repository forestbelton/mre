; Bonus stage: Tiger -- record 86, reached from floor 56. See docs/special_floor_records.md.

INCLUDE "room.inc"

SECTION "Tiger room", ROMX

RoomBonusTiger:
    dstruct Header, , .Id=$64, .SpawnX=5, .SpawnY=5, .Pad=$00, .Tileset=$00, .Palette=$00, .Height=10, .Width=11
    assert @ - RoomBonusTiger == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_C, COLL_C, COLL_F, COLL_C, COLL_C, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_C, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_F, COLL_C, COLL_C, COLL_C, COLL_F, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_C, COLL_F, COLL_F, COLL_F, COLL_C, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_F, COLL_C, COLL_C, COLL_C, COLL_F, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_C, COLL_F, COLL_C, COLL_F, COLL_C, COLL_F, COLL_C, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_C, COLL_C, COLL_F, COLL_C, COLL_C, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_DISC_STONE_PIECE, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_DISC_STONE_PIECE, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, TILE_EXIT, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_FIREPLACE, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_RED_DIAMOND, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_NUGGET, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_MEDAL, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BELL, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_DISC_STONE_PIECE, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_NUGGET, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table
    db MONSTER_TACOPI, MONSTER_JELL, MONSTER_NAGA, MONSTER_TIGER

    ; arr2: 9 monster slots
.monsters
    dstruct Monster, , .X=6, .Y=3, .Type=$22, .Param=$00, .Index=3
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

Data_12_635f:
	db $2e, $aa, $d5, $67, $55, $45, $ba, $aa, $55, $75, $aa, $ab, $aa, $aa, $55, $15
	db $55, $55, $a8, $8a, $aa, $aa, $97, $91, $0e, $a2, $5d, $e5, $05, $55, $ab, $a2
	db $aa, $aa, $55, $15, $54, $51, $aa, $aa, $55, $54, $a9, $ba, $aa, $aa, $11, $57
	db $54, $55, $aa, $ab, $aa, $aa, $6f, $45, $ac, $aa, $55, $c6, $d7, $61, $a3, $ea
	db $bf, $40, $55, $15, $7d, $55, $8a, $72, $51, $7d, $aa, $a2, $aa, $aa, $4c, $15
	db $d5, $55, $8b, $aa, $a8, $aa, $f7, $74, $ba, $aa, $d1, $55, $b5, $8d, $2a, $e2
	db $6a, $8e, $75, $45, $dd, $5d, $aa, $b8, $55, $54, $aa, $be, $ba, $aa, $47, $77
	db $55, $55, $aa, $a2, $aa, $2a, $c5, $77, $23, $ba, $15, $61, $55, $5d, $6a, $ea
	db $8b, $aa, $10, $55, $55, $55, $aa, $bb, $55, $55, $a8, $ae, $aa, $ba, $55, $75
	db $44, $55, $be, $ae, $af, $aa, $55, $58, $aa, $aa, $d7, $47, $15, $50, $8a, $ab
	db $aa, $8a, $55, $f5, $4d, $55, $e2, $b8, $55, $55, $a2, $8a, $aa, $8a, $75, $d7
	db $57, $51, $aa, $8a, $aa, $e8, $15, $55, $22, $aa, $55, $55, $65, $61, $aa, $2a
	db $aa, $a3, $55, $05, $55, $57, $aa, $9a, $75, $55, $aa, $ab, $aa, $82, $55, $55
	db $57, $55, $ab, $aa, $ba, $2a, $54, $55, $aa, $aa, $77, $15, $55, $5d, $aa, $8a
	db $ae, $ea, $55, $55, $55, $55, $2a, $bb, $45, $55, $aa, $a2, $aa, $ea, $5a, $5d
	db $41, $55, $02, $ab, $a8, $aa, $33, $55, $e8, $ae, $44, $45, $55, $dd, $aa, $ab
