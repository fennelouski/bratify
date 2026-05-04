#!/usr/bin/env python3
"""Apply human-quality translations to brat/Localizable.xcstrings for in-scope locales.

Reads translation rows from bratify_locale_table (ROW_ORDER + ENTRIES).
Conservative merge for ar/es/fr: only overwrite when value still mirrors English,
except FORCE_FIX_KEYS which always receive correct values (e.g. format strings).
"""

from __future__ import annotations

import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "brat" / "Localizable.xcstrings"

TARGET_LOCALES = [
    "ar",
    "ca",
    "cs",
    "da",
    "de",
    "el",
    "en",
    "en-AU",
    "en-CA",
    "en-GB",
    "en-IN",
    "es",
    "es-419",
    "es-US",
    "fi",
    "fr",
    "fr-CA",
    "he",
    "hi",
    "hr",
]

# Always apply these (key, locale) — e.g. broken String(format:) templates.
FORCE_FIX_KEYS: set[tuple[str, str]] = {
    ("FontNameLabel", "ar"),
    ("FontNameLabel", "es"),
    ("FontNameLabel", "fr"),
    ("SelectedFontLabel", "ar"),
    ("SelectedFontLabel", "es"),
    ("SelectedFontLabel", "fr"),
}

CONSERVATIVE_LOCALES = frozenset({"ar", "es", "fr"})


def load_locale_table():
    spec = importlib.util.spec_from_file_location(
        "bratify_locale_table", Path(__file__).parent / "bratify_locale_table.py"
    )
    mod = importlib.util.module_from_spec(spec)
    assert spec.loader
    spec.loader.exec_module(mod)
    order: list[str] = list(mod.ROW_ORDER)
    entries: list[tuple[str, tuple[str, ...]]] = list(mod.ENTRIES)
    if len(order) != 20:
        raise SystemExit(f"ROW_ORDER must have 20 locales, got {len(order)}")
    for key, tup in entries:
        if len(tup) != 20:
            raise SystemExit(f"Key {key!r}: expected 20 values, got {len(tup)}")
    return order, entries


def should_apply(
    key: str,
    locale: str,
    old_value: str,
    en_value: str,
    new_value: str,
) -> bool:
    if (key, locale) in FORCE_FIX_KEYS:
        return old_value != new_value
    if locale in CONSERVATIVE_LOCALES:
        if old_value != en_value:
            return False
    return old_value != new_value


def main() -> int:
    row_order, entries = load_locale_table()
    if row_order != TARGET_LOCALES:
        print(
            "WARN: ROW_ORDER differs from TARGET_LOCALES; using ROW_ORDER from table",
            file=sys.stderr,
        )

    with open(CATALOG, encoding="utf-8") as f:
        catalog = json.load(f)

    original_strings = json.dumps(catalog["strings"], sort_keys=True)

    translations: dict[str, dict[str, str]] = {}
    for key, tup in entries:
        translations[key] = dict(zip(row_order, tup))

    stats: dict[str, int] = {loc: 0 for loc in row_order}
    touched_keys: set[str] = set()

    for key, loc_map in translations.items():
        if key not in catalog["strings"]:
            raise SystemExit(f"Unknown key in table: {key!r}")
        entry = catalog["strings"][key]
        locs = entry.setdefault("localizations", {})
        en_val = (locs.get("en") or {}).get("stringUnit", {}).get("value", key)

        for loc, new_val in loc_map.items():
            if loc not in row_order:
                raise SystemExit(f"Unknown locale in row for {key!r}: {loc!r}")
            unit = (locs.get(loc) or {}).get("stringUnit") or {}
            old_val = unit.get("value", "")
            if not should_apply(key, loc, old_val, en_val, new_val):
                continue
            if loc not in locs:
                locs[loc] = {"stringUnit": {"state": "translated", "value": new_val}}
            else:
                su = locs[loc].setdefault("stringUnit", {})
                su["state"] = "translated"
                su["value"] = new_val
            stats[loc] += 1
            touched_keys.add(key)

    with open(CATALOG, "w", encoding="utf-8") as f:
        json.dump(catalog, f, ensure_ascii=False, indent=2)
        f.write("\n")

    with open(CATALOG, encoding="utf-8") as f:
        catalog2 = json.load(f)

    if json.dumps(catalog2["strings"], sort_keys=True) != original_strings:
        # Keys/comments/locale keys must still exist; values may change.
        if set(catalog2["strings"]) != set(json.loads(original_strings)):
            print("ERROR: string keys changed", file=sys.stderr)
            return 1

    for key, o_entry in json.loads(original_strings).items():
        n_entry = catalog2["strings"][key]
        if o_entry.get("comment", "") != n_entry.get("comment", ""):
            print(f"ERROR: comment changed for {key!r}", file=sys.stderr)
            return 1
        o_locs = o_entry.get("localizations") or {}
        n_locs = n_entry.get("localizations") or {}
        if set(o_locs) != set(n_locs):
            print(f"ERROR: locales changed for {key!r}", file=sys.stderr)
            return 1
        for loc, o_unit in o_locs.items():
            n_unit = n_locs[loc]
            if o_unit.get("stringUnit", {}).get("state") != n_unit.get("stringUnit", {}).get(
                "state"
            ):
                print(f"ERROR: state changed for {key!r}/{loc}", file=sys.stderr)
                return 1

    total = sum(stats.values())
    print(f"Updated {total} stringUnit values across {len(touched_keys)} keys.")
    for loc in row_order:
        if stats[loc]:
            print(f"  {loc}: {stats[loc]}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
