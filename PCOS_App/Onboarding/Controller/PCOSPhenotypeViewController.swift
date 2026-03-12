//
//  PCOSPhenotypeViewController.swift
//  PCOS_App
//
//  Created by SDC-USER on 17/01/26.
//

import UIKit


class PCOSPhenotypeViewController: UIViewController {
    
    @IBOutlet weak var typeACard: UIView!
    @IBOutlet weak var typeBCard: UIView!
    @IBOutlet weak var typeCCard: UIView!
    @IBOutlet weak var typeDCard: UIView!
    @IBOutlet weak var dontKnowCard: UIView!
    
    @IBOutlet weak var continueButton: UIButton!
    
    private var selectedView: UIView?
    private var selectedPhenotype: PCOSPhenotype?
    
    // Store original background colors
    private var originalBackgroundColors: [Int: UIColor] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupCardGestures()
    }
    
    private func setupUI() {
        continueButton.tintColor = UIColor(hex: "FE7A96")
        
        // Round all cards
        let allCards = [typeACard, typeBCard, typeCCard, typeDCard, dontKnowCard]
        for card in allCards {
            card?.layer.cornerRadius = 20
        }
    }
    
    private func setupCardGestures() {
        // Add tap gestures to each card
        addTapGesture(to: typeACard, phenotype: .typeA)
        addTapGesture(to: typeBCard, phenotype: .typeB)
        addTapGesture(to: typeCCard, phenotype: .typeC)
        addTapGesture(to: typeDCard, phenotype: .typeD)
        addTapGesture(to: dontKnowCard, phenotype: .unknown)
        
        // Store original background colors AFTER tags are assigned
        let allCards = [typeACard, typeBCard, typeCCard, typeDCard, dontKnowCard]
        for card in allCards {
            if let card = card {
                originalBackgroundColors[card.tag] = card.backgroundColor
            }
        }
    }
    
    private func addTapGesture(to view: UIView?, phenotype: PCOSPhenotype) {
        guard let view = view else { return }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        view.isUserInteractionEnabled = true
        view.tag = getTag(for: phenotype)
        view.addGestureRecognizer(tapGesture)
    }
    
    private func getTag(for phenotype: PCOSPhenotype) -> Int {
        switch phenotype {
        case .typeA: return 1
        case .typeB: return 2
        case .typeC: return 3
        case .typeD: return 4
        case .unknown: return 5
        }
    }
    
    private func getPhenotype(from tag: Int) -> PCOSPhenotype {
        switch tag {
        case 1: return .typeA
        case 2: return .typeB
        case 3: return .typeC
        case 4: return .typeD
        case 5: return .unknown
        default: return .unknown
        }
    }
    
    @objc private func cardTapped(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view else { return }
        
        // Deselect previous view - restore original background color
        if let previousView = selectedView {
            previousView.layer.borderWidth = 0
            previousView.backgroundColor = originalBackgroundColors[previousView.tag] ?? UIColor(red: 0.95, green: 0.85, blue: 0.90, alpha: 1.0)
        }
        
        // Select new view
        selectedView = tappedView
        selectedPhenotype = getPhenotype(from: tappedView.tag)
        
        // Highlight selected view
        tappedView.layer.borderWidth = 3
        tappedView.layer.borderColor = UIColor(hex: "#fe7a96").cgColor
        tappedView.backgroundColor = UIColor(hex: "fe7a96").withAlphaComponent(0.1)
    }
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        // Check if a phenotype was selected
        guard let phenotype = selectedPhenotype else {
            // Show alert to user
            let alert = UIAlertController(title: "Selection Required",
                                          message: "Please select a PCOS phenotype",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Save selected phenotype to UserDefaults
        UserDefaults.standard.set(phenotype.rawValue, forKey: "userPCOSPhenotype")
        
        // Gather ALL onboarding data from UserDefaults
        let name = UserDefaults.standard.string(forKey: "userName") ?? ""
        let dob = UserDefaults.standard.object(forKey: "userDOB") as? Date ?? Date()
        let dietType = UserDefaults.standard.string(forKey: "userDietType") ?? "Not sure yet"
        let workoutType = UserDefaults.standard.string(forKey: "userWorkoutType") ?? "Mostly sedentary"
        let pcosPhenotype = UserDefaults.standard.string(forKey: "userPCOSPhenotype") ?? "I Don't Know"
        
        // --- Height: convert to cm if stored in inches ---
        let rawHeight = UserDefaults.standard.integer(forKey: "userHeight")
        let heightIsMetric = UserDefaults.standard.bool(forKey: "heightIsMetric")
        let heightInCm: Double = heightIsMetric ? Double(rawHeight) : Double(rawHeight) * 2.54
        
        // --- Weight: convert to kg if stored in lbs ---
        let rawWeight = UserDefaults.standard.integer(forKey: "userWeight")
        let weightIsMetric = UserDefaults.standard.bool(forKey: "weightIsMetric")
        let weightInKg: Double = weightIsMetric ? Double(rawWeight) / 2.205 : Double(rawWeight)
        
        // Create complete profile with all onboarding data
        let profile = ProfileModel(
            name: name,
            dob: dob,
            height: Int(heightInCm),
            weight: Int(weightInKg),
            dietType: dietType,
            workoutType: workoutType,
            pcosPhenotype: pcosPhenotype
        )
        
        // Save to ProfileService (which now writes to Core Data)
        ProfileService.shared.setProfile(to: profile)
        
        // Mark onboarding as complete
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        print("Complete profile saved! Height: \(heightInCm)cm, Weight: \(weightInKg)kg, Phenotype: \(pcosPhenotype)")
        
        // Navigate to main app
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarVC = mainStoryboard.instantiateViewController(withIdentifier: "MainTabBarController")
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = tabBarVC
            window.makeKeyAndVisible()
            
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
}


