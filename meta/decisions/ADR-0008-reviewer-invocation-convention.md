# ADR-0008 — Parameterised reviewer-invocation convention for open PRs, with CI-aware fallback and follow-through-by-default subscription

## Status

Accepted — 2026-06-02.

## Context

The seed already documents how a contributor's local pre-push reviewer-agent invocation should look (`CONTRIBUTING.md §"Pre-push self-review"`, extended in [ADR-0003](ADR-0003-labels-applied-via-reviewer.md)). It did *not* document how to invoke a reviewer agent against an **already-open PR** — yours or someone else's, on GitHub, where the agent fetches the diff via the GitHub MCP tools and (by default) posts findings as inline PR review comments.

In practice the open-PR invocation has been a long ad-hoc prompt: *"subscribe to and review PR NN against the principles in REVIEW_CONTEXT.md and the current state of DESIGN/SPEC/ROADMAP. Focus on cross-document consistency and architectural principle violations. Provide comments directly on the PR …"* — re-typed each time, with no documented defaults, no V&V-mode lever ([ADR-0007](ADR-0007-v-cycle-additions.md)'s contribution), no policy for what to do when CI didn't run.

Three properties of this invocation deserve to be locked in (and so deserve an ADR) rather than left ad-hoc:

1. **Defaults.** What's the default mode (bundled vs single-mode)? Default output channel (post comments vs report in-conversation)? Default context-doc set?
2. **CI-handling fallback chain.** A reviewer agent reviewing an open PR can encounter four CI states: green / red / not-yet-run / never-going-to-run (workflows off, fork, Actions minutes out). What's the policy for each? `CLAUDE.md §4` names "fallback ordering" explicitly as ADR-worthy.
3. **Surface — where in the docs.** `CONTRIBUTING.md` (alongside §"Pre-push self-review") vs `REVIEW_CONTEXT.md` (the "what you review against" doc) vs a dedicated file. Choosing wrong would over-load one doc's purpose with another's.

## Decision

Add a §"Reviewing an open PR" subsection to `CONTRIBUTING.md`, peer to the existing §"Pre-push self-review" and §"Pre-push CI run". The section parameterises the invocation across **six levers** with conservative defaults:

1. **PR number** (required).
2. **Mode** — `bundled` (default; both verification *and* validation per [`REVIEW_CONTEXT.md` §"Verification vs validation"](../../docs/REVIEW_CONTEXT.md)) / `verification-only` / `validation-only`.
3. **Output channel** — `comments` (default; inline PR review comments via GitHub MCP tools) / `report` (in-conversation, posted publicly only after requester confirms).
4. **Context-doc set** — defaults to `REVIEW_CONTEXT.md` + `DESIGN.md` + `SPEC.md` + `ROADMAP.md`. Override when the PR is adjacent to a specific ADR or other doc.
5. **CI handling** — `check-or-run` (default) / `skip`.
6. **Subscription** — `subscribe` (default; after the initial review the reviewer subscribes to PR activity events and follows through on subsequent pushes, review comments, and CI changes — investigating each, pushing fixes where tractable, replying for clarifications, or escalating ambiguity) / `once` (one-shot review, no subscription).

**CI-handling fallback chain** (the load-bearing trade-off; default `check-or-run`):

- **CI ran, green** → one-line summary in the verdict.
- **CI ran, red** → fetch failing job logs, summarise each failure with the specific assertion / step / check that failed (not "tests failed").
- **CI did not run** (workflows off, fork without permission, Actions minutes exhausted, simply not yet triggered) → invoke the local equivalent per [`CONTRIBUTING.md` §"Pre-push CI run"](../../docs/CONTRIBUTING.md) — tier 1 + tier 3 — and report the result the same way.
- **`skip` requested** → omit CI handling entirely; the verdict must say so explicitly, since a review that didn't verify is a validation-only review.

**Call-site invocation collapses** to *"review PR NN per `CONTRIBUTING.md` §Reviewing an open PR"* (plus inline parameter overrides when needed: *"… — verification-only, report"*, *"… — plus docs/decisions/ADR-NNNN"*).

**Surface choice:** `CONTRIBUTING.md`, not `REVIEW_CONTEXT.md`. `REVIEW_CONTEXT.md` answers *what the reviewer reviews against* (principles, terminology, red flags); `CONTRIBUTING.md` answers *how the workflow operates* (CI strategy, pre-push, label hygiene). The invocation prompt is workflow mechanics, not content the reviewer measures against — so it belongs with the existing reviewer-invocation conventions in `CONTRIBUTING.md`.

## Consequences

- **Reviewer invocations standardise.** Contributors stop re-typing the long prompt; the call site collapses to a one-line reference. The six parameters expose the variability that actually exists (mode / output / context / CI / subscription) without forcing it on the caller.
- **Reviews follow through on the PR lifecycle by default.** A reviewer that posts findings and exits misses most of the value when the contributor pushes a fix, CI completes red, or a reviewer comment needs a response. `subscribe` as default keeps the reviewer responsive through the lifecycle until explicitly told to stop; `once` covers the triage / fast-first-pass case where staying alive would be wasted. **Trade-off:** in environments where PR-activity subscription is exclusive (e.g. the Claude Code on the web subscription tool), `subscribe` takes exclusive ownership of the PR's events and disconnects any other watcher (an org PR Steward, a separate reviewer session, etc.). Accepted because follow-through is the common case, but the convention requires the subscribing session to **announce the take-over at subscribe time** (see `CONTRIBUTING.md §"Reviewing an open PR"` Invocation rules) so event-ownership reassignment is never silent.
- **CI-unreachable failure mode handled by policy, not improvisation.** When Actions minutes are out or a fork can't trigger workflows, the reviewer falls back to a local tier-1+3 run rather than silently skipping the right-side mechanical checks. A review that *did* skip must say so in the verdict — visible debt, not invisible.
- **Verification-mode findings can cite the `Verified by:` mechanism.** ADR-0007's per-rule `Verified by:` annotation in `SPEC.md` becomes citeable from PR review comments, so contributors can see whether the mechanism caught the drift or whether it's an uncovered gap.
- **`REVIEW_CONTEXT.md` stays focused on content** (principles + red flags + output format). The new section in `CONTRIBUTING.md` references it for V&V modes and output format but doesn't duplicate them.
- **No new on-disk artifacts beyond this ADR and the new subsection.** No new dependencies. The convention works against the existing GitHub MCP tool set; the local-CI fallback uses the existing `CONTRIBUTING.md §"Pre-push CI run"` (ADR-0004) commands.

## Alternatives considered

- **A — leave the invocation ad-hoc.** Rejected. The long prompt was already being re-typed inconsistently across PR reviews; defaults, modes, and CI-handling drifted between invocations.
- **B — put the convention in `REVIEW_CONTEXT.md`.** Rejected. `REVIEW_CONTEXT.md` is the *what's reviewed against* doc, deliberately framed as both a reviewer prompt *and* a project-values statement (per its own header). Loading "how to ask for a review" mechanics into it dilutes that purpose. `CONTRIBUTING.md` already owns workflow-mechanics neighbours (§"Pre-push self-review", §"Pre-push CI run") and is the better surface.
- **C — a dedicated `REVIEWING.md` doc.** Rejected. The content is one subsection; a whole file is over-scaffolded. If the surface grows past ~3 subsections of mechanics, revisit.
- **D — chosen path: §"Reviewing an open PR" in `CONTRIBUTING.md`, six parameters, conservative defaults, explicit CI fallback chain, follow-through-by-default subscription.**
- **`report` (in-conversation) as the default output channel** — considered. Rejected: most reviews are routine and the contributor wants the findings on the PR, not gated behind a second human triage step. `report` stays available for novel-shape PRs where low-confidence findings shouldn't land as public noise; `comments` as default matches the seed's "make scaffolding explicit" stance — defaults should reflect the common case, not the cautious one.
- **`validation-only` as the default mode** — rejected. CI itself already covers most of the verification surface (`Verified by:` mechanisms); a default of `validation-only` would skip the mechanical re-check on the (common) case where CI is reachable. `bundled` keeps verification as a safety net without much added cost.
- **Make CI-handling mandatory `check-or-run`, no `skip` option** — rejected. A pure-prose docs PR with no gates that apply genuinely doesn't need CI-handling; `skip` exists to cover that, with the labelling-as-validation-only discipline making the omission visible in the verdict.
- **`once` (no subscription) as the default** — rejected. Most reviews are not triage; the natural shape is for the reviewer to react to subsequent pushes and CI changes through the PR's lifecycle. Forcing the requester to opt into subscription each time inverts the common-case incentive and bakes "review once, walk away" into the default — exactly the brittleness the convention exists to prevent. The exclusivity side-effect (subscribing displaces other watchers in environments where the subscription is exclusive) was weighed against this and accepted because the announce-at-subscribe-time discipline makes the take-over visible. `once` stays available for fast first-pass triage where staying alive would be wasted, *or* where the requester knows another watcher should keep event ownership.

## Related

- [ADR-0003](ADR-0003-labels-applied-via-reviewer.md) — extended the pre-push reviewer prompt with label-vs-diff + lifecycle currency bullets; this ADR adds the *PR-stage* counterpart with its own CI-aware extensions.
- [ADR-0004](ADR-0004-pre-push-ci-via-ecosystem-task-runner.md) — the local-CI fallback in the new section's CI handling uses ADR-0004's tier-1+3 commands.
- [ADR-0007](ADR-0007-v-cycle-additions.md) — V&V split (mode parameter), `Verified by:` mechanism (verification-mode findings cite it).
