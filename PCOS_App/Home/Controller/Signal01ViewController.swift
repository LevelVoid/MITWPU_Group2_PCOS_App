//
//  Signal01ViewController.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 17/02/26.
//

import UIKit

final class Signal01ViewController: UIViewController {

   // @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoHeadingLabel: UILabel!
    @IBOutlet weak var infoCardLabel1: UILabel!
    @IBOutlet weak var infoCardLabel2: UILabel!
    @IBOutlet weak var illustrationImageView: UIImageView!
    var signal: PCOSSignal!


    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        bindData()
    }

    private func configureUI() {
        title = signal.signalTitle
        infoCardLabel1.numberOfLines = 0
        infoCardLabel2.numberOfLines = 0
        illustrationImageView.contentMode = .scaleAspectFit
    }

    private func bindData() {

        infoHeadingLabel.text = signal.infoHeading
        infoCardLabel1.text = signal.scientificReasons.first
        infoCardLabel2.text = signal.scientificReasons.dropFirst().first
        illustrationImageView.image = UIImage(named: signal.signalIllustration)
    }

}
