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
| `$06 lo hi` | 2 | **Local call to script** at address `$hilo` in the *same* bank. Often paired with a `$0E` immediately afterwards (see below). The exact semantics aren't pinned down — could be a state-update before the actual subscript dispatch. |
| `$0E lo hi bank` | 3 | **Far call to script**. Calls a subscript at address `$hilo` in bank `bank` (decimal). Example: `$0E 8B 40 19` calls bank-25 `$408B` — almost certainly the engine's main text-display routine, given how often other scripts call into it. |
| `$07 lo hi bank` | 3 | **Far call to Z80 code**. Distinct from `$0E`: the target is not a script byte stream but real machine code. All four `$07` targets in the ranch-welcome script disassemble cleanly as Z80 (e.g., `bank25 $4018` → `ld a, $12; ld hl, $4BB3; call $042E; ld a, ($D5FE); ret; ...`). Used to invoke handler routines that render menu items, perform saves, etc. The menu labels ("Sign", "Confirm", "Exit", "Yes", "No") are **not in the script bytes at all** — they're tile-blitted by the code these calls reach. |

### Control bytes still unknown

These bytes appear in scripts but their operand widths and semantics
haven't been confirmed. The numbers in parentheses are best guesses
based on how many bytes seem to follow before text resumes.

- `$03` (?) — seen once before "Replace previous" prompt
- `$02` (1?) — appears between menu-option calls; possibly "end of option list" or "begin menu" marker
- `$08` (5?) — `$08 ff d5 0f xx xx` likely a conditional jump on WRAM `$D5FF`, same shape as `$0A`
- `$09` (5?) — `$09 dc d0 01 xx xx` likely a conditional jump on WRAM `$D0DC` (e.g., guarding the "Pashute returned" / "Verde returned" branches in the ranch welcome)
- `$10` (?) — only seen once (in the "save data" script, `$10 78`)

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

`$08` and `$09` almost certainly share this 6-byte conditional-jump
shape (differing only in *what* they read or *how* they compare —
not-equal vs equal, perhaps). The WRAM addresses they reference are
all in the `$D0DC` / `$D5FE` / `$D5FF` neighborhood — the game-state
flag block.

To confirm `$08` and `$09`'s exact compare semantics, a live analyzer
trace through each branch would resolve it.

## Script layout

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

### Runtime flow (recorded from gameplay)

The flow downstream of "What do you want to do?" is:

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

### Bank 25 (decimal; ROM offsets `$64000-$67fff`)

Already covered as `data` inside `analyzed.asm`. Identified
scripts:

| Offset | Bytes | Content (first message) |
|---|---|---|
| `$64392` | 332 | "Welcome, stay as / long as you like" — ranch greeting (the worked example above) |
| `$64513` | ~245 | "Want to sign the / guest book?" — guest-book save prompt |
| `$646be` | ~16+ | "Be careful." — short farewell |
| `$0630ca` | ~? | "Be careful, and / good luck." (bank 12, decimal — separate region) |

There are many more scripts in bank 25 — `$06251e`, `$06357d`,
`$0644ab`, `$064540`, `$064615`, `$06457a` were all noticed during the
probe search but not yet mapped. Bank 25 looks like the central
location for ranch / save / town interactions.

### Other text noticed

- Bank 1 menu strings (`$4f5b`-`$4fdc`) — `PAUSE`, `STATUS`, `STAGE-MAP`, `GIVE-UP`, `TOWN`, blank line. 21-byte padded asciz; **no control bytes**. These are display-formatted menu items, not dialogue.
- Bank 1 `$4ff2`: `"     YES    NO      "` — same format, currently uncovered.
- Monster name table at `$3b83` — already extracted (see `src/names.asm`).
- Bank 21 `$5400a`: `"SMALL\0"` — small standalone asciz.

## Open questions

1. **What does `$06 lo hi` actually do?** Always immediately followed by a `$0E ... 19` (bank 25 call) — so the local call could be loading a parameter that the bank-25 routine reads. The `lo hi` operand is some address within the current bank.
2. **`$08` / `$02` / `$10` operand widths.** Best guesses are above but unconfirmed.
3. **What WRAM bytes do `$09 $DCD0` / `$0A $D5FE` / `$08 $D5FF` track?** Likely game-state flags (Pashute returned, Verde returned, currently-signing flag, etc.). A live read-watchpoint via the analyzer on those addresses while playing through the relevant interactions would identify them.
4. **What's the `$A5` separator in staff credits?** Probably an attribute byte (text color, palette). Need to compare with how it renders.
5. **How are scripts dispatched?** Some upstream table or instruction sequence picks "use script at `$64392`" — finding that table would unlock automatic mapping from game state → script.
6. **Is Cox's letter at `$4c7ff` really a static text block?** It has no `$04` waits — but it does have `$0D` line breaks. May render as one big scrollable text box, or it's loaded into VRAM as static tiles.
7. **What's `$04 $FF` at the end of the Exit handler do?** `Be careful.` ends with `$04` (wait for A) immediately followed by `$FF` (end-script) — so the engine waits for A, then unwinds. This is the standard "exit-message" pattern and probably what every leaf script ends with.

## Why we're not extracting these yet

The bank-19 dialogue region is uncovered and would be a clean
conservative add — but until `$07 / $08 / $09 / $0A` are understood,
declaring it as `data` would lose the per-script structure we'd
otherwise want to label. Once the menu/condition ops are decoded,
we can carve scripts out with semantic labels (`Dialog_NoxFlashback`,
`Letter_FromCox`, etc.) and a richer section type (or comment
annotations) that calls out each control sequence.

For now: keep the bytes in their current home (uncovered for bank
19, in `analyzed.asm` for bank 25). Revisit after the analyzer +
runtime traces have nailed down the unknowns.
