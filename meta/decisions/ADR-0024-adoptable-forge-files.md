# ADR-0024 — Adoptable forge files: `.github/` stays the adopters' copy, seed-only behaviour moves to settings, other forges get `forges/<forge>/`

## Status

Proposed — 2026-11-22. Raised by the maintainer in
[#76](https://github.com/pdlourenco/disciplined-project-seed/issues/76),
which proposes separating the forge files adopters receive from the ones
the seed runs. This ADR recommends a lighter shape than #76's `.forge/`
copy; the choice is the maintainer's. Builds on
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

How much of `.github/` is actually the seed's own, as of `d0c1c04`:

- `release.yml` sets `CHANGELOG_PATH: meta/CHANGELOG.md` and
  `ARCHIVE_EXCLUDES: meta`. Both are values: an adopter "flips" the first
  and "adapts" the second (the file's own comments say so).
- Several files cite `meta/decisions/ADR-*` in comments, as links to the
  seed repository; they still resolve after an adopter strips `meta/`.
- Everything else (the CI jobs, templates, label catalogue, branch
  protection, scripts) is what an adopter keeps and extends.

So the seed-only part is small, and it is configuration, not files.

## Decision

1. **`.github/` stays the adoptable GitHub set.** The seed runs exactly the
   files adopters receive, so the seed's CI keeps testing them, and "Use
   this template" keeps giving a GitHub adopter working CI with no
   placement step.
2. **Seed-only behaviour moves out of the files and into repository
   settings.** A workflow reads a seed-only value from an Actions
   repository variable with an adopter's default:
   `CHANGELOG_PATH` (`vars.CHANGELOG_PATH || 'CHANGELOG.md'`) and
   `ARCHIVE_EXCLUDES` (default: none). The seed sets the variables to
   `meta/CHANGELOG.md` and `meta` in its own repository settings; an
   adopter's copy works unchanged. A seed-only step that cannot be a value
   lives in a workflow named `seed-*.yml`, which the template archive
   strips and the README tells template users to delete. Today there is
   none.
3. **Other forges get `forges/<forge>/`**, a visible directory with a
   working set of forge files for that forge, contributed by an adopter who
   runs it (#70's Gitea adopter is the obvious first). Each set says, in
   its own README, that the seed does not run it: it is that adopter's
   experience, as #75's table is. The seed lints what it can (YAML, and
   `actionlint` where the syntax is GitHub-compatible), and runs none of it.
   The README's forge table points at the set when one exists.
4. **Adoptable forge files are agent-authority paths in the seed.** A change
   to `forges/` changes what every adopter on that forge will run, so it
   joins the role-named list in CONTRIBUTING §"Merge authority" as "the
   forge files adopters receive (here `.github/`, `forges/`, and the
   branch-protection scripts)". `.github/` is covered already by the
   workflow and branch-protection roles; this names the rest.

## Consequences

- **No drift check is needed.** There is one copy of the GitHub files, and
  the seed's CI runs it. #76's question 2 disappears.
- **The seed's release depends on two repository variables.** If they are
  unset, the seed's release reads `CHANGELOG.md` (which is the adopter
  template, not the seed's history) and builds an archive that keeps
  `meta/`. The implementing PR sets them before it merges, and the seed's
  `release.yml` fails the gate if `CHANGELOG_PATH`'s file has no section for
  the tag, as it does today, so a missing variable fails loudly.
- **Template users keep today's behaviour** (#76's question 1): they get
  `.github/` working, plus `forges/`, which they can delete or use.
- **`forges/<forge>/` is untested by the seed** (#76's question 3), and says
  so where it lives.
- **The seed-only list** (#76's question 4) is short and lives in one
  place: the variables in decision 2, listed in CONTRIBUTING beside
  §"Required status checks", and any future `seed-*.yml`.
- **Implementation follows acceptance**, in its own PR: the two variables in
  `release.yml`, CONTRIBUTING and README updates, the authority-path line,
  and an empty `forges/README.md` explaining the convention. A Gitea set
  arrives when an adopter contributes one.

## Alternatives considered

- **A. `.forge/github/` as a second copy (#76 as proposed).** Cleanly
  separates the seed's files from the adopters'. Rejected for now: it
  duplicates every GitHub file, needs a CI check to keep the two copies
  identical, and leaves "Use this template" users with unplaced files
  unless the seed's own `.github/` stays adoptable too, which brings back
  the coupling it set out to remove. The coupling it fixes amounts to two
  values, which settings handle without a copy.
- **B. Status quo: adopters edit the seed-only values themselves.** No
  work. Rejected: every adopter has to find and flip `CHANGELOG_PATH`, and
  a missed flip points their release gate at the seed's history.
- **C. A hidden `.forge/` directory for other forges.** Matches the forges'
  own dot-directories. Rejected for the reason ADR-0006 gave for `meta/`:
  adopters who want these files should not have to discover a hidden
  directory.
- **D. Seed-only files marked by comments inside shared files.** No new
  mechanism. Rejected: a comment does not stop an adopter's copy from
  running seed behaviour; a setting with a default does.
