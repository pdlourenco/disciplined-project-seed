#!/usr/bin/env python3
"""Static consistency check: every `required_status_checks.contexts`
entry in `.github/branch-protection.yml` must name a live job in
`.github/workflows/ci.yml` (subset check — extra CI jobs are fine).

Catches the failure mode where a CI job's `name:` is renamed (or the
job is removed) but `branch-protection.yml`'s contexts didn't update —
leaving the merge gate stuck pending forever (the gate references a
context name that no CI job produces) or quietly ungated after a
manual `Settings → Branches` fix.

Token-free; no network. Runs as a CI job on every PR / push so the
check is enforced at merge time. Complement to the runtime presence /
field-level-drift checks in `check-branch-protection.yml` — together
they cover the three drift modes (CI job renamed at edit time;
protection removed post-deploy; per-field config drift post-deploy).
See ADR-0005 §Consequences.
"""
from __future__ import annotations

import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[2]
BP_PATH = ROOT / ".github" / "branch-protection.yml"
CI_PATH = ROOT / ".github" / "workflows" / "ci.yml"


def load_yaml(path: Path) -> dict:
    with path.open() as f:
        return yaml.safe_load(f) or {}


def required_contexts(bp: dict) -> set[str]:
    rsc = bp.get("required_status_checks") or {}
    return set(rsc.get("contexts") or [])


def live_job_names(ci: dict) -> set[str]:
    """Return the set of names GitHub will report as status-check
    contexts. If a job has `name:`, that's the context; otherwise the
    job_id is used."""
    jobs = ci.get("jobs") or {}
    names: set[str] = set()
    for job_id, job in jobs.items():
        if isinstance(job, dict):
            names.add(job.get("name") or job_id)
    return names


def main() -> int:
    bp = load_yaml(BP_PATH)
    ci = load_yaml(CI_PATH)
    required = required_contexts(bp)
    live = live_job_names(ci)
    missing = required - live

    if missing:
        print(
            "FAIL: required contexts in branch-protection.yml have no\n"
            "      matching job name in ci.yml. Drift will leave the\n"
            "      merge gate stuck pending forever (no job produces\n"
            "      these context names).",
            file=sys.stderr,
        )
        print(file=sys.stderr)
        print("Missing contexts:", file=sys.stderr)
        for ctx in sorted(missing):
            print(f"  - {ctx!r}", file=sys.stderr)
        print(file=sys.stderr)
        print("Live job names (from ci.yml):", file=sys.stderr)
        for name in sorted(live):
            print(f"  - {name!r}", file=sys.stderr)
        return 1

    print(
        f"OK: all {len(required)} required contexts have matching job "
        f"names in ci.yml."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
