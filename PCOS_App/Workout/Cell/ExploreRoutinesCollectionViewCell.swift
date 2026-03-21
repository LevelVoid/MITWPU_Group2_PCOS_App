//
//  ExploreRoutinesCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 09/12/25.
//

import UIKit

class ExploreRoutinesCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var RoutineEstTime: UILabel!
    @IBOutlet weak var exploreRoutineImage: UIImageView!
    @IBOutlet weak var exploreRoutineTitle: UILabel!
    @IBOutlet weak var cellBackgroundView: UIView!
    
    @IBOutlet weak var EstTimeOutlet: UILabel!
    @IBOutlet weak var timeTagContainer: UIView!
    @IBOutlet weak var RoutineDescriptionOutlet: UILabel!

    // Programmatic "Recommended Today" tag — positioned beside the time tag
    private lazy var recommendedTagLabel: UILabel = {
        let label = UILabel()
        label.text = "Recommended Today"
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = UIColor(hex: "D4516A")
        label.backgroundColor = UIColor(hex: "FDEEF1")
        label.layer.borderWidth = 0.8
        label.layer.borderColor = UIColor(hex: "F2C0CB").cgColor
        label.textAlignment = .center
        label.layer.cornerRadius = 9
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private var recommendedTagAdded = false

    override func awakeFromNib() {
        super.awakeFromNib()
    }
   
    private func addRecommendedTag() {
        guard !recommendedTagAdded else { return }
        recommendedTagAdded = true
        cellBackgroundView.addSubview(recommendedTagLabel)
        NSLayoutConstraint.activate([
            // Position beside the time tag container, same vertical center
            recommendedTagLabel.centerYAnchor.constraint(equalTo: timeTagContainer.centerYAnchor),
            recommendedTagLabel.leadingAnchor.constraint(equalTo: timeTagContainer.trailingAnchor, constant: 8),
            recommendedTagLabel.heightAnchor.constraint(equalToConstant: 20),
            recommendedTagLabel.widthAnchor.constraint(equalToConstant: 138)
        ])
    }

    func configureCell(_ routine: Routine, isRecommended: Bool = false) {
        
        exploreRoutineTitle.text = routine.name
        RoutineDescriptionOutlet.text = routine.routineTagline
        EstTimeOutlet.text = routine.formattedDuration
        
        if let imageName = routine.thumbnailImageName {
            exploreRoutineImage.image = UIImage(named: imageName)
        } else {
            exploreRoutineImage.image = UIImage(systemName: "dumbbell.fill")
        }
        
        timeTagContainer.layer.cornerRadius = timeTagContainer.frame.height / 2
        exploreRoutineTitle.textColor = .label

        // Fix uneven images: use scaleAspectFill with clipping
       // exploreRoutineImage.contentMode = .scaleAspectFill
        exploreRoutineImage.clipsToBounds = true

        cellBackgroundView.backgroundColor = .systemBackground
        cellBackgroundView.layer.cornerRadius = 16
        exploreRoutineImage.layer.cornerRadius = 16

        // Show/hide recommended tag beside the time tag
        addRecommendedTag()
        recommendedTagLabel.isHidden = !isRecommended
    }
}
