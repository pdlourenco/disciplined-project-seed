# Changelog

All notable changes to the disciplined-project-seed template are recorded here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and loosely follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

For a seed / template repo, the version semantics are about **what an adopter has to merge back into a forked project**:

- **MAJOR** — breaking change to the template shape: a renamed doc, a removed section, a reordered file structure that downstream forks must mirror.
- **MINOR** — a new convention or document added that adopters can opt into without disruption.
- **PATCH** — typo, bug fix, or wording cleanup that adopters can merge as-is.

Entries are dated by merge into `main`.

## [Unreleased]

### Added
- `CHANGELOG.md` (this file) so adopters can see what changed between any two points in the seed's evolution.
- `README.md` rewritten to lead with the seed framing: what this is, how to adopt it end-to-end, how the seed itself evolves. Adds a *How the seed evolves* section pointing at this changelog.

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
