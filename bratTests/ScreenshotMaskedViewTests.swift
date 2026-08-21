import XCTest
@testable import brat

final class ScreenshotMaskedViewTests: XCTestCase {

    private func makeContainer() -> (ScreenshotMaskedView, UIButton) {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        let container = ScreenshotMaskedView(content: button)
        container.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        container.layoutIfNeeded()
        return (container, button)
    }

    func testEmbeddedContentFillsTheContainer() {
        let (container, button) = makeContainer()
        XCTAssertEqual(button.bounds.size, container.bounds.size)
    }

    func testEmbeddedContentStillReceivesTouches() {
        let (container, button) = makeContainer()
        XCTAssertEqual(container.hitTest(CGPoint(x: 22, y: 22), with: nil), button)
    }

    #if !targetEnvironment(macCatalyst)
    /// Canary: the masking rides on a private `UITextField` subview. If iOS ever renames or
    /// restructures it the button stops hiding from screenshots, and this is where we notice.
    func testContentIsParentedInsideTheSecureCanvas() {
        let (container, button) = makeContainer()
        XCTAssertTrue(container.isMaskingActive)

        let ancestors = sequence(first: button, next: { $0.superview })
        XCTAssertTrue(ancestors.contains { String(describing: type(of: $0)).contains("CanvasView") })
    }
    #endif

    func testMaskedShareBarButtonItemUsesTheMaskedContainerAsItsCustomView() {
        let item = ScreenshotMaskedShareBarButtonItem(action: {})
        XCTAssertTrue(item.customView is ScreenshotMaskedView)
    }

    func testMaskedShareBarButtonItemForwardsEnabledStateToItsCustomView() throws {
        let item = ScreenshotMaskedShareBarButtonItem(action: {})
        let button = try XCTUnwrap(embeddedButton(of: item))

        item.isEnabled = false
        XCTAssertFalse(item.isEnabled)
        XCTAssertFalse(button.isEnabled)

        item.isEnabled = true
        XCTAssertTrue(item.isEnabled)
        XCTAssertTrue(button.isEnabled)
    }

    func testMaskedShareBarButtonItemInvokesItsAction() throws {
        var tapped = 0
        let item = ScreenshotMaskedShareBarButtonItem(action: { tapped += 1 })
        try XCTUnwrap(embeddedButton(of: item)).sendActions(for: .touchUpInside)
        XCTAssertEqual(tapped, 1)
    }

    private func embeddedButton(of item: UIBarButtonItem) -> UIButton? {
        (item.customView as? ScreenshotMaskedView)?.contentView.subviews.first as? UIButton
    }
}
