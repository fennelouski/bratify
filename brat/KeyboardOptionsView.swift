import UIKit

protocol KeyboardOptionsViewDelegate: DesignControlsViewControllerDelegate, DesignControlsDelegate {
    var currentDesign: Design { get }

    func updateDesignImage()
    func selectColor()
    func selectTextColor()
    func fontSizeChanged(to newFontSize: CGFloat)
    func selectFont()
    func pixelationScaleChanged(to newPixelationScale: CGFloat)
    func stretchChanged(to newStretch: CGFloat)
    func blurChanged(to newBlur: CGFloat)
    func selectBackgroundImage()
    func didSelectBackgroundColor(_ color: UIColor)
}

class KeyboardOptionsView: UIView {

    private static let presetColors: [UIColor] = [
        UIColor(hexString: "#36a241"),
        UIColor(hexString: "#8AE234"),
        UIColor(hexString: "#000000"),
        UIColor(hexString: "#FFFFFF"),
        UIColor(hexString: "#FF69B4"),
        UIColor(hexString: "#FF00FF"),
        UIColor(hexString: "#FFFF00"),
        UIColor(hexString: "#FF6B00"),
        UIColor(hexString: "#0000FF"),
        UIColor(hexString: "#FF0000"),
    ]

    weak var delegate: KeyboardOptionsViewDelegate?
    private let settingsManager: SettingsManager
    private var designControlsView: DesignControlsView?

    private let colorSwatchScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let colorSwatchStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    func update(with design: Design) {
        fontSizeSlider.value = Float(design.fontSize)
        pixelationSlider.value = Float(design.pixelationScale)
        stretchSlider.value = Float(design.stretch)
        blurSlider.value = Float(design.blur)

        blurValueLabel.text = "\(Int(blurSlider.value))"
        stretchValueLabel.text = "\(Int(stretchSlider.value * 100))%"
        pixelationValueLabel.text = "\(Int(pixelationSlider.value))"
        fontSizeValueLabel.text = "\(Int(fontSizeSlider.value))"
        refreshColorSwatches(currentColor: design.backgroundColor)
    }

    private func refreshColorSwatches(currentColor: UIColor) {
        colorSwatchStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        colorIndicatorView.backgroundColor = currentColor

        let recentHexes = settingsManager.recentBackgroundColors
        let recentColors = recentHexes.map { UIColor(hexString: $0) }
        let presetHexes = Set(recentHexes)
        let additionalPresets = KeyboardOptionsView.presetColors.filter { !presetHexes.contains($0.toHexString()) }
        let swatchColors = recentColors + additionalPresets

        for color in swatchColors {
            let swatch = makeSwatchButton(color: color, isCurrent: color.toHexString() == currentColor.toHexString())
            colorSwatchStackView.addArrangedSubview(swatch)
        }
    }

    private func makeSwatchButton(color: UIColor, isCurrent: Bool) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = color
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.layer.borderWidth = isCurrent ? 2.5 : 1
        button.layer.borderColor = isCurrent ? UIColor.systemBlue.cgColor : UIColor.gray.withAlphaComponent(0.4).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 30),
            button.heightAnchor.constraint(equalToConstant: 30),
        ])
        button.addAction(UIAction { [weak self, weak button] _ in
            self?.delegate?.didSelectBackgroundColor(color)
            self?.colorSwatchStackView.arrangedSubviews.forEach { view in
                guard let btn = view as? UIButton else { return }
                btn.layer.borderWidth = 1
                btn.layer.borderColor = UIColor.gray.withAlphaComponent(0.4).cgColor
            }
            button?.layer.borderWidth = 2.5
            button?.layer.borderColor = UIColor.systemBlue.cgColor
        }, for: .touchUpInside)
        return button
    }
    
    private let colorButton: UIButton = {
        let button = UIButton()
        let paintBrushImage = UIImage(systemName: "paintbrush.fill")
        button.setImage(paintBrushImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .systemBlue
        button.accessibilityLabel = NSLocalizedString(
            "background color",
            comment: "Button to change the background color of this design"
        )
        return button
    }()

    private let colorIndicatorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 7
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()

    private let textColorButton: UIButton = {
        let button = UIButton()
        let textColorImage = UIImage(systemName: "character.textbox")
        button.setImage(textColorImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .systemBlue
        button.accessibilityLabel = NSLocalizedString(
            "Text Color Picker",
            comment: ""
        )
        return button
    }()
    
    private let fontButton: UIButton = {
        let button = UIButton()
        let textFormatImage = UIImage(systemName: "textformat")
        button.setImage(textFormatImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .systemBlue
        button.accessibilityLabel = NSLocalizedString(
            "Font Picker",
            comment: ""
        )
        return button
    }()
    
    private let controlsButton: UIButton = {
        let button = UIButton()
        let controlsImage = UIImage(systemName: "slider.horizontal.3")
        button.setImage(controlsImage, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .systemBlue
        button.accessibilityLabel = NSLocalizedString(
            "Controls",
            comment: ""
        )
        return button
    }()
    
    private let backgroundImageButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "photo")
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.tintColor = .systemBlue
        button.accessibilityLabel = NSLocalizedString(
            "Background Image",
            comment: ""
        )
        return button
    }()
    
    private lazy var fontSizeSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 20
        slider.value = Float(settingsManager.preferredFontSize)
        slider.maximumValue = 500
#if !targetEnvironment(macCatalyst)
        let thumbImage = UIImage(systemName: "textformat.size")
        slider.setThumbImage(thumbImage, for: .normal)
#endif
        return slider
    }()
    
    private let pixelationSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 1
        slider.maximumValue = 50
        slider.value = 5
#if !targetEnvironment(macCatalyst)
        let thumbImage = UIImage(systemName: "rectangle.checkered")
        slider.setThumbImage(thumbImage, for: .normal)
#endif
        return slider
    }()
    
    private let stretchSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = -0.8
        slider.maximumValue = 0.98
        slider.value = 0.2
#if !targetEnvironment(macCatalyst)
        slider.maximumValue = 0.5
        let thumbImage = UIImage(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right")
        slider.setThumbImage(thumbImage, for: .normal)
#endif
        return slider
    }()
    
    private let blurSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 50
        slider.value = 0
#if !targetEnvironment(macCatalyst)
        slider.maximumValue = 10
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

    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        colorSwatchScrollView.addSubview(colorSwatchStackView)
        addSubview(colorSwatchScrollView)
        addSubview(colorButton)
        addSubview(colorIndicatorView)
        addSubview(textColorButton)
        addSubview(fontButton)
        addSubview(fontSizeSlider)
        addSubview(pixelationSlider)
        addSubview(stretchSlider)
        addSubview(blurSlider)
        addSubview(controlsButton)
        addSubview(backgroundImageButton)

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

        colorButton.translatesAutoresizingMaskIntoConstraints = false
        textColorButton.translatesAutoresizingMaskIntoConstraints = false
        fontButton.translatesAutoresizingMaskIntoConstraints = false
        fontSizeSlider.translatesAutoresizingMaskIntoConstraints = false
        pixelationSlider.translatesAutoresizingMaskIntoConstraints = false
        stretchSlider.translatesAutoresizingMaskIntoConstraints = false
        blurSlider.translatesAutoresizingMaskIntoConstraints = false
        controlsButton.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            colorSwatchScrollView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            colorSwatchScrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            colorSwatchScrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            colorSwatchScrollView.heightAnchor.constraint(equalToConstant: 38),

            colorSwatchStackView.topAnchor.constraint(equalTo: colorSwatchScrollView.topAnchor, constant: 4),
            colorSwatchStackView.leadingAnchor.constraint(equalTo: colorSwatchScrollView.leadingAnchor),
            colorSwatchStackView.trailingAnchor.constraint(equalTo: colorSwatchScrollView.trailingAnchor),
            colorSwatchStackView.bottomAnchor.constraint(equalTo: colorSwatchScrollView.bottomAnchor, constant: -4),
            colorSwatchStackView.heightAnchor.constraint(equalTo: colorSwatchScrollView.heightAnchor, constant: -8),

            colorButton.topAnchor.constraint(equalTo: colorSwatchScrollView.bottomAnchor, constant: 12),
            colorButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            colorButton.widthAnchor.constraint(equalTo: colorButton.heightAnchor),

            colorIndicatorView.widthAnchor.constraint(equalToConstant: 14),
            colorIndicatorView.heightAnchor.constraint(equalToConstant: 14),
            colorIndicatorView.trailingAnchor.constraint(equalTo: colorButton.trailingAnchor, constant: 4),
            colorIndicatorView.bottomAnchor.constraint(equalTo: colorButton.bottomAnchor, constant: 4),

            fontButton.topAnchor.constraint(equalTo: colorButton.bottomAnchor, constant: 20),
            fontButton.leadingAnchor.constraint(equalTo: colorButton.leadingAnchor),
            fontButton.trailingAnchor.constraint(equalTo: colorButton.trailingAnchor),
            fontButton.heightAnchor.constraint(equalTo: colorButton.heightAnchor),

            controlsButton.topAnchor.constraint(equalTo: fontButton.bottomAnchor, constant: 20),
            controlsButton.leadingAnchor.constraint(equalTo: colorButton.leadingAnchor),
            controlsButton.trailingAnchor.constraint(equalTo: colorButton.trailingAnchor),
            controlsButton.heightAnchor.constraint(equalTo: colorButton.heightAnchor),

            backgroundImageButton.topAnchor.constraint(equalTo: controlsButton.bottomAnchor, constant: 20),
            backgroundImageButton.leadingAnchor.constraint(equalTo: colorButton.leadingAnchor),
            backgroundImageButton.trailingAnchor.constraint(equalTo: colorButton.trailingAnchor),
            backgroundImageButton.heightAnchor.constraint(equalTo: colorButton.heightAnchor),

            textColorButton.topAnchor.constraint(equalTo: backgroundImageButton.bottomAnchor, constant: 20),
            textColorButton.leadingAnchor.constraint(equalTo: colorButton.leadingAnchor),
            textColorButton.trailingAnchor.constraint(equalTo: colorButton.trailingAnchor),
            textColorButton.heightAnchor.constraint(equalTo: colorButton.heightAnchor),
            textColorButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),

            fontSizeSlider.topAnchor.constraint(equalTo: colorSwatchScrollView.bottomAnchor, constant: 12),
            
            pixelationSlider.topAnchor.constraint(equalTo: fontSizeSlider.bottomAnchor, constant: 20),
            pixelationSlider.heightAnchor.constraint(equalTo: fontSizeSlider.heightAnchor),
            
            stretchSlider.topAnchor.constraint(equalTo: pixelationSlider.bottomAnchor, constant: 20),
            stretchSlider.heightAnchor.constraint(equalTo: fontSizeSlider.heightAnchor),
            
            blurSlider.topAnchor.constraint(equalTo: stretchSlider.bottomAnchor, constant: 20),
            blurSlider.heightAnchor.constraint(equalTo: fontSizeSlider.heightAnchor),
            blurSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
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
                fontSizeLabel.leadingAnchor.constraint(equalTo: colorButton.trailingAnchor, constant: 20),
                fontSizeSlider.leadingAnchor.constraint(equalTo: fontSizeLabel.trailingAnchor, constant: 10),
                fontSizeValueLabel.leadingAnchor.constraint(equalTo: fontSizeSlider.trailingAnchor, constant: 20),
                fontSizeValueLabel.centerYAnchor.constraint(equalTo: fontSizeLabel.centerYAnchor),
                fontSizeValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

                pixelationLabel.centerYAnchor.constraint(equalTo: pixelationSlider.centerYAnchor),
                pixelationLabel.leadingAnchor.constraint(equalTo: colorButton.trailingAnchor, constant: 20),
                pixelationSlider.leadingAnchor.constraint(equalTo: pixelationLabel.trailingAnchor, constant: 10),
                pixelationValueLabel.leadingAnchor.constraint(equalTo: pixelationSlider.trailingAnchor, constant: 20),
                pixelationValueLabel.centerYAnchor.constraint(equalTo: pixelationSlider.centerYAnchor),
                pixelationValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

                stretchLabel.centerYAnchor.constraint(equalTo: stretchSlider.centerYAnchor),
                stretchLabel.leadingAnchor.constraint(equalTo: colorButton.trailingAnchor, constant: 20),
                stretchSlider.leadingAnchor.constraint(equalTo: stretchLabel.trailingAnchor, constant: 10),
                stretchValueLabel.leadingAnchor.constraint(equalTo: stretchSlider.trailingAnchor, constant: 20),
                stretchValueLabel.centerYAnchor.constraint(equalTo: stretchSlider.centerYAnchor),
                stretchValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

                blurLabel.centerYAnchor.constraint(equalTo: blurSlider.centerYAnchor),
                blurLabel.leadingAnchor.constraint(equalTo: colorButton.trailingAnchor, constant: 20),
                blurSlider.leadingAnchor.constraint(equalTo: blurLabel.trailingAnchor, constant: 10),
                blurValueLabel.leadingAnchor.constraint(equalTo: blurSlider.trailingAnchor, constant: 20),
                blurValueLabel.centerYAnchor.constraint(equalTo: blurSlider.centerYAnchor),
                blurValueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
            ])
        } else {
            NSLayoutConstraint.activate([
                fontSizeSlider.leadingAnchor.constraint(equalTo: colorButton.trailingAnchor, constant: 20),
                pixelationSlider.leadingAnchor.constraint(equalTo: colorButton.trailingAnchor, constant: 20),
                stretchSlider.leadingAnchor.constraint(equalTo: colorButton.trailingAnchor, constant: 20),
                blurSlider.leadingAnchor.constraint(equalTo: colorButton.trailingAnchor, constant: 20),
                
                blurSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                fontSizeSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                pixelationSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                stretchSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            ])
        }
        
        colorButton.addTarget(self, action: #selector(selectColor), for: .touchUpInside)
        textColorButton.addTarget(self, action: #selector(selectTextColor), for: .touchUpInside)
        fontButton.addTarget(self, action: #selector(selectFont), for: .touchUpInside)
        fontSizeSlider.addTarget(self, action: #selector(fontSizeChanged), for: .valueChanged)
        pixelationSlider.addTarget(self, action: #selector(pixelationChanged), for: .valueChanged)
        stretchSlider.addTarget(self, action: #selector(stretchChanged), for: .valueChanged)
        blurSlider.addTarget(self, action: #selector(blurChanged), for: .valueChanged)
        controlsButton.addTarget(self, action: #selector(showControls), for: .touchUpInside)
        backgroundImageButton.addTarget(self, action: #selector(selectBackgroundImage), for: .touchUpInside)
    }
    
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        return label
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
    
    @objc private func selectColor() {
        delegate?.selectColor()
    }

    @objc private func didSelectBackgroundColor(_ color: UIColor) {
        delegate?.didSelectBackgroundColor(color)
    }

    @objc private func selectTextColor() {
        delegate?.selectTextColor()
    }

    @objc private func selectFont() {
        delegate?.selectFont()
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
    
    @objc private func showControls() {
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

            // Present the navigation controller
            viewController?.present(
                navigationController,
                animated: true,
                completion: nil
            )
        }
    }
    
    @objc private func selectBackgroundImage() {
        delegate?.selectBackgroundImage()
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
}
