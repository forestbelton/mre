#!/usr/bin/env python3
"""Byte-exact (dis)assembler for the MRE sound-data region ($4b00-$7fff).

The driver (docs/sound_engine.md) stores, per bank:
  * $4b00-$4cff  a 256-entry pointer table (offsets rel $4b00 to song descriptors)
  * $4d00-$7fff  song descriptors (12 bytes = 4x [pri,ptr_lo,ptr_hi]) interleaved
                 with per-channel op-streams (notes + commands) and the pattern
                 subroutines they CALL.

This module decodes that region into a flat list of semantic items, then
re-encodes the items back to bytes -- computing note bytes, CALL/GOTO relative
offsets and descriptor/table offsets from the (fixed) label addresses -- and
asserts the result is byte-identical to the ROM.  That proves the semantic
representation captures everything, i.e. it round-trips.

Run `python3 tools/songdisasm.py --verify` to check both banks round-trip.
"""
import sys, argparse
from collections import OrderedDict

ROM_PATH = '/home/case/projects/mre-disasm/rom.gbc'
BASE = 0x4b00          # offsets in the table/descriptors are relative to here
REGION_END = 0x7fff    # song data fills to $7ffe; $7fff is the bank tag (banks.asm)

# column (note & 0x0f) -> semitone offset; 7 & 15 = rest.
COL2SEMI = {0:0, 1:2, 2:4, 3:5, 4:7, 5:9, 6:11,
            8:1, 9:3, 10:5, 11:6, 12:8, 13:10, 14:12}

class Rom:
    def __init__(self, path=ROM_PATH):
        self.d = open(path, 'rb').read()
    def fa(self, bank, a): return bank * 0x4000 + (a - 0x4000)
    def b(self, bank, a):  return self.d[self.fa(bank, a)]
    def w(self, bank, a):  return self.b(bank, a) | (self.b(bank, a + 1) << 8)

def sign16(x): return x - 0x10000 if x >= 0x8000 else x

# ---------------------------------------------------------------------------
# Decoded item types.  Each knows its address and can re-encode to bytes given
# the label->address map (for relative/offset operands).
# ---------------------------------------------------------------------------
class Item:
    def encode(self, addr, labels): raise NotImplementedError
    def size(self): raise NotImplementedError

class TableEntry(Item):           # one $4b00 pointer-table slot
    def __init__(self, target): self.target = target      # descriptor addr
    def size(self): return 2
    def encode(self, addr, labels):
        off = (labels[self.target] - BASE) & 0xffff
        return bytes([off & 0xff, off >> 8])

class Descriptor(Item):           # 12-byte song header: 4x [pri, ptr16-rel-BASE]
    def __init__(self, chans): self.chans = chans          # [(pri, stream_addr)]*4
    def size(self): return 12
    def encode(self, addr, labels):
        out = bytearray()
        for pri, ptr in self.chans:
            off = (labels[ptr] - BASE) & 0xffff
            out += bytes([pri, off & 0xff, off >> 8])
        return bytes(out)

class Note(Item):
    def __init__(self, pan, col, length):      # length None = default-length note
        self.pan, self.col, self.length = pan, col, length
    def size(self): return 1 if self.length is None else 2
    def encode(self, addr, labels):
        b = (self.pan << 5) | self.col
        if self.length is None:
            return bytes([b])
        return bytes([b | 0x10, self.length])

class Cmd(Item):                  # single-opcode or opcode+operand-bytes command
    def __init__(self, op, operands=b''):
        self.op, self.operands = op, bytes(operands)
    def size(self): return 1 + len(self.operands)
    def encode(self, addr, labels): return bytes([self.op]) + self.operands

class Jump(Item):                 # CALL ($f9) / GOTO ($fa): target = addr + rel16
    def __init__(self, op, target): self.op, self.target = op, target
    def size(self): return 3
    def encode(self, addr, labels):
        rel = (labels[self.target] - addr) & 0xffff
        return bytes([self.op, rel & 0xff, rel >> 8])

class Raw(Item):                  # bytes we couldn't classify (should stay empty)
    def __init__(self, data): self.data = bytes(data)
    def size(self): return len(self.data)
    def encode(self, addr, labels): return self.data

# ---------------------------------------------------------------------------
# Disassembly
# ---------------------------------------------------------------------------
def disasm_bank(rom, bank):
    """Return (items, labels, table) where items maps addr->Item (sorted by addr)
    and labels is the set of reference-target addresses needing a name.

    Strategy: the table and descriptors are data at known addresses; op-streams
    are decoded by *reachability* from each descriptor's channel pointers and the
    CALL targets they reach, each followed to its terminator ($ff/$f8/$fa).  Any
    region byte left uncovered is emitted as Raw (expected: none)."""
    decoded = {}        # addr -> (Item, size)
    labels = set()

    # 1. pointer table -> descriptor addresses
    first = rom.w(bank, BASE)
    n_entries = first // 2
    for i in range(n_entries):
        tgt = BASE + rom.w(bank, BASE + 2*i)
        decoded[BASE + 2*i] = (TableEntry(tgt), 2)
        labels.add(tgt)

    # 2. descriptors (12 bytes) at each distinct song address; collect streams
    stream_worklist = []
    for tgt in {e[0].target for a, e in decoded.items() if isinstance(e[0], TableEntry)}:
        chans = []
        for ch in range(4):
            pri = rom.b(bank, tgt + ch*3)
            ptr = BASE + rom.w(bank, tgt + ch*3 + 1)
            chans.append((pri, ptr))
            labels.add(ptr)
            stream_worklist.append(ptr)
        decoded[tgt] = (Descriptor(chans), 12)

    # 3. follow each stream / pattern to its terminator
    seen_stream = set()
    while stream_worklist:
        s = stream_worklist.pop()
        if s in seen_stream:
            continue
        seen_stream.add(s)
        a = s
        while True:
            if a in decoded:            # already decoded (shared/overlapping) -> stop
                break
            it, sz, refs = decode_op(rom, bank, a)
            decoded[a] = (it, sz)
            for r in refs:
                labels.add(r)
                stream_worklist.append(r)
            if isinstance(it, Cmd) and it.op in (0xff, 0xf8):   # END / RET
                break
            if isinstance(it, Jump) and it.op == 0xfa:           # GOTO (terminal)
                break
            a += sz

    # 4. Uncovered bytes are unreferenced ("dead") op-streams left in the data.
    #    Decode them as ops too (for readability); fall back to Raw if they don't
    #    tile the gap cleanly (e.g. genuine padding/data).
    dead = set()
    a = BASE
    while a < REGION_END:
        if a in decoded:
            a += decoded[a][1]
            continue
        run = a
        while run < REGION_END and run not in decoded:
            run += 1
        if decode_gap_ops(rom, bank, a, run, decoded, labels, dead):
            pass
        else:
            decoded[a] = (Raw(rom.d[rom.fa(bank, a):rom.fa(bank, run)]), run - a)
            labels.add(a)
        a = run

    # 5. assemble in address order
    items = OrderedDict()
    a = BASE
    while a < REGION_END:
        it, sz = decoded[a]
        items[a] = it
        a += sz
    table_items = {x: it for x, it in decoded.items() if isinstance(it[0], TableEntry)}
    return items, labels, table_items, dead

def decode_gap_ops(rom, bank, start, end, decoded, labels, dead):
    """Try to decode [start,end) as a sequence of ops that tiles exactly.
    On success, write items into `decoded`, mark `dead`, return True."""
    # an all-$ff gap is padding/alignment, not code -> keep as Raw
    if all(rom.b(bank, x) == 0xff for x in range(start, end)):
        return False
    tmp = {}
    a = start
    try:
        while a < end:
            it, sz, refs = decode_op(rom, bank, a)
            if a + sz > end:
                return False
            tmp[a] = (it, sz)
            a += sz
    except (ValueError, IndexError):
        return False
    if a != end:
        return False
    decoded.update(tmp)
    labels.add(start)
    dead.update(tmp.keys())
    return True

def decode_op(rom, bank, a):
    """Decode one op-stream byte at `a`. Returns (item, size, ref_targets)."""
    b = rom.b(bank, a)
    if b < 0x80:                                   # note
        pan = (b >> 5) & 3
        col = b & 0x0f
        if b & 0x10:
            return Note(pan, col, rom.b(bank, a+1)), 2, ()
        return Note(pan, col, None), 1, ()
    if (b & 0xf0) == 0x90:                          # octave
        return Cmd(b), 1, ()
    if b == 0xf9 or b == 0xfa:                       # CALL / GOTO
        rel = rom.w(bank, a+1)
        tgt = (a + sign16(rel)) & 0xffff
        return Jump(b, tgt), 3, (tgt,)
    # commands with a fixed operand count
    ONE_OPERAND = {0xea, 0xec, 0xed, 0xee, 0xef, 0xfb, 0xfc, 0xfd}
    ZERO_OPERAND = {0xeb, 0xf0, 0xf8, 0xfe, 0xff}
    if b in ONE_OPERAND:
        return Cmd(b, [rom.b(bank, a+1)]), 2, ()
    if b in ZERO_OPERAND:
        return Cmd(b), 1, ()
    if 0xf1 <= b <= 0xf7:                            # reserved (jp self)
        return Cmd(b), 1, ()
    raise ValueError(f"bank ${bank:02x} ${a:04x}: unknown op ${b:02x}")

# ---------------------------------------------------------------------------
# Verification: re-encode and compare to ROM
# ---------------------------------------------------------------------------
def reencode(items, labels_addr):
    out = bytearray()
    addr = BASE
    for a, it in items.items():
        assert a == addr, f"layout gap: item @ ${a:04x} but cursor ${addr:04x}"
        out += it.encode(a, labels_addr)
        addr += it.size()
    return bytes(out), addr

def verify_bank(rom, bank):
    items, labels, table, dead = disasm_bank(rom, bank)
    labels_addr = {x: x for x in labels}      # identity: layout is fixed
    data, end = reencode(items, labels_addr)
    orig = rom.d[rom.fa(bank, BASE):rom.fa(bank, REGION_END)]
    ok = data == orig
    nraw = sum(1 for it in items.values() if isinstance(it, Raw))
    print(f"bank ${bank:02x}: {len(items)} items, region ${BASE:04x}-${end-1:04x}, "
          f"{len(labels)} labels, {len(dead)} dead-pattern ops, {nraw} raw runs "
          f"-> {'OK byte-exact' if ok else 'MISMATCH'}")
    if not ok:
        for i, (x, y) in enumerate(zip(data, orig)):
            if x != y:
                print(f"  first diff at offset {i} (${BASE+i:04x}): got {x:02x} want {y:02x}")
                break
        if len(data) != len(orig):
            print(f"  length mismatch: got {len(data)} want {len(orig)}")
    return ok

# ---------------------------------------------------------------------------
# Emit readable RGBDS macro source (byte-exact via include/snd_song.inc)
# ---------------------------------------------------------------------------
COL_NAME = {0:'SC_C',1:'SC_D',2:'SC_E',3:'SC_F',4:'SC_G',5:'SC_A',6:'SC_B',
            7:'SC_REST',8:'SC_CS',9:'SC_DS',10:'SC_ES',11:'SC_FS',12:'SC_GS',
            13:'SC_AS',14:'SC_BS',15:'SC_REST2'}
COL_LETTER = {0:'C',1:'D',2:'E',3:'F',4:'G',5:'A',6:'B',7:'rest',8:'C#',9:'D#',
              10:'E#',11:'F#',12:'G#',13:'A#',14:'B#',15:'rest'}

def lname(bank, a): return f"Snd_{bank:02x}_{a:04x}"

CMD_MACRO = {0xea:'s_wave',0xec:'s_setloop',0xed:'s_dutyenv',0xee:'s_sweep',
             0xef:'s_set10',0xfb:'s_pitchenv',0xfc:'s_instr',0xfd:'s_deflen'}
CMD_NOOP  = {0xeb:'s_loopback',0xf0:'s_nop',0xf8:'s_ret',0xfe:'s_keyon',0xff:'s_end'}

def emit_item(bank, a, it, labels, dead):
    """Return list of source lines for one item (without its own label line)."""
    if isinstance(it, TableEntry):
        return [f"\ts_songptr {lname(bank, it.target)}"]
    if isinstance(it, Descriptor):
        out = []
        for ch, (pri, ptr) in enumerate(it.chans):
            out.append(f"\ts_chan ${pri:02x}, {lname(bank, ptr)}")
        return out
    if isinstance(it, Note):
        c = COL_NAME[it.col]; letter = COL_LETTER[it.col]
        if it.pan == 3 and it.length is None:
            return [f"\ts_note {c:<8}\t; {letter}"]
        if it.pan == 3:
            return [f"\ts_note_l {c}, {it.length}\t; {letter} dur={it.length}"]
        if it.length is None:
            return [f"\ts_note_p {it.pan}, {c}\t; {letter} pan={it.pan}"]
        return [f"\ts_note_pl {it.pan}, {c}, {it.length}\t; {letter} pan={it.pan} dur={it.length}"]
    if isinstance(it, Jump):
        m = 's_call' if it.op == 0xf9 else 's_goto'
        return [f"\t{m} {lname(bank, it.target)}"]
    if isinstance(it, Cmd):
        op = it.op
        if (op & 0xf0) == 0x90:
            return [f"\ts_oct {op & 0x0f}\t; block {(op & 0x0f) - 1}"]
        if op in CMD_MACRO:
            return [f"\t{CMD_MACRO[op]} {it.operands[0]}"]
        if op in CMD_NOOP:
            return [f"\t{CMD_NOOP[op]}"]
        if 0xf1 <= op <= 0xf7:
            return [f"\ts_rawcmd ${op:02x}"]
    if isinstance(it, Raw):
        d = it.data
        if d and all(b == 0xff for b in d):        # trailing $ff padding
            return [f"\tds {len(d)}, $ff"]
        if len(d) > 1 and all(b == 0xff for b in d[:-1]):
            return [f"\tds {len(d) - 1}, $ff", f"\tdb ${d[-1]:02x}"]
        return ["\tdb " + ", ".join(f"${b:02x}" for b in d)]
    raise ValueError(f"cannot emit {it}")

# Known sound-id roles (for file/section header comments only). See
# docs/sound_engine.md for the full table.
ID_NAMES = {
    0x00:'silence / stop', 0x04:'UI cursor move', 0x05:'item use',
    0x0d:'UI confirm', 0x25:'player lift', 0x28:'BGM silence / stop',
    0x29:'room', 0x2f:'town', 0x31:'room transition (between floors)',
    0x32:'Pashute', 0x33:'Verde', 0x34:'Toamuna', 0x35:'monster regen',
    0x36:'rival encounter', 0x37:'title', 0x38:'intro',
}

def bank_meta(rom, bank):
    """Return (items, labels, dead, descr_id, ids_lo, n_entries)."""
    items, labels, _table, dead = disasm_bank(rom, bank)
    n_entries = sum(1 for it in items.values() if isinstance(it, TableEntry))
    ids_lo = 0x00 if bank == 0x3f else 0x2f
    descr_id = {}
    for i in range(n_entries):
        descr_id.setdefault(items[BASE + 2*i].target, ids_lo + i)
    return items, labels, dead, descr_id, ids_lo, n_entries

def render_table(bank, items, descr_id, ids_lo, n_entries):
    """Lines for the $4b00 pointer table (runs of identical pointers via REPT)."""
    L = [f"{lname(bank, BASE)}:\t\t; $4b00 song pointer table ({n_entries} entries)"]
    addrs = [BASE + 2*i for i in range(n_entries)]
    i = 0
    while i < len(addrs):
        tgt = items[addrs[i]].target
        j = i
        while j < len(addrs) and items[addrs[j]].target == tgt:
            j += 1
        run = j - i
        if run >= 4:
            L.append(f"\tREPT {run}  ; ids ${ids_lo + i:02x}-${ids_lo + j - 1:02x} "
                     f"-> id ${descr_id.get(tgt):02x} (default)")
            L.append(f"\t\ts_songptr {lname(bank, tgt)}")
            L.append("\tENDR")
        else:
            for k in range(i, j):
                L.append(f"\ts_songptr {lname(bank, items[addrs[k]].target)}"
                         f"\t; id ${ids_lo + k:02x}")
        i = j
    return L

def render_one(bank, a, it, labels, dead, descr_id):
    """Lines for one non-table item: optional banner + label, then the macro."""
    L = []
    if a in labels:
        if isinstance(it, Descriptor):
            sid = descr_id.get(a)
            L.append("")
            L.append(f"; ===== sound id ${sid:02x} =====" if sid is not None
                     else "; ===== song =====")
        tag = "\t; unused/dead pattern" if a in dead else ""
        L.append(f"{lname(bank, a)}:{tag}")
    L += emit_item(bank, a, it, labels, dead)
    return L

def song_ranges(items, descr_id):
    """(sid, lo, hi) per song, in ascending address order; hi exclusive."""
    descrs = sorted(a for a, it in items.items() if isinstance(it, Descriptor))
    out = []
    for idx, lo in enumerate(descrs):
        hi = descrs[idx + 1] if idx + 1 < len(descrs) else REGION_END
        out.append((descr_id[lo], lo, hi))
    return out

def emit_bank(rom, bank):
    """Monolithic single-file source for a bank (used by the round-trip check)."""
    items, labels, dead, descr_id, ids_lo, n = bank_meta(rom, bank)
    L = [f"; Auto-generated by tools/songdisasm.py. Song/SFX data for bank "
         f"${bank:02x}. See include/snd_song.inc.", "",
         f'SECTION "snd_data_{bank:02x}", ROMX[$4b00], BANK[${bank:02x}]', ""]
    L += render_table(bank, items, descr_id, ids_lo, n)
    for a in sorted(items):
        if not isinstance(items[a], TableEntry):
            L += render_one(bank, a, items[a], labels, dead, descr_id)
    return "\n".join(L) + "\n"

def emit_split(rom, srcdir):
    """Write per-song files under <srcdir>/sound/{sfx,bgm}/ plus per-bank glue
    files <srcdir>/sound/bank_3{e,f}.asm (SECTION + pointer table + INCLUDEs)."""
    import os
    root = os.path.join(srcdir, 'sound')
    for sub in ('sfx', 'bgm'):
        os.makedirs(os.path.join(root, sub), exist_ok=True)
    written = []
    for bank in (0x3f, 0x3e):
        items, labels, dead, descr_id, ids_lo, n = bank_meta(rom, bank)
        ranges = song_ranges(items, descr_id)
        includes = []
        for sid, lo, hi in ranges:
            kind = 'sfx' if sid <= 0x27 else 'bgm'
            name = f"{kind}_{sid:02x}.asm"
            rel = f"sound/{kind}/{name}"
            includes.append(rel)
            role = ID_NAMES.get(sid, '?')
            body = [
                f"; Sound id ${sid:02x} ({kind.upper()}) -- {role}",
                f"; Bank ${bank:02x}, ROM ${lo:04x}-${hi-1:04x}. "
                f"Auto-generated by tools/songdisasm.py --split; INCLUDEd by "
                f"sound/bank_{bank:02x}.asm into its $4b00 section.",
            ]
            for a in sorted(items):
                if lo <= a < hi and not isinstance(items[a], TableEntry):
                    body += render_one(bank, a, items[a], labels, dead, descr_id)
            path = os.path.join(root, kind, name)
            open(path, 'w').write("\n".join(body) + "\n")
            written.append(path)
        # per-bank glue
        glue = [
            f"; Song/SFX data for sound driver bank ${bank:02x} "
            f"(ids ${ids_lo:02x}-${ids_lo + (0x2e if bank==0x3f else 0xb):02x}).",
            f"; The $4b00 pointer table + one INCLUDE per song (address order).",
            f"; Auto-generated by tools/songdisasm.py --split.", "",
            f'SECTION "snd_data_{bank:02x}", ROMX[$4b00], BANK[${bank:02x}]', "",
        ]
        glue += render_table(bank, items, descr_id, ids_lo, n)
        glue.append("")
        for rel in includes:
            glue.append(f'INCLUDE "{rel}"')
        path = os.path.join(root, f"bank_{bank:02x}.asm")
        open(path, 'w').write("\n".join(glue) + "\n")
        written.append(path)
    return written

if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--verify', action='store_true')
    ap.add_argument('--emit', metavar='BANK', help='emit single-file source for a bank (3f/3e) to stdout')
    ap.add_argument('--split', metavar='SRCDIR', help='write per-song files under SRCDIR/sound/')
    args = ap.parse_args()
    rom = Rom()
    if args.emit:
        print(emit_bank(rom, int(args.emit, 16)), end='')
    elif args.split:
        for p in emit_split(rom, args.split):
            print(f"wrote {p}")
    else:
        ok = all(verify_bank(rom, b) for b in (0x3f, 0x3e))
        sys.exit(0 if ok else 1)
