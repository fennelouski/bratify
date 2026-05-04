#!/usr/bin/env python3
"""One-off: apply human-quality translations to brat/Localizable.xcstrings for target locales.

Target locales: hu, id, it, ko, ms, nb, nl, pl, pt-PT, ro, ru, sk, sl, sv, th, tr, uk, vi (full pass).
ja: only fixes Invert → 反転.
pt-BR: skipped (already localized).

Does not touch: BackgroundHelp, BrightnessHelp, LatchOrTouchHelp, TorchHelp, LoadingSettings
  (already translated in catalog).

Excludes all other knownRegions (ar, de, en-*, es, fr, zh-*, etc.).

Run from repo root: python3 scripts/translate_pass_v1.py
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "brat" / "Localizable.xcstrings"
LOCALE_JSON_DIR = Path(__file__).resolve().parent / "locale_patches"

HELP_KEYS = frozenset(
    {
        "BackgroundHelp",
        "BrightnessHelp",
        "LatchOrTouchHelp",
        "TorchHelp",
        "LoadingSettings",
    }
)

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

JA_INVERT_FIX = ("ja", "Invert", "反転")


def load_locale_tables() -> dict[str, dict[str, str]]:
    out: dict[str, dict[str, str]] = {}
    if not LOCALE_JSON_DIR.is_dir():
        raise FileNotFoundError(f"Missing {LOCALE_JSON_DIR}")
    for path in sorted(LOCALE_JSON_DIR.glob("*.json")):
        lang = path.stem
        if lang not in TARGET_FULL:
            raise ValueError(f"Unexpected locale file {path.name}")
        with open(path, encoding="utf-8") as f:
            table = json.load(f)
        if not isinstance(table, dict):
            raise TypeError(f"{path} must be a JSON object")
        out[lang] = {str(k): str(v) for k, v in table.items()}
    return out


def main() -> int:
    tables = load_locale_tables()
    missing = TARGET_FULL - set(tables.keys())
    if missing:
        print(f"Missing locale JSON files for: {', '.join(sorted(missing))}", file=sys.stderr)
        return 1

    with open(CATALOG, encoding="utf-8") as f:
        data = json.load(f)

    strings = data["strings"]

    def en_value(key: str) -> str:
        locs = strings[key].get("localizations") or {}
        u = (locs.get("en") or {}).get("stringUnit") or {}
        v = u.get("value")
        if v is not None:
            return v
        return key

    # ja: fix Invert only
    ja_entry = strings.get("Invert")
    if ja_entry is not None:
        locs = ja_entry.setdefault("localizations", {})
        locs["ja"] = {"stringUnit": {"state": "translated", "value": JA_INVERT_FIX[2]}}

    for key, entry in strings.items():
        if key == "" or key in HELP_KEYS:
            continue
        en_v = en_value(key)
        locs = entry.setdefault("localizations", {})

        for lang in TARGET_FULL:
            patch = tables[lang].get(key)
            if patch is None:
                print(f"warning: no patch for {lang!r} key {key!r}", file=sys.stderr)
                continue
            cur = (locs.get(lang) or {}).get("stringUnit", {}).get("value")
            if cur != en_v:
                continue
            locs[lang] = {"stringUnit": {"state": "translated", "value": patch}}

    with open(CATALOG, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")

    json.loads(CATALOG.read_text(encoding="utf-8"))
    print(f"Updated {CATALOG} (validated JSON).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
