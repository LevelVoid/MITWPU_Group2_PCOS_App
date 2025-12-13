//
//  MyRoutinesCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

class MyRoutinesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var startRoutineButtonOutlet: UIButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var routineNameOutlet: UILabel!
    
    var onStartTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        startRoutineButtonOutlet.isUserInteractionEnabled = true
        
        containerView.layer.cornerRadius = 16
                containerView.layer.masksToBounds = true
                containerView.layer.borderWidth = 1
                containerView.layer.borderColor = UIColor.systemGray5.cgColor
    }
    func configureCell(with routine: Routine) {
            routineNameOutlet.text = routine.name
        startRoutineButtonOutlet.tintColor = UIColor(red: 254/255, green: 122/255, blue: 150/255, alpha: 0.8)


        }
    @IBAction func startRoutineTapped(_ sender: UIButton) {
            onStartTapped?()
        }
}
