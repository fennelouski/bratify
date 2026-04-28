import UIKit

class ViewController: UIViewController {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    internal let settingsManager = SettingsManager()
    internal let imageService = ImageService()
    
    var designs: [Design] = []
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

        // If there are no designs, show the edit view controller for creating a new design
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.designs.isEmpty {
                self.addNewDesign()
            }
        }
        

        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: DispatchWorkItem(block: { [weak self] in
            guard let self else {
                return
            }
            
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
                        id: design.id
                    )
                    DesignManager.shared.addDesign(updatedDesign)
                    updatedDesign.generateImage(with: imageService, callback: { [weak collectionView] _, _ in
                        collectionView?.reloadItems(at: [indexPath])
                    })
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: DispatchWorkItem(block: { [weak self] in
                self?.designs = DesignManager.shared.getAllDesigns()
                self?.collectionView.reloadData()
            }))
        }))

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        apply(settingsManager.selectedTheme)
        designs = DesignManager.shared.getAllDesigns()
        collectionView.reloadData()
        
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
        designs = DesignManager.shared.loadDesigns()
        collectionView.reloadData()
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
            DesignManager.shared.deleteDesign(design)
            designs.remove(at: indexPath.item)
            collectionView.deleteItems(at: [indexPath])
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
