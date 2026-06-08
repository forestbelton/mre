; Floor 56 (record 55) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room56", ROMX[$4245], BANK[$2f]
Room56:
    dstruct Header, , .Type=$58, .SpawnX=3, .SpawnY=8, .Pad=$00, .Param0=$00, .Param1=$00, .Height=10, .Width=11
    assert @ - Room56 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_W, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_W, COLL_C, COLL_C, COLL_F, COLL_F, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_W, COLL_C, COLL_W, COLL_W, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_W, COLL_W, COLL_W, COLL_F, COLL_C, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_MONSTER_FLAME, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_MEDAL, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, TILE_OBSTACLE_BAT, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, ITEM_FLAG | ITEM_SILVER_MEDAL, COLL_B
    db COLL_B, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_EXIT, COLL_F, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, COLL_F, COLL_F, COLL_B
    db COLL_B, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_HENGER, MONSTER_GHOST, MONSTER_JELL, MONSTER_TIGER

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=9, .Y=8, .Type=$23, .Param=$00, .Index=0   ; HENGER
    dstruct Monster, , .X=3, .Y=2, .Type=$22, .Param=$00, .Index=2   ; JELL
    dstruct Monster, , .X=4, .Y=1, .Type=$22, .Param=$00, .Index=0   ; HENGER
    dstruct Monster, , .X=7, .Y=1, .Type=$22, .Param=$02, .Index=1   ; GHOST
    dstruct Monster, , .X=6, .Y=1, .Type=$20, .Param=$02, .Index=1   ; GHOST
    dstruct Monster, , .X=8, .Y=2, .Type=$22, .Param=$00, .Index=2   ; JELL
    dstruct Monster, , .X=6, .Y=4, .Type=$22, .Param=$00, .Index=2   ; JELL
    dstruct Monster, , .X=4, .Y=6, .Type=$22, .Param=$00, .Index=2   ; JELL
    EMPTY_MONSTER_SLOT
    assert @ - .monsters == sizeof_Monster * 9

    ; arr3: 4 spawner slots (Spawner: X,Y,P0,P1,P2,Spawn0..5,End)
.spawners
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    assert @ - .spawners == sizeof_Spawner * 4

    ; --- unknown trailer (256 bytes): nonzero record data not yet
    ; modeled in the Header struct; colocated from analyzed.asm. ---
.trailer
    db $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $42, $00, $20, $20, $c2, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $d2, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00
    db $c5, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $cc, $20, $20, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $c0
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20
    db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $09
    db $01, $02, $0e, $08, $06, $24, $00, $00, $08, $08, $24, $00, $00, $08, $0a, $24
    db $00, $00, $08, $0c, $24, $00, $00, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01
    db $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff
    db $02, $02, $02, $00, $02, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $0e, $05, $02, $00
    db $02, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
