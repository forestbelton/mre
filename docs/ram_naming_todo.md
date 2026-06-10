# Remaining WRAM/HRAM naming work

Snapshot of the still-unnamed RAM operands (`[$xxxx]` raw addresses), so the next
naming pass doesn't have to re-hunt them. As of this snapshot: **315 distinct
addresses, ~1526 raw refs** (down from ~3500 — the dense single-purpose clusters
are done; see `include/wram.inc` / `include/hram.inc` and the per-subsystem docs).

Regenerate the raw table any time with `scratch/remaining_ram.py` (prints
`addr  count  reads/writes  files  top-routines`). The full table is appended
below.

## Method reminder

Per [[feedback_ram_label_confident_only]]: trace before naming, only name what's
confirmed, leave the rest as raw `ds` gaps, substitute `[$xxxx] -> [label]`
(byte-exact), `make verify` every time. A heavily-**written**, rarely-**read**
byte is usually a parameter to its one reader (a dispatcher/trampoline), not
state — find the reader first.

## Clusters worth a dedicated pass (highest value first)

### 1. `$cf40`–`$cf90` — room/scene/FX working state (biggest remaining pool)
The `wram_scene` region. Several sub-groups, all transient per-frame state:
- **Bank `$05` scene/cutscene** (`Func_05_*`): `$cf41/$cf42`, `$cf43`–`$cf4c`,
  `$cf4f`, `$cf5b`–`$cf60`, `$cf45` — sequence step/timer/coords. ~80 refs.
- **Floor/timer** (`$cf65/$cf66/$cf67`, `QuintupleFloorTimer`, bank `$0f`/`$01`).
- **Room engine** (bank `$03`, `engine.asm`): `$cf71`–`$cf80`, `$cf8c` —
  `Player_*`, knockback (`ApplyKnockbackX/Y` touch `$cf7b`), grab-scan
  (`Player_ScanGrabTargets` touches `$cf73/$cf74`). Cross-ref `docs/room_engine.md`.
- **Spawner params** `$cf84`–`$cf89`: a 6-byte block read by `ReadSpawnerParams`
  /`SpawnerSlotActive` (`layout.asm`) — already routine-named, easy struct to name.
- **Item tracking** `$cf8e`–`$cf90`: `TrackItemCollection` (`layout.asm`).

### 2. `$c2d8`–`$c2e6` — story / floor-progress flags
The `wram_story_flags` region just after `wC2D7`. Bank `$01`/`$0f`, mostly
write-heavy (flags set as the player progresses): `$c2d8`(20), `$c2dd`(17),
`$c2db`(13), `$c2e2`(14), `$c2e3`(12), `$c2da/$c2d9/$c2de/$c2e4/$c2e6/$c2df`.
`StartKeyUnlock` and several `Func_01_*`/`Func_0f_*` touch these — likely the
per-floor "unlocked / opened / cleared" bits and key/door state.

### 3. Game Link exchange (`$d5c2`–`$d5f9`, `$d109`, `$d0ff`, `$d100`)
Bank `$31` two-player link/trade protocol — pairs with the `wSerial*` trio
already named. Many routines are already labelled (`LinkExchangeConnect`,
`LinkStoreSendRoom`, `LinkClampResultCode`, `Func_31_*`). `$d5c7`(19), `$d5c3`(12,
a retry/timeout counter — `Func_31_4069` cmp loop), `$d5f6`(12), `$d5c2`(11).
`$d100`(12)/`$d0ff`(9) are bank-`$30` link-screen state.

### 4. `$c7cb`–`$c7de` — 2D grid-menu working buffers
Extends `docs/menu.md`. `Func_00_25e5`/`27xx`/`28xx` build a grid into `$c7d3`
(the buffer named there). `$c7cc`(6, read-only — column index source),
`$c7cb`(6), `$c7ce/$c7cd/$c7d2/$c7d3/$c7d4`(8–9), `$c7de`(8, `Func_00_3460`).
Decode alongside the remaining `$c55d`–`$c570` menu bytes.

### 5. Sound driver internals (`$de80`, `$dec3`–`$dec7`)
All in `sound_driver.asm` — the engine's playback state. `$dec7`(22),
`$dec3`(11), `$dec4/$dec5`(8), `$dec6`(6). Cross-ref `docs/sound_engine.md`;
likely current-track pointer / tempo / channel-enable bytes.

### 6. Rendering / OAM HRAM scratch (`$ff9b`, `$ffa6`–`$ffac`)
Used by `DrawMetasprite`, `HideUnusedOamSprites`, `CheckItemPickup`,
`Func_05_4000`, banked copies. `$ffac`(17), `$ffa8`(15), `$ffa9`(14, an X/Y or
src/dst pair with `$ffa8`?), `$ffa7`(9), `$ffa6`(8). General sprite/copy temps.

## Quick wins (low effort, high confidence)

- **`$d61f`** (22, write-only) — this is the **high byte of `wRendererAddr`**
  (`$D61E/$D61F`, already a named 2-byte field). Just substitute
  `[$d61f] -> [wRendererAddr + 1]`. Pure cleanup, no new investigation.
- **`$ffc3`/`$ffc4`** (15/11) — the entity **16-bit timer** left raw in the
  `hEntity*` block; `DecGenTimer16` / `SetTimer120` / `SetProjectileSpeed`
  (engine.asm) now confirm the role. Name `hEntityTimer16Lo/Hi`.
- **`$cff1`** (10) — the unnamed gap byte inside `wram_floor_state` (`$CFF0`
  block, between `wCFF0` and `wCurrentFloor`).
- **`$c2ea`/`$c2eb`** (6/7) — the per-room source the editor cursor
  (`wEditCursorX/Y`) is saved to/from; noted in `docs/menu.md`.
- **`$cf84`–`$cf89`** — `ReadSpawnerParams`' 6-byte spawner-slot record.

## Appendix — full raw table (count ≥ 3)

Columns: `addr  refs  reads/writes  files  top-routines(count)`.

```
$cf65	22	8r/14w	engine.asm,gameplay.asm,monster_detail.asm	QuintupleFloorTimer(2), Func_0f_4565(1), Func_0f_4588(1), Func_03_45a0(1)
$d0e7	21	14r/7w	editor.asm,home.asm	Func_12_4c3e(3), Func_12_4870(2), Func_12_4c1a(2), Func_12_4c83(2)
$d61f	21	0r/21w	bodka.asm,cox.asm,kalum.asm,mistral.asm,nada.asm,naji.asm,pashute.asm,portrait_lib.asm,rafaga.asm,tempest.asm,toamuna.asm,verde.asm	Func_1f_50a1(1), Kalum_AnimateMonsterPortrait(1), Pashute_RenderPortraitNeutral(1), Pashute_RenderPortraitPanic(1)
$ffac	20	18r/2w	editor.asm,engine.asm,entity_anim.asm,home.asm,layout.asm	Func_12_4548(2), Func_12_45c3(2), CheckItemPickup(2), Func_12_455f(1)
$c2d8	20	5r/15w	gameplay.asm,monster_detail.asm	Func_0f_4054(2), Func_0f_4000(1), Func_0f_403b(1), Func_0f_40cb(1)
$c55d	19	15r/4w	editor.asm,editor_screens.asm,home.asm,screens.asm	Func_15_4147(2), Func_30_4403(1), DrawRoomStartScreen(1), Func_30_4540(1)
$d5c7	19	15r/4w	link.asm	Func_31_4542(2), Func_31_457e(2), Func_31_452e(1), Func_31_456f(1)
$c55f	17	9r/8w	editor.asm,home.asm	Func_00_217d(2), Func_12_433e(1), Func_12_4441(1), Data_00_213b(1)
$c2dd	17	3r/14w	engine.asm,gameplay.asm	Func_01_587f(2), Func_01_5949(2), Func_01_5a5f(2), Func_03_502b(1)
$cf77	17	8r/9w	engine.asm,gameplay.asm	AnimSparkleRing(3), Func_03_6a89(2), Func_03_6c62(2), Func_03_6c83(2)
$ffa8	15	6r/9w	gameplay.asm,home.asm,layout.asm,monster_detail.asm,scene.asm,screens.asm	SceneInit(2), Func_30_5816(1), SceneFinish(1), Func_0f_420f(1)
$ffc3	15	8r/7w	engine.asm	DecGenTimer16(2), Func_03_66d6(2), SetProjectileSpeed(1), SetTimer120(1)
$ffa9	14	6r/8w	gameplay.asm,home.asm,layout.asm,monster_detail.asm,scene.asm,screens.asm	SceneInit(2), Func_30_5816(1), SceneFinish(1), Func_0f_420f(1)
$c530	14	6r/8w	editor.asm,engine.asm,gameplay.asm,home.asm,layout.asm	Func_03_5518(3), Func_00_2f65(2), Func_12_401e(1), Func_12_4933(1)
$cf67	14	5r/9w	engine.asm,entity_anim.asm,gameplay.asm,monster_detail.asm	Func_0f_491f(3), QuintupleFloorTimer(2), Func_0f_4565(1), Func_0f_4588(1)
$c2e2	14	9r/5w	engine.asm,gameplay.asm	Func_01_5acd(3), Func_03_400b(1), Func_03_6ba2(1), Func_03_6bc8(1)
$cf3f	13	8r/5w	home.asm,scene.asm,screens.asm	Func_30_5f6e(2), SceneFlipDrawBuffer(2), Func_30_5816(1), Func_30_5f4b(1)
$c2db	13	9r/4w	engine.asm,gameplay.asm,monster_detail.asm	Func_0f_4000(1), UpdateEntities(1), EndEntityFrame(1), Func_01_4412(1)
$cf66	13	5r/8w	engine.asm,gameplay.asm,monster_detail.asm	Func_0f_491f(3), QuintupleFloorTimer(2), Func_0f_4565(1), Func_0f_4588(1)
$d100	12	10r/2w	screens.asm	Func_30_476c(2), Func_30_47d0(2), Func_30_49fd(2), Func_30_4a3f(2)
$c531	12	4r/8w	editor.asm,engine.asm,gameplay.asm,home.asm,layout.asm	Func_03_5518(3), Func_12_401e(1), Func_12_4933(1), Func_00_2df6(1)
$d5c3	12	6r/6w	link.asm	Func_31_4069(2), Func_31_410f(2), Func_31_420d(2), LinkExchangeConnect(1)
$d5f6	12	5r/7w	link.asm	Func_31_46d4(2), Func_31_4725(2), Func_31_4755(2), Func_31_452e(1)
$c2e3	12	7r/5w	engine.asm,gameplay.asm,home.asm	Func_01_4bdc(2), Func_01_65e8(2), Func_00_11b4(1), Func_03_6ec9(1)
$d5c2	11	3r/8w	bodka.asm,link.asm	Func_31_409a(1), Func_31_413d(1), Func_31_423d(1), Func_31_4329(1)
$c289	11	7r/4w	gameplay.asm,home.asm,layout.asm,scene.asm	Func_01_4dd9(2), SceneFinish(1), Func_00_0d4d(1), Func_00_0d7f(1)
$c2da	11	6r/5w	gameplay.asm,monster_detail.asm	Func_0f_4097(2), Func_0f_40b2(2), Func_0f_4125(2), Func_0f_40e8(1)
$c29e	11	6r/5w	home.asm	Func_00_0979(4), Func_00_094a(2), Func_00_09b1(2), Func_00_09d5(2)
$ffd0	11	10r/1w	engine.asm,entity_anim.asm	SpawnProjectileRel(2), EndEntityFrame(1), SpawnProjectileInFront(1), Func_03_5352(1)
$ffc4	11	7r/4w	engine.asm	DecGenTimer16(2), SetProjectileSpeed(1), SetTimer120(1), Func_03_5adf(1)
$cf4b	10	1r/9w	scene.asm	SceneSprVm_Step(1), SceneSprOp_LoopOn(1), SceneSprOp_LoopOff(1), SceneSprOp_Sound(1)
$cf4c	10	1r/9w	scene.asm	SceneSprVm_Step(1), SceneSprOp_LoopOn(1), SceneSprOp_LoopOff(1), SceneSprOp_Sound(1)
$cff1	10	2r/8w	gameplay.asm,scene.asm	Func_05_479d(1), Func_01_45d6(1), Func_01_460e(1), Func_01_461c(1)
$c2ac	10	1r/9w	home.asm,monster_detail.asm	Func_0f_4054(1), Func_0f_4206(1), Func_0f_4265(1), Func_0f_427b(1)
$c7cd	10	8r/2w	home.asm	Func_00_25e5(7), Func_00_281f(1), Func_00_2994(1), Func_00_2d95(1)
$cf8e	10	6r/4w	gameplay.asm,layout.asm	.next(2), Func_01_5764(2), Func_01_57d0(2), Func_01_57f3(2)
$cf79	10	3r/7w	engine.asm,gameplay.asm	SpawnFx15_SetDoneFlag(3), Func_03_699b(2), Func_03_6ba2(2), Func_03_6917(1)
$cf7a	10	3r/7w	engine.asm	Func_03_6e7b(3), Func_03_6c46(2), Func_03_6d0a(2), Func_03_6be4(1)
$cfbc	10	4r/6w	cox.asm	Func_13_49e9(3), Func_13_496b(2), Func_13_4a08(2), Func_13_41e5(1)
$d0ff	9	4r/5w	screens.asm	Func_30_49d1(2), Func_30_5547(2), DrawNextRoomScreen(1), Func_30_4946(1)
$cf5b	9	4r/5w	home.asm,scene.asm,screens.asm	Func_05_443d(2), Func_05_445a(2), Func_05_447f(2), Func_30_5816(1)
$c56f	9	5r/4w	editor.asm,home.asm	Func_00_2e94(3), Func_00_2e56(2), Func_00_2e78(2), Func_12_45e3(1)
$cf41	9	1r/8w	scene.asm	SceneBgVm_Enter(1), SceneBgOp_Sound(1), SceneBgOp_Flip(1), SceneBgOp_Draw(1)
$cf42	9	1r/8w	scene.asm	SceneBgVm_Enter(1), SceneBgOp_Sound(1), SceneBgOp_Flip(1), SceneBgOp_Draw(1)
$c28a	9	6r/3w	gameplay.asm,home.asm,layout.asm,scene.asm	SceneFinish(1), Func_00_0d4d(1), Func_00_0d7f(1), Func_00_0da3(1)
$c2d9	9	5r/4w	gameplay.asm,monster_detail.asm	Func_0f_416c(2), Func_0f_41a3(2), Func_0f_41bd(2), Func_0f_4054(1)
$ffa7	9	4r/5w	home.asm	Func_00_0be6(1), HideUnusedOamSprites(1), Func_00_0c04(1), DrawMetasprite(1)
$c7ce	9	7r/2w	home.asm	Func_00_25e5(6), Func_00_281f(1), Func_00_2994(1), Func_00_2d95(1)
$c2e4	9	5r/4w	engine.asm,gameplay.asm,layout.asm	Func_01_65a6(2), Func_01_65e8(2), Func_01_6aae(2), Func_01_4124(1)
$c2de	9	4r/5w	gameplay.asm	StartRoomAnimation(1), Func_01_58c1(1), Func_01_58d9(1), Func_01_58ee(1)
$cf5c	8	3r/5w	home.asm,scene.asm,screens.asm	Func_05_443d(2), Func_05_445a(2), Func_30_5816(1), SceneInit(1)
$d0e8	8	4r/4w	editor.asm,home.asm	Func_12_48d3(2), Func_12_40ec(1), Func_12_416e(1), Func_12_4866(1)
$c569	8	1r/7w	editor.asm	Func_12_455f(1), Func_12_4597(1), Data_12_45cf(1), Func_12_45fa(1)
$cf4f	8	3r/5w	scene.asm	SceneSprVm_Enter(2), SceneSprOp_Anim(2), SceneSprOp_Show(2), SceneSprOp_Move(1)
$c282	8	0r/8w	home.asm,portrait_lib.asm	Func_00_04cc(1), Func_00_0608(1), Func_00_0630(1), Func_00_076f(1)
$ffa6	8	3r/5w	home.asm	Func_00_05ae(1), Func_00_05ca(1), Func_00_05fd(1), Func_00_0602(1)
$c7d3	8	1r/7w	home.asm	Func_00_25e5(6), Func_00_281f(1), Func_00_2994(1)
$c7d4	8	1r/7w	home.asm	Func_00_25e5(6), Func_00_281f(1), Func_00_2994(1)
$c7d2	8	8r/0w	home.asm	Func_00_2c85(2), Func_00_28d5(1), Func_00_2994(1), Func_00_2bf1(1)
$c7de	8	1r/7w	home.asm	Func_00_3460(2), Func_00_3340(1), Func_00_340c(1), Func_00_342a(1)
$c2e6	8	3r/5w	engine.asm,gameplay.asm	Func_01_44ef(2), Func_03_45a0(1), Func_01_449d(1), Func_01_450d(1)
$cf7f	8	4r/4w	engine.asm,gameplay.asm	Func_01_6eda(3), Func_01_6ef9(2), Player_StandThinkDown(1), Player_ClearActionFlag(1)
$cf5d	7	2r/5w	home.asm,scene.asm,screens.asm	Func_05_445a(2), Func_30_5816(1), SceneInit(1), Func_05_443d(1)
$d5f9	7	6r/1w	bodka.asm,link.asm	Func_31_4189(1), Func_31_41bb(1), Func_31_4449(1), LinkExchangeTransfer(1)
$cf45	7	3r/4w	scene.asm	SceneBgVm_Step(2), SceneBgOp_Draw(2), SceneBgOp_Row(2), SceneSetupTracks(1)
$c2ab	7	1r/6w	gameplay.asm,home.asm,scene.asm	Func_05_4785(1), Func_05_479d(1), Func_05_47b2(1), Func_05_47c6(1)
$c281	7	0r/7w	home.asm,portrait_lib.asm	Func_00_04cc(1), Func_00_05ae(1), Func_00_05dc(1), Func_1f_4008(1)
$c7cb	7	5r/2w	home.asm	Func_00_289d(2), Func_00_27a5(1), Func_00_27f9(1), Func_00_2b07(1)
$c7cc	7	6r/1w	home.asm	Func_00_27e1(1), Func_00_2b4d(1), Func_00_2b6b(1), Func_00_2b89(1)
$d60e	7	0r/7w	gameplay.asm,home.asm	Func_00_39ad(1), Func_01_5c70(1), Func_01_5ce2(1), Func_01_5cff(1)
$c55c	7	4r/3w	room_murals.asm,special_scene.asm	Func_38_4000(1), SpecialScene_SelectIndex(1), Func_17_40dd(1), Func_17_40e3(1)
$cf78	7	4r/3w	engine.asm,gameplay.asm	Func_03_6a89(1), Func_03_6ace(1), Func_03_6e7b(1), Stairs_PollOpenUp(1)
$cf7b	7	3r/4w	engine.asm	Func_03_6e7b(2), Func_03_6e01(1), ApplyKnockbackX(1), ApplyKnockbackY(1)
$c2c5	7	3r/4w	gameplay.asm	Func_01_4ab6(2), Func_01_4530(1), Func_01_4a3b(1), Func_01_4a48(1)
$d0fa	6	2r/4w	screens.asm	DrawRoomClearScreen(1), Func_30_50d7(1), Func_30_5259(1), Func_30_527e(1)
$cf5e	6	1r/5w	home.asm,scene.asm,screens.asm	Func_30_5816(1), SceneInit(1), Func_05_443d(1), Func_05_445a(1)
$cf5f	6	1r/5w	home.asm,scene.asm,screens.asm	Func_30_5816(1), SceneInit(1), Func_05_443d(1), Func_05_445a(1)
$cf60	6	1r/5w	home.asm,scene.asm,screens.asm	Func_30_5816(1), SceneInit(1), Func_05_443d(1), Func_05_445a(1)
$c2eb	6	6r/0w	editor.asm,gameplay.asm,home.asm,layout.asm	Func_12_452d(1), Func_00_1ada(1), PackFloorSnapshot(1), SpawnPlayerEntity(1)
$c2ea	6	6r/0w	editor.asm,gameplay.asm,home.asm,layout.asm	Func_12_453b(1), Func_00_1ada(1), PackFloorSnapshot(1), SpawnPlayerEntity(1)
$c570	6	3r/3w	editor.asm,home.asm	Func_00_2ebb(2), Func_00_2f4b(2), Func_12_4584(1), Func_00_2e37(1)
$d5fa	6	5r/1w	bodka.asm,link.asm	Func_31_4189(1), Func_31_41bb(1), Func_31_446e(1), LinkExchangeTransfer(1)
$d10d	6	2r/4w	link.asm	Func_31_42e9(1), Func_31_42f8(1), Func_31_42ff(1), Func_31_437d(1)
$cf6d	6	3r/3w	monster_detail.asm,scene.asm	SceneInit(1), SceneFinish(1), Func_0f_420f(1), Func_0f_4229(1)
$cf6e	6	3r/3w	monster_detail.asm,scene.asm	SceneInit(1), SceneFinish(1), Func_0f_420f(1), Func_0f_4229(1)
$cf50	6	2r/4w	scene.asm	SceneSprOp_Step(2), SceneSprOp_Show(1), SceneSprOp_Move(1), Func_05_44b4(1)
$cf51	6	2r/4w	scene.asm	SceneSprOp_Step(2), SceneSprOp_Show(1), SceneSprOp_Move(1), Func_05_44b4(1)
$cfe8	6	3r/3w	monster_detail.asm,scene.asm	Func_0f_4897(2), Func_05_463a(1), Func_05_46f0(1), Func_05_473d(1)
$ff9b	6	3r/3w	home.asm	DrawMetasprite(1), Func_00_0c20(1), Func_00_0c45(1), Func_00_0c51(1)
$c2df	6	3r/3w	gameplay.asm,home.asm	Func_01_4bbd(2), Func_00_11ca(1), Func_01_49e0(1), Func_01_4ab6(1)
$cf8f	6	3r/3w	gameplay.asm,layout.asm	Func_01_5788(2), TrackItemCollection(1), RemoveCollectedCell(1), Func_01_575b(1)
$cf90	6	3r/3w	gameplay.asm,layout.asm	Func_01_5788(2), TrackItemCollection(1), RemoveCollectedCell(1), Func_01_5749(1)
$cf70	6	3r/3w	engine.asm	BreakOrChainCrateCell(1), Func_03_4544(1), PlayerHit_BeginStun(1), Func_03_4f38(1)
$cf6f	6	3r/3w	engine.asm	BreakOrChainCrateCell(1), Func_03_4544(1), PlayerHit_BeginStun(1), Func_03_4f38(1)
$c287	5	4r/1w	home.asm,monster_detail.asm,screens.asm	Func_0f_436e(2), WaitForNextFrame(2), Func_30_4104(1)
$cf52	5	1r/4w	scene.asm,screens.asm	Func_30_5816(1), SceneInit(1), SceneSprOp_LoopOn(1), SceneSprOp_LoopOff(1)
$cfbe	5	3r/2w	editor.asm,editor_screens.asm,home.asm	Func_12_425b(1), OpenRoomSelectMenu(1), OpenRoomArrangeMenu(1), Func_15_40ac(1)
$c55e	5	3r/2w	editor.asm,editor_screens.asm	Func_12_4296(1), Func_12_42a2(1), Func_12_43fe(1), Func_12_4426(1)
$ffab	5	4r/1w	editor.asm,home.asm,layout.asm	Data_12_45cf(1), Func_12_45fa(1), Func_12_4631(1), Func_00_2dda(1)
$c7df	5	2r/3w	editor.asm	Func_12_4798(1), Func_12_47e5(1), Func_12_4804(1), Func_12_4941(1)
$c7e0	5	2r/3w	editor.asm	Func_12_4798(1), Func_12_47e5(1), Func_12_4804(1), Func_12_4941(1)
$d5f5	5	2r/3w	link.asm	Func_31_46fe(2), Func_31_4725(2), Func_31_452e(1)
$d5ea	5	3r/2w	link.asm	Func_31_4644(4), Func_31_47ce(1)
$cf63	5	1r/4w	scene.asm	SceneScrollWobble(2), SceneBgOp_WobbleOn(1), SceneBgOp_WobbleOff(1), SceneSetupTracks(1)
$c2c4	5	2r/3w	gameplay.asm,scene.asm	Func_01_67ee(2), Func_05_47d4(1), Func_01_6856(1), Func_01_7608(1)
$cfb2	5	2r/3w	monster_detail.asm	Func_0f_43c3(4), Func_0f_43bb(1)
$c2a3	5	3r/2w	home.asm,monster_detail.asm	Func_00_37b0(2), Func_0f_494b(1), Func_00_3788(1), Func_00_3796(1)
$c2a4	5	3r/2w	home.asm,monster_detail.asm	Func_00_37b0(2), Func_0f_494b(1), Func_00_3788(1), Func_00_3796(1)
$d6cf	5	2r/3w	monster_detail.asm	Func_32_42d4(1), Func_32_42ef(1), Func_32_430a(1), Func_32_432a(1)
$d6d0	5	1r/4w	monster_detail.asm	Func_32_42d4(1), Func_32_42ef(1), Func_32_430a(1), Func_32_4339(1)
$d6d1	5	1r/4w	monster_detail.asm	Func_32_42d4(1), Func_32_42ef(1), Func_32_430a(1), Func_32_4339(1)
$c2e0	5	2r/3w	gameplay.asm,home.asm	Func_01_4bbd(2), Func_00_11ca(1), Func_01_49e0(1), Func_01_4af4(1)
$c56e	5	2r/3w	home.asm	Func_00_2ebb(2), Func_00_27a5(1), Func_00_2be9(1), Func_00_2e20(1)
$d61b	5	2r/3w	cox.asm,engine.asm,home.asm	.specialChar(2), Func_00_397a(1), .lookupTile(1), Func_13_4061(1)
$ffd7	5	4r/1w	gameplay.asm,layout.asm	CheckItemPickup(1), Func_01_5df7(1), Func_01_5e44(1), Func_01_650d(1)
$ffd6	5	4r/1w	gameplay.asm	Func_01_7499(2), Func_01_5df7(1), Func_01_5e44(1), Func_01_650d(1)
$ffd8	5	4r/1w	gameplay.asm	Func_01_5df7(1), Func_01_5e44(1), Func_01_5eaf(1), Func_01_650d(1)
$ffb2	5	2r/3w	entity_anim.asm	Func_04_403c(1), EntityAnim_SetAnimation(1), Func_04_4114(1), Func_04_42d4(1)
$cfed	4	2r/2w	scene.asm,screens.asm	Func_05_481d(2), Func_30_4f10(1), Func_05_463a(1)
$cfee	4	2r/2w	scene.asm,screens.asm	Func_05_4835(2), Func_30_4ff6(1), Func_05_463a(1)
$d0f9	4	2r/2w	screens.asm	DrawRoomClearScreen(1), Func_30_50d7(1), Func_30_5646(1), Func_30_566c(1)
$cf61	4	1r/3w	scene.asm,screens.asm	Func_30_5816(1), SceneInit(1), SceneBgOp_Scroll(1), Func_05_447f(1)
$cf64	4	1r/3w	scene.asm,screens.asm	SceneDrawMetasprites(2), Func_30_5816(1), SceneInit(1)
$c560	4	2r/2w	editor.asm,home.asm	Func_12_4441(1), Func_12_447e(1), Func_00_2223(1), Func_00_2253(1)
$d5c5	4	2r/2w	link.asm	Func_31_4189(1), Func_31_41bb(1), Func_31_44e1(1), Func_31_44fd(1)
$cf62	4	1r/3w	scene.asm	SceneScrollWobble(1), SceneBgOp_WobbleOn(1), SceneBgOp_WobbleOff(1), SceneSetupTracks(1)
$cf57	4	2r/2w	scene.asm	SceneBgOp_Row(1), SceneSprOp_Anim(1), Func_05_43db(1), Func_05_440c(1)
$cf58	4	2r/2w	scene.asm	SceneBgOp_Row(1), SceneSprOp_Anim(1), Func_05_43db(1), Func_05_440c(1)
$cf59	4	2r/2w	scene.asm	SceneBgOp_Row(1), SceneSprOp_Anim(1), Func_05_43db(1), Func_05_440c(1)
$cf5a	4	2r/2w	scene.asm	SceneBgOp_Row(1), SceneSprOp_Anim(1), Func_05_43db(1), Func_05_440c(1)
$cf4d	4	1r/3w	scene.asm	SceneSprOp_Show(1), SceneSprOp_Move(1), SceneDrawMetasprites(1), SceneSetupTracks(1)
$cf4e	4	1r/3w	scene.asm	SceneSprOp_Show(1), SceneSprOp_Move(1), SceneDrawMetasprites(1), SceneSetupTracks(1)
$cf3e	4	1r/3w	monster_detail.asm	Func_0f_466c(2), LoadDiscStoneDisplay(1), Func_0f_4690(1)
$cf3a	4	1r/3w	monster_detail.asm	LoadDiscStoneDisplay(1), Func_0f_465c(1), Func_0f_466c(1), Func_0f_4690(1)
$cf3b	4	1r/3w	monster_detail.asm	LoadDiscStoneDisplay(1), Func_0f_465c(1), Func_0f_466c(1), Func_0f_4690(1)
$c286	4	1r/3w	home.asm	HaltIfC286Set(2), Func_00_02a4(1), Func_00_02b9(1)
$c29d	4	2r/2w	home.asm	Func_00_09b1(2), Func_00_09d5(2)
$ff9d	4	2r/2w	home.asm	Func_00_0ca0(2), Func_00_0cae(1), Func_00_0cb9(1)
$c2ad	4	0r/4w	home.asm	Func_00_0d41(1), Func_00_0d76(1), Func_00_0d7f(1), Func_00_0da3(1)
$c7d6	4	1r/3w	home.asm	Func_00_33fb(1), Func_00_340c(1), Func_00_342a(1), Func_00_3492(1)
$c7d7	4	1r/3w	home.asm	Func_00_33fb(1), Func_00_340c(1), Func_00_342a(1), Func_00_3492(1)
$c7dd	4	1r/3w	home.asm	Func_00_33fb(1), Func_00_340c(1), Func_00_342a(1), Func_00_346e(1)
$d61a	4	2r/2w	cox.asm,engine.asm,home.asm	Func_00_397a(1), .loop(1), DrawTextWindow(1), Func_13_4000(1)
$c2c2	4	3r/1w	gameplay.asm,layout.asm	GetFloorIndex(1), Func_00_17c0(1), Func_01_4698(1), Func_01_46a0(1)
$cf81	4	2r/2w	gameplay.asm,layout.asm	.slotLoop(1), Func_01_40c6(1), Func_01_40da(1), Func_01_42f2(1)
$cf82	4	2r/2w	gameplay.asm,layout.asm	.slotLoop(1), Func_01_40e7(1), .dispatch(1), Func_01_42f2(1)
$ffaa	4	2r/2w	layout.asm	RemoveOpenItemAtCell(2), CheckItemPickup(2)
$ffd9	4	3r/1w	gameplay.asm,layout.asm	CheckItemPickup(1), Func_01_5df7(1), Func_01_5e44(1), Func_01_650d(1)
$c2e5	4	1r/3w	engine.asm,gameplay.asm	Func_01_4dd9(2), Func_03_6a89(1), Func_01_49e0(1)
$c2e1	4	1r/3w	gameplay.asm	Func_01_4bbd(2), Func_01_49e0(1), Func_01_4af4(1)
$ffca	4	3r/1w	entity_anim.asm	Func_04_4114(1), Func_04_4138(1), Func_04_419d(1), Func_04_4319(1)
$ffcb	4	3r/1w	entity_anim.asm	Func_04_4114(1), Func_04_4138(1), Func_04_419d(1), Func_04_4319(1)
$d617	4	1r/3w	cox.asm,engine.asm	.poll(1), PrintCharacterAtCursor(1), Func_13_4982(1), Func_13_49ac(1)
$d602	4	4r/0w	npc_menus.asm	Func_1f_587c(1), Func_1f_6245(1), Func_1f_62c1(1), Func_1f_62d8(1)
$d60c	4	3r/1w	npc_menus.asm	Func_1f_6254(1), Func_1f_62b4(1), Func_1f_62ca(1), Func_1f_62d8(1)
$d0fb	3	2r/1w	home.asm,screens.asm	DrawTownScreen(1), Func_30_41a9(1), Func_00_34bc(1)
$d109	3	1r/2w	link.asm	Func_31_4360(1), Func_31_43db(1), Func_31_43fc(1)
$d5f8	3	0r/3w	link.asm	Func_31_452e(1), Func_31_456f(1), Func_31_47ce(1)
$d5f7	3	0r/3w	link.asm	Func_31_452e(1), Func_31_456f(1), Func_31_47ce(1)
$d5e9	3	1r/2w	link.asm	Func_31_4644(2), Func_31_47ce(1)
$cf49	3	2r/1w	scene.asm	SceneBgOp_Draw(1), SceneDrawBgMap(1), Func_05_4385(1)
$cf4a	3	2r/1w	scene.asm	SceneBgOp_Draw(1), SceneDrawBgMap(1), Func_05_4385(1)
$cf43	3	1r/2w	scene.asm	SceneBgOp_Draw(1), SceneDrawBgMap(1), SceneSetupTracks(1)
$cf44	3	1r/2w	scene.asm	SceneBgOp_Draw(1), SceneDrawBgMap(1), SceneSetupTracks(1)
$c55b	3	1r/2w	gameplay.asm,scene.asm	Func_05_4931(1), Func_05_4956(1), Func_01_4c57(1)
$c55a	3	1r/2w	gameplay.asm,scene.asm	Func_05_4931(1), Func_05_4956(1), Func_01_4c82(1)
$cfb1	3	1r/2w	monster_detail.asm	Func_0f_43c3(2), Func_0f_43bb(1)
$c7d5	3	1r/2w	home.asm	Func_00_25e5(1), Func_00_281f(1), Func_00_2994(1)
$c2c0	3	0r/3w	home.asm	Func_00_3318(2), Func_00_3308(1)
$c7dc	3	1r/2w	home.asm	Func_00_3340(1), Func_00_346e(1), Func_00_347e(1)
$d612	3	2r/1w	home.asm,npc_menus.asm	Func_1f_65c1(2), Func_00_3e10(1)
$cf80	3	1r/2w	gameplay.asm,layout.asm	.slotLoop(1), Func_01_40c6(1), Func_01_42f2(1)
$cf84	3	2r/1w	layout.asm	ReadSpawnerParams(1), SpawnerSlotActive(1), Func_01_426d(1)
$cf85	3	2r/1w	layout.asm	ReadSpawnerParams(1), SpawnerSlotActive(1), Func_01_426d(1)
$cf86	3	2r/1w	layout.asm	ReadSpawnerParams(1), SpawnerSlotActive(1), Func_01_426d(1)
$cf87	3	2r/1w	layout.asm	ReadSpawnerParams(1), SpawnerSlotActive(1), Func_01_426d(1)
$cf88	3	2r/1w	layout.asm	ReadSpawnerParams(1), SpawnerSlotActive(1), Func_01_426d(1)
$cf89	3	2r/1w	layout.asm	ReadSpawnerParams(1), SpawnerSlotActive(1), Func_01_426d(1)
$cf68	3	2r/1w	engine.asm,entity_anim.asm,gameplay.asm	Func_03_45a0(1), Func_01_7b24(1), Func_04_4100(1)
$cf73	3	2r/1w	engine.asm	Player_ScanGrabTargets(1), Player_ProbeGrabCellL(1), Player_ProbeGrabCellR(1)
$cf74	3	2r/1w	engine.asm	Player_ScanGrabTargets(1), Player_ProbeGrabCellL(1), Player_ProbeGrabCellR(1)
$cf72	3	2r/1w	engine.asm	Func_03_4a8c(1), Func_03_4c0b(1), Func_03_4e85(1)
$cf71	3	2r/1w	engine.asm	Func_03_4a8c(1), Func_03_4c0b(1), Func_03_4e85(1)
$cf7d	3	1r/2w	engine.asm	Func_03_6be4(1), Func_03_6bfb(1), PlaceBossEntryY(1)
$cf8c	3	1r/2w	engine.asm	Func_03_6d0a(2), Func_03_6cd7(1)
$cf76	3	1r/2w	gameplay.asm	Func_01_55bc(1), Func_01_55d1(1), Func_01_55db(1)
```
