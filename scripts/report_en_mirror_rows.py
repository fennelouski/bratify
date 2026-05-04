#!/usr/bin/env python3
"""Read-only report: count non-en-family locales whose value still equals en for each key.

Usage (repo root):
  python3 scripts/report_en_mirror_rows.py
  python3 scripts/report_en_mirror_rows.py --locales-preset row-order-non-en
  python3 scripts/report_en_mirror_rows.py --locales hu,nl,pl
  python3 scripts/report_en_mirror_rows.py --csv

See brat/LOCALIZATION.md for translation pipelines; SKIP keys are not in emit_locale_columns.
"""

from __future__ import annotations

import argparse
import csv
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "brat" / "Localizable.xcstrings"

SKIP = {"", ":", "ø", "zerØ"}

ROW_ORDER = [
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

TARGET_FULL = frozenset(
    {
        "hu",
        "id",
        "it",
        "ko",
        "ms",
        "nb",
        "nl",
        "pl",
        "pt-PT",
        "ro",
        "ru",
        "sk",
        "sl",
        "sv",
        "th",
        "tr",
        "uk",
        "vi",
    }
)


def _en_family(loc: str) -> bool:
    return loc == "en" or loc.startswith("en-")


def _en_value(strings: dict, key: str) -> str:
    locs = strings[key].get("localizations") or {}
    u = (locs.get("en") or {}).get("stringUnit") or {}
    v = u.get("value")
    if v is not None:
        return v
    return key


def _mirror_count(
    strings: dict,
    key: str,
    en_val: str,
    locale_filter: frozenset[str] | None,
) -> int:
    locs = strings[key].get("localizations") or {}
    n = 0
    for loc, blob in locs.items():
        if _en_family(loc):
            continue
        if locale_filter is not None and loc not in locale_filter:
            continue
        val = (blob.get("stringUnit") or {}).get("value", "")
        if val == en_val:
            n += 1
    return n


def _resolve_locales(preset: str | None, explicit: str | None) -> frozenset[str] | None:
    if explicit:
        parts = [p.strip() for p in explicit.split(",") if p.strip()]
        return frozenset(parts)
    if not preset or preset == "all":
        return None
    if preset == "row-order-non-en":
        return frozenset(loc for loc in ROW_ORDER if not _en_family(loc))
    if preset == "target-full":
        return frozenset(TARGET_FULL)
    if preset == "table-and-pass":
        return frozenset(
            loc for loc in ROW_ORDER if not _en_family(loc)
        ) | frozenset(TARGET_FULL)
    raise SystemExit(f"Unknown --locales-preset: {preset!r}")


def _tier(key: str, en_val: str) -> str:
    if key in SKIP:
        return "skip_key"
    if en_val.strip() == "%@":
        return "format_only"
    if len(key) == 1 or key == ":":
        return "puzzle_token"
    return "bulk_ui"


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument(
        "--locales-preset",
        choices=("all", "row-order-non-en", "target-full", "table-and-pass"),
        default="all",
        help="Which non-en locales to count (default: all in each key).",
    )
    ap.add_argument(
        "--locales",
        metavar="LIST",
        help="Comma-separated locale ids (overrides --locales-preset).",
    )
    ap.add_argument("--csv", action="store_true", help="Write CSV rows to stdout.")
    ap.add_argument("--top", type=int, default=0, help="Only print first N bulk_ui rows (0 = all).")
    args = ap.parse_args()

    locale_filter = _resolve_locales(args.locales_preset, args.locales)

    with open(CATALOG, encoding="utf-8") as f:
        data = json.load(f)
    strings = data["strings"]

    rows: list[tuple[str, str, int, str]] = []
    for key in sorted(strings):
        en_val = _en_value(strings, key)
        cnt = _mirror_count(strings, key, en_val, locale_filter)
        tier = _tier(key, en_val)
        rows.append((tier, key, cnt, en_val))

    bulk = [(k, c, ev) for t, k, c, ev in rows if t == "bulk_ui" and c > 0]
    bulk.sort(key=lambda x: (-x[1], x[0]))

    if args.csv:
        w = csv.writer(sys.stdout)
        w.writerow(["tier", "key", "en_mirror_count", "en_value"])
        for tier, key, cnt, ev in rows:
            if cnt == 0:
                continue
            w.writerow([tier, key, cnt, ev])
        return 0

    label = (
        ",".join(sorted(locale_filter))
        if locale_filter
        else "all_non_en_family"
    )
    print(f"Locales counted: {label}\n")

    for section, title in (
        ("skip_key", "SKIP keys (not in emit_locale_columns / bratify table)"),
        ("puzzle_token", "Puzzle / single-letter keys (often intentionally identical)"),
        ("format_only", "Format-only en == %@ (translate only if product wants)"),
        ("bulk_ui", "Bulk UI (default priority)"),
    ):
        sec_rows = [(k, c, ev) for t, k, c, ev in rows if t == section and c > 0]
        sec_rows.sort(key=lambda x: (-x[1], x[0]))
        if not sec_rows:
            continue
        print(f"=== {title} ({len(sec_rows)} keys with ≥1 mirror) ===")
        for key, cnt, ev in sec_rows[: args.top or len(sec_rows)]:
            preview = ev.replace("\n", " ")[:72]
            if len(ev) > 72:
                preview += "…"
            print(f"  {cnt:2d}  {key!r}  en={preview!r}")
        if args.top and len(sec_rows) > args.top:
            print(f"  ... ({len(sec_rows) - args.top} more)")
        print()

    if not args.top:
        print(f"Bulk UI keys with mirrors: {len(bulk)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
