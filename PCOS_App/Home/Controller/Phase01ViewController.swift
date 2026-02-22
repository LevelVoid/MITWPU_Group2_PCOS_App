//
//  Phase01ViewController.swift
//  PCOS_App
//
//  Created by Dnyaneshwari Gogawale on 19/02/26.
//

import UIKit

class Phase01ViewController: UIViewController {
    @IBOutlet weak var CycleImage: UIImageView!
    @IBOutlet weak var card1View:UIView!
    @IBOutlet weak var CycleInformation: UILabel!
    @IBOutlet weak var heading: UILabel!
    var phaseSignal: PhaseSignal!

        // MARK: - Lifecycle
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
        }

        // MARK: - UI Setup
        private func setupUI() {

            // Heading
            heading.text = phaseSignal.understanding.heading

            // Combine multiple paragraphs into one clean block
            CycleInformation.text = phaseSignal.understanding.descriptions
                .joined(separator: "\n\n")
            card1View.layer.cornerRadius = 16
            // Illustration
            CycleImage.image = UIImage(named: phaseSignal.illustration)
            CycleImage.contentMode = .scaleAspectFit
        }

    

}
