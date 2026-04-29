import UIKit

final class ToastView: UIView {
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .white
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private init(message: String, icon: String = "exclamationmark.triangle.fill") {
        super.init(frame: .zero)
        backgroundColor = UIColor.black.withAlphaComponent(0.80)
        layer.cornerRadius = 12
        layer.masksToBounds = true
        iconImageView.image = UIImage(systemName: icon)
        messageLabel.text = message

        let stack = UIStackView(arrangedSubviews: [iconImageView, messageLabel])
        stack.axis = .horizontal
        stack.spacing = .su
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),
            stack.topAnchor.constraint(equalTo: topAnchor, constant: .su),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.su),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .su2),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.su2),
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    static func show(message: String, icon: String = "exclamationmark.triangle.fill", in view: UIView, duration: TimeInterval = 3.0) {
        let toast = ToastView(message: message, icon: icon)
        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.alpha = 0
        view.addSubview(toast)

        let topConstraint = toast.topAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: -80
        )
        NSLayoutConstraint.activate([
            topConstraint,
            toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toast.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.9),
        ])
        view.layoutIfNeeded()

        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.72,
                       initialSpringVelocity: 0.5, options: [.curveEaseOut]) {
            topConstraint.constant = .su2
            toast.alpha = 1
            view.layoutIfNeeded()
        } completion: { _ in
            UIView.animate(withDuration: 0.25, delay: duration, options: [.curveEaseIn]) {
                topConstraint.constant = -80
                toast.alpha = 0
                view.layoutIfNeeded()
            } completion: { _ in
                toast.removeFromSuperview()
            }
        }
    }
}
