# Discipline adoption record

<!-- This file records this repository's adoption of the disciplined
     agentic coding practices from the disciplined-project-seed — named for
     the discipline being adopted, not for the seed artifact. Keep it at the
     repo root. Rationale and the file-vs-issue trade-off: the seed's
     meta ADR-0013.

     Issue-centric repos may keep this record in a pinned tracking issue
     instead (same content: provenance, per-artifact table, sync log). The
     committed file is the default — in-repo, diffable, and it survives a
     tracker migration. -->

## Provenance

- **Seed:** <https://github.com/pdlourenco/disciplined-project-seed>
- **Adopted at:** <!-- vX.Y.Z (sha) — pin both; flow-down reads the seed's meta/CHANGELOG.md between two pinned versions -->
- **Adoption date:** <!-- YYYY-MM-DD -->
- **Profile:** <!-- full spine | minimal | fork + catch-up sync | governance retrofit — per the seed README §"Adopting at small scale" -->

## Per-artifact adoption table

<!-- One row per seed artifact. Status is one of:
     adopted | adapted (say where/how) | dropped (say why, or link the ADR).
     Add rows for artifacts the seed grows later; delete none — a dropped
     row with a reason is the record working. -->

| Seed artifact | Status | Notes |
|---|---|---|
| `docs/SPEC.md` | <!-- status --> | <!-- e.g. "folded into DESIGN §Contracts — single implementation" --> |
| `docs/DESIGN.md` | <!-- status --> | |
| `docs/ROADMAP.md` | <!-- status --> | |
| `docs/CONTRIBUTING.md` | <!-- status --> | |
| `docs/REVIEW_CONTEXT.md` | <!-- status --> | |
| `docs/LABELS.md` + `.github/labels.yml` | <!-- status --> | |
| `.github/branch-protection.yml` + apply script | <!-- status --> | |
| `docs/plans/` | <!-- status --> | |
| `docs/decisions/` | <!-- status --> | |
| `docs/analyses/` | <!-- status --> | |
| `CLAUDE.md` | <!-- status --> | |
| CI workflow (`.github/workflows/ci.yml`) | <!-- status --> | |
| `DISCIPLINE_ADOPTION.md` (this file) | adopted | |

## Sync log (append-only)

<!-- One row per flow-down pass: diff the seed from your last recorded ref
     (or read its meta/CHANGELOG.md between the two versions), triage each
     entry against the table above, record what you took and skipped —
     skips with reasons are as valuable as takes. -->

| Date | Seed ref range | Taken | Skipped (reason) |
|---|---|---|---|
| <!-- YYYY-MM-DD --> | <!-- vA.B.C (sha)..vX.Y.Z (sha) --> | <!-- entries --> | <!-- entries + why --> |

## Backport log (optional)

<!-- Conventions this project invented, or convention failures it
     documented, proposed upstream to the seed. Delete the section if
     unused. -->

| Date | What | Upstream issue / PR |
|---|---|---|
| <!-- YYYY-MM-DD --> | <!-- one line --> | <!-- link --> |
