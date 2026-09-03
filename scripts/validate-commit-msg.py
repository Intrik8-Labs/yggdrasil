#!/usr/bin/env python3
"""Validate commit messages against the Yggdrasil Conventional Commits policy."""

from __future__ import annotations

import re
import sys
from pathlib import Path

PATTERN = re.compile(
    r"^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)"
    r"(?:\([a-z0-9][a-z0-9._/-]*\))?"
    r"!?"
    r": [^\n]{1,100}$"
)

ALLOWED_SPECIAL_PREFIXES = (
    "Merge ",
    "Revert ",
    "fixup! ",
    "squash! ",
)


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: validate-commit-msg.py <commit-message-file>", file=sys.stderr)
        return 2

    message_file = Path(sys.argv[1])
    subject = message_file.read_text(encoding="utf-8").splitlines()[0].strip()

    if not subject:
        print("commit message subject cannot be empty", file=sys.stderr)
        return 1

    if subject.startswith(ALLOWED_SPECIAL_PREFIXES):
        return 0

    if PATTERN.fullmatch(subject):
        return 0

    print("Invalid commit message.", file=sys.stderr)
    print("Expected Conventional Commits format:", file=sys.stderr)
    print("  <type>(optional-scope): <description>", file=sys.stderr)
    print("Examples:", file=sys.stderr)
    print("  feat(mimir): add task creation use case", file=sys.stderr)
    print("  fix(tyr): enforce active tenant membership", file=sys.stderr)
    print("  docs: document weekly iteration process", file=sys.stderr)
    print("  refactor!: rename public contract namespace", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
