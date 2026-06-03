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

**Drift detection.** [`.github/workflows/check-branch-protection.yml`](../.github/workflows/check-branch-protection.yml) runs weekly (Sundays 10:00 UTC), compares the live config to the YAML using the default `GITHUB_TOKEN`'s read-only scope, and opens an issue if anything drifts. If you edited the YAML and forgot to re-apply, the workflow will tell you within a week; manual edits to `Settings → Branches` get caught too.

**Adopters:** the YAML ships with the seed's own four `Tier 3 — …` required contexts (from [`ci.yml`](../.github/workflows/ci.yml)) and conservative defaults (`required_linear_history: true`, `allow_force_pushes: false`, `allow_deletions: false`, `required_conversation_resolution: true`, `enforce_admins: false`, no required reviews). Per-field rationale is inline in the YAML; flip `enforce_admins`, configure `required_pull_request_reviews`, or add status-check contexts as your team and CI grow.

Feature-branch pushes may run a reduced slice of the matrix for fast feedback; full cross-platform and integration checks run on every pull request and every push to `main`.

## CI strategy

The pipeline has four concerns, in order of blast radius. Ordering matters — higher-leverage checks should fail faster than lower-leverage ones.

The seed ships an active baseline workflow at [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) with four tier-3 jobs (markdown lint, internal link check, dangling-placeholder audit, workflow YAML lint) and commented stubs for tier 1, tier 2, and tier 4. Adopters extend the same file with their stack's real implementations; see [ADR-0002](../meta/decisions/ADR-0002-active-trivial-ci-workflow.md) for the choice of "active trivial workflow" over a `.example` skeleton.

### 1. Contract enforcement

<!-- The highest-leverage tests in the repo: they catch silent drift between
     independently developed components. Name them concretely with what they
     check and what drift they prevent.

     Common patterns:

     - A test that parses a field table out of SPEC.md (or a canonical schema
       file) and asserts it matches the code-side schema definition.

     - Version-pinning tests that ensure two implementations of a shared
       dependency agree on a minor version.

     - An integration job that exercises one side's writes against another
       side's reads with a real on-disk artifact.

     If your project has no cross-component contracts, delete this tier and
     the four-tier structure collapses to three. -->

- **`<!-- contract-consistency-test -->`** — <!-- what it asserts; what drift it catches -->
- **`<!-- version-pinning-test -->`** — <!-- which versions it pins together, why -->
- **`<!-- integration-job -->`** — <!-- what writes, what reads, what assertion -->

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

## Workflow permissions

Any shipped workflow that uses `actions/checkout` (or otherwise reads repo contents) must list `contents: read` explicitly in its `permissions:` block. A `permissions:` block sets every unlisted scope to `none`, so the implicit `contents: none` breaks `actions/checkout` on private repos with a 404 — silently fine on public repos because unauthenticated reads work, which is how this class of bug can hide until a private adopter hits it. `contents: read` is harmless on public repos and required on private — a strict improvement with no downside. The seed's own `sync-labels.yml` and `check-branch-protection.yml` both ship with the explicit `contents: read`; extend the same discipline to any new workflow.

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
- Use `report` mode for the first pass on a novel PR shape so low-confidence findings don't land as public noise; switch to `comments` once you've calibrated.
- If CI is unreachable *and* a local run isn't possible (no checkout, no toolchain), say so in the review — never silently skip the right-side mechanical checks. A review that didn't verify is a validation-only review and should be labelled as such in the verdict.
- `subscribe` is the default because the natural shape of PR review is to follow through: a one-shot review that ignores follow-up pushes and CI changes misses most of the value. Use `once` for fast triage passes where the reviewer should not stay alive — typically paired with `report` output — or when another watcher (an org PR Steward, a separate session) should keep event ownership.
- **Announce subscription at take-up time.** When `subscribe` is in effect, the reviewer must surface that it has subscribed — and, in environments where the subscription is exclusive, that this displaced any prior watcher. *"I'm now watching PR NN; this took over event ownership from any existing steward"* is the shape; the human should see it alongside the findings rather than discover later that events were silently re-routed.

## Pre-push CI run (once CI exists)

Once the CI suite defined in §CI strategy lands, **run it locally before every push**, in addition to (not in place of) the pre-push self-review above. The reviewer subagent and the CI suite are complementary: the reviewer catches cross-cutting / principle / scope / terminology issues; the CI catches mechanical failures (contract-enforcement, lint, test, coverage). Both are pre-push disciplines for the same reason — catch issues before CI minutes burn, before the PR thread fills with red checks, and before reviewer attention is wasted on noise the contributor could have fixed locally.

**Rules of engagement** (mirroring the pre-push reviewer):

- Run before every push, including fix-up pushes on a branch that already has open CI.
- Fix failures before pushing; don't rely on CI to catch what the local run already would have.
- **Exceptions**: same narrow list as the reviewer — one-line typo fixes, formatting-only changes, pure reverts. The ceremony costs more than the signal for these.
- Note the outcome briefly in the PR description: `local CI: green` or `local CI: <job> failed, fixed in <sha>`.

**Commands.** The same commands your CI workflow runs should be runnable locally. If your stack has a task runner (`tox`, `nox`, `just`, `cargo`, `npm scripts`, `go` subcommands, etc.), define your CI commands there once and call them from both the workflow and the pre-push invocation. A small `Makefile` or shell script is a reasonable fallback when no ecosystem-native task runner fits. `act` is available for testing workflow YAML *changes* themselves but is overkill as the default pre-push mechanism — for most CI logic, invoking the underlying commands directly is faster and equally drift-resistant. The seed's own [`ci.yml`](../.github/workflows/ci.yml) currently inlines these commands directly (the fallback path) because the seed has no stack with a task runner yet; see [ADR-0004](../meta/decisions/ADR-0004-pre-push-ci-via-ecosystem-task-runner.md) for the reasoning and the revisit conditions for dogfooding the task-runner pattern.

**Scope.** Pre-push runs **tier 1 + tier 3 only**. Tier 2's runner matrix doesn't run locally (single-machine can't emulate cross-OS coverage meaningfully); tier 4 doesn't run anywhere until promoted out of "deferred". A pre-push command that takes longer than ~30 seconds will get bypassed — that's the design budget.

## When you change a contract in `docs/SPEC.md`

<!-- Adapt these steps to the actual shape of your contracts. If the project
     has only one implementation, this section collapses to a single
     "update spec and implementation in the same PR" line. -->

1. Update the spec first.
2. Update each implementation side in the same PR.
3. Add a note in `docs/SPEC.md`'s change log.
4. Run the contract-consistency checks and integration job locally before pushing.

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

## When CI fails

- **Contract jobs failed**: almost always means two sides of a contract disagree. Fix both in the same commit.
- **Matrix job failed on one platform only**: platform-specific bug. Reproduce locally with the appropriate platform-specific tooling before guessing.
- **Pre-commit failed**: run `pre-commit run --all-files` locally and commit the fix. Do not bypass with `--no-verify`.
- **Coverage floor breached**: add tests; do not lower the floor in the same PR that breached it.

## Warnings are actionable

CI warnings, deprecation notices, and runtime warnings should be addressed, not tolerated. They're ignored *only when they're triggered on purpose* — with an inline suppression plus a comment explaining why. Warnings that stay on the screen long enough become background noise, and then real signal disappears with them.

Concrete situations and expected responses:

- **CI action/deprecation warnings**: bump to a compatible release in a small focused PR as soon as one is available. Deadlines in the warning are real.
- **Language-level deprecation warnings**: treat like a CI failure. Either fix the call site or add a targeted suppression with a comment citing the upstream issue.
- **Test-framework warning summaries**: scan on every local run. If a new warning appears, address it in the same PR that introduced it.
- **Deliberate ignores**: use the narrowest possible suppression and drop a one-line comment saying why. No blanket `ignore-all` at the project level.

If a warning blocks progress but can't be fixed in the current PR (needs upstream release, large refactor, etc.), file an issue and link it from the suppression comment. That keeps the "ignore" from becoming permanent by accident.
