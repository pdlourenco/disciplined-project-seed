# Disciplined project seed

A documentation skeleton for projects that want explicit contracts and a discipline of documented decisions as their working substrate. Opinionated about the *shape* of each artifact, agnostic about the *contents* — every fill-in slot belongs to the consumer.

The discipline pays off most when contributors — human and agent — edit independent modules in parallel and the cost of an unnoticed contract break is higher than the cost of writing things down. If that doesn't sound like your project, adopt selectively; `CLAUDE.md`, `REVIEW_CONTEXT.md`, and the ADR set are the pieces that carry weight even at single-contributor scale.

## How to adopt

1. **Start from the seed.** Click *Use this template* on the [GitHub repo](https://github.com/pdlourenco/disciplined-project-seed) for a clean history, or clone-and-strip-history manually.
2. **Decide what to do with `meta/`.** The seed ships its own evolution history (ADRs about how the seed was built, plus a CHANGELOG) under [`meta/`](meta/). Two paths:
   - **Strip it** with `rm -rf meta/` for a clean repo — `docs/decisions/` is then yours to start at ADR-0001, and the root `CHANGELOG.md` is yours to start fresh. The inherited scaffolding still works.
   - **Keep it as reference** if you want to understand why the inherited CI workflow / labels.yml / branch-protection.yml are shaped the way they are. See [`meta/README.md`](meta/README.md).
3. **Replace markers.** Search the tree for `[PROJECT]` and `<!-- FILL IN -->`. Each one is intentional. Also scan for inline `<!-- ... -->` placeholders — they render as nothing, so leaving one in production text leaves the doc visibly unfinished (em-dash artifacts, dangling commas).
4. **Strip what doesn't apply.** Common prunings:
   - Cross-language contract sections in `docs/SPEC.md` for single-language projects.
   - Cross-platform sections in `docs/DESIGN.md` for platform-specific projects.
   - The "Tier 1 — Contract enforcement" section in `docs/CONTRIBUTING.md` for projects without cross-component contracts.
   - Optional sections in `docs/DESIGN.md` (process architecture, cross-platform strategy, installation).
5. **Keep section headings stable** even when their content is empty for now. Consistent structure across your projects pays off.
6. **Replace `LICENSE`.** The seed ships under MIT with the seed author as copyright holder; adopters should replace the file with their project's chosen license (or rewrite the copyright line to point at the adopter).
7. **Seed the label catalogue.** Run Actions → Sync labels → Run workflow once against the new repo so the live labels match [`docs/LABELS.md`](docs/LABELS.md).
8. **Set up branch protection** with `scripts/setup-branch-protection.sh` once your CI workflow's job names are settled.

CI and packaging examples assume GitHub Actions and common tooling; adapt to your platform.

## What's in the seed

**Root-level signal**

- `CLAUDE.md` — short operating rules for coding agents; delegates to the authoritative docs below.
- `.github/pull_request_template.md` — PR form referencing the pre-push review convention.

**Docs (`docs/`)**

- `CONTRIBUTING.md` — CI strategy, pre-push review and pre-push CI conventions, ADR policy, contract-change workflow, label conventions. Authoritative source for contributor mechanics.
- `DESIGN.md` — architectural rationale. Not a contract; answers "why is it shaped this way".
- `SPEC.md` — binding external contracts. The surfaces that cross language, process, or module boundaries.
- `ROADMAP.md` — phased delivery plan. Terse per-phase summaries that link to detailed plans.
- `LABELS.md` — issue and PR label taxonomy (lifecycle / topic / phase). Load-bearing for hygiene; changes are a major decision per `CLAUDE.md` §4.
- `REVIEW_CONTEXT.md` — seed context for a reviewer agent (and new contributors).
- `STRUCTURE.md` — target project layout. Aspirational, updated as the repo evolves.
- `analyses/README.md` — convention for dated, immutable analysis snapshots (optional doc type; add the folder when the first analysis is written).

**Plans and decisions**

- `docs/plans/PHASE-TEMPLATE.md` — shape of an individual phase plan.
- `docs/plans/README.md` — index of phase plans.
- `docs/decisions/ADR-TEMPLATE.md` — shape of an Architecture Decision Record.
- `docs/decisions/README.md` — ADR conventions, ADR lifecycle (ADR-first / issue-first), and index.

## How the documents relate

**`DESIGN.md` and `SPEC.md` are a pair with a clear division of labor:**

- **`DESIGN.md` is rationale.** Why this architecture, what alternatives were considered, what trade-offs were accepted. Prose is fine; field tables are not.
- **`SPEC.md` is contract.** What the on-disk formats, RPC shapes, and cross-boundary conventions actually are. Machine-checkable where possible.

If either drifts into the other's job, both rot. `DESIGN.md` should link to `SPEC.md` for contract details; `SPEC.md` should link to `DESIGN.md` for rationale.

**`ROADMAP.md` and the phase plans are also a pair:**

- `ROADMAP.md` is the portfolio view; each phase entry is ≤1 screen and links to a detailed plan in `plans/`.
- A phase plan is the execution view: PR sequence, per-PR gates, success criteria, follow-ups.

If the plan isn't roughly an order of magnitude longer than its roadmap entry, one of them is the wrong shape.

**ADRs capture decisions that would otherwise drift.** They are the tactical layer beneath `DESIGN.md` and `SPEC.md`: not the architecture itself, but the choices within it that future contributors will wonder about. `CONTRIBUTING.md` describes when to write one; the ADR README describes how and which lifecycle to use.

**Left side and right side: every commitment has a check.** The seed borrows lightly from [V-cycle](https://en.wikipedia.org/wiki/V-model) / ECSS-style engineering — no formal V&V plans, no qualification documents, the ceremony stays out — to treat the doc set as two legs that mirror each other. **Left** commits to *what*: `DESIGN.md`, `SPEC.md`, `ROADMAP.md`, phase plans, ADRs — intent, contracts, scope. **Right** verifies *built right*: contract-consistency tests, the four-tier CI in `docs/CONTRIBUTING.md`, the pre-push and PR-stage reviewer-subagent conventions (`§Pre-push self-review`, `§Reviewing an open PR`), the per-rule `Verified by:` annotation in `docs/SPEC.md`, branch protection. A SPEC rule with `Verified by: <!-- nothing -->` is visible debt; a review that didn't verify is a validation-only review and says so in the verdict. See [ADR-0007](meta/decisions/ADR-0007-v-cycle-additions.md) for the rationale.

**A recurring pattern across every document in this set: *deferred-with-conditions* lists.** They appear as "Deferred (not yet wired)" in CI, "Deferred to post-Phase-N" in `SPEC.md`, "Future Extensions" in `DESIGN.md`, "Future Phases" in `ROADMAP.md`, and "Follow-ups" in each phase plan. The discipline is the same at every layer: what's deferred, why it's deferred, what would bring it back. This prevents "later" from becoming "never" by accident.

## How the seed evolves

The seed is a living artifact. When a downstream adopter discovers a convention that should belong here, it gets back-ported as a refinement; when scaffolding stops earning its keep, it's removed.

- **What changed in the seed since you forked:** [`meta/CHANGELOG.md`](meta/CHANGELOG.md). Each entry names the PR and describes what an adopter needs to merge back. (Your project's own CHANGELOG lives at the repo root and tracks your changes; the seed's history lives under `meta/`.)
- **Why the inherited scaffolding is the way it is:** [`meta/decisions/`](meta/decisions/) holds the ADRs that captured the trade-offs. Useful when you're considering deviating from a default — read the ADR first.
- **Adopting a refinement:** the `meta/CHANGELOG.md` entries are written to be self-contained. For minor refinements (new conventions, wording tightenings), copy the merged PR's diff into your fork. For structural changes (renamed docs, restructured sections), the entry calls out the adoption path explicitly.
- **Proposing a refinement:** if you've adopted the seed and found a convention that should belong here, open an issue against [the seed repo](https://github.com/pdlourenco/disciplined-project-seed) describing the gap. The seed's own discipline (ADR lifecycle in `docs/decisions/README.md`, label conventions in `docs/LABELS.md`) applies to changes to the seed itself.
