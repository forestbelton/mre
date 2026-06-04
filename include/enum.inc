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

; Used to skip values if the enum is not contiguous. The skipped value is marked
; so `enum_table` can fill its (nameless) slot via the `*` fill.
macro skip
    def _enum_skipped_{ENUM_NAME}_{d:ENUM_DISCRIMINANT} equ 1
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
; out of sync with the enum. Every named case must be given exactly once; a
; missing, duplicate, or unknown case is a build error. The leading `.` on each
; key is optional sugar; `Case` names an enum member (`EnumName_Case`). Values
; may be any expression (they are parenthesised before emission).
;
; `skip`ped enum values have no name, so they can't be addressed by key; instead
; a `*=Value` entry supplies the fill for every skipped slot (required if the
; enum has any). `*` fills ONLY skipped slots -- a forgotten *named* case is
; still an error, so the coverage check is preserved.
;
; `ElemType` chooses how each value is emitted: `byte`/`word`/`long` (-> db/dw/
; dl), or the name of any directive or macro that takes one value and emits that
; entry's bytes -- e.g. `BCD4` for a table of 4-byte BCD values. When omitted
; (empty) it defaults to the enum's own discriminant type. The named-initializer
; syntax deliberately mirrors structs.inc's `dstruct`.
;
;   enum Move
;     case Walk
;     skip            ; value 1 reserved / unused
;     case Run
;   end_enum
;
;   MoveHandlers::
;       enum_table Move, word, \
;           *     = NoMove, \   ; fills the skipped slot
;           .Walk = DoWalk, \
;           .Run  = DoRun       ; -> dw DoWalk / dw NoMove / dw DoRun
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
			redef _ET_DIR equs "\2"   ; any other token: a directive/macro emitter
		endc
	endc

	; parse each `.Case=Value` (and the optional `*=Fill`) into slot vars
	for _ET_i, 3, _NARG + 1
		def _ET_ARG equs "\<_ET_i>"
		def _ET_EQ = STRFIND("{_ET_ARG}", "=")
		if _ET_EQ == -1
			fail "enum_table \1: arg #{d:_ET_i} `{_ET_ARG}` is not Case=Value"
		endc
		; split into key/value and strip all whitespace (so `.A = $12`, `* = Fill`,
		; and line-continued entries all parse the same as `.A=$12`)
		def _ET_KEY equs STRSLICE("{_ET_ARG}", 0, _ET_EQ)
		def _ET_VAL equs STRSLICE("{_ET_ARG}", _ET_EQ + 1)
		redef _ET_KEY equs STRRPL(STRRPL("{_ET_KEY}", " ", ""), "\t", "")
		redef _ET_VAL equs STRRPL(STRRPL("{_ET_VAL}", " ", ""), "\t", "")
		if !STRCMP(STRSLICE("{_ET_KEY}", 0, 1), ".")   ; drop optional leading '.'
			redef _ET_KEY equs STRSLICE("{_ET_KEY}", 1)
		endc
		if !STRCMP("{_ET_KEY}", "*")                    ; `*=Fill` for skipped slots
			if def(_ET_FILL)
				fail "enum_table \1: duplicate `*` fill"
			endc
			def _ET_FILL equs "({_ET_VAL})"
		else
			if !def({_ET_ENUM}_{_ET_KEY})
				fail "enum_table \1: `\1_{_ET_KEY}` is not a case of `\1`"
			endc
			def _ET_D = {_ET_ENUM}_{_ET_KEY}
			if def(_ET_slot{d:_ET_D})
				fail "enum_table \1: duplicate value for `\1_{_ET_KEY}`"
			endc
			def _ET_slot{d:_ET_D} equs "({_ET_VAL})"
			purge _ET_D
		endc
		purge _ET_ARG, _ET_EQ, _ET_KEY, _ET_VAL
	endr

	; emit one element per enum value, in order; skipped slots take the `*` fill
	for _ET_i, 0, countof_{_ET_ENUM}
		if def(_ET_slot{d:_ET_i})
			{_ET_DIR} {_ET_slot{d:_ET_i}}
			purge _ET_slot{d:_ET_i}
		elif def(_enum_skipped_{_ET_ENUM}_{d:_ET_i})
			if !def(_ET_FILL)
				fail "enum_table \1: value #{d:_ET_i} was `skip`ped; pass `*=<fill>` to fill skipped slots"
			endc
			{_ET_DIR} {_ET_FILL}
		else
			fail "enum_table \1: no value given for case at value #{d:_ET_i}"
		endc
	endr

	if def(_ET_FILL)
		purge _ET_FILL
	endc
	purge _ET_ENUM, _ET_DIR
endm

ENDC ; ENUM_INC
