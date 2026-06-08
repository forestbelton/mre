; Floor 14 (record 13) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room14", ROMX[$5d81], BANK[$2d]
Room14:
    dstruct Header, , .Type=$07, .SpawnX=8, .SpawnY=1, .Pad=$00, .Param0=$05, .Param1=$02, .Height=10, .Width=11
    assert @ - Room14 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_W, COLL_W, COLL_W, COLL_C, COLL_C, COLL_W, COLL_W, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_W, COLL_W, COLL_W, COLL_C, COLL_W, COLL_W, COLL_W, COLL_C, COLL_W, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_W, COLL_C, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_MEDAL, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_NUGGET, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_MEDAL, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, TILE_EXIT, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BELL, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_JOKER, MONSTER_JELL, MONSTER_NAGA, MONSTER_TIGER

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=4, .Y=3, .Type=$22, .Param=$01, .Index=0   ; JOKER
    dstruct Monster, , .X=6, .Y=3, .Type=$22, .Param=$01, .Index=0   ; JOKER
    dstruct Monster, , .X=3, .Y=5, .Type=$22, .Param=$00, .Index=0   ; JOKER
    dstruct Monster, , .X=5, .Y=5, .Type=$22, .Param=$00, .Index=0   ; JOKER
    dstruct Monster, , .X=7, .Y=7, .Type=$22, .Param=$01, .Index=0   ; JOKER
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
    db $a2, $0e, $aa, $d4, $27, $15, $45, $ba, $a8, $57, $75, $aa, $ab, $aa, $aa, $55
    db $15, $55, $55, $a8, $8b, $aa, $aa, $b7, $91, $4e, $a2, $1d, $e5, $05, $55, $ab
    db $22, $ea, $aa, $9d, $05, $54, $d1, $ba, $aa, $d5, $74, $a9, $3a, $ba, $aa, $11
    db $57, $54, $55, $8a, $ab, $aa, $aa, $73, $45, $ac, $aa, $55, $c6, $d7, $61, $a3
    db $ee, $af, $40, $55, $17, $7d, $45, $8a, $72, $51, $79, $aa, $a2, $ea, $aa, $4c
    db $05, $d5, $55, $8b, $a2, $a8, $aa, $f7, $54, $ba, $aa, $d1, $15, $b5, $8d, $2a
    db $f2, $ee, $ca, $75, $45, $dd, $dd, $aa, $b8, $56, $50, $aa, $be, $ba, $aa, $45
    db $77, $95, $55, $a8, $a2, $88, $2a, $c5, $77, $2b, $ba, $17, $60, $55, $4d, $6e
    db $ea, $8b, $aa, $10, $55, $54, $d4, $aa, $b9, $51, $55, $a8, $ea, $a8, $ba, $55
    db $75, $44, $55, $9a, $ae, $bf, $aa, $55, $d8, $ea, $aa, $d7, $67, $15, $50, $9a
    db $bb, $aa, $8a, $55, $b5, $4d, $dd, $e2, $b8, $55, $55, $a2, $8a, $ab, $8a, $75
    db $d7, $57, $51, $aa, $88, $ba, $e8, $15, $17, $02, $aa, $55, $55, $74, $61, $a8
    db $2a, $ba, $a3, $75, $25, $55, $57, $aa, $9c, $75, $55, $aa, $af, $aa, $82, $55
    db $55, $57, $55, $2b, $aa, $ba, $2a, $55, $55, $aa, $aa, $17, $1d, $51, $5d, $a2
    db $8a, $af, $ea, $55, $55, $5d, $55, $28, $bb, $45, $55, $aa, $9a, $aa, $ee, $5a
    db $5d, $45, $55, $00, $ab, $a8, $aa, $31, $55, $ed, $ae, $4c, $05, $55, $5d, $aa
