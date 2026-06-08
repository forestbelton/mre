; Floor 48 (record 47) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room48", ROMX[$6d64], BANK[$2e]
Room48:
    dstruct Header, , .Type=$27, .SpawnX=9, .SpawnY=1, .Pad=$00, .Param0=$02, .Param1=$05, .Height=10, .Width=11
    assert @ - Room48 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_F, COLL_W, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_C, COLL_W, COLL_B
    db COLL_B, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_W, COLL_W, COLL_W, COLL_F, COLL_W, COLL_W, COLL_W, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_W, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_W, COLL_F, COLL_C, COLL_C, COLL_W, COLL_C, COLL_W, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_W, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BELL, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, TILE_OBSTACLE_BAT, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, TILE_EXIT, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, TILE_OBSTACLE_BAT, ITEM_FLAG | ITEM_PLATINUM_RING, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_PLANT, MONSTER_JELL, MONSTER_NAGA, MONSTER_GALI

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=5, .Y=1, .Type=$22, .Param=$00, .Index=2   ; NAGA
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
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    assert @ - .spawners == sizeof_Spawner * 4

    ; --- record trailer (256 bytes), undecoded. Read only by the level
    ; editor (LoadFloorRecordToBuffer -> wFloorSnapshot); gameplay never
    ; reads it. See docs/floor_data.md "Record trailer". ---
.trailer
    db $00, $00, $e0, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $c1
    db $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $c6, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $c4, $00, $20, $20, $00, $00, $00, $c2, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $c2, $00, $00, $20, $20, $43, $43, $43
    db $43, $43, $00, $00, $00, $00, $00, $43, $43, $43, $43, $43, $20, $20, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20
    db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $00
    db $07, $02, $0e, $08, $0c, $24, $02, $01, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff
    db $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01
    db $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff
    db $0d, $01, $01, $01, $04, $00, $02, $ff, $ff, $ff, $ff, $ff, $03, $01, $01, $00
    db $04, $02, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
