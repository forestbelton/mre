; Sound ids passed in A to PlaySound / PlaySoundTracked /
; PlaySoundIfChanged (src/sound.asm). Names from docs/sound_engine.md's id
; table; ids whose role isn't pinned keep a SOUND_{SFX,BGM}_<hexid>
; placeholder. $00-$27 are SFX (transient path), $28-$3a are BGM (tracked).
; The enum is contiguous, so each discriminant equals the id byte.
IF !DEF(SOUND_IDS_INC)
DEF SOUND_IDS_INC EQU 1

INCLUDE "enum.inc"

enum SOUND
    case SFX_Silence  ; $00 silence / stop (default $4d00 entry)
    case SFX_01       ; $01 bank $12 UI
    case SFX_02       ; $02 boot menu (banks $03/$30)
    case SFX_03       ; $03
    case SFX_Cursor   ; $04 pervasive UI cursor-move blip
    case SFX_ItemUse  ; $05 item use (every ItemEffect_* handler)
    case SFX_06       ; $06 bank $01/$30 event
    case SFX_07       ; $07
    case SFX_08       ; $08 bank $01/$30 event (Cox-hat item)
    case SFX_09       ; $09 bank $01/$30 event
    case SFX_0a       ; $0a bank $01/$30 event
    case SFX_0b       ; $0b bank $01/$30 event
    case SFX_0c       ; $0c
    case SFX_Confirm  ; $0d common UI confirm / action
    case SFX_Cancel   ; $0e UI cancel / secondary
    case SFX_0f       ; $0f
    case SFX_10       ; $10
    case SFX_11       ; $11 bank $03/$30 event
    case SFX_12       ; $12
    case SFX_13       ; $13
    case SFX_14       ; $14
    case SFX_15       ; $15 bank $03/$30 event
    case SFX_16       ; $16
    case SFX_17       ; $17
    case SFX_18       ; $18
    case SFX_19       ; $19
    case SFX_1a       ; $1a
    case SFX_1b       ; $1b
    case SFX_1c       ; $1c
    case SFX_1d       ; $1d
    case SFX_1e       ; $1e
    case SFX_1f       ; $1f
    case SFX_20       ; $20
    case SFX_21       ; $21 bank $31/$01 event
    case SFX_22       ; $22 bank $31/$01 event
    case SFX_23       ; $23
    case SFX_24       ; $24 bank $31/$01 event
    case SFX_Lift     ; $25 player lift (Player_LiftThink)
    case SFX_26       ; $26 bank $31/$01 event
    case SFX_27       ; $27
    case BGM_Silence  ; $28 BGM silence / stop (rest;goto-self on all channels)
    case BGM_Room     ; $29 room / tower gameplay
    case BGM_2a       ; $2a bank $01 scene cue
    case BGM_2b       ; $2b bonus stage (tentative)
    case BGM_2c       ; $2c bank $01 scene cue
    case BGM_2d       ; $2d bank $01 scene cue
    case BGM_2e       ; $2e bank $01 scene cue
    case BGM_Town     ; $2f town
    case BGM_Bodka    ; $30 Bodka menu / studio / intro
    case BGM_RoomTransition ; $31 room transition (walking between floors)
    case BGM_Pashute  ; $32 Pashute scenes
    case BGM_Verde    ; $33 Verde scenes
    case BGM_Toamuna  ; $34 Toamuna (ranch / save NPC)
    case BGM_DiscRegen ; $35 disc-stone regeneration
    case BGM_RivalEncounter ; $36 rival encounter (Kalum/Mistral/Rafaga/Tempest/Nada)
    case BGM_Title    ; $37 title theme
    case BGM_Intro    ; $38 intro
    case BGM_39       ; $39 bank $13 (likely ending/credits)
    case BGM_3a       ; $3a bank $13 (likely ending/credits)
end_enum

ENDC ; SOUND_IDS_INC
