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

| Byte | Operand bytes | Meaning |
|---|---|---|
| `$04` | — | End of message. The text engine waits for an A-button press, then continues with the next byte. |
| `$0D` | — | Newline within a message. Equivalent to the player-facing line break inside a single text bubble. |
| `$FF` | — | End of script. Terminates a whole dialogue tree. The bytes immediately after `$FF` are usually another script (or unrelated data — e.g., the tile lookup at `$4c884`). |
| `$06 lo hi` | 2 | **GOTO (same-bank jump)** to script at `$hilo`. **Confirmed JMP, not CALL** — Naji's Ask/Stop branch at `$7966` is *literally just* `$06 $83 $74` followed by trailing `$00`s, exactly matching pseudocode "MENU Stop 14" (GOTO step 14 = `$7483` = "What are your plans?"). The previous "local call + $0E pair" reading was wrong: `$06` is the GOTO, the `$0E` after it is dead unless reached separately. |
| `$0E lo hi bank` | 3 | **Far call to script**. Calls a subscript at address `$hilo` in bank `bank` (decimal). Example: `$0E 8B 40 19` calls bank-25 `$408B` — almost certainly the engine's main text-display routine, given how often other scripts call into it. |
| `$07 lo hi bank` | 3 | **Far call to Z80 code**. Distinct from `$0E`: the target is not a script byte stream but real machine code. All four `$07` targets in the ranch-welcome script disassemble cleanly as Z80 (e.g., `bank25 $4018` → `ld a, $12; ld hl, $4BB3; call $042E; ld a, ($D5FE); ret; ...`). Used to invoke handler routines that render menu items, perform saves, etc. The menu labels ("Sign", "Confirm", "Exit", "Yes", "No", "Restart", "Climb", "Ask", "Leave") are **not in the script bytes at all** — they're tile-blitted by the code these calls reach. Some menu-render `$07` calls are followed by 3 bytes of inline argument data (e.g., `$07 $bc $5a $1f $06 $d0 $74`); the called Z80 routine reads its args and advances the script PC past them. |
| `$09 lo hi val` | 3 | **Write to WRAM**. Stores byte `val` at WRAM address `$hilo`. Used to update NPC-state flags. Example: `$09 $dd $d0 $01` writes `$01` to `$D0DD`. Naji writes `$D0DD = $01` after both the first-time intro and the "progress" greeting, so subsequent visits fall into the RAND-greeting branch. |
| `$0F lo hi` | 2 | **Insert WRAM byte as text**. Reads byte at WRAM `$hilo` and renders it in place — the `[X]` substitution in the user's pseudocode. Example: `"till Level " $0F $F2 $CF " "` inside the Restart prompt reads `$CFF2` (current tower floor) and prints it as a number. |
| `$0A lo hi val tlo thi` | 5 | **Conditional jump (equal)**. If `[$hilo] == val`, jump to `$thi tlo`; else fall through. Confirmed via the save flow and the welcome menu (see `$0A` section below). |
| `$0B lo hi val tlo thi` | 5 | **Conditional jump** with the same shape as `$0A`. Empirically used to skip optional menu items: in Naji's menu, `$0B $F0 $CF $00 $B8 $74` and `$0B $F0 $CF $00 $CC $74` skip past the Restart/Ask render calls when `[$CFF0] == $00`. Whether `$0B` and `$0A` differ in side-effects or compare operator isn't yet pinned down. |
| `$0C count flag wlo whi tlo₁ thi₁ … tloₙ thiₙ` | 4 + 2·count | **RAND**. Picks one of `count` targets at random, using `[$whi wlo]` as the source/state. `flag` is `$08` in every sample so far. Example: `$0C $04 $08 $0D $D6  $4A $73 $6D $73 $94 $73 $BC $73` = "random of 4 greetings, source `$D60D`, targets `$734A / $736D / $7394 / $73BC`". Each RAND target tail-jumps (`$06`) back to the shared follow-up — so the laid-out byte stream looks like the 4 options run sequentially, but at runtime only one fires. |
| `$02 flag wlo whi tlo₁ thi₁ … tloₙ thiₙ` | 4 + 2·N | **MENU dispatch**. After the option-render `$07`s have populated the menu UI and the player has picked a slot, the menu code writes the result to WRAM `[$whi wlo]` and `$02` indexes into the inline jump table. `flag` is `$08` in every sample so far. Example: Naji's main menu is `$02 $08 $FF $D5  $E2 $74  $2C $75  $BC $75  $79 $75  $A8 $75` — reads `$D5FF`, dispatches to one of 5 targets (Restart / Climb / Tower-content / Ask / Leave). The Ask submenu uses the same shape with `[$D600]` and 3 targets. |

### Control bytes still unknown

These bytes appear in scripts but their operand widths and semantics
haven't been confirmed. The numbers in parentheses are best guesses
based on how many bytes seem to follow before text resumes.

- `$03` (0?) — appears as a 1-byte marker immediately before every Y/N menu setup: `"...?" $03 $07 $D7 $58 $1F $0A $FE $D5 ...`. Seen in the guest-book lady (before "Replace previous"), in Naji's Restart confirmation, and in Naji's Climb confirmation. Possibly a "switch text-box mode to Y/N indicator" cue, or just visual spacing.
- `$08` (5?) — `$08 ff d5 0f xx xx` shape suggests a 6-byte conditional like `$0A`, comparing against `$D5FF`. Still needs a confirmed example.
- `$10` (?) — `$10 $78` seen between "Do not remove / Game Pak." and the next "Finished signing the guest book!" message. The user's pseudocode says step 16 is `Z80_CALL SAVE` — so `$10 $78` may be either a `Z80_CALL`-shaped opcode using `$10` (different from `$07`?) or a 1-byte short-call into a SAVE routine selected by `$78`. Needs more data.

#### `$0A` — conditional jump (confirmed)

5 operand bytes, 6 bytes total. Shape:

```
$0A  addr_lo addr_hi  value  target_lo target_hi
     └── 2-byte addr ──┘ └─1B─┘ └────── 2-byte ──────┘
```

Semantics: **if `byte at $addr_hi addr_lo` equals `value`, jump to `$target_hi target_lo` within the current script**.

Caught in two places that pin down the operand layout:

1. In the **save flow** at `$06454c`:
   ```
   "Okay. It's ready" $04 $07 $18 $40 $19  $0A $FE $D5 $01 $7A $45  "Current data\rwill be saved." ...
   ```
   `$7A $45` decodes as `$457A`, which is exactly the script address of `"Replace previous / saved data?"`. So this reads: *if WRAM `$D5FE` (an "existing save" flag) is `$01`, branch to the Replace prompt; otherwise fall through into the "Current data will be saved." path.*

2. In the **welcome script** at `$0644c6`:
   ```
   "What do you / want to do?" $07 $18 $40 $19  $0A $FE $D5 $01 $D3 $44  ...
   ```
   Same pattern — reads `$D5FE`, jumps to `$44D3` (which contains a `$07 $60 $59 $1F` — call to the bank-31 "Confirm" menu code).

`$0B` confirmed shares this 6-byte shape (see Naji's menu, where
`$0B $F0 $CF $00 …` skips renderers when `[$CFF0]==$00`). `$09`
turned out to be 4 bytes total (WRITE to WRAM), *not* a conditional —
the docs originally guessed wrong because `$09 $DD $D0 $01` looked
like the start of a `$0A`-shaped op. `$08` is still tentatively a
6-byte conditional, but needs a confirmed example.

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
| `RAND` group | `$0C count $08 wlo whi t₁lo t₁hi … tNlo tNhi` | Random branch among N targets. Each target's tail GOTOs the shared follow-up via `$06`. |
| `Z80_CALL <routine>` | `$07 lo hi bank` | Call a Z80 routine. Used for menu rendering, SAVE, LOAD, ENTER_DUNGEON, post-screen cleanup, etc. Distinguished from `$0E` (which calls a *script*). |
| `DONE` | `$FF` | End of script. |

Conditional jumps (`$0A` confirmed, `$08`/`$09` very likely) implement
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

Within the script we see the `$09 dc d0 01` pattern twice — likely a
"flag is set" precondition guarding the "Pashute"/"Verde" branches.

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
063183  0A DD D0 04  3D 73                          ; if [$D0DD]==$04 -> $733D (RAND)
063189  0A D7 C2 01  3D 73                          ; if [$C2D7]==$01 -> $733D (RAND)
06318F  0A DD D0 02  E0 73                          ; if [$D0DD]==$02 -> $73E0 (progress)
063195  0A DD D0 01  3D 73                          ; if [$D0DD]==$01 -> $733D (RAND)
06319B  0E 27 6C 18                                 ; far-call text engine (IF FIRST TIME)
06319F  "Did you come to..."                        ; pseudocode steps 00-13
063335  04                                          ; end of "Please help!"
063336  09 DD D0 01                                 ; mark [$D0DD] = 1
06333A  06 83 74                                    ; GOTO $7483 (menu prompt)
```

So `$D0DD` is Naji's NPC-state byte:
`0` = unseen, `1` = greeted, `2` = mid-quest progress, `4` = end state.
`$C2D7` is some separate global story flag.

**RAND greeting** (`$06333D` = bank-24 `$733D`):

```
06333D  0C 04 08 0D D6                              ; RAND of 4, source $D60D
063342  4A 73  6D 73  94 73  BC 73                  ; targets $734A/$736D/$7394/$73BC
06334A  0E 9F 6C 18 "Oh, you're here..." 04         ; option 1
06335C  06 83 74                                    ; GOTO $7483 (menu)
06335F  0E 27 6C 18 "It's you. Good luck..." 04     ; option 2
...
0633BC  0E 27 6C 18 "Hey. It's you!..." 04          ; option 4
0633DD  06 83 74                                    ; GOTO $7483 (menu)
```

Each option's tail is `$06 $83 $74` — they all GOTO the same menu.
The 4 messages laid out linearly, but only one runs per visit.

**Progress greeting** (`$0633E0` = bank-24 `$73E0`):

```
0633E0  0E 9F 6C 18 "Oh, it's you again..." 04 ...  ; long message
063488  04
063489  09 DD D0 01                                 ; reset state to "greeted"
06348D  06 83 74                                    ; GOTO $7483 (menu)
```

Note the same `$09 DD D0 01` reset: after Naji's "you made it half-way
up" speech, he demotes back to plain RAND-greeting state.

**Menu prompt + render + dispatch** (`$063483` = bank-24 `$7483`):

```
063483  0E 27 6C 18 "What are your plans this time?"
0634A5  0A E2 D0 01 BF 74                          ; if [$D0E2]==1 -> $74BF (already rendered?)
0634AB  0B F0 CF 00 B8 74                          ; if [$CFF0]==0 -> $74B8 (skip Restart)
0634B1  07 BC 5A 1F  06 D0 74                       ; render slot 1 (Restart label)
0634B8  07 42 5B 1F  06 D0 74                       ; render slot 2 (Climb label)
0634BF  0B F0 CF 00 CC 74                          ; if [$CFF0]==0 -> $74CC (skip Ask)
0634C5  07 CB 5B 1F  06 D0 74                       ; render slot 3 (Ask label)
0634CC  07 54 5C 1F                                 ; render slot 4 (Leave label)
0634D0  07 1B 6C 18                                 ; finalize menu (Z80)
0634D4  02 08 FF D5                                 ; dispatch table header (reads $D5FF)
0634D8  E2 74  2C 75  BC 75  79 75  A8 75           ; 5 targets
```

Each render-`$07` is followed by 3 bytes of inline argument data
(`$06 $D0 $74` = the menu-dispatcher address `$74D0`); the bank-31
routine reads its args and bumps the script PC past them.

`$CFF0` controls whether Restart and Ask render — when it's 0 (no
tower progress yet), only Climb and Leave appear. That matches the
expected first-visit menu state.

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
| `$18:$3ACF` | **Script-engine `$09` (WRITE-WRAM) handler** | Fires when the script byte `$09 $DD $D0 $01` executes after Naji's first-time intro. Anchor for the bank-24 script interpreter. |
| `$18:$3B09` | **Script-engine `$0C` (RAND) handler** | Fires when the script byte `$0C` executes on a non-first-time Naji visit (writes the chosen index to the RAND result byte `$D60D`). Sits 58 bytes after the `$09` handler — the bank-24 interpreter is a per-opcode dispatch table laid out around `$3A?? / $3B??`. |
| `$1F:$5AC9` | Main-menu init: zeros `$D5FF` | Fires on every main-menu open. |
| `$1F:$5861` | Cursor move (any menu) | Writes the new cursor value to `$D5FF` (main) or `$D600` (sub). |
| `$1F:$5874` | Cursor move opposite direction | Same as `$5861` but the symmetric pair. |
| `$1F:$5AE9` | **Main-menu confirm**: writes the dispatch index | Cursor → dispatch lookup happens here. Picking Ask (cursor 1) wrote `$03`; picking Leave (cursor 2) wrote `$04`; picking Climb (cursor 0) wrote `$01`. |
| `$1F:$5D83` | Ask-submenu init: zeros `$D600` | Fires on every Ask-submenu open. The Ask submenu has **no separate confirm-PC** — dispatch reads the live cursor value. |
| `$1F:$58ED` | **Y/N-menu init**: zeros `$D5FE` | Fires when the Y/N UI (`$07 $D7 $58 $1F` = bank 31 `$58D7`) opens — initial cursor on "Yes". |
| `$1F:$591A` | **Y/N-menu confirm**: writes selection to `$D5FE` | `$00` = Yes, `$01` = No. The script's `$0A $FE $D5 $01 $83 $74` then reads "if user picked No, GOTO menu" — so the YES case is the fall-through (e.g., into ENTER_DUNGEON), which matches Climb's branch shape. |

### What this nails down

- **`$D5FF`** is the main-menu dispatch register, written by `$5AE9` on confirm.
- **`$D5FE`** is the Y/N result register: 0 = Yes, 1 = No. Init at `$1F:$58ED`, confirm at `$1F:$591A`.
- **`$D600`** is the Ask-submenu cursor, read live by dispatch.
- **`$D0DD`** is Naji's NPC-state byte: 0 at boot, →1 after the first-time intro completes (written by the `$09` handler at `$18:$3ACF`).
- **`$D60D`** is the `$0C` (RAND) result byte, written by the `$0C` handler at `$18:$3B09` only when RAND actually fires (i.e., subsequent-visit Naji, not the first-time path).
- **The cursor-to-dispatch lookup** in the main menu maps the visible-cursor positions to the dispatch table, skipping hidden options. With Restart hidden (first-time path, `$CFF0=0`), cursor {0,1,2} → dispatch {1,3,4}; this was confirmed across three picks (Climb cursor 0 → dispatch 1, Ask cursor 1 → dispatch 3, Leave cursor 2 → dispatch 4). Dispatch index 2 (`$75BC`) stays unreachable from the menu cursor regardless.
- **`$0A` operand layout and equality semantics** confirmed again on Naji's Climb-No path: `$0A $FE $D5 $01 $83 $74` fired iff `$D5FE==$01`, jumping to `$7483`.

### What's still open after the trace

- **`$0B` semantics.** Still not pinned down — the first-time menu with `$CFF0=$00` rendered Climb / Ask / Leave (3 options), meaning the first `$0B` skipped Restart but the second `$0B` (same condition!) did *not* skip Ask. Likely needs a quick read of the bank-31 menu render routine or the bank-24 script interpreter at `$3A??/3B??` to settle.
- **Dispatch index 2 (`$75BC`)** is still unexplained — it's valid script content (a `$0A` conditional gating the Tower explanation) but is never reached via the main-menu cursor. Probably reachable from a different upstream caller.

## Open questions

1. **`$0A` vs `$0B` — same compare or different?** Both are 6-byte equality-shape jumps. `$0B` is used to *skip* optional menu items when a state byte is zero; `$0A` is the catch-all conditional everywhere else. They may differ in compare operator (eq vs neq) or in some side-effect like marking a "rendered" flag. A pair of analyzer breakpoints would settle it. (The Naji trace did **not** resolve this — see "What's still open" above.)
2. **`$02` and `$0C` second byte — always `$08`?** Every menu dispatch and every RAND header observed so far has its second byte = `$08`. Could be a "table format" tag, a "default-cursor index", or the number of bits used for the result. Worth checking against a wider sample.
3. **`$0C`'s WRAM source.** Naji's RAND reads `$D60D`. Is that the engine's shared RNG byte, or NPC-specific state? A trace would tell.
4. ~~**Why does Naji's main menu have 5 dispatch entries but only 4 pseudocode options?**~~ **Resolved by trace** — the menu UI has a cursor→dispatch lookup that maps cursor {0,1,2,3} → dispatch {0,1,3,4}; dispatch index 2 (`$75BC`) is not reachable from the cursor.
5. **How does Tower/Item content "GOTO 28" (back to Ask menu)?** Each submenu handler ends with `$09 ... $07 $94 $40 $1F $07 $B7 $6B $18 $FF`. The two `$07` calls plus `$FF` must unwind back into the Ask menu's wait-loop. Probably the bank-31 `$4094` and bank-24 `$6BB7` routines manipulate the script PC / return stack.
6. **`$08` / `$10` operand widths.** Best guesses are above but unconfirmed.
7. ~~**What WRAM bytes do `$D5FE` / `$D5FF` / `$D600` track?**~~ **Resolved by traces** — `$D5FF` = main-menu dispatch register (written by `$1F:$5AE9` on confirm); `$D5FE` = Y/N result (0=Yes, 1=No, written by `$1F:$591A`); `$D600` = Ask-submenu cursor (read live, no confirm write).
8. **What's the `$A5` separator in staff credits?** Probably an attribute byte (text color, palette). Need to compare with how it renders.
9. **How are scripts dispatched?** Some upstream table or instruction sequence picks "use script at `$64392`" — finding that table would unlock automatic mapping from game state → script.
10. **Is Cox's letter at `$4c7ff` really a static text block?** It has no `$04` waits — but it does have `$0D` line breaks. May render as one big scrollable text box, or it's loaded into VRAM as static tiles.

## Why we're not extracting these yet

The encoding is now well-understood enough that a real script-aware
disassembler could be written. The remaining unknowns (`$08`, `$10`,
the `$0A`/`$0B` distinction, the GOTO-28 unwind mechanism) are
narrow enough that they no longer block a first-pass extractor.

What's missing on the extractor side:

1. A new section type (or a `data` annotation language) that lets
   `map.json` mark a script region and emit per-opcode pseudocode
   alongside the bytes, rather than a flat `db` blob.
2. A label model that lets script targets (`$734A`, `$74E2`, …)
   become real RGBASM labels so cross-references resolve cleanly
   inside `analyzed.asm`.
3. A pass that classifies `$07` targets as either Z80 code (so the
   analyzer can pick them up) or script (so they extend the script
   coverage further).

Once those exist, bank-19 (Nox flashback / Letter from Cox) and the
unmapped bank-25 scripts can be extracted with their full structure
preserved.
