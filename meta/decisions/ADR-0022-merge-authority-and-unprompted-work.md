# ADR-0022 — Merge authority: agents merge only under a human's label, never silently; unprompted work waits on its own branch

## Status

**Amended by [ADR-0023](ADR-0023-two-plan-carriers.md)** (Accepted — 2026-11-21):
plan files under `docs/plans/` and the plan-carrier declaration join the
agent-authority paths, since merging a plan schedules its items.

Accepted — 2026-11-19: the maintainer chose option B, with one added
condition, that every merge an agent makes is announced to them
(maintainer decision, relayed by the hub session on 2026-11-19). On
PR #66 on 2026-11-20 the maintainer concurred with option B as described
there, notices included, and chose that the label never covers a change
to an agent's own authority; on 2026-11-20 the maintainer also put the CI
workflows on that list, and on PR #69 on 2026-11-21 the branch-protection
scripts. The `auto/` branch principle in §Decision 2 is the maintainer's
own decision of 2026-11-19. Stacked on ADR-0021. Refines
[ADR-0009](ADR-0009-agent-pr-lifecycle-and-two-session-workflow.md): the
label is an explicit, per-PR approval given in advance. Operationalised in
[`docs/CONTRIBUTING.md`](../../docs/CONTRIBUTING.md) §"Merge authority"
(where the notice rule is recorded), the merge invariant of §"Agent
roles", and the `agent:auto` label in
[`docs/LABELS.md`](../../docs/LABELS.md) and `.github/labels.yml`.
**In force for agents since 2026-11-20**, when `CLAUDE.md` §5 was aligned
with it on the maintainer's direct instruction. With that change the
maintainer also settled two points (2026-11-21): a PR opened from an
`auto/` branch at a person's request is requested work, which the label
may cover; and a PR carrying a surfaced §4 major decision waits for the
maintainer's go-ahead, label or not. (Until then §5 said "never
merge on your own initiative", and agents treated every `agent:auto` PR as
unlabelled: accepting this ADR was not, on its own, an instruction to
change the file that binds every agent.)

## Context

ADR-0021 gives every agent a bot account and no `merge` capability by
default, and leaves who may merge to this ADR. Until now the only rule was
ADR-0009's: the authoring session merges on the maintainer's explicit
"merge and proceed". Two things make that insufficient:

- **Agents that act unprompted.** The maintainer's agent work includes
  agents that start on their own: an alert, a new note in an inbox, a
  reminder coming due. ADR-0009 assumes every change starts with a person
  asking. A change nobody asked for has no requester to review it before
  it lands, and no request to bound what it touches.
- **The two merge options on the table.** (A) Humans merge every PR; the
  loop stops at "ready to merge". (B) The agent may merge a PR itself when
  the final review approves, CI is green, the PR changes no contract and
  adds no dependency, and it carries an autonomy label. B saves the
  maintainer a click per PR; it also moves the last human check off the
  merge itself, which is why the maintainer added a notice for every
  agent merge.

The maintainer's working practice already had a middle ground for the
first point: a direct request follows the repository's normal commit
policy, while work the agent chose to do goes to a branch and waits there.
The branch is the gate.

## Decision

1. **Merge authority: option B, under a human's label, never silently.**
   - **Without the label, a human decides (option A).** A PR merges only
     on a human's explicit decision for that PR: the human merges it, or
     tells the agent to ("merge and proceed", ADR-0009). This is the
     default for every unlabelled PR.
   - **With the label, the agent may merge** (the orchestrator in the loop,
     or by hand the authoring session) a PR carrying `agent:auto`,
     applied by a human (the forge's event history shows who applied it; a
     label added by a bot account does not count), when all of these hold
     at the moment of merging:
     - the final review approves (ADR-0021: the final `frontier` review
       where an orchestrator runs the loop; in a hand-run flow, the
       reviewing session's approving verdict on the current head);
     - CI is green on the current head;
     - the PR changes no contract (`docs/SPEC.md` and the
       machine-shared artifacts it names);
     - the PR adds no dependency (no new entry in a manifest or lockfile);
     - the PR changes nothing that sets an agent's own authority:
       `CLAUDE.md`, CONTRIBUTING §"Merge authority", the branch-protection
       config, the CI workflows under `.github/workflows/` (they decide
       what "CI is green" means), the branch-protection scripts
       (`scripts/setup-branch-protection.sh`,
       `scripts/normalize-branch-protection.jq`,
       `.github/scripts/check-bp-contexts.py`, which write and check the
       protection settings), the label catalogue (`docs/LABELS.md`,
       `.github/labels.yml`), anything under `.claude/`, and (added by
       ADR-0023) plan files under `docs/plans/` and the plan-carrier
       row of `DISCIPLINE_ADOPTION.md` (only that row), since merging a plan
       schedules its items. Otherwise one
       labelled PR could widen what the next labelled PR may do;
     - no `CLAUDE.md` §4 major decision surfaced during the work is still
       waiting for the maintainer's go-ahead: the label approves routine
       work in advance, not a decision the maintainer has not yet seen.

     If any condition fails, or the label is removed, the PR falls back to
     a human decision.
   - **Every agent merge is announced** to the maintainer, naming the PR,
     a one-line summary and the merge commit. Before merging, the agent
     checks it can reach a notice channel: the runtime's chat channel
     where one exists, otherwise the forge. After merging, it sends the
     notice there; if the runtime channel fails, it falls back to a comment
     on the merged PR that mentions the maintainer (which the forge
     delivers as a notification) and retries until one is delivered. A
     repository without a runtime uses the forge route. A merge is never
     silent: with no reachable channel, the agent does not merge.
   - **Bot merge rights are per repository**, recorded with its branch
     protection (for GitHub, `restrictions` in
     `.github/branch-protection.yml`). A repository that does not use
     `agent:auto` can keep merge rights off the bot account entirely.
2. **Unprompted work waits on its own branch.**
   - Work an agent does **because a person asked** follows the repository's
     own commit policy, whatever that is (in this seed: a PR, merged under
     §1).
   - Work an agent **chose to do** (on an alert, a note, a reminder, or any
     trigger other than a person's request) goes to its own branch, named
     `auto/<YYYY-MM-DD>-<slug>`, and stops there for a human.
   - Option B never applies to it: the agent never merges an `auto/`
     branch itself, label or not. A person asking for that work to land is
     a direct request; in this seed that means opening a PR from the
     `auto/` branch, with its CI and review. That PR is requested work and
     merges under §1: by a human, or by the agent under a human's label.
     Pushes to an `auto/` branch get the pre-push self-review like any PR
     branch, since it becomes one.
   - The agent deletes an `auto/` branch once it is merged or rejected, and
     checks its open `auto/` branches before acting on a trigger, so the
     same trigger is not handled twice.

## Consequences

- Every merge still rests on a human decision about that PR: a merge, an
  instruction, or a label. "Agents recommend, humans decide" holds; the
  label moves the decision earlier, it does not remove it. Unprompted work
  never merges without a human looking at it.
- The maintainer gives up one click per labelled PR and gains a notice
  stream to read instead. A notice that shows a merge that should not have
  happened is the signal to stop labelling, which returns that work to A
  at once.
- **Enforcement is split.** Branch protection enforces CI and the required
  review on the forge. The contract, dependency and authority conditions,
  and who applied the label, are checked by the merging agent. **Deferred:
  a CI check** that fails an `agent:auto` PR touching `docs/SPEC.md`, a
  manifest or lockfile, or one of the authority paths. **Trigger:** the
  first agent merge under B. Like every new check, it lands with a test
  that shows it can fail.
- The label taxonomy gains `agent:auto` (a new "authority" category in
  `docs/LABELS.md` and `.github/labels.yml`, which change together).
- A later escalation-triggers ADR owns *when* an agent stops and asks
  (iteration cap, contract changes, failing CI after a fix); this ADR owns
  only who merges, how merges are announced, and where unprompted work
  lands.

## Alternatives considered

- **Option A as the rule for every PR.** It was recommended in this ADR's
  draft. The maintainer chose B instead: under A every PR costs a click
  even when the review, CI and scope all say it is routine, and the label
  keeps the decision with a human per PR. A remains the default for every
  unlabelled PR and the fallback whenever a condition fails.
- **Option B without notices.** Rejected by the maintainer: an agent merge
  nobody hears about is the one most likely to go unnoticed when wrong.
- **Option B for unprompted work.** Rejected: the trigger is the agent's
  own judgement, so nobody has agreed to the change before it lands; a
  label would be a human approving something no human asked for.
- **A label the agent may apply itself.** Rejected: it would turn the
  advance approval into the agent approving its own work.
- **The label on any PR, authority changes included.** Rejected by the
  maintainer: a labelled change to the merge rules, the CI workflows, the
  branch-protection scripts, the label catalogue or the agent's own
  configuration could widen what the next labelled PR may do, with no
  human decision on the widening itself. A labelled PR that weakened a
  workflow or a protection script could merge on its own green CI.
- **Unprompted work as a PR rather than a bare branch.** A PR is a fine way
  to present an `auto/` branch, and nothing here forbids opening one. The
  rule is about the branch: it is what the agent may not merge and must
  clean up, on any forge, with or without PR tooling.
- **No naming rule for unprompted work.** Rejected: without a fixed prefix
  the agent cannot cheaply check its own open work before acting, and a
  person cannot find unprompted work at a glance.
