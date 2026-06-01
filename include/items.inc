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

INCLUDE "enum.inc"

DEF ITEM_OPEN    EQU $C0
DEF ITEM_HIDDEN  EQU $80

; base item ids (low 6 bits); compose with a placement flag: ITEM_OPEN | IID_KEY
DEF IID_KEY          EQU $00
DEF IID_KEY_SILVER   EQU $01
DEF IID_BELL         EQU $02     ; Spawns a Suzurizo (collect 10 Suzurizos -> 1-up)
DEF IID_TORORON_HALF EQU $03     ; Doubles the remaining floor time
DEF IID_TORORON_FULL EQU $04     ; Multiplies the remaining floor time by 5
DEF IID_HOURGLASS_ORANGE EQU $05 ; Sets the timer to 50 seconds
DEF IID_HOURGLASS_BLUE EQU $06   ; Sets the timer to 100 seconds
DEF IID_COX_HAT      EQU $07     ; Extra life (1-UP)
DEF IID_BOMB_SMALL   EQU $08
DEF IID_BOMB_LARGE   EQU $09
DEF IID_FIREPLACE    EQU $0A
DEF IID_GUNPOWDER    EQU $0B
DEF IID_CRYSTAL_BLUE EQU $0C
DEF IID_CRYSTAL_RED  EQU $0D
DEF IID_DIAMOND_BLUE EQU $0E
DEF IID_DIAMOND_RED  EQU $0F
DEF IID_RING_PLATINUM EQU $10    ; 50,000-point pickup
DEF IID_COIN_GRAY    EQU $11
DEF IID_NUGGET_GRAY  EQU $12
DEF IID_COIN_GOLD    EQU $13
DEF IID_NUGGET_GOLD  EQU $14
DEF IID_HEAL_BADGE   EQU $15     ; 10,000-point pickup
DEF IID_CAKE         EQU $17     ; 100,000-point pickup
DEF IID_BATTLE_CARD  EQU $18
DEF IID_PEACH_GOLD   EQU $19     ; 500,000-point pickup
DEF IID_MONSTER_FLAME EQU $1D    ; Warp to the friendly-monster bonus stage
DEF IID_DOLL_DUCK    EQU $1E     ; Transforms monsters into entity $08 (effect Func_01_55a6)
DEF IID_DOLL_ALF     EQU $1F     ; Turns all monsters into Suzurizos (entity $1f, as BELL spawns)
DEF IID_DISC_STONE_PIECE EQU $20
DEF IID_RED_DISC_STONE EQU $23   ; Contains Phoenix

; $16 is a real item, not an unused gap: it has a distinct sprite in FloorPieceDefs
; ($d6 -> tiles 40/6b, same structure as its neighbours). But it never appears in
; play or in reference maps -- even visible-coded on floor 69 -- so it's runtime-
; gated like COX_HAT. Unidentified (would need to be triggered in-game, or its
; sprite rendered, to name).
;
; The item id space is base $00-$23 (FloorPieceDefs covers open codes $c0-$e3;
; $e4+ have no entry). $21 and $22 are defined there (sprites $e1/$e2) but never
; placed on any floor or bonus stage -- cut/reserved content.

; Item points + effect tables (bank $01, used by the pickup dispatch Func_01_5060):
;   Data_01_51aa ($51aa) -- 4 bytes/id, big-endian BCD point value added to score.
;   $523a               -- 2 bytes/id, LE pointer to the per-id effect handler.
;   ($19 PEACH_GOLD = 500,000 here, matching its known name -- confirmed in-game on
;    floor 45 (r6,c1, hidden), so the decode's id<->value mapping is trustworthy.)
;
; Statically decoded facts for the remaining unmapped ids (points + handler kind):
;   $16  20,000 pts, generic handler -- but phantom (see above); NOT in the $5162
;        conditional-appearance table, so its suppression is a separate mechanism.
;   $1a  500,000 pts, generic points-only handler ($5282)  -- PEACH-class
;   $1b  500,000 pts, generic points-only handler ($5282)  -- PEACH-class
;   $1c  1,000,000 pts, points-only handler ($53a0)         -- highest-value item
;   $1f  DOLL_ALF (now named above): 0 pts, effect Func_01_5544 ($53ab) kills each
;        monster and spawns entity $1f (Suzurizo) at its position -- the same entity
;        BELL spawns. Proven from code (sibling of $1e DOLL_DUCK, which spawns $08).
;
; Names from the in-game list still to be matched (need in-game confirmation):
;   PEACH_SILVER -- 500,000 points  => one of $1a/$1b (both 500k points-only).
;   DOLL_AYA     -- effect unknown   => not yet located (no remaining 0-pt DOLL id;
;                   may be an alias, $1c, or cut). $1f is DOLL_ALF, proven above.
;   ($1c at 1,000,000 pts has no name in the player's list yet -- a premium item.)
;
; These 7 ids ($07 COX_HAT, $17 CAKE, $19 PEACH_GOLD, $1a, $1b, $1c, $1f) share the
; $5162 conditional-appearance flag and are removed at floor-load by Func_01_56fb
; when wC2D5 bit 0 is clear -- see docs/floor_data.md. They DO appear in normal play
; (PEACH_GOLD did), so $1a/$1b/$1c/$1f are observable, not permanently phantom.

; non-item room-piece tiles (bit 7 clear)
DEF TILE_EXIT          EQU $40
DEF TILE_OBSTACLE_BAT  EQU $43

; collision-grid (wFloorCollision) values
DEF COLL_FLOOR   EQU $00   ; walkable
DEF COLL_BORDER  EQU $20
DEF COLL_WALL    EQU $21
DEF COLL_CRATE   EQU $22   ; breakable crate (an item on this cell is in-crate)

; monster species (arr1 / sprite-set ids referenced by the arr2 monster slots)
enum MONSTER
    case TACOPI ; aka Octopee
    case JELL
    case NAGA
    case DINO
    case PLANT
    case HENGER
    case JOKER
    case GHOST
    case PUNCHO
    case PSIROLLER
    case DAKKUNG
    case FLAME_RED
    case FLAME_BLUE

    skip ; Unused

    ; Friendly monsters available on bonus stages
    case TIGER  ; Floor 56
    case MOCCHI ; Floor 58
    case HARE   ; Floor 06
    case GALI   ; Floor 18
    case GOLEM  ; Floor 22
    case SUEZO  ; Floor 44
end_enum

ENDC ; ITEMS_INC
