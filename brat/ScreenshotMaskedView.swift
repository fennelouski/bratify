import UIKit

/// A container that hides whatever it holds from screenshots, screen recordings and
/// AirPlay mirroring, while leaving it fully visible and tappable on the device.
///
/// The trick is the one Bluesky and Threads use to sneak their logos into iOS
/// screenshots: a `UITextField` with `isSecureTextEntry` enabled owns a private canvas
/// view that the capture pipeline blanks out. Parent real content into that canvas and
/// the content disappears from every captured frame, letting whatever sits behind it
/// show through — here, the artwork under the share button.
///
/// Nothing about the hierarchy is faked: the canvas is a plain `UIView`, so layout,
/// hit-testing, accessibility and animations all behave normally.
///
/// When the private canvas cannot be found — Mac Catalyst, or a future iOS that reshapes
/// `UITextField` — the content is rendered as-is and ``isMaskingActive`` reports `false`.
final class ScreenshotMaskedView: UIView {

    /// Host for the masked content. Add subviews here, not to the container itself.
    let contentView = UIView()

    /// `true` once the content is parented inside the secure canvas.
    private(set) var isMaskingActive = false

    /// Kept alive and in the hierarchy: the canvas only stays secure while its field does.
    private let secureTextField = UITextField()

    private var contentConstraints: [NSLayoutConstraint] = []

    init(content: UIView? = nil) {
        super.init(frame: .zero)
        setUpContainer()
        if let content {
            embed(content)
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpContainer()
    }

    /// Pins `content` to the edges of ``contentView``.
    func embed(_ content: UIView) {
        content.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(content)
        NSLayoutConstraint.activate(Self.pin(content, to: contentView))
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        activateMaskingIfNeeded()
    }

    override func layoutSubviews() {
        activateMaskingIfNeeded()
        super.layoutSubviews()
    }

    private func setUpContainer() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.translatesAutoresizingMaskIntoConstraints = false

        // Zero-sized: the field never draws anything itself, it only marks its canvas as
        // secure. Low priorities keep its intrinsic size out of the container's sizing.
        secureTextField.isSecureTextEntry = true
        secureTextField.isUserInteractionEnabled = false
        secureTextField.isAccessibilityElement = false
        secureTextField.backgroundColor = .clear
        secureTextField.translatesAutoresizingMaskIntoConstraints = false
        secureTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        secureTextField.setContentHuggingPriority(.defaultLow, for: .vertical)
        secureTextField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        secureTextField.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        addSubview(secureTextField)
        NSLayoutConstraint.activate([
            secureTextField.leadingAnchor.constraint(equalTo: leadingAnchor),
            secureTextField.topAnchor.constraint(equalTo: topAnchor),
            secureTextField.widthAnchor.constraint(equalToConstant: 0),
            secureTextField.heightAnchor.constraint(equalToConstant: 0),
        ])

        attachContent(to: self)
        activateMaskingIfNeeded()
    }

    /// Moves the secure canvas out of the text field and the content into the canvas.
    /// Idempotent, and safe to retry: the canvas view is created lazily, so the first
    /// attempt at `init` time can legitimately come up empty.
    private func activateMaskingIfNeeded() {
        guard !isMaskingActive, Self.supportsMasking else { return }
        secureTextField.layoutIfNeeded()
        guard let canvas = Self.secureCanvas(of: secureTextField) else { return }

        canvas.subviews.forEach { $0.removeFromSuperview() }
        canvas.isUserInteractionEnabled = true
        canvas.backgroundColor = .clear
        canvas.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(canvas, aboveSubview: secureTextField)
        NSLayoutConstraint.activate(Self.pin(canvas, to: self))

        attachContent(to: canvas)
        isMaskingActive = true
    }

    private func attachContent(to parent: UIView) {
        NSLayoutConstraint.deactivate(contentConstraints)
        parent.addSubview(contentView)
        contentConstraints = Self.pin(contentView, to: parent)
        NSLayoutConstraint.activate(contentConstraints)
    }

    /// Catalyst renders secure fields through AppKit; there is no canvas to borrow.
    static let supportsMasking: Bool = {
        #if targetEnvironment(macCatalyst)
        false
        #else
        true
        #endif
    }()

    /// The private `_UITextLayoutCanvasView` whose layer the screenshot path blanks.
    private static func secureCanvas(of textField: UITextField) -> UIView? {
        // The canvas is the view backing the field's first sublayer. Fall back to matching
        // the subview by class name if that layer is not wired up to a view.
        if let canvas = textField.layer.sublayers?.first?.delegate as? UIView {
            return canvas
        }
        return textField.subviews.first { subview in
            String(describing: type(of: subview)).contains("CanvasView")
        }
    }

    private static func pin(_ view: UIView, to parent: UIView) -> [NSLayoutConstraint] {
        [
            view.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: parent.trailingAnchor),
            view.topAnchor.constraint(equalTo: parent.topAnchor),
            view.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
        ]
    }
}
