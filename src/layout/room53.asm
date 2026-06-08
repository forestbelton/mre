; Floor 53 (record 52) -- 11 wide x 10 tall. Tower floor data; see docs/floor_data.md.

INCLUDE "room.inc"

SECTION "room53", ROMX[$78bd], BANK[$2e]
Room53:
    dstruct Header, , .Type=$28, .SpawnX=9, .SpawnY=1, .Pad=$00, .Param0=$00, .Param1=$00, .Height=10, .Width=11
    assert @ - Room53 == sizeof_Header

    ; collision grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_W, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_W, COLL_F, COLL_C, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_W, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_W, COLL_W, COLL_C, COLL_W, COLL_W, COLL_F, COLL_W, COLL_B
    db COLL_B, COLL_C, COLL_F, COLL_W, COLL_W, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_C, COLL_W, COLL_C, COLL_W, COLL_W, COLL_W, COLL_F, COLL_W, COLL_B
    db COLL_B, COLL_C, COLL_F, COLL_C, COLL_F, COLL_F, COLL_W, COLL_W, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_C, COLL_W, COLL_F, COLL_C, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_W, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; piece/object grid (10 rows x 11)
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_SILVER_KEY, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, TILE_EXIT, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_COX_HAT, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, ITEM_FLAG | ITEM_SILVER_MEDAL, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_B
    db COLL_B, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, COLL_F, ITEM_FLAG | ITEM_OPEN | ITEM_RED_DIAMOND, COLL_B
    db COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B, COLL_B

    ; arr1: per-floor sprite/species table (indexed by a monster's Index)
    db MONSTER_GHOST, MONSTER_DUCKEN, MONSTER_PSYLORA, MONSTER_TIGER

    ; arr2: 9 monster slots (Monster: X,Y,Type,Param,Index)
.monsters
    dstruct Monster, , .X=8, .Y=4, .Type=$21, .Param=$03, .Index=0   ; GHOST
    dstruct Monster, , .X=1, .Y=8, .Type=$02, .Param=$00, .Index=1   ; DUCKEN
    dstruct Monster, , .X=4, .Y=6, .Type=$22, .Param=$00, .Index=2   ; PSYLORA
    dstruct Monster, , .X=1, .Y=5, .Type=$22, .Param=$00, .Index=2   ; PSYLORA
    dstruct Monster, , .X=5, .Y=2, .Type=$23, .Param=$00, .Index=2   ; PSYLORA
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

    ; --- record trailer (256 bytes), undecoded. Read only by the level
    ; editor (LoadFloorRecordToBuffer -> wFloorSnapshot); gameplay never
    ; reads it. See docs/floor_data.md "Record trailer". ---
.trailer
    db $66, $70, $d5, $3b, $af, $dc, $55, $aa, $21, $b9, $0e, $32, $40, $1b, $d8, $76
    db $7a, $e3, $29, $d2, $60, $b8, $e9, $7c, $71, $66, $a9, $8d, $13, $c6, $30, $3e
    db $7f, $64, $53, $d1, $45, $58, $b7, $c9, $63, $a7, $a8, $4d, $14, $ac, $5c, $a5
    db $d2, $28, $c6, $d3, $6b, $36, $6d, $d7, $70, $30, $47, $ea, $85, $55, $ee, $cf
    db $ab, $37, $e9, $30, $62, $91, $bb, $67, $12, $72, $47, $24, $8f, $d7, $0a, $b2
    db $c3, $52, $12, $75, $0c, $5a, $a8, $c5, $51, $4b, $52, $54, $d6, $a8, $c9, $a3
    db $3a, $ce, $ef, $90, $9e, $1e, $28, $e1, $b1, $5f, $ee, $6b, $9f, $ec, $63, $51
    db $4e, $80, $a5, $6a, $b2, $9b, $52, $b3, $59, $2e, $7f, $fe, $b8, $cc, $8a, $d1
    db $61, $2f, $a6, $cf, $c6, $5c, $76, $42, $e3, $4e, $69, $94, $a8, $e4, $bf, $a8
    db $d2, $bb, $13, $eb, $2a, $ee, $3d, $95, $df, $65, $2b, $2c, $4e, $f6, $5d, $ed
    db $2a, $33, $2d, $ce, $53, $83, $db, $65, $37, $4f, $45, $9b, $11, $a9, $a5, $6d
    db $6f, $ab, $b1, $6d, $4b, $42, $6c, $e5, $35, $45, $a9, $e4, $28, $76, $37, $28
    db $4b, $54, $5c, $f2, $42, $a5, $56, $2a, $1f, $25, $e4, $bf, $dd, $2b, $1c, $3a
    db $c4, $58, $b4, $b6, $af, $4d, $bc, $bd, $ad, $a4, $2b, $59, $99, $a1, $2d, $e8
    db $58, $dc, $82, $6a, $32, $32, $92, $d7, $6a, $a8, $ab, $4f, $94, $c9, $2b, $63
    db $f7, $db, $eb, $cb, $98, $62, $52, $b2, $2a, $b2, $55, $ba, $47, $63, $56, $2a
