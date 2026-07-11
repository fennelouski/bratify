import UIKit

struct Design: Codable {
    var text: String
    var backgroundColor: UIColor
    var textColor: UIColor = .white
    var usesAutomaticTextColor: Bool = false
    var creationDate: Date
    var modifiedDate: Date
    var fontName: String
    var fontSize: CGFloat
    var pixelationScale: CGFloat
    var id: UUID
    var stretch: CGFloat = 0.2
    var blur: CGFloat = 0.0
    var width: CGFloat = 512.0
    var height: CGFloat = 512.0
    
    // Core Image filters
    var brightness: CGFloat = 0.0
    var contrast: CGFloat = 1.0
    var saturation: CGFloat = 1.0
    var exposure: CGFloat = 0.0
    var gamma: CGFloat = 1.0
    var sepia: CGFloat = 0.0
    var invert: Bool = false
    var pixelate: CGFloat = 0.0
    var sharpen: CGFloat = 0.0
    var monochrome: CGFloat = 0.0
    var vignette: CGFloat = 0.0
    var hue: CGFloat = 0.0
    var highlightAmount: CGFloat = 1.0
    var shadowAmount: CGFloat = 0.0
    var grain: CGFloat = 0.0
    var bloom: CGFloat = 0.0
    var duotoneIntensity: CGFloat = 0.0
    var duotoneColorHex: String = "8ACE00"
    var vibrance: CGFloat = 0.0
    var posterizeLevels: CGFloat = 0.0
    var colorTemperature: CGFloat = 6500.0
    var colorTint: CGFloat = 0.0
    var photoEffect: FilterPhotoEffect?
    var halftone: CGFloat = 0.0
    var unsharpMask: CGFloat = 0.0
    
    // Background image properties
    var backgroundImageKey: String?
    var backgroundScale: CGFloat = 1.0
    var backgroundFlipHorizontal: Bool = false
    var backgroundFlipVertical: Bool = false
    var backgroundBlur: CGFloat = 0.0
    var backgroundAlpha: CGFloat = 1.0
    var backgroundBrightness: CGFloat = 0.0
    var backgroundContrast: CGFloat = 1.0
    var backgroundSaturation: CGFloat = 1.0
    var backgroundExposure: CGFloat = 0.0
    var backgroundGamma: CGFloat = 1.0
    var backgroundSepia: CGFloat = 0.0
    var backgroundInvert: Bool = false
    var backgroundPixelate: CGFloat = 0.0
    var backgroundSharpen: CGFloat = 0.0
    var backgroundMonochrome: CGFloat = 0.0
    var backgroundVignette: CGFloat = 0.0
    var backgroundHue: CGFloat = 0.0
    var backgroundHighlightAmount: CGFloat = 1.0
    var backgroundShadowAmount: CGFloat = 0.0
    var backgroundGrain: CGFloat = 0.0
    var backgroundBloom: CGFloat = 0.0
    var backgroundDuotoneIntensity: CGFloat = 0.0
    var backgroundDuotoneColorHex: String = "8ACE00"
    var backgroundVibrance: CGFloat = 0.0
    var backgroundPosterizeLevels: CGFloat = 0.0
    var backgroundColorTemperature: CGFloat = 6500.0
    var backgroundColorTint: CGFloat = 0.0
    var backgroundPhotoEffect: FilterPhotoEffect?
    var backgroundHalftone: CGFloat = 0.0
    var backgroundUnsharpMask: CGFloat = 0.0

    enum CodingKeys: String, CodingKey {
        case text
        case backgroundColor
        case textColor
        case usesAutomaticTextColor
        case creationDate
        case modifiedDate
        case fontName
        case fontSize
        case pixelationScale
        case id
        case stretch
        case blur
        case width
        case height
        case brightness
        case contrast
        case saturation
        case exposure
        case gamma
        case sepia
        case invert
        case pixelate
        case sharpen
        case monochrome
        case vignette
        case hue
        case highlightAmount
        case shadowAmount
        case grain
        case bloom
        case duotoneIntensity
        case duotoneColorHex
        case vibrance
        case posterizeLevels
        case colorTemperature
        case colorTint
        case photoEffect
        case halftone
        case unsharpMask
        case backgroundImageKey
        case backgroundScale
        case backgroundFlipHorizontal
        case backgroundFlipVertical
        case backgroundBlur
        case backgroundAlpha
        case backgroundBrightness
        case backgroundContrast
        case backgroundSaturation
        case backgroundExposure
        case backgroundGamma
        case backgroundSepia
        case backgroundInvert
        case backgroundPixelate
        case backgroundSharpen
        case backgroundMonochrome
        case backgroundVignette
        case backgroundHue
        case backgroundHighlightAmount
        case backgroundShadowAmount
        case backgroundGrain
        case backgroundBloom
        case backgroundDuotoneIntensity
        case backgroundDuotoneColorHex
        case backgroundVibrance
        case backgroundPosterizeLevels
        case backgroundColorTemperature
        case backgroundColorTint
        case backgroundPhotoEffect
        case backgroundHalftone
        case backgroundUnsharpMask
    }

    // Encoding the UIColor as a hex string
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(backgroundColor.toHexString(), forKey: .backgroundColor)
        try container.encode(textColor.toHexString(), forKey: .textColor)
        try container.encode(usesAutomaticTextColor, forKey: .usesAutomaticTextColor)
        try container.encode(creationDate, forKey: .creationDate)
        try container.encode(modifiedDate, forKey: .modifiedDate)
        try container.encode(fontName, forKey: .fontName)
        try container.encode(fontSize, forKey: .fontSize)
        try container.encode(pixelationScale, forKey: .pixelationScale)
        try container.encode(id, forKey: .id)
        try container.encode(stretch, forKey: .stretch)
        try container.encode(blur, forKey: .blur)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(brightness, forKey: .brightness)
        try container.encode(contrast, forKey: .contrast)
        try container.encode(saturation, forKey: .saturation)
        try container.encode(exposure, forKey: .exposure)
        try container.encode(gamma, forKey: .gamma)
        try container.encode(sepia, forKey: .sepia)
        try container.encode(invert, forKey: .invert)
        try container.encode(pixelate, forKey: .pixelate)
        try container.encode(sharpen, forKey: .sharpen)
        try container.encode(monochrome, forKey: .monochrome)
        try container.encode(vignette, forKey: .vignette)
        try container.encode(hue, forKey: .hue)
        try container.encode(highlightAmount, forKey: .highlightAmount)
        try container.encode(shadowAmount, forKey: .shadowAmount)
        try container.encode(grain, forKey: .grain)
        try container.encode(bloom, forKey: .bloom)
        try container.encode(duotoneIntensity, forKey: .duotoneIntensity)
        try container.encode(duotoneColorHex, forKey: .duotoneColorHex)
        try container.encode(vibrance, forKey: .vibrance)
        try container.encode(posterizeLevels, forKey: .posterizeLevels)
        try container.encode(colorTemperature, forKey: .colorTemperature)
        try container.encode(colorTint, forKey: .colorTint)
        try container.encode(photoEffect, forKey: .photoEffect)
        try container.encode(halftone, forKey: .halftone)
        try container.encode(unsharpMask, forKey: .unsharpMask)
        try container.encode(backgroundImageKey, forKey: .backgroundImageKey)
        try container.encode(backgroundScale, forKey: .backgroundScale)
        try container.encode(backgroundFlipHorizontal, forKey: .backgroundFlipHorizontal)
        try container.encode(backgroundFlipVertical, forKey: .backgroundFlipVertical)
        try container.encode(backgroundBlur, forKey: .backgroundBlur)
        try container.encode(backgroundAlpha, forKey: .backgroundAlpha)
        try container.encode(backgroundBrightness, forKey: .backgroundBrightness)
        try container.encode(backgroundContrast, forKey: .backgroundContrast)
        try container.encode(backgroundSaturation, forKey: .backgroundSaturation)
        try container.encode(backgroundExposure, forKey: .backgroundExposure)
        try container.encode(backgroundGamma, forKey: .backgroundGamma)
        try container.encode(backgroundSepia, forKey: .backgroundSepia)
        try container.encode(backgroundInvert, forKey: .backgroundInvert)
        try container.encode(backgroundPixelate, forKey: .backgroundPixelate)
        try container.encode(backgroundSharpen, forKey: .backgroundSharpen)
        try container.encode(backgroundMonochrome, forKey: .backgroundMonochrome)
        try container.encode(backgroundVignette, forKey: .backgroundVignette)
        try container.encode(backgroundHue, forKey: .backgroundHue)
        try container.encode(backgroundHighlightAmount, forKey: .backgroundHighlightAmount)
        try container.encode(backgroundShadowAmount, forKey: .backgroundShadowAmount)
        try container.encode(backgroundGrain, forKey: .backgroundGrain)
        try container.encode(backgroundBloom, forKey: .backgroundBloom)
        try container.encode(backgroundDuotoneIntensity, forKey: .backgroundDuotoneIntensity)
        try container.encode(backgroundDuotoneColorHex, forKey: .backgroundDuotoneColorHex)
        try container.encode(backgroundVibrance, forKey: .backgroundVibrance)
        try container.encode(backgroundPosterizeLevels, forKey: .backgroundPosterizeLevels)
        try container.encode(backgroundColorTemperature, forKey: .backgroundColorTemperature)
        try container.encode(backgroundColorTint, forKey: .backgroundColorTint)
        try container.encode(backgroundPhotoEffect, forKey: .backgroundPhotoEffect)
        try container.encode(backgroundHalftone, forKey: .backgroundHalftone)
        try container.encode(backgroundUnsharpMask, forKey: .backgroundUnsharpMask)
    }

    init(
        text: String,
        backgroundColor: UIColor,
        textColor: UIColor = .white,
        usesAutomaticTextColor: Bool = true,
        creationDate: Date,
        modifiedDate: Date? = nil,
        fontName: String,
        fontSize: CGFloat,
        pixelationScale: CGFloat,
        stretch: CGFloat = 0.2,
        blur: CGFloat = 0.0,
        width: CGFloat = 512.0,
        height: CGFloat = 512.0,
        brightness: CGFloat = 0.0,
        contrast: CGFloat = 1.0,
        saturation: CGFloat = 1.0,
        exposure: CGFloat = 0.0,
        gamma: CGFloat = 1.0,
        sepia: CGFloat = 0.0,
        invert: Bool = false,
        pixelate: CGFloat = 0.0,
        sharpen: CGFloat = 0.0,
        monochrome: CGFloat = 0.0,
        vignette: CGFloat = 0.0,
        hue: CGFloat = 0.0,
        highlightAmount: CGFloat = 1.0,
        shadowAmount: CGFloat = 0.0,
        grain: CGFloat = 0.0,
        bloom: CGFloat = 0.0,
        duotoneIntensity: CGFloat = 0.0,
        duotoneColorHex: String = "8ACE00",
        vibrance: CGFloat = 0.0,
        posterizeLevels: CGFloat = 0.0,
        colorTemperature: CGFloat = 6500.0,
        colorTint: CGFloat = 0.0,
        photoEffect: FilterPhotoEffect? = nil,
        halftone: CGFloat = 0.0,
        unsharpMask: CGFloat = 0.0,
        backgroundImageKey: String? = nil,
        backgroundScale: CGFloat = 1.0,
        backgroundFlipHorizontal: Bool = false,
        backgroundFlipVertical: Bool = false,
        backgroundBlur: CGFloat = 0.0,
        backgroundAlpha: CGFloat = 1.0,
        backgroundBrightness: CGFloat = 0.0,
        backgroundContrast: CGFloat = 1.0,
        backgroundSaturation: CGFloat = 1.0,
        backgroundExposure: CGFloat = 0.0,
        backgroundGamma: CGFloat = 1.0,
        backgroundSepia: CGFloat = 0.0,
        backgroundInvert: Bool = false,
        backgroundPixelate: CGFloat = 0.0,
        backgroundSharpen: CGFloat = 0.0,
        backgroundMonochrome: CGFloat = 0.0,
        backgroundVignette: CGFloat = 0.0,
        backgroundHue: CGFloat = 0.0,
        backgroundHighlightAmount: CGFloat = 1.0,
        backgroundShadowAmount: CGFloat = 0.0,
        backgroundGrain: CGFloat = 0.0,
        backgroundBloom: CGFloat = 0.0,
        backgroundDuotoneIntensity: CGFloat = 0.0,
        backgroundDuotoneColorHex: String = "8ACE00",
        backgroundVibrance: CGFloat = 0.0,
        backgroundPosterizeLevels: CGFloat = 0.0,
        backgroundColorTemperature: CGFloat = 6500.0,
        backgroundColorTint: CGFloat = 0.0,
        backgroundPhotoEffect: FilterPhotoEffect? = nil,
        backgroundHalftone: CGFloat = 0.0,
        backgroundUnsharpMask: CGFloat = 0.0,
        id: UUID = UUID()
    ) {
        self.text = text
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.usesAutomaticTextColor = usesAutomaticTextColor
        self.creationDate = creationDate
        self.modifiedDate = modifiedDate ?? creationDate
        self.fontName = fontName
        self.fontSize = fontSize
        self.pixelationScale = pixelationScale
        self.id = id
        self.stretch = stretch
        self.blur = blur
        self.width = width
        self.height = height
        self.brightness = brightness
        self.contrast = contrast
        self.saturation = saturation
        self.exposure = exposure
        self.gamma = gamma
        self.sepia = sepia
        self.invert = invert
        self.pixelate = pixelate
        self.sharpen = sharpen
        self.monochrome = monochrome
        self.vignette = vignette
        self.hue = hue
        self.highlightAmount = highlightAmount
        self.shadowAmount = shadowAmount
        self.grain = grain
        self.bloom = bloom
        self.duotoneIntensity = duotoneIntensity
        self.duotoneColorHex = duotoneColorHex
        self.vibrance = vibrance
        self.posterizeLevels = posterizeLevels
        self.colorTemperature = colorTemperature
        self.colorTint = colorTint
        self.photoEffect = photoEffect
        self.halftone = halftone
        self.unsharpMask = unsharpMask
        self.backgroundImageKey = backgroundImageKey
        self.backgroundScale = backgroundScale
        self.backgroundFlipHorizontal = backgroundFlipHorizontal
        self.backgroundFlipVertical = backgroundFlipVertical
        self.backgroundBlur = backgroundBlur
        self.backgroundAlpha = backgroundAlpha
        self.backgroundBrightness = backgroundBrightness
        self.backgroundContrast = backgroundContrast
        self.backgroundSaturation = backgroundSaturation
        self.backgroundExposure = backgroundExposure
        self.backgroundGamma = backgroundGamma
        self.backgroundSepia = backgroundSepia
        self.backgroundInvert = backgroundInvert
        self.backgroundPixelate = backgroundPixelate
        self.backgroundSharpen = backgroundSharpen
        self.backgroundMonochrome = backgroundMonochrome
        self.backgroundVignette = backgroundVignette
        self.backgroundHue = backgroundHue
        self.backgroundHighlightAmount = backgroundHighlightAmount
        self.backgroundShadowAmount = backgroundShadowAmount
        self.backgroundGrain = backgroundGrain
        self.backgroundBloom = backgroundBloom
        self.backgroundDuotoneIntensity = backgroundDuotoneIntensity
        self.backgroundDuotoneColorHex = backgroundDuotoneColorHex
        self.backgroundVibrance = backgroundVibrance
        self.backgroundPosterizeLevels = backgroundPosterizeLevels
        self.backgroundColorTemperature = backgroundColorTemperature
        self.backgroundColorTint = backgroundColorTint
        self.backgroundPhotoEffect = backgroundPhotoEffect
        self.backgroundHalftone = backgroundHalftone
        self.backgroundUnsharpMask = backgroundUnsharpMask
    }

    // Decoding the UIColor from a hex string
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedText = try container.decode(String.self, forKey: .text)
        if decodedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw DecodingError.dataCorruptedError(forKey: .text, in: container, debugDescription: "Text cannot be empty or whitespace.")
        }
        text = decodedText
        let colorHex = try container.decode(String.self, forKey: .backgroundColor)
        backgroundColor = UIColor(hexString: colorHex)
        let textColorHex = try container.decodeIfPresent(String.self, forKey: .textColor)
        textColor = textColorHex.map { UIColor(hexString: $0) } ?? .white
        usesAutomaticTextColor = try container.decodeIfPresent(Bool.self, forKey: .usesAutomaticTextColor) ?? false
        creationDate = try container.decode(Date.self, forKey: .creationDate)
        modifiedDate = try container.decodeIfPresent(Date.self, forKey: .modifiedDate) ?? creationDate
        fontName = try container.decode(String.self, forKey: .fontName)
        fontSize = try container.decode(CGFloat.self, forKey: .fontSize)
        pixelationScale = try container.decode(CGFloat.self, forKey: .pixelationScale)
        id = try container.decode(UUID.self, forKey: .id)
        stretch = try container.decodeIfPresent(CGFloat.self, forKey: .stretch) ?? 0.2
        blur = try container.decodeIfPresent(CGFloat.self, forKey: .blur) ?? 0.0
        width = try container.decodeIfPresent(CGFloat.self, forKey: .width) ?? 512.0
        height = try container.decodeIfPresent(CGFloat.self, forKey: .height) ?? 512.0
        brightness = try container.decodeIfPresent(CGFloat.self, forKey: .brightness) ?? 0.0
        contrast = try container.decodeIfPresent(CGFloat.self, forKey: .contrast) ?? 1.0
        saturation = try container.decodeIfPresent(CGFloat.self, forKey: .saturation) ?? 1.0
        exposure = try container.decodeIfPresent(CGFloat.self, forKey: .exposure) ?? 0.0
        gamma = try container.decodeIfPresent(CGFloat.self, forKey: .gamma) ?? 1.0
        sepia = try container.decodeIfPresent(CGFloat.self, forKey: .sepia) ?? 0.0
        invert = try container.decodeIfPresent(Bool.self, forKey: .invert) ?? false
        pixelate = try container.decodeIfPresent(CGFloat.self, forKey: .pixelate) ?? 0.0
        sharpen = try container.decodeIfPresent(CGFloat.self, forKey: .sharpen) ?? 0.0
        monochrome = try container.decodeIfPresent(CGFloat.self, forKey: .monochrome) ?? 0.0
        vignette = try container.decodeIfPresent(CGFloat.self, forKey: .vignette) ?? 0.0
        hue = try container.decodeIfPresent(CGFloat.self, forKey: .hue) ?? 0.0
        highlightAmount = try container.decodeIfPresent(CGFloat.self, forKey: .highlightAmount) ?? 1.0
        shadowAmount = try container.decodeIfPresent(CGFloat.self, forKey: .shadowAmount) ?? 0.0
        grain = try container.decodeIfPresent(CGFloat.self, forKey: .grain) ?? 0.0
        bloom = try container.decodeIfPresent(CGFloat.self, forKey: .bloom) ?? 0.0
        duotoneIntensity = try container.decodeIfPresent(CGFloat.self, forKey: .duotoneIntensity) ?? 0.0
        duotoneColorHex = try container.decodeIfPresent(String.self, forKey: .duotoneColorHex) ?? "8ACE00"
        vibrance = try container.decodeIfPresent(CGFloat.self, forKey: .vibrance) ?? 0.0
        posterizeLevels = try container.decodeIfPresent(CGFloat.self, forKey: .posterizeLevels) ?? 0.0
        colorTemperature = try container.decodeIfPresent(CGFloat.self, forKey: .colorTemperature) ?? 6500.0
        colorTint = try container.decodeIfPresent(CGFloat.self, forKey: .colorTint) ?? 0.0
        photoEffect = try container.decodeIfPresent(FilterPhotoEffect.self, forKey: .photoEffect)
        halftone = try container.decodeIfPresent(CGFloat.self, forKey: .halftone) ?? 0.0
        unsharpMask = try container.decodeIfPresent(CGFloat.self, forKey: .unsharpMask) ?? 0.0
        backgroundImageKey = try container.decodeIfPresent(String.self, forKey: .backgroundImageKey)
        backgroundScale = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundScale) ?? 1.0
        backgroundFlipHorizontal = try container.decodeIfPresent(Bool.self, forKey: .backgroundFlipHorizontal) ?? false
        backgroundFlipVertical = try container.decodeIfPresent(Bool.self, forKey: .backgroundFlipVertical) ?? false
        backgroundBlur = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundBlur) ?? 0.0
        backgroundAlpha = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundAlpha) ?? 1.0
        backgroundBrightness = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundBrightness) ?? 0.0
        backgroundContrast = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundContrast) ?? 1.0
        backgroundSaturation = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundSaturation) ?? 1.0
        backgroundExposure = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundExposure) ?? 0.0
        backgroundGamma = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundGamma) ?? 1.0
        backgroundSepia = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundSepia) ?? 0.0
        backgroundInvert = try container.decodeIfPresent(Bool.self, forKey: .backgroundInvert) ?? false
        backgroundPixelate = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundPixelate) ?? 0.0
        backgroundSharpen = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundSharpen) ?? 0.0
        backgroundMonochrome = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundMonochrome) ?? 0.0
        backgroundVignette = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundVignette) ?? 0.0
        backgroundHue = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundHue) ?? 0.0
        backgroundHighlightAmount = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundHighlightAmount) ?? 1.0
        backgroundShadowAmount = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundShadowAmount) ?? 0.0
        backgroundGrain = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundGrain) ?? 0.0
        backgroundBloom = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundBloom) ?? 0.0
        backgroundDuotoneIntensity = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundDuotoneIntensity) ?? 0.0
        backgroundDuotoneColorHex = try container.decodeIfPresent(String.self, forKey: .backgroundDuotoneColorHex) ?? "8ACE00"
        backgroundVibrance = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundVibrance) ?? 0.0
        backgroundPosterizeLevels = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundPosterizeLevels) ?? 0.0
        backgroundColorTemperature = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundColorTemperature) ?? 6500.0
        backgroundColorTint = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundColorTint) ?? 0.0
        backgroundPhotoEffect = try container.decodeIfPresent(FilterPhotoEffect.self, forKey: .backgroundPhotoEffect)
        backgroundHalftone = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundHalftone) ?? 0.0
        backgroundUnsharpMask = try container.decodeIfPresent(CGFloat.self, forKey: .backgroundUnsharpMask) ?? 0.0
    }

    func resolvedTextColor(for traits: UITraitCollection, view: UIView? = nil) -> UIColor {
        DesignTextColor.resolved(self, traits: traits, view: view)
    }

    func resolvedTextColor(for userInterfaceStyle: UIUserInterfaceStyle) -> UIColor {
        DesignTextColor.resolved(self, userInterfaceStyle: userInterfaceStyle)
    }

    func imageCacheKey(
        userInterfaceStyle style: UIUserInterfaceStyle = .unspecified,
        traitCollection: UITraitCollection? = nil,
        view: UIView? = nil
    ) -> String {
        var key = description
        if usesAutomaticTextColor {
            let resolved = DesignTextColor.resolvedUserInterfaceStyle(
                style,
                traitCollection: traitCollection,
                view: view
            )
            key += "-appearance-\(resolved.rawValue)"
        }
        return key
    }

    var description: String {
        var descriptionString = "\(text)\(backgroundColor.toHexString())\(textColor.toHexString())\(usesAutomaticTextColor ? 1 : 0)\(fontName)\(Int(fontSize))\(Int(pixelationScale))\(Int(stretch*25))\(Int(blur))\(Int(width))\(Int(height))\(mainImageFilters.cacheKeyFragment())\(backgroundImageKey ?? "")"
        
        if let backgroundImageKey = backgroundImageKey {
            descriptionString += "\(backgroundImageKey)\(backgroundImageFilters.cacheKeyFragment())\(Int(backgroundScale*100))\(backgroundFlipHorizontal ? 1 : 0)\(backgroundFlipVertical ? 1 : 0)\(Int(backgroundBlur*100))\(Int(backgroundAlpha*100))"
        }
        
        return descriptionString
    }
}

extension Design {
    static var empty: Design {
        .init(
            text: "",
            backgroundColor: .blue,
            usesAutomaticTextColor: true,
            creationDate: Date(),
            fontName: "",
            fontSize: 64,
            pixelationScale: 1
        )
    }
}
