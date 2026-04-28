//
//  ColorModel.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/15/24.
//

import UIKit

struct ColorModel: Codable, Hashable, Equatable {
    var textColor: UIColor
    var backgroundColor: UIColor
    var shadowColor: UIColor
    var tintColor: UIColor
    var positiveColor: UIColor
    var destructiveColor: UIColor
    var onColor: UIColor
    
    // Conform to Codable
    enum CodingKeys: String, CodingKey {
        case textColor
        case backgroundColor
        case shadowColor
        case tintColor
        case positiveColor
        case destructiveColor
        case onColor
    }
    
    // Custom encoding to handle UIColor
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(textColor.hexString, forKey: .textColor)
        try container.encode(backgroundColor.hexString, forKey: .backgroundColor)
        try container.encode(shadowColor.hexString, forKey: .shadowColor)
        try container.encode(tintColor.hexString, forKey: .tintColor)
        try container.encode(positiveColor.hexString, forKey: .positiveColor)
        try container.encode(destructiveColor.hexString, forKey: .destructiveColor)
        try container.encode(onColor.hexString, forKey: .onColor)
    }
    
    init(textColor: UIColor, backgroundColor: UIColor, shadowColor: UIColor, tintColor: UIColor, positiveColor: UIColor, destructiveColor: UIColor, onColor: UIColor) {
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.shadowColor = shadowColor
        self.tintColor = tintColor
        self.positiveColor = positiveColor
        self.destructiveColor = destructiveColor
        self.onColor = onColor
    }
    
    // Custom decoding to handle UIColor
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let textColorHex = try container.decode(String.self, forKey: .textColor)
        let backgroundColorHex = try container.decode(String.self, forKey: .backgroundColor)
        let shadowColorHex = try container.decode(String.self, forKey: .shadowColor)
        let tintColorHex = try container.decode(String.self, forKey: .tintColor)
        let positiveColorHex = try container.decode(String.self, forKey: .positiveColor)
        let destructiveColorHex = try container.decode(String.self, forKey: .destructiveColor)
        let onColorHex = try container.decode(String.self, forKey: .onColor)
        
        self.textColor = UIColor(hexString: textColorHex)
        self.backgroundColor = UIColor(hexString: backgroundColorHex)
        self.shadowColor = UIColor(hexString: shadowColorHex)
        self.tintColor = UIColor(hexString: tintColorHex)
        self.positiveColor = UIColor(hexString: positiveColorHex)
        self.destructiveColor = UIColor(hexString: destructiveColorHex)
        self.onColor = UIColor(hexString: onColorHex)
    }
}
