# Changelog

All notable changes to the disciplined-project-seed template are recorded here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and loosely follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

For a seed / template repo, the version semantics are about **what an adopter has to merge back into a forked project**:

- **MAJOR** — breaking change to the template shape: a renamed doc, a removed section, a reordered file structure that downstream forks must mirror.
- **MINOR** — a new convention or document added that adopters can opt into without disruption.
- **PATCH** — typo, bug fix, or wording cleanup that adopters can merge as-is.

Entries are dated by merge into `main`.

## [Unreleased]

### Added

- `.github/workflows/ci.yml` — active baseline CI doing four tier-3 jobs on the seed itself: markdown lint, internal link check (lychee in offline mode), dangling-placeholder audit, workflow YAML lint (actionlint). Tier 1 / 2 / 4 ship as commented stubs adopters extend. ([#8](https://github.com/pdlourenco/disciplined-project-seed/issues/8))
- `.github/scripts/audit-placeholders.py` — narrow render-and-scan audit for inline `<!-- ... -->` placeholders that would render as visible artifacts (the [#4](https://github.com/pdlourenco/disciplined-project-seed/pull/4) bug class). Detection patterns are data, not logic; extend `GLITCHES` when a new bug class appears.
- `.markdownlint-cli2.jsonc` — single config file (markdownlint-cli2's native format) containing the rule config, the glob (`**/*.md`), and the ignore list matching the placeholder-audit and link-check jobs. Rules disabled with rationale:
  - **MD013** (line length) — long prose lines are intentional.
  - **MD024** (no-duplicate-heading) — the seed's templates use comment-placeholder headings (`#### <!-- Example: ... -->`) that all strip to empty text and false-positive.
  - **MD033** (inline HTML) — the seed uses `<!-- ... -->` comments extensively.
  - **MD036** (no-emphasis-as-heading) — README and other docs use bold-prefix-as-list-grouping as a lighter-weight section marker than `###` headings.
  - **MD041** (first-line-heading) — the PR template starts with an HTML comment by design.
  - **MD060** (table-column-style) — too strict for variable-width content; tables render fine regardless.

  The reviewer subagent catches real drift on heading hygiene, emphasis style, etc. Uses markdownlint-cli2's single native config format (rules + glob + ignore list in one file), rather than the `.markdownlint.json` + `.markdownlintignore` pair that markdownlint-cli2 does not read.
- `docs/decisions/ADR-0002-active-trivial-ci-workflow.md` — captures the choice of an active workflow over an `.example` skeleton, the placeholder-audit detection rule, the pinning-policy reuse from ADR-0001.
- `.github/labels.yml` — machine-readable source of truth for the label catalogue, paired with `docs/LABELS.md`. ([#7](https://github.com/pdlourenco/disciplined-project-seed/issues/7))
- `.github/workflows/sync-labels.yml` — reconciles the live catalogue against `.github/labels.yml` via `EndBug/label-sync` (SHA-pinned). `workflow_dispatch` only by default; `delete-other-labels: false` by default. ([#7](https://github.com/pdlourenco/disciplined-project-seed/issues/7))
- `docs/decisions/ADR-0001-label-sync.md` — captures the decision, the conservative defaults, and explicit flip conditions.
- `CHANGELOG.md` (this file) so adopters can see what changed between any two points in the seed's evolution.
- `README.md` rewritten to lead with the seed framing: what this is, how to adopt it end-to-end, how the seed itself evolves. Adds a *How the seed evolves* section pointing at this changelog.
- `.gitignore` — generic baseline (OS metadata, editor swap files, env overrides, logs) with guidance to extend per project stack.
- `LICENSE` — MIT, shipped with the seed author as copyright holder. Adopters replace this with their own license (see README *How to adopt* step 5).
- `README.md` *How to adopt*: new step 5 calling out the LICENSE replacement.

### Changed

- `docs/CONTRIBUTING.md §"CI strategy"`: added a pointer to the shipped workflow and ADR-0002.
- `docs/LABELS.md` slimmed: removed the three catalogue tables (now duplicated by `.github/labels.yml`), kept the conventions prose (state machine, disambiguation, usage examples, add/rename/remove). LABELS.md is now "the conventions doc"; `labels.yml` is "the catalogue".
- `docs/LABELS.md` §Lifecycle: `deferred` is now a parallel modifier that combines with the progression states (`discussion` / `decided` / `ready`) rather than mutually exclusive with them. Most common combination: `decided + deferred`.
- `docs/LABELS.md` *Seeding the catalogue*: replaced the manual `gh label create` snippet with a pointer to the Sync labels workflow and the `.github/labels.yml` machine source.
- `docs/CONTRIBUTING.md §"Issue & PR labels"`: rewritten to match the new lifecycle rule and the labels.yml ↔ LABELS.md pairing.
- `docs/STRUCTURE.md`: tree now shows `.github/labels.yml`, `.github/workflows/sync-labels.yml`, `.github/workflows/ci.yml`, and `.github/scripts/audit-placeholders.py`.
- `docs/decisions/README.md`: ADR-0001 and ADR-0002 added to the index.
- `.gitignore`: promoted `__pycache__/` and `*.py[cod]` from a comment-only mention to actual ignore patterns now that the seed runs Python (the placeholder-audit script).
- `CHANGELOG.md`: added blank lines after each `### Subsection` heading so MD022 / MD032 pass cleanly. Older release sections fixed at the same time.

### Fixed

- `CLAUDE.md` §3 rendered two dangling em-dash artifacts where HTML-comment placeholders sat inline — `external contracts — .` and `gates in CI — — are not optional.` Rewrote both to neutral generic prose. ([#4](https://github.com/pdlourenco/disciplined-project-seed/pull/4))

## [0.3.0] — 2026-05-29

### Added

- Explicit rule: when an ADR motivates a SPEC change, both land in the same PR. Stated in `docs/decisions/README.md` "What an ADR is — and isn't" and mirrored in `docs/CONTRIBUTING.md §"When you change a contract"`. ([#3](https://github.com/pdlourenco/disciplined-project-seed/pull/3))

## [0.2.1] — 2026-05-24

### Removed

- Stale ADR-link scaffolding in `docs/CONTRIBUTING.md §"Pre-push self-review"` and `CLAUDE.md §2`: an HTML comment instructing consumers to write an ADR for the convention, plus a paired italic `*See <!-- ADR link --> ...*` line and a `CLAUDE.md` placeholder of the same shape. The convention is now established in prose without a back-reference; the `CLAUDE.md` sentence points directly at the CONTRIBUTING section that documents both exceptions and rationale. ([#2](https://github.com/pdlourenco/disciplined-project-seed/pull/2))

## [0.2.0] — 2026-05-23

Eight refinements back-ported from a downstream adopter (`ppqq-active`):

### Added

- `docs/LABELS.md` — single source of truth for the issue + PR label taxonomy (lifecycle / topic / phase) with default colours, disambiguation rules, usage-examples table, `gh label create` seeding snippet, add/rename/remove process.
- `docs/CONTRIBUTING.md §"Issue & PR labels"` — short section pointing at `LABELS.md`.
- `docs/CONTRIBUTING.md §"Pre-push CI run (once CI exists)"` — companion to the existing pre-push self-review for mechanical / contract / quality checks.
- `docs/decisions/README.md §"ADR lifecycle"` — ADR-first vs issue-first shapes, both first-class.
- `docs/plans/PHASE-TEMPLATE.md` — design-meeting variant note for phases that produce decisions rather than engineering output.
- `docs/DESIGN.md` positioning block — note on the slim+per-topic split shape when DESIGN outgrows ~300 lines.
- `.github/pull_request_template.md` — `Local CI:` and `Labels applied` checklist rows.

### Changed

- `CLAUDE.md §4` — `docs/LABELS.md` folded into the major-decision contract enumeration with an inline parenthetical.
- `docs/CONTRIBUTING.md §"Pre-push self-review"` reviewer prompt — lead-in instructs consumers to inline their `REVIEW_CONTEXT.md` principles as numbered assertions the reviewer can cite by number.
- `docs/STRUCTURE.md` tree — adds `LABELS.md` and the optional `docs/design/` subdirectory.
- `README.md` doc index — refreshed for `LABELS.md` and pre-push CI conventions.

([#1](https://github.com/pdlourenco/disciplined-project-seed/pull/1))

## [0.1.0] — Initial seed

Initial coordinated documentation skeleton:

- `CLAUDE.md` — agent operating rules.
- `docs/CONTRIBUTING.md` — CI strategy, pre-push review convention, ADR policy, contract-change workflow.
- `docs/DESIGN.md` — architectural rationale template.
- `docs/SPEC.md` — binding external contracts template.
- `docs/ROADMAP.md` — phased delivery plan template.
- `docs/REVIEW_CONTEXT.md` — reviewer agent seed context.
- `docs/STRUCTURE.md` — target project layout.
- `docs/plans/PHASE-TEMPLATE.md` + `docs/plans/README.md` — phase-plan template + index.
- `docs/decisions/ADR-TEMPLATE.md` + `docs/decisions/README.md` — ADR template + conventions.
- `.github/pull_request_template.md` — PR form referencing the pre-push review convention.
- `README.md` — adopter-facing overview.
