; WRAM variable declarations for Monster Rancher Explorer.
;
; Each variable is a real RGBASM label (`::` exports them across the
; whole compilation unit) declared via `ds N` inside a `WRAM0` SECTION.
; The linker assigns the address, and anywhere in the .asm tree we can
; refer to the byte by name — `SCRIPT_WRITE_WRAM wNajiState, $01`
; assembles to the same `$09 $DD $D0 $01` as the raw form, but reads
; meaningfully.
;
; Variables we haven't fully identified yet are still listed (with
; `wXXXX::` placeholder names) where we know they're touched by code
; we've decoded — that way the gaps don't break neighbouring labels
; once we figure out what they're for.
;
; See docs/text_engine.md for the script-engine variables ($D5FE,
; $D5FF, $D600, $D60D, $D614-$D622, $CFF0, $CFF2).

    IF !DEF(WRAM_INC)
DEF WRAM_INC EQU 1


SECTION "wram_floor", WRAM0[$C2C0]

wActiveFloor::      ds 1    ; $C2C0: active tower floor (1-60). Copied from wCFF0 and
                            ;   capped at $3C(=60). Indexes per-floor tables — tile-gfx
                            ;   pointers at $3D:$406F/$4079/$4083 — and drives the HUD
                            ;   floor digits ($0F:$47A2, split via ÷10). Distinct from
                            ;   wCurrentFloor ($CFF2) and the source wCFF0.


SECTION "wram_story_flags", WRAM0[$C2D7]
; (story flags are in the always-mapped $C000-$CFFF region)

wC2D7::             ds 1    ; story flag read by Naji's entry cascade


SECTION "wram_floor_grid", WRAM0[$C2EC]
; The active floor's layout, expanded from its per-floor record by LoadFloorData
; ($00:$16EA) — selected via FloorBankTable ($1567) + FloorPtrTable ($15BF). The
; record's header gives width/height; two parallel 17-wide grids follow.

wFloorWidth::       ds 1    ; $C2EC: floor width in cells (<= 17)
wFloorHeight::      ds 1    ; $C2ED: floor height in cells (<= 14)
wFloorRowStride::   ds 1    ; $C2EE: $11 - width (grid rows are 17 cells apart)
wFloorCollision::   ds 238  ; $C2EF: 17x14 collision/attribute grid
wFloorGrid::        ds 238  ; $C3DD: 17x14 piece-ID grid (the floor layout; rendered
                            ;   via DrawFloorPiece + FloorPieceDefs at $12FA)


SECTION "wram_floor_state", WRAM0[$CFF0]

wCFF0::             ds 1    ; tower progress; gates Naji's Restart + Ask render
                    ds 1    ; $CFF1
wCurrentFloor::     ds 1    ; current tower floor — rendered by $0F in "Level [X]"


SECTION "wram_npc_state", WRAMX[$D0DC], BANK[1]

wRanchProgress::    ds 1    ; $D0DC: Toamuna's cascade — 0/1/2/3/4 = first/cyclic/Pashute/Verde/AllBack
wNajiState::        ds 1    ; $D0DD: 0/1/2/4 = first / greeted / progress / end-game
wPashuteState::     ds 1    ; $D0DE: Pashute's NPC cascade (0/2/3/4, mirrors the other NPC states)
wTowerExplained::   ds 1    ; $D0DF: set by NajiAskTower (Tower-explanation given)
                    ds 2    ; $D0E0-$D0E1
wNajiMenuShown::    ds 1    ; $D0E2: Naji's "menu already rendered" gate (uncertain)
wTradehouseState::  ds 1    ; $D0E3: empty-tradehouse cascade
wVerdeState::       ds 1    ; $D0E4: Verde's NPC cascade


SECTION "wram_menu_results", WRAMX[$D5FB], BANK[1]

wBcdLow::           ds 1    ; $D5FB: $0F's low-digit BCD output
wBcdHigh::          ds 1    ; $D5FC: $0F's high-digit BCD output
                    ds 1    ; $D5FD
wYNResult::         ds 1    ; $D5FE: 0=Yes / 1=No (also: save-exists flag from bank-25 $4018)
wMainMenuResult::   ds 1    ; $D5FF: main-menu dispatch index


SECTION "wram_submenu", WRAMX[$D600], BANK[1]

wSubMenuCursor::    ds 1    ; $D600: submenu cursor (Pashute uses this for his main menu too)


SECTION "wram_cycle", WRAMX[$D60D], BANK[1]

wCycleCounter::     ds 1    ; $D60D: $0C opcode advances this mod N for cyclic dispatch

SECTION "boss_state", WRAMX[$D60F], BANK[1]
wBossState::        ds 1    ; $D60F: Boss victory/defeat state, used to conditionally display text

SECTION "wram_text_engine", WRAMX[$D614], BANK[1]

wTextAnchor::       ds 2    ; $D614/$D615: $01 opcode's tilemap-position anchor
wTextCursor::       ds 2    ; $D616/$D617: live render cursor (mirrored from anchor by $01/$02)
wTextWidth::        ds 1    ; $D618: textbox width
wTextHeight::       ds 1    ; $D619: textbox height
                    ds 4    ; $D61A-$D61D
wRendererAddr::     ds 2    ; $D61E/$D61F: text-renderer routine address (set by $0E)
wRendererBank::     ds 1    ; $D620: text-renderer bank (set by $0E)
wTextStateV2::      ds 2    ; $D621/$D622: $05 opcode's BC target

    ENDC ; WRAM_INC
