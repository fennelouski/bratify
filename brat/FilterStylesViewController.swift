//
//  FilterStylesViewController.swift
//  brat
//

import UIKit

protocol FilterStylesViewControllerDelegate: AnyObject {
    func filterStylesViewController(_ controller: FilterStylesViewController, didSelect preset: FilterPreset)
    func filterStylesViewControllerDidDeselectStyle(_ controller: FilterStylesViewController)
    func filterStylesViewController(_ controller: FilterStylesViewController, didChangeTarget target: FilterPresetTarget)
    func filterStylesViewController(_ controller: FilterStylesViewController, didChangeIntensity intensity: CGFloat)
    func filterStylesViewControllerWillBeginIntensityDrag(_ controller: FilterStylesViewController)
    func filterStylesViewControllerDidEndIntensityDrag(_ controller: FilterStylesViewController)
}

/// Preset-only panel for filter looks (embeddable in sidebar or popover).
final class FilterStylesViewController: UIViewController {

    weak var delegate: FilterStylesViewControllerDelegate?

    var onDone: (() -> Void)?

    private let settingsManager: SettingsManager
    private var selectedPresetID: String?

    private let showsSidebarChrome: Bool

    private(set) var selectedTarget: FilterPresetTarget = .both
    private(set) var selectedIntensity: CGFloat = 1.0

    private let pickerView = FilterPresetPickerView()

    private let sidebarHeaderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let sidebarTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        return label
    }()

    private lazy var sidebarDoneButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(
            NSLocalizedString("Done", comment: "Dismiss filter styles sidebar").localizedLowercase,
            for: .normal
        )
        button.addTarget(self, action: #selector(sidebarDoneTapped), for: .touchUpInside)
        return button
    }()

    private let sidebarSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()

    private let filterControlsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var targetSegmentedControl: UISegmentedControl = {
        let items = [
            NSLocalizedString("Text", comment: "Filter target: main image/text layer"),
            NSLocalizedString("BG", comment: "Filter target: background layer"),
            NSLocalizedString("Both", comment: "Filter target: both layers"),
        ]
        let control = UISegmentedControl(items: items)
        control.translatesAutoresizingMaskIntoConstraints = false
        control.selectedSegmentIndex = 2
        control.addTarget(self, action: #selector(targetSegmentChanged), for: .valueChanged)
        return control
    }()

    private lazy var intensitySlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 1
        slider.isEnabled = false
        slider.addTarget(self, action: #selector(intensitySliderChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(intensitySliderTouchDown), for: .touchDown)
        slider.addTarget(self, action: #selector(intensitySliderDidEnd), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        return slider
    }()

    private let intensityPercentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "100%"
        label.font = UIFont.monospacedDigitSystemFont(ofSize: UIFont.smallSystemFontSize, weight: .regular)
        label.textAlignment = .right
        return label
    }()

    init(settingsManager: SettingsManager, showsSidebarChrome: Bool = false) {
        self.settingsManager = settingsManager
        self.showsSidebarChrome = showsSidebarChrome
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        title = NSLocalizedString("Styles", comment: "Filter styles panel title")

        if showsSidebarChrome {
            setupSidebarChrome()
        }

        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.onSelectPreset = { [weak self] preset in
            self?.handlePresetSelected(preset)
        }
        pickerView.onDeselectPreset = { [weak self] in
            self?.handlePresetDeselected()
        }

        setupFilterControls()
        view.addSubview(pickerView)
        reloadSelection(selectedPresetID: selectedPresetID)

        let controlsTopAnchor: NSLayoutYAxisAnchor
        if showsSidebarChrome {
            controlsTopAnchor = sidebarSeparator.bottomAnchor
        } else {
            controlsTopAnchor = view.safeAreaLayoutGuide.topAnchor
        }

        NSLayoutConstraint.activate([
            filterControlsContainerView.topAnchor.constraint(equalTo: controlsTopAnchor, constant: .su),
            filterControlsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            filterControlsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            pickerView.topAnchor.constraint(equalTo: filterControlsContainerView.bottomAnchor, constant: .su2),
            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            pickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadSelection(selectedPresetID: selectedPresetID)
    }

    func reloadSelection(selectedPresetID: String?) {
        self.selectedPresetID = selectedPresetID
        intensitySlider.isEnabled = selectedPresetID != nil
        pickerView.configure(
            theme: settingsManager.selectedTheme,
            selectedPresetID: selectedPresetID
        )
    }

    private func setupFilterControls() {
        view.addSubview(filterControlsContainerView)

        let strengthLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = NSLocalizedString("strength", comment: "Filter intensity slider label")
            label.font = UIFont.preferredFont(forTextStyle: .caption1)
            label.textColor = .secondaryLabel
            return label
        }()

        let intensityRowView = UIView()
        intensityRowView.translatesAutoresizingMaskIntoConstraints = false

        intensityRowView.addSubview(strengthLabel)
        intensityRowView.addSubview(intensitySlider)
        intensityRowView.addSubview(intensityPercentLabel)

        filterControlsContainerView.addSubview(targetSegmentedControl)
        filterControlsContainerView.addSubview(intensityRowView)

        NSLayoutConstraint.activate([
            targetSegmentedControl.topAnchor.constraint(equalTo: filterControlsContainerView.topAnchor),
            targetSegmentedControl.leadingAnchor.constraint(equalTo: filterControlsContainerView.leadingAnchor),
            targetSegmentedControl.trailingAnchor.constraint(equalTo: filterControlsContainerView.trailingAnchor),

            intensityRowView.topAnchor.constraint(equalTo: targetSegmentedControl.bottomAnchor, constant: .su),
            intensityRowView.leadingAnchor.constraint(equalTo: filterControlsContainerView.leadingAnchor),
            intensityRowView.trailingAnchor.constraint(equalTo: filterControlsContainerView.trailingAnchor),
            intensityRowView.bottomAnchor.constraint(equalTo: filterControlsContainerView.bottomAnchor),

            strengthLabel.leadingAnchor.constraint(equalTo: intensityRowView.leadingAnchor),
            strengthLabel.centerYAnchor.constraint(equalTo: intensityRowView.centerYAnchor),

            intensityPercentLabel.trailingAnchor.constraint(equalTo: intensityRowView.trailingAnchor),
            intensityPercentLabel.centerYAnchor.constraint(equalTo: intensityRowView.centerYAnchor),
            intensityPercentLabel.widthAnchor.constraint(equalToConstant: 40),

            intensitySlider.leadingAnchor.constraint(equalTo: strengthLabel.trailingAnchor, constant: .su),
            intensitySlider.trailingAnchor.constraint(equalTo: intensityPercentLabel.leadingAnchor, constant: -.su),
            intensitySlider.centerYAnchor.constraint(equalTo: intensityRowView.centerYAnchor),
            intensitySlider.topAnchor.constraint(equalTo: intensityRowView.topAnchor),
            intensitySlider.bottomAnchor.constraint(equalTo: intensityRowView.bottomAnchor),
        ])
    }

    private func setupSidebarChrome() {
        sidebarTitleLabel.text = NSLocalizedString(
            "Styles",
            comment: "Filter styles panel title"
        ).localizedLowercase

        view.addSubview(sidebarHeaderView)
        sidebarHeaderView.addSubview(sidebarTitleLabel)
        sidebarHeaderView.addSubview(sidebarDoneButton)
        view.addSubview(sidebarSeparator)

        NSLayoutConstraint.activate([
            sidebarHeaderView.topAnchor.constraint(equalTo: view.topAnchor),
            sidebarHeaderView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sidebarHeaderView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sidebarHeaderView.heightAnchor.constraint(equalToConstant: 44),

            sidebarTitleLabel.leadingAnchor.constraint(equalTo: sidebarHeaderView.leadingAnchor, constant: .su2),
            sidebarTitleLabel.centerYAnchor.constraint(equalTo: sidebarHeaderView.centerYAnchor),
            sidebarTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: sidebarDoneButton.leadingAnchor, constant: -.su),

            sidebarDoneButton.trailingAnchor.constraint(equalTo: sidebarHeaderView.trailingAnchor, constant: -.su2),
            sidebarDoneButton.centerYAnchor.constraint(equalTo: sidebarHeaderView.centerYAnchor),

            sidebarSeparator.topAnchor.constraint(equalTo: sidebarHeaderView.bottomAnchor),
            sidebarSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sidebarSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sidebarSeparator.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }

    @objc private func sidebarDoneTapped() {
        onDone?()
    }

    @objc private func targetSegmentChanged(_ sender: UISegmentedControl) {
        let target: FilterPresetTarget
        switch sender.selectedSegmentIndex {
        case 0: target = .main
        case 1: target = .background
        default: target = .both
        }
        selectedTarget = target
        guard selectedPresetID != nil else { return }
        delegate?.filterStylesViewController(self, didChangeTarget: target)
    }

    @objc private func intensitySliderChanged(_ sender: UISlider) {
        let value = CGFloat(sender.value)
        selectedIntensity = value
        intensityPercentLabel.text = "\(Int(value * 100))%"
        guard selectedPresetID != nil else { return }
        delegate?.filterStylesViewController(self, didChangeIntensity: value)
    }

    @objc private func intensitySliderTouchDown(_ sender: UISlider) {
        delegate?.filterStylesViewControllerWillBeginIntensityDrag(self)
    }

    @objc private func intensitySliderDidEnd(_ sender: UISlider) {
        delegate?.filterStylesViewControllerDidEndIntensityDrag(self)
    }

    private func handlePresetSelected(_ preset: FilterPreset) {
        selectedPresetID = preset.id
        pickerView.updateSelection(selectedPresetID: preset.id)
        intensitySlider.isEnabled = true

        if preset.id == "none", settingsManager.eli5Mode {
            showNoneELI5Toast()
        }

        delegate?.filterStylesViewController(self, didSelect: preset)
    }

    private func handlePresetDeselected() {
        selectedPresetID = nil
        pickerView.updateSelection(selectedPresetID: nil)
        intensitySlider.isEnabled = false
        delegate?.filterStylesViewControllerDidDeselectStyle(self)
    }

    private func showNoneELI5Toast() {
        guard let window = view.window ?? view.superview?.window else { return }
        let message = ELI5Descriptions.forFilterPresetNone()
        ToastView.show(message: message, icon: "info.circle", in: window, duration: 5.0)
    }
}
