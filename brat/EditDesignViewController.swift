import UIKit

class EditDesignViewController: UIViewController {

    private lazy var textView: UITextView = {
        let textView = UITextView(frame: CGRect(x: -500, y: -500, width: 0, height: 0))
        textView.textAlignment = .center
        textView.autocapitalizationType = .none
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.smartInsertDeleteType = .no
        textView.alpha = 0
        textView.delegate = self
        addTap(to: textView)
        return textView
    }()

    private lazy var previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        addTap(to: imageView)
        return imageView
    }()
    private var originalText: String = ""
    private var originalBackgroundColor: UIColor = .white
    private var isPickingTextColor = false
    private var isPickingCustomColor = false
    internal let settingsManager: SettingsManager
    private let imageService: ImageService
    private var previewImageViewBottomConstraint: NSLayoutConstraint?
    private var previewImageViewTopSwatchConstraint: NSLayoutConstraint?
    private var previewImageViewTopSafeAreaConstraint: NSLayoutConstraint?
    private var previewImageViewAspectRatioConstraint: NSLayoutConstraint?
    private var isDesignControlsModeActive = false
    private lazy var keyboardOptionsView = KeyboardOptionsView(settingsManager: settingsManager)

    private enum ColorSwatchMode { case tools, backgroundColor, textColor }
    private var colorSwatchMode: ColorSwatchMode = .tools { didSet { applySwatchMode() } }
    private var currentTintColor: UIColor = .label

    private let colorSwatchToggleButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "paintpalette"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = NSLocalizedString("show color swatches", comment: "")
        return button
    }()

    private let colorSwatchIndicatorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 7
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()

    private let colorSwatchScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = true
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

    private var colorSwatchIsTextMode: Bool { colorSwatchMode == .textColor }
    private var customPickedColors: [UIColor] = []
    private var toolsStackWidthConstraint: NSLayoutConstraint?
    private var scrollViewLeadingNormal: NSLayoutConstraint?
    private var scrollViewLeadingFull: NSLayoutConstraint?

    // MARK: - Focus mode
    private enum FocusState { case editing, distractionFree, fullScreen }
    private var focusState: FocusState = .editing
    private var distractionFreeTimer: Timer?
    private var fullScreenTimer: Timer?
    private var focusOverlayView: UIView?
    private var focusImageView: UIImageView?
    private var focusCloseButton: UIButton?
    private var focusShareButton: UIButton?

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

    var design: Design? {
        didSet {
            guard let design else {
                return
            }
            textView.text = design.text
        }
    }
    
    private lazy var backgroundColor: UIColor = {
        if let color = design?.backgroundColor {
            return color
        } else if let color = UIColor(hex: settingsManager.backgroundColorHex) {
            return color
        } else {
            return .systemBackground
        }
    }()

    private lazy var textColor: UIColor = {
        if let color = design?.textColor {
            return color
        } else {
            return UIColor(hexString: settingsManager.textColorHex)
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var fontName: String = design?.fontName ?? settingsManager.preferredFontName {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }
    
    private lazy var imageName: String = design?.backgroundImageKey ?? "" {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    
    private lazy var stretch: CGFloat = {
        if let size = design?.stretch {
            return size
        } else {
            return CGFloat(settingsManager.stretch)
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var blur: CGFloat = {
        if let size = design?.blur {
            return size
        } else {
            return CGFloat(settingsManager.blur)
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var fontSize: CGFloat = {
        if let size = design?.fontSize {
            return size
        } else {
            return CGFloat(settingsManager.preferredFontSize)
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var pixelationScale: CGFloat = CGFloat(design?.pixelationScale ?? CGFloat(settingsManager.pixelationScale)) {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var brightness: CGFloat = {
        if let value = design?.brightness {
            return value
        } else {
            return CGFloat(settingsManager.brightness)
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var contrast: CGFloat = {
        if let value = design?.contrast {
            return value
        } else {
            return CGFloat(settingsManager.contrast)
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var saturation: CGFloat = {
        if let value = design?.saturation {
            return value
        } else {
            return CGFloat(settingsManager.saturation)
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var exposure: CGFloat = {
        if let value = design?.exposure {
            return value
        } else {
            return CGFloat(settingsManager.exposure)
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var gamma: CGFloat = {
        if let value = design?.gamma {
            return value
        } else {
            return CGFloat(settingsManager.gamma)
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var sepia: CGFloat = {
        if let value = design?.sepia {
            return value
        } else {
            return CGFloat(settingsManager.sepia)
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var invert: Bool = {
        if let value = design?.invert {
            return value
        } else {
            return settingsManager.invert
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var pixelate: CGFloat = {
        if let value = design?.pixelate {
            return value
        } else {
            return CGFloat(settingsManager.pixelate)
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var sharpen: CGFloat = {
        if let value = design?.sharpen {
            return value
        } else {
            return CGFloat(settingsManager.sharpen)
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var monochrome: CGFloat = {
        if let value = design?.monochrome {
            return value
        } else {
            return CGFloat(settingsManager.monochrome)
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var vignette: CGFloat = {
        if let value = design?.vignette {
            return value
        } else {
            return CGFloat(settingsManager.vignette)
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }
    
    private lazy var backgroundBrightness: CGFloat = {
        if let brightness = design?.backgroundBrightness {
            return brightness
        } else {
            return settingsManager.backgroundBrightness
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var backgroundContrast: CGFloat = {
        if let contrast = design?.backgroundContrast {
            return contrast
        } else {
            return settingsManager.backgroundContrast
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var backgroundSaturation: CGFloat = {
        if let saturation = design?.backgroundSaturation {
            return saturation
        } else {
            return settingsManager.backgroundSaturation
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var backgroundExposure: CGFloat = {
        if let exposure = design?.backgroundExposure {
            return exposure
        } else {
            return settingsManager.backgroundExposure
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var backgroundGamma: CGFloat = {
        if let gamma = design?.backgroundGamma {
            return gamma
        } else {
            return settingsManager.backgroundGamma
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var backgroundSepia: CGFloat = {
        if let sepia = design?.backgroundSepia {
            return sepia
        } else {
            return settingsManager.backgroundSepia
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var backgroundInvert: Bool = {
        if let invert = design?.backgroundInvert {
            return invert
        } else {
            return settingsManager.backgroundInvert
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var backgroundPixelate: CGFloat = {
        if let pixelate = design?.backgroundPixelate {
            return pixelate
        } else {
            return settingsManager.backgroundPixelate
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var backgroundSharpen: CGFloat = {
        if let sharpen = design?.backgroundSharpen {
            return sharpen
        } else {
            return settingsManager.backgroundSharpen
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var backgroundMonochrome: CGFloat = {
        if let monochrome = design?.backgroundMonochrome {
            return monochrome
        } else {
            return settingsManager.backgroundMonochrome
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var backgroundVignette: CGFloat = {
        if let vignette = design?.backgroundVignette {
            return vignette
        } else {
            return settingsManager.backgroundVignette
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var backgroundScale: CGFloat = {
        if let scale = design?.backgroundScale {
            return scale
        } else {
            return settingsManager.backgroundScale
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var backgroundFlipHorizontal: Bool = {
        if let flipHorizontal = design?.backgroundFlipHorizontal {
            return flipHorizontal
        } else {
            return settingsManager.backgroundFlipHorizontal
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var backgroundFlipVertical: Bool = {
        if let flipVertical = design?.backgroundFlipVertical {
            return flipVertical
        } else {
            return settingsManager.backgroundFlipVertical
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var backgroundBlur: CGFloat = {
        if let blur = design?.backgroundBlur {
            return blur
        } else {
            return settingsManager.backgroundBlur
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }

    private lazy var backgroundAlpha: CGFloat = {
        if let alpha = design?.backgroundAlpha {
            return alpha
        } else {
            return settingsManager.backgroundAlpha
        }
    }() {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }


    private var creationDate = Date()
    
    var currentDesign: Design {
        Design(
            text: textView.text,
            backgroundColor: backgroundColor,
            textColor: textColor,
            creationDate: creationDate,
            fontName: fontName,
            fontSize: fontSize,
            pixelationScale: pixelationScale,
            stretch: stretch,
            blur: blur,
            width: design?.width ?? settingsManager.xDimension,
            height: design?.height ?? settingsManager.yDimension,
            brightness: brightness,
            contrast: contrast,
            saturation: saturation,
            exposure: exposure,
            gamma: gamma,
            sepia: sepia,
            invert: invert,
            pixelate: pixelate,
            sharpen: sharpen,
            monochrome: monochrome,
            vignette: vignette,
            backgroundImageKey: imageName,
            backgroundScale: backgroundScale,
            backgroundFlipHorizontal: backgroundFlipHorizontal,
            backgroundFlipVertical: backgroundFlipVertical,
            backgroundBlur: backgroundBlur,
            backgroundAlpha: backgroundAlpha,
            backgroundBrightness: backgroundBrightness,
            backgroundContrast: backgroundContrast,
            backgroundSaturation: backgroundSaturation,
            backgroundExposure: backgroundExposure,
            backgroundGamma: backgroundGamma,
            backgroundSepia: backgroundSepia,
            backgroundInvert: backgroundInvert,
            backgroundPixelate: backgroundPixelate,
            backgroundSharpen: backgroundSharpen,
            backgroundMonochrome: backgroundMonochrome,
            backgroundVignette: backgroundVignette,
            id: design?.id ?? UUID()
        )
    }
    
    init(
        originalText: String,
        originalBackgroundColor: UIColor,
        design: Design? = nil,
        settingsManager: SettingsManager,
        imageService: ImageService
    ) {
        self.originalText = originalText
        self.originalBackgroundColor = originalBackgroundColor
        self.design = design
        self.settingsManager = settingsManager
        self.imageService = imageService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(canvasDimensionsDidChange),
            name: .canvasDimensionsDidChange,
            object: settingsManager
        )

        // Setup navigation bar
        var rightBarButtonItems: [UIBarButtonItem] = [
            .settings(self),
            .share {  [weak self] in
                self?.shareButtonTouched()
            }
        ]

        var isRunningOnMacCatalyst: Bool {
            #if targetEnvironment(macCatalyst)
            return true
            #else
            return false
            #endif
        }
        
        if !isRunningOnMacCatalyst {
            rightBarButtonItems.insert(UIBarButtonItem(
                image: UIImage(systemName: "keyboard"),
                style: .plain,
                target: self,
                action: #selector(toggleKeyboard)
            ), at: 0)
        }

        navigationItem.rightBarButtonItems = rightBarButtonItems

        // Setup color swatch row — toggle always visible on left, content scrolls in on right
        colorSwatchScrollView.addSubview(colorSwatchStackView)
        view.addSubview(colorSwatchToggleButton)
        view.addSubview(colorSwatchIndicatorView)
        view.addSubview(colorSwatchScrollView)
        colorSwatchToggleButton.addTarget(self, action: #selector(cycleSwatchMode), for: .touchUpInside)

        let leadingNormal = colorSwatchScrollView.leadingAnchor.constraint(equalTo: colorSwatchToggleButton.trailingAnchor, constant: 8)
        let leadingFull = colorSwatchScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12)
        scrollViewLeadingNormal = leadingNormal
        scrollViewLeadingFull = leadingFull
        leadingNormal.isActive = true

        NSLayoutConstraint.activate([
            colorSwatchToggleButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            colorSwatchToggleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            colorSwatchToggleButton.widthAnchor.constraint(equalToConstant: 30),
            colorSwatchToggleButton.heightAnchor.constraint(equalToConstant: 30),

            colorSwatchIndicatorView.widthAnchor.constraint(equalToConstant: 14),
            colorSwatchIndicatorView.heightAnchor.constraint(equalToConstant: 14),
            colorSwatchIndicatorView.trailingAnchor.constraint(equalTo: colorSwatchToggleButton.trailingAnchor, constant: 4),
            colorSwatchIndicatorView.bottomAnchor.constraint(equalTo: colorSwatchToggleButton.bottomAnchor, constant: 4),

            colorSwatchScrollView.centerYAnchor.constraint(equalTo: colorSwatchToggleButton.centerYAnchor),
            colorSwatchScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            colorSwatchScrollView.heightAnchor.constraint(equalToConstant: 38),

            colorSwatchStackView.topAnchor.constraint(equalTo: colorSwatchScrollView.topAnchor, constant: 4),
            colorSwatchStackView.leadingAnchor.constraint(equalTo: colorSwatchScrollView.leadingAnchor),
            colorSwatchStackView.trailingAnchor.constraint(equalTo: colorSwatchScrollView.trailingAnchor),
            colorSwatchStackView.bottomAnchor.constraint(equalTo: colorSwatchScrollView.bottomAnchor, constant: -4),
            colorSwatchStackView.heightAnchor.constraint(equalTo: colorSwatchScrollView.heightAnchor, constant: -8),
        ])

        // Setup preview image view
        view.addSubview(previewImageView)
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        let topSwatchConstraint = previewImageView.topAnchor.constraint(
            equalTo: colorSwatchToggleButton.bottomAnchor,
            constant: .su2
        )
        let topSafeAreaConstraint = previewImageView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: -162
        )
        previewImageViewTopSwatchConstraint = topSwatchConstraint
        previewImageViewTopSafeAreaConstraint = topSafeAreaConstraint
        NSLayoutConstraint.activate([
            topSwatchConstraint,
            previewImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .su2),
            previewImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.su2)
        ])
        previewImageViewBottomConstraint = previewImageView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: -300
        )
        previewImageViewBottomConstraint?.isActive = true

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handlePreviewLongPress(_:)))
        longPress.minimumPressDuration = 0.01
        previewImageView.addGestureRecognizer(longPress)

        // Setup keyboard options view
        keyboardOptionsView.delegate = self
        view.addSubview(keyboardOptionsView)
        keyboardOptionsView.translatesAutoresizingMaskIntoConstraints = false

        let keyboardOptionsViewHeight: CGFloat = {
            if UIDevice.current.userInterfaceIdiom == .phone {
                return 240
            } else if UIDevice.current.userInterfaceIdiom == .pad {
                return 160
            }
            return 300
        }()
        NSLayoutConstraint.activate([
            keyboardOptionsView.topAnchor.constraint(lessThanOrEqualTo: previewImageView.bottomAnchor, constant: .su2),
            keyboardOptionsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            keyboardOptionsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            keyboardOptionsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            keyboardOptionsView.heightAnchor.constraint(greaterThanOrEqualToConstant: keyboardOptionsViewHeight),
        ])
        
        view.backgroundColor = .systemBackground

        // Load design if exists
        if let design = design {
            textView.text = design.text
            originalText = design.text
            originalBackgroundColor = design.backgroundColor
        }
        
        // Show keyboard
        view.addSubview(textView)
        textView.becomeFirstResponder()
        textView.backgroundColor = .clear

        // Populate the swatch row with tool buttons immediately
        refreshToolButtons()

        updateDesignImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        apply(settingsManager.selectedTheme)
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        if let theme = settingsManager.selectedTheme {
            currentTintColor = isDarkMode ? theme.darkModeColors.tintColor : theme.lightModeColors.tintColor
        }
        keyboardOptionsView.update(with: currentDesign)
        pixelationScale = pixelationScale + .random(in: 0...0.001)
        updateDesignImage()
        pixelationScale = pixelationScale + .random(in: 0...0.001)
        textView.autocorrectionType = settingsManager.autocorrectionEnabled ? .yes : .no
    }
    
    override func viewDidAppear(_ animated: Bool) {
        pixelationScale = pixelationScale + .random(in: 0...0.001)
        updateDesignImage()
        pixelationScale = pixelationScale + .random(in: 0...0.001)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: DispatchWorkItem(block: { [weak self] in
            guard let self else {
                return
            }
            updateDesignImage()
        }))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveDesignIfNeeded()
    }
    
    private func updateWithDesign() {
        textView.backgroundColor = .clear
        if let design = design {
            textView.text = design.text
            originalText = design.text
            originalBackgroundColor = design.backgroundColor
        }
        updateDesignImage()
    }
    
    @objc func backButtonPressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func toggleKeyboard() {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        } else {
            textView.becomeFirstResponder()
        }
    }
    
    @objc func selectColor() {
        isPickingTextColor = false
        #if targetEnvironment(macCatalyst)
        MacColorPicker.shared.showColorPicker(initialColor: view.backgroundColor ?? .white) { [weak self] selectedColor in
            self?.applyBackgroundColor(selectedColor)
        }
        #else
        let colorPicker = UIColorPickerViewController()
        colorPicker.selectedColor = backgroundColor
        colorPicker.delegate = self
        present(colorPicker, animated: true, completion: nil)
        #endif
    }

    private func applyBackgroundColor(_ color: UIColor) {
        backgroundColor = color
        textView.backgroundColor = .clear
        settingsManager.addRecentBackgroundColor(color)
        keyboardOptionsView.update(with: currentDesign)
        updateDesignImage()
    }

    @objc func selectTextColor() {
        isPickingTextColor = true
        #if targetEnvironment(macCatalyst)
        MacColorPicker.shared.showColorPicker(initialColor: textColor) { [weak self] selectedColor in
            self?.textColor = selectedColor
            self?.updateDesignImage()
        }
        #else
        let colorPicker = UIColorPickerViewController()
        colorPicker.selectedColor = textColor
        colorPicker.delegate = self
        present(colorPicker, animated: true, completion: nil)
        #endif
    }
    
    private func saveDesignIfNeeded() {
        let text = textView.text
        let somethingHasChanged = text != originalText || view.backgroundColor != originalBackgroundColor
        guard let text,
              !text.isEmpty,
              somethingHasChanged else {
            return
        }
        
        let backgroundColor = self.backgroundColor
        
        DesignManager.shared.addDesign(currentDesign)

        settingsManager.backgroundColorHex = backgroundColor.toHexString()
        settingsManager.textColorHex = textColor.toHexString()
    }
    
    private var lastUpdateDate: Date?
    private var pendingImageUpdateWorkItem: DispatchWorkItem?
    private var previewImageGenerationID: UInt64 = 0
    private static var backgroundImageLoadFailedKeys = Set<String>()

    internal func updateDesignImage() {
        let timeLimit = blur > 1 ? 0.12 : 0.06
        if let lastUpdateDate,
           abs(lastUpdateDate.timeIntervalSinceNow) < timeLimit {
            pendingImageUpdateWorkItem?.cancel()
            let work = DispatchWorkItem { [weak self] in
                self?.performUpdateDesignImage()
            }
            pendingImageUpdateWorkItem = work
            DispatchQueue.main.asyncAfter(deadline: .now() + timeLimit, execute: work)
            return
        }
        pendingImageUpdateWorkItem?.cancel()
        pendingImageUpdateWorkItem = nil
        performUpdateDesignImage()
    }

    private func performUpdateDesignImage() {
        pendingImageUpdateWorkItem = nil
        lastUpdateDate = Date()
        previewImageGenerationID += 1
        let generationID = previewImageGenerationID

        let failedImageKey = imageName
        currentDesign.generateImage(
            with: imageService,
            onBackgroundImageLoadFailed: { [weak self] in
                guard let self,
                      generationID == self.previewImageGenerationID,
                      !failedImageKey.isEmpty,
                      EditDesignViewController.backgroundImageLoadFailedKeys.insert(failedImageKey).inserted
                else { return }
                ToastView.show(
                    message: NSLocalizedString(
                        "background_image_load_failed",
                        comment: "Toast shown when a design's background image cannot be loaded from disk"
                    ),
                    in: view
                )
            }
        ) { [weak self] returnedImage, _ in
            guard let self,
                  generationID == self.previewImageGenerationID,
                  let returnedImage else {
                return
            }
            if Thread.isMainThread {
                self.previewImageView.image = returnedImage
            } else {
                DispatchQueue.main.async {
                    guard generationID == self.previewImageGenerationID else { return }
                    self.previewImageView.image = returnedImage
                }
            }
        }
    }

    @objc private func canvasDimensionsDidChange() {
        if var d = design {
            d.width = settingsManager.xDimension
            d.height = settingsManager.yDimension
            design = d
        }
        keyboardOptionsView.update(with: currentDesign)
        updateDesignImage()
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard !isDesignControlsModeActive else { return }
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            previewImageViewBottomConstraint?.constant = -keyboardFrame.height
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: NSNotification) {
        guard !isDesignControlsModeActive else { return }
        previewImageViewBottomConstraint?.constant = -200
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func shareButtonTouched() {
        currentDesign.generateImage(with: imageService) { [weak self] imageToShare, _ in
            guard let imageToShare,
                    let self else {
                return
            }
            if Thread.isMainThread {
                share(image: imageToShare)
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self else {
                        return
                    }
                    share(image: imageToShare)
                }
            }
        }
    }
    private func share(image imageToShare: UIImage) {
        let activityViewController = UIActivityViewController(activityItems: [imageToShare], applicationActivities: nil)
        
        // For iPad: Popover presentation configuration
        if let popoverController = activityViewController.popoverPresentationController {
            popoverController.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - Focus mode methods

    @objc private func handlePreviewLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            distractionFreeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                self?.enterDistractionFreeMode()
                self?.fullScreenTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                    self?.enterFullScreenMode()
                }
            }
        case .ended, .cancelled, .failed:
            distractionFreeTimer?.invalidate()
            distractionFreeTimer = nil
            fullScreenTimer?.invalidate()
            fullScreenTimer = nil
            if focusState == .distractionFree {
                exitDistractionFreeMode(animated: true)
            } else if focusState == .editing, gesture.state == .ended {
                toggleKeyboard()
            }
        default: break
        }
    }

    private func enterDistractionFreeMode() {
        guard focusState == .editing else { return }
        focusState = .distractionFree
        textView.resignFirstResponder()
        navigationController?.setNavigationBarHidden(true, animated: true)
        UIView.animate(withDuration: 0.25) {
            self.colorSwatchToggleButton.alpha = 0
            self.colorSwatchIndicatorView.alpha = 0
            self.colorSwatchScrollView.alpha = 0
            self.keyboardOptionsView.alpha = 0
        }
        view.bringSubviewToFront(previewImageView)
    }

    private func exitDistractionFreeMode(animated: Bool) {
        guard focusState == .distractionFree else { return }
        focusState = .editing
        navigationController?.setNavigationBarHidden(false, animated: animated)
        UIView.animate(withDuration: animated ? 0.25 : 0) {
            self.colorSwatchToggleButton.alpha = 1
            self.colorSwatchIndicatorView.alpha = 1
            self.colorSwatchScrollView.alpha = 1
            self.keyboardOptionsView.alpha = 1
        }
    }

    private func enterDesignControlsMode() {
        isDesignControlsModeActive = true
        textView.resignFirstResponder()
        navigationController?.setNavigationBarHidden(true, animated: true)

        previewImageViewTopSwatchConstraint?.isActive = false
        previewImageViewTopSafeAreaConstraint?.isActive = true

        // Lock the image view to the rendered image's aspect ratio so scaleAspectFit has
        // no room to add blank padding above/below the image.
        if let image = previewImageView.image, image.size.width > 0 {
            let ratio = image.size.height / image.size.width
            let aspectConstraint = previewImageView.heightAnchor.constraint(
                equalTo: previewImageView.widthAnchor,
                multiplier: ratio
            )
            aspectConstraint.priority = .defaultHigh
            aspectConstraint.isActive = true
            previewImageViewAspectRatioConstraint = aspectConstraint
        }

        // Use <= so the aspect-ratio-sized view can't grow past the modal top.
        previewImageViewBottomConstraint?.isActive = false
        previewImageViewBottomConstraint = previewImageView.bottomAnchor.constraint(
            lessThanOrEqualTo: keyboardOptionsView.topAnchor,
            constant: -8
        )
        previewImageViewBottomConstraint?.isActive = true

        UIView.animate(withDuration: 0.25) {
            self.colorSwatchToggleButton.alpha = 0
            self.colorSwatchIndicatorView.alpha = 0
            self.colorSwatchScrollView.alpha = 0
            self.view.layoutIfNeeded()
        }
    }

    private func exitDesignControlsMode() {
        isDesignControlsModeActive = false
        navigationController?.setNavigationBarHidden(false, animated: true)

        previewImageViewTopSafeAreaConstraint?.isActive = false
        previewImageViewTopSwatchConstraint?.isActive = true

        previewImageViewAspectRatioConstraint?.isActive = false
        previewImageViewAspectRatioConstraint = nil

        previewImageViewBottomConstraint?.isActive = false
        previewImageViewBottomConstraint = previewImageView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: -300
        )
        previewImageViewBottomConstraint?.isActive = true

        UIView.animate(withDuration: 0.25) {
            self.colorSwatchToggleButton.alpha = 1
            self.colorSwatchIndicatorView.alpha = 1
            self.colorSwatchScrollView.alpha = 1
            self.view.layoutIfNeeded()
        }
    }

    private func enterFullScreenMode() {
        guard focusState == .distractionFree, let window = view.window else { return }
        focusState = .fullScreen

        let startFrame = previewImageView.convert(previewImageView.bounds, to: window)

        let overlay = UIView(frame: window.bounds)
        overlay.backgroundColor = .black
        overlay.alpha = 0
        window.addSubview(overlay)
        focusOverlayView = overlay

        let imageView = UIImageView(frame: startFrame)
        imageView.image = previewImageView.image
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.isUserInteractionEnabled = true
        window.addSubview(imageView)
        focusImageView = imageView

        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        closeButton.layer.cornerRadius = 16
        closeButton.alpha = 0
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(exitFullScreenMode), for: .touchUpInside)
        window.addSubview(closeButton)
        focusCloseButton = closeButton
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 12),
            closeButton.trailingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
        ])

        let shareButton = UIButton(type: .system)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.tintColor = .white
        shareButton.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        shareButton.layer.cornerRadius = 22
        shareButton.alpha = 0
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.addTarget(self, action: #selector(shareFocusedImage), for: .touchUpInside)
        window.addSubview(shareButton)
        focusShareButton = shareButton
        NSLayoutConstraint.activate([
            shareButton.bottomAnchor.constraint(equalTo: window.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            shareButton.leadingAnchor.constraint(equalTo: window.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            shareButton.widthAnchor.constraint(equalToConstant: 44),
            shareButton.heightAnchor.constraint(equalToConstant: 44),
        ])

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleFocusPan(_:)))
        imageView.addGestureRecognizer(pan)

        window.layoutIfNeeded()
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5) {
            overlay.alpha = 1
            imageView.frame = window.bounds
            closeButton.alpha = 1
        }
    }

    @objc private func exitFullScreenMode() {
        guard focusState == .fullScreen, let window = view.window else { return }
        let targetFrame = previewImageView.convert(previewImageView.bounds, to: window)
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5) {
            self.focusImageView?.frame = targetFrame
            self.focusOverlayView?.alpha = 0
            self.focusCloseButton?.alpha = 0
        } completion: { _ in
            self.tearDownFullScreenOverlay()
            self.exitDistractionFreeMode(animated: true)
        }
    }

    private func tearDownFullScreenOverlay() {
        focusImageView?.removeFromSuperview()
        focusOverlayView?.removeFromSuperview()
        focusCloseButton?.removeFromSuperview()
        focusShareButton?.removeFromSuperview()
        focusImageView = nil
        focusOverlayView = nil
        focusCloseButton = nil
        focusShareButton = nil
        focusState = .distractionFree
    }

    @objc private func handleFocusPan(_ gesture: UIPanGestureRecognizer) {
        guard let window = view.window,
              let imageView = focusImageView,
              let overlay = focusOverlayView else { return }

        let translation = gesture.translation(in: window)
        let velocity = gesture.velocity(in: window)

        switch gesture.state {
        case .changed:
            if translation.y > 0 {
                let progress = min(translation.y / (window.bounds.height * 0.5), 1.0)
                let targetFrame = previewImageView.convert(previewImageView.bounds, to: window)
                imageView.frame = interpolateFocusFrame(from: window.bounds, to: targetFrame, progress: progress)
                overlay.alpha = 1 - progress * 0.9
                focusCloseButton?.alpha = 1 - progress
                focusShareButton?.alpha = 0
            } else if translation.y < 0 {
                let progress = min(-translation.y / (window.bounds.height * 0.25), 1.0)
                focusShareButton?.alpha = progress
                imageView.frame = CGRect(
                    x: 0,
                    y: translation.y * 0.08,
                    width: window.bounds.width,
                    height: window.bounds.height
                )
                focusCloseButton?.alpha = 1
            }

        case .ended, .cancelled:
            if translation.y > 0 {
                let shouldDismiss = translation.y > window.bounds.height * 0.5 * 0.3 || velocity.y > 400
                if shouldDismiss {
                    let targetFrame = previewImageView.convert(previewImageView.bounds, to: window)
                    UIView.animate(withDuration: 0.35, delay: 0,
                                   usingSpringWithDamping: 0.85, initialSpringVelocity: 0.5) {
                        imageView.frame = targetFrame
                        overlay.alpha = 0
                        self.focusCloseButton?.alpha = 0
                    } completion: { _ in
                        self.tearDownFullScreenOverlay()
                        self.exitDistractionFreeMode(animated: true)
                    }
                } else {
                    snapFocusBackToFullScreen(in: window)
                }
            } else if translation.y < 0 {
                let shouldShare = -translation.y > window.bounds.height * 0.25 * 0.3 || velocity.y < -400
                snapFocusBackToFullScreen(in: window)
                if shouldShare {
                    shareFocusedImage()
                }
            }

        default: break
        }
    }

    private func interpolateFocusFrame(from: CGRect, to: CGRect, progress: CGFloat) -> CGRect {
        CGRect(
            x: from.minX + (to.minX - from.minX) * progress,
            y: from.minY + (to.minY - from.minY) * progress,
            width: from.width + (to.width - from.width) * progress,
            height: from.height + (to.height - from.height) * progress
        )
    }

    private func snapFocusBackToFullScreen(in window: UIWindow) {
        guard let imageView = focusImageView else { return }
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            imageView.frame = window.bounds
            self.focusOverlayView?.alpha = 1
            self.focusCloseButton?.alpha = 1
            self.focusShareButton?.alpha = 0
        }
    }

    @objc private func shareFocusedImage() {
        shareButtonTouched()
    }

    private func addTap(to viewToAddTap: UIView) {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(toggleKeyboard)
        )
        viewToAddTap.addGestureRecognizer(tap)
        viewToAddTap.isUserInteractionEnabled = true
    }
}

extension EditDesignViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if settingsManager.forceLowercase {
            textView.text = textView.text.localizedLowercase
        }
        updateDesignImage()
    }
}

extension UIImage {
    func scaled(by scale: CGFloat, flipHorizontal: Bool = false, flipVertical: Bool = false, crop: CGFloat = 3) -> UIImage? {
        let size = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        
        // Create a bitmap graphics context of the scaled size
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Set up transformations
        context.saveGState()
        
        if flipHorizontal {
            context.translateBy(x: size.width, y: 0)
            context.scaleBy(x: -1.0, y: 1.0)
        }
        
        if !flipVertical {
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0)
        }
        
        // Draw the image in the context with high-quality interpolation
        context.interpolationQuality = .high
        context.draw(self.cgImage!, in: CGRect(origin: .zero, size: size).insetBy(dx: -crop, dy: -crop))
        
        // Restore the context to its original state
        context.restoreGState()
        
        // Extract the scaled image from the context
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}

extension EditDesignViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        if isPickingTextColor {
            textColor = viewController.selectedColor
        } else {
            backgroundColor = viewController.selectedColor
            textView.backgroundColor = .clear
        }
        updateDesignImage()
    }

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let color = viewController.selectedColor
        if isPickingCustomColor {
            isPickingCustomColor = false
            applyCustomColor(color)
            return
        }
        if isPickingTextColor {
            textColor = color
            settingsManager.textColorHex = color.toHexString()
            if colorSwatchMode == .textColor { refreshColorSwatches(currentColor: color) }
        } else {
            applyBackgroundColor(color)
            settingsManager.backgroundColorHex = color.toHexString()
            if colorSwatchMode == .backgroundColor { refreshColorSwatches(currentColor: color) }
        }
        updateDesignImage()
    }
}

extension UIColor {
    convenience init?(hex: String) {
        let r, g, b: CGFloat
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat(hexNumber & 0x0000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: 1.0)
                    return
                }
            }
        }
        return nil
    }
    
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02lX%02lX%02lX", lroundf(Float(r * 255)), lroundf(Float(g * 255)), lroundf(Float(b * 255)))
    }
}

extension EditDesignViewController {
    @objc private func cycleSwatchMode() {
        switch colorSwatchMode {
        case .tools: colorSwatchMode = .backgroundColor
        case .backgroundColor: colorSwatchMode = .textColor
        case .textColor: colorSwatchMode = .tools
        }
    }

    private func applySwatchMode() {
        let iconName: String
        let accessLabel: String
        switch colorSwatchMode {
        case .tools:
            iconName = "ellipsis"
            accessLabel = NSLocalizedString("show tools", comment: "")
        case .backgroundColor:
            iconName = "square.fill"
            accessLabel = NSLocalizedString("color swatches: background", comment: "")
        case .textColor:
            iconName = "character"
            accessLabel = NSLocalizedString("color swatches: text", comment: "")
        }
        colorSwatchToggleButton.setImage(UIImage(systemName: iconName), for: .normal)
        colorSwatchToggleButton.accessibilityLabel = accessLabel
        colorSwatchIndicatorView.isHidden = (colorSwatchMode == .tools)

        switch colorSwatchMode {
        case .tools:
            refreshToolButtons()
        case .backgroundColor:
            colorSwatchIndicatorView.backgroundColor = backgroundColor
            refreshColorSwatches(currentColor: backgroundColor)
        case .textColor:
            colorSwatchIndicatorView.backgroundColor = textColor
            refreshColorSwatches(currentColor: textColor)
        }
    }

    private func refreshToolButtons() {
        colorSwatchStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        colorSwatchStackView.distribution = .equalSpacing
        colorSwatchStackView.spacing = 0
        toolsStackWidthConstraint = colorSwatchStackView.widthAnchor.constraint(equalTo: colorSwatchScrollView.widthAnchor)
        toolsStackWidthConstraint?.isActive = true

        scrollViewLeadingNormal?.isActive = false
        scrollViewLeadingFull?.isActive = true
        colorSwatchToggleButton.isHidden = true
        colorSwatchIndicatorView.isHidden = true

        let items: [(String, String, Selector)] = [
            ("paintpalette",        "Color Mode",        #selector(cycleSwatchMode)),
            ("textformat",          "Font Picker",       #selector(selectFont)),
            ("slider.horizontal.3", "Controls",          #selector(showControlsFromToolbar)),
            ("photo",               "Background Image",  #selector(selectBackgroundImage)),
        ]
        for (icon, label, action) in items {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: icon), for: .normal)
            button.tintColor = currentTintColor
            button.accessibilityLabel = NSLocalizedString(label, comment: "")
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 30),
                button.heightAnchor.constraint(equalToConstant: 30),
            ])
            button.addTarget(self, action: action, for: .touchUpInside)
            colorSwatchStackView.addArrangedSubview(button)
        }
    }

    @objc private func showControlsFromToolbar() {
        keyboardOptionsView.showControls()
    }

    private func refreshColorSwatches(currentColor: UIColor) {
        colorSwatchStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        toolsStackWidthConstraint?.isActive = false
        toolsStackWidthConstraint = nil
        colorSwatchStackView.distribution = .fill
        colorSwatchStackView.spacing = 8

        scrollViewLeadingFull?.isActive = false
        scrollViewLeadingNormal?.isActive = true
        colorSwatchToggleButton.isHidden = false
        colorSwatchIndicatorView.isHidden = false

        for color in Self.presetColors {
            colorSwatchStackView.addArrangedSubview(
                makeSwatchButton(color: color, isCurrent: color.toHexString() == currentColor.toHexString())
            )
        }

        colorSwatchStackView.addArrangedSubview(makeRainbowPickerButton())

        for color in customPickedColors {
            colorSwatchStackView.addArrangedSubview(
                makeSwatchButton(color: color, isCurrent: color.toHexString() == currentColor.toHexString())
            )
        }
    }

    private func makeSwatchButton(color: UIColor, isCurrent: Bool) -> UIButton {
        let button = UIButton(type: .custom)
        button.backgroundColor = color
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.layer.borderWidth = isCurrent ? 2.5 : 1
        button.layer.borderColor = isCurrent ? currentTintColor.cgColor : UIColor.gray.withAlphaComponent(0.4).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 30),
            button.heightAnchor.constraint(equalToConstant: 30),
        ])
        button.addAction(UIAction { [weak self, weak button] _ in
            guard let self else { return }
            if self.colorSwatchIsTextMode {
                self.didSelectTextColorFromSwatch(color)
            } else {
                self.didSelectBackgroundColor(color)
            }
            self.colorSwatchStackView.arrangedSubviews.compactMap { $0 as? UIButton }.forEach {
                $0.layer.borderWidth = 1
                $0.layer.borderColor = UIColor.gray.withAlphaComponent(0.4).cgColor
            }
            button?.layer.borderWidth = 2.5
            button?.layer.borderColor = self.currentTintColor.cgColor
        }, for: .touchUpInside)
        return button
    }

    private func makeRainbowPickerButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.gray.withAlphaComponent(0.4).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 30),
            button.heightAnchor.constraint(equalToConstant: 30),
        ])
        let gradient = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        gradient.colors = [
            UIColor.systemRed.cgColor, UIColor.systemOrange.cgColor,
            UIColor.systemYellow.cgColor, UIColor.systemGreen.cgColor,
            UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor,
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        button.layer.insertSublayer(gradient, at: 0)
        button.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.isPickingTextColor = self.colorSwatchIsTextMode
            self.isPickingCustomColor = true
            #if targetEnvironment(macCatalyst)
            let initialColor = self.colorSwatchIsTextMode ? self.textColor : self.backgroundColor
            MacColorPicker.shared.showColorPicker(initialColor: initialColor) { [weak self] selectedColor in
                self?.applyCustomColor(selectedColor)
            }
            #else
            let colorPicker = UIColorPickerViewController()
            colorPicker.selectedColor = self.colorSwatchIsTextMode ? self.textColor : self.backgroundColor
            colorPicker.delegate = self
            self.present(colorPicker, animated: true)
            #endif
        }, for: .touchUpInside)
        return button
    }

    private func applyCustomColor(_ color: UIColor) {
        customPickedColors.append(color)
        if colorSwatchIsTextMode {
            didSelectTextColorFromSwatch(color)
        } else {
            didSelectBackgroundColor(color)
        }
    }
}

extension EditDesignViewController: KeyboardOptionsViewDelegate {
    func didChangeBrightness(_ brightness: CGFloat) {
        self.brightness = brightness
        updateDesignImage()
    }
    
    func didChangeContrast(_ contrast: CGFloat) {
        self.contrast = contrast
        updateDesignImage()
    }
    
    func didChangeSaturation(_ saturation: CGFloat) {
        self.saturation = saturation
        updateDesignImage()
    }
    
    func didChangeExposure(_ exposure: CGFloat) {
        self.exposure = exposure
        updateDesignImage()
    }
    
    func didChangeGamma(_ gamma: CGFloat) {
        self.gamma = gamma
        updateDesignImage()
    }
    
    func didChangeSepia(_ sepia: CGFloat) {
        self.sepia = sepia
        updateDesignImage()
    }
    
    func didChangeInvert(_ invert: Bool) {
        self.invert = invert
        updateDesignImage()
    }
    
    func didChangePixelate(_ pixelate: CGFloat) {
        self.pixelate = pixelate
        updateDesignImage()
    }
    
    func didChangeSharpen(_ sharpen: CGFloat) {
        self.sharpen = sharpen
        updateDesignImage()
    }
    
    func didChangeMonochrome(_ monochrome: CGFloat) {
        self.monochrome = monochrome
        updateDesignImage()
    }
    
    func didChangeVignette(_ vignette: CGFloat) {
        self.vignette = vignette
        updateDesignImage()
    }
    
    func didChangeBackgroundScale(_ scale: CGFloat) {
        self.backgroundScale = scale
        updateDesignImage()
    }
    
    func didChangeBackgroundFlipHorizontal(_ flip: Bool) {
        self.backgroundFlipHorizontal = flip
        updateDesignImage()
    }
    
    func didChangeBackgroundFlipVertical(_ flip: Bool) {
        self.backgroundFlipVertical = flip
        updateDesignImage()
    }
    
    func didChangeBackgroundBlur(_ blur: CGFloat) {
        self.backgroundBlur = blur
        updateDesignImage()
    }
    
    func didChangeBackgroundAlpha(_ alpha: CGFloat) {
        self.backgroundAlpha = alpha
        updateDesignImage()
    }
    
    func didChangeBackgroundBrightness(_ brightness: CGFloat) {
        self.backgroundBrightness = brightness
        updateDesignImage()
    }
    
    func didChangeBackgroundContrast(_ contrast: CGFloat) {
        self.backgroundContrast = contrast
        updateDesignImage()
    }
    
    func didChangeBackgroundSaturation(_ saturation: CGFloat) {
        self.backgroundSaturation = saturation
        updateDesignImage()
    }
    
    func didChangeBackgroundExposure(_ exposure: CGFloat) {
        self.backgroundExposure = exposure
        updateDesignImage()
    }
    
    func didChangeBackgroundGamma(_ gamma: CGFloat) {
        self.backgroundGamma = gamma
        updateDesignImage()
    }
    
    func didChangeBackgroundSepia(_ sepia: CGFloat) {
        self.backgroundSepia = sepia
        updateDesignImage()
    }
    
    func didChangeBackgroundInvert(_ invert: Bool) {
        self.backgroundInvert = invert
        updateDesignImage()
    }
    
    func didChangeBackgroundPixelate(_ pixelate: CGFloat) {
        self.backgroundPixelate = pixelate
        updateDesignImage()
    }
    
    func didChangeBackgroundSharpen(_ sharpen: CGFloat) {
        self.backgroundSharpen = sharpen
        updateDesignImage()
    }
    
    func didChangeBackgroundMonochrome(_ monochrome: CGFloat) {
        self.backgroundMonochrome = monochrome
        updateDesignImage()
    }
    
    func didChangeBackgroundVignette(_ vignette: CGFloat) {
        self.backgroundVignette = vignette
        updateDesignImage()
    }
    
    
    func designControlsViewController(
        _ controller: DesignControlsViewController,
        didUpdateDesign design: Design
    ) {
        textColor = design.textColor
        stretch = design.stretch
        blur = design.blur
        fontSize = design.fontSize
        pixelationScale = design.pixelationScale
        brightness = design.brightness
        contrast = design.contrast
        saturation = design.saturation
        exposure = design.exposure
        gamma = design.gamma
        sepia = design.sepia
        invert = design.invert
        pixelate = design.pixelate
        sharpen = design.sharpen
        monochrome = design.monochrome
        vignette = design.vignette
        backgroundBrightness = design.backgroundBrightness
        backgroundContrast = design.backgroundContrast
        backgroundSaturation = design.backgroundSaturation
        backgroundExposure = design.backgroundExposure
        backgroundGamma = design.backgroundGamma
        backgroundSepia = design.backgroundSepia
        backgroundInvert = design.backgroundInvert
        backgroundPixelate = design.backgroundPixelate
        backgroundSharpen = design.backgroundSharpen
        backgroundMonochrome = design.backgroundMonochrome
        backgroundVignette = design.backgroundVignette
        backgroundScale = design.backgroundScale
        backgroundFlipHorizontal = design.backgroundFlipHorizontal
        backgroundFlipVertical = design.backgroundFlipVertical
        backgroundBlur = design.backgroundBlur
        backgroundAlpha = design.backgroundAlpha
        updateDesignImage()
    }

    func stretchChanged(to newStretch: CGFloat) {
        stretch = newStretch
    }
    
    func blurChanged(to newBlur: CGFloat) {
        blur = newBlur
    }
    
    func fontSizeChanged(to newFontSize: CGFloat) {
        fontSize = newFontSize
    }
    
    @objc func selectFont() {
        showFontPicker { [weak self] in
            self?.updateDesignImage()
        }
    }
    
    func pixelationScaleChanged(to newPixelationScale: CGFloat) {
        pixelationScale = newPixelationScale
    }
    
    private func showFontPicker(_ completion: @escaping () -> Void) {
        let fontViewController = FontsViewController(settingsManager: settingsManager) { [weak self] fontName in
            guard let self else {
                return
            }
            settingsManager.preferredFontName = fontName
            self.fontName = fontName
            completion()
        }
        
        present(fontViewController)
    }
    
    @objc internal func selectBackgroundImage() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(
            imagePicker,
            animated: true,
            completion: nil
        )
    }

    func didSelectBackgroundColor(_ color: UIColor) {
        applyBackgroundColor(color)
        if colorSwatchMode == .backgroundColor {
            colorSwatchIndicatorView.backgroundColor = color
            refreshColorSwatches(currentColor: color)
        }
    }

    func didSelectTextColorFromSwatch(_ color: UIColor) {
        textColor = color
        settingsManager.textColorHex = color.toHexString()
        updateDesignImage()
        if colorSwatchMode == .textColor {
            colorSwatchIndicatorView.backgroundColor = color
            refreshColorSwatches(currentColor: color)
        }
    }

    func keyboardOptionsViewWillShowDesignControls() {
        enterDesignControlsMode()
    }

    func keyboardOptionsViewDidDismissDesignControls() {
        exitDesignControlsMode()
    }
}

extension EditDesignViewController: SettingsReferenceable {
    
}

extension EditDesignViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[.originalImage] as? UIImage else {
            return
        }
        
        let imageName = UUID().uuidString
        imageService.saveImageToDisk(
            selectedImage,
            addToInMemoryCache: true,
            withName: imageName,
            compressionQuality: 0.7
        )
        self.imageName = imageName
        
        updateDesignImage()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
