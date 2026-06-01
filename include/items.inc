; Floor object codes for Monster Rancher Explorer (tower floor grids; see
; docs/floor_data.md). A floor cell has a piece-grid byte (wFloorGrid) and a
; collision-grid byte (wFloorCollision).
;
; PIECE grid -- DrawFloorPiece ($17DE): bit 7 set = item, else a room-piece tile.
; ITEM byte = placement | base-id (low 6 bits):
;   ITEM_OPEN   ($C0, bit 6 set)   = present (lying out, or inside a crate)
;   ITEM_HIDDEN ($80, bit 6 clear) = phantom; appears only after a crate is made
;                                    and destroyed on the cell
; e.g. COIN_GOLD = $D3 open / $93 hidden; DIAMOND_BLUE = $CE open / $8E hidden.
;
; Placement is driven by the cell's COLLISION value, not just bit 6:
;   in-crate: collision $22 (a crate hides the item) -- for EITHER bit 6 value
;   visible : collision $00, bit 6 set
;   hidden  : collision $00, bit 6 clear (phantom; appears via make+break crate)
; (KEY_SILVER is open-coded but gated separately by progression, not these flags.)

IF !DEF(ITEMS_INC)
DEF ITEMS_INC EQU 1

DEF ITEM_OPEN    EQU $C0
DEF ITEM_HIDDEN  EQU $80

; base item ids (low 6 bits); compose with a placement flag: ITEM_OPEN | IID_KEY
DEF IID_KEY          EQU $00
DEF IID_KEY_SILVER   EQU $01
DEF IID_BELL         EQU $02
DEF IID_HOURGLASS_ORANGE EQU $05   ; sets the timer to 50 seconds
DEF IID_COX_HAT      EQU $07   ; extra life (1-UP)
DEF IID_BOMB_SMALL   EQU $08
DEF IID_BOMB_LARGE   EQU $09
DEF IID_FIREPLACE    EQU $0A
DEF IID_GUNPOWDER    EQU $0B
DEF IID_CRYSTAL_BLUE EQU $0C
DEF IID_CRYSTAL_RED  EQU $0D
DEF IID_DIAMOND_BLUE EQU $0E
DEF IID_DIAMOND_RED  EQU $0F
DEF IID_RING_PLATINUM EQU $10   ; 50,000-point pickup
DEF IID_COIN_GRAY    EQU $11
DEF IID_NUGGET_GRAY  EQU $12
DEF IID_COIN_GOLD    EQU $13
DEF IID_NUGGET_GOLD  EQU $14
DEF IID_HEAL_BADGE   EQU $15   ; 10,000-point pickup
DEF IID_MONSTER_FLAME EQU $1D   ; warp to the friendly-monster bonus stage
DEF IID_DOLL_DUCK    EQU $1E
DEF IID_DISC_STONE_PIECE EQU $20

; non-item room-piece tiles (bit 7 clear)
DEF TILE_EXIT          EQU $40
DEF TILE_OBSTACLE_BAT  EQU $43

; collision-grid (wFloorCollision) values
DEF COLL_FLOOR   EQU $00   ; walkable
DEF COLL_BORDER  EQU $20
DEF COLL_WALL    EQU $21
DEF COLL_CRATE   EQU $22   ; breakable crate (an item on this cell is in-crate)

; monster species (arr1 / sprite-set ids referenced by the arr2 monster slots)
DEF MON_TACOPI  EQU $00   ; aka Octopee
DEF MON_JELL    EQU $01
DEF MON_NAGA    EQU $02
DEF MON_DINO    EQU $03
DEF MON_PLANT   EQU $04
DEF MON_HENGER  EQU $05
DEF MON_JOKER   EQU $06
DEF MON_GHOST   EQU $07
DEF MON_PUNCHO    EQU $08
DEF MON_PSIROLLER EQU $09
DEF MON_DAKKUNG   EQU $0A
DEF MON_RED_FLAME  EQU $0B
DEF MON_BLUE_FLAME EQU $0C
DEF MON_GALI       EQU $11   ; friendly monster found in a bonus stage
DEF MON_GOLEM      EQU $12   ; friendly monster found in a bonus stage

ENDC ; ITEMS_INC
