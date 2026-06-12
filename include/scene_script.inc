; Macros for the bank-$05 scene-script bytecode — the engine that plays the
; intro / story cutscenes. See docs/screen_tilemaps.md for the full write-up.
;
; Each scene is selected by wSceneState ($CF40, low 7 bits) and runs TWO parallel
; bytecode tracks, kicked off by Func_05_44d8 from per-state root tables:
;   - the BG track   (VM1, interpreter Func_05_4103) — root table $05:$461A[state*2]
;   - the sprite track(VM2, interpreter Func_05_4202) — root table $05:$462A[state*2]
; The two tracks share opcode bytes but mean different things, so they get
; distinct macro families: SCENE_BG_* (VM1) and SCENE_SPR_* (VM2).
;
; Both interpreters read a 1-byte opcode at the script pointer; any byte not in
; the table ends the track (handlers Func_05_4128 / the wSceneState bit7 set) —
; the scripts use $FE as that explicit terminator, exposed as *_END below.

    IF !DEF(SCENE_SCRIPT_INC)
DEF SCENE_SCRIPT_INC EQU 1

; SCENE_SPRITE_LIST def0, def1, ... : a metasprite-show list -- 2-byte def
; pointers terminated by $0000, as read by Func_05_44c7. Each arg is a
; <Mon>SpriteNN record label (the defs are labelled records in the summon files).
MACRO SCENE_SPRITE_LIST
    REPT _NARG
        dw (\1)
        SHIFT
    ENDR
    dw $0000
ENDM

; ===========================================================================
; VM1 — background / tilemap track (Func_05_4103)
;   state: script ptr $CF41/$CF42, frame-delay $CF45
; ===========================================================================

; Draw BG tilemap descriptor `descptr` (a CopyBgMap screen, in the bank the scene
; mapped) at VRAM offset `dest` (added to $9800/$9A00 by Func_05_4349), then wait
; `delay` frames before the next command. descptr=0 ⇒ draw nothing, just wait.
; ($00 — 6 bytes)
MACRO SCENE_BG_DRAW   ; delay, dest, descptr
    db $00, \1
    dw \2, \3
ENDM

; Play sound id (PlaySound). ($01 — 2 bytes)
MACRO SCENE_BG_SOUND  ; id
    db $01, \1
ENDM

; Swap the draw buffer between the $9800 and $9A00 BG maps (Func_05_43B1/4338).
; ($02 — 1 byte)
MACRO SCENE_BG_FLIP
    db $02
ENDM

; Draw a horizontal run of `count` tiles from `src`, starting at column `start`,
; waiting `delay` frames (Func_05_43DB). ($03 — 6 bytes)
MACRO SCENE_BG_ROW    ; delay, src, start, count
    db $03, \1
    dw \2
    db \3, \4
ENDM

; Far-call Z80 routine {bank,addr} mid-scene (Func_00_0495). ($FA — 4 bytes)
MACRO SCENE_BG_FARCALL ; bank, addr
    db $FA, \1
    dw \2
ENDM

; Set the per-frame scroll speed added to SCY while wobble is on ($CF61).
; ($FB — 2 bytes)
MACRO SCENE_BG_SCROLL ; speed
    db $FB, \1
ENDM

MACRO SCENE_BG_WOBBLE_OFF   ; $FC — 1 byte (disable scroll wobble)
    db $FC
ENDM

MACRO SCENE_BG_WOBBLE_ON    ; $FD — 1 byte (enable scroll wobble)
    db $FD
ENDM

MACRO SCENE_BG_END          ; $FE — 1 byte (terminate the BG track)
    db $FE
ENDM

; ===========================================================================
; VM2 — sprite / animation track (Func_05_4202)
;   state: script ptr $CF4B/$CF4C, frame-delay $CF4F
; ===========================================================================

; Show the metasprite list at `list` at position (x,y), holding for `dur` frames
; ($CF4F; $FF = hold indefinitely). Drawn each frame by Func_05_449A. ($00 — 6 bytes)
MACRO SCENE_SPR_SHOW  ; dur, x, y, list
    db $00, \1, \2, \3
    dw \4
ENDM

; Play sound id. ($01 — 2 bytes)
MACRO SCENE_SPR_SOUND ; id
    db $01, \1
ENDM

; Animate a run of `count` metasprites from list `src` (start index `start`),
; holding `dur` frames (Func_05_440C, sibling of the BG track's ROW). ($03 — 6 bytes)
MACRO SCENE_SPR_ANIM  ; dur, src, start, count
    db $03, \1
    dw \2
    db \3, \4
ENDM

; Jump the sprite track to `target` (same-bank goto; sets $CF4B/$CF4C). ($04 — 3 bytes)
MACRO SCENE_SPR_JUMP  ; target
    db $04
    dw \1
ENDM

MACRO SCENE_SPR_LOOP_ON     ; $05 — 1 byte (mark loop point / enable every-other-frame)
    db $05
ENDM

MACRO SCENE_SPR_LOOP_OFF    ; $06 — 1 byte
    db $06
ENDM

; Move/scroll: 8 params into $CF50,$CF51,$CF53..$CF56,$CF4D,$CF4E (Func_05_42CD).
; Steps toward a target position over frames; advances on STEP. ($07 — 9 bytes)
MACRO SCENE_SPR_MOVE  ; p1,p2,p3,p4,p5,p6,p7,p8
    db $07, \1, \2, \3, \4, \5, \6, \7, \8
ENDM

MACRO SCENE_SPR_STEP        ; $08 — 1 byte (advance the MOVE until target reached)
    db $08
ENDM

; Far-call Z80 routine {bank,addr} from the sprite track (Func_00_0495). ($FA — 4 bytes)
MACRO SCENE_SPR_FARCALL ; bank, addr
    db $FA, \1
    dw \2
ENDM

MACRO SCENE_SPR_END         ; $FE — 1 byte (terminate the sprite track)
    db $FE
ENDM

    ENDC ; SCENE_SCRIPT_INC
