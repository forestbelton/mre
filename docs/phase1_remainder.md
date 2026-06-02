# Phase 1 remainder — mapping the last uncovered bytes

Goal of phase 1: classify **every** ROM byte (code / data / gfx / padding) so the
map is complete; phase 2 is the semantic conversion to a real source project.

**Snapshot:** 91.1% covered, **93,265 bytes uncovered** in **1,701 gaps** across 57
banks (`make extract` coverage summary). This note is a *carve plan* for the
remainder: what each gap is (from static analysis) and which tool finishes it.

Regenerate the analysis any time with the scripts described under "Method" — the
exact offsets drift as carving and analyzer runs proceed, so treat the tables as
a snapshot and re-run before acting.

## The split: static vs. runtime trace

Two complementary efforts close the remainder. They don't overlap, so they can
run in parallel:

| Category | Gaps | Bytes | Carve with | Owner |
|---|---:|---:|---|---|
| **gfx? / opaque** | 906 | 60,894 (65%) | runtime VRAM provenance | `analyzer --watch-vram` (play widely) |
| **tilemap-screen** | 115 | 17,739 (19%) | `find_screens` descriptors | static |
| **padding** | 522 | 6,203 (7%) | `find_padding.py` | static |
| **code/table (xref)** | 128 | 5,521 (6%) | targeted by mapped code | static |
| **text** | 28 | 2,908 (3%) | ASCII → `asciz`/data | static |

**~32 KB is statically carve-able now** (screens + padding + code + text). The
remaining **~61 KB is overwhelmingly tile pixel data** — only the analyzer's
VRAM-write provenance can attribute those bytes with confidence (see
`docs/gfx_extraction.md`), so the move is: **play a wide session under
`--watch-vram`** (battles, every floor, menus, shops, encyclopedia, cutscenes)
to reclassify the gfx bulk, and carve the four static categories below by hand.

## 1. Tilemap screens (~17.7 KB, static)

`tools/find_screens.py` chains `CopyBgMap` descriptors statically (no trace
needed). These bytes are **tilemap layout**, not pixels (pixels are the gfx
category). The libraries with bytes still in current gaps, largest first:

| ROM offset | bank:addr | screens | gap bytes |
|---|---|---:|---:|
| `0x030000` | `$0c:$4000` | 23 | 4912 |
| `0x042737` | `$10:$6737` | 7 | 3962 |
| `0x04dac5` | `$13:$5ac5` | 7 | 2094 |
| `0x0d3128` | `$34:$7128` | 8 | 2028 |
| `0x0a7080` | `$29:$7080` | 6 | 824 |
| `0x09197f` | `$24:$597f` | 9 | 660 |
| `0x0565ce` | `$15:$65ce` | 10 | 180 |
| `0x0ca313` | `$32:$6313` | 15 | 180 |
| `0x03ecce` | `$0f:$6cce` | 63 | 180 |
| `0x02b39d` | `$0a:$739d` | 27 | 142 |
| `0x08f6e2` | `$23:$76e2` | 40 | 120 |

For **phase 1** (coverage) these can be carved as plain `data` sections to close
the gap. For **phase 2** the comprehensible end-state is composite PNGs (the
TECMO/screen treatment) — see `docs/screen_libraries.md` ("If revisited"). Bank
`$0c:$4000` (the largest, 23 screens) is almost certainly the **level editor's**
screen set.

## 2. Code & tables reached by mapped code (~5.5 KB, static)

128 gap regions are the target of a `call`/`jp`/`jr`/`ld rr,nn` from
already-mapped code, so they are **definitely code or code-referenced tables** —
and valuable precisely because an unexecuted path won't show up in a runtime
trace. Largest, with the first referencing target:

| gap | bank | bytes | refs | first target | head |
|---|---|---:|---:|---|---|
| `0x0025e5` | `$00` | 1955 | 8 | `0x0026cb` | `3e02ea6ac53e` |
| `0x0c40a1` | `$31` | 488 | 2 | `0x0c40a1` | `2197c23ea322` |
| `0x0037cc` | `$00` | 327 | 3 | `0x003860` | `160058cb2030` |
| `0x062fa5` | `$18` | 219 | 2 | `0x063000` | (NPC script, see §4) |
| `0x00639d` | `$01` | 172 | 4 | `0x00639d` | `f0bcc608cb37` |
| `0x07e457` | `$1f` | 137 | 3 | `0x07e4b8` | `11cb98010409` |
| `0x048368` | `$12` | 117 | 2 | `0x048368` | `cd7d21b7c29a` |
| `0x0008d7` | `$00` | 115 | 3 | `0x000904` | `21dc08180de4` |

…plus ~120 smaller ones (mostly HOME bank `$00`/`$01`). Carve as `code` sections
in `analyzed.asm` (or split into curated files during phase 2). The HOME-bank
ones cluster near already-named routines and are the easiest wins.

## 3. Text (~2.6 KB real, static)

**Confirmed real text** (carve as `asciz`/data):

- **Bank `$17` — level-editor help strings** (~2 KB, `0x05c660`–`0x05df20`):
  "This is a small / room called …", "Select if only / sending a room.",
  "Reverts to open.", "3 monster types / can be placed.", "Sets the speed / of
  the monster.", "Cannot place a / monster there." (column-padded to a fixed
  display width — these are screen-formatted, not control-byte dialogue).
- **Bank `$18` — NPC dialogue** (`0x062e21`, `0x0630e6`, ~270 B): "You climbed
  to / the top again…", "Good work, but / you can't go any / further. To / move
  on, you / need anoth…". These are text-engine scripts (see
  `docs/text_engine.md`); carve alongside the bank-`$18`/`$24` script work.

**False positives to ignore** (the detector's ASCII heuristic trips on tile/OAM
data): bank `$01` `6n6n…`/`.D.D…`/`$H$H…`, and bank `$3e`/`$3f` `.F.F…`/
`t.w.du.iag…` runs — these are graphics/attribute data, not text.

## 4. Padding (~6.2 KB, static)

`tools/find_padding.py` folds runs of `$00`/`$ff` into the padding file so the
coverage stats account for them. 522 gap slivers are pure padding; most are
1–4-byte alignment gaps between sections. Run it last (after the other three
categories carve their content) so it only sweeps up genuine filler.

## 5. The gfx remainder (~61 KB, runtime trace)

The largest opaque blobs — these read as tile pixel data (`$ff` fills, plane
patterns) and need `--watch-vram` to attribute:

| gap | bank | bytes | head |
|---|---|---:|---|
| `0x0fab71` | `$3e` | 5262 | `fd28fc0a63fc` |
| `0x0d08a8` | `$34` | 4096 | `ffffffffffff` |
| `0x035096` | `$0d` | 3244 | `c0c07070243c` |
| `0x034000` | `$0d` | 3144 | `ff7f94524a29` |
| `0x0d28a8` | `$34` | 1785 | `ffffffffffff` |
| `0x04d247` | `$13` | 1742 | `7f7f64636463` |
| `0x0d0000` | `$34` | 1664 | `78a7200521df` |
| `0x04c884` | `$13` | 1377 | `be483b493b49` |

Some of these may be code reached only via jump tables / banked calls / `rst`
(not caught by the direct-xref scan in §2) — the analyzer's execution trace will
separate executed code from gfx. Don't bulk-mark this category as gfx blindly;
let the trace drive it.

## Method (reproduce)

Scripts used to produce the tables (kept ad-hoc under `/tmp` during analysis;
re-derive from these notes):

1. **Gaps:** `extract.find_gaps(validate_map(spec), len(rom))` after
   `normalize_addr_fields` + `reconcile_analyzed_sections` on a fresh
   `json.load(map.json)`.
2. **Screens:** `python3 tools/find_screens.py --json out.json`; a library's
   `offset`/`bytes` give its range, intersect with the gap set.
3. **Xref code:** walk every mapped *code* section's instruction stream (GB
   opcode-length table), collect `jp/call/jr` and `ld rr,nn` targets, resolve
   ROMX `$4000–$7fff` to flat via the section's bank, and keep targets landing
   in a gap.
4. **Text:** gap with ≥45% `[A-Za-z ]` bytes over ≥16 bytes (then eyeball to
   drop tile-data false positives).
5. **Padding:** `tools/find_padding.py`.

## Definition of done (phase 1)

`uncovered (gap-fill .bin)` reaches ~0 in the `make extract` coverage summary —
every byte is in a section with a known kind. Categories 1–4 are carved by hand;
category 5 falls to one or more wide `--watch-vram` sessions. Byte-exactness
(`make verify` → `8f66b59…`) holds throughout.
