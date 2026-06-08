; Floor 43 (record 42) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room43", ROMX[$620b], BANK[$2e]
Room43:
    dstruct Header, , .Type=$18, .SpawnX=1, .SpawnY=7, .Pad=$00, .Param0=$00, .Param1=$00, .Height=10, .Width=11
    assert @ - Room43 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_C, COLL_F, COLL_W, COLL_F, COLL_C, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_C, COLL_W, COLL_C, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_W, COLL_C, COLL_C, COLL_C, COLL_W, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_W, COLL_W, COLL_C, COLL_W, COLL_W, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_W, COLL_F, COLL_W, COLL_F, COLL_W, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_W, COLL_C, COLL_C, COLL_C, COLL_W, COLL_C, COLL_C, COLL_C, COLL_W, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, $42, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_KEY, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_MEDAL, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_CAKE, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, TILE_EXIT, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_MEDAL, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_MEDAL, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_TACOPI, MONSTER_JELL, MONSTER_NAGA, MONSTER_TIGER

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    assert @ - .monsters == sizeof_Monster * 9

    ; arr3: 4 spawner slots (Spawner: X,Y,P0,P1,P2,Spawn0..5,End)
.spawners
    dstruct Spawner, , .X=5, .Y=1, .P0=$00, .P1=$02, .P2=$04, .Spawn0=2, .Spawn1=SPAWN_NONE, .Spawn2=SPAWN_NONE, .Spawn3=SPAWN_NONE, .Spawn4=SPAWN_NONE, .Spawn5=SPAWN_NONE, .End=INERT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    assert @ - .spawners == sizeof_Spawner * 4

    ; --- record trailer (256 bytes), undecoded. Read only by the level
    ; editor (LoadFloorRecordToBuffer -> wFloorSnapshot); gameplay never
    ; reads it. See docs/floor_data.md "Record trailer". ---
.trailer
    db $aa, $2e, $aa, $d5, $27, $55, $55, $ba, $aa, $57, $75, $aa, $ab, $aa, $aa, $55
    db $15, $55, $55, $b8, $8a, $aa, $aa, $97, $91, $0e, $a2, $5f, $e5, $05, $55, $ab
    db $a2, $aa, $aa, $5d, $15, $54, $d1, $ba, $aa, $55, $74, $a9, $ba, $aa, $aa, $11
    db $57, $54, $55, $ab, $ab, $aa, $aa, $6f, $45, $ac, $aa, $55, $c6, $d7, $61, $a3
    db $ea, $af, $40, $55, $17, $7d, $45, $8a, $72, $51, $7d, $aa, $a2, $aa, $aa, $4c
    db $05, $d5, $55, $8b, $aa, $a8, $aa, $f7, $74, $ba, $aa, $d1, $55, $b5, $0d, $2a
    db $e2, $ea, $8a, $75, $45, $dd, $dd, $aa, $f8, $55, $55, $aa, $be, $aa, $aa, $45
    db $77, $55, $55, $a8, $aa, $aa, $aa, $c5, $77, $2b, $ba, $15, $61, $55, $5d, $2e
    db $ea, $8b, $aa, $10, $55, $55, $55, $aa, $bb, $55, $55, $a8, $ea, $aa, $ba, $55
    db $75, $54, $55, $ae, $ae, $af, $aa, $55, $d8, $ea, $aa, $d7, $47, $15, $50, $8a
    db $ab, $aa, $8a, $55, $b5, $4d, $5d, $a2, $a8, $55, $55, $a2, $8a, $aa, $8a, $75
    db $d7, $55, $51, $aa, $8a, $ba, $e8, $15, $17, $22, $aa, $55, $55, $64, $41, $aa
    db $2a, $ba, $a3, $55, $25, $55, $57, $aa, $9a, $75, $55, $aa, $ab, $aa, $82, $55
    db $55, $57, $55, $ab, $aa, $ba, $2a, $54, $55, $aa, $aa, $57, $15, $55, $5d, $aa
    db $8a, $aa, $ea, $55, $55, $55, $55, $2a, $bb, $45, $55, $aa, $b2, $aa, $ea, $52
    db $5d, $41, $55, $02, $ab, $a8, $aa, $33, $55, $e0, $ae, $44, $45, $5d, $5d, $aa
