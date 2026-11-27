# ADR-0024 — Adoptable forge files: `.github/` stays the adopters' copy, seed-only behaviour keyed to the seed's repository, other forges get `forges/<forge>/`

## Status

Accepted — 2026-11-27, by maintainer decision on PR #77: the Decision
below rather than #76's `.forge/` copy (alternative A), and the two
questions this ADR left open answered as recommended (Decision 4 and 5).
Proposed 2026-11-22. Raised by the maintainer in
[#76](https://github.com/pdlourenco/disciplined-project-seed/issues/76),
which proposes separating the forge files adopters receive from the ones
the seed runs. Revised after the maintainer's review on PR #77 (2026-11-23):
seed-only values stay in the workflow, keyed to the seed's repository,
instead of in repository settings. Builds on
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
  shipped, unless an adopter keeps a `meta/` of their own: on an adopter's
  repository there is usually no `meta/` to remove, and template users want
  the seed's out anyway.
- Comments in `branch-protection.yml`, `labels.yml`, `sync-labels.yml` and
  `setup-branch-protection.sh` cite `meta/decisions/ADR-*` by repo-relative
  path, which breaks once an adopter strips `meta/`;
  `check-branch-protection.yml` cites the seed repository by absolute URL,
  which survives.

So the seed-only part is one value, one block of release-note text and a
few broken comment links: configuration and wording, not files. (Relative
links into `meta/` from the docs adopters keep break the same way;
CONTRIBUTING alone has eighteen. They are outside the forge files and
tracked in [#79](https://github.com/pdlourenco/disciplined-project-seed/issues/79).)

## Decision

1. **`.github/` stays the adoptable GitHub set.** The seed runs exactly the
   files adopters receive, so the seed's CI keeps testing them, and "Use
   this template" keeps giving a GitHub adopter working CI with no
   placement step.
2. **Seed-only behaviour is keyed to the seed's repository, in the file.**
   A seed-only value depends on the repository the workflow runs in, so it
   stays versioned and reviewed like any other change, while a template
   copy or fork, which has another name, gets the adopter's default with
   nothing to set:
   - `CHANGELOG_PATH: ${{ github.repository ==
     'pdlourenco/disciplined-project-seed' && 'meta/CHANGELOG.md' ||
     'CHANGELOG.md' }}`;
   - the release-notes footer is a step guarded by the same condition, its
     text kept in the file.

   `ARCHIVE_EXCLUDES` stays hardcoded as `meta`, harmless for adopters as
   above. The comment links in the Context become absolute URLs to the
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
   README's forge table points at a set when one exists. A set mirrors
   the forge's own layout under `forges/<forge>/` (for Gitea,
   `forges/gitea/workflows/` for what runs from `.gitea/workflows/`), and
   the adopter moves it into place, as a template user strips `meta/` by
   hand today.
4. **A change to `forges/` needs a human merge** (#76's question 5).
   CONTRIBUTING §"Merge authority" gains the role "files this repository
   distributes for others to run as their CI (here `forges/`)". In the
   seed, `forges/` runs nothing and sets no agent's authority, which is
   that list's usual criterion; the concern is different: a change there
   alters what every adopter on that forge will run. The rule sits where
   an agent deciding an `agent:auto` merge reads it, and in an adopter's
   repository it simply matches nothing. Rejected: a seed-only rule in
   `meta/`, which no agent reads when deciding a merge, so it would need a
   pointer from §"Merge authority" or forge enforcement such as a required
   code-owner review on `forges/**`.
5. **§"Merge authority" also covers the scripts a required check runs.**
   Its roles covered the workflow directory, branch protection and its
   scripts, and the label catalogue, but not `audit-placeholders.py`,
   though it backs a required check: an agent could weaken a required
   check through its script and merge that under the label. The new role,
   "the scripts a required check runs", covers it (and its kin) on any
   forge. The PR and issue templates and `release_changelog.py` stay out:
   they set no agent's authority. This gap existed before this ADR; it is
   closed here because the same list changes for Decision 4.

## Consequences

- **No drift check is needed for GitHub.** There is one copy of the GitHub
  files, and the seed's CI runs it. For `forges/<forge>/`, drift is
  expected and visible instead: each set records the seed version it
  matches.
- **Nothing to set, and nothing unversioned.** The seed's release
  behaviour is all in its files, as ADR-0015 intends; nothing waits in
  Settings to be forgotten before the implementing PR merges.
- **Adopters' files name the seed's repository** in two expressions. That
  is harmless where it never matches. If the seed repository is renamed or
  moved, the expressions must change with it, or the seed's release falls
  back to the adopter defaults: the gate then reads the root
  `CHANGELOG.md`, which has no version heading, so `release_changelog.py
  validate` fails and the release stops. That failure is loud.
- **Template users keep today's behaviour** (#76's question 1): they get
  `.github/` working, plus `forges/`, which they can delete or use.
- **`forges/<forge>/` is untested by the seed** (#76's question 3), and says
  so where it lives.
- **The seed-only list** (#76's question 4) is the Context's list, plus any
  future `seed-*.yml`. It is kept with the seed's own record in `meta/`
  (for example `meta/README.md`), not in CONTRIBUTING, which adopters
  receive.
- **Implementation follows acceptance**, in its own PR: the two repository-keyed values
  and the hardcoded exclusion in `release.yml` (and its comments, which
  tell adopters to flip or adapt those values), `release_changelog.py`'s
  docstring that names `meta/CHANGELOG.md`, the absolute comment links,
  CONTRIBUTING and README updates, the lint paths, the two new
  §"Merge authority" roles (Decision 4 and 5), and a `forges/README.md` explaining the convention. A Gitea
  set arrives when an adopter contributes one.

## Alternatives considered

- **A. `.forge/github/` as a second copy (#76 as proposed).** Cleanly
  separates the seed's files from the adopters', and the release archive
  could place `.forge/github/` into `.github/`. A placement step for
  template users would cost about what they already pay, since they strip
  `meta/` by hand. Not recommended: it duplicates every GitHub file and
  needs a CI check to keep the two copies identical, for a coupling that
  comes down to one value and one block of text, which repository-keyed
  values handle without a copy.
- **B. Status quo: adopters edit the seed-only parts themselves.** No work.
  Not recommended: every adopter has to find and flip `CHANGELOG_PATH`, and
  a missed flip points their release gate at the seed's history; and every
  adopter's releases carry the seed's footer until someone notices.
- **C. A hidden `.forge/` directory for other forges** (#76's question 6). Matches the forges'
  own dot-directories. Not recommended, for the reason ADR-0006 gave for
  `meta/`: adopters who want these files should not have to discover a
  hidden directory.
- **D. Seed-only parts marked by comments inside shared files.** No new
  mechanism. Not recommended: a comment does not stop an adopter's copy
  from running seed behaviour; a repository-keyed condition does.
- **E. Actions repository variables with adopter defaults**
  (`vars.CHANGELOG_PATH || 'CHANGELOG.md'`, and the footer text as a
  variable). This ADR's first draft. Keeps the seed's name out of
  adopters' files. Not recommended: it puts the seed's release behaviour
  in settings nobody reviews or diffs, the gap ADR-0005 closed for branch
  protection ("the prose claim and the live config are independent;
  nothing enforces that they match"), and an unset footer variable would
  fail quietly.
