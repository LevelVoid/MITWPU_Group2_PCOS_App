//
//  TypingIndicatorCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 23/03/26.
//
import UIKit

final class TypingIndicatorCell: UITableViewCell {
    
    static let identifier = "TypingIndicatorCell"
    
    private let bubbleView  = UIView()
    private let avatarView  = UIView()
    private let avatarLabel = UILabel()
    private var dots: [UIView] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        avatarView.backgroundColor = UIColor(hex:"fe7a96")
        avatarView.layer.cornerRadius = 14
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatarView)
        
        avatarLabel.text = "A"
        avatarLabel.font = .systemFont(ofSize: 12, weight: .bold)
        avatarLabel.textColor = .white
        avatarLabel.textAlignment = .center
        avatarLabel.translatesAutoresizingMaskIntoConstraints = false
        avatarView.addSubview(avatarLabel)
        
        bubbleView.backgroundColor = UIColor(hex:"ffffff")
        bubbleView.layer.cornerRadius = 18
        bubbleView.layer.cornerCurve = .continuous
        bubbleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bubbleView)
        
        // 3 dots
        let dotStack = UIStackView()
        dotStack.axis = .horizontal
        dotStack.spacing = 4
        dotStack.alignment = .center
        dotStack.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(dotStack)
        
        for _ in 0..<3 {
            let dot = UIView()
            dot.backgroundColor = .systemGray2
            dot.layer.cornerRadius = 4
            dot.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dot.widthAnchor.constraint(equalToConstant: 8),
                dot.heightAnchor.constraint(equalToConstant: 8)
            ])
            dotStack.addArrangedSubview(dot)
            dots.append(dot)
        }
        
        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            avatarView.widthAnchor.constraint(equalToConstant: 28),
            avatarView.heightAnchor.constraint(equalToConstant: 28),
            avatarView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
            
            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),
            
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
            bubbleView.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 6),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            dotStack.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 12),
            dotStack.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -12),
            dotStack.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 14),
            dotStack.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -14),
        ])
    }
    
    func startAnimating() {
        for (i, dot) in dots.enumerated() {
            let delay = Double(i) * 0.18
            UIView.animate(
                withDuration: 0.45,
                delay: delay,
                options: [.repeat, .autoreverse],
                animations: { dot.alpha = 0.2 }
            )
        }
    }
    
    func stopAnimating() {
        dots.forEach { $0.layer.removeAllAnimations(); $0.alpha = 1 }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopAnimating()
    }
}
