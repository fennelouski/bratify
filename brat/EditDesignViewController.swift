import SwiftUI
import UIKit
import WebImagePicker

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
    private var previewImageViewTopCanvasConstraint: NSLayoutConstraint?
    private var previewImageViewBottomCanvasConstraint: NSLayoutConstraint?
    private var previewImageViewAspectRatioConstraint: NSLayoutConstraint?
    private var isDesignControlsModeActive = false
    private var isEditingChromeVisible = false
    private lazy var keyboardOptionsView = KeyboardOptionsView(settingsManager: settingsManager)
    private var keyboardOptionsHeightConstraint: NSLayoutConstraint?
    private let macKeyboardOptionsExpandedHeight: CGFloat = 300

    private var usesMacCollapsibleBottomPanel: Bool {
        #if targetEnvironment(macCatalyst)
        return true
        #else
        return UIDevice.current.userInterfaceIdiom == .mac
        #endif
    }

    private weak var primarySlidersToggleButton: UIButton?
    private weak var controlsToolbarButton: UIButton?
    private weak var stylesToolbarButton: UIButton?
    private weak var backgroundImageToolbarButton: UIButton?
    private weak var settingsToolbarButton: UIButton?
    private var lastAppliedPresetID: String?
    private weak var settingsNavBarButton: UIBarButtonItem?

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

    private let fontPickerSidebarContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()

    private let fontPickerSidebarSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()

    private var fontPickerSidebarWidthConstraint: NSLayoutConstraint?
    private var previewImageViewTrailingToViewConstraint: NSLayoutConstraint?
    private var previewImageViewTrailingToSidebarConstraint: NSLayoutConstraint?
    private var embeddedFontPickerViewController: FontsViewController?
    private var embeddedWebImagePickerHostingController: UIHostingController<WebImagePicker>?
    private var embeddedAspectRatioPickerViewController: AspectRatioPickerViewController?
    private weak var fontPickerToolbarButton: UIButton?
    private weak var webImportToolbarButton: UIButton?
    private weak var aspectRatioToolbarButton: UIButton?

    private enum TrailingSidebarContent {
        case fontPicker
        case webImages
        case aspectRatio
    }

    private var activeTrailingSidebar: TrailingSidebarContent?

    private var isTrailingSidebarVisible: Bool {
        activeTrailingSidebar != nil
    }

    private var isFontPickerSidebarVisible: Bool {
        activeTrailingSidebar == .fontPicker
    }

    private var isWebImageSidebarVisible: Bool {
        activeTrailingSidebar == .webImages
    }

    private var isAspectRatioSidebarVisible: Bool {
        activeTrailingSidebar == .aspectRatio
    }

    private enum LeadingSidebarContent {
        case backgroundImage
        case settings
        case filterStyles
    }

    private var embeddedSettingsNavigationController: UINavigationController?
    private var activeLeadingSidebar: LeadingSidebarContent?

    private var isLeadingSidebarVisible: Bool {
        activeLeadingSidebar != nil
    }

    private var isImagePickerSidebarVisible: Bool {
        activeLeadingSidebar == .backgroundImage
    }

    private let imagePickerSidebarContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()

    private let imagePickerSidebarSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()

    private var imagePickerSidebarWidthConstraint: NSLayoutConstraint?
    private var previewImageViewLeadingToViewConstraint: NSLayoutConstraint?
    private var previewImageViewLeadingToSidebarConstraint: NSLayoutConstraint?
    private var embeddedBackgroundImagePickerViewController: BackgroundImagePickerViewController?
    private var embeddedFilterStylesViewController: FilterStylesViewController?

    private let editorBottomPanelContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()

    private var editorBottomPanelHeightConstraint: NSLayoutConstraint?
    private var activeEditorPanel: EditorPanel?

    private var isEditorBottomPanelVisible: Bool {
        activeEditorPanel != nil
    }

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

    private var usesAutomaticTextColor = true
    private var customTextColor: UIColor = .white

    /// Resolved light/dark appearance for the editor chrome and preview rendering.
    private var resolvedInterfaceStyle: UIUserInterfaceStyle {
        DesignTextColor.resolvedUserInterfaceStyle(
            traitCollection.userInterfaceStyle,
            traitCollection: traitCollection,
            view: isViewLoaded ? view : nil
        )
    }

    private var resolvedEditingTextColor: UIColor {
        currentDesign.resolvedTextColor(for: resolvedInterfaceStyle)
    }

    private func configureTextColorState() {
        if let design {
            usesAutomaticTextColor = design.usesAutomaticTextColor
            customTextColor = design.textColor
        } else {
            usesAutomaticTextColor = settingsManager.usesAutomaticDefaultTextColor
            customTextColor = UIColor(hexString: settingsManager.textColorHex)
        }
    }

    private func setTextColor(_ color: UIColor, isUserChosen: Bool) {
        if isUserChosen {
            usesAutomaticTextColor = false
            customTextColor = color
            settingsManager.textColorHex = color.toHexString()
            settingsManager.usesAutomaticDefaultTextColor = false
        }
        keyboardOptionsView.update(with: currentDesign)
        if colorSwatchMode == .textColor {
            colorSwatchIndicatorView.backgroundColor = resolvedEditingTextColor
            refreshColorSwatches(currentColor: resolvedEditingTextColor)
        }
        updateDesignImage()
    }

    private func setAutomaticTextColor() {
        guard !usesAutomaticTextColor else { return }
        usesAutomaticTextColor = true
        keyboardOptionsView.update(with: currentDesign)
        if colorSwatchMode == .textColor {
            colorSwatchIndicatorView.backgroundColor = resolvedEditingTextColor
            refreshColorSwatches(currentColor: resolvedEditingTextColor)
        }
        updateDesignImage()
    }

    private lazy var fontName: String = design?.fontName ?? settingsManager.preferredFontName {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
        }
    }
    
    private lazy var imageName: String = design?.backgroundImageKey ?? "" {
        didSet {
            keyboardOptionsView.update(with: currentDesign)
            reloadAspectRatioSidebarNativeImageIfNeeded()
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

    private lazy var hue: CGFloat = design?.hue ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var highlightAmount: CGFloat = design?.highlightAmount ?? 1 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var shadowAmount: CGFloat = design?.shadowAmount ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var grain: CGFloat = design?.grain ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var bloom: CGFloat = design?.bloom ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var duotoneIntensity: CGFloat = design?.duotoneIntensity ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var duotoneColorHex: String = design?.duotoneColorHex ?? "8ACE00"
    private lazy var vibrance: CGFloat = design?.vibrance ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var posterizeLevels: CGFloat = design?.posterizeLevels ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var colorTemperature: CGFloat = design?.colorTemperature ?? 6500 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var colorTint: CGFloat = design?.colorTint ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var photoEffect: FilterPhotoEffect? = design?.photoEffect
    private lazy var halftone: CGFloat = design?.halftone ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var unsharpMask: CGFloat = design?.unsharpMask ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
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

    private lazy var backgroundHue: CGFloat = design?.backgroundHue ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var backgroundHighlightAmount: CGFloat = design?.backgroundHighlightAmount ?? 1 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var backgroundShadowAmount: CGFloat = design?.backgroundShadowAmount ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var backgroundGrain: CGFloat = design?.backgroundGrain ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var backgroundBloom: CGFloat = design?.backgroundBloom ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var backgroundDuotoneIntensity: CGFloat = design?.backgroundDuotoneIntensity ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var backgroundDuotoneColorHex: String = design?.backgroundDuotoneColorHex ?? "8ACE00"
    private lazy var backgroundVibrance: CGFloat = design?.backgroundVibrance ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var backgroundPosterizeLevels: CGFloat = design?.backgroundPosterizeLevels ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var backgroundColorTemperature: CGFloat = design?.backgroundColorTemperature ?? 6500 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var backgroundColorTint: CGFloat = design?.backgroundColorTint ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var backgroundPhotoEffect: FilterPhotoEffect? = design?.backgroundPhotoEffect
    private lazy var backgroundHalftone: CGFloat = design?.backgroundHalftone ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
    }
    private lazy var backgroundUnsharpMask: CGFloat = design?.backgroundUnsharpMask ?? 0 {
        didSet { keyboardOptionsView.update(with: currentDesign) }
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
    private var canvasWidth: CGFloat
    private var canvasHeight: CGFloat

    var currentDesign: Design {
        Design(
            text: textView.text,
            backgroundColor: backgroundColor,
            textColor: customTextColor,
            usesAutomaticTextColor: usesAutomaticTextColor,
            creationDate: creationDate,
            fontName: fontName,
            fontSize: fontSize,
            pixelationScale: pixelationScale,
            stretch: stretch,
            blur: blur,
            width: canvasWidth,
            height: canvasHeight,
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
            hue: hue,
            highlightAmount: highlightAmount,
            shadowAmount: shadowAmount,
            grain: grain,
            bloom: bloom,
            duotoneIntensity: duotoneIntensity,
            duotoneColorHex: duotoneColorHex,
            vibrance: vibrance,
            posterizeLevels: posterizeLevels,
            colorTemperature: colorTemperature,
            colorTint: colorTint,
            photoEffect: photoEffect,
            halftone: halftone,
            unsharpMask: unsharpMask,
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
            backgroundHue: backgroundHue,
            backgroundHighlightAmount: backgroundHighlightAmount,
            backgroundShadowAmount: backgroundShadowAmount,
            backgroundGrain: backgroundGrain,
            backgroundBloom: backgroundBloom,
            backgroundDuotoneIntensity: backgroundDuotoneIntensity,
            backgroundDuotoneColorHex: backgroundDuotoneColorHex,
            backgroundVibrance: backgroundVibrance,
            backgroundPosterizeLevels: backgroundPosterizeLevels,
            backgroundColorTemperature: backgroundColorTemperature,
            backgroundColorTint: backgroundColorTint,
            backgroundPhotoEffect: backgroundPhotoEffect,
            backgroundHalftone: backgroundHalftone,
            backgroundUnsharpMask: backgroundUnsharpMask,
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
        if let design {
            canvasWidth = design.width
            canvasHeight = design.height
        } else {
            canvasWidth = settingsManager.xDimension
            canvasHeight = settingsManager.yDimension
        }
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
        configureTextColorState()

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
        let shareBarButton = UIBarButtonItem.share { [weak self] in
            self?.shareButtonTouched()
        }

        if usesMacCollapsibleBottomPanel {
            navigationItem.rightBarButtonItems = [shareBarButton]
        } else {
            let settingsBarButton: UIBarButtonItem = {
                if let image = UIImage.gear {
                    let button = UIBarButtonItem(
                        image: image,
                        style: .plain,
                        target: self,
                        action: #selector(openSettingsFromEditor)
                    )
                    button.accessibilityLabel = NSLocalizedString(
                        "Settings",
                        comment: "The name of the button that goes to the settings menu."
                    )
                    settingsNavBarButton = button
                    return button
                }
                let titleButton = UIBarButtonItem(
                    title: NSLocalizedString(
                        "Settings",
                        comment: "The name of the button that goes to the settings menu."
                    ),
                    style: .plain,
                    target: self,
                    action: #selector(openSettingsFromEditor)
                )
                settingsNavBarButton = titleButton
                return titleButton
            }()
            var rightBarButtonItems: [UIBarButtonItem] = [settingsBarButton, shareBarButton]
            rightBarButtonItems.insert(UIBarButtonItem(
                image: UIImage(systemName: "keyboard"),
                style: .plain,
                target: self,
                action: #selector(toggleKeyboard)
            ), at: 0)
            navigationItem.rightBarButtonItems = rightBarButtonItems
        }

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
        previewImageViewTopCanvasConstraint = previewImageView.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: .su2
        )
        previewImageViewTopCanvasConstraint?.isActive = false
        previewImageViewTrailingToViewConstraint = previewImageView.trailingAnchor.constraint(
            equalTo: view.trailingAnchor,
            constant: -.su2
        )
        previewImageViewTrailingToSidebarConstraint = previewImageView.trailingAnchor.constraint(
            equalTo: fontPickerSidebarContainer.leadingAnchor,
            constant: -.su2
        )
        previewImageViewTrailingToSidebarConstraint?.isActive = false
        previewImageViewLeadingToViewConstraint = previewImageView.leadingAnchor.constraint(
            equalTo: view.leadingAnchor,
            constant: .su2
        )
        previewImageViewLeadingToSidebarConstraint = previewImageView.leadingAnchor.constraint(
            equalTo: imagePickerSidebarContainer.trailingAnchor,
            constant: .su2
        )
        previewImageViewLeadingToSidebarConstraint?.isActive = false
        NSLayoutConstraint.activate([
            topSwatchConstraint,
            previewImageViewLeadingToViewConstraint!,
            previewImageViewTrailingToViewConstraint!,
        ])

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
            return macKeyboardOptionsExpandedHeight
        }()

        if usesMacCollapsibleBottomPanel {
            keyboardOptionsHeightConstraint = keyboardOptionsView.heightAnchor.constraint(equalToConstant: 0)
        } else {
            keyboardOptionsHeightConstraint = keyboardOptionsView.heightAnchor.constraint(
                greaterThanOrEqualToConstant: keyboardOptionsViewHeight
            )
        }

        if usesMacCollapsibleBottomPanel {
            previewImageViewBottomConstraint = previewImageView.bottomAnchor.constraint(
                equalTo: keyboardOptionsView.topAnchor,
                constant: -.su2
            )
            previewImageViewBottomCanvasConstraint = previewImageView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -.su2
            )
            previewImageViewBottomCanvasConstraint?.isActive = false

            NSLayoutConstraint.activate([
                keyboardOptionsView.topAnchor.constraint(lessThanOrEqualTo: previewImageView.bottomAnchor, constant: .su2),
                keyboardOptionsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                keyboardOptionsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                keyboardOptionsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                keyboardOptionsHeightConstraint!,
                previewImageViewBottomConstraint!,
            ])
        } else {
            view.addSubview(editorBottomPanelContainer)
            editorBottomPanelHeightConstraint = editorBottomPanelContainer.heightAnchor.constraint(equalToConstant: 0)

            previewImageViewBottomConstraint = previewImageView.bottomAnchor.constraint(
                equalTo: editorBottomPanelContainer.topAnchor,
                constant: -.su2
            )
            previewImageViewBottomCanvasConstraint = previewImageView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -.su2
            )
            previewImageViewBottomCanvasConstraint?.isActive = false

            NSLayoutConstraint.activate([
                editorBottomPanelContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                editorBottomPanelContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                editorBottomPanelHeightConstraint!,

                keyboardOptionsView.topAnchor.constraint(
                    equalTo: editorBottomPanelContainer.bottomAnchor,
                    constant: .su2
                ),
                keyboardOptionsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                keyboardOptionsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                keyboardOptionsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                keyboardOptionsHeightConstraint!,
                previewImageViewBottomConstraint!,
            ])
        }

        setupFontPickerSidebar()
        setupImagePickerSidebar()

        view.backgroundColor = .systemBackground

        // Load design if exists
        if let design = design {
            textView.text = design.text
            originalText = design.text
            originalBackgroundColor = design.backgroundColor
        }
        
        view.addSubview(textView)
        textView.backgroundColor = .clear

        // Populate the swatch row with tool buttons immediately
        refreshToolButtons()
        if usesMacCollapsibleBottomPanel {
            applyMacEditorInitialState()
        } else {
            setEditingChromeVisible(false, animated: false)
        }

        updateDesignImage()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateEditorPanelLayoutMode()
    }

    private func applyAppearanceSensitiveChrome() {
        let isDarkMode = resolvedInterfaceStyle == .dark
        if let theme = settingsManager.selectedTheme {
            currentTintColor = isDarkMode ? theme.darkModeColors.tintColor : theme.lightModeColors.tintColor
        }
        updateAllToolbarButtonAppearances()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateEditorPanelLayoutMode()

        let previousStyle = previousTraitCollection.map {
            DesignTextColor.resolvedUserInterfaceStyle(
                $0.userInterfaceStyle,
                traitCollection: previousTraitCollection,
                view: isViewLoaded ? view : nil
            )
        }
        guard previousStyle != resolvedInterfaceStyle else {
            return
        }

        apply(settingsManager.selectedTheme)
        applyAppearanceSensitiveChrome()

        if usesAutomaticTextColor {
            if colorSwatchMode == .textColor {
                colorSwatchIndicatorView.backgroundColor = resolvedEditingTextColor
                refreshColorSwatches(currentColor: resolvedEditingTextColor)
            }
            updateDesignImage()
        }
    }

    override var canBecomeFirstResponder: Bool {
        isTrailingSidebarVisible || isLeadingSidebarVisible || isEditorBottomPanelVisible
    }

    override var keyCommands: [UIKeyCommand]? {
        guard isTrailingSidebarVisible || isLeadingSidebarVisible || isEditorBottomPanelVisible else {
            return super.keyCommands
        }
        return [
            UIKeyCommand(
                title: NSLocalizedString("Close", comment: "Title for close key command"),
                action: #selector(dismissEditorPanelsFromKeyCommand),
                input: UIKeyCommand.inputEscape,
                modifierFlags: [.shift],
                propertyList: nil
            ),
        ]
    }

    override func viewWillAppear(_ animated: Bool) {
        apply(settingsManager.selectedTheme)
        applyAppearanceSensitiveChrome()
        keyboardOptionsView.update(with: currentDesign)
        updateAllToolbarButtonAppearances()
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
            configureTextColorState()
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
            setEditingChromeVisible(true, animated: true)
            textView.becomeFirstResponder()
        }
    }

    /// macOS: toolbar visible, no sidebars, sliders, or design-controls panel until the user opts in.
    private func applyMacEditorInitialState() {
        guard usesMacCollapsibleBottomPanel else { return }

        keyboardOptionsView.dismissInlineEditingPanels()
        keyboardOptionsHeightConstraint?.constant = 0
        isDesignControlsModeActive = false

        isEditingChromeVisible = true
        previewImageViewTopSwatchConstraint?.isActive = true
        previewImageViewTopCanvasConstraint?.isActive = false
        previewImageViewBottomConstraint?.isActive = true
        previewImageViewBottomCanvasConstraint?.isActive = false

        colorSwatchToggleButton.isUserInteractionEnabled = true
        colorSwatchScrollView.isUserInteractionEnabled = true
        keyboardOptionsView.isUserInteractionEnabled = true
        colorSwatchToggleButton.alpha = 1
        colorSwatchIndicatorView.alpha = 1
        colorSwatchScrollView.alpha = 1
        keyboardOptionsView.alpha = 1

        updateAllToolbarButtonAppearances()
        view.layoutIfNeeded()
    }

    private func setEditingChromeVisible(_ visible: Bool, animated: Bool) {
        let visibilityChanged = isEditingChromeVisible != visible
        isEditingChromeVisible = visible

        if visibilityChanged {
            if usesMacCollapsibleBottomPanel {
                if visible {
                    keyboardOptionsView.setMacPrimarySlidersVisible(
                        settingsManager.macPrimarySlidersVisible,
                        persist: false
                    )
                } else {
                    keyboardOptionsView.dismissInlineEditingPanels()
                    keyboardOptionsHeightConstraint?.constant = 0
                }
            }

            previewImageViewTopSwatchConstraint?.isActive = visible
            previewImageViewTopCanvasConstraint?.isActive = !visible
            if usesMacCollapsibleBottomPanel {
                previewImageViewBottomConstraint?.isActive = true
                previewImageViewBottomCanvasConstraint?.isActive = false
            } else {
                previewImageViewBottomConstraint?.isActive = visible
                previewImageViewBottomCanvasConstraint?.isActive = !visible
            }
        }

        applyEditingChromeAppearance(animated: animated)
    }

    private func applyEditingChromeAppearance(animated: Bool) {
        let duration = animated ? 0.25 : 0
        let visible = isEditingChromeVisible
        let alpha: CGFloat = visible ? 1 : 0
        colorSwatchToggleButton.isUserInteractionEnabled = visible
        colorSwatchScrollView.isUserInteractionEnabled = visible
        keyboardOptionsView.isUserInteractionEnabled = visible
        UIView.animate(withDuration: duration) {
            self.colorSwatchToggleButton.alpha = alpha
            self.colorSwatchIndicatorView.alpha = alpha
            self.colorSwatchScrollView.alpha = alpha
            self.keyboardOptionsView.alpha = alpha
            self.view.layoutIfNeeded()
        }
        updateAllToolbarButtonAppearances()
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
        MacColorPicker.shared.showColorPicker(initialColor: resolvedEditingTextColor) { [weak self] selectedColor in
            self?.setTextColor(selectedColor, isUserChosen: true)
            self?.updateDesignImage()
        }
        #else
        let colorPicker = UIColorPickerViewController()
        colorPicker.selectedColor = resolvedEditingTextColor
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
        if !usesAutomaticTextColor {
            settingsManager.textColorHex = customTextColor.toHexString()
        }
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
            userInterfaceStyle: resolvedInterfaceStyle,
            traitCollection: traitCollection,
            view: isViewLoaded ? view : nil,
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
        canvasWidth = settingsManager.xDimension
        canvasHeight = settingsManager.yDimension
        if var d = design {
            d.width = canvasWidth
            d.height = canvasHeight
            design = d
        }
        embeddedAspectRatioPickerViewController?.selectedCanvasSize = CGSize(width: canvasWidth, height: canvasHeight)
        embeddedAspectRatioPickerViewController?.reloadNativeImageSection(nativeImageAspectSize: nativeBackgroundImageAspectSize())
        keyboardOptionsView.update(with: currentDesign)
        updateDesignImage()
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard !isDesignControlsModeActive else { return }
        if isEditorBottomPanelVisible, shouldUseCompactBottomPanel {
            dismissEditorPanel(animated: true)
        }
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            previewImageViewBottomConstraint?.constant = -.su2 - keyboardFrame.height
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: NSNotification) {
        guard !isDesignControlsModeActive else { return }
        previewImageViewBottomConstraint?.constant = -.su2
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func shareButtonTouched() {
        currentDesign.generateImage(
            with: imageService,
            userInterfaceStyle: resolvedInterfaceStyle,
            traitCollection: traitCollection,
            view: view
        ) { [weak self] imageToShare, _ in
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
        applyEditingChromeAppearance(animated: animated)
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
    func scaled(by scale: CGFloat, flipHorizontal: Bool = false, flipVertical: Bool = false) -> UIImage? {
        let size = CGSize(width: self.size.width * scale, height: self.size.height * scale)
        
        // Opaque context + nearest-neighbor keeps pixel edges sharp (no background bleed).
        UIGraphicsBeginImageContextWithOptions(size, true, self.scale)
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
        
        context.interpolationQuality = .none
        context.draw(self.cgImage!, in: CGRect(origin: .zero, size: size))
        
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
            setTextColor(viewController.selectedColor, isUserChosen: true)
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
            setTextColor(color, isUserChosen: true)
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
        updateAllToolbarButtonAppearances()
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
            colorSwatchIndicatorView.backgroundColor = resolvedEditingTextColor
            refreshColorSwatches(currentColor: resolvedEditingTextColor)
        }

        applyToolbarButtonSelectedAppearance(
            colorSwatchToggleButton,
            isSelected: colorSwatchMode != .tools
        )
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

        var items: [(String, String, Selector)] = []
        if usesMacCollapsibleBottomPanel {
            items.append(("gearshape", "Settings", #selector(openSettingsFromEditor)))
        }
        items.append(contentsOf: [
            ("paintpalette",        "Color Mode",        #selector(cycleSwatchMode)),
            ("photo",               "Background Image",  #selector(selectBackgroundImage)),
            ("camera.filters",      "Styles",            #selector(toggleFilterStyles)),
        ])
        if usesMacCollapsibleBottomPanel {
            items.append(("slider.vertical.3", "Primary Sliders", #selector(togglePrimarySlidersFromToolbar)))
        }
        items.append(contentsOf: [
            ("slider.horizontal.3", "Controls",          #selector(showControlsFromToolbar)),
            ("aspectratio",         "Aspect Ratio",      #selector(toggleAspectRatioSidebar)),
            ("textformat",          "Font Picker",       #selector(selectFont)),
            ("globe",               "Import from web",   #selector(importBackgroundFromWeb)),
        ])
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
            switch action {
            case #selector(selectFont):
                fontPickerToolbarButton = button
            case #selector(importBackgroundFromWeb):
                webImportToolbarButton = button
            case #selector(togglePrimarySlidersFromToolbar):
                primarySlidersToggleButton = button
            case #selector(showControlsFromToolbar):
                controlsToolbarButton = button
            case #selector(selectBackgroundImage):
                backgroundImageToolbarButton = button
            case #selector(toggleFilterStyles):
                stylesToolbarButton = button
            case #selector(openSettingsFromEditor):
                settingsToolbarButton = button
            case #selector(toggleAspectRatioSidebar):
                aspectRatioToolbarButton = button
            default:
                break
            }
        }
        updateAllToolbarButtonAppearances()
    }

    @objc private func togglePrimarySlidersFromToolbar() {
        keyboardOptionsView.toggleMacPrimarySliders()
        updateAllToolbarButtonAppearances()
    }

    @objc private func showControlsFromToolbar() {
        keyboardOptionsView.showControls()
        updateAllToolbarButtonAppearances()
    }

    @objc private func toggleFilterStyles() {
        if shouldUseSidebars {
            toggleLeadingSidebar(.filterStyles)
        } else if shouldUseCompactBottomPanel {
            toggleEditorPanel(.filterStyles)
        }
    }

    private var isFilterStylesVisible: Bool {
        if shouldUseCompactBottomPanel {
            return activeEditorPanel == .filterStyles
        }
        return activeLeadingSidebar == .filterStyles
    }

    private func refreshFilterStylesSelection() {
        embeddedFilterStylesViewController?.reloadSelection(selectedPresetID: lastAppliedPresetID)
    }

    private var isDesignControlsToolbarSelected: Bool {
        if usesMacCollapsibleBottomPanel {
            return keyboardOptionsView.isMacDesignControlsShowing
        }
        return isDesignControlsModeActive
    }

    private func applyToolbarButtonSelectedAppearance(_ button: UIButton?, isSelected: Bool) {
        guard let button else { return }
        button.isSelected = isSelected
        if isSelected {
            button.backgroundColor = currentTintColor.withAlphaComponent(0.15)
            button.layer.cornerRadius = 6
            button.tintColor = currentTintColor
        } else {
            button.backgroundColor = .clear
            button.layer.cornerRadius = 0
            button.tintColor = currentTintColor
        }
    }

    private func updateAllToolbarButtonAppearances() {
        let usesCompact = shouldUseCompactBottomPanel

        applyToolbarButtonSelectedAppearance(
            colorSwatchToggleButton,
            isSelected: colorSwatchMode != .tools
        )
        applyToolbarButtonSelectedAppearance(
            fontPickerToolbarButton,
            isSelected: usesCompact ? activeEditorPanel == .fontPicker : isFontPickerSidebarVisible
        )
        applyToolbarButtonSelectedAppearance(
            primarySlidersToggleButton,
            isSelected: keyboardOptionsView.isMacPrimarySlidersShowing
        )
        applyToolbarButtonSelectedAppearance(
            controlsToolbarButton,
            isSelected: isDesignControlsToolbarSelected
        )
        applyToolbarButtonSelectedAppearance(
            backgroundImageToolbarButton,
            isSelected: usesCompact ? activeEditorPanel == .backgroundImage : isImagePickerSidebarVisible
        )
        applyToolbarButtonSelectedAppearance(
            stylesToolbarButton,
            isSelected: isFilterStylesVisible
        )
        applyToolbarButtonSelectedAppearance(
            webImportToolbarButton,
            isSelected: usesCompact ? activeEditorPanel == .webImport : isWebImageSidebarVisible
        )
        applyToolbarButtonSelectedAppearance(
            aspectRatioToolbarButton,
            isSelected: usesCompact ? activeEditorPanel == .aspectRatio : isAspectRatioSidebarVisible
        )
        applyToolbarButtonSelectedAppearance(
            settingsToolbarButton,
            isSelected: activeLeadingSidebar == .settings
        )

        settingsNavBarButton?.tintColor = activeLeadingSidebar == .settings ? currentTintColor : nil
    }

    @objc private func toggleAspectRatioSidebar() {
        if shouldUseSidebars {
            toggleTrailingSidebar(.aspectRatio)
        } else if shouldUseCompactBottomPanel {
            toggleEditorPanel(.aspectRatio)
        }
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

        if colorSwatchIsTextMode {
            colorSwatchStackView.addArrangedSubview(makeAutomaticTextColorSwatchButton())
        }

        for color in Self.presetColors {
            colorSwatchStackView.addArrangedSubview(
                makeSwatchButton(color: color, isCurrent: !usesAutomaticTextColor && color.toHexString() == currentColor.toHexString())
            )
        }

        colorSwatchStackView.addArrangedSubview(makeRainbowPickerButton())

        for color in customPickedColors {
            colorSwatchStackView.addArrangedSubview(
                makeSwatchButton(color: color, isCurrent: color.toHexString() == currentColor.toHexString())
            )
        }
    }

    private func makeAutomaticTextColorSwatchButton() -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        button.setImage(UIImage(systemName: "circle.lefthalf.filled", withConfiguration: config), for: .normal)
        button.tintColor = resolvedEditingTextColor
        button.backgroundColor = .secondarySystemFill
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.layer.borderWidth = usesAutomaticTextColor ? 2.5 : 1
        button.layer.borderColor = usesAutomaticTextColor
            ? currentTintColor.cgColor
            : UIColor.gray.withAlphaComponent(0.4).cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityLabel = NSLocalizedString(
            "Automatic text color",
            comment: "Swatch that adapts text color to light or dark mode"
        )
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 30),
            button.heightAnchor.constraint(equalToConstant: 30),
        ])
        button.addAction(UIAction { [weak self] _ in
            self?.setAutomaticTextColor()
        }, for: .touchUpInside)
        return button
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
            let initialColor = self.colorSwatchIsTextMode ? self.resolvedEditingTextColor : self.backgroundColor
            MacColorPicker.shared.showColorPicker(initialColor: initialColor) { [weak self] selectedColor in
                self?.applyCustomColor(selectedColor)
            }
            #else
            let colorPicker = UIColorPickerViewController()
            colorPicker.selectedColor = self.colorSwatchIsTextMode ? self.resolvedEditingTextColor : self.backgroundColor
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

extension EditDesignViewController {
    func applyFilterState(from design: Design) {
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
        hue = design.hue
        highlightAmount = design.highlightAmount
        shadowAmount = design.shadowAmount
        grain = design.grain
        bloom = design.bloom
        duotoneIntensity = design.duotoneIntensity
        duotoneColorHex = design.duotoneColorHex
        vibrance = design.vibrance
        posterizeLevels = design.posterizeLevels
        colorTemperature = design.colorTemperature
        colorTint = design.colorTint
        photoEffect = design.photoEffect
        halftone = design.halftone
        unsharpMask = design.unsharpMask

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
        backgroundHue = design.backgroundHue
        backgroundHighlightAmount = design.backgroundHighlightAmount
        backgroundShadowAmount = design.backgroundShadowAmount
        backgroundGrain = design.backgroundGrain
        backgroundBloom = design.backgroundBloom
        backgroundDuotoneIntensity = design.backgroundDuotoneIntensity
        backgroundDuotoneColorHex = design.backgroundDuotoneColorHex
        backgroundVibrance = design.backgroundVibrance
        backgroundPosterizeLevels = design.backgroundPosterizeLevels
        backgroundColorTemperature = design.backgroundColorTemperature
        backgroundColorTint = design.backgroundColorTint
        backgroundPhotoEffect = design.backgroundPhotoEffect
        backgroundHalftone = design.backgroundHalftone
        backgroundUnsharpMask = design.backgroundUnsharpMask
    }

    func applyMainImageFilters(from settings: ImageFilterSettings) {
        brightness = settings.brightness
        contrast = settings.contrast
        saturation = settings.saturation
        exposure = settings.exposure
        gamma = settings.gamma
        sepia = settings.sepia
        invert = settings.invert
        pixelate = settings.pixelate
        sharpen = settings.sharpen
        monochrome = settings.monochrome
        vignette = settings.vignette
        hue = settings.hue
        highlightAmount = settings.highlightAmount
        shadowAmount = settings.shadowAmount
        grain = settings.grain
        bloom = settings.bloom
        duotoneIntensity = settings.duotoneIntensity
        duotoneColorHex = settings.duotoneColorHex
        vibrance = settings.vibrance
        posterizeLevels = settings.posterizeLevels
        colorTemperature = settings.colorTemperature
        colorTint = settings.colorTint
        photoEffect = settings.photoEffect
        halftone = settings.halftone
        unsharpMask = settings.unsharpMask
    }

    func applyBackgroundImageFilters(from settings: ImageFilterSettings) {
        backgroundBrightness = settings.brightness
        backgroundContrast = settings.contrast
        backgroundSaturation = settings.saturation
        backgroundExposure = settings.exposure
        backgroundGamma = settings.gamma
        backgroundSepia = settings.sepia
        backgroundInvert = settings.invert
        backgroundPixelate = settings.pixelate
        backgroundSharpen = settings.sharpen
        backgroundMonochrome = settings.monochrome
        backgroundVignette = settings.vignette
        backgroundHue = settings.hue
        backgroundHighlightAmount = settings.highlightAmount
        backgroundShadowAmount = settings.shadowAmount
        backgroundGrain = settings.grain
        backgroundBloom = settings.bloom
        backgroundDuotoneIntensity = settings.duotoneIntensity
        backgroundDuotoneColorHex = settings.duotoneColorHex
        backgroundVibrance = settings.vibrance
        backgroundPosterizeLevels = settings.posterizeLevels
        backgroundColorTemperature = settings.colorTemperature
        backgroundColorTint = settings.colorTint
        backgroundPhotoEffect = settings.photoEffect
        backgroundHalftone = settings.halftone
        backgroundUnsharpMask = settings.unsharpMask
    }

    var mainImageFilterSettings: ImageFilterSettings {
        ImageFilterSettings(
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
            hue: hue,
            highlightAmount: highlightAmount,
            shadowAmount: shadowAmount,
            grain: grain,
            bloom: bloom,
            duotoneIntensity: duotoneIntensity,
            duotoneColorHex: duotoneColorHex,
            vibrance: vibrance,
            posterizeLevels: posterizeLevels,
            colorTemperature: colorTemperature,
            colorTint: colorTint,
            photoEffect: photoEffect,
            halftone: halftone,
            unsharpMask: unsharpMask
        )
    }

    var backgroundImageFilterSettings: ImageFilterSettings {
        ImageFilterSettings(
            brightness: backgroundBrightness,
            contrast: backgroundContrast,
            saturation: backgroundSaturation,
            exposure: backgroundExposure,
            gamma: backgroundGamma,
            sepia: backgroundSepia,
            invert: backgroundInvert,
            pixelate: backgroundPixelate,
            sharpen: backgroundSharpen,
            monochrome: backgroundMonochrome,
            vignette: backgroundVignette,
            hue: backgroundHue,
            highlightAmount: backgroundHighlightAmount,
            shadowAmount: backgroundShadowAmount,
            grain: backgroundGrain,
            bloom: backgroundBloom,
            duotoneIntensity: backgroundDuotoneIntensity,
            duotoneColorHex: backgroundDuotoneColorHex,
            vibrance: backgroundVibrance,
            posterizeLevels: backgroundPosterizeLevels,
            colorTemperature: backgroundColorTemperature,
            colorTint: backgroundColorTint,
            photoEffect: backgroundPhotoEffect,
            halftone: backgroundHalftone,
            unsharpMask: backgroundUnsharpMask
        )
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

    func didChangeHue(_ hue: CGFloat) {
        self.hue = hue
        updateDesignImage()
    }

    func didChangeHighlightAmount(_ amount: CGFloat) {
        highlightAmount = amount
        updateDesignImage()
    }

    func didChangeShadowAmount(_ amount: CGFloat) {
        shadowAmount = amount
        updateDesignImage()
    }

    func didChangeGrain(_ grain: CGFloat) {
        self.grain = grain
        updateDesignImage()
    }

    func didChangeBloom(_ bloom: CGFloat) {
        self.bloom = bloom
        updateDesignImage()
    }

    func didChangeDuotoneIntensity(_ intensity: CGFloat) {
        duotoneIntensity = intensity
        updateDesignImage()
    }

    func didChangeVibrance(_ vibrance: CGFloat) {
        self.vibrance = vibrance
        updateDesignImage()
    }

    func didChangePosterizeLevels(_ levels: CGFloat) {
        posterizeLevels = levels
        updateDesignImage()
    }

    func didChangeColorTemperature(_ temperature: CGFloat) {
        colorTemperature = temperature
        updateDesignImage()
    }

    func didChangeColorTint(_ tint: CGFloat) {
        colorTint = tint
        updateDesignImage()
    }

    func didChangeHalftone(_ halftone: CGFloat) {
        self.halftone = halftone
        updateDesignImage()
    }

    func didChangeUnsharpMask(_ amount: CGFloat) {
        unsharpMask = amount
        updateDesignImage()
    }

    func didApplyFilterPreset(_ preset: FilterPreset) {
        var updated = currentDesign
        preset.apply(to: &updated)
        if preset.id == "none" {
            updated.backgroundScale = 1.0
            updated.backgroundFlipHorizontal = false
            updated.backgroundFlipVertical = false
            updated.backgroundBlur = 0.0
            updated.backgroundAlpha = 1.0
        }
        applyFilterState(from: updated)
        backgroundScale = updated.backgroundScale
        backgroundFlipHorizontal = updated.backgroundFlipHorizontal
        backgroundFlipVertical = updated.backgroundFlipVertical
        backgroundBlur = updated.backgroundBlur
        backgroundAlpha = updated.backgroundAlpha
        lastAppliedPresetID = preset.id
        refreshFilterStylesSelection()
        updateDesignImage()
    }

    func didRequestCopyBackgroundFiltersToMain() {
        applyMainImageFilters(from: backgroundImageFilterSettings)
        updateDesignImage()
    }

    func didRequestResetMainImageFilters() {
        applyMainImageFilters(from: .default)
        updateDesignImage()
    }

    func didRequestResetBackgroundImageFilters() {
        applyBackgroundImageFilters(from: .default)
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

    func didChangeBackgroundHue(_ hue: CGFloat) {
        backgroundHue = hue
        updateDesignImage()
    }

    func didChangeBackgroundHighlightAmount(_ amount: CGFloat) {
        backgroundHighlightAmount = amount
        updateDesignImage()
    }

    func didChangeBackgroundShadowAmount(_ amount: CGFloat) {
        backgroundShadowAmount = amount
        updateDesignImage()
    }

    func didChangeBackgroundGrain(_ grain: CGFloat) {
        backgroundGrain = grain
        updateDesignImage()
    }

    func didChangeBackgroundBloom(_ bloom: CGFloat) {
        backgroundBloom = bloom
        updateDesignImage()
    }

    func didChangeBackgroundDuotoneIntensity(_ intensity: CGFloat) {
        backgroundDuotoneIntensity = intensity
        updateDesignImage()
    }

    func didChangeBackgroundVibrance(_ vibrance: CGFloat) {
        backgroundVibrance = vibrance
        updateDesignImage()
    }

    func didChangeBackgroundPosterizeLevels(_ levels: CGFloat) {
        backgroundPosterizeLevels = levels
        updateDesignImage()
    }

    func didChangeBackgroundColorTemperature(_ temperature: CGFloat) {
        backgroundColorTemperature = temperature
        updateDesignImage()
    }

    func didChangeBackgroundColorTint(_ tint: CGFloat) {
        backgroundColorTint = tint
        updateDesignImage()
    }

    func didChangeBackgroundHalftone(_ halftone: CGFloat) {
        backgroundHalftone = halftone
        updateDesignImage()
    }

    func didChangeBackgroundUnsharpMask(_ amount: CGFloat) {
        backgroundUnsharpMask = amount
        updateDesignImage()
    }
    
    
    func designControlsViewController(
        _ controller: DesignControlsViewController,
        didUpdateDesign design: Design
    ) {
        stretch = design.stretch
        blur = design.blur
        fontSize = design.fontSize
        pixelationScale = design.pixelationScale
        applyFilterState(from: design)
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
    
    @objc func openSettingsFromEditor() {
        if shouldUseSidebars {
            toggleLeadingSidebar(.settings)
        } else {
            openSettings()
        }
    }

    @objc func selectFont() {
        if shouldUseSidebars {
            toggleTrailingSidebar(.fontPicker)
        } else if shouldUseCompactBottomPanel {
            toggleEditorPanel(.fontPicker)
        }
    }

    func pixelationScaleChanged(to newPixelationScale: CGFloat) {
        pixelationScale = newPixelationScale
    }

    private var shouldUseCompactBottomPanel: Bool {
        guard isViewLoaded else { return false }
        return TrailingSidebarLayout.shouldUseCompactBottomPanel(
            idiom: traitCollection.userInterfaceIdiom,
            width: view.bounds.width,
            height: view.bounds.height,
            usesMacCollapsibleBottomPanel: usesMacCollapsibleBottomPanel
        )
    }

    private var shouldUseSidebars: Bool {
        guard isViewLoaded else { return false }
        return TrailingSidebarLayout.shouldUseSidebars(
            idiom: traitCollection.userInterfaceIdiom,
            width: view.bounds.width,
            height: view.bounds.height,
            usesMacCollapsibleBottomPanel: usesMacCollapsibleBottomPanel
        )
    }

    private var editorMiddleBandHeight: CGFloat {
        let swatchBottom = colorSwatchToggleButton.frame.maxY + .su2
        let keyboardTop = keyboardOptionsView.frame.minY - .su2
        return max(keyboardTop - swatchBottom, 200)
    }

    private func setupFontPickerSidebar() {
        view.addSubview(fontPickerSidebarContainer)
        fontPickerSidebarContainer.addSubview(fontPickerSidebarSeparator)

        fontPickerSidebarWidthConstraint = fontPickerSidebarContainer.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            fontPickerSidebarContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            fontPickerSidebarContainer.topAnchor.constraint(equalTo: colorSwatchToggleButton.bottomAnchor, constant: .su2),
            fontPickerSidebarContainer.bottomAnchor.constraint(equalTo: keyboardOptionsView.topAnchor, constant: -.su2),
            fontPickerSidebarWidthConstraint!,

            fontPickerSidebarSeparator.leadingAnchor.constraint(equalTo: fontPickerSidebarContainer.leadingAnchor),
            fontPickerSidebarSeparator.topAnchor.constraint(equalTo: fontPickerSidebarContainer.topAnchor),
            fontPickerSidebarSeparator.bottomAnchor.constraint(equalTo: fontPickerSidebarContainer.bottomAnchor),
            fontPickerSidebarSeparator.widthAnchor.constraint(equalToConstant: 0.5),
        ])
    }

    private func toggleTrailingSidebar(_ content: TrailingSidebarContent) {
        guard shouldUseSidebars else { return }
        if activeTrailingSidebar == content {
            dismissTrailingSidebar(animated: true)
        } else {
            presentTrailingSidebar(content)
        }
    }

    private func presentTrailingSidebar(_ content: TrailingSidebarContent) {
        guard shouldUseSidebars, activeTrailingSidebar != content else { return }

        if activeTrailingSidebar != nil {
            dismissTrailingSidebar(animated: false)
        }

        switch content {
        case .fontPicker:
            embedFontPickerInTrailingSidebar()
        case .webImages:
            embedWebImagePickerInTrailingSidebar()
        case .aspectRatio:
            embedAspectRatioInTrailingSidebar()
        }

        activeTrailingSidebar = content
        fontPickerSidebarContainer.isHidden = false
        view.bringSubviewToFront(fontPickerSidebarContainer)
        fontPickerSidebarWidthConstraint?.constant = TrailingSidebarLayout.width
        previewImageViewTrailingToViewConstraint?.isActive = false
        previewImageViewTrailingToSidebarConstraint?.isActive = true
        updateAllToolbarButtonAppearances()
        becomeFirstResponder()

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    private func embedFontPickerInTrailingSidebar() {
        embedFontPicker(
            in: fontPickerSidebarContainer,
            leadingAnchor: fontPickerSidebarSeparator.trailingAnchor,
            onDone: { [weak self] in self?.dismissTrailingSidebar(animated: true) }
        )
    }

    private func embedFontPicker(
        in container: UIView,
        leadingAnchor: NSLayoutXAxisAnchor,
        onDone: @escaping () -> Void
    ) {
        let fontViewController: FontsViewController
        if let existing = embeddedFontPickerViewController {
            fontViewController = existing
        } else {
            fontViewController = FontsViewController(settingsManager: settingsManager) { [weak self] fontName in
                guard let self else { return }
                settingsManager.preferredFontName = fontName
                self.fontName = fontName
                self.updateDesignImage()
            }
            fontViewController.presentationStyle = .sidebar
            embeddedFontPickerViewController = fontViewController
        }
        fontViewController.onDone = onDone

        embedChildViewController(fontViewController, in: container) { childView in
            [
                childView.topAnchor.constraint(equalTo: container.topAnchor),
                childView.leadingAnchor.constraint(equalTo: leadingAnchor),
                childView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                childView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ]
        }
    }

    private func embedAspectRatioInTrailingSidebar() {
        embedAspectRatioPicker(
            in: fontPickerSidebarContainer,
            leadingAnchor: fontPickerSidebarSeparator.trailingAnchor,
            onDone: { [weak self] in self?.dismissTrailingSidebar(animated: true) }
        )
    }

    private func embedAspectRatioPicker(
        in container: UIView,
        leadingAnchor: NSLayoutXAxisAnchor,
        onDone: @escaping () -> Void
    ) {
        let aspectViewController: AspectRatioPickerViewController
        if let existing = embeddedAspectRatioPickerViewController {
            aspectViewController = existing
        } else {
            aspectViewController = AspectRatioPickerViewController(settingsManager: settingsManager)
            aspectViewController.presentationStyle = .sidebar
            aspectViewController.delegate = self
            embeddedAspectRatioPickerViewController = aspectViewController
        }
        aspectViewController.onDone = onDone
        aspectViewController.presentationStyle = .sidebar
        aspectViewController.delegate = self
        aspectViewController.nativeImageAspectSize = nativeBackgroundImageAspectSize()
        aspectViewController.selectedCanvasSize = CGSize(width: canvasWidth, height: canvasHeight)

        embedChildViewController(aspectViewController, in: container) { childView in
            [
                childView.topAnchor.constraint(equalTo: container.topAnchor),
                childView.leadingAnchor.constraint(equalTo: leadingAnchor),
                childView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
                childView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ]
        }
    }

    private func nativeBackgroundImageAspectSize() -> (width: Int, height: Int)? {
        guard !imageName.isEmpty else { return nil }
        let image: UIImage?
        if let cached = imageService.memoryCache.object(forKey: imageName as NSString) {
            image = cached
        } else {
            image = imageService.loadImageFromDisk(with: imageName)
        }
        guard let image, image.size.width > 0, image.size.height > 0 else { return nil }
        let pixelWidth = max(1, Int((image.size.width * image.scale).rounded()))
        let pixelHeight = max(1, Int((image.size.height * image.scale).rounded()))
        return (pixelWidth, pixelHeight)
    }

    private func reloadAspectRatioSidebarNativeImageIfNeeded() {
        guard isAspectRatioSidebarVisible || activeEditorPanel == .aspectRatio else { return }
        embeddedAspectRatioPickerViewController?.nativeImageAspectSize = nativeBackgroundImageAspectSize()
        embeddedAspectRatioPickerViewController?.reloadNativeImageSection(
            nativeImageAspectSize: nativeBackgroundImageAspectSize()
        )
    }

    private func embedWebImagePickerInTrailingSidebar() {
        embedWebImagePicker(
            in: fontPickerSidebarContainer,
            leadingAnchor: fontPickerSidebarSeparator.trailingAnchor,
            onDone: { [weak self] in self?.dismissTrailingSidebar(animated: true) }
        )
    }

    private func embedWebImagePicker(
        in container: UIView,
        leadingAnchor: NSLayoutXAxisAnchor,
        onDone: @escaping () -> Void
    ) {
        let host: UIHostingController<WebImagePicker>
        if let existing = embeddedWebImagePickerHostingController {
            host = existing
            WebImageImportPresenter.updateHostingController(
                host,
                imageService: imageService,
                onCancel: onDone,
                onImagePicked: { [weak self] imageName in
                    guard let self else { return }
                    self.imageName = imageName
                    self.updateDesignImage()
                    self.updateAllToolbarButtonAppearances()
                    onDone()
                }
            )
        } else {
            host = WebImageImportPresenter.makeHostingController(
                imageService: imageService,
                onCancel: onDone,
                onImagePicked: { [weak self] imageName in
                    guard let self else { return }
                    self.imageName = imageName
                    self.updateDesignImage()
                    self.updateAllToolbarButtonAppearances()
                    onDone()
                }
            )
            embeddedWebImagePickerHostingController = host
        }

        if leadingAnchor === container.leadingAnchor {
            WebImageImportPresenter.embed(host, in: self, container: container)
        } else {
            WebImageImportPresenter.embed(
                host,
                in: self,
                container: container,
                contentLeadingAnchor: leadingAnchor
            )
        }
    }

    private func dismissTrailingSidebar(animated: Bool) {
        guard let content = activeTrailingSidebar else { return }

        activeTrailingSidebar = nil
        fontPickerSidebarWidthConstraint?.constant = 0
        previewImageViewTrailingToSidebarConstraint?.isActive = false
        previewImageViewTrailingToViewConstraint?.isActive = true
        updateAllToolbarButtonAppearances()

        let removeChild = { [weak self] in
            guard let self else { return }
            switch content {
            case .fontPicker:
                guard let fontVC = self.embeddedFontPickerViewController else { return }
                fontVC.willMove(toParent: nil)
                fontVC.view.removeFromSuperview()
                fontVC.removeFromParent()
            case .webImages:
                guard let host = self.embeddedWebImagePickerHostingController else { return }
                host.willMove(toParent: nil)
                host.view.removeFromSuperview()
                host.removeFromParent()
            case .aspectRatio:
                guard let aspectVC = self.embeddedAspectRatioPickerViewController else { return }
                aspectVC.willMove(toParent: nil)
                aspectVC.view.removeFromSuperview()
                aspectVC.removeFromParent()
            }
        }

        let finish = { [weak self] in
            guard let self else { return }
            self.fontPickerSidebarContainer.isHidden = true
            if !self.isLeadingSidebarVisible, !self.isTrailingSidebarVisible, !self.isEditorBottomPanelVisible {
                self.resignFirstResponder()
            }
        }

        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                removeChild()
                finish()
            })
        } else {
            view.layoutIfNeeded()
            removeChild()
            finish()
        }
    }

    @objc private func dismissEditorPanelsFromKeyCommand() {
        if isEditorBottomPanelVisible {
            dismissEditorPanel(animated: true)
        }
        if isLeadingSidebarVisible {
            dismissLeadingSidebar(animated: true)
        }
        if isTrailingSidebarVisible {
            dismissTrailingSidebar(animated: true)
        }
    }

    private func updateEditorPanelLayoutMode() {
        if isTrailingSidebarVisible, !shouldUseSidebars {
            dismissTrailingSidebar(animated: false)
        }
        if isLeadingSidebarVisible, !shouldUseSidebars {
            dismissLeadingSidebar(animated: false)
        }
        if isEditorBottomPanelVisible, !shouldUseCompactBottomPanel {
            dismissEditorPanel(animated: false)
        }
    }

    private func toggleEditorPanel(_ panel: EditorPanel) {
        guard shouldUseCompactBottomPanel else { return }
        if activeEditorPanel == panel {
            dismissEditorPanel(animated: true)
        } else {
            presentEditorPanel(panel)
        }
    }

    private func presentEditorPanel(_ panel: EditorPanel) {
        guard shouldUseCompactBottomPanel, activeEditorPanel != panel else { return }

        if activeEditorPanel != nil {
            dismissEditorPanel(animated: false)
        }

        let onDone: () -> Void = { [weak self] in
            self?.dismissEditorPanel(animated: true)
        }

        switch panel {
        case .backgroundImage:
            embedBackgroundImagePicker(
                in: editorBottomPanelContainer,
                leadingAnchor: editorBottomPanelContainer.leadingAnchor,
                onDone: onDone
            )
        case .filterStyles:
            embedFilterStyles(
                in: editorBottomPanelContainer,
                leadingAnchor: editorBottomPanelContainer.leadingAnchor,
                onDone: onDone
            )
        case .fontPicker:
            embedFontPicker(
                in: editorBottomPanelContainer,
                leadingAnchor: editorBottomPanelContainer.leadingAnchor,
                onDone: onDone
            )
        case .webImport:
            embedWebImagePicker(
                in: editorBottomPanelContainer,
                leadingAnchor: editorBottomPanelContainer.leadingAnchor,
                onDone: onDone
            )
        case .aspectRatio:
            embedAspectRatioPicker(
                in: editorBottomPanelContainer,
                leadingAnchor: editorBottomPanelContainer.leadingAnchor,
                onDone: onDone
            )
        }

        activeEditorPanel = panel
        editorBottomPanelContainer.isHidden = false
        view.bringSubviewToFront(editorBottomPanelContainer)
        editorBottomPanelHeightConstraint?.constant = TrailingSidebarLayout.compactPanelHeight(
            for: panel,
            editorMiddleBandHeight: editorMiddleBandHeight
        )
        updateAllToolbarButtonAppearances()
        becomeFirstResponder()

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    private func dismissEditorPanel(animated: Bool) {
        guard let panel = activeEditorPanel else { return }

        activeEditorPanel = nil
        editorBottomPanelHeightConstraint?.constant = 0
        updateAllToolbarButtonAppearances()

        let removeChild = { [weak self] in
            guard let self else { return }
            switch panel {
            case .backgroundImage:
                guard let imagePickerVC = self.embeddedBackgroundImagePickerViewController else { return }
                imagePickerVC.willMove(toParent: nil)
                imagePickerVC.view.removeFromSuperview()
                imagePickerVC.removeFromParent()
            case .filterStyles:
                guard let stylesVC = self.embeddedFilterStylesViewController else { return }
                stylesVC.willMove(toParent: nil)
                stylesVC.view.removeFromSuperview()
                stylesVC.removeFromParent()
            case .fontPicker:
                guard let fontVC = self.embeddedFontPickerViewController else { return }
                fontVC.willMove(toParent: nil)
                fontVC.view.removeFromSuperview()
                fontVC.removeFromParent()
            case .webImport:
                guard let host = self.embeddedWebImagePickerHostingController else { return }
                host.willMove(toParent: nil)
                host.view.removeFromSuperview()
                host.removeFromParent()
            case .aspectRatio:
                guard let aspectVC = self.embeddedAspectRatioPickerViewController else { return }
                aspectVC.willMove(toParent: nil)
                aspectVC.view.removeFromSuperview()
                aspectVC.removeFromParent()
            }
        }

        let finish = { [weak self] in
            guard let self else { return }
            self.editorBottomPanelContainer.isHidden = true
            if !self.isLeadingSidebarVisible, !self.isTrailingSidebarVisible, !self.isEditorBottomPanelVisible {
                self.resignFirstResponder()
            }
        }

        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                removeChild()
                finish()
            })
        } else {
            view.layoutIfNeeded()
            removeChild()
            finish()
        }
    }

    private func toggleLeadingSidebar(_ content: LeadingSidebarContent) {
        guard shouldUseSidebars else { return }
        if activeLeadingSidebar == content {
            dismissLeadingSidebar(animated: true)
        } else {
            presentLeadingSidebar(content)
        }
    }

    private func presentLeadingSidebar(_ content: LeadingSidebarContent) {
        guard shouldUseSidebars, activeLeadingSidebar != content else { return }

        if activeLeadingSidebar != nil {
            dismissLeadingSidebar(animated: false)
        }

        switch content {
        case .backgroundImage:
            embedBackgroundImagePickerInLeadingSidebar()
        case .settings:
            embedSettingsInLeadingSidebar()
        case .filterStyles:
            embedFilterStylesInLeadingSidebar()
        }

        activeLeadingSidebar = content
        imagePickerSidebarContainer.isHidden = false
        view.bringSubviewToFront(imagePickerSidebarContainer)
        imagePickerSidebarWidthConstraint?.constant = TrailingSidebarLayout.width
        previewImageViewLeadingToViewConstraint?.isActive = false
        previewImageViewLeadingToSidebarConstraint?.isActive = true
        updateAllToolbarButtonAppearances()
        becomeFirstResponder()

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    private func embedBackgroundImagePickerInLeadingSidebar() {
        embedBackgroundImagePicker(
            in: imagePickerSidebarContainer,
            leadingAnchor: imagePickerSidebarContainer.leadingAnchor,
            onDone: { [weak self] in self?.dismissLeadingSidebar(animated: true) }
        )
    }

    private func embedBackgroundImagePicker(
        in container: UIView,
        leadingAnchor: NSLayoutXAxisAnchor,
        onDone: @escaping () -> Void
    ) {
        let imagePickerViewController: BackgroundImagePickerViewController
        if let existing = embeddedBackgroundImagePickerViewController {
            imagePickerViewController = existing
        } else {
            imagePickerViewController = BackgroundImagePickerViewController()
            embeddedBackgroundImagePickerViewController = imagePickerViewController
        }
        imagePickerViewController.onImagePicked = { [weak self] image in
            guard let self else { return }
            self.applyPickedBackgroundImage(image)
            onDone()
        }
        imagePickerViewController.onDone = onDone

        let trailingAnchor: NSLayoutXAxisAnchor = {
            if container === imagePickerSidebarContainer {
                return imagePickerSidebarSeparator.leadingAnchor
            }
            return container.trailingAnchor
        }()
        embedChildViewController(imagePickerViewController, in: container) { childView in
            [
                childView.topAnchor.constraint(equalTo: container.topAnchor),
                childView.leadingAnchor.constraint(equalTo: leadingAnchor),
                childView.trailingAnchor.constraint(equalTo: trailingAnchor),
                childView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ]
        }
    }

    private func embedSettingsInLeadingSidebar() {
        embedSettings(
            in: imagePickerSidebarContainer,
            leadingAnchor: imagePickerSidebarContainer.leadingAnchor,
            onDone: { [weak self] in self?.dismissLeadingSidebar(animated: true) }
        )
    }

    private func embedSettings(
        in container: UIView,
        leadingAnchor: NSLayoutXAxisAnchor,
        onDone: @escaping () -> Void
    ) {
        let navigationController: UINavigationController
        if let existing = embeddedSettingsNavigationController {
            navigationController = existing
        } else {
            let settingsViewController = SettingsViewController(settingsManager: settingsManager)
            settingsViewController.presentationStyle = .sidebar
            settingsViewController.onDone = onDone
            navigationController = UINavigationController(rootViewController: settingsViewController)
            embeddedSettingsNavigationController = navigationController
        }
        navigationController.popToRootViewController(animated: false)
        if let settingsViewController = navigationController.viewControllers.first as? SettingsViewController {
            settingsViewController.onDone = onDone
        }

        let trailingAnchor: NSLayoutXAxisAnchor = {
            if container === imagePickerSidebarContainer {
                return imagePickerSidebarSeparator.leadingAnchor
            }
            return container.trailingAnchor
        }()
        embedChildViewController(navigationController, in: container) { childView in
            [
                childView.topAnchor.constraint(equalTo: container.topAnchor),
                childView.leadingAnchor.constraint(equalTo: leadingAnchor),
                childView.trailingAnchor.constraint(equalTo: trailingAnchor),
                childView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ]
        }
    }

    private func embedFilterStylesInLeadingSidebar() {
        embedFilterStyles(
            in: imagePickerSidebarContainer,
            leadingAnchor: imagePickerSidebarContainer.leadingAnchor,
            onDone: { [weak self] in self?.dismissLeadingSidebar(animated: true) }
        )
    }

    private func embedFilterStyles(
        in container: UIView,
        leadingAnchor: NSLayoutXAxisAnchor,
        onDone: @escaping () -> Void
    ) {
        let stylesViewController: FilterStylesViewController
        if let existing = embeddedFilterStylesViewController {
            stylesViewController = existing
        } else {
            stylesViewController = FilterStylesViewController(
                settingsManager: settingsManager,
                showsSidebarChrome: true
            )
            stylesViewController.delegate = self
            embeddedFilterStylesViewController = stylesViewController
        }
        stylesViewController.onDone = onDone
        stylesViewController.reloadSelection(selectedPresetID: lastAppliedPresetID)

        let trailingAnchor: NSLayoutXAxisAnchor = {
            if container === imagePickerSidebarContainer {
                return imagePickerSidebarSeparator.leadingAnchor
            }
            return container.trailingAnchor
        }()
        embedChildViewController(stylesViewController, in: container) { childView in
            [
                childView.topAnchor.constraint(equalTo: container.topAnchor),
                childView.leadingAnchor.constraint(equalTo: leadingAnchor),
                childView.trailingAnchor.constraint(equalTo: trailingAnchor),
                childView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            ]
        }
    }

    private func dismissLeadingSidebar(animated: Bool) {
        guard let content = activeLeadingSidebar else { return }

        activeLeadingSidebar = nil
        imagePickerSidebarWidthConstraint?.constant = 0
        previewImageViewLeadingToSidebarConstraint?.isActive = false
        previewImageViewLeadingToViewConstraint?.isActive = true
        updateAllToolbarButtonAppearances()

        let removeChild = { [weak self] in
            guard let self else { return }
            switch content {
            case .backgroundImage:
                guard let imagePickerVC = self.embeddedBackgroundImagePickerViewController else { return }
                imagePickerVC.willMove(toParent: nil)
                imagePickerVC.view.removeFromSuperview()
                imagePickerVC.removeFromParent()
            case .settings:
                guard let nav = self.embeddedSettingsNavigationController else { return }
                nav.willMove(toParent: nil)
                nav.view.removeFromSuperview()
                nav.removeFromParent()
            case .filterStyles:
                guard let stylesVC = self.embeddedFilterStylesViewController else { return }
                stylesVC.willMove(toParent: nil)
                stylesVC.view.removeFromSuperview()
                stylesVC.removeFromParent()
            }
        }

        let finish = { [weak self] in
            guard let self else { return }
            self.imagePickerSidebarContainer.isHidden = true
            if !self.isTrailingSidebarVisible, !self.isEditorBottomPanelVisible {
                self.resignFirstResponder()
            }
        }

        if animated {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.layoutIfNeeded()
            }, completion: { _ in
                removeChild()
                finish()
            })
        } else {
            view.layoutIfNeeded()
            removeChild()
            finish()
        }
    }

    private func setupImagePickerSidebar() {
        view.addSubview(imagePickerSidebarContainer)
        imagePickerSidebarContainer.addSubview(imagePickerSidebarSeparator)

        imagePickerSidebarWidthConstraint = imagePickerSidebarContainer.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            imagePickerSidebarContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            imagePickerSidebarContainer.topAnchor.constraint(equalTo: colorSwatchToggleButton.bottomAnchor, constant: .su2),
            imagePickerSidebarContainer.bottomAnchor.constraint(equalTo: keyboardOptionsView.topAnchor, constant: -.su2),
            imagePickerSidebarWidthConstraint!,

            imagePickerSidebarSeparator.trailingAnchor.constraint(equalTo: imagePickerSidebarContainer.trailingAnchor),
            imagePickerSidebarSeparator.topAnchor.constraint(equalTo: imagePickerSidebarContainer.topAnchor),
            imagePickerSidebarSeparator.bottomAnchor.constraint(equalTo: imagePickerSidebarContainer.bottomAnchor),
            imagePickerSidebarSeparator.widthAnchor.constraint(equalToConstant: 0.5),
        ])
    }

    @objc internal func selectBackgroundImage() {
        if shouldUseSidebars {
            toggleLeadingSidebar(.backgroundImage)
        } else if shouldUseCompactBottomPanel {
            toggleEditorPanel(.backgroundImage)
        }
    }

    private func applyPickedBackgroundImage(_ image: UIImage) {
        let imageName = UUID().uuidString
        imageService.saveImageToDisk(
            image,
            addToInMemoryCache: true,
            withName: imageName,
            compressionQuality: 0.7
        )
        self.imageName = imageName
        updateDesignImage()
        updateAllToolbarButtonAppearances()
    }

    @objc private func importBackgroundFromWeb() {
        if shouldUseSidebars {
            toggleTrailingSidebar(.webImages)
        } else if shouldUseCompactBottomPanel {
            toggleEditorPanel(.webImport)
        }
    }

    func didSelectBackgroundColor(_ color: UIColor) {
        applyBackgroundColor(color)
        if colorSwatchMode == .backgroundColor {
            colorSwatchIndicatorView.backgroundColor = color
            refreshColorSwatches(currentColor: color)
        }
    }

    func didSelectTextColorFromSwatch(_ color: UIColor) {
        setTextColor(color, isUserChosen: true)
    }

    func keyboardOptionsViewWillShowDesignControls() {
        enterDesignControlsMode()
        updateAllToolbarButtonAppearances()
    }

    func keyboardOptionsViewDidDismissDesignControls() {
        exitDesignControlsMode()
        updateAllToolbarButtonAppearances()
    }

    func keyboardOptionsView(_ view: KeyboardOptionsView, didSetBottomPanelExpanded expanded: Bool) {
        guard usesMacCollapsibleBottomPanel else { return }

        keyboardOptionsHeightConstraint?.constant = expanded ? macKeyboardOptionsExpandedHeight : 0
        updateAllToolbarButtonAppearances()

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
}

extension EditDesignViewController: AspectRatioPickerDelegate {
    func didSelectAspectRatio(width: Int, height: Int) {
        let size = CanvasDimensions.pixelSize(forAspectWidth: width, height: height)
        canvasWidth = size.width
        canvasHeight = size.height
        if var d = design {
            d.width = canvasWidth
            d.height = canvasHeight
            design = d
        }
        embeddedAspectRatioPickerViewController?.selectedCanvasSize = CGSize(width: canvasWidth, height: canvasHeight)
        keyboardOptionsView.update(with: currentDesign)
        updateDesignImage()
    }
}

private extension EditDesignViewController {
    /// Detaches `child` from any prior parent before embedding to avoid duplicate `addChild` warnings when switching panels quickly.
    func embedChildViewController(
        _ child: UIViewController,
        in container: UIView,
        constraints: (UIView) -> [NSLayoutConstraint]
    ) {
        if child.parent != nil || child.view.superview != nil {
            child.willMove(toParent: nil)
            child.view.removeFromSuperview()
            child.removeFromParent()
        }
        addChild(child)
        container.addSubview(child.view)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints(child.view))
        child.didMove(toParent: self)
    }
}

extension EditDesignViewController: FilterStylesViewControllerDelegate {
    func filterStylesViewController(
        _ controller: FilterStylesViewController,
        didSelect preset: FilterPreset
    ) {
        didApplyFilterPreset(preset)
    }
}

extension EditDesignViewController: SettingsReferenceable {

}
