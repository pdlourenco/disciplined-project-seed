# ADR-0020 — Provider- and forge-neutral interfaces, with four abstract model tiers

## Status

Proposed — 2026-11-19. Maintainer request (conversation, 2026-11-19): the
second of three governance ADRs that land before the agent-bindings
profile; stacked on ADR-0019. Revises the tier **vocabulary** of
[ADR-0016](ADR-0016-model-tier-selection-plan-level.md) §Decision 2 and
leaves its mechanics in place. Operationalised in
[`docs/CONTRIBUTING.md`](../../docs/CONTRIBUTING.md) §"Neutral interfaces",
§"Model tier selection" and §"Forge operations", the
[`PHASE-TEMPLATE.md`](../../docs/plans/PHASE-TEMPLATE.md) §3 tier comments,
and the `pre-push-review` skill's tier lookup.

## Context

ADR-0019 puts the discipline in a layer that is neutral about agent tool and
forge. The discipline's agent-facing interfaces only partly meet that today:

- **Model tiers are neutral in name, not in shape.** ADR-0016 names three
  tiers by task shape (`routine` / `complex` / `planning-and-review`). Its
  only mapping is to Claude Code aliases, and two of the three tiers map to
  the same alias (`sonnet`), told apart by *effort*, a dial one provider
  offers. A provider without that dial cannot express the difference.
- **Three tiers cannot express the review ladder the maintainer wants for
  agent work** (conversation, 2026-11-19): each iteration reviewed at one
  tier and a final pass before merge at a higher one. With
  `planning-and-review` as the top tier, there is no rung above iteration
  review. Authors
  also span a wider range than two tiers: from fully specified mechanical
  edits to tasks with real design freedom.
- **Forge operations are GitHub-shaped.** §"Reviewing an open PR" fetches
  diffs "via the GitHub MCP tools"; `docs/decisions/README.md` scans open PRs
  with `gh pr list`; the label, branch-protection and release automation is
  GitHub Actions. The maintainer's first target forge for agent work is a
  self-hosted Gitea, with GitLab and GitHub through adapters.
- **Two further interfaces do not exist yet:** the verdict schema and the
  escalation triggers. Each gets its own ADR later. They need a stated home
  and a neutrality rule before they are written, not after.

The forcing function is the agent-bindings profile: role files carry a tier,
and forge mappings need a set of operation names to map from. Both need the
discipline's vocabulary fixed first.

## Decision

1. **The agent-facing interfaces are plain files in the discipline layer
   and name no provider or forge.** They are: the plan format, the
   model-tier vocabulary and rubric, the forge operations, and (when their
   ADRs land) the verdict schema and the escalation triggers. A person can
   follow each by hand. `docs/CONTRIBUTING.md` §"Neutral interfaces" lists
   them and where each one lives.
2. **Four model tiers, named by capability rung: `fast`, `standard`,
   `strong`, `frontier`.** They replace ADR-0016's three names. Everything
   else in ADR-0016 stays: the tier is a field on each plan row, the author
   recommends it, plan approval ratifies it, the PR records it, and tiers
   are never model names. The rubric still assigns a tier by task shape:
   the rung names say how much capability a task needs, and the rubric says
   which tasks need which.
3. **Each agent-tool adapter owns its tier mapping.** An adapter maps each
   rung to one of its provider's models in a single table. Until the
   agent-bindings profile ships the Claude Code adapter,
   `docs/CONTRIBUTING.md` §"Model tier selection" keeps that adapter's table
   as the one place the mapping lives; the profile moves it out.
4. **Finer dials belong to adapters.** A dial such as effort is an adapter
   feature, never part of the discipline. The discipline keeps ADR-0016
   §Decision 3 in neutral form: if an adapter offers a finer dial, use it
   before moving a task up a rung.
5. **Five neutral forge operations:** `open-pr`, `get-diff`, `post-review`,
   `ci-status`, `merge`. The discipline names them and what each must do;
   each forge adapter (bindings layer) maps them to commands in one mapping
   file. "PR" is the discipline's word for a GitLab merge request too. The
   existing GitHub scaffolding under `.github/` is forge-specific carriage
   in ADR-0019's sense. This ADR does not move it; versions for other forges
   come with the later CONTRIBUTING update for agent work.

## Consequences

- An adapter for a new provider or forge is one mapping file, with no
  discipline change. Role files and plans stay valid across providers.
- **Vocabulary migration.** Phase plans written under ADR-0016 carry old
  names. The default reading is `routine` → `standard`, `complex` →
  `strong`, and `planning-and-review` → `frontier` for planning and ADR
  work. Iteration review moves to `strong` (per-role defaults are ADR-0021's
  subject; CONTRIBUTING's defaults are updated here only so the docs do not
  name a retired tier). No phase plan in this repository carries a tier yet,
  so nothing here needs rewriting; adopters with plans read them through
  this table.
- **Escalation generalises.** ADR-0016's escalation rule covered only a
  `complex` row, recorded as `complex (escalated)`. With four rungs any row
  can move up one, recorded as `<planned> (escalated to <ran>)`. The audit
  signal is the same: the escalation count is the rubric mispredicting.
- **`opusplan` leaves the mapping table.** It paired `opus` planning with
  `sonnet` execution under `planning-and-review`. It splits by mode, not by
  rung, so it maps to no single rung; ADR-0016 already treats mode splits
  as mechanism. It plans on `opus`, so a Claude Code session may still use
  it on a `strong` row.
- **The final review pass is not defined here.** The rubric places
  planning, ADR work and architecture at `frontier`. Which rung reviews
  each iteration and whether a final pass runs above it are role defaults,
  decided in ADR-0021.
- **Cost moves.** Under the proposed Claude mapping, `complex` work moves
  from `sonnet` at high effort to `strong` (`opus`), and planning moves from
  `opus` to `frontier`. That raises plan-usage cost for those rows. The
  rubric's "dial before rung" rule and the per-PR `Model tier:` record are
  the controls. Revisit the mapping when one phase's PR trail shows where
  rows over-escalated.
- The forge-operation names make §"Reviewing an open PR" and the ADR
  number scan visibly GitHub-specific. Rewriting them in neutral terms is
  left to a later CONTRIBUTING update for agent work, so this PR stays a
  vocabulary change.
- The deferred tier CI check (#57) keeps its trigger. When it is wired, it
  checks the new vocabulary, and it lands with a test that shows it failing
  on a row without a tier.

## Alternatives considered

- **Keep ADR-0016's three task-shape names and add a per-adapter mapping.**
  Smallest change. Rejected: it cannot place a final review above iteration
  review, and `routine` and `complex` stay distinguishable only through a
  Claude-specific dial.
- **Two-level vocabulary: task-shape names in plans, mapped to capability
  rungs, mapped to models.** Keeps ADR-0016's names visible. Rejected: two
  indirections for one decision, and every reader has to learn both sets.
  The rubric already carries the task-shape meaning.
- **Name tiers after one provider's family (haiku / sonnet / opus).** No
  mapping needed for Claude. Rejected for the reason ADR-0016 rejected model
  names: aliases move, and other providers would map from a competitor's
  names.
- **Forge operations as a full API (issues, labels, comments, branches).**
  More complete. Rejected for now: the five operations are the ones the
  author–review–merge loop calls. Others join the list when a role needs
  them, and each joins as a discipline change first (ADR-0019 §Decision 2).
- **Do nothing until a second provider exists.** Rejected: role files
  written against Claude-only tiers would need rewriting later, which is
  exactly the churn ADR-0016's indirection exists to avoid.
