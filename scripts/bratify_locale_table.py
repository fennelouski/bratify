"""Source data for translate_catalog: ROW_ORDER + ENTRIES (164 keys × 20 locales)."""

from __future__ import annotations

import json
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parent

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

_COLS: dict[str, list[str]] = json.loads((SCRIPTS / "locale_columns.json").read_text(encoding="utf-8"))
_AR: dict[str, str] = json.loads((SCRIPTS / "ar_column.json").read_text(encoding="utf-8"))
_EN_BASE: dict[str, str] = json.loads((SCRIPTS / "en_base.json").read_text(encoding="utf-8"))
_GB: dict[str, str] = json.loads((SCRIPTS / "gb_preserve.json").read_text(encoding="utf-8"))

# en-CA uses British spelling for colour-related strings; keeps US wording elsewhere (e.g. flashlight).
_COLOUR_KEYS = {
    "Background Color",
    "BackgroundHelp",
    "Color Picker",
    "color swatches: background",
    "color swatches: text",
    "Colorful and playful",
    "Dark Mode Colors",
    "Default Background Color",
    "Default Text Color",
    "Destructive Color",
    "Light Mode Colors",
    "Positive Color",
    "Shadow Color",
    "show color swatches",
    "Text Color",
    "Tint Color",
}


def _key_list() -> list[str]:
    with open(SCRIPTS.parent / "brat" / "Localizable.xcstrings", encoding="utf-8") as f:
        data = json.load(f)
    return [k for k in sorted(data["strings"]) if k not in SKIP]


def _variant_en_au_in_gb(k: str) -> str:
    return _GB.get(k, _EN_BASE[k])


def _variant_en_ca(k: str) -> str:
    if k in _COLOUR_KEYS:
        return _GB.get(k, _EN_BASE[k])
    return _EN_BASE[k]


def _entries() -> list[tuple[str, tuple[str, ...]]]:
    keys = _key_list()
    assert len(keys) == 164
    entries: list[tuple[str, tuple[str, ...]]] = []
    # ROW_ORDER indices: ar=0, es=11, fr=15
    _fmt_fix = (0, 11, 15)
    for i, k in enumerate(keys):
        tup = (
            _AR[k],
            _COLS["ca"][i],
            _COLS["cs"][i],
            _COLS["da"][i],
            _COLS["de"][i],
            _COLS["el"][i],
            _EN_BASE[k],
            _variant_en_au_in_gb(k),
            _variant_en_ca(k),
            _GB.get(k, _EN_BASE[k]),
            _variant_en_au_in_gb(k),
            _COLS["es"][i],
            _COLS["es-419"][i],
            _COLS["es-US"][i],
            _COLS["fi"][i],
            _COLS["fr"][i],
            _COLS["fr-CA"][i],
            _COLS["he"][i],
            _COLS["hi"][i],
            _COLS["hr"][i],
        )
        assert len(tup) == 20
        if k in ("FontNameLabel", "SelectedFontLabel"):
            lst = list(tup)
            for j in _fmt_fix:
                lst[j] = "%@"
            tup = tuple(lst)
        entries.append((k, tup))
    return entries


ENTRIES = _entries()
