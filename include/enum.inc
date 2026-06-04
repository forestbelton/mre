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
; respectively, plus `countof_Item` = 3 (the number of values). `enum_table`
; (below) builds a lookup table keyed by an enum's values.

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
	; Record the value count (max value + 1) so `enum_table` can iterate the
	; enum and check a table covers every value.
	def countof_{ENUM_NAME} equ ENUM_DISCRIMINANT
	purge ENUM_NAME, ENUM_DISCRIMINANT
endm

; Builds a lookup table keyed by an enum's values.
;
;   enum_table EnumName[, ElemType], .Case=Value, ...
;
; Emits one element per enum value, in value order (0..N-1), regardless of the
; order the `.Case=Value` pairs are written -- so the table can't silently drift
; out of sync with the enum. Every enum value must be given exactly once; a
; missing, duplicate, or unknown case is a build error. The leading `.` on each
; key is optional sugar; `Case` names an enum member (`EnumName_Case`). Values
; may be any expression (they are parenthesised before emission).
;
; `ElemType` is `byte`, `word`, or `long`; when omitted (empty) it defaults to
; the enum's own discriminant type. The named-initializer syntax deliberately
; mirrors structs.inc's `dstruct`.
;
;   enum Move
;     case Walk
;     case Run
;     case Jump
;   end_enum
;
;   MoveHandlers::
;       enum_table Move, word, \
;           .Walk = DoWalk, \
;           .Run  = DoRun, \
;           .Jump = DoJump      ; -> dw DoWalk / dw DoRun / dw DoJump
;
macro enum_table ; EnumName, ElemType, .Case=Value...
	def _ET_ENUM equs "\1"
	if !def(countof_{_ET_ENUM})
		fail "enum_table: `\1` is not a defined enum"
	endc

	; element storage directive: explicit ElemType, else the enum's own type
	def _ET_DIR equs "d{typeof_{_ET_ENUM}}"
	if _NARG >= 2 && STRLEN("\2")
		if !STRCMP("\2", "byte")
			redef _ET_DIR equs "db"
		elif !STRCMP("\2", "word")
			redef _ET_DIR equs "dw"
		elif !STRCMP("\2", "long")
			redef _ET_DIR equs "dl"
		else
			fail "enum_table \1: ElemType must be byte/word/long, got `\2`"
		endc
	endc

	; parse each `.Case=Value` into a slot indexed by the case's enum value
	for _ET_i, 3, _NARG + 1
		def _ET_ARG equs "\<_ET_i>"
		def _ET_EQ = STRFIND("{_ET_ARG}", "=")
		if _ET_EQ == -1
			fail "enum_table \1: arg #{d:_ET_i} `{_ET_ARG}` is not Case=Value"
		endc
		def _ET_KEY equs STRSLICE("{_ET_ARG}", 0, _ET_EQ)
		if !STRCMP(STRSLICE("{_ET_KEY}", 0, 1), ".")   ; drop optional leading '.'
			redef _ET_KEY equs STRSLICE("{_ET_KEY}", 1)
		endc
		if !def({_ET_ENUM}_{_ET_KEY})
			fail "enum_table \1: `\1_{_ET_KEY}` is not a case of `\1`"
		endc
		def _ET_D = {_ET_ENUM}_{_ET_KEY}
		if def(_ET_slot{d:_ET_D})
			fail "enum_table \1: duplicate value for `\1_{_ET_KEY}`"
		endc
		def _ET_slot{d:_ET_D} equs STRCAT("(", STRSLICE("{_ET_ARG}", _ET_EQ + 1), ")")
		purge _ET_ARG, _ET_EQ, _ET_KEY, _ET_D
	endr

	; emit one element per enum value, in order
	for _ET_i, 0, countof_{_ET_ENUM}
		if !def(_ET_slot{d:_ET_i})
			fail "enum_table \1: no value given for enum value #{d:_ET_i}"
		endc
		{_ET_DIR} {_ET_slot{d:_ET_i}}
		purge _ET_slot{d:_ET_i}
	endr

	purge _ET_ENUM, _ET_DIR
endm

ENDC ; ENUM_INC
