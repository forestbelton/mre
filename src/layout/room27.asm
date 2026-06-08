; Floor 27 (record 26) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room27", ROMX[$7b02], BANK[$2d]
Room27:
    dstruct Header, , .Id=$16, .SpawnX=1, .SpawnY=8, .Pad=$00, .Tileset=$05, .Palette=$03, .Height=10, .Width=11
    assert @ - Room27 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_C, COLL_C, COLL_F, COLL_C, COLL_C, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_C, COLL_F, COLL_W, COLL_F, COLL_C, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_C, COLL_C, COLL_F, COLL_C, COLL_C, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_C, COLL_F, COLL_F, COLL_F, COLL_W, COLL_C, COLL_C, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_C, COLL_F, COLL_C, COLL_F, COLL_C, COLL_C, COLL_F, COLL_B
    db COLL_B, COLL_C, COLL_C, COLL_F, COLL_W, COLL_F, COLL_W, COLL_F, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, $42, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BELL, COLL_F, COLL_F, COLL_F, $42, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, TILE_EXIT, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_SILVER_MEDAL, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_NUGGET, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_MEDAL, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_DUCK_DOLL, COLL_F, $42, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_BOMB_LARGE, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_FLAME_BLUE, MONSTER_TACOPI, MONSTER_NAGA, MONSTER_TIGER

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=4, .Y=3, .Type=$22, .Param=$00, .Index=0   ; FLAME_BLUE
    dstruct Monster, , .X=6, .Y=3, .Type=$22, .Param=$00, .Index=0   ; FLAME_BLUE
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
    dstruct Spawner, , .X=1, .Y=1, .P0=$01, .P1=$02, .P2=$03, .Spawn0=1, .Spawn1=1, .Spawn2=SPAWN_NONE, .Spawn3=SPAWN_NONE, .Spawn4=SPAWN_NONE, .Spawn5=SPAWN_NONE, .End=INERT
    dstruct Spawner, , .X=9, .Y=1, .P0=$01, .P1=$02, .P2=$03, .Spawn0=1, .Spawn1=1, .Spawn2=SPAWN_NONE, .Spawn3=SPAWN_NONE, .Spawn4=SPAWN_NONE, .Spawn5=SPAWN_NONE, .End=INERT
    dstruct Spawner, , .X=7, .Y=7, .P0=$02, .P1=$00, .P2=$02, .Spawn0=SPAWN_NONE, .Spawn1=SPAWN_NONE, .Spawn2=SPAWN_NONE, .Spawn3=SPAWN_NONE, .Spawn4=SPAWN_NONE, .Spawn5=SPAWN_NONE, .End=INERT
    EMPTY_SPAWNER_SLOT
    assert @ - .spawners == sizeof_Spawner * 4

    ; --- 256 bytes of unused slot slack: every floor record is a fixed
    ; 581-byte slot (sized for the max 14x17 floor); this 10x11 floor fills
    ; only 325, leaving this leftover/default tail. Never read by anything.
    ; See docs/floor_data.md "Record trailer". ---
.trailer
    db $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $00
    db $00, $ce, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00
    db $00, $cd, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00
    db $00, $00, $00, $00, $c2, $00, $00, $00, $40, $00, $20, $20, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $20
    db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $00
    db $01, $02, $0e, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff
    db $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01
    db $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff
    db $04, $02, $01, $00, $03, $00, $ff, $ff, $ff, $ff, $ff, $ff, $02, $02, $01, $00
    db $03, $00, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
