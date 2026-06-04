# Sound engine

How Monster Rancher Explorer (USA) plays music and sound effects. Written as the
disassembly progresses; inferred/unconfirmed points are flagged. The engine is
carved into `src/sound.asm`. Channel/state RAM lives at `$de80+`; see the
hardware register names in `include/hardware.inc`.

## Layers

```
game code  --PlaySound / PlaySoundTracked(A = sound id)-->  HOME API ($0a30-$0b4d)
HOME API   --SoundCommandTable--> (driver bank, local index) --bankswitch + call $4006/$4009-->
driver     --Sound_ResolveCmdPtr / $4b00 table--> song descriptor --interpret--> APU ($ff10+)
```

There are two driver banks. **`$3f` owns sound ids `$00-$2e`** and **`$3e` owns
ids `$2f-$3a`** (59 ids total). The two banks contain a **byte-identical driver
in `$4000-$4aff`** — only the data from `$4b00` on (the pointer table and the
song/SFX bytecode) differs. So the driver is documented once, against `$3f`.

## HOME API (`$0a30-$0b4d`, in `src/sound.asm`)

| Symbol | Addr | Role |
|---|---|---|
| `ResetSoundEngine` | `$0a30` | banks in `$3f`, calls `$3f:$4000` (`Sound_Reset`), clears `[$c28c]`. |
| `UpdateSoundEngine` | `$0a45` | per-frame tick; calls `$3f:$4003` (`Sound_Update`). |
| `PlaySoundIfChanged` | `$0a56` | no-op if `A == [$c28c]` (don't restart the current track), else `PlaySoundTracked`. |
| `PlaySoundTracked` | `$0a63` | stores id in `[$c28c]`, then dispatches via `$4006` (tracked path). |
| `PlaySound` | `$0a85` | dispatches via `$4009` (transient path); does not record the id. |
| `SetSoundFade` | `$0aa4` | hands `(B,C,A)` to the fade block `$ded3/$ded4/$ded5` via `$3f:$400c`. Not called by any disassembled code yet. |
| `SetSoundMute` | `$0abd` | `A!=0` silences (saves+zeroes `rAUDTERM`/`rAUDVOL`), `A=0` restores, via `$3f:$400f`. Not called by any disassembled code yet. |
| `SoundCommandTable` | `$0ad8` | 59 entries, 2 bytes each: `(bank, local index)`. ids `$00-$2e` → `$3f`/index=id; ids `$2f-$3a` → `$3e`/index=id-`$2f`. |

The dispatch wrappers save the caller's bank via `[$7fff]` (a self-ID byte) and
restore it through `[$2fff]`, preserving BC/DE/HL. They take the id in `A`, look
up `SoundCommandTable[id]` to get the owning bank + local index, bank-switch, and
`call` the owning bank's fixed trampoline.

## Driver bank trampoline (`$4000`)

Six 3-byte `jp`s at the bank base, so HOME can call by fixed address regardless
of which bank is active:

| Addr | Target | Name |
|---|---|---|
| `$4000` | `Sound_Reset` | clear `$de80-$dfff`, init APU (`rAUDVOL=$77`, `rAUDENA=$8f`), silence. |
| `$4003` | `Sound_Update` | per-frame: advance all voices, run the fade ramp. |
| `$4006` | `Sound_StartTracked` | start id `A` on the **tracked** state block. |
| `$4009` | `Sound_Start` | start id `A` on the **transient** state block. |
| `$400c` | `$46de` | set fade block: `$ded3=B, $ded4=C, $ded5=A`. |
| `$400f` | `$46e7` | mute (`A!=0`) / unmute (`A=0`) by saving/zeroing `rAUDTERM`+`rAUDVOL`. |

`Sound_ResolveCmdPtr` (`$40c4`) turns a local index into a ROM pointer:
`entry = [$4b00 + 2*index]` (16-bit LE **offset relative to `$4b00`**);
`song = $4b00 + entry`.

### Driver code/data map (`$4000-$4aff`, both banks, verified by recursive descent)

| Range | Kind | Contents |
|---|---|---|
| `$4000-$442d` | code | trampoline, reset/update, start (tracked/transient), `Sound_ResolveCmdPtr`, channel install (`Func_3f_40d2`), per-frame interpreter + note handler. |
| `$442e-$452d` | **data** | note frequency table (16-bit GB pitch values). |
| `$452e-$454a` | code | command dispatch: `$9x`→`$46cc`, else `(cmd-$ea)*2` indexes the jump table. |
| `$454b-$4574` | **data** | command-handler jump table, 21 entries for cmd `$ea-$fe` (2-byte LE pointers). |
| `$4575-$4707` | code | the command handlers. `$f1-$f7` map to `$46db` = `jp $46db` (self-loop) → those opcodes are **unimplemented/reserved**. `$46de`/`$46e7` are the fade-block / mute handlers reached from `$400c`/`$400f`. |
| `$4708-$4aff` | **data** | instrument pointer table (`$4708`, ptrs into `$47xx`) + envelope/instrument blocks + a CH3 wave-sample table (`$49a4`), `$ff`-filled tail. |

The misclassified-code `db` fragments the static pass left in the code rows are
now disassembled in `src/sound.asm`; the three data tables stay `db`.

## Song / SFX pointer table (`$4b00`) and data (`$4d00+`)

`$4b00-$4cff` is a fixed 256-entry pointer table (offsets relative to `$4b00`).
Only the entries for the bank's own id range are meaningful; every other slot
holds the default offset `$0200`, i.e. `$4d00`. **Song/SFX bytecode begins at
`$4d00`** in both banks. Index 0 (`$4d00`) is the shared default entry — the
silence song (all 4 channels priority `$ff`, id `$00`). Counts: 47 real entries
in `$3f` (ids `$00-$2e`), 12 in `$3e`
(ids `$2f-$3a`).

### Song format

A song is a **12-byte descriptor** followed by per-channel command streams, all
within the bank. The descriptor is 4 records — one per GB channel CH1..CH4 — of
3 bytes: `[priority] [ptr_lo] [ptr_hi]` where the 16-bit pointer is again an
offset relative to `$4b00`. `Func_3f_40d2` installs a channel only if its
priority `>=` the channel's current priority, so a higher-priority SFX can take a
channel from the BGM. Example (id `$01`): CH2 has priority `$f0` and its own
stream; CH1/3/4 have priority `$00` pointing at a shared empty stream. The
silence song (`$4d00`) is 4× `[$ff,…]` (priority `$ff`) + a 3-byte stub.

### Channel command stream (the bytecode)

Each channel's stream is interpreted one byte at a time (`Func_3f_414a`):
`$ff` ends the channel; **bit 7 clear = a note**, **bit 7 set = a command**.

A **note** byte (`$00-$7f`, handler `$432c`→`$4382`) keys on the channel's
hardware voice with an 11-bit frequency looked up from the `$442e` table, which
is a 2-D grid: **`row = [block+1]` (the octave register set by `$9x`), `column =
note & $0f` (semitone)** — `freq = $442e[row*32 + col*2]`. Note bits 5-6 apply a
further octave shift (handlers `$43ff/$4401/$4403`); bit 4 flags that a length
operand byte follows. `note & $0f` of `$07`/`$0f` is a rest. The voice's hardware
target is `voice index & 3`: 0→CH1 (`rAUD1*`), 1→CH2 (`rAUD2*`), 2→CH3 wave
(`rAUD3LEVEL`), 3→CH4 noise (`rAUD4*`). Volume/timbre come from the instrument
envelope (`$fc`), not the note.

**Commands** (`$80-$fe`) dispatch via `Func_3f_452e`. `$9x` is special; the rest
index the `$454b` jump table by `(cmd-$ea)`:

| cmd | operand | action (writes to the voice's `$df` block unless noted) |
|---|---|---|
| `$9x` | — | set octave register `[+1] = x-1` (selects the frequency-table row). |
| `$ea n` | 1 | load CH3 waveform table `$4760[n]` into wave RAM `$ff30-$ff3f`, retrigger CH3. |
| `$eb` | 0 | loop back: `[+7]` is a counter — if nonzero, dec and jump to the saved point `[+8/9]`. |
| `$ec n` | 1 | set loop: `[+7]=n` (count), `[+8/9]=` current stream ptr (loop start). |
| `$ed n` | 1 | load effect table `$4754[n]` into `[+$0a…]`. |
| `$ee n` | 1 | set CH1 sweep (`rAUD1SWEEP`/NR10) `= n`. |
| `$ef n` | 1 | set `[+$10] = n`. |
| `$f0` | 1 | skip one byte (marker / no-op). |
| `$f1-$f7` | — | **reserved** — handler is `jp $46db` (self-loop); never emitted. |
| `$f8` | 0 | return: restore stream ptr from `[+$12]`. |
| `$f9 lo hi` | 2 | call: save ptr to `[+$12]`, jump (relative). |
| `$fa lo hi` | 2 | goto: jump (signed 16-bit relative). |
| `$fb n` | 1 | load table `$474c[n]` into `[+$1a…]`. |
| `$fc n` | 1 | set instrument: load `$4708[n]` (envelope block) into `[+$14…]`. |
| `$fd n` | 1 | set `[+5] = n`. |
| `$fe` | 0 | set `[+4] = 1` (note-active / key-on flag). |

There is one instrument pointer table at `$4708` (`$3f`: 55 entries, `$4708-$4775`);
the `$fc`/`$fb`/`$ed`/`$ea` commands index it from different base offsets
(`$4708`/`$474c`/`$4754`/`$4760` = entries 0/34/38/44), i.e. four "families" in
one array. Each entry points to a block in `$4776-$4aff`. The `$ea` family are
16-byte CH3 wave samples (4-bit, copied straight to `$ff30-$ff3f`) — directly
editable: e.g. `$4984` is a triangle (`01 23 45 67 89 ab cd ef …`), `$49a4` a
descending ramp (`0f fe ed dc …`). The envelope-block byte format (stepped each
frame to write `rAUDxENV`) is the remaining piece to decode.

## Per-frame interpreter (`Sound_Update` → `Func_3f_4113`)

Walks 8 voice slots (`[$dec3]` counter, `cp $08` — 4 tracked + 4 transient, mapped
to GB CH1-4 by `& 3`). Per voice it reads the next stream byte as above. The
tracked state lives around `$dec0/$dee0/$df00`, the transient state around
`$dec1/$def0/$df80`. The fade ramp (`Func_3f_4070`) nudges `rAUDVOL` toward `$77`
in steps of `$11` under control of the `$ded3-$ded5` block.

## State RAM (`$de80+`, partial)

| Addr | Meaning (inferred) |
|---|---|
| `$de80` | "busy"/lock flag set during `Func_3f_40d2` install. |
| `$dec0` / `$dec1` | currently-playing id, tracked / transient. |
| `$dec3` | voice loop counter (0..7) inside the per-frame update. |
| `$dec4/5`, `$dec6/7` | working pointers into the voice state arrays during update. |
| `$ded0`/`$ded1` | mute state: live `rAUDTERM` shadow / saved value. |
| `$ded3/4/5` | fade block: direction (1=in), step counter, target/level. |
| `$dee0+`, `$def0+` | per-voice control blocks, tracked / transient (stride `$20`). |
| `$df00+`, `$df80+` | per-voice runtime blocks, tracked / transient (stride `$20`). |

## Sound id reference

Derived from the `PlaySound*` call sites (caller context is fact; the role is
inferred from it). **ids `$00-$27` are SFX** (always the transient `PlaySound`
path) and **ids `$28-$3a` are BGM** (always `PlaySoundTracked`). ids not listed
exist in the data but have no disassembled trigger yet.

| id | kind | trigger context → inferred role |
|---|---|---|
| `$00` | SFX | played at boot/scene-change right after `ResetSoundEngine`; the default `$4d00` entry — **silence / stop**. |
| `$01` | SFX | bank `$12` UI (6 sites). |
| `$02` | SFX | boot menu, banks `$03`/`$30`. |
| `$04` | SFX | **pervasive UI blip (cursor move)** — 53 sites across menu code. |
| `$05` | SFX | **item use** — every `ItemEffect_*` handler calls it (22 sites). |
| `$06`,`$08`,`$09`,`$0a`,`$0b` | SFX | bank `$01`/`$30` events (`$08` also Cox-hat item). |
| `$0d` | SFX | **common UI confirm/action** — 40 sites (menus + room engine). |
| `$0e` | SFX | UI cancel/secondary (7 sites). |
| `$11`,`$15`,`$21`,`$22`,`$24`,`$26` | SFX | banks `$03`/`$30`/`$31`/`$01` events. |
| `$25` | SFX | **player lift** (`Player_LiftThink`). |
| `$28` | BGM | **main/title theme** — first track played at boot; most-used (22 sites). |
| `$29-$2e` | BGM | bank `$01` scene builders (paired scene cues). |
| `$2f` | BGM | bank `$18` scene (`Func_00_34bc`). |
| `$30` | BGM | menu/studio (room-arrange menu, Bodka studio, intro). |
| `$31` | BGM | `Func_00_3508`. |
| `$32` | BGM | **Pashute** scenes. |
| `$33` | BGM | **Verde** scenes. |
| `$34` | BGM | ranch/save (`Toamuna_CheckSaveExists`). |
| `$35` | BGM | monster-regenerated jingle (`ShowRegeneratedMonster`). |
| `$36` | BGM | **rival encounter** (Kalum/Mistral/Rafaga/Tempest/Nada). |
| `$37` | BGM | **Tecmo logo** jingle (`IntroScene_TecmoLogo`). |
| `$38` | BGM | bank `$30` (`Func_00_577e`). |
| `$39`,`$3a` | BGM | bank `$13` (likely ending/credits). |

A few call sites compute the id at runtime (e.g. `Func_04_405f`, `Func_05_4138/_4261`)
and play a variable sound — not captured above.

## Caller's view

A `call PlaySound` / `PlaySoundTracked` with a small immediate in `A` starts a
sound; `A` is a `SoundCommandTable` index. `PlaySoundIfChanged` is the "set BGM"
call. Use `[$c28c]` to know the current tracked track.

## TODO / unknowns

- **Done:** driver code/data reclassified (above), `$4000-$4aff` reads as code
  in both banks; sound ids named from their call sites (above).
- **Done:** the per-channel command set (`$9x`, `$ea-$fe`) and the note/`$ff`
  encoding are enumerated above; the song descriptor format is confirmed.
- Decode the per-entry layout of the four instrument banks (`$4708`, `$474c`,
  `$4754`, `$4760`) and the note byte's duration/octave bits (the `$70` field the
  `$432c` handler tests beyond the bare pitch index).
- Give the three data tables (`$442e`, `$454b`, `$4708`) merged single-section
  homes + names (currently still fragmented into the static pass's `db` sections).
- Fill in the SFX ids with no observed caller (`$03`,`$07`,`$0c`,`$0f`,`$10`,
  `$12-$14`,`$16-$20`,`$23`,`$27`) and confirm the BGM track identities.
