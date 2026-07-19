# Phase N — <!-- Phase title -->

**Status:** Draft plan. Decisions captured here are proposals; binding contracts live in [`docs/SPEC.md`](../SPEC.md), [`docs/DESIGN.md`](../DESIGN.md), and [`docs/decisions/`](../decisions/). This document is a phase-scoped narrative; the terse per-phase summary stays in [`docs/ROADMAP.md`](../ROADMAP.md) and links here for detail.

<!-- Positioning: the phase plan is the execution view; the roadmap entry
     is the portfolio view. The plan should be ~10× longer than its
     roadmap entry. If it's not, one of them is the wrong shape. -->

**Reads before any Phase N PR lands:**

<!-- The reading list. Primes whoever picks up the phase — human or
     agent — on the context they need. Keep it short; items here
     should be things a PR reviewer will expect the PR author to have
     internalized. -->

- <!-- ADR-NNNN --> — <!-- what decision / convention it establishes that's relevant to this phase -->
- <!-- SPEC.md §N --> — <!-- what contract the phase implements or consumes -->
- [REVIEW_CONTEXT.md](../REVIEW_CONTEXT.md) — <!-- principles relevant to this phase -->

**Reads for context (reference material, non-normative):**

<!-- Optional — delete if no reference material applies. Things like
     migration briefs, prior-art studies, external SDK docs. These are
     background, not contracts. -->

- <!-- reference doc --> — <!-- one sentence on how to treat it -->

---

## 1. Goal, scope, non-goals

**Goal.** <!-- One paragraph. What does "Phase N done" mean from the user's or system's perspective? What does the world look like after this phase ships that it didn't before? -->

**In scope.**

<!-- Specific, checkable items. If a reviewer has to squint to
     decide whether a PR is in scope, the scope statement isn't
     concrete enough. -->

- <!-- item -->
- <!-- item -->
- <!-- item -->

**Explicit non-goals.**

<!-- As important as in-scope. The phase plan's scope discipline is
     the strongest guardrail against scope creep. Aim to over-
     enumerate — non-goals that feel "too obvious to state" are
     exactly the ones that get pulled in later because "we might as
     well".

     Each non-goal should name the thing AND say where it eventually
     lives (future phase, separate ADR, explicit deferral). -->

- **<!-- Thing A -->** — deferred to <!-- where -->.
- **<!-- Thing B -->** — belongs in <!-- where -->, not Phase N.
- **<!-- Thing C -->** — out of scope; <!-- why / where it goes -->.
- **<!-- Changes to [adjacent component] beyond the minimum this phase requires -->** — if Phase N uncovers a gap there, the fix lands in a separate PR and is cited here; it does not grow Phase N's scope silently.

---

## 2. Prerequisites

Phase N implementation work does not begin until the items below land.

<!-- Three buckets: required-in-order, tracked-not-blocking, already-
     complete. The middle bucket is the nuanced one — it's what lets
     work start without pretending every loose end is closed. -->

**Required, in landing order.**

1. **<!-- This plan PR -->** (`docs/plans/PHASE-N.md`). When this merges, [`docs/ROADMAP.md`](../ROADMAP.md) §Phase N is updated in the same PR: <!-- what changes in ROADMAP as a result -->.

2. **<!-- Prerequisite PR -->.** <!-- What it contains, referenced by contract/ADR. Concrete scope — what files change, what tests are added, what invariants are established. -->

3. **<!-- Prerequisite PR -->.** <!-- ... -->

**Tracked, not blocking.**

<!-- Items that might surface during implementation but don't gate
     the phase from starting. Linked to issues so the status is
     visible. -->

- **<!-- Open question -->** ([issue #NN](<!-- link -->)). <!-- When and how this gets resolved. Often something like: "Phase N work begins without this resolved; if the extension turns out to want [thing], the gap surfaces in §N during implementation and closes alongside that PR." -->

**Already complete.**

<!-- Makes visible what's been set up by prior phases so the prerequisite
     list doesn't double-count. Short entries. -->

- <!-- ADR-NNNN merged -->.
- <!-- Prior PR / decision / contract-change landed -->.

---

## 3. PR sequence

<!-- If the phase produces decisions rather than engineering output (e.g. a
     design-meeting phase), replace this section with a "Decision agenda"
     enumerating the issues / ADRs the phase produces. No PRs in the phase
     itself; PRs follow as decisions close. -->

After §2 prerequisites land, Phase N implementation decomposes into N PRs. Each lands in a sideloadable / deployable / CI-green state. Per-PR depth lives in §4–§7; this section is the order-of-operations and the visible outcome that gates each merge.

<!-- PR labeling scheme — pick one:

     - Alphabetic: "PR Na", "PR Nb", "PR Nc" (for small sequences)
     - Numeric: "PR N.1", "PR N.2"
     - Descriptive: "Scaffold PR", "Live-search PR", "Rich-item PR"

     The important thing is that each PR has a memorable short name so
     later sections can reference it without re-describing. -->

**PR Na — <!-- Scaffold / minimal viable shape -->.** <!-- What this PR contains, in 2-4 sentences. -->

- **Depends on:** §2 prerequisites complete.
- **Gate:** <!-- what outcome must be demonstrable to merge. Phrase in outcome terms, not task terms. "Clone → build → [thing] appears in [system] → [thing] does [expected]" is better than "code scaffolding complete". -->
- **Detail:** §N (<!-- which section has the depth -->), §N (<!-- which -->).

**PR Nb — <!-- Core functionality -->.** <!-- ... -->

- **Depends on:** PR Na.
- **Gate:** <!-- ... -->
- **Detail:** §N, §N.

**PR Nc — <!-- Rich / polish / integration -->.** <!-- ... -->

- **Depends on:** PR Nb.
- **Gate:** <!-- ... -->
- **Detail:** §N.

**PR Nd — <!-- Final polish + phase gating -->.** <!-- Manual test plan execution, perf budget verification, ROADMAP update, CHANGELOG entry. -->

- **Depends on:** PR Nc.
- **Gate:** all manual tests pass, performance budget met or gap explicitly documented, no open critical bugs from the chain.
- **Detail:** §N.

<!-- OPTIONAL: note explicitly what IS NOT in the sequence. Example:

     Settings UI is intentionally not in this sequence — Phase N ships
     with no in-extension settings surface. See §8.

     This prevents reviewers from wondering "did they forget to plan the
     settings PR?". -->

---

## 4. <!-- External contract the phase produces or consumes -->

<!-- Use when the phase involves a contract surface: CLI invocation,
     RPC shape, message format, etc. Describe what the phase's work
     produces or consumes, and how it maps to SPEC.md.

     Subsections typically include:

     - Discovery and invocation (how does the component find its
       counterpart; how is it called)
     - Process model (lifecycle, timeouts, cancellation, debounce)
     - Parsing / validation (what the consumer must handle; what
       errors look like)
     - Error handling (what's surfaced to the user, what's logged,
       what's retried) -->

<!-- If the phase doesn't produce or consume a contract surface,
     delete this section. -->

---

## 5. <!-- Internal scaffolding -->

<!-- The shape of the code that implements the phase — file layout,
     key classes/modules, naming conventions, build configuration.

     Not the implementation itself; the shape that makes
     implementation unambiguous.

     Example content:

     - Project layout (file tree with brief annotations)
     - Key types / traits / interfaces and their responsibilities
     - Runtime / framework / SDK version pinning
     - Dependencies picked (and why; alternatives that were
       considered at this tactical level can be footnoted but
       needn't be full ADRs) -->

<!-- Delete if not applicable. -->

---

## 6. <!-- Component shape / data shape / UI shape -->

<!-- The visible shape of whatever the phase produces. For a UI phase,
     what the user sees. For a data-model phase, the table or schema.
     For a protocol phase, the message fields.

     This section is often the densest in the plan and may need its
     own subheadings:

     - Per-element field table
     - Rendering rules / validation rules
     - Edge cases (empty, error, loading)
     - What's deliberately omitted and why -->

<!-- Delete if not applicable. -->

---

## 7. <!-- Packaging / dev loop / operational concerns -->

<!-- For phases that produce a shippable artifact (installer, binary,
     package, extension), cover:

     - Packaging format and manifest details
     - Signing (dev vs production)
     - Build + deploy inner loop for developers
     - Log location, rotation policy
     - Distribution channels in scope vs deferred

     Keep production-signing / Store submission / auto-update etc.
     out of scope if they belong to a later phase, but NAME them so
     the boundary is visible. -->

<!-- Delete if not applicable. -->

---

## 8. <!-- What we're deliberately NOT shipping -->

<!-- OPTIONAL but recommended when a reader might reasonably expect
     something that isn't coming.

     This is the architectural-level non-goal — distinct from the
     scope-level non-goals in §1. It names a capability the phase
     could plausibly include but explicitly does not, with the
     reasoning for the exclusion.

     Example shape:

         Phase N ships **no in-extension settings surface**. This is
         a deliberate non-goal, not an omission.

         **Why none.** [Reasoning — usually that the capability belongs
         somewhere else in the architecture, or that it'd fork a
         source of truth, or that it's premature until specific
         usage data comes in.]

         **What Phase N leaves open.** [Triggers that would bring
         this in; typically "when X or Y happens, open a subsequent
         ADR and an additive PR."]

         **Anti-goal.** [An obvious-seeming design that is NOT
         planned — the "don't go there without a superseding ADR"
         warning.] -->

<!-- Delete if not applicable. -->

---

## 9. Success criteria & gates

"Phase N done" means all of the below hold. Each PR in the §3 chain lands a subset; this section consolidates the checklist so drift is visible in one place.

**Phase-N success criteria.**

<!-- The user-visible / system-level outcomes. Each should be
     specific enough to check. Include latency/throughput targets
     where relevant, and NAME the corpus or workload they're
     measured against. -->

- <!-- A user can [do X end-to-end]. -->
- <!-- [Failure mode Y] renders as [specific handling], not silent failure. -->
- <!-- [Performance metric] meets [target] at [measurement method] on [representative workload]. -->
- <!-- [Documentation] updated: [what updates, where]. -->

**Per-PR gate table.**

<!-- Consolidates the per-PR "Gate" lines from §3 into a single view.
     Paired Must-demonstrate / Must-not columns. -->

| PR | Must demonstrate | Must not |
|---|---|---|
| Na | <!-- outcome --> | <!-- exclusion --> |
| Nb | <!-- outcome --> | <!-- exclusion --> |
| Nc | <!-- outcome --> | <!-- exclusion --> |
| Nd | <!-- outcome --> | <!-- exclusion --> |

**Perf measurement** (if the phase has a latency or throughput target):

<!-- Define "representative workload" (which corpus, which input
     distribution). Define measurement method (p95 over N runs,
     warm vs cold, what's being timed end-to-end). Name the gate
     threshold AND any informational-only secondary measurements.

     If perf is missed, the failure path: (a) fix in-scope when root
     cause is phase-side, (b) document the gap and open a follow-up
     issue when root cause is elsewhere. Do not merge the gating PR
     with a quiet fail. -->

**Anti-drift assertions.**

<!-- Things a Phase N PR must NOT have. Each one should correspond to
     a core principle (from REVIEW_CONTEXT.md) or an explicit scope
     decision (from §1 or §8).

     These are enforced at each PR's reviewer checklist. -->

A Phase N PR must not have:

- <!-- violation of a core principle -->
- <!-- regression on a deliberate non-goal from §1 or §8 -->
- <!-- scope leak into a bounded adjacent surface -->
- <!-- change to [out-of-scope artifact] outside [authorized PR] -->

---

## 10. Follow-ups

<!-- The deferred-with-conditions pattern, applied at the phase level.
     Every phase surfaces follow-ups; documenting them here prevents
     them from falling on the floor.

     Groupings that work:

     - Surfaced by Phase N (open questions to close during or after)
     - Already scheduled for a later phase
     - Long-term / open-ended
     - Admin (minor cleanup, doc updates, chases) -->

**Follow-ups surfaced by Phase N work.**

- **[Issue #NN](<!-- link -->) — <!-- open question -->.** <!-- When and how this closes: "PR Nd investigates; outcome is either a supersession ADR + additive PR (if yes) or a closed issue with reasoning (if no)." -->
- **<!-- Deferred feature from §8 -->.** <!-- Where it picks up; what the trigger is. -->

**Already scheduled (Phase N+k).**

<!-- Items that Phase N explicitly routed to a later phase, named
     here so reviewers can see they aren't forgotten. -->

- **<!-- Deferred item -->** — routed to Phase N+k per <!-- ROADMAP or ADR -->.

**Admin.**

- **Deferral sweep** — on phase completion, scan the deferred-with-conditions surfaces (`CONTRIBUTING.md` §CI strategy "Deferred", `SPEC.md` §Deferred, `DESIGN.md` future extensions, `ROADMAP.md` future phases, earlier phase plans' follow-ups, issues labelled `deferred`) for triggers that named Phase N or fired during it; wire each hit in or explicitly re-defer it with a new trigger. See `CONTRIBUTING.md` §"CI strategy" §4, *The sweep step*.
- **Randomized-exploration campaign run** — if the project has adopted `CONTRIBUTING.md` §"Randomized-exploration testing", run the unbounded campaign at phase completion and triage failures (promote each failing case to a committed deterministic fixture). This is the convention's mandatory floor; delete this bullet only if the convention isn't adopted.
- **<!-- CHANGELOG / doc update / cleanup -->** — <!-- who picks up, when -->.
- **<!-- Typo, rename, link fix -->** — <!-- usually ships with this phase's gating PR or follow-up -->.

---

**End of Phase N plan.** This document is a draft until the plan PR merges; at that point [`docs/ROADMAP.md`](../ROADMAP.md) §Phase N links here.
