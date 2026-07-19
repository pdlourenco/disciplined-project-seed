# Analysis documents

Dated, immutable analysis snapshots: independent repo-wide reviews, field
reports, audits, adoption or backport studies. An **optional** doc type — add
the folder when the first analysis is written, not before.

Analyses fill a gap the rest of the doc set leaves open. They are neither
decisions ([`../decisions/`](../decisions/README.md) records what was chosen
and why) nor living contracts or rationale (`SPEC.md` / `DESIGN.md` are
maintained to stay true). An analysis records **what was observed at a point
in time** and is then left alone.

## The four rules

1. **Dated filename.** `YYYY-MM-DD-<slug>.md`, dated by when the analysis was
   performed, not when it merges.
2. **Anchored to a commit.** Each analysis names the commit it examined
   (typically `main`'s SHA at the time). `file:line` references are relative
   to that commit and are expected to drift afterwards — that is not an
   error.
3. **Immutable once merged.** Findings are not edited as they get fixed; the
   follow-up issues and PRs are the live tracking surface. Amendments land
   while the analysis's PR is open; after merge, supersede by writing a new
   dated analysis. Each document should say so up front ("dated snapshot,
   will not be maintained") and point at where live status is tracked.
4. **Not a contract.** Nothing in an analysis binds implementations. Binding
   text lives in `SPEC.md`; decisions live in ADRs. An analysis can motivate
   either — the authoritative text then moves there.

The immutability-plus-pointers rule is what keeps this folder from becoming
a stale-doc graveyard: nothing in it claims to be current, so nothing in it
can rot.

## Usage models

Three usage models; combine freely:

- **Dated snapshot series** — field reports, code-quality reviews,
  reassessments. Each self-declares its snapshot state and points at the
  live surfaces (`ROADMAP.md`, the issue tracker, a bug register) for
  current status.
- **Canonical registers** — a small number of *living* catalogue documents
  (for example, a numbered bug register other docs cite by stable IDs).
  These are the deliberate exception to rule 3 — registers, not snapshots —
  and must be clearly marked as such at the top of the file.
- **Periodic independent review loop** — a dated whole-repo review by a
  non-authoring session or contributor; findings are converted to tracked
  issues, and the issues scope the remediation work (a dedicated remediation
  phase, or targeted PRs). The document is the narrative; the tracker is the
  register.

## See also

- [`../decisions/README.md`](../decisions/README.md) — where a decision an
  analysis motivates gets recorded.
- The seed dogfoods this convention on itself under `meta/analyses/`
  (adopters strip `meta/`; this folder is your project's own).
