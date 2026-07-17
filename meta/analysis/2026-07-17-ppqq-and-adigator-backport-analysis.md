# 2026-07-17 — Two-adopter backport analysis (ppqq + adigator-embedded)

**Dated snapshot at seed `main` `090b2a7`. Will not be maintained** — it records
the state of two downstream adopters on this date and the backport decision
taken from it. Live status of the resulting work:
[#35](https://github.com/pdlourenco/disciplined-project-seed/issues/35)
(Tier 1) and
[#36](https://github.com/pdlourenco/disciplined-project-seed/issues/36)
(Tier 2). This is the seed's first `meta/analysis/` document; the
adopter-facing convention for analysis documents is itself one of the backport
items below (§7 item 1).

**Inputs.** Local checkouts of the two adopters, studied on this date:

- `adigator-embedded` (GMV) — MATLAB automatic-differentiation fork
  (Weinstein/Rao ADiGator) targeting embedded code generation. Solo-maintained,
  GPLv3, ~378 commits, 29 ADRs. GitHub: `pdlourenco/adigator-embedded`.
- `ppqq` (a.k.a. `ppqq-active` in earlier seed records) — TypeScript/pnpm
  monorepo (NestJS + React SPA) condominium-management SaaS. Regulated-domain,
  69 ADRs, 14 phase plans.

**Method.** One deep-read subagent per adopter (all discipline docs, ADR
indexes, process ADRs in full, workflows, scripts, git history), findings
spot-verified first-hand, then deduplicated against the seed's already-absorbed
backports (§2). The executing session does **not** need access to the adopter
repos; every claim used by the decision is recorded here.

## 1. Adoption profiles

| | adigator-embedded | ppqq |
|---|---|---|
| Profile | **Minimal** — deliberate trim, decided up front in a written analysis (`docs/analyses/SEED_ADOPTION_ANALYSIS.md`) | **Full spine** — every seed artifact adopted; seed doctrine quoted verbatim in its READMEs |
| SPEC | Folded into `DESIGN.md §Contracts` ("single implementation, no cross-language/process boundaries, a standalone spec would be overhead") | Standalone `SPEC.md`, 25+ sections, per-rule `Verified by:` |
| Dropped | `STRUCTURE.md`, `RISKS.md`, `LABELS.md`, labels-as-code, branch-protection-as-code, `docs/plans/` (inline ROADMAP) | Only `RISKS.md` ("adopt when the first concrete risk needs tracking, rather than shipping an empty template now") |
| Scale evidence | Discipline held across 29 ADRs and a spec-first CI plan | Discipline held across 69 ADRs, ~24 PRs/phase; two conventions showed documented rot (§5) |

Both profiles worked. The lesson is that the seed scales down by **dropping
files, not by diluting rules** — neither adopter weakened ADRs, pre-push
review, contracts-with-teeth, or recommend-don't-decide.

## 2. Already flowed upstream — do not re-backport

Everything the seed absorbed in v0.2.0 and the PR [#16](https://github.com/pdlourenco/disciplined-project-seed/issues/16)–[#29](https://github.com/pdlourenco/disciplined-project-seed/pull/29)
era came from ppqq. The executing session must treat these as done: agent
PR-lifecycle + two-session workflow (ADR-0009), comment-only reviewer
carve-out, recommend-don't-decide extension, ADR parallel-track
reserve-band + rebase-before-finalizing rule (already generalized in
`docs/decisions/README.md` to any sequence-drawn identifier), SessionStart
toolchain hook, `scripts/local-ci.sh`, structural-lint contract-enforcement
pattern, phased-activation option, pointer-index pattern,
branch-protection contexts-consistency check + two-layer drift model,
`GH_REPO`-explicit rule, label 100-char cap, `contents: read` rule,
hex-colour quoting, V&V / `Verified by:` additions, `LABELS.md`, pre-push CI
run section, ADR lifecycle shapes, design-meeting phase variant, DESIGN
slim/per-topic split, PR-template rows. Nothing from adigator-embedded has
ever been backported.

## 3. adigator-embedded — findings

New inventions (beyond MATLAB specifics):

- **Known-issue / self-healing test lifecycle.** A documented bug ships a
  tagged test (`KnownIssue` + `assumeFail`; xfail in other frameworks) that
  detects the buggy outcome and skips, otherwise asserts — so it becomes a
  regression guard the moment the bug is fixed. The fixing PR flips the tag in
  the same PR. Their own caveat, worth carrying: a stale tag downgrades the
  guard (a re-introduced regression reports as *filtered*, not *failed*), so
  tag removal is part of the fix, and a stale-tag detector is the residual
  debt.
- **`CI_PLAN.md` traceability model.** Stable requirement IDs (`REQ-T-*`,
  `REQ-C-*`) × test IDs (`TS-U/I/S-*`) in a traceability matrix, plus a
  bug-register→test mapping. Independently invented *before* adopting the seed
  — their adoption analysis flags the convergence with the seed's
  `Verified by:` idea as evidence the idea is load-bearing.
- **Docs are state-based and release-relative** (their ADR-0029): user-facing
  docs describe current behavior with **no dev-tracking references** (no
  `ADR-nnnn`, `#issue`, internal revision tags); dev docs and code comments
  keep the full audit trail.
- **Expensive-CI cost patterns** (born from MATLAB-licensed runners, general
  to any costly required check): (a) docs-only PRs skip the expensive job via
  an in-job base-diff while the required check still reports green; (b) a
  committed `.githooks/pre-push` hook runs the same entry point CI runs, on a
  clean environment, skipping cleanly when the toolchain is absent.
- **Clean-environment lesson** (their ADR-0017): a test passed locally off an
  incidentally-loaded path and reddened CI twice; fixed with a clean-path test
  base class plus a **meta-test that scans sibling test classes** for the
  violation — a test enforcing a contributor convention.
- **`docs/analyses/`** — see §6.
- **ADR in-flight scan.** Their numbering rule adds a concrete command the
  seed's rule lacks: scan open PRs (`gh pr list --search 'ADR- in:files'`) as
  well as merged history before claiming a number.

## 4. ppqq — findings beyond the §2 inventory

- **A contract-gate catalogue far richer than the seed's four patterns:**
  - *Codegen-diff gate*: emit OpenAPI from the real app → regenerate client
    types → `git diff --exit-code`; an unregenerated contract change fails CI.
  - *Set-for-set enrollment gate*: enumerate every route/handler from
    framework metadata and force each into `matrix` / `exempt` / `pending`; an
    unenrolled newcomer fails CI.
  - *Totality-over-enum gate*: every enum member declaring a capability must
    appear in the registry implementing it.
  - *Spec-prose parsing gate*: tests parse the markdown catalogue tables out
    of `SPEC.md` and assert set-for-set equality with the code unions — which
    in turn forces a documented machine-parseable shape on the SPEC tables.
  - *Metadata-derived cross-check*: any hand-maintained list inside a lint
    rule is asserted equal to the same set derived from schema metadata, so
    the lint rule can't drift from the schema.
- **The drift-hardening doctrine** behind them (their "ADR-0021 series", five
  entries deep): *a mandate enforced only by an outcome test that two idioms
  both pass will drift — replace it with a structural gate.*
- **Property-based-testing convention** (their ADR-0059): `fast-check` with a
  seeded-reproducibility rule (pinned seed, committed counterexample corpus as
  regression fixtures), a three-layer scope model (pure engines per-PR /
  stateful nightly / never-randomize), and the **oracle-trap rule** ("assert
  invariants, not a reimplementation"). Wired author-facing into
  `PHASE-TEMPLATE.md §9` anti-drift and reviewer-facing into
  `REVIEW_CONTEXT.md`.
- **Fractional / remediation interstitial phases**: decimal phases (2.10, 3.5,
  4.7, 4.8, 6.5, 6.6) with the *why-fractional* named per entry in
  `plans/README.md` — pull-forward slices and dedicated remediation phases
  instead of reopening a completed phase.
- **Frozen-`notes/` migration pattern**: pre-seed design material kept
  verbatim and frozen ("not authoritative"), load-bearing parts migrated into
  the disciplined `docs/` tree with a mapping table and `git log --follow`
  trail; the design-phase TODO scratchpad kept with resolved items struck
  through as an audit trail feeding the Phase-0 design meeting.
- **Sequence-identifier discipline extended** to migration timestamps
  (decade-band per active phase) after three recorded collisions; the seed
  already carries the generalized rule, but the migration-band worked example
  is theirs.

## 5. Convention-failure evidence (the most valuable findings)

Both are documented failures **of seed conventions at scale**, caught by
ppqq's independent review:

1. **Deferred-with-trigger rot.** At least five deferral sites whose named
   trigger had fired ("deferred to #126 / Phase 4") sat unswept after Phase
   4.8 landed; nobody scanned for fired triggers. The convention needs a
   paired **sweep step** — on phase completion, sweep deferrals whose trigger
   named that phase/issue.
2. **Prose restating machine-checked catalogues drifts.** The set-for-set
   gates protected the tables they parse, while ~a dozen design docs that
   *restated* those catalogues fell behind (one list "6 values behind"; one
   doc still describing a rejected alternative). Prose should **point, not
   restate** — an extension of the seed's existing pointer-index pattern.

## 6. Convergent signal — the analysis folder

Both adopters independently created one, with two compatible usage models:

- **adigator `docs/analyses/`**: a running series of **dated immutable
  snapshots** — field reports, a code-quality review, an "objective
  reassessment" that self-declares *"deliberately short and will not be
  maintained"* and points at ROADMAP / the bug register for live state — plus
  **canonical registers** (`ANALYSIS.md`, the B1–B28 bug catalogue, cited 14
  times across their CLAUDE.md, DESIGN, ROADMAP, REVIEW_CONTEXT,
  CONTRIBUTING).
- **ppqq `docs/analysis/`**: a **periodic independent audit** — one dated
  whole-platform review by a non-authoring session; findings converted to
  GitHub issues, which scoped dedicated remediation phases. The doc is the
  narrative; the tracker is the register.

Convergent detail: both ran a dated independent review whose findings drove a
remediation burst. The folder fills a real gap — analysis artifacts that are
neither decisions (ADRs) nor living contracts (SPEC/DESIGN). The
immutability-plus-pointers rule is what keeps it from becoming a stale-doc
graveyard.

## 7. Backport decision

Maintainer approved 2026-07-17. **Tier 1** ships as one PR series (one commit
per item; seed-meta ADRs where marked), tracked in
[#35](https://github.com/pdlourenco/disciplined-project-seed/issues/35).
**Tier 2** is parked as one `deferred + decided` issue with named triggers,
[#36](https://github.com/pdlourenco/disciplined-project-seed/issues/36).

Tier 1:

1. **`analyses/` as a first-class optional doc type** — adopter-facing
   convention (suggested home: `docs/analyses/` with a convention README)
   covering both usage models from §6, the dated-immutable-snapshot rule
   (dated docs declare themselves unmaintained and point at living docs), the
   canonical-register variant, and the periodic
   independent-review → issues → remediation-phase loop. The seed dogfoods it
   as `meta/analysis/` (this document). Settle the `analysis`/`analyses`
   naming in the ADR. *(both adopters — convergent)* **ADR.**
2. **Contract-gate pattern catalogue + drift-hardening doctrine** — extend
   `docs/CONTRIBUTING.md §"CI strategy" §1` with the §4 gate patterns
   (codegen-diff, set-for-set enrollment, totality-over-enum, spec-prose
   parsing, metadata-derived cross-check), state the doctrine, and fold the
   §5.2 "prose points, doesn't restate" caveat into the pointer-index
   guidance. Patterns only; contents stay downstream. *(ppqq)* **ADR.**
3. **Deferral-sweep step** — pair the deferred-with-conditions convention
   with a sweep: on phase completion (PHASE-TEMPLATE §10 admin) and in the
   contributing guidance, scan for deferrals whose named trigger fired.
   Evidence: §5.1. *(ppqq)*
4. **Known-issue / self-healing test lifecycle** — testing convention in
   `docs/CONTRIBUTING.md` (+ §"When CI fails" cross-ref) and a PR-checklist
   row ("bug fix flips its known-issue test in the same PR"), including the
   stale-tag caveat. *(adigator)* **ADR.**
5. **Scale-based adoption guidance** — a short "adopting at small scale"
   section (README or CONTRIBUTING): the two-profile contrast from §1 with
   thresholds (single implementation → SPEC folds into `DESIGN §Contracts`;
   solo/small team → labels-as-code and branch-protection-as-code optional;
   small scope → inline ROADMAP), plus the frozen-`notes/` migration pattern
   for pre-existing material. *(both)*
6. **State-based / release-relative docs rule** — user-facing docs describe
   current state with no dev-tracking references; dev docs keep the audit
   trail. Example principle in `REVIEW_CONTEXT.md` + a CONTRIBUTING note.
   *(adigator)*
7. **Trivia batch** — in-flight ADR scan command in
   `docs/decisions/README.md`; a migration-timestamp banding example on the
   existing sequence-identifier rule (parallel tracks claim distinct
   leading-decade blocks of the timestamp — ppqq banded per active phase, and
   re-banded a phase to a fresh decade when a shared one exhausted). *(both)*
8. **`SEED_ADOPTION.md` marker** — new template file recording seed
   provenance (repo URL + seed version/SHA + date), a per-artifact adoption
   table (`adopted` / `adapted (where)` / `dropped (why/ADR)`), an
   append-only sync log (date + seed ref range + taken/skipped), and an
   optional backport log. Referenced from the item-5 guidance ("choose your
   profile, record it here"). Enables both flow directions: backport studies
   like this one, and seed-update flow-down (diff the seed from your last
   recorded ref, triage against your table). *(maintainer-originated, this
   study)* **ADR.**

Supporting change: the seed starts **cutting git tags** at CHANGELOG
versions, so adopters pin `vX.Y.Z (sha)` in their marker and flow-down reads
the seed CHANGELOG between two pinned versions. First tag: whatever version
the Tier-1 PR ships as.

Tier 2 (deferred, named triggers):

- **PBT convention** (§4) — trigger: first adopter with a pure,
  invariant-bearing engine surface asks for testing guidance.
- **Full traceability-matrix option** for SPEC (§3) — trigger: an adopter in
  a regulated / V&V-heavy domain needs requirement-level traceability beyond
  per-rule `Verified by:`.
- **Expensive-CI cost patterns** (§3) — trigger: first adopter whose required
  checks are licensed or slow enough that docs-only skips / a committed
  pre-push hook pay for themselves.

Explicitly **not** backported: reproducible-artifact commit-back workflow
(adigator's PDF pipeline; niche), the meta-test-over-tests idea as a separate
pattern (covered by the existing structural-lint pattern; at most an example
in item 2), local-ci self-healing extensions (machine-specific).

## 8. Implementation notes for the executing session

- Work from this document only; adopter repo access is not needed and not
  assumed. If a claim here seems insufficient to write an item, say so rather
  than guessing.
- One commit per Tier-1 item, in the numbered order above (item 8 depends on
  item 5's guidance section existing; item 7 is independent).
- Seed-meta ADRs go in `meta/decisions/` (next free numbers — rebase and scan
  open PRs before claiming, per `docs/decisions/README.md`); adopter-facing
  conventions land in the adopter-facing docs.
- Every item lands with its `meta/CHANGELOG.md` entry (MINOR for new
  conventions/files, PATCH for guidance-only), per the existing format.
- Follow-up to open as an issue, not bundled: retrofit `SEED_ADOPTION.md` in
  the two adopters (adigator's is mostly a lift of its
  `SEED_ADOPTION_ANALYSIS.md`). The Tier-2 deferrals are already tracked in
  [#36](https://github.com/pdlourenco/disciplined-project-seed/issues/36).
