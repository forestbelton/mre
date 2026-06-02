#!/usr/bin/env python3
"""Index NPC/cutscene graphics by following script SCRIPT_FAR_CALLs.

Scripts are text-engine bytecode, but a SCRIPT_FAR_CALL ($07 lo hi bank) jumps
to real GBZ80 code. Those targets are the per-NPC "show portrait" loaders, which
copy tile pixels to VRAM (CopyBytesBanked) and a tilemap descriptor to the BG map
(CopyBgMapBankedA). This walks every src/scripts/*.asm far-call, finds the
analyzed.asm code section that contains the target, scans that section for the
graphics-load calls, renders each tile blob from the ROM, and attributes it to
the calling NPC + the nearest preceding dialogue line.

Read-only: renders PNGs under build/portraits/ and prints a table. Touches no
map.json. Run from the repo root: python3 tools/find_portraits.py
"""
import json, re, glob, os, sys, pathlib
sys.path.insert(0, os.path.dirname(__file__))
import extract  # for gfx_to_indexed_png + the home-bank helper labels

ROM = open("rom.gbc", "rb").read()
MAP = json.load(open("map.json"))

# HOME copy routines the loaders call (addr -> kind).
COPY = {0x392d: "tiles", 0x3942: "bgmap", 0x35e9: "bgmap", 0x35d4: "bgmap_idx",
        0x3614: "palette"}

# SM83 instruction byte-lengths so a linear scan stays in sync.
LEN = [1]*256
for op in (0x01,0x08,0x11,0x21,0x31,0xC2,0xC3,0xC4,0xCA,0xCC,0xCD,
           0xD2,0xD4,0xDA,0xDC,0xEA,0xFA): LEN[op] = 3
for op in (0x06,0x0E,0x10,0x16,0x18,0x1E,0x20,0x26,0x28,0x2E,0x30,0x36,0x38,0x3E,
           0xC6,0xCB,0xCE,0xD6,0xDE,0xE0,0xE6,0xE8,0xEE,0xF0,0xF6,0xF8,0xFE): LEN[op] = 2

def flat(bank, addr):
    return addr if bank == 0 else bank*0x4000 + (addr-0x4000)

def bank_addr(fl):
    b = fl // 0x4000
    return b, (fl if b == 0 else 0x4000 + (fl % 0x4000))

# analyzed.asm code sections, sorted, for "which section contains this target".
A = next(f for f in MAP["files"] if f["name"] == "analyzed.asm")
CODE = sorted((int(s["addr"],16), int(s["len"],16))
              for s in A["sections"] if s.get("type") == "code")
def section_of(fl):
    for a,l in CODE:
        if a <= fl < a+l:
            return (a, l)
    return None

def scan_loads(sec_start, sec_len):
    """Linear-scan a code section; return load events from Copy* calls."""
    end = sec_start + sec_len
    i = sec_start
    la = lhl = lde = lbc = None
    out = []
    while i < end:
        op = ROM[i]
        if   op == 0x3E: la  = ROM[i+1]
        elif op == 0x21: lhl = ROM[i+1] | ROM[i+2] << 8
        elif op == 0x11: lde = ROM[i+1] | ROM[i+2] << 8
        elif op == 0x01: lbc = ROM[i+1] | ROM[i+2] << 8
        elif op == 0xCD:
            tgt = ROM[i+1] | ROM[i+2] << 8
            if tgt in COPY:
                out.append(dict(kind=COPY[tgt], at=i, bank=la, src=lhl,
                                dest=lde, size=lbc))
        i += LEN[op]
    return out

# --- parse scripts: NPC -> [(far_addr, far_bank, context_text)] ---
FAR = re.compile(r'SCRIPT_FAR_CALL\s+\$([0-9a-fA-F]+),\s*\$([0-9a-fA-F]+)')
TEXT = re.compile(r'db\s+"([^"]*)"')
npc_calls = {}
for path in sorted(glob.glob("src/scripts/*.asm")):
    npc = pathlib.Path(path).stem
    lines = open(path).read().splitlines()
    last_text = ""
    calls = []
    for ln in lines:
        mt = TEXT.search(ln)
        if mt: last_text = mt.group(1)
        mf = FAR.search(ln)
        if mf:
            calls.append((int(mf.group(1),16), int(mf.group(2),16), last_text))
    npc_calls[npc] = calls

# --- for each NPC, gather loads from sections containing its far-call targets ---
outdir = pathlib.Path("build/portraits"); outdir.mkdir(parents=True, exist_ok=True)
rendered = {}   # src flat -> png path (dedupe identical blobs)
rows = []
for npc, calls in npc_calls.items():
    seen_sec = set()
    for addr, bank, ctx in calls:
        fl = flat(bank, addr)
        sec = section_of(fl)
        if not sec or sec in seen_sec:
            continue
        seen_sec.add(sec)
        for ev in scan_loads(*sec):
            if ev["bank"] is None or ev["src"] is None:
                continue
            sb, sa = ev["bank"], ev["src"]
            sfl = flat(sb, sa)
            tag = ""
            png = ""
            if ev["kind"] == "tiles" and ev["size"] and ev["dest"] and \
               0x8000 <= ev["dest"] < 0xA000 and ev["size"] % 16 == 0:
                if sfl not in rendered:
                    blob = ROM[sfl:sfl+ev["size"]]
                    p = outdir / f"{sb:02x}_{sa:04x}_{ev['size']//16}t.png"
                    try:
                        extract.gfx_to_indexed_png(blob, 16, p)
                        rendered[sfl] = str(p)
                    except Exception as e:
                        rendered[sfl] = f"(render fail: {e})"
                png = rendered[sfl]
            rows.append((npc, ctx[:24], ev["kind"], sb, sa, ev["size"], ev["dest"], png))

# --- print table ---
print(f"{'NPC':9} {'context':25} {'kind':8} {'src':10} {'size':>6} {'dest':>6}  png")
seen=set()
for npc,ctx,kind,sb,sa,size,dest,png in rows:
    key=(npc,kind,sb,sa)
    if key in seen: continue
    seen.add(key)
    src=f"${sb:02x}:${sa:04x}"; sz=f"{size or 0:#x}"; ds=f"${dest:04x}" if dest else ""
    print(f"{npc:9} {ctx:25} {kind:8} {src:10} {sz:>6} {ds:>6}  {os.path.basename(png) if png else ''}")
print(f"\nrendered {len(rendered)} tile blobs -> build/portraits/")
