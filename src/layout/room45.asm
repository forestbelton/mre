; Floor 45 (record 44) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room45", ROMX[$6695], BANK[$2e]
Room45:
    dstruct Header, , .Id=$60, .SpawnX=2, .SpawnY=1, .Pad=$00, .Tileset=$02, .Palette=$05, .Height=10, .Width=11
    assert @ - Room45 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_W, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_C, COLL_C, COLL_C, COLL_W, COLL_F, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_W, COLL_W, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_SILVER_MEDAL, COLL_F, COLL_F, COLL_F, COLL_F, TILE_EXIT, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, TILE_OBSTACLE_BAT, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BOMB_LARGE, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_GOLD_PEACH, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, TILE_OBSTACLE_BAT, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_FLAME_RED, MONSTER_GHOST, MONSTER_HENGER, MONSTER_GOLEM

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=9, .Y=8, .Type=$22, .Param=$00, .Index=0   ; FLAME_RED
    dstruct Monster, , .X=7, .Y=2, .Type=$22, .Param=$02, .Index=1   ; GHOST
    dstruct Monster, , .X=1, .Y=8, .Type=$22, .Param=$00, .Index=0   ; FLAME_RED
    dstruct Monster, , .X=9, .Y=6, .Type=$22, .Param=$00, .Index=2   ; HENGER
    dstruct Monster, , .X=8, .Y=8, .Type=$22, .Param=$00, .Index=0   ; FLAME_RED
    dstruct Monster, , .X=7, .Y=6, .Type=$22, .Param=$02, .Index=1   ; GHOST
    EMPTY_MONSTER_SLOT
    dstruct Monster, , .X=9, .Y=1, .Type=$22, .Param=$00, .Index=2   ; HENGER
    EMPTY_MONSTER_SLOT
    assert @ - .monsters == sizeof_Monster * 9

    ; arr3: 4 spawner slots (Spawner: X,Y,P0,P1,P2,Spawn0..5,End)
.spawners
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    assert @ - .spawners == sizeof_Spawner * 4

    ; --- 256 bytes of unused slot slack: every floor record is a fixed
    ; 581-byte slot (sized for the max 14x17 floor); this 10x11 floor fills
    ; only 325, leaving this leftover/default tail. Never read by anything.
    ; See docs/floor_data.md "Record trailer". ---
.trailer
    db $00, $00, $00, $00, $cf, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00
    db $00, $e0, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $d2, $00, $00, $00
    db $00, $00, $00, $dd, $00, $00, $00, $00, $00, $00, $d2, $20, $20, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20
    db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $0c
    db $00, $02, $0e, $07, $09, $22, $00, $00, $09, $09, $22, $00, $00, $0d, $07, $22
    db $00, $00, $03, $07, $22, $00, $00, $08, $06, $22, $00, $00, $ff, $ff, $ff, $01
    db $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff
    db $0e, $01, $03, $01, $04, $01, $ff, $ff, $ff, $ff, $ff, $ff, $02, $01, $03, $00
    db $04, $01, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
