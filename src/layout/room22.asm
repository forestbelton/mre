; Floor 22 (record 21) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room22", ROMX[$6fa9], BANK[$2d]
Room22:
    dstruct Header, , .Id=$0d, .SpawnX=1, .SpawnY=2, .Pad=$00, .Tileset=$00, .Palette=$00, .Height=10, .Width=11
    assert @ - Room22 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_C, COLL_W, COLL_W, COLL_C, COLL_C, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_C, COLL_C, COLL_C, COLL_W, COLL_W, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_W, COLL_C, COLL_F, COLL_C, COLL_W, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BELL, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, TILE_EXIT, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_MONSTER_FLAME, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_MEDAL, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_MEDAL, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_FIREPLACE, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_PUNCHO, MONSTER_DINO, MONSTER_NAGA, MONSTER_MOCCHI

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=7, .Y=5, .Type=$23, .Param=$01, .Index=0   ; PUNCHO
    dstruct Monster, , .X=3, .Y=5, .Type=$24, .Param=$00, .Index=1   ; DINO
    dstruct Monster, , .X=4, .Y=3, .Type=$23, .Param=$00, .Index=0   ; PUNCHO
    EMPTY_MONSTER_SLOT
    dstruct Monster, , .X=5, .Y=8, .Type=$24, .Param=$00, .Index=1   ; DINO
    dstruct Monster, , .X=7, .Y=1, .Type=$23, .Param=$01, .Index=0   ; PUNCHO
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
    db $00, $00, $04, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
    db $00, $00, $00, $00, $00, $40, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
    db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
    db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
    db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
    db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
    db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
    db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
    db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
    db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
    db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
    db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
    db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
    db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
    db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
    db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
