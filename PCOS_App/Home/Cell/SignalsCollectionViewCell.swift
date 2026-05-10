//
//  SignalsCollectionViewCell.swift
//  PCOS_App
//
//  Created by SDC-USER on 05/02/26.
//

import UIKit

class SignalsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var SignalsCardView: UIView!
    
    @IBOutlet weak var SignalsLabel: UILabel!
    @IBOutlet weak var SignalsImage: UIImageView!
    
    let IconBackgroundView = UIView()
    let CategoryLabel = UILabel()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        SignalsCardView.layer.cornerRadius = 20
        SignalsCardView.layer.borderWidth = 0

        SignalsCardView.clipsToBounds = true
        
        SignalsLabel.removeFromSuperview()
        SignalsImage.removeFromSuperview()
        
        SignalsCardView.addSubview(IconBackgroundView)
        SignalsCardView.addSubview(SignalsImage)
        SignalsCardView.addSubview(SignalsLabel)
        SignalsCardView.addSubview(CategoryLabel)
        
        IconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        SignalsImage.translatesAutoresizingMaskIntoConstraints = false
        SignalsImage.clipsToBounds = true
        SignalsLabel.translatesAutoresizingMaskIntoConstraints = false
        CategoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        IconBackgroundView.backgroundColor = UIColor(hex: "#fee6f3")
        IconBackgroundView.layer.cornerRadius = 16
        IconBackgroundView.clipsToBounds = true
        
        SignalsImage.layer.cornerRadius = 16
        SignalsImage.clipsToBounds = true
        
        SignalsLabel.font = .systemFont(ofSize: 12, weight: .medium)
        SignalsLabel.textColor = .label
        SignalsLabel.numberOfLines = 0
        
        CategoryLabel.font = .systemFont(ofSize: 12, weight: .regular)
        CategoryLabel.textColor = .secondaryLabel
        
        NSLayoutConstraint.activate([
            IconBackgroundView.topAnchor.constraint(equalTo: SignalsCardView.topAnchor, constant: 4),
            IconBackgroundView.leadingAnchor.constraint(equalTo: SignalsCardView.leadingAnchor, constant: 4),
            IconBackgroundView.trailingAnchor.constraint(equalTo: SignalsCardView.trailingAnchor, constant: -4),
            IconBackgroundView.heightAnchor.constraint(equalTo: SignalsCardView.heightAnchor, multiplier: 0.58),
            
            SignalsImage.topAnchor.constraint(equalTo: IconBackgroundView.topAnchor),
            SignalsImage.leadingAnchor.constraint(equalTo: IconBackgroundView.leadingAnchor),
            SignalsImage.trailingAnchor.constraint(equalTo: IconBackgroundView.trailingAnchor),
            SignalsImage.bottomAnchor.constraint(equalTo: IconBackgroundView.bottomAnchor),
            
            SignalsLabel.topAnchor.constraint(equalTo: IconBackgroundView.bottomAnchor, constant: 8),
            SignalsLabel.leadingAnchor.constraint(equalTo: SignalsCardView.leadingAnchor, constant: 10),
            SignalsLabel.trailingAnchor.constraint(equalTo: SignalsCardView.trailingAnchor, constant: -10),
            
            CategoryLabel.topAnchor.constraint(equalTo: SignalsLabel.bottomAnchor, constant: 2),
            CategoryLabel.leadingAnchor.constraint(equalTo: SignalsCardView.leadingAnchor, constant: 10),
            CategoryLabel.trailingAnchor.constraint(equalTo: SignalsCardView.trailingAnchor, constant: -10)
        ])
    }
    
    func configure(with signal: PCOSSignal, symptom: SymptomItem? = nil) {
        if let symptom = symptom {
            SignalsLabel.text = symptom.name
            CategoryLabel.text = symptom.category
            
            // Resolve canonical icon from SymptomCategory to avoid legacy CoreData mismatch
            let canonicalIcon = SymptomCategory.allCategories
                .flatMap { $0.items }
                .first(where: { $0.name == symptom.name })?.icon ?? symptom.icon
                
            SignalsImage.image = UIImage(named: canonicalIcon)
            SignalsImage.contentMode = .scaleAspectFill
            IconBackgroundView.isHidden = false
        } else {
            SignalsLabel.text = signal.signalTitle
            CategoryLabel.text = ""
            SignalsImage.image = UIImage(named: signal.signalIllustration)
            SignalsImage.contentMode = .scaleAspectFill
            IconBackgroundView.isHidden = true
        }
        SignalsImage.tintColor = .clear
    }
    
    func configurePhase(
        phase: PhaseSignal,
        cardType: PhaseCardType
    ) {
        SignalsLabel.text = phase.cardTitle(for: cardType)
        CategoryLabel.text = ""
        SignalsImage.image = UIImage(
            named: phase.cardImage(for: cardType)
        )
        SignalsImage.contentMode = .scaleAspectFill
        IconBackgroundView.isHidden = true
        SignalsImage.tintColor = .clear
    }
}
