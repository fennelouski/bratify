import UIKit

class ShareBarButtonItem: UIBarButtonItem {

    init(target: AnyObject?, action: Selector?) {
        super.init()
        let shareImage = UIImage(systemName: "square.and.arrow.up.circle.fill")
        self.image = shareImage
        self.style = .plain
        self.target = target
        self.action = action
        self.tintColor = .systemBlue
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let shareImage = UIImage(systemName: "square.and.arrow.up.circle.fill")
        self.image = shareImage
        self.style = .plain
        self.tintColor = .systemBlue
    }
}

extension UIBarButtonItem {
    /// A share button that iOS blanks out of screenshots and screen recordings, so the
    /// artwork underneath shows through in the capture. Falls back to the plain system
    /// share item where the masking is unavailable (Mac Catalyst).
    static func screenshotMaskedShare(_ action: @escaping () -> Void) -> UIBarButtonItem {
        guard ScreenshotMaskedView.supportsMasking else { return share(action) }
        return ScreenshotMaskedShareBarButtonItem(action: action)
    }

    static func share(_ action: @escaping ()->Void) -> UIBarButtonItem {
        let button = UIBarButtonItem(
            systemItem: .action,
            primaryAction: UIAction(handler: { _ in
                action()
            }),
            menu: nil
        )
        return button
    }
}

/// A share button whose artwork lives inside a ``ScreenshotMaskedView``, so it is visible
/// and tappable on screen but absent from screenshots and screen recordings — a capture of
/// the editor shows the design, not the chrome sitting on top of it.
final class ScreenshotMaskedShareBarButtonItem: UIBarButtonItem {

    private let button: UIButton
    private let maskedContainer: ScreenshotMaskedView

    /// `true` when the button is actually hidden from captures.
    var isMaskingActive: Bool { maskedContainer.isMaskingActive }

    init(action: @escaping () -> Void) {
        let button = UIButton(type: .system)
        self.button = button
        self.maskedContainer = ScreenshotMaskedView(content: button)
        super.init()

        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)
        button.accessibilityLabel = NSLocalizedString(
            "share",
            comment: "Short label indicating double-tap-to-share is on."
        )

        // The bar sizes its custom view from constraints, so state them on the container.
        // The height yields rather than fight the shorter bar in compact landscape.
        maskedContainer.translatesAutoresizingMaskIntoConstraints = false
        let height = maskedContainer.heightAnchor.constraint(equalToConstant: 44)
        height.priority = .defaultHigh
        NSLayoutConstraint.activate([
            maskedContainer.widthAnchor.constraint(equalToConstant: 44),
            height,
        ])

        customView = maskedContainer
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // A custom view does not pick up the bar button item's enabled state on its own.
    override var isEnabled: Bool {
        get { super.isEnabled }
        set {
            super.isEnabled = newValue
            button.isEnabled = newValue
        }
    }

    override var tintColor: UIColor? {
        get { super.tintColor }
        set {
            super.tintColor = newValue
            button.tintColor = newValue
        }
    }
}
