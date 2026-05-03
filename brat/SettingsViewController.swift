import UIKit

class SettingsViewController: UITableViewController {

    private let settingsManager: SettingsManager

    private enum CategorySection: Int, CaseIterable {
        case appearance
        case typography
        case canvas
        case behavior
        case gallery

        var displayName: String {
            switch self {
            case .appearance: return NSLocalizedString("Appearance", comment: "Settings category for visual appearance.").localizedLowercase
            case .typography: return NSLocalizedString("Typography", comment: "Settings category for font and text.").localizedLowercase
            case .canvas:     return NSLocalizedString("Canvas", comment: "Settings category for canvas and output.").localizedLowercase
            case .behavior:   return NSLocalizedString("Behavior", comment: "Settings category for app behavior.").localizedLowercase
            case .gallery:    return NSLocalizedString("Gallery", comment: "Settings category for gallery options.").localizedLowercase
            }
        }

        var items: [SettingItem] {
            switch self {
            case .appearance: return [.themeSelection, .defaultTextColor, .defaultBackgroundColor]
            case .typography: return [.preferredFontName, .preferredFontSize]
            case .canvas:     return [.aspectRatio, .pixelationScale, .extendedRange]
            case .behavior:   return [.autocorrectionEnabled, .forceLowercase, .saveWithoutTitle, .confirmBeforeDeleting, .showLabels, .eli5Mode]
            case .gallery:    return [.gallerySortOrder, .galleryLayout, .galleryLabel, .doubleTapToShare]
            }
        }
    }

    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Settings", comment: "The name of the settings menu.").localizedLowercase
        navigationItem.largeTitleDisplayMode = .always
        apply(settingsManager.selectedTheme)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        apply(settingsManager.selectedTheme)
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        apply(settingsManager.selectedTheme)
    }

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(
                title: NSLocalizedString("Close", comment: "Title for close key command"),
                action: #selector(close),
                input: UIKeyCommand.inputEscape,
                modifierFlags: [.shift],
                propertyList: nil
            )
        ]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return CategorySection.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let category = CategorySection(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell")
            ?? UITableViewCell(style: .value1, reuseIdentifier: "CategoryCell")
        cell.textLabel?.text = category.displayName
        cell.detailTextLabel?.text = subtitle(for: category)
        cell.accessoryType = .disclosureIndicator
        cell.apply(settingsManager.selectedTheme)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let category = CategorySection(rawValue: indexPath.section) else { return }
        let vc: UIViewController
        if category == .typography {
            vc = TypographyViewController(settingsManager: settingsManager)
        } else {
            vc = SettingsCategoryViewController(
                title: category.displayName,
                items: category.items,
                settingsManager: settingsManager
            )
        }
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    @objc private func close() {
        dismiss()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        apply(settingsManager.selectedTheme)
        tableView.reloadData()
    }

    // MARK: - Subtitles

    private func subtitle(for category: CategorySection) -> String {
        switch category {
        case .appearance:
            return settingsManager.selectedTheme?.name ?? NSLocalizedString("default", comment: "Default theme subtitle.")
        case .typography:
            let size = Int(settingsManager.preferredFontSize)
            return "\(settingsManager.preferredFontName) · \(size)"
        case .canvas:
            let x = min(Int(settingsManager.xDimension), 40)
            let y = min(Int(settingsManager.yDimension), 40)
            let scale = Int(settingsManager.pixelationScale)
            return "\(x):\(y) · \(scale)px"
        case .behavior:
            var active: [String] = []
            if settingsManager.autocorrectionEnabled { active.append(NSLocalizedString("autocorrect", comment: "Short label for autocorrection.")) }
            if settingsManager.forceLowercase { active.append(NSLocalizedString("lowercase", comment: "Short label for force lowercase.")) }
            if settingsManager.saveWithoutTitle { active.append(NSLocalizedString("no title", comment: "Short label for save without title.")) }
            if !settingsManager.confirmBeforeDeleting { active.append(NSLocalizedString("no confirm", comment: "Short label for skip delete confirmation.")) }
            if settingsManager.showLabels { active.append(NSLocalizedString("labels", comment: "Short label for show labels.")) }
            if settingsManager.eli5Mode { active.append(NSLocalizedString("eli5", comment: "Short label for eli5 mode.")) }
            return active.isEmpty ? NSLocalizedString("default", comment: "Default behavior subtitle.") : active.joined(separator: ", ")
        case .gallery:
            var parts = [settingsManager.gallerySortOrder.displayName.localizedLowercase,
                         settingsManager.galleryLayout.displayName.localizedLowercase,
                         settingsManager.galleryLabel.displayName.localizedLowercase]
            if settingsManager.doubleTapToShare { parts.append(NSLocalizedString("share", comment: "Short label indicating double-tap-to-share is on.")) }
            return parts.joined(separator: " · ")
        }
    }
}
