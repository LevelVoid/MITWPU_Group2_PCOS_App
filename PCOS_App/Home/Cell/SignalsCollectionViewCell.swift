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

    
    func configurePhase(with phase: PhaseSignal) {
        SignalsLabel.text = phase.title
        SignalsImage.image = UIImage(named: phase.illustration)
        SignalsImage.tintColor = .clear
    }


}
