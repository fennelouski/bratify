#!/usr/bin/env python3
"""Add new locale columns to brat/Localizable.xcstrings by copying `en` stringUnit values.

Usage (from repo root):
  python3 scripts/add_catalog_locale_columns.py af bn et

Does not remove or rename existing locales. Skips string keys that have no `localizations`
object (e.g. comment-only entries).

See also: merge_all_catalog_locales.py (git merge). Avoid running update_localizable_catalog.py
as-is — it prunes the catalog to a small SHIPPED set and will delete other locales.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "brat" / "Localizable.xcstrings"


def en_value(entry: dict, key: str) -> str:
    locs = entry.get("localizations") or {}
    u = (locs.get("en") or {}).get("stringUnit") or {}
    v = u.get("value")
    if v is not None and v != "":
        return v
    return key


def add_locales(new_locales: list[str]) -> int:
    new_locales = list(dict.fromkeys(new_locales))  # dedupe, preserve order
    if not new_locales:
        print("No locale ids provided.", file=sys.stderr)
        return 1

    with open(CATALOG, encoding="utf-8") as f:
        data = json.load(f)

    strings = data["strings"]
    keys_touched = 0
    units_added = 0

    for key, entry in strings.items():
        if not entry or "localizations" not in entry:
            continue
        locs = entry.get("localizations")
        if not locs:
            continue
        fill = en_value(entry, key)
        changed = False
        for loc in new_locales:
            if loc in locs:
                continue
            locs[loc] = {
                "stringUnit": {
                    "state": "translated",
                    "value": fill,
                }
            }
            units_added += 1
            changed = True
        if changed:
            keys_touched += 1

    with open(CATALOG, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")

    print(
        f"Updated {CATALOG}: {keys_touched} keys, {units_added} new stringUnits "
        f"({', '.join(new_locales)})"
    )
    return 0


def main() -> int:
    args = [a.strip() for a in sys.argv[1:] if a.strip()]
    if not args:
        print(
            "Usage: add_catalog_locale_columns.py <locale> [locale ...]",
            file=sys.stderr,
        )
        return 1
    return add_locales(args)


if __name__ == "__main__":
    raise SystemExit(main())
