//
//  MyRoutinesEmptyCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 15/12/25.
//

import UIKit

class MyRoutinesEmptyCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 20
//        containerView.layer.borderWidth = 1
//        containerView.layer.borderColor = UIColor.systemGray5.cgColor
        
        messageLabel.text = "Get started by creating a routine"
        messageLabel.textColor = .secondaryLabel
        messageLabel.textAlignment = .center
//        messageLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        
    }
}
