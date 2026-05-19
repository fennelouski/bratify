//
//  TrailingSidebarLayout.swift
//  brat
//

import UIKit

enum EditorPanelLayoutMode {
    case sidebars
    case compactBottomPanel
    case macBottomChromeOnly
}

enum TrailingSidebarLayout {
    static let width: CGFloat = 280
    static let minimumWindowWidth: CGFloat = 700

    static let compactPanelHeightFilterStyles: CGFloat = 140
    static let compactPanelHeightFontPicker: CGFloat = 280
    static let compactPanelHeightAspectRatio: CGFloat = 300
    static let compactPanelHeightBackgroundImage: CGFloat = 320
    static let compactPanelHeightWebImport: CGFloat = 340
    static let compactPanelHeightSettingsMaximum: CGFloat = 420

    static func isEligible(width: CGFloat) -> Bool {
        width >= minimumWindowWidth
    }

    static func isEnabled(for traitCollection: UITraitCollection) -> Bool {
        isEnabled(for: traitCollection.userInterfaceIdiom)
    }

    static func isEnabled(for idiom: UIUserInterfaceIdiom) -> Bool {
        #if targetEnvironment(macCatalyst)
        return true
        #else
        switch idiom {
        case .mac, .pad:
            return true
        default:
            return false
        }
        #endif
    }

    static func mode(
        idiom: UIUserInterfaceIdiom,
        width: CGFloat,
        height: CGFloat,
        usesMacCollapsibleBottomPanel: Bool
    ) -> EditorPanelLayoutMode {
        if usesMacCollapsibleBottomPanel {
            return .macBottomChromeOnly
        }
        if idiom == .phone {
            return .compactBottomPanel
        }
        if idiom == .pad {
            if width < minimumWindowWidth || height > width {
                return .compactBottomPanel
            }
            return .sidebars
        }
        if isEnabled(for: idiom), isEligible(width: width) {
            return .sidebars
        }
        return .macBottomChromeOnly
    }

    static func shouldUseCompactBottomPanel(
        idiom: UIUserInterfaceIdiom,
        width: CGFloat,
        height: CGFloat,
        usesMacCollapsibleBottomPanel: Bool
    ) -> Bool {
        mode(
            idiom: idiom,
            width: width,
            height: height,
            usesMacCollapsibleBottomPanel: usesMacCollapsibleBottomPanel
        ) == .compactBottomPanel
    }

    static func shouldUseSidebars(
        idiom: UIUserInterfaceIdiom,
        width: CGFloat,
        height: CGFloat,
        usesMacCollapsibleBottomPanel: Bool
    ) -> Bool {
        mode(
            idiom: idiom,
            width: width,
            height: height,
            usesMacCollapsibleBottomPanel: usesMacCollapsibleBottomPanel
        ) == .sidebars
    }

    static func compactPanelHeight(
        for panel: EditorPanel,
        editorMiddleBandHeight: CGFloat
    ) -> CGFloat {
        switch panel {
        case .filterStyles:
            return compactPanelHeightFilterStyles
        case .fontPicker:
            return compactPanelHeightFontPicker
        case .aspectRatio:
            return compactPanelHeightAspectRatio
        case .backgroundImage:
            return compactPanelHeightBackgroundImage
        case .webImport:
            return compactPanelHeightWebImport
        case .settings:
            let proportional = editorMiddleBandHeight * 0.55
            return min(compactPanelHeightSettingsMaximum, max(proportional, compactPanelHeightFilterStyles))
        }
    }
}

enum EditorPanel: Equatable {
    case settings
    case backgroundImage
    case filterStyles
    case fontPicker
    case webImport
    case aspectRatio
}
