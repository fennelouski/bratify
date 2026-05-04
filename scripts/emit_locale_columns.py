#!/usr/bin/env python3
"""Build scripts/locale_columns.json (14 locale columns × 164 keys) for bratify_locale_table."""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = Path(__file__).resolve().parent
OUT = SCRIPTS / "locale_columns.json"
SKIP = {"", ":", "ø", "zerØ"}

sys.path.insert(0, str(SCRIPTS))

from gen_locale_columns import _bg_value  # noqa: E402
from ui_parallel import (  # noqa: E402
    CA,
    CS,
    DA,
    DE,
    EL,
    ES_419,
    ES_US,
    FI,
    FR_CA,
    HE,
    HI,
    HR,
)


def key_list() -> list[str]:
    with open(ROOT / "brat" / "Localizable.xcstrings", encoding="utf-8") as f:
        data = json.load(f)
    return [k for k in sorted(data["strings"]) if k not in SKIP]


def non_bg_map(keys: list[str]) -> tuple[list[str], dict[str, int]]:
    non_bg = [k for k in keys if not (k.startswith("Background ") and k != "BackgroundHelp")]
    return non_bg, {k: i for i, k in enumerate(non_bg)}


def raw_en(cat: dict, k: str) -> str:
    return (
        (cat["strings"][k].get("localizations") or {})
        .get("en", {})
        .get("stringUnit", {})
        .get("value", k)
    )


def loc_val(cat: dict, k: str, loc: str) -> str:
    return (
        (cat["strings"][k].get("localizations") or {})
        .get(loc, {})
        .get("stringUnit", {})
        .get("value", "")
    )


PARALLEL_LOCALES = {
    "ca": CA,
    "cs": CS,
    "da": DA,
    "de": DE,
    "el": EL,
    "es-419": ES_419,
    "es-US": ES_US,
    "fi": FI,
    "fr-CA": FR_CA,
    "he": HE,
    "hi": HI,
    "hr": HR,
}


def main() -> int:
    keys = key_list()
    assert len(keys) == 164
    non_bg, ix = non_bg_map(keys)

    with open(ROOT / "brat" / "Localizable.xcstrings", encoding="utf-8") as f:
        cat = json.load(f)

    cols: dict[str, list[str]] = {}

    for loc, parallel in PARALLEL_LOCALES.items():
        col: list[str] = []
        for k in keys:
            bg = _bg_value(loc, k)
            if bg is not None:
                col.append(bg)
            else:
                col.append(parallel[ix[k]])
        cols[loc] = col

    # Spanish (Spain): keep existing good strings when they differ from English; else use Latin‑American template.
    es_col: list[str] = []
    for k in keys:
        bg = _bg_value("es", k)
        if bg is not None:
            es_col.append(bg)
            continue
        en0 = raw_en(cat, k)
        cur = loc_val(cat, k, "es")
        if cur != en0:
            es_col.append(cur)
        else:
            es_col.append(ES_419[ix[k]])
    cols["es"] = es_col

    # French (France): same merge rule with Canadian French template as fallback.
    fr_col: list[str] = []
    for k in keys:
        bg = _bg_value("fr", k)
        if bg is not None:
            fr_col.append(bg)
            continue
        en0 = raw_en(cat, k)
        cur = loc_val(cat, k, "fr")
        if cur != en0:
            fr_col.append(cur)
        else:
            fr_col.append(FR_CA[ix[k]])
    cols["fr"] = fr_col

    OUT.write_text(json.dumps(cols, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {OUT} ({len(cols)} locales × {len(keys)} keys)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
