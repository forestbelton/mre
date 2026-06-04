IF !DEF(HRAM_INC)
DEF HRAM_INC EQU 1

SECTION "HRAM joypad", HRAM[$ff8d]
hJoyHeld:: ds 1

; CGB palette upload state, one per layer (see docs/palettes.md). $FF = clean;
; any other value = dirty -> FlushDirtyPalettes streams the WRAM shadow buffer
; (wBgPalettes / wObjPalettes) to the hardware palette in VBlank and marks it
; clean again. $09 keeps it dirty (re-uploads every frame).
SECTION "HRAM palette flags", HRAM[$ffa1]
hBgPaletteDirty:: ds 1
hObjPaletteDirty:: ds 1

ENDC
