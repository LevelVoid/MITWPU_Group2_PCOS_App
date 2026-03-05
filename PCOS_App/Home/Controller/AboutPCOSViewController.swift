//
//  AboutPCOSViewController.swift
//  PCOS_App
//

import UIKit

final class AboutPCOSViewController: UIViewController {

    // MARK: - Storyboard Outlets
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var ContentView: UIView!

    // MARK: - Data
    var section: AboutPCOSSection?

    // Track whether we've already done the one-time constraint surgery
    private var constraintsFixed = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        headerImageView.backgroundColor = .clear
        configureUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard !constraintsFixed else { return }
        fixScrollConstraints()
        constraintsFixed = true
    }


    private func fixScrollConstraints() {
        guard let scrollView = ContentView.superview as? UIScrollView else { return }

        // ── Step 1: nuke every bottom constraint on scrollView that involves ContentView ──
        let bad = scrollView.constraints.filter { c in
            (c.firstItem  as? UIView === ContentView && c.firstAttribute  == .bottom) ||
            (c.secondItem as? UIView === ContentView && c.secondAttribute == .bottom)
        }
        scrollView.removeConstraints(bad)

        let cl = scrollView.contentLayoutGuide
        NSLayoutConstraint.activate([
            ContentView.topAnchor     .constraint(equalTo: cl.topAnchor),
            ContentView.leadingAnchor .constraint(equalTo: cl.leadingAnchor),
            ContentView.trailingAnchor.constraint(equalTo: cl.trailingAnchor),
            ContentView.bottomAnchor  .constraint(equalTo: cl.bottomAnchor),  // ← key
        ])

        ContentView.widthAnchor
            .constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
            .isActive = true

        ContentView.constraints
            .filter { $0.firstAttribute == .height && $0.secondItem == nil }
            .forEach { ContentView.removeConstraint($0) }

        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
    }

    // MARK: - Content

    private func configureUI() {
        guard let section = section else { return }

        title = section.title
        headerImageView.image = UIImage(named: section.imageName)

        stackView.arrangedSubviews.forEach {
            stackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        for (index, block) in section.contentBlocks.enumerated() {

            if block.heading != nil && index > 0 {
                let spacer = UIView()
                spacer.translatesAutoresizingMaskIntoConstraints = false
                spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
                stackView.addArrangedSubview(spacer)
            }

            if let heading = block.heading {
                stackView.addArrangedSubview(makeLabel(
                    text: heading,
                    font: .boldSystemFont(ofSize: 22),
                    color: .label
                ))
            }

            if let body = block.body {
                stackView.addArrangedSubview(makeLabel(
                    text: body,
                    font: .systemFont(ofSize: 17),
                    color: .label
                ))
            }

            if let imageName = block.imageName,
               let image = UIImage(named: imageName) {
                let iv = UIImageView()
                iv.translatesAutoresizingMaskIntoConstraints = false
                iv.image = image
                iv.contentMode = .scaleAspectFit
                iv.clipsToBounds = true
                iv.backgroundColor = .clear
                iv.heightAnchor.constraint(equalToConstant: 200).isActive = true
                stackView.addArrangedSubview(iv)
            }
        }
    }

    // MARK: - Helpers

    private func makeLabel(text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }
}
