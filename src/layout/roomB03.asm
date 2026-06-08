; Floor 63 (record 62) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "roomB03", ROMX[$5228], BANK[$2f]
RoomB03:
    dstruct Header, , .Id=$41, .SpawnX=1, .SpawnY=1, .Pad=$00, .Tileset=$00, .Palette=$06, .Height=10, .Width=11
    assert @ - RoomB03 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_C, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_W, COLL_C, COLL_W, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_C, COLL_W, COLL_B
    db COLL_B, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_W, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_ORANGE_HOURGLASS, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_COX_HAT, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, TILE_EXIT, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_PEACH, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_DISC_STONE_PIECE, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BOMB_SMALL, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_F, ITEM_FLAG | ITEM_BOMB_LARGE, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_DUCKEN, MONSTER_PSYLORA, MONSTER_NAGA, MONSTER_TIGER

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=2, .Y=8, .Type=$23, .Param=$00, .Index=1   ; PSYLORA
    dstruct Monster, , .X=5, .Y=1, .Type=$23, .Param=$00, .Index=1   ; PSYLORA
    dstruct Monster, , .X=9, .Y=4, .Type=$22, .Param=$01, .Index=0   ; DUCKEN
    dstruct Monster, , .X=1, .Y=6, .Type=$22, .Param=$00, .Index=0   ; DUCKEN
    dstruct Monster, , .X=9, .Y=2, .Type=$22, .Param=$01, .Index=0   ; DUCKEN
    EMPTY_MONSTER_SLOT
    dstruct Monster, , .X=1, .Y=3, .Type=$22, .Param=$00, .Index=0   ; DUCKEN
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
    db $00, $00, $00, $00, $04, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $00, $00, $00, $00, $00, $00, $00, $40, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $00, $00, $40, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $00, $00, $00, $02, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $bf, $ff, $ff
    db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $00, $00, $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
