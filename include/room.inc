; Tower floor/room definitions for Monster Rancher Explorer (see docs/floor_data.md).
; A floor cell has a piece-grid byte (wFloorGrid) and a collision-grid byte
; (wFloorCollision); a floor record also carries the sprite/monster/spawner tables.
;
; PIECE grid -- DrawFloorPiece ($17DE) classifies a cell by bit 7, then reads bit 6
; for placement; the base id is the low 6 bits (and $3f). So an item byte is:
;       ITEM_FLAG | (open ? ITEM_OPEN : 0) | base-id
;   bit 7 (ITEM_FLAG) -- set on EVERY item; it's just the "this cell is an item"
;                        marker (a clear bit 7 is a room-piece tile, e.g. $40 EXIT,
;                        $43 Devil's Seal -- those set bit 6 but not bit 7).
;   bit 6 (ITEM_OPEN) -- the single open/hidden flag: set = open/visible, clear =
;                        hidden (phantom; appears only after a crate is made+broken).
; e.g. GOLD_MEDAL = $D3 open / $93 hidden; BLUE_DIAMOND = $CE open / $8E hidden.
;
; The *displayed* state also depends on the cell's COLLISION value, not just bit 6:
;   in-crate: collision $22 (a crate hides the item) -- regardless of bit 6
;   visible : collision $00, bit 6 set
;   hidden  : collision $00, bit 6 clear (phantom; appears via make+break crate)
; (SILVER_KEY is open-coded but gated separately by progression, not these flags.)

IF !DEF(ROOM_INC)
DEF ROOM_INC EQU 1

INCLUDE "enum.inc"
INCLUDE "structs.inc"

DEF ITEM_FLAG    EQU $80   ; bit 7: marks the cell as an item (set on every item)
DEF ITEM_OPEN    EQU $40   ; bit 6: open/visible (clear = hidden/phantom)

; base item ids (low 6 bits). Compose: ITEM_FLAG | ITEM_OPEN | ITEM_GOLD_KEY (visible),
; or ITEM_FLAG | ITEM_GOLD_KEY (hidden). E.g. visible KEY = $C0, hidden KEY = $80.
enum ITEM
    case GOLD_KEY          ; Opens the exit
    case SILVER_KEY        ; Unlocks a basement room
    case BELL              ; Spawns a Suzurin (collect 10 Suzurins -> 1-up)
    case HALF_TORORON      ; Doubles the remaining floor time
    case FULL_TORORON      ; Multiplies the remaining floor time by 5
    case ORANGE_HOURGLASS  ; Sets remaining floor time to 50 seconds
    case BLUE_HOURGLASS    ; Sets remaining floor time to 100 seconds
    case COX_HAT           ; Extra life (1-up)
    case BOMB_SMALL        ; Fire at an enemy to kill
    case BOMB_LARGE        ; Fire at an enemy to kill (pierces)
    case FIREPLACE         ; Increases number of bomb slots
    case GUNPOWDER
    case BLUE_CRYSTAL
    case RED_CRYSTAL
    case BLUE_DIAMOND
    case RED_DIAMOND
    case PLATINUM_RING     ; Awards 50K points
    case SILVER_MEDAL      ; Awards 100 points
    case SILVER_NUGGET     ; Awards 200 points
    case GOLD_MEDAL        ; Awards 1K points
    case GOLD_NUGGET
    case HEAL_BADGE        ; Awards 10K points
    case WALKING_COIN      ; $16 (20,000 pts); a gold coin with legs (tentative name).
                           ;   Force-hidden on every floor by Func_05_49c8, so never
                           ;   collectible in normal play (observed only via ROM hack).
    case CAKE              ; Awards 100K points
    case BATTLE_CARD
    case GOLD_PEACH        ; Awards 500K points
    case SILVER_PEACH      ; Awards 500K points
    case HARE_ICON         ; Awards 500K points
    case AYA_DOLL          ; $1c (1,000,000 pts); gated by $5162 + force-hidden by
                           ;   Func_05_496b, so never collectible in normal play
                           ;   (observed only via ROM hack). Confirmed in-game.
    case MONSTER_FLAME     ; Exit goes to bonus stage with friendly monster
    case DUCK_DOLL         ; Transforms all monsters into entity $08 (effect Func_01_55a6) & they die
    case ALF_DOLL          ; Transforms all monsters into Suzurins (confirmed in-game)
    case DISC_STONE_PIECE  ; Collect 4 for a full disc stone
    skip                   ; $21 special-stage "collect 4" token (bomb art, NOT a real
                           ;   bomb -- pickup adds no bombs): 4x in the corners of the
                           ;   no-monster floors 75/76 (record $12:$574d), 0 pts, no
                           ;   encyclopedia entry. ItemEffect_Item21 ($5462) bumps $cf7e;
                           ;   the 4th sets $cf40=1 + Func_01_5854(c=4) (GOLD_KEY's unlock).
    skip                   ; $22 silver-key stage-advance token (silver-key art): not placed
                           ;   in normal play. ItemEffect_Item22 ($5485, a real handler) runs
                           ;   the silver-key unlock (Func_01_47a9) then sets $c2d6=1, which
                           ;   the main loop reads as "stage complete" (Func_01_45ad -> $c2a7
                           ;   =$13). Pickup instantly ends the stage; tied to basement-room
                           ;   ($c2c1==2) descent. No encyclopedia entry.
    case RED_DISC_STONE    ; Contains Phoenix (gives a Phenix disc stone on pickup)
end_enum

; $16/$1c are real items (distinct FloorPieceDefs sprites) but never collectible in
; normal play: every floor-load forces them hidden (bit 6 clear), and the pickup
; check (RemoveOpenItemAtCell) only takes open items. The suppressors are bank-$05
; grid passes run by FloorPostLoadCleanup: Func_05_49c8 re-hides $16 (always),
; Func_05_496b re-hides $1c/$1f (when $c2e8==0); $1c/$1f/etc. are also stripped by
; the $5162 conditional-appearance gate (RemoveConditionalItemsPass) unless wC2D5
; bit 0 is set. $1b HARE_ICON is removed by Func_05_499d unless $c2aa!=0. All three
; were collected (encyclopedia) only after NOPing those passes -- see git history.
; See docs/floor_data.md for the points/effect tables (Data_01_51aa / $523a).
;
; The item id space is base $00-$23 (FloorPieceDefs covers open codes $c0-$e3;
; $e4+ have no entry). $21 (sprite $e1) appears only on the special floors 75/76;
; $22 (sprite $e2) is defined but never placed.

; non-item room-piece tiles (bit 7 clear)
DEF TILE_EXIT          EQU $40
DEF TILE_OBSTACLE_BAT  EQU $43   ; "Devil's Seal"

; collision-grid (wFloorCollision) values -- short names keep grid rows aligned
DEF COLL_F  EQU $00   ; walkable floor
DEF COLL_B  EQU $20   ; border
DEF COLL_W  EQU $21   ; wall
DEF COLL_C  EQU $22   ; breakable crate (an item on this cell is in-crate)

; monster species (arr1 / sprite-set ids referenced by a monster slot's GfxIndex)
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
    case PSYLORA ; aka Psiroller
    case DUCKEN ; aka Dakkung
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

; The 8-byte floor-record header. Instantiate with e.g.
;   dstruct Header, , .Type=$61, .SpawnX=2, .SpawnY=7, .Pad=0, .Param0=0, .Param1=1, .Height=10, .Width=11
struct Header
    bytes 1, Type     ; floor theme/type
    bytes 1, SpawnX   ; player start column
    bytes 1, SpawnY   ; player start row
    bytes 1, Pad      ; always $00
    bytes 1, Param0   ; undecoded (observed 0-5)
    bytes 1, Param1   ; undecoded (observed 0-6)
    bytes 1, Height
    bytes 1, Width
end_struct

; A monster slot (arr2; 9 per floor). Sprite/species = MonsterSprites[Index];
; Index == INERT marks an empty slot. Instantiate with e.g.
;   dstruct Monster, , .X=6, .Y=4, .Type=$22, .Param=0, .Index=1
struct Monster
    bytes 1, X
    bytes 1, Y
    bytes 1, Type      ; per-instance attribute (not the species)
    bytes 1, Param
    bytes 1, Index     ; index into the floor's MonsterSprites (arr1)
end_struct

; A monster spawner slot (arr3; 4 per floor, 12 bytes each). ProcessFloorSpawners
; ($41aa) reads X/Y (the spawn cell), the P0-P2 timing params, then a 6-step spawn
; schedule. Each schedule step is an index into the floor's MonsterSprites table
; (arr1), taken as the low 2 bits; SPAWN_NONE ($FF, i.e. index 3) means "spawn
; nothing this step". So {2,2,2,-,-,-} spawns MonsterSprites[2] three times
; (floor 23 = 3x Naga); {0,2,-,-,-,-} spawns sprites[0] then sprites[2] (floor 47).
; End is an unused trailing byte; an all-$FF slot is empty. See docs/floor_data.md.
struct Spawner
    bytes 1, X
    bytes 1, Y
    bytes 1, P0        ; spawn-timing params (rate/interval; packed, undecoded)
    bytes 1, P1
    bytes 1, P2
    bytes 1, Spawn0    ; spawn schedule: each step = arr1 index (low 2 bits),
    bytes 1, Spawn1    ;   SPAWN_NONE = no spawn this step
    bytes 1, Spawn2
    bytes 1, Spawn3
    bytes 1, Spawn4
    bytes 1, Spawn5
    bytes 1, End       ; unused trailing byte
end_struct

DEF INERT EQU $FF        ; empty/missing monster or spawner slot
DEF SPAWN_NONE EQU $FF   ; spawner schedule: no spawn this step (arr1 index 3)

; Fixed fillers for unused slots -- byte-identical across all 70 floors.
MACRO EMPTY_MONSTER_SLOT
    db INERT, INERT, INERT, $01, INERT
ENDM
MACRO EMPTY_SPAWNER_SLOT
    db INERT, INERT, INERT, INERT, INERT, INERT, INERT, INERT, INERT, INERT, INERT, INERT
ENDM

ENDC ; ROOM_INC
