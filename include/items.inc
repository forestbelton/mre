; Floor object codes for Monster Rancher Explorer (tower floor piece grid,
; wFloorGrid). DrawFloorPiece ($17DE): bit 7 set = item, else a room-piece tile.
;
; ITEM ENCODING (confirmed): an item byte = placement-flag | base-id (low 6 bits).
;   ITEM_OPEN   ($C0, bit 6 set)   = lying in the open
;   ITEM_HIDDEN ($80, bit 6 clear) = revealed by destroying a crate
; e.g. COIN_GOLD = ITEM_OPEN|$13 = $D3 (open) / ITEM_HIDDEN|$13 = $93 (hidden);
;      DIAMOND_BLUE = $CE open / $8E hidden.
; (KEY_SILVER is open-coded but gated separately by progression -- the first
;  silver key must be taken at the tower top -- not by the hidden bit.)

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

ENDC ; ITEMS_INC
