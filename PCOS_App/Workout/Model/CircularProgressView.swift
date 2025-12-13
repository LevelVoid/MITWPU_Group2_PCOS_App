//
//  CircularProgressView.swift
//  PCOS_App
//
//  Created by SDC-USER on 11/12/25.
//
import UIKit

class CircularProgressView: UIView {

    private let backgroundLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()

    var progressColor: UIColor = .systemOrange {
        didSet { progressLayer.strokeColor = progressColor.cgColor }
    }

    var trackColor: UIColor = UIColor.systemGray5 {
        didSet { backgroundLayer.strokeColor = trackColor.cgColor }
    }

    var lineWidth: CGFloat = 6 {
        didSet {
            backgroundLayer.lineWidth = lineWidth
            progressLayer.lineWidth = lineWidth
            setNeedsLayout()
        }
    }

    // 0.0 → 1.0
    var progress: CGFloat = 0 {
        didSet { animateProgress() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    private func setupLayers() {
        backgroundColor = .clear

        // Background circle
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = trackColor.cgColor
        backgroundLayer.lineWidth = lineWidth
        backgroundLayer.lineCap = .round
        layer.addSublayer(backgroundLayer)

        // Foreground/progress circle
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = lineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        let centerPoint = CGPoint(x: bounds.midX, y: bounds.midY)

        let circlePath = UIBezierPath(
            arcCenter: centerPoint,
            radius: radius,
            startAngle: -.pi / 2,
            endAngle: 1.5 * .pi,
            clockwise: true
        )

        backgroundLayer.path = circlePath.cgPath
        progressLayer.path = circlePath.cgPath
    }

    private func animateProgress() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = progress
        animation.duration = 0.5
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false

        progressLayer.strokeEnd = progress
        progressLayer.add(animation, forKey: "progressAnimation")
    }
}

