import UIKit
import MetalKit

/// GPU edit-canvas preview. Mirrors the `generateImage` pipeline — DesignView
/// raster → nearest-neighbor pixelation upscale → blur → main filter chain —
/// but keeps the whole thing as a CIImage graph rendered straight to a Metal
/// drawable, skipping the CPU readback that the cache/export path needs.
/// Text and background are rastered as separate layers so a keystroke only
/// re-rasters the text; the background layer is cached until its params change.
final class LiveDesignPreviewView: MTKView {
    private let commandQueue: MTLCommandQueue
    private let ciContext = ImageFilterRendering.sharedContext
    private let imageService: ImageService

    private var textLayerView: DesignView?
    private var backgroundLayerView: DesignView?
    private var layerViewSize: CGSize = .zero

    private var textImage: CIImage?
    private var backgroundImage: CIImage?
    private var backgroundKey: String?

    private var design: Design?
    private var interfaceStyle: UIUserInterfaceStyle = .unspecified
    private var rasterScale: CGFloat = 2

    private var composedImage: CIImage?

    init?(imageService: ImageService) {
        guard let device = ImageFilterRendering.metalDevice,
              let queue = device.makeCommandQueue() else { return nil }
        self.commandQueue = queue
        self.imageService = imageService
        super.init(frame: .zero, device: device)

        framebufferOnly = false
        isPaused = true
        enableSetNeedsDisplay = true
        isOpaque = false
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Update

    func update(design: Design, userInterfaceStyle: UIUserInterfaceStyle, displayScale: CGFloat) {
        self.design = design
        self.interfaceStyle = userInterfaceStyle
        // Match generateImage's raster density so filter radii (blur, bloom,
        // halftone…) read identically in preview and export.
        self.rasterScale = max(1, displayScale)

        let layerSize = CGSize(
            width: design.width / design.pixelationScale,
            height: design.height / design.pixelationScale
        )
        if layerSize != layerViewSize || textLayerView == nil {
            layerViewSize = layerSize
            let frame = CGRect(origin: .zero, size: layerSize)
            textLayerView = DesignView(frame: frame, imageService: imageService)
            backgroundLayerView = DesignView(frame: frame, imageService: imageService)
            backgroundKey = nil
        }

        updateTextLayer(for: design)
        updateBackgroundLayer(for: design)
        compose()
    }

    private func renderedText(for design: Design) -> String {
        // The export path lowercases on the blur/Catalyst branch only; mirror it.
        #if targetEnvironment(macCatalyst)
        return design.text.localizedLowercase
        #else
        return design.blur >= 1 ? design.text.localizedLowercase : design.text
        #endif
    }

    private func updateTextLayer(for design: Design) {
        guard let textLayerView else { return }
        textLayerView.overrideUserInterfaceStyle = interfaceStyle
        // Clear background + no image: this layer is only text + scratch strokes.
        textLayerView.configure(
            with: renderedText(for: design),
            backgroundColor: .clear,
            fontName: design.fontName,
            fontSize: design.fontSize / design.pixelationScale,
            stretch: design.stretch,
            imageName: nil,
            design: design
        ) { _ in }
        textLayerView.layoutIfNeeded()
        textImage = rasterize(textLayerView)
    }

    private func backgroundCacheKey(for design: Design) -> String {
        "\(design.backgroundColor.toHexString())|\(design.backgroundImageKey ?? "")|"
            + "\(design.backgroundImageFilters.cacheKeyFragment())|\(design.backgroundScale)|"
            + "\(design.backgroundFlipHorizontal)|\(design.backgroundFlipVertical)|"
            + "\(design.backgroundBlur)|\(design.backgroundAlpha)|"
            + "\(Int(design.width))x\(Int(design.height))|\(design.pixelationScale)|"
            + "\(interfaceStyle.rawValue)|\(rasterScale)"
    }

    private func updateBackgroundLayer(for design: Design) {
        guard let backgroundLayerView else { return }
        let key = backgroundCacheKey(for: design)
        guard key != backgroundKey else { return }
        backgroundKey = key

        backgroundLayerView.overrideUserInterfaceStyle = interfaceStyle
        var backgroundDesign = design
        backgroundDesign.scratchIntensity = 0 // scratch belongs to the text layer
        backgroundLayerView.configure(
            with: "",
            backgroundColor: design.backgroundColor,
            fontName: design.fontName,
            fontSize: design.fontSize / design.pixelationScale,
            stretch: design.stretch,
            imageName: design.backgroundImageKey,
            design: backgroundDesign
        ) { [weak self] configuredView in
            guard let self, key == self.backgroundKey else { return }
            configuredView.layoutIfNeeded()
            self.backgroundImage = self.rasterize(configuredView)
            self.compose()
        }
    }

    private func rasterize(_ layerView: DesignView) -> CIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = rasterScale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: layerView.bounds.size, format: format)
        let image = renderer.image { ctx in
            layerView.layer.render(in: ctx.cgContext)
        }
        guard let cgImage = image.cgImage else { return nil }
        return CIImage(cgImage: cgImage)
    }

    // MARK: - Compose + draw

    private func compose() {
        guard let design else { return }

        let layerExtent = CGRect(
            origin: .zero,
            size: CGSize(width: layerViewSize.width * rasterScale, height: layerViewSize.height * rasterScale)
        )

        // Until the async background raster lands, fall back to the flat color.
        var composed = backgroundImage
            ?? CIImage(color: CIColor(color: design.backgroundColor)).cropped(to: layerExtent)
        if let textImage {
            composed = textImage.composited(over: composed)
        }

        let pixelation = design.pixelationScale
        if pixelation != 1 {
            // Same nearest-neighbor up-scale as fastScaled/scaled(by:).
            composed = composed
                .samplingNearest()
                .transformed(by: CGAffineTransform(scaleX: pixelation, y: pixelation))
        }

        if design.blur >= 1 {
            composed = composed.applyingGaussianBlur(design.blur, extent: composed.extent.integral)
        }

        composed = composed.applyingDesignFilters(design.mainImageFilters, extent: composed.extent.integral)

        composedImage = composed
        setNeedsDisplay()
    }

    /// Test hook: reads the composed graph back to CPU so tests can compare it
    /// against the generateImage export path. The display path never does this.
    func composedImageForTesting() -> UIImage? {
        guard let composedImage,
              let cgImage = ciContext.createCGImage(composedImage, from: composedImage.extent.integral) else {
            return nil
        }
        return UIImage(cgImage: cgImage, scale: rasterScale, orientation: .up)
    }

    override func draw(_ rect: CGRect) {
        guard let image = composedImage,
              image.extent.width > 0, image.extent.height > 0,
              drawableSize.width > 0, drawableSize.height > 0,
              let drawable = currentDrawable,
              let commandBuffer = commandQueue.makeCommandBuffer() else { return }

        let bounds = CGRect(origin: .zero, size: drawableSize)

        // Aspect-fit into the drawable, letterbox transparent.
        let fitScale = min(bounds.width / image.extent.width, bounds.height / image.extent.height)
        var positioned = image.transformed(by: CGAffineTransform(scaleX: fitScale, y: fitScale))
        positioned = positioned.transformed(by: CGAffineTransform(
            translationX: (bounds.width - positioned.extent.width) / 2 - positioned.extent.minX,
            y: (bounds.height - positioned.extent.height) / 2 - positioned.extent.minY
        ))

        // Empirically verified on-device: CIContext.render into an MTKView
        // drawable displays CI's bottom-left origin upright — no flip needed.
        let flipped = positioned
            .composited(over: CIImage(color: .clear).cropped(to: bounds))

        ciContext.render(
            flipped,
            to: drawable.texture,
            commandBuffer: commandBuffer,
            bounds: bounds,
            colorSpace: CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
        )

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
