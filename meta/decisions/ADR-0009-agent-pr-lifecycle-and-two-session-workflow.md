# ADR-0009 — Agent PR lifecycle: open/merge gate + two-session authoring / review workflow

## Status

Accepted — 2026-06-18.

Forward-ported from downstream adopter `ppqq-active` (its `ADR-0047`). Surfaced in [#26](https://github.com/pdlourenco/disciplined-project-seed/issues/26).

## Context

The seed documented *how to review* an open PR ([ADR-0008](ADR-0008-reviewer-invocation-convention.md), `CONTRIBUTING.md §"Reviewing an open PR"`) but was silent on the most basic agent action in the PR lifecycle: **when may an agent open a PR, and when may it merge one?** `CLAUDE.md` stopped at §4; `CONTRIBUTING.md` had no description of who authors versus who reviews when parallel agent sessions run a track.

That gap had a concrete cost. The `§"Reviewing an open PR"` prompt template tells the reviewer to *"push a fix where the call is clear"* — correct for the **single-session autofix / babysit** model (one session both reviews and fixes), but a latent contradiction the moment a track is split into an authoring session and a separate reviewing session, where the reviewer must be comment-only. Without a written topology, the two models silently blur.

`ppqq-active` had already codified the lifecycle (`ADR-0047` + a `CLAUDE.md` section + a `CONTRIBUTING` section). The seed has the same shape of work and the same gap, so the convention back-ports.

## Decision

Adopt a two-session topology as the seed's default for parallel agentic development, and state the open/merge authorization explicitly:

- **Opening a PR is free for planned work.** Implementing an already-approved item in a phase plan's PR sequence does not need separate approval; the §2 pre-push self-review and pre-push CI run first. Unplanned work follows `CLAUDE.md` §4 (surface, wait for go-ahead) before the PR is opened.
- **Merging always requires explicit maintainer approval** — never on the agent's own initiative, not even a green PR.
- **Two sessions, three verbs.** An *authoring* session authors / edits, pushes fixes, and merges on *"merge and proceed."* A *reviewing* session only reviews and never edits, pushes, or merges. The pre-push self-review of one's own diff is not the same verb as reviewing a PR.
- The disambiguating bullet is added to `§"Reviewing an open PR"` so the *push-a-fix* instruction is scoped to the single-session model.

Lands as: `CLAUDE.md` §5, `CONTRIBUTING.md §"Two-session authoring / review workflow"` (roles table, 5-step loop, command vocabulary), the `§"Reviewing an open PR"` comment-only bullet, and this ADR.

## Consequences

- **The lifecycle is durable repo policy, seeded per session as just role + phase.** The kickoff collapses to one line — *"you are the authoring / reviewing session for Phase N, per `CONTRIBUTING.md` §Two-session…"* — instead of re-explaining the topology each time.
- **Repo policy does not self-bind a session.** This ADR is a convention, not an authorization. The operative grant — that an agent may open PRs without asking, or merge on a phrase — still comes from how the session/environment is launched; the standing grant must be given there too. `CLAUDE.md` §5 states this caveat so an agent does not read the doc as permission the session didn't grant.
- **One shared reviewer across parallel authors, by default.** When two authoring sessions share a contract surface, a single reviewer holding both contexts catches cross-track drift that two siloed reviewers each miss. Stated in the workflow section.
- **Interacts with the ADR-number sequence.** Two authoring sessions both appending ADRs collide at the second merge; the mitigation (reserve a band, rebase before finalizing the number) is recorded in `docs/decisions/README.md §"Numbering and filenames"` rather than here, since it is a numbering convention, not a workflow decision.
- **Revisit condition.** If single-session autofix / babysit becomes the dominant mode (e.g. solo maintainer, no parallel tracks), the two-session topology is overhead — at which point this ADR's §"Roles" collapses to "one session does all three verbs on the maintainer's say-so" and the comment-only carve-out is the exception rather than the default.

## Alternatives considered

- **Seed the full workflow per session.** Re-state the topology, roles, and command vocabulary in every session kickoff. Rejected — it is exactly the re-typing the parameterised conventions (ADR-0008) were created to avoid; durable policy in `CONTRIBUTING.md` with per-session role+phase is lighter and drifts less.
- **A dedicated `WORKFLOW.md`.** A separate top-level doc for the lifecycle. Rejected — the lifecycle is contributor mechanics, which `CONTRIBUTING.md` already owns; a new doc fragments the surface and competes with `CONTRIBUTING.md` for "where do I look." Same reasoning ADR-0008 used to reject a dedicated `REVIEWING.md`.
- **Require approval to open every PR.** Safer but slower; it defeats the point of a pre-approved phase plan and turns every in-plan PR into a round-trip. Rejected — the plan *is* the approval for opening; merging is where the human gate belongs.
- **Leave the autofix / two-session ambiguity unresolved.** Rejected — the *push-a-fix* line actively misleads a comment-only reviewer; the contradiction is in the seed today and costs nothing to fix.
