import AVFoundation
import CoreImage
import UIKit

/// Exports a design's rendered image as a short looping MP4 for social sharing.
/// The animation is a pixelation "resolve" — the image resolves in from chunky
/// blocks, holds sharp, then dissolves back out so the video loops seamlessly.
final class DesignVideoExporter {

    enum ExportError: Error {
        case invalidImage
        case writerSetupFailed
        case writingFailed
    }

    private let queue = DispatchQueue(label: "com.nathanfennel.brat.videoExport")
    private var isCancelled = false

    func cancel() {
        queue.async { self.isCancelled = true }
    }

    func export(
        baseImage: UIImage,
        duration: TimeInterval = 4,
        fps: Int32 = 30,
        progress: @escaping (Double) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        queue.async {
            self.isCancelled = false
            let result = self.performExport(
                baseImage: baseImage,
                duration: duration,
                fps: fps,
                progress: progress
            )
            DispatchQueue.main.async { completion(result) }
        }
    }

    private func performExport(
        baseImage: UIImage,
        duration: TimeInterval,
        fps: Int32,
        progress: @escaping (Double) -> Void
    ) -> Result<URL, Error> {
        guard let upscaled = upscaledForVideo(baseImage),
              let baseCGImage = upscaled.cgImage else {
            return .failure(ExportError.invalidImage)
        }
        // H.264 requires even dimensions; crop render extent to match the buffer.
        let fullExtent = CIImage(cgImage: baseCGImage).extent
        let videoWidth = Int(fullExtent.width) / 2 * 2
        let videoHeight = Int(fullExtent.height) / 2 * 2
        let extent = CGRect(x: 0, y: 0, width: videoWidth, height: videoHeight)
        let baseCIImage = CIImage(cgImage: baseCGImage).cropped(to: extent)

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("bratify-\(UUID().uuidString).mp4")
        try? FileManager.default.removeItem(at: outputURL)

        guard let writer = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4) else {
            return .failure(ExportError.writerSetupFailed)
        }
        let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: videoWidth,
            AVVideoHeightKey: videoHeight,
        ])
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: input,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
                kCVPixelBufferWidthKey as String: videoWidth,
                kCVPixelBufferHeightKey as String: videoHeight,
            ]
        )
        guard writer.canAdd(input) else { return .failure(ExportError.writerSetupFailed) }
        writer.add(input)
        guard writer.startWriting() else {
            return .failure(writer.error ?? ExportError.writerSetupFailed)
        }
        writer.startSession(atSourceTime: .zero)

        let frameCount = Int(duration * Double(fps))
        let context = ImageFilterRendering.sharedContext
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        for frame in 0..<frameCount {
            if isCancelled {
                writer.cancelWriting()
                try? FileManager.default.removeItem(at: outputURL)
                return .failure(CancellationError())
            }
            while !input.isReadyForMoreMediaData {
                Thread.sleep(forTimeInterval: 0.005)
            }

            let t = Double(frame) / Double(frameCount)
            let frameImage = pixellated(baseCIImage, extent: extent, phase: t)

            guard let pool = adaptor.pixelBufferPool else {
                writer.cancelWriting()
                return .failure(ExportError.writingFailed)
            }
            var buffer: CVPixelBuffer?
            CVPixelBufferPoolCreatePixelBuffer(nil, pool, &buffer)
            guard let pixelBuffer = buffer else {
                writer.cancelWriting()
                return .failure(ExportError.writingFailed)
            }
            context.render(frameImage, to: pixelBuffer, bounds: extent, colorSpace: colorSpace)

            let time = CMTime(value: CMTimeValue(frame), timescale: fps)
            guard adaptor.append(pixelBuffer, withPresentationTime: time) else {
                let error = writer.error
                writer.cancelWriting()
                return .failure(error ?? ExportError.writingFailed)
            }
            DispatchQueue.main.async { progress(Double(frame + 1) / Double(frameCount)) }
        }

        input.markAsFinished()
        let semaphore = DispatchSemaphore(value: 0)
        writer.finishWriting { semaphore.signal() }
        semaphore.wait()

        if writer.status == .completed {
            return .success(outputURL)
        }
        try? FileManager.default.removeItem(at: outputURL)
        return .failure(writer.error ?? ExportError.writingFailed)
    }

    /// Resolve in (0…0.3), hold sharp (0.3…0.7), dissolve out (0.7…1) —
    /// start and end at max pixelation so the video loops seamlessly.
    private func pixellated(_ image: CIImage, extent: CGRect, phase t: Double) -> CIImage {
        let maxScale = max(extent.width, extent.height) / 24.0
        let amount: Double
        switch t {
        case ..<0.3: amount = 1 - t / 0.3
        case ..<0.7: amount = 0
        default: amount = (t - 0.7) / 0.3
        }
        guard amount > 0.001 else { return image }

        let scale = max(1, CGFloat(amount) * maxScale)
        guard let filter = CIFilter(name: "CIPixellate") else { return image }
        filter.setValue(image.clampedToExtent(), forKey: kCIInputImageKey)
        filter.setValue(scale, forKey: kCIInputScaleKey)
        filter.setValue(CIVector(x: extent.midX, y: extent.midY), forKey: kCIInputCenterKey)
        return filter.outputImage?.cropped(to: extent) ?? image
    }

    /// Nearest-neighbor upscale so the longest side is ~1080, preserving the lo-fi look.
    private func upscaledForVideo(_ image: UIImage) -> UIImage? {
        let longest = max(image.size.width, image.size.height) * image.scale
        guard longest > 0 else { return nil }
        let factor = 1080.0 / longest
        guard factor > 1 else { return image }
        return image.fastScaled(by: factor) ?? image
    }
}
