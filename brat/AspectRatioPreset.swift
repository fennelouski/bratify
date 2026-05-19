import Foundation

struct AspectRatioPreset: Equatable {
    enum Category: Equatable {
        case social
        case standard
    }

    let width: Int
    let height: Int
    /// Localization keys joined with ", " for the cell title (one row per unique aspect ratio).
    let titleKeys: [String]
    let category: Category

    init(width: Int, height: Int, titleKey: String, category: Category) {
        self.width = width
        self.height = height
        self.titleKeys = [titleKey]
        self.category = category
    }

    init(width: Int, height: Int, titleKeys: [String], category: Category) {
        self.width = width
        self.height = height
        self.titleKeys = titleKeys
        self.category = category
    }

    var localizedTitle: String {
        titleKeys
            .map { NSLocalizedString($0, comment: "Aspect ratio preset title") }
            .joined(separator: ", ")
    }

    var ratioLabel: String {
        let simplified = CanvasDimensions.simplifiedRatio(width: width, height: height)
        return "\(simplified.0):\(simplified.1)"
    }
}

extension AspectRatioPreset {
    /// One preset per unique ratio; labels list every platform that uses it.
    static let socialPresets: [AspectRatioPreset] = [
        AspectRatioPreset(
            width: 9,
            height: 16,
            titleKeys: ["Instagram Story", "TikTok", "Snapchat"],
            category: .social
        ),
        AspectRatioPreset(
            width: 16,
            height: 9,
            titleKeys: ["YouTube", "X Post"],
            category: .social
        ),
        AspectRatioPreset(
            width: 4,
            height: 5,
            titleKeys: ["Instagram Post", "Facebook Post"],
            category: .social
        ),
        AspectRatioPreset(
            width: 1,
            height: 1,
            titleKeys: ["Instagram Square", "X Square"],
            category: .social
        ),
        AspectRatioPreset(width: 2, height: 3, titleKey: "Pinterest Pin", category: .social),
        AspectRatioPreset(width: 191, height: 100, titleKey: "LinkedIn", category: .social),
    ]

    static let standardPresets: [AspectRatioPreset] = [
        AspectRatioPreset(width: 9, height: 21, titleKey: "Ultra Tall", category: .standard),
        AspectRatioPreset(width: 3, height: 4, titleKey: "Portrait", category: .standard),
        AspectRatioPreset(width: 4, height: 3, titleKey: "Landscape", category: .standard),
        AspectRatioPreset(width: 21, height: 9, titleKey: "Ultra Wide", category: .standard),
    ]

    static var allPresets: [AspectRatioPreset] {
        socialPresets + standardPresets
    }
}
