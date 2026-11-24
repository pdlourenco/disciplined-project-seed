# Verdict schema

The structured record of a review ([ADR-0025](../meta/decisions/ADR-0025-verdict-schema.md)). It is one of the neutral interfaces ([`CONTRIBUTING.md`](CONTRIBUTING.md) §"Neutral interfaces"): it names no agent tool, model provider or forge, and a person can write it by hand.

A review has two renderings of one record: the readable review of [`REVIEW_CONTEXT.md`](REVIEW_CONTEXT.md) §"Review output format", and this block at the end of the same review body.

## Where it lives

The verdict is a fenced code block whose info string is `yaml verdict`, at the end of the body the reviewer posts with `post-review` (§"Forge operations"). A reader takes the **last** such block in the body. A pre-push review (`kind: pre-push`) returns the same block to its author instead of posting it.

The forge's native review state (Approve / Request changes / Comment, or approvals) is **not** the verdict: it has no `needs-human`, no verification and no finding ids, it differs between forges, and an account cannot approve its own PR. Where the forge allows, the reviewer also sets the native state to match (`approve` → Approve, anything else → Request changes), as a convenience for people reading the PR list (which native states it sets at all is open in ADR-0025 (v)). Nothing reads it as the decision.

## Fields

```yaml verdict
schema: 1                      # this document's version, raised on any change to fields, values or rules; unknown → fail closed (rule 7)
kind: iteration                # iteration | final (the loop's final pass only; a hand-run review writes iteration) | pre-push
number: 2                      # this verdict's number on the PR; 1 on a first review
head: "3f2a9c1e5b7d0a4c6e8f1b3d5a7c9e0f2b4d6a8c"           # the commit reviewed, quoted
decision: request-changes      # approve | request-changes | needs-human
verification:
  level: full                  # full | validation-only | none
  checks: [local-ci, tests]    # what the reviewer ran or read the results of
  ci: green                    # green | red | pending | none, as the reviewer saw it
findings:
  - id: F1                     # stable across iterations
    severity: blocker          # blocker | non-blocker
    status: open               # open | resolved | disputed (resolved and disputed only on a re-review)
    location: docs/SPEC.md:42
    claim: The rate limit is stated twice with different values.
    evidence: "SPEC.md:42 says 10/s; SPEC.md:118 says 20/s."   # or a "to reproduce" step
    change: Keep one value and cite it from the other place.
decisions_for_human: []        # e.g. "Raises the default timeout, a threshold a later PR may revisit (CLAUDE.md §4)"
```

**Required fields:** every field above. An empty list is written `[]`, never left out. `number` is a whole number from 1. `head` is a quoted string (an all-digit short SHA would otherwise parse as a number) and holds the full SHA, except in a `pre-push` verdict, whose head may be abbreviated, or the literal `"working-tree"` when it reviews uncommitted changes.

## Rules

1. **`decision`** follows from the record:
   - `needs-human` when `decisions_for_human` is not empty, any `blocker` is `disputed` (author and reviewer disagree, so a human decides), or the reviewer could not do its job (no diff, no access, contradictory contracts; it says why in a blocker finding). It stops the loop whatever the findings say.
   - otherwise `request-changes` when any finding is a `blocker` with status `open`;
   - otherwise `approve`.

   "Approve with changes" is not a value: its conditions are blocking findings, so it is `request-changes`.
2. **Severity has two values.** A nit is a `non-blocker`.
3. **A PR's verdicts are numbered, and only the highest-numbered one stands.** A first review is `number: 1`. A re-review takes the highest `number` among the PR's verdicts that count (who may post one is open in ADR-0025 (vi)) plus one, and supersedes every verdict at that number: it lists every finding of each, with a status: `resolved`, `open` or `disputed` (the author contests it and the reviewer still holds it; a disputed blocker goes to a human, rule 1). A contest the reviewer accepts is `resolved`. The reviewer never drops a finding, and changes a finding's severity only with its `claim` saying so and why. New findings take new ids; where two superseded verdicts used one id for different findings, the re-review keeps it for one and gives the other a new id whose `claim` names the old one. A reader takes the decision from the highest-numbered verdict only; a superseded verdict is never read for it. Verdicts are numbered rather than tied to `head` because two can review the same head: a reviewer run again without a push, or two reviewers at once. A `pre-push` review numbers its own chain in the authoring session, apart from the PR's (rule 6): the author gives the reviewer the previous pre-push verdict, if any.
4. **A verdict is about one head.** Once the PR's head moves past `head`, the verdict is stale: it describes a commit that is no longer the PR.
5. **`verification` tells the truth.** A review that ran no checks says `level: none`; one that read the diff against principles only says `validation-only`. A review that checked nothing must never look like one that did.
6. **A `pre-push` verdict is never a reviewer verdict.** It uses this shape but counts toward no merge ([ADR-0021](../meta/decisions/ADR-0021-agent-roles-and-topology.md)).
7. **An unreadable verdict fails closed.** A reader that finds no block, cannot parse it, finds a `schema` it does not know, a required field missing or a value outside its list or range, finds two verdicts at the PR's highest `number` (until a re-review supersedes both), or finds a `decision` more permissive than rule 1 allows (an `approve` with an open or disputed blocker or a decision for a human; a `request-changes` with a disputed blocker or a decision for a human), treats the verdict as `needs-human`, never as a pass. A decision stricter than rule 1 requires stands.

## What the verdict is not

It records facts, not policy. How many iterations run before the loop stops, and whether a `validation-only` approval may lead to a merge, belong to the escalation-triggers ADR, so a stricter policy never needs a schema change.
