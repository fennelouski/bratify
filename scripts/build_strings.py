#!/usr/bin/env python3
"""Verify scripts/str/<locale>.txt has exactly 164 lines (matches KEY_LIST order)."""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
STR_DIR = Path(__file__).resolve().parent / "str"
SKIP = {"", ":", "ø", "zerØ"}


def key_list() -> list[str]:
    with open(ROOT / "brat" / "Localizable.xcstrings", encoding="utf-8") as f:
        data = json.load(f)
    return [k for k in sorted(data["strings"]) if k not in SKIP]


def main() -> int:
    keys = key_list()
    n = len(keys)
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <locale>")
        return 1
    loc = sys.argv[1]
    p = STR_DIR / f"{loc}.txt"
    if not p.exists():
        print(f"Missing {p}")
        return 1
    lines = p.read_text(encoding="utf-8").splitlines()
    if len(lines) != n:
        print(f"{loc}: expected {n} lines, got {len(lines)}")
        return 1
    print(f"{loc}: OK ({n} lines)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
