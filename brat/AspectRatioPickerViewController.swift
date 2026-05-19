import UIKit

protocol AspectRatioPickerDelegate: AnyObject {
    func didSelectAspectRatio(width: Int, height: Int)
}

class AspectRatioPickerViewController: UIViewController {

    enum PresentationStyle {
        case navigation
        case sidebar
    }

    enum Section: Int, CaseIterable {
        case nativeImage
        case social
        case standard

        var titleKey: String {
            switch self {
            case .nativeImage:
                return "Your image"
            case .social:
                return "Social platforms"
            case .standard:
                return "Common ratios"
            }
        }
    }

    private let settingsManager: SettingsManager
    weak var delegate: AspectRatioPickerDelegate?

    var presentationStyle: PresentationStyle = .navigation
    var onDone: (() -> Void)?
    var nativeImageAspectSize: (width: Int, height: Int)?
    var selectedCanvasSize: CGSize?

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
            NSLocalizedString("Done", comment: "Dismiss aspect ratio sidebar").localizedLowercase,
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

    private var collectionViewTopConstraint: NSLayoutConstraint?

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private var visibleSections: [Section] {
        var sections: [Section] = []
        if nativeImageAspectSize != nil {
            sections.append(.nativeImage)
        }
        sections.append(.social)
        sections.append(.standard)
        return sections
    }

    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadNativeImageSection(nativeImageAspectSize: (width: Int, height: Int)?) {
        self.nativeImageAspectSize = nativeImageAspectSize
        collectionView.reloadData()
    }

    @objc private func sidebarDoneTapped() {
        onDone?()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSidebarChromeIfNeeded()
        setupCollectionView()
        apply(settingsManager.selectedTheme)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        apply(settingsManager.selectedTheme)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        apply(settingsManager.selectedTheme)
    }

    private func setupSidebarChromeIfNeeded() {
        guard presentationStyle == .sidebar else { return }

        view.addSubview(sidebarHeaderView)
        sidebarHeaderView.addSubview(sidebarTitleLabel)
        sidebarHeaderView.addSubview(sidebarDoneButton)
        view.addSubview(sidebarSeparator)

        sidebarTitleLabel.text = NSLocalizedString(
            "Aspect Ratio",
            comment: "Title for aspect ratio sidebar"
        ).localizedLowercase

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

    private func setupCollectionView() {
        let title = NSLocalizedString("Select Aspect Ratio", comment: "Title for aspect ratio picker").localizedLowercase
        navigationItem.title = title

        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AspectRatioCell.self, forCellWithReuseIdentifier: AspectRatioCell.reuseIdentifier)
        collectionView.register(
            AspectRatioSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: AspectRatioSectionHeaderView.reuseIdentifier
        )

        if presentationStyle == .sidebar {
            collectionViewTopConstraint = collectionView.topAnchor.constraint(equalTo: sidebarSeparator.bottomAnchor)
        } else {
            collectionViewTopConstraint = collectionView.topAnchor.constraint(equalTo: view.topAnchor)
        }

        NSLayoutConstraint.activate([
            collectionViewTopConstraint!,
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { _, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.5),
                heightDimension: .absolute(118)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(118)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = .su
            section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: .su, bottom: .su, trailing: .su)

            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(28)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            return section
        }
    }

    private func section(at index: Int) -> Section {
        visibleSections[index]
    }

    private func presets(for section: Section) -> [AspectRatioPreset] {
        switch section {
        case .nativeImage:
            return []
        case .social:
            return AspectRatioPreset.socialPresets
        case .standard:
            return AspectRatioPreset.standardPresets
        }
    }

    private func isSelected(width: Int, height: Int) -> Bool {
        guard let selectedCanvasSize else { return false }
        return CanvasDimensions.matchesRatio(
            canvasWidth: selectedCanvasSize.width,
            canvasHeight: selectedCanvasSize.height,
            presetWidth: width,
            presetHeight: height
        )
    }

    private func selectionTint() -> UIColor {
        guard let theme = settingsManager.selectedTheme else { return .tintColor }
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        let colorModel = isDarkMode ? theme.darkModeColors : theme.lightModeColors
        return colorModel.tintColor
    }

    private func selectAspectRatio(width: Int, height: Int) {
        delegate?.didSelectAspectRatio(width: width, height: height)
        selectedCanvasSize = CGSize(
            width: CanvasDimensions.pixelSize(forAspectWidth: width, height: height).width,
            height: CanvasDimensions.pixelSize(forAspectWidth: width, height: height).height
        )
        collectionView.reloadData()

        if presentationStyle == .navigation {
            navigationController?.popViewController(animated: true)
        }
    }
}

extension AspectRatioPickerViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleSections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionKind = self.section(at: section)
        switch sectionKind {
        case .nativeImage:
            return nativeImageAspectSize != nil ? 1 : 0
        case .social, .standard:
            return presets(for: sectionKind).count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: AspectRatioCell.reuseIdentifier,
            for: indexPath
        ) as! AspectRatioCell

        let sectionKind = section(at: indexPath.section)
        let tint = selectionTint()

        switch sectionKind {
        case .nativeImage:
            guard let native = nativeImageAspectSize else { return cell }
            let simplified = CanvasDimensions.simplifiedRatio(width: native.width, height: native.height)
            let title = NSLocalizedString("Your image", comment: "Native image aspect ratio preset title")
            cell.configure(
                title: title,
                ratioWidth: simplified.0,
                ratioHeight: simplified.1,
                showsImageBadge: true,
                isSelected: isSelected(width: native.width, height: native.height),
                selectionTint: tint
            )
            cell.accessibilityLabel = NSLocalizedString(
                "Match image aspect ratio",
                comment: "Accessibility label for native image aspect ratio preset"
            )
        case .social, .standard:
            let preset = presets(for: sectionKind)[indexPath.item]
            cell.configure(
                preset: preset,
                isSelected: isSelected(width: preset.width, height: preset.height),
                selectionTint: tint
            )
            cell.accessibilityLabel = "\(preset.localizedTitle), \(preset.ratioLabel)"
        }

        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: AspectRatioSectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as! AspectRatioSectionHeaderView
        let sectionKind = section(at: indexPath.section)
        header.configure(title: NSLocalizedString(sectionKind.titleKey, comment: "Aspect ratio section header"))
        return header
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionKind = section(at: indexPath.section)

        switch sectionKind {
        case .nativeImage:
            guard let native = nativeImageAspectSize else { return }
            selectAspectRatio(width: native.width, height: native.height)
        case .social, .standard:
            let preset = presets(for: sectionKind)[indexPath.item]
            selectAspectRatio(width: preset.width, height: preset.height)
        }
    }
}

private final class AspectRatioSectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "AspectRatioSectionHeaderView"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .su),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.su),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String) {
        titleLabel.text = title.localizedUppercase
    }
}
