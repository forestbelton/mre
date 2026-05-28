# Text engine

Notes on how Monster Rancher Explorer (USA) encodes dialogue and
menu text in the ROM. Written as the disassembly progresses; gaps
and unknowns are flagged explicitly.

## Character set

Plain 7-bit ASCII (`$20-$7E`) for literal text. The game appears to
include no Japanese text — even the staff credits use romanized
names ("MOTOKI", "INAMOTO").

## Control bytes

A "script" is a stream of bytes interleaving ASCII text with
single-byte control opcodes (some of which take operands). Confirmed
control bytes:

All opcodes are **dispatched from a HOME-bank table at `$39F0`** (one
2-byte LE handler address per opcode). The dispatcher at `$39C5`
reads `C = [HL+]`; if `C >= $20` it's text (printable char + control
characters `$0D` for newline are handled by the text path); if
`C == $FF` it returns out of the engine; otherwise it indexes
`$39F0 + 2*C` to fetch a handler.

| Byte | Operand bytes | Handler | Meaning |
|---|---|---|---|
| `$01` | 4 | `$3A14` | **Init text-state**: stores 4 script bytes into `$D614 / $D615 / $D618 / $D619` (and duplicates `$D614/$D615` into `$D616/$D617`). |
| `$02` | 0 | `$3A7D` | **Render prep**: copies the 16-bit pointer at `$D614/$D615` into `$D616/$D617`, calls `$3C55`. Used immediately before `$08` to re-anchor the renderer at a fixed cursor. |
| `$03` | 0 | `$3A33` | **Wait + render prep**: `call $3A39` (wait-for-input core) then tail-call `$02`'s handler. Hence the `$03` cue seen before every Y/N menu. |
| `$04` | 0 | `$3A2D` | **Wait for A button** (end-of-message). |
| `$05` | 4 | `$3A93` | **Set text-state v2** — reads 4 script bytes into DE+BC, then `call $3BD3` (helper stores BC at `$D621/$D622` and continues with DE). Parallels `$01` but writes a different state slot. |
| `$06 lo hi` | 2 | `$3AA1` | **GOTO** within the engine — `HL = {hi:lo}`. Was previously called "local call"; the handler is just `ld a,[hl+]; ld h,[hl]; ld l,a; jp $39C5` — pure jump, no return stack. |
| `$07 lo hi bank` | 3 | `$3ABA` | **Far call** to Z80 code. Calls `$042E` with `A = bank`, `HL = {hi:lo}`; on return resumes the script. |
| `$08 wlo whi t₁lo t₁hi … tNlo tNhi` | 2 + 2·N | `$3AA7` | **Jump table indexed by WRAM byte.** Reads `[$whi wlo]`, multiplies by 2, adds to HL (which now points at the table), loads new HL from that entry. This is the *actual* dispatcher used by every menu and by `$0C`'s cyclic counter — what I was calling "MENU dispatch" was really `$02 $08 …`. The table is inline; the number of entries `N` is implicit (any byte the WRAM source can return). |
| `$09 lo hi val` | 3 | `$3AC9` | **Write to WRAM**: stores `val` at `[$hi lo]`. |
| `$0A lo hi val tlo thi` | 5 | `$3AD2` | **Jump if `[$hi lo] == val`** — else fall through. |
| `$0B lo hi val tlo thi` | 5 | `$3AE7` | **Jump if `[$hi lo] != val`** — else fall through. (Same operand layout as `$0A`; differs only in the `jr z`/`jr nz` polarity inside the handler.) |
| `$0C count` | 1 | `$3AFC` | **Cyclic counter** — `[$D60D] = ([$D60D] + 1) mod count`. Deterministic round-robin, not random. The "RAND" terminology was wrong; the followup is always an `$08` jump table reading `[$D60D]`. |
| `$0D` | 0 | `$3BAD` | **Newline** — advances the text cursor `[$D616/$D617]` to the column anchor in `[$D614]` and adds `$40` (one tilemap row × 2 bytes per tile). Implements the in-message line break that scripts write inline between text fragments. |
| `$0E lo hi bank` | 3 | `$3B0C` | **Set text-renderer config** — stores the 3 bytes verbatim at `$D61E/$D61F/$D620`. Was previously called "far call to script"; it isn't a call, it just configures which routine `$3C77`/`$3CF3`/`$0BF1` use for the following text. Different NPCs/contexts use different renderers (e.g. Naji has two: `bank-24 $6C9F` and `bank-24 $6C27`; the lady uses `bank-25 $408B`). |
| `$0F lo hi` | 2 | `$3B1B` | **Print `[$hi lo]` as decimal** — reads the WRAM byte, BCD-splits it into `$D5FB/$D5FC`, prints the high digit if non-zero then the low digit. This is the `[X]` substitution. |
| `$10 N` | 1 | `$3B3E` | **Repeat text-print N times** — pulls a count, then calls `$02E6 / $3CF3 / $0BF1` N times. |
| `$11 lo hi` | 2 | `$3B53` | **Print indexed string** — reads `[$hi lo]` as an index, looks up `$3B75 + 2*idx` to get a string pointer, prints the null-terminated string at that pointer. |
| `$1F` | 0 | `$3A39` | Helper, not normally a top-level opcode — invoked by `$03`/`$04` for the input-wait core. Showing up in the table at all is incidental. |
| `$FF` | 0 | (dispatcher) | **End of script** — the dispatcher returns. |

### Worked references back into the bytecode

Examples of how this table reads the canonical sequences we've seen:

- **Naji's "RAND" greeting**:
  `$0C $04   $08 $0D $D6   $4A $73 $6D $73 $94 $73 $BC $73`
  = `$0C` cycle-counter (mod 4) → updates `[$D60D]` → `$08` jumps via 4-entry table at the next 8 bytes, indexed by `[$D60D]`. Round-robin, not random.

- **Naji's main menu dispatch**:
  `$02   $08 $FF $D5   $E2 $74 $2C $75 $BC $75 $79 $75 $A8 $75`
  = `$02` resets the render anchor → `$08` jumps via the 5-entry table indexed by `[$D5FF]` (the cursor / confirm result).

- **The save Y/N pattern**:
  `…? $04   $07 $18 $40 $19   $0A $FE $D5 $01 $7A $45   …`
  = wait → far-call `bank-25 $4018` (sets `[$D5FE]` to save-exists flag, or to Y/N result from `bank-31 $58D7`) → if `[$D5FE]==$01`, jump to `$457A`. Confirmed by traces.

- **Naji's "till Level [X]"**:
  `"till Level " $0F $F2 $CF   " " $04 …`
  = print `[$CFF2]` as a decimal number in place. Confirmed.

## Script model

A script is conceptually a labeled sequence of **steps** with branch
operations between them. The encoded byte stream is just one long
linear sequence; "steps" and "labels" are abstractions over byte
offsets within that stream.

Each step is one of:

| Pseudo-op | Bytes | Notes |
|---|---|---|
| `<text>\e` | ASCII chars + `$04` | Display one message, wait for A button. |
| `<text>\n<text>\e` | ASCII + `$0D` + ASCII + `$04` | `$0D` is an in-message newline. |
| `[X]` (variable insert) | `$0F lo hi` | Insert WRAM byte `[$hilo]` as text. Used for the floor number in "till Level [X]" — `$0F $F2 $CF` reads `$CFF2`. |
| `GOTO <addr>` | `$06 lo hi` | Same-bank tail jump. The byte stream after a `$06` is "dead" unless reached by another jump. |
| `MENU` group | render `$07`s + `$02` dispatch | The block is: (optional `$0B` guards to hide options) → N × menu-render `$07` calls (with inline arg bytes) → finalize `$07` → `$02 $08 wlo whi t₁lo t₁hi … tNlo tNhi` dispatch table. Menu labels are tile glyphs blitted by the bank-31 routines; they never appear as text in the script. |
| `YESNO Yes A No B` | `$03 $07 $D7 $58 $1F $0A $FE $D5 $01 <B-lo> <B-hi>` | Show Y/N prompt. The `$03` is a 1-byte cue. The `$07` calls the bank-31 Y/N menu UI. The `$0A` reads result from `$D5FE`: if 1 (No), jump to B; else fall through to A. |
| `RAND`-style group | `$0C count` then `$08 wlo whi t₁lo t₁hi … tNlo tNhi` | Cyclic round-robin across N targets. `$0C` advances `[$D60D]` mod N; `$08` then dispatches via the inline jump table reading `[$D60D]`. Each target's tail GOTOs the shared follow-up via `$06`. **Not actually random** — the "RAND" framing in the source pseudocode was a player-side observation; the engine is deterministic. |
| `Z80_CALL <routine>` | `$07 lo hi bank` | Call a Z80 routine. Used for menu rendering, SAVE, LOAD, ENTER_DUNGEON, post-screen cleanup, etc. Distinguished from `$0E` (which calls a *script*). |
| `DONE` | `$FF` | End of script. |

Conditional jumps (`$0A` if-equal, `$0B` if-not-equal) implement
"if WRAM flag = value, jump to step X" — used to thread alternate
greetings, post-save-state branches, and probably menu-result
dispatch.

The user's pseudocode for the guest-book lady (verbatim, with the
note that the actual ROM script likely reuses subscripts like
"Need to do something else?" rather than inlining them twice):

```basic
00 Welcome.
01 What do you want to do?
02 MENU Sign 10
03 MENU Confirm 21
04 MENU Exit 98
10 Want to sign the guest book?
11 ... ... ... ... Okay. It's ready
12 Replace previous saved data?
13 YESNO Yes 15
14 YESNO No 01
15 Do not remove the Game Pak.
16 Z80_CALL SAVE
17 Finished signing the guest book!
18 Need to do something else?
19 YESNO Yes 01
20 YESNO No 98
21 Want to check the guest book?
22 ... ... ... ... Okay. It's ready
23 Previous data will be loaded.
24 YESNO Yes 26
25 YESNO No 01
26 Do not remove the Game Pak.
27 Z80_CALL LOAD
28 Done checking the guest book!
29 Need to do something else?
30 YESNO Yes 01
31 YESNO No 98
98 Okay. Be careful.
99 DONE
```

**ROM verification**: "Need to do something else?" occurs exactly once
in the ROM (at `$0644e9`) — so steps 18–20 and 29–31 collapse to one
shared subscript call site in practice.

## Script byte layout

Each dialogue tree is one byte stream terminated by `$FF`. A typical
flow:

```
text "Welcome, stay as"
$0D                      ; newline
text "long as you like"
$04                      ; wait for A
$06 a7 44                ; local call $44A7
$0E 8b 40 19             ; far call bank 25 $408B (the text engine?)
text "Welcome."          ; subscript content begins
$04
...
$FF                      ; end of this script
```

The parent script presents the first message, then dispatches to
sub-trees via repeated `$06 ... $0E ...` patterns. The `$0E` target
`bank 25 $408B` recurs across many scripts — almost certainly the
shared display routine.

### Worked example: ranch welcome

ROM offset `$64392`, 332 bytes, ends at `$644dd`.

The script presents one of several greetings based on game state:

- First visit / default: `"Welcome, stay as\nlong as you like\e"`
- `"Welcome.\e"` — repeat-visit short form
- `"Welcome back.\nGo and rest.\e"` — after some condition
- `"Welcome back.\nLong day?\e"` — after a different condition
- `"Pashute is back.\nThanks a lot.\e"` — after rescue
- `"Verde returned.\nGreat! Thank you\e"`
- `"Everyone's back,\nthanks to you.\e"` then `"I'm so happy,\nI'm speechless.\e"`

Then the menu prompt: `"What do you\nwant to do?"` followed by an
unknown menu construct (the `$07 / $08 / $0A` cluster).

Re-reading the raw bytes: `$09 $DC $D0 $01` actually appears **four**
times in this script (`$06437A`, `$06442B`, `$064457`, `$0644A0`),
each in the same shape:

```
... <intro-text> $04   $09 $DC $D0 $01   $06 $A7 $44   ...
```

= "after this intro variant ends, write `$D0DC = $01` then GOTO
`$44A7`" (the shared "What do you want to do?" menu prompt). So
the four state-specific intros all converge on the menu via this
tail. The writes ARE legitimate `$09` opcodes — but they write the
same `$01` that the area-init at `$12:$0314` already wrote on entry,
so they're redundant with it. Likely `$D0DC` accumulates multiple
meanings ("in-ranch" set by init, "lady-welcomed" set by script) that
happen to use the same value.

Also visible at `$064381` immediately after the first such tail:

```
064381  $0C $04 $08 $0D $D6   $8E $43  $B7 $43  $C7 $43  $E9 $43
```

— `$0C` cycle-counter + a `$08` jump table with 4 targets reading
`[$D60D]`, *identical in shape* to Naji's "RAND" pair. `$0C` / `$08`
/ `$D60D` are global engine infrastructure shared across NPCs.

### Runtime flow (from user's pseudocode)

This is the same state machine as the pseudocode above, drawn as a
tree so the menu/Y-N branching is easier to see:

```
"Welcome ... / What do you want to do?\e"
└─ menu (3 options: Sign, Confirm, Exit)   ← labels NOT in script (tile-rendered by $07 handlers)
   ├─ "Sign"
   │  └─ "Want to sign the / guest book?\e" + Yes/No
   │     ├─ Yes → "... ... ... ... / Okay. It's ready\e"   ← unconditional
   │     │      → $0A $FE $D5 $01 → if $D5FE == $01:
   │     │        ├─ existing save → "Replace previous / saved data?\e" + Yes/No
   │     │        │                   ├─ Yes → "Do not remove / Game Pak."
   │     │        │                   │       (save routine runs)
   │     │        │                   │       → "Finished signing the / guest book!\e"
   │     │        │                   │       → "Need to do / something else?\e" + Yes/No
   │     │        │                   │          ├─ Yes → back to "What do you want to do?"
   │     │        │                   │          └─ No  → "Okay. / Be careful.\e" + exit
   │     │        │                   └─ No  → "What do you want to do?" (back to main)
   │     │        └─ no save (fallthrough) → "Current data / will be saved.\e"
   │     │                                  → (save routine runs)
   │     │                                  → "Finished signing the / guest book!\e" ...
   │     └─ No  → "What do you want to do?" (back to main)
   ├─ "Confirm"
   │  └─ "Want to check / the guest book?\e" + Yes/No
   │     ├─ Yes → "... ... ... ... / Okay. It's ready\e"
   │     │      → "Previous data / will be loaded.\e"
   │     │      → (load routine)
   │     └─ No  → "What do you want to do?" (back to main)
   └─ "Exit"
      └─ "Okay. / Be careful.\e"
```

The four `$07` calls in the menu region most likely correspond to:
the three menu options (Sign, Confirm, Exit) plus the menu-builder
or default-cursor routine. Confirming which is which is best done
with a live trace.

### Worked example: Naji (Tower guard)

ROM offset `$063180`, in bank 24 (`$18`). This is the canonical
"NPC entry → branch on state → menu → dispatch → handlers" shape;
the user-provided pseudocode (Naji block in the conversation log)
decodes cleanly against the bytes.

**Entry + state selector** (`$063180-$06319A`):

```
063180  99 10 04                                   ; trailing bytes of prior script
063183  0A DD D0 04  3D 73                          ; if [$D0DD]==$04 -> $733D (greeting cycler)
063189  0A D7 C2 01  3D 73                          ; if [$C2D7]==$01 -> $733D (greeting cycler)
06318F  0A DD D0 02  E0 73                          ; if [$D0DD]==$02 -> $73E0 (progress)
063195  0A DD D0 01  3D 73                          ; if [$D0DD]==$01 -> $733D (greeting cycler)
06319B  0E 27 6C 18                                 ; far-call text engine (IF FIRST TIME)
06319F  "Did you come to..."                        ; pseudocode steps 00-13
063335  04                                          ; end of "Please help!"
063336  09 DD D0 01                                 ; mark [$D0DD] = 1
06333A  06 83 74                                    ; GOTO $7483 (menu prompt)
```

So `$D0DD` is Naji's NPC-state byte:
`0` = unseen, `1` = greeted, `2` = mid-quest progress, `4` = end state.
`$C2D7` is some separate global story flag.

**Cyclic greeting** (`$06333D` = bank-24 `$733D`):

```
06333D  0C 04                                       ; advance [$D60D] mod 4
06333F  08 0D D6                                    ; jump table dispatcher, reads [$D60D]
063342  4A 73  6D 73  94 73  BC 73                  ; 4 targets $734A/$736D/$7394/$73BC
06334A  0E 9F 6C 18 "Oh, you're here..." 04         ; option 0
06335C  06 83 74                                    ; GOTO $7483 (menu)
06335F  0E 27 6C 18 "It's you. Good luck..." 04     ; option 1
...
0633BC  0E 27 6C 18 "Hey. It's you!..." 04          ; option 3
0633DD  06 83 74                                    ; GOTO $7483 (menu)
```

Each option's tail is `$06 $83 $74` — they all GOTO the same menu.
The 4 messages laid out linearly, but only one runs per visit, in
deterministic round-robin order.

**Progress greeting** (`$0633E0` = bank-24 `$73E0`):

```
0633E0  0E 9F 6C 18 "Oh, it's you again..." 04 ...  ; long message
063488  04
063489  09 DD D0 01                                 ; reset state to "greeted"
06348D  06 83 74                                    ; GOTO $7483 (menu)
```

Note the same `$09 DD D0 01` reset: after Naji's "you made it half-way
up" speech, he demotes back to plain cyclic-greeting state.

**Menu prompt + state-specific render + dispatch** (`$063483` = bank-24 `$7483`):

```
063483  0E 27 6C 18 "What are your plans this time?"
0634A5  0A E2 D0 01 BF 74           ; if [$D0E2]==1 -> $74BF (skip Restart+Climb renderers)
0634AB  0B F0 CF 00 B8 74           ; if [$CFF0]!=0 -> $74B8 (skip Restart-only renderer)
0634B1  07 BC 5A 1F                 ; renderer A (bank-31 $5ABC) — draws this state's menu
0634B5  06 D0 74                    ; GOTO $74D0 (finalize/dispatch)
0634B8  07 42 5B 1F                 ; renderer B (bank-31 $5B42)  <-- $74B8
0634BC  06 D0 74                    ; GOTO $74D0
0634BF  0B F0 CF 00 CC 74           ; if [$CFF0]!=0 -> $74CC      <-- $74BF
0634C5  07 CB 5B 1F                 ; renderer C (bank-31 $5BCB)
0634C9  06 D0 74                    ; GOTO $74D0
0634CC  07 54 5C 1F                 ; renderer D (bank-31 $5C54)  <-- $74CC
0634D0  07 1B 6C 18                 ; finalize (bank-24 $6C1B)    <-- $74D0
0634D4  02                          ; render prep
0634D5  08 FF D5                    ; jump table dispatcher, reads [$D5FF]
0634D8  E2 74  2C 75  BC 75  79 75  A8 75   ; 5 dispatch targets
```

Each `$07 ... $1F` is a **complete renderer** — it draws the entire
menu for one game-state. The four renderers (`$5ABC / $5B42 / $5BCB
/ $5C54`) represent four state-specific menu layouts (e.g. 3 options
when no progress, 4 options after first climb). The `$0A`/`$0B`
guards pick exactly one based on `[$D0E2]` and `[$CFF0]`; that
renderer runs, then the immediate `$06 $D0 $74` GOTO falls through
to the shared finalize at `$74D0`. So only one renderer fires per
menu open — there are no "per-option label calls" in the script.

After finalize, `$02` resets the render anchor and `$08 $FF $D5 …`
dispatches via 5-entry table indexed by `[$D5FF]`. The renderer
chose which cursor positions are visible; the dispatch table is the
same shape regardless. That's why the same dispatch indices `{1,3,4}`
were observed for the 3-visible-options first-time state — the
renderer (probably `$5ABC`) only let the cursor visit slots that map
to those three table entries.

**Dispatch targets** (jump-table indices 0-4):

| Index | Target | Bytes at target | Pseudocode | Confirmed by trace? |
|---|---|---|---|---|
| 0 | `$74E2` | `"You've climbed till Level " $0F $F2 $CF $04 "Want to start there?"` | Restart → step 18 | not picked in trace |
| 1 | `$752C` | `"I understand. I'll open the door. But, are you ready?"` | Climb → step 23 | not picked in trace |
| 2 | `$75BC` | `$0A $DF $D0 $01 $24 $76 + "10 underground levels here..."` | (no pseudocode match) | **never reached by cursor** |
| 3 | `$7579` | `"What do you want to know?"` + Ask submenu | Ask → step 28 | yes, `$D5FF=$03` |
| 4 | `$75A8` | `"See you later." $04 $FF` | Leave → step 98 | yes, `$D5FF=$04` |

The 5-entries-vs-4-options mystery is resolved: there is a cursor →
dispatch lookup in the menu UI. The cursor visits 4 visible positions
{0,1,2,3} (one per visible option); on confirm, the lookup writes
{0,1,3,4} to `$D5FF` — dispatch index 2 (`$75BC`, the Tower content
directly) is **unreachable from the main-menu cursor**. It is still a
live target for *other* code (the bytes at `$75BC` start a real
script), but no menu selection lands there. Most likely it's reached
by a different NPC/script path or is dead code left over from an
earlier menu layout.

**Y/N confirmations** (Restart at `$0634E2`, Climb at `$06352C`):

```
"...till Level " 0F F2 CF 04 "Want to start there?"
063518  03                                          ; Y/N cue
063519  07 D7 58 1F                                 ; Y/N menu UI (bank 31 $58D7)
06351D  0A FE D5 01 83 74                           ; if [$D5FE]==1 (No) -> $7483 (back to menu)
063523  07 94 40 1F                                 ; ENTER_DUNGEON_AT setup (bank 31 $4094)
063527  07 A6 6B 18                                 ; ENTER_DUNGEON_AT (bank 24 $6BA6)
06352B  FF                                          ; end of script
```

So `$07 $A6 $6B $18` is the `Z80_CALL ENTER_DUNGEON_AT [X]` from
step 22; the `[X]` (floor number) is read from `$CFF2` inside the
routine (the same byte rendered by `$0F` in the prompt). Climb's
post-confirmation tail is `$07 $94 $40 $1F $07 $95 $6B $18 $FF` —
identical setup (`$4094`) but a different bank-24 entry (`$6B95` vs
`$6BA6`), so `$6B95` is `ENTER_DUNGEON` (start from level 1) and
`$6BA6` is `ENTER_DUNGEON_AT [CFF2]`.

**Ask submenu** (`$063579` = bank-24 `$7579`):

```
063579  0E 27 6C 18 "What do you want to know?"
063596  07 76 5D 1F                                 ; render all 3 options at once (bank 31 $5D76)
06359A  07 1B 6C 18                                 ; finalize
06359E  02 08 00 D6                                 ; dispatch, reads $D600
0635A2  9B 76  09 78  66 79                         ; targets: Tower / Item / Stop
```

The Ask submenu only emits one `$07` render call (vs the main menu's
four), so the bank-31 routine at `$5D76` must internally render all
three labels. The dispatch resolves to:

- `$769B` Tower → `"Find the golden key..."` (step 32) ending with `$09 $DF $D0 $01` (mark Tower-explained) + `$07 $94 $40 $1F` + `$07 $B7 $6B $18` + `$FF`
- `$7809` Item → `"Let me explain. There are over 300 items..."` (step 46), same end shape
- `$7966` Stop → **just** `$06 $83 $74` — bare GOTO back to `$7483` (the main menu prompt). This is the cleanest single-purpose script in the engine and is what nailed down `$06` as a GOTO opcode.

Each terminal sub-handler ends with `$FF` (end-of-script). The
"GOTO 28" in the user's pseudocode after Tower and Item content is
implemented by *not* terminating with `$FF` but with a chain of
`$07` cleanup calls then `$FF` that eventually returns the engine to
the menu prompt — the exact unwind mechanism is the next thing to
pin down with the analyzer.

### Confirmed handler locations

These were found by searching for the dialogue strings the player
sees in each branch, then converting to flat ROM offsets:

| Handler | ROM offset | First message |
|---|---|---|
| Sign | `$64513` (bank 25 `$4513`) | `"Want to sign the / guest book?"` |
| Confirm | `$645d4` (bank 25 `$45d4`) | `"Want to check / the guest book?"` |
| Exit | `$646be` (bank 25 `$46be`) | `"Be careful."` |
| Post-save loop | `$644d7` (bank 25 `$44d7`) | `"Need to do / something else?"` |

The `$07` targets in the main menu point at code addresses, not at
these script offsets:

| `$07` operand | Target | Notes |
|---|---|---|
| `$07 18 40 19` | bank 25 `$4018` | Z80 code (sets up menu palette / cursor — opens with `ld a, $12; ld hl, $4BB3; call $042E`) |
| `$07 d3 59 1f` | bank 31 `$59D3` | Z80 code (handler entry — almost identical to `$5960` below) |
| `$07 60 59 1f` | bank 31 `$5960` | Z80 code (handler entry) |
| `$07 7f 40 19` | bank 25 `$407F` | Z80 code (post-action — `ld hl, $5880; ld a, $1A; ld de, $9800; call $3942; ret`) |

These code routines presumably read further script bytes via the
text engine to render the chosen branch.

## Discovered script regions

### Bank 19 (decimal; ROM offsets `$4c000-$4ffff`)

Currently uncovered in `map.json`. All addresses are flat ROM offsets.

| Range | Bytes | Content |
|---|---|---|
| `$4c452-$4c6d4` | 643 | Nox/Alf "Wow, you were cool back then" flashback dialogue |
| `$4c6d5-$4c73c` | 104 | Nox reminiscing ("Whew! I forgot...") |
| `$4c73d-$4c7c2` | 134 | Nox "I'll go see old friends" |
| `$4c7c3-$4c7fe` | 60 | Nox "Wait, I forgot." |
| `$4c7ff-$4c883` | 133 | **Letter from Cox** — single block with only `$0D` line breaks, no `$04` waits. Reads like a static written note rather than spoken dialogue. |
| `$4c884-$4c8bd` | ~58 | Tile-encoded glyph table (`H;I*I;I1I;I` etc.) — not text |
| `$4c8be-$4c93b` | ~126 | Staff credits — see below |

#### Staff credits structure

Starting at `$4c8be`, an asciz string `STAGE STAFF\0` introduces a
repeated entry table. Each entry is:

```
<role-glyph><$A5><NAME>\0
```

Examples:

```
$4c8be  STAGE STAFF\0
$4c8ca  H \xA5 MOTOKI\0
$4c8d3  R \xA5 SHINADA\0
$4c8dd  Y \xA5 ... (next name)
```

The single-character `role-glyph` ("H", "R", "Y" so far) is **not
ASCII** — they're tile indices that render as job-title glyphs on
screen (Director, Programmer, etc., presumably). The `$A5` separator
between glyph and name is consistent.

### Bank 24 (decimal; ROM offsets `$60000-$63fff`)

Already covered as `data` inside `analyzed.asm`. Identified scripts:

| Offset | Bytes | Content (first message) |
|---|---|---|
| `$063180` | ~1000 | Naji (Tower guard) — full decode above. Spans roughly `$063180-$063969`. |
| `$0630ca` | ~? | "Be careful, and / good luck." — separate short region |

### Bank 25 (decimal; ROM offsets `$64000-$67fff`)

Already covered as `data` inside `analyzed.asm`. Identified
scripts:

| Offset | Bytes | Content (first message) |
|---|---|---|
| `$64392` | 332 | "Welcome, stay as / long as you like" — ranch greeting (the worked example above) |
| `$64513` | ~245 | "Want to sign the / guest book?" — guest-book save prompt |
| `$646be` | ~16+ | "Be careful." — short farewell |

There are many more scripts in bank 25 — `$06251e`, `$06357d`,
`$0644ab`, `$064540`, `$064615`, `$06457a` were all noticed during the
probe search but not yet mapped. Bank 25 looks like the central
location for ranch / save / town interactions.

### Other text noticed

- Bank 1 menu strings (`$4f5b`-`$4fdc`) — `PAUSE`, `STATUS`, `STAGE-MAP`, `GIVE-UP`, `TOWN`, blank line. 21-byte padded asciz; **no control bytes**. These are display-formatted menu items, not dialogue.
- Bank 1 `$4ff2`: `"     YES    NO      "` — same format, currently uncovered.
- Monster name table at `$3b83` — already extracted (see `src/names.asm`).
- Bank 21 `$5400a`: `"SMALL\0"` — small standalone asciz.

## Analyzer trace anchors

From a play session through Naji (`--watch-write $D5FF,$D600,$CFF0,$CFF2,$D0DD,$D60D`),
the following PCs were caught writing to the engine's state bytes
and identify concrete routines we can disassemble later.

| PC | Role | Evidence |
|---|---|---|
| `$05:$4656` / `$05:$4659` | Init clear of `$CFF0` / `$CFF2` at boot | Same PC writes both within one frame — a `xor a; ld [hl+], a; ld [hl], a` pattern over the engine block. |
| `$12:$0314` | Bulk zero of `$CFF0` / `$CFF2` / `$D0DD` on area entry | All three written from the same instruction when entering Naji's area. This is the "clear NPC/local state" routine. |
| `HOME:$3ACF` | **Script-engine `$09` (WRITE-WRAM) handler** | Originally logged as `$18:$3ACF` (Naji) and `$19:$3ACF` (lady). The PC is below `$4000`, so the code lives in HOME (always-mapped) — the bank prefix in the watch log is the currently-mapped *data* bank, not the code bank. Two NPCs in different banks hitting the same address confirms the interpreter is global HOME code. |
| `HOME:$3B09` | **Script-engine `$0C` (cyclic) handler** | Same correction — HOME code, runs from any data-bank context. Sits 58 bytes after the `$09` handler; the dispatch table at `$39F0` plus handlers `$3A14-$3B72` are now fully read out. |
| `$1F:$5AC9` | **Naji** main-menu init: zeros `$D5FF` | Fires on every Naji main-menu open. |
| `$1F:$596D` | **Guest-book lady** main-menu init: zeros `$D5FF` | Fires on the lady's main-menu open. Same register as Naji's main menu but a different init routine — the engine has multiple menu UI variants (4-option grid for Naji, 3-option vertical list for the lady). |
| `$1F:$5861` | **Cursor move** (any menu, shared) | Writes the new cursor value to `$D5FF` (main) or `$D600` (sub). Shared across Naji's menu, Naji's submenu, and the lady's menu. |
| `$1F:$5874` | Cursor move opposite direction | Same as `$5861` but the symmetric pair. |
| `$1F:$5AE9` | **Naji** main-menu confirm: writes dispatch index | Cursor → dispatch lookup happens here. Picking Ask (cursor 1) wrote `$03`; picking Leave (cursor 2) wrote `$04`; picking Climb (cursor 0) wrote `$01`. The lady's menu has **no equivalent confirm-PC observed** — likely dispatches off the live cursor value (like Naji's Ask submenu). |
| `$1F:$5D83` | Ask-submenu init: zeros `$D600` | Fires on every Ask-submenu open. The Ask submenu has **no separate confirm-PC** — dispatch reads the live cursor value. |
| `$1F:$58ED` | **Y/N-menu init** (shared): zeros `$D5FE` | Global Y/N UI infrastructure (called by anyone via `$07 $D7 $58 $1F`). Shared across Naji and the lady. |
| `$1F:$591A` | **Y/N-menu confirm** (shared): writes selection to `$D5FE` | `$00` = Yes, `$01` = No. The script's `$0A $FE $D5 $01 ...` then reads "if user picked No, GOTO menu" — so the YES case is the fall-through. |
| `$19:$4023` | **"Save exists?" check** inside the bank-25 `$4018` routine | Writes `$D5FE = $01` if a save record is present in the cart RAM (or `$00` if not). Called via `$07 $18 $40 $19` from the ranch-welcome script. Means `$D5FE` is dual-purpose: Y/N result (via `$58ED/$591A`) AND save-exists flag (via `$4023`). |

### What this nails down

- **`$D5FF`** is the main-menu dispatch register, written by `$5AE9` on confirm.
- **`$D5FE`** is the Y/N result register: 0 = Yes, 1 = No. Init at `$1F:$58ED`, confirm at `$1F:$591A`.
- **`$D600`** is the Ask-submenu cursor, read live by dispatch.
- **`$D0DD`** is Naji's NPC-state byte: 0 at boot, →1 after the first-time intro completes (written by the `$09` handler at HOME `$3ACF`).
- **`$D60D`** is the `$0C` cycle-counter byte, written by the `$0C` handler at HOME `$3B09` only when a `$0C` actually fires. Same address fires from both Naji's bank-24 cycler and the ranch-welcome's bank-25 cycler — confirming it's global engine state, not NPC-specific.
- **`$D0DC`** is *both* an area-presence flag (set `$01` by the area-init at `$12:$0314` on entering the ranch) *and* a script-write target (the four `$09 $DC $D0 $01` opcodes in the ranch welcome each write `$01`). Live trace confirms one of those script-writes fires during the lady's first-time intro. The two writes are redundant on the same value — probably defensive, or `$D0DC` accumulates two unrelated semantics that happen to coexist on `$01`.
- **The cursor-to-dispatch lookup** in the main menu maps the visible-cursor positions to the dispatch table, skipping hidden options. With Restart hidden (first-time path, `$CFF0=0`), cursor {0,1,2} → dispatch {1,3,4}; this was confirmed across three picks (Climb cursor 0 → dispatch 1, Ask cursor 1 → dispatch 3, Leave cursor 2 → dispatch 4). Dispatch index 2 (`$75BC`) stays unreachable from the menu cursor regardless.
- **`$0A` operand layout and equality semantics** confirmed again on Naji's Climb-No path: `$0A $FE $D5 $01 $83 $74` fired iff `$D5FE==$01`, jumping to `$7483`.

### What's still open after the trace

- **`$0B` semantics.** Still not pinned down — the first-time menu with `$CFF0=$00` rendered Climb / Ask / Leave (3 options), meaning the first `$0B` skipped Restart but the second `$0B` (same condition!) did *not* skip Ask. Likely needs a quick read of the bank-31 menu render routine or the bank-24 script interpreter at `$3A??/3B??` to settle.
- **Dispatch index 2 (`$75BC`)** is still unexplained — it's valid script content (a `$0A` conditional gating the Tower explanation) but is never reached via the main-menu cursor. Probably reachable from a different upstream caller.

## Open questions

1. ~~**How does Tower/Item content "GOTO 28" (back to Ask menu)?**~~ **Resolved by Naji's full disassembly** (`src/naji.asm`): the *Ask submenu's* Tower and Item handlers (`$769B` and `$7809`) end with a plain `$06` GOTO back to `$7579` (`NajiAskMenu`). The complex `$09 ... $07 $94 $40 $1F $07 $B7 $6B $18 $FF` tail I'd been chasing belongs to `NajiTowerLong` at `$75BC` — a *different* handler reachable only from main-menu dispatch entry 2 (the unreachable one). So `$FF` really is plain end-of-script, and Tower/Item content reaches the Ask menu via ordinary script-level GOTO.
2. **How are scripts dispatched?** Some upstream table or instruction sequence picks "use script at `$64392`" — finding that table would unlock automatic mapping from game state → script.
3. **What's the `$A5` separator in staff credits?** Probably an attribute byte (text color, palette). Need to compare with how it renders.
4. **Is Cox's letter at `$4c7ff` really a static text block?** It has no `$04` waits — but it does have `$0D` line breaks. May render as one big scrollable text box, or it's loaded into VRAM as static tiles.
5. **`$05`'s exact use.** The handler is decoded but the field isn't bytecode-flush yet — we haven't seen it in any extracted script. Could be a windowed-text or alternate text-frame opcode used by NPCs we haven't traced.

### Resolved by this disassembly pass

- ~~`$0A` vs `$0B` — same compare?~~ **No, opposite polarities.** `$0A` = jump if equal, `$0B` = jump if NOT equal.
- ~~`$02`/`$0C` second byte always `$08`?~~ **It's not a second byte — `$08` is its own opcode** (the inline jump-table dispatcher). The "$02 $08 …" / "$0C N $08 …" runs were two opcodes back-to-back.
- ~~`$0C`'s WRAM source~~ **Confirmed `$D60D`, fixed in the handler.** And `$0C` is a deterministic cyclic counter, not RAND.
- ~~`$08` operand width~~ **2-byte WRAM addr + inline jump table.**
- ~~`$10` semantics~~ **Repeat the text-render call N times.**
- ~~Y/N register~~ **`$D5FE`, written by `$1F:$591A` (Y/N confirm) and by `$19:$4023` (save-exists check).**
- ~~5-entries-vs-N-visible options~~ **Resolved differently from earlier framing**: the dispatch table is 5 entries because the engine reserves one per possible state-handler; per-state renderers (the bank-31 routines) decide which cursor positions are visible, and the cursor-to-dispatch index mapping is determined by the renderer.

## Why we're not extracting these yet

The encoding is now well-understood enough that a real script-aware
disassembler could be written. The full opcode set ($01-$11, $1F,
$FF) is now decoded against the actual HOME-bank handler bodies at
`$3A14-$3BD2`. `$0D` is the engine's newline; `$05` is a 4-byte
text-state setter (parallels `$01`) — both confirmed by reading the
handler bodies even though they haven't shown up in the extracted
scripts so far.

What's missing on the extractor side:

1. A new section type (or a `data` annotation language) that lets
   `map.json` mark a script region and emit per-opcode pseudocode
   alongside the bytes, rather than a flat `db` blob.
2. A label model that lets script targets (`$734A`, `$74E2`, …)
   become real RGBASM labels so cross-references resolve cleanly
   inside `analyzed.asm`.
3. A pass that picks up `$07` and `$0E` targets — `$07` is straight
   Z80 code, `$0E` is a text-renderer (still Z80 code, just used
   differently). Either way, marking these as code extends analyzer
   coverage and removes the "uncovered script call" sub-region.

Once those exist, bank-19 (Nox flashback / Letter from Cox) and the
unmapped bank-25 scripts can be extracted with their full structure
preserved.
