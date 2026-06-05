IF !DEF(UTIL_INC)
DEF UTIL_INC EQU 1

; Perform a call to another bank using CallBankedHL
; \1 Bank
; \2 Address
MACRO FAR_CALL
    ld a, \1
    ld hl, \2
    call CallBankedHL
ENDM

ENDC
