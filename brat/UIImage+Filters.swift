//
//  UIImage+Filters.swift
//  brat
//
//  Created by Nathan Fennel on 8/5/24.
//

import UIKit

private enum ImageFilterRendering {
    static let sharedContext = CIContext(options: nil)
}

private extension UIImage {
    /// Core Image input with orientation applied; extent matches visible pixels.
    func orientedCIImage() -> CIImage? {
        CIImage(image: self)?.oriented(.up)
    }

    /// Replicates edge pixels so filters do not sample transparent/out-of-bounds values.
    func clampedToSourceExtent(_ image: CIImage, extent: CGRect) -> CIImage {
        image.clampedToExtent().cropped(to: extent)
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
        let size = CGSize(width: self.size.width * scale, height: self.size.height * scale)

        UIGraphicsBeginImageContextWithOptions(size, true, self.scale)
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
        context.draw(self.cgImage!, in: CGRect(origin: .zero, size: size))

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
        let context = ImageFilterRendering.sharedContext

        guard let filter = CIFilter(name: "CIGaussianBlur") else { return nil }
        filter.setValue(inputImage.clampedToExtent(), forKey: kCIInputImageKey)
        filter.setValue(blur, forKey: kCIInputRadiusKey)

        guard let outputImage = filter.outputImage else { return nil }
        return renderCIImage(
            outputImage.cropped(to: sourceExtent),
            toExtent: sourceExtent,
            in: context
        )
    }

    func applyFilters(_ settings: ImageFilterSettings) -> UIImage? {
        applyFilters(
            brightness: settings.brightness,
            contrast: settings.contrast,
            saturation: settings.saturation,
            exposure: settings.exposure,
            gamma: settings.gamma,
            sepia: settings.sepia,
            invert: settings.invert,
            pixelate: settings.pixelate,
            sharpen: settings.sharpen,
            monochrome: settings.monochrome,
            vignette: settings.vignette,
            hue: settings.hue,
            highlightAmount: settings.highlightAmount,
            shadowAmount: settings.shadowAmount,
            grain: settings.grain,
            bloom: settings.bloom,
            duotoneIntensity: settings.duotoneIntensity,
            duotoneColorHex: settings.duotoneColorHex,
            vibrance: settings.vibrance,
            posterizeLevels: settings.posterizeLevels,
            colorTemperature: settings.colorTemperature,
            colorTint: settings.colorTint,
            photoEffect: settings.photoEffect,
            halftone: settings.halftone,
            unsharpMask: settings.unsharpMask
        )
    }

    func applyFilters(
        brightness: CGFloat,
        contrast: CGFloat,
        saturation: CGFloat,
        exposure: CGFloat,
        gamma: CGFloat,
        sepia: CGFloat,
        invert: Bool,
        pixelate: CGFloat,
        sharpen: CGFloat,
        monochrome: CGFloat,
        vignette: CGFloat,
        hue: CGFloat = 0,
        highlightAmount: CGFloat = 1,
        shadowAmount: CGFloat = 0,
        grain: CGFloat = 0,
        bloom: CGFloat = 0,
        duotoneIntensity: CGFloat = 0,
        duotoneColorHex: String = "8ACE00",
        vibrance: CGFloat = 0,
        posterizeLevels: CGFloat = 0,
        colorTemperature: CGFloat = 6500,
        colorTint: CGFloat = 0,
        photoEffect: FilterPhotoEffect? = nil,
        halftone: CGFloat = 0,
        unsharpMask: CGFloat = 0
    ) -> UIImage? {
        guard let inputImage = orientedCIImage() else { return nil }

        let sourceExtent = inputImage.extent.integral
        let context = ImageFilterRendering.sharedContext
        var ciImage = inputImage

        if let photoEffect,
           let filter = CIFilter(name: photoEffect.ciFilterName) {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            if let output = filter.outputImage {
                ciImage = output
            }
        }

        let needsColorControls = brightness != 0 || contrast != 1 || saturation != 1
        if needsColorControls, let filter = CIFilter(name: "CIColorControls") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(brightness, forKey: kCIInputBrightnessKey)
            filter.setValue(contrast, forKey: kCIInputContrastKey)
            filter.setValue(saturation, forKey: kCIInputSaturationKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if vibrance != 0, let filter = CIFilter(name: "CIVibrance") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(vibrance, forKey: "inputAmount")
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if hue != 0, let filter = CIFilter(name: "CIHueAdjust") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(hue * .pi / 180, forKey: kCIInputAngleKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if exposure != 0, let filter = CIFilter(name: "CIExposureAdjust") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(exposure, forKey: kCIInputEVKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if gamma != 1, let filter = CIFilter(name: "CIGammaAdjust") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(gamma, forKey: "inputPower")
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if colorTemperature != 6500 || colorTint != 0,
           let filter = CIFilter(name: "CITemperatureAndTint") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIVector(x: 6500, y: 0), forKey: "inputNeutral")
            filter.setValue(CIVector(x: colorTemperature, y: colorTint), forKey: "inputTargetNeutral")
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if highlightAmount != 1 || shadowAmount != 0,
           let filter = CIFilter(name: "CIHighlightShadowAdjust") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(highlightAmount, forKey: "inputHighlightAmount")
            filter.setValue(shadowAmount, forKey: "inputShadowAmount")
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if sepia != 0, let filter = CIFilter(name: "CISepiaTone") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(sepia, forKey: kCIInputIntensityKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if duotoneIntensity > 0, let filter = CIFilter(name: "CIColorMonochrome") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIColor(color: UIColor(hexString: duotoneColorHex)), forKey: kCIInputColorKey)
            filter.setValue(duotoneIntensity, forKey: kCIInputIntensityKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if monochrome != 0, let filter = CIFilter(name: "CIColorMonochrome") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(CIColor(color: UIColor.white), forKey: kCIInputColorKey)
            filter.setValue(monochrome, forKey: kCIInputIntensityKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if posterizeLevels >= 2,
           let filter = CIFilter(name: "CIColorPosterize") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            filter.setValue(posterizeLevels, forKey: "inputLevels")
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if invert, let filter = CIFilter(name: "CIColorInvert") {
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage
            }
        }

        if halftone > 0, let filter = CIFilter(name: "CIDotScreen") {
            filter.setValue(
                clampedToSourceExtent(ciImage, extent: sourceExtent),
                forKey: kCIInputImageKey
            )
            filter.setValue(halftone, forKey: "inputWidth")
            filter.setValue(0.7, forKey: "inputSharpness")
            filter.setValue(
                CIVector(x: sourceExtent.midX, y: sourceExtent.midY),
                forKey: kCIInputCenterKey
            )
            if let outputImage = filter.outputImage {
                ciImage = outputImage.cropped(to: sourceExtent)
            }
        }

        if pixelate != 0, let filter = CIFilter(name: "CIPixellate") {
            filter.setValue(
                clampedToSourceExtent(ciImage, extent: sourceExtent),
                forKey: kCIInputImageKey
            )
            filter.setValue(pixelate, forKey: kCIInputScaleKey)
            filter.setValue(
                CIVector(x: sourceExtent.midX, y: sourceExtent.midY),
                forKey: kCIInputCenterKey
            )
            if let outputImage = filter.outputImage {
                ciImage = outputImage.cropped(to: sourceExtent)
            }
        }

        if unsharpMask > 0, let filter = CIFilter(name: "CIUnsharpMask") {
            filter.setValue(
                clampedToSourceExtent(ciImage, extent: sourceExtent),
                forKey: kCIInputImageKey
            )
            filter.setValue(unsharpMask, forKey: kCIInputIntensityKey)
            filter.setValue(2.5, forKey: kCIInputRadiusKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage.cropped(to: sourceExtent)
            }
        }

        if sharpen != 0, let filter = CIFilter(name: "CISharpenLuminance") {
            filter.setValue(
                clampedToSourceExtent(ciImage, extent: sourceExtent),
                forKey: kCIInputImageKey
            )
            filter.setValue(sharpen, forKey: kCIInputSharpnessKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage.cropped(to: sourceExtent)
            }
        }

        if bloom > 0, let filter = CIFilter(name: "CIBloom") {
            filter.setValue(
                clampedToSourceExtent(ciImage, extent: sourceExtent),
                forKey: kCIInputImageKey
            )
            filter.setValue(bloom, forKey: kCIInputIntensityKey)
            filter.setValue(12, forKey: kCIInputRadiusKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage.cropped(to: sourceExtent)
            }
        }

        if grain > 0 {
            ciImage = applyGrain(to: ciImage, extent: sourceExtent, intensity: grain) ?? ciImage
        }

        if vignette != 0, let filter = CIFilter(name: "CIVignette") {
            filter.setValue(
                clampedToSourceExtent(ciImage, extent: sourceExtent),
                forKey: kCIInputImageKey
            )
            filter.setValue(vignette, forKey: kCIInputIntensityKey)
            if let outputImage = filter.outputImage {
                ciImage = outputImage.cropped(to: sourceExtent)
            }
        }

        return renderCIImage(
            ciImage.cropped(to: sourceExtent),
            toExtent: sourceExtent,
            in: context
        )
    }

    private func applyGrain(to image: CIImage, extent: CGRect, intensity: CGFloat) -> CIImage? {
        guard let noiseFilter = CIFilter(name: "CIRandomGenerator"),
              let noise = noiseFilter.outputImage else {
            return nil
        }

        let croppedNoise = noise.cropped(to: extent)
        guard let matrix = CIFilter(name: "CIColorMatrix") else { return nil }
        matrix.setValue(croppedNoise, forKey: kCIInputImageKey)
        matrix.setValue(CIVector(x: 0, y: 0, z: 0, w: intensity * 0.35), forKey: "inputAVector")

        guard let grainImage = matrix.outputImage,
              let blend = CIFilter(name: "CISourceOverCompositing") else {
            return nil
        }
        blend.setValue(grainImage, forKey: kCIInputImageKey)
        blend.setValue(image, forKey: kCIInputBackgroundImageKey)
        return blend.outputImage?.cropped(to: extent)
    }
}
