# ADR-0024 — Adoptable forge files: `.github/` stays the adopters' copy, seed-only behaviour moves to settings, other forges get `forges/<forge>/`

## Status

Proposed — 2026-11-22. Raised by the maintainer in
[#76](https://github.com/pdlourenco/disciplined-project-seed/issues/76),
which proposes separating the forge files adopters receive from the ones
the seed runs. This ADR recommends a lighter shape than #76's `.forge/`
copy; the choice between them, and two open questions below, are the
maintainer's. Builds on
[ADR-0006](ADR-0006-meta-folder-for-seed-history.md) (`meta/` for the
seed's own history), [ADR-0015](ADR-0015-release-as-code.md) (release
workflow and template archive) and
[ADR-0020](ADR-0020-provider-and-forge-neutral-interfaces.md) (the forge
files are one realisation of neutral roles), and on #75's README table and
role-named authority paths.

## Context

The seed holds content for adopters, content that serves both the seed and
adopters, and the seed's own record (ADR-0006 moved the last into `meta/`).
The forge files (`.github/`, `scripts/setup-branch-protection.sh`,
`scripts/normalize-branch-protection.jq`) serve both: the seed runs them
and adopters inherit them. #76 names two costs:

- **The seed cannot change its own CI without changing what adopters get.**
- **A non-GitHub adopter gets a table of fallbacks (#75), not working files.**

What in those files is the seed's own, as of `d0c1c04`. "Seed-only" here
means content that is wrong for an adopter as shipped; a starting state
adopters share and later adjust (the CI jobs, the lint and link-check
exclusion lists, the label catalogue) is not seed-only.

- `release.yml` sets `CHANGELOG_PATH: meta/CHANGELOG.md`: an adopter must
  flip it to their root `CHANGELOG.md`, or the release gate reads the
  seed's history.
- `release.yml` appends an "**Adopting?** … seed-meta pre-stripped" footer
  to every release's notes: text about the seed's own template archive,
  wrong on an adopter's releases.
- `release.yml` sets `ARCHIVE_EXCLUDES: meta`. This one is harmless as
  shipped: on an adopter's repository there is no `meta/` to remove, and
  template users want it out anyway.
- Comments in `branch-protection.yml`, `labels.yml`, `sync-labels.yml` and
  `setup-branch-protection.sh` cite `meta/decisions/ADR-*` by repo-relative
  path, which breaks once an adopter strips `meta/`;
  `check-branch-protection.yml` cites the seed repository by absolute URL,
  which survives.

So the seed-only part is one value, one block of release-note text and a
few broken comment links: configuration and wording, not files.

## Decision

1. **`.github/` stays the adoptable GitHub set.** The seed runs exactly the
   files adopters receive, so the seed's CI keeps testing them, and "Use
   this template" keeps giving a GitHub adopter working CI with no
   placement step.
2. **Seed-only behaviour moves out of the files and into repository
   settings.** A workflow reads a seed-only value from an Actions
   repository variable with an adopter's default:
   - `CHANGELOG_PATH`: `${{ vars.CHANGELOG_PATH || 'CHANGELOG.md' }}`; the
     seed sets `meta/CHANGELOG.md`;
   - the release-notes footer: `vars.RELEASE_NOTES_FOOTER`, empty by
     default; the seed sets its "Adopting?" text.

   `ARCHIVE_EXCLUDES` stays hardcoded as `meta`, harmless for adopters as
   above, so a missing variable can never ship `meta/` in the seed's
   archive. The comment links in the Context become absolute URLs to the
   seed repository. A seed-only step that cannot be a value would live in a
   workflow named `seed-*.yml`, which the template archive strips and the
   README tells template users to delete; today there is none.
3. **Other forges get `forges/<forge>/`**, a visible directory with a
   working set of forge files for that forge, contributed by an adopter who
   runs it (#70's Gitea adopter is the obvious first). Each set's README
   says the seed does not run it (it is that adopter's experience, as #75's
   table is) and records the seed version it was last brought in line with,
   so an adopter can see how far it trails `.github/`. The seed lints what
   it can: YAML everywhere, and `actionlint` on `forges/*/workflows/` where
   the syntax is GitHub-compatible, added to the lint job's paths. The
   README's forge table points at a set when one exists.

## Open questions for the maintainer

1. **Who merges a change to `forges/`?** In the seed, `forges/` runs
   nothing, so it sets no agent's authority, which is CONTRIBUTING
   §"Merge authority"'s criterion. The concern is different: a change there
   alters what every adopter on that forge will run.
   - **(a) Recommended:** a seed-only rule in `meta/` (for example in
     `meta/README.md`) that a PR changing `forges/` needs the maintainer's
     merge. *Why:* it keeps §"Merge authority"'s criterion clean, and keeps
     seed-specific wording out of CONTRIBUTING, which adopters receive; the
     coupling this ADR removes.
   - **(b)** Add "the forge files adopters receive" as a role in
     §"Merge authority": one list, but a mixed criterion, and wording that
     only makes sense in the seed.
2. **Widen §"Merge authority" to all of `.github/`?** Its roles cover the
   workflow directory, branch protection and its scripts, and the label
   catalogue, but not the PR and issue templates, `release_changelog.py`,
   or `audit-placeholders.py`, though the last backs a required check. That
   gap exists today, independent of this ADR. Recommended: add "the scripts
   a required check runs" as a role, which covers `audit-placeholders.py`
   (and its kin) on any forge; leave the templates out, since they set no
   authority.

## Consequences

- **No drift check is needed for GitHub.** There is one copy of the GitHub
  files, and the seed's CI runs it. For `forges/<forge>/`, drift is
  expected and visible instead: each set records the seed version it
  matches.
- **The seed's release depends on two repository variables.** If
  `CHANGELOG_PATH` is unset, the gate reads the root `CHANGELOG.md`, which
  has no version heading, so `release_changelog.py validate` fails and the
  release stops: loud. If `RELEASE_NOTES_FOOTER` is unset, the seed's
  release ships without the footer: quiet, and cosmetic. The implementing
  PR sets both before it merges.
- **Template users keep today's behaviour** (#76's question 1): they get
  `.github/` working, plus `forges/`, which they can delete or use.
- **`forges/<forge>/` is untested by the seed** (#76's question 3), and says
  so where it lives.
- **The seed-only list** (#76's question 4) is the Context's list, kept in
  CONTRIBUTING beside §"Required status checks", plus any future
  `seed-*.yml`.
- **Implementation follows acceptance**, in its own PR: the two variables
  and the hardcoded exclusion in `release.yml`, the absolute comment links,
  CONTRIBUTING and README updates, the lint paths, the answer to the open
  questions, and a `forges/README.md` explaining the convention. A Gitea
  set arrives when an adopter contributes one.

## Alternatives considered

- **A. `.forge/github/` as a second copy (#76 as proposed).** Cleanly
  separates the seed's files from the adopters', and the release archive
  could place `.forge/github/` into `.github/`. A placement step for
  template users would cost about what they already pay, since they strip
  `meta/` by hand. Not recommended: it duplicates every GitHub file and
  needs a CI check to keep the two copies identical, for a coupling that
  comes down to one value and one block of text, which settings handle
  without a copy.
- **B. Status quo: adopters edit the seed-only parts themselves.** No work.
  Not recommended: every adopter has to find and flip `CHANGELOG_PATH`, and
  a missed flip points their release gate at the seed's history; and every
  adopter's releases carry the seed's footer until someone notices.
- **C. A hidden `.forge/` directory for other forges.** Matches the forges'
  own dot-directories. Not recommended, for the reason ADR-0006 gave for
  `meta/`: adopters who want these files should not have to discover a
  hidden directory.
- **D. Seed-only parts marked by comments inside shared files.** No new
  mechanism. Not recommended: a comment does not stop an adopter's copy
  from running seed behaviour; a setting with a default does.
