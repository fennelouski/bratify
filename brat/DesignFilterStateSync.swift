//
//  DesignFilterStateSync.swift
//  brat
//

import UIKit

extension Design {
    /// Copies main-image filter fields from `settings` into this design.
    mutating func applyMainImageFilters(_ settings: ImageFilterSettings) {
        brightness = settings.brightness
        contrast = settings.contrast
        saturation = settings.saturation
        exposure = settings.exposure
        gamma = settings.gamma
        sepia = settings.sepia
        invert = settings.invert
        pixelate = settings.pixelate
        sharpen = settings.sharpen
        monochrome = settings.monochrome
        vignette = settings.vignette
        hue = settings.hue
        highlightAmount = settings.highlightAmount
        shadowAmount = settings.shadowAmount
        grain = settings.grain
        bloom = settings.bloom
        duotoneIntensity = settings.duotoneIntensity
        duotoneColorHex = settings.duotoneColorHex
        vibrance = settings.vibrance
        posterizeLevels = settings.posterizeLevels
        colorTemperature = settings.colorTemperature
        colorTint = settings.colorTint
        photoEffect = settings.photoEffect
        halftone = settings.halftone
        unsharpMask = settings.unsharpMask
    }

    /// Copies background-image filter fields from `settings` into this design.
    mutating func applyBackgroundImageFilters(_ settings: ImageFilterSettings) {
        backgroundBrightness = settings.brightness
        backgroundContrast = settings.contrast
        backgroundSaturation = settings.saturation
        backgroundExposure = settings.exposure
        backgroundGamma = settings.gamma
        backgroundSepia = settings.sepia
        backgroundInvert = settings.invert
        backgroundPixelate = settings.pixelate
        backgroundSharpen = settings.sharpen
        backgroundMonochrome = settings.monochrome
        backgroundVignette = settings.vignette
        backgroundHue = settings.hue
        backgroundHighlightAmount = settings.highlightAmount
        backgroundShadowAmount = settings.shadowAmount
        backgroundGrain = settings.grain
        backgroundBloom = settings.bloom
        backgroundDuotoneIntensity = settings.duotoneIntensity
        backgroundDuotoneColorHex = settings.duotoneColorHex
        backgroundVibrance = settings.vibrance
        backgroundPosterizeLevels = settings.posterizeLevels
        backgroundColorTemperature = settings.colorTemperature
        backgroundColorTint = settings.colorTint
        backgroundPhotoEffect = settings.photoEffect
        backgroundHalftone = settings.halftone
        backgroundUnsharpMask = settings.unsharpMask
    }
}
