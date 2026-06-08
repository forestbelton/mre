; Floor 16 (record 15) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room16", ROMX[$620b], BANK[$2d]
Room16:
    dstruct Header, , .Id=$0b, .SpawnX=5, .SpawnY=6, .Pad=$00, .Tileset=$02, .Palette=$02, .Height=10, .Width=11
    assert @ - Room16 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_EXIT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, ITEM_FLAG | ITEM_OPEN | ITEM_BELL, COLL_B
    db COLL_B, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, COLL_F, COLL_F, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, COLL_B
    db COLL_B, TILE_OBSTACLE_BAT, COLL_F, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, COLL_F, TILE_OBSTACLE_BAT, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, ITEM_FLAG | ITEM_GOLD_MEDAL, TILE_OBSTACLE_BAT, ITEM_FLAG | ITEM_GOLD_MEDAL, TILE_OBSTACLE_BAT, ITEM_FLAG | ITEM_HEAL_BADGE, TILE_OBSTACLE_BAT, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_SILVER_MEDAL, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, ITEM_FLAG | ITEM_SILVER_MEDAL, COLL_B
    db COLL_B, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, COLL_F, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, COLL_F, TILE_OBSTACLE_BAT, COLL_B
    db COLL_B, TILE_OBSTACLE_BAT, COLL_F, TILE_OBSTACLE_BAT, COLL_F, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, ITEM_FLAG | ITEM_RED_CRYSTAL, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, COLL_B
    db COLL_B, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, COLL_F, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, COLL_B
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
    db $aa, $2e, $aa, $d5, $27, $55, $55, $ba, $aa, $57, $75, $aa, $ab, $aa, $aa, $55
    db $15, $55, $55, $aa, $8a, $aa, $aa, $97, $91, $0e, $a2, $5f, $e5, $05, $55, $ab
    db $a2, $aa, $aa, $55, $35, $54, $d1, $ba, $aa, $55, $54, $a9, $ba, $aa, $aa, $11
    db $57, $54, $55, $ab, $ab, $aa, $aa, $5d, $45, $ac, $aa, $55, $c6, $d7, $61, $a2
    db $ea, $af, $40, $55, $17, $7d, $45, $8a, $72, $51, $59, $aa, $a2, $aa, $aa, $4c
    db $15, $d5, $55, $8b, $aa, $aa, $aa, $f7, $74, $ba, $aa, $d1, $55, $b5, $0d, $2a
    db $e2, $ea, $8a, $75, $45, $dd, $dd, $aa, $b8, $55, $55, $aa, $be, $aa, $aa, $47
    db $77, $55, $55, $28, $aa, $a8, $2a, $c5, $75, $23, $ba, $17, $61, $55, $5d, $ee
    db $ea, $8b, $aa, $10, $55, $55, $d5, $aa, $bb, $51, $55, $a8, $ee, $aa, $ba, $55
    db $75, $54, $55, $ba, $ae, $af, $aa, $55, $58, $ea, $aa, $d7, $47, $15, $50, $8a
    db $ab, $aa, $8a, $55, $b5, $4d, $55, $aa, $b8, $55, $55, $a2, $8a, $aa, $8a, $75
    db $d7, $57, $51, $aa, $0a, $aa, $e8, $15, $57, $a2, $aa, $55, $55, $64, $61, $aa
    db $2a, $aa, $a3, $55, $25, $55, $57, $aa, $9a, $75, $55, $aa, $af, $aa, $82, $55
    db $55, $57, $55, $ab, $aa, $ba, $2a, $55, $55, $aa, $aa, $57, $15, $55, $5d, $aa
    db $8a, $ae, $ea, $55, $55, $55, $55, $2a, $bb, $45, $55, $aa, $a2, $aa, $ea, $5a
    db $5d, $51, $55, $02, $ab, $a8, $aa, $33, $55, $e8, $ae, $44, $45, $55, $55, $aa
