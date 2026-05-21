//
//  FilterPresetPreviewProvider.swift
//  brat
//

import UIKit

/// Generates and caches real filter previews for style preset cards.
enum FilterPresetPreviewProvider {

    private static let sampleSize = CGSize(width: 80, height: 120)
    private static var sampleImage: UIImage?
    private static var canvasImage: UIImage?
    private static var cache: [String: UIImage] = [:]
    private static let lock = NSLock()
    private static let renderQueue = DispatchQueue(label: "com.brat.filterPresetPreview", qos: .userInitiated)

    static func setCanvasImage(_ image: UIImage?) {
        let thumbnail: UIImage?
        if let image {
            let maxDim: CGFloat = 200
            let scale = min(maxDim / image.size.width, maxDim / image.size.height, 1)
            let thumbSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            thumbnail = UIGraphicsImageRenderer(size: thumbSize).image { _ in
                image.draw(in: CGRect(origin: .zero, size: thumbSize))
            }
        } else {
            thumbnail = nil
        }
        lock.lock()
        canvasImage = thumbnail
        cache.removeAll()
        lock.unlock()
    }

    static func preview(for preset: FilterPreset, completion: @escaping (UIImage?) -> Void) {
        if let cached = cachedImage(for: preset.id) {
            DispatchQueue.main.async { completion(cached) }
            return
        }

        renderQueue.async {
            let image = renderPreview(for: preset)
            if let image {
                lock.lock()
                cache[preset.id] = image
                lock.unlock()
            }
            DispatchQueue.main.async { completion(image) }
        }
    }

    static func cachedPreview(for presetID: String) -> UIImage? {
        cachedImage(for: presetID)
    }

    private static func cachedImage(for presetID: String) -> UIImage? {
        lock.lock()
        defer { lock.unlock() }
        return cache[presetID]
    }

    private static func renderPreview(for preset: FilterPreset) -> UIImage? {
        lock.lock()
        let sourceSnapshot = canvasImage
        lock.unlock()

        let source = sourceSnapshot ?? baseSampleImage()
        if preset.id == "none" { return source }
        guard let settings = preset.previewFilterSettings else { return source }
        return source.applyFilters(settings)
    }

    private static func baseSampleImage() -> UIImage {
        lock.lock()
        if let sampleImage {
            lock.unlock()
            return sampleImage
        }
        lock.unlock()

        let renderer = UIGraphicsImageRenderer(size: sampleSize)
        let image = renderer.image { context in
            let rect = CGRect(origin: .zero, size: sampleSize)
            let skyColors = [
                UIColor(red: 0.45, green: 0.72, blue: 0.95, alpha: 1).cgColor,
                UIColor(red: 0.78, green: 0.88, blue: 0.98, alpha: 1).cgColor,
            ] as CFArray
            if let sky = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: skyColors,
                locations: [0, 1]
            ) {
                context.cgContext.drawLinearGradient(
                    sky,
                    start: CGPoint(x: rect.midX, y: rect.minY),
                    end: CGPoint(x: rect.midX, y: rect.midY + rect.height * 0.55),
                    options: []
                )
            }

            let groundColors = [
                UIColor(red: 0.35, green: 0.55, blue: 0.32, alpha: 1).cgColor,
                UIColor(red: 0.22, green: 0.38, blue: 0.24, alpha: 1).cgColor,
            ] as CFArray
            if let ground = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: groundColors,
                locations: [0, 1]
            ) {
                context.cgContext.drawLinearGradient(
                    ground,
                    start: CGPoint(x: rect.midX, y: rect.midY + rect.height * 0.45),
                    end: CGPoint(x: rect.midX, y: rect.maxY),
                    options: []
                )
            }

            let accent = UIColor(red: 0.95, green: 0.55, blue: 0.35, alpha: 1)
            let circleRect = CGRect(
                x: rect.width * 0.28,
                y: rect.height * 0.32,
                width: rect.width * 0.44,
                height: rect.width * 0.44
            )
            context.cgContext.setFillColor(accent.cgColor)
            context.cgContext.fillEllipse(in: circleRect)

            context.cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.85).cgColor)
            context.cgContext.setLineWidth(2)
            context.cgContext.strokeEllipse(in: circleRect.insetBy(dx: 2, dy: 2))
        }

        lock.lock()
        sampleImage = image
        lock.unlock()
        return image
    }
}
