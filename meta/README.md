# `meta/` — the seed's own evolution history

This directory holds artifacts about *how the [disciplined-project-seed](https://github.com/pdlourenco/disciplined-project-seed) was built*, kept separate from the template content adopters fill in and the scaffolding adopters use as-is.

## What's in here

- **`decisions/`** — Architecture Decision Records capturing the seed's own design choices. Why labels sync via a GitHub Action; why CI ships as an active trivial workflow rather than an `.example` skeleton; why branch protection is human-triggered apply rather than auto-sync; etc.
- **`analyses/`** — dated, immutable analysis snapshots about the seed itself (adopter studies, backport analyses). Each declares the state it captured and is not maintained afterwards; live status stays in the issues/PRs it links.
- **`CHANGELOG.md`** — Keep-a-Changelog format documenting the seed's evolution.

## For adopters

When you use this seed via *Use this template*, you inherit this `meta/` directory. Two reasonable adoption paths:

1. **Strip it.** Run `rm -rf meta/` once. You get a clean repo where `docs/decisions/` is for *your* project's ADRs (starting at ADR-0001 in your own numbering) and the root `CHANGELOG.md` is *your* project's release history. The inherited scaffolding (`.github/labels.yml`, `.github/workflows/ci.yml`, `.github/branch-protection.yml`, `scripts/setup-branch-protection.sh`, etc.) still works on its own — you've just dropped the "why we chose it" reference.

2. **Keep it as reference.** Leave `meta/` in place. When you wonder why the inherited CI workflow is shaped the way it is, why labels sync via the specific GitHub Action it uses, or why branch protection is human-triggered rather than auto-synced, the per-decision write-ups with rationale and alternatives are right here. Useful when you're considering deviating from the seed's defaults — read the ADR first to see what the trade-off was.

Pulling upstream refinements (the seed itself evolves; see the *How the seed evolves* section in the root `README.md`) is easier with `meta/` kept — `meta/CHANGELOG.md` tells you what changed between your snapshot and the latest seed.

## Seed-only parts of the shared files

The seed runs the same `.github/` files adopters receive ([ADR-0024](decisions/ADR-0024-adoptable-forge-files.md)). The few parts that are the seed's own are keyed to the seed's repository name inside the file, so a template copy or fork, which has another name, gets the adopter's behaviour with nothing to set:

- `release.yml`'s `CHANGELOG_PATH`: `meta/CHANGELOG.md` in the seed, the root `CHANGELOG.md` elsewhere;
- `release.yml`'s "Adopting?" footer on release notes, a step that runs only in the seed.

`ARCHIVE_EXCLUDES: meta` is shared: it is harmless where there is no `meta/`. A seed-only step that cannot be a keyed value would live in a workflow named `seed-*.yml`; there is none today. If the seed repository is renamed, the two keyed expressions in `release.yml` change with it.

## ADR numbering

Seed-meta ADRs (`meta/decisions/`) and adopter ADRs (`docs/decisions/`) share **no numbering**. Both start from ADR-0001 in their own directories. Cross-references stay within each directory.

## See also

- [`docs/decisions/README.md`](../docs/decisions/README.md) — the ADR conventions adopters follow for *their* ADRs (same conventions the seed used for the meta ADRs).
- The root [`README.md`](../README.md) *How the seed evolves* section.
