; Floor 52 (record 51) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room52", ROMX[$7678], BANK[$2e]
Room52:
    dstruct Header, , .Id=$5a, .SpawnX=1, .SpawnY=2, .Pad=$00, .Tileset=$03, .Palette=$02, .Height=10, .Width=11
    assert @ - Room52 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_W, COLL_C, COLL_C, COLL_F, COLL_W, COLL_F, COLL_W, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_C, COLL_F, COLL_W, COLL_F, COLL_C, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_C, COLL_C, COLL_W, COLL_C, COLL_C, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_W, COLL_F, COLL_F, COLL_W, COLL_W, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, TILE_OBSTACLE_BAT, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, $42, ITEM_FLAG | ITEM_OPEN | ITEM_BELL, $42, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_PLATINUM_RING, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_SILVER_MEDAL, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_MEDAL, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_MEDAL, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, TILE_EXIT, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, ITEM_FLAG | ITEM_GOLD_NUGGET, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_FLAME_RED, MONSTER_JELL, MONSTER_NAGA, MONSTER_TIGER

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
    dstruct Spawner, , .X=4, .Y=2, .P0=$00, .P1=$00, .P2=$02, .Spawn0=2, .Spawn1=2, .Spawn2=SPAWN_NONE, .Spawn3=SPAWN_NONE, .Spawn4=SPAWN_NONE, .Spawn5=SPAWN_NONE, .End=INERT
    EMPTY_SPAWNER_SLOT
    dstruct Spawner, , .X=6, .Y=2, .P0=$00, .P1=$00, .P2=$02, .Spawn0=2, .Spawn1=2, .Spawn2=SPAWN_NONE, .Spawn3=SPAWN_NONE, .Spawn4=SPAWN_NONE, .Spawn5=SPAWN_NONE, .End=INERT
    EMPTY_SPAWNER_SLOT
    assert @ - .spawners == sizeof_Spawner * 4

    ; --- 256 bytes of unused slot slack: every floor record is a fixed
    ; 581-byte slot (sized for the max 14x17 floor); this 10x11 floor fills
    ; only 325, leaving this leftover/default tail. Never read by anything.
    ; See docs/floor_data.md "Record trailer". ---
.trailer
    db $aa, $2e, $aa, $d5, $27, $55, $55, $ba, $aa, $57, $75, $aa, $ab, $aa, $aa, $55
    db $15, $55, $55, $ba, $8a, $aa, $aa, $97, $91, $0e, $a2, $5f, $e5, $05, $55, $aa
    db $a2, $aa, $aa, $55, $15, $54, $51, $ba, $aa, $55, $54, $a9, $ba, $aa, $aa, $11
    db $57, $54, $d5, $ab, $ab, $aa, $aa, $4f, $45, $a8, $aa, $d5, $c6, $d7, $61, $a2
    db $ee, $af, $48, $55, $17, $7c, $45, $8a, $62, $51, $7d, $aa, $a2, $ea, $aa, $48
    db $15, $d5, $55, $cb, $aa, $a8, $aa, $f7, $54, $ba, $aa, $d1, $55, $b5, $0d, $2a
    db $e2, $6a, $8e, $75, $45, $dd, $9d, $aa, $b8, $55, $54, $aa, $be, $ba, $aa, $47
    db $77, $55, $55, $28, $a2, $aa, $2a, $c5, $77, $23, $ba, $17, $61, $55, $55, $6a
    db $ea, $8b, $aa, $14, $55, $55, $d4, $aa, $bb, $55, $55, $a8, $eb, $aa, $ba, $55
    db $75, $54, $55, $be, $ae, $af, $aa, $55, $58, $ea, $aa, $d7, $45, $15, $50, $8a
    db $ab, $a2, $8a, $55, $b5, $4d, $55, $aa, $a8, $55, $55, $a2, $8a, $aa, $8a, $75
    db $d7, $57, $51, $aa, $8a, $ba, $e8, $15, $17, $82, $aa, $55, $55, $65, $41, $a8
    db $2a, $aa, $a3, $55, $05, $55, $57, $aa, $9a, $75, $55, $aa, $ab, $aa, $82, $55
    db $55, $57, $55, $ab, $ba, $ba, $2a, $54, $55, $aa, $aa, $57, $15, $55, $5d, $aa
    db $8a, $ae, $ea, $55, $55, $55, $55, $2a, $bb, $45, $55, $aa, $b2, $aa, $ea, $5a
    db $5d, $41, $55, $02, $ab, $a8, $aa, $33, $55, $e9, $ae, $44, $45, $55, $5d, $aa
