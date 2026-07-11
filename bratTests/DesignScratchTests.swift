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
final class LiveDesignPreviewParityTests: XCTestCase {

    /// The live GPU preview and the generateImage export path must agree:
    /// same dimensions, and near-identical color in every horizontal band
    /// (top/middle/bottom thirds — the middle band contains the text).
    func testLivePreviewMatchesGenerateImage() throws {
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
        design.width = 256
        design.height = 256
        design.scratchIntensity = 0.7
        design.mainImageFilters.saturation = 1.2
        design.mainImageFilters.vignette = 0.4
        design.mainImageFilters.pixelate = 12 // exercises the pixel-based param rescaling on the capped path

        let imageService = ImageService()
        let scale = UIScreen.main.scale

        let exported = expectation(description: "generateImage")
        var exportedImage: UIImage?
        design.generateImage(with: imageService, userInterfaceStyle: .light, bypassCache: true) { image, _ in
            exportedImage = image
            exported.fulfill()
        }
        wait(for: [exported], timeout: 30)
        let reference = try XCTUnwrap(exportedImage)

        let liveView = try XCTUnwrap(LiveDesignPreviewView(imageService: imageService))
        liveView.update(design: design, userInterfaceStyle: .light, displayScale: scale)
        let live = try XCTUnwrap(liveView.composedImageForTesting())

        XCTAssertEqual(live.size, reference.size, "Live preview and export must have the same pixel dimensions")

        func bandAverages(_ image: UIImage) throws -> [[CGFloat]] {
            let cgImage = try XCTUnwrap(image.cgImage)
            let ciImage = CIImage(cgImage: cgImage)
            let extent = ciImage.extent
            let bandHeight = extent.height / 3
            return (0..<3).map { band in
                let rect = CGRect(x: extent.minX, y: extent.minY + CGFloat(band) * bandHeight,
                                  width: extent.width, height: bandHeight)
                let filter = CIFilter(name: "CIAreaAverage")!
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                filter.setValue(CIVector(cgRect: rect), forKey: kCIInputExtentKey)
                var bitmap = [UInt8](repeating: 0, count: 4)
                ImageFilterRendering.sharedContext.render(
                    filter.outputImage!, toBitmap: &bitmap, rowBytes: 4,
                    bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                    format: .RGBA8, colorSpace: CGColorSpaceCreateDeviceRGB()
                )
                return bitmap.map { CGFloat($0) / 255 }
            }
        }

        let referenceBands = try bandAverages(reference)
        let liveBands = try bandAverages(live)
        for (band, (ref, liv)) in zip(referenceBands, liveBands).enumerated() {
            for channel in 0..<3 {
                XCTAssertEqual(
                    liv[channel], ref[channel], accuracy: 0.04,
                    "Band \(band) channel \(channel) diverged between live preview and export"
                )
            }
        }

        // Old-hardware path: once the view has a (small) drawable, the raster
        // resolution is capped to it. Fewer pixels, same look.
        liveView.frame = CGRect(x: 0, y: 0, width: 64, height: 64)
        liveView.layoutIfNeeded()
        liveView.update(design: design, userInterfaceStyle: .light, displayScale: scale)
        let capped = try XCTUnwrap(liveView.composedImageForTesting())
        let cappedPixelWidth = try XCTUnwrap(capped.cgImage).width
        let referencePixelWidth = try XCTUnwrap(reference.cgImage).width
        XCTAssertLessThan(cappedPixelWidth, referencePixelWidth, "Resolution cap should reduce rendered pixels")

        let cappedBands = try bandAverages(capped)
        for (band, (ref, liv)) in zip(referenceBands, cappedBands).enumerated() {
            for channel in 0..<3 {
                XCTAssertEqual(
                    liv[channel], ref[channel], accuracy: 0.05,
                    "Capped band \(band) channel \(channel) diverged from export"
                )
            }
        }
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
