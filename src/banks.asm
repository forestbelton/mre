; Bank-number tags. Every 16 KiB bank ends with a byte equal to its own bank
; number ($7fff for ROMX banks) -- a common integrity/identity convention.

; Banks $01..$3f (ROMX, tag at $7fff)
MACRO BANK_TAG
    SECTION "Bank tag ${02X:\1}", ROMX[$7fff], BANK[\1]

BANK_TAG_{02X:\1}:
    DB \1
ENDM

FOR N, 1, $40
    BANK_TAG N
ENDR
