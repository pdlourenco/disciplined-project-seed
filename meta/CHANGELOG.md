# Changelog (seed-meta)

All notable changes to the disciplined-project-seed *itself* are recorded here. This is the seed's evolution log; an adopter's *own* project changelog lives at the repo root in `CHANGELOG.md`. See [`README.md`](README.md) for what the `meta/` directory is and how adopters handle it.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and loosely follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

For a seed / template repo, the version semantics are about **what an adopter has to merge back into a forked project**:

- **MAJOR** — breaking change to the template shape: a renamed doc, a removed section, a reordered file structure that downstream forks must mirror.
- **MINOR** — a new convention or document added that adopters can opt into without disruption.
- **PATCH** — typo, bug fix, or wording cleanup that adopters can merge as-is.

Entries are dated by merge into `main`.

## [Unreleased]

### Added

- `.github/scripts/check-bp-contexts.py` + a tier-3 CI job + a 5th required context in `.github/branch-protection.yml` (`"Tier 3 — Branch-protection contexts consistency"`) — static, token-free, merge-time consistency check asserting every `required_status_checks.contexts` entry in `branch-protection.yml` names a live job in `ci.yml` (subset check). Catches the most common drift mode — *CI job renamed, contexts didn't follow* — before the gate breaks (a context with no matching job leaves the merge gate stuck pending forever). Pre-deploy complement to the post-deploy runtime checks in `check-branch-protection.yml`. Forward-ported from a downstream adopter (PPQQ). **Adopters must re-run `scripts/setup-branch-protection.sh`** after merging so the new required context lands on live protection. ([ADR-0005](decisions/ADR-0005-branch-protection-as-code-classic.md))
- `docs/CONTRIBUTING.md §"Reviewing an open PR"` — parameterised reviewer-invocation convention so contributors and agents don't re-type the long prompt each time. Call-site collapses to *"review PR NN per `CONTRIBUTING.md` §Reviewing an open PR"*. Six parameters (PR number, mode, output channel, context-doc set, CI handling, subscription). Distinct from §"Pre-push self-review" (local diff, in-conversation report); this one fetches the remote diff, deals with CI state (summarises if CI ran; falls back to a local tier-1+3 run per §"Pre-push CI run" if CI didn't), by default posts findings as inline PR review comments, and by default subscribes to PR activity events so it follows through on subsequent pushes / review comments / CI changes. References the V&V modes from `REVIEW_CONTEXT.md` and the `Verified by:` mechanisms from `SPEC.md` so verification-mode findings can cite the right-side mechanism that should have caught the drift. ([ADR-0008](decisions/ADR-0008-reviewer-invocation-convention.md))
- `meta/decisions/ADR-0008-reviewer-invocation-convention.md` — captures the defaults (`bundled` / `comments` / `check-or-run` / `subscribe`), the CI-handling fallback chain (green → summarise; red → fetch logs; unreachable → local tier-1+3 per ADR-0004; `skip` → disclose), the follow-through-by-default subscription stance with the announce-at-subscribe-time discipline (in environments where subscription is exclusive, `subscribe` takes over event ownership from any prior watcher — the reviewer must announce the take-over rather than subscribe silently), and the surface-choice rationale (`CONTRIBUTING.md` not `REVIEW_CONTEXT.md`). Rejected alternatives: leave invocation ad-hoc, put in `REVIEW_CONTEXT.md`, create a dedicated `REVIEWING.md`, `report` as default output, `validation-only` as default mode, no `skip` option, `once` as default subscription.
- `docs/RISKS.md` — optional risk register template, same deferred-with-conditions shape applied at the risk level (Risk → Probability × Impact → Mitigation → Residual → Revisit trigger). Header explicitly says "skip unless regulated / life-safety / hard-reliability"; the seed's first explicitly-optional document. Added to the three template skip lists (`ci.yml` placeholder-audit `find`, `ci.yml` link-check `find`, `.markdownlint-cli2.jsonc` `ignores`) since the example risk entries ship with placeholders. ([ADR-0007](decisions/ADR-0007-v-cycle-additions.md))
- `meta/decisions/ADR-0007-v-cycle-additions.md` — captures the V-cycle / ECSS framing as the lens, the three chosen additions (V&V split, per-rule verified-by, optional RISKS.md) plus a lineage paragraph, and the deferral of stable SPEC IDs and multi-doc baseline versioning with named revisit conditions.
- `docs/REVIEW_CONTEXT.md` §"Verification vs validation" — names two review modes (verification = matches contracts / named artifacts; validation = matches principles / intent). The reviewer agent can be invoked in either or both; default is both. Includes a one-paragraph V-cycle / ECSS lineage note that disclaims the heavyweight ceremony.
- `docs/SPEC.md` §"Verification (right-side mechanisms)" — convention that every binding rule names the mechanism gating it (specific test, integration job, manual inspection, ADR-driven review). A rule with `Verified by: <!-- nothing -->` is visible debt reviewers flag in verification mode. Convention applied to §3 Critical rules template as the demonstration; optional stable-SPEC-IDs note for adopters whose SPECs already need it.
- `.github/branch-protection.yml` — desired state for `main`'s branch protection, classic GitHub schema. Includes the four `Tier 3 — …` required status-check contexts from `ci.yml`, `required_linear_history: true`, `allow_force_pushes: false`, `allow_deletions: false`, `required_conversation_resolution: true`, and conservative defaults. Per-field rationale inline. ([#11](https://github.com/pdlourenco/disciplined-project-seed/issues/11))
- `scripts/setup-branch-protection.sh` — applies `.github/branch-protection.yml` to GitHub using the operator's `gh auth` credentials. No admin PAT secret stored in the repo. Shows the normalized diff against live config before applying. ([#11](https://github.com/pdlourenco/disciplined-project-seed/issues/11))
- `scripts/normalize-branch-protection.jq` — shared jq filter used by both the apply script and the drift workflow. Single source of truth for *what counts as the same state*: unwraps the live API's `{enabled: bool}` objects to flat booleans (using `type == "object"` to avoid `jq`'s `false`-as-null pitfall), sorts `contexts` arrays, extracts comparable subfields of `required_pull_request_reviews`. ([#11](https://github.com/pdlourenco/disciplined-project-seed/issues/11))
- `.github/workflows/check-branch-protection.yml` — weekly read-only drift check using the default `GITHUB_TOKEN`. Uses the runner's pre-installed Python + PyYAML for the YAML→JSON conversion (avoids fetching a yq binary into a workflow that holds `issues: write`, inconsistent with ADR-0001's pinning policy). Falls back to no-label issue creation on fresh forks where the label catalogue isn't seeded yet. Opens an issue if live branch protection drifts from the YAML, or if no live protection exists at all. ([#11](https://github.com/pdlourenco/disciplined-project-seed/issues/11))
- `meta/decisions/ADR-0005-branch-protection-as-code-classic.md` — captures the B + drift-detection + classic-schema decision, the permissions-asymmetry contrast with ADR-0001 (default `GITHUB_TOKEN` reads branch protection but cannot write), the rulesets-as-upgrade-path note, and the alternatives the issue thread considered (A through D + two sub-decisions).
- `meta/decisions/ADR-0004-pre-push-ci-via-ecosystem-task-runner.md` — captures the modified-D decision for pre-push CI tooling: use the ecosystem's own task runner (`tox` / `cargo` / `npm scripts` / `go` subcommands) as the single source of truth called from both the CI workflow and the pre-push invocation; no `Makefile` / `act` / shell-script wrapper ships with the seed; `act` reframed as a niche tool for workflow-YAML-changes testing; tier 1 + tier 3 only pre-push with a ~30-second design budget.
- `.github/ISSUE_TEMPLATE/decision-proposal.yml` — YAML form template for issue-first ADR proposals. Structured fields for Context / Alternatives / Where it lands / Recommendation. Pre-applies `discussion` + `design`. ([#9](https://github.com/pdlourenco/disciplined-project-seed/issues/9))
- `.github/ISSUE_TEMPLATE/bug.yml` — YAML form template for bug reports. Structured fields for expected / actual / reproduction / affected surfaces. Pre-applies `bug` only (no lifecycle per `LABELS.md` §Lifecycle). ([#9](https://github.com/pdlourenco/disciplined-project-seed/issues/9))
- `meta/decisions/ADR-0003-labels-applied-via-reviewer.md` — captures the C + lightweight B + A deferred decision: reviewer-prompt extension for label-vs-diff and lifecycle currency, issue templates with pre-applied labels, no CI gate (external contributors can't apply labels; enforcement is the wrong frame).
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
- `meta/decisions/ADR-0002-active-trivial-ci-workflow.md` — captures the choice of an active workflow over an `.example` skeleton, the placeholder-audit detection rule, the pinning-policy reuse from ADR-0001.
- `.github/labels.yml` — machine-readable source of truth for the label catalogue, paired with `docs/LABELS.md`. ([#7](https://github.com/pdlourenco/disciplined-project-seed/issues/7))
- `.github/workflows/sync-labels.yml` — reconciles the live catalogue against `.github/labels.yml` via `EndBug/label-sync` (SHA-pinned). `workflow_dispatch` only by default; `delete-other-labels: false` by default. ([#7](https://github.com/pdlourenco/disciplined-project-seed/issues/7))
- `meta/decisions/ADR-0001-label-sync.md` — captures the decision, the conservative defaults, and explicit flip conditions.
- `CHANGELOG.md` (this file) so adopters can see what changed between any two points in the seed's evolution.
- `README.md` rewritten to lead with the seed framing: what this is, how to adopt it end-to-end, how the seed itself evolves. Adds a *How the seed evolves* section pointing at this changelog.
- `.gitignore` — generic baseline (OS metadata, editor swap files, env overrides, logs) with guidance to extend per project stack.
- `LICENSE` — MIT, shipped with the seed author as copyright holder. Adopters replace this with their own license (see README *How to adopt* step 6).
- `README.md` *How to adopt*: new step 6 calling out the LICENSE replacement.

### Changed

- `.github/labels.yml` header + `docs/LABELS.md §"Adding a new label"` — stated GitHub's 100-character cap on label `description` values once in each surface, so adopters extending the catalogue see the limit at write time. No current entry exceeds the limit (the longest, `documentation`, sits at 96); the rule is preventative — GitHub's label API rejects longer values. Surfaced by a downstream adopter.
- `README.md §"How the documents relate"` — added a paragraph surfacing the V-cycle / ECSS lineage at the entry doc: left side commits to *what* (DESIGN, SPEC, ROADMAP, plans, ADRs); right side verifies *built right* (contract-consistency tests, four-tier CI, pre-push and PR-stage reviewer-subagent conventions, the `Verified by:` annotation, branch protection). Names the discipline (visible debt for unverified rules; validation-only reviews must say so in the verdict) and links to ADR-0007. Kept to one paragraph — the framing is acknowledged, the ECSS-grade ceremony is explicitly disclaimed. The lineage clauses (here, in ADR-0007's Context, and in `docs/REVIEW_CONTEXT.md` §"Verification vs validation") link the [V-model Wikipedia page](https://en.wikipedia.org/wiki/V-model) for prior-art onramp without embedding any image — the canonical V-model image is the engineering-lifecycle V, which doesn't match the seed's doc-set V (engineering-V vertex is *implementation*; seed-V vertex doesn't exist because the seed is scaffolding, not implementation). ([ADR-0007](decisions/ADR-0007-v-cycle-additions.md))
- `docs/CONTRIBUTING.md §"Reviewer prompt"` — added intro paragraph naming the two review modes from `REVIEW_CONTEXT.md` and how to invoke the agent in one mode for tighter findings. The numbered bullets below stay as the bundled-mode prompt. ([ADR-0007](decisions/ADR-0007-v-cycle-additions.md))
- `docs/STRUCTURE.md` — tree shows `docs/RISKS.md` as an optional file.
- **Structural: extracted seed-meta into `meta/`.** The seed's own ADRs (ADR-0001–ADR-0005) moved from `docs/decisions/` to `meta/decisions/`; the seed's own CHANGELOG history moved from the repo root to `meta/CHANGELOG.md`; the root `CHANGELOG.md` reset to a clean Keep-a-Changelog template for the adopter's own project history. `docs/decisions/` is now the adopter's namespace, starting fresh at their ADR-0001. Captured in [ADR-0006](decisions/ADR-0006-meta-folder-for-seed-history.md). Adopters strip-or-keep `meta/` per the root README's *How to adopt* step.
- `docs/CONTRIBUTING.md §"Required status checks"`: rewritten to point at `.github/branch-protection.yml` as the machine source, `scripts/setup-branch-protection.sh` as the apply mechanism, and the drift-detection workflow as the safety net. Replaces the static list of required checks (which would drift) with a pointer to the YAML. ([#11](https://github.com/pdlourenco/disciplined-project-seed/issues/11))
- `docs/CONTRIBUTING.md §"Pre-push CI run"`: replaced the `**Commands.**` placeholder with concrete guidance (ecosystem task runner as source of truth) and added a `**Scope.**` clause stating tier 1 + tier 3 only pre-push. ([#10](https://github.com/pdlourenco/disciplined-project-seed/issues/10))
- `docs/CONTRIBUTING.md §"Reviewer prompt"`: added bullets 5 (label consistency with the diff) and 6 (lifecycle currency on linked issues). The reviewer subagent now covers label hygiene in addition to principles / scope / ADR. ([#9](https://github.com/pdlourenco/disciplined-project-seed/issues/9))
- `docs/CONTRIBUTING.md §"CI strategy"`: added a pointer to the shipped workflow and ADR-0002.
- `docs/LABELS.md` slimmed: removed the three catalogue tables (now duplicated by `.github/labels.yml`), kept the conventions prose (state machine, disambiguation, usage examples, add/rename/remove). LABELS.md is now "the conventions doc"; `labels.yml` is "the catalogue".
- `docs/LABELS.md` §Lifecycle: `deferred` is now a parallel modifier that combines with the progression states (`discussion` / `decided` / `ready`) rather than mutually exclusive with them. Most common combination: `decided + deferred`.
- `docs/LABELS.md` *Seeding the catalogue*: replaced the manual `gh label create` snippet with a pointer to the Sync labels workflow and the `.github/labels.yml` machine source.
- `docs/CONTRIBUTING.md §"Issue & PR labels"`: rewritten to match the new lifecycle rule and the labels.yml ↔ LABELS.md pairing.
- `docs/STRUCTURE.md`: tree now shows `.github/ISSUE_TEMPLATE/`, `.github/labels.yml`, `.github/branch-protection.yml`, `.github/workflows/sync-labels.yml`, `.github/workflows/ci.yml`, `.github/workflows/check-branch-protection.yml`, `.github/scripts/audit-placeholders.py`, and the new top-level `scripts/` directory with both `setup-branch-protection.sh` and `normalize-branch-protection.jq`. After the meta/ extraction, also shows `meta/` and the dual-CHANGELOG split.
- `docs/decisions/README.md`: ADR index emptied (seed ADRs moved to `meta/decisions/`; adopter starts fresh).
- `.gitignore`: promoted `__pycache__/` and `*.py[cod]` from a comment-only mention to actual ignore patterns now that the seed runs Python (the placeholder-audit script).
- `CHANGELOG.md`: added blank lines after each `### Subsection` heading so MD022 / MD032 pass cleanly. Older release sections fixed at the same time.

### Fixed

- `.github/workflows/check-branch-protection.yml` — corrected a wrong premise that ran end-to-end through the workflow, ADR-0005, and `CONTRIBUTING.md`: the default `GITHUB_TOKEN` **cannot** read `/repos/.../branches/main/protection` — that endpoint requires `administration: read` scope and returns 403, not 404. The old workflow fetched `/protection` with the default token and routed any failure (including the 403 it always got) into the "Report missing live protection" issue path — silently mis-reporting denied-as-absent on every weekly run. Fix is two-layer: layer 1 (presence) uses the default token against `/branches/main`'s `protected` flag (always works); layer 2 (field-level drift) uses `secrets.BRANCH_PROTECTION_READ_TOKEN || github.token` against `/protection` and distinguishes HTTP 403 (denied — log "field-level drift skipped", exit clean) from 404 (missing — file the missing-protection issue) from 200 (diff against YAML). ADR-0005's Status records a "Revised — 2026-06-05" line; §Decision and §Consequences carry the corrected premise; `docs/CONTRIBUTING.md §"Required status checks"` describes the two-layer model. Adopter-facing: all forks should merge; private forks especially, since they're the ones where layer 2 silently fails.
- `.github/workflows/sync-labels.yml` — added `contents: read` alongside `issues: write` so `actions/checkout` works on private adopter repos. A `permissions:` block sets every unlisted scope to `none`; the implicit `contents: none` was silently fine on the seed's own public repo (unauthenticated reads work) but 404'd on private forks, so the sync never ran. Same shape `check-branch-protection.yml` already used; surfaced by a downstream private adopter (PPQQ). General rule now stated once in `docs/CONTRIBUTING.md §"Workflow permissions"` and noted in [ADR-0001 §Consequences](decisions/ADR-0001-label-sync.md). Adopter-facing: private forks should merge this fix.
- `.github/labels.yml` — quoted all hex colour values as strings. A hex colour matching `/\d+[eE]\d+/` (e.g. `5319E7`, used by the `schema` label) is YAML-1.1-legal scientific notation: `5319 × 10^7`. An unquoted value would parse as a number and silently corrupt the colour when sent to GitHub's API by `EndBug/label-sync`. Quoted prophylactically across the whole catalogue with a header comment explaining the rule so future additions don't have to re-derive it. Adopter-facing: private forks should merge this fix.
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
