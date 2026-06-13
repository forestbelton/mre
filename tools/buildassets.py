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
    """build/assets/<mirror of the asset's path>: the PNG's parent dir when the
    file is named after it (assets/portrait/npc/bodka/bodka.png ->
    portrait/npc/bodka), else parent/stem (assets/summon/gali.png ->
    summon/gali). No per-entry overrides."""
    p = Path(png_rel)
    return ROOT / "build" / "assets" / \
        (p.parent if p.parent.name == p.stem else p.parent / p.stem)


def run(*args: str) -> None:
    subprocess.run([PY, *args], check=True, cwd=ROOT)


def build_png_asset(name: str, spec: dict) -> None:
    png = ROOT / "assets" / spec["png"]
    out = out_dir(spec["png"])
    mode = spec["mode"]
    pngasset = str(ROOT / "tools" / "pngasset.py")
    if mode == "screen":
        cmd = [pngasset, "screen", "--png", str(png), "--out-dir", str(out)]
        if "tiles" in spec:
            cmd += ["--tiles", str(spec["tiles"])]
        if "map" in spec:                             # Tiled .tmx arrangement source
            cmd += ["--map", str(spec["map"])]
    elif mode == "maplib":
        cmd = [pngasset, "maplib", "--png", str(png), "--out-dir", str(out),
               "--tiles", str(spec["tiles"]),
               "--banks", str(spec.get("banks", 1)),
               "--base", str(spec.get("base", 0)),
               "--palettes", str(spec.get("palettes", 0)),
               "--maps", ",".join(spec.get("maps", []))]
    elif mode == "sprite":
        cmd = [pngasset, "sprite", "--png", str(png), "--out-dir", str(out),
               "--tiles", str(spec["tiles"]),
               "--palettes", str(spec.get("palettes", 0))]
    elif mode == "scene":
        cmd = [pngasset, "scene", "--png", str(png), "--out-dir", str(out)]
        if "tiles" in spec:
            cmd += ["--tiles", str(spec["tiles"])]
        if "palettes" in spec:
            cmd += ["--palettes", str(spec["palettes"])]
        if "frames" in spec:                          # Tiled animation-frame maps
            cmd += ["--frames", str(spec["frames"])]
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
        if "map" in spec:                             # Tiled arrangement source
            cmd += ["--map", str(spec["map"]), "--map-layer", str(spec["map_layer"])]
            if "obj_layers" in spec:                  # static OBJ overlays in the map
                cmd += ["--obj-layers", ",".join(spec["obj_layers"])]
            if "map_bank1" in spec:                   # NPC portraits: bank-1 tile count
                cmd += ["--map-bank1", str(spec["map_bank1"])]
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
