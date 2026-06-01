; Floor 18 (record 17) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room18", ROMX[$6695], BANK[$2d]
Room18:
    dstruct Header, , .Type=$0e, .SpawnX=9, .SpawnY=8, .Pad=$00, .Param0=$00, .Param1=$00, .Height=10, .Width=11
    assert @ - Room18 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_W, COLL_C, COLL_W, COLL_W, COLL_C, COLL_W, COLL_W, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_W, COLL_C, COLL_F, COLL_W, COLL_F, COLL_W, COLL_F, COLL_C, COLL_W, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_W, COLL_C, COLL_C, COLL_C, COLL_W, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_C, COLL_F, COLL_W, COLL_F, COLL_W, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_F, COLL_F, COLL_W, COLL_F, COLL_F, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_BELL, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_MEDAL, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_MEDAL, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_MEDAL, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_FIREPLACE, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, TILE_EXIT, COLL_F, COLL_F, ITEM_FLAG | ITEM_SILVER_NUGGET, COLL_F, ITEM_FLAG | ITEM_MONSTER_FLAME, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_DINO, MONSTER_PSYLORA, MONSTER_JELL, MONSTER_GOLEM

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=8, .Y=3, .Type=$21, .Param=$01, .Index=0   ; DINO
    dstruct Monster, , .X=2, .Y=3, .Type=$21, .Param=$00, .Index=0   ; DINO
    dstruct Monster, , .X=5, .Y=3, .Type=$21, .Param=$07, .Index=1   ; PSYLORA
    dstruct Monster, , .X=6, .Y=1, .Type=$23, .Param=$00, .Index=2   ; JELL
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    assert @ - .monsters == sizeof_Monster * 9

    ; arr3: 8 spawner slots (Spawner: X,Y,P0,P1,P2,Index)
.spawners
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    assert @ - .spawners == sizeof_Spawner * 8
