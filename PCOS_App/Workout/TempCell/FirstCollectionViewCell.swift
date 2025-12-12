//
//  FirstCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit


class FirstCollectionViewCell: UICollectionViewCell {
    

    @IBOutlet weak var progressView: UIView!
    
    @IBOutlet weak var goal: UILabel!
    @IBOutlet weak var toBeCompleted: UILabel!
    @IBOutlet weak var cardName: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
