//
//  bratTests.swift
//  bratTests
//
//  Created by Nathan Fennel on 7/25/24.
//

import XCTest
import UIKit
@testable import brat

final class bratTests: XCTestCase {

    @MainActor
    func testEditorReclaimsHiddenControlsSpace() async throws {
        let settings = SettingsManager()
        let originalShowLabels = settings.showLabels
        defer { settings.showLabels = originalShowLabels }
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.first as? UIWindowScene)

        for showLabels in [false, true] {
            settings.showLabels = showLabels
            var design = Design.empty
            design.text = "layout check"
            let editor = EditDesignViewController(
                originalText: design.text,
                originalBackgroundColor: design.backgroundColor,
                design: design,
                settingsManager: settings,
                imageService: ImageService()
            )
            let window = UIWindow(windowScene: scene)
            window.rootViewController = UINavigationController(rootViewController: editor)
            window.makeKeyAndVisible()
            defer { window.isHidden = true }
            window.layoutIfNeeded()

            let sliders = try XCTUnwrap(editor.view.subviews.compactMap { $0 as? KeyboardOptionsView }.first)
            let preview = try XCTUnwrap(editor.view.subviews.compactMap { $0 as? UIImageView }.first)
            let textView = try XCTUnwrap(editor.view.subviews.compactMap { $0 as? UITextView }.first)
            XCTAssertTrue(textView.becomeFirstResponder())
            try await Task.sleep(for: .milliseconds(500))
            editor.view.layoutIfNeeded()
            XCTAssertEqual(sliders.bounds.height, 0, accuracy: 1, "Typing should use the hidden sliders' space")
            XCTAssertEqual(sliders.frame.maxY, editor.view.keyboardLayoutGuide.layoutFrame.minY, accuracy: 1)
            XCTAssertEqual(preview.frame.maxY, sliders.frame.minY - .su2, accuracy: 1, "No manual keyboard inset")

            textView.resignFirstResponder()
            try await Task.sleep(for: .milliseconds(500))
            editor.perform(NSSelectorFromString("toggleFilterStyles"))
            try await Task.sleep(for: .milliseconds(300))
            editor.view.layoutIfNeeded()
            let styles = try XCTUnwrap(editor.children.compactMap { $0 as? FilterStylesViewController }.first)
            XCTAssertEqual(sliders.bounds.height, 0, accuracy: 1, "Hidden slider constraints must not reserve a bottom band")
            let stylesFrame = styles.view.convert(styles.view.bounds, to: editor.view)
            XCTAssertEqual(stylesFrame.maxY, editor.view.safeAreaLayoutGuide.layoutFrame.maxY, accuracy: 1)

            editor.perform(NSSelectorFromString("toggleFilterStyles"))
            try await Task.sleep(for: .milliseconds(300))
            editor.view.layoutIfNeeded()
            XCTAssertGreaterThan(sliders.bounds.height, 0, "Sliders return when the picker closes")

            editor.keyboardOptionsViewWillShowDesignControls()
            editor.keyboardOptionsViewDidDismissDesignControls()
            try await Task.sleep(for: .milliseconds(300))
            editor.view.layoutIfNeeded()
            XCTAssertEqual(preview.frame.maxY, sliders.frame.minY - .su2, accuracy: 1, "Closing controls restores the normal canvas boundary")
        }
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
