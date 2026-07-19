# ADR-0007 — V-cycle-shaped additions to the right side: V&V split, per-rule verified-by, optional RISKS.md

## Status

Accepted — 2026-06-01. Revised — 2026-07-19: the requirements traceability matrix, rejected below as part of full ECSS adoption (Alternative D), now ships as an explicitly **optional** SPEC section for regulated / V&V-heavy domains (`docs/SPEC.md` §"Traceability matrix"), pulled forward from the Tier-2 backport set ([#36](https://github.com/pdlourenco/disciplined-project-seed/issues/36)) by maintainer decision after an adopter independently invented the same model. The rejection of *mandatory* ECSS-grade ceremony stands, as does the stable-SPEC-IDs deferral (they become the matrix's prerequisite when a project opts in).

## Context

The seed's discipline already has a left-right asymmetry: SPEC / DESIGN / ROADMAP / phase plans on the left capture *what*; contract-consistency tests, PR gates, the reviewer subagent, and the four-tier CI on the right verify *built right*. The left side is well-developed; the right side is informally distributed and weaker.

V-cycle / ECSS-style engineering ([V-model](https://en.wikipedia.org/wiki/V-model) on Wikipedia for the canonical engineering-lifecycle reference) names this asymmetry: every left-side commitment has a corresponding right-side mechanism that checks it. The seed already has the *shape* (contract → contract-consistency test; principle → reviewer-subagent finding; success criteria → per-PR gates), just without the framing or naming.

Three weak points on the current right side, surfaced in conversation:

1. **The reviewer prompt conflates verification and validation.** *"Does this match the spec?"* (verification) and *"does this match the principles we actually care about?"* (validation) are different operations. Bundling them produces less rigour at each.
2. **SPEC rules have no enforcement-mechanism field.** A binding rule with no named verification mechanism is a hope, not a contract. The author may have intended a specific test, but there's nothing in SPEC that says so — reviewers can't see what's covered and what isn't.
3. **No risk register.** Some adopter domains (regulated, life-safety, hard-reliability) need an explicit, revisitable list of known failure modes. The seed's deferred-with-conditions pattern works at the work-item level; the same shape applied to risks is a one-page addition for adopters who need it.

This ADR adopts lightweight elements of the V-cycle frame without importing ECSS-grade overhead (formal V&V plans, qualification documents, requirements traceability matrices). The lineage is acknowledged briefly in `REVIEW_CONTEXT.md` so engineers from regulated backgrounds have a familiar handhold without overclaiming.

## Decision

Three coordinated changes plus a framing paragraph:

1. **Verification vs validation distinction in `REVIEW_CONTEXT.md`** — a new section names the two review modes the reviewer agent can be invoked in. The default reviewer prompt in `CONTRIBUTING.md` covers both, but agents can be asked for one specifically. Tighter findings, lower token cost.
2. **Per-rule "Verified by:" annotation convention in `SPEC.md`** — each binding rule gets a sub-bullet naming the mechanism that gates it (specific test file, integration job, manual inspection, or ADR-driven review when only judgment can enforce). Documented in SPEC's positioning header; applied to the existing rule template in §3 Critical rules as the demonstration shape. A rule with `Verified by: <!-- nothing -->` is visible debt reviewers can flag.
3. **Optional `docs/RISKS.md` template** — same deferred-with-conditions shape applied at the risk level: Risk → Probability × Impact → Mitigation → Residual → Revisit trigger. Header explicitly says "skip unless regulated / life-safety / hard-reliability"; the file is delete-if-not-needed scaffolding, not a required artifact. The seed's first explicitly-optional document.
4. **V-cycle / ECSS lineage paragraph in `REVIEW_CONTEXT.md`** — one paragraph acknowledging the frame and explicitly disclaiming the heavyweight ceremony.

## Consequences

- **The reviewer agent's invocation gets sharper.** *"Review in verification mode"* and *"review in validation mode"* produce tighter outputs than the bundled prompt; the default (both modes) stays for the common case where token cost isn't the bottleneck.
- **SPEC rules become enforceability-visible.** Authors of new rules confront the verification question at write time. Reviewers see which rules are gated by tests, which by integration, which only by ADR-driven judgment — and which have nothing at all.
- **Adopters in regulated domains have a ready scaffold.** RISKS.md is the first explicitly-optional document the seed ships; the same "skip unless X" header convention can apply to other domain-specific docs later (compliance checklists, threat models, …).
- **No new external dependencies, no new on-disk artifacts beyond RISKS.md and this ADR.** The other three changes are prose conventions inside existing files.
- **The right-side framing is explicit.** Adopters from waterfall / regulated backgrounds get a familiar handhold; adopters from continuous-delivery backgrounds aren't burdened with vocabulary they don't need (the V-cycle paragraph is a single paragraph in REVIEW_CONTEXT.md, not a separate doc).

## Alternatives considered

- **A — adopt all five suggestions** (V&V split + verified-by + stable SPEC IDs + multi-doc versioning + RISKS.md). Rejected: stable SPEC IDs and multi-doc versioning add overhead without proportional value for most adopters. The chosen three carry the same V-cycle discipline at lower cost.
- **B — adopt none; keep the current informal discipline.** Rejected: the reviewer-prompt conflation is a real loss of rigour, the unenforceable-rule problem in SPEC is real, and the RISKS-shaped need exists for some adopter domains. Cost of inaction exceeds cost of the three.
- **C — chosen path: V&V split + verified-by + optional RISKS + lineage paragraph.** Three lightweight conventions plus one new template; no new dependencies; preserves the seed's "make scaffolding explicit" discipline.
- **D — full ECSS adoption** (V&V plans, qualification documents, requirements traceability matrices, configuration audits). Rejected outright: the seed's audience is broader than regulated engineering; ECSS-grade ceremony would make the seed unusable for the majority case.
- **Stable SPEC IDs (suggestion #3 from the conversation) — deferred.** Revisit when SPEC grows past ~10–15 binding rules, or when cross-references to specific rules from ADRs / phase plans / code comments become common enough that "SPEC §3 (the rule about IDs)" turns awkward. An optional pattern is noted in SPEC's positioning header for adopters whose SPECs already need it.
- **Multi-doc versioning (suggestion #4) — deferred.** Revisit when the project starts shipping documented baselines (this binary built against DESIGN v0.3) — typical for regulated or hardware-coupled work. For continuously-evolving software where every commit is a new baseline, the version numbers become noise without proportional return.
- **Make RISKS.md required, not optional.** Rejected: the document earns its keep in a narrow slice of adopter domains; requiring it everywhere is the kind of imposition that erodes adoption of the seed's broader discipline. The "skip unless X" header convention is the right shape.
- **Include a worked example of a complete `Verified by:` reference in SPEC.md.** Considered. The seed's SPEC is entirely template placeholders; a worked example would invent test-file names that don't exist. The convention is documented in the header; concrete examples land in adopter SPECs.
