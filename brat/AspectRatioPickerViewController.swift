import UIKit

protocol AspectRatioPickerDelegate: AnyObject {
    func didSelectAspectRatio(width: Int, height: Int)
}

class AspectRatioPickerViewController: UIViewController {
    
    private let settingsManager: SettingsManager
    weak var delegate: AspectRatioPickerDelegate?
    
    private let aspectRatios: [(width: Int, height: Int)] = [(9, 21), (9, 16), (3, 4), (1, 1), (4, 3), (16, 9), (21, 9)]
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = .su
        layout.minimumLineSpacing = .su
        layout.sectionInset = UIEdgeInsets(top: .su, left: .su, bottom: .su, right: .su)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    init(settingsManager: SettingsManager) {
        self.settingsManager = settingsManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
    
    private func setupView() {
        navigationItem.title = NSLocalizedString("Select Aspect Ratio", comment: "Title for aspect ratio picker").localizedLowercase
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(AspectRatioCell.self, forCellWithReuseIdentifier: AspectRatioCell.reuseIdentifier)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        apply(settingsManager.selectedTheme)
    }
}

extension AspectRatioPickerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return aspectRatios.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AspectRatioCell.reuseIdentifier, for: indexPath) as! AspectRatioCell
        let aspectRatio = aspectRatios[indexPath.row]
        cell.configure(with: aspectRatio.width, height: aspectRatio.height)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAspectRatio = aspectRatios[indexPath.row]
        delegate?.didSelectAspectRatio(width: selectedAspectRatio.width, height: selectedAspectRatio.height)
        navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 10
        let collectionViewSize = collectionView.frame.size.width - padding
        let itemSize = collectionViewSize / 2 - padding
        return CGSize(width: itemSize, height: itemSize)
    }
}
