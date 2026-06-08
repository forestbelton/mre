; Floor 21 (record 20) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room21", ROMX[$6d64], BANK[$2d]
Room21:
    dstruct Header, , .Type=$3d, .SpawnX=1, .SpawnY=1, .Pad=$00, .Param0=$04, .Param1=$03, .Height=10, .Width=11
    assert @ - Room21 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_C, COLL_C, COLL_C, COLL_C, COLL_W, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_W, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_W, COLL_W, COLL_F, COLL_W, COLL_W, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_F, COLL_C, COLL_F, COLL_F, COLL_W, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_F, COLL_W, COLL_F, COLL_W, COLL_W, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_C, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, TILE_EXIT, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BELL, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, ITEM_FLAG | ITEM_SILVER_MEDAL, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_TACOPI, MONSTER_JELL, MONSTER_NAGA, MONSTER_TIGER

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=8, .Y=5, .Type=$22, .Param=$00, .Index=1   ; JELL
    dstruct Monster, , .X=8, .Y=3, .Type=$22, .Param=$00, .Index=1   ; JELL
    dstruct Monster, , .X=8, .Y=1, .Type=$22, .Param=$00, .Index=1   ; JELL
    EMPTY_MONSTER_SLOT
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

    ; --- record trailer (256 bytes), undecoded. Read only by the level
    ; editor (LoadFloorRecordToBuffer -> wFloorSnapshot); gameplay never
    ; reads it. See docs/floor_data.md "Record trailer". ---
.trailer
    db $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $c9, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $8c, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $c7, $20, $20, $00, $c2
    db $00, $00, $00, $00, $d5, $00, $c0, $00, $00, $90, $85, $42, $e0, $20, $20, $20
    db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $00
    db $01, $02, $0e, $0f, $01, $22, $00, $01, $0a, $05, $22, $00, $01, $0c, $0a, $22
    db $00, $01, $01, $09, $22, $00, $01, $06, $0c, $22, $00, $02, $ff, $ff, $ff, $01
    db $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff
    db $0e, $0c, $02, $00, $02, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
