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
        case sepia
        case pixelate
        case sharpen
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
        case monochrome
        case sepia
        case scale
        case sharpen
        case vignette
    }
    
    init(
        design: Design,
        settingsManager: SettingsManager
    ) {
        self.design = design
        self.settingsManager = settingsManager
        super.init(frame: .zero)
        setupTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        switch section {
        case .mainImage:
            let row = MainImageRow(rawValue: indexPath.row)!
            switch row {
            case .invert:
                let cell = tableView.dequeueReusableCell(withIdentifier: ControlSwitchTableViewCell.reuseIdentifier, for: indexPath) as! ControlSwitchTableViewCell
                cell.configure(
                    text: NSLocalizedString("Invert", comment: "Invert"),
                    isOn: delegate?.currentDesign.invert ?? design.invert,
                    theme: settingsManager.selectedTheme
                )
                cell.selectionStyle = .none
                cell.valueChanged = { [weak self] isOn in
                    self?.delegate?.didChangeInvert(isOn)
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
                    theme: settingsManager.selectedTheme
                )
                cell.selectionStyle = .none
                cell.valueChanged = { [weak self] newValue in
                    self?.handleSliderChange(for: row, value: newValue)
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
                    theme: settingsManager.selectedTheme
                )
                cell.selectionStyle = .none
                cell.valueChanged = { [weak self] isOn in
                    self?.handleSwitchChange(for: row, isOn: isOn)
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
                    theme: settingsManager.selectedTheme
                )
                cell.selectionStyle = .none
                cell.valueChanged = { [weak self] newValue in
                    self?.handleSliderChange(for: row, value: newValue)
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
    
    private var thumbImage: UIImage? {
        didSet {
            guard oldValue != thumbImage else {
                return
            }
            if traitCollection.userInterfaceIdiom != .mac {
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
        
        slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(
            self,
            action: #selector(sliderValueChanged(_:)),
            for: .valueChanged
        )
        slider.accessibilityLabel = NSLocalizedString("Slider", comment: "Slider")
        contentView.addSubview(slider)
        
        valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.font = UIFont.preferredFont(forTextStyle: .body)
        valueLabel.adjustsFontForContentSizeCategory = true
        valueLabel.accessibilityLabel = NSLocalizedString("Value Label", comment: "Value Label")
        contentView.addSubview(valueLabel)
        
        NSLayoutConstraint.activate(
            [
                label.topAnchor.constraint(
                    equalTo: contentView.topAnchor,
                    constant: 8
                ),
                label.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: 8
                ),
                
                slider.topAnchor.constraint(
                    equalTo: label.bottomAnchor,
                    constant: 8
                ),
                slider.leadingAnchor.constraint(
                    equalTo: contentView.leadingAnchor,
                    constant: 8
                ),
                slider.trailingAnchor.constraint(
                    equalTo: valueLabel.leadingAnchor,
                    constant: -8
                ),
                slider.bottomAnchor.constraint(
                    equalTo: contentView.bottomAnchor,
                    constant: -8
                ),
                
                valueLabel.centerYAnchor.constraint(equalTo: slider.centerYAnchor),
                valueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
                valueLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 40)
            ]
        )
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(doubleTapRecognizer)
    }
    
    func configure(
        text: String,
        with value: Float,
        min: Float,
        max: Float,
        resetValue: Float,
        mode: Mode,
        thumbImage: UIImage?,
        theme: ThemeModel?
    ) {
        valueChanged = nil
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
        slider.applyColors(from: colorModel)
    }
}

class ControlSwitchTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "ControlSwitchTableViewCell"
    
    var label: UILabel!
    var switchControl: UISwitch!
    var valueChanged: ((Bool) -> Void)?
    
    private var previousValue: Bool?
    
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
        
        switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.addTarget(
            self,
            action: #selector(switchValueChanged(_:)),
            for: .valueChanged
        )
        switchControl.accessibilityLabel = NSLocalizedString("Switch", comment: "Switch")
        contentView.addSubview(switchControl)
        
        NSLayoutConstraint.activate(
            [
                label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                
                switchControl.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                switchControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8)
            ]
        )
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTapRecognizer.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(doubleTapRecognizer)
    }
    
    func configure(
        text: String,
        isOn: Bool,
        theme: ThemeModel?
    ) {
        valueChanged = nil
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
