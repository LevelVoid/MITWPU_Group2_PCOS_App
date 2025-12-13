//
//  FirstCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit

class GoalCards: UICollectionViewCell {
    
    @IBOutlet weak var progressView: CircularProgressView!
    
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var goal: UILabel!
    @IBOutlet weak var toBeCompleted: UILabel!
    @IBOutlet weak var cardName: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(_ model: Card){
        cardName.text = model.name
        imageView.image = UIImage(systemName: model.image)
        card.layer.cornerRadius = 16
        card.layer.masksToBounds = true
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.systemGray5.cgColor
        
    }
    
    
}
