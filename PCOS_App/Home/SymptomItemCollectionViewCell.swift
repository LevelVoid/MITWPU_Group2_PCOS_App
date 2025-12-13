//
//  SymptomItemCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 13/12/25.
//

import UIKit

class SymptomItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var IconImage: UIImageView!
    @IBOutlet weak var symptomLabel: UILabel!
    
    static let identifier = "SymptomItemCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        if IconImage != nil && symptomLabel != nil {
                setupUI()
            } else {
                print("⚠️ ERROR: IBOutlets not connected in Storyboard!")
            }
    }
    
    private func setupUI(){
        // Cell background and corners
        //contentView.backgroundColor = UIColor(red: 1.0, green: 0.87, blue: 0.96, alpha: 1.0) // Light purple/lavender
            contentView.layer.cornerRadius = 20
            contentView.clipsToBounds = true
            
            // Icon setup - circular white background
            IconImage?.layer.cornerRadius = 25 // Will be 50x50, so half is 25
            IconImage?.clipsToBounds = true
            IconImage?.contentMode = .scaleAspectFit
            IconImage?.backgroundColor = .white
            
            // Label setup
//            symptomLabel?.textAlignment = .center
//            symptomLabel?.numberOfLines = 2
//            symptomLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            //symptomLabel?.textColor = UIColor(red: 0.56, green: 0.56, blue: 0.58, alpha: 1.0) // Gray color
        }
    
    func configure(with symptom: SymptomItem, isSelected: Bool) {
        guard let iconImage = IconImage, let label = symptomLabel else {
                print("ERROR in configure: IBOutlets are nil!")
                return
            }
            
            label.text = symptom.name
            iconImage.image = UIImage(named: symptom.icon)
            
            updateSelectionState(isSelected)
                
        }
    
    private func updateSelectionState(_ isSelected: Bool) {
        if isSelected {
                    contentView.backgroundColor = UIColor.systemPurple
                    IconImage.tintColor = .white
                    symptomLabel.textColor = .white
                } else {
                    //contentView.backgroundColor = UIColor.systemPurple.withAlphaComponent(0.15)
                    //IconImage.tintColor = .systemPurple
                    symptomLabel.textColor = .gray
                }
        }

}
