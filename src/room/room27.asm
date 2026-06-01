; Floor 27 (record 26) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room27", ROMX[$7b02], BANK[$2d]
Room27:
    dstruct Header, , .Type=$16, .SpawnX=1, .SpawnY=8, .Pad=$00, .Param0=$05, .Param1=$03, .Height=10, .Width=11
    assert @ - Room27 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_C, COLL_C, COLL_F, COLL_C, COLL_C, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_C, COLL_F, COLL_W, COLL_F, COLL_C, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_C, COLL_C, COLL_F, COLL_C, COLL_C, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_C, COLL_F, COLL_F, COLL_F, COLL_W, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_C, COLL_F, COLL_C, COLL_F, COLL_C, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_F, COLL_W, COLL_F, COLL_W, COLL_F, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, $42, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BELL, COLL_F, COLL_F, COLL_F, $42, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, TILE_EXIT, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_SILVER_MEDAL, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_NUGGET, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_MEDAL, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_DUCK_DOLL, COLL_F, $42, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BOMB_LARGE, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_FLAME_BLUE, MONSTER_TACOPI, MONSTER_NAGA, MONSTER_TIGER

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=4, .Y=3, .Type=$22, .Param=$00, .Index=0   ; FLAME_BLUE
    dstruct Monster, , .X=6, .Y=3, .Type=$22, .Param=$00, .Index=0   ; FLAME_BLUE
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    assert @ - .monsters == sizeof_Monster * 9

    ; arr3: 8 spawner slots (Spawner: X,Y,P0,P1,P2,Index)
.spawners
    dstruct Spawner, , .X=1, .Y=1, .P0=$01, .P1=$02, .P2=$03, .Index=1
    dstruct Spawner, , .X=1, .Y=255, .P0=$ff, .P1=$ff, .P2=$ff, .Index=255
    dstruct Spawner, , .X=9, .Y=1, .P0=$01, .P1=$02, .P2=$03, .Index=1
    dstruct Spawner, , .X=1, .Y=255, .P0=$ff, .P1=$ff, .P2=$ff, .Index=255
    dstruct Spawner, , .X=7, .Y=7, .P0=$02, .P1=$00, .P2=$02, .Index=255
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    assert @ - .spawners == sizeof_Spawner * 8
