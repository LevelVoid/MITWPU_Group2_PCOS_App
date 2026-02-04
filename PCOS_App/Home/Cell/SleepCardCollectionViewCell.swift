//
//  SleepCardCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 04/02/26.
//

import UIKit

class SleepCardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var Card: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        Card.layer.cornerRadius = 20
    }

}
