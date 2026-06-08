; Floor 19 (record 18) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room19", ROMX[$68da], BANK[$2d]
Room19:
    dstruct Header, , .Type=$12, .SpawnX=5, .SpawnY=8, .Pad=$00, .Param0=$05, .Param1=$02, .Height=10, .Width=11
    assert @ - Room19 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_C, COLL_F, COLL_F, COLL_F, COLL_C, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_C, COLL_F, COLL_F, COLL_F, COLL_C, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_C, COLL_F, COLL_F, COLL_F, COLL_C, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_C, COLL_F, COLL_F, COLL_C, COLL_F, COLL_C, COLL_F, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_C, COLL_F, COLL_F, COLL_F, COLL_C, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_NUGGET, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_MEDAL, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, TILE_EXIT, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_MEDAL, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BOMB_LARGE, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_NUGGET, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_MEDAL, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_MEDAL, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_PSYLORA, MONSTER_JELL, MONSTER_NAGA, MONSTER_TIGER

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=7, .Y=7, .Type=$21, .Param=$04, .Index=0   ; PSYLORA
    dstruct Monster, , .X=2, .Y=7, .Type=$22, .Param=$02, .Index=0   ; PSYLORA
    dstruct Monster, , .X=3, .Y=2, .Type=$21, .Param=$05, .Index=0   ; PSYLORA
    dstruct Monster, , .X=8, .Y=2, .Type=$22, .Param=$03, .Index=0   ; PSYLORA
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
    db $aa, $2e, $aa, $d5, $67, $15, $45, $ba, $aa, $57, $75, $aa, $ab, $aa, $aa, $55
    db $15, $55, $55, $ba, $8a, $aa, $aa, $97, $91, $0e, $a2, $5f, $e5, $05, $55, $ab
    db $a2, $ea, $aa, $dd, $35, $54, $51, $ba, $aa, $d5, $74, $ad, $ba, $aa, $aa, $11
    db $57, $54, $d5, $ab, $ab, $aa, $aa, $6b, $45, $a8, $aa, $d5, $c6, $d7, $61, $a3
    db $ee, $af, $40, $55, $17, $7d, $45, $8a, $72, $51, $79, $aa, $a2, $ea, $aa, $4c
    db $15, $d5, $55, $9a, $a2, $aa, $aa, $f7, $74, $ba, $aa, $d1, $55, $b5, $0d, $2a
    db $e2, $6a, $8a, $75, $45, $dd, $dd, $aa, $b8, $57, $50, $aa, $be, $ba, $aa, $45
    db $77, $55, $55, $a8, $a2, $aa, $2a, $c5, $77, $23, $ba, $17, $60, $55, $55, $6e
    db $ea, $0b, $aa, $10, $55, $55, $55, $aa, $bb, $51, $55, $a8, $aa, $a8, $ba, $55
    db $75, $44, $55, $ae, $ae, $af, $aa, $55, $58, $ea, $aa, $d7, $47, $15, $50, $8a
    db $ab, $aa, $8a, $55, $b5, $4d, $5d, $e2, $ac, $55, $55, $a2, $8a, $aa, $8a, $75
    db $d7, $57, $41, $aa, $8a, $ba, $e8, $15, $57, $22, $aa, $55, $55, $64, $61, $aa
    db $2a, $ba, $a3, $75, $25, $55, $57, $aa, $d8, $75, $55, $aa, $af, $aa, $82, $55
    db $55, $57, $55, $ab, $aa, $ba, $2a, $55, $55, $aa, $aa, $17, $15, $55, $5d, $aa
    db $8a, $ae, $ea, $55, $55, $55, $55, $aa, $bb, $45, $55, $aa, $ba, $aa, $ee, $5a
    db $5d, $41, $55, $02, $ab, $a8, $aa, $73, $55, $e8, $ae, $44, $05, $55, $5d, $aa
