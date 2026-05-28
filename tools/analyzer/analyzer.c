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
#define WINDOW_SCALE              3
#define ANALYZED_FILE_NAME        "analyzed.asm"
#define HEADER_START              0x0100
#define HEADER_END                0x0150  /* exclusive */
/* Max screen we ever need to back: SGB border is 256x224. */
#define MAX_SCREEN_PIXELS         (256 * 224)

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
    if (addr >= 0x8000) return data;          /* outside cart ROM region */

    GB_registers_t *regs = GB_get_registers(gb);
    if (addr == (uint16_t)(regs->pc - 1)) return data; /* fetch read */

    uint32_t flat = resolve_rom_addr(addr);
    if (flat != UINT32_MAX && flat < g.rom_size)
        mark_data(flat);
    return data;
}

static uint32_t rgb_encode(GB_gameboy_t *gb, uint8_t r, uint8_t gr, uint8_t b) {
    (void)gb;
    return 0xFF000000u | ((uint32_t)r << 16) | ((uint32_t)gr << 8) | b;
}

static void on_vblank(GB_gameboy_t *gb, GB_vblank_type_t type) {
    (void)gb; (void)type;
    g.total_frames++;
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
            if (key == SDLK_ESCAPE) { g.running = 0; return; }
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

static const char *section_kind(uint8_t v) {
    switch (v) {
        case REGION_CODE:     return "code";
        case REGION_DATA:     return "data";
        case REGION_CONFLICT: return "data"; /* defensive */
        default:              return NULL;
    }
}

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
        } else if (strcmp(argv[i], "--no-save") == 0) {
            g.no_save = true;
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
    if (!g.rom_map || !g.covered || !g.insn_byte) {
        fprintf(stderr, "out of memory\n");
        return 1;
    }

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

    SDL_DestroyTexture(g.texture);
    SDL_DestroyRenderer(g.renderer);
    SDL_DestroyWindow(g.window);
    SDL_Quit();

    GB_free(&g.gb);
    pthread_mutex_destroy(&g.writer_mtx);
    pthread_cond_destroy(&g.writer_cv);
    free(g.rom_data);
    free(g.rom_map);
    free(g.covered);
    free(g.insn_byte);
    free(g.battery_path);
    return 0;
}
