#!/usr/bin/env python3
"""Generate scripts/locale_columns.json (locale -> [164 strings] in KEY_LIST order).

Run from repo root: python3 scripts/gen_locale_columns.py
"""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = Path(__file__).resolve().parent / "locale_columns.json"

SKIP = {"", ":", "ø", "zerØ"}

KEY_LIST: list[str] = []


def _key_list() -> list[str]:
    with open(ROOT / "brat" / "Localizable.xcstrings", encoding="utf-8") as f:
        data = json.load(f)
    return [k for k in sorted(data["strings"]) if k not in SKIP]


# --- Background * (tail after "Background ") ---
BG = {
    "ca": {
        "Alpha": "Alfa del fons",
        "Blur": "Desenfocament del fons",
        "Brightness": "Lluminositat del fons",
        "Color": "Color del fons",
        "Contrast": "Contrast del fons",
        "Exposure": "Exposició del fons",
        "Flip Horizontal": "Volta el fons horitzontalment",
        "Flip Vertical": "Volta el fons verticalment",
        "Gamma": "Gamma del fons",
        "Image": "Imatge de fons",
        "Image Controls": "Controls de la imatge de fons",
        "Invert": "Inverteix el fons",
        "Monochrome": "Fons monocrom",
        "Pixelate": "Pixel·la el fons",
        "Saturation": "Saturació del fons",
        "Scale": "Escala del fons",
        "Sepia": "Sèpia del fons",
        "Sharpen": "Enfoca el fons",
        "Vignette": "Vineta del fons",
    },
    "cs": {
        "Alpha": "Průhlednost pozadí",
        "Blur": "Rozostření pozadí",
        "Brightness": "Jas pozadí",
        "Color": "Barva pozadí",
        "Contrast": "Kontrast pozadí",
        "Exposure": "Expozice pozadí",
        "Flip Horizontal": "Překlopit pozadí vodorovně",
        "Flip Vertical": "Překlopit pozadí svisle",
        "Gamma": "Gamma pozadí",
        "Image": "Obrázek na pozadí",
        "Image Controls": "Ovládání obrázku pozadí",
        "Invert": "Invertovat pozadí",
        "Monochrome": "Černobílé pozadí",
        "Pixelate": "Pixelovat pozadí",
        "Saturation": "Sytost pozadí",
        "Scale": "Měřítko pozadí",
        "Sepia": "Sépie pozadí",
        "Sharpen": "Ostrost pozadí",
        "Vignette": "Vinetace pozadí",
    },
    "da": {
        "Alpha": "Baggrunds-alfa",
        "Blur": "Baggrunds-sløring",
        "Brightness": "Baggrunds-lysstyrke",
        "Color": "Baggrundsfarve",
        "Contrast": "Baggrunds-kontrast",
        "Exposure": "Baggrunds-eksponering",
        "Flip Horizontal": "Vend baggrund vandret",
        "Flip Vertical": "Vend baggrund lodret",
        "Gamma": "Baggrunds-gamma",
        "Image": "Baggrundsbillede",
        "Image Controls": "Kontroller til baggrundsbillede",
        "Invert": "Invertér baggrund",
        "Monochrome": "Baggrund monokrom",
        "Pixelate": "Pixelér baggrund",
        "Saturation": "Baggrunds-mætning",
        "Scale": "Baggrunds-skala",
        "Sepia": "Baggrund sepia",
        "Sharpen": "Skærp baggrund",
        "Vignette": "Baggrunds-vignet",
    },
    "de": {
        "Alpha": "Hintergrund-Alpha",
        "Blur": "Hintergrundunschärfe",
        "Brightness": "Hintergrundhelligkeit",
        "Color": "Hintergrundfarbe",
        "Contrast": "Hintergrundkontrast",
        "Exposure": "Hintergrundbelichtung",
        "Flip Horizontal": "Hintergrund horizontal spiegeln",
        "Flip Vertical": "Hintergrund vertikal spiegeln",
        "Gamma": "Hintergrund-Gamma",
        "Image": "Hintergrundbild",
        "Image Controls": "Hintergrundbild-Steuerung",
        "Invert": "Hintergrund invertieren",
        "Monochrome": "Hintergrund monochrom",
        "Pixelate": "Hintergrund pixeln",
        "Saturation": "Hintergrund-Sättigung",
        "Scale": "Hintergrund skalieren",
        "Sepia": "Hintergrund-Sepia",
        "Sharpen": "Hintergrund schärfen",
        "Vignette": "Hintergrund-Vignette",
    },
    "el": {
        "Alpha": "Διαφάνεια φόντου",
        "Blur": "Θόλωμα φόντου",
        "Brightness": "Φωτεινότητα φόντου",
        "Color": "Χρώμα φόντου",
        "Contrast": "Αντίθεση φόντου",
        "Exposure": "Έκθεση φόντου",
        "Flip Horizontal": "Οριζόντια αναστροφή φόντου",
        "Flip Vertical": "Κατακόρυφη αναστροφή φόντου",
        "Gamma": "Γάμμα φόντου",
        "Image": "Εικόνα φόντου",
        "Image Controls": "Χειριστήρια εικόνας φόντου",
        "Invert": "Αντιστροφή φόντου",
        "Monochrome": "Μονόχρωμο φόντο",
        "Pixelate": "Εικονοστοιχεία φόντου",
        "Saturation": "Κορεσμός φόντου",
        "Scale": "Κλίμακα φόντου",
        "Sepia": "Σέπια φόντου",
        "Sharpen": "Όξυνση φόντου",
        "Vignette": "Βινιετάρισμα φόντου",
    },
    "es": {
        "Alpha": "Alfa del fondo",
        "Blur": "Desenfoque del fondo",
        "Brightness": "Brillo del fondo",
        "Color": "Color del fondo",
        "Contrast": "Contraste del fondo",
        "Exposure": "Exposición del fondo",
        "Flip Horizontal": "Voltear fondo horizontalmente",
        "Flip Vertical": "Voltear fondo verticalmente",
        "Gamma": "Gamma del fondo",
        "Image": "Imagen de fondo",
        "Image Controls": "Controles de imagen de fondo",
        "Invert": "Invertir fondo",
        "Monochrome": "Fondo monocromo",
        "Pixelate": "Pixelar fondo",
        "Saturation": "Saturación del fondo",
        "Scale": "Escala del fondo",
        "Sepia": "Sepia del fondo",
        "Sharpen": "Enfocar fondo",
        "Vignette": "Viñeta del fondo",
    },
    "es-419": {
        "Alpha": "Alfa del fondo",
        "Blur": "Desenfoque del fondo",
        "Brightness": "Brillo del fondo",
        "Color": "Color del fondo",
        "Contrast": "Contraste del fondo",
        "Exposure": "Exposición del fondo",
        "Flip Horizontal": "Voltear fondo horizontalmente",
        "Flip Vertical": "Voltear fondo verticalmente",
        "Gamma": "Gamma del fondo",
        "Image": "Imagen de fondo",
        "Image Controls": "Controles de la imagen de fondo",
        "Invert": "Invertir fondo",
        "Monochrome": "Fondo monocromático",
        "Pixelate": "Pixelar fondo",
        "Saturation": "Saturación del fondo",
        "Scale": "Escala del fondo",
        "Sepia": "Sepia del fondo",
        "Sharpen": "Enfocar fondo",
        "Vignette": "Viñeta del fondo",
    },
    "es-US": {
        "Alpha": "Background alpha",
        "Blur": "Background blur",
        "Brightness": "Background brightness",
        "Color": "Background color",
        "Contrast": "Background contrast",
        "Exposure": "Background exposure",
        "Flip Horizontal": "Flip background horizontally",
        "Flip Vertical": "Flip background vertically",
        "Gamma": "Background gamma",
        "Image": "Background image",
        "Image Controls": "Background image controls",
        "Invert": "Invert background",
        "Monochrome": "Background monochrome",
        "Pixelate": "Pixelate background",
        "Saturation": "Background saturation",
        "Scale": "Background scale",
        "Sepia": "Background sepia",
        "Sharpen": "Sharpen background",
        "Vignette": "Background vignette",
    },
    "fi": {
        "Alpha": "Taustan peittävyys",
        "Blur": "Taustan sumennus",
        "Brightness": "Taustan kirkkaus",
        "Color": "Taustaväri",
        "Contrast": "Taustan kontrasti",
        "Exposure": "Taustan valotus",
        "Flip Horizontal": "Käännä tausta vaakasuunnassa",
        "Flip Vertical": "Käännä tausta pystysuunnassa",
        "Gamma": "Taustan gamma",
        "Image": "Taustakuva",
        "Image Controls": "Taustakuvan säätimet",
        "Invert": "Käänteinen tausta",
        "Monochrome": "Tausta yksivärisenä",
        "Pixelate": "Pikselöi tausta",
        "Saturation": "Taustan kylläisyys",
        "Scale": "Taustan skaalaus",
        "Sepia": "Taustan seepia",
        "Sharpen": "Terävöitä taustaa",
        "Vignette": "Taustan vinjetointi",
    },
    "fr": {
        "Alpha": "Alpha de l’arrière-plan",
        "Blur": "Flou d’arrière-plan",
        "Brightness": "Luminosité de l’arrière-plan",
        "Color": "Couleur d’arrière-plan",
        "Contrast": "Contraste de l’arrière-plan",
        "Exposure": "Exposition de l’arrière-plan",
        "Flip Horizontal": "Retourner l’arrière-plan horizontalement",
        "Flip Vertical": "Retourner l’arrière-plan verticalement",
        "Gamma": "Gamma de l’arrière-plan",
        "Image": "Image d’arrière-plan",
        "Image Controls": "Réglages de l’image d’arrière-plan",
        "Invert": "Inverser l’arrière-plan",
        "Monochrome": "Arrière-plan monochrome",
        "Pixelate": "Pixeliser l’arrière-plan",
        "Saturation": "Saturation de l’arrière-plan",
        "Scale": "Échelle de l’arrière-plan",
        "Sepia": "Sépia de l’arrière-plan",
        "Sharpen": "Renforcer la netteté de l’arrière-plan",
        "Vignette": "Vignettage de l’arrière-plan",
    },
    "fr-CA": {
        "Alpha": "Alpha de l’arrière-plan",
        "Blur": "Flou d’arrière-plan",
        "Brightness": "Luminosité de l’arrière-plan",
        "Color": "Couleur d’arrière-plan",
        "Contrast": "Contraste de l’arrière-plan",
        "Exposure": "Exposition de l’arrière-plan",
        "Flip Horizontal": "Retourner l’arrière-plan horizontalement",
        "Flip Vertical": "Retourner l’arrière-plan verticalement",
        "Gamma": "Gamma de l’arrière-plan",
        "Image": "Image d’arrière-plan",
        "Image Controls": "Contrôles de l’image d’arrière-plan",
        "Invert": "Inverser l’arrière-plan",
        "Monochrome": "Arrière-plan monochrome",
        "Pixelate": "Pixelliser l’arrière-plan",
        "Saturation": "Saturation de l’arrière-plan",
        "Scale": "Échelle de l’arrière-plan",
        "Sepia": "Sépia de l’arrière-plan",
        "Sharpen": "Accentuer la netteté de l’arrière-plan",
        "Vignette": "Vignetage de l’arrière-plan",
    },
    "he": {
        "Alpha": "אלפא רקע",
        "Blur": "טשטוש רקע",
        "Brightness": "בהירות רקע",
        "Color": "צבע רקע",
        "Contrast": "ניגודיות רקע",
        "Exposure": "חשיפת רקע",
        "Flip Horizontal": "הפוך רקע אופקית",
        "Flip Vertical": "הפוך רקע אנכית",
        "Gamma": "גמא רקע",
        "Image": "תמונת רקע",
        "Image Controls": "בקרות תמונת רקע",
        "Invert": "הפוך רקע",
        "Monochrome": "רקע חד־צבעי",
        "Pixelate": "פיקסול רקע",
        "Saturation": "רוויית רקע",
        "Scale": "קנה מידה של רקע",
        "Sepia": "ספיה לרקע",
        "Sharpen": "חידוד רקע",
        "Vignette": "הצללה מעגלית לרקע",
    },
    "hi": {
        "Alpha": "पृष्ठभूमि अल्फा",
        "Blur": "पृष्ठभूमि धुंधलापन",
        "Brightness": "पृष्ठभूमि चमक",
        "Color": "पृष्ठभूमि रंग",
        "Contrast": "पृष्ठभूमि कंट्रास्ट",
        "Exposure": "पृष्ठभूमि एक्सपोज़र",
        "Flip Horizontal": "पृष्ठभूमि क्षैतिज पलटें",
        "Flip Vertical": "पृष्ठभूमि ऊर्ध्वाधर पलटें",
        "Gamma": "पृष्ठभूमि गामा",
        "Image": "पृष्ठभूमि छवि",
        "Image Controls": "पृष्ठभूमि छवि नियंत्रण",
        "Invert": "पृष्ठभूमि उलटें",
        "Monochrome": "पृष्ठभूमि एकरंगी",
        "Pixelate": "पृष्ठभूमि पिक्सेलेट करें",
        "Saturation": "पृष्ठभूमि संतृप्ति",
        "Scale": "पृष्ठभूमि स्केल",
        "Sepia": "पृष्ठभूमि सीपिया",
        "Sharpen": "पृष्ठभूमि शार्पन",
        "Vignette": "पृष्ठभूमि विग्नेट",
    },
    "hr": {
        "Alpha": "Alfa pozadine",
        "Blur": "Zamućenje pozadine",
        "Brightness": "Svjetlina pozadine",
        "Color": "Boja pozadine",
        "Contrast": "Kontrast pozadine",
        "Exposure": "Ekspozicija pozadine",
        "Flip Horizontal": "Okreni pozadinu vodoravno",
        "Flip Vertical": "Okreni pozadinu okomito",
        "Gamma": "Gama pozadine",
        "Image": "Slika pozadine",
        "Image Controls": "Kontrole slike pozadine",
        "Invert": "Invertiraj pozadinu",
        "Monochrome": "Pozadina u jednoj boji",
        "Pixelate": "Pikseliziraj pozadinu",
        "Saturation": "Zasićenje pozadine",
        "Scale": "Mjerilo pozadine",
        "Sepia": "Sepija pozadine",
        "Sharpen": "Izoštri pozadinu",
        "Vignette": "Vinjeta pozadine",
    },
}


def _bg_value(loc: str, key: str) -> str | None:
    if not key.startswith("Background ") or key == "BackgroundHelp":
        return None
    tail = key.removeprefix("Background ")
    m = BG.get(loc, {})
    return m.get(tail)


# --- Per-locale full overrides (key -> str); missing keys filled from EN later in bratify_locale_table ---


def main() -> None:
    global KEY_LIST
    KEY_LIST = _key_list()
    assert len(KEY_LIST) == 164

    locales = [
        "ca",
        "cs",
        "da",
        "de",
        "el",
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

    cols: dict[str, list[str]] = {loc: [] for loc in locales}

    # Placeholder: will be filled in next patch with full UI/theme/digit strings.
    with open(ROOT / "brat" / "Localizable.xcstrings", encoding="utf-8") as f:
        catalog = json.load(f)

    for key in KEY_LIST:
        en = (
            (catalog["strings"][key].get("localizations") or {})
            .get("en", {})
            .get("stringUnit", {})
            .get("value", key)
        )
        # en fixes
        if key == "LastHour":
            en = "Last hour"
        elif key == "Last7Days":
            en = "Last 7 days"
        elif key == "Last30Days":
            en = "Last 30 days"
        elif key == "OlderThan30Days":
            en = "Older than 30 days"
        elif key in ("FontNameLabel", "SelectedFontLabel"):
            en = "%@"

        for loc in locales:
            v = _bg_value(loc, key)
            cols[loc].append(v if v is not None else en)

    OUT.write_text(json.dumps(cols, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {OUT} ({len(KEY_LIST)} keys × {len(locales)} locales, partial)")


if __name__ == "__main__":
    main()
