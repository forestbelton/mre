IF !DEF(HRAM_INC)
DEF HRAM_INC EQU 1

; Joypad state, refreshed once per frame by ReadJoypad ($00:$0252). `hJoyHeld` is
; the raw down-state; `hJoyPressed` is the rising edge ((prev^cur)&cur); `hJoyRepeat`
; is the menu auto-repeat pulse -- on a fresh press it mirrors the press, then with
; the button held it re-fires every few frames, and is 0 in between (the cadence is
; counted down in `hJoyRepeatTimer`: $1e-frame initial delay, then $05-frame repeat).
SECTION "HRAM joypad", HRAM[$ff8b]
hJoyHeld::        ds 1  ; $ff8b  buttons currently held down this frame
hJoyPressed::     ds 1  ; $ff8c  buttons newly pressed this frame (rising edge)
hJoyRepeat::      ds 1  ; $ff8d  press + auto-repeat pulse (for menu navigation; 0 between repeats)
hJoyRepeatTimer:: ds 1  ; $ff8e  auto-repeat countdown ($1e initial delay, $05 repeat rate)

; CGB palette upload state, one per layer (see docs/palettes.md). $FF = clean;
; any other value = dirty -> FlushDirtyPalettes streams the WRAM shadow buffer
; (wBgPalettes / wObjPalettes) to the hardware palette in VBlank and marks it
; clean again. $09 keeps it dirty (re-uploads every frame).
SECTION "HRAM palette flags", HRAM[$ffa1]
hBgPaletteDirty:: ds 1
hObjPaletteDirty:: ds 1

; --- Current-entity working shadow (the room/entity engine) ------------------
; RunEntity ($03:$4037) copies the active 42-byte entity record into this block
; (LoadEntityRegs, $03:$4308), the bytecode VM + locomotion/collision code work
; on it in place, and SaveEntityRegs ($03:$438d) writes it back to WRAM. The
; whole region $ffb0-$ffe6 belongs to this one subsystem (banks $01/$03/$04 +
; the layout spawns) -- nothing else touches it. Only fields whose meaning is
; confirmed are named here; undecoded bytes stay as raw `ds` gaps so the named
; offsets can't drift. See docs/room_engine.md ("Entity record / HRAM-shadow
; layout") and docs/entity_scripts.md.
SECTION "HRAM entity shadow", HRAM[$ffb0]
hEntityState::       ds 1  ; $ffb0  occupied / state-id flag (0 = empty slot)
hEntityUpdate2::     ds 1  ; $ffb1  secondary-update enable (nonzero -> call $04:$4000)
                     ds 1  ; $ffb2  (bank-$04 anim scratch; purpose TBD)
hEntityType::        ds 1  ; $ffb3  entity type id (set by opcode $01 ent_set_type)
hEntityStatus::      ds 1  ; $ffb4  status bits (bit7 = acting/cooldown gate)
hEntityAnimState::   ds 1  ; $ffb5  animation sub-state (&3 selects facing variant)
hEntityFacing::      ds 1  ; $ffb6  facing/flags (bit7 X-flip, bits0-1 4-dir, bit3 active)
hEntityMoveResult::  ds 1  ; $ffb7  move/collision result bits (tested by branch opcodes $21-$24)
hEntityResult::      ds 1  ; $ffb8  behaviour-selector result code (the script "b8" register)
                     ds 2  ; $ffb9-$ffba
hEntityXSub::        ds 1  ; $ffbb  X position, subpixel (fractional)
hEntityX::           ds 1  ; $ffbc  X position, pixel
hEntityYSub::        ds 1  ; $ffbd  Y position, subpixel (fractional)
hEntityY::           ds 1  ; $ffbe  Y position, pixel
hEntityVelXLo::      ds 1  ; $ffbf  X velocity, low byte (signed 16-bit, little-endian)
hEntityVelXHi::      ds 1  ; $ffc0  X velocity, high byte
hEntityVelYLo::      ds 1  ; $ffc1  Y velocity, low byte (signed 16-bit, little-endian)
hEntityVelYHi::      ds 1  ; $ffc2  Y velocity, high byte
                     ds 2  ; $ffc3-$ffc4  (16-bit timer per docs; unverified)
                     ds 1  ; $ffc5
hEntityTimer::       ds 1  ; $ffc6  per-entity script timer (opcodes $08/$0a/$0b/$25/$26)
hEntityActionTimer:: ds 1  ; $ffc7  action/attack cooldown timer (opcode $0f sets $14)
hEntityScriptPtrLo:: ds 1  ; $ffc8  script PC low byte (de in RunEntityScript)
hEntityScriptPtrHi:: ds 1  ; $ffc9  script PC high byte
                     ds 6  ; $ffca-$ffcf  (bank-$04 anim scratch; purpose TBD)
                     ds 1  ; $ffd0  (bit7-gated flag; OAM attr? unverified)
hEntityAnimSel::     ds 1  ; $ffd1  low 3 bits index per-type velocity/anim tables (opcode $04)
hEntityProbeX::      ds 1  ; $ffd2  collision-probe box: X offset ahead of entity
hEntityProbeY::      ds 1  ; $ffd3  collision-probe box: Y offset
hEntityProbeW::      ds 1  ; $ffd4  collision-probe box: X extent
hEntityProbeH::      ds 1  ; $ffd5  collision-probe box: Y extent
                     ds 4  ; $ffd6-$ffd9  (entity record +$26..+$29; purpose TBD)
; Entity-vs-entity AABB overlap scratch: two boxes built from entity positions
; (each {X, Y, W, H}), tested by Func_00_0fb0, which writes the signed per-axis
; penetration to hOverlapX/Y and returns a=1 when the boxes overlap.
hHitbox1X::          ds 1  ; $ffda  box 1 X (left edge; e.g. wPlayerX + box offset)
hHitbox1Y::          ds 1  ; $ffdb  box 1 Y (top edge)
hHitbox1W::          ds 1  ; $ffdc  box 1 width
hHitbox1H::          ds 1  ; $ffdd  box 1 height
hHitbox2X::          ds 1  ; $ffde  box 2 X
hHitbox2Y::          ds 1  ; $ffdf  box 2 Y
hHitbox2W::          ds 1  ; $ffe0  box 2 width
hHitbox2H::          ds 1  ; $ffe1  box 2 height
hOverlapX::          ds 1  ; $ffe2  signed X penetration depth (Func_00_0fb0 output)
hOverlapY::          ds 1  ; $ffe3  signed Y penetration depth
                     ds 1  ; $ffe4  (current-entity classification byte; TBD)
hEntityPtrLo::       ds 1  ; $ffe5  current-entity record WRAM pointer, low byte
hEntityPtrHi::       ds 1  ; $ffe6  current-entity record WRAM pointer, high byte

ENDC
