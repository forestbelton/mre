; Floor 62 (record 61) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "roomB02", ROMX[$4fe3], BANK[$2f]
RoomB02:
    dstruct Header, , .Id=$4b, .SpawnX=5, .SpawnY=5, .Pad=$00, .Tileset=$05, .Palette=$06, .Height=10, .Width=11
    assert @ - RoomB02 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_F, COLL_C, COLL_W, COLL_W, COLL_C, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_C, COLL_F, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_W, COLL_W, COLL_F, COLL_W, COLL_F, COLL_W, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_F, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_W, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_W, COLL_F, COLL_W, COLL_C, COLL_F, COLL_W, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_W, COLL_W, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_C, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, $42, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, $42, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, TILE_EXIT, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BELL, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_PEACH, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BELL, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_OPEN | ITEM_COX_HAT, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_PSYLORA, MONSTER_FLAME_BLUE, MONSTER_NAGA, MONSTER_GOLEM

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=7, .Y=6, .Type=$20, .Facing=$05, .Index=0   ; PSYLORA
    dstruct Monster, , .X=7, .Y=1, .Type=$22, .Facing=$00, .Index=1   ; FLAME_BLUE
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
    dstruct Spawner, , .X=1, .Y=1, .P0=$00, .P1=$00, .P2=$03, .Spawn0=2, .Spawn1=SPAWN_NONE, .Spawn2=SPAWN_NONE, .Spawn3=SPAWN_NONE, .Spawn4=SPAWN_NONE, .Spawn5=SPAWN_NONE, .End=INERT
    dstruct Spawner, , .X=9, .Y=1, .P0=$00, .P1=$01, .P2=$04, .Spawn0=2, .Spawn1=SPAWN_NONE, .Spawn2=SPAWN_NONE, .Spawn3=SPAWN_NONE, .Spawn4=SPAWN_NONE, .Spawn5=SPAWN_NONE, .End=INERT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    assert @ - .spawners == sizeof_Spawner * 4

    ; --- 256 bytes of unused slot slack: every floor record is a fixed
    ; 581-byte slot (sized for the max 14x17 floor); this 10x11 floor fills
    ; only 325, leaving this leftover/default tail. Never read by anything.
    ; See docs/floor_data.md "Record trailer". ---
.trailer
    db $aa, $2e, $aa, $d5, $67, $55, $45, $ba, $aa, $55, $75, $aa, $ab, $aa, $aa, $55
    db $15, $55, $55, $ba, $8a, $aa, $aa, $97, $91, $0e, $a2, $5d, $e5, $05, $55, $ab
    db $a2, $aa, $aa, $5d, $15, $54, $d1, $ba, $aa, $55, $54, $ad, $ba, $aa, $aa, $15
    db $57, $54, $55, $aa, $ab, $aa, $aa, $4d, $45, $ac, $aa, $d5, $c6, $d7, $61, $a2
    db $ea, $bf, $48, $55, $17, $7c, $45, $8a, $72, $51, $59, $aa, $a2, $ea, $aa, $4c
    db $15, $d5, $55, $ab, $aa, $aa, $aa, $f7, $54, $ba, $aa, $d1, $55, $b5, $8d, $2a
    db $e2, $6a, $8e, $75, $45, $dd, $dd, $aa, $b8, $55, $55, $aa, $bf, $ba, $aa, $45
    db $77, $55, $55, $28, $a2, $a8, $2a, $c5, $77, $23, $ba, $15, $61, $55, $55, $6e
    db $ea, $8b, $aa, $10, $55, $55, $d5, $aa, $bb, $55, $55, $a8, $aa, $aa, $ba, $55
    db $75, $54, $55, $9a, $ae, $af, $aa, $55, $58, $ea, $aa, $d7, $47, $15, $50, $82
    db $ab, $aa, $8a, $55, $b5, $6d, $5d, $a2, $a8, $55, $55, $a2, $8a, $aa, $8a, $75
    db $d7, $55, $51, $aa, $0a, $aa, $e8, $15, $55, $aa, $aa, $55, $55, $65, $41, $aa
    db $2a, $aa, $a3, $55, $25, $55, $57, $aa, $9a, $75, $55, $aa, $af, $aa, $82, $55
    db $55, $57, $55, $ab, $aa, $ba, $2a, $54, $55, $aa, $aa, $57, $15, $55, $5d, $aa
    db $8a, $ae, $ea, $55, $55, $55, $55, $aa, $bb, $45, $55, $8a, $b2, $aa, $ea, $5a
    db $5d, $41, $55, $02, $ab, $a8, $aa, $73, $55, $e8, $ae, $c4, $45, $55, $5d, $aa
