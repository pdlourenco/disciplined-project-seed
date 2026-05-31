# ADR-0002 — Ship an active trivial CI workflow with four-tier framing in comments

## Status

Accepted — 2026-05-31.

## Context

[`docs/CONTRIBUTING.md §"CI strategy"`](../CONTRIBUTING.md) describes a four-tier pipeline in detail: tier 1 (contract enforcement), tier 2 (cross-platform matrix), tier 3 (code quality), tier 4 (deferred). Until this ADR, the seed shipped **no** `.github/workflows/ci.yml` skeleton — every adopter rebuilt the YAML from the prose.

Surfaced and decided in [#8](https://github.com/pdlourenco/disciplined-project-seed/issues/8). The proximate trigger was [#4](https://github.com/pdlourenco/disciplined-project-seed/pull/4): a CLAUDE.md fix for two `<!-- ... -->` placeholders that rendered as visible em-dash artifacts. The seed had no automated gate for that bug class. A CI workflow running on the seed itself would have caught it at the source.

## Decision

Ship `.github/workflows/ci.yml` as an **active** workflow (not `.example` / `.template`) doing trivial-but-real quality checks on the seed itself:

- **Markdown lint** via `DavidAnson/markdownlint-cli2-action` (SHA-pinned to v23.2.0).
- **Internal link check** via `lycheeverse/lychee-action` in offline mode (SHA-pinned to v2.8.0). External URLs deliberately not checked — they're flaky in CI and a separate scheduled job can cover them when adopters opt in.
- **Dangling-placeholder audit** via `.github/scripts/audit-placeholders.py` — closes the [#4](https://github.com/pdlourenco/disciplined-project-seed/pull/4) regression class. Detection is narrow on purpose: simulate rendering (strip complete `<!-- ... -->` from each line), then scan for the specific glitch patterns `— .` and `— —` that PR #4 produced. The seed's structural templates (heading placeholders, label-style placeholders, table cells) render cleanly even unfilled and are not flagged.
- **Workflow YAML lint** via `rhysd/actionlint` Docker image (tag-pinned to 1.7.12).

The four-tier framing lives in **comments inside `ci.yml`** rather than in separate `.example` files — placeholder stubs for tier 1, tier 2, and tier 4 sit next to the active tier 3 jobs, so adopters extend the same file rather than copying a template.

## Consequences

- **The seed's discipline is self-applied.** "Named gates for named drift" now operates on the seed itself — markdown drift, link drift, placeholder drift, workflow YAML drift each have a named gate.
- **Adopters inherit a working CI on day one.** No `.example` to rename, no placeholder to fill before any job runs. The forcing function for filling in real CI is *"my contract test isn't actually running"*, not *"I have a file with placeholder comments I should probably get to"*.
- **The placeholder-audit script is narrow by design.** It catches PR #4's pattern (`— .` and `— —`) and intentionally not every conceivable rendering artifact. If a new bug class shows up, extend `GLITCHES` in `audit-placeholders.py` — the rule is data, not logic.
- **The audit needs a skip list for template files.** Files that exist specifically as fill-in templates for adopters (PHASE-TEMPLATE, ADR-TEMPLATE, SPEC, DESIGN, ROADMAP, REVIEW_CONTEXT, STRUCTURE) would false-positive otherwise. The same skip list is duplicated across **three** places — the `find` invocations in the `link-check` and `placeholder-audit` jobs of `ci.yml`, and the `ignores` array in `.markdownlint-cli2.jsonc` — and must be kept in sync by hand. The duplication is documented rather than eliminated because the natural shared format (a flat list of paths) doesn't fit cleanly into both shell `find` invocations and the cli2 config's JSON schema; promotion would require a generator script. Promote when (a) a fourth consumer is added, or (b) the skip list drifts across the three copies in any PR review.
- **Pinning policy follows ADR-0001.** First-party `actions/*` tag-pinned; third-party SHA-pinned; Docker image `rhysd/actionlint` tag-pinned (the upstream repo isn't a GitHub Action, the Docker image is the supported invocation path).
- **`.markdownlint-cli2.jsonc` at the repo root** holds the rule config, glob, and ignore list. Disabled rules, each with rationale: MD013 (long prose lines), MD024 (comment-placeholder headings strip to empty and false-positive as duplicates; CHANGELOG legitimately reuses `### Added`), MD033 (the seed uses `<!-- ... -->` extensively), MD036 (bold-prefix list grouping used as a light section marker), MD041 (PR template opens with an HTML comment by design), MD060 (variable-width table columns). The single-file `cli2.jsonc` format replaces the `.markdownlint.json` + `.markdownlintignore` pair that markdownlint-cli2 ignores.

## Alternatives considered

The lettering matches the issue thread on [#8](https://github.com/pdlourenco/disciplined-project-seed/issues/8) so anyone re-reading the discussion can map decisions back to the recommendation.

- **A — single `ci.yml.example` skeleton mirroring the four-tier structure with placeholder `run: # fill in command` steps.** Rejected: a YAML skeleton with placeholder commands is dead weight until renamed and filled in. `run: # fill in command` either silently no-ops or breaks YAML. Adopters can copy without ever testing that their adaptation works. The placeholder pattern works in prose docs but not in executable YAML.
- **B — multiple stack-specific examples (`ci.python.yml.example`, `ci.rust.yml.example`, `ci.js.yml.example`).** Rejected for the seed itself but worth keeping in mind: "favourites are the most common stacks" is a fair reframe, and the seed could ship a follow-on `examples/` directory if adoption signal shows real demand. Not in this PR's scope.
- **C — minimal `ci.yml.example` with just matrix + lint + test, no four-tier framing.** Rejected: drops the seed's own conceptual discipline. The four tiers are how the seed thinks about CI; the workflow file is the place that thinking is most actionable.
- **D — do nothing; adopters keep building from prose.** Rejected: friction is real and the cost of the fix is low. PR #4 was a concrete proof that the seed itself benefits from CI; deferring leaves that gap open.
- **`act` as the seed's invocation mechanism.** Considered for pre-push tooling and addressed separately in [#10](https://github.com/pdlourenco/disciplined-project-seed/issues/10). Not relevant here — this is about which workflow ships, not how it's run locally.
- **Audit rule based on "non-whitespace both sides of the placeholder".** Rejected during implementation: the rule false-positives on the seed's structural templates (heading placeholders, label-style placeholders, table cells). The render-and-scan-for-glitches approach used here is narrower but catches the specific bug class PR #4 represented.
- **Per-file audit allowlist file (e.g. `.placeholder-audit-skip`).** Rejected as overengineering for now: the workflow's `find` invocation is the skip list. If the seed ever has many more template files, promote the inline skip list to a checked-in config file.
