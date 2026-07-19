# ADR-0012 — Known-bug lifecycle: two mechanisms, presented as options

## Status

Accepted — 2026-07-19. Implements item 4 of the Tier-1 backport set
([#35](https://github.com/pdlourenco/disciplined-project-seed/issues/35));
decided in
[`meta/analyses/2026-07-17-ppqq-adigator-tombo-sid-backport-analysis.md`](../analyses/2026-07-17-ppqq-adigator-tombo-sid-backport-analysis.md)
§3, §5, §6, §9. Supersedes the earlier two-adopter decision, which
prescribed the xfail mechanism alone.

## Context

A documented-but-unfixed bug needs a tracking artifact wired to the test
surface, or "known" quietly becomes "forgotten". The studied adopters solved
this in two **incompatible** ways, each deliberately:

- One adopter built the **self-healing xfail lifecycle**: a tagged test
  detects the buggy outcome and skips, otherwise asserts — a regression
  guard that arms itself the moment the bug is fixed. Its own caveat is on
  record: a stale tag downgrades the guard (a re-introduced regression
  reports as *filtered*, not *failed*), so tag removal is part of the fix
  and a stale-tag detector is the residual debt.
- Two adopters landed on **visible-debt markers + register** — a marker in
  SPEC (`Verified by: none` in the closed-vocabulary form) plus an entry in
  a tracking register — with one of them *deliberately rejecting* a forced
  same-PR test gate; its independent review notes "no skip/xfail anywhere".
  The residual debt is annotation honesty (the over-claiming `Verified by:`
  failure, documented at another adopter).

The original two-adopter backport decision prescribed xfail alone; the
third adopter's documented rejection of exactly that mechanism showed the
seed would have been imposing one test culture on another.

## Decision

`docs/CONTRIBUTING.md` §"Known-bug lifecycle" presents **both** mechanisms
with their residual debts, unranked — adopters pick one per project and
state the choice. The common core is mandatory either way and lands as a PR
checklist row: **a bug fix closes its known-bug tracking artifact (tag, or
marker + register entry) in the same PR.**

## Consequences

- Adopters with strong test-harness cultures get the self-arming regression
  guard; adopters that reject forced same-PR tests get an honest-debt
  ledger. Neither is penalized by seed doctrine.
- The common core still gives reviewers one universal check ("does this fix
  close its tracking artifact?") regardless of mechanism.
- Presenting options costs prescriptive force: a fresh adopter must make
  one more choice. The section is explicit that the choice is per-project
  and should be stated in the adopted CONTRIBUTING.
- Adopter count at decision time was 1 (xfail) vs 2 (marker + register);
  recorded here so a future revisit can see whether the split held.
  Revisit if either mechanism accumulates documented failures the other
  avoids.

## Alternatives considered

- **Prescribe self-healing xfail alone** (the original two-adopter
  decision). Rejected: a scaled adopter deliberately rejected forced
  same-PR test gates for found debt, with reasoning on record — the
  mechanism encodes a test culture, not a universal best practice.
- **Prescribe visible-debt markers alone.** Rejected symmetrically: the
  xfail lifecycle's self-arming regression guard is a real property the
  marker form lacks, and the adopter running it has substantial scale
  evidence behind it (29 ADRs, a spec-first CI plan).
- **Rank one as default, other as exception.** Rejected: with a 1-vs-2
  split and both sides' reasoning documented, a ranking would be the seed
  picking a side the evidence doesn't pick. Recommend-don't-decide applies
  to the seed's own conventions too.
- **Say nothing (each adopter invents their own).** Rejected: both
  residual-debt caveats (stale tags; dishonest annotations) were paid for
  downstream — shipping the mechanisms without the caveats invites the
  same failures again.
