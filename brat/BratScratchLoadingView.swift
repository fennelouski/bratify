import UIKit

final class BratScratchLoadingView: UIView {

    private let lineCount = 22
    private var lineLayers: [CAShapeLayer] = []
    private(set) var isAnimating = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        isHidden = true
        alpha = 0
    }

    required init?(coder: NSCoder) { fatalError() }

    func startAnimating() {
        guard !isAnimating else { return }
        isAnimating = true
        isHidden = false
        buildAndAnimate()
        UIView.animate(withDuration: 0.25) { self.alpha = 1 }
    }

    func stopAnimating(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard isAnimating else {
            completion?()
            return
        }
        isAnimating = false
        let cleanup = { [weak self] in
            self?.lineLayers.forEach { $0.removeFromSuperlayer() }
            self?.lineLayers.removeAll()
            self?.isHidden = true
            completion?()
        }
        if animated {
            UIView.animate(withDuration: 0.2, animations: { self.alpha = 0 }) { _ in cleanup() }
        } else {
            alpha = 0
            cleanup()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if isAnimating { buildAndAnimate() }
    }

    private func buildAndAnimate() {
        lineLayers.forEach { $0.removeFromSuperlayer() }
        lineLayers.removeAll()

        let w = bounds.width
        let h = bounds.height
        guard w > 0, h > 0 else { return }

        let midY = h / 2.0
        let pairCount = lineCount / 2

        let cycleDuration: Double = 3.2
        let drawDuration: Double = 0.15
        let drawStagger: Double = 0.065
        let totalDrawEnd: Double = Double(lineCount - 1) * drawStagger + drawDuration
        let eraseStartBase: Double = totalDrawEnd + 0.2
        let eraseDuration: Double = 0.10
        let eraseStagger: Double = 0.05

        for i in 0..<lineCount {
            let pairIndex = i / 2
            let t: CGFloat = pairCount > 1 ? CGFloat(pairIndex) / CGFloat(pairCount - 1) : 0
            let spread = h * 0.38 * t
            let yOffset = i.isMultiple(of: 2) ? -spread : spread
            let lineY = midY + yOffset

            let waviness = CGFloat(sin(Double(i) * 1.4) * 7.0)
            let endYJitter = CGFloat(cos(Double(i) * 2.6) * 3.0)
            let leftPad = CGFloat(i % 5) * (w * 0.014)
            let rightPad = CGFloat((i + 3) % 5) * (w * 0.014)
            let lineWidth: CGFloat = 0.5 + CGFloat(i % 6) / 5.0 * 1.2

            let path = UIBezierPath()
            path.move(to: CGPoint(x: leftPad, y: lineY))
            path.addQuadCurve(
                to: CGPoint(x: w - rightPad, y: lineY + endYJitter),
                controlPoint: CGPoint(x: w / 2.0, y: lineY + waviness)
            )

            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.strokeColor = UIColor.label.withAlphaComponent(0.72).cgColor
            shapeLayer.lineWidth = lineWidth
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.lineCap = .round
            shapeLayer.strokeEnd = 0
            shapeLayer.strokeStart = 0
            layer.addSublayer(shapeLayer)
            lineLayers.append(shapeLayer)

            let drawStart = Double(i) * drawStagger
            let drawEnd = drawStart + drawDuration
            let eraseStart = eraseStartBase + Double(i) * eraseStagger
            let eraseEnd = eraseStart + eraseDuration

            let strokeEndAnim = CAKeyframeAnimation(keyPath: "strokeEnd")
            strokeEndAnim.values = [0.0, 0.0, 1.0, 1.0]
            strokeEndAnim.keyTimes = [
                0,
                NSNumber(value: drawStart / cycleDuration),
                NSNumber(value: drawEnd / cycleDuration),
                1.0
            ]
            strokeEndAnim.timingFunctions = [
                CAMediaTimingFunction(name: .linear),
                CAMediaTimingFunction(name: .easeOut),
                CAMediaTimingFunction(name: .linear)
            ]
            strokeEndAnim.duration = cycleDuration
            strokeEndAnim.repeatCount = .greatestFiniteMagnitude

            let strokeStartAnim = CAKeyframeAnimation(keyPath: "strokeStart")
            strokeStartAnim.values = [0.0, 0.0, 1.0, 1.0]
            strokeStartAnim.keyTimes = [
                0,
                NSNumber(value: eraseStart / cycleDuration),
                NSNumber(value: eraseEnd / cycleDuration),
                1.0
            ]
            strokeStartAnim.timingFunctions = [
                CAMediaTimingFunction(name: .linear),
                CAMediaTimingFunction(name: .easeIn),
                CAMediaTimingFunction(name: .linear)
            ]
            strokeStartAnim.duration = cycleDuration
            strokeStartAnim.repeatCount = .greatestFiniteMagnitude

            shapeLayer.add(strokeEndAnim, forKey: "bratScratchStrokeEnd")
            shapeLayer.add(strokeStartAnim, forKey: "bratScratchStrokeStart")
        }
    }
}
