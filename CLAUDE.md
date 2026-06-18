# CLAUDE.md — Agent operating rules

Binding rules for Claude (and any other coding agent) working on this repo.

<!-- ACTIVATION: when do these rules become binding?

     Options:
     - "from day one"
     - "once the contracts in docs/SPEC.md are stable"
     - "from Phase N onward"
     - "active from day one, but a specific gate (e.g. the spec-as-contract
       check in §3) is a no-op until the implementation it guards lands
       (Phase 1+)" — binds the workflow rules immediately while honestly
       deferring the gates that have nothing to check yet

     Default, if you're unsure: active from the first PR that touches
     production code. -->

Source-of-truth documents are linked inline; this file is a short index, not a replacement for them.

## 1. Follow `docs/CONTRIBUTING.md`

`docs/CONTRIBUTING.md` is authoritative for CI strategy, contract enforcement, ADR conventions, commit and branch naming, warning policy, and the workflow for changing a contract in `docs/SPEC.md`. Read it before opening a PR. Deviations require an explicit note in the PR description and, if the deviation is structural, an ADR.

## 2. Pre-push self-review is mandatory

Before **every** `git push` on a PR branch, launch a reviewer subagent on the local diff using the prompt in `docs/CONTRIBUTING.md` §"Pre-push self-review (agent convention)". Seed the subagent with `docs/REVIEW_CONTEXT.md` (project principles and red flags) alongside `docs/DESIGN.md` / `docs/SPEC.md` / `docs/ROADMAP.md` so it reviews against what the project actually cares about, not surface-level lint. Act on findings before pushing; record the outcome in the PR description (`pre-push review: no findings` or `pre-push review flagged X, fixed in <sha>`).

The narrow exceptions — one-line typo, formatting-only, pure revert — and the rationale for pre-push (vs CI) are in `docs/CONTRIBUTING.md` §"Pre-push self-review".

## 3. Implementation is bound to `docs/SPEC.md` as a contract

`docs/SPEC.md` defines the external contracts that cross module, process, or language boundaries. Implementations must match the spec; the spec must match the implementations. Concretely:

- If you need to change a contract, update `docs/SPEC.md` **first**, then update every implementation side in the same PR. Follow the checklist in `docs/CONTRIBUTING.md` §"When you change a contract in `docs/SPEC.md`".
- The contract-consistency gates in CI are not optional. Do not bypass them; do not weaken them to make a PR green.
- If the spec and the implementation drift and you cannot tell which is correct, stop and ask — do not pick a side unilaterally.

<!-- If your project has only one implementation and no cross-boundary
     contracts, §3 can collapse to a single-sentence pointer at SPEC.md. -->

## 4. Discuss major decisions before deciding; ADR if it sticks

A "major decision" is anything that:

- changes a contract in `docs/SPEC.md`, `docs/DESIGN.md`, `docs/ROADMAP.md`, a per-topic rationale file under `docs/design/*.md`, `docs/REVIEW_CONTEXT.md` (whose principles are load-bearing for every review), `docs/LABELS.md` (whose taxonomy is load-bearing for issue / PR hygiene), or <!-- any other source-of-truth artifact, e.g. docs/schema.toml -->;
- introduces a new external dependency, a new process boundary, or a new on-disk artifact;
- locks in a trade-off a future PR could reasonably want to revisit (thresholds, fallback ordering, error-handling policy, schema seams);
- materially changes the scope or shape of the phase being worked on.

For any of the above:

1. **Pause and surface the decision** — describe the choice, the alternatives, and the trade-off in the conversation. Wait for an explicit go-ahead before implementing. **Recommend, don't decide:** lay out the possibilities and mark the one you'd choose with a one-line why, then let the maintainer choose. This recommend-don't-decide posture applies to *every* question you put to the maintainer — including `AskUserQuestion` prompts, not only §4 decisions.
2. **If the decision is accepted and non-obvious, write an ADR** in `docs/decisions/` following the convention in `docs/decisions/README.md`. Link the ADR from the PR description.
3. **Tactical and mechanical choices do not need this** — formatter settings, import ordering, internal naming, obvious refactors. When in doubt, ask; the cost of a question is lower than the cost of an unwanted commit.

## 5. Opening a PR is free for planned work; merging needs approval

Opening a PR for work that implements an already-approved item in a phase / subphase plan (`docs/plans/PHASE-*.md` §"PR sequence") does **not** need separate approval — open it once the work is ready and the §2 pre-push self-review (plus the local CI run, once CI exists) pass. Work that is **not** part of an approved plan follows §4 — surface it and wait for the go-ahead before opening the PR.

**Merging always requires explicit maintainer approval.** Never merge on your own initiative, not even a green PR. A §4 major decision discovered *mid-implementation* is still surfaced, even though opening the PR itself was pre-authorized.

The full loop lives in `docs/CONTRIBUTING.md` §"Two-session authoring / review workflow". Note this is repo *policy*: the binding per-session authorization still comes from how the session is launched, so the standing grant must be given there too — the repo doc does not override a session instruction.
