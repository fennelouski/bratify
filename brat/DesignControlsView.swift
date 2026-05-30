import UIKit

protocol DesignControlsDelegate: AnyObject {
    func didChangeBrightness(_ brightness: CGFloat)
    func didChangeContrast(_ contrast: CGFloat)
    func didChangeSaturation(_ saturation: CGFloat)
    func didChangeExposure(_ exposure: CGFloat)
    func didChangeGamma(_ gamma: CGFloat)
    func didChangeSepia(_ sepia: CGFloat)
    func didChangeInvert(_ invert: Bool)
    func didChangePixelate(_ pixelate: CGFloat)
    func didChangeSharpen(_ sharpen: CGFloat)
    func didChangeMonochrome(_ monochrome: CGFloat)
    func didChangeVignette(_ vignette: CGFloat)
    
    func didChangeBackgroundScale(_ scale: CGFloat)
    func didChangeBackgroundFlipHorizontal(_ flip: Bool)
    func didChangeBackgroundFlipVertical(_ flip: Bool)
    func didChangeBackgroundBlur(_ blur: CGFloat)
    func didChangeBackgroundAlpha(_ alpha: CGFloat)
    func didChangeBackgroundBrightness(_ brightness: CGFloat)
    func didChangeBackgroundContrast(_ contrast: CGFloat)
    func didChangeBackgroundSaturation(_ saturation: CGFloat)
    func didChangeBackgroundExposure(_ exposure: CGFloat)
    func didChangeBackgroundGamma(_ gamma: CGFloat)
    func didChangeBackgroundSepia(_ sepia: CGFloat)
    func didChangeBackgroundInvert(_ invert: Bool)
    func didChangeBackgroundPixelate(_ pixelate: CGFloat)
    func didChangeBackgroundSharpen(_ sharpen: CGFloat)
    func didChangeBackgroundMonochrome(_ monochrome: CGFloat)
    func didChangeBackgroundVignette(_ vignette: CGFloat)

    func didChangeHue(_ hue: CGFloat)
    func didChangeHighlightAmount(_ amount: CGFloat)
    func didChangeShadowAmount(_ amount: CGFloat)
    func didChangeGrain(_ grain: CGFloat)
    func didChangeBloom(_ bloom: CGFloat)
    func didChangeDuotoneIntensity(_ intensity: CGFloat)
    func didChangeVibrance(_ vibrance: CGFloat)
    func didChangePosterizeLevels(_ levels: CGFloat)
    func didChangeColorTemperature(_ temperature: CGFloat)
    func didChangeColorTint(_ tint: CGFloat)
    func didChangeHalftone(_ halftone: CGFloat)
    func didChangeUnsharpMask(_ amount: CGFloat)

    func didChangeBackgroundHue(_ hue: CGFloat)
    func didChangeBackgroundHighlightAmount(_ amount: CGFloat)
    func didChangeBackgroundShadowAmount(_ amount: CGFloat)
    func didChangeBackgroundGrain(_ grain: CGFloat)
    func didChangeBackgroundBloom(_ bloom: CGFloat)
    func didChangeBackgroundDuotoneIntensity(_ intensity: CGFloat)
    func didChangeBackgroundVibrance(_ vibrance: CGFloat)
    func didChangeBackgroundPosterizeLevels(_ levels: CGFloat)
    func didChangeBackgroundColorTemperature(_ temperature: CGFloat)
    func didChangeBackgroundColorTint(_ tint: CGFloat)
    func didChangeBackgroundHalftone(_ halftone: CGFloat)
    func didChangeBackgroundUnsharpMask(_ amount: CGFloat)

    func didApplyFilterPreset(_ preset: FilterPreset)
    func didRequestCopyBackgroundFiltersToMain()
    func didRequestResetMainImageFilters()
    func didRequestResetBackgroundImageFilters()

    func willBeginContinuousEdit()
    func didEndContinuousEdit()

    var currentDesign: Design { get }
}

class DesignControlsView: UIView {

    weak var delegate: DesignControlsDelegate?
    private var design: Design
    private var tableView: UITableView!
    private let settingsManager: SettingsManager
    
    enum Section: Int, CaseIterable {
        case mainImage
        case backgroundImage
        
        var title: String {
            switch self {
            case .mainImage:
                return NSLocalizedString("Main Image Controls", comment: "Title for main image controls section")
            case .backgroundImage:
                return NSLocalizedString("Background Image Controls", comment: "Title for background image controls section")
            }
        }
    }
    
    enum MainImageRow: Int, CaseIterable {
        case brightness
        case contrast
        case saturation
        case exposure
        case gamma
        case hue
        case vibrance
        case highlightAmount
        case shadowAmount
        case sepia
        case duotoneIntensity
        case grain
        case bloom
        case posterizeLevels
        case colorTemperature
        case colorTint
        case halftone
        case pixelate
        case sharpen
        case unsharpMask
        case monochrome
        case vignette
        case invert
    }
    
    enum BackgroundImageRow: Int, CaseIterable {
        case invert
        case flipHorizontal
        case flipVertical
        case alpha
        case pixelate
        case blur
        case exposure
        case brightness
        case contrast
        case saturation
        case gamma
        case hue
        case vibrance
        case highlightAmount
        case shadowAmount
        case sepia
        case duotoneIntensity
        case grain
        case bloom
        case posterizeLevels
        case colorTemperature
        case colorTint
        case halftone
        case monochrome
        case scale
        case sharpen
        case unsharpMask
        case vignette
    }

    private lazy var mainFooter = FilterActionsFooterView(
        primaryTitle: NSLocalizedString("Reset Main Filters", comment: "Reset main image filters"),
        secondaryTitle: NSLocalizedString("Copy Background → Main", comment: "Copy background filters to main")
    )

    private lazy var backgroundFooter = FilterActionsFooterView(
        primaryTitle: NSLocalizedString("Reset Background Filters", comment: "Reset background image filters"),
        secondaryTitle: ""
    )
    
    init(
        design: Design,
        settingsManager: SettingsManager
    ) {
        self.design = design
        self.settingsManager = settingsManager
        super.init(frame: .zero)
        setupTableView()
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

    @objc private func handleELI5ModeChange() {
        tableView.reloadData()
    }
    
    private func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            ControlSliderTableViewCell.self,
            forCellReuseIdentifier: ControlSliderTableViewCell.reuseIdentifier
        )
        tableView.register(
            ControlSwitchTableViewCell.self,
            forCellReuseIdentifier: ControlSwitchTableViewCell.reuseIdentifier
        )
        mainFooter.onPrimary = { [weak self] in
            self?.delegate?.didRequestResetMainImageFilters()
        }
        mainFooter.onSecondary = { [weak self] in
            self?.delegate?.didRequestCopyBackgroundFiltersToMain()
        }
        backgroundFooter.onPrimary = { [weak self] in
            self?.delegate?.didRequestResetBackgroundImageFilters()
        }
        addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension DesignControlsView: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section)! {
        case .mainImage:
            return MainImageRow.allCases.count
        case .backgroundImage:
            return BackgroundImageRow.allCases.count
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let section = Section(rawValue: indexPath.section)!
        
        let showInfo = settingsManager.eli5Mode

        switch section {
        case .mainImage:
            let row = MainImageRow(rawValue: indexPath.row)!
            switch row {
            case .invert:
                let cell = tableView.dequeueReusableCell(withIdentifier: ControlSwitchTableViewCell.reuseIdentifier, for: indexPath) as! ControlSwitchTableViewCell
                let text = NSLocalizedString("Invert", comment: "Invert")
                cell.configure(
                    text: text,
                    isOn: delegate?.currentDesign.invert ?? design.invert,
                    theme: settingsManager.selectedTheme,
                    showInfoButton: showInfo
                )
                cell.selectionStyle = .none
                cell.valueChanged = { [weak self] isOn in
                    self?.delegate?.didChangeInvert(isOn)
                }
                cell.infoButtonTapped = { [weak self] in
                    self?.showELI5Toast(for: text)
                }
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: ControlSliderTableViewCell.reuseIdentifier, for: indexPath) as! ControlSliderTableViewCell
                let (text, value, min, max, resetValue, mode, thumbImage) = sliderProperties(for: row)
                cell.configure(
                    text: text,
                    with: value,
                    min: min,
                    max: max,
                    resetValue: resetValue,
                    mode: mode,
                    thumbImage: thumbImage,
                    theme: settingsManager.selectedTheme,
                    showInfoButton: showInfo
                )
                cell.selectionStyle = .none
                cell.valueChanged = { [weak self] newValue in
                    self?.handleSliderChange(for: row, value: newValue)
                }
                cell.sliderBegan = { [weak self] in self?.delegate?.willBeginContinuousEdit() }
                cell.sliderEnded = { [weak self] in self?.delegate?.didEndContinuousEdit() }
                cell.infoButtonTapped = { [weak self] in
                    self?.showELI5Toast(for: text)
                }
                return cell
            }
        case .backgroundImage:
            let row = BackgroundImageRow(rawValue: indexPath.row)!
            switch row {
            case .flipHorizontal, .flipVertical, .invert:
                let cell = tableView.dequeueReusableCell(withIdentifier: ControlSwitchTableViewCell.reuseIdentifier, for: indexPath) as! ControlSwitchTableViewCell
                let (text, isOn) = switchProperties(for: row)
                cell.configure(
                    text: text,
                    isOn: isOn,
                    theme: settingsManager.selectedTheme,
                    showInfoButton: showInfo
                )
                cell.selectionStyle = .none
                cell.valueChanged = { [weak self] isOn in
                    self?.handleSwitchChange(for: row, isOn: isOn)
                }
                cell.infoButtonTapped = { [weak self] in
                    self?.showELI5Toast(for: text)
                }
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: ControlSliderTableViewCell.reuseIdentifier, for: indexPath) as! ControlSliderTableViewCell
                let (text, value, min, max, resetValue, mode, thumbImage) = sliderProperties(for: row)
                cell.configure(
                    text: text,
                    with: value,
                    min: min,
                    max: max,
                    resetValue: resetValue,
                    mode: mode,
                    thumbImage: thumbImage,
                    theme: settingsManager.selectedTheme,
                    showInfoButton: showInfo
                )
                cell.selectionStyle = .none
                cell.valueChanged = { [weak self] newValue in
                    self?.handleSliderChange(for: row, value: newValue)
                }
                cell.sliderBegan = { [weak self] in self?.delegate?.willBeginContinuousEdit() }
                cell.sliderEnded = { [weak self] in self?.delegate?.didEndContinuousEdit() }
                cell.infoButtonTapped = { [weak self] in
                    self?.showELI5Toast(for: text)
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = Section(rawValue: section)!
        let header = UITableViewHeaderFooterView()
        header.textLabel?.text = section.title.localizedLowercase
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch Section(rawValue: section)! {
        case .mainImage:
            return mainFooter
        case .backgroundImage:
            return backgroundFooter
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 44
    }
    
    private func switchProperties(for row: BackgroundImageRow) -> (String, Bool) {
        switch row {
        case .flipHorizontal:
            return (
                NSLocalizedString(
                    "Background Flip Horizontal",
                    comment: "Background Flip Horizontal"
                ),
                delegate?.currentDesign.backgroundFlipHorizontal ?? design.backgroundFlipHorizontal
            )
        case .flipVertical:
            return (
                NSLocalizedString(
                    "Background Flip Vertical",
                    comment: "Background Flip Vertical"
                ),
                delegate?.currentDesign.backgroundFlipVertical ?? design.backgroundFlipVertical
            )
        case .invert:
            return (NSLocalizedString("Background Invert", comment: "Background Invert"), delegate?.currentDesign.backgroundInvert ?? design.backgroundInvert)
        default:
            return ("", false)
        }
    }
    
    private func sliderProperties(for row: MainImageRow) -> (String, Float, Float, Float, Float, ControlSliderTableViewCell.Mode, UIImage?) {
        switch row {
        case .brightness:
            return (NSLocalizedString("Brightness", comment: "Brightness"), Float(delegate?.currentDesign.brightness ?? design.brightness), -1, 1, 0, .alpha, UIImage(systemName: "sun.max"))
        case .contrast:
            return (NSLocalizedString("Contrast", comment: "Contrast"), Float(delegate?.currentDesign.contrast ?? design.contrast), 0, 4, 1, .alpha, UIImage(systemName: "circle.lefthalf.fill"))
        case .saturation:
            return (NSLocalizedString("Saturation", comment: "Saturation"), Float(delegate?.currentDesign.saturation ?? design.saturation), 0, 2, 1, .alpha, UIImage(systemName: "drop"))
        case .exposure:
            return (NSLocalizedString("Exposure", comment: "Exposure"), Float(delegate?.currentDesign.exposure ?? design.exposure), -10, 10, 0, .alpha, UIImage(systemName: "lightbulb"))
        case .gamma:
            return (NSLocalizedString("Gamma", comment: "Gamma"), Float(delegate?.currentDesign.gamma ?? design.gamma), 0, 3, 1, .alpha, UIImage(systemName: "bolt"))
        case .hue:
            return (NSLocalizedString("Hue", comment: "Hue shift"), Float(delegate?.currentDesign.hue ?? design.hue), -180, 180, 0, .integer, UIImage(systemName: "circle.hexagongrid"))
        case .vibrance:
            return (NSLocalizedString("Vibrance", comment: "Vibrance"), Float(delegate?.currentDesign.vibrance ?? design.vibrance), -1, 1, 0, .alpha, UIImage(systemName: "wand.and.stars"))
        case .highlightAmount:
            return (NSLocalizedString("Highlights", comment: "Highlight amount"), Float(delegate?.currentDesign.highlightAmount ?? design.highlightAmount), 0, 2, 1, .alpha, UIImage(systemName: "sun.max.fill"))
        case .shadowAmount:
            return (NSLocalizedString("Shadows", comment: "Shadow amount"), Float(delegate?.currentDesign.shadowAmount ?? design.shadowAmount), -1, 1, 0, .alpha, UIImage(systemName: "moon.fill"))
        case .duotoneIntensity:
            return (NSLocalizedString("Duotone", comment: "Duotone intensity"), Float(delegate?.currentDesign.duotoneIntensity ?? design.duotoneIntensity), 0, 1, 0, .alpha, UIImage(systemName: "paintpalette"))
        case .grain:
            return (NSLocalizedString("Grain", comment: "Film grain"), Float(delegate?.currentDesign.grain ?? design.grain), 0, 1, 0, .alpha, UIImage(systemName: "sparkle"))
        case .bloom:
            return (NSLocalizedString("Bloom", comment: "Bloom glow"), Float(delegate?.currentDesign.bloom ?? design.bloom), 0, 1, 0, .alpha, UIImage(systemName: "rays"))
        case .posterizeLevels:
            return (NSLocalizedString("Posterize", comment: "Posterize levels"), Float(delegate?.currentDesign.posterizeLevels ?? design.posterizeLevels), 0, 12, 0, .integer, UIImage(systemName: "square.grid.3x3"))
        case .colorTemperature:
            return (NSLocalizedString("Temperature", comment: "Color temperature"), Float(delegate?.currentDesign.colorTemperature ?? design.colorTemperature), 4000, 10000, 6500, .integer, UIImage(systemName: "thermometer.medium"))
        case .colorTint:
            return (NSLocalizedString("Tint", comment: "Color tint"), Float(delegate?.currentDesign.colorTint ?? design.colorTint), -100, 100, 0, .integer, UIImage(systemName: "drop.halffull"))
        case .halftone:
            return (NSLocalizedString("Halftone", comment: "Halftone dots"), Float(delegate?.currentDesign.halftone ?? design.halftone), 0, 30, 0, .integer, UIImage(systemName: "circle.grid.2x2"))
        case .unsharpMask:
            return (NSLocalizedString("Unsharp Mask", comment: "Unsharp mask"), Float(delegate?.currentDesign.unsharpMask ?? design.unsharpMask), 0, 2, 0, .alpha, UIImage(systemName: "scope"))
        case .sepia:
            return (NSLocalizedString("Sepia", comment: "Sepia"), Float(delegate?.currentDesign.sepia ?? design.sepia), 0, 1, 0, .alpha, UIImage(systemName: "paintbrush"))
        case .pixelate:
            return (NSLocalizedString("Pixelate", comment: "Pixelate"), Float(delegate?.currentDesign.pixelate ?? design.pixelate), 0, 100, 3, .integer, UIImage(systemName: "mosaic"))
        case .sharpen:
            return (NSLocalizedString("Sharpen", comment: "Sharpen"), Float(delegate?.currentDesign.sharpen ?? design.sharpen), 0, 2, 0, .alpha, UIImage(systemName: "sparkles"))
        case .monochrome:
            return (NSLocalizedString("Monochrome", comment: "Monochrome"), Float(delegate?.currentDesign.monochrome ?? design.monochrome), 0, 1, 0, .alpha, UIImage(systemName: "moon.stars"))
        case .vignette:
            return (
                NSLocalizedString("Vignette", comment: "Vignette"),
                Float(delegate?.currentDesign.vignette ?? design.vignette),
                0,
                20,
                0,
                .alpha,
                UIImage(systemName: "circle")
            )
        case .invert:
            fatalError("Invert is a switch property, not a slider")
        }
    }
    
    private func sliderProperties(for row: BackgroundImageRow) -> (String, Float, Float, Float, Float, ControlSliderTableViewCell.Mode, UIImage?) {
        switch row {
        case .scale:
            return (
                NSLocalizedString("Background Scale", comment: "Background Scale"),
                Float(delegate?.currentDesign.backgroundScale ?? design.backgroundScale),
                0.01,
                1,
                1,
                .alpha,
                UIImage(systemName: "arrow.up.and.down.circle")
            )
        case .blur:
            return (
                NSLocalizedString("Background Blur", comment: "Background Blur"),
                Float(delegate?.currentDesign.backgroundBlur ?? design.backgroundBlur),
                0,
                50,
                0,
                .alpha,
                UIImage(systemName: "drop.fill")
            )
        case .alpha:
            return (
                NSLocalizedString("Background Alpha", comment: "Background Alpha"),
                Float(delegate?.currentDesign.backgroundAlpha ?? design.backgroundAlpha),
                0,
                1,
                1,
                .alpha,
                UIImage(systemName: "circle.fill")
            )
        case .brightness:
            return (
                NSLocalizedString("Background Brightness", comment: "Background Brightness"),
                Float(
                    delegate?.currentDesign.backgroundBrightness ?? design.backgroundBrightness
                ),
                -1,
                1,
                0,
                .alpha,
                UIImage(systemName: "sun.max")
            )
        case .contrast:
            return (
                NSLocalizedString(
                    "Background Contrast",
                    comment: "Background Contrast"
                ),
                Float(delegate?.currentDesign.backgroundContrast ?? design.backgroundContrast),
                0,
                4,
                1,
                .alpha,
                UIImage(systemName: "circle.lefthalf.fill")
            )
        case .saturation:
            return (
                NSLocalizedString("Background Saturation", comment: "Background Saturation"),
                Float(delegate?.currentDesign.backgroundSaturation ?? design.backgroundSaturation),
                0,
                2,
                1,
                .alpha,
                UIImage(systemName: "drop")
            )
        case .exposure:
            return (
                NSLocalizedString("Background Exposure", comment: "Background Exposure"),
                Float(delegate?.currentDesign.backgroundExposure ?? design.backgroundExposure),
                -10,
                10,
                0,
                .alpha,
                UIImage(systemName: "lightbulb")
            )
        case .gamma:
            return (
                NSLocalizedString("Background Gamma", comment: "Background Gamma"),
                Float(delegate?.currentDesign.backgroundGamma ?? design.backgroundGamma),
                0,
                3,
                1,
                .alpha,
                UIImage(systemName: "bolt")
            )
        case .hue:
            return (NSLocalizedString("Background Hue", comment: "Background hue"), Float(delegate?.currentDesign.backgroundHue ?? design.backgroundHue), -180, 180, 0, .integer, UIImage(systemName: "circle.hexagongrid"))
        case .vibrance:
            return (NSLocalizedString("Background Vibrance", comment: "Background vibrance"), Float(delegate?.currentDesign.backgroundVibrance ?? design.backgroundVibrance), -1, 1, 0, .alpha, UIImage(systemName: "wand.and.stars"))
        case .highlightAmount:
            return (NSLocalizedString("Background Highlights", comment: "Background highlights"), Float(delegate?.currentDesign.backgroundHighlightAmount ?? design.backgroundHighlightAmount), 0, 2, 1, .alpha, UIImage(systemName: "sun.max.fill"))
        case .shadowAmount:
            return (NSLocalizedString("Background Shadows", comment: "Background shadows"), Float(delegate?.currentDesign.backgroundShadowAmount ?? design.backgroundShadowAmount), -1, 1, 0, .alpha, UIImage(systemName: "moon.fill"))
        case .duotoneIntensity:
            return (NSLocalizedString("Background Duotone", comment: "Background duotone"), Float(delegate?.currentDesign.backgroundDuotoneIntensity ?? design.backgroundDuotoneIntensity), 0, 1, 0, .alpha, UIImage(systemName: "paintpalette"))
        case .grain:
            return (NSLocalizedString("Background Grain", comment: "Background grain"), Float(delegate?.currentDesign.backgroundGrain ?? design.backgroundGrain), 0, 1, 0, .alpha, UIImage(systemName: "sparkle"))
        case .bloom:
            return (NSLocalizedString("Background Bloom", comment: "Background bloom"), Float(delegate?.currentDesign.backgroundBloom ?? design.backgroundBloom), 0, 1, 0, .alpha, UIImage(systemName: "rays"))
        case .posterizeLevels:
            return (NSLocalizedString("Background Posterize", comment: "Background posterize"), Float(delegate?.currentDesign.backgroundPosterizeLevels ?? design.backgroundPosterizeLevels), 0, 12, 0, .integer, UIImage(systemName: "square.grid.3x3"))
        case .colorTemperature:
            return (NSLocalizedString("Background Temperature", comment: "Background temperature"), Float(delegate?.currentDesign.backgroundColorTemperature ?? design.backgroundColorTemperature), 4000, 10000, 6500, .integer, UIImage(systemName: "thermometer.medium"))
        case .colorTint:
            return (NSLocalizedString("Background Tint", comment: "Background tint"), Float(delegate?.currentDesign.backgroundColorTint ?? design.backgroundColorTint), -100, 100, 0, .integer, UIImage(systemName: "drop.halffull"))
        case .halftone:
            return (NSLocalizedString("Background Halftone", comment: "Background halftone"), Float(delegate?.currentDesign.backgroundHalftone ?? design.backgroundHalftone), 0, 30, 0, .integer, UIImage(systemName: "circle.grid.2x2"))
        case .unsharpMask:
            return (NSLocalizedString("Background Unsharp Mask", comment: "Background unsharp mask"), Float(delegate?.currentDesign.backgroundUnsharpMask ?? design.backgroundUnsharpMask), 0, 2, 0, .alpha, UIImage(systemName: "scope"))
        case .sepia:
            return (
                NSLocalizedString("Background Sepia", comment: "Background Sepia"),
                Float(delegate?.currentDesign.backgroundSepia ?? design.backgroundSepia),
                0,
                1,
                0,
                .alpha,
                UIImage(systemName: "paintbrush")
            )
        case .pixelate:
            return (
                NSLocalizedString("Background Pixelate", comment: "Background Pixelate"),
                Float(delegate?.currentDesign.backgroundPixelate ?? design.backgroundPixelate),
                0,
                100,
                0,
                .integer,
                UIImage(systemName: "mosaic")
            )
        case .sharpen:
            return (
                NSLocalizedString("Background Sharpen", comment: "Background Sharpen"),
                Float(delegate?.currentDesign.backgroundSharpen ?? design.backgroundSharpen),
                0,
                2,
                1,
                .alpha,
                UIImage(systemName: "sparkles")
            )
        case .monochrome:
            return (
                NSLocalizedString("Background Monochrome", comment: "Background Monochrome"),
                Float(delegate?.currentDesign.backgroundMonochrome ?? design.backgroundMonochrome),
                0,
                1,
                0,
                .alpha,
                UIImage(systemName: "moon.stars")
            )
        case .vignette:
            return (
                NSLocalizedString("Background Vignette", comment: "Background Vignette"),
                Float(delegate?.currentDesign.backgroundVignette ?? design.backgroundVignette),
                -20,
                20,
                0,
                .alpha,
                UIImage(systemName: "circle")
            )
        case .flipHorizontal, .flipVertical, .invert:
            fatalError("FlipHorizontal, FlipVertical, and Invert are switch properties, not sliders")
        }
    }
    
    private func handleSliderChange(for row: MainImageRow, value: Float) {
        let newValue = CGFloat(value)
        switch row {
        case .brightness:
            delegate?.didChangeBrightness(newValue)
        case .contrast:
            delegate?.didChangeContrast(newValue)
        case .saturation:
            delegate?.didChangeSaturation(newValue)
        case .exposure:
            delegate?.didChangeExposure(newValue)
        case .gamma:
            delegate?.didChangeGamma(newValue)
        case .hue:
            delegate?.didChangeHue(newValue)
        case .vibrance:
            delegate?.didChangeVibrance(newValue)
        case .highlightAmount:
            delegate?.didChangeHighlightAmount(newValue)
        case .shadowAmount:
            delegate?.didChangeShadowAmount(newValue)
        case .duotoneIntensity:
            delegate?.didChangeDuotoneIntensity(newValue)
        case .grain:
            delegate?.didChangeGrain(newValue)
        case .bloom:
            delegate?.didChangeBloom(newValue)
        case .posterizeLevels:
            delegate?.didChangePosterizeLevels(newValue)
        case .colorTemperature:
            delegate?.didChangeColorTemperature(newValue)
        case .colorTint:
            delegate?.didChangeColorTint(newValue)
        case .halftone:
            delegate?.didChangeHalftone(newValue)
        case .unsharpMask:
            delegate?.didChangeUnsharpMask(newValue)
        case .sepia:
            delegate?.didChangeSepia(newValue)
        case .pixelate:
            delegate?.didChangePixelate(newValue)
        case .sharpen:
            delegate?.didChangeSharpen(newValue)
        case .monochrome:
            delegate?.didChangeMonochrome(newValue)
        case .vignette:
            delegate?.didChangeVignette(newValue)
        case .invert:
            fatalError("Invert is a switch property, not a slider")
        }
    }
    
    private func handleSliderChange(for row: BackgroundImageRow, value: Float) {
        let newValue = CGFloat(value)
        switch row {
        case .scale:
            delegate?.didChangeBackgroundScale(newValue)
        case .blur:
            delegate?.didChangeBackgroundBlur(newValue)
        case .alpha:
            delegate?.didChangeBackgroundAlpha(newValue)
        case .brightness:
            delegate?.didChangeBackgroundBrightness(newValue)
        case .contrast:
            delegate?.didChangeBackgroundContrast(newValue)
        case .saturation:
            delegate?.didChangeBackgroundSaturation(newValue)
        case .exposure:
            delegate?.didChangeBackgroundExposure(newValue)
        case .gamma:
            delegate?.didChangeBackgroundGamma(newValue)
        case .hue:
            delegate?.didChangeBackgroundHue(newValue)
        case .vibrance:
            delegate?.didChangeBackgroundVibrance(newValue)
        case .highlightAmount:
            delegate?.didChangeBackgroundHighlightAmount(newValue)
        case .shadowAmount:
            delegate?.didChangeBackgroundShadowAmount(newValue)
        case .duotoneIntensity:
            delegate?.didChangeBackgroundDuotoneIntensity(newValue)
        case .grain:
            delegate?.didChangeBackgroundGrain(newValue)
        case .bloom:
            delegate?.didChangeBackgroundBloom(newValue)
        case .posterizeLevels:
            delegate?.didChangeBackgroundPosterizeLevels(newValue)
        case .colorTemperature:
            delegate?.didChangeBackgroundColorTemperature(newValue)
        case .colorTint:
            delegate?.didChangeBackgroundColorTint(newValue)
        case .halftone:
            delegate?.didChangeBackgroundHalftone(newValue)
        case .unsharpMask:
            delegate?.didChangeBackgroundUnsharpMask(newValue)
        case .sepia:
            delegate?.didChangeBackgroundSepia(newValue)
        case .pixelate:
            delegate?.didChangeBackgroundPixelate(newValue)
        case .sharpen:
            delegate?.didChangeBackgroundSharpen(newValue)
        case .monochrome:
            delegate?.didChangeBackgroundMonochrome(newValue)
        case .vignette:
            delegate?.didChangeBackgroundVignette(newValue)
        case .flipHorizontal, .flipVertical, .invert:
            fatalError("FlipHorizontal, FlipVertical, and Invert are switch properties, not sliders")
        }
    }
    
    private func handleSwitchChange(for row: BackgroundImageRow, isOn: Bool) {
        switch row {
        case .flipHorizontal:
            delegate?.didChangeBackgroundFlipHorizontal(isOn)
        case .flipVertical:
            delegate?.didChangeBackgroundFlipVertical(isOn)
        case .invert:
            delegate?.didChangeBackgroundInvert(isOn)
        default:
            break
        }
    }

    private func showELI5Toast(for label: String) {
        guard let window = self.window else { return }
        let desc = ELI5Descriptions.forDesignControl(label)
        ToastView.show(message: desc, icon: "info.circle", in: window, duration: 5.0)
    }
}

class ControlSliderTableViewCell: UITableViewCell {

    static let reuseIdentifier = "ControlSliderTableViewCell"

    enum Mode {
        case alpha
        case integer
        case unknown
    }

    var label: UILabel!
    var slider: UISlider!
    var valueLabel: UILabel!
    var mode: Mode = .unknown
    var valueChanged: ((Float) -> Void)?
    var sliderBegan: (() -> Void)?
    var sliderEnded: (() -> Void)?
    var infoButtonTapped: (() -> Void)?

    private let infoButton = UIButton(type: .system)
    private var infoButtonWidthConstraint: NSLayoutConstraint!
    private let macIconImageView = UIImageView()
    private lazy var macLayoutInstaller = SliderMacRowLayoutInstaller(iconImageView: macIconImageView)

    var showInfoButton: Bool = false {
        didSet {
            infoButtonWidthConstraint.constant = showInfoButton ? 28 : 0
            infoButton.isHidden = !showInfoButton
            infoButton.isUserInteractionEnabled = showInfoButton
        }
    }

    private var thumbImage: UIImage? {
        didSet {
            guard oldValue != thumbImage else {
                return
            }
            if SliderMacRowLayout.isEnabled(for: traitCollection) {
                macLayoutInstaller.setIconImage(thumbImage, traitCollection: traitCollection)
            } else {
                slider.setThumbImage(thumbImage, for: .normal)
            }
        }
    }

    private var previousValue: Float?
    private var resetValue: Float?
    
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityLabel = NSLocalizedString("Slider Label", comment: "Slider Label")
        contentView.addSubview(label)

        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        infoButton.setImage(UIImage(systemName: "info.circle", withConfiguration: config), for: .normal)
        infoButton.tintColor = .secondaryLabel
        infoButton.isHidden = true
        infoButton.isUserInteractionEnabled = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.addTarget(self, action: #selector(infoButtonAction), for: .touchUpInside)
        contentView.addSubview(infoButton)

        slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(sliderTouchDown), for: .touchDown)
        slider.addTarget(self, action: #selector(sliderTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        slider.accessibilityLabel = NSLocalizedString("Slider", comment: "Slider")
        contentView.addSubview(slider)

        valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = UIFont.preferredFont(forTextStyle: .body)
        valueLabel.adjustsFontForContentSizeCategory = true
        valueLabel.accessibilityLabel = NSLocalizedString("Value Label", comment: "Value Label")
        contentView.addSubview(valueLabel)

        infoButtonWidthConstraint = infoButton.widthAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([infoButtonWidthConstraint])

        macLayoutInstaller.install(
            in: contentView,
            style: .control,
            margin: 8,
            label: label,
            slider: slider,
            valueLabel: valueLabel,
            infoButton: infoButton
        )

        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(doubleTapRecognizer)

        registerForTraitChanges([UITraitUserInterfaceIdiom.self]) { (self: ControlSliderTableViewCell, previousTraitCollection: UITraitCollection) in
            guard previousTraitCollection.userInterfaceIdiom != self.traitCollection.userInterfaceIdiom else {
                return
            }
            self.macLayoutInstaller.update(for: self.traitCollection)
            if SliderMacRowLayout.isEnabled(for: self.traitCollection) {
                self.slider.setThumbImage(nil, for: .normal)
                self.macLayoutInstaller.setIconImage(self.thumbImage, traitCollection: self.traitCollection)
            } else {
                self.macIconImageView.isHidden = true
                self.slider.setThumbImage(self.thumbImage, for: .normal)
            }
        }
    }

    @objc private func infoButtonAction() {
        infoButtonTapped?()
    }

    func configure(
        text: String,
        with value: Float,
        min: Float,
        max: Float,
        resetValue: Float,
        mode: Mode,
        thumbImage: UIImage?,
        theme: ThemeModel?,
        showInfoButton: Bool = false
    ) {
        valueChanged = nil
        sliderBegan = nil
        sliderEnded = nil
        infoButtonTapped = nil
        self.showInfoButton = showInfoButton
        label.text = text.localizedLowercase
        slider.minimumValue = min
        slider.maximumValue = max
        self.resetValue = resetValue
        self.mode = mode
        slider.value = value
        self.thumbImage = thumbImage
        sliderValueChanged(slider)
        apply(theme)
    }
    
    @objc private func sliderTouchDown() { sliderBegan?() }
    @objc private func sliderTouchUp() { sliderEnded?() }

    @objc private func sliderValueChanged(_ sender: UISlider) {
        switch mode {
        case .alpha:
            let percentage = Int(sender.value * 100)
            valueLabel.text = "\(percentage)%".localizedLowercase
            valueChanged?(sender.value)
        case .integer:
            let roundedValue = Int(sender.value.rounded())
            valueLabel.text = "\(roundedValue)".localizedLowercase
            valueChanged?(Float(roundedValue))
        case .unknown:
            break
        }
    }
    
    @objc private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if let previousValue = previousValue {
            slider.value = previousValue
            sliderValueChanged(slider)
            self.previousValue = nil
        } else {
            previousValue = slider.value
            slider.value = resetValue ?? (slider.minimumValue + slider.maximumValue) / 2
            sliderValueChanged(slider)
        }
    }
}

extension ControlSliderTableViewCell: Themeable {
    func apply(_ colorModel: ColorModel) {
        backgroundColor = .clear
        valueLabel.applyColors(from: colorModel)
        label.applyColors(from: colorModel)
        slider.applyColors(from: colorModel)
        macIconImageView.tintColor = colorModel.textColor
    }
}

class ControlSwitchTableViewCell: UITableViewCell {

    static let reuseIdentifier = "ControlSwitchTableViewCell"

    var label: UILabel!
    var switchControl: UISwitch!
    var valueChanged: ((Bool) -> Void)?
    var infoButtonTapped: (() -> Void)?

    private let infoButton = UIButton(type: .system)
    private var infoButtonWidthConstraint: NSLayoutConstraint!
    private var previousValue: Bool?

    var showInfoButton: Bool = false {
        didSet {
            infoButtonWidthConstraint.constant = showInfoButton ? 28 : 0
            infoButton.isHidden = !showInfoButton
            infoButton.isUserInteractionEnabled = showInfoButton
        }
    }
    
    override init(
        style: UITableViewCell.CellStyle,
        reuseIdentifier: String?
    ) {
        super.init(
            style: style,
            reuseIdentifier: reuseIdentifier
        )
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityLabel = NSLocalizedString("Switch Label", comment: "Switch Label")
        contentView.addSubview(label)

        let config = UIImage.SymbolConfiguration(pointSize: 15, weight: .regular)
        infoButton.setImage(UIImage(systemName: "info.circle", withConfiguration: config), for: .normal)
        infoButton.tintColor = .secondaryLabel
        infoButton.isHidden = true
        infoButton.isUserInteractionEnabled = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.addTarget(self, action: #selector(infoButtonAction), for: .touchUpInside)
        contentView.addSubview(infoButton)

        switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(
            self,
            action: #selector(switchValueChanged(_:)),
            for: .valueChanged
        )
        switchControl.accessibilityLabel = NSLocalizedString("Switch", comment: "Switch")
        contentView.addSubview(switchControl)

        infoButtonWidthConstraint = infoButton.widthAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate(
            [
                label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                label.trailingAnchor.constraint(lessThanOrEqualTo: infoButton.leadingAnchor, constant: -4),

                infoButton.trailingAnchor.constraint(equalTo: switchControl.leadingAnchor, constant: -8),
                infoButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                infoButton.heightAnchor.constraint(equalToConstant: 28),
                infoButtonWidthConstraint,

                switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
            ]
        )

        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(doubleTapRecognizer)
    }

    @objc private func infoButtonAction() {
        infoButtonTapped?()
    }

    func configure(
        text: String,
        isOn: Bool,
        theme: ThemeModel?,
        showInfoButton: Bool = false
    ) {
        valueChanged = nil
        infoButtonTapped = nil
        self.showInfoButton = showInfoButton
        label.text = text.localizedLowercase
        switchControl.isOn = isOn
        apply(theme)
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        valueChanged?(sender.isOn)
    }
    
    @objc private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        if let previousValue = previousValue {
            switchControl.isOn = previousValue
            switchValueChanged(switchControl)
            self.previousValue = nil
        } else {
            previousValue = switchControl.isOn
            switchControl.isOn.toggle()
            switchValueChanged(switchControl)
        }
    }
}

extension ControlSwitchTableViewCell: Themeable {
    func apply(_ colorModel: ColorModel) {
        backgroundColor = .clear
        label.applyColors(from: colorModel)
        switchControl.applyColors(from: colorModel)
    }
}
