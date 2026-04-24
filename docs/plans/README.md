# Phase Plans

This directory holds the narrative per-phase plans. Each plan owns its PR sequence, per-PR gates, success criteria, and follow-ups. The phase's terse summary lives in [`../ROADMAP.md`](../ROADMAP.md) and links to its plan here.

## What a phase plan is — and isn't

**A phase plan is the execution view of a phase.** It tells a reader (human or agent) what it means to ship this phase, in enough detail that a PR can be written against it.

**A phase plan is NOT:**

- A roadmap. The roadmap is the portfolio view — all phases at a glance. A plan is the depth for exactly one phase.
- A contract. `docs/SPEC.md` owns contracts. A plan schedules *implementations* of contracts; it does not define them. When a plan needs to change a contract, the relevant SPEC edit belongs in the prerequisite PR, not the plan.
- A design document. `docs/DESIGN.md` owns architectural rationale. A plan schedules *deliveries within* the architecture.

The shape the plan takes — the numbered sections, the per-PR gates, the anti-drift assertions — is in [`PHASE-TEMPLATE.md`](PHASE-TEMPLATE.md).

## Rule of thumb for plan length

A plan should be roughly an order of magnitude longer than its roadmap entry. If it's shorter, the plan is likely missing operational detail (per-PR gates, success criteria, follow-ups) and reviewers will fill those gaps with guesswork. If the plan is *significantly* longer still, some of its content probably belongs in SPEC, DESIGN, or an ADR — push it there and link rather than embed.

## Index

<!-- One entry per phase plan. Keep in phase order.

     Example entries:

     - [Phase 1](PHASE-1.md) — <title> — Status: Complete.
     - [Phase 2](PHASE-2.md) — <title> — Status: In progress. PRs <list>.
     - [Phase 3](PHASE-3.md) — <title> — Status: Draft. Not yet started. -->

<!-- Your first entries here: -->
