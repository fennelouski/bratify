# Localization

## Shipped languages

The Xcode project’s `knownRegions` match every locale column in [Localizable.xcstrings](Localizable.xcstrings). The catalog currently embeds **70** locale variants:

`af`, `ar`, `be`, `bg`, `bn`, `ca`, `cs`, `cy`, `da`, `de`, `el`, `en`, `en-AU`, `en-CA`, `en-GB`, `en-IN`, `es`, `es-419`, `es-US`, `et`, `eu`, `fa`, `fi`, `fil`, `fr`, `fr-CA`, `ga`, `gl`, `he`, `hi`, `hr`, `hu`, `hy`, `id`, `is`, `it`, `ja`, `ka`, `kk`, `ko`, `lt`, `lv`, `mk`, `mn`, `ms`, `nb`, `nl`, `pl`, `pt-BR`, `pt-PT`, `ro`, `ru`, `sk`, `sl`, `sq`, `sr`, `sr-Latn`, `sv`, `sw`, `ta`, `te`, `th`, `tr`, `uk`, `ur`, `uz`, `vi`, `zh-HK`, `zh-Hans`, `zh-Hant`

**Development language** is `en` (U.S. English). Where a string never had a translator pass for a given locale, the catalog uses the **English source** for that column so the bundle stays complete (you can replace those values over time). The newest locale columns (`af`, `bn`, `et`, `fa`, `fil`, `is`, `lt`, `lv`, `sw`, `ur`) may still mirror English until they receive a native review. Strings in `scripts/keys_order.txt` for `be`, `bg`, `cy`, `eu`, `ga`, `gl`, `hy`, `ka`, `kk`, `mk`, `mn`, `sq`, `sr`, `sr-Latn`, `ta`, `te`, `uz` (plus existing `translate_pass_v1` targets) are filled from `scripts/vals/*.txt`; the `*Help` / `LoadingSettings` keys for those locales may still mirror English until localized separately.

## UK English (`en-GB`)

Strings include explicit `en-GB` where British spelling or wording was added (e.g. **colour**). Other `en-GB` rows may mirror `en` until you tailor copy.

## Regenerating shipped locales (scripts)

Human-reviewed translations for the primary catalog locales are maintained via scripts under `scripts/`:

1. Edit UI strings in [`scripts/ui_parallel.py`](../scripts/ui_parallel.py) (per-locale lists in **NON_BG** order) and/or Background\* templates in [`scripts/gen_locale_columns.py`](../scripts/gen_locale_columns.py) (`BG`).
2. Run `python3 scripts/emit_locale_columns.py` to rebuild [`scripts/locale_columns.json`](../scripts/locale_columns.json).
3. Run `python3 scripts/translate_catalog.py` to apply updates to [`Localizable.xcstrings`](Localizable.xcstrings).

Supporting snapshots: [`scripts/en_base.json`](../scripts/en_base.json), [`scripts/gb_preserve.json`](../scripts/gb_preserve.json), [`scripts/ar_column.json`](../scripts/ar_column.json). Row order is defined in [`scripts/bratify_locale_table.py`](../scripts/bratify_locale_table.py).

**Typographic puzzle strings** (`""`, `:`, `ø`, `zerØ`) are omitted from the scripted locale table (`SKIP` in `scripts/emit_locale_columns.py` / `bratify_locale_table.py`). Tune those per locale directly in `Localizable.xcstrings` so stylized “zero” variants are not flattened by the bulk pipeline.

## App Store

Listing extra languages in Xcode does not add them to App Store Connect automatically—you still select primary and additional languages per version when you ship.
