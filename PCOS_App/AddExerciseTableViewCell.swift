//
//  AddExerciseTableViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class AddExerciseTableViewCell: UITableViewCell {

    @IBOutlet weak var muscleTypeSubheadline: UILabel!
    @IBOutlet weak var exerciseNameHeadline: UILabel!
    @IBOutlet weak var addExerciseImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Optional: unify margins and separator insets
        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        preservesSuperviewLayoutMargins = false
        separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        // If your constraints are tied to layoutMarginsGuide, this will add the left padding.
        // If they’re tied to contentView.leadingAnchor, adjust the leading constraint constant in IB instead.
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
