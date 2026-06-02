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

    static let compactPanelHeightFilterStyles: CGFloat = 320
    static let compactPanelHeightFontPicker: CGFloat = 280
    static let compactPanelHeightAspectRatio: CGFloat = 300
    static let compactPanelHeightBackgroundImage: CGFloat = 320
    static let compactPanelHeightWebImport: CGFloat = 340

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

    /// Picker panels (background, styles, font, web, aspect) use sidebars when the window is wide enough, including on Mac with collapsible bottom chrome.
    static func shouldUseEditorSidebars(
        idiom: UIUserInterfaceIdiom,
        width: CGFloat,
        height: CGFloat,
        usesMacCollapsibleBottomPanel: Bool
    ) -> Bool {
        if shouldUseSidebars(
            idiom: idiom,
            width: width,
            height: height,
            usesMacCollapsibleBottomPanel: usesMacCollapsibleBottomPanel
        ) {
            return true
        }
        return usesMacCollapsibleBottomPanel
            && isEnabled(for: idiom)
            && isEligible(width: width)
    }

    /// Settings from the editor detail view use the leading sidebar on Mac and wide iPad landscape.
    static func shouldUseSettingsLeadingSidebar(
        idiom: UIUserInterfaceIdiom,
        width: CGFloat,
        height: CGFloat,
        usesMacCollapsibleBottomPanel: Bool
    ) -> Bool {
        if usesMacCollapsibleBottomPanel, isEnabled(for: idiom) {
            return true
        }
        return shouldUseSidebars(
            idiom: idiom,
            width: width,
            height: height,
            usesMacCollapsibleBottomPanel: usesMacCollapsibleBottomPanel
        )
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
        }
    }

    /// Compact panels usually dismiss on keyboard show to preserve editing space.
    /// Web import is excluded because it requires keyboard input in its URL/search controls.
    static func shouldDismissCompactPanelOnKeyboardShow(activePanel: EditorPanel?) -> Bool {
        activePanel != .webImport
    }
}

enum EditorPanel: Equatable {
    case backgroundImage
    case filterStyles
    case fontPicker
    case webImport
    case aspectRatio
}
