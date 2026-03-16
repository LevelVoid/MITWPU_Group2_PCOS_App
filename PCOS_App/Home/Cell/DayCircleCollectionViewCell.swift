//
//  DayCircleCollectionViewCell.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 06/02/26.
//

import UIKit

class DayCircleCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        dayLabel.isHidden = true
        circleView.isHidden = false
        circleView.backgroundColor = .clear
        iconImageView.isHidden = true
        iconImageView.image = nil
    }

    override func layoutSubviews() {
            super.layoutSubviews()
            circleView.layer.cornerRadius = circleView.bounds.width / 2
            circleView.clipsToBounds = true
        }
    



    func configure(
        day: CycleDay,
        symptom: SymptomItem?,
        focusedSymptom: SymptomItem?
    ) {
        circleView.isHidden = false
        circleView.backgroundColor = day.phase.backgroundColor.withAlphaComponent(0.5)

        if symptom != nil, let iconName = focusedSymptom?.icon {
            // Use the original image (full-color) to display the symptom exactly as designed
            let image = UIImage(named: iconName)?.withRenderingMode(.alwaysOriginal)
            iconImageView.image = image
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
            iconImageView.image = nil
        }

        dayLabel.isHidden = true
    }

    func configureAsDayNumber(day: Int) {
        dayLabel.isHidden = false
        dayLabel.text = "\(day)"

        circleView.isHidden = true
        iconImageView.isHidden = true
    }




    

}
