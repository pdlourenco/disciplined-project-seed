# ADR-0011 — Contract-gate pattern catalogue + drift-hardening doctrine

## Status

Accepted — 2026-07-19. Implements item 2 of the Tier-1 backport set
([#35](https://github.com/pdlourenco/disciplined-project-seed/issues/35));
decided in
[`meta/analyses/2026-07-17-ppqq-adigator-tombo-sid-backport-analysis.md`](../analyses/2026-07-17-ppqq-adigator-tombo-sid-backport-analysis.md)
§4–§7, §9.

## Context

The seed's tier-1 guidance named four contract-enforcement patterns. Three
adopters running contract gates at scale accumulated both a much richer
catalogue and — more valuable — documented failures of the naive forms:

- One adopter's "ADR-0021 series" (five entries deep) distilled a doctrine
  from repeated drift incidents: outcome tests that two idioms both pass do
  not hold a mandate; only structural gates do.
- A polyglot adopter shipped the strongest counter-doctrine evidence: its
  cross-language reference vectors held for the project's life, yet a bug in
  a shared generator produced a stored reference that doesn't match
  production — cross-validation cannot see joint drift. Four orphan
  reference files were consumed by no test; no artifact carried generator
  metadata ("staleness is undetectable from file contents"); a zero
  tolerance floor made the gate flaky across environments.
- A second polyglot adopter's review found a gate verifying a test-oriented
  reimplementation rather than the production function, and a `Verified by:`
  annotation claiming coverage of "every validation rule above" while ~10
  rules had zero tests — "flatly false".
- Two adopters independently reproduced the same prose failure: gates
  protected the tables they parse while design docs *restating* those
  catalogues fell one to two contract versions behind.

## Decision

Extend `docs/CONTRIBUTING.md` §"CI strategy" §1 with a rendered
**contract-gate pattern catalogue** (spec-prose parsing, codegen-diff,
set-for-set enrollment, totality-over-enum, metadata-derived cross-check,
structural lint, version-pinning, integration probe, shared contract
artifact), the two caveats (gate the production idiom; cross-check
`Verified by:` claims — closed value vocabulary as the worked option), the
machine-shared-artifact hardening requirement (generator-provenance
metadata + absolute tolerance floor + no orphan artifacts), and the
three-line **drift-hardening doctrine**. Add the paired prose-refresh step
to §"When you change a contract in `docs/SPEC.md`". Patterns only —
contents stay downstream.

## Consequences

- Adopters designing tier-1 gates start from nine proven shapes instead of
  four sketches, with the failure modes attached to the patterns that
  invite them.
- The doctrine gives reviews citable ground: "this is an outcome test two
  idioms pass" is now a named finding, not an intuition.
- The contract-change checklist grows a step; contract PRs get slightly
  heavier in exchange for closing the documented prose-drift gap.
- The catalogue is rendered text in a template section, so it ships into
  adopted CONTRIBUTINGs verbatim — it must stay pattern-level; anything
  domain-specific added here would be wrong in every downstream copy.
- The shared-contract-artifact pattern is stated as *preferred where
  feasible* over mirror-plus-equality-test — a ranking, deliberately, since
  the rejecting adopter documented concrete grounds ("catches drift after
  it's pushed; dies when one language is retired").

## Alternatives considered

- **Keep the catalogue in the guidance comment (invisible when rendered).**
  Rejected: the previous four patterns lived in an HTML comment and were
  guidance for filling in the section; a nine-pattern catalogue with
  caveats and doctrine is reference material adopters should keep, not
  scaffolding they replace. Comments get deleted on adoption; rendered text
  survives.
- **Put the doctrine in `REVIEW_CONTEXT.md` instead.** Rejected:
  REVIEW_CONTEXT's principles section is adopter fill-in territory (the
  seed ships it as a template), and the doctrine is inseparable from the
  catalogue it governs. CONTRIBUTING §CI strategy owns gate design;
  reviewers reach it from there.
- **Ship the catalogue as a separate `docs/design/` note.** Rejected: it
  would split tier-1 guidance across two files and the CI-strategy section
  would restate it — exactly the prose-restating failure the doctrine
  forbids.
- **Do nothing.** Rejected: three adopters paid for these lessons with
  documented incidents; not recording them upstream guarantees the next
  adopter re-derives them the same way.
