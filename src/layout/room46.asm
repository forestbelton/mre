; Floor 46 (record 45) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room46", ROMX[$68da], BANK[$2e]
Room46:
    dstruct Header, , .Type=$13, .SpawnX=5, .SpawnY=8, .Pad=$00, .Param0=$01, .Param1=$05, .Height=10, .Width=11
    assert @ - Room46 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_C, COLL_W, COLL_C, COLL_C, COLL_C, COLL_W, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_C, COLL_C, COLL_C, COLL_C, COLL_F, COLL_W, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_W, COLL_C, COLL_C, COLL_F, COLL_C, COLL_W, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_C, COLL_F, COLL_C, COLL_C, COLL_C, COLL_W, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_C, COLL_C, COLL_C, COLL_C, COLL_W, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_C, COLL_C, COLL_W, COLL_C, COLL_C, COLL_W, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_NUGGET, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_NUGGET, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BELL, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_NUGGET, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, TILE_EXIT, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_RED_DIAMOND, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_RED_DIAMOND, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_FLAME_BLUE, MONSTER_JELL, MONSTER_NAGA, MONSTER_TIGER

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=4, .Y=5, .Type=$22, .Param=$00, .Index=0   ; FLAME_BLUE
    dstruct Monster, , .X=6, .Y=4, .Type=$22, .Param=$00, .Index=0   ; FLAME_BLUE
    dstruct Monster, , .X=7, .Y=3, .Type=$22, .Param=$00, .Index=0   ; FLAME_BLUE
    dstruct Monster, , .X=5, .Y=1, .Type=$22, .Param=$00, .Index=0   ; FLAME_BLUE
    dstruct Monster, , .X=3, .Y=1, .Type=$22, .Param=$00, .Index=0   ; FLAME_BLUE
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
