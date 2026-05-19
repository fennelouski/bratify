//
//  DesignTextColorTests.swift
//  bratTests
//

import XCTest
@testable import brat

final class DesignTextColorTests: XCTestCase {

    private func makeDesign(
        textColor: UIColor = .white,
        usesAutomaticTextColor: Bool = false
    ) -> Design {
        Design(
            text: "test",
            backgroundColor: .green,
            textColor: textColor,
            usesAutomaticTextColor: usesAutomaticTextColor,
            creationDate: Date(),
            fontName: "Arial",
            fontSize: 48,
            pixelationScale: 8
        )
    }

    func testAutomaticTextColorIsWhiteInDarkMode() {
        let color = DesignTextColor.automatic(for: .dark)
        XCTAssertEqual(color, .white)
    }

    func testAutomaticTextColorIsBlackInLightMode() {
        let color = DesignTextColor.automatic(for: .light)
        XCTAssertEqual(color, .black)
    }

    func testResolvedUsesAutomaticWhenFlagSet() {
        let design = makeDesign(textColor: .red, usesAutomaticTextColor: true)
        XCTAssertEqual(design.resolvedTextColor(for: .dark), .white)
        XCTAssertEqual(design.resolvedTextColor(for: .light), .black)
    }

    func testResolvedUsesStoredColorWhenNotAutomatic() {
        let design = makeDesign(textColor: .red, usesAutomaticTextColor: false)
        XCTAssertEqual(design.resolvedTextColor(for: .dark), .red)
        XCTAssertEqual(design.resolvedTextColor(for: .light), .red)
    }

    func testDecodeWithoutAutomaticFlagDefaultsToFalse() throws {
        let json = """
        {
            "text": "hello",
            "backgroundColor": "#00FF00",
            "textColor": "#FF0000",
            "creationDate": 0,
            "fontName": "Arial",
            "fontSize": 48,
            "pixelationScale": 8,
            "id": "00000000-0000-0000-0000-000000000001"
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let design = try JSONDecoder().decode(Design.self, from: data)
        XCTAssertFalse(design.usesAutomaticTextColor)
        XCTAssertEqual(design.textColor, UIColor(hexString: "#FF0000"))
    }

    func testImageCacheKeyIncludesAppearanceWhenAutomatic() {
        let design = makeDesign(usesAutomaticTextColor: true)
        let darkKey = design.imageCacheKey(userInterfaceStyle: .dark)
        let lightKey = design.imageCacheKey(userInterfaceStyle: .light)
        XCTAssertNotEqual(darkKey, lightKey)
        XCTAssertTrue(darkKey.contains("appearance"))
    }

    func testResolvedUserInterfaceStyleUsesTraitCollectionWhenUnspecified() {
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        let resolved = DesignTextColor.resolvedUserInterfaceStyle(
            .unspecified,
            traitCollection: traits,
            view: nil
        )
        XCTAssertEqual(resolved, .dark)
    }

    func testAutomaticTextColorWithUnspecifiedStyleAndDarkTraits() {
        let design = makeDesign(textColor: .red, usesAutomaticTextColor: true)
        let traits = UITraitCollection(userInterfaceStyle: .dark)
        XCTAssertEqual(design.resolvedTextColor(for: traits), .white)
    }
}
