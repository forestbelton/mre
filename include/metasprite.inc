; Metasprite data macros -- turn raw `db` OBJ-list blobs into structured, labelled
; source so DrawMetasprite lists read as records and code can reference into them by
; label (a metasprite list is a 1-byte count + N {Yoff,Xoff,tile,attr} records; see
; docs/metasprites.md).
;
; Usage:
;     metasprite SomeName        ; emits SomeName: (the count byte) + SomeName.objs:
;         obj  $f8, $f8, $80, $00
;     .face:                     ; an ordinary local label -> SomeName.face, usable as
;         obj  $00, $f8, $82, $05 ;   a mid-list reference target
;     end_metasprite SomeName    ; emits SomeName.end: and back-fills the count
;
; The count is derived from the record block (SomeName.end - SomeName.objs), so it can
; never disagree with the records.

IF !DEF(METASPRITE_INC)
DEF METASPRITE_INC EQU 1

    IF !DEF(STRUCTS_VERSION)
INCLUDE "structs.inc"
    ENDC

; One OBJ record (a single hardware sprite within a metasprite).
struct MetaspriteObj
    bytes 1, Y       ; Y offset from the metasprite's base position (signed)
    bytes 1, X       ; X offset (signed)
    bytes 1, Tile    ; OAM tile index (8x16 OBJ mode -> even)
    bytes 1, Attr    ; OAM attribute (pal 0-2, bank 3, xflip 5, yflip 6, prio 7)
end_struct

; Open a metasprite list: defines <Name> (the count byte) and <Name>.objs (first
; record). Records follow via `obj`; close with `end_metasprite <Name>`.
MACRO metasprite ; <Name>
\1::
    db (\1.end - \1.objs) / sizeof_MetaspriteObj
\1.objs::
ENDM

; One record: obj Yoff, Xoff, Tile, Attr
MACRO obj
    db \1, \2, \3, \4
ENDM

; Close a metasprite list (marks the end used by the count).
MACRO end_metasprite ; <Name>
\1.end::
ENDM

ENDC
