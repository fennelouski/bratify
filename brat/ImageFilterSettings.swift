//
//  ImageFilterSettings.swift
//  brat
//

import UIKit

/// Built-in CIPhotoEffect-style looks applied as a single filter pass.
enum FilterPhotoEffect: String, Codable, CaseIterable, Identifiable {
    case instant
    case fade
    case noir
    case chrome
    case process
    case transfer
    case tonal

    var id: String { rawValue }

    var ciFilterName: String {
        switch self {
        case .instant: return "CIPhotoEffectInstant"
        case .fade: return "CIPhotoEffectFade"
        case .noir: return "CIPhotoEffectNoir"
        case .chrome: return "CIPhotoEffectChrome"
        case .process: return "CIPhotoEffectProcess"
        case .transfer: return "CIPhotoEffectTransfer"
        case .tonal: return "CIPhotoEffectTonal"
        }
    }

    var displayName: String {
        switch self {
        case .instant: return NSLocalizedString("Instant", comment: "Photo effect preset name")
        case .fade: return NSLocalizedString("Fade", comment: "Photo effect preset name")
        case .noir: return NSLocalizedString("Noir", comment: "Photo effect preset name")
        case .chrome: return NSLocalizedString("Chrome", comment: "Photo effect preset name")
        case .process: return NSLocalizedString("Process", comment: "Photo effect preset name")
        case .transfer: return NSLocalizedString("Transfer", comment: "Photo effect preset name")
        case .tonal: return NSLocalizedString("Tonal", comment: "Photo effect preset name")
        }
    }
}

/// Core Image adjustment bundle for main or background image passes.
struct ImageFilterSettings: Codable, Equatable {
    var brightness: CGFloat = 0
    var contrast: CGFloat = 1
    var saturation: CGFloat = 1
    var exposure: CGFloat = 0
    var gamma: CGFloat = 1
    var sepia: CGFloat = 0
    var invert: Bool = false
    var pixelate: CGFloat = 0
    var sharpen: CGFloat = 0
    var monochrome: CGFloat = 0
    var vignette: CGFloat = 0

    /// Hue rotation in degrees (−180…180).
    var hue: CGFloat = 0
    /// `CIHighlightShadowAdjust` highlight amount; 1 is neutral.
    var highlightAmount: CGFloat = 1
    var shadowAmount: CGFloat = 0
    /// Film grain intensity 0…1.
    var grain: CGFloat = 0
    var bloom: CGFloat = 0
    /// Duotone mix 0…1.
    var duotoneIntensity: CGFloat = 0
    var duotoneColorHex: String = "8ACE00"
    /// `CIVibrance` amount (−1…1).
    var vibrance: CGFloat = 0

    /// Posterize level count; 0 disables.
    var posterizeLevels: CGFloat = 0
    /// Neutral daylight reference for `CITemperatureAndTint`.
    var colorTemperature: CGFloat = 6500
    var colorTint: CGFloat = 0
    var photoEffect: FilterPhotoEffect?
    var halftone: CGFloat = 0
    var unsharpMask: CGFloat = 0

    static let `default` = ImageFilterSettings()

    var isDefault: Bool {
        self == .default
    }

    /// Stable fragment for design cache keys.
    func cacheKeyFragment() -> String {
        var parts: [String] = []
        parts.append("\(Int(brightness * 100))")
        parts.append("\(Int(contrast * 100))")
        parts.append("\(Int(saturation * 100))")
        parts.append("\(Int(exposure * 100))")
        parts.append("\(Int(gamma * 100))")
        parts.append("\(Int(sepia * 100))")
        parts.append(invert ? "1" : "0")
        parts.append("\(Int(pixelate * 100))")
        parts.append("\(Int(sharpen * 100))")
        parts.append("\(Int(monochrome * 100))")
        parts.append("\(Int(vignette * 100))")
        parts.append("\(Int(hue))")
        parts.append("\(Int(highlightAmount * 100))")
        parts.append("\(Int(shadowAmount * 100))")
        parts.append("\(Int(grain * 100))")
        parts.append("\(Int(bloom * 100))")
        parts.append("\(Int(duotoneIntensity * 100))")
        parts.append(duotoneColorHex)
        parts.append("\(Int(vibrance * 100))")
        parts.append("\(Int(posterizeLevels))")
        parts.append("\(Int(colorTemperature))")
        parts.append("\(Int(colorTint))")
        parts.append(photoEffect?.rawValue ?? "")
        parts.append("\(Int(halftone * 100))")
        parts.append("\(Int(unsharpMask * 100))")
        return parts.joined()
    }
}

extension Design {
    var mainImageFilters: ImageFilterSettings {
        get {
            ImageFilterSettings(
                brightness: brightness,
                contrast: contrast,
                saturation: saturation,
                exposure: exposure,
                gamma: gamma,
                sepia: sepia,
                invert: invert,
                pixelate: pixelate,
                sharpen: sharpen,
                monochrome: monochrome,
                vignette: vignette,
                hue: hue,
                highlightAmount: highlightAmount,
                shadowAmount: shadowAmount,
                grain: grain,
                bloom: bloom,
                duotoneIntensity: duotoneIntensity,
                duotoneColorHex: duotoneColorHex,
                vibrance: vibrance,
                posterizeLevels: posterizeLevels,
                colorTemperature: colorTemperature,
                colorTint: colorTint,
                photoEffect: photoEffect,
                halftone: halftone,
                unsharpMask: unsharpMask
            )
        }
        set {
            applyMainImageFilters(newValue)
        }
    }

    var backgroundImageFilters: ImageFilterSettings {
        get {
            ImageFilterSettings(
                brightness: backgroundBrightness,
                contrast: backgroundContrast,
                saturation: backgroundSaturation,
                exposure: backgroundExposure,
                gamma: backgroundGamma,
                sepia: backgroundSepia,
                invert: backgroundInvert,
                pixelate: backgroundPixelate,
                sharpen: backgroundSharpen,
                monochrome: backgroundMonochrome,
                vignette: backgroundVignette,
                hue: backgroundHue,
                highlightAmount: backgroundHighlightAmount,
                shadowAmount: backgroundShadowAmount,
                grain: backgroundGrain,
                bloom: backgroundBloom,
                duotoneIntensity: backgroundDuotoneIntensity,
                duotoneColorHex: backgroundDuotoneColorHex,
                vibrance: backgroundVibrance,
                posterizeLevels: backgroundPosterizeLevels,
                colorTemperature: backgroundColorTemperature,
                colorTint: backgroundColorTint,
                photoEffect: backgroundPhotoEffect,
                halftone: backgroundHalftone,
                unsharpMask: backgroundUnsharpMask
            )
        }
        set {
            applyBackgroundImageFilters(newValue)
        }
    }

}
