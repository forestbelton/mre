; Song/SFX data for sound driver bank $3f (ids $00-$2e) -- SOUND_BANK_0.
; The $4b00 pointer table + one INCLUDE per song (address order).
INCLUDE "sound.inc"

SECTION "Sound bank 0", ROMX

SOUND_DRIVER SOUND_BANK_0

SOUND_TABLE
    SOUND Snd_SFX_Silence ; id $00
    SOUND Snd_SFX_01 ; id $01
    SOUND Snd_SFX_02 ; id $02
    SOUND Snd_SFX_03 ; id $03
    SOUND Snd_SFX_Cursor ; id $04
    SOUND Snd_SFX_ItemUse ; id $05
    SOUND Snd_SFX_06 ; id $06
    SOUND Snd_SFX_07 ; id $07
    SOUND Snd_SFX_08 ; id $08
    SOUND Snd_SFX_09 ; id $09
    SOUND Snd_SFX_0a ; id $0a
    SOUND Snd_SFX_0b ; id $0b
    SOUND Snd_SFX_0c ; id $0c
    SOUND Snd_SFX_Confirm ; id $0d
    SOUND Snd_SFX_Cancel ; id $0e
    SOUND Snd_SFX_0f ; id $0f
    SOUND Snd_SFX_10 ; id $10
    SOUND Snd_SFX_11 ; id $11
    SOUND Snd_SFX_12 ; id $12
    SOUND Snd_SFX_13 ; id $13
    SOUND Snd_SFX_14 ; id $14
    SOUND Snd_SFX_15 ; id $15
    SOUND Snd_SFX_16 ; id $16
    SOUND Snd_SFX_17 ; id $17
    SOUND Snd_SFX_18 ; id $18
    SOUND Snd_SFX_19 ; id $19
    SOUND Snd_SFX_1a ; id $1a
    SOUND Snd_SFX_1b ; id $1b
    SOUND Snd_SFX_1c ; id $1c
    SOUND Snd_SFX_1d ; id $1d
    SOUND Snd_SFX_1e ; id $1e
    SOUND Snd_SFX_1f ; id $1f
    SOUND Snd_SFX_20 ; id $20
    SOUND Snd_SFX_21 ; id $21
    SOUND Snd_SFX_22 ; id $22
    SOUND Snd_SFX_23 ; id $23
    SOUND Snd_SFX_24 ; id $24
    SOUND Snd_SFX_Lift ; id $25
    SOUND Snd_SFX_26 ; id $26
    SOUND Snd_SFX_27 ; id $27
    SOUND Snd_BGM_Silence ; id $28
    SOUND Snd_BGM_Room ; id $29
    SOUND Snd_BGM_2a ; id $2a
    SOUND Snd_BGM_2b ; id $2b
    SOUND Snd_BGM_2c ; id $2c
    SOUND Snd_BGM_2d ; id $2d
    SOUND Snd_BGM_2e ; id $2e
END_SOUND_TABLE
