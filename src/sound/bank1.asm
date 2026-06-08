; Song/SFX data for sound driver bank $3e (ids $2f-$3a) -- SOUND_BANK_1.
; The $4b00 pointer table + one INCLUDE per song (address order).
INCLUDE "hardware.inc"      ; APU registers used by the shared driver
INCLUDE "sound.inc"

SECTION "Sound bank 1", ROMX

SOUND_DRIVER SOUND_BANK_1

SOUND_TABLE
	SOUND Snd_BGM_Town ; id $2f
    SOUND Snd_BGM_Bodka ; id $30
    SOUND Snd_BGM_RoomTransition ; id $31
    SOUND Snd_BGM_Pashute ; id $32
    SOUND Snd_BGM_Verde ; id $33
    SOUND Snd_BGM_Toamuna ; id $34
    SOUND Snd_BGM_DiscRegen ; id $35
    SOUND Snd_BGM_RivalEncounter ; id $36
    SOUND Snd_BGM_Title ; id $37
    SOUND Snd_BGM_Intro ; id $38
    SOUND Snd_BGM_39 ; id $39
    SOUND Snd_BGM_3a ; id $3a
END_SOUND_TABLE
