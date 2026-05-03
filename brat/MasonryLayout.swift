import UIKit

protocol MasonryLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, aspectRatioForItemAt indexPath: IndexPath) -> CGFloat
}

class MasonryLayout: UICollectionViewLayout {
    weak var delegate: MasonryLayoutDelegate?
    var numberOfColumns: Int = 2
    var cellPadding: CGFloat = 5

    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0

    private var contentWidth: CGFloat {
        guard let collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - insets.left - insets.right
    }

    override var collectionViewContentSize: CGSize {
        CGSize(width: contentWidth, height: contentHeight)
    }

    override func prepare() {
        guard cache.isEmpty, let collectionView else { return }

        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        let xOffsets: [CGFloat] = (0..<numberOfColumns).map { CGFloat($0) * columnWidth }
        var yOffsets: [CGFloat] = [CGFloat](repeating: 0, count: numberOfColumns)

        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let aspectRatio = delegate?.collectionView(collectionView, aspectRatioForItemAt: indexPath) ?? 1.0

            let shortestColumn = yOffsets.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            let innerWidth = columnWidth - cellPadding * 2
            let imageHeight = innerWidth / aspectRatio
            let labelHeight = innerWidth * 0.25
            let height = imageHeight + labelHeight + cellPadding * 2

            let frame = CGRect(
                x: xOffsets[shortestColumn] + cellPadding,
                y: yOffsets[shortestColumn] + cellPadding,
                width: innerWidth,
                height: height
            )
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)

            contentHeight = max(contentHeight, frame.maxY + cellPadding)
            yOffsets[shortestColumn] = frame.maxY + cellPadding
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        cache.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard indexPath.item < cache.count else { return nil }
        return cache[indexPath.item]
    }

    override func invalidateLayout() {
        super.invalidateLayout()
        cache.removeAll()
        contentHeight = 0
    }
}
