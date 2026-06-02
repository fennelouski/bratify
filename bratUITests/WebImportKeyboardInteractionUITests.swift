import XCTest

final class WebImportKeyboardInteractionUITests: XCTestCase {

    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
    }

    func testWebImportPanelRemainsVisibleWhenKeyboardShows() {
        app.launch()
        openEditorFromDesignsList()
        revealEditorChromeIfNeeded()

        let importFromWebButton = app.buttons["Import from web"]
        XCTAssertTrue(importFromWebButton.waitForExistence(timeout: 5), "Expected Import from web button.")
        importFromWebButton.tap()

        let changeURLButton = app.webImagePickerChangeURLButton
        XCTAssertTrue(changeURLButton.waitForExistence(timeout: 8), "Expected web import UI to be visible.")
        changeURLButton.tap()

        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 5), "Expected keyboard after tapping Change URL.")

        // Regression check: keyboard appearance should not dismiss web import on iPhone.
        XCTAssertTrue(app.webImagePickerDoneButton.waitForExistence(timeout: 5))
        XCTAssertTrue(app.webImagePickerCancelButton.exists)
        XCTAssertTrue(app.webImagePickerChangeURLButton.exists)
    }

    private func openEditorFromDesignsList() {
        let cells = app.collectionViews.cells
        if cells.firstMatch.waitForExistence(timeout: 2) {
            cells.firstMatch.tap()
            return
        }

        let addButton = app.navigationBars.buttons["Add"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5), "Expected Add button on designs screen.")
        addButton.tap()
        XCTAssertTrue(app.navigationBars.buttons["designs"].waitForExistence(timeout: 5), "Expected editor screen after creating a design.")
    }

    private func revealEditorChromeIfNeeded() {
        let importFromWebButton = app.buttons["Import from web"]
        if importFromWebButton.exists && importFromWebButton.isHittable {
            return
        }

        let keyboardCandidates = ["Keyboard", "keyboard"]
        for candidate in keyboardCandidates {
            let button = app.navigationBars.buttons[candidate]
            if button.exists {
                button.tap()
                break
            }
        }

        _ = importFromWebButton.waitForExistence(timeout: 2)
    }
}
