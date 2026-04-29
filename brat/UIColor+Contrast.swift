//
//  UIColor+Contrast.swift
//  brat
//

import UIKit

extension UIColor {
    var relativeLuminance: CGFloat {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        func linearize(_ c: CGFloat) -> CGFloat {
            return c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * linearize(r) + 0.7152 * linearize(g) + 0.0722 * linearize(b)
    }

    func contrastRatio(with other: UIColor) -> CGFloat {
        let l1 = max(relativeLuminance, other.relativeLuminance)
        let l2 = min(relativeLuminance, other.relativeLuminance)
        return (l1 + 0.05) / (l2 + 0.05)
    }

    // Returns self if it meets WCAG AA (4.5:1) against background, otherwise black or white
    func readable(on background: UIColor) -> UIColor {
        if contrastRatio(with: background) >= 4.5 {
            return self
        }
        return background.relativeLuminance > 0.179 ? .black : .white
    }
}
