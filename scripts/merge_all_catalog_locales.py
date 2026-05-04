#!/usr/bin/env python3
"""Merge git history catalog (many locales) with current Localizable.xcstrings; fill gaps with English."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "brat" / "Localizable.xcstrings"
OLD_REV = "b6ac552:brat/Localizable.xcstrings"


def load_old() -> dict | None:
    try:
        raw = subprocess.check_output(
            ["git", "show", OLD_REV],
            cwd=ROOT,
            stderr=subprocess.DEVNULL,
        )
        return json.loads(raw)
    except (subprocess.CalledProcessError, json.JSONDecodeError):
        return None


def en_value(*entries: dict, key: str = "") -> str:
    for e in entries:
        if not e:
            continue
        locs = e.get("localizations") or {}
        u = (locs.get("en") or {}).get("stringUnit") or {}
        v = u.get("value")
        if v is not None and v != "":
            return v
    return key


def merge() -> int:
    with open(CATALOG, encoding="utf-8") as f:
        current = json.load(f)

    old = load_old()
    if not old:
        print("No historical catalog; aborting (need git history with pre-prune strings).", file=sys.stderr)
        return 1

    all_locales: set[str] = set()
    for e in current["strings"].values():
        all_locales.update((e.get("localizations") or {}).keys())
    for e in old["strings"].values():
        all_locales.update((e.get("localizations") or {}).keys())
    all_locales = sorted(all_locales)

    old_strings = old["strings"]
    new_strings = current["strings"]

    for key, cur_entry in new_strings.items():
        if key == "":
            continue
        old_entry = old_strings.get(key, {})
        en_v = en_value(cur_entry, old_entry, key=key)
        out_locs: dict = {}
        for lang in all_locales:
            for src in (cur_entry, old_entry):
                if not src:
                    continue
                locs = src.get("localizations") or {}
                if lang in locs and "stringUnit" in locs[lang]:
                    out_locs[lang] = locs[lang]
                    break
            else:
                out_locs[lang] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": en_v,
                    }
                }
        cur_entry["localizations"] = out_locs

    with open(CATALOG, "w", encoding="utf-8") as f:
        json.dump(current, f, ensure_ascii=False, indent=2)
        f.write("\n")
    print(f"Wrote {CATALOG} with {len(all_locales)} locales: {', '.join(all_locales)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(merge())
