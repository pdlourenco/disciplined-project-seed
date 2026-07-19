# [PROJECT] — Specification (v0.1)

**Status:** <!-- Draft | Locked for Phase N | Frozen until vN -->. Changes require a version bump and a change-log entry.

**Purpose:** This document defines the **external contracts** between [PROJECT]'s modules — the surfaces that cross language, process, or module boundaries. It is intentionally lean: internal types, internal DDL, exit codes, and logging formats are deliberately **out of scope** and may evolve freely inside their owning module.

This spec exists so multiple agents can develop independent modules in parallel without silent drift.

Readers: [`DESIGN.md`](DESIGN.md) for rationale, [`ROADMAP.md`](ROADMAP.md) for phasing, this file for binding decisions.

<!-- Positioning note (paired with DESIGN.md): SPEC is contract; DESIGN
     is rationale. Do not include prose rationale here unless it's a
     brief "why this shape" footnote alongside a rule. For architectural
     justification, link to DESIGN.md. -->

---

## Verification (right-side mechanisms)

Every binding rule in this document names the mechanism that gates it. The convention:

- A **specific test file** (e.g. `tests/test_spec_consistency.py::test_path_storage_is_raw`) when an automated check exists.
- An **integration job** (e.g. the `contract-consistency` job in `.github/workflows/ci.yml`) when a CI tier covers it.
- **Manual inspection** (e.g. "manual review of the migration script on release PRs") when only human checking applies.
- **ADR-driven review** (e.g. `ADR-NNNN`) when only judgment can enforce — the rule survives because contributors read the ADR; reviewers flag deviations.

A rule with `*Verified by:* <!-- nothing -->` is visible debt; reviewers running in *verification mode* (see [`REVIEW_CONTEXT.md`](REVIEW_CONTEXT.md) §"Verification vs validation") should flag it as an uncovered rule. The shape applies to every binding-rule section below; the §3 Critical rules template demonstrates it.

<!-- OPTIONAL: stable IDs for binding rules. When this document grows past
     ~10-15 rules, or when ADRs / phase plans / code comments start
     referring back to specific rules often, adopt a SPEC-N.N.N numbering
     convention so references survive renames and reorderings. See
     ADR-0007 §Alternatives for the deferral reasoning. Skip for tight
     single-author SPECs. -->

### Traceability matrix (optional — regulated / V&V-heavy domains)

The per-rule `Verified by:` annotation above is the light form of the right side, and the right weight for most projects. Projects with **requirement-level** V&V obligations (regulated, safety, formal review) can upgrade to a full traceability matrix — adopter-proven, independently invented before this seed's `Verified by:` convention and convergent with it:

- **Stable requirement IDs** on every binding rule — `REQ-<area>-N` (e.g. `REQ-T-3` for tooling requirements, `REQ-C-7` for codegen). Prerequisite: the stable-ID convention in the comment above; the matrix is unusable over rules that renumber.
- **Stable test IDs** on the verifying artifacts — e.g. `TS-U-*` / `TS-I-*` / `TS-S-*` for unit / integration / system tests.
- **The matrix itself** — a table mapping each requirement ID to the test IDs that verify it. Every requirement row must be non-empty or carry the project's visible-debt marker (see `CONTRIBUTING.md` §"Known-bug lifecycle"). Keep the table machine-parseable (one requirement per row) so a CI gate can assert row-level coverage — the spec-prose parsing gate pattern from `CONTRIBUTING.md` §"CI strategy" §1.
- **Bug-register → test mapping** — each known-bug register entry names the test that will detect its regression once fixed; pairs with the known-bug lifecycle's common core (the fixing PR closes the tracking artifact).

Skip this section entirely unless the domain demands requirement-level traceability.

---

## 1. Filesystem layout <!-- or equivalent shared-artifact section -->

<!-- OPTIONAL — delete if the project has no shared on-disk artifacts.

     If it does, all modules must agree on the layout. State it once here. -->

```
<!-- Tree of the shared directory structure. Keep annotations short. -->
~/.[project]/
├── config.toml          # user-edited (see §2)
├── <artifact>/          # <owner> writes, <readers> read
└── ...
```

### Ownership table

| Artifact | Writer | Readers | Format |
|---|---|---|---|
| `<!-- config.toml -->` | <!-- User --> | <!-- list --> | <!-- TOML (§2) --> |
| `<!-- artifact -->` | <!-- owner --> | <!-- readers --> | <!-- format (§N) --> |

**Rule:** <!-- One-sentence invariant about who may write where; e.g.
"Only [module] writes to [artifact]; other modules open it read-only." -->

---

## 2. Configuration schema

<!-- OPTIONAL — delete if your project has no user-facing config.

     If it does: this section is authoritative. A `config.example.toml`
     in the repo root should be generated from (or kept in sync with)
     this section. Unknown keys should cause a warning, not fail loading
     — that's what makes the schema forward-compatible. -->

<!-- Organize sections by consumer. The discipline is: one section per
     consumer-side, plus a shared [general] section. Avoid sections
     that serve as dumping grounds. -->

| Section | Consumer |
|---|---|
| `[general]` | both / shared |
| `[<!-- section -->]` | <!-- module / implementation side --> |

```toml
[general]
# Expanded with ~ and environment variables at load time.
<!-- key --> = <!-- default -->      # type, default, validation

[<!-- section -->]
<!-- key --> = <!-- default -->      # type, default, validation
```

### Validation rules

<!-- Enumerate what a config loader must check and what happens on
     failure. "Load error" = fail loud and exit; "warning" = log and
     continue. The default bias: unknown keys are warnings (forward
     compatibility), invalid values for known keys are errors. -->

- Missing required keys → load error with the offending key path.
- Invalid enum values → load error listing allowed values.
- Unknown keys → warning, not error (forward compatibility).
- <!-- Per-key specific validation, e.g. "max_file_size_mb must be >= 1" -->

---

## 3. <!-- Data schema / index schema / database schema -->

<!-- If the project has a cross-implementation data schema (index,
     database, message format), this is the single most critical
     contract. Every implementation must agree byte-for-byte.

     If your project doesn't have one, delete this section. -->

### Version pinning

<!-- If two implementations share a dependency version (e.g. a shared
     library with its own wire format), pin them here and enforce via
     a test. Delete if not applicable. -->

| Component | Version |
|---|---|
| <!-- library on side A --> | <!-- pin --> |
| <!-- library on side B --> | <!-- pin --> |

### Fields

<!-- If the schema is complex enough to warrant its own file, make
     that file authoritative and keep only human-readable notes here:

         **Authoritative source: [`docs/schema.toml`](schema.toml).**
         Both [side A] and [side B] parse `schema.toml` at build time
         and construct their native schema object from it.

     Otherwise, inline the field table here. Either way, the rule is
     ONE source of truth. -->

| Field | Type | Stored | Notes |
|---|---|---|---|
| `<!-- name -->` | <!-- type --> | <!-- yes/no --> | <!-- critical note --> |

### Critical rules

<!-- THIS IS WHERE SPEC EARNS ITS KEEP. Enumerate the non-obvious
     invariants a future contributor might get wrong. Each rule
     should be the crystallization of a bug that would otherwise
     happen.

     Examples from other projects to show the shape:

     - "`path` is stored raw (keyword type), not tokenized. Tokenized
       paths break exact-match queries for any path with punctuation
       or path separators."
     - "`modified` is stored in UTC. Producers that use local time
       produce silently-wrong sort orders."
     - "IDs are minted as UUIDv5 over the canonical path, not an
       auto-increment integer. Integer IDs are not stable across
       rebuilds."

     Replace with your project's actual landmines. -->

- **<!-- Rule 1 -->**
  - *Verified by:* <!-- specific test, integration job, manual inspection, or ADR-driven review. See §Verification at the top. -->
- **<!-- Rule 2 -->**
  - *Verified by:* <!-- mechanism -->
- **<!-- Rule 3 -->**
  - *Verified by:* <!-- mechanism -->

---

## 4. <!-- RPC / CLI / HTTP output contract -->

<!-- If the project has a cross-implementation API surface (CLI output,
     HTTP responses, message envelope), define it here. -->

### Invocation

```
<!-- tombo search <query> [flags...] -->
```

### Output schema

```json
{
  "<!-- field -->": "<!-- value -->",
  "results": [
    {
      "<!-- field -->": "<!-- value -->"
    }
  ]
}
```

### Field rules

| Field | Type | Nullable | Notes |
|---|---|---|---|
| `<!-- query -->` | <!-- string --> | <!-- no --> | <!-- Echoes user input unmodified. --> |
| `<!-- results -->` | <!-- list --> | <!-- no --> | <!-- May be empty. --> |

### Known limitations

<!-- Document known, deliberate limitations of the current contract so
     consumers don't try to work around them. Examples:

     - "Pagination is not supported; use --limit."
     - "Faceted aggregation is not specified; deferred to v2."
     - "Snippet highlighting is hardcoded to <b>...</b>." -->

### Non-goals

<!-- Explicit non-goals for this version of the contract.
     Deliberately over-enumerate: ambiguity about what's not in
     scope is the main way scope creeps. -->

---

## 5. <!-- ID minting rule / canonical identifier convention -->

<!-- If the project uses stable IDs that cross boundaries (e.g., a
     document ID passed from indexer → search → opener), define the
     minting rule here.

     Delete if not applicable. -->

**Rule:** <!-- Describe the minting function. -->

Properties:

- **Deterministic:** <!-- same input → same ID --> .
- **Stable across <!-- operation -->:** <!-- re-running [operation] produces the same IDs -->.
- <!-- Any other invariants consumers rely on -->

**Do not** <!-- name common wrong choices and why they fail here -->.

---

## 6. Canonicalization rules

<!-- If any string value (path, URL, identifier) crosses boundaries,
     it must be canonicalized identically on every side. Pin the
     rules here.

     Delete if not applicable. -->

Rules (applied in order):

1. <!-- e.g. Expand `~` and environment variables. -->
2. <!-- e.g. Resolve to absolute form. -->
3. <!-- e.g. Normalize Unicode to NFC. -->
4. <!-- e.g. Replace separator variants with a canonical choice. -->

<!-- Be specific about edge cases: case sensitivity, trailing slashes,
     platform-specific prefixes. This is another place SPEC earns its
     keep. -->

---

## 7. Deferred to post-[VERSION] (explicitly out of this spec)

Documented here so no one confuses "unspecified" with "free to ignore".

<!-- The deferred-with-conditions pattern. Same discipline as
     CONTRIBUTING.md §"Tier 4 / Deferred" and DESIGN.md "Future
     extensions", applied at the contract layer.

     For each item: name it, describe its ownership today (if any),
     and name the phase or trigger that brings it into SPEC scope. -->

- **<!-- Internal DDL / schema of the state database -->** — Owned by <!-- module -->; may change freely within that module. Not a cross-module contract.
- **<!-- Exit codes and stderr format -->** — <!-- Phase N --> will formalize when <!-- consumer --> needs them.
- **<!-- Logging format -->** — <!-- description and owner; explicitly not a contract -->.
- **<!-- Contract for a future command / endpoint -->** — Added to this spec when <!-- trigger --> lands.

---

## Change log

<!-- Every contract-changing PR appends an entry. Keep entries terse;
     detailed rationale lives in the ADR or DESIGN that motivated the
     change. -->

- **v0.1 — Initial spec.** <!-- Coverage summary: which sections, what version of what. -->
- <!-- v0.2 — [Phase / trigger]. [Change summary, with ADR refs for
     non-obvious decisions.] -->
