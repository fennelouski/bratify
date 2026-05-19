//
//  FilterStylesViewController.swift
//  brat
//

import UIKit

protocol FilterStylesViewControllerDelegate: AnyObject {
    func filterStylesViewController(_ controller: FilterStylesViewController, didSelect preset: FilterPreset)
}

/// Preset-only panel for filter looks (embeddable in sidebar or popover).
final class FilterStylesViewController: UIViewController {

    weak var delegate: FilterStylesViewControllerDelegate?

    var onDone: (() -> Void)?

    private let settingsManager: SettingsManager
    private var selectedPresetID: String?

    private let showsSidebarChrome: Bool

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
        view.addSubview(pickerView)
        reloadSelection(selectedPresetID: selectedPresetID)

        let topAnchor: NSLayoutYAxisAnchor
        if showsSidebarChrome {
            topAnchor = sidebarSeparator.bottomAnchor
        } else {
            topAnchor = view.safeAreaLayoutGuide.topAnchor
        }

        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: topAnchor, constant: showsSidebarChrome ? .su2 : 16),
            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadSelection(selectedPresetID: selectedPresetID)
    }

    func reloadSelection(selectedPresetID: String?) {
        self.selectedPresetID = selectedPresetID
        pickerView.configure(
            theme: settingsManager.selectedTheme,
            selectedPresetID: selectedPresetID
        )
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

    private func handlePresetSelected(_ preset: FilterPreset) {
        selectedPresetID = preset.id
        pickerView.updateSelection(selectedPresetID: preset.id)

        if preset.id == "none", settingsManager.eli5Mode {
            showNoneELI5Toast()
        }

        delegate?.filterStylesViewController(self, didSelect: preset)
    }

    private func showNoneELI5Toast() {
        guard let window = view.window ?? view.superview?.window else { return }
        let message = ELI5Descriptions.forFilterPresetNone()
        ToastView.show(message: message, icon: "info.circle", in: window, duration: 5.0)
    }
}
