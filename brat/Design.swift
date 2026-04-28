import UIKit

struct Design: Codable {
    var text: String
    var backgroundColor: UIColor
    var textColor: UIColor = .white
    var creationDate: Date
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

    enum CodingKeys: String, CodingKey {
        case text
        case backgroundColor
        case textColor
        case creationDate
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
    }

    // Encoding the UIColor as a hex string
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(backgroundColor.toHexString(), forKey: .backgroundColor)
        try container.encode(textColor.toHexString(), forKey: .textColor)
        try container.encode(creationDate, forKey: .creationDate)
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
    }

    init(
        text: String,
        backgroundColor: UIColor,
        textColor: UIColor = .white,
        creationDate: Date,
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
        id: UUID = UUID()
    ) {
        self.text = text
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.creationDate = creationDate
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
        creationDate = try container.decode(Date.self, forKey: .creationDate)
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
    }

    var description: String {
        var descriptionString = "\(text)\(backgroundColor.toHexString())\(textColor.toHexString())\(fontName)\(Int(fontSize))\(Int(pixelationScale))\(Int(stretch*25))\(Int(blur))\(Int(width))\(Int(height))\(Int(brightness*100))\(Int(contrast*100))\(Int(saturation*100))\(Int(exposure*100))\(Int(gamma*100))\(Int(sepia*100))\(invert ? 1 : 0)\(Int(pixelate*100))\(Int(sharpen*100))\(Int(monochrome*100))\(Int(vignette*100))\(backgroundImageKey ?? "")"
        
        if let backgroundImageKey = backgroundImageKey {
            descriptionString += "\(backgroundImageKey)\(Int(backgroundBrightness*100))\(Int(backgroundContrast*100))\(Int(backgroundSaturation*100))\(Int(backgroundExposure*100))\(Int(backgroundGamma*100))\(Int(backgroundSepia*100))\(backgroundInvert ? 1 : 0)\(Int(backgroundPixelate*100))\(Int(backgroundSharpen*100))\(Int(backgroundMonochrome*100))\(Int(backgroundVignette*100))\(Int(backgroundScale*100))\(backgroundFlipHorizontal ? 1 : 0)\(backgroundFlipVertical ? 1 : 0)\(Int(backgroundBlur*100))\(Int(backgroundAlpha*100))"
        }
        
        return descriptionString
    }
}

extension Design {
    static var empty: Design {
        .init(
            text: "",
            backgroundColor: .blue,
            creationDate: Date(),
            fontName: "",
            fontSize: 64,
            pixelationScale: 1
        )
    }
}
