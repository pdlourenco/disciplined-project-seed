# [PROJECT] — Development Roadmap

<!-- Optional terminology callout. Use when your project has more than
     one orthogonal numbering or labeling scheme. Conflating milestone
     numbers with version numbers or with architectural migration
     steps is one of the most common drift failures.

     Example:

     > **Terminology.** *Phase N* (Phase 1–N) refers to the delivery
     > milestones in this document. *Gen 1 / Gen 2* refers to the
     > [component] technology transition: Gen 1 is [today's stack]
     > (spans Phases 1–N), Gen 2 is [future stack] (a Future
     > milestone). Gen 2 uses named migration steps, not phase
     > numbers — it re-platforms internally without adding
     > user-visible phases. See `DESIGN.md`. -->

Phase-scoped narrative plans (PR sequences, per-PR gates, surfaced ADRs, success criteria) live under [`docs/plans/`](plans/README.md). Per-phase "Detailed plan" links point at the phase's plan below.

---

## Phase 1: <!-- title -->

**Goal:** <!-- One sentence. What validates-or-delivers by the end of this phase. -->

**Deliverables:**

- <!-- specific, checkable artifact -->
- <!-- specific, checkable artifact -->
- <!-- specific, checkable artifact -->

**Success criteria:**

- <!-- measurable outcome, not an aspiration -->
- <!-- measurable outcome -->

**Key decisions to validate:**

<!-- The forward-looking twin of ADRs. What hypotheses is this phase
     meant to test? If the answers come back "no", what invalidates
     the plan? Naming these up front makes the phase's purpose clear
     and gives future ADRs a place to reference.

     Optional per phase — delete if there are no open hypotheses. -->

- <!-- Hypothesis this phase validates -->
- <!-- Fallback if it doesn't -->

**Estimated effort:** <!-- N weeks -->

---

## Phase 2: <!-- title -->

**Detailed plan:** [`docs/plans/PHASE-2.md`](plans/PHASE-2.md). <!-- This ROADMAP entry is the terse summary; the plan owns the PR sequence, per-PR gates, success criteria, and follow-ups. -->

**Entry criteria** (must land before this phase begins):

<!-- Optional slot for phases with hard prerequisites. Delete if
     there are none. Prevents the "oh, that has to land first" surprise. -->

- <!-- ADR / PR / decision that gates this phase -->

**Goal:** <!-- -->

**Deliverables:**

- <!-- -->

**Success criteria:**

- <!-- -->

**Estimated effort:** <!-- -->

---

## Phase 3: <!-- title -->

<!-- repeat structure -->

---

## Future Phases (not yet scheduled)

<!-- The deferred-with-conditions pattern, applied at the delivery
     layer. Same discipline as SPEC.md §"Deferred", CONTRIBUTING.md
     §"Tier 4 / Deferred", and DESIGN.md "Future extensions".

     Each item sketches shape and names either a target phase or a
     trigger condition. Don't promise what you can't schedule. -->

### <!-- Name of future phase -->

<!-- 2-4 paragraphs on shape. Link to DESIGN.md for architectural
     rationale if it's covered there. Include any notable constraints
     or cross-phase dependencies. -->

### <!-- Name of future phase -->

<!-- -->

---

## Dependencies Summary

<!-- OPTIONAL — delete this section if you don't want to maintain it.

     If kept, caveat it: this is a snapshot, not a lockfile. Source
     of truth is the language-specific manifest (pyproject.toml,
     Cargo.toml, package.json, go.mod, etc.).

     Its value is as a reader's index: "what external dependencies
     does this project rely on, at a glance?" The manifest can answer
     the question authoritatively but takes more effort to scan. -->

### <!-- Component name -->

| Package | License | Purpose |
|---|---|---|
| <!-- name --> | <!-- license --> | <!-- what it does --> |

### <!-- External tools (optional) -->

| Tool | License | Purpose |
|---|---|---|
| <!-- name --> | <!-- license --> | <!-- how it's invoked; e.g. "external CLI only, no library linking" --> |

<!-- For a target directory layout of the repo, see STRUCTURE.md. -->
