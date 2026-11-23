# ADR-0025 — The verdict schema: one record, rendered as the readable review plus a block in the same body

## Status

Proposed — 2026-11-23. Drafted from the maintainer's brief,
[#78](https://github.com/pdlourenco/disciplined-project-seed/issues/78),
whose decisions are marked there as decided and are recorded here as
given: the three `decision` values, the two severities, finding ids that
persist across iterations, the review body (not the forge's review state)
as the verdict, the rule that an agent's approval never counts as a human
approval, and the revision of every place that describes review output.
Four points #78 left for the draft are proposed below and are the
maintainer's to settle. Implements the "verdict schema" row of
[ADR-0020](ADR-0020-provider-and-forge-neutral-interfaces.md)'s neutral
interfaces, and amends
[ADR-0021](ADR-0021-agent-roles-and-topology.md) (what the reviewer
produces), [ADR-0022](ADR-0022-merge-authority-and-unprompted-work.md)
("the final review approves" becomes a verdict field, and an agent's
approval is never a human one) and
[ADR-0023](ADR-0023-two-plan-carriers.md) (the ledger's "last verdict" is
the verdict's `decision` and `head`); each gets an "Amended by" note on
acceptance. Two further questions raised in review are open for the
maintainer below. Operationalised in [`docs/VERDICT.md`](../../docs/VERDICT.md),
[`docs/REVIEW_CONTEXT.md`](../../docs/REVIEW_CONTEXT.md) §"Review output
format", and [`docs/CONTRIBUTING.md`](../../docs/CONTRIBUTING.md)
§"Pre-push self-review", §"Reviewing an open PR", §"Agent roles",
§"Merge authority", §"Neutral interfaces" and §"Forge operations".

## Context

CONTRIBUTING §"Neutral interfaces" lists the verdict schema as "not yet
written; lands with its own ADR". Several accepted decisions already read
a verdict without defining one:

| Reader | Needs from it |
|---|---|
| The orchestrator (ADR-0021) | a decision it can act on without interpreting prose |
| §"Merge authority" (ADR-0022) | "the final review approves on the current head": the commit reviewed |
| The ledger (ADR-0023) | "last verdict" per item: one short value |
| The author | findings to act on: where, how serious, what to change |
| The escalation triggers (their own ADR, next) | facts to fire on |
| A human | the readable review of `REVIEW_CONTEXT.md` §"Review output format" |

Today's verdict is a prose line, "approve / approve with changes / request
changes", which none of the machine readers can act on safely, and which
says nothing about what the reviewer actually checked.

## Decision

1. **One schema, two renderings.** The readable review stays as
   `REVIEW_CONTEXT.md` §"Review output format" describes it; a structured
   block at the end of the same review body carries the same record. The
   schema is written in `docs/VERDICT.md` (proposed, (ii) below); its
   fields are `schema`, `kind` (`iteration` / `final` / `pre-push`),
   `head`, `previous_head` (proposed, (iii) below), `decision`,
   `verification`, `findings` and `decisions_for_human`.
2. **Three decisions** (decided): `approve`, `request-changes`,
   `needs-human`. "Approve with changes" is not a machine value: its
   conditions become blocking findings, so it is `request-changes`.
   `needs-human` is for a `CLAUDE.md` §4 decision, or a reviewer that
   could not do its job, and stops the loop whatever the findings say.
3. **Two severities** (decided): `blocker`, `non-blocker`; a nit is a
   non-blocker. **Finding ids persist across iterations** (decided): a
   re-review gives each earlier finding a status, `resolved`, `open` or
   `disputed`, which makes iterations countable and lets a trigger fire on
   a blocker that recurs.
4. **`verification` is part of the record**: `full`, `validation-only` or
   `none`, the checks that ran, and the CI state the reviewer saw. A review
   that checked nothing must never look like one that did.
5. **`decisions_for_human` is kept apart from findings**, because a §4
   decision blocks a labelled merge even with no blocking findings.
6. **The review body is the verdict, not the forge's review state**
   (decided). The native state has at most three values, no
   `needs-human`, verification or ids, differs between forges, and fails
   whenever author and reviewer act through one account. The reviewer sets
   it to match where the forge allows, as a convenience. **Nothing reads
   the native state as the decision, and branch protection never counts an
   agent's approval as a human approval**; that rule joins §"Merge
   authority", so a bot's approval can never satisfy a gate meant for
   humans and widen merge authority.
7. **An unreadable verdict fails closed.** A reader treats a verdict it
   cannot parse, or one whose `decision` contradicts its own findings, as
   `needs-human`, never as a pass.
8. **Policy stays out.** The verdict records facts; how many iterations
   run before the loop stops, and whether a `validation-only` approval may
   lead to a merge, belong to the escalation-triggers ADR.
9. **Every place that describes review output is revised to match, in this
   PR** (decided): `REVIEW_CONTEXT.md`, CONTRIBUTING's review, roles,
   merge-authority, interfaces and forge-operation sections, the README's
   left/right-side paragraph, and the `pre-push-review` skill.

### Proposed for the points #78 left to the draft (the maintainer's to settle)

- **(i) Format and how a reader finds it.** YAML in a fenced block whose
  info string is `yaml verdict`, at the end of the body; a reader takes the
  last such block. *Why:* YAML is readable and writable by hand, the
  `yaml` word gives syntax highlighting on every forge, and the second
  word finds it without a separate marker. JSON would read worse to a
  person, and an HTML-comment marker would hide the record from the reader
  it is also for.
- **(ii) Where the schema is written.** A file of its own,
  `docs/VERDICT.md`, which §"Neutral interfaces" points to. *Why:* the
  parser in the agent-bindings profile tests against it, and CONTRIBUTING
  is already the longest file in the seed; a section there would mix a
  machine contract into process prose.
- **(iii) How a re-review refers to an earlier verdict.** By its head:
  `previous_head`. *Why:* a review id is forge-specific; a commit SHA is
  the same on every forge and is what the staleness rule already uses.
- **(iv) When the hand-run flow starts writing the block.** From day one,
  as #78 recommends, so people test the format before a machine depends on
  it. The pre-push outcome marker in the PR description keeps its shape and
  summarises the `pre-push` verdict.

### Open questions raised in review (the maintainer's)

- **(v) Setting the native review state.** #78 decided the reviewer also
  sets the forge's native state to match "where the forge allows". On
  GitHub, an Approve from any account with write access counts toward a
  required approving review, so that convenience would make an agent's
  approval satisfy a gate meant for humans, which the same brief rules
  out; the seed has no setting that prevents it.
  - **(a) Recommended:** the reviewer never sets Approve; it uses Comment,
    or Request changes when the decision is not `approve`. *Why:* it holds
    on every forge with no setup.
  - **(b)** Keep setting Approve, and make the setup prevent it from
    counting: no write-level review rights for the agent's account, or
    human-only code owners on protected paths. Needs per-repository setup,
    and fails open when that setup is missing.
- **(vi) Who may post a verdict that counts.** Any comment ending in a
  `yaml verdict` block would parse, including one from the author, and
  accounts may be shared today.
  - **Recommended:** only a verdict posted with `post-review` by the
    reviewer role counts, and the orchestrator reads only the reviews it
    started; in the hand-run flow, the reviewing session's.

## Consequences

- **The orchestrator, the ledger and §"Merge authority" read one field.**
  "The final review approves on the current head" becomes: a `kind: final`
  verdict (`iteration` in the hand-run flow, which has no final pass) with
  `decision: approve` and `head` equal to the PR's head.
- **The agent-bindings profile's verdict parser** has a written contract to
  parse and test against, including rule 7's failure cases.
- **Reviews get longer by one block.** The readable review is unchanged;
  the block repeats it in a form a machine can act on.
- **`.claude/` and §"Merge authority" change**, both agent-authority paths,
  so this PR needs the maintainer's merge whatever its label.
- **The escalation-triggers ADR comes next** and reads this record.

## Alternatives considered

- **The forge's native review state as the verdict.** Built in, no new
  format. Not recommended (decided against in #78): three states at most,
  different per forge, no `needs-human` or verification, and unusable when
  author and reviewer share an account.
- **Keep the prose verdict line.** No change. Not recommended: no machine
  can act on it safely, and "approve with changes" is a decision with
  conditions nobody checks.
- **A separate verdict file or artifact per review** (committed, or
  attached to CI). Keeps the review body clean. Not recommended: it needs a
  place to live on every forge and a way to tie it to the review; the
  review body already exists on all of them and a person can write it.
- **More severities** (critical / major / minor / nit). Finer grading. Not
  recommended (decided against in #78): only "does this block the merge"
  drives any decision, and extra grades invite argument without changing
  the outcome.
