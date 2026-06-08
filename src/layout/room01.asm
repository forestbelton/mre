; Floor 1 (record 0) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room01", ROMX[$4000], BANK[$2d]
Room01:
    dstruct Header, , .Type=$61, .SpawnX=2, .SpawnY=7, .Pad=$00, .Param0=$00, .Param1=$01, .Height=10, .Width=11
    assert @ - Room01 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_W, COLL_B
    db COLL_B, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_W, COLL_F, COLL_C, COLL_F, COLL_F, COLL_F, COLL_C, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_C, COLL_W, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_W, COLL_F, COLL_F, COLL_F, COLL_C, COLL_W, COLL_W, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_W, COLL_F, COLL_F, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, TILE_EXIT, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_MEDAL, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BOMB_SMALL, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_TACOPI, MONSTER_JELL, MONSTER_NAGA, MONSTER_TIGER

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=6, .Y=4, .Type=$22, .Param=$00, .Index=1   ; JELL
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
    db $aa, $2e, $aa, $d5, $27, $55, $45, $ba, $aa, $55, $75, $aa, $ab, $aa, $aa, $55
    db $15, $55, $55, $ba, $8a, $aa, $aa, $97, $91, $0e, $a2, $5f, $e5, $05, $55, $ab
    db $22, $aa, $aa, $5d, $15, $54, $51, $ba, $aa, $d5, $54, $a9, $ba, $aa, $aa, $11
    db $57, $54, $55, $ab, $ab, $aa, $aa, $47, $45, $ac, $aa, $d5, $c6, $d7, $61, $a3
    db $ea, $af, $c0, $55, $15, $7d, $45, $8a, $72, $51, $7d, $aa, $a2, $ea, $aa, $48
    db $15, $d5, $55, $cb, $aa, $aa, $aa, $f7, $74, $ba, $aa, $d1, $55, $b5, $0d, $2a
    db $e2, $ea, $8a, $75, $45, $dd, $dd, $aa, $b8, $55, $54, $aa, $be, $aa, $aa, $47
    db $77, $55, $55, $28, $a2, $a8, $2a, $c5, $77, $23, $ba, $15, $61, $55, $55, $6a
    db $ea, $8b, $aa, $10, $55, $55, $d5, $aa, $bb, $55, $55, $a8, $eb, $aa, $ba, $55
    db $75, $54, $55, $9e, $ae, $ae, $aa, $55, $58, $ea, $aa, $d7, $45, $15, $50, $8a
    db $ab, $aa, $8a, $55, $b5, $4d, $55, $ea, $a8, $55, $55, $a2, $8a, $aa, $8a, $75
    db $d7, $55, $51, $aa, $8a, $ba, $a8, $15, $17, $a2, $aa, $55, $55, $65, $41, $aa
    db $2a, $ba, $a3, $55, $25, $55, $57, $aa, $9a, $75, $55, $aa, $af, $aa, $82, $55
    db $55, $57, $55, $ab, $aa, $ba, $2a, $54, $55, $aa, $aa, $57, $15, $55, $5d, $aa
    db $8a, $ae, $ea, $55, $55, $55, $55, $aa, $bb, $45, $55, $aa, $b2, $aa, $ea, $5a
    db $5d, $41, $55, $02, $ab, $a8, $aa, $33, $55, $ec, $ae, $40, $45, $55, $5d, $aa
