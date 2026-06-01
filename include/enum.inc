; Adapted from ISSOtm's PR against the `rgbds-structs` repository,
; available here: https://codeberg.org/ISSOtm/rgbds-structs/pulls/22
;
; Example usage:
;
; enum Item
;   case Foo
;   case Bar
;   case Baz
; end_enum
;
IF !DEF(ENUM_INC)
DEF ENUM_INC EQU 1

; This defines Item_Foo, Item_Bar, Item_Baz and sets them to 0, 1, and 2
; respectively.

; Defines an enum from a list of `case`s.
;
; `Type` is an optional argument that determines what storage to use for enum
; discriminants.
; Valid values for this argument are: `byte`, `word`, `long`.
; When absent, it defaults to `byte`.
macro enum ; Name, [Type]
	def ENUM_NAME equs "\1"
	if _NARG > 1
	    if !STRCMP("\2", "byte")
	        def typeof_{ENUM_NAME} equs "b"
	    elif !STRCMP("\2", "word")
	        def typeof_{ENUM_NAME} equs "w"
	    elif !STRCMP("\2", "long")
	        def typeof_{ENUM_NAME} equs "l"
	    else
	        FAIL "Unrecognized discriminant type: \2"
	    endc
	else
	    def typeof_{ENUM_NAME} equs "b"
	endc
	; We can't use RB because it'll be clobbered by `struct`
	def ENUM_DISCRIMINANT = 0
endm

macro case ; Name
	def {ENUM_NAME}_\1 equ ENUM_DISCRIMINANT
	def ENUM_DISCRIMINANT += 1
endm

; Used to skip values if the enum is not contiguous.
macro skip
    def ENUM_DISCRIMINANT += 1
endm

macro end_enum
	purge ENUM_NAME, ENUM_DISCRIMINANT
endm

ENDC ; ENUM_INC
