# Portrait overlay regions — layered PNG source

How the per-character "overlay" data (the eyes/mouth animation frames, expression
variants, shoulders, hair, etc. drawn on top of a portrait's base background) was
migrated from opaque `db` blobs into **editable, byte-exact layered source**, what
the heuristics are and why, and how to extend the tools for the remaining portraits.

Status (2026-06-10): **pashute, kalum, naji, toamuna, rafaga, tempest done**; bodka
(single-bank) and ferious, nada_intro, nada_scene2 (two-bank) remain. See
[gfx_assets.md](gfx_assets.md) for the broader PNG-asset pipeline and the BG-map
derivation (`derive_portrait_maps`, a separate single-PNG reference flow).

## 1. What an overlay region is

Each portrait's ROM has, right after its `tilemap`/`attrmap`, a contiguous data
region (`Data_<bank>_<addr>`) holding the **animation/expression overlay**: the bits
the render code draws over the base background every frame. It is a run of two block
kinds, interleaved in whatever order the render functions reference them:

- **patch** — a `CopyBgMap` sub-tilemap (BG layer), copied to a fixed VRAM address by
  `BankMapCopyA` (e.g. the mouth/eyes region → `$98xx`). Layout:
  `[rows][cols][attr_ptr LE16][idx_ptr LE16]` + `rows*cols` index bytes + `rows*cols`
  attribute bytes. `idx_ptr = block_addr+6`, `attr_ptr = block_addr+6+rows*cols`
  (absolute pointers — so the region's load address matters; see `base` below).
- **meta** — a `DrawMetasprite` OAM list (OBJ layer): `[count]` +
  `[Yoff,Xoff,tile,attr]*count`, in 8×16 OBJ mode (tiles even, step 2). The render
  code passes a base `bc` position; the stored offsets are relative to it.

The render functions live in `src/text/scripts/<name>.asm` (`<Name>_RenderPortrait*`,
far-called at bank `$18`/`$19`). Read them to learn the **order and role** of every
block — that is the only place the roles are documented.

## 2. The source model: images + metadata

Committed under `assets/portrait/<name>/sprites/`:

- one **PNG per block** — a patch is a `cols*8 × rows*8` RGB image; a metasprite is an
  RGBA image (transparent = OBJ colour 0) of its bounding box.
- **`sprites.yaml`** — the manifest:
  ```yaml
  base: '0x5a3e'          # MUST equal the asm SECTION address (patch pointers are absolute)
  blocks:
    - role: eyes_frame0
      kind: patch
      png: eyes_frame0.png
    - role: hair
      kind: meta
      png: hair.png
      # optional, only when needed:
      # oy: -4            # metasprite placement origin (default 0)
      # ox: 8
      # pal: 5            # forced OBJ palette for an image-irreducible sprite
  ```

`tools/pngasset.py` regenerates the whole region byte-exact from these
(`gen_sprite_region`), writing `build/assets/<name>/sprites.bin`, which the asm
`INCBIN`s in place of the old `db`. The block sizes are computed by walking the
manifest from `base`, so addresses are implicit — reordering blocks just works (as
long as the render code's `ld hl,$addr` still points where each block lands; in
practice the order is fixed by the render code).

### What's derivable vs. metadata

The whole point is that **almost everything is derived from the pixels**. The only
metadata the image genuinely can't carry:

- `base` — the region's load address (needed for the patch pointers).
- `kind`, `role`, block order — structural.
- `oy`/`ox` — a metasprite's placement origin (the min Yoff/Xoff). All-zero for every
  portrait so far, so omitted.
- `pal` — an OBJ palette that several palettes reproduce identically (a monochrome
  sprite). Across all four portraits this was needed **once** (kalum's all-red Selketo
  eye: red lives in OBJ pal 0 and 5). The extractor emits it only when >1 palette
  reproduces every sprite colour.

Everything else — tile indices (including `$8800`-signed BG bytes, duplicate tiles,
blank-padding tiles, freshly-allocated animation runs) and per-cell palettes — is
recovered structurally. The hard-won lesson is that this is **possible** but needs the
right structural model, because the original tool's tile allocation is not a clean
function of the pixels.

## 3. Migration procedure (per portrait)

1. **Find the region & roles.** Read `src/gfx/portrait/<name>.asm` for the
   `Data_<bank>_<addr>` block bounds, and `src/text/scripts/<name>.asm` for the
   `<Name>_RenderPortrait*` functions. Each `ld hl,$addr` + `DrawMetasprite` is a
   meta block; each `ld hl,$addr` + `BankMapCopyA` is a patch. Note the bank
   (`wDrawBank`) and the order.
2. **Add a `PORTRAITS` entry** in `scratch/extract_sprites.py`:
   `name: (rom_bank, base_addr, [(kind, addr, role), ...])`. Walk the blocks first
   (a tiny script that sizes each block and checks they tile the region exactly) to
   confirm kinds/addresses before extracting.
3. **Extract:** `python3 scratch/extract_sprites.py <name>` — carves each block from
   the ROM into a PNG and writes `sprites.yaml`.
4. **Verify regeneration** standalone (import `gen_sprite_region`, compare to the ROM
   slice) — iterate on `pngasset.py` until byte-exact. This is where new structural
   cases show up; see §4.
5. **Wire the build:** add `sprites: sprites/sprites.yaml` to the portrait's
   `assets/assets.yaml` entry; replace the `db` block in `src/gfx/portrait/<name>.asm`
   with `INCBIN "assets/<name>/sprites.bin"` (+ a comment naming the roles). Keep any
   trailing non-overlay bytes as `db` (only pashute had them).
6. **`make verify`** (sha256 `8f66b59…` must be unchanged).
7. **Render** for a human eyeball check (`scratch/render_<name>.py` →
   `scratch/<name>_portrait_4x.png`). Byte-exactness is the real proof; the render
   just catches a wrong mental model and confirms the roles/names. **Stop and let the
   user verify the render before concluding** — don't assert it's correct yourself.
8. **Confirm names with the user**, rename, re-extract, re-verify, commit.

## 4. What we learned — the structural heuristics

The original art tool packed tiles in a way that is *not* a clean function of the
image, so several cases are "image-irreducible" (two byte sequences render
identically). Each was solved by finding the structural invariant the tool used, not
by adding metadata. In `gen_sprite_region`:

### BG patches (`gen_patch`)
- **Tile first, palette second.** Match each cell's tile from pixels independently of
  palette (duplicate tiles share pixels → a *set* of candidate `$8800`-signed bytes),
  then derive the palette from the chosen tile. Choosing palette first lets a wrong
  palette vote force a wrong tile.
- **Column-major base.** Tile bytes follow `byte = base + 8*col + row`; `base` is the
  mode of `(byte − 8*col − row)` over the pinned (unique-candidate) cells.
- **Freshly-allocated bands.** When the column-major base doesn't reach a duplicate
  cell, it belongs to a separate band the tool allocated fresh (e.g. a patch's bottom
  row, or an alt expression reusing a pixel-twin tile). Prefer a candidate within the
  byte range that **the cell's own row's pinned cells span**, over the lowest sheet
  byte.
- **Palette** by 8-neighbour consensus over the pinned cells (region-based), dominant
  fallback.

### OBJ metasprites (`gen_meta`)
- **Complete grid.** A metasprite is a full row-major grid of 8×16 cells; *every* cell
  is a record, including transparent ones (the tool padded rather than pruned).
- **Tile candidates are bytes (`<256`).** `objidx` includes duplicate tiles at index
  ≥256; those aren't valid OBJ byte indices and must be filtered, or genuinely-unique
  cells look ambiguous.
- **Base diagonal + off-diagonal override runs.** Tiles run `+2` in record order along
  `base0 + 2*i`. An animation frame allocates a *contiguous* fresh run for its changed
  cells; one tile in that run can pixel-duplicate a base tile (image-irreducible).
  Resolve an ambiguous cell by an **adjacent off-diagonal pinned neighbour** (the
  override run it belongs to) — `neighbour ∓ 2` — else the base diagonal. Run-length /
  nearest-pinned heuristics fail here because the base run is longer.
- **Override run = a row-major rectangle, not a record-order run.** The changed cells
  form a *rectangle* (e.g. a 2×2 eye block), and the tool reallocates it **row-major**
  (`run_base + 2·rank`). Because the rectangle spans multiple grid rows, its lower rows
  are **not record-adjacent** to a pinned cell (base-diagonal cells sit between them in
  record order), so the `neighbour ∓ 2` rule above can't reach them — it would pick the
  pixel-twin base tile (tempest's `blink_frame1`, recs 7–8). Fix (`gen_meta`): seed each
  run from its pinned off-diagonal cell (top-left = lowest tile), **width-extend right by
  candidate sets** (top-row cells may themselves be ambiguous, so don't require pinned),
  then fill the rectangle's still-ambiguous cells by row-major rank. Stop a row once no
  cell admits its run tile.
- **Blank-padding tiles.** A transparent cell carries no pixels. First infer it from
  the run (`next-opaque − 2`, chained back; `prev + 2` for trailing blanks). Then
  **validate**: a transparent cell's tile must itself be a blank (all-colour-0) tile —
  if the run lands on an opaque tile, the tool instead reused a *shared* blank tile
  (the lowest it had allocated, else the lowest blank in the sheet). Both conventions
  occur (kalum follows the run; toamuna dedups to one blank).
- **Palette** is region-based and often splits **per row** (the distinguishing colour
  can sit at the transparent index, so it's image-irreducible per cell). Fill
  row-uniform (if a row's pinned cells agree) before 8-neighbour consensus, then
  `pal` hint / dominant.

The throughline: **pin what the pixels uniquely determine, then resolve the rest by
the tool's allocation structure** (column-major bands for BG, `+2` diagonal with
off-diagonal override runs for OBJ), and only fall back to metadata for the truly
invisible (`pal`).

## 5. How to edit the tools

### `tools/pngasset.py`
- **`gen_sprite_region(manifest_path, tiles, palbg, palobj)`** — the regenerator. Sets
  up `PBG`/`POBJ` (palette colours), `TPX` (tile→indices), `bgidx` (signed BG byte
  lookup), `objidx` (8×16 OBJ lookup), and `blank_obj` (blank tile set). Walks the
  manifest, calling the two nested generators and accumulating `addr` from `base`.
  - **`gen_patch(img, addr, bank)`** — §4 BG logic. Returns the patch block bytes
    (header with computed `idx_ptr`/`attr_ptr` + idx map + attr map).
  - **`gen_meta(img, oy, ox, bank, pal_hint)`** — §4 OBJ logic. Returns
    `[count]` + records.
  - When a new portrait fails byte-exact, **diff per block** (size-walk the ROM region
    and `sprites.bin` in parallel, dump differing records/idx) to see whether it's a
    tile or palette issue, then extend the relevant generator. Keep the existing four
    passing — re-run the standalone check over all of them after every change.
- **`cmd_portrait`** wires `--sprites <manifest>` into the `portrait` command: it loads
  the tile/palette bins it already produced and appends `sprites.bin` to the outputs.
  The arg is registered in `main()` under the `portrait` subparser.
- Helpers reused: `tile_to_indices`, `rgb555_to_888`. OBJ tiles are 8×16
  (`TPX[T] + TPX[T+1]`). BG uses `$8800` signed addressing
  (`byte b → tiles[b]` if `b≥128` else `tiles[b+256]`).

### `tools/buildassets.py`
- **`build_png_asset(name, spec)`** reads each `assets.yaml` entry and shells out to
  `pngasset.py`. For `mode: portrait`, it already forwards `--reference`/`--rows`/etc.
  for BG-map derivation; the overlay region is added by:
  ```python
  if "sprites" in spec:                          # regenerate the OBJ/BG overlay region
      cmd += ["--sprites", str(spec["sprites"])]
  ```
  So **adding an overlay to a portrait is purely a YAML edit** (`sprites:
  sprites/sprites.yaml`) once the PNGs + manifest exist. No Makefile change.

### `scratch/extract_sprites.py` (migration only, not part of the build)
- One-time carver: ROM → per-block PNGs + manifest. Parametrised by the `PORTRAITS`
  dict (add an entry per new portrait). Emits `oy`/`ox` only when non-zero and `pal`
  only when >1 OBJ palette reproduces every sprite colour. Re-run it after a name
  change to regenerate the PNGs + manifest.

## 6. Gotchas

- **`base` must equal the asm SECTION address** — patch `idx_ptr`/`attr_ptr` are
  absolute. If the section moves, update `base`.
- **Byte-exact is the gate.** `make verify` (sha256 `8f66b59…`) must stay unchanged;
  every tool change must keep all migrated portraits passing, not just the new one.
- **The render is for eyeballing only.** Present it as unverified and let a human
  confirm before concluding — pixel positions/colours are exactly what's easy to
  misjudge and easy for a human to settle.
- **Don't commit until the user confirms the role names** — they've corrected the
  guesses every time (e.g. "mouth" → "eyes"/"face", "shoulder" → "vest", "alt" →
  "smile").
