; Floor 33 (record 32) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room33", ROMX[$4b59], BANK[$2e]
Room33:
    dstruct Header, , .Type=$26, .SpawnX=5, .SpawnY=7, .Pad=$00, .Param0=$01, .Param1=$04, .Height=10, .Width=11
    assert @ - Room33 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_C, COLL_C, COLL_W, COLL_C, COLL_C, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_W, COLL_C, COLL_F, COLL_W, COLL_F, COLL_W, COLL_F, COLL_C, COLL_W, COLL_B
    db COLL_B, COLL_C, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_C, COLL_C, COLL_W, COLL_C, COLL_C, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, ITEM_FLAG | $16, COLL_F, COLL_F, COLL_F, TILE_EXIT, COLL_F, COLL_F, COLL_F, ITEM_FLAG | $16, COLL_B
    db COLL_B, $42, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, $42, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_JOKER, MONSTER_NAGA, MONSTER_JELL, MONSTER_TIGER

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=4, .Y=6, .Type=$22, .Param=$00, .Index=0   ; JOKER
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    dstruct Monster, , .X=6, .Y=6, .Type=$22, .Param=$01, .Index=0   ; JOKER
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    assert @ - .monsters == sizeof_Monster * 9

    ; arr3: 4 spawner slots (Spawner: X,Y,P0,P1,P2,Spawn0..5,End)
.spawners
    dstruct Spawner, , .X=9, .Y=2, .P0=$02, .P1=$01, .P2=$02, .Spawn0=1, .Spawn1=SPAWN_NONE, .Spawn2=SPAWN_NONE, .Spawn3=SPAWN_NONE, .Spawn4=SPAWN_NONE, .Spawn5=SPAWN_NONE, .End=INERT
    dstruct Spawner, , .X=1, .Y=2, .P0=$02, .P1=$00, .P2=$02, .Spawn0=1, .Spawn1=SPAWN_NONE, .Spawn2=SPAWN_NONE, .Spawn3=SPAWN_NONE, .Spawn4=SPAWN_NONE, .Spawn5=SPAWN_NONE, .End=INERT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    assert @ - .spawners == sizeof_Spawner * 4
