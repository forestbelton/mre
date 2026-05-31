# Screen libraries (BG tilemaps)

**Status: identified, deferred.** This documents what a large slice of the
still-unmapped ROM *is*, so we don't keep rediscovering it. We deliberately have
**not** carved these into `map.json` — see "Why deferred" below.

## What they are

A "screen" is a BG-tilemap descriptor in the engine's `CopyBgMap` format (the
same format the TECMO logo and Kalum portrait use):

```
[rows][cols][attr_ptr:LE16][idx_ptr:LE16]   6-byte descriptor
idx map  : rows*cols bytes   tile indices    (immediately after the descriptor)
attr map : rows*cols bytes   CGB attributes
```

so `idx_ptr == descriptor_addr + 6` and `attr_ptr == idx_ptr + rows*cols`.
Descriptors are stored back-to-back in "libraries" — one screen's attr map ends
exactly where the next descriptor begins.

These are **layout only** (1 byte per cell: which tile index, which palette/attr).
They are *not* the tile pixels. The pixels live elsewhere, are shared across many
screens, and are VRAM-loaded — they're what `analyzer --watch-vram` tags as `gfx`.
The two are complementary:

| Analyzer `--watch-vram` pass | This finding |
|---|---|
| tile **pixels** → `gfx` sections | tile **layouts** (which tile goes where) |

Loaded at runtime via `CopyBgMapBankedA` (`$3942`): `ld a,<bank>; ld [$c29c],a;
ld hl,<descriptor>; call $3942`.

## How to find them

`tools/find_screens.py` scans the whole ROM for chained descriptors and reports
the inventory (and, against `src/data/` gap blobs, how much is still unmapped):

```
python3 tools/find_screens.py            # inventory + gap intersection
python3 tools/find_screens.py --json out.json
```

It cross-validates: it independently re-discovers the hand-extracted Kalum
portrait at `$1d:$5880` (and the matching portrait pairs in the other tower-NPC
banks `$1a`/`$1b`/`$1e`), which is strong evidence the descriptor signature is
real, not coincidence. The chaining arithmetic is too constrained to fire by
chance for the larger runs.

## Inventory (snapshot)

**54 libraries, ~65 KB, 400 screens; ~47 KB still in unmapped gaps.** The big,
unmistakable ones (12×20 / 12×32 background dims):

| ROM offset | bank | screens | bytes |
|---|---|---|---|
| `0x030000` | `$0c` | 23 | 14394 |
| `0x0159b2` | `$05` | 10 | 4860 |
| `0x042737` | `$10` | 7 | 3962 |
| `0x0565ce` | `$15` | 10 | 3832 |
| `0x01b20f` | `$06` | 7 | 3402 |
| `0x09197f` | `$24` | 9 | 2970 |
| `0x0af2a2` | `$2b` | 26 | 2824 |
| `0x0a7080` | `$29` | 6 | 2436 |
| `0x04dac5` | `$13` | 7 | 2094 |
| `0x03d2c4` | `$0f` | 3 | 2058 |
| `0x0d3128` | `$34` | 8 | 2028 |
| `0x0ca313` | `$32` | 15 | 1986 |
| `0x02b39d` | `$0a` | 27 | 1838 |

Run the tool for the full list. **Confidence tiers:** the large runs above are
unmistakable. The many tiny `(2,1)`/`(2,2)`/`(3,3)` runs satisfy the chaining
arithmetic but are low-value and possibly coincidental — `find_screens.py` tiers
singletons out separately and `--json` keeps them apart. Note a 0.97 distinct-tile
ratio is *not* a false-positive signal: a portrait legitimately uses near-unique
tiles (Kalum proves it).

A few libraries are entangled with `gfx` sections from the analyzer pass
(`$32:0x0ca313`, `$0f:0x03d138`/`0x03d2c4`) — the tiledata copy boundary
overshot into the adjacent tilemap (the vram log even flags `$32:0x0CA319` as
`mixed`). Those need manual reconciliation if revisited.

## Why deferred

Carving these into `map.json` would relabel the bytes (anonymous gap blob →
`Screen_xx` section) and let load-site code resolve to a screen name. But the
data itself would still emit as an opaque wall of `db $fc, $fc, ...` — that
closes a coverage *metric* without making anything comprehensible, and it would
add hundreds of sections/labels for little readability gain. That's contrary to
the source-project goal (editable asset forms — see `docs/philosophy.md`).

## If revisited: the comprehensible path

The worthwhile end-state is the TECMO/Kalum treatment — each screen rendered as
an **editable PNG** (tilemap + its tiles + palette → an actual picture, via
`tools/gfxasset.py`). The analyzer pass now makes this feasible: its VRAM
provenance logs *which palette* and *which tiledata region* feed each screen, so
the missing piece (linking a screen to its tiles) has a data source. The work is
per-screen and includes that linkage step, so it's a deliberate effort to take
on, not a batch job. Start by rendering a single known screen (e.g. a tower
floor) end-to-end as a proof before scaling.
