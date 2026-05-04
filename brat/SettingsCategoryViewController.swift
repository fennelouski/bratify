import UIKit

enum SettingItem: Equatable {
    case preferredFontSize
    case preferredFontName
    case themeSelection
    case pixelationScale
    case extendedRange
    case aspectRatio
    case autocorrectionEnabled
    case forceLowercase
    case saveWithoutTitle
    case confirmBeforeDeleting
    case showLabels
    case eli5Mode
    case gallerySortOrder
    case galleryLayout
    case galleryLabel
    case doubleTapToShare
    case defaultTextColor
    case defaultBackgroundColor
    case themingEnabled
}

class SettingsCategoryViewController: UITableViewController {

    private let items: [SettingItem]
    private let settingsManager: SettingsManager

    private enum ActiveColorPicker {
        case textColor, backgroundColor
    }
    private var activeColorPicker: ActiveColorPicker?

    init(title: String, items: [SettingItem], settingsManager: SettingsManager) {
        self.items = items
        self.settingsManager = settingsManager
        super.init(nibName: nil, bundle: nil)
        navigationItem.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(SliderTableViewCell.self, forCellReuseIdentifier: "SliderTableViewCell")
        tableView.register(StepperTableViewCell.self, forCellReuseIdentifier: "StepperTableViewCell")
        tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: "TextFieldTableViewCell")
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: "SwitchTableViewCell")
        tableView.register(ThemeTableViewCell.self, forCellReuseIdentifier: "ThemeTableViewCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.section]

        switch item {
        case .preferredFontSize:
            let cell = tableView.dequeueReusableCell(withIdentifier: "StepperTableViewCell", for: indexPath) as! StepperTableViewCell
            cell.configure(
                text: NSLocalizedString("Font Size", comment: "A label for the control that allows the user to change the size of text being shown."),
                with: settingsManager.preferredFontSize,
                min: 12,
                max: 500,
                step: 0.1,
                theme: settingsManager.selectedTheme
            )
            cell.valueChanged = { [weak self] newValue in
                guard let self, settingsManager.preferredFontSize != newValue else { return }
                settingsManager.preferredFontSize = newValue
                if let idx = items.firstIndex(of: .preferredFontName) {
                    tableView.reloadRows(at: [IndexPath(row: 0, section: idx)], with: .automatic)
                }
            }
            return cell

        case .preferredFontName:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextFieldTableViewCell", for: indexPath) as! TextFieldTableViewCell
            cell.configure(
                text: settingsManager.preferredFontName,
                font: UIFont(name: settingsManager.preferredFontName, size: settingsManager.preferredFontSize),
                theme: settingsManager.selectedTheme
            )
            cell.textFieldTapped = { [weak self] in
                self?.showFontPicker {
                    if #available(iOS 15.0, *) {
                        self?.tableView.reconfigureRows(at: [indexPath])
                    } else {
                        self?.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
            }
            return cell

        case .themeSelection:
            if let selectedTheme = settingsManager.selectedTheme {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeTableViewCell", for: indexPath) as! ThemeTableViewCell
                cell.configure(with: selectedTheme)
                cell.apply(settingsManager.selectedTheme)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
                cell.textLabel?.text = NSLocalizedString("Theme Selection", comment: "A label for the control that allows the user to select a theme.").localizedLowercase
                cell.detailTextLabel?.text = settingsManager.selectedTheme?.name ?? NSLocalizedString("Default", comment: "Default theme name.").localizedLowercase
                cell.accessoryType = .disclosureIndicator
                cell.apply(settingsManager.selectedTheme)
                return cell
            }

        case .pixelationScale:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SliderTableViewCell", for: indexPath) as! SliderTableViewCell
            cell.configure(
                text: NSLocalizedString("Pixelation Scale", comment: "A label for the control that allows the user to change the scale of the pixelation effect."),
                with: Float(settingsManager.pixelationScale),
                min: 1,
                max: settingsManager.extendedRange ? 100 : 20,
                mode: .integer,
                thumbImage: .Large.rectangleCheckered,
                theme: settingsManager.selectedTheme,
                showInfoButton: settingsManager.eli5Mode
            )
            cell.valueChanged = { [weak self] newValue in
                self?.settingsManager.pixelationScale = Double(newValue)
            }
            cell.infoButtonTapped = { [weak self] in self?.showELI5Toast(for: item) }
            return cell

        case .extendedRange:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(
                text: NSLocalizedString("Extended Range", comment: "Toggle to expand slider ranges for more creative control.").localizedLowercase,
                isOn: settingsManager.extendedRange,
                theme: settingsManager.selectedTheme,
                showInfoButton: settingsManager.eli5Mode
            )
            cell.valueChanged = { [weak self] newValue in
                guard let self else { return }
                settingsManager.extendedRange = newValue
                if let idx = items.firstIndex(of: .pixelationScale) {
                    tableView.reloadRows(at: [IndexPath(row: 0, section: idx)], with: .automatic)
                }
            }
            cell.infoButtonTapped = { [weak self] in self?.showELI5Toast(for: item) }
            return cell

        case .themingEnabled:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(
                text: NSLocalizedString("theming", comment: "Toggle to apply the selected color theme across the app's interface.").localizedLowercase,
                isOn: settingsManager.themingEnabled,
                theme: settingsManager.selectedTheme,
                showInfoButton: settingsManager.eli5Mode
            )
            cell.valueChanged = { [weak self] newValue in
                guard let self else { return }
                settingsManager.themingEnabled = newValue
                tableView.reloadData()
                apply(settingsManager.selectedTheme)
            }
            cell.infoButtonTapped = { [weak self] in self?.showELI5Toast(for: item) }
            return cell

        case .aspectRatio:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            let xDimension = min(Int(settingsManager.xDimension), 40)
            let yDimension = min(Int(settingsManager.yDimension), 40)
            cell.textLabel?.text = NSLocalizedString("Aspect Ratio", comment: "A label for the control that allows the user to select the aspect ratio.").localizedLowercase
            cell.detailTextLabel?.text = "\(xDimension):\(yDimension)"
            cell.accessoryType = .disclosureIndicator
            cell.apply(settingsManager.selectedTheme)
            return cell

        case .autocorrectionEnabled:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(
                text: NSLocalizedString("Autocorrection Enabled", comment: "A label for the control that allows the user to automatically save on paste.").localizedLowercase,
                isOn: settingsManager.autocorrectionEnabled,
                theme: settingsManager.selectedTheme,
                showInfoButton: settingsManager.eli5Mode
            )
            cell.valueChanged = { [weak self] newValue in
                self?.settingsManager.autocorrectionEnabled = newValue
            }
            cell.infoButtonTapped = { [weak self] in self?.showELI5Toast(for: item) }
            return cell

        case .forceLowercase:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(
                text: NSLocalizedString("Force Lowercase", comment: "A label for the control that forces text to lowercase.").localizedLowercase,
                isOn: settingsManager.forceLowercase,
                theme: settingsManager.selectedTheme,
                showInfoButton: settingsManager.eli5Mode
            )
            cell.valueChanged = { [weak self] newValue in
                self?.settingsManager.forceLowercase = newValue
            }
            cell.infoButtonTapped = { [weak self] in self?.showELI5Toast(for: item) }
            return cell

        case .saveWithoutTitle:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(
                text: NSLocalizedString("Save Without Title", comment: "A label for the control that allows the user to save without a title."),
                isOn: settingsManager.saveWithoutTitle,
                theme: settingsManager.selectedTheme,
                showInfoButton: settingsManager.eli5Mode
            )
            cell.valueChanged = { [weak self] newValue in
                self?.settingsManager.saveWithoutTitle = newValue
            }
            cell.infoButtonTapped = { [weak self] in self?.showELI5Toast(for: item) }
            return cell

        case .confirmBeforeDeleting:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(
                text: NSLocalizedString("Confirm Before Deleting", comment: "A label for the toggle that requires a confirmation dialog before deleting a design.").localizedLowercase,
                isOn: settingsManager.confirmBeforeDeleting,
                theme: settingsManager.selectedTheme,
                showInfoButton: settingsManager.eli5Mode
            )
            cell.valueChanged = { [weak self] newValue in
                self?.settingsManager.confirmBeforeDeleting = newValue
            }
            cell.infoButtonTapped = { [weak self] in self?.showELI5Toast(for: item) }
            return cell

        case .showLabels:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(
                text: NSLocalizedString("Show Labels", comment: "A label for the control that shows labels for the user if they prefer.").localizedLowercase,
                isOn: settingsManager.showLabels,
                theme: settingsManager.selectedTheme,
                showInfoButton: settingsManager.eli5Mode
            )
            cell.valueChanged = { [weak self] newValue in
                self?.settingsManager.showLabels = newValue
            }
            cell.infoButtonTapped = { [weak self] in self?.showELI5Toast(for: item) }
            return cell

        case .eli5Mode:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(
                text: NSLocalizedString("eli5 mode", comment: "A label for the toggle that enables ELI5 (explain like I'm 5) info buttons on all controls."),
                isOn: settingsManager.eli5Mode,
                theme: settingsManager.selectedTheme,
                showInfoButton: settingsManager.eli5Mode
            )
            cell.valueChanged = { [weak self] newValue in
                guard let self else { return }
                settingsManager.eli5Mode = newValue
                tableView.reloadData()
            }
            cell.infoButtonTapped = { [weak self] in self?.showELI5Toast(for: item) }
            return cell

        case .gallerySortOrder:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("Sort Order", comment: "A label for the control that sets gallery sort order.").localizedLowercase
            cell.detailTextLabel?.text = settingsManager.gallerySortOrder.displayName.localizedLowercase
            cell.accessoryType = .disclosureIndicator
            cell.apply(settingsManager.selectedTheme)
            return cell

        case .galleryLayout:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("Layout", comment: "A label for the control that sets gallery layout style.").localizedLowercase
            cell.detailTextLabel?.text = settingsManager.galleryLayout.displayName.localizedLowercase
            cell.accessoryType = .disclosureIndicator
            cell.apply(settingsManager.selectedTheme)
            return cell

        case .galleryLabel:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("Cell Label", comment: "A label for the control that sets what text appears below each gallery thumbnail.").localizedLowercase
            cell.detailTextLabel?.text = settingsManager.galleryLabel.displayName.localizedLowercase
            cell.accessoryType = .disclosureIndicator
            cell.apply(settingsManager.selectedTheme)
            return cell

        case .doubleTapToShare:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchTableViewCell", for: indexPath) as! SwitchTableViewCell
            cell.configure(
                text: NSLocalizedString("Double Tap to Share", comment: "A label for the toggle that enables double-tap on a gallery item to share it.").localizedLowercase,
                isOn: settingsManager.doubleTapToShare,
                theme: settingsManager.selectedTheme,
                showInfoButton: settingsManager.eli5Mode
            )
            cell.valueChanged = { [weak self] newValue in
                self?.settingsManager.doubleTapToShare = newValue
            }
            cell.infoButtonTapped = { [weak self] in self?.showELI5Toast(for: item) }
            return cell

        case .defaultTextColor:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("Default Text Color", comment: "A label for the control that sets the default text color.").localizedLowercase
            cell.detailTextLabel?.text = nil
            cell.accessoryView = colorSwatch(for: UIColor(hexString: settingsManager.textColorHex))
            cell.apply(settingsManager.selectedTheme)
            return cell

        case .defaultBackgroundColor:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DefaultCell", for: indexPath)
            cell.textLabel?.text = NSLocalizedString("Default Background Color", comment: "A label for the control that sets the default background color.").localizedLowercase
            cell.detailTextLabel?.text = nil
            cell.accessoryView = colorSwatch(for: UIColor(hexString: settingsManager.backgroundColorHex))
            cell.apply(settingsManager.selectedTheme)
            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.section]

        switch item {
        case .themeSelection:
            let themePickerVC = ColorThemePickerViewController(settingsManager: settingsManager) { [weak self] selectedTheme in
                self?.settingsManager.selectedTheme = selectedTheme
                UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseInOut) {
                    self?.apply(selectedTheme)
                } completion: { _ in
                    self?.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
            navigationController?.pushViewController(themePickerVC, animated: true)

        case .aspectRatio:
            let aspectRatioPickerVC = AspectRatioPickerViewController(settingsManager: settingsManager)
            aspectRatioPickerVC.delegate = self
            navigationController?.pushViewController(aspectRatioPickerVC, animated: true)

        case .gallerySortOrder:
            showSortOrderPicker(at: indexPath)

        case .galleryLayout:
            showLayoutPicker(at: indexPath)

        case .galleryLabel:
            showLabelPicker(at: indexPath)

        case .defaultTextColor:
            activeColorPicker = .textColor
            let initial = UIColor(hexString: settingsManager.textColorHex)
            showColorPicker(initialColor: initial, at: indexPath)

        case .defaultBackgroundColor:
            activeColorPicker = .backgroundColor
            let initial = UIColor(hexString: settingsManager.backgroundColorHex)
            showColorPicker(initialColor: initial, at: indexPath)

        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func showELI5Toast(for item: SettingItem) {
        let desc = ELI5Descriptions.forSetting(item)
        ToastView.show(message: desc, icon: "info.circle", in: view, duration: 5.0)
    }

    private func colorSwatch(for color: UIColor) -> UIView {
        let swatch = UIView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        swatch.backgroundColor = color
        swatch.layer.cornerRadius = 6
        swatch.layer.borderWidth = 1
        swatch.layer.borderColor = UIColor.separator.cgColor
        return swatch
    }

    private func showFontPicker(_ completion: @escaping () -> Void) {
        let fontViewController = FontsViewController(settingsManager: settingsManager) { [weak self] fontName in
            guard let self else { return }
            settingsManager.preferredFontName = fontName
            completion()
        }
        present(fontViewController)
    }

    private func showSortOrderPicker(at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: NSLocalizedString("Sort Order", comment: "Title for sort order picker"),
            message: nil,
            preferredStyle: .actionSheet
        )
        for order in GallerySortOrder.allCases {
            let isCurrent = settingsManager.gallerySortOrder == order
            let title = isCurrent ? "✓ \(order.displayName)" : order.displayName
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                guard let self else { return }
                settingsManager.gallerySortOrder = order
                tableView.reloadRows(at: [indexPath], with: .automatic)
            })
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel))
        if let popover = alert.popoverPresentationController, let cell = tableView.cellForRow(at: indexPath) {
            popover.sourceView = cell
            popover.sourceRect = cell.bounds
        }
        present(alert, animated: true)
    }

    private func showLayoutPicker(at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: NSLocalizedString("Layout", comment: "Title for layout picker"),
            message: nil,
            preferredStyle: .actionSheet
        )
        for layout in GalleryLayout.allCases {
            let isCurrent = settingsManager.galleryLayout == layout
            let title = isCurrent ? "✓ \(layout.displayName)" : layout.displayName
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                guard let self else { return }
                settingsManager.galleryLayout = layout
                tableView.reloadRows(at: [indexPath], with: .automatic)
            })
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel))
        if let popover = alert.popoverPresentationController, let cell = tableView.cellForRow(at: indexPath) {
            popover.sourceView = cell
            popover.sourceRect = cell.bounds
        }
        present(alert, animated: true)
    }

    private func showLabelPicker(at indexPath: IndexPath) {
        let alert = UIAlertController(
            title: NSLocalizedString("Cell Label", comment: "Title for cell label picker"),
            message: nil,
            preferredStyle: .actionSheet
        )
        for label in GalleryLabel.allCases {
            let isCurrent = settingsManager.galleryLabel == label
            let title = isCurrent ? "✓ \(label.displayName)" : label.displayName
            alert.addAction(UIAlertAction(title: title, style: .default) { [weak self] _ in
                guard let self else { return }
                settingsManager.galleryLabel = label
                tableView.reloadRows(at: [indexPath], with: .automatic)
            })
        }
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel action"), style: .cancel))
        if let popover = alert.popoverPresentationController, let cell = tableView.cellForRow(at: indexPath) {
            popover.sourceView = cell
            popover.sourceRect = cell.bounds
        }
        present(alert, animated: true)
    }

    private func showColorPicker(initialColor: UIColor, at indexPath: IndexPath) {
        let colorPicker = UIColorPickerViewController()
        colorPicker.selectedColor = initialColor
        colorPicker.delegate = self
        present(colorPicker, animated: true)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        apply(settingsManager.selectedTheme)
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: DispatchWorkItem(block: { [weak self] in
            guard let self else { return }
            apply(settingsManager.selectedTheme)
            if let idx = items.firstIndex(of: .themeSelection) {
                tableView.reloadSections(IndexSet(integer: idx), with: .fade)
            }
        }))
    }
}

extension SettingsCategoryViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        applySelectedColor(viewController.selectedColor)
    }

    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        applySelectedColor(viewController.selectedColor)
        activeColorPicker = nil
    }

    private func applySelectedColor(_ color: UIColor) {
        switch activeColorPicker {
        case .textColor:
            settingsManager.textColorHex = color.toHexString()
            if let idx = items.firstIndex(of: .defaultTextColor) {
                tableView.reloadRows(at: [IndexPath(row: 0, section: idx)], with: .none)
            }
        case .backgroundColor:
            settingsManager.backgroundColorHex = color.toHexString()
            if let idx = items.firstIndex(of: .defaultBackgroundColor) {
                tableView.reloadRows(at: [IndexPath(row: 0, section: idx)], with: .none)
            }
        case nil:
            break
        }
    }
}

extension SettingsCategoryViewController: AspectRatioPickerDelegate {
    func didSelectAspectRatio(width: Int, height: Int) {
        let maxDimension: CGFloat = 512.0
        let maxPixels: CGFloat = 500_000.0

        var newWidth = CGFloat(width)
        var newHeight = CGFloat(height)

        if newWidth > maxDimension || newHeight > maxDimension || (newWidth * newHeight > maxPixels) {
            let aspectRatio = newWidth / newHeight
            if newWidth > newHeight {
                newWidth = min(maxDimension, sqrt(maxPixels * aspectRatio))
                newHeight = newWidth / aspectRatio
            } else {
                newHeight = min(maxDimension, sqrt(maxPixels / aspectRatio))
                newWidth = newHeight * aspectRatio
            }
        }

        settingsManager.setCanvasDimensions(width: newWidth, height: newHeight)

        if let idx = items.firstIndex(of: .aspectRatio) {
            tableView.reloadRows(at: [IndexPath(row: 0, section: idx)], with: .automatic)
        }
    }
}

enum ELI5Descriptions {
    static func forSetting(_ item: SettingItem) -> String {
        switch item {
        case .eli5Mode:
            return "adds a ⓘ button to every control so you can tap it to learn what it does"
        case .autocorrectionEnabled:
            return "when on, your phone tries to fix spelling mistakes as you type"
        case .forceLowercase:
            return "when on, all text you type is automatically made lowercase — perfect for that brat aesthetic"
        case .saveWithoutTitle:
            return "when on, designs save without asking you to name them first"
        case .confirmBeforeDeleting:
            return "when on, the app asks 'are you sure?' before deleting a design so you don't lose it by accident"
        case .showLabels:
            return "when on, shows text labels next to the sliders so you can see what each one does"
        case .extendedRange:
            return "unlocks extra-wide ranges for sliders so you can push effects further than normal"
        case .pixelationScale:
            return "sets how big each 'pixel' looks in the pixelation effect — bigger number means chunkier pixels"
        case .preferredFontSize:
            return "sets how big your text starts out when you create a new design"
        case .preferredFontName:
            return "the font your text uses — tap to browse and pick one you like"
        case .themeSelection:
            return "the color scheme for the whole app — changes button colors, backgrounds, and text"
        case .aspectRatio:
            return "the shape of your canvas — like 1:1 for square (instagram), 9:16 for tall (stories), or 16:9 for wide (youtube)"
        case .gallerySortOrder:
            return "controls which designs appear first in your gallery — newest, oldest, or most recently edited"
        case .galleryLayout:
            return "grid lines everything up in equal squares; masonry stacks designs in columns at their natural proportions, like Pinterest"
        case .galleryLabel:
            return "time shows when each design was created; title shows the text of the design instead"
        case .doubleTapToShare:
            return "when on, double-tapping a design in the gallery opens the share sheet so you can send it without opening it first"
        case .defaultTextColor:
            return "the color your text starts out as when you create a new design"
        case .defaultBackgroundColor:
            return "the background color your canvas starts out as when you create a new design"
        case .themingEnabled:
            return "when on, the app uses your chosen theme colors; when off, it sticks with the system look"
        }
    }

    static func forDesignControl(_ label: String) -> String {
        switch label.lowercased() {
        case "brightness":
            return "makes the image lighter (right) or darker (left)"
        case "contrast":
            return "increases the difference between light and dark — high contrast looks more dramatic"
        case "saturation":
            return "cranks up colors (right) or drains them toward gray (left)"
        case "exposure":
            return "like opening or closing a camera shutter — right makes the whole image brighter, left makes it darker"
        case "gamma":
            return "adjusts the midtone brightness without blowing out highlights or crushing shadows"
        case "sepia":
            return "adds a warm brown vintage filter, like an old photograph"
        case "pixelate":
            return "breaks the image into visible square blocks — higher means chunkier pixels"
        case "sharpen":
            return "makes edges and details look crisper and more defined"
        case "monochrome":
            return "converts the image to black and white — all the way right is fully grayscale"
        case "vignette":
            return "darkens the corners and edges of the image, drawing focus to the center"
        case "invert":
            return "flips every color to its opposite — like a photo negative"
        case "background scale":
            return "zooms the background image in or out to fill or fit the canvas"
        case "background blur":
            return "blurs the background image — useful for making your text pop in front"
        case "background alpha":
            return "controls how see-through the background image is — lower means more transparent"
        case "background brightness":
            return "makes the background image lighter or darker"
        case "background contrast":
            return "increases or decreases light/dark difference in the background"
        case "background saturation":
            return "cranks up or drains the colors in the background image"
        case "background exposure":
            return "adjusts the overall brightness of the background like a camera exposure"
        case "background gamma":
            return "adjusts the midtones of the background image"
        case "background sepia":
            return "adds a vintage warm-brown tint to the background image"
        case "background pixelate":
            return "breaks the background into visible square blocks"
        case "background sharpen":
            return "makes the background image look crisper and more defined"
        case "background monochrome":
            return "converts the background image to black and white"
        case "background vignette":
            return "darkens the corners of the background image"
        case "background flip horizontal":
            return "mirrors the background image left-to-right"
        case "background flip vertical":
            return "flips the background image upside-down"
        case "background invert":
            return "flips every color in the background image to its opposite"
        case "font size":
            return "makes your text bigger or smaller"
        case "pixelation":
            return "adds a chunky pixel effect to your text — higher means more blocky"
        case "stretch":
            return "squishes or stretches your text horizontally — right makes it wide, left makes it narrow"
        case "blur":
            return "makes your text blurry — useful for a dreamy or out-of-focus look"
        default:
            return "adjusts \(label.lowercased())"
        }
    }
}
