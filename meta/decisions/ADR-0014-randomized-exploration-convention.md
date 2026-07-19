# ADR-0014 — Randomized-exploration testing convention (PBT / Monte-Carlo)

## Status

Accepted — 2026-07-19. Implements item 9 of the Tier-1 backport set
([#35](https://github.com/pdlourenco/disciplined-project-seed/issues/35));
decided in
[`meta/analyses/2026-07-17-ppqq-adigator-tombo-sid-backport-analysis.md`](../analyses/2026-07-17-ppqq-adigator-tombo-sid-backport-analysis.md)
§3, §4, §9 item 9. Promoted from Tier 2 — with the periodic-forced-run
requirement added — by maintainer decision in the PR #37 review.

## Context

Two adopters independently built randomized-exploration testing and
converged on the **same three design choices** without contact:

- One (MATLAB, Monte-Carlo V&V): a campaign randomizing function bodies,
  shapes, sizes, and parameters against tolerance-free oracles (cross-mode
  exact equality; generators emitting functions whose exact derivative is
  known by construction; sparsity-superset checks); never a required PR
  check — a fixed-seed smoke test covers per-merge drift; every failing
  seed delta-debugged to a minimal reproducer and promoted to a committed
  deterministic regression case. Motivation on record: bugs live
  "precisely in the *combinations* nobody enumerated."
- One (TypeScript, property-based testing): seeded reproducibility with a
  pinned seed and a committed counterexample corpus as regression
  fixtures; a three-layer scope model (pure engines per-PR / stateful
  nightly / never-randomize); and the oracle-trap rule — "assert
  invariants, not a reimplementation."
- A third adopter is a partial data point: ad-hoc Monte-Carlo used as a
  review/verification tool (a 200-trial calibration proved its review's
  highest-severity finding), no seeded convention.

This is the same convergence class that put `analyses/` in Tier 1. The
maintainer promoted it (twice, in the PR #37 review) and added a
requirement the adopter ADRs lack: keeping the campaign out of the PR gate
must be paired with a **forcing mechanism for periodic runs** — end of a
roadmap phase, after major bug fixes, after major features — so "not in
CI" cannot decay into "never".

## Decision

`docs/CONTRIBUTING.md` §"Randomized-exploration testing (PBT /
Monte-Carlo)": an optional convention carrying the three convergent rules
(invariants/oracles, never a reimplementation; seeded reproducibility with
failing cases promoted to committed deterministic fixtures — delta-debug
first as the strongest form; unbounded campaign out of the PR gate, fixed-
seed smoke per merge) plus the **mandatory floor for adopters of the
convention**: a "run the campaign and triage failures" step at every phase
completion (`PHASE-TEMPLATE.md` §10 Follow-ups, *Admin*, alongside the deferral sweep)
and in the PR checklist for major-bug-fix / major-feature PRs. A scheduled
CI run with auto-filed issues is named as optional hardening.

## Consequences

- Projects with invariant-bearing engine surfaces get the convention
  pre-derived, with the two independent implementations' agreement as its
  justification.
- The floor closes the gap the maintainer identified: rule 3 alone leaves
  the campaign with no forcing function. Tying it to phase completion
  reuses an existing checkpoint (the deferral sweep fires at the same
  moment) rather than inventing a new ceremony.
- "Major bug / major feature" in the PR-checklist trigger is a judgment
  call, deliberately: a mechanical definition would either under-trigger
  or spam every PR. The checklist row makes the judgment visible instead
  of automatic.
- The convention is optional; the floor binds only adopters of the
  convention. A project that never randomizes deletes one template bullet
  and one checklist row.

## Alternatives considered

- **Keep it Tier 2 (deferred with a named trigger).** Rejected by
  maintainer decision: two adopters built it without waiting for the
  trigger to fire, which undercuts the trigger — the demand is already
  demonstrated.
- **Campaign as a required PR check.** Rejected: both adopter ADRs
  independently keep the unbounded run out of the merge path (randomized
  wall-clock and flake risk in the gate); the fixed-seed smoke test covers
  per-merge drift.
- **Scheduled CI as the mandatory floor** (instead of process-level
  steps). Rejected as *floor*: it assumes runner budget and toolchain the
  seed can't require of every adopter — a phase-completion checklist step
  costs nothing and hits the moments the maintainer named. Scheduled CI
  ships as the optional hardening.
- **Release-gate only** (run the campaign before releases). Rejected:
  phase ends and major fixes/features — the moments the input space just
  changed — would slip through; that timing gap is exactly the
  maintainer's stated concern.
- **Prescribe the tooling** (fast-check, a `tests/montecarlo/` layout).
  Rejected: the convergence is on the three design rules, not the stack;
  tooling is per-ecosystem and stays downstream.
