---
name: pre-push-review
description: Mandatory pre-push self-review ceremony for this repository (CLAUDE.md §2). Invoke before EVERY git push on a PR branch — including fix-up pushes on a branch with open CI, and pushes you are about to make as part of "commit and push", "apply the review", or finishing any change. Launches a reviewer subagent on the local diff at the review-role model tier, applies its findings, and records the outcome marker. The narrow exemptions are listed in docs/CONTRIBUTING.md §"Pre-push self-review"; when in doubt, run it.
---

# Pre-push self-review

This skill orchestrates the ceremony defined in `docs/CONTRIBUTING.md`
§"Pre-push self-review (agent convention)". **That section is the source of
truth** — read it fresh each time and use its content; if anything below
seems to disagree with it, the doc wins and this skill has a bug (fix the
skill, per ADR-0018). The point of running the ceremony through this skill
is pinned sequencing: the review happens before the push, at the right
tier, with the right seeding, and leaves its marker.

## Steps

1. **Check the exemptions.** Read the §"Rules of engagement" exceptions in
   `docs/CONTRIBUTING.md` §"Pre-push self-review". If the pending push is
   genuinely one of them, skip the ceremony and say so where the outcome
   marker would go. When in doubt, run it — the token cost is trivial next
   to a CI round-trip.

2. **Gather the exact diff that will be pushed.** Committed-but-unpushed
   work plus anything you are about to commit: typically
   `git diff <base>...HEAD` against the PR's base branch, plus `git diff`
   for uncommitted changes. Review what will land, not what happens to be
   in the working tree.

3. **Launch the reviewer subagent.**
   - **Tier:** pin the subagent's model to the review-role tier — look up
     the current alias in `docs/CONTRIBUTING.md` §"Model tier selection"
     (the `planning-and-review` row). Never let it inherit this session's
     model.
   - **Seeding:** tell it to read `docs/REVIEW_CONTEXT.md`,
     `docs/DESIGN.md`, `docs/SPEC.md`, and `docs/ROADMAP.md` before
     reviewing, so it reviews against what the project cares about.
   - **Prompt:** have it apply the reviewer prompt from
     `docs/CONTRIBUTING.md` §"Pre-push self-review" §"Reviewer prompt" —
     all its numbered bullets, including label consistency and lifecycle
     currency on linked issues. Pass the section reference and the diff;
     do not paste a from-memory copy of the prompt.
   - State the PR's declared purpose so scope drift is checkable.

4. **Act on the findings before pushing.** Fix what is right; where you
   disagree with a finding, that is a judgment call — note it in the PR
   description so the human reviewer sees the reasoning. If fixes were
   non-trivial, re-run the ceremony on the amended diff (a focused
   verification pass over the fix is acceptable for small amendments).

5. **Run the local CI suite** per `docs/CONTRIBUTING.md` §"Pre-push CI run"
   (this repo: `scripts/local-ci.sh`). Both pre-push disciplines run; the
   reviewer catches judgment issues, the CI run catches mechanical ones.

6. **Push, then record the outcome marker** in the PR description (or the
   commit message summary if no PR exists yet), in the exact shape
   documented in §"Rules of engagement" of the same `CONTRIBUTING.md`
   section. An exempted push records the exemption instead. The marker is
   what makes the ceremony auditable after the fact — a run that leaves no
   marker is indistinguishable from a run that never happened.
