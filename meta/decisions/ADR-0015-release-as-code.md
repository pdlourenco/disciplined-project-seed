# ADR-0015 — Release-as-code: tag-push workflow with a CHANGELOG gate and a curated template archive

## Status

Accepted — 2026-07-20. Implements
[#42](https://github.com/pdlourenco/disciplined-project-seed/issues/42);
maintainer-approved direction (conversation, 2026-07-19). Operationalised
in [`.github/workflows/release.yml`](../../.github/workflows/release.yml)
and [`.github/scripts/release_changelog.py`](../../.github/scripts/release_changelog.py).

## Context

ADR-0013's supporting change had the seed **cutting a git tag at each
`meta/CHANGELOG.md` version**, so `DISCIPLINE_ADOPTION.md` pins
(`vX.Y.Z (sha)`) resolve and a flow-down pass is "read the seed CHANGELOG
between two pinned versions". As shipped that was a *discipline-only*
convention — a human remembering to tag, and to tag a commit whose
CHANGELOG is actually in the right shape. That is exactly the class the
four-adopter study
([`meta/analyses/2026-07-17-…`](../analyses/2026-07-17-ppqq-adigator-tombo-sid-backport-analysis.md))
documented rotting: a deferred-with-trigger promise that nothing enforces
drifts silently. A tag pushed against a commit whose `[Unreleased]` section
hadn't been cut yet would produce a pin that resolves to a misleading
CHANGELOG span, and nothing would catch it.

Two further forcing functions from the same issue:

- **Adoption still starts with manual stripping.** README step 2 tells an
  adopter to `rm -rf meta/` for a clean start. A release that attaches a
  **pre-stripped template archive** makes "download the latest release" the
  clean-start path — no manual deletion, no risk of shipping seed-meta into
  a fork. The backport study noted a curated-archive release pattern
  downstream and parked it as niche in its polyglot form; the general,
  reusable shape belongs in the seed.
- **Releases are also a passive update feed.** GitHub releases are
  subscribable, `vA...vB` compare URLs become stable, and each
  `DISCIPLINE_ADOPTION.md` pin lands on a real release page carrying its
  CHANGELOG section.

Options considered: (A) tag-push workflow that validates + publishes;
(B) manual `workflow_dispatch` release; (C) fully-automatic
release-on-merge.

## Decision

Ship [`.github/workflows/release.yml`](../../.github/workflows/release.yml),
triggered on `push:` of `v*` tags. On each tag push it:

1. **Validates (the gate):** the pushed `vX.Y.Z` must have a matching
   `## [X.Y.Z] — YYYY-MM-DD` CHANGELOG section, and `[Unreleased]` must be
   empty, both at the tagged commit. Any mismatch fails the run with an
   actionable message and creates no release. The gate logic lives in
   [`release_changelog.py`](../../.github/scripts/release_changelog.py) — a
   real script, not inline one-liners, so it is exercisable without pushing
   a tag.
2. **Extracts** that version's CHANGELOG section as the release body.
3. **Assembles** a curated `<repo>-vX.Y.Z-template.zip` / `.tar.gz` from the
   tagged tree minus the exclusion list, and attaches it. The auto-generated
   "Source code" archives remain the everything-included variant; the
   release body points newcomers at the template asset.
4. **Creates** the release with `gh release create`, `GH_REPO` set
   explicitly per `docs/CONTRIBUTING.md` §"`gh` CLI in workflows".

**Stance: human decides, machine executes and validates** — the same
posture as ADR-0005's human-triggered branch-protection apply. The
maintainer makes the release decision by pushing the tag; the workflow does
the ceremony and enforces the tag↔CHANGELOG pairing.

**Exclusion list: `meta/` only (default).** `git archive` already omits
`.git` and untracked files, so seed-meta is the only thing to strip.
Everything else stays in because it *is* the discipline the archive is
meant to carry: `scripts/` (branch-protection apply + jq filter,
`local-ci.sh`), `.github/` (labels-as-code, branch-protection desired
state, active CI baseline, drift/label-sync workflows, issue/PR templates),
and `.claude/` (SessionStart doc-CI scaffolding). `.claude/` is the one
marginal call — dropping it would make the archive Claude-agnostic — but
the meta/-only default keeps it; an adopter who wants it gone edits the one
`ARCHIVE_EXCLUDES` variable.

**Adopter-facing parameterization.** Both the CHANGELOG path
(`CHANGELOG_PATH`) and the exclusion list (`ARCHIVE_EXCLUDES`) are single,
commented `env:` variables at the top of the workflow: the seed sets
`meta/CHANGELOG.md` and `meta`; an adopter flips them to `CHANGELOG.md` and
their own list. This ships as a small **"release-as-code" adopter
convention**, not seed-only plumbing.

## Consequences

- The tag↔CHANGELOG convention from ADR-0013 becomes a **structural gate**
  (`docs/CONTRIBUTING.md` §"CI strategy" §1, drift-hardening doctrine): a
  tag pushed against an un-cut CHANGELOG fails loudly instead of minting a
  misleading pin.
- Adoption gains a clean-start path (download the template asset) that can't
  accidentally include seed-meta, and adopters get a subscribable update
  feed with stable compare URLs.
- The seed takes on a **`contents: write`** workflow — its first — but the
  scope is justified and narrow: it runs only on `v*` tag pushes, never on
  arbitrary `main` pushes. A tag pusher is already trusted with the release
  decision.
- **Branch protection is unaffected.** The workflow triggers on tags, not
  pull requests, so it is not a merge-gating status check; no
  `.github/branch-protection.yml` context is added and the `check-bp-contexts`
  consistency check is untouched.
- Cutting a release now has a required shape: move `[Unreleased]` → a dated
  `## [X.Y.Z]` section in a release PR *before* tagging. That is a small
  recurring cost, and the gate's error messages name the exact fix.
- No new third-party action is introduced — plain `gh` + shell keeps the
  ADR-0001 SHA-pinning surface at zero for this workflow.

## Alternatives considered

- **Manual `workflow_dispatch` release (B).** A maintainer runs the workflow
  from the Actions tab, passing the version. Rejected as the primary trigger:
  the tag is the natural, git-native record of "this commit is release
  X.Y.Z", and `DISCIPLINE_ADOPTION.md` pins already reference tags. A tag
  push *is* the decision; a separate dispatch is a second, redundant one.
  (`workflow_dispatch` could be added later as a re-run convenience without
  changing the model.)
- **Fully-automatic release-on-merge (C).** Every merge to `main` that bumps
  the CHANGELOG cuts a release. Rejected: it inverts the human-decides
  stance (the machine would decide *when* to release), and it needs write
  permissions on every `main` push rather than only on tag pushes —
  strictly more standing authority for strictly less control.
- **A packaged release Action** (e.g. a marketplace `create-release`).
  Rejected in favour of plain `gh` + shell: `gh` is pre-installed on the
  runner, and avoiding a third-party action keeps the SHA-pin surface
  (ADR-0001) empty for this workflow.
- **Excluding `scripts/` / `.github/` / `.claude/` from the archive too.**
  Rejected: those directories are the largest part of the conventions the
  template exists to deliver. Stripping them would ship a docs-only skeleton
  and defeat the "clean start *with the discipline*" purpose. `.claude/`
  alone is a defensible drop (Claude-agnostic archive); left to the adopter
  via `ARCHIVE_EXCLUDES`.
- **Gate as inline workflow one-liners.** Rejected: the tag↔CHANGELOG check
  is the load-bearing part of this ADR and must be exercisable without
  pushing a tag. A script (`release_changelog.py`) can be dry-run against
  fixtures; a `run:` heredoc cannot.
- **Do nothing (keep tags as a discipline-only convention).** Rejected: this
  is precisely the un-enforced-convention shape the four-adopter study found
  rotting, and a mis-cut pin degrades the flow-down mechanism ADR-0013 built.
