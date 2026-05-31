; Floor object codes for Monster Rancher Explorer.
;
; These are the values that appear in a tower floor's piece grid (wFloorGrid);
; see docs/floor_data.md. DrawFloorPiece ($17DE) classifies a cell by its bits:
; bit 7 set = item, bit 6 set = exit, otherwise it's a plain room-piece tile.
;
; Codes group by high nibble: $4x structural (exits/stairs), $8x-$9x gems,
; $cx tools/usables, $dx-$ex coins/nuggets/valuables. Many remain unidentified.

    IF !DEF(ITEMS_INC)
DEF ITEMS_INC EQU 1

; -- structural ($4x) --
DEF ITEM_EXIT         EQU $40   ; stairs to the next floor

; -- gems ($8x-$9x) --
DEF ITEM_DIAMOND_RED  EQU $8F

; -- tools / usables ($cx) --
DEF ITEM_KEY          EQU $C0
DEF ITEM_BELL         EQU $C2
DEF ITEM_BOMB_SMALL   EQU $C8

; -- coins / nuggets / valuables ($dx) --
DEF ITEM_COIN_GRAY    EQU $D1
DEF ITEM_NUGGET_GRAY  EQU $D2
DEF ITEM_COIN_GOLD    EQU $D3

    ENDC ; ITEMS_INC
