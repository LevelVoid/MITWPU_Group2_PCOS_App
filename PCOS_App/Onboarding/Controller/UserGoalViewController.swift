//
//  UserGoalViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 17/01/26.
//

import UIKit

class UserGoalViewController: UIViewController {
    
    @IBOutlet weak var cycleRegularityCard: UIView!
    @IBOutlet weak var weightManagementCard: UIView!
    @IBOutlet weak var acneHairCard: UIView!
    @IBOutlet weak var energyLevelCard: UIView!
    
    @IBOutlet weak var nextButton: UIButton!
    private var selectedView: UIView?
    private var selectedGoalType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextButton.tintColor = UIColor(hex:"FE7A96")
        cycleRegularityCard.layer.cornerRadius = 20
        weightManagementCard.layer.cornerRadius = 20
        acneHairCard.layer.cornerRadius = 20
        energyLevelCard.layer.cornerRadius = 20
        
        addTapGesture(to: cycleRegularityCard, goalType: "Improve cycle regularity")
        addTapGesture(to: weightManagementCard, goalType: "Manage weight comfortably")
        addTapGesture(to: acneHairCard, goalType: "Reduce acne/hair concerns")
        addTapGesture(to: energyLevelCard, goalType: "Boost daily energy levels")
    }
    
    private func addTapGesture(to view: UIView, goalType: String) {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
        view.isUserInteractionEnabled = true
        view.tag = getTag(for: goalType)
        view.addGestureRecognizer(tapGesture)
    }
    
    private func getGoalType(from tag: Int) -> String {
        switch tag {
        case 1: return "Improve cycle regularity"  // Changed from "Regular Cycles"
        case 2: return "Manage weight comfortably"  // Changed from "Manage Weight"
        case 3: return "Reduce acne/hair concerns"  // Changed from "Acne Hair Management"
        case 4: return "Boost daily energy levels"  // Changed from "Energy Levels"
        default: return ""
        }
    }

    private func getTag(for goalType: String) -> Int {
        switch goalType {
        case "Improve cycle regularity": return 1
        case "Manage weight comfortably": return 2
        case "Reduce acne/hair concerns": return 3
        case "Boost daily energy levels": return 4
        default: return 0
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
        selectedGoalType = getGoalType(from: tappedView.tag)
        
        // Highlight selected view
        tappedView.layer.borderWidth = 3
        tappedView.layer.borderColor = UIColor(hex:"#fe7a96").cgColor
        tappedView.backgroundColor = UIColor(hex:"fe7a96").withAlphaComponent(0.1)
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        // Check if a goal was selected
        guard let goalType = selectedGoalType else {
            // Show alert to user
            let alert = UIAlertController(title: "Selection Required",
                                          message: "Please select a goal",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return // Exit early if no selection
        }
        
        // Save selected goal to UserDefaults
        UserDefaults.standard.set(goalType, forKey: "userGoalType")
        
        // Now gather ALL onboarding data from UserDefaults
        // Gather ALL onboarding data from UserDefaults
        let name = UserDefaults.standard.string(forKey: "userName") ?? ""
        let dob = UserDefaults.standard.object(forKey: "userDOB") as? Date ?? Date()
        let dietType = UserDefaults.standard.string(forKey: "userDietType") ?? "Not sure yet"
        let workoutType = UserDefaults.standard.string(forKey: "userWorkoutType") ?? "Mostly sedentary"
        let finalGoalType = UserDefaults.standard.string(forKey: "userGoalType") ?? "Improve cycle regularity"
        
        // --- Height: convert to cm if stored in inches ---
        let rawHeight = UserDefaults.standard.integer(forKey: "userHeight")
        let heightIsMetric = UserDefaults.standard.bool(forKey: "heightIsMetric")
        let heightInCm: Double = heightIsMetric ? Double(rawHeight) : Double(rawHeight) * 2.54
        
        // --- Weight: convert to kg if stored in lbs ---
        let rawWeight = UserDefaults.standard.integer(forKey: "userWeight")
        let weightIsMetric = UserDefaults.standard.bool(forKey: "weightIsMetric")
        let weightInKg: Double = weightIsMetric ? Double(rawWeight) : Double(rawWeight) / 2.205

        // Create complete profile with all onboarding data
        // Create complete profile with all onboarding data
        let profile = ProfileModel(
            name: name,
            dob: dob,
            height: Int(heightInCm),
            weight: Int(weightInKg),
            dietType: dietType,
            workoutType: workoutType,
            goalType: finalGoalType
        )
        
        // Save to ProfileService (which now writes to Core Data)
        ProfileService.shared.setProfile(to: profile)
        // Mark onboarding as complete — this flag is checked by SceneDelegate on every launch
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        print("Complete profile saved! Height: \(heightInCm)cm, Weight: \(weightInKg)kg")
        print("Complete profile saved!")
        
        // Clear temporary onboarding data
        //clearOnboardingData()
        
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarVC = mainStoryboard.instantiateViewController(withIdentifier: "MainTabBarController")
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = tabBarVC
            window.makeKeyAndVisible()
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }

        
//        func clearOnboardingData() {
//            UserDefaults.standard.removeObject(forKey: "userName")
//            UserDefaults.standard.removeObject(forKey: "userHeight")
//            UserDefaults.standard.removeObject(forKey: "userWeight")
//            UserDefaults.standard.removeObject(forKey: "userDOB")
//            UserDefaults.standard.removeObject(forKey: "userDietType")
//            UserDefaults.standard.removeObject(forKey: "userWorkoutType")
//            UserDefaults.standard.removeObject(forKey: "userGoalType")
//            UserDefaults.standard.removeObject(forKey: "heightIsMetric")
//            
//            print("🧹 Onboarding data cleared")
//        }
        
        
    }
}

