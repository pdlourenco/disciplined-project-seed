#!/usr/bin/env bash
# local-ci.sh — runs the seed's own doc-CI suite (the active tier-3 jobs in
# .github/workflows/ci.yml) locally, in CI order, fail-fast. This is the
# pre-push CI run for the seed itself (docs/CONTRIBUTING.md §"Pre-push CI
# run").
#
# Why the seed ships a wrapper here when the recommended *adopter* pattern
# is the ecosystem's own task runner: the seed's doc-CI is a set of
# heterogeneous tools (markdownlint-cli2, lychee, actionlint, two Python
# scripts) that no single ecosystem runner drives — exactly the
# "no ecosystem-native runner fits" fallback ADR-0004 leaves open. See
# ADR-0004 (Revised) for the dogfooding decision; adopters with a real
# stack still define their CI commands in their task runner, not here.
#
# Pairs with .claude/hooks/session-start.sh: that hook provisions the
# toolchain in a web container; this script drives it. A missing tool is
# reported (not silently skipped) so a partial run is never mistaken for a
# clean one.
#
# Run from anywhere: scripts/local-ci.sh

set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

skipped=0
step() { printf '\n=== %s ===\n' "$*"; }
warn() { printf '!! %s\n' "$*" >&2; }
die()  { warn "$* — FAILED"; exit 1; }

# Template files that ship with intentional unfilled placeholders; the
# link-check and placeholder-audit jobs exclude them.
#
# KEEP IN SYNC with the `find` invocations in the link-check and
# placeholder-audit jobs of .github/workflows/ci.yml and the `ignores`
# array in .markdownlint-cli2.jsonc — the same template set, duplicated by
# hand across those places and here. ADR-0002 §Consequences names the
# promotion trigger that would collapse the duplication.
doc_files() {
  find . -name '*.md' \
    -not -path './.git/*' \
    -not -path './docs/SPEC.md' \
    -not -path './docs/DESIGN.md' \
    -not -path './docs/ROADMAP.md' \
    -not -path './docs/REVIEW_CONTEXT.md' \
    -not -path './docs/STRUCTURE.md' \
    -not -path './docs/RISKS.md' \
    -not -name 'PHASE-TEMPLATE.md' \
    -not -name 'ADR-TEMPLATE.md'
}

# 1. markdown lint — config (rules + globs + ignores) lives in
#    .markdownlint-cli2.jsonc; invoke with no args so it uses that config.
step "Tier 3 — Markdown lint (markdownlint-cli2)"
if command -v markdownlint-cli2 >/dev/null 2>&1; then
  markdownlint-cli2 || die "markdown lint"
else
  warn "markdownlint-cli2 not found — skipped (npm i -g markdownlint-cli2)"; skipped=1
fi

# 2. internal link check — offline; validates relative paths only.
step "Tier 3 — Link check (lychee, offline)"
if command -v lychee >/dev/null 2>&1; then
  # shellcheck disable=SC2046
  lychee --offline --no-progress $(doc_files | tr '\n' ' ') || die "link check"
else
  warn "lychee not found — skipped"; skipped=1
fi

# 3. dangling-placeholder audit.
step "Tier 3 — Dangling-placeholder audit"
if command -v python3 >/dev/null 2>&1; then
  mapfile -t files < <(doc_files)
  python3 .github/scripts/audit-placeholders.py "${files[@]}" || die "placeholder audit"
else
  warn "python3 not found — skipped"; skipped=1
fi

# 4. workflow YAML lint — actionlint binary if present, else the Docker
#    image ci.yml uses (tag-pinned identically).
step "Tier 3 — Workflow YAML lint (actionlint)"
if command -v actionlint >/dev/null 2>&1; then
  actionlint -color || die "workflow lint"
elif command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  docker run --rm -v "${PWD}:/repo" -w /repo rhysd/actionlint:1.7.12 -color || die "workflow lint"
else
  warn "no actionlint binary and no running docker daemon — skipped (install actionlint or start docker)"; skipped=1
fi

# 5. branch-protection contexts consistency — static, token-free, no network.
step "Tier 3 — Branch-protection contexts consistency"
if command -v python3 >/dev/null 2>&1; then
  python3 .github/scripts/check-bp-contexts.py || die "branch-protection contexts check"
else
  warn "python3 not found — skipped"; skipped=1
fi

if [ "$skipped" -ne 0 ]; then
  printf '\nlocal CI: passed what it could, but some checks were SKIPPED (missing tools above) — not a clean run\n'
  exit 0
fi
printf '\nlocal CI: all doc-CI jobs passed\n'
