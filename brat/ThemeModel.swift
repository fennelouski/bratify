//
//  ThemeModel.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/15/24.
//

import UIKit

struct ThemeModel: Codable, Hashable, Equatable {
    var name: String
    var description: String?
    var lightModeColors: ColorModel
    var darkModeColors: ColorModel
}

extension [ThemeModel] {
    static var defaults: [ThemeModel] {
        return [
            .charliXCXBold,
            .bratRebel,
            
            .blandTheme1,
            .blandTheme2,
            
            .vibrantTheme1,
            .vibrantTheme2,
            .vibrantTheme3,
            .vibrantTheme4,
            .vibrantTheme5,
            
            .traditionalTheme1,
            .traditionalTheme2,
            .traditionalTheme3,
            
            .newTheme1,
            .newTheme2,
            .forest,
            .lavender,
            .midnight,
            .newTheme6,
            .newTheme7,
            .newTheme8,
            .newTheme9,
            .newTheme10,
            
            .redTheme,
            .orangeTheme,
            .yellowTheme,
            .greenTheme,
            .blueTheme,
            .indigoTheme,
            .violetTheme,
            .pinkTheme
        ]
    }
}

extension ThemeModel {
    static let charliXCXBold = ThemeModel(
        name: "90+10",
        description: NSLocalizedString("Vibrant and edgy", comment: "The name of a color model that uses vibrant colors"),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#000000"), // Black
            backgroundColor: UIColor(hexString: "#8AE234"), // Bright green
            shadowColor: UIColor(hexString: "#2E2E2E"), // Dark gray
            tintColor: UIColor(hexString: "#FF00FF"), // Magenta
            positiveColor: UIColor(hexString: "#FF69B4"), // Hot pink
            destructiveColor: UIColor(hexString: "#FF4500"), // Orange red
            onColor: UIColor(hexString: "#00FFFF") // Cyan
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#FFFFFF"), // White
            backgroundColor: UIColor(hexString: "#121212"), // Almost black
            shadowColor: UIColor(hexString: "#4B0082"), // Indigo
            tintColor: UIColor(hexString: "#FF1493"), // Deep pink
            positiveColor: UIColor(hexString: "#00FF00"), // Lime
            destructiveColor: UIColor(hexString: "#FF6347"), // Tomato
            onColor: UIColor(hexString: "#00CED1") // Dark turquoise
        )
    )

    static let bratRebel = ThemeModel(
        name: "brebel",
        description: NSLocalizedString("Neon and bold", comment: "The name of a color model that uses neon and bold colors"),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#292929"), // Charcoal
            backgroundColor: UIColor(hexString: "#D1FF00"), // Lime green
            shadowColor: UIColor(hexString: "#3C3C3C"), // Dark gray
            tintColor: UIColor(hexString: "#FF00FF"), // Magenta
            positiveColor: UIColor(hexString: "#FF1493"), // Deep pink
            destructiveColor: UIColor(hexString: "#DC143C"), // Crimson
            onColor: UIColor(hexString: "#1E90FF") // Dodger blue
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#E5E5E5"), // Very light gray
            backgroundColor: UIColor(hexString: "#101010"), // Very dark gray
            shadowColor: UIColor(hexString: "#696969"), // Dim gray
            tintColor: UIColor(hexString: "#FF69B4"), // Hot pink
            positiveColor: UIColor(hexString: "#32CD32"), // Lime green
            destructiveColor: UIColor(hexString: "#FF0000"), // Red
            onColor: UIColor(hexString: "#00BFFF") // Deep sky blue
        )
    )
    // Bland Themes
    static let blandTheme1 = ThemeModel(
        name: "Beige",
        description: NSLocalizedString(
            "Subtle and neutral beige",
            comment: "The name of a color model that uses beige, subtle, and neutral colors"
        ),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#5A5A5A"), // Dark gray
            backgroundColor: UIColor(hexString: "#F5F5DC"), // Beige
            shadowColor: UIColor(hexString: "#A9A9A9"), // Dark gray
            tintColor: UIColor(hexString: "#C0C0C0"), // Silver
            positiveColor: UIColor(hexString: "#8FBC8F"), // Dark sea green
            destructiveColor: UIColor(hexString: "#CD5C5C"), // Indian red
            onColor: UIColor(hexString: "#FFE4C4") // Bisque
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#D3D3D3"), // Light gray
            backgroundColor: UIColor(hexString: "#2F4F4F"), // Dark slate gray
            shadowColor: UIColor(hexString: "#696969"), // Dim gray
            tintColor: UIColor(hexString: "#778899"), // Light slate gray
            positiveColor: UIColor(hexString: "#556B2F"), // Dark olive green
            destructiveColor: UIColor(hexString: "#8B0000"), // Dark red
            onColor: UIColor(hexString: "#BC8F8F") // Rosy brown
        )
    )

    static let blandTheme2 = ThemeModel(
        name: "Monochromatic",
        description: NSLocalizedString("Simple and understated monochromatic", comment: "The name of a color model that uses simple monochromatic colors"),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#4B4B4B"), // Dark gray
            backgroundColor: UIColor(hexString: "#DADADA"), // Light gray
            shadowColor: UIColor(hexString: "#8A8A8A"), // Medium gray
            tintColor: UIColor(hexString: "#B0B0B0"), // Light gray
            positiveColor: UIColor(hexString: "#A0A0A0"), // Medium light gray
            destructiveColor: UIColor(hexString: "#7B7B7B"), // Medium dark gray
            onColor: UIColor(hexString: "#C0C0C0") // Silver
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#E0E0E0"), // Very light gray
            backgroundColor: UIColor(hexString: "#3A3A3A"), // Dark gray
            shadowColor: UIColor(hexString: "#5A5A5A"), // Medium dark gray
            tintColor: UIColor(hexString: "#4A4A4A"), // Medium gray
            positiveColor: UIColor(hexString: "#6A6A6A"), // Medium gray
            destructiveColor: UIColor(hexString: "#2A2A2A"), // Very dark gray
            onColor: UIColor(hexString: "#4B4B4B") // Dark gray
        )
    )

    static let blandTheme3 = ThemeModel(
        name: "Soft Almond",
        description: NSLocalizedString("A warm and gentle almond theme.", comment: "The name of a color model that uses a gentle and calming almond color as a base for other colors"),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#6B6B6B"), // Dim gray
            backgroundColor: UIColor(hexString: "#FAEBD7"), // Antique white
            shadowColor: UIColor(hexString: "#A4A4A4"), // Light gray
            tintColor: UIColor(hexString: "#D8D8D8"), // Gainsboro
            positiveColor: UIColor(hexString: "#9ACD32"), // Yellow green
            destructiveColor: UIColor(hexString: "#E9967A"), // Dark salmon
            onColor: UIColor(hexString: "#FFEBCD") // Blanched almond
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#C0C0C0"), // Silver
            backgroundColor: UIColor(hexString: "#2C2C2C"), // Dark charcoal
            shadowColor: UIColor(hexString: "#737373"), // Medium gray
            tintColor: UIColor(hexString: "#A9A9A9"), // Dark gray
            positiveColor: UIColor(hexString: "#808000"), // Olive
            destructiveColor: UIColor(hexString: "#B22222"), // Firebrick
            onColor: UIColor(hexString: "#D2B48C") // Tan
        )
    )

    // Vibrant Themes
    static let vibrantTheme1 = ThemeModel(
        name: "Vibrant 1",
        description: NSLocalizedString("Lively and energetic", comment: "The name of a color model that uses simple monochromatic colors"),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#FFFFFF"), // White
            backgroundColor: UIColor(hexString: "#FF6347"), // Tomato red
            shadowColor: UIColor(hexString: "#000000"), // Black
            tintColor: UIColor(hexString: "#FFD700"), // Gold
            positiveColor: UIColor(hexString: "#32CD32"), // Lime green
            destructiveColor: UIColor(hexString: "#FF4500"), // Orange red
            onColor: UIColor(hexString: "#FF7F50") // Coral
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#FF6347"), // Tomato red
            backgroundColor: UIColor(hexString: "#1C1C1C"), // Very dark gray
            shadowColor: UIColor(hexString: "#FF6347"), // Tomato red
            tintColor: UIColor(hexString: "#FFD700"), // Gold
            positiveColor: UIColor(hexString: "#32CD32"), // Lime green
            destructiveColor: UIColor(hexString: "#FF4500"), // Orange red
            onColor: UIColor(hexString: "#FF7F50") // Coral
        )
    )

    static let vibrantTheme2 = ThemeModel(
        name: "Vibrant 2",
        description: NSLocalizedString("Bright and cheerful", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#FFFFFF"), // White
            backgroundColor: UIColor(hexString: "#4682B4"), // Steel blue
            shadowColor: UIColor(hexString: "#2F4F4F"), // Dark slate gray
            tintColor: UIColor(hexString: "#FFA500"), // Orange
            positiveColor: UIColor(hexString: "#00FF00"), // Green
            destructiveColor: UIColor(hexString: "#FF0000"), // Red
            onColor: UIColor(hexString: "#87CEFA") // Light sky blue
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#4682B4"), // Steel blue
            backgroundColor: UIColor(hexString: "#1C1C1C"), // Very dark gray
            shadowColor: UIColor(hexString: "#4682B4"), // Steel blue
            tintColor: UIColor(hexString: "#FFA500"), // Orange
            positiveColor: UIColor(hexString: "#00FF00"), // Green
            destructiveColor: UIColor(hexString: "#FF0000"), // Red
            onColor: UIColor(hexString: "#87CEFA") // Light sky blue
        )
    )

    static let vibrantTheme3 = ThemeModel(
        name: "Vibrant 3",
        description: NSLocalizedString("Bold and dynamic", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#000000"), // Black
            backgroundColor: UIColor(hexString: "#FFFF00"), // Yellow
            shadowColor: UIColor(hexString: "#8B0000"), // Dark red
            tintColor: UIColor(hexString: "#800080"), // Purple
            positiveColor: UIColor(hexString: "#ADFF2F"), // Green yellow
            destructiveColor: UIColor(hexString: "#FF6347"), // Tomato red
            onColor: UIColor(hexString: "#FFFFE0") // Light yellow
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#FFFF00"), // Yellow
            backgroundColor: UIColor(hexString: "#000000"), // Black
            shadowColor: UIColor(hexString: "#FFFF00"), // Yellow
            tintColor: UIColor(hexString: "#800080"), // Purple
            positiveColor: UIColor(hexString: "#ADFF2F"), // Green yellow
            destructiveColor: UIColor(hexString: "#FF6347"), // Tomato red
            onColor: UIColor(hexString: "#FFFFE0") // Light yellow
        )
    )

    static let vibrantTheme4 = ThemeModel(
        name: "Vibrant 4",
        description: NSLocalizedString("Colorful and playful", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#000000"), // Black
            backgroundColor: UIColor(hexString: "#7CFC00"), // Lawn green
            shadowColor: UIColor(hexString: "#696969"), // Dim gray
            tintColor: UIColor(hexString: "#FF69B4"), // Hot pink
            positiveColor: UIColor(hexString: "#1E90FF"), // Dodger blue
            destructiveColor: UIColor(hexString: "#FF4500"), // Orange red
            onColor: UIColor(hexString: "#98FB98") // Pale green
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#7CFC00"), // Lawn green
            backgroundColor: UIColor(hexString: "#1C1C1C"), // Very dark gray
            shadowColor: UIColor(hexString: "#7CFC00"), // Lawn green
            tintColor: UIColor(hexString: "#FF69B4"), // Hot pink
            positiveColor: UIColor(hexString: "#1E90FF"), // Dodger blue
            destructiveColor: UIColor(hexString: "#FF4500"), // Orange red
            onColor: UIColor(hexString: "#98FB98") // Pale green
        )
    )

    static let vibrantTheme5 = ThemeModel(
        name: "Vibrant 5",
        description: NSLocalizedString("Vivid and striking", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#FFFFFF"), // White
            backgroundColor: UIColor(hexString: "#800080"), // Purple
            shadowColor: UIColor(hexString: "#000000"), // Black
            tintColor: UIColor(hexString: "#32CD32"), // Lime green
            positiveColor: UIColor(hexString: "#00FFFF"), // Cyan
            destructiveColor: UIColor(hexString: "#FF00FF"), // Magenta
            onColor: UIColor(hexString: "#DA70D6") // Orchid
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#800080"), // Purple
            backgroundColor: UIColor(hexString: "#1C1C1C"), // Very dark gray
            shadowColor: UIColor(hexString: "#800080"), // Purple
            tintColor: UIColor(hexString: "#32CD32"), // Lime green
            positiveColor: UIColor(hexString: "#00FFFF"), // Cyan
            destructiveColor: UIColor(hexString: "#FF00FF"), // Magenta
            onColor: UIColor(hexString: "#DA70D6") // Orchid
        )
    )

    // Traditional Themes
    static let traditionalTheme1 = ThemeModel(
        name: "Traditional 1",
        description: NSLocalizedString("Classic and timeless", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#000000"), // Black
            backgroundColor: UIColor(hexString: "#FFFFFF"), // White
            shadowColor: UIColor(hexString: "#A9A9A9"), // Dark gray
            tintColor: UIColor(hexString: "#0000FF"), // Blue
            positiveColor: UIColor(hexString: "#008000"), // Green
            destructiveColor: UIColor(hexString: "#FF0000"), // Red
            onColor: UIColor(hexString: "#F5F5F5") // White smoke
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#FFFFFF"), // White
            backgroundColor: UIColor(hexString: "#000000"), // Black
            shadowColor: UIColor(hexString: "#A9A9A9"), // Dark gray
            tintColor: UIColor(hexString: "#0000FF"), // Blue
            positiveColor: UIColor(hexString: "#008000"), // Green
            destructiveColor: UIColor(hexString: "#FF0000"), // Red
            onColor: UIColor(hexString: "#696969") // Dim gray
        )
    )

    static let traditionalTheme2 = ThemeModel(
        name: "Traditional 2",
        description: NSLocalizedString("Refined and elegant", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#2F4F4F"), // Dark slate gray
            backgroundColor: UIColor(hexString: "#F5DEB3"), // Wheat
            shadowColor: UIColor(hexString: "#A9A9A9"), // Dark gray
            tintColor: UIColor(hexString: "#8B4513"), // Saddle brown
            positiveColor: UIColor(hexString: "#556B2F"), // Dark olive green
            destructiveColor: UIColor(hexString: "#B22222"), // Firebrick
            onColor: UIColor(hexString: "#FFEBCD") // Blanched almond
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#F5DEB3"), // Wheat
            backgroundColor: UIColor(hexString: "#2F4F4F"), // Dark slate gray
            shadowColor: UIColor(hexString: "#A9A9A9"), // Dark gray
            tintColor: UIColor(hexString: "#8B4513"), // Saddle brown
            positiveColor: UIColor(hexString: "#556B2F"), // Dark olive green
            destructiveColor: UIColor(hexString: "#B22222"), // Firebrick
            onColor: UIColor(hexString: "#D2B48C") // Tan
        )
    )

    static let traditionalTheme3 = ThemeModel(
        name: "Traditional 3",
        description: NSLocalizedString("Rich and sophisticated", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#4B0082"), // Indigo
            backgroundColor: UIColor(hexString: "#E6E6FA"), // Lavender
            shadowColor: UIColor(hexString: "#708090"), // Slate gray
            tintColor: UIColor(hexString: "#8B0000"), // Dark red
            positiveColor: UIColor(hexString: "#006400"), // Dark green
            destructiveColor: UIColor(hexString: "#8B0000"), // Dark red
            onColor: UIColor(hexString: "#D8BFD8") // Thistle
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#E6E6FA"), // Lavender
            backgroundColor: UIColor(hexString: "#4B0082"), // Indigo
            shadowColor: UIColor(hexString: "#708090"), // Slate gray
            tintColor: UIColor(hexString: "#8B0000"), // Dark red
            positiveColor: UIColor(hexString: "#006400"), // Dark green
            destructiveColor: UIColor(hexString: "#8B0000"), // Dark red
            onColor: UIColor(hexString: "#DDA0DD") // Plum
        )
    )

    // New Themes
    static let newTheme1 = ThemeModel(
        name: "Ocean Blue",
        description: NSLocalizedString("Refreshing ocean blue", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#FFFFFF"), // White
            backgroundColor: UIColor(hexString: "#1E90FF"), // Dodger blue
            shadowColor: UIColor(hexString: "#00008B"), // Dark blue
            tintColor: UIColor(hexString: "#00BFFF"), // Deep sky blue
            positiveColor: UIColor(hexString: "#00CED1"), // Dark turquoise
            destructiveColor: UIColor(hexString: "#B22222"), // Firebrick
            onColor: UIColor(hexString: "#87CEEB") // Sky blue
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#1E90FF"), // Dodger blue
            backgroundColor: UIColor(hexString: "#000000"), // Black
            shadowColor: UIColor(hexString: "#1E90FF"), // Dodger blue
            tintColor: UIColor(hexString: "#00BFFF"), // Deep sky blue
            positiveColor: UIColor(hexString: "#00CED1"), // Dark turquoise
            destructiveColor: UIColor(hexString: "#B22222"), // Firebrick
            onColor: UIColor(hexString: "#4682B4") // Steel blue
        )
    )

    static let newTheme2 = ThemeModel(
        name: "Sunset",
        description: NSLocalizedString("Warm and inviting sunset", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#FFFFFF"), // White
            backgroundColor: UIColor(hexString: "#FF4500"), // Orange red
            shadowColor: UIColor(hexString: "#8B0000"), // Dark red
            tintColor: UIColor(hexString: "#FF6347"), // Tomato
            positiveColor: UIColor(hexString: "#FFD700"), // Gold
            destructiveColor: UIColor(hexString: "#FF0000"), // Red
            onColor: UIColor(hexString: "#FFA07A") // Light salmon
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#FF4500"), // Orange red
            backgroundColor: UIColor(hexString: "#1C1C1C"), // Very dark gray
            shadowColor: UIColor(hexString: "#FF4500"), // Orange red
            tintColor: UIColor(hexString: "#FF6347"), // Tomato
            positiveColor: UIColor(hexString: "#FFD700"), // Gold
            destructiveColor: UIColor(hexString: "#FF0000"), // Red
            onColor: UIColor(hexString: "#FA8072") // Salmon
        )
    )

    static let forest = ThemeModel(
        name: "Forest",
        description: NSLocalizedString("Deep and tranquil forest", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#000000"), // Black
            backgroundColor: UIColor(hexString: "#228B22"), // Forest green
            shadowColor: UIColor(hexString: "#006400"), // Dark green
            tintColor: UIColor(hexString: "#8FBC8F"), // Dark sea green
            positiveColor: UIColor(hexString: "#32CD32"), // Lime green
            destructiveColor: UIColor(hexString: "#8B0000"), // Dark red
            onColor: UIColor(hexString: "#ADFF2F") // Green yellow
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#228B22"), // Forest green
            backgroundColor: UIColor(hexString: "#000000"), // Black
            shadowColor: UIColor(hexString: "#228B22"), // Forest green
            tintColor: UIColor(hexString: "#8FBC8F"), // Dark sea green
            positiveColor: UIColor(hexString: "#32CD32"), // Lime green
            destructiveColor: UIColor(hexString: "#8B0000"), // Dark red
            onColor: UIColor(hexString: "#7FFF00") // Chartreuse
        )
    )

    static let lavender = ThemeModel(
        name: "Lavender",
        description: NSLocalizedString("Soft and calming lavender", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#4B0082"), // Indigo
            backgroundColor: UIColor(hexString: "#E6E6FA"), // Lavender
            shadowColor: UIColor(hexString: "#8A2BE2"), // Blue violet
            tintColor: UIColor(hexString: "#9370DB"), // Medium purple
            positiveColor: UIColor(hexString: "#8B008B"), // Dark magenta
            destructiveColor: UIColor(hexString: "#FF1493"), // Deep pink
            onColor: UIColor(hexString: "#D8BFD8") // Thistle
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#E6E6FA"), // Lavender
            backgroundColor: UIColor(hexString: "#4B0082"), // Indigo
            shadowColor: UIColor(hexString: "#8A2BE2"), // Blue violet
            tintColor: UIColor(hexString: "#9370DB"), // Medium purple
            positiveColor: UIColor(hexString: "#8B008B"), // Dark magenta
            destructiveColor: UIColor(hexString: "#FF1493"), // Deep pink
            onColor: UIColor(hexString: "#DDA0DD") // Plum
        )
    )

    static let midnight = ThemeModel(
        name: "Midnight",
        description: NSLocalizedString("Mysterious and dark midnight", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#FFFFFF"), // White
            backgroundColor: UIColor(hexString: "#2F4F4F"), // Dark slate gray
            shadowColor: UIColor(hexString: "#000000"), // Black
            tintColor: UIColor(hexString: "#4682B4"), // Steel blue
            positiveColor: UIColor(hexString: "#00BFFF"), // Deep sky blue
            destructiveColor: UIColor(hexString: "#8B0000"), // Dark red
            onColor: UIColor(hexString: "#708090") // Slate gray
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#2F4F4F"), // Dark slate gray
            backgroundColor: UIColor(hexString: "#000000"), // Black
            shadowColor: UIColor(hexString: "#2F4F4F"), // Dark slate gray
            tintColor: UIColor(hexString: "#4682B4"), // Steel blue
            positiveColor: UIColor(hexString: "#00BFFF"), // Deep sky blue
            destructiveColor: UIColor(hexString: "#8B0000"), // Dark red
            onColor: UIColor(hexString: "#5F9EA0") // Cadet blue
        )
    )

    static let newTheme6 = ThemeModel(
        name: "Sunshine",
        description: NSLocalizedString("Bright and sunny", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#000000"), // Black
            backgroundColor: UIColor(hexString: "#FFD700"), // Gold
            shadowColor: UIColor(hexString: "#FFA500"), // Orange
            tintColor: UIColor(hexString: "#FF4500"), // Orange red
            positiveColor: UIColor(hexString: "#32CD32"), // Lime green
            destructiveColor: UIColor(hexString: "#FF0000"), // Red
            onColor: UIColor(hexString: "#FFE4B5") // Moccasin
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#FFD700"), // Gold
            backgroundColor: UIColor(hexString: "#000000"), // Black
            shadowColor: UIColor(hexString: "#FFD700"), // Gold
            tintColor: UIColor(hexString: "#FF4500"), // Orange red
            positiveColor: UIColor(hexString: "#32CD32"), // Lime green
            destructiveColor: UIColor(hexString: "#FF0000"), // Red
            onColor: UIColor(hexString: "#FF8C00") // Dark orange
        )
    )

    static let newTheme7 = ThemeModel(
        name: "Pastel",
        description: NSLocalizedString("Soft and gentle pastel", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#000000"), // Black
            backgroundColor: UIColor(hexString: "#FFDAB9"), // Peach puff
            shadowColor: UIColor(hexString: "#FFE4E1"), // Misty rose
            tintColor: UIColor(hexString: "#FFB6C1"), // Light pink
            positiveColor: UIColor(hexString: "#E6E6FA"), // Lavender
            destructiveColor: UIColor(hexString: "#FF69B4"), // Hot pink
            onColor: UIColor(hexString: "#FFF0F5") // Lavender blush
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#FFDAB9"), // Peach puff
            backgroundColor: UIColor(hexString: "#1C1C1C"), // Very dark gray
            shadowColor: UIColor(hexString: "#FFDAB9"), // Peach puff
            tintColor: UIColor(hexString: "#FFB6C1"), // Light pink
            positiveColor: UIColor(hexString: "#E6E6FA"), // Lavender
            destructiveColor: UIColor(hexString: "#FF69B4"), // Hot pink
            onColor: UIColor(hexString: "#FFC0CB") // Pink
        )
    )

    static let newTheme8 = ThemeModel(
        name: "Citrus",
        description: NSLocalizedString("Fresh and zesty citrus", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#000000"), // Black
            backgroundColor: UIColor(hexString: "#FFD700"), // Gold
            shadowColor: UIColor(hexString: "#FFA500"), // Orange
            tintColor: UIColor(hexString: "#FF4500"), // Orange red
            positiveColor: UIColor(hexString: "#32CD32"), // Lime green
            destructiveColor: UIColor(hexString: "#FF0000"), // Red
            onColor: UIColor(hexString: "#FFFFE0") // Light yellow
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#FFD700"), // Gold
            backgroundColor: UIColor(hexString: "#000000"), // Black
            shadowColor: UIColor(hexString: "#FFD700"), // Gold
            tintColor: UIColor(hexString: "#FF4500"), // Orange red
            positiveColor: UIColor(hexString: "#32CD32"), // Lime green
            destructiveColor: UIColor(hexString: "#FF0000"), // Red
            onColor: UIColor(hexString: "#FFD700") // Gold
        )
    )

    static let newTheme9 = ThemeModel(
        name: "Berry",
        description: NSLocalizedString("Vibrant and juicy berry", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#000000"), // Black
            backgroundColor: UIColor(hexString: "#8A2BE2"), // Blue violet
            shadowColor: UIColor(hexString: "#4B0082"), // Indigo
            tintColor: UIColor(hexString: "#9370DB"), // Medium purple
            positiveColor: UIColor(hexString: "#8B008B"), // Dark magenta
            destructiveColor: UIColor(hexString: "#FF1493"), // Deep pink
            onColor: UIColor(hexString: "#D8BFD8") // Thistle
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#8A2BE2"), // Blue violet
            backgroundColor: UIColor(hexString: "#1C1C1C"), // Very dark gray
            shadowColor: UIColor(hexString: "#8A2BE2"), // Blue violet
            tintColor: UIColor(hexString: "#9370DB"), // Medium purple
            positiveColor: UIColor(hexString: "#8B008B"), // Dark magenta
            destructiveColor: UIColor(hexString: "#FF1493"), // Deep pink
            onColor: UIColor(hexString: "#DDA0DD") // Plum
        )
    )

    static let newTheme10 = ThemeModel(
        name: "Mint",
        description: NSLocalizedString("Cool and refreshing mint", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#000000"), // Black
            backgroundColor: UIColor(hexString: "#98FF98"), // Mint green
            shadowColor: UIColor(hexString: "#2E8B57"), // Sea green
            tintColor: UIColor(hexString: "#3CB371"), // Medium sea green
            positiveColor: UIColor(hexString: "#00FF7F"), // Spring green
            destructiveColor: UIColor(hexString: "#006400"), // Dark green
            onColor: UIColor(hexString: "#F5FFFA") // Mint cream
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#98FF98"), // Mint green
            backgroundColor: UIColor(hexString: "#1C1C1C"), // Very dark gray
            shadowColor: UIColor(hexString: "#98FF98"), // Mint green
            tintColor: UIColor(hexString: "#3CB371"), // Medium sea green
            positiveColor: UIColor(hexString: "#00FF7F"), // Spring green
            destructiveColor: UIColor(hexString: "#006400"), // Dark green
            onColor: UIColor(hexString: "#2E8B57") // Sea green
        )
    )
    
    static let redTheme = ThemeModel(
        name: "Red",
        description: NSLocalizedString("Vibrant red monochromatic", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#B22222"), // Firebrick
            backgroundColor: UIColor(hexString: "#FF6347"), // Tomato
            shadowColor: UIColor(hexString: "#CD5C5C"), // Indian Red
            tintColor: UIColor(hexString: "#FF4500"), // Orange Red
            positiveColor: UIColor(hexString: "#FA8072"), // Salmon
            destructiveColor: UIColor(hexString: "#FF0000"), // Red
            onColor: UIColor(hexString: "#FFA07A") // Light Salmon
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#FFB6C1"), // Light Pink
            backgroundColor: UIColor(hexString: "#8B0000"), // Dark Red
            shadowColor: UIColor(hexString: "#A52A2A"), // Brown
            tintColor: UIColor(hexString: "#DC143C"), // Crimson
            positiveColor: UIColor(hexString: "#E9967A"), // Dark Salmon
            destructiveColor: UIColor(hexString: "#8B0000"), // Dark Red
            onColor: UIColor(hexString: "#FF4500") // Orange Red
        )
    )

    static let orangeTheme = ThemeModel(
        name: "Orange",
        description: NSLocalizedString("Bold orange monochromatic", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#FF8C00"), // Dark Orange
            backgroundColor: UIColor(hexString: "#FFA500"), // Orange
            shadowColor: UIColor(hexString: "#FF7F50"), // Coral
            tintColor: UIColor(hexString: "#FF6347"), // Tomato
            positiveColor: UIColor(hexString: "#FFD700"), // Gold
            destructiveColor: UIColor(hexString: "#FF4500"), // Orange Red
            onColor: UIColor(hexString: "#FFFAF0") // Floral White
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#FFE4B5"), // Moccasin
            backgroundColor: UIColor(hexString: "#FF4500"), // Orange Red
            shadowColor: UIColor(hexString: "#FF6347"), // Tomato
            tintColor: UIColor(hexString: "#FF7F50"), // Coral
            positiveColor: UIColor(hexString: "#FFA07A"), // Light Salmon
            destructiveColor: UIColor(hexString: "#FF8C00"), // Dark Orange
            onColor: UIColor(hexString: "#FFD700") // Gold
        )
    )

    static let yellowTheme = ThemeModel(
        name: "Yellow",
        description: NSLocalizedString("Bright yellow monochromatic", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#FFD700"), // Gold
            backgroundColor: UIColor(hexString: "#FFFFE0"), // Light Yellow
            shadowColor: UIColor(hexString: "#FFA500"), // Orange
            tintColor: UIColor(hexString: "#FFFACD"), // Lemon Chiffon
            positiveColor: UIColor(hexString: "#FAFAD2"), // Light Goldenrod Yellow
            destructiveColor: UIColor(hexString: "#FF4500"), // Orange Red
            onColor: UIColor(hexString: "#FFFF00") // Yellow
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#FFF8DC"), // Cornsilk
            backgroundColor: UIColor(hexString: "#FFD700"), // Gold
            shadowColor: UIColor(hexString: "#FFA500"), // Orange
            tintColor: UIColor(hexString: "#FFE4B5"), // Moccasin
            positiveColor: UIColor(hexString: "#FAFAD2"), // Light Goldenrod Yellow
            destructiveColor: UIColor(hexString: "#FFD700"), // Gold
            onColor: UIColor(hexString: "#FFFF00") // Yellow
        )
    )

    static let greenTheme = ThemeModel(
        name: "Green",
        description: NSLocalizedString("Refreshing green monochromatic", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#006400"), // Dark Green
            backgroundColor: UIColor(hexString: "#90EE90"), // Light Green
            shadowColor: UIColor(hexString: "#2E8B57"), // Sea Green
            tintColor: UIColor(hexString: "#32CD32"), // Lime Green
            positiveColor: UIColor(hexString: "#00FF00"), // Lime
            destructiveColor: UIColor(hexString: "#228B22"), // Forest Green
            onColor: UIColor(hexString: "#ADFF2F") // Green Yellow
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#98FB98"), // Pale Green
            backgroundColor: UIColor(hexString: "#006400"), // Dark Green
            shadowColor: UIColor(hexString: "#2E8B57"), // Sea Green
            tintColor: UIColor(hexString: "#3CB371"), // Medium Sea Green
            positiveColor: UIColor(hexString: "#00FF7F"), // Spring Green
            destructiveColor: UIColor(hexString: "#228B22"), // Forest Green
            onColor: UIColor(hexString: "#ADFF2F") // Green Yellow
        )
    )

    static let blueTheme = ThemeModel(
        name: "Blue",
        description: NSLocalizedString("Cool blue monochromatic", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#0000FF"), // Blue
            backgroundColor: UIColor(hexString: "#ADD8E6"), // Light Blue
            shadowColor: UIColor(hexString: "#4682B4"), // Steel Blue
            tintColor: UIColor(hexString: "#87CEEB"), // Sky Blue
            positiveColor: UIColor(hexString: "#1E90FF"), // Dodger Blue
            destructiveColor: UIColor(hexString: "#00008B"), // Dark Blue
            onColor: UIColor(hexString: "#00BFFF") // Deep Sky Blue
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#B0C4DE"), // Light Steel Blue
            backgroundColor: UIColor(hexString: "#00008B"), // Dark Blue
            shadowColor: UIColor(hexString: "#4682B4"), // Steel Blue
            tintColor: UIColor(hexString: "#5F9EA0"), // Cadet Blue
            positiveColor: UIColor(hexString: "#6495ED"), // Cornflower Blue
            destructiveColor: UIColor(hexString: "#0000CD"), // Medium Blue
            onColor: UIColor(hexString: "#00BFFF") // Deep Sky Blue
        )
    )

    static let indigoTheme = ThemeModel(
        name: "Indigo",
        description: NSLocalizedString("Deep indigo monochromatic", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#4B0082"), // Indigo
            backgroundColor: UIColor(hexString: "#8A2BE2"), // Blue Violet
            shadowColor: UIColor(hexString: "#6A5ACD"), // Slate Blue
            tintColor: UIColor(hexString: "#7B68EE"), // Medium Slate Blue
            positiveColor: UIColor(hexString: "#9370DB"), // Medium Purple
            destructiveColor: UIColor(hexString: "#483D8B"), // Dark Slate Blue
            onColor: UIColor(hexString: "#8B008B") // Dark Magenta
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#E6E6FA"), // Lavender
            backgroundColor: UIColor(hexString: "#4B0082"), // Indigo
            shadowColor: UIColor(hexString: "#6A5ACD"), // Slate Blue
            tintColor: UIColor(hexString: "#9370DB"), // Medium Purple
            positiveColor: UIColor(hexString: "#BA55D3"), // Medium Orchid
            destructiveColor: UIColor(hexString: "#8A2BE2"), // Blue Violet
            onColor: UIColor(hexString: "#7B68EE") // Medium Slate Blue
        )
    )

    static let violetTheme = ThemeModel(
        name: "Violet",
        description: NSLocalizedString("Gentle violet monochromatic", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#9400D3"), // Dark Violet
            backgroundColor: UIColor(hexString: "#EE82EE"), // Violet
            shadowColor: UIColor(hexString: "#8A2BE2"), // Blue Violet
            tintColor: UIColor(hexString: "#DDA0DD"), // Plum
            positiveColor: UIColor(hexString: "#DA70D6"), // Orchid
            destructiveColor: UIColor(hexString: "#9932CC"), // Dark Orchid
            onColor: UIColor(hexString: "#FF00FF") // Magenta
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#DDA0DD"), // Plum
            backgroundColor: UIColor(hexString: "#800080"), // Purple
            shadowColor: UIColor(hexString: "#8A2BE2"), // Blue Violet
            tintColor: UIColor(hexString: "#9400D3"), // Dark Violet
            positiveColor: UIColor(hexString: "#DA70D6"), // Orchid
            destructiveColor: UIColor(hexString: "#9932CC"), // Dark Orchid
            onColor: UIColor(hexString: "#BA55D3") // Medium Orchid
        )
    )

    static let pinkTheme = ThemeModel(
        name: "Pink",
        description: NSLocalizedString("Sweet pink monochromatic", comment: ""),
        lightModeColors: ColorModel(
            textColor: UIColor(hexString: "#FF69B4"), // Hot Pink
            backgroundColor: UIColor(hexString: "#FFB6C1"), // Light Pink
            shadowColor: UIColor(hexString: "#FF1493"), // Deep Pink
            tintColor: UIColor(hexString: "#FFC0CB"), // Pink
            positiveColor: UIColor(hexString: "#FF69B4"), // Hot Pink
            destructiveColor: UIColor(hexString: "#DB7093"), // Pale Violet Red
            onColor: UIColor(hexString: "#FF69B4") // Hot Pink
        ),
        darkModeColors: ColorModel(
            textColor: UIColor(hexString: "#FFB6C1"), // Light Pink
            backgroundColor: UIColor(hexString: "#C71585"), // Medium Violet Red
            shadowColor: UIColor(hexString: "#FF1493"), // Deep Pink
            tintColor: UIColor(hexString: "#FF69B4"), // Hot Pink
            positiveColor: UIColor(hexString: "#DB7093"), // Pale Violet Red
            destructiveColor: UIColor(hexString: "#FF69B4"), // Hot Pink
            onColor: UIColor(hexString: "#FFC0CB") // Pink
        )
    )

}
