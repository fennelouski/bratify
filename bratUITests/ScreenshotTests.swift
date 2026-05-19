import XCTest

final class ScreenshotTests: XCTestCase {

    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testCaptureScreenshots() {
        app.launchEnvironment["BRATIFY_SCREENSHOT"] = "1"
        app.launch()

        let shouldSeed = ProcessInfo.processInfo.environment["BRATIFY_SEED"] == "1"
        if shouldSeed {
            seedDemoDesigns()
        }

        snap("01_main")

        // Open the first design (or create one) to show the editor
        let cells = app.collectionViews.cells
        if cells.firstMatch.waitForExistence(timeout: 2) {
            cells.firstMatch.tap()
            if app.navigationBars.buttons["designs"].waitForExistence(timeout: 3) {
                snap("02_editor")
                app.navigationBars.buttons["designs"].tap()
            }
        }

        // Show settings
        let settingsButton = app.navigationBars.buttons["Settings"]
        if settingsButton.waitForExistence(timeout: 2) {
            settingsButton.tap()
            snap("03_settings")
        }
    }

    // Creates 3 sample designs through the app UI.
    private func seedDemoDesigns() {
        let samples = ["hello kitty", "brat summer", "very demure"]
        for text in samples {
            let addButton = app.navigationBars.buttons["Add"]
            guard addButton.waitForExistence(timeout: 5) else { break }
            addButton.tap()

            // The editor uses a hidden first-responder UITextView; typeText goes to it directly.
            if app.navigationBars.buttons["designs"].waitForExistence(timeout: 3) {
                app.typeText(text)
                app.navigationBars.buttons["designs"].tap()
            }

            // Wait for collection view to reload
            _ = app.collectionViews.firstMatch.waitForExistence(timeout: 2)
        }
    }

    private func snap(_ name: String) {
        let screenshot = app.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
