//
//  QuickActionsCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 04/02/26.
//

import UIKit

class QuickActionsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var dietActionCard: UIView!
    @IBOutlet weak var workoutActionCard: UIView!
    
    @IBOutlet weak var dietRecView: UIView!
    @IBOutlet weak var workoutRecView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        dietActionCard.layer.cornerRadius=20
        workoutActionCard.layer.cornerRadius=20
        
        dietRecView.layer.cornerRadius=10
        workoutRecView.layer.cornerRadius=10
    }

}
