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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        SignalsCardView.layer.cornerRadius = 20
    }
    
    func configure(with signal: PCOSSignal) {
        SignalsLabel.text = signal.signalTitle
        SignalsImage.image = UIImage(named: signal.signalIllustration)
        SignalsImage.tintColor = .clear
    }

    
    func configurePhase(
        phase: PhaseSignal,
        cardType: PhaseCardType
    ) {
        SignalsLabel.text = phase.cardTitle(for: cardType)
        SignalsImage.image = UIImage(
            named: phase.cardImage(for: cardType)
        )
        SignalsImage.tintColor = .clear
    }

}
