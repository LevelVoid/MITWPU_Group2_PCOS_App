
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
import TipKit

// MARK: - Overlay View

final class WalkthroughOverlayView: UIView {

    // MARK: Callbacks
    var onTargetTapped: (() -> Void)?

    // MARK: Sub-views
    private let pulseDot    = UIView()
    private let tapIndicator = UIView()   // invisible tap zone over the cutout

    // MARK: State
    private var cutoutFrame: CGRect = .zero

    // MARK: - Factory

    static func install(
        in parent: UIView,
        targetFrame: CGRect,
        onTargetTapped: (() -> Void)? = nil
    ) -> WalkthroughOverlayView {
        let ov = WalkthroughOverlayView(frame: parent.bounds)
        ov.onTargetTapped = onTargetTapped
        ov.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        parent.addSubview(ov)
        ov.setupContents(targetFrame: targetFrame)
        ov.animateIn()
        return ov
    }

    // MARK: - Setup

    private func setupContents(targetFrame: CGRect) {
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
        UIView.animate(withDuration: 0.3, delay: 0,
                       usingSpringWithDamping: 0.75, initialSpringVelocity: 0.2) {
            self.alpha = 1
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

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if tapIndicator.frame.contains(point) { return tapIndicator }
        return self   // dim area blocks all other touches
    }
    
    @available(iOS 17.0, *)
    func observeTip(_ tip: any Tip, popover: UIViewController? = nil, onInvalidated: (() -> Void)? = nil) {
        Task {
            for await status in tip.statusUpdates {
                if case .invalidated = status {
                    await MainActor.run {
                        if let popover = popover {
                            popover.dismiss(animated: true) {
                                onInvalidated?()
                            }
                        } else {
                            onInvalidated?()
                        }
                        self.dismiss()
                    }
                }
            }
        }
    }
}


