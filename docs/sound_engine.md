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
note & $0f` (semitone)** — `freq = $442e[row*32 + col*2]`. The note byte's
bit fields are:

- **bits 3-0** — the semitone column. The table is exact equal temperament;
  columns map `0..6 = C D E F G A B`, `8..14 = C# D# (E#) F# G# A# (B#)`, and
  **`$07`/`$0f` are rests**. Cols `$0a`/`$0e` are enharmonic duplicates of F/C.
  block `1` col `0` = C2 (MIDI 36); block N selects octave N+1.
- **bit 4** — a length-operand byte follows (the note's frame count); see timing
  below.
- **bits 5-6** — **stereo panning** (NR51/`rAUDTERM` via `$43ff/$4401/$4403`),
  *not* an octave shift. The handler shifts a per-channel L/R enable mask into
  `rAUDTERM`. (Earlier drafts of this doc misread this as an octave shift.)

The voice's hardware target is `voice index & 3`: 0→CH1 (`rAUD1*`), 1→CH2
(`rAUD2*`), 2→CH3 wave (`rAUD3LEVEL`), 3→CH4 noise (`rAUD4*`). For CH4 the
"frequency" value is written to `rAUD4POLY` (the noise polynomial), so note names
are not musical pitches on that channel. Volume/timbre come from the instrument
envelope (`$fc`), not the note.

### Note timing (frames)

The interpreter ticks once per frame (`UpdateSoundEngine` runs in the VBlank
handler, ~59.7 Hz). Voice `+0` is a frame countdown: while nonzero the note holds
and `+0` is decremented; at zero the next stream byte is read. A note sets `+0`
as follows (handler tail `$43e8`, using `+5`/`+6`):

- **bit 4 set** → `+0 = ` the explicit length-operand byte; `+6` (an
  explicit-length flag) is set, then cleared.
- **bit 4 clear** → `+6` is 0, so `+0 = +5`, the **default note length** set by
  `$fd n`.

So `$fd n` sets the default length and length-less notes reuse it — durations in
real songs come out as clean multiples (e.g. default `7`, with `14`/`28` for
half/quarter-note feel).

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
one array. Each entry points to a block in `$4776-$4aff`.

### Envelope blocks — `[value, duration]` pair streams

Three of the families are **envelopes**: streams of `[value, frames]` byte pairs.
A per-frame stepper holds `value` for `frames` frames, then advances to the next
pair (`frames = $ff` ≈ a sustain). Entries overlap into a shared pool at staggered
offsets, so instruments reuse common tails. The three steppers, the family that
loads each, and what `value` means:

| family / cmd | stepper | `value` is | drives |
|---|---|---|---|
| `$4708` / `$fc` | `Func_3f_42c5` | a `rAUDxENV` byte (vol<<4 \| dir<<3 \| period; CH3 = level) — **retriggers the channel** each step | volume envelope |
| `$4754` / `$ed` | `Func_3f_41e8` | a `rAUDxLEN` byte (duty in bits 7-6, length 5-0) | duty/length envelope |
| `$474c` / `$fb` | `Func_3f_422e`+`$4257` | a **signed** offset added to the note frequency | vibrato / pitch bend |

Examples (`$3f`): vol-env `$4776` = `f0 ff, c1 03, 90 ff, …` (a decay from full
volume); duty-env `$495e` = `00 ff, 40 ff, 80 ff, c0 ff, …` (duty 0→25→50→75%);
pitch-env `$47e6` = `00 ff, 00 10, 01 01, 02 01, 03 02, 02 01, ff 01, …` (a small
vibrato, `$ff`=−1).

The fourth family, `$4760` / `$ea`, is not a pair stream: each entry is a 16-byte
CH3 wave sample (4-bit, copied straight to `$ff30-$ff3f`) — directly editable,
e.g. `$4984` is a triangle (`01 23 45 67 89 ab cd ef …`), `$49a4` a descending
ramp (`0f fe ed dc …`).

### Voice state block (`$df00 + $20*voice`, partial)

Each voice's `$20`-byte runtime block; `[$dec7]` holds the low byte (`d=$df`).
The envelope steppers keep a `(pointer, value, countdown)` triple per envelope:

| off | meaning |
|---|---|
| `+0` | note length operand (when the note byte's bit 4 is set) |
| `+1` | octave register (set by `$9x`; the freq-table row) |
| `+2/+3` | current note frequency (set by the note handler, modulated by the pitch env) |
| `+4` | key-on flag (`$fe`) |
| `+6` | note-active flag |
| `+7`,`+8/9` | loop counter and loop-point pointer (`$ec` sets, `$eb` repeats) |
| `+$0c/d`,`+$0e`,`+$0f` | duty/length env: pointer, value, countdown (`$ed`) |
| `+$12/13` | saved stream pointer for call/return (`$f9`/`$f8`) |
| `+$16/17`,`+$18` | volume env: pointer, countdown (`$fc`) |
| `+$1c/d`,`+$1e`,`+$1f` | pitch env: pointer, value, countdown (`$fb`) |

Output to hardware is routed by `voice & 3`: `Func_3f_428a` writes the frequency
to CH1/2/3-`LOW/HIGH` or CH4 `rAUD4POLY`; `Func_3f_42ea` writes the volume to
`rAUD1/2/4ENV` (+ retrigger) or `rAUD3LEVEL`.

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
| `$28` | BGM | **BGM silence / stop** — its data is a 17-byte `rest; goto self` loop on all 4 channels (the BGM analogue of `$00`). Most-used (22 sites) because scenes play it to turn music off; despite being the boot/most-played BGM id it is *not* a musical track. |
| `$29` | BGM | **room** (tower gameplay); bank `$01` scene builder. |
| `$2a`,`$2c-$2e` | BGM | bank `$01` scene builders (paired scene cues). |
| `$2b` | BGM | **bonus stage** (tentative — observed for Hare, not yet checked against others). |
| `$2f` | BGM | **town**; bank `$18` scene (`Func_00_34bc`). |
| `$30` | BGM | **Bodka** (menu/studio: room-arrange menu, Bodka studio, intro). |
| `$31` | BGM | **room transition** (walking between floors); `Func_00_3508`. |
| `$32` | BGM | **Pashute** scenes. |
| `$33` | BGM | **Verde** scenes. |
| `$34` | BGM | **Toamuna** (ranch/save NPC theme; `Toamuna_CheckSaveExists`). |
| `$35` | BGM | **disc stone regeneration** (`ShowRegeneratedMonster`). |
| `$36` | BGM | **rival encounter** (Kalum/Mistral/Rafaga/Tempest/Nada). |
| `$37` | BGM | **title** theme (`IntroScene_TecmoLogo` call site; the music is the title screen, not the Tecmo logo). |
| `$38` | BGM | **intro**; bank `$30` (`Func_00_577e`). |
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
- **Done:** the command set (`$9x`, `$ea-$fe`), the note/`$ff` encoding, the song
  descriptor format, and the instrument/envelope blocks (`$4708`/`$4754`/`$474c`
  pair streams + `$4760` wave samples) are all enumerated above.
- **Done:** the note byte's `$70` field is resolved — bit 4 = length-operand
  flag, bits 5-6 = stereo panning (not octave); `+5` = default note length (set
  by `$fd`, used by length-less notes). `+$10` (set by `$ef`) is still unpinned.
- **Done — editable source:** the whole song-data region (`$4b00-$7ffe`, both
  banks) is now carved into readable RGBDS macro source —
  `src/snd_data_3f.asm` / `src/snd_data_3e.asm`, using the opcode macros in
  `include/snd_song.inc` (note columns, octave, envelopes, `s_call`/`s_goto`,
  descriptors). `tools/songdisasm.py` is the byte-exact (dis)assembler
  (`--verify` round-trips both banks; `--emit 3f|3e` regenerates the source).
  A song is an order-list of per-channel `s_call`s into shared pattern
  subroutines, looping via `s_goto`. ~30% of each bank is **unused/dead**
  patterns (decoded but referenced by nothing — flagged `; unused/dead pattern`).
  `tools/songexport.py --dump` is a frame-accurate channel emulator for analysis.
- **Done — GBS export:** `tools/songtogbs.py src/sound/.../<sound>.asm` builds a
  GBS (Game Boy Sound) file that plays that one sound on a GBS player (bit-exact,
  since it runs the real driver). It lifts the sound's bank from the built ROM,
  patches the `$7fff` bank tag to the GBS bank it places the data in (the driver
  re-banks to that tag per voice), and prepends a tiny INIT/PLAY stub
  (INIT: select bank, `$4000` reset, `$4006`/`$4009` start; PLAY: `$4003` update).
  Verified with gbsplay. Next: lift instruments/CH3 waves into PNG/2bpp assets.
- Give the three data tables (`$442e`, `$454b`, `$4708`) merged single-section
  homes + names (currently still fragmented into the static pass's `db` sections).
- Fill in the SFX ids with no observed caller (`$03`,`$07`,`$0c`,`$0f`,`$10`,
  `$12-$14`,`$16-$20`,`$23`,`$27`) and confirm the BGM track identities.
