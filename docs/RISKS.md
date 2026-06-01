# [PROJECT] — Risks (optional)

<!-- **Skip this document** unless your project ships under regulated
     obligations (safety, finance, healthcare, automotive, aerospace, …),
     targets hard-reliability constraints, or has identified failure
     modes with non-negligible blast radius. For solo / low-stakes /
     iterative software, the deferred-with-conditions pattern in
     `SPEC.md §Deferred`, `CONTRIBUTING.md §"CI strategy"` (tier 4),
     `DESIGN.md §"Future extensions"`, and each phase plan's "Follow-
     ups" carries the same discipline at lower overhead.

     If you're keeping this file: delete this comment block once the
     team understands the convention. If you're stripping it: just
     delete the file; nothing else in the seed depends on it. -->

**Purpose.** Make known risks visible, sized, and revisitable — so that *"we'll deal with it"* doesn't become *"we forgot it existed."* Same shape as the deferred-with-conditions lists used throughout this project's docs; applied at the risk level rather than the work-item level.

This document is one of the right-side mechanisms in the V-cycle-shaped discipline described in [`REVIEW_CONTEXT.md` §"Verification vs validation"](REVIEW_CONTEXT.md) — it captures *what could go wrong*, in a form that names mitigation and revisit triggers explicitly. Decisions taken in response to risks live in [`decisions/`](decisions/) as ADRs; this file is the risk register itself.

## Format

Each risk is one entry with six fields. Keep entries terse; the discipline is in completing every field, not in length.

| Field | What it captures |
|---|---|
| **Risk** | One sentence. A specific failure mode and what triggers it. Not *"the system might fail"*. |
| **Probability** | Low / Medium / High, with a horizon (*"per release", "within the first 1000 users"*). |
| **Impact** | Low / Medium / High, with an axis (money / users / data / reputation / legal). |
| **Mitigation** | The concrete action that reduces probability or impact. *"Be careful"* isn't a mitigation. |
| **Residual** | What's left after the mitigation, and whether it's acceptable. Honest. *"None"* is a yellow flag. |
| **Revisit trigger** | Same shape as deferred-with-conditions: when does this entry need re-examination? Calendar (*"quarterly"*), event (*"on first paying customer"*), or threshold (*"when latency p99 exceeds X"*). |

## Risks

<!-- Replace the example below with your project's actual risks. The
     example is intentionally not domain-specific — it's a shape, not
     a list of things to copy. -->

### Risk: <!-- One-sentence failure mode -->

- **Probability:** <!-- L / M / H + horizon -->
- **Impact:** <!-- L / M / H + axis -->
- **Mitigation:** <!-- concrete action -->
- **Residual:** <!-- what's left; whether acceptable; why -->
- **Revisit trigger:** <!-- when this entry gets re-examined -->
- **Related:** <!-- optional: ADR-NNNN, PR #NN, issue #NN -->

### Risk: <!-- One-sentence failure mode -->

- **Probability:**
- **Impact:**
- **Mitigation:**
- **Residual:**
- **Revisit trigger:**
- **Related:**

## Discipline

- **Add when discovered**, not when realised. The register surfaces *possible* failure modes, not just past ones.
- **Prune when retired.** A mitigation that's been in place long enough without incident may justify dropping the entry — or it may not. Judgment call; record the reasoning when dropping.
- **Honest residuals.** *"None"* is rare and usually wrong; *"acceptable because X"* is the right shape.
- **Tie to ADRs when applicable.** A risk that motivated an architectural choice should reference its ADR; an ADR that names a risk should reference this file's entry. Cross-linking keeps the *why* and the *what* in sync.
- **Major changes to the register are major decisions** per [`../CLAUDE.md`](../CLAUDE.md) §4 — adding, retiring, or materially re-sizing a risk affects the project's risk posture.

## See also

- [`CONTRIBUTING.md` §"CI strategy"](CONTRIBUTING.md) — tier 4 *"Deferred (not yet wired)"* carries the same revisit-trigger shape at the CI gate level.
- [`SPEC.md` §"Deferred to post-[VERSION]"](SPEC.md) — contract-level deferral with the same shape.
- [`decisions/README.md`](decisions/README.md) — ADRs capture the *decisions* taken in response to risks; this file captures the risks themselves.
- [`REVIEW_CONTEXT.md` §"Verification vs validation"](REVIEW_CONTEXT.md) — the V-cycle framing that names this document as a right-side mechanism.
