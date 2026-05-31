; Floor object codes for Monster Rancher Explorer.
;
; These are the values that appear in a tower floor's piece grid (wFloorGrid);
; see docs/floor_data.md. DrawFloorPiece ($17DE) classifies a cell by its bits:
; bit 7 set = item, bit 6 set = exit, otherwise it's a plain room-piece tile.
;
; $4x are structural (exits/obstacles). For items (bit 7 set), the low 6 bits are
; the base id and bit 6 marks placement: set ($cx-$fx) = placed in the open, clear
; ($8x-$bx) = "hidden" (revealed by destroying a crate). E.g. COIN_GOLD is $d3 open
; / $93 hidden. (KEY_SILVER is open-coded $c1 but gated separately by progression --
; the first silver key must be taken at the tower top -- not by the hidden bit.)

IF !DEF(ITEMS_INC)
DEF ITEMS_INC EQU 1

; -- structural ($4x) --
DEF ITEM_EXIT             EQU $40   ; stairs to the next floor
DEF OBSTACLE_BAT          EQU $43   ; bat-shaped obstruction (impassable)

; -- $8x-$9x (incl. hidden variants) --
DEF ITEM_DIAMOND_RED      EQU $8F
DEF ITEM_COIN_GOLD_HIDDEN EQU $93   ; hidden variant of COIN_GOLD ($d3)

; -- $cx tools / usables --
DEF ITEM_KEY              EQU $C0
DEF ITEM_KEY_SILVER       EQU $C1
DEF ITEM_BELL             EQU $C2
DEF ITEM_BOMB_SMALL       EQU $C8
DEF ITEM_DIAMOND_BLUE     EQU $CE

; -- $dx coins / nuggets / valuables --
DEF ITEM_COIN_GRAY        EQU $D1
DEF ITEM_NUGGET_GRAY      EQU $D2
DEF ITEM_COIN_GOLD        EQU $D3

ENDC ; ITEMS_INC
