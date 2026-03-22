//
//  Signal01ViewController.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 17/02/26.
//

import UIKit

final class Signal01ViewController: UIViewController {

    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var paragraph1Label: UILabel!
    @IBOutlet weak var paragraph2Label: UILabel!
    @IBOutlet weak var illustrationImageView: UIImageView!
    var signal: PCOSSignal!

    @IBOutlet weak var card1View: UIView!
    @IBOutlet weak var card2View: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bindData()
    }

    private func configureUI() {
        card1View.layer.cornerRadius = 16
        card2View.layer.cornerRadius = 16
        illustrationImageView.contentMode = .scaleAspectFit
        
        // Prevent unusually large assets from blowing up the stack view
        let heightConstraint = illustrationImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 200)
        heightConstraint.isActive = true
    }

    private func bindData() {
        title = signal.signalTitle
        headingLabel.text = signal.infoHeading
        paragraph1Label.text = signal.scientificReasons.first
        
        let secondReason = signal.scientificReasons.dropFirst().first
        paragraph2Label.text = secondReason
        
        // Hide the second card if there is no second paragraph data
        card2View.isHidden = (secondReason == nil || secondReason!.isEmpty)
        
        illustrationImageView.image = UIImage(named: signal.signalIllustration)
    }

}
