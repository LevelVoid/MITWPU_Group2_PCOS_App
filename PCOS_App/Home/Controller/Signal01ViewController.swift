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
        addIconsToCards()
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
        title = signal.symptomName
        
        headingLabel.text = signal.infoHeading
        headingLabel.numberOfLines = 0
        headingLabel.lineBreakMode = .byWordWrapping
        // Ensure standard native large title sizing feeling
        headingLabel.font = .systemFont(ofSize: 24, weight: .regular)
        
        paragraph1Label.text = signal.scientificReasons.first
        
        let secondReason = signal.scientificReasons.dropFirst().first
        paragraph2Label.text = secondReason
        
        // Hide the second card if there is no second paragraph data
        card2View.isHidden = (secondReason == nil || secondReason!.isEmpty)
        
        // Hide illustration
        // illustrationImageView.image = UIImage(named: signal.signalIllustration)
        illustrationImageView.isHidden = true
    }
    
    private func getIcons(for symptom: String) -> (String, String) {
        let defaultIcons = ("heart.text.clipboard", "heart.text.clipboard")
        switch symptom.lowercased() {
        case "acne":
            return ("sun.max", "drop")
        case "hair loss":
            return ("comb", "arrow.down.right")
        case "hirsutism", "excess hair growth":
            return ("sparkles", "scissors")
        case "brown", "brown spotting":
            return ("drop.triangle.fill", "clock")
        case "red", "red spotting":
            return ("drop.fill", "waveform.path.ecg")
        case "cramps":
            return ("bolt.heart", "figure.walk")
        case "fatigue":
            return ("battery.25", "bed.double")
        case "mood swings", "depressed", "anxiety":
            return ("brain", "cloud.sun")
        case "sugar cravings", "cravings":
            return ("fork.knife", "takeoutbox")
        case "weight gain":
            return ("scalemass", "arrow.up")
        case "disrupted sleep", "sleep":
            return ("moon.zzz", "bed.double.fill")
        case "headache", "headaches":
            return ("bolt.head", "pills")
        case "digestion", "bloating":
            return ("leaf", "pills.circle")
        case "low libido":
            return ("heart.slash", "moon")
        case "skin darkening":
            return ("sun.max.fill", "drop.triangle")
        default:
            return defaultIcons
        }
    }
    
    private func addIconsToCards() {
        let icons = getIcons(for: signal.symptomName)
        
        func addIcon(to card: UIView, label: UILabel, iconName: String) {
            let imageView = UIImageView(image: UIImage(systemName: iconName))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.contentMode = .scaleAspectFit
            imageView.tintColor = .black
            
            // Adjust label font size slightly if needed, or just let auto layout wrap
            card.addSubview(imageView)
            
            // Find and deactivate the existing leading constraint for the label
            for constraint in card.constraints {
                if let firstItem = constraint.firstItem as? UIView, firstItem == label, constraint.firstAttribute == .leading {
                    constraint.isActive = false
                }
            }
            
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
                imageView.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
                imageView.widthAnchor.constraint(equalToConstant: 30),
                imageView.heightAnchor.constraint(equalToConstant: 30),
                label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16)
            ])
        }
        
        addIcon(to: card1View, label: paragraph1Label, iconName: icons.0)
        addIcon(to: card2View, label: paragraph2Label, iconName: icons.1)
    }

}
