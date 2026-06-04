# Monster Rancher Explorer disassembly — build orchestration.
#
# The source tree under src/ is the hand-maintained truth; the build just
# assembles it. Editable screen assets (assets/<name>/asset.json) are encoded to
# their ROM bytes by tools/gfxasset.py, and raw_gfx/*.png are converted to 2bpp,
# both at build time.
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
GFX_DIR  := $(SRC_DIR)/raw_gfx

# Assembler inputs — a change to any of these rebuilds the ROM (no `make clean`
# needed). Wildcards are evaluated at parse time, which is fine: these are all
# committed source. find covers subdirs (src/scripts/, assets/<name>/).
SRC_ASM   := $(shell find $(SRC_DIR) -name '*.asm' 2>/dev/null)
INCLUDES  := $(wildcard include/*.inc)
ASSET_SRC := $(shell find assets -type f 2>/dev/null)

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

$(OUT): $(SRC_ASM) $(INCLUDES) $(ASSET_SRC) | $(BUILD_DIR)
	@# Build every gfx PNG into its 2bpp tile data.
	@# `-c embedded` maps PNG pixels back to 2bpp values by the embedded
	@# palette's index order, so the round-trip is byte-exact (the asm
	@# INCBINs only the leading bytes; rgbgfx zero-pads the last tile-row).
	@if [ -d $(GFX_DIR) ]; then \
		for png in $(GFX_DIR)/*.png; do \
			[ -e "$$png" ] || continue; \
			$(RGBGFX) -c embedded -o "$${png%.png}.2bpp" "$$png" || exit 1; \
		done; \
	fi
	@# Compile editable screen assets (assets/<name>/) into their ROM
	@# component bytes under build/assets/, which the asm INCBINs.
	@for a in $(wildcard assets/*); do \
		[ -f "$$a/asset.json" ] || continue; \
		$(PYTHON) tools/gfxasset.py encode --in "$$a" --out-dir "$(BUILD_DIR)/$$a" || exit 1; \
	done
	$(RGBASM) -i $(SRC_DIR)/ -i include/ -i $(BUILD_DIR)/ -o $(BUILD_DIR)/main.o $(SRC_DIR)/main.asm
	$(RGBLINK) -p 0 -m $@.map -o $@ $(BUILD_DIR)/main.o

$(BUILD_DIR):
	@mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)
