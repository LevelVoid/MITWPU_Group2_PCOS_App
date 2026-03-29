//
//  HomeRecommendationCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 10/01/26.
//

import UIKit

class HomeRecommendationCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        
        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.separator.cgColor

        iconContainerView.layer.cornerRadius = 20
    }
    
    func configure(with recommendation: Recommendation) {
        titleLabel.text = recommendation.title
        descriptionLabel.text = recommendation.summary
        
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        
        switch recommendation.category {
        case .nutrition:
            iconImageView.image = UIImage(systemName: "fork.knife", withConfiguration: iconConfig)
            iconImageView.tintColor = .systemRed
            iconContainerView.backgroundColor = UIColor(red: 1.0, green: 0.9, blue: 0.9, alpha: 1.0)
            
        case .workout:
            iconImageView.image = UIImage(systemName: "figure.walk", withConfiguration: iconConfig)
            iconImageView.tintColor = .systemGreen
            iconContainerView.backgroundColor = UIColor(red: 0.9, green: 1.0, blue: 0.9, alpha: 1.0)
            
        case .foodPattern:
            iconImageView.image = UIImage(systemName: "chart.bar.fill", withConfiguration: iconConfig)
            iconImageView.tintColor = .systemBlue
            iconContainerView.backgroundColor = UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0)
            
        default:
            iconImageView.image = UIImage(systemName: "info.circle.fill", withConfiguration: iconConfig)
            iconImageView.tintColor = .gray
            iconContainerView.backgroundColor = .lightGray
        }
    }
    
}
