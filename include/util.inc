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

; Encode a 4-byte BCD value.
; \1	value to encode
MACRO BCD4
	BCDN 4, \1
ENDM

; Encode a n-byte BCD value.
; \1	number of bytes to encode
; \2	value to encode
MACRO BCDN
	ASSERT \2 >= 0
	ASSERT \2 <= ((100 ** \1) - 1)
	FOR I,\1
		BCD1 ((\2 / (100 ** (\1 - 1 - I))) % 100)
	ENDR
ENDM

; Encode a 1-byte BCD value.
; \1	value to encode
MACRO BCD1
	ASSERT \1 >= 0
	ASSERT \1 <= 99
	DB ((\1 / 10) << 4) | (\1 % 10)
ENDM

ENDC
