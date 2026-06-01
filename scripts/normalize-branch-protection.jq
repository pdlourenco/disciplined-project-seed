# Normalize a GitHub branch-protection JSON object so the live API
# response and the flat YAML's JSON can be diffed apples-to-apples.
#
# Shared by:
#   - scripts/setup-branch-protection.sh (pre-apply diff for the operator)
#   - .github/workflows/check-branch-protection.yml (weekly drift detection)
#
# Both pipe their JSON through `jq -f` against this file.
#
# Why this is non-trivial:
#
# 1. The live API wraps several booleans as {"enabled": bool} objects
#    (enforce_admins, required_linear_history, allow_force_pushes,
#    allow_deletions, required_conversation_resolution, block_creations,
#    lock_branch); the YAML's PUT-body shape uses flat booleans for the
#    same fields. Use `type == "object"` to disambiguate — `//` is wrong
#    here because `false // x` evaluates to `x` (jq treats `false` as
#    null-equivalent in alternative).
# 2. `required_status_checks.contexts` is an array; live and YAML may
#    list contexts in a different order. Sort before comparing.
# 3. `required_pull_request_reviews` (when set) carries server-only
#    fields on the live side (`url`, defaulted sub-objects) the YAML
#    can't be expected to ship; extract only the comparable subfields.
# 4. `required_signatures` is intentionally absent — it's a separate
#    sub-resource of the branch-protection API, not a PUT-body param.
#    See ADR-0005 §Consequences.

def flat: if type == "object" then .enabled else . end;

def normalize_pr_reviews:
  if . == null then null else {
    required_approving_review_count: (.required_approving_review_count // 0),
    dismiss_stale_reviews:           (.dismiss_stale_reviews // false),
    require_code_owner_reviews:      (.require_code_owner_reviews // false),
    require_last_push_approval:      (.require_last_push_approval // false),
    bypass_pull_request_allowances:  (.bypass_pull_request_allowances // null)
  } end;

def normalize_status_checks:
  if . == null then null else {
    strict:   (.strict // false),
    contexts: ((.contexts // []) | sort)
  } end;

{
  required_status_checks:           (.required_status_checks | normalize_status_checks),
  enforce_admins:                   ((.enforce_admins | flat) // false),
  required_pull_request_reviews:    (.required_pull_request_reviews | normalize_pr_reviews),
  restrictions:                     (.restrictions // null),
  required_linear_history:          ((.required_linear_history | flat) // false),
  allow_force_pushes:               ((.allow_force_pushes | flat) // false),
  allow_deletions:                  ((.allow_deletions | flat) // false),
  required_conversation_resolution: ((.required_conversation_resolution | flat) // false),
  block_creations:                  ((.block_creations | flat) // false),
  lock_branch:                      ((.lock_branch | flat) // false)
}
