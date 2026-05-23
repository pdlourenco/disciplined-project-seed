# Issue & PR labels

This document is the source of truth for the label taxonomy used on issues and PRs. The taxonomy has three categories:

- **Lifecycle** — applied to decision-bearing issues. Apply one.
- **Topic** — what an issue or PR is about. Apply one or more.
- **Phase** — which delivery phase from [`ROADMAP.md`](ROADMAP.md) the work belongs to. Apply one when applicable; not pre-created.

Changes to this taxonomy are a major decision in the sense of [`../CLAUDE.md`](../CLAUDE.md) §4 — see [Adding a new label](#adding-a-new-label) below.

## Lifecycle (apply one)

Used on decision-bearing issues — typically those routed through the issue-per-decision workflow described in [`decisions/README.md`](decisions/README.md). The progression is linear: `discussion → decided → ready`. `deferred` is a parallel state with a named return trigger.

- **`discussion`** — open question. The issue describes context, alternatives, and where the decision would land. Comments converge toward a recommendation.
- **`decided`** — the question has been resolved in the thread. If the decision needs to stick (see ADR criteria in [`CONTRIBUTING.md`](CONTRIBUTING.md) §"Design decisions (ADRs)"), a follow-up writes the ADR; otherwise the issue closes with the decision summarized in the final comment.
- **`ready`** — the decision is captured (ADR merged or noted in the appropriate doc) and any implementation follow-up is scheduled. The issue is ready to close or hand off.
- **`deferred`** — the decision is parked **with a named return trigger**. This applies the *deferred-with-conditions discipline* used across the project's docs (`Deferred (not yet wired)` in `CONTRIBUTING.md` §CI strategy, `Deferred` in `SPEC.md`, `Future extensions` in `DESIGN.md`, `Future Phases` in `ROADMAP.md`, `Follow-ups` in each phase plan): nothing is "later" without saying what brings it back. Without a named trigger in the issue body, do not apply this label — close with "won't fix" instead.

Lifecycle labels are only meaningful on decision-bearing issues. Pure implementation tickets, bug reports, and chores don't need them.

## Topic (apply one or more)

Topic labels say what an issue or PR is about. Apply as many as fit.

- **`schema`** — changes to a binding shared data shape (field names, types, on-disk artifact layout). The contract itself, not its prose description.
- **`spec`** — changes to `docs/SPEC.md`. The prose form of a contract. Often paired with `schema`.
- **`design`** — changes to `docs/DESIGN.md` or rationale-only documents.
- **`documentation`** — changes to docs that are not themselves contracts (README, CONTRIBUTING, REVIEW_CONTEXT, STRUCTURE, decisions/, plans/, this file).
- **`implementation`** — code changes that realize an existing contract.
- **`UX`** — user-facing experience: flows, copy, what the user reaches for and finds.
- **`UI`** — user-facing surface: layout, widgets, visual treatment.
- **`bug`** — something is broken against a stated invariant or contract.
- **`security`** — security-relevant: authn/authz, data exposure, supply chain, sandboxing.

### Disambiguation

- **`design` vs `documentation`** — `design` is for changes to rationale/architecture docs that carry load (`DESIGN.md`, the ADR set). `documentation` is for everything else doc-shaped.
- **`schema` vs `implementation`** — a PR that adds or changes a field on a shared artifact is `schema` (the contract surface moved); a PR that adds code consuming an unchanged field is `implementation`. PRs that move both together get both labels.
- **`spec` vs `schema` vs `design`** — `spec` flags that `SPEC.md` prose changed; `schema` flags that the contract itself changed; `design` flags rationale changes. A typical contract update touches all three. Apply all that fit.
- **`UX` vs `UI`** — `UX` describes the flow ("user completes checkout without confirming twice"); `UI` describes the surface ("checkout button colour, position, label"). Most PRs touch both — apply both.

## Phase (apply one when applicable)

Phase labels mark which delivery phase from [`ROADMAP.md`](ROADMAP.md) the issue or PR belongs to. Use the form `phase-0`, `phase-1`, etc.

**Do not pre-create the full set.** Create a phase label on demand, the first time an issue or PR is filed against that phase. Pre-creating clutters the label picker with phases that don't yet exist.

When an issue spans phases (e.g. a decision made in Phase 0 implemented in Phase 1), apply the label of the *deciding* phase, not the implementing one — the issue's purpose is the decision.

## Seeding the catalogue

Run once at project setup. Adjust colours to taste; descriptions below are the canonical short forms.

```bash
# Lifecycle
gh label create discussion --description "Open question; converging on a decision"
gh label create decided    --description "Question resolved; ADR / doc update pending or done"
gh label create ready      --description "Decision captured; ready to close or hand off"
gh label create deferred   --description "Parked with a named return trigger"

# Topic
gh label create schema         --description "Changes to a binding shared data shape"
gh label create spec           --description "Changes to docs/SPEC.md"
gh label create design         --description "Changes to docs/DESIGN.md or rationale"
gh label create documentation  --description "Doc changes outside the contract surface"
gh label create implementation --description "Code change realizing an existing contract"
gh label create UX             --description "User-facing experience: flows, copy"
gh label create UI             --description "User-facing surface: layout, visuals"
gh label create bug            --description "Broken against a stated invariant or contract"
gh label create security       --description "Authn/authz, data exposure, supply chain"
```

Phase labels are added on demand — see above.

## Examples

- **"Phase 0 decision about [error-handling policy]"** — `phase-0`, `discussion` while the thread is open; `decided` after it converges; `ready` once the ADR lands.
- **"[Shared artifact] gains optional [field]"** — `schema`, `spec`, `implementation` together. Lifecycle labels not needed.
- **"[Feature] flow needs fewer confirmations"** — `UX`, plus `UI` if visual changes follow.

## Adding a new label

The label taxonomy is load-bearing for issue and PR hygiene. Adding, renaming, removing, or repurposing a label is a **major decision** in the sense of [`../CLAUDE.md`](../CLAUDE.md) §4: surface the proposal (name, category, definition, disambiguation against neighbours) before adding it. If the change sticks, update this file in the same PR that introduces the label.

A new label should:

- Have a clear definition that doesn't overlap an existing one — or, if it overlaps deliberately, update the disambiguation entry in the same PR.
- Sit in one of the three existing categories. Proposing a new category is itself a major decision and warrants surfacing the case for why an existing category won't do.

## Rename and remove

Renames and removes affect history: every old issue and PR carrying the old label loses its categorization unless mass-relabelled.

- Before renaming, confirm the rename is worth the churn. Clearer category names usually are; stylistic preferences usually aren't. `gh label edit <old> --name <new>` preserves existing assignments.
- Before removing, prefer marking the label as deprecated in this file with a "use X instead" note for one release cycle before deleting it. Removing a label deletes its assignments.
