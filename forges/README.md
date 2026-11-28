# `forges/`: working files for forges other than GitHub

The seed's GitHub files live where GitHub reads them, in `.github/`; the seed runs them, and "Use this template" gives a GitHub adopter working CI. This directory holds the equivalent for other forges, one set per forge, contributed by an adopter who runs it ([ADR-0024](https://github.com/pdlourenco/disciplined-project-seed/blob/main/meta/decisions/ADR-0024-adoptable-forge-files.md)).

There is no set yet. Until one arrives, the README's §"On a forge other than GitHub" table lists the fallbacks one adopter on Gitea chose for each GitHub-specific file.

## What a set is

- **One directory per forge**, `forges/<forge>/`, mirroring that forge's own layout. For Gitea, `forges/gitea/workflows/` holds what runs from `.gitea/workflows/`, and `forges/gitea/ISSUE_TEMPLATE/` what Gitea reads from `.gitea/ISSUE_TEMPLATE/`.
- **A README in the set** that says who contributed it, that the seed does not run it, and the seed version it was last brought in line with, so a reader can see how far it trails `.github/`.
- **Only what differs from `.github/`.** Files that work unchanged on that forge (the scripts under `.github/scripts/`, for example) are not copied; the set's README says which ones to take from `.github/`.

## What the seed checks

The seed has no runner for other forges, so a set is that adopter's experience, as the README's table is. The seed lints what it can:

- `actionlint` runs on `forges/*/workflows/` in the workflow-lint job, so put only GitHub-Actions-compatible workflow files there (Gitea Actions and Forgejo Actions mostly are). A forge with another syntax keeps its CI file elsewhere in its set (for GitLab, `forges/gitlab/.gitlab-ci.yml`), where it is not linted.
- Markdown in a set goes through the same lint and link checks as the rest of the repository.

## Using a set

Copy the set into the place your forge reads, by hand, as you strip `meta/` by hand: for Gitea, `forges/gitea/workflows/` to `.gitea/workflows/`. Check whether your forge also reads `.github/` (some fall back to it) and remove what it should not run, then record the choice in `DISCIPLINE_ADOPTION.md`.

## Changing a set

A change here alters what every adopter on that forge will run, so it needs a human decision to merge: `agent:auto` does not cover it (`docs/CONTRIBUTING.md` §"Merge authority"). A contribution that brings a set in line with a newer seed version updates the version its README records.
