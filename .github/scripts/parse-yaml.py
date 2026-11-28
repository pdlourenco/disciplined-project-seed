#!/usr/bin/env python3
"""
Check that each YAML file given on the command line parses.

Used on forges/ (ADR-0024), whose sets follow other forges' syntaxes:
it checks only that the YAML is well formed, not what it means. Tags a
forge defines (GitLab's `!reference`, for example) are accepted without
being interpreted, so a valid file for any forge passes.

Exit codes: 0 if every file parses, 1 if any does not.
"""
from __future__ import annotations

import sys

import yaml


class _Loader(yaml.SafeLoader):
    """SafeLoader that accepts any `!tag` as plain data."""


def _any_tag(loader: yaml.SafeLoader, suffix: str, node: yaml.Node) -> object:
    if isinstance(node, yaml.ScalarNode):
        return loader.construct_scalar(node)
    if isinstance(node, yaml.SequenceNode):
        return loader.construct_sequence(node)
    return loader.construct_mapping(node)


_Loader.add_multi_constructor("!", _any_tag)


def main(paths: list[str]) -> int:
    failed = 0
    for path in paths:
        try:
            # Binary mode: PyYAML detects the encoding and reports a bad
            # byte as a YAMLError instead of a traceback.
            with open(path, "rb") as handle:
                for _ in yaml.load_all(handle, Loader=_Loader):  # noqa: S506 (SafeLoader subclass)
                    pass
        except (OSError, yaml.YAMLError) as err:
            print(f"{path}: {err}", file=sys.stderr)
            failed = 1
    return failed


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
