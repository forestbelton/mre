#!/usr/bin/env python3
"""Frame-accurate channel-VM emulator for MRE songs (analysis / listening aid).

The game's sound driver (banks $3f/$3e, see docs/sound_engine.md) stores songs
as per-channel bytecode streams.  This tool emulates each of a song's 4 channel
VMs frame-by-frame (the driver ticks at ~60 Hz) to flatten the bytecode -- notes,
durations, instruments, octaves, loops, CALL/RET, GOTO -- into a per-channel
note-event timeline (`--dump`).

It is an *analysis* tool: the canonical editable form of the songs is the
byte-exact macro source produced by tools/songdisasm.py (see docs/sound_engine.md
"editable source").  A tracker (XM) export from this timeline was considered but
rejected -- it cannot round-trip to the exact ROM bytecode; a GBS register-replay
export is the bit-exact listening route if one is ever wanted.
"""
import sys, math, struct, argparse

ROM_PATH = '/home/case/projects/mre-disasm/rom.gbc'

# ---------------------------------------------------------------------------
# ROM access
# ---------------------------------------------------------------------------
class Rom:
    def __init__(self, path=ROM_PATH):
        self.data = open(path, 'rb').read()
    def flat(self, bank, addr):
        return bank * 0x4000 + (addr - 0x4000)
    def b(self, bank, addr):
        return self.data[self.flat(bank, addr)]
    def w(self, bank, addr):                       # 16-bit little-endian
        return self.b(bank, addr) | (self.b(bank, addr + 1) << 8)

# ---------------------------------------------------------------------------
# Pitch / note mapping (from the $442e frequency table, equal temperament)
# ---------------------------------------------------------------------------
# column (note & 0x0f) -> semitones above the block's C.  7 & 15 = rest.
COL2SEMI = {0:0, 1:2, 2:4, 3:5, 4:7, 5:9, 6:11,
            8:1, 9:3, 10:5, 11:6, 12:8, 13:10, 14:12}
REST_COLS = (7, 15)

def note_midi(block, col):
    """block = octave register (set by $9x as nibble-1). block1/col0 = C2 = 36."""
    return 12 * (block + 2) + COL2SEMI[col]

NOTE_NAMES = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B']
def midi_name(m):
    return f"{NOTE_NAMES[m % 12]}{m // 12 - 1}"

# ---------------------------------------------------------------------------
# Song / pattern table
# ---------------------------------------------------------------------------
def song_table(rom, bank):
    """Return {id: descriptor_addr} for this bank's $4b00 pointer table."""
    first = rom.w(bank, 0x4b00)
    n = first // 2
    return {i: 0x4b00 + rom.w(bank, 0x4b00 + 2*i) for i in range(n)}

def descriptor(rom, bank, addr):
    """4 channel records [pri, ptr_lo, ptr_hi]; ptr = offset rel $4b00."""
    out = []
    for ch in range(4):
        base = addr + ch*3
        pri = rom.b(bank, base)
        ptr = 0x4b00 + rom.w(bank, base + 1)
        out.append((pri, ptr))
    return out

# ---------------------------------------------------------------------------
# Stage 1: channel VM emulator
# ---------------------------------------------------------------------------
class Note:
    __slots__ = ('start', 'dur', 'midi', 'rest', 'instr', 'duty', 'wave', 'pan')
    def __init__(self, start, dur, midi, rest, instr, duty, wave, pan):
        self.start, self.dur, self.midi, self.rest = start, dur, midi, rest
        self.instr, self.duty, self.wave, self.pan = instr, duty, wave, pan
    def __repr__(self):
        n = 'rest' if self.rest else midi_name(self.midi)
        return f"@{self.start:4d}+{self.dur:<3d} {n:5s} instr={self.instr} duty={self.duty} wave={self.wave} pan={self.pan}"

class ChannelVM:
    """Emulates one channel's bytecode stream, frame by frame."""
    def __init__(self, rom, bank, start, ch):
        self.rom, self.bank, self.ch = rom, bank, ch
        self.pc = start
        self.start = start
        self.deflen = 1
        self.block = 0
        self.instr = 0          # $fc volume-envelope index
        self.duty = None        # $ed duty-env index (pulse), else None
        self.wave = None        # $ea wave index (CH3)
        self.pitchenv = None    # $fb index
        self.pan = 3            # bits 5-6 of note (default LR=center)
        self.ret = None         # single-slot call return (driver has only +$12/13)
        self.loop_cnt = 0
        self.loop_pc = None
        self.notes = []         # emitted Note events
        self.countdown = 0      # frames until next event read
        self.done = False
        self.goto_frame = None  # frame at which the first GOTO fired (loop end)
        self.goto_target = None

    def _emit(self, frame, col):
        rest = col in REST_COLS
        midi = None if rest else note_midi(self.block, col)
        self.notes.append(Note(frame, 0, midi, rest, self.instr,
                               self.duty, self.wave, self.pan))
        return self.notes[-1]

    def step_frame(self, frame):
        """Advance one frame.  Reads bytecode when the current note expires."""
        if self.done:
            return
        if self.countdown > 0:
            self.countdown -= 1
            return
        # countdown expired -> process bytecode until the next note sets a duration
        rom, bank = self.rom, self.bank
        guard = 0
        while True:
            guard += 1
            if guard > 10000:
                self.done = True
                return
            b = rom.b(bank, self.pc)
            if b == 0xff:                          # END
                self.done = True
                return
            if b < 0x80:                           # NOTE
                col = b & 0x0f
                self.pan = (b >> 5) & 3
                if b & 0x10:
                    dur = rom.b(bank, self.pc + 1)
                    self.pc += 2
                else:
                    dur = self.deflen
                    self.pc += 1
                ev = self._emit(frame, col)
                ev.dur = dur
                self.countdown = dur - 1           # this frame counts as the first
                return
            # ---- command ----
            if (b & 0xf0) == 0x90:                 # octave / block
                self.block = (b & 0x0f) - 1
                self.pc += 1
            elif b == 0xea:                        # wave select (CH3)
                self.wave = rom.b(bank, self.pc + 1); self.pc += 2
            elif b == 0xeb:                        # loop back
                if self.loop_cnt:
                    self.loop_cnt -= 1
                    self.pc = self.loop_pc
                else:
                    self.pc += 1
            elif b == 0xec:                        # set loop count + point
                self.loop_cnt = rom.b(bank, self.pc + 1)
                self.pc += 2
                self.loop_pc = self.pc             # loop point = after the operand
            elif b == 0xed:                        # duty/length envelope
                self.duty = rom.b(bank, self.pc + 1); self.pc += 2
            elif b == 0xee:                        # CH1 sweep (NR10)
                self.pc += 2
            elif b == 0xef:                        # set +$10
                self.pc += 2
            elif b == 0xf0:                        # nop/marker
                self.pc += 1
            elif 0xf1 <= b <= 0xf7:                # reserved (jp self) -> treat as end
                self.done = True
                return
            elif b == 0xf8:                        # RET
                self.pc = self.ret if self.ret is not None else self.pc + 1
            elif b == 0xf9:                        # CALL
                rel = rom.w(bank, self.pc + 1)
                self.ret = self.pc + 3
                self.pc = (self.pc + sign16(rel)) & 0xffff
            elif b == 0xfa:                        # GOTO (loop)
                rel = rom.w(bank, self.pc + 1)
                tgt = (self.pc + sign16(rel)) & 0xffff
                if self.goto_frame is None:
                    self.goto_frame = frame
                    self.goto_target = tgt
                self.pc = tgt
            elif b == 0xfb:                        # pitch envelope
                self.pitchenv = rom.b(bank, self.pc + 1); self.pc += 2
            elif b == 0xfc:                        # instrument (volume env)
                self.instr = rom.b(bank, self.pc + 1); self.pc += 2
            elif b == 0xfd:                        # default note length
                self.deflen = rom.b(bank, self.pc + 1); self.pc += 2
            elif b == 0xfe:                        # key-on flag
                self.pc += 1
            else:
                self.pc += 1

def sign16(x):
    return x - 0x10000 if x >= 0x8000 else x

def emulate_song(rom, bank, addr, max_frames=8192):
    """Emulate all 4 channels.  Returns (channels, total_frames, loop_frames)."""
    chans = []
    for ch, (pri, ptr) in enumerate(descriptor(rom, bank, addr)):
        if pri == 0xff:
            chans.append(None)            # silent channel
        else:
            chans.append(ChannelVM(rom, bank, ptr, ch))
    # First pass: find each channel's natural loop length (first GOTO frame).
    loop_lens = []
    f = 0
    while f < max_frames:
        active = False
        for vm in chans:
            if vm and not vm.done and vm.goto_frame is None:
                vm.step_frame(f)
                active = True
        if not active:
            break
        # stop once every (looping) channel has hit its first GOTO
        if all((vm is None) or vm.done or vm.goto_frame is not None for vm in chans):
            break
        f += 1
    for vm in chans:
        if vm:
            loop_lens.append(vm.goto_frame if vm.goto_frame is not None
                             else len_of_finished(vm))
    real = [l for l in loop_lens if l]
    if real:
        total = 1
        for l in real:
            total = lcm(total, l)
        total = min(total, max_frames)
    else:
        total = min(max(loop_lens or [0]), max_frames) or 64
    # Second pass: fresh emulation for `total` frames, channels wrap on GOTO.
    chans = []
    for ch, (pri, ptr) in enumerate(descriptor(rom, bank, addr)):
        chans.append(None if pri == 0xff else ChannelVM(rom, bank, ptr, ch))
    for f in range(total):
        for vm in chans:
            if vm and not vm.done:
                vm.step_frame(f)
    return chans, total, real

def len_of_finished(vm):
    if not vm.notes:
        return 0
    last = vm.notes[-1]
    return last.start + last.dur

def lcm(a, b):
    return a * b // math.gcd(a, b) if a and b else (a or b)

# ---------------------------------------------------------------------------
# dump mode
# ---------------------------------------------------------------------------
def dump(rom, bank, sid):
    addr = song_table(rom, bank)[sid]
    chans, total, loops = emulate_song(rom, bank, addr)
    print(f"song bank ${bank:02x} id ${sid:02x} @ ${addr:04x}: "
          f"{total} frames (~{total/59.7:.1f}s), channel loop lens={loops}")
    for ch, vm in enumerate(chans):
        hw = ['CH1 pulse','CH2 pulse','CH3 wave','CH4 noise'][ch]
        if vm is None:
            print(f"-- CH{ch+1} ({hw}): silent")
            continue
        print(f"-- CH{ch+1} ({hw}): {len(vm.notes)} events, loop@frame {vm.goto_frame} --")
        for ev in vm.notes[:60]:
            print("   ", ev)
        if len(vm.notes) > 60:
            print(f"    ... (+{len(vm.notes)-60} more)")

if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--bank', default='3f')
    ap.add_argument('--id', required=True)
    ap.add_argument('--dump', action='store_true')
    args = ap.parse_args()
    rom = Rom()
    bank = int(args.bank, 16)
    sid = int(args.id, 16)
    if args.dump:
        dump(rom, bank, sid)
