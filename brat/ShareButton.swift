import UIKit

class ShareBarButtonItem: UIBarButtonItem {

    init(target: AnyObject?, action: Selector?) {
        super.init()
        let shareImage = UIImage(systemName: "square.and.arrow.up.circle.fill")
        self.image = shareImage
        self.style = .plain
        self.target = target
        self.action = action
        self.tintColor = .systemBlue
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        let shareImage = UIImage(systemName: "square.and.arrow.up.circle.fill")
        self.image = shareImage
        self.style = .plain
        self.tintColor = .systemBlue
    }
}

extension UIBarButtonItem {
    static func share(_ action: @escaping ()->Void) -> UIBarButtonItem {
        let button = UIBarButtonItem(
            systemItem: .action,
            primaryAction: UIAction(handler: { _ in
                action()
            }),
            menu: nil
        )
        return button
    }
}
