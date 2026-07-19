# ADR-0010 — `analyses/` as a first-class optional doc type

## Status

Accepted — 2026-07-19. Implements item 1 of the Tier-1 backport set
([#35](https://github.com/pdlourenco/disciplined-project-seed/issues/35));
decided in
[`meta/analyses/2026-07-17-ppqq-adigator-tombo-sid-backport-analysis.md`](../analyses/2026-07-17-ppqq-adigator-tombo-sid-backport-analysis.md)
§8–§9.

## Context

All four studied adopters independently created an analyses folder
(`docs/analyses/` in three, `docs/analysis/` in one) for artifacts that fit
none of the seed's doc types: dated repo-wide reviews, field reports,
adoption studies, canonical registers. One adopter (sid) produced a textbook
instance — dated filename, commit-anchored, severity-graded findings spun
out to twelve issues — *before* adopting any convention, and outside its
adoption epic: independent convergence. A fourth-way convergence is the
strongest demand signal the seed has recorded for any candidate convention.

The gap is real: an analysis is neither a decision (ADRs record what was
chosen) nor a living document (SPEC/DESIGN are maintained to stay true).
Without a stated convention, each adopter re-derives the rules — and the
observed failure mode of unmaintained prose (analysis §7.2: docs that
restate reality drift within one or two contract versions) threatens any
folder of point-in-time documents that pretends to stay current.

One adopter (tombo) had already written the convention down as a four-rule
README; the backport decision names it the base text.

## Decision

Ship [`docs/analyses/README.md`](../../docs/analyses/README.md): an
**optional** doc type with four rules (dated filename; anchored to a commit;
immutable once merged — supersede, don't edit; not a contract) and three
usage models (dated snapshot series; clearly-marked canonical registers as
the deliberate exception to immutability; periodic independent review →
issues → remediation loop). The seed dogfoods the convention on itself as
`meta/analyses/`. Folder name settled as `analyses` (plural) by the
maintainer.

## Consequences

- Analysis-shaped artifacts get a sanctioned home instead of landing in
  `DESIGN.md` (where they'd rot) or staying unwritten.
- The immutability-plus-pointers rule makes the folder rot-proof by
  construction: a document that declares its snapshot date and points at
  live surfaces cannot be *wrong later*, only *historical*.
- One more optional surface for adopters to consider; the README's "add the
  folder when the first analysis is written" rule keeps empty scaffolding
  out of fresh adoptions.
- The canonical-register variant deliberately punches a hole in rule 3;
  the marking requirement ("registers, not snapshots, say so at the top")
  is the guard. If marked registers still get confused with snapshots,
  revisit by splitting registers into their own convention.

## Alternatives considered

- **Leave it ad hoc (do nothing).** Rejected: four adopters independently
  built the same thing — the demand is proven, and without shared rules the
  variants diverge on exactly the load-bearing points (immutability,
  anchoring) that keep such folders from rotting.
- **Maintained analyses (edit findings as they're fixed).** Rejected: this
  recreates the documented prose-rot failure mode (analysis §7.2). The
  follow-up tracker is the live surface; the document is the narrative.
- **Fold into `decisions/` as a long-form ADR variant.** Rejected: analyses
  aren't decisions — most contain findings and observations with no
  chosen-alternative structure, and stretching the ADR format to fit them
  would weaken both conventions.
- **Make the folder a required part of the seed.** Rejected: the seed's
  scaling rule is "drop files, not rules" — a project that never writes
  analyses should not carry an empty folder. Optional, added on first use.
