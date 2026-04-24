# ADR-NNNN — <!-- short decision title -->

<!-- FILENAME CONVENTION: ADR-NNNN-kebab-case-title.md, where NNNN is a
     zero-padded sequence number. See decisions/README.md for
     numbering rules. -->

## Status

<!-- One of: Proposed | Accepted | Rejected | Superseded by ADR-NNNN |
     Deprecated. Date the status change. For Accepted records,
     optionally note where the decision was implemented.

     Examples:

     - "Accepted — 2026-04-15. Implemented in PR #NN."
     - "Proposed — 2026-04-15."
     - "Superseded by ADR-0021 — 2026-06-02. -->

<!-- Status line --> — <!-- YYYY-MM-DD -->.

## Context

<!-- What's the situation that forced this decision? The test of a
     well-written Context section is that someone reading it six
     months later can understand WHY this decision was even being
     made, without having to chase down separate threads.

     Strongly prefer CONCRETE EVIDENCE over abstract argument.
     Bugs that happened, surveys that returned these numbers, PRs
     that broke this way, benchmarks that showed this. Abstract
     "we should do X because good engineering" ages badly. Concrete
     "PR #N cost two hours to debug because..." ages well.

     A good Context section usually lists:

     - The problem or forcing function (what changed to require a
       decision now?)
     - 2-3 concrete instances or data points that motivate it
     - The options the authors are considering, in brief -->

<!-- PROBLEM / FORCING FUNCTION -->

<!-- Concrete evidence:

     - <event, with enough detail to verify>
     - <event>
     - <event> -->

<!-- OPTIONS (brief — detail lives in "Alternatives considered" below):

     - **Option A.** <one-sentence shape>
     - **Option B.** <one-sentence shape>
     - **Option C.** <one-sentence shape> -->

## Decision

<!-- What we're doing. Terse — usually 1-3 sentences. If the decision
     needs paragraphs to state, you're probably conflating the
     decision with its justification; the justification belongs in
     Context and Consequences.

     Where appropriate, link to a PR, doc, or section that embodies
     the decision operationally.

     Example:

         Pre-push self-review. The originating agent runs a reviewer
         subagent on the local diff before every push on a PR branch
         (with narrow exceptions). Full convention in
         docs/CONTRIBUTING.md. -->

## Consequences

<!-- What this decision means going forward. Both positive and
     negative; reviewers should be able to see the trade-off at a
     glance.

     Mix of:

     - What gets easier / cheaper / faster
     - What gets harder / more expensive / slower
     - What new constraints or obligations this creates
     - What future decisions this leaves open (or closes off)

     Optional: a short "revisit conditions" note if the decision has
     known expiry criteria. Example: "Revisit if more than N% of PRs
     ship bugs that this gate should have caught." -->

- <!-- positive consequence -->
- <!-- negative consequence -->
- <!-- constraint or obligation -->
- <!-- future doors this leaves open or closes -->

## Alternatives considered

<!-- REQUIRED, NOT OPTIONAL. An ADR without "Alternatives considered"
     is the single biggest failure mode of the format. Six months
     later, someone WILL want to know why the rejected option was
     rejected — and if the answer isn't here, they'll either re-derive
     it (slow) or assume it was never considered (worse).

     For each alternative: name it, describe it in one or two
     sentences, say why it was rejected with enough specificity that
     a reader can evaluate the reasoning. If the reason is "we'd
     revisit if X", say so. -->

- **<!-- Alternative 1 -->.** <!-- Shape in one or two sentences. Why rejected. Revisit criteria if any. -->
- **<!-- Alternative 2 -->.** <!-- Shape in one or two sentences. Why rejected. Revisit criteria if any. -->
- **<!-- Doing nothing -->.** <!-- Usually worth stating explicitly, even when obvious. "Doing nothing was rejected because [concrete evidence from Context above] shows the cost of doing nothing is [X]." -->
