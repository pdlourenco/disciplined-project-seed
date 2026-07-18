# 2026-07-17 — Four-adopter backport analysis (ppqq, adigator-embedded, tombo, sid)

**Dated snapshot at seed `main` `090b2a7`. Will not be maintained** — it records
the state of four downstream adopters on this date and the backport decision
taken from it. Live status of the resulting work:
[#35](https://github.com/pdlourenco/disciplined-project-seed/issues/35)
(Tier 1) and
[#36](https://github.com/pdlourenco/disciplined-project-seed/issues/36)
(Tier 2). This is the seed's first `meta/analyses/` document; the
adopter-facing convention for analysis documents is itself one of the backport
items below (§9 item 1).

**Inputs.** The four adopters — ppqq and adigator-embedded studied
2026-07-17, tombo and sid 2026-07-18 (the doc keeps the study's start date).
The first three were studied from local checkouts; sid additionally through
its open PRs, since its adoption is in flight there:

- `adigator-embedded` (GMV) — MATLAB automatic-differentiation fork
  (Weinstein/Rao ADiGator) targeting embedded code generation. Solo-maintained,
  GPLv3, ~378 commits, 29 ADRs. GitHub: `pdlourenco/adigator-embedded`.
- `ppqq` (a.k.a. `ppqq-active` in earlier seed records) — TypeScript/pnpm
  monorepo (NestJS + React SPA) condominium-management SaaS. Regulated-domain,
  69 ADRs, 14 phase plans.
- `tombo` — Python indexer + Rust CLI over a shared Tantivy index. Forked the
  seed's **v0.1.0 core**, then back-ported the governance machinery the seed
  matured afterwards as an explicit workstream (its ADRs 0018–0022, each
  naming its seed meta-ADR origin). 23 ADR-directory files; owns the seed's
  named example of an extra source-of-truth artifact, `docs/schema.toml`.
- `sid` (GMV; local checkout `sid-matlab`, GitHub: `pdlourenco/sid`) —
  trilingual system-identification toolbox (MATLAB + Python shipped, Julia
  planned) bound by a shared `spec/SPEC.md` and cross-language reference
  vectors in `testdata/`. Independently realized the seed's spec-as-contract
  core before adopting; the governance layer is being retrofitted **right
  now** as a stacked PR series (its PRs #125–#130 + #132), with a repo-wide
  review (its PR #133) alongside.

**Method.** One deep-read subagent per adopter (all discipline docs, ADR
indexes, process ADRs in full, workflows, scripts, git history; for sid also
the open-PR descriptions, diffs, and review threads), findings spot-verified
first-hand, then deduplicated against the seed's already-absorbed backports
(§2). The tombo and sid passes additionally scored each already-decided
Tier-1 item as confirmed / contradicted / extended. The executing session
does **not** need access to the adopter repos; every claim used by the
decision is recorded here.

## 1. Adoption profiles

| | adigator-embedded | ppqq | tombo | sid |
|---|---|---|---|---|
| Profile | **Minimal** — deliberate trim, decided up front in a written analysis (`docs/analyses/SEED_ADOPTION_ANALYSIS.md`) | **Full spine** — every seed artifact adopted; seed doctrine quoted verbatim in its READMEs | **Fork + catch-up sync** — v0.1.0 core, later back-ported governance (reviewer convention, labels-as-code, doc-CI, branch-protection-as-code, V&V) as issues #65–#71 / epic #72 | **Governance retrofit** — already realized the spec-as-contract core independently; adopting only the governance layer, one artifact per stacked PR (its epic #117: "adapt to SID's layout, don't impose the seed's") |
| SPEC | Folded into `DESIGN.md §Contracts` ("single implementation, no cross-language/process boundaries, a standalone spec would be overhead") | Standalone `SPEC.md`, 25+ sections, per-rule `Verified by:` | Standalone `SPEC.md` + `docs/schema.toml` as a second, machine-shared contract artifact (its ADR-0008) | Pre-existing `spec/SPEC.md` + `testdata/reference_*.json` machine-shared vectors; `Verified by:` retrofitted with a 6-value vocabulary (its PR #127) |
| Dropped | `STRUCTURE.md`, `RISKS.md`, `LABELS.md`, labels-as-code, branch-protection-as-code, `docs/plans/` (inline ROADMAP) | Only `RISKS.md` ("adopt when the first concrete risk needs tracking, rather than shipping an empty template now") | `meta/`, `STRUCTURE.md`, `RISKS.md` (explicitly de-scoped in its epic #72); seed's `UX`/`UI` labels ("no human-facing UI surface" yet) | Labels-as-code, branch-protection-as-code, open-PR-review convention, `docs/plans/`, project `CHANGELOG.md` — each parked in the epic's deferral table with a named trigger, "not filed as issues to avoid stale-backlog noise" |
| Scale evidence | Discipline held across 29 ADRs and a spec-first CI plan | Discipline held across 69 ADRs, ~24 PRs/phase; two conventions showed documented rot (§7) | Contract gates held across a polyglot boundary; prose docs and serial identifiers showed documented rot (§7) | Trilingual contract gate held for years; the shared artifact itself showed staleness rot (§7) |

All four profiles worked. The lesson stands: the seed scales down by
**dropping files, not by diluting rules** — no adopter weakened ADRs,
pre-push review, contracts-with-teeth, or recommend-don't-decide. Adaptation
lesson from tombo: reconcile the seed's vocabulary against local usage before
importing names — its CONTRIBUTING already used "Tier 3" to mean *deferred*,
so it deliberately renamed the seed's "Tier 3 —"-prefixed doc-CI jobs to
avoid an "actively misleading" collision.

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
slim/per-topic split, PR-template rows. Nothing from adigator-embedded,
tombo, or sid has ever been backported; tombo and sid have so far been pure
*consumers* of seed updates (tombo's commits "back-port seed fix" pulled the
`contents: read`, colour-quoting, and two-layer drift fixes downstream; sid's
PR #132 "[seed adoption +1]" backported the `contents: read` + `GH_REPO`
fixes citing the exact seed commits, recording the non-applicable fixes from
the same wave with reasons — evidence the seed already functions as a
bidirectional fix-distribution hub).

## 3. adigator-embedded — findings

New inventions (beyond MATLAB specifics):

- **Known-issue / self-healing test lifecycle.** A documented bug ships a
  tagged test (`KnownIssue` + `assumeFail`; xfail in other frameworks) that
  detects the buggy outcome and skips, otherwise asserts — so it becomes a
  regression guard the moment the bug is fixed. The fixing PR flips the tag in
  the same PR. Their own caveat, worth carrying: a stale tag downgrades the
  guard (a re-introduced regression reports as *filtered*, not *failed*), so
  tag removal is part of the fix, and a stale-tag detector is the residual
  debt. (See §9 item 4 — tombo and sid use a different mechanism.)
- **`CI_PLAN.md` traceability model.** Stable requirement IDs (`REQ-T-*`,
  `REQ-C-*`) × test IDs (`TS-U/I/S-*`) in a traceability matrix, plus a
  bug-register→test mapping. Independently invented *before* adopting the seed
  — their adoption analysis flags the convergence with the seed's
  `Verified by:` idea as evidence the idea is load-bearing.
- **Randomized / Monte-Carlo V&V** (their ADR-0007): a `tests/montecarlo/`
  campaign randomizing function bodies, shapes, sizes, and parameters against
  **tolerance-free oracles** (cross-mode exact equality; generators emitting
  functions whose exact derivative is known by construction; sparsity-superset
  checks), explicitly **never a required PR check** (a fixed-seed smoke test
  covers per-merge drift; the unbounded campaign is a local/release run), with
  every failing seed **delta-debugged to a minimal reproducer and promoted**
  to a deterministic committed regression case. Motivated by bugs living
  "precisely in the *combinations* nobody enumerated." Convergent with ppqq's
  PBT convention (§4) — see the randomized-exploration item under Tier 2 in
  §9.
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
- **`docs/analyses/`** — see §8.
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
  already carries the generalized rule, but the migration-band example is
  theirs.

## 5. tombo — findings

- **`docs/schema.toml` — the reference implementation of the seed's "extra
  source-of-truth artifact" example.** One language-agnostic schema file that
  both the Python indexer and the Rust CLI *parse at build/run time*
  (`include_str!` on the Rust side). Its ADR-0008 explicitly rejected the
  "mirror + CI equality test" alternative because it "catches drift *after*
  it's already pushed" and dies when one language is retired, choosing the
  shared-file form where *"drift in the source of truth is structurally
  impossible; drift in the parsers is caught at CI time."* Enforced by a
  polyglot gate trio: a SPEC-table↔code consistency test, a dependency
  version-pinning test (Python binding minor ↔ Rust crate), and an
  integration probe (Python writes a real index; a Rust binary opens it and
  asserts the field set and types). Directly reusable guidance for any
  polyglot contract artifact.
- **Sync model: distributed provenance, no central ledger.** Every
  governance ADR names its seed origin ("Back-ported from the
  `disciplined-project-seed` (its meta ADR-N)"), and seed fixes were pulled
  down post-adoption — but there is **no seed-version pin** (only "v0.1.0
  core"), **no sync log**, and **no per-artifact adoption table**. The
  strongest single motivation observed for the `DISCIPLINE_ADOPTION.md` marker
  (§9 item 8).
- **Visible-debt markers instead of xfail** (its ADR-0022): rules found with
  no automated verifier get a visible-debt marker in SPEC plus an entry in a
  tracking issue, *deliberately rejecting* a forced same-PR test gate. Its
  2026-07-16 independent review notes "no skip/xfail anywhere." A second,
  incompatible mechanism for the same problem adigator solves with
  self-healing tests — see §9 item 4.
- **Cross-workstream serial-identifier collisions, live.** Running the
  governance backport concurrently with feature work collided on **both** an
  ADR number and a SPEC version string (an open PR reused `v0.2.3` and
  `ADR-0018`, both already taken). Its review prescribes next-free-slot
  renumbering and recommends *"a small CI check for ADR-number/SPEC-version
  uniqueness against open PRs"* — a concrete automation of the in-flight
  scan.
- **A gate can test a mirror instead of the real thing.** Its review's T6
  finding: a path-handling test suite verified `canonicalize_windows` — "a
  parallel, test-oriented reimplementation" — rather than the production
  `canonicalize` function, so the gate passed while the production idiom went
  unverified. The origin of item 2's production-idiom caveat.
- **`Verified by:` can over-claim.** Its review found a SPEC section
  asserting "Verified by: … every validation rule above" while ~10 rules had
  zero tests — *"flatly false."* Adopting the annotation surfaced real gaps
  but also created a new drift surface; the annotation needs a mechanized
  cross-check or reviewer attention, not trust.
- **Contract gates hold; prose rots.** Its review's central conclusion: the
  schema/contract gates worked, while DESIGN/ROADMAP "lag the contract by
  one to two versions" because nothing gates prose — independently
  reproducing ppqq's §7.2 finding. Recommended remedy: fold a doc-refresh
  step into the contract-change checklist.
- **markdownlint auto-fix hazard** (its ADR-0020): auto-fixes silently
  changed meaning twice (`__pycache__` → `**pycache**`; a trailing-space
  code span collapsed). Lesson: review auto-fix output; disable
  meaning-changing rules (e.g. MD038) rather than accept their fixes.
- **Doc-CI exclusion-set triplication**: the same template skip-list is
  hand-duplicated across the markdownlint config and two workflow `find`
  invocations with KEEP-IN-SYNC notes — the same seam the seed itself
  carries; tombo names a promotion trigger for factoring it out.

## 6. sid — findings

- **The strongest polyglot validation of the contract-gate model.** The
  binding contract is the written spec; the machine-shared artifact is
  `testdata/reference_*.json` (22 files: function, params, input, 16-digit
  output, tolerance), generated by MATLAB and validated *independently* by
  each language in CI. The doctrine is stated more concretely than the
  seed's: "Implementations conform to the spec, not to each other. MATLAB is
  not a ground truth"; "Cross-language reference vectors are a check, not a
  proof"; and the joint-drift failure mode is named — "a bug in a shared
  helper can make every downstream caller silently violate the spec in the
  same way, which will not be caught by cross-validation tests."
- **`Verified by:` with a closed value vocabulary** (its PR #127): six values
  (`cross-vector` / `unit(M|Py)` / `lint` / `manual` / `deferred` / `none`),
  with the explainer that "a `cross-vector` check proves the two ports
  agree, not that either satisfies the spec; the strongest rules pair it
  with a `unit` test." `none` is the visible-debt marker — sid lands on the
  same known-bug mechanism as tombo (marker + register: its gap issues and
  the review's severity-graded register → issues), not adigator's xfail.
- **The shared contract artifact itself rotted** (its PR #133, finding S10):
  the generator double-divides one quantity so a stored reference doesn't
  match production; four reference files are consumed by no test; no JSON
  carries generator version/date/seed metadata "so staleness is undetectable
  from file contents"; and a zero absolute-tolerance floor makes the gate
  environment-flaky (passes on CI's Octave, fails on Octave 8.4.0).
  Concrete hardening requirement: **generator-provenance metadata + an
  absolute tolerance floor** on any machine-shared numeric artifact.
- **Issue-based provenance instead of a marker file.** No
  `DISCIPLINE_ADOPTION.md`-like file exists; the per-artifact adoption table,
  value/effort ordering, and deferral table live in epic issue #117, the
  seed attribution in CLAUDE.md's header, the pre-existing-principle record
  in a retroactive ADR-0001, and the sync log in PR #132's body (exact seed
  commits `4335ee7` / `28a007c`, with N/A items reasoned). A live
  counterpoint to §9 item 8's file convention.
- **Adoption-as-stacked-PR-series mechanics**: one artifact per PR, each
  branch stacked on the previous so every diff is single-topic; strictly
  ordered review; an original monolith PR was closed and split "for easier
  review." **Forward-reference bookkeeping**: CLAUDE.md landed first,
  pointing at conventions two PRs away as "being added" via issue links,
  each later PR closing its forward-reference. The `[1/6]`…`[6/6]` +
  `[seed adoption +1]` title banding marks in-plan vs post-plan increments.
- **Retroactive ADR as provenance anchor**: ADR-0001 records the
  spec-is-contract principle "the project has operated under since its early
  multi-language structure... so the rationale is recoverable, not because
  the decision is new" — the pattern for adopting a decision trail onto a
  codebase that already made its decisions.
- **Monte-Carlo present, ad hoc**: the repo-wide review used a 200-trial
  Monte-Carlo calibration to prove its highest-severity finding, and one
  committed MC uncertainty test predates adoption — a partial third data
  point for the randomized-exploration convergence (§9 Tier 2), though no
  seeded/promoted convention exists.
- **Polyglot ops patterns** (noted, not backported — see §9): per-language
  release tags (`v0.1-matlab` / `v0.1-python`) assembling curated archives;
  a GitHub-App token bypassing branch protection so CI can auto-commit
  regenerated reference vectors, with a pull-rebase-retry loop.

## 7. Convention-failure evidence (the most valuable findings)

Documented failures **of seed conventions at scale**:

1. **Deferred-with-trigger rot** (ppqq). At least five deferral sites whose
   named trigger had fired ("deferred to #126 / Phase 4") sat unswept after
   the phase landed; nobody scanned for fired triggers. The convention needs
   a paired **sweep step** — on phase completion, sweep deferrals whose
   trigger named that phase/issue.
2. **Prose restating machine-checked catalogues drifts** (ppqq, independently
   reproduced by tombo). Set-for-set gates protected the tables they parse,
   while design docs that *restated* those catalogues fell behind (ppqq: one
   list "6 values behind"; tombo: DESIGN two contract versions stale, three
   docs advertising a forbidden pattern). Prose should **point, not
   restate** — and the contract-change checklist should include refreshing
   the prose docs that describe the contract.
3. **`Verified by:` annotations over-claim without a cross-check** (tombo).
   The visible-debt convention only works if the annotation is honest; an
   over-claiming annotation is worse than a missing one.
4. **Serial identifiers collide across parallel workstreams even with the
   rebase rule on paper** (tombo, live merge-blocker on both an ADR number
   and a SPEC version; ppqq, three recorded migration-timestamp collisions).
   The discipline needs the in-flight scan — and optionally a CI uniqueness
   check — not just the rebase rule.
5. **A machine-shared contract artifact can itself rot** (sid, §6): a
   generator bug shipped a wrong stored reference, orphan reference files
   went unconsumed, and missing generator metadata plus a zero tolerance
   floor made the gate staleness-blind and environment-flaky. Gates guard
   the consumers; the artifact's own generation needs provenance and a
   verifier too.

## 8. Convergent signal — the analyses folder

All four adopters independently created one:

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
- **tombo `docs/analyses/`**: the audit loop *plus a written convention
  README* (added 2026-07-16) that articulates the rules crisply. Its four
  conventions: filename `YYYY-MM-DD-<slug>.md` "dated by the review, not the
  merge"; **"Anchored to a commit"** — each analysis names the `main` SHA it
  reviewed, `file:line` references are relative to that SHA "and are
  expected to drift afterwards"; **"Immutable once merged"** — "Don't edit
  findings as they get fixed — the follow-up issues and PRs are the live
  tracking surface. Supersede by writing a new dated analysis"; **"Not a
  contract"** — "Nothing here binds implementations."
- **sid `docs/analyses/`**: its PR #133 introduces
  `docs/analyses/2026-07-12-repo-wide-review.md` — dated filename, immutable
  snapshot anchored to a named HEAD state (test counts and the executing
  Octave version recorded), findings severity-graded and spun out to twelve
  companion issues. Produced *before* sid formally adopted any analyses
  convention, and outside its adoption epic — a fourth independent
  convergence on the same shape.

The folder fills a real gap — analysis artifacts that are neither decisions
(ADRs) nor living contracts (SPEC/DESIGN). Tombo's README is close to the
convention text the seed should ship; the immutability-plus-pointers rule is
what keeps the folder from becoming a stale-doc graveyard.

## 9. Backport decision

Maintainer approved 2026-07-17 (originally from the two-adopter study; items
1, 2, 5, 7, 8 extended and item 4 materially changed 2026-07-18 after the
tombo pass; the sid pass, also 2026-07-18, further extended items 1, 2, 3,
4, 5, 8). **Tier 1** ships as one PR series (one commit per item;
seed-meta ADRs where marked), tracked in
[#35](https://github.com/pdlourenco/disciplined-project-seed/issues/35).
**Tier 2** is parked as one `deferred + decided` issue with named triggers,
[#36](https://github.com/pdlourenco/disciplined-project-seed/issues/36).

Tier 1:

1. **`analyses/` as a first-class optional doc type** — adopter-facing
   convention at `docs/analyses/` with a convention README covering the
   usage models from §8. **Start from tombo's four rules** (dated filename,
   anchored-to-a-commit, immutable-once-merged, not-a-contract), extended
   with the canonical-register variant (adigator) and the periodic
   independent-review → issues → remediation-phase loop (ppqq, tombo, sid).
   The seed dogfoods it as `meta/analyses/` (this document); the maintainer
   settled the naming on `analyses` (plural). *(all four adopters —
   convergent; sid produced a textbook instance before adopting any
   convention)* **ADR.**
2. **Contract-gate pattern catalogue + drift-hardening doctrine** — extend
   `docs/CONTRIBUTING.md §"CI strategy" §1` with the §4 gate patterns
   (codegen-diff, set-for-set enrollment, totality-over-enum, spec-prose
   parsing, metadata-derived cross-check) plus tombo's **shared
   contract-artifact pattern** (§5: one machine-parsed file both sides
   consume — "drift structurally impossible" — preferred over
   mirror-plus-equality-test where feasible, with the polyglot
   integration-probe gate). State the doctrine — with sid's sharper polyglot
   phrasing (implementations conform to the spec, not to each other;
   equivalence vectors are a check, not a proof; shared helpers drift
   jointly past cross-validation) — and sid's artifact-hardening requirement
   (§6, §7.5): machine-shared numeric artifacts carry generator-provenance
   metadata and an absolute tolerance floor. Fold the §7.2 "prose points,
   doesn't restate" caveat into the pointer-index guidance and add a
   prose-refresh step to the contract-change checklist; carry tombo's
   caveats that a gate must test the production idiom (not a test-oriented
   reimplementation) and that `Verified by:` annotations need a cross-check
   (§7.3) — sid's closed `Verified by:` value vocabulary (§6) is the
   worked option for making the annotation checkable. Patterns only;
   contents stay downstream. *(ppqq + tombo + sid)* **ADR.**
3. **Deferral-sweep step** — pair the deferred-with-conditions convention
   with a sweep: on phase completion (PHASE-TEMPLATE §10 admin) and in the
   contributing guidance, scan for deferrals whose named trigger fired.
   Evidence: §7.1. Tombo confirms the need in weaker form (pervasive named
   triggers, no sweep mechanism); sid's epic deferral table with per-item
   triggers is the born-sweepable form. *(ppqq)*
4. **Known-bug lifecycle — two documented mechanisms, presented as
   options.** *(Changed from the two-adopter decision, which prescribed the
   xfail mechanism alone; tombo deliberately rejects it.)* Present both with
   trade-offs and let adopters choose per their test culture:
   (a) **self-healing xfail tests** (adigator, §3): a tagged test that skips
   on the buggy outcome and asserts otherwise; becomes a regression guard on
   fix; the fixing PR flips the tag; stale tags are the residual debt.
   (b) **visible-debt markers + register** (tombo, §5; sid, §6 — its
   `Verified by: none` value plus gap/finding issues): unverified rules get
   a marker in SPEC plus an entry in a tracking issue; no forced same-PR
   test. Adopter count now 1 vs 2, still no ranking. Common core for the PR
   checklist either way: *a bug fix closes its known-bug tracking artifact
   (tag or marker) in the same PR.* *(adigator + tombo + sid)* **ADR.**
5. **Scale-based adoption guidance** — a short "adopting at small scale"
   section (README or CONTRIBUTING): the four-profile contrast from §1 with
   thresholds (single implementation → SPEC folds into `DESIGN §Contracts`;
   solo/small team → labels-as-code and branch-protection-as-code optional;
   small scope → inline ROADMAP), the frozen-`notes/` migration pattern for
   pre-existing material (ppqq), the fork + catch-up-sync path (tombo) and
   the governance-retrofit path (sid) as further adoption modes, the
   staged-PR-series mechanics for retrofits (§6: one artifact per stacked
   PR, forward-reference bookkeeping, retroactive ADR anchoring pre-existing
   principles), and the vocabulary-reconciliation warning (§1: diff the
   seed's names — tiers, labels, section titles — against local usage
   before importing). *(all four)*
6. **State-based / release-relative docs rule** — user-facing docs describe
   current state with no dev-tracking references; dev docs keep the audit
   trail. Example principle in `REVIEW_CONTEXT.md` + a CONTRIBUTING note.
   *(adigator)*
7. **Trivia batch** — in-flight scan command in `docs/decisions/README.md`
   (`gh pr list --search 'ADR- in:files'`), extended to note SPEC version
   strings as another colliding sequence and the optional CI uniqueness
   check tombo recommends (§5); a migration-timestamp banding example on the
   existing sequence-identifier rule (parallel tracks claim distinct
   leading-decade blocks of the timestamp — ppqq banded per active phase,
   and re-banded a phase to a fresh decade when a shared one exhausted); a
   one-line markdownlint auto-fix caution (§5) in the doc-CI guidance.
   *(adigator + ppqq + tombo)*
8. **`DISCIPLINE_ADOPTION.md` marker** — new template file (named for the
   discipline being adopted, not the seed artifact, per maintainer review on
   PR #37; final name settled in the ADR) recording seed
   provenance (repo URL + seed version/SHA + date), a per-artifact adoption
   table (`adopted` / `adapted (where)` / `dropped (why/ADR)`), an
   append-only sync log (date + seed ref range + taken/skipped), and an
   optional backport log. Referenced from the item-5 guidance ("choose your
   profile, record it here"). Enables both flow directions: backport studies
   like this one, and seed-update flow-down (diff the seed from your last
   recorded ref, triage against your table). Tombo is the motivating
   counterexample: its provenance is distributed per-ADR with no version pin
   and no sync log, which is exactly what made its sync state expensive to
   reconstruct. sid is the live counterpoint (§6): it keeps an equivalent
   record in a pinned epic issue + retroactive ADR + backport-PR bodies —
   so the convention should name the committed file as the default (in-repo,
   diffable, survives tracker migration) while allowing a pinned tracking
   issue as the record for issue-centric repos; the ADR records that
   trade-off. *(maintainer-originated, this study)* **ADR.**

Supporting change: the seed starts **cutting git tags** at CHANGELOG
versions, so adopters pin `vX.Y.Z (sha)` in their marker and flow-down reads
the seed CHANGELOG between two pinned versions. First tag: whatever version
the Tier-1 PR ships as.

Tier 2 (deferred, named triggers):

- **Randomized-exploration testing convention (PBT / Monte-Carlo V&V)**
  (§3, §4) — **convergent**: two adopters independently built the same three
  design choices (assert invariants/oracles, not a reimplementation; seeded
  reproducibility with failing cases promoted to committed deterministic
  fixtures; the unbounded run kept out of the PR gate); sid adds a partial
  third data point (§6: ad-hoc Monte-Carlo as a review/verification tool,
  no seeded convention). Maintainer flagged the convergence in PR #37
  review; promotion to Tier 1 is a live option. If it stays deferred —
  trigger: first adopter with a pure, invariant-bearing engine surface asks
  for testing guidance.
- **Full traceability-matrix option** for SPEC (§3) — trigger: an adopter in
  a regulated / V&V-heavy domain needs requirement-level traceability beyond
  per-rule `Verified by:`.
- **Expensive-CI cost patterns** (§3) — trigger: first adopter whose required
  checks are licensed or slow enough that docs-only skips / a committed
  pre-push hook pay for themselves. sid's cross-engine equivalence gate
  history (BLAS-dependent tolerance flakiness, race-prone auto-commits,
  App-token bypass) is further evidence the pattern set is needed.

Explicitly **not** backported: reproducible-artifact commit-back workflow
(adigator's PDF pipeline and sid's App-token reference-vector auto-commit;
niche polyglot/generated-artifact ops — revisit if a third adopter needs
it), per-language release tagging and archive assembly (sid; polyglot
release ops), the meta-test-over-tests idea as a separate pattern (covered
by the existing structural-lint pattern; at most an example in item 2),
local-ci self-healing extensions (machine-specific), tombo's
Docker-actionlint cold-pull trade-off (already documented in the seed's
wrapper as the binary-first fallback).

## 10. Implementation notes for the executing session

- Work from this document only; adopter repo access is not needed and not
  assumed. If a claim here seems insufficient to write an item, say so rather
  than guessing.
- One commit per Tier-1 item, in the numbered order above (item 8 depends on
  item 5's guidance section existing; item 7 is independent).
- Seed-meta ADRs go in `meta/decisions/` (next free numbers — rebase and scan
  open PRs before claiming, per `docs/decisions/README.md`); adopter-facing
  conventions land in the adopter-facing docs.
- Item 1's convention README: tombo's four rules (§8) are the base to adapt,
  not text to copy verbatim — reword freely, keep the four rules' substance.
- Item 4 presents **both** mechanisms without ranking them; the ADR records
  why the seed doesn't pick one (adopters chose differently, 1 vs 2, for
  documented reasons).
- Every item lands with its `meta/CHANGELOG.md` entry (MINOR for new
  conventions/files, PATCH for guidance-only), per the existing format.
- Follow-up to open as an issue, not bundled: retrofit `DISCIPLINE_ADOPTION.md` in
  the four adopters (adigator's is mostly a lift of its
  `SEED_ADOPTION_ANALYSIS.md`; tombo's consolidates its per-ADR provenance
  lines and epic #72 into the table + sync log; sid's lifts its epic #117
  table, ADR-0001, and PR #132 sync record — or stays issue-based per item
  8's allowance). The Tier-2 deferrals are already tracked in
  [#36](https://github.com/pdlourenco/disciplined-project-seed/issues/36).
