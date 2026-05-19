import XCTest
@testable import brat

final class CanvasDimensionsTests: XCTestCase {

    func testSimplifiedRatio() {
        XCTAssertEqual(CanvasDimensions.simplifiedRatio(width: 3024, height: 4032), (3, 4))
        XCTAssertEqual(CanvasDimensions.simplifiedRatio(width: 16, height: 9), (16, 9))
        XCTAssertEqual(CanvasDimensions.simplifiedRatio(width: 191, height: 100), (191, 100))
    }

    func testPixelSizeClampsLargeDimensions() {
        let size = CanvasDimensions.pixelSize(forAspectWidth: 4000, height: 3000)
        XCTAssertLessThanOrEqual(max(size.width, size.height), CanvasDimensions.maxDimension + 0.01)
        XCTAssertLessThanOrEqual(size.width * size.height, CanvasDimensions.maxPixels + 1)
    }

    func testPixelSizePreservesAspectRatio() {
        let size = CanvasDimensions.pixelSize(forAspectWidth: 16, height: 9)
        let ratio = size.width / size.height
        XCTAssertEqual(ratio, 16.0 / 9.0, accuracy: 0.001)
    }

    func testPixelSizeScalesPresetRatiosToUsableCanvas() {
        let portraitPost = CanvasDimensions.pixelSize(forAspectWidth: 4, height: 5)
        XCTAssertEqual(portraitPost.width, 409.6, accuracy: 0.01)
        XCTAssertEqual(portraitPost.height, 512, accuracy: 0.01)

        let story = CanvasDimensions.pixelSize(forAspectWidth: 9, height: 16)
        XCTAssertEqual(story.width, 288, accuracy: 0.01)
        XCTAssertEqual(story.height, 512, accuracy: 0.01)

        let square = CanvasDimensions.pixelSize(forAspectWidth: 1, height: 1)
        XCTAssertEqual(square.width, 512, accuracy: 0.01)
        XCTAssertEqual(square.height, 512, accuracy: 0.01)
    }

    func testMatchesRatioUsesSimplifiedForm() {
        XCTAssertTrue(CanvasDimensions.matchesRatio(canvasWidth: 512, canvasHeight: 288, presetWidth: 16, presetHeight: 9))
        XCTAssertTrue(CanvasDimensions.matchesRatio(canvasWidth: 1080, canvasHeight: 1920, presetWidth: 9, presetHeight: 16))
        XCTAssertFalse(CanvasDimensions.matchesRatio(canvasWidth: 512, canvasHeight: 512, presetWidth: 16, presetHeight: 9))
    }

    func testSocialPresetCount() {
        XCTAssertEqual(AspectRatioPreset.socialPresets.count, 6)
    }

    func testSocialPresetsHaveUniqueRatios() {
        var seen = Set<String>()
        for preset in AspectRatioPreset.socialPresets {
            let key = preset.ratioLabel
            XCTAssertFalse(seen.contains(key), "Duplicate social ratio: \(key)")
            seen.insert(key)
        }
    }

    func testPresetsHavePositiveDimensions() {
        for preset in AspectRatioPreset.allPresets {
            XCTAssertGreaterThan(preset.width, 0)
            XCTAssertGreaterThan(preset.height, 0)
        }
    }
}
