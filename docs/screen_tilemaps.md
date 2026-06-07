# Screen tilemap libraries — plan (PINNED)

Status: **in progress — inventory done, driver found.** This captures everything
needed to turn the ROM's BG-tilemap "screen libraries" into editable,
comprehensible assets, so the work can be resumed without re-deriving it. The
screens are already mapped as plain `data` (no coverage gap), but turning them
into editable-asset form **is** the north-star (editable assets, end state drops
section offsets — docs/philosophy.md), not optional polish. **Comprehensibility
over coverage; never bulk-emit opaque `db` walls.**

## Inventory (2026-06-07, `scratch/screen_inventory.py`)

Auto-detected back-to-back descriptor runs (≥2) per bank via the invariant
`idx_ptr == desc+6` and `attr_ptr == idx_ptr + rows*cols`:

| bank  | screens | bytes     | notes                                                             |
| ----- | ------- | --------- | ----------------------------------------------------------------- |
| `$05` | 10      | 4860      | 10× 12×20                                                         |
| `$0a` | 27      | 1838      | small (6×4, 10×5, 4×4, 8×4) — some likely false positives         |
| `$0c` | **23**  | **14394** | 1× 12×10, 12× 12×32, 10× 12×20 — **the editor set; proof target** |
| `$0f` | 75      | 4022      | incl. 3× 17×20 + 7× 7×7; many tiny (2×2/2×1) are false positives  |
| `$15` | 10      | 3832      | 4×20, 6× 14×20, 3× 7×6                                            |
| `$23` | 46      | 1930      | mixed small; verify                                               |
| `$2b` | 26      | 2824      | 11× 2×17, 15× 4×16                                                |

~217 raw hits / 33 KB; the **big clean runs** (`$05`,`$0c`,`$15`,`$2b`, the
`$0f` 17×20 and 7×7 sets) are real libraries — the micro-dimension runs need the
back-to-back filter tightened (a descriptor <32 B matches by chance).

## The driver — bank `$05` screen-composition bytecode (KEY FINDING, 2026-06-07)

The bank-`$0c` descriptors are **NOT unused**. They are consumed by a
**screen-composition script** in bank `$05` (~`$5000`–`$54xx`) that is currently
**MISFILED AS `data`** (`Data_05_5058` etc.) — the classic indirect-dispatch-as-
data trap (memory: project_carve_readable_code). A source grep finds no caller
_because the caller isn't disassembled as code_; the link was found by scanning
raw ROM bytes (`scratch/find_screen_refs.py`) for a pointer table of the 23
descriptor start-addresses.

Bytecode structure (`scratch/decode_records.py`):

- **Inner** (~`$05:$5124`): 6-byte records `[page:LE16][dest:LE16=$0060][descriptor_ptr:LE16]`
  whose `descriptor_ptr` field cycles through the bank-`$0c` starts
  (`$40f6 $43fc $4702 … $6238` = the twelve 12×32 screens) — confirmed
  `is_desc($0c, ptr)` for every entry. `fb fc/fd/fe/ff` page-begin ops bracket
  each page group (page field `$05→$06→$07→$08` parallels the `fb` arg).
- **Mid** (`$05:$5058`): header of 7 pointer-pairs into `$70xx–$73xx`.
- **Outer** (`$05:$5000`+): VM ops with sub-script pointers (`$74/$77/$78/$79xx`)
  and literal BG-map destinations (`$4080`/`$4088`).

## The interpreter — bank `$05` scene engine (FOUND, 2026-06-07)
The bytecode is run by a **two-level scene-scripting engine that was ALREADY
disassembled as code** (Func_05_*) — it just had never been connected to the
screen libraries (the Explore agent missed it because the VM never does a literal
`ld a,$0c`; the bank comes from the script). So: the *interpreter* is real code;
the *bytecode* (`Data_05_5058+`) is the opaque-data part to carve.

- `Func_05_4000` — scene **init** (clears `$cf3f`..`$cf64` state, sets up VRAM,
  reads `wSceneState`).
- `Func_05_407d` — per-frame **driver**: runs `Func_05_40e7`→VM1, `Func_05_41fa`→
  VM2, plus scroll/wobble (`Func_05_40b6`) and finalizers.
- **VM1** `Func_05_4103` (loop `Func_05_40f5`, frame-delay `$cf45`, script-ptr
  `$cf41/$cf42`): opcodes `$00`=`Func_05_415a`, `$01`=`4138`(sound), `$02`=`4147`,
  `$03`=`4187`, `$fa`=`41e9`, `$fb`=`41d9`, `$fc`=`41c6`, `$fd`=`41b1`.
- **VM2** `Func_05_4202` (loop `Func_05_41fa`, counter `$cf4f`, script-ptr
  `$cf4b/$cf4c`): opcodes `$00`=`42a8`, `$01`=`4261`(sound), `$03`=`427e`,
  `$04`=`4270`, `$05`=`4242`, `$06`=`4252`, `$07`=`42cd`, `$08`=`42fb`, `$fa`=`4327`.
- Draw handlers (`Func_05_4349/4385/43b1/43db/440c`) write the tilemaps to
  `$9800`/`$9a00` via banked far-calls (`Func_00_0467`/`Func_00_0495`,
  `CopyBgMap`, `BankMapCopyA`/`BankMapCopyB` — the old `CopyBgMapBankedA`/`…B`),
  bank from `$cf4a`, indexed through tables `$05:$4602`/`$460a` keyed by
  `wSceneState`.

**So these "screens" are animated, scripted scenes, not static pictures** — which
reframes the asset question (see Open decisions).

## Carve — all 8 scenes (DONE, 2026-06-07, byte-exact)
All eight scenes (wSceneState 0-7) are carved from the `Data_05_*` db walls into
commented macro form. Bytecode macros live in `include/scene_script.inc`
(`SCENE_BG_*` for VM1, `SCENE_SPR_*` for VM2; each emits the exact opcode bytes).
Each scene's two tracks read as a labelled command list `Scene{N}_VM1` /
`Scene{N}_VM2` (e.g. `SCENE_BG_DRAW $0c,$0060,$720f`,
`SCENE_SPR_SHOW $28,$30,$20,$4d54`, scene 3's backward `SCENE_SPR_JUMP $53ed`
loop). 658 macro calls; `make verify` sha256 unchanged. Commits `fb4ccfc`
(scene 4 + VM) and `1bb42b7` (the other 7).

Method: per-span surgery on `db` lines only — engine code (`Func_05_*`) and the
interleaved metasprite/tilemap data are untouched. Adjacent spans (VM1 end ==
VM2 start) are merged so they don't share a `db` line; `$FE` terminators that sit
in their own 1-byte section are converted in place to `SCENE_*_END`; addresses
are tracked by resyncing at each `Data/Func_05` label (never through code).
Tools: `scratch/scene_disasm.py` (disassembler), `scratch/carve_scenes_v3.py`
(merged-interval splicer; self-verifies bytes per region before writing).

**VM1 opcodes** (Func_05_4103): `$00` BG_DRAW [delay,dest,descptr], `$01` SOUND,
`$02` FLIP, `$03` ROW [delay,src,start,count], `$FA` FARCALL [bank,addr], `$FB`
SCROLL [spd], `$FC`/`$FD` WOBBLE off/on, `$FE` END.
**VM2 opcodes** (Func_05_4202): `$00` SHOW [dur,x,y,list], `$01` SOUND, `$03`
ANIM, `$04` JUMP, `$05`/`$06` LOOP on/off, `$07` MOVE (8 args), `$08` STEP, `$FA`
FARCALL, `$FE` END. (VM2 `$03`/`$07` macros not yet written — no scene needs them
until carved.)

**Next:**
- Convert the root-pointer tables `$05:$461A`/`$462A` (and params
  `$4602/$460A/$4612`) from raw `db` to `dw Scene{N}_VM1` labels so the dispatch
  is self-documenting (currently the scenes are labelled but the tables still
  reference them by raw address).
- The referenced **tilemap descriptors + metasprite lists** are still `db` data
  (the `descptr`/`list` args point at them). Carve those next, or render to PNG
  once palettes/tilesets are traced — this is the remaining path to *editable
  pictures* (the original Open-decisions north-star).
- Name the `$CF40+` scene-engine WRAM fields (script ptrs `$CF41/$CF4B`, delays
  `$CF45/$CF4F`, etc.) and the per-scene param-table semantics
  (`$4602/$460A/$4612`).
- Apply the same VM treatment to the **other screen-library banks** (the
  inventory's `$0a/$0f/$15/$23/$2b` runs) — confirm whether they're driven by
  this same bank-`$05` engine or their own loaders.

## What these are

A large slice of `data`-typed ROM is **`CopyBgMap` screen descriptors** — BG
tilemaps (tile indices + CGB attributes), _not_ tile pixels (those are VRAM tile
data, loaded separately). Each screen:

```
descriptor (6 bytes):  [rows] [cols] [attr_ptr:LE16] [idx_ptr:LE16]
idx  map: rows*cols bytes  (tile indices)   -- at idx_ptr  == descriptor + 6
attr map: rows*cols bytes  (CGB attributes) -- at attr_ptr == idx_ptr + rows*cols
```

Descriptors sit **back-to-back** (one screen's attr map ends where the next
descriptor begins). CGB attribute byte = palette(0-2) | vrambank(3) | xflip(5) |
yflip(6) | priority(7). Confirmed by decoding bank `$0c` (a 12×10 then a run of
12×32 screens; `scratch/screen_probe.py` decodes descriptors).

### Loaders (confirmed)

- `CopyBgMap` (HOME): `ld a,[hl+]→rows; ld a,[hl+]→cols`; on CGB derefs the
  `attr_ptr` into VRAM bank 1, then derefs `idx_ptr` into VRAM bank 0; copies
  `cols` per row, `de += $20` between rows. hl must already point at a
  descriptor in the _currently mapped_ bank.
- Banked path `BankMapCopyA` (`$3942`, per memory): `ld a,<bank>;
ld [$c29c],a; ld hl,<descriptor>; call $3942`.
- The level editor (bank `$12`) draws some screens from its **own** bank — e.g.
  `Func_12_406f`: `hl=$66a4→$9820`, `$66ca→$983f`, `$66f0→$9a20` via `CopyBgMap`.

### Where they live

~54 libraries / ~65 KB / ~400 screens across banks **`$0c`** (the editor's set,
~23), `$05`, `$15`, `$0a`, `$2b`, plus `$0f`/`$23`. Currently raw `data` in
`src/analyzed.asm`.

## What's already done

The **full-screen `$X:$7080` family + NPC portraits** are editable PNGs:

- `assets/screen/{town,tower,tower_open,room_start,room_done,title}/*.png`,
  `assets/intro/intro.png`, `assets/portrait/*`.
- Pipeline: `assets/assets.yaml` lists each; `tools/buildassets.py` runs
  `tools/pngasset.py` per entry → `build/assets/<name>/` (INCBIN'd by `src/gfx/`).
- A `mode: screen` asset = **one PNG** (tile data + palette _derived_ from it) +
  committed **`tilemap.bin`** and **`attrmap.bin`** (the non-derivable maps).
  See docs/gfx_assets.md, docs/philosophy.md.

## The gating dependency (the actual work)

A tilemap is only indices+attributes; to render a **picture** you also need the
screen's **tileset** (2bpp tile pixels in VRAM) and **palettes** (8 BG palettes
of 4 colours). These are set up by the _code that draws the screen_, per context
— so "which tiles + which palette feed screen N" is a **per-screen / per-group
trace** of the VRAM tile load + palette load around each draw site. The old
VRAM-provenance tooling for this was removed and must be re-derived. This trace,
not the tilemap decode, is the real cost — hence **prove one render before
scaling.**

Useful leads: docs/palettes.md (CGB palette system, WRAM shadows `$c101`/`$c141`),
docs/gfx_loaders.md / gfx_catalog.md (identifying raw_gfx sheets),
project_vram_provenance / project_cgb_palettes / project_gfx_loaders in memory.

## Plan (phased)

0. **Inventory** — promote `scratch/screen_probe.py` to a tool that walks each
   bank, decodes every descriptor (addr, rows×cols, idx/attr offsets, size),
   and lists all screens. Cheap; no tileset needed. Gives the full screen map.
1. **Prove one render** (read-only, no source change) — pick one group (the
   editor `$0c` set is the best first target: many partial screens likely
   sharing one tileset+palette). Trace that group's tileset + BG palettes. Build
   a renderer `(descriptor + tileset + palette) → PNG` and validate one screen
   looks correct. _This is the milestone that de-risks everything._
2. **One group → editable assets** — extend `pngasset.py` with a "screen-lib"
   mode (shared tileset, partial/non-full-screen tilemaps; commit
   `tilemap.bin`/`attrmap.bin` per screen, derive/ share the tileset+palette);
   render the whole group to PNGs; add to `assets.yaml`; carve that bank's
   library out of `analyzed.asm` → INCBIN. Confirm `make verify` byte-exact.
3. **Scale** — repeat per group/bank, sharing tilesets where groups share them.

## Open decisions (revisit when resumed)

- **Editable pictures vs comprehensible-as-data.** Full PNG round-trip (phase
  1-3) is the north-star, but a cheaper interim is a _structured_ carve (per
  screen: a label + `rows,cols` + idx/attr as 2-D `db` grids) — comprehensible &
  editable as tilemap data, byte-exact, _no tileset trace needed_. Not opaque
  `db`, but not a picture. Decide per appetite; default is the PNG route.
- How widely tilesets are shared within/across banks (determines grouping).
- Start target: editor `$0c` set (assumed shared tileset) vs another group.

## Guardrails

- Byte-exact always (`make verify`); never bulk-emit opaque `db`.
- Tooling via `tools/`; run from `scratch/*.py`. Surgical asm edits via
  `tools/asmrepl.py`.
