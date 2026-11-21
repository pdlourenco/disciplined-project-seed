# ADR-0023 — Two plan carriers: a markdown plan for ad-hoc work, forge milestones and issues for repository work

## Status

Proposed — 2026-11-21. Maintainer direction (conversation, 2026-11-21):
the agent machinery serves two kinds of work, and each should be planned in
the carrier that suits it. Ad-hoc work must stay grounded, but it may have
no infrastructure, so what it creates must be light; markdown plans
suffice. Repository work is long-lived, with roadmaps, phases, features and
bugs, and it is where agents and humans interact most; a forge's
capabilities simplify that. Takes the direction of
[#71](https://github.com/pdlourenco/disciplined-project-seed/issues/71)
for repository work and leaves its forge-side details deferred there.
Amends [ADR-0016](ADR-0016-model-tier-selection-plan-level.md) and
[ADR-0020](ADR-0020-provider-and-forge-neutral-interfaces.md) (where the
model tier and the plan format live) and
[ADR-0021](ADR-0021-agent-roles-and-topology.md) (what the planner
produces and where the orchestrator's ledger lives). Operationalised in
[`docs/CONTRIBUTING.md`](../../docs/CONTRIBUTING.md) §"Plan carriers",
§"Neutral interfaces" and §"Agent roles", and in `CLAUDE.md` §5's
definition of planned work.

## Context

The seed plans in documents: `ROADMAP.md` lists phases, and each phase gets
a plan from `docs/plans/PHASE-TEMPLATE.md` whose §"PR sequence" holds one
row per PR, each with a model tier and a gate. ADR-0020 made that plan
format one of the neutral interfaces. ADR-0021 made the orchestrator keep
the plan file as a ledger (status, PR, iteration, last verdict per row) and
left the ledger's format and commit path open.

Two pressures pull that single shape apart:

- **Repository work outgrows plan files.** #71 reports what the visible
  adopters did: none uses milestones or the `phase-N` labels as intended;
  one ran a 286-line plan for a seven-PR sequence whose prose recorded no
  status; the one adopter that tracked phase work tracked it as issues. On
  a forge, issues already carry status, assignment, dependencies,
  discussion and a progress view, and they are where humans and agents meet.
  The closed-source adopter has moved to "the roadmap orders milestones,
  issues carry the work".
- **Ad-hoc work has no forge to lean on.** The same agent roles also run
  work that is not a repository's roadmap: a one-off task, an
  investigation, work started from a chat. It may have no repository and no
  forge. It still needs grounding (a goal, a scope, a record of decisions
  and of what is done) or the "agents recommend, humans decide" rule has
  nothing to anchor to. A milestone and an issue tracker are too heavy for
  it, and may not exist.

Choosing one carrier for both forces one kind of work into the other's
shape. The collisions #71 raises with ADR-0016, ADR-0020, ADR-0021 and
`CLAUDE.md` §5 all come from assuming a single carrier.

## Decision

1. **One plan model, defined by the discipline.** A plan is a goal with
   success criteria, a scope and non-goals, a set of **items**, and the
   open **decisions** it depends on. Each item has a title, a **model
   tier** (ADR-0020), a gate, its dependencies ("blocked by"), a
   **status** (`open`, `taken`, `in review`, `done`, `dropped`) and, once
   work starts, its PR. The **ledger** is the part the orchestrator writes:
   each item's status, PR, iteration count and last verdict. Nothing else
   in a plan is the orchestrator's to change.
2. **Two carriers hold that model.**
   - **Markdown carrier**, for ad-hoc work: one plan file, with the items as
     a table and the ledger as columns of that table. It needs no forge and
     no repository. Repository work may also use it where the forge lacks
     milestones or dependencies, or by the maintainer's choice;
     `PHASE-TEMPLATE.md` is its long form for a repository phase.
   - **Forge carrier**, for repository work on a forge that has milestones
     and issue dependencies: one milestone per phase, one issue per item,
     dependencies as the forge's "blocked by", the model tier as an issue
     field, and the ledger as the issues' own state. Its detailed shape
     (close-out duties, how short a phase plan becomes, how dependencies
     are recorded) stays deferred in #71 until the adopter there closes its
     first milestone under it.
3. **Three neutral plan operations**, beside ADR-0020's five forge
   operations: `list-items` (the items with their status, tier and
   dependencies), `add-item` (a new item, unscheduled until a human
   schedules it) and `update-item` (the ledger fields only). Each carrier's
   adapter maps them: the markdown adapter edits the plan file, a forge
   adapter calls the issue tracker. The orchestrator uses only these, so it
   runs the same way on either carrier.
4. **Scheduling is a human act on either carrier.** On the markdown carrier
   an item is scheduled when its plan is approved: the plan PR is merged,
   or, with no repository, the maintainer's approval is recorded in the plan
   file with who and when. On the forge carrier an item is scheduled when a
   human puts its issue in an open milestone. Agents may add, label and
   propose items, but never create or close a milestone, and never set,
   change or clear an issue's milestone. `CLAUDE.md` §5's "planned work"
   becomes "an item the maintainer has scheduled", on either carrier.
5. **One carrier per body of work, declared at its start.** A plan file
   says so in its header; a repository using the forge carrier says so in
   `DISCIPLINE_ADOPTION.md`. No body of work is split across carriers:
   two sources of truth for the same items drift.
6. **Promotion is one-way.** Ad-hoc work that becomes long-lived moves to
   the forge carrier: its open items become issues in a milestone, the plan
   file records where they went and stops changing. Nothing moves back.
7. **Ad-hoc work has a minimal grounding set.** A markdown plan for ad-hoc
   work needs a goal, its scope and non-goals, its items and its decisions,
   and nothing more. `ROADMAP.md`, `SPEC.md` and the phase template are for
   repository work, or for ad-hoc work once it is promoted.

## Consequences

- **ADR-0021's ledger question splits.** On the markdown carrier the ledger
  is the item table's ledger columns, defined now; on the forge carrier it
  is the issues' state. How markdown ledger updates reach a protected
  default branch is still open, as ADR-0021 left it, and is decided with the
  orchestrator loop's own PRs.
- **The model tier is a field on the item** in both carriers: a column in
  the markdown table, an issue field on the forge. The deferred tier check
  ([#57](https://github.com/pdlourenco/disciplined-project-seed/issues/57))
  needs one form per carrier when it is wired.
- **The planner produces a plan in its carrier**: a plan file for review,
  or, on the forge carrier, a milestone proposal with its items added as
  issues for a human to schedule. The orchestrator runs scheduled items,
  item by item, through the plan operations.
- **The plan operations need adapters.** The agent-bindings profile ships a
  markdown adapter first (it needs nothing but the file); a forge adapter
  for the plan operations comes with the forge carrier's details.
- **The forge carrier uses only what the plan operations name.** Forges
  differ (milestones, dependencies, custom fields). Anything a forge offers
  beyond the three operations is convenience, never something the
  discipline relies on, or the carrier stops being forge-neutral.
- **#71 stays deferred, narrowed.** The direction (milestones and issues
  for repository work) is taken here; what remains deferred is the forge
  carrier's detailed shape and the label changes #71 proposes (`feature`,
  removing the phase category), which wait for its trigger.
- **`PHASE-TEMPLATE.md` is unchanged for now.** It remains the long-form
  markdown plan for a repository phase; trimming it, as #71 proposes, comes
  with the forge carrier's details.

## Alternatives considered

- **Markdown plans for everything (status quo).** No new mechanism.
  Rejected: repository work keeps tracking status in prose nobody updates,
  and it gives up the forge's issues, dependencies and progress view at
  exactly the point where humans and agents work together most.
- **Forge milestones and issues for everything (#71 as written).** One
  model. Rejected: ad-hoc work may have no repository or forge, and would
  have to create one, or go ungrounded, to be planned at all.
- **Let each body of work pick freely, without declaring it.** Least
  ceremony. Rejected: without a declared carrier an agent cannot know which
  record is authoritative, and mixed records drift.
- **Keep both carriers in sync both ways.** Lets work move back and forth.
  Rejected: two-way sync is a second source of truth by design, and the
  case it serves (repository work going back to ad-hoc) has not come up.
- **Separate role sets per carrier.** Rejected: the planner, orchestrator,
  author and reviewer do the same jobs on either carrier; only where the
  plan lives differs, which is what the plan operations hide.
