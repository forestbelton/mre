; Floor 54 (record 53) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room54", ROMX[$7b02], BANK[$2e]
Room54:
    dstruct Header, , .Id=$42, .SpawnX=2, .SpawnY=2, .Pad=$00, .Tileset=$01, .Palette=$02, .Height=10, .Width=11
    assert @ - Room54 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_W, COLL_W, COLL_C, COLL_W, COLL_F, COLL_W, COLL_F, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_F, COLL_W, COLL_F, COLL_C, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_F, COLL_W, COLL_C, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_W, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, TILE_OBSTACLE_BAT, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, TILE_OBSTACLE_BAT, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, TILE_OBSTACLE_BAT, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, TILE_EXIT, COLL_F, COLL_F, COLL_F, TILE_OBSTACLE_BAT, COLL_F, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, TILE_OBSTACLE_BAT, COLL_F, COLL_F, COLL_B
    db COLL_B, TILE_OBSTACLE_BAT, COLL_F, TILE_OBSTACLE_BAT, COLL_F, TILE_OBSTACLE_BAT, COLL_F, TILE_OBSTACLE_BAT, COLL_F, TILE_OBSTACLE_BAT, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_FLAME_BLUE, MONSTER_JOKER, MONSTER_PSYLORA, MONSTER_HARE

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=7, .Y=7, .Type=$22, .Param=$00, .Index=0   ; FLAME_BLUE
    dstruct Monster, , .X=3, .Y=2, .Type=$22, .Param=$00, .Index=0   ; FLAME_BLUE
    dstruct Monster, , .X=2, .Y=7, .Type=$22, .Param=$04, .Index=2   ; PSYLORA
    dstruct Monster, , .X=5, .Y=7, .Type=$21, .Param=$00, .Index=1   ; JOKER
    dstruct Monster, , .X=1, .Y=7, .Type=$22, .Param=$00, .Index=0   ; FLAME_BLUE
    dstruct Monster, , .X=8, .Y=2, .Type=$21, .Param=$04, .Index=2   ; PSYLORA
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

    ; --- 256 bytes of unused slot slack: every floor record is a fixed
    ; 581-byte slot (sized for the max 14x17 floor); this 10x11 floor fills
    ; only 325, leaving this leftover/default tail. Never read by anything.
    ; See docs/floor_data.md "Record trailer". ---
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
