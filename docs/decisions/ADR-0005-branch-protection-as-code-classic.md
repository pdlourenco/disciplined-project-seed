# ADR-0005 — Branch protection as code: classic schema + human-triggered apply + scheduled drift check

## Status

Accepted — 2026-05-31.

## Context

[`docs/CONTRIBUTING.md` §"Required status checks"](../CONTRIBUTING.md) lists which checks branch protection on `main` should require, but the actual GitHub branch protection settings live in **repo Settings → Branches** — not in the repo. The prose claim and the live config are independent; nothing enforces that they match.

Same drift surface as the labels problem ([ADR-0001](ADR-0001-label-sync.md)) — but with a critical **permissions asymmetry**:

- Labels can be reconciled with the default `GITHUB_TOKEN` issued to workflows. ADR-0001's sync action runs with no special secrets.
- Branch protection requires `Administration: write` scope. The default `GITHUB_TOKEN` does **not** have it. An auto-sync workflow would need a Personal Access Token (or GitHub App installation token) with admin scope, stored as a repo secret.

That permissions difference changes the operational shape end-to-end: every adopter would have to provision an admin-scoped PAT, store it as a secret, manage its rotation, and accept the escalation path if compromised. Sync going wrong with admin credentials can also lock the repo out (a bad workflow that adds a non-existent required status check blocks all merges until an admin manually unblocks).

A second sub-decision lurks underneath: **classic branch protection vs rulesets**. GitHub has two APIs for the same conceptual problem now. Classic is the older, simpler, universally tooled model; rulesets are newer and more flexible (multiple rulesets per branch, layered policies, ruleset bypass actors, support for tags, deployment-success requirements), but the tooling ecosystem is still catching up. Anything the seed ships locks in one of the two.

Surfaced and decided in [#11](https://github.com/pdlourenco/disciplined-project-seed/issues/11), which explicitly blocks the deferred merge-gate option in [ADR-0003](ADR-0003-labels-applied-via-reviewer.md) (no required status checks can be added safely until this problem is solved).

## Decision

Ship three coordinated pieces, no secrets in the repo:

- **`.github/branch-protection.yml`** — desired state, **classic** branch-protection schema. Includes the four `Tier 3 — …` status-check contexts from [ADR-0002](ADR-0002-active-trivial-ci-workflow.md)'s `ci.yml`, `required_linear_history: true`, `allow_force_pushes: false`, `allow_deletions: false`, `required_conversation_resolution: true`, and conservative defaults for the rest. Per-field rationale lives inline as YAML comments.

- **`scripts/setup-branch-protection.sh`** — human-triggered apply. Reads the YAML, converts to JSON via `yq`, posts to the branch-protection API via the adopter's `gh auth` credentials. No admin PAT stored in the repo. Shows the diff against live config before applying. Requires `gh`, `yq`, and `jq` on the operator's PATH.

- **`.github/workflows/check-branch-protection.yml`** — scheduled (weekly) read-only drift check. Uses the default `GITHUB_TOKEN`, which *can* read branch protection without admin scope. Normalizes the live API response (which wraps some booleans as `{enabled: bool}` objects) to match the YAML's flat structure, then diffs. Opens an issue if drift is detected, or if live protection isn't configured at all.

For the classic-vs-rulesets sub-decision: **classic**. Universal tooling support; simpler reasoning; every action and script knows how to handle it. Rulesets are documented as the alternative when adopters need ruleset-only features.

## Consequences

- **No secret stored in the repo.** Sidesteps the admin-PAT provisioning, rotation, and compromise surface entirely. The trade-off is that apply is manual — adopters re-run `setup-branch-protection.sh` when they edit the YAML.
- **Drift-detection safety net.** The weekly read-only workflow runs against `GITHUB_TOKEN`'s read scope and opens an issue on divergence. Adopters who edit the YAML and forget to apply get notified within a week; manual `Settings → Branches` edits also get caught.
- **Permissions-asymmetry explicit.** This ADR diverges from [ADR-0001](ADR-0001-label-sync.md)'s "sync via Action" shape *because of the admin-scope requirement*, not because the two problems differ in spirit. Documenting it here closes the "why didn't we just do it like labels?" question a future contributor would ask.
- **Lockout blast radius is bounded.** A bad label-sync run loses a label; recoverable in seconds. A bad branch-protection-apply run with admin credentials can require manual GitHub-UI intervention. Human-in-the-loop apply (running the script consciously) is the safety property: the operator sees the diff before pressing enter.
- **Classic schema, rulesets as upgrade path.** If adopters need ruleset-only features (deployment-success requirements, ruleset bypass actors, layered policies), they migrate the YAML schema and the script's API endpoint. Documented as the upgrade-path direction; not done in this PR.
- **Resolves the [#9](https://github.com/pdlourenco/disciplined-project-seed/issues/9) Alternative A blocker.** Required-status-check additions can now be tracked configuration rather than manual Settings clicks. If the [ADR-0003](ADR-0003-labels-applied-via-reviewer.md) revisit conditions fire for moving to a hard label-gate, this ADR's mechanism is what owns the wire-up.
- **The seed's own `branch-protection.yml` is the dogfood.** This PR's CI workflow has the four `Tier 3 — …` contexts; the YAML pins them as required. If the seed's CI workflow ever changes a job's `name:`, the YAML must change too, and the drift check will catch the gap if anyone forgets.
- **`required_signatures` is intentionally out of scope.** GitHub's signed-commit enforcement is a *separate sub-resource* (`POST` / `DELETE` on `.../branches/:branch/protection/required_signatures`), not a body parameter of the Update branch protection PUT. Including it in `branch-protection.yml` would either be silently ignored or 422 the apply call. The YAML and the workflow's normalize filter both exclude it; adopters who want signed-commit enforcement configure it via the dedicated endpoint or the GitHub UI. A future ADR can extend the script to call the sub-resource if the trade-off changes.
- **Normalize filter is shared between script and workflow.** [`scripts/normalize-branch-protection.jq`](../../scripts/normalize-branch-protection.jq) is the single source of truth for *what counts as the same state*. Both `setup-branch-protection.sh` (pre-apply diff for the operator) and `check-branch-protection.yml` (weekly drift detection) pipe their JSON through it via `jq -f`. Without the shared filter, the operator's pre-apply diff would be dominated by structural noise (`{enabled: bool}` wrappers, server-only URLs) while the workflow's diff would be clean — bad for the operator's "review before pressing enter" safety property. The filter also handles three correctness issues: `jq`'s `//` operator treats `false` as null-equivalent (use `type == "object"` to disambiguate); `contexts` arrays may arrive in different orders (sort before comparing); `required_pull_request_reviews` carries server-only fields when set (extract only the comparable subfields).
- **Adopter prerequisite: the label catalogue must be seeded for proper issue labelling.** The drift workflow tries to create its drift issue with `--label "bug,security"`, then falls back to no-label if those don't exist. On fresh forks where the [ADR-0001](ADR-0001-label-sync.md) sync-labels workflow hasn't been run yet, drift issues land unlabelled but still land. Adopters who run `gh label create`-equivalent setup early get properly-categorised drift issues from day one.

## Alternatives considered

The lettering matches the issue thread on [#11](https://github.com/pdlourenco/disciplined-project-seed/issues/11) so anyone re-reading the discussion can map decisions back to the recommendation.

- **A — GitHub Action with admin-scoped PAT, auto-sync.** Mirrors [ADR-0001](ADR-0001-label-sync.md)'s pattern. Rejected because the permissions asymmetry is load-bearing: every adopter would have to provision and rotate an admin PAT, store it as a secret, and accept the escalation surface if compromised. The `workflow_dispatch`-only-default mitigation from ADR-0001 addresses *trigger* safety but not *credential* safety. Documented as an upgrade path for adopters with platform teams that already own admin tokens.
- **B — script + YAML, human-triggered apply + scheduled drift check.** Chosen. See §Decision and §Consequences.
- **C — Terraform via the GitHub provider.** Standard infrastructure-as-code shape; mature handling of state, drift, plan/apply. Rejected for a documentation-shaped seed: Terraform itself is a heavy dependency, state management is a separate operational problem, and the population of seed adopters likely to use Terraform for one resource is small. Adopters whose stack already includes Terraform can migrate the YAML schema to HCL and gain Terraform's drift detection natively.
- **D — do nothing.** Status quo. Drift accepted; adopter sets up branch protection manually from `CONTRIBUTING.md`'s prose checklist; each new "required check" addition compounds drift. Rejected — the gap is real and concrete, the cost of the fix is low, and [#9](https://github.com/pdlourenco/disciplined-project-seed/issues/9) Alternative A explicitly needs this to land.
- **Rulesets instead of classic schema.** Considered. Rulesets are more flexible but the tooling ecosystem (actions, scripts, docs, examples) is still catching up. Adopters who need ruleset features today are a minority and can migrate the schema themselves. Picked classic with the rulesets-upgrade-path note in §Consequences. Worth revisiting when ruleset adoption among seed-shaped projects becomes the norm.
- **Auto-sync without admin PAT** (using only read scope to *report* drift without applying). Rejected as a default because the report-only mode is already what the drift-detection workflow does; conflating it with "apply" would be misleading. The two concerns are cleanly separated in this ADR.
- **Inline the live-vs-YAML comparison logic in the script too** (so `setup-branch-protection.sh` does both report and apply). The script already shows the diff before applying — operators see what changes before pressing enter. The standalone weekly workflow is what catches *unintended* drift between manual applies; a single script that does both would conflate "I'm about to apply" with "what changed since I last checked".
