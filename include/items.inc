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
; visible vs in-crate is in the COLLISION grid, not the item byte: an open item on
; COLL_CRATE ($22) is inside a crate; on COLL_FLOOR ($00) it lies in the open. So:
;   visible : item bit6=1, collision $00
;   in-crate: item bit6=1, collision $22
;   hidden  : item bit6=0, collision $00
; (KEY_SILVER is open-coded but gated separately by progression, not these flags.)

IF !DEF(ITEMS_INC)
DEF ITEMS_INC EQU 1

DEF ITEM_OPEN    EQU $C0
DEF ITEM_HIDDEN  EQU $80

; base item ids (low 6 bits); compose with a placement flag: ITEM_OPEN | IID_KEY
DEF IID_KEY          EQU $00
DEF IID_KEY_SILVER   EQU $01
DEF IID_BELL         EQU $02
DEF IID_BOMB_SMALL   EQU $08
DEF IID_CRYSTAL_BLUE EQU $0C
DEF IID_DIAMOND_BLUE EQU $0E
DEF IID_DIAMOND_RED  EQU $0F
DEF IID_COIN_GRAY    EQU $11
DEF IID_NUGGET_GRAY  EQU $12
DEF IID_COIN_GOLD    EQU $13

; non-item room-piece tiles (bit 7 clear)
DEF TILE_EXIT          EQU $40
DEF TILE_OBSTACLE_BAT  EQU $43

; collision-grid (wFloorCollision) values
DEF COLL_FLOOR   EQU $00   ; walkable
DEF COLL_BORDER  EQU $20
DEF COLL_WALL    EQU $21
DEF COLL_CRATE   EQU $22   ; breakable crate (an item on this cell is in-crate)

ENDC ; ITEMS_INC
