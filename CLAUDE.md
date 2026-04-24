# CLAUDE.md — Agent operating rules

Binding rules for Claude (and any other coding agent) working on this repo.

<!-- ACTIVATION: when do these rules become binding?

     Options:
     - "from day one"
     - "once the contracts in docs/SPEC.md are stable"
     - "from Phase N onward"

     Default, if you're unsure: active from the first PR that touches
     production code. -->

Source-of-truth documents are linked inline; this file is a short index, not a replacement for them.

## 1. Follow `docs/CONTRIBUTING.md`

`docs/CONTRIBUTING.md` is authoritative for CI strategy, contract enforcement, ADR conventions, commit and branch naming, warning policy, and the workflow for changing a contract in `docs/SPEC.md`. Read it before opening a PR. Deviations require an explicit note in the PR description and, if the deviation is structural, an ADR.

## 2. Pre-push self-review is mandatory

Before **every** `git push` on a PR branch, launch a reviewer subagent on the local diff using the prompt in `docs/CONTRIBUTING.md` §"Pre-push self-review (agent convention)". Seed the subagent with `docs/REVIEW_CONTEXT.md` (project principles and red flags) alongside `docs/DESIGN.md` / `docs/SPEC.md` / `docs/ROADMAP.md` so it reviews against what the project actually cares about, not surface-level lint. Act on findings before pushing; record the outcome in the PR description (`pre-push review: no findings` or `pre-push review flagged X, fixed in <sha>`).

Rationale and the narrow exceptions (one-line typo, formatting-only, pure revert) are in <!-- link to the ADR that established this convention; e.g. docs/decisions/ADR-NNNN-pre-push-self-review.md -->.

## 3. Implementation is bound to `docs/SPEC.md` as a contract

`docs/SPEC.md` defines the external contracts — <!-- describe the boundaries: cross-language, cross-process, cross-module, whichever applies -->. Implementations must match the spec; the spec must match the implementations. Concretely:

- If you need to change a contract, update `docs/SPEC.md` **first**, then update every implementation side in the same PR. Follow the checklist in `docs/CONTRIBUTING.md` §"When you change a contract in `docs/SPEC.md`".
- The contract-consistency gates in CI — <!-- name them, e.g. test_spec_consistency.py, test_version_pinning.py, the Integration job --> — are not optional. Do not bypass them; do not weaken them to make a PR green.
- If the spec and the implementation drift and you cannot tell which is correct, stop and ask — do not pick a side unilaterally.

<!-- If your project has only one implementation and no cross-boundary
     contracts, §3 can collapse to a single-sentence pointer at SPEC.md. -->

## 4. Discuss major decisions before deciding; ADR if it sticks

A "major decision" is anything that:

- changes a contract in `docs/SPEC.md`, `docs/DESIGN.md`, `docs/ROADMAP.md`, or <!-- any other source-of-truth artifact, e.g. docs/schema.toml -->;
- introduces a new external dependency, a new process boundary, or a new on-disk artifact;
- locks in a trade-off a future PR could reasonably want to revisit (thresholds, fallback ordering, error-handling policy, schema seams);
- materially changes the scope or shape of the phase being worked on.

For any of the above:

1. **Pause and surface the decision** — describe the choice, the alternatives, and the trade-off in the conversation. Wait for an explicit go-ahead before implementing.
2. **If the decision is accepted and non-obvious, write an ADR** in `docs/decisions/` following the convention in `docs/decisions/README.md`. Link the ADR from the PR description.
3. **Tactical and mechanical choices do not need this** — formatter settings, import ordering, internal naming, obvious refactors. When in doubt, ask; the cost of a question is lower than the cost of an unwanted commit.
