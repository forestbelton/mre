# Project philosophy: a *source project*, not just a map

This note records the guiding goal of the disassembly. It's context that shapes
most design decisions, so it's worth stating plainly.

## The bare minimum vs. the actual goal

Stripped to its essentials, a "disassembly" is just **tagging**: deciding which
ROM bytes are code and which are data, and labelling them. If that were the
whole goal, nothing else would be necessary — a map of regions would do.

That is *not* the goal here. We want a **source project** for the ROM:
an approximation of what the original developers' source tree and build system
might have looked like. The ROM is the *output* of a build; we are trying to
recover plausible *inputs*.

## What that implies

- **Assets live in their natural, editable source forms — not raw bytes.**
  A graphic should be a PNG, not a `db`/`INCBIN` blob, because that's how a
  developer would have authored it. The original team drew an image and ran it
  through tooling to bake it into the ROM; our build should do the same. The
  same reasoning applies to tilemaps, palettes, level data, text, etc. — each
  gets a source form that a human would actually want to edit, plus whatever
  tooling is needed to compile it back into bytes.

- **Build our own tooling when the format demands it.** Off-the-shelf tools
  (e.g. `rgbgfx`) may not match this game's specific semantics — its tilemap
  descriptor layout, palette format, addressing mode, CGB attributes. When that
  happens we write our own encoder/decoder so the asset can round-trip from its
  natural source form. Re-creating the devs' toolchain is part of the project,
  not a workaround.

- **References are symbolic, not numeric.** Code and data point at each other
  by *label*, never by hardcoded address. Pointer tables become `dw Label`,
  not `dw $5976`.

## The litmus test: *could* we drop the offsets?

A good rule of thumb for "do we really understand a region?": **could we delete
its explicit section offset and still build a working ROM?** If every
cross-reference into and out of it is symbolic, the answer is yes — the linker
could place it anywhere and all labels would resolve to their new homes. Being
*able* to drop the offset is the sign that a region is genuine source rather
than a frozen blob.

This is a *test*, not the goal. **Byte-exactness is the actual goal and stays
the goal**: reproducing the original ROM byte-for-byte is how we prove our
source has the exact same behaviour as the original, so `make verify` must keep
passing the whole way through. We therefore *keep* a layout that reproduces the
original bytes — we don't actually strip the offsets. The point is only that we
*could*: if we ever wanted a layout-independent build, dropping the offsets
would just work. A region is "fully understood" when its placement has become a
*choice* (symbolic enough to relocate) rather than a *necessity* (bytes pinned
because we can't yet generate them from real source).

## Practical consequences

- Prefer a PNG (+ tooling) over an `INCBIN` of tile bytes; prefer a structured,
  labelled asm/source asset over an opaque `db` blob.
- Prefer `dw Label` over `dw $1234`; prefer named RAM/IO symbols over raw
  addresses.
- It's worth building real tools (custom gfx compilers, text compilers, map
  compilers) rather than freezing bytes in place — every byte we can *generate*
  from source is a byte we understand.
