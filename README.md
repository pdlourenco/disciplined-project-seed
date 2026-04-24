# Project Documentation Templates

A coordinated set of documents for grounding parallel software development on explicit contracts and a discipline of documented decisions. Drop into a new or existing repo and adapt: `CLAUDE.md` at the root, the rest under `docs/`.

## What's here

**Root-level signal**

- `CLAUDE.md` — short operating rules for coding agents; delegates to the authoritative docs below.
- `.github/pull_request_template.md` — PR form that references the pre-push review convention.

**Docs (`docs/`)**

- `CONTRIBUTING.md` — CI strategy, pre-push review convention, ADR policy, contract-change workflow. The authoritative source for contributor mechanics.
- `DESIGN.md` — architectural rationale. Not a contract; answers "why is it shaped this way".
- `SPEC.md` — binding external contracts. The surfaces that cross language, process, or module boundaries.
- `ROADMAP.md` — phased delivery plan. Terse per-phase summaries that link to detailed plans.
- `REVIEW_CONTEXT.md` — seed context for a reviewer agent (and new contributors).
- `STRUCTURE.md` — target project layout. Aspirational, updated as the repo evolves.

**Plans and decisions**

- `docs/plans/PHASE-TEMPLATE.md` — the shape of an individual phase plan.
- `docs/plans/README.md` — index of phase plans.
- `docs/decisions/ADR-TEMPLATE.md` — the shape of an Architecture Decision Record.
- `docs/decisions/README.md` — ADR conventions and index.

## How the documents relate

**`DESIGN.md` and `SPEC.md` are a pair with a clear division of labor:**

- **`DESIGN.md` is rationale.** Why this architecture, what alternatives were considered, what trade-offs were accepted. Prose is fine; field tables are not.
- **`SPEC.md` is contract.** What the on-disk formats, RPC shapes, and cross-boundary conventions actually are. Machine-checkable where possible.

If either drifts into the other's job, both rot. `DESIGN.md` should link to `SPEC.md` for contract details; `SPEC.md` should link to `DESIGN.md` for rationale.

**`ROADMAP.md` and the phase plans are also a pair:**

- `ROADMAP.md` is the portfolio view; each phase entry is ≤1 screen and links to a detailed plan in `plans/`.
- A phase plan is the execution view: PR sequence, per-PR gates, success criteria, follow-ups.

If the plan isn't roughly an order of magnitude longer than its roadmap entry, one of them is the wrong shape.

**ADRs capture decisions that would otherwise drift.** They are the tactical layer beneath `DESIGN.md` and `SPEC.md`: not the architecture itself, but the choices within it that future contributors will wonder about. `CONTRIBUTING.md` describes when to write one; the ADR README describes how.

**A recurring pattern across every document in this set: *deferred-with-conditions* lists.** They appear as "Tier 4 / Deferred" in CI, "Deferred to post-Phase-N" in `SPEC.md`, "Future Extensions" in `DESIGN.md`, "Future Phases" in `ROADMAP.md`, and "Follow-ups" in each phase plan. The discipline is the same at every layer: what's deferred, why it's deferred, what would bring it back. This prevents "later" from becoming "never" by accident.

## Customizing for your project

1. Replace every `<!-- FILL IN -->` and `[PROJECT]` marker. These are the minimum edits.
2. Delete sections that don't apply. Common prunings:
   - Cross-language contract sections in `SPEC.md` for single-language projects.
   - Cross-platform sections in `DESIGN.md` for platform-specific projects.
   - The "Tier 1 — Contract enforcement" section in `CONTRIBUTING.md` for projects without cross-component contracts.
3. Keep section headings stable even when content is empty — consistent structure across your projects pays off.
4. CI and packaging examples assume GitHub Actions and common tooling; adapt to your platform.

## A note on when this discipline earns its keep

These templates assume a project where contributors — human and agent — will edit independent modules in parallel, and where the cost of an unnoticed contract break is higher than the cost of writing things down. If that's not your project, some of this will feel like overhead. That's a legitimate call; adopt selectively. The documents that carry the most weight even for single-contributor projects are `CLAUDE.md`, `REVIEW_CONTEXT.md`, and the ADR set — they're what lets a future you (or a future agent) pick up context without re-deriving it.
