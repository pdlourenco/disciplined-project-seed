# [PROJECT] — Target Project Structure

<!-- This document describes the intended directory layout of the repo.
     It is aspirational: the repo may not yet match it, and reality may
     diverge as the project evolves. Treat this as a roadmap for
     structure, not a snapshot of it.

     Why separate from ROADMAP.md: directory trees embedded in roadmaps
     drift fastest of anything in the documentation set (every new
     module changes them). Keeping the tree in its own file makes the
     drift visible and the update surface smaller.

     Update this file when the target shape changes, not when the
     current shape changes. The current shape is the repo itself. -->

## Layout

```
<!-- Adapt this tree to your project. Keep annotations short.

     Suggested top-level convention:

     - Source-level code lives in per-language / per-component folders
       (indexer/, cli/, web/, etc.) rather than in src/
     - docs/ holds all coordinated documentation (DESIGN, SPEC,
       ROADMAP, CONTRIBUTING, REVIEW_CONTEXT, STRUCTURE, plans/,
       decisions/)
     - .github/ holds CI workflows and PR/issue templates
     - scripts/ holds repo-level tooling (build scripts, release
       helpers, local CI harnesses) -->

[project]/
├── CLAUDE.md                      # agent operating rules
├── README.md                      # user-facing entry point
├── <config>.example.<ext>          # example configuration, generated from SPEC
│
├── .github/
│   ├── labels.yml                  # machine source for label catalogue
│   ├── workflows/                  # CI definitions
│   │   └── sync-labels.yml         # reconciles labels.yml → live repo
│   └── pull_request_template.md
│
├── docs/
│   ├── DESIGN.md
│   ├── SPEC.md
│   ├── ROADMAP.md
│   ├── CONTRIBUTING.md
│   ├── LABELS.md                   # issue + PR label taxonomy
│   ├── REVIEW_CONTEXT.md
│   ├── STRUCTURE.md                # this file
│   ├── decisions/
│   │   ├── README.md               # ADR convention + index
│   │   └── ADR-NNNN-*.md
│   ├── plans/
│   │   ├── README.md               # phase-plan index
│   │   └── PHASE-N.md
│   └── design/                     # optional: per-topic depth when
│       └── <topic>.md              # DESIGN.md outgrows ~300 lines
│
├── <component>/                    # e.g. indexer/, backend/, service/
│   ├── <manifest>                  # e.g. pyproject.toml, Cargo.toml
│   ├── src/
│   └── tests/
│
├── <component>/                    # e.g. cli/, frontend/
│   └── ...
│
└── scripts/                        # build / release / local tooling
```

## Conventions

<!-- Project-specific conventions that aren't captured elsewhere.
     Examples:

     - "All test fixtures live in tests/fixtures/ of their owning
       component, never at the repo root."
     - "Per-component READMEs are for component-level setup; root
       README is user-facing only."
     - "Files in reference-material/ are study material, never
       imported or copied wholesale." -->

- <!-- convention -->
- <!-- convention -->
