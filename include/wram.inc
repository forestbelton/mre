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


; CGB palette shadow buffers, flushed to the hardware palette registers in VBlank
; (FlushBgPalettes / FlushObjPalettes, gated by hBgPaletteDirty / hObjPaletteDirty).
; 8 palettes each, 4 little-endian RGB555 colors per palette. See docs/palettes.md.
SECTION "wram_draw_bank", WRAM0[$C100]
wDrawBank::    ds 1     ; $C100: ROM bank holding the graphics/metasprite data to render.
                        ;   Callers set it to their data bank (banks $02-$35 seen) right
                        ;   before a DrawMetasprite-family call, which banks it into the
                        ;   $2FFF ROM-select register to fetch the sprite/tile data. The
                        ;   real execution bank is saved/restored separately via $7FFF
                        ;   (each ROMX bank's last byte holds its own index).

SECTION "wram_palettes", WRAM0[$C101]
wBgPalettes::  ds $40   ; $C101: BG palettes 0-7 (loaded by LoadBgPalettes / LoadBgPalette)
wObjPalettes:: ds $40   ; $C141: OBJ palettes 0-7 (loaded by LoadObjPalettes / LoadObjPalette)

; Monster portrait subsystem pointers, set by LoadMonsterPortrait from the
; $0f:$4C4B record for wDisplayMonster. The portrait is BG body + sprite detail
; over per-monster bank-$3c tiles. See docs/monster_detail_screen.md.
SECTION "wram_monster_portrait", WRAM0[$CF34]
wMonsterMeta1Ptr:: ds 2  ; $CF34: portrait metasprite 1 (drawn by DrawMonster*Sprites)
wMonsterMeta2Ptr:: ds 2  ; $CF36: portrait metasprite 2 (overlay; 0 if none)
wMonsterBgMapPtr:: ds 2  ; $CF38: portrait BG tilemap (CopyBgMap; drawn by DrawMonster*BgMap)

SECTION "wram_sound_vars", WRAM0[$C28C]
wCurrentSound:: ds 1 ; $C28C: ID of sound currently being played

SECTION "wram_spawn_params", WRAM0[$C29C]
; SpawnEntity argument block: the far-call trampoline (Func_00_0467) marshals these
; into AF/DE/HL before tail-calling the bank-3 spawn routine ($4593).

wSpawnType::        ds 1    ; $C29C: entity type/id to spawn (-> A)
                    ds 2    ; $C29D-$C29E
wSpawnY::           ds 1    ; $C29F: spawn Y (-> D)
wSpawnX::           ds 1    ; $C2A0: spawn X (-> E)
wSpawnPtr::         ds 2    ; $C2A1: spawn context pointer, big-endian hi/lo (-> HL)


SECTION "wram_floor", WRAM0[$C2C0]

wActiveFloor::      ds 1    ; $C2C0: active tower floor (1-60). Copied from wCFF0 and
                            ;   capped at $3C(=60). Indexes per-floor tables — tile-gfx
                            ;   pointers at $3D:$406F/$4079/$4083 — and drives the HUD
                            ;   floor digits ($0F:$47A2, split via ÷10). Distinct from
                            ;   wCurrentFloor ($CFF2) and the source wCFF0.


SECTION "wram_item_state", WRAM0[$C2C1]
; Per-run item state, manipulated by the item pickup effect handlers (src/item.asm).

wRoomType::         ds 1    ; $C2C1: room/screen mode -- 0 normal / 2 boss / 5 special
                    ds 1    ; $C2C2
wLives::            ds 1    ; $C2C3: lives, BCD (cap 99); COX_HAT +1
                    ds 2    ; $C2C4-$C2C5
wScore::            ds 5    ; $C2C6: score, 5-byte little-endian BCD (AddItemScore adds
                            ;   the item's ItemPoints value here)
wBombCapacity::     ds 1    ; $C2CB: bomb slots, max 8 (FIREPLACE +1)
wBombCount::        ds 1    ; $C2CC: held bombs
wBombLargeFlags::   ds 1    ; $C2CD: bit per held bomb -> large/piercing
wCrystalCount::     ds 2    ; $C2CE: crystal counter (BLUE_CRYSTAL +4, RED_CRYSTAL +$10)
                    ds 1    ; $C2D0
wFloorTimer::       ds 3    ; $C2D1: floor time remaining, 3-byte BCD (hourglasses/tororon)
wTimeMultiplier::   ds 1    ; $C2D4: tororon time multiplier (2 or 5)
wProgressFlags::    ds 1    ; $C2D5: bit0 normal-stair-path, bit1 exit unlocked,
                            ;   bit3 bonus-stage warp, bit7 stair/summon reveal
wTransitionState::  ds 1    ; $C2D6: room-transition sub-state (read with wRoomType)


SECTION "wram_story_flags", WRAM0[$C2D7]
; (story flags are in the always-mapped $C000-$CFFF region)

wC2D7::             ds 1    ; story flag read by Naji's entry cascade
                    ds 16   ; $C2D8-$C2E7
wHasBattleCard::    ds 1    ; $C2E8: BATTLE_CARD collected (battle available)
                    ds 3    ; $C2E9-$C2EB


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


SECTION "wram_spawn_cell", WRAM0[$C52E]
wSpawnCellX::       ds 1    ; $C52E: pickup/effect spawn target cell X
wSpawnCellY::       ds 1    ; $C52F: pickup/effect spawn target cell Y


SECTION "wram_scene", WRAM0[$CF40]
wSceneState::       ds 1    ; $CF40: bank-5 scene/sequence state machine -- low 7 bits =
                            ;   state index, bit7 = active; kicked off by special items
                    ds 61   ; $CF41-$CF7D
wToken21Count::     ds 1    ; $CF7E: collect-4 counter for token $21


SECTION "wram_monsters", WRAM0[$CFBB]
; The seven summonable partner monsters: Tiger, Mocchi, Hare, Gali, Golem, Suezo,
; Phenix (indices 0-6, the order of MONSTER_NAME_POINTERS in script.asm). Distinct
; from the 19 floor-monster species in the `enum MONSTER` (include/room.inc).

wActiveMonster::    ds 1    ; $CFBB: index (0-6) of the currently-selected partner
                            ;   monster. Indexes wMonsterUses / wMonsterDiscStones,
                            ;   the name table (ScriptPrintMonsterName), and the
                            ;   bank-$32 portrait table ($32:$40A5). Set by Pashute's
                            ;   and Verde's menus (SCRIPT_JUMP_TABLE $cfbb). Transient:
                            ;   it sits below the saved block, so it is NOT persisted.
                    ds 19   ; $CFBC-$CFCE

; --- Persistent save block ($CFCF..$D0E6, $118 bytes) ------------------------
; The game's saved state. On save (Func_12_4b67, bank $12) this block is stamped
; with the "V03" signature and copied verbatim to SRAM $A6ED; on load (Func_12_4BA1)
; it is copied back. Integrity is a one-byte XOR of every block byte (Func_00_12EE
; computes+stores it, Func_00_12E1 recomputes+verifies it), kept in the byte right
; after the block. The .sav file is the raw 8KB SRAM image, so the block lives at
; file offset $A6ED-$A000 = 0x6ED with its checksum at 0x805; the three "V03ROOM1
; /2/3" blocks earlier in the file are the level editor's saved rooms. The block
; spans several of the sections below (wCFF0, the $D0DC NPC cascade, ...).
wSaveSignature::    ds 3    ; $CFCF: "V03" save-format signature
wHiScore::          ds 4    ; $CFD2: hi-score, 4-byte BCD little-endian (max 99999999).
                            ;   e.g. bytes 55 54 53 00 read as the number 535455. (The
                            ;   low three bytes spell "UTS" in ASCII — a coincidence.)
                    ds 1    ; $CFD6
wDiscStoneFragments:: ds 1  ; $CFD7: loose disc-stone pieces held (4 pieces = 1 stone)
wFreeDiscStones::   ds 1    ; $CFD8: assembled disc stones not yet bound to a monster
wDisplayMonster::   ds 1    ; $CFD9: monster index (0-6) the portrait/detail subsystem
                            ;   renders -- LoadMonsterPortrait/LoadMonsterPalettes and the
                            ;   wMonster*Ptr pointers all derive from it. ShowMonsterDetailScreen
                            ;   temporarily sets it to wActiveMonster to preview, restoring it
                            ;   after. Lives in the saved block, so its resting value persists.
wMonsterDiscStones:: ds 7   ; $CFDA: per-monster (0-6) count of disc stones bound to
                            ;   that monster. A free disc stone (wFreeDiscStones) is
                            ;   bound by touching the monster on its bonus stage;
                            ;   Pashute's shrine spends one bound stone to regenerate
                            ;   uses (Func_18_4088 decrements it as Func_18_4074 adds
                            ;   5 to wMonsterUses).
wMonsterUses::      ds 7    ; $CFE1: per-monster (0-6) summon uses remaining, stored
                            ;   as BCD (0-99). Pashute's shrine adds 5 via `add a,$05`
                            ;   + `daa` (Func_18_4074); read through wActiveMonster
                            ;   (Func_18_403C). Tiger=$CFE1 … Suezo=$CFE6, Phenix=$CFE7.
                    ds 7    ; $CFE8-$CFEE
wSilverKeys::       ds 1    ; $CFEF: silver keys held (unlock tower doors). Identified
                            ;   by value-match (the sole "10" in the block); code
                            ;   xref still TBD.


SECTION "wram_floor_state", WRAM0[$CFF0]

wCFF0::             ds 1    ; tower progress; gates Naji's Restart + Ask render
                    ds 1    ; $CFF1
wCurrentFloor::     ds 1    ; current tower floor — rendered by $0F in "Level [X]"
wBattleCardPending:: ds 1   ; $CFF3: BATTLE_CARD pending flag (set unless wRoomType 5;
                            ;   cleared on new game). Write-only in the current disasm.
wItemsSeen::        ds 4    ; $CFF4: item-encyclopedia "seen" bitfield (up to 32 items),
                            ;   little-endian. Bit i set = item (i+1) has been seen
                            ;   (so item 1 = bit 0). Drives the encyclopedia's seen/
                            ;   unseen list.


SECTION "wram_npc_state", WRAMX[$D0DC], BANK[1]

wRanchProgress::    ds 1    ; $D0DC: Toamuna's cascade — 0/1/2/3/4 = first/cyclic/Pashute/Verde/AllBack
wNajiState::        ds 1    ; $D0DD: 0/1/2/4 = first / greeted / progress / end-game
wPashuteState::     ds 1    ; $D0DE: Pashute's NPC cascade (0/2/3/4, mirrors the other NPC states)
wTowerExplained::   ds 1    ; $D0DF: set by NajiAskTower (Tower-explanation given)
                    ds 2    ; $D0E0-$D0E1
wNajiMenuShown::    ds 1    ; $D0E2: Naji's "menu already rendered" gate (uncertain)
wTradehouseState::  ds 1    ; $D0E3: empty-tradehouse cascade
wVerdeState::       ds 1    ; $D0E4: Verde's NPC cascade


SECTION "wram_ui_loop", WRAMX[$D0E9], BANK[1]
; State + frame timer for the engine's blocking interactive UI/menu loops. The
; recurring shape (Func_00_1b29/$1b58/... and screen setups in banks $13/...) is:
; draw the screen, zero wUiTimer, set wUiState=1, then each frame
; `WaitForNextFrame -> ReadJoypad -> dispatch a per-phase handler by wUiState ->
; render`, looping while wUiState != 0 and exiting when a handler clears it. The
; phase-1 handlers read hJoyRepeat for cursor navigation. Sits just past the
; saved block ($CFCF..$D0E6), so neither byte persists.
wUiState::          ds 1    ; $D0E9: UI-loop state (0 = exit loop; 1/2 = active phase)
wUiTimer::          ds 1    ; $D0EA: frames elapsed in the active loop (reset at entry,
                            ;   +1 per frame; masked e.g. `rrca/and 3` for blink/anim timing)


SECTION "wram_fade_state", WRAMX[$D0FE], BANK[1]
wFadeLevel::        ds 1    ; $D0FE: Logo fade level (0 = no fade)


SECTION "wram_serial", WRAMX[$D10A], BANK[1]
; Game Link serial state, driven by the serial-transfer-complete ISR
; (Func_00_3e7e): it stamps wSerialRecvFlag, copies the shifted-in byte from rSB
; into wSerialRecv, and dispatches on the protocol bytes ($f0/$f1/...). The link
; protocol itself lives in bank $31. To transmit, code stages a byte in
; wSerialSend, copies it to rSB, and kicks rSC.
wSerialRecvFlag::   ds 1    ; $D10A: $FF once a byte has arrived (set by the ISR); the
                            ;   bank-$31 poller checks it (`and a`) and clears it when handled
                    ds 3    ; $D10B-$D10D
wSerialRecv::       ds 1    ; $D10E: last byte received (copied from rSB by the ISR)
wSerialSend::       ds 1    ; $D10F: byte to transmit (staged here, then written to rSB)


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
