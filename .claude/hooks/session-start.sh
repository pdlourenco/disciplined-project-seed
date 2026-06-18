#!/usr/bin/env bash
# SessionStart hook — provisions the seed's own doc-CI toolchain in an
# ephemeral Claude-Code-on-the-web container so the "run CI locally before
# every push" discipline (docs/CONTRIBUTING.md §"Pre-push CI run") is
# actually executable there. Local checkouts keep their own toolchain and
# are skipped.
#
# Design properties (see meta/decisions/ADR-0009, issue #26, and
# .github/workflows/ci.yml):
#   - Gates on CLAUDE_CODE_REMOTE; no-ops on a local checkout.
#   - Idempotent and best-effort: each step warns and continues on
#     failure and never aborts the session. A non-zero SessionStart hook
#     only warns, so a half-provision must log clearly rather than strand
#     the steps after it.
#   - Tool versions are pinned to track .github/workflows/ci.yml. When a
#     pinned action there moves, bump the matching pin below so the local
#     checks track CI exactly.
#   - Arch guard: an unexpected host logs-and-skips the arch-specific
#     binary downloads instead of 404-ing them.
#
# Pairs with scripts/local-ci.sh (see ADR-0004): this hook *provisions*
# the toolchain; that script *drives* it.

set -uo pipefail

log() { printf '[session-start] %s\n' "$*" >&2; }

# 1. Gate — only provision in the remote (web) container.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  log "not a remote session (CLAUDE_CODE_REMOTE != true) — skipping toolchain provisioning"
  exit 0
fi

# 2. Arch guard — the pinned binary downloads are arch-specific.
arch="$(uname -m)"
case "$arch" in
  x86_64|amd64)  LYCHEE_ARCH="x86_64-unknown-linux-gnu";  ACTIONLINT_ARCH="linux_amd64" ;;
  aarch64|arm64) LYCHEE_ARCH="aarch64-unknown-linux-gnu"; ACTIONLINT_ARCH="linux_arm64" ;;
  *)
    log "unsupported arch '$arch' — skipping binary installs (npm-based markdown lint still attempted)"
    LYCHEE_ARCH=""; ACTIONLINT_ARCH=""
    ;;
esac

# ── Pinned versions — keep in sync with .github/workflows/ci.yml ─────────
# actionlint: ci.yml runs the rhysd/actionlint:1.7.12 Docker image. This
#             pin matches that tag exactly.
ACTIONLINT_VERSION="1.7.12"
# markdownlint-cli2 + lychee: ci.yml pins the *actions*
# (DavidAnson/markdownlint-cli2-action, lycheeverse/lychee-action); the
# versions below are the tool versions those pinned action releases bundle,
# so a local run matches CI. When you bump a pinned action in ci.yml,
# re-check the version it ships and update the matching pin here. Steps
# below are best-effort: a stale pin degrades to a logged warning, not a
# broken session.
MARKDOWNLINT_CLI2_VERSION="0.22.1"   # bundled by markdownlint-cli2-action v23.2.0 (ci.yml)
LYCHEE_VERSION="0.23.0"              # default of lychee-action v2.8.0 (ci.yml)

# 3. markdown lint — markdownlint-cli2 via npm.
if command -v markdownlint-cli2 >/dev/null 2>&1; then
  log "markdownlint-cli2 already present"
elif command -v npm >/dev/null 2>&1; then
  npm install -g "markdownlint-cli2@${MARKDOWNLINT_CLI2_VERSION}" \
    && log "installed markdownlint-cli2@${MARKDOWNLINT_CLI2_VERSION}" \
    || log "markdownlint-cli2 install failed — manual install needed (npm i -g markdownlint-cli2@${MARKDOWNLINT_CLI2_VERSION})"
else
  log "npm not found — skipping markdownlint-cli2 (manual install needed)"
fi

# 4. internal link check — lychee, pinned binary.
if command -v lychee >/dev/null 2>&1; then
  log "lychee already present"
elif [ -n "$LYCHEE_ARCH" ]; then
  url="https://github.com/lycheeverse/lychee/releases/download/lychee-v${LYCHEE_VERSION}/lychee-${LYCHEE_ARCH}.tar.gz"
  ( curl -fsSL "$url" | tar -xz -C /usr/local/bin lychee ) \
    && log "installed lychee v${LYCHEE_VERSION}" \
    || log "lychee install failed — manual install needed ($url)"
else
  log "no arch mapping for lychee — skipping (manual install needed)"
fi

# 5. workflow YAML lint — actionlint, pinned binary. ci.yml runs it via the
#    rhysd/actionlint Docker image; locally the static binary is lighter and
#    avoids requiring Docker just for the doc suite.
if command -v actionlint >/dev/null 2>&1; then
  log "actionlint already present"
elif [ -n "$ACTIONLINT_ARCH" ]; then
  url="https://github.com/rhysd/actionlint/releases/download/v${ACTIONLINT_VERSION}/actionlint_${ACTIONLINT_VERSION}_${ACTIONLINT_ARCH}.tar.gz"
  ( curl -fsSL "$url" | tar -xz -C /usr/local/bin actionlint ) \
    && log "installed actionlint v${ACTIONLINT_VERSION}" \
    || log "actionlint install failed — manual install needed ($url)"
else
  log "no arch mapping for actionlint — skipping (manual install needed)"
fi

# 6. placeholder audit — python3 is pre-installed on the standard image;
#    verify so a missing interpreter surfaces here, not at push time.
command -v python3 >/dev/null 2>&1 \
  && log "python3 present ($(python3 --version 2>&1))" \
  || log "python3 not found — the placeholder-audit job needs it (manual install needed)"

# ── Adopter stack toolchain (stub) ──────────────────────────────────────
# Install the adopter's stack toolchain here (pnpm / cargo / tox / …),
# mirroring what ci.yml's tier-1 / tier-2 / tier-3 jobs use, pinned the
# same way. For example:
#   corepack enable && corepack prepare pnpm@<pinned> --activate
#   pnpm install --frozen-lockfile

# ── Docker (stub, for adopters whose CI needs it) ───────────────────────
# If a tier needs Docker (an integration job, a service container, …):
#   - configure a registry mirror to dodge the Docker Hub anonymous-pull
#     limit;
#   - self-start dockerd if it's down and wait (~30s) for the socket — the
#     SessionStart hook can race the daemon's network init and bail;
#   - pre-pull the images the suite uses into the cached container.
# Left commented because the seed's own doc-CI needs none of it.

log "doc-CI toolchain provisioning complete (best-effort)"
exit 0
