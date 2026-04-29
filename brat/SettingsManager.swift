import UIKit

enum GallerySortOrder: String, CaseIterable {
    case newestFirst
    case oldestFirst
    case lastModified

    var displayName: String {
        switch self {
        case .newestFirst: return NSLocalizedString("Newest First", comment: "Sort option: newest designs shown first")
        case .oldestFirst: return NSLocalizedString("Oldest First", comment: "Sort option: oldest designs shown first")
        case .lastModified: return NSLocalizedString("Last Modified", comment: "Sort option: recently edited designs shown first")
        }
    }
}

class SettingsManager {
    // Thread-safe access pattern
    private let queue = DispatchQueue(
        label: "\(#file)",
        attributes: .concurrent
    )

    // UserDefaults keys
    private enum UserDefaultsKeys: String {
        case wordsPerMinute
        case preferredFontSize
        case preferredFontName
        case selectedTheme
        case histogramAlpha
        case stretch
        case blur
        case saveWithoutTitle
        case autocorrectionEnabled
        case showLabels
        case backgroundColorHex
        case textColorHex
        case pixelationScale
        case xDimension
        case yDimension
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
        case backgroundScale
        case backgroundFlipHorizontal
        case backgroundFlipVertical
        case backgroundBlur
        case backgroundAlpha
        case recentBackgroundColors
        case gallerySortOrder
        case forceLowercase
        case confirmBeforeDeleting
    }
    
    // Properties with default values and persistence
    var wordsPerMinute: Int {
        get {
            queue.sync {
                UserDefaults.standard.integer(forKey: UserDefaultsKeys.wordsPerMinute.rawValue) == 0 ? 300 : UserDefaults.standard.integer(forKey: UserDefaultsKeys.wordsPerMinute.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.wordsPerMinute.rawValue)
            }
        }
    }
    
    var preferredFontSize: Double {
        get {
            queue.sync {
                UserDefaults.standard.double(forKey: UserDefaultsKeys.preferredFontSize.rawValue) == 0 ? 100 : UserDefaults.standard.double(forKey: UserDefaultsKeys.preferredFontSize.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.preferredFontSize.rawValue)
            }
        }
    }
    
    var preferredFontName: String {
        get {
            queue.sync {
                UserDefaults.standard.string(forKey: UserDefaultsKeys.preferredFontName.rawValue) ?? "Arial"
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.preferredFontName.rawValue)
            }
        }
    }
    
    var selectedTheme: ThemeModel? {
        get {
            queue.sync {
                if let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.selectedTheme.rawValue) {
                    return try? JSONDecoder().decode(ThemeModel.self, from: data)
                }
                return .charliXCXBold
            }
        }
        set {
            queue.async(flags: .barrier) {
                if let theme = newValue, let data = try? JSONEncoder().encode(theme) {
                    UserDefaults.standard.set(data, forKey: UserDefaultsKeys.selectedTheme.rawValue)
                } else {
                    UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.selectedTheme.rawValue)
                }
            }
        }
    }
    
    var pixelationScale: Double {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.pixelationScale.rawValue)
                return savedValue == 0 ? 5 : savedValue
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.pixelationScale.rawValue)
            }
        }
    }
    
    var xDimension: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.float(forKey: UserDefaultsKeys.xDimension.rawValue)
                return CGFloat(savedValue == 0 ? 512 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.xDimension.rawValue)
            }
        }
    }

    var yDimension: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.float(forKey: UserDefaultsKeys.yDimension.rawValue)
                return CGFloat(savedValue == 0 ? 512 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.yDimension.rawValue)
            }
        }
    }

    var stretch: Double {
        get {
            queue.sync {
                let stretch = UserDefaults.standard.double(forKey: UserDefaultsKeys.stretch.rawValue)
                return stretch == 0 ? 0.1 : stretch
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.stretch.rawValue)
            }
        }
    }
    
    var blur: Double {
        get {
            queue.sync {
                let blur = UserDefaults.standard.double(forKey: UserDefaultsKeys.blur.rawValue)
                return blur == 0 ? 0.001 : blur
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.blur.rawValue)
            }
        }
    }

    var brightness: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.brightness.rawValue)
                return CGFloat(savedValue == 0 ? 0.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.brightness.rawValue)
            }
        }
    }

    var contrast: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.contrast.rawValue)
                return CGFloat(savedValue == 0 ? 1.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.contrast.rawValue)
            }
        }
    }

    var saturation: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.saturation.rawValue)
                return CGFloat(savedValue == 0 ? 1.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.saturation.rawValue)
            }
        }
    }

    var exposure: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.exposure.rawValue)
                return CGFloat(savedValue == 0 ? 0.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.exposure.rawValue)
            }
        }
    }

    var gamma: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.gamma.rawValue)
                return CGFloat(savedValue == 0 ? 1.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.gamma.rawValue)
            }
        }
    }

    var sepia: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.sepia.rawValue)
                return CGFloat(savedValue == 0 ? 0.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.sepia.rawValue)
            }
        }
    }

    var invert: Bool {
        get {
            queue.sync {
                UserDefaults.standard.bool(forKey: UserDefaultsKeys.invert.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.invert.rawValue)
            }
        }
    }

    var pixelate: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.pixelate.rawValue)
                return CGFloat(savedValue == 0 ? 0.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.pixelate.rawValue)
            }
        }
    }

    var sharpen: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.sharpen.rawValue)
                return CGFloat(savedValue == 0 ? 0.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.sharpen.rawValue)
            }
        }
    }

    var monochrome: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.monochrome.rawValue)
                return CGFloat(savedValue == 0 ? 0.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.monochrome.rawValue)
            }
        }
    }

    var vignette: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.vignette.rawValue)
                return CGFloat(savedValue == 0 ? 0.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.vignette.rawValue)
            }
        }
    }

    var backgroundBrightness: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.backgroundBrightness.rawValue)
                return CGFloat(savedValue == 0 ? 0.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.backgroundBrightness.rawValue)
            }
        }
    }

    var backgroundContrast: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.backgroundContrast.rawValue)
                return CGFloat(savedValue == 0 ? 1.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.backgroundContrast.rawValue)
            }
        }
    }

    var backgroundSaturation: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.backgroundSaturation.rawValue)
                return CGFloat(savedValue == 0 ? 1.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.backgroundSaturation.rawValue)
            }
        }
    }

    var backgroundExposure: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.backgroundExposure.rawValue)
                return CGFloat(savedValue == 0 ? 0.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.backgroundExposure.rawValue)
            }
        }
    }

    var backgroundGamma: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.backgroundGamma.rawValue)
                return CGFloat(savedValue == 0 ? 1.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.backgroundGamma.rawValue)
            }
        }
    }

    var backgroundSepia: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.backgroundSepia.rawValue)
                return CGFloat(savedValue == 0 ? 0.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.backgroundSepia.rawValue)
            }
        }
    }

    var backgroundInvert: Bool {
        get {
            queue.sync {
                UserDefaults.standard.bool(forKey: UserDefaultsKeys.backgroundInvert.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.backgroundInvert.rawValue)
            }
        }
    }

    var backgroundPixelate: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.backgroundPixelate.rawValue)
                return CGFloat(savedValue == 0 ? 0.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.backgroundPixelate.rawValue)
            }
        }
    }

    var backgroundSharpen: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.backgroundSharpen.rawValue)
                return CGFloat(savedValue == 0 ? 0.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.backgroundSharpen.rawValue)
            }
        }
    }

    var backgroundMonochrome: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.backgroundMonochrome.rawValue)
                return CGFloat(savedValue == 0 ? 0.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.backgroundMonochrome.rawValue)
            }
        }
    }

    var backgroundVignette: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.backgroundVignette.rawValue)
                return CGFloat(savedValue == 0 ? 0.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.backgroundVignette.rawValue)
            }
        }
    }

    var backgroundScale: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.backgroundScale.rawValue)
                return CGFloat(savedValue == 0 ? 1.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.backgroundScale.rawValue)
            }
        }
    }

    var backgroundFlipHorizontal: Bool {
        get {
            queue.sync {
                UserDefaults.standard.bool(forKey: UserDefaultsKeys.backgroundFlipHorizontal.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.backgroundFlipHorizontal.rawValue)
            }
        }
    }

    var backgroundFlipVertical: Bool {
        get {
            queue.sync {
                UserDefaults.standard.bool(forKey: UserDefaultsKeys.backgroundFlipVertical.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.backgroundFlipVertical.rawValue)
            }
        }
    }

    var backgroundBlur: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.backgroundBlur.rawValue)
                return CGFloat(savedValue == 0 ? 0.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.backgroundBlur.rawValue)
            }
        }
    }

    var backgroundAlpha: CGFloat {
        get {
            queue.sync {
                let savedValue = UserDefaults.standard.double(forKey: UserDefaultsKeys.backgroundAlpha.rawValue)
                return CGFloat(savedValue == 0 ? 1.0 : savedValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(Double(newValue), forKey: UserDefaultsKeys.backgroundAlpha.rawValue)
            }
        }
    }

    var recentBackgroundColors: [String] {
        get {
            queue.sync {
                UserDefaults.standard.stringArray(forKey: UserDefaultsKeys.recentBackgroundColors.rawValue) ?? []
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.recentBackgroundColors.rawValue)
            }
        }
    }

    var gallerySortOrder: GallerySortOrder {
        get {
            queue.sync {
                if let raw = UserDefaults.standard.string(forKey: UserDefaultsKeys.gallerySortOrder.rawValue),
                   let order = GallerySortOrder(rawValue: raw) {
                    return order
                }
                return .newestFirst
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaultsKeys.gallerySortOrder.rawValue)
            }
        }
    }

    func addRecentBackgroundColor(_ color: UIColor) {
        let hex = color.toHexString()
        var recents = recentBackgroundColors.filter { $0 != hex }
        recents.insert(hex, at: 0)
        recentBackgroundColors = Array(recents.prefix(8))
    }

    var saveWithoutTitle: Bool {
        get {
            queue.sync {
                UserDefaults.standard.bool(forKey: UserDefaultsKeys.saveWithoutTitle.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.saveWithoutTitle.rawValue)
            }
        }
    }
    
    var forceLowercase: Bool {
        get {
            queue.sync {
                if UserDefaults.standard.object(forKey: UserDefaultsKeys.forceLowercase.rawValue) == nil {
                    return true
                }
                return UserDefaults.standard.bool(forKey: UserDefaultsKeys.forceLowercase.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.forceLowercase.rawValue)
            }
        }
    }

    var confirmBeforeDeleting: Bool {
        get {
            queue.sync {
                if UserDefaults.standard.object(forKey: UserDefaultsKeys.confirmBeforeDeleting.rawValue) == nil {
                    return true
                }
                return UserDefaults.standard.bool(forKey: UserDefaultsKeys.confirmBeforeDeleting.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.confirmBeforeDeleting.rawValue)
            }
        }
    }

    var autocorrectionEnabled: Bool {
        get {
            queue.sync {
                UserDefaults.standard.bool(forKey: UserDefaultsKeys.autocorrectionEnabled.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.autocorrectionEnabled.rawValue)
            }
        }
    }
    
    var showLabels: Bool {
        get {
            queue.sync {
                if UserDefaults.standard.object(forKey: UserDefaultsKeys.showLabels.rawValue) == nil {
                    #if targetEnvironment(macCatalyst)
                    return true
                    #else
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        if let model = UIDevice.current.modelIdentifier, model.hasPrefix("iPad") && !model.contains("iPad5,1") && !model.contains("iPad5,2") && !model.contains("iPad11,1") && !model.contains("iPad11,2") {
                            return true
                        }
                    }
                    return false
                    #endif
                }
                return UserDefaults.standard.bool(forKey: UserDefaultsKeys.showLabels.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.showLabels.rawValue)
            }
        }
    }

    var backgroundColorHex: String {
        get {
            queue.sync {
                guard let colorHex = UserDefaults.standard.string(forKey: UserDefaultsKeys.backgroundColorHex.rawValue) else {
                    return "#36a241"
                }
                return colorHex
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.backgroundColorHex.rawValue)
            }
        }
    }

    var textColorHex: String {
        get {
            queue.sync {
                UserDefaults.standard.string(forKey: UserDefaultsKeys.textColorHex.rawValue) ?? "#FFFFFF"
            }
        }
        set {
            queue.async(flags: .barrier) {
                UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.textColorHex.rawValue)
            }
        }
    }
}
