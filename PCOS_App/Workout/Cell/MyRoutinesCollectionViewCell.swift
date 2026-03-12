//
//  MyRoutinesCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

class MyRoutinesCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var routineNameOutlet: UILabel!
    
    @IBOutlet weak var MyRoutinesImageOutlet: UIImageView!
    @IBOutlet weak var timeTagContainer: UIView!
    
    @IBOutlet weak var EstimatedTimeLabelOutlet: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        containerView.layer.cornerRadius = 20
        containerView.layer.masksToBounds = true
        //containerView.layer.borderWidth = 1
        //containerView.layer.borderColor = UIColor.systemGray5.cgColor
        timeTagContainer.layer.cornerRadius = timeTagContainer.frame.height/2
    }
    func configureCell(with routine: Routine) {
            routineNameOutlet.text = routine.name
        if let imageName = routine.thumbnailImageName {
            MyRoutinesImageOutlet.image = UIImage(named: imageName)
            //MyRoutinesImageOutlet.contentMode = .scaleAspectFill
            EstimatedTimeLabelOutlet.text = routine.formattedDuration
        }


        }
    
}
