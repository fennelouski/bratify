import UIKit

class DesignView: UIView {
    private let textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let backgroundColorView: UIView = UIView(frame: .zero)
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    var design: Design? {
        didSet {
            updateView()
        }
    }
    
    let imageService: ImageService
    var imageName: String? {
        didSet {
            loadImage { _ in }
        }
    }
    
    init(
        frame: CGRect,
        imageService: ImageService
    ) {
        self.imageService = imageService
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(backgroundImageView)
//        addSubview(backgroundColorView)
        addSubview(textLabel)
        
        backgroundImageView.frame = bounds//.insetBy(dx: -50, dy: -50)
//        backgroundColorView.frame = bounds
        textLabel.frame = CGRect(x: bounds.width * 0.1,
                                 y: bounds.height * 0.1,
                                 width: bounds.width * 0.8,
                                 height: bounds.height * 0.8)
        
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func updateView() {
        guard let design = design else { return }
        configure(
            with: design.text,
            backgroundColor: design.backgroundColor,
            fontName: design.fontName,
            fontSize: design.fontSize,
            stretch: design.stretch,
            imageName: design.backgroundImageKey,
            design: design
        ) { _ in }
    }
    
    func configure(
        with text: String,
        backgroundColor: UIColor,
        fontName: String,
        fontSize: CGFloat,
        stretch: CGFloat,
        imageName: String?,
        design: Design,
        completion: @escaping (DesignView) -> Void
    ) {
        self.imageName = imageName
        textLabel.text = text
        textLabel.font = UIFont(name: fontName, size: fontSize)
        self.backgroundColor = backgroundColor
        textLabel.textColor = design.textColor
        textLabel.adjustsFontSizeToFitWidth = true
        
        var widthMultiplier: CGFloat = 0.1
        let scaleTransform: CGAffineTransform
        if stretch < 0 {
            // Squish horizontally
            scaleTransform = CGAffineTransform(scaleX: 1.0 * (1 - stretch * 2), y: 1.0)
            widthMultiplier *= (1 - stretch * 2)
        } else {
            // Stretch horizontally
            scaleTransform = CGAffineTransform(scaleX: 1.0 * (1 - stretch), y: 1.0)
        }
        
        textLabel.transform = scaleTransform
        
        textLabel.frame = CGRect(x: bounds.width * widthMultiplier,
                                 y: bounds.height * 0.1,
                                 width: bounds.width * (1 - 2 * widthMultiplier),
                                 height: bounds.height * 0.8)
        
        applyBackgroundImageFilters(design) { filteredImage in
            if Thread.isMainThread {
                self.backgroundImageView.image = filteredImage
                self.backgroundImageView.alpha = design.backgroundAlpha
                completion(self)
            } else {
                DispatchQueue.main.async {
                    self.backgroundImageView.image = filteredImage
                    self.backgroundImageView.alpha = design.backgroundAlpha
                    completion(self)
                }
            }
        }
    }
    
    private func applyBackgroundImageFilters(
        _ design: Design,
        completion: @escaping (UIImage?) -> Void
    ) {
        guard let imageName = imageName,
              !imageName.isEmpty else {
            completion(nil)
            return
        }

        if let image = imageService.memoryCache.object(forKey: imageName as NSString) {
            let resizedImage = image.resized(to: CGSize(width: design.width, height: design.height))
            let filteredImage = resizedImage.applyFilters(
                brightness: design.backgroundBrightness,
                contrast: design.backgroundContrast,
                saturation: design.backgroundSaturation,
                exposure: design.backgroundExposure,
                gamma: design.backgroundGamma,
                sepia: design.backgroundSepia,
                invert: design.backgroundInvert,
                pixelate: design.backgroundPixelate,
                sharpen: design.backgroundSharpen,
                monochrome: design.backgroundMonochrome,
                vignette: design.backgroundVignette
            )?.fastScaled(
                by: design.backgroundScale,
                flipHorizontal: design.backgroundFlipHorizontal,
                flipVertical: design.backgroundFlipVertical,
                blur: design.backgroundBlur
            )
            completion(filteredImage)
        } else {
            DispatchQueue.global(qos: .background).async { [weak self] in
                if let image = self?.imageService.loadImageFromDisk(with: imageName) {
                    let resizedImage = image.resized(to: CGSize(width: design.width, height: design.height))
                    let filteredImage = resizedImage.applyFilters(
                        brightness: design.backgroundBrightness,
                        contrast: design.backgroundContrast,
                        saturation: design.backgroundSaturation,
                        exposure: design.backgroundExposure,
                        gamma: design.backgroundGamma,
                        sepia: design.backgroundSepia,
                        invert: design.backgroundInvert,
                        pixelate: design.backgroundPixelate,
                        sharpen: design.backgroundSharpen,
                        monochrome: design.backgroundMonochrome,
                        vignette: design.backgroundVignette
                    )?.fastScaled(
                        by: design.backgroundScale,
                        flipHorizontal: design.backgroundFlipHorizontal,
                        flipVertical: design.backgroundFlipVertical,
                        blur: design.backgroundBlur
                    )
                    DispatchQueue.main.async {
                        completion(filteredImage)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
    }


    
    private func loadImage(completion: @escaping (UIImage?) -> Void) {
        guard let imageName = imageName else {
            completion(nil)
            return
        }
        
        if let image = imageService.memoryCache.object(forKey: imageName as NSString) {
            completion(image)
        } else {
            DispatchQueue.global(qos: .background).async { [weak self] in
                if let image = self?.imageService.loadImageFromDisk(with: imageName) {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                } else {
                    completion(nil)
                }
            }
        }
    }
}

extension DesignView: Themeable {
    func apply(_ colorModel: ColorModel) {
        // no-op
    }
}

private extension UIImage {
    func resized(to targetSize: CGSize) -> UIImage {
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio)

        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        UIGraphicsBeginImageContextWithOptions(scaledImageSize, false, 0)
        draw(in: CGRect(origin: .zero, size: scaledImageSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resizedImage ?? self
    }
}
