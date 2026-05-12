
//
//  WalkthroughOverlayView.swift
//  PCOS_App
//
//  iOS-native TipKit-style walkthrough overlay.
//  • Semi-transparent dim layer with a clear spotlight cutout over the target
//  • Pulsing white beacon dot on the target
//  • Floating white tip card (icon + title + body + close ×) with an arrow
//    pointing toward the target – identical aesthetics to Apple's TipKit
//

import UIKit

// MARK: - Overlay View

final class WalkthroughOverlayView: UIView {

    // MARK: Callbacks
    var onTargetTapped: (() -> Void)?
    var onDismissTapped: (() -> Void)?

    // MARK: Sub-views
    private let tipCard     = UIView()
    private let iconWrap    = UIView()
    private let iconLabel   = UILabel()
    private let titleLabel  = UILabel()
    private let bodyLabel   = UILabel()
    private let closeButton = UIButton(type: .system)
    private let arrowLayer  = CAShapeLayer()
    private let pulseDot    = UIView()
    private let tapIndicator = UIView()   // invisible tap zone over the cutout

    // MARK: State
    private var cutoutFrame: CGRect = .zero
    private var arrowPointsUp = true   // true → arrow at top of card (card below target)

    // MARK: - Factory

    static func install(
        in parent: UIView,
        targetFrame: CGRect,
        message: String,
        iconEmoji: String = "👆",
        tipTitle: String? = nil,
        onTargetTapped: (() -> Void)? = nil,
        onDismissTapped: (() -> Void)? = nil
    ) -> WalkthroughOverlayView {
        let ov = WalkthroughOverlayView(frame: parent.bounds)
        ov.onTargetTapped = onTargetTapped
        ov.onDismissTapped = onDismissTapped
        ov.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parent.addSubview(ov)
        ov.setupContents(targetFrame: targetFrame,
                         message: message,
                         iconEmoji: iconEmoji,
                         tipTitle: tipTitle)
        ov.animateIn()
        return ov
    }

    // MARK: - Setup

    private func setupContents(
        targetFrame: CGRect,
        message: String,
        iconEmoji: String,
        tipTitle: String?
    ) {
        backgroundColor = .clear
        cutoutFrame = targetFrame.insetBy(dx: -8, dy: -8)

        // ── Tap passthrough zone ──────────────────────────────────────────────
        tapIndicator.frame = cutoutFrame
        tapIndicator.backgroundColor = .clear
        addSubview(tapIndicator)
        tapIndicator.isUserInteractionEnabled = true
        tapIndicator.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(cutoutTapped)))

        // ── Pulsing beacon dot ────────────────────────────────────────────────
        let dotSize: CGFloat = 18
        pulseDot.frame = CGRect(
            x: cutoutFrame.midX - dotSize / 2,
            y: cutoutFrame.midY - dotSize / 2,
            width: dotSize, height: dotSize)
        pulseDot.backgroundColor = .white
        pulseDot.layer.cornerRadius = dotSize / 2
        pulseDot.layer.shadowColor  = UIColor(hex: "#FE7A96").cgColor
        pulseDot.layer.shadowOpacity = 0.85
        pulseDot.layer.shadowRadius  = 8
        pulseDot.layer.shadowOffset  = .zero
        addSubview(pulseDot)

        // ── Tip card (TipKit style) ───────────────────────────────────────────
        buildTipCard(message: message, iconEmoji: iconEmoji, tipTitle: tipTitle)
    }

    private func buildTipCard(message: String, iconEmoji: String, tipTitle: String?) {
        // Card
        tipCard.backgroundColor  = .systemBackground
        tipCard.layer.cornerRadius = 14
        tipCard.layer.shadowColor   = UIColor.black.cgColor
        tipCard.layer.shadowOpacity = 0.14
        tipCard.layer.shadowRadius  = 16
        tipCard.layer.shadowOffset  = CGSize(width: 0, height: 4)
        addSubview(tipCard)

        // Icon circle
        iconWrap.backgroundColor    = UIColor(hex: "#FE7A96").withAlphaComponent(0.12)
        iconWrap.layer.cornerRadius = 20
        iconWrap.translatesAutoresizingMaskIntoConstraints = false
        tipCard.addSubview(iconWrap)

        iconLabel.text      = iconEmoji
        iconLabel.font      = .systemFont(ofSize: 22)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconWrap.addSubview(iconLabel)

        // Title (optional – mirrors TipKit bold headline)
        let resolvedTitle = tipTitle ?? "Quick Tip"
        titleLabel.text            = resolvedTitle
        titleLabel.font            = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor       = .label
        titleLabel.numberOfLines   = 1
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tipCard.addSubview(titleLabel)

        // Body
        bodyLabel.text           = message
        bodyLabel.font           = .systemFont(ofSize: 13, weight: .regular)
        bodyLabel.textColor      = .secondaryLabel
        bodyLabel.numberOfLines  = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        tipCard.addSubview(bodyLabel)

        // Close button (×)
        closeButton.setImage(
            UIImage(systemName: "xmark", withConfiguration:
                UIImage.SymbolConfiguration(pointSize: 10, weight: .medium)),
            for: .normal)
        closeButton.tintColor = .tertiaryLabel
        closeButton.backgroundColor = UIColor.secondarySystemFill
        closeButton.layer.cornerRadius = 12
        closeButton.clipsToBounds = true
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        tipCard.addSubview(closeButton)

        // ── Size the card dynamically based on content ────────────────────────
        let maxAllowedWidth = min(bounds.width - 40, 320)
        
        let titleFont = UIFont.systemFont(ofSize: 15, weight: .semibold)
        let bodyFont = UIFont.systemFont(ofSize: 13, weight: .regular)
        
        let titleW = resolvedTitle.size(withAttributes: [.font: titleFont]).width
        let minCardWidthForTitle = titleW + 106 // icon(14+40+10) + title + close(8+24+10)
        
        let maxBodyW = maxAllowedWidth - 78 // icon(14+40+10) + body + pad(14)
        let bodyRect = message.boundingRect(
            with: CGSize(width: maxBodyW, height: .infinity),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: bodyFont],
            context: nil)
            
        let optimalBodyWidth = ceil(bodyRect.width) + 78 + 4 // small buffer
        
        var cardWidth = max(minCardWidthForTitle, optimalBodyWidth)
        cardWidth = min(maxAllowedWidth, cardWidth)
        
        let finalBodyW = cardWidth - 78
        let finalTextH = message.boundingRect(
            with: CGSize(width: finalBodyW, height: .infinity),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: bodyFont],
            context: nil).height
            
        let cardH = max(80, 24 + 40 + 8 + ceil(finalTextH) + 20)
        
        let spaceBelow = bounds.height - cutoutFrame.maxY
        let spaceAbove = cutoutFrame.minY

        let cardX = max(16, min(bounds.width - cardWidth - 16,
                                cutoutFrame.midX - cardWidth / 2))

        let cardY: CGFloat
        if spaceBelow >= cardH + 28 {
            cardY = cutoutFrame.maxY + 16
            arrowPointsUp = true
        } else if spaceAbove >= cardH + 28 {
            cardY = cutoutFrame.minY - cardH - 16
            arrowPointsUp = false
        } else {
            cardY = max(60, cutoutFrame.minY - cardH - 16)
            arrowPointsUp = false
        }
        tipCard.frame = CGRect(x: cardX, y: cardY, width: cardWidth, height: cardH)

        // Arrow (triangle pointing toward target)
        buildArrow()

        // ── Auto-layout inside card ───────────────────────────────────────────
        NSLayoutConstraint.activate([
            iconWrap.leadingAnchor.constraint(equalTo: tipCard.leadingAnchor, constant: 14),
            iconWrap.topAnchor.constraint(equalTo: tipCard.topAnchor, constant: 14),
            iconWrap.widthAnchor.constraint(equalToConstant: 40),
            iconWrap.heightAnchor.constraint(equalToConstant: 40),

            iconLabel.centerXAnchor.constraint(equalTo: iconWrap.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconWrap.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: iconWrap.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: iconWrap.topAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8),

            bodyLabel.leadingAnchor.constraint(equalTo: iconWrap.trailingAnchor, constant: 10),
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            bodyLabel.trailingAnchor.constraint(equalTo: tipCard.trailingAnchor, constant: -14),
            bodyLabel.bottomAnchor.constraint(lessThanOrEqualTo: tipCard.bottomAnchor, constant: -14),

            closeButton.topAnchor.constraint(equalTo: tipCard.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: tipCard.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
        ])
    }

    private func buildArrow() {
        let arrowW: CGFloat = 18
        let arrowH: CGFloat = 10
        // Arrow X tracks the cutout midpoint, clamped inside card
        let arrowMidX = min(max(cutoutFrame.midX, tipCard.frame.minX + 20),
                            tipCard.frame.maxX - 20)
        let arrowX = arrowMidX - arrowW / 2

        let arrowView = UIView(frame: CGRect(
            x: arrowX,
            y: arrowPointsUp ? tipCard.frame.minY - arrowH + 1
                             : tipCard.frame.maxY - 1,
            width: arrowW, height: arrowH))
        arrowView.backgroundColor = .clear

        let path = UIBezierPath()
        if arrowPointsUp {
            // ▲ pointing up (above card, toward target below)
            path.move(to: CGPoint(x: 0, y: arrowH))
            path.addLine(to: CGPoint(x: arrowW / 2, y: 0))
            path.addLine(to: CGPoint(x: arrowW, y: arrowH))
        } else {
            // ▼ pointing down (below card, toward target above)
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: arrowW / 2, y: arrowH))
            path.addLine(to: CGPoint(x: arrowW, y: 0))
        }
        path.close()
        arrowLayer.path      = path.cgPath
        arrowLayer.fillColor = UIColor.systemBackground.cgColor
        arrowView.layer.addSublayer(arrowLayer)
        insertSubview(arrowView, belowSubview: tipCard)
    }

    // MARK: - Draw dim + spotlight cutout

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        ctx.setFillColor(UIColor.black.withAlphaComponent(0.48).cgColor)
        ctx.fill(rect)

        ctx.setBlendMode(.clear)
        let cutoutPath = UIBezierPath(roundedRect: cutoutFrame, cornerRadius: 14)
        ctx.addPath(cutoutPath.cgPath)
        ctx.fillPath()
        ctx.setBlendMode(.normal)
    }

    // MARK: - Animations

    private func animateIn() {
        alpha = 0
        tipCard.transform = CGAffineTransform(scaleX: 0.88, y: 0.88).translatedBy(x: 0, y: -8)
        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.75, initialSpringVelocity: 0.2) {
            self.alpha = 1
            self.tipCard.transform = .identity
        }
        startBeaconPulse()
    }

    private func startBeaconPulse() {
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue  = 0.7
        scale.toValue    = 1.5
        scale.duration   = 0.9
        scale.autoreverses  = true
        scale.repeatCount   = .infinity
        scale.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        pulseDot.layer.add(scale, forKey: "scale")

        let shadow = CABasicAnimation(keyPath: "shadowRadius")
        shadow.fromValue    = 4
        shadow.toValue      = 14
        shadow.duration     = 0.9
        shadow.autoreverses = true
        shadow.repeatCount  = .infinity
        pulseDot.layer.add(shadow, forKey: "shadow")
    }

    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        pulseDot.layer.removeAllAnimations()
        if animated {
            UIView.animate(withDuration: 0.22,
                           animations: { self.alpha = 0 }) { _ in
                self.removeFromSuperview()
                completion?()
            }
        } else {
            removeFromSuperview()
            completion?()
        }
    }

    // MARK: - Hit testing

    @objc private func cutoutTapped() { onTargetTapped?() }

    @objc private func closeButtonTapped() {
        dismiss()
        onDismissTapped?()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if tapIndicator.frame.contains(point) { return tapIndicator }
        if tipCard.frame.contains(point)      { return tipCard.hitTest(convert(point, to: tipCard), with: event) }
        return self   // dim area blocks all other touches
    }
}
