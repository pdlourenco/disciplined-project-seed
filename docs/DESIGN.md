# [PROJECT] — Design Document

<!-- Optional tagline: a memorable phrase or mnemonic that anchors the
     project's identity. Delete if not useful. -->

<!-- Optional origin/etymology paragraph: where the name comes from, what
     it's a reference to. Small touch but makes readers engage. Delete
     if not useful. -->

---

> **Positioning.** This document is the *rationale* half of the DESIGN / SPEC pair. It answers "why is the project shaped this way?" — architecture choices, alternatives considered, trade-offs accepted. The *contract* half lives in [`SPEC.md`](SPEC.md): the on-disk formats, RPC shapes, and cross-boundary conventions that different implementations must agree on. If DESIGN drifts into contract details (field tables, wire formats), or SPEC drifts into rationale (prose arguments for why), both rot. When in doubt, link to the other rather than duplicate.
>
> If DESIGN.md grows past roughly 300 lines, consider applying the same split shape used for ROADMAP + plans/ — keep DESIGN.md as a slim shell linking to `docs/design/<topic>.md` files per topic. The slim DESIGN.md holds the load-bearing architectural principle, constraints, and a navigation index; the per-topic files hold module-level rationale.

## Overview

<!-- One paragraph: what [PROJECT] does, for whom, and the shape of the
     system at a high level. Aim for a paragraph a new contributor can
     read and form an accurate mental model from.

     Example shape (substitute your project):

         [PROJECT] does X for Y users. The architecture is: a [component A]
         (written in [language]) that [responsibility], a [component B]
         (written in [language]) that [responsibility], coordinated via
         [shared contract]. [Future component C] is planned to [replace /
         extend] [component A] without changing the [shared contract]. -->

## Architecture

<!-- Optional terminology callout, if your project has more than one
     orthogonal numbering scheme. Example:

     > **Terminology.** *Phase N* refers to delivery milestones defined
     > in ROADMAP.md. *Gen 1 / Gen 2* refers to the [subsystem]
     > technology transition — Gen 1 being [today's stack], Gen 2 being
     > [future stack]. Gen 2 uses named migration steps, not phase
     > numbers. -->

<!-- ASCII architecture diagram.

     The diagram should show process topology and shared artifacts, NOT
     internal module layout. One screenful is the target. If it's
     growing past that, you're probably mixing levels — split into two
     diagrams (system-level and module-level) rather than stuffing one. -->

```
┌──────────────────────────────────────────────────────────┐
│                                                          │
│  ┌─────────────┐         ┌──────────────────────────┐    │
│  │ [Component] │         │ [Component]              │    │
│  │             │         │                          │    │
│  └──────┬──────┘         └────────────┬─────────────┘    │
│         │                             │                  │
│         ▼                             ▼                  │
│  ┌─────────────────────────────────────────────────┐     │
│  │ [Shared contract: index / database / API / ...] │     │
│  └─────────────────────────────────────────────────┘     │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

### The key architectural principle

<!-- THE LOAD-BEARING SENTENCE of the whole document. The one
     architectural invariant that, if violated, breaks the project's
     shape. Every subsequent design decision should trace back to this.

     Examples of the shape:

     - "The interface between X and Y is the [on-disk artifact],
       not a function call."
     - "All [requests] are idempotent and stateless; no [service]
       holds session state."
     - "[Library] is embedded in every consumer; there is no central
       [service] that owns the data."

     If you can't write this sentence yet, the architecture isn't
     settled. -->

**<!-- One sentence. Bold. -->**

<!-- 2–4 paragraphs unpacking the principle: what it enables, what it
     costs, what it rules out. This is where you explain why the
     architecture has the shape shown in the diagram above. -->

### Why this split?

<!-- For each major boundary in the architecture (language,
     process, service, storage), justify the choice. Each choice
     should trade clearly against the cost of the boundary itself —
     boundaries aren't free.

     Example structure, one paragraph per boundary:

         **[Language A] for [Component A]** because [specific
         capability]. [Language B] would also work but [trade-off].

         **[Language B] for [Component B]** because [specific
         constraint, e.g. startup latency, deployment shape]. A
         [Language A] implementation would [specific cost].

         **Polyglot in general** because [the shared contract lives
         on-disk / over-the-wire] and therefore doesn't care about
         implementation language. -->

### Alternative architecture considered

<!-- The escape hatch. Not an ADR (no decision has been made) — this
     is a documented fallback with explicit revisit conditions.

     Example shape:

         An alternative considered and kept as a fallback: [describe
         the alternative in two sentences]. This would [eliminate cost
         X / simplify Y] at the cost of [specific downside]. If
         [trigger condition] proves insurmountable, this is the
         escape hatch.

     Delete this subsection if there's no meaningful alternative.
     Keep it if there is — future-you will want to find it. -->

---

## Constraints

<!-- Non-functional constraints that shaped the design. Each constraint
     should be specific enough that a new dependency or technology
     proposal can be checked against it.

     Common constraint categories:

     - Licensing (permissive only? GPL excluded? AGPL excluded?)
     - Platform support envelope (which OSes, which architectures)
     - Performance envelope (latency targets, memory ceilings)
     - Security / compliance (regulated data, air-gapped environments)
     - Distribution shape (single binary, containerized, OS package)

     If constraints are simple, inline them. If they're elaborate —
     especially licensing — use a table. -->

### <!-- Example: Licensing -->

<!-- Example table shape, adapt to your constraint category:

     | Dependency   | License      | Decision               |
     |--------------|--------------|------------------------|
     | [name]       | [license]    | Included / Excluded    |
     | [name]       | [license]    | Included / Excluded    | -->

---

## Shared contracts

<!-- List the surfaces that cross boundaries (language, process,
     module). For each, point at SPEC.md for the binding definition
     and describe the high-level shape here.

     The discipline: DON'T duplicate field tables. Link, don't copy.
     Tables drift faster than prose does, and two sources of truth
     are zero sources of truth. -->

### <!-- Example: shared index / database schema -->

The canonical definition of <!-- schema/format --> lives in [`SPEC.md`](SPEC.md) §<!-- N -->. <!-- High-level shape in one or two paragraphs: what kind of artifact it is, who writes it, who reads it, what the critical invariants are. Don't reproduce the field table. -->

### <!-- Example: CLI / RPC / HTTP contract -->

The JSON/protocol contract between <!-- producer --> and <!-- consumer --> is defined in [`SPEC.md`](SPEC.md) §<!-- N -->. <!-- High-level shape: what's stable, what's expected to evolve additively, what's deliberately unpinned. -->

---

## Module sections

<!-- One subsection per major module. Use a consistent internal
     structure across them so readers can scan. The shape below
     works for most projects:

     - Responsibility (one paragraph)
     - Key dependencies (table; name + license/version + purpose)
     - Interface (how other modules interact with it — link to SPEC
       if the interface is a binding contract)
     - Design-level notes (things that are architecturally
       interesting but not SPEC-worthy) -->

### Module: <!-- name -->

**Responsibility.** <!-- What this module does, in one paragraph. -->

**Key dependencies.**

| Dependency | License / Version | Purpose |
|---|---|---|
| <!-- name --> | <!-- MIT / 1.2.x --> | <!-- purpose --> |

**Interface.** <!-- How other modules call into or consume this one. Link to SPEC.md for binding details. -->

**Notes.** <!-- Design-level observations that don't belong in SPEC. -->

### Module: <!-- name -->

<!-- repeat -->

---

## Process architecture and coordination

<!-- OPTIONAL — delete this section if the system is a single process.

     If the system has more than one process, document the coordination
     model explicitly:

     - How do the processes find each other? (configuration, discovery,
       shared filesystem path, etc.)
     - How do they coordinate access to shared state? (lockfile,
       transaction, lease, kernel page cache, etc.)
     - What guarantees does the coordination model give us, and what
       does it explicitly not give us?
     - Under what conditions would a different coordination model be
       justified? (named as a non-goal with revisit criteria) -->

---

## Future extensions

<!-- The "parking lot with entry criteria" pattern — same discipline as
     CONTRIBUTING.md §"Tier 4 / Deferred" and SPEC.md §"Deferred", but
     applied at the architectural level.

     For each item: name the extension, sketch the shape, and either
     name the phase that will implement it or the trigger that would
     bring it into scope. Don't promise what you can't schedule. -->

### <!-- Example: a new client / frontend / surface -->

<!-- 2-4 sentences on shape and trigger. -->

### <!-- Example: a new indexing / storage backend -->

<!-- 2-4 sentences on shape and trigger. -->

---

## Cross-platform strategy

<!-- OPTIONAL — delete this section if single-platform.

     If cross-platform, the goal of this section is to make clear
     where platform variation lives and where it's absorbed:

     - What's already cross-platform (no per-OS code paths)
     - What needs per-platform handling (table is usually clearest:
       concern × platform)
     - Competitive landscape per platform (who's already in the space)
     - The project's differentiator per platform -->

---

## Installation and distribution

<!-- OPTIONAL — delete this section for library/service projects that
     don't ship as an end-user artifact.

     For distributable projects, describe:

     - What gets installed (binaries, config, scheduled tasks, etc.)
     - Installer / package format per platform
     - First-run experience (wizard, defaults, post-install tasks)
     - Uninstall semantics (what's removed, what's preserved) -->
