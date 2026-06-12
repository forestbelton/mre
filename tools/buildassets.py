#!/usr/bin/env python3
"""Build every graphics asset's ROM components into build/assets/.

The single entry point the Makefile calls: reads assets/assets.yaml and runs
tools/pngasset.py for each PNG-driven asset. Every graphics asset is described
here, so adding one is a YAML edit -- no Makefile change. See docs/gfx_assets.md.
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
        if "map" in spec:                             # Tiled .tmx arrangement source
            cmd += ["--map", str(spec["map"])]
    elif mode == "scene":
        cmd = [pngasset, "scene", "--png", str(png), "--out-dir", str(out)]
        if "tiles" in spec:
            cmd += ["--tiles", str(spec["tiles"])]
        if "palettes" in spec:
            cmd += ["--palettes", str(spec["palettes"])]
    elif mode == "portrait":
        cmd = [pngasset, "portrait", "--png", str(png), "--out-dir", str(out)]
        if "tiles1" in spec:
            cmd += ["--tiles1", str(spec["tiles1"])]
        if "tiles0" in spec:
            cmd += ["--tiles0", str(spec["tiles0"])]
        if "palettes_bg" in spec:
            cmd += ["--palettes-bg", str(spec["palettes_bg"])]
        if "palettes_obj" in spec:
            cmd += ["--palettes-obj", str(spec["palettes_obj"])]
        if "layout" in spec:                          # derive maps from the allocator layout
            cmd += ["--layout", str(spec["layout"])]
            if "blank_byte" in spec:                  # blank-collapse layouts (mistral)
                cmd += ["--blank-byte", str(spec["blank_byte"]),
                        "--reference", str(spec["reference"])]
            if "map_overrides" in spec:               # blank-cell/blank-slot ties
                cmd += ["--map-overrides",
                        ";".join(f"{k}:{v}" for k, v in spec["map_overrides"].items())]
        if "sprites" in spec:                          # regenerate the OBJ/BG overlay region
            cmd += ["--sprites", str(spec["sprites"])]
        if "palettes2" in spec:                        # a second BG+OBJ palette set (alt scene)
            cmd += ["--palettes2-png", str(spec["palettes2"])]
    else:
        raise SystemExit(f"asset {name!r}: unknown mode {mode!r}")
    print(f"[{name}] {mode} -> {out.relative_to(ROOT)}")
    run(*cmd)


def main() -> int:
    spec = yaml.safe_load((ROOT / "assets" / "assets.yaml").read_text()) or {}
    for name, a in spec.items():
        build_png_asset(name, a)
    return 0


if __name__ == "__main__":
    sys.exit(main())
