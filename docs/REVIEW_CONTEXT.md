# [PROJECT] — Reviewer Context

**Purpose.** This document seeds a reviewer agent with the context needed to review PRs against [PROJECT] with judgment, not just surface-level linting. Point the reviewer at `DESIGN.md`, `SPEC.md`, `ROADMAP.md`, and this file before starting a review.

<!-- This document does double duty: it's a reviewer-agent prompt AND a
     codified statement of what the project cares about. New human
     contributors benefit from reading it too. Write it accordingly —
     not as a narrow prompt, but as a statement of project values that
     happens to work as a prompt. -->

---

## Project in one paragraph

<!-- Tighter than the DESIGN.md overview. The goal: someone who's never
     seen the repo should, after reading this paragraph, be able to tell
     whether a given change belongs in the project at all.

     Example shape:

         [PROJECT] is a [kind of thing] that does [primary function].
         Architecture: [shape in one clause]. Key design decisions
         already locked in: [2-3 invariants]. The goals that shape
         everything: [1-2 goals, in the form "X matters because Y"]. -->

Key documents:

- `DESIGN.md` — architectural rationale, module responsibilities, process model
- `SPEC.md` — binding contracts
- `ROADMAP.md` — phased delivery plan
- `docs/decisions/` — ADRs
- `docs/RISKS.md` — optional; ship if the project carries regulated, life-safety, or hard-reliability obligations
- <!-- any other canonical reference, e.g. a schema file -->

## Verification vs validation

This document supports two distinct review modes. The reviewer agent can be invoked in either, or in both:

- **Verification — *did we build it right?*** Does the diff match the binding contracts in `SPEC.md`, the catalogue in `.github/labels.yml`, the four-tier CI structure, the file-shape conventions? Checks against **named artifacts**. Findings are mechanical: a rule said X, the diff did Y, here's the gap. The `Verified by:` annotations in `SPEC.md` are the right-side mechanisms verification-mode reviews use.
- **Validation — *did we build the right thing?*** Does the diff match the principles below, the project goals, the scope of the PR's stated purpose? Checks against **intent**. Findings are judgment calls: a principle implies X, the diff appears to violate it, here's the reasoning.

A bundled review covers both by default. When the reviewer agent is asked to focus on one — for instance, *"review in verification mode against PR diff at <file>"* — it stays inside the named-artifact checks; *"review in validation mode"* stays inside the principles and scope. Tighter findings, lower token cost when the reviewing context warrants narrowing.

The distinction is borrowed from [V-cycle](https://en.wikipedia.org/wiki/V-model) / ECSS-style engineering, which names the left-right structure explicitly (left side commits to *what*; right side names the mechanisms that verify *built right* at each level). This project deliberately stays lighter than ECSS-grade ceremony — no formal V&V plans, no qualification documents, no requirements traceability matrices — but borrows the framing so the right-side mechanisms are named, not implied. See [ADR-0007](../meta/decisions/ADR-0007-v-cycle-additions.md) for the rationale and the deferred elements (stable SPEC IDs, multi-doc baseline versioning).

## Evidence discipline — fact, or artifact of the measurement?

The principles below are about the **artifact**; this section is about
**method**. What makes this class catchable is that the unverified thing is
usually **the instrument, not the subject** — the number is real, but it
measures something other than what the sentence says.

**Prefer a mechanical guard to vigilance.** Where a claim can be pinned by a
test or a gate, pin it; this section is for the rest.

**Tells that a measurement is an artifact rather than a result:**

1. **stderr discarded** where stdout is treated as data.
   `git show missing:path 2>/dev/null | tr -cd '\r' | wc -c` returns `0` — so
   does a genuine LF file. Worse than one bad number: a *set* of these can look
   coherent while some entries are failures, and that coherence is what stops
   the question being asked.
2. **unchecked tool state** — the tool is not showing what you assume. A
   shallow clone's boundary commit behaves exactly like a root commit
   (`git rev-parse --is-shallow-repository`); a stale working tree answers for
   a revision you did not ask about (`git show <rev>:<path>`, not a search over
   the checkout).
3. **"CI is green"** — a claim about *what ran*. A suite that silently shrank
   still reports `0 Failed`. **"It passes locally"** is the same tell mirrored:
   a test count without an environment is a claim about what ran with the
   *where* left out. A local harness broader than the real one — anything that
   puts more on the path, in the environment, or in scope than the gate does —
   answers a question the gate never asks.
4. **an inferred relationship between two verified facts** — both line numbers
   right, the execution order between them never checked; an error identifier
   real, the code path it implied never confirmed to exist. Two facts do not
   make the relation between them a third.
5. **a statistic whose population was never stated** — a median or a percentage
   is only as good as the set it was taken over, and the set is the part most
   easily left implicit.
6. **a negative result whose search space was narrower than the claim.**
   "I searched and found nothing" answers the question you *typed*, not the one
   you asked. Distinct from the *inferred-relationship* tell (there is one
   fact, not a relationship) and from the *unchecked-tool-state* tell (the
   tool answered honestly — the *query* was under-specified).
   Before concluding *X is absent*, enumerate the forms X could take and check
   the pattern covers them: a dependency can be a filesystem call, a name that
   has to resolve at run time, or ambient state, and a pattern list built for
   one of those cannot express the others. Where the set can grow, prefer a
   **deny-list with a drift test** to an allow-list — an allow-list omits
   silently, which is the same failure with a longer fuse. (This is about
   *search coverage*, not about deliberate allow-lists: a deny-by-default
   security control is correctly an allow-list. Its tell is different — it
   fails silently on the entry you forgot to write, so it needs a note saying
   so.)
7. **a summarizing intermediary treated as a primary source** — an agent-side
   fetch tool that answers a prompt with a smaller model returns that model's
   summary of the page, not the page: its quotes, figures, and citations are
   the summarizer's output, with compression and invention as failure modes.
   (E.g. Claude Code's WebFetch is documented to run "the prompt against the
   content using a small, fast model. For most fetches, Claude receives that
   model's answer, not the raw page" and to be "lossy by design" —
   <https://code.claude.com/docs/en/tools> §"WebFetch tool behavior",
   retrieved 2026-08-22 via raw fetch of the page source.)
   Fine for triage and leads; the tell is a specific figure or quote whose
   provenance is a fetch-tool result rather than the raw text. For any claim
   that will be quoted into a durable doc, retrieve the raw text (fetch the
   page or paper directly and read it yourself) and record the retrieval
   method beside the claim.

**A claim that will outlive the PR** — quoted into a document, a roadmap row, an
ADR — carries how it was measured, so the next reader can re-run it instead of
trusting it. A *"To reproduce:"* line beside the number is the shape.

### Instances (this project)

<!-- Citations only. The numbered tells above stay generic and portable;
     project-specific instances (the PR / issue / doc where a tell fired
     here) accumulate below as short cited entries. Do not fold instance
     details back into the tells — the tells/instances split is the
     convention that keeps this section liftable between projects.
     Reference tells by name, not number, so insertions don't rot the
     citations. -->

- ***"CI is green"*** — the PR #58 review (the PR that added this section)
  noted the seed's markdown-lint gate excludes `docs/REVIEW_CONTEXT.md` and
  `docs/plans/PHASE-TEMPLATE.md`, which carried 84 of that PR's 335 added
  lines — so "markdown lint green" there was a claim about the other seven
  files. To reproduce: compare the ignore globs in `.markdownlint-cli2.jsonc`
  against the PR's file list.

## Core principles (review against these)

<!-- This is the load-bearing section. These are NOT generic software-
     engineering principles — they are the specific invariants this
     project has repeatedly converged on. A PR that violates one should
     be flagged, even if it's internally consistent.

     Target 5-8 principles. Each should be phrased as an assertion the
     reviewer can test a PR against. "The index on disk is the
     contract" is a good shape; "write clean code" is not.

     Examples from the shape of other projects to illustrate:

     1. **The [shared artifact] is the contract.** Processes come and
        go around it; none own it. If a PR couples two processes
        through runtime communication, that's a significant deviation.

     2. **Permissive licenses only.** MIT, Apache-2.0, BSD. [GPL and
        AGPL excluded because Y.] Any new dependency's license must
        be declared and checked.

     3. **Polyglot by design.** [Shared surfaces] must be language-
        agnostic. If a PR introduces a shared artifact only one
        language can consume (a pickle, a binary format), that's
        wrong.

     4. **[Latency target] matters.** [Component] targets [X ms from
        spawn to result]. Long-running processes are a non-goal. A
        PR that adds significant startup work needs justification.

     5. **Phased migration, not rewrites.** [Current generation] →
        [next generation] is incremental. A PR that couples [generation
        internals] or assumes only one will exist undermines this.

     6. **Warnings are actionable.** [Specific class of error] should
        get a clear message with a path forward, not a cryptic stack
        trace.

     7. **Composition over dependency.** [Reference implementations]
        are studied, not imported as libraries.

     8. **User-facing docs are state-based and release-relative.**
        They describe current behavior with no dev-tracking references
        (no ADR-NNNN, no #issue, no internal revision tags); dev docs
        and code comments keep the full audit trail. Flag a PR that
        leaks tracker vocabulary into a user-facing surface.

     Replace wholesale with your project's actual invariants. -->

1. **<!-- Principle -->** <!-- Description + consequences for PRs. -->
2. **<!-- Principle -->** <!-- Description + consequences for PRs. -->
3. **<!-- Principle -->** <!-- Description + consequences for PRs. -->

## Terminology (enforce consistency)

<!-- Words that mean specific things in this project, plus the drift
     modes to watch for. Conflation between terms is one of the most
     common review findings; pre-enumerating the distinctions makes
     the reviewer's job easier.

     Example shape:

     - **Phase N:** delivery milestones from ROADMAP.md. Phase numbers
       are stable and never reused.
     - **Gen 1 / Gen 2:** [component] technology. Gen N is NOT the
       same as Phase N — they are orthogonal dimensions.
     - **[Term]:** when unqualified, refers to [specific thing]. The
       [other thing] is always qualified as such. -->

- **<!-- Term -->:** <!-- definition + what not to confuse it with -->
- **<!-- Term -->:** <!-- definition + what not to confuse it with -->

## Common review patterns and red flags

<!-- The reviewer's working checklist of things that should raise
     eyebrows. Organized by category, each with a concrete shape
     ("flag if X") and a reason.

     Think of the categories below as types of red flag, then
     instantiate each with your project's actual failure modes. -->

**<!-- Contract drift -->.** <!-- What counts as drift between this project's canonical artifacts and their implementations. Which artifact is authoritative. What happens when they disagree. -->

**<!-- Terminology inconsistency -->.** Look for:

- <!-- Specific wrong-vs-right pairs your project keeps hitting -->
- <!-- e.g. "Phase N" where "Gen N" is meant, or vice versa -->

**<!-- Scope creep in a shared file -->.** <!-- Identify which files have a narrow, well-defined scope that shouldn't grow. Why. What belongs there vs where. -->

**<!-- Exposing internal state as contract -->.** <!-- If SPEC.md explicitly marks something as internal to module X, it must stay internal. Flag PRs that start reading or writing it from outside. -->

**<!-- Architectural creep: daemon, cache, session state, ... -->.** <!-- Name the architectural moves this project has deliberately ruled out. A PR proposing one is a significant deviation and needs explicit justification. -->

**<!-- Unrealistic assumptions about [known pain point] -->.** <!-- Every project has them. Python packaging, Windows path handling, timezone arithmetic. If a PR treats one of them as a solved problem, push back.

     Concrete example of the shape (adapt or delete — illustrative, not a
     mandated rule): in a multi-tenant system that schedules future work at a
     local wall-clock time, make it a citable assertion — "storage is UTC, but
     the tenant's IANA timezone is canonical for every time-sensitive
     operation." Flag a PR that anchors a schedule, or derives a tenant-facing
     "today", from UTC (or the browser/device zone) instead of resolving it
     from the tenant-carried zone at the write seam: the UTC-anchored branch is
     the intuitive one and it silently produces wrong calendar dates for
     tenants in other zones — dates that then flow into immutable downstream
     artifacts. -->

**A guard whose failure direction is unasserted.** A
fallback that states which way it should fail when it cannot decide, with no
test that puts it in that state. The happy path passing says nothing about the
`catch`. Pin the *undeterminable* input, not just the valid and invalid ones.
<!-- A fail-direction stated in prose is not a fail-direction under test, and
     error paths are where already-fixed defects come back. Instantiate with
     your project's guards: parsers with a reject-on-ambiguity clause,
     fail-closed gates, "when in doubt, refuse" fallbacks. -->

**<!-- Missing ADR for a decision that will stick -->.** <!-- When a PR makes a decision future contributors will wonder about, an ADR should accompany it. Small tactical choices don't need one; see CONTRIBUTING.md §"Design decisions". -->

## What to be lenient about

<!-- Explicit permission not to nitpick. This is as important as the
     strict list — reviewers who flag everything stop being trusted.

     Example shape:

     - Naming bikesheds unless they break consistency with existing terminology
     - Missing tests on throwaway / PoC code
     - Imperfect prose in rationale documents (they're not contracts)
     - Minor stylistic inconsistencies across documents if the substantive
       content is right -->

- <!-- category -->
- <!-- category -->

## What to be strict about

<!-- The non-negotiables. Crystallizes which review findings are blockers. -->

- Anything that touches a cross-language or cross-module contract
- <!-- constraints from DESIGN.md (licensing, platform support, perf envelope) -->
- Terminology drift in any of the three core documents
- Changes that silently break <!-- named invariant, e.g. a migration path -->
- Breaking a core principle from the list above

## Review output format

When reviewing a PR, structure feedback as:

1. **Summary** — one paragraph: what the PR does, is the direction right, is it ready to merge.
2. **What works well** — brief, to acknowledge good work.
3. **Issues to address before merge** — numbered, each with file/line reference, severity (blocker / non-blocker), and concrete suggested change.
4. **Follow-up suggestions** — non-blocking items that could land in this PR or a later one.
5. **Verdict** — approve / approve with changes / request changes, with a clear conditional if "approve with changes".

Cite line numbers when referring to specific content. Quote the problematic text when it's short. Propose concrete replacement wording when you disagree with something — don't just say "this is wrong," say "this should read X because Y."

## Tone

<!-- Calibrate explicitly. The difference between a solo-maintainer
     project and a team-of-20 affects what "constructive" means.

     Examples:

     - Solo project: "This is a solo-maintainer project; reviews are a
       conversation, not an approval gate. 'I'd do this differently
       but yours works too' is a legitimate thing to say."

     - Small team: "Be direct. Our code review culture is that pushing
       back is expected; 'LGTM' with no comments is suspicious."

     - Open source: "Reviewers are often first-time contributors'
       first interaction. Lead with what works, be explicit about
       what's a blocker vs nit, remember that the PR author doesn't
       have the context you do." -->

<!-- Add: -->
<!-- - What level of directness is appropriate -->
<!-- - Whether reviews should be strict gates or conversations -->
<!-- - How to handle disagreement between reviewer and PR author -->
