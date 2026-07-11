import XCTest
@testable import brat

final class DesignScratchTests: XCTestCase {

    func testDecodeWithoutScratchKeyDefaultsToZero() throws {
        let json = """
        {
            "text": "hello",
            "backgroundColor": "#00FF00",
            "creationDate": 0,
            "fontName": "Arial",
            "fontSize": 48,
            "pixelationScale": 8,
            "id": "00000000-0000-0000-0000-000000000001"
        }
        """
        let data = try XCTUnwrap(json.data(using: .utf8))
        let design = try JSONDecoder().decode(Design.self, from: data)
        XCTAssertEqual(design.scratchIntensity, 0)
    }

    func testScratchIntensityRoundTrips() throws {
        var design = Design(
            text: "hello",
            backgroundColor: .green,
            creationDate: Date(),
            fontName: "Arial",
            fontSize: 48,
            pixelationScale: 8
        )
        design.scratchIntensity = 0.6
        let data = try JSONEncoder().encode(design)
        let decoded = try JSONDecoder().decode(Design.self, from: data)
        XCTAssertEqual(decoded.scratchIntensity, 0.6, accuracy: 0.0001)
    }

    func testScratchChangesCacheKeyOnlyWhenNonZero() {
        var design = Design(
            text: "hello",
            backgroundColor: .green,
            creationDate: Date(),
            fontName: "Arial",
            fontSize: 48,
            pixelationScale: 8
        )
        let baseKey = design.description
        design.scratchIntensity = 0.5
        XCTAssertNotEqual(design.description, baseKey)
        design.scratchIntensity = 0
        XCTAssertEqual(design.description, baseKey)
    }

    func testSeededRandomIsDeterministic() {
        let uuid = UUID(uuidString: "12345678-1234-1234-1234-123456789012")!
        var a = SeededRandom(uuid: uuid)
        var b = SeededRandom(uuid: uuid)
        for _ in 0..<32 {
            XCTAssertEqual(a.next(), b.next())
        }
        var c = SeededRandom(uuid: UUID(uuidString: "00000000-0000-0000-0000-000000000009")!)
        XCTAssertNotEqual(SeededRandom(uuid: uuid).next(), c.next())
    }
}
