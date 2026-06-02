; Item attribute database -- four parallel tables, one entry per item base id
; ($00-$23), consumed by the pickup path in room.asm (CollectItem/AddItemScore/
; TrackItemCollection) and the bank-1 cleanup pass. Item names come from the ITEM
; enum in room.inc; see docs/floor_data.md. Carved from analyzed.asm; the per-item
; effect handlers ($5282+) are referenced by address (still in analyzed.asm).

SECTION "item_gate_flags", ROMX[$5162], BANK[$01]
; RemoveConditionalItemsPass strips an item cell when its flag here is nonzero,
; unless wC2D5 bit 0 is set -- the "only on the normal stair path" items.
ItemGateFlags:
    db $00    ; $00 GOLD_KEY
    db $00    ; $01 SILVER_KEY
    db $00    ; $02 BELL
    db $00    ; $03 HALF_TORORON
    db $00    ; $04 FULL_TORORON
    db $00    ; $05 ORANGE_HOURGLASS
    db $00    ; $06 BLUE_HOURGLASS
    db $01    ; $07 COX_HAT
    db $00    ; $08 BOMB_SMALL
    db $00    ; $09 BOMB_LARGE
    db $00    ; $0a FIREPLACE
    db $00    ; $0b GUNPOWDER
    db $00    ; $0c BLUE_CRYSTAL
    db $00    ; $0d RED_CRYSTAL
    db $00    ; $0e BLUE_DIAMOND
    db $00    ; $0f RED_DIAMOND
    db $00    ; $10 PLATINUM_RING
    db $00    ; $11 SILVER_MEDAL
    db $00    ; $12 SILVER_NUGGET
    db $00    ; $13 GOLD_MEDAL
    db $00    ; $14 GOLD_NUGGET
    db $00    ; $15 HEAL_BADGE
    db $00    ; $16 (unused)
    db $01    ; $17 CAKE
    db $00    ; $18 BATTLE_CARD
    db $01    ; $19 GOLD_PEACH
    db $01    ; $1a SILVER_PEACH
    db $01    ; $1b HARE_ICON
    db $01    ; $1c (unused)
    db $00    ; $1d MONSTER_FLAME
    db $00    ; $1e DUCK_DOLL
    db $01    ; $1f ALF_DOLL
    db $00    ; $20 DISC_STONE_PIECE
    db $00    ; $21 (unused)
    db $00    ; $22 (unused)
    db $00    ; $23 RED_DISC_STONE

SECTION "item_collectible_desc", ROMX[$5186], BANK[$01]
; TrackItemCollection's per-id descriptor ($ff = not a tracked "collect a set" item).
ItemCollectibleDesc:
    db $ff    ; $00 GOLD_KEY
    db $ff    ; $01 SILVER_KEY
    db $00    ; $02 BELL
    db $01    ; $03 HALF_TORORON
    db $02    ; $04 FULL_TORORON
    db $03    ; $05 ORANGE_HOURGLASS
    db $04    ; $06 BLUE_HOURGLASS
    db $05    ; $07 COX_HAT
    db $10    ; $08 BOMB_SMALL
    db $11    ; $09 BOMB_LARGE
    db $12    ; $0a FIREPLACE
    db $13    ; $0b GUNPOWDER
    db $15    ; $0c BLUE_CRYSTAL
    db $14    ; $0d RED_CRYSTAL
    db $17    ; $0e BLUE_DIAMOND
    db $16    ; $0f RED_DIAMOND
    db $21    ; $10 PLATINUM_RING
    db $24    ; $11 SILVER_MEDAL
    db $22    ; $12 SILVER_NUGGET
    db $25    ; $13 GOLD_MEDAL
    db $23    ; $14 GOLD_NUGGET
    db $27    ; $15 HEAL_BADGE
    db $26    ; $16 (unused)
    db $33    ; $17 CAKE
    db $30    ; $18 BATTLE_CARD
    db $35    ; $19 GOLD_PEACH
    db $34    ; $1a SILVER_PEACH
    db $37    ; $1b HARE_ICON
    db $32    ; $1c (unused)
    db $20    ; $1d MONSTER_FLAME
    db $36    ; $1e DUCK_DOLL
    db $31    ; $1f ALF_DOLL
    db $06    ; $20 DISC_STONE_PIECE
    db $ff    ; $21 (unused)
    db $ff    ; $22 (unused)
    db $07    ; $23 RED_DISC_STONE

SECTION "item_points", ROMX[$51aa], BANK[$01]
; 4 bytes/id, big-endian BCD score added by AddItemScore.
ItemPoints:
    db $00,$00,$00,$00  ; $00 GOLD_KEY         = 0
    db $00,$00,$00,$00  ; $01 SILVER_KEY       = 0
    db $00,$00,$00,$00  ; $02 BELL             = 0
    db $00,$00,$00,$00  ; $03 HALF_TORORON     = 0
    db $00,$00,$00,$00  ; $04 FULL_TORORON     = 0
    db $00,$00,$00,$00  ; $05 ORANGE_HOURGLASS = 0
    db $00,$00,$00,$00  ; $06 BLUE_HOURGLASS   = 0
    db $00,$00,$00,$00  ; $07 COX_HAT          = 0
    db $00,$00,$00,$00  ; $08 BOMB_SMALL       = 0
    db $00,$00,$00,$00  ; $09 BOMB_LARGE       = 0
    db $00,$00,$00,$00  ; $0a FIREPLACE        = 0
    db $00,$00,$00,$00  ; $0b GUNPOWDER        = 0
    db $00,$00,$02,$00  ; $0c BLUE_CRYSTAL     = 200
    db $00,$00,$00,$00  ; $0d RED_CRYSTAL      = 0
    db $00,$00,$05,$00  ; $0e BLUE_DIAMOND     = 500
    db $00,$00,$50,$00  ; $0f RED_DIAMOND      = 5000
    db $00,$05,$00,$00  ; $10 PLATINUM_RING    = 50000
    db $00,$00,$01,$00  ; $11 SILVER_MEDAL     = 100
    db $00,$00,$02,$00  ; $12 SILVER_NUGGET    = 200
    db $00,$00,$10,$00  ; $13 GOLD_MEDAL       = 1000
    db $00,$00,$20,$00  ; $14 GOLD_NUGGET      = 2000
    db $00,$01,$00,$00  ; $15 HEAL_BADGE       = 10000
    db $00,$02,$00,$00  ; $16 (unused)         = 20000
    db $00,$10,$00,$00  ; $17 CAKE             = 100000
    db $00,$20,$00,$00  ; $18 BATTLE_CARD      = 200000
    db $00,$50,$00,$00  ; $19 GOLD_PEACH       = 500000
    db $00,$50,$00,$00  ; $1a SILVER_PEACH     = 500000
    db $00,$50,$00,$00  ; $1b HARE_ICON        = 500000
    db $01,$00,$00,$00  ; $1c (unused)         = 1000000
    db $00,$00,$00,$00  ; $1d MONSTER_FLAME    = 0
    db $00,$00,$00,$00  ; $1e DUCK_DOLL        = 0
    db $00,$00,$00,$00  ; $1f ALF_DOLL         = 0
    db $00,$00,$00,$00  ; $20 DISC_STONE_PIECE = 0
    db $00,$00,$00,$00  ; $21 (unused)         = 0
    db $00,$00,$00,$00  ; $22 (unused)         = 0
    db $00,$00,$00,$00  ; $23 RED_DISC_STONE   = 0

SECTION "item_effect_table", ROMX[$523a], BANK[$01]
; 2 bytes/id, LE pointer to the bank-1 effect handler ($5282 = generic score-only).
ItemEffectHandlers:
    dw ItemEffect_GoldKey  ; $00 GOLD_KEY        
    dw ItemEffect_SilverKey  ; $01 SILVER_KEY      
    dw ItemEffect_Bell  ; $02 BELL            
    dw ItemEffect_HalfTororon  ; $03 HALF_TORORON    
    dw ItemEffect_FullTororon  ; $04 FULL_TORORON    
    dw ItemEffect_OrangeHourglass  ; $05 ORANGE_HOURGLASS
    dw ItemEffect_BlueHourglass  ; $06 BLUE_HOURGLASS  
    dw ItemEffect_CoxHat  ; $07 COX_HAT         
    dw ItemEffect_BombSmall  ; $08 BOMB_SMALL      
    dw ItemEffect_BombLarge  ; $09 BOMB_LARGE      
    dw ItemEffect_Fireplace  ; $0a FIREPLACE       
    dw ItemEffect_Gunpowder  ; $0b GUNPOWDER       
    dw ItemEffect_BlueCrystal  ; $0c BLUE_CRYSTAL    
    dw ItemEffect_RedCrystal  ; $0d RED_CRYSTAL     
    dw ItemEffect_ScoreOnly  ; $0e BLUE_DIAMOND     (score only)
    dw ItemEffect_ScoreOnly  ; $0f RED_DIAMOND      (score only)
    dw ItemEffect_ScoreOnly  ; $10 PLATINUM_RING    (score only)
    dw ItemEffect_ScoreOnly  ; $11 SILVER_MEDAL     (score only)
    dw ItemEffect_ScoreOnly  ; $12 SILVER_NUGGET    (score only)
    dw ItemEffect_ScoreOnly  ; $13 GOLD_MEDAL       (score only)
    dw ItemEffect_ScoreOnly  ; $14 GOLD_NUGGET      (score only)
    dw ItemEffect_ScoreOnly  ; $15 HEAL_BADGE       (score only)
    dw ItemEffect_ScoreOnly  ; $16 (unused)         (score only)
    dw ItemEffect_ScoreOnly  ; $17 CAKE             (score only)
    dw ItemEffect_BattleCard  ; $18 BATTLE_CARD     
    dw ItemEffect_ScoreOnly  ; $19 GOLD_PEACH       (score only)
    dw ItemEffect_ScoreOnly  ; $1a SILVER_PEACH     (score only)
    dw ItemEffect_ScoreOnly  ; $1b HARE_ICON        (score only)
    dw ItemEffect_Item1c  ; $1c (unused)        
    dw ItemEffect_MonsterFlame  ; $1d MONSTER_FLAME   
    dw ItemEffect_DuckDoll  ; $1e DUCK_DOLL       
    dw ItemEffect_AlfDoll  ; $1f ALF_DOLL        
    dw ItemEffect_DiscPiece  ; $20 DISC_STONE_PIECE
    dw ItemEffect_Item21  ; $21 (unused)        
    dw ItemEffect_Item22  ; $22 (unused)        
    dw ItemEffect_RedDiscStone  ; $23 RED_DISC_STONE  
