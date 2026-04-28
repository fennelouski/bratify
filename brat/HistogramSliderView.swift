//
//  HistogramSliderView.swift
//  Speed Reader
//
//  Created by Nathan Fennel on 5/15/24.
//

import UIKit

class HistogramSliderView: UIControl {
    private var wordData: [(word: String, whitespaceCount: Int, nonLetterCount: Int)] = []
    private var histogramLayers: [CALayer] = []
    private let controlImageView: UIImageView
    private var isLTR: Bool = true
    private let middleLineLayer = CALayer()
    
    var positiveColor: UIColor = .systemBlue {
        didSet { setNeedsLayout() }
    }
    
    var negativeColor: UIColor = .systemRed {
        didSet { setNeedsLayout() }
    }
    
    var deselectedColor: UIColor = .systemGray {
        didSet { setNeedsLayout() }
    }
    
    var positiveAlpha: CGFloat = 1.0 {
        didSet { setNeedsLayout() }
    }
    
    var negativeAlpha: CGFloat = 1.0 {
        didSet { setNeedsLayout() }
    }
    
    var controlAlpha: CGFloat = 1.0 {
        didSet { controlImageView.alpha = controlAlpha }
    }
    
    var middleLineAlpha: CGFloat = 1.0 {
        didSet { middleLineLayer.opacity = Float(middleLineAlpha) }
    }
    
    var minimumValue: Float = 0 {
        didSet { setNeedsLayout() }
    }
    
    var maximumValue: Float = 1 {
        didSet { setNeedsLayout() }
    }
    
    private var _value: Float = 0
    private(set) var value: Float {
        get { _value }
        set { setValue(newValue, animated: true, allowUpdate: true) }
    }
    
    var isContinuous: Bool = true
    
    init(frame: CGRect = .zero, image: UIImage?) {
        if let image {
            controlImageView = UIImageView(image: image)
        } else {
            controlImageView = UIImageView(image: UIImage(systemName: "circle.fill"))
        }
        super.init(frame: frame)
        setupView()
    }

    init(frame: CGRect = .zero, controlImageName: String? = nil) {
        if let imageName = controlImageName,
           let image = UIImage(systemName: imageName) {
            controlImageView = UIImageView(image: image)
        } else {
            controlImageView = UIImageView(image: UIImage(systemName: "circle.fill"))
        }
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        controlImageView = UIImageView(image: UIImage(systemName: "circle.fill"))
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        middleLineLayer.backgroundColor = deselectedColor.cgColor
        middleLineLayer.opacity = Float(middleLineAlpha)
        layer.addSublayer(middleLineLayer)
        
        controlImageView.contentMode = .scaleAspectFit
        controlImageView.isUserInteractionEnabled = true
        controlImageView.tintColor = tintColor
        controlImageView.alpha = controlAlpha
        controlImageView.layer.zPosition = 1
        addSubview(controlImageView)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        controlImageView.addGestureRecognizer(panGesture)
        
        addParallaxEffect()
    }
    
    func setValue(_ value: Float, animated: Bool, allowUpdate: Bool) {
        _value = min(max(value, minimumValue), maximumValue)
        updateControlPosition(animated: animated)
        guard allowUpdate else {
            return
        }
        sendActions(for: .valueChanged)
    }
    
    func updateWords(_ text: String) {
        let words = text.split(separator: " ")
        wordData = words.map { word in
            let whitespaceCount = word.filter { $0.isWhitespace }.count
            let nonLetterCount = word.filter { !$0.isLetter }.count
            return (String(word), whitespaceCount, nonLetterCount)
        }
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        isLTR = UIView.userInterfaceLayoutDirection(for: self.semanticContentAttribute) == .leftToRight
        clearHistogram()
        
        middleLineLayer.frame = CGRect(x: 0, y: bounds.midY - 0.5, width: bounds.width, height: 1)
        
        if wordData.isEmpty || wordData.count == 1 {
            drawSineWaves()
        } else {
            drawHistogram()
        }
        updateControlPosition(animated: true)
    }
    
    private func clearHistogram() {
        histogramLayers.forEach { $0.removeFromSuperlayer() }
        histogramLayers.removeAll()
    }
    
    private func drawSineWaves() {
        let path = UIBezierPath()
        let amplitude: CGFloat = 10
        let frequency: CGFloat = 0.1
        for x in stride(from: 0, to: bounds.width, by: 1) {
            let y = bounds.midY + amplitude * sin(frequency * x)
            if x == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        let sineWaveLayer = CAShapeLayer()
        sineWaveLayer.path = path.cgPath
        sineWaveLayer.strokeColor = positiveColor.withAlphaComponent(positiveAlpha).cgColor
        sineWaveLayer.fillColor = UIColor.clear.cgColor
        sineWaveLayer.lineWidth = 2
        
        let sineWaveLayer2 = CAShapeLayer()
        sineWaveLayer2.path = path.cgPath
        sineWaveLayer2.strokeColor = negativeColor.withAlphaComponent(negativeAlpha).cgColor
        sineWaveLayer2.fillColor = UIColor.clear.cgColor
        sineWaveLayer2.lineWidth = 2
        sineWaveLayer2.frame = sineWaveLayer.frame.offsetBy(dx: 0, dy: 20)
        
        layer.addSublayer(sineWaveLayer)
        layer.addSublayer(sineWaveLayer2)
        
        histogramLayers.append(sineWaveLayer)
        histogramLayers.append(sineWaveLayer2)
    }
    
    private func drawHistogram() {
        let widthPerWord = bounds.width / CGFloat(wordData.count)
        let midY = bounds.midY

        let path = UIBezierPath()
        let lowerPath = UIBezierPath()

        for (index, wordInfo) in wordData.enumerated() {
            let wordLength = CGFloat(wordInfo.word.count)
            let whitespaceCount = CGFloat(wordInfo.whitespaceCount)
            let nonLetterCount = CGFloat(wordInfo.nonLetterCount)

            let upperHeight = sqrt(wordLength) * max(bounds.height * 0.05, 1)
            let lowerHeight = sqrt(whitespaceCount + nonLetterCount) * max(bounds.height * 0.05, 1)

            let xPosition = isLTR ? CGFloat(index) * widthPerWord : bounds.width - CGFloat(index + 1) * widthPerWord

//            let yStart = midY - upperHeight
//            let yEnd = midY + lowerHeight

            let averagedHeight = (upperHeight + lowerHeight) / 2
            let smoothedHeight = (upperHeight + lowerHeight + averagedHeight) / 3

            let upperX = xPosition + widthPerWord / 2
            let upperY = midY - smoothedHeight
            let lowerX = xPosition + widthPerWord / 2
            let lowerY = midY + (upperHeight - smoothedHeight)

            if index == 0 {
                path.move(to: CGPoint(x: upperX, y: upperY))
                lowerPath.move(to: CGPoint(x: lowerX, y: lowerY))
            } else {
                path.addLine(to: CGPoint(x: upperX, y: upperY))
                lowerPath.addLine(to: CGPoint(x: lowerX, y: lowerY))
            }
        }

        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillColor = UIColor.clear.cgColor
        fillLayer.strokeColor = positiveColor.withAlphaComponent(positiveAlpha).cgColor
        fillLayer.lineWidth = widthPerWord

        let lowerFillLayer = CAShapeLayer()
        lowerFillLayer.path = lowerPath.cgPath
        lowerFillLayer.fillColor = UIColor.clear.cgColor
        lowerFillLayer.strokeColor = negativeColor.withAlphaComponent(negativeAlpha).cgColor
        lowerFillLayer.lineWidth = widthPerWord

        layer.addSublayer(fillLayer)
        layer.addSublayer(lowerFillLayer)

        histogramLayers.append(fillLayer)
        histogramLayers.append(lowerFillLayer)
    }

    private func updateControlPosition(animated: Bool) {
        let totalRange = CGFloat(maximumValue - minimumValue)
        let relativeValue = CGFloat(CGFloat(value - minimumValue) / totalRange)
        let xPosition = relativeValue * bounds.width
        let animation = { [weak self] in
            guard let self else {
                return
            }
            controlImageView.center = CGPoint(x: xPosition, y: bounds.midY)
        }
        if animated {
            UIView.animate(
                withDuration: 0.5,
                delay: 0,
                options: .allowUserInteraction,
                animations: animation
            )
        } else {
            animation()
        }
        
        drawHistogram()
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        let relativeLocation = isLTR ? location.x / bounds.width : 1 - location.x / bounds.width
        let newValue = Float(relativeLocation) * (maximumValue - minimumValue) + minimumValue
        setValue(newValue, animated: false, allowUpdate: true)
        
        if isContinuous {
            sendActions(for: .valueChanged)
        } else if gesture.state == .ended {
            sendActions(for: .valueChanged)
        }
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        controlImageView.tintColor = tintColor
    }
    
    private func addParallaxEffect() {
        guard !UIAccessibility.isReduceMotionEnabled else { return }
        
        let amount = 10
        let horizontalEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontalEffect.minimumRelativeValue = -amount
        horizontalEffect.maximumRelativeValue = amount
        
        let verticalEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        verticalEffect.minimumRelativeValue = -amount
        verticalEffect.maximumRelativeValue = amount
        
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontalEffect, verticalEffect]
        
        addMotionEffect(group)
    }
}
