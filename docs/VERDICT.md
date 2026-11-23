# Verdict schema

The structured record of a review ([ADR-0025](../meta/decisions/ADR-0025-verdict-schema.md)). It is one of the neutral interfaces ([`CONTRIBUTING.md`](CONTRIBUTING.md) §"Neutral interfaces"): it names no agent tool, model provider or forge, and a person can write it by hand.

A review has two renderings of one record: the readable review of [`REVIEW_CONTEXT.md`](REVIEW_CONTEXT.md) §"Review output format", and this block at the end of the same review body.

## Where it lives

The verdict is a fenced code block whose info string is `yaml verdict`, at the end of the body the reviewer posts with `post-review` (§"Forge operations"). A reader takes the **last** such block in the body. A pre-push review (`kind: pre-push`) returns the same block to its author instead of posting it.

The forge's native review state (Approve / Request changes / Comment, or approvals) is **not** the verdict: it has no `needs-human`, no verification and no finding ids, it differs between forges, and an account cannot approve its own PR. Where the forge allows, the reviewer also sets the native state to match (`approve` → Approve, anything else → Request changes), as a convenience for people reading the PR list. Nothing reads it as the decision.

## Fields

```yaml verdict
schema: 1                      # this document's version
kind: iteration                # iteration | final | pre-push
head: 3f2a9c1                  # the commit reviewed (full or abbreviated SHA)
previous_head: 8b1d04e         # the head of the verdict this one supersedes; omit on a first review
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
decisions_for_human:
  - Raises the default timeout, a threshold a later PR may revisit (CLAUDE.md §4).
```

## Rules

1. **`decision`** follows from the record:
   - `needs-human` when `decisions_for_human` is not empty, or the reviewer could not do its job (no diff, no access, contradictory contracts). It stops the loop whatever the findings say.
   - otherwise `request-changes` when any finding is a `blocker` with status `open`;
   - otherwise `approve`.

   "Approve with changes" is not a value: its conditions are blocking findings, so it is `request-changes`.
2. **Severity has two values.** A nit is a `non-blocker`.
3. **Finding ids persist across iterations.** A re-review lists every finding of the verdict it supersedes, each with a status: `resolved`, `open` or `disputed` (the author contests it; the reviewer keeps it open or resolves it, never drops it). New findings take new ids.
4. **A verdict is about one head.** Once the PR's head moves past `head`, the verdict is stale: it describes a commit that is no longer the PR.
5. **`verification` tells the truth.** A review that ran no checks says `level: none`; one that read the diff against principles only says `validation-only`. A review that checked nothing must never look like one that did.
6. **A `pre-push` verdict is never a reviewer verdict.** It uses this shape but counts toward no merge ([ADR-0021](../meta/decisions/ADR-0021-agent-roles-and-topology.md)).
7. **An unreadable verdict fails closed.** A reader that finds no block, cannot parse it, finds a field missing or a value outside its list, or finds a `decision` that contradicts rule 1, treats the verdict as `needs-human`, never as a pass.

## What the verdict is not

It records facts, not policy. How many iterations run before the loop stops, and whether a `validation-only` approval may lead to a merge, belong to the escalation-triggers ADR, so a stricter policy never needs a schema change.
