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
    internal let settingsManager: SettingsManager
    private let imageService: ImageService
    private var previewImageViewBottomConstraint: NSLayoutConstraint?
    private lazy var keyboardOptionsView = KeyboardOptionsView(settingsManager: settingsManager)

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
            return UIColor(hexString: settingsManager.backgroundColorHex)
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

        // Setup preview image view
        view.addSubview(previewImageView)
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            previewImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: .su2),
            previewImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .su2),
            previewImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.su2)
        ])
        previewImageViewBottomConstraint = previewImageView.bottomAnchor.constraint(
            equalTo: view.bottomAnchor,
            constant: -300
        )
        previewImageViewBottomConstraint?.isActive = true
        
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
            keyboardOptionsView.heightAnchor.constraint(greaterThanOrEqualToConstant: keyboardOptionsViewHeight)
        ])
        
        // Load design if exists
        if let design = design {
            textView.text = design.text
            view.backgroundColor = design.backgroundColor
            originalText = design.text
            originalBackgroundColor = design.backgroundColor
        } else {
            view.backgroundColor = UIColor(hex: settingsManager.backgroundColorHex) ?? .white
        }
        
        // Show keyboard
        view.addSubview(textView)
        textView.becomeFirstResponder()
        textView.backgroundColor = .clear
        
        updateDesignImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        apply(settingsManager.selectedTheme)
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
            view.backgroundColor = design.backgroundColor
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
        colorPicker.selectedColor = view.backgroundColor ?? .white
        colorPicker.delegate = self
        present(colorPicker, animated: true, completion: nil)
        #endif
    }

    private func applyBackgroundColor(_ color: UIColor) {
        view.backgroundColor = color
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
        
        let backgroundColor = view.backgroundColor ?? .white
        
        DesignManager.shared.addDesign(currentDesign)

        settingsManager.backgroundColorHex = backgroundColor.toHexString()
        settingsManager.textColorHex = textColor.toHexString()
    }
    
    private var lastUpdateDate: Date? = nil
    internal func updateDesignImage() {
        let timeLimit = blur > 1 ? 0.12 : 0.06
        if let lastUpdateDate,
           abs(lastUpdateDate.timeIntervalSinceNow) < timeLimit {
            return
        }
        lastUpdateDate = Date()
        
        currentDesign.generateImage(
            with: imageService,
            onBackgroundImageLoadFailed: { [weak self] in
                guard let self else { return }
                ToastView.show(
                    message: NSLocalizedString(
                        "background_image_load_failed",
                        comment: "Toast shown when a design's background image cannot be loaded from disk"
                    ),
                    in: view
                )
            }
        ) { [weak self] returnedImage, _ in
            guard let returnedImage,
                    let self else {
                return
            }
            if Thread.isMainThread {
                self.previewImageView.image = returnedImage
            } else {
                DispatchQueue.main.async {
                    self.previewImageView.image = returnedImage
                }
            }
        }
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            previewImageViewBottomConstraint?.constant = -keyboardFrame.height
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
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
            view.backgroundColor = viewController.selectedColor
            backgroundColor = viewController.selectedColor
            textView.backgroundColor = .clear
        }
        updateDesignImage()
    }

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        if isPickingTextColor {
            textColor = viewController.selectedColor
            settingsManager.textColorHex = viewController.selectedColor.toHexString()
        } else {
            applyBackgroundColor(viewController.selectedColor)
            settingsManager.backgroundColorHex = viewController.selectedColor.toHexString()
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
    
    func selectFont() {
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
        ImageService().saveImageToDisk(
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
