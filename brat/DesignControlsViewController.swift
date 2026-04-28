import UIKit

protocol DesignControlsViewControllerDelegate: AnyObject {
    func designControlsViewController(
        _ controller: DesignControlsViewController,
        didUpdateDesign design: Design
    )
    
    var currentDesign: Design { get }
}

import UIKit

class DesignControlsViewController: UIViewController {

    private var design: Design
    private let settingsManager: SettingsManager
    weak var delegate: DesignControlsViewControllerDelegate?

    private var designControlsView: DesignControlsView!

    init(design: Design, settingsManager: SettingsManager) {
        self.design = design
        self.settingsManager = settingsManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDesignControlsView()
        view.backgroundColor = .systemBackground
        title = NSLocalizedString("Design Controls", comment: "")
        apply(settingsManager.selectedTheme)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        apply(settingsManager.selectedTheme)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        apply(settingsManager.selectedTheme)
    }

    private func setupDesignControlsView() {
        designControlsView = DesignControlsView(
            design: design,
            settingsManager: settingsManager
        )
        designControlsView.delegate = self
        designControlsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(designControlsView)

        NSLayoutConstraint.activate([
            designControlsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            designControlsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            designControlsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            designControlsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension DesignControlsViewController: DesignControlsDelegate {
    var currentDesign: Design {
        delegate?.currentDesign ?? .empty
    }
    
    func didChangeBackgroundScale(_ scale: CGFloat) {
        design.backgroundScale = scale
        delegate?.designControlsViewController(
            self,
            didUpdateDesign: design
        )
    }
    
    func didChangeBackgroundFlipHorizontal(_ flip: Bool) {
        design.backgroundFlipHorizontal = flip
        delegate?.designControlsViewController(
            self,
            didUpdateDesign: design
        )
    }
    
    func didChangeBackgroundFlipVertical(_ flip: Bool) {
        design.backgroundFlipVertical = flip
        delegate?.designControlsViewController(
            self,
            didUpdateDesign: design
        )
    }
    
    func didChangeBackgroundBlur(_ blur: CGFloat) {
        design.backgroundBlur = blur
        delegate?.designControlsViewController(
            self,
            didUpdateDesign: design
        )
    }
    
    func didChangeBackgroundAlpha(_ alpha: CGFloat) {
        design.backgroundAlpha = alpha
        delegate?.designControlsViewController(
            self,
            didUpdateDesign: design
        )
    }
    
    func didChangeBackgroundBrightness(_ brightness: CGFloat) {
        design.backgroundBrightness = brightness
        delegate?.designControlsViewController(
            self,
            didUpdateDesign: design
        )
    }
    
    func didChangeBackgroundContrast(_ contrast: CGFloat) {
        design.backgroundContrast = contrast
        delegate?.designControlsViewController(
            self,
            didUpdateDesign: design
        )
    }
    
    func didChangeBackgroundSaturation(_ saturation: CGFloat) {
        design.backgroundSaturation = saturation
        delegate?.designControlsViewController(
            self,
            didUpdateDesign: design
        )
    }
    
    func didChangeBackgroundExposure(_ exposure: CGFloat) {
        design.backgroundExposure = exposure
        delegate?.designControlsViewController(
            self,
            didUpdateDesign: design
        )
    }
    
    func didChangeBackgroundGamma(_ gamma: CGFloat) {
        design.backgroundGamma = gamma
        delegate?.designControlsViewController(
            self,
            didUpdateDesign: design
        )
    }
    
    func didChangeBackgroundSepia(_ sepia: CGFloat) {
        design.backgroundSepia = sepia
        delegate?.designControlsViewController(
            self,
            didUpdateDesign: design
        )
    }
    
    func didChangeBackgroundInvert(_ invert: Bool) {
        design.backgroundInvert = invert
        delegate?.designControlsViewController(
            self,
            didUpdateDesign: design
        )
    }
    
    func didChangeBackgroundPixelate(_ pixelate: CGFloat) {
        design.backgroundPixelate = pixelate
        delegate?.designControlsViewController(
            self,
            didUpdateDesign: design
        )
    }
    
    func didChangeBackgroundSharpen(_ sharpen: CGFloat) {
        design.backgroundSharpen = sharpen
        delegate?.designControlsViewController(
            self,
            didUpdateDesign: design
        )
    }
    
    func didChangeBackgroundMonochrome(_ monochrome: CGFloat) {
        design.backgroundMonochrome = monochrome
        delegate?.designControlsViewController(
            self,
            didUpdateDesign: design
        )
    }
    
    func didChangeBackgroundVignette(_ vignette: CGFloat) {
        design.backgroundVignette = vignette
        delegate?.designControlsViewController(
            self,
            didUpdateDesign: design
        )
    }
    
    func didChangeBrightness(_ brightness: CGFloat) {
        design.brightness = brightness
        delegate?.designControlsViewController(self, didUpdateDesign: design)
    }

    func didChangeContrast(_ contrast: CGFloat) {
        design.contrast = contrast
        delegate?.designControlsViewController(self, didUpdateDesign: design)
    }

    func didChangeSaturation(_ saturation: CGFloat) {
        design.saturation = saturation
        delegate?.designControlsViewController(self, didUpdateDesign: design)
    }

    func didChangeExposure(_ exposure: CGFloat) {
        design.exposure = exposure
        delegate?.designControlsViewController(self, didUpdateDesign: design)
    }

    func didChangeGamma(_ gamma: CGFloat) {
        design.gamma = gamma
        delegate?.designControlsViewController(self, didUpdateDesign: design)
    }

    func didChangeSepia(_ sepia: CGFloat) {
        design.sepia = sepia
        delegate?.designControlsViewController(self, didUpdateDesign: design)
    }

    func didChangeInvert(_ invert: Bool) {
        design.invert = invert
        delegate?.designControlsViewController(self, didUpdateDesign: design)
    }

    func didChangePixelate(_ pixelate: CGFloat) {
        design.pixelate = pixelate
        delegate?.designControlsViewController(self, didUpdateDesign: design)
    }

    func didChangeSharpen(_ sharpen: CGFloat) {
        design.sharpen = sharpen
        delegate?.designControlsViewController(self, didUpdateDesign: design)
    }

    func didChangeMonochrome(_ monochrome: CGFloat) {
        design.monochrome = monochrome
        delegate?.designControlsViewController(self, didUpdateDesign: design)
    }

    func didChangeVignette(_ vignette: CGFloat) {
        design.vignette = vignette
        delegate?.designControlsViewController(
            self,
            didUpdateDesign: design
        )
    }
}
