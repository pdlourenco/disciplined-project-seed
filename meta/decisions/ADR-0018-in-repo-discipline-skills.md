# ADR-0018 — Discipline ceremonies as in-repo skills: pre-push-review pilot

## Status

Accepted — 2026-08-22. Implements the pilot slice of
[#60](https://github.com/pdlourenco/disciplined-project-seed/issues/60);
maintainer-approved direction (conversation, 2026-08-22). Operationalised in
[`.claude/skills/pre-push-review/SKILL.md`](../../.claude/skills/pre-push-review/SKILL.md),
pointer lines in `CLAUDE.md` §2 and
[`docs/CONTRIBUTING.md`](../../docs/CONTRIBUTING.md) §"Pre-push self-review",
and a [`docs/STRUCTURE.md`](../../docs/STRUCTURE.md) entry. Skills 2–6 of the
set stay deferred in #60 with per-ceremony triggers.

## Context

The seed's discipline has two layers. The substance is repo-side and
mechanically enforced — contracts, CI gates, templates, branch protection.
Around it sit **ceremonies**: multi-step procedures an agent performs at
known moments (before a push, at phase completion, at a release), defined in
`CONTRIBUTING.md` but executed from working memory. A ceremony is re-derived
on every occurrence, and the re-derivation is where drift happens. The
record for this claim is
[PR #58](https://github.com/pdlourenco/disciplined-project-seed/pull/58):
its `pre-push review:` checklist line documents the ceremony re-assembled
per push (three review passes across the branch's pushes), and the posted
review's findings included ceremony-adjacent drift — a reviewer-pin
instruction half of which had no mechanism, and prose restating a
decision's rationale where it should have pointed (see the
[review thread](https://github.com/pdlourenco/disciplined-project-seed/pull/58#pullrequestreview-4999657636)).

Claude Code skills deliver procedural knowledge at task time. Three
properties fit the seed: repo-scoped skills under `.claude/skills/` travel
with adoption and are versioned by the existing release machinery
(ADR-0013/ADR-0015); `CLAUDE.md` can mandate invocation **by name**, which
sidesteps probabilistic description-based triggering for ceremonies that are
mandatory anyway; and skills can bundle scripts for mechanical sub-steps.

The risk is the one this repo keeps meeting: a skill that *restates* the
docs is a second copy that drifts — the same failure declined in ADR-0016
§Decision 5 (no reviewer agent file) and flagged twice in the PR #58 review.

## Decision

1. **Ship discipline-ceremony skills in-repo (`.claude/skills/`),** not as
   personal or org-level skills. In-repo skills reach every contributor's
   session, ride the release/sync machinery, and keep one source of truth.
   A personal skill would be per-user — contributors without it silently
   lose the discipline, which is the goodwill problem the seed exists to
   remove.
2. **Point, don't restate.** A SKILL.md is orchestration: the sequence of
   mechanical steps, plus instructions to *read* the governing doc sections
   fresh and use their content (the reviewer prompt, the tier table, the
   exception list). It never carries a copy of doc prose. Where a doc
   section and the skill disagree, the doc wins and the skill is the bug.
3. **Docs stay primary.** Skills are a Claude-specific accelerator, the
   same tier as `.claude/settings.json` and the session-start hook. The
   binding conventions remain in `CLAUDE.md` / `CONTRIBUTING.md`, which
   also serve agents and humans that never load a skill.
4. **Trigger by instruction.** `CLAUDE.md` §2 and `CONTRIBUTING.md`
   §"Pre-push self-review" name the skill at the point the ceremony is
   required. The skill's own description is a fallback trigger, not the
   mechanism.
5. **Pilot one ceremony: `pre-push-review`.** It is the highest-frequency
   ceremony, mandatory per push, with observed failure modes a fixed
   procedure pins (wrong seeding, inherited tier, forgotten marker). The
   remaining set (review-pr, deferral-sweep, contract-change, release,
   phase-plan; plus the out-of-repo `adopt-seed` exception) is enumerated
   and deferred in #60, each with the trigger *the next natural occurrence
   of its ceremony after the pilot ships*, conditional on the pilot's
   pattern holding.

## Consequences

- A new artifact class (`.claude/skills/`) enters the template; adopters
  that don't use Claude Code can delete it without losing anything binding,
  and `docs/STRUCTURE.md` marks it optional alongside the existing
  `.claude/` entries.
- The point-don't-restate constraint makes the skill deliberately thin; its
  value is pinned sequencing and named invocation, not new content. If the
  pilot's review or first uses show the thin skill still drifting from the
  docs, #60 reverts to `discussion` rather than growing the set.
- Skill quality iteration (eval loops per the skill-creator methodology) is
  available but deferred: the pilot's stated evaluation is real use — the
  PR-trail `pre-push review:` markers already record every occurrence, so
  the evidence accumulates without new machinery.

## Alternatives considered

- **The full six-skill set at once.** Faster to complete; rejected as five
  conventions landing on zero usage evidence — the move the seed keeps
  declining (#45, #48, #49, ADR-0016's deferred CI gate).
- **A standalone personal/org skill or plugin.** Portable to repos that
  never adopted the seed, but forks the source of truth, needs its own
  versioning, and is per-user. Recorded in #60 only as the `adopt-seed`
  exception, which cannot live in-repo by definition.
- **No skills — CLAUDE.md pointers only.** The status quo; rejected on the
  session evidence that per-occurrence re-derivation is where ceremony
  drift concentrates. Cheap to revert to if the pilot fails.
