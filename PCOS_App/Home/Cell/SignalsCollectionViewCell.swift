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
        SignalsCardView.clipsToBounds = true
        
        SignalsLabel.removeFromSuperview()
        SignalsImage.removeFromSuperview()
        
        SignalsCardView.addSubview(IconBackgroundView)
        SignalsCardView.addSubview(SignalsImage)
        SignalsCardView.addSubview(SignalsLabel)
        SignalsCardView.addSubview(CategoryLabel)
        
        IconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        SignalsImage.translatesAutoresizingMaskIntoConstraints = false
        SignalsLabel.translatesAutoresizingMaskIntoConstraints = false
        CategoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        IconBackgroundView.backgroundColor = UIColor(hex: "#FCEEED")
        IconBackgroundView.layer.cornerRadius = 16
        IconBackgroundView.clipsToBounds = true
        
        SignalsLabel.font = .systemFont(ofSize: 20, weight: .medium)
        SignalsLabel.textColor = .black
        SignalsLabel.numberOfLines = 1
        
        CategoryLabel.font = .systemFont(ofSize: 13, weight: .regular)
        CategoryLabel.textColor = .darkGray
        
        NSLayoutConstraint.activate([
            IconBackgroundView.topAnchor.constraint(equalTo: SignalsCardView.topAnchor, constant: 8),
            IconBackgroundView.leadingAnchor.constraint(equalTo: SignalsCardView.leadingAnchor, constant: 8),
            IconBackgroundView.trailingAnchor.constraint(equalTo: SignalsCardView.trailingAnchor, constant: -8),
            IconBackgroundView.heightAnchor.constraint(equalToConstant: 110),
            
            SignalsImage.topAnchor.constraint(equalTo: IconBackgroundView.topAnchor),
            SignalsImage.leadingAnchor.constraint(equalTo: IconBackgroundView.leadingAnchor),
            SignalsImage.trailingAnchor.constraint(equalTo: IconBackgroundView.trailingAnchor),
            SignalsImage.bottomAnchor.constraint(equalTo: IconBackgroundView.bottomAnchor),
            
            SignalsLabel.topAnchor.constraint(equalTo: IconBackgroundView.bottomAnchor, constant: 12),
            SignalsLabel.leadingAnchor.constraint(equalTo: SignalsCardView.leadingAnchor, constant: 12),
            SignalsLabel.trailingAnchor.constraint(equalTo: SignalsCardView.trailingAnchor, constant: -12),
            
            CategoryLabel.topAnchor.constraint(equalTo: SignalsLabel.bottomAnchor, constant: 4),
            CategoryLabel.leadingAnchor.constraint(equalTo: SignalsCardView.leadingAnchor, constant: 12),
            CategoryLabel.trailingAnchor.constraint(equalTo: SignalsCardView.trailingAnchor, constant: -12)
        ])
    }
    
    func configure(with signal: PCOSSignal, symptom: SymptomItem? = nil) {
        if let symptom = symptom {
            SignalsLabel.text = symptom.name
            CategoryLabel.text = symptom.category
            SignalsImage.image = UIImage(named: symptom.icon)
            SignalsImage.contentMode = .center // center it in the pink box
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
