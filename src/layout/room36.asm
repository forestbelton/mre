; Floor 36 (record 35) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room36", ROMX[$5228], BANK[$2e]
Room36:
    dstruct Header, , .Type=$46, .SpawnX=9, .SpawnY=8, .Pad=$00, .Param0=$00, .Param1=$00, .Height=10, .Width=11
    assert @ - Room36 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, TILE_EXIT, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_KEY, ITEM_FLAG | ITEM_OPEN | ITEM_BLUE_DIAMOND, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_RED_DIAMOND, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BLUE_DIAMOND, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_MEDAL, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_TACOPI, MONSTER_DUCKEN, MONSTER_NAGA, MONSTER_TIGER

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=9, .Y=5, .Type=$22, .Param=$01, .Index=1   ; DUCKEN
    dstruct Monster, , .X=1, .Y=3, .Type=$22, .Param=$00, .Index=1   ; DUCKEN
    dstruct Monster, , .X=1, .Y=6, .Type=$22, .Param=$00, .Index=1   ; DUCKEN
    dstruct Monster, , .X=9, .Y=2, .Type=$22, .Param=$01, .Index=1   ; DUCKEN
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    assert @ - .monsters == sizeof_Monster * 9

    ; arr3: 4 spawner slots (Spawner: X,Y,P0,P1,P2,Spawn0..5,End)
.spawners
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    assert @ - .spawners == sizeof_Spawner * 4
