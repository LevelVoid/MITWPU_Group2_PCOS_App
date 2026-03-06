//
//  MovementTypeViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 17/01/26.
//

import UIKit

class MovementTypeViewController: UIViewController {

    @IBOutlet weak var sedentaryView: UIView!
    @IBOutlet weak var lightMovementsView: UIView!
    @IBOutlet weak var regularMovementsView: UIView!
    @IBOutlet weak var veryActiveView: UIView!
    
    @IBOutlet weak var nextButton: UIButton!
    private var selectedView: UIView?
    private var selectedMovementType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.tintColor = UIColor(hex:"FE7A96")
        sedentaryView.layer.cornerRadius = 20
        lightMovementsView.layer.cornerRadius = 20
        regularMovementsView.layer.cornerRadius = 20
        veryActiveView.layer.cornerRadius = 20
        
        // Add tap gestures to each view
        addTapGesture(to: sedentaryView, movementType: "Sedentary Type")
        addTapGesture(to: lightMovementsView, movementType: "Light Movements")
        addTapGesture(to: regularMovementsView, movementType: "Regular Movements")
        addTapGesture(to: veryActiveView, movementType: "Very active on most days")
       
    }
    
    private func addTapGesture(to view: UIView, movementType: String) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
            view.isUserInteractionEnabled = true
            view.tag = getTag(for: movementType)
            view.addGestureRecognizer(tapGesture)
        }
    private func getTag(for movementType: String) -> Int {
    switch movementType {
    case "Sedentary Type": return 1
    case "Light Movements": return 2
    case "Regular Movements": return 3
    case "Very active on most days": return 4
    default: return 0
    }
        }
    
    private func getMovementType(from tag: Int) -> String {
            switch tag {
            case 1: return "Sedentary Type"
            case 2: return "Light Movements"
            case 3: return "Regular Movements"
            case 4: return "Very active on most days"
            default: return ""
            }
        }
    @objc private func viewTapped(_ gesture: UITapGestureRecognizer) {
            guard let tappedView = gesture.view else { return }
            
            // Deselect previous view
            if let previousView = selectedView {
                previousView.layer.borderWidth = 0
                previousView.backgroundColor = UIColor(red: 0.95, green: 0.85, blue: 0.90, alpha: 1.0)
            }
            
            // Select new view
            selectedView = tappedView
            selectedMovementType = getMovementType(from: tappedView.tag)
            
            // Highlight selected view
            tappedView.layer.borderWidth = 3
        tappedView.layer.borderColor = UIColor(hex:"#fe7a96").cgColor
        tappedView.backgroundColor = UIColor(hex:"#fe7a96").withAlphaComponent(0.1)
        }

    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if let movementType = selectedMovementType {
        print("Selected movement type: \(movementType)")
        
        // Save to UserDefaults
        UserDefaults.standard.set(movementType, forKey: "userWorkoutType")
        
        // Navigate to next screen
        //performSegue(withIdentifier: "toNextScreen", sender: nil)
    } else {
        print("No movement type selected")
        
        // Show alert to user
        let alert = UIAlertController(title: "Selection Required",
                                    message: "Please select a movement type",
                                    preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
        
    }
    
}
