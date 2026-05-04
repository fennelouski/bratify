#!/usr/bin/env python3
"""One-off: apply human-quality translations to brat/Localizable.xcstrings for target locales.

Target locales (full pass from scripts/vals): be, bg, cy, eu, ga, gl, hy, hu, id, it, ka, kk, ko,
mk, mn, ms, nb, nl, pl, pt-PT, ro, ru, sk, sl, sq, sr, sr-Latn, sv, ta, te, th, tr, uk, uz, vi.
ja: only fixes Invert → 反転.
pt-BR: skipped (already localized).

Does not touch: BackgroundHelp, BrightnessHelp, LatchOrTouchHelp, TorchHelp, LoadingSettings
  (already translated in catalog).

Excludes all other knownRegions not listed in TARGET_FULL (ar, de, en-*, es, fr, zh-*, etc.).

Translations live in scripts/vals/{locale}.txt (one line per key, same order as scripts/keys_order.txt).

Run from repo root: python3 scripts/translate_pass_v1.py
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "brat" / "Localizable.xcstrings"
SCRIPT_DIR = Path(__file__).resolve().parent
KEYS_ORDER = SCRIPT_DIR / "keys_order.txt"
VALS_DIR = SCRIPT_DIR / "vals"

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
        "be",
        "bg",
        "cy",
        "eu",
        "ga",
        "gl",
        "hy",
        "hu",
        "id",
        "it",
        "ka",
        "kk",
        "ko",
        "mk",
        "mn",
        "ms",
        "nb",
        "nl",
        "pl",
        "pt-PT",
        "ro",
        "ru",
        "sk",
        "sl",
        "sq",
        "sr",
        "sr-Latn",
        "sv",
        "ta",
        "te",
        "th",
        "tr",
        "uk",
        "uz",
        "vi",
    }
)

JA_INVERT_FIX = ("ja", "Invert", "反転")

# Always overwrite these (e.g. refined after an initial pass when catalog no longer matches en).
FORCE_PATCHES: dict[tuple[str, str], str] = {
    ("pt-PT", "Last Modified"): "Modificado recentemente",
}


def load_locale_tables() -> dict[str, dict[str, str]]:
    if not KEYS_ORDER.is_file():
        raise FileNotFoundError(f"Missing {KEYS_ORDER}")
    if not VALS_DIR.is_dir():
        raise FileNotFoundError(f"Missing {VALS_DIR}")
    keys = KEYS_ORDER.read_text(encoding="utf-8").splitlines()
    out: dict[str, dict[str, str]] = {}
    for lang in sorted(TARGET_FULL):
        path = VALS_DIR / f"{lang}.txt"
        if not path.is_file():
            raise FileNotFoundError(f"Missing translations file {path}")
        lines = path.read_text(encoding="utf-8").splitlines()
        if len(lines) != len(keys):
            raise ValueError(
                f"{path.name}: expected {len(keys)} lines, got {len(lines)}"
            )
        out[lang] = dict(zip(keys, lines))
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

    for (lang, key), val in FORCE_PATCHES.items():
        entry = strings.get(key)
        if entry is None:
            continue
        locs = entry.setdefault("localizations", {})
        locs[lang] = {"stringUnit": {"state": "translated", "value": val}}

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
