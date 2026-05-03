import UIKit

protocol KeyboardOptionsViewDelegate: DesignControlsViewControllerDelegate, DesignControlsDelegate {
    var currentDesign: Design { get }

    func updateDesignImage()
    func fontSizeChanged(to newFontSize: CGFloat)
    func pixelationScaleChanged(to newPixelationScale: CGFloat)
    func stretchChanged(to newStretch: CGFloat)
    func blurChanged(to newBlur: CGFloat)
    func didSelectBackgroundColor(_ color: UIColor)
    func didSelectTextColorFromSwatch(_ color: UIColor)
    func keyboardOptionsViewWillShowDesignControls()
    func keyboardOptionsViewDidDismissDesignControls()
}

class KeyboardOptionsView: UIView {

    weak var delegate: KeyboardOptionsViewDelegate?
    private let settingsManager: SettingsManager
    private var designControlsView: DesignControlsView?

    func update(with design: Design) {
        fontSizeSlider.value = Float(design.fontSize)
        pixelationSlider.value = Float(design.pixelationScale)
        stretchSlider.value = Float(design.stretch)
        blurSlider.value = Float(design.blur)

        blurValueLabel.text = "\(Int(blurSlider.value))"
        stretchValueLabel.text = "\(Int(stretchSlider.value * 100))%"
        pixelationValueLabel.text = "\(Int(pixelationSlider.value))"
        fontSizeValueLabel.text = "\(Int(fontSizeSlider.value))"

    }

    private lazy var fontSizeSlider: UISlider = {
        let slider = UISlider()
        slider.value = Float(settingsManager.preferredFontSize)
#if !targetEnvironment(macCatalyst)
        let thumbImage = UIImage(systemName: "textformat.size")
        slider.setThumbImage(thumbImage, for: .normal)
#endif
        return slider
    }()

    private lazy var pixelationSlider: UISlider = {
        let slider = UISlider()
        slider.value = 5
#if !targetEnvironment(macCatalyst)
        let thumbImage = UIImage(systemName: "rectangle.checkered")
        slider.setThumbImage(thumbImage, for: .normal)
#endif
        return slider
    }()

    private lazy var stretchSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.2
#if !targetEnvironment(macCatalyst)
        let thumbImage = UIImage(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right")
        slider.setThumbImage(thumbImage, for: .normal)
#endif
        return slider
    }()

    private lazy var blurSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0
#if !targetEnvironment(macCatalyst)
        let thumbImage = UIImage(systemName: "drop.circle")
        slider.setThumbImage(thumbImage, for: .normal)
#endif
        return slider
    }()
    
    private lazy var fontSizeLabel: UILabel = createLabel(withText: NSLocalizedString("font size", comment: "").localizedLowercase)
    private lazy var fontSizeValueLabel: UILabel = createLabel(withText: "")
    private lazy var pixelationLabel: UILabel = createLabel(withText: NSLocalizedString("pixelation", comment: "").localizedLowercase)
    private lazy var pixelationValueLabel: UILabel = createLabel(withText: "")
    private lazy var stretchLabel: UILabel = createLabel(withText: NSLocalizedString("stretch", comment: "").localizedLowercase)
    private lazy var stretchValueLabel: UILabel = createLabel(withText: "")
    private lazy var blurLabel: UILabel = createLabel(withText: NSLocalizedString("blur", comment: "").localizedLowercase)
    private lazy var blurValueLabel: UILabel = createLabel(withText: "")

    private lazy var fontSizeInfoButton: UIButton = createInfoButton(key: "font size")
    private lazy var pixelationInfoButton: UIButton = createInfoButton(key: "pixelation")
    private lazy var stretchInfoButton: UIButton = createInfoButton(key: "stretch")
    private lazy var blurInfoButton: UIButton = createInfoButton(key: "blur")

    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        super.init(frame: .zero)
        setupView()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleExtendedRangeChange),
            name: .extendedRangeDidChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleELI5ModeChange),
            name: .eli5ModeDidChange,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .clear

        addSubview(fontSizeSlider)
        addSubview(pixelationSlider)
        addSubview(stretchSlider)
        addSubview(blurSlider)

        if settingsManager.showLabels {
            addSubview(fontSizeLabel)
            addSubview(fontSizeValueLabel)
            addSubview(pixelationLabel)
            addSubview(pixelationValueLabel)
            addSubview(stretchLabel)
            addSubview(stretchValueLabel)
            addSubview(blurLabel)
            addSubview(blurValueLabel)
        }

        addSubview(fontSizeInfoButton)
        addSubview(pixelationInfoButton)
        addSubview(stretchInfoButton)
        addSubview(blurInfoButton)
        updateInfoButtonVisibility()

        fontSizeSlider.translatesAutoresizingMaskIntoConstraints = false
        pixelationSlider.translatesAutoresizingMaskIntoConstraints = false
        stretchSlider.translatesAutoresizingMaskIntoConstraints = false
        blurSlider.translatesAutoresizingMaskIntoConstraints = false
        fontSizeInfoButton.translatesAutoresizingMaskIntoConstraints = false
        pixelationInfoButton.translatesAutoresizingMaskIntoConstraints = false
        stretchInfoButton.translatesAutoresizingMaskIntoConstraints = false
        blurInfoButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            fontSizeSlider.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            fontSizeSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            fontSizeSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            pixelationSlider.topAnchor.constraint(equalTo: fontSizeSlider.bottomAnchor, constant: 20),
            pixelationSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            pixelationSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            pixelationSlider.heightAnchor.constraint(equalTo: fontSizeSlider.heightAnchor),

            stretchSlider.topAnchor.constraint(equalTo: pixelationSlider.bottomAnchor, constant: 20),
            stretchSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stretchSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stretchSlider.heightAnchor.constraint(equalTo: fontSizeSlider.heightAnchor),

            blurSlider.topAnchor.constraint(equalTo: stretchSlider.bottomAnchor, constant: 20),
            blurSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            blurSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            blurSlider.heightAnchor.constraint(equalTo: fontSizeSlider.heightAnchor),
            blurSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),

            fontSizeInfoButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            fontSizeInfoButton.centerYAnchor.constraint(equalTo: fontSizeSlider.centerYAnchor),
            fontSizeInfoButton.widthAnchor.constraint(equalToConstant: 28),
            fontSizeInfoButton.heightAnchor.constraint(equalToConstant: 28),

            pixelationInfoButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            pixelationInfoButton.centerYAnchor.constraint(equalTo: pixelationSlider.centerYAnchor),
            pixelationInfoButton.widthAnchor.constraint(equalToConstant: 28),
            pixelationInfoButton.heightAnchor.constraint(equalToConstant: 28),

            stretchInfoButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            stretchInfoButton.centerYAnchor.constraint(equalTo: stretchSlider.centerYAnchor),
            stretchInfoButton.widthAnchor.constraint(equalToConstant: 28),
            stretchInfoButton.heightAnchor.constraint(equalToConstant: 28),

            blurInfoButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            blurInfoButton.centerYAnchor.constraint(equalTo: blurSlider.centerYAnchor),
            blurInfoButton.widthAnchor.constraint(equalToConstant: 28),
            blurInfoButton.heightAnchor.constraint(equalToConstant: 28),
        ])

        if settingsManager.showLabels {
            fontSizeLabel.translatesAutoresizingMaskIntoConstraints = false
            fontSizeValueLabel.translatesAutoresizingMaskIntoConstraints = false
            pixelationLabel.translatesAutoresizingMaskIntoConstraints = false
            pixelationValueLabel.translatesAutoresizingMaskIntoConstraints = false
            stretchLabel.translatesAutoresizingMaskIntoConstraints = false
            stretchValueLabel.translatesAutoresizingMaskIntoConstraints = false
            blurLabel.translatesAutoresizingMaskIntoConstraints = false
            blurValueLabel.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                fontSizeLabel.centerYAnchor.constraint(equalTo: fontSizeSlider.centerYAnchor),
                fontSizeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                fontSizeSlider.leadingAnchor.constraint(equalTo: fontSizeLabel.trailingAnchor, constant: 10),
                fontSizeValueLabel.leadingAnchor.constraint(equalTo: fontSizeSlider.trailingAnchor, constant: 20),
                fontSizeValueLabel.centerYAnchor.constraint(equalTo: fontSizeLabel.centerYAnchor),
                fontSizeValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

                pixelationLabel.centerYAnchor.constraint(equalTo: pixelationSlider.centerYAnchor),
                pixelationLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                pixelationSlider.leadingAnchor.constraint(equalTo: pixelationLabel.trailingAnchor, constant: 10),
                pixelationValueLabel.leadingAnchor.constraint(equalTo: pixelationSlider.trailingAnchor, constant: 20),
                pixelationValueLabel.centerYAnchor.constraint(equalTo: pixelationSlider.centerYAnchor),
                pixelationValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

                stretchLabel.centerYAnchor.constraint(equalTo: stretchSlider.centerYAnchor),
                stretchLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                stretchSlider.leadingAnchor.constraint(equalTo: stretchLabel.trailingAnchor, constant: 10),
                stretchValueLabel.leadingAnchor.constraint(equalTo: stretchSlider.trailingAnchor, constant: 20),
                stretchValueLabel.centerYAnchor.constraint(equalTo: stretchSlider.centerYAnchor),
                stretchValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

                blurLabel.centerYAnchor.constraint(equalTo: blurSlider.centerYAnchor),
                blurLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                blurSlider.leadingAnchor.constraint(equalTo: blurLabel.trailingAnchor, constant: 10),
                blurValueLabel.leadingAnchor.constraint(equalTo: blurSlider.trailingAnchor, constant: 20),
                blurValueLabel.centerYAnchor.constraint(equalTo: blurSlider.centerYAnchor),
                blurValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            ])
        }

        fontSizeSlider.addTarget(self, action: #selector(fontSizeChanged), for: .valueChanged)
        pixelationSlider.addTarget(self, action: #selector(pixelationChanged), for: .valueChanged)
        stretchSlider.addTarget(self, action: #selector(stretchChanged), for: .valueChanged)
        blurSlider.addTarget(self, action: #selector(blurChanged), for: .valueChanged)

        updateSliderRanges()
    }

    private func updateSliderRanges() {
        let extended = settingsManager.extendedRange
        fontSizeSlider.minimumValue = extended ? 1 : 20
        fontSizeSlider.maximumValue = extended ? 2000 : 500
        pixelationSlider.minimumValue = 1
        pixelationSlider.maximumValue = extended ? 200 : 50
#if targetEnvironment(macCatalyst)
        stretchSlider.minimumValue = extended ? -4.0 : -0.8
        stretchSlider.maximumValue = extended ? 4.0 : 0.98
        blurSlider.minimumValue = 0
        blurSlider.maximumValue = extended ? 200 : 50
#else
        stretchSlider.minimumValue = extended ? -4.0 : -0.8
        stretchSlider.maximumValue = extended ? 4.0 : 0.5
        blurSlider.minimumValue = 0
        blurSlider.maximumValue = extended ? 100 : 10
#endif
    }

    @objc private func handleExtendedRangeChange() {
        updateSliderRanges()
    }

    @objc private func handleELI5ModeChange() {
        updateInfoButtonVisibility()
    }
    
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        return label
    }

    private func createInfoButton(key: String) -> UIButton {
        let btn = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        btn.setImage(UIImage(systemName: "info.circle", withConfiguration: config), for: .normal)
        btn.tintColor = .secondaryLabel
        btn.isHidden = true
        btn.addAction(UIAction { [weak self] _ in
            guard let self, let window = self.window else { return }
            let desc = ELI5Descriptions.forDesignControl(key)
            ToastView.show(message: desc, icon: "info.circle", in: window, duration: 5.0)
        }, for: .touchUpInside)
        return btn
    }

    func updateInfoButtonVisibility() {
        let show = settingsManager.eli5Mode
        fontSizeInfoButton.isHidden = !show
        pixelationInfoButton.isHidden = !show
        stretchInfoButton.isHidden = !show
        blurInfoButton.isHidden = !show
    }
    
    private lazy var closeButton = UIButton(type: .system)

    private func setupCloseButton() {
        closeButton.setTitle(
            NSLocalizedString("Close", comment: "").localizedLowercase,
            for: .normal
        )
        closeButton.addTarget(
            self,
            action: #selector(closeDesignControls),
            for: .touchUpInside
        )
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(closeButton)
        
        NSLayoutConstraint.activate(
            [
                closeButton.topAnchor.constraint(
                    equalTo: topAnchor,
                    constant: .su3
                ),
                closeButton.trailingAnchor.constraint(
                    equalTo: trailingAnchor,
                    constant: -.su2
                )
            ]
        )
        
//        let closeGesture = UITapGestureRecognizer(
//            target: self,
//            action: #selector(closeDesignControls)
//        )
//        addGestureRecognizer(closeGesture)
    }
    
    @objc private func fontSizeChanged() {
        fontSizeValueLabel.text = "\(Int(fontSizeSlider.value))"
        settingsManager.preferredFontSize = Double(fontSizeSlider.value)
        delegate?.fontSizeChanged(to: CGFloat(fontSizeSlider.value))
        delegate?.updateDesignImage()
    }
    
    @objc private func pixelationChanged() {
        pixelationValueLabel.text = "\(Int(pixelationSlider.value))"
        settingsManager.pixelationScale = Double(pixelationSlider.value)
        delegate?.pixelationScaleChanged(to: CGFloat(pixelationSlider.value))
        delegate?.updateDesignImage()
    }
    
    @objc private func stretchChanged() {
        stretchValueLabel.text = "\(Int(stretchSlider.value * 100))%"
        delegate?.stretchChanged(to: CGFloat(stretchSlider.value))
        delegate?.updateDesignImage()
    }
    
    @objc private func blurChanged() {
        blurValueLabel.text = "\(Int(blurSlider.value))"
        delegate?.blurChanged(to: CGFloat(blurSlider.value))
        delegate?.updateDesignImage()
    }
    
    @objc func showControls() {
        guard let currentDesign = delegate?.currentDesign else {
            return
        }
        
        if traitCollection.userInterfaceIdiom == .mac {
            // Add the DesignControlsView as a subview
            let designControlsView = DesignControlsView(
                design: currentDesign,
                settingsManager: settingsManager
            )
            designControlsView.delegate = delegate
            designControlsView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(designControlsView)
            self.designControlsView = designControlsView
            
            NSLayoutConstraint.activate([
                designControlsView.topAnchor.constraint(equalTo: topAnchor, constant: .su2),
                designControlsView.leadingAnchor.constraint(equalTo: leadingAnchor),
                designControlsView.trailingAnchor.constraint(equalTo: trailingAnchor),
                designControlsView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            
            setupCloseButton()
        } else {
            // Present the view controller for design controls
            let designControlsVC = DesignControlsViewController(
                design: currentDesign,
                settingsManager: settingsManager
            )
            designControlsVC.delegate = delegate
            let navigationController = UINavigationController(rootViewController: designControlsVC)
            navigationController.modalPresentationStyle = .popover

            // Calculate the preferred height
            let screenSize = window?.bounds.size ?? UIScreen.main.bounds.size
            let preferredHeight = min(screenSize.width, 400)
            
            // Set the preferred content size
            designControlsVC.preferredContentSize = CGSize(
                width: screenSize.width,
                height: preferredHeight
            )

            if let popoverPresentationController = navigationController.popoverPresentationController {
                popoverPresentationController.sourceView = self
                popoverPresentationController.sourceRect = CGRect(
                    x: 0,
                    y: bounds.midY + .su5,
                    width: 0,
                    height: 0
                )
                popoverPresentationController.permittedArrowDirections = []
                popoverPresentationController.delegate = self
            }

            delegate?.keyboardOptionsViewWillShowDesignControls()

            // Present the navigation controller
            viewController?.present(
                navigationController,
                animated: true,
                completion: nil
            )
        }
    }
    
    @objc private func closeDesignControls() {
        designControlsView?.removeFromSuperview()
        closeButton.removeFromSuperview()
        designControlsView = nil
    }
    
    private var viewController: UIViewController? {
        return (self.next as? UIViewController) ?? (self.next?.next as? UIViewController)
    }
}

extension KeyboardOptionsView: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate?.keyboardOptionsViewDidDismissDesignControls()
    }
}
