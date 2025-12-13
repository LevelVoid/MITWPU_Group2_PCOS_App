//
//  ExploreRoutinesCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

class ExploreRoutinesCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var exploreRoutineImage: UIImageView!
    @IBOutlet weak var exploreRoutineTitle: UILabel!
    @IBOutlet weak var cellBackgroundView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
   

    func configureCell(_ routine: Routine) {
        
        exploreRoutineTitle.text = routine.name

        if let imageName = routine.thumbnailImageName {
            exploreRoutineImage.image = UIImage(named: imageName)
        } else {
            exploreRoutineImage.image = UIImage(systemName: "dumbbell.fill")
        }

        exploreRoutineTitle.textColor = .label
//        exploreRoutineImage.contentMode = .scaleAspectFill
        exploreRoutineImage.clipsToBounds = true
        cellBackgroundView.backgroundColor = .systemGray6
        cellBackgroundView.layer.cornerRadius = 10
    }


    
    
    
    
}
