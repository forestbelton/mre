# Monster Rancher Explorer disassembly — build orchestration.
#
# The source tree under src/ is the hand-maintained truth; the build just
# assembles it. Editable graphics assets (assets/, laid out to mirror src/gfx)
# are encoded to their ROM bytes from one PNG each by tools/pngasset.py (driven by
# assets/assets.yaml), and raw_gfx/*.png are converted to 2bpp, both at build time.
#
# Targets:
#   verify   (default) — build the ROM and compare its sha256 to the known value
#   rom                — assemble and link build/rom.gbc from src/
#   clean              — remove build artifacts (does not touch src/)

SRC_DIR   := src
BUILD_DIR := build
OUT       := $(BUILD_DIR)/rom.gbc

PYTHON   := python3
RGBASM   := rgbasm
RGBLINK  := rgblink
RGBGFX   := rgbgfx
RGBFIX   := rgbfix
GFX_DIR  := $(SRC_DIR)/raw_gfx

FIXARGS := --validate \
	--pad-value 0 \
	--title MREXPLORER \
	--game-id BSOE \
	--color-only \
	--new-licensee 9B \
	--ram-size 2 \
	--non-japanese \
	--old-licensee 0x33 \
	--mbc-type MBC5+RAM+BATTERY

# Assembler inputs — a change to any of these rebuilds the ROM (no `make clean`
# needed). Wildcards are evaluated at parse time, which is fine: these are all
# committed source. find covers subdirs (src/scripts/, assets/<name>/).
SRC_ASM    := $(shell find $(SRC_DIR) -name '*.asm' 2>/dev/null)
INCLUDES   := $(wildcard include/*.inc)
ASSET_SRC  := $(shell find assets -type f 2>/dev/null)
# raw_gfx is 1:1 PNG -> 2bpp (rebuilt per-PNG); the PNG-driven assets are gated by
# one stamp so they only rebuild when an asset PNG, the YAML, or a build script
# changes -- not on every .asm edit.
GFX_PNG     := $(wildcard $(GFX_DIR)/*.png)
GFX_2BPP    := $(GFX_PNG:.png=.2bpp)
ASSET_STAMP := $(BUILD_DIR)/assets.stamp
# Linker script — centralizes section placement; sections are progressively
# migrated off their source ROMX[$addr] offsets into here (see the file header).
LINKSCRIPT := layout.link

.PHONY: verify rom clean

verify: $(OUT)
	@built_sum=$$(sha256sum $(OUT) | awk '{print $$1}'); \
	rom_sum=8f66b5972bf76ed15985815ccdecc459fab9e84221454139b05d1d6654b69e7a; \
	if [ "$$built_sum" = "$$rom_sum" ]; then \
		printf 'verify: OK — sha256 %s\n' "$$built_sum"; \
	else \
		printf 'verify: FAIL\n  built (%s): %s\n  rom: %s\n' \
			$(OUT) "$$built_sum" "$$rom_sum"; \
		exit 1; \
	fi

rom: $(OUT)

$(OUT): $(SRC_ASM) $(INCLUDES) $(GFX_2BPP) $(ASSET_STAMP) $(LINKSCRIPT) | $(BUILD_DIR)
	$(RGBASM) -i $(SRC_DIR)/ -i include/ -i $(BUILD_DIR)/ -o $(BUILD_DIR)/main.o $(SRC_DIR)/main.asm
	$(RGBLINK) -p 0 -l $(LINKSCRIPT) -m $@.map -o $@ $(BUILD_DIR)/main.o
	$(RGBFIX) $(FIXARGS) $@

# raw_gfx: each PNG -> 2bpp tile data, rebuilt only when its PNG changes.
# `-c embedded` maps PNG pixels back to 2bpp values by the embedded palette's
# index order, so the round-trip is byte-exact (the asm INCBINs only the leading
# bytes; rgbgfx zero-pads the last tile-row).
$(GFX_DIR)/%.2bpp: $(GFX_DIR)/%.png
	$(RGBGFX) -c embedded -o $@ $<

# All graphics assets are PNG-driven: assets/assets.yaml -> pngasset for each,
# into build/assets/. The stamp gates the whole batch so it reruns only when an
# asset PNG, the YAML, or a build script changes. Adding an asset is a YAML edit.
$(ASSET_STAMP): $(ASSET_SRC) tools/buildassets.py tools/pngasset.py | $(BUILD_DIR)
	$(PYTHON) tools/buildassets.py
	@touch $@

$(BUILD_DIR):
	@mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)
