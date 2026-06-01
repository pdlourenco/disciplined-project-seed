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

- **Verification — *did we build it right?*** Does the diff match the binding contracts in `SPEC.md`, the catalogue in `.github/labels.yml`, the four-tier CI structure, the file-shape conventions? Checks against **named artifacts**. Findings are mechanical: a rule said X, the diff did Y, here's the gap. The `verified by:` annotations in `SPEC.md` are the right-side mechanisms verification-mode reviews use.
- **Validation — *did we build the right thing?*** Does the diff match the principles below, the project goals, the scope of the PR's stated purpose? Checks against **intent**. Findings are judgment calls: a principle implies X, the diff appears to violate it, here's the reasoning.

A bundled review covers both by default. When the reviewer agent is asked to focus on one — for instance, *"review in verification mode against PR diff at <file>"* — it stays inside the named-artifact checks; *"review in validation mode"* stays inside the principles and scope. Tighter findings, lower token cost when the reviewing context warrants narrowing.

The distinction is borrowed from V-cycle / ECSS-style engineering, which names the left-right structure explicitly (left side commits to *what*; right side names the mechanisms that verify *built right* at each level). This project deliberately stays lighter than ECSS-grade ceremony — no formal V&V plans, no qualification documents, no requirements traceability matrices — but borrows the framing so the right-side mechanisms are named, not implied. See [ADR-0007](../meta/decisions/ADR-0007-v-cycle-additions.md) for the rationale and the deferred elements (stable SPEC IDs, multi-doc baseline versioning).

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

**<!-- Unrealistic assumptions about [known pain point] -->.** <!-- Every project has them. Python packaging, Windows path handling, timezone arithmetic. If a PR treats one of them as a solved problem, push back. -->

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
