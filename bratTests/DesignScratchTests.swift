import AVFoundation
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

    func testScratchRendersDeterministicallyAndChangesOutput() throws {
        var design = Design(
            text: "brat",
            backgroundColor: UIColor(hexString: "#8ACE00"),
            usesAutomaticTextColor: false,
            creationDate: Date(),
            fontName: "Arial",
            fontSize: 120,
            pixelationScale: 2,
            id: UUID(uuidString: "12345678-1234-1234-1234-123456789012")!
        )
        design.textColor = .black

        func render(_ design: Design) -> Data {
            let view = DesignView(
                frame: CGRect(x: 0, y: 0, width: 256, height: 256),
                imageService: ImageService()
            )
            var configured: DesignView?
            view.configure(
                with: design.text,
                backgroundColor: design.backgroundColor,
                fontName: design.fontName,
                fontSize: design.fontSize,
                stretch: design.stretch,
                imageName: nil,
                design: design
            ) { configured = $0 }
            let renderedView = try! XCTUnwrap(configured)  // completion is synchronous without a background image
            let image = UIGraphicsImageRenderer(size: renderedView.bounds.size).image { ctx in
                renderedView.layer.render(in: ctx.cgContext)
            }
            return image.pngData() ?? Data()
        }

        let plain = render(design)
        design.scratchIntensity = 0.7
        let scratchedA = render(design)
        let scratchedB = render(design)

        XCTAssertNotEqual(plain, scratchedA, "Scratch should visibly change the render")
        XCTAssertEqual(scratchedA, scratchedB, "Scratch must be deterministic per design")

        try? scratchedA.write(to: URL(fileURLWithPath: "/tmp/brat-scratch-preview.png"))
    }

    func testSeededRandomIsDeterministic() {
        let uuid = UUID(uuidString: "12345678-1234-1234-1234-123456789012")!
        var a = SeededRandom(uuid: uuid)
        var b = SeededRandom(uuid: uuid)
        for _ in 0..<32 {
            XCTAssertEqual(a.next(), b.next())
        }
        var c = SeededRandom(uuid: UUID(uuidString: "00000000-0000-0000-0000-000000000009")!)
        var d = SeededRandom(uuid: uuid)
        XCTAssertNotEqual(d.next(), c.next())
    }
}

// Lives here rather than its own file to keep the test target's project wiring minimal.
final class DesignVideoExporterTests: XCTestCase {

    func testExportProducesPlayableMP4() throws {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 128, height: 128)).image { ctx in
            UIColor(hexString: "#8ACE00").setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 128, height: 128))
        }

        let exporter = DesignVideoExporter()
        let done = expectation(description: "export")
        var exportResult: Result<URL, Error>?
        exporter.export(baseImage: image, duration: 0.5, fps: 10, progress: { _ in }) { result in
            exportResult = result
            done.fulfill()
        }
        wait(for: [done], timeout: 30)

        let url = try XCTUnwrap(try exportResult?.get())
        defer { try? FileManager.default.removeItem(at: url) }
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))

        let asset = AVURLAsset(url: url)
        let duration = CMTimeGetSeconds(asset.duration)
        XCTAssertEqual(duration, 0.5, accuracy: 0.15)
    }
}
