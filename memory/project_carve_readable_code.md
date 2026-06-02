---
name: project_carve_readable_code
description: How to carve code/data out of auto-generated analyzed.asm into a hand-authored readable src file (room.asm etc.)
metadata:
  type: project
---

Workflow to move a ROM region from the auto-generated `src/analyzed.asm` into a
hand-written, annotated source file (as done for the room records and the bank-0
floor loader in [[project_tower_floor_data]]):

1. **Add a `files[]` entry to `map.json`** (`type:code`, `name:foo.asm`, with a
   `sections[]` covering the byte range). `reconcile_analyzed_sections` in
   `tools/extract.py` then auto-trims those bytes out of analyzed.asm in-memory —
   you do NOT re-run the analyzer. `emit_main` auto-INCLUDEs the new file.
2. **Hand-author the `.asm`** with a `SECTION ... ROM0[$addr]` whose assembled
   bytes exactly reproduce the range. The file is **append-only**: once it exists,
   extract scans its `SECTION` directives and leaves covered ranges alone.
3. **Curated names**: `analyzed.asm` is full-regen, so any label it references
   must be the analyzer's `Func_BB_AAAA` name OR a curated name in `map.json`
   `labels[]`. Add a label there to rename a function in BOTH files at once
   (improves analyzed.asm call sites too). Labels referenced only inside the
   carved file can be named freely.
4. **Byte-exactness is guaranteed by `make verify`** (sha256 vs rom.gbc). A
   1-byte-low diff at many call sites = a label landed at the wrong address
   because the carved file is short/long (a 0x11 offset = a missing 17-byte fn).
   Bytes NOT in any section are auto-emitted as gap-fill `src/data/data_*.bin`
   (gitignored), so undiscovered code can hide there — check the gap-bin list for
   the range and disassemble those bytes too.

`map.json` is cJSON tab-formatted; edit it textually (tabs), not via
`json.dump` (reformats the whole file). See [[project_map_json_hex]].
