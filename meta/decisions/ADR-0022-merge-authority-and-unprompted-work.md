# ADR-0022 — Merge authority: humans merge; unprompted agent work waits on its own branch

## Status

Proposed — 2026-11-19. Maintainer request (conversation, 2026-11-19): the
merge-authority item of the agent-governance set, stacked on ADR-0021. The
`auto/` branch principle in §Decision 2 is the maintainer's own decision of
that date; the choice between merge options A and B (§Decision 1) is still
the maintainer's. Operationalised in
[`docs/CONTRIBUTING.md`](../../docs/CONTRIBUTING.md) §"Merge authority" and
the merge invariant of §"Agent roles".

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
  maintainer a click per PR; it also moves the last human check off the PR.

The maintainer's working practice already has a middle ground for the
first point: a direct request follows the repository's normal commit
policy, while work the agent chose to do goes to a branch and waits there.
The branch is the gate.

## Decision

1. **Recommended: option A** (the maintainer chooses A or B before this
   ADR is Accepted). A PR merges only on a human's explicit decision for
   that PR: the human merges it, or tells the agent to ("merge and
   proceed", ADR-0009). This is the rule ADR-0009 and `CLAUDE.md` §5
   already state, so choosing A changes nothing in the hand-run flow.
   Whether the bot account holds merge rights at all is decided per
   repository and recorded with its branch protection (for GitHub, the
   `restrictions` setting in `.github/branch-protection.yml`): without
   them, the maintainer presses merge; with them, protection must still
   stop an uninstructed merge. Option B stays available for a later ADR,
   scoped to labelled PRs, once the reviewer's verdicts have a record; it
   would never apply to unprompted work (§2).
2. **Unprompted work waits on its own branch.**
   - Work an agent does **because a person asked** follows the repository's
     own commit policy, whatever that is (in this seed: a PR, merged under
     §1).
   - Work an agent **chose to do** (on an alert, a note, a reminder, or any
     trigger other than a person's request) goes to its own branch, named
     `auto/<YYYY-MM-DD>-<slug>`, and stops there for a human to merge.
   - The agent never merges its own `auto/` branch. A person telling it to
     merge one is a direct request, and follows the repository's policy;
     in this seed that means opening a PR from the `auto/` branch, with its
     CI and review, and merging under §1. Pushes to an `auto/` branch get
     the pre-push self-review like any PR branch, since it becomes one.
   - The agent deletes an `auto/` branch once it is merged or rejected, and
     checks its open `auto/` branches before acting on a trigger, so the
     same trigger is not handled twice.

## Consequences

- "Agents recommend, humans decide" holds for every merge, including work
  no human started. An unprompted change is visible, as a branch, before
  anyone has to trust it.
- One click per PR stays with the maintainer. B is the relief valve, behind
  its own ADR and evidence.
- The `auto/` prefix is a contract the forge can see: a branch-protection
  rule or a periodic sweep can find stale unprompted work by name, and the
  check-before-acting rule needs only a branch listing.
- **Who presses merge is per repository.** Without bot merge rights,
  "merge and proceed" means the maintainer merges and the authoring
  session only proceeds; with them, an instructed merge is the agent's.
  Either way the decision is the human's, which is what §1 requires.
- A later escalation-triggers ADR owns *when* an agent stops and asks
  (iteration cap, contract changes, failing CI after a fix); this ADR owns
  only who merges and where unprompted work lands.

## Alternatives considered

- **Option B now.** Rejected for now: no reviewer verdicts have been
  recorded yet to show B's conditions would have caught what a human
  catches. Revisit after two phases under A on a real repository (the
  maintainer's stated preference, conversation of 2026-11-19).
- **Unprompted work treated like requested work.** It would follow the
  repository's policy, which in some repositories means committing straight
  to `main`. Rejected: the trigger is the agent's own judgement, so nobody
  has agreed to the change before it lands.
- **Unprompted work as a PR rather than a bare branch.** A PR is a fine way
  to present an `auto/` branch, and nothing here forbids opening one. The
  rule is about the branch: it is what the agent may not merge and must
  clean up, on any forge, with or without PR tooling.
- **No naming rule.** Rejected: without a fixed prefix the agent cannot
  cheaply check its own open work before acting, and a person cannot find
  unprompted work at a glance.
