//
//  DietTypeViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 17/01/26.
//

import UIKit

class DietTypeViewController: UIViewController {
    
    @IBOutlet weak var balancedDietView: UIView!
    @IBOutlet weak var frequentsugarView: UIView!
    @IBOutlet weak var irregularMealView: UIView!
    @IBOutlet weak var noDataView: UIView!
    
    @IBOutlet weak var nextButton: UIButton!
    // Track selected view
    private var selectedView: UIView?
    private var selectedDietType: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.tintColor = UIColor(hex:"FE7A96")
        balancedDietView.layer.cornerRadius = 20
        frequentsugarView.layer.cornerRadius = 20
        irregularMealView.layer.cornerRadius = 20
        noDataView.layer.cornerRadius = 20
        
        // Add tap gestures to each view
       addTapGesture(to: balancedDietView, dietType: "Balanced Diet")
       addTapGesture(to: frequentsugarView, dietType: "Frequent Sugar")
       addTapGesture(to: irregularMealView, dietType: "Irregular Meals")
       addTapGesture(to: noDataView, dietType: "Not Sure Yet")
        
    }
    
    private func addTapGesture(to view: UIView, dietType: String) {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
            view.isUserInteractionEnabled = true
            view.tag = getTag(for: dietType)
            view.addGestureRecognizer(tapGesture)
        }
    
    private func getTag(for dietType: String) -> Int {
    switch dietType {
    case "Balanced Diet": return 1
    case "Frequent Sugar": return 2
    case "Irregular Meals": return 3
    case "Not Sure Yet": return 4
    default: return 0
    }
        }
    
    private func getDietType(from tag: Int) -> String {
            switch tag {
            case 1: return "Balanced Diet"
            case 2: return "Frequent Sugar"
            case 3: return "Irregular Meals"
            case 4: return "Not Sure Yet"
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
            selectedDietType = getDietType(from: tappedView.tag)
            
            // Highlight selected view
            tappedView.layer.borderWidth = 3
        tappedView.layer.borderColor = UIColor(hex: "fe7a96").cgColor
        tappedView.backgroundColor = UIColor(hex:"#fe7a96").withAlphaComponent(0.1)
        }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        if let dietType = selectedDietType {
                    print("Selected diet type: \(dietType)")
                    
                    // Save to UserDefaults
                    UserDefaults.standard.set(dietType, forKey: "userDietType")
                    
                    // Navigate to next screen
                    //performSegue(withIdentifier: "toNextScreen", sender: nil)
                } else {
                    print("No diet type selected")
                    
                    // Show alert to user
                    let alert = UIAlertController(title: "Selection Required",
                                                message: "Please select a diet type",
                                                preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    present(alert, animated: true)
                }
    }
    
}
