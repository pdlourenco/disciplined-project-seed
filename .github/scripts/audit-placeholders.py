#!/usr/bin/env python3
"""
Audit Markdown files for inline HTML-comment placeholders that render
as visible artifacts in the published output.

Bug class this catches: the seed's PR #4. Source lines like

    defines the external contracts — <!-- describe the boundaries -->.
    gates in CI — <!-- name them --> — are not optional.

render as

    defines the external contracts — .
    gates in CI — — are not optional.

— em-dash glitches where the placeholder rendered to nothing. The fix
is to inline real prose or move the comment onto its own line.

Detection: simulate rendering (strip complete <!-- ... --> from each
line), then scan for visible glitches. The audit is **intentionally
narrow** — it catches the em-dash-adjacent pattern PR #4 represented,
not every conceivable rendering artifact. The seed's structural
templates (`## Phase 1: <!-- title -->`, `**Goal:** <!-- ... -->`,
table cells with placeholder content) render cleanly even with
placeholders unfilled and are not flagged.

If a new placeholder-rendering bug class shows up, extend `GLITCHES`.

Exit codes: 0 if clean, 1 if any findings.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

CODE_SPAN = re.compile(r"`[^`]*`")
INLINE_COMMENT = re.compile(r"<!--.*?-->")

# Glitch patterns to scan the rendered (comment-stripped) line for.
# Each pattern matches a visible artifact that would only appear if an
# inline placeholder rendered to nothing.
GLITCHES = [
    # em-dash followed by sentence-ending punctuation (PR #4 case 1:
    # "external contracts — .")
    re.compile(r"—\s*[.,;:!?]"),
    # double em-dash with only whitespace between (PR #4 case 2:
    # "gates in CI — — are not optional")
    re.compile(r"—\s+—"),
]


def find_glitches(line: str) -> list[str]:
    """Return any glitch fragments that appear in the line after stripping
    code spans and complete inline comments. Code spans are stripped first
    so backticked examples of placeholder syntax or glitch patterns (e.g.
    in this script's own ADR) aren't flagged.

    Empty list = no findings.
    """
    stripped = CODE_SPAN.sub("", line)
    has_inline = INLINE_COMMENT.search(stripped) is not None
    if not has_inline:
        return []
    rendered = INLINE_COMMENT.sub("", stripped)
    findings: list[str] = []
    for pattern in GLITCHES:
        findings.extend(m.group(0) for m in pattern.finditer(rendered))
    return findings


def audit_file(path: Path) -> list[tuple[int, str, list[str]]]:
    findings: list[tuple[int, str, list[str]]] = []
    for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
        glitches = find_glitches(line)
        if glitches:
            findings.append((lineno, line.rstrip(), glitches))
    return findings


def main(argv: list[str]) -> int:
    paths = [Path(p) for p in argv[1:]]
    if not paths:
        paths = [p for p in Path(".").rglob("*.md") if ".git" not in p.parts]
    any_findings = False
    for path in sorted(paths):
        if not path.is_file():
            continue
        findings = audit_file(path)
        if findings:
            any_findings = True
            print(f"\n{path}:")
            for lineno, text, glitches in findings:
                glitch_summary = ", ".join(repr(g) for g in glitches)
                print(f"  {lineno}: {text}")
                print(f"      ⤷ rendered glitch(es): {glitch_summary}")
    if any_findings:
        print(
            "\nDangling inline placeholders found. Fix by rewriting the "
            "containing line to neutral prose or moving the comment onto "
            "its own line(s)."
        )
        return 1
    print("No dangling inline placeholders.")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
