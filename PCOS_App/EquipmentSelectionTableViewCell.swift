//
//  EquipmentSelectionTableViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 27/11/25.
//

import UIKit

class EquipmentSelectionTableViewCell: UITableViewCell {

    @IBOutlet weak var equipmentNameLabel: UILabel!
    @IBOutlet weak var equipmentImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
