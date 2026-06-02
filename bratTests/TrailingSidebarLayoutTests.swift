import UIKit
import XCTest
@testable import brat

final class TrailingSidebarLayoutTests: XCTestCase {

    func testIsEnabledForPadAndMac() {
        XCTAssertTrue(TrailingSidebarLayout.isEnabled(for: UITraitCollection(userInterfaceIdiom: .pad)))
        XCTAssertTrue(TrailingSidebarLayout.isEnabled(for: UITraitCollection(userInterfaceIdiom: .mac)))
    }

    func testIsDisabledForPhone() {
        XCTAssertFalse(TrailingSidebarLayout.isEnabled(for: UITraitCollection(userInterfaceIdiom: .phone)))
    }

    func testIsEligibleAtMinimumWidth() {
        XCTAssertFalse(TrailingSidebarLayout.isEligible(width: 699))
        XCTAssertTrue(TrailingSidebarLayout.isEligible(width: 700))
    }

    func testPhoneLandscapeUsesCompactBottomPanel() {
        XCTAssertTrue(
            TrailingSidebarLayout.shouldUseCompactBottomPanel(
                idiom: .phone,
                width: 956,
                height: 414,
                usesMacCollapsibleBottomPanel: false
            )
        )
        XCTAssertFalse(
            TrailingSidebarLayout.shouldUseSidebars(
                idiom: .phone,
                width: 956,
                height: 414,
                usesMacCollapsibleBottomPanel: false
            )
        )
    }

    func testPadPortraitUsesCompactBottomPanel() {
        XCTAssertEqual(
            TrailingSidebarLayout.mode(
                idiom: .pad,
                width: 1032,
                height: 1376,
                usesMacCollapsibleBottomPanel: false
            ),
            .compactBottomPanel
        )
    }

    func testPadLandscapeUsesSidebars() {
        XCTAssertTrue(
            TrailingSidebarLayout.shouldUseSidebars(
                idiom: .pad,
                width: 1376,
                height: 1032,
                usesMacCollapsibleBottomPanel: false
            )
        )
    }

    func testPadNarrowPortraitUsesCompactBottomPanel() {
        XCTAssertTrue(
            TrailingSidebarLayout.shouldUseCompactBottomPanel(
                idiom: .pad,
                width: 600,
                height: 800,
                usesMacCollapsibleBottomPanel: false
            )
        )
    }

    func testMacUsesMacBottomChromeOnly() {
        XCTAssertEqual(
            TrailingSidebarLayout.mode(
                idiom: .mac,
                width: 800,
                height: 600,
                usesMacCollapsibleBottomPanel: true
            ),
            .macBottomChromeOnly
        )
        XCTAssertFalse(
            TrailingSidebarLayout.shouldUseCompactBottomPanel(
                idiom: .mac,
                width: 800,
                height: 600,
                usesMacCollapsibleBottomPanel: true
            )
        )
        XCTAssertFalse(
            TrailingSidebarLayout.shouldUseSidebars(
                idiom: .mac,
                width: 800,
                height: 600,
                usesMacCollapsibleBottomPanel: true
            )
        )
        XCTAssertTrue(
            TrailingSidebarLayout.shouldUseSettingsLeadingSidebar(
                idiom: .mac,
                width: 800,
                height: 600,
                usesMacCollapsibleBottomPanel: true
            )
        )
        XCTAssertTrue(
            TrailingSidebarLayout.shouldUseEditorSidebars(
                idiom: .mac,
                width: 800,
                height: 600,
                usesMacCollapsibleBottomPanel: true
            )
        )
    }

    func testMacCollapsibleChromeNarrowWindowDoesNotUseEditorSidebars() {
        XCTAssertFalse(
            TrailingSidebarLayout.shouldUseEditorSidebars(
                idiom: .mac,
                width: 699,
                height: 600,
                usesMacCollapsibleBottomPanel: true
            )
        )
    }

    func testPadPortraitDoesNotUseSettingsLeadingSidebar() {
        XCTAssertFalse(
            TrailingSidebarLayout.shouldUseSettingsLeadingSidebar(
                idiom: .pad,
                width: 1032,
                height: 1376,
                usesMacCollapsibleBottomPanel: false
            )
        )
    }

    func testPadLandscapeUsesSettingsLeadingSidebar() {
        XCTAssertTrue(
            TrailingSidebarLayout.shouldUseSettingsLeadingSidebar(
                idiom: .pad,
                width: 1376,
                height: 1032,
                usesMacCollapsibleBottomPanel: false
            )
        )
    }

    func testMacWideWindowUsesSidebarsWhenNotCollapsibleChrome() {
        XCTAssertTrue(
            TrailingSidebarLayout.shouldUseSidebars(
                idiom: .mac,
                width: 1200,
                height: 800,
                usesMacCollapsibleBottomPanel: false
            )
        )
    }

    /// Compact editor exposes five bottom panels; settings uses navigation push, not ``EditorPanel``.
    func testCompactBottomPanelCount() {
        let panels: [EditorPanel] = [
            .backgroundImage,
            .filterStyles,
            .fontPicker,
            .webImport,
            .aspectRatio,
        ]
        XCTAssertEqual(panels.count, 5)
        for panel in panels {
            let height = TrailingSidebarLayout.compactPanelHeight(
                for: panel,
                editorMiddleBandHeight: 800
            )
            XCTAssertGreaterThan(height, 0)
        }
    }

    func testPhoneCompactLayoutDoesNotUseSidebars() {
        XCTAssertTrue(
            TrailingSidebarLayout.shouldUseCompactBottomPanel(
                idiom: .phone,
                width: 390,
                height: 844,
                usesMacCollapsibleBottomPanel: false
            )
        )
        XCTAssertFalse(
            TrailingSidebarLayout.shouldUseSidebars(
                idiom: .phone,
                width: 390,
                height: 844,
                usesMacCollapsibleBottomPanel: false
            )
        )
    }

    func testCompactKeyboardShowDoesNotDismissWebImportPanel() {
        XCTAssertFalse(
            TrailingSidebarLayout.shouldDismissCompactPanelOnKeyboardShow(activePanel: .webImport)
        )
    }

    func testCompactKeyboardShowDismissesOtherPanels() {
        XCTAssertTrue(
            TrailingSidebarLayout.shouldDismissCompactPanelOnKeyboardShow(activePanel: .fontPicker)
        )
        XCTAssertTrue(
            TrailingSidebarLayout.shouldDismissCompactPanelOnKeyboardShow(activePanel: .backgroundImage)
        )
        XCTAssertTrue(
            TrailingSidebarLayout.shouldDismissCompactPanelOnKeyboardShow(activePanel: .filterStyles)
        )
        XCTAssertTrue(
            TrailingSidebarLayout.shouldDismissCompactPanelOnKeyboardShow(activePanel: .aspectRatio)
        )
        XCTAssertTrue(
            TrailingSidebarLayout.shouldDismissCompactPanelOnKeyboardShow(activePanel: nil)
        )
    }
}
