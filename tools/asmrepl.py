#!/usr/bin/env python3
"""Multi-line, whitespace-tolerant search-and-replace for RGBDS assembly.

Surgical edits across the disassembly usually mean a bespoke script each time.
`asm_replace` replaces that: give it a file glob and a list of
(pattern, replacement) snippets and it rewrites every match, byte-aware of the
asm layout rather than raw text.

    from tools.asmrepl import asm_replace

    asm_replace("src/**/*.asm", [
        ('''
         ld a, $00
         ld [wGameScene], a
         ''', '''
         ld a, SCENE_TITLE
         ld [wGameScene], a
         '''),
    ])

How matching works:
  * A pattern is one or more consecutive lines. Each pattern line must match a
    consecutive file line.
  * Matching is **whitespace-normalized**: leading indentation and runs of
    spaces/tabs are collapsed, so `\\tld a, $00` matches `ld a, $00`. It is
    otherwise literal -- comments and comma spacing must match the file's style.
  * Replacement lines are re-indented (author them flush-left): a label line
    (`Foo:`, `.local:`, `Exported::`) goes to column 0, every other line goes to
    the matched block's instruction indent. Blank lines stay blank.
  * Rules are applied in order; scanning resumes past each replacement, so a
    replacement that re-contains its own pattern won't loop.

Safety / ergonomics:
  * All edits are computed in memory first. If `require_match` (default) and any
    rule matched zero times, it raises before writing anything -- so a typo'd
    pattern fails loudly instead of silently no-op'ing.
  * `dry_run=True` prints the proposed changes (with line numbers) and writes
    nothing.
  * Returns a list of Change(file, line, rule, before, after).

A `%NAME` reused within one line (or across the pattern's lines) is a
back-reference: every occurrence must capture the same text -- e.g.
`ld a, %X` / `ld b, %X` matches only when both operands are identical.

FUTURE -- capture wildcards (designed-in, not yet exposed): a `%NAME` token in a
pattern captures one whitespace-delimited operand, usable in the replacement,
e.g.
        ld a, %BANK
        ld hl, %ADDR
        call CallBankedHL
    ->  FAR_CALL %BANK, %ADDR
The compiler already turns `%NAME` into a named regex group and the renderer
already substitutes `%NAME` back; `_TOKEN_RX` is the only knob to tune for what
an operand may look like. It is intentionally conservative until we use it.
"""
import glob as _glob
import os
import re
import textwrap
from collections import namedtuple

Change = namedtuple("Change", "file line rule before after")

# What a `%NAME` wildcard may capture (one operand). Conservative for now: a run
# of non-space chars. Refine when the capture feature is turned on for real.
_TOKEN_RX = r"\S+"
_WILDCARD = re.compile(r"%(\w+)")
# A label line: one token then 1-2 colons, e.g. `Foo:`, `.local:`, `Exported::`.
_LABEL_RX = re.compile(r"[^\s:]+::?$")


def _canon(line):
    """Whitespace-normalized form used for matching: strip ends, collapse runs."""
    return re.sub(r"\s+", " ", line.strip())


def _block(text):
    """A heredoc snippet -> list of lines, dedented, blank top/bottom trimmed."""
    return textwrap.dedent(text).strip("\n").split("\n")


def _indent(line):
    return line[: len(line) - len(line.lstrip())]


def _compile_line(canon_pat):
    """canon pattern line -> (compiled regex over a canon file line, [capture names]).

    A `%NAME` repeated within the same line becomes a back-reference, so e.g.
    `ld a, %X` / `ld b, %X` only matches when both operands are identical. (Across
    lines the same effect is enforced by _match_window merging captures.)"""
    rx, names, seen = "", [], set()
    for part in re.split(r"(%\w+)", canon_pat):
        if _WILDCARD.fullmatch(part):
            name = part[1:]
            if name in seen:
                rx += rf"(?P={name})"                 # back-reference to earlier capture
            else:
                seen.add(name)
                names.append(name)
                rx += rf"(?P<{name}>{_TOKEN_RX})"
        else:
            rx += re.escape(part)
    return re.compile("^" + rx + "$"), names


def _compile_rule(pattern, replacement):
    pat_lines = [_compile_line(_canon(l)) for l in _block(pattern)]
    if not pat_lines:
        raise ValueError("empty pattern")
    return pat_lines, _block(replacement)


def _match_window(window, pat_lines):
    """Return merged capture dict if every file line matches its pattern, else None."""
    caps = {}
    for fline, (rx, _names) in zip(window, pat_lines):
        m = rx.match(_canon(fline))
        if not m:
            return None
        for k, v in m.groupdict().items():
            if k in caps and caps[k] != v:   # same %NAME must capture the same text
                return None
            caps[k] = v
    return caps


def _instr_indent(window):
    """Indent for non-label replacement lines: the first non-label, non-blank
    matched line's indentation (fallback: one tab)."""
    for fl in window:
        if fl.strip() and not _LABEL_RX.fullmatch(fl.strip()):
            return _indent(fl)
    return "\t"


def _render(repl_lines, instr_indent, caps):
    """Re-indent replacement lines: a label (`Foo:`/`.x:`/`Foo::`) goes to column 0,
    everything else to the matched block's instruction indent. Authored leading
    whitespace is ignored (so author replacements flush-left)."""
    out = []
    for line in repl_lines:
        if not line.strip():
            out.append("")
            continue
        s = _WILDCARD.sub(lambda m: caps.get(m.group(1), m.group(0)), line).strip()
        out.append(s if _LABEL_RX.fullmatch(s) else instr_indent + s)
    return out


def _apply_rule(lines, pat_lines, repl_lines, rule_idx):
    """Apply one rule across `lines`; return (new_lines, [Change])."""
    n = len(pat_lines)
    out, changes, i = [], [], 0
    while i < len(lines):
        window = lines[i : i + n]
        if len(window) == n:
            caps = _match_window(window, pat_lines)
            if caps is not None:
                repl = _render(repl_lines, _instr_indent(window), caps)
                changes.append(Change(None, i + 1, rule_idx, "\n".join(window),
                                      "\n".join(repl)))
                out.extend(repl)
                i += n
                continue
        out.append(lines[i])
        i += 1
    return out, changes


def asm_replace(file_glob, rules, *, root=".", dry_run=False,
                require_match=True, verbose=True):
    """Apply (pattern, replacement) rules to every file matching `file_glob`.

    file_glob : glob string, e.g. "src/**/*.asm" (recursive ** supported).
    rules     : list of (pattern, replacement) multi-line strings.
    Returns a list of Change records. Raises ValueError (before writing anything)
    if require_match and some rule never matched.
    """
    compiled = [_compile_rule(p, r) for p, r in rules]
    files = sorted(_glob.glob(os.path.join(root, file_glob), recursive=True))

    all_changes, pending = [], {}          # path -> new text (computed, unwritten)
    rule_hits = [0] * len(rules)
    for path in files:
        text = open(path).read()
        nl = text.endswith("\n")
        lines = text[:-1].split("\n") if nl else text.split("\n")
        file_changes = []
        for idx, (pat_lines, repl_lines) in enumerate(compiled):
            lines, ch = _apply_rule(lines, pat_lines, repl_lines, idx)
            for c in ch:
                rule_hits[idx] += 1
                file_changes.append(c._replace(file=path))
        if file_changes:
            pending[path] = "\n".join(lines) + ("\n" if nl else "")
            all_changes.extend(file_changes)

    misses = [i for i, h in enumerate(rule_hits) if h == 0]
    if misses and require_match:
        raise ValueError(
            "no match for rule(s) " + ", ".join(map(str, misses))
            + " (set require_match=False to allow). First pattern of a missed "
            "rule:\n" + "\n".join(_block(rules[misses[0]][0])))

    if verbose:
        for i, h in enumerate(rule_hits):
            print(f"rule {i}: {h} match(es)")
        for path in sorted(pending):
            print(f"  {path}: {sum(1 for c in all_changes if c.file == path)} edit(s)")
    if dry_run:
        for c in all_changes:
            print(f"\n--- {c.file}:{c.line} (rule {c.rule}) ---")
            for l in c.before.split("\n"):
                print(f"- {l}")
            for l in c.after.split("\n"):
                print(f"+ {l}")
    elif pending:
        for path, txt in pending.items():
            open(path, "w").write(txt)

    return all_changes


if __name__ == "__main__":
    print(__doc__)
    print("This is a library: `from tools.asmrepl import asm_replace`. "
          "Run your edits from a small scratch script.")
