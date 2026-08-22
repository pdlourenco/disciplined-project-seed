# Contributing to [PROJECT]

<!-- One paragraph: what this project is, and what about the development workflow
     makes the guardrails in this document worth having.

     Example framing for projects with parallel agentic development:

         "[PROJECT] is built with parallel agentic development as a
         first-class workflow: multiple agents (and humans) edit
         independent modules against the contracts in docs/SPEC.md.
         This document describes the guardrails that make that safe."

     Example framing for projects without:

         "[PROJECT] is a [type] project with [N] contributors. This
         document describes the conventions and guardrails new
         contributors should be aware of." -->

## Required status checks

Branch protection on `main` is **version-controlled** via [`.github/branch-protection.yml`](../.github/branch-protection.yml) — the desired state in classic GitHub branch-protection schema. See [ADR-0005](../meta/decisions/ADR-0005-branch-protection-as-code-classic.md) for the choice of human-triggered apply (over auto-sync via Action) and classic schema (over rulesets).

**Apply.** Run `scripts/setup-branch-protection.sh` once after cloning the seed, then again whenever `branch-protection.yml` changes. The script uses the operator's `gh auth` credentials (admin scope required); no secret is stored in the repo. Shows the diff against live config before applying.

**Drift detection.** Three checks across two timing modes, all aligned with [`ADR-0005`](../meta/decisions/ADR-0005-branch-protection-as-code-classic.md):

- **Merge-time, in CI:** [`.github/scripts/check-bp-contexts.py`](../.github/scripts/check-bp-contexts.py) runs as a tier-3 job and statically asserts every required context in `branch-protection.yml` names a live job in `ci.yml` (subset check). Token-free, no network. Catches "CI job renamed; contexts didn't follow" — the most common edit-time drift — before the PR can merge.
- **Post-deploy, weekly (Sundays 10:00 UTC):** [`.github/workflows/check-branch-protection.yml`](../.github/workflows/check-branch-protection.yml) with a **two-layer** runtime model. **Layer 1** (always runs; default token's `contents: read`) is a *presence check* — `GET /repos/.../branches/main` returns a `protected` boolean. Catches "protection removed entirely". **Layer 2** (opt-in; requires `administration: read`) is *field-level drift* — `GET /repos/.../branches/main/protection` returns the full configuration; adopters who want it provide `BRANCH_PROTECTION_READ_TOKEN` (PAT or App token) as a repo secret. Without it, layer 1 still catches presence drift. The error handler distinguishes HTTP 403 (denied — token lacks scope) from 404 (missing — no protection set), so denied-as-absent is never mis-reported.

If you edited the YAML and forgot to re-apply, the merge-time check catches the context-naming subset (before merge) and the weekly check catches everything else (within a week); manual edits to `Settings → Branches` get caught too.

**Adopters:** the YAML ships with the seed's own five `Tier 3 — …` required contexts (from [`ci.yml`](../.github/workflows/ci.yml)) and conservative defaults (`required_linear_history: true`, `allow_force_pushes: false`, `allow_deletions: false`, `required_conversation_resolution: true`, `enforce_admins: false`, no required reviews). Per-field rationale is inline in the YAML; flip `enforce_admins`, configure `required_pull_request_reviews`, or add status-check contexts as your team and CI grow.

Feature-branch pushes may run a reduced slice of the matrix for fast feedback; full cross-platform and integration checks run on every pull request and every push to `main`.

## CI strategy

The pipeline has four concerns, in order of blast radius. Ordering matters — higher-leverage checks should fail faster than lower-leverage ones.

The seed ships an active baseline workflow at [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) with five tier-3 jobs (markdown lint, internal link check, dangling-placeholder audit, workflow YAML lint, branch-protection contexts consistency) and commented stubs for tier 1, tier 2, and tier 4. Adopters extend the same file with their stack's real implementations; see [ADR-0002](../meta/decisions/ADR-0002-active-trivial-ci-workflow.md) for the choice of "active trivial workflow" over a `.example` skeleton.

### 1. Contract enforcement

<!-- The highest-leverage tests in the repo: they catch silent drift between
     independently developed components. Name them concretely with what they
     check and what drift they prevent. Pick shapes from the pattern
     catalogue below (rendered text, so it survives into your adopted
     CONTRIBUTING).

     If your project has no cross-component contracts, delete this tier and
     the four-tier structure collapses to three. -->

- **`<!-- contract-consistency-test -->`** — <!-- what it asserts; what drift it catches -->
- **`<!-- version-pinning-test -->`** — <!-- which versions it pins together, why -->
- **`<!-- integration-job -->`** — <!-- what writes, what reads, what assertion -->

#### Contract-gate pattern catalogue

Patterns for tier-1 gates — the contents are domain-specific and stay
downstream:

- **Spec-prose parsing gate** — tests parse the catalogue tables out of `SPEC.md` (or a canonical schema file) and assert set-for-set equality with the code-side unions / schema definition. Useful side effect: forces a documented, machine-parseable shape onto the SPEC tables themselves.
- **Codegen-diff gate** — emit the interface description from the real application (e.g. OpenAPI from the running app), regenerate the client types, then `git diff --exit-code`: an unregenerated contract change fails CI.
- **Set-for-set enrollment gate** — enumerate every route / handler / member from framework metadata and force each into an explicit disposition (`matrix` / `exempt` / `pending`); an unenrolled newcomer fails CI.
- **Totality-over-enum gate** — every enum member declaring a capability must appear in the registry that implements it.
- **Metadata-derived cross-check** — any hand-maintained list inside a lint rule or gate is asserted equal to the same set derived from schema metadata, so the gate itself can't drift from the schema.
- **Structural lint rule** — an AST-level rule that makes violating an architectural invariant a build error, paired with the metadata-derived cross-check above so the rule's hardcoded list can't silently diverge.
- **Version-pinning test** — two implementations of a shared dependency asserted to agree on (at least) a minor version.
- **Integration probe** — one side's writes exercised against the other side's reads with a real on-disk artifact, asserting the field set and types.
- **Shared contract artifact** — one language-agnostic, machine-parsed file (a schema file, a TOML/JSON catalogue) that *every* implementation parses at build/run time, instead of per-language mirrors reconciled by an equality test. Drift in the source of truth becomes structurally impossible; drift in the parsers is caught at CI time by the integration probe. Prefer this over mirror-plus-equality-test where feasible: the equality test catches drift only after it's already pushed, and dies when one language is retired.

Two caveats:

- **Gate the production idiom, not a mirror.** A gate that verifies a parallel, test-oriented reimplementation of the production function passes while the production idiom goes unverified. Point the gate at the code that ships.
- **`Verified by:` annotations need a cross-check.** An annotation claiming "verified: every rule above" while rules have zero tests is worse than no annotation — it converts visible debt into hidden debt. Either mechanize the cross-check or use a closed value vocabulary (values are per-project; e.g. `unit` / `integration` / `lint` / `manual` / `deferred` / `none`) so each rule's claim is individually checkable; `none` doubles as the visible-debt marker.

**Hardening for machine-shared artifacts.** Gates guard the consumers; the artifact's own generation needs guards too. Any generated shared artifact carries **generator-provenance metadata** (generator version, date, seed) so staleness is detectable from file contents; numeric artifacts (reference vectors, golden files) additionally set an **absolute tolerance floor** so the gate isn't environment-flaky at zero tolerance. Assert that every shipped artifact is consumed by at least one test, so orphans can't accumulate.

#### The drift-hardening doctrine

The doctrine behind the catalogue, stated once so reviews can cite it:

- **A mandate enforced only by an outcome test that two idioms both pass will drift.** Replace it with a structural gate.
- **Implementations conform to the spec, not to each other.** No implementation is ground truth. Cross-implementation equivalence vectors are a check, not a proof: a bug in a shared helper makes every downstream caller violate the spec in the same way, invisibly to cross-validation.
- **Prose points, doesn't restate.** Set-for-set gates protect the tables they parse; prose that *restates* a machine-checked catalogue falls behind within a version or two. Docs describing a contract link to it rather than repeating its contents. The paired refresh step lives in §"When you change a contract in `docs/SPEC.md`".

### 2. Cross-platform matrix

<!-- List supported platforms and what runs on each.
     Delete this tier if the project is single-platform. -->

### 3. Code quality

<!-- One bullet per language/component. Typical entries:

     - Lint + type check (ruff / mypy / clippy / tsc / etc.)
     - Test suite with coverage floor
     - Formatter check (fmt / black / prettier / etc.)
     - Pre-commit run against all files as a centralized enforcement point -->

### 4. Deferred (not yet wired)

These checks are valuable but don't earn their keep today, either because the surface they protect hasn't landed yet or because their signal-to-noise ratio is poor until the codebase is larger. Each entry names the check, what it does, why we're deferring it, and the **trigger condition** that should prompt us to wire it in.

**The sweep step.** A named trigger only works if someone notices it fired — the documented failure mode is deferrals sitting unswept after their trigger fired. The convention is therefore paired with a sweep: **on every phase completion** (see `docs/plans/PHASE-TEMPLATE.md` §10 Follow-ups, *Admin*), scan the project's deferred-with-conditions surfaces — this section, `SPEC.md` §Deferred, `DESIGN.md` future extensions, `ROADMAP.md` future phases, phase-plan follow-ups, and issues labelled `deferred` — for triggers that named the completing phase or fired during it. Each hit is either wired in or explicitly re-deferred with a new trigger; silence is the one prohibited outcome.

<!-- The deferred-with-conditions pattern is the same discipline used in
     SPEC.md §"Deferred" and ROADMAP.md "Future phases". It prevents
     "someday" from meaning "never" by accident.

     Template per entry below. Duplicate per item. When you wire one in,
     move it out of this section and into the appropriate tier above. -->

#### <!-- Example: supply-chain audit -->

- **What:** <!-- concrete description of the check -->
- **Why deferred:** <!-- project-specific reasoning; not generic -->
- **Trigger to wire in:** <!-- explicit condition, e.g. "first release binary built", "dependency count grows past N direct deps", "Phase N begins" -->
- **Sketch:** <!-- how it would be implemented when the trigger fires -->

#### <!-- Example: performance regression gate -->

- **What:**
- **Why deferred:**
- **Trigger to wire in:**
- **Sketch:**

### Expensive required checks — cost patterns

When a required check is costly — licensed toolchains, long runs, metered runners — two patterns keep the merge gate intact without paying for runs that prove nothing:

- **Docs-only skip inside the job.** The expensive job starts with an in-job base-diff; when the diff touches no surface the check exercises (e.g. a docs-only PR), the job exits successfully without running the expensive part, so **the required context still reports green**. Keep the skip *inside* the job rather than in a workflow-level `paths:` filter: a `paths:`-filtered required check that never starts reports pending forever and wedges the merge gate.
- **Committed pre-push hook mirroring CI.** A committed hook directory (e.g. `.githooks/pre-push`, opted into via `git config core.hooksPath .githooks`) runs the *same entry point CI runs*, on a clean environment, and **skips cleanly when the toolchain is absent** — contributors with the toolchain catch failures before burning licensed CI minutes; contributors without it aren't blocked.

Adopt these when a required check is expensive enough that they pay for themselves; for cheap checks (like the seed's own doc-CI) they're overhead.

## Workflow permissions

Any shipped workflow that uses `actions/checkout` (or otherwise reads repo contents) must list `contents: read` explicitly in its `permissions:` block. A `permissions:` block sets every unlisted scope to `none`, so the implicit `contents: none` breaks `actions/checkout` on private repos with a 404 — silently fine on public repos because unauthenticated reads work, which is how this class of bug can hide until a private adopter hits it. `contents: read` is harmless on public repos and required on private — a strict improvement with no downside. The seed's own `sync-labels.yml`, `check-branch-protection.yml`, and `ci.yml` all ship with explicit `contents: read`; extend the same discipline to any new workflow.

## `gh` CLI in workflows

Any shipped workflow that invokes the `gh` CLI against a specific repo (`gh issue create`, `gh pr create`, `gh api /repos/...`, …) must target the repo explicitly — either via `--repo ${{ github.repository }}` per call site, or by setting `GH_REPO: ${{ github.repository }}` in the step's `env:`. Without it, `gh` falls back to inferring the target from the current working directory's git remote, which only works if `actions/checkout` ran. Workflows that legitimately don't check out (or any future workflow that drops the checkout step "because the API call doesn't need it") silently break the first time the `gh` command actually fires — typically with `fatal: not a git repository`. The seed's `check-branch-protection.yml` sets `GH_REPO` on every step that calls `gh issue create`; extend the same discipline to any new workflow that invokes `gh` outside a checked-out tree. The failure shape is tool-independent: any CLI invoked in CI that infers its target repo or context from the working directory, rather than from an explicit flag or environment variable, breaks silently in workflows without a checkout — always pass the target explicitly.

## Local development

<!-- One subsection per language or component. Keep commands minimal and
     working — these are what a new contributor (or agent) runs first. -->

### <!-- Component name, e.g. Python service -->

```bash
# setup
# test
# lint
```

### <!-- Component name, e.g. Rust CLI -->

```bash
# setup
# test
# lint
```

## Design decisions (ADRs)

Non-obvious design choices live in `docs/decisions/` as Architecture Decision Records. See `docs/decisions/README.md` for the convention, format, and the current index.

**When to add an ADR in your PR**:

- You made a tactical or engineering choice someone could reasonably challenge later (thresholds, fallback ordering, error-handling policy, schema seams kept reserved for future).
- Future PRs will either follow your pattern or explicitly deviate — having a target to reference saves reviewers and future agents from re-deriving the trade-off.

**When NOT to add an ADR**:

- The choice is obvious or already in `docs/SPEC.md`, `docs/DESIGN.md`, or `docs/ROADMAP.md`. Those docs own contracts and architecture; ADRs capture the *why* of tactical choices below that layer.
- The choice is purely mechanical (import ordering, formatter settings).

Link ADRs from PR descriptions: `Implements X per ADR-NNNN.` Inline code comments can point to ADRs for tactical values (`# See ADR-NNNN` beside a magic number).

**Scope of dev-tracking references: dev-facing surfaces only.** User-facing docs are **state-based and release-relative** — they describe current behavior and never carry `ADR-NNNN`, `#issue`, or internal revision tags; the audit trail lives in dev docs and code comments. A user reading the manual should not need the tracker to parse a sentence.

## Pre-push self-review (agent convention)

Before every `git push` on a PR branch, Claude agents working on this repo should launch a reviewer agent on the local diff and act on what it flags. This catches the "I would have caught that if I thought about it harder" class of bugs before they burn CI minutes, PR-thread attention, or reviewer time.

### Reviewer prompt

Launch a `general-purpose` or `Explore` subagent with the diff plus this prompt.

The prompt below covers both review modes from [`REVIEW_CONTEXT.md` §"Verification vs validation"](REVIEW_CONTEXT.md) — *verification* (matches contracts / catalogue / named artifacts?) and *validation* (matches principles / scope / intent?). To run a single-mode review for tighter findings at lower token cost, prefix the invocation with *"review in verification mode only"* or *"review in validation mode only"* and skip the bullets that don't apply.

**Replace the example pitfalls below with your project's actual principles from [`REVIEW_CONTEXT.md`](REVIEW_CONTEXT.md), phrased as numbered assertions the reviewer can cite by number.** What's listed below is shaped as a guide, not as boilerplate to ship verbatim.

> Review the diff below for:
>
> 1. **<!-- Project-specific pitfalls -->** — <!-- Calibrate this list to
>    concrete bug classes the project has actually shipped, or to the
>    numbered principles in REVIEW_CONTEXT.md so findings can cite them
>    by number ("violates principle 3: [shared artifact] is the contract"
>    is more actionable than "cross-cutting issue: ..."). Examples from
>    other projects to illustrate the shape:
>
>    - Cross-platform issues (Windows path handling, line endings, shell syntax)
>    - Encoding assumptions (assumed UTF-8, assumed locale)
>    - Timezone handling (naive datetimes crossing boundaries)
>    - Licensing obligations (new dependency, check license compatibility)
>    - Binary-vs-text file handling (pre-commit hooks mutating binary fixtures)
>
>    Swap in your project's actual failure modes or principles. Vague
>    prompts get vague reviews. -->
> 2. **Scope drift** from the PR's stated purpose — touching files outside the declared scope, unrelated refactors piggybacking on the PR.
> 3. **Design choices deserving an ADR** (see `docs/decisions/`) — new magic numbers, non-obvious fallback chains, thresholds, backwards-compat seams.
> 4. **Missing or stale ADR links** in the PR description; missing docstring `See ADR-NNNN` markers beside tactical values.
> 5. **Label consistency with the diff** — does the `Labels applied` checklist row in the PR description match the topic labels appropriate for the surfaces this PR touches? Map each touched surface to its topic label per [`docs/LABELS.md`](LABELS.md) §Disambiguation as the canonical source — the taxonomy can drift over time; `LABELS.md` is the truth, not this bullet. Common misfires worth eyeballing: rationale / architecture docs (including ADRs) are `design`, not `documentation`; code realizing an existing contract is `implementation`, but a docs- or YAML-only PR with no application code is *not* `implementation`.
> 6. **Lifecycle currency on linked issues** — for any issue this PR references (`closes #NN`, `addresses #NN`, etc.), is the issue's current lifecycle label still accurate given the conversation? A `discussion` issue that's clearly resolved should be `decided`; a `decided` issue whose implementation is landing in this PR should move to `ready` (or close). A `deferred + decided` issue with a fired trigger should drop `deferred`.
>
> Report findings in under 200 words. Say "no findings" if the diff is clean.

### Rules of engagement

- Run the review before **every** push, including fix-up pushes on a branch that already has open CI. The token cost is trivial compared to a CI round-trip.
- If the reviewer surfaces real issues, fix them before pushing. If you disagree with the reviewer, that's a judgment call — note it in the PR description so the human reviewer sees the reasoning.
- **Exceptions**: one-line typo fixes, formatting-only changes, or pushes that consist entirely of reverts. The ceremony costs more than the signal.
- Note the outcome briefly in the PR description so the human reviewer knows it ran — e.g. `pre-push review: no findings` or `pre-push review flagged X, fixed in commit abc1234`.

### Why pre-push rather than CI

Catching issues before CI runs saves minutes, dollars, and reviewer attention. A reviewer in CI would re-analyze every push on every PR (≈ 5–10× more runs for similar signal) and clutter PR threads with comments mostly ignored. Pre-push keeps the cost low and the signal high; if too many cross-cutting issues slip through, promote it to CI with a dedicated workflow.

## Reviewing an open PR

When asking a reviewer agent to review a pull request that already exists on GitHub (yours or someone else's), use the parameterised prompt below rather than re-typing the long invocation each time. The call-site invocation collapses to *"review PR NN per `CONTRIBUTING.md` §Reviewing an open PR"* — the agent reads this section and the linked docs, then runs the review. See [ADR-0008](../meta/decisions/ADR-0008-reviewer-invocation-convention.md) for the rationale (defaults, fallback chain, surface choice).

This convention is distinct from §"Pre-push self-review" above:

- **Pre-push self-review** runs against the **local diff** before the contributor pushes; the agent has the diff in hand and reports back in-conversation.
- **Reviewing an open PR** runs against the **remote PR**; the agent fetches the diff via the GitHub MCP tools, deals with CI state (running, failed, or unavailable), and — by default — posts findings as inline PR review comments.

### Parameters

Sensible defaults cover the common case. Six parameters can be overridden inline:

1. **PR number** (required) — e.g. `review PR 18`.
2. **Mode** — `bundled` (default; runs both verification *and* validation per [`REVIEW_CONTEXT.md` §"Verification vs validation"](REVIEW_CONTEXT.md)), `verification-only`, or `validation-only`. Single-mode runs produce tighter findings at lower token cost when only one is needed.
3. **Output channel** — `comments` (default; posts findings as PR review comments via the GitHub MCP tools so contributors see them inline) or `report` (returns findings in-conversation for the requester to triage before anything is posted publicly).
4. **Context-doc set** — defaults to [`REVIEW_CONTEXT.md`](REVIEW_CONTEXT.md), [`DESIGN.md`](DESIGN.md), [`SPEC.md`](SPEC.md), [`ROADMAP.md`](ROADMAP.md). Override when the PR touches a narrower or wider surface (e.g. *"plus `docs/decisions/ADR-NNNN`"* for a PR adjacent to a recent ADR whose rationale matters).
5. **CI handling** — `check-or-run` (default; see step 1 of the prompt below) or `skip` for diff-only reviews when CI isn't useful (e.g. a pure-prose docs PR with no gates that apply).
6. **Subscription** — `subscribe` (default; after posting findings the reviewer subscribes to PR activity events and follows through on subsequent pushes, review comments, and CI status changes — investigating each, pushing fixes where tractable, replying for clarifications, or escalating ambiguity) or `once` (post findings, exit; no subscription).

### Prompt template

> Review PR **NN** in the current repository.
>
> Fetch the diff, the PR description, and any linked issues. Seed yourself with [`REVIEW_CONTEXT.md`](REVIEW_CONTEXT.md) for principles and review modes (§"Verification vs validation"), [`SPEC.md`](SPEC.md) for binding contracts and the `Verified by:` mechanisms each contract names, [`DESIGN.md`](DESIGN.md) for architectural rationale, and [`ROADMAP.md`](ROADMAP.md) for phasing context.
>
> Review in **<mode>** mode (default: `bundled` — both verification *and* validation). The six prompt bullets from §"Pre-push self-review" apply in full; in addition:
>
> 1. **CI awareness.** Check the PR's CI status first:
>     - If CI ran and is green, summarise the green status in one line.
>     - If CI ran and one or more jobs failed, fetch the failing job logs and include a one-paragraph summary of each failure — the specific assertion, step, or check that failed, not just "tests failed".
>     - If CI did *not* run (workflows disabled on the fork, Actions minutes exhausted, or the PR simply hasn't triggered them yet), invoke the local equivalent per [§"Pre-push CI run"](#pre-push-ci-run-once-ci-exists) — tier 1 + tier 3 — and report the result the same way.
>     - If CI handling is set to `skip`, omit this step entirely and say so in the verdict so the reader knows no right-side mechanical checks were performed.
> 2. **Verification findings** (skip if mode = `validation-only`) — cite the binding contract or named artifact that's affected. Reference rules by their `Verified by:` mechanism in `SPEC.md` where possible, so contributors can see whether the mechanism caught the drift or whether it's an uncovered gap.
> 3. **Validation findings** (skip if mode = `verification-only`) — cite the numbered principle in `REVIEW_CONTEXT.md` or the PR's stated scope/purpose.
>
> Format findings per [`REVIEW_CONTEXT.md` §"Review output format"](REVIEW_CONTEXT.md) (summary / what works well / issues / follow-ups / verdict). Post them to the PR as **<output>** (default: `comments` — inline PR review comments via the GitHub MCP tools). When the output is `report`, return findings in-conversation instead and do not post anything publicly until the requester confirms.
>
> After posting (or surfacing) the findings, **subscribe to PR activity events** (default; skip if subscription = `once`). **Announce the subscription at the same time** — in environments where the subscription is exclusive, subscribing displaces any other watcher (e.g. an org PR Steward), and event-ownership reassignment must never be silent: the human should see something like *"I'm now watching PR NN; this took over event ownership from any existing steward"* alongside the findings. On each subsequent event — push, review comment, CI status change — re-investigate per this prompt. Push a fix where the call is clear and the change is small; reply where a clarification suffices; escalate ambiguity to the requester before acting. Refresh the review's status checklist on every event so the thread shows live state. Unsubscribe when the requester explicitly says to stop.
>
> If you find nothing actionable after the full review, say so explicitly — *"no findings; CI green; verdict approve"* — rather than going silent.

### Invocation examples

- `review PR 18 per CONTRIBUTING.md §Reviewing an open PR`
  Default: bundled mode, comments output, default context-doc set, CI-aware.

- `review PR 18 per CONTRIBUTING.md §Reviewing an open PR — verification-only, report`
  Single-mode, in-conversation output (good for a fast triage pass before deciding whether to post publicly).

- `review PR 18 per CONTRIBUTING.md §Reviewing an open PR — plus docs/decisions/ADR-0007`
  Bundled, comments, expanded context (useful for PRs adjacent to a recent ADR whose rationale the reviewer needs).

### Invocation rules

- The reviewer is a complement to human review, not a replacement. Treat its findings the way you'd treat any reviewer's: weigh them, push back where the call is yours, fix what's right.
- **In the two-session workflow (§"Two-session authoring / review workflow"), the reviewing session is comment-only** — it posts findings and never edits or pushes code. The *push-a-fix* follow-up in the prompt template above applies only to the single-session autofix / babysit model, where one session both reviews and fixes; in the two-session split the **authoring** session applies fixes (on the maintainer's *"reviews posted"*).
- Use `report` mode for the first pass on a novel PR shape so low-confidence findings don't land as public noise; switch to `comments` once you've calibrated.
- If CI is unreachable *and* a local run isn't possible (no checkout, no toolchain), say so in the review — never silently skip the right-side mechanical checks. A review that didn't verify is a validation-only review and should be labelled as such in the verdict.
- `subscribe` is the default because the natural shape of PR review is to follow through: a one-shot review that ignores follow-up pushes and CI changes misses most of the value. Use `once` for fast triage passes where the reviewer should not stay alive — typically paired with `report` output — or when another watcher (an org PR Steward, a separate session) should keep event ownership.
- **Announce subscription at take-up time.** When `subscribe` is in effect, the reviewer must surface that it has subscribed — and, in environments where the subscription is exclusive, that this displaced any prior watcher. *"I'm now watching PR NN; this took over event ownership from any existing steward"* is the shape; the human should see it alongside the findings rather than discover later that events were silently re-routed.

## Two-session authoring / review workflow

For parallel agentic development, the seed's default topology is **two sessions per track**: one authors, one reviews. They never share the three verbs below. See [ADR-0009](../meta/decisions/ADR-0009-agent-pr-lifecycle-and-two-session-workflow.md) for the rationale and rejected alternatives. The open/merge authorization this section assumes is set in [`../CLAUDE.md`](../CLAUDE.md) §5.

### Roles

- **Authoring session** — implements an item from the active phase plan's PR sequence, opens the PR, pushes fixes, and **merges on the maintainer's *"merge and proceed."*** Owns the code. It does **not** perform the open-PR review (that is the reviewing session's job); its only review duty is the **pre-push self-review of its own diff** (§"Pre-push self-review"), which is *not* the same as reviewing a PR.
- **Reviewing session** — **only reviews** (on *"review PR X"*, per §"Reviewing an open PR") and subscribes / follows through. It never edits or pushes code, and **never merges** — not even a clean, approved PR; the authoring session merges, on the maintainer's say-so.

At a glance — the three verbs, per session:

| Session | Authors / edits code | Reviews open PRs | Merges |
|---|---|---|---|
| **Authoring** | yes | no — only the pre-push self-review of its *own* diff | yes, on `merge and proceed` |
| **Reviewing** | no | yes | no |

### The loop

1. **Authoring** implements and **opens the PR** — no separate approval for in-plan work (`CLAUDE.md` §5); the pre-push self-review and pre-push CI disciplines run first.
2. **Reviewing** reviews on the maintainer's *"review PR X"*, per §"Reviewing an open PR". Never touches code.
3. Maintainer tells authoring *"reviews posted"*; it analyses the comments and pushes any fixes.
4. Repeat 2–3 until the review is clean.
5. Maintainer tells authoring *"merge and proceed"*; it merges (squash / rebase for linear history) and starts the next plan item.

### Command vocabulary

| Phrase | Session | Means |
|---|---|---|
| `review PR X` | reviewing | run §"Reviewing an open PR" against PR X |
| `reviews posted` | authoring | analyse the posted review, push fixes |
| `merge and proceed` | authoring | merge the open PR, then start the next plan item |

When two authoring sessions run in parallel and share a contract surface, prefer **one shared reviewer** over one-per-author — cross-track contract drift is exactly what a single reviewer holding both contexts catches and two siloed reviewers each miss.

The kickoff collapses to one line: *"you are the authoring / reviewing session for Phase N, per `CONTRIBUTING.md` §Two-session authoring / review workflow."* Only the variable bits (role + phase) are seeded per session; the model tier is set on the launch command rather than seeded in the prose (see §"Per-role default model tiers" below).

### Per-role default model tiers

Model tiers per role (rubric and tier→alias mapping in §"Model tier selection"): the **authoring** session launches at the model tier named by the plan row it implements (`routine` when the work is unplanned); the **reviewing** session launches at `planning-and-review`. Review deliberately runs hotter than authoring — the asymmetry [ADR-0009](../meta/decisions/ADR-0009-agent-pr-lifecycle-and-two-session-workflow.md) implied in practice, stated as the default.

## Model tier selection

A session's model tier binds at launch (`--model`, or the launcher's config)
and an agent cannot re-tier itself mid-flight: every documented
model-selection surface — `/model` during a session, `claude --model` at
startup, and the operator-side environment/settings defaults — is
operator-controlled; none is an agent tool
(<https://code.claude.com/docs/en/model-config> §"Setting your model",
retrieved 2026-08-22 via raw fetch of the page source). So the tier is
decided *before* the work starts, which makes it a plan-level concern, not a
session-level one. See
[ADR-0016](../meta/decisions/ADR-0016-model-tier-selection-plan-level.md) for
the rationale and rejected alternatives. **Model tiers are unrelated to the
CI tiers 1–4 in §"CI strategy"** — where both are in play, say "model tier".
The convention:

- **The model tier is named per PR row in the phase plan.** Each row of a
  phase plan's §"PR sequence"
  ([`docs/plans/PHASE-TEMPLATE.md`](plans/PHASE-TEMPLATE.md) §3) carries a
  **Model tier** line. The authoring session proposes it when drafting the
  plan (recommend-don't-decide, per `CLAUDE.md` §4); plan approval makes it
  part of the approved artifact; whoever launches the session for that row
  reads it there.
- **Tiers are named by task shape, never by model.** Plans, PR descriptions,
  and conversations carry the tier names below; the tier→alias mapping lives
  in this section's table and **only** here, so alias churn never rots a plan.
- **Effort before tier.** Effort levels are a finer and cheaper dial than a
  tier jump. A task that is fiddly rather than architecturally hard wants
  higher effort at the current tier, not the next tier up; escalate tier when
  the difficulty is design freedom, not fiddliness.
  - **Escalating a `complex` row.** `complex` launches at its single mapped
    alias below. Escalate that row's session to the `planning-and-review`
    alias — and say so in the PR's `Model tier:` line — when a first pass
    produced design churn rather than fiddliness. The recorded escalation is
    the audit signal the tier row exists to collect: a `complex` row that
    needed the jump is the rubric mispredicting (ADR-0016's revisit trigger).
- **Record the tier.** The PR description carries a `Model tier:` checklist
  row beside the pre-push review marker, so tier is auditable against review
  outcomes after the fact.
- **The pre-push reviewer runs at the review tier.** When launching the
  §"Pre-push self-review" subagent, pin its **model** explicitly at launch
  rather than letting it inherit the authoring session's. Effort is not
  pinnable at launch without a named subagent definition, so it inherits —
  an accepted residual, since the tier jump is the coarser, higher-value
  dial (see the "Effort before tier" bullet above). Projects that keep named subagent
  definitions can pin both via `model` / `effort` frontmatter. (No subagent
  definition file ships for this; ADR-0016 §Decision 5 has the why and the
  escape hatch.)

### Tier rubric and mapping

The alias column is the **single source of truth** for what each tier runs as;
update it here (one-line PR) when aliases move. Changing the tier *vocabulary*
is a major decision (`CLAUDE.md` §4).

| Model tier | Task shape | Alias (maintained here only) |
|---|---|---|
| `routine` | Mechanical application of an established pattern: renames, doc syncs, fixture refreshes, mirroring an approved convention across files. | `sonnet` |
| `complex` | Real design freedom inside an approved plan: a new gate, a non-trivial refactor, implementing a contract with open choices. | `sonnet` (high effort) |
| `planning-and-review` | Phase-plan drafting, ADR authoring, architecture spikes, and all reviewing-session work. | `opus` (or `opusplan` for plan-then-execute sessions) |

## Pre-push CI run (once CI exists)

Once the CI suite defined in §CI strategy lands, **run it locally before every push**, in addition to (not in place of) the pre-push self-review above. The reviewer subagent and the CI suite are complementary: the reviewer catches cross-cutting / principle / scope / terminology issues; the CI catches mechanical failures (contract-enforcement, lint, test, coverage). Both are pre-push disciplines for the same reason — catch issues before CI minutes burn, before the PR thread fills with red checks, and before reviewer attention is wasted on noise the contributor could have fixed locally.

**Rules of engagement** (mirroring the pre-push reviewer):

- Run before every push, including fix-up pushes on a branch that already has open CI.
- Fix failures before pushing; don't rely on CI to catch what the local run already would have.
- **Exceptions**: same narrow list as the reviewer — one-line typo fixes, formatting-only changes, pure reverts. The ceremony costs more than the signal for these.
- Note the outcome briefly in the PR description: `local CI: green` or `local CI: <job> failed, fixed in <sha>`.

**Commands.** The same commands your CI workflow runs should be runnable locally. If your stack has a task runner (`tox`, `nox`, `just`, `cargo`, `npm scripts`, `go` subcommands, etc.), define your CI commands there once and call them from both the workflow and the pre-push invocation. A small `Makefile` or shell script is a reasonable fallback when no ecosystem-native task runner fits. `act` is available for testing workflow YAML *changes* themselves but is overkill as the default pre-push mechanism — for most CI logic, invoking the underlying commands directly is faster and equally drift-resistant. The seed's **own** doc-CI is exactly that fallback case — heterogeneous tools (markdownlint-cli2, lychee, actionlint, two Python scripts) that no single runner drives — so the seed dogfoods [`scripts/local-ci.sh`](../scripts/local-ci.sh), which runs its active tier-3 jobs in [`ci.yml`](../.github/workflows/ci.yml) order, fail-fast. This is the seed's glue across heterogeneous doc tools, not a recommendation to prefer a wrapper over your stack's task runner; see [ADR-0004](../meta/decisions/ADR-0004-pre-push-ci-via-ecosystem-task-runner.md) (Revised) for the dogfooding decision. In a web session, [`.claude/hooks/session-start.sh`](../.claude/hooks/session-start.sh) provisions the toolchain this script drives.

**Auto-fix caution.** Linters' auto-fix modes can silently change meaning, not just form (e.g. `__pycache__` auto-"fixed" to `**pycache**`, a code span with a significant trailing space collapsed). Review auto-fix output like any other diff, and disable meaning-changing rules (e.g. markdownlint's MD038) rather than accepting their fixes.

**Scope.** Pre-push runs **tier 1 + tier 3 only**. Tier 2's runner matrix doesn't run locally (single-machine can't emulate cross-OS coverage meaningfully); tier 4 doesn't run anywhere until promoted out of "deferred". A pre-push command that takes longer than ~30 seconds will get bypassed — that's the design budget.

## When you change a contract in `docs/SPEC.md`

<!-- Adapt these steps to the actual shape of your contracts. If the project
     has only one implementation, this section collapses to a single
     "update spec and implementation in the same PR" line. -->

1. Update the spec first.
2. Update each implementation side in the same PR.
3. Add a note in `docs/SPEC.md`'s change log.
4. Refresh the prose docs that describe the contract (`DESIGN.md`, `ROADMAP.md`, per-topic notes under `docs/design/`): update what they say about the change and, where they restate contract details, make them **point** at the contract instead — restated catalogues are the documented drift surface (see §"CI strategy" §1, *drift-hardening doctrine*).
5. Run the contract-consistency checks and integration job locally before pushing.

If the contract change is motivated by an ADR, the ADR lands in the same PR too — see [`decisions/README.md`](decisions/README.md) §"What an ADR is — and isn't".

This keeps the contract and its implementations in lock-step. The contract-enforcement checks in CI catch partial updates.

## Commit and branch conventions

- Feature branches: `<!-- e.g. claude/<topic>-<short-hash> for agent work, <user>/<topic> for humans -->`.
- Commits: imperative subject line, ≤70 chars. Follow the existing style in `git log`.
- One topic per commit where practical; it keeps CI failures diagnosable.

## Issue & PR labels

Labels follow the taxonomy in [`LABELS.md`](LABELS.md). On decision-bearing issues, apply one progression-state **lifecycle** label (`discussion` / `decided` / `ready`) and, when the work is parked with a named trigger, also `deferred` (which combines with the progression state — see `LABELS.md` §Lifecycle). Apply one or more **topic** labels matching the surfaces the issue or PR touches, and an optional **phase** label (`phase-0`, `phase-1`, …) when the work belongs to a specific phase.

The live catalogue is reconciled from [`.github/labels.yml`](../.github/labels.yml) via the **Sync labels** workflow ([ADR-0001](../meta/decisions/ADR-0001-label-sync.md)); `.github/labels.yml` and `docs/LABELS.md` are paired and must change together.

Adding a new label or changing the taxonomy is a major decision (see [`../CLAUDE.md`](../CLAUDE.md) §4 and [`LABELS.md`](LABELS.md) §Adding a new label); routine labelling is not.

## Known-bug lifecycle

A documented bug that can't be fixed now still needs a **tracking artifact wired to the test surface** — otherwise "known" degrades to "forgotten". Two mechanisms exist; they encode different test cultures, and the seed deliberately does not rank them. Pick one per project and state the choice here:

- **(a) Self-healing xfail tests.** The bug ships with a tagged test (`xfail` / `KnownIssue` + assume-fail, per your framework) that *detects the buggy outcome and skips, otherwise asserts* — so it becomes a regression guard the moment the bug is fixed. The fixing PR flips the tag in the same PR. Residual debt: a stale tag downgrades the guard (a re-introduced regression reports as *filtered*, not *failed*), so tag removal is part of the fix and a stale-tag detector is worth adding when tags accumulate.
- **(b) Visible-debt markers + register.** The unverified or known-broken rule gets a visible marker in `SPEC.md` (e.g. `Verified by: none`) plus an entry in a tracking register (issues, or a severity-graded list), with no forced same-PR test. Residual debt: the marker is only as good as its honesty — see §"CI strategy" §1's `Verified by:` cross-check caveat.

**Common core, either way:** *a bug fix closes its known-bug tracking artifact — tag or marker plus register entry — in the same PR.* The PR checklist carries this row.

## Randomized-exploration testing (PBT / Monte-Carlo)

An optional convention for projects with a pure, invariant-bearing engine surface — property-based testing, Monte-Carlo campaigns, randomized V&V. The motivation: bugs live precisely in the *combinations* nobody enumerated.

The three rules:

1. **Assert invariants and oracles, never a reimplementation.** The oracle is a property the result must satisfy (exactness by construction, cross-mode equality, superset checks, round-trips) — a parallel reimplementation of the engine drifts with it and proves nothing.
2. **Seeded reproducibility, failures promoted.** Runs are seeded and reproducible; every failing case is promoted to a committed **deterministic** regression fixture (the strongest form first delta-debugs the failing seed to a minimal reproducer, then commits that).
3. **The unbounded campaign stays out of the PR gate.** A fixed-seed smoke test covers per-merge drift; the open-ended campaign is a local / scheduled / release run. Randomized wall-clock does not belong in the merge path.

**Mandatory floor (for projects that adopt this convention): periodic forced runs.** Rule 3 keeps the campaign out of the PR gate, so something else must force it to actually run — otherwise "not in CI" quietly becomes "never". The floor is a *"run the randomized campaign and triage failures"* step:

- at **every phase completion** (`docs/plans/PHASE-TEMPLATE.md` §10 Follow-ups, *Admin*, alongside the deferral sweep), and
- in the **PR checklist for major-bug-fix and major-feature PRs** — the moments the input space just changed.

**Optional hardening:** a scheduled CI run (cron) of the campaign with failures auto-filed as issues, for projects with the runner budget.

## When CI fails

- **Contract jobs failed**: almost always means two sides of a contract disagree. Fix both in the same commit.
- **Matrix job failed on one platform only**: platform-specific bug. Reproduce locally with the appropriate platform-specific tooling before guessing.
- **Hook or formatter gate failed**: run the same gate locally against all files (e.g. `pre-commit run --all-files`) and commit the fix. Never bypass hooks to push (`--no-verify` or equivalent).
- **Coverage floor breached**: add tests; do not lower the floor in the same PR that breached it.

## Warnings are actionable

CI warnings, deprecation notices, and runtime warnings should be addressed, not tolerated. They're ignored *only when they're triggered on purpose* — with an inline suppression plus a comment explaining why. Warnings that stay on the screen long enough become background noise, and then real signal disappears with them.

Concrete situations and expected responses:

- **CI action/deprecation warnings**: bump to a compatible release in a small focused PR as soon as one is available. Deadlines in the warning are real.
- **Language-level deprecation warnings**: treat like a CI failure. Either fix the call site or add a targeted suppression with a comment citing the upstream issue.
- **Test-framework warning summaries**: scan on every local run. If a new warning appears, address it in the same PR that introduced it.
- **Deliberate ignores**: use the narrowest possible suppression and drop a one-line comment saying why. No blanket `ignore-all` at the project level.

If a warning blocks progress but can't be fixed in the current PR (needs upstream release, large refactor, etc.), file an issue and link it from the suppression comment. That keeps the "ignore" from becoming permanent by accident.
