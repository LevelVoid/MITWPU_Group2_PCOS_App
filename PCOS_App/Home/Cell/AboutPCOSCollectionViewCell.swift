//
//  AboutPCOSCollectionViewCell.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 11/02/26.
//

import UIKit

class AboutPCOSCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        containerView.layer.cornerRadius = 20
        containerView.clipsToBounds = true
        containerView.backgroundColor = .white

        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.numberOfLines = 2

        descriptionLabel.font = UIFont.systemFont(ofSize: 15)
        descriptionLabel.numberOfLines = 3
        descriptionLabel.textColor = .darkGray

        articleImageView.contentMode = .scaleAspectFit
        articleImageView.clipsToBounds = true
    }

    func configure(with article: AboutPCOSSection) {
        titleLabel.text = article.title
        descriptionLabel.text = article.description
        articleImageView.image = UIImage(named: article.imageName)
    }
}
