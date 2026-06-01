#!/usr/bin/env bash
# Apply .github/branch-protection.yml to a branch's protection settings
# on the current repo. Uses the adopter's `gh auth` credentials — no
# secret is stored in the repo.
#
# See docs/decisions/ADR-0005-branch-protection-as-code-classic.md for
# the rationale (human-in-the-loop apply vs auto-sync via Action).
#
# Prerequisites:
#   - `gh` CLI authenticated with admin scope on this repo
#     (`gh auth login --scopes admin:repo` if you need to escalate)
#   - `yq` installed (https://github.com/mikefarah/yq) for YAML → JSON
#
# Usage:
#   scripts/setup-branch-protection.sh           # applies to `main`
#   scripts/setup-branch-protection.sh develop   # applies to `develop`

set -euo pipefail

BRANCH="${1:-main}"
YAML_FILE=".github/branch-protection.yml"

if [[ ! -f "$YAML_FILE" ]]; then
  echo "Error: $YAML_FILE not found." >&2
  exit 1
fi

for tool in yq gh jq; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Error: $tool not found on PATH." >&2
    case "$tool" in
      yq) echo "Install: https://github.com/mikefarah/yq" >&2 ;;
      gh) echo "Install: https://cli.github.com/" >&2 ;;
      jq) echo "Install: https://jqlang.github.io/jq/" >&2 ;;
    esac
    exit 1
  fi
done

if ! gh auth status >/dev/null 2>&1; then
  echo "Error: gh not authenticated. Run 'gh auth login' first." >&2
  exit 1
fi

REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)

echo "Applying branch protection from $YAML_FILE to $REPO@$BRANCH..."
echo

# Show the diff between desired and live state before applying, so the
# operator can sanity-check. Don't abort on diff — applying is the goal.
LIVE_JSON=$(mktemp)
DESIRED_JSON=$(mktemp)
trap 'rm -f "$LIVE_JSON" "$DESIRED_JSON"' EXIT

yq -o=json "$YAML_FILE" > "$DESIRED_JSON"

# Shared normalize filter (same one the drift workflow uses) so the
# pre-apply diff shows only meaningful changes — without it the operator
# sees dozens of structural differences ({enabled: bool} wrappers,
# server-only URLs, etc.) that bury the one line that might matter,
# undercutting the human-in-the-loop safety property.
NORMALIZE_JQ="$(dirname "$0")/normalize-branch-protection.jq"

if gh api -H "Accept: application/vnd.github+json" \
   "/repos/$REPO/branches/$BRANCH/protection" \
   > "$LIVE_JSON" 2>/dev/null; then
  echo "Current live protection found. Normalized diff against desired:"
  diff -u \
    <(jq -S -f "$NORMALIZE_JQ" "$DESIRED_JSON") \
    <(jq -S -f "$NORMALIZE_JQ" "$LIVE_JSON") \
    || true
  echo
else
  echo "No live protection currently configured on $BRANCH; will create."
  echo
fi

# Apply the YAML.
yq -o=json "$YAML_FILE" | gh api \
  -X PUT \
  -H "Accept: application/vnd.github+json" \
  "/repos/$REPO/branches/$BRANCH/protection" \
  --input - > /dev/null

echo "Done. Verify in the GitHub UI:"
echo "  https://github.com/$REPO/settings/branches"
