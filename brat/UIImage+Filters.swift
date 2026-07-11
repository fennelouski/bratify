//
//  UIImage+Filters.swift
//  brat
//
//  Created by Nathan Fennel on 8/5/24.
//

import UIKit
import Metal

enum ImageFilterRendering {
    static let metalDevice: MTLDevice? = MTLCreateSystemDefaultDevice()

    static let sharedContext: CIContext = {
        if let device = metalDevice {
            return CIContext(mtlDevice: device)
        }
        return CIContext(options: nil)
    }()
}

private extension UIImage {
    /// Core Image input with orientation applied; extent matches visible pixels.
    func orientedCIImage() -> CIImage? {
        CIImage(image: self)?.oriented(.up)
    }

    func renderCIImage(_ ciImage: CIImage, toExtent extent: CGRect, in context: CIContext) -> UIImage? {
        let cropped = ciImage.cropped(to: extent)
        guard let cgImage = context.createCGImage(cropped, from: extent) else { return nil }
        return UIImage(cgImage: cgImage, scale: scale, orientation: .up)
    }
}

extension UIImage {
    func fastScaled(
        by scale: CGFloat,
        flipHorizontal: Bool = false,
        flipVertical: Bool = false,
        blur: CGFloat = 0
    ) -> UIImage? {
        guard let cgImage = self.cgImage else { return nil }
        let size = CGSize(width: self.size.width * scale, height: self.size.height * scale)

        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        if flipHorizontal {
            context.translateBy(x: size.width, y: 0)
            context.scaleBy(x: -1.0, y: 1.0)
        }

        if !flipVertical {
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0)
        }

        context.interpolationQuality = .none
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if blur >= 1, let scaledImage = scaledImage {
            return scaledImage.applyBlur(blur)
        }

        return scaledImage
    }

    func applyBlur(_ blur: CGFloat) -> UIImage? {
        guard let inputImage = orientedCIImage() else { return nil }

        let sourceExtent = inputImage.extent.integral
        return renderCIImage(
            inputImage.applyingGaussianBlur(blur, extent: sourceExtent),
            toExtent: sourceExtent,
            in: ImageFilterRendering.sharedContext
        )
    }

    func applyFilters(_ settings: ImageFilterSettings) -> UIImage? {
        guard let inputImage = orientedCIImage() else { return nil }

        let sourceExtent = inputImage.extent.integral
        return renderCIImage(
            inputImage.applyingDesignFilters(settings, extent: sourceExtent),
            toExtent: sourceExtent,
            in: ImageFilterRendering.sharedContext
        )
    }
}

extension CIImage {
    func applyingGaussianBlur(_ blur: CGFloat, extent sourceExtent: CGRect) -> CIImage {
        guard let filter = CIFilter(name: "CIGaussianBlur") else { return self }
        filter.setValue(clampedToExtent(), forKey: kCIInputImageKey)
        filter.setValue(blur, forKey: kCIInputRadiusKey)
        guard let outputImage = filter.outputImage else { return self }
        return outputImage.cropped(to: sourceExtent)
    }

    /// The full main-image adjustment chain, kept as a lazy CIImage graph so
    /// callers can either read it back (export/cache) or render it straight to
    /// a Metal drawable (live preview).
    func applyingDesignFilters(_ settings: ImageFilterSettings, extent sourceExtent: CGRect) -> CIImage {
        var ciImage = self

        if let photoEffect = settings.photoEffect,
           let filter = CIFilter(name: photoEffect.ciFilterName) {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            if let output = filter.outputImage {
                ciImage = output
            }
        }

        let needsColorControls = settings.brightness != 0 || settings.contrast != 1 || settings.saturation != 1
        if needsColorControls, let filter = CIFilter(name: "CIColorControls") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(settings.brightness, forKey: kCIInputBrightnessKey)
            filter.setValue(settings.contrast, forKey: kCIInputContrastKey)
            filter.setValue(settings.saturation, forKey: kCIInputSaturationKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if settings.vibrance != 0, let filter = CIFilter(name: "CIVibrance") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(settings.vibrance, forKey: "inputAmount")
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if settings.hue != 0, let filter = CIFilter(name: "CIHueAdjust") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(settings.hue * .pi / 180, forKey: kCIInputAngleKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if settings.exposure != 0, let filter = CIFilter(name: "CIExposureAdjust") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(settings.exposure, forKey: kCIInputEVKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if settings.gamma != 1, let filter = CIFilter(name: "CIGammaAdjust") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(settings.gamma, forKey: "inputPower")
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if settings.colorTemperature != 6500 || settings.colorTint != 0,
           let filter = CIFilter(name: "CITemperatureAndTint") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIVector(x: 6500, y: 0), forKey: "inputNeutral")
            filter.setValue(CIVector(x: settings.colorTemperature, y: settings.colorTint), forKey: "inputTargetNeutral")
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if settings.highlightAmount != 1 || settings.shadowAmount != 0,
           let filter = CIFilter(name: "CIHighlightShadowAdjust") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(settings.highlightAmount, forKey: "inputHighlightAmount")
            filter.setValue(settings.shadowAmount, forKey: "inputShadowAmount")
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if settings.sepia != 0, let filter = CIFilter(name: "CISepiaTone") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(settings.sepia, forKey: kCIInputIntensityKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if settings.duotoneIntensity > 0, let filter = CIFilter(name: "CIColorMonochrome") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIColor(color: UIColor(hexString: settings.duotoneColorHex)), forKey: kCIInputColorKey)
            filter.setValue(settings.duotoneIntensity, forKey: kCIInputIntensityKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if settings.monochrome != 0, let filter = CIFilter(name: "CIColorMonochrome") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIColor(color: UIColor.white), forKey: kCIInputColorKey)
            filter.setValue(settings.monochrome, forKey: kCIInputIntensityKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if settings.posterizeLevels >= 2,
           let filter = CIFilter(name: "CIColorPosterize") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(settings.posterizeLevels, forKey: "inputLevels")
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if settings.invert, let filter = CIFilter(name: "CIColorInvert") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if settings.halftone > 0, let filter = CIFilter(name: "CIDotScreen") {
            filter.setValue(
                ciImage.clampedToSourceExtent(sourceExtent),
                forKey: kCIInputImageKey
            )
            filter.setValue(settings.halftone, forKey: "inputWidth")
            filter.setValue(0.7, forKey: "inputSharpness")
            filter.setValue(
                CIVector(x: sourceExtent.midX, y: sourceExtent.midY),
                forKey: kCIInputCenterKey
            )
            if let outputImage = filter.outputImage {
                ciImage = outputImage.cropped(to: sourceExtent)
            }
        }

        if settings.pixelate != 0, let filter = CIFilter(name: "CIPixellate") {
            filter.setValue(
                ciImage.clampedToSourceExtent(sourceExtent),
                forKey: kCIInputImageKey
            )
            filter.setValue(settings.pixelate, forKey: kCIInputScaleKey)
            filter.setValue(
                CIVector(x: sourceExtent.midX, y: sourceExtent.midY),
                forKey: kCIInputCenterKey
            )
            if let outputImage = filter.outputImage {
                ciImage = outputImage.cropped(to: sourceExtent)
            }
        }

        if settings.unsharpMask > 0, let filter = CIFilter(name: "CIUnsharpMask") {
            filter.setValue(
                ciImage.clampedToSourceExtent(sourceExtent),
                forKey: kCIInputImageKey
            )
            filter.setValue(settings.unsharpMask, forKey: kCIInputIntensityKey)
            filter.setValue(2.5, forKey: kCIInputRadiusKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage.cropped(to: sourceExtent)
            }
        }

        if settings.sharpen != 0, let filter = CIFilter(name: "CISharpenLuminance") {
            filter.setValue(
                ciImage.clampedToSourceExtent(sourceExtent),
                forKey: kCIInputImageKey
            )
            filter.setValue(settings.sharpen, forKey: kCIInputSharpnessKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage.cropped(to: sourceExtent)
            }
        }

        if settings.bloom > 0, let filter = CIFilter(name: "CIBloom") {
            filter.setValue(
                ciImage.clampedToSourceExtent(sourceExtent),
                forKey: kCIInputImageKey
            )
            filter.setValue(settings.bloom, forKey: kCIInputIntensityKey)
            filter.setValue(12, forKey: kCIInputRadiusKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage.cropped(to: sourceExtent)
            }
        }

        if settings.grain > 0 {
            ciImage = ciImage.applyingGrain(extent: sourceExtent, intensity: settings.grain) ?? ciImage
        }

        if settings.vignette != 0, let filter = CIFilter(name: "CIVignette") {
            filter.setValue(
                ciImage.clampedToSourceExtent(sourceExtent),
                forKey: kCIInputImageKey
            )
            filter.setValue(settings.vignette, forKey: kCIInputIntensityKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage.cropped(to: sourceExtent)
            }
        }

        return ciImage.cropped(to: sourceExtent)
    }

    /// Replicates edge pixels so filters do not sample transparent/out-of-bounds values.
    private func clampedToSourceExtent(_ extent: CGRect) -> CIImage {
        clampedToExtent().cropped(to: extent)
    }

    private func applyingGrain(extent: CGRect, intensity: CGFloat) -> CIImage? {
        guard let noiseFilter = CIFilter(name: "CIRandomGenerator"),
              let noise = noiseFilter.outputImage else {
            return nil
        }

        let croppedNoise = noise.cropped(to: extent)
        guard let matrix = CIFilter(name: "CIColorMatrix") else { return nil }
        matrix.setValue(croppedNoise, forKey: kCIInputImageKey)
        matrix.setValue(CIVector(x: 0, y: 0, z: 0, w: intensity * 0.35), forKey: "inputAVector")

        guard let grainImage = matrix.outputImage,
              let blend = CIFilter(name: "CISourceAtopCompositing") else {
            return nil
        }
        blend.setValue(grainImage, forKey: kCIInputImageKey)
        blend.setValue(self, forKey: kCIInputBackgroundImageKey)
        return blend.outputImage?.cropped(to: extent)
    }
}
