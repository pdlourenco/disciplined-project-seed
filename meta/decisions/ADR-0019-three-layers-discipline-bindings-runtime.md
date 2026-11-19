# ADR-0019 — Three layers: discipline, agent bindings, runtime

## Status

Proposed — 2026-11-19. Phase 6 item 1 of the maintainer's agent
implementation plan (first of three governance ADRs that must land before
the agentic profile; ADR-0020 and ADR-0021 follow as stacked PRs).
Operationalised in the root [`README.md`](../../README.md) §"Three layers".

## Context

The seed already holds two kinds of artifact without naming the difference:

- **Tool-neutral discipline.** `docs/` (CONTRIBUTING, REVIEW_CONTEXT, SPEC,
  plans, ADRs), the templates, and the CI gates. A human with git and a
  forge can follow all of it.
- **Tool-specific bindings.** `CLAUDE.md`, `.claude/settings.json`,
  `.claude/hooks/session-start.sh` and `.claude/skills/pre-push-review/`.
  ADR-0018 §Decision 3 already treats these as one tier ("a Claude-specific
  accelerator, the same tier as `.claude/settings.json` and the
  session-start hook") and rules that the docs stay primary. ADR-0016
  §Decision 5 declined a `.claude/agents/` reviewer file for the same
  reason: a binding that restates the docs drifts.

Two upcoming pieces of work make the implicit split load-bearing:

- **An agentic profile.** Neutral role definitions, a generator that emits
  per-tool agent files, forge mappings and a verdict parser. That is five or
  more new tool- or forge-specific artifacts. Without a rule, each PR
  re-decides what they may restate and whether a non-agent adopter must
  carry them.
- **A runtime.** A container, a session supervisor and messaging channels
  that run agent sessions unattended. Its first implementation is a
  separate public repository, `pessoa-relayer`. It changes when the agent
  binary, the channels or the host change, none of which is a reason to cut
  a seed release.

The scaling rule in the README (*drop files, don't dilute rules*) already
says how an optional part should behave. What is missing is which parts are
optional, and which way dependencies may point.

## Decision

1. **Three layers, one dependency direction:
   runtime → agent bindings → discipline.** Nothing points the other way.
   - **Discipline** — the binding conventions and contracts, neutral about
     agent tool and forge, and complete on its own: following it by hand is
     fully compliant.
   - **Agent bindings** — an optional profile inside the seed that carries
     the discipline into specific agent tools and forges. Today:
     `CLAUDE.md` and `.claude/`. An adopter opts out by deleting the files
     and loses nothing binding.
   - **Runtime** — outside the seed, in its own repository. It pins a seed
     version, reads seed files, and never modifies them. The seed never
     names a runtime as a requirement.
2. **Placement rule.** A rule that must hold whoever does the work belongs
   in the discipline. How a given tool or forge carries that rule belongs in
   the bindings. Where and how sessions run belongs in the runtime. When a
   binding needs a rule the discipline does not state, the rule lands in the
   discipline first, in the same PR (the SPEC-first rule, applied across
   layers).
3. **Versioning.** Discipline and bindings ship under one seed tag, through
   the existing release machinery (ADR-0013, ADR-0015). Each
   `meta/CHANGELOG.md` entry names the layer it touches, and
   `DISCIPLINE_ADOPTION.md` records whether the profile was adopted. The
   runtime has its own versions and records the seed version it targets.

## Consequences

- The agentic profile has a home and a rule before its first file lands.
  Opting out is deletion, which matches the README's scaling rule.
- Runtime churn (agent binary versions, channel protocols, hosts) never
  forces a seed release, and a seed release never forces a runtime change
  until the runtime moves its pin.
- Point-don't-restate (ADR-0018 §Decision 2) now covers every binding, not
  only skills. A role file or generated agent file that copies discipline
  prose is the drift bug ADR-0016 §Decision 5 avoided.
- `CLAUDE.md` straddles the line today: a Claude-specific file that carries
  agent operating rules (§1–§5) which every agent should follow. The
  agentic profile resolves this by moving those rules into a tool-neutral
  `AGENTS.md` and leaving `CLAUDE.md` as a thin import. Until then
  `CLAUDE.md` stays as it is.
- One tag for two layers means an adopter cannot take a bindings change
  without the discipline changes released alongside it. Accepted for now:
  the profile is small, and a second tag stream doubles the release
  ceremony. **Revisit** when an adopter reports needing one layer's change
  without the other's.
- **Deferred: a layering check.** A tier-3 gate that fails when a
  discipline-layer file references a runtime repository or a binding path
  as a requirement. Not wired now: there is no profile yet for it to
  police. **Trigger:** the first agentic-profile PR, or the first review
  finding of a wrong-direction reference, whichever comes first. Like every
  new check, it lands with a test that shows it can fail.

## Alternatives considered

- **Leave the split implicit (status quo).** Each binding PR re-derives the
  rule, as ADR-0016 and ADR-0018 each had to for one artifact. Rejected:
  the profile multiplies those PRs by five or more.
- **Bindings in the runtime repository.** Rejected: bindings are useful with
  no runtime. A person running one agent session by hand still wants the
  role files. Bindings would also inherit the runtime's release cadence,
  which is set by host and binary changes.
- **Bindings in a third repository.** Clean versioning, but it adds a third
  release stream and a cross-repo pin for a handful of files that must sit
  in the adopter's own tree anyway. Rejected for now. **Revisit** if
  bindings for several tools outgrow what an adopter would delete by hand.
- **Runtime inside the seed.** Rejected: it is host-specific and heavy, and
  it would make the seed depend on an agent binary and a container
  toolchain, contradicting the seed's tool-agnostic shape.
- **Two layers, bindings mandatory.** Ship the profile as part of the
  discipline. Rejected: an adopter that does not use agents would carry
  agent files, the dilution the scaling rule forbids.
