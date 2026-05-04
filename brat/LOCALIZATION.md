# Localization

## Shipped languages

The Xcode project’s `knownRegions` match every locale column in [Localizable.xcstrings](Localizable.xcstrings). The catalog currently embeds **53** locale variants:

`af`, `ar`, `bn`, `ca`, `cs`, `da`, `de`, `el`, `en`, `en-AU`, `en-CA`, `en-GB`, `en-IN`, `es`, `es-419`, `es-US`, `et`, `fa`, `fi`, `fil`, `fr`, `fr-CA`, `he`, `hi`, `hr`, `hu`, `id`, `is`, `it`, `ja`, `ko`, `lt`, `lv`, `ms`, `nb`, `nl`, `pl`, `pt-BR`, `pt-PT`, `ro`, `ru`, `sk`, `sl`, `sv`, `sw`, `th`, `tr`, `uk`, `ur`, `vi`, `zh-HK`, `zh-Hans`, `zh-Hant`

**Development language** is `en` (U.S. English). Where a string never had a translator pass for a given locale, the catalog uses the **English source** for that column so the bundle stays complete (you can replace those values over time). The newest locale columns (`af`, `bn`, `et`, `fa`, `fil`, `is`, `lt`, `lv`, `sw`, `ur`) may still mirror English until they receive a native review.

## UK English (`en-GB`)

Strings include explicit `en-GB` where British spelling or wording was added (e.g. **colour**). Other `en-GB` rows may mirror `en` until you tailor copy.

## App Store

Listing extra languages in Xcode does not add them to App Store Connect automatically—you still select primary and additional languages per version when you ship.
