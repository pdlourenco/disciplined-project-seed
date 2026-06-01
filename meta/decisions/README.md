# Seed-meta Architecture Decision Records

ADRs documenting the seed's own design choices — separate from `docs/decisions/`, which is for adopter projects' ADRs (`docs/decisions/README.md` for conventions; this directory uses the same conventions).

See [`../README.md`](../README.md) for what the `meta/` directory is and how adopters handle it.

## Index

- [ADR-0001](ADR-0001-label-sync.md) — Sync GitHub labels from `.github/labels.yml` via an Action, defaults conservative — Accepted — `EndBug/label-sync` SHA-pinned, `workflow_dispatch` only, `delete-other-labels: false`; paired with `docs/LABELS.md`.
- [ADR-0002](ADR-0002-active-trivial-ci-workflow.md) — Ship an active trivial CI workflow with four-tier framing in comments — Accepted — `.github/workflows/ci.yml` runs four tier-3 jobs on the seed itself (markdown lint, internal link check, dangling-placeholder audit, workflow YAML lint); tiers 1/2/4 are commented stubs adopters extend.
- [ADR-0003](ADR-0003-labels-applied-via-reviewer.md) — Label-vs-diff checking via the reviewer subagent (not a CI gate); pre-applied issue templates — Accepted — pre-push reviewer prompt extended with label-vs-diff + lifecycle currency bullets; `.github/ISSUE_TEMPLATE/` ships `decision-proposal.yml` and `bug.yml` with pre-applied labels; CI merge-gate (A) deferred with three named revisit conditions.
- [ADR-0004](ADR-0004-pre-push-ci-via-ecosystem-task-runner.md) — Pre-push CI invocation via the ecosystem's own task runner — Accepted — `CONTRIBUTING.md §"Pre-push CI run"` recommends defining CI commands once in the ecosystem's task runner (tox / cargo / npm scripts / etc.) and calling them from both the workflow and the pre-push invocation; `act` reframed as a niche tool; tier 1 + tier 3 only pre-push (~30s budget).
- [ADR-0005](ADR-0005-branch-protection-as-code-classic.md) — Branch protection as code: classic schema + human-triggered apply + scheduled drift check — Accepted — `.github/branch-protection.yml` is the desired state; `scripts/setup-branch-protection.sh` applies it using the operator's `gh auth` credentials (no admin PAT secret); `.github/workflows/check-branch-protection.yml` runs weekly read-only drift detection.
- [ADR-0006](ADR-0006-meta-folder-for-seed-history.md) — Separate seed-meta from adopter template content via `meta/` — Accepted — moves the five preceding ADRs and the seed's CHANGELOG into `meta/`; adopters strip-or-keep via the README's *How to adopt* step.
