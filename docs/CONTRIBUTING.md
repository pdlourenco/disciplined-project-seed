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

Branch protection on `main` should require the following checks (configure in your host's branch protection settings):

<!-- List CI job names exactly as they appear in your workflow.
     Typical entries below; delete what doesn't apply. -->

- `<!-- Build and test (ubuntu-latest) -->`
- `<!-- Build and test (windows-latest) -->`
- `<!-- Build and test (macos-latest) -->`
- `<!-- Contract consistency -->`
- `<!-- Integration -->`
- `<!-- Pre-commit -->`

Also enable:

- **Require branches to be up to date before merging** — prevents two PRs landing contradictory changes.
- **Require linear history** (optional but recommended) — easier to bisect.
- **Do not allow force pushes to `main`**.

<!-- Branch-protection settings are not version-controlled in the repo itself.
     Keep them documented here and periodically verify that the actual
     settings match this description. -->

Feature-branch pushes may run a reduced slice of the matrix for fast feedback; full cross-platform and integration checks run on every pull request and every push to `main`.

## CI strategy

The pipeline has four concerns, in order of blast radius. Ordering matters — higher-leverage checks should fail faster than lower-leverage ones.

The seed ships an active baseline workflow at [`.github/workflows/ci.yml`](../.github/workflows/ci.yml) with four tier-3 jobs (markdown lint, internal link check, dangling-placeholder audit, workflow YAML lint) and commented stubs for tier 1, tier 2, and tier 4. Adopters extend the same file with their stack's real implementations; see [ADR-0002](decisions/ADR-0002-active-trivial-ci-workflow.md) for the choice of "active trivial workflow" over a `.example` skeleton.

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
>
> Report findings in under 200 words. Say "no findings" if the diff is clean.

### Rules of engagement

- Run the review before **every** push, including fix-up pushes on a branch that already has open CI. The token cost is trivial compared to a CI round-trip.
- If the reviewer surfaces real issues, fix them before pushing. If you disagree with the reviewer, that's a judgment call — note it in the PR description so the human reviewer sees the reasoning.
- **Exceptions**: one-line typo fixes, formatting-only changes, or pushes that consist entirely of reverts. The ceremony costs more than the signal.
- Note the outcome briefly in the PR description so the human reviewer knows it ran — e.g. `pre-push review: no findings` or `pre-push review flagged X, fixed in commit abc1234`.

### Why pre-push rather than CI

Catching issues before CI runs saves minutes, dollars, and reviewer attention. A reviewer in CI would re-analyze every push on every PR (≈ 5–10× more runs for similar signal) and clutter PR threads with comments mostly ignored. Pre-push keeps the cost low and the signal high; if too many cross-cutting issues slip through, promote it to CI with a dedicated workflow.

## Pre-push CI run (once CI exists)

Once the CI suite defined in §CI strategy lands, **run it locally before every push**, in addition to (not in place of) the pre-push self-review above. The reviewer subagent and the CI suite are complementary: the reviewer catches cross-cutting / principle / scope / terminology issues; the CI catches mechanical failures (contract-enforcement, lint, test, coverage). Both are pre-push disciplines for the same reason — catch issues before CI minutes burn, before the PR thread fills with red checks, and before reviewer attention is wasted on noise the contributor could have fixed locally.

**Rules of engagement** (mirroring the pre-push reviewer):

- Run before every push, including fix-up pushes on a branch that already has open CI.
- Fix failures before pushing; don't rely on CI to catch what the local run already would have.
- **Exceptions**: same narrow list as the reviewer — one-line typo fixes, formatting-only changes, pure reverts. The ceremony costs more than the signal for these.
- Note the outcome briefly in the PR description: `local CI: green` or `local CI: <job> failed, fixed in <sha>`.

**Commands.** <!-- Project-specific; fill in once the tech stack lands. -->

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

The live catalogue is reconciled from [`.github/labels.yml`](../.github/labels.yml) via the **Sync labels** workflow ([ADR-0001](decisions/ADR-0001-label-sync.md)); `.github/labels.yml` and `docs/LABELS.md` are paired and must change together.

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
