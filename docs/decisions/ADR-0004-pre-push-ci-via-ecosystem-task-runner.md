# ADR-0004 — Pre-push CI invocation via the ecosystem's own task runner (not `act`, not a wrapper)

## Status

Accepted — 2026-05-31.

## Context

[`docs/CONTRIBUTING.md` §"Pre-push CI run"](../CONTRIBUTING.md) carries a `**Commands.**` slot for the local invocation the agent runs before every push. Until this ADR, the slot was a bare placeholder (`<!-- Project-specific; fill in once the tech stack lands. -->`) — adopters were left to design the mechanism from scratch.

The seed could ship a convention. The question is *what* convention. Surfaced and decided in [#10](https://github.com/pdlourenco/disciplined-project-seed/issues/10).

The initial framing (A — Makefile target, B — `act`, C — shell script, D — no scaffolding) assumed pre-push CI needs a *wrapper layer* invoking the commands. The reframe that landed: that assumption is usually wrong. Most ecosystems already have a task runner — `tox` / `nox` / `just` for Python, `cargo` for Rust, `npm scripts` for JavaScript, `go` subcommands for Go. The CI workflow can call into those task names directly, and the pre-push command can call into the same task names. There's no third artifact to drift.

This shifts the problem from *"which wrapper does the seed recommend?"* to *"where do the commands live?"* — and the ecosystem-native answer dissolves the drift question entirely.

A separate but related insight: pre-push CI has to be **fast by design**. A command that takes more than ~30 seconds gets bypassed. The seed's CI workflow ([ADR-0002](ADR-0002-active-trivial-ci-workflow.md)) ships four tiers; not all of them belong pre-push.

## Decision

The `**Commands.**` slot in `CONTRIBUTING.md` §"Pre-push CI run" gets concrete guidance, not a wrapper recommendation (full prose lives in `CONTRIBUTING.md`; verbatim quotes below):

> The same commands your CI workflow runs should be runnable locally. If your stack has a task runner (`tox`, `nox`, `just`, `cargo`, `npm scripts`, `go` subcommands, etc.), define your CI commands there once and call them from both the workflow and the pre-push invocation. A small `Makefile` or shell script is a reasonable fallback when no ecosystem-native task runner fits. `act` is available for testing workflow YAML *changes* themselves but is overkill as the default pre-push mechanism — for most CI logic, invoking the underlying commands directly is faster and equally drift-resistant. The seed's own `ci.yml` currently inlines these commands directly (the fallback path) because the seed has no stack with a task runner yet; see this ADR for the reasoning and the revisit conditions for dogfooding the task-runner pattern.

And a **Scope** clause:

> Pre-push runs **tier 1 + tier 3 only**. Tier 2's runner matrix doesn't run locally (single-machine can't emulate cross-OS coverage meaningfully); tier 4 doesn't run anywhere until promoted out of "deferred". A pre-push command that takes longer than ~30 seconds will get bypassed — that's the design budget.

No new on-disk artifact ships with this ADR — the change is prose in `CONTRIBUTING.md`. The seed doesn't ship a `Makefile`, doesn't depend on `act`, doesn't ship a wrapper script. The convention is: use what your ecosystem already provides.

## Consequences

- **The pre-push command is whatever the adopter's task runner is.** `tox -e lint,test` for Python with tox; `cargo fmt --check && cargo clippy && cargo test` for Rust; `pnpm lint && pnpm typecheck && pnpm test` for Node; `go vet ./... && go test ./...` for Go. The seed itself runs `python3 .github/scripts/audit-placeholders.py` plus the markdown / link / workflow gates — there's no single one-liner that captures them, but the workflow's own `run:` lines are the source of truth.
- **No `Makefile` or shell wrapper ships with the seed.** Adding one would create the shadow-scaffolding problem the ADR's reframe was designed to dissolve. Adopters whose ecosystem genuinely lacks a task runner can write a `Makefile` themselves; the seed doesn't enforce that.
- **`act` is reframed as a niche tool, not the default.** Documented in §Decision; not banned, just not recommended as the pre-push mechanism for most adopters. Adopters who specifically need workflow-YAML-fidelity testing can layer `act` on top.
- **Tier-scope discipline is load-bearing and stated explicitly.** Tier 1 + 3 pre-push; tier 2 ships only on CI (the runner matrix is what makes it meaningful); tier 4 doesn't run anywhere until promoted. Without this carve-out, adopters who try to run the full workflow locally hit the 30-second budget and abandon the convention.
- **No new external dependency.** Per `CLAUDE.md` §4, this PR is still a major decision (it locks in a sticky trade-off about which wrapper layer the seed *doesn't* recommend), but no `Makefile`, `act`, or script gets shipped.
- **Revisit conditions.** If workflow YAML changes become frequent enough that CI-roundtripping them is genuinely painful, the cost calculus for `act` shifts and the seed should add an `act`-as-upgrade-path note. If the seed itself adds a non-trivial Python or other stack (beyond the placeholder-audit script), the "use the ecosystem's task runner" guidance applies to the seed too — at which point a `pyproject.toml` (or equivalent) with a `[tool.tox]` (or equivalent) section dogfoods the convention.

## Alternatives considered

The lettering matches the issue thread on [#10](https://github.com/pdlourenco/disciplined-project-seed/issues/10) so anyone re-reading the discussion can map decisions back to the recommendation.

- **A — `Makefile` target.** `make ci` runs the same commands as the workflow. Familiar; no extra dependency (`make` is universal). Rejected as the default: it's a wrapper layer that duplicates the ecosystem's task runner. The Makefile and the workflow can drift if both define the same logic in slightly different ways. Acceptable as a fallback when no ecosystem-native runner fits.
- **B — `act` (nektos/act).** Pre-push runs the actual workflow YAML locally via Docker. Single source of truth (the YAML); no shadow scaffolding. **Rejected as the default** for four reasons: (1) Docker Desktop has commercial licensing constraints (Mac/Windows, larger orgs) that make assuming Docker presence in the seed a real assumption, not a freebie; (2) `act`'s "single source of truth" is partial — the YAML is shared but the execution environment isn't, so a workflow that passes `act` can still fail real Actions and vice versa; (3) `act` is slow on the hot path (image pulls, container spin-up per job, no cache) — pre-push commands that exceed the 30-second budget get bypassed; (4) `act`'s failure modes are debugging-heavy and unrelated to project logic (Docker networking, image compatibility, version drift). Reframed as a niche tool for workflow-YAML-changes testing rather than the default pre-push mechanism.
- **C — shell script (`scripts/pre-push-ci.sh`).** Hand-written script with the same commands as the workflow. More flexibility than `Makefile` (conditionals, env handling); same shadow-scaffolding cost. Rejected as the default for the same wrapper-duplication reason as A; acceptable as a fallback.
- **D — no scaffolding, document the pattern.** Closest to the chosen path. The issue's original framing of D was "pick what fits your stack" — too vague. **Modified D** (chosen) is D with concrete guidance: the ecosystem's task runner *is* the recommended pattern, and the seed says so explicitly.
- **`act` as the default, A/B/C as upgrade paths.** Considered and rejected — the cost/benefit math is reversed for most adopters. `act` adds Docker dependency + slowness for cases where direct invocation works and is faster.
- **A `Makefile` shipped with the seed itself.** Considered. Rejected because the seed doesn't yet have a stack that needs one — the placeholder-audit script is invoked directly via `python3`. Adopters whose stack lacks a task runner can write their own `Makefile`; the seed shouldn't ship one that gets ignored or repurposed in ways the seed didn't anticipate.
