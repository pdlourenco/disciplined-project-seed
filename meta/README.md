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

## ADR numbering

Seed-meta ADRs (`meta/decisions/`) and adopter ADRs (`docs/decisions/`) share **no numbering**. Both start from ADR-0001 in their own directories. Cross-references stay within each directory.

## See also

- [`docs/decisions/README.md`](../docs/decisions/README.md) — the ADR conventions adopters follow for *their* ADRs (same conventions the seed used for the meta ADRs).
- The root [`README.md`](../README.md) *How the seed evolves* section.
