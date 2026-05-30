/*
 * Runtime ROM analyzer for the Monster Rancher Explorer disassembly.
 *
 * Plays the ROM in an SDL window using SameBoy's Core (CGB-correct), while
 * classifying every ROM byte as code (PC visited) or data (read non-fetch).
 * Bytes that hit both criteria are defensively recorded as data.
 *
 * Findings are merged into the project's map.json under a single auto-
 * managed file entry named `analyzed.asm`. User-curated entries and the
 * reserved header at 0x100-0x14F are never touched.
 *
 * Threads:
 *   main    SDL render, GB_run_frame, input
 *   writer  every --save-interval seconds (default 10) and once on exit,
 *           snapshots the per-byte map and rewrites map.json atomically
 *
 * Usage:
 *   analyzer --rom rom.gbc --map map.json [--save-interval 10]
 *
 * Controls: Arrows = D-pad, Z/X = A/B, Enter = Start, Backspace = Select,
 * Tab toggles fast-forward, Escape or window close quits.
 */

#include <errno.h>
#include <pthread.h>
#include <signal.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#include <SDL2/SDL.h>

#include "cJSON.h"
#include "sameboy/gb.h"

/* ---------------- Constants ---------------- */

enum {
    REGION_UNKNOWN  = 0,
    REGION_CODE     = 1,
    REGION_DATA     = 2,
    REGION_CONFLICT = 3, /* both observed — emitted as data */
};

#define DEFAULT_SAVE_INTERVAL_SEC 10
#define WINDOW_SCALE              9
#define ANALYZED_FILE_NAME        "analyzed.asm"
#define HEADER_START              0x0100
#define HEADER_END                0x0150  /* exclusive */
/* Max screen we ever need to back: SGB border is 256x224. */
#define MAX_SCREEN_PIXELS         (256 * 224)

/* --watch-vram provenance bitmask (per ROM byte). Despite the "vram" name
 * VSRC_PALETTE tracks ROM bytes copied to the CGB palette data port, which
 * is a separate destination ($FF69/$FF6B) — palette tables are usually NOT
 * colocated with the tiles they color. */
#define VSRC_TILEDATA 0x01   /* copied to VRAM tiledata ($8000-$97FF) */
#define VSRC_TILEMAP  0x02   /* copied to VRAM tilemap  ($9800-$9FFF) */
#define VSRC_PALETTE  0x04   /* copied to CGB palette RAM ($FF69/$FF6B)  */

/* A tiledata run must be at least this many bytes (and a whole number of
 * 16-byte tiles) to be promoted from `data` to a `gfx` section; shorter
 * verbatim runs stay `data` to avoid one-tile section clutter. */
#define GFX_MIN_BYTES 0x40

/* Minimal CGB boot stub.
 *
 * SameBoy requires a boot ROM to be loaded — without one, gb->boot_rom is
 * zero, gb->boot_rom_finished stays false, and the CPU executes NOPs from
 * $0000 forever (white screen). Real boot ROMs are large and licensed
 * (Nintendo's) or have build dependencies (SameBoy's own, which needs a
 * compressed-logo blob). For analysis we don't need the Nintendo-logo
 * scroll or the CGB title-checksum colorization — we just need the
 * cartridge to start running with A = $11 (CGB hardware indicator) and
 * the boot ROM unmapped.
 *
 * Bytes laid out at $0000-$00FF, with the unmap instruction sitting at
 * $00FE-$00FF so PC naturally falls through to $0100 (cart entry) after
 * the write to $FF50. */
static const uint8_t cgb_boot_stub[0x100] = {
    [0x00] = 0x31, 0xfe, 0xff,  /* ld sp, $FFFE              */
    [0x03] = 0x3e, 0x91,        /* ld a, $91                 */
    [0x05] = 0xe0, 0x40,        /* ldh [$40], a    ; LCDC=$91 */
    [0x07] = 0x3e, 0x11,        /* ld a, $11       ; CGB hw   */
    /* 0x09-0xFD: NOPs ($00, the array's default) */
    [0xfe] = 0xe0, 0x50,        /* ldh [$50], a    ; unmap    */
};

/* SM83 instruction length, indexed by first opcode byte. CB-prefixed
 * instructions are uniformly 2 bytes (the $CB entry). Illegal opcodes
 * are listed as 1 — SameBoy doesn't define their behavior. */
static const uint8_t sm83_length_table[256] = {
    /*       0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F */
    /* 00 */ 1, 3, 1, 1, 1, 1, 2, 1, 3, 1, 1, 1, 1, 1, 2, 1,
    /* 10 */ 2, 3, 1, 1, 1, 1, 2, 1, 2, 1, 1, 1, 1, 1, 2, 1,
    /* 20 */ 2, 3, 1, 1, 1, 1, 2, 1, 2, 1, 1, 1, 1, 1, 2, 1,
    /* 30 */ 2, 3, 1, 1, 1, 1, 2, 1, 2, 1, 1, 1, 1, 1, 2, 1,
    /* 40 */ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    /* 50 */ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    /* 60 */ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    /* 70 */ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    /* 80 */ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    /* 90 */ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    /* A0 */ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    /* B0 */ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    /* C0 */ 1, 1, 3, 3, 3, 1, 2, 1, 1, 1, 3, 2, 3, 3, 2, 1,
    /* D0 */ 1, 1, 3, 1, 3, 1, 2, 1, 1, 1, 3, 1, 3, 1, 2, 1,
    /* E0 */ 2, 1, 1, 1, 1, 1, 2, 1, 2, 1, 3, 1, 1, 1, 2, 1,
    /* F0 */ 2, 1, 1, 1, 1, 1, 2, 1, 2, 1, 3, 1, 1, 1, 2, 1,
};

/* ---------------- Globals ---------------- */

typedef struct {
    /* ROM and per-byte annotations. */
    uint8_t  *rom_data;
    uint32_t  rom_size;
    uint8_t  *rom_map;
    uint8_t  *covered;
    /* insn_byte[i] = 1 if byte i is part of an instruction that has been
     * executed (the opcode byte or one of its operand bytes). Used to
     * suppress data marks against bytes that genuinely belong to a known
     * instruction — OAM DMA from a low-address source page would
     * otherwise read VBlank/RST vector operand bytes and fragment the
     * map (CODE -> CONFLICT -> emitted as data, breaking the
     * disassembly into 1-byte slivers). */
    uint8_t  *insn_byte;
    /* is_gfx[i] = 1 if byte i is verbatim tiledata pixel data (from this
     * session's --watch-vram trace OR a `gfx` section loaded from map.json).
     * Persistent and independent of watch_vram so the classification sticks
     * across sessions; build_analyzed_entry promotes these DATA bytes to
     * `gfx` sections. */
    uint8_t  *is_gfx;

    /* SameBoy instance + framebuffer big enough for SGB border. */
    GB_gameboy_t gb;
    uint32_t     framebuffer[MAX_SCREEN_PIXELS];

    /* SDL */
    SDL_Window   *window;
    SDL_Renderer *renderer;
    SDL_Texture  *texture;
    unsigned      screen_w, screen_h;

    /* Run state */
    volatile int running;
    bool         fast_forward;

    /* CLI */
    const char *rom_path;
    const char *map_path;
    char       *battery_path;  /* "<rom_path>.sav", malloc'd */
    uint32_t    save_interval_sec;
    bool        no_save;       /* --no-save: skip battery load and save */

    /* --watch-write: every cart-bus write to a flagged 16-bit address is
     * logged with the writing PC, so a play session can correlate menu
     * selections, RNG ticks, etc. with the script-engine WRAM bytes that
     * back them. Per-address bool keeps the hot path branch-free. */
    bool        watch_write[0x10000];
    bool        watch_any;
    const char *watch_log_path;  /* --watch-log <path>; NULL -> stderr */
    FILE       *watch_log;

    /* --watch-vram: trace the provenance of bytes copied into VRAM so we
     * can find, from runtime ground truth, which ROM regions are tile
     * pixel data ($8000-$97FF) vs tilemap layout ($9800-$9FFF), and which
     * arrive uncompressed (straight from ROM) vs decompressed (built in
     * WRAM first). vram_src_kind[flat] accumulates a bitmask per ROM byte:
     *   bit0 (VSRC_TILEDATA) — this ROM byte was copied to tiledata VRAM
     *   bit1 (VSRC_TILEMAP)  — ... to tilemap VRAM
     * last_data_read holds the flat ROM offset of the most recent non-fetch
     * data read, or UINT32_MAX if that read came from RAM/IO (not ROM); it
     * is consumed (and cleared) by the next VRAM write so a single ROM read
     * attributes to at most one VRAM byte and stale offsets can't leak. */
    bool        watch_vram;
    const char *vram_log_path;   /* --watch-vram <path>; NULL -> stderr */
    FILE       *vram_log;
    uint8_t    *vram_src_kind;   /* rom_size bytes, allocated iff watch_vram */
    uint32_t    last_data_read;
    /* A VRAM byte is only credited to its ROM source when the byte written
     * equals rom[src] — a *verbatim* copy, which is proof the ROM region is
     * the literal source. "rejected" = a ROM read preceded the write but the
     * value differs (transformed tile-index, or a coincidental stale read);
     * "from_ram" = no ROM read preceded it (computed / WRAM->VRAM). Neither
     * is marked, so map.json only ever gets definite ROM sources. */
    uint64_t    cpu_tiledata_marked, cpu_tiledata_rejected;
    uint64_t    cpu_tilemap_marked,  cpu_tilemap_rejected;
    uint64_t    cpu_palette_marked,  cpu_palette_rejected;
    uint64_t    cpu_vram_from_ram;
    uint64_t    hdma_from_rom_bytes, hdma_from_ram_bytes;

    /* Tile<->palette cross-reference. The ROM source that loaded each VRAM
     * byte is remembered in vram_byte_src (indexed by VRAM offset, both
     * banks; UINT32_MAX = not from ROM). Each frame we walk the active BG/
     * window tilemaps and OAM, read the palette number applied to each tile
     * (tilemap attribute / OAM attribute bits 0-2), follow the slot back to
     * its ROM source, and OR that palette's bit into rom_bg_pal / rom_obj_pal
     * for every byte of the tile. Result per ROM tile region: the set of
     * palettes it's drawn with. pal_colors_seen snapshots each palette's
     * RGB555 the first frame it's observed in use, so colors pair with tiles
     * even though the live palette RAM is reused across screens. */
    uint32_t   *vram_byte_src;   /* [0x4000], allocated iff watch_vram */
    uint8_t    *rom_bg_pal;      /* [rom_size] bitmask of BG palettes (bit p) */
    uint8_t    *rom_obj_pal;     /* [rom_size] bitmask of OBJ palettes        */
    uint8_t     bg_pal_colors[8][8];   /* RGB555, snapshotted on first use */
    uint8_t     obj_pal_colors[8][8];
    uint16_t    bg_pal_seen, obj_pal_seen;   /* bit p set once snapshotted */

    /* Writer thread */
    pthread_t       writer_thread;
    pthread_mutex_t writer_mtx;
    pthread_cond_t  writer_cv;
    int             writer_should_stop;
    uint32_t        saves_done;

    /* Stats */
    uint64_t total_instructions;
    uint64_t total_frames;
} analyzer_t;

static analyzer_t g;

/* SIGINT/SIGTERM -> request a graceful shutdown so the main loop exits,
 * the final map.json checkpoint is written, and (with --watch-vram) the
 * provenance report is emitted. Lets headless/timed runs end cleanly via
 * `timeout --signal=INT` instead of being killed mid-frame. */
static void on_signal(int sig) { (void)sig; g.running = 0; }

/* ---------------- Bank/address helpers ---------------- */

/* Resolve a 16-bit CPU address into a flat ROM offset, or UINT32_MAX if
 * the address isn't in the cart ROM region ($0000-$7FFF). For $4000-$7FFF
 * the SameBoy MBC's current high bank is used. */
static uint32_t resolve_rom_addr(uint16_t addr) {
    if (addr < 0x4000) return addr;
    if (addr < 0x8000)
        return (uint32_t)g.gb.mbc_rom_bank * 0x4000 + (addr - 0x4000);
    return UINT32_MAX;
}

/* ---------------- mark code / data ---------------- */

static void mark_code(uint32_t flat, uint8_t len) {
    for (uint8_t i = 0; i < len; i++) {
        uint32_t a = flat + i;
        if (a >= g.rom_size || g.covered[a]) continue;
        uint8_t cur = g.rom_map[a];
        if (cur == REGION_DATA)         g.rom_map[a] = REGION_CONFLICT;
        else if (cur == REGION_UNKNOWN) g.rom_map[a] = REGION_CODE;
    }
}

static void mark_data(uint32_t flat) {
    if (flat >= g.rom_size || g.covered[flat]) return;
    /* If the CPU has executed an instruction that covers this byte, it
     * is unambiguously code (opcode or operand). Don't let a later
     * data-bus read — OAM DMA from a low-address source page, indirect
     * prefetch, etc. — downgrade it; that's what fragments multi-byte
     * instructions into "Func_X: db $c3" stumps. */
    if (g.insn_byte[flat]) return;
    uint8_t cur = g.rom_map[flat];
    if (cur == REGION_CODE)         g.rom_map[flat] = REGION_CONFLICT;
    else if (cur == REGION_UNKNOWN) g.rom_map[flat] = REGION_DATA;
}

/* ---------------- SameBoy callbacks ---------------- */

/* execution_callback fires after the opcode byte is read but before
 * operand reads / opcode execution. PC has just been incremented past
 * the opcode (so gb->pc == pc + 1 here).
 *
 * While the boot ROM is mapped, $0000-$00FF (and $0200-$08FF on CGB) is
 * boot ROM territory, not cart ROM — even though our resolve_rom_addr
 * happily maps those addresses to flat offsets. Gate on
 * boot_rom_finished so we don't mistake stub instructions for cart code. */
static void on_execution(GB_gameboy_t *gb, uint16_t pc, uint8_t opcode) {
    if (!gb->boot_rom_finished) return;
    uint32_t flat = resolve_rom_addr(pc);
    if (flat == UINT32_MAX || flat >= g.rom_size) return;
    uint8_t ilen = sm83_length_table[opcode];
    mark_code(flat, ilen);
    /* Note every byte of this instruction as belonging to an executed
     * instruction, so future mark_data on operand bytes is a no-op. */
    for (uint8_t i = 0; i < ilen; i++) {
        uint32_t a = flat + i;
        if (a < g.rom_size) g.insn_byte[a] = 1;
    }
    g.total_instructions++;
}

/* read_memory_callback fires on every memory read. All fetch reads
 * (opcode + operands) in SameBoy's CPU are of the form
 *     cycle_read(gb, gb->pc++)
 * which means at callback time, `addr == gb->pc - 1`. We use that to
 * skip fetches and only mark genuine data accesses (LD A,[HL], DMA
 * source reads, etc.). */
static uint8_t on_read_memory(GB_gameboy_t *gb, uint16_t addr, uint8_t data) {
    if (!gb->boot_rom_finished) return data; /* don't analyze the boot stub */
    if (addr >= 0x8000) {                      /* outside cart ROM region */
        /* A non-fetch read from RAM/IO/VRAM breaks any ROM->VRAM chain:
         * the next VRAM write isn't sourced straight from ROM (it's a
         * WRAM->VRAM copy of decompressed data, a computed value, etc.). */
        if (g.watch_vram) {
            GB_registers_t *regs = GB_get_registers(gb);
            if (addr != (uint16_t)(regs->pc - 1)) g.last_data_read = UINT32_MAX;
        }
        return data;
    }

    GB_registers_t *regs = GB_get_registers(gb);
    if (addr == (uint16_t)(regs->pc - 1)) return data; /* fetch read */

    uint32_t flat = resolve_rom_addr(addr);
    if (flat != UINT32_MAX && flat < g.rom_size) {
        mark_data(flat);
        if (g.watch_vram) g.last_data_read = flat;
    }
    return data;
}

/* ---------------- VRAM-write provenance (--watch-vram) ---------------- */

/* A CPU write landed in VRAM ($8000-$9FFF). Attribute it to the ROM byte
 * most recently read (last_data_read) — but only mark that ROM byte if the
 * value written is byte-identical to it (a verbatim copy), which is the
 * "definitely the source" bar. The source is consumed either way so it
 * can't be credited to a second VRAM byte. */
static void vram_note_cpu_write(uint16_t addr, uint8_t value) {
    uint8_t kind = (addr < 0x9800) ? VSRC_TILEDATA : VSRC_TILEMAP;
    uint32_t src = g.last_data_read;
    if (src == UINT32_MAX) { g.cpu_vram_from_ram++; return; }
    g.last_data_read = UINT32_MAX;  /* consume */

    bool verbatim = (src < g.rom_size && g.rom_data[src] == value);
    if (kind == VSRC_TILEDATA) {
        if (verbatim) {
            g.vram_src_kind[src] |= kind; g.cpu_tiledata_marked++;
            g.is_gfx[src] = 1;
            uint32_t voff = (uint32_t)(addr - 0x8000)
                          + (g.gb.cgb_vram_bank ? 0x2000 : 0);
            g.vram_byte_src[voff] = src;   /* remember slot's ROM source */
        }
        else            g.cpu_tiledata_rejected++;
    } else {
        if (verbatim) { g.vram_src_kind[src] |= kind; g.cpu_tilemap_marked++; }
        else            g.cpu_tilemap_rejected++;
    }
}

/* A CPU write hit a CGB palette data port ($FF69 BGPD / $FF6B OBPD). The
 * 64-byte BG and OBJ palette RAMs are usually filled by a loop reading an
 * RGB555 table from ROM, so the same verbatim-copy provenance applies. The
 * palette ROM region is typically separate from the tile data it colors. */
static void vram_note_palette_write(uint8_t value) {
    uint32_t src = g.last_data_read;
    if (src == UINT32_MAX) { g.cpu_vram_from_ram++; return; }
    g.last_data_read = UINT32_MAX;  /* consume */
    if (src < g.rom_size && g.rom_data[src] == value) {
        g.vram_src_kind[src] |= VSRC_PALETTE;
        g.cpu_palette_marked++;
    } else {
        g.cpu_palette_rejected++;
    }
}

/* A GDMA/HDMA transfer was triggered by a write to $FF55. Read the source
 * ($FF51/52), destination ($FF53/54) and length from the registers and, if
 * the source is in ROM, mark the whole copied span by destination kind.
 * A source >= $8000 (WRAM/SRAM) means the data was decompressed/built in
 * RAM first — the ROM blob feeding it is compressed, so we don't mark it. */
static void vram_note_hdma(GB_gameboy_t *gb, uint8_t hdma5) {
    uint16_t src  = ((uint16_t)gb->io_registers[GB_IO_HDMA1] << 8)
                  | (gb->io_registers[GB_IO_HDMA2] & 0xF0);
    uint16_t dest = (((uint16_t)(gb->io_registers[GB_IO_HDMA3] & 0x1F)) << 8)
                  | (gb->io_registers[GB_IO_HDMA4] & 0xF0);   /* VRAM offset */
    uint32_t len  = ((uint32_t)(hdma5 & 0x7F) + 1) * 0x10;

    fprintf(g.vram_log,
        "[hdma] src $%04X -> vram $%04X len $%04X bank $%02X%s\n",
        src, (uint16_t)(0x8000 + dest), len,
        (unsigned)g.gb.mbc_rom_bank, (hdma5 & 0x80) ? " hblank" : "");
    fflush(g.vram_log);

    if (src >= 0x8000) { g.hdma_from_ram_bytes += len; return; }

    for (uint32_t i = 0; i < len; i++) {
        uint16_t s = (uint16_t)(src + i);
        if (s >= 0x8000) break;          /* ran past the ROM region */
        uint16_t doff = (uint16_t)((dest + i) & 0x1FFF);
        uint8_t kind = (doff < 0x1800) ? VSRC_TILEDATA : VSRC_TILEMAP;
        uint32_t flat = resolve_rom_addr(s);
        if (flat != UINT32_MAX && flat < g.rom_size) {
            g.vram_src_kind[flat] |= kind;
            if (kind == VSRC_TILEDATA) {
                g.is_gfx[flat] = 1;
                uint32_t voff = doff + (g.gb.cgb_vram_bank ? 0x2000 : 0);
                g.vram_byte_src[voff] = flat;
            }
        }
    }
    g.hdma_from_rom_bytes += len;
}

/* write_memory_callback fires on every CPU write. Used for --watch-write:
 * if `addr` is in the watch set, log the writing instruction's PC (the
 * post-fetch CPU PC, i.e., one past the end of the instruction) and the
 * value being written. Always returns true (allow the write).
 *
 * The bank we print is the *code* bank: HOME ($0000-$3FFF) is always
 * mapped from ROM bank 0 regardless of the current MBC high-bank
 * selection, so print 0 for PCs below $4000. Otherwise mbc_rom_bank is
 * the bank holding the executing code. (Earlier versions printed
 * mbc_rom_bank unconditionally, which was misleading for HOME PCs — the
 * script interpreter lives in HOME but ran while NPC-data banks 24/25
 * were mapped, so the same handler showed up as both "$18:$3ACF" and
 * "$19:$3ACF" in those logs.) */
static bool on_write_memory(GB_gameboy_t *gb, uint16_t addr, uint8_t data) {
    if (!gb->boot_rom_finished) return true;

    if (g.watch_vram) {
        if (addr >= 0x8000 && addr < 0xA000)
            vram_note_cpu_write(addr, data);
        else if (addr == (uint16_t)(0xFF00 + GB_IO_BGPD) ||
                 addr == (uint16_t)(0xFF00 + GB_IO_OBPD))
            vram_note_palette_write(data);
        else if (addr == (uint16_t)(0xFF00 + GB_IO_HDMA5))
            vram_note_hdma(gb, data);   /* GDMA or HDMA trigger; same span */
    }

    if (!g.watch_any) return true;
    if (!g.watch_write[addr]) return true;
    GB_registers_t *regs = GB_get_registers(gb);
    unsigned code_bank = (regs->pc < 0x4000) ? 0u
                                             : (unsigned)g.gb.mbc_rom_bank;
    fprintf(g.watch_log,
        "[watch] $%04X <- $%02X  PC $%02X:$%04X  frame %llu\n",
        addr, data,
        code_bank, regs->pc,
        (unsigned long long)g.total_frames);
    fflush(g.watch_log);
    return true;
}

static uint32_t rgb_encode(GB_gameboy_t *gb, uint8_t r, uint8_t gr, uint8_t b) {
    (void)gb;
    return 0xFF000000u | ((uint32_t)r << 16) | ((uint32_t)gr << 8) | b;
}

/* Snapshot palette P's current RGB555 (8 bytes) the first frame it's seen
 * applied to a tile, so extracted tiles keep colors that match when they
 * were drawn even though palette RAM is reused across screens. */
static void snapshot_palette(bool obj, int p) {
    uint16_t *seen = obj ? &g.obj_pal_seen : &g.bg_pal_seen;
    if (*seen & (1u << p)) return;
    const uint8_t *pd = obj ? g.gb.object_palettes_data
                            : g.gb.background_palettes_data;
    memcpy(obj ? g.obj_pal_colors[p] : g.bg_pal_colors[p], pd + p * 8, 8);
    *seen |= (uint16_t)(1u << p);
}

/* Credit palette `pal` to the ROM source of every byte of the 16-byte tile
 * at VRAM tiledata offset `voff` (bank already folded in). */
static void credit_tile_palette(uint32_t voff, int pal, bool obj) {
    for (int k = 0; k < 16; k++) {
        uint32_t src = g.vram_byte_src[(voff + k) & 0x3FFF];
        if (src == UINT32_MAX || src >= g.rom_size) continue;
        if (obj) g.rom_obj_pal[src] |= (uint8_t)(1u << pal);
        else     g.rom_bg_pal[src]  |= (uint8_t)(1u << pal);
    }
}

/* Once per frame: walk the active BG/window tilemaps and OAM, read the
 * palette each on-screen tile uses, and credit it back to the tile's ROM
 * source. This is the tile<->palette cross-reference: the link only exists
 * at draw time (in tilemap/OAM attributes), not when the tiles were copied. */
static void scan_tile_palette_associations(void) {
    uint8_t lcdc = g.gb.io_registers[GB_IO_LCDC];
    if (!(lcdc & 0x80)) return;                 /* LCD off */
    const uint8_t *vram = g.gb.vram;
    bool unsigned_td = (lcdc & 0x10) != 0;      /* $8000 vs $8800 addressing */

    for (int pass = 0; pass < 2; pass++) {      /* 0 = BG map, 1 = window map */
        bool is_win = (pass == 1);
        if (is_win && !(lcdc & 0x20)) continue; /* window disabled */
        uint32_t map_base =
            ((is_win ? (lcdc & 0x40) : (lcdc & 0x08)) ? 0x1C00 : 0x1800);
        for (int c = 0; c < 32 * 32; c++) {
            uint8_t idx  = vram[map_base + c];
            uint8_t attr = vram[0x2000 + map_base + c];   /* bank 1 attrs */
            int pal = attr & 7;
            uint32_t td = unsigned_td ? (uint32_t)idx * 16
                                      : (uint32_t)(0x1000 + (int8_t)idx * 16);
            td += (attr & 0x08) ? 0x2000 : 0;             /* tile VRAM bank */
            credit_tile_palette(td, pal, false);
            snapshot_palette(false, pal);
        }
    }

    if (lcdc & 0x02) {                          /* OBJ enabled */
        bool tall = (lcdc & 0x04) != 0;         /* 8x16 sprites */
        for (int s = 0; s < 40; s++) {
            const uint8_t *o = g.gb.oam + s * 4;
            if (o[0] == 0 || o[0] >= 160) continue;       /* parked off-screen */
            uint8_t tile = tall ? (o[2] & 0xFE) : o[2];
            int pal = o[3] & 7;
            uint32_t td = (uint32_t)tile * 16 + ((o[3] & 0x08) ? 0x2000 : 0);
            credit_tile_palette(td, pal, true);
            if (tall) credit_tile_palette(td + 16, pal, true);
            snapshot_palette(true, pal);
        }
    }
}

static void on_vblank(GB_gameboy_t *gb, GB_vblank_type_t type) {
    (void)gb; (void)type;
    g.total_frames++;
    if (g.watch_vram) scan_tile_palette_associations();
}

static void on_log(GB_gameboy_t *gb, const char *string,
                   GB_log_attributes_t attributes) {
    (void)gb; (void)attributes;
    fputs(string, stderr);
}

/* ---------------- SDL input ---------------- */

static void handle_input(void) {
    SDL_Event ev;
    while (SDL_PollEvent(&ev)) {
        if (ev.type == SDL_QUIT) { g.running = 0; return; }
        if (ev.type != SDL_KEYDOWN && ev.type != SDL_KEYUP) continue;

        bool pressed = (ev.type == SDL_KEYDOWN);
        SDL_Keycode key = ev.key.keysym.sym;

        if (pressed) {
            if (key == SDLK_ESCAPE) {
                /* Double-tap to quit. Easy to hit ESC by accident and
                 * lose a long play session, so require two presses within
                 * ~1.5s; the first press just arms the second. */
                static uint32_t esc_armed_at = 0;
                const uint32_t ESC_WINDOW_MS = 1500;
                uint32_t now = SDL_GetTicks();
                if (esc_armed_at && now - esc_armed_at <= ESC_WINDOW_MS) {
                    g.running = 0;
                    return;
                }
                esc_armed_at = now;
                printf("press ESC again within %u ms to quit\n", ESC_WINDOW_MS);
                fflush(stdout);
                continue;
            }
            if (key == SDLK_TAB) {
                g.fast_forward = !g.fast_forward;
                /* The manual frame-pacing SDL_Delay alone isn't enough —
                 * the renderer is created with PRESENTVSYNC, so
                 * SDL_RenderPresent blocks until the next display refresh
                 * (~60 Hz). Toggle vsync off when fast-forwarding. */
                SDL_RenderSetVSync(g.renderer, g.fast_forward ? 0 : 1);
                continue;
            }
        }

        GB_key_t gb_key;
        switch (key) {
            case SDLK_z:         gb_key = GB_KEY_A;      break;
            case SDLK_x:         gb_key = GB_KEY_B;      break;
            case SDLK_BACKSPACE: gb_key = GB_KEY_SELECT; break;
            case SDLK_RETURN:    gb_key = GB_KEY_START;  break;
            case SDLK_RIGHT:     gb_key = GB_KEY_RIGHT;  break;
            case SDLK_LEFT:      gb_key = GB_KEY_LEFT;   break;
            case SDLK_UP:        gb_key = GB_KEY_UP;     break;
            case SDLK_DOWN:      gb_key = GB_KEY_DOWN;   break;
            default: continue;
        }
        GB_set_key_state(&g.gb, gb_key, pressed);
    }
}

/* ---------------- File I/O helpers ---------------- */

static uint8_t *load_file(const char *path, uint32_t *size_out) {
    FILE *f = fopen(path, "rb");
    if (!f) { fprintf(stderr, "error: cannot open %s: %s\n", path, strerror(errno)); return NULL; }
    fseek(f, 0, SEEK_END);
    long len = ftell(f);
    fseek(f, 0, SEEK_SET);
    if (len <= 0) { fclose(f); return NULL; }
    uint8_t *buf = malloc((size_t)len);
    if (!buf) { fclose(f); return NULL; }
    if (fread(buf, 1, (size_t)len, f) != (size_t)len) {
        free(buf); fclose(f); return NULL;
    }
    fclose(f);
    *size_out = (uint32_t)len;
    return buf;
}

static char *read_text_file(const char *path) {
    FILE *f = fopen(path, "rb");
    if (!f) return NULL;
    fseek(f, 0, SEEK_END);
    long len = ftell(f);
    fseek(f, 0, SEEK_SET);
    if (len < 0) { fclose(f); return NULL; }
    char *buf = malloc((size_t)len + 1);
    if (!buf) { fclose(f); return NULL; }
    if (fread(buf, 1, (size_t)len, f) != (size_t)len) {
        free(buf); fclose(f); return NULL;
    }
    buf[len] = '\0';
    fclose(f);
    return buf;
}

/* ---------------- map.json: load + merge ---------------- */

static void cover_range(uint32_t start, uint32_t len) {
    if (start >= g.rom_size) return;
    uint32_t end = start + len;
    if (end > g.rom_size) end = g.rom_size;
    memset(g.covered + start, 1, end - start);
}

static cJSON *load_map_json_root(const char *path) {
    char *text = read_text_file(path);
    cJSON *root = NULL;
    if (text) {
        root = cJSON_Parse(text);
        free(text);
    }
    if (!root) {
        root = cJSON_CreateObject();
        cJSON_AddArrayToObject(root, "files");
    }
    if (!cJSON_GetObjectItem(root, "files"))
        cJSON_AddArrayToObject(root, "files");
    return root;
}

static void mark_covered_from_map(cJSON *root) {
    /* Header is reserved by extract.py — keep our hands off it. */
    cover_range(HEADER_START, HEADER_END - HEADER_START);

    cJSON *files = cJSON_GetObjectItem(root, "files");
    if (!cJSON_IsArray(files)) return;

    cJSON *file;
    cJSON_ArrayForEach(file, files) {
        cJSON *jname = cJSON_GetObjectItem(file, "name");
        cJSON *jtype = cJSON_GetObjectItem(file, "type");
        if (!cJSON_IsString(jname) || !cJSON_IsString(jtype)) continue;
        if (strcmp(jname->valuestring, ANALYZED_FILE_NAME) == 0) continue;

        if (strcmp(jtype->valuestring, "code") == 0) {
            cJSON *secs = cJSON_GetObjectItem(file, "sections");
            if (!cJSON_IsArray(secs)) continue;
            cJSON *s;
            cJSON_ArrayForEach(s, secs) {
                cJSON *ja = cJSON_GetObjectItem(s, "addr");
                cJSON *jl = cJSON_GetObjectItem(s, "len");
                if (cJSON_IsNumber(ja) && cJSON_IsNumber(jl))
                    cover_range((uint32_t)ja->valuedouble, (uint32_t)jl->valuedouble);
            }
        } else if (strcmp(jtype->valuestring, "data") == 0) {
            cJSON *ja = cJSON_GetObjectItem(file, "addr");
            cJSON *jl = cJSON_GetObjectItem(file, "len");
            if (cJSON_IsNumber(ja) && cJSON_IsNumber(jl))
                cover_range((uint32_t)ja->valuedouble, (uint32_t)jl->valuedouble);
        }
    }
}

/* Restore the previous analyzer state from map.json so coverage and
 * conflict observations accumulate across sessions instead of starting
 * blank every launch. Reads:
 *   - the analyzed.asm entry's sections → CODE / DATA per `type`
 *   - the top-level "conflicts" array    → CONFLICT
 *
 * Bytes already in `covered` (a user-curated section or the header)
 * are skipped — those are off-limits and rom_map for them is unused
 * anyway. Returns counts purely for the load-time log. */
static void load_prior_rom_map(cJSON *root) {
    uint32_t code_n = 0, data_n = 0, conflict_n = 0;

    cJSON *files = cJSON_GetObjectItem(root, "files");
    if (cJSON_IsArray(files)) {
        cJSON *file;
        cJSON_ArrayForEach(file, files) {
            cJSON *jname = cJSON_GetObjectItem(file, "name");
            if (!cJSON_IsString(jname)) continue;
            if (strcmp(jname->valuestring, ANALYZED_FILE_NAME) != 0) continue;
            cJSON *secs = cJSON_GetObjectItem(file, "sections");
            if (!cJSON_IsArray(secs)) continue;
            cJSON *s;
            cJSON_ArrayForEach(s, secs) {
                cJSON *jt = cJSON_GetObjectItem(s, "type");
                cJSON *ja = cJSON_GetObjectItem(s, "addr");
                cJSON *jl = cJSON_GetObjectItem(s, "len");
                if (!cJSON_IsString(jt) || !cJSON_IsNumber(ja) || !cJSON_IsNumber(jl))
                    continue;
                uint8_t kind;
                bool gfx = false;
                if (strcmp(jt->valuestring, "code") == 0)      kind = REGION_CODE;
                else if (strcmp(jt->valuestring, "data") == 0) kind = REGION_DATA;
                else if (strcmp(jt->valuestring, "gfx") == 0) { kind = REGION_DATA; gfx = true; }
                else continue;
                uint32_t a = (uint32_t)ja->valuedouble;
                uint32_t l = (uint32_t)jl->valuedouble;
                for (uint32_t i = 0; i < l && (a + i) < g.rom_size; i++) {
                    if (g.covered[a + i]) continue;
                    g.rom_map[a + i] = kind;
                    if (gfx) g.is_gfx[a + i] = 1;   /* persist gfx classification */
                    if (kind == REGION_CODE) code_n++; else data_n++;
                }
            }
        }
    }

    /* CONFLICT overrides DATA from analyzed.asm (those bytes are stored
     * as data in the file entry per the defensive rule, but tagged
     * separately here so we don't lose the "both observed" fact). */
    cJSON *conflicts = cJSON_GetObjectItem(root, "conflicts");
    if (cJSON_IsArray(conflicts)) {
        cJSON *e;
        cJSON_ArrayForEach(e, conflicts) {
            cJSON *ja = cJSON_GetObjectItem(e, "addr");
            cJSON *jl = cJSON_GetObjectItem(e, "len");
            if (!cJSON_IsNumber(ja) || !cJSON_IsNumber(jl)) continue;
            uint32_t a = (uint32_t)ja->valuedouble;
            uint32_t l = (uint32_t)jl->valuedouble;
            for (uint32_t i = 0; i < l && (a + i) < g.rom_size; i++) {
                if (g.covered[a + i]) continue;
                /* Restoring CONFLICT — the byte was both code- and data-
                 * observed in a previous session; without this we'd come
                 * back as just DATA (per analyzed.asm) and forget the
                 * code observation. */
                if (g.rom_map[a + i] == REGION_DATA) data_n--;
                else if (g.rom_map[a + i] == REGION_CODE) code_n--;
                g.rom_map[a + i] = REGION_CONFLICT;
                conflict_n++;
            }
        }
    }

    if (code_n || data_n || conflict_n) {
        printf("restored prior state: code %u, data %u, conflict %u bytes\n",
               code_n, data_n, conflict_n);
    }
}

static const char *section_kind(uint8_t v) {
    switch (v) {
        case REGION_CODE:     return "code";
        case REGION_DATA:     return "data";
        case REGION_CONFLICT: return "data"; /* defensive */
        default:              return NULL;
    }
}

static void add_section(cJSON *sections, const char *type,
                        uint32_t start, uint32_t len) {
    cJSON *sec = cJSON_CreateObject();
    cJSON_AddStringToObject(sec, "type", type);
    cJSON_AddNumberToObject(sec, "addr", (double)start);
    cJSON_AddNumberToObject(sec, "len",  (double)len);
    cJSON_AddItemToArray(sections, sec);
}

/* Emit-time kind for byte i: like section_kind(), but a DATA byte that the
 * VRAM trace proved is verbatim tiledata becomes "gfx". Code/conflict win
 * over gfx (an executed byte is code, full stop). */
static const char *effective_kind(uint32_t i, const uint8_t *snapshot) {
    const char *k = section_kind(snapshot[i]);
    if (k && snapshot[i] == REGION_DATA && g.is_gfx[i]) return "gfx";
    return k;
}

static cJSON *build_analyzed_entry(const uint8_t *snapshot) {
    cJSON *entry = cJSON_CreateObject();
    cJSON_AddStringToObject(entry, "type", "code");
    cJSON_AddStringToObject(entry, "name", ANALYZED_FILE_NAME);
    cJSON *sections = cJSON_AddArrayToObject(entry, "sections");

    uint32_t i = 0;
    while (i < g.rom_size) {
        if (g.covered[i]) { i++; continue; }
        const char *kind = effective_kind(i, snapshot);
        if (!kind) { i++; continue; }
        uint32_t start = i;
        while (i < g.rom_size && !g.covered[i]) {
            /* Break at bank boundaries (every 0x4000 bytes) — each
             * rgbasm SECTION must live in a single bank, so a run that
             * would cross from bank N into bank N+1 has to be split. */
            if (i > start && (i & 0x3FFF) == 0) break;
            const char *k = effective_kind(i, snapshot);
            if (!k || strcmp(k, kind) != 0) break;
            i++;
        }
        uint32_t len = i - start;
        if (strcmp(kind, "gfx") == 0) {
            /* gfx must be whole 16-byte tiles and large enough to be worth
             * it; emit the tile-aligned head as gfx and any leftover as
             * data, or keep the whole run as data if it's too small. */
            uint32_t tiles = len & ~(uint32_t)0xF;
            if (tiles >= GFX_MIN_BYTES) {
                add_section(sections, "gfx", start, tiles);
                if (len > tiles)
                    add_section(sections, "data", start + tiles, len - tiles);
                continue;
            }
            kind = "data";
        }
        add_section(sections, kind, start, len);
    }
    return entry;
}

/* Sibling structure to "files": every contiguous run of bytes that
 * was both PC-visited AND read-as-data (REGION_CONFLICT) is emitted
 * here with its (addr, len). These bytes are also still represented in
 * the analyzed.asm sections (as `data`, per the defensive rule) so the
 * disassembly round-trips byte-exact; this array exists purely as an
 * index for investigation — usually the trigger is OAM DMA from a low
 * source page bleeding over executed code. */
static cJSON *build_conflict_array(const uint8_t *snapshot) {
    cJSON *arr = cJSON_CreateArray();
    uint32_t i = 0;
    while (i < g.rom_size) {
        if (g.covered[i] || snapshot[i] != REGION_CONFLICT) {
            i++;
            continue;
        }
        uint32_t start = i;
        while (i < g.rom_size && !g.covered[i] &&
               snapshot[i] == REGION_CONFLICT) {
            if (i > start && (i & 0x3FFF) == 0) break;  /* bank boundary */
            i++;
        }
        cJSON *e = cJSON_CreateObject();
        cJSON_AddNumberToObject(e, "addr", (double)start);
        cJSON_AddNumberToObject(e, "len",  (double)(i - start));
        cJSON_AddItemToArray(arr, e);
    }
    return arr;
}

static int write_json_atomic(const char *path, cJSON *root) {
    char *out = cJSON_Print(root);
    if (!out) return -1;
    size_t plen = strlen(path);
    char *tmp = malloc(plen + 5);
    if (!tmp) { free(out); return -1; }
    snprintf(tmp, plen + 5, "%s.tmp", path);
    FILE *f = fopen(tmp, "w");
    if (!f) { free(out); free(tmp); return -1; }
    fputs(out, f);
    fputc('\n', f);
    fclose(f);
    free(out);
    int rc = rename(tmp, path);
    free(tmp);
    return rc;
}

static void perform_save(void) {
    uint8_t *snap = malloc(g.rom_size);
    if (!snap) return;
    memcpy(snap, g.rom_map, g.rom_size);

    cJSON *root = load_map_json_root(g.map_path);
    cJSON *files = cJSON_GetObjectItem(root, "files");

    int idx = 0;
    cJSON *file;
    cJSON_ArrayForEach(file, files) {
        cJSON *jname = cJSON_GetObjectItem(file, "name");
        if (cJSON_IsString(jname) &&
            strcmp(jname->valuestring, ANALYZED_FILE_NAME) == 0) {
            cJSON_DeleteItemFromArray(files, idx);
            break;
        }
        idx++;
    }

    cJSON *entry = build_analyzed_entry(snap);
    cJSON_AddItemToArray(files, entry);

    /* Replace any previous "conflicts" sibling with a fresh snapshot. */
    cJSON_DeleteItemFromObject(root, "conflicts");
    cJSON_AddItemToObject(root, "conflicts", build_conflict_array(snap));

    if (write_json_atomic(g.map_path, root) != 0)
        fprintf(stderr, "error: failed to write %s: %s\n",
                g.map_path, strerror(errno));

    cJSON_Delete(root);
    free(snap);
    g.saves_done++;
}

/* ---------------- Coverage summary ---------------- */

static void print_coverage(void) {
    uint32_t code = 0, data = 0, conflict = 0, covered_n = 0;
    for (uint32_t i = 0; i < g.rom_size; i++) {
        if (g.covered[i]) { covered_n++; continue; }
        switch (g.rom_map[i]) {
            case REGION_CODE:     code++;     break;
            case REGION_DATA:     data++;     break;
            case REGION_CONFLICT: conflict++; break;
            default:                          break;
        }
    }
    uint32_t analyzed = code + data + conflict;
    uint32_t available = g.rom_size - covered_n;
    double pct = available ? 100.0 * analyzed / available : 0.0;
    printf("  coverage: %u/%u uncovered bytes analyzed (%.1f%%) — "
           "code %u, data %u, conflict %u | %llu insns\n",
           analyzed, available, pct, code, data, conflict,
           (unsigned long long)g.total_instructions);
}

/* ---------------- Writer thread ---------------- */

static void *writer_main(void *arg) {
    (void)arg;
    while (1) {
        struct timespec abs_ts;
        clock_gettime(CLOCK_REALTIME, &abs_ts);
        abs_ts.tv_sec += g.save_interval_sec;

        pthread_mutex_lock(&g.writer_mtx);
        while (!g.writer_should_stop) {
            int rc = pthread_cond_timedwait(&g.writer_cv, &g.writer_mtx, &abs_ts);
            if (rc == ETIMEDOUT) break;
        }
        int should_stop = g.writer_should_stop;
        pthread_mutex_unlock(&g.writer_mtx);

        printf("[checkpoint #%u] ", g.saves_done + 1);
        perform_save();
        print_coverage();

        if (should_stop) break;
    }
    return NULL;
}

/* ---------------- CLI ---------------- */

static void print_usage(const char *prog) {
    fprintf(stderr,
        "Usage: %s --rom <rom.gbc> --map <map.json> [options]\n"
        "\n"
        "Plays the ROM in an SDL window (SameBoy Core, CGB-correct) and merges\n"
        "discovered code/data sections into map.json under `analyzed.asm`.\n"
        "\n"
        "Options:\n"
        "  --save-interval N   Checkpoint map.json every N seconds (default 10).\n"
        "  --no-save           Don't load or write the battery save (<rom>.sav).\n"
        "                      Use for headless smoke tests so a real session's\n"
        "                      save can't be clobbered.\n"
        "  --watch-write LIST  Log every CPU write to any address in LIST. LIST is\n"
        "                      a comma-separated set of 16-bit addresses (hex,\n"
        "                      optionally prefixed with $ or 0x). Each log line\n"
        "                      prints the value written and the PC bank:addr.\n"
        "                      Example: --watch-write $D5FF,$D600,$CFF0\n"
        "  --watch-log PATH    Write --watch-write lines to PATH (default stderr).\n"
        "  --watch-vram [PATH] Trace which ROM regions are copied into VRAM,\n"
        "                      classifying them as tiledata vs tilemap and as\n"
        "                      from-ROM (uncompressed) vs from-RAM (decompressed).\n"
        "                      Logs each HDMA and prints a region report on exit\n"
        "                      to PATH (default stderr). Does not modify map.json.\n"
        "\n"
        "Controls:\n"
        "  Arrows     D-pad\n"
        "  Z          A         X      B\n"
        "  Enter      Start     Bksp   Select\n"
        "  Tab        Toggle fast-forward\n"
        "  Esc        Quit (press twice within 1.5s)\n",
        prog);
}

/* Parse a comma-separated list of 16-bit hex addresses into g.watch_write.
 * Accepts `$`, `0x`, or bare hex per item. Returns 0 on success. */
static int parse_watch_list(const char *spec) {
    const char *p = spec;
    while (*p) {
        while (*p == ',' || *p == ' ' || *p == '\t') p++;
        if (!*p) break;
        if (*p == '$') p++;
        else if (p[0] == '0' && (p[1] == 'x' || p[1] == 'X')) p += 2;
        char *end;
        unsigned long v = strtoul(p, &end, 16);
        if (end == p) {
            fprintf(stderr, "error: bad watch address in '%s'\n", spec);
            return -1;
        }
        if (v > 0xFFFF) {
            fprintf(stderr, "error: watch address $%lx out of CPU range\n", v);
            return -1;
        }
        g.watch_write[v] = true;
        g.watch_any = true;
        p = end;
    }
    return 0;
}

static int parse_args(int argc, char **argv) {
    g.save_interval_sec = DEFAULT_SAVE_INTERVAL_SEC;
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--rom") == 0 && i + 1 < argc) {
            g.rom_path = argv[++i];
        } else if (strcmp(argv[i], "--map") == 0 && i + 1 < argc) {
            g.map_path = argv[++i];
        } else if (strcmp(argv[i], "--save-interval") == 0 && i + 1 < argc) {
            g.save_interval_sec = (uint32_t)atoi(argv[++i]);
            if (g.save_interval_sec == 0) g.save_interval_sec = 1;
        } else if (strcmp(argv[i], "--no-save") == 0) {
            g.no_save = true;
        } else if (strcmp(argv[i], "--watch-write") == 0 && i + 1 < argc) {
            if (parse_watch_list(argv[++i]) != 0) return 1;
        } else if (strcmp(argv[i], "--watch-log") == 0 && i + 1 < argc) {
            g.watch_log_path = argv[++i];
        } else if (strcmp(argv[i], "--watch-vram") == 0) {
            g.watch_vram = true;
            /* Optional path arg: a following token that isn't another flag. */
            if (i + 1 < argc && argv[i + 1][0] != '-')
                g.vram_log_path = argv[++i];
        } else if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0) {
            print_usage(argv[0]);
            return 0;
        } else {
            fprintf(stderr, "unknown argument: %s\n", argv[i]);
            return 1;
        }
    }
    if (!g.rom_path || !g.map_path) {
        print_usage(argv[0]);
        return 1;
    }
    return -1;
}

/* Coalesce per-byte VRAM-source marks into contiguous same-kind runs and
 * write a report. Runs shorter than one tile (16 bytes) are noise from the
 * single-byte CPU heuristic (e.g. a value written to VRAM that happened to
 * match a stale ROM read) and are summarized, not listed. */
static const char *vsrc_kind_name(uint8_t k) {
    switch (k) {
        case VSRC_TILEDATA: return "tiledata";
        case VSRC_TILEMAP:  return "tilemap";
        case VSRC_PALETTE:  return "palette";
        default:            return "mixed";   /* >1 destination kind */
    }
}

/* Print the palettes that were actually applied to tiles, using the colors
 * snapshotted the first frame each palette was seen in use (RGB555, 5-bit
 * components). These are what colorize the extracted tile PNGs. */
static void dump_seen_palettes(FILE *o, const char *tag, uint16_t seen,
                               const uint8_t colors[8][8]) {
    for (int p = 0; p < 8; p++) {
        if (!(seen & (1u << p))) continue;
        fprintf(o, "[vram]   %s pal %d:", tag, p);
        for (int c = 0; c < 4; c++) {
            unsigned v = colors[p][c * 2] | ((unsigned)colors[p][c * 2 + 1] << 8);
            fprintf(o, " %02X,%02X,%02X", v & 0x1F, (v >> 5) & 0x1F, (v >> 10) & 0x1F);
        }
        fprintf(o, "\n");
    }
}

/* Format the BG/OBJ palette bitmasks observed for a region, e.g. "bg{0,3}"
 * or "bg{1} obj{2}" or "-" if no palette was ever cross-referenced. */
static void format_region_pals(char *buf, size_t n, uint8_t bgm, uint8_t objm) {
    size_t k = 0; buf[0] = 0;
    for (int pass = 0; pass < 2; pass++) {
        uint8_t m = pass ? objm : bgm;
        if (!m) continue;
        k += (size_t)snprintf(buf + k, k < n ? n - k : 0,
                              "%s%s{", k ? " " : "", pass ? "obj" : "bg");
        bool first = true;
        for (int p = 0; p < 8; p++)
            if (m & (1u << p)) {
                k += (size_t)snprintf(buf + k, k < n ? n - k : 0,
                                      "%s%d", first ? "" : ",", p);
                first = false;
            }
        k += (size_t)snprintf(buf + k, k < n ? n - k : 0, "}");
    }
    if (!buf[0]) snprintf(buf, n, "-");
}

static void vram_report(void) {
    if (!g.watch_vram || !g.vram_src_kind) return;
    FILE *o = g.vram_log;
    fprintf(o, "\n[vram] ===== ROM->VRAM provenance report =====\n");
    fprintf(o, "[vram] CPU verbatim copies (marked): tiledata %llu, tilemap %llu\n",
        (unsigned long long)g.cpu_tiledata_marked,
        (unsigned long long)g.cpu_tilemap_marked);
    fprintf(o, "[vram] CPU verbatim palette copies (marked): %llu\n",
        (unsigned long long)g.cpu_palette_marked);
    fprintf(o, "[vram] CPU rejected (ROM read but value differs — transformed): "
               "tiledata %llu, tilemap %llu, palette %llu\n",
        (unsigned long long)g.cpu_tiledata_rejected,
        (unsigned long long)g.cpu_tilemap_rejected,
        (unsigned long long)g.cpu_palette_rejected);
    fprintf(o, "[vram] CPU writes not from ROM (RAM/computed): %llu\n",
        (unsigned long long)g.cpu_vram_from_ram);
    fprintf(o, "[vram] HDMA bytes: from ROM %llu, from RAM (decompressed) %llu\n",
        (unsigned long long)g.hdma_from_rom_bytes,
        (unsigned long long)g.hdma_from_ram_bytes);
    fprintf(o, "[vram] palettes seen applied to tiles (first-use RGB555):\n");
    dump_seen_palettes(o, "BG ", g.bg_pal_seen, g.bg_pal_colors);
    dump_seen_palettes(o, "OBJ", g.obj_pal_seen, g.obj_pal_colors);

    uint64_t total_marked = 0, listed = 0, noise = 0;
    uint32_t i = 0, runs = 0;
    fprintf(o, "[vram] ROM regions feeding VRAM (runs >= 16 bytes):\n");
    while (i < g.rom_size) {
        uint8_t k = g.vram_src_kind[i];
        if (!k) { i++; continue; }
        uint32_t start = i;
        uint8_t bgm = 0, objm = 0;
        while (i < g.rom_size && g.vram_src_kind[i] == k) {
            bgm |= g.rom_bg_pal[i]; objm |= g.rom_obj_pal[i]; i++;
        }
        uint32_t len = i - start;
        total_marked += len;
        if (len >= 16) {
            char pbuf[80];
            format_region_pals(pbuf, sizeof pbuf, bgm, objm);
            fprintf(o, "[vram]   0x%06X +0x%-5X (%6u)  %-8s  bank $%02X  %s\n",
                start, len, len, vsrc_kind_name(k),
                (unsigned)(start / 0x4000), pbuf);
            listed += len; runs++;
        } else {
            noise += len;
        }
    }
    fprintf(o, "[vram] %u runs listed (%llu bytes); %llu bytes in sub-tile "
               "noise runs; %llu total marked\n",
        runs, (unsigned long long)listed,
        (unsigned long long)noise, (unsigned long long)total_marked);
    fflush(o);
}

/* ---------------- Main ---------------- */

int main(int argc, char **argv) {
    int rc = parse_args(argc, argv);
    if (rc != -1) return rc;

    g.rom_data = load_file(g.rom_path, &g.rom_size);
    if (!g.rom_data) return 1;
    printf("loaded %s (%u bytes)\n", g.rom_path, g.rom_size);

    g.rom_map   = calloc(g.rom_size, 1);
    g.covered   = calloc(g.rom_size, 1);
    g.insn_byte = calloc(g.rom_size, 1);
    g.is_gfx    = calloc(g.rom_size, 1);
    if (!g.rom_map || !g.covered || !g.insn_byte || !g.is_gfx) {
        fprintf(stderr, "out of memory\n");
        return 1;
    }

    {
        cJSON *root = load_map_json_root(g.map_path);
        mark_covered_from_map(root);
        load_prior_rom_map(root);
        cJSON_Delete(root);
    }

    /* SDL */
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS) < 0) {
        fprintf(stderr, "SDL_Init: %s\n", SDL_GetError());
        return 1;
    }

    /* SameBoy — initialize as CGB-E (the standard CGB revision). */
    GB_init(&g.gb, GB_MODEL_CGB_E);
    GB_set_log_callback(&g.gb, on_log);
    GB_load_rom_from_buffer(&g.gb, g.rom_data, g.rom_size);
    GB_load_boot_rom_from_buffer(&g.gb, cgb_boot_stub, sizeof(cgb_boot_stub));

    /* Battery save file: <rom>.sav alongside the ROM. Silently skip the
     * load if it doesn't exist yet (first run). --no-save bypasses both
     * the load and the save-on-exit so headless / scratch runs can't
     * clobber a real session's save. */
    if (!g.no_save) {
        size_t rlen = strlen(g.rom_path);
        g.battery_path = malloc(rlen + 5);
        snprintf(g.battery_path, rlen + 5, "%s.sav", g.rom_path);
        if (GB_load_battery(&g.gb, g.battery_path) == 0)
            printf("loaded battery save from %s\n", g.battery_path);
    } else {
        printf("battery save disabled (--no-save)\n");
    }

    GB_set_rgb_encode_callback(&g.gb, rgb_encode);
    GB_set_pixels_output(&g.gb, g.framebuffer);
    GB_set_vblank_callback(&g.gb, on_vblank);
    GB_set_execution_callback(&g.gb, on_execution);
    GB_set_read_memory_callback(&g.gb, on_read_memory);
    GB_set_write_memory_callback(&g.gb, on_write_memory);

    g.watch_log = stderr;
    if (g.watch_log_path) {
        FILE *wf = fopen(g.watch_log_path, "w");
        if (!wf) {
            fprintf(stderr, "warning: cannot open %s for watch log (%s); "
                            "falling back to stderr\n",
                    g.watch_log_path, strerror(errno));
        } else {
            g.watch_log = wf;
            printf("watch log -> %s\n", g.watch_log_path);
        }
    }
    if (g.watch_any) {
        printf("watching writes to:");
        for (int wa = 0; wa < 0x10000; wa++) {
            if (g.watch_write[wa]) printf(" $%04X", wa);
        }
        printf("\n");
    }

    if (g.watch_vram) {
        g.vram_src_kind = calloc(g.rom_size, 1);
        g.rom_bg_pal    = calloc(g.rom_size, 1);
        g.rom_obj_pal   = calloc(g.rom_size, 1);
        g.vram_byte_src = malloc(0x4000 * sizeof(uint32_t));
        if (!g.vram_src_kind || !g.rom_bg_pal || !g.rom_obj_pal ||
            !g.vram_byte_src) { fprintf(stderr, "out of memory\n"); return 1; }
        for (int v = 0; v < 0x4000; v++) g.vram_byte_src[v] = UINT32_MAX;
        g.last_data_read = UINT32_MAX;
        g.vram_log = stderr;
        if (g.vram_log_path) {
            FILE *vf = fopen(g.vram_log_path, "w");
            if (!vf) {
                fprintf(stderr, "warning: cannot open %s for vram log (%s); "
                                "falling back to stderr\n",
                        g.vram_log_path, strerror(errno));
            } else {
                g.vram_log = vf;
                printf("vram provenance log -> %s\n", g.vram_log_path);
            }
        }
        printf("tracing VRAM-write provenance (--watch-vram)\n");
    }

    g.screen_w = GB_get_screen_width(&g.gb);
    g.screen_h = GB_get_screen_height(&g.gb);

    g.window = SDL_CreateWindow(
        "Monster Rancher Explorer — analyzer",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        g.screen_w * WINDOW_SCALE, g.screen_h * WINDOW_SCALE,
        SDL_WINDOW_SHOWN);
    if (!g.window) { fprintf(stderr, "SDL_CreateWindow: %s\n", SDL_GetError()); return 1; }

    g.renderer = SDL_CreateRenderer(g.window, -1,
        SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (!g.renderer)
        g.renderer = SDL_CreateRenderer(g.window, -1, SDL_RENDERER_SOFTWARE);
    if (!g.renderer) { fprintf(stderr, "SDL_CreateRenderer: %s\n", SDL_GetError()); return 1; }

    g.texture = SDL_CreateTexture(g.renderer, SDL_PIXELFORMAT_ARGB8888,
        SDL_TEXTUREACCESS_STREAMING, g.screen_w, g.screen_h);
    if (!g.texture) { fprintf(stderr, "SDL_CreateTexture: %s\n", SDL_GetError()); return 1; }

    /* Writer thread */
    pthread_mutex_init(&g.writer_mtx, NULL);
    pthread_cond_init(&g.writer_cv, NULL);
    g.writer_should_stop = 0;
    pthread_create(&g.writer_thread, NULL, writer_main, NULL);

    printf("ready (CGB-E). saving map.json every %u s. esc/close to quit.\n",
           g.save_interval_sec);

    /* Main loop */
    signal(SIGINT, on_signal);
    signal(SIGTERM, on_signal);
    g.running = 1;
    uint32_t frame_start = SDL_GetTicks();
    while (g.running) {
        GB_run_frame(&g.gb);

        SDL_UpdateTexture(g.texture, NULL, g.framebuffer,
                          g.screen_w * sizeof(uint32_t));
        SDL_RenderClear(g.renderer);
        SDL_RenderCopy(g.renderer, g.texture, NULL, NULL);
        SDL_RenderPresent(g.renderer);

        handle_input();

        if (!g.fast_forward) {
            uint32_t now = SDL_GetTicks();
            uint32_t elapsed = now - frame_start;
            if (elapsed < 16) SDL_Delay(16 - elapsed);
        }
        frame_start = SDL_GetTicks();
    }

    /* Shutdown */
    pthread_mutex_lock(&g.writer_mtx);
    g.writer_should_stop = 1;
    pthread_cond_signal(&g.writer_cv);
    pthread_mutex_unlock(&g.writer_mtx);
    pthread_join(g.writer_thread, NULL);

    /* Persist cart RAM so the next session resumes where we left off.
     * Done from the main thread (after the loop) so there's no race with
     * the emulator writing to MBC RAM. */
    if (!g.no_save && g.battery_path &&
        GB_save_battery(&g.gb, g.battery_path) == 0)
        printf("saved battery to %s\n", g.battery_path);

    printf("[exit] %llu frames, %llu instructions, %u saves\n",
           (unsigned long long)g.total_frames,
           (unsigned long long)g.total_instructions,
           g.saves_done);

    vram_report();

    SDL_DestroyTexture(g.texture);
    SDL_DestroyRenderer(g.renderer);
    SDL_DestroyWindow(g.window);
    SDL_Quit();

    GB_free(&g.gb);
    pthread_mutex_destroy(&g.writer_mtx);
    pthread_cond_destroy(&g.writer_cv);
    if (g.watch_log && g.watch_log != stderr) fclose(g.watch_log);
    if (g.vram_log && g.vram_log != stderr) fclose(g.vram_log);
    free(g.vram_src_kind);
    free(g.rom_bg_pal);
    free(g.rom_obj_pal);
    free(g.vram_byte_src);
    free(g.rom_data);
    free(g.rom_map);
    free(g.covered);
    free(g.insn_byte);
    free(g.is_gfx);
    free(g.battery_path);
    return 0;
}
