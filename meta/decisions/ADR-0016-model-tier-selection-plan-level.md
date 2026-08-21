# ADR-0016 — Model-tier selection as a plan-level field with a task-shape rubric

## Status

Accepted — 2026-08-21. Implements
[#54](https://github.com/pdlourenco/disciplined-project-seed/issues/54);
maintainer-approved direction (conversation, 2026-08-21). Operationalised in
[`docs/CONTRIBUTING.md`](../../docs/CONTRIBUTING.md) §"Model tier selection",
[`docs/plans/PHASE-TEMPLATE.md`](../../docs/plans/PHASE-TEMPLATE.md) §3, the
PR template's `Model tier:` checklist row, and `CLAUDE.md` §2's reviewer-tier
clause. The companion CI gate is deferred with a named trigger (see
§Consequences).

## Context

Model tier is a standing cost/capability trade-off, and until now it was the
one such choice with nowhere durable to land: it bound at session launch
(`--model …`) as an ad-hoc per-terminal pick — invisible to the phase plan,
unrecorded in the PR trail (unlike review outcomes, which the `pre-push
review:` marker makes auditable), and unreviewable despite being exactly the
kind of sticky choice `CLAUDE.md` §4 says should be surfaced and recommended
rather than decided silently.

A hard mechanical constraint decides where the field *can* live: **a session
cannot change its own model.** `/model` is a user command and `--model` binds
at launch, so an agent cannot re-tier itself mid-flight. Any convention that
wants tier to be *agent-recommended and maintainer-approved* must land the
recommendation in a durable artifact the launch reads — which means the phase
plan, or nothing. The plan's §"PR sequence" is the only place work is
enumerated ahead of time and already carries per-PR gates, so it is the
natural row to extend.

The two-session topology (ADR-0009) already implies per-role tiers — the
reviewing session runs hotter than the authoring one in practice — but that
asymmetry was written down nowhere.

## Decision

1. **Tier is a field on each PR row of the phase plan's §"PR sequence".** The
   authoring session proposes a tier per row when drafting the plan; plan
   approval makes it part of an approved artifact; whoever launches the
   session for that row reads it there. The §4 recommend-don't-decide posture
   is unchanged — the recommendation lands in a document instead of a chat
   turn.
2. **Tiers are named by task shape, never by model.** The vocabulary is
   `routine` / `complex` / `planning-and-review`. The mapping from tier to a
   concrete model alias lives in **exactly one place** —
   `CONTRIBUTING.md` §"Model tier selection"'s table — because aliases move
   (`opus` and `sonnet` resolve differently across providers and versions);
   tier names scattered through plans stay stable while the mapping absorbs
   the churn. This is the same single-source-of-truth argument `LABELS.md` /
   `labels.yml` settle for labels.
3. **Effort is the first dial.** Effort levels are a finer and cheaper control
   than a tier jump; a task that is fiddly rather than architecturally hard is
   a higher-effort task at the current tier, not a tier escalation. The rubric
   states this so it doesn't over-escalate.
4. **Per-role defaults for the two-session workflow.** The authoring session
   launches at the tier named by the plan row it implements (`routine` when
   the work is unplanned); the reviewing session launches at
   `planning-and-review`. The asymmetry ADR-0009 implied is now stated.
5. **The §2 pre-push reviewer runs at the review tier**, pinned at launch via
   the subagent's model/effort parameters (or `model` / `effort` frontmatter,
   for projects that keep named subagent definitions) rather than inheriting
   whatever tier the authoring session happens to be running. The seed
   deliberately does **not** ship a `.claude/agents/` reviewer definition for
   this: the reviewer prompt lives in `CONTRIBUTING.md` §"Pre-push
   self-review", and duplicating it into an agent file would create a
   restated-prose drift surface (§"CI strategy" §1, drift-hardening doctrine)
   for one frontmatter line of value.
6. **Tier is recorded per PR.** The PR template carries a `Model tier:`
   checklist row beside the pre-push review marker, so tier becomes auditable
   alongside review outcome — after a phase, the PR trail can answer whether
   the rubric mispredicted (e.g. whether `routine`-tiered PRs generated the
   review findings).

Built-in mode splits — the `opusplan` alias (plan mode vs execution) and
per-subagent model/effort settings — are the *mechanism* a tier assignment is
implemented with, not an alternative to the convention: they split on mode,
not on task difficulty, so they cannot express "PR 3 in this sequence is the
hard one."

## Consequences

- Phase plans gain one line per PR row; drafting cost is negligible since the
  author is already judging difficulty to write the row's gate.
- The mapping table is a new maintenance point, deliberately singular.
  Changing which alias a tier resolves to is a one-line PR; changing the
  *vocabulary* is a §4 major decision.
- **Deferred: CI gate.** A tier-3 check that every PR-sequence row in an
  active phase plan carries a tier (shaped like the dangling-placeholder
  audit) is deferred rather than wired now, per the seed's own standard that a
  gate must earn its keep: no phase plan has yet been authored under the
  field. Trigger to wire in: **the first phase plan authored under the tier
  field** (at which point plan-approval review stops being the only
  enforcement). Tracked as a `deferred + decided` issue.
- **Deferred with conditions: runtime escalation via an advisor model.**
  Configuring an advisor so a session consults a stronger model mid-task on
  its own judgement is the closest thing to "the author decides" and composes
  with this convention rather than competing — but it is a new runtime
  dependency the seed has no experience with, and adopting it blind would be
  exactly the un-evidenced trade-off #54 complains about. Trigger to revisit:
  **at least one phase has run under this convention and the PR-description
  tier data shows where the rubric mispredicts.**

## Rejected alternatives

- **Do nothing (per-session launch flag).** The status quo whose costs are in
  §Context; worsens as phases get longer and more heterogeneous.
- **Repo-level default only** (`model` in `.claude/settings.json`). One line,
  but strictly less expressive than per-session choice — cannot even
  distinguish the authoring session from the reviewing one.
- **Built-in splits only** (`opusplan` + subagent frontmatter, no plan field).
  Splits on mode, not task difficulty; folded in as mechanism instead (see
  §Decision).
- **Model names in plan rows.** Rot with alias churn; rejected for the
  tier-vocabulary indirection (§Decision 2).
