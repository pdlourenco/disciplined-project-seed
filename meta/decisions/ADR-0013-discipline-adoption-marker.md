# ADR-0013 — `DISCIPLINE_ADOPTION.md`: adoption / sync marker

## Status

Accepted — 2026-07-19. Implements item 8 of the Tier-1 backport set
([#35](https://github.com/pdlourenco/disciplined-project-seed/issues/35));
decided in
[`meta/analyses/2026-07-17-ppqq-adigator-tombo-sid-backport-analysis.md`](../analyses/2026-07-17-ppqq-adigator-tombo-sid-backport-analysis.md)
§5, §6, §9. Maintainer-originated (PR #37 review).

## Context

The seed is a living template: fixes and conventions flow down to adopters,
and adopter inventions flow back up. Both directions need to know **what an
adopter took, adapted, or dropped, and at which seed version** — and the
studied adopters showed the cost of not recording it:

- The motivating counterexample (tombo): provenance distributed per-ADR
  ("back-ported from the seed's meta ADR-N"), but **no seed-version pin, no
  sync log, no per-artifact table** — reconstructing its sync state for the
  backport study was expensive precisely because the record was scattered.
- The live counterpoint (sid): an equivalent record kept *without* a marker
  file — per-artifact table and deferrals in a pinned epic issue, seed
  attribution in CLAUDE.md, a retroactive ADR for the pre-existing
  principle, and a sync log in a backport-PR body citing exact seed
  commits. Proof the record matters more than the container.
- The maintainer's naming review on PR #37: the marker is named for the
  **discipline being adopted**, not the seed artifact (`DISCIPLINE_ADOPTION.md`,
  not `SEED_ADOPTION.md`).

## Decision

Ship a root-level [`DISCIPLINE_ADOPTION.md`](../../DISCIPLINE_ADOPTION.md)
template: seed provenance (repo URL + pinned `vX.Y.Z (sha)` + date +
profile), a per-artifact adoption table (`adopted` / `adapted (where)` /
`dropped (why/ADR)`), an append-only sync log (date + seed ref range +
taken / skipped-with-reasons), and an optional backport log. The committed
file is the **default**; a pinned tracking issue with the same content is
an allowed alternative for issue-centric repos. Referenced from the README
adoption steps and the small-scale profile guidance.

Two optional companions (maintainer-suggested, PR #37 review):
an **adoption-display sentence** — a one-line pointer in the adopter's
README/CONTRIBUTING; purely optional, the marker stays the record — and
**upstream backport-suggestion issues**, encouraged as the flow-up channel
and tracked in the marker's backport log.

Supporting change: the seed starts **cutting a git tag at each
`meta/CHANGELOG.md` version** (first tag: the version this Tier-1 series
ships as), so pinned `vX.Y.Z (sha)` references resolve and a flow-down pass
is "read the seed CHANGELOG between two pinned versions".

## Consequences

- Both flow directions get mechanical: flow-down is a CHANGELOG diff
  between two pins triaged against the table; flow-up (backport studies
  like the one that produced this ADR) reads one file instead of
  reconstructing scattered provenance.
- Adopters pay a small ongoing cost: a sync-log row per flow-down pass and
  an honest table row per dropped artifact. The template makes "dropped,
  with reason" an explicitly good outcome so the cost isn't inflated by
  guilt.
- The issue-based allowance means tooling can't assume the file exists;
  anything that automates against the marker must handle the pinned-issue
  form or degrade gracefully.
- The seed takes on a release-hygiene obligation (tags at CHANGELOG
  versions) it did not previously have.

## Alternatives considered

- **`SEED_ADOPTION.md` (original name).** Rejected in maintainer review:
  what gets adopted is the discipline, not the seed; the name should
  survive even if the template repo is renamed or forked.
- **Per-ADR distributed provenance (tombo's organic form).** Rejected as
  the recommended form by direct evidence: it's the shape whose sync state
  was expensive to reconstruct — no version pin, no single place to diff
  from.
- **Issue-based record as the default** (sid's form). Rejected as
  *default* but explicitly **allowed**: the pinned-issue form worked, but
  a committed file is in-repo, diffable, reviewable in PRs, and survives a
  tracker migration. Issue-centric repos may still choose it; the record's
  content is the requirement, not the container.
- **Central registry in the seed repo** (seed tracks its adopters).
  Rejected: inverts ownership — adopters own their adoption records; the
  seed can't know about private forks and shouldn't gate on registration.
- **Do nothing.** Rejected: the backport study that motivated this ADR
  spent most of its reconstruction cost on exactly the information this
  file records.
