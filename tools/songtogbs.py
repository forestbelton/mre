#!/usr/bin/env python3
"""Produce a GBS (Game Boy Sound) file that plays one MRE sound.

A GBS embeds the *real* driver code + song data and is played by a GB-emulating
GBS player (CPU + APU + MBC) that calls INIT once and PLAY each frame -- so this
is the bit-exact "listen" companion to the byte-exact editable source (the source
of truth stays src/sound/...; see docs/sound_engine.md).

Given a song file (src/sound/{sfx,bgm}/*.asm), this:
  1. reads the file header for the sound id, kind (SFX/BGM) and driver bank;
  2. lifts that bank's 16 KB ($4000-$7fff, driver + $4b00 table + song bytecode)
     out of the built ROM and patches its $7fff bank-tag byte to $01 (the driver
     stores that tag per voice and re-banks to it each frame -- see
     Func_*_40d2 -- so it must equal the GBS bank we place the data in);
  3. prepends a tiny INIT/PLAY stub and writes the GBS.

The stub bank is GBS bank 0 ($0000-$3fff); the patched sound bank is GBS bank 1
($4000-$7fff), so the driver's absolute $4xxx addressing just works.

Usage:  python3 tools/songtogbs.py src/sound/bgm/bgm_2a.asm [-o out.gbs] [--rom build/rom.gbc]
"""
import argparse, os, re, sys

LOAD = 0x0400          # GBS load address; data[0] -> $0400
INIT = 0x0400
PLAY = 0x0420
SP   = 0xfffe
GBS_BANK = 0x01        # GBS bank the sound data is placed in (bank 1)

def parse_song_file(path):
    """Return (id, kind, bank, local_index, role) from the file's header."""
    head = ""
    with open(path) as f:
        for _ in range(4):
            head += f.readline()
    m_id   = re.search(r"id \$([0-9a-fA-F]{2})", head)
    m_kind = re.search(r"\((SFX|BGM)\)", head)
    m_bank = re.search(r"[Bb]ank \$([0-9a-fA-F]{2})", head)
    m_role = re.search(r"--\s*(.+?)\s*$", head, re.M)
    if not (m_id and m_kind and m_bank):
        raise SystemExit(f"{path}: could not parse sound id/kind/bank from header")
    sid  = int(m_id.group(1), 16)
    kind = m_kind.group(1)
    bank = int(m_bank.group(1), 16)
    local = sid if bank == 0x3f else sid - 0x2f      # index into the $4b00 table
    role = m_role.group(1) if m_role else "?"
    return sid, kind, bank, local, role

def read_bank(rom_path, bank):
    rom = open(rom_path, "rb").read()
    off = bank * 0x4000
    data = bytearray(rom[off:off + 0x4000])
    if len(data) != 0x4000:
        raise SystemExit(f"{rom_path}: bank ${bank:02x} out of range (ROM too small?)")
    return data

def make_stub(local, kind):
    """Hand-assembled INIT/PLAY (LOAD=$0400). INIT at $0400, PLAY at $0420."""
    start_tramp = 0x06 if kind == "BGM" else 0x09   # $4006 tracked / $4009 transient
    init = bytes([
        0x3e, GBS_BANK,          # ld a, $01
        0xea, 0x00, 0x20,        # ld [$2000], a      ; select GBS bank 1 (sound bank)
        0xcd, 0x00, 0x40,        # call $4000         ; Sound_Reset
        0x3e, local & 0xff,      # ld a, local_index
        0xcd, start_tramp, 0x40, # call $4006/$4009   ; Sound_Start(Tracked)
        0xc9,                    # ret
    ])
    play = bytes([
        0x3e, GBS_BANK,          # ld a, $01
        0xea, 0x00, 0x20,        # ld [$2000], a
        0xcd, 0x03, 0x40,        # call $4003         ; Sound_Update
        0xc9,                    # ret
    ])
    bank0 = bytearray(b"\x00" * 0x4000)
    bank0[INIT - LOAD:INIT - LOAD + len(init)] = init
    assert PLAY - LOAD >= INIT - LOAD + len(init), "stub overlap"
    bank0[PLAY - LOAD:PLAY - LOAD + len(play)] = play
    # only $0400-$3fff is ours; the leading $0400 bytes are the player's
    return bank0[:0x4000 - (LOAD)]   # data covering $0400..$3fff

def gbs_header(title, author, copyright_):
    def field(s): return s.encode("ascii", "replace")[:32].ljust(32, b"\x00")
    h = bytearray(0x70)
    h[0:3] = b"GBS"
    h[3] = 1                       # version
    h[4] = 1                       # number of songs
    h[5] = 1                       # first song (1-based)
    h[6:8]   = LOAD.to_bytes(2, "little")
    h[8:10]  = INIT.to_bytes(2, "little")
    h[10:12] = PLAY.to_bytes(2, "little")
    h[12:14] = SP.to_bytes(2, "little")
    h[14] = 0                      # TMA (timer modulo)
    h[15] = 0                      # TAC = 0 -> PLAY at VBlank rate (~59.7 Hz)
    h[16:48]  = field(title)
    h[48:80]  = field(author)
    h[80:112] = field(copyright_)
    return bytes(h)

def build_gbs(song_path, rom_path):
    sid, kind, bank, local, role = parse_song_file(song_path)
    sound_bank = read_bank(rom_path, bank)
    sound_bank[0x3fff] = GBS_BANK          # patch $7fff bank tag -> GBS bank 1

    stub = make_stub(local, kind)          # $0400..$3fff (bank 0 tail)
    # data region (loaded at $0400): stub, padding, then the sound bank at $4000.
    data = bytearray(stub)
    pad_to = 0x4000 - LOAD                  # offset of $4000 within the data
    assert len(data) <= pad_to
    data += b"\x00" * (pad_to - len(data))
    data += sound_bank                      # -> GB $4000..$7fff

    title = f"{kind} {sid:#04x} {role}".strip()
    header = gbs_header(title, "Tecmo", "Tecmo / Monster Rancher Explorer")
    return header + bytes(data), (sid, kind, bank, local, role)

if __name__ == "__main__":
    ap = argparse.ArgumentParser(description="Build a GBS that plays one MRE sound.")
    ap.add_argument("song", help="path to a song file, e.g. src/sound/bgm/bgm_2a.asm")
    ap.add_argument("-o", "--out", help="output .gbs path (default: <stem>.gbs)")
    ap.add_argument("--rom", default=None,
                    help="ROM to lift the bank from (default: build/rom.gbc, else rom.gbc)")
    args = ap.parse_args()

    rom_path = args.rom or next((p for p in ("build/rom.gbc", "rom.gbc") if os.path.exists(p)), None)
    if not rom_path or not os.path.exists(rom_path):
        raise SystemExit("no ROM found; build it (`make`) or pass --rom")

    blob, (sid, kind, bank, local, role) = build_gbs(args.song, rom_path)
    out = args.out or (os.path.splitext(os.path.basename(args.song))[0] + ".gbs")
    with open(out, "wb") as f:
        f.write(blob)
    print(f"{out}: sound ${sid:02x} ({kind}, {role}) from bank ${bank:02x} "
          f"local idx ${local:02x} via {rom_path} -- {len(blob)} bytes")
