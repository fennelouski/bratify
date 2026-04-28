import UIKit

class DesignCell: UICollectionViewCell {
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let dateLabel: UILabel = {
        let label: UILabel = .dynamicTypeLabel
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        contentView.addSubview(dateLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.8),
            
            dateLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // Apply random corner radius
        applyRandomCornerRadius()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var currentDesign: Design?
    private var imageService: ImageService?

    private lazy var errorOverlay: UIView = {
        let overlay = UIView()
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.55)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isHidden = true

        let iconView = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill"))
        iconView.tintColor = .white
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let retryButton = UIButton(type: .system)
        retryButton.setTitle(NSLocalizedString("retry", comment: "Button to retry loading a failed thumbnail"), for: .normal)
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.addTarget(self, action: #selector(retryImageGeneration), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [iconView, retryButton])
        stack.axis = .vertical
        stack.spacing = .suHalf
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(stack)

        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            stack.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: overlay.centerYAnchor),
        ])
        return overlay
    }()

    @objc private func retryImageGeneration() {
        guard let currentDesign, let imageService else { return }
        configure(with: currentDesign, imageService: imageService)
    }

    private func showErrorOverlay() {
        if errorOverlay.superview == nil {
            imageView.addSubview(errorOverlay)
            NSLayoutConstraint.activate([
                errorOverlay.topAnchor.constraint(equalTo: imageView.topAnchor),
                errorOverlay.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
                errorOverlay.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
                errorOverlay.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
            ])
        }
        errorOverlay.isHidden = false
    }

    private func hideErrorOverlay() {
        errorOverlay.isHidden = true
    }

    func configure(
        with design: Design,
        imageService: ImageService
    ) {
        currentDesign = design
        self.imageService = imageService
        hideErrorOverlay()
        // Configure the cell with the design
        imageView.backgroundColor = design.backgroundColor
        // Here you should set the imageView image to the screenshot of the design using the imageService
        // For now, we set the background color
        dateLabel.text = design.creationDate.spelledOutTimeLowercase()
        
        // Load image using imageService
        let cacheKey = design.description
        if let cachedImage = imageService.memoryCache.object(forKey: cacheKey as NSString) {
            imageView.image = cachedImage
        } else {
            design.generateImage(with: imageService) { [weak self] generatedImage, generatedImageDescription in
                guard let self,
                      let currentDesign,
                      generatedImageDescription == currentDesign.description else {
                    return  // stale result for a recycled cell
                }
                guard let generatedImage else {
                    DispatchQueue.main.async { [weak self] in self?.showErrorOverlay() }
                    return
                }
                
                if Thread.isMainThread {
                    imageView.image = generatedImage
                } else {
                    DispatchQueue.main.async { [weak self] in
                        guard let self else {
                            return
                        }
                        imageView.image = generatedImage
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        currentDesign = nil
        imageService = nil
        hideErrorOverlay()
    }

    private func applyRandomCornerRadius() {
        let topLeftRadius = CGFloat.random(in: 0...16)
        let topRightRadius = CGFloat.random(in: 0...16)
        let bottomLeftRadius = CGFloat.random(in: 0...16)
        let bottomRightRadius = CGFloat.random(in: 0...16)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: topLeftRadius))
        path.addArc(withCenter: CGPoint(x: topLeftRadius, y: topLeftRadius), radius: topLeftRadius, startAngle: CGFloat.pi, endAngle: CGFloat.pi * 1.5, clockwise: true)
        path.addLine(to: CGPoint(x: bounds.width - topRightRadius, y: 0))
        path.addArc(withCenter: CGPoint(x: bounds.width - topRightRadius, y: topRightRadius), radius: topRightRadius, startAngle: CGFloat.pi * 1.5, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height - bottomRightRadius))
        path.addArc(withCenter: CGPoint(x: bounds.width - bottomRightRadius, y: bounds.height - bottomRightRadius), radius: bottomRightRadius, startAngle: 0, endAngle: CGFloat.pi * 0.5, clockwise: true)
        path.addLine(to: CGPoint(x: bottomLeftRadius, y: bounds.height))
        path.addArc(withCenter: CGPoint(x: bottomLeftRadius, y: bounds.height - bottomLeftRadius), radius: bottomLeftRadius, startAngle: CGFloat.pi * 0.5, endAngle: CGFloat.pi, clockwise: true)
        path.addLine(to: CGPoint(x: 0, y: topLeftRadius))
        
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

extension DesignCell: Themeable {
    func apply(_ colorModel: ColorModel) {
        self.imageView.layer.borderColor = colorModel.shadowColor.cgColor
        self.imageView.backgroundColor = colorModel.backgroundColor
        self.dateLabel.textColor = colorModel.textColor
        self.dateLabel.backgroundColor = colorModel.backgroundColor
        self.contentView.backgroundColor = colorModel.tintColor
        backgroundColor = .yellow
    }
}
