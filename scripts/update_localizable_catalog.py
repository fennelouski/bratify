#!/usr/bin/env python3
"""One-off maintenance script for Localizable.xcstrings — run from repo root if needed.

Warning: this script prunes `localizations` to `SHIPPED` only and will delete every other
locale column. Do not run it against the full shipped String Catalog unless you update
`SHIPPED` to match project `knownRegions` or remove `prune_localizations`. Prefer
`scripts/add_catalog_locale_columns.py` to add new locale columns without pruning.
"""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "brat" / "Localizable.xcstrings"

SHIPPED = frozenset({"en", "ar", "fr", "ja", "pt-BR", "en-GB"})


def su(value: str) -> dict:
    return {"stringUnit": {"state": "translated", "value": value}}


def prune_localizations(loc: dict | None) -> dict | None:
    if not loc:
        return None
    return {k: v for k, v in loc.items() if k in SHIPPED}


def main() -> None:
    with open(PATH, encoding="utf-8") as f:
        data = json.load(f)

    strings = data["strings"]

    # Remove duplicate lowercase cancel key (code uses "Cancel" only)
    if "cancel" in strings:
        del strings["cancel"]

    # Merge tables for specific keys (full shipped locales)
    MERGE = {
        "background_image_load_failed": {
            "en": "couldn't load background image",
            "en-GB": "couldn't load background image",
            "ar": "تعذّر تحميل صورة الخلفية",
            "fr": "impossible de charger l’image d’arrière-plan",
            "ja": "背景画像を読み込めませんでした",
            "pt-BR": "não foi possível carregar a imagem de fundo",
        },
        "failed_to_save_design": {
            "en": "couldn't save design",
            "en-GB": "couldn't save design",
            "ar": "تعذّر حفظ التصميم",
            "fr": "impossible d’enregistrer la création",
            "ja": "デザインを保存できませんでした",
            "pt-BR": "não foi possível salvar o design",
        },
        "synced_from_icloud": {
            "en": "synced from iCloud",
            "en-GB": "synced from iCloud",
            "ar": "تمت المزامنة من iCloud",
            "fr": "synchronisé depuis iCloud",
            "ja": "iCloud から同期しました",
            "pt-BR": "sincronizado com o iCloud",
        },
        "delete": {
            "en": "delete",
            "en-GB": "delete",
            "ar": "حذف",
            "fr": "supprimer",
            "ja": "削除",
            "pt-BR": "excluir",
        },
        "delete_design_message": {
            "en": "this can't be undone",
            "en-GB": "this can't be undone",
            "ar": "لا يمكن التراجع عن هذا الإجراء",
            "fr": "cette action est irréversible",
            "ja": "この操作は取り消せません",
            "pt-BR": "isso não pode ser desfeito",
        },
        "delete_design_title": {
            "en": "delete design?",
            "en-GB": "delete design?",
            "ar": "حذف التصميم؟",
            "fr": "supprimer la création ?",
            "ja": "デザインを削除しますか？",
            "pt-BR": "excluir o design?",
        },
        "duplicate": {
            "en": "duplicate",
            "en-GB": "duplicate",
            "ar": "تكرار",
            "fr": "dupliquer",
            "ja": "複製",
            "pt-BR": "duplicar",
        },
        "retry": {
            "en": "retry",
            "en-GB": "retry",
            "ar": "إعادة المحاولة",
            "fr": "réessayer",
            "ja": "再試行",
            "pt-BR": "tentar novamente",
        },
        "Cancel": {
            "en": "Cancel",
            "en-GB": "Cancel",
            "ar": "إلغاء",
            "fr": "Annuler",
            "ja": "キャンセル",
            "pt-BR": "Cancelar",
        },
        ":": {
            "en": ":",
            "en-GB": ":",
            "ar": ":",
            "fr": ":",
            "ja": ":",
            "pt-BR": ":",
        },
        "a": {
            "en": "a",
            "en-GB": "a",
            "ar": "أ",
            "fr": "a",
            "ja": "a",
            "pt-BR": "a",
        },
        "k": {
            "en": "k",
            "en-GB": "k",
            "ar": "ك",
            "fr": "k",
            "ja": "k",
            "pt-BR": "k",
        },
        "ø": {
            "en": "ø",
            "en-GB": "ø",
            "ar": "ø",
            "fr": "ø",
            "ja": "ø",
            "pt-BR": "ø",
        },
        "empty_state_title": {
            "en": "No designs yet",
            "en-GB": "No designs yet",
            "ar": "لا توجد تصاميم بعد",
            "fr": "Aucune création pour l’instant",
            "ja": "まだデザインがありません",
            "pt-BR": "Ainda não há designs",
        },
        "empty_state_subtitle": {
            "en": "Create your first design to get started.",
            "en-GB": "Create your first design to get started.",
            "ar": "ابدأ بإنشاء تصميمك الأول.",
            "fr": "Commencez par créer votre première création.",
            "ja": "最初のデザインを作成して始めましょう。",
            "pt-BR": "Comece criando seu primeiro design.",
        },
        "create_first_design": {
            "en": "Create a design",
            "en-GB": "Create a design",
            "ar": "إنشاء تصميم",
            "fr": "Créer un design",
            "ja": "デザインを作成",
            "pt-BR": "Criar um design",
        },
        "color swatches: background": {
            "en": "color swatches: background",
            "en-GB": "colour swatches: background",
            "ar": "عينات الألوان: الخلفية",
            "fr": "nuancier : arrière-plan",
            "ja": "カラースウォッチ：背景",
            "pt-BR": "amostras de cor: plano de fundo",
        },
        "color swatches: text": {
            "en": "color swatches: text",
            "en-GB": "colour swatches: text",
            "ar": "عينات الألوان: النص",
            "fr": "nuancier : texte",
            "ja": "カラースウォッチ：テキスト",
            "pt-BR": "amostras de cor: texto",
        },
        "Confirm Before Deleting": {
            "en": "Confirm Before Deleting",
            "en-GB": "Confirm Before Deleting",
            "ar": "التأكيد قبل الحذف",
            "fr": "Confirmer avant suppression",
            "ja": "削除前に確認",
            "pt-BR": "Confirmar antes de excluir",
        },
        "Extended Range": {
            "en": "Extended Range",
            "en-GB": "Extended Range",
            "ar": "نطاق موسّع",
            "fr": "Plage étendue",
            "ja": "拡張レンジ",
            "pt-BR": "Intervalo estendido",
        },
        "Default Background Color": {
            "en": "Default Background Color",
            "en-GB": "Default Background Colour",
            "ar": "لون الخلفية الافتراضي",
            "fr": "Couleur d’arrière-plan par défaut",
            "ja": "デフォルトの背景色",
            "pt-BR": "Cor de fundo padrão",
        },
        "Default Text Color": {
            "en": "Default Text Color",
            "en-GB": "Default Text Colour",
            "ar": "لون النص الافتراضي",
            "fr": "Couleur du texte par défaut",
            "ja": "デフォルトのテキスト色",
            "pt-BR": "Cor do texto padrão",
        },
        "Force Lowercase": {
            "en": "Force Lowercase",
            "en-GB": "Force Lowercase",
            "ar": "فرض الأحرف الصغيرة",
            "fr": "Forcer les minuscules",
            "ja": "小文字に固定",
            "pt-BR": "Forçar minúsculas",
        },
        "Last Modified": {
            "en": "Last Modified",
            "en-GB": "Last Modified",
            "ar": "آخر تعديل",
            "fr": "Dernière modification",
            "ja": "最終更新",
            "pt-BR": "Última modificação",
        },
        "Newest First": {
            "en": "Newest First",
            "en-GB": "Newest First",
            "ar": "الأحدث أولاً",
            "fr": "Plus récent en premier",
            "ja": "新しい順",
            "pt-BR": "Mais novos primeiro",
        },
        "Oldest First": {
            "en": "Oldest First",
            "en-GB": "Oldest First",
            "ar": "الأقدم أولاً",
            "fr": "Plus ancien en premier",
            "ja": "古い順",
            "pt-BR": "Mais antigos primeiro",
        },
        "show color swatches": {
            "en": "show color swatches",
            "en-GB": "show colour swatches",
            "ar": "إظهار عينات الألوان",
            "fr": "afficher le nuancier",
            "ja": "カラースウォッチを表示",
            "pt-BR": "mostrar amostras de cor",
        },
        "show tools": {
            "en": "show tools",
            "en-GB": "show tools",
            "ar": "إظهار الأدوات",
            "fr": "afficher les outils",
            "ja": "ツールを表示",
            "pt-BR": "mostrar ferramentas",
        },
        "Sort Order": {
            "en": "Sort Order",
            "en-GB": "Sort Order",
            "ar": "ترتيب الفرز",
            "fr": "Ordre de tri",
            "ja": "並び順",
            "pt-BR": "Ordem de classificação",
        },
    }

    for key, lang_map in MERGE.items():
        if key not in strings:
            strings[key] = {}
        entry = strings[key]
        loc = entry.get("localizations") or {}
        for lang, text in lang_map.items():
            loc[lang] = su(text)
        entry["localizations"] = loc

    # Prune all entries to shipped locales only
    for _key, entry in strings.items():
        if "localizations" in entry and entry["localizations"]:
            entry["localizations"] = prune_localizations(entry["localizations"])

    with open(PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")

    print(f"Updated {PATH}")


if __name__ == "__main__":
    main()
