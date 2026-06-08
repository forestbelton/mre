; Floor 26 (record 25) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room26", ROMX[$78bd], BANK[$2d]
Room26:
    dstruct Header, , .Type=$14, .SpawnX=9, .SpawnY=3, .Pad=$00, .Param0=$04, .Param1=$03, .Height=10, .Width=11
    assert @ - Room26 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_W, COLL_W, COLL_W, COLL_W, COLL_C, COLL_W, COLL_W, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_W, COLL_C, COLL_W, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_W, COLL_C, COLL_C, COLL_W, COLL_F, COLL_W, COLL_C, COLL_C, COLL_W, COLL_B
    db COLL_B, COLL_W, COLL_F, COLL_F, COLL_W, COLL_C, COLL_W, COLL_F, COLL_F, COLL_W, COLL_B
    db COLL_B, COLL_C, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_C, COLL_B
    db COLL_B, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_W, COLL_B
    db COLL_B, COLL_W, COLL_W, COLL_W, COLL_W, COLL_C, COLL_W, COLL_W, COLL_W, COLL_W, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_MEDAL, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, $42, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, $42, COLL_F, COLL_B
    db COLL_B, TILE_EXIT, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_DISC_STONE_PIECE, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_GOLD_MEDAL, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_MEDAL, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_MEDAL, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_JOKER, MONSTER_HENGER, MONSTER_PLANT, MONSTER_SUEZO

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=5, .Y=2, .Type=$22, .Param=$00, .Index=2   ; PLANT
    dstruct Monster, , .X=7, .Y=6, .Type=$22, .Param=$00, .Index=0   ; JOKER
    dstruct Monster, , .X=3, .Y=7, .Type=$22, .Param=$00, .Index=1   ; HENGER
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    EMPTY_MONSTER_SLOT
    assert @ - .monsters == sizeof_Monster * 9

    ; arr3: 4 spawner slots (Spawner: X,Y,P0,P1,P2,Spawn0..5,End)
.spawners
    dstruct Spawner, , .X=2, .Y=2, .P0=$02, .P1=$00, .P2=$02, .Spawn0=SPAWN_NONE, .Spawn1=SPAWN_NONE, .Spawn2=SPAWN_NONE, .Spawn3=SPAWN_NONE, .Spawn4=SPAWN_NONE, .Spawn5=SPAWN_NONE, .End=INERT
    dstruct Spawner, , .X=8, .Y=2, .P0=$02, .P1=$00, .P2=$02, .Spawn0=SPAWN_NONE, .Spawn1=SPAWN_NONE, .Spawn2=SPAWN_NONE, .Spawn3=SPAWN_NONE, .Spawn4=SPAWN_NONE, .Spawn5=SPAWN_NONE, .End=INERT
    EMPTY_SPAWNER_SLOT
    EMPTY_SPAWNER_SLOT
    assert @ - .spawners == sizeof_Spawner * 4

    ; --- 256 bytes of unused slot slack: every floor record is a fixed
    ; 581-byte slot (sized for the max 14x17 floor); this 10x11 floor fills
    ; only 325, leaving this leftover/default tail. Never read by anything.
    ; See docs/floor_data.md "Record trailer". ---
.trailer
    db $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00, $c8, $00
    db $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $d1, $00
    db $d1, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00, $00, $00
    db $c0, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $93, $00, $00
    db $d1, $00, $d1, $00, $00, $82, $00, $00, $00, $20, $20, $00, $00, $00, $00, $00
    db $00, $00, $e0, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00, $00
    db $00, $00, $00, $00, $94, $00, $00, $00, $00, $00, $00, $00, $20, $20, $00, $00
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $40, $00, $20, $20, $20
    db $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $20, $07
    db $06, $02, $0e, $08, $01, $23, $03, $00, $08, $0b, $23, $02, $00, $01, $08, $23
    db $00, $01, $01, $06, $23, $00, $01, $0f, $06, $23, $01, $01, $0f, $08, $23, $01
    db $01, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff, $ff, $ff, $ff, $01, $ff
    db $07, $02, $02, $00, $02, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $09, $02, $02, $00
    db $02, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
    db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff
