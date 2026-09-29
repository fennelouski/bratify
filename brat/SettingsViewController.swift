import UIKit
import SwiftUI

final class SettingsViewController: UIViewController {
    enum PresentationStyle { case navigation, sidebar }
    var presentationStyle: PresentationStyle = .navigation
    var onDone: (() -> Void)?
    private let settingsManager: SettingsManager
    private var hostingController: UIHostingController<BratSettingsView>?

    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Settings", comment: "Settings screen title")
        navigationItem.largeTitleDisplayMode = presentationStyle == .sidebar ? .never : .always
        if presentationStyle == .sidebar {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
        }
        let host = UIHostingController(rootView: settingsView())
        addChild(host)
        view.addSubview(host.view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            host.view.topAnchor.constraint(equalTo: view.topAnchor),
            host.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            host.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        host.didMove(toParent: self)
        hostingController = host
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // The existing font, theme and canvas pickers keep using this same manager.
        hostingController?.rootView = settingsView()
    }

    private func settingsView() -> BratSettingsView {
        BratSettingsView(settings: settingsManager) { [weak self] category in
            guard let self else { return }
            let destination: UIViewController
            if category == .typography {
                destination = TypographyViewController(settingsManager: settingsManager)
            } else {
                destination = SettingsCategoryViewController(title: category.title, items: category.items, settingsManager: settingsManager)
            }
            navigationController?.pushViewController(destination, animated: true)
        }
    }

    override var keyCommands: [UIKeyCommand]? {
        [UIKeyCommand(title: NSLocalizedString("Close", comment: "Close settings"), action: #selector(close), input: UIKeyCommand.inputEscape, modifierFlags: [.shift])]
    }

    @objc private func close() {
        if presentationStyle == .sidebar { onDone?() }
        else if let navigationController, navigationController.viewControllers.first !== self {
            navigationController.popViewController(animated: true)
        } else { dismiss() }
    }
}

private enum SettingsDetail {
    case appearance, typography, canvas
    var title: String {
        switch self {
        case .appearance: return NSLocalizedString("Appearance", comment: "Settings section")
        case .typography: return NSLocalizedString("Typography", comment: "Settings section")
        case .canvas: return NSLocalizedString("Canvas", comment: "Settings section")
        }
    }
    var items: [SettingItem] {
        switch self {
        case .appearance: return [.themingEnabled, .themeSelection, .defaultTextColor, .defaultBackgroundColor]
        case .typography: return [.preferredFontName, .preferredFontSize]
        case .canvas: return [.aspectRatio, .pixelationScale, .extendedRange]
        }
    }
}

private struct BratSettingsView: View {
    let settings: SettingsManager
    let openDetail: (SettingsDetail) -> Void
    // SettingsManager is also used by UIKit; its persisted values remain authoritative.
    @State private var revision = 0
    @State private var confirmsHistoryRemoval = false

    var body: some View {
        let _ = revision
        Form {
            Section("Design Defaults") {
                detail(.appearance, summary: settings.selectedTheme?.name ?? "Default")
                detail(.typography, summary: "\(settings.preferredFontName) · \(Int(settings.preferredFontSize))")
                detail(.canvas, summary: "\(min(Int(settings.xDimension), 40)):\(min(Int(settings.yDimension), 40)) · \(Int(settings.pixelationScale))px")
            }
            Section("Behavior") {
                toggle("Autocorrection Enabled", keyPath: \.autocorrectionEnabled, item: .autocorrectionEnabled)
                toggle("Force Lowercase", keyPath: \.forceLowercase, item: .forceLowercase)
                toggle("Save Without Title", keyPath: \.saveWithoutTitle, item: .saveWithoutTitle)
                toggle("Confirm Before Deleting", keyPath: \.confirmBeforeDeleting, item: .confirmBeforeDeleting)
                toggle("Show Labels", keyPath: \.showLabels, item: .showLabels)
                toggle("ELI5 Mode", keyPath: \.eli5Mode, item: .eli5Mode)
                Stepper("Undo Steps: \(settings.undoStepCount)", value: binding(\.undoStepCount), in: 5...200, step: 5)
                Button("Remove Undo History", role: .destructive) { confirmsHistoryRemoval = true }
            }
            Section("Gallery") {
                Picker("Sort Order", selection: binding(\.gallerySortOrder)) {
                    ForEach(GallerySortOrder.allCases, id: \.self) { Text($0.displayName).tag($0) }
                }
                Picker("Layout", selection: binding(\.galleryLayout)) {
                    ForEach(GalleryLayout.allCases, id: \.self) { Text($0.displayName).tag($0) }
                }
                Picker("Cell Label", selection: binding(\.galleryLabel)) {
                    ForEach(GalleryLabel.allCases, id: \.self) { Text($0.displayName).tag($0) }
                }
                toggle("Double Tap to Share", keyPath: \.doubleTapToShare, item: .doubleTapToShare)
            }
            Section("Help") {
                Link("Privacy Policy", destination: URL(string: "https://nathanfennel.com/bratify/privacy.html")!)
                Link("Contact Support", destination: URL(string: "https://nathanfennel.com/contact")!)
            }
        }
        .tint(accent)
        .alert("Remove Undo History?", isPresented: $confirmsHistoryRemoval) {
            Button("Remove", role: .destructive) { DesignUndoHistoryStore.shared.purgeAll() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete undo history for all designs. Your designs are not affected.")
        }
    }

    private var accent: Color {
        guard settings.themingEnabled, let theme = settings.selectedTheme else { return .accentColor }
        return Color(uiColor: UIColor { traits in
            let colors = traits.userInterfaceStyle == .dark ? theme.darkModeColors : theme.lightModeColors
            return colors.tintColor.readable(on: .systemBackground.resolvedColor(with: traits))
        })
    }

    private func detail(_ category: SettingsDetail, summary: String) -> some View {
        Button { openDetail(category) } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.title).foregroundStyle(.primary)
                    Text(summary).font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.secondary).accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func toggle(_ title: LocalizedStringKey, keyPath: ReferenceWritableKeyPath<SettingsManager, Bool>, item: SettingItem) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(title, isOn: binding(keyPath))
            if settings.eli5Mode {
                Text(ELI5Descriptions.forSetting(item)).font(.footnote).foregroundStyle(.secondary)
            }
        }
    }

    private func binding<Value>(_ keyPath: ReferenceWritableKeyPath<SettingsManager, Value>) -> Binding<Value> {
        Binding(get: { settings[keyPath: keyPath] }, set: {
            settings[keyPath: keyPath] = $0
            revision += 1
        })
    }
}
