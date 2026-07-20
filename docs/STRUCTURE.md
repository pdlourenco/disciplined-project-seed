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
├── CHANGELOG.md                    # adopter project changelog (Keep a Changelog format)
├── DISCIPLINE_ADOPTION.md          # seed provenance + per-artifact adoption table + sync log
├── <config>.example.<ext>          # example configuration, generated from SPEC
│
├── .claude/                        # Claude Code config (optional, adopter-tunable)
│   ├── settings.json               # registers the SessionStart hook
│   └── hooks/
│       └── session-start.sh        # provisions doc-CI toolchain in web sessions
│
├── .github/
│   ├── ISSUE_TEMPLATE/             # issue forms with pre-applied labels
│   │   ├── bug.yml
│   │   └── decision-proposal.yml
│   ├── branch-protection.yml       # main's branch protection, classic schema
│   ├── labels.yml                  # machine source for label catalogue
│   ├── scripts/
│   │   ├── audit-placeholders.py   # tier-3 audit (see CONTRIBUTING.md)
│   │   └── release_changelog.py    # release.yml gate: tag ↔ CHANGELOG
│   ├── workflows/                  # CI definitions
│   │   ├── check-branch-protection.yml  # weekly drift check (read-only)
│   │   ├── ci.yml                  # active baseline + four-tier framing
│   │   ├── release.yml             # tag-push release + CHANGELOG gate (ADR-0015)
│   │   └── sync-labels.yml         # reconciles labels.yml → live repo
│   └── pull_request_template.md
│
├── scripts/                        # human-triggered repo-level scripts
│   ├── local-ci.sh                 # runs the doc-CI suite locally (pre-push)
│   ├── normalize-branch-protection.jq  # shared filter (script + workflow)
│   └── setup-branch-protection.sh  # apply branch-protection.yml → live
│
├── docs/                           # adopter-facing documentation
│   ├── DESIGN.md
│   ├── SPEC.md
│   ├── ROADMAP.md
│   ├── CONTRIBUTING.md
│   ├── LABELS.md                   # issue + PR label taxonomy
│   ├── REVIEW_CONTEXT.md
│   ├── RISKS.md                    # OPTIONAL — regulated / life-safety / hard-reliability only
│   ├── STRUCTURE.md                # this file
│   ├── analyses/                   # OPTIONAL — dated, immutable analysis snapshots
│   │   └── README.md               # the four-rule convention
│   ├── decisions/                  # adopter ADRs (your project's decisions)
│   │   ├── README.md               # ADR conventions + index
│   │   └── ADR-NNNN-*.md
│   ├── plans/
│   │   ├── README.md               # phase-plan index
│   │   └── PHASE-N.md
│   └── design/                     # optional: per-topic depth when
│       └── <topic>.md              # DESIGN.md outgrows ~300 lines
│
├── meta/                           # seed-meta — the seed's own history; strip on
│   ├── README.md                   # adoption OR keep as design reference
│   ├── CHANGELOG.md                # seed evolution log (Keep a Changelog format)
│   └── decisions/                  # seed-meta ADRs (separate numbering from docs/)
│       ├── README.md               # seed-meta ADR index
│       └── ADR-NNNN-*.md
│
├── <component>/                    # e.g. indexer/, backend/, service/
│   ├── <manifest>                  # e.g. pyproject.toml, Cargo.toml
│   ├── src/
│   └── tests/
│
└── <component>/                    # e.g. cli/, frontend/
    └── ...
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
