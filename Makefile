# Monster Rancher Explorer disassembly — build orchestration.
#
# Targets:
#   verify   (default) — build the ROM and compare its sha256 to rom.gbc
#   rom               — assemble and link build/rom.gbc from src/
#   extract           — run tools/extract.py to (re)populate src/ from rom.gbc + map.json
#   analyzer          — build the runtime analyzer binary
#   analyze           — run the analyzer against rom.gbc, merging into map.json
#   clean             — remove build artifacts (does not touch src/)

ROM       := rom.gbc
MAP       := map.json
SRC_DIR   := src
BUILD_DIR := build
OUT       := $(BUILD_DIR)/rom.gbc

EXTRACTOR     := tools/extract.py
EXTRACT_STAMP := $(BUILD_DIR)/.extract.stamp

ANALYZER_DIR     := tools/analyzer
ANALYZER_BIN     := $(ANALYZER_DIR)/analyzer
SAMEBOY_DIR      := $(ANALYZER_DIR)/sameboy
# Build every SameBoy Core .c except the ones excluded by the standard
# GB_DISABLE_* defines below.
SAMEBOY_EXCLUDE  := rewind.c debugger.c sm83_disassembler.c symbol_hash.c cheats.c cheat_search.c
SAMEBOY_SRCS     := $(filter-out $(addprefix $(SAMEBOY_DIR)/,$(SAMEBOY_EXCLUDE)),$(wildcard $(SAMEBOY_DIR)/*.c))
ANALYZER_SRCS    := $(ANALYZER_DIR)/analyzer.c $(ANALYZER_DIR)/cJSON.c $(SAMEBOY_SRCS)
ANALYZER_HDRS    := $(ANALYZER_DIR)/cJSON.h $(wildcard $(SAMEBOY_DIR)/*.h)

# SameBoy reads its VERSION from version.mk.
SAMEBOY_VERSION  := $(shell sed -n 's/^VERSION *:= *//p' $(SAMEBOY_DIR)/version.mk)

PYTHON   := python3
RGBASM   := rgbasm
RGBLINK  := rgblink
CC       := cc
CFLAGS   := -O2 -Wall -Wno-unused-parameter -Wno-multichar
SAMEBOY_CFLAGS := -std=gnu11 -D_GNU_SOURCE \
                  -DGB_VERSION='"$(SAMEBOY_VERSION)"' \
                  -DGB_INTERNAL \
                  -DGB_DISABLE_TIMEKEEPING \
                  -DGB_DISABLE_REWIND \
                  -DGB_DISABLE_DEBUGGER \
                  -DGB_DISABLE_CHEATS \
                  -DGB_DISABLE_CHEAT_SEARCH \
                  -I$(ANALYZER_DIR) -I$(SAMEBOY_DIR)
SDL_CFLAGS := $(shell pkg-config --cflags sdl2)
SDL_LIBS   := $(shell pkg-config --libs sdl2)

.PHONY: verify rom extract analyzer analyze clean

verify: $(OUT)
	@built_sum=$$(sha256sum $(OUT) | awk '{print $$1}'); \
	rom_sum=$$(sha256sum $(ROM)  | awk '{print $$1}'); \
	if [ "$$built_sum" = "$$rom_sum" ]; then \
		printf 'verify: OK — sha256 %s\n' "$$built_sum"; \
	else \
		printf 'verify: FAIL\n  built (%s): %s\n  rom   (%s): %s\n' \
			$(OUT) "$$built_sum" $(ROM) "$$rom_sum"; \
		exit 1; \
	fi

rom: $(OUT)

$(OUT): $(EXTRACT_STAMP) | $(BUILD_DIR)
	$(RGBASM) -i $(SRC_DIR)/ -i include/ -o $(BUILD_DIR)/main.o $(SRC_DIR)/main.asm
	$(RGBLINK) -p 0 -o $@ $(BUILD_DIR)/main.o

extract: $(EXTRACT_STAMP)

$(EXTRACT_STAMP): $(EXTRACTOR) $(MAP) $(ROM) | $(BUILD_DIR)
	$(PYTHON) $(EXTRACTOR) --rom $(ROM) --map $(MAP) --output $(SRC_DIR)/ > /dev/null
	@touch $@

$(BUILD_DIR):
	@mkdir -p $@

analyzer: $(ANALYZER_BIN)

$(ANALYZER_BIN): $(ANALYZER_SRCS) $(ANALYZER_HDRS)
	$(CC) $(CFLAGS) $(SAMEBOY_CFLAGS) $(SDL_CFLAGS) -o $@ $(ANALYZER_SRCS) $(SDL_LIBS) -lpthread -lm

analyze: $(ANALYZER_BIN)
	$(ANALYZER_BIN) --rom $(ROM) --map $(MAP)

clean:
	rm -rf $(BUILD_DIR) $(ANALYZER_BIN)
