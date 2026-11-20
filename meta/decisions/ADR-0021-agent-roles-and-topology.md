# ADR-0021 — Agent roles and topology: four roles, a read-only reviewer, a bot identity

## Status

Accepted — 2026-11-19, with the draft's recommendation on each open
question: the pre-push reviewer is a named exception to the start rule
(it must not edit, held by instruction until the bindings generate a
read-only definition, and reports only to its author); the final
`frontier` review is loop-only; what the orchestrator may write is decided
with the plan-format change for the loop; the capability vocabulary stays
neutral. Who may merge is settled in ADR-0022 (PR #66): agent merges only
under a human's `agent:auto` label, each one announced, in force since
`CLAUDE.md` §5 was aligned with it on 2026-11-20 (maintainer decisions,
relayed 2026-11-19). Maintainer request
(conversation, 2026-11-19): the third of three governance ADRs that land before the agent-bindings
profile; stacked on ADR-0020. Extends
[ADR-0009](ADR-0009-agent-pr-lifecycle-and-two-session-workflow.md) (whose
two sessions become one way to fill these roles) and sets the per-role tier
defaults ADR-0020 left open. Operationalised in
[`docs/CONTRIBUTING.md`](../../docs/CONTRIBUTING.md) §"Agent roles" and
§"Per-role default model tiers".

## Context

ADR-0009 defines two sessions and three verbs: an authoring session authors
and merges on the maintainer's word; a reviewing session only reviews. The
authoring session drafts the phase plan for the maintainer's approval
(`CONTRIBUTING.md` §"Model tier selection"); the maintainer launches each
session and relays between them.
That covers a human-driven loop. It does not name roles a tool can be
configured with, and it is silent on three points an unattended loop forces:

- **Who starts whom.** The maintainer's agent work adds a planner that drafts
  the phase plan and an orchestrator that walks its PR sequence, starting an
  author and a reviewer per row. Without a rule, any agent can start any
  other, and the loop's cost and blast radius are unbounded.
- **What a reviewer may touch.** ADR-0009 makes the reviewing session
  comment-only by convention. A reviewer that holds edit tools can still
  "fix while reviewing" and then approve its own fix. The convention is
  only as strong as the session's prompt.
- **Which account acts.** The seed says nothing about the forge identity an
  agent uses. In practice it is whatever credentials the session holds,
  which can be the maintainer's own. The forge then cannot tell agent
  actions from human ones, and branch protection cannot enforce who merges.

The agent-bindings profile will define roles once, in neutral role files,
and generate each tool's agent files from them (ADR-0019, ADR-0020). Those
files need a fixed role set and fixed invariants to conform to.

## Decision

1. **Four roles.** The table in `docs/CONTRIBUTING.md` §"Agent roles" is
   normative: each role's purpose, what it reads, what it produces, the
   capabilities it holds, and its default tier.
   - **planner** drafts a phase plan from the roadmap, design, contracts and
     ADRs. It writes plan files only.
   - **orchestrator** runs an approved plan: it starts an author and a
     reviewer per row, reads verdicts and CI status, keeps the plan file's
     ledger, and stops and asks a human when an escalation trigger fires.
     It writes no code and reviews nothing.
   - **author** implements one plan row: branch, commits, the pre-push
     self-review, `open-pr`.
   - **reviewer** reviews one PR and posts a verdict with `post-review`.
2. **The reviewer holds no write capability.** No file edits, no push, no
   `merge`; its forge operations are `get-diff`, `ci-status` and
   `post-review`. This is enforced through the tool configuration that the
   bindings generate, not only through the prompt.
3. **Reviewer independence.** A reviewer sees the diff, the plan row, and
   the review context and contracts. It never sees the author's transcript
   or reasoning.
4. **Only the planner and the orchestrator start agents.** Authors and
   reviewers do not nest, with one exception: an author starts its own
   pre-push reviewer (`CLAUDE.md` §2), which must not edit and reports only
   to that author. Until the agent-bindings profile generates a reviewer
   definition with a read-only tool list, "must not edit" is held by
   instruction where the tool offers no read-only agent type that can read
   whole files: an accepted residual, named so it is not mistaken for the
   boundary §Decision 2 requires.
5. **Agents act through a dedicated forge bot account, never a human's.**
   Humans keep their own accounts and merge rights. Whether the bot account
   may also merge is the merge-authority ADR's decision (ADR-0022: only a
   PR a human has labelled `agent:auto`, and never silently); before that
   decision came into force (2026-11-20, with `CLAUDE.md` §5 aligned),
   ADR-0009's rule alone applied (merging only on the maintainer's explicit
   word), and it still applies to every unlabelled PR.
6. **Sessions fill roles.** ADR-0009's authoring session is the author role
   (plus the merge verb, on the maintainer's word); its reviewing session is
   the reviewer role. In the hand-run loop the authoring session also acts
   as planner when it drafts a plan for approval, and the maintainer is the
   orchestrator. The single-session autofix model (one session that reviews
   and pushes fixes, `CONTRIBUTING.md` §"Reviewing an open PR") is an author
   working without an independent reviewer: its review is not a reviewer
   verdict. ADR-0009 stays valid; this ADR names its parts.
7. **Per-role default tiers** (ADR-0020's rungs): planner `frontier`;
   orchestrator `strong`; author the plan row's tier (`standard` when
   unplanned); reviewer `strong` for each iteration. When an orchestrator
   runs the loop, a PR whose iteration review approves with green CI gets
   one final review at `frontier` before it is reported ready to merge, or,
   where the merge-authority ADR allows, merged.

## Consequences

- The agent-bindings profile can write one role file per role, check it
  against the table, and generate per-tool files whose tool lists enforce
  §Decision 2. A role file that grants a reviewer an edit tool contradicts
  the discipline, and a generator check can catch it. That check lands with
  the profile, with a test that shows it failing on such a file.
- **Bot identity is a setup cost.** Each adopting repository needs a bot
  account and a token scoped to its repositories, on each forge it uses.
  Branch protection can then enforce the merge-authority choice by account
  instead of by convention.
- **ADR-0009's merge verb meets the bot account.** If the bot account has no
  merge rights, the authoring session cannot execute "merge and proceed",
  and a human merges. The merge-authority ADR (ADR-0022) decides this: bot
  merge rights are recorded per repository with its branch protection, and
  a repository may keep them off the bot, in which case a human merges.
  This ADR only makes the question visible.
- **The final frontier pass is loop-only.** It is not added to the
  human-driven two-session flow, where it would add a frontier-tier review
  to every PR. Revisit if the loop's final passes catch issues the
  iteration reviews missed often enough to justify the cost by hand too.
- **Plans land by PR; the ledger's commit path is open.** The planner opens
  a PR for its plan, so approval is a review like any other. The
  orchestrator keeps the plan file as a ledger (status, PR, iteration, last
  verdict per row) and writes only those fields. The ledger's format and
  how its updates reach the default branch are part of the plan format, so
  they land with the loop's own PRs as a discipline change first.
- **Hand-run sessions change in one way:** they act through the bot
  account. The transition rule (existing credentials until a bot account
  exists, named in each PR description) sits with the invariant in
  `CONTRIBUTING.md` §"Agent roles". A hand-run session drafting a phase
  plan launches at the planner's `frontier`, per §"Per-role default model
  tiers".

## Alternatives considered

- **Keep ADR-0009's two sessions as the only topology.** Rejected: it has no
  planner or orchestrator, so an unattended loop would have to invent them
  in the runtime, outside the discipline, against ADR-0019's placement rule.
- **Let any role start agents.** Simpler to configure. Rejected: an author
  that starts its own reviewer of its PR loses reviewer independence, and
  nested starts multiply cost with no bound the plan can see.
- **Comment-only reviewer by prompt alone (status quo).** Rejected: a prompt
  is not a boundary, and the reviewer's verdict is what the merge decision
  rests on.
- **Agents act through the maintainer's account.** Zero setup. Rejected:
  the forge cannot attribute decisions, and branch protection cannot
  separate an agent's merge from the maintainer's.
- **Fold planner into orchestrator.** One fewer role. Rejected: planning
  runs once per phase at `frontier` and ends at a human approval gate; the
  orchestrator runs for the whole phase at `strong`. Merging them runs the
  long loop at the expensive tier or the plan at the cheap one.
