/*
 * Runtime ROM analyzer for the Monster Rancher Explorer disassembly.
 *
 * Plays the ROM in an SDL window through Peanut-GB while classifying every
 * ROM byte as code (PC visited) or data (read non-fetch). Bytes that hit
 * both criteria are defensively marked as data.
 *
 * Findings are merged into the project's map.json under a single auto-
 * managed file entry named `analyzed.asm`. User-curated entries in the
 * map (anything else) and the reserved header at 0x100-0x14F are never
 * touched.
 *
 * Threads:
 *   main    SDL render, gb_run_frame, input
 *   writer  every --save-interval seconds (default 10) and once on exit,
 *           snapshots the per-byte map and rewrites map.json
 *
 * Usage:
 *   analyzer --rom rom.gbc --map map.json [--save-interval 10]
 *
 * Controls: Arrows = D-pad, Z/X = A/B, Enter = Start, Backspace = Select,
 * Tab toggles fast-forward, Escape or window close quits.
 */

#include <errno.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#include <SDL2/SDL.h>

#include "cJSON.h"

/* ---------------- ROM byte annotations ---------------- */

enum {
    REGION_UNKNOWN  = 0,
    REGION_CODE     = 1,
    REGION_DATA     = 2,
    REGION_CONFLICT = 3, /* both observed — emitted as data */
};

/* ---------------- Globals & forward decls ---------------- */

#define GB_SCREEN_W 160
#define GB_SCREEN_H 144
#define WINDOW_SCALE 3
#define DEFAULT_SAVE_INTERVAL_SEC 10

static const uint32_t dmg_palette[4] = {
    0xFFE0F8D0, 0xFF88C070, 0xFF346856, 0xFF081820,
};

typedef struct {
    /* ROM */
    uint8_t  *rom_data;
    uint32_t  rom_size;

    /* Per-byte annotation arrays, both rom_size long.
       Single-byte stores from emulator thread; writer thread memcpys a
       snapshot before serializing — torn reads on a per-byte array
       can't tear since each location is one byte. */
    uint8_t  *rom_map;
    /* covered[i] = 1 if byte i is owned by a user-curated entry in
       map.json (or by the reserved header). The analyzer pre-marks these
       so it never emits a section that overlaps user-curated content. */
    uint8_t  *covered;

    /* Cart RAM (battery-backed save data, etc.). 128 KiB covers MBC5. */
    uint8_t  *cart_ram;
    uint32_t  cart_ram_size;

    /* Current instruction tracking (set by pre_step_hook, consumed by
       rom_read to distinguish opcode fetches from data reads). */
    uint32_t  current_insn_flat_pc;
    uint8_t   current_insn_len;

    /* Runtime stats */
    uint64_t  total_instructions;
    uint64_t  total_frames;

    /* SDL */
    SDL_Window   *window;
    SDL_Renderer *renderer;
    SDL_Texture  *texture;
    uint32_t      framebuffer[GB_SCREEN_W * GB_SCREEN_H];

    /* Run state */
    volatile int running;
    bool         fast_forward;

    /* CLI */
    const char *rom_path;
    const char *map_path;
    uint32_t    save_interval_sec;

    /* Writer thread */
    pthread_t       writer_thread;
    pthread_mutex_t writer_mtx;
    pthread_cond_t  writer_cv;
    int             writer_should_stop;
    uint32_t        saves_done;
} analyzer_t;

static analyzer_t g;

/* ---------------- SM83 instruction length table ----------------
 * Length of a single GBZ80 (a.k.a. SM83) instruction in bytes,
 * indexed by the first opcode byte.  $CB-prefixed instructions are
 * uniformly 2 bytes (entry $CB is 2).  Illegal opcodes are listed as
 * 1 byte — Peanut-GB will trap them via the error callback. */
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

static inline uint8_t sm83_insn_length(uint8_t op) {
    return sm83_length_table[op];
}

/* ---------------- mark code / data ---------------- */

static void mark_code(uint32_t addr, uint8_t len) {
    for (uint8_t i = 0; i < len; i++) {
        uint32_t a = addr + i;
        if (a >= g.rom_size || g.covered[a]) continue;
        uint8_t cur = g.rom_map[a];
        if (cur == REGION_DATA)         g.rom_map[a] = REGION_CONFLICT;
        else if (cur == REGION_UNKNOWN) g.rom_map[a] = REGION_CODE;
    }
}

static void mark_data(uint32_t addr) {
    if (addr >= g.rom_size || g.covered[addr]) return;
    uint8_t cur = g.rom_map[addr];
    if (cur == REGION_CODE)         g.rom_map[addr] = REGION_CONFLICT;
    else if (cur == REGION_UNKNOWN) g.rom_map[addr] = REGION_DATA;
}

/* ---------------- Peanut-GB hook + config ---------------- */

struct gb_s; /* forward — completed by peanut_gb.h */
static void pre_step_hook(struct gb_s *gb);

#define PEANUT_GB_PRE_STEP_HOOK(gb) pre_step_hook(gb)
#define ENABLE_LCD 1
#define ENABLE_SOUND 0
#define PEANUT_GB_HIGH_LCD_ACCURACY 0
#include "peanut_gb.h"

/* ---------------- ROM banking ---------------- */

static uint32_t resolve_rom_addr(struct gb_s *gb, uint16_t addr) {
    if (addr <= 0x3FFF) return addr;
    if (addr <= 0x7FFF)
        return (uint32_t)gb->selected_rom_bank * 0x4000 + (addr - 0x4000);
    return addr; /* WRAM/HRAM — not in ROM */
}

/* ---------------- Pre-instruction hook ---------------- */

static void pre_step_hook(struct gb_s *gb) {
    uint16_t pc = gb->cpu_reg.pc.reg;
    uint32_t flat = resolve_rom_addr(gb, pc);

    if (pc >= 0x8000 || flat >= g.rom_size) {
        g.current_insn_flat_pc = UINT32_MAX;
        g.current_insn_len     = 0;
        return;
    }

    uint8_t opcode = g.rom_data[flat];
    uint8_t ilen   = sm83_insn_length(opcode);
    mark_code(flat, ilen);

    g.current_insn_flat_pc = flat;
    g.current_insn_len     = ilen;
    g.total_instructions++;
}

/* ---------------- Peanut-GB callbacks ---------------- */

static uint8_t rom_read(struct gb_s *gb, const uint_fast32_t addr) {
    (void)gb;
    if (addr >= g.rom_size) return 0xFF;
    /* A read outside the current instruction's bytes is a data access. */
    uint32_t flat = g.current_insn_flat_pc;
    uint8_t  ilen = g.current_insn_len;
    if (ilen == 0 || addr < flat || addr >= (uint32_t)(flat + ilen))
        mark_data((uint32_t)addr);
    return g.rom_data[addr];
}

static uint8_t cart_ram_read(struct gb_s *gb, const uint_fast32_t addr) {
    (void)gb;
    if (g.cart_ram && addr < g.cart_ram_size) return g.cart_ram[addr];
    return 0xFF;
}

static void cart_ram_write(struct gb_s *gb, const uint_fast32_t addr,
                           const uint8_t val) {
    (void)gb;
    if (g.cart_ram && addr < g.cart_ram_size) g.cart_ram[addr] = val;
}

static void error_handler(struct gb_s *gb, const enum gb_error_e err,
                          const uint16_t addr) {
    (void)gb;
    const char *msg;
    switch (err) {
        case GB_INVALID_OPCODE: msg = "invalid opcode"; break;
        case GB_INVALID_READ:   msg = "invalid read";   break;
        case GB_INVALID_WRITE:  msg = "invalid write";  break;
        default:                msg = "unknown error";  break;
    }
    fprintf(stderr, "peanut-gb: %s at $%04X\n", msg, addr);
}

static void lcd_draw_line_cb(struct gb_s *gb, const uint8_t *pixels,
                             const uint_fast8_t line) {
    (void)gb;
    if (line >= GB_SCREEN_H) return;
    uint32_t *row = &g.framebuffer[line * GB_SCREEN_W];
    for (int x = 0; x < GB_SCREEN_W; x++) row[x] = dmg_palette[pixels[x] & 3];
}

/* ---------------- SDL input ---------------- */

static void handle_input(struct gb_s *gb) {
    SDL_Event ev;
    while (SDL_PollEvent(&ev)) {
        if (ev.type == SDL_QUIT) { g.running = 0; return; }
        if (ev.type != SDL_KEYDOWN && ev.type != SDL_KEYUP) continue;

        bool pressed = (ev.type == SDL_KEYDOWN);
        SDL_Keycode key = ev.key.keysym.sym;

        if (pressed) {
            if (key == SDLK_ESCAPE) { g.running = 0; return; }
            if (key == SDLK_TAB)    { g.fast_forward = !g.fast_forward; continue; }
        }

        uint8_t mask = 0;
        switch (key) {
            case SDLK_z:         mask = JOYPAD_A;      break;
            case SDLK_x:         mask = JOYPAD_B;      break;
            case SDLK_BACKSPACE: mask = JOYPAD_SELECT; break;
            case SDLK_RETURN:    mask = JOYPAD_START;  break;
            case SDLK_RIGHT:     mask = JOYPAD_RIGHT;  break;
            case SDLK_LEFT:      mask = JOYPAD_LEFT;   break;
            case SDLK_UP:        mask = JOYPAD_UP;     break;
            case SDLK_DOWN:      mask = JOYPAD_DOWN;   break;
            default: break;
        }
        if (!mask) continue;
        /* Peanut-GB joypad is active-low */
        if (pressed) gb->direct.joypad &= ~mask;
        else         gb->direct.joypad |=  mask;
    }
}

/* ---------------- File I/O ---------------- */

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

/* Read entire text file into a malloc'd, NUL-terminated string. */
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

/* ---------------- map.json: load (mark covered bytes) ---------------- */

#define ANALYZED_FILE_NAME "analyzed.asm"
#define HEADER_START 0x0100
#define HEADER_END   0x0150  /* exclusive */

static void cover_range(uint32_t start, uint32_t len) {
    if (start >= g.rom_size) return;
    uint32_t end = start + len;
    if (end > g.rom_size) end = g.rom_size;
    memset(g.covered + start, 1, end - start);
}

/* Returns the cJSON root (caller frees). On parse failure or missing file
 * builds an empty {"files": []} document. */
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
    if (!cJSON_GetObjectItem(root, "files")) {
        cJSON_AddArrayToObject(root, "files");
    }
    return root;
}

/* Walk the existing map and mark covered bytes for everything EXCEPT the
 * analyzed.asm entry (which we own and will overwrite). Also reserves the
 * cartridge header. */
static void mark_covered_from_map(cJSON *root) {
    /* Header is always reserved by extract.py — don't touch it. */
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

/* ---------------- map.json: serialize merged result ---------------- */

/* Map an annotation byte to "code"/"data" or NULL if unknown. Adjacent
 * runs of the same returned string get merged into a single section. */
static const char *section_kind(uint8_t v) {
    switch (v) {
        case REGION_CODE:     return "code";
        case REGION_DATA:     return "data";
        case REGION_CONFLICT: return "data"; /* defensive */
        default:              return NULL;
    }
}

/* Build the analyzed.asm file entry from `snapshot` (per-byte annotations).
 * Sections cover only bytes where covered[i] is false. Adjacent same-kind
 * runs are merged. */
static cJSON *build_analyzed_entry(const uint8_t *snapshot) {
    cJSON *entry = cJSON_CreateObject();
    cJSON_AddStringToObject(entry, "type", "code");
    cJSON_AddStringToObject(entry, "name", ANALYZED_FILE_NAME);
    cJSON *sections = cJSON_AddArrayToObject(entry, "sections");

    uint32_t i = 0;
    while (i < g.rom_size) {
        if (g.covered[i]) { i++; continue; }
        const char *kind = section_kind(snapshot[i]);
        if (!kind) { i++; continue; }
        uint32_t start = i;
        while (i < g.rom_size && !g.covered[i]) {
            const char *k = section_kind(snapshot[i]);
            if (!k || strcmp(k, kind) != 0) break;
            i++;
        }
        cJSON *sec = cJSON_CreateObject();
        cJSON_AddStringToObject(sec, "type", kind);
        cJSON_AddNumberToObject(sec, "addr", (double)start);
        cJSON_AddNumberToObject(sec, "len",  (double)(i - start));
        cJSON_AddItemToArray(sections, sec);
    }
    return entry;
}

/* Atomically replace `path` with the serialized JSON. Writes to `path.tmp`
 * then rename()s into place so a crash mid-write can't truncate the file. */
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

/* Take a snapshot, build the merged document, write atomically. Called
 * from the writer thread only. */
static void perform_save(void) {
    /* Snapshot rom_map. Each byte is independently written by the
     * emulator thread, so per-byte snapshot reads are coherent. */
    uint8_t *snap = malloc(g.rom_size);
    if (!snap) return;
    memcpy(snap, g.rom_map, g.rom_size);

    cJSON *root = load_map_json_root(g.map_path);
    cJSON *files = cJSON_GetObjectItem(root, "files");

    /* Drop the previous analyzed.asm entry (we own it). */
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
        "Usage: %s --rom <rom.gbc> --map <map.json> [--save-interval N]\n"
        "\n"
        "Plays the ROM in an SDL window and merges discovered code/data\n"
        "sections into map.json under the auto-managed `analyzed.asm` entry.\n"
        "\n"
        "Controls:\n"
        "  Arrows     D-pad\n"
        "  Z          A         X      B\n"
        "  Enter      Start     Bksp   Select\n"
        "  Tab        Toggle fast-forward\n"
        "  Esc        Quit\n",
        prog);
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
    return -1; /* continue */
}

/* ---------------- Main ---------------- */

int main(int argc, char **argv) {
    int rc = parse_args(argc, argv);
    if (rc != -1) return rc;

    g.rom_data = load_file(g.rom_path, &g.rom_size);
    if (!g.rom_data) return 1;
    printf("loaded %s (%u bytes)\n", g.rom_path, g.rom_size);

    g.rom_map = calloc(g.rom_size, 1);
    g.covered = calloc(g.rom_size, 1);
    g.cart_ram_size = 0x20000;
    g.cart_ram = calloc(g.cart_ram_size, 1);
    if (!g.rom_map || !g.covered || !g.cart_ram) {
        fprintf(stderr, "out of memory\n");
        return 1;
    }

    /* Cover bytes already claimed by the existing map and the header. */
    {
        cJSON *root = load_map_json_root(g.map_path);
        mark_covered_from_map(root);
        cJSON_Delete(root);
    }

    /* SDL */
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS) < 0) {
        fprintf(stderr, "SDL_Init: %s\n", SDL_GetError());
        return 1;
    }
    g.window = SDL_CreateWindow(
        "Monster Rancher Explorer — analyzer",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        GB_SCREEN_W * WINDOW_SCALE, GB_SCREEN_H * WINDOW_SCALE,
        SDL_WINDOW_SHOWN);
    if (!g.window) { fprintf(stderr, "SDL_CreateWindow: %s\n", SDL_GetError()); return 1; }

    g.renderer = SDL_CreateRenderer(g.window, -1,
        SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (!g.renderer)
        g.renderer = SDL_CreateRenderer(g.window, -1, SDL_RENDERER_SOFTWARE);
    if (!g.renderer) { fprintf(stderr, "SDL_CreateRenderer: %s\n", SDL_GetError()); return 1; }

    g.texture = SDL_CreateTexture(g.renderer, SDL_PIXELFORMAT_ARGB8888,
        SDL_TEXTUREACCESS_STREAMING, GB_SCREEN_W, GB_SCREEN_H);
    if (!g.texture) { fprintf(stderr, "SDL_CreateTexture: %s\n", SDL_GetError()); return 1; }

    /* Peanut-GB */
    struct gb_s gb;
    enum gb_init_error_e init_err = gb_init(&gb, rom_read, cart_ram_read,
                                            cart_ram_write, error_handler, &g);
    if (init_err != GB_INIT_NO_ERROR) {
        fprintf(stderr, "gb_init failed (code %d)\n", init_err);
        return 1;
    }
    gb_init_lcd(&gb, lcd_draw_line_cb);
    gb.direct.joypad = 0xFF;

    /* Writer thread */
    pthread_mutex_init(&g.writer_mtx, NULL);
    pthread_cond_init(&g.writer_cv, NULL);
    g.writer_should_stop = 0;
    pthread_create(&g.writer_thread, NULL, writer_main, NULL);

    printf("ready. saving map.json every %u s. esc/close to quit.\n",
           g.save_interval_sec);

    /* Main loop */
    g.running = 1;
    uint32_t frame_start = SDL_GetTicks();
    while (g.running) {
        gb_run_frame(&gb);
        g.total_frames++;

        SDL_UpdateTexture(g.texture, NULL, g.framebuffer,
                          GB_SCREEN_W * sizeof(uint32_t));
        SDL_RenderClear(g.renderer);
        SDL_RenderCopy(g.renderer, g.texture, NULL, NULL);
        SDL_RenderPresent(g.renderer);

        handle_input(&gb);

        if (!g.fast_forward) {
            uint32_t now = SDL_GetTicks();
            uint32_t elapsed = now - frame_start;
            if (elapsed < 16) SDL_Delay(16 - elapsed);
        }
        frame_start = SDL_GetTicks();
    }

    /* Signal writer to do a final save and exit. */
    pthread_mutex_lock(&g.writer_mtx);
    g.writer_should_stop = 1;
    pthread_cond_signal(&g.writer_cv);
    pthread_mutex_unlock(&g.writer_mtx);
    pthread_join(g.writer_thread, NULL);

    printf("[exit] %llu frames, %llu instructions, %u saves\n",
           (unsigned long long)g.total_frames,
           (unsigned long long)g.total_instructions,
           g.saves_done);

    /* Cleanup */
    SDL_DestroyTexture(g.texture);
    SDL_DestroyRenderer(g.renderer);
    SDL_DestroyWindow(g.window);
    SDL_Quit();
    pthread_mutex_destroy(&g.writer_mtx);
    pthread_cond_destroy(&g.writer_cv);
    free(g.rom_data);
    free(g.rom_map);
    free(g.covered);
    free(g.cart_ram);
    return 0;
}
