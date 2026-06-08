; Floor 5 (record 4) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room05", ROMX[$4914], BANK[$2d]
Room05:
    dstruct Header, , .Id=$33, .SpawnX=2, .SpawnY=4, .Pad=$00, .Tileset=$00, .Palette=$01, .Height=10, .Width=11
    assert @ - Room05 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_W, COLL_B
    db COLL_B, COLL_W, COLL_F, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_F, COLL_W, COLL_B
    db COLL_B, COLL_W, COLL_F, COLL_F, COLL_W, COLL_W, COLL_W, COLL_F, COLL_F, COLL_W, COLL_B
    db COLL_B, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_C, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_W, COLL_W, COLL_F, COLL_F, COLL_C, COLL_C, COLL_F, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_W, COLL_F, COLL_C, COLL_F, COLL_F, COLL_F, COLL_C, COLL_F, COLL_W, COLL_B
    db COLL_B, COLL_W, COLL_W, COLL_W, COLL_F, COLL_F, COLL_F, COLL_W, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BLUE_DIAMOND, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BLUE_DIAMOND, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_NUGGET, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BELL, COLL_F, COLL_F, TILE_EXIT, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_MEDAL, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_JOKER, MONSTER_JELL, MONSTER_DINO, MONSTER_TIGER

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=3, .Y=6, .Type=$22, .Facing=$00, .Index=2   ; DINO
    dstruct Monster, , .X=5, .Y=2, .Type=$22, .Facing=$00, .Index=1   ; JELL
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
    db $aa, $2e, $aa, $d5, $27, $55, $45, $ba, $aa, $57, $75, $aa, $ab, $aa, $aa, $55
    db $15, $55, $55, $fa, $8a, $aa, $aa, $97, $91, $0e, $a2, $5d, $e5, $05, $55, $ab
    db $a2, $aa, $aa, $15, $35, $54, $d1, $ba, $aa, $d5, $54, $ad, $ba, $aa, $aa, $11
    db $57, $54, $55, $ab, $ab, $aa, $aa, $4f, $45, $a8, $aa, $d5, $c6, $d7, $61, $a3
    db $ea, $af, $40, $55, $57, $7c, $45, $8a, $72, $51, $79, $aa, $a2, $aa, $aa, $4c
    db $15, $d5, $55, $9b, $aa, $aa, $aa, $f7, $74, $ba, $aa, $d1, $55, $b5, $0d, $2a
    db $e2, $ea, $8a, $75, $45, $dd, $dd, $aa, $b8, $55, $54, $aa, $be, $ba, $aa, $45
    db $77, $55, $55, $2a, $a2, $aa, $2a, $c5, $77, $23, $ba, $17, $61, $55, $55, $2a
    db $ea, $8b, $aa, $14, $55, $55, $d5, $aa, $bb, $55, $55, $a8, $ab, $aa, $ba, $55
    db $75, $54, $55, $ba, $ae, $af, $aa, $55, $d8, $aa, $aa, $d7, $4f, $15, $50, $8a
    db $ab, $aa, $8a, $55, $b5, $4d, $55, $aa, $ac, $55, $55, $a2, $8a, $aa, $8a, $75
    db $d7, $57, $51, $aa, $0a, $aa, $e8, $15, $17, $02, $aa, $55, $55, $64, $61, $a8
    db $2a, $ba, $a3, $55, $25, $55, $57, $aa, $9a, $75, $55, $aa, $ab, $aa, $82, $55
    db $55, $57, $55, $ab, $aa, $ba, $2a, $75, $55, $aa, $aa, $57, $15, $55, $5d, $aa
    db $8a, $ae, $ea, $55, $55, $55, $55, $aa, $bb, $45, $55, $8a, $b2, $aa, $ea, $5a
    db $5d, $51, $55, $02, $ab, $a8, $aa, $33, $55, $ed, $ae, $c0, $05, $55, $5d, $aa
