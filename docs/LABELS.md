# [PROJECT] — Issue & PR Labels

The label taxonomy for GitHub issues and pull requests. Labels are how reviewers and contributors filter, prioritise, and track work across the project.

This file is the **single source of truth** for label names, descriptions, and conventions. The GitHub repo's actual labels (Settings → Labels) should match the catalogue below exactly. When drift is found, this file wins — the repo labels get fixed to match.

Changing this taxonomy is a major decision per [`../CLAUDE.md`](../CLAUDE.md) §4 (changing it affects every future issue and PR). Routine labelling — applying existing labels to existing issues — is not.

## Catalogue

### Lifecycle (apply one progression state, and/or `deferred`)

| Name | Color | Description |
|---|---|---|
| `discussion` | `FBCA04` | Decision is open; alternatives on the table, no resolution yet |
| `decided` | `0E8A16` | Decision is locked; awaiting follow-up implementation / ADR |
| `ready` | `1D76DB` | All prerequisites met; ready to implement |
| `deferred` | `C5DEF5` | Postponed with a named trigger condition (deferred-with-conditions, not deferred-forever) |

State machine: `discussion → decided → ready`. `deferred` is a parallel modifier that may apply **alongside** any of the three progression states — most commonly `decided + deferred` (the decision is locked but implementation is parked until a named trigger fires) or `discussion + deferred` (the decision itself is parked).

The `deferred` label is the labels-layer expression of the *deferred-with-conditions* discipline used elsewhere in the project's docs (`Deferred (not yet wired)` in [`CONTRIBUTING.md`](CONTRIBUTING.md) §CI strategy, `Deferred` in [`SPEC.md`](SPEC.md), `Future extensions` in [`DESIGN.md`](DESIGN.md), `Future Phases` in [`ROADMAP.md`](ROADMAP.md), `Follow-ups` in each phase plan). Nothing is "later" without saying what brings it back; without a named trigger in the issue body, do not apply `deferred` — close with "won't fix" instead.

Lifecycle labels are only meaningful on decision-bearing issues. Pure implementation tickets, bug reports, and chores don't need them.

### Topic (apply one or more)

| Name | Color | Description |
|---|---|---|
| `schema` | `5319E7` | Data shape / migrations / contract-bearing field changes |
| `spec` | `0052CC` | Contract layer: changes to `docs/SPEC.md` |
| `design` | `8E44AD` | Design rationale: `docs/DESIGN.md` and `docs/design/*.md` |
| `documentation` | `0075CA` | Root-level docs (README, CONTRIBUTING, REVIEW_CONTEXT, STRUCTURE, decisions/, plans/, this file) |
| `implementation` | `2EA44F` | Application code, not docs |
| `UX` | `BFD4F2` | User experience: flow, interaction, copy |
| `UI` | `F9D0C4` | Visual surface: layout, components, styling |
| `bug` | `D73A4A` | Defect; expected vs actual mismatch |
| `security` | `B60205` | Security-relevant: auth, encryption, isolation, PII |

#### Disambiguation

- **`design` vs `documentation`** — `design` is for changes to rationale / architecture docs (`DESIGN.md`, `docs/design/*.md`, the ADR set). `documentation` is for everything else doc-shaped.
- **`schema` vs `implementation`** — a PR that adds or changes a field on a shared artifact is `schema` (the contract surface moved); a PR that adds code consuming an unchanged field is `implementation`. PRs that move both together get both labels.
- **`spec` vs `schema` vs `design`** — `spec` flags that `SPEC.md` prose changed; `schema` flags that the contract itself changed; `design` flags rationale changes. A typical contract update touches all three.
- **`UX` vs `UI`** — `UX` describes the flow ("user completes checkout without confirming twice"); `UI` describes the surface ("checkout button colour, position, label"). Most PRs touch both — apply both.

### Phase (apply at most one)

| Name | Color | Description |
|---|---|---|
| `phase-0`, `phase-1`, … | `D4C5F9` | Per-phase work, created on demand |

Don't pre-create all phase labels. Add `phase-N` the first time an issue or PR targets that phase; pre-creating clutters the label picker with phases that don't yet exist. When an issue spans phases (e.g. a decision made in Phase 0 implemented in Phase 1), apply the label of the *deciding* phase, not the implementing one — the issue's purpose is the decision.

## Usage examples

| Issue / PR shape | Lifecycle | Topic | Phase |
|---|---|---|---|
| "Phase 0 decision about [error-handling policy]" | `discussion` → `decided` → `ready` | — | `phase-0` |
| "[Shared artifact] gains optional [field]" | — | `schema`, `spec`, `implementation` | (varies) |
| "[Feature] flow needs fewer confirmations" | — | `UX`, `UI` | (varies) |
| "[Bug] in [module]" | — | `bug`, `implementation` | (varies) |
| "Phase 0 decision deferred until [trigger]" | `decided`, `deferred` | (varies) | `phase-0` |
| "Deferred until [trigger]: [topic]" | `deferred` | (varies) | (varies) |
| "Update [doc] to reflect [change]" | — | `documentation` | — |

## Adding a new label

The label taxonomy is load-bearing for issue and PR hygiene. Adding, renaming, removing, or repurposing a label is a **major decision** per [`../CLAUDE.md`](../CLAUDE.md) §4: surface the proposal (name, category, colour, description, disambiguation against neighbours) before adding it. If the change sticks, update this file in the same PR that introduces the label, and update the repo's catalogue (Settings → Labels) to match.

A new label should:

- Have a clear definition that doesn't overlap an existing one — or, if it overlaps deliberately, update the disambiguation entry in the same PR.
- Sit in one of the three existing categories. Proposing a new category is itself a major decision and warrants surfacing the case for why an existing category won't do.

## Seeding the catalogue

The catalogue is reconciled by the **Sync labels** workflow at [`.github/workflows/sync-labels.yml`](../.github/workflows/sync-labels.yml), which reads [`.github/labels.yml`](../.github/labels.yml) — the machine-readable companion to this file. After cloning the seed, run the workflow once: **Actions → Sync labels → Run workflow**. Subsequent edits to the catalogue land in PRs that touch both this file and `.github/labels.yml` together; re-run the workflow when those PRs merge.

`.github/labels.yml` and this file are paired — edits to one require edits to the other in the same PR, same co-landing discipline as ADR + SPEC changes (see [`decisions/README.md`](decisions/README.md) §"What an ADR is — and isn't").

**Conservative defaults** (see [ADR-0001](decisions/ADR-0001-label-sync.md) for rationale and flip conditions):

- **`workflow_dispatch` only** — the workflow does not auto-run on push to `main`. Flip to add `push: branches: [main]` once you trust label-YAML edits to be caught at PR review time.
- **`delete-other-labels: false`** — labels added organically to the live repo (`priority:p0`, `client:acme`, …) are preserved across sync runs. Flip to `true` once the taxonomy is stable and the YAML should own the catalogue authoritatively.

Phase labels (`phase-0`, `phase-1`, …) are added on demand and are deliberately not listed in `.github/labels.yml` — see [Phase (apply at most one)](#phase-apply-at-most-one) below.

## Renaming and removing

Renames and removes affect history: every old issue and PR carrying the old label loses its categorisation unless mass-relabelled.

- **Renaming.** Confirm the rename is worth the churn. Clearer category names usually are; stylistic preferences usually aren't. `gh label edit <old> --name <new>` preserves existing assignments. Update this file in the same PR.
- **Removing.** Prefer marking the label as deprecated in this file with a "use X instead" note for one release cycle before deleting it from the catalogue. Removing a label deletes its assignments — preserve the migration path.

## See also

- [`../CLAUDE.md`](../CLAUDE.md) §4 — major-decision policy that gates taxonomy changes.
- [`CONTRIBUTING.md`](CONTRIBUTING.md) §"Issue & PR labels" — pointer back to this file from the contributor workflow.
- [`decisions/README.md`](decisions/README.md) §"ADR lifecycle" — the lifecycle labels track an issue-first ADR through its decision flow.
