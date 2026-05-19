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
        XCTAssertEqual(output?.size.width, 64, accuracy: 0.5)
    }

    func testCacheKeyFragmentChangesWithHue() {
        var a = ImageFilterSettings.default
        var b = ImageFilterSettings.default
        XCTAssertEqual(a.cacheKeyFragment(), b.cacheKeyFragment())
        b.hue = 10
        XCTAssertNotEqual(a.cacheKeyFragment(), b.cacheKeyFragment())
    }
}
