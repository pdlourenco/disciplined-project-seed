# 2026-07-17 — Three-adopter backport analysis (ppqq, adigator-embedded, tombo)

**Dated snapshot at seed `main` `090b2a7`. Will not be maintained** — it records
the state of three downstream adopters on this date and the backport decision
taken from it. Live status of the resulting work:
[#35](https://github.com/pdlourenco/disciplined-project-seed/issues/35)
(Tier 1) and
[#36](https://github.com/pdlourenco/disciplined-project-seed/issues/36)
(Tier 2). This is the seed's first `meta/analyses/` document; the
adopter-facing convention for analysis documents is itself one of the backport
items below (§8 item 1).

**Inputs.** Local checkouts of the three adopters — ppqq and
adigator-embedded studied 2026-07-17, tombo 2026-07-18 (the doc keeps the
study's start date):

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

**Method.** One deep-read subagent per adopter (all discipline docs, ADR
indexes, process ADRs in full, workflows, scripts, git history), findings
spot-verified first-hand, then deduplicated against the seed's already-absorbed
backports (§2). The tombo pass additionally scored each already-decided Tier-1
item as confirmed / contradicted / extended. The executing session does
**not** need access to the adopter repos; every claim used by the decision is
recorded here.

## 1. Adoption profiles

| | adigator-embedded | ppqq | tombo |
|---|---|---|---|
| Profile | **Minimal** — deliberate trim, decided up front in a written analysis (`docs/analyses/SEED_ADOPTION_ANALYSIS.md`) | **Full spine** — every seed artifact adopted; seed doctrine quoted verbatim in its READMEs | **Fork + catch-up sync** — v0.1.0 core, later back-ported governance (reviewer convention, labels-as-code, doc-CI, branch-protection-as-code, V&V) as issues #65–#71 / epic #72 |
| SPEC | Folded into `DESIGN.md §Contracts` ("single implementation, no cross-language/process boundaries, a standalone spec would be overhead") | Standalone `SPEC.md`, 25+ sections, per-rule `Verified by:` | Standalone `SPEC.md` + `docs/schema.toml` as a second, machine-shared contract artifact (its ADR-0008) |
| Dropped | `STRUCTURE.md`, `RISKS.md`, `LABELS.md`, labels-as-code, branch-protection-as-code, `docs/plans/` (inline ROADMAP) | Only `RISKS.md` ("adopt when the first concrete risk needs tracking, rather than shipping an empty template now") | `meta/`, `STRUCTURE.md`, `RISKS.md` (explicitly de-scoped in its epic #72); seed's `UX`/`UI` labels ("no human-facing UI surface" yet) |
| Scale evidence | Discipline held across 29 ADRs and a spec-first CI plan | Discipline held across 69 ADRs, ~24 PRs/phase; two conventions showed documented rot (§6) | Contract gates held across a polyglot boundary; prose docs and serial identifiers showed documented rot (§6) |

All three profiles worked. The lesson stands: the seed scales down by
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
slim/per-topic split, PR-template rows. Nothing from adigator-embedded or
tombo has ever been backported; tombo has so far been a pure *consumer* of
seed updates (its commits "back-port seed fix" pulled the `contents: read`,
colour-quoting, and two-layer drift fixes downstream — evidence the seed
already functions as a bidirectional fix-distribution hub).

## 3. adigator-embedded — findings

New inventions (beyond MATLAB specifics):

- **Known-issue / self-healing test lifecycle.** A documented bug ships a
  tagged test (`KnownIssue` + `assumeFail`; xfail in other frameworks) that
  detects the buggy outcome and skips, otherwise asserts — so it becomes a
  regression guard the moment the bug is fixed. The fixing PR flips the tag in
  the same PR. Their own caveat, worth carrying: a stale tag downgrades the
  guard (a re-introduced regression reports as *filtered*, not *failed*), so
  tag removal is part of the fix, and a stale-tag detector is the residual
  debt. (See §8 item 4 — tombo deliberately uses a different mechanism.)
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
- **`docs/analyses/`** — see §7.
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
  strongest single motivation observed for the `SEED_ADOPTION.md` marker
  (§8 item 8).
- **Visible-debt markers instead of xfail** (its ADR-0022): rules found with
  no automated verifier get a visible-debt marker in SPEC plus an entry in a
  tracking issue, *deliberately rejecting* a forced same-PR test gate. Its
  2026-07-16 independent review notes "no skip/xfail anywhere." A second,
  incompatible mechanism for the same problem adigator solves with
  self-healing tests — see §8 item 4.
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
  reproducing ppqq's §6.2 finding. Recommended remedy: fold a doc-refresh
  step into the contract-change checklist.
- **markdownlint auto-fix hazard** (its ADR-0020): auto-fixes silently
  changed meaning twice (`__pycache__` → `**pycache**`; a trailing-space
  code span collapsed). Lesson: review auto-fix output; disable
  meaning-changing rules (e.g. MD038) rather than accept their fixes.
- **Doc-CI exclusion-set triplication**: the same template skip-list is
  hand-duplicated across the markdownlint config and two workflow `find`
  invocations with KEEP-IN-SYNC notes — the same seam the seed itself
  carries; tombo names a promotion trigger for factoring it out.

## 6. Convention-failure evidence (the most valuable findings)

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

## 7. Convergent signal — the analyses folder

All three adopters independently created one:

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

The folder fills a real gap — analysis artifacts that are neither decisions
(ADRs) nor living contracts (SPEC/DESIGN). Tombo's README is close to the
convention text the seed should ship; the immutability-plus-pointers rule is
what keeps the folder from becoming a stale-doc graveyard.

## 8. Backport decision

Maintainer approved 2026-07-17 (originally from the two-adopter study; items
1, 2, 5, 7, 8 extended and item 4 materially changed 2026-07-18 after the
tombo pass). **Tier 1** ships as one PR series (one commit per item;
seed-meta ADRs where marked), tracked in
[#35](https://github.com/pdlourenco/disciplined-project-seed/issues/35).
**Tier 2** is parked as one `deferred + decided` issue with named triggers,
[#36](https://github.com/pdlourenco/disciplined-project-seed/issues/36).

Tier 1:

1. **`analyses/` as a first-class optional doc type** — adopter-facing
   convention at `docs/analyses/` with a convention README covering the
   usage models from §7. **Start from tombo's four rules** (dated filename,
   anchored-to-a-commit, immutable-once-merged, not-a-contract), extended
   with the canonical-register variant (adigator) and the periodic
   independent-review → issues → remediation-phase loop (ppqq, tombo). The
   seed dogfoods it as `meta/analyses/` (this document); the maintainer
   settled the naming on `analyses` (plural). *(all three adopters —
   convergent)* **ADR.**
2. **Contract-gate pattern catalogue + drift-hardening doctrine** — extend
   `docs/CONTRIBUTING.md §"CI strategy" §1` with the §4 gate patterns
   (codegen-diff, set-for-set enrollment, totality-over-enum, spec-prose
   parsing, metadata-derived cross-check) plus tombo's **shared
   contract-artifact pattern** (§5: one machine-parsed file both sides
   consume — "drift structurally impossible" — preferred over
   mirror-plus-equality-test where feasible, with the polyglot
   integration-probe gate). State the doctrine; fold the §6.2 "prose points,
   doesn't restate" caveat into the pointer-index guidance and add a
   prose-refresh step to the contract-change checklist; carry tombo's
   caveats that a gate must test the production idiom (not a test-oriented
   reimplementation) and that `Verified by:` annotations need a cross-check
   (§6.3). Patterns only; contents stay downstream. *(ppqq + tombo)* **ADR.**
3. **Deferral-sweep step** — pair the deferred-with-conditions convention
   with a sweep: on phase completion (PHASE-TEMPLATE §10 admin) and in the
   contributing guidance, scan for deferrals whose named trigger fired.
   Evidence: §6.1. Tombo confirms the need in weaker form (pervasive named
   triggers, no sweep mechanism). *(ppqq)*
4. **Known-bug lifecycle — two documented mechanisms, presented as
   options.** *(Changed from the two-adopter decision, which prescribed the
   xfail mechanism alone; tombo deliberately rejects it.)* Present both with
   trade-offs and let adopters choose per their test culture:
   (a) **self-healing xfail tests** (adigator, §3): a tagged test that skips
   on the buggy outcome and asserts otherwise; becomes a regression guard on
   fix; the fixing PR flips the tag; stale tags are the residual debt.
   (b) **visible-debt markers + register** (tombo, §5): unverified rules get
   a marker in SPEC plus an entry in a tracking issue; no forced same-PR
   test. Common core for the PR checklist either way: *a bug fix closes its
   known-bug tracking artifact (tag or marker) in the same PR.*
   *(adigator + tombo)* **ADR.**
5. **Scale-based adoption guidance** — a short "adopting at small scale"
   section (README or CONTRIBUTING): the three-profile contrast from §1 with
   thresholds (single implementation → SPEC folds into `DESIGN §Contracts`;
   solo/small team → labels-as-code and branch-protection-as-code optional;
   small scope → inline ROADMAP), the frozen-`notes/` migration pattern for
   pre-existing material (ppqq), the fork + catch-up-sync path as a third
   adoption mode (tombo), and the vocabulary-reconciliation warning (§1:
   diff the seed's names — tiers, labels, section titles — against local
   usage before importing). *(all three)*
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
   *(all three)*
8. **`SEED_ADOPTION.md` marker** — new template file recording seed
   provenance (repo URL + seed version/SHA + date), a per-artifact adoption
   table (`adopted` / `adapted (where)` / `dropped (why/ADR)`), an
   append-only sync log (date + seed ref range + taken/skipped), and an
   optional backport log. Referenced from the item-5 guidance ("choose your
   profile, record it here"). Enables both flow directions: backport studies
   like this one, and seed-update flow-down (diff the seed from your last
   recorded ref, triage against your table). Tombo is the motivating
   counterexample: its provenance is distributed per-ADR with no version pin
   and no sync log, which is exactly what made its sync state expensive to
   reconstruct. *(maintainer-originated, this study)* **ADR.**

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
in item 2), local-ci self-healing extensions (machine-specific), tombo's
Docker-actionlint cold-pull trade-off (already documented in the seed's
wrapper as the binary-first fallback).

## 9. Implementation notes for the executing session

- Work from this document only; adopter repo access is not needed and not
  assumed. If a claim here seems insufficient to write an item, say so rather
  than guessing.
- One commit per Tier-1 item, in the numbered order above (item 8 depends on
  item 5's guidance section existing; item 7 is independent).
- Seed-meta ADRs go in `meta/decisions/` (next free numbers — rebase and scan
  open PRs before claiming, per `docs/decisions/README.md`); adopter-facing
  conventions land in the adopter-facing docs.
- Item 1's convention README: tombo's four rules (§7) are the base to adapt,
  not text to copy verbatim — reword freely, keep the four rules' substance.
- Item 4 presents **both** mechanisms without ranking them; the ADR records
  why the seed doesn't pick one (two adopters chose differently for
  documented reasons).
- Every item lands with its `meta/CHANGELOG.md` entry (MINOR for new
  conventions/files, PATCH for guidance-only), per the existing format.
- Follow-up to open as an issue, not bundled: retrofit `SEED_ADOPTION.md` in
  the three adopters (adigator's is mostly a lift of its
  `SEED_ADOPTION_ANALYSIS.md`; tombo's consolidates its per-ADR provenance
  lines and epic #72 into the table + sync log). The Tier-2 deferrals are
  already tracked in
  [#36](https://github.com/pdlourenco/disciplined-project-seed/issues/36).
