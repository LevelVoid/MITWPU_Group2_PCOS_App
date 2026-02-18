//
//  Signal02ViewController.swift
//  PCOS_App
//
//  Created by Abhinaya Rajarajan on 18/02/26.
//

import UIKit

final class Signal02ViewController: UIViewController {

    var signal: PCOSSignal!

        @IBOutlet weak var headingLabel: UILabel!
        @IBOutlet weak var descriptionLabel: UILabel!
        @IBOutlet weak var doctorDisclaimerLabel: UILabel!

    @IBOutlet weak var card1View: UIView!
    
    @IBOutlet weak var card2View: UIView!
    override func viewDidLoad() {
            super.viewDidLoad()
            
            card1View.layer.cornerRadius = 16
        card2View.layer.cornerRadius = 16
            headingLabel.text = signal.appearanceHeading
            descriptionLabel.text = signal.appearanceDescriptions.joined(separator: "\n")
            doctorDisclaimerLabel.text = signal.doctorDisclaimer
        }

}
