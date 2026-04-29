import UIKit

class ViewController: UIViewController {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    internal let settingsManager = SettingsManager()
    internal let imageService = ImageService()

    var designs: [Design] = [] {
        didSet { updateEmptyState() }
    }

    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true

        let iconView = UIImageView(image: UIImage(systemName: "rectangle.stack.badge.plus"))
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = .secondaryLabel
        iconView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("empty_state_title", comment: "Empty state heading when no designs exist")
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label

        let subtitleLabel = UILabel()
        subtitleLabel.text = NSLocalizedString("empty_state_subtitle", comment: "Empty state body text")
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        let button = UIButton(type: .system)
        button.setTitle(NSLocalizedString("create_first_design", comment: "CTA button on the empty state screen"), for: .normal)
        button.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.backgroundColor = .label
        button.setTitleColor(.systemBackground, for: .normal)
        button.layer.cornerRadius = 14
        button.contentEdgeInsets = UIEdgeInsets(top: .su, left: .su4, bottom: .su, right: .su4)
        button.addTarget(nil, action: #selector(ViewController.addNewDesign), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel, subtitleLabel, button])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = .su2
        stack.setCustomSpacing(.su4, after: subtitleLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            iconView.widthAnchor.constraint(equalToConstant: 64),
            iconView.heightAnchor.constraint(equalToConstant: 64),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: .su4),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -.su4),
        ])
        return view
    }()

    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInsetReference = .fromSafeArea
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(DesignCell.self, forCellWithReuseIdentifier: "DesignCell")
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString(
            "designs",
            comment: "Title for the main screen that shows designs"
        ).localizedLowercase
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewDesign))
        navigationItem.leftBarButtonItem = .settings(self)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)
        var contentInset = view.safeAreaInsets
        #if targetEnvironment(macCatalyst)
        contentInset.top += 20
        contentInset.left += 20
        contentInset.bottom += 20
        contentInset.right += 20
        #endif
        collectionView.contentInset = contentInset
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .su2),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.su2),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        view.addSubview(emptyStateView)
        NSLayoutConstraint.activate([
            emptyStateView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        
        // Add long press gesture recognizer to collection view
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
        
        loadDesigns()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDesignSaveFailed),
            name: .designSaveFailed,
            object: nil
        )

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        apply(settingsManager.selectedTheme)
        designs = sorted(DesignManager.shared.getAllDesigns())
        collectionView.reloadData()
        updateEmptyState()
        
        for indexPath in collectionView.indexPathsForVisibleItems {
            if designs.indices.contains(indexPath.row) {
                let design = designs[indexPath.row]
                let updatedDesign = Design(
                    text: design.text,
                    backgroundColor: design.backgroundColor,
                    creationDate: design.creationDate,
                    fontName: design.fontName,
                    fontSize: design.fontSize,
                    pixelationScale: design.pixelationScale + .random(in: -0.00001...0.00001),
                    stretch: design.stretch,
                    blur: design.blur,
                    id: design.id
                )
                DesignManager.shared.addDesign(updatedDesign)
                updatedDesign.generateImage(with: imageService, callback: { [weak collectionView] _, _ in
                    collectionView?.reloadItems(at: [indexPath])
                })
            }
        }
    }

    @objc func addNewDesign() {
        let newDesign: Design = .empty
        let newDesignVC = EditDesignViewController(
            originalText: newDesign.text,
            originalBackgroundColor: newDesign.backgroundColor,
            design: newDesign,
            settingsManager: settingsManager,
            imageService: imageService
        )
        navigationController?.pushViewController(newDesignVC, animated: true)
    }
    
    private func loadDesigns() {
        designs = sorted(DesignManager.shared.loadDesigns())
        collectionView.reloadData()
    }

    private func updateEmptyState() {
        emptyStateView.isHidden = !designs.isEmpty
    }

    func sorted(_ designs: [Design]) -> [Design] {
        switch settingsManager.gallerySortOrder {
        case .newestFirst:
            return designs.sorted { $0.creationDate > $1.creationDate }
        case .oldestFirst:
            return designs.sorted { $0.creationDate < $1.creationDate }
        case .lastModified:
            return designs.sorted { $0.modifiedDate > $1.modifiedDate }
        }
    }

    @objc private func handleDesignSaveFailed() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            ToastView.show(
                message: NSLocalizedString(
                    "failed_to_save_design",
                    comment: "Toast shown when a design fails to save to disk"
                ),
                in: view
            )
        }
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let point = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }
        let design = designs[indexPath.item]

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("duplicate", comment: "Action to duplicate a design"),
            style: .default
        ) { [weak self] _ in
            guard let self else { return }
            let duplicate = DesignManager.shared.duplicateDesign(design)
            let newIndex = indexPath.item + 1
            designs.insert(duplicate, at: newIndex)
            collectionView.insertItems(at: [IndexPath(item: newIndex, section: 0)])
        })

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("delete", comment: "Action to delete a design"),
            style: .destructive
        ) { [weak self] _ in
            guard let self else { return }
            self.confirmDeleteDesign(design, at: indexPath)
        })

        alert.addAction(UIAlertAction(
            title: NSLocalizedString("cancel", comment: "Cancel action"),
            style: .cancel
        ))

        if let popover = alert.popoverPresentationController,
           let cell = collectionView.cellForItem(at: indexPath) {
            popover.sourceView = cell
            popover.sourceRect = cell.bounds
        }

        present(alert, animated: true)
    }

    private func confirmDeleteDesign(_ design: Design, at indexPath: IndexPath) {
        let confirmation = UIAlertController(
            title: NSLocalizedString("delete_design_title", comment: "Title of the delete confirmation alert"),
            message: NSLocalizedString("delete_design_message", comment: "Body of the delete confirmation alert"),
            preferredStyle: .alert
        )
        confirmation.addAction(UIAlertAction(
            title: NSLocalizedString("delete", comment: "Action to delete a design"),
            style: .destructive
        ) { [weak self] _ in
            guard let self else { return }
            DesignManager.shared.deleteDesign(design)
            designs.remove(at: indexPath.item)
            collectionView.deleteItems(at: [indexPath])
        })
        confirmation.addAction(UIAlertAction(
            title: NSLocalizedString("cancel", comment: "Cancel action"),
            style: .cancel
        ))
        present(confirmation, animated: true)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return designs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DesignCell", for: indexPath) as! DesignCell
        let design = designs[indexPath.item]
        cell.configure(with: design, imageService: imageService)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let maxColumnWidth: CGFloat = 240
        let screenWidth = collectionView.bounds.width - 40
        let columns: CGFloat = floor(screenWidth / maxColumnWidth) + 1
        let cellWidth = min(maxColumnWidth, screenWidth / columns)
        
        // Randomize the size but keep it consistent for each position
        let randomOffset = CGFloat((indexPath.item % 20))
        let width = cellWidth + randomOffset
        let height = cellWidth + randomOffset
        return CGSize(width: width, height: height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        let selectedDesign = designs[indexPath.item]
        let editDesignVC = EditDesignViewController(
            originalText: selectedDesign.text,
            originalBackgroundColor: selectedDesign.backgroundColor,
            design: selectedDesign,
            settingsManager: settingsManager,
            imageService: imageService
        )
        navigationController?.pushViewController(editDesignVC, animated: true)
    }
}

extension ViewController: SettingsReferenceable {
    
}
