import UIKit

class TypographyViewController: UIViewController {

    private let settingsManager: SettingsManager

    private let previewContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 0.5
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()

    private let previewLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.1
        label.numberOfLines = 1
        return label
    }()

    private let topSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        return view
    }()

    private let stepperRow: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let fontSizeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("Font Size", comment: "A label for the control that allows the user to change the size of text being shown.").localizedLowercase
        return label
    }()

    private var stepper: CustomStepperProtocol!

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        return label
    }()

    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = NSLocalizedString("Typography", comment: "Settings category for font and text.").localizedLowercase
        navigationItem.largeTitleDisplayMode = .always
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupPreview()
        setupStepperRow()
        updatePreview()
        apply(settingsManager.selectedTheme)

        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: TypographyViewController, _: UITraitCollection) in
            self.previewContainerView.layer.borderColor = UIColor.separator.cgColor
            self.apply(self.settingsManager.selectedTheme)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        apply(settingsManager.selectedTheme)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        apply(settingsManager.selectedTheme)
    }

    private func setupPreview() {
        view.addSubview(previewContainerView)
        previewContainerView.addSubview(previewLabel)

        let tap = UITapGestureRecognizer(target: self, action: #selector(previewTapped))
        previewContainerView.addGestureRecognizer(tap)

        NSLayoutConstraint.activate([
            previewContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            previewContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            previewContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            previewLabel.topAnchor.constraint(equalTo: previewContainerView.topAnchor, constant: 8),
            previewLabel.leadingAnchor.constraint(equalTo: previewContainerView.leadingAnchor, constant: 8),
            previewLabel.trailingAnchor.constraint(equalTo: previewContainerView.trailingAnchor, constant: -8),
            previewLabel.bottomAnchor.constraint(equalTo: previewContainerView.bottomAnchor, constant: -8),
        ])
    }

    private func setupStepperRow() {
        view.addSubview(topSeparator)
        view.addSubview(stepperRow)

        NSLayoutConstraint.activate([
            stepperRow.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stepperRow.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stepperRow.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stepperRow.heightAnchor.constraint(equalToConstant: 44),

            topSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            topSeparator.bottomAnchor.constraint(equalTo: stepperRow.topAnchor),

            previewContainerView.bottomAnchor.constraint(equalTo: topSeparator.topAnchor, constant: -16),
        ])

        let currentValue = settingsManager.preferredFontSize

        if traitCollection.userInterfaceIdiom == .mac {
            stepper = CustomStepper(
                value: currentValue,
                minimumValue: 12,
                maximumValue: 500,
                stepValue: currentValue > 40 ? currentValue * 0.1 : 1
            ) { [weak self] value in
                guard let self else { return }
                updateFontSize(value)
            }
        } else {
            let uiStepper = UIStepper()
            uiStepper.minimumValue = 12
            uiStepper.maximumValue = 500
            uiStepper.stepValue = currentValue > 40 ? currentValue * 0.1 : 1
            uiStepper.value = currentValue
            uiStepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
            stepper = uiStepper
        }
        stepper.translatesAutoresizingMaskIntoConstraints = false

        stepperRow.addSubview(fontSizeLabel)
        stepperRow.addSubview(stepper)
        stepperRow.addSubview(valueLabel)

        NSLayoutConstraint.activate([
            fontSizeLabel.leadingAnchor.constraint(equalTo: stepperRow.leadingAnchor, constant: .su),
            fontSizeLabel.centerYAnchor.constraint(equalTo: stepperRow.centerYAnchor),

            stepper.leadingAnchor.constraint(equalTo: fontSizeLabel.trailingAnchor, constant: .su),
            stepper.centerYAnchor.constraint(equalTo: stepperRow.centerYAnchor),
            stepper.heightAnchor.constraint(greaterThanOrEqualToConstant: .su5),
            stepper.widthAnchor.constraint(equalToConstant: .su15),

            valueLabel.leadingAnchor.constraint(equalTo: stepper.trailingAnchor, constant: .su),
            valueLabel.trailingAnchor.constraint(equalTo: stepperRow.trailingAnchor, constant: -.su),
            valueLabel.centerYAnchor.constraint(equalTo: stepperRow.centerYAnchor),
        ])

        valueLabel.text = "\(Int(currentValue))".localizedLowercase
    }

    private func updatePreview() {
        let fontName = settingsManager.preferredFontName
        let fontSize = settingsManager.preferredFontSize
        previewLabel.text = fontName.localizedLowercase
        previewLabel.font = UIFont(name: fontName, size: fontSize)
    }

    private func updateFontSize(_ value: Double) {
        settingsManager.preferredFontSize = value
        valueLabel.text = "\(Int(value))".localizedLowercase
        stepper.stepValue = value > 40 ? value * 0.1 : 1
        previewLabel.font = UIFont(name: settingsManager.preferredFontName, size: value)
    }

    @objc private func stepperChanged() {
        updateFontSize(stepper.value)
    }

    @objc private func previewTapped() {
        let fontVC = FontsViewController(settingsManager: settingsManager) { [weak self] fontName in
            guard let self else { return }
            settingsManager.preferredFontName = fontName
            updatePreview()
        }
        present(fontVC)
    }

}
