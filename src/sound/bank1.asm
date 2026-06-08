; Song/SFX data for sound driver bank $3e (ids $2f-$3a) -- SOUND_BANK_1.
; The $4b00 pointer table + one INCLUDE per song (address order).
INCLUDE "hardware.inc"      ; APU registers used by the shared driver
INCLUDE "sound.inc"

SECTION "Sound bank 1", ROMX

SOUND_DRIVER SOUND_BANK_1

SOUND_TABLE
	SOUND Snd_3e_4d00 ; id $2f
    SOUND Snd_3e_516f ; id $30
    SOUND Snd_3e_559d ; id $31
    SOUND Snd_3e_570a ; id $32
    SOUND Snd_3e_5a30 ; id $33
    SOUND Snd_3e_5cb6 ; id $34
    SOUND Snd_3e_5ef9 ; id $35
    SOUND Snd_3e_62fa ; id $36
    SOUND Snd_3e_646a ; id $37
    SOUND Snd_3e_664d ; id $38
    SOUND Snd_3e_6b85 ; id $39
    SOUND Snd_3e_6f12 ; id $3a
END_SOUND_TABLE
