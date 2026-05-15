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
    
    // Store original background colors
    private var originalBackgroundColors: [Int: UIColor] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.tintColor = UIColor(hex:"FE7A96")
        balancedDietView.layer.cornerRadius = 20
        frequentsugarView.layer.cornerRadius = 20
        irregularMealView.layer.cornerRadius = 20
        noDataView.layer.cornerRadius = 20
        
        // Start at 35% opacity — button stays enabled so iOS never overrides with grey
        nextButton.alpha = 0.5
        
        // Add tap gestures to each view (this assigns tags)
       addTapGesture(to: balancedDietView, dietType: "Balanced Diet")
       addTapGesture(to: frequentsugarView, dietType: "Frequent Sugar")
       addTapGesture(to: irregularMealView, dietType: "Irregular Meals")
       addTapGesture(to: noDataView, dietType: "Not Sure Yet")
        
        // Store original background colors AFTER tags are assigned
        let allViews = [balancedDietView, frequentsugarView, irregularMealView, noDataView]
        for view in allViews {
            if let view = view {
                originalBackgroundColors[view.tag] = view.backgroundColor
            }
        }
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
            
            // Deselect previous view - restore original background color
            if let previousView = selectedView {
                previousView.layer.borderWidth = 0
                previousView.backgroundColor = originalBackgroundColors[previousView.tag] ?? UIColor(red: 0.95, green: 0.85, blue: 0.90, alpha: 1.0)
            }
            
            // Select new view
            selectedView = tappedView
            selectedDietType = getDietType(from: tappedView.tag)
            
            // Highlight selected view
            tappedView.layer.borderWidth = 3
        tappedView.layer.borderColor = UIColor(hex: "fe7a96").cgColor
        tappedView.backgroundColor = UIColor(hex:"#fe7a96").withAlphaComponent(0.1)
            
            // Restore full opacity now that a selection is made
            nextButton.alpha = 1.0
        }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let dietType = selectedDietType else { return }
        UserDefaults.standard.set(dietType, forKey: "userDietType")
        ProfileService.shared.updateDietPattern(dietType)
        
        if WalkthroughManager.shared.isActive {
            if WalkthroughManager.shared.isAbortedMode {
                dismiss(animated: true) {
                    WalkthroughManager.shared.continueAbortedFlow()
                }
            } else {
                dismiss(animated: true) {
                    guard let window = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .flatMap({ $0.windows })
                        .first(where: { $0.isKeyWindow }) else { return }
                        
                    WalkthroughCongratsView.present(
                        in: window,
                        title: "Great Choice!",
                        body: "Your diet type is set.\nNext, let's explore your workout options!",
                        continueTitle: "Go to Workout"
                    ) {
                        if let tabBarController = window.rootViewController as? UITabBarController {
                            tabBarController.selectedIndex = 2
                        }
                        WalkthroughManager.shared.advanceToStep(.workoutIntro)
                    }
                }
            }
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // During walkthrough we handle navigation ourselves in nextButtonTapped
        if WalkthroughManager.shared.isActive { return false }
        guard let dietType = selectedDietType else { return false }
        // Save BEFORE the segue fires — IBAction timing is unreliable with button-wired segues
        UserDefaults.standard.set(dietType, forKey: "userDietType")
        ProfileService.shared.updateDietPattern(dietType)
        print("Saved diet type: \(dietType)")
        return true
    }
    
}
