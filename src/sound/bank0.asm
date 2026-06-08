; Song/SFX data for sound driver bank $3f (ids $00-$2e) -- SOUND_BANK_0.
; The $4b00 pointer table + one INCLUDE per song (address order).
INCLUDE "sound.inc"

SECTION "Sound bank 0", ROMX

SOUND_DRIVER SOUND_BANK_0

SOUND_TABLE
    SOUND Snd_3f_4d00 ; id $00
    SOUND Snd_3f_4d0f ; id $01
    SOUND Snd_3f_4d39 ; id $02
    SOUND Snd_3f_4d5f ; id $03
    SOUND Snd_3f_4d79 ; id $04
    SOUND Snd_3f_4d95 ; id $05
    SOUND Snd_3f_4dd0 ; id $06
    SOUND Snd_3f_4e15 ; id $07
    SOUND Snd_3f_4e52 ; id $08
    SOUND Snd_3f_4eaa ; id $09
    SOUND Snd_3f_4f05 ; id $0a
    SOUND Snd_3f_4f90 ; id $0b
    SOUND Snd_3f_4faf ; id $0c
    SOUND Snd_3f_5031 ; id $0d
    SOUND Snd_3f_505b ; id $0e
    SOUND Snd_3f_5085 ; id $0f
    SOUND Snd_3f_5098 ; id $10
    SOUND Snd_3f_50b1 ; id $11
    SOUND Snd_3f_5198 ; id $12
    SOUND Snd_3f_524c ; id $13
    SOUND Snd_3f_5283 ; id $14
    SOUND Snd_3f_52ce ; id $15
    SOUND Snd_3f_534b ; id $16
    SOUND Snd_3f_539e ; id $17
    SOUND Snd_3f_5433 ; id $18
    SOUND Snd_3f_547a ; id $19
    SOUND Snd_3f_54b7 ; id $1a
    SOUND Snd_3f_5514 ; id $1b
    SOUND Snd_3f_55a3 ; id $1c
    SOUND Snd_3f_55ef ; id $1d
    SOUND Snd_3f_55fe ; id $1e
    SOUND Snd_3f_5630 ; id $1f
    SOUND Snd_3f_5652 ; id $20
    SOUND Snd_3f_5689 ; id $21
    SOUND Snd_3f_56bd ; id $22
    SOUND Snd_3f_56ee ; id $23
    SOUND Snd_3f_5724 ; id $24
    SOUND Snd_3f_5760 ; id $25
    SOUND Snd_3f_579c ; id $26
    SOUND Snd_3f_57fb ; id $27
    SOUND Snd_3f_580a ; id $28
    SOUND Snd_3f_581b ; id $29
    SOUND Snd_3f_5ca3 ; id $2a
    SOUND Snd_3f_60bf ; id $2b
    SOUND Snd_3f_660d ; id $2c
    SOUND Snd_3f_6a2f ; id $2d
    SOUND Snd_3f_6eb6 ; id $2e
END_SOUND_TABLE
