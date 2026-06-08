; Floor 11 (record 10) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room11", ROMX[$56b2], BANK[$2d]
Room11:
    dstruct Header, , .Id=$08, .SpawnX=5, .SpawnY=4, .Pad=$00, .Tileset=$00, .Palette=$02, .Height=10, .Width=11
    assert @ - Room11 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_W, COLL_F, COLL_F, COLL_F, COLL_W, COLL_W, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_W, COLL_F, COLL_W, COLL_F, COLL_W, COLL_F, COLL_C, COLL_F, COLL_W, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_C, COLL_F, COLL_C, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_W, COLL_W, COLL_W, COLL_C, COLL_W, COLL_C, COLL_C, COLL_W, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_W, COLL_F, COLL_W, COLL_F, COLL_W, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_NUGGET, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_NUGGET, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BELL, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_MEDAL, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, TILE_EXIT, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_FLAME_BLUE, MONSTER_JELL, MONSTER_NAGA, MONSTER_TIGER

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=3, .Y=4, .Type=$22, .Facing=$00, .Index=0   ; FLAME_BLUE
    dstruct Monster, , .X=7, .Y=4, .Type=$22, .Facing=$00, .Index=0   ; FLAME_BLUE
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
    db $15, $55, $55, $aa, $8a, $aa, $aa, $97, $91, $0e, $a2, $1f, $e5, $05, $55, $ab
    db $a2, $aa, $aa, $55, $35, $54, $d1, $ba, $aa, $d5, $74, $a9, $ba, $aa, $aa, $15
    db $57, $54, $55, $ab, $ab, $aa, $aa, $5f, $45, $ac, $aa, $d5, $c6, $d7, $61, $a3
    db $ea, $af, $40, $55, $17, $7c, $45, $8a, $72, $51, $7d, $aa, $a2, $aa, $aa, $4c
    db $15, $d5, $55, $8b, $aa, $aa, $aa, $f7, $54, $ba, $aa, $d1, $55, $b5, $0d, $2a
    db $e2, $ea, $ce, $75, $45, $dd, $dd, $aa, $b8, $55, $54, $aa, $be, $aa, $aa, $45
    db $77, $55, $55, $a8, $a2, $a8, $2a, $c5, $77, $23, $ba, $17, $61, $55, $55, $2a
    db $ea, $8b, $aa, $10, $55, $55, $55, $aa, $bb, $55, $55, $a8, $ab, $aa, $ba, $55
    db $75, $44, $55, $9e, $ae, $af, $aa, $55, $58, $aa, $aa, $d7, $47, $15, $50, $8a
    db $ab, $aa, $8a, $55, $b5, $45, $55, $ea, $ac, $55, $55, $a2, $8a, $aa, $aa, $35
    db $d7, $57, $51, $aa, $0a, $aa, $a8, $15, $57, $22, $aa, $55, $55, $65, $41, $aa
    db $2a, $ba, $a3, $75, $05, $55, $57, $aa, $98, $75, $55, $ea, $af, $aa, $82, $55
    db $55, $57, $55, $ab, $aa, $ba, $2a, $54, $55, $aa, $aa, $55, $15, $55, $5d, $aa
    db $8a, $ae, $ea, $55, $55, $55, $55, $2a, $bb, $45, $55, $aa, $a2, $aa, $ea, $5a
    db $5d, $51, $55, $02, $ab, $a8, $aa, $33, $55, $e9, $ae, $44, $45, $5d, $5d, $aa
