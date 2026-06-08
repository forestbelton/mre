; Floor 35 (record 34) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room35", ROMX[$4fe3], BANK[$2e]
Room35:
    dstruct Header, , .Id=$31, .SpawnX=5, .SpawnY=8, .Pad=$00, .Tileset=$01, .Palette=$04, .Height=10, .Width=11
    assert @ - Room35 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_C, COLL_F, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_C, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, TILE_EXIT, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BELL, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, $42, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, TILE_OBSTACLE_BAT, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_NUGGET, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_TACOPI, MONSTER_PSYLORA, MONSTER_NAGA, MONSTER_TIGER

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=1, .Y=2, .Type=$24, .Facing=$00, .Index=1   ; PSYLORA
    dstruct Monster, , .X=9, .Y=5, .Type=$22, .Facing=$00, .Index=0   ; TACOPI
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
    dstruct Spawner, , .X=3, .Y=3, .P0=$01, .P1=$02, .P2=$02, .Spawn0=0, .Spawn1=2, .Spawn2=SPAWN_NONE, .Spawn3=SPAWN_NONE, .Spawn4=SPAWN_NONE, .Spawn5=SPAWN_NONE, .End=INERT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    assert @ - .spawners == sizeof_Spawner * 4

    ; --- 256 bytes of unused slot slack: every floor record is a fixed
    ; 581-byte slot (sized for the max 14x17 floor); this 10x11 floor fills
    ; only 325, leaving this leftover/default tail. Never read by anything.
    ; See docs/floor_data.md "Record trailer". ---
.trailer
    db $aa, $2e, $aa, $d5, $67, $15, $55, $ba, $aa, $57, $75, $aa, $ab, $aa, $aa, $55
    db $15, $55, $55, $a8, $8a, $aa, $aa, $97, $91, $0e, $a2, $1d, $e5, $05, $55, $ab
    db $a2, $ea, $aa, $9d, $15, $54, $51, $ba, $aa, $d5, $74, $a9, $ba, $aa, $aa, $11
    db $57, $54, $d5, $aa, $ab, $aa, $aa, $6f, $41, $ae, $aa, $55, $c6, $d7, $61, $a2
    db $ee, $af, $40, $55, $17, $7d, $55, $8a, $7a, $51, $79, $aa, $a2, $ea, $aa, $4c
    db $15, $d5, $55, $8b, $a2, $a8, $aa, $f7, $54, $ba, $aa, $d1, $55, $b5, $0d, $2a
    db $e2, $ea, $ca, $75, $45, $dd, $dd, $aa, $b8, $55, $54, $aa, $be, $ba, $aa, $47
    db $77, $55, $55, $a8, $a2, $88, $2a, $c5, $77, $23, $ba, $17, $61, $55, $55, $6a
    db $ea, $8b, $aa, $10, $55, $55, $d5, $aa, $bb, $55, $55, $a8, $aa, $aa, $ba, $55
    db $75, $54, $55, $ba, $ae, $af, $aa, $55, $58, $ea, $aa, $d7, $47, $15, $50, $8a
    db $ab, $aa, $8a, $55, $b5, $4d, $5d, $a2, $ac, $55, $55, $a2, $8a, $aa, $8a, $75
    db $d7, $55, $51, $aa, $8a, $ba, $e8, $15, $17, $2a, $aa, $55, $55, $65, $41, $aa
    db $2a, $ba, $a3, $75, $25, $55, $57, $aa, $9a, $75, $55, $aa, $ab, $aa, $82, $55
    db $55, $57, $55, $ab, $ba, $ba, $2a, $55, $55, $aa, $aa, $17, $15, $55, $5d, $aa
    db $8a, $ae, $ea, $55, $55, $55, $55, $aa, $b3, $45, $55, $aa, $aa, $aa, $ea, $52
    db $5d, $45, $55, $02, $ab, $a8, $aa, $33, $55, $ec, $ae, $40, $45, $55, $5d, $aa
