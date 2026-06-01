; Floor 66 (record 65) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "roomB06", ROMX[$58f7], BANK[$2f]
RoomB06:
    dstruct Header, , .Type=$2a, .SpawnX=1, .SpawnY=1, .Pad=$00, .Param0=$02, .Param1=$06, .Height=10, .Width=11
    assert @ - RoomB06 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_C, COLL_W, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_C, COLL_W, COLL_W, COLL_W, COLL_F, COLL_W, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_C, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_F, COLL_C, COLL_F, COLL_C, COLL_F, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_C, COLL_F, COLL_C, COLL_F, COLL_W, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, TILE_EXIT, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, TILE_OBSTACLE_BAT, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_PSYLORA, MONSTER_JELL, MONSTER_NAGA, MONSTER_TIGER

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=7, .Y=7, .Type=$22, .Param=$00, .Index=0   ; PSYLORA
    dstruct Monster, , .X=7, .Y=2, .Type=$22, .Param=$00, .Index=0   ; PSYLORA
    dstruct Monster, , .X=9, .Y=6, .Type=$22, .Param=$00, .Index=0   ; PSYLORA
    dstruct Monster, , .X=8, .Y=3, .Type=$22, .Param=$00, .Index=0   ; PSYLORA
    dstruct Monster, , .X=7, .Y=4, .Type=$22, .Param=$00, .Index=0   ; PSYLORA
    dstruct Monster, , .X=5, .Y=7, .Type=$22, .Param=$00, .Index=0   ; PSYLORA
    dstruct Monster, , .X=3, .Y=7, .Type=$22, .Param=$00, .Index=0   ; PSYLORA
    dstruct Monster, , .X=1, .Y=8, .Type=$22, .Param=$00, .Index=0   ; PSYLORA
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
