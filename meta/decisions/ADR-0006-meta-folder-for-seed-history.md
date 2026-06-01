# ADR-0006 — Separate seed-meta from adopter template content via `meta/`

## Status

Accepted — 2026-06-01.

## Context

The seed had accumulated five ADRs (ADR-0001 through ADR-0005) and a CHANGELOG documenting *how the seed itself was built* — decisions about label sync, CI workflow shape, branch protection mechanism, pre-push tooling, etc. All of it lived in the conventional locations:

- `docs/decisions/ADR-NNNN-*.md` for the ADRs.
- `CHANGELOG.md` at the repo root for the history.

When an adopter forks via *Use this template*, they inherit those locations verbatim. That creates two problems:

1. The adopter's `docs/decisions/` index conflates inherited seed-meta ADRs with the adopter's own ADRs (which don't exist yet). Their ADR-0001 should be about *their* project, not numbered 0006 onward to coexist with the seed's history.
2. The adopter's `CHANGELOG.md` starts as the seed's evolution log rather than their project's clean slate. They have to manually scrub.

The status quo asked adopters to `rm -rf docs/decisions/ADR-*.md` and `: > CHANGELOG.md` on adoption — ambient knowledge nowhere written down, an implicit step in conflict with the seed's "make scaffolding explicit" discipline.

Surfaced and decided in conversation; no preceding issue.

## Decision

Add a top-level `meta/` directory for seed-meta content:

- `meta/decisions/ADR-0001-…md` through `ADR-0005-…md` — moved from `docs/decisions/`. `ADR-0006-…md` (this ADR) is born in `meta/decisions/`; it documents the move and is the first seed-meta artifact to *land* in `meta/` rather than to be relocated there.
- `meta/CHANGELOG.md` — the seed's evolution history, moved from the root `CHANGELOG.md`.
- `meta/README.md` — explains the directory's purpose and the two adoption paths (strip or keep-as-reference).

Root-level `CHANGELOG.md` resets to a minimal Keep-a-Changelog template — adopter starts with the file pattern, fresh content.

`docs/decisions/ADR-TEMPLATE.md` and `docs/decisions/README.md` stay in place — they're the adopter's template content (ADR conventions, format, lifecycle), not seed-meta. The conventions doc's "Index" section is now a placeholder for the adopter to fill in.

The README's *How to adopt* gains a step naming the strip-or-keep choice; the *How the seed evolves* section points at `meta/CHANGELOG.md` for the upstream-tracking flow.

## Consequences

- **Clean adoption.** An adopter who doesn't want the seed's history runs `rm -rf meta/` once. Their `docs/decisions/` is empty (ready for their own ADR-0001) and their root `CHANGELOG.md` is a Keep-a-Changelog template ready for their first release.
- **Reference-or-strip choice surfaced explicitly.** The README's *How to adopt* names the choice. Adopters who want the seed's design rationale as reference (e.g., "why is the inherited CI workflow shaped this way?") keep `meta/`. The cost of keeping is one directory in the tree.
- **Cross-refs updated.** The five moved ADRs reference `docs/CONTRIBUTING.md`, `docs/LABELS.md`, etc. — their relative paths changed from `../CONTRIBUTING.md` to `../../docs/CONTRIBUTING.md`. References *to* the ADRs from CONTRIBUTING, LABELS, the labels/branch-protection workflows, and the setup script changed from `decisions/ADR-NNNN-…md` (and `docs/decisions/ADR-NNNN-…md`) to `../meta/decisions/ADR-NNNN-…md` (and `meta/decisions/ADR-NNNN-…md`).
- **The label disambiguation rule still applies.** `LABELS.md §Disambiguation` says `design` is for "rationale / architecture docs (`DESIGN.md`, `docs/design/*.md`, the ADR set)". "The ADR set" covers both `docs/decisions/` (adopter ADRs) and `meta/decisions/` (seed ADRs) without needing a taxonomy change.
- **ADR numbering forks.** Seed-meta ADRs continue at `meta/decisions/ADR-NNNN-…md` and adopter ADRs start fresh at `docs/decisions/ADR-0001-…md`. The two namespaces never collide because they live in different directories.
- **Lint and audit scope unchanged.** `meta/` content is real prose (not template placeholders); it gets linted and audited like other working content. The skip lists in `.markdownlint-cli2.jsonc` and the placeholder-audit `find` invocation don't need updating — they continue to skip the same template files (`ADR-TEMPLATE.md`, `PHASE-TEMPLATE.md`, `SPEC.md`, etc.) regardless of `meta/`'s existence.
- **Future seed-meta artifacts go in `meta/`.** A future ADR about how the seed's own SPEC is structured, a future retroactive labelling script, etc., land in `meta/`, not in `docs/`. The line is: "is this about the seed's own design, or part of what adopters fill in?"

## Alternatives considered

- **A. `seed/` at the repo root.** Visible, sits alongside `docs/` and `scripts/`. Considered and chosen-then-rejected in favour of `meta/` because *"the seed of what?"* is ambiguous to a fresh adopter reading the tree, while *"metadata about the seed itself"* is clearer from the name without needing context.
- **B. `docs/seed/` or `docs/meta/`.** Nests under the existing doc tree. Tighter scope ("this is documentation about the seed"), less prominent. Rejected because the content is structurally peer to `docs/`, not inside it; nesting hides the "this is its own thing" framing.
- **C. `.seed/` or `.meta/`.** Hidden, signals "infrastructure, not for daily reading". Rejected because adopters who *want* to read the meta content as reference shouldn't need to discover a hidden directory; the discovery cost outweighs the prominence cost.
- **D. Single aggregated file** (e.g., `meta/HISTORY.md` combining ADRs and CHANGELOG). Rejected: ADRs and CHANGELOG entries serve different audiences and have different shapes (ADRs = per-decision rationale; CHANGELOG = chronological what-changed); aggregating loses the per-decision atomicity that makes ADRs useful.
- **E. Status quo + documented adoption steps** (`rm -rf docs/decisions/ADR-*.md; : > CHANGELOG.md`). Rejected: ambient knowledge adopters have to remember at fork time. The seed's discipline is "make scaffolding explicit"; an explicit `meta/` directory beats an implicit cleanup step.
- **F. Branch-based separation** (the seed's history lives on a `seed-meta` branch). Rejected: too clever; *Use this template* doesn't copy non-default branches, so adopters lose the reference entirely; reading the meta requires switching branches.
- **G. Move ADRs to `meta/decisions/` but leave `CHANGELOG.md` at root** (adopter would strip CHANGELOG content manually on fork). Rejected as inconsistent: both files document the seed's evolution and the same strip/keep logic applies to both; treating them differently is arbitrary.

## Related

- The five moved ADRs (ADR-0001 through ADR-0005) are unchanged in content; only their location and cross-reference paths changed.
- This ADR is itself the first seed-meta artifact written *into* `meta/decisions/` rather than into `docs/decisions/`. Self-applies the decision.
