; Floor 61 (record 60) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "roomB01", ROMX[$4d9e], BANK[$2f]
RoomB01:
    dstruct Header, , .Id=$39, .SpawnX=5, .SpawnY=1, .Pad=$00, .Tileset=$02, .Palette=$06, .Height=10, .Width=11
    assert @ - RoomB01 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_W, COLL_C, COLL_W, COLL_W, COLL_W, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_F, COLL_W, COLL_F, COLL_W, COLL_C, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_F, COLL_W, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_W, COLL_F, COLL_W, COLL_F, COLL_W, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, $42, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_FULL_TORORON, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_CAKE, TILE_EXIT, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BLUE_HOURGLASS, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_TACOPI, MONSTER_FLAME_BLUE, MONSTER_NAGA, MONSTER_TIGER

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=4, .Y=4, .Type=$22, .Param=$00, .Index=1   ; FLAME_BLUE
    dstruct Monster, , .X=7, .Y=4, .Type=$22, .Param=$00, .Index=1   ; FLAME_BLUE
    dstruct Monster, , .X=9, .Y=4, .Type=$22, .Param=$00, .Index=1   ; FLAME_BLUE
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    assert @ - .monsters == sizeof_Monster * 9

    ; arr3: 4 spawner slots (Spawner: X,Y,P0,P1,P2,Spawn0..5,End)
.spawners
    dstruct Spawner, , .X=2, .Y=1, .P0=$02, .P1=$00, .P2=$02, .Spawn0=0, .Spawn1=0, .Spawn2=0, .Spawn3=SPAWN_NONE, .Spawn4=SPAWN_NONE, .Spawn5=SPAWN_NONE, .End=INERT
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
    db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $bf, $ff, $ff, $00, $00
    db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
    db $00, $00, $00, $00, $00, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $00, $00
