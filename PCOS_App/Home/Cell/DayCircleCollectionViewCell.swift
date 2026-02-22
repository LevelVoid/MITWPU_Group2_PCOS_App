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
        iconImageView.isHidden = true
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
        circleView.backgroundColor = day.phase.backgroundColor

        if symptom != nil {
            iconImageView.image = UIImage(named: focusedSymptom?.icon ?? "")
            iconImageView.tintColor = .label
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
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
