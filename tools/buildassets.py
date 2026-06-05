#!/usr/bin/env python3
"""Build every graphics asset's ROM components into build/assets/.

The single entry point the Makefile calls: reads assets/assets.yaml and runs
tools/pngasset.py for each PNG-driven asset, then auto-builds the remaining
legacy assets/<name>/asset.json assets via tools/gfxasset.py. Adding a
PNG-driven asset is a YAML edit -- no Makefile change. See docs/gfx_assets.md.
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
PY = sys.executable


def out_dir(png_rel: str) -> Path:
    """build/assets/<dir of the PNG, or its stem if it sits at assets/ root>."""
    p = Path(png_rel)
    return ROOT / "build" / "assets" / (p.parent.name or p.stem)


def run(*args: str) -> None:
    subprocess.run([PY, *args], check=True, cwd=ROOT)


def build_png_asset(name: str, spec: dict) -> None:
    png = ROOT / "assets" / spec["png"]
    out = out_dir(spec["png"])
    mode = spec["mode"]
    pngasset = str(ROOT / "tools" / "pngasset.py")
    if mode == "composite":
        cmd = [pngasset, "encode", "--png", str(png), "--out-dir", str(out)]
        if "sheet_rows" in spec:
            cmd += ["--sheet-rows", str(spec["sheet_rows"])]
        if "pad_before" in spec:
            byte, n = spec["pad_before"]
            cmd += ["--pad-before", str(byte), str(n)]
        if "colors" in spec:
            cmd += ["--colors", str(spec["colors"])]
    elif mode == "screen":
        cmd = [pngasset, "screen", "--png", str(png), "--out-dir", str(out)]
        if "tiles" in spec:
            cmd += ["--tiles", str(spec["tiles"])]
    elif mode == "portrait":
        cmd = [pngasset, "portrait", "--png", str(png), "--out-dir", str(out)]
        if "tiles1" in spec:
            cmd += ["--tiles1", str(spec["tiles1"])]
        if "tiles0" in spec:
            cmd += ["--tiles0", str(spec["tiles0"])]
    else:
        raise SystemExit(f"asset {name!r}: unknown mode {mode!r}")
    print(f"[{name}] {mode} -> {out.relative_to(ROOT)}")
    run(*cmd)


def main() -> int:
    spec = yaml.safe_load((ROOT / "assets" / "assets.yaml").read_text()) or {}
    described = set()
    for name, a in spec.items():
        build_png_asset(name, a)
        described.add((ROOT / "assets" / a["png"]).parent.resolve())

    # Legacy multi-file assets (assets/<name>/asset.json) not already PNG-driven.
    gfxasset = str(ROOT / "tools" / "gfxasset.py")
    for aj in sorted((ROOT / "assets").glob("*/asset.json")):
        d = aj.parent
        if d.resolve() in described:
            continue
        print(f"[{d.name}] legacy gfxasset")
        run(gfxasset, "encode", "--in", str(d), "--out-dir", str(ROOT / "build" / "assets" / d.name))
    return 0


if __name__ == "__main__":
    sys.exit(main())
