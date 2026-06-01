# ADR-0003 — Label-vs-diff checking via the reviewer subagent (not a CI gate); pre-applied issue templates

## Status

Accepted — 2026-05-31.

## Context

[`docs/LABELS.md`](../../docs/LABELS.md) defines a three-category taxonomy (lifecycle / topic / phase) that's load-bearing for issue and PR hygiene. The [`pull_request_template.md`](../../.github/pull_request_template.md) carries a `Labels applied per docs/LABELS.md` checklist row, but nothing in the framework *enforces* that labels actually get applied — the checkbox relies on contributor self-attestation.

Concrete failure modes ([#9](https://github.com/pdlourenco/disciplined-project-seed/issues/9)):

- An issue opened without lifecycle labels silently drifts through `discussion → decided → ready` without anyone updating state.
- A PR ships without topic labels, making filtering, dashboards, and the catalogue-as-source-of-truth invariant from [ADR-0001](ADR-0001-label-sync.md) hollow.
- A lifecycle label applied at creation and never updated is **worse than no lifecycle label at all**, because it lies. Lifecycle is state, not classification.
- On public-facing projects, external contributors can't apply labels at all (GitHub permissions), so any hard CI gate blocks their PRs until a maintainer relabels.

The framing question matters: "enforcement" is the wrong frame for labels. Labels organize and filter; they don't gate. A PR can be excellent and unlabeled; the right response is a post-hoc relabel in two seconds, not a CI failure. Hard-gating conflates "this work is organized" with "this work is good."

Surfaced and decided in [#9](https://github.com/pdlourenco/disciplined-project-seed/issues/9).

## Decision

Three coordinated changes, no CI gate:

- **C — Reviewer-prompt extension.** The pre-push self-review subagent prompt in [`docs/CONTRIBUTING.md` §"Reviewer prompt"](../../docs/CONTRIBUTING.md) gains two new bullets: (5) does the `Labels applied` checklist row match the diff's surface? (touches `SPEC.md` → `spec`; touches `DESIGN.md` → `design`; etc.) (6) for linked issues, is the current lifecycle label still accurate given the conversation? The reviewer subagent already runs on every push; the marginal cost is a few lines of prompt.

- **Lightweight B — issue templates with pre-applied labels.** Two YAML form templates under `.github/ISSUE_TEMPLATE/`:
  - [`decision-proposal.yml`](../../.github/ISSUE_TEMPLATE/decision-proposal.yml) — structured fields matching the ADR-lifecycle shape (Context / Alternatives / Where it lands / Recommendation); pre-applies `discussion` + `design`.
  - [`bug.yml`](../../.github/ISSUE_TEMPLATE/bug.yml) — structured fields for expected / actual / reproduction / affected surfaces; pre-applies `bug` (no lifecycle — `LABELS.md` §Lifecycle says bug reports don't need them).

- **A — PR-merge gate, deferred** with explicit revisit conditions (see §Consequences).

## Consequences

- **The reviewer is responsible for label drift now.** The pre-push self-review's scope grows from "principle / scope drift / ADR" to also include label-vs-diff consistency and lifecycle currency. The convention in [`docs/CONTRIBUTING.md` §"Pre-push self-review"](../../docs/CONTRIBUTING.md) is the load-bearing change here, not the prompt text — and the convention now governs labels as well as principles.
- **Lifecycle labels are treated as state, not classification.** The reviewer prompt explicitly checks "is the lifecycle label still accurate given the conversation?" on linked issues. A `discussion` label that should now be `decided` is a finding. This closes a real failure mode that pure classification labels don't have.
- **No CI gate on labels.** External contributors can't apply labels (GitHub permissions); a hard gate would block their PRs. The reviewer subagent runs against the contributor's branch, not against repo-side permissions — sidesteps the papercut entirely.
- **Issue templates carry pre-applied labels by default.** Decision proposals open at `discussion + design`; bug reports open at `bug` (no lifecycle). Contributors can edit the labels after creation; the templates set sensible defaults.
- **A is deferred with three named revisit conditions.** When *any* of them fires, re-open the gating question: (1) mis-labeled merged PRs exceed X% over a rolling window (X and the window are project-specific — pick when this becomes a problem worth measuring); (2) contributor count grows past N with shared labelling responsibility; (3) [#11](https://github.com/pdlourenco/disciplined-project-seed/issues/11) resolves the required-check-as-code problem so adding a required-status-check is a tracked configuration rather than a manual GitHub-settings click.
- **The catalogue from [ADR-0001](ADR-0001-label-sync.md) is a prerequisite.** The reviewer prompt's label-vs-diff check can only run against labels that exist; the issue templates can only pre-apply labels that exist. Both depend on the Sync labels workflow having run at least once against the live repo.

## Alternatives considered

The lettering matches the issue thread on [#9](https://github.com/pdlourenco/disciplined-project-seed/issues/9) so anyone re-reading the discussion can map decisions back to the recommendation.

- **A — PR-merge gate.** A GitHub Action that requires each PR to carry at least one topic label before merge (block label `needs-labels` until applied, or required-status-check via `mheap/github-action-required-labels` or similar). Rejected for now: enforcement is the wrong frame for labels (post-hoc relabel is two seconds vs blocking the PR); external contributors hit a known papercut (no permission to apply labels); adds a required-status-check, which itself drifts because GitHub branch protection isn't version-controlled until [#11](https://github.com/pdlourenco/disciplined-project-seed/issues/11) lands. Deferred with the revisit conditions above; not "won't fix".

- **B — full issue forms with required-label dropdowns.** GitHub issue forms can present labels as a required dropdown field. Considered and reduced in scope to "lightweight B" (templates with `labels:` frontmatter pre-applying defaults). Rejected at full strength because dropdowns force a structural decision (how many template variants, which labels appear as options) that's worth a separate ADR if and when it earns its keep. Lightweight B closes most of the issue-side gap at near-zero cost.

- **C — reviewer-prompt extension only.** Chosen. See §Decision.

- **D — status quo (PR template checkbox, no enforcement).** Rejected: the checkbox without verification is a self-attestation that the reviewer can't audit at scale; lifecycle currency is invisible to it entirely.

- **A + C combined.** Originally recommended in the issue body. Rejected after discussion: A's marginal value over C for a small project is small; A's failure modes are real. Deferred-with-conditions is the right shape for this trade-off — "ship C, document when A would join" follows the seed's own discipline.

- **C alone, without the lightweight B issue templates.** Considered: pure prompt extension, no change to issue creation. Rejected because lightweight B closes the issue side at the source (label drift on issues that *never* got labelled is a different failure mode than label drift on issues whose lifecycle state changed), and the cost is negligible — two YAML files with `labels:` frontmatter.

- **Add lifecycle labels to bug.yml** (e.g. `bug + ready`). The issue thread loosely suggested `lifecycle:ready + topic:bug` for bug.yml; this contradicts `LABELS.md` §Lifecycle ("Pure implementation tickets, bug reports, and chores don't need [lifecycle labels]"). Followed `LABELS.md` as source of truth; bug.yml pre-applies `bug` only.
