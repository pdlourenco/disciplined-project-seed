# ADR-0001 — Sync GitHub labels from `.github/labels.yml` via an Action, defaults conservative

## Status

Accepted — 2026-05-31.

## Context

The seed's label taxonomy ([`docs/LABELS.md`](../../docs/LABELS.md)) is load-bearing for issue and PR hygiene per `CLAUDE.md §4`. Until this ADR, the catalogue was seeded via a manual `gh label create` snippet — a one-shot.

Two failure modes followed:

1. **Drift between doc and live labels.** `LABELS.md` says one thing; the actual repo labels say another. No automation catches the divergence.
2. **Adoption friction.** Every adopter copy-pasted the `gh` snippet once; subsequent edits to `LABELS.md` relied on contributor memory to also re-apply against the live repo.

Same shape as the branch-protection-settings problem ([#11](https://github.com/pdlourenco/disciplined-project-seed/issues/11)), but with a critical asymmetry: labels can be reconciled with the default `GITHUB_TOKEN`; branch protection cannot. That asymmetry is what justifies different mechanisms for the two cases (see the branch-protection ADR when written).

Surfaced and decided in [#7](https://github.com/pdlourenco/disciplined-project-seed/issues/7) with explicit refinements (`delete: false` default, `workflow_dispatch` only, SHA-pin) added during discussion.

## Decision

Ship `.github/labels.yml` as the machine-readable source of truth, paired with `docs/LABELS.md` as the human doc. Reconcile via [`EndBug/label-sync`](https://github.com/EndBug/label-sync), pinned to SHA `52074158190acb45f3077f9099fea818aa43f97a` (v2.3.3, latest stable as of 2026-05-31, action.yml uses `node24`).

`.github/workflows/sync-labels.yml` runs on `workflow_dispatch` only — no push-to-main auto-trigger — with `delete-other-labels: false` by default. Both defaults are conservative; flip conditions are documented in [`docs/LABELS.md` §"Seeding the catalogue"](../../docs/LABELS.md) and in §Consequences below.

## Consequences

- **`LABELS.md` and `labels.yml` are paired.** Edits to one require edits to the other in the same PR — the same co-landing rule that applies to ADR + SPEC changes (per PR #3 and `decisions/README.md`).
- **`delete-other-labels: false` default.** Adopters extending the catalogue organically (project-specific labels like `priority:p0`, `client:acme`) don't get them nuked on the next sync run. *Flip condition*: once the taxonomy is stable and the YAML should own the catalogue authoritatively, set `delete-other-labels: true`.
- **`workflow_dispatch` trigger only.** A PR that accidentally edits a label row doesn't nuke the live label on merge. *Flip condition*: once contributors trust label-YAML edits to be caught at PR review time, add `push: branches: [main]` to the trigger so sync runs automatically.
- **SHA-pinned action.** Reproducible behaviour across the seed and adopter forks. Adopters bump on their own cadence; the seed bumps via a routine PR when an upstream release earns it (security fix, runtime upgrade).
- **Pinning policy: third-party actions SHA-pinned; first-party `actions/*` tag-pinned.** `EndBug/label-sync` is SHA-pinned because third-party Actions are the threat surface — a moving tag there is unaudited code. `actions/checkout` and other `actions/*` are tag-pinned (`@v4`) because they're under GitHub's own maintenance and the standard ecosystem pattern is tag-pin for first-party. If this asymmetry ever stops feeling defensible, the upgrade path is uniform SHA-pinning.
- **The workflow ships effectively dormant on the seed itself.** The seed has near-zero label activity, so the workflow rarely runs here; it's scaffolding adopters inherit. Documented in this ADR rather than via a new `# seed-only:` marker convention (overengineering for one file; the marker convention can be promoted if a future PR adds more seed-only scaffolding).
- **Phase labels are not maintained by the YAML.** Per `LABELS.md §"Phase (apply at most one)"`, phase labels are added on demand. The YAML deliberately omits them so the sync action doesn't churn them as phases come and go.

## Alternatives considered

The lettering matches the issue thread on [#7](https://github.com/pdlourenco/disciplined-project-seed/issues/7) so anyone re-reading the discussion can map decisions back to the recommendation.

- **A — `.github/labels.yml` + GitHub Action sync, conservative defaults.** Chosen; see §Decision and §Consequences.
- **B — `labels.yml` only, no automation.** Ship the YAML so adopters have a starting point but leave sync to a manual one-shot. Rejected: solves the seeding problem without addressing the drift problem; the YAML becomes a third source of truth that nobody enforces against.
- **C — generate `labels.yml` from `LABELS.md` at sync time.** A small script parses LABELS.md's tables and emits YAML. Rejected: introduces a parser dependency the seed has to maintain. Pairing-via-PR-discipline is a cheaper consistency mechanism than a script.
- **D — do nothing.** Keep the manual `gh label create` snippet. Accept drift. Rejected: the gap is real and the cost of the fix is low.
- **Auto-trigger on push to `main` by default.** Sub-decision within A. Rejected: the failure mode (a PR accidentally edits a label row → label nuked on merge) is silent and recovery is manual. `workflow_dispatch` is the conservative default; adopters opt in to auto-trigger when the taxonomy stabilises.
- **`delete-other-labels: true` by default.** Sub-decision within A. Rejected: organically-added project-specific labels are the natural adoption pattern; the seed shouldn't ship with a foot-gun. Flip when the taxonomy stabilises.
- **Pinning to `@v2` (or any major version tag) instead of SHA.** Rejected: the seed's discipline is "named gates for named drift", and a moving tag is a named gate that doesn't actually gate anything. SHA-pin makes upstream changes a visible bump rather than a silent runtime shift.
- **Defer maintenance verification to a future bump.** Rejected: the seed's whole posture is "named gates for named drift"; shipping a stale action contradicts that. Maintenance was verified pre-pin and the result is documented above.
