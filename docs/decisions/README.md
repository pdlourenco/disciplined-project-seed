# Architecture Decision Records

This directory holds the project's Architecture Decision Records. Each ADR documents a non-obvious tactical or engineering decision with enough context that a future contributor (human or agent) can understand why the decision was made and when to revisit it.

## What an ADR is — and isn't

**An ADR records a decision that will stick.** If a future PR might reasonably want to revisit the decision, or if contributors following or diverging from the pattern will want a reference, it's ADR-worthy.

**An ADR is NOT:**

- A place for architecture itself. `docs/DESIGN.md` owns architectural shape. ADRs are the tactical choices underneath the architecture.
- A place for contracts. `docs/SPEC.md` owns binding cross-boundary contracts. ADRs can motivate a SPEC change, but the authoritative text lives in SPEC. When an ADR motivates a SPEC change, both land in the same PR (spec first, per [`../CONTRIBUTING.md`](../CONTRIBUTING.md) §"When you change a contract").
- A place for obvious or purely mechanical choices. Import ordering, formatter settings, internal naming conventions. These churn too much to earn a permanent record.
- A narrative of what you did. It's a record of what you decided and why the rejected alternatives were rejected.

When to write one vs. not is also covered in [`docs/CONTRIBUTING.md`](../CONTRIBUTING.md) §"Design decisions (ADRs)".

## ADR lifecycle

ADRs can be written in either of two shapes:

- **ADR-first**: the ADR is opened as a PR; the discussion happens on the PR; the ADR captures the decision when the PR merges.
- **Issue-first**: a GitHub issue is opened for the decision (with Context + Alternatives + Where it lands); discussion / resolution happens in the issue; once the issue closes, a follow-up PR writes the ADR from the closed-issue thread.

Issue-first is useful when the decision is part of a batch (e.g. a design meeting's agenda) where opening N empty ADR-PRs would be heavier than opening N issues. Either shape produces the same ADR in `docs/decisions/`; the difference is where the discussion lives.

## Format

Use [`ADR-TEMPLATE.md`](ADR-TEMPLATE.md) as the starting point. Required sections:

1. **Status** — with date. Proposed / Accepted / Rejected / Superseded.
2. **Context** — what forced the decision. Prefer concrete evidence (bugs that happened, data that was collected) over abstract argument.
3. **Decision** — what was chosen. Terse; 1-3 sentences.
4. **Consequences** — what this means going forward. Mix of positive and negative.
5. **Alternatives considered** — **not optional**. Each alternative named, described, and rejected with enough specificity that a reader can evaluate the reasoning.

The "Alternatives considered" section is what makes an ADR useful six months later. An ADR without it is a decision-log entry, not an ADR.

## Numbering and filenames

- Filenames: `ADR-NNNN-kebab-case-title.md`, where `NNNN` is a zero-padded sequence number.
- Numbers are assigned sequentially as ADRs are merged, never reused, never reordered.
- Titles in filenames should be short and specific — "pre-push-self-review" rather than "review-process".
- If an ADR supersedes another, the new one references the old one in its Status section, and the old one's Status flips to "Superseded by ADR-NNNN".

## Linking to ADRs

- From PR descriptions: `Implements X per ADR-NNNN.`
- From code comments beside tactical values: `# See ADR-NNNN` or `// See ADR-NNNN`. Especially useful for magic numbers, thresholds, and fallback choices whose rationale lives in an ADR.
- From other docs: markdown links to the ADR file, e.g. `[ADR-0003](decisions/ADR-0003-some-decision.md)`.

## Index

<!-- Keep this list append-only, in numeric order. Each entry:
     ADR number — short title — status (one word) — one-line summary. -->

<!-- Example entries:

     - [ADR-0001](ADR-0001-use-toml-for-config.md) — Use TOML for config — Accepted — Config files are user-edited; TOML chosen for readability over JSON/YAML.
     - [ADR-0002](ADR-0002-state-db-is-internal.md) — State DB is internal to the indexer — Accepted — State DB schema is not a cross-module contract; indexer owns it fully.
     - [ADR-0003](ADR-0003-permissive-licenses-only.md) — Permissive licenses only — Accepted — MIT/Apache-2.0/BSD required; GPL/AGPL excluded. -->

<!-- Your first entries here: -->
