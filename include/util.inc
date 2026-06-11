IF !DEF(UTIL_INC)
DEF UTIL_INC EQU 1

INCLUDE "hardware.inc"
INCLUDE "structs.inc"

DEF CUR_BANK_TAG EQU $7fff

; Perform a call to another bank using CallBankedHL
; \1 Address
MACRO FAR_CALL
    ld a, BANK(\1)
    ld hl, \1
    call CallBankedHL
ENDM

; Draw a metasprite using DrawMetasprite
; \1	Address of metasprite
; \2	X offset
; \3	Y offset
MACRO DRAW_METASPRITE
	ld a, BANK(\1)
	ld [wDrawBank], a
	ld hl, \1
	ld bc, (\2 << 8) | \3
	call DrawMetasprite
ENDM

; A {bank, addr LE16} far-pointer record for a banked dispatch table (the consumer
; reads the bank into the bank-select register, then jp/call the address). The bank
; is derived from the target via BANK(); the optional offset addresses a point inside
; the target (a mid-routine resume entry).
; \1 Target label   \2 (optional) byte offset into Target
MACRO farptr
    db BANK(\1)
IF _NARG > 1
    dw \1 + (\2)
ELSE
    dw \1
ENDC
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

; Include a binary asset and add a label for length computation.
; \1	Name of asset
; \2	Path to asset
MACRO ASSET
\1:
	INCBIN \2
\1End:

	; DEF LEN__\1 EQU (\1End - \1)
ENDM

struct MapAsset
	bytes 1, Height
	bytes 1, Width
	words 1, Attrs
	words 1, Indexes
end_struct

MACRO MAP_ASSET
	dstruct MapAsset, \#
ENDM

DEF TILEDATA0 EQU $8000
DEF TILEDATA1 EQU $9000

FOR Y,32
	FOR X,32
		DEF TILEMAP0_X{d:X}_Y{d:Y} EQU (TILEMAP0 + Y * 32 + X)
	ENDR
ENDR

ENDC
