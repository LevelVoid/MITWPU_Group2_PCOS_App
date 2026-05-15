
//
//  WalkthroughCongratsView.swift
//  PCOS_App
//

import UIKit

// MARK: - Congratulations Card

/// Animated congratulations card shown between walkthrough steps.
final class WalkthroughCongratsView: UIView {

    // MARK: Callback
    var onContinue: (() -> Void)?

    // MARK: Sub-views
    private let blurBackground = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let card           = UIView()
    private let checkCircle    = UIView()
    private let checkLabel     = UILabel()
    private let titleLabel     = UILabel()
    private let bodyLabel      = UILabel()
    private let continueButton = UIButton(type: .system)

    // MARK: - Factory

    @discardableResult
    static func present(
        in parent: UIView,
        title: String,
        body: String,
        continueTitle: String = "Continue",
        onContinue: @escaping () -> Void
    ) -> WalkthroughCongratsView {
        let v = WalkthroughCongratsView(frame: parent.bounds)
        v.onContinue = onContinue
        v.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        v.buildUI(title: title, body: body, continueTitle: continueTitle)
        parent.addSubview(v)
        v.animateIn()
        return v
    }

    // MARK: - Build

    private func buildUI(title: String, body: String, continueTitle: String) {
        let pink = UIColor(hex: "#FE7A96")

        // Blur background
        blurBackground.frame = bounds
        blurBackground.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurBackground)

        // Card
        card.backgroundColor = .white
        card.layer.cornerRadius = 24
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.18
        card.layer.shadowRadius = 24
        card.layer.shadowOffset = CGSize(width: 0, height: 8)
        card.translatesAutoresizingMaskIntoConstraints = false
        addSubview(card)

        NSLayoutConstraint.activate([
            card.centerXAnchor.constraint(equalTo: centerXAnchor),
            card.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20),
            card.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.82),
        ])

        // ── Check circle ─────────────────────────────────────────────────────
        checkCircle.backgroundColor = pink.withAlphaComponent(0.12)
        checkCircle.layer.cornerRadius = 40
        checkCircle.layer.borderWidth  = 2.5
        checkCircle.layer.borderColor  = pink.cgColor
        checkCircle.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(checkCircle)

        checkLabel.text = "✓"
        checkLabel.font = .systemFont(ofSize: 36, weight: .bold)
        checkLabel.textColor = pink
        checkLabel.textAlignment = .center
        checkLabel.translatesAutoresizingMaskIntoConstraints = false
        checkCircle.addSubview(checkLabel)

        // ── Title ─────────────────────────────────────────────────────────────
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = UIColor(hex: "#1A1A2E")
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)

        // ── Body ──────────────────────────────────────────────────────────────
        bodyLabel.text = body
        bodyLabel.font = .systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.textAlignment = .center
        bodyLabel.numberOfLines = 0
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(bodyLabel)

        // ── Continue Button ───────────────────────────────────────────────────
        var config = UIButton.Configuration.filled()
        config.title = continueTitle
        config.cornerStyle = .capsule
        config.baseBackgroundColor = pink
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = .systemFont(ofSize: 16, weight: .semibold)
            return a
        }
        continueButton.configuration = config
        continueButton.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(continueButton)

        // ── Constraints inside card ───────────────────────────────────────────
        NSLayoutConstraint.activate([
            checkCircle.topAnchor.constraint(equalTo: card.topAnchor, constant: 32),
            checkCircle.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            checkCircle.widthAnchor.constraint(equalToConstant: 80),
            checkCircle.heightAnchor.constraint(equalToConstant: 80),

            checkLabel.centerXAnchor.constraint(equalTo: checkCircle.centerXAnchor),
            checkLabel.centerYAnchor.constraint(equalTo: checkCircle.centerYAnchor),

            titleLabel.topAnchor.constraint(equalTo: checkCircle.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            bodyLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 24),
            bodyLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -24),

            continueButton.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 28),
            continueButton.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            continueButton.widthAnchor.constraint(equalTo: card.widthAnchor, multiplier: 0.75),
            continueButton.heightAnchor.constraint(equalToConstant: 52),
            continueButton.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -28),
        ])
    }

    // MARK: - Animations

    private func animateIn() {
        blurBackground.alpha = 0
        card.alpha = 0
        card.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.3, options: .curveEaseOut) {
            self.blurBackground.alpha = 1
            self.card.alpha = 1
            self.card.transform = .identity
        } completion: { _ in
            self.animateCheck()
        }
    }

    private func animateCheck() {
        checkLabel.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        checkLabel.alpha = 0
        UIView.animate(withDuration: 0.45, delay: 0, usingSpringWithDamping: 0.55,
                       initialSpringVelocity: 0.5) {
            self.checkLabel.transform = .identity
            self.checkLabel.alpha = 1
        }
        // Ripple on circle
        let ripple = UIView(frame: checkCircle.bounds)
        ripple.layer.cornerRadius = 40
        ripple.layer.borderWidth = 2
        ripple.layer.borderColor = UIColor(hex: "#FE7A96").cgColor
        ripple.alpha = 0.8
        checkCircle.addSubview(ripple)
        UIView.animate(withDuration: 0.7, delay: 0.1, options: .curveEaseOut) {
            ripple.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            ripple.alpha = 0
        } completion: { _ in ripple.removeFromSuperview() }
    }

    private func animateOut(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.25, animations: {
            self.blurBackground.alpha = 0
            self.card.alpha = 0
            self.card.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            self.removeFromSuperview()
            completion()
        }
    }

    // MARK: - Action

    @objc private func continueTapped() {
        animateOut { [weak self] in
            self?.onContinue?()
        }
    }
}
