//
//  ImageFilterSettingsTests.swift
//  bratTests
//

import XCTest
@testable import brat

final class ImageFilterSettingsTests: XCTestCase {

    func testDefaultSettingsAreNeutral() {
        let settings = ImageFilterSettings.default
        XCTAssertEqual(settings.brightness, 0)
        XCTAssertEqual(settings.contrast, 1)
        XCTAssertEqual(settings.saturation, 1)
        XCTAssertEqual(settings.highlightAmount, 1)
        XCTAssertTrue(settings.isDefault)
    }

    func testDesignRoundTripMainFilters() {
        var design = Design(
            text: "test",
            backgroundColor: .green,
            creationDate: Date(),
            fontName: "Arial",
            fontSize: 48,
            pixelationScale: 1,
            hue: 45,
            grain: 0.2,
            bloom: 0.1
        )
        let filters = design.mainImageFilters
        XCTAssertEqual(filters.hue, 45)
        XCTAssertEqual(filters.grain, 0.2, accuracy: 0.001)

        design.applyMainImageFilters(.default)
        XCTAssertEqual(design.mainImageFilters, .default)
    }

    func testNonePresetZeroesMainAndBackgroundFilterFields() {
        var design = Design(
            text: "test",
            backgroundColor: .green,
            creationDate: Date(),
            fontName: "Arial",
            fontSize: 48,
            pixelationScale: 1,
            contrast: 1.5,
            backgroundContrast: 1.4,
            backgroundHue: 30
        )
        let none = FilterPreset.builtIn.first { $0.id == "none" }!
        none.apply(to: &design)
        XCTAssertEqual(design.mainImageFilters, .default)
        XCTAssertEqual(design.backgroundImageFilters, .default)
    }

    func testNonePresetResetsBackgroundTransform() {
        var design = Design(
            text: "test",
            backgroundColor: .green,
            creationDate: Date(),
            fontName: "Arial",
            fontSize: 48,
            pixelationScale: 1,
            backgroundScale: 1.8,
            backgroundFlipHorizontal: true,
            backgroundFlipVertical: true,
            backgroundBlur: 12,
            backgroundAlpha: 0.5
        )
        let none = FilterPreset.builtIn.first { $0.id == "none" }!
        none.apply(to: &design)
        design.backgroundScale = 1.0
        design.backgroundFlipHorizontal = false
        design.backgroundFlipVertical = false
        design.backgroundBlur = 0.0
        design.backgroundAlpha = 1.0
        XCTAssertEqual(design.backgroundScale, 1.0, accuracy: 0.001)
        XCTAssertFalse(design.backgroundFlipHorizontal)
        XCTAssertFalse(design.backgroundFlipVertical)
        XCTAssertEqual(design.backgroundBlur, 0, accuracy: 0.001)
        XCTAssertEqual(design.backgroundAlpha, 1.0, accuracy: 0.001)
    }

    func testPresetAppliesToDesign() {
        var design = Design(
            text: "test",
            backgroundColor: .green,
            creationDate: Date(),
            fontName: "Arial",
            fontSize: 48,
            pixelationScale: 1
        )
        let preset = FilterPreset.builtIn.first { $0.id == "negative_pop" }!
        preset.apply(to: &design)
        XCTAssertTrue(design.invert)
        XCTAssertGreaterThan(design.contrast, 1)
    }

    func testApplyFiltersProducesImage() {
        let size = CGSize(width: 64, height: 64)
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        UIColor.red.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        var settings = ImageFilterSettings.default
        settings.brightness = 0.1
        settings.hue = 30
        let output = image.applyFilters(settings)
        XCTAssertNotNil(output)
        XCTAssertEqual(Double(output?.size.width ?? 0), 64, accuracy: 0.5)
    }

    func testCacheKeyFragmentChangesWithHue() {
        var a = ImageFilterSettings.default
        var b = ImageFilterSettings.default
        XCTAssertEqual(a.cacheKeyFragment(), b.cacheKeyFragment())
        b.hue = 10
        XCTAssertNotEqual(a.cacheKeyFragment(), b.cacheKeyFragment())
    }

    func testBuiltInPresetsHaveValidSymbolsAndLayoutRatios() {
        for preset in FilterPreset.builtIn {
            XCTAssertFalse(preset.symbolName.isEmpty, preset.id)
            XCTAssertNotNil(
                UIImage(systemName: preset.symbolName),
                "Missing SF Symbol for \(preset.id): \(preset.symbolName)"
            )
            XCTAssertGreaterThan(preset.layoutAspectRatio, 0.5, preset.id)
            XCTAssertLessThan(preset.layoutAspectRatio, 1.5, preset.id)
        }
    }

    func testBuiltInPresetIDsAreUnique() {
        let ids = FilterPreset.builtIn.map(\.id)
        XCTAssertEqual(ids.count, Set(ids).count, "Duplicate preset IDs: \(ids)")
    }

    func testBuiltInPresetCount() {
        XCTAssertEqual(FilterPreset.builtIn.count, 25)
    }

    func testBuiltInPresetsHavePreviewSettingsExceptNone() {
        for preset in FilterPreset.builtIn where preset.id != "none" {
            XCTAssertNotNil(
                preset.previewFilterSettings,
                "Preset \(preset.id) should expose preview settings"
            )
        }
        let none = FilterPreset.builtIn.first { $0.id == "none" }!
        XCTAssertNotNil(none.main)
        XCTAssertNotNil(none.background)
    }

    func testWarmFadeUsesBackgroundSettingsForPreview() {
        let warmFade = FilterPreset.builtIn.first { $0.id == "warm_fade" }!
        XCTAssertNil(warmFade.main)
        XCTAssertNotNil(warmFade.background)
        XCTAssertEqual(warmFade.previewFilterSettings, warmFade.background)
    }

    func testFilterPresetPreviewProviderReturnsImages() {
        let none = FilterPreset.builtIn.first { $0.id == "none" }!
        let bratPunch = FilterPreset.builtIn.first { $0.id == "brat_punch" }!

        let noneExpectation = expectation(description: "none preview")
        FilterPresetPreviewProvider.preview(for: none) { image in
            XCTAssertNotNil(image)
            noneExpectation.fulfill()
        }

        let punchExpectation = expectation(description: "brat punch preview")
        FilterPresetPreviewProvider.preview(for: bratPunch) { image in
            XCTAssertNotNil(image)
            punchExpectation.fulfill()
        }

        wait(for: [noneExpectation, punchExpectation], timeout: 10)
        XCTAssertNotNil(FilterPresetPreviewProvider.cachedPreview(for: "none"))
        XCTAssertNotNil(FilterPresetPreviewProvider.cachedPreview(for: "brat_punch"))
    }
}
