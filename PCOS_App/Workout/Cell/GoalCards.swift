//
//  FirstCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit

class GoalCards: UICollectionViewCell {
    
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var done: UILabel!
    @IBOutlet weak var toBeDone: UILabel!
    @IBOutlet weak var cardName: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var iconContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(_ model: Card){
        cardName.text = model.name
        cardName.textColor = model.tintColor
        
        imageView.image = UIImage(systemName: model.image)
        imageView.tintColor = model.tintColor
        
        iconContainer.layer.cornerRadius = 12
        iconContainer.backgroundColor = model.tintColor.withAlphaComponent(0.1)
        
        card.layer.cornerRadius = 16
        card.layer.masksToBounds = true
        card.backgroundColor = .white
        
        done.text = "\(Int(model.done ?? 0))"
        toBeDone.text = "/ \(Int(model.toBeDone)) " + (model.unit ?? "")
        
        // Progress calculation
        let progress = model.toBeDone > 0
        ? min(model.done! / model.toBeDone, 1.0)
        : 0

        progressView.setProgress(Float(progress), animated: true)
        progressView.progressTintColor = model.tintColor
        progressView.trackTintColor = .systemGray5
    }
    
    
}
